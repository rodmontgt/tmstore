//
//  StoreConfig.m
//  TMStore
//
//  Created by Rishabh Jain on 27/12/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StoreConfig.h"
#import "Utility.h"
static NSMutableArray* listStoreConfig = nil;
static NSMutableArray* listStoreConfigMark = nil;
static NSMutableArray* listStoreConfigDefault = nil;
static NSMutableArray* listStoreConfigNearBy = nil;
static NSMutableArray *mapMenuOptions = nil;

@implementation StoreConfig
+ (NSMutableArray*)getAllStoreConfigsForMark {
    if (listStoreConfigMark == nil) {
        listStoreConfigMark = [[NSMutableArray alloc] init];
    }
    return listStoreConfigMark;
}
+ (NSMutableArray*)getAllStoreConfigs {
    if (listStoreConfig == nil) {
        listStoreConfig = [[NSMutableArray alloc] init];
    }
    return listStoreConfig;
}
+ (NSMutableArray*)getAllDefaultStoreConfigs {
    if (listStoreConfigDefault == nil) {
        listStoreConfigDefault = [[NSMutableArray alloc] init];
        for (StoreConfig* sc in [StoreConfig getAllStoreConfigs]) {
            if(sc.is_default){
                [listStoreConfigDefault addObject:sc];
            }
        }
    }
    return listStoreConfigDefault;
}
+ (NSMutableArray*)getAllMapMenuOptions{
    if (mapMenuOptions == nil) {
        mapMenuOptions = [[NSMutableArray alloc] init];
    }
    return mapMenuOptions;
}

+ (NSMutableArray*)getAllStoreConfigNearBy{
    if (listStoreConfigNearBy == nil) {
        listStoreConfigNearBy = [[NSMutableArray alloc] init];
    }
    return listStoreConfigNearBy;
}


- (id)init {
    self = [super init];
    if (self) {
        _enabled = true;
        _is_default = true;
        _title = @"";
        _desc = @"";
        _icon_url = @"";
        _store_url = @"";
        _latitude = 0.0f;
        _longitude = 0.0f;
        _platform = @"";
        _url = @"";//added by me
    }
    return self;
}
+ (StoreConfig*)isStoreConfigExists:(NSString*)str {
    for (StoreConfig* storeConfig in [StoreConfig getAllStoreConfigs]) {
        NSString* str1 = @"";
        if ([Utility isMultiStoreAppTMStore]) {
            str1 = storeConfig.platform;
        } else {
            str1 = storeConfig.multi_store_platform;
        }
        if ([str isEqualToString:str1]) {
            return storeConfig;
        }
    }
    return nil;
}
@end
