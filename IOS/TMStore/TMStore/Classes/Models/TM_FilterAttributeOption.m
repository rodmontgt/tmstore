//
//  TM_FilterAttributeOption.m
//  TMStore
//
//  Created by Rishabh Jain on 16/05/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import "TM_FilterAttributeOption.h"

@implementation TM_FilterAttributeOption
- (id)init {
    self = [super init];
    if (self) {
        self.name = @"";
        self.slug = @"";
        self.taxo = @"";
        self.isVisible = true;
    }
    return self;
}
- (id)init:(TM_FilterAttributeOption*)other {
    self = [super init];
    if (self) {
        self.name = other.name;
        self.slug = other.slug;
        self.taxo = other.taxo;
    }
    return self;
}
@end
