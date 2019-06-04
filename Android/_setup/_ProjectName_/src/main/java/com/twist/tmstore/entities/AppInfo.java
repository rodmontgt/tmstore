package com.twist.tmstore.entities;

import com.twist.tmstore.config.CartNoteConfig;
import com.twist.tmstore.config.CategoryLayoutsConfig;
import com.twist.tmstore.config.GuestUserConfig;
import com.twist.tmstore.config.HomeConfigUltimate;
import com.twist.tmstore.config.ImageDownloaderConfig;
import com.twist.tmstore.config.OrderNoteConfig;
import com.twist.tmstore.config.ProductDetailsConfig;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Twist Mobile on 30-03-2017.
 */

public class AppInfo {
    public static final String DEBUG_CODE = "1211";
    public static final String SAMPLE_APP_ID = "sNAGb5J4or";

    public static String color_theme = "#5c6bc0";
    public static String color_theme_dark = "#5c6bc0";
    public static String color_theme_statusbar = "#5c6bc0";
    public static String normal_button_color = "#5c6bc0";
    public static String selected_button_color = "#ffff00";
    public static String normal_button_text_color = "#ffdd33";
    public static String selected_button_text_color = "#eedd33";
    public static String disable_button_color = "#00ffff";
    public static String color_pager_title_strip = "#00ff00";
    public static String color_actionbar_text = "#ffffff";
    public static String color_splash_text = "#808080";
    public static String color_regular_price = "#626262";
    public static String color_sale_price = "#f25d2f";
    public static String color_notification_badge_bg = "#f63228";
    public static String color_notification_badge_text = "#fefefe";
    public static String color_splash_bg = "#ffffff";
    public static String color_home_section_header_bg = "#f5f5f5";
    public static String color_home_section_header_text = "#626262";
    public static String color_bottom_nav_normal = "#c9c9c9";
    public static String color_bottom_nav_selected = "#3F51B5";
    public static String color_bottom_nav_bg = "#ffffff";

    public static String ABOUT_URL = "";
    public static String PROMO_URL = "";
    public static String PROMO_TITLE = "";
    public static String PROMO_DESC = "";
    public static String PROMO_IMG_URL = "";
    public static String FACEBOOK_APP_ID = "";
    public static String TWITTER_APP_KEY = "";
    public static String GOOGLE_APP_KEY = "";
    public static String MERCHANT_ID = "";
    public static String PRODUCT_DEEPLINK_URL = "";
    public static String PRODUCT_DEEPLINK = "";
    public static String SHIPPING_PROVIDER = "";
    public static String SHIPPING_KEY = "";
    public static String SHIPPING_TRACK_URL = "";
    public static String ACTIONBAR_ICON_URL = null;
    public static String DATE_FORMAT_PATTERN = "";
    public static String DEEP_LINK_URL = "";
    public static String EMAIL_DOMAIN = ""; // TODO Use pattern == @gmail.com || @greenapple.com
    public static String ACTION_BAR_HOME_TITLE = "";

    public static int ID_PLACEHOLDER_BANNER = 0;
    public static int ID_PLACEHOLDER_PRODUCT = 0;
    public static int ID_PLACEHOLDER_CATEGORY = 0;
    public static int ID_LAYOUT_PRODUCTS = 0;
    public static int ID_LAYOUT_CATEGORIES = 0;
    public static int ID_LAYOUT_CART = 0;
    public static int PENDING_NOTIFICATIONS = 0;
    public static int PRODUCT_ACTIVITY_ANIMATION = 0;
    public static int DRAWER_INDEX_CATEGORY = 1;
    public static int DRAWER_INDEX_WP_MENU = 2;
    public static int SHIPPING_MINIMUM_WEIGHT = 0;
    public static int SHIPPING_DEFAULT_WEIGHT = 0;
    public static int REQUIRED_PASSWORD_STRENGTH = 0;
    public static int NEW_PRODUCT_DAYS_LIMIT = 7;

    public static int HOME_SLIDER_STANDARD_WIDTH = 680;
    public static int HOME_SLIDER_STANDARD_HEIGHT = 380;
    public static int PRODUCT_SLIDER_STANDARD_WIDTH = 680;
    public static int PRODUCT_SLIDER_STANDARD_HEIGHT = 380;

