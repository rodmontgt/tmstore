//
//  TMShippingSDK.h
//  TMShippingSDK
//
//  Created by Rishabh Jain on 28/09/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMShipping.h"
#import "Variables.h"
@interface TMShippingSDK : NSObject
@property NSMutableArray* shippingMethods;//Array of TMShipping
@property NSString* shippingMethodChoosedId;
@property BOOL shippingEnable;
- (void)addShippingMethod:(TMShipping*)obj;
- (void)resetShippingMethods;
//+ (id)getInstance;
- (id)init;
@end


@interface ShippingConfigWooCommerce : NSObject
@property NSString* cProvider;
@property BOOL cIsEnabled;
@property NSString* cBaseUrl;
+ (id)getInstance;
@end

@interface ShippingConfigRajaongkir : NSObject
@property NSString* cProvider;
@property BOOL cIsEnabled;
@property NSString* cBaseUrl;
@property NSString* cKey;
@property float cMinWeight;
@property float cDefaultWeight;
+ (id)getInstance;
@end