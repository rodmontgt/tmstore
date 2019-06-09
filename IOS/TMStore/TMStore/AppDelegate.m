//
//  AppDelegate.m
//  eCommerceApp
//
//  Created by Rishabh Jain on 16/09/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import "AppDelegate.h"

#if ENABLE_GOOGLE_ADMOB_SDK
@import GoogleMobileAds;
#endif

#import <AFNetworking/AFNetworkActivityIndicatorManager.h>
#import <AFNetworking/AFNetworkReachabilityManager.h>
#import <AFNetworking/AFNetworking.h>
#if ENABLE_ADWORDS_FIREBASE || ENABLE_FIREBASE_TAG_MANAGER
@import Firebase;
#endif

#if ENABLE_FIREBASE_TAG_MANAGER
#import "AnalyticsHelper.h"
#endif
#if ENABLE_TWITTER_LOGIN
#import <TwitterKit/TwitterKit.h>
#import <TwitterCore/TwitterCore.h>
#import <Twitter/Twitter.h>
#endif

#if ENABLE_FB_LOGIN
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#endif

#if ENABLE_NTP
#import "NetworkClock.h"
#endif

#if (INTEGRATE_PARSE)
#import <Parse/Parse.h>
#endif
#import "CommonInfo.h"
#import "AppUser.h"
#import "DataManager.h"
#import "LayoutManager.h"
#import "Variables.h"
#import "VariousKeys.h"
#if (ENABLE_BRANCH)
#if (WORKING_BRANCH_VERSION_0_11_6)
#import "Branch.h"
#endif
#if (WORKING_BRANCH_VERSION_0_11_11)
#import <Branch/Branch.h>
#endif
#endif

#import "TMDataDoctor.h"
#import "LoginFlow.h"
#import "ParseVariables.h"
#import "ParseHelper.h"

#if ENABLE_HOTLINE
#import "Hotline.h"
#elif ENABLE_FRESHCHAT
#import "Freshchat.h"
#endif

#if ENABLE_GOOGLE_ANALYTICS
#import <Google/Analytics.h>
#endif

#if ENABLE_AUTOCOMPLETE_GEOLOCATION_SEARCH
@import GoogleMaps;
@import GooglePlaces;
#endif

#define SAMPLE_TMPAYMENTSDK 0

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <AdSupport/AdSupport.h>

#if ENABLE_CRASHLYTICS
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#endif

static AppDelegate* apd = nil;
static BOOL deviceSleepingMode = false;
@interface AppDelegate ()
@end

@implementation AppDelegate
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    apd = self;
    self.dlProductId = -1;
    self.nType = -1;
    self.nJsonData_Id = -1;
    self.nJsonData_varId = -1;
    self.nJsonData_couponCode = @"";
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    deviceSleepingMode = [UIApplication sharedApplication].idleTimerDisabled;
    [UIApplication sharedApplication].idleTimerDisabled = true;
    [[[SDWebImageManager sharedManager] imageCache] setMaxMemoryCountLimit:50];
    
    [GMSServices provideAPIKey:GMS_SERVICES_API_KEY];
    [GMSPlacesClient provideAPIKey:GMS_PLACES_CLIENT_API_KEY];
    
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [Utility isNetworkAvailable];
    
#if ENABLE_CRASHLYTICS
    [Fabric with:@[[Crashlytics class]]];
#endif
    
#if ENABLE_FB_LOGIN
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
#endif
    
#if ENABLE_HOTLINE
    if ([[Hotline sharedInstance] isHotlineNotification:launchOptions]) {
        [[Hotline sharedInstance] handleRemoteNotification:launchOptions andAppstate:application.applicationState];
    }
#elif ENABLE_FRESHCHAT
    if ([[Freshchat sharedInstance] isFreshchatNotification:launchOptions]) {
        [[Freshchat sharedInstance] handleRemoteNotification:launchOptions andAppstate:application.applicationState];
    }
#endif
    
#if (ENABLE_BRANCH)
    Branch *branch = [Branch getInstance];
    [branch initSessionWithLaunchOptions:launchOptions andRegisterDeepLinkHandler:^(NSDictionary *params, NSError *error) {
        // params are the deep linked params associated with the link that the user clicked before showing up.
        RLOG(@"deep link data: %@", [params description]);
        NSString *canonical_identifier = (NSString*)[params objectForKey:@"$canonical_identifier"];
        if([self checkProductUrl:canonical_identifier]){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NOTIFY_DL_PRODUCT" object:self];
        }
    }];
