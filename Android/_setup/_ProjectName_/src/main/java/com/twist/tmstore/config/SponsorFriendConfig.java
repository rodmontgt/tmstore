package com.twist.tmstore.config;

import com.utils.JsonHelper;

import org.json.JSONObject;

/**
 * Created by Twist Mobile on 08-02-2017.
 */

public class SponsorFriendConfig {

    private static SponsorFriendConfig mSponsorFriendConfig;

    public static SponsorFriendConfig getInstance() {
        if (mSponsorFriendConfig == null) {
            mSponsorFriendConfig = new SponsorFriendConfig();
        }
        return mSponsorFriendConfig;
    }

    private boolean enabled;

    private String sponsorImageUrl;

    private SponsorFriendConfig() {
        this.enabled = false;
        this.sponsorImageUrl = "";
    }

    public boolean isEnabled() {
        return enabled;
    }

    public String getSponsorImageUrl() {
        return sponsorImageUrl;
    }

    public static void createConfig(JSONObject jsonObject) {
        try {
            mSponsorFriendConfig = SponsorFriendConfig.getInstance();
            mSponsorFriendConfig.enabled = JsonHelper.getBool(jsonObject, "enabled");
            mSponsorFriendConfig.sponsorImageUrl = JsonHelper.getString(jsonObject, "sponsor_img_url");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void resetConfig() {
        mSponsorFriendConfig = null;
    }
}
