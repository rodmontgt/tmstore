//
//  TM_MixMatch.m
//  TMStore
//
//  Created by Rishabh Jain on 05/12/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import "TM_MixMatch.h"
@implementation TM_MixMatch
- (id)init {
    self = [super init];
    if (self) {
        self.matchingItems = [[NSMutableArray alloc] init];
        self.mixMatchingItemPurchaseCount = 0;
        self.maxMatchingItemPurchaseCount = 0;
        self.per_product_pricing = false;
        self.per_product_shipping = false;
        self.is_synced = false;
        self.min_price = 0;
        self.max_price = 0;
        self.base_price = 0;
        self.base_regular_price = 0;
        self.base_sale_price = 0;
        self.container_size = 0;
    }
    return self;
}
- (void)addMatchingItems:(id)product {
    [self.matchingItems addObject:product];
}
@end
