//
//  PaymentDetail.m
//  eCommerceApp
//
//  Created by Rishabh Jain on 01/10/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import "PaymentDetail.h"

@implementation PaymentDetail

- (id)init {
    self = [super init];
    if (self) {
        self._method_id = @"";
        self._method_title = @"";
        self._paid = NO;
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self._method_id = [decoder decodeObjectForKey:@"#1"];
        self._method_title = [decoder decodeObjectForKey:@"#2"];
        self._paid = [decoder decodeBoolForKey:@"#3"];
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self._method_id forKey:@"#1"];
    [encoder encodeObject:self._method_title forKey:@"#2"];
    [encoder encodeBool:self._paid forKey:@"#3"];
}


@end