#endif
    
    // Override point for customization after application launch.
    [[DataManager sharedManager] loadWebsiteDataPlist];
    [LayoutManager sharedManager];
#if ENABLE_NTP
    [NetworkClock sharedNetworkClock];
#endif
    
#if (INTEGRATE_PARSE)
    NSString* parseApplicationId = @"";
    NSString* parseClientKey = @"";
    if ([[DataManager sharedManager] appType] == APP_TYPE_DEMO) {
        parseApplicationId = PARSE_DEMO_APP_ID;
        parseClientKey = PARSE_DEMO_CLIENT_KEY;
    } else {
        parseApplicationId = PARSE_MERCHANT_APPLICATION_ID;
        parseClientKey = PARSE_MERCHANT_CLIENT_KEY;
    }
    [Parse initializeWithConfiguration:[ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
        configuration.applicationId = parseApplicationId;
        configuration.clientKey = parseClientKey;
        configuration.server = @"https://parseapi.back4app.com";
        configuration.localDatastoreEnabled = YES;
    }]];
    [PFUser enableAutomaticUser];
    [[ParseHelper sharedManager] installDeviceOnParse];
    [[PFUser currentUser] saveInBackground];
#endif
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0){
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
    
    [self checkForNotificationPermission];
    [[Utility sharedManager] startRecording];
    
#if (SAMPLE_TMPAYMENTSDK)
    //init paymentsdk
    TMPaymentSDK* tmPaymentSDK = [[TMPaymentSDK alloc] init];
    
    //create pamentgateway
    TMPaymentGateway* tmPaymentGageway = [[TMPaymentGateway alloc] init];
    [tmPaymentSDK.paymentGateways addObject:tmPaymentGageway];
    
    //to set completion delegate
    [tmPaymentSDK.paymentDelegate setDelegate:self];
    //to post completion callback
    [tmPaymentSDK.paymentDelegates postCompletionCallbackWithSuccess:nil];
#endif
    
#if ENABLE_GOOGLE_ANALYTICS
    [self initGoogleAnalytics];
#endif
    
    NSDictionary *aPushNotification = [launchOptions valueForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if(aPushNotification) {
        [self application:application didReceiveRemoteNotification:aPushNotification];
    }
    NSString *pathAndFileName = [[NSBundle mainBundle] pathForResource:@"GoogleService-Info" ofType:@"plist"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:pathAndFileName])
    {
#if ENABLE_ADWORDS_FIREBASE || ENABLE_FIREBASE_TAG_MANAGER
        NSDictionary *dictRoot = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"GoogleService-Info" ofType:@"plist"]];
        BOOL isAnalyticsEnabled = GET_VALUE_BOOL(dictRoot, @"IS_ANALYTICS_ENABLED");
        BOOL isAdEnabled = GET_VALUE_BOOL(dictRoot, @"IS_ADS_ENABLED");
        if (isAnalyticsEnabled || isAdEnabled) {
            [FIRApp configure];
        }
#endif
    }
    else {
        NSLog(@"File not found");
    }
    
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    UIStoryboard *storyboard = [Utility getStoryBoardObject];
    UIViewController * viewController = nil;
    if ([Utility isMultiStoreApp]) {
        viewController = [storyboard instantiateViewControllerWithIdentifier:VC_SPLASH_PLATFORM];
    } else {
        viewController = [storyboard instantiateViewControllerWithIdentifier:VC_SPLASH_PRIMARY];
    }
    self.window.rootViewController = viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    BOOL isHandled = false;
#if (ENABLE_BRANCH)
    if (!isHandled) {
        isHandled = [[Branch getInstance] handleDeepLink:url];
    }
#endif
#if (ENABLE_FB_LOGIN)
    if (!isHandled) {
        isHandled = [[FBSDKApplicationDelegate sharedInstance] application:application openURL:url sourceApplication:sourceApplication annotation:nil];
    }
