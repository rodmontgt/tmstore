//
//  QuantityRule.m
//  TMStore
//
//  Created by Vikas Patidar on 07/11/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QuantityRule.h"

@implementation QuantityRule
- (id)init {
    if (self = [super init]) {
        self.orderrideRule = NO;
        self.stepValue = 1;
        self.minQuantity = 0;
        self.maxQuantity = 0;
        self.minOutOfStock = 0;
        self.maxOutOfStock = 0;
    }
    return self;
}
@end
