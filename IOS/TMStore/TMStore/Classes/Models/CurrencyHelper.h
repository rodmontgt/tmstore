//
//  CurrencyHelper.h
//  TMStore
//
//  Created by Rishabh Jain on 27/12/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CurrencyItem.h"
#import "ProductInfo.h"
#import "Variation.h"
@interface CurrencyHelper : NSObject


+ (void)setSelectedCurrencyItem:(CurrencyItem*)currency_Item;
+ (void)setCurrencyName:(NSString*)currency_Name;
+ (CurrencyItem*)getCurrencyItemWithName:(NSString*)currency_Name;
+ (void)applyCurrencyRate:(ProductInfo*)product;
+ (float)applyRate:(float)price;
+ (void)applyCurrencyRateForVariation:(Variation*)variation;
+ (float)parseSafeFloatPrice:(NSString*)input;

@end
