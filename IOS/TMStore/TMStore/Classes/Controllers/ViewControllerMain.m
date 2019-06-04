//
//  ViewControllerMain.m
//  eCommerceApp
//
//  Created by Rishabh Jain on 16/09/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import "ViewControllerMain.h"
#import "RCustomViewSegue.h"
#import "SWRevealViewController.h"
#import "LayoutManager.h"
#import "Utility.h"
#import "Vendor.h"
#import "ViewControllerLeft.h"
#import "ViewControllerSearch.h"
#import "AnalyticsHelper.h"
#import <SDWebImage/UIButton+WebCache.h>

#if ENABLE_HOTLINE
#import "Hotline.h"
#elif ENABLE_FRESHCHAT
#import "Freshchat.h"
#endif

@interface ViewControllerMain ()
//@property (nonatomic, strong) NSMutableDictionary *viewControllersByIdentifier;
@property (strong, nonatomic) NSString *destinationIdentifier;
@end

static ViewControllerMain *_me = nil;

@implementation ViewControllerMain
//@synthesize sb = _sb;
@synthesize revealController = _revealController;
#pragma mark - View Life Cycle

- (void)viewDidLoad {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super viewDidLoad];

    _isBottomBarEnable = true;
    _containerBottom.hidden = false;
    _me = self;
    [Utility resetViewControllersByIdentifier];
    
    //    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    //    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(deviceOrientationDidChange:) name: UIDeviceOrientationDidChangeNotification object: nil];
    
    _revealController = [self revealViewController];
    [_revealController panGestureRecognizer];
    [_revealController tapGestureRecognizer];
    [_revealController panGestureRecognizerEnable:YES];
    [self deviceOrientationDidChange:nil];
    
    //    [self adjustViewsAfterOrientation:UIDeviceOrientationUnknown];
    
    self.viewControllersByIdentifier = [Utility getViewControllersByIdentifier];
    _sb = [Utility getStoryBoardObject];

    [self.revealController revealToggle:self];
    [self.revealController revealToggle:self];
    [self btnClickedHome:self];

}
- (void)viewWillAppear:(BOOL)animated {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super viewWillAppear:animated];
    
    [self adjustViewsAfterOrientation:[[UIDevice currentDevice] orientation]];
    //    if (self.childViewControllers.count < 1) {
    //        [self performSegueWithIdentifier:@"viewController1" sender:[self.buttons objectAtIndex:0]];
    //    }
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        _revealController.view.transform = CGAffineTransformMakeScale(-1, 1);
    }
    //    _containerBottom.transform = CGAffineTransformMakeScale(-1, 1);
    //    _containerBottomIphone.transform = CGAffineTransformMakeScale(-1, 1);
    //    _containerTop.transform = CGAffineTransformMakeScale(-1, 1);
    //    _containerCenter.transform = CGAffineTransformMakeScale(-1, 1);
    //    _containerCenterWithTop.transform = CGAffineTransformMakeScale(-1, 1);
    
}
- (void)viewDidAppear:(BOOL)animated {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super viewDidAppear:animated];
    [self adjustViewsAfterOrientation:[[UIDevice currentDevice] orientation]];
    [_vcTopBar redrawButtonRightView];
#if ENABLE_FIREBASE_TAG_MANAGER
    //[[AnalyticsHelper sharedInstance] registerVisitScreenEvent:@"Main Screen"];
#endif
}

- (void)didReceiveMemoryWarning {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    
    [[self.viewControllersByIdentifier allKeys] enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        if (![self.destinationIdentifier isEqualToString:key]) {
            [self.viewControllersByIdentifier removeObjectForKey:key];
        }
    }];
    
    [super didReceiveMemoryWarning];
}

#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:SEAGUE_VC_TOP_BAR])
        _vcTopBar = segue.destinationViewController;
    
    if ([[MyDevice sharedManager] isIphone]) {
        if ([segue.identifier isEqualToString:SEAGUE_VC_BOTTOM_BAR])
            _vcBottomBar = segue.destinationViewController;
    }else{
        if ([segue.identifier isEqualToString:SEAGUE_VC_BOTTOM_BAR])
            _vcBottomBar = segue.destinationViewController;
    }
    
    if ([segue.identifier isEqualToString:SEAGUE_VC_CENTER_TOP])
        _vcCenterTop = segue.destinationViewController;
    
    if (![segue isKindOfClass:[RCustomViewSegue class]]) {
        [super prepareForSegue:segue sender:sender];
        return;
    }
    self.oldViewController = self.destinationViewController;
    //if view controller isn't already contained in the viewControllers-Dictionary
    //    RLOG(@"####segue.identifier=%@", segue.identifier);
