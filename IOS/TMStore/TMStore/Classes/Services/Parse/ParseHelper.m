//
//  ParseHelper.m
//  eCommerceApp
//
//  Created by Rishabh Jain on 01/10/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import "ParseHelper.h"
#import "Opinion.h"
#import "CustomerData.h"
#import "Order.h"
#import "Cart.h"
#import "Wishlist.h"
#import "Banner.h"
#import "LayoutManager.h"
#import "Addons.h"
#import "AppDelegate.h"
#import "UIAlertView+NSCookbook.h"
#import "ShippingWooCommerce.h"
#import "ShippingRajaongkir.h"
#import "StoreConfig.h"
#import "MapMenuOptions.h"

#define ENABLE_OLD_OBJ 1
#define PARSE_ERROR_CODE_OBJECT_NOT_FOUND 101

static int retryCount = 0;
static double NEAR_BY_STORES_IN_KM = 15.0;
@implementation ParseHelper
static ParseHelper *pHelper = nil;
+ (id)sharedManager {
    if (pHelper == nil)
        pHelper = [[self alloc] init];
    return pHelper;
}
+ (void)resetManager {
    pHelper.isParseDataLoaded = false;
}
- (id)init {
    if (self = [super init]) {
        self.isParseDataLoaded = false;
        self.appDataRows = nil;
    }
    return self;
}
- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

- (void)checkDataLoaded {
    if (![Utility isNetworkAvailable]) {
        [MRProgressOverlayView dismissAllOverlaysForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:Localize(@"no_network_connection") message:Localize(@"try_again") delegate:nil cancelButtonTitle:Localize(@"retry") otherButtonTitles:nil];
        [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [self checkDataLoaded];
        }];
        return;
    }
    if (!_isParseDataLoaded) {
        if ([[DataManager sharedManager] appType] == APP_TYPE_DEMO) {
            [self loadParseDataDemo:[[DataManager sharedManager] merchantObjectId]];
        } else {
            [self loadParseData];
        }
    }
}
- (void)parseDataDemo:(PFObject*)object {
    RLOG(@"Object %@", object);

    NSString* strBaseURL = [object objectForKey:@"site_url"];
    NSString* strOauthConsumerKey = [object objectForKey:@"wc_api_key"];
    NSString* strOauthConsumerSecret = [object objectForKey:@"wc_api_secret"];

    NSString* strStoreName = @"WooCommerce";
    NSString* strStoreVersion = @"v3";
    NSString* strStoreContactUs = @"http://www.thetmstore.com/#contact";
    NSString* strStoreAboutUs = @"http://www.thetmstore.com";


    Addons* addons = [Addons sharedManager];
    [addons.shippingConfigs removeAllObjects];
    ShippingConfigWooCommerce* config = [ShippingConfigWooCommerce getInstance];
    [addons.shippingConfigs addObject:config];

    if (IS_NOT_NULL(object, @"addons")) {
        NSString* addonsStr = [object objectForKey:@"addons"];
        NSError *jsonError;
        NSData *objectData = [addonsStr dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData options:NSJSONReadingMutableContainers error:&jsonError];
        [self loadAddons:json];
    }


    DataManager* dm = [DataManager sharedManager];
    dm.tmDataDoctor = [TMDataDoctor initWithParameter:strStoreName storeVersion:strStoreVersion baseUrl:strBaseURL consumerKey:strOauthConsumerKey consumerSecretKey:strOauthConsumerSecret pagelinkContactus:strStoreContactUs pagelinkAboutus:strStoreAboutUs];
    [dm.shippingEngines removeAllObjects];
    for (NSObject* obj in [[Addons sharedManager] shippingConfigs]) {
        if ([obj isKindOfClass:[ShippingConfigWooCommerce class]]) {
            ShippingConfigWooCommerce* config = (ShippingConfigWooCommerce*)obj;
            if (config.cIsEnabled) {
                config.cBaseUrl = strBaseURL;
                [dm.shippingEngines addObject:[[ShippingWooCommerce alloc] init:config.cBaseUrl]];
            }
        }
        else if ([obj isKindOfClass:[ShippingConfigRajaongkir class]]) {
            ShippingConfigRajaongkir* config = (ShippingConfigRajaongkir*)obj;
            if (config.cIsEnabled) {
                config.cBaseUrl = strBaseURL;
                [dm.shippingEngines addObject:[[ShippingRajaongkir alloc] init:config.cBaseUrl keyRajaongkir:config.cKey]];
            }
        }
    }

    if (IS_NOT_NULL(object, @"fb_appid")) {
        dm.keyFacebookAppId = [object objectForKey:@"fb_appid"];
    }
    if (IS_NOT_NULL(object, @"fb_secret")) {
        dm.keyFacebookConsumerSecret = [object objectForKey:@"fb_secret"];
    }
    if (IS_NOT_NULL(object, @"twitter_key")) {
        dm.keyTwitterConsumerKey = [object objectForKey:@"twitter_key"];
    }
    if (IS_NOT_NULL(object, @"twitter_secret")) {
        dm.keyTwitterConsumerSecret = [object objectForKey:@"twitter_secret"];
    }
    if (IS_NOT_NULL(object, @"google_key")) {
        dm.keyGoogleClientId = [object objectForKey:@"google_key"];
    }
    if (IS_NOT_NULL(object, @"google_secret")) {
        dm.keyGoogleClientSecret = [object objectForKey:@"google_secret"];
    }
    if (IS_NOT_NULL(object, @"enable_filters")) {
        dm.enable_filters = [[object objectForKey:@"enable_filters"] boolValue];
    }
    if (IS_NOT_NULL(object, @"show_tmstore_text")) {
        dm.show_tmstore_text = [[object objectForKey:@"show_tmstore_text"] boolValue];
    }
#if (ENABLE_FULL_SPLASH_ON_LAUNCH_NEW == 0)
    if (IS_NOT_NULL(object, @"splash_url")) {
        dm.splashUrlImgPath = [object objectForKey:@"splash_url"];
        [[NSUserDefaults standardUserDefaults] setValue:dm.splashUrlImgPath forKey:@"SPLASH_IMG"];
    }
    if (IS_NOT_NULL(object, @"splash_data")) {
        NSString* splashData = [object objectForKey:@"splash_data"];
        NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:[splashData dataUsingEncoding:NSUTF8StringEncoding] options:0 error:NULL];
        if([[MyDevice sharedManager] isIphone]) {
            float screenRatio = [[MyDevice sharedManager] screenHeightInPortrait]/[[MyDevice sharedManager] screenWidthInPortrait];
            if (screenRatio > 1.5f) {
                dm.splashUrlImgPathPortrait = [jsonObject objectForKey:@"ios_1920_1080"];
            } else {
                dm.splashUrlImgPathPortrait = [jsonObject objectForKey:@"ios_960_640"];
            }
            [[NSUserDefaults standardUserDefaults] setValue:dm.splashUrlImgPathPortrait forKey:@"SPLASH_IMG_PORTRAIT"];
        } else {
            dm.splashUrlImgPathPortrait = [jsonObject objectForKey:@"ios_1024_768"];
            dm.splashUrlImgPathLandscape = [jsonObject objectForKey:@"ios_768_1024"];
            [[NSUserDefaults standardUserDefaults] setValue:dm.splashUrlImgPathPortrait forKey:@"SPLASH_IMG_PORTRAIT"];
            [[NSUserDefaults standardUserDefaults] setValue:dm.splashUrlImgPathLandscape forKey:@"SPLASH_IMG_LANDSCAPE"];
        }
    }
    else {
        [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"SPLASH_IMG_PORTRAIT"];
        [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"SPLASH_IMG_LANDSCAPE"];
    }
#endif

    if (IS_NOT_NULL(object, @"app_color")) {
        NSData *data = [[object objectForKey:@"app_color"] dataUsingEncoding:NSUTF8StringEncoding];
        dm.colorDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        RLOG(@"dm.colorDict = %@",  dm.colorDict);
#if ENABLE_UI_COLOR_FORM_SERVER
        {
            if (IS_NOT_NULL(dm.colorDict, @"ios_header")) {
                [Utility setThemeHeaderBg:[Utility colorWithHexString:[dm.colorDict objectForKey:@"ios_header"] alpha:1.0f]];
            }
            if (IS_NOT_NULL(dm.colorDict, @"ios_footer")) {
                [Utility setThemeFooterBg:[Utility colorWithHexString:[dm.colorDict objectForKey:@"ios_footer"] alpha:1.0f]];
            }
            if (IS_NOT_NULL(dm.colorDict, @"ios_theme")) {
                [Utility setThemeColor:[Utility colorWithHexString:[dm.colorDict objectForKey:@"ios_theme"] alpha:1.0f]];
            }
            if (IS_NOT_NULL(dm.colorDict, @"ios_btn_normal")) {
                [Utility setThemeButtonNormalColor:[Utility colorWithHexString:[dm.colorDict objectForKey:@"ios_btn_normal"] alpha:1.0f]];
            }
            if (IS_NOT_NULL(dm.colorDict, @"ios_btn_selected")) {
                [Utility setThemeButtonSelectedColor:[Utility colorWithHexString:[dm.colorDict objectForKey:@"ios_btn_selected"] alpha:1.0f]];
            }
            if (IS_NOT_NULL(dm.colorDict, @"ios_btn_disabled")) {
                [Utility setThemeButtonDisabledColor:[Utility colorWithHexString:[dm.colorDict objectForKey:@"ios_btn_disabled"] alpha:1.0f]];
            }
            if (IS_NOT_NULL(dm.colorDict, @"ios_btn_big_normalBg")) {
                [Utility setThemeBigButtonBg:[Utility colorWithHexString:[dm.colorDict objectForKey:@"ios_btn_big_normalBg"] alpha:1.0f]];
            }
            if (IS_NOT_NULL(dm.colorDict, @"ios_btn_big_normalFont")) {
                [Utility setThemeBigButtonFont:[Utility colorWithHexString:[dm.colorDict objectForKey:@"ios_btn_big_normalFont"] alpha:1.0f]];
            }
            if (IS_NOT_NULL(dm.colorDict, @"ios_color_splash_text")) {
                dm.splashTextColor = [Utility colorWithHexString:[dm.colorDict objectForKey:@"ios_color_splash_text"] alpha:1.0f];
                [[NSUserDefaults standardUserDefaults] setValue:[dm.colorDict objectForKey:@"ios_color_splash_text"] forKey:@"SPLASH_COLOR"];
            }
            if (IS_NOT_NULL(dm.colorDict, @"ios_color_home_section_header_bg")) {
                [Utility setThemeColorHorizontalViewBg:[Utility colorWithHexString:[dm.colorDict objectForKey:@"ios_color_home_section_header_bg"] alpha:1.0f]];
            }
            if (IS_NOT_NULL(dm.colorDict, @"ios_color_home_section_header_text")) {
                [Utility setThemeColorHorizontalViewFont:[Utility colorWithHexString:[dm.colorDict objectForKey:@"ios_color_home_section_header_text"] alpha:1.0f]];
            }
            [Utility setThemeBlueColor];
        }
#endif
    }
    [Utility setThemeBannerIndicatorNormalColor:nil];
    [Utility setThemeBannerIndicatorSelectedColor:nil];

    if (IS_NOT_NULL(object, @"image_data")) {
        NSMutableArray* bannersData = [Banner getAllBanners];
        [bannersData removeAllObjects];
        NSString* imageData = [object objectForKey:@"image_data"];
        NSArray *jsonObject = [NSJSONSerialization JSONObjectWithData:[imageData dataUsingEncoding:NSUTF8StringEncoding] options:0 error:NULL];
        RLOG(@"imageData=%@", imageData);
        for (id dict in jsonObject) {
            if ([dict isKindOfClass:[NSDictionary class]]) {
                if (IS_NOT_NULL(dict, @"img_url") && IS_NOT_NULL(dict, @"type") && IS_NOT_NULL(dict, @"id")) {
                    NSString* dict_img_url = [dict objectForKey:@"img_url"];
                    int dict_type = [[dict objectForKey:@"type"] intValue];
                    int dict_id = [[dict objectForKey:@"id"] intValue];
                    Banner* banner = [[Banner alloc] init];
                    banner.bannerUrl = dict_img_url;
                    banner.bannerType = dict_type;
                    banner.bannerId = dict_id;
                }
            }
        }
    }

    if (IS_NOT_NULL(object, @"id_layout_categories")) {
        dm.layoutIdCategoryView = [[object objectForKey:@"id_layout_categories"] intValue];
    }
    if (IS_NOT_NULL(object, @"id_layout_products")) {
        dm.layoutIdProductView = [[object objectForKey:@"id_layout_products"] intValue];
    }
#if TEST_FORCED_DISCOUNT_LAYOUT
    dm.layoutIdProductView = P_LAYOUT_DISCOUNT;
#endif
    [[LayoutManager sharedManager] readLayoutPlist];
    self.isParseDataLoaded = true;
}
- (void)loadParseDataDemo:(NSString*)merchantObjectId {
    //old code
    /*
     PFQuery *query = [PFQuery queryWithClassName:PClassAppData];
     [query whereKey:@"merchant_obj" equalTo:[PFObject objectWithoutDataWithClassName:PClassMerchantPluginData objectId:merchantObjectId]];
     [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
     if (error == nil){
     [self parseDataDemo:object];
     }
     else{
     PFQuery *query1 = [PFQuery queryWithClassName:PClassMerchantPluginData];
     [query1 getObjectInBackgroundWithId:merchantObjectId block:^(PFObject * _Nullable object1, NSError * _Nullable error) {
     if (error == nil){
     [self parseDataDemo:object1];
     } else {
     RLOG(@"%@", error);
     [MRProgressOverlayView dismissAllOverlaysForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
     UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:Localize(@"i_error") message:Localize(@"generic_error") delegate:nil cancelButtonTitle:Localize(@"i_ok") otherButtonTitles:nil];
     [alertView show];
     }
     }];
     }
     }];
     */

    //new code
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                RLOG(@" Hello : %@", merchantObjectId);
                PFQuery *query1 = [PFQuery queryWithClassName:PClassMerchantPluginData];

                [query1 getObjectInBackgroundWithId:merchantObjectId block:^(PFObject * _Nullable object1, NSError * _Nullable error) {
                    if (error == nil){
                        [self parseDataDemo:object1];
                    } else {
                        RLOG(@"%@", error);
                        [MRProgressOverlayView dismissAllOverlaysForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
                        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:Localize(@"i_error") message:Localize(@"generic_error") delegate:nil cancelButtonTitle:Localize(@"i_ok") otherButtonTitles:nil];
                        [alertView show];
                    }
                }];


    });
}
- (void)loadAllPlatformData:(void(^)(void))success
                    failure:(void(^)(NSString* error))failure
                 markerInfo:(GMSMarker*)marker{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        PFQuery *query = [PFQuery queryWithClassName:PClassAppData];

        if ([Utility isNearBySearch] && marker != nil) {
            PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:marker.position.latitude longitude:marker.position.longitude];
            [query whereKey:@"store_location" nearGeoPoint:geoPoint withinKilometers:NEAR_BY_STORES_IN_KM];
        }

        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            if (objects && [objects isKindOfClass:[NSArray class]]) {
                BOOL nearBySearch = (marker!= nil);
                if (!nearBySearch) {
                    self.appDataRows = objects;
                }
                [self parseStoreConfig:objects :nearBySearch];
                success();
            } else {
                [MRProgressOverlayView dismissAllOverlaysForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
                UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:Localize(@"i_error") message:Localize(@"generic_error") delegate:nil cancelButtonTitle:Localize(@"i_ok") otherButtonTitles:nil];
                [alertView show];
            }
        }];
    });
}

