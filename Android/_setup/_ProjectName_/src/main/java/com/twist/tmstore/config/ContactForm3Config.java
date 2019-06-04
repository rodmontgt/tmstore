package com.twist.tmstore.config;

import com.utils.JsonHelper;

import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

/**
 * Created by Twist Mobile on 20-04-2017.
 */

public class ContactForm3Config {

    public boolean enabled = false;

    private String title;

    public static ContactForm3Config mContactForm3Config;

    public static class ContactForm3 {
        public String label;
        public String shortcode;
        public String type;
        public String options[];
        public String submit_mess;
    }
    public Map<String, ContactForm3Config.ContactForm3> contactForm3Map= new HashMap<>();

    public ContactForm3Config() {
    }

    public static void createConfig(JSONObject jsonObject) {
        try {
            mContactForm3Config = new ContactForm3Config();
            mContactForm3Config.enabled = JsonHelper.getBool(jsonObject, "enabled", mContactForm3Config.enabled);
            mContactForm3Config.title = JsonHelper.getString(jsonObject, "title");
        } catch (Exception e) {
            e.printStackTrace();
            mContactForm3Config = null;
        }
    }

    public static void resetConfig() {
        mContactForm3Config = null;
    }

    public static boolean isEnabled() {
        return mContactForm3Config != null && mContactForm3Config.enabled;
    }
}