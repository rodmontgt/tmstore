package com.twist.tmstore.config;

import com.utils.JsonHelper;

import org.json.JSONObject;

/**
 * Created by Twist Mobile on 28-03-2017.
 */

public class NavDrawerConfig {

//            String jsonString = "{\n" +
//                "  \"nav_drawer\": {\n" +
//                "    \"enabled\": true,\n" +
//                "    \"bg_color\": \"#00B08E\",\n" +
//                "    \"main_menu\": {\n" +
//                "      \"enabled\": true,\n" +
//                "      \"bg_color\": \"#00B08E\",\n" +
//                "      \"indicator_color\": \"#C2FFF3\",\n" +
//                "      \"icon\": {\n" +
//                "        \"visible\": true,\n" +
//                "        \"color\": \"#C2FFF3\"\n" +
//                "      },\n" +
//                "      \"divider\": {\n" +
//                "        \"color\": \"#00A383\",\n" +
//                "        \"height\": 2\n" +
//                "      },\n" +
//                "      \"title\": {\n" +
//                "        \"color\": \"#C2FFF3\",\n" +
//                "        \"caps_all\": true\n" +
//                "      }\n" +
//                "    },\n" +
//                "    \"child_menu\": {\n" +
//                "      \"enabled\": true,\n" +
//                "      \"bg_color\": \"#00CCA3\",\n" +
//                "      \"divider\": {\n" +
//                "        \"color\": \"#00E0B4\",\n" +
//                "        \"height\": 0\n" +
//                "      },\n" +
//                "      \"title\": {\n" +
//                "        \"color\": \"#C2FFF3\",\n" +
//                "        \"caps_all\": true\n" +
//                "      }\n" +
//                "    }\n" +
//                "  }\n" +
//                "}";

    private static NavDrawerConfig mNavDrawerConfig;

    public boolean enabled = true;

    public String bgColor = "#fbfbfb";

    public static class MainMenuConfig {
        public boolean enabled = true;
        public String bgColor = "#fbfbfb";
        public String indicatorColor = "#6f6f6f";
        public String dividerColor = "#f6f6f6";
        public int dividerHeight = 1;
        public int[] hideDividers = null;
        public String titleTextColor = "#6f6f6f";
        public boolean titleCapsAll = true;
        public boolean iconVisible = true;
        public String iconColor = "#6f6f6f";
    }

    public static class ChildMenuConfig {
        public boolean enabled = true;
        public String bgColor = "#fbfbfb";
        public String dividerColor = "#f6f6f6";
        public int dividerHeight = 1;
        public int[] hideDividers = null;
        public String titleTextColor = "#6f6f6f";
        public boolean titleCapsAll = true;
    }

    public static NavDrawerConfig getInstance() {
        if (mNavDrawerConfig == null) {
            mNavDrawerConfig = new NavDrawerConfig();
        }
        return mNavDrawerConfig;
    }

    private MainMenuConfig mMainMenuConfig = new MainMenuConfig();

    private ChildMenuConfig mChildMenuConfig = new ChildMenuConfig();

    public MainMenuConfig getMainMenuConfig() {
        return mMainMenuConfig;
    }

    public ChildMenuConfig getChildMenuConfig() {
        return mChildMenuConfig;
    }

    public static void createConfig(JSONObject rootJsonObject) {
        if(!rootJsonObject.has("nav_drawer")) {
            mNavDrawerConfig = null;
            return;
        }
        try {
            mNavDrawerConfig = NavDrawerConfig.getInstance();
            rootJsonObject = rootJsonObject.getJSONObject("nav_drawer");
            if (rootJsonObject.has("main_menu")) {
                mNavDrawerConfig.enabled = JsonHelper.getBool(rootJsonObject, "enabled", mNavDrawerConfig.enabled);
                mNavDrawerConfig.bgColor = JsonHelper.getString(rootJsonObject, "bg_color", mNavDrawerConfig.bgColor, true);

                try {
                    MainMenuConfig config = mNavDrawerConfig.mMainMenuConfig;
                    JSONObject jsonObject = rootJsonObject.getJSONObject("main_menu");
                    config.enabled = JsonHelper.getBool(jsonObject, "enabled", config.enabled);
                    config.bgColor = JsonHelper.getString(jsonObject, "bg_color", config.bgColor, true);
                    config.indicatorColor = JsonHelper.getString(jsonObject, "indicator_color", config.indicatorColor, true);

                    if (jsonObject.has("icon")) {
                        JSONObject object = jsonObject.getJSONObject("icon");
                        config.iconVisible = JsonHelper.getBool(object, "visible", config.iconVisible);
                        config.iconColor = JsonHelper.getString(object, "color", config.iconColor, true);
                    }

                    if (jsonObject.has("divider")) {
                        JSONObject object = jsonObject.getJSONObject("divider");
                        config.dividerColor = JsonHelper.getString(object, "color", config.dividerColor, true);
                        config.dividerHeight = JsonHelper.getInt(object, "height", config.dividerHeight);
                        config.hideDividers = JsonHelper.getIntArray(object, "hide");
                    }

                    if (jsonObject.has("title")) {
                        JSONObject object = jsonObject.getJSONObject("title");
                        config.titleTextColor = JsonHelper.getString(object, "color", config.titleTextColor, true);
                        config.titleCapsAll = JsonHelper.getBool(object, "caps_all", config.titleCapsAll);
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }

            if (rootJsonObject.has("child_menu")) {
                try {
                    ChildMenuConfig config = mNavDrawerConfig.mChildMenuConfig;
                    JSONObject jsonObject = rootJsonObject.getJSONObject("child_menu");
                    config.enabled = JsonHelper.getBool(jsonObject, "enabled", config.enabled);
                    config.bgColor = JsonHelper.getString(jsonObject, "bg_color", config.bgColor, true);

                    if (jsonObject.has("divider")) {
                        JSONObject object = jsonObject.getJSONObject("divider");
                        config.dividerColor = JsonHelper.getString(object, "color", config.dividerColor, true);
                        config.dividerHeight = JsonHelper.getInt(object, "height", config.dividerHeight);
                        config.hideDividers = JsonHelper.getIntArray(object, "hide");
                    }

                    if (jsonObject.has("title")) {
                        JSONObject object = jsonObject.getJSONObject("title");
                        config.titleTextColor = JsonHelper.getString(object, "color", config.titleTextColor, true);
                        config.titleCapsAll = JsonHelper.getBool(object, "caps_all", config.titleCapsAll);
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
