package com.twist.tmstore.config;

import com.utils.JsonHelper;

import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

/**
 * Created by Twist Mobile on 20-04-2017.
 */

public class ReservationFormConfig {

    public boolean enabled = false;

    private String title;

    public static ReservationFormConfig mReservationFormConfig;

    public static class ReservationForm {
        public String label;
        public String shortcode;
        public String type;
        public String options[];
        public String submit_mess;
    }

    public Map<String, ReservationFormConfig.ReservationForm> reservationFormMap = new HashMap<>();

    public ReservationFormConfig() {
    }

    public static void createConfig(JSONObject jsonObject) {
        try {
            mReservationFormConfig = new ReservationFormConfig();
            mReservationFormConfig.enabled = JsonHelper.getBool(jsonObject, "enabled", mReservationFormConfig.enabled);
            mReservationFormConfig.title = JsonHelper.getString(jsonObject, "title");
        } catch (Exception e) {
            e.printStackTrace();
            mReservationFormConfig = null;
        }
    }

    public static void resetConfig() {
        mReservationFormConfig = null;
    }

    public static boolean isEnabled() {
        return mReservationFormConfig != null && mReservationFormConfig.enabled;
    }
}