    public static final int MAX_ITEMS_COUNT_HOME = 10;
    public static final int MAX_PROMOTED_MERCHANTS = 50;

    public static int HOME_MENU_ITEMS[] = {0, 1, 2, 3};
    public static int HOME_NAV_MENU_ITEMS[] = {0, 1, 2, 3};
    public static int PRODUCT_MENU_ITEMS[] = {0, 1, 4};

    // Dynamic Home Screen Layout
    public static HomeConfigUltimate homeConfigUltimate = null;
    public static HomeConfigUltimate homeConfigUltimateLand = null;
    public static OrderNoteConfig mOrderNoteConfig;
    public static CartNoteConfig mCartNoteConfig;
    public static ImageDownloaderConfig mImageDownloaderConfig;
    public static GuestUserConfig mGuestUserConfig;
    public static CategoryLayoutsConfig mCategoryLayoutsConfig;
    public static ProductDetailsConfig mProductDetailsConfig = new ProductDetailsConfig();

    public static List<NavDrawItem> drawerItems = null;
    public static List<MyProfileItem> profileItems = null;
    public static List<String> homeMenuContactNumbers = null;
    public static List<Banner> banners;
    public static DummyUser dummyUser;
    public static List<ContactDetail> contactDetails = null;
    public static List<Integer> restrictedCategories = null;
    public static List<CategoryItem> front_page_categories = null;
    public static String sort_config;
    public static String drawer_header_bg;
    public static String profile_header_bg;
    public static String login_bg;
    public static List<String> EXCLUDED_ADDRESSES = new ArrayList<>();
    public static List<String> OPTIONAL_ADDRESSES = new ArrayList<>();


    // To start demo app.
    public static boolean DEMO_APP = false;

    // To show discount coupons section
    public static boolean ENABLE_COUPONS = false;

    // To hide applied coupons list from cart
    public static boolean HIDE_COUPON_LIST = false;

    // To apply coupon automatically.
    public static boolean ENABLE_AUTO_COUPONS = false;

    // To show full page login Dialog
    public static boolean FULL_SCREEN_LOGIN = false;

    // Set Login dialog cancellable
    public static boolean CANCELLABLE_LOGIN = true;

    // To show Login Dialog at app start
    public static boolean SHOW_LOGIN_AT_START = false;

    // To show Mobile number section in Login dialog.
    public static boolean SHOW_MOBILE_NUMBER_IN_SIGNUP = false;

    // To make Mobile number of login dialog compulsory required.
    public static boolean REQUIRE_MOBILE_NUMBER_IN_SIGNUP = false;
    
    // To show only Mobile number section with out Email in Login dialog.
    public static boolean SHOW_ONLY_MOBILE_NUMBER_IN_SIGNUP = false;

    // To show Edit Profile After Login.
    public static boolean EDIT_PROFILE_ON_LOGIN = true;

    // To show reset password section in Login dialog.
    public static boolean SHOW_RESET_PASSWORD = false;

    // To show Signup Form UI in Login dialog.
    public static boolean SHOW_SIGNUP_UI = true;

    // To Auto fill Profile Location using current location.
    public static boolean AUTO_DETECT_ADDRESS = false;

    // stop load more product in category automatically.
    public static boolean AUTO_LOAD_MORE_ITEMS = false;
    public static boolean ENABLE_PROMO_BUTTON = false;
    public static boolean AUTO_SIGNIN_IN_HIDDEN_WEBVIEW = true;
    public static boolean USE_PARSE_ANALYTICS = true;
    public static boolean USE_HTTPTASK_WITH_COOKIES = true;
    public static boolean ALLOW_NEGATIVE_SHIPPING_HACK = false;

    // To show Slider Image/ Banner at Home page.
    public static boolean SHOW_HOME_PAGE_BANNER = true;

    // To show Slider Image/ Banner in category.
    public static boolean SHOW_CATEGORY_BANNER = true;

    // To show full page Slider Image/ Banner in category.
    public static boolean SHOW_CATEGORY_BANNER_FULL = false;

    // To show category Filter button in App, load filter for all category.
    public static boolean ENABLE_FILTERS = true;

