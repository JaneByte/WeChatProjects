package com.example.freshtime.common;

public final class AuthContext {
    private static final ThreadLocal<AuthUser> AUTH_USER_HOLDER = new ThreadLocal<>();

    private AuthContext() {
    }

    public static void set(AuthUser authUser) {
        AUTH_USER_HOLDER.set(authUser);
    }

    public static AuthUser get() {
        return AUTH_USER_HOLDER.get();
    }

    public static Long getUserId() {
        AuthUser authUser = get();
        return authUser == null ? null : authUser.getUserId();
    }

    public static void clear() {
        AUTH_USER_HOLDER.remove();
    }
}
