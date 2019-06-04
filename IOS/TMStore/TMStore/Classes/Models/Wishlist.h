//
//  Wishlist.h
//  eCommerceApp
//
//  Created by Rishabh Jain on 02/10/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProductInfo.h"
@interface Wishlist : NSObject <NSCoding>
@property int product_id;
@property int count;
@property int selectedVariationId;
@property int selectedVariationIndex;
@property ProductInfo* product;
@property NSMutableArray* selected_attributes;
@property NSString* productName;
@property NSString* productImgUrl;
@property float productPrice;

+ (void)refresh;
+ (float)getTotalPayment;
+ (float)getTotalSavings;
+ (NSMutableArray*)getAll;//ARRAY OF Wishlist
+ (int)getItemCount;
+ (void)prepareWishlist;
+ (void)addProduct:(ProductInfo*)product;
+ (void)removeProduct:(ProductInfo*)product productId:(int)productId variationId:(int)variationId;

//+ (void)removeProduct:(ProductInfo*)product;
+ (void)addProduct:(ProductInfo*)product variationId:(int)variationId;
//+ (void)removeProduct:(ProductInfo*)product variationId:(int)variationId;
+ (BOOL)hasItem:(ProductInfo*)product variationId:(int)variationId;
+ (BOOL)hasItem:(ProductInfo*)product;
+ (void)removeSafely:(Wishlist*)wishlist;
+ (void)printAll;
- (id)initWithParameters:(int)product_id product:(ProductInfo *)product variationId:(int)variationId variationIndex:(int)variationIndex;
+ (void)setWishlistArray:(NSMutableArray*)array;

+ (int)getNotificationItemCount;
+ (void)resetNotificationItemCount;
- (float)getWishlistTotal;
+ (void)addProductWithoutSync:(ProductInfo*)product;
@end