//    if (self.viewControllersByIdentifier == nil) {
//        self.viewControllersByIdentifier = [NSMutableDictionary dictionary];
//    }
    
    if (![self.viewControllersByIdentifier objectForKey:segue.identifier]) {
        [self.viewControllersByIdentifier setObject:segue.destinationViewController forKey:segue.identifier];
    }
    self.destinationIdentifier = segue.identifier;
    self.destinationViewController = [self.viewControllersByIdentifier objectForKey:self.destinationIdentifier];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([self.destinationIdentifier isEqual:identifier]) {
        //Dont perform segue, if visible ViewController is already the destination ViewController
        return NO;
    }
    return YES;
}

#pragma mark - Action
- (IBAction)btnClickedRightDrawer:(id)sender {
    
}
- (IBAction)btnClickedLeftDrawer:(id)sender {
    
}
- (void)selectedButton:(UIButton*)button label:(UILabel*)label{
    _vcBottomBar.buttonHome.selected = NO;
    _vcBottomBar.buttonCart.selected = NO;
    _vcBottomBar.buttonWishlist.selected = NO;
    _vcBottomBar.buttonSearch.selected = NO;
    _vcBottomBar.buttonOpinion.selected = NO;
    _vcBottomBar.buttonMyAccount.selected = NO;
    _vcBottomBar.buttonLiveChat.selected = NO;
    button.selected = YES;
    _vcTopBar.labelHeader.hidden = YES;
    _vcTopBar.imageLogo.hidden = YES;
    _vcTopBar.buttonHeader.hidden = NO;
    if (button != _vcBottomBar.buttonHome) {
        _vcTopBar.labelHeader.hidden = NO;
        _vcTopBar.buttonHeader.hidden = YES;
    } else {
        _vcTopBar.labelHeader.hidden = YES;
        _vcTopBar.buttonHeader.hidden = NO;
    }
    
    if (![[Addons sharedManager] show_home_title_image] && ![[Addons sharedManager] show_home_title_text]) {
        _vcTopBar.buttonHeader.hidden = YES;
     } else if ([[Addons sharedManager] show_home_title_image] && [[Addons sharedManager] show_home_title_text]) {
        
    } else if ([[Addons sharedManager] show_home_title_image]) {
        [_vcTopBar.buttonHeader setTitle:@"" forState:UIControlStateNormal];
    } else if ([[Addons sharedManager] show_home_title_text]) {
        [_vcTopBar.buttonHeader setImage:nil forState:UIControlStateNormal];
    }
    
    _vcTopBar.buttonBack.hidden = YES;
    _vcTopBar.buttonLeftView.hidden = NO;
    if ([[Addons sharedManager] multiVendor_enable] &&
        [[Addons sharedManager] multiVendor_screen_type] == MULTIVENDOR_SCREEN_SELLER) {
        _vcTopBar.buttonRightView.hidden = NO;
    } else {
        _vcTopBar.buttonRightView.hidden = YES;
    }
    
    [_vcBottomBar buttonClicked:nil];
    [_revealController panGestureRecognizerEnable:YES];
    self.containerTop.hidden = NO;
    self.containerCenter.hidden = NO;
    self.containerCenterWithTop.hidden = YES;
    
//    RLOG(@"self.containerCenterWithTop.subviews count = %d", (int)[self.containerCenterWithTop.subviews count]);
//    if ((int)[self.containerCenterWithTop.subviews count] > 1) {
//        
//    }
    NSMutableArray* vcToRemove = [[NSMutableArray alloc]initWithArray:self.vcCenterTop.childViewControllers];
    for (UIViewController* vcObj in vcToRemove) {
        [vcObj.view removeFromSuperview];
        [vcObj removeFromParentViewController];
    }
    
    self.selectedBottomItem = button;
    _vcBottomBar.labelHome.textColor = [Utility getUIColor:kUIColorThemeButtonNormal];
    _vcBottomBar.labelLiveChat.textColor = [Utility getUIColor:kUIColorThemeButtonNormal];
    _vcBottomBar.labelSearch.textColor = [Utility getUIColor:kUIColorThemeButtonNormal];
    _vcBottomBar.labelCart.textColor = [Utility getUIColor:kUIColorThemeButtonNormal];
    _vcBottomBar.labelWishlist.textColor = [Utility getUIColor:kUIColorThemeButtonNormal];
    _vcBottomBar.labelOpinion.textColor = [Utility getUIColor:kUIColorThemeButtonNormal];
    _vcBottomBar.labelMyAccount.textColor = [Utility getUIColor:kUIColorThemeButtonNormal];
    label.textColor = [Utility getUIColor:kUIColorThemeButtonSelected];
}

