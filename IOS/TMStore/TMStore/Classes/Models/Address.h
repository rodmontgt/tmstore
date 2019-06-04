//
//  Address.h
//  eCommerceApp
//
//  Created by Rishabh Jain on 01/10/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Variables.h"
#import "TMRegion.h"

@interface Address : NSObject <NSCoding>
@property BOOL _isBillingAddress;
@property BOOL _isShippingAddress;

//need in billing and shipping address
@property NSString *_first_name;
@property NSString *_last_name;
@property NSString *_company;
@property NSString *_address_1;
@property NSString *_address_2;
@property NSString *_city;
@property NSString *_cityId;
@property NSString *_district;
@property NSString *_districtId;
@property NSString *_subdistrict;
@property NSString *_subdistrictId;
@property NSString *_state;
@property NSString *_stateId;
@property NSString *_country;
@property NSString *_countryId;
@property NSString *_postcode;
//need only in billing address
@property NSString *_email;
@property NSString *_phone;

@property BOOL _isAddressSaved;
- (id)init;
- (void)copyAddress:(Address*)address;
@end
