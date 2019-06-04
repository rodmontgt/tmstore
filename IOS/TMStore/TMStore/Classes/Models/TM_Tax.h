//
//  TM_Tax.h
//  TMStore
//
//  Created by Rishabh Jain on 16/05/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Variables.h"

@interface TM_Tax : NSObject
@property int taxId;
@property NSString* country;//only one
@property NSString* state;//only one
@property NSString* postcode;//multiple
@property NSString* city;//multiple
@property double rate;
@property NSString* name;
@property int priority;
@property BOOL compound;
@property BOOL shipping;
@property int order;
@property NSString* taxClass;
@property NSMutableDictionary* additionalProperties;

@property NSArray* cities;
@property NSArray* postalCodes;
- (id)init;
+ (NSMutableArray*)getAllTaxes;
@end


@interface TM_TaxApplied : NSObject
@property int taxId;
@property NSString* country;
@property NSString* state;
@property NSString* postcode;
@property NSString* city;
@property double rate;
@property NSString* name;
@property int priority;
@property BOOL compound;
@property BOOL shipping;
@property int order;
@property NSString* taxClass;
@property NSMutableDictionary* additionalProperties;
@property NSArray* cities;
@property NSArray* postalCodes;
- (id)init;
+ (NSMutableArray*)getAllTaxesApplied;
@property float netTax;
+ (float)calculateTotalTax:(float)shippingCost;
+ (float)calculateTaxProduct:(float)cost productTaxClass:(NSString*)productTaxClass isProductTaxable:(BOOL)isProductTaxable isShippingNecessary:(BOOL)isShippingNecessary;
+ (float)calculateTaxProductOriginal:(float)cost productTaxClass:(NSString*)productTaxClass isProductTaxable:(BOOL)isProductTaxable isShippingNecessary:(BOOL)isShippingNecessary;
+ (float)calculateTotalTaxOnCheckoutAddons;
@end
