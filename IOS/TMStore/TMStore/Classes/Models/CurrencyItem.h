//
//  CurrencyItem.h
//  TMStore
//
//  Created by Rishabh Jain on 27/12/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CurrencyItem : NSObject

@property NSString* name;
@property NSString* symbol;
@property NSString* position;
@property NSString* desc;
@property NSString* flag;
@property float rate;
@property int is_etalon;
@property int hide_cents;
@property int decimals;

+ (NSMutableArray*)currencyItemList;
+ (NSMutableArray*)getAll;

//+ (NSString*)getName;
//+ (NSString*)getSymbol;
//+ (float*)getRate;
//
@end