#endif
    if (!isHandled) {
        isHandled = [[GIDSignIn sharedInstance] handleURL:url
                                        sourceApplication:sourceApplication
                                               annotation:annotation];
    }
    return isHandled;
}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *installation = [PFInstallation currentInstallation];
    [installation setDeviceTokenFromData:deviceToken];
    installation.channels = @[ @"ios", @"both" ];
    [installation saveInBackground];
    
#if ENABLE_HOTLINE
    [[Hotline sharedInstance] updateDeviceToken:deviceToken];
#elif ENABLE_FRESHCHAT
    [[Freshchat sharedInstance] setPushRegistrationToken:deviceToken];
#endif
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    BOOL isHotLineNotification = false;
#if ENABLE_HOTLINE
    if ([[Hotline sharedInstance]isHotlineNotification:userInfo]) {
        isHotLineNotification = true;
        [[Hotline sharedInstance]handleRemoteNotification:userInfo andAppstate:application.applicationState];
    }
#elif ENABLE_FRESHCHAT
    if ([[Freshchat sharedInstance] isFreshchatNotification:userInfo]) {
        isHotLineNotification = true;
        [[Freshchat sharedInstance] handleRemoteNotification:userInfo andAppstate:application.applicationState];
    }
#endif
    if (isHotLineNotification == false) {
        [PFPush handlePush:userInfo];
        NSDictionary* data_array = nil;
        if (IS_NOT_NULL(userInfo, @"aps")) {
            NSDictionary* aps = GET_VALUE_OBJECT(userInfo, @"aps");
            if (IS_NOT_NULL(aps, @"data_array")) {
                id obj = GET_VALUE_OBJECT(aps, @"data_array");
                if ([obj isKindOfClass:[NSDictionary class]]) {
                    data_array = obj;
                }
            }
        }
        if (data_array == nil && IS_NOT_NULL(userInfo, @"data_array")) {
            id obj = GET_VALUE_OBJECT(userInfo, @"data_array");
            if ([obj isKindOfClass:[NSDictionary class]]) {
                data_array = obj;
            }
        }
        if (data_array) {
            self.nJsonData_varId = -1;
            if (IS_NOT_NULL(data_array, @"type")) {
                self.nType = GET_VALUE_INT(data_array, @"type");
            }
            if (IS_NOT_NULL(data_array, @"id")) {
                self.nJsonData_Id = GET_VALUE_INT(data_array, @"id");
            }
            if (IS_NOT_NULL(data_array, @"content")) {
                self.nJsonData_couponCode = GET_VALUE_STRING(data_array, @"content");
            }
            if (IS_NOT_NULL(data_array, @"notify_id")) {
                NSString* parsePushId = GET_VALUE_STRING(data_array, @"notify_id");
                [[ParseHelper sharedManager] updateNotificationReceivedCountOnParse:parsePushId];
            }
        }
    }
    
    [self parseForNotifictaion:userInfo];
    
    //json format to be sent from parse
    //    {
    //        "alert": "Proceed",
    //        "badge": "Increment",
    //        "id": "345",
    //        "sound": "chime",
    //        "str": "test str",
    //        "title": "TM Store News",
    //        "vid": "105"
    //    }
    
    //userInfo received at application end
    //    {
    //        aps =     {
    //            alert = Proceed;
    //            badge = 4;
    //            sound = chime;
    //        };
    //        id = 345;
    //        parsePushId = JWvUxNFDMy;
    //        str = "test str";
    //        title = "TM Store News";
    //        vid = 105;
    //    }
}
- (void)parseForNotifictaion:(NSDictionary*)userInfo {
    //for notification action
    NSDictionary* data_array = nil;
    NSDictionary* aps = nil;
    {
        if (IS_NOT_NULL(userInfo, @"aps")) {
            aps= GET_VALUE_OBJECT(userInfo, @"aps");
            
            if (IS_NOT_NULL(aps, @"data_array")) {
                id obj = GET_VALUE_OBJECT(aps, @"data_array");
                if ([obj isKindOfClass:[NSDictionary class]]) {
                    data_array = obj;
                }
            }
        }
        if (data_array == nil && IS_NOT_NULL(userInfo, @"data_array")) {
            id obj = GET_VALUE_OBJECT(userInfo, @"data_array");
            if ([obj isKindOfClass:[NSDictionary class]]) {
                data_array = obj;
            }
        }
    }
    
    //for notification screen/list
    {
        // Notification List Screen
        NSManagedObjectContext *context = [self managedObjectContext];
        // Create a new managed object
        NSManagedObject *newDevice = [NSEntityDescription insertNewObjectForEntityForName:@"NotificationsList" inManagedObjectContext:context];
        if (aps) {
            if (IS_NOT_NULL(aps, @"alert")) {
                id alertObj = GET_VALUE_OBJ(aps, @"alert");
                if (alertObj) {
                    if([alertObj isKindOfClass:[NSDictionary class]]) {
                        [newDevice setValue:GET_VALUE_STR(alertObj, @"body") forKey:@"descriptions"];
                    } else if([alertObj isKindOfClass:[NSString class]]){
                        [newDevice setValue:GET_VALUE_STR(aps, @"alert") forKey:@"descriptions"];
                    }
                }
            }
            if (IS_NOT_NULL(aps, @"title")) {
                [newDevice setValue:GET_VALUE_STR(aps, @"title") forKey:@"notificationtitle"];
            }
            NSDate *currDate = [NSDate date];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
            [dateFormatter setDateFormat:@"dd/MM/YY HH:mm"];
            NSString *dateString = [dateFormatter stringFromDate:currDate];
            NSLog(@"%@",dateString);
            [newDevice setValue:dateString forKey:@"timeanddate"];
            
            NSError *error = nil;
            // Save the object to persistent store
            if (![context save:&error]) {
                NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
            }
            [newDevice setValue:@"yellow" forKey:@"backgroundcolor"];
        }
        
        if (data_array) {
            if (IS_NOT_NULL(data_array, @"type")) {
                int  notificationType = GET_VALUE_INT(data_array, @"type");
                NSNumber *Type = [NSNumber numberWithInteger:notificationType];
                [newDevice setValue:Type forKey:@"type"];
            }
            if (IS_NOT_NULL(data_array, @"id")) {
                int nnotificationId = GET_VALUE_INT(data_array, @"id");
                NSNumber *ids = [NSNumber numberWithInteger:nnotificationId];
                [newDevice setValue:ids forKey:@"id"];
            }
            if (IS_NOT_NULL(data_array, @"content")) {
                NSString *notificationCouponCode = GET_VALUE_STRING(data_array, @"content");
                [newDevice setValue:notificationCouponCode forKey:@"content"];
            }
            if (IS_NOT_NULL(data_array, @"notify_id")) {
                NSString* parsePushId = GET_VALUE_STRING(data_array, @"notify_id");
                [newDevice setValue:parsePushId forKey:@"notify_id"];
            }
        }
    }
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    self.isAppEnteredInBackground = true;
    [[AppUser sharedManager] saveData];
    [UIApplication sharedApplication].idleTimerDisabled = deviceSleepingMode;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
    //    [[[DataManager sharedManager] tmDataDoctor] fetchCartProductsDataFromPlugin];
    self.isAppEnteredInBackground = false;
    [UIApplication sharedApplication].idleTimerDisabled = true;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBSDKAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [UIApplication sharedApplication].idleTimerDisabled = deviceSleepingMode;
    
#if ENABLE_NTP
    [[NetworkClock sharedNetworkClock] finishAssociations];
#endif
    [self saveContext];
}

