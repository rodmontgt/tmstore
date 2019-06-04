package com.twist.tmstore.config;

import com.utils.JsonHelper;

import org.json.JSONObject;

/**
 * Created by Twist Mobile on 7/20/2017.
 */

public class ConsentDialogConfig {

    public static ConsentDialogConfig mConsentDialogConfig;

    private boolean enabled = false;

    private String layout = "";

    private boolean showAlways = false;

    public boolean isEnabled() {
        return enabled;
    }

    public String getLayout() {
        return layout;
    }

    public boolean isShowAlways() {
        return showAlways;
    }

    public static void createConfig(JSONObject jsonObject) {
        mConsentDialogConfig = null;
        if (jsonObject.has("consent_dialog")) {
            try {
                JSONObject obj = jsonObject.getJSONObject("consent_dialog");
                ConsentDialogConfig consentDialogConfig = new ConsentDialogConfig();
                consentDialogConfig.enabled = JsonHelper.getBool(obj, "enabled", consentDialogConfig.enabled);
                consentDialogConfig.layout = JsonHelper.getString(obj, "layout");
                consentDialogConfig.showAlways = JsonHelper.getBool(obj, "show_always");
                mConsentDialogConfig = consentDialogConfig;
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}
