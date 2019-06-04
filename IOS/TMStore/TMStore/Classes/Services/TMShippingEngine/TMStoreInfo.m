//
//  TMStoreInfo.m
//  TMShippingSDK
//
//  Created by Rishabh Jain on 28/09/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import "TMStoreInfo.h"
static NSMutableArray* regionList = nil;
@implementation TMStoreInfo
- (id)init {
    self = [super init];
    if (self) {
        self.locations = [[NSMutableArray alloc] init];
        self.courier_types = [[NSMutableArray alloc] init];
    }
    return self;
}
@end