//- (void)shareUrl {
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"com.twist.rishabh://test_page/one?token=12345&domain=foo.com"]];
//}
- (NSDictionary *)parseQueryString:(NSString *)query {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:6];
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    
    for (NSString *pair in pairs) {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        NSString *key = [[elements objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *val = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [dict setObject:val forKey:key];
    }
    return dict;
}
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    RLOG(@"url recieved: %@", url);
    RLOG(@"query string: %@", [url query]);
    RLOG(@"host: %@", [url host]);
    RLOG(@"url path: %@", [url path]);
    NSDictionary *dict = [self parseQueryString:[url query]];
    RLOG(@"query dict: %@", dict);
    return YES;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *))restorationHandler {
#if (ENABLE_BRANCH)
    return [[Branch getInstance] continueUserActivity:userActivity];
#endif
    return false;
}

- (BOOL)checkProductUrl:(NSString*)url{
    if ([[ParseHelper sharedManager] isParseDataLoaded] == false) {
        return false;
    }
    NSString* matchUrl = [NSString stringWithString:[[[DataManager sharedManager] tmDataDoctor] productPageBaseUrl]];
    
    if (url != nil && [Utility containsString:url substring:matchUrl]) {
        NSString *extractString = [url stringByReplacingOccurrencesOfString:matchUrl withString:@""];
        int productId = (int)[extractString integerValue];
        _dlProductId = productId;
        RLOG(@"_dlProductId:%d", _dlProductId);
        return true;
    }
    RLOG(@"_dlProductId:%d", _dlProductId);
    return false;
}