- (void)loadParseData {
    if ([Utility isMultiStoreApp]) {
        NSArray* objects = self.appDataRows;
        if (objects) {
            for (PFObject* object in objects) {
                NSString* key = @"multi_store_platform";
                if ([Utility isMultiStoreAppTMStore]) {
                    key = @"platform";
                }
                if (object && [object objectForKey:key] &&
                    [[[object objectForKey:key] lowercaseString] isEqualToString:[[[DataManager sharedManager] appDataPlatformString] lowercaseString]]) {
                    [self parseAppDataRow:object error:nil];
                    return;
                }
            }
        }
        [MRProgressOverlayView dismissAllOverlaysForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:Localize(@"i_error") message:Localize(@"generic_error") delegate:nil cancelButtonTitle:Localize(@"i_ok") otherButtonTitles:nil];
        [alertView show];
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            PFQuery *query = [PFQuery queryWithClassName:PClassAppData];
            [query whereKey:@"platform" equalTo:[[DataManager sharedManager] appDataPlatformString]];
            [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                [self parseAppDataRow:object error:error];
            }];
        });
    }
}
- (void)parseAppDataRow:(PFObject*)object error:(NSError*)error {
    if (!object) {
        RLOG(@"The getFirstObject request failed.");
        RLOG(@"%@", error);
        [MRProgressOverlayView dismissAllOverlaysForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:Localize(@"i_error") message:Localize(@"generic_error") delegate:nil cancelButtonTitle:Localize(@"i_ok") otherButtonTitles:nil];
        [alertView show];
    } else {
        // The find succeeded.
        RLOG(@"Successfully retrieved the object.");
        RLOG(@"%@", object);
        self.isParseDataLoadedWithError = true;
        NSString* strBaseURL = [object objectForKey:@"baseurl"];
        NSString* strOauthConsumerKey = [object objectForKey:@"oauth_consumer_key"];
        NSString* strOauthConsumerSecret = [object objectForKey:@"oauth_consumer_secret"];
        NSString* strStoreName = [object objectForKey:@"dataHost"];
        if (strStoreName == nil || (strStoreName && [strStoreName isEqualToString:@""])) {
            strStoreName = @"woocommerce";
        }
        NSString* strStoreVersion = [object objectForKey:@"api_version_string"];
        if (strStoreVersion == nil || (strStoreVersion && [strStoreVersion isEqualToString:@""])) {
            strStoreVersion = @"v3";
        }
        NSString* strStoreContactUs = [object objectForKey:@"about_url"];
        NSString* strStoreAboutUs = PAGE_TERMS_AND_CONDITION;//[object objectForKey:@"about_url"];


        DataManager* dm = [DataManager sharedManager];
        if (dm.appType == APP_TYPE_DEMO) {
            strBaseURL = [object objectForKey:@"site_url"];
            strOauthConsumerKey = [object objectForKey:@"wc_api_key"];
            strOauthConsumerSecret = [object objectForKey:@"wc_api_secret"];
        }
        Addons* addons = [Addons sharedManager];
        [addons.shippingConfigs removeAllObjects];
        ShippingConfigWooCommerce* config = [ShippingConfigWooCommerce getInstance];
        [addons.shippingConfigs addObject:config];

        if (IS_NOT_NULL(object, @"addons")) {
            NSString* addonsStr = [object objectForKey:@"addons"];
#if ENABLE_DEBUGGING && ENABLE_TEST_MULTIVENDOR
            addonsStr = @"{\"config\":{\"show_non_variation_attribute\":\"true\",\"show_ios_style_sub_categories\":true,\"show_min_max_price\":true,\"auto_select_variation\":false,\"show_mobile_number_in_signup\":false,\"require_mobile_number_in_signup\":false,\"enable_otp_in_cod_payment\":true,\"product_details_config\":{\"show_opinion_section\":true,\"show_full_share_section\":false,\"extra_attributes_layout_type\":\"vertical\"},\"enable_opinions\":true,\"enable_webview_payment\":false,\"show_cart_with_product\":false,\"show_wordpress_menu\":false,\"wordpress_menu_ids\":[9,8],\"enable_zero_price_order\":false,\"hide_product_price_tag\":false,\"enable_product_ratings\":true,\"enable_product_reviews\":true,\"excluded_addresses\":[\"billing_country\",\"shipping_country\"],\"optional_addresses\":[\"billing_country\",\"shipping_country\"],\"home_menu_items\":[0,4,1,2,3],\"product_menu_items\":[0,4,1,2,3],\"drawer_items\":[{\"id\":0},{\"id\":10},{\"id\":12},{\"id\":1},{\"id\":2},{\"id\":3},{\"id\":22},{\"id\":33},{\"id\":9},{\"id\":4},{\"id\":43,\"name\":\"Share App\"},{\"id\":6},{\"id\":5},{\"id\":7},{\"id\":57,\"name\":\"PRIVACY POLICY\",\"data\":\"http://www.pearlkraft.in/privacy-policy/\"},{\"id\":58,\"name\":\"TERMS AND CONDITIONS\",\"data\":\"https://www.pearlkraft.in/terms-and-conditions/\"},{\"id\":13}]},\"apps\":[{\"app_name\":\"multivendor\",\"plugin\":\"dokan\",\"enabled\":true,\"screen\":\"products\",\"pos\":1,\"title\":\"Multivendor\"},{\"app_name\":\"Freshchat\",\"enabled\":true,\"app_id\":\"23afc958-0e0f-4459-82eb-f6ce4a61b786\",\"app_key\":\"3ae0f0e4-52f5-4965-be40-f5a40618c516\",\"pos\":1,\"title\":\"Freshchat\",\"push_type\":\"fcm\"}],\"payments\":[{\"gateway\":\"PayUMoney\",\"merchant_key\":\"rImEcpGK\",\"salt\":\"YtaUSiWFLP\",\"surl\":\"https://www.pearlkraft.in/my-account/\",\"furl\":\"https://www.pearlkraft.in\",\"service_provider\":\"payu_paisa\",\"enabled\":true,\"version\":2,\"hurl\":\"\",\"merchant_id\":\"5587282\"}]}";
#endif
#if ENABLE_DEBUGGING && TEST_PAYSTACK
            addonsStr = @"{\"payments\":[{\"gateway\":\"paystack\",\"publicKey\":\"pk_live_983a5778515eb60afc530a94cdc178a7f4edba10\",\"secretKey\":\"sk_live_e4bcc78077cc04d4dd1c4da786353a24ecc6152f\",\"title\":\"Paystack\",\"enabled\":\"true\",\"default_gateway\":\"true\"}]}";
#endif

            NSError *jsonError;
            NSData *objectData = [addonsStr dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData options:NSJSONReadingMutableContainers error:&jsonError];
            [self loadAddons:json];
        }



        dm.tmDataDoctor = [TMDataDoctor initWithParameter:strStoreName storeVersion:strStoreVersion baseUrl:strBaseURL consumerKey:strOauthConsumerKey consumerSecretKey:strOauthConsumerSecret pagelinkContactus:strStoreContactUs pagelinkAboutus:strStoreAboutUs];
        [dm.shippingEngines removeAllObjects];
        for (NSObject* obj in [[Addons sharedManager] shippingConfigs]) {
            if ([obj isKindOfClass:[ShippingConfigWooCommerce class]]) {
                ShippingConfigWooCommerce* config = (ShippingConfigWooCommerce*)obj;
                if (config.cIsEnabled) {
                    config.cBaseUrl = strBaseURL;
                    [dm.shippingEngines addObject:[[ShippingWooCommerce alloc] init:config.cBaseUrl]];
                }
            }
            else if ([obj isKindOfClass:[ShippingConfigRajaongkir class]]) {
                ShippingConfigRajaongkir* config = (ShippingConfigRajaongkir*)obj;
                if (config.cIsEnabled) {
                    config.cBaseUrl = strBaseURL;
                    [dm.shippingEngines addObject:[[ShippingRajaongkir alloc] init:config.cBaseUrl keyRajaongkir:config.cKey]];
                }
            }
        }


        if (IS_NOT_NULL(object, @"enableCoupons")) {
            dm.enable_coupons = true;//[[object objectForKey:@"enableCoupons"] boolValue];
        }


        if (IS_NOT_NULL(object, @"homeConfigUltimate")) {
            NSString* homeConfigUltimate = [object objectForKey:@"homeConfigUltimate"];
            if (![homeConfigUltimate isEqualToString:@""]) {
                Addons* addons1 = [Addons sharedManager];
                addons1.isDynamicLayoutEnable = true;
                [self writeStringToFile:homeConfigUltimate];
            }
        }
        if (IS_NOT_NULL(object, @"fb_appid")) {
            dm.keyFacebookAppId = [object objectForKey:@"fb_appid"];
        }
        if (IS_NOT_NULL(object, @"fb_secret")) {
            dm.keyFacebookConsumerSecret = [object objectForKey:@"fb_secret"];
        }
        if (IS_NOT_NULL(object, @"twitter_key")) {
            dm.keyTwitterConsumerKey = [object objectForKey:@"twitter_key"];
        }
        if (IS_NOT_NULL(object, @"twitter_secret")) {
            dm.keyTwitterConsumerSecret = [object objectForKey:@"twitter_secret"];
        }
        if (IS_NOT_NULL(object, @"google_key")) {
            dm.keyGoogleClientId = [object objectForKey:@"google_key"];
        }
        if (IS_NOT_NULL(object, @"google_secret")) {
            dm.keyGoogleClientSecret = [object objectForKey:@"google_secret"];
        }
        if (IS_NOT_NULL(object, @"enable_filters")) {
            dm.enable_filters = [[object objectForKey:@"enable_filters"] boolValue];
#if ENABLE_DEBUGGING && ENABLE_TEST_FILTER
            dm.enable_filters = true;
#endif
        }
        if (IS_NOT_NULL(object, @"show_tmstore_text")) {
            dm.show_tmstore_text = [[object objectForKey:@"show_tmstore_text"] boolValue];
        }
        if (IS_NOT_NULL(object, @"promo_img_url")) {
            dm.promoUrlImgPath = [object objectForKey:@"promo_img_url"];
        }
        if (IS_NOT_NULL(object, @"promo_url")) {
            dm.promoUrlString = [object objectForKey:@"promo_url"];
        }
        if (IS_NOT_NULL(object, @"enable_promo_button")) {
            dm.promoEnable = [[object objectForKey:@"enable_promo_button"] boolValue];
        }
        if (IS_NOT_NULL(object, @"showFullsizeCategoryBanner")) {
            dm.showFullSizeCategoryBanner = [[object objectForKey:@"showFullsizeCategoryBanner"] boolValue];
        }
        if (IS_NOT_NULL(object, @"service_active")) {
            int appType = [[object objectForKey:@"service_active"] intValue];
            if (dm.appType != APP_TYPE_DEMO) {
                dm.appType = appType;
            }
        }
        if (IS_NOT_NULL(object, @"max_categories_query_count_limit")) {
            dm.maxCategoryLoadCount = [[object objectForKey:@"max_categories_query_count_limit"] intValue];
        }
        if (IS_NOT_NULL(object, @"max_products_query_count_limit")) {
            dm.maxProductLoadCount = [[object objectForKey:@"max_products_query_count_limit"] intValue];
        }
        if (IS_NOT_NULL(object, @"min_app_version")) {
            dm.min_app_version = [object objectForKey:@"min_app_version"];
        }
        if (IS_NOT_NULL(object, @"current_app_version")) {
            dm.current_app_version = [object objectForKey:@"current_app_version"];
        }
        if (IS_NOT_NULL(object, @"refine_categories")) {
            dm.isRefineCategoriesEnable = [[object objectForKey:@"refine_categories"] boolValue];
        }
        if (IS_NOT_NULL(object, @"auto_refresh_thumbs")) {
            dm.isAutoRefreshCategoryThumbEnable = [[object objectForKey:@"auto_refresh_thumbs"] boolValue];
        }
        if (IS_NOT_NULL(object, @"stepup_single_child_categories")) {
            dm.isStepUpSingleChildrenCategoriesEnable = [[object objectForKey:@"stepup_single_child_categories"] boolValue];
        }
        if (IS_NOT_NULL(object, @"auto_signin_in_hidden_webview")) {
            dm.isAutoSigninInHiddenWebviewEnable = [[object objectForKey:@"auto_signin_in_hidden_webview"] boolValue];
        }
        if (IS_NOT_NULL(object, @"thousand_separator")) {
            dm.thousandSeperator = [object objectForKey:@"thousand_separator"];
        }
        //        if (IS_NOT_NULL(object, @"decimal_separator")) {
        //            dm.decimalSeperator = [object objectForKey:@"decimal_separator"];//not implemented in parse
        //        }
        if (IS_NOT_NULL(object, @"merchant_id")) {
            dm.merchantObjectId = [object objectForKey:@"merchant_id"];
        }

#if (ENABLE_FULL_SPLASH_ON_LAUNCH_NEW == 0)
        if (IS_NOT_NULL(object, @"splash_url")) {
            dm.splashUrlImgPath = [object objectForKey:@"splash_url"];
            [[NSUserDefaults standardUserDefaults] setValue:dm.splashUrlImgPath forKey:@"SPLASH_IMG"];
        } else {
            dm.splashUrlImgPath = @"";
            [[NSUserDefaults standardUserDefaults] setValue:dm.splashUrlImgPath forKey:@"SPLASH_IMG"];
        }
        if (IS_NOT_NULL(object, @"splash_data")) {
            NSString* splashData = [object objectForKey:@"splash_data"];
            NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:[splashData dataUsingEncoding:NSUTF8StringEncoding] options:0 error:NULL];
            if([[MyDevice sharedManager] isIphone]) {
                float screenRatio = [[MyDevice sharedManager] screenHeightInPortrait]/[[MyDevice sharedManager] screenWidthInPortrait];
                if (screenRatio > 1.5f) {
                    dm.splashUrlImgPathPortrait = [jsonObject objectForKey:@"ios_1920_1080"];
                    [Utility setImage:[[UIImageView alloc] init] url:dm.splashUrlImgPathPortrait resizeType:0 isLocal:false highPriority:true];
                } else {
                    dm.splashUrlImgPathPortrait = [jsonObject objectForKey:@"ios_960_640"];
                    [Utility setImage:[[UIImageView alloc] init] url:dm.splashUrlImgPathPortrait resizeType:0 isLocal:false highPriority:true];
                }
                [[NSUserDefaults standardUserDefaults] setValue:dm.splashUrlImgPathPortrait forKey:@"SPLASH_IMG_PORTRAIT"];
            } else {
                dm.splashUrlImgPathPortrait = [jsonObject objectForKey:@"ios_1024_768"];
                dm.splashUrlImgPathLandscape = [jsonObject objectForKey:@"ios_768_1024"];
                [Utility setImage:[[UIImageView alloc] init] url:dm.splashUrlImgPathPortrait resizeType:0 isLocal:false highPriority:true];
                [Utility setImage:[[UIImageView alloc] init] url:dm.splashUrlImgPathLandscape resizeType:0 isLocal:false highPriority:true];
                [[NSUserDefaults standardUserDefaults] setValue:dm.splashUrlImgPathPortrait forKey:@"SPLASH_IMG_PORTRAIT"];
                [[NSUserDefaults standardUserDefaults] setValue:dm.splashUrlImgPathLandscape forKey:@"SPLASH_IMG_LANDSCAPE"];
            }
        }
        else {
            [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"SPLASH_IMG_PORTRAIT"];
            [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"SPLASH_IMG_LANDSCAPE"];
        }
#endif

        NSString* appColor = @"app_color";
        if (dm.appType == APP_TYPE_DEMO) {
            appColor = @"ios_app_color";
        }
        if (IS_NOT_NULL(object, appColor)) {
            NSData *data = [[object objectForKey:appColor] dataUsingEncoding:NSUTF8StringEncoding];
            dm.colorDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            RLOG(@"dm.colorDict = %@",  dm.colorDict);
#if ENABLE_UI_COLOR_FORM_SERVER
            {
                if (IS_NOT_NULL(dm.colorDict, @"ios_header")) {
                    [Utility setThemeHeaderBg:[Utility colorWithHexString:[dm.colorDict objectForKey:@"ios_header"] alpha:1.0f]];
                }
                if (IS_NOT_NULL(dm.colorDict, @"ios_footer")) {
                    [Utility setThemeFooterBg:[Utility colorWithHexString:[dm.colorDict objectForKey:@"ios_footer"] alpha:1.0f]];
                }
                if (IS_NOT_NULL(dm.colorDict, @"ios_theme")) {
                    [Utility setThemeColor:[Utility colorWithHexString:[dm.colorDict objectForKey:@"ios_theme"] alpha:1.0f]];
                }
                if (IS_NOT_NULL(dm.colorDict, @"ios_btn_normal")) {
                    [Utility setThemeButtonNormalColor:[Utility colorWithHexString:[dm.colorDict objectForKey:@"ios_btn_normal"] alpha:1.0f]];
                }
                if (IS_NOT_NULL(dm.colorDict, @"ios_btn_selected")) {
                    [Utility setThemeButtonSelectedColor:[Utility colorWithHexString:[dm.colorDict objectForKey:@"ios_btn_selected"] alpha:1.0f]];
                }
                if (IS_NOT_NULL(dm.colorDict, @"ios_btn_disabled")) {
                    [Utility setThemeButtonDisabledColor:[Utility colorWithHexString:[dm.colorDict objectForKey:@"ios_btn_disabled"] alpha:1.0f]];
                }
                if (IS_NOT_NULL(dm.colorDict, @"ios_btn_big_normalBg")) {
                    [Utility setThemeBigButtonBg:[Utility colorWithHexString:[dm.colorDict objectForKey:@"ios_btn_big_normalBg"] alpha:1.0f]];
                }
                if (IS_NOT_NULL(dm.colorDict, @"ios_btn_big_normalFont")) {
                    [Utility setThemeBigButtonFont:[Utility colorWithHexString:[dm.colorDict objectForKey:@"ios_btn_big_normalFont"] alpha:1.0f]];
                }
                if (IS_NOT_NULL(dm.colorDict, @"ios_color_splash_text")) {
                    dm.splashTextColor = [Utility colorWithHexString:[dm.colorDict objectForKey:@"ios_color_splash_text"] alpha:1.0f];
                    [[NSUserDefaults standardUserDefaults] setValue:[dm.colorDict objectForKey:@"ios_color_splash_text"] forKey:@"SPLASH_COLOR"];
                }

                if (IS_NOT_NULL(dm.colorDict, @"ios_color_home_section_header_bg")) {
                    [Utility setThemeColorHorizontalViewBg:[Utility colorWithHexString:[dm.colorDict objectForKey:@"ios_color_home_section_header_bg"] alpha:1.0f]];
                }
                if (IS_NOT_NULL(dm.colorDict, @"ios_color_home_section_header_text")) {
                    [Utility setThemeColorHorizontalViewFont:[Utility colorWithHexString:[dm.colorDict objectForKey:@"ios_color_home_section_header_text"] alpha:1.0f]];
                }
                [Utility setThemeBlueColor];

            }
#endif
        }



        [Utility setThemeBannerIndicatorNormalColor:nil];
        [Utility setThemeBannerIndicatorSelectedColor:nil];

        if (IS_NOT_NULL(object, @"image_data")) {
            NSMutableArray* bannersData = [Banner getAllBanners];
            [bannersData removeAllObjects];
            NSString* imageData = [object objectForKey:@"image_data"];
            NSArray *jsonObject = [NSJSONSerialization JSONObjectWithData:[imageData dataUsingEncoding:NSUTF8StringEncoding] options:0 error:NULL];
            RLOG(@"imageData=%@", imageData);
            for (NSDictionary* dict in jsonObject) {
                NSString* dict_img_url = [dict objectForKey:@"img_url"];
                int dict_type = [[dict objectForKey:@"type"] intValue];
                int dict_id = [[dict objectForKey:@"id"] intValue];
                Banner* banner = [[Banner alloc] init];
                banner.bannerUrl = dict_img_url;
                banner.bannerType = dict_type;
                banner.bannerId = dict_id;
                [Utility setImage:[[UIImageView alloc] init] url:dict_img_url resizeType:0 isLocal:false highPriority:true];
            }
        }
        //            //paypal
        //            if (IS_NOT_NULL(object, @"paypal_merchant_id")) {
        //                PayPalConfig* config = [PayPalConfig sharedManager];
        //                if ([config.cPayPalClientId isEqualToString:@""]) {
        //                    config.cPayPalClientId = [object objectForKey:@"paypal_merchant_id"];
        //                    config.cIsEnabled = true;
        //                }
        //            }
        //            //payu money
        //            if (IS_NOT_NULL(object, @"payumoney_merchantkey")) {
        //                PayuConfig* config = [PayuConfig sharedManager];
        //                if ([config.cPayuMerchantKey isEqualToString:@""]) {
        //                    config.cPayuMerchantKey = [object objectForKey:@"payumoney_merchantkey"];
        //                    config.cIsEnabled = true;
        //                    if (IS_NOT_NULL(object, @"payumoney_salt")) {
        //                        config.cPayuSaltKey = [object objectForKey:@"payumoney_salt"];
        //                    }
        //                    if (IS_NOT_NULL(object, @"payumoney_surl")) {
        //                        config.cSuccessUrl = [object objectForKey:@"payumoney_surl"];
        //                    }
        //                    if (IS_NOT_NULL(object, @"payumoney_furl")) {
        //                        config.cFailureUrl = [object objectForKey:@"payumoney_furl"];
        //                    }
        //                    if (IS_NOT_NULL(object, @"payumoney_serviceprovider")) {
        //                        config.cServiceProvider = [object objectForKey:@"payumoney_serviceprovider"];
        //                    }
        //                }
        //            }

        if (IS_NOT_NULL(object, @"id_layout_categories")) {
            dm.layoutIdCategoryView = [[object objectForKey:@"id_layout_categories"] intValue];
        }
        if (IS_NOT_NULL(object, @"id_layout_products")) {
            dm.layoutIdProductView = [[object objectForKey:@"id_layout_products"] intValue];
        }

#if TEST_FORCED_DISCOUNT_LAYOUT
        dm.layoutIdProductView = P_LAYOUT_DISCOUNT;
#endif
        if(IS_NOT_NULL(object, @"contactDetail")){
            NSString *jsonString = [object objectForKey:@"contactDetail"];
            NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if ([json isKindOfClass:[NSDictionary class]]) {
                dm.contactDetails = json;
            }
        }


        if (dm.appType == APP_TYPE_INACTIVE) {
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Service is inactive." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                [self exitApp];
            }];
        } else {
            dm.isUpdateInfoLoaded = true;
#if (ENABLE_UPDATE_CHECK == 0)
            self.isParseDataLoaded = true;
#else
            dm.isForceUpdateNeeded = [self isAppNeedUpdate:dm.min_app_version];
            dm.isUpdateNeeded = [self isAppNeedUpdate:dm.current_app_version];
            if (dm.isUpdateNeeded) {
                //                if ([[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"CCVV%@VVCC", dm.current_app_version]]) {
                //                    dm.isUpdateNeeded = false;
                //                } else {
                //                    [[NSUserDefaults standardUserDefaults] setBool:true forKey:[NSString stringWithFormat:@"CCVV%@VVCC", dm.current_app_version]];
                //                }
                NSDate* currentDate = [NSDate date];
                NSDate* savedDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"AFUT"];
                if (savedDate == nil) {
                    [[NSUserDefaults standardUserDefaults] setObject:currentDate forKey:@"AFUT"];
                } else {
                    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
                    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:savedDate toDate:currentDate options:0];
                    int numberOfDays = (int)components.day + (int)components.month * 30 + (int)components.year * 365;
                    if (numberOfDays < UPDATE_CHECK_LATER_DAYS) {
                        dm.isUpdateNeeded = false;
                    } else {
                        [[NSUserDefaults standardUserDefaults] setObject:currentDate forKey:@"AFUT"];
                    }
                }
            }

            NSString* stringAppDisplayName = Localize(@"app_display_name");
            if ([stringAppDisplayName isEqualToString:@""] || [stringAppDisplayName isEqualToString:@"app_display_name"]) {
                stringAppDisplayName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
            }
            NSString* appName = stringAppDisplayName;
            if (dm.isForceUpdateNeeded) {
                UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:appName
                                                                    message:@"New Update is available."
                                                                   delegate:nil
                                                          cancelButtonTitle:@"Update"
                                                          otherButtonTitles:nil];
                [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    [self gotoAppUpdatePage];
                    [self exitApp];
                }];
            }
            else if (dm.isUpdateNeeded) {
                UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:appName
                                                                    message:@"New Update is available."
                                                                   delegate:nil
                                                          cancelButtonTitle:@"Later"
                                                          otherButtonTitles:@"Update", nil];
                [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    if (buttonIndex == 0) {
                        self.isParseDataLoaded = true;
                    } else {
                        [self gotoAppUpdatePage];
                        [self exitApp];
                    }

                }];
            }
            else {
                self.isParseDataLoaded = true;
            }