    // To show category Filter button with only Sorting feature in App.
    public static boolean SHOW_SORTING_IF_FILTER_UNAVAILABLE = false;

    // To Load category filter according to single category.
    public static boolean ENABLE_FILTERS_PER_CATEGORY = false;

    // To show Location section in filter.
    public static boolean ENABLE_LOCATION_IN_FILTERS = false;

    // To show Seasonal Greeting image at Home and Navigation drawer.
    public static boolean SHOW_SEASONAL_GREETINGS = false;

    // To show trending product list section.
    public static boolean SHOW_SECTION_TRENDING = true;

    // To show product fresh arrivals list section.
    public static boolean SHOW_SECTION_FRESH_ARRIVALS = true;

    // To show product best deals list section.
    public static boolean SHOW_SECTION_BEST_DEALS = true;

    // To show cart button with product at home/category page.
    public static boolean SHOW_CART_WITH_PRODUCT = false;

    // To show discounted percentage price section in product.
    public static boolean SHOW_DISCOUNT_PERCENTAGE_ON_PRODUCTS = false;

    // To hide product price section in App.
    public static boolean HIDE_PRODUCT_PRICE_TAG = false;

    // Enable Zero price order place condition.
    public static boolean ENABLE_ZERO_PRICE_ORDER = false;
    public static boolean ENABLE_OPINIONS = false;
    public static boolean ENABLE_WISHLIST = true;
    public static boolean ENABLE_CART = true;
    public static boolean ENABLE_SINGLE_CHECK_WISHLIST = false;

    // To hide Notification list.
    public static boolean HIDE_NOTIFICATIONS_LIST = false;
    public static boolean ENABLE_MULTIPLE_DELETE = false;
    public static boolean ENABLE_AUTOMATIC_BANNERS = true;

    // To show order shipping tracking section.
    public static boolean ENABLE_SHIPMENT_TRACKING = false;
    public static boolean ENABLE_CUSTOM_WISHLIST = false;
    public static boolean ENABLE_MULTIPLE_WISHLIST = false;
    public static boolean ENABLE_CUSTOM_WAITLIST = false;
    public static boolean ENABLE_CUSTOM_POINTS = false;
    public static boolean ENABLE_WEBVIEW_PAYMENT = false;
    public static boolean CHECK_MIN_ORDER_DATA = false;
    public static boolean ENABLE_APP_RATING = false;
    public static boolean ENABLE_WISHLIST_NOTE = false;
    public static boolean IS_VAT_EXEMPT = false;
    public static boolean ENABLE_MIXMATCH_PRODUCTS = false;

    // To enable/show Bundle(product with related sub-product) Product.
    public static boolean ENABLE_BUNDLED_PRODUCTS = false;

    // To show keep Shopping button in Cart page.
    public static boolean SHOW_KEEP_SHOPPING_IN_CART = false;

    // To enable order again after order placed in order list.
    public static boolean SHOW_ORDER_AGAIN = false;

    // To show total savings in cart.
    public static boolean SHOW_TOTAL_SAVINGS = true;

    // To show tag on new product.
    public static boolean SHOW_NEW_PRODUCT_TAG = false;

    // To show tag on sale type product.
    public static boolean SHOW_SALE_PRODUCT_TAG = false;

    // To show tag on out of stock product.
    public static boolean SHOW_OUTOFSTOCK_PRODUCT_TAG = false;
    public static boolean ENABLE_PRODUCT_DELIVERY_DATE = false;

    // For entering Special Order Note while Proceeding to Checkout and Show in Order list.
    public static boolean ENABLE_SPECIAL_ORDER_NOTE = false;

    // To show footer section in cart page.
    public static boolean SHOW_CART_FOOTER_OVERLAY = false;
    public static boolean SHOW_NESTED_CATEGORY_MENU = true;
    public static boolean SHOW_UPSELL_PRODUCTS = false;
    public static boolean SHOW_CROSSSEL_PRODUCTS = false;
    public static boolean SHOW_IOS_STYLE_SUB_CATEGORIES = false;
    public static boolean ENABLE_LOCALIZATION = false;

    // To show image/icon on action bar.
    public static boolean SHOW_ACTIONBAR_ICON = false;

