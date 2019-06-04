//
//  TM_PickupLocation.m
//  TMStore
//
//  Created by Rishabh Jain on 08/03/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import "TM_PickupLocation.h"
#import "TMLanguage.h"
static NSMutableArray* allPickupLocations = NULL;
@implementation TM_PickupLocation
- (id)init {
    if (self = [super init]) {
        if (allPickupLocations == NULL) {
            allPickupLocations = [[NSMutableArray alloc] init];
        }
        self.country = @"";
        self.cost = @"";
        self.pickupId = @"";
        self.note = @"";
        self.company = @"";
        self.address_1 = @"";
        self.address_2 = @"";
        self.city = @"";
        self.state = @"";
        self.postcode = @"";
        self.phone = @"";
        [allPickupLocations addObject:self];
    }
    return self;
}
+ (void)clearAllPickupLocations {
    if (allPickupLocations) {
        [allPickupLocations removeAllObjects];
    }
}
+ (NSMutableArray*)getAllPickupLocations {
    if (allPickupLocations == nil) {
        allPickupLocations = [[NSMutableArray alloc] init];
    }
    return allPickupLocations;
}
- (NSAttributedString*)getLocationStringAttributed {
    NSString* picLocStr = @"";
    NSString* seperator = @",";
    BOOL isHeaderRequired = false;
    TM_PickupLocation* picLoc = self;
    if (![picLoc.address_1 isEqualToString:@""]) {
        if (isHeaderRequired) {
            picLocStr = [NSString stringWithFormat:@"%@%@ : %@%@", picLocStr, Localize(@"address1"), picLoc.address_1, seperator];
        } else {
            picLocStr = [NSString stringWithFormat:@"%@%@%@", picLocStr, picLoc.address_1, seperator];
        }
    }
    if (![picLoc.address_2 isEqualToString:@""]) {
        if (isHeaderRequired) {
            picLocStr = [NSString stringWithFormat:@"%@%@ : %@%@", picLocStr, Localize(@"address2"), picLoc.address_2, seperator];
        } else {
            picLocStr = [NSString stringWithFormat:@"%@ %@%@", picLocStr, picLoc.address_2, seperator];
        }
    }
    if (![picLoc.company isEqualToString:@""]) {
        if (isHeaderRequired) {
            picLocStr = [NSString stringWithFormat:@"%@%@ : %@%@", picLocStr, Localize(@"company"), picLoc.company, seperator];
        } else {
            picLocStr = [NSString stringWithFormat:@"%@ %@%@", picLocStr, picLoc.company, seperator];
        }
    }
    if (![picLoc.city isEqualToString:@""]) {
        if (isHeaderRequired) {
            picLocStr = [NSString stringWithFormat:@"%@%@ : %@%@", picLocStr, Localize(@"city"), picLoc.city, seperator];
        } else {
            picLocStr = [NSString stringWithFormat:@"%@ %@%@", picLocStr, picLoc.city, seperator];
        }
    }
    if (![picLoc.state isEqualToString:@""]) {
        if (isHeaderRequired) {
            picLocStr = [NSString stringWithFormat:@"%@%@ : %@%@", picLocStr, Localize(@"state"), picLoc.state, seperator];
        } else {
            picLocStr = [NSString stringWithFormat:@"%@ %@%@", picLocStr, picLoc.state, seperator];
        }
    }
    if (![picLoc.country isEqualToString:@""]) {
        if (isHeaderRequired) {
            picLocStr = [NSString stringWithFormat:@"%@%@ : %@%@", picLocStr, Localize(@"country"), picLoc.country, seperator];
        } else {
            picLocStr = [NSString stringWithFormat:@"%@ %@%@", picLocStr, picLoc.country, seperator];
        }
    }
    if (![picLoc.postcode isEqualToString:@""]) {
        if (isHeaderRequired) {
            picLocStr = [NSString stringWithFormat:@"%@%@ : %@%@", picLocStr, Localize(@"postcode"), picLoc.postcode, seperator];
        } else {
            picLocStr = [NSString stringWithFormat:@"%@ %@%@", picLocStr, picLoc.postcode, seperator];
        }
    }
    if (![picLoc.note isEqualToString:@""]) {
        if (isHeaderRequired) {
            picLocStr = [NSString stringWithFormat:@"%@%@ : %@%@", picLocStr, Localize(@"note"), picLoc.note, seperator];
        } else {
            picLocStr = [NSString stringWithFormat:@"%@ %@%@", picLocStr, picLoc.note, seperator];
        }
    }
    if (![picLocStr isEqualToString:@""] && [picLocStr containsString:@","]) {
        NSRange lastComma = [picLocStr rangeOfString:@"," options:NSBackwardsSearch];
        if(lastComma.location != NSNotFound) {
            picLocStr = [picLocStr stringByReplacingCharactersInRange:lastComma
                                                           withString:@""];
        }
    }
    NSAttributedString* locString = [[NSAttributedString alloc] initWithString:picLocStr];
    return locString;
}
@end
