//
//  ViewControllerGetCode.m
//  eMobileApp
//
//  Created by Rishabh Jain on 25/11/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import "ViewControllerGetCode.h"
#import "AppUser.h"
#import "Attribute.h"
#import "Order.h"
#import "DataManager.h"
#import "CommonInfo.h"
#import "Cart.h"
#import "AnalyticsHelper.h"


static int kTagForGlobalSpacing = 0;
static int kTagForNoSpacing = -1;

@interface ViewControllerGetCode () {
    NSMutableArray* _viewsAdded;
    UIButton *customBackButton;
}
@end


@implementation ViewControllerGetCode

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
}
-(void)viewDidAppear:(BOOL)animated{
#if ENABLE_FIREBASE_TAG_MANAGER
    [[AnalyticsHelper sharedInstance] registerVisitScreenEvent:@"GetCode Screen"];
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
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if([[MyDevice sharedManager] isIphone]){
        return UIInterfaceOrientationMaskPortrait;
    }
    return UIInterfaceOrientationMaskAll;
}

- (IBAction)barButtonBackPressed:(id)sender {
    [[Utility sharedManager] popScreenWithNewAnimation:self];
}
- (void)initVariables {
    _viewsAdded = [[NSMutableArray alloc] init];
    [_labelViewHeading setText:Localize(@"prompt_demo_code")];
    [self loadAllViews];
}

