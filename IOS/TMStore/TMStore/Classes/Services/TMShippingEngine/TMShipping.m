//
//  TMShipping.m
//  TMShippingSDK
//
//  Created by Rishabh Jain on 28/09/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import "TMShipping.h"
@implementation TMShipping
static BOOL SHIPPING_REQUIRED = true;
- (id)init {
    self = [super init];
    if (self) {
        _shippingId = @"";
        _shippingLabel = @"";
        _shippingMethodId = @"";
        _shippingDescription = @"";
        _shippingEtd = @"";
        _shippingTaxes = [[NSMutableArray alloc] init];
        _shippingCost = 0.0f;
        _taxable = true;
    }
    return self;
}
+ (BOOL)SHIPPING_REQUIRED;{
    return SHIPPING_REQUIRED;
}
- (void)setSHIPPING_REQUIRED:(BOOL)value {
    SHIPPING_REQUIRED = value;
}
@end
