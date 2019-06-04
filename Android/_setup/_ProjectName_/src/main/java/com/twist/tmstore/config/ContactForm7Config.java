package com.twist.tmstore.config;

import com.twist.tmstore.L;
import com.utils.JsonHelper;

import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

public class ContactForm7Config {
    private String bg_url;

    private boolean enabled = false;

    private List<TextField> textFields = new ArrayList<>();

    private String title;

    private String submitUrl;

    private static ContactForm7Config mContactForm7Config;

    public static String getBgUrl() {
        return mContactForm7Config.bg_url;
    }

    public void setBgUrl(String bg_url) {
        this.bg_url = bg_url;
    }

    public static class TextField {
        private boolean enabled = false;
        private int line_count;
        private String hint_text;
        private String char_type;
        private boolean compulsory;
        private boolean single_line;
        private int char_limit;
        private String param_name;

        public String getParamName() {
            return param_name;
        }

        public void setParamName(String param_name) {
            this.param_name = param_name;
        }

        public int getCharLimit() {
            return char_limit;
        }

        public void setCharLimit(int char_limit) {
            this.char_limit = char_limit;
        }

        public boolean isSingleLine() {
            return single_line;
        }

        public boolean isCompulsory() {
            return compulsory;
        }

        public boolean getEnabled() {
            return enabled;
        }

        public void setEnabled(boolean enabled) {
            this.enabled = enabled;
        }

        public int getLineCount() {
            return line_count;
        }

        public void setLineCount(int line_count) {
            this.line_count = line_count;
        }

        public String getHintText() {
            return hint_text;
        }

        public void setHintText(String hint_text) {
            this.hint_text = hint_text;
        }

        public String getCharType() {
            return char_type;
        }

        public void setCharType(String char_type) {
            this.char_type = char_type;
        }

        public boolean getCompulsory() {
            return compulsory;
        }

        public void setCompulsory(boolean compulsory) {
            this.compulsory = compulsory;
        }

        public boolean getSingleLine() {
            return single_line;
        }

        public void setSingleLine(boolean single_line) {
            this.single_line = single_line;
        }

    }

    public static void createConfig(JSONObject jsonObject) {
        try {
            mContactForm7Config = new ContactForm7Config();
            mContactForm7Config.enabled = JsonHelper.getBool(jsonObject, "enabled", mContactForm7Config.enabled);
            mContactForm7Config.setTitle(JsonHelper.getString(jsonObject, "app_title", L.getString(L.string.send_quote)));
            mContactForm7Config.submitUrl = JsonHelper.getString(jsonObject, "submit_url", null);
            mContactForm7Config.setBgUrl(JsonHelper.getString(jsonObject, "bg_url", null));
        } catch (Exception e) {
            e.printStackTrace();
            mContactForm7Config = null;
        }
    }

    public static void resetConfig() {
        mContactForm7Config = null;
    }

    public static void addTextField(TextField textField) {
        if (mContactForm7Config != null)
            mContactForm7Config.textFields.add(textField);
    }

    public static String getTitle() {
        return mContactForm7Config.title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public static String getSubmitUrl() {
        return mContactForm7Config.submitUrl;
    }

    public static void setSubmitUrl(String submitUrl) {
        mContactForm7Config.submitUrl = submitUrl;
    }

    public static List<TextField> getTextFields() {
        return mContactForm7Config.textFields;
    }

    public static boolean isEnabled() {
        return mContactForm7Config != null && mContactForm7Config.enabled;
    }

}