#if (SAMPLE_TMPAYMENTSDK)
- (void)paymentCompletionWithSuccess:(id)obj {
    RLOG(@"paymentCompletionWithSuccess");
}
- (void)paymentCompletionWithFailure:(id)obj {
    RLOG(@"paymentCompletionWithFailure");
}
#endif

#if ENABLE_HOTLINE
- (void)configureHotlineSDK:(NSString*)hotlineAppId hotlineAppKey:(NSString*)hotlineAppKey {
    HotlineConfig *config = [[HotlineConfig alloc] initWithAppID:hotlineAppId  andAppKey:hotlineAppKey];
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    if (bundleIdentifier && [bundleIdentifier isEqualToString:@"com.tmstore.sexappealstore"]) {
        config.pictureMessagingEnabled = false;
        config.cameraCaptureEnabled = false;
    }
    //    config.voiceMessagingEnabled = false;
    //    config.themeName = @"Hotline";
    //    config.pollWhenAppActive = true;
    
    NSString* locale = [[NSUserDefaults standardUserDefaults] valueForKey:USER_LOCALE];
    //    NSString *locale = [[NSLocale currentLocale] localeIdentifier];
    if (locale != nil) {
        NSString* hotlineLocalizationFileName = [NSString stringWithFormat:@"HLLocalization_%@",locale];
        NSString *pathAndFileName = [[NSBundle mainBundle] pathForResource:hotlineLocalizationFileName ofType:@"bundle"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:pathAndFileName]){
            config.stringsBundle = hotlineLocalizationFileName;
        } else {
            NSLog(@"File not found");
        }
    }
    [[Hotline sharedInstance] initWithConfig:config];
    
    HotlineUser *user = [HotlineUser sharedInstance];
    AppUser* appUser = [AppUser sharedManager];
    if (appUser._isUserLoggedIn) {
        if ([appUser._first_name isEqualToString:@""] == false) {
            user.name = [NSString stringWithFormat:@"%@ %@", appUser._first_name, appUser._last_name];
        }else if ([appUser._username isEqualToString:@""] == false){
            user.name = appUser._username;
        }
        if ([appUser._email isEqualToString:@""] == false) {
            user.email = appUser._email;
        }
    }
    user.externalID = [[PFUser currentUser] objectId];
    [[Hotline sharedInstance] updateUser:user];
}
#elif ENABLE_FRESHCHAT
- (void)configureHotlineSDK:(NSString*)hotlineAppId hotlineAppKey:(NSString*)hotlineAppKey {
    FreshchatConfig *config = [[FreshchatConfig alloc] initWithAppID:hotlineAppId  andAppKey:hotlineAppKey];
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    if (bundleIdentifier && [bundleIdentifier isEqualToString:@"com.tmstore.sexappealstore"]) {
        config.gallerySelectionEnabled = false;
        config.cameraCaptureEnabled = false;
    }
    //    config.voiceMessagingEnabled = false;
    //    config.themeName = @"Hotline";
    //    config.pollWhenAppActive = true;
    
    NSString* locale = [[NSUserDefaults standardUserDefaults] valueForKey:USER_LOCALE];
    //    NSString *locale = [[NSLocale currentLocale] localeIdentifier];
    if (locale != nil) {
        NSString* hotlineLocalizationFileName = [NSString stringWithFormat:@"FCLocalization_%@",locale];
        NSString *pathAndFileName = [[NSBundle mainBundle] pathForResource:hotlineLocalizationFileName ofType:@"bundle"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:pathAndFileName])
        {
            config.stringsBundle = hotlineLocalizationFileName;
        } else {
            NSLog(@"File not found");
        }
    }
    [[Freshchat sharedInstance] initWithConfig:config];
    
    FreshchatUser *user = [FreshchatUser sharedInstance];
    AppUser* appUser = [AppUser sharedManager];
    if (appUser._isUserLoggedIn) {
        if ([appUser._first_name isEqualToString:@""] == false) {
            user.firstName = [NSString stringWithFormat:@"%@", appUser._first_name];
            if ([appUser._last_name isEqualToString:@""] == false) {
                user.lastName = [NSString stringWithFormat:@"%@", appUser._last_name];
            }
        }else if ([appUser._username isEqualToString:@""] == false){
            user.firstName = [NSString stringWithFormat:@"%@", appUser._first_name];
        }
        if ([appUser._email isEqualToString:@""] == false) {
            user.email = appUser._email;
        }
    }
    user.externalID = [[PFUser currentUser] objectId];
    [[Freshchat sharedInstance] setUser:user];
}
#endif
#if ENABLE_AUTOCOMPLETE_GEOLOCATION_SEARCH
- (void)configureGeoLocationSDK:(NSString*)apiKey {
    [GMSServices provideAPIKey:apiKey];
    [GMSPlacesClient provideAPIKey:apiKey];
}
#endif

