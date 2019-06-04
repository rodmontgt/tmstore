//
//  LayoutProperties.m
//  eMobileApp
//
//  Created by Rishabh Jain on 20/10/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import "LayoutProperties.h"
#import "MyDevice.h"
#import "Utility.h"
#import "LayoutManager.h"
#import "DataManager.h"
@interface LayoutProperties() {
    

}
@end

@implementation LayoutProperties

- (id)init {
    self = [super init];
    if (self) {
        self._posX = 0;
        self._posY = 0;
        self._mTop = 0;
        self._mBottom = 0;
        self._mLeft = 0;
        self._mRight = 0;
        self._height = 0;
        self._width = 0;
        self._sfX = 1.0f;
        self._sfY = 1.0f;
        self._isFlexW = false;
        self._isFlexH = false;
        self._cmHorizontal = 0;
        self._cmVertical = 0;
        self._cHeight = 0;
        self._cWidth = 0;
        self._csfX = 1.0f;
        self._csfY = 1.0f;
        self._cInRowCount = 1;
        self._hasChild = false;
        self._scrollType = SCROLL_TYPE_HORIZONTAL;
        self._insetTop = -1;
        self._insetBottom = -1;
        self._insetLeft = -1;
        self._insetRight = -1;
    }
    return self;
}
- (id)initWithBannerValues {
    self = [super init];
    if (self) {
        [self setBannerProperties:self showFullSizeBanner:false];
    }
    return self;
}
- (id)initWithProductBannerValues {
    self = [super init];
    if (self) {
        [self setProductBannerProperties:self];
    }
    return self;
}
- (id)initWithCollectionViewValues:(int)scrollType {
    self = [super init];
    if (self) {
        [self setCollectionViewProperties:self scrollType:scrollType];
    }
    return self;
}
- (void)setBannerProperties:(LayoutProperties *)layoutProp showFullSizeBanner:(BOOL)showFullSizeBanner {
    float maxHeight = [[MyDevice sharedManager] screenHeightInPortrait];
    float maxWidth = [[MyDevice sharedManager] screenWidthInPortrait];
    
    LayoutData* layoutData = [[LayoutManager sharedManager] propBanner];
    layoutProp._posX = 0;
    layoutProp._posY = 0;
    
    int orientationId = [MyDevice orientationId];
    
    layoutProp._mTop = maxHeight * layoutData->topMarginPWRTH[orientationId] / 100.0f;
    layoutProp._mBottom = maxHeight * layoutData->bottomMarginPWRTH[orientationId] / 100.0f;
    layoutProp._mLeft = maxHeight * layoutData->leftMarginPWRTH[orientationId] / 100.0f;
    layoutProp._mRight = maxHeight * layoutData->rightMarginPWRTH[orientationId] / 100.0f;
    layoutProp._height = maxHeight * layoutData->heightPWRTH[orientationId] / 100.0f;
    layoutProp._width = maxHeight * layoutData->widthPWRTH[orientationId] / 100.0f;
    
    if (showFullSizeBanner)
    {
        layoutProp._height = maxHeight * (100.0f - layoutData->topMarginPWRTH[orientationId] * 2.0f) / 100.0f - [[Utility sharedManager] topBarHeight] - [[Utility sharedManager] bottomBarHeight];
            layoutProp._width = maxWidth * (100.0f - layoutData->leftMarginPWRTH[orientationId] * 2.0f ) / 100.0f;
    }
    
    if (layoutProp._height <= 0) {
        layoutProp._height = 10;
    }
    if (layoutProp._width <= 0) {
        layoutProp._width = 10;
    }
    layoutProp._sfX = 1.0f;
    layoutProp._sfY = 1.0f;
    layoutProp._isFlexW = layoutData->isFlexibleWidth;
    layoutProp._isFlexH = layoutData->isFlexibleHeight;
    
    layoutProp._hasChild = false;
    layoutProp._cmHorizontal = 0;
    layoutProp._cmVertical = 0;
    layoutProp._cHeight = 0;
    layoutProp._cWidth = 0;
    layoutProp._csfX = 1.0f;
    layoutProp._csfY = 1.0f;
    layoutProp._cInRowCount = 0;
    layoutProp._scrollType = SCROLL_TYPE_NONE;
    
    layoutProp._bgColor = layoutData->backgroundColor;
    
}
- (void)setProductBannerProperties:(LayoutProperties *)layoutProp {
    float maxHeight = [[MyDevice sharedManager] screenHeightInPortrait];
    LayoutData* layoutData = [[LayoutManager sharedManager] propProductBanner];
    layoutProp._posX = 0;
    layoutProp._posY = 0;
    
    int orientationId = [MyDevice orientationId];
    
    layoutProp._mTop = maxHeight * layoutData->topMarginPWRTH[orientationId] / 100.0f;
    layoutProp._mBottom = maxHeight * layoutData->bottomMarginPWRTH[orientationId] / 100.0f;
    layoutProp._mLeft = maxHeight * layoutData->leftMarginPWRTH[orientationId] / 100.0f;
    layoutProp._mRight = maxHeight * layoutData->rightMarginPWRTH[orientationId] / 100.0f;
    layoutProp._height = maxHeight * layoutData->heightPWRTH[orientationId] / 100.0f;
    layoutProp._width = maxHeight * layoutData->widthPWRTH[orientationId] / 100.0f;
    
    
    if (layoutProp._height <= 0) {
        layoutProp._height = 10;
    }
    if (layoutProp._width <= 0) {
        layoutProp._width = 10;
    }
    layoutProp._sfX = 1.0f;
    layoutProp._sfY = 1.0f;
    layoutProp._isFlexW = layoutData->isFlexibleWidth;
    layoutProp._isFlexH = layoutData->isFlexibleHeight;
    
    layoutProp._hasChild = false;
    layoutProp._cmHorizontal = 0;
    layoutProp._cmVertical = 0;
    layoutProp._cHeight = 0;
    layoutProp._cWidth = 0;
    layoutProp._csfX = 1.0f;
    layoutProp._csfY = 1.0f;
    layoutProp._cInRowCount = 0;
    layoutProp._scrollType = SCROLL_TYPE_NONE;
    
    layoutProp._bgColor = layoutData->backgroundColor;
    
}


