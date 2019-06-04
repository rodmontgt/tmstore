//
//  CurrencyHelper.m
//  TMStore
//
//  Created by Rishabh Jain on 27/12/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CurrencyHelper.h"
#import "Utility.h"
#import "CurrencyItem.h"
#import "TM_CommonInfo.h"

static NSString* currencyName = @"";
static CurrencyItem *currencyItem;

static TM_CommonInfo *tm_commonInfo;

@implementation CurrencyHelper

- (id)init {
    self = [super init];
    if (self) {

    }
    return self;
}
+ (void)setSelectedCurrencyItem:(CurrencyItem*)currency_Item{
    currencyItem = currency_Item;
    currencyName = [currencyItem name];
}

+ (void)setCurrencyName:(NSString*)currency_Name{
    currencyName = currency_Name;
    for (CurrencyItem * cItem in [CurrencyItem getAll]) {
        if ([cItem.name isEqualToString:currencyName]) {
            currencyItem = cItem;
        }
    }
}

+ (CurrencyItem*)getCurrencyItemWithName:(NSString*)currency_Name{
    for (CurrencyItem *cItem in [CurrencyItem getAll]) {
        if ([cItem.name isEqualToString:currency_Name]) {
            return cItem;
        }
    }
    return nil;
}
+ (void)applyCurrencyRate:(ProductInfo*)product{
    if (currencyItem == nil) {
        return;
    }
    tm_commonInfo.currency_format = [currencyItem symbol];
    tm_commonInfo.currency = [currencyItem name];
    NSLog(@"Product price before currency change: %f",product._price);
    product._price = [self applyRate:product._price];
    product._regular_price = [self applyRate:product._regular_price];
    product._sale_price = [self applyRate:product._sale_price];
    NSLog(@"Product price after currency change: %f",product._price);

}
+ (void)applyCurrencyRateForVariation:(Variation*)variation{
    if (currencyItem == nil) {
        return;
    }
    tm_commonInfo.currency_format = [currencyItem symbol];
    tm_commonInfo.currency = [currencyItem name];
    NSLog(@"Variation price before currency change: %f",variation._price);
    variation._price = [self applyRate:variation._price];
    variation._regular_price = [self applyRate:variation._regular_price];
    variation._sale_price = [self applyRate:variation._sale_price];
    NSLog(@"Variation price after currency change: %f",variation._price);

}
+ (float)applyRate:(float)price{
    return currencyItem == nil ? price : price * [currencyItem rate];
}
+ (float)parseSafeFloatPrice:(NSString*)input{
    if (input != nil && [input floatValue]> 0) {
        @try {
            return [input floatValue];
        } @catch (NSException *e1) {
            @try {
                if ([input containsString:@","]) {
                    input = [input stringByReplacingOccurrencesOfString:@"," withString:@"."];
                }
                return [input floatValue];
            } @catch (NSException *e2) {
            }
        }
     }
    return 0.0f;
}
@end
