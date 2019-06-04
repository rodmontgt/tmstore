//
//  DateTimeSlot.m
//  TMStore
//
//  Created by Rishabh Jain on 27/12/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DateTimeSlot.h"
#import "TimeSlot.h"
static NSMutableArray* listDateTimeSlot = nil;
static BOOL shippingDependent = false;
@implementation DateTimeSlot
+ (NSMutableArray*)getAllDateTimeSlots {
    if (listDateTimeSlot == nil) {
        listDateTimeSlot = [[NSMutableArray alloc] init];
    }
    return listDateTimeSlot;
}
+ (NSDate*)getStartDate:(NSString*)methodId {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd/MM/yyyy"];
    NSMutableArray* allDateTimeSlots = [DateTimeSlot getAllDateTimeSlots:methodId];
    NSMutableArray* allDates = [[NSMutableArray alloc] init];
    for (DateTimeSlot* dts in allDateTimeSlots) {
        NSString *dateString = dts.getDateSlot;
        NSDate *dateFromString = [dateFormat dateFromString:dateString];
        [allDates addObject:dateFromString];
    }
    NSDate *startDate = nil; // Earliest date
    NSDate *endDate = nil; // Latest date
    for (id entry in allDates) {
        NSDate *date = entry;
        if (startDate == nil && endDate == nil) {
            startDate = date;
            endDate = date;
        }
        if ([date compare:startDate] == NSOrderedAscending) {
            startDate = date;
        }
        if ([date compare:endDate] == NSOrderedDescending) {
            endDate = date;
        }
        date = nil;
    }
    return startDate;
}
+ (NSDate*)getEndDate:(NSString*)methodId {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd/MM/yyyy"];
    NSMutableArray* allDateTimeSlots = [DateTimeSlot getAllDateTimeSlots:methodId];
    NSMutableArray* allDates = [[NSMutableArray alloc] init];
    for (DateTimeSlot* dts in allDateTimeSlots) {
        NSString *dateString = dts.getDateSlot;
        NSDate *dateFromString = [dateFormat dateFromString:dateString];
        [allDates addObject:dateFromString];
    }
    NSDate *startDate = nil; // Earliest date
    NSDate *endDate = nil; // Latest date
    for (id entry in allDates) {
        NSDate *date = entry;
        if (startDate == nil && endDate == nil) {
            startDate = date;
            endDate = date;
        }
        if ([date compare:startDate] == NSOrderedAscending) {
            startDate = date;
        }
        if ([date compare:endDate] == NSOrderedDescending) {
            endDate = date;
        }
        date = nil;
    }
    return endDate;
}
+ (DateTimeSlot*)getEndDateSlot:(NSString*)methodId {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd/MM/yyyy"];
    NSMutableArray* allDateTimeSlots = [DateTimeSlot getAllDateTimeSlots:methodId];
    NSMutableArray* allDates = [[NSMutableArray alloc] init];
    for (DateTimeSlot* dts in allDateTimeSlots) {
        NSString *dateString = dts.getDateSlot;
        NSDate *dateFromString = [dateFormat dateFromString:dateString];
        [allDates addObject:dateFromString];
    }
    NSDate *startDate = nil; // Earliest date
    NSDate *endDate = nil; // Latest date
    int startDateSlotIndex = -1; // Earliest date
    int endDateSlotIndex = -1; // Latest date

    int i = 0;
    for (id entry in allDates) {
        NSDate *date = entry;
        if (startDate == nil && endDate == nil) {
            startDate = date;
            endDate = date;
            startDateSlotIndex = 0;
            endDateSlotIndex = 0;
        }
        if ([date compare:startDate] == NSOrderedAscending) {
            startDate = date;
            startDateSlotIndex = i;
        }
        if ([date compare:endDate] == NSOrderedDescending) {
            endDate = date;
            endDateSlotIndex = i;
        }
        i++;
        date = nil;
    }
    
    if (i == -1) {
        return nil;
    }
    return [allDateTimeSlots objectAtIndex:endDateSlotIndex];
}
+ (DateTimeSlot*)getStartDateSlot:(NSString*)methodId {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd/MM/yyyy"];
    NSMutableArray* allDateTimeSlots = [DateTimeSlot getAllDateTimeSlots:methodId];
    NSMutableArray* allDates = [[NSMutableArray alloc] init];
    for (DateTimeSlot* dts in allDateTimeSlots) {
        NSString *dateString = dts.getDateSlot;
        NSDate *dateFromString = [dateFormat dateFromString:dateString];
        [allDates addObject:dateFromString];
    }
    NSDate *startDate = nil; // Earliest date
    NSDate *endDate = nil; // Latest date
    int startDateSlotIndex = -1; // Earliest date
    int endDateSlotIndex = -1; // Latest date
    
    int i = 0;
    for (id entry in allDates) {
        NSDate *date = entry;
        if (startDate == nil && endDate == nil) {
            startDate = date;
            endDate = date;
            startDateSlotIndex = 0;
            endDateSlotIndex = 0;
        }
        if ([date compare:startDate] == NSOrderedAscending) {
            startDate = date;
            startDateSlotIndex = i;
        }
        if ([date compare:endDate] == NSOrderedDescending) {
            endDate = date;
            endDateSlotIndex = i;
        }
        i++;
        date = nil;
    }
    
    if (i == -1) {
        return nil;
    }
    return [allDateTimeSlots objectAtIndex:startDateSlotIndex];
}
+ (NSMutableArray*)getAllDateTimeSlotsSequentially:(NSString*)methodId {
    if ([DateTimeSlot isShippingDependent] == false) {
        return [DateTimeSlot getAllDateTimeSlots];
    }
    
    NSDate *dateToday = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd/MM/yyyy"];
    
    NSMutableArray* tempArray = [[NSMutableArray alloc] init];
    for (DateTimeSlot* dtSlot in listDateTimeSlot) {
        if (dtSlot && [[dtSlot getShippingMethodId] isEqualToString:methodId]) {
            NSString *dateString = dtSlot.getDateSlot;
            NSDate *dateSlot = [dateFormat dateFromString:dateString];
            if ([dateSlot compare:dateToday] == NSOrderedDescending) {
                [tempArray addObject:dtSlot];
            }
        }
    }
    return tempArray;
}
+ (NSMutableArray*)getAllDateTimeSlots:(NSString*)methodId {
    if ([DateTimeSlot isShippingDependent] == false) {
        return [DateTimeSlot getAllDateTimeSlots];
    }
    
    NSDate *dateToday = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd/MM/yyyy"];
    
    NSMutableArray* tempArray = [[NSMutableArray alloc] init];
    for (DateTimeSlot* dtSlot in listDateTimeSlot) {
        if (dtSlot && [[dtSlot getShippingMethodId] isEqualToString:methodId]) {
            NSString *dateString = dtSlot.getDateSlot;
            NSDate *dateSlot = [dateFormat dateFromString:dateString];
            if ([dateSlot compare:dateToday] == NSOrderedDescending) {
                [tempArray addObject:dtSlot];
            }
        }
    }
    return tempArray;
}
- (id)init {
    self = [super init];
    if (self) {
        dateSlot = @"";
        timeSlots = [[NSMutableArray alloc] init];
        shippingMethodId = @"";
    }
    return self;
}

- (void)setTimeSlot:(NSMutableArray*)timeSlotsArray {
    timeSlots = timeSlotsArray;
    for (TimeSlot* timeSlot in timeSlots) {
        timeSlot.slotParent = self;
    }
}
- (NSMutableArray*)getTimeSlot {
    return timeSlots;
}
- (void)setDateSlot:(NSString*)dateSlotsString {
    dateSlot = dateSlotsString;
}
- (NSString*)getDateSlot {
    return dateSlot;
}
- (NSString*)getShippingMethodId {
    return shippingMethodId;
}
- (void)setShippingMethodId:(NSString*)shippingMethodIdString {
    shippingMethodId = shippingMethodIdString;
}
+ (BOOL)isShippingDependent {
    return shippingDependent;
}
+ (void)setShippingDenpendent:(BOOL)value {
    shippingDependent = value;
}
@end



