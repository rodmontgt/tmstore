//
//  TMShippingMethod.h
//  TMPaymentSDK
//
//  Created by Rishabh Jain on 04/04/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMPaymentVariables.h"
@interface TMShippingMethod : NSObject
@property NSString* shippingId;
@property float shippingCost;
@property NSString* shippingLabel;
@property NSString* shippingMethod;
@property NSMutableArray* shippingTaxes;

- (id)init;
- (id)initWithDictionary:(NSDictionary*) dict;
@end
