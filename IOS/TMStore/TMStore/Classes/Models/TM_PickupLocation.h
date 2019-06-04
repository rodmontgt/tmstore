//
//  TM_PickupLocation.h
//  TMStore
//
//  Created by Rishabh Jain on 08/03/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TM_PickupLocation : NSObject
- (id)init;
+ (void)clearAllPickupLocations;
+ (NSMutableArray*)getAllPickupLocations;
@property NSString* country;
@property NSString* cost;
@property NSString* pickupId;
@property NSString* note;
@property NSString* company;
@property NSString* address_1;
@property NSString* address_2;
@property NSString* city;
@property NSString* state;
@property NSString* postcode;
@property NSString* phone;

- (NSAttributedString*)getLocationStringAttributed;
@end
