//
//  Country.h
//  eCommerceApp
//
//  Created by Rishabh Jain on 01/10/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TMCountry : NSObject
@property NSString *countryName;
@property NSString *countryId;
@property NSMutableArray *countryStates;
- (id)init;
+ (NSMutableArray*)getAllCountries;
+ (TMCountry*)getCountryByName:(NSString*)countryName;
+ (TMCountry*)getCountryById:(NSString*)countryId;
+ (int)getCountryIndex:(TMCountry*)country;
+ (TMCountry*)getCountryByIndex:(int)index;
+ (NSMutableArray*)getCountryNames;
@end

@interface TMState : NSObject
@property NSString *stateName;
@property NSString *stateId;
- (id)init;
+ (TMState*)getStateById:(TMCountry*)country stateId:(NSString*)stateId;
+ (TMState*)getStateByName:(TMCountry*)country stateName:(NSString*)stateName;
+ (int)getStateIndex:(TMCountry*)country state:(TMState*)state;
+ (NSMutableArray*)getStateNames:(TMCountry*)country;
+ (TMState*)getStateByIndex:(TMCountry*)country index:(int)index;
@end

