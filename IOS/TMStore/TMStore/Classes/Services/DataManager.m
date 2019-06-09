//
//  DataManager.m
//  eCommerceApp
//
//  Created by Rishabh Jain on 01/10/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import "DataManager.h"
#import "CommonInfo.h"
#import "Utility.h"
#import "ViewControllerSplashSecondary.h"
#import "LayoutManager.h"
#import "STHTTPRequest.h"
#import "Variables.h"
#import "AppUser.h"
#import "Order.h"
#import "Variation.h"
#import "ServerData.h"
#import "ProductInfo.h"
#import "ProductImage.h"
#import "Attribute.h"
#import "CategoryInfo.h"
#import "VariousKeys.h"

@implementation DataManager
@synthesize tmDataDoctor = _tmDataDoctor;
static DataManager *sharedDataManager = nil;
+ (id)sharedManager {
    @synchronized(self) {
        if (sharedDataManager == nil)
            sharedDataManager = [[self alloc] init];
    }
    return sharedDataManager;
}
+ (void)resetManager {
    sharedDataManager = nil;
}
+ (id)getDataDoctor {
    return [[DataManager sharedManager] tmDataDoctor];
}
- (id)init {
    if (self = [super init]) {
        self.tmDataDoctor = nil;
        self.shippingEngines = [[NSMutableArray alloc] init];
        self.shippingProvider = SHIPPING_PROVIDER_WOOCOMMERCE;
        self.appType = APP_TYPE_FREE;
        self.isAppForExternalUser = true;
        self.merchantObjectId = @"";
        self.promoUrlImgPath = @"";
        self.promoUrlString = @"";
        self.promoEnable = false;
        self.showFullSizeCategoryBanner = false;
        self.maxCategoryLoadCount = 100;
        self.maxProductLoadCount = 100;
        self.isRefineCategoriesEnable = false;
        self.isAutoRefreshCategoryThumbEnable = false;
        self.isStepUpSingleChildrenCategoriesEnable = false;
        self.isAutoSigninInHiddenWebviewEnable = false;
        self.decimalSeperator = @"NONE";
        self.thousandSeperator = @"NONE";
        
        self.min_app_version = @"";
        self.current_app_version = @"";

        self.layoutIdCategoryView = 0;
        self.layoutIdProductView = 0;
        self.layoutIdHorizontalView = 0;
        self.layoutIdBannerView = 0;
        self.layoutIdProductBannerView = 0;
//        [LayoutManager sharedManager];
        
        self.locationDataFetched = false;
        self.userTempCity = @"";
        self.userTempCountry = @"";
        self.userTempPostalCode = @"";
        self.userTempState = @"";
        self.isAllFilterLoaded = false;
        self.isPriceFilterLoaded = false;
        self.isAllFilterLoaded = false;

        
        self.isShowLoginPopUpHomeScreen = false;
        _tmPaymentSDK = [[TMPaymentSDK alloc] init];
        _tmShippingSDK = [[TMShippingSDK alloc] init];
//        self.paypal_ClientId = @"";
//        
//        self.payu_merchantKey = @"";
//        self.payu_saltKey = @"";
//        self.payu_successUrl = @"";
//        self.payu_failureUrl = @"";
//        self.payu_serviceProvider = @"";
        
        if ([[NSUserDefaults standardUserDefaults] valueForKey:@"SPLASH_IMG"]) {
            self.splashUrlImgPath = [[NSUserDefaults standardUserDefaults] valueForKey:@"SPLASH_IMG"];
        } else {
            self.splashUrlImgPath = @"";
        }
        
        if ([[NSUserDefaults standardUserDefaults] valueForKey:@"SPLASH_IMG_LANDSCAPE"]) {
            self.splashUrlImgPathLandscape = [[NSUserDefaults standardUserDefaults] valueForKey:@"SPLASH_IMG_LANDSCAPE"];
        } else {
            self.splashUrlImgPathLandscape = @"";
        }
        
        if ([[NSUserDefaults standardUserDefaults] valueForKey:@"SPLASH_IMG_PORTRAIT"]) {
            self.splashUrlImgPathPortrait = [[NSUserDefaults standardUserDefaults] valueForKey:@"SPLASH_IMG_PORTRAIT"];
        } else {
            self.splashUrlImgPathPortrait = @"";
        }
        
        if ([[NSUserDefaults standardUserDefaults] valueForKey:@"SPLASH_COLOR"]) {
            self.splashTextColorString = [[NSUserDefaults standardUserDefaults] valueForKey:@"SPLASH_COLOR"];
            self.splashTextColor = [Utility colorWithHexString:self.splashTextColorString alpha:1.0f];
        } else {
            self.splashTextColorString = @"";
        }
        
        self.keyFacebookAppId = @"";
        self.keyFacebookConsumerSecret = @"";
        self.keyTwitterConsumerKey = @"";
        self.keyTwitterConsumerSecret = @"";
        self.keyGoogleClientId = @"";
        self.keyGoogleClientSecret = @"";
        self.show_tmstore_text = true;

        
        self.checkoutUrlLinkFromPlugin = @"";
        self.contactDetails = nil;
        
//        if ([Utility isMultiStoreApp]) {
//            if ([[NSUserDefaults standardUserDefaults] valueForKey:@"APPDATA_PLATFORM"]) {
//                self.appDataPlatformString = [[NSUserDefaults standardUserDefaults] valueForKey:@"APPDATA_PLATFORM"];
//            } else {
//                self.appDataPlatformString = APPDATA_PLATFORM;
//            }
//        } else {
            self.appDataPlatformString = APPDATA_PLATFORM;
//        }
        
#if ENABLE_FULL_SPLASH_ON_LAUNCH_NEW
//        if([[MyDevice sharedManager] isIphone]) {
//            float screenRatio = [[MyDevice sharedManager] screenHeightInPortrait]/[[MyDevice sharedManager] screenWidthInPortrait];
//            if (screenRatio > 1.5f) {
//                self.splashUrlImgPathPortrait = @"app_splash_1080x1920.png";//[jsonObject objectForKey:@"ios_1920_1080"];
//            } else {
//                self.splashUrlImgPathPortrait = @"app_splash_640x960.png";//[jsonObject objectForKey:@"ios_960_640"];
//            }
//            [[NSUserDefaults standardUserDefaults] setValue:self.splashUrlImgPathPortrait forKey:@"SPLASH_IMG_PORTRAIT"];
//        } else {
//            self.splashUrlImgPathPortrait = @"app_splash_768x1024.png";//[jsonObject objectForKey:@"ios_1024_768"];
//            self.splashUrlImgPathLandscape = @"app_splash_1024x768.png";//[jsonObject objectForKey:@"ios_768_1024"];
//            [[NSUserDefaults standardUserDefaults] setValue:self.splashUrlImgPathPortrait forKey:@"SPLASH_IMG_PORTRAIT"];
//            [[NSUserDefaults standardUserDefaults] setValue:self.splashUrlImgPathLandscape forKey:@"SPLASH_IMG_LANDSCAPE"];
//        }
        
        UIScreen *mainScreen = [UIScreen mainScreen];
        float sizeW = mainScreen.coordinateSpace.bounds.size.width;
        float sizeH = mainScreen.coordinateSpace.bounds.size.height;
        sizeW = mainScreen.nativeBounds.size.width;
        sizeH = mainScreen.nativeBounds.size.height;
        if (sizeW > sizeH) {
            float temp = sizeW;
            sizeW = sizeH;
            sizeH = temp;
        }
        NSLog(@"screenSize = %.f,%.f",sizeW, sizeH);
        if([[MyDevice sharedManager] isIphone]) {
            self.splashUrlImgPathPortrait = [NSString stringWithFormat:@"Launch%.fx%.f.png", sizeW, sizeH];
            [[NSUserDefaults standardUserDefaults] setValue:self.splashUrlImgPathPortrait forKey:@"SPLASH_IMG_PORTRAIT"];
            NSLog(@"self.splashUrlImgPathPortrait = %@",self.splashUrlImgPathPortrait);
        } else {
            self.splashUrlImgPathPortrait = [NSString stringWithFormat:@"Launch%.fx%.f.png", sizeW, sizeH];
            [[NSUserDefaults standardUserDefaults] setValue:self.splashUrlImgPathPortrait forKey:@"SPLASH_IMG_PORTRAIT"];
            NSLog(@"self.splashUrlImgPathPortrait = %@",self.splashUrlImgPathPortrait);
            
            self.splashUrlImgPathLandscape = [NSString stringWithFormat:@"Launch%.fx%.f.png", sizeH, sizeW];
            [[NSUserDefaults standardUserDefaults] setValue:self.splashUrlImgPathLandscape forKey:@"SPLASH_IMG_LANDSCAPE"];
            NSLog(@"self.splashUrlImgPathLandscape = %@",self.splashUrlImgPathLandscape);
        }
#endif
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

#pragma mark Load Data From Server
- (void)loadCustomerData:(NSDictionary*)dictionary {
    [[_tmDataDoctor tmJsonHelper] loadCustomerData:dictionary];
}
- (void)loadOrdersData:(NSDictionary *)dictionary {
    [[_tmDataDoctor tmJsonHelper] loadOrdersData:dictionary];
}
- (void)loadCategoriesData:(NSDictionary *)dictionary {
    [[_tmDataDoctor tmJsonHelper] loadCategoriesData:dictionary];
}
- (NSMutableArray*)loadProductsData:(NSDictionary *)dictionary {
    return [[_tmDataDoctor tmJsonHelper] loadProductsData:dictionary];
}
- (ProductInfo*)loadSingleProductData:(NSDictionary *)dictionary {
    return [[_tmDataDoctor tmJsonHelper] loadSingleProductData:dictionary];
}
- (void)loadSingleProductReviewData:(NSDictionary *)dictionary product:(ProductInfo*)product {
    return [[_tmDataDoctor tmJsonHelper] loadSingleProductReviewData:dictionary product:product];
}
- (void)loadCommonData:(NSDictionary *)dictionary {
    [[_tmDataDoctor tmJsonHelper] loadCommonData:dictionary];
}
- (ServerData*)fetchCommonData:(UIView*)view {
    return [_tmDataDoctor fetchCommonData:view];
}
- (ServerData*)fetchCategoriesData:(UIView*)view {
    return [_tmDataDoctor fetchCategoriesData:view];
}
- (ServerData*)fetchProductData:(UIView*)view {
    return [_tmDataDoctor fetchProductData:view];
}
- (ServerData*)fetchCustomerData:(UIView*)view userEmail:(NSString*)userEmail {
    return [_tmDataDoctor fetchCustomerData:view userEmail:userEmail];
}
- (ServerData*)fetchOrdersData:(UIView*)view {
    return [_tmDataDoctor fetchOrdersData:view];
}
- (ServerData*)fetchCouponsData:(UIView*)view {
    return [_tmDataDoctor fetchCouponsData:view];
}
- (ServerData*)fetchSingleProductData:(UIView*)view  productId:(int)productId{
    return [_tmDataDoctor fetchSingleProductData:view productId:productId];
}
- (ServerData*)fetchSingleProductDataReviews:(UIView*)view  productId:(int)productId{
    return [_tmDataDoctor fetchSingleProductDataReviews:view productId:productId];
}
- (ServerData*)fetchProductsWithTag:(UIView*)view tag:(NSString*)tag offset:(int)offset productCount:(int)productCount {
    return [_tmDataDoctor fetchProductsWithTag:view tag:tag offset:offset productCount:productCount];
}
#pragma mark Website Data

- (void)loadWebsiteDataPlist {
    NSDictionary *dictRoot = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"tmstore" ofType:@"plist"]];
    
    
    _isAppForExternalUser = GET_VALUE_BOOL(dictRoot, @"isAppForExternalUser");
    BOOL isDemoApp = GET_VALUE_BOOL(dictRoot, @"isDemoApp");
    BOOL isFreeApp = GET_VALUE_BOOL(dictRoot, @"isFreeApp");
    BOOL isPaidApp = GET_VALUE_BOOL(dictRoot, @"isPaidApp");
    if (isDemoApp) {
        _appType = APP_TYPE_DEMO;
    }
    if (isFreeApp) {
        _appType = APP_TYPE_FREE;
    }
    if (isPaidApp) {
        _appType = APP_TYPE_PAID;
    }
    
    
    if (IS_NOT_NULL(dictRoot, @"color")) {
        NSMutableDictionary* colors = GET_VALUE_OBJECT(dictRoot, @"color");
        
        unsigned hex_color_header;
        if ([[NSScanner scannerWithString:GET_VALUE_STRING(colors, @"color_header")] scanHexInt:&hex_color_header]) {
            [Utility setThemeHeaderBg:[Utility colorWithHex:hex_color_header]];
        }
        if (1) {
            [Utility setThemeColorHorizontalViewBg:[UIColor clearColor]];
        }
        if (1) {
            [Utility setThemeColorHorizontalViewFont:[UIColor darkGrayColor]];
        }
        unsigned hex_color_footer;
        if ([[NSScanner scannerWithString:GET_VALUE_STRING(colors, @"color_footer")] scanHexInt:&hex_color_footer]) {
            [Utility setThemeFooterBg:[Utility colorWithHex:hex_color_footer]];
        }
        
        unsigned hex_color_theme;
        if ([[NSScanner scannerWithString:GET_VALUE_STRING(colors, @"color_theme")] scanHexInt:&hex_color_theme]) {
            [Utility setThemeColor:[Utility colorWithHex:hex_color_theme]];
        }
        
        unsigned hex_color_btn_normal;
        if ([[NSScanner scannerWithString:GET_VALUE_STRING(colors, @"color_btn_normal")] scanHexInt:&hex_color_btn_normal]) {
            [Utility setThemeButtonNormalColor:[Utility colorWithHex:hex_color_btn_normal]];
        }
        
        unsigned hex_color_btn_selected;
        if ([[NSScanner scannerWithString:GET_VALUE_STRING(colors, @"color_btn_selected")] scanHexInt:&hex_color_btn_selected]) {
            [Utility setThemeButtonSelectedColor:[Utility colorWithHex:hex_color_btn_selected]];
        }
        
        unsigned hex_color_btn_disabled;
        if ([[NSScanner scannerWithString:GET_VALUE_STRING(colors, @"color_btn_disabled")] scanHexInt:&hex_color_btn_disabled]) {
            [Utility setThemeButtonDisabledColor:[Utility colorWithHex:hex_color_btn_disabled]];
        }
        
        unsigned hex_color_btn_big_bg;
        if ([[NSScanner scannerWithString:GET_VALUE_STRING(colors, @"color_btn_big_bg")] scanHexInt:&hex_color_btn_big_bg]) {
            [Utility setThemeBigButtonBg:[Utility colorWithHex:hex_color_btn_big_bg]];
        }
        
        unsigned hex_color_btn_big_font;
        if ([[NSScanner scannerWithString:GET_VALUE_STRING(colors, @"color_btn_big_font")] scanHexInt:&hex_color_btn_big_font]) {
            [Utility setThemeBigButtonFont:[Utility colorWithHex:hex_color_btn_big_font]];
        }
        [Utility setThemeBlueColor];
    }
}

@end
