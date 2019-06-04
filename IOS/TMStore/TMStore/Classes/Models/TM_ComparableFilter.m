//
//  TM_ComparableFilter.m
//  TMStore
//
//  Created by Rishabh Jain on 16/05/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import "TM_ComparableFilter.h"
@implementation TM_ComparableFilterAttribute
- (id)init {
    self = [super init];
    if (self) {
        _taxo = @"";
        _names = [[NSMutableArray alloc] init];
    }
    return self;
}
@end


@implementation TM_ComparableFilter
- (id)init {
    self = [super init];
    if (self) {
        _min_limit = 0.0f;
        _max_limit = 0.0f;
        _attribute = [[NSMutableArray alloc] init];
    }
    return self;
}
- (TM_ComparableFilterAttribute*)getMatchingAttribute:(NSString*)text {
    for (TM_ComparableFilterAttribute* obj in self.attribute) {
        if ([obj.taxo isEqualToString:text]) {
            return obj;
        }
    }
    return nil;
}
- (BOOL)hasAnyOptionInAttribute:(NSString*)attributeName {
    for (TM_ComparableFilterAttribute* attributeItem in self.attribute) {
        if ([attributeItem.taxo isEqualToString:attributeName]) {
            int count = (int)[attributeItem.names count];
            if (count == 0) {
                return false;
            }
            return true;
        }
    }
    return false;
}
@end