- (IBAction)btnClickedHome:(id)sender {

    _sb = [Utility getStoryBoardObject];
    NSString* stringAppDisplayName = Localize(@"app_display_name");
    if ([stringAppDisplayName isEqualToString:@""] || [stringAppDisplayName isEqualToString:@"app_display_name"]) {
        stringAppDisplayName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
        NSLog(@"stringAppDisplayName %@",stringAppDisplayName);

    }
    _vcTopBar.labelHeader.text = stringAppDisplayName;
    [_vcTopBar.buttonHeader setTitle:stringAppDisplayName forState:UIControlStateNormal];
    
    if ([[Addons sharedManager] show_actionbar_icon] && [[Addons sharedManager] actionbar_icon_url] && ![[[Addons sharedManager] actionbar_icon_url] isEqualToString:@""]) {
        NSString* icon_url =  [[Addons sharedManager] actionbar_icon_url];
        NSURL *url = [NSURL URLWithString:icon_url];
        NSData *data = [NSData dataWithContentsOfURL:url];
      // [_vcTopBar.buttonHeader setUIImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
       //[Utility setImage:_vcTopBar.buttonHeader.imageView url:icon_url resizeType:0 isLocal:false highPriority:true];
        NSLog(@"print_url %@",icon_url);
        [_vcTopBar.buttonHeader sd_setImageWithURL:[NSURL URLWithString:icon_url] forState:UIControlStateNormal];

          }

      if ([[Addons sharedManager] multiVendor_enable] &&
        [[Addons sharedManager] multiVendor_screen_type] == MULTIVENDOR_SCREEN_SELLER) {
        NSString* vendorName = [[NSUserDefaults standardUserDefaults] valueForKey:VENDOR_NAME];
        _vcTopBar.labelHeader.text = vendorName;
        [_vcTopBar.buttonHeader setTitle:vendorName forState:UIControlStateNormal];
          NSLog(@"vendor_name %@",vendorName);
         
    }
    [self selectedButton:_vcBottomBar.buttonHome label:_vcBottomBar.labelHome];
    [_vcTopBar.buttonHeader setImageEdgeInsets:UIEdgeInsetsMake(5, 0, 5, 0)];

    UIViewController *toViewController = nil;
    RCustomViewSegue *segue = nil;
    if ([[Addons sharedManager] isDynamicLayoutEnable]) {
        toViewController = [_sb instantiateViewControllerWithIdentifier:VC_HOME_DYNAMIC];
        segue = [[RCustomViewSegue alloc] initWithIdentifier:SEAGUE_VC_HOME_DYNAMIC source:self destination:toViewController];
    } else {
        toViewController = [_sb instantiateViewControllerWithIdentifier:VC_HOME];
        segue = [[RCustomViewSegue alloc] initWithIdentifier:SEAGUE_VC_HOME source:self destination:toViewController];
    }
//#if ENABLE_DYNAMIC_LAYOUT_HOME_SCREEN
//    toViewController = [_sb instantiateViewControllerWithIdentifier:VC_HOME_DYNAMIC];
//    segue = [[RCustomViewSegue alloc] initWithIdentifier:SEAGUE_VC_HOME_DYNAMIC source:self destination:toViewController];
//#else
//    toViewController = [_sb instantiateViewControllerWithIdentifier:VC_HOME];
//    segue = [[RCustomViewSegue alloc] initWithIdentifier:SEAGUE_VC_HOME source:self destination:toViewController];
//#endif
    [self prepareForSegue:segue sender:sender];
    [segue perform];
    
    _vcTopBar.lineView.frame = CGRectMake(0, _vcTopBar.view.frame.size.height - 1.0f, _vcTopBar.view.frame.size.width, 1.0f);
    NSMutableArray* vcObjToRemove = [[NSMutableArray alloc] init];
    for (UIViewController* vcObj in _vcCenterTop.childViewControllers) {
        if ([vcObj isKindOfClass:[ViewControllerCategories class]]) {
            [vcObj viewWillDisappear:true];
            [vcObjToRemove addObject:vcObj];
        }
    }
    for (UIViewController* vcObj in vcObjToRemove) {
        [vcObj removeFromParentViewController];
    }
}
- (IBAction)btnClickedMyAccount:(id)sender {
    _sb = [Utility getStoryBoardObject];
    _vcTopBar.labelHeader.text = Localize(@"title_profile");
    [_vcTopBar.buttonHeader setTitle:Localize(@"title_profile") forState:UIControlStateNormal];
    [self selectedButton:_vcBottomBar.buttonMyAccount label:_vcBottomBar.labelMyAccount];
    UIViewController *toViewController = [_sb instantiateViewControllerWithIdentifier:VC_LEFT];
    ViewControllerLeft* vcMyAccount = (ViewControllerLeft*)toViewController;
    vcMyAccount.isMyAccountScreen = true;
    RCustomViewSegue *segue = [[RCustomViewSegue alloc] initWithIdentifier:SEAGUE_VC_MY_ACCOUNT source:self destination:toViewController];
    [self prepareForSegue:segue sender:sender];
    [segue perform];
    
    _vcTopBar.lineView.frame = CGRectMake(0, _vcTopBar.view.frame.size.height - 1.0f, _vcTopBar.view.frame.size.width, 1.0f);
}
- (IBAction)btnClickedOpinion:(id)sender {
    _sb = [Utility getStoryBoardObject];
    _vcTopBar.labelHeader.text = Localize(@"title_poll");
    [_vcTopBar.buttonHeader setTitle:Localize(@"title_poll") forState:UIControlStateNormal];
    [self selectedButton:_vcBottomBar.buttonOpinion label:_vcBottomBar.labelOpinion];
    UIViewController *toViewController = [_sb instantiateViewControllerWithIdentifier:VC_OPINION];
    RCustomViewSegue *segue = [[RCustomViewSegue alloc] initWithIdentifier:SEAGUE_VC_OPINION source:self destination:toViewController];
    [self prepareForSegue:segue sender:sender];
    [segue perform];
    _vcTopBar.lineView.frame = CGRectMake(0, _vcTopBar.view.frame.size.height - 1.0f, _vcTopBar.view.frame.size.width, 1.0f);
}
- (IBAction)btnClickedLiveChat:(id)sender {
#if ENABLE_HOTLINE
    Addons* addons = [Addons sharedManager];
    if (addons.hotline && addons.hotline.isEnabled) {
        [[Hotline sharedInstance] showConversations:self];
    }
#elif ENABLE_FRESHCHAT
    Addons* addons = [Addons sharedManager];
    if (addons.hotline && addons.hotline.isEnabled) {
        [[Freshchat sharedInstance] showConversations:self];
    }
#endif
}

