//
//  DataManager.h
//  eCommerceApp
//
//  Created by Rishabh Jain on 01/10/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Variables.h"
#import "Banner.h"
#import "ProductInfo.h"

#import "WC2X_Engine.h"

#import "ShippingEngine.h"
#import "TMShippingSDK.h"

@interface DataManager : NSObject
+ (id)sharedManager;
+ (void)resetManager;
+ (id)getDataDoctor;
- (void)loadWebsiteDataPlist;

- (void)loadCustomerData:(NSDictionary*)dictionary;
- (void)loadOrdersData:(NSDictionary *)dictionary;
- (void)loadCategoriesData:(NSDictionary *)dictionary;
- (NSMutableArray*)loadProductsData:(NSDictionary *)dictionary;
- (ProductInfo*)loadSingleProductData:(NSDictionary *)dictionary;
- (void)loadSingleProductReviewData:(NSDictionary *)dictionary product:(ProductInfo*)product;
- (void)loadCommonData:(NSDictionary *)dictionary;

@property id tmDataDoctor;
@property int appType;
@property BOOL isAppForExternalUser;
@property NSString* merchantObjectId;
@property NSString* promoUrlImgPath;
@property NSString* promoUrlString;
@property BOOL promoEnable;
@property BOOL showFullSizeCategoryBanner;
@property int maxCategoryLoadCount;
@property int maxProductLoadCount;
@property BOOL isRefineCategoriesEnable;
@property BOOL isAutoRefreshCategoryThumbEnable;
@property BOOL isStepUpSingleChildrenCategoriesEnable;
@property BOOL isAutoSigninInHiddenWebviewEnable;
@property NSString* decimalSeperator;
@property NSString* thousandSeperator;

@property NSString* userTempPostalCode;
@property NSString* userTempCity;
@property NSString* userTempState;
@property NSString* userTempCountry;
@property BOOL locationDataFetched;

@property TMPaymentSDK* tmPaymentSDK;
@property TMShippingSDK* tmShippingSDK;
@property NSDictionary* colorDict;

////payu money
//@property NSString* payu_merchantKey;
//@property NSString* payu_saltKey;
//@property NSString* payu_successUrl;
//@property NSString* payu_failureUrl;
//@property NSString* payu_serviceProvider;
////paypal
//@property NSString* paypal_ClientId;

//splash
@property NSString* splashUrlImgPath;
@property UIColor* splashTextColor;
@property NSString* splashTextColorString;

@property NSString* splashUrlImgPathPortrait;
@property NSString* splashUrlImgPathLandscape;

//various keys
@property NSString* keyFacebookAppId;
@property NSString* keyFacebookConsumerSecret;
@property NSString* keyTwitterConsumerKey;
@property NSString* keyTwitterConsumerSecret;
@property NSString* keyGoogleClientId;
@property NSString* keyGoogleClientSecret;
@property BOOL enable_coupons;
@property BOOL enable_filters;
@property BOOL show_tmstore_text;

@property NSString* checkoutUrlLinkFromPlugin;

@property int layoutIdCategoryView;
@property int layoutIdProductView;
@property int layoutIdHorizontalView;
@property int layoutIdBannerView;
@property int layoutIdProductBannerView;

@property NSMutableArray* shippingEngines;
@property id shippingEngine;
@property int shippingProvider;
@property NSDictionary* contactDetails;
@property UISearchBar* searchBarTextField;
@property BOOL isAllFilterLoaded;
@property BOOL isPriceFilterLoaded;
@property BOOL isAtributtFilterLoaded;
@property BOOL isShowLoginPopUpHomeScreen;

@property NSString* appDataPlatformString;
@property BOOL isHomeScreenFirstLaunch;

@property NSString* min_app_version;
@property NSString* current_app_version;

@property BOOL isForceUpdateNeeded;
@property BOOL isUpdateNeeded;
@property BOOL isUpdateInfoLoaded;


@end
