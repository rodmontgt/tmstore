//
//  QuantityRule.h
//  TMStore
//
//  Created by Vikas Patidar on 07/11/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QuantityRule : NSObject

@property BOOL orderrideRule;
@property int stepValue;
@property int minQuantity;
@property int maxQuantity;
@property int minOutOfStock;
@property int maxOutOfStock;

@end
