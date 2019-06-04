//
//  SellerZoneManager.m
//  TMStore
//
//  Created by Rajshekhar on 05/05/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import "SellerZoneManager.h"
#import "AppUser.h"

@implementation SellerZoneManager
static SellerZoneManager *sharedInstance = nil;
+ (id)getInstance {
    @synchronized(self) {
        if (sharedInstance == nil)
            sharedInstance = [[self alloc] init];
    }
    return sharedInstance;
}
- (id)init {
    self = [super init];
    if (self) {
        self.myOrders = [[NSMutableArray alloc] init];
        self.tempProduct = nil;
    }
    return self;
}
@end