    // To show Text Title in Action Bar.
    public static boolean SHOW_HOME_TITLE_TEXT = true;

    public static boolean SKIP_MANUAL_ENCODING = true;  // Skip encoding of special HEBREW kind of chars

    // To show search option at Home Page.
    public static boolean ADD_SEARCH_IN_HOME = false;

    // To enable Geo location search while search product.
    public static boolean GEO_LOC_SEARCH_IN_HOME = false;

    // To show minimum/maximum price of product.
    public static boolean SHOW_MIN_MAX_PRICE = false;

    // Using this Product attribute/variation should be by default selected.
    public static boolean AUTO_SELECT_VARIATION = true;

    // To show non variation Product Attribute.
    public static boolean SHOW_NON_VARIATION_ATTRIBUTE = false;

    // Select Shipping Address by Multiple Shipping Address shown in Map.
    public static boolean USE_MULTIPLE_SHIPPING_ADDRESSES = false;

    // To show App url while Share App.
    public static boolean SHOW_APP_URL_IN_SHARE_TEXT = false;

    // To show App price of product while Share App.
    public static boolean SHOW_PRICE_IN_SHARE_TEXT = false;
    public static boolean ENABLE_MULTI_STORE_CHECKOUT = false;
    public static boolean SHOW_PAYMENT_GATEWAY_DESCRIPTION = false;
    public static boolean SHOW_PAYMENT_GATEWAY_INSTRUCTIONS = false;
    public static boolean REMOVE_CART_OR_WISH_ITEMS = true;

    // To Send OTP when proceed to CashOnDelivery payment checkout.
    public static boolean ENABLE_OTP_IN_COD_PAYMENT = false;

    // To show loaded product count on Category page.
    public static boolean SHOW_CATEGORY_PRODUCTS_COUNT = false;

    // To show Category title in Capital letter(Upper Case).
    public static boolean CATEGORY_TITLE_ALL_CAPS = true;

    // To Use Google Latitude/Longitude for placing Order & Navigation Location.
    public static boolean USE_LAT_LONG_IN_ORDER = false;

    // To enable currency switcher show currency list for select.
    public static boolean ENABLE_CURRENCY_SWITCHER = false;

    // To show product PickUp Location for delivery.
    public static boolean SHOW_PICKUP_LOCATION = false;
    public static boolean REQUIRE_ORDER_PAYMENT_PROOF = false;

    // To Show price qty Label on Product.
    public static boolean SHOW_PRICE_LABELS = false;

    // To show product Booking Info.
    public static boolean SHOW_PRODUCTS_BOOKING_INFO = false;

    // To show confirmation dialog after order placed.
    public static boolean SHOW_ORDER_PLACED_DIALOG = false;

    // To show Footer/Bottom section in Navigation Drawer.
    public static boolean SHOW_BOTTOM_NAV_MENU = false;

    // To Enable Role Price Config.
    public static boolean ENABLE_ROLE_PRICE = false;
    public static boolean ENABLE_PRODUCT_ADDONS = false;
    public static boolean ENABLE_DEPOSIT_ADDONS = false;

    // To Enable/Disable Banner(Image) Slider to AutoSlide.
    public static boolean ENABLE_AUTO_SLIDE_BANNER = true;

    // Below these keys are for local configuration only

    // Controls whether use theme colors from cloud or not;
    public static boolean ENABLE_THEME_COLORS = true;

    // Controls whether use of Facebook in analytics
    public static boolean ENABLE_FACEBOOK_SDK = true;

    // Controls use of Fabric/Crashlytics for exceptions logging
    public static boolean ENABLE_CRASHLYTICS = true;

    // If you want to load configuration json from asset instead of parse server. // only for testing
    public static boolean ENABLE_LOCAL_CONFIG = false;

    public static boolean basic_content_loaded = false;
    public static boolean basic_content_loading = false;


