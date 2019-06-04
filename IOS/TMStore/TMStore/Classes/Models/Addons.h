//
//  Addons.h
//  eCommerceApp
//
//  Created by Rishabh Jain on 01/10/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//
#import "Variables.h"
#import "ConsentScreenConfig.h"






enum ORDER_NOTE_CHAR_TYPE {
    ORDER_NOTE_CHAR_TYPE_ALPHANUMERIC,
    ORDER_NOTE_CHAR_TYPE_NUMERIC,
    ORDER_NOTE_CHAR_TYPE_TOTAL
};
enum CART_NOTE_CHAR_TYPE {
    CART_NOTE_CHAR_TYPE_ALPHANUMERIC,
    CART_NOTE_CHAR_TYPE_NUMERIC,
    CART_NOTE_CHAR_TYPE_TOTAL
};
enum CART_NOTE_LOCATION {
    CART_NOTE_LOCATION_AFTER_EACH_ITEM,
    CART_NOTE_LOCATION_BEFORE_PLACE_ORDER_BUTTON,
    CART_NOTE_LOCATION_BOTH,
    CART_NOTE_LOCATION_TOTAL
};
enum MULTIVENDOR_SCREEN {
    MULTIVENDOR_SCREEN_PRODUCT,
    MULTIVENDOR_SCREEN_SELLER
};
@interface ProductDetailsConfig : NSObject
+ (id)sharedInstance;
+ (void)resetInstance;
@property BOOL show_top_section;
@property BOOL show_image_slider;
@property BOOL show_share_button;
@property BOOL show_zoom_button;
@property BOOL show_combo_section;
@property BOOL show_product_title;
@property BOOL show_short_desc;
@property BOOL show_price;
@property BOOL show_reward_points;
@property BOOL show_variation_section;
@property BOOL show_quick_cart_section;
@property BOOL show_button_section;
@property BOOL show_opinion_section;
@property BOOL show_full_share_section;
@property BOOL show_waitlist_section;
@property BOOL show_details_section;
@property BOOL show_full_description;
@property BOOL show_show_more;
@property BOOL show_ratings_section;
@property BOOL show_reviews_section;
@property BOOL show_upsell_section;
@property BOOL show_related_section;
@property BOOL tap_to_exit;
@property BOOL show_related_products;
@property int product_short_desc_max_line;
@property float img_slider_height_ratio;
/*
 * Show brand names for product.
 * */
@property BOOL show_brand_names;

/*
 * Show price labels for product.
 * */
@property BOOL show_price_labels;

/*
 * Show quantity rules for product.
 * */
@property BOOL show_quantity_rules;

@property BOOL show_vertical_layout_components;
@property NSArray* contact_numbers;
@property BOOL show_buy_button_description;
@property BOOL select_variation_with_button;
@property BOOL show_additional_info;
@end


@interface GuestConfig : NSObject
+ (id)sharedInstance;
+ (void)resetInstance;
@property BOOL enable_cart;
@property BOOL prevent_cart;
@property BOOL prevent_wishlist;
@property BOOL hide_price;
@property BOOL guest_checkout;
@property NSMutableArray* restricted_categories;
@end

@interface OrderNote : NSObject
@property int note_char_type; //only two types: "alphanumeric" and "numeric"
@property int note_char_limit; // -1 indicates unlimited characters
@property int note_line_count; // display lines for the view rectangle
@property BOOL note_enabled;
@property BOOL note_single_line; //if true then comes after the text means vertically align the header text and the textview.
- (id)init;
@end

@interface CartNote : NSObject
@property int note_char_type;
@property int note_char_limit;
@property int note_line_count;
@property BOOL note_enabled;
@property BOOL note_single_line;
@property int note_location; //0 for note after each product & 1 for note before Place order button
- (id)init;
@end

@interface ExcludedAddress : NSObject

+ (id)sharedManager;
+ (void)resetInstance;

@property BOOL first_name;//value = true means enable & value = false means disable
@property BOOL last_name;
@property BOOL email;

