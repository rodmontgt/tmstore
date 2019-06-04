package com.twist.tmstore.entities;

import com.twist.tmstore.Constants;
import com.twist.tmstore.L;
import com.twist.tmstore.R;
import com.utils.Helper;

import static com.twist.tmstore.L.getString;

/**
 * Created by Twist Mobile on 05-12-2016.
 */
public class MyProfileItem {

    private final int id;
    private final String name;
    private final int iconId;

    public MyProfileItem(int id, String name, int iconId) {
        this.id = id;
        this.name = name;
        this.iconId = iconId;
    }

    public MyProfileItem(int id, String name) {
        this(id, name, getItemIcon(id));
    }

    public MyProfileItem(int id) {
        this(id, getItemName(id));
    }

    public int getIconId() {
        return iconId;
    }

    public int getId() {
        return id;
    }

    public String getName() {
        String string = getItemName(this.id);
        if (Helper.isValidString(string))
            return string;
        return this.name;
    }

    public static String getItemName(int itemId) {
        switch (itemId) {
            case Constants.MENU_ID_HOME:
                return getString(L.string.title_shop);
            case Constants.MENU_ID_WISH:
                return getString(L.string.title_wishlist);
            case Constants.MENU_ID_CART:
                return getString(L.string.title_cart);
            case Constants.MENU_ID_ORDERS:
                return getString(L.string.title_myorders);
            case Constants.MENU_ID_SETTINGS:
                return getString(L.string.title_settings);
            case Constants.MENU_ID_ABOUT:
                return getString(L.string.title_about);
            case Constants.MENU_ID_CHANGE_SELLER:
                return getString(L.string.title_change_vendor);
            case Constants.MENU_ID_SIGN_IN:
                return getString(L.string.title_login);
            case Constants.MENU_ID_SELLER_INFO:
                return getString(L.string.title_login_as_vendor);
            case Constants.MENU_ID_SIGN_OUT:
                return getString(L.string.title_logout);
            case Constants.MENU_ID_PROFILE:
                return getString(L.string.title_profile);
            case Constants.MENU_ID_SEARCH:
                return getString(L.string.title_search);
            case Constants.MENU_ID_CATEGORIES:
                return getString(L.string.title_categories);
            case Constants.MENU_ID_OPINION:
                return getString(L.string.menu_title_opinion);
            case Constants.MENU_ID_REFER_FRIEND:
                return getString(L.string.sponsor_a_friend);
            case Constants.MENU_ID_RATE_APP:
                return getString(L.string.rate_us);
            case Constants.MENU_ID_GROUPS:
                return getString(L.string.title_groups);
            case Constants.MENU_ID_SELLER_HOME:
                return getString(L.string.title_seller_zone);
            case Constants.MENU_ID_MY_ADDRESS:
                return getString(L.string.my_addresses);
            case Constants.MENU_ID_SELLER_PRODUCTS:
                return getString(L.string.seller_my_products);
            case Constants.MENU_ID_SELLER_UPLOAD_PRODUCT:
                return getString(L.string.seller_upload_product);
            case Constants.MENU_ID_SELLER_ORDERS:
                return getString(L.string.seller_my_orders);
            case Constants.MENU_ID_SELLER_WALLET:
                return getString(L.string.seller_my_wallet);
            case Constants.MENU_ID_SELLER_ANALYTICS:
                return getString(L.string.seller_analytics);
            case Constants.MENU_ID_SELLER_STORE_SETTINGS:
                return getString(L.string.title_store_settings);
            case Constants.MENU_ID_SHARE_APP:
                return getString(L.string.share);
            case Constants.MENU_ID_FRESH_CHAT:
                return getString(L.string.title_live_chat);
            case Constants.MENU_ID_LIVE_CHAT:
                return getString(L.string.title_live_chat);
            default:
                return "";
        }
    }

    public static int getItemIcon(int itemId) {
        switch (itemId) {
            case Constants.MENU_ID_HOME:
                return R.drawable.ic_vc_home;
            case Constants.MENU_ID_WISH:
                return R.drawable.ic_vc_wish_flat;
            case Constants.MENU_ID_CART:
                return R.drawable.ic_vc_cart;
            case Constants.MENU_ID_ORDERS:
                return R.drawable.ic_vc_orders;
            case Constants.MENU_ID_SETTINGS:
                return R.drawable.ic_vc_settings;
            case Constants.MENU_ID_ABOUT:
                return R.drawable.ic_vc_contact;
            case Constants.MENU_ID_CHANGE_MERCHANT:
                return R.drawable.ic_vc_seller;
            case Constants.MENU_ID_CHANGE_SELLER:
                return R.drawable.ic_vc_seller;
            case Constants.MENU_ID_SIGN_IN:
                return R.drawable.ic_vc_login;
            case Constants.MENU_ID_SELLER_INFO:
                return R.drawable.ic_vc_link;
            case Constants.MENU_ID_SIGN_OUT:
                return R.drawable.ic_vc_logout;
            case Constants.MENU_ID_PROFILE:
                return R.drawable.ic_vc_settings;
            case Constants.MENU_ID_SEARCH:
                return R.drawable.ic_vc_search;
            case Constants.MENU_ID_CATEGORIES:
                return R.drawable.ic_vc_categories;
            case Constants.MENU_ID_OPINION:
                return R.drawable.ic_vc_opinion;
            case Constants.MENU_ID_FRESH_CHAT:
                return R.drawable.ic_vc_chat;
            case Constants.MENU_ID_WEB_PAGE:
                return R.drawable.ic_vc_link;
            case Constants.MENU_ID_EXTERNAL_LINK:
                return R.drawable.ic_vc_external_link;
            case Constants.MENU_ID_REFER_FRIEND:
                return R.drawable.ic_vc_sponsor_friend;
            case Constants.MENU_ID_RATE_APP:
                return R.drawable.ic_vc_rate_us;
            case Constants.MENU_ID_SELLER_HOME:
                return R.drawable.ic_vc_seller;
            case Constants.MENU_ID_MY_ADDRESS:
                return R.drawable.ic_vc_location;
            case Constants.MENU_ID_SELLER_PRODUCTS:
                return R.drawable.ic_vc_categories;
            case Constants.MENU_ID_SELLER_UPLOAD_PRODUCT:
                return R.drawable.ic_vc_upload;
            case Constants.MENU_ID_SELLER_ORDERS:
                return R.drawable.ic_vc_orders;
            case Constants.MENU_ID_SELLER_WALLET:
                return R.drawable.ic_vc_wallet;
            case Constants.MENU_ID_SELLER_ANALYTICS:
                return R.drawable.ic_vc_chart;
            case Constants.MENU_ID_GROUPS:
                return R.drawable.ic_vc_link;
            case Constants.MENU_ID_SELLER_STORE_SETTINGS:
                return R.drawable.ic_vc_seller;
            case Constants.MENU_ID_SHARE_APP:
                return R.drawable.ic_vc_share;
            case Constants.MENU_ID_LIVE_CHAT:
                return R.drawable.ic_vc_chat;
        }
        return R.drawable.ic_vc_link;
    }
}
