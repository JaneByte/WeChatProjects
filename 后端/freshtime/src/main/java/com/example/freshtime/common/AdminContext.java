package com.example.freshtime.common;

import com.example.freshtime.entity.AdminInfo;

public final class AdminContext {
    private static final ThreadLocal<AdminInfo> ADMIN_HOLDER = new ThreadLocal<>();

    private AdminContext() {
    }

    public static void set(AdminInfo adminInfo) {
        ADMIN_HOLDER.set(adminInfo);
    }

    public static AdminInfo get() {
        return ADMIN_HOLDER.get();
    }

    public static Long getAdminId() {
        AdminInfo adminInfo = get();
        return adminInfo == null ? null : adminInfo.getId();
    }

    public static void clear() {
        ADMIN_HOLDER.remove();
    }
}
