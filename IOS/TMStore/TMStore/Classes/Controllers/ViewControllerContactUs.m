//
//  ViewControllerContactUs.m
//  eMobileApp
//
//  Created by Rishabh Jain on 25/11/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import "ViewControllerContactUs.h"
#import "ViewControllerWebview.h"
#import "AppUser.h"
#import "Attribute.h"
#import "Order.h"
#import "DataManager.h"
#import "CommonInfo.h"
#import "Cart.h"
#import "UIAlertView+NSCookbook.h"
#import "AnalyticsHelper.h"

static int kTagForGlobalSpacing = 1;
static int kTagForNoSpacing = -1;

@interface ViewControllerContactUs () {
    NSMutableArray* _viewsAdded;
    UIButton *customBackButton;
}
@end


@implementation ViewControllerContactUs

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [Utility getUIColor:kUIColorThemeFont], NSForegroundColorAttributeName, [Utility getUIFont:kUIFontType24 isBold:false], NSFontAttributeName, nil]];
    [self.currentItemHeading setTitle:@"   "];
    
    self.labelViewHeading = [[UILabel alloc] init] ;
    [self.labelViewHeading setFrame:CGRectMake(0, 20, [[MyDevice sharedManager] screenSize].width, self.navigationBar.frame.size.height)];
    [self.labelViewHeading setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self.labelViewHeading setUIFont:kUIFontType24 isBold:false];
    [self.labelViewHeading setTextColor:[Utility getUIColor:kUIColorThemeFont]];
    [self.labelViewHeading setTextAlignment:NSTextAlignmentCenter];
    [self.labelViewHeading setText:@"    "];
    [self.view addSubview:self.labelViewHeading];
    
    [self.navigationBar setClipsToBounds:false];
    [self.lineView setBackgroundColor:[Utility getUIColor:kUIColorBorder]];
    [_scrollView setBackgroundColor:[Utility getUIColor:kUIColorBgTheme]];
    [self.view setBackgroundColor:[Utility getUIColor:kUIColorBgHeader]];
    [self.navigationBar setBarTintColor:[Utility getUIColor:kUIColorBgHeader]];
    customBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [customBackButton setImage:[[UIImage imageNamed:@"img_arrow_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [customBackButton addTarget:self action:@selector(barButtonBackPressed:)forControlEvents:UIControlEventTouchUpInside];
    [customBackButton setTitle:[NSString stringWithFormat:@"  %@  ", Localize(@"i_back")] forState:UIControlStateNormal];
    [customBackButton setTintColor:[Utility getUIColor:kUIColorThemeFont]];
    [customBackButton setTitleColor:[Utility getUIColor:kUIColorThemeFont] forState:UIControlStateNormal];
    [customBackButton.titleLabel setUIFont:kUIFontType18 isBold:false];
    
    [customBackButton sizeToFit];
    [self.previousItemHeading setCustomView:customBackButton];
    [self.previousItemHeading setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[Utility getUIColor:kUIColorThemeFont], NSForegroundColorAttributeName, [Utility getUIFont:kUIFontType18 isBold:false], NSFontAttributeName, nil] forState:UIControlStateNormal];
    
    [self initVariables];
    //    [[[DataManager sharedManager] tmMulticastDelegate] addDelegate:self];
    
    [self loadAllViews];
}
-(void)viewDidAppear:(BOOL)animated{
#if ENABLE_FIREBASE_TAG_MANAGER
    [[AnalyticsHelper sharedInstance] registerVisitScreenEvent:@"ContactUs Screen"];
#endif
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)viewWillAppear:(BOOL)animated {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super viewWillAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super viewWillDisappear:animated];
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
    ViewControllerMain* mainVC = [ViewControllerMain getInstance];
    [mainVC resetPreviousState];
}
- (void)initVariables {
    _viewsAdded = [[NSMutableArray alloc] init];
    //    [_scrollView setBackgroundColor:[Utility getUIColor:kUIColorBgTheme]];
    //    [self.view setBackgroundColor:[Utility getUIColor:kUIColorBgHeader]];
    //    [self.lineView setBackgroundColor:[Utility getUIColor:kUIColorBorder]];
    
    [self.labelViewHeading setText:Localize(@"title_about")];
    
}

