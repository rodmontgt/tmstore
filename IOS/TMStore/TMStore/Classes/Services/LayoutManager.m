//
//  LayoutManager.m
//  eMobileApp
//
//  Created by Rishabh Jain on 21/10/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import "LayoutManager.h"
#import "Variables.h"
#import "Utility.h"
#import "DataManager.h"
@implementation LeftViewProperties
+ (id)sharedManager {
    static LeftViewProperties *sharedManager = nil;
    @synchronized(self) {
        if (sharedManager == nil)
            sharedManager = [[self alloc] init];
    }
    return sharedManager;
}
- (id)init {
    if (self = [super init]) {
        isEnable = YES;
        ipad_L_PWRTW = 50.0f;
        iphone_L_PWRTW = 50.0f;
        ipad_P_PWRTW = 50.0f;
        iphone_P_PWRTW = 50.0f;
        if ([[MyDevice sharedManager] isIpad]) {
            rowHeight_PWRTH_MAX = 4.88f;
        }else{
            rowHeight_PWRTH_MAX = 4.88f;
        }
    }
    return self;
}
@end

@implementation RightViewProperties
+ (id)sharedManager {
    static RightViewProperties *sharedManager = nil;
    @synchronized(self) {
        if (sharedManager == nil)
            sharedManager = [[self alloc] init];
    }
    return sharedManager;
}
- (id)init {
    if (self = [super init]) {
        isEnable = YES;
        ipad_L_PWRTW = 50.0f;
        iphone_L_PWRTW = 50.0f;
        ipad_P_PWRTW = 50.0f;
        iphone_P_PWRTW = 50.0f;
        if ([[MyDevice sharedManager] isIpad]) {
            rowHeight_PWRTH_MAX = 4.88f;
        }else{
            rowHeight_PWRTH_MAX = 4.88f;
        }
        
    }
    return self;
}
@end

@implementation PlaceHolderColor
+ (id)sharedManager {
    static PlaceHolderColor *sharedManager = nil;
    @synchronized(self) {
        if (sharedManager == nil)
            sharedManager = [[self alloc] init];
    }
    return sharedManager;
}
- (id)init {
    if (self = [super init]) {
        red_min = 80;
        red_max = 220;
        green_min = 80;
        green_max = 220;
        blue_min = 80;
        blue_max = 220;
    }
    return self;
}
@end
@implementation LayoutData
- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}
@end


@implementation LayoutManager

+ (id)sharedManager {
    static LayoutManager *sharedManager = nil;
    @synchronized(self) {
        if (sharedManager == nil)
            sharedManager = [[self alloc] init];
    }
    return sharedManager;
}
- (id)init {
    if (self = [super init]) {
        self.propBanner = [[LayoutData alloc] init];
        self.propProductBanner = [[LayoutData alloc] init];
        self.propCategoryView = [[LayoutData alloc] init];
        self.propProductView = [[LayoutData alloc] init];
        self.propHorizontalView = [[LayoutData alloc] init];
        self.placeHolderColorRange = [PlaceHolderColor sharedManager];
        self.imagePath_PlaceHolder = @"placeholderdemo.png";
        self.imagePath_AppIcon = @"Icon.png";
        self.imagePath_SplashBg = @"splashBg.png";
        self.imagePath_SplashFg = @"splashFg.png";
        self.version = @"";
        self.globalMarginPWRTH = 0;
        self.usePlaceHolderImage = NO;
        
        self.leftViewProp = [LeftViewProperties sharedManager];
        self.rightViewProp = [RightViewProperties sharedManager];
        
        [self readLayoutPlist];
    }
    return self;
}


