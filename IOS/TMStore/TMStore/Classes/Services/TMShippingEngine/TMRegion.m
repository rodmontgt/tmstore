//
//  TMRegion.m
//  TMShippingSDK
//
//  Created by Rishabh Jain on 28/09/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import "TMRegion.h"
static NSMutableArray* regionList = nil;
@implementation TMRegion

- (id)initWithoutAppendingInRegionList {
    self = [super init];
    if (self) {
        _regionChildren = [[NSMutableArray alloc] init];
        _regionId = @"";
        _regionIsLoaded = false;
        _regionIsNode = false;
        _regionTitle = @"";
        _regionType = @"";
    }
    return self;
}
- (id)init {
    self = [super init];
    if (self) {
        if (regionList == nil) {
            regionList = [[NSMutableArray alloc] init];
        }
        [regionList addObject:self];
        
        
        _regionChildren = [[NSMutableArray alloc] init];
        _regionId = @"";
        _regionIsLoaded = false;
        _regionIsNode = false;
        _regionTitle = @"";
        _regionType = @"";
    }
    return self;
}
- (id)init:(NSString*)regionType regionId:(NSString*)regionId regionTitle:(NSString*)regionTitle regionParent:(TMRegion*)regionParent {
    self = [super init];
    if (self) {
        if (regionList == nil) {
            regionList = [[NSMutableArray alloc] init];
        }
        [regionList addObject:self];
        
        
        _regionChildren = [[NSMutableArray alloc] init];
        _regionId = regionId;
        _regionTitle = regionTitle;
        _regionType = regionType;
        _parentRegion = regionParent;
        if (regionParent != nil) {
            _regionIsNode = false;
            [regionParent.regionChildren addObject:self];
        } else {
            _regionIsNode = true;
        }
        _regionIsLoaded = false;
    }
    return self;
}
+ (TMRegion*)getRegion:(NSString*)regionType regionId:(NSString*)regionId regionTitle:(NSString*)regionTitle regionParent:(TMRegion*)regionParent {
    for (TMRegion* region in regionList) {
        if ([regionType isEqualToString:region.regionType] && [regionId isEqualToString:region.regionId] && regionParent == region.parentRegion) {
            return region;
        }
    }
    return [[TMRegion alloc] init:regionType regionId:regionId regionTitle:regionTitle regionParent:regionParent];
}
+ (TMRegion*)getRegionFromAll:(NSString*)regionType regionTitle:(NSString*)regionTitle {
    for (TMRegion* region in regionList) {
        if ([regionType isEqualToString:region.regionType] && [regionTitle isEqualToString:region.regionTitle]) {
            return region;
        }
    }
    return [[TMRegion alloc] init:regionType regionId:regionTitle regionTitle:regionTitle regionParent:nil];
}
+ (NSMutableArray*)getRegions:(TMRegion*)regionParent {
    if (regionParent != nil) {
        return regionParent.regionChildren;
    } else {
        NSMutableArray* regions = [[NSMutableArray alloc] init];
        for (TMRegion* region in regionList) {
            if (region.regionIsNode) {
                [regions addObject:region];
            }
        }
        return regions;
    }
}
+ (TMRegion*)findRegionFromId:(NSString*)regionId regionType:(NSString*)regionType regionParent:(TMRegion*)regionParent {
    for (TMRegion* region in regionList) {
        if (regionParent == nil) {
            if ([region.regionId isEqualToString:regionId] && [region.regionType isEqualToString:regionType]) {
                return region;
            }
        } else {
            if ([region.regionId isEqualToString:regionId] && [region.regionType isEqualToString:regionType] && [region.parentRegion.regionId isEqualToString:regionParent.regionId]) {
                return region;
            }
        }
    }
    return nil;
}

//@Override
//public String toString() {
//    return this.title;
//}
//
//@Override
//public boolean equals(Object object) {
//    if (object instanceof TMRegion) {
//        TMRegion other = (TMRegion) object;
//        return (this.type.equals(other.type) && this.id.equals(other.id));
//    }
//    return super.equals(object);
//}
//
//public String toJson() {
//    return new Gson().toJson(this);
//}
//
//public static TMRegion fromJson(String jsonString) {
//    return new Gson().fromJson(jsonString, TMRegion.class);
//}
@end