@property BOOL billing_first_name;
@property BOOL billing_last_name;
@property BOOL billing_address_1;
@property BOOL billing_address_2;
@property BOOL billing_city;
@property BOOL billing_district;
@property BOOL billing_subdistrict;
@property BOOL billing_state;
@property BOOL billing_postcode;
@property BOOL billing_country;
@property BOOL billing_email;
@property BOOL billing_phone;
@property BOOL shipping_first_name;
@property BOOL shipping_last_name;
@property BOOL shipping_address_1;
@property BOOL shipping_address_2;
@property BOOL shipping_city;
@property BOOL shipping_district;
@property BOOL shipping_subdistrict;
@property BOOL shipping_state;
@property BOOL shipping_postcode;
@property BOOL shipping_country;
- (BOOL)isVisibleFirstName:(BOOL)isBillingAddress;
- (BOOL)isVisibleLastName:(BOOL)isBillingAddress;
- (BOOL)isVisibleAddress1:(BOOL)isBillingAddress;
- (BOOL)isVisibleAddress2:(BOOL)isBillingAddress;
- (BOOL)isVisibleCity:(BOOL)isBillingAddress;
- (BOOL)isVisibleSubdistrict:(BOOL)isBillingAddress;
- (BOOL)isVisibleDistrict:(BOOL)isBillingAddress;
- (BOOL)isVisibleState:(BOOL)isBillingAddress;
- (BOOL)isVisiblePostCode:(BOOL)isBillingAddress;
- (BOOL)isVisibleCountry:(BOOL)isBillingAddress;
- (BOOL)isVisibleEmail:(BOOL)isBillingAddress;
- (BOOL)isVisiblePhone:(BOOL)isBillingAddress;

//"excluded_addresses":[
//                      "first_name",
//                      "last_name",
//                      "email",
//                      "billing_first_name",
//                      "billing_last_name",
//                      "billing_address_1",
//                      "billing_address_2",
//                      "billing_city",
//                      "billing_state",
//                      "billing_postcode",
//                      "billing_country",
//                      "billing_email",
//                      "billing_phone",
//                      "shipping_first_name",
//                      "shipping_last_name",
//                      "shipping_address_1",
//                      "shipping_address_2",
//                      "shipping_city",
//                      "shipping_state",
//                      "shipping_postcode",
//                      "shipping_country"
//                      ]
@end
@interface DrawerItem : NSObject
@property int itemId;
@property NSString* itemName;
@property NSString* itemData;
@property NSArray* sortedCategoryArray;
@property NSArray* sortedCategoryIconArray;
- (id)init;
@end

@interface Language : NSObject
+ (id)sharedManager;
+ (void)resetInstance;
@property int version;
@property NSString* defaultLocale;
@property NSMutableArray* locales;
@property NSMutableArray* titles;
@property NSMutableArray* isDownloaded;
@property NSMutableArray* isRTLNeeded;
@property BOOL isLanguageKeyboardNeeded;
@property BOOL isLocalizationEnabled;
@end

@interface ShopSettings : NSObject
- (id)init;
//@property NSString* avatar_icon;
//@property NSString* first_name;
//@property NSString* last_name;
//@property NSString* shop_name;
//@property NSString* shop_contact;
//@property NSString* shop_address;
//@property NSString* shop_icon;

@property BOOL enable_avatar_icon;
@property BOOL enable_first_name;
@property BOOL enable_last_name;
@property BOOL enable_shop_name;
@property BOOL enable_shop_contact;
@property BOOL enable_shop_address;
@property BOOL enable_shop_icon;

@property NSMutableArray* profile_items;
@property BOOL show_location;
@property BOOL manage_stock;
@property BOOL other_options;
@property BOOL shipping_required;
@property BOOL show_parent_categories;
@property NSString* publish_status;
@property BOOL enable_subscription;
@end

@interface APPS : NSObject
- (id)init;
@property NSString* app_name;
@property NSString* app_id;
@property NSString* app_key;
@property NSString* apn;
@property NSString* gcm;
@property int pos;
@property NSString* title;
@property BOOL isEnabled;

@property NSString* sponsor_img_url;
@property BOOL enable_seller_app;
@property int ad_delay;
@property int ad_interval;
@property NSString* ad_id;
@property NSString* ad_unit_id;


@property NSString* plugin_name;
@property NSString* multiVendor_icon_url;
@property BOOL multiVendor_icon_reuse;
@property ShopSettings* multiVendor_shop_settings;
@property int upload_image_width;
@property int upload_image_height;

@end

//"app_name": "multivendor",
//"plugin": "wcvendors",
//"screen": "products",
//"shipping_required": false,
//"show_location": true,
//"manage_stock": false,
//"other_options": false,
//"tab_items": [
//              0,
//              1
//              ],
//"profile_items": [
//                  23,
//                  24,
//                  27
//                  ],
//"shop_settings": [
//                  "avatar_icon",
//                  "first_name",
//                  "last_name",
//                  "shop_name",
//                  "shop_contact",
//                  "shop_address",
//                  "shop_icon"
//                  ],
//"enabled": true





//{
//"app_name": "adwords_install_tracking",
//"enabled": true,
//"conversion_id": "864479184",
//"label": "zUorCJ_OnG0Q0M-bnAM",
//"value": "5.00",
//"is_repeatable": false
//}


//{
//    "app_name": "multivendor",
//    "plugin": "dokan",
//    "enabled;
//    "vendor_icon_url": "www.google.png/icon.png",
// 	  "vendor_icon_reuse": true
//}

