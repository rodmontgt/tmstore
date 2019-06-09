//
//  Addons.m
//  eCommerceApp
//
//  Created by Rishabh Jain on 01/10/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import "Addons.h"
#import "Variables.h"
@implementation GuestConfig
static GuestConfig *guestConfigObj = nil;
+ (id)sharedInstance {
    @synchronized(self) {
        if (guestConfigObj == nil){
            guestConfigObj = [[self alloc] init];
        }
    }
    return guestConfigObj;
}
+ (void)resetInstance {
    guestConfigObj = nil;
}
- (id)init {
    if (self = [super init]) {
        self.enable_cart = false;
        self.prevent_cart = false;
        self.prevent_wishlist = false;
        self.hide_price = false;
        self.guest_checkout = false;
        self.restricted_categories = [[NSMutableArray alloc] init];
    }
    return self;
}
@end


@implementation ProductDetailsConfig
static ProductDetailsConfig *productDetailsConfigObj = nil;
+ (id)sharedInstance {
    @synchronized(self) {
        if (productDetailsConfigObj == nil){
            productDetailsConfigObj = [[self alloc] init];
        }
    }
    return productDetailsConfigObj;
}
+ (void)resetInstance {
    productDetailsConfigObj = nil;
}
- (id)init {
    if (self = [super init]) {
        self.show_top_section = true;
        self.show_image_slider = true;
        self.show_share_button = true;
        self.show_zoom_button = true;
        
        self.show_combo_section = true;
        self.show_product_title = true;
        self.show_short_desc = true;
        self.show_price = true;
        self.show_reward_points = true;
        
        self.show_variation_section = true;
        
        self.show_quick_cart_section = false;
        self.show_button_section = true;
        self.show_opinion_section = true;
        self.show_waitlist_section = true;
        
        self.show_details_section = true;
        self.show_full_description = true;
        self.show_show_more = true;
        self.show_ratings_section = true;
        self.show_reviews_section = true;
        
        self.show_upsell_section = false;
        self.show_related_section = false;
        self.tap_to_exit = false;
        self.show_brand_names = false;
        self.show_price_labels = false;
        self.show_quantity_rules = false;
        
        self.show_vertical_layout_components = false;
        self.contact_numbers = nil;
        self.show_full_share_section= false;
        self.show_buy_button_description = false;
        self.select_variation_with_button = false;
        self.show_additional_info = true;
        self.product_short_desc_max_line = -1;
        self.img_slider_height_ratio = 1.0f;
    }
    return self;
}
@end

@implementation OrderNote
- (id)init {
    if (self = [super init]) {
        self.note_char_limit = -1;
        self.note_char_type = ORDER_NOTE_CHAR_TYPE_ALPHANUMERIC;
        self.note_enabled = false;
        self.note_line_count = 1;
        self.note_single_line = false;
    }
    return self;
}
@end

@implementation CartNote
- (id)init {
    if (self = [super init]) {
        self.note_char_limit = -1;
        self.note_char_type = CART_NOTE_CHAR_TYPE_ALPHANUMERIC;
        self.note_enabled = false;
        self.note_line_count = 1;
        self.note_single_line = false;
        self.note_location = CART_NOTE_LOCATION_BEFORE_PLACE_ORDER_BUTTON;
    }
    return self;
}
@end