- (void)loadAllViews {
    for (UIView* view in _viewsAdded) {
        [view removeFromSuperview];
    }
    [_viewsAdded removeAllObjects];
    DataManager* dm = [DataManager sharedManager];
    if (dm.contactDetails == nil) {
        return;
    }
    
    
    
    for (_dic in [dm.contactDetails valueForKey:@"contactDetails"]) {
        RLOG(@"Divc value for key  %@",[_dic valueForKey:@"type"]);
        if ([[_dic valueForKey:@"type"] isEqualToString:@"image"]) {
            NSString* imgUrl = @"";
            if (IS_NOT_NULL(_dic, @"intro")) {
                imgUrl = GET_VALUE_STR(_dic, @"intro");
            }
            [self createLogoView:imgUrl];
        }
        else if ([[_dic valueForKey:@"type"] isEqualToString:@"description"]) {
            [self createDescriptionView];
        }
        else if ([[_dic valueForKey:@"type"] isEqualToString:@"phone"]) {
            [self createPhoneview];
        }
        else if ([[_dic valueForKey:@"type"] isEqualToString:@"email"]) {
            [self createEmailView];
        }
        else if ([[_dic valueForKey:@"type"] isEqualToString:@"address"]) {
            [self createAddreasView];
        }
        else if ([[_dic valueForKey:@"type"] isEqualToString:@"website"]) {
            [self createWebsiteView];
        }
    }
    [self resetMainScrollView];
    
    
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

#pragma mark - Create Contacviews

- (void)createLogoView:(NSString*)imgUrl {
    
    float viewHeightPercent = .25f;
    
    UIView *view = [[UIView alloc]init];
    //   view.frame = CGRectMake(0, 0, [[MyDevice sharedManager] screenSize].width, [[MyDevice sharedManager] screenSize].height * viewHeightPercent);
    _propBanner = [[LayoutProperties alloc] initWithBannerValues];
    
    [_propBanner setBannerProperties:_propBanner showFullSizeBanner:false];
    CGRect bannerRect = [_propBanner getFrameRect];
    
    view.frame = bannerRect;
    view.backgroundColor = [UIColor whiteColor];
    [_scrollView addSubview:view];
    [_viewsAdded addObject:view];
    [view setTag:kTagForNoSpacing];
    
    UIImageView *imgView =[[UIImageView alloc] init];
    [imgView setFrame:CGRectMake(0, 0, view.frame.size.height/2, view.frame.size.height/2)];
    imgView.center = CGPointMake(view.frame.size.width/2, view.frame.size.height/2);
    
    if (imgUrl == nil || [imgUrl isEqualToString:@""]) {
        [imgView setUIImage:[Utility getAppIconImage]];
    } else {
        [Utility setImage:imgView url:imgUrl placeholderImage:[Utility getAppIconImage]];
    }
    
    [view addSubview:imgView];
}
-(void)createDescriptionView{
    
    float viewWidth = [[MyDevice sharedManager] screenSize].width;
    float viewPosX = [[MyDevice sharedManager] screenSize].width * 0.00f;
    
    float itemPosX = [[MyDevice sharedManager] screenSize].width * 0.03f;
    float itemPosY = [[MyDevice sharedManager] screenSize].width * 0.01f;
    float itemWidth = viewWidth - itemPosX * 2;
    
    UIView *view = [[UIView alloc]init];
    view.frame = CGRectMake(viewPosX, 0, viewWidth, 0);
    view.backgroundColor = [UIColor whiteColor];
    [_scrollView addSubview:view];
    [_viewsAdded addObject:view];
    [view setTag:kTagForNoSpacing];
    
    
    float gapY = itemPosY;
    UILabel *lblTitle =[[UILabel alloc] init];
    lblTitle.frame = CGRectMake(itemPosX, itemPosY, itemWidth, 0);
    if (IS_NOT_NULL(_dic, @"label") && ![[_dic valueForKey:@"label"] isEqualToString:@""]) {
        [lblTitle setText:[_dic valueForKey:@"label"]];
    } else {
        [lblTitle setText:Localize(@"introduction")];
    }
    [view addSubview:lblTitle];
    lblTitle.numberOfLines = 0;
    [lblTitle setUIFont:kUIFontType18 isBold:false];
     [lblTitle setTextColor:[Utility getUIColor:kUIColorFontDark]];
    [lblTitle sizeToFitUI];
    itemPosY = (CGRectGetMaxY(lblTitle.frame) + gapY);
    
    UILabel *Introduction =[[UILabel alloc] initWithFrame:CGRectMake(itemPosX, itemPosY, itemWidth, 0)];
    
    NSString * htmlString = [_dic valueForKey:@"intro"];
    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    Introduction.attributedText = attrStr;
    [view addSubview:Introduction];
    Introduction.numberOfLines = 0;
    Introduction.textColor = [Utility getUIColor:kUIColorThemeButtonNormal];
    [Introduction setUIFont:kUIFontType16 isBold:false];
    [Introduction setTextColor:[Utility getUIColor:kUIColorFontLight]];
    [Introduction sizeToFitUI];
    itemPosY = (CGRectGetMaxY(Introduction.frame) + gapY);
    view.frame = CGRectMake(viewPosX, 0, viewWidth, itemPosY);
    //view.layer.borderWidth = 1.0;
}
-(void)createPhoneview{
    
    float viewWidth = [[MyDevice sharedManager] screenSize].width;
    float viewPosX = [[MyDevice sharedManager] screenSize].width * 0.00f;
    float itemPosX = [[MyDevice sharedManager] screenSize].width * 0.03f;
    float itemPosY = [[MyDevice sharedManager] screenSize].width * 0.01f;
    
    float buttonHeight = [[MyDevice sharedManager] screenHeightInPortrait] * .075f;
    
    float buttonEdge = buttonHeight * .20f;
    
    float itemWidth = viewWidth - itemPosX * 2;
    
    UIView *view = [[UIView alloc]init];
    view.frame = CGRectMake(viewPosX, 0, viewWidth, 0);
    view.backgroundColor = [UIColor whiteColor];
    [_scrollView addSubview:view];
    [_viewsAdded addObject:view];
    [view setTag:kTagForNoSpacing];
    
    float gapY = itemPosY;
    UILabel *lblTitle =[[UILabel alloc] init];
    lblTitle.frame = CGRectMake(itemPosX, itemPosY, itemWidth, 0);
    if (IS_NOT_NULL(_dic, @"label") && ![[_dic valueForKey:@"label"] isEqualToString:@""]) {
        [lblTitle setText:[_dic valueForKey:@"label"]];
    } else {
        [lblTitle setText:Localize(@"call_or_whatsapp")];
    }
    [view addSubview:lblTitle];
    lblTitle.numberOfLines = 0;
    [lblTitle setUIFont:kUIFontType18 isBold:false];
    [lblTitle setTextColor:[Utility getUIColor:kUIColorFontDark]];
    [lblTitle sizeToFitUI];
    itemPosY = (CGRectGetMaxY(lblTitle.frame) + gapY);
    
    NSString * stringList = [_dic valueForKey:@"intro"];
    NSArray *listItems = [stringList componentsSeparatedByString:@","];
    
    for (NSString *stringIntro in listItems) {
        UIButton *btnPhone = [[UIButton alloc]init];
        btnPhone.frame = CGRectMake(itemPosX * 2, itemPosY, itemWidth, buttonHeight);
        
        float edgeSize = buttonHeight * .25f;
        [[btnPhone titleLabel] setUIFont:kUIFontType16 isBold:false];
        [btnPhone setTitle:stringIntro forState:UIControlStateNormal];
        [btnPhone setTitleColor:[Utility getUIColor:kUIColorFontLight] forState:UIControlStateNormal];
        [btnPhone setImageEdgeInsets:UIEdgeInsetsMake(edgeSize, 0, edgeSize, 0)];
        [btnPhone setTitleEdgeInsets:UIEdgeInsetsMake(0, edgeSize, 0, 0)];
        [btnPhone.imageView setContentMode:UIViewContentModeScaleAspectFit];
        UIImage* normalWL = [[UIImage imageNamed:@"Phone-30.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImage* selectedWL = [[UIImage imageNamed:@"Phone-30.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImage* highlightedWL = [[UIImage imageNamed:@"Phone-30.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [btnPhone setUIImage:normalWL forState:UIControlStateNormal];
        [btnPhone setUIImage:selectedWL forState:UIControlStateSelected];
        [btnPhone setUIImage:highlightedWL forState:UIControlStateHighlighted];
        btnPhone.backgroundColor = [UIColor clearColor];
        [btnPhone setTintColor:[Utility getUIColor:kUIColorFontLight]];
        [view addSubview:btnPhone];
        [btnPhone setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [btnPhone.layer setValue:stringIntro forKey:@"PHONE_NUMBER_STR"];
        [btnPhone addTarget:self action:@selector(openPhoneCall:) forControlEvents:UIControlEventTouchUpInside];
        [btnPhone.titleLabel sizeToFitUI];
//        [btnPhone sizeToFit];
        itemPosY = (CGRectGetMaxY(btnPhone.frame));
        
    }
    
    view.frame = CGRectMake(viewPosX, 0, viewWidth, itemPosY);
}
-(void)createEmailView{
    
    float viewWidth = [[MyDevice sharedManager] screenSize].width ;
    float viewPosX = [[MyDevice sharedManager] screenSize].width * 0.00f;
    float itemPosX = [[MyDevice sharedManager] screenSize].width * 0.03f;
    float itemPosY = [[MyDevice sharedManager] screenSize].width * 0.01f;
    float itemWidth = viewWidth - itemPosX * 2;
    float buttonHeight = [[MyDevice sharedManager] screenHeightInPortrait] * .075f;
    
    UIView *view = [[UIView alloc]init];
    view.frame = CGRectMake(viewPosX, 0, viewWidth, 0);
    view.backgroundColor = [UIColor whiteColor];
    [_scrollView addSubview:view];
    [_viewsAdded addObject:view];
    [view setTag:kTagForNoSpacing];
    
    float gapY = itemPosY;
    UILabel *lblTitle =[[UILabel alloc] init];
    lblTitle.frame = CGRectMake(itemPosX, itemPosY, itemWidth, 0);
    if (IS_NOT_NULL(_dic, @"label") && ![[_dic valueForKey:@"label"] isEqualToString:@""]) {
        [lblTitle setText:[_dic valueForKey:@"label"]];
    } else {
        [lblTitle setText:Localize(@"email")];
    }
    
    [view addSubview:lblTitle];
    lblTitle.numberOfLines = 0;
    [lblTitle setUIFont:kUIFontType18 isBold:false];
    [lblTitle setTextColor:[Utility getUIColor:kUIColorFontDark]];
    [lblTitle sizeToFitUI];
    itemPosY = (CGRectGetMaxY(lblTitle.frame) + gapY);
    
    
    NSString * stringList = [_dic valueForKey:@"intro"];
    NSArray *listItems = [stringList componentsSeparatedByString:@","];
    RLOG(@"listitems   =  %@",listItems);
    for (NSString *stringIntro in listItems) {
        UIButton *btnMail = [[UIButton alloc]init];
        btnMail.frame = CGRectMake(itemPosX * 2, itemPosY, itemWidth, buttonHeight);
        float edgeSize = buttonHeight * .25f;
        [[btnMail titleLabel] setUIFont:kUIFontType16 isBold:false];
        [btnMail setTitle:stringIntro forState:UIControlStateNormal];
        [btnMail setTitleColor:[Utility getUIColor:kUIColorFontLight] forState:UIControlStateNormal];
        [btnMail setImageEdgeInsets:UIEdgeInsetsMake(edgeSize, 0, edgeSize, 0)];
        [btnMail setTitleEdgeInsets:UIEdgeInsetsMake(0, edgeSize, 0, 0)];
        [btnMail.imageView setContentMode:UIViewContentModeScaleAspectFit];
        UIImage* normalWL = [[UIImage imageNamed:@"Mail-30.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImage* selectedWL = [[UIImage imageNamed:@"Mail-30.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImage* highlightedWL = [[UIImage imageNamed:@"Mail-30.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [btnMail setUIImage:normalWL forState:UIControlStateNormal];
        [btnMail setUIImage:selectedWL forState:UIControlStateSelected];
        [btnMail setUIImage:highlightedWL forState:UIControlStateHighlighted];
        [btnMail setTintColor:[Utility getUIColor:kUIColorFontLight]];
        btnMail.backgroundColor = [UIColor clearColor];
        [view addSubview:btnMail];
        [btnMail.layer setValue:stringIntro forKey:@"EMAIL_STR"];
        [btnMail setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        
        [btnMail addTarget:self action:@selector(openMail:) forControlEvents:UIControlEventTouchUpInside];
        [btnMail.titleLabel sizeToFitUI];
//        [btnMail sizeToFit];
        itemPosY = (CGRectGetMaxY(btnMail.frame));
        
    }
    view.frame = CGRectMake(viewPosX, 0, viewWidth, itemPosY);
    
}
-(void)createAddreasView{
    float viewWidth = [[MyDevice sharedManager] screenSize].width ;
    float viewPosX = [[MyDevice sharedManager] screenSize].width * 0.00f;
    
    float itemPosX = [[MyDevice sharedManager] screenSize].width * 0.03f;
    float itemPosY = [[MyDevice sharedManager] screenSize].width * 0.01f;
    float itemWidth = viewWidth - itemPosX * 2;
    
    UIView *view = [[UIView alloc]init];
    view.frame = CGRectMake(viewPosX, 0, viewWidth, 0);
    view.backgroundColor = [UIColor whiteColor];
    [_scrollView addSubview:view];
    [_viewsAdded addObject:view];
    [view setTag:kTagForNoSpacing];
    
    
    float gapY = itemPosY;
    UILabel *lblTitle =[[UILabel alloc] init];
    lblTitle.frame = CGRectMake(itemPosX, itemPosY, itemWidth, 0);
    if (IS_NOT_NULL(_dic, @"label") && ![[_dic valueForKey:@"label"] isEqualToString:@""]) {
        [lblTitle setText:[_dic valueForKey:@"label"]];
    } else {
        [lblTitle setText:Localize(@"address")];
    }
    [view addSubview:lblTitle];
    lblTitle.numberOfLines = 0;
    [lblTitle setUIFont:kUIFontType18 isBold:false];
    [lblTitle setTextColor:[Utility getUIColor:kUIColorFontDark]];
    [lblTitle sizeToFitUI];
    itemPosY = (CGRectGetMaxY(lblTitle.frame) + gapY);
    
    UILabel *lblAddres =[[UILabel alloc] initWithFrame:CGRectMake(itemPosX, itemPosY, itemWidth, 0)];
    
    NSString * htmlString = [_dic valueForKey:@"intro"];
    
    
    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    lblAddres.attributedText = attrStr;
    [view addSubview:lblAddres];
    lblAddres.numberOfLines = 0;
    [lblAddres setTextColor:[Utility getUIColor:kUIColorFontLight]];
    [lblAddres setUIFont:kUIFontType16 isBold:false];
    [lblAddres sizeToFitUI];
    itemPosY = (CGRectGetMaxY(lblAddres.frame) + gapY);
    
    view.frame = CGRectMake(viewPosX, 0, viewWidth, itemPosY);
    
}

-(void)createWebsiteView{
    float viewWidth = [[MyDevice sharedManager] screenSize].width ;
    float viewPosX = [[MyDevice sharedManager] screenSize].width * 0.00f;
    float itemPosX = [[MyDevice sharedManager] screenSize].width * 0.03f;
    float itemPosY = [[MyDevice sharedManager] screenSize].width * 0.01f;
    float itemWidth = viewWidth - itemPosX * 2;
    
    UIView *view = [[UIView alloc]init];
    view.frame = CGRectMake(viewPosX, 0, viewWidth, 0);
    view.backgroundColor = [UIColor whiteColor];
    [_scrollView addSubview:view];
    [_viewsAdded addObject:view];
    [view setTag:kTagForNoSpacing];
    
    float gapY = itemPosY;
    UILabel *lblTitle =[[UILabel alloc] init];
    lblTitle.frame = CGRectMake(itemPosX, itemPosY, itemWidth, 0);
    if (IS_NOT_NULL(_dic, @"label") && ![[_dic valueForKey:@"label"] isEqualToString:@""]) {
        [lblTitle setText:[_dic valueForKey:@"label"]];
    } else {
        [lblTitle setText:Localize(@"website")];
    }
    [view addSubview:lblTitle];
    lblTitle.numberOfLines = 0;
    [lblTitle setUIFont:kUIFontType18 isBold:false];
    [lblTitle setTextColor:[Utility getUIColor:kUIColorFontDark]];
    [lblTitle sizeToFitUI];
    itemPosY = (CGRectGetMaxY(lblTitle.frame) + gapY);
    
    itemPosY = (CGRectGetMaxY(lblTitle.frame) + gapY);
    
    UILabel *lblWebAddres =[[UILabel alloc] initWithFrame:CGRectMake(0, itemPosY, itemWidth, 0)];
    UIButton *btnwebAddres = [[UIButton alloc]init];
    [view addSubview:lblWebAddres];
    [view addSubview:btnwebAddres];
    NSString * htmlString = [_dic valueForKey:@"intro"];
    
    lblWebAddres.numberOfLines = 0;
    lblWebAddres.textColor = [Utility getUIColor:kUIColorThemeButtonNormal];
    [lblWebAddres setUIFont:kUIFontType16 isBold:false];
    [lblWebAddres setAttributedText:[Utility createLinkAttributedString:htmlString]];
    [lblWebAddres sizeToFitUI];
    itemPosY = (CGRectGetMaxY(lblWebAddres.frame) + gapY);
    
    view.frame = CGRectMake(viewPosX, 0, viewWidth, itemPosY);
    lblWebAddres.center = CGPointMake(view.frame.size.width/2, view.frame.size.height/2);
    btnwebAddres.frame = lblWebAddres.frame;
    [btnwebAddres.layer setValue:htmlString forKey:@"LINK_STR"];
    [btnwebAddres addTarget:self action:@selector(openViewControllerWebview:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Webside Methore

-(void)openViewControllerWebview:(UIButton *)button{
    UIAlertView *alert= [[UIAlertView alloc]initWithTitle:@"" message:[NSString stringWithFormat:Localize(@"visit_site"), [button.layer valueForKey:@"LINK_STR"]] delegate:self cancelButtonTitle:Localize(@"btn_no") otherButtonTitles:Localize(@"btn_yes"), nil];
    [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1){
            NSString* linkUrl = [button.layer valueForKey:@"LINK_STR"];
            ViewControllerMain* mainVC = [ViewControllerMain getInstance];
            ViewControllerWebview* vcWebview = (ViewControllerWebview*)[[Utility sharedManager] pushScreenWithNewAnimation:mainVC.vcCenterTop type:PUSH_SCREEN_TYPE_WEBVIEW];
            [vcWebview loadAllViews:linkUrl];
            [vcWebview.view setTag:PUSH_SCREEN_TYPE_BRAND];
            
        }
    }];
    
}

#pragma mark - Email Send Methore

-(void)openMail: (UIButton *)button{
    UIAlertView *alert= [[UIAlertView alloc]initWithTitle:@"" message:[NSString stringWithFormat:Localize(@"write_to_email"), [button.layer valueForKey:@"EMAIL_STR"]] delegate:self cancelButtonTitle:Localize(@"btn_no") otherButtonTitles:Localize(@"btn_yes"), nil];
    [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            if ([MFMailComposeViewController canSendMail]) {
                NSString *strMail = [button.layer valueForKey:@"EMAIL_STR"];
                MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] initWithNibName:nil bundle:nil];
                [composeViewController setMailComposeDelegate:self];
                [composeViewController setToRecipients:@[strMail]];
                [self presentViewController:composeViewController animated:YES completion:nil];
            }
        }
    }];
}
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Phone Call Methore

-(void)openPhoneCall:(UIButton *)button{
    if ([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPhone) {
        UIAlertView *alert= [[UIAlertView alloc]initWithTitle:@"" message:[NSString stringWithFormat:Localize(@"call_to_number"),[button.layer valueForKey:@"PHONE_NUMBER_STR"]] delegate:self cancelButtonTitle:Localize(@"btn_no") otherButtonTitles:Localize(@"btn_yes"), nil];
        [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                NSString *phoneNumberString = [button.layer valueForKey:@"PHONE_NUMBER_STR"];
                phoneNumberString = [phoneNumberString stringByReplacingOccurrencesOfString:@" " withString:@""];
                phoneNumberString = [NSString stringWithFormat:@"tel:%@", phoneNumberString];
                NSURL *phoneNumberURL = [NSURL URLWithString:phoneNumberString];
                [[UIApplication sharedApplication] openURL:phoneNumberURL];
            }
        }];
    }else{
        
    }
}


@end
