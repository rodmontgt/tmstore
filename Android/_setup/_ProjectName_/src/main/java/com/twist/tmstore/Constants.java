package com.twist.tmstore;

/**
 * Created by Twist Mobile on 10-Jun-16.
 */
public class Constants {

    /*
    * IDs of different items used in Navigation Bar
    * */

    public static final int MENU_ID_HOME = 0;
    public static final int MENU_ID_WISH = 1;
    public static final int MENU_ID_CART = 2;
    public static final int MENU_ID_ORDERS = 3;
    public static final int MENU_ID_SETTINGS = 4;
    public static final int MENU_ID_ABOUT = 5;
    public static final int MENU_ID_SIGN_IN = 6;
    public static final int MENU_ID_SIGN_OUT = 7;
    public static final int MENU_ID_PROFILE = 8;
    public static final int MENU_ID_SEARCH = 9;
    public static final int MENU_ID_CATEGORIES = 10;
    public static final int MENU_ID_OPINION = 11;
    public static final int MENU_ID_WP_MENU = 12;
    public static final int MENU_ID_FRESH_CHAT = 13;
    public static final int MENU_ID_WEB_PAGE = 14;
    public static final int MENU_ID_REFER_FRIEND = 15;
    public static final int MENU_ID_CHANGE_MERCHANT = 16;
    public static final int MENU_ID_CHANGE_SELLER = 17;
    public static final int MENU_ID_RATE_APP = 18;
    public static final int MENU_ID_GROUPS = 19;
    public static final int MENU_ID_SELLER_HOME = 20;
    public static final int MENU_ID_MY_ADDRESS = 21;
    public static final int MENU_ID_MY_COUPONS = 22;
    public static final int MENU_ID_SELLER_PRODUCTS = 23;
    public static final int MENU_ID_SELLER_UPLOAD_PRODUCT = 24;
    public static final int MENU_ID_SELLER_ORDERS = 25;
    public static final int MENU_ID_SELLER_WALLET = 26;
    public static final int MENU_ID_SELLER_STORE_SETTINGS = 27;
    public static final int MENU_ID_SELLER_ANALYTICS = 28;
    public static final int MENU_ID_PROFILE_FULL = 30;
    public static final int MENU_ID_EXTERNAL_LINK = 31;
    public static final int MENU_ID_FIXED_PRODUCTS = 32;
    public static final int MENU_ID_NOTIFICATIONS = 33;
    public static final int MENU_ID_CHANGE_PLATFORM = 34;
    public static final int MENU_ID_SELLER_INFO = 35;
    public static final int MENU_ID_SCAN_PRODUCT = 36;
    public static final int MENU_ID_CHANGE_STORE = 37;
    public static final int MENU_ID_RESERVATION_FORM = 38;
    public static final int MENU_ID_CONTACT_FORM3 = 39;
    public static final int MENU_ID_FOOTER_ITEM = 40;
    public static final int MENU_ID_LOCATE_STORE = 41;
    public static final int MENU_ID_SHARE_APP = 43;
    public static final int MENU_ID_NEWS_FEED = 44;
    public static final int MENU_ID_LIVE_CHAT = 45;

    /*
   * IDs of different items used in Action Bar
   * */

    public static final int ID_ACTION_MENU_HOME = 101;
    public static final int ID_ACTION_MENU_CART = 102;
    public static final int ID_ACTION_MENU_WISH = 103;
    public static final int ID_ACTION_MENU_OPINION = 104;
    public static final int ID_ACTION_MENU_SEARCH = 105;
    public static final int ID_ACTION_MENU_EDIT = 107;
    public static final int ID_ACTION_MENU_DOWNLOADS = 108;
    public static final int ID_ACTION_MENU_CURRENCY = 109;
    public static final int ID_ACTION_MENU_CALL = 110;

    /*
   * IDs of different items used in Floating Action Menu
   * */

    public static final int ID_WISH_MENU_RENAME = 101;
    public static final int ID_WISH_MENU_DELETE = 102;
    public static final int ID_WISH_MENU_DOWNLOAD_LIST = 103;
    public static final int ID_WISH_MENU_SHARE = 104;

    public class Key {
        public static final String CONTACT_TYPE_DESCRIPTION = "description";
        public static final String CONTACT_TYPE_MOBILE = "mobile";
        public static final String CONTACT_TYPE_PHONE = "phone";
        public static final String CONTACT_TYPE_EMAIL = "email";
        public static final String CONTACT_TYPE_IMAGE = "image";
        public static final String CONTACT_TYPE_ADDRESS = "address";
        public static final String CONTACT_TYPE_WEBSITE = "website";