@implementation ExcludedAddress
static ExcludedAddress *sharedManagerObj = nil;
+ (id)sharedManager {
    @synchronized(self) {
        if (sharedManagerObj == nil){
            sharedManagerObj = [[self alloc] init];
        }
    }
    return sharedManagerObj;
}
+ (void)resetInstance {
    sharedManagerObj = nil;
}
- (id)init {
    if (self = [super init]) {
        self.first_name = true;
        self.last_name = true;
        self.email = true;
        self.billing_first_name = true;
        self.billing_last_name = true;
        self.billing_address_1 = true;
        self.billing_address_2 = true;
        self.billing_city = true;
        self.billing_district = true;
        self.billing_subdistrict = true;
        self.billing_state = true;
        self.billing_postcode = true;
        self.billing_country = true;
        self.billing_email = true;
        self.billing_phone = true;
        self.shipping_first_name = true;
        self.shipping_last_name = true;
        self.shipping_address_1 = true;
        self.shipping_address_2 = true;
        self.shipping_city = true;
        self.shipping_district = true;
        self.shipping_subdistrict = true;
        self.shipping_state = true;
        self.shipping_postcode = true;
        self.shipping_country = true;
    }
    return self;
}
- (BOOL)isVisibleFirstName:(BOOL)isBillingAddress {
    if (isBillingAddress) {
        return _billing_first_name;
    }
    return _shipping_first_name;
}
- (BOOL)isVisibleLastName:(BOOL)isBillingAddress {
    if (isBillingAddress) {
        return _billing_last_name;
    }
    return _shipping_last_name;
}
- (BOOL)isVisibleAddress1:(BOOL)isBillingAddress {
    if (isBillingAddress) {
        return _billing_address_1;
    }
    return _shipping_address_1;
}
- (BOOL)isVisibleAddress2:(BOOL)isBillingAddress {
    if (isBillingAddress) {
        return _billing_address_2;
    }
    return _shipping_address_2;
}
- (BOOL)isVisibleCity:(BOOL)isBillingAddress {
    if (isBillingAddress) {
        return _billing_city;
    }
    return _shipping_city;
}
- (BOOL)isVisibleDistrict:(BOOL)isBillingAddress {
    if (isBillingAddress) {
        return _billing_district;
    }
    return _shipping_district;
}
- (BOOL)isVisibleSubdistrict:(BOOL)isBillingAddress {
    if (isBillingAddress) {
        return _billing_subdistrict;
    }
    return _shipping_subdistrict;
}
- (BOOL)isVisibleState:(BOOL)isBillingAddress {
    if (isBillingAddress) {
        return _billing_state;
    }
    return _shipping_state;
}
- (BOOL)isVisiblePostCode:(BOOL)isBillingAddress {
    if (isBillingAddress) {
        return _billing_postcode;
    }
    return _shipping_postcode;
}
- (BOOL)isVisibleCountry:(BOOL)isBillingAddress {
    if (isBillingAddress) {
        return _billing_country;
    }
    return _shipping_country;
}
- (BOOL)isVisibleEmail:(BOOL)isBillingAddress {
    if (isBillingAddress) {
        return _billing_email;
    }
    return _billing_email;
}
- (BOOL)isVisiblePhone:(BOOL)isBillingAddress {
    if (isBillingAddress) {
        return _billing_phone;
    }
    return _billing_phone;
}
@end


@implementation ShopSettings
- (id)init {
    if (self = [super init]) {
        self.profile_items = [[NSMutableArray alloc] init];
        self.show_location = false;
        self.manage_stock = false;
        self.other_options = false;
        self.shipping_required = false;
        self.show_parent_categories = true;
        self.publish_status = @"pending";
    }
    return self;
}
@end
//"app_name": "timeSlot",
//"plugin": "woocommerce_delivery_slots_copia/woocommerce_local_pickup_time_select",
//"enabled": true
@implementation APPS
- (id)init {
    if (self = [super init]) {
        self.app_name = @"";
        self.app_id = @"";
        self.app_key = @"";
        self.gcm = @"";
        self.apn = @"";
        self.title = @"";
        self.pos = 0;
        self.isEnabled = false;
        self.plugin_name = @"";
        self.enable_seller_app = false;
        self.ad_delay = 0;
        self.ad_interval = 0;
        self.ad_id = @"";
        self.ad_unit_id = @"";
        self.upload_image_height = 1920.0f;
        self.upload_image_width = 1080.0f;
        self.multiVendor_shop_settings = [[ShopSettings alloc] init];
    }
    return self;
}
@end
@implementation DrawerItem
- (id)init {
    if (self = [super init]) {
        self.itemId = -1;
        self.itemName = @"";
        self.itemData = @"";
    }
    return self;
}
@end

