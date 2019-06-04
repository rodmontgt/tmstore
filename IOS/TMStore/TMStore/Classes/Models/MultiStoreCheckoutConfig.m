//
//  MultiStoreCheckoutConfig.m
//  TMStore
//
//  Created by Rishabh Jain on 25/07/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import "MultiStoreCheckoutConfig.h"

@implementation MultiStoreCheckoutConfig
static MultiStoreCheckoutConfig *sharedInstance = nil;
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
        self.deliveryTypeLabel = @"";
        self.deliveryTypeField = @"";
        self.selectedDeliveryType = @"";
        self.deliveryTypeOptions = [[NSMutableArray alloc] init];//Array of NSStrings
        
        self.homeDestinationLabel = @"";
        self.homeDestinationField = @"";
        self.selectedHomeDestination = @"";
        self.homeDestinationOptions = [[NSMutableArray alloc] init];//Array of NSStrings
        
        self.clusterDestinationsLabel = @"";
        self.clusterDestinationsField = @"";
        self.selectedClusterDestination = @"";
        self.clusterDestinationsOptions = [[NSMutableArray alloc] init];//Array of NSStrings
        
        self.deliveryDaysLabel = @"";
        self.deliveryDaysField = @"";
        self.selectedDeliveryDay = @"";
        self.deliveryDaysOptions = [[NSMutableArray alloc] init];//Array of NSStrings
        
        self.deliveryFee = @"";
        
        self.deliverSlots = [[NSMutableArray alloc] init]; //Array of MSCDeliverSlot
        
        self.isDataFetched = false;
        
        self.msMetaData = nil;
    }
    return self;
}
- (MSCDeliverSlot*)getDeliverySlotForDay:(NSString*)selectedDay {
    selectedDay = [[selectedDay lowercaseString] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
    for (MSCDeliverSlot* mscd in self.deliverSlots) {
        NSString* choosedValt = [[mscd.chosen_valt lowercaseString] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
        if ([choosedValt isEqualToString:selectedDay]) {
            return mscd;
        }
    }
    return nil;
}
- (void)setMetaData:(NSMutableDictionary*)dict {
    if (dict && ([dict isKindOfClass:[NSDictionary class]] || [dict isKindOfClass:[NSMutableDictionary class]])) {
        self.msMetaData = [[NSMutableDictionary alloc] initWithDictionary:dict];
    }
}
- (NSMutableDictionary*)getMetaData {
    return self.msMetaData;
}
- (void)resetMetaData {
    if (self.msMetaData) {
        [self.msMetaData removeAllObjects];
    }
    self.msMetaData = nil;
}
@end

@implementation MSCDeliverSlot
- (id)init {
    self = [super init];
    if (self) {
        self.label = @"";
        self.chosen_valt = @"";
        self.field = @"";
        self.options = [[NSMutableArray alloc] init];//Array of NSStrings
    }
    return self;
}
@end
