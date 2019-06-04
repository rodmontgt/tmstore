package com.twist.dataengine;

import android.app.Activity;
import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import com.google.gson.Gson;
import com.twist.dataengine.entities.*;
import com.twist.dataengine.shippings.DefaultWooComShipping;
import com.twist.dataengine.shippings.EpekenJneAllCountriesShipping;
import com.twist.dataengine.shippings.EpekenJneShipping;
import com.twist.dataengine.shippings.RajaOngkirShipping;
import com.twist.oauth.NetworkRequest;
import com.twist.oauth.NetworkResponse;
import com.twist.tmstore.R;
import com.utils.Base64Utils;
import com.utils.DataHelper;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.*;

/**
 * Created by Twist Mobile on 12/30/2015.
 */

public class DataEngine {

    private static boolean logEnabled = false;

    private Activity activity = null;
    private NoConnectionError mNoConnectionError;
    private ShippingEngine shippingEngine;

    public static String baseURL = "";
    private String version_string = "";

    public static boolean hide_blocked_items = false;
    public static boolean use_plugin_for_pagging = false;
    public static boolean use_plugin_for_full_data = false;
    public static boolean enable_mix_n_match = false;
    public static boolean refine_categories = false;
    public static boolean show_child_cat_products_in_parent_cat = true;
    public static boolean load_extra_attrib_data = false;
    public static boolean append_variation_images = false;
    public static boolean auto_generate_variations = false;
    public static boolean stepup_single_child_categories = false;
    public static boolean show_non_variation_attribute = false;
    public static boolean resize_product_thumbs = false;
    public static boolean resize_product_images = false;
    public static int max_categories_query_count_limit = 25;
    public static int max_products_query_count_limit = 25;
    public static int max_search_products_query_count_limit = 50;
    public static int max_initial_products_query_limit = 10;

    private String locale = "";

    public String url_local_pickup_time_select = "";
    public String url_login_website = "";
    public String url_image_upload = "";
    public String url_countries_list = "";
    public String url_cart_items = "";
    public String url_checkout = "";
    public String url_delivery_slots_copia = "";

    private String url_assign_seller_order = "";
    private String url_add_review = "";
    private String url_order_meta = "";
    private String url_product_attributes = "";
    private String url_order_approval = "";
    private String url_woocommerce_bookings = "";
    private String url_products = "";
    private String url_load_products = "";
    private String url_splash_products = "";
    private String url_customer_data = "";
    private String url_customer_edit = "";
    private String url_orders = "";
    private String url_register_order = "";
    private String url_single_order = "";
    private String url_common = "";
    private String url_social_login = "";
    private String url_signin = "";
    private String url_signup = "";
    private String url_forget_password = "";
    private String url_poll_products = "";
    private String url_filterdata_prices = "";
    private String url_filterdata_attributes = "";
    private String url_filter_products = "";
    private String url_shipment_track = "";
    private String url_cross_sells_product = "";
    private String url_coupons = "";
    private String url_coupons_code = "";
    private String url_menu_data = "";
    private String url_custom_sponsor_friend = "";
    private String url_custom_wishlist = "";
    private String url_custom_waitlist = "";
    private String url_custom_reward_points = "";
    private String url_products_brand_names = "";
    private String url_products_price_labels = "";
    private String url_incremental_product_quantities = "";
    private String url_product_pin_code_availability = "";
    private String url_product_pin_code = "";
    private String url_all_attributes = "";
    private String url_shipping_type = "";
    private String url_create_multiple_wishlist = "";
    private String url_seller_list = "";
    private String url_seller_info = "";
    private String url_seller_orders = "";
    private String url_seller_products = "";
    private String url_frontpage_content_seller = "";
    private String url_assign_seller_product = "";
    private String url_seller_load_products = "";
    private String url_products_fast = "";
    private String url_single_product_fast = "";
    private String url_product_shipping_info = "";
    private String url_extra_attribs = "";
    private String url_order_data = "";
    private String url_product_full_data = "";
    private String url_order_delivery_slots = "";
    private String url_product_delivery_info = "";
    private String url_reservation_from = "";
    private String url_contact_from_3 = "";
    private String url_wpcf7_form = "";
    private String url_otp = "";
    private String url_multiple_shipping_address;
    private String url_checkout_manager;
    private String url_reset_password = "";
    private String url_verify_user_email = "";
    private String url_reset_mobile_email_password = "";
    private String url_filter_price_attribute = "";
    private String url_blog_info = "";
    private String url_wc_auction = "";
    private String url_search_products = "";

    private static DataEngine dataEngine;

    public static DataEngine getDataEngine() {
        if (dataEngine == null)
            dataEngine = new DataEngine();
        return dataEngine;
    }

    private DataEngine() {
    }

    public void initWithArgs(Activity activity, String url, String oauth_ck, String oauth_cs, String ver, String ep, String mvp, String sp, String sk) {
        this.activity = activity;
        DataEngine.baseURL = url;
        this.version_string = ver;
        NetworkRequest.setParams(oauth_ck, oauth_cs);
        this.initUrls(ep, mvp);
        this.initShipping(sp, sk);
        mNoConnectionError = new NoConnectionError(activity.getString(R.string.no_network_connection));
    }

    private void initUrls(String ep, String mvp) {
        String plugin = "/wp-" + ep + "-store" + "-notify/api/";
        String base_url_ext_api_mvp = baseURL + "/wp-tm-ext-store-notify/api/" + mvp + "_";

        url_products = baseURL + "/wc-api/" + version_string + "/products";
        url_splash_products = baseURL + plugin + "splash_products";
        url_load_products = baseURL + plugin + "load_products";
        url_customer_data = baseURL + "/wc-api/" + version_string + "/customers/email/";
        url_customer_edit = baseURL + "/wc-api/" + version_string + "/customers/";
        url_social_login = baseURL + plugin + "social-login/";
        url_signin = baseURL + plugin + "login/";
        url_signup = baseURL + plugin + "register/";
        url_forget_password = baseURL + plugin + "forget-password/";
        url_register_order = baseURL + "/wc-api/" + version_string + "/orders";  // /wc-api/v3/customers/<id>/orders
        url_orders = baseURL + "/wc-api/" + version_string + "/customers/";
        url_coupons = baseURL + "/wc-api/" + version_string + "/coupons";
        url_coupons_code = baseURL + "/wc-api/" + version_string + "/coupons/code/";
        url_single_order = baseURL + "/wc-api/" + version_string + "/orders/";
        url_common = baseURL + "/wc-api/" + version_string;
        url_login_website = baseURL + plugin + "login_website";
        url_order_data = baseURL + plugin + "order_data";
        url_cart_items = baseURL + plugin + "cart_items/";
        url_checkout = baseURL + "/cart?device_type=android";
        url_poll_products = baseURL + plugin + "pole_products/";
        url_filterdata_prices = baseURL + plugin + "filter_data_price/";
        url_filterdata_attributes = baseURL + plugin + "filter_data_attribute/";
        url_filter_products = baseURL + plugin + "filter_products/";
        url_shipment_track = baseURL + plugin + "exship_data/";
        url_cross_sells_product = baseURL + plugin + "crosssell_data/";
        url_menu_data = baseURL + plugin + "menu_data/";
        url_custom_sponsor_friend = baseURL + "/wp-tm-ext-store-notify/api/custom_sponsor_a_friend/";
        url_custom_wishlist = baseURL + "/wp-tm-ext-store-notify/api/custom_wishlist/";
        url_custom_waitlist = baseURL + "/wp-tm-ext-store-notify/api/custom_waitlist/";
        url_custom_reward_points = baseURL + "/wp-tm-ext-store-notify/api/custom_reward_points/";
        url_create_multiple_wishlist = baseURL + "/wp-tm-ext-store-notify/api/woocommerce_multiple_wishlist/";
        url_frontpage_content_seller = base_url_ext_api_mvp + "splash_products";
        url_seller_list = base_url_ext_api_mvp + "seller_list";
        url_seller_info = base_url_ext_api_mvp + "seller_info";
        url_seller_load_products = base_url_ext_api_mvp + "load_products";
        url_seller_products = base_url_ext_api_mvp + "load_category_products";
        url_assign_seller_product = base_url_ext_api_mvp + "product_to_seller";
        url_seller_orders = base_url_ext_api_mvp + "seller_orders";
        url_assign_seller_order = base_url_ext_api_mvp + "order_to_seller";
        url_products_fast = baseURL + plugin + "load_category_products";
        url_products_brand_names = baseURL + "/wp-tm-ext-store-notify/api/woo_brand";
        url_products_price_labels = baseURL + "/wp-tm-ext-store-notify/api/woocommerce_price_labeller";
        url_incremental_product_quantities = baseURL + "/wp-tm-ext-store-notify/api/woocommerce_incremental_product_quantities";
        url_extra_attribs = baseURL + "/wp-tm-ext-store-notify/api/variation_simple_fields";
        url_single_product_fast = baseURL + "/wp-tm-ext-store-notify/api/woocommerce_ext_product_data/";
        url_product_pin_code = baseURL + "/wp-tm-ext-store-notify/api/woocommerce_product_pin_code/";
        url_product_pin_code_availability = baseURL + "/wp-tm-ext-store-notify/api/woocommerce_product_availibilty_pin_code/";
        url_product_full_data = baseURL + plugin + "product_full_data/";
        url_local_pickup_time_select = baseURL + "/wp-tm-ext-store-notify/api/woocommerce_local_pickup_time_select";
        url_delivery_slots_copia = baseURL + "/wp-tm-ext-store-notify/api/woocommerce_delivery_slots_copia";
        url_order_delivery_slots = baseURL + "/wp-tm-ext-store-notify/api/woocommerce_delivery_slots_copia/";
        url_image_upload = baseURL + plugin + "upload_image";
        url_all_attributes = baseURL + plugin + "attribute_data";
        url_shipping_type = baseURL + plugin + "shipping_list/";
        url_product_shipping_info = baseURL + plugin + "product_shipping_info";
        url_product_delivery_info = baseURL + "/wp-tm-ext-store-notify/api/product-delivery-info/";
        url_reservation_from = baseURL + "/wp-tm-ext-store-notify/api/reservation_form/";
        url_contact_from_3 = baseURL + "/wp-tm-ext-store-notify/api/contact_form/";
        url_wpcf7_form = baseURL + "/wp-tm-ext-store-notify/api/wpcf7_form";
        url_otp = baseURL + "/wp-tm-ext-store-notify/api/otp";
        url_multiple_shipping_address = baseURL + "/wp-tm-ext-store-notify/api/multiple_shipping_address";
        url_checkout_manager = baseURL + "/wp-tm-ext-store-notify/api/woocommerce-checkout-manager/";
        url_reset_password = baseURL + plugin + "reset_password/";
        url_verify_user_email = baseURL + plugin + "verify_user_email/";
        url_reset_mobile_email_password = baseURL + plugin + "set_password/";
        url_countries_list = baseURL + plugin + "countries_list/";
        url_add_review = baseURL + "/wp-tm-store-notify/api/add_reviews";
        url_order_meta = baseURL + "/wp-tm-ext-store-notify/api/woocommerce_ordermeta";
        url_product_attributes = baseURL + "/wp-tm-ext-store-notify/api/product_attributes";
        url_filter_price_attribute = baseURL + "/wp-tm-store-notify/api/filter_price_attribute";
        url_order_approval = baseURL + "/wp-tm-ext-store-notify/api/woocommerce_ordermeta";
        url_blog_info = baseURL + "/wp-tm-store-notify/api/blog_info/";
        url_wc_auction = baseURL + "/wp-tm-ext-store-notify/api/wc_auction/";
        url_search_products = baseURL + "/wp-tm-store-notify/api/search_products";
        url_woocommerce_bookings = baseURL + "/wp-tm-ext-store-notify/api/woocommerce_bookings/";
    }

    public void setContext(Activity activity) {
        this.activity = activity;
    }

    private void initShipping(String shippingProvider, String shippingKey) {
        switch (shippingProvider.toLowerCase()) {
            case "rajaongkir":
                shippingEngine = new RajaOngkirShipping(baseURL, shippingKey);
                break;
            case "epeken_jne":
                shippingEngine = new EpekenJneShipping(baseURL, shippingKey);
                break;
            case "all_courier":
                shippingEngine = new EpekenJneAllCountriesShipping(baseURL, shippingKey);
                break;
            default:
                shippingEngine = new DefaultWooComShipping(baseURL);
                break;
        }
    }

    public static boolean isLogEnabled() {
        return logEnabled;
    }

    public static void setLogEnabled(boolean logEnabled) {
        DataEngine.logEnabled = logEnabled;
    }

    public ShippingEngine getShippingEngine() {
        return shippingEngine;
    }

    public void setLocale(String locale) {
        this.locale = locale;
    }

    public boolean isNetworkAvailable() {
        ConnectivityManager connectivityManager = (ConnectivityManager) activity.getSystemService(Context.CONNECTIVITY_SERVICE);
        NetworkInfo activeNetworkInfo = connectivityManager.getActiveNetworkInfo();
        return activeNetworkInfo != null && activeNetworkInfo.isConnected();
    }

    public String getVersionString() {
        return version_string;
    }

    public String getContactForm7Url() {
        return url_wpcf7_form;
    }