#endif
        }
        [[LayoutManager sharedManager] readLayoutPlist];
    }
}
- (void)exitApp {
    //home button press programmatically
    UIApplication *app = [UIApplication sharedApplication];
    [app performSelector:@selector(suspend)];

    //wait 2 seconds while app is going background
    [NSThread sleepForTimeInterval:2.0];

    //exit app when app is in background
    exit(0);
}
- (void)gotoAppUpdatePage {
    NSString* appId = MY_APPID;
    NSString * iOS7AppStoreURLFormat = @"itms-apps://itunes.apple.com/app/id%@";
    NSString * iOSAppStoreURLFormat = @"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:([[UIDevice currentDevice].systemVersion floatValue] >= 7.0f)? iOS7AppStoreURLFormat: iOSAppStoreURLFormat, appId]]];
}
- (BOOL)isAppNeedUpdate:(NSString*)serverVersion {
    BOOL needUpdate = false;
    if ([serverVersion isEqualToString:@""]) {
        return needUpdate;
    }
    NSString* appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSArray* appVersionArray = [appVersion componentsSeparatedByString: @"."];
    NSArray* serverVersionArray = [serverVersion componentsSeparatedByString: @"."];
    for (int digit = 0; digit < 5; digit++) {
        if ([appVersionArray count] > digit && [serverVersionArray count] > digit) {
            int avDigit = [appVersionArray[digit] intValue];
            int svDigit = [serverVersionArray[digit] intValue];
            if (avDigit < svDigit) {
                needUpdate = true;
                return needUpdate;
            }
        }
    }
    return needUpdate;
}
- (void)parseConsentDialogScreen:(NSDictionary*)dict {
    if (dict && [dict isKindOfClass:[NSDictionary class]]) {
        ConsentScreenConfig* csConfig = [ConsentScreenConfig sharedInstance];
        if (IS_NOT_NULL(dict, @"enabled")) {
            csConfig.enabled = GET_VALUE_BOOL(dict, @"enabled");
        }
        if (IS_NOT_NULL(dict, @"show_always")) {
            csConfig.show_always = GET_VALUE_BOOL(dict, @"show_always");
        }
        if (IS_NOT_NULL(dict, @"layout")) {
            NSArray* array = GET_VALUE_OBJECT(dict, @"layout");
            if (array && [array isKindOfClass:[NSArray class]]) {
                for (NSDictionary* tempDict in array) {
                    ConsentScreenLayout* layout = [[ConsentScreenLayout alloc] init];
                    [csConfig.layout addObject:layout];
                    if (IS_NOT_NULL(tempDict, @"view")) {
                        NSString* viewStr = GET_VALUE_OBJECT(tempDict, @"view");
                        if (viewStr && [viewStr isKindOfClass:[NSString class]]) {
                            if ([[viewStr lowercaseString] isEqualToString:@"text"]) {
                                layout.viewType = CS_VIEW_TYPE_TEXT;
                            } else if ([[viewStr lowercaseString] isEqualToString:@"image"]) {
                                layout.viewType = CS_VIEW_TYPE_IMAGE;
                            }
                        }
                    }
                    if (IS_NOT_NULL(tempDict, @"type")) {
                        NSString* typeStr = GET_VALUE_OBJECT(tempDict, @"type");
                        if (typeStr && [typeStr isKindOfClass:[NSString class]]) {
                            if ([[typeStr lowercaseString] isEqualToString:@"header"]) {
                                layout.viewSubType = CS_VIEW_SUB_TYPE_HEADER;
                            } else if ([[typeStr lowercaseString] isEqualToString:@"normal"]) {
                                layout.viewSubType = CS_VIEW_SUB_TYPE_NORMAL;
                            }
                        }
                    }
                    if (IS_NOT_NULL(tempDict, @"content")) {
                        NSString* contentStr = GET_VALUE_OBJECT(tempDict, @"content");
                        if (contentStr && [contentStr isKindOfClass:[NSString class]]) {
                            layout.contentString = contentStr;
                        }
                    }
                }
                ConsentScreenLayout* layout = [[ConsentScreenLayout alloc] init];
                [csConfig.layout addObject:layout];
                layout.viewType = CS_VIEW_TYPE_BUTTON;
                layout.contentString = Localize(@"button_continue");
            }
        }
    }
}
- (void)loadAddons:(NSDictionary*)dict {
    Addons* addons = [Addons sharedManager];

    if (IS_NOT_NULL(dict, @"config")) {
        addons.config = GET_VALUE_OBJECT(dict, @"config");
    }
    if (addons.config) {
        if ((IS_NOT_NULL(addons.config, @"consent_dialog"))) {
            NSDictionary* consent_dialog = GET_VALUE_OBJ(addons.config, @"consent_dialog");
            [self parseConsentDialogScreen:consent_dialog];
        }
        if ((IS_NOT_NULL(addons.config, @"is_vat_exempt"))) {
            addons.is_vat_exempt = GET_VALUE_BOOL(addons.config, @"is_vat_exempt");
        }
        if ((IS_NOT_NULL(addons.config, @"order_again"))) {
            addons.order_again = GET_VALUE_BOOL(addons.config, @"order_again");
        }
        if ((IS_NOT_NULL(addons.config, @"enable_mixmatch_products"))) {
            addons.enable_mixmatch_products = GET_VALUE_BOOL(addons.config, @"enable_mixmatch_products");
        }
        if ((IS_NOT_NULL(addons.config, @"enable_bundled_products"))) {
            addons.enable_bundled_products = GET_VALUE_BOOL(addons.config, @"enable_bundled_products");
        }
#if ENABLE_DEBUGGING
        //addons.enable_bundled_products = true;
#endif
        if ((IS_NOT_NULL(addons.config, @"hide_price"))) {
            addons.hide_price = GET_VALUE_BOOL(addons.config, @"hide_price");
        }
        if ((IS_NOT_NULL(addons.config, @"show_keep_shopping_in_cart"))) {
            addons.show_keep_shopping_in_cart = GET_VALUE_BOOL(addons.config, @"show_keep_shopping_in_cart");
        }
        if (IS_NOT_NULL(addons.config, @"product_details_config")) {
            [self parseAndLoadProductDetailsConfig:GET_VALUE_OBJECT(addons.config, @"product_details_config")];
        }
        if (IS_NOT_NULL(addons.config, @"guest_config")) {
            [self parseAndLoadGuestConfig:GET_VALUE_OBJECT(addons.config, @"guest_config")];
        }
        if (IS_NOT_NULL(addons.config, @"show_child_cat_products_in_parent_cat")) {
            addons.show_child_cat_products_in_parent_cat = GET_VALUE_BOOL(addons.config, @"show_child_cat_products_in_parent_cat");
        }
        if (IS_NOT_NULL(addons.config, @"show_cart_with_product")) {
            addons.show_cart_with_product = GET_VALUE_BOOL(addons.config, @"show_cart_with_product");
        }

#if TEST_SHOW_CART_WITH_PRODUCTS
        addons.show_cart_with_product = true;
#endif
        if (IS_NOT_NULL(addons.config, @"show_wordpress_menu")) {
            addons.show_wordpress_menu = GET_VALUE_BOOL(addons.config, @"show_wordpress_menu");
        }
        if (IS_NOT_NULL(addons.config, @"enable_opinions")) {
            addons.enable_opinions = GET_VALUE_BOOL(addons.config, @"enable_opinions");
        }
        if (IS_NOT_NULL(addons.config, @"enable_zero_price_order")) {
            addons.enable_zero_price_order = GET_VALUE_BOOL(addons.config, @"enable_zero_price_order");
        }
        if (IS_NOT_NULL(addons.config, @"hide_product_price_tag")) {
            addons.hide_product_price_tag = GET_VALUE_BOOL(addons.config, @"hide_product_price_tag");
        }
        if (IS_NOT_NULL(addons.config, @"enable_product_ratings")) {
            addons.enable_product_ratings = GET_VALUE_BOOL(addons.config, @"enable_product_ratings");
        }
        if (IS_NOT_NULL(addons.config, @"enable_product_reviews")) {
            addons.enable_product_reviews = GET_VALUE_BOOL(addons.config, @"enable_product_reviews");
        }
        if (IS_NOT_NULL(addons.config, @"show_crosssell_products")) {
            addons.show_crosssell_products = GET_VALUE_BOOL(addons.config, @"show_crosssell_products");
        }
        if (IS_NOT_NULL(addons.config, @"required_password_strength")) {
            addons.required_password_strength = GET_VALUE_INT(addons.config, @"required_password_strength");
        }
        if (IS_NOT_NULL(addons.config, @"wordpress_menu_ids")) {
            addons.wordpress_menu_ids = [[NSMutableArray alloc] initWithArray:GET_VALUE_OBJECT(addons.config, @"wordpress_menu_ids")];
        }
        if (IS_NOT_NULL(addons.config, @"home_menu_items")) {
            addons.home_menu_items = [[NSMutableArray alloc] initWithArray:GET_VALUE_OBJECT(addons.config, @"home_menu_items")];
        }
        if (IS_NOT_NULL(addons.config, @"product_menu_items")) {
            addons.product_menu_items = [[NSMutableArray alloc] initWithArray:GET_VALUE_OBJECT(addons.config, @"product_menu_items")];
        }
        if (IS_NOT_NULL(addons.config, @"cancellable_login")) {
            addons.cancellable_login = GET_VALUE_BOOL(addons.config, @"cancellable_login");
        }
        if (IS_NOT_NULL(addons.config, @"show_login_at_start")) {
            addons.show_login_at_start = GET_VALUE_BOOL(addons.config, @"show_login_at_start");
        }
        if (IS_NOT_NULL(addons.config, @"show_billing_address")) {
            addons.show_billing_address = GET_VALUE_BOOL(addons.config, @"show_billing_address");
        }
        if (IS_NOT_NULL(addons.config, @"show_shipping_address")) {
            addons.show_shipping_address = GET_VALUE_BOOL(addons.config, @"show_shipping_address");
        }
        if (IS_NOT_NULL(addons.config, @"show_pickup_location")) {
            addons.show_pickup_location = GET_VALUE_BOOL(addons.config, @"show_pickup_location");
        }
        if (IS_NOT_NULL(addons.config, @"enable_special_order_note")) {
            addons.enable_special_order_note = GET_VALUE_BOOL(addons.config, @"enable_special_order_note");
        }
        if (IS_NOT_NULL(addons.config, @"show_category_banner")) {
            addons.show_category_banner = GET_VALUE_BOOL(addons.config, @"show_category_banner");
        }
        if (IS_NOT_NULL(addons.config, @"enable_webview_payment")) {
            addons.enable_webview_payment = GET_VALUE_BOOL(addons.config, @"enable_webview_payment");
        }
        if (IS_NOT_NULL(addons.config, @"show_filter_price_with_tax")) {
            addons.show_filter_price_with_tax = GET_VALUE_BOOL(addons.config, @"show_filter_price_with_tax");
        }
        if (IS_NOT_NULL(addons.config, @"show_mobile_number_in_signup")) {
            addons.show_mobile_number_in_signup = GET_VALUE_BOOL(addons.config, @"show_mobile_number_in_signup");
        }
        if (IS_NOT_NULL(addons.config, @"require_mobile_number_in_signup")) {
            addons.require_mobile_number_in_signup = GET_VALUE_BOOL(addons.config, @"require_mobile_number_in_signup");
        }
        if (IS_NOT_NULL(addons.config, @"show_home_page_banner")) {
            addons.show_home_page_banner = GET_VALUE_BOOL(addons.config, @"show_home_page_banner");
        }
#if TEST_OTP_LOGIN
        addons.show_mobile_number_in_signup = true;
        addons.require_mobile_number_in_signup = true;
#endif
        if (IS_NOT_NULL(addons.config, @"show_nested_category_menu")) {
            addons.show_nested_category_menu = GET_VALUE_BOOL(addons.config, @"show_nested_category_menu");
        }
#if TEST_SHOW_NESTED_CATEGORY_MENU_FALSE
        addons.show_nested_category_menu = false;
#endif

        if (IS_NOT_NULL(addons.config, @"show_reset_password")) {
            addons.show_reset_password = GET_VALUE_BOOL(addons.config, @"show_reset_password");
        }
#if ENABLE_CHECKOUT_MANAGER
        if (IS_NOT_NULL(addons.config, @"enable_multi_store_checkout")) {
            addons.enable_multi_store_checkout = GET_VALUE_BOOL(addons.config, @"enable_multi_store_checkout");
        }
#if TEST_CHECKOUT_MANAGER
        addons.enable_multi_store_checkout = true;
#endif
#endif



#if ENABLE_OTP_AT_CHECKOUT
        if (IS_NOT_NULL(addons.config, @"enable_otp_in_cod_payment")) {
            addons.enable_otp_in_cod_payment = GET_VALUE_BOOL(addons.config, @"enable_otp_in_cod_payment");
        }
#if TEST_OTP_AT_CHECKOUT
        addons.enable_otp_in_cod_payment = true;
#endif
#endif

#if ENABLE_USER_ROLE
        if (IS_NOT_NULL(addons.config, @"enable_role_price")) {
            addons.enable_role_price = GET_VALUE_BOOL(addons.config, @"enable_role_price");
        }
#if TEST_USER_ROLE
        addons.enable_role_price = true;
#endif
#endif

#if ENABLE_ADDRESS_WITH_MAP
        if (IS_NOT_NULL(addons.config, @"use_multiple_shipping_addresses")) {
            addons.use_multiple_shipping_addresses = GET_VALUE_BOOL(addons.config, @"use_multiple_shipping_addresses");
        }
#if TEST_ADDRESS_WITH_MAP
        addons.use_multiple_shipping_addresses = true;
#endif
#endif

        if (IS_NOT_NULL(addons.config, @"hide_shipping_info")) {
            addons.hide_shipping_info = GET_VALUE_BOOL(addons.config, @"hide_shipping_info");
        }

        if (IS_NOT_NULL(addons.config, @"remove_cart_or_wish_items")) {
            addons.remove_cart_or_wish_items = GET_VALUE_BOOL(addons.config, @"remove_cart_or_wish_items");
        }

#if ENABLE_SHOW_ALL_IMAGES
        if (IS_NOT_NULL(addons.config, @"show_all_images")) {
            addons.show_all_images = GET_VALUE_BOOL(addons.config, @"show_all_images");
        }
#if TEST_SHOW_ALL_IMAGES
        addons.show_all_images = false;
#endif
#endif

#if ENABLE_CURRENCY_SWITCHER
        if (IS_NOT_NULL(addons.config, @"enable_currency_switcher")) {
            addons.enable_currency_switcher = GET_VALUE_BOOL(addons.config, @"enable_currency_switcher");
        }
#if TEST_CURRENCY_SWITCHER
        addons.enable_currency_switcher = true;
#endif
#endif
        if (IS_NOT_NULL(addons.config, @"show_non_variation_attribute")) {
            addons.show_non_variation_attribute = GET_VALUE_BOOL(addons.config, @"show_non_variation_attribute");
        }
        
        if (IS_NOT_NULL(addons.config, @"use_plugin_for_pagging")) {
            addons.use_plugin_for_pagging = GET_VALUE_BOOL(addons.config, @"use_plugin_for_pagging");
        }

        if (IS_NOT_NULL(addons.config, @"enable_location_in_filters")) {
            addons.enable_location_in_filters = GET_VALUE_BOOL(addons.config, @"enable_location_in_filters");
        }
        
        if (IS_NOT_NULL(addons.config, @"resize_product_thumbs")) {
            addons.resize_product_thumbs = GET_VALUE_BOOL(addons.config, @"resize_product_thumbs");
        }
        
        if (IS_NOT_NULL(addons.config, @"resize_product_images")) {
            addons.resize_product_images = GET_VALUE_BOOL(addons.config, @"resize_product_images");
        }

        if (IS_NOT_NULL(addons.config, @"restricted_categories")) {
            addons.restricted_categories = [[NSMutableArray alloc] initWithArray:GET_VALUE_OBJECT(addons.config, @"restricted_categories")];
        }
#if (ENABLE_SELLER_ZONE && TEST_SELLER_ZONE)
#else
        if (IS_NOT_NULL(addons.config, @"drawer_items")) {
            NSMutableArray* tempArray = [[NSMutableArray alloc] initWithArray:GET_VALUE_OBJECT(addons.config, @"drawer_items")];
            [addons.drawer_items removeAllObjects];
            for (NSDictionary* tempDict in tempArray) {
                DrawerItem* d = [[DrawerItem alloc] init];
                if (IS_NOT_NULL(tempDict, @"id")) {
                    d.itemId = GET_VALUE_INT(tempDict, @"id");
                }
                if (IS_NOT_NULL(tempDict, @"name")) {
                    d.itemName = GET_VALUE_STRING(tempDict, @"name");
                }
                if (IS_NOT_NULL(tempDict, @"data")) {
                    d.itemData = GET_VALUE_OBJECT(tempDict, @"data");
                }
                if (IS_NOT_NULL(tempDict, @"children")) {
                    d.itemData = GET_VALUE_OBJECT(tempDict, @"children");
                }
                if (IS_NOT_NULL(tempDict, @"sort_order")) {
                    d.sortedCategoryArray = GET_VALUE_OBJECT(tempDict, @"sort_order");
                }
                if (IS_NOT_NULL(tempDict, @"icon_url")) {
                    d.sortedCategoryIconArray = GET_VALUE_OBJECT(tempDict, @"icon_url");
                }

                [addons.drawer_items addObject:d];
            }
        }
#endif

        if (IS_NOT_NULL(addons.config, @"profile_items")) {
            NSMutableArray* tempArray = [[NSMutableArray alloc] initWithArray:GET_VALUE_OBJECT(addons.config, @"profile_items")];
            [addons.profile_items removeAllObjects];
            for (NSDictionary* tempDict in tempArray) {
                DrawerItem* d = [[DrawerItem alloc] init];
                if (IS_NOT_NULL(tempDict, @"id")) {
                    d.itemId = GET_VALUE_INT(tempDict, @"id");
                }
                if (IS_NOT_NULL(tempDict, @"name")) {
                    d.itemName = GET_VALUE_STRING(tempDict, @"name");
                }
                if (IS_NOT_NULL(tempDict, @"data")) {
                    d.itemData = GET_VALUE_STRING(tempDict, @"data");
                }
                [addons.profile_items addObject:d];
            }
        }
        if (IS_NOT_NULL(addons.config, @"language")) {
            NSDictionary* tempDict = GET_VALUE_OBJECT(addons.config, @"language");
            if (IS_NOT_NULL(tempDict, @"version")) {
                addons.language.version = GET_VALUE_INT(tempDict, @"version");
            }
            if (IS_NOT_NULL(tempDict, @"locales")) {
                addons.language.locales = [[NSMutableArray alloc] initWithArray:GET_VALUE_OBJECT(tempDict, @"locales")];
                addons.language.isDownloaded = [[NSMutableArray alloc] init];
                for (NSString* str in addons.language.locales) {
                    [addons.language.isDownloaded addObject:[NSNumber numberWithBool:NO]];
                }
            }
            if (IS_NOT_NULL(tempDict, @"titles")) {
                addons.language.titles = [[NSMutableArray alloc] initWithArray:GET_VALUE_OBJECT(tempDict, @"titles")];
            }
            if (IS_NOT_NULL(tempDict, @"isRTLNeeded")) {
                addons.language.isRTLNeeded = [[NSMutableArray alloc] initWithArray:GET_VALUE_OBJECT(tempDict, @"isRTLNeeded")];
            }
            if (IS_NOT_NULL(tempDict, @"isLanguageKeyboardNeeded")) {
                addons.language.isLanguageKeyboardNeeded = GET_VALUE_BOOL(tempDict, @"isLanguageKeyboardNeeded");
            }
            if (IS_NOT_NULL(tempDict, @"defaultLocale")) {
                addons.language.defaultLocale = GET_VALUE_STRING(tempDict, @"defaultLocale");
                //                if (addons.language && addons.language.locales && (int)[addons.language.locales count] == 1) {
                //                    [[NSUserDefaults standardUserDefaults] setValue:addons.language.defaultLocale forKey:USER_LOCALE];
                //                    int tempCounter = 0;
                //
                //                    for (NSString* tempLocale in addons.language.locales) {
                //                        if ([[tempLocale lowercaseString] isEqualToString:[addons.language.defaultLocale lowercaseString]]) {
                //                            [[NSUserDefaults standardUserDefaults] setValue:addons.language.titles[tempCounter] forKey:USER_LOCAL_TITLE];
                //                            break;
                //                        }
                //                        tempCounter++;
                //                    }
                //                }

                if (addons.language && addons.language.locales) {
                    if ((int)[addons.language.locales count] == 1) {
                        [[NSUserDefaults standardUserDefaults] setValue:addons.language.defaultLocale forKey:USER_LOCALE];
                        if (addons.language.titles && [addons.language.titles count] > 0) {
                            [[NSUserDefaults standardUserDefaults] setValue:addons.language.titles[0] forKey:USER_LOCAL_TITLE];
                        }
                    } else {
                        int tempCounter = 0;
                        if ([[NSUserDefaults standardUserDefaults] valueForKey:USER_LOCALE] == nil || [[[NSUserDefaults standardUserDefaults] valueForKey:USER_LOCALE] isEqualToString:@""]) {
                            for (NSString* tempLocale in addons.language.locales) {
                                if ([[tempLocale lowercaseString] isEqualToString:[addons.language.defaultLocale lowercaseString]]) {
                                    [[NSUserDefaults standardUserDefaults] setValue:addons.language.titles[tempCounter] forKey:USER_LOCAL_TITLE];
                                    [[NSUserDefaults standardUserDefaults] setValue:addons.language.defaultLocale forKey:USER_LOCALE];
                                    break;
                                }
                                tempCounter++;
                            }
                        }
                    }
                }
                [[TMLanguage sharedManager] refreshLanguage];
            }

        }
        if(IS_NOT_NULL(addons.config, @"excluded_addresses")) {
            NSMutableArray* tempDict = GET_VALUE_OBJECT(addons.config, @"excluded_addresses");
            for (NSString* str in tempDict) {
                if ([str isEqualToString:@"first_name"]) {
                    addons.excludedAddress.first_name = false;
                } else if ([str isEqualToString:@"last_name"]) {
                    addons.excludedAddress.last_name = false;
                } else if ([str isEqualToString:@"email"]) {
                    addons.excludedAddress.email = false;
                } else if ([str isEqualToString:@"billing_address_1"]) {
                    addons.excludedAddress.billing_address_1 = false;
                } else if ([str isEqualToString:@"billing_address_2"]) {
                    addons.excludedAddress.billing_address_2 = false;
                } else if ([str isEqualToString:@"billing_city"]) {
                    addons.excludedAddress.billing_city = false;
                } else if ([str isEqualToString:@"billing_country"]) {
                    addons.excludedAddress.billing_country = false;
                } else if ([str isEqualToString:@"billing_email"]) {
                    addons.excludedAddress.billing_email = false;
                } else if ([str isEqualToString:@"billing_first_name"]) {
                    addons.excludedAddress.billing_first_name = false;
                } else if ([str isEqualToString:@"billing_last_name"]) {
                    addons.excludedAddress.billing_last_name = false;
                } else if ([str isEqualToString:@"billing_phone"]) {
                    addons.excludedAddress.billing_phone = false;
                } else if ([str isEqualToString:@"billing_state"]) {
                    addons.excludedAddress.billing_state = false;
                } else if ([str isEqualToString:@"billing_postcode"]) {
                    addons.excludedAddress.billing_postcode = false;
                } else if ([str isEqualToString:@"shipping_address_1"]) {
                    addons.excludedAddress.shipping_address_1 = false;
                } else if ([str isEqualToString:@"shipping_address_2"]) {
                    addons.excludedAddress.shipping_address_2 = false;
                } else if ([str isEqualToString:@"shipping_city"]) {
                    addons.excludedAddress.shipping_city = false;
                } else if ([str isEqualToString:@"shipping_country"]) {
                    addons.excludedAddress.shipping_country = false;
                } else if ([str isEqualToString:@"shipping_first_name"]) {
                    addons.excludedAddress.shipping_first_name = false;
                } else if ([str isEqualToString:@"shipping_last_name"]) {
                    addons.excludedAddress.shipping_last_name = false;
                } else if ([str isEqualToString:@"shipping_postcode"]) {
                    addons.excludedAddress.shipping_postcode = false;
                } else if ([str isEqualToString:@"shipping_state"]) {
                    addons.excludedAddress.shipping_state = false;
                }
            }

        }
        if (IS_NOT_NULL(addons.config, @"enable_cart")) {
            addons.enable_cart = GET_VALUE_BOOL(addons.config, @"enable_cart");
            if (addons.enable_cart == false) {
                addons.show_cart_with_product= false;
            }
        }
        if (IS_NOT_NULL(addons.config, @"load_extra_attrib_data")) {
            addons.load_extra_attrib_data = GET_VALUE_BOOL(addons.config, @"load_extra_attrib_data");
        }
        if (IS_NOT_NULL(addons.config, @"show_home_title_text")) {
            addons.show_home_title_text = GET_VALUE_BOOL(addons.config, @"show_home_title_text");
        }
        if (IS_NOT_NULL(addons.config, @"show_home_title_image")) {
            addons.show_home_title_image = GET_VALUE_BOOL(addons.config, @"show_home_title_image");
        }
        if (IS_NOT_NULL(addons.config, @"show_actionbar_icon")) {
            addons.show_actionbar_icon = GET_VALUE_BOOL(addons.config, @"show_actionbar_icon");
            addons.show_home_title_text = !addons.show_actionbar_icon;
            addons.show_home_title_image = !addons.show_home_title_text;
        }
        if (IS_NOT_NULL(addons.config, @"actionbar_icon_url")) {
            addons.actionbar_icon_url = GET_VALUE_OBJECT(addons.config, @"actionbar_icon_url");
        }
        if (IS_NOT_NULL(addons.config, @"add_search_in_home")) {
            addons.add_search_in_home = GET_VALUE_BOOL(addons.config, @"add_search_in_home");
        }
        if (IS_NOT_NULL(addons.config, @"show_section_best_deals")) {
            addons.show_section_best_deals = GET_VALUE_BOOL(addons.config, @"show_section_best_deals");
        }
        if (IS_NOT_NULL(addons.config, @"show_section_fresh_arrivals")) {
            addons.show_section_fresh_arrivals = GET_VALUE_BOOL(addons.config, @"show_section_fresh_arrivals");
        }
        if (IS_NOT_NULL(addons.config, @"show_section_trending")) {
            addons.show_section_trending = GET_VALUE_BOOL(addons.config, @"show_section_trending");
        }
        if (IS_NOT_NULL(addons.config, @"show_home_categories")) {
            addons.show_home_categories = GET_VALUE_BOOL(addons.config, @"show_home_categories");
        }
        if (IS_NOT_NULL(addons.config, @"show_min_max_price")) {
            addons.show_min_max_price = GET_VALUE_BOOL(addons.config, @"show_min_max_price");
        }
        if (IS_NOT_NULL(addons.config, @"auto_generate_variations")) {
            addons.auto_generate_variations = GET_VALUE_BOOL(addons.config, @"auto_generate_variations");
        }
        if (IS_NOT_NULL(addons.config, @"enable_custom_wishlist")) {
            addons.enable_custom_wishlist = GET_VALUE_BOOL(addons.config, @"enable_custom_wishlist");
        }
        if (IS_NOT_NULL(addons.config, @"enable_custom_waitlist")) {
            addons.enable_custom_waitlist = GET_VALUE_BOOL(addons.config, @"enable_custom_waitlist");
        }
        if (IS_NOT_NULL(addons.config, @"enable_custom_points")) {
            addons.enable_custom_points = GET_VALUE_BOOL(addons.config, @"enable_custom_points");
        }
        /*
         if (IS_NOT_NULL(addons.config, @"enable_sponsor_friend")) {
         addons.enable_sponsor_friend = GET_VALUE_BOOL(addons.config, @"enable_sponsor_friend");
         }
         */
        if (IS_NOT_NULL(addons.config, @"enable_pincode_settings")) {
            addons.enable_pincode_settings = GET_VALUE_BOOL(addons.config, @"enable_pincode_settings");
        }
        if (IS_NOT_NULL(addons.config, @"enable_auto_coupons")) {
            addons.enable_auto_coupons = GET_VALUE_BOOL(addons.config, @"enable_auto_coupons");
        }
        if (IS_NOT_NULL(addons.config, @"check_min_order_data")) {
            addons.check_min_order_data = GET_VALUE_BOOL(addons.config, @"check_min_order_data");
        }

        if (IS_NOT_NULL(addons.config, @"order_note")) {
            NSDictionary* orderNoteDict = GET_VALUE_OBJECT(addons.config, @"order_note");
            addons.orderNote = [[OrderNote alloc] init];

            if (IS_NOT_NULL(orderNoteDict, @"char_limit")) {
                addons.orderNote.note_char_limit = GET_VALUE_INT(orderNoteDict, @"char_limit");
            }
            if (IS_NOT_NULL(orderNoteDict, @"char_type")) {
                NSString* str = GET_VALUE_OBJECT(orderNoteDict, @"char_type");
                if ([str isEqualToString:@"alphanumeric"]) {
                    addons.orderNote.note_char_type = ORDER_NOTE_CHAR_TYPE_ALPHANUMERIC;
                }
                if ([str isEqualToString:@"numeric"]) {
                    addons.orderNote.note_char_type = ORDER_NOTE_CHAR_TYPE_NUMERIC;
                }
            }
            if (IS_NOT_NULL(orderNoteDict, @"enabled")) {
                addons.orderNote.note_enabled = GET_VALUE_BOOL(orderNoteDict, @"enabled");
            }
            if (IS_NOT_NULL(orderNoteDict, @"line_count")) {
                addons.orderNote.note_line_count = GET_VALUE_INT(orderNoteDict, @"line_count");
            }
            if (IS_NOT_NULL(orderNoteDict, @"single_line")) {
                addons.orderNote.note_single_line = GET_VALUE_BOOL(orderNoteDict, @"single_line");
            }
        }

        if (IS_NOT_NULL(addons.config, @"cart_note")) {
            NSDictionary* cartNoteDict = GET_VALUE_OBJECT(addons.config, @"cart_note");
            addons.cartNote = [[CartNote alloc] init];

            if (IS_NOT_NULL(cartNoteDict, @"char_limit")) {
                addons.cartNote.note_char_limit = GET_VALUE_INT(cartNoteDict, @"char_limit");
            }
            if (IS_NOT_NULL(cartNoteDict, @"char_type")) {
                NSString* str = GET_VALUE_OBJECT(cartNoteDict, @"char_type");
                if ([str isEqualToString:@"alphanumeric"]) {
                    addons.cartNote.note_char_type = CART_NOTE_CHAR_TYPE_ALPHANUMERIC;
                }
                if ([str isEqualToString:@"numeric"]) {
                    addons.cartNote.note_char_type = CART_NOTE_CHAR_TYPE_NUMERIC;
                }
            }
            if (IS_NOT_NULL(cartNoteDict, @"enabled")) {
                addons.cartNote.note_enabled = GET_VALUE_BOOL(cartNoteDict, @"enabled");
            }
            if (IS_NOT_NULL(cartNoteDict, @"line_count")) {
                addons.cartNote.note_line_count = GET_VALUE_INT(cartNoteDict, @"line_count");
            }
            if (IS_NOT_NULL(cartNoteDict, @"single_line")) {
                addons.cartNote.note_single_line = GET_VALUE_BOOL(cartNoteDict, @"single_line");
            }
            if (IS_NOT_NULL(cartNoteDict, @"location")) {
                int loc = GET_VALUE_INT(cartNoteDict, @"location");
                if (loc == CART_NOTE_LOCATION_AFTER_EACH_ITEM) {
                    addons.cartNote.note_location = CART_NOTE_LOCATION_AFTER_EACH_ITEM;
                }
                if (loc == CART_NOTE_LOCATION_BEFORE_PLACE_ORDER_BUTTON) {
                    addons.cartNote.note_location = CART_NOTE_LOCATION_BEFORE_PLACE_ORDER_BUTTON;
                }
            }
        }
        if (IS_NOT_NULL(addons.config, @"show_categories_in_search")) {
            addons.show_categories_in_search = GET_VALUE_BOOL(addons.config, @"show_categories_in_search");
        }
        if (IS_NOT_NULL(addons.config, @"hide_coupon_list")) {
            addons.hide_coupon_list = GET_VALUE_BOOL(addons.config, @"hide_coupon_list");
        }
        if (IS_NOT_NULL(addons.config, @"date_format")) {
            addons.date_format = GET_VALUE_OBJ(addons.config, @"date_format");
        }
    }

    if (IS_NOT_NULL(dict, @"apps")) {
        NSArray* tempArray = GET_VALUE_OBJECT(dict, @"apps");
        for (NSDictionary* tempDict in tempArray) {
            APPS* tempApp = [[APPS alloc] init];
            if (IS_NOT_NULL(tempDict, @"app_name")) {
                tempApp.app_name = GET_VALUE_STRING(tempDict, @"app_name");
            }
            if (IS_NOT_NULL(tempDict, @"app_id")) {
                tempApp.app_id = GET_VALUE_STRING(tempDict, @"app_id");
            }
            if (IS_NOT_NULL(tempDict, @"app_key")) {
                tempApp.app_key = GET_VALUE_STRING(tempDict, @"app_key");
            }
            if (IS_NOT_NULL(tempDict, @"apn")) {
                tempApp.apn = GET_VALUE_STRING(tempDict, @"apn");
            }
            if (IS_NOT_NULL(tempDict, @"gcm")) {
                tempApp.gcm = GET_VALUE_STRING(tempDict, @"gcm");
            }
            if (IS_NOT_NULL(tempDict, @"title")) {
                tempApp.title = GET_VALUE_STRING(tempDict, @"title");
            }
            if (IS_NOT_NULL(tempDict, @"pos")) {
                tempApp.pos = GET_VALUE_INT(tempDict, @"pos");
            }
            if (IS_NOT_NULL(tempDict, @"pos")) {
                tempApp.pos = GET_VALUE_INT(tempDict, @"pos");
            }
            if (IS_NOT_NULL(tempDict, @"enabled")) {
                tempApp.isEnabled = GET_VALUE_BOOL(tempDict, @"enabled");
            }
            if (IS_NOT_NULL(tempDict, @"enable_seller_app")) {
                tempApp.enable_seller_app = GET_VALUE_BOOL(tempDict, @"enable_seller_app");
            }
            if (IS_NOT_NULL(tempDict, @"plugin")) {
                tempApp.plugin_name = GET_VALUE_OBJECT(tempDict, @"plugin");
            }
            if (IS_NOT_NULL(tempDict, @"vendor_icon_url")) {
                tempApp.multiVendor_icon_url = GET_VALUE_OBJECT(tempDict, @"vendor_icon_url");
            }
            if (IS_NOT_NULL(tempDict, @"vendor_icon_reuse")) {
                tempApp.multiVendor_icon_reuse = GET_VALUE_BOOL(tempDict, @"vendor_icon_reuse");
            }
            if (IS_NOT_NULL(tempDict, @"sponsor_img_url")) {
                tempApp.sponsor_img_url = GET_VALUE_OBJECT(tempDict, @"sponsor_img_url");
            }
            if (IS_NOT_NULL(tempDict, @"delay")) {
                tempApp.ad_delay = GET_VALUE_INT(tempDict, @"delay");
            }
            if (IS_NOT_NULL(tempDict, @"interval")) {
                tempApp.ad_interval = GET_VALUE_INT(tempDict, @"interval");
            }
            if (IS_NOT_NULL(tempDict, @"ad_id")) {
                tempApp.ad_id = GET_VALUE_OBJECT(tempDict, @"ad_id");
            }
            if (IS_NOT_NULL(tempDict, @"ad_unit_id")) {
                tempApp.ad_unit_id = GET_VALUE_OBJECT(tempDict, @"ad_unit_id");
            }
            

            ///assign
            if ([[tempApp.app_name lowercaseString] isEqualToString:@"hotline"]) {
#if ENABLE_HOTLINE
                addons.hotline = tempApp;
                if (addons.hotline.isEnabled) {
                    AppDelegate* appD = (AppDelegate*)[UIApplication sharedApplication].delegate;
                    [appD configureHotlineSDK:addons.hotline.app_id hotlineAppKey:addons.hotline.app_key];
                }
#endif
            }
            else if ([[tempApp.app_name lowercaseString] isEqualToString:@"freshchat"]) {
#if ENABLE_FRESHCHAT
                addons.hotline = tempApp;
                if (addons.hotline.isEnabled) {
                    AppDelegate* appD = (AppDelegate*)[UIApplication sharedApplication].delegate;
                    [appD configureHotlineSDK:addons.hotline.app_id hotlineAppKey:addons.hotline.app_key];
                }
#endif
            }
            else if ([[tempApp.app_name lowercaseString] isEqualToString:@"geo_location"])
            {
#if ENABLE_AUTOCOMPLETE_GEOLOCATION_SEARCH
                addons.geoLocation = tempApp;
                if (addons.geoLocation.isEnabled) {
                    AppDelegate* appD = (AppDelegate*)[UIApplication sharedApplication].delegate;
                    [appD configureGeoLocationSDK:addons.geoLocation.app_key];
                }
#endif
            }
            else if ([[tempApp.app_name lowercaseString] isEqualToString:@"product_delivery_date"] || [[tempApp.app_name lowercaseString] isEqualToString:@"product_delivery_data"])
            {
#if ENABLE_PRODUCT_DELIVERY_DATA_PLUGIN
                addons.productDeliveryDatePlugin = tempApp;
                if (addons.productDeliveryDatePlugin.isEnabled) {
                }
#endif
            }
            else if ([[tempApp.app_name lowercaseString] isEqualToString:@"admob"])
            {
#if ENABLE_GOOGLE_ADMOB_SDK
                addons.googleAdmobPlugin = tempApp;
                if (addons.googleAdmobPlugin.isEnabled) {
                    AppDelegate* appD = (AppDelegate*)[UIApplication sharedApplication].delegate;
                    [appD initGoogleAdMobSDK:addons.googleAdmobPlugin.ad_id];
                }
#endif
            }
            else if ([[tempApp.app_name lowercaseString] isEqualToString:@"sponsor_friend"])
            {
#if ENABLE_SPONSOR_FRIEND
                addons.sponsorFriend = tempApp;
                if (addons.sponsorFriend.isEnabled) {
                }
#endif
            }
            else if ([[tempApp.app_name lowercaseString] isEqualToString:@"multivendor"])
            {
#if ENABLE_MULTI_VENDOR
                addons.multiVendor = tempApp;
                if (addons.multiVendor.isEnabled) {
                    ShopSettings* ss = addons.multiVendor.multiVendor_shop_settings;
                    if (IS_NOT_NULL(tempDict, @"shipping_required")) {
                        ss.shipping_required = GET_VALUE_BOOL(tempDict, @"shipping_required");
                    }
                    if (IS_NOT_NULL(tempDict, @"show_location")) {
                        ss.show_location = GET_VALUE_BOOL(tempDict, @"show_location");
                    }
                    if (IS_NOT_NULL(tempDict, @"publish_status")) {
                        ss.publish_status = GET_VALUE_STRING(tempDict, @"publish_status");
                    }
                    if (IS_NOT_NULL(tempDict, @"manage_stock")) {
                        ss.manage_stock = GET_VALUE_BOOL(tempDict, @"manage_stock");
                    }
                    if (IS_NOT_NULL(tempDict, @"show_parent_categories")) {
                        ss.show_parent_categories = GET_VALUE_BOOL(tempDict, @"show_parent_categories");
                    }
                    ss.show_parent_categories = false;
                    if (IS_NOT_NULL(tempDict, @"other_options")) {
                        ss.other_options = GET_VALUE_BOOL(tempDict, @"other_options");
                    }
                    if (IS_NOT_NULL(tempDict, @"enable_subscription")) {
                        ss.enable_subscription = GET_VALUE_BOOL(tempDict, @"enable_subscription");
                    }
                    if (IS_NOT_NULL(tempDict, @"shop_settings")) {
                        //                        "avatar_icon",
                        //                        "first_name",
                        //                        "last_name",
                        //                        "shop_name",
                        //                        "shop_contact",
                        //                        "shop_address",
                        //                        "shop_icon"
                        NSArray* shop_settings_dict = GET_VALUE_OBJ(tempDict, @"shop_settings");
                        if ([shop_settings_dict containsObject:@"avatar_icon"]) {
                            ss.enable_avatar_icon = true;
                        }
                        if ([shop_settings_dict containsObject:@"first_name"]) {
                            ss.enable_first_name = true;
                        }
                        if ([shop_settings_dict containsObject:@"last_name"]) {
                            ss.enable_last_name = true;
                        }
                        if ([shop_settings_dict containsObject:@"shop_name"]) {
                            ss.enable_shop_name = true;
                        }
                        if ([shop_settings_dict containsObject:@"shop_contact"]) {
                            ss.enable_shop_contact = true;
                        }
                        if ([shop_settings_dict containsObject:@"shop_address"]) {
                            ss.enable_shop_address = true;
                        }
                        if ([shop_settings_dict containsObject:@"shop_icon"]) {
                            ss.enable_shop_icon = true;
                        }
                    }
                    if (IS_NOT_NULL(tempDict, @"profile_items")) {
                        ss.profile_items = [[NSMutableArray alloc] init];
                        if ([GET_VALUE_OBJ(tempDict, @"profile_items") isKindOfClass:[NSArray class]]) {
                            ss.profile_items = GET_VALUE_OBJ(tempDict, @"profile_items");
                        }
                    }
                    addons.enable_seller_only_app = addons.multiVendor.enable_seller_app;
                    addons.multiVendor_enable = true;
                    addons.multiVendor_screen_type = MULTIVENDOR_SCREEN_SELLER;
                    if (IS_NOT_NULL(tempDict, @"screen")) {
                        NSString* multiVendorScreenType = GET_VALUE_OBJECT(tempDict, @"screen");
                        if ([[multiVendorScreenType lowercaseString] isEqualToString:@"products"]) {
                            addons.multiVendor_screen_type = MULTIVENDOR_SCREEN_PRODUCT;
                        } if ([[multiVendorScreenType lowercaseString] isEqualToString:@"seller"]) {
                            addons.multiVendor_screen_type = MULTIVENDOR_SCREEN_SELLER;
                        }
                    }

                    if (IS_NOT_NULL(tempDict, @"upload_options")) {
                        NSDictionary *upload_options = [tempDict objectForKey:@"upload_options"];
                        if (IS_NOT_NULL(upload_options, @"image_width")) {
                            addons.multiVendor.upload_image_width = GET_VALUE_INT(upload_options, @"image_width");
                        }
                        if (IS_NOT_NULL(upload_options, @"image_width")) {
                            addons.multiVendor.upload_image_height = GET_VALUE_INT(upload_options, @"image_height");
                        }
                    }
                } else {
                    addons.multiVendor_enable = false;
                }
#endif
            }
            else if ([[tempApp.app_name lowercaseString] isEqualToString:@"timeslot"])
            {
#if ENABLE_DELIVERY_SLOT_COPIA
                if ([[tempApp.plugin_name lowercaseString] isEqualToString:@"woocommerce_delivery_slots_copia"]) {
                    addons.deliverySlotsCopiaPlugin = tempApp;
                }
#endif
#if ENABLE_LOCAL_PICKUP_TIME_SELECT
                if ([[tempApp.plugin_name lowercaseString] isEqualToString:@"woocommerce_local_pickup_time_select"]) {
                    addons.localPickupTimeSelectPlugin = tempApp;
                }
#endif
            }
            else if ([[tempApp.app_name lowercaseString] isEqualToString:@"firebaseanalytics"]){
#if ENABLE_FIREBASE_TAG_MANAGER
                addons.firebaseAnalytics = tempApp;
#endif
            }
            else{

            }
        }
    }

    if (IS_NOT_NULL(dict, @"payments")) {
        //        [dict setValue:@"{\"gateway\":\"paystack\",\"publicKey\":\"pk_live_983a5778515eb60afc530a94cdc178a7f4edba10\",\"secretKey\":\"sk_live_e4bcc78077cc04d4dd1c4da786353a24ecc6152f\",\"enabled\":true}" forKey:@"payments"];

        NSArray* paymentsArray = GET_VALUE_OBJECT(dict, @"payments");

        for (NSDictionary* tempDict in paymentsArray) {
            NSString* gateway = @"";
            if (IS_NOT_NULL(tempDict, @"gateway")) {
                gateway = [GET_VALUE_OBJECT(tempDict, @"gateway") lowercaseString];
            }
            if ([gateway isEqualToString:[@"PayPal" lowercaseString]]) {
                PayPalConfig* config = [PayPalConfig sharedManager];
                if (IS_NOT_NULL(tempDict, @"merchant_id")) {
                    config.cPayPalClientId = GET_VALUE_OBJECT(tempDict, @"merchant_id");
                }
                if (IS_NOT_NULL(tempDict, @"merchant_sandbox_id")) {
                    config.cPayPalSandboxId = GET_VALUE_OBJECT(tempDict, @"merchant_sandbox_id");
                }
                if (IS_NOT_NULL(tempDict, @"enabled")) {
                    config.cIsEnabled = GET_VALUE_BOOL(tempDict, @"enabled");
                }
                if (IS_NOT_NULL(tempDict, @"enableCreditCard")) {
                    config.cEnableCreditCard = GET_VALUE_BOOL(tempDict, @"enableCreditCard");
                }


                [addons.addonPayments addObject:config];
            }
            else if ([gateway isEqualToString:[@"PayUMoney" lowercaseString]]) {
                PayuConfig* config = [PayuConfig sharedManager];
                if (IS_NOT_NULL(tempDict, @"merchant_key")) {
                    config.cPayuMerchantKey = GET_VALUE_OBJECT(tempDict, @"merchant_key");
                }
                if (IS_NOT_NULL(tempDict, @"salt")) {
                    config.cPayuSaltKey = GET_VALUE_OBJECT(tempDict, @"salt");
                }
                if (IS_NOT_NULL(tempDict, @"service_provider")) {
                    config.cServiceProvider = GET_VALUE_OBJECT(tempDict, @"service_provider");
                }
                if (IS_NOT_NULL(tempDict, @"surl")) {
                    config.cSuccessUrl = GET_VALUE_OBJECT(tempDict, @"surl");
                }
                if (IS_NOT_NULL(tempDict, @"furl")) {
                    config.cFailureUrl = GET_VALUE_OBJECT(tempDict, @"furl");
                }
                if (IS_NOT_NULL(tempDict, @"enabled")) {
                    config.cIsEnabled = GET_VALUE_BOOL(tempDict, @"enabled");
                }
                [addons.addonPayments addObject:config];
            }
            else if ([gateway isEqualToString:[@"stripe" lowercaseString]]) {
                StripeConfig* config = [StripeConfig sharedManager];
                if (IS_NOT_NULL(tempDict, @"publishable_key")) {
                    config.cStripePublishableKey = GET_VALUE_OBJECT(tempDict, @"publishable_key");
                }
                if (IS_NOT_NULL(tempDict, @"secret_key")) {
                    config.cStripeSecretKey = GET_VALUE_OBJECT(tempDict, @"secret_key");
                }
                if (IS_NOT_NULL(tempDict, @"backend_charge_url")) {
                    config.cBackendChargeURLString = GET_VALUE_OBJECT(tempDict, @"backend_charge_url");
                }
                if (IS_NOT_NULL(tempDict, @"backend_save_card_url")) {
                    config.cBackendChargeURLStringSavedCard = GET_VALUE_OBJECT(tempDict, @"backend_save_card_url");
                }

                //config.cBackendChargeURLStringSavedCard = @"https://www.sexappealstore.it/stripe/save_card.php";

                if (IS_NOT_NULL(tempDict, @"enabled")) {
                    config.cIsEnabled = GET_VALUE_BOOL(tempDict, @"enabled");
                }
                if (IS_NOT_NULL(tempDict, @"default_gateway")) {
                    config.cIsDefaultGateway = GET_VALUE_BOOL(tempDict, @"default_gateway");
                }
                if (IS_NOT_NULL(tempDict, @"title")) {
                    config.cTitle = GET_VALUE_OBJECT(tempDict, @"title");
                }
                //#if TEST_ORDER_OR_PAYMENT
                //                config.cIsDefaultGateway = true;
                //                config.cTitle = @"rishabh";
                //#endif
                [addons.addonPayments addObject:config];
            }
            else if ([gateway isEqualToString:[@"paystack" lowercaseString]]) {
                PaystackConfig* config = [PaystackConfig sharedManager];
                if (IS_NOT_NULL(tempDict, @"publicKey")) {
                    config.cPaystackPublishableKey = GET_VALUE_OBJECT(tempDict, @"publicKey");
                }
                if (IS_NOT_NULL(tempDict, @"secretKey")) {
                    config.cPaystackSecretKey = GET_VALUE_OBJECT(tempDict, @"secretKey");
                }
                if (IS_NOT_NULL(tempDict, @"backend_charge_url")) {
                    config.cBackendChargeURLString = GET_VALUE_OBJECT(tempDict, @"backend_charge_url");
                }
                if (IS_NOT_NULL(tempDict, @"enabled")) {
                    config.cIsEnabled = GET_VALUE_BOOL(tempDict, @"enabled");
                }
                if (IS_NOT_NULL(tempDict, @"default_gateway")) {
                    config.cIsDefaultGateway = GET_VALUE_BOOL(tempDict, @"default_gateway");
                }
                if (IS_NOT_NULL(tempDict, @"title")) {
                    config.cTitle = GET_VALUE_OBJECT(tempDict, @"title");
                }
                [addons.addonPayments addObject:config];
            }
            else if ([gateway isEqualToString:[@"ApplePayViaStripe" lowercaseString]]) {
                ApplePayViaStripeConfig* config = [ApplePayViaStripeConfig sharedManager];
                if (IS_NOT_NULL(tempDict, @"publishable_key")) {
                    config.cStripePublishableKey = GET_VALUE_OBJECT(tempDict, @"publishable_key");
                }
                if (IS_NOT_NULL(tempDict, @"secret_key")) {
                    config.cStripeSecretKey = GET_VALUE_OBJECT(tempDict, @"secret_key");
                }
                if (IS_NOT_NULL(tempDict, @"backend_charge_url")) {
                    config.cBackendChargeURLString = GET_VALUE_OBJECT(tempDict, @"backend_charge_url");
                }
                if (IS_NOT_NULL(tempDict, @"apple_pay_merchant_id")) {
                    config.cApplePayMerchantId = GET_VALUE_OBJECT(tempDict, @"apple_pay_merchant_id");
                }
                if (IS_NOT_NULL(tempDict, @"enabled")) {
                    config.cIsEnabled = GET_VALUE_BOOL(tempDict, @"enabled");
                }
                if (IS_NOT_NULL(tempDict, @"default_gateway")) {
                    config.cIsDefaultGateway = GET_VALUE_BOOL(tempDict, @"default_gateway");
                }
                if (IS_NOT_NULL(tempDict, @"title")) {
                    config.cTitle = GET_VALUE_OBJECT(tempDict, @"title");
                }
                [addons.addonPayments addObject:config];
            }
            else if ([gateway isEqualToString:[@"Sagepay" lowercaseString]]) {
                SagepayConfig* config = [SagepayConfig sharedManager];
                if (IS_NOT_NULL(tempDict, @"vendor_url")) {
                    config.cVendorUrl = GET_VALUE_OBJECT(tempDict, @"vendor_url");
                }
                if (IS_NOT_NULL(tempDict, @"vendor_id")) {
                    config.cVendorId = GET_VALUE_OBJECT(tempDict, @"vendor_id");
                }
                if (IS_NOT_NULL(tempDict, @"vendor_password")) {
                    config.cVendorPassword = GET_VALUE_OBJECT(tempDict, @"vendor_password");
                }
                if (IS_NOT_NULL(tempDict, @"vendor_response_url")) {
                    config.cVendorResponseUrl = GET_VALUE_OBJECT(tempDict, @"vendor_response_url");
                }
                if (IS_NOT_NULL(tempDict, @"vendor_payment_url")) {
                    config.cVendorPaymentUrl = GET_VALUE_OBJECT(tempDict, @"vendor_payment_url");
                }
                if (IS_NOT_NULL(tempDict, @"enabled")) {
                    config.cIsEnabled = GET_VALUE_BOOL(tempDict, @"enabled");
                }

                if (IS_NOT_NULL(tempDict, @"default_gateway")) {
                    config.cIsDefaultGateway = GET_VALUE_BOOL(tempDict, @"default_gateway");
                }
                if (IS_NOT_NULL(tempDict, @"title")) {
                    config.cTitle = GET_VALUE_OBJECT(tempDict, @"title");
                }
                [addons.addonPayments addObject:config];
            }
            else if ([gateway isEqualToString:[@"Gestpay" lowercaseString]]) {
                GestpayConfig* config = [GestpayConfig sharedManager];
                if (IS_NOT_NULL(tempDict, @"payment_url")) {
                    config.cPaymentUrl = GET_VALUE_OBJECT(tempDict, @"payment_url");
                }
                if (IS_NOT_NULL(tempDict, @"shop_login")) {
                    config.cShopLogin = GET_VALUE_OBJECT(tempDict, @"shop_login");
                }
                if (IS_NOT_NULL(tempDict, @"shop_transaction_id")) {
                    config.cShopTransactionId = GET_VALUE_OBJECT(tempDict, @"shop_transaction_id");
                }
                if (IS_NOT_NULL(tempDict, @"enabled")) {
                    config.cIsEnabled = GET_VALUE_BOOL(tempDict, @"enabled");
                }

                if (IS_NOT_NULL(tempDict, @"default_gateway")) {
                    config.cIsDefaultGateway = GET_VALUE_BOOL(tempDict, @"default_gateway");
                }
                if (IS_NOT_NULL(tempDict, @"title")) {
                    config.cTitle = GET_VALUE_OBJECT(tempDict, @"title");
                }
                [addons.addonPayments addObject:config];
            }
            else if ([gateway isEqualToString:[@"Kentpayment" lowercaseString]]) {
                KentPaymentConfig* config = [KentPaymentConfig sharedManager];
                if (IS_NOT_NULL(tempDict, @"access_url")) {
                    config.cAccessUrl = GET_VALUE_OBJECT(tempDict, @"access_url");
                }
                if (IS_NOT_NULL(tempDict, @"sectery")) {
                    config.cSecretKey= GET_VALUE_OBJECT(tempDict, @"sectery");
                }
                if (IS_NOT_NULL(tempDict, @"enabled")) {
                    config.cIsEnabled = GET_VALUE_BOOL(tempDict, @"enabled");
                }
                if (IS_NOT_NULL(tempDict, @"default_gateway")) {
                    config.cIsDefaultGateway = GET_VALUE_BOOL(tempDict, @"default_gateway");
                }
                if (IS_NOT_NULL(tempDict, @"title")) {
                    config.cTitle = GET_VALUE_OBJECT(tempDict, @"title");
                }
                [addons.addonPayments addObject:config];
            }
            else if ([gateway isEqualToString:[@"PayPal Payflow" lowercaseString]]) {
                PayPalPayFlowConfig* config = [PayPalPayFlowConfig sharedManager];
                if (IS_NOT_NULL(tempDict, @"backendurl")) {
                    config.cBackendUrl = GET_VALUE_OBJECT(tempDict, @"backendurl");
                }
                if (IS_NOT_NULL(tempDict, @"enabled")) {
                    config.cIsEnabled = GET_VALUE_BOOL(tempDict, @"enabled");
                }
                if (IS_NOT_NULL(tempDict, @"default_gateway")) {
                    config.cIsDefaultGateway = GET_VALUE_BOOL(tempDict, @"default_gateway");
                }
                if (IS_NOT_NULL(tempDict, @"title")) {
                    config.cTitle = GET_VALUE_OBJECT(tempDict, @"title");
                }
                [addons.addonPayments addObject:config];
            }
            else if ([gateway isEqualToString:[@"vcs" lowercaseString]]) {
                VCSPayConfig* config = [VCSPayConfig sharedManager];
                if (IS_NOT_NULL(tempDict, @"merchant_id")) {
                    config.cMerchantId = GET_VALUE_OBJECT(tempDict, @"merchant_id");
                }
                if (IS_NOT_NULL(tempDict, @"enabled")) {
                    config.cIsEnabled = GET_VALUE_BOOL(tempDict, @"enabled");
                }
                if (IS_NOT_NULL(tempDict, @"default_gateway")) {
                    config.cIsDefaultGateway = GET_VALUE_BOOL(tempDict, @"default_gateway");
                }
                if (IS_NOT_NULL(tempDict, @"title")) {
                    config.cTitle = GET_VALUE_OBJECT(tempDict, @"title");
                }
                [addons.addonPayments addObject:config];
            }
            else if ([gateway isEqualToString:[@"TapPay" lowercaseString]]) {
                TapPaymentConfig* config = [TapPaymentConfig sharedManager];
                if (IS_NOT_NULL(tempDict, @"backendurl")) {
                    config.cBackendUrl = GET_VALUE_OBJECT(tempDict, @"backendurl");
                }
                if (IS_NOT_NULL(tempDict, @"enabled")) {
                    config.cIsEnabled = GET_VALUE_BOOL(tempDict, @"enabled");
                }
                if (IS_NOT_NULL(tempDict, @"default_gateway")) {
                    config.cIsDefaultGateway = GET_VALUE_BOOL(tempDict, @"default_gateway");
                }
                if (IS_NOT_NULL(tempDict, @"title")) {
                    config.cTitle = GET_VALUE_OBJECT(tempDict, @"title");
                }
                [addons.addonPayments addObject:config];
            }
            else if ([gateway isEqualToString:[@"PlugNPay" lowercaseString]]) {
                PlugNPayPaymentConfig* config = [PlugNPayPaymentConfig sharedManager];
                if (IS_NOT_NULL(tempDict, @"backendurl")) {
                    config.cBackendUrl = GET_VALUE_OBJECT(tempDict, @"backendurl");
                } else if (IS_NOT_NULL(tempDict, @"baseurl")) {
                    config.cBackendUrl = GET_VALUE_OBJECT(tempDict, @"baseurl");
                }
                if (IS_NOT_NULL(tempDict, @"enabled")) {
                    config.cIsEnabled = GET_VALUE_BOOL(tempDict, @"enabled");
                }
                if (IS_NOT_NULL(tempDict, @"default_gateway")) {
                    config.cIsDefaultGateway = GET_VALUE_BOOL(tempDict, @"default_gateway");
                }
                if (IS_NOT_NULL(tempDict, @"title")) {
                    config.cTitle = GET_VALUE_OBJECT(tempDict, @"title");
                }
                [addons.addonPayments addObject:config];
            }
            else if ([gateway isEqualToString:[@"senangpay" lowercaseString]]) {
                SenangPayPaymentConfig* config = [SenangPayPaymentConfig sharedManager];
                if (IS_NOT_NULL(tempDict, @"baseurl")) {
                    config.cBaseUrl = GET_VALUE_OBJECT(tempDict, @"baseurl");
                }
                if (IS_NOT_NULL(tempDict, @"surl")) {
                    config.cSuccessUrl = GET_VALUE_OBJECT(tempDict, @"surl");
                }
                if (IS_NOT_NULL(tempDict, @"furl")) {
                    config.cFailureUrl = GET_VALUE_OBJECT(tempDict, @"furl");
                }
                if (IS_NOT_NULL(tempDict, @"enabled")) {
                    config.cIsEnabled = GET_VALUE_BOOL(tempDict, @"enabled");
                }
                if (IS_NOT_NULL(tempDict, @"default_gateway")) {
                    config.cIsDefaultGateway = GET_VALUE_BOOL(tempDict, @"default_gateway");
                }
                if (IS_NOT_NULL(tempDict, @"title")) {
                    config.cTitle = GET_VALUE_OBJECT(tempDict, @"title");
                }
                [addons.addonPayments addObject:config];
            }
            else if ([gateway isEqualToString:[@"mollie" lowercaseString]]) {
                MolliePaymentConfig* config = [MolliePaymentConfig sharedManager];
                if (IS_NOT_NULL(tempDict, @"baseurl")) {
                    config.cBaseUrl = GET_VALUE_OBJECT(tempDict, @"baseurl");
                }
                if (IS_NOT_NULL(tempDict, @"surl")) {
                    config.cSuccessUrl = GET_VALUE_OBJECT(tempDict, @"surl");
                }
                if (IS_NOT_NULL(tempDict, @"furl")) {
                    config.cFailureUrl = GET_VALUE_OBJECT(tempDict, @"furl");
                }
                if (IS_NOT_NULL(tempDict, @"enabled")) {
                    config.cIsEnabled = GET_VALUE_BOOL(tempDict, @"enabled");
                }
                if (IS_NOT_NULL(tempDict, @"default_gateway")) {
                    config.cIsDefaultGateway = GET_VALUE_BOOL(tempDict, @"default_gateway");
                }
                if (IS_NOT_NULL(tempDict, @"title")) {
                    config.cTitle = GET_VALUE_OBJECT(tempDict, @"title");
                }
                [addons.addonPayments addObject:config];
            }
            else if ([gateway isEqualToString:[@"hesabe" lowercaseString]]) {
                HesabePaymentConfig* config = [HesabePaymentConfig sharedManager];
                if (IS_NOT_NULL(tempDict, @"baseurl")) {
                    config.cBaseUrl = GET_VALUE_OBJECT(tempDict, @"baseurl");
                }
                if (IS_NOT_NULL(tempDict, @"surl")) {
                    config.cSuccessUrl = GET_VALUE_OBJECT(tempDict, @"surl");
                }
                if (IS_NOT_NULL(tempDict, @"furl")) {
                    config.cFailureUrl = GET_VALUE_OBJECT(tempDict, @"furl");
                }
                if (IS_NOT_NULL(tempDict, @"enabled")) {
                    config.cIsEnabled = GET_VALUE_BOOL(tempDict, @"enabled");
                }
                if (IS_NOT_NULL(tempDict, @"default_gateway")) {
                    config.cIsDefaultGateway = GET_VALUE_BOOL(tempDict, @"default_gateway");
                }
                if (IS_NOT_NULL(tempDict, @"title")) {
                    config.cTitle = GET_VALUE_OBJECT(tempDict, @"title");
                }
                [addons.addonPayments addObject:config];
            }
            else if ([gateway isEqualToString:[@"conektacard" lowercaseString]]) {
                ConektaCardConfig* config = [ConektaCardConfig sharedManager];
                if (IS_NOT_NULL(tempDict, @"baseurl")) {
                    config.cBaseUrl = GET_VALUE_OBJECT(tempDict, @"baseurl");
                }
                if (IS_NOT_NULL(tempDict, @"surl")) {
                    config.cSuccessUrl = GET_VALUE_OBJECT(tempDict, @"surl");
                }
                if (IS_NOT_NULL(tempDict, @"furl")) {
                    config.cFailureUrl = GET_VALUE_OBJECT(tempDict, @"furl");
                }
                if (IS_NOT_NULL(tempDict, @"enabled")) {
                    config.cIsEnabled = GET_VALUE_BOOL(tempDict, @"enabled");
                }
                if (IS_NOT_NULL(tempDict, @"default_gateway")) {
                    config.cIsDefaultGateway = GET_VALUE_BOOL(tempDict, @"default_gateway");
                }
                if (IS_NOT_NULL(tempDict, @"title")) {
                    config.cTitle = GET_VALUE_OBJECT(tempDict, @"title");
                }
                [addons.addonPayments addObject:config];
            }
            else if ([gateway isEqualToString:[@"braintree" lowercaseString]]) {
                BraintreeConfig* config = [BraintreeConfig sharedManager];
                if (IS_NOT_NULL(tempDict, @"baseurl")) {
                    config.cBaseUrl = GET_VALUE_OBJECT(tempDict, @"baseurl");
                }
                if (IS_NOT_NULL(tempDict, @"surl")) {
                    config.cSuccessUrl = GET_VALUE_OBJECT(tempDict, @"surl");
                }
                if (IS_NOT_NULL(tempDict, @"furl")) {
                    config.cFailureUrl = GET_VALUE_OBJECT(tempDict, @"furl");
                }
                if (IS_NOT_NULL(tempDict, @"enabled")) {
                    config.cIsEnabled = GET_VALUE_BOOL(tempDict, @"enabled");
                }
                if (IS_NOT_NULL(tempDict, @"default_gateway")) {
                    config.cIsDefaultGateway = GET_VALUE_BOOL(tempDict, @"default_gateway");
                }
                if (IS_NOT_NULL(tempDict, @"title")) {
                    config.cTitle = GET_VALUE_OBJECT(tempDict, @"title");
                }
                [addons.addonPayments addObject:config];
            }
            else if ([gateway isEqualToString:[@"MyGate" lowercaseString]]) {
                MyGateConfig* config = [MyGateConfig sharedManager];
                if (IS_NOT_NULL(tempDict, @"baseurl")) {
                    config.cBaseUrl = GET_VALUE_OBJECT(tempDict, @"baseurl");
                }
                if (IS_NOT_NULL(tempDict, @"surl")) {
                    config.cSuccessUrl = GET_VALUE_OBJECT(tempDict, @"surl");
                }
                if (IS_NOT_NULL(tempDict, @"furl")) {
                    config.cFailureUrl = GET_VALUE_OBJECT(tempDict, @"furl");
                }
                if (IS_NOT_NULL(tempDict, @"enabled")) {
                    config.cIsEnabled = GET_VALUE_BOOL(tempDict, @"enabled");
                }
                if (IS_NOT_NULL(tempDict, @"default_gateway")) {
                    config.cIsDefaultGateway = GET_VALUE_BOOL(tempDict, @"default_gateway");
                }
                if (IS_NOT_NULL(tempDict, @"title")) {
                    config.cTitle = GET_VALUE_OBJECT(tempDict, @"title");
                }
                [addons.addonPayments addObject:config];
            }
            else if ([gateway isEqualToString:[@"AuthorizeNet" lowercaseString]]) {
                AuthorizeNetConfig* config = [AuthorizeNetConfig sharedManager];
                if (IS_NOT_NULL(tempDict, @"baseurl")) {
                    config.cBaseUrl = GET_VALUE_OBJECT(tempDict, @"baseurl");
                }
                if (IS_NOT_NULL(tempDict, @"surl")) {
                    config.cSuccessUrl = GET_VALUE_OBJECT(tempDict, @"surl");
                }
                if (IS_NOT_NULL(tempDict, @"furl")) {
                    config.cFailureUrl = GET_VALUE_OBJECT(tempDict, @"furl");
                }
                if (IS_NOT_NULL(tempDict, @"enabled")) {
                    config.cIsEnabled = GET_VALUE_BOOL(tempDict, @"enabled");
                }
                if (IS_NOT_NULL(tempDict, @"default_gateway")) {
                    config.cIsDefaultGateway = GET_VALUE_BOOL(tempDict, @"default_gateway");
                }
                if (IS_NOT_NULL(tempDict, @"title")) {
                    config.cTitle = GET_VALUE_OBJECT(tempDict, @"title");
                }
                [addons.addonPayments addObject:config];
            }
            else if ([gateway isEqualToString:[@"dusupay" lowercaseString]]) {
                DusupayConfig* config = [DusupayConfig sharedManager];
                if (IS_NOT_NULL(tempDict, @"merchant_id")) {
                    config.cMerchantId = GET_VALUE_OBJECT(tempDict, @"merchant_id");
                }
                if (IS_NOT_NULL(tempDict, @"success_url")) {
                    config.cSuccessUrl= GET_VALUE_OBJECT(tempDict, @"success_url");
                }
                if (IS_NOT_NULL(tempDict, @"redirect_url")) {
                    config.cRedirectUrl = GET_VALUE_OBJECT(tempDict, @"redirect_url");
                }
                if (IS_NOT_NULL(tempDict, @"default_gateway")) {
                    config.cIsDefaultGateway = GET_VALUE_BOOL(tempDict, @"default_gateway");
                }
                if (IS_NOT_NULL(tempDict, @"enabled")) {
                    config.cIsEnabled = GET_VALUE_BOOL(tempDict, @"enabled");
                }
                if (IS_NOT_NULL(tempDict, @"sandbox_mode")) {
                    config.cIsSandboxMode = GET_VALUE_BOOL(tempDict, @"sandbox_mode");
                }
                //                config.cIsDefaultGateway = true;
                if (IS_NOT_NULL(tempDict, @"title")) {
                    config.cTitle = GET_VALUE_OBJECT(tempDict, @"title");
                }
                [addons.addonPayments addObject:config];
            }
            else if ([gateway isEqualToString:[@"CCAvenue" lowercaseString]]) {
                //            else if([gateway compare:@"CCAvenue" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                @try {
                    CCAvenueConfig* config = [CCAvenueConfig getInstance];
                    config.gateway = gateway;
                    config.merchantId = GET_VALUE_STRING(tempDict, @"merchant_id");
                    config.accessCode = GET_VALUE_STRING(tempDict, @"access_code");
                    config.redirectUrl = GET_VALUE_STRING(tempDict, @"redirect_url");
                    config.cancelUrl = GET_VALUE_STRING(tempDict, @"cancel_url");
                    config.rsaKeyUrl = GET_VALUE_STRING(tempDict, @"rsa_key_url");
                    config.enabled = GET_VALUE_BOOL(tempDict, @"enabled");
                    config.cIsEnabled = GET_VALUE_BOOL(tempDict, @"enabled");
                    [addons.addonPayments addObject:config];
                } @catch (NSException *exception) {
                    RLOG(@"Error while parsing CCAvenue JSON data : %@", exception.reason);
                }
            }
        }
    }
    if (IS_NOT_NULL(dict, @"shipping")) {
        @try {
            NSArray* shippingData = GET_VALUE_OBJ(dict, @"shipping");
            for (NSDictionary* shipping in shippingData) {
                NSString* provider = GET_VALUE_STR(shipping, @"provider");
                if([provider compare:@"aftership" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                    AfterShipConfig* shippingConfig = [[AfterShipConfig alloc] init];
                    shippingConfig.provider = provider;
                    shippingConfig.trackingUrl = GET_VALUE_STR(shipping, @"tracking_url");
                    addons.afterShipConfig = shippingConfig;
                    addons.enable_shipment_tracking = true;
                }
                //                else if([provider compare:@"rajaongkir" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                //                    RajaOngkirConfig* shippingConfig = [[RajaOngkirConfig alloc] init];
                //                    shippingConfig.provider = provider;
                //                    shippingConfig.shippingKey = GET_VALUE_STR(shipping, @"key");
                //                    shippingConfig.minimumWeight = GET_VALUE_INT(shipping, @"minimum_weight");
                //                    shippingConfig.defaultWeight = GET_VALUE_INT(shipping, @"default_weight");
                //                    addons.rajaOngkirConfig = shippingConfig;
                //                    addons.enable_shipment_tracking = true;
                //                }
            }
        } @catch (NSException *exception) {
            RLOG(@"Error while parsing shipping data : %@", exception.reason);
        }
    }

    //default config is added.
    //    [addons.shippingConfigs removeAllObjects];
    //    ShippingConfigWooCommerce* config = [ShippingConfigWooCommerce getInstance];
    //    [addons.shippingConfigs addObject:config];
    //
    if (IS_NOT_NULL(dict, @"shipping")) {
        NSArray* shippingArray = GET_VALUE_OBJECT(dict, @"shipping");
        for (NSDictionary* tempDict in shippingArray) {
            NSString* provider = @"";
            if (IS_NOT_NULL(tempDict, @"provider")) {
                provider = GET_VALUE_OBJECT(tempDict, @"provider");
            }
            if ([provider isEqualToString:@"woocommerce"]) {
                ShippingConfigWooCommerce* config = [ShippingConfigWooCommerce getInstance];
                if (IS_NOT_NULL(tempDict, @"enabled")) {
                    config.cIsEnabled = GET_VALUE_BOOL(tempDict, @"enabled");
                }
                //                [addons.shippingConfigs addObject:config];//this config is added by default. no need to add here.
            }
            else if ([provider isEqualToString:@"rajaongkir"]) {
                ShippingConfigRajaongkir* config = [ShippingConfigRajaongkir getInstance];
                if (IS_NOT_NULL(tempDict, @"key")) {
                    config.cKey = GET_VALUE_OBJECT(tempDict, @"key");
                }
                if (IS_NOT_NULL(tempDict, @"minimum_weight")) {
                    config.cMinWeight = GET_VALUE_FLOAT(tempDict, @"minimum_weight");
                }
                if (IS_NOT_NULL(tempDict, @"default_weight")) {
                    config.cDefaultWeight = GET_VALUE_FLOAT(tempDict, @"default_weight");
                }
                if (IS_NOT_NULL(tempDict, @"enabled")) {
                    config.cIsEnabled = GET_VALUE_BOOL(tempDict, @"enabled");
                }
                [addons.shippingConfigs addObject:config];
            }
        }
    }



    if (addons.use_multiple_shipping_addresses) {
        if (!(addons.geoLocation && addons.geoLocation.isEnabled)) {
            addons.use_multiple_shipping_addresses = false;
        }
    }
}

