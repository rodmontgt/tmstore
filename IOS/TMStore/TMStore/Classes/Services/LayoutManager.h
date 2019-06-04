//
//  LayoutManager.h
//  eMobileApp
//
//  Created by Rishabh Jain on 21/10/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LayoutProperties.h"
@interface LeftViewProperties: NSObject {
@public
    float ipad_L_PWRTW;
    float ipad_P_PWRTW;
    float iphone_L_PWRTW;
    float iphone_P_PWRTW;
    BOOL isEnable;
    float rowHeight_PWRTH_MAX;
    float topRowHeight_PWRTH_MAX;
};
+ (id)sharedManager;
@end

@interface RightViewProperties: NSObject {
@public
    float ipad_L_PWRTW;
    float ipad_P_PWRTW;
    float iphone_L_PWRTW;
    float iphone_P_PWRTW;
    BOOL isEnable;
    float rowHeight_PWRTH_MAX;
    float topRowHeight_PWRTH_MAX;
};
+ (id)sharedManager;
@end


@interface PlaceHolderColor: NSObject {
@public
    int red_min;
    int green_min;
    int blue_min;
    int red_max;
    int green_max;
    int blue_max;
};
+ (id)sharedManager;
@end

@interface LayoutData : NSObject {
@public
 int scrollType;
 BOOL isFlexibleHeight;
 BOOL isFlexibleWidth;
 UIColor *backgroundColor;

 float widthPWRTH[2];
 float heightPWRTH[2];
 float rightMarginPWRTH[2];
 float leftMarginPWRTH[2];
 float bottomMarginPWRTH[2];
 float topMarginPWRTH[2];
 float cardWidthPWRTW[2];
 float cardHeightPWRTW[2];
 float cardVerticalSpacingPWRTW[2];
 float cardHorizontalSpacingPWRTW[2];
 float insetMarginTopPWRTW[2];
 float insetMarginBottomPWRTW[2];
 float insetMarginLeftPWRTW[2];
 float insetMarginRightPWRTW[2];
 int cardInRowCount[2];
}
@end

@interface LayoutManager : NSObject
@property LayoutData *propProductBanner;
@property LayoutData *propBanner;
@property LayoutData *propCategoryView;
@property LayoutData *propProductView;
@property LayoutData *propHorizontalView;
@property NSString *version;
@property float globalMarginPWRTH;

@property PlaceHolderColor *placeHolderColorRange;

@property NSString *imagePath_PlaceHolder;
@property NSString *imagePath_AppIcon;
@property NSString *imagePath_SplashBg;
@property NSString *imagePath_SplashFg;

@property BOOL usePlaceHolderImage;

@property LeftViewProperties *leftViewProp;
@property RightViewProperties *rightViewProp;

+ (id)sharedManager;
- (void)readLayoutPlist;
@end



