package com.twist.tmstore.entities;

import com.twist.dataengine.entities.TM_VariationAttribute;
import com.utils.DataHelper;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class CartVariation {

    //} extends TypeSerializer {

    //private List<TM_VariationAttribute> attributes;

//    public CartVariation(List<TM_VariationAttribute> attributes) {
//        this.attributes = attributes;
//    }

    public static String encodeToString(List<TM_VariationAttribute> attributes) {
        if (attributes == null || attributes.isEmpty()) {
            return "";
        }
        try {
            JSONArray jsonArray = new JSONArray();
            for (TM_VariationAttribute attribute : attributes) {
                JSONObject jsonObject = new JSONObject();
                jsonObject.put("name", attribute.name);
                jsonObject.put("slug", attribute.slug);
                jsonObject.put("value", attribute.value);
                jsonObject.put("extraPrice", attribute.extraPrice);
                jsonArray.put(jsonObject);
            }
            return jsonArray.toString();
        } catch (Exception e) {
            e.printStackTrace();
            return "";
        }
    }

    public static List<TM_VariationAttribute> decodeString(String str) {
        List<TM_VariationAttribute> attributes = new ArrayList<>();
        if (str != null && str.length() > 0 && !str.equalsIgnoreCase("null")) {
            try {
                JSONArray jsonArray = new JSONArray(str);
                for (int i = 0; i < jsonArray.length(); i++) {
                    JSONObject jsonObject = jsonArray.getJSONObject(i);
                    TM_VariationAttribute attribute = new TM_VariationAttribute(UUID.randomUUID().toString());
                    attribute.name = jsonObject.getString("name");
                    attribute.slug = jsonObject.getString("slug");
                    attribute.value = jsonObject.getString("value");
                    if (jsonObject.has("extraPrice")) {
                        attribute.extraPrice = (float) jsonObject.getDouble("extraPrice");
                    } else {
                        attribute.extraPrice = 0;
                    }
                    attributes.add(attribute);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return attributes;
    }

//    public static String getAttributeString(List<TM_VariationAttribute> attributes) {
//        String str = "";
//        for (TM_VariationAttribute attribute : attributes) {
//            String attributeName = attribute.name;
//            String attributeValue = attribute.value;
//            if (DataHelper.normalizationRequired(attributeName))
//                attributeName = DataHelper.normalizePercentages(attributeName);
//            if (DataHelper.normalizationRequired(attributeValue))
//                attributeValue = DataHelper.normalizePercentages(attributeValue);
//            str += attributeName + " : <strong>" + attributeValue + "</strong> | ";
//        }
//        if (str.length() > 3) {
//            str = str.substring(0, str.length() - 3);
//        }
//        return str;
//    }

    public static List<String> getAttributeStringList(List<TM_VariationAttribute> attributes) {
        List<String> selected_attributes_array = new ArrayList<>();
        for (TM_VariationAttribute attribute : attributes) {
            String attributeName = attribute.name;
            String attributeValue = attribute.value;
            if (DataHelper.normalizationRequired(attributeName))
                attributeName = DataHelper.normalizePercentages(attributeName);
            if (DataHelper.normalizationRequired(attributeValue))
                attributeValue = DataHelper.normalizePercentages(attributeValue);
            selected_attributes_array.add(attributeName + " : <strong>" + attributeValue + "</strong>");
        }
        return selected_attributes_array;
    }
}