- (void)parseAndLoadGuestConfig:(NSDictionary*)dict {
    if (dict == nil || ![dict isKindOfClass:[NSDictionary class]]) {
        return;
    }
    GuestConfig* gc = [GuestConfig sharedInstance];
    if (IS_NOT_NULL(dict, @"enable_cart")) {
        gc.enable_cart = GET_VALUE_BOOL(dict, @"enable_cart");
    }
    if (IS_NOT_NULL(dict, @"prevent_cart")) {
        gc.prevent_cart = GET_VALUE_BOOL(dict, @"prevent_cart");
    }
    if (IS_NOT_NULL(dict, @"prevent_wishlist")) {
        gc.prevent_wishlist = GET_VALUE_BOOL(dict, @"prevent_wishlist");
    }
    if (IS_NOT_NULL(dict, @"hide_price")) {
        gc.hide_price = GET_VALUE_BOOL(dict, @"hide_price");
    }
    if (IS_NOT_NULL(dict, @"guest_checkout")) {
#if ENABLE_GUEST_CHECKOUT
        gc.guest_checkout = GET_VALUE_BOOL(dict, @"guest_checkout");
#endif
    }
    if (IS_NOT_NULL(dict, @"restricted_categories")) {
        gc.restricted_categories = [[NSMutableArray alloc] initWithArray:GET_VALUE_OBJECT(dict, @"restricted_categories")];
    }
}


- (void)parseAndLoadProductDetailsConfig:(NSDictionary*)dict {
    if (dict == nil || ![dict isKindOfClass:[NSDictionary class]]) {
        return;
    }

    ProductDetailsConfig* pdc = [ProductDetailsConfig sharedInstance];
    if (IS_NOT_NULL(dict, @"show_top_section")) {
        pdc.show_top_section = GET_VALUE_BOOL(dict, @"show_top_section");
    }
    if (IS_NOT_NULL(dict, @"show_image_slider")) {
        pdc.show_image_slider = GET_VALUE_BOOL(dict, @"show_image_slider");
    }
    if (IS_NOT_NULL(dict, @"show_share_button")) {
        pdc.show_share_button = GET_VALUE_BOOL(dict, @"show_share_button");
    }
    if (IS_NOT_NULL(dict, @"show_zoom_button")) {
        pdc.show_zoom_button = GET_VALUE_BOOL(dict, @"show_zoom_button");
    }
    if (IS_NOT_NULL(dict, @"show_combo_section")) {
        pdc.show_combo_section = GET_VALUE_BOOL(dict, @"show_combo_section");
    }
    if (IS_NOT_NULL(dict, @"show_product_title")) {
        pdc.show_product_title = GET_VALUE_BOOL(dict, @"show_product_title");
    }
    if (IS_NOT_NULL(dict, @"show_short_desc")) {
        pdc.show_short_desc = GET_VALUE_BOOL(dict, @"show_short_desc");
    }
    if (IS_NOT_NULL(dict, @"show_price")) {
        pdc.show_price = GET_VALUE_BOOL(dict, @"show_price");
    }
    if (IS_NOT_NULL(dict, @"show_reward_points")) {
        pdc.show_reward_points = GET_VALUE_BOOL(dict, @"show_reward_points");
    }
    if (IS_NOT_NULL(dict, @"show_variation_section")) {
        pdc.show_variation_section = GET_VALUE_BOOL(dict, @"show_variation_section");
    }
    if (IS_NOT_NULL(dict, @"show_quick_cart_section")) {
        pdc.show_quick_cart_section = GET_VALUE_BOOL(dict, @"show_quick_cart_section");
    }
    if (IS_NOT_NULL(dict, @"show_button_section")) {
        pdc.show_button_section = GET_VALUE_BOOL(dict, @"show_button_section");
    }
    if (IS_NOT_NULL(dict, @"show_opinion_section")) {
        pdc.show_opinion_section = GET_VALUE_BOOL(dict, @"show_opinion_section");
    }
    if (IS_NOT_NULL(dict, @"show_waitlist_section")) {
        pdc.show_waitlist_section = GET_VALUE_BOOL(dict, @"show_waitlist_section");
    }
    if (IS_NOT_NULL(dict, @"show_details_section")) {
        pdc.show_details_section = GET_VALUE_BOOL(dict, @"show_details_section");
    }
    if (IS_NOT_NULL(dict, @"show_full_description")) {
        pdc.show_full_description = GET_VALUE_BOOL(dict, @"show_full_description");
    }
    if (IS_NOT_NULL(dict, @"show_show_more")) {
        pdc.show_show_more = GET_VALUE_BOOL(dict, @"show_show_more");
    }
    if (IS_NOT_NULL(dict, @"show_ratings_section")) {
        pdc.show_ratings_section = GET_VALUE_BOOL(dict, @"show_ratings_section");
    }
    if (IS_NOT_NULL(dict, @"show_reviews_section")) {
        pdc.show_reviews_section = GET_VALUE_BOOL(dict, @"show_reviews_section");
    }
    if (IS_NOT_NULL(dict, @"show_upsell_section")) {
        pdc.show_upsell_section = GET_VALUE_BOOL(dict, @"show_upsell_section");
    }
    if (IS_NOT_NULL(dict, @"product_short_desc_max_line")) {
        pdc.product_short_desc_max_line = GET_VALUE_INT(dict, @"product_short_desc_max_line");
    }
    if (IS_NOT_NULL(dict, @"show_related_section")) {
        pdc.show_related_section = GET_VALUE_BOOL(dict, @"show_related_section");
    }
    if (IS_NOT_NULL(dict, @"tap_to_exit")) {
        pdc.tap_to_exit = GET_VALUE_BOOL(dict, @"tap_to_exit");
    }
    if (IS_NOT_NULL(dict, @"show_brand_names")) {
        pdc.show_brand_names = GET_VALUE_BOOL(dict, @"show_brand_names");
    }
    if (IS_NOT_NULL(dict, @"show_price_labels")) {
        pdc.show_price_labels = GET_VALUE_BOOL(dict, @"show_price_labels");
    }
    if (IS_NOT_NULL(dict, @"show_quantity_rules")) {
        pdc.show_quantity_rules = GET_VALUE_BOOL(dict, @"show_quantity_rules");
    }
    if (IS_NOT_NULL(dict, @"show_vertical_layout_components")) {
        pdc.show_vertical_layout_components = GET_VALUE_BOOL(dict, @"show_vertical_layout_components");
    }
    if (IS_NOT_NULL(dict, @"show_full_share_section")) {
        pdc.show_full_share_section = GET_VALUE_BOOL(dict, @"show_full_share_section");
    }
    if (IS_NOT_NULL(dict, @"show_buy_button_description")) {
        pdc.show_buy_button_description = GET_VALUE_BOOL(dict, @"show_buy_button_description");
    }
    if (IS_NOT_NULL(dict, @"select_variation_with_button")) {
        pdc.select_variation_with_button = GET_VALUE_BOOL(dict, @"select_variation_with_button");
    }
    if (IS_NOT_NULL(dict, @"show_additional_info")) {
        pdc.show_additional_info = GET_VALUE_BOOL(dict, @"show_additional_info");
    }
    if (IS_NOT_NULL(dict, @"img_slider_height_ratio")) {
        pdc.img_slider_height_ratio = GET_VALUE_FLOAT(dict, @"img_slider_height_ratio");
    }
    if (IS_NOT_NULL(dict, @"contact_numbers")) {
        id contact_numbersArray = GET_VALUE_OBJECT(dict, @"contact_numbers");
        if ([contact_numbersArray isKindOfClass:[NSArray class]]) {
            //            NSMutableArray * cc = [[NSMutableArray alloc] initWithArray:contact_numbersArray];
            //            [cc addObject:@"234123412"];
            //            [cc addObject:@"897948759"];
            //            pdc.contact_numbers = cc;

            pdc.contact_numbers = contact_numbersArray;
        }
    }
}

