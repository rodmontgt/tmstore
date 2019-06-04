package com.twist.tmstore.config;

import com.twist.tmstore.entities.AppInfo;
import com.utils.JsonHelper;
import com.utils.Log;

import org.json.JSONObject;

/**
 * Created by Twist Mobile on 2/1/2017.
 */

public class CategoryLayoutsConfig {

    private int[] mLayoutIds = null;
    private boolean mEnabled = false;

    public boolean isEnabled() {
        return mEnabled;
    }

    public void setEnabled(boolean mEnabled) {
        this.mEnabled = mEnabled;
    }

    public int[] getLayoutIds() {
        return mLayoutIds;
    }

    public static void createConfig(JSONObject jsonObject) {
        AppInfo.mCategoryLayoutsConfig = null;
        try {
            if(jsonObject.has("category_layouts")) {
                JSONObject configJsonObject = jsonObject.getJSONObject("category_layouts");
                CategoryLayoutsConfig config = new CategoryLayoutsConfig();
                config.mEnabled = JsonHelper.getBool(configJsonObject, "enabled", config.mEnabled);
                config.mLayoutIds = JsonHelper.getIntArray(configJsonObject, "layout_ids");
                if (config.mLayoutIds == null || config.mLayoutIds.length == 0) {
                    config.mEnabled = false;
                }
                AppInfo.mCategoryLayoutsConfig = config;
            }
        } catch (Exception e) {
            e.printStackTrace();
            AppInfo.mCategoryLayoutsConfig = null;
            Log.e("Error while parsing " + CategoryLayoutsConfig.class.getSimpleName() + " JSON");
        }
    }
}