@implementation Language
static Language *sharedLanguageManager = nil;
+ (id)sharedManager {
    @synchronized(self) {
        if (sharedLanguageManager == nil){
            sharedLanguageManager = [[self alloc] init];
        }
    }
    return sharedLanguageManager;
}
+ (void)resetInstance {
    sharedLanguageManager = nil;
}
- (id)init {
    if (self = [super init]) {
        _version = 0;
        _defaultLocale = @"";
        _locales = [[NSMutableArray alloc] init];
        _titles = [[NSMutableArray alloc] init];
        _isRTLNeeded = [[NSMutableArray alloc] init];
        _isLanguageKeyboardNeeded = false;
        _isLocalizationEnabled = true;
    }
    return self;
}
@end

@implementation AfterShipConfig
- (id)init {
    if (self = [super init]) {
        self.provider = @"";
        self.trackingUrl = @"";
    }
    return self;
}
@end

@implementation RajaOngkirConfig
- (id)init {
    if (self = [super init]) {
        self.provider = @"";
        self.shippingKey = @"";
        self.minimumWeight = 0;
        self.defaultWeight = 0;
    }
    return self;
}
@end

@implementation Addons
static Addons *sharedAddonsManager = nil;
+ (id)sharedManager {
    @synchronized(self) {
        if (sharedAddonsManager == nil){
            sharedAddonsManager = [[self alloc] init];
        }
    }
    return sharedAddonsManager;
}
+ (void)resetManager {
    sharedAddonsManager = nil;
}
- (id)init {
    if (self = [super init]) {
        self.config = [[NSMutableDictionary alloc] init];
        self.show_child_cat_products_in_parent_cat = false;
        self.show_cart_with_product = false;
#if TEST_SHOW_CART_WITH_PRODUCTS
        self.show_cart_with_product = true;
#endif
        self.show_wordpress_menu = false;
        self.wordpress_menu_ids = [[NSMutableArray alloc] init];
        self.enable_opinions = false;
        self.enable_zero_price_order = false;
        self.hide_product_price_tag = false;
        self.enable_product_ratings = false;
        self.enable_product_reviews = false;
        self.show_crosssell_products = false;
        self.required_password_strength = false;
        self.home_menu_items = [[NSMutableArray alloc] init];
        self.product_menu_items = [[NSMutableArray alloc] init];
        self.drawer_items = [[NSMutableArray alloc] init];
        self.profile_items = [[NSMutableArray alloc] init];
        self.language = [Language sharedManager];
        self.excludedAddress = [ExcludedAddress sharedManager];
        self.hotline = nil;
        self.geoLocation = nil;
        self.multiVendor = nil;
        self.deliverySlotsCopiaPlugin = nil;
        self.localPickupTimeSelectPlugin = nil;
        self.firebaseAnalytics = nil;
        self.sponsorFriend = nil;
        self.productDeliveryDatePlugin = nil;
        self.googleAdmobPlugin = nil;
        self.show_section_best_deals = true;
        self.show_section_fresh_arrivals = true;
        self.show_section_trending = true;
        self.show_home_categories = true;
        self.multiVendor_enable = false;
        self.show_min_max_price = false;
        self.orderNote = nil;
        self.cartNote = nil;
        self.addonPayments = [[NSMutableArray alloc] init];
        self.shippingConfigs = [[NSMutableArray alloc] init];
        self.auto_generate_variations = true;
        self.show_categories_in_search = false;
        self.add_search_in_home = false;
        self.show_home_title_text = true;
        self.show_home_title_image = false;
        self.show_actionbar_icon = false;
        self.actionbar_icon_url = @"";
        self.load_extra_attrib_data = false;
        self.afterShipConfig = nil;
        self.rajaOngkirConfig = nil;
		self.enable_shipment_tracking = false;
        self.enable_custom_points = false;
        self.enable_custom_waitlist = false;
        self.enable_custom_wishlist = false;
        /*self.enable_sponsor_friend = false;*/
        self.enable_pincode_settings = false;
        self.show_categories_in_search = false;
        self.productDetailsConfig = [ProductDetailsConfig sharedInstance];
        self.guestConfig = [GuestConfig sharedInstance];
        self.show_keep_shopping_in_cart = false;
        self.enable_cart = true;
        self.hide_price = false;
        self.enable_mixmatch_products = false;
        self.enable_bundled_products = false;
        self.is_vat_exempt = false;
        self.order_again = false;
		self.cancellable_login = true;
		self.show_login_at_start = false;
        self.show_billing_address = true;
        self.show_shipping_address = true;
        self.show_pickup_location = false;
        self.hide_coupon_list = false;
        self.date_format = @"dd/MM/yyyy";
		
//#if ENABLE_PRODUCT_DELIVERY_DATA_PLUGIN_TEST
//        self.productDeliveryDatePlugin = [[APPS alloc] init];
//        self.productDeliveryDatePlugin.isEnabled = true;
//#endif
        
        self.enable_special_order_note = false;
        self.show_category_banner = true;
        self.enable_webview_payment = true;
        self.show_filter_price_with_tax = false;//default value is false, this variable is true only when we are showing product price with tax in whole app.
        
        self.show_mobile_number_in_signup = false;
        self.require_mobile_number_in_signup = false;
#if TEST_OTP_LOGIN
        self.show_mobile_number_in_signup = true;
        self.require_mobile_number_in_signup = true;
#endif
        self.show_nested_category_menu = true;
#if TEST_SHOW_NESTED_CATEGORY_MENU_FALSE
        self.show_nested_category_menu = false;
#endif
		self.show_home_page_banner = true;       
        self.show_reset_password = false;    
        self.restricted_categories = [[NSMutableArray alloc] init];
        
        self.enable_multi_store_checkout = false;
#if ENABLE_CHECKOUT_MANAGER && TEST_CHECKOUT_MANAGER
        self.enable_multi_store_checkout = true;
#endif     
        
        self.enable_otp_in_cod_payment = false;
#if ENABLE_OTP_AT_CHECKOUT && TEST_OTP_AT_CHECKOUT
        self.enable_otp_in_cod_payment = true;
#endif
        
        self.enable_role_price = false;
#if ENABLE_USER_ROLE && TEST_USER_ROLE
        self.enable_role_price = true;
#endif
        
        self.enable_seller_only_app = false;
        
        
        self.use_multiple_shipping_addresses = false;
#if ENABLE_ADDRESS_WITH_MAP && TEST_ADDRESS_WITH_MAP
        self.use_multiple_shipping_addresses = true;
#endif
        
        self.hide_shipping_info = false;
        self.enable_location_in_filters = false;
        self.csConfig = [ConsentScreenConfig sharedInstance];
        
        self.isDynamicLayoutEnable = false;
        self.remove_cart_or_wish_items = true;
        
        self.show_all_images = true;
        self.resize_product_thumbs = false;
        self.resize_product_images = false;
        self.enable_currency_switcher = false;
        self.show_non_variation_attribute = false;
    }
    return self;
}
- (NSString*)getTitleForLocale:(NSString*)locale {
    Addons* addons = [Addons sharedManager];
    if (addons.language && addons.language.locales && [addons.language.locales count] > 0) {
        for (int i = 0; i < (int)[addons.language.locales count]; i++) {
            if ([addons.language.locales[i] isEqualToString:locale]) {
                return addons.language.titles[i];
            }
        }
    }
    return @"";
}
@end
