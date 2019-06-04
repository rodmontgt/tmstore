package com.twist.tmstore.entities;

/**
 * Created by Twist Mobile on 13-Dec-16.
 */

public enum RoleType {
    VENDOR("vendor"),
    VENDOR_YITH("yith_vendor"),
    VENDOR_DC("dc_vendor"),
    PENDING_VENDOR("pending_vendor"),
    PENDING_VENDOR_DC("dc_pending_vendor"),
    SELLER("seller"),
    SHOP_MANAGER("shop_manager"),
    CUSTOMER("customer"),
    SUBSCRIBER("subscriber"),
    CONTRIBUTOR("contributor"),
    AUTHOR("author"),
    EDITOR("editor"),
    ADMINISTRATOR("administrator"),
    MANDOOB("mandoob");

    private final String value;

    RoleType(String value) {
        this.value = value;
    }

    public String getValue() {
        return this.value;
    }

    public static RoleType from(String name) {
        if (name != null && !name.equals("")) {
            for (RoleType type : values()) {
                if (type.getValue().equalsIgnoreCase(name)) {
                    return type;
                }
            }
        }
        return CUSTOMER;
    }
}
