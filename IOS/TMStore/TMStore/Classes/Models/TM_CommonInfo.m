//
//  TM_CommonInfo.m
//  TMStore
//
//  Created by Twist Mobile on 02/12/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import "TM_CommonInfo.h"

@implementation TM_CommonInfo
-(id)init{
    self = [super init];
    if (self) {
        timezone = @"Asia/Kolkata";
        _currency = @"INR";
        _currency_format = @"Rs.";
        _currency_position = @"left";
         _thousand_separator =@ ".";
         _decimal_separator = @",";
         _price_num_decimals = 2;
         _tax_included = false;
         _weight_unit = @"kg";
         _dimension_unit = @"cm";
        _hide_out_of_stock = false;
        
         _USE_OFFLINE_MODE = false;
         _SAVE_OFFLINE_DATA = false;
    }
    return self;
}
@end
