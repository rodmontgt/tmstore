//
//  ViewControllerSellerZone.m

//
//  Created by Rajshekhar on 18/07/17.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import "ViewControllerSellerZone.h"
#import "Variables.h"
#import "Utility.h"
#import "AnalyticsHelper.h"
#import <CoreLocation/CoreLocation.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "SellerZoneTableViewCell.h"
#import "VCProducts.h"
#import "ViewControllerUploadProduct.h"
#import "VCMyOrders.h"
#import "DataManager.h"
#import "SellerZoneManager.h"
#import "ProductInfo.h"
#import "ProductImage.h"
#import "AppUser.h"
#import "SellerInfo.h"
#import "ViewControllerLeft.h"
#import "VCSellerProfile.h"
#import "TMDataDoctor.h"

enum SELLER_ZONE_ROW_TYPE {
    SELLER_ZONE_ROW_TYPE_NONE,
    SELLER_ZONE_ROW_TYPE_LOGIN,
    SELLER_ZONE_ROW_TYPE_PRODUCTS,
    SELLER_ZONE_ROW_TYPE_UPLOAD,
    SELLER_ZONE_ROW_TYPE_ORDERS,
    SELLER_ZONE_ROW_TYPE_INFO,
    SELLER_ZONE_ROW_TYPE_LOGOUT,
    SELLER_ZONE_ROW_TYPE_TOTAL
};
enum SELLER_ZONE_BUTTONS_IDS {
    BUTTONS_ID_LOGIN = 6,
    BUTTONS_ID_LOGOUT = 7,
    BUTTONS_ID_SellerProducts = 23,
    BUTTONS_ID_SellerUploadProduct = 24,
    BUTTONS_ID_SellerOrders = 25,
    BUTTONS_ID_SellerWallet = 26,
    BUTTONS_ID_SellerStoreSettings = 27,
    BUTTONS_ID_SellerAnalytics = 28,
};

static int kTagForGlobalSpacing = 0;
static int kTagForNoSpacing = -1;
@interface ViewControllerSellerZone () <UITableViewDelegate,UITableViewDataSource> {
    NSMutableArray* _viewsAdded;
    UIButton *customBackButton;
    __weak IBOutlet UIImageView *imageUser;
    __weak IBOutlet UILabel *labelTitle;
    __weak IBOutlet UILabel *labelShopeName;
    __weak IBOutlet UILabel *labelPhone;
    __weak IBOutlet UILabel *labelAddress;
    __weak IBOutlet UITableView *tableSellerZone;
    __weak IBOutlet UIView *viewSellerInfo;
    NSMutableArray *arrayDashBoardElememts;
    NSMutableArray *arrayDashBoardImages;
    ViewControllerLeft* leftVC;
    
    BOOL showSellerProducts;
    BOOL showUploadProduct;
    BOOL showOrders;
    BOOL showStoreSettings;
    BOOL showLogout;
}
@end


@implementation ViewControllerSellerZone

