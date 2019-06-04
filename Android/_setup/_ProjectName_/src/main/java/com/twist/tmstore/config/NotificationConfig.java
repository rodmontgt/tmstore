package com.twist.tmstore.config;

import com.utils.JsonHelper;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Twist Mobile on 08-Oct-16.
 */

public class NotificationConfig {
    private static NotificationConfig mNotificationConfig;

    public enum Type {
        PARSE,  // Parse Push Notifications
        FCM;    // Firebase Cloud Messaging

        public static Type fromName(String name) {
            for (Type type : values()) {
                if (type.name().equalsIgnoreCase(name)) {
                    return type;
                }
            }
            return Type.PARSE;
        }
    }

    public static class Channel {
        public String id;
        public String name;
        public boolean setting;
        public boolean subscribe;

        public Channel() {
            this.id = "";
            this.name = "";
            this.setting = false;
            this.subscribe = false;
        }
    }

    private boolean enabled;

    private boolean settings;

    private Type type;

    private List<Channel> channels;

    public NotificationConfig() {
        enabled = false;
        type = Type.PARSE;
        channels = new ArrayList<>();
        settings = false;
    }

    public static void createConfig(JSONObject mainObject) {
        if(!mainObject.has("notifications")) {
            mNotificationConfig = null;
            return;
        }
        NotificationConfig notificationConfig;
        try {
            JSONObject jsonObject = mainObject.getJSONObject("notifications");
            notificationConfig = new NotificationConfig();
            notificationConfig.enabled = jsonObject.getBoolean("enabled");
            if (notificationConfig.enabled) {
                notificationConfig.type = Type.fromName(jsonObject.getString("type"));
                notificationConfig.settings = JsonHelper.getBool(jsonObject, "settings", false);
                if (jsonObject.has("channels")) {
                    JSONArray channelsJsonArray = jsonObject.getJSONArray("channels");
                    for (int i = 0; i < channelsJsonArray.length(); i++) {
                        JSONObject channelsJsonObject = channelsJsonArray.getJSONObject(i);
                        Channel channel = new Channel();
                        channel.id = channelsJsonObject.getString("id");
                        channel.name = channelsJsonObject.getString("name");
                        channel.setting = JsonHelper.getBool(channelsJsonObject, "setting", false);
                        channel.subscribe = JsonHelper.getBool(channelsJsonObject, "subscribe", false);
                        notificationConfig.addChannel(channel);
                    }
                }
            }
        } catch (JSONException e) {
            e.printStackTrace();
            notificationConfig = null;
        }
        mNotificationConfig = notificationConfig;
    }

    public static Type getType() {
        return mNotificationConfig != null ? mNotificationConfig.type : null;
    }

    public static List<Channel> getChannels() {
        return mNotificationConfig != null ? mNotificationConfig.channels : null;
    }

    public static boolean hasSettings() {
        return mNotificationConfig != null && mNotificationConfig.enabled && mNotificationConfig.settings;
    }

    public static boolean isEnabled() {
        return (mNotificationConfig != null && mNotificationConfig.enabled);
    }

    private void addChannel(Channel channel) {
        if (channels == null) {
            channels = new ArrayList<>();
        }
        channels.add(channel);
    }

    public static boolean containsChannelId(String id) {
        List<NotificationConfig.Channel> channels = NotificationConfig.getChannels();
        if (channels != null && id != null) {
            for (Channel channel : channels) {
                if (channel.id.contains(id)) {
                    return true;
                }
            }
        }
        return false;
    }

    public static boolean containsChannels(String[] ids) {
        for (String id : ids) {
            if (!containsChannelId(id)) {
                return false;
            }
        }
        return true;
    }
}
