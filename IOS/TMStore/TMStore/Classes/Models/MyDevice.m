//
//  MyDevice.m
//  eMobileApp
//
//  Created by Rishabh Jain on 14/10/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import "MyDevice.h"
@interface MyDevice()
{
    BOOL _isIphone;
    BOOL _isLandscape;
    BOOL _isIpad;
    BOOL _isPortrait;
    CGSize _deviceSize;
    CGSize _screenSizeInPortrait;
}
@end
@implementation MyDevice

+ (MyDevice *)sharedManager {
    static MyDevice *sharedManager = nil;
    @synchronized(self) {
        if (sharedManager == nil)
            sharedManager = [[self alloc] init];
    }
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        sharedManager->_isIphone = true;
        sharedManager->_isIpad = false;
    }else{
        sharedManager->_isIphone = false;
        sharedManager->_isIpad = true;
    }
//    sharedManager->_isIphone = true;
//    sharedManager->_isIpad = false;
    sharedManager->_deviceSize = [MyDevice getDeviceSize];//[[UIScreen mainScreen] bounds].size;
    
    [sharedManager setScreenSize];
    return sharedManager;
}
+ (CGSize)getDeviceSize {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
//    CGFloat screenScale = [[UIScreen mainScreen] scale];
//    screenSize.width *= screenScale;
//    screenSize.height *= screenScale;
    if ((NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1) && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        return CGSizeMake(screenSize.height, screenSize.width);
    }
    return screenSize;
}
- (CGSize)deviceSize {
    _deviceSize = [MyDevice getDeviceSize];
    return _deviceSize;
//    _deviceSize = [[UIScreen mainScreen] bounds].size;
//    return _deviceSize;
}

- (CGSize)screenSize{
    return _deviceSize;//[self deviceSize];;
}

- (BOOL)isLandscape {
    CGSize size = [self deviceSize];
    if (size.width > size.height) {
        return true;
    } else {
        return false;
    }
}
- (BOOL)isIphone {
    return _isIphone;
}
- (BOOL)isPortrait {
    CGSize size = [self deviceSize];
    if (size.width < size.height) {
        return true;
    } else {
        return false;
    }
}
- (BOOL)isIpad {
    return _isIpad;
}

- (CGSize)setScreenSize {
//    CGRect screenRect = [MyDevice getDeviceSize];// [[UIScreen mainScreen] bounds];
    CGSize screenSize = [MyDevice getDeviceSize];;
    float sHeight = screenSize.height;
    float sWidth = screenSize.width;
    if (sHeight > sWidth) {
        screenSize.height = sHeight;
        screenSize.width = sWidth;
    } else {
        screenSize.height = sWidth;
        screenSize.width = sHeight;
    }
    _screenSizeInPortrait = screenSize;
    return _screenSizeInPortrait;
}
- (CGSize)screenSizeInPortrait {
    return _screenSizeInPortrait;
}

- (float)screenHeightInPortrait {
    return _screenSizeInPortrait.height;
}
- (float)screenWidthInPortrait {
    return _screenSizeInPortrait.width;
}

+ (int)orientationId {
    if([[MyDevice sharedManager]isLandscape]){
        return 1;
    }
    return 0;
}
- (BOOL)isRetina {
    return false;
}
@end
