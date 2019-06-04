//
//  DateTimeSlot.h
//  TMStore
//
//  Created by Rishabh Jain on 27/12/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#ifndef DateTimeSlot_h
#define DateTimeSlot_h
@interface DateTimeSlot : NSObject
{
    NSString* dateSlot;
    NSMutableArray* timeSlots;//Array of TimeSlot
    NSString* shippingMethodId;
}
- (id)init;
- (void)setTimeSlot:(NSMutableArray*)timeSlotsArray;
- (NSMutableArray*)getTimeSlot;
- (void)setDateSlot:(NSString*)dateSlotsString;
- (NSString*)getDateSlot;
- (NSString*)getShippingMethodId;
- (void)setShippingMethodId:(NSString*)shippingMethodIdString;

+ (NSMutableArray*)getAllDateTimeSlots;
+ (NSMutableArray*)getAllDateTimeSlots:(NSString*)methodId;
+ (NSDate*)getStartDate:(NSString*)methodId;
+ (NSDate*)getEndDate:(NSString*)methodId;
+ (DateTimeSlot*)getStartDateSlot:(NSString*)methodId;
+ (DateTimeSlot*)getEndDateSlot:(NSString*)methodId;

+ (BOOL)isShippingDependent;
+ (void)setShippingDenpendent:(BOOL)value;
@end
#endif /* DateTimeSlot_h */
