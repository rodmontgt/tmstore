//
//  TM_ProductDeliveryDate.h
//  TMStore
//
//  Created by Rishabh Jain on 20/03/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TM_PRDD_Day : NSObject
@property NSMutableArray* prdd_times;
@property int prdd_day; //sun = 0, mon = 1, tue = 2, wed = 3, thu = 4, fri = 5, sat = 6
@property BOOL prdd_day_enable;
@end

@interface TM_PRDD_Time : NSObject
@property float slot_price;
@property NSString* slot_title;
@property int slot_lockout;
@end

@interface TM_PRDD : NSObject
@property BOOL prdd_enable_date;
@property BOOL prdd_enable_time;
@property BOOL prdd_recurring_chk;
//@property NSMutableArray* prdd_dates;
@property NSMutableArray* prdd_days;

@end

