package com.twist.tmstore.config;

import com.utils.JsonHelper;

import org.json.JSONObject;

/**
 * Created by Twist Mobile on 2/27/2017.
 */

public class PesaPalConfig {

    private boolean enabled = false;
    private String baseUrl = "";
    private String successUrl = "";
    private String failureUrl = "";

    private static PesaPalConfig mPesaPalConfig;

    public String getBaseUrl() {
        return baseUrl;
    }

    public String getSuccessUrl() {
        return successUrl;
    }

    public String getFailureUrl() {
        return failureUrl;
    }

    public boolean isEnabled() {
        return enabled;
    }


    public static PesaPalConfig getInstance() {
        if (mPesaPalConfig == null) {
            mPesaPalConfig = new PesaPalConfig();
        }
        return mPesaPalConfig;
    }

    public static void create(JSONObject jsonObject) {
        try {
            mPesaPalConfig = PesaPalConfig.getInstance();
            mPesaPalConfig.enabled = JsonHelper.getBool(jsonObject, "enabled");
            mPesaPalConfig.baseUrl = JsonHelper.getString(jsonObject, "baseurl");
            mPesaPalConfig.successUrl = JsonHelper.getString(jsonObject, "furl");
            mPesaPalConfig.failureUrl = JsonHelper.getString(jsonObject, "surl");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