- (void)logCartEvent:(Cart *)cart {
#if ENABLE_FB_ANALYTICS
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setValue:[CommonInfo sharedManager]->_currency forKey:FBSDKAppEventParameterNameCurrency];
    [dict setValue:@"product" forKey:FBSDKAppEventParameterNameContentType];
    if (cart.selectedVariationId == -1) {
        [dict setValue:[NSString stringWithFormat:@"%d", cart.product_id] forKey:FBSDKAppEventParameterNameContentID];
    }else {
        [dict setValue:[NSString stringWithFormat:@"%d", cart.selectedVariationId] forKey:FBSDKAppEventParameterNameContentID];
    }
    [FBSDKAppEvents logEvent:FBSDKAppEventNameAddedToCart valueToSum:[cart getCartTotal] parameters:dict];
#endif
}
- (void)logWishlistEvent:(Wishlist *)wishlist {
#if ENABLE_FB_ANALYTICS
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setValue:[CommonInfo sharedManager]->_currency forKey:FBSDKAppEventParameterNameCurrency];
    [dict setValue:@"product" forKey:FBSDKAppEventParameterNameContentType];
    if (wishlist.selectedVariationId == -1) {
        [dict setValue:[NSString stringWithFormat:@"%d", wishlist.product_id] forKey:FBSDKAppEventParameterNameContentID];
    }else {
        [dict setValue:[NSString stringWithFormat:@"%d", wishlist.selectedVariationId] forKey:FBSDKAppEventParameterNameContentID];
    }
    [FBSDKAppEvents logEvent:FBSDKAppEventNameAddedToWishlist valueToSum:[wishlist getWishlistTotal] parameters:dict];
#endif
}
- (void)logProductViewEvent:(ProductInfo *)product {
#if ENABLE_FB_ANALYTICS
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setValue:[CommonInfo sharedManager]->_currency forKey:FBSDKAppEventParameterNameCurrency];
    [dict setValue:@"product" forKey:FBSDKAppEventParameterNameContentType];
    [dict setValue:[NSString stringWithFormat:@"%d", product._id] forKey:FBSDKAppEventParameterNameContentID];
    [FBSDKAppEvents logEvent:FBSDKAppEventNameViewedContent valueToSum:[product  getNewPrice:-1] parameters:dict];
#endif
}
- (void)logRegistration {
#if ENABLE_FB_ANALYTICS
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    AppUser* ap = [AppUser sharedManager];
    [dict setValue:SA_PROVIDERS_NAME[ap._userLoggedInVia] forKey:FBSDKAppEventParameterNameRegistrationMethod];
    [FBSDKAppEvents logEvent:FBSDKAppEventNameCompletedRegistration parameters:dict];
#endif
}
- (void)logItemSearched:(NSString *)text isFound:(BOOL)isFound {
#if ENABLE_FB_ANALYTICS
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setValue:@"Search" forKey:FBSDKAppEventParameterNameContentType];
    [dict setValue:text forKey:FBSDKAppEventParameterNameSearchString];
    [dict setValue:[NSNumber numberWithBool:isFound] forKey:FBSDKAppEventParameterNameSuccess];
    [FBSDKAppEvents logEvent:FBSDKAppEventNameSearched parameters:dict];