- (void)registerParseAnalytics:(NSDictionary*)params{
    //    dispatch_async(dispatch_get_main_queue(), ^{
    NSString* update_catalog_data = @"update_catalog_data";

    [PFCloud callFunctionInBackground:update_catalog_data
                       withParameters:params
                                block:^(NSArray *results, NSError *error) {
                                    if (!error) {
                                        // this is where you handle the results and change the UI.
                                        RLOG(@"registerParseAnalytics:succeed");
                                    }else{
                                        RLOG(@"registerParseAnalytics:failed");
                                    }
                                }];
    //    });
}
- (void)registerParseWishlistProduct:(int)productId categoryId:(int)categoryId increment:(int)increment{
    @try {
        NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
        [params setValue:@"Product_Data" forKey:@"catalog_class_name"];
        [params setValue:@"Product_Id" forKey:@"catalog_name"];
        [params setValue:[NSString stringWithFormat:@"%d",productId] forKey:@"catalog_value"];
        ProductInfo* product = [ProductInfo getProductWithId:productId];
        NSString* productName = product._title;
        NSString* productParentName = @"";
        NSString* productParentId = @"";
        if (product._categories != nil && (int)[product._categories count] > 0) {
            productParentName = ((CategoryInfo*)[product._categories objectAtIndex:0])._name;
            productParentId = [NSString stringWithFormat:@"%d", ((CategoryInfo*)[product._categories objectAtIndex:0])._id];
        }
        NSMutableDictionary* info = [[NSMutableDictionary alloc] init];
        [info setValue:productName forKey:@"Product_Name"];
        [info setValue:productParentId forKey:@"Category_Id"];
        [info setValue:productParentName forKey:@"Category_Name"];
        [info setValue:[NSNumber numberWithInt:increment] forKey:@"#Current_day_wish_added"];
        [params setValue:info forKey:@"catalog_Obj"];
        [self registerParseAnalytics:params];
    }
    @catch (NSException *exception) {
        RLOG(@"%@", exception.reason);
    }

    if(categoryId != -1) {
        @try {
            NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
            [params setValue:@"Category_Data" forKey:@"catalog_class_name"];
            [params setValue:@"Category_Id" forKey:@"catalog_name"];
            [params setValue:[NSString stringWithFormat:@"%d", categoryId] forKey:@"catalog_value"];
            CategoryInfo* category = [CategoryInfo getWithId:categoryId];
            NSString* categoryName = category._name;
            NSString* categoryParentName = @"";
            NSString* categoryParentId = @"";
            if (category._parent != nil) {
                categoryParentName = category._parent._name;
                categoryParentId = [NSString stringWithFormat:@"%d", category._parent._id];
            }
            NSMutableDictionary* info = [[NSMutableDictionary alloc] init];
            [info setValue:categoryName forKey:@"Category_Name"];
            [info setValue:categoryParentId forKey:@"Category_Parent_Id"];
            [info setValue:categoryParentName forKey:@"Category_Parent_Name"];
            [info setValue:[NSNumber numberWithInt:increment] forKey:@"#Current_Day_wish_added"];
            [params setValue:info forKey:@"catalog_Obj"];
            [self registerParseAnalytics:params];
        }
        @catch (NSException *exception) {
            RLOG(@"%@", exception.reason);
        }

    }
}
- (void)registerParseCartProduct:(int)productId categoryId:(int)categoryId increment:(int)increment{
    @try {
        NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
        [params setValue:@"Product_Data" forKey:@"catalog_class_name"];
        [params setValue:@"Product_Id" forKey:@"catalog_name"];
        [params setValue:[NSString stringWithFormat:@"%d", productId] forKey:@"catalog_value"];
        ProductInfo* product = [ProductInfo getProductWithId:productId];
        NSString* productName = product._title;
        NSString* productParentName = @"";
        NSString* productParentId = @"";
        if (product._categories != nil && (int)[product._categories count] > 0) {
            productParentName = ((CategoryInfo*)[product._categories objectAtIndex:0])._name;
            productParentId = [NSString stringWithFormat:@"%d", ((CategoryInfo*)[product._categories objectAtIndex:0])._id];
        }
        NSMutableDictionary* info = [[NSMutableDictionary alloc] init];
        [info setValue:productName forKey:@"Product_Name"];
        [info setValue:productParentId forKey:@"Category_Id"];
        [info setValue:productParentName forKey:@"Category_Name"];
        [info setValue:[NSNumber numberWithInt:increment] forKey:@"#Current_day_cart_added"];
        [params setValue:info forKey:@"catalog_Obj"];
        [self registerParseAnalytics:params];
    }
    @catch (NSException *exception) {
        RLOG(@"%@", exception.reason);
    }

    if(categoryId != -1) {
        @try {
            NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
            [params setValue:@"Category_Data" forKey:@"catalog_class_name"];
            [params setValue:@"Category_Id" forKey:@"catalog_name"];
            [params setValue:[NSString stringWithFormat:@"%d", categoryId] forKey:@"catalog_value"];
            CategoryInfo* category = [CategoryInfo getWithId:categoryId];
            NSString* categoryName = category._name;
            NSString* categoryParentName = @"";
            NSString* categoryParentId = @"";
            if (category._parent != nil) {
                categoryParentName = category._parent._name;
                categoryParentId = [NSString stringWithFormat:@"%d", category._parent._id];
            }
            NSMutableDictionary* info = [[NSMutableDictionary alloc] init];
            [info setValue:categoryName forKey:@"Category_Name"];
            [info setValue:categoryParentId forKey:@"Category_Parent_Id"];
            [info setValue:categoryParentName forKey:@"Category_Parent_Name"];
            [info setValue:[NSNumber numberWithInt:increment] forKey:@"#Current_day_cart_added"];
            [params setValue:info forKey:@"catalog_Obj"];
            [self registerParseAnalytics:params];
        }
        @catch (NSException *exception) {
            RLOG(@"%@", exception.reason);
        }

    }
}
- (void)registerParseVisitProduct:(int)productId increment:(int)increment{
    @try {
        NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
        [params setValue:@"Product_Data" forKey:@"catalog_class_name"];
        [params setValue:@"Product_Id" forKey:@"catalog_name"];
        [params setValue:[NSString stringWithFormat:@"%d", productId] forKey:@"catalog_value"];
        ProductInfo* product = [ProductInfo getProductWithId:productId];
        NSString* productName = product._title;
        NSString* productParentName = @"";
        NSString* productParentId = @"";
        if (product._categories != nil && (int)[product._categories count] > 0) {
            productParentName = ((CategoryInfo*)[product._categories objectAtIndex:0])._name;
            productParentId = [NSString stringWithFormat:@"%d", ((CategoryInfo*)[product._categories objectAtIndex:0])._id];
        }
        NSMutableDictionary* info = [[NSMutableDictionary alloc] init];
        [info setValue:productName forKey:@"Product_Name"];
        [info setValue:productParentName forKey:@"Category_Name"];
        [info setValue:productParentId forKey:@"Category_Id"];
        [info setValue:[NSNumber numberWithInt:increment] forKey:@"#Current_day_Product_Visited"];
        [params setValue:info forKey:@"catalog_Obj"];
        [self registerParseAnalytics:params];
    }
    @catch (NSException *exception) {
        RLOG(@"%@", exception.reason);
    }


    ProductInfo* product = [ProductInfo getProductWithId:productId];
    int categoryId = product._parent_id;
    if(categoryId != -1) {
        @try {
            NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
            [params setValue:@"Category_Data" forKey:@"catalog_class_name"];
            [params setValue:@"Category_Id" forKey:@"catalog_name"];
            [params setValue:[NSString stringWithFormat:@"%d", categoryId] forKey:@"catalog_value"];
            CategoryInfo* category = [CategoryInfo getWithId:categoryId];
            NSString* categoryName = category._name;
            NSString* categoryParentName = @"";
            NSString* categoryParentId = @"";
            if (category._parent != nil) {
                categoryParentName = category._parent._name;
                categoryParentId = [NSString stringWithFormat:@"%d", category._parent._id];
            }
            NSMutableDictionary* info = [[NSMutableDictionary alloc] init];
            [info setValue:categoryName forKey:@"Category_Name"];
            [info setValue:categoryParentName forKey:@"Category_Parent_Name"];
            [info setValue:categoryParentId forKey:@"Category_Parent_Id"];
            [info setValue:[NSNumber numberWithInt:increment] forKey:@"#Current_day_Product_Visited"];
            [params setValue:info forKey:@"catalog_Obj"];
            [self registerParseAnalytics:params];
        }
        @catch (NSException *exception) {
            RLOG(@"%@", exception.reason);
        }
    }
}
- (void)registerParsePurchaseProduct:(int)productId categoryId:(int)categoryId quantity:(int)quantity price:(float)price{
    @try {
        NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
        [params setValue:@"Product_Data" forKey:@"catalog_class_name"];
        [params setValue:@"Product_Id" forKey:@"catalog_name"];
        [params setValue:[NSString stringWithFormat:@"%d", productId] forKey:@"catalog_value"];
        ProductInfo* product = [ProductInfo getProductWithId:productId];
        NSString* productName = product._title;
        NSString* productParentName = @"";
        NSString* productParentId = @"";
        if (product._categories != nil && (int)[product._categories count] > 0) {
            productParentName = ((CategoryInfo*)[product._categories objectAtIndex:0])._name;
            productParentId = [NSString stringWithFormat:@"%d", ((CategoryInfo*)[product._categories objectAtIndex:0])._id];
        }
        NSMutableDictionary* info = [[NSMutableDictionary alloc] init];
        [info setValue:productName forKey:@"Product_Name"];
        [info setValue:productParentName forKey:@"Category_Name"];
        [info setValue:productParentId forKey:@"Category_Id"];
        [info setValue:[NSNumber numberWithInt:quantity] forKey:@"#Current_Day_Sales"];
        [info setValue:[NSNumber numberWithFloat:price] forKey:@"#Current_Day_Revenue"];
        [params setValue:info forKey:@"catalog_Obj"];
        [self registerParseAnalytics:params];
    }
    @catch (NSException *exception) {
        RLOG(@"%@", exception.reason);
    }


    if(categoryId != -1) {
        @try {
            NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
            [params setValue:@"Category_Data" forKey:@"catalog_class_name"];
            [params setValue:@"Category_Id" forKey:@"catalog_name"];
            [params setValue:[NSString stringWithFormat:@"%d", categoryId] forKey:@"catalog_value"];
            CategoryInfo* category = [CategoryInfo getWithId:categoryId];
            NSString* categoryName = category._name;
            NSString* categoryParentName = @"";
            NSString* categoryParentId = @"";
            if (category._parent != nil) {
                categoryParentName = category._parent._name;
                categoryParentId = [NSString stringWithFormat:@"%d", category._parent._id];
            }
            NSMutableDictionary* info = [[NSMutableDictionary alloc] init];
            [info setValue:categoryName forKey:@"Category_Name"];
            [info setValue:categoryParentName forKey:@"Category_Parent_Name"];
            [info setValue:categoryParentId forKey:@"Category_Parent_Id"];
            [info setValue:[NSNumber numberWithInt:quantity] forKey:@"#Current_Day_Sales"];
            [info setValue:[NSNumber numberWithFloat:price] forKey:@"#Current_Day_Revenue"];
            [params setValue:info forKey:@"catalog_Obj"];
            [self registerParseAnalytics:params];
        }
        @catch (NSException *exception) {
            RLOG(@"%@", exception.reason);
        }

    }
}
- (void)registerParseVisitCategory:(int)categoryId increment:(int)increment{
    @try {
        NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
        [params setValue:@"Category_Data" forKey:@"catalog_class_name"];
        [params setValue:@"Category_Id" forKey:@"catalog_name"];
        [params setValue:[NSString stringWithFormat:@"%d", categoryId] forKey:@"catalog_value"];
        CategoryInfo* category = [CategoryInfo getWithId:categoryId];
        NSString* categoryName = category._name;
        NSString* categoryParentName = @"";
        NSString* categoryParentId = @"";
        if (category._parent != nil) {
            categoryParentName = category._parent._name;
            categoryParentId = [NSString stringWithFormat:@"%d", category._parent._id];
        }
        NSMutableDictionary* info = [[NSMutableDictionary alloc] init];
        [info setValue:categoryName forKey:@"Category_Name"];
        [info setValue:categoryParentName forKey:@"Category_Parent_Name"];
        [info setValue:categoryParentId forKey:@"Category_Parent_Id"];
        [info setValue:[NSNumber numberWithInt:increment] forKey:@"#Current_Day_Category_Visit"];
        [params setValue:info forKey:@"catalog_Obj"];
        [self registerParseAnalytics:params];
    }
    @catch (NSException *exception) {
        RLOG(@"%@", exception.reason);
    }
}
- (void)registerOrder:(Order*)order{
    @try {
        NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
        [params setValue:@"Order_Data" forKey:@"catalog_class_name"];
        [params setValue:@"Order_Id" forKey:@"catalog_name"];
        [params setValue:[NSString stringWithFormat:@"%d", order._id] forKey:@"catalog_value"];

        AppUser* appUser = [AppUser sharedManager];
        NSString* userId = [NSString stringWithFormat:@"%d", appUser._id];
        NSString* userName = [NSString stringWithFormat:@"%@", appUser._username];
        NSString* status = [NSString stringWithFormat:@"%@", order._status];
        NSMutableDictionary* info = [[NSMutableDictionary alloc] init];
        [info setValue:userId forKey:@"User_Id"];
        [info setValue:userName forKey:@"User_Name"];
        [info setValue:status forKey:@"Status"];
        [info setValue:order._created_at forKey:@"Purchase_Date"];
        [info setValue:[NSNumber numberWithFloat:[order._total floatValue]] forKey:@"Amount"];
        [params setValue:info forKey:@"catalog_Obj"];
        [self registerParseAnalytics:params];
    }
    @catch (NSException *exception) {
        RLOG(@"%@", exception.reason);
    }
}
- (void)fetchAllOpinionPoll {

    AppUser* appUser = [AppUser sharedManager];
    [appUser._needProductsArrayForOpinion removeAllObjects];
    [appUser._opinionArray removeAllObjects];
    PFQuery *query = [PFQuery queryWithClassName:PClassPollData];
    [query whereKey:@"user_id" equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(error == nil) {
            if((int)[objects count] > 0) {
                for (PFObject *pfObject in objects) {
                    int productId = [[pfObject valueForKey:@"product_id"] intValue];
                    int likeCount = [[pfObject valueForKey:@"likes"] intValue];
                    int dislikeCount = [[pfObject valueForKey:@"unlikes"] intValue];
                    NSString* pollId = [pfObject objectId];
                    [Opinion addProduct:productId pollId:pollId likeCount:likeCount dislikeCount:dislikeCount];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"FETCH_ALL_OPINION" object:nil];
            }
            [[[DataManager sharedManager] tmDataDoctor] fetchMoreProductsDataFromPlugin];
        }
    }];
}
- (void)fetchOpinionPoll:(ProductInfo*)pInfo {
    PFQuery *query = [PFQuery queryWithClassName:PClassPollData];
    [query whereKey:@"product_id" equalTo: [NSString stringWithFormat:@"%d", pInfo._id]];
    [query whereKey:@"user_id" equalTo:[PFUser currentUser]];
    [query setLimit:1];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(error == nil) {
            if((int)[objects count] > 0) {
                PFObject *pfObject = [objects objectAtIndex:0];
                int productId = [[pfObject valueForKey:@"product_id"] intValue];
                int likeCount = [[pfObject valueForKey:@"likes"] intValue];
                int dislikeCount = [[pfObject valueForKey:@"unlikes"] intValue];
                NSString* pollId = [pfObject objectId];
                [Opinion addProduct:productId pollId:pollId likeCount:likeCount dislikeCount:dislikeCount];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"FETCH_OPINION" object:nil];
            }
        }
    }];
}
- (void)registerOpinionPoll:(ProductInfo*)pInfo {
    NSString *productUrl = [NSString stringWithFormat:@"%@/?p=%d",[[[DataManager sharedManager] tmDataDoctor] baseUrl], pInfo._id];

    PFQuery *query = [PFQuery queryWithClassName:PClassPollData];
    [query whereKey:@"product_id" equalTo: [NSString stringWithFormat:@"%d", pInfo._id]];
    [query whereKey:@"user_id" equalTo:[PFUser currentUser]];
    [query setLimit:1];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(error == nil) {
            if((int)[objects count] > 0) {
                [[Utility sharedManager] shareOpinionButtonClicked:pInfo pollId:[[objects objectAtIndex:0] objectId] productUrl:productUrl];
            } else {
                //                showProgress("Updating Opinion data..");
                PFObject *pfObject = [PFObject objectWithClassName:PClassPollData];
                [pfObject setObject:[PFUser currentUser] forKey:@"user_id"];
                [pfObject setObject: [NSString stringWithFormat:@"%d", pInfo._id] forKey:@"product_id"];
                [pfObject setObject:[NSNumber numberWithInt:0] forKey:@"likes"];
                [pfObject setObject:[NSNumber numberWithInt:0] forKey:@"unlikes"];
                [pfObject setObject:[NSNumber numberWithInt:0] forKey:@"operated"];
                [pfObject setObject:[NSNumber numberWithBool:true] forKey:@"is_active"];
                [pfObject setObject:productUrl forKey:@"product_url"];
                [pfObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if(error == nil) {
                        if (succeeded) {
                            [[Utility sharedManager] shareOpinionButtonClicked:pInfo pollId:[pfObject objectId] productUrl:productUrl];
                        }else{
                            //                        hideProgress(false);
                            RLOG(@"failed");
                        }

                    } else {
                        //                        hideProgress(false);
                        RLOG(@"error =%@", error);
                    }
                }];
            }
        } else {
            //                        hideProgress(false);
            RLOG(@"error =%@", error);
        }
    }];


}
- (void)registerCustomer{
    @try {
        AppUser* appUser = [AppUser sharedManager];
        NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
        [params setValue:@"CustomerData" forKey:@"catalog_class_name"];
        [params setValue:@"EmailID" forKey:@"catalog_name"];
        [params setValue:[NSString stringWithFormat:@"%@", appUser._email] forKey:@"catalog_value"];

        NSString* appName = @"TMStoreDemo";
        NSString* userName = [NSString stringWithFormat:@"%@", appUser._username];
        NSString* firstName = [NSString stringWithFormat:@"%@", appUser._first_name];
        NSString* lastName = [NSString stringWithFormat:@"%@", appUser._last_name];
        NSString* password = [NSString stringWithFormat:@"%@", appUser._password];
        NSString* deviceModel = @"iPad";

        NSMutableDictionary* info = [[NSMutableDictionary alloc] init];
        [info setValue:appName forKey:@"App_Name"];
        [info setValue:userName forKey:@"Username"];
        [info setValue:firstName forKey:@"FirstName"];
        [info setValue:lastName forKey:@"LastName"];
        [info setValue:password forKey:@"Password"];
        [info setValue:deviceModel forKey:@"DeviceModel"];
        [params setValue:info forKey:@"catalog_Obj"];
        [self registerParseAnalytics:params];



    }
    @catch (NSException *exception) {
        RLOG(@"%@", exception.reason);
    }

}
- (void)installDeviceOnParse {
    [[PFInstallation currentInstallation] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            PFUser* parseUser = [PFUser currentUser];
            if (parseUser != nil) {
                [parseUser setObject:[PFInstallation currentInstallation] forKey:@"installation_id"];
                [parseUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if (succeeded) {
                        RLOG(@"parseuser installation id is saved.");
                    }
                }];
            }


            PFQuery *query = [PFQuery queryWithClassName:PClassCustomerData];
            [query whereKey:@"ParseUser" equalTo:parseUser];
            [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                if (object == nil || error != nil) {
                    //create new user
                    [self createFreshUser];
                }else {
                    [[CustomerData sharedManager] setPFInstance:object];
                    [[CustomerData sharedManager] incrementCurrent_Day_App_Visit];
                    [[[CustomerData sharedManager] getPFInstance] saveInBackground];
                }
            }];
        } else {

        }
    }];
}