- (void)setCollectionViewProperties:(LayoutProperties *)layoutProp scrollType:(int)scrollType {
    float maxHeight = [[MyDevice sharedManager] screenHeightInPortrait];
    LayoutData* layoutData = [[LayoutManager sharedManager] propCategoryView];
    
    layoutProp._posX = 0;
    layoutProp._posY = 0;
    
    int orientationId = [MyDevice orientationId];
    //Divide by 2.0f, As there is headerReferenceSize
    layoutProp._mTop = maxHeight * (layoutData->topMarginPWRTH[orientationId] / 2.0f) / 100.0f;
    layoutProp._mBottom = maxHeight * (layoutData->bottomMarginPWRTH[orientationId] / 2.0f) / 100.0f;
    layoutProp._mLeft = maxHeight * layoutData->leftMarginPWRTH[orientationId] / 100.0f;
    layoutProp._mRight = maxHeight * layoutData->rightMarginPWRTH[orientationId] / 100.0f;
    layoutProp._height = maxHeight * layoutData->heightPWRTH[orientationId] / 100.0f;
    layoutProp._width = maxHeight * layoutData->widthPWRTH[orientationId] / 100.0f;
    
    if (layoutProp._height <= 10)
    {
        layoutProp._height = 10;
    }
    if (layoutProp._width <= 10)
    {
        layoutProp._width = 10;
    }
    
    layoutProp._sfX = 1.0f;
    layoutProp._sfY = 1.0f;
    layoutProp._isFlexW = layoutData->isFlexibleWidth;
    layoutProp._isFlexH = layoutData->isFlexibleHeight;
    
    layoutProp._hasChild = true;
    layoutProp._cmHorizontal = 0;
    layoutProp._cmVertical = 0;
    layoutProp._cHeight = 0;
    layoutProp._cWidth = 0;
    layoutProp._csfX = 1.0f;
    layoutProp._csfY = 1.0f;
    layoutProp._cInRowCount = 0;
    
    layoutProp._scrollType = scrollType;
    
    layoutProp._bgColor = layoutData->backgroundColor;
}

