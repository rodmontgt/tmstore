//
//  FeeData.m
//  TMStore
//
//  Created by Rishabh Jain on 03/11/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import "FeeData.h"
static NSMutableArray* _allFeeData = nil;//ARRAY OF FeeData
@implementation FeeData
- (id)init {
    self = [super init];
    if (self) {
        _plugin_title = @"";
        _label = @"";
        _taxable = false;
        _minorder = 0.0f;
        _cost = 0.0f;
        if (_allFeeData == nil) {
            _allFeeData = [[NSMutableArray alloc] init];
        }
        [_allFeeData addObject:self];
    }
    return self;
}
+ (NSMutableArray*)getAllFeeData {
    return _allFeeData;
}
+ (void)resetFeeData {
    [[FeeData getAllFeeData] removeAllObjects];
}
@end