- (void)loadAllViews {
    NSMutableAttributedString *str1 = [[NSMutableAttributedString alloc] initWithString:Localize(@"get_code_step_1")];
    //    NSMutableAttributedString *str2 = [[NSMutableAttributedString alloc] initWithString:@"\n\n\n\t1.\tGo to your WordPress Admin Panel\n\t2.\tGo to Plugins -> Add New\n\t3.\tSearch for \"TMStore - WooCommerce Native Mobile App\" Plugin\n\t4.\tInstall and Activate the Plugin\n\t5.\tGo to \"TM Store\" Plugin Page on your WordPress Admin Panel\n\t6.\tFill few Basic Details and Submit\n\t7.\tClick on \"GET MOBILE APP\"\n\t8.\tGet Code for your Demo Mobile App\n\n\n"];
    NSMutableAttributedString *str2 = [[NSMutableAttributedString alloc] initWithString:Localize(@"\n\n\n\t1.\tGo to your WordPress Admin Panel\n\n\t2.\tGo to Plugins -> Add New\n\n\t3.\tSearch for \"TMStore - WooCommerce Native Mobile App\" Plugin\n\n\t4.\tInstall and Activate the Plugin\n\n\t5.\tGo to \"TM Store\" Plugin Page on your WordPress Admin Panel\n\n\t6.\tFill few Basic Details and Submit\n\n\t7.\tClick on \"GET MOBILE APP\"\n\n\t8.\tGet Code for your Demo Mobile App\n\n\n")];
    NSMutableAttributedString *str3 = [[NSMutableAttributedString alloc] initWithString:Localize(@"get_code_step_10")];
    
    
    NSMutableDictionary *attributesDictionary1 = [NSMutableDictionary dictionary];
    [attributesDictionary1 setObject:[Utility getUIFont:kUIFontType18 isBold:false] forKey:NSFontAttributeName];
    [attributesDictionary1 setObject:UIColorFromRGB(0x222222) forKey:NSForegroundColorAttributeName];
    [str1 addAttributes:attributesDictionary1 range:NSMakeRange(0, str1.length)];
    
    NSMutableDictionary *attributesDictionary2 = [NSMutableDictionary dictionary];
    [attributesDictionary2 setObject:[Utility getUIFont:kUIFontType16 isBold:false] forKey:NSFontAttributeName];
    [attributesDictionary2 setObject:UIColorFromRGB(0x444444) forKey:NSForegroundColorAttributeName];
    [str2 addAttributes:attributesDictionary2 range:NSMakeRange(0, str2.length)];
    
    NSMutableDictionary *attributesDictionary3 = [NSMutableDictionary dictionary];
    [attributesDictionary3 setObject:[Utility getUIFont:kUIFontType18 isBold:false] forKey:NSFontAttributeName];
    [attributesDictionary3 setObject:UIColorFromRGB(0x222222) forKey:NSForegroundColorAttributeName];
    [str3 addAttributes:attributesDictionary3 range:NSMakeRange(0, str3.length)];
    
    
    NSMutableAttributedString* strF = [[NSMutableAttributedString alloc] initWithString:@""];
    [strF appendAttributedString:str1];
    [strF appendAttributedString:str2];
    [strF appendAttributedString:str3];
    
    
    UIView* view = [self addHeaderView:strF isTransparant:false];
    [Utility showShadow:view];
    [self resetMainScrollView];
}
- (UIView*)addHeaderView:(NSAttributedString*)str isTransparant:(BOOL)isTransparant{
    UIView* view = [[UIView alloc] init];
    [_scrollView addSubview:view];
    [_viewsAdded addObject:view];
    [view setTag:kTagForGlobalSpacing];
    
    //    [view setFrame: CGRectMake(self.view.frame.size.width * 0.01f, 0, self.view.frame.size.width *.98f, 50)];
    [view setFrame: CGRectMake(self.view.frame.size.width * 0.015f, self.view.frame.size.width * 0.02f, self.view.frame.size.width *.97f, self.view.frame.size.height - self.view.frame.size.width * 0.02f - [[Utility sharedManager] topBarHeight])];
    
    if(isTransparant){
        [view setBackgroundColor:[Utility getUIColor:kUIColorClear]];
    } else{
        [view setBackgroundColor:[UIColor whiteColor]];
    }
    
    UILabel* label = [[UILabel alloc] init];
    [label setAttributedText:str];
    [label setNumberOfLines:0];
    
    CGRect labelRect = view.frame;
    float gapX = self.view.frame.size.width * 0.05f;
    float gapY = self.view.frame.size.width * 0.025f;
    labelRect.origin.x = gapX;
    labelRect.size.width = view.frame.size.width - gapX*2;
    labelRect.origin.y = gapY;
    [label setFrame:labelRect];
    [label sizeToFitUI];
    [label setTextAlignment:NSTextAlignmentLeft];
    [label setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [view addSubview:label];
    
    
    UIImageView* img = [[UIImageView alloc] init];
    [img setUIImage:[UIImage imageNamed:@"tmstore"]];
    [img setContentMode:UIViewContentModeScaleAspectFit];
    [img setFrame:CGRectMake(0, gapY, self.view.frame.size.width * .25f, self.view.frame.size.width * .25f)];
    [img setCenter:CGPointMake(view.frame.size.width * .5f, img.center.y)];
    [view addSubview:img];
    
    
    
    CGRect imgFrame = img.frame;
    labelRect = label.frame;
    labelRect.origin.y = CGRectGetMaxY(imgFrame) + gapY;
    [label setFrame:labelRect];
    //    [view setFrame: CGRectMake(self.view.frame.size.width * 0.01f, 0, self.view.frame.size.width *.98f, CGRectGetMaxY(labelRect) + gapY * 2)];
    
    float viewH = CGRectGetMaxY(labelRect) + gapY * 2;
    if (CGRectGetMaxY(labelRect) + gapY * 2 < self.view.frame.size.height - self.view.frame.size.width * 0.02f - [[Utility sharedManager] topBarHeight]) {
        viewH = self.view.frame.size.height - self.view.frame.size.width * 0.02f - [[Utility sharedManager] topBarHeight];
    }
    [view setFrame: CGRectMake(self.view.frame.size.width * 0.015f, self.view.frame.size.width * 0.02f, self.view.frame.size.width *.97f, viewH)];
    
    return view;
}

#pragma mark - Adjust Orientation
- (void)beforeRotation {
    UIView* lastView = [_viewsAdded lastObject];
    for(UIView *view in _viewsAdded) {
        [UIView animateWithDuration:0.1f animations:^{
            [view setAlpha:0.0f];
        }completion:^(BOOL finished){
            [view removeFromSuperview];
            if (view == lastView) {
                [_scrollView setAlpha:0.0f];
                [_viewsAdded removeAllObjects];
                [self loadAllViews];
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
    [self adjustViewsForOrientation:[[UIDevice currentDevice] orientation]];
    [self resetMainScrollView];
}
@end
