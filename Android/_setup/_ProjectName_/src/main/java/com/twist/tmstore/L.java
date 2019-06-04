package com.twist.tmstore;

import android.app.Application;
import android.content.Context;
import android.content.SharedPreferences;
import android.content.res.Configuration;
import android.content.res.Resources;
import com.parse.*;
import com.twist.dataengine.DataEngine;
import com.utils.JsonHelper;
import com.utils.Log;
import com.utils.Preferences;
import org.json.JSONArray;
import org.json.JSONObject;

import java.io.*;
import java.util.List;
import java.util.Locale;

/**
 * Created by Twist Mobile on 04-Jul-16.
 */

public class L {
    interface LoadCallback {
        void onSuccess(boolean upgraded);

        void onError();
    }

    private static L l;

    public static L getInstance() {
        if (l == null) {
            l = new L();
            l.setLanguage(new Language());
        }
        return l;
    }

    public String getLocale() throws Exception {
        return Preferences.getString((R.string.key_app_lang), L.getInstance().getLanguage().defaultLocale).split("_")[0];
    }

    /* json for
    * {
         "config": {
            "language": {
              "version": 1,
              "defaultLocale": "hi_IN",
              "locales": [
                {
                  "locale": "en_US",
                  "title": "English",
                  "wpml_enabled": true
                },
                {
                  "locale": "hi_IN",
                  "title": "हिंदी",
                  "wpml_enabled": true
                }
              ]
            }
          }
        }
    * */

    public static class LocaleConfig {
        String locale = "";
        String title = "";
        boolean wpml = false;
    }

    public static class Language {
        int version = 0;
        public String defaultLocale = "en_US";

        LocaleConfig[] localeConfigs;

        Language() {
            this.version = 0;
            this.defaultLocale = "en_US";
        }

        public static Language parse(String jsonString) throws Exception {
            JSONObject languageJsonObj = new JSONObject(jsonString);
            Language language = new Language();
            language.version = languageJsonObj.getInt("version");
            language.defaultLocale = JsonHelper.getString(languageJsonObj, "defaultLocale", "en_US");
            if (jsonString.contains("wpml")) {
                JSONArray localesJsonArray = languageJsonObj.getJSONArray("locales");
                int length = localesJsonArray.length();
                language.localeConfigs = new LocaleConfig[length];
                for (int i = 0; i < length; i++) {
                    JSONObject localeJsonObj = localesJsonArray.getJSONObject(i);
                    LocaleConfig localeConfig = new LocaleConfig();
                    localeConfig.locale = localeJsonObj.getString("locale");
                    localeConfig.title = localeJsonObj.getString("title");
                    localeConfig.wpml = localeJsonObj.getBoolean("wpml");
                    language.localeConfigs[i] = localeConfig;
                }
            } else {
                JSONArray localesJsonArray = languageJsonObj.getJSONArray("locales");
                JSONArray titlesJsonArray = languageJsonObj.getJSONArray("titles");
                int localesLength = localesJsonArray.length();
                language.localeConfigs = new LocaleConfig[localesLength];
                for (int i = 0; i < localesLength; i++) {
                    LocaleConfig localeConfig = new LocaleConfig();
                    localeConfig.locale = localesJsonArray.getString(i);
                    localeConfig.title = titlesJsonArray.getString(i);
                    localeConfig.wpml = false;
                    language.localeConfigs[i] = localeConfig;
                }
            }
            return language;
        }

        public String[] getLocales() {
            if (localeConfigs != null) {
                int length = localeConfigs.length;
                String[] locales = new String[length];
                for (int i = 0; i < length; i++) {
                    locales[i] = localeConfigs[i].locale;
                }
                return locales;
            }
            return null;
        }

        public String[] getTitles() {
            if (localeConfigs != null) {
                int length = localeConfigs.length;
                String[] titles = new String[length];
                for (int i = 0; i < length; i++) {
                    titles[i] = localeConfigs[i].title;
                }
                return titles;
            }
            return null;
        }

        public LocaleConfig findLocaleConfig(String locale) {
            if (localeConfigs != null) {
                for (LocaleConfig localeConfig : localeConfigs) {
                    if (localeConfig.locale.equalsIgnoreCase(locale)) {
                        return localeConfig;
                    }
                }
            }
            return null;
        }
    }

    private Context mContext = null;

    private JSONObject mJsonObject;

    private int mLocaleSuccessCount = 0;

    private int mLocaleErrorCount = 0;

    private int mLocaleDownloadCount = 0;

    private Language mLanguage;

    public void setLanguage(Language language) {
        this.mLanguage = language;
    }

    public Language getLanguage() {
        return mLanguage;
    }

    public void init(Context context) {
        mContext = context;
        loadFromAssets();
    }

