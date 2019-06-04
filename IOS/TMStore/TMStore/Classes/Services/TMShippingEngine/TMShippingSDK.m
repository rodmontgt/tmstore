//
//  TMShippingSDK.m
//  TMShippingSDK
//
//  Created by Rishabh Jain on 28/09/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import "TMShippingSDK.h"

@implementation TMShippingSDK
//+ (id)getInstance {
//    static TMShippingSDK *instanceObj = nil;
//    @synchronized(self) {
//        if (instanceObj == nil)
//            instanceObj = [[self alloc] init];
//    }
//    return instanceObj;
//}
- (id)init {
    self = [super init];
    if (self) {
        PLOG(@"TMPaymentSDK INIT");
        _shippingMethods = [[NSMutableArray alloc] init];
        _shippingMethodChoosedId = @"";
        _shippingEnable = false;
    }
    return self;
}
- (void)resetShippingMethods {
    [_shippingMethods removeAllObjects];
    RLOG(@"ShippingMethods reset.");
}
- (void)addShippingMethod:(TMShipping*)obj {
    [_shippingMethods addObject:obj];
    RLOG(@"ShippingMethod added.");
}
@end



@implementation ShippingConfigWooCommerce
static ShippingConfigWooCommerce *iVarWoocommerce = nil;
+ (id)getInstance {
    @synchronized(self) {
        if (iVarWoocommerce == nil){
            iVarWoocommerce = [[self alloc] init];
        }
    }
    return iVarWoocommerce;
}
- (id)init {
    self = [super self];
    if (self) {
        self.cProvider = @"woocommerce";
        self.cIsEnabled = true;
        self.cBaseUrl = @"";
    }
    return self;
}
@end


@implementation ShippingConfigRajaongkir
static ShippingConfigRajaongkir *iVarRajaongkir = nil;
+ (id)getInstance {
    @synchronized(self) {
        if (iVarRajaongkir == nil){
            iVarRajaongkir = [[self alloc] init];
        }
    }
    return iVarRajaongkir;
}
- (id)init {
    self = [super self];
    if (self) {
        self.cProvider = @"rajaongkir";
        self.cIsEnabled = false;
        self.cKey = @"";
        self.cMinWeight = 0.0f;
        self.cDefaultWeight = 0.0f;
    }
    return self;
}
@end