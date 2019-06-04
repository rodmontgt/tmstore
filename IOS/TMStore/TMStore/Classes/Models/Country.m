//
//  Country.m
//  eCommerceApp
//
//  Created by Rishabh Jain on 01/10/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import "Country.h"
static NSMutableArray* _allCountries = NULL;
@implementation TMCountry
- (id)init {
    self = [super init];
    if (self) {
        _countryId = @"";
        _countryName = @"";
        _countryStates = [[NSMutableArray alloc]init];
    }
    
    if (_allCountries == NULL) {
        _allCountries = [[NSMutableArray alloc] init];
    }
    [_allCountries addObject:self];
    
    return self;
}
- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        _countryId = [decoder decodeObjectForKey:@"#1"];
        _countryName = [decoder decodeObjectForKey:@"#2"];
        _countryStates = [decoder decodeObjectForKey:@"#3"];
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_countryId forKey:@"#1"];
    [encoder encodeObject:_countryName forKey:@"#2"];
    [encoder encodeObject:_countryStates forKey:@"#3"];
}
+ (NSMutableArray*)getAllCountries{
    return _allCountries;
}

+ (TMCountry*)getCountryById:(NSString*)countryId {
    for (TMCountry* obj in [TMCountry getAllCountries]) {
        if ([[obj.countryId uppercaseString] isEqualToString:[countryId uppercaseString]]) {
            return obj;
        }
    }
    return nil;
}
+ (TMCountry*)getCountryByName:(NSString*)countryName {
    for (TMCountry* obj in [TMCountry getAllCountries]) {
        if ([[obj.countryName uppercaseString] isEqualToString:[countryName uppercaseString]]) {
            return obj;
        }
    }
    return nil;
}
+ (int)getCountryIndex:(TMCountry*)country {
    int i = 0;
    for (TMCountry* obj in [TMCountry getAllCountries]) {
        if (obj == country) {
            return i;
        }
        i++;
    }
    return i;
}
+ (NSMutableArray*)getCountryNames {
    NSMutableArray* countryNames = [[NSMutableArray alloc] init];
    for (TMCountry* obj in [TMCountry getAllCountries]) {
        [countryNames addObject:obj.countryName];
    }
    return countryNames;
}
+ (TMCountry*)getCountryByIndex:(int)index {
    return [[TMCountry getAllCountries] objectAtIndex:index];
}

@end

@implementation TMState
- (id)init {
    self = [super init];
    if (self) {
        _stateId = @"";
        _stateName = @"";
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        _stateId = [decoder decodeObjectForKey:@"#1"];
        _stateName = [decoder decodeObjectForKey:@"#2"];
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_stateId forKey:@"#1"];
    [encoder encodeObject:_stateName forKey:@"#2"];
}
+ (TMState*)getStateById:(TMCountry*)country stateId:(NSString*)stateId {
    for (TMState* obj in country.countryStates) {
        if ([[obj.stateId uppercaseString] isEqualToString:[stateId uppercaseString]]) {
            return obj;
        }
    }
    return nil;
}
+ (TMState*)getStateByName:(TMCountry*)country stateName:(NSString*)stateName {
    for (TMState* obj in country.countryStates) {
        if ([[obj.stateName uppercaseString] isEqualToString:[stateName uppercaseString]]) {
            return obj;
        }
    }
    return nil;
}
+ (int)getStateIndex:(TMCountry*)country state:(TMState *)state{
    int i = 0;
    for (TMState* obj in country.countryStates) {
        if (obj == state) {
            return i;
        }
        i++;
    }
    return i;
}
+ (NSMutableArray*)getStateNames:(TMCountry*)country; {
    NSMutableArray* stateNames = [[NSMutableArray alloc] init];
    for (TMState* obj in country.countryStates) {
        [stateNames addObject:obj.stateName];
    }
    return stateNames;
}
+ (TMState*)getStateByIndex:(TMCountry*)country index:(int)index{
    return [country.countryStates objectAtIndex:index];
}
@end