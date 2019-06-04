//
//  TMShippingMethod.m
//  TMPaymentSDK
//
//  Created by Rishabh Jain on 04/04/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import "TMShippingMethod.h"

@implementation TMShippingMethod
- (id)init {
    self = [super self];
    if (self) {
        PLOG(@"TMShippingMethod INIT");
        _shippingId = @"";
        _shippingCost = 0.0f;
        _shippingLabel = @"";
        _shippingMethod = @"";
        _shippingTaxes = [[NSMutableArray alloc] init];
    }
    return self;
}
- (id)initWithDictionary:(NSDictionary*) dict {
    self = [self init];
    if (IS_NOT_NULL(dict, @"id")) {
        _shippingId = GET_VALUE_STRING(dict, @"id");
    }
    if (IS_NOT_NULL(dict, @"cost")) {
        _shippingCost = GET_VALUE_FLOAT(dict, @"cost");
    }
    if (IS_NOT_NULL(dict, @"label")) {
        _shippingLabel = GET_VALUE_STRING(dict, @"label");
    }
    if (IS_NOT_NULL(dict, @"method_id")) {
        _shippingMethod = GET_VALUE_STRING(dict, @"method_id");
    }
//    if (IS_NOT_NULL(dict, @"taxes")) {
//        _shippingTaxes = GET_VALUE_OBJECT(dict, @"taxes");
//    }
    return self;
}
@end
