//
//  CartMeta.h
//  TMStore
//
//  Created by Rishabh Jain on 02/11/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Variables.h"


@interface AppliedCoupon : NSObject
@property float discount_amount;
@property float tax_amounts;
@property NSString* title;
- (id)initWithTitle:(NSString*)title;
@end


@interface CartMeta : NSObject
+ (id)sharedInstance;
- (NSMutableArray*)getAppliedCoupons;
- (AppliedCoupon*)getAppliedCouponWithTitle:(NSString*)title;
- (void)resetCartMeta;
@end
