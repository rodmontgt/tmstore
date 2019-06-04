//
//  PagedImageScrollView.m
//  Test
//
//  Created by jianpx on 7/11/13.
//  Copyright (c) 2013 PS. All rights reserved.
//

#import "PagedImageScrollView.h"
#import "Utility.h"

@interface PagedImageScrollView() <UIScrollViewDelegate>
@property (nonatomic) BOOL pageControlIsChangingPage;
@property BOOL bannerChangeAutomaticallyEnable;
@end

@implementation PagedImageScrollView


#define PAGECONTROL_DOT_WIDTH 20
#define PAGECONTROL_HEIGHT 30


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.scrollView = [[UIScrollView alloc] initWithFrame:frame];
        self.pageControl = [[UIPageControl alloc] init];
        [self setDefaults];
        [self.pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.scrollView];
        [self addSubview:self.pageControl];
        self.scrollView.delegate = self;
        self.bannerChangeAutomaticallyEnable = false;
    }
    return self;
}


- (void)setPageControlPos:(enum PageControlPosition)pageControlPos
{
    int pageControlHeight = PAGECONTROL_HEIGHT;
    
    CGFloat width = PAGECONTROL_DOT_WIDTH * self.pageControl.numberOfPages;
    _pageControlPos = pageControlPos;
    if (pageControlPos == PageControlPositionRightCorner)
    {
        self.pageControl.frame = CGRectMake(self.scrollView.frame.size.width - width, self.scrollView.frame.size.height - pageControlHeight, width, pageControlHeight);
    }else if (pageControlPos == PageControlPositionCenterBottom)
    {
        self.pageControl.frame = CGRectMake((self.scrollView.frame.size.width - width) / 2, self.scrollView.frame.size.height - pageControlHeight, width, pageControlHeight);
    }else if (pageControlPos == PageControlPositionLeftCorner)
    {
        self.pageControl.frame = CGRectMake(0, self.scrollView.frame.size.height - pageControlHeight, width, pageControlHeight);
    }
}

- (void)setDefaults
{
    self.pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    self.pageControl.hidesForSinglePage = YES;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.pageControlPos = PageControlPositionCenterBottom;
}


- (void)setScrollViewContents: (NSArray *)images
{
    //remove original subviews first.
    for (UIView *subview in [self.scrollView subviews]) {
        [subview removeFromSuperview];
    }
    if (images.count <= 0) {
        self.pageControl.numberOfPages = 0;
        return;
    }
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * images.count, self.scrollView.frame.size.height);
    for (int i = 0; i < images.count; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.scrollView.frame.size.width * i, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
        [imageView setImage:images[i]];
        [imageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        
//        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        [imageView setContentMode:UIViewContentModeScaleToFill];
        
        [self.scrollView addSubview:imageView];
        
        
        
        
        UIImageView *placeholderImage = (UIImageView *)[imageView viewWithTag:10000];
        if (placeholderImage) {
            [placeholderImage setImage:[Utility getPlaceholderImage:0]];
            [placeholderImage setFrame:CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height)];
        }else{
            placeholderImage = [[UIImageView alloc] initWithImage:[Utility getPlaceholderImage:0]];
            [placeholderImage setTag:10000];
            [placeholderImage setFrame:CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height)];
            [placeholderImage setContentMode:UIViewContentModeCenter];
            [imageView addSubview:placeholderImage];
        }
        
    }
    self.pageControl.numberOfPages = images.count;
    //call pagecontrolpos setter.
    self.pageControlPos = self.pageControlPos;
    [self.pageControl setPageIndicatorTintColor:[Utility getUIColor:kUIColorBannerNormalPageIndicator]];
    [self.pageControl setCurrentPageIndicatorTintColor:[Utility getUIColor:kUIColorBannerSelectedPageIndicator]];
}
- (void)setScrollViewContentsWithImageViews:(NSArray *)imageviews contentMode:(UIViewContentMode)contentMode
{
    //remove original subviews first.
    for (UIView *subview in [self.scrollView subviews]) {
        [subview removeFromSuperview];
    }
    if (imageviews.count <= 0) {
        self.pageControl.numberOfPages = 0;
        return;
    }
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * imageviews.count, self.scrollView.frame.size.height);
    for (int i = 0; i < imageviews.count; i++) {
        UIImageView *imageView = imageviews[i];
        [imageviews[i] setFrame:CGRectMake(self.scrollView.frame.size.width * i, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
        [imageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [imageView setContentMode:contentMode];
        [imageView setClipsToBounds:true];
//        [imageView setContentMode:UIViewContentModeScaleAspectFit];
//        [imageView setContentMode:UIViewContentModeScaleToFill];
        
        [self.scrollView addSubview:imageView];
        
        UIImageView *placeholderImage = (UIImageView *)[imageView viewWithTag:10000];
        
        if (placeholderImage) {
            [placeholderImage setImage:[Utility getPlaceholderImage:0]];
            [placeholderImage setFrame:CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height)];
        }else{
            placeholderImage = [[UIImageView alloc] initWithImage:[Utility getPlaceholderImage:0]];
            [placeholderImage setTag:10000];
            [placeholderImage setFrame:CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height)];
            [placeholderImage setContentMode:UIViewContentModeCenter];
            [imageView addSubview:placeholderImage];
        }
        
    }
    self.pageControl.numberOfPages = imageviews.count;
    //call pagecontrolpos setter.
    self.pageControlPos = self.pageControlPos;
    [self.pageControl setPageIndicatorTintColor:[Utility getUIColor:kUIColorBannerNormalPageIndicator]];
    [self.pageControl setCurrentPageIndicatorTintColor:[Utility getUIColor:kUIColorBannerSelectedPageIndicator]];
}

