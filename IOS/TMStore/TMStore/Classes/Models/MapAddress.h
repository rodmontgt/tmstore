//
//  MapAddress.h
//  TMStore
//
//  Created by Rishabh Jain on 28/09/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Address.h"
@interface MapAddress : NSObject
@property int shipping_id;//not fetched form json
@property NSString* shipping_first_name;
@property NSString* shipping_last_name;
@property NSString* shipping_company;
@property NSString* shipping_country;
@property NSString* shipping_countryId;//not in json
@property NSString* shipping_address_1;
@property NSString* shipping_address_2;
@property NSString* shipping_city;
@property NSString* shipping_state;
@property NSString* shipping_postcode;
@property NSString* shipping_lat;
@property NSString* shipping_lng;
@property BOOL shipping_address_is_default;
- (id)init;
+ (NSMutableArray*)getAllAddresses;
+ (MapAddress*)getDefaultAddress;
+ (MapAddress*)getAddressById:(int)shipping_id;
+ (void)setAddressById:(int)shipping_id address:(Address*)address;
+ (void)setSelectedMapAddress:(MapAddress*)mapAddress;
+ (MapAddress*)getSelectedMapAddress;
+ (NSMutableArray*)getAllAddressesWithLatLong;
+ (NSString*)getFinalJsonString;
@end
