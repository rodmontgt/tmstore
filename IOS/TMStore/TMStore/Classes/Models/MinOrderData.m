//
//  MinOrderData.m
//  TMStore
//
//  Created by Rishabh Jain on 03/11/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//
#import "MinOrderData.h"
static MinOrderData *minOrderDataInstance = nil;
@implementation MinOrderData
+ (id)sharedInstance {
    @synchronized(self) {
        if (minOrderDataInstance == nil){
            minOrderDataInstance = [[self alloc] init];
        }
    }
    return minOrderDataInstance;
}
- (id)init {
    self = [super init];
    if (self) {
        _minOrderAmount = 0;
        _minOrderMessage = @"";
    }
    return self;
}
- (void)resetMinOrderData {
    MinOrderData* minOrderData = [MinOrderData sharedInstance];
    minOrderData.minOrderAmount = 0.0f;
    minOrderData.minOrderMessage = @"";
}
@end