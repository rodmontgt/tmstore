package com.utils;

import android.text.TextUtils;
import android.util.Base64;

import com.twist.dataengine.DataEngine;
import com.twist.dataengine.entities.Slugify;
import com.twist.dataengine.entities.TM_CommonInfo;
import com.twist.dataengine.entities.TM_Order;
import com.twist.dataengine.entities.TM_Response;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.text.DecimalFormat;
import java.text.Normalizer;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.regex.Pattern;

import com.twist.oauth.NetworkUtils;

/**
 * Created by Twist Mobile on 12/30/2015.
 */
public class DataHelper {
    private static final Pattern NONLATIN1 = Pattern.compile("[^\\w-]");
    private static final Pattern WHITESPACE1 = Pattern.compile("[\\s]");
    private static final Slugify slg = new Slugify();

    public static String toSlug(String input) {
        String nowhitespace = WHITESPACE1.matcher(input).replaceAll("-");
        String normalized = Normalizer.normalize(nowhitespace, Normalizer.Form.NFD);
        String slug = NONLATIN1.matcher(normalized).replaceAll("");
        return slug.toLowerCase(Locale.ENGLISH);
    }

    public static String appendCurrency(float amount) {
        StringBuilder precisions = new StringBuilder(".");
        for (int i = 0; i < TM_CommonInfo.price_num_decimals; i++) {
            precisions.append("0");
        }
        DecimalFormat formatter = new DecimalFormat("###,###" + precisions);
        String str = formatter.format(amount);
        str = str.replaceAll(",", TM_CommonInfo.thousand_separator);
        return appendCurrency(str);
    }


    public static String appendCurrency(String amount) {
        if (TM_CommonInfo.currency_position.equalsIgnoreCase("left")) {
            return TM_CommonInfo.currency_format + amount;
        } else if (TM_CommonInfo.currency_position.equalsIgnoreCase("left_space")) {
            return TM_CommonInfo.currency_format + " " + amount;
        } else if (TM_CommonInfo.currency_position.equalsIgnoreCase("right")) {
            return amount + TM_CommonInfo.currency_format;
        } else if (TM_CommonInfo.currency_position.equalsIgnoreCase("right_space")) {
            return amount + " " + TM_CommonInfo.currency_format;
        } else {
            return amount + TM_CommonInfo.currency_format;
        }
    }

    public static float safeFloatPrice(String input) {
        if (input != null && input.length() > 0) {
            try {
                return Float.parseFloat(input);
            } catch (Exception ignored) {
                if (input.contains(","))
                    input = input.replace(",", ".");
                try {
                    return Float.parseFloat(input);
                } catch (Exception e) {
                }
            }
        }
        return 0.0f;
    }

    public static float safeFloat(String input) {
        try {
            return Float.parseFloat(input);
        } catch (Exception ignored) {
            return 0.0f;
        }
    }

    public static String safeString(JSONObject object, String key) {
        return safeString(object, key, "");
    }

    public static String safeString(JSONObject object, String key, String defaultStr) {
        try {
            if (!object.has(key))
                return defaultStr;
            String str = object.getString(key);
            if (str == null || str.equals("") || str.equals("null")) {
                str = defaultStr;
            }
            return str;
        } catch (Exception ignored) {
            return defaultStr;
        }
    }

    public static int safeInt(String value) {
        try {
            return Integer.parseInt(value);
        } catch (Exception ignored) {
            return 0;
        }
    }

    public static int safeInt(JSONObject object, String key, int defaultVal) {
        if (object.has(key)) {
            try {
                Object val = object.get(key);
                if (val instanceof Integer) {
                    return (Integer) val;
                } else {
                    return Integer.parseInt(val.toString());
                }
            } catch (Exception ignored) {
            }
        }
        return defaultVal;
    }

    public static int safeIntWithCeil(JSONObject object, String key, int defaultVal) {
        if (!object.has(key)) {
            return defaultVal;
        }

        try {
            Object val = object.get(key);
            if (val instanceof Integer) {
                return (Integer) val;
            } else if (val instanceof Double) {
                return (int) Math.ceil((double) val);
            } else if (val instanceof String) {
                return (int) Math.ceil(Double.parseDouble(val.toString()));
            }
        } catch (Exception ignored) {
            //ignored.printStackTrace();
        }
        return defaultVal;
    }


    public static int safeIntOrString(JSONObject object, String key, int defaultVal) {
        if (!object.has(key))
            return defaultVal;

        try {
            return object.getInt(key);
        } catch (JSONException ignored) {
            try {
                return Integer.parseInt(object.getString(key));
            } catch (Exception ignoredAgain) {
                return defaultVal;
            }
        } catch (Exception ignored) {
            return defaultVal;
        }
    }