#endif
#if ENABLE_FIREBASE_TAG_MANAGER
    [[AnalyticsHelper sharedInstance] registerSearchEvent:text isFound:isFound];
#endif
}
- (void)logPaymentInit {
#if ENABLE_FB_ANALYTICS
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setValue:@"Checkout" forKey:FBSDKAppEventParameterNameContentType];
    [dict setValue:@"0" forKey:FBSDKAppEventParameterNameContentID];
    [dict setValue:[NSNumber numberWithInt:[Cart getItemCount]] forKey:FBSDKAppEventParameterNameNumItems];
    [dict setValue:[NSNumber numberWithBool:true] forKey:FBSDKAppEventParameterNamePaymentInfoAvailable];
    [dict setValue:[CommonInfo sharedManager]->_currency forKey:FBSDKAppEventParameterNameCurrency];
    [FBSDKAppEvents logEvent:FBSDKAppEventNameInitiatedCheckout parameters:dict];
#endif
}
- (void)logPurchase:(Order*)order {
#if ENABLE_FB_ANALYTICS
    //    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    //    [dict setValue:@"Order" forKey:FBSDKAppEventParameterNameContentType];
    //    [dict setValue:[NSNumber numberWithInt:order._id] forKey:FBSDKAppEventParameterNameContentID];
    //    [dict setValue:[NSNumber numberWithInt:order._total_line_items_quantity] forKey:FBSDKAppEventParameterNameNumItems];
    //    [dict setValue:[CommonInfo sharedManager]->_currency forKey:FBSDKAppEventParameterNameCurrency];
    
    //FBAppEventNamePurchased is not found in facebook sdk
    //    [FBSDKAppEvents logEvent:FBAppEventNamePurchased valueToSum:[order._total doubleValue] parameters:dict];
#endif
}

+ (AppDelegate*)getInstance {
    return apd;
}

#if ENABLE_GOOGLE_ADMOB_SDK
- (void)initGoogleAdMobSDK:(NSString*)admob_app_id {
    // Initialize Google Mobile Ads SDK
    // Sample AdMob app ID: ca-app-pub-3940256099942544~1458002511
    [GADMobileAds configureWithApplicationID:admob_app_id];
}
#endif
#if ENABLE_GOOGLE_ANALYTICS
- (void)initGoogleAnalytics {
    NSError *configureError;
    [[GGLContext sharedInstance] configureWithError:&configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    
    // Optional: configure GAI options.
    GAI *gai = [GAI sharedInstance];
    //    gai.trackUncaughtExceptions = YES;  // report uncaught exceptions
    //    gai.logger.logLevel = kGAILogLevelVerbose;  // remove before app release
}
- (void)googleEvent {
    // May return nil if a tracker has not already been initialized with a property
    // ID.
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"
                                                          action:@"button_press"
                                                           label:@"play"
                                                           value:nil] build]];
}
#endif

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Notification" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Notification.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Notification Setting Permission

- (void)checkForNotificationPermission{
    NSString *iOSversion = [[UIDevice currentDevice] systemVersion];
    NSString *prefix = [[iOSversion componentsSeparatedByString:@"."] firstObject];
    float versionVal = [prefix floatValue];
    
    if (versionVal >= 8){
        if ([[UIApplication sharedApplication] currentUserNotificationSettings].types != UIUserNotificationTypeNone){
            RLOG(@" Push Notification ON");
            self.notification =  Localize(@"on");
        }
        else{
            self.notification = Localize(@"off");
        }
    }else{
        UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        if (types != UIRemoteNotificationTypeNone){
            self.notification =  Localize(@"on");
        }
        else{
            self.notification = Localize(@"off");
        }
    }
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    BOOL handled = false;
#if (ENABLE_FB_LOGIN)
    if (!handled) {
        handled = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                                 openURL:url
                                                       sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                                              annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
    }
#endif
    
#if (ENABLE_TWITTER_LOGIN)
    if (!handled) {
        handled =  [[Twitter sharedInstance] application:application openURL:url options:options];
    }
#endif
    
    if (!handled) {
        handled = [[GIDSignIn sharedInstance] handleURL:url sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey] annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
    }
    
    return handled;
}

#if SUPPORT_PORTRAIT_ORIENTATION_ONLY
- (BOOL)shouldAutorotate {
    return YES;
}
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskPortrait;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#endif
@end
