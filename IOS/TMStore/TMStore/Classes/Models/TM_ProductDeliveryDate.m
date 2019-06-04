//
//  TM_ProductDeliveryDate.m
//  TMStore
//
//  Created by Rishabh Jain on 20/03/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import "TM_ProductDeliveryDate.h"

@implementation TM_PRDD
- (id)init {
    self = [super init];
    if (self) {
        _prdd_enable_date = false;
        _prdd_enable_time = false;
        _prdd_recurring_chk = false;
//        _prdd_dates = [[NSMutableArray alloc] init];
        _prdd_days = [[NSMutableArray alloc] init];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.prdd_enable_date = [decoder decodeBoolForKey:@"#1"];
        self.prdd_enable_time = [decoder decodeBoolForKey:@"#2"];
        self.prdd_recurring_chk = [decoder decodeBoolForKey:@"#3"];
        self.prdd_days = [decoder decodeObjectForKey:@"#4"];
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeBool:self.prdd_enable_date forKey:@"#1"];
    [encoder encodeBool:self.prdd_enable_time forKey:@"#2"];
    [encoder encodeBool:self.prdd_recurring_chk forKey:@"#3"];
    [encoder encodeObject:self.prdd_days forKey:@"#4"];
}
@end

@implementation TM_PRDD_Day
- (id)init {
    self = [super init];
    if (self) {
        _prdd_day = 0;
        _prdd_day_enable = true;
        _prdd_times = [[NSMutableArray alloc] init];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.prdd_day = [decoder decodeIntForKey:@"#1"];
        self.prdd_day_enable = [decoder decodeBoolForKey:@"#2"];
        self.prdd_times = [decoder decodeObjectForKey:@"#3"];
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt:self.prdd_day forKey:@"#1"];
    [encoder encodeBool:self.prdd_day_enable forKey:@"#2"];
    [encoder encodeObject:self.prdd_times forKey:@"#3"];
}
@end

@implementation TM_PRDD_Time
- (id)init {
    self = [super init];
    if (self) {
        _slot_price = 0.0f;
        _slot_title = @"";
        _slot_lockout = -1;
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.slot_price = [decoder decodeFloatForKey:@"#1"];
        self.slot_title = [decoder decodeObjectForKey:@"#2"];
        self.slot_lockout = [decoder decodeIntForKey:@"#3"];
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeFloat:self.slot_price forKey:@"#1"];
    [encoder encodeObject:self.slot_title forKey:@"#2"];
    [encoder encodeInt:self.slot_lockout forKey:@"#3"];
}
@end