- (void)createFreshUser {
    CustomerData* c = [CustomerData sharedManager];
    [c setApp_Name:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"]];
    [c setDeviceModel:[[Utility sharedManager] getDeviceModel]];
    [c setParseUser:[PFUser currentUser]];
    [c setCurrent_Day_App_Visit:1];
    [c setCurrent_Day_Purchased_Amount:0];
    [[c getPFInstance] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        RLOG(@"NEW USER CREATED");
    }];
}


- (void)registerParseCustomerWishlist {
    @try {
        NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
        [params setValue:@"CustomerData" forKey:@"catalog_class_name"];
        [params setValue:@"objectId" forKey:@"catalog_name"];
        [params setValue:[[[CustomerData sharedManager] getPFInstance] objectId] forKey:@"catalog_value"];
        NSMutableDictionary* info = [[NSMutableDictionary alloc] init];
        [info setObject:[self getWishlistStringForParse] forKey:@"Current_Day_Whishlist_Items"];
        [params setValue:info forKey:@"catalog_Obj"];
        [self registerParseAnalytics:params];
    }
    @catch (NSException *exception) {
        RLOG(@"%@", exception.reason);
    }
}
- (NSMutableArray*)getWishlistStringForParse {
    NSMutableArray* jsonArray = [[NSMutableArray alloc] init];
    for (Wishlist* obj in [Wishlist getAll]) {
        NSMutableArray* object = [[NSMutableArray alloc] init];
        [object addObject:[NSString stringWithFormat:@"%d", obj.product_id]];
        [object addObject:[NSString stringWithFormat:@"%@", obj.productName]];
        [object addObject:[NSString stringWithFormat:@"%d", 1]];
        [object addObject:[NSString stringWithFormat:@"%d", obj.selectedVariationId]];
        [object addObject:[NSString stringWithFormat:@"%.2f", obj.productPrice]];
        //        [object addObject:[NSString stringWithFormat:@"%d", obj.product_id]];
        //        [object addObject:[NSString stringWithFormat:@"%@", obj.productName]];
        //        [object addObject:[NSString stringWithFormat:@"%d", 1]];
        //        [object addObject:[NSString stringWithFormat:@"%f", obj.productPrice]];
        [jsonArray addObject:object];
    }
    return jsonArray;
}
- (void)registerParseCustomerCart {
    @try {
        NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
        [params setValue:@"CustomerData" forKey:@"catalog_class_name"];
        [params setValue:@"objectId" forKey:@"catalog_name"];
        [params setValue:[[[CustomerData sharedManager] getPFInstance] objectId] forKey:@"catalog_value"];
        NSMutableDictionary* info = [[NSMutableDictionary alloc] init];
        [info setObject:[self getCartStringForParse] forKey:@"Current_Day_Cart_Items"];
        [params setValue:info forKey:@"catalog_Obj"];
        [self registerParseAnalytics:params];
    }
    @catch (NSException *exception) {
        RLOG(@"%@", exception.reason);
    }
}
- (NSMutableArray*)getCartStringForParse {
    NSMutableArray* jsonArray = [[NSMutableArray alloc] init];
    for (Cart* obj in [Cart getAll]) {
        NSMutableArray* object = [[NSMutableArray alloc] init];
        [object addObject:[NSString stringWithFormat:@"%d", obj.product_id]];
        [object addObject:[NSString stringWithFormat:@"%@", obj.productName]];
        [object addObject:[NSString stringWithFormat:@"%d", obj.count]];
        [object addObject:[NSString stringWithFormat:@"%d", obj.selectedVariationId]];
        [object addObject:[NSString stringWithFormat:@"%.2f", obj.productPrice]];
        [jsonArray addObject:object];
    }
    return jsonArray;
}


