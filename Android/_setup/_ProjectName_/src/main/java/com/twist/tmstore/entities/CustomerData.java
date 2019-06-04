package com.twist.tmstore.entities;

import android.text.TextUtils;

import com.parse.ParseClassName;
import com.parse.ParseObject;
import com.parse.ParseUser;

import java.util.List;

/**
 * Created by Twist Mobile on 12/10/2015.
 */
@ParseClassName("CustomerData")
public class CustomerData extends ParseObject {
    private static CustomerData mInstance;

    public static CustomerData getInstance() {
        /*
        // bad idea.. seriously..
        if(mInstance == null)
            mInstance = new CustomerData();
        */
        return mInstance;
    }

    public CustomerData() {
        // A default constructor is required.
    }

//    public void setInstance() {
//        mInstance = this;
//    }

    public static void setInstance(CustomerData customerData) {
        mInstance = customerData;
    }

//    public String getFirstName() {
//        return getString("FirstName");
//    }

    public void setFirstName(String firstName) {
        put("FirstName", firstName);
    }

//    public String getPhoneNo() {
//        return getString("PhoneNo");
//    }
//
//    public void setPhoneNo(String phoneNo) {
//        put("PhoneNo", phoneNo);
//    }
//
//    public String getZipCode() {
//        return getString("ZipCode");
//    }
//
//    public void setZipCode(String zipCode) {
//        put("ZipCode", zipCode);
//    }
//
//    public String getCountry() {
//        return getString("Country");
//    }
//
//    public void setCountry(String country) {
//        put("Country", country);
//    }

    public String getUsername() {
        return getString("Username");
    }

    public void setUsername(String username) {
        put("Username", username);
    }

    public String getPassword() {
        return getString("Password");
    }

    public void setPassword(String password) {
        put("Password", password);
    }

//    public String getEmailID() {
//        return getString("EmailID");
//    }

    public void setEmailID(String emailID) {
        put("EmailID", emailID);
    }

//    public String getLastName() {
//        return getString("LastName");
//    }

    public void setLastName(String lastName) {
        put("LastName", lastName);
    }

    public String getAddress() {
        return getString("Address");
    }

    public void setAddress(String address) {
        put("Address", address);
    }

    //    public String getCompanyName() {
//        return getString("CompanyName");
//    }
//
//    public void setCompanyName(String companyName) {
//        put("CompanyName", companyName);
//    }
//
    public String getState() {
        return getString("State");
    }

    public void setState(String state) {
        put("State", state);
    }

//    public String getProduct_WishList() {
//        return getString("Product_WishList");
//    }
//
//    public void setProduct_WishList(String product_WishList) {
//        put("Product_WishList", product_WishList);
//    }
//
//    public String getProduct_Purchased() {
//        return getString("Product_Purchased");
//    }
//
//    public void setProduct_Purchased(String product_Purchased) {
//        put("Product_Purchased", product_Purchased);
//    }
//
//    public String getProduct_Delivery_Status() {
//        return getString("Product_Delivery_Status");
//    }
//
//    public void setProduct_Delivery_Status(String product_Delivery_Status) {
//        put("Product_Delivery_Status", product_Delivery_Status);
//    }
//
//    public String getProduct_Order_Cancel() {
//        return getString("Product_Order_Cancel");
//    }
//
//    public void setProduct_Order_Cancel(String product_Order_Cancel) {
//        put("Product_Order_Cancel", product_Order_Cancel);
//    }

//    public String getProduct_Refund() {
//        return getString("Product_Refund");
//    }
//
//    public void setProduct_Refund(String product_Refund) {
//        put("Product_Refund", product_Refund);
//    }
//
//    public String getProduct_cart() {
//        return getString("Product_cart");
//    }
//
//    public void setProduct_cart(String product_cart) {
//        put("Product_cart", product_cart);
//    }
//
//    public String getWebSiteUrl() {
//        return getString("WebSiteUrl");
//    }
//
//    public void setWebSiteUrl(String webSiteUrl) {
//        put("WebSiteUrl", webSiteUrl);
//    }
//
//    public String getApp_Name() {
//        return getString("App_Name");
//    }

