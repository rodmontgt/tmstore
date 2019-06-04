//
//  Banner.h
//  TMStore
//
//  Created by Rishabh Jain on 19/05/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
enum BannerType {
    BANNER_SIMPLE = 0,
    BANNER_CATEGORY = 1,
    BANNER_PRODUCT = 2,
    BANNER_CART = 3,
    BANNER_WISHLIST = 4
};
@interface Banner : NSObject
@property NSString* bannerUrl;
@property int bannerType;
@property int bannerId;
- (id)init;
- (id)initWithoutAddingToArray;
+ (NSMutableArray*)getAllBanners;




@end
