//
//  Vendor.h
//  TMStore
//
//  Created by Rishabh Jain on 16/08/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface Vendor : NSObject
@property NSString* vendorId;
@property NSString* vendorName;
@property NSString* vendorIconUrl;
@property NSMutableArray* vendorLocations;
+ (NSMutableArray*)getAllVendors;

+ (Vendor*)getVendorById:(NSString*)vendorId;
+ (Vendor*)getVendorByName:(NSString*)vendorName;
+ (NSMutableArray*)getVendorsByLocation:(NSString*)vendorLocation;
+ (NSMutableArray*)getVendorLocations;
@end
