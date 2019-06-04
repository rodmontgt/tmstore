//
//  Dimension.m
//  eCommerceApp
//
//  Created by Rishabh Jain on 01/10/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import "Dimension.h"

@implementation Dimension


- (id)init {
    self = [super init];
    if (self) {
        // initialize instance variables here
        
        self._height = 0;
        self._width= 0;
        self._length = 0;
        self._unit = @"";
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self._height = [decoder decodeFloatForKey:@"#1"];
        self._width = [decoder decodeFloatForKey:@"#2"];
        self._length = [decoder decodeFloatForKey:@"#3"];
        self._unit = [decoder decodeObjectForKey:@"#4"];
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeFloat:self._height forKey:@"#1"];
    [encoder encodeFloat:self._width forKey:@"#2"];
    [encoder encodeFloat:self._length forKey:@"#3"];
    [encoder encodeObject:self._unit forKey:@"#4"];
}
@end
