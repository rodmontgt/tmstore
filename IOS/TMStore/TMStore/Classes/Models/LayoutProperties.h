//
//  LayoutProperties.h
//  eMobileApp
//
//  Created by Rishabh Jain on 20/10/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

enum SCROLL_TYPE {
    SCROLL_TYPE_NONE,
    SCROLL_TYPE_VERTICAL,
    SCROLL_TYPE_HORIZONTAL,
    SCROLL_TYPE_SHOWFULL,
    SCROLL_TYPE_NOSCROLL,
};
@interface LayoutProperties : NSObject

@property float _posX;
@property float _posY;
@property float _mTop;
@property float _mBottom;
@property float _mLeft;
@property float _mRight;
@property float _height;
@property float _width;
@property float _sfX;
@property float _sfY;
@property BOOL _isFlexW;
@property BOOL _isFlexH;
@property int _scrollType;

@property BOOL _hasChild;
@property float _cmHorizontal;
@property float _cmVertical;
@property float _cHeight;
@property float _cWidth;
@property float _csfX;
@property float _csfY;
@property int _cInRowCount;

@property UIColor* _bgColor;

@property float _insetTop;
@property float _insetBottom;
@property float _insetLeft;
@property float _insetRight;


- (id)init;
- (id)initWithBannerValues;
- (id)initWithProductBannerValues;
- (id)initWithCollectionViewValues:(int)scrollType;
- (CGRect)getFrameRect;


//+ (CGRect)CardPropertiesForProductView;
+ (NSMutableArray *)CardPropertiesForCategoryView;
+ (NSMutableArray *)CardPropertiesForHorizontalView;
+ (NSMutableArray *)CardPropertiesForProductView;
+ (float)globalVerticalMargin;

- (void)setBannerProperties:(LayoutProperties *)layoutProp showFullSizeBanner:(BOOL)showFullSizeBanner;
- (void)setProductBannerProperties:(LayoutProperties *)layoutProp;
- (void)setCollectionViewProperties:(LayoutProperties *)layoutProp scrollType:(int)scrollType;

@end
