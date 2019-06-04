//
//  PincodeSetting.h
//  TMStore
//
//  Created by Vikas Patidar on 09/11/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

enum ZIP_SETTING_VIEW_STATE {
    ZIP_SETTING_VIEW_STATE_INITIATE,
    ZIP_SETTING_VIEW_STATE_FOUND,
    ZIP_SETTING_VIEW_STATE_NOT_FOUND
};

@interface ZipSetting : NSObject

@property NSString* pincode;

@property NSString* message;

@end

@interface PincodeSetting : NSObject

@property BOOL fetched;

@property BOOL enableOnProductPage;

@property NSString* zipTitle;

@property NSString* zipButtonText;

@property NSString* zipNotFoundMessage;

@property NSMutableArray* zipSettings;

+ (id) getInstance;

+ (void) destroyInstance;

- (BOOL) isFetched;

- (void) clearZipSettings;

- (void) addZipSetting:(ZipSetting*) zipSetting;

- (ZipSetting*) getZipSetting:(NSString*) pincode;

@end

