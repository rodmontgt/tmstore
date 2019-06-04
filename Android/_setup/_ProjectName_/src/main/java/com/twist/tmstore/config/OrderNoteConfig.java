package com.twist.tmstore.config;

import com.twist.tmstore.entities.AppInfo;
import com.utils.JsonHelper;

import org.json.JSONObject;

public class OrderNoteConfig {

    private boolean enabled = false;
    private String char_type = "";
    private int char_limit = 256;
    private int line_count = 3;

    public int getLocation() {
        return location;
    }

    public void setLocation(int location) {
        this.location = location;
    }

    private int location = 0;
    private boolean single_line = false;

    public OrderNoteConfig() {
    }

    public int getLineCount() {
        return line_count;
    }

    public void setLineCount(int line_count) {
        this.line_count = line_count;
    }

    public boolean isSingleLine() {
        return single_line;
    }

    public void setSingleLine(boolean single_line) {
        this.single_line = single_line;
    }

    public boolean isEnabled() {
        return enabled;
    }

    public void setEnabled(boolean enabled) {
        this.enabled = enabled;
    }

    public String getCharType() {
        return char_type;
    }

    public void setCharType(String char_type) {
        this.char_type = char_type;
    }

    public int getCharLimit() {
        return char_limit;
    }

    public void setCharLimit(int char_limit) {
        this.char_limit = char_limit;
    }

    public static void createConfig(JSONObject jsonObject) {
        AppInfo.mOrderNoteConfig = null;
        if (jsonObject.has("order_note")) {
            try {
                JSONObject obj = jsonObject.getJSONObject("order_note");
                OrderNoteConfig orderNoteConfig = new OrderNoteConfig();
                orderNoteConfig.setEnabled(JsonHelper.getBool(obj, "enabled", orderNoteConfig.enabled));
                orderNoteConfig.setSingleLine(JsonHelper.getBool(obj, "single_line", orderNoteConfig.single_line));
                orderNoteConfig.setCharLimit(JsonHelper.getInt(obj, "char_limit", orderNoteConfig.char_limit));
                orderNoteConfig.setLineCount(JsonHelper.getInt(obj, "line_count", orderNoteConfig.line_count));
                orderNoteConfig.setLocation(JsonHelper.getInt(obj, "location", orderNoteConfig.location));
                orderNoteConfig.setCharType(JsonHelper.getString(obj, "char_type", orderNoteConfig.char_type));
                AppInfo.mOrderNoteConfig = orderNoteConfig;
            } catch (Exception e) {
                e.printStackTrace();
                AppInfo.mOrderNoteConfig = null;
            }
        }
    }
}
