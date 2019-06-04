//
//  ViewControllerWebview.m
//  eMobileApp
//
//  Created by Rishabh Jain on 25/11/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import "ViewControllerWebview.h"
#import "AppUser.h"
#import "Attribute.h"
#import "Order.h"
#import "DataManager.h"
#import "CommonInfo.h"
#import "Cart.h"
#import "AnalyticsHelper.h"


static int kTagForGlobalSpacing = 0;
static int kTagForNoSpacing = -1;

@interface ViewControllerWebview () {
    NSMutableArray* _viewsAdded;
    UIButton *customBackButton;
}
@end


@implementation ViewControllerWebview

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
    
    [self initVariables];
    //    [[[DataManager sharedManager] tmMulticastDelegate] addDelegate:self];
}
-(void)viewDidAppear:(BOOL)animated{
#if ENABLE_FIREBASE_TAG_MANAGER
    [[AnalyticsHelper sharedInstance] registerVisitScreenEvent:@"Webview Screen"];
#endif
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)viewWillAppear:(BOOL)animated {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super viewWillAppear:animated];
}
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
            globalPosY += 10;//[LayoutProperties globalVerticalMargin];
        }
        i++;
    }
    [_scrollView setContentSize:CGSizeMake(_scrollView.contentSize.width, globalPosY)];
}
- (IBAction)barButtonBackPressed:(id)sender {
    [[Utility sharedManager] popScreen:self];
    if ([self.view tag] == PUSH_SCREEN_TYPE_BRAND) {
        return;
    }
    ViewControllerMain* mainVC = [ViewControllerMain getInstance];
    [mainVC resetPreviousState];
}
- (void)initVariables {
    _viewsAdded = [[NSMutableArray alloc] init];
    //    [_scrollView setBackgroundColor:[Utility getUIColor:kUIColorBgTheme]];
    //    [self.view setBackgroundColor:[Utility getUIColor:kUIColorBgHeader]];
    //    [_lineView setBackgroundColor:[Utility getUIColor:kUIColorBorder]];
    
    [_labelViewHeading setText:@""];
}
- (void)loadAllViews:(NSString*)linkStr enableTouchBg:(BOOL)enableTouchBg {
    _linkStr = linkStr;
    _webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    _enableTouchBg = enableTouchBg;
    _enableTouchBg =  true;
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        _webView.transform = CGAffineTransformMakeScale(-1, 1);
    }
    
    
    [_webView setDelegate:self];
    [_scrollView addSubview:_webView];
    [_viewsAdded addObject:_webView];
    [self loadWebView];
}
- (void)loadAllViews:(NSString*)linkStr {
    [self loadAllViews:linkStr enableTouchBg:false];
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
                [_scrollView setAlpha:0.0f];
                [_viewsAdded removeAllObjects];
                [self loadAllViews:_linkStr];
                for(UIView *vieww in _viewsAdded)
                {
                    [vieww setAlpha:0.0f];
                }
                [_scrollView setAlpha:1.0f];
            }
        }];
    }
}
- (void)afterRotation {
    for(UIView *vieww in _viewsAdded)
    {
        [UIView animateWithDuration:0.1f animations:^{
            [vieww setAlpha:1.0f];
        }completion:^(BOOL finished){
            
        }];
    }
}
- (void)adjustViewsForOrientation:(UIDeviceOrientation) orientation {
    RLOG(@"====adjustViewsForOrientation====");
    //    [self beforeRotation];
}
- (void)adjustViewsAfterOrientation:(UIDeviceOrientation) orientation {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    RLOG(@"====adjustViewsAfterOrientation====");
    //    [self afterRotation];
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
    [self adjustViewsForOrientation:[[UIDevice currentDevice] orientation]];
    [self resetMainScrollView];
}
#pragma mark - Webview
- (void)loadWebView {
    [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
    if (_enableTouchBg) {
        UIActivityIndicatorView* sV = [[Utility sharedManager] startGrayLoadingBar:true];
        sV.center = self.view.center;
    } else {
        [MRProgressOverlayView showOverlayAddedTo:[[UIApplication sharedApplication] keyWindow] title:@"" mode:MRProgressOverlayViewModeIndeterminateSmallDefault animated:YES];
    }
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:_linkStr]];
    [_webView loadRequest:urlRequest];
}
- (void)webViewDidStartLoad:(UIWebView *)webView {
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (_enableTouchBg) {
        [[Utility sharedManager] stopGrayLoadingBar];
    } else {
        [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
    }
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (_enableTouchBg) {
        [[Utility sharedManager] stopGrayLoadingBar];
    } else {
        [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
    }
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}
@end