- (CGRect)getFrameRect {
    CGRect rect = CGRectMake(0, 0, 0, 0);
    float screenW = [[MyDevice sharedManager] screenSize].width;
    float screenH = [[MyDevice sharedManager] screenSize].height;
    
    if (self._isFlexW)
        self._width = screenW;
    if (self._isFlexH)
        self._height = screenH;
    
    rect.origin.x = self._posX + self._mLeft;
    rect.origin.y = self._posY + self._mTop;
    rect.size.width = self._width - self._mLeft - self._mRight;
    rect.size.height = self._height + self._mBottom;
    return rect;
}
/*
+ (CGRect)CardPropertiesForProductView {
    LayoutData* layoutData = [[LayoutManager sharedManager] propProductView];
    float cardWidth = 0;
    float cardHeight = 0;
    float horizontalSpace = 0;
    float verticalSpace = 0;
    int cardInRow = 0;
    
    float screenMaxW = [[MyDevice sharedManager] screenWidthInPortrait];
    float screenCurrentW = [[MyDevice sharedManager] screenSize].width;
    
//    bool isIPhone = [[MyDevice sharedManager] isIphone];
//    bool isPortrait = [[MyDevice sharedManager] isPortrait];
    
    int orientationId = [MyDevice orientationId];
    cardInRow = layoutData->cardInRowCount[orientationId];
    cardWidth = screenMaxW * layoutData->cardWidthPWRTW[orientationId] / 100.0f;
    cardHeight = screenMaxW * layoutData->cardHeightPWRTW[orientationId] / 100.0f;
    horizontalSpace = (screenCurrentW - cardWidth * cardInRow)/(cardInRow);
    verticalSpace = screenMaxW * layoutData->cardVerticalSpacingPWRTW[orientationId] / 100.0f;


//    if (isIPhone) {
//        if (isPortrait) {
//            cardInRow = layoutData->cardInRowCount[0];
//        }else{
//            cardInRow = layoutData.iPhoneCardInRowCountL;
//        }
//        cardWidth = screenMaxW * layoutData.iPhoneCardWidthPWRTW / 100.0f;
//        cardHeight = screenMaxW * layoutData.iPhoneCardHeightPWRTW / 100.0f;
//        horizontalSpace = (screenCurrentW - cardWidth * cardInRow)/(cardInRow);
//        verticalSpace = screenMaxW * layoutData.iPhoneCardVerticalSpacingPWRTW / 100.0f;
//    } else {
//        if (isPortrait) {
//            cardInRow = layoutData.iPadCardInRowCountP;
//        }else{
//            cardInRow = layoutData.iPadCardInRowCountL;
//        }
//        cardWidth = screenMaxW * layoutData.iPadCardWidthPWRTW / 100.0f;
//        cardHeight = screenMaxW * layoutData.iPadCardHeightPWRTW / 100.0f;
//        horizontalSpace = (screenCurrentW - cardWidth * cardInRow)/(cardInRow);
//        verticalSpace = screenMaxW * layoutData.iPadCardVerticalSpacingPWRTW / 100.0f;
//    }
    RLOG(@"cardWidth = %.f, cardHeight = %.f", cardWidth, cardHeight);
    return CGRectMake(horizontalSpace, verticalSpace, cardWidth, cardHeight);
}
*/
+ (NSMutableArray *)CardPropertiesForCategoryView {
    LayoutData* layoutData = [[LayoutManager sharedManager] propCategoryView];
    float cardWidth = 0;
    float cardHeight = 0;
    float horizontalSpace = 0;
    float verticalSpace = 0;
    int cardInRow = 0;
    float screenMaxW = [[MyDevice sharedManager] screenWidthInPortrait];
    float screenMaxH = [[MyDevice sharedManager] screenHeightInPortrait];
//    float screenCurrentW = [[MyDevice sharedManager] screenSize].width;
    int orientationId = [MyDevice orientationId];
    float screenMarginLeft = screenMaxH * layoutData->leftMarginPWRTH[orientationId] / 100.0f;
    float screenMarginRight = screenMaxH * layoutData->rightMarginPWRTH[orientationId] / 100.0f;
    
    screenMaxW = screenMaxW - (screenMarginLeft + screenMarginRight);
//    screenCurrentW = screenCurrentW - (screenMarginLeft + screenMarginRight);
    
    cardInRow = layoutData->cardInRowCount[orientationId];
    cardWidth = screenMaxW * layoutData->cardWidthPWRTW[orientationId] / 100.0f;
    cardHeight = screenMaxW * layoutData->cardHeightPWRTW[orientationId] / 100.0f;
    horizontalSpace = screenMaxW * layoutData->cardHorizontalSpacingPWRTW[orientationId] / 100.0f;
//    float horizontalSpace1 = (screenCurrentW - cardWidth * cardInRow)/(cardInRow);
    
    verticalSpace = screenMaxW * layoutData->cardVerticalSpacingPWRTW[orientationId] / 100.0f;
    
    float insetLeft = screenMaxW * layoutData->insetMarginLeftPWRTW[orientationId] / 100.0f;
    float insetRight = screenMaxW * layoutData->insetMarginRightPWRTW[orientationId] / 100.0f;
    float insetTop = screenMaxW * layoutData->insetMarginTopPWRTW[orientationId] / 100.0f;
    float insetBottom = screenMaxW * layoutData->insetMarginBottomPWRTW[orientationId] / 100.0f;
    
    
    NSMutableArray* array = [[NSMutableArray alloc] init];
    [array addObject:[NSNumber numberWithFloat:horizontalSpace]];
    [array addObject:[NSNumber numberWithFloat:verticalSpace]];
    [array addObject:[NSNumber numberWithFloat:cardWidth]];
    [array addObject:[NSNumber numberWithFloat:cardHeight]];
    [array addObject:[NSNumber numberWithFloat:insetLeft]];
    [array addObject:[NSNumber numberWithFloat:insetRight]];
    [array addObject:[NSNumber numberWithFloat:insetTop]];
    [array addObject:[NSNumber numberWithFloat:insetBottom]];
    
//    RLOG(@"cardWidth = %.f, cardHeight = %.f", cardWidth, cardHeight);
    return array;
//    return CGRectMake(horizontalSpace, verticalSpace, cardWidth, cardHeight);
}
+ (NSMutableArray *)CardPropertiesForHorizontalView {
    LayoutData* layoutData = [[LayoutManager sharedManager] propHorizontalView];
    float cardWidth = 0;
    float cardHeight = 0;
    float horizontalSpace = 0;
    float verticalSpace = 0;
    int cardInRow = 0;
    float screenMaxW = [[MyDevice sharedManager] screenWidthInPortrait];
    float screenMaxH = [[MyDevice sharedManager] screenHeightInPortrait];
    //    float screenCurrentW = [[MyDevice sharedManager] screenSize].width;
    int orientationId = [MyDevice orientationId];
    float screenMarginLeft = screenMaxH * layoutData->leftMarginPWRTH[orientationId] / 100.0f;
    float screenMarginRight = screenMaxH * layoutData->rightMarginPWRTH[orientationId] / 100.0f;
    
    screenMaxW = screenMaxW - (screenMarginLeft + screenMarginRight);
    //    screenCurrentW = screenCurrentW - (screenMarginLeft + screenMarginRight);
    
    cardInRow = layoutData->cardInRowCount[orientationId];
    cardWidth = screenMaxW * layoutData->cardWidthPWRTW[orientationId] / 100.0f;
    cardHeight = screenMaxW * layoutData->cardHeightPWRTW[orientationId] / 100.0f;
    horizontalSpace = screenMaxW * layoutData->cardHorizontalSpacingPWRTW[orientationId] / 100.0f;
    //    float horizontalSpace1 = (screenCurrentW - cardWidth * cardInRow)/(cardInRow);
    
    verticalSpace = screenMaxW * layoutData->cardVerticalSpacingPWRTW[orientationId] / 100.0f;
    
    float insetLeft = screenMaxW * layoutData->insetMarginLeftPWRTW[orientationId] / 100.0f;
    float insetRight = screenMaxW * layoutData->insetMarginRightPWRTW[orientationId] / 100.0f;
    float insetTop = screenMaxW * layoutData->insetMarginTopPWRTW[orientationId] / 100.0f;
    float insetBottom = screenMaxW * layoutData->insetMarginBottomPWRTW[orientationId] / 100.0f;
    
    
    NSMutableArray* array = [[NSMutableArray alloc] init];
    [array addObject:[NSNumber numberWithFloat:horizontalSpace]];
    [array addObject:[NSNumber numberWithFloat:verticalSpace]];
    [array addObject:[NSNumber numberWithFloat:cardWidth]];
    [array addObject:[NSNumber numberWithFloat:cardHeight]];
    [array addObject:[NSNumber numberWithFloat:insetLeft]];
    [array addObject:[NSNumber numberWithFloat:insetRight]];
    [array addObject:[NSNumber numberWithFloat:insetTop]];
    [array addObject:[NSNumber numberWithFloat:insetBottom]];
    
//    RLOG(@"cardWidth = %.f, cardHeight = %.f", cardWidth, cardHeight);
    return array;
    //    return CGRectMake(horizontalSpace, verticalSpace, cardWidth, cardHeight);
}
+ (NSMutableArray *)CardPropertiesForProductView {
    LayoutData* layoutData = [[LayoutManager sharedManager] propProductView];
    float cardWidth = 0;
    float cardHeight = 0;
    float horizontalSpace = 0;
    float verticalSpace = 0;
    int cardInRow = 0;
    float screenMaxW = [[MyDevice sharedManager] screenWidthInPortrait];
    float screenMaxH = [[MyDevice sharedManager] screenHeightInPortrait];
    //    float screenCurrentW = [[MyDevice sharedManager] screenSize].width;
    int orientationId = [MyDevice orientationId];
    float screenMarginLeft = screenMaxH * layoutData->leftMarginPWRTH[orientationId] / 100.0f;
    float screenMarginRight = screenMaxH * layoutData->rightMarginPWRTH[orientationId] / 100.0f;
    
    screenMaxW = screenMaxW - (screenMarginLeft + screenMarginRight);
    //    screenCurrentW = screenCurrentW - (screenMarginLeft + screenMarginRight);
    
    cardInRow = layoutData->cardInRowCount[orientationId];
    cardWidth = screenMaxW * layoutData->cardWidthPWRTW[orientationId] / 100.0f;
    cardHeight = screenMaxW * layoutData->cardHeightPWRTW[orientationId] / 100.0f;

    horizontalSpace = screenMaxW * layoutData->cardHorizontalSpacingPWRTW[orientationId] / 100.0f;
    //    float horizontalSpace1 = (screenCurrentW - cardWidth * cardInRow)/(cardInRow);
    
    verticalSpace = screenMaxW * layoutData->cardVerticalSpacingPWRTW[orientationId] / 100.0f;
    
    float insetLeft = screenMaxW * layoutData->insetMarginLeftPWRTW[orientationId] / 100.0f;
    float insetRight = screenMaxW * layoutData->insetMarginRightPWRTW[orientationId] / 100.0f;
    float insetTop = screenMaxW * layoutData->insetMarginTopPWRTW[orientationId] / 100.0f;
    float insetBottom = screenMaxW * layoutData->insetMarginBottomPWRTW[orientationId] / 100.0f;
    
    NSMutableArray* array = [[NSMutableArray alloc] init];
    [array addObject:[NSNumber numberWithFloat:horizontalSpace]];
    [array addObject:[NSNumber numberWithFloat:verticalSpace]];
    [array addObject:[NSNumber numberWithFloat:cardWidth]];
    [array addObject:[NSNumber numberWithFloat:cardHeight]];
    [array addObject:[NSNumber numberWithFloat:insetLeft]];
    [array addObject:[NSNumber numberWithFloat:insetRight]];
    [array addObject:[NSNumber numberWithFloat:insetTop]];
    [array addObject:[NSNumber numberWithFloat:insetBottom]];
    
//    RLOG(@"cardWidth = %.f, cardHeight = %.f", cardWidth, cardHeight);
    return array;
    //    return CGRectMake(horizontalSpace, verticalSpace, cardWidth, cardHeight);
}



