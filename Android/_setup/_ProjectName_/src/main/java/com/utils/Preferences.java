package com.utils;

import android.content.Context;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;
import android.support.v4.content.ContextCompat;

import java.util.HashMap;
import java.util.Map;

/**
 * Created by Twist Mobile on 26-05-2017.
 */

public class Preferences {

    private static Context context;

    private static SharedPreferences mPreferences;

    public static void init(Context context) {
        Preferences.context = context;
        mPreferences = PreferenceManager.getDefaultSharedPreferences(context);
    }

    public static String getString(String key, String defValue) {
        return mPreferences.getString(key, defValue);
    }

    public static String getString(String key) {
        return Preferences.getString(key, "");
    }

    public static void putString(String key, String value) {
        mPreferences.edit().putString(key, value).apply();
    }

    public static String getString(int keyResId, String defaultValue) {
        return mPreferences.getString(context.getResources().getString(keyResId), defaultValue);
    }

    public static String getString(int keyResId, int defValueResId) {
        return Preferences.getString(keyResId, context.getResources().getString(defValueResId));
    }

    public static String getColorString(String key, int defaultColorResId) {
        int defaultColor = ContextCompat.getColor(context, defaultColorResId);
        String defValue = "#" + Integer.toHexString(defaultColor);
        return mPreferences.getString(key, defValue);
    }

    public static void putString(int keyResId, String value) {
        putString(context.getResources().getString(keyResId), value);
    }

    public static void putHashMap(HashMap<String, String> keyValuesMap) {
        SharedPreferences.Editor editor = mPreferences.edit();
        for(Map.Entry<String, String> entry : keyValuesMap.entrySet()) {
            editor.putString(entry.getKey(), entry.getValue());
        }
        editor.apply();
    }

    public static void putBool(int keyResId, boolean value) {
        mPreferences.edit().putBoolean(context.getResources().getString(keyResId), value).apply();
    }

    public static boolean getBool(int keyResId, boolean defaultValue) {
        return mPreferences.getBoolean(context.getResources().getString(keyResId), defaultValue);
    }
}