    public static boolean safeBool(String input) {
        try {
            return Boolean.parseBoolean(input);
        } catch (Exception ignored) {
            return false;
        }
    }

    public static JSONObject safeJsonObject(String json) throws JSONException {
        if (!json.contains("{") || !json.contains("}"))
            throw new JSONException("Invalid response.");
        return new JSONObject(json.substring(json.indexOf("{"), json.lastIndexOf("}") + 1));
    }

    public static JSONObject safeJsonObject(String json, String objectName) throws JSONException {
        // Returns safe JSON object when response contains multiple JSON objects with HTML, CSS & JS
        if (!json.contains("{") || !json.contains("}"))
            throw new JSONException("Invalid response.");

        int start = json.indexOf("{\"" + objectName + "\"");
        if (start < 0)
            throw new JSONException("Invalid response.");

        return new JSONObject(json.substring(start, json.lastIndexOf("}") + 1));
    }

    public static JSONArray safeJsonArray(String json) throws JSONException {
        if (!json.contains("[") || !json.contains("]"))
            throw new JSONException("Invalid response.");
        return new JSONArray(json.substring(json.indexOf("["), json.lastIndexOf("]") + 1));
    }

    public static boolean compareAttributeStrings(String name1, String name2) {
        if (name1 == null || name2 == null)
            return false;

        if (name1.equalsIgnoreCase(name2))
            return true;

        String tempName1 = slg.slugify(name1).replaceAll("-", "");
        String tempName2 = slg.slugify(name2).replaceAll("-", "");

        if (TextUtils.isEmpty(tempName1)) {
            tempName1 = name1;
        }

        if (TextUtils.isEmpty(tempName2)) {
            tempName2 = name2;
        }

        if (tempName1.equals(tempName2))
            return true;

        String nameToCompare1 = name1.toLowerCase();
        String nameToCompare2 = name2.toLowerCase();
        if (nameToCompare1.startsWith("pa_")) {
            nameToCompare1 = nameToCompare1.substring(3, nameToCompare1.length());
        }
        if (nameToCompare2.startsWith("pa_")) {
            nameToCompare2 = nameToCompare2.substring(3, nameToCompare2.length());
        }

        if (nameToCompare1.equals(nameToCompare2))
            return true;

        if (normalizationRequired(nameToCompare1)) {
            nameToCompare1 = normalizePercentages(nameToCompare1);
        }

        if (normalizationRequired(nameToCompare2)) {
            nameToCompare2 = normalizePercentages(nameToCompare2);
        }

        if (nameToCompare1.equals(nameToCompare2))
            return true;

        nameToCompare1 = nameToCompare1.replaceAll("\\s+", "");
        nameToCompare2 = nameToCompare2.replaceAll("\\s+", "");
        nameToCompare1 = nameToCompare1.replaceAll("-", "");
        nameToCompare2 = nameToCompare2.replaceAll("-", "");
        nameToCompare1 = nameToCompare1.replaceAll("_", "");
        nameToCompare2 = nameToCompare2.replaceAll("_", "");
        nameToCompare1 = nameToCompare1.replaceAll("\"", "");
        nameToCompare2 = nameToCompare2.replaceAll("\"", "");

        return nameToCompare1.equals(nameToCompare2);
    }

    public static boolean normalizationRequired(String string) {
        return (string != null && string.split("%").length > 3);
    }

    public static String normalizePercentages(String string) {
        try {
            string = java.net.URLDecoder.decode(string, "UTF-8");
        } catch (Exception e) {
            e.printStackTrace();
        }
        return string;
    }

    public static String encrypt(final String data) {
        return Base64.encodeToString(data.getBytes(), Base64.NO_WRAP);
    }

    public static String encrypt(final int data) {
        return Base64.encodeToString(String.valueOf(data).getBytes(), Base64.NO_WRAP);
    }

    public static Map<String, String> encrypt(Map<String, String> params) {
        for (Map.Entry<String, String> param : params.entrySet()) {
            param.setValue(encrypt(param.getValue()));
        }
        return params;
    }

    public static String getExtension(String fileName) {
        int index = fileName.lastIndexOf('.');
        return  index > 0 ? fileName.substring(index) : "";
    }

    public static String getResizedImageUrl(String src_url) {
        String dst_url = src_url;
        if(src_url.contains("-150x150") && !src_url.contains("resize=")) {
            dst_url = src_url.split("-150x150")[0];
            dst_url += DataHelper.getExtension(src_url);
            dst_url += "?fit=500%2C500";
            DataHelper.log("ResizedImage : " + dst_url);
        }
        return dst_url;
    }

