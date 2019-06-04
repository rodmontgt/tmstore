//
//  TM_CheckoutAddon.m
//  TMStore
//
//  Created by Rishabh Jain on 12/04/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import "TM_CheckoutAddon.h"
static NSMutableArray* allCheckoutAddons = NULL;
static NSMutableArray* selectedCheckoutAddons = NULL;
static NSString* orderScreenNote = @"";
@implementation TM_CheckoutAddon
- (id)init {
    self = [super init];
    if (self) {
        self.cost = 0.0f;
        self.label = @"";
        self.name = @"";
        self.type = TM_CheckoutAddonType_CHECKBOX;
        self.taxClass = @"standard";
        if (allCheckoutAddons == NULL) {
            allCheckoutAddons = [[NSMutableArray alloc] init];
        }
        [allCheckoutAddons addObject:self];
    }
    return self;
}
+ (NSMutableArray*)getAllCheckoutAddons {
    if (allCheckoutAddons == NULL) {
        allCheckoutAddons = [[NSMutableArray alloc] init];
    }
    return allCheckoutAddons;
}
+ (void)clearAllCheckoutAddons {
    if (allCheckoutAddons == NULL) {
        allCheckoutAddons = [[NSMutableArray alloc] init];
    }
    [allCheckoutAddons removeAllObjects];
}
+ (NSMutableArray*)getSelectedCheckoutAddons {
    if (selectedCheckoutAddons == NULL) {
        selectedCheckoutAddons = [[NSMutableArray alloc] init];
    }
    return selectedCheckoutAddons;
}
+ (void)clearSelectedCheckoutAddons {
    if (selectedCheckoutAddons == NULL) {
        selectedCheckoutAddons = [[NSMutableArray alloc] init];
    }
    [selectedCheckoutAddons removeAllObjects];
}
+ (void)addToSelectedCheckoutAddons:(TM_CheckoutAddon*)obj {
    if (selectedCheckoutAddons == NULL) {
        selectedCheckoutAddons = [[NSMutableArray alloc] init];
    }
    [selectedCheckoutAddons addObject:obj];
}
+ (NSString*)getOrderScreenNote {
    return orderScreenNote;
}
+ (void)setOrderScreenNote:(NSString*)value {
    orderScreenNote = value;
}
@end
