//
//  TimeSlot.m
//  TMStore
//
//  Created by Rishabh Jain on 27/12/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TimeSlot.h"
static NSMutableArray* listTimeSlot = nil;
@implementation TimeSlot
+ (NSMutableArray*)getAllTimeSlots {
    if (listTimeSlot == nil) {
        listTimeSlot = [[NSMutableArray alloc] init];
    }
    return listTimeSlot;
}
- (id)init {
    self = [super init];
    if (self) {
        _slotCost = @"";
        _slotId = @"";
        _slotParent = nil;
        _slotTitle = @"";
    }
    return self;
}

@end
