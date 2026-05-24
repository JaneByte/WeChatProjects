package com.example.freshtime.service.impl;

import com.example.freshtime.common.ApiResponse;
import com.example.freshtime.common.AuthContext;
import com.example.freshtime.common.AuthTokenUtil;
import com.example.freshtime.dto.LoginRequest;
import com.example.freshtime.dto.UserProfileUpdateRequest;
import com.example.freshtime.entity.UserInfo;
import com.example.freshtime.mapper.UserMapper;
import com.example.freshtime.service.AuthService;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.regex.Pattern;

@Service
public class AuthServiceImpl implements AuthService {
    private static final Logger log = LoggerFactory.getLogger(AuthServiceImpl.class);
    private static final String LOGIN_TYPE_WECHAT = "wechat";
    private static final String LOGIN_TYPE_GUEST = "guest";
    private static final int MAX_NICKNAME_LENGTH = 20;
    private static final Pattern REMOTE_AVATAR_PATTERN = Pattern.compile("^(https?:)?//.+");
    private static final Pattern CLOUD_AVATAR_PATTERN = Pattern.compile("^cloud://.+");
    private static final String CODE_2_SESSION_URL =
            "https://api.weixin.qq.com/sns/jscode2session?appid=%s&secret=%s&js_code=%s&grant_type=authorization_code";

    @Autowired
    private UserMapper userMapper;

    @Autowired
    private AuthTokenUtil authTokenUtil;

    private final ObjectMapper objectMapper = new ObjectMapper();
    private final RestTemplate restTemplate = new RestTemplate();

    @Value("${wechat.miniprogram.app-id:}")
    private String wechatAppId;

    @Value("${wechat.miniprogram.app-secret:}")
    private String wechatAppSecret;

    @Override
    public ApiResponse<?> login(LoginRequest request) {
        if (request == null) {
            return ApiResponse.badRequest("登录参数不能为空");
        }

        String loginType = safeText(request.getLoginType());
        if (loginType.isEmpty()) {
            loginType = LOGIN_TYPE_WECHAT;
        }

        String[] loginMeta = new String[2];
        String openid = resolveOpenid(request, loginType, loginMeta);
        if (openid.isEmpty()) {
            return ApiResponse.badRequest("登录凭证无效");
        }

        String nickname = safeText(request.getNickname());
        if (nickname.isEmpty()) {
            nickname = LOGIN_TYPE_GUEST.equals(loginType) ? "游客用户" : "微信用户";
        }
        String avatar = safeText(request.getAvatar());

        UserInfo user = userMapper.selectByOpenid(openid);
        if (user == null) {
            user = new UserInfo();
            user.setOpenid(openid);
            user.setNickname(nickname);
            user.setAvatar(avatar.isEmpty() ? null : avatar);
            userMapper.insertUser(user);
            user = userMapper.selectById(user.getId());
        } else {
            boolean changed = false;
            if (isDefaultNickname(user.getNickname()) && !nickname.isEmpty() && !nickname.equals(user.getNickname())) {
                user.setNickname(nickname);
                changed = true;
            }
            if (!hasAvatar(user.getAvatar()) && shouldUpdateAvatar(user.getAvatar(), avatar)) {
                user.setAvatar(avatar);
                changed = true;
            }
            if (changed) {
                userMapper.updateProfile(user);
                user = userMapper.selectById(user.getId());
            }
        }

        Map<String, Object> data = new HashMap<>();
        data.put("userId", user.getId());
        data.put("nickname", user.getNickname());
        data.put("openid", user.getOpenid());
        data.put("avatar", user.getAvatar());
        data.put("token", authTokenUtil.generateToken(user));
        data.put("tokenExpireAt", authTokenUtil.getExpireAtMillis());
        log.info("登录成功 mode={} source={} userId={} openid={}",
                loginMeta[0] == null ? loginType : loginMeta[0],
                loginMeta[1] == null ? "unknown" : loginMeta[1],
                user.getId(),
                maskOpenid(user.getOpenid()));
        return ApiResponse.success("登录成功", data);
    }

    @Override
    public ApiResponse<?> updateProfile(UserProfileUpdateRequest request) {
        Long userId = AuthContext.getUserId();
        if (userId == null) {
            return ApiResponse.unauthorized("请先登录");
        }
        if (request == null) {
            return ApiResponse.badRequest("资料参数不能为空");
        }

        UserInfo user = userMapper.selectById(userId);
        if (user == null) {
            return ApiResponse.notFound("用户不存在");
        }

        String nickname = safeText(request.getNickname());
        String avatar = safeText(request.getAvatar());
        String nicknameValidationMessage = validateNickname(nickname);
        if (nicknameValidationMessage != null) {
            return ApiResponse.badRequest(nicknameValidationMessage);
        }
        String avatarValidationMessage = validateAvatar(avatar);
        if (avatarValidationMessage != null) {
            return ApiResponse.badRequest(avatarValidationMessage);
        }
        boolean changed = false;

        if (!nickname.isEmpty() && !nickname.equals(user.getNickname())) {
            user.setNickname(nickname);
            changed = true;
        }
        if (!avatar.isEmpty() && !avatar.equals(safeText(user.getAvatar()))) {
            user.setAvatar(avatar);
            changed = true;
        }

        if (changed) {
            userMapper.updateProfile(user);
            user = userMapper.selectById(userId);
        }

        return ApiResponse.success("资料更新成功", buildUserData(user));
    }

