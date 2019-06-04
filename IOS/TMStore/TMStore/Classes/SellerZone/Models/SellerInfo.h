//
//  SellerInfo.h
//  TMStore
//
//  Created by Rishabh Jain on 28/08/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SellerInfo : NSObject
@property NSString* sellerAvatarUrl;
@property NSString* sellerFirstName;
@property NSString* sellerLastName;
@property NSString* sellerTitle;
@property NSString* sellerId;
@property NSString* sellerInfo;
@property NSString* sellerPhone;
@property NSString* sellerProfileUrl;
@property NSString* membership_status;
@property NSString* subscription_url;
@property BOOL isSellerVerified;
@property NSMutableArray* locations;
@property double shopLatitude;
@property double shopLongitude;
@property NSString* shopAddress;
@property NSString* shopBannerUrl;
@property NSString* shopDescription;
@property NSString* shopIconUrl;
@property NSString* shopName;
@property NSString* shopUrl;
@property NSMutableArray* sellerProducts;
@property int productLoadedPageCount;
+ (id)sharedManager;
+ (SellerInfo*)getCurrentSeller;
+ (void)setCurrentSeller:(SellerInfo*)seller;
+ (SellerInfo*)getCurrentSellerUpdated;
+ (void)setCurrentSellerUpdated:(SellerInfo*)seller;
- (id)init;
- (NSString*)getSellerFirstLocation;
+ (BOOL)hasSeller:(SellerInfo*)seller;
+ (SellerInfo*)getSellerInfoWithId:(NSString*)sellerId;
+ (NSMutableArray*)getAllSellers;
+ (SellerInfo*)getSelectedSeller;
+ (void)setSelectedSeller:(SellerInfo*)seller;
- (BOOL)equals:(SellerInfo*)another;
+ (NSMutableArray*)getAllSellerLocations;
+ (void)updateLocations:(NSMutableArray*)newLocations;
+ (BOOL)hasAnyKeyWord:(NSString*)src tags:(NSMutableArray*)tags;
+ (NSMutableArray*)getAllSellersWithLocation:(NSString*)location1;
+ (SellerInfo*)findSellerById:(NSString*)sellerId;
+ (NSMutableArray*)getAllSellersWithLocationAndKeyWords:(NSString*)location1 keyWords:(NSMutableArray*)keyWords;
+ (SellerInfo*)createCopyFrom:(SellerInfo*)oldObj;
@end
