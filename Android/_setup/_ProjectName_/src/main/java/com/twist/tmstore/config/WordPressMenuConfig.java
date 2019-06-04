package com.twist.tmstore.config;

import com.utils.JsonHelper;
import com.utils.Log;

import org.json.JSONObject;

/**
 * Created by Twist Mobile on 14-02-2017.
 */

public class WordPressMenuConfig {

    private boolean enabled;
    private int[] menuIds;

    private static WordPressMenuConfig mWordPressMenuConfig;

    public static WordPressMenuConfig getInstance() {
        if (mWordPressMenuConfig == null) {
            mWordPressMenuConfig = new WordPressMenuConfig();
        }
        return mWordPressMenuConfig;
    }

    private WordPressMenuConfig() {
        this.enabled = false;
        this.menuIds = null;
    }

    public boolean isEnabled() {
        return enabled;
    }

    public int[] getMenuIds() {
        return menuIds;
    }

    public static void createConfig(JSONObject jsonObject) {
        mWordPressMenuConfig = null;
        try {
            if (jsonObject.has("show_wordpress_menu")) {
                WordPressMenuConfig config = WordPressMenuConfig.getInstance();
                config.enabled = JsonHelper.getBool(jsonObject, "show_wordpress_menu", config.enabled);
                config.menuIds = JsonHelper.getIntArray(jsonObject, "wordpress_menu_ids");
            }
        } catch (Exception e) {
            e.printStackTrace();
            mWordPressMenuConfig = null;
            Log.e("Error while parsing { WORDPRESS_MENU_IDS } config");
        }
    }
}
