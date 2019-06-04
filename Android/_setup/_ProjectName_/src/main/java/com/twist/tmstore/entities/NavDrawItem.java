package com.twist.tmstore.entities;

import android.support.annotation.NonNull;

import com.bignerdranch.expandablerecyclerview.Model.ParentListItem;
import com.twist.tmstore.Constants;
import com.twist.tmstore.L;
import com.twist.tmstore.R;
import com.utils.Helper;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import static com.twist.tmstore.L.getString;

public class NavDrawItem implements ParentListItem {

    public String getData() {
        return data;
    }

    public void setData(String data) {
        this.data = data;
    }

    @Override
    public List<Object> getChildItemList() {
        return header != null ? header : new ArrayList<>();
    }

    @Override
    public boolean isInitiallyExpanded() {
        return false;
    }
    
    public String getRole() {
        return role;
    }
    
    public void setRole(String role) {
        this.role = role;
    }
    
    public enum Type {
        CATEGORY, MENU, GROUPS
    }

    private String name;
    private String data = null;
    private int iconId;
    private int id;
    private int parent_id = -1;
    private String iconUrl;
    private int[] sortOrder = null;
    private String role = null;

    public List<Object> header;
    public HashMap<Object, List<Object>> child;

    private boolean showIcon = true;

    public NavDrawItem(int id, String name, int iconId, @NonNull List header, @NonNull HashMap child) {
        this.id = id;
        this.name = name;
        this.iconId = iconId;
        this.header = header;
        this.child = child;
    }

    public NavDrawItem(int id, String name, int iconId) {
        this.id = id;
        this.name = name;
        this.iconId = iconId;
    }

    public NavDrawItem(int id, String name) {
        this(id, name, getItemIcon(id));
    }

    public NavDrawItem(int id) {
        this(id, getItemName(id));
    }

    public int getParent() {
        return this.parent_id;
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
            case Constants.MENU_ID_GROUPS:
                return R.drawable.ic_vc_link;
            case Constants.MENU_ID_MY_COUPONS:
                return R.drawable.ic_vc_coupon;
            case Constants.MENU_ID_NOTIFICATIONS:
                return R.drawable.ic_vc_notification;
            case Constants.MENU_ID_FIXED_PRODUCTS:
                return R.drawable.ic_vc_link;
            case Constants.MENU_ID_CHANGE_PLATFORM:
                return R.drawable.ic_vc_android;
            case Constants.MENU_ID_SCAN_PRODUCT:
                return R.drawable.ic_vc_scan_product;
            case Constants.MENU_ID_CHANGE_STORE:
                return R.drawable.ic_vc_store;
            case Constants.MENU_ID_RESERVATION_FORM:
                return R.drawable.ic_action_table;
            case Constants.MENU_ID_CONTACT_FORM3:
                return R.drawable.ic_vc_write;
            case Constants.MENU_ID_LOCATE_STORE:
                return R.drawable.ic_vc_store;
            case Constants.MENU_ID_SHARE_APP:
                return R.drawable.ic_vc_share;
            case Constants.MENU_ID_NEWS_FEED:
                return R.drawable.ic_vc_feed;
            case Constants.MENU_ID_LIVE_CHAT:
                return R.drawable.ic_vc_chat;
        }
        return R.drawable.ic_vc_link;
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
            case Constants.MENU_ID_FRESH_CHAT:
                return getString(L.string.title_live_chat);
            case Constants.MENU_ID_REFER_FRIEND:
                return getString(L.string.sponsor_a_friend);
            case Constants.MENU_ID_RATE_APP:
                return getString(L.string.rate_us);
            case Constants.MENU_ID_GROUPS:
                return getString(L.string.title_groups);
            case Constants.MENU_ID_SELLER_HOME:
                return getString(L.string.title_seller_zone);
            case Constants.MENU_ID_MY_COUPONS:
                return getString(L.string.my_coupons);
            case Constants.MENU_ID_NOTIFICATIONS:
                return getString(L.string.my_notifications);
            case Constants.MENU_ID_CHANGE_PLATFORM:
                return getString(L.string.change_platform);
            case Constants.MENU_ID_SCAN_PRODUCT:
                return getString(L.string.scan_product);
            case Constants.MENU_ID_CHANGE_STORE:
                return getString(L.string.change_store);
            case Constants.MENU_ID_RESERVATION_FORM:
                return getString(L.string.title_reservation);
            case Constants.MENU_ID_CONTACT_FORM3:
                return getString(L.string.title_contact_us);
            case Constants.MENU_ID_LOCATE_STORE:
                return getString(L.string.locate_store);
            case Constants.MENU_ID_SHARE_APP:
                return getString(L.string.share);
            case Constants.MENU_ID_NEWS_FEED:
                return getString(L.string.title_news_feed);
            case Constants.MENU_ID_LIVE_CHAT:
                return getString(L.string.title_live_chat);
            default:
                return "";
        }
    }

    public String getName() {
        return name;
    }

    public void updateName() {
        String newName = getItemName(this.id);
        if (Helper.isValidString(newName)) {
            this.name = newName;
        }
    }

    public int getIconId() {
        return iconId;
    }

    public int getId() {
        return id;
    }

    public List<Object> getHeader() {
        return header;
    }

    public void addChild(Object obj) {
        if (header == null) {
            header = new ArrayList<>();
        }
        header.add(obj);
    }

    public String getIconUrl() {
        return iconUrl;
    }

    public void setIconUrl(String iconUrl) {
        this.iconUrl = iconUrl;
    }

    public int[] getSortOrder() {
        return sortOrder;
    }

    public void setSortOrder(int[] sortOrder) {
        this.sortOrder = sortOrder;
    }

    public boolean isShowIcon() {
        return showIcon;
    }

    public void setShowIcon(boolean showIcon) {
        this.showIcon = showIcon;
    }
}
