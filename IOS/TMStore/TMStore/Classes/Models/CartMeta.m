//
//  CartMeta.m
//  TMStore
//
//  Created by Rishabh Jain on 02/11/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import "CartMeta.h"

@implementation AppliedCoupon
- (id)initWithTitle:(NSString*)title {
    self = [super init];
    if (self) {
        self.discount_amount = 0.0f;
        self.tax_amounts = 0.0f;
        self.title = title;
    }
    return self;
}
@end






static NSMutableArray* _applied_coupons = NULL;//ARRAY OF Coupon
static CartMeta *cartMetaInstance = nil;
@implementation CartMeta
- (NSMutableArray*)getAppliedCoupons {
    return _applied_coupons;
}
- (AppliedCoupon*)getAppliedCouponWithTitle:(NSString*)title {
    for (AppliedCoupon* appliedCoupon in _applied_coupons) {
        if ([appliedCoupon.title isEqualToString:title]) {
            return appliedCoupon;
        }
    }
    return nil;
}
- (void)resetCartMeta {
    [[[CartMeta sharedInstance] getAppliedCoupons] removeAllObjects];
}
- (id)init {
    self = [super init];
    if (self) {
        _applied_coupons = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (id)sharedInstance {
    @synchronized(self) {
        if (cartMetaInstance == nil){
            cartMetaInstance = [[self alloc] init];
        }
    }
    return cartMetaInstance;
}
@end
