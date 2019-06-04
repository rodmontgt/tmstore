package com.twist.dataengine.entities;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Twist Mobile on 25-Jul-16.
 */

public class TM_WishList {

    private static String id = "";

    private static String url = "";

    private static String token = "";

    private int productId;
    private int quantity;

    private static List<TM_WishList> wishLists = new ArrayList<>();

    private TM_WishList() {
        wishLists.add(this);
    }

    private TM_WishList(int productId) {
        this();
        this.productId = productId;
    }

    public static TM_WishList create(int productId) {
        if (wishLists != null) {
            for (TM_WishList item : wishLists) {
                if (item.productId == productId) {
                    return item;
                }
            }
        }
        return new TM_WishList(productId);
    }

    public static String getId() {
        return id;
    }

    public static void setId(String id) {
        TM_WishList.id = id;
    }

    public static String getUrl() {
        return url;
    }

    public static void setUrl(String url) {
        TM_WishList.url = url;
    }

    public static String getToken() {
        return token;
    }

    public static void setToken(String token) {
        TM_WishList.token = token;
    }

    public int getProductId() {
        return productId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public static String getSharableUrl() {
        return url + token;
    }

    public static List<TM_WishList> getAll() {
        return wishLists;
    }

    public static void clearAll() {
        if(wishLists != null) {
            wishLists.clear();
        }
    }
}