- (void)viewDidLoad {
    [super viewDidLoad];
    
    imageUser.layer.masksToBounds = true;
    imageUser.layer.cornerRadius = 40;
    //imageUser.clipsToBounds = true;
    
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [Utility getUIColor:kUIColorThemeFont], NSForegroundColorAttributeName, [Utility getUIFont:kUIFontType24 isBold:false], NSFontAttributeName, nil]];
    [self.currentItemHeading setTitle:@""];
    
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
    
    
    //[imageUser setContentMode:UIViewContentModeScaleAspectFit];
    
    [self initVariables];
    [self loadAllViews];
    //    [[[DataManager sharedManager] tmMulticastDelegate] addDelegate:self];
    
    //remove empty cells
    tableSellerZone.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    showSellerProducts = false;
    showUploadProduct = false;
    showOrders = false;
    showStoreSettings = false;
    showLogout = true;
    Addons* addons = [Addons sharedManager];
    if(addons.multiVendor && addons.multiVendor.multiVendor_shop_settings) {
        ShopSettings* sSettings = addons.multiVendor.multiVendor_shop_settings;
        if (sSettings && sSettings.profile_items && [sSettings.profile_items count] > 0) {
            for (NSString* nsStrObj in sSettings.profile_items) {
                int profileId = [nsStrObj intValue];
                switch (profileId) {
                    case BUTTONS_ID_SellerProducts:
                        showSellerProducts = true;
                        break;
                    case BUTTONS_ID_SellerUploadProduct:
                        showUploadProduct = true;
                        break;
                    case BUTTONS_ID_SellerOrders:
                        showOrders = true;
                        break;
                    case BUTTONS_ID_SellerStoreSettings:
                        showStoreSettings = true;
                        break;
                    default:
                        break;
                }
            }
        }
        else {
            showSellerProducts = true;
            showUploadProduct = true;
            showOrders = true;
            showStoreSettings = true;
        }
    } else {
        showSellerProducts = true;
        showUploadProduct = true;
        showOrders = true;
        showStoreSettings = true;
    }
    arrayDashBoardElememts = [[NSMutableArray alloc] initWithObjects:
                              @"",
                              @"Login",
                              Localize(@"seller_my_products"),
                              Localize(@"seller_upload_product"),
                              Localize(@"seller_my_orders"),
                              Localize(@"store_settings"),
                              Localize(@"title_logout"),
                              nil];
    arrayDashBoardImages = [[NSMutableArray alloc] initWithObjects:
                            @"",
                            @"product_icon",
                            @"product_icon",
                            @"upload_icon",
                            @"my_orders",
                            @"btn_store_outline",
                            @"btn_logout_outline",
                            nil];
    

    [self.labelDesc setText:[NSString stringWithFormat:Localize(@"seller_intro"), [Utility getAppName]]];
    [self.labelDesc setTextAlignment:NSTextAlignmentCenter];
    [self.buttonLogin setTitle:Localize(@"btn_seller_register") forState:UIControlStateNormal];
    [self.buttonLogin addTarget:self action:@selector(createLoginView) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonLogin setBackgroundColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
    [self.buttonLogin setTitleColor:[Utility getUIColor:kUIColorBuyButtonFont] forState:UIControlStateNormal];
    [self.buttonLogin.titleLabel setUIFont:kUIFontType16 isBold:false];
    
    [self resetView];
    [self loadCurrentSellerData];
    if ([Utility isSellerOnlyApp]) {
        [customBackButton setHidden:true];
    }
    
}
- (void)loadCurrentSellerData {

    AppUser* appUser = [AppUser sharedManager];
    if (appUser._id != -1) {
      
        
        labelTitle.text = [NSString stringWithFormat:@"%@ %@", appUser._first_name, appUser._last_name];
        if ([[SellerInfo getCurrentSeller] sellerAvatarUrl] && ![[[SellerInfo getCurrentSeller] sellerAvatarUrl] isEqualToString:@""]) {
            [Utility setImage:imageUser url:[[SellerInfo getCurrentSeller] sellerAvatarUrl] resizeType:0 isLocal:false highPriority:true];
        } else {
//            [Utility setImage:imageUser url:appUser._avatar_url resizeType:0 isLocal:false highPriority:true];
        }
        labelShopeName.hidden = true;
        
        // Update seller info UI
        
        labelTitle.text = [NSString stringWithFormat:@"%@", [[SellerInfo getCurrentSeller] sellerTitle]];
        labelShopeName.text = [[SellerInfo getCurrentSeller] shopName];
        labelPhone.text = [[SellerInfo getCurrentSeller] sellerPhone];
        labelAddress.text = [[SellerInfo getCurrentSeller] shopAddress];
        
        labelShopeName.hidden = false;
        if ([[SellerInfo getCurrentSeller] sellerAvatarUrl] && ![[[SellerInfo getCurrentSeller] sellerAvatarUrl] isEqualToString:@""]) {
            [Utility setImage:imageUser url:[[SellerInfo getCurrentSeller] sellerAvatarUrl] resizeType:0 isLocal:false highPriority:true];
        } else {
            [Utility setImage:imageUser url:appUser._avatar_url resizeType:0 isLocal:false highPriority:true];
        }
    } else {
        [self resetView];
    }
}


