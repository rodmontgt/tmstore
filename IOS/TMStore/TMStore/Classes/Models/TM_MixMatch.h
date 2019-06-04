//
//  TM_MixMatch.h
//  TMStore
//
//  Created by Rishabh Jain on 05/12/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Variables.h"
@interface TM_MixMatch : NSObject
@property NSMutableArray* matchingItems; // Array Of ProductInfo
@property int mixMatchingItemPurchaseCount;
@property int maxMatchingItemPurchaseCount;
@property BOOL per_product_pricing;
@property BOOL per_product_shipping;
@property BOOL is_synced;
@property float min_price;
@property float max_price;
@property float base_price;
@property float base_regular_price;
@property float base_sale_price;
@property float container_size;
- (id)init;
- (void)addMatchingItems:(id)product;
@end
