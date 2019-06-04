package com.twist.tmstore.entities;

import com.twist.dataengine.entities.TM_ProductInfo;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Created by Twist Mobile on 12-Oct-16.
 */

public class CartMatchedItem {
    private int productId;
    private String title;
    private double basePrice;
    private String imageUrl;
    private int quantity;

    public int getProductId() {
        return productId;
    }

    public String getTitle() {
        return title;
    }

    public double getBasePrice() {
        return basePrice;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public void setBasePrice(double basePrice) {
        this.basePrice = basePrice;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public static String encodeToString(Map<TM_ProductInfo, Integer> matchedItems) {
        String str = "";
        if (matchedItems != null) {
            try {
                JSONArray jsonArray = new JSONArray();
                for (Map.Entry<TM_ProductInfo, Integer> entry : matchedItems.entrySet()) {
                    TM_ProductInfo product = entry.getKey();
                    int quantity = entry.getValue();
                    JSONObject jsonObject = new JSONObject();
                    jsonObject.put("product_id", product.id);
                    jsonObject.put("title", product.title);
                    jsonObject.put("base_price", product.price);
                    jsonObject.put("image_url", product.getFirstImageUrl());
                    jsonObject.put("quantity", quantity);
                    jsonArray.put(jsonObject);
                }
                str = jsonArray.toString();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return str;
    }

    public static List<CartMatchedItem> decodeString(String str) {
        List<CartMatchedItem> list = null;
        if (str != null && str.length() > 0 && !str.equalsIgnoreCase("null")) {
            try {
                JSONArray jsonArray = new JSONArray(str);
                list = new ArrayList<>();
                for (int i = 0; i < jsonArray.length(); i++) {
                    JSONObject jsonObject = jsonArray.getJSONObject(i);
                    CartMatchedItem item = new CartMatchedItem();
                    item.productId = jsonObject.getInt("product_id");
                    item.title = jsonObject.getString("title");
                    item.basePrice = jsonObject.getDouble("base_price");
                    item.imageUrl = jsonObject.getString("image_url");
                    item.quantity = jsonObject.getInt("quantity");
                    list.add(item);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return list;
    }
}