//
//  TM_CommonInfo.h
//  TMStore
//
//  Created by Twist Mobile on 02/12/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
enum SORTING_TYPE{
    FRESH_ARRIVALS,
    FEATURED,
    USER_RATING,
    PRICE_HIGH_TO_LOW,
    PRICE_LOW_TO_HIGH,
    POPULARITY,
    SORTING_TOTAL_TYPE
};
static NSString *SORTING_TYPE_STRING[SORTING_TOTAL_TYPE] = {
    @"sort_fresh_arrival",
    @"sort_featured",
    @"sort_user_rating",
    @"sort_price_high_to_low",
    @"sort_price_low_to_high",
    @"sort_popularity",
};
@interface TM_CommonInfo : NSObject

@property NSString *timezone;
@property NSString *currency;
@property NSString *currency_format;
@property NSString *currency_position;
@property NSString *thousand_separator;
@property NSString *decimal_separator;
@property int price_num_decimals;
@property BOOL tax_included;
@property NSString *weight_unit;
@property NSString *dimension_unit;
@property BOOL hide_out_of_stock;

@property BOOL USE_OFFLINE_MODE;
@property BOOL SAVE_OFFLINE_DATA;

@end
