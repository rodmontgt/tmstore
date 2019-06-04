//
//  AppDelegate.h
//  eCommerceApp
//
//  Created by Rishabh Jain on 16/09/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Google/SignIn.h>
#if (SAMPLE_TMPAYMENTSDK)
#import <TMPaymentSDK/TMPaymentSDK.h>
#endif
#import "Variables.h"
#import "Cart.h"
#import "ProductInfo.h"
#import "Wishlist.h"
#import "Order.h"
#import <CoreData/CoreData.h>
enum nNotificationType {
    nType_DoNothing = 0,
    nType_OpenProduct = 2,
    nType_OpenCategory = 1,
    nType_OpenWishlist = 4,
    nType_OpenCart = 3
};
@interface AppDelegate : UIResponder <UIApplicationDelegate

#if (SAMPLE_TMPAYMENTSDK)
, TMPaymentSDKDelegate
#endif
>

@property (strong, nonatomic) UIWindow *window;

//- (void)shareUrl;
@property int dlProductId;

@property int nType;
@property int nJsonData_Id;
@property int nJsonData_varId;
@property NSString* nJsonData_couponCode;
@property NSString* nTitle;
@property NSString* nDescripation;
#if ENABLE_HOTLINE
- (void)configureHotlineSDK:(NSString*)hotlineAppId hotlineAppKey:(NSString*)hotlineAppKey;
#elif ENABLE_FRESHCHAT
- (void)configureHotlineSDK:(NSString*)hotlineAppId hotlineAppKey:(NSString*)hotlineAppKey;
#endif
#if ENABLE_AUTOCOMPLETE_GEOLOCATION_SEARCH
- (void)configureGeoLocationSDK:(NSString*)apiKey;
#endif

- (void)logCartEvent:(Cart *)cart;
- (void)logWishlistEvent:(Wishlist *)wishlist;
- (void)logProductViewEvent:(ProductInfo *)product;
- (void)logRegistration;
- (void)logItemSearched:(NSString *)text isFound:(BOOL)isFound;
- (void)logPaymentInit;
- (void)logPurchase:(Order*)order;
#if ENABLE_FMAS
@property (assign ,nonatomic) BOOL FMASDismiss;
#endif
+ (AppDelegate*)getInstance;
@property BOOL isPrevScreenCouponCode;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
@property  (nonatomic,retain) NSString *notification;
- (void)checkForNotificationPermission;

@property BOOL isAppEnteredInBackground;
- (void)initGoogleAdMobSDK:(NSString*)admob_app_id;
@end