/* + (CGRect)CardPropertiesForCategoryView {
    LayoutData* layoutData = [[LayoutManager sharedManager] propCategoryView];
    float cardWidth = 0;
    float cardHeight = 0;
    float horizontalSpace = 0;
    float verticalSpace = 0;
    int cardInRow = 0;
    
    float screenMaxW = [[MyDevice sharedManager] screenWidthInPortrait];
    float screenMaxH = [[MyDevice sharedManager] screenHeightInPortrait];
    float screenCurrentW = [[MyDevice sharedManager] screenSize].width;
    float screenMarginLeft = screenMaxH * layoutData.leftMarginPWRTH / 100.0f;
    float screenMarginRight = screenMaxH * layoutData.leftMarginPWRTH / 100.0f;
    screenMaxW = screenMaxW - (screenMarginLeft + screenMarginRight);
    screenCurrentW = screenCurrentW - (screenMarginLeft + screenMarginRight);
    bool isIPhone = [[MyDevice sharedManager] isIphone];
    bool isPortrait = [[MyDevice sharedManager] isPortrait];
    
    if (isIPhone) {
        if (isPortrait) {
            cardInRow = layoutData.iPhoneCardInRowCountP;
        }else{
            cardInRow = layoutData.iPhoneCardInRowCountL;
        }
        cardWidth = screenMaxW * layoutData.iPhoneCardWidthPWRTW / 100.0f;
        cardHeight = screenMaxW * layoutData.iPhoneCardHeightPWRTW / 100.0f;
        horizontalSpace = (screenCurrentW - cardWidth * cardInRow)/(cardInRow);
        verticalSpace = screenMaxW * layoutData.iPhoneCardVerticalSpacingPWRTW / 100.0f;
    } else {
        if (isPortrait) {
            cardInRow = layoutData.iPadCardInRowCountP;
        }else{
            cardInRow = layoutData.iPadCardInRowCountL;
        }
        cardWidth = screenMaxW * layoutData.iPadCardWidthPWRTW / 100.0f;
        cardHeight = screenMaxW * layoutData.iPadCardHeightPWRTW / 100.0f;
        horizontalSpace = (screenCurrentW - cardWidth * cardInRow)/(cardInRow);
        verticalSpace = screenMaxW * layoutData.iPadCardVerticalSpacingPWRTW / 100.0f;
    }
    RLOG(@"cardWidth = %.f, cardHeight = %.f", cardWidth, cardHeight);
    return CGRectMake(horizontalSpace, verticalSpace, cardWidth, cardHeight);
} */
+ (float)globalVerticalMargin{
    float maxHeight = [[MyDevice sharedManager] screenHeightInPortrait];
    return maxHeight * [[LayoutManager sharedManager] globalMarginPWRTH] / 100.0f;
}
@end