    public void setApp_Name(String app_Name) {
        put("App_Name", app_Name);
    }

    public String getDeviceModel() {
        return getString("DeviceModel");
    }

    public void setDeviceModel(String deviceModel) {
        put("DeviceModel", deviceModel);
    }

//    public Number getDay_7() {
//        return getNumber("Day_7");
//    }
//
//    public void setDay_7(Number day_7) {
//        put("Day_7", day_7);
//    }

    public List<List<String>> getCurrent_Day_Cart_Items() {
        return getList("Current_Day_Cart_Items");
    }

    public void setCurrent_Day_Cart_Items(Object current_Day_Cart_Items) {
        if (current_Day_Cart_Items != null) {
            put("Current_Day_Cart_Items", current_Day_Cart_Items);
        } else {
            put("Current_Day_Cart_Items", "[]");
        }
    }

    public List<List<String>> getCurrent_Day_Whishlist_Items() {
        return getList("Current_Day_Whishlist_Items");
    }

    public void setCurrent_Day_Whishlist_Items(Object current_Day_WishList_Items) {
        if (current_Day_WishList_Items != null) {
            put("Current_Day_Whishlist_Items", current_Day_WishList_Items);
        } else {
            put("Current_Day_Whishlist_Items", "[]");
        }
    }

    public List<List<String>> getCurrent_Day_WhishList_Items() {
        return getList("Current_Day_WhishList_Items");
    }

    public void setCurrent_Day_WhishList_Items(Object current_Day_WishList_Items) {
        if (current_Day_WishList_Items != null) {
            put("Current_Day_WhishList_Items", current_Day_WishList_Items);
        } else {
            put("Current_Day_WhishList_Items", "[]");
        }
    }

    public int getCurrent_Day_App_Visit() {
        return getNumber("Current_Day_App_Visit").intValue();
    }

    public void setCurrent_Day_App_Visit(Number current_Day_App_Visit) {
        put("Current_Day_App_Visit", current_Day_App_Visit);
    }

    public void incrementCurrent_Day_App_Visit() {
        increment("Current_Day_App_Visit");
    }

//    public Number getCurrent_Day_Purchased_Amount() {
//        return getNumber("Current_Day_Purchased_Amount");
//    }

    public void setCurrent_Day_Purchased_Amount(Number current_Day_Purchased_Amount) {
        put("Current_Day_Purchased_Amount", current_Day_Purchased_Amount);
    }

    public void incrementCurrent_Day_Purchased_Amount(Number amount) {
        increment("Current_Day_Purchased_Amount", amount);
    }

//    public Number getCurrent_Day_Purchased_Items() {
//        return getNumber("Current_Day_Purchased_Items");
//    }
//
//    public void setCurrent_Day_Purchased_Items(Number current_Day_Purchased_Items) {
//        put("Current_Day_Purchased_Item", current_Day_Purchased_Items);
//    }

    public void incrementCurrent_Day_Purchased_Item(int count) {
        increment("Current_Day_Purchased_Item", count);
    }

//    public ParseUser getParseUser() {
//        return getParseUser("ParseUser");
//    }

    public void setParseUser(ParseUser parseUser) {
        put("ParseUser", parseUser);
        addInstallId(parseUser);
    }

    public void addInstallId(ParseUser parseUser) {
        add("install_ids", parseUser);
    }

    /* Add Device Token or Device ID for FCM Notifications */
    public void addDeviceToken(String deviceToken) {
        if(!TextUtils.isEmpty(deviceToken)) {
            add("installation_ids", deviceToken);
        }
    }