        // EXCLUDE ADDRESS KEYS
        static final String FIRST_NAME = "first_name";
        static final String LAST_NAME = "last_name";
        static final String EMAIL = "email";
        static final String BILLING_FIRST_NAME = "billing_first_name";
        static final String BILLING_LAST_NAME = "billing_last_name";
        static final String BILLING_ADDRESS_1 = "billing_address_1";
        static final String BILLING_ADDRESS_2 = "billing_address_2";
        static final String BILLING_CITY = "billing_city";
        static final String BILLING_STATE = "billing_state";
        static final String BILLING_POSTCODE = "billing_postcode";
        static final String BILLING_COUNTRY = "billing_country";
        static final String BILLING_EMAIL = "billing_email";
        static final String BILLING_PHONE = "billing_phone";
        static final String SHIPPING_FIRST_NAME = "shipping_first_name";
        static final String SHIPPING_LAST_NAME = "shipping_last_name";
        static final String SHIPPING_ADDRESS_1 = "shipping_address_1";
        static final String SHIPPING_ADDRESS_2 = "shipping_address_2";
        static final String SHIPPING_CITY = "shipping_city";
        static final String SHIPPING_STATE = "shipping_state";
        static final String SHIPPING_POSTCODE = "shipping_postcode";
        static final String SHIPPING_COUNTRY = "shipping_country";

        // Names for Shipping Providers
        public static final String SHIPPING_AFTERSHIP = "aftership";
        public static final String SHIPPING_RAJAONGKIR = "rajaongkir";
        public static final String SHIPPING_EPEKEN_JNE = "epeken_jne";
        public static final String SHIPPING_JNE_ALL_COURIER = "all_courier";

        // Application Preferences Keys
        public static final String DEVICE_TOKEN = "device_token";

        public static final String REFERRER_INSTALL = "install_referrer";
        public static final String REFERRER_PRODUCT = "product_referrer";
        public static final String CONTACT_TYPE_GEOLOCATION = "geolocation";

        public static final String MULTI_STORE_PLATFORM = "multi_store_platform";
    }

    public static final String ACTION_BROADCAST_NOTIFICATION = "com.twist.tmstore.BROADCAST_NOTIFICATION";
    public static final String ACTION_UNREGISTER_NOTIFICATION = "com.twist.tmstore.UNREGISTER_NOTIFICATION";
    public static final String ACTION_REGISTER_NOTIFICATION = "com.twist.tmstore.REGISTER_NOTIFICATION";
    public static final String ACTION_MANAGE_CHANNEL_SUBSCRIPTION = "com.twist.tmstore.MANAGE_CHANNEL_SUBSCRIPTION";
    public static final String ACTION_PRODUCT_DELETED = "com.twist.tmstore.PRODUCT_DELETED";
    public static final String ACTION_PRODUCT_UPDATED = "com.twist.tmstore.PRODUCT_UPDATED";
    public static final String ACTION_PRODUCT_UPLOADED = "com.twist.tmstore.PRODUCT_UPLOADED";
    public static final String ACTION_MULTI_STORE_SEARCH_NEARBY = "com.twist.tmstore.MULTI_STORE_SEARCH_NEARBY";
    public static final String ACTION_MULTI_STORE_SEARCH_ALL = "com.twist.tmstore.MULTI_STORE_SEARCH_ALL";
    public static final String ACTION_MULTI_STORE_LOCATE_ALL = "com.twist.tmstore.MULTI_STORE_LOCATE_ALL";

    public static final String CHANNEL_GUEST = "guest";
    public static final String CHANNEL_LOGIN = "login";
    public static final String GUEST_ORDER_ID = "GUEST_ORDER";

    // Constants name for FetchAddress
    public static final int SUCCESS_RESULT = 0;
    public static final int FAILURE_RESULT = 1;

    public static final String PACKAGE_NAME = "com.twist.tmstore.services";
    public static final String RECEIVER = PACKAGE_NAME + ".RECEIVER";
    public static final String RESULT_DATA_KEY = PACKAGE_NAME + ".RESULT_DATA_KEY";
    public static final String LOCATION_NAME_DATA_EXTRA = PACKAGE_NAME + ".LOCATION_NAME_DATA_EXTRA";
    public static final String RESULT_ADDRESS = PACKAGE_NAME + ".RESULT_ADDRESS";

    public static final String LAT = "lat";
    public static final String LNG = "lng";
    public static final String CART = "cart";
    public static final String WISHLIST = "wishlist";
    public static final String VENDOR_SECTION = "vendor_section";
    public static final String OPINION = "opinion";
    public static final String SELECT_PAYMENT = "select_payment";
    public static final String SPONSER_FRIEND = "sponser_friend";
    public static final String HOME = "home";
    public static final String SPLASH = "splash";
    public static final String CONTACT_US = "contact_us";
    public static final String CONFIRM_ORDER = "confirm_order";
    public static final String SEARCH = "search";
    public static final String PROFILE = "profile";
    public static final String ORDERS = "orders";

    // Activity Request Codes
    public static final int REQUEST_SHOW_PRODUCT = 1;
    public static final int REQUEST_EDIT_PROFILE = 2;
    public static final int REQUEST_UPLOAD_PRODUCT = 3;
    public static final int REQUEST_EDIT_PRODUCT = 4;
    public static final int REQUEST_CHANGE_STORE = 5;
    public static final int REQUEST_BARCODE_CAPTURE = 9001;

    // Activity Result Codes
    public static final int RESULT_EDIT_PROFILE_SKIP_LOGIN = 1000;

    // Bundle Arguments Constants
    public static final String ARG_WISHLIST_DEEPLINK = "arg_wishlist_deeplink";
    public static final String ARG_WAYBILL_NUMBER = "arg_waybill_number";
}