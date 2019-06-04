//
//  VCProductDesc.m
//  eMobileApp
//
//  Created by Rishabh Jain on 09/11/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import "VCProductDesc.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ProductInfo.h"
#import "ViewControllerMain.h"
#import "Utility.h"
#import "AppDelegate.h"
#import "CommonInfo.h"
#import "Variables.h"
#import "DataManager.h"
#import "ParseHelper.h"
#import "VCProducts.h"

static int kTagForGlobalSpacing = 0;
static int kTagForNoSpacing = -1;
@interface VCProductDesc () {
    NSMutableArray *_viewsAdded;
    UIButton *customBackButton;
}
@end
@implementation VCProductDesc
- (void)viewDidLoad {
    [super viewDidLoad];
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [Utility getUIColor:kUIColorThemeFont], NSForegroundColorAttributeName, [Utility getUIFont:kUIFontType24 isBold:false], NSFontAttributeName, nil]];
    [self.currentItemHeading setTitle:@"   "];
    
    _labelViewHeading = [[UILabel alloc] init] ;
    [_labelViewHeading setFrame:CGRectMake(0, 20, [[MyDevice sharedManager] screenSize].width, _navigationBar.frame.size.height)];
    [_labelViewHeading setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [_labelViewHeading setUIFont:kUIFontType24 isBold:false];
    [_labelViewHeading setTextColor:[Utility getUIColor:kUIColorThemeFont]];
    [_labelViewHeading setTextAlignment:NSTextAlignmentCenter];
    [_labelViewHeading setText:@"    "];
    [self.view addSubview:_labelViewHeading];
    
    [_navigationBar setClipsToBounds:false];
    [_lineView setBackgroundColor:[Utility getUIColor:kUIColorBorder]];
    [_scrollView setBackgroundColor:[Utility getUIColor:kUIColorBgTheme]];
    [self.view setBackgroundColor:[Utility getUIColor:kUIColorBgHeader]];
    [_navigationBar setBarTintColor:[Utility getUIColor:kUIColorBgHeader]];
    customBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [customBackButton setImage:[[UIImage imageNamed:@"img_arrow_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [customBackButton addTarget:self action:@selector(barButtonBackPressed:)forControlEvents:UIControlEventTouchUpInside];
    [customBackButton setTitle:[NSString stringWithFormat:@"  %@  ", Localize(@"i_back")] forState:UIControlStateNormal];
    [customBackButton setTintColor:[Utility getUIColor:kUIColorThemeFont]];
    [customBackButton setTitleColor:[Utility getUIColor:kUIColorThemeFont] forState:UIControlStateNormal];
    [customBackButton.titleLabel setUIFont:kUIFontType18 isBold:false];
    [customBackButton sizeToFit];
    [_previousItemHeading setCustomView:customBackButton];
    [_previousItemHeading setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[Utility getUIColor:kUIColorThemeFont], NSForegroundColorAttributeName, [Utility getUIFont:kUIFontType18 isBold:false], NSFontAttributeName, nil] forState:UIControlStateNormal];
    [[Utility sharedManager] startGrayLoadingBar:false];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //rv//[SDWebImageManager.sharedManager.imageDownloader setValue:@"SDWebImage Demo" forHTTPHeaderField:@"AppName"];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self loadDataInView];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
- (void)flushCache {
    [SDWebImageManager.sharedManager.imageCache clearMemory];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)barButtonBackPressed:(id)sender {
    [[Utility sharedManager] popScreen:self];
    //    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - Adjust Orientation
- (void)beforeRotation {
    UIView* lastView = [_viewsAdded lastObject];
    for(UIView *view in _viewsAdded)
    {
        [UIView animateWithDuration:0.1f animations:^{
            [view setAlpha:0.0f];
        }completion:^(BOOL finished){
            [view removeFromSuperview];
            if (view == lastView) {
                [_viewsAdded removeAllObjects];
            }
        }];
    }
}
- (void)afterRotation {
    [self loadDataInView];
    UIView* lastView = [_viewsAdded lastObject];
    for(UIView *vieww in _viewsAdded)
    {
        [vieww setAlpha:0.0f];
        [UIView animateWithDuration:0.5f animations:^{
            [vieww setAlpha:1.0f];
        }completion:^(BOOL finished){
            if (vieww == lastView) {
                [self resetMainScrollView];
            }
        }];
    }
}
- (void)beforeRotation:(float)dt {
    UIView* lastView = [_viewsAdded lastObject];
    for(UIView *view in _viewsAdded)
    {
        [UIView animateWithDuration:dt animations:^{
            [view setAlpha:0.0f];
        }completion:^(BOOL finished){
            [view removeFromSuperview];
            if (view == lastView) {
                [_viewsAdded removeAllObjects];
            }
        }];
    }
}
- (void)afterRotation:(float)dt {
    [self loadDataInView];
    UIView* lastView = [_viewsAdded lastObject];
    for(UIView *vieww in _viewsAdded)
    {
        [vieww setAlpha:0.0f];
        [UIView animateWithDuration:dt animations:^{
            [vieww setAlpha:1.0f];
        }completion:^(BOOL finished){
            if (vieww == lastView) {
                [self resetMainScrollView];
            }
        }];
    }
}
- (void)adjustViewsForOrientation:(UIDeviceOrientation) orientation {
    RLOG(@"====adjustViewsForOrientation====");
    [self beforeRotation];
}
- (void)adjustViewsAfterOrientation:(UIDeviceOrientation) orientation {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    RLOG(@"====adjustViewsAfterOrientation====");
    [self afterRotation];
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    if ([[AppDelegate getInstance] isAppEnteredInBackground]) {
        return;
    }
    [self adjustViewsAfterOrientation:[[UIDevice currentDevice] orientation]];
    [self resetMainScrollView];
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if ([[AppDelegate getInstance] isAppEnteredInBackground]) {
        return;
    }
    [[Utility sharedManager] startGrayLoadingBar:true];
    [self adjustViewsForOrientation:[[UIDevice currentDevice] orientation]];
    [self resetMainScrollView];
}
#pragma mark - Reset Views
- (void)resetMainScrollView {
    float globalPosY = 0.0f;
    UIView* tempView = nil;
    int i = 0;
    for (tempView in _viewsAdded) {
        CGRect rect = [tempView frame];
        if (i == 0) {
            globalPosY = 10;
        }
        rect.origin.y = globalPosY;
        
        [tempView setFrame:rect];
        globalPosY += rect.size.height;
        
        if ([tempView tag] == kTagForGlobalSpacing) {
            if ([[MyDevice sharedManager] isIpad]) {
                globalPosY += 20;//[LayoutProperties globalVerticalMargin];
            } else {
                globalPosY += 15;//[LayoutProperties globalVerticalMargin];
            }
        }
        i++;
    }
    [_scrollView setContentSize:CGSizeMake(_scrollView.contentSize.width, globalPosY)];
}
- (void)setProductData:(ProductInfo*)pInfo {
    self.productInfo = pInfo;
}
- (void)loadDataInView {
    if (self.productInfo) {
        UIView* headerShortDesc = [self addHeaderView:[self.productInfo getShortDescriptionAttributedString] isTransparant:false];
        [Utility showShadow:headerShortDesc];
        
        [_scrollView setContentSize:CGSizeMake(_scrollView.contentSize.width, MAX(_scrollView.contentSize.height, headerShortDesc.frame.size.height + 50))];
    }
    [[Utility sharedManager] stopGrayLoadingBar];
}
- (UIView*)addHeaderView:(NSAttributedString*)str isTransparant:(BOOL)isTransparant{
    UIView* view = [[UIView alloc] init];
    [_scrollView addSubview:view];
    [_viewsAdded addObject:view];
    [view setTag:kTagForNoSpacing];
    [view setFrame: CGRectMake(self.view.frame.size.width * 0.01f, self.view.frame.size.width * 0.01f, self.view.frame.size.width *.98f, 40)];
    if(isTransparant) {
        [view setBackgroundColor:[Utility getUIColor:kUIColorClear]];
    } else {
        [view setBackgroundColor:[UIColor whiteColor]];
    }
    
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, view.frame.size.width - 40, 0)];
    [view addSubview:label];
    [label setUIFont:kUIFontType16 isBold:false];
    [label setAttributedText:str];
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = 0;
    [label setTextColor:[Utility getUIColor:kUIColorFontLight]];
    [label sizeToFitUI];
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        [label setTextAlignment:NSTextAlignmentRight];
    } else {
        [label setTextAlignment:NSTextAlignmentLeft];
    }
    [label setAutoresizingMask:UIViewAutoresizingFlexibleWidth];

    
    CGRect labelRect = view.frame;
    labelRect.size.height = label.frame.size.height + 40;
    [view setFrame:labelRect];
    

    return view;
}

@end