- (void)changePage:(UIPageControl *)sender
{
    CGRect frame = self.scrollView.frame;
    frame.origin.x = frame.size.width * self.pageControl.currentPage;
    frame.origin.y = 0;
    frame.size = self.scrollView.frame.size;
    [self.scrollView scrollRectToVisible:frame animated:YES];
    self.pageControlIsChangingPage = YES;
}
- (void)enableBannerChangeAutomatically {
    self.bannerChangeAutomaticallyEnable = true;
    self.moveInFwdDir = true;
    [self scheduleTimer];
}
- (void)scheduleTimer {
    if (self.bannerChangeAutomaticallyEnable) {
        if (self.nsTimer) {
            [self.nsTimer invalidate];
            self.nsTimer = nil;
        }
        self.nsTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(autoChangeBanner:) userInfo:nil repeats:YES];
    }
}
- (void)autoChangeBanner:(float)dt {
    if (self.moveInFwdDir) {
        self.pageControl.currentPage += 1;
        if (self.pageControl.currentPage == self.pageControl.numberOfPages - 1) {
            self.moveInFwdDir = false;
        }
    }else {
        self.pageControl.currentPage -= 1;
        if (self.pageControl.currentPage == 0) {
            self.moveInFwdDir = true;
        }
    }
    [self changePage:nil];
}
#pragma scrollviewdelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.pageControlIsChangingPage) {
        return;
    }
    [scrollView setContentOffset: CGPointMake(scrollView.contentOffset.x, 0)];
    CGFloat pageWidth = scrollView.frame.size.width;
    //switch page at 50% across
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.pageControlIsChangingPage = NO;
    [self scheduleTimer];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.pageControlIsChangingPage = NO;
    if (self.nsTimer) {
        [self.nsTimer invalidate];
        self.nsTimer = nil;
    }
}
- (void)reloadView:(CGRect)frame {
    [self setFrame:frame];
    [self setBounds:frame];
    [self.scrollView setFrame:frame];
    [self.pageControl setFrame:frame];

    int i = 0;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * [self.scrollView subviews].count, self.scrollView.frame.size.height);
    for (UIView *subview in [self.scrollView subviews]) {
        [subview setFrame:CGRectMake(self.scrollView.frame.size.width * i, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
        i++;
    }
    self.pageControl.numberOfPages = [self.scrollView subviews].count;
    [self setPageControlPos:self.pageControlPos];
    [self changePage:self.pageControl];
}
- (void)setCurrentPage:(int)pageIndex {
    if (pageIndex < self.pageControl.numberOfPages) {
        self.pageControl.currentPage = pageIndex;
        [self changePage:nil];
    }
}

@end
