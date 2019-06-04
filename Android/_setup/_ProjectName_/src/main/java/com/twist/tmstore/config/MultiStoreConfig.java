package com.twist.tmstore.config;

import com.parse.ParseObject;
import com.utils.JsonHelper;
import com.utils.ListUtils;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by Twist Mobile on 10-04-2017.
 */

public class MultiStoreConfig implements Serializable {
    private static List<MultiStoreConfig> multiStoreConfigs = new ArrayList<>();
    private static List<MultiStoreConfig> nearByStoreConfigs = new ArrayList<>();
    private static List<MapMenuOption> mapMenuOptions = null;
    private boolean enabled;
    private boolean is_default;//TODO if any store get with this config,app launch taking this store without selection
    private boolean is_active = true;
    private String title;
    private String description;
    private String icon_url;
    private String strLatitude;
    private String strLongitude;
    private double latitude;
    private double longitude;
    private String platform;

    public static List<MultiStoreConfig> getMultiStoreConfigs() {
        return multiStoreConfigs;
    }

    public static List<MultiStoreConfig> getMultiStoreConfigList(boolean filterEnabled) {
        if (!filterEnabled) {
            return multiStoreConfigs;
        }
        List<MultiStoreConfig> list = new ArrayList<>();
        for (MultiStoreConfig multiStoreConfig : multiStoreConfigs) {
            if (multiStoreConfig.isEnabled())
                list.add(multiStoreConfig);
        }
        return list;
    }

    public static List<MultiStoreConfig> getdefaultMultiStoreConfigList(boolean filterEnabled) {
        if (!filterEnabled) {
            return multiStoreConfigs;
        }
        List<MultiStoreConfig> list = new ArrayList<>();
        for (MultiStoreConfig multiStoreConfig : multiStoreConfigs) {
            if (multiStoreConfig.isEnabled() && multiStoreConfig.isDefault())
                list.add(multiStoreConfig);
        }
        return list;
    }

    public static List<MapMenuOption> getMapMenuOptions() {
        return mapMenuOptions;
    }

    public static List<MultiStoreConfig> createConfigs(List<ParseObject> objects, boolean isNearby) {
        List<MultiStoreConfig> list = new ArrayList<>();
        for (ParseObject parseObject : objects) {
            MultiStoreConfig multiStoreConfig = MultiStoreConfig.createConfig(parseObject, isNearby);
            if (multiStoreConfig != null && multiStoreConfig.enabled) {
                list.add(multiStoreConfig);
            }
        }
        return list;
    }

    public static MultiStoreConfig createConfig(ParseObject parseObject, boolean isNearby) {

        MultiStoreConfig multiStoreConfig = new MultiStoreConfig();
        try {
            JSONObject jsonObject = new JSONObject(parseObject.getString("multi_store_config"));
            multiStoreConfig.platform = parseObject.getString("multi_store_platform");
            multiStoreConfig.enabled = JsonHelper.getBool(jsonObject, "enabled");
            multiStoreConfig.title = JsonHelper.getString(jsonObject, "title");
            multiStoreConfig.description = JsonHelper.getString(jsonObject, "description");
            multiStoreConfig.icon_url = JsonHelper.getString(jsonObject, "icon_url");
            multiStoreConfig.is_default = JsonHelper.getBool(jsonObject, "is_default");
            multiStoreConfig.is_active = JsonHelper.getBool(jsonObject, "is_active");

            if (jsonObject.has("location")) {
                JSONObject locationJsonObject = jsonObject.getJSONObject("location");
                multiStoreConfig.strLatitude = JsonHelper.getString(locationJsonObject, "latitude");
                multiStoreConfig.strLongitude = JsonHelper.getString(locationJsonObject, "longitude");
                multiStoreConfig.latitude = Double.parseDouble(JsonHelper.getString(locationJsonObject, "latitude"));
                multiStoreConfig.longitude = Double.parseDouble(JsonHelper.getString(locationJsonObject, "longitude"));
            }

            if (parseObject.has("map_menu_options") && ListUtils.isEmpty(mapMenuOptions)) {
                try {
                    mapMenuOptions = new ArrayList<>();
                    JSONArray array = new JSONArray(parseObject.getString("map_menu_options"));
                    for (int i = 0; i < array.length(); i++) {
                        JSONObject object = array.getJSONObject(i);
                        MapMenuOption mapMenuOption = new MapMenuOption();
                        mapMenuOption.title = object.getString("title");
                        mapMenuOption.url = object.getString("url");
                        mapMenuOptions.add(mapMenuOption);
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                    mapMenuOptions = null;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        boolean contains = false;
        for (MultiStoreConfig config : multiStoreConfigs) {
            if (config.platform.equals(multiStoreConfig.platform) && config.platform.equals(multiStoreConfig.platform)) {
                contains = true;
                break;
            }
        }

        if (isNearby) {
            nearByStoreConfigs.add(multiStoreConfig);
        } else if (!contains) {
            multiStoreConfigs.add(multiStoreConfig);
        }
        return multiStoreConfig;
    }

    public static boolean isEmpty() {
        return multiStoreConfigs.size() == 0;
    }

    public static MultiStoreConfig findByPlatform(String platform) {
        for (MultiStoreConfig multiStoreConfig : multiStoreConfigs) {
            if (multiStoreConfig.isEnabled() && multiStoreConfig.getPlatform().equals(platform))
                return multiStoreConfig;
        }
        return null;
    }

    public String getPlatform() {
        return platform;
    }

    public boolean isEnabled() {
        return enabled;
    }

    public void setEnabled(boolean enabled) {
        this.enabled = enabled;
    }

    public boolean isDefault() {
        return is_default;
    }

    public void setDefault(boolean isDefault) {
        this.is_default = isDefault;
    }

    public boolean isActive() {
        return is_active;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getIcon_url() {
        return icon_url;
    }

    public String getLatitudeString() {
        return strLatitude;
    }

    public String getLongitudeString() {
        return strLongitude;
    }

    public double getLatitude() {
        return latitude;
    }

    public double getLongitude() {
        return longitude;
    }

    @Override
    public String toString() {
        return "MultiStoreConfig{" +
                "enabled=" + enabled +
                ", is_default=" + is_default +
                ", title='" + title + '\'' +
                ", description='" + description + '\'' +
                ", icon_url='" + icon_url + '\'' +
                ", latitude='" + latitude + '\'' +
                ", longitude='" + longitude + '\'' +
                ", platform='" + platform + '\'' +
                '}';
    }

    public boolean hasKeyWord(String tag) {
        if (this.title != null && this.title.toLowerCase().contains(tag))
            return true;
        if (this.description != null && this.description.toLowerCase().contains(tag))
            return true;
        return false;
    }

    public boolean hasKeyWords(String[] keywords) {
        for (String keyword : keywords) {
            if (!hasKeyWord(keyword)) {
                return false;
            }
        }
        return true;
    }

    public static class MapMenuOption {
        public String title;
        public String url;
    }
}