    private void loadFromAssets() {
        if (BuildConfig.DEMO_VERSION) {
            String fileName = String.format(Locale.ENGLISH, "languages/%s.json", mLanguage.defaultLocale);
            StringBuilder result = null;
            BufferedReader reader = null;
            try {
                reader = new BufferedReader(new InputStreamReader(mContext.getAssets().open(fileName), "UTF-8"));
                result = new StringBuilder();
                String line;
                while ((line = reader.readLine()) != null) {
                    result.append(line);
                }
            } catch (IOException e) {
                e.printStackTrace();
            } finally {
                if (reader != null) {
                    try {
                        reader.close();
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
            }

            if (result != null) {
                try {
                    mJsonObject = new JSONObject(result.toString());
                } catch (Exception e) {
                    e.printStackTrace();
                }
            } else {
                Log.d("Language file not found in assets");
            }
        }
    }

    public static void loadLanguagesAsync(final LoadCallback loadCallback) {
        L.getInstance()._loadLanguagesAsync(loadCallback);
    }

    private boolean hasLocale(String locale) {
        if (mLanguage.localeConfigs != null) {
            for (LocaleConfig localeConfig : mLanguage.localeConfigs) {
                if (localeConfig.locale.equalsIgnoreCase(locale)) {
                    return true;
                }
            }
        }
        return false;
    }

    private void _loadLanguagesAsync(final LoadCallback loadCallback) {
        if (mLanguage.localeConfigs == null || mLanguage.localeConfigs.length == 0) {
            loadCallback.onSuccess(false);
            return;
        }

        final SharedPreferences preferences = mContext.getSharedPreferences("settings", Context.MODE_PRIVATE);
        if (preferences.getInt("version", 0) >= mLanguage.version) {
            mLocaleSuccessCount = 0;
            loadCallback.onSuccess(false);
            return;
        }

        if (BuildConfig.DEMO_VERSION) {
            loadCallback.onSuccess(true);
            return;
        }

        ParseQuery<ParseObject> query = ParseQuery.getQuery("LANGUAGES");
        query.findInBackground(new FindCallback<ParseObject>() {
            @Override
            public void done(final List<ParseObject> objects, ParseException e) {
                if (e == null) {
                    int excludedLocales = 0;
                    for (final ParseObject parseObject : objects) {
                        final String localeName = parseObject.getString("locale");
                        if (!hasLocale(localeName)) {
                            excludedLocales++;
                            continue;
                        }

                        final ParseFile jsonFile = parseObject.getParseFile("file");
                        if (jsonFile != null) {
                            jsonFile.getDataInBackground(new GetDataCallback() {
                                @Override
                                public void done(byte[] data, ParseException e) {
                                    mLocaleDownloadCount++;
                                    if (e == null) {
                                        try {
                                            FileOutputStream outputStream = mContext.openFileOutput(localeName + ".json", Context.MODE_PRIVATE);
                                            BufferedOutputStream bos = new BufferedOutputStream(outputStream);
                                            bos.write(data);
                                            bos.flush();
                                            bos.close();
                                            Log.d("Language for Locale [" + localeName + "] downloaded successfully.");
                                            mLocaleSuccessCount++;
                                        } catch (Exception e1) {
                                            e1.printStackTrace();
                                            Log.d("Error while downloading language for Locale " + localeName);
                                            mLocaleErrorCount++;
                                        }
                                    } else {
                                        mLocaleErrorCount++;
                                    }

                                    if (mLocaleSuccessCount > 0 && mLocaleSuccessCount == mLanguage.localeConfigs.length) {
                                        preferences.edit().putInt("version", mLanguage.version).apply();
                                        mLocaleErrorCount = 0;
                                        mLocaleSuccessCount = 0;
                                        mLocaleDownloadCount = 0;
                                        loadCallback.onSuccess(true);
                                    } else {
                                        if (mLocaleDownloadCount == mLanguage.localeConfigs.length && mLocaleErrorCount > 0) {
                                            onLanguageLoadError(loadCallback);
                                        }
                                    }
                                }
                            });
                        } else {
                            mLocaleErrorCount++;
                            if (mLocaleErrorCount >= mLanguage.localeConfigs.length && mLocaleErrorCount <= objects.size()) {
                                onLanguageLoadError(loadCallback);
                            }
                        }
                    }
                    // if all locales are excluded
                    if (excludedLocales == objects.size()) {
                        onLanguageLoadError(loadCallback);
                    }
                } else {
                    onLanguageLoadError(loadCallback);
                }
            }
        });
    }

    private void onLanguageLoadError(final LoadCallback loadCallback) {
        mLocaleErrorCount = 0;
        mLocaleSuccessCount = 0;
        mLocaleDownloadCount = 0;
        loadCallback.onError();
    }

    void loadDefault() {
        this.loadLocale(mLanguage.defaultLocale);
    }

    void loadLocale(final String localeName) {
        mLanguage.defaultLocale = localeName;
        this.setWebLocale(localeName);
        if (BuildConfig.DEMO_VERSION) {
            loadFromAssets();
            changeLocale(mLanguage.defaultLocale);
        } else {
            try {
                loadFromStorage();
                changeLocale(mLanguage.defaultLocale);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    private void loadFromStorage() throws Exception {
        try {
            FileInputStream inputStream = mContext.openFileInput(mLanguage.defaultLocale + ".json");
            BufferedReader input = new BufferedReader(new InputStreamReader(inputStream));
            String line;
            StringBuilder buffer = new StringBuilder();
            while ((line = input.readLine()) != null) {
                buffer.append(line);
            }
            input.close();
            inputStream.close();
            try {
                mJsonObject = new JSONObject(buffer.toString());
            } catch (Exception e) {
                e.printStackTrace();
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    /*
     *  Set locale for the WPML Plugin.
     * */
    private void setWebLocale(String locale) {
        Language language = getInstance().getLanguage();
        LocaleConfig localeConfig = language.findLocaleConfig(locale);
        String str = "";
        if (localeConfig != null && localeConfig.wpml) {
            try {
                str = locale.split("_")[0];
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        if (DataEngine.getDataEngine() != null) {
            DataEngine.getDataEngine().setLocale(str);
        }
    }

    public boolean isWPMLEnabled(String locale) {
        Language language = L.getInstance().getLanguage();
        LocaleConfig localeConfig = language.findLocaleConfig(locale);
        return (localeConfig != null && localeConfig.wpml);
    }

    private static void changeLocale(String language) {
        L.getInstance()._changeLocale(language);
    }

    public static String getString(final String key) {
        return L.getInstance()._getString(key);
    }

    /* It replace existing Integer and Float formats with String to prevent possible crash if there is a change in argument data type. */
    public static String getString(String key, boolean ignoreFormat) {
        String str = L.getInstance()._getString(key);
        if (ignoreFormat) {
            str = str.replaceAll("%d", "%s");
            str = str.replaceAll("%f", "%s");
            str = str.replaceAll("%@", "%s");

            str = str.replaceAll("% d", "%s");
            str = str.replaceAll("% f", "%s");
            str = str.replaceAll("% @", "%s");
        }
        return str;
    }

    private void _changeLocale(String language) {
        Application application = (Application) mContext;
        Locale locale = new Locale(language.toLowerCase());
        Locale.setDefault(locale);

        {
            // patch for for changing locale in calendar
            locale = mContext.getResources().getConfiguration().locale;
            Locale.setDefault(locale);
        }

        Resources resources = application.getBaseContext().getResources();
        Configuration configuration = resources.getConfiguration();
        configuration.locale = locale;
        resources.updateConfiguration(configuration, resources.getDisplayMetrics());
    }

    private String _getString(final String key) {
        String value;
        try {
            value = mJsonObject.getString(key);
        } catch (Exception e) {
            Log.d("No value for key in JSON {" + key + "}");
            int resId = getResId(key, "string", mContext.getPackageName());
            if (resId > 0) {
                value = mContext.getString(resId);
            } else {
                Log.d("No value for key in XML {" + key + "}");
                value = key;
            }
        }
        return value;
    }

    private int getResId(String var, String res, String pkg) {
        try {
            return mContext.getResources().getIdentifier(var, res, pkg);
        } catch (Exception e) {
            e.printStackTrace();
            return -1;
        }
    }

    public class string {

        public static final String app_name = "app_name";
        public static final String title_shop = "title_shop";
        public static final String reservating_time_slots = "reservating_time_slots";
        public static final String title_wishlist = "title_wishlist";
        public static final String select_wishlist = "select_wishlist";
        public static final String create_wishlist_message = "create_wishlist_message";
        public static final String title_myorders = "title_myorders";
        public static final String title_settings = "title_settings";
        public static final String title_about = "title_about";
        public static final String title_logout = "title_logout";
        public static final String title_login = "title_login";
        public static final String title_login_as_vendor = "title_login_as_vendor";
        public static final String title_profile = "title_profile";
        public static final String title_categories = "title_categories";
        public static final String title_groups = "title_groups";
        public static final String title_polls = "title_polls";
        public static final String title_poll = "title_poll";
        public static final String title_edit_product = "title_edit_product";
        public static final String title_new_product = "title_new_product";
        public static final String title_change_vendor = "title_change_vendor";
        public static final String seller_my_products = "seller_my_products";
        public static final String seller_upload_product = "seller_upload_product";
        public static final String seller_my_orders = "seller_my_orders";
        public static final String seller_my_wallet = "seller_my_wallet";
        public static final String generic_server_timeout = "generic_server_timeout";
        public static final String generic_error = "generic_error";
        public static final String some_problem_occurred = "some_problem_occurred";
        public static final String demo_code_help_1 = "demo_code_help_1";
        public static final String demo_code_help_2 = "demo_code_help_2";
        public static final String title_dialog_get_code = "title_dialog_get_code";
        public static final String get_code_step_1 = "get_code_step_1";
        public static final String get_code_step_2 = "get_code_step_2";
        public static final String get_code_step_3 = "get_code_step_3";
        public static final String get_code_step_4 = "get_code_step_4";
        public static final String get_code_step_5 = "get_code_step_5";
        public static final String get_code_step_6 = "get_code_step_6";
        public static final String get_code_step_7 = "get_code_step_7";
        public static final String get_code_step_8 = "get_code_step_8";
        public static final String get_code_step_9 = "get_code_step_9";
        public static final String get_code_step_10 = "get_code_step_10";
        public static final String launch_sample_app = "launch_sample_app";
        public static final String prompt_demo_code = "prompt_demo_code";
        public static final String enter = "enter";
        public static final String invalid_demo_code = "invalid_demo_code";
        public static final String demo_code_not_found = "demo_code_not_found";
        public static final String loading_products = "loading_products";
        public static final String loading_vendors = "loading_vendors";
        public static final String out_of_stock = "out_of_stock";
        public static final String edit_profile = "edit_profile";
        public static final String loading_available_countries = "loading_available_countries";
        public static final String loading_available_states = "loading_available_states";
        public static final String loading_available_cities = "loading_available_cities";
        public static final String loading_available_subdistricts = "loading_available_subdistricts";
        public static final String loading_available_province = "loading_available_province";
        public static final String invalid_postal_code = "invalid_postal_code";
        public static final String invalid_contact_number = "invalid_contact_number";
        public static final String invalid_email = "invalid_email";
        public static final String invalid_first_name = "invalid_first_name";
        public static final String invalid_last_name = "invalid_last_name";
        public static final String invalid_shop_name = "invalid_shop_name";
        public static final String invalid_shop_address = "invalid_shop_address";
        public static final String invalid_city = "invalid_city";
        public static final String invalid_address = "invalid_address";
        public static final String error_updating_customer_data = "error_updating_customer_data";
        public static final String already_have_same_shipping_address = "already_have_same_shipping_address";
        public static final String billing_address = "billing_address";
        public static final String shipping_address = "shipping_address";
        public static final String first_name = "first_name";
        public static final String last_name = "last_name";
        public static final String email_address = "email_address";
        public static final String mobile_number = "mobile_number";
        public static final String address = "address";
        public static final String city = "city";
        public static final String subdistrict = "subdistrict";
        public static final String province = "province";
        public static final String postcode = "postcode";
        public static final String email = "email";
        public static final String contact_number = "contact_number";
        public static final String shipping_as_billing_address = "shipping_as_billing_address";
        public static final String update = "update";
        public static final String country = "country";
        public static final String state = "state";
        public static final String add_billing_address = "add_billing_address";
        public static final String basic_details = "basic_details";
        public static final String updating = "updating";
        public static final String prompt_email = "prompt_email";
        public static final String prompt_password = "prompt_password";
        public static final String prompt_password_confirm = "prompt_password_confirm";
        public static final String text_autofill = "text_autofill";
        public static final String action_sign_in_short = "action_sign_in_short";
        public static final String action_sign_up_short = "action_sign_up_short";
        public static final String action_sign_up_title = "action_sign_up_title";
        public static final String already_have_account = "already_have_account";
        public static final String sign_in_here = "sign_in_here";
        public static final String sign_up_here = "sign_up_here";
        public static final String login_failed = "login_failed";
        public static final String password_required = "password_required";
        public static final String passwords_mismatch = "passwords_mismatch";
        public static final String google_signin_failed = "google_signin_failed";
        public static final String or = "or";
        public static final String sign_in_1_click = "sign_in_1_click";
        public static final String facebook_access_canceled = "facebook_access_canceled";
        public static final String signing_in = "signing_in";
        public static final String signing_up = "signing_up";
        public static final String retrieving = "retrieving";
        public static final String whatsapp_install_error = "whatsapp_install_error";
        public static final String whatsapp_tutorial = "whatsapp_tutorial";
        public static final String keep_shopping = "keep_shopping";
        public static final String keep_shopping_cart = "keep_shopping_cart";
        public static final String no_items_in_wishlist = "no_items_in_wishlist";
        public static final String label_quantity = "label_quantity";
        public static final String loading_checking_app_id = "loading_checking_app_id";
        public static final String loading_product_details = "loading_product_details";
        public static final String product_not_for_sale = "product_not_for_sale";
        public static final String view_cart = "view_cart";
        public static final String not_signed_in = "not_signed_in";
        public static final String loading = "loading";
        public static final String select_payment = "select_payment";
        public static final String nothing_to_display = "nothing_to_display";
        public static final String no_products = "no_products";
        public static final String complete_profile = "complete_profile";
        public static final String exit_message = "exit_message";
        public static final String menu_title_home = "menu_title_home";
        public static final String menu_title_cart = "menu_title_cart";
        public static final String menu_title_wishlist = "menu_title_wishlist";
        public static final String show_more = "show_more";
        public static final String show_less = "show_less";
        public static final String menu_title_search = "menu_title_search";
        public static final String menu_title_call = "menu_title_call";
        public static final String menu_title_opinion = "menu_title_opinion";
        public static final String send_email = "send_email";
        public static final String powered_by_tm_store = "powered_by_tm_store";
        public static final String address_not_set = "address_not_set";
        public static final String cancel_order = "cancel_order";
        public static final String track_order = "track_order";
        public static final String please_wait = "please_wait";
        public static final String msg_cancel_order = "msg_cancel_order";
        public static final String retry = "retry";
        public static final String cancel = "cancel";
        public static final String no_internet_connection = "no_internet_connection";
        public static final String checking_app_data = "checking_app_data";
        public static final String error_loading_data = "error_loading_data";
        public static final String error_wishlist_share = "error_wishlist_share";
        public static final String service_not_active = "service_not_active";
        public static final String outdated_version = "outdated_version";
        public static final String parse_object_error = "parse_object_error";
        public static final String title_dialog_update = "title_dialog_update";
        public static final String update_message_forcefully = "update_message_forcefully";
        public static final String update_message_ask = "update_message_ask";
        public static final String later = "later";
        public static final String update_now = "update_now";
        public static final String fetching_product_info = "fetching_product_info";
        public static final String signin_failed = "signin_failed";
        public static final String no_data = "no_data";
        public static final String product_not_available = "product_not_available";
        public static final String category_not_available = "category_not_available";
        public static final String explore_now = "explore_now";
        public static final String no_product_or_sub_category = "no_product_or_sub_category";
        public static final String outdated_product = "outdated_product";
        public static final String remove_from_cart = "remove_from_cart";
        public static final String retrieving_cart = "retrieving_cart";
        public static final String verifying_cart = "verifying_cart";
        public static final String item_added_to_cart = "item_added_to_cart";
        public static final String item_moved_to_wishlist = "item_moved_to_wishlist";
        public static final String qty = "qty";
        public static final String msg_remove_coupon = "msg_remove_coupon";
        public static final String item_added_to_wishlist = "item_added_to_wishlist";
        public static final String item_removed_from_wishlist = "item_removed_from_wishlist";
        public static final String title_dialog_cart_update = "title_dialog_cart_update";
        public static final String title_cart = "title_cart";
        public static final String title_coupons = "title_coupons";
        public static final String no_items_in_cart = "no_items_in_cart";
        public static final String add_to_cart = "add_to_cart";
        public static final String add_to_wishlist = "add_to_wishlist";
        public static final String add_to_mlultiple_wishlist = "add_to_mlultiple_wishlist";
        public static final String attribute_name_unavailable = "attribute_name_unavailable";
        public static final String price_range_header = "price_range_header";
        public static final String show_discounted_only = "show_discounted_only";
        public static final String exclude_out_of_stock = "exclude_out_of_stock";
        public static final String txt_select_category = "txt_select_category";
        public static final String reset_all_filters = "reset_all_filters";
        public static final String sort_by = "sort_by";
        public static final String price_range = "price_range";
        public static final String stock_check = "stock_check";
        public static final String discount = "discount";
        public static final String clear_filters = "clear_filters";
        public static final String title_filter = "title_filter";
        public static final String select_filter_to_apply = "select_filter_to_apply";
        public static final String apply = "apply";
        public static final String invalid_coupon_code = "invalid_coupon_code";
        public static final String coupon_code_copied = "coupon_code_copied";
        public static final String no_coupon_available = "no_coupon_available";
        public static final String coupon_applied_successfully = "coupon_applied_successfully";
        public static final String coupon_not_applicable_for_products = "coupon_not_applicable_for_products";
        public static final String coupon_expired = "coupon_expired";
        public static final String coupon_not_applicable_for_category = "coupon_not_applicable_for_category";
        public static final String coupon_surpasses_total_usage_limit = "coupon_surpasses_total_usage_limit";
        public static final String coupon_exceeds_usage_limit = "coupon_exceeds_usage_limit";
        public static final String coupon_invalid_for_already_sale_items = "coupon_invalid_for_already_sale_items";
        public static final String coupon_not_applicable_for_email = "coupon_not_applicable_for_email";
        public static final String applied_coupons = "applied_coupons";
        public static final String apply_new_coupon = "apply_new_coupon";
        public static final String enter_coupon_code = "enter_coupon_code";
        public static final String total_savings = "total_savings";
        public static final String place_order = "place_order";
        public static final String you_need_to_login_first = "you_need_to_login_first";
        public static final String login_to_share_wishlist = "login_to_share_wishlist";
        public static final String not_available = "not_available";
        public static final String wish_list_deleted_error = "wish_list_deleted_error";
        public static final String filter_details = "filter_details";
        public static final String no_more_products_found = "no_more_products_found";
        public static final String confirm_order = "confirm_order";
        public static final String cart_totals = "cart_totals";
        public static final String title_meta_section_group = "title_meta_section_group";
        public static final String saved_addresses = "saved_addresses";
        public static final String change = "change";
        public static final String select_from_saved_addresses = "select_from_saved_addresses";
        public static final String opinion_message = "opinion_message";
        public static final String retry_payment = "retry_payment";
        public static final String failure_reason = "failure_reason";
        public static final String order_payment_failed = "order_payment_failed";
        public static final String contact_or_retry_payment = "contact_or_retry_payment";
        public static final String order_placed = "order_placed";
        public static final String updating_order = "updating_order";
        public static final String fetching_orders = "fetching_orders";
        public static final String cancellation_requested_successfully = "cancellation_requested_successfully";
        public static final String no_orders = "no_orders";
        public static final String share = "share";
        public static final String share_via = "share_via";
        public static final String share_via_whatsapp = "share_via_whatsapp";
        public static final String product_out_of_stock = "product_out_of_stock";
        public static final String loading_variations = "loading_variations";
        public static final String variation_out_of_stock = "variation_out_of_stock";
        public static final String select_a_variation_first = "select_a_variation_first";
        public static final String select_attribute = "select_attribute";
        public static final String select_attribute_dialog_title = "select_attribute_dialog_title";
        public static final String variation_not_for_sale = "variation_not_for_sale";
        public static final String creating_opinion_poll = "creating_opinion_poll";
        public static final String updating_opinion_data = "updating_opinion_data";
        public static final String buy = "buy";
        public static final String reviews = "reviews";
        public static final String load_comments = "load_comments";
        public static final String title_search = "title_search";
        public static final String recent_searches = "recent_searches";
        public static final String no_recent_item = "no_recent_item";
        public static final String syncing_cart = "syncing_cart";
        public static final String contacting_website = "contacting_website";
        public static final String unable_to_create_order_now = "unable_to_create_order_now";
        public static final String registering_order = "registering_order";
        public static final String shipping_unavailable_for_region = "shipping_unavailable_for_region";
        public static final String shipping_not_required = "shipping_not_required";
        public static final String select_payment_method = "select_payment_method";
        public static final String no_shipping_method_found = "no_shipping_method_found";
        public static final String grand_total = "grand_total";
        public static final String available_payment_options = "available_payment_options";
        public static final String proceed = "proceed";
        public static final String calculating_time_slots = "calculating_time_slots";
        public static final String title_available_time_slots = "title_available_time_slots";
        public static final String select_delivery_date = "select_delivery_date";
        public static final String dont_have_account = "dont_have_account";
        public static final String shipment_tracking_id_unavailable = "shipment_tracking_id_unavailable";
        public static final String header_best_deals = "header_best_deals";
        public static final String header_fresh_arrival = "header_fresh_arrival";
        public static final String header_recently_viewed = "header_recently_viewed";
        public static final String header_trending_items = "header_trending_items";
        public static final String header_related_products = "header_related_products";
        public static final String header_upsells_products = "header_upsells_products";
        public static final String average_user_ratings = "average_user_ratings";
        public static final String title_product_info = "title_product_info";
        public static final String msg_no_review = "msg_no_review";
        public static final String txt_search_hint = "txt_search_hint";
        public static final String txt_search_hint_home = "txt_search_hint_home";
        public static final String my_orders = "my_orders";
        public static final String your_order_placed = "your_order_placed";
        public static final String instructions = "instructions";
        public static final String track = "track";
        public static final String title_return = "title_return";
        public static final String code = "code";
        public static final String ratings_not_available = "ratings_not_available";
        public static final String loading_payment_details = "loading_payment_details";
        public static final String coupon_details_error = "coupon_details_error";
        public static final String you_can_now = "you_can_now";
        public static final String invalid = "invalid";
        public static final String coupon_invalid_for_product = "coupon_invalid_for_product";
        public static final String unable_to_cancel_order = "unable_to_cancel_order";
        public static final String free_shipping_unavailable = "free_shipping_unavailable";
        public static final String contact_on_payment_deduct = "contact_on_payment_deduct";
        public static final String coupon_not_applicable_for_items = "coupon_not_applicable_for_items";
        public static final String coupon_valid_for_min_purchase = "coupon_valid_for_min_purchase";
        public static final String coupon_valid_for_max_purchase = "coupon_valid_for_max_purchase";
        public static final String total_items = "total_items";
        public static final String order_created_date = "order_created_date";
        public static final String select_payment_from = "select_payment_from";
        public static final String select_date = "select_date";
        public static final String write_to_email = "write_to_email";
        public static final String call = "call";
        public static final String call_to_number = "call_to_number";
        public static final String visit_site = "visit_site";
        public static final String title_order_status = "title_order_status";
        public static final String order_id = "order_id";
        public static final String order_by = "order_by";
        public static final String coupon_code = "coupon_code";
        public static final String order_quantity = "order_quantity";
        public static final String btn_yes = "btn_yes";
        public static final String btn_no = "btn_no";
        public static final String select_language = "select_language";
        public static final String title_language = "title_language";
        public static final String title_notification = "title_notification";
        public static final String txt_forget = "txt_forget";
        public static final String action_reset_password = "action_reset_password";
        public static final String txt_go_back = "txt_go_back";
        public static final String password_specification_weak = "password_specification_weak";
        public static final String password_specification_average = "password_specification_average";
        public static final String password_specification_strong = "password_specification_strong";
        public static final String msg_opinion_product = "msg_opinion_product";
        public static final String msg_opinion_like = "msg_opinion_like";
        public static final String msg_opinion_dislike = "msg_opinion_dislike";
        public static final String error_no_payment_methods = "error_no_payment_methods";
        public static final String toggle_wishlist_on = "toggle_wishlist_on";
        public static final String toggle_wishlist_off = "toggle_wishlist_off";
        public static final String address1 = "address1";
        public static final String sponsor_a_friend = "sponsor_a_friend";
        public static final String my_addresses = "my_addresses";
        public static final String your_friend_first_name = "your_friend_first_name";
        public static final String your_friend_last_name = "your_friend_last_name";
        public static final String your_friend_email = "your_friend_email";
        public static final String optional_message = "optional_message";
        public static final String your_friend_first_name_invalid = "your_friend_first_name_invalid";
        public static final String your_friend_last_name_invalid = "your_friend_last_name_invalid";
        public static final String your_friend_email_invalid = "your_friend_email_invalid";
        public static final String optional_message_too_large = "optional_message_too_large";
        public static final String sponsor_friend_message_sent = "sponsor_friend_message_sent";
        public static final String syncing_wishlist = "syncing_wishlist";
        public static final String address2 = "address2";
        public static final String share_wishlist = "share_wishlist";
        public static final String subscribe_waitlist_desc = "subscribe_waitlist_desc";
        public static final String unsubscribe_waitlist_desc = "unsubscribe_waitlist_desc";
        public static final String subscribe_waitlist = "subscribe_waitlist";
        public static final String unsubscribe_waitlist = "unsubscribe_waitlist";
        public static final String product_points = "product_points";
        public static final String earn_points_desc = "earn_points_desc";
        public static final String use_points_desc = "use_points_desc";
        public static final String used_points_desc = "used_points_desc";
        public static final String apply_discount = "apply_discount";
        public static final String remove_discount = "remove_discount";
        public static final String your_points = "your_points";
        public static final String title_shipping_section = "title_shipping_section";
        public static final String title_cart_summary = "title_cart_summary";
        public static final String order_note = "order_note";
        public static final String note = "note";
        public static final String order_note_placeholder = "order_note_placeholder";
        public static final String title_taxes = "title_taxes";
        public static final String points_earned = "points_earned";
        public static final String permission_denied = "permission_denied";
        public static final String points_redeemed = "points_redeemed";
        public static final String rate_us = "rate_us";
        public static final String brand = "brand";
        public static final String minimum_qty = "minimum_qty";
        public static final String prompt_shop_name = "prompt_shop_name";
        public static final String title_contains_attribute = "title_contains_attribute";
        public static final String title_out_of_stock = "title_out_of_stock";
        public static final String title_already_in_cart = "title_already_in_cart";
        public static final String adding_attribute_error = "adding_attribute_error";
        public static final String adding_outofstock_error = "adding_outofstock_error";
        public static final String adding_alredyadded_error = "adding_alredyadded_error";
        public static final String continue_anyway = "continue_anyway";
        public static final String pick_number = "pick_number";
        public static final String address_found = "address_found";
        public static final String no_address_found = "no_address_found";
        public static final String invalid_lat_long_used = "invalid_lat_long_used";
        public static final String service_not_available = "service_not_available";
        public static final String sort_fresh_arrival = "sort_fresh_arrival";
        public static final String sort_featured = "sort_featured";
        public static final String sort_user_rating = "sort_user_rating";
        public static final String sort_price_high_to_low = "sort_price_high_to_low";
        public static final String sort_price_low_to_high = "sort_price_low_to_high";
        public static final String sort_popularity = "sort_popularity";
        public static final String error_no_app_to_open_folder = "error_no_app_to_open_folder";
        public static final String add_note = "add_note";
        public static final String edit_note = "edit_note";
        public static final String download_selected = "download_selected";
        public static final String select_multiple = "select_multiple";
        public static final String select_choice = "select_choice";
        public static final String actions = "actions";
        public static final String download = "download";
        public static final String downloads = "downloads";
        public static final String ok = "ok";
        public static final String done = "done";
        public static final String download_initiated = "download_initiated";
        public static final String image_download_success = "image_download_success";
        public static final String mylist = "mylist";
        public static final String image_download_error = "image_download_error";
        public static final String bundle_free_quantity = "bundle_free_quantity";
        public static final String header_mixmatch_products = "header_mixmatch_products";
        public static final String shipping_tax = "shipping_tax";
        public static final String free = "free";
        public static final String please_enter_pincode = "please_enter_pincode";
        public static final String change_pincode = "change_pincode";
        public static final String rename = "rename";
        public static final String delete = "delete";
        public static final String set_as_default_WishList = "set_as_default_WishList";
        public static final String updated_successfully = "updated_successfully";
        public static final String deleted_successfully = "deleted_successfully";
        public static final String price_prefix = "price_prefix";
        public static final String approval = "approval";
        public static final String processing = "processing";
        public static final String shipping = "shipping";
        public static final String delivered = "delivered";
        public static final String pending = "pending";
        public static final String onhold = "onhold";
        public static final String completed = "completed";
        public static final String cancelled = "cancelled";
        public static final String refunded = "refunded";
        public static final String failed = "failed";
        public static final String expiry_date = "expiry_date";
        public static final String available_discount = "available_discount";
        public static final String discount_apply_on = "discount_apply_on";
        public static final String discount_not_apply_on = "discount_not_apply_on";
        public static final String free_shipping_available = "free_shipping_available";
        public static final String my_coupons = "my_coupons";
        public static final String no_coupons_found = "no_coupons_found";
        public static final String btn_go_back = "btn_go_back";
        public static final String cannot_apply_coupons = "cannot_apply_coupons";
        public static final String category = "category";
        public static final String send_quote = "send_quote";
        public static final String product = "product";
        public static final String visit_product = "visit_product";
        public static final String introduction = "introduction";
        public static final String cart = "cart";
        public static final String location = "location";
        public static final String website = "website";
        public static final String call_or_whatsapp = "call_or_whatsapp";
        public static final String warning = "warning";
        public static final String question_cancel_transaction = "question_cancel_transaction";
        public static final String invalid_name = "invalid_name";
        public static final String edit = "edit";
        public static final String register_as_vendor = "register_as_vendor";
        public static final String vendor_change_confirmation = "vendor_change_confirmation";
        public static final String vendor_status_label = "vendor_status_label";
        public static final String vendor_status_pending = "vendor_status_pending";
        public static final String vendor_status_verified = "vendor_status_verified";
        public static final String assign_order_to_vendor = "assign_order_to_vendor";
        public static final String updating_status = "updating_status";
        public static final String shipping_methods = "shipping_methods";
        public static final String view_all = "view_all";
        public static final String text_applied_coupons = "text_applied_coupons";
        public static final String payment_detail = "payment_detail";
        public static final String text_payment = "text_payment";
        public static final String select_time_slot = "select_time_slot";
        public static final String fee_lines = "fee_lines";
        public static final String title_tax = "title_tax";
        public static final String error_high_sale_price = "error_high_sale_price";
        public static final String label_other_options = "label_other_options";
        public static final String downloadable = "downloadable";
        public static final String virtual = "virtual";
        public static final String back_order = "back_order";
        public static final String sold_individually = "sold_individually";
        public static final String featured = "featured";
        public static final String weight = "weight";
        public static final String label_stock_option = "label_stock_option";
        public static final String managing_stock = "managing_stock";
        public static final String hint_stock_quantity = "hint_stock_quantity";
        public static final String submit = "submit";
        public static final String label_attributes = "label_attributes";
        public static final String hint_sale_price = "hint_sale_price";
        public static final String submiting_request = "submiting_request";
        public static final String product_stock_quantity = "product_stock_quantity";
        public static final String order_again = "order_again";
        public static final String quote_submitted = "quote_submitted";
        public static final String my_notifications = "my_notifications";
        public static final String change_platform = "change_platform";
        public static final String title_seller_zone_delete_product = "title_seller_zone_delete_product";
        public static final String title_seller_zone_edit_product = "title_seller_zone_edit_product";
        public static final String seller_zone_delete_product_confirmation = "seller_zone_delete_product_confirmation";
        public static final String seller_zone_shop_settings_updated = "seller_zone_shop_settings_updated";
        public static final String label_basic_info = "label_basic_info";
        public static final String hint_product_title = "hint_product_title";
        public static final String hint_short_description = "hint_short_description";
        public static final String label_product_images = "label_product_images";
        public static final String label_category = "label_category";
        public static final String label_full_description = "label_full_description";
        public static final String label_pricing = "label_pricing";
        public static final String loading_seller_info = "loading_seller_info";
        public static final String hint_regular_price = "hint_regular_price";
        public static final String login_facebook = "login_facebook";
        public static final String login_google = "login_google";
        public static final String login_twitter = "login_twitter";
        public static final String seller_analytics = "seller_analytics";
        public static final String update_order = "update_order";
        public static final String no_notifications_found = "no_notifications_found";
        public static final String seller_verification_is_pending = "seller_verification_is_pending";
        public static final String add_new = "add_new";
        public static final String title_seller_profile = "title_seller_profile";
        public static final String title_seller_products = "title_seller_products";
        public static final String title_seller_orders = "title_seller_orders";
        public static final String title_seller_zone = "title_seller_zone";
        public static final String title_store_settings = "title_store_settings";
        public static final String label_shop_name = "label_shop_name";
        public static final String label_shop_address = "label_shop_address";
        public static final String uploading = "uploading";
        public static final String please_select_a_category = "please_select_a_category";
        public static final String please_try_again = "please_try_again";
        public static final String check_availability = "check_availability";
        public static final String available_at = "available_at";
        public static final String pincode_is_blank = "pincode_is_blank";
        public static final String enter_your_pincode = "enter_your_pincode";
        public static final String pincode_server_error = "pincode_server_error";
        public static final String label_shipment_details = "label_shipment_details";
        public static final String label_shipment_id = "label_shipment_id";
        public static final String label_shipment_provider = "label_shipment_provider";
        public static final String label_shipping_types = "label_shipping_types";
        public static final String title_select_shipping_types = "title_select_shipping_types";
        public static final String uploading_shipping_data = "uploading_shipping_data";
        public static final String uploading_product_data = "uploading_product_data";
        public static final String product_upload_error = "product_upload_error";
        public static final String product_deleted = "product_deleted";
        public static final String product_delete_error = "product_delete_error";
        public static final String product_assign_seller_error = "product_assign_seller_error";
        public static final String are_you_sure = "are_you_sure";
        public static final String restart_app_dialog_title = "restart_app_dialog_title";
        public static final String restart_app_confirm_msg = "restart_app_confirm_msg";
        public static final String button_reload = "button_reload";
        public static final String button_later = "button_later";
        public static final String security_cert_dialog_msg = "security_cert_dialog_msg";
        public static final String security_cert_dialog_title = "security_cert_dialog_title";
        public static final String buy_button_description = "buy_button_description";
        public static final String delivery_date = "delivery_date";
        public static final String delivery_time = "delivery_time";
        public static final String cart_note_placeholder = "cart_note_placeholder";
        public static final String change_store = "change_store";
        public static final String dialog_title_caution = "dialog_title_caution";
        public static final String dialog_msg_caution = "dialog_msg_caution";
        public static final String new_tag = "new_tag";
        public static final String sale_tag = "sale_tag";
        public static final String out_of_stock_tag = "out_of_stock_tag";
        public static final String select_delivery_time = "select_delivery_time";
        public static final String hint_select_delivery_date = "hint_select_delivery_date";
        public static final String label_date = "label_date";
        public static final String label_time = "label_time";
        public static final String label_delivery_details = "label_delivery_details";
        public static final String special_order_note = "special_order_note";
        public static final String scan_product = "scan_product";
        public static final String error_retrieving_product = "error_retrieving_product";
        public static final String title_reservation = "title_reservation";
        public static final String title_contact_us = "title_contact_us";
        public static final String label_name_booking_reservation = "label_name_booking_reservation";
        public static final String label_select_reservation_date = "label_select_reservation_date";
        public static final String label_pers = "label_pers";
        public static final String label_hour_reservation = "label_hour_reservation";
        public static final String label_phone_number_reservation = "label_phone_number_reservation";
        public static final String label_message_reservation = "label_message_reservation";
        public static final String btn_make_a_reservation = "btn_make_a_reservation";
        public static final String label_last_and_first_name = "label_last_and_first_name";
        public static final String get_direction = "get_direction";
        public static final String store_is_not_yet_open = "store_is_not_yet_open";
        public static final String error_in_route = "error_in_route";
        public static final String error_in_distance = "error_in_distance";
        public static final String show_stores = "show_stores";
        public static final String reservation_form_desc = "reservation_form_desc";
        public static final String select_reservation_date = "select_reservation_date";
        public static final String invalid_pers = "invalid_pers";
        public static final String btn_send_message_contactus = "btn_send_message_contactus";
        public static final String invalid_message = "invalid_message";
        public static final String label_item_cart_overlay = "label_item_cart_overlay";
        public static final String label_total_cart_overlay = "label_total_cart_overlay";
        public static final String locate_store = "locate_store";
        public static final String search_location = "search_location";
        public static final String add_shipping_address = "add_shipping_address";
        public static final String you_need_to_allow_permission = "you_need_to_allow_permission";
        public static final String select_shipping_address = "select_shipping_address";
        public static final String title_reset_password = "title_reset_password";
        public static final String prompt_new_password = "prompt_new_password";
        public static final String prompt_current_password = "prompt_current_password";
        public static final String label_total_taxes = "label_total_taxes";
        public static final String show_billing_address = "show_billing_address";
        public static final String show_shipping_address = "show_shipping_address";
        public static final String vendor_sold_by = "vendor_sold_by";
        public static final String title_pay = "title_pay";
        public static final String title_card_number = "title_card_number";
        public static final String title_card_cvv = "title_card_cvv";
        public static final String title_card_expiry_month = "title_card_expiry_month";
        public static final String title_card_expiry_year = "title_card_expiry_year";
        public static final String title_total_amount = "title_total_amount";
        public static final String hint_card_number = "hint_card_number";
        public static final String hint_card_cvv = "hint_card_cvv";
        public static final String hint_card_expiry_month = "hint_card_expiry_month";
        public static final String hint_card_expiry_year = "hint_card_expiry_year";
        public static final String error_empty_card_number = "error_empty_card_number";
        public static final String error_invalid_card_number = "error_invalid_card_number";
        public static final String error_empty_cvv = "error_empty_cvv";
        public static final String error_invalid_cvv = "error_invalid_cvv";
        public static final String error_invalid_month = "error_invalid_month";
        public static final String error_invalid_year = "error_invalid_year";
        public static final String error_invalid_expiry = "error_invalid_expiry";
        public static final String error_check_card_details = "error_check_card_details";
        public static final String seller = "seller";
        public static final String please_enter_otp = "please_enter_otp";
        public static final String otp_verification = "otp_verification";
        public static final String user_already_registered = "user_already_registered";
        public static final String resend_otp = "resend_otp";
        public static final String verify = "verify";
        public static final String enter_otp = "enter_otp";
        public static final String total_shipping_cost = "total_shipping_cost";
        public static final String total_tax_order = "total_tax_order";
        public static final String total_order = "total_order";
        public static final String regenerate_otp = "regenerate_otp";
        public static final String cod_otp_dialog_msg = "cod_otp_dialog_msg";
        public static final String update_billing_mobile_no_dialog_header = "update_billing_mobile_no_dialog_header";
        public static final String update_billing_mobile_no_dialog_msg = "update_billing_mobile_no_dialog_msg";
        public static final String error_invalid_mobile_number = "error_invalid_mobile_number";
        public static final String hint_mobile_number = "hint_mobile_number";
        public static final String add_new_card = "add_new_card";
        public static final String saved_cards = "saved_cards";
        public static final String lable_ratings = "lable_ratings";
        public static final String hint_your_review = "hint_your_review";
        public static final String review_dialog_title = "review_dialog_title";
        public static final String review_dialog_msg = "review_dialog_msg";
        public static final String name = "name";
        public static final String error_country_code_required = "error_country_code_required";
        public static final String satispay_checking_user = "satispay_checking_user";
        public static final String satispay_error_checking_user = "satispay_error_checking_user";
        public static final String satispay_creating_charge = "satispay_creating_charge";
        public static final String satispay_error_creating_charge = "satispay_error_creating_charge";
        public static final String satispay_verifying_charge = "satispay_verifying_charge";
        public static final String continue_as_guest = "continue_as_guest";
        public static final String button_continue = "button_continue";
        public static final String category_products_count_format = "category_products_count_format";
        public static final String title_address1 = "title_address1";
        public static final String title_address2 = "title_address2";
        public static final String company = "company";
        public static final String phone = "phone";
        public static final String install = "install";
        public static final String locate = "locate";
        public static final String msg_install_map_dialog = "msg_install_map_dialog";
        public static final String allow_location_access = "allow_location_access";
        public static final String turn_on_high_accuracy_location = "turn_on_high_accuracy_location";
        public static final String change_currency = "change_currency";
        public static final String please_select_currency = "please_select_currency";
        public static final String title_currency = "title_currency";
        public static final String already_selected_currency = "already_selected_currency";
        public static final String title_additional_information = "title_additional_information";
        public static final String title_pickup_location = "title_pickup_location";
        public static final String pickup_order_text = "pickup_order_text";
        public static final String filter_location = "filter_location";
        public static final String title_range = "title_range";
        public static final String title_range_in = "title_range_in";
        public static final String kilometer = "kilometer";
        public static final String bundle_product_out_of_stock = "bundle_product_out_of_stock";
        public static final String error_failed_to_submit_review = "error_failed_to_submit_review";
        public static final String share_app_title = "share_app_title";
        public static final String product_upload_successful = "product_upload_successful";
        public static final String show_all_stores = "show_all_stores";
        public static final String no_near_by_store_available = "no_near_by_store_available";
        public static final String no_store_available = "no_store_available";
        public static final String upload_payment_proof = "upload_payment_proof";
        public static final String payment_proof_uploaded = "payment_proof_uploaded";
        public static final String uploading_image = "uploading_image";
        public static final String title_location = "title_location";
        public static final String title_seller_icon = "title_seller_icon";
        public static final String title_live_chat = "title_live_chat";
        public static final String btn_seller_register_login = "btn_seller_register_login";
        public static final String txt_msg_seller_intro = "txt_msg_seller_intro";
        public static final String dialog_title_thankyou = "dialog_title_thankyou";
        public static final String dialog_title_alert = "dialog_title_alert";
        public static final String dialog_msg_not_verified_seller = "dialog_msg_not_verified_seller";
        public static final String dialog_msg_not_seller = "dialog_msg_not_seller";
        public static final String title_news_feed = "title_news_feed";
        public static final String posted_by = "posted_by";
        public static final String new_feed_unavailable = "new_feed_unavailable";
        public static final String sort_discount = "sort_discount";
        public static final String title_welcome = "title_welcome";
        public static final String save_card_details = "save_card_details";
        public static final String not_registered_as_vendor = "not_registered_as_vendor";
        public static final String title_item_condition = "title_item_condition";
        public static final String title_remaining_time = "title_remaining_time";
        public static final String title_auction_ends = "title_auction_ends";
        public static final String title_time_zone = "title_time_zone";
        public static final String title_Current_bid = "title_Current_bid";
        public static final String title_auction_history = "title_auction_history";
        public static final String title_date = "title_date";
        public static final String title_bid = "title_bid";
        public static final String title_user = "title_user";
        public static final String btn_bid = "btn_bid";
        public static final String error_bid_qty = "error_bid_qty";
        public static final String bid_finish = "bid_finish";
        public static final String days = "days";
        public static final String hours = "hours";
        public static final String minutes = "minutes";
        public static final String seconds = "seconds";
        public static final String nearby_map_marker_title = "nearby_map_marker_title";
        public static final String invalid_review_message = "invalid_review_message";
        public static final String invalid_rating = "invalid_rating";
        public static final String order_placed_dialog_title = "order_placed_dialog_title";
        public static final String order_placed_dialog_msg = "order_placed_dialog_msg";
        public static final String hint_msrp_price = "hint_msrp_price";
        public static final String hint_cost_of_good = "hint_cost_of_good";
        public static final String error_msrp_price = "error_msrp_price";
        public static final String error_cost_of_good = "error_cost_of_good";

        public static final String btn_check_booking_availability = "btn_check_booking_availability";
        public static final String hint_booking_date = "hint_booking_date";
        public static final String title_booking_cost = "title_booking_cost";
        public static final String title_select_booking_date_dialog = "title_select_booking_date_dialog";
        public static final String msg_partially_booking_date = "msg_partially_booking_date";
        public static final String toast_error_msg_select_booking_date = "toast_error_msg_select_booking_date";
        public static final String label_booking_date = "label_booking_date";
        public static final String title_order_booking_id = "title_order_booking_id";
        public static final String title_order_booking_status = "title_order_booking_status";
        public static final String title_order_booking_start_date = "title_order_booking_start_date";
        public static final String title_order_booking_end_date = "title_order_booking_end_date";
        public static final String btn_order_booking_pay = "btn_order_booking_pay";

        public static final String hint_mci_registration_number = "hint_mci_registration_number";
        public static final String hint_mci_year_registration = "hint_mci_year_registration";
        public static final String hint_qualification = "hint_qualification";

        public static final String invalid_mci_registration_number = "invalid_mci_registration_number";
        public static final String invalid_mci_year_registration = "invalid_mci_year_registration";
        public static final String invalid_qualification = "invalid_qualification";

        public static final String text_delivery_date = "text_delivery_date";
        public static final String text_delivery_time = "text_delivery_time";
        public static final String text_delivery_status = "text_delivery_status";
        public static final String text_delivery_receiver = "text_delivery_receiver";
        public static final String text_bill_number = "text_bill_number";
        public static final String text_bill_date = "text_bill_date";
        public static final String text_bill_time = "text_bill_time";
        public static final String text_order_weight = "text_order_weight";
        public static final String text_order_origin = "text_order_origin";
        public static final String text_order_destination = "text_order_destination";
        public static final String text_shipper_name = "text_shipper_name";
        public static final String text_shipper_address = "text_shipper_address";
        public static final String text_shipper_city = "text_shipper_city";
        public static final String text_receiver_name = "text_receiver_name";
        public static final String text_receiver_address = "text_receiver_address";
        public static final String text_receiver_city = "text_receiver_city";
        public static final String shipping_details = "shipping_details";
        public static final String distance = "distance";
        public static final String seller_subscription_dialog_title = "seller_subscription_dialog_title";
        public static final String seller_subscription_dialog_msg = "seller_subscription_dialog_msg";
        public static final String label_deposit_fixed = "label_deposit_fixed";
        public static final String label_deposit_percent = "label_deposit_percent";
        public static final String message_deposit = "message_deposit";
        public static final String message_deposit_full = "message_deposit_full";
        public static final String pay_deposit = "pay_deposit";
        public static final String pay_full = "pay_full";
        public static final String label_deposit_amount = "label_deposit_amount";
        public static final String label_deposit_remaining_amount = "label_deposit_remaining_amount";
        public static final String error_option_is_required = "error_option_is_required";

        public static final String product_map_adress = "product_map_adress";
        public static final String product_map_phone = "product_map_phone";
        public static final String product_map_email = "product_map_email";
        public static final String product_map_website = "product_map_website";
        public static final String dialog_title_select_country_code = "dialog_title_select_country_code";
        public static final String invalid_select_country_code = "invalid_select_country_code";
        public static final String invalid_email_domain = "invalid_email_domain";
        public static final String title_shipping_pickup_location = "title_shipping_pickup_location";
        public static final String dialog_header_shipping_pickup = "dialog_header_shipping_pickup";
        public static final String permission_location_rationale = "permission_location_rationale";

        public static final String title_camera = "title_camera";
        public static final String title_gallery = "title_gallery";

        //Demo related string resources
        public static final String visit = "visit";
        public static final String error = "error";
        public static final String title_dialog_get_app_type = "title_dialog_get_app_type";
        public static final String contact_support_team = "contact_support_team";
        public static final String button_accept = "button_accept";
        public static final String button_cancel = "button_cancel";
        public static final String privacy_policy = "privacy_policy";
    }
}