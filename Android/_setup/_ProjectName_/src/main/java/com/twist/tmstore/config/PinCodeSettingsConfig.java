package com.twist.tmstore.config;

import android.text.TextUtils;

import com.utils.JsonHelper;

import org.json.JSONObject;

/**
 * Created by Twist Mobile on 07-02-2017.
 */

public class PinCodeSettingsConfig {

    private static PinCodeSettingsConfig mPinCodeSettingsConfig;

    public static PinCodeSettingsConfig getInstance() {
        if (mPinCodeSettingsConfig == null) {
            mPinCodeSettingsConfig = new PinCodeSettingsConfig();
        }
        return mPinCodeSettingsConfig;
    }

    private boolean enabled;

    private String name;

    private CheckType checkType;

    public enum CheckType {
        CHECK_PER_PRODUCT("check_per_product"),
        CHECK_ALL_PRODUCT("check_all_product");

        private final String value;

        CheckType(String value) {
            this.value = value;
        }

        public String getValue() {
            return this.value;
        }

        public static CheckType from(String name) {
            if (!TextUtils.isEmpty(name)) {
                for (CheckType type : values()) {
                    if (type.value.equalsIgnoreCase(name)) {
                        return type;
                    }
                }
            }
            return CHECK_ALL_PRODUCT;
        }
    }

    private PinCodeSettingsConfig() {
        this.enabled = false;
        this.name = "";
    }

    public boolean isEnabled() {
        return enabled;
    }

    public void setEnabled(boolean enabled) {
        this.enabled = enabled;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public CheckType getCheckType() {
        return checkType;
    }

    public void setCheckType(CheckType checkType) {
        this.checkType = checkType;
    }

    public static void createConfigOld(JSONObject jsonObject) {
        // Insures that older configurations works as well.
        mPinCodeSettingsConfig = null;
        if (jsonObject.has("enable_pincode_settings")) {
            try {
                mPinCodeSettingsConfig = PinCodeSettingsConfig.getInstance();
                mPinCodeSettingsConfig.enabled = JsonHelper.getBool(jsonObject, "enable_pincode_settings", false);
                mPinCodeSettingsConfig.checkType = CheckType.CHECK_ALL_PRODUCT;
            } catch (Exception e) {
                e.printStackTrace();
                mPinCodeSettingsConfig = null;
            }
        }
    }

    public static void createConfig(JSONObject jsonObject) {
        try {
            mPinCodeSettingsConfig = PinCodeSettingsConfig.getInstance();
            mPinCodeSettingsConfig.enabled = JsonHelper.getBool(jsonObject, "enabled");
            mPinCodeSettingsConfig.checkType = CheckType.from(JsonHelper.getString(jsonObject, "check_type"));
        } catch (Exception e) {
            e.printStackTrace();
            mPinCodeSettingsConfig = null;
        }
    }

    public static void resetConfig() {
        mPinCodeSettingsConfig = null;
    }
}