- (UIViewController *)btnClickedSearch:(id)sender {
    _sb = [Utility getStoryBoardObject];
    _vcTopBar.labelHeader.text = Localize(@"title_search");
    [_vcTopBar.buttonHeader setTitle:Localize(@"title_search") forState:UIControlStateNormal];

    [self selectedButton:_vcBottomBar.buttonSearch label:_vcBottomBar.labelSearch];
    UIViewController *toViewController = [_sb instantiateViewControllerWithIdentifier:VC_SEARCH];
    RCustomViewSegue *segue = [[RCustomViewSegue alloc] initWithIdentifier:SEAGUE_VC_SEARCH source:self destination:toViewController];

    [self prepareForSegue:segue sender:sender];
    [segue perform];
    
    _vcTopBar.lineView.frame = CGRectMake(0, _vcTopBar.view.frame.size.height - 1.0f, _vcTopBar.view.frame.size.width, 1.0f);
    return toViewController;
}

- (UIViewController*)getCartViewController:(id)sender {
    _vcTopBar.labelHeader.text = Localize(@"title_mycart");
    [_vcTopBar.buttonHeader setTitle:Localize(@"title_mycart") forState:UIControlStateNormal];
    [self selectedButton:_vcBottomBar.buttonCart label:_vcBottomBar.labelCart];
    UIViewController *toViewController = [_sb instantiateViewControllerWithIdentifier:VC_CART];
    RCustomViewSegue *segue = [[RCustomViewSegue alloc] initWithIdentifier:SEAGUE_VC_CART  source:self destination:toViewController];
    [self prepareForSegue:segue sender:sender];
    [segue perform];
    _vcTopBar.lineView.frame = CGRectMake(0, _vcTopBar.view.frame.size.height - 1.0f, _vcTopBar.view.frame.size.width, 1.0f);
    return toViewController;
}
- (IBAction)btnClickedCart:(id)sender {
    _sb = [Utility getStoryBoardObject];
    _vcTopBar.labelHeader.text = Localize(@"title_mycart");
    [_vcTopBar.buttonHeader setTitle:Localize(@"title_mycart") forState:UIControlStateNormal];

    [self selectedButton:_vcBottomBar.buttonCart label:_vcBottomBar.labelCart];
    UIViewController *toViewController = [_sb instantiateViewControllerWithIdentifier:VC_CART];
    RCustomViewSegue *segue = [[RCustomViewSegue alloc] initWithIdentifier:SEAGUE_VC_CART  source:self destination:toViewController];
    [self prepareForSegue:segue sender:sender];
    [segue perform];
    
    _vcTopBar.lineView.frame = CGRectMake(0, _vcTopBar.view.frame.size.height - 1.0f, _vcTopBar.view.frame.size.width, 1.0f);
}
- (IBAction)btnClickedWishlist:(id)sender {
    _sb = [Utility getStoryBoardObject];
    _vcTopBar.labelHeader.text = Localize(@"menu_title_wishlist");
    [_vcTopBar.buttonHeader setTitle:Localize(@"menu_title_wishlist") forState:UIControlStateNormal];
    [self selectedButton:_vcBottomBar.buttonWishlist label:_vcBottomBar.labelWishlist];
    UIViewController *toViewController = [_sb instantiateViewControllerWithIdentifier:VC_WISHLIST];
    RCustomViewSegue *segue = [[RCustomViewSegue alloc] initWithIdentifier:SEAGUE_VC_WISHLIST  source:self destination:toViewController];
    [self prepareForSegue:segue sender:sender];
    [segue perform];    
    _vcTopBar.lineView.frame = CGRectMake(0, _vcTopBar.view.frame.size.height - 1.0f, _vcTopBar.view.frame.size.width, 1.0f);
    
}
- (IBAction)btnClicked:(id)sender {
    //Write a code you want to execute on buttons click event
}
#pragma mark - Adjust Orientation
- (void)adjustViewsForOrientation:(UIDeviceOrientation) orientation {
    float topViewHeight = [[Utility sharedManager] getTopBarHeight];
    SWRevealViewController *revealController = [self revealViewController];
    CGRect rect = self.view.bounds;
    //    rect.origin.y = 0;//topViewHeight;
    //    rect.size.height = [[MyDevice sharedManager] screenSizeInPortrait].height;
    [[revealController transparentViewLeft] setFrame:rect];
    [[revealController transparentViewRight] setFrame:rect];
    revealController.frontViewShadowOffset = CGSizeMake(0.0f, rect.origin.y + 5.0f);
}
- (void)adjustViewsAfterOrientation:(UIDeviceOrientation) orientation {
    
    //    UIDeviceOrientation deviceOrientation =[[UIDevice currentDevice] orientation];
    SWRevealViewController *revealController = [self revealViewController];
    float leftViewWidth = 0.9f;
    float rightViewWidth = 0.9f;
    if ([[MyDevice sharedManager] isIpad]) {
        if ([[MyDevice sharedManager] isLandscape]) {
            leftViewWidth = [[LayoutManager sharedManager] leftViewProp]->ipad_L_PWRTW;
            rightViewWidth = [[LayoutManager sharedManager] rightViewProp]->ipad_L_PWRTW;
        } else {
            leftViewWidth = [[LayoutManager sharedManager] leftViewProp]->ipad_P_PWRTW;
            rightViewWidth = [[LayoutManager sharedManager] rightViewProp]->ipad_P_PWRTW;
        }
    } else {
        if ([[MyDevice sharedManager] isLandscape]) {
            leftViewWidth = [[LayoutManager sharedManager] leftViewProp]->iphone_L_PWRTW;
            rightViewWidth = [[LayoutManager sharedManager] rightViewProp]->iphone_L_PWRTW;
        } else {
            leftViewWidth = [[LayoutManager sharedManager] leftViewProp]->iphone_P_PWRTW;
            rightViewWidth = [[LayoutManager sharedManager] rightViewProp]->iphone_P_PWRTW;
        }
    }
    
    leftViewWidth /= 100.0f;
    rightViewWidth /= 100.0f;
    
    leftViewWidth *=  [[MyDevice sharedManager] screenSizeInPortrait].width; //self.view.bounds.size.width;
    rightViewWidth *= [[MyDevice sharedManager] screenSizeInPortrait].width; //self.view.bounds.size.width;
                                                                             //    RLOG(@"====leftViewWidth1 = %.f", leftViewWidth);
    [revealController setRearViewRevealWidth:leftViewWidth];
    [revealController setRightViewRevealWidth:rightViewWidth];
    //    if ([[revealController transparentView] isHidden] == false)
    //    {
    //        [revealController revealToggleAnimated:YES];
    //        [revealController revealToggleAnimated:YES];
    //    }
    CGRect rect = self.view.bounds;
    self.leftViewControllerWidth = leftViewWidth;
    self.rightViewControllerWidth = rightViewWidth;
    
    
    //    RLOG(@"====leftViewWidth2 = %.f", leftViewWidth);
    
    float viewPosX = 0;
    float viewWidth = [[MyDevice sharedManager] screenSize].width;
    
    
    float topViewHeight = [[Utility sharedManager] getTopBarHeight];//[[MyDevice sharedManager] screenHeightInPortrait] * .08f;
    float topViewPosY = 0;
    
    float bottomViewHeight = [[Utility sharedManager] getBottomBarHeight];//[[MyDevice sharedManager] screenHeightInPortrait] * .05f;
    if (_isBottomBarEnable == false) {
        bottomViewHeight = 0;
    }
    
    float bottomViewPosY = 0;
    
    float centerViewHeight = [[MyDevice sharedManager] screenSize].height - bottomViewHeight - topViewHeight;
    float centerViewPosY = 0;
    
    float centerTopViewHeight = [[MyDevice sharedManager] screenSize].height - bottomViewHeight;
    float centerTopViewPosY = 0;
    
    
    bottomViewPosY = centerTopViewHeight;
    centerViewPosY = topViewHeight;
    
    self.containerTop.frame = CGRectMake(viewPosX, topViewPosY, viewWidth, topViewHeight);
    self.containerBottom.frame = CGRectMake(viewPosX, bottomViewPosY, viewWidth, bottomViewHeight);
    self.containerCenter.frame = CGRectMake(viewPosX, centerViewPosY, viewWidth, centerViewHeight);
    self.containerCenterWithTop.frame = CGRectMake(viewPosX, centerTopViewPosY, viewWidth, centerTopViewHeight);
    
    
    rect = self.view.bounds;
    [[revealController transparentViewLeft] setFrame:rect];
    [[revealController transparentViewRight] setFrame:rect];
    revealController.frontViewShadowOffset = CGSizeMake(0.0f, rect.origin.y + 5.0f);
    
    _vcTopBar.lineView.frame = CGRectMake(0, _vcTopBar.view.frame.size.height - 1.0f, _vcTopBar.view.frame.size.width, 1.0f);
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    if ([[AppDelegate getInstance] isAppEnteredInBackground]) {
        return;
    }
    [self adjustViewsAfterOrientation:[[UIDevice currentDevice] orientation]];
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if ([[AppDelegate getInstance] isAppEnteredInBackground]) {
        return;
    }
    [self adjustViewsForOrientation:[[UIDevice currentDevice] orientation]];
}
- (void)deviceOrientationDidChange:(NSNotification *)notification {
}
+ (ViewControllerMain*)getInstance {
    return _me;
}
- (void)resetPreviousState
{
    ViewControllerMain* mainVC = [ViewControllerMain getInstance];
    if (self.selectedBottomItem == mainVC.vcBottomBar.buttonHome) {
        [self btnClickedHome:self];
    }
    if (self.selectedBottomItem == mainVC.vcBottomBar.buttonSearch) {
        [self btnClickedSearch:self];
    }
    if (self.selectedBottomItem == mainVC.vcBottomBar.buttonOpinion) {
        [self btnClickedOpinion:self];
    }
    if (self.selectedBottomItem == mainVC.vcBottomBar.buttonCart) {
        [self btnClickedCart:self];
    }
    if (self.selectedBottomItem == mainVC.vcBottomBar.buttonWishlist) {
        [self btnClickedWishlist:self];
    }
    if (self.selectedBottomItem == mainVC.vcBottomBar.buttonMyAccount) {
        [self btnClickedMyAccount:self];
    }
}
+ (void)resetInstance {
    NSArray* children = _me.childViewControllers;
    if (children) {
        for (UIViewController* vc in children) {
            [[Utility sharedManager] popScreenWithoutAnimation:vc];
        }
    }
    
    children = [_me.containerCenter subviews];
    for (UIView* v in children) {
        [v removeFromSuperview];
    }
    
    children = [_me.containerTop subviews];
    for (UIView* v in children) {
        [v removeFromSuperview];
    }
    
    children = [_me.containerBottom subviews];
    for (UIView* v in children) {
        [v removeFromSuperview];
    }
    
    children = [_me.containerCenterWithTop subviews];
    for (UIView* v in children) {
        [v removeFromSuperview];
    }
    
    children = [_me.view subviews];
    for (UIView* v in children) {
        [v removeFromSuperview];
    }
    [[Utility sharedManager] popScreenWithoutAnimation:_me.vcBottomBar];
    [_me.vcBottomBar dismissViewControllerAnimated:false completion:nil];
    
    [[Utility sharedManager] popScreenWithoutAnimation:_me.vcCenterTop];
    [_me.vcCenterTop dismissViewControllerAnimated:false completion:nil];
    
    [[Utility sharedManager] popScreenWithoutAnimation:_me.vcTopBar];
    [_me.vcTopBar dismissViewControllerAnimated:false completion:nil];
    
    [[Utility sharedManager] popScreenWithoutAnimation:_me.destinationViewController];
    [_me.destinationViewController dismissViewControllerAnimated:false completion:nil];
    
    [[Utility sharedManager] popScreenWithoutAnimation:_me];
    [_me dismissViewControllerAnimated:false completion:nil];
    
    
    _me.vcBottomBar = nil;
    _me.vcCenterTop = nil;
    _me.vcTopBar = nil;
    _me.destinationViewController = nil;
    _me = nil;
}

