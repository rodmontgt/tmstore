package com.twist.tmstore.config;

import com.twist.tmstore.Constants;
import com.utils.JsonHelper;

import org.json.JSONException;
import org.json.JSONObject;

/**
 * Created by Twist Mobile on 21-Jul-16.
 */

public class MultiVendorConfig {
    public static final String SHOP_SETTING_FIRST_NAME = "first_name";
    public static final String SHOP_SETTING_LAST_NAME = "last_name";
    public static final String SHOP_SETTING_SHOP_NAME = "shop_name";
    public static final String SHOP_SETTING_SHOP_CONTACT = "shop_contact";
    public static final String SHOP_SETTING_SHOP_ADDRESS = "shop_address";
    public static final String SHOP_SETTING_AVATAR_ICON = "avatar_icon";
    public static final String SHOP_SETTING_SHOP_ICON = "shop_icon";

    public static final String ID_NAME = "name";
    public static final String ID_SHOP_NAME = "shop_name";
    public static final String ID_PHONE_NUMBER = "phone_number";
    public static final String ID_LOCATION = "location";
    public static final String ID_SHOP_ADDRESS = "shop_address";

    public static final int TAB_PROFILE = 0;
    public static final int TAB_PRODUCTS = 1;
    public static final int TAB_ORDERS = 2;

    private static MultiVendorConfig multiVendorConfig;

    private boolean enabled;
    private boolean enable_seller_app;
    private PluginType pluginType;
    private ScreenType screenType;
    private SignupType signupType;
    private String defaultRole;
    private boolean shippingRequired;
    private String layoutOrder[];
    private boolean show_sold_by = false;
    private boolean show_location = false;
    private boolean manage_stock = true;
    private boolean other_options = true;
    private boolean msrp_price = false;
    private boolean cost_of_good = false;
    private boolean show_parent_categories = true;
    private String publish_status = "pending";
    private boolean enable_subscription = false;
    private boolean enable_camera = false;

    private int[] tab_items = new int[]{TAB_PROFILE, TAB_PRODUCTS, TAB_ORDERS};
    private int[] profile_items = new int[]{Constants.MENU_ID_SELLER_PRODUCTS, Constants.MENU_ID_SELLER_UPLOAD_PRODUCT, Constants.MENU_ID_SELLER_ORDERS, Constants.MENU_ID_SELLER_STORE_SETTINGS};
    private String[] shop_settings = new String[]{SHOP_SETTING_FIRST_NAME, SHOP_SETTING_LAST_NAME, SHOP_SETTING_SHOP_ADDRESS, SHOP_SETTING_SHOP_CONTACT};
    private int upload_image_width = 1080;
    private int upload_image_height = 1920;

    private MultiVendorConfig() {
        this.enabled = false;
        this.enable_seller_app = false;
        this.pluginType = PluginType.DEFAULT;
        this.shippingRequired = false;
        this.layoutOrder = new String[]{ID_NAME, ID_SHOP_NAME, ID_PHONE_NUMBER, ID_LOCATION, ID_SHOP_ADDRESS};
    }

    public static String getDefaultRole() {
        return multiVendorConfig.defaultRole;
    }

