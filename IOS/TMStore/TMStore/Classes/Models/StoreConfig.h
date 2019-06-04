//
//  StoreConfig.h
//  TMStore
//
//  Created by Rishabh Jain on 27/12/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#ifndef StoreConfig_h
#define StoreConfig_h
@interface StoreConfig : NSObject
@property BOOL enabled;
@property BOOL is_default;
@property NSString* title;
@property NSString* desc;
@property NSString* icon_url;
@property NSString* store_url;
@property float latitude;
@property float longitude;

@property NSString* platform;
@property NSString* multi_store_platform;
@property NSString* storeType;

//added by me
@property NSString* url;
@property NSMutableArray *arrayInfo;

@property int appType;
+ (NSMutableArray*)getAllStoreConfigs;
+ (NSMutableArray*)getAllStoreConfigsForMark;
+ (NSMutableArray*)getAllDefaultStoreConfigs;
+ (NSMutableArray*)getAllMapMenuOptions;
+ (NSMutableArray*)getAllStoreConfigNearBy;
- (id)init;
+ (StoreConfig*)isStoreConfigExists:(NSString*)str;

@end
#endif /* StoreConfig_h */
