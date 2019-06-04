package com.twist.tmstore.config;

import com.utils.JsonHelper;

import org.json.JSONObject;

/**
 * Created by Twist Mobile on 21-Jul-16.
 */

public class TimeSlotConfig {
    public enum PluginType {
        DELIVERY_SLOTS("woocommerce_delivery_slots_copia"),
        PICK_TIME_SELECT("woocommerce_local_pickup_time_select");

        private final String value;

        PluginType(String value) {
            this.value = value;
        }

        public String getValue() {
            return this.value;
        }

        public static PluginType from(String name) {
            if (name != null && !name.equals("")) {
                for (PluginType type : values()) {
                    if (type.getValue().equalsIgnoreCase(name)) {
                        return type;
                    }
                }
            }
            return DELIVERY_SLOTS;
        }
    }

    private boolean enabled;
    private PluginType pluginType;

    private static TimeSlotConfig mTimeSlotConfig;

    private TimeSlotConfig() {
        this.enabled = false;
        this.pluginType = PluginType.DELIVERY_SLOTS;
    }

    public static void createConfiguration(JSONObject jsonObject) {
        try {
            mTimeSlotConfig = new TimeSlotConfig();
            mTimeSlotConfig.enabled = JsonHelper.getBool(jsonObject, "enabled", false);
            mTimeSlotConfig.pluginType = PluginType.from(JsonHelper.getString(jsonObject, "plugin"));
        } catch (Exception e) {
            e.printStackTrace();
            mTimeSlotConfig = null;
        }
    }

    public static void resetConfig() {
        mTimeSlotConfig = null;
    }

    public static boolean isEnabled() {
        return mTimeSlotConfig != null && mTimeSlotConfig.enabled;
    }

    public static PluginType getPluginType() {
        if (mTimeSlotConfig != null) {
            return mTimeSlotConfig.pluginType;
        }
        return PluginType.DELIVERY_SLOTS;
    }
}