    public static void createConfig(JSONObject jsonObject) {
        try {
            multiVendorConfig = new MultiVendorConfig();
            multiVendorConfig.enabled = JsonHelper.getBool(jsonObject, "enabled", true);
            multiVendorConfig.enable_seller_app = JsonHelper.getBool(jsonObject, "enable_seller_app", false);
            multiVendorConfig.pluginType = PluginType.from(JsonHelper.getString(jsonObject, "plugin"));
            multiVendorConfig.signupType = SignupType.from(JsonHelper.getString(jsonObject, "signup_type"));
            multiVendorConfig.screenType = ScreenType.from(JsonHelper.getString(jsonObject, "screen"));
            multiVendorConfig.defaultRole = JsonHelper.getString(jsonObject, "default_role", "VENDOR");
            multiVendorConfig.shippingRequired = JsonHelper.getBool(jsonObject, "shipping_required", multiVendorConfig.shippingRequired);
            if (jsonObject.has("layout_order")) {
                multiVendorConfig.layoutOrder = JsonHelper.getStringArray(jsonObject, "layout_order");
            }
            multiVendorConfig.show_sold_by = JsonHelper.getBool(jsonObject, "show_sold_by", multiVendorConfig.show_sold_by);
            multiVendorConfig.show_location = JsonHelper.getBool(jsonObject, "show_location", multiVendorConfig.show_location);
            multiVendorConfig.manage_stock = JsonHelper.getBool(jsonObject, "manage_stock", multiVendorConfig.manage_stock);
            multiVendorConfig.other_options = JsonHelper.getBool(jsonObject, "other_options", multiVendorConfig.other_options);
            multiVendorConfig.msrp_price = JsonHelper.getBool(jsonObject, "msrp_price", multiVendorConfig.msrp_price);
            multiVendorConfig.cost_of_good = JsonHelper.getBool(jsonObject, "cost_of_good", multiVendorConfig.cost_of_good);
            multiVendorConfig.show_parent_categories = JsonHelper.getBool(jsonObject, "show_parent_categories", multiVendorConfig.show_parent_categories);
            multiVendorConfig.publish_status = JsonHelper.getString(jsonObject, "publish_status", multiVendorConfig.publish_status);

            if (jsonObject.has("tab_items")) {
                multiVendorConfig.tab_items = JsonHelper.getIntArray(jsonObject, "tab_items");
                if (multiVendorConfig.tab_items == null) {
                    multiVendorConfig.tab_items = new int[]{TAB_PROFILE, TAB_PRODUCTS, TAB_ORDERS};
                }
            }

            if (jsonObject.has("profile_items")) {
                multiVendorConfig.profile_items = JsonHelper.getIntArray(jsonObject, "profile_items");
                if (multiVendorConfig.profile_items == null) {
                    multiVendorConfig.profile_items = new int[]{Constants.MENU_ID_SELLER_PRODUCTS, Constants.MENU_ID_SELLER_UPLOAD_PRODUCT, Constants.MENU_ID_SELLER_ORDERS, Constants.MENU_ID_SELLER_STORE_SETTINGS};
                }
            }

            if (jsonObject.has("shop_settings")) {
                multiVendorConfig.shop_settings = JsonHelper.getStringArray(jsonObject, "shop_settings");
                if (multiVendorConfig.shop_settings == null)
                    multiVendorConfig.shop_settings  = new String[]{SHOP_SETTING_FIRST_NAME, SHOP_SETTING_LAST_NAME, SHOP_SETTING_SHOP_ADDRESS, SHOP_SETTING_SHOP_CONTACT};
            }

            if (jsonObject.has("enable_subscription")) {
                multiVendorConfig.enable_subscription = JsonHelper.getBool(jsonObject, "enable_subscription");
            }

            if (jsonObject.has("enable_camera")) {
                multiVendorConfig.enable_camera = JsonHelper.getBool(jsonObject, "enable_camera");
            }

            if (jsonObject.has("upload_options")) {
                try {
                    JSONObject upload_options = jsonObject.getJSONObject("upload_options");
                    multiVendorConfig.upload_image_width = upload_options.getInt("image_width");
                    multiVendorConfig.upload_image_height = upload_options.getInt("image_height");
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void resetConfig() {
        multiVendorConfig = null;
    }

    public static boolean isShowVendorLayoutCenter() {
        return multiVendorConfig != null && multiVendorConfig.show_sold_by;
    }

    public static String[] getLayoutOrder() {
        if (multiVendorConfig != null) {
            return multiVendorConfig.layoutOrder;
        }
        return null;
    }

    public static boolean isEnabled() {
        return multiVendorConfig != null && multiVendorConfig.enabled;
    }

    public static PluginType getPluginType() {
        if (multiVendorConfig != null) {
            return multiVendorConfig.pluginType;
        }
        return PluginType.DEFAULT;
    }

    public static ScreenType getScreenType() {
        if (multiVendorConfig != null) {
            return multiVendorConfig.screenType;
        }
        return ScreenType.VENDORS;
    }

    public static SignupType getSignupType() {
        if (multiVendorConfig != null) {
            return multiVendorConfig.signupType;
        }
        return SignupType.OPTIONAL;
    }

    public static boolean isShippingRequired() {
        return multiVendorConfig != null && multiVendorConfig.shippingRequired;
    }

    public static boolean isSellerApp() {
        return multiVendorConfig != null
                && multiVendorConfig.enabled
                && multiVendorConfig.enable_seller_app;
    }

    public static boolean shouldShowLocation() {
        return isEnabled() && multiVendorConfig.show_location;
    }

    public static boolean shouldManageStock() {
        return isEnabled() && multiVendorConfig.manage_stock;
    }

    public static boolean shouldShowOtherOptions() {
        return isEnabled() && multiVendorConfig.other_options;
    }

    public static boolean shouldShowMsrpPrice() {
        return isEnabled() && multiVendorConfig.msrp_price;
    }

    public static boolean shouldShowCostOfGood() {
        return isEnabled() && multiVendorConfig.cost_of_good;
    }

    public static boolean shouldShowParentCategory() {
        return isEnabled() && multiVendorConfig.show_parent_categories;
    }

    public static boolean isSubscriptionEnabled() {
        return isEnabled() && multiVendorConfig.enable_subscription;
    }

    public static boolean isCameraUploadEnabled() {
        return isEnabled() && multiVendorConfig.enable_camera;
    }

    public static String getPublishStatus() {
        return multiVendorConfig.publish_status;
    }

    public static int[] getTabItems() {
        return multiVendorConfig.tab_items;
    }

    public static int[] getProfileItems() {
        return multiVendorConfig.profile_items;
    }

    public static String[] getShopSettings() {
        return multiVendorConfig.shop_settings;
    }

    public static int getUploadImageWidth() {
        return multiVendorConfig.upload_image_width;
    }

    public static int getUploadImageHeight() {
        return multiVendorConfig.upload_image_height;
    }

    public enum PluginType {
        DEFAULT(""),
        DOKAN("dokan"),
        WCVENDORS("wcvendors");

        private final String value;

        PluginType(String value) {
            this.value = value;
        }

        public static PluginType from(String name) {
            if (name != null && !name.equals("")) {
                for (PluginType type : values()) {
                    if (type.getValue().equalsIgnoreCase(name)) {
                        return type;
                    }
                }
            }
            return DEFAULT;
        }

        public String getValue() {
            return this.value;
        }
    }

    public enum ScreenType {
        VENDORS("vendors"),
        PRODUCTS("products");

        private final String value;

        ScreenType(String value) {
            this.value = value;
        }

        public static ScreenType from(String name) {
            if (name != null && !name.equals("")) {
                for (ScreenType type : values()) {
                    if (type.getValue().equalsIgnoreCase(name)) {
                        return type;
                    }
                }
            }
            return VENDORS;
        }

        public String getValue() {
            return this.value;
        }
    }

    public enum SignupType {
        LEGACY("legacy"),
        OPTIONAL("optional"),
        REQUIRED("required");

        private final String value;

        SignupType(String value) {
            this.value = value;
        }

        public static SignupType from(String name) {
            if (name != null && !name.equals("")) {
                for (SignupType type : values()) {
                    if (type.getValue().equalsIgnoreCase(name)) {
                        return type;
                    }
                }
            }
            return OPTIONAL;
        }

        public String getValue() {
            return this.value;
        }
    }
}
