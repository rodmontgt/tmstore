package com.twist.tmstore.entities;

/**
 * Created by Twist Mobile on 8/3/2016.
 */

public class FeeData {
    public enum Type {
        FIXED("fixed"),
        PERCENT("percent");

        private final String value;

        Type(String value) {
            this.value = value;
        }

        public String getValue() {
            return this.value;
        }

        public static Type from(String name) {
            if (name != null && !name.equals("")) {
                for (FeeData.Type type : values()) {
                    if (type.getValue().equalsIgnoreCase(name)) {
                        return type;
                    }
                }
            }
            return Type.FIXED;
        }
    }

    public String plugin_title;
    public String label;
    public boolean taxable;
    public float minorder;
    public float cost;
    public Type type;
}
