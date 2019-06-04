//
//  MultiStoreCheckoutConfig.h
//  TMStore
//
//  Created by Rishabh Jain on 25/07/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSCDeliverSlot : NSObject
@property NSString* label;
@property NSArray* options;//Array of NSStrings
@property NSString* chosen_valt;
@property NSString* field;
@end


@interface MultiStoreCheckoutConfig : NSObject

@property NSString* deliveryTypeLabel;
@property NSString* deliveryTypeField;
@property NSString* selectedDeliveryType;
@property NSArray* deliveryTypeOptions;//Array of NSStrings

@property NSString* clusterDestinationsLabel;
@property NSString* clusterDestinationsField;
@property NSString* selectedClusterDestination;
@property NSArray* clusterDestinationsOptions;//Array of NSStrings

@property NSString* homeDestinationLabel;
@property NSString* homeDestinationField;
@property NSString* selectedHomeDestination;
@property NSArray* homeDestinationOptions;//Array of NSStrings


@property NSString* deliveryDaysLabel;
@property NSString* deliveryDaysField;
@property NSString* selectedDeliveryDay;
@property NSArray* deliveryDaysOptions;//Array of NSStrings

@property NSString* deliveryFee;

@property NSMutableArray* deliverSlots; //Array of MSCDeliverSlot


+ (id)getInstance;
- (MSCDeliverSlot*)getDeliverySlotForDay:(NSString*)selectedDay;
- (void)setMetaData:(NSMutableDictionary*)dict;
- (NSMutableDictionary*)getMetaData;
- (void)resetMetaData;

@property NSMutableDictionary* msMetaData;
@property BOOL isDataFetched;
@end

