//
//  CurrencyItem.m
//  TMStore
//
//  Created by Rishabh Jain on 27/12/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CurrencyItem.h"
#import "Utility.h"

static NSMutableArray* currencyList = nil;
//static NSString* currencyName = @"";
//static NSString* currencySymbol = @"";
//static float* currencyRate;

@implementation CurrencyItem

- (id)init {
    self = [super init];
    if (self) {
        _name = @"";
        _symbol = @"";
        _position = @"";
        _rate = 0.0f;
        _is_etalon = 0;
        _hide_cents = 0;
        _decimals = 0;
        _desc = @"";
        _flag = @"";
    }
    return self;
}

+ (NSMutableArray*)currencyItemList {
    if (currencyList == nil) {
        currencyList = [[NSMutableArray alloc] init];
    }
    return currencyList;
}
+ (NSMutableArray*)getAll {
   return currencyList;
}

//+ (NSString*)getName {
//    return currencyName;
//}
//+ (NSString*)getSymbol {
//    return currencySymbol;
//}
//+ (float*)getRate {
//    return currencyRate;
//}
@end