    public void loadRawCategories(final DataQueryHandler<List<RawCategory>> dataQueryHandler) {
        if (RawCategory.loadingCompleted()) {
            if (dataQueryHandler != null) {
                dataQueryHandler.onSuccess(RawCategory.getAll());
            }
            return;
        }
        final Map<String, String> params = new HashMap<>();
        params.put("lang", DataHelper.encrypt(locale));
        NetworkResponse.ResponseListener responseListener = new NetworkResponse.ResponseListener() {
            @Override
            public void onResponseReceived(NetworkResponse response) {
                DataHelper.log("-- getLoadTempCategoriesInBackground-response: [" + response.msg + "] --");
                if (response.succeed) {
                    if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                        try {
                            parseJsonAndCreateTempCategories(response.msg);
                            dataQueryHandler.onSuccess(RawCategory.getAll());
                            RawCategory.setCategoriesLoaded();
                        } catch (Exception e) {
                            e.printStackTrace();
                            dataQueryHandler.onFailure(new Exception("Error while loading products.."));
                        }
                    }
                } else {
                    dataQueryHandler.onFailure(response.error);
                }
            }
        };
        NetworkRequest.makeCommonPostRequest(url_splash_products, params, null, responseListener);
    }

    public void loadRawAttributes(List<Integer> categoryIds, final DataQueryHandler dataQueryHandler) {
        if (hasNetworkAccess(dataQueryHandler)) {
            Map<String, String> params = new HashMap<>();
            params.put("c_ids", DataHelper.encrypt(DataHelper.join(",", categoryIds)));
            params.put("lang", DataHelper.encrypt(locale));
            NetworkRequest.makeCommonPostRequest(url_all_attributes, params, null, new NetworkResponse.ResponseListener() {
                @Override
                public void onResponseReceived(NetworkResponse response) {
                    if (didResponseSucceed(dataQueryHandler, response)) {
                        if (DataEngine.isLogEnabled()) {
                            DataHelper.log("-- loadRawAttributes::onResponseReceived : [" + response.msg + "]--");
                        }
                        if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                            try {
                                RawAttribute.clearAll();
                                parseJsonAndCreateTempAttributes(response.msg);
                                dataQueryHandler.onSuccess(RawAttribute.getAll());
                            } catch (Exception e) {
                                e.printStackTrace();
                                dataQueryHandler.onFailure(new Exception("Error while loading attributes."));
                            }
                        }
                    }
                }
            });
        }
    }

    public void getShipmentStatusDataInBackground(String trackUrl, String billNumber, String method, String key, final DataQueryHandler<String> dataQueryHandler) {
        if (hasNetworkAccess(dataQueryHandler)) {
            Map<String, String> params = new HashMap<>();
            params.put("waybill", billNumber);
            params.put("courier", method);
            params.put("key", key);
            NetworkRequest.makeCommonPostRequest(trackUrl, params, null, new NetworkResponse.ResponseListener() {
                @Override
                public void onResponseReceived(NetworkResponse response) {
                    if (didResponseSucceed(dataQueryHandler, response)) {
                        if (DataEngine.isLogEnabled()) {
                            DataHelper.log("-- getShipmentStatusDataInBackground::onResponseReceived : [" + response.msg + "]--");
                        }
                        if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                            try {
                                dataQueryHandler.onSuccess(response.msg);
                            } catch (Exception e) {
                                e.printStackTrace();
                                dataQueryHandler.onFailure(new Exception("Error while loading order status."));
                            }
                        }
                    }
                }
            });
        }
    }

    private void parseJsonAndCreateTempAttributes(String jsonStringContent) throws JSONException {
        JSONObject jMainObject = DataHelper.safeJsonObject(jsonStringContent);
        JSONArray attribute_data = jMainObject.getJSONArray("attribute_data");
        for (int i = 0; i < attribute_data.length(); i++) {
            JSONObject jsonObjectCategory = attribute_data.getJSONObject(i);
            parseTempAttribute(jsonObjectCategory);
        }
    }

    private void parseJsonAndCreateTempCategories(String jsonStringContent) throws JSONException {
        JSONObject jMainObject = DataHelper.safeJsonObject(jsonStringContent);
        JSONArray category = jMainObject.getJSONArray("category");
        for (int i = 0; i < category.length(); i++) {
            JSONObject jsonObjectCategory = category.getJSONObject(i);
            parseTempCategory(jsonObjectCategory);
        }
    }

    private void parseTempCategory(JSONObject categoryInfoJson) throws JSONException {
        RawCategory category = RawCategory.getWithId(categoryInfoJson.getInt("id"));
        category.setName(DataHelper.safeString(categoryInfoJson, "name"));
        try {
            String img_url = DataHelper.safeString(categoryInfoJson, "img_url");
            img_url = DataHelper.getResizedImageUrl(img_url);
            category.setThumb(img_url);
        } catch (Exception e) {
            e.printStackTrace();
        }
        int parentId = categoryInfoJson.getInt("parent");
        if (parentId > 0) {
            RawCategory.getWithId(parentId).addChild(category);
        }
    }

    private void parseTempAttribute(JSONObject attributeInfoJson) throws JSONException {
        if (attributeInfoJson.has("product_attribute_term")) {
            JSONArray product_attribute_term = attributeInfoJson.getJSONArray("product_attribute_term");
            if (product_attribute_term.length() > 0) {
                // attributes having attribute terms, only those are required.
                RawAttribute attribute = RawAttribute.getWithId(attributeInfoJson.getInt("id"));
                attribute.setName(DataHelper.safeString(attributeInfoJson, "name"));
                attribute.setSlug(DataHelper.safeString(attributeInfoJson, "slug"));
                attribute.setType(DataHelper.safeString(attributeInfoJson, "type"));
                for (int i = 0; i < product_attribute_term.length(); i++) {
                    attribute.addAttributeTerm(parseTempAttributeTerm(product_attribute_term.getJSONObject(i)));
                }
            }
        }
    }

    private RawAttributeTerm parseTempAttributeTerm(JSONObject attributeTermObject) throws JSONException {
        RawAttributeTerm term = new RawAttributeTerm();
        term.id = attributeTermObject.getInt("id");
        term.name = DataHelper.safeString(attributeTermObject, "name");
        return term;
    }

    public void signInSocialUsing(final String str_email, final TM_LoginListener loginListener) {
        final Map<String, String> params = new HashMap<>();
        params.put("user_emailID", DataHelper.encrypt(str_email));
        params.put("user_platform", DataHelper.encrypt("Android"));
        NetworkResponse.ResponseListener postResponseListener = new NetworkResponse.ResponseListener() {
            @Override
            public void onResponseReceived(NetworkResponse postResponse) {
                if (loginListener != null) {
                    if (postResponse.succeed) {
                        DataHelper.log("-- onResponse:[" + postResponse.msg + "] --");
                        loginListener.onLoginSuccess(postResponse.msg);
                    } else {
                        loginListener.onLoginFailed(postResponse.error.getMessage());
                    }
                }
            }
        };
        NetworkRequest.makeCommonPostRequest(url_social_login, params, null, postResponseListener);
    }

    public void signUpWebUsing(final String str_email, final String str_userid, final String str_password, final TM_LoginListener loginListener) {
        final Map<String, String> params = new HashMap<>();
        params.put("user_emailID", DataHelper.encrypt(str_email));
        params.put("user_name", DataHelper.encrypt(str_userid));
        params.put("user_pass", DataHelper.encrypt(str_password));
        params.put("user_platform", DataHelper.encrypt("Android"));
        NetworkResponse.ResponseListener postResponseListener = new NetworkResponse.ResponseListener() {
            @Override
            public void onResponseReceived(NetworkResponse postResponse) {
                if (loginListener != null) {
                    if (postResponse.succeed) {
                        DataHelper.log("-- onResponse:[" + postResponse.msg + "] --");
                        TM_Response tm_response = DataHelper.parseJsonAndCreateTMResponse(postResponse.msg);
                        if (tm_response.status) {
                            loginListener.onLoginSuccess(tm_response.message);
                        } else {
                            loginListener.onLoginFailed(tm_response.message);
                        }
                    } else {
                        loginListener.onLoginFailed("postResponse failed");
                    }
                }
            }
        };
        NetworkRequest.makeCommonPostRequest(url_signup, params, null, postResponseListener);
    }

    public void signUpWebUsing(Map<String, String> params, final TM_LoginListener loginListener) {
        DataHelper.encrypt(params);
        NetworkResponse.ResponseListener postResponseListener = new NetworkResponse.ResponseListener() {
            @Override
            public void onResponseReceived(NetworkResponse postResponse) {
                if (loginListener != null) {
                    if (postResponse.succeed) {
                        DataHelper.log("-- onResponse:[" + postResponse.msg + "] --");
                        TM_Response tm_response = DataHelper.parseJsonAndCreateTMResponse(postResponse.msg);
                        if (tm_response.status) {
                            loginListener.onLoginSuccess(tm_response.message);
                        } else {
                            loginListener.onLoginFailed(tm_response.message);
                        }
                    } else {
                        loginListener.onLoginFailed("postResponse failed");
                    }
                }
            }
        };
        NetworkRequest.makeCommonPostRequest(url_signup, params, null, postResponseListener);
    }

    public void signUpWebUsing(String _userId, String _email, String _password, String _first_name, String _last_name, String _shop_name, String _phone, String _role, final TM_LoginListener loginListener) {
        final Map<String, String> params = new HashMap<>();
        params.put("user_emailID", DataHelper.encrypt(_email));
        params.put("user_name", DataHelper.encrypt(_userId));
        params.put("user_pass", DataHelper.encrypt(_password));
        params.put("first_name", DataHelper.encrypt(_first_name));
        params.put("last_name", DataHelper.encrypt(_last_name));
        params.put("shop_name", DataHelper.encrypt(_shop_name));
        params.put("phone", DataHelper.encrypt(_phone));
        params.put("role", DataHelper.encrypt(_role));
        params.put("user_platform", DataHelper.encrypt("Android"));
        NetworkResponse.ResponseListener postResponseListener = new NetworkResponse.ResponseListener() {
            @Override
            public void onResponseReceived(NetworkResponse postResponse) {
                if (loginListener != null) {
                    if (postResponse.succeed) {
                        DataHelper.log("-- onResponse:[" + postResponse.msg + "] --");
                        TM_Response tm_response = DataHelper.parseJsonAndCreateTMResponse(postResponse.msg);
                        if (tm_response.status) {
                            loginListener.onLoginSuccess(tm_response.message);
                        } else {
                            loginListener.onLoginFailed(tm_response.message);
                        }
                    } else {
                        loginListener.onLoginFailed("postResponse failed");
                    }
                }
            }
        };
        NetworkRequest.makeCommonPostRequest(url_signup, params, null, postResponseListener);
    }

    public void recoverPassword(final String str_email, final TM_LoginListener loginListener) {
        final Map<String, String> params = new HashMap<>();
        params.put("user_emailID", DataHelper.encrypt(str_email));
        NetworkResponse.ResponseListener postResponseListener = new NetworkResponse.ResponseListener() {
            @Override
            public void onResponseReceived(NetworkResponse postResponse) {
                if (loginListener != null) {
                    if (postResponse.succeed) {
                        DataHelper.log("-- onResponse:[" + postResponse.msg + "] --");
                        TM_Response tm_response = DataHelper.parseJsonAndCreateTMResponse(postResponse.msg);
                        if (tm_response.status) {
                            loginListener.onLoginSuccess(tm_response.message);
                        } else {
                            loginListener.onLoginFailed(tm_response.message);
                        }
                    } else {
                        loginListener.onLoginFailed("postResponse failed");
                    }
                }
            }
        };
        NetworkRequest.makeCommonPostRequest(url_forget_password, params, null, postResponseListener);
    }

    public void resetPassword(final String str_email, final String str_user_pass, final String str_user_pass_new, final TM_LoginListener loginListener) {
        final Map<String, String> params = new HashMap<>();
        params.put("user_emailID", DataHelper.encrypt(str_email));
        params.put("user_pass", DataHelper.encrypt(str_user_pass));
        params.put("user_pass_new", DataHelper.encrypt(str_user_pass_new));
        params.put("user_platform", "Android");
        NetworkRequest.makeCommonPostRequest(url_reset_password, params, null, new NetworkResponse.ResponseListener() {
            @Override
            public void onResponseReceived(NetworkResponse postResponse) {
                if (loginListener != null) {
                    if (postResponse.succeed) {
                        DataHelper.log("-- onResponse:[" + postResponse.msg + "] --");
                        TM_Response tm_response = DataHelper.parseJsonAndCreateTMResponse(postResponse.msg);
                        if (tm_response.status) {
                            loginListener.onLoginSuccess(tm_response.message);
                        } else {
                            loginListener.onLoginFailed(tm_response.message);
                        }
                    } else {
                        loginListener.onLoginFailed("postResponse failed");
                    }
                }
            }
        });
    }

    public void verifyUserEmailInBackground(final String str_email, final TM_LoginListener loginListener) {
        final Map<String, String> params = new HashMap<>();
        params.put("user_emailID", DataHelper.encrypt(str_email));
        NetworkRequest.makeCommonPostRequest(url_verify_user_email, params, null, new NetworkResponse.ResponseListener() {
            @Override
            public void onResponseReceived(NetworkResponse postResponse) {
                if (loginListener != null) {
                    if (postResponse.succeed) {
                        DataHelper.log("-- onResponse:[" + postResponse.msg + "] --");
                        TM_Response tm_response = DataHelper.parseJsonAndCreateTMResponse(postResponse.msg);
                        if (tm_response.status) {
                            loginListener.onLoginSuccess(tm_response.message);
                        } else {
                            loginListener.onLoginFailed(tm_response.message);
                        }
                    } else {
                        loginListener.onLoginFailed("postResponse failed");
                    }
                }
            }
        });
    }

    public void resetPasswordAfterOtp(final String str_email, final String str_user_pass_new, final TM_LoginListener loginListener) {
        final Map<String, String> params = new HashMap<>();
        params.put("user_emailID", DataHelper.encrypt(str_email));
        params.put("user_pass_new", DataHelper.encrypt(str_user_pass_new));
        NetworkRequest.makeCommonPostRequest(url_reset_mobile_email_password, params, null, new NetworkResponse.ResponseListener() {
            @Override
            public void onResponseReceived(NetworkResponse postResponse) {
                if (loginListener != null) {
                    if (postResponse.succeed) {
                        DataHelper.log("-- onResponse:[" + postResponse.msg + "] --");
                        TM_Response tm_response = DataHelper.parseJsonAndCreateTMResponse(postResponse.msg);
                        if (tm_response.status) {
                            loginListener.onLoginSuccess(tm_response.message);
                        } else {
                            loginListener.onLoginFailed(tm_response.message);
                        }
                    } else {
                        loginListener.onLoginFailed("postResponse failed");
                    }
                }
            }
        });
    }

    public void signInWebUsing(final String email, final String password, final TM_LoginListener loginListener) {
        final Map<String, String> params = new HashMap<>();
        params.put("user_emailID", DataHelper.encrypt(email));
        params.put("user_pass", DataHelper.encrypt(password));
        params.put("user_platform", DataHelper.encrypt("Android"));
        NetworkRequest.makeCommonPostRequest(url_signin, params, null, new NetworkResponse.ResponseListener() {
            @Override
            public void onResponseReceived(NetworkResponse postResponse) {
                if (loginListener != null) {
                    if (postResponse.succeed) {
                        DataHelper.log("-- DataEngine::signInWebUsing response: [" + postResponse.msg + "] --");
                        TM_Response tm_response = DataHelper.parseJsonAndCreateTMResponse(postResponse.msg);
                        if (tm_response.status) {
                            loginListener.onLoginSuccess(tm_response.message);
                        } else {
                            loginListener.onLoginFailed(tm_response.message);
                        }
                    } else {
                        loginListener.onLoginFailed("Login failed");
                    }
                }
            }
        });
    }

    public String getBaseURL() {
        return baseURL;
    }

    protected boolean hasNetworkAccess(DataQueryHandler<?> dataQueryHandler) {
        if (!isNetworkAvailable()) {
            if (dataQueryHandler != null) {
                dataQueryHandler.onFailure(mNoConnectionError);
            }
            return false;
        }
        return true;
    }

    protected boolean didResponseSucceed(DataQueryHandler<?> dataQueryHandler, NetworkResponse response) {
        if (!response.succeed) {
            if (dataQueryHandler != null) {
                dataQueryHandler.onFailure(response.error);
            }
            return false;
        }
        return true;
    }

    public void getFrontPageContentInBackground(final DataQueryHandler dataQueryHandler) {
        final Map<String, String> params = new HashMap<>();
        //params.put("product_limit", "10");
        params.put("lang", DataHelper.encrypt(locale));
        params.put("post_status", DataHelper.encrypt("publish"));
        NetworkResponse.ResponseListener responseListener = response -> {
            if (DataEngine.isLogEnabled()) {
                DataHelper.log("-- getFrontPageContentInBackground-response: [" + response.msg + "] --");
            }

            if (response.succeed) {
                if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                    try {
                        parseJsonAndCreateFrontPageProducts(response.msg);
                        dataQueryHandler.onSuccess(null);
                    } catch (Exception e) {
                        e.printStackTrace();
                        dataQueryHandler.onFailure(new Exception("Error while loading products.."));
                    }
                }
            } else {
                dataQueryHandler.onFailure(response.error);
            }
        };
        NetworkRequest.makeCommonPostRequest(url_splash_products, params, null, responseListener);
    }

    public void fetchSellersInBackground(final DataQueryHandler dataQueryHandler) {
        Map<String, String> params = new HashMap<>();
        params.put("show_zero_seller", DataHelper.encrypt("0"));
        NetworkResponse.ResponseListener responseListener = response -> {
            if (response.succeed) {
                if (WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                    return;
                }
                dataQueryHandler.onSuccess(WooCommerceJSONHelper.parseJsonAndCreateVendors(response.msg));
            } else {
                dataQueryHandler.onFailure(response.error);
            }
        };
        NetworkRequest.makeCommonPostRequest(url_seller_list, params, null, responseListener);
    }

    public void fetchSellerInBackground(int sellerId, final DataQueryHandler dataQueryHandler) {
        Map<String, String> params = new HashMap<>();
        params.put("seller_id", DataHelper.encrypt(String.valueOf(sellerId)));
        params.put("type", DataHelper.encrypt("view"));
        NetworkResponse.ResponseListener responseListener = response -> {
            if (response.succeed) {
                if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                    dataQueryHandler.onSuccess(response.msg);
                }
            } else {
                dataQueryHandler.onFailure(response.error);
            }
        };
        NetworkRequest.makeCommonPostRequest(url_seller_info, params, null, responseListener);
    }

    public void updateSellerInBackground(final DataQueryHandler dataQueryHandler, HashMap<String, String> params) {
        NetworkResponse.ResponseListener responseListener = response -> {
            if (response.succeed) {
                if (WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                    return;
                }
                dataQueryHandler.onSuccess(response.msg);
            } else {
                dataQueryHandler.onFailure(response.error);
            }
        };
        NetworkRequest.makeCommonPostRequest(url_seller_info, DataHelper.encrypt(params), null, responseListener);
    }

    public void getFrontPageContentInBackground(String sellerId, final DataQueryHandler dataQueryHandler) {
        Map<String, String> params = new HashMap<>();
        params.put("seller_id", DataHelper.encrypt(sellerId));
        params.put("lang", DataHelper.encrypt(locale));
        params.put("post_status", DataHelper.encrypt("publish"));
        NetworkResponse.ResponseListener responseListener = response -> {
            if (response.succeed) {
                if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                    try {
                        parseJsonAndCreateFrontPageProducts(response.msg);
                        dataQueryHandler.onSuccess(null);
                    } catch (Exception e) {
                        e.printStackTrace();
                        dataQueryHandler.onFailure(new Exception("Error while loading products.."));
                    }
                }
            } else {
                dataQueryHandler.onFailure(response.error);
            }
        };
        NetworkRequest.makeCommonPostRequest(url_frontpage_content_seller, params, null, responseListener);
    }

    public void getInitialProductsInBackground(final DataQueryHandler dataQueryHandler) {
        Map<String, String> params = new HashMap<>();
        params.put("product_limit", String.valueOf(max_initial_products_query_limit));
        params.put("lang", DataHelper.encrypt(locale));
        NetworkResponse.ResponseListener responseListener = response -> {
            if (DataEngine.isLogEnabled()) {
                DataHelper.log("-- getInitialProductsInBackground::onResponseReceived:[" + response.msg + "] --");
            }
            if (response.succeed) {
                if (WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                    return;
                }
                try {
                    parseJsonAndCreateInitialProducts(response.msg);
                    dataQueryHandler.onSuccess(null);
                } catch (Exception e) {
                    e.printStackTrace();
                    dataQueryHandler.onFailure(new Exception("Error while loading products.."));
                }
            } else {
                dataQueryHandler.onFailure(response.error);
            }
        };
        NetworkRequest.makeCommonPostRequest(url_load_products, params, null, responseListener);
    }


    public void getInitialProductsInBackground(String sellerId, final DataQueryHandler dataQueryHandler) {
        Map<String, String> params = new HashMap<>();
        params.put("seller_id", DataHelper.encrypt(sellerId));
        if (locale.length() != 0) {
            params.put("lang", DataHelper.encrypt(locale));
        }
        NetworkResponse.ResponseListener responseListener = response -> {
            DataHelper.log("-- getInitialProductsInBackground::onResponseReceived:[" + response.msg + "] --");
            if (response.succeed) {
                if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                    try {
                        parseJsonAndCreateInitialProducts(response.msg);
                        dataQueryHandler.onSuccess(null);
                    } catch (Exception e) {
                        e.printStackTrace();
                        dataQueryHandler.onFailure(new Exception("Error while loading products.."));
                    }
                }
            } else {
                dataQueryHandler.onFailure(response.error);
            }
        };
        NetworkRequest.makeCommonPostRequest(url_seller_load_products, params, null, responseListener);
    }


    public void refineCategories() {
        DataHelper.log("-- refineCategories --");
        List<TM_CategoryInfo> categoriesToDelete = new ArrayList<>();
        for (TM_CategoryInfo category : TM_CategoryInfo.getAll()) {
            if (category.getCompleteProductCountIncludingSubCategories() <= 0) {
                //category = null;
                categoriesToDelete.add(category);
            }
        }

        for (TM_CategoryInfo category : categoriesToDelete) {
            TM_CategoryInfo.remove(category);
        }
        TM_CategoryInfo.clearRoots();
        categoriesToDelete.clear();
    }

    public void stepUpSingleChildrenCategories() {
        DataHelper.log("-- stepUpSingleChildrenCategories --");
        for (TM_CategoryInfo category : TM_CategoryInfo.getAll()) {
            if (category != null && category.getSubCategories().size() == 1 && category.getStrictProductCount() == 0) {
                TM_CategoryInfo c = category.getSubCategories().get(0);
                if (c != null) {
                    category.childrens.remove(c);
                    c.parent = category.parent;
                    refineCategories();
                    return;
                }
            }
        }
    }

    public void adjustCategoryThumbs() {
        DataHelper.log("-- adjustCategoryThumbs --");
        for (TM_CategoryInfo category : TM_CategoryInfo.getAll()) {
            if (category.image == null || category.image.equals("")) {
                List<TM_ProductInfo> tempList = TM_ProductInfo.getAllForCategory(category);
                for (int i = tempList.size() - 1; i >= 0; i--) {
                    TM_ProductInfo product = tempList.get(i);
                    if (product.hasThumb()) {
                        category.image = product.thumb;
                        break;
                    }
                }
            }
        }
    }

    public List<TM_ProductInfo> parseJsonAndCreateProducts(String jsonStringContent) {
        DataHelper.log("-- parseJsonAndCreateProducts: [" + jsonStringContent + "] --");
        JSONObject jMainObject = null;
        List<TM_ProductInfo> list_products = new ArrayList<>();
        try {
            jMainObject = DataHelper.safeJsonObject(jsonStringContent);
            JSONArray products = jMainObject.getJSONArray("products");
            for (int i = 0; i < products.length(); i++) {
                list_products.add(WooCommerceJSONHelper.parseFullProduct(products.getJSONObject(i)));
            }
        } catch (JSONException je) {
            je.printStackTrace();
        }
        return list_products;
    }

    public void parseJsonAndCreateInitialProducts(String jsonStringContent) throws Exception {
        DataHelper.log("-- parseJsonAndCreateInitialProducts: [" + jsonStringContent + "] --");
        JSONArray jMainObject = DataHelper.safeJsonArray(jsonStringContent);
        for (int i = 0; i < jMainObject.length(); i++) {
            JSONObject comboObject = jMainObject.getJSONObject(i);
            int categoryId = comboObject.getJSONObject("category").getInt("id");
            JSONArray productsJson = comboObject.getJSONArray("products");
            for (int j = 0; j < productsJson.length(); j++) {
                TM_ProductInfo productInfo = WooCommerceJSONHelper.parseRawProduct(productsJson.getJSONObject(j));
                productInfo.putInCategory(categoryId);
            }
        }
    }

    public List<TM_ProductInfo> parseJsonAndCreatePollProducts(String jsonStringContent) throws Exception {
        DataHelper.log("-- parseJsonAndCreatePollProducts: [" + jsonStringContent + "] --");
        List<TM_ProductInfo> pollProducts = new ArrayList<>();
        jsonStringContent = jsonStringContent.substring(jsonStringContent.indexOf("["), jsonStringContent.lastIndexOf("]") + 1);
        JSONArray jMainObject = new JSONArray(jsonStringContent);
        for (int i = 0; i < jMainObject.length(); i++) {
            JSONObject productsJson = jMainObject.getJSONObject(i);
            TM_ProductInfo productInfo = WooCommerceJSONHelper.parseRawProduct(productsJson);
            productInfo.has_poll = true;
            pollProducts.add(productInfo);
        }
        DataHelper.log("-- parseJsonAndCreatePollProducts: DONE] --");
        return pollProducts;
    }

    public List<TM_SimpleCart> parseJsonAndCreateSimpleCartProducts(String jsonStringContent) {
        try {
            List<TM_SimpleCart> simpleCarts = new ArrayList<>();
            JSONArray jsonArray = new JSONArray(jsonStringContent);
            for (int i = 0; i < jsonArray.length(); i++) {
                TM_SimpleCart simpleCart = WooCommerceJSONHelper.parseJsonAndCreateSimpleCart(jsonArray.getJSONObject(i));
                simpleCarts.add(simpleCart);
            }
            return simpleCarts;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    public List<TM_ProductInfo> parseJsonAndCreateFilterProducts(List<TM_FilterAttribute> filterAttributes, String jsonStringContent) throws Exception {
        DataHelper.log("-- parseJsonAndCreateFilterProducts: [" + jsonStringContent + "] --");
        jsonStringContent = jsonStringContent.substring(jsonStringContent.indexOf("["), jsonStringContent.lastIndexOf("]") + 1);
        JSONArray jMainArray = new JSONArray(jsonStringContent);
        List<TM_ProductInfo> list_products = new ArrayList<>();

        for (int i = 0; i < jMainArray.length(); i++) {
            JSONObject jsonObject = jMainArray.getJSONObject(i);
            TM_ProductInfo product = WooCommerceJSONHelper.parseRawProduct(jsonObject);
            if (!product.full_data_loaded) {
                for (TM_FilterAttribute filterAttribute : filterAttributes) {
                    product.addAttribute(filterAttribute.getProductAttribute());
                }
            }
            list_products.add(product);
        }

        return list_products;
    }

    public void parseJsonAndCreateFrontPageProducts(String jsonString) throws Exception {
        DataHelper.log("-- parseJsonAndCreateFrontPageProducts: [" + jsonString + "] --");
        JSONObject jMainObject = DataHelper.safeJsonObject(jsonString);
        //par 1 - Metadata hack // to reduce common data query
        {
            JSONObject meta_data = jMainObject.getJSONObject("meta_data");
            WooCommerceJSONHelper.parseCommonInfoFromJsonString(meta_data);
        }

        //par 2 - actual purpose of this query
        {
            JSONArray category = jMainObject.getJSONArray("category");
            for (int i = 0; i < category.length(); i++) {
                TM_CategoryInfo categoryInfo = WooCommerceJSONHelper.parseRawCategory(category.getJSONObject(i));
                DataHelper.log("-- FrontPageProducts::found Category [" + categoryInfo.id + "][" + categoryInfo.getName() + "] ---");
            }

            if (stepup_single_child_categories) {
                stepUpSingleChildrenCategories();
            }

            if (refine_categories) {
                refineCategories();
            }
        }

        //par 3 - hack to show smooth home page

        if (!TM_ProductInfo.bestDealProductsIds.isEmpty())
            TM_ProductInfo.bestDealProductsIds.clear();

        if (!TM_ProductInfo.freshArrivalProductsIds.isEmpty())
            TM_ProductInfo.freshArrivalProductsIds.clear();

        if (!TM_ProductInfo.trendingProductsIds.isEmpty())
            TM_ProductInfo.trendingProductsIds.clear();

        try {
            JSONArray best_selling = jMainObject.getJSONArray("best_selling");
            for (int i = 0; i < best_selling.length(); i++) {
                TM_ProductInfo.bestDealProductsIds.add(WooCommerceJSONHelper.parseHomepageProduct(best_selling.getJSONObject(i)));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        try {
            JSONArray new_arrivals = jMainObject.getJSONArray("new_arrivals");
            for (int i = 0; i < new_arrivals.length(); i++) {
                TM_ProductInfo.freshArrivalProductsIds.add(WooCommerceJSONHelper.parseHomepageProduct(new_arrivals.getJSONObject(i)));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        try {
            JSONArray new_sales = jMainObject.getJSONArray("new_sales");
            for (int i = 0; i < new_sales.length(); i++) {
                TM_ProductInfo.trendingProductsIds.add(WooCommerceJSONHelper.parseHomepageProduct(new_sales.getJSONObject(i)));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public List<TM_ProductInfo> parseJsonAndCreateShortProducts(String jsonStringContent) throws Exception {
        List<TM_ProductInfo> list_products = new ArrayList<>();
        JSONArray productsArray = DataHelper.safeJsonArray(jsonStringContent);
        for (int i = 0; i < productsArray.length(); i++) {
            list_products.add(WooCommerceJSONHelper.parseHomepageProduct(productsArray.getJSONObject(i)));
        }
        return list_products;
    }

    public List<TM_ProductInfo> parseJsonAndCreateProductsSecure(TM_CategoryInfo category, String jsonStringContent) throws Exception {
        DataHelper.log("-- parseJsonAndCreateProducts: [" + jsonStringContent + "] --");
        List<TM_ProductInfo> list_products = new ArrayList<>();

        JSONObject jMainObject = DataHelper.safeJsonObject(jsonStringContent, "products");
        JSONArray products = jMainObject.getJSONArray("products");

        for (int i = 0; i < products.length(); i++) {
            TM_ProductInfo product = WooCommerceJSONHelper.parseFullProduct(products.getJSONObject(i));
            if (category != null && DataEngine.show_child_cat_products_in_parent_cat) {
                product.putInCategory(category);
                //list_products.add(product);
            }
            if (product.isInCategory(category)) {
                list_products.add(product);
            }
        }
        return list_products;
    }

//    public void getCouponsListCountInBackground(final DataQueryHandler dataQueryHandler) {
//        if (!DataHelper.isNetworkAvailable()) {
//            if (dataQueryHandler != null) {
//                dataQueryHandler.onFailure(mNoConnectionError);
//            }
//            return;
//        }
//
//        NetworkRequest.makeOauthGetRequest(url_coupons + "count", null, new NetworkResponse.ResponseListener() {
//            @Override
//            public void onResponseReceived(NetworkResponse response) {
//                if (response.succeed) {
//                    DataHelper.log("-- getCouponsListCountInBackground::onRequestCompleted : [" + response.msg + "]--");
//
//                    if (WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
//                        return;
//                    }
//
//                    try {
//                        JSONObject jMainObject = DataHelper.safeJsonObject(response.msg);
//                        int coupon_count = jMainObject.getInt("count");
//
//                        dataQueryHandler.onSuccess(coupon_count);
//                    } catch (Exception ex) {
//                        ex.printStackTrace();
//                        dataQueryHandler.onFailure(ex);
//                    }
//                } else {
//                    dataQueryHandler.onFailure(response.error);
//                }
//            }
//        });
//    }

    public void getCouponsInBackground(final DataQueryHandler dataQueryHandler) {
        if (hasNetworkAccess(dataQueryHandler)) {
            Map<String, String> params = new HashMap<>();
            params.put("filter[limit]", "200");
            NetworkRequest.makeOauthGetRequest(url_coupons, params, response -> {
                if (response.succeed) {
                    DataHelper.log("-- getCouponsInBackground::onRequestCompleted : [" + response.msg + "]--");
                    if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                        try {
                            dataQueryHandler.onSuccess(parseJsonAndCreateCoupons(response.msg));
                        } catch (Exception ex) {
                            ex.printStackTrace();
                            dataQueryHandler.onFailure(ex);
                        }
                    }
                } else {
                    dataQueryHandler.onFailure(response.error);
                }
            });
        }
    }

    public void getCouponInfoInBackground(String couponCode, final DataQueryHandler<TM_Coupon> dataQueryHandler) {
        if (hasNetworkAccess(dataQueryHandler)) {
            NetworkRequest.makeOauthGetRequest(url_coupons_code + couponCode, null, new NetworkResponse.ResponseListener() {
                @Override
                public void onResponseReceived(NetworkResponse response) {
                    if (response.succeed) {
                        DataHelper.log("-- getCouponByCodeInBackground::onRequestCompleted : [" + response.msg + "]--");
                        if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                            try {
                                dataQueryHandler.onSuccess(parseJsonAndCreateSingleCoupon(response.msg));
                            } catch (Exception ex) {
                                ex.printStackTrace();
                                dataQueryHandler.onFailure(ex);
                            }
                        }
                    } else {
                        dataQueryHandler.onFailure(response.error);
                    }
                }
            });
        }
    }

    public void getFilterPricesInBackground(final DataQueryHandler dataQueryHandler) {
        if (!isNetworkAvailable()) {
            if (dataQueryHandler != null) {
                dataQueryHandler.onFailure(mNoConnectionError);
            }
            return;
        }

        String filterLimit = "200";
        List categories = TM_CategoryInfo.getAll();
        if (categories != null) {
            filterLimit = String.valueOf(categories.size());
        }

        Map<String, String> params = new HashMap<>();
        params.put("filter[limit]", filterLimit);
        params.put("lang", DataHelper.encrypt(locale));

        NetworkRequest.makeCommonPostRequest(url_filterdata_prices, params, null, new NetworkResponse.ResponseListener() {
            @Override
            public void onResponseReceived(NetworkResponse response) {
                if (response.succeed) {
                    DataHelper.log("-- getFilterPricesInBackground::onRequestCompleted : [" + response.msg + "]--");
                    if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                        try {
                            dataQueryHandler.onSuccess(parseJsonAndCreateFilterPrices(response.msg));
                        } catch (Exception ex) {
                            ex.printStackTrace();
                            dataQueryHandler.onFailure(ex);
                        }
                    }
                } else {
                    dataQueryHandler.onFailure(response.error);
                }
            }
        });
    }

    public void getFilterAttributesInBackground(final DataQueryHandler dataQueryHandler) {
        if (!isNetworkAvailable()) {
            if (dataQueryHandler != null) {
                dataQueryHandler.onFailure(mNoConnectionError);
            }
            return;
        }

        String filterLimit = "200";
        List categories = TM_CategoryInfo.getAll();
        if (categories != null) {
            filterLimit = String.valueOf(categories.size());
        }

        Map<String, String> params = new HashMap<>();
        params.put("filter[limit]", filterLimit);
        params.put("lang", DataHelper.encrypt(locale));

        NetworkRequest.makeCommonPostRequest(url_filterdata_attributes, params, null, new NetworkResponse.ResponseListener() {
            @Override
            public void onResponseReceived(NetworkResponse response) {
                if (response.succeed) {
                    DataHelper.log("-- getFilterAttributesInBackground::onRequestCompleted : [" + response.msg + "]--");
                    if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                        try {
                            TM_ProductFilter.attribsLoaded = true;
                            dataQueryHandler.onSuccess(parseJsonAndCreateFilterAttributes(response.msg));
                        } catch (Exception ex) {
                            ex.printStackTrace();
                            TM_ProductFilter.attribsLoaded = false;
                            dataQueryHandler.onFailure(ex);
                        }
                    }

                } else {
                    dataQueryHandler.onFailure(response.error);
                }
            }
        });
    }

    public void getFiltersByCategoryInBackground(int categoryId, final DataQueryHandler dataQueryHandler) {
        if (hasNetworkAccess(dataQueryHandler)) {
            Map<String, String> params = new HashMap<>();
            params.put("category_id", DataHelper.encrypt(categoryId));
            params.put("lang", DataHelper.encrypt(locale));
            NetworkRequest.makeCommonPostRequest(url_filter_price_attribute, params, null, response -> {
                if (response.succeed) {
                    DataHelper.log("-- getFiltersByCategoryInBackground::onResponseReceived : [" + response.msg + "]--");
                    if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                        try {
                            TM_ProductFilter.attribsLoaded = true;
                            parseJsonAndCreateFilterPricesAttributes(response.msg);
                            dataQueryHandler.onSuccess(null);
                        } catch (Exception ex) {
                            ex.printStackTrace();
                            TM_ProductFilter.attribsLoaded = false;
                            dataQueryHandler.onFailure(ex);
                        }
                    }

                } else {
                    dataQueryHandler.onFailure(response.error);
                }
            });
        }
    }

    public void getWordPressMenuItemsAsync(final DataQueryHandler dataQueryHandler) {
        if (hasNetworkAccess(dataQueryHandler)) {
            NetworkRequest.makeOauthGetRequest(url_menu_data, null, new NetworkResponse.ResponseListener() {
                @Override
                public void onResponseReceived(NetworkResponse response) {
                    if (response.succeed) {
                        if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                            try {
                                dataQueryHandler.onSuccess(parseAndCreateMenuItems(response.msg));
                            } catch (Exception e) {
                                e.printStackTrace();
                                dataQueryHandler.onFailure(e);
                            }
                        }
                    } else {
                        dataQueryHandler.onFailure(response.error);
                    }
                }
            });
        }
    }

    public void getShipmentTrackingData(final String type, final List<TM_Order> ordersList, final DataQueryHandler dataQueryHandler) {
        if (hasNetworkAccess(dataQueryHandler)) {
            Map<String, String> params = new HashMap<>();
            params.put("ship_type", DataHelper.encrypt(type));
            params.put("order_ids", DataHelper.encrypt(DataHelper.getOrderIdJSONString(ordersList)));

            NetworkRequest.makeCommonPostRequest(url_shipment_track, params, null, new NetworkResponse.ResponseListener() {
                @Override
                public void onResponseReceived(NetworkResponse response) {
                    if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                        dataQueryHandler.onSuccess(response.msg);
                    }
                }
            });
        }
    }

    public void getProductsOfCategory(int categoryId, final DataQueryHandler dataQueryHandler) {
        if (DataEngine.use_plugin_for_pagging) {
            getProductsOfCategoryFast(categoryId, 0, max_products_query_count_limit, dataQueryHandler);
            return;
        }

        DataHelper.log("-- WooCommerceEngine::getProductsOfCategory(" + categoryId + ") --");
        if (!isNetworkAvailable()) {
            if (dataQueryHandler != null) {
                dataQueryHandler.onFailure(mNoConnectionError);
            }
            return;
        }

        final TM_CategoryInfo category = TM_CategoryInfo.getWithId(categoryId);
        if (category == null) {
            if (dataQueryHandler != null) {
                dataQueryHandler.onFailure(new Exception("No such category.."));
            }
            return;
        }

        Map<String, String> params = new HashMap<>();
        params.put("filter[category]", category.slug);
        params.put("filter[limit]", String.valueOf(max_products_query_count_limit));
        //params.put("filter[orderby]", "menu_order"));
        //params.put("filter[order]", "ASC"));
        //OAuthRequest.setLogEnabled(true);
        if (locale.length() != 0) {
            params.put("filter[lang]", locale);
        }
        NetworkRequest.makeOauthGetRequest(url_products, params, new NetworkResponse.ResponseListener() {
            @Override
            public void onResponseReceived(NetworkResponse response) {
                if (response.succeed) {
                    DataHelper.log("-- getProductsOfCategory::onRequestCompleted 1 --");
                    if (WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                        return;
                    }
                    try {
                        List<TM_ProductInfo> listProducts = parseJsonAndCreateProductsSecure(category, response.msg);
                        //refineCategories();
                        adjustCategoryThumbs();
                        //TM_ProductInfo.printAll();
                        DataHelper.log("*** found [" + listProducts.size() + "] products from REST api ***");
                        category.isProductRefreshed = true;
                        dataQueryHandler.onSuccess(listProducts);
                        //OAuthRequest.setLogEnabled(false);
                    } catch (Exception ex) {
                        ex.printStackTrace();
                        dataQueryHandler.onFailure(ex);
                        return;
                    }
                } else {
                    dataQueryHandler.onFailure(response.error);
                }
            }
        });
    }


    public void getProductsOfCategory(int categoryId, int skipProductsCount, int pageIndex, int maxProducts, final DataQueryHandler dataQueryHandler) {
        if (DataEngine.use_plugin_for_pagging) {
            getProductsOfCategoryFast(categoryId, skipProductsCount, maxProducts, dataQueryHandler);
            return;
        }

        DataHelper.log("-- WooCommerceEngine::getProductsOfCategory(" + categoryId + ") skipProductsCount: (" + skipProductsCount + ") pageIndex: (" + pageIndex + ") maxProducts: (" + maxProducts + ")  --");
        if (!isNetworkAvailable()) {
            if (dataQueryHandler != null) {
                dataQueryHandler.onFailure(mNoConnectionError);
            }
            return;
        }

        final TM_CategoryInfo category = TM_CategoryInfo.getWithId(categoryId);
        if (category == null) {
            if (dataQueryHandler != null) {
                dataQueryHandler.onFailure(new Exception("No such category.."));
            }
            return;
        }

        Map<String, String> params = new HashMap<>();
        params.put("filter[category]", category.slug);
        params.put("filter[limit]", String.valueOf(maxProducts));
        params.put("page", String.valueOf(pageIndex));
        params.put("filter[offset]", String.valueOf(skipProductsCount));
        //params.put("filter[orderby]", "menu_order"));
        //params.put("filter[order]", "ASC"));
        if (locale.length() != 0) {
            params.put("filter[lang]", locale);
        }
        NetworkRequest.makeOauthGetRequest(url_products, params, new NetworkResponse.ResponseListener() {
            @Override
            public void onResponseReceived(NetworkResponse response) {
                if (response.succeed) {
                    DataHelper.log("-- getProductsOfCategory::onRequestCompleted 2 --");

                    if (WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                        return;
                    }

                    try {
                        List<TM_ProductInfo> listProducts = parseJsonAndCreateProductsSecure(category, response.msg);
                        //refineCategories();
                        adjustCategoryThumbs();
                        //TM_ProductInfo.printAll();
                        DataHelper.log("*** found [" + listProducts.size() + "] products from REST api ***");
                        category.isProductRefreshed = true;
                        dataQueryHandler.onSuccess(listProducts);
                        //OAuthRequest.setLogEnabled(false);
                    } catch (Exception ex) {
                        ex.printStackTrace();
                        dataQueryHandler.onFailure(ex);
                    }
                } else {
                    dataQueryHandler.onFailure(response.error);
                }
            }
        });
    }


    public void getProductsOfCategory(final int categoryId, String sellerId, int skipProductsCount, int maxProducts, final DataQueryHandler dataQueryHandler) {
        DataHelper.log("-- WooCommerceEngine::getProductsOfCategory(" + categoryId + ") for vendor(" + sellerId + ")--");
        if (hasNetworkAccess(dataQueryHandler)) {
            Map<String, String> params = new HashMap<>();
            params.put("seller_id", DataHelper.encrypt(sellerId));
            params.put("category_id", DataHelper.encrypt(categoryId));
            params.put("product_limit", DataHelper.encrypt(maxProducts));
            params.put("offset", DataHelper.encrypt(skipProductsCount));
            params.put("post_status", DataHelper.encrypt("all"));
            NetworkRequest.makeCommonPostRequest(url_seller_products, params, null, new NetworkResponse.ResponseListener() {
                @Override
                public void onResponseReceived(NetworkResponse response) {
                    if (response.succeed) {
                        if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                            try {
                                //List<TM_ProductInfo> listProducts = parseJsonAndCreateFrontPageProducts(response);
                                TM_CategoryInfo category = TM_CategoryInfo.getWithId(categoryId);
                                if (category != null) {
                                    category.isProductRefreshed = true;
                                }
                                // adjustCategoryThumbs(); // Quite Optional
                                dataQueryHandler.onSuccess(parseJsonAndCreateShortProducts(response.msg));
                            } catch (Exception e) {
                                e.printStackTrace();
                                dataQueryHandler.onFailure(new Exception("Error while loading products.."));
                            }
                        }
                    } else {
                        dataQueryHandler.onFailure(response.error);
                    }
                }
            });
        }
    }


    public void getSellerOrdersInBackground(String sellerId, final DataQueryHandler dataQueryHandler) {
        DataHelper.log("-- WooCommerceEngine::getSellerOrdersInBackground (" + sellerId + ")--");
        if (hasNetworkAccess(dataQueryHandler)) {
            Map<String, String> params = new HashMap<>();
            params.put("seller_id", DataHelper.encrypt(sellerId));
            NetworkRequest.makeCommonPostRequest(url_seller_orders, params, null, new NetworkResponse.ResponseListener() {
                @Override
                public void onResponseReceived(NetworkResponse response) {
                    if (response.succeed) {
                        if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                            try {
                                dataQueryHandler.onSuccess(WooCommerceJSONHelper.parseJsonAndCreateOrders(response.msg));
                            } catch (Exception e) {
                                e.printStackTrace();
                                dataQueryHandler.onFailure(new Exception("Error while loading products.."));
                            }
                        }
                    } else {
                        dataQueryHandler.onFailure(response.error);
                    }
                }
            });
        }
    }


    public void getOrderDeliverySlots(final List<TM_Order> orderList, final DataQueryHandler dataQueryHandler) {
        if (!isNetworkAvailable()) {
            if (dataQueryHandler != null) {
                dataQueryHandler.onFailure(mNoConnectionError);
            }
            return;
        }

        Map<String, String> params = new HashMap<>();
        params.put("type", DataHelper.encrypt("ordered_slot"));
        params.put("order_ids", DataHelper.encrypt(DataHelper.getOrderIdJSONString(orderList)));
        NetworkRequest.makeCommonPostRequest(url_order_delivery_slots, params, null, new NetworkResponse.ResponseListener() {
            @Override
            public void onResponseReceived(NetworkResponse response) {
                if (response.succeed) {
                    if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                        try {
                            WooCommerceJSONHelper.parseOrderDeliverySlots(response.msg, orderList);
                            dataQueryHandler.onSuccess(null);
                        } catch (Exception e) {
                            e.printStackTrace();
                            dataQueryHandler.onFailure(new Exception("Error while loading delivery slots"));
                        }
                    }
                } else {
                    dataQueryHandler.onFailure(response.error);
                }
            }
        });
    }

    public void postOrderDateTimeDeliverySlots(Map<String, String> params, final DataQueryHandler dataQueryHandler) {
        if (hasNetworkAccess(dataQueryHandler)) {
            DataHelper.log("-- WooCommerceEngine::postOrderDateTimeDeliverySlots (" + params + ")--");
            DataHelper.encrypt(params);
            NetworkRequest.makeCommonPostRequest(url_order_delivery_slots, params, null, new NetworkResponse.ResponseListener() {
                @Override
                public void onResponseReceived(NetworkResponse response) {
                    if (response.succeed) {
                        if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                            try {
                                dataQueryHandler.onSuccess(response.msg);
                            } catch (Exception e) {
                                e.printStackTrace();
                                dataQueryHandler.onFailure(new Exception("Error while loading delivery slots"));
                            }
                        }
                    } else {
                        dataQueryHandler.onFailure(response.error);
                    }
                }
            });
        }
    }


    public void assignProductToSellerInBackground(Map<String, String> params, final DataQueryHandler dataQueryHandler) {
        if (hasNetworkAccess(dataQueryHandler)) {
            NetworkRequest.makeCommonPostRequest(url_assign_seller_product, params, null, new NetworkResponse.ResponseListener() {
                @Override
                public void onResponseReceived(NetworkResponse response) {
                    if (response.succeed) {
                        if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                            if (response.msg.contains("success")) {
                                dataQueryHandler.onSuccess(null);
                            } else {
                                dataQueryHandler.onFailure(new Exception("Error while assigning products.."));
                            }
                        } else {
                            dataQueryHandler.onFailure(response.error);
                        }
                    }
                }
            });
        }
    }

    public void assignOrderToSellerInBackground(int orderId, final DataQueryHandler<Void> dataQueryHandler) {
        if (!hasNetworkAccess(dataQueryHandler)) {
            return;
        }
        Map<String, String> params = new HashMap<>();
        params.put("order_id", DataHelper.encrypt(orderId));
        NetworkResponse.ResponseListener responseListener = new NetworkResponse.ResponseListener() {
            @Override
            public void onResponseReceived(NetworkResponse response) {
                if (response.succeed) {
                    if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                        if (dataQueryHandler != null) {
                            dataQueryHandler.onSuccess(null);
                            return;
                        }
                    }
                }
                dataQueryHandler.onFailure(response.error);
            }
        };
        NetworkRequest.makeCommonPostRequest(url_assign_seller_order, params, null, responseListener);
    }

    public void getProductsOfCategoryFast(final int categoryId, int skipProductsCount, int maxProducts, final DataQueryHandler dataQueryHandler) {
        DataHelper.log("-- WooCommerceEngine::getProductsOfCategoryFast(" + categoryId + ") --");
        if (!isNetworkAvailable()) {
            if (dataQueryHandler != null) {
                dataQueryHandler.onFailure(mNoConnectionError);
            }
            return;
        }

        Map<String, String> params = new HashMap<>();
        params.put("category_id", DataHelper.encrypt(categoryId));
        params.put("product_limit", DataHelper.encrypt(maxProducts));
        params.put("offset", DataHelper.encrypt(skipProductsCount));

        NetworkResponse.ResponseListener responseListener = new NetworkResponse.ResponseListener() {
            @Override
            public void onResponseReceived(NetworkResponse response) {
                if (response.succeed) {
                    if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                        try {
                            //List<TM_ProductInfo> listProducts = parseJsonAndCreateFrontPageProducts(response);
                            TM_CategoryInfo category = TM_CategoryInfo.getWithId(categoryId);
                            category.isProductRefreshed = true;
                            List<TM_ProductInfo> list_products = parseJsonAndCreateShortProducts(response.msg);
                            category.officiallyLoadedProductsCount += list_products.size();
                            dataQueryHandler.onSuccess(list_products);
                        } catch (Exception e) {
                            e.printStackTrace();
                            dataQueryHandler.onFailure(new Exception("Error while loading products.."));
                        }
                    }
                } else {
                    dataQueryHandler.onFailure(response.error);
                }
            }
        };
        NetworkRequest.makeCommonPostRequest(url_products_fast, params, null, responseListener);
    }


    public void getProductsWithTag(String tag, final DataQueryHandler dataQueryHandler) {
        getProductsWithTag(0, 0, tag, dataQueryHandler);
    }

    public void getProductsWithTag(int pageIndex, int skipCount, String tag, final DataQueryHandler dataQueryHandler) {
        DataHelper.log("-- WooCommerceEngine::getProductsWithTag(" + tag + ") --");
        if (!isNetworkAvailable()) {
            if (dataQueryHandler != null) {
                dataQueryHandler.onFailure(mNoConnectionError);
            }
            return;
        }

        if (DataEngine.use_plugin_for_pagging) {
            searchProductsUsingPlugin(max_search_products_query_count_limit, skipCount, tag, dataQueryHandler);
            return;
        }

        try {
            tag = URLEncoder.encode(tag, "UTF-8");
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }

        Map<String, String> params = new HashMap<>();
        params.put("filter[limit]", max_search_products_query_count_limit + "");
        params.put("page", pageIndex + "");
        params.put("filter[offset]", skipCount + "");
        params.put("filter[q]", tag);
        params.put("lang", DataHelper.encrypt(locale));
        NetworkRequest.makeOauthGetRequest(url_products, params, new NetworkResponse.ResponseListener() {
            @Override
            public void onResponseReceived(NetworkResponse response) {
                if (response.succeed) {
                    DataHelper.log("-- getProductsWithTag::onRequestCompleted 1 --");
                    if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                        try {
                            dataQueryHandler.onSuccess(parseJsonAndCreateProducts(response.msg));
                        } catch (Exception ex) {
                            ex.printStackTrace();
                            dataQueryHandler.onFailure(ex);
                        }
                    }
                } else {
                    dataQueryHandler.onFailure(response.error);
                }
            }
        });
    }

    private void searchProductsUsingPlugin(int max_search_products_query_count_limit, int skipCount, String tag, final DataQueryHandler dataQueryHandler) {
        Map<String, String> params = new HashMap<>();
        params.put("limit", DataHelper.encrypt(max_search_products_query_count_limit));
        params.put("offset", DataHelper.encrypt(skipCount));
        params.put("q", DataHelper.encrypt(tag));
        params.put("lang", DataHelper.encrypt(locale));

        NetworkRequest.makeCommonPostRequest(url_search_products, params, null, new NetworkResponse.ResponseListener() {
            @Override
            public void onResponseReceived(NetworkResponse response) {
                if (response.succeed) {
                    DataHelper.log("-- searchProductsUsingPlugin::onRequestCompleted 1 --");
                    if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                        try {
                            dataQueryHandler.onSuccess(parseJsonAndCreateProducts(response.msg));
                        } catch (Exception ex) {
                            ex.printStackTrace();
                            dataQueryHandler.onFailure(ex);
                        }
                    }
                } else {
                    dataQueryHandler.onFailure(response.error);
                }
            }
        });
    }


    public void getProductsByFilter(final UserFilter userFilter, final DataQueryHandler dataQueryHandler) {
        DataHelper.log("-- WooCommerceEngine::getProductsByFilter --");
        Gson gson = new Gson();
        String filterString = gson.toJson(userFilter); //.replaceAll("\"slugs\"","\"taxo\"");
        //filterString = TextUtils.htmlEncode(filterString);

        Map<String, String> params = new HashMap<>();
        params.put("filter_data", filterString);
        params.put("products_required", String.valueOf(1));
        //params.put("lang", DataHelper.encrypt(locale));
        //DataHelper.log("--- params (getProductsByFilter) ----");
        //DataHelper.log("--- filter_data : [" + filterString + "] ----");
        //DataHelper.log("--- products_required : [" + 1 + "] ----");

        DataHelper.log("-- getProductsByFilter::onPostData [" + filterString + "] --");

        NetworkRequest.makeCommonPostRequest(url_filter_products, params, null, new NetworkResponse.ResponseListener() {
            @Override
            public void onResponseReceived(NetworkResponse response) {
                DataHelper.log("-- getProductsByFilter::onResponse [" + response.msg + "] --");
                if (WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                    return;
                }
                try {
                    dataQueryHandler.onSuccess(parseJsonAndCreateFilterProducts(userFilter.getAttributes(), response.msg));
                } catch (Exception ex) {
                    ex.printStackTrace();
                    dataQueryHandler.onFailure(ex);
                }
            }
        });
    }

    public void getProductsByFilterTest(String categorySlug, final DataQueryHandler<String> dataQueryHandler) {
        DataHelper.log("-- WooCommerceEngine::getProductsByFilterTest --");
        Map<String, String> params = new HashMap<>();
        params.put("products_required", String.valueOf(0));
        try {
            JSONObject jsonObject = new JSONObject();
            jsonObject.put("attributes", new JSONArray());
            jsonObject.put("cat_slug", categorySlug);
            params.put("filter_data", jsonObject.toString());
        } catch (JSONException e) {
            e.printStackTrace();
        }
        NetworkRequest.makeCommonPostRequest(url_filter_products, params, null, new NetworkResponse.ResponseListener() {
            @Override
            public void onResponseReceived(NetworkResponse response) {
                DataHelper.log("-- getProductsByFilterTest::onResponse [" + response.msg + "] --");
                if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                    try {
                        dataQueryHandler.onSuccess(response.msg);
                    } catch (Exception ex) {
                        ex.printStackTrace();
                        dataQueryHandler.onFailure(ex);
                    }
                }
            }
        });
    }


    public void getFilterByFilter(UserFilter userFilter, final DataQueryHandler dataQueryHandler) {
        DataHelper.log("-- WooCommerceEngine::getFilterByFilter --");

        final UserFilter userFilterTemp = new UserFilter(userFilter.getCatSlug(), userFilter.getMinPrice(), userFilter.getMaxPrice(), new ArrayList<TM_FilterAttribute>(), userFilter.chkStock);
        for (TM_FilterAttribute attribute : userFilter.getAttributes()) {
            if (!attribute.options.isEmpty()) {
                userFilterTemp.addAttribute(attribute);
            }
        }

        String filterString = new Gson().toJson(userFilterTemp);

        Map<String, String> params = new HashMap<>();
        params.put("filter_data", filterString);
        params.put("products_required", 0 + "");

        NetworkRequest.makeCommonPostRequest(url_filter_products, params, null, new NetworkResponse.ResponseListener() {
            @Override
            public void onResponseReceived(NetworkResponse response) {
                DataHelper.log("-- getFilterByFilter::onResponse [" + response.msg + "] --");
                if (WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                    return;
                }

                try {
                    dataQueryHandler.onSuccess(WooCommerceJSONHelper.parseComparableFilterFromJson(response.msg));
                } catch (Exception ex) {
                    ex.printStackTrace();
                    dataQueryHandler.onFailure(ex);
                }
            }
        });
    }


    public List<TM_CategoryInfo> parseJsonAndCreateCategories(String jsonStringContent) {
        DataHelper.log("-- parseJsonAndCreateCategories  " + jsonStringContent + " \n--");
        JSONObject jMainObject = null;
        List<TM_CategoryInfo> list_categories = new ArrayList<>();
        try {
            jMainObject = DataHelper.safeJsonObject(jsonStringContent);
            JSONArray categories = jMainObject.getJSONArray("product_categories");
            for (int i = 0; i < categories.length(); i++) {
                JSONObject categoryInfoJson = categories.getJSONObject(i);
                list_categories.add(WooCommerceJSONHelper.parseCategory(categoryInfoJson));
            }
        } catch (JSONException je) {
            je.printStackTrace();
        }

        try {
            if (list_categories.size() > 0) {
                Collections.sort(list_categories, new Comparator<TM_CategoryInfo>() {
                    @Override
                    public int compare(final TM_CategoryInfo object1, final TM_CategoryInfo object2) {
                        return (object1.tempSlugDigit - object2.tempSlugDigit); //object1.getName().compareTo(object2.getName());
                    }
                });
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list_categories;
    }

    public List<TM_Coupon> parseJsonAndCreateCoupons(String jsonStringContent) throws Exception {
        DataHelper.log("-- parseJsonAndCreateCoupons  " + jsonStringContent + " \n--");
        JSONObject jMainObject = DataHelper.safeJsonObject(jsonStringContent);
        JSONArray coupons = jMainObject.getJSONArray("coupons");
        for (int i = 0; i < coupons.length(); i++) {
            JSONObject couponsInfoJson = coupons.getJSONObject(i);
            TM_Coupon tm_coupon = TM_Coupon.getWithCode(couponsInfoJson.getString("code"));
            if (tm_coupon == null) {
                TM_Coupon coupon = WooCommerceJSONHelper.parseCoupon(couponsInfoJson);
                coupon.register();
            }
        }
        return TM_Coupon.getAll();
    }

    public TM_Coupon parseJsonAndCreateSingleCoupon(String jsonStringContent) throws Exception {
        DataHelper.log("-- parseJsonAndCreateSingleCoupon  " + jsonStringContent + " \n--");
        JSONObject jMainObject = DataHelper.safeJsonObject(jsonStringContent);
        JSONObject coupons = jMainObject.getJSONObject("coupon");
        TM_Coupon coupon = WooCommerceJSONHelper.parseCoupon(coupons);
        coupon.register();
        return coupon;
    }

    public List<TM_ProductFilter> parseJsonAndCreateFilterPrices(String jsonStringContent) throws Exception {
        DataHelper.log("-- parseJsonAndCreateFilterPrices  [" + jsonStringContent + "] \n--");
        JSONObject jMainObject = DataHelper.safeJsonObject(jsonStringContent);
        JSONArray cat_price_range = jMainObject.getJSONArray("cat_price_range");
        for (int i = 0; i < cat_price_range.length(); i++) {
            JSONObject jsonObject = cat_price_range.getJSONObject(i);
            WooCommerceJSONHelper.parseFilterPrices(jsonObject);
        }
        return TM_ProductFilter.getAll();
    }

    public List<TM_ProductFilter> parseJsonAndCreateFilterAttributes(String jsonStringContent) throws Exception {
        DataHelper.log("-- parseJsonAndCreateFilterAttributes  " + jsonStringContent + " \n--");
        jsonStringContent = jsonStringContent.substring(jsonStringContent.indexOf("["), jsonStringContent.lastIndexOf("]") + 1);
        JSONArray jMainObject = new JSONArray(jsonStringContent);
        for (int i = 0; i < jMainObject.length(); i++) {
            JSONObject jsonObject = jMainObject.getJSONObject(i);
            WooCommerceJSONHelper.parseFilterAttributes(jsonObject);
        }
        return TM_ProductFilter.getAll();
    }

    public List<TM_ProductFilter> parseJsonAndCreateFilterPricesAttributes(String jsonStringContent) throws Exception {
        if (DataEngine.isLogEnabled()) {
            DataHelper.log("-- parseJsonAndCreateFilterPricesAttributes  [" + jsonStringContent + "] \n--");
        }
        JSONObject jMainObject = DataHelper.safeJsonObject(jsonStringContent);
        JSONArray cat_price_range = jMainObject.getJSONArray("cat_price_range");
        for (int i = 0; i < cat_price_range.length(); i++) {
            JSONObject jsonObject = cat_price_range.getJSONObject(i);
            WooCommerceJSONHelper.parseFilterPrices(jsonObject);
        }
        WooCommerceJSONHelper.parseFilterAttributes(jMainObject);
        return TM_ProductFilter.getAll();
    }

    public List<MenuInfo> parseAndCreateMenuItems(String json) throws Exception {
        json = json.substring(json.indexOf("["), json.lastIndexOf("]") + 1);
        JSONArray mainObject = new JSONArray(json);
        for (int i = 0; i < mainObject.length(); i++) {
            JSONObject jsonObject = mainObject.getJSONObject(i);
            JSONObject menuItemObj = jsonObject.getJSONObject("menu");

            int menuItemId = menuItemObj.getInt("id");

            MenuInfo menuInfo = MenuInfo.create(menuItemId);
            menuInfo.setName(menuItemObj.getString("name").trim());
            menuInfo.setSlug(menuItemObj.getString("slug"));

            JSONArray menuOptionArray = jsonObject.getJSONArray("options");
            for (int j = 0; j < menuOptionArray.length(); j++) {
                JSONObject menuOptionObj = menuOptionArray.getJSONObject(j);

                int menuOptionId = menuOptionObj.getInt("id");

                MenuOption menuOption = MenuOption.create(menuOptionId);
                menuOption.setName(menuOptionObj.getString("name").trim());
                menuOption.setParent(menuOptionObj.getString("parent"));
                menuOption.setMenuOrder(menuOptionObj.getInt("menu_order"));
                menuOption.setCategoryId(menuOptionObj.getInt("redirect_cid"));
                menuOption.setUrl(menuOptionObj.getString("redirect_url"));
                menuInfo.addMenuOption(menuOption);
            }
        }
        return MenuInfo.getAll();
    }


    public void getCommonInfoInBackground(final DataQueryHandler dataQueryHandler) {
        NetworkRequest.makeOauthGetRequest(url_common, null, new NetworkResponse.ResponseListener() {
            @Override
            public void onResponseReceived(NetworkResponse response) {
                if (response.succeed) {
                    DataHelper.log("-- fetchCommonInfo::getCommonInfoInBackground --");
                    try {
                        parseCommonInfoFromJsonString(response.msg);
                        dataQueryHandler.onSuccess(null);
                    } catch (Exception error) {
                        dataQueryHandler.onFailure(error);
                    }
                } else {
                    dataQueryHandler.onFailure(response.error);
                }
            }
        });
    }


    public void getCommentOnProductInBackground(int productId, final DataQueryHandler dataQueryHandler) {
        DataHelper.log("-- getCommentOnProductInBackground[" + productId + "] --");

        Map<String, String> params = new HashMap<>();
        params.put("filter[limit]", "100");

        String requestReviewURL = url_products + "/" + productId + "/reviews";
        DataHelper.log("-- requestReviewURL: [" + requestReviewURL + "] --");

        NetworkRequest.makeOauthGetRequest(requestReviewURL, params, new NetworkResponse.ResponseListener() {
            @Override
            public void onResponseReceived(NetworkResponse response) {
                if (response.succeed) {
                    DataHelper.log("-- getCommentOnProductInBackground::onRequestCompleted --");
                    if (WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                        return;
                    }

                    try {
                        dataQueryHandler.onSuccess(parseJsonAndCreateReviews(response.msg));
                    } catch (Exception ex) {
                        ex.printStackTrace();
                        dataQueryHandler.onFailure(ex);
                    }
                } else {
                    dataQueryHandler.onFailure(response.error);
                }
            }
        });
    }

    public void getOrderInBackground(int orderId, final DataQueryHandler dataQueryHandler) {
        if (!isNetworkAvailable()) {
            if (dataQueryHandler != null) {
                dataQueryHandler.onFailure(mNoConnectionError);
            }
            return;
        }

        NetworkRequest.makeOauthGetRequest(url_single_order + orderId, null, new NetworkResponse.ResponseListener() {
            @Override
            public void onResponseReceived(NetworkResponse response) {
                if (response.succeed) {
                    DataHelper.log("-- getOrderInBackground::onResponse:[" + response.msg + "] 1 --");
                    if (WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                        return;
                    }

                    try {
                        dataQueryHandler.onSuccess(WooCommerceJSONHelper.parseOrder(response.msg));
                    } catch (JSONException ex) {
                        ex.printStackTrace();
                        dataQueryHandler.onFailure(ex);
                    }
                } else {
                    dataQueryHandler.onFailure(response.error);
                }
            }
        });
    }

    public void getGuestOrdersInBackground(String orderIds, final DataQueryHandler dataQueryHandler) {
        final Map<String, String> params = new HashMap<>();
        params.put("oids", DataHelper.encrypt(orderIds));
        NetworkResponse.ResponseListener responseListener = new NetworkResponse.ResponseListener() {
            @Override
            public void onResponseReceived(NetworkResponse response) {
                if (dataQueryHandler != null) {
                    if (response.succeed) {
                        DataHelper.log("-- getGuestOrdersInBackground::onResponse : [" + response.msg + "] --");
                        if (WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                            return;
                        }
                        dataQueryHandler.onSuccess(WooCommerceJSONHelper.parseJsonAndCreateOrders(response.msg));
                    } else {
                        dataQueryHandler.onFailure(response.error);
                    }
                }
            }
        };
        NetworkRequest.makeCommonPostRequest(url_order_data, params, null, responseListener);
    }

    public void getOrdersInBackground(int customerId, final DataQueryHandler dataQueryHandler) {
        if (!isNetworkAvailable()) {
            if (dataQueryHandler != null) {
                dataQueryHandler.onFailure(mNoConnectionError);
            }
            return;
        }

        Map<String, String> params = new HashMap<>();
        params.put("filter[limit]", "300");
        params.put("filter[lang]", locale);
        NetworkRequest.makeOauthGetRequest(url_orders + customerId + "/orders", params, new NetworkResponse.ResponseListener() {
            @Override
            public void onResponseReceived(NetworkResponse response) {
                if (response.succeed) {
                    DataHelper.log("-- getOrdersInBackground::onResponse : [" + response.msg + "] --");
                    if (WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                        return;
                    }
                    dataQueryHandler.onSuccess(WooCommerceJSONHelper.parseJsonAndCreateOrders(response.msg));
                } else {
                    dataQueryHandler.onFailure(response.error);
                }
            }
        });
    }

    public List<TM_ProductReview> parseJsonAndCreateReviews(String jsonStringContent) throws JSONException {
        DataHelper.log("-- parseJsonAndCreateReviews [" + jsonStringContent + "] --");

        List<TM_ProductReview> productReviews = new ArrayList<>();
        JSONObject jMainObject = DataHelper.safeJsonObject(jsonStringContent);
        JSONArray product_reviews = jMainObject.getJSONArray("product_reviews");
        for (int i = 0; i < product_reviews.length(); i++) {
            productReviews.add(WooCommerceJSONHelper.parseProductReview(product_reviews.getJSONObject(i)));
        }
        return productReviews;
    }

    public void parseCommonInfoFromJsonString(String jsonStringContent) throws Exception {
        DataHelper.log("-- parseCommonInfoFromJsonString  [" + jsonStringContent + "] --");
        WooCommerceJSONHelper.parseCommonInfoFromJsonString(jsonStringContent);
    }

    public void registerOrderInBackground(String cartJsonString, final DataQueryHandler dataQueryHandler) {
        DataHelper.log("-- registerOrderInBackground:: [" + cartJsonString + "] --");
        NetworkRequest.makeOauthPostRequest(url_register_order, null, cartJsonString, new NetworkResponse.ResponseListener() {
            @Override
            public void onResponseReceived(NetworkResponse response) {
                if (response.succeed) {
                    DataHelper.log("-- WooCommerceEngine::registerOrderInBackground response: [" + response.msg + "] --");
                    if (WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                        return;
                    }

                    try {
                        TM_Order order = WooCommerceJSONHelper.parseOrder(response.msg);
                        if (dataQueryHandler != null) {
                            dataQueryHandler.onSuccess(order);
                        }
                    } catch (JSONException ex) {
                        ex.printStackTrace();
                        if (dataQueryHandler != null) {
                            dataQueryHandler.onFailure(ex);
                        }
                    }
                } else {
                    dataQueryHandler.onFailure(response.error);
                }
            }
        });
    }

    public void updateOrderStatusInBackground(int orderId, String cartJsonString, final DataQueryHandler dataQueryHandler) {
        DataHelper.log("-- updateOrderStatusInBackground [" + orderId + "][" + cartJsonString + "] --");
        NetworkRequest.makeOauthPostRequest(url_register_order + "/" + orderId, null, cartJsonString, new NetworkResponse.ResponseListener() {
            @Override
            public void onResponseReceived(NetworkResponse response) {
                if (response.succeed) {
                    DataHelper.log("== updateOrderStatusInBackground:onRequestCompleted [" + response.msg + "] ==");
                    if (WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                        return;
                    }

                    try {
                        TM_Order order = WooCommerceJSONHelper.parseOrder(response.msg);
                        if (dataQueryHandler != null) {
                            dataQueryHandler.onSuccess(order);
                        }
                    } catch (JSONException ex) {
                        ex.printStackTrace();
                        if (dataQueryHandler != null) {
                            dataQueryHandler.onFailure(ex);
                        }
                    }
                } else {
                    dataQueryHandler.onFailure(response.error);
                }
            }
        });
    }

    public void editCustomerDataInBackground(final String customerId, final String customerData, final DataQueryHandler dataQueryHandler) {
        DataHelper.log("-- WooCommerceEngine::editCustomerInBackground [" + customerId + "][" + customerData + "] --");
        if (!isNetworkAvailable()) {
            if (dataQueryHandler != null) {
                dataQueryHandler.onFailure(new Exception("No network connection"));
            }
            return;
        }

        NetworkRequest.makeOauthPostRequest(url_customer_edit + customerId, null, customerData, new NetworkResponse.ResponseListener() {
            @Override
            public void onResponseReceived(NetworkResponse response) {
                if (response.succeed) {
                    DataHelper.log("-- WooCommerceEngine::editCustomerInBackground response: [" + response.msg + "] --");
                    if (WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                        return;
                    }
                    if (dataQueryHandler != null)
                        dataQueryHandler.onSuccess(response.msg);
                } else {
                    dataQueryHandler.onFailure(response.error);
                }
            }
        });
    }

    public void fetchCustomerDataInBackground(String email, final TM_LoginListener loginListener) {
        if (!isNetworkAvailable()) {
            loginListener.onLoginFailed("No network connection");
            return;
        }

        NetworkRequest.makeOauthGetRequest(url_customer_data + email, null, new NetworkResponse.ResponseListener() {
            @Override
            public void onResponseReceived(NetworkResponse response) {
                if (response.succeed) {
                    DataHelper.log("-- DataEngine::fetchCustomerDataInBackground response: [" + response.msg + "] --");
                    if (WooCommerceJSONHelper.hasResponseError(response.msg, loginListener)) {
                        return;
                    }
                    loginListener.onLoginSuccess(response.msg);
                } else {
                    loginListener.onLoginFailed(response.error.getLocalizedMessage());
                }
            }
        });
    }

    public void getCrossSellProducts(final List<Integer> productIds, final DataQueryHandler dataQueryHandler) {
        final Map<String, String> params = new HashMap<>();
        params.put("products", productIds.toString());

        NetworkRequest.makeCommonGetRequest(url_cross_sells_product, params, new NetworkResponse.ResponseListener() {
            @Override
            public void onResponseReceived(NetworkResponse getResponse) {
                if (getResponse.succeed) {
                    if (dataQueryHandler != null) {
                        final List<Integer> cross_sell_ids = new ArrayList<>();
                        List<Integer> unavailable_product_ids = new ArrayList<>();
                        for (int cross_sell_id : cross_sell_ids) {
                            if (TM_ProductInfo.getProductWithId(cross_sell_id) == null)
                                unavailable_product_ids.add(cross_sell_id);
                        }
                        if (unavailable_product_ids.isEmpty()) {
                            dataQueryHandler.onSuccess(cross_sell_ids);
                        } else {
                            getPollProductsInBackground(unavailable_product_ids, new DataQueryHandler() {
                                @Override
                                public void onSuccess(Object data) {
                                    dataQueryHandler.onSuccess(cross_sell_ids);
                                }

                                @Override
                                public void onFailure(Exception exception) {
                                    dataQueryHandler.onFailure(exception);
                                }
                            });
                        }
                    }
                } else {
                    if (dataQueryHandler != null) {
                        dataQueryHandler.onFailure(getResponse.error);
                    }
                }
            }
        });
    }

    public void createProductInBackground(RawProductInfo product, final DataQueryHandler dataQueryHandler) {
        String productJsonString = null;
        try {
            productJsonString = WooCommerceJSONHelper.getJsonFromProduct(product);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        if (productJsonString != null && productJsonString.length() > 0) {
            String finalUrl = url_products;
            if (product.id > 0) {
                finalUrl += "/" + product.id;
                NetworkRequest.makeOauthPutRequest(finalUrl, null, productJsonString, new NetworkResponse.ResponseListener() {
                    @Override
                    public void onResponseReceived(NetworkResponse response) {
                        if (response.succeed) {
                            DataHelper.log("-- WooCommerceEngine::createProductInBackground response: [" + response.msg + "] --");
                            if (WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                                return;
                            }
                            try {
                                TM_ProductInfo product = WooCommerceJSONHelper.parseFullProduct(getSingleProductJSON(response.msg));
                                dataQueryHandler.onSuccess(product);
                            } catch (Exception e) {
                                dataQueryHandler.onFailure(e);
                            }
                        } else {
                            dataQueryHandler.onFailure(response.error);
                        }
                    }
                });
            } else {
                NetworkRequest.makeOauthPostRequest(finalUrl, null, productJsonString, new NetworkResponse.ResponseListener() {
                    @Override
                    public void onResponseReceived(NetworkResponse response) {
                        if (response.succeed) {
                            DataHelper.log("-- WooCommerceEngine::createProductInBackground response: [" + response.msg + "] --");
                            if (WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                                return;
                            }
                            try {
                                TM_ProductInfo product = WooCommerceJSONHelper.parseFullProduct(getSingleProductJSON(response.msg));
                                dataQueryHandler.onSuccess(product);
                            } catch (Exception e) {
                                dataQueryHandler.onFailure(e);
                            }
                        } else {
                            dataQueryHandler.onFailure(response.error);
                        }
                    }
                });
            }
        }
    }

    public void updateProductShippingInfo(Map<String, String> params, final DataQueryHandler dataQueryHandler) {
        NetworkRequest.makeCommonPostRequest(url_product_shipping_info, params, null, new NetworkResponse.ResponseListener() {
            @Override
            public void onResponseReceived(NetworkResponse response) {
                DataHelper.log("-- updateProductShippingInfo:response [" + response.msg + "] --");
                if (response.succeed) {
                    DataHelper.log(response.msg);
                } else {
                    dataQueryHandler.onFailure(response.error);
                }
            }

        });
    }

    public void getProductShippingInfo(final DataQueryHandler dataQueryHandler) {
        if (RawShipping.loadingCompleted()) {
            if (dataQueryHandler != null) {
                dataQueryHandler.onSuccess(RawShipping.getAll());
            }
            return;
        }
        NetworkResponse.ResponseListener responseListener = new NetworkResponse.ResponseListener() {
            @Override
            public void onResponseReceived(NetworkResponse response) {
                DataHelper.log("-- getProductShippingInfo-response: [" + response.msg + "] --");
                if (response.succeed) {
                    if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                        try {
                            WooCommerceJSONHelper.parseJsonAndCreateShippingType(response.msg);
                            dataQueryHandler.onSuccess(RawShipping.getAll());
                            RawShipping.setShippingLoaded();
                        } catch (Exception e) {
                            e.printStackTrace();
                            dataQueryHandler.onFailure(new Exception("Error while loading shipping methods.."));
                        }
                    }
                } else {
                    dataQueryHandler.onFailure(response.error);
                }
            }
        };
        NetworkRequest.makeCommonGetRequest(url_shipping_type, null, responseListener);
    }


    public void deleteProductInBackground(final int productId, final DataQueryHandler dataQueryHandler) {
        NetworkRequest.makeOauthDeleteRequest(url_products + "/" + productId, null, new NetworkResponse.ResponseListener() {
            @Override
            public void onResponseReceived(NetworkResponse response) {
                if (response.succeed) {
                    DataHelper.log("-- WooCommerceEngine::deleteProductInBackground response: [" + response.msg + "] --");
                    if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                        dataQueryHandler.onSuccess(productId);
                    }
                } else {
                    dataQueryHandler.onFailure(response.error);
                }
            }
        });
    }


    public void getProductInfoInBackground(final int productId, final DataQueryHandler dataQueryHandler) {
        TM_ProductInfo product = TM_ProductInfo.findProductById(productId);
        if (product != null
            && (product.type == TM_ProductInfo.ProductType.BUNDLE || product.type == TM_ProductInfo.ProductType.BUNDLE_YITH || product.type == TM_ProductInfo.ProductType.MIXNMATCH)
            && (DataEngine.use_plugin_for_full_data || DataEngine.enable_mix_n_match)) {
            getProductInfoFastInBackground(product, dataQueryHandler);
            return;
        }

        //DataHelper.log("Product Type => " + product.type.toString() + " => [" + product.title + "]" );

        if (!isNetworkAvailable()) {
            if (dataQueryHandler != null) {
                dataQueryHandler.onFailure(mNoConnectionError);
            }
            return;
        }

        NetworkRequest.makeOauthGetRequest(url_products + "/" + productId, null, new NetworkResponse.ResponseListener() {
            @Override
            public void onResponseReceived(NetworkResponse response) {
                if (response.succeed) {
                    DataHelper.log("-- getProductInfoInBackground::onResponse 1 [" + response.msg + "] --");
                    if (WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                        return;
                    }
                    try {
                        TM_ProductInfo product = WooCommerceJSONHelper.parseFullProduct(getSingleProductJSON(response.msg));
                        product.extra_attribs_loaded = false;
                        dataQueryHandler.onSuccess(product);
                    } catch (Exception e) {
                        dataQueryHandler.onFailure(e);
                    }
                } else {
                    dataQueryHandler.onFailure(response.error);
                }
            }
        });
    }


    public void getProductWithSkuInBackground(String sku, final DataQueryHandler<TM_ProductInfo> dataQueryHandler) {
        if (!isNetworkAvailable()) {
            dataQueryHandler.onFailure(mNoConnectionError);
            return;
        }

        Map<String, String> params = new HashMap<>();
        params.put("filter[sku]", sku);
        if (locale.length() != 0) {
            params.put("filter[lang]", locale);
        }

        NetworkRequest.makeOauthGetRequest(url_products, params, new NetworkResponse.ResponseListener() {
            @Override
            public void onResponseReceived(NetworkResponse response) {
                if (response.succeed) {
                    DataHelper.log("-- getProductInfoWithSkuInBackground::onResponse 1 [" + response.msg + "] --");
                    if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                        try {
                            List<TM_ProductInfo> productInfoList = parseJsonAndCreateProducts(response.msg);
                            dataQueryHandler.onSuccess(productInfoList.get(0));
                        } catch (Exception e) {
                            dataQueryHandler.onFailure(e);
                        }
                    }
                } else {
                    dataQueryHandler.onFailure(response.error);
                }
            }
        });
    }

    public void getProductInfoFastInBackground(final TM_ProductInfo product, final DataQueryHandler dataQueryHandler) {
        if (!isNetworkAvailable()) {
            if (dataQueryHandler != null) {
                dataQueryHandler.onFailure(mNoConnectionError);
            }
            return;
        }

        Map<String, String> params = new HashMap<>();
        params.put("pids", DataHelper.encrypt("[" + product.id + "]"));
        params.put("lang", locale);

        NetworkRequest.makeCommonPostRequest(url_single_product_fast, params, null, new NetworkResponse.ResponseListener() {
            @Override
            public void onResponseReceived(NetworkResponse response) {
                DataHelper.log("-- getProductInfoFastInBackground:response [" + response.msg + "] --");
                if (response.succeed) {
                    if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                        try {
                            TM_ProductInfo product = WooCommerceJSONHelper.parseFullProductFast(response.msg);
                            product.extra_attribs_loaded = false;
                            dataQueryHandler.onSuccess(product);
                        } catch (Exception e) {
                            e.printStackTrace();
                            dataQueryHandler.onFailure(e);
                        }
                    }
                } else {
                    dataQueryHandler.onFailure(response.error);
                }
            }
        });
    }


    public void getExtraAttributesDataInBackground(final TM_ProductInfo product, final DataQueryHandler dataQueryHandler) {
        if (!isNetworkAvailable()) {
            if (dataQueryHandler != null) {
                dataQueryHandler.onFailure(mNoConnectionError);
            }
            return;
        }

        Map<String, String> params = new HashMap<>();
        params.put("pids", DataHelper.encrypt("[" + product.id + "]"));
        NetworkRequest.makeCommonPostRequest(url_extra_attribs, params, null, new NetworkResponse.ResponseListener() {
            @Override
            public void onResponseReceived(NetworkResponse response) {
                if (response.succeed) {
                    if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                        try {
                            WooCommerceJSONHelper.parseExtraAttributesForProduct(product, response.msg);
                            dataQueryHandler.onSuccess(product);
                        } catch (Exception e) {
                            e.printStackTrace();
                            dataQueryHandler.onFailure(e);
                        }
                    }
                } else {
                    dataQueryHandler.onFailure(response.error);
                }
            }
        });
    }

    public JSONObject getSingleProductJSON(String jsonString) throws JSONException {
        return DataHelper.safeJsonObject(jsonString, "product").getJSONObject("product");
    }

    public void getPollProductsInBackground(List<Integer> productIds, final DataQueryHandler dataQueryHandler) {
        String ids = "";
        for (int id : productIds) {
            ids += id + ";";
        }
        if (ids.length() > 0) {
            ids = ids.substring(0, ids.length() - 1);
        }
        getPollProductsInBackground(ids, dataQueryHandler);
    }

    public void getPollProductsInBackground(String productIds, final DataQueryHandler dataQueryHandler) {
        DataHelper.log("-- getPollProductsInBackground:[" + productIds + "] --");
        final Map<String, String> params = new HashMap<>();
        params.put("pole_param", productIds);
        params.put("lang", DataHelper.encrypt(locale));
        NetworkRequest.makeCommonPostRequest(url_poll_products, params, null, new NetworkResponse.ResponseListener() {
            @Override
            public void onResponseReceived(NetworkResponse response) {
                if (response.succeed) {
                    if (WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                        return;
                    }
                    try {
                        dataQueryHandler.onSuccess(parseJsonAndCreatePollProducts(response.msg));
                    } catch (Exception e) {
                        e.printStackTrace();
                        dataQueryHandler.onFailure(new Exception("Error while loading products.."));
                    }
                } else {
                    dataQueryHandler.onFailure(response.error);
                }
            }
        });
    }

    public void getFullProductsInBackground(List<Integer> productIds, DataQueryHandler<List<TM_ProductInfo>> dataQueryHandler) {
        String ids = "";
        for (int id : productIds) {
            ids += id + ";";
        }
        if (ids.length() > 0) {
            ids = ids.substring(0, ids.length() - 1);
        }
        getFullProductsInBackground(ids, dataQueryHandler);
    }

    public void getFullProductsInBackground(String productIds, final DataQueryHandler<List<TM_ProductInfo>> dataQueryHandler) {
        DataHelper.log("-- getFullProductsInBackground:[" + productIds + "] --");
        final Map<String, String> params = new HashMap<>();
        params.put("pids", DataHelper.encrypt("[" + productIds + "]"));
        params.put("lang", DataHelper.encrypt(locale));
        NetworkRequest.makeCommonPostRequest(url_product_full_data, params, null, new NetworkResponse.ResponseListener() {
            @Override
            public void onResponseReceived(NetworkResponse response) {
                if (response.succeed) {
                    if (WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                        return;
                    }
                    try {
                        dataQueryHandler.onSuccess(parseFullJsonAndCreateProducts(response.msg));
                    } catch (Exception e) {
                        e.printStackTrace();
                        dataQueryHandler.onFailure(new Exception("Error while loading products.."));
                    }
                } else {
                    dataQueryHandler.onFailure(response.error);
                }
            }
        });
    }

    public void getProductDeliveryInfo(final TM_ProductInfo product, final DataQueryHandler dataQueryHandler) {
        if (hasNetworkAccess(dataQueryHandler)) {
            Map<String, String> params = new HashMap<>();
            params.put("type", DataHelper.encrypt("product"));
            params.put("pid", DataHelper.encrypt(product.id));
            NetworkRequest.makeCommonPostRequest(url_product_delivery_info, params, null, new NetworkResponse.ResponseListener() {
                @Override
                public void onResponseReceived(NetworkResponse response) {
                    if (response.succeed) {
                        if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                            try {
                                dataQueryHandler.onSuccess(WooCommerceJSONHelper.parseProductDeliveryInfo(response.msg, product));
                            } catch (Exception e) {
                                e.printStackTrace();
                                dataQueryHandler.onFailure(new Exception("Error while loading product info.."));
                            }
                        }
                    } else {
                        dataQueryHandler.onFailure(response.error);
                    }
                }
            });
        }
    }

    public void postOrderShippingDeliveryInfo(int orderId, String shippingData, final DataQueryHandler dataQueryHandler) {
        if (hasNetworkAccess(dataQueryHandler)) {
            Map<String, String> params = new HashMap<>();
            params.put("type", DataHelper.encrypt("order-meta"));
            params.put("orderid", DataHelper.encrypt(orderId));
            params.put("shipping", shippingData);
            NetworkRequest.makeCommonPostRequest(url_product_delivery_info, params, null, new NetworkResponse.ResponseListener() {
                @Override
                public void onResponseReceived(NetworkResponse response) {
                    if (response.succeed) {
                        if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                            dataQueryHandler.onSuccess(response.msg);
                        }
                    } else {
                        dataQueryHandler.onFailure(response.error);
                    }
                }
            });
        }
    }


    public void sponsorFriendAsync(final Map<String, String> params, final DataQueryHandler dataQueryHandler) {
        if (hasNetworkAccess(dataQueryHandler)) {
            DataHelper.encrypt(params);
            NetworkRequest.makeCommonPostRequest(url_custom_sponsor_friend, params, null, new NetworkResponse.ResponseListener() {
                @Override
                public void onResponseReceived(NetworkResponse response) {
                    if (response.succeed) {
                        if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                            dataQueryHandler.onSuccess(response.msg);
                        }
                    } else {
                        dataQueryHandler.onFailure(response.error);
                    }
                }
            });
        }
    }


    public void getReservationFormInBackground(final DataQueryHandler dataQueryHandler) {
        if (hasNetworkAccess(dataQueryHandler)) {
            Map<String, String> params = new HashMap<>();
            params.put("type", DataHelper.encrypt("reservation_form"));
            params.put("form_id", DataHelper.encrypt("25"));
            NetworkRequest.makeCommonPostRequest(url_reservation_from, params, null, new NetworkResponse.ResponseListener() {
                @Override
                public void onResponseReceived(NetworkResponse response) {
                    if (response.succeed) {
                        if (WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                            return;
                        }

                        try {
                            dataQueryHandler.onSuccess(response.msg);
                        } catch (Exception ex) {
                            ex.printStackTrace();
                            dataQueryHandler.onFailure(ex);
                        }
                    } else {
                        dataQueryHandler.onFailure(response.error);
                    }
                }
            });
        }
    }

    public void postReservationFormInBackground(Map<String, String> params, final DataQueryHandler dataQueryHandler) {
        if (hasNetworkAccess(dataQueryHandler)) {
            DataHelper.encrypt(params);
            NetworkRequest.makeCommonPostRequest(url_reservation_from, params, null, new NetworkResponse.ResponseListener() {
                @Override
                public void onResponseReceived(NetworkResponse response) {
                    if (response.succeed) {
                        if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                            try {
                                JSONObject msgJsonObject = new JSONObject(response.msg);
                                String message = msgJsonObject.getString("message");
                                dataQueryHandler.onSuccess(message);
                            } catch (Exception e) {
                                e.printStackTrace();
                                dataQueryHandler.onFailure(e);
                            }

                        } else {
                            dataQueryHandler.onFailure(response.error);
                        }
                    } else {
                        dataQueryHandler.onFailure(response.error);
                    }
                }
            });
        }
    }

    public void getContactForm3InBackground(final DataQueryHandler dataQueryHandler) {
        if (hasNetworkAccess(dataQueryHandler)) {
            Map<String, String> params = new HashMap<>();
            params.put("type", DataHelper.encrypt("contact_form"));
            params.put("form_id", DataHelper.encrypt("0"));
            NetworkRequest.makeCommonPostRequest(url_contact_from_3, params, null, new NetworkResponse.ResponseListener() {
                @Override
                public void onResponseReceived(NetworkResponse response) {
                    if (response.succeed) {
                        if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                            dataQueryHandler.onSuccess(response.msg);
                        } else {
                            dataQueryHandler.onFailure(response.error);
                        }
                    } else {
                        dataQueryHandler.onFailure(response.error);
                    }
                }
            });
        }
    }

    public void postContactForm3InBackground(Map<String, String> params, final DataQueryHandler dataQueryHandler) {
        if (hasNetworkAccess(dataQueryHandler)) {
            DataHelper.encrypt(params);
            NetworkRequest.makeCommonPostRequest(url_contact_from_3, params, null, new NetworkResponse.ResponseListener() {
                @Override
                public void onResponseReceived(NetworkResponse response) {
                    if (response.succeed) {
                        if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                            try {
                                JSONObject msgJsonObject = new JSONObject(response.msg);
                                String message = msgJsonObject.getString("message");
                                dataQueryHandler.onSuccess(message);
                            } catch (Exception e) {
                                e.printStackTrace();
                                dataQueryHandler.onFailure(e);
                            }
                        } else {
                            dataQueryHandler.onFailure(response.error);
                        }
                    } else {
                        dataQueryHandler.onFailure(response.error);
                    }
                }
            });
        }
    }

    public void getWishListProductsAsync(String emailId, int userId, final DataQueryHandler dataQueryHandler) {
        if (hasNetworkAccess(dataQueryHandler)) {
            Map<String, String> params = new HashMap<>();
            params.put("type", DataHelper.encrypt("products"));
            params.put("user_id", DataHelper.encrypt(String.valueOf(userId)));
            params.put("email_id", DataHelper.encrypt(emailId));
            NetworkRequest.makeCommonPostRequest(url_custom_wishlist, params, null, new NetworkResponse.ResponseListener() {
                @Override
                public void onResponseReceived(NetworkResponse response) {
                    if (response.succeed) {
                        if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                            try {
                                WooCommerceJSONHelper.createWishListFromJson(response.msg);
                                dataQueryHandler.onSuccess(null);
                            } catch (JSONException e) {
                                e.printStackTrace();
                                dataQueryHandler.onFailure(new Exception("Error while loading WishList items."));
                            }
                        }
                    } else {
                        dataQueryHandler.onFailure(response.error);
                    }
                }
            });
        }
    }


    public void getWishListDetailsAsync(String emailId, int userId, final DataQueryHandler dataQueryHandler) {
        if (hasNetworkAccess(dataQueryHandler)) {
            Map<String, String> params = new HashMap<>();
            params.put("type", DataHelper.encrypt("details"));
            params.put("user_id", DataHelper.encrypt(String.valueOf(userId)));
            params.put("email_id", DataHelper.encrypt(emailId));
            NetworkRequest.makeCommonPostRequest(url_custom_wishlist, params, null, new NetworkResponse.ResponseListener() {
                @Override
                public void onResponseReceived(NetworkResponse response) {
                    if (response.succeed) {
                        if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                            dataQueryHandler.onSuccess(response.msg);
                        }
                    } else {
                        dataQueryHandler.onFailure(response.error);
                    }
                }
            });
        }
    }


    public void addOrRemoveWishListProductAsync(Map<String, String> params, final DataQueryHandler dataQueryHandler) {
        if (hasNetworkAccess(dataQueryHandler)) {
            DataHelper.encrypt(params);
            NetworkRequest.makeCommonPostRequest(url_custom_wishlist, params, null, new NetworkResponse.ResponseListener() {
                @Override
                public void onResponseReceived(NetworkResponse response) {
                    if (response.succeed) {
                        if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                            dataQueryHandler.onSuccess(response.msg);
                        }
                    } else {
                        dataQueryHandler.onFailure(response.error);
                    }
                }
            });
        }
    }


    public void addOrRemoveMultipleWishListProductAsync(Map<String, String> params, final DataQueryHandler dataQueryHandler) {
        if (hasNetworkAccess(dataQueryHandler)) {

            try {
                DataHelper.encrypt(params);
                NetworkRequest.makeCommonPostRequest(url_create_multiple_wishlist, params, null, new NetworkResponse.ResponseListener() {
                    @Override
                    public void onResponseReceived(NetworkResponse response) {
                        if (response.succeed) {
                            if (!WooCommerceJSONHelper.hasResponseError(response.toString(), dataQueryHandler)) {
                                dataQueryHandler.onSuccess(response.msg);
                            }
                        } else {
                            dataQueryHandler.onFailure(response.error);
                        }
                    }
                });
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }


    public void getWaitListProductIdsAsync(int userId, String emailId, final DataQueryHandler dataQueryHandler) {
        if (hasNetworkAccess(dataQueryHandler)) {
            Map<String, String> params = new HashMap<>();
            params.put("type", DataHelper.encrypt("view"));
            params.put("user_id", DataHelper.encrypt("" + userId));
            params.put("email_id", DataHelper.encrypt(emailId));
            NetworkRequest.makeCommonPostRequest(url_custom_waitlist, params, null, new NetworkResponse.ResponseListener() {
                @Override
                public void onResponseReceived(NetworkResponse response) {
                    if (response.succeed) {
                        if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                            try {
                                WooCommerceJSONHelper.createWaitListFromJson(response.msg);
                                dataQueryHandler.onSuccess(response.msg);
                            } catch (JSONException e) {
                                e.printStackTrace();
                                dataQueryHandler.onFailure(new Exception("Error while loading WaitList product ids."));
                            }
                        }
                    } else {
                        dataQueryHandler.onFailure(response.error);
                    }
                }
            });
        }
    }


    public void subscribeWaitListProductAsync(int userId, String emailId, int productId, final DataQueryHandler dataQueryHandler) {
        if (hasNetworkAccess(dataQueryHandler)) {
            Map<String, String> params = new HashMap<>();
            params.put("type", DataHelper.encrypt("subscribe"));
            params.put("user_id", DataHelper.encrypt("" + userId));
            params.put("email_id", DataHelper.encrypt(emailId));
            params.put("prod_id", DataHelper.encrypt("" + productId));
            NetworkRequest.makeCommonPostRequest(url_custom_waitlist, params, null, new NetworkResponse.ResponseListener() {
                @Override
                public void onResponseReceived(NetworkResponse response) {
                    if (response.succeed) {
                        if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                            dataQueryHandler.onSuccess(response.msg);
                        }
                    } else {
                        dataQueryHandler.onFailure(response.error);
                    }
                }
            });
        }
    }


    public void unsubscribeWaitListProductAsync(int userId, String emailId, int productId, final DataQueryHandler dataQueryHandler) {
        if (hasNetworkAccess(dataQueryHandler)) {
            Map<String, String> params = new HashMap<>();
            params.put("type", DataHelper.encrypt("unsubscribe"));
            params.put("user_id", DataHelper.encrypt("" + userId));
            params.put("email_id", DataHelper.encrypt(emailId));
            params.put("prod_id", DataHelper.encrypt("" + productId));
            NetworkRequest.makeCommonPostRequest(url_custom_waitlist, params, null, new NetworkResponse.ResponseListener() {
                @Override
                public void onResponseReceived(NetworkResponse response) {
                    if (response.succeed) {
                        if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                            dataQueryHandler.onSuccess(response.msg);
                        }
                    } else {
                        dataQueryHandler.onFailure(response.error);
                    }
                }
            });
        }
    }

    public void getRewardPointsSettingsAsync(final DataQueryHandler dataQueryHandler) {
        if (hasNetworkAccess(dataQueryHandler)) {
            Map<String, String> params = new HashMap<>();
            params.put("type", "reward_point_settings");
            DataHelper.encrypt(params);
            NetworkRequest.makeCommonPostRequest(url_custom_reward_points, params, null, new NetworkResponse.ResponseListener() {
                @Override
                public void onResponseReceived(NetworkResponse response) {
                    if (response.succeed) {
                        if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                            try {
                                WooCommerceJSONHelper.parseRewardPointsSettingFromJson(response.msg);
                                dataQueryHandler.onSuccess("");
                            } catch (JSONException e) {
                                e.printStackTrace();
                                dataQueryHandler.onFailure(e);
                            }
                        }
                    } else {
                        dataQueryHandler.onFailure(response.error);
                    }
                }
            });
        }
    }

    public void getUserRewardPointsAsync(Map<String, String> params, final DataQueryHandler dataQueryHandler) {
        if (hasNetworkAccess(dataQueryHandler)) {
            params.put("type", "user_total_points");
            DataHelper.encrypt(params);
            NetworkRequest.makeCommonPostRequest(url_custom_reward_points, params, null, new NetworkResponse.ResponseListener() {
                @Override
                public void onResponseReceived(NetworkResponse response) {
                    if (response.succeed) {
                        if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                            dataQueryHandler.onSuccess(response.msg);
                        }
                    } else {
                        dataQueryHandler.onFailure(response.error);
                    }
                }
            });
        }
    }


    public void getProductRewardPointsAsync(Map<String, String> params, final DataQueryHandler dataQueryHandler) {
        if (hasNetworkAccess(dataQueryHandler)) {
            params.put("type", "product_reward_points");
            DataHelper.encrypt(params);
            NetworkRequest.makeCommonPostRequest(url_custom_reward_points, params, null, new NetworkResponse.ResponseListener() {
                @Override
                public void onResponseReceived(NetworkResponse response) {
                    if (response.succeed) {
                        if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                            try {
                                WooCommerceJSONHelper.parseProductRewardPointsFromJson(response.msg);
                                dataQueryHandler.onSuccess(response.msg);
                            } catch (JSONException e) {
                                e.printStackTrace();
                                dataQueryHandler.onFailure(e);
                            }
                        }
                    } else {
                        dataQueryHandler.onFailure(response.error);
                    }
                }
            });
        }
    }


    public void getOrderRewardPointsAsync(Map<String, String> params, final DataQueryHandler dataQueryHandler) {
        if (hasNetworkAccess(dataQueryHandler)) {
            params.put("type", "order_reward_points");
            DataHelper.encrypt(params);
            NetworkRequest.makeCommonPostRequest(url_custom_reward_points, params, null, new NetworkResponse.ResponseListener() {
                @Override
                public void onResponseReceived(NetworkResponse response) {
                    if (response.succeed) {
                        if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                            dataQueryHandler.onSuccess(response.msg);
                        }
                    } else {
                        dataQueryHandler.onFailure(response.error);
                    }
                }
            });
        }
    }


    public void updateOrderRewardPointsAsync(Map<String, String> params, final DataQueryHandler dataQueryHandler) {
        if (hasNetworkAccess(dataQueryHandler)) {
            params.put("type", "update_order_points");
            DataHelper.encrypt(params);
            NetworkRequest.makeCommonPostRequest(url_custom_reward_points, params, null, new NetworkResponse.ResponseListener() {
                @Override
                public void onResponseReceived(NetworkResponse response) {
                    if (response.succeed) {
                        if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                            dataQueryHandler.onSuccess(response.msg);
                        }
                    } else {
                        dataQueryHandler.onFailure(response.error);
                    }
                }
            });
        }
    }


    public void getCartProductsRewardPointsAsync(Map<String, String> params, final DataQueryHandler dataQueryHandler) {
        if (hasNetworkAccess(dataQueryHandler)) {
            params.put("type", "poll_reward_data");
            DataHelper.encrypt(params);
            NetworkRequest.makeCommonPostRequest(url_custom_reward_points, params, null, new NetworkResponse.ResponseListener() {
                @Override
                public void onResponseReceived(NetworkResponse response) {
                    if (response.succeed) {
                        if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                            try {
                                WooCommerceJSONHelper.parseProductsRewardPointsFromJson(response.msg);
                                dataQueryHandler.onSuccess(response.msg);
                            } catch (JSONException e) {
                                e.printStackTrace();
                                dataQueryHandler.onFailure(e);
                            }
                        }
                    } else {
                        dataQueryHandler.onFailure(response.error);
                    }
                }
            });
        }
    }

    public void getProductsBrandNames(int[] productIds, final DataQueryHandler dataQueryHandler) {
        if (hasNetworkAccess(dataQueryHandler)) {
            Map<String, String> params = new HashMap<>();
            params.put("pids", DataHelper.encrypt("[" + DataHelper.join(",", productIds) + "]"));
            NetworkRequest.makeCommonPostRequest(url_products_brand_names, params, null, new NetworkResponse.ResponseListener() {
                @Override
                public void onResponseReceived(NetworkResponse response) {
                    if (response.succeed) {
                        if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                            try {
                                WooCommerceJSONHelper.parseProductsBrandNamesJson(response.msg);
                                dataQueryHandler.onSuccess(response.msg);
                            } catch (Exception e) {
                                e.printStackTrace();
                                dataQueryHandler.onFailure(e);
                            }
                        }
                    } else {
                        dataQueryHandler.onFailure(response.error);
                    }
                }
            });
        }
    }


    public void getProductsPriceLabels(int[] productIds, final DataQueryHandler dataQueryHandler) {
        if (hasNetworkAccess(dataQueryHandler)) {
            Map<String, String> params = new HashMap<>();
            params.put("pids", DataHelper.encrypt("[" + DataHelper.join(",", productIds) + "]"));
            NetworkRequest.makeCommonPostRequest(url_products_price_labels, params, null, new NetworkResponse.ResponseListener() {
                @Override
                public void onResponseReceived(NetworkResponse response) {
                    if (response.succeed) {
                        if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                            try {
                                WooCommerceJSONHelper.parseProductsPriceLabelsJson(response.msg);
                                dataQueryHandler.onSuccess(response.msg);
                            } catch (Exception e) {
                                e.printStackTrace();
                                dataQueryHandler.onFailure(e);
                            }
                        }
                    } else {
                        dataQueryHandler.onFailure(response.error);
                    }
                }
            });
        }
    }


    public void getProductsQuantityRules(int[] productIds, final DataQueryHandler dataQueryHandler) {
        if (hasNetworkAccess(dataQueryHandler)) {
            Map<String, String> params = new HashMap<>();
            params.put("pids", DataHelper.encrypt("[" + DataHelper.join(",", productIds) + "]"));
            NetworkRequest.makeCommonPostRequest(url_incremental_product_quantities, params, null, new NetworkResponse.ResponseListener() {
                @Override
                public void onResponseReceived(NetworkResponse response) {
                    if (response.succeed) {
                        if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                            try {
                                WooCommerceJSONHelper.parseProductsQuantityRulesJson(response.msg);
                                dataQueryHandler.onSuccess(response.msg);
                            } catch (Exception e) {
                                e.printStackTrace();
                                dataQueryHandler.onFailure(e);
                            }
                        }
                    } else {
                        dataQueryHandler.onFailure(response.error);
                    }
                }
            });
        }
    }


    public void getProductsPincodeSettings(final DataQueryHandler dataQueryHandler) {
        if (hasNetworkAccess(dataQueryHandler)) {
            NetworkRequest.makeCommonGetRequest(url_product_pin_code, null, new NetworkResponse.ResponseListener() {
                @Override
                public void onResponseReceived(NetworkResponse response) {
                    if (response.succeed) {
                        if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                            try {
                                WooCommerceJSONHelper.parseProductsPincodeSettings(response.msg);
                                dataQueryHandler.onSuccess(null);
                            } catch (Exception e) {
                                e.printStackTrace();
                                dataQueryHandler.onFailure(e);
                            }
                        }
                    } else {
                        dataQueryHandler.onFailure(response.error);
                    }
                }
            });
        }
    }


    public void getProductsAvailabilityPincode(final DataQueryHandler dataQueryHandler, String pincode) {
        final Map<String, String> params = new HashMap<>();
        params.put("pincode", DataHelper.encrypt(pincode));
        NetworkRequest.makeCommonPostRequest(url_product_pin_code_availability, params, null, new NetworkResponse.ResponseListener() {
            @Override
            public void onResponseReceived(NetworkResponse response) {
                if (response.succeed) {
                    DataHelper.log(response.msg);
                    dataQueryHandler.onSuccess(response.msg);
                }
            }
        });
    }

    public List<TM_ProductInfo> parseFullJsonAndCreateProducts(String jsonStringContent) {
        JSONObject jMainObject;
        List<TM_ProductInfo> list_products = new ArrayList<>();
        JSONArray jsonarray;
        try {
            jsonarray = new JSONArray(jsonStringContent);
            String key = null;
            for (int i = 0; i < jsonarray.length(); i++) {
                JSONObject jsonobject = jsonarray.getJSONObject(i);
                Iterator<?> keys = jsonobject.keys();
                while (keys.hasNext()) {
                    key = (String) keys.next();
                }
                jMainObject = jsonobject.getJSONObject(key);
                list_products.add(WooCommerceJSONHelper.parseFullProductWithNullCheck(jMainObject));
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return list_products;
    }

    public void updateCartItemsInBackground(String cartJson, final DataQueryHandler dataQueryHandler) {
        DataHelper.log("-- updateCartItemsInBackground:[" + cartJson + "] --");
        final Map<String, String> params = new HashMap<>();
        params.put("cart_param", cartJson);
        params.put("lang", DataHelper.encrypt(locale));
        NetworkRequest.makeCommonPostRequest(url_poll_products, params, null, new NetworkResponse.ResponseListener() {
            @Override
            public void onResponseReceived(NetworkResponse response) {
                if (response.succeed) {
                    if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                        List<TM_SimpleCart> simpleCarts = parseJsonAndCreateSimpleCartProducts(response.msg);
                        if (simpleCarts != null) {
                            dataQueryHandler.onSuccess(simpleCarts);
                        } else {
                            dataQueryHandler.onFailure(new Exception("Error while loading simple cart data."));
                        }
                    }
                } else {
                    dataQueryHandler.onFailure(response.error);
                }
            }
        });
    }

    public void getShippingAddressesInBackground(int userId, final DataQueryHandler dataQueryHandler) {
        if (hasNetworkAccess(dataQueryHandler)) {
            final Map<String, String> params = new HashMap<>();
            params.put("type", DataHelper.encrypt("view"));
            params.put("user_id", DataHelper.encrypt(userId));
            NetworkRequest.makeCommonPostRequest(url_multiple_shipping_address, params, null, new NetworkResponse.ResponseListener() {
                @Override
                public void onResponseReceived(NetworkResponse response) {
                    if (response.succeed) {
                        //TODO pare your shipping addresses here
                        dataQueryHandler.onSuccess(response.msg);
                    } else {
                        dataQueryHandler.onFailure(response.error);
                    }
                }
            });
        }
    }

    public void updateShippingAddressesInBackground(int userId, String addressJson, final DataQueryHandler dataQueryHandler) {
        if (hasNetworkAccess(dataQueryHandler)) {
            final Map<String, String> params = new HashMap<>();
            params.put("type", DataHelper.encrypt("update"));
            params.put("user_id", DataHelper.encrypt(userId));
            params.put("address", DataHelper.encrypt(addressJson));
            NetworkRequest.makeCommonPostRequest(url_multiple_shipping_address, params, null, new NetworkResponse.ResponseListener() {
                @Override
                public void onResponseReceived(NetworkResponse response) {
                    if (response.succeed) {
                        dataQueryHandler.onSuccess(response.msg);
                    } else {
                        dataQueryHandler.onFailure(response.error);
                    }
                }
            });
        }
    }

    public void getMultiStoreCheckoutDataInBackground(final DataQueryHandler dataQueryHandler) {
        if (hasNetworkAccess(dataQueryHandler)) {
            final Map<String, String> params = new HashMap<>();
            params.put("type", DataHelper.encrypt("view"));
            NetworkRequest.makeCommonPostRequest(url_checkout_manager, params, null, new NetworkResponse.ResponseListener() {
                @Override
                public void onResponseReceived(NetworkResponse response) {
                    if (response.succeed) {
                        dataQueryHandler.onSuccess(response.msg);
                    } else {
                        dataQueryHandler.onFailure(response.error);
                    }
                }
            });
        }
    }

    public void getOrderMetaDataInBackground(List<TM_Order> orderList, final DataQueryHandler dataQueryHandler) {
        if (hasNetworkAccess(dataQueryHandler)) {
            Map<String, String> params = new HashMap<>();
            params.put("type", DataHelper.encrypt("view_order"));
            params.put("order_ids", DataHelper.encrypt(DataHelper.getOrderIdJSONString(orderList)));

            NetworkRequest.makeCommonPostRequest(url_checkout_manager, params, null, new NetworkResponse.ResponseListener() {
                @Override
                public void onResponseReceived(NetworkResponse response) {
                    if (response.succeed) {
                        if (WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                            return;
                        }
                        try {
                            dataQueryHandler.onSuccess(response.msg);
                        } catch (Exception ex) {
                            ex.printStackTrace();
                            dataQueryHandler.onFailure(new Exception("Error while loading delivery address"));
                        }
                    } else {
                        dataQueryHandler.onFailure(response.error);
                    }
                }
            });
        }
    }

    public void getOrderPaymentProofInBackground(final List<TM_Order> orderList, final DataQueryHandler dataQueryHandler) {
        if (hasNetworkAccess(dataQueryHandler)) {
            Map<String, String> params = new HashMap<>();
            params.put("type", DataHelper.encrypt("get"));
            params.put("order_ids", DataHelper.encrypt(DataHelper.getOrderIdJSONString(orderList)));
            NetworkRequest.makeCommonPostRequest(url_order_approval, params, null, new NetworkResponse.ResponseListener() {
                @Override
                public void onResponseReceived(NetworkResponse response) {
                    if (response.succeed) {
                        if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                            try {
                                dataQueryHandler.onSuccess(response.msg);
                            } catch (Exception ex) {
                                ex.printStackTrace();
                                dataQueryHandler.onFailure(new Exception("Error while loading data"));
                            }
                        }
                    } else {
                        dataQueryHandler.onFailure(response.error);
                    }
                }
            });
        }
    }

    public void updateOrderPaymentProofInBackground(int orderId, String url, final DataQueryHandler dataQueryHandler) {
        if (hasNetworkAccess(dataQueryHandler)) {
            Map<String, String> params = new HashMap<>();
            params.put("type", DataHelper.encrypt("update"));
            params.put("file_url", DataHelper.encrypt(url));
            params.put("order_id", DataHelper.encrypt(orderId));
            NetworkRequest.makeCommonPostRequest(url_order_approval, params, null, new NetworkResponse.ResponseListener() {
                @Override
                public void onResponseReceived(NetworkResponse response) {
                    if (response.succeed) {
                        if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                            try {
                                dataQueryHandler.onSuccess(response.msg);
                            } catch (Exception ex) {
                                ex.printStackTrace();
                                dataQueryHandler.onFailure(new Exception("Error while loading data"));
                            }
                        }
                    } else {
                        dataQueryHandler.onFailure(response.error);
                    }
                }
            });
        }
    }

    public void updateOrderMetaDataInBackground(Map<String, String> params, final DataQueryHandler dataQueryHandler) {
        if (hasNetworkAccess(dataQueryHandler)) {
            NetworkRequest.makeCommonPostRequest(url_checkout_manager, params, null, new NetworkResponse.ResponseListener() {
                @Override
                public void onResponseReceived(NetworkResponse response) {
                    if (response.succeed) {
                        dataQueryHandler.onSuccess(response.msg);
                    } else {
                        dataQueryHandler.onFailure(response.error);
                    }
                }
            });
        }
    }

    public void requestOtpVerifyInBackground(String type, String mobile_no, String otp_code, String request_id, final DataQueryHandler<String> dataQueryHandler) {
        if (hasNetworkAccess(dataQueryHandler)) {
            final Map<String, String> params = new HashMap<>();
            params.put("type", DataHelper.encrypt(type));
            params.put("mobile", DataHelper.encrypt(mobile_no));
            params.put("otp_code", DataHelper.encrypt(otp_code));
            params.put("request_id", DataHelper.encrypt(request_id));
            handleOTPInBackground(url_otp, params, dataQueryHandler);
        }
    }

    public void requestLoginOtpInBackground(String mobile_no, final DataQueryHandler<String> dataQueryHandler) {
        if (hasNetworkAccess(dataQueryHandler)) {
            final Map<String, String> params = new HashMap<>();
            params.put("type", DataHelper.encrypt("send"));
            params.put("mobile", DataHelper.encrypt(mobile_no));
            handleOTPInBackground(url_otp, params, dataQueryHandler);
        }
    }

    public void requestCheckoutOTPInBackground(String mobile_no, final DataQueryHandler<String> dataQueryHandler) {
        if (hasNetworkAccess(dataQueryHandler)) {
            final Map<String, String> params = new HashMap<>();
            params.put("type", DataHelper.encrypt("checkout_otp"));
            params.put("mobile", DataHelper.encrypt(mobile_no));
            handleOTPInBackground(url_otp, params, dataQueryHandler);
        }
    }

    private void handleOTPInBackground(String url_otp, Map<String, String> params, final DataQueryHandler<String> dataQueryHandler) {
        NetworkRequest.makeCommonPostRequest(url_otp, params, null, new NetworkResponse.ResponseListener() {
            @Override
            public void onResponseReceived(NetworkResponse response) {
                if (response.succeed) {
                    if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                        dataQueryHandler.onSuccess(response.msg);
                    }
                } else {
                    dataQueryHandler.onFailure(response.error);
                }
            }
        });
    }

    public void postReviewRatingInBackground(Map<String, String> params, final DataQueryHandler dataQueryHandler) {
        if (hasNetworkAccess(dataQueryHandler)) {
            DataHelper.encrypt(params);
            NetworkRequest.makeCommonPostRequest(url_add_review, params, null, new NetworkResponse.ResponseListener() {
                @Override
                public void onResponseReceived(NetworkResponse response) {
                    if (response.succeed) {
                        if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                            try {
                                JSONObject msgJsonObject = new JSONObject(response.msg);
                                String message = msgJsonObject.getString("message");
                                dataQueryHandler.onSuccess(message);
                            } catch (Exception e) {
                                e.printStackTrace();
                                dataQueryHandler.onFailure(e);
                            }
                        }
                    } else {
                        dataQueryHandler.onFailure(response.error);
                    }
                }
            });
        }
    }

    public void getDeliverySlotsInBackground(final DataQueryHandler<String> dataQueryHandler) {
        if (hasNetworkAccess(dataQueryHandler)) {
            HashMap<String, String> params = new HashMap<>();
            params.put("type", Base64Utils.encode("slot_list"));
            NetworkRequest.makeCommonPostRequest(url_delivery_slots_copia, params, null, new NetworkResponse.ResponseListener() {
                @Override
                public void onResponseReceived(NetworkResponse response) {
                    if (response.succeed) {
                        if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                            try {
                                dataQueryHandler.onSuccess(response.msg);
                            } catch (Exception e) {
                                e.printStackTrace();
                                dataQueryHandler.onFailure(e);
                            }
                        }
                    } else {
                        dataQueryHandler.onFailure(response.error);
                    }
                }
            });
        }
    }

    public void getOrdersMeta(final List<TM_Order> orderList, final DataQueryHandler dataQueryHandler) {
        if (!isNetworkAvailable()) {
            if (dataQueryHandler != null) {
                dataQueryHandler.onFailure(mNoConnectionError);
            }
            return;
        }

        Map<String, String> params = new HashMap<>();
        params.put("type", DataHelper.encrypt("find"));
        params.put("order_ids", DataHelper.encrypt(DataHelper.getOrderIdJSONString(orderList)));
        NetworkRequest.makeCommonPostRequest(url_order_meta, params, null, new NetworkResponse.ResponseListener() {
            @Override
            public void onResponseReceived(NetworkResponse response) {
                if (response.succeed) {
                    if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                        try {
                            WooCommerceJSONHelper.parseOrderMeta(response.msg, orderList);
                            dataQueryHandler.onSuccess(null);
                        } catch (Exception e) {
                            e.printStackTrace();
                            dataQueryHandler.onFailure(new Exception("Error while Getting OrdersMeta"));
                        }
                    }
                } else {
                    dataQueryHandler.onFailure(response.error);
                }
            }
        });
    }


    public void postOrdersMeta(Map<String, String> params, final DataQueryHandler dataQueryHandler) {
        if (hasNetworkAccess(dataQueryHandler)) {
            DataHelper.encrypt(params);
            NetworkRequest.makeCommonPostRequest(url_order_meta, params, null, new NetworkResponse.ResponseListener() {
                @Override
                public void onResponseReceived(NetworkResponse response) {
                    if (response.succeed) {
                        if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                            dataQueryHandler.onSuccess(response.msg);
                        }
                    } else {
                        dataQueryHandler.onFailure(response.error);
                    }
                }
            });
        }
    }

    public void getProductShortAttributes(final DataQueryHandler dataQueryHandler) {
        NetworkRequest.makeCommonGetRequest(url_product_attributes, null, new NetworkResponse.ResponseListener() {
            @Override
            public void onResponseReceived(NetworkResponse response) {
                DataHelper.log("-- getProductShortAttributes -response: [" + response.msg + "] --");
                if (response.succeed) {
                    if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                        try {
                            WooCommerceJSONHelper.parseAndCreateShortAttribute(response.msg);
                            dataQueryHandler.onSuccess(null);
                        } catch (Exception e) {
                            e.printStackTrace();
                            dataQueryHandler.onFailure(new Exception("Error while loading ProductVariation.."));
                        }
                    }
                } else {
                    dataQueryHandler.onFailure(response.error);
                }
            }
        });
    }

    public void getBlogsInBackground(final DataQueryHandler<String> dataQueryHandler) {
        if (hasNetworkAccess(dataQueryHandler)) {
            final Map<String, String> params = new HashMap<>();
            params.put("type", DataHelper.encrypt("blogs"));
            params.put("lang", DataHelper.encrypt(locale));
            params.put("limit", DataHelper.encrypt(-1));
            params.put("offset", DataHelper.encrypt(0));

            NetworkRequest.makeCommonPostRequest(url_blog_info, params, null, new NetworkResponse.ResponseListener() {
                @Override
                public void onResponseReceived(NetworkResponse response) {
                    if (response.succeed) {
                        if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                            DataHelper.log("-- getBlogsInBackground -response: [" + response.msg + "] --");
                            try {
                                WooCommerceJSONHelper.parseBlogsResponse(response.msg);
                                dataQueryHandler.onSuccess(response.msg);
                            } catch (JSONException e) {
                                e.printStackTrace();
                                dataQueryHandler.onFailure(response.error);
                            }
                        }
                    } else {
                        dataQueryHandler.onFailure(response.error);
                    }
                }
            });
        }
    }


    public void getProductAuctionInfo(final int[] productIds, final TM_ProductInfo productInfo, final DataQueryHandler<TM_ProductInfo> dataQueryHandler) {
        if (hasNetworkAccess(dataQueryHandler)) {
            Map<String, String> params = new HashMap<>();
            params.put("type", DataHelper.encrypt("get_auction"));
            params.put("pids", DataHelper.encrypt("[" + DataHelper.join(",", productIds) + "]"));
            NetworkRequest.makeCommonPostRequest(url_wc_auction, params, null, new NetworkResponse.ResponseListener() {
                @Override
                public void onResponseReceived(NetworkResponse response) {
                    if (response.succeed) {
                        if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                            DataHelper.log("-- getProductAuctionInfo -response: [" + response.msg + "] --");
                            try {
                                WooCommerceJSONHelper.parseProductAuctionInfo(response.msg, productInfo);
                                dataQueryHandler.onSuccess(productInfo);
                            } catch (Exception e) {
                                e.printStackTrace();
                                dataQueryHandler.onFailure(e);
                            }
                        }
                    } else {
                        dataQueryHandler.onFailure(response.error);
                    }
                }
            });
        }
    }

    public void requestProductAuctionBid(final TM_ProductInfo productInfo, final String bidAmount, final String email, final DataQueryHandler dataQueryHandler) {
        if (hasNetworkAccess(dataQueryHandler)) {
            Map<String, String> params = new HashMap<>();
            params.put("type", DataHelper.encrypt("place_bid"));
            params.put("product_id", DataHelper.encrypt(productInfo.id));
            params.put("bid_amount", DataHelper.encrypt(bidAmount));
            params.put("user_email", DataHelper.encrypt(email));

            NetworkRequest.makeCommonPostRequest(url_wc_auction, params, null, new NetworkResponse.ResponseListener() {
                @Override
                public void onResponseReceived(NetworkResponse response) {
                    if (response.succeed) {
                        if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                            DataHelper.log("-- requestProductAuctionBid -response: [" + response.msg + "] --");
                            try {
                                dataQueryHandler.onSuccess(response.msg);
                            } catch (Exception e) {
                                e.printStackTrace();
                                dataQueryHandler.onFailure(e);
                            }
                        }
                    } else {
                        dataQueryHandler.onFailure(response.error);
                    }
                }
            });
        }
    }

    public void getBlogInBackground(int blogId, final DataQueryHandler<BlogItem> dataQueryHandler) {
        if (hasNetworkAccess(dataQueryHandler)) {
            final Map<String, String> params = new HashMap<>();
            params.put("type", DataHelper.encrypt("blog"));
            params.put("blog_id", DataHelper.encrypt(blogId));

            NetworkRequest.makeCommonPostRequest(url_blog_info, params, null, new NetworkResponse.ResponseListener() {
                @Override
                public void onResponseReceived(NetworkResponse response) {
                    if (response.succeed) {
                        //TODO pare your response here
                        DataHelper.log("-- getBlogInBackground -response: [" + response.msg + "] --");
                        try {
                            dataQueryHandler.onSuccess(WooCommerceJSONHelper.parseBlogResponse(response.msg));
                        } catch (JSONException e) {
                            dataQueryHandler.onFailure(e);
                            e.printStackTrace();
                        }
                    } else {
                        dataQueryHandler.onFailure(response.error);
                    }
                }
            });
        }
    }

    public void getProductBookingInfoDate(final TM_ProductInfo productInfo, final DataQueryHandler dataQueryHandler) {
        if (hasNetworkAccess(dataQueryHandler)) {
            Map<String, String> params = new HashMap<>();
            params.put("type", DataHelper.encrypt("booking_slots"));
            params.put("product_id", DataHelper.encrypt(productInfo.id));/*352*/

            NetworkRequest.makeCommonPostRequest(url_woocommerce_bookings, params, null, new NetworkResponse.ResponseListener() {
                @Override
                public void onResponseReceived(NetworkResponse response) {
                    if (response.succeed) {
                        DataHelper.log("-- getProductBookingInfoDate::onResponse [" + response.msg + "] --");
                        if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                            try {
                                WooCommerceJSONHelper.parseProductBookingInfo(response.msg, productInfo);
                                dataQueryHandler.onSuccess(productInfo);
                            } catch (Exception e) {
                                e.printStackTrace();
                                dataQueryHandler.onFailure(new Exception("Error while loading product booking info.."));
                            }
                        }
                    } else {
                        dataQueryHandler.onFailure(response.error);
                    }
                }
            });
        }
    }

    public void getProductBookingInfoCost(final TM_ProductInfo product, String bookingDate, final DataQueryHandler dataQueryHandler) {
        if (hasNetworkAccess(dataQueryHandler)) {
            Map<String, String> params = new HashMap<>();
            params.put("type", DataHelper.encrypt("booking_price"));
            params.put("duration", DataHelper.encrypt("1"));
            params.put("date", DataHelper.encrypt(bookingDate));
            params.put("product_id", DataHelper.encrypt(product.id));

            NetworkRequest.makeCommonPostRequest(url_woocommerce_bookings, params, null, new NetworkResponse.ResponseListener() {
                @Override
                public void onResponseReceived(NetworkResponse response) {
                    if (response.succeed) {
                        DataHelper.log("-- getProductBookingInfoCost::onResponse [" + response.msg + "] --");
                        if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                            try {
                                dataQueryHandler.onSuccess(WooCommerceJSONHelper.parseProductBookingCostInfo(response.msg, product));
                            } catch (Exception e) {
                                e.printStackTrace();
                                dataQueryHandler.onFailure(new Exception("Error while loading product booking cost info.."));
                            }
                        }
                    } else {
                        dataQueryHandler.onFailure(response.error);
                    }
                }
            });
        }
    }

    public void postOrderCreateBookingInfo(String cartData, final DataQueryHandler dataQueryHandler) {
        if (hasNetworkAccess(dataQueryHandler)) {
            Map<String, String> params = new HashMap<>();
            params.put("type", DataHelper.encrypt("create_booking"));
            params.put("cart_data", cartData);
            DataHelper.log("-- WooCommerceEngine::postOrderCreateBookingInfo (" + params + ")--");
            NetworkRequest.makeCommonPostRequest(url_woocommerce_bookings, params, null, new NetworkResponse.ResponseListener() {
                @Override
                public void onResponseReceived(NetworkResponse response) {
                    if (response.succeed) {
                        if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                            DataHelper.log("-- postOrderCreateBookingInfo::onResponse [" + response.msg + "] --");
                            try {
                                dataQueryHandler.onSuccess(response.msg);
                            } catch (Exception e) {
                                e.printStackTrace();
                                dataQueryHandler.onFailure(new Exception("Error while loading delivery slots"));
                            }
                        }
                    } else {
                        dataQueryHandler.onFailure(response.error);
                    }
                }
            });
        }
    }

    public void postOrderUpdateBookingInfo(int orderId, int orderBookingID, final DataQueryHandler dataQueryHandler) {
        if (hasNetworkAccess(dataQueryHandler)) {
            Map<String, String> params = new HashMap<>();
            params.put("type", DataHelper.encrypt("update_booking"));
            params.put("order_id", DataHelper.encrypt(orderId));
            params.put("booking_id", DataHelper.encrypt(orderBookingID));
            DataHelper.log("-- WooCommerceEngine::postOrderUpdateBookingInfo (" + params + ")--");
            NetworkRequest.makeCommonPostRequest(url_woocommerce_bookings, params, null, new NetworkResponse.ResponseListener() {
                @Override
                public void onResponseReceived(NetworkResponse response) {
                    if (response.succeed) {
                        if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                            DataHelper.log("-- postOrderUpdateBookingInfo::onResponse [" + response.msg + "] --");
                            try {
                                dataQueryHandler.onSuccess(response.msg);
                            } catch (Exception e) {
                                e.printStackTrace();
                                dataQueryHandler.onFailure(new Exception("Error while loading delivery slots"));
                            }
                        }
                    } else {
                        dataQueryHandler.onFailure(response.error);
                    }
                }
            });
        }
    }

    public void getOrderBookingInfoStatus(final List<TM_Order> orders_list, final DataQueryHandler dataQueryHandler) {
        if (hasNetworkAccess(dataQueryHandler)) {
            Map<String, String> params = new HashMap<>();
            params.put("type", DataHelper.encrypt("order_booking_status"));
            params.put("order_ids", DataHelper.encrypt(DataHelper.getOrderIdJSONString(orders_list)));
            DataHelper.log("-- WooCommerceEngine::postOrderBookingInfoStatus (" + params + ")--");
            NetworkRequest.makeCommonPostRequest(url_woocommerce_bookings, params, null, new NetworkResponse.ResponseListener() {
                @Override
                public void onResponseReceived(NetworkResponse response) {
                    if (response.succeed) {
                        if (!WooCommerceJSONHelper.hasResponseError(response.msg, dataQueryHandler)) {
                            DataHelper.log("-- postOrderBookingInfoStatus::onResponse [" + response.msg + "] --");
                            try {
                                WooCommerceJSONHelper.parseOrderBookingSlots(response.msg, orders_list);
                                dataQueryHandler.onSuccess(response.msg);
                            } catch (Exception e) {
                                e.printStackTrace();
                                dataQueryHandler.onFailure(new Exception("Error while loading booking slots"));
                            }
                        }
                    } else {
                        dataQueryHandler.onFailure(response.error);
                    }
                }
            });
        }
    }
}