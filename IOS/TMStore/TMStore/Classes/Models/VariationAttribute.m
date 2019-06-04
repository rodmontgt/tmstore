//
//  VariationAttribute.m
//  WooMobil
//
//  Created by Rishabh Jain on 02/02/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import "VariationAttribute.h"

@implementation VariationAttribute


- (BOOL)isEqual:(VariationAttribute*)other{
    if ([self.name isEqualToString:other.name] && [self.value isEqualToString:other.value]) {
        return true;
    }
    return false;
}
- (id)init {
    self = [super init];
    if (self) {
        self.name = @"";
        self.slug = @"";
        self.value = @"";
        self.extraPrice = 0.0f;
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.name = [decoder decodeObjectForKey:@"#1"];
        self.slug = [decoder decodeObjectForKey:@"#2"];
        self.value = [decoder decodeObjectForKey:@"#3"];
        self.extraPrice = [decoder decodeFloatForKey:@"#4"];
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.name forKey:@"#1"];
    [encoder encodeObject:self.slug forKey:@"#2"];
    [encoder encodeObject:self.value forKey:@"#3"];
    [encoder encodeFloat:self.extraPrice forKey:@"#4"];
}
@end
