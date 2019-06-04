//
//  Address.m
//  eCommerceApp
//
//  Created by Rishabh Jain on 01/10/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import "Address.h"

@implementation Address

- (id)init {
    self = [super init];
    if (self) {
        // initialize instance variables here
        self._first_name = @"";
        self._last_name = @"";
        self._company = @"";
        self._address_1 = @"";
        self._address_2 = @"";
        self._city = @"";
        self._state = @"";
        self._postcode = @"";
        self._country = @"";
        self._email = @"";
        self._phone = @"";
        self._isBillingAddress = NO;
        self._isShippingAddress = NO;
        self._countryId = @"";
        self._stateId = @"";
        self._subdistrict = @"";
        self._subdistrictId = @"";
        self._district = @"";
        self._districtId = @"";
        self._cityId = @"";
        self._isAddressSaved = false;
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self._first_name = [decoder decodeObjectForKey:@"#1"];
        self._last_name = [decoder decodeObjectForKey:@"#2"];
        self._company = [decoder decodeObjectForKey:@"#3"];
        self._address_1 = [decoder decodeObjectForKey:@"#4"];
        self._address_2 = [decoder decodeObjectForKey:@"#5"];
        self._city = [decoder decodeObjectForKey:@"#6"];
        self._state = [decoder decodeObjectForKey:@"#7"];
        self._postcode = [decoder decodeObjectForKey:@"#8"];
        self._country = [decoder decodeObjectForKey:@"#9"];
        self._email = [decoder decodeObjectForKey:@"#10"];
        self._phone = [decoder decodeObjectForKey:@"#11"];
        self._isBillingAddress = [decoder decodeBoolForKey:@"#12"];
        self._isShippingAddress = [decoder decodeBoolForKey:@"#13"];
        self._countryId = [decoder decodeObjectForKey:@"#14"];
        self._stateId = [decoder decodeObjectForKey:@"#15"];
        self._subdistrict = [decoder decodeObjectForKey:@"#16"];
        self._subdistrictId = [decoder decodeObjectForKey:@"#17"];
        self._cityId = [decoder decodeObjectForKey:@"#18"];
        self._district = [decoder decodeObjectForKey:@"#19"];
        self._districtId = [decoder decodeObjectForKey:@"#20"];
        self._isAddressSaved = [decoder decodeBoolForKey:@"#21"];
   }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self._first_name forKey:@"#1"];
    [encoder encodeObject:self._last_name forKey:@"#2"];
    [encoder encodeObject:self._company forKey:@"#3"];
    [encoder encodeObject:self._address_1 forKey:@"#4"];
    [encoder encodeObject:self._address_2 forKey:@"#5"];
    [encoder encodeObject:self._city forKey:@"#6"];
    [encoder encodeObject:self._state forKey:@"#7"];
    [encoder encodeObject:self._postcode forKey:@"#8"];
    [encoder encodeObject:self._country forKey:@"#9"];
    [encoder encodeObject:self._email forKey:@"#10"];
    [encoder encodeObject:self._phone forKey:@"#11"];
    [encoder encodeBool:self._isBillingAddress forKey:@"#12"];
    [encoder encodeBool:self._isShippingAddress forKey:@"#13"];
    [encoder encodeObject:self._countryId forKey:@"#14"];
    [encoder encodeObject:self._stateId forKey:@"#15"];
    [encoder encodeObject:self._subdistrict forKey:@"#16"];
    [encoder encodeObject:self._subdistrictId forKey:@"#17"];
    [encoder encodeObject:self._cityId forKey:@"#18"];
    [encoder encodeObject:self._district forKey:@"#19"];
    [encoder encodeObject:self._districtId forKey:@"#20"];
    [encoder encodeBool:self._isAddressSaved forKey:@"#21"];
}
- (void)copyAddress:(Address*)address {
    self._first_name = [NSString stringWithFormat:@"%@", address._first_name];
    self._last_name = [NSString stringWithFormat:@"%@", address._last_name];
    self._company = [NSString stringWithFormat:@"%@", address._company];
    self._address_1 = [NSString stringWithFormat:@"%@", address._address_1];
    self._address_2 = [NSString stringWithFormat:@"%@", address._address_2];
    self._city = [NSString stringWithFormat:@"%@", address._city];
    self._state = [NSString stringWithFormat:@"%@", address._state];
    self._postcode = [NSString stringWithFormat:@"%@", address._postcode];
    self._country = [NSString stringWithFormat:@"%@", address._country];
    self._email = [NSString stringWithFormat:@"%@", address._email];
    self._phone = [NSString stringWithFormat:@"%@", address._phone];
    self._isBillingAddress = address._isBillingAddress;
    self._isShippingAddress = address._isShippingAddress;
    self._countryId = [NSString stringWithFormat:@"%@", address._countryId];
    self._stateId = [NSString stringWithFormat:@"%@", address._stateId];
    self._subdistrict = [NSString stringWithFormat:@"%@", address._subdistrict];
    self._subdistrictId = [NSString stringWithFormat:@"%@", address._subdistrictId];
    self._cityId = [NSString stringWithFormat:@"%@", address._cityId];
    self._district = [NSString stringWithFormat:@"%@", address._district];
    self._districtId = [NSString stringWithFormat:@"%@", address._districtId];
    self._isAddressSaved = address._isAddressSaved;
}
@end
