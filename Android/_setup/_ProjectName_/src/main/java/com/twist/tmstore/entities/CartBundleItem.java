package com.twist.tmstore.entities;

import com.twist.dataengine.entities.TM_Bundle;
import com.twist.dataengine.entities.TM_ProductInfo;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Twist Mobile on 12-Oct-16.
 */

public class CartBundleItem {
    private int productId;
    private String title;
    private String imageUrl;
    private int quantity;

    public static String encodeToString(List<TM_Bundle> bundles) {
        String str = "";
        if (bundles != null && !bundles.isEmpty()) {
            try {
                JSONArray jsonArray = new JSONArray();
                for (TM_Bundle bundle : bundles) {
                    TM_ProductInfo product = bundle.getProduct();
                    JSONObject jsonObject = new JSONObject();
                    jsonObject.put("product_id", product.id);
                    jsonObject.put("title", product.title);
                    jsonObject.put("image_url", product.getFirstImageUrl());
                    jsonObject.put("quantity", bundle.getBundleQuantity());
                    jsonArray.put(jsonObject);
                }
                str = jsonArray.toString();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return str;
    }

    public static List<CartBundleItem> decodeString(String str) {
        List<CartBundleItem> list = null;
        if (str != null && str.length() > 0 && !str.equalsIgnoreCase("null")) {
            try {
                JSONArray jsonArray = new JSONArray(str);
                list = new ArrayList<>();
                for (int i = 0; i < jsonArray.length(); i++) {
                    JSONObject jsonObject = jsonArray.getJSONObject(i);
                    CartBundleItem item = new CartBundleItem();
                    item.productId = jsonObject.getInt("product_id");
                    item.title = jsonObject.getString("title");
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

    public int getProductId() {
        return productId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public JSONObject toJSONObject() throws JSONException {
        JSONObject jsonObject = new JSONObject();
        jsonObject.put("product_id", this.getProductId());
        jsonObject.put("title", this.getTitle());
        jsonObject.put("image_url", this.getImageUrl());
        jsonObject.put("quantity", this.getQuantity());
        return jsonObject;
    }
}