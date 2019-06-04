//
//  ShippingEngine.m
//  TMShippingSDK
//
//  Created by Rishabh Jain on 28/09/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import "ShippingEngine.h"
@implementation ShippingEngine
static BOOL listCities = false;
- (BOOL)hasSubDistrictSelection {
    return subDistrictSelection;
}
- (BOOL)hasDistrictSelection {
    return districtSelection;
}
- (BOOL)hasCitySelection {
    return citySelection;
}
- (BOOL)hasCountrySelection {
    return countrySelection;
}
- (BOOL)hasStateSelection {
    return stateSelection;
}
+ (BOOL)listCities {
    return listCities;
}
+ (BOOL)areCitiesListed {
    return listCities;
}
- (void)setListCities:(BOOL)value {
    listCities = value;
}
@end

