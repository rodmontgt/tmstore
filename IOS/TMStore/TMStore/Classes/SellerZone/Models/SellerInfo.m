//
//  SellerInfo.m
//  TMStore
//
//  Created by Rishabh Jain on 28/08/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import "SellerInfo.h"
#import "Addons.h"
static SellerInfo* selectedSeller = nil;
static SellerInfo* currentSeller = nil;
static SellerInfo* currentSellerUpdated = nil;
static NSMutableArray* allSellerLocations = nil;
static NSMutableArray* allSellers = nil;
@implementation SellerInfo
+ (SellerInfo*)getCurrentSeller {
    return currentSeller;
}
+ (void)setCurrentSeller:(SellerInfo*)seller {
    currentSeller = seller;
}
+ (SellerInfo*)getCurrentSellerUpdated {
    return currentSellerUpdated;
}
+ (void)setCurrentSellerUpdated:(SellerInfo*)seller {
    currentSellerUpdated = seller;
}
+ (SellerInfo*)createCopyFrom:(SellerInfo*)oldObj {
    SellerInfo* newObj = [[SellerInfo alloc] init];
    [[SellerInfo getAllSellers] removeObject:newObj];
    newObj.sellerAvatarUrl = oldObj.sellerAvatarUrl;
    newObj.sellerId = oldObj.sellerId;
    newObj.sellerFirstName = oldObj.sellerFirstName;
    newObj.sellerLastName = oldObj.sellerLastName;
    newObj.shopLatitude = oldObj.shopLatitude;
    newObj.shopLongitude = oldObj.shopLongitude;
    newObj.membership_status = oldObj.membership_status;
    newObj.subscription_url = oldObj.subscription_url;
    newObj.sellerProfileUrl = oldObj.sellerProfileUrl;
    newObj.isSellerVerified = oldObj.isSellerVerified;
    newObj.sellerPhone = oldObj.sellerPhone;
    newObj.sellerInfo = oldObj.sellerInfo;
    newObj.shopName = oldObj.shopName;
    newObj.shopUrl = oldObj.shopUrl;
    newObj.shopIconUrl = oldObj.shopIconUrl;
    newObj.shopBannerUrl = oldObj.shopBannerUrl;
    newObj.shopAddress = oldObj.shopAddress;
    newObj.shopDescription = oldObj.shopDescription;
    return newObj;
}
- (id)init {
    self = [super init];
    if (self) {
        self.sellerAvatarUrl = @"";
        self.sellerId = @"";
        self.sellerFirstName = @"";
        self.sellerLastName = @"";
        self.sellerTitle = @"";//full name ie sellerFirstName + sellerLastName
        self.locations = [[NSMutableArray alloc] init];
        self.shopLatitude = -1.0;
        self.shopLongitude = -1.0;
        self.membership_status = @"";
        self.sellerProfileUrl = @"";
        self.isSellerVerified = NO;
        self.subscription_url = @"";
        self.sellerPhone = @"";
        self.sellerInfo = @"";
        self.shopName = @"";
        self.shopUrl = @"";
        self.shopIconUrl = @"";
        self.shopBannerUrl = @"";
        self.shopAddress = @"";
        self.shopDescription = @"";
        [[SellerInfo getAllSellers] addObject:self];
        self.sellerProducts = [[NSMutableArray alloc] init];
        self.productLoadedPageCount = 0;
    }
    return self;
}
- (NSString*)getSellerFirstLocation {
    if (self.locations != nil && [self.locations count] > 0)
        return [self.locations objectAtIndex:0];
    return @"";
}
+ (BOOL)hasSeller:(SellerInfo*)seller {
    NSMutableArray* array = [SellerInfo getAllSellers];
    for (SellerInfo* sellerTemp in array) {
        if ([sellerTemp.sellerId isEqualToString:seller.sellerId]) {
            return true;
        }
    }
    return false;
}
+ (SellerInfo*)getSellerInfoWithId:(NSString*)sellerId {
    NSMutableArray* array = [SellerInfo getAllSellers];
    for (SellerInfo* sellerTemp in array) {
        if ([sellerTemp.sellerId isEqualToString:sellerId]) {
            return sellerTemp;
        }
    }
    return nil;
}
+ (NSMutableArray*)getAllSellers {
    if (allSellers == nil) {
        allSellers = [[NSMutableArray alloc] init];
    }
    return allSellers;
}
+ (SellerInfo*)getSelectedSeller {
    return selectedSeller;
}
+ (void)setSelectedSeller:(SellerInfo*)seller {
    selectedSeller = seller;
}
- (BOOL)equals:(SellerInfo*)another {
    return [self.sellerId isEqualToString:another.sellerId];
}
+ (NSMutableArray*)getAllSellerLocations {
    if (allSellerLocations == nil) {
        allSellerLocations = [[NSMutableArray alloc] init];
    }
    return allSellerLocations;
}
+ (void)updateLocations:(NSMutableArray*)newLocations {
    NSMutableArray* array = [SellerInfo getAllSellerLocations];
    if (newLocations != nil) {
        for (NSString* newLocation in newLocations) {
            if (![array containsObject:newLocation]) {
                [array addObject:newLocation];
            }
        }
    }
}
+ (BOOL)hasAnyKeyWord:(NSString*)src tags:(NSMutableArray*)tags {
    for (NSString* tag in tags) {
        if ([[src lowercaseString] containsString:[tag lowercaseString]])
            return true;
    }
    return false;
}
+ (NSMutableArray*)getAllSellersWithLocation:(NSString*)location1 {
    NSMutableArray* sellersWithLocation = [[NSMutableArray alloc] init];
    NSMutableArray* array = [SellerInfo getAllSellers];
    
    for (SellerInfo* seller in array) {
        if (seller.locations != nil) {
            for (NSString* location2 in seller.locations) {
                if ([location2 isEqualToString:location1]) {
                    [sellersWithLocation addObject:seller];
                    break;
                }
            }
        }
    }
    return sellersWithLocation;
}
+ (SellerInfo*)findSellerById:(NSString*)sellerId {
    NSMutableArray* array = [SellerInfo getAllSellers];
    for (SellerInfo* seller in array) {
        if ([seller.sellerId isEqualToString:sellerId]) {
            return seller;
        }
    }
    return nil;
}
+ (NSMutableArray*)getAllSellersWithLocationAndKeyWords:(NSString*)location1 keyWords:(NSMutableArray*)keyWords {
    NSMutableArray* sellersWithLocation = [[NSMutableArray alloc] init];
    NSMutableArray* array = [SellerInfo getAllSellers];
    for (SellerInfo* seller in array) {
        if (seller.locations != nil) {
            for (NSString* location2 in seller.locations) {
                if ([location2 isEqualToString:location1] && [seller hasAnyKeyWord:keyWords]) {
                    [sellersWithLocation addObject:seller];
                    break;
                }
            }
        }
    }
    return sellersWithLocation;
}
- (BOOL)hasAnyKeyWord:(NSMutableArray*)keywords {
    for (NSString* keyword in keywords) {
        if ([[self.sellerTitle lowercaseString] containsString:[keyword lowercaseString]]) {
            return true;
        }
    }
    return false;
}

- (BOOL)hasKeyWord:(NSString*)tag {
    return [[self.sellerTitle lowercaseString] containsString:[tag lowercaseString]];
}
@end
