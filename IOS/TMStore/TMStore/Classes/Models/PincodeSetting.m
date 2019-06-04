//
//  PincodeSetting.m
//  TMStore
//
//  Created by Vikas Patidar on 09/11/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PincodeSetting.h"

@implementation ZipSetting

@end

@implementation PincodeSetting

static PincodeSetting *pincodeSetting = nil;

+ (id) getInstance {
    @synchronized(self) {
        if (pincodeSetting == nil){
            pincodeSetting = [[self alloc] init];
            pincodeSetting.fetched = NO;
        }
    }
    return pincodeSetting;
}

+ (void) destroyInstance {
    @synchronized(self) {
        if(pincodeSetting != nil) {
            pincodeSetting = nil;
        }
    }
}

- (BOOL) isFetched {
    return _fetched;
}

- (void) clearZipSettings {
    if(_zipSettings != nil) {
        [_zipSettings removeAllObjects];
        _zipSettings = nil;
    }
}

- (void) addZipSetting:(ZipSetting*) zipSetting {
    if(_zipSettings == nil) {
        _zipSettings = [[NSMutableArray alloc] init];
    }
    [_zipSettings addObject:zipSetting];
}

- (ZipSetting*) getZipSetting:(NSString*) pincode {
    if(_zipSettings != nil && pincode != nil && [pincode length]> 0) {
        for(ZipSetting* zipSetting in _zipSettings) {
            if([zipSetting.pincode caseInsensitiveCompare:pincode] == NSOrderedSame) {
                return zipSetting;
            }
        }
    }
    return nil;
}
@end