/* Shipping configuration for AfterShip plugin */

@interface AfterShipConfig : NSObject

- (id)init;
@property NSString* provider;
@property NSString* trackingUrl;

@end

/* Shipping configuration for RajaOngkir plugin */

@interface RajaOngkirConfig : NSObject

- (id)init;
@property NSString* provider;
@property NSString* shippingKey;
@property int minimumWeight;
@property int defaultWeight;

@end

@interface Addons : NSObject
+ (id)sharedManager;
+ (void)resetManager;

@property NSDictionary* config;
@property BOOL show_child_cat_products_in_parent_cat;
@property BOOL show_cart_with_product;
@property BOOL show_wordpress_menu;
@property NSMutableArray* wordpress_menu_ids;
@property BOOL enable_opinions;
@property BOOL enable_zero_price_order;
@property BOOL hide_product_price_tag;
@property BOOL enable_product_ratings;
@property BOOL enable_product_reviews;
@property BOOL show_crosssell_products;
@property int required_password_strength;
@property NSMutableArray* home_menu_items;
@property NSMutableArray* product_menu_items;
@property NSMutableArray* drawer_items;
@property NSMutableArray* profile_items;
@property Language* language;
@property ExcludedAddress* excludedAddress;
@property APPS* hotline;
@property APPS* geoLocation;
@property APPS* multiVendor;
@property APPS* deliverySlotsCopiaPlugin;
@property APPS* localPickupTimeSelectPlugin;
@property APPS* firebaseAnalytics;
@property APPS* sponsorFriend;
@property APPS* productDeliveryDatePlugin;
@property APPS* googleAdmobPlugin;
@property ConsentScreenConfig* csConfig;
@property BOOL show_home_categories;
@property BOOL show_section_best_deals;
@property BOOL show_section_fresh_arrivals;
@property BOOL show_section_trending;
@property BOOL multiVendor_enable;
@property int multiVendor_screen_type;
@property BOOL auto_generate_variations;
@property BOOL add_search_in_home;
@property BOOL show_home_title_text;
@property BOOL show_home_title_image;
@property BOOL show_actionbar_icon;
@property NSString* actionbar_icon_url;

@property BOOL load_extra_attrib_data;
@property BOOL enable_cart;
@property BOOL hide_coupon_list;
- (NSString*)getTitleForLocale:(NSString*)locale;

@property BOOL show_min_max_price;

@property OrderNote* orderNote;
@property CartNote* cartNote;
@property NSMutableArray* addonPayments;

@property AfterShipConfig* afterShipConfig;
@property RajaOngkirConfig* rajaOngkirConfig;

@property BOOL enable_shipment_tracking;

@property BOOL enable_custom_wishlist;

@property BOOL enable_custom_waitlist;

@property BOOL enable_custom_points;
/*@property BOOL enable_sponsor_friend;*///DOUBT

@property BOOL enable_pincode_settings;

@property NSMutableArray* shippingConfigs;

@property BOOL show_categories_in_search;
@property BOOL cancellable_login;
@property BOOL show_login_at_start;

@property ProductDetailsConfig* productDetailsConfig;
@property GuestConfig* guestConfig;

@property BOOL enable_auto_coupons;
@property BOOL check_min_order_data;
@property BOOL show_keep_shopping_in_cart;
@property BOOL hide_price;

@property BOOL enable_mixmatch_products;
@property BOOL enable_bundled_products;


@property BOOL is_vat_exempt;
@property BOOL order_again;

@property BOOL show_billing_address;
@property BOOL show_shipping_address;
@property BOOL show_pickup_location;

@property BOOL enable_special_order_note;
@property NSString* date_format;
@property BOOL show_category_banner;
@property BOOL enable_webview_payment;
@property BOOL show_filter_price_with_tax;

@property BOOL show_mobile_number_in_signup;
@property BOOL require_mobile_number_in_signup;
@property BOOL show_nested_category_menu;
@property BOOL show_home_page_banner;
@property BOOL show_reset_password;
@property NSMutableArray* restricted_categories;
@property BOOL enable_multi_store_checkout;
@property BOOL enable_otp_in_cod_payment;

@property BOOL enable_role_price;//need to update to server team
@property BOOL enable_seller_only_app;

@property BOOL use_multiple_shipping_addresses;
@property BOOL hide_shipping_info;
@property BOOL enable_location_in_filters;

@property BOOL isDynamicLayoutEnable;
@property BOOL remove_cart_or_wish_items;

@property BOOL show_all_images;
@property BOOL resize_product_thumbs;
@property BOOL resize_product_images;
@property BOOL enable_currency_switcher;
@property BOOL use_plugin_for_pagging;
@property BOOL show_non_variation_attribute;

@end
