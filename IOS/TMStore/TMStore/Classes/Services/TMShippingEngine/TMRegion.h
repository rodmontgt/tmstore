//
//  TMRegion.h
//  TMShippingSDK
//
//  Created by Rishabh Jain on 28/09/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TMRegion : NSObject
@property BOOL regionIsLoaded;
@property BOOL regionIsNode;
@property NSString* regionType;
@property NSString* regionId;
@property NSString* regionTitle;
@property NSMutableArray* regionChildren;
@property TMRegion* parentRegion;
- (id)initWithoutAppendingInRegionList;
- (id)init;
- (id)init:(NSString*)regionType regionId:(NSString*)regionId regionTitle:(NSString*)regionTitle regionParent:(TMRegion*)regionParent;
+ (TMRegion*)getRegion:(NSString*)regionType regionId:(NSString*)regionId regionTitle:(NSString*)regionTitle regionParent:(TMRegion*)regionParent;
+ (TMRegion*)getRegionFromAll:(NSString*)regionType regionTitle:(NSString*)regionTitle;
+ (NSMutableArray*)getRegions:(TMRegion*)regionParent;
+ (TMRegion*)findRegionFromId:(NSString*)regionId regionType:(NSString*)regionType regionParent:(TMRegion*)regionParent;
@end
