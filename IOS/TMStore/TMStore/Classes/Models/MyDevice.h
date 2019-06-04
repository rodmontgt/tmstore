//
//  MyDevice.h
//  eMobileApp
//
//  Created by Rishabh Jain on 14/10/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface MyDevice : NSObject

+ (MyDevice *)sharedManager;
- (BOOL)isLandscape;
- (BOOL)isIphone;
- (BOOL)isPortrait;
- (BOOL)isIpad;
- (BOOL)isRetina;
- (CGSize)screenSizeInPortrait;
- (float)screenWidthInPortrait;
- (float)screenHeightInPortrait;
- (CGSize)screenSize;
+ (int)orientationId;
+ (CGSize)getDeviceSize;
@end
