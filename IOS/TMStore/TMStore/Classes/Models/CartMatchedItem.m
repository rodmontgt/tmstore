//
//  CartMatchedItem.m
//  TMStore
//
//  Created by Rishabh Jain on 08/12/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import "CartMatchedItem.h"
@implementation CartMatchedItem
- (id)init {
    self = [super init];
    if (self) {
        self.productId = -1;
        self.title = @"";
        self.price = 0.0f;
        self.imgUrl = @"";
        self.quantity = 0;
        self.product = nil;
    }
    return self;
}
- (float)getTotalPrice {
   return self.price * self.quantity;
}
@end