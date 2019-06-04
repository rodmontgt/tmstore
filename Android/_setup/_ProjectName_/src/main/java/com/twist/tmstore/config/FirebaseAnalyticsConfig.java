package com.twist.tmstore.config;

import com.utils.JsonHelper;

import org.json.JSONObject;

/**
 * Created by Twist Mobile on 03-02-2017.
 */

public class FirebaseAnalyticsConfig {

    private static FirebaseAnalyticsConfig firebaseAnalyticsConfig;
    private boolean enabled = false;

    private FirebaseAnalyticsConfig() {
        this.enabled = false;
    }

    public static boolean isEnabled() {
        return firebaseAnalyticsConfig != null && firebaseAnalyticsConfig.enabled;
    }

    public void setEnabled(boolean enabled) {
        this.enabled = enabled;
    }

    public static void createConfiguration(JSONObject jsonObject) {
        try {
            firebaseAnalyticsConfig = new FirebaseAnalyticsConfig();
            firebaseAnalyticsConfig.enabled = JsonHelper.getBool(jsonObject, "enabled", true);
        } catch (Exception e) {
            e.printStackTrace();
            firebaseAnalyticsConfig = null;
        }
    }

    public static void resetConfig() {
        firebaseAnalyticsConfig = null;
    }
}
