//
//  Vendor.m
//  TMStore
//
//  Created by Rishabh Jain on 16/08/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import "Vendor.h"
@implementation Vendor
static NSMutableArray* _allVendors = NULL;//ARRAY OF Vendors
- (id)init {
    if (self = [super init]) {
        if (_allVendors == NULL) {
            _allVendors = [[NSMutableArray alloc] init];
        }
        self.vendorId = @"";
        self.vendorName = @"";
        self.vendorIconUrl = @"";
        self.vendorLocations = [[NSMutableArray alloc] init];
        [_allVendors addObject:self];
    }
    return self;
}
+ (NSMutableArray*)getAllVendors {
    if (_allVendors == NULL) {
        _allVendors = [[NSMutableArray alloc] init];
    }
    return _allVendors;
}
+ (Vendor*)getVendorById:(NSString*)vendorId{
    for (Vendor* v in _allVendors) {
        if ([v.vendorId isEqualToString:vendorId]) {
            return v;
        }
    }
    return nil;
}
+ (Vendor*)getVendorByName:(NSString*)vendorName{
    for (Vendor* v in _allVendors) {
        if ([v.vendorName isEqualToString:vendorName]) {
            return v;
        }
    }
    return nil;
}
+ (NSMutableArray*)getVendorsByLocation:(NSString*)vendorLocation{
    NSMutableArray* vendorArray = [[NSMutableArray alloc] init];
    for (Vendor* v in _allVendors) {
        for (NSString* loc in v.vendorLocations) {
            if ([loc isEqualToString:vendorLocation]) {
                [vendorArray addObject:v];
            }
        }
    }
    return vendorArray;
}
+ (NSMutableArray*)getVendorLocations{
    NSMutableArray* vendorLocations = [[NSMutableArray alloc] init];
    for (Vendor* v in _allVendors) {
        for (NSString* loc in v.vendorLocations) {
            if (![vendorLocations containsObject:loc]) {
                [vendorLocations addObject:loc];
            }
        }
    }
    return vendorLocations;
}
@end

