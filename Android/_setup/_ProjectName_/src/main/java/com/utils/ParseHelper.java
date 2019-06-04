package com.utils;

import com.parse.ParseObject;

import org.json.JSONArray;
import org.json.JSONObject;

public class ParseHelper {

    public static String getString(ParseObject parseObject, String key, String defaultValue) {
        if (parseObject.containsKey(key)) {
            String value = parseObject.getString(key);
            if (value != null) {
                return value;
            }
        }
        return defaultValue;
    }

    public static boolean getBool(ParseObject parseObject, String key) {
        return parseObject.containsKey(key) && parseObject.getBoolean(key);
    }

    public static boolean getBool(ParseObject parseObject, String key, boolean defaultValue) {
        return parseObject.containsKey(key) ? parseObject.getBoolean(key) : defaultValue;
    }

    public static int getInt(ParseObject parseObject, String key) {
        return parseObject.containsKey(key) ? parseObject.getInt(key) : -1;
    }

    public static int getInt(ParseObject parseObject, String key, int defaultValue) {
        return parseObject.containsKey(key) ? parseObject.getInt(key) : defaultValue;
    }

    public static void printClass(ParseObject parseObject) {
        try {
            JSONArray jsonArray = new JSONArray();
            for (String key : parseObject.keySet()) {
                JSONObject object = new JSONObject();
                object.put("class", parseObject.get(key).getClass().getSimpleName());
                object.put("key", key);
                jsonArray.put(object);
            }
            Log.d(parseObject.getClassName() + " : " + jsonArray.toString());
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