    private String resolveOpenid(LoginRequest request, String loginType, String[] loginMeta) {
        String explicitOpenid = safeText(request.getOpenid());
        if (!explicitOpenid.isEmpty()) {
            setLoginMeta(loginMeta, loginType, "client-openid");
            return explicitOpenid;
        }

        if (LOGIN_TYPE_GUEST.equals(loginType)) {
            setLoginMeta(loginMeta, LOGIN_TYPE_GUEST, "guest-fallback");
            return "guest_" + UUID.randomUUID().toString().replace("-", "").substring(0, 12);
        }

        String code = safeText(request.getCode());
        if (code.isEmpty()) {
            setLoginMeta(loginMeta, loginType, "missing-code");
            return "";
        }

        if (wechatAppId.isEmpty() || wechatAppSecret.isEmpty()) {
            setLoginMeta(loginMeta, LOGIN_TYPE_WECHAT, "dev-fallback");
            return "wxcode_" + code;
        }

        try {
            String requestUrl = String.format(
                    CODE_2_SESSION_URL,
                    urlEncode(wechatAppId),
                    urlEncode(wechatAppSecret),
                    urlEncode(code)
            );
            ResponseEntity<String> response = restTemplate.getForEntity(requestUrl, String.class);
            String body = response.getBody();
            if (body == null || body.trim().isEmpty()) {
                return "";
            }
            JsonNode jsonNode = objectMapper.readTree(body);
            if (jsonNode.has("errcode") && jsonNode.path("errcode").asInt() != 0) {
                setLoginMeta(loginMeta, LOGIN_TYPE_WECHAT, "code2session-failed");
                return "";
            }
            setLoginMeta(loginMeta, LOGIN_TYPE_WECHAT, "code2session");
            return safeText(jsonNode.path("openid").asText(""));
        } catch (Exception ex) {
            setLoginMeta(loginMeta, LOGIN_TYPE_WECHAT, "code2session-error");
            return "";
        }
    }

    private String urlEncode(String text) {
        return URLEncoder.encode(text, StandardCharsets.UTF_8);
    }

    private Map<String, Object> buildUserData(UserInfo user) {
        Map<String, Object> data = new HashMap<>();
        data.put("userId", user.getId());
        data.put("nickname", user.getNickname());
        data.put("openid", user.getOpenid());
        data.put("avatar", user.getAvatar());
        data.put("token", authTokenUtil.generateToken(user));
        data.put("tokenExpireAt", authTokenUtil.getExpireAtMillis());
        return data;
    }

    private void setLoginMeta(String[] loginMeta, String mode, String source) {
        if (loginMeta == null || loginMeta.length < 2) {
            return;
        }
        loginMeta[0] = mode;
        loginMeta[1] = source;
    }

    private String maskOpenid(String openid) {
        String safe = safeText(openid);
        if (safe.length() <= 8) {
            return safe;
        }
        return safe.substring(0, 4) + "****" + safe.substring(safe.length() - 4);
    }

    private boolean shouldUpdateAvatar(String currentAvatar, String nextAvatar) {
        String current = safeText(currentAvatar);
        String next = safeText(nextAvatar);
        return !next.isEmpty() && !next.equals(current);
    }

    private boolean hasAvatar(String avatar) {
        return !safeText(avatar).isEmpty();
    }

    private boolean isDefaultNickname(String nickname) {
        String safeNickname = safeText(nickname);
        return safeNickname.isEmpty() || "微信用户".equals(safeNickname) || "游客用户".equals(safeNickname);
    }

    private String validateNickname(String nickname) {
        if (nickname.isEmpty()) {
            return "昵称不能为空";
        }
        if (nickname.length() > MAX_NICKNAME_LENGTH) {
            return "昵称不能超过20个字符";
        }
        return null;
    }

    private String validateAvatar(String avatar) {
        if (avatar.isEmpty()) {
            return "头像不能为空";
        }
        if (avatar.startsWith("wxfile:") || avatar.startsWith("/tmp/") || avatar.startsWith("http://tmp/")) {
            return "头像地址无效，请重新上传";
        }
        if (avatar.startsWith("/assets/")) {
            return null;
        }
        if (CLOUD_AVATAR_PATTERN.matcher(avatar).matches()) {
            return null;
        }
        if (!REMOTE_AVATAR_PATTERN.matcher(avatar).matches()) {
            return "头像地址格式不正确";
        }
        return null;
    }

    private String safeText(String raw) {
        return raw == null ? "" : raw.trim();
    }
}
