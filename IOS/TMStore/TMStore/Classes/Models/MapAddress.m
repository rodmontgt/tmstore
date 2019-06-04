//
//  MapAddress.m
//  TMStore
//
//  Created by Rishabh Jain on 28/09/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import "MapAddress.h"
static NSMutableArray* allMapAddresses = nil;
static MapAddress* mapAddressSelected = nil;
@implementation MapAddress
- (id)init {
    self = [super init];
    if (self) {
        self.shipping_first_name = @"";
        self.shipping_last_name = @"";
        self.shipping_company = @"";
        self.shipping_country = @"";
        self.shipping_address_1 = @"";
        self.shipping_address_2 = @"";
        self.shipping_city = @"";
        self.shipping_state = @"";
        self.shipping_postcode = @"";
        self.shipping_lat = @"";
        self.shipping_lng = @"";
        

        self.shipping_address_is_default = false;
        [[MapAddress getAllAddresses] addObject:self];
        self.shipping_id = (int)[[MapAddress getAllAddresses] count] - 1;
        
//        if (self.shipping_id == 0) {
//            self.shipping_lat = @"10.4534534";
//            self.shipping_lng = @"24.4534534";
//        }
//        if (self.shipping_id == 1) {
//            self.shipping_lat = @"15.4534534";
//            self.shipping_lng = @"24.4534534";
//        }
//        if (self.shipping_id == 2) {
//            self.shipping_lat = @"20.4534534";
//            self.shipping_lng = @"24.4534534";
//        }
//        if (self.shipping_id == 3) {
//            self.shipping_lat = @"25.4534534";
//            self.shipping_lng = @"24.4534534";
//        }
//        if (self.shipping_id == 4) {
//            self.shipping_lat = @"30.4534534";
//            self.shipping_lng = @"24.4534534";
//        }

        
        
    }
    return self;
}
+ (NSMutableArray*)getAllAddressesWithLatLong {
    NSMutableArray* arrayAddresses = [[NSMutableArray alloc] init];
    for (MapAddress* mAdd in [MapAddress getAllAddresses]) {
        if (![mAdd.shipping_lat isEqualToString:@""] && ![mAdd.shipping_lng isEqualToString:@""]) {
            [arrayAddresses addObject:mAdd];
        }
    }
    return arrayAddresses;
}
+ (NSMutableArray*)getAllAddresses {
    if (allMapAddresses == nil) {
        allMapAddresses = [[NSMutableArray alloc] init];
    }
    return allMapAddresses;
}
+ (MapAddress*)getDefaultAddress {
    for (MapAddress* mapAddress in [MapAddress getAllAddresses]) {
        if(mapAddress.shipping_address_is_default){
            return mapAddress;
        }
    }
    return nil;
}
+ (MapAddress*)getAddressById:(int)shipping_id {
    for (MapAddress* mapAddress in [MapAddress getAllAddresses]) {
        if(mapAddress.shipping_id == shipping_id){
            return mapAddress;
        }
    }
    return nil;
}
+ (void)setAddressById:(int)shipping_id address:(Address*)address {
    for (MapAddress* mapAddress in [MapAddress getAllAddresses]) {
        if(mapAddress.shipping_id == shipping_id){
            mapAddress.shipping_lat = address._first_name;
            mapAddress.shipping_lng = address._first_name;
            mapAddress.shipping_city = address._city;
            mapAddress.shipping_state = address._state;
            mapAddress.shipping_company = address._company;
            mapAddress.shipping_country = address._country;
            mapAddress.shipping_postcode = address._postcode;
            mapAddress.shipping_address_1 = address._address_1;
            mapAddress.shipping_address_2 = address._address_2;
            mapAddress.shipping_last_name = address._last_name;
            mapAddress.shipping_first_name = address._first_name;
            mapAddress.shipping_address_is_default = true;
        } else {
            mapAddress.shipping_address_is_default = false;
        }
    }
}
+ (void)setSelectedMapAddress:(MapAddress*)mapAddress {
    mapAddressSelected = mapAddress;
}
+ (MapAddress*)getSelectedMapAddress {
    return mapAddressSelected;
}
+ (NSString*)getFinalJsonString {
    NSMutableArray* finalArray = [[NSMutableArray alloc] init];
    for (MapAddress* mapAddress in [MapAddress getAllAddresses]) {
        NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
        [finalArray addObject:dict];
        if (mapAddress.shipping_lat) {
            [dict setValue:mapAddress.shipping_lat forKey:@"shipping_lat"];
        }
        if (mapAddress.shipping_lng) {
            [dict setValue:mapAddress.shipping_lng forKey:@"shipping_lng"];
        }
        if (mapAddress.shipping_city) {
            [dict setValue:mapAddress.shipping_city forKey:@"shipping_city"];
        }
        if (mapAddress.shipping_state) {
            [dict setValue:mapAddress.shipping_state forKey:@"shipping_state"];
        }
        if (mapAddress.shipping_company) {
            [dict setValue:mapAddress.shipping_company forKey:@"shipping_company"];
        }
        if (mapAddress.shipping_postcode) {
            [dict setValue:mapAddress.shipping_postcode forKey:@"shipping_postcode"];
        }
        if (mapAddress.shipping_address_1) {
            [dict setValue:mapAddress.shipping_address_1 forKey:@"shipping_address_1"];
        }
        if (mapAddress.shipping_address_2) {
            [dict setValue:mapAddress.shipping_address_2 forKey:@"shipping_address_2"];
        }
        if (mapAddress.shipping_last_name) {
            [dict setValue:mapAddress.shipping_last_name forKey:@"shipping_last_name"];
        }
        if (mapAddress.shipping_first_name) {
            [dict setValue:mapAddress.shipping_first_name forKey:@"shipping_first_name"];
        }
        if (mapAddress.shipping_address_is_default) {
            [dict setValue:@"true" forKey:@"shipping_address_is_default"];
        } else {
            [dict setValue:@"false" forKey:@"shipping_address_is_default"];
        }
    }
    
    NSError* error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:finalArray options:NSJSONWritingPrettyPrinted error:&error];
    NSString *finalArrayString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//    NSString *finalArrayString = [finalArray componentsJoinedByString:@" "];
//    finalArrayString = [NSString stringWithFormat:@"[%@]", finalArrayString];
    NSLog(@"%@",finalArrayString);
    return finalArrayString;

}
@end
