package com.twist.tmstore.config;

import com.twist.tmstore.entities.AppInfo;
import com.twist.tmstore.entities.AppUser;
import com.utils.JsonHelper;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Twist Mobile on 21-Jul-16.
 */

public class GuestUserConfig {

    public static boolean mEnableCart = true;
    public static boolean mPreventCart = false;
    public static boolean mEnabled = false;
    public static boolean mPreventMyOrders = false;
    public static boolean mPreventWishlist = false;
    public static boolean mPreventPriceTag = false;
    public static boolean mGuestCheckout = false;
    private static boolean mGuestContinue = false;

    private List<Integer> restrictedCategories = new ArrayList<>();

    public GuestUserConfig() {
    }

    public static boolean isEnableCart() {
        return AppInfo.mGuestUserConfig == null || !mEnabled || !AppUser.isAnonymous() || mEnableCart;
    }

    public void setEnableCart(boolean enableCart) {
        mEnableCart = enableCart;
    }

    public static boolean isGuestCheckout() {
        return AppInfo.mGuestUserConfig != null && GuestUserConfig.mGuestCheckout;
    }

    public void setGuestCheckout(boolean guestCheckout) {
        GuestUserConfig.mGuestCheckout = guestCheckout;
    }

    public static boolean hidePriceTag() {
        return AppInfo.mGuestUserConfig != null && AppInfo.mGuestUserConfig.isEnabled() && AppInfo.mGuestUserConfig.isPreventPriceTag() && AppUser.isAnonymous();
    }

    public static boolean isPreventMyOrders() {
        return mPreventMyOrders;
    }

    public void setPreventMyOrders(boolean mPreventMyOrders) {
        GuestUserConfig.mPreventMyOrders = mPreventMyOrders;
    }

    public static boolean isGuestContinue() {
        return mGuestContinue;
    }

    public static void createConfig(JSONObject jsonObject) {
        AppInfo.mGuestUserConfig = null;
        if (jsonObject.has("guest_config")) {
            try {
                JSONObject guestConfigObject = jsonObject.getJSONObject("guest_config");
                GuestUserConfig mGuestUserConfig = new GuestUserConfig();
                mGuestUserConfig.setEnabled(true);
                mGuestUserConfig.setEnableCart(JsonHelper.getBool(guestConfigObject, "enable_cart", GuestUserConfig.mEnableCart));
                mGuestUserConfig.setPreventCart(JsonHelper.getBool(guestConfigObject, "prevent_cart", GuestUserConfig.mPreventCart));
                mGuestUserConfig.setPreventWishlist(JsonHelper.getBool(guestConfigObject, "prevent_wishlist", GuestUserConfig.mPreventWishlist));
                mGuestUserConfig.setPreventPriceTag(JsonHelper.getBool(guestConfigObject, "hide_price", GuestUserConfig.mPreventPriceTag));
                mGuestUserConfig.setGuestCheckout(JsonHelper.getBool(guestConfigObject, "guest_checkout", GuestUserConfig.mGuestCheckout));
                mGuestUserConfig.setPreventMyOrders(JsonHelper.getBool(guestConfigObject, "prevent_myorder", GuestUserConfig.mPreventMyOrders));
                GuestUserConfig.mGuestContinue = JsonHelper.getBool(guestConfigObject, "guest_continue", GuestUserConfig.mGuestContinue);
                if (guestConfigObject.has("restricted_categories")) {
                    try {
                        JSONArray restricted_categories = guestConfigObject.getJSONArray("restricted_categories");
                        for (int i = 0; i < restricted_categories.length(); i++) {
                            mGuestUserConfig.restrictCategory(restricted_categories.getInt(i));
                        }
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                }
                AppInfo.mGuestUserConfig = mGuestUserConfig;
            } catch (Exception e) {
                e.printStackTrace();
                AppInfo.mGuestUserConfig = null;
            }
        }
    }

    public boolean isPreventCart() {
        return mPreventCart;
    }

    public void setPreventCart(boolean mPreventCart) {
        GuestUserConfig.mPreventCart = mPreventCart;
    }

    public boolean isPreventWishlist() {
        return mPreventWishlist;
    }

    public void setPreventWishlist(boolean mPreventWishlist) {
        GuestUserConfig.mPreventWishlist = mPreventWishlist;
    }

    public void restrictCategory(int categoryId) {
        restrictedCategories.add(categoryId);
    }

    public List<Integer> getRestrictedCategoryIds() {
        return restrictedCategories;
    }

    public boolean isCategoryRestricted(int categoryId) {
        return restrictedCategories.contains(categoryId);
    }

    public boolean isEnabled() {
        return mEnabled;
    }

    public void setEnabled(boolean mEnabled) {
        GuestUserConfig.mEnabled = mEnabled;
    }

    public boolean isPreventPriceTag() {
        return mPreventPriceTag;
    }

    public void setPreventPriceTag(boolean mPreventPriceTag) {
        GuestUserConfig.mPreventPriceTag = mPreventPriceTag;
    }
}