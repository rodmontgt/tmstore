//
//  TimeSlot.h
//  TMStore
//
//  Created by Rishabh Jain on 27/12/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#ifndef TimeSlot_h
#define TimeSlot_h
@interface TimeSlot : NSObject
@property NSString* slotId;
@property NSString* slotTitle;
@property NSString* slotCost;
@property id slotParent;
+ (NSMutableArray*)getAllTimeSlots;
- (id)init;
@end
#endif /* TimeSlot_h */
