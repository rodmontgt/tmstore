//
//  ParseHelper.h
//  eCommerceApp
//
//  Created by Rishabh Jain on 01/10/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Variables.h"
#import "Utility.h"
#import "DataManager.h"
#import <Parse/Parse.h>
#import "ParseVariables.h"
#import "Order.h"
#import "AppUser.h"
#import "ProductInfo.h"
#import "CustomerData.h"
#import "Variables.h"

@interface ParseHelper : NSObject

@property BOOL isParseDataLoaded;
@property BOOL isParseDataLoadedWithError;
@property NSArray* appDataRows;
+ (id)sharedManager;
+ (void)resetManager;
- (void)checkDataLoaded;
- (void)registerParseWishlistProduct:(int)productId categoryId:(int)categoryId increment:(int)increment;
- (void)registerParseCartProduct:(int)productId categoryId:(int)categoryId increment:(int)increment;
- (void)registerParseVisitProduct:(int)productId increment:(int)increment;
//- (void)registerParsePurchaseProduct:(int)productId categoryId:(int)categoryId increment:(int)increment;
- (void)registerParsePurchaseProduct:(int)productId categoryId:(int)categoryId quantity:(int)quantity price:(float)price;
- (void)registerParseVisitCategory:(int)categoryId increment:(int)increment;
- (void)registerOrder:(Order*)order;

- (void)registerOpinionPoll:(ProductInfo*)pInfo;
- (void)fetchOpinionPoll:(ProductInfo*)pInfo;
- (void)fetchAllOpinionPoll;
- (void)installDeviceOnParse;
- (void)signInParse:(NSString*)EmailID;
- (void)registerParseCustomerUpdate;

- (void)registerParseCustomerWishlist;
- (void)registerParseCustomerCart;
- (void)registerParseCustomerPurchase:(Order*)order;
- (void)downloadLanguageFile:(NSString*)localeString;
- (void)downloadLanguageFileInBg:(NSString*)localeString;

//- (void)downloadLanguageFiles;
- (void)proceedSignOut;
- (void)updateNotificationReceivedCountOnParse:(NSString*)parsePushId;
- (void)loadAllPlatformData:(void(^)(void))success
                    failure:(void(^)(NSString* error))failure
                 markerInfo:(GMSMarker*)marker;
@end
