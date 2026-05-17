package com.example.freshtime.common;

import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@Component
public class AuthInterceptor implements HandlerInterceptor {
    private final AuthTokenUtil authTokenUtil;

    public AuthInterceptor(AuthTokenUtil authTokenUtil) {
        this.authTokenUtil = authTokenUtil;
    }

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        String authorization = request.getHeader("Authorization");
        String token = extractBearerToken(authorization);
        AuthUser authUser = authTokenUtil.parseToken(token);
        if (authUser == null || authUser.getUserId() == null) {
            writeUnauthorized(response);
            return false;
        }
        AuthContext.set(authUser);
        return true;
    }

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) {
        AuthContext.clear();
    }

    private String extractBearerToken(String authorization) {
        if (authorization == null) {
            return "";
        }
        String prefix = "Bearer ";
        if (!authorization.startsWith(prefix)) {
            return "";
        }
        return authorization.substring(prefix.length()).trim();
    }

    private void writeUnauthorized(HttpServletResponse response) throws Exception {
        response.setStatus(401);
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write("{\"code\":401,\"message\":\"登录已失效，请重新登录\",\"data\":null,\"timestamp\":" + System.currentTimeMillis() + "}");
    }
}