- (void)LoadLayoutData:(LayoutData*)object dict:(NSDictionary*)dict layoutId:(int) layoutId {
    if (IS_NOT_NULL(dict, @"isFlexibleHeight")) {
        object->isFlexibleHeight = GET_VALUE_BOOL(dict, @"isFlexibleHeight");
    }
    if (IS_NOT_NULL(dict, @"isFlexibleWidth")) {
        object->isFlexibleWidth = GET_VALUE_BOOL(dict, @"isFlexibleWidth");
    }
    
    if (IS_NOT_NULL(dict, @"backgroundColor")) {
        NSScanner *scanner = [NSScanner scannerWithString:GET_VALUE_STRING(dict, @"backgroundColor")];
        unsigned hex;
        BOOL success = [scanner scanHexInt:&hex];
        if (success) {
            object->backgroundColor = [Utility colorWithHex:hex];
        }else{
            object->backgroundColor = [Utility colorWithHex:0xFFFFFFFF];
        }
    }
    
    if ([[MyDevice sharedManager] isIphone]) {
        if (IS_NOT_NULL(dict, @"iPhone")) {
            NSObject* obj = GET_VALUE_OBJECT(dict, @"iPhone");
            NSDictionary* iPhoneDict;
            if ([obj isKindOfClass:[NSDictionary class]]) {
                iPhoneDict = (NSDictionary*)obj;
            } else {
                NSArray* iPhoneArray = (NSArray*)obj;
                iPhoneDict = [iPhoneArray objectAtIndex:layoutId];
                if (iPhoneDict == nil) {
                    iPhoneDict = [iPhoneArray objectAtIndex:0];
                }
            }
            
            
            NSDictionary* tempDict = nil;
            for (int i = 0; i < 1; i++) {
                if (i == 0) {
                    if (IS_NOT_NULL(iPhoneDict, @"portrait")) {
                        tempDict = GET_VALUE_OBJECT(iPhoneDict, @"portrait");
                    }
                } else {
                    if (IS_NOT_NULL(iPhoneDict, @"landscape")) {
                        tempDict = GET_VALUE_OBJECT(iPhoneDict, @"landscape");
                    }
                }
                if (tempDict == nil) {
                    continue;
                }
                
                if (IS_NOT_NULL(tempDict, @"cardWidthPWRTW")) {
                    object->cardWidthPWRTW[i] = GET_VALUE_FLOAT(tempDict, @"cardWidthPWRTW");
                }
                if (IS_NOT_NULL(tempDict, @"cardHeightPWRTW")) {
                    object->cardHeightPWRTW[i] = GET_VALUE_FLOAT(tempDict, @"cardHeightPWRTW");
                }
                if (IS_NOT_NULL(tempDict, @"cardVerticalSpacingPWRTW")) {
                    object->cardVerticalSpacingPWRTW[i] = GET_VALUE_FLOAT(tempDict, @"cardVerticalSpacingPWRTW");
                }
                if (IS_NOT_NULL(tempDict, @"cardHorizontalSpacingPWRTW")) {
                    object->cardHorizontalSpacingPWRTW[i] = GET_VALUE_FLOAT(tempDict, @"cardHorizontalSpacingPWRTW");
                }
                if (IS_NOT_NULL(tempDict, @"widthPWRTH")) {
                    object->widthPWRTH[i] = GET_VALUE_FLOAT(tempDict, @"widthPWRTH");
                }
                if (IS_NOT_NULL(tempDict, @"heightPWRTH")) {
                    object->heightPWRTH[i] = GET_VALUE_FLOAT(tempDict, @"heightPWRTH");
                }
                if (IS_NOT_NULL(tempDict, @"rightMarginPWRTH")) {
                    object->rightMarginPWRTH[i] = GET_VALUE_FLOAT(tempDict, @"rightMarginPWRTH");
                }
                if (IS_NOT_NULL(tempDict, @"leftMarginPWRTH")) {
                    object->leftMarginPWRTH[i] = GET_VALUE_FLOAT(tempDict, @"leftMarginPWRTH");
                }
                if (IS_NOT_NULL(tempDict, @"bottomMarginPWRTH")) {
                    object->bottomMarginPWRTH[i] = GET_VALUE_FLOAT(tempDict, @"bottomMarginPWRTH");
                }
                if (IS_NOT_NULL(tempDict, @"topMarginPWRTH")) {
                    object->topMarginPWRTH[i] = GET_VALUE_FLOAT(tempDict, @"topMarginPWRTH");
                }
                if (IS_NOT_NULL(tempDict, @"cardInRowCount")) {
                    object->cardInRowCount[i] = GET_VALUE_INT(tempDict, @"cardInRowCount");
                }
                
                if (IS_NOT_NULL(tempDict, @"insetMarginTopPWRTW")) {
                    object->insetMarginTopPWRTW[i] = GET_VALUE_FLOAT(tempDict, @"insetMarginTopPWRTW");
                }
                if (IS_NOT_NULL(tempDict, @"insetMarginBottomPWRTW")) {
                    object->insetMarginBottomPWRTW[i] = GET_VALUE_FLOAT(tempDict, @"insetMarginBottomPWRTW");
                }
                if (IS_NOT_NULL(tempDict, @"insetMarginLeftPWRTW")) {
                    object->insetMarginLeftPWRTW[i] = GET_VALUE_FLOAT(tempDict, @"insetMarginLeftPWRTW");
                }
                if (IS_NOT_NULL(tempDict, @"insetMarginRightPWRTW")) {
                    object->insetMarginRightPWRTW[i] = GET_VALUE_FLOAT(tempDict, @"insetMarginRightPWRTW");
                }
            }
        }
    }
    if ([[MyDevice sharedManager] isIpad]) {
        if (IS_NOT_NULL(dict, @"iPad")) {
            NSObject* obj = GET_VALUE_OBJECT(dict, @"iPad");
            NSDictionary* iPadDict;
            if ([obj isKindOfClass:[NSDictionary class]]) {
                iPadDict = (NSDictionary*)obj;
            } else {
                NSArray* iPadArray = (NSArray*)obj;
                iPadDict = [iPadArray objectAtIndex:layoutId];
                if (iPadDict == nil) {
                    iPadDict = [iPadArray objectAtIndex:0];
                }
            }
            
            NSDictionary* tempDict = nil;
            for (int i = 0; i < 2; i++) {
                if (i == 0) {
                    if (IS_NOT_NULL(iPadDict, @"portrait")) {
                        tempDict = GET_VALUE_OBJECT(iPadDict, @"portrait");
                    }
                } else {
                    if (IS_NOT_NULL(iPadDict, @"landscape")) {
                        tempDict = GET_VALUE_OBJECT(iPadDict, @"landscape");
                    }
                }
                if (tempDict == nil) {
                    continue;
                }
                
                if (IS_NOT_NULL(tempDict, @"cardWidthPWRTW")) {
                    object->cardWidthPWRTW[i] = GET_VALUE_FLOAT(tempDict, @"cardWidthPWRTW");
                }
                if (IS_NOT_NULL(tempDict, @"cardHeightPWRTW")) {
                    object->cardHeightPWRTW[i] = GET_VALUE_FLOAT(tempDict, @"cardHeightPWRTW");
                }
                if (IS_NOT_NULL(tempDict, @"cardVerticalSpacingPWRTW")) {
                    object->cardVerticalSpacingPWRTW[i] = GET_VALUE_FLOAT(tempDict, @"cardVerticalSpacingPWRTW");
                }
                if (IS_NOT_NULL(tempDict, @"cardHorizontalSpacingPWRTW")) {
                    object->cardHorizontalSpacingPWRTW[i] = GET_VALUE_FLOAT(tempDict, @"cardHorizontalSpacingPWRTW");
                }
                if (IS_NOT_NULL(tempDict, @"widthPWRTH")) {
                    object->widthPWRTH[i] = GET_VALUE_FLOAT(tempDict, @"widthPWRTH");
                }
                if (IS_NOT_NULL(tempDict, @"heightPWRTH")) {
                    object->heightPWRTH[i] = GET_VALUE_FLOAT(tempDict, @"heightPWRTH");
                }
                if (IS_NOT_NULL(tempDict, @"rightMarginPWRTH")) {
                    object->rightMarginPWRTH[i] = GET_VALUE_FLOAT(tempDict, @"rightMarginPWRTH");
                }
                if (IS_NOT_NULL(tempDict, @"leftMarginPWRTH")) {
                    object->leftMarginPWRTH[i] = GET_VALUE_FLOAT(tempDict, @"leftMarginPWRTH");
                }
                if (IS_NOT_NULL(tempDict, @"bottomMarginPWRTH")) {
                    object->bottomMarginPWRTH[i] = GET_VALUE_FLOAT(tempDict, @"bottomMarginPWRTH");
                }
                if (IS_NOT_NULL(tempDict, @"topMarginPWRTH")) {
                    object->topMarginPWRTH[i] = GET_VALUE_FLOAT(tempDict, @"topMarginPWRTH");
                }
                if (IS_NOT_NULL(tempDict, @"cardInRowCount")) {
                    object->cardInRowCount[i] = GET_VALUE_INT(tempDict, @"cardInRowCount");
                }
                if (IS_NOT_NULL(tempDict, @"insetMarginTopPWRTW")) {
                    object->insetMarginTopPWRTW[i] = GET_VALUE_FLOAT(tempDict, @"insetMarginTopPWRTW");
                }
                if (IS_NOT_NULL(tempDict, @"insetMarginBottomPWRTW")) {
                    object->insetMarginBottomPWRTW[i] = GET_VALUE_FLOAT(tempDict, @"insetMarginBottomPWRTW");
                }
                if (IS_NOT_NULL(tempDict, @"insetMarginLeftPWRTW")) {
                    object->insetMarginLeftPWRTW[i] = GET_VALUE_FLOAT(tempDict, @"insetMarginLeftPWRTW");
                }
                if (IS_NOT_NULL(tempDict, @"insetMarginRightPWRTW")) {
                    object->insetMarginRightPWRTW[i] = GET_VALUE_FLOAT(tempDict, @"insetMarginRightPWRTW");
                }
                
            }
            
        }
    }
}
- (void)readLayoutPlist {
    //    NSString *plistFilePath  = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"LayoutProperties.plist"];
    //    NSDictionary *list = [NSDictionary dictionaryWithContentsOfFile:plistFilePath];
    
    NSDictionary *dictRoot = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"LayoutProperties" ofType:@"plist"]];
    //    RLOG(@"%@",dictRoot);
    
    if (IS_NOT_NULL(dictRoot, @"version")) {
        self.version = GET_VALUE_STRING(dictRoot, @"version");
    }
    
    if (IS_NOT_NULL(dictRoot, @"globalMarginPWRTH")) {
        self.globalMarginPWRTH = GET_VALUE_FLOAT(dictRoot, @"globalMarginPWRTH");
    }
    
    if (IS_NOT_NULL(dictRoot, @"bannerView")) {
        NSDictionary* bannerView = GET_VALUE_OBJECT(dictRoot, @"bannerView");
        [self LoadLayoutData:self.propBanner dict:bannerView layoutId:[[DataManager sharedManager] layoutIdBannerView]];
    }
    if (IS_NOT_NULL(dictRoot, @"productBannerView")) {
        NSDictionary* productBannerView = GET_VALUE_OBJECT(dictRoot, @"productBannerView");
        [self LoadLayoutData:self.propProductBanner dict:productBannerView layoutId:[[DataManager sharedManager] layoutIdProductBannerView]];
    }
    
    if (IS_NOT_NULL(dictRoot, @"categoryView")) {
        NSDictionary* categoryView = GET_VALUE_OBJECT(dictRoot, @"categoryView");
        [self LoadLayoutData:self.propCategoryView dict:categoryView layoutId:[[DataManager sharedManager] layoutIdCategoryView]];
    }
    
    if (IS_NOT_NULL(dictRoot, @"productView")) {
        NSDictionary* productView = GET_VALUE_OBJECT(dictRoot, @"productView");
        [self LoadLayoutData:self.propProductView dict:productView layoutId:[[DataManager sharedManager] layoutIdProductView]];
    }
    
    if (IS_NOT_NULL(dictRoot, @"horizontalView")) {
        NSDictionary* horizontalView = GET_VALUE_OBJECT(dictRoot, @"horizontalView");
        [self LoadLayoutData:self.propHorizontalView dict:horizontalView layoutId:[[DataManager sharedManager] layoutIdHorizontalView]];
    }
    
    {
        NSDictionary *tmStoreRoot = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"tmstore" ofType:@"plist"]];
        
        
        if (IS_NOT_NULL(tmStoreRoot, @"imagePath_PlaceHolder")) {
            self.imagePath_PlaceHolder = GET_VALUE_STRING(tmStoreRoot, @"imagePath_PlaceHolder");
        }
        if (IS_NOT_NULL(tmStoreRoot, @"imagePath_AppIcon")) {
            self.imagePath_AppIcon = GET_VALUE_STRING(tmStoreRoot, @"imagePath_AppIcon");
        }
        if (IS_NOT_NULL(tmStoreRoot, @"imagePath_SplashBg")) {
            self.imagePath_SplashBg = GET_VALUE_STRING(tmStoreRoot, @"imagePath_SplashBg");
        }
        if (IS_NOT_NULL(tmStoreRoot, @"imagePath_SplashFg")) {
            self.imagePath_SplashFg = GET_VALUE_STRING(tmStoreRoot, @"imagePath_SplashFg");
        }
    }
    
    
    if (IS_NOT_NULL(dictRoot, @"placeHolderColorRange")) {
        NSDictionary* colorRange = GET_VALUE_OBJECT(dictRoot, @"placeHolderColorRange");
        
        self.placeHolderColorRange->red_min = GET_VALUE_INT(colorRange, @"r_min");
        self.placeHolderColorRange->red_max = GET_VALUE_INT(colorRange, @"r_max");
        
        self.placeHolderColorRange->green_min = GET_VALUE_INT(colorRange, @"g_min");
        self.placeHolderColorRange->green_max = GET_VALUE_INT(colorRange, @"g_max");
        
        self.placeHolderColorRange->blue_min = GET_VALUE_INT(colorRange, @"b_min");
        self.placeHolderColorRange->blue_max = GET_VALUE_INT(colorRange, @"b_max");
    }
    if (IS_NOT_NULL(dictRoot, @"usePlaceHolderImage")) {
        self.usePlaceHolderImage = GET_VALUE_BOOL(dictRoot, @"usePlaceHolderImage");
    }
    
    if (IS_NOT_NULL(dictRoot, @"leftView")) {
        NSDictionary* leftView = GET_VALUE_OBJECT(dictRoot, @"leftView");
        self.leftViewProp->isEnable = GET_VALUE_BOOL(leftView, @"isEnable");
        self.leftViewProp->ipad_L_PWRTW = GET_VALUE_FLOAT(leftView, @"ipad_L_PWRTW");
        self.leftViewProp->iphone_L_PWRTW = GET_VALUE_FLOAT(leftView, @"iphone_L_PWRTW");
        self.leftViewProp->ipad_P_PWRTW = GET_VALUE_FLOAT(leftView, @"ipad_P_PWRTW");
        self.leftViewProp->iphone_P_PWRTW = GET_VALUE_FLOAT(leftView, @"iphone_P_PWRTW");
        if ([[MyDevice sharedManager] isIpad]) {
            self.leftViewProp->rowHeight_PWRTH_MAX = GET_VALUE_FLOAT(leftView, @"ipad_rowHeight_PWRTH_MAX");
        }else{
            self.leftViewProp->rowHeight_PWRTH_MAX = GET_VALUE_FLOAT(leftView, @"iphone_rowHeight_PWRTH_MAX");
        }
    }
    
    if (IS_NOT_NULL(dictRoot, @"rightView")) {
        NSDictionary* rightView = GET_VALUE_OBJECT(dictRoot, @"rightView");
        self.rightViewProp->isEnable = GET_VALUE_BOOL(rightView, @"isEnable");
        self.rightViewProp->ipad_L_PWRTW = GET_VALUE_FLOAT(rightView, @"ipad_L_PWRTW");
        self.rightViewProp->iphone_L_PWRTW = GET_VALUE_FLOAT(rightView, @"iphone_L_PWRTW");
        self.rightViewProp->ipad_P_PWRTW = GET_VALUE_FLOAT(rightView, @"ipad_P_PWRTW");
        self.rightViewProp->iphone_P_PWRTW = GET_VALUE_FLOAT(rightView, @"iphone_P_PWRTW");
        if ([[MyDevice sharedManager] isIpad]) {
            self.rightViewProp->rowHeight_PWRTH_MAX = GET_VALUE_FLOAT(rightView, @"ipad_rowHeight_PWRTH_MAX");
        }else{
            self.rightViewProp->rowHeight_PWRTH_MAX = GET_VALUE_FLOAT(rightView, @"iphone_rowHeight_PWRTH_MAX");
        }
        
        
    }
    
}

@end





