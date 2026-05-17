package com.example.freshtime.common;

import com.example.freshtime.entity.AdminInfo;
import com.example.freshtime.mapper.AdminMapper;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@Component
public class AdminAuthInterceptor implements HandlerInterceptor {

    private final AdminTokenUtil adminTokenUtil;
    private final AdminMapper adminMapper;

    public AdminAuthInterceptor(AdminTokenUtil adminTokenUtil, AdminMapper adminMapper) {
        this.adminTokenUtil = adminTokenUtil;
        this.adminMapper = adminMapper;
    }

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
            return true;
        }
        String authorization = request.getHeader("Authorization");
        String token = extractBearerToken(authorization);
        Long adminId = adminTokenUtil.parseAdminId(token);
        if (adminId == null) {
            writeUnauthorized(response);
            return false;
        }
        AdminInfo adminInfo = adminMapper.selectById(adminId);
        if (adminInfo == null || adminInfo.getStatus() == null || adminInfo.getStatus() != 1) {
            writeForbidden(response);
            return false;
        }
        AdminContext.set(adminInfo);
        return true;
    }

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) {
        AdminContext.clear();
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
        response.getWriter().write("{\"code\":401,\"message\":\"请先登录管理端\",\"data\":null,\"timestamp\":" + System.currentTimeMillis() + "}");
    }

    private void writeForbidden(HttpServletResponse response) throws Exception {
        response.setStatus(403);
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write("{\"code\":403,\"message\":\"店铺账号不可用\",\"data\":null,\"timestamp\":" + System.currentTimeMillis() + "}");
    }
}