- (void)hideBottomBar {
    if (_me && _me.vcBottomBar && _me.vcBottomBar.buttons) {
        _isBottomBarEnable = false;
        _me.constraintBottomBarHeight.constant = 0;
        [_me.view updateConstraintsIfNeeded];
        [self.view layoutIfNeeded];
        [_me.containerBottom layoutIfNeeded];
        [_me.containerTop layoutIfNeeded];
        [_me.containerCenterWithTop layoutIfNeeded];
        [_me.containerCenter layoutIfNeeded];
        [_me.vcBottomBar.view layoutIfNeeded];
        [_me.vcBottomBar arrangeUI];
    }
}
- (void)showBottomBar {
    if (_me && _me.vcBottomBar && _me.vcBottomBar.buttons) {
        _isBottomBarEnable = true;
        _me.constraintBottomBarHeight.constant = 49;
        [_me.view updateConstraintsIfNeeded];
        [self.view layoutIfNeeded];
        [_me.containerBottom layoutIfNeeded];
        [_me.containerTop layoutIfNeeded];
        [_me.containerCenterWithTop layoutIfNeeded];
        [_me.containerCenter layoutIfNeeded];
        [_me.vcBottomBar.view layoutIfNeeded];
        [_me.vcBottomBar arrangeUI];
    }
}
@end