    public static void resetAll() {
        ABOUT_URL = "";
        PROMO_URL = "";
        PROMO_TITLE = "";
        PROMO_DESC = "";
        PROMO_IMG_URL = "";
        FACEBOOK_APP_ID = "";
        TWITTER_APP_KEY = "";
        GOOGLE_APP_KEY = "";
        MERCHANT_ID = "";
        PRODUCT_DEEPLINK_URL = "";
        PRODUCT_DEEPLINK = "";
        SHIPPING_PROVIDER = "";
        SHIPPING_KEY = "";
        SHIPPING_TRACK_URL = "";
        ACTIONBAR_ICON_URL = null;
        DATE_FORMAT_PATTERN = "";
        EMAIL_DOMAIN = "";//@gmail.com
        ACTION_BAR_HOME_TITLE = "";

        ID_PLACEHOLDER_BANNER = 0;
        ID_PLACEHOLDER_PRODUCT = 0;
        ID_PLACEHOLDER_CATEGORY = 0;
        ID_LAYOUT_PRODUCTS = 0;
        ID_LAYOUT_CATEGORIES = 0;
        ID_LAYOUT_CART = 0;
        PENDING_NOTIFICATIONS = 0;
        PRODUCT_ACTIVITY_ANIMATION = 0;

        DRAWER_INDEX_CATEGORY = 1;
        DRAWER_INDEX_WP_MENU = 2;
        SHIPPING_MINIMUM_WEIGHT = 0;
        SHIPPING_DEFAULT_WEIGHT = 0;
        REQUIRED_PASSWORD_STRENGTH = 0;
        NEW_PRODUCT_DAYS_LIMIT = 7;

        HOME_SLIDER_STANDARD_WIDTH = 680;
        HOME_SLIDER_STANDARD_HEIGHT = 380;
        PRODUCT_SLIDER_STANDARD_WIDTH = 680;
        PRODUCT_SLIDER_STANDARD_HEIGHT = 380;

        HOME_MENU_ITEMS = new int[]{0, 1, 2, 3};
        PRODUCT_MENU_ITEMS = new int[]{0, 1, 4};

        homeConfigUltimate = null;
        homeConfigUltimateLand = null;
        mOrderNoteConfig = null;
        mCartNoteConfig = null;
        mImageDownloaderConfig = null;
        mGuestUserConfig = null;
        mCategoryLayoutsConfig = null;
        mProductDetailsConfig = new ProductDetailsConfig();
        drawerItems = null;
        profileItems = null;
        banners = null;
        contactDetails = null;
        restrictedCategories = null;
        homeMenuContactNumbers = null;
        front_page_categories = null;
        sort_config = "";
        drawer_header_bg = "";
        profile_header_bg = "";
        login_bg = "";
        EXCLUDED_ADDRESSES.clear();
        OPTIONAL_ADDRESSES.clear();

        DEMO_APP = false;
        ENABLE_COUPONS = false;
        HIDE_COUPON_LIST = false;
        FULL_SCREEN_LOGIN = false;
        CANCELLABLE_LOGIN = true;
        SHOW_LOGIN_AT_START = false;
        AUTO_LOAD_MORE_ITEMS = false;
        ENABLE_PROMO_BUTTON = false;
        AUTO_SIGNIN_IN_HIDDEN_WEBVIEW = true;
        SHOW_CATEGORY_BANNER_FULL = false;
        SHOW_CATEGORY_BANNER = true;
        SHOW_HOME_PAGE_BANNER = true;
        ENABLE_FILTERS = true;
        SHOW_SORTING_IF_FILTER_UNAVAILABLE = false;
        USE_HTTPTASK_WITH_COOKIES = true;
        ALLOW_NEGATIVE_SHIPPING_HACK = false;
        SHOW_SEASONAL_GREETINGS = false;
        USE_PARSE_ANALYTICS = true;
        SHOW_SECTION_TRENDING = true;
        SHOW_SECTION_FRESH_ARRIVALS = true;
        SHOW_SECTION_BEST_DEALS = true;
        ENABLE_FACEBOOK_SDK = true;
        SHOW_CART_WITH_PRODUCT = false;
        SHOW_DISCOUNT_PERCENTAGE_ON_PRODUCTS = false;
        HIDE_PRODUCT_PRICE_TAG = false;
        ENABLE_ZERO_PRICE_ORDER = false;
        ENABLE_OPINIONS = false;
        ENABLE_WISHLIST = true;
        ENABLE_SINGLE_CHECK_WISHLIST = false;
        HIDE_NOTIFICATIONS_LIST = false;
        ENABLE_MULTIPLE_DELETE = false;
        SHOW_SIGNUP_UI = true;
        ENABLE_AUTOMATIC_BANNERS = true;
        ENABLE_SHIPMENT_TRACKING = false;
        ENABLE_CUSTOM_WISHLIST = false;
        ENABLE_MULTIPLE_WISHLIST = false;
        ENABLE_CART = true;
        ENABLE_CUSTOM_WAITLIST = false;
        ENABLE_CUSTOM_POINTS = false;
        ENABLE_AUTO_COUPONS = false;
        ENABLE_WEBVIEW_PAYMENT = false;
        CHECK_MIN_ORDER_DATA = false;
        ENABLE_APP_RATING = false;
        ENABLE_WISHLIST_NOTE = false;
        ENABLE_MIXMATCH_PRODUCTS = false;
        ENABLE_BUNDLED_PRODUCTS = false;
        SHOW_KEEP_SHOPPING_IN_CART = false;
        IS_VAT_EXEMPT = false;
        SHOW_ORDER_AGAIN = false;
        EDIT_PROFILE_ON_LOGIN = true;
        SHOW_TOTAL_SAVINGS = true;
        SHOW_NEW_PRODUCT_TAG = false;
        SHOW_SALE_PRODUCT_TAG = false;
        SHOW_OUTOFSTOCK_PRODUCT_TAG = false;
        ENABLE_PRODUCT_DELIVERY_DATE = false;
        ENABLE_SPECIAL_ORDER_NOTE = false;
        SHOW_CART_FOOTER_OVERLAY = false;
        SHOW_NESTED_CATEGORY_MENU = true;
        SHOW_UPSELL_PRODUCTS = false;
        SHOW_CROSSSEL_PRODUCTS = false;
        SHOW_IOS_STYLE_SUB_CATEGORIES = false;
        ENABLE_LOCALIZATION = false;
        SHOW_ACTIONBAR_ICON = false;
        SKIP_MANUAL_ENCODING = true;
        ADD_SEARCH_IN_HOME = false;
        GEO_LOC_SEARCH_IN_HOME = false;
        SHOW_MIN_MAX_PRICE = false;
        AUTO_SELECT_VARIATION = true;
        AUTO_DETECT_ADDRESS = false;
        SHOW_HOME_TITLE_TEXT = true;
        SHOW_NON_VARIATION_ATTRIBUTE = false;
        USE_MULTIPLE_SHIPPING_ADDRESSES = false;
        SHOW_APP_URL_IN_SHARE_TEXT = false;
        SHOW_PRICE_IN_SHARE_TEXT = false;
        ENABLE_MULTI_STORE_CHECKOUT = false;
        SHOW_MOBILE_NUMBER_IN_SIGNUP = false;
        REQUIRE_MOBILE_NUMBER_IN_SIGNUP = false;
        SHOW_ONLY_MOBILE_NUMBER_IN_SIGNUP = false;
        SHOW_PAYMENT_GATEWAY_DESCRIPTION = false;
        SHOW_PAYMENT_GATEWAY_INSTRUCTIONS = false;
        SHOW_RESET_PASSWORD = false;
        REMOVE_CART_OR_WISH_ITEMS = true;
        ENABLE_OTP_IN_COD_PAYMENT = false;
        SHOW_CATEGORY_PRODUCTS_COUNT = false;
        CATEGORY_TITLE_ALL_CAPS = true;
        USE_LAT_LONG_IN_ORDER = false;
        ENABLE_CURRENCY_SWITCHER = false;
        SHOW_PICKUP_LOCATION = false;
        ENABLE_LOCATION_IN_FILTERS = false;
        ENABLE_FILTERS_PER_CATEGORY = false;
        REQUIRE_ORDER_PAYMENT_PROOF = false;
        SHOW_PRICE_LABELS = false;
        SHOW_PRODUCTS_BOOKING_INFO = false;
        SHOW_ORDER_PLACED_DIALOG = false;
        ENABLE_ROLE_PRICE = false;
        ENABLE_PRODUCT_ADDONS = false;
        ENABLE_DEPOSIT_ADDONS = false;
        basic_content_loaded = false;
        basic_content_loading = false;
        ENABLE_AUTO_SLIDE_BANNER = true;
    }
}