    public static String getScaledImageUrl(String src_url) {
        String dst_url = DataHelper.getResizedImageUrl(src_url);
        // if url is not changed
        if (dst_url.equals(src_url)) {
            dst_url = DataHelper.resizeProductImage(src_url);
        }
        return dst_url;
    }

    public static String getScaledThumbnailUrl(String img_url) {
        final String keyword = "-150x150";
        if (img_url.contains(keyword) && !img_url.contains("resize=")) {
            String ext = DataHelper.getExtension(img_url);
            img_url = img_url.split(keyword)[0] + ext + "?fit=180%2C180";
        } else if (DataEngine.resize_product_thumbs && !TextUtils.isEmpty(img_url)) {
            String[] tokens = img_url.split("-");
            if (tokens.length > 1) {
                String token = tokens[tokens.length - 1];
                if (token.contains("x") && !token.contains("?fit=")) {
                    String ext = DataHelper.getExtension(token);
                    if (ext.length() != 0) {
                        // Aspect ratio will be applied using images default width and height.
                        img_url = img_url.replace("-" + token, ext + "?fit=512x512");
                        DataHelper.log("ResizedImage : " + img_url);
                    }
                }
            }
        }
        return img_url;
    }

    private static String resizeProductImage(String img_url) {
        if (DataEngine.resize_product_images && !TextUtils.isEmpty(img_url)) {
            try {
                String[] tokens = img_url.split("-");
                if (tokens.length > 1) {
                    String token = tokens[tokens.length - 1];
                    if (token.contains("x") && !token.contains("?fit=")) {
                        String ext = DataHelper.getExtension(token);
                        if (ext.length() != 0) {
                            // Aspect ratio will be applied using images default width and height.
                            img_url = img_url.replace("-" + token, ext + "?fit=512x512");
                            DataHelper.log("ResizedImage : " + img_url);
                        }
                    }
                }
            } catch (Exception ignored) {
            }
        }
        return img_url;
    }

    public static void log(String str) {
        if (DataEngine.isLogEnabled()) {
            android.util.Log.d("DataEngine", str);
        }
        NetworkUtils.appendBuffer(str);
    }

    public static String join(String separator, int[] values) {
        String result = "";
        for (int i = 0; i < values.length; i++) {
            result += values[i];
            if (i < values.length - 1) {
                result += separator;
            }
        }
        return result;
    }

    public static String join(String separator, List<Integer> values) {
        StringBuilder result = new StringBuilder();
        result.append("[");
        final int size = values.size();
        for (int i = 0; i < size; i++) {
            result.append("\"");
            result.append(values.get(i));
            result.append("\"");
            if (i < size - 1) {
                result.append(separator);
            }
        }
        result.append("]");
        return result.toString();
    }

    public static String getOrderIdJSONString(List<TM_Order> orderList) {
        StringBuilder result = new StringBuilder();
        result.append("[");
        int size = orderList.size();
        for (int i = 0; i < size; i++) {
            result.append("\"");
            result.append(orderList.get(i).id);
            result.append("\"");
            if (i < size - 1) {
                result.append(",");
            }
        }
        result.append("]");
        return result.toString();
    }

    public static String[] getStringArray(JSONObject object, String key) throws JSONException {
        if (object != null && object.has(key)) {
            JSONArray jsonArray = object.getJSONArray(key);
            String array[] = new String[jsonArray.length()];
            for (int i = 0; i < array.length; i++) {
                array[i] = jsonArray.getString(i);
            }
            return array;
        }
        return null;
    }

    public static String replaceNewLines(String str) {
        if (str != null && str.contains("\r\n")) {
            str = str.trim().replaceAll("\r\n", "<br/>");
        }

        if (str != null && str.contains("\n")) {
            str = str.replaceAll("\n", "");
        }
        return str;
    }

    public static TM_Response parseJsonAndCreateTMResponse(String jsonStringContent) {
        DataHelper.log("-- parseJsonAndCreateTMResponse:[" + jsonStringContent + "] --");
        TM_Response tmResponse = new TM_Response();
        JSONObject jMainObject = null;
        try {
            jMainObject = DataHelper.safeJsonObject(jsonStringContent);
            tmResponse.status = jMainObject.getString("status").equalsIgnoreCase("success");
            tmResponse.error = jMainObject.get("error").toString();
            tmResponse.message = jMainObject.getString("message");
        } catch (JSONException je) {
            je.printStackTrace();
        }
        return tmResponse;
    }
}