- (void)viewDidAppear:(BOOL)animated{
#if ENABLE_FIREBASE_TAG_MANAGER
    [[AnalyticsHelper sharedInstance] registerVisitScreenEvent:@"Seller Zone"];
#endif
    
//    [self resetView];
   [self loadCurrentSellerData];
//    if ([Utility isSellerOnlyApp]) {
//        [customBackButton setHidden:true];
//    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}
- (void)viewWillAppear:(BOOL)animated {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super viewWillAppear:animated];
    [self loadCurrentSellerData];
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
    [mainVC showBottomBar];
}

- (void)initVariables {
    _viewsAdded = [[NSMutableArray alloc] init];
    [_labelViewHeading setText:Localize(@"title_seller_zone")];
}
- (void)loadAllViews {
    
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
- (void)setDelegate:(id)delegate {
    _delegate = delegate;
}
#pragma mark - TableView-Delegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return arrayDashBoardElememts.count;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL isSignedIn = false;
    if ([AppUser isSignedIn]) {
        isSignedIn = true;
    }
    [tableSellerZone setHidden:!isSignedIn];
    [self.viewNoSeller setHidden:isSignedIn];
    BOOL isFullHeight = false;
    if (indexPath.row == SELLER_ZONE_ROW_TYPE_LOGIN) {
        isFullHeight = !isSignedIn;
    } else {
        isFullHeight = isSignedIn;
    }
    float height = 120;
    if ([[MyDevice sharedManager] isIphone]) {
        height = 75;
    }
    if (isFullHeight == false) {
        height = 0;
    }
    if (indexPath.row == SELLER_ZONE_ROW_TYPE_NONE) {
        height = 1;
    }
    
    switch (indexPath.row) {
        case SELLER_ZONE_ROW_TYPE_LOGIN:
        {
            
        }break;
        case SELLER_ZONE_ROW_TYPE_PRODUCTS:
        {
            if (showSellerProducts == false) {
                height = 0;
            }
        }break;
        case SELLER_ZONE_ROW_TYPE_UPLOAD:
        {
            if (showUploadProduct == false) {
                height = 0;
            }
        }break;
        case SELLER_ZONE_ROW_TYPE_ORDERS:
        {
            if (showOrders == false) {
                height = 0;
            }
        }break;
        case SELLER_ZONE_ROW_TYPE_INFO:
        {
            if (showStoreSettings == false) {
                height = 0;
            }
        }break;
        case SELLER_ZONE_ROW_TYPE_LOGOUT:
        {
            
        }break;
        default:
        {
        
        }break;
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"SellerZoneTableViewCell";
    SellerZoneTableViewCell *cell = (SellerZoneTableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        cell = [[SellerZoneTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    cell.labelProductsName.text = [arrayDashBoardElememts objectAtIndex:indexPath.row];
    cell.imageProduct.image = [UIImage imageNamed:[arrayDashBoardImages objectAtIndex:indexPath.row]];
    [cell.imageProduct setImage:[cell.imageProduct.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [[cell labelProductsName] setUIFont:kUIFontType16 isBold:false];
    
    [cell.imageProduct setTintColor:[UIColor colorWithRed:93/255.0 green:92/255.0 blue:98/255.0 alpha:1]];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case SELLER_ZONE_ROW_TYPE_LOGIN:
        {
            [self createLoginView];
        }break;
        case SELLER_ZONE_ROW_TYPE_PRODUCTS:
        {
//            VCProducts *vcProducts=[[VCProducts alloc] initWithNibName:@"VCProducts" bundle:nil];
            //[vcProducts setData:[SellerInfo getCurrentSeller]];
//            [self presentViewController:vcProducts animated:YES completion:nil];
            
            
            ViewControllerMain* mainVC = [ViewControllerMain getInstance];
            mainVC.containerTop.hidden = YES;
            mainVC.containerCenter.hidden = YES;
            mainVC.containerCenterWithTop.hidden = NO;
            mainVC.vcBottomBar.buttonHome.selected = YES;
            mainVC.vcBottomBar.buttonCart.selected = NO;
            mainVC.vcBottomBar.buttonWishlist.selected = NO;
            mainVC.vcBottomBar.buttonSearch.selected = NO;
            mainVC.revealController.panGestureEnable = false;
            [mainVC.vcBottomBar buttonClicked:nil];
            
//            VCProducts* vcProducts = (VCProducts*)[[Utility sharedManager] pushScreenWithoutAnimation:mainVC.vcCenterTop type:PUSH_SCREEN_TYPE_VC_PRODUCTS];
            VCProducts* vcProducts = (VCProducts*)[[Utility sharedManager] pushOverScreenWithoutAnimation:mainVC.vcCenterTop type:PUSH_SCREEN_TYPE_VC_PRODUCTS];
            [vcProducts setData:[SellerInfo getCurrentSeller]];

        }break;
        case SELLER_ZONE_ROW_TYPE_UPLOAD:
        {
            ViewControllerUploadProduct *vcUploadProduct=[[ViewControllerUploadProduct alloc] initWithNibName:@"ViewControllerUploadProduct" bundle:nil];
            [self presentViewController:vcUploadProduct animated:YES completion:nil];
        }break;
        case SELLER_ZONE_ROW_TYPE_ORDERS:
        {
            UIStoryboard* storyBoardObj = [UIStoryboard storyboardWithName:@"StoryboardOrders" bundle:nil];
            VCMyOrders *vcMyOrders = [storyBoardObj instantiateViewControllerWithIdentifier:@"VCMyOrders"];
            [self presentViewController:vcMyOrders animated:YES completion:nil];
        }break;
        case SELLER_ZONE_ROW_TYPE_INFO:
        {
            VCSellerProfile*vcSellerProfilew = [[VCSellerProfile alloc]initWithNibName:@"VCSellerProfile" bundle:nil];
            vcSellerProfilew.vcSellerZone = self;
            [self presentViewController:vcSellerProfilew animated:YES completion:nil];
        }break;
        case SELLER_ZONE_ROW_TYPE_LOGOUT:
        {
            [self logout];
        }break;
        default:
            break;
    }
}
- (void)createLoginView {
    if (leftVC == nil) {
        UIStoryboard *sb = [Utility getStoryBoardObject];
        leftVC = [sb instantiateViewControllerWithIdentifier:VC_LEFT];
    }
    [self.navigationController pushViewController:leftVC animated:YES];
    NSArray* array = [leftVC.view subviews];
    for (UIView* view in array) {
        [view setHidden:true];
    }
    [leftVC showLoginPopup:true];
    __block ViewControllerSellerZone* me = self;
    leftVC.didDismiss = ^(NSString *data) {
        [me resetView];
        [me loadCurrentSellerData];
    };
}
- (void)logout {
    if (leftVC == nil) {
        UIStoryboard *sb = [Utility getStoryBoardObject];
        leftVC = [sb instantiateViewControllerWithIdentifier:VC_LEFT];
    }
    [self.navigationController pushViewController:leftVC animated:YES];
    NSArray* array = [leftVC.view subviews];
    for (UIView* view in array) {
        [view setHidden:true];
    }
    [leftVC logoutClicked];
    __block ViewControllerSellerZone* me = self;
    leftVC.didDismiss = ^(NSString *data) {
        [SellerInfo setCurrentSeller:nil];
        [me resetView];
    };
}
- (void)resetView {
    [tableSellerZone reloadData];
    [imageUser setImage:[Utility getAppIconImage]];
    [labelTitle setText:@""];
    [labelShopeName setText:@""];
    [labelPhone setText:@""];
    [labelAddress setText:@""];
}


- (IBAction)ActionEditProfile:(id)sender {
    VCSellerProfile*vcSellerProfilew = [[VCSellerProfile alloc]initWithNibName:@"VCSellerProfile" bundle:nil];
    [self presentViewController:vcSellerProfilew animated:YES completion:nil];
}

@end