    public void addReferrer(String referrer) {
        if(!TextUtils.isEmpty(referrer)) {
            add("referrers", referrer);
        }
    }

//    public String getGender() {
//        return getString("Gender");
//    }
//
//    public void setGender(String gender) {
//        put("Gender", gender);
//    }
//
//    public Object getCurrent_Month_App_Visit() {
//        return get("Current_Month_App_Visit");
//    }
//
//    public void setCurrent_Month_App_Visit(Object current_Month_App_Visit) {
//        put("Current_Month_App_Visit", current_Month_App_Visit);
//    }
//
//    public Object getCurrent_Month_Purchased_Items() {
//        return get("Current_Month_Purchased_Items");
//    }
//
//    public void setCurrent_Month_Purchased_Items(Object current_Month_Purchased_Items) {
//        put("Current_Month_Purchased_Items", current_Month_Purchased_Items);
//    }
//
//    public Object getCurrent_Month_Cart_Items() {
//        return get("Current_Month_Cart_Items");
//    }
//
//    public void setCurrent_Month_Cart_Items(Object current_Month_Cart_Items) {
//        put("Current_Month_Cart_Items", current_Month_Cart_Items);
//    }
//
//    public Object getCurrent_Month_WishList_Items() {
//        return get("Current_Month_WishList_Items");
//    }
//
//    public void setCurrent_Month_WishList_Items(Object current_Month_WishList_Items) {
//        put("Current_Month_WishList_Items", current_Month_WishList_Items);
//    }

    public void copyData(CustomerData another) {
        this.setCurrent_Day_App_Visit(another.getCurrent_Day_App_Visit());
        this.setCurrent_Day_Cart_Items(another.getCurrent_Day_Cart_Items());
        this.setCurrent_Day_WhishList_Items(another.getCurrent_Day_WhishList_Items());
        this.setCurrent_Day_Whishlist_Items(another.getCurrent_Day_Whishlist_Items());
    }

    /*
    public String FirstName;
    public String PhoneNo;
    public String ZipCode;
    public String Country;
    public String Username;
    public String Password;
    public String EmailID;
    public String LastName;
    public String Address;
    public String CompanyName;
    public String State;
    public String Product_WishList;
    public String Product_Purchased;
    public String Product_Delivery_Status;
    public String Product_Order_Cancel;
    public String Product_Refund;
    public String Product_cart;
    public String WebSiteUrl;
    public String App_Name;
    public Number Day_7;
    public String[] Current_Day_Cart_Items;
    public String[] Current_Day_WishList_Items;
    public Number Current_Day_App_Visit;
    public Number Current_Day_Purchased_Amount;
    public Number Current_Day_Purchased_Items;
    public String Gender;
    public Number[] Current_Month_App_Visit;
    public Number[] Current_Month_Purchased_Items;
    public String[] Current_Month_Cart_Items;
    public String[] Current_Month_WishList_Items;
    */

    public String getDisplayName() {
        return getString("displayName");
    }

    public void setDisplayName(String displayName) {
        put("displayName", displayName);
    }

    public static void appendData(CustomerData from, CustomerData to) {

        final String[] numericColumns = {
                "Current_Day_App_Visit",
                "Current_Day_Purchased_Amount",
                "Current_Day_Purchased_Item",
                "Today_App_Visit"
        };

        final String[] arrayColumns = {
                "Current_Day_Purchased_Items",
                "Current_Day_Whishlist_Items",
                "Current_Month_Cart_Items",
                "Current_Month_Purchased_Amount",
                "Current_Month_App_Visit",
                "Current_Month_WhishList_Items",
                "Today_Cart_Items",
                "Today_Purchased_Amount",
                "Today_WhishList_Items",
                "Today_Purchased_Items",
                "Current_Day_Cart_Items",
                "Current_Day_WhishList_Items",
                "referrers"
        };

        final String[] stringColumns = {
                "FirstName",
                "LastName",
                "Password",
                "Username"
        };

        for (String key : numericColumns) {
            if (from.getNumber(key) != null) {
                to.increment(key, from.getNumber(key));
            }
        }
        for (String key : arrayColumns) {
            if (from.getList(key) != null) {
                to.addAll(key, from.getList(key));
            }
        }
        for (String key : stringColumns) {
            if (from.getString(key) != null) {
                to.put(key, from.getString(key));
            }
        }
    }
}
