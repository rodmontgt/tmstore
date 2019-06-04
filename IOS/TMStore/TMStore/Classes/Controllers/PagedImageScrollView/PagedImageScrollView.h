//
//  PagedImageScrollView.h
//  Test
//
//  Created by jianpx on 7/11/13.
//  Copyright (c) 2013 PS. All rights reserved.
//

#import <UIKit/UIKit.h>

enum PageControlPosition {
    PageControlPositionRightCorner = 0,
    PageControlPositionCenterBottom = 1,
    PageControlPositionLeftCorner = 2,
};


@interface PagedImageScrollView : UIView

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, assign) enum PageControlPosition pageControlPos; //default is PageControlPositionRightCorner

- (void)setScrollViewContents: (NSArray *)images;
- (void)setScrollViewContentsWithImageViews:(NSArray *)imageviews contentMode:(UIViewContentMode)contentMode;
- (void)reloadView:(CGRect)frame;
- (void)enableBannerChangeAutomatically;
- (void)setCurrentPage:(int)pageIndex;
@property NSTimer* nsTimer;
@property BOOL moveInFwdDir;
@end