- (void)registerParseCustomerPurchase:(Order*)order {
    @try {
        NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
        [params setValue:@"CustomerData" forKey:@"catalog_class_name"];
        [params setValue:@"objectId" forKey:@"catalog_name"];
        [params setValue:[[[CustomerData sharedManager] getPFInstance] objectId] forKey:@"catalog_value"];
        NSMutableDictionary* info = [[NSMutableDictionary alloc] init];
        [info setObject:[self getPurchasedItemsStringForParse:order] forKey:@"*Current_Day_Purchased_Items"];
        [params setValue:info forKey:@"catalog_Obj"];
        [self registerParseAnalytics:params];
    }
    @catch (NSException *exception) {
        RLOG(@"%@", exception.reason);
    }
}
- (NSMutableArray*)getPurchasedItemsStringForParse:(Order*)order {
    NSMutableArray* jsonArray = [[NSMutableArray alloc] init];
    for (LineItem* obj in order._line_items) {
        NSMutableArray* object = [[NSMutableArray alloc] init];
        [object addObject:[NSString stringWithFormat:@"%d", obj._product_id]];
        [object addObject:[NSString stringWithFormat:@"%@", obj._name]];
        [object addObject:[NSString stringWithFormat:@"%d", obj._quantity]];
        [jsonArray addObject:object];
    }
    return jsonArray;
}

- (void)signInParse:(NSString*)EmailID {
    PFQuery *query = [PFQuery queryWithClassName:PClassCustomerData];
    [query whereKey:@"EmailID" equalTo:EmailID];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (error == nil || error.code == PARSE_ERROR_CODE_OBJECT_NOT_FOUND) {
            if (object == NULL) {
                RLOG(@" -- Ab tak koi bhi iss email id se login nahi hua.. app me.. --");
                AppUser *au = [AppUser sharedManager];
                [au synq];//PS. 2. in dono line ke orders se chheDkhani naa kre..
                [[CustomerData sharedManager] setEmailID:EmailID];
                [au saveAll];
            } else {
                RLOG(@" -- Bhai, ye email id ek bar app me signin ho chuka hai.. --");
                RLOG(@" -- device model : [ %@ ] --", object[@"DeviceModel"]);
                PFObject* currentAnonymousDeviceCustomer = [[CustomerData sharedManager] getPFInstance];
                RLOG(@" -- obj id 1 : [%@] --", currentAnonymousDeviceCustomer);
                [[CustomerData sharedManager] setPFInstance:object]; //PS. 1. in dono line ke orders se chheDkhani naa kre..
                PFObject* newSignedInCustomer = [[CustomerData sharedManager] getPFInstance];
                RLOG(@" -- obj id 4 : [%@] --", newSignedInCustomer);
                AppUser *au = [AppUser sharedManager];
                [au synq];//PS. 2. in dono line ke orders se chheDkhani naa kre..
                [[CustomerData sharedManager] setParseUser:[PFUser currentUser]];
                [au saveAll];
                [currentAnonymousDeviceCustomer fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
                    if (error == NULL) {
                        RLOG(@"fetchIfNeededInBackgroundWithBlock error1 = NULL");
                        [[CustomerData sharedManager] appendData:object to:newSignedInCustomer];
                        RLOG(@"fetchIfNeededInBackgroundWithBlock error2 = NULL");
                        [currentAnonymousDeviceCustomer deleteInBackground];
                        RLOG(@"fetchIfNeededInBackgroundWithBlock error3 = NULL");
                        [newSignedInCustomer saveInBackground];
                        RLOG(@"fetchIfNeededInBackgroundWithBlock error4 = NULL");
                    }else{
                        RLOG(@"fetchIfNeededInBackgroundWithBlock error = %@", error);
                    }
                }];
            }
        } else {
        }
    }];
}
- (void)registerParseCustomerUpdate {
    RLOG(@"-- registerParseCustomerUpdate --");
    @try {
        NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
        [params setValue:@"CustomerData" forKey:@"catalog_class_name"];
        [params setValue:@"objectId" forKey:@"catalog_name"];
        [params setValue:[[[CustomerData sharedManager] getPFInstance] objectId] forKey:@"catalog_value"];
        NSMutableDictionary* info = [[NSMutableDictionary alloc] init];
        [info setObject:[self getCustomerDataStringForParse] forKey:@"Customer_Data"];
        [params setValue:info forKey:@"catalog_Obj"];
        [self registerParseAnalytics:params];
    }
    @catch (NSException *exception) {
        RLOG(@"%@", exception.reason);
    }
}

- (NSString*)getCustomerDataStringForParse {
    AppUser* au = [AppUser sharedManager];
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[NSNumber numberWithInt:au._id] forKey:@"user_id"];
    [dict setObject:au._first_name forKey:@"first_name"];
    [dict setObject:au._last_name forKey:@"last_name"];
    [dict setObject:au._email forKey:@"email"];
    [dict setObject:[[Utility sharedManager] getDeviceModel] forKey:@"model"];
    [dict setObject:@"ios" forKey:@"platform"];
    [dict setObject:@"" forKey:@"gender"];

    Address* billingAddress = au._billing_address;
    if (billingAddress) {
        NSMutableDictionary *billingParams = [[NSMutableDictionary alloc]init];
        [dict setObject:billingParams forKey:@"billing_address"];
        [billingParams setObject:billingAddress._first_name forKey:@"first_name"];
        [billingParams setObject:billingAddress._last_name forKey:@"last_name"];
        //        [billingParams setObject:billingAddress._company forKey:@"company"];
        [billingParams setObject:billingAddress._address_1 forKey:@"address_1"];
        [billingParams setObject:billingAddress._address_2 forKey:@"address_2"];
        [billingParams setObject:billingAddress._city forKey:@"city"];
        [billingParams setObject:billingAddress._postcode forKey:@"postcode"];
        [billingParams setObject:billingAddress._email forKey:@"email"];
        [billingParams setObject:billingAddress._phone forKey:@"phone"];
        [billingParams setObject:billingAddress._stateId forKey:@"state"];
        [billingParams setObject:billingAddress._countryId forKey:@"country"];
    }
    NSError * err;
    NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:dict options:0 error:&err];
    NSString * dataString = [[NSString alloc] initWithData:jsonData   encoding:NSUTF8StringEncoding];
    RLOG(@"%@",dataString);
    return dataString;
}
- (void)downloadLanguageFileInBg:(NSString*)localeString {

    Addons* addons = [Addons sharedManager];
    if (addons.language && addons.language.locales && [addons.language.locales count] > 0) {
        for (int i = 0; i < (int)[addons.language.locales count]; i++) {
            if ([addons.language.locales[i] isEqualToString:localeString]) {
                if([addons.language.isDownloaded[i] boolValue]) {
                    return;
                }else{
                    break;
                }
            }
        }
    }


    PFQuery *query = [PFQuery queryWithClassName:PClassLanguage];
    [query whereKey:@"locale" equalTo:localeString];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        PFFile *languageFile = object[@"file"];
        PFFile *languageFileOld = object[@"old_file"];

        [languageFile getDataInBackgroundWithBlock:^(NSData *languageData, NSError *error1) {
            if (!error1) {
                [self saveLanguageFileToDocuments:languageData fileName:[NSString stringWithFormat:@"%@.json", localeString]];
            }
        } progressBlock:^(int percentDone) {
            RLOG(@"percentDone = %d", percentDone);
        }];

        [languageFileOld getDataInBackgroundWithBlock:^(NSData *languageDataOld, NSError *error2) {
            if (!error2) {
                [self saveLanguageFileToDocuments:languageDataOld fileName:[NSString stringWithFormat:@"%@_Old.json", localeString]];
            }
        } progressBlock:^(int percentDone) {
            RLOG(@"percentDone = %d", percentDone);
        }];

    }];
}
- (void)writeStringToFile:(NSString*)aString {
    NSString* filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* fileName = @"dynamic_layout_server.json";
    NSString* fileAtPath = [filePath stringByAppendingPathComponent:fileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileAtPath]) {
        [[NSFileManager defaultManager] createFileAtPath:fileAtPath contents:nil attributes:nil];
    }
    [[aString dataUsingEncoding:NSUTF8StringEncoding] writeToFile:fileAtPath atomically:NO];
}
- (void)downloadLanguageFile:(NSString*)localeString {
    PFQuery *query = [PFQuery queryWithClassName:PClassLanguage];
    [query whereKey:@"locale" equalTo:localeString];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        PFFile *languageFile = object[@"file"];
        PFFile *languageFileOld = object[@"old_file"];

        [languageFile getDataInBackgroundWithBlock:^(NSData *languageData, NSError *error1) {
            if (!error1) {
                [self saveLanguageFileToDocuments:languageData fileName:[NSString stringWithFormat:@"%@.json", localeString]];
                [[TMLanguage sharedManager] setUserLanguageFromParse:localeString];

                Addons* addons = [Addons sharedManager];
                if (addons.language && addons.language.locales && [addons.language.locales count] > 0) {
                    for (int i = 0; i < (int)[addons.language.locales count]; i++) {
                        if ([addons.language.locales[i] isEqualToString:localeString]) {
                            [addons.language.isDownloaded replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:YES]];
                            [[TMLanguage sharedManager] postNotification:localeString];
                            break;
                        }
                    }
                }
            }
        } progressBlock:^(int percentDone) {
            RLOG(@"percentDone = %d", percentDone);
        }];
        [languageFileOld getDataInBackgroundWithBlock:^(NSData *languageDataOld, NSError *error2) {
            if (!error2)
            {
                [self saveLanguageFileToDocuments:languageDataOld fileName:[NSString stringWithFormat:@"%@_Old.json", localeString]];
                [[TMLanguage sharedManager] setUserLanguageFromParseOld:localeString];
            }
        } progressBlock:^(int percentDone) {
            RLOG(@"percentDone = %d", percentDone);
        }];


    }];
}
- (void)saveLanguageFileToDocuments:(NSData *)languageData fileName:(NSString *)fileName {
    NSString *docsDir;
    NSArray *dirPaths;
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    NSString *databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:fileName]];
    if([languageData writeToFile:databasePath atomically:YES]){
        RLOG(@"File saved at %@", databasePath);
    }else{
        RLOG(@"File saving failed.");
    }
}

- (void)proceedSignOut {
    //    PFUser* parseUser = [PFUser currentUser];
    //    CustomerData* c = [CustomerData sharedManager];
    //    c = nil;
    //    c = [CustomerData sharedManager];
    //    [self createFreshUser];
    //    return;
    //    [[CustomerData sharedManager] setPFInstance:parseUser];
    //    [[[CustomerData sharedManager] getPFInstance] saveInBackground];


    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        if (error == nil) {
            [[PFUser currentUser] deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if (succeeded) {
                    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                        if (succeeded) {
                            if ([PFUser currentUser] != nil) {
                                [[PFUser currentUser] setObject:[PFInstallation currentInstallation] forKey:@"installation_id"];
                                [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                                    if (succeeded) {
                                        RLOG(@"parseuser installation id is saved.");
                                        PFObject *pfObjCustomerData = [PFObject objectWithClassName:PClassCustomerData];
                                        [pfObjCustomerData saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                            if (succeeded) {
                                                // The object has been saved.
                                                [[CustomerData sharedManager] setPFInstance:pfObjCustomerData];
                                                [self createFreshUser];
                                            } else {
                                                // There was a problem, check error.description
                                            }
                                        }];
                                    }
                                }];
                            }
                        }
                    }];
                }
            }];
        }

    }];
}
//public void proceedSignOut() {
//    AppUser.deleteInstance(); //Sign Out
//    ParseUser.getCurrentUser().logOutInBackground(new LogOutCallback() {
//        @Override
//        public void done(ParseException e) {
//            ParseUser.getCurrentUser().deleteInBackground(new DeleteCallback() {
//                @Override
//                public void done(ParseException e) {
//                    if (e == null) {
//                        Helper.SOUT("--previous parse user deleted successfully --");
//                        ParseUser.getCurrentUser().saveInBackground(new SaveCallback() {
//                            @Override
//                            public void done(ParseException e) {
//                                if (e == null) {
//                                    Helper.SOUT("-- new anonymous use created successfully --");
//                                    CustomerData c = new CustomerData();
//                                    CustomerData.setInstance(c);
//                                    CustomerData.getInstance().setApp_Name(getApplicationContext().getPackageName());
//                                    CustomerData.getInstance().setDeviceModel(android.os.Build.MODEL);
//                                    CustomerData.getInstance().setParseUser(ParseUser.getCurrentUser());
//                                    CustomerData.getInstance().setCurrent_Day_App_Visit(1);
//                                    CustomerData.getInstance().setCurrent_Day_Purchased_Amount(0);
//                                    CustomerData.getInstance().saveInBackground();
//                                    manageNotificationChannelsSubscription();
//                                    Cart.clearCoupons();
//                                    WishListGroup.clearAll();//To Test
//
//                                } else {
//                                    Helper.SOUT("-- new anonymous user creation failed --");
//                                    e.printStackTrace();
//                                }
//                            }
//                        });
//                    } else {
//                        Helper.SOUT("--previous parse user deletion failed --");
//                        e.printStackTrace();
//                    }
//                }
//            });
//        }
//    });
//    resetDrawer();
//}
- (void)updateNotificationReceivedCountOnParse:(NSString*)parsePushId {
    if (parsePushId != nil && ![parsePushId isEqualToString:@""]) {
        PFQuery *query = [PFQuery queryWithClassName:PClassPushNotify];
        [query getObjectInBackgroundWithId:parsePushId block:^(PFObject * _Nullable object, NSError * _Nullable error) {
            if (error == nil) {
                [object incrementKey:@"push_open"];
                [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if (succeeded) {
                        RLOG(@"Notification open event has been registered.");
                    } else {
                        if (error) {
                            RLOG(@"%@", [error localizedDescription]);
                        }
                    }
                }];
            } else {
                RLOG(@"Notification ID not found on server.");
            }
        }];
    } else {
        RLOG(@"Notification open can't be registered.");
    }
}
- (void)parseStoreConfig :(NSArray*)objects :(BOOL)isNearBySearch {

    [[StoreConfig getAllStoreConfigsForMark] removeAllObjects];
    [[StoreConfig getAllStoreConfigNearBy]removeAllObjects];


    for (PFObject* object in objects) {
        StoreConfig* sc = [[StoreConfig alloc] init];
        NSString* strPlatform = [object objectForKey:@"platform"];
        NSString* strStoreType = [object objectForKey:@"dataHost"];
        if (strStoreType == nil || (strStoreType && [strStoreType isEqualToString:@""])) {
            strStoreType = @"woocommerce";
        }
        int appType = [[object objectForKey:@"service_active"] intValue];
        id multi_store_config = [object objectForKey:@"multi_store_config"];
        id multi_store_platform = [object objectForKey:@"multi_store_platform"];

        RLOG(@"multi_store_config = %@", multi_store_config);
        RLOG(@"multi_store_platform = %@", multi_store_platform);

        if (multi_store_config && ![multi_store_config isEqualToString:@""]) {
            NSError *jsonError;
            NSData *objectData = [multi_store_config dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData options:NSJSONReadingMutableContainers error:&jsonError];
            multi_store_config = json;
        }
        if (multi_store_config && [multi_store_config isKindOfClass:[NSDictionary class]]) {
            if (IS_NOT_NULL(multi_store_config, @"enabled")) {
                sc.enabled = GET_VALUE_BOOL(multi_store_config, @"enabled");
            }
            if (IS_NOT_NULL(multi_store_config, @"is_default")) {
                sc.is_default = GET_VALUE_BOOL(multi_store_config, @"is_default");
            }
            if (IS_NOT_NULL(multi_store_config, @"title")) {
                sc.title = GET_VALUE_STRING(multi_store_config, @"title");
            }
            if (IS_NOT_NULL(multi_store_config, @"description")) {
                sc.desc = GET_VALUE_STRING(multi_store_config, @"description");
            }
            if (IS_NOT_NULL(multi_store_config, @"icon_url")) {
                sc.icon_url = GET_VALUE_STRING(multi_store_config, @"icon_url");
            }
            if (IS_NOT_NULL(multi_store_config, @"store_url")) {
                sc.store_url = GET_VALUE_STRING(multi_store_config, @"store_url");
            }
            if (IS_NOT_NULL(multi_store_config, @"location")) {
                NSDictionary* location = GET_VALUE_OBJECT(multi_store_config, @"location");
                if (location && [location isKindOfClass:[NSDictionary class]]) {
                    if (IS_NOT_NULL(location, @"latitude")) {
                        sc.latitude = GET_VALUE_FLOAT(location, @"latitude");
                    }
                    if (IS_NOT_NULL(location, @"longitude")) {
                        sc.longitude = GET_VALUE_FLOAT(location, @"longitude");
                    }
                }
            }
        }

        if (multi_store_platform && ![multi_store_platform isEqualToString:@""]) {
            sc.multi_store_platform = multi_store_platform;
        }

        sc.platform = strPlatform;
        sc.storeType = strStoreType;
        sc.appType = appType;

        //Added by me
        NSMutableArray *mapMenuOptions = [StoreConfig getAllMapMenuOptions];
        if (mapMenuOptions && mapMenuOptions.count == 0) {
            id map_menu_options = [object objectForKey:@"map_menu_options"];
            if (map_menu_options && ![map_menu_options isEqualToString:@""]) {
                NSError *jsonError;
                NSData *objectData = [map_menu_options dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData options:NSJSONReadingMutableContainers error:&jsonError];
                map_menu_options = json;

                if ([map_menu_options isKindOfClass:[NSArray class]]) {
                    for (NSDictionary* tempDict in map_menu_options) {
                        MapMenuOptions *mapMenuOption = [[MapMenuOptions alloc]init];
                        if (IS_NOT_NULL(tempDict, @"title")) {
                            mapMenuOption.title = GET_VALUE_STRING(tempDict, @"title");
                        }
                        if (IS_NOT_NULL(tempDict, @"url")) {
                            mapMenuOption.url = GET_VALUE_STRING(tempDict, @"url");
                        }
                        [mapMenuOptions addObject:mapMenuOption];
                    }
                }
            }
        }

        BOOL isValidStore = false;
        BOOL isValidStoreForMark = false;


        NSString* platformStr = @"ios";
        NSString* platformStr1 = [NSString stringWithFormat:@"%@_", platformStr];
        NSString* platformStr2 = [NSString stringWithFormat:@"_%@", platformStr];

        NSString* title = sc.title;
        if ([Utility isMultiStoreAppTMStore]) {
            if ([[sc.platform lowercaseString] isEqualToString:platformStr] ||
                [[sc.platform lowercaseString] containsString:platformStr1] ||
                [[sc.platform lowercaseString] containsString:platformStr2]) {
                isValidStore = true;
                isValidStoreForMark = true;

                title = [NSString stringWithFormat:@"%@", sc.platform];
                title = [title stringByReplacingOccurrencesOfString:platformStr1 withString:@""];
                title = [title stringByReplacingOccurrencesOfString:platformStr2 withString:@""];
                sc.title = title;
            }
        }
        else {
            if ([[sc.multi_store_platform lowercaseString] isEqualToString:platformStr] ||
                [[sc.multi_store_platform lowercaseString] containsString:platformStr1] ||
                [[sc.multi_store_platform lowercaseString] containsString:platformStr2]) {
                isValidStore = true;
                isValidStoreForMark = true;
            }
        }
        if (sc.enabled && sc.appType != APP_TYPE_INACTIVE && [[sc.storeType lowercaseString] isEqualToString:@"woocommerce"] &&isValidStore) {
            if (!isNearBySearch) {
                [[StoreConfig getAllStoreConfigs] addObject:sc];
            } else {
                [[StoreConfig getAllStoreConfigNearBy]addObject:sc];
            }
        }

        if (isValidStoreForMark) {
            [[StoreConfig getAllStoreConfigsForMark] addObject:sc];
        }

        //        if (sc.enabled &&
        //            sc.appType != APP_TYPE_INACTIVE &&
        //            [[sc.storeType lowercaseString] isEqualToString:@"woocommerce"]) {
        //            NSString* title = sc.title;
        //            if ([Utility isMultiStoreAppTMStore]) {
        //                if ([[sc.platform lowercaseString] isEqualToString:platformStr] ||
        //                    [[sc.platform lowercaseString] containsString:platformStr1] ||
        //                    [[sc.platform lowercaseString] containsString:platformStr2]) {
        //                    isValidStore = true;
        //                    title = [NSString stringWithFormat:@"%@", sc.platform];
        //                    title = [title stringByReplacingOccurrencesOfString:platformStr1 withString:@""];
        //                    title = [title stringByReplacingOccurrencesOfString:platformStr2 withString:@""];
        //                    sc.title = title;
        //                }
        //            }
        //            else {
        //                if ([[sc.multi_store_platform lowercaseString] isEqualToString:platformStr] ||
        //                    [[sc.multi_store_platform lowercaseString] containsString:platformStr1] ||
        //                    [[sc.multi_store_platform lowercaseString] containsString:platformStr2]) {
        //                    isValidStore = true;
        //                }
        //            }
        //            if (isValidStore) {
        //                [[StoreConfig getAllStoreConfigs] addObject:sc];
        //            }
        //        }
    }
}
@end
