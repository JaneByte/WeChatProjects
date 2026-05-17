package com.example.freshtime.common;

import com.example.freshtime.entity.AdminInfo;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.Base64;

@Component
public class AdminTokenUtil {
    private static final String HMAC_ALGORITHM = "HmacSHA256";
    private static final long DEFAULT_EXPIRE_SECONDS = 24L * 60 * 60;

    @Value("${app.admin-auth.token-secret:freshtime-admin-secret}")
    private String tokenSecret;

    @Value("${app.admin-auth.token-expire-seconds:" + DEFAULT_EXPIRE_SECONDS + "}")
    private long tokenExpireSeconds;

    public String generateToken(AdminInfo admin) {
        long expireAt = Instant.now().getEpochSecond() + Math.max(tokenExpireSeconds, 60);
        String payload = String.format("%s|%s|%s|%s",
                admin.getId(),
                safeText(admin.getUsername()),
                safeText(admin.getNickname()),
                expireAt);
        return base64UrlEncode(payload) + "." + sign(payload);
    }

    public long getExpireAtMillis() {
        long seconds = Math.max(tokenExpireSeconds, 60);
        return (Instant.now().getEpochSecond() + seconds) * 1000;
    }

    public Long parseAdminId(String token) {
        if (token == null || token.trim().isEmpty()) {
            return null;
        }
        String[] parts = token.trim().split("\\.");
        if (parts.length != 2) {
            return null;
        }

        String payload;
        try {
            payload = new String(Base64.getUrlDecoder().decode(parts[0]), StandardCharsets.UTF_8);
        } catch (IllegalArgumentException ex) {
            return null;
        }

        if (!sign(payload).equals(parts[1])) {
            return null;
        }

        String[] fields = payload.split("\\|", 4);
        if (fields.length < 4) {
            return null;
        }

        try {
            long expireAt = Long.parseLong(fields[3]);
            if (Instant.now().getEpochSecond() >= expireAt) {
                return null;
            }
            return Long.valueOf(fields[0]);
        } catch (NumberFormatException ex) {
            return null;
        }
    }

    private String base64UrlEncode(String value) {
        return Base64.getUrlEncoder().withoutPadding().encodeToString(value.getBytes(StandardCharsets.UTF_8));
    }

    private String sign(String payload) {
        try {
            Mac mac = Mac.getInstance(HMAC_ALGORITHM);
            SecretKeySpec secretKey = new SecretKeySpec(tokenSecret.getBytes(StandardCharsets.UTF_8), HMAC_ALGORITHM);
            mac.init(secretKey);
            byte[] bytes = mac.doFinal(payload.getBytes(StandardCharsets.UTF_8));
            return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
        } catch (Exception ex) {
            throw new IllegalStateException("admin token sign failed", ex);
        }
    }

    private String safeText(String text) {
        return text == null ? "" : text.replace("|", "").trim();
    }
}
