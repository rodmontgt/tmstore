//
//  ViewControllerLeft.m
//  eCommerceApp
//
//  Created by Rishabh Jain on 16/09/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import "ViewControllerLeft.h"
#import "ViewControllerContactUs.h"
#import "DLContent.h"
#import "ViewControllerContactForm.h"
#import "ViewControllerReservationForm.h"
#import "SWRevealViewController.h"
#import "Variables.h"
#import "RATreeView.h"
#import "RADataObject.h"
#import "RATableViewCell.h"
#import "RCustomViewSegue.h"
#import "ProductInfo.h"
#import "ProductImage.h"
#import "CategoryInfo.h"
#import "LoginViewOnDrawer.h"
#import "LayoutManager.h"
#import "Utility.h"
#import "ViewControllerMain.h"
#import "ViewControllerAddress.h"
#import "ViewControllerLogin.h"
#import "CNPPopupController.h"
#import "AppUser.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "WebViewWordPress.h"
#import "MRProgress.h"
#import "DataManager.h"
#import "Variables.h"
#import "ViewControllerOrder.h"
#import "ViewControllerSponsorFriend.h"
#import "ViewControllerWebview.h"
#import "LoginFlow.h"
#import "ParseHelper.h"
#import "ViewControllerMyCoupon.h"
#import "BarcodeScannerViewController.h"
#import "LocateStoreViewController.h"
#import "ViewControllerPlatformSelection.h"
#import "ViewControllerSellerZone.h"
#if ENABLE_HOTLINE
#import "Hotline.h"
#elif ENABLE_FRESHCHAT
#import "Freshchat.h"
#endif
#import "CustomMenu.h"
#import "UITextView+LocalizeConstrint.h"
#import "AppDelegate.h"
#import "AnalyticsHelper.h"
#import "ViewControllerNotification.h"
#import "ViewControllerSetting.h"
#import "ViewControllerSplashPrimary.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#define SINGLE_LINE 0
#define REGISTRATION_HIDE_USERNAME 1
#define LOGIN_HIDE_FORGET_PASSWORD 0
#define NEW_CHU 1

#define NEW_LOGIN_ISSUE 1
#if ENABLE_TWITTER_LOGIN
#import <TwitterKit/TwitterKit.h>
#import <TwitterCore/TwitterCore.h>
#endif
//#define MY_ACCOUNT_SCREEN 1

/*
 //public static final int kIdPageHome = 0;
 //public static final int kIdPageWishlist = 1;
 //public static final int kIdPageMyCart = 2;
 //public static final int kIdPageMyOrders = 3;
 //public static final int kIdPageSettings = 4;
 //public static final int kIdPageAbout = 5;
 //public static final int kIdPageSignIn = 6;
 //public static final int kIdPageSignOut = 7;
 //public static final int kIdPageProfile = 8;
 //public static final int kIdPageSearch = 9;
 //public static final int kIdPageCategories = 10;
 //public static final int kIdPageOpinion = 11;
 //public static final int kIdPageWPMenu = 12;
 //public static final int kIdPageHotline = 13;
 public static final int kIdPageWebPage = 14;
 public static final int kIdSponsorFriend = 15;
 public static final int kIdChangeMerchant = 16;
 public static final int kIdChangeVendor = 17;
 //public static final int kIdRateApp = 18;
 */


enum BUTTONS_ID {
    BUTTONS_ID_HOME = 0,
    BUTTONS_ID_WISHLIST = 1,
    BUTTONS_ID_CART = 2,
    BUTTONS_ID_ORDERS = 3,
    BUTTONS_ID_SETTINGS = 4,
    BUTTONS_ID_CONTACT_US = 5,
    BUTTONS_ID_LOGIN = 6,
    BUTTONS_ID_LOGOUT = 7,
    BUTTONS_ID_ADDRESS = 8,//profile
    BUTTONS_ID_SEARCH = 9,
    BUTTONS_ID_CATEGORIES = 10,
    BUTTONS_ID_OPINION = 11,
    BUTTONS_ID_MENU_ITEMS = 12,//wp menu
    BUTTONS_ID_LIVE_CHAT = 13,//hotline
    BUTTONS_ID_RATE_APP = 18,
    BUTTONS_ID_WEBVIEW = 14,//webview
    BUTTONS_ID_SPONSOR_FRIEND = 15,
    BUTTONS_ID_REWARDS = 50,
    //    BUTTONS_ID_HELP_AND_SUPPORT = 51,
    BUTTONS_ID_TERMS_AND_CONDITIONS = 52,
    BUTTONS_ID_LANGUAGES = 53,
    BUTTONS_ID_GROUP = 19, //Grope list
    BUTTONS_ID_MYCOUPON = 22, // MycouponList
    BUTTONS_ID_NOTIFICATION = 33, //Notification List
    
    BUTTONS_ID_CONTACT_FORM = 39,
    BUTTONS_ID_RESERVATION_FORM = 38,
    
    
    BUTTONS_ID_CHANGE_STORE = 37,
    BUTTONS_ID_SCAN_BARCODE = 36,
    
    BUTTONS_ID_LOCATE_STORE = 41,
    BUTTONS_ID_RESET_PASSWORD = 42,
    BUTTONS_ID_SELLER_ZONE = 20,
    
    //    BUTTONS_ID_SellerProducts = 23,
    //    BUTTONS_ID_SellerUploadProduct = 24,
    //    BUTTONS_ID_SellerOrders = 25,
    //    BUTTONS_ID_SellerWallet = 26,
    //    BUTTONS_ID_SellerStoreSettings = 27,
    //    BUTTONS_ID_SellerAnalytics = 28,
    BUTTONS_ID_TOTAL
};

//IdPageSignIn = 6;
//IdPageSignOut = 7;
//IdSellerProducts = 23;
//IdSellerUploadProduct = 24;
//IdSellerOrders = 25;
//IdSellerWallet = 26;
//IdSellerStoreSettings = 27;
//IdSellerAnalytics = 28;
//IdPageProfileFull = 30;
//IdScanProduct = 36;
//IdChangeStore = 37;
//IdLocateStore = 41;

@interface ViewControllerLeft () <RATreeViewDelegate, RATreeViewDataSource, UITableViewDataSource, UITableViewDelegate, CNPPopupControllerDelegate, UITextFieldDelegate, BarcodeScannerDelegate>{
    ViewControllerMain* mainVC;
}

@property (strong, nonatomic) NSMutableArray *dataObjects;
@property (weak, nonatomic) RATreeView *treeView;
@property (strong, nonatomic) UIBarButtonItem *editButton;
@property (nonatomic, strong) CNPPopupController *popupController;
@property (nonatomic, strong) CNPPopupController *popupControllerRegister;
@property (nonatomic, strong) CNPPopupController *popupControllerRegisterAsSeller;

@property (nonatomic, strong) CNPPopupController *popupControllerForgotPassword;
@property (nonatomic, strong) CNPPopupController *popupControllerSettings;
@property (nonatomic, strong) CNPPopupController *popupControllerSponserFriend;
@property (nonatomic, strong) CNPPopupController *popupControllerOTP;
@property (nonatomic, strong) CNPPopupController *popupControllerResetPassword;
@end


@implementation ViewControllerLeft
#pragma mark - View Life Cycle
- (void)viewDidLoad {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super viewDidLoad];
    
    [LoginFlow sharedManager];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(languageChanged:) name:@"LANGUAGE_CHANGED" object:nil];
    if ([[MyDevice sharedManager] isIpad]) {
        _gap = 10.0f;
    } else {
        _gap = 7.0f;
    }
    if (_isMyAccountScreen) {
        _rowH = 200.0f;
    } else {
        _rowH = 65.0f;
    }
    
    _chkBoxLanguage = [[NSMutableArray alloc] init];
    [self loadData];
    
    //ADD LOGIN VIEW ON TOP
    float topViewHeight = [[Utility sharedManager] getTopBarHeight];
    CGRect topRect = self.view.bounds;
    topRect.size.height = topViewHeight;
    headerView = [[UIView alloc] initWithFrame:topRect];
    headerView.backgroundColor = [Utility getUIColor:kUIColorBgHeader];
    [headerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    if (_isMyAccountScreen) {
    } else {
        [self.view addSubview:headerView];
    }
    
    //    float bottomViewHeight = [[Utility sharedManager] getBottomBarHeight];
    //    CGRect bottomRect = self.view.bounds;
    //    bottomRect.size.height = bottomViewHeight;
    //    bottomRect.origin.y = self.view.bounds.size.height - bottomRect.size.height;
    //    footerView = [[UIView alloc] initWithFrame:bottomRect];
    //    footerView.backgroundColor = [Utility getUIColor:kUIColorBgHeader];
    //    [footerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    //    [self.view addSubview:footerView];
    
    
    
    ViewControllerMain* vcMain = [ViewControllerMain getInstance];
    NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject: vcMain.vcTopBar.buttonLeftView];
    buttonDrawer = [NSKeyedUnarchiver unarchiveObjectWithData: archivedData];
    buttonDrawer.translatesAutoresizingMaskIntoConstraints = YES;
    [buttonDrawer addTarget:self action: @selector(revealToggleClicked) forControlEvents: UIControlEventTouchUpInside];
    [buttonDrawer setNeedsLayout];
    [buttonDrawer setHidden:false];
    [buttonDrawer setContentMode:UIViewContentModeCenter];
    [buttonDrawer setCenter:CGPointMake(buttonDrawer.frame.origin.x + buttonDrawer.frame.size.width / 2, topRect.size.height / 2  + [[Utility sharedManager] getStatusBarHeight]/2)];
    [headerView addSubview:buttonDrawer];
    
    if (_isMyAccountScreen) {
        headerView.frame = CGRectZero;
    } else {
    }
    CGRect tableViewRect = self.view.bounds;
    tableViewRect.origin.y = headerView.frame.origin.y + headerView.frame.size.height - 1;
    tableViewRect.size.height = _rowH;
    tableView = [[UITableView alloc] initWithFrame:tableViewRect style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.scrollEnabled = NO;
    [tableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self.view addSubview:tableView];
    [tableView reloadData];
    [tableView setNeedsLayout];
    [tableView setSeparatorInset:UIEdgeInsetsZero];
    
    //ADD TABLE VIEW
    CGRect treeViewRect = self.view.bounds;
    treeViewRect.origin.y = tableView.frame.origin.y + tableView.frame.size.height;
    RATreeView *treeView = [[RATreeView alloc] initWithFrame:treeViewRect];
    treeView.delegate = self;
    treeView.dataSource = self;
    treeView.separatorStyle = RATreeViewCellSeparatorStyleNone;
    self.treeView = treeView;
    treeView.collapsesChildRowsWhenRowCollapses = true;
    [self.view insertSubview:treeView atIndex:0];
    [self.treeView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self.treeView setScrollEnabled:true];
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController setTitle:NSLocalizedString(@"Things", nil)];
    [self updateNavigationItemButton];
    
    [self.treeView reloadData];
    if (![[[[DataManager sharedManager] tmDataDoctor] tmMulticastDelegate] hasDelegate:self]) {
        [[[[DataManager sharedManager] tmDataDoctor] tmMulticastDelegate] addDelegate:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loggedIn:) name:@"LoginCompleted" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetPasswordSentSuccess:) name:@"ResetPasswordSentSuccess" object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tryForFacebookWeb:) name:@"TRY_FOR_FACEBOOK_WEB" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tryForTwitterWeb:) name:@"TRY_FOR_TWITTER_WEB" object:nil];
    }
    
    
    NSError* configureError;
    [[GGLContext sharedInstance] configureWithError: &configureError];
    if (configureError != nil) {
        RLOG(@"Error configuring the Google context: %@", configureError);
        DataManager* dm = [DataManager sharedManager];
        dm.keyGoogleClientId = @"";
        dm.keyGoogleClientSecret = @"";
    } else {
        [GIDSignIn sharedInstance].delegate = self;
        [GIDSignIn sharedInstance].uiDelegate = self;
    }
    
#if ENABLE_TWITTER_LOGIN
    NSString* twitterConsumerKey = [[DataManager sharedManager] keyTwitterConsumerKey];
    NSString* twitterConsumerSecret = [[DataManager sharedManager] keyTwitterConsumerSecret];
    if (twitterConsumerKey && ![twitterConsumerKey isEqualToString:@""] && twitterConsumerSecret && ![twitterConsumerSecret isEqualToString:@""]) {
        [[Twitter sharedInstance] startWithConsumerKey:twitterConsumerKey consumerSecret:twitterConsumerSecret];
    }
#endif
}
- (void)revealToggleClicked {
    //    if ([[DataManager sharedManager] searchBarTextField]) {
    //         [[[DataManager sharedManager] searchBarTextField] resignFirstResponder];
    //    }
    ViewControllerMain* mainVC = [ViewControllerMain getInstance];
    [mainVC.revealController revealToggle:self];
}
- (void)viewDidAppear:(BOOL)animated {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super viewDidAppear:animated];
    if ([Utility isSellerOnlyApp]) {
        [self.view setBackgroundColor:[UIColor clearColor]];
    }
    
    [self getUserRewardPoints];
}
- (void)viewWillAppear:(BOOL)animated {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super viewWillAppear:animated];
    
    //rv//[SDWebImageManager.sharedManager.imageDownloader setValue:@"SDWebImage Demo" forHTTPHeaderField:@"AppName"];
    //    SDWebImageManager.sharedManager.imageDownloader.executionOrder = SDWebImageDownloaderFIFOExecutionOrder;
    
    int systemVersion = [[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."][0] intValue];
    if (systemVersion >= 7 && systemVersion < 8) {
        CGRect statusBarViewRect = [[UIApplication sharedApplication] statusBarFrame];
        float heightPadding = statusBarViewRect.size.height+self.navigationController.navigationBar.frame.size.height;
        self.treeView.contentInset = UIEdgeInsetsMake(heightPadding, 0.0, 0.0, 0.0);
        self.treeView.contentOffset = CGPointMake(0.0, -heightPadding);
    }
    [tableView setNeedsLayout];
    
    [self adjustViewsAfterOrientation:UIDeviceOrientationUnknown];
    
    float topViewHeight = [[Utility sharedManager] getTopBarHeight];
    CGRect topRect = self.view.bounds;
    topRect.size.height = topViewHeight;
    ViewControllerMain* vcMain = [ViewControllerMain getInstance];
    NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject: vcMain.vcTopBar.buttonLeftView];
    UIButton* tempButton = [NSKeyedUnarchiver unarchiveObjectWithData: archivedData];
    [buttonDrawer setCenter:CGPointMake(tempButton.frame.origin.x + tempButton.frame.size.width / 2, topRect.size.height / 2  + [[Utility sharedManager] getStatusBarHeight]/2)];
    
}
- (void)flushCache {
    [SDWebImageManager.sharedManager.imageCache clearMemory];
    
}
- (void)didReceiveMemoryWarning {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super didReceiveMemoryWarning];
}
//- (NSUInteger)supportedInterfaceOrientations
//{
//    //Forced Portrait mode
//    return UIInterfaceOrientationMaskPortrait;
//}
#pragma mark - Table View
#pragma mark - Actions
- (void)editButtonTapped:(id)sender{
    [self.treeView setEditing:!self.treeView.isEditing animated:YES];
    [self updateNavigationItemButton];
}
- (void)updateNavigationItemButton{
    UIBarButtonSystemItem systemItem = self.treeView.isEditing ? UIBarButtonSystemItemDone : UIBarButtonSystemItemEdit;
    self.editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:systemItem target:self action:@selector(editButtonTapped:)];
    self.navigationItem.rightBarButtonItem = self.editButton;
}
#pragma mark TreeView Delegate methods
- (CGFloat)treeView:(RATreeView *)treeView heightForRowForItem:(id)item{
    return 50;
    //    return [[LayoutManager sharedManager] leftViewProp]->rowHeight_PWRTH_MAX * [[MyDevice sharedManager] screenHeightInPortrait] / 100.0f;
}
- (BOOL)treeView:(RATreeView *)treeView canEditRowForItem:(id)item{
    return NO;
}
- (void)treeView:(RATreeView *)treeView willExpandRowForItem:(id)item{
    RATableViewCell *cell = (RATableViewCell *)[treeView cellForItem:item];
    RADataObject *data = item;
    if (data != nil) {
        [cell.btn_addition setUIImage:[UIImage imageNamed:data.imgCollapsePath] forState:UIControlStateNormal];
    }
}
- (void)treeView:(RATreeView *)treeView willCollapseRowForItem:(id)item{
    RATableViewCell *cell = (RATableViewCell *)[treeView cellForItem:item];
    RADataObject *data = item;
    if (data != nil) {
        [cell.btn_addition setUIImage:[UIImage imageNamed:data.imgExpandPath] forState:UIControlStateNormal];
    }
}
- (void)treeView:(RATreeView *)treeView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowForItem:(id)item{
    //    if (editingStyle != UITableViewCellEditingStyleDelete) {
    //        return;
    //    }
    //
    //    RADataObject *parent = [self.treeView parentForItem:item];
    //    NSInteger index = 0;
    //
    //    if (parent == nil) {
    //        index = [self.dataObjects indexOfObject:item];
    //        NSMutableArray *children = [self.dataObjects mutableCopy];
    //        [children removeObject:item];
    //        self.dataObjects = [children copy];
    //
    //    } else {
    //        index = [parent.children indexOfObject:item];
    //        [parent removeChild:item];
    //    }
    //
    //    [self.treeView deleteItemsAtIndexes:[NSIndexSet indexSetWithIndex:index] inParent:parent withAnimation:RATreeViewRowAnimationRight];
    //    if (parent) {
    //        [self.treeView reloadRowsForItems:@[parent] withRowAnimation:RATreeViewRowAnimationNone];
    //    }
}
#pragma mark TreeView Data Source
- (UITableViewCell *)treeView:(RATreeView *)treeView cellForItem:(id)item{
    RADataObject *dataObject = item;
    
    RATableViewCell *cell = [treeView dequeueReusableCellWithIdentifier:@"RATableViewCell"];
    if (! cell) {
        NSArray *parts = [[NSBundle mainBundle] loadNibNamed:@"RATableViewCell" owner:nil options:nil];
        cell = [parts objectAtIndex:0];
    }
    
    //    cell.translatesAutoresizingMaskIntoConstraints = YES;
    cell.label_name.translatesAutoresizingMaskIntoConstraints = YES;
    cell.label_points.translatesAutoresizingMaskIntoConstraints = YES;
    cell.img_icon.translatesAutoresizingMaskIntoConstraints = YES;
    cell.img_children.translatesAutoresizingMaskIntoConstraints = YES;
    cell.btn_addition.translatesAutoresizingMaskIntoConstraints = YES;
    
    if (dataObject == [self.dataObjects lastObject]) {
        //        [cell.img_children setHidden:true];
    }
    
    NSInteger level = [self.treeView levelForCellForItem:item];
    NSInteger numberOfChildren = [dataObject.children count];
    
    if (numberOfChildren > 0) {
        [cell setAdditionButtonHidden:NO];
    }else{
        [cell setAdditionButtonHidden:YES];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    if (level == 0) {
        [cell.label_name setTextColor:[Utility getUIColor:kUIColorFontListViewLevel0]];
    } else if (level == 1) {
        [cell.label_name setTextColor:[Utility getUIColor:kUIColorFontListViewLevel1]];
    } else if (level >= 2) {
        [cell.label_name setTextColor:[Utility getUIColor:kUIColorFontListViewLevel2Plus]];
    }
    
    [cell.label_name setText:[Utility getNormalStringFromAttributed:dataObject.title]];
    if ([[MyDevice sharedManager] isIpad]) {
        [cell.label_name setUIFont:kUIFontType18 isBold:false];
    } else {
        [cell.label_name setUIFont:kUIFontType19 isBold:false];
    }
    
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        [cell.label_name setTextAlignment:NSTextAlignmentRight];
    } else {
        [cell.label_name setTextAlignment:NSTextAlignmentLeft];
    }
    
    [cell.label_points setTextColor:[Utility getUIColor:kUIColorFontListViewLevel0]];
    AppUser* appUser = [AppUser sharedManager];
    [cell.label_points setText:[NSString stringWithFormat:@"%d %@", appUser.rewardPoints, Localize(@"points")]];
    if ([[MyDevice sharedManager] isIpad]) {
        [cell.label_points setUIFont:kUIFontType18 isBold:false];
    } else {
        [cell.label_points setUIFont:kUIFontType19 isBold:false];
    }
    [cell.label_points setTextAlignment:NSTextAlignmentCenter];
    
    CGRect img_iconFrame = cell.img_icon.frame;
    img_iconFrame.origin.x = _gap + (_gap*2) * level;
    cell.img_icon.frame = img_iconFrame;
    if (dataObject.isIconUrl) {
        [Utility setImage:cell.img_icon url:dataObject.imgPath resizeType:0 isLocal:false highPriority:true];
        [cell.img_icon setContentMode:UIViewContentModeScaleAspectFit];
    } else {
        [cell.img_icon setUIImage:[UIImage imageNamed:dataObject.imgPath]];
    }
    
    CGRect label_nameFrame = cell.label_name.frame;
    label_nameFrame.origin.x = img_iconFrame.origin.x + img_iconFrame.size.width + _gap;
    cell.label_name.frame = label_nameFrame;
    
    CGRect label_pointsFrame = cell.label_points.frame;
    label_pointsFrame.origin.x = img_iconFrame.origin.x + img_iconFrame.size.width + _gap;
    cell.label_points.frame = label_pointsFrame;
    
    CGRect img_childrenFrame = cell.img_children.frame;
    img_childrenFrame.origin.x = _gap + cell.img_icon.frame.size.width;
    cell.img_children.frame = img_childrenFrame;
    
    //    RLOG(@"POSX=%.f", cell.frame.size.width - cell.btn_addition.frame.size.width - _gap);
    
    cell.btn_addition.center = CGPointMake(self.view.frame.size.width - cell.btn_addition.frame.size.width - _gap, cell.btn_addition.center.y);
    [cell.btn_addition setUIImage:[UIImage imageNamed:dataObject.imgExpandPath] forState:UIControlStateNormal];
    
    if([dataObject.title isEqualToString:@""]) {
        cell.img_children.hidden = true;
    }else{
        cell.img_children.hidden = false;
    }
    float maxLabelX = CGRectGetMaxX(cell.label_name.frame);
    float minButtonX = CGRectGetMinX(cell.btn_addition.frame);
    float diff = maxLabelX - minButtonX;
    label_nameFrame.size.width = label_nameFrame.size.width - diff;
    cell.label_name.frame = label_nameFrame;
    
    if (dataObject.objId == BUTTONS_ID_REWARDS) {
        float maxLabelX = CGRectGetMaxX(cell.label_points.frame);
        float minButtonX = CGRectGetMinX(cell.btn_addition.frame);
        float diff = maxLabelX - minButtonX;
        label_pointsFrame.size.width = label_pointsFrame.size.width - diff;
        float maxPosX = CGRectGetMaxX(label_pointsFrame);
        cell.label_points.frame = label_pointsFrame;
        [cell.label_points sizeToFitUI];
        float maxWidth = cell.label_points.frame.size.width;
        float newPosX = maxPosX - maxWidth;
        label_pointsFrame = cell.label_points.frame;
        label_pointsFrame.origin.x = newPosX;
        label_pointsFrame.size.width *= 1.5f;
        label_pointsFrame.size.height += 10;
        cell.label_points.frame = label_pointsFrame;
        [cell.label_points.layer setBackgroundColor:[Utility getUIColor:kUIColorBuyButtonNormalBg].CGColor];
        [cell.label_points setTextColor:[Utility getUIColor:kUIColorBuyButtonFont]];
        cell.label_points.hidden = false;
        cell.label_points.layer.cornerRadius = cell.label_points.frame.size.height/2.0f;
    }else {
        cell.label_points.hidden = true;
    }
    RLOG(@"dataObject.name = %@, %.f", dataObject.title, cell.img_icon.frame.origin.x);
    [cell setNeedsLayout];
    return cell;
}
- (NSInteger)treeView:(RATreeView *)treeView numberOfChildrenOfItem:(id)item{
    RADataObject *data = item;
    if (item == nil) {
        return [self.dataObjects count];
    }
    return [data.children count];
}
- (id)treeView:(RATreeView *)treeView child:(NSInteger)index ofItem:(id)item{
    RADataObject *data = item;
    if (item == nil) {
        return [self.dataObjects objectAtIndex:index];
    }
    return data.children[index];
}
- (void)treeView:(RATreeView *)treeView didSelectRowForItem:(id)item {
    RADataObject *data = item;
    mainVC = [ViewControllerMain getInstance];

    if (data) {
        if (data.cInfo) {
            //object is category
            if ([data.children count] == 0) {
                DataPass* dp = nil;
                //                if (data.cInfo._parent) {
                //                    dp = [[DataPass alloc] init];
                //                    dp.itemId = data.cInfo._parent._id;
                //                    dp.isCategory = true;
                //                    dp.isProduct = false;
                //                    dp.hasChildCategory = true;
                //                    dp.childCount = (int)[[data.cInfo._parent getSubCategories] count];
                //                    dp.cInfo = data.cInfo._parent;
                //                }
                [self clickOnCategory:data.cInfo currentItemData:dp];
                if (_isMyAccountScreen) {
                    
                } else {
                    [mainVC.revealController revealToggle:self];
                }
            }
        }
        else if (![data.urlString isEqualToString:@""]) {
            mainVC.containerTop.hidden = YES;
            mainVC.containerCenter.hidden = YES;
            mainVC.containerCenterWithTop.hidden = NO;
            mainVC.vcBottomBar.buttonHome.selected = YES;
            mainVC.vcBottomBar.buttonCart.selected = NO;
            mainVC.vcBottomBar.buttonWishlist.selected = NO;
            mainVC.vcBottomBar.buttonSearch.selected = NO;
            mainVC.revealController.panGestureEnable = false;
            [mainVC.vcBottomBar buttonClicked:nil];
            if (_isMyAccountScreen) {
                ViewControllerWebview* vcWebview = (ViewControllerWebview*)[[Utility sharedManager] pushScreenWithNewAnimation:mainVC.vcCenterTop type:PUSH_SCREEN_TYPE_WEBVIEW];
                [vcWebview loadAllViews:data.urlString];
            } else {
                ViewControllerWebview* vcWebview = (ViewControllerWebview*)[[Utility sharedManager] pushScreenWithoutAnimation:mainVC.vcCenterTop type:PUSH_SCREEN_TYPE_WEBVIEW];
                [vcWebview loadAllViews:data.urlString];
                [mainVC.revealController revealToggle:self];
            }
        }
        else {
            //other object here switch case is applied
            
            switch (data.objId) {
                    
                    
                case BUTTONS_ID_LANGUAGES:
                {
                    //todo
                    [self showLanguageSelectionScreen];
                }break;
                    
#if ENABLE_HOTLINE
                case BUTTONS_ID_LIVE_CHAT:
                {
                    Addons* addons = [Addons sharedManager];
                    if (addons.hotline && addons.hotline.isEnabled) {
                        //                        AppDelegate* appD = (AppDelegate*)[UIApplication sharedApplication].delegate;
                        //                        [appD configureHotlineSDK:addons.hotline.app_id hotlineAppKey:addons.hotline.app_key];
                        [[Hotline sharedInstance] showConversations:self];
                    }
                }break;
#elif ENABLE_FRESHCHAT
                case BUTTONS_ID_LIVE_CHAT:
                {
                    Addons* addons = [Addons sharedManager];
                    if (addons.hotline && addons.hotline.isEnabled) {
                        //                        AppDelegate* appD = (AppDelegate*)[UIApplication sharedApplication].delegate;
                        //                        [appD configureHotlineSDK:addons.hotline.app_id hotlineAppKey:addons.hotline.app_key];
                        [[Freshchat sharedInstance] showConversations:self];
                    }
                }break;
#endif
                case BUTTONS_ID_CONTACT_FORM:
                {
                    mainVC.containerTop.hidden = YES;
                    mainVC.containerCenter.hidden = YES;
                    mainVC.containerCenterWithTop.hidden = NO;
                    mainVC.vcBottomBar.buttonHome.selected = YES;
                    mainVC.vcBottomBar.buttonCart.selected = NO;
                    mainVC.vcBottomBar.buttonWishlist.selected = NO;
                    mainVC.vcBottomBar.buttonSearch.selected = NO;
                    mainVC.revealController.panGestureEnable = false;
                    [mainVC.vcBottomBar buttonClicked:nil];
                    ViewControllerContactForm* vcContactUsForm = (ViewControllerContactForm*)[[Utility sharedManager] pushScreenWithNewAnimation:mainVC.vcCenterTop type:PUSH_SCREEN_TYPE_CONTACT_US_FORM];
                    [mainVC.revealController revealToggle:self];
                }break;
                case BUTTONS_ID_RESERVATION_FORM:
                {
                    mainVC.containerTop.hidden = YES;
                    mainVC.containerCenter.hidden = YES;
                    mainVC.containerCenterWithTop.hidden = NO;
                    mainVC.vcBottomBar.buttonHome.selected = YES;
                    mainVC.vcBottomBar.buttonCart.selected = NO;
                    mainVC.vcBottomBar.buttonWishlist.selected = NO;
                    mainVC.vcBottomBar.buttonSearch.selected = NO;
                    mainVC.revealController.panGestureEnable = false;
                    [mainVC.vcBottomBar buttonClicked:nil];
                    ViewControllerReservationForm* vcReservationForm = (ViewControllerReservationForm*)[[Utility sharedManager] pushScreenWithNewAnimation:mainVC.vcCenterTop type:PUSH_SCREEN_TYPE_RESERVATION_FORM];
                    [mainVC.revealController revealToggle:self];
                }break;
                case BUTTONS_ID_CHANGE_STORE:
                {
                    if ([Utility isMultiStoreApp]) {
                        [ViewControllerMain resetInstance];
                        //                        [[Utility sharedManager] popScreenWithoutAnimation:[ViewControllerHome getInstance]];
                        [Utility resetStoryBoardObject];
                        [AppUser clearFullAppData];
                        UIStoryboard *sb = [Utility getStoryBoardObject];
                        [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"APPDATA_PLATFORM"];
                        ViewControllerPlatformSelection *rootViewController = [sb instantiateViewControllerWithIdentifier:VC_SPLASH_PLATFORM];
                        rootViewController.markerInfo = nil;
                        [[UIApplication sharedApplication].keyWindow setRootViewController:rootViewController];
                        return;
                    }
                } break;
                case BUTTONS_ID_SCAN_BARCODE:
                {
                    
                    mainVC.containerTop.hidden = YES;
                    mainVC.containerCenter.hidden = YES;
                    mainVC.containerCenterWithTop.hidden = NO;
                    mainVC.vcBottomBar.buttonHome.selected = YES;
                    mainVC.vcBottomBar.buttonCart.selected = NO;
                    mainVC.vcBottomBar.buttonWishlist.selected = NO;
                    mainVC.vcBottomBar.buttonSearch.selected = NO;
                    mainVC.revealController.panGestureEnable = false;
                    [mainVC.vcBottomBar buttonClicked:nil];
                    BarcodeScannerViewController* vcBarcodeScanner = (BarcodeScannerViewController*)[[Utility sharedManager] pushScreenWithoutAnimation:mainVC.vcCenterTop type:PUSH_SCREEN_TYPE_BARCODE_SCAN];
                    [vcBarcodeScanner setDelegate:self];
                    [mainVC.revealController revealToggle:self];
                    return;
                } break;
                case BUTTONS_ID_LOCATE_STORE:
                {
                    
                    mainVC.containerTop.hidden = YES;
                    mainVC.containerCenter.hidden = YES;
                    mainVC.containerCenterWithTop.hidden = NO;
                    mainVC.vcBottomBar.buttonHome.selected = YES;
                    mainVC.vcBottomBar.buttonCart.selected = NO;
                    mainVC.vcBottomBar.buttonWishlist.selected = NO;
                    mainVC.vcBottomBar.buttonSearch.selected = NO;
                    mainVC.revealController.panGestureEnable = false;
                    [mainVC.vcBottomBar buttonClicked:nil];
                    
                    [mainVC hideBottomBar];
                    LocateStoreViewController* vcLocateStore = (LocateStoreViewController*)[[Utility sharedManager] pushScreenWithoutAnimation:mainVC.vcCenterTop type:PUSH_SCREEN_TYPE_LOCATE_STORE];
                    [vcLocateStore setDelegate:self];
                    [mainVC.revealController revealToggle:self];
                    return;
                } break;
                case BUTTONS_ID_SELLER_ZONE:
                {
                    AppUser* appUser = [AppUser sharedManager];
                    if (appUser._id != -1) {
                        if([SellerInfo getCurrentSeller] == nil) {
                            [[[DataManager sharedManager] tmDataDoctor] getSellerInformation:appUser._id success:^(id data) {
                                if (data && [data isKindOfClass:[SellerInfo class]]) {
                                    [SellerInfo setCurrentSeller:data];
                                    // call on click method
                                    [self onSellerZoneClick];
                                }
                            } failure:^(NSString *error) {
                                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:Localize(@"i_error")  message:@"Fetching seller data failed. Please retry." delegate:self cancelButtonTitle:Localize(@"cancel") otherButtonTitles:Localize(@"retry"), nil];
                                [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                    if (buttonIndex == 1) {
                                        // [self loadCurrentSellerData];
                                    }
                                }];
                            }];
                        } else {
                            // call on click method here
                            [self onSellerZoneClick];
                            
                        }
                    }
                } break;
                case BUTTONS_ID_RESET_PASSWORD:
                {
                    [self createResetPasswordView];
                }break;
                case BUTTONS_ID_HOME:
                    if (_isMyAccountScreen) {
                    } else {
                        [mainVC.revealController revealToggle:self];
                    }
                    [mainVC btnClickedHome:self];
                    break;
                case BUTTONS_ID_WISHLIST:
                    [mainVC btnClickedWishlist:self];
                    if (_isMyAccountScreen) {
                    } else {
                        [mainVC.revealController revealToggle:self];
                    }
                    break;
                case BUTTONS_ID_SEARCH:
                    [mainVC btnClickedSearch:self];
                    if (_isMyAccountScreen) {
                    } else {
                        [mainVC.revealController revealToggle:self];
                    }
                    break;
                    
                case BUTTONS_ID_CART:
                    [mainVC btnClickedCart:self];
                    if (_isMyAccountScreen) {
                    } else {
                        [mainVC.revealController revealToggle:self];
                    }
                    break;
                case BUTTONS_ID_CATEGORIES:
                    break;
                case BUTTONS_ID_CONTACT_US:
                {
                    DataManager* dm = [DataManager sharedManager];
                    if (dm.contactDetails == nil) {
                        if ([dm.tmDataDoctor pagelinkContactUs] == nil || [[dm.tmDataDoctor pagelinkContactUs] isEqualToString:@""]) {
                            return;
                        }
                    }
                    
                    mainVC.containerTop.hidden = YES;
                    mainVC.containerCenter.hidden = YES;
                    mainVC.containerCenterWithTop.hidden = NO;
                    mainVC.vcBottomBar.buttonHome.selected = YES;
                    mainVC.vcBottomBar.buttonCart.selected = NO;
                    mainVC.vcBottomBar.buttonWishlist.selected = NO;
                    mainVC.vcBottomBar.buttonSearch.selected = NO;
                    mainVC.revealController.panGestureEnable = false;
                    [mainVC.vcBottomBar buttonClicked:nil];
                    
                    
                    if (_isMyAccountScreen) {
                        if (dm.contactDetails == nil) {
                            ViewControllerWebview* vcWebview = (ViewControllerWebview*)[[Utility sharedManager] pushScreenWithNewAnimation:mainVC.vcCenterTop type:PUSH_SCREEN_TYPE_WEBVIEW];
                            [vcWebview loadAllViews:[dm.tmDataDoctor pagelinkContactUs]];
                        } else {
                            ViewControllerContactUs* vcContactUs = (ViewControllerContactUs*)[[Utility sharedManager] pushScreenWithNewAnimation:mainVC.vcCenterTop type:PUSH_SCREEN_TYPE_CONTACT_US];
                        }
                    } else {
                        if (dm.contactDetails == nil) {
                            ViewControllerWebview* vcWebview = (ViewControllerWebview*)[[Utility sharedManager] pushScreenWithoutAnimation:mainVC.vcCenterTop type:PUSH_SCREEN_TYPE_WEBVIEW];
                            [vcWebview loadAllViews:[dm.tmDataDoctor pagelinkContactUs]];
                        } else {
                            ViewControllerContactUs* vcContactUs = (ViewControllerContactUs*)[[Utility sharedManager] pushScreenWithoutAnimation:mainVC.vcCenterTop type:PUSH_SCREEN_TYPE_CONTACT_US];
                        }
                    }
                    
                    if (_isMyAccountScreen) {
                    } else {
                        [mainVC.revealController revealToggle:self];
                    }
                }break;
                case BUTTONS_ID_TERMS_AND_CONDITIONS:
                {
                    mainVC.containerTop.hidden = YES;
                    mainVC.containerCenter.hidden = YES;
                    mainVC.containerCenterWithTop.hidden = NO;
                    mainVC.vcBottomBar.buttonHome.selected = YES;
                    mainVC.vcBottomBar.buttonCart.selected = NO;
                    mainVC.vcBottomBar.buttonWishlist.selected = NO;
                    mainVC.vcBottomBar.buttonSearch.selected = NO;
                    mainVC.revealController.panGestureEnable = false;
                    [mainVC.vcBottomBar buttonClicked:nil];
                    
                    if (_isMyAccountScreen) {
                        ViewControllerWebview* vcWebview = (ViewControllerWebview*)[[Utility sharedManager] pushScreenWithNewAnimation:mainVC.vcCenterTop type:PUSH_SCREEN_TYPE_WEBVIEW];
                        [vcWebview loadAllViews:[[[DataManager sharedManager] tmDataDoctor] pagelinkAboutUs]];
                    } else {
                        ViewControllerWebview* vcWebview = (ViewControllerWebview*)[[Utility sharedManager] pushScreenWithoutAnimation:mainVC.vcCenterTop type:PUSH_SCREEN_TYPE_WEBVIEW];
                        [vcWebview loadAllViews:[[[DataManager sharedManager] tmDataDoctor] pagelinkAboutUs]];
                        [mainVC.revealController revealToggle:self];
                    }
                }break;
                case BUTTONS_ID_ORDERS:
                {
                    mainVC.containerTop.hidden = YES;
                    mainVC.containerCenter.hidden = YES;
                    mainVC.containerCenterWithTop.hidden = NO;
                    mainVC.vcBottomBar.buttonHome.selected = YES;
                    mainVC.vcBottomBar.buttonCart.selected = NO;
                    mainVC.vcBottomBar.buttonWishlist.selected = NO;
                    mainVC.vcBottomBar.buttonSearch.selected = NO;
                    mainVC.revealController.panGestureEnable = false;
                    [mainVC.vcBottomBar buttonClicked:nil];
                    
                    if (_isMyAccountScreen) {
                        ViewControllerOrder* vcOrder = (ViewControllerOrder*)[[Utility sharedManager] pushScreenWithNewAnimation:mainVC.vcCenterTop type:PUSH_SCREEN_TYPE_ORDER];
                        RLOG(@"vcOrder = %@", vcOrder);
                    } else {
                        ViewControllerOrder* vcOrder = (ViewControllerOrder*)[[Utility sharedManager] pushScreenWithoutAnimation:mainVC.vcCenterTop type:PUSH_SCREEN_TYPE_ORDER];
                        RLOG(@"vcOrder = %@", vcOrder);
                        [mainVC.revealController revealToggle:self];
                    }
                }break;
                case BUTTONS_ID_MYCOUPON:
                {
                    mainVC.containerTop.hidden = YES;
                    mainVC.containerCenter.hidden = YES;
                    mainVC.containerCenterWithTop.hidden = NO;
                    mainVC.vcBottomBar.buttonHome.selected = YES;
                    mainVC.vcBottomBar.buttonCart.selected = NO;
                    mainVC.vcBottomBar.buttonWishlist.selected = NO;
                    mainVC.vcBottomBar.buttonSearch.selected = NO;
                    mainVC.revealController.panGestureEnable = false;
                    [mainVC.vcBottomBar buttonClicked:nil];
                    if (_isMyAccountScreen) {
                        ViewControllerMyCoupon* vcMyCoupon= (ViewControllerMyCoupon*)[[Utility sharedManager] pushScreenWithNewAnimation:mainVC.vcCenterTop type:PUSH_SCREEN_TYPE_MYCOPON];
                        RLOG(@"vcMyCoupon = %@", vcMyCoupon);
                    } else {
                        ViewControllerMyCoupon* vcMyCoupon = (ViewControllerMyCoupon*)[[Utility sharedManager] pushScreenWithoutAnimation:mainVC.vcCenterTop type:PUSH_SCREEN_TYPE_MYCOPON];
                        RLOG(@"vcMyCoupon = %@", vcMyCoupon);
                        [mainVC.revealController revealToggle:self];
                    }
                }break;
                case BUTTONS_ID_NOTIFICATION:
                {
                    mainVC.containerTop.hidden = YES;
                    mainVC.containerCenter.hidden = YES;
                    mainVC.containerCenterWithTop.hidden = NO;
                    mainVC.vcBottomBar.buttonHome.selected = YES;
                    mainVC.vcBottomBar.buttonCart.selected = NO;
                    mainVC.vcBottomBar.buttonWishlist.selected = NO;
                    mainVC.vcBottomBar.buttonSearch.selected = NO;
                    mainVC.revealController.panGestureEnable = false;
                    [mainVC.vcBottomBar buttonClicked:nil];
                    if (_isMyAccountScreen) {
                        ViewControllerNotification* vcMyNotification= (ViewControllerNotification*)[[Utility sharedManager] pushScreenWithNewAnimation:mainVC.vcCenterTop type:PUSH_SCREEN_TYPE_NOTIFICATION];
                        RLOG(@"vcMyCoupon = %@", vcMyNotification);
                    } else {
                        ViewControllerNotification* vcMyNotification = (ViewControllerNotification*)[[Utility sharedManager] pushScreenWithoutAnimation:mainVC.vcCenterTop type:PUSH_SCREEN_TYPE_NOTIFICATION];
                        RLOG(@"vcMyCoupon = %@", vcMyNotification);
                        [mainVC.revealController revealToggle:self];
                    }
                }break;
                case BUTTONS_ID_SPONSOR_FRIEND:
                {
                    [self createSponserFriendPopup];
                    
                    //                    mainVC.containerTop.hidden = YES;
                    //                    mainVC.containerCenter.hidden = YES;
                    //                    mainVC.containerCenterWithTop.hidden = NO;
                    //                    mainVC.vcBottomBar.buttonHome.selected = YES;
                    //                    mainVC.vcBottomBar.buttonCart.selected = NO;
                    //                    mainVC.vcBottomBar.buttonWishlist.selected = NO;
                    //                    mainVC.vcBottomBar.buttonSearch.selected = NO;
                    //                    mainVC.revealController.panGestureEnable = false;
                    //                    [mainVC.vcBottomBar buttonClicked:nil];
                    //
                    //                    if (_isMyAccountScreen) {
                    //                        ViewControllerSponsorFriend* vcSponsorFriend = (ViewControllerSponsorFriend*)[[Utility sharedManager] pushScreenWithNewAnimation:mainVC.vcCenterTop type:PUSH_SCREEN_TYPE_SPONSOR_FRIEND];
                    //                        RLOG(@"vcSponsorFriend = %@", vcSponsorFriend);
                    //                    } else {
                    //                        ViewControllerSponsorFriend* vcSponsorFriend = (ViewControllerSponsorFriend*)[[Utility sharedManager] pushScreenWithoutAnimation:mainVC.vcCenterTop type:PUSH_SCREEN_TYPE_SPONSOR_FRIEND];
                    //                        RLOG(@"vcSponsorFriend = %@", vcSponsorFriend);
                    //                        [mainVC.revealController revealToggle:self];
                    //                    }
                }break;
                case BUTTONS_ID_REWARDS:
                {
                    //                    mainVC.containerTop.hidden = YES;
                    //                    mainVC.containerCenter.hidden = YES;
                    //                    mainVC.containerCenterWithTop.hidden = NO;
                    //                    mainVC.vcBottomBar.buttonHome.selected = YES;
                    //                    mainVC.vcBottomBar.buttonCart.selected = NO;
                    //                    mainVC.vcBottomBar.buttonWishlist.selected = NO;
                    //                    mainVC.vcBottomBar.buttonSearch.selected = NO;
                    //                    mainVC.revealController.panGestureEnable = false;
                    //                    [mainVC.vcBottomBar buttonClicked:nil];
                    //
                    //if (_isMyAccountScreen) {
                    //                    ViewControllerOrder* vcOrder = (ViewControllerOrder*)[[Utility sharedManager] pushScreenWithNewAnimation:mainVC.vcCenterTop type:PUSH_SCREEN_TYPE_ORDER];
                    //                    RLOG(@"vcOrder = %@", vcOrder);
                    //} else {
                    //                    ViewControllerOrder* vcOrder = (ViewControllerOrder*)[[Utility sharedManager] pushScreenWithoutAnimation:mainVC.vcCenterTop type:PUSH_SCREEN_TYPE_ORDER];
                    //                    RLOG(@"vcOrder = %@", vcOrder);
                    //                    [mainVC.revealController revealToggle:self];
                    //}
                }break;
                case BUTTONS_ID_ADDRESS:
                {
                    
                    mainVC.containerTop.hidden = YES;
                    mainVC.containerCenter.hidden = YES;
                    mainVC.containerCenterWithTop.hidden = NO;
                    mainVC.vcBottomBar.buttonHome.selected = YES;
                    mainVC.vcBottomBar.buttonCart.selected = NO;
                    mainVC.vcBottomBar.buttonWishlist.selected = NO;
                    mainVC.vcBottomBar.buttonSearch.selected = NO;
                    mainVC.revealController.panGestureEnable = false;
                    [mainVC.vcBottomBar buttonClicked:nil];
                    if (_isMyAccountScreen) {
                        ViewControllerAddress* vcAddress = (ViewControllerAddress*)[[Utility sharedManager] pushScreenWithNewAnimation:mainVC.vcCenterTop type:PUSH_SCREEN_TYPE_ADDRESS];
                        RLOG(@"vcAddress = %@", vcAddress);
                    } else {
                        ViewControllerAddress* vcAddress = (ViewControllerAddress*)[[Utility sharedManager] pushScreenWithoutAnimation:mainVC.vcCenterTop type:PUSH_SCREEN_TYPE_ADDRESS];
                        RLOG(@"vcAddress = %@", vcAddress);
                        [mainVC.revealController revealToggle:self];
                    }
                }break;
                case BUTTONS_ID_SETTINGS:
                {
                    mainVC.containerTop.hidden = YES;
                    mainVC.containerCenter.hidden = YES;
                    mainVC.containerCenterWithTop.hidden = NO;
                    mainVC.vcBottomBar.buttonHome.selected = YES;
                    mainVC.vcBottomBar.buttonCart.selected = NO;
                    mainVC.vcBottomBar.buttonWishlist.selected = NO;
                    mainVC.vcBottomBar.buttonSearch.selected = NO;
                    mainVC.revealController.panGestureEnable = false;
                    [mainVC.vcBottomBar buttonClicked:nil];
                    
                    //                    if (_isMyAccountScreen) {
                    ViewControllerSetting * vcSetting = (ViewControllerSetting*)[[Utility sharedManager] pushScreenWithNewAnimation:mainVC.vcCenterTop type:PUSH_SCREEN_TYPE_SETTING];
                    RLOG(@"vcSetting = %@", vcSetting);
                    [mainVC.revealController revealToggle:self];
                    
                    
                    //                    } else {
                    //                        ViewControllerNotification* vcMyNotification = (ViewControllerNotification*)[[Utility sharedManager] pushScreenWithoutAnimation:mainVC.vcCenterTop type:PUSH_SCREEN_TYPE_NOTIFICATION];
                    //                        RLOG(@"vcMyCoupon = %@", vcMyNotification);
                    //                        [mainVC.revealController revealToggle:self];
                    //                    }
                } break;
                    //                case BUTTONS_ID_HELP_AND_SUPPORT:
                    //                {
                    //                } break;
                case BUTTONS_ID_WEBVIEW:
                {
                    mainVC.containerTop.hidden = YES;
                    mainVC.containerCenter.hidden = YES;
                    mainVC.containerCenterWithTop.hidden = NO;
                    mainVC.vcBottomBar.buttonHome.selected = YES;
                    mainVC.vcBottomBar.buttonCart.selected = NO;
                    mainVC.vcBottomBar.buttonWishlist.selected = NO;
                    mainVC.vcBottomBar.buttonSearch.selected = NO;
                    mainVC.revealController.panGestureEnable = false;
                    [mainVC.vcBottomBar buttonClicked:nil];
                    if (_isMyAccountScreen) {
                        ViewControllerWebview* vcWebview = (ViewControllerWebview*)[[Utility sharedManager] pushScreenWithNewAnimation:mainVC.vcCenterTop type:PUSH_SCREEN_TYPE_WEBVIEW];
                        [vcWebview loadAllViews:data.urlString];
                    } else {
                        ViewControllerWebview* vcWebview = (ViewControllerWebview*)[[Utility sharedManager] pushScreenWithoutAnimation:mainVC.vcCenterTop type:PUSH_SCREEN_TYPE_WEBVIEW];
                        [vcWebview loadAllViews:data.urlString];
                        [mainVC.revealController revealToggle:self];
                    }
                    
                } break;
                case BUTTONS_ID_LOGOUT:
                {
#if ENABLE_FIREBASE_TAG_MANAGER
                    [[AnalyticsHelper sharedInstance] registerLogoutEvent];
#endif
                    switch ([[AppUser sharedManager] _userLoggedInVia]) {
                        case SA_PROVIDERS_FACEBOOK:
                        {
#if (ENABLE_FB_LOGIN)
                            FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
                            [loginManager logOut];
#endif
                            [self loggedOut];
                        } break;
                        case SA_PROVIDERS_FACEBOOK_WEB:{
                            [self loggedOut];
                        }break;
                        case SA_PROVIDERS_GOOGLE_WEB:
                        {
                            [[GIDSignIn sharedInstance] signOut];
                            [self loggedOut];
                        }break;
                        case SA_PROVIDERS_TWITTER:{
#if (ENABLE_TWITTER_LOGIN)
                            TWTRSessionStore *store = [[Twitter sharedInstance] sessionStore];
                            NSString *userID = store.session.userID;
                            [store logOutUserID:userID];
                            NSURL *url = [NSURL URLWithString:@"https://api.twitter.com"];
                            NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url];
                            for (NSHTTPCookie *cookie in cookies)
                            {
                                [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
                            }
#endif

                            [self loggedOut];
                        }break;
                        case SA_PROVIDERS_TWITTER_WEB:{
                            [self loggedOut];
                        }break;
                        case SA_PROVIDERS_STORE:{
                            [self loggedOut];
                        }break;
                        default:
                            break;
                    }
                    
                }break;
                case BUTTONS_ID_RATE_APP:
                {
                    NSString* appId = MY_APPID;
                    NSString * iOS7AppStoreURLFormat = @"itms-apps://itunes.apple.com/app/id%@";
                    NSString * iOSAppStoreURLFormat = @"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@";
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:([[UIDevice currentDevice].systemVersion floatValue] >= 7.0f)? iOS7AppStoreURLFormat: iOSAppStoreURLFormat, appId]]];
                    if (_isMyAccountScreen) {
                    } else {
                        [mainVC.revealController revealToggle:self];
                    }
                    
                }break;
                    
                case BUTTONS_ID_LOGIN:{
                    if (_isUserLoggedIn == false) {
                        [self showLoginPopup:true];
                    }
                }break;
                default:
                    break;
            }
            
        }
        
    }
    
}
- (void)treeView:(RATreeView *)treeView didDeselectRowForItem:(id)item {
}
- (void)logoutClicked {
#if ENABLE_FIREBASE_TAG_MANAGER
    [[AnalyticsHelper sharedInstance] registerLogoutEvent];
#endif
    switch ([[AppUser sharedManager] _userLoggedInVia]) {
        case SA_PROVIDERS_FACEBOOK:
        {
#if (ENABLE_FB_LOGIN)
            FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
            [loginManager logOut];
#endif
            [self loggedOut];
        } break;
        case SA_PROVIDERS_FACEBOOK_WEB:{
            [self loggedOut];
        }break;
        case SA_PROVIDERS_GOOGLE_WEB:
        {
            [[GIDSignIn sharedInstance] signOut];
            [self loggedOut];
        }break;
        case SA_PROVIDERS_TWITTER:{
#if (ENABLE_TWITTER_LOGIN)
            TWTRSessionStore *store = [[Twitter sharedInstance] sessionStore];
            NSString *userID = store.session.userID;
            [store logOutUserID:userID];
            NSURL *url = [NSURL URLWithString:@"https://api.twitter.com"];
            NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url];
            for (NSHTTPCookie *cookie in cookies)
            {
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
            }
#endif
            
            [self loggedOut];
        }break;
        case SA_PROVIDERS_TWITTER_WEB:{
            [self loggedOut];
        }break;
        case SA_PROVIDERS_STORE:{
            [self loggedOut];
        }break;
        default:
            [self loggedOut];
            break;
    }
}
#pragma mark - Helpers
- (BOOL)initRADataObject:(RADataObject*)item {
    return [self initRADataObject:item addForcefully:true];
}
- (BOOL)initRADataObject:(RADataObject*)item addForcefully:(BOOL)addForcefully{
    int i = item.objId;
    
    NSString* itemName = @"default";
    NSString* itemImagePath = @"default";
    NSString* itemImageExpandPath = @"img_arrow_down.png";
    NSString* itemImageCollapsePath = @"img_arrow_up.png";
    BOOL isEnable = true;
    //        item = [[RADataObject alloc] init];
    //        item.objId = i;
    if (isEnable) {
        if(![itemName compare:@"default"]){
            switch (i) {
                case BUTTONS_ID_HOME:
                    itemName = Localize(@"title_shop");
                    itemImagePath = @"btn_home.png";
                    break;
                case BUTTONS_ID_WISHLIST:
                    itemName = Localize(@"menu_title_wishlist");
                    itemImagePath = @"btn_wishlist.png";
                    break;
                case BUTTONS_ID_SEARCH:
                    itemName = Localize(@"title_search");
                    itemImagePath = @"btn_search.png";
                    //                        if ([[MyDevice sharedManager] isIpad]) {
                    //                            isEnable = NO;
                    //                        }
                    break;
                case BUTTONS_ID_CART:{
                    itemName = Localize(@"title_mycart");
                    itemImagePath = @"btn_cart.png";
                    Addons* addons = [Addons sharedManager];
                    if (addons.enable_cart == false){
                        isEnable = NO;
                    }
                }break;
                case BUTTONS_ID_CATEGORIES:
                    itemName = Localize(@"title_categories");
                    itemImagePath = @"btn_category.png";
                    categoryObject = item;
                    break;
                case BUTTONS_ID_ORDERS:
                    
                    if(_isUserLoggedIn || [[GuestConfig sharedInstance] guest_checkout]) {
                        //                        if (_isUserLoggedIn) {
                        itemName = Localize(@"my_orders");
                        itemImagePath = @"btn_myOrder.png";
                    } else {
                        isEnable = NO;
                    }
                    break;
                case BUTTONS_ID_MYCOUPON:
                    if (![[Addons sharedManager] hide_coupon_list]) {
                        itemName = Localize(@"my_coupons");
                        itemImagePath = @"btn_myOrder.png";
                    } else {
                        isEnable = NO;
                    }
                    break;
                case BUTTONS_ID_NOTIFICATION:
                    ///if (![[Addons sharedManager] hide_coupon_list]) {
                    itemName = Localize(@"title_notification");
                    itemImagePath = @"notification_icon.png";
                    // } else {
                    //     isEnable = NO;
                    // }
                    break;
#if ENABLE_SPONSOR_FRIEND
                case BUTTONS_ID_SPONSOR_FRIEND:
                {
                    Addons* addons = [Addons sharedManager];
                    if(_isUserLoggedIn && addons.sponsorFriend && addons.sponsorFriend.isEnabled) {
                        itemName = Localize(@"sponsor_a_friend");
                        itemImagePath = @"btn_myOrder.png";
                    } else {
                        isEnable = NO;
                    }
                }break;
#endif
                case BUTTONS_ID_REWARDS:
                    if(_isUserLoggedIn && [[Addons sharedManager] enable_custom_points]) {
                        itemName = Localize(@"my_rewards");
                        itemImagePath = @"btn_myOrder.png";
                    } else {
                        isEnable = NO;
                    }
                    break;
                case BUTTONS_ID_ADDRESS:
                    if (_isUserLoggedIn && [[Addons sharedManager] show_shipping_address] && [[Addons sharedManager] show_billing_address]) {
                        itemName = Localize(@"my_addresses");
                        itemImagePath = @"btn_myOrder.png";
                    } else {
                        isEnable = NO;
                    }
                    break;
                case BUTTONS_ID_CONTACT_US:
                    itemName = Localize(@"title_about");
                    itemImagePath = @"btn_mail.png";
                    break;
                case BUTTONS_ID_TERMS_AND_CONDITIONS:
                    itemName = Localize(@"i_t&c");
                    //                        itemImagePath = @"btn_chat.png";
                    break;
                case BUTTONS_ID_RATE_APP:
                    itemName = Localize(@"i_rate_app");
                    itemImagePath = @"btn_rating.png";
                    rateThisAppObject = item;
                    break;
                case BUTTONS_ID_SETTINGS:
                    itemName = Localize(@"title_settings");
                    itemImagePath = @"btn_setting.png";
                    //                        settingObject = item;
                    //                        if(![[TMLanguage sharedManager] isLocalizationVisible]) {
                    //                            isEnable = NO;
                    //                        }
                    break;
                case BUTTONS_ID_WEBVIEW:
                    //                        itemName = Localize(@"title_login");
                    itemImagePath = @"Link-60.png";
                    break;
                case BUTTONS_ID_GROUP:
                    //itemName = Localize(@"title_login");
                    //                        itemImagePath = @"Link-60.png";
                    break;
                case BUTTONS_ID_LOGIN:
                    if (_isUserLoggedIn) {
                        isEnable = NO;
                    }else{
                        itemName = Localize(@"title_login");
                        itemImagePath = @"btn_logout.png";
                    }
                    break;
                case BUTTONS_ID_LOGOUT:
                    if (_isUserLoggedIn) {
                        itemName = Localize(@"title_logout");
                        itemImagePath = @"btn_logout.png";
                    }else{
                        isEnable = NO;
                    }
                    break;
#if ENABLE_HOTLINE
                case BUTTONS_ID_LIVE_CHAT:
                    if ([[Addons sharedManager] hotline] && [[[Addons sharedManager] hotline] isEnabled]) {
                        itemName = Localize(@"live_chat");
                        itemImagePath = @"btn_chat.png";
                    }else{
                        isEnable = NO;
                    }
                    break;
#elif ENABLE_FRESHCHAT
                case BUTTONS_ID_LIVE_CHAT:
                    if ([[Addons sharedManager] hotline] && [[[Addons sharedManager] hotline] isEnabled]) {
                        itemName = Localize(@"live_chat");
                        itemImagePath = @"btn_chat.png";
                    }else{
                        isEnable = NO;
                    }
                    break;
#endif
                case BUTTONS_ID_CONTACT_FORM:
                    itemName = Localize(@"title_contact_us");
                    itemImagePath = @"btn_contact_us.png";
                    break;
                case BUTTONS_ID_RESERVATION_FORM:
                    itemName = Localize(@"title_reservation");
                    itemImagePath = @"btn_reservation.png";
                    break;
                case BUTTONS_ID_CHANGE_STORE:
                    if ([Utility isMultiStoreApp]) {
                        itemName = Localize(@"change_store");
                        itemImagePath = @"btn_change_store.png";
                    }else{
                        isEnable = NO;
                    }
                    break;
#if ENABLE_BARCODE_SCANNER
                case BUTTONS_ID_SCAN_BARCODE:
                {
                    
                    itemName = Localize(@"title_barcode_scan");
                    itemImagePath = @"btn_barcode.png";
                    
                }break;
#endif
#if ENABLE_LOCATE_STORE
                case BUTTONS_ID_LOCATE_STORE:
                {
                    
                    itemName = Localize(@"locate_store");
                    itemImagePath = @"btn_locate_store.png";
                    
                }break;
#endif
#if ENABLE_RESET_PASSWORD
                case BUTTONS_ID_RESET_PASSWORD:
                {
                    if (_isMyAccountScreen && [[Addons sharedManager] show_reset_password]) {
                        itemName = Localize(@"title_reset_password");
                        itemImagePath = @"btn_reset_password.png";
                    } else {
                        isEnable = NO;
                    }
                }break;
#endif
#if ENABLE_SELLER_ZONE
                case BUTTONS_ID_SELLER_ZONE:
                {
                    if (_isUserLoggedIn && ([[AppUser sharedManager] ur_type] == UR_TYPE_SELLER || [[AppUser sharedManager] ur_type] == UR_TYPE_PENDING_VENDOR)) {
                        itemName = Localize(@"title_seller_zone");//TODO
                        itemImagePath = @"seller_zone1.png";//TODO
                    } else {
                        isEnable = NO;
                    }
                } break;
#endif
                default:
                    isEnable = NO;
                    break;
            }
        }
        if (isEnable) {
            item.title = itemName;
            item.imgPath = itemImagePath;
            item.imgCollapsePath = itemImageCollapsePath;
            item.imgExpandPath = itemImageExpandPath;
            if (addForcefully) {
                [self.dataObjects addObject:item];
            }
        }
    }
    return isEnable;
}
- (void)addItemInArray:(NSMutableArray*)array itemId:(int)itemId{
    DrawerItem* dItem = [[DrawerItem alloc] init];
    dItem.itemId = itemId;
    [array addObject:dItem];
}
- (void)loadData {
    _isUserLoggedIn = [[AppUser sharedManager] _isUserLoggedIn];
    
    if (_isUserLoggedIn) {
        switch ([[AppUser sharedManager] _userLoggedInVia]) {
            case SA_PROVIDERS_FACEBOOK:
            {
                
            } break;
                
            default:
                break;
        }
    }
    if (self.dataObjects) {
        [self.dataObjects removeAllObjects];
    }else {
        self.dataObjects = [[NSMutableArray alloc] init];
    }
    NSMutableArray* item = [[NSMutableArray alloc] init];
    
    //    RADataObject *item[BUTTONS_ID_TOTAL];
    //    for (int i = 0; i < BUTTONS_ID_TOTAL; i++) {
    //        item[i] = [[RADataObject alloc] init];
    //    }
    categoryObject = nil;
    settingObject = nil;
    //    helpAndSupportObject = nil;
    rateThisAppObject = nil;
    menuObjects = nil;
    Addons* addons = [Addons sharedManager];
    

    NSMutableArray* serverRootCategories = nil;
    NSMutableArray* serverRootCategoriesIcon = nil;
    if (_isMyAccountScreen) {
        if ((int)[addons.profile_items count] == 0) {
            [self addItemInArray:addons.profile_items itemId:BUTTONS_ID_ADDRESS];
            [self addItemInArray:addons.profile_items itemId:BUTTONS_ID_ORDERS];
            [self addItemInArray:addons.profile_items itemId:BUTTONS_ID_REWARDS];
            [self addItemInArray:addons.profile_items itemId:BUTTONS_ID_MYCOUPON];
            [self addItemInArray:addons.profile_items itemId:BUTTONS_ID_NOTIFICATION];
            [self addItemInArray:addons.profile_items itemId:BUTTONS_ID_RATE_APP];
            [self addItemInArray:addons.profile_items itemId:BUTTONS_ID_LIVE_CHAT];
            [self addItemInArray:addons.profile_items itemId:BUTTONS_ID_CONTACT_US];
            [self addItemInArray:addons.profile_items itemId:BUTTONS_ID_RESET_PASSWORD];
            [self addItemInArray:addons.profile_items itemId:BUTTONS_ID_LOGOUT];
        }
        else {
            //#if TEST_RESET_PASSWORD
            //            {
            //                DrawerItem* drawerItem = [[DrawerItem alloc] init];
            //                drawerItem.itemId = BUTTONS_ID_RESET_PASSWORD;
            //                drawerItem.itemName = Localize(@"title_reset_password");
            //                [addons.profile_items addObject:drawerItem];
            //            }
            //#endif
        }
        for (DrawerItem* drawerItem in addons.profile_items) {
            RADataObject* itemObj = [[RADataObject alloc] init];
            itemObj.objId = drawerItem.itemId;
            [item addObject:itemObj];
            [self initRADataObject:itemObj];
            if (![drawerItem.itemName isEqualToString:@""]) {
                itemObj.title = drawerItem.itemName;
            }
            if (![drawerItem.itemData isEqualToString:@""]) {
                itemObj.urlString = drawerItem.itemData;
            }
        }
        
    }
    else {
        if ((int)[addons.drawer_items count] == 0) {
            [self addItemInArray:addons.drawer_items itemId:BUTTONS_ID_HOME];
            [self addItemInArray:addons.drawer_items itemId:BUTTONS_ID_CATEGORIES];
            [self addItemInArray:addons.drawer_items itemId:BUTTONS_ID_MENU_ITEMS];
            [self addItemInArray:addons.drawer_items itemId:BUTTONS_ID_CART];
            [self addItemInArray:addons.drawer_items itemId:BUTTONS_ID_WISHLIST];
            [self addItemInArray:addons.drawer_items itemId:BUTTONS_ID_SEARCH];
            [self addItemInArray:addons.drawer_items itemId:BUTTONS_ID_ORDERS];
            [self addItemInArray:addons.drawer_items itemId:BUTTONS_ID_MYCOUPON];
            [self addItemInArray:addons.drawer_items itemId:BUTTONS_ID_NOTIFICATION];
            [self addItemInArray:addons.drawer_items itemId:BUTTONS_ID_SETTINGS];
            [self addItemInArray:addons.drawer_items itemId:BUTTONS_ID_CONTACT_US];
            [self addItemInArray:addons.drawer_items itemId:BUTTONS_ID_LIVE_CHAT];
            [self addItemInArray:addons.drawer_items itemId:BUTTONS_ID_RATE_APP];
            [self addItemInArray:addons.drawer_items itemId:BUTTONS_ID_LOGIN];
            [self addItemInArray:addons.drawer_items itemId:BUTTONS_ID_LOGOUT];
            [self addItemInArray:addons.drawer_items itemId:BUTTONS_ID_SPONSOR_FRIEND];
#if (ENABLE_SELLER_ZONE && TEST_SELLER_ZONE)
            [self addItemInArray:addons.drawer_items itemId:BUTTONS_ID_SELLER_ZONE];
#endif
            
            if ([Utility isMultiStoreApp]) {
                [self addItemInArray:addons.drawer_items itemId:BUTTONS_ID_CHANGE_STORE];
            }
#if TEST_BARCODE_SCANNER
            [self addItemInArray:addons.drawer_items itemId:BUTTONS_ID_SCAN_BARCODE];
#endif
#if TEST_LOCATE_STORE
            [self addItemInArray:addons.drawer_items itemId:BUTTONS_ID_LOCATE_STORE];
#endif
        }
        else {
#if TEST_CHANGE_STORE
            if ([Utility isMultiStoreApp]) {
                DrawerItem* drawerItem = [[DrawerItem alloc] init];
                drawerItem.itemId = BUTTONS_ID_CHANGE_STORE;
                drawerItem.itemName = Localize(@"change_store");
                [addons.drawer_items addObject:drawerItem];
            }
#endif
#if TEST_BARCODE_SCANNER
            {
                DrawerItem* drawerItem = [[DrawerItem alloc] init];
                drawerItem.itemId = BUTTONS_ID_SCAN_BARCODE;
                drawerItem.itemName = Localize(@"title_barcode_scan");
                [addons.drawer_items addObject:drawerItem];
            }
#endif
#if TEST_LOCATE_STORE
            {
                DrawerItem* drawerItem = [[DrawerItem alloc] init];
                drawerItem.itemId = BUTTONS_ID_LOCATE_STORE;
                drawerItem.itemName = Localize(@"locate_store");
                [addons.drawer_items addObject:drawerItem];
            }
#endif
        }
        for (DrawerItem* drawerItem in addons.drawer_items) {
            RADataObject* itemObj = [[RADataObject alloc] init];
            itemObj.objId = drawerItem.itemId;
            [item addObject:itemObj];
            [self initRADataObject:itemObj];
            if (![drawerItem.itemName isEqualToString:@""]) {
                itemObj.title = drawerItem.itemName;
                RLOG(@"itemObj.title  %@",itemObj.title);
            }
            if (drawerItem.itemId == BUTTONS_ID_GROUP) {
                if ([drawerItem.itemData isKindOfClass:[NSArray class]]) {
                    itemObj.groupeListData = [[NSMutableArray alloc] initWithArray:(NSArray*)(drawerItem.itemData)];
                }
                [self addGroupItemsRecursive:itemObj groupData:itemObj.groupeListData];
            }
            else if (drawerItem.itemId == BUTTONS_ID_CATEGORIES && drawerItem.sortedCategoryArray && [drawerItem.sortedCategoryArray count] > 0) {
                [CategoryInfo getAllRootCategories];
                serverRootCategories = [[NSMutableArray alloc] init];
                serverRootCategoriesIcon = [[NSMutableArray alloc] init];
                for (NSNumber* categoryIdObj in drawerItem.sortedCategoryArray) {
                    int cId = [categoryIdObj intValue];
                    CategoryInfo* cInfo = [CategoryInfo getWithId:cId];
                    [serverRootCategories addObject:cInfo];
                }
                for (NSString* categoryIcon in drawerItem.sortedCategoryIconArray) {
                    [serverRootCategoriesIcon addObject:categoryIcon];
                }
            }
            else if (drawerItem.itemData && [drawerItem.itemData isKindOfClass:[NSString class]] && ![drawerItem.itemData isEqualToString:@""]) {
                    itemObj.urlString = drawerItem.itemData;
                    RLOG(@"itemObj.urlString  %@",itemObj.urlString);
                }
        }
    }
    
    //RLOG(@"%@",[CategoryInfo getAllRootCategories]);
    
    if([[TMLanguage sharedManager] isLocalizationVisible]) {
        [self addSettingObjects:settingObject];
    }
    if (serverRootCategories == nil) {
        if (addons.show_nested_category_menu) {
            [self addCategoriesRecursive:categoryObject categoryArray:[CategoryInfo getAllRootCategories]];
        } else {
            for (CategoryInfo* category in [CategoryInfo getAllRootCategories]) {
                NSUInteger index = [self.dataObjects indexOfObject:categoryObject];
                if (self.dataObjects.count >= index) {
                    RADataObject* itemObj = [[RADataObject alloc] init];
                    itemObj.objId = categoryObject.objId;
                    itemObj.imgPath = categoryObject.imgPath;
                    itemObj.title = category._name;
                    itemObj.cInfo = category;
                    [item addObject:itemObj];
                    [self.dataObjects insertObject:itemObj atIndex:index];
                    [self addCategoriesRecursive:itemObj categoryArray:[category getSubCategories]];
                }
            }
            [self.dataObjects removeObject:categoryObject];
            categoryObject = nil;
        }
    } else {
        if (addons.show_nested_category_menu) {
            [self addCategoriesRecursive:categoryObject categoryArray:serverRootCategories];
        } else {
            int srcCounter = 0;
            for (CategoryInfo* category in serverRootCategories) {
                RADataObject* itemObj = [[RADataObject alloc] init];
                itemObj.objId = categoryObject.objId;
                itemObj.imgPath = categoryObject.imgPath;
                if (serverRootCategoriesIcon && [serverRootCategoriesIcon count] > srcCounter) {
                    NSString* imgP = [serverRootCategoriesIcon objectAtIndex:srcCounter];
                    itemObj.imgPath = imgP;
                    itemObj.isIconUrl = true;
                }
                
                itemObj.title = category._name;
                itemObj.cInfo = category;
                [item addObject:itemObj];
                int ind = (int)[self.dataObjects indexOfObject:categoryObject];
                [self.dataObjects insertObject:itemObj atIndex:ind];
                [self addCategoriesRecursive:itemObj categoryArray:[category getSubCategories]];
                srcCounter++;
            }
            [self.dataObjects removeObject:categoryObject];
            categoryObject = nil;
        }
    }
    
    [self.dataObjects addObject:[[RADataObject alloc] init]];
    [self.dataObjects addObject:[[RADataObject alloc] init]];
    [self.dataObjects addObject:[[RADataObject alloc] init]];
    [self.dataObjects addObject:[[RADataObject alloc] init]];
    [self.dataObjects addObject:[[RADataObject alloc] init]];
    
    if (_isMyAccountScreen) {
    } else {
        int categoryObjIndex = (int)[self.dataObjects indexOfObject:categoryObject];
        if (addons.show_wordpress_menu) {
            CustomMenu* cMenu = [CustomMenu sharedManager];
            if(cMenu.items != addons.wordpress_menu_ids) {
                [[[DataManager sharedManager] tmDataDoctor] getCustomMenuItems:addons.wordpress_menu_ids success:^(id data) {
                    int itemPos = 0;
                    if (addons.drawer_items) {
                        for (DrawerItem* dItem in addons.drawer_items) {
                            if(dItem.itemId == BUTTONS_ID_MENU_ITEMS) {
                                [self addCustomMenu:itemPos];
                                break;
                            }
                            itemPos++;
                        }
                        
                    } else {
                        [self addCustomMenu:categoryObjIndex + 1];
                    }
                    [_treeView reloadData];
                } failure:^(NSString *error) {
                    
                }];
            } else {
                [self addCustomMenu:categoryObjIndex + 1];
            }
            
        }
    }
    //    [self getUserRewardPoints];
}
- (void)addCustomMenu:(int)objIndex {
    Addons* addons = [Addons sharedManager];
    if (addons.show_wordpress_menu) {
        CustomMenu* cMenu = [CustomMenu sharedManager];
        for (CustomMenuItem* cMenuItem in cMenu.items) {
            BOOL needToShow = false;
            if (addons.wordpress_menu_ids && [addons.wordpress_menu_ids count] > 0) {
                for (NSNumber* n in addons.wordpress_menu_ids) {
                    int menuID = [n intValue];
                    if (cMenuItem.itemId == menuID) {
                        needToShow = true;
                        break;
                    }
                }
            }
            else {
                needToShow = true;
            }
            if (needToShow) {
                RADataObject * raObj = [[RADataObject alloc] init];
                raObj.title = cMenuItem.itemName;
                raObj.objId = BUTTONS_ID_MENU_ITEMS;
                raObj.imgPath = @"btn_category.png";
                [self.dataObjects insertObject:raObj atIndex:objIndex++];
                [self addCustomMenuItems:raObj cMenuChildren:cMenuItem.itemChildren];
            }
        }
    }
}

- (void)addCustomMenuItems:(RADataObject*)raObj cMenuChildren:(NSMutableArray*)cMenuChildren{
    for (CustomMenuChild* cMenuChild in [cMenuChildren reverseObjectEnumerator]) {
        RADataObject * raObjChild = [[RADataObject alloc] init];
        raObjChild.title = cMenuChild.itemName;
        if(cMenuChild.itemCategoryId != -1)
        {
            raObjChild.cInfo = [CategoryInfo getWithId:cMenuChild.itemCategoryId];
        }else if([cMenuChild.itemUrl isEqualToString:@""] == false) {
            if ((int)[cMenuChild.itemChildren count] == 0) {
                raObjChild.urlString = cMenuChild.itemUrl;
            }
        }
        raObjChild.objId = BUTTONS_ID_MENU_ITEMS;
        [raObj addChild:raObjChild];
        [self addCustomMenuItems:raObjChild cMenuChildren:cMenuChild.itemChildren];
    }
}
//- (void)addHelpAndSupportObjects:(RADataObject*)_raDataObj {
//    RADataObject * raObj1 = [[RADataObject alloc] init];
//    raObj1.title = Localize(@"title_about");
//    raObj1.objId = BUTTONS_ID_CONTACT_US;
//
//    RADataObject * raObj2 = [[RADataObject alloc] init];
//    raObj2.title = Localize(@"i_t&c");
//    raObj2.objId = BUTTONS_ID_TERMS_AND_CONDITIONS;
//
//    //    RADataObject * raObj3 = [[RADataObject alloc] init];
//    //    raObj3.title = Localize(@"i_rate_app");
//    //    raObj3.objId = BUTTONS_ID_RATE_APP;
//    //    [_raDataObj addChild:raObj3];
//    if (![[[[DataManager sharedManager] tmDataDoctor] pagelinkAboutUs] isEqualToString:@""]) {
//        [_raDataObj addChild:raObj2];
//    }
//    [_raDataObj addChild:raObj1];
//}
- (void)addSettingObjects:(RADataObject*)_raDataObj {
    RADataObject * raObj1 = [[RADataObject alloc] init];
    raObj1.title = Localize(@"title_language");
    raObj1.objId = BUTTONS_ID_LANGUAGES;
    [_raDataObj addChild:raObj1];
}
- (void)addGroupItemsRecursive:(RADataObject*)_raDataObj groupData:(NSMutableArray*)groupData {
    if (groupData == nil) {
        return;
    }
    NSDictionary *tempDict = nil;
    for (tempDict in [groupData reverseObjectEnumerator]) {
        DrawerItem* drawerItem = [[DrawerItem alloc] init];
        if (IS_NOT_NULL(tempDict, @"id")) {
            drawerItem.itemId = GET_VALUE_INT(tempDict, @"id");
        }
        if (IS_NOT_NULL(tempDict, @"name")) {
            drawerItem.itemName = GET_VALUE_STRING(tempDict, @"name");
        }
        if (IS_NOT_NULL(tempDict, @"data")) {
            drawerItem.itemData = GET_VALUE_OBJECT(tempDict, @"data");
        }
        if (IS_NOT_NULL(tempDict, @"children")) {
            drawerItem.itemData = GET_VALUE_OBJECT(tempDict, @"children");
        }
        RADataObject* itemObj = [[RADataObject alloc] init];
        itemObj.objId = drawerItem.itemId;
        BOOL isEnable = [self initRADataObject:itemObj addForcefully:false];
        if (isEnable) {
            [_raDataObj addChild:itemObj];
        }
        if (![drawerItem.itemName isEqualToString:@""]) {
            itemObj.title = drawerItem.itemName;
            RLOG(@"itemObj.title  %@",itemObj.title);
        }
        if (drawerItem.itemId == BUTTONS_ID_GROUP) {
            if ([drawerItem.itemData isKindOfClass:[NSArray class]]) {
                itemObj.groupeListData = [[NSMutableArray alloc] initWithArray:(NSArray*)(drawerItem.itemData)];
            }
            [self addGroupItemsRecursive:itemObj groupData:itemObj.groupeListData];
        }
        else {
            if (drawerItem.itemData && [drawerItem.itemData isKindOfClass:[NSString class]] && ![drawerItem.itemData isEqualToString:@""]) {
                itemObj.urlString = drawerItem.itemData;
                RLOG(@"itemObj.urlString  %@",itemObj.urlString);
            }
        }
    }
}
- (void)addCategoriesRecursive:(RADataObject*)_raDataObj categoryArray:(NSMutableArray*)_categoryArray {
    CategoryInfo *category = nil;
    for (category in [_categoryArray reverseObjectEnumerator]) {
        RADataObject * raObj = [[RADataObject alloc] init];
        raObj.title = category._name;
        raObj.cInfo = category;
        [_raDataObj addChild:raObj];
        RLOG(@"%@",[category getSubCategories]);
        [self addCategoriesRecursive:raObj categoryArray:[category getSubCategories]];
    }
}
#pragma mark - Adjust Orientation
- (void)adjustViewsForOrientation:(UIDeviceOrientation) orientation {
    RLOG(@"adjustViewsAfterOrientation");
    float topViewHeight = [[Utility sharedManager] getTopBarHeight];
    if (_isMyAccountScreen) {
        topViewHeight = 0;
    } else {
    }
    if (headerView) {
        CGRect rect = self.view.frame;
        rect.size.height = topViewHeight;// [[MyDevice sharedManager] screenSize].width * 8.0f / 100.0f;
        //        PRINT_RECT(rect);
        headerView.frame = rect;
        [buttonDrawer setCenter:CGPointMake(buttonDrawer.frame.origin.x + buttonDrawer.frame.size.width / 2, rect.size.height / 2  + [[Utility sharedManager] getStatusBarHeight]/2)];
        if (_isMyAccountScreen) {
            headerView.frame = CGRectZero;
        } else {
        }
    }
    if (tableView) {
        CGRect rect = self.view.frame;
        rect.origin.y = topViewHeight - 1;
        rect.size.height = _rowH;
        tableView.frame = rect;
    }
    if (_treeView) {
        CGRect rect = self.view.frame;
        rect.origin.y = tableView.frame.origin.y + tableView.frame.size.height;
        _treeView.frame =  rect;
    }
}
- (void)adjustViewsAfterOrientation:(UIDeviceOrientation) orientation {
    RLOG(@"adjustViewsAfterOrientation");
    float topViewHeight = [[Utility sharedManager] getTopBarHeight];
    if (_isMyAccountScreen) {
        topViewHeight = 0;
    } else {
    }
    if (headerView) {
        CGRect rect = self.view.frame;
        rect.size.height = topViewHeight;//[[MyDevice sharedManager] screenSize].height * 8.0f / 100.0f;
        //        PRINT_RECT(rect);
        headerView.frame = rect;
        
        [buttonDrawer setCenter:CGPointMake(buttonDrawer.frame.origin.x + buttonDrawer.frame.size.width / 2, rect.size.height / 2  + [[Utility sharedManager] getStatusBarHeight]/2)];
        //        PRINT_RECT(buttonDrawer.superview.frame);
        //        PRINT_RECT(buttonDrawer.frame);
        if (_isMyAccountScreen) {
            headerView.frame = CGRectZero;
        } else {
        }
    }
    if (tableView) {
        CGRect rect = self.view.frame;
        rect.origin.y = topViewHeight - 1;
        rect.size.height = _rowH;
        tableView.frame = rect;
        [tableView reloadData];
    }
    if (_treeView) {
        CGRect rect = self.view.frame;
        rect.origin.y = tableView.frame.origin.y + tableView.frame.size.height;
        _treeView.frame =  rect;
        [_treeView reloadData];
    }
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
#pragma mark -Tableview
#pragma mark - UITableViewDataSource
// the cell will be returned to the tableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return _rowH;
    //[[MyDevice sharedManager] screenSize].height * 8.0f / 100.0f;
    //    [[LayoutManager sharedManager] leftViewProp]->rowHeight_PWRTH_MAX * [[MyDevice sharedManager] screenHeightInPortrait] / 100.0f;//[indexPath row] * 1.5;
}
- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    LoginViewOnDrawer *cell = [tableView dequeueReusableCellWithIdentifier:@"LoginViewOnProfile"];
    if (_isMyAccountScreen) {
        if (! cell) {
            NSArray *parts = [[NSBundle mainBundle] loadNibNamed:@"LoginViewOnProfile" owner:nil options:nil];
            cell = [parts objectAtIndex:0];
        }
    } else {
        if (! cell) {
            NSArray *parts = [[NSBundle mainBundle] loadNibNamed:@"LoginViewOnDrawer" owner:nil options:nil];
            cell = [parts objectAtIndex:0];
        }
    }
    loginView = cell;
    cell.labelUserName.translatesAutoresizingMaskIntoConstraints = YES;
    cell.labelUserId.translatesAutoresizingMaskIntoConstraints = YES;
    cell.imgUser.translatesAutoresizingMaskIntoConstraints = YES;
    cell.imgUserBg.translatesAutoresizingMaskIntoConstraints = YES;
    
    
    if ([[[AppUser sharedManager] _email] isEqualToString:@""]) {
        [cell.labelUserId setText:Localize(@"i_use_your_email_add")];
    } else {
        [cell.labelUserId setText:[[AppUser sharedManager] _email]];
    }
    if ([[[AppUser sharedManager] _username] isEqualToString:@""]) {
        [cell.labelUserName setText:[NSString stringWithFormat:@"%@ / %@", Localize(@"title_login"), Localize(@"action_sign_up_short")]];
    } else {
        NSMutableString * str = [[NSMutableString alloc] init];
        AppUser* ap = [AppUser sharedManager];
        if (![ap._first_name isEqualToString:@""]) {
            [str appendString:ap._first_name];
        }
        if (![ap._last_name isEqualToString:@""]) {
            [str appendFormat:@" %@",ap._last_name ];
        }
        if ([str isEqualToString:@""]) {
            [str appendFormat:@" %@",ap._username];
        }
        [cell.labelUserName setText:str];
        
//        if ([[[AppUser sharedManager] _avatar_url] isEqualToString:@""]) {
//            [cell.imgUser setUIImage:[UIImage imageNamed:@"profile.png"]];
//        } else {
//            [Utility setImage:cell.imgUser url:ap._avatar_url resizeType:0 isLocal:false highPriority:true];
//        }
//
    }
    if ([[[AppUser sharedManager] _avatar_url] isEqualToString:@""]) {
        [cell.imgUser setUIImage:[UIImage imageNamed:@"profile.png"]];
    } else {
        [Utility setImage:cell.imgUser url:[[AppUser sharedManager] _avatar_url] resizeType:0 isLocal:false highPriority:true];
    }
 
//    if ([[SellerInfo getCurrentSeller] sellerAvatarUrl] && ![[[SellerInfo getCurrentSeller] sellerAvatarUrl] isEqualToString:@""]) {
//        [Utility setImage:imageUser url:[[SellerInfo getCurrentSeller] sellerAvatarUrl] resizeType:0 isLocal:false highPriority:true];
//    } else {
//        [Utility setImage:imageUser url:appUser._avatar_url resizeType:0 isLocal:false highPriority:true];
//    }

    
    
    int diffAmount = 0;
    float imgDiffAmount = 0;
    float imgBgFrameWidth = cell.imgUserBg.frame.size.width;
    float imgDiffAmountPrev = 0;
    do {
        CGRect imgBgFrame = cell.imgUserBg.frame;
        CGRect imgFgFrame = cell.imgUser.frame;
        
        if (imgDiffAmount < imgBgFrameWidth * .75f && imgDiffAmountPrev != imgDiffAmount) {
            imgBgFrame.size.width = imgBgFrame.size.width - imgDiffAmount;
            imgBgFrame.size.height = imgBgFrame.size.height - imgDiffAmount;
            imgFgFrame.size.width = imgFgFrame.size.width - imgDiffAmount;
            imgFgFrame.size.height = imgFgFrame.size.height - imgDiffAmount;
            cell.imgUserBg.frame = imgBgFrame;
            cell.imgUser.frame = imgFgFrame;
            imgDiffAmountPrev = imgDiffAmount;
        }
        
        
        if (_isMyAccountScreen) {
            [cell.labelUserName setUIFont:kUIFontType32 - diffAmount isBold:true];
            [cell.labelUserId setUIFont:kUIFontType20 - diffAmount isBold:true];
        } else {
            if ([[MyDevice sharedManager] isIpad]) {
                [cell.labelUserName setUIFont:kUIFontType16 - diffAmount isBold:true];
                [cell.labelUserId setUIFont:kUIFontType10 - diffAmount isBold:true];
            } else {
                [cell.labelUserName setUIFont:kUIFontType18 - diffAmount isBold:true];
                [cell.labelUserId setUIFont:kUIFontType12 - diffAmount isBold:true];
            }
        }
        cell.imgUserBg.layer.cornerRadius = cell.imgUserBg.frame.size.height / 2;
        cell.imgUserBg.layer.masksToBounds = YES;
        cell.imgUserBg.layer.borderWidth = 0;
        cell.imgUser.layer.cornerRadius = cell.imgUser.frame.size.height / 2;
        cell.imgUser.layer.masksToBounds = YES;
        cell.imgUser.layer.borderWidth = 0;
        CGSize sizeName = LABEL_SIZE(cell.labelUserName);
        CGSize sizeId = LABEL_SIZE(cell.labelUserId);
        CGSize sizeImgBg = cell.imgUserBg.frame.size;
        float maxLabelWidth = sizeName.width;
        if (sizeId.width > sizeName.width) {
            maxLabelWidth = sizeId.width;
        }
        float totalWidth = maxLabelWidth + sizeImgBg.width + _gap;
        float selfWidth = self.view.frame.size.width;
        float bgimgPosX = (selfWidth - totalWidth) / 2 + sizeImgBg.width / 2;
        float labelPosX = bgimgPosX + sizeImgBg.width / 2 + _gap + maxLabelWidth / 2;
        
        float imgCenterY = cell.imgUserBg.center.y;
        cell.imgUserBg.center = CGPointMake(bgimgPosX, imgCenterY);
        cell.imgUser.center = CGPointMake(bgimgPosX, imgCenterY);
        [cell.labelUserName sizeToFitUI];
        [cell.labelUserId sizeToFitUI];
        
        cell.labelUserName.center = CGPointMake(labelPosX, cell.imgUserBg.center.y - cell.labelUserName.frame.size.height/2);
        cell.labelUserId.center = CGPointMake(labelPosX, cell.imgUserBg.center.y + cell.labelUserId.frame.size.height/2);
        diffAmount++;
        if (diffAmount%3 == 0) {
            imgDiffAmount += (imgBgFrameWidth * .10f);
        }
        
    } while (CGRectGetMinX(cell.imgUserBg.frame) < 0);
    
    
    [cell setNeedsLayout];
    return cell;
}
#pragma mark - UITableViewDelegate
// when user tap the row, what action you want to perform
- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_isUserLoggedIn == false) {
        [self showLoginPopup:true];
    }else {
        mainVC = [ViewControllerMain getInstance];
        mainVC.containerTop.hidden = YES;
        mainVC.containerCenter.hidden = YES;
        mainVC.containerCenterWithTop.hidden = NO;
        mainVC.vcBottomBar.buttonHome.selected = YES;
        mainVC.vcBottomBar.buttonCart.selected = NO;
        mainVC.vcBottomBar.buttonWishlist.selected = NO;
        mainVC.vcBottomBar.buttonSearch.selected = NO;
        mainVC.revealController.panGestureEnable = false;
        [mainVC.vcBottomBar buttonClicked:nil];
       [mainVC.revealController revealToggle:self];
       [mainVC btnClickedMyAccount:nil];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    RLOG(@"selected %d row", (int)indexPath.row);
}
- (void)clickOnCategory:(CategoryInfo*)categoryClicked currentItemData:(DataPass*)currentItemData{
    mainVC = [ViewControllerMain getInstance];
    mainVC.containerTop.hidden = YES;
    mainVC.containerCenter.hidden = YES;
    mainVC.containerCenterWithTop.hidden = NO;
    mainVC.vcBottomBar.buttonHome.selected = YES;
    mainVC.vcBottomBar.buttonCart.selected = NO;
    mainVC.vcBottomBar.buttonWishlist.selected = NO;
    mainVC.vcBottomBar.buttonSearch.selected = NO;
    mainVC.revealController.panGestureEnable = false;
    [mainVC.vcBottomBar buttonClicked:nil];
    DataPass* clickedItemData = [[DataPass alloc] init];
    clickedItemData.itemId = categoryClicked._id;
    clickedItemData.isCategory = true;
    clickedItemData.isProduct = false;
    clickedItemData.hasChildCategory = [[categoryClicked getSubCategories] count];
    clickedItemData.childCount = (int)[[ProductInfo getOnlyForCategory:categoryClicked] count];
    clickedItemData.cInfo = categoryClicked;
    
    DataPass* previousItemData = [[DataPass alloc] init];
    previousItemData.itemId = currentItemData.cInfo._id;
    previousItemData.isCategory = currentItemData.isCategory;
    previousItemData.isProduct = currentItemData.isProduct;
    previousItemData.hasChildCategory = currentItemData.hasChildCategory;
    previousItemData.childCount = currentItemData.childCount;
    previousItemData.cInfo = currentItemData.cInfo;
    
    ViewControllerCategories* vcCategories = (ViewControllerCategories*)[[Utility sharedManager] pushScreenWithoutAnimation:mainVC.vcCenterTop type:PUSH_SCREEN_TYPE_CATEGORY];
    [vcCategories loadData:clickedItemData previousItem:previousItemData drillingLevel:0];
}
///////////////////////////////
#pragma mark - LOGIN
- (void)showLoginPopup:(BOOL)withAnimation{
    if (![[[[DataManager sharedManager] tmDataDoctor] tmMulticastDelegate] hasDelegate:self]) {
        [[[[DataManager sharedManager] tmDataDoctor] tmMulticastDelegate] addDelegate:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loggedIn:) name:@"LoginCompleted" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetPasswordSentSuccess:) name:@"ResetPasswordSentSuccess" object:nil];
    }
    [self createLoginPopup];
    [self fillDataInPopup];
    if (withAnimation) {
        [self signupClicked:nil];
    }else{
        [self.popupController presentPopupControllerAnimated:withAnimation];
    }
}
- (void)createLoginPopup {
    if (self.popupController == nil) {
        
        DataManager* dm = [DataManager sharedManager];
        BOOL isFBExists = ([dm.keyFacebookAppId isEqualToString:@""] || [dm.keyFacebookConsumerSecret isEqualToString:@""]) ? false : true;
        BOOL isGoogleExists = ([dm.keyGoogleClientId isEqualToString:@""] || [dm.keyGoogleClientSecret isEqualToString:@""]) ? false : true;
        BOOL isTwitterExists = ([dm.keyTwitterConsumerKey isEqualToString:@""] || [dm.keyTwitterConsumerSecret isEqualToString:@""]) ? false : true;
        
        int totalSocialAuthItems = 0;
        if (isFBExists) {
            totalSocialAuthItems++;
        }
        if (isGoogleExists) {
            totalSocialAuthItems++;
        }
        if (isTwitterExists) {
            totalSocialAuthItems++;
        }
        
        
        float widthView = [[MyDevice sharedManager] screenSize].width - [[MyDevice sharedManager] screenSize].width * 0.1f;
        float heightView = [[MyDevice sharedManager] screenSize].height - [[MyDevice sharedManager] screenSize].width * 0.1f;
        
        if ([[MyDevice sharedManager] isIpad]) {
            widthView = [[MyDevice sharedManager] screenWidthInPortrait] * 0.65f;
            heightView = [[MyDevice sharedManager] screenHeightInPortrait] * 0.63f;
            
        }else if ([[MyDevice sharedManager] isIphone]) {
            widthView = [[MyDevice sharedManager] screenSize].width * 0.96f;
            heightView = [[MyDevice sharedManager] screenSize].height * 0.70f;
        }
        
        
        UIView* viewMain = [[UIView alloc] initWithFrame:CGRectMake(0, 0, widthView, heightView)];
        viewMain.backgroundColor = [Utility getUIColor:kUIColorBgTheme];
        _mainViewLogin = viewMain;
        
        UIView* viewTop = [[UIView alloc] initWithFrame:CGRectMake(0, 0, widthView, heightView * 0.05f)];
        
        viewTop.backgroundColor = [UIColor whiteColor];
        [viewMain addSubview:viewTop];
        
        self.popupController = [[CNPPopupController alloc] initWithContents:@[viewMain]];
        self.popupController.theme = [CNPPopupTheme addressTheme];
        self.popupController.theme.popupStyle = CNPPopupStyleCentered;
        self.popupController.theme.size = CGSizeMake(widthView, heightView);
        self.popupController.theme.maxPopupWidth = widthView;
        self.popupController.delegate = self;
        [self setShouldDismissOnBackgroundTouch:self.popupController];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            self.popupController.VIEW_POPUP.transform = CGAffineTransformMakeScale(-1, 1);
        }
        
        UIButton* _buttonCancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, viewTop.frame.size.width, viewTop.frame.size.height)];
        [viewTop addSubview:_buttonCancel];
        [_buttonCancel addTarget:self action:@selector(cancelClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_buttonCancel sizeToFit];
        [_buttonCancel setFrame:CGRectMake(viewTop.frame.size.width * 0.04f, 0, _buttonCancel.frame.size.width, viewTop.frame.size.height)];
        
        
        
        
        UILabel* _labelTitle = [self createLabel:viewTop fontType:kUIFontType20 fontColorType:kUIColorFontDark frame:CGRectMake(0, -16, viewTop.frame.size.width, viewTop.frame.size.height + 16) textStr:Localize(@"action_sign_in_short")];
        [_labelTitle setTextAlignment:NSTextAlignmentCenter];
        
        
        float posY = CGRectGetMaxY(viewTop.frame) + viewMain.frame.size.width * 0.05f;
        float width = viewMain.frame.size.width * 0.70f;
        float posX = (viewMain.frame.size.width - width)/2;
#if REGISTRATION_HIDE_USERNAME
        float height = (viewMain.frame.size.height - (posY - viewTop.frame.size.height) - posY)/9;
#else
        float height = (viewMain.frame.size.height - (posY - viewTop.frame.size.height) - posY)/10.0f;
#endif
        float gap = height/2;
        if (totalSocialAuthItems == 0) {
            posY += (heightView * (1.0f - 0.63f) / 4);
        }
        
        
        
        _textLoginId = [self createTextField:viewMain fontType:kUIFontType18 fontColorType:kUIColorFontLight frame:CGRectMake(posX, posY, width, height) tag:_kTAGTEXTFIELD_LOGIN_ID textStrPlaceHolder:Localize(@"email")];
        posY += (height+gap);
        
        _textLoginPassword = [self createTextField:viewMain fontType:kUIFontType18 fontColorType:kUIColorFontLight frame:CGRectMake(posX, posY, width, height) tag:_kTAGTEXTFIELD_LOGIN_PASSWORD textStrPlaceHolder:Localize(@"prompt_password")];
        posY += (height+gap);
        [_textLoginPassword setSecureTextEntry:YES];
        
        UIButton *buttonLogin = [[UIButton alloc] initWithFrame:CGRectMake(posX, posY, width, height)];
        [buttonLogin setBackgroundColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
        [[buttonLogin titleLabel] setUIFont:kUIFontType22 isBold:false];
        [buttonLogin setTitle:Localize(@"action_sign_in_short") forState:UIControlStateNormal];
        [buttonLogin setTitleColor:[Utility getUIColor:kUIColorBuyButtonFont] forState:UIControlStateNormal];
        [viewMain addSubview:buttonLogin];
        [buttonLogin addTarget:self action:@selector(loginClicked:) forControlEvents:UIControlEventTouchUpInside];
        posY += (height+gap);
        
        
        UIButton* _buttonClickHere = [[UIButton alloc] initWithFrame:CGRectMake(posX, posY, width, height)];
        [[_buttonClickHere titleLabel] setUIFont:kUIFontType18 isBold:false];
        [_buttonClickHere setTitleColor:[Utility getUIColor:kUIColorBlue] forState:UIControlStateNormal];
        [viewMain addSubview:_buttonClickHere];
        [_buttonClickHere addTarget:self action:@selector(signupClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        
        
        
        UIButton* _buttonForgetPass = [[UIButton alloc] initWithFrame:CGRectMake(posX, posY, width, height)];
        [[_buttonForgetPass titleLabel] setUIFont:kUIFontType18 isBold:false];
        [_buttonForgetPass setTitleColor:[Utility getUIColor:kUIColorBlue] forState:UIControlStateNormal];
        [viewMain addSubview:_buttonForgetPass];
        [_buttonForgetPass addTarget:self action:@selector(forgotPasswordClicked:) forControlEvents:UIControlEventTouchUpInside];
#if (SINGLE_LINE)
        [_buttonClickHere setTitle:Localize(@"Click here to create new account /") forState:UIControlStateNormal];
        [_buttonForgetPass setTitle:Localize(@"txt_forget") forState:UIControlStateNormal];
        float buttonw1 = LABEL_SIZE([_buttonClickHere titleLabel]).width;
        float buttonw2 = LABEL_SIZE([_buttonForgetPass titleLabel]).width;
        float buttonh2 = LABEL_SIZE([_buttonForgetPass titleLabel]).height;
        float buttonwT = buttonw1 + buttonw2;
        CGRect br1 = _buttonClickHere.frame;
        CGRect br2 = _buttonForgetPass.frame;
        br1.origin.x = (widthView - buttonwT)/2;
        br1.size.width = buttonw1;
        
        br2.size.width = buttonw2;
        br2.size.height = buttonh2;
        br2.center.x = widthView/2;
        [_buttonForgetPass set]
        [_buttonClickHere setFrame:br1];
        [_buttonForgetPass setFrame:br2];
#else
        
        
        [_buttonClickHere setTitle:Localize(@"sign_up_here") forState:UIControlStateNormal];
        [_buttonForgetPass setTitle:Localize(@"txt_forget") forState:UIControlStateNormal];
        float buttonw1 = LABEL_SIZE([_buttonClickHere titleLabel]).width;
        float buttonh1 = LABEL_SIZE([_buttonClickHere titleLabel]).height;
        float buttonw2 = LABEL_SIZE([_buttonForgetPass titleLabel]).width;
        float buttonh2 = LABEL_SIZE([_buttonForgetPass titleLabel]).height;
        
        CGRect br1 = _buttonClickHere.frame;
        CGRect br2 = _buttonForgetPass.frame;
        br1.origin.x = widthView * 0.10f;
        br1.size.width = buttonw1;
        br1.size.height = buttonh1;
        
        
        br2.origin.x = widthView * 0.50f - buttonw2/2;
        br2.origin.y = CGRectGetMaxY(br1);//+ buttonh1/2;//#newrr
        br2.size.width = buttonw2;
        br2.size.height = buttonh2;
        
        [_buttonClickHere setFrame:br1];
        [_buttonForgetPass setFrame:br2];
        
#if (LOGIN_HIDE_FORGET_PASSWORD == 0)
        UILabel *faltuText = [[UILabel alloc] init];
        [faltuText setUIFont:kUIFontType18 isBold:false];
        faltuText.text = Localize(@"dont_have_account");
        faltuText.textColor = [Utility getUIColor:kUIColorFontLight];
        [faltuText sizeToFitUI];
        [viewMain addSubview:faltuText];
        CGRect rectCreateBtn = _buttonClickHere.frame;
        CGRect rectTextDesc = faltuText.frame;
        float totalWidth = rectTextDesc.size.width + rectCreateBtn.size.width;
        float totalViewWidth = viewMain.frame.size.width;
        float startX = (totalViewWidth - totalWidth)/2;
        rectTextDesc.origin.x = startX;//rectCreateBtn.origin.x;
        rectTextDesc.origin.y = rectCreateBtn.origin.y;
        rectTextDesc.size.height =rectCreateBtn.size.height;
        rectCreateBtn.origin.x = CGRectGetMaxX(rectTextDesc);
        _buttonClickHere.frame = rectCreateBtn;
        faltuText.frame = rectTextDesc;
#endif
        
        
        
        
#endif
        
        
#if LOGIN_HIDE_FORGET_PASSWORD
        _buttonForgetPass.hidden = true;
#endif
        
        
        //        posY = heightView * .63f;
        posY = heightView * .68f;
        gap = height/3;
        UIView *bottomBorder = [[UIView alloc] init];
        bottomBorder.frame = CGRectMake(0, posY, viewMain.frame.size.width, 2);
        bottomBorder.backgroundColor = [Utility getUIColor:kUIColorBorder];
        [viewMain addSubview:bottomBorder];
        
        UILabel* _labelGyan = [self createLabel:viewMain fontType:kUIFontType14 fontColorType:kUIColorFontLight frame:CGRectMake(0, posY, viewMain.frame.size.width, height) textStr:Localize(@"sign_in_1_click")];
        [_labelGyan setTextAlignment:NSTextAlignmentCenter];
        posY += (height * .75f);
        
        

        _fbLoginButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [_fbLoginButton setUIImage:[UIImage imageNamed:@"facebookLogin.png"] forState:UIControlStateNormal];
        [[_fbLoginButton imageView] setContentMode: UIViewContentModeScaleAspectFit];
        [_fbLoginButton addTarget:self action:@selector(fbClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        _googleLoginButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [_googleLoginButton setUIImage:[UIImage imageNamed:@"googleLogin.png"] forState:UIControlStateNormal];
        [[_googleLoginButton imageView] setContentMode: UIViewContentModeScaleAspectFit];
        [_googleLoginButton addTarget:self action:@selector(googleClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        _twitterLoginButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [_twitterLoginButton setUIImage:[UIImage imageNamed:@"twitterLogin.png"] forState:UIControlStateNormal];
        [[_twitterLoginButton imageView] setContentMode: UIViewContentModeScaleAspectFit];
        [_twitterLoginButton addTarget:self action:@selector(twitterClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        
        
        _fbLoginButton.hidden = !false;
        _googleLoginButton.hidden = !false;
        _twitterLoginButton.hidden = !false;
        if (isFBExists) {
            _fbLoginButton.hidden = !true;
        }
        if (isGoogleExists) {
            _googleLoginButton.hidden = !true;
        }
        if (isTwitterExists) {
            _twitterLoginButton.hidden = !true;
        }
        switch (totalSocialAuthItems) {
            case 0:
                _labelGyan.hidden = true;
                bottomBorder.hidden = true;
                break;
            case 1:
            {
                CGRect rect = CGRectMake((viewMain.frame.size.width - viewMain.frame.size.width * .45f) / 2, posY+gap, viewMain.frame.size.width * .45f, height);
                _loginScreenRectFB = rect;
                _loginScreenRectGoogle = rect;
                _loginScreenRectTwitter = rect;
            } break;
            case 2:
            {
                CGRect rect1 = CGRectMake(viewMain.frame.size.width * .05f, posY+gap, viewMain.frame.size.width * .45f, height);
                CGRect rect2 = CGRectMake(viewMain.frame.size.width * .50f, posY+gap, viewMain.frame.size.width * .45f, height);
                if (isFBExists) {
                    _loginScreenRectFB = rect1;
                    rect1 = rect2;
                }
                if (isGoogleExists) {
                    _loginScreenRectGoogle = rect1;
                    rect1 = rect2;
                }
                if (isTwitterExists) {
                    _loginScreenRectTwitter = rect1;
                    rect1 = rect2;
                }
            } break;
            case 3:
                _loginScreenRectFB = CGRectMake(viewMain.frame.size.width * .05f, posY, viewMain.frame.size.width * .45f, height);
                _loginScreenRectGoogle = CGRectMake(viewMain.frame.size.width * .50f, posY, viewMain.frame.size.width * .45f, height);
                posY += height;
                _loginScreenRectTwitter = CGRectMake((viewMain.frame.size.width - viewMain.frame.size.width * .45f) / 2, posY, viewMain.frame.size.width * .45f, height);
                posY += height;
                break;
                
            default:
                break;
        }
        /*switch (totalSocialAuthItems) {
         case 0:
         _labelGyan.hidden = true;
         bottomBorder.hidden = true;
         break;
         case 1:
         {
         CGRect rect = CGRectMake(viewMain.frame.size.width * .3f, posY+gap, viewMain.frame.size.width * .4f, height);
         _loginScreenRectFB = rect;
         _loginScreenRectGoogle = rect;
         _loginScreenRectTwitter = rect;
         } break;
         case 2:
         {
         CGRect rect1 = CGRectMake(viewMain.frame.size.width * .075f, posY+gap, viewMain.frame.size.width * .4f, height);
         CGRect rect2 = CGRectMake(viewMain.frame.size.width * .525f, posY+gap, viewMain.frame.size.width * .4f, height);
         if (isFBExists) {
         _loginScreenRectFB = rect1;
         rect1 = rect2;
         }
         if (isGoogleExists) {
         _loginScreenRectGoogle = rect1;
         rect1 = rect2;
         }
         if (isTwitterExists) {
         _loginScreenRectTwitter = rect1;
         rect1 = rect2;
         }
         } break;
         case 3:
         _loginScreenRectFB = CGRectMake(viewMain.frame.size.width * .075f, posY, viewMain.frame.size.width * .4f, height);
         _loginScreenRectGoogle = CGRectMake(viewMain.frame.size.width * .525f, posY, viewMain.frame.size.width * .4f, height);
         posY += height;
         _loginScreenRectTwitter = CGRectMake((viewMain.frame.size.width - viewMain.frame.size.width * .4f) / 2, posY, viewMain.frame.size.width * .4f, height);
         posY += height;
         break;
         
         default:
         break;
         }*/
        
#if (NEW_CHU)
        UIImage * img =  [UIImage imageNamed:@"Icon"];
        [_buttonCancel setUIImage:img forState:UIControlStateDisabled];
        [_buttonCancel.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_buttonCancel setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [_buttonCancel setAdjustsImageWhenDisabled:true];
        [_buttonCancel setEnabled:false];
        float viewH = viewTop.frame.size.height + 16;
        float viewW = (img.size.width/img.size.height) * viewH;
        [_buttonCancel setFrame:CGRectMake(16, -16, viewW, viewH)];
        [_buttonCancel setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        //        UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:_buttonCancel.layer.bounds];
        //        _buttonCancel.layer.backgroundColor = [UIColor whiteColor].CGColor;
        //        _buttonCancel.layer.masksToBounds = NO;
        //        _buttonCancel.layer.shadowColor = [UIColor blackColor].CGColor;
        //        if ([[MyDevice sharedManager] isIpad]) {
        //            _buttonCancel.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
        //            _buttonCancel.layer.shadowOpacity = 0.2f;
        //            _buttonCancel.layer.shadowRadius = 0.0f;
        //        }else{
        //            _buttonCancel.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
        //            _buttonCancel.layer.shadowOpacity = 0.2f;
        //            _buttonCancel.layer.shadowRadius = 0.0f;
        //        }
        //        _buttonCancel.layer.shadowPath = shadowPath.CGPath;
#endif
    }
    
    [_fbLoginButton removeFromSuperview];
    [_fbLoginButton setFrame:_loginScreenRectFB];
    [_mainViewLogin addSubview:_fbLoginButton];
    
    [_googleLoginButton removeFromSuperview];
    [_googleLoginButton setFrame:_loginScreenRectGoogle];
    [_mainViewLogin addSubview:_googleLoginButton];
    
    [_twitterLoginButton removeFromSuperview];
    [_twitterLoginButton setFrame:_loginScreenRectTwitter];
    [_mainViewLogin addSubview:_twitterLoginButton];
}

- (void)loginClicked:(UIButton*)button {
#if NEW_LOGIN_ISSUE
    LoginFlow* lf = [LoginFlow sharedManager];
    [lf responseLogoutClicked:nil];
#endif
    //    [[[DataManager sharedManager] tmDataDoctor] checkPostMethod];
    //    return;
    if ([_textLoginId.text isEqualToString:@""] || [_textLoginPassword.text isEqualToString:@""]) {
        [self showErrorAlert];
        return;
    }
    _wpWebView = [WebViewWordPress sharedManager];
    [self.view addSubview:_wpWebView];
    _wpWebView.loginFillData_userName = @"";
    _wpWebView.loginFillData_userPassword = _textLoginPassword.text;
    _wpWebView.loginFillData_userEmail = _textLoginId.text;
    //    [self authenticateAndLogin];
    //    self._tempServerData = [[DataManager sharedManager] fetchCustomerData:nil userEmail:_wpWebView.loginFillData_userEmail];
    [LoginFlow sharedManager];
    NSMutableDictionary* dataDictionary = [[NSMutableDictionary alloc] init];
    [dataDictionary setObject:@"" forKey:@"name"];
    [dataDictionary setObject:_textLoginPassword.text forKey:@"password"];
    [dataDictionary setObject:@"" forKey:@"image"];
    [dataDictionary setObject:_textLoginId.text forKey:@"email"];
    [dataDictionary setObject:SA_PROVIDERS_NAME[SA_PROVIDERS_STORE] forKey:@"provider"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"response_login_clicked" object:dataDictionary];
}
- (void)authenticateAndLogin {
    if (self.popupController) {
        [self.popupController dismissPopupControllerAnimated:YES];
    }
    if (self.popupControllerRegister) {
        [self.popupControllerRegister dismissPopupControllerAnimated:YES];
    }
    if (self.popupControllerRegisterAsSeller) {
        [self.popupControllerRegisterAsSeller dismissPopupControllerAnimated:YES];
    }
    [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
    [MRProgressOverlayView showOverlayAddedTo:[[UIApplication sharedApplication] keyWindow] title:@"" mode:MRProgressOverlayViewModeIndeterminateSmallDefault animated:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:@"LoginSuccessful" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:@"LoginFailed" object:nil];
    
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    [self setEditing:NO];
}
- (void)receiveNotification:(NSNotification *)notification{
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LoginSuccessful" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LoginFailed" object:nil];
    [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
    
    if ([[notification name] isEqualToString:@"LoginSuccessful"]){
        RLOG (@"LoginSuccessful");
        NSString *serverUrl = [NSString stringWithFormat:@"%@/email/%@", [[[DataManager sharedManager] tmDataDoctor] request_url_customer], _wpWebView.loginFillData_userEmail];
        NSString* dictionaryString = [[NSUserDefaults standardUserDefaults] valueForKey:serverUrl];
        [[DataManager sharedManager] loadCustomerData:[dictionaryString json_StringToDictionary]];
        AppUser* appuser = [AppUser sharedManager];
        appuser._userLoggedInVia = SA_PROVIDERS_STORE;
        [self loggedIn:nil];
    }
    if ([[notification name] isEqualToString:@"LoginFailed"]){
        RLOG (@"LoginFailed");
        NSString* description = Localize(@"invalid_email");
        if ([notification object]) {
            NSMutableDictionary* dictionary =  [notification object];
            if(dictionary)
                description = [dictionary objectForKey:@"description"];
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Localize(@"login_failed") message:description delegate:self cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil];
        [alert show];
    }
}
- (void)signupClicked:(UIButton*)button {
    [self createRegisterPopup];
    if (button == nil) {
        if ([Utility isSellerOnlyApp]) { } else {
            [self.popupControllerRegister presentPopupControllerAnimated:YES];
        }
    }else{
        if ([Utility isSellerOnlyApp]) { } else {
            [self.popupControllerRegister presentPopupControllerAnimated:NO];
        }
    }
    if (self.popupControllerRegisterAsSeller) {
        [self.popupControllerRegisterAsSeller dismissPopupControllerAnimated:NO];
    }
    [self.popupController dismissPopupControllerAnimated:NO];
    [self.popupControllerForgotPassword dismissPopupControllerAnimated:NO];
    if ([Utility isSellerOnlyApp]) {
        [self registerAsVendor:self.buttonRegisterAsVendor];
    }
}
- (void)forgotPasswordClicked:(UIButton*)button {
    [self createForgotPasswordPopup];
    [self.popupControllerForgotPassword presentPopupControllerAnimated:NO];
    [self.popupControllerRegister dismissPopupControllerAnimated:NO];
    [self.popupController dismissPopupControllerAnimated:NO];
    if (self.popupControllerRegisterAsSeller) {
        [self.popupControllerRegisterAsSeller dismissPopupControllerAnimated:NO];
    }
}
- (void)tryForFacebookWeb:(NSNotification *)notification{
#if NEW_LOGIN_ISSUE
    LoginFlow* lf = [LoginFlow sharedManager];
    [lf responseLogoutClicked:nil];
#endif
    [self cancelClicked:nil];
#if ENABLE_SIMPLEAUTH
    [[LoginFlow sharedManager] clickOnSimpleAuthItem:SA_PROVIDERS_FACEBOOK_WEB];
#endif
}
- (void)tryForTwitterWeb:(NSNotification *)notification{
#if NEW_LOGIN_ISSUE
    LoginFlow* lf = [LoginFlow sharedManager];
    [lf responseLogoutClicked:nil];
#endif
    [self cancelClicked:nil];
#if ENABLE_SIMPLEAUTH
    [[LoginFlow sharedManager] clickOnSimpleAuthItem:SA_PROVIDERS_TWITTER_WEB];
#endif
}
- (void)fbClicked:(UIButton*)button {
    if ([[Utility sharedManager] checkForDemoApp:true]) return;
#if NEW_LOGIN_ISSUE
    LoginFlow* lf = [LoginFlow sharedManager];
    [lf responseLogoutClicked:nil];
#endif
    [self cancelClicked:nil];
#if ENABLE_FB_LOGIN
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login logInWithReadPermissions: @[@"public_profile", @"email"]
                 fromViewController:self
                            handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                [MRProgressOverlayView showOverlayAddedTo:[[UIApplication sharedApplication] keyWindow] title:@"" mode:MRProgressOverlayViewModeIndeterminateSmallDefault animated:YES];
                                if (error) {
                                    RLOG(@"Process error");
                                    RLOG(@"FB ERROR IN TOKEN FETCHING");
                                    [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Localize(@"sorry") message:[error description] delegate:self cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil];
                                    [alert show];
                                }
                                else if (result.isCancelled) {
                                    RLOG(@"Cancelled");
                                    RLOG(@"FB CANCELLED");
                                    [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
                                }
                                else {
                                    RLOG(@"Logged in");
                                    RLOG(@"FB LOGIN SUCCESSFUL");
                                    if (result.token)
                                    {
                                        RLOG(@"FB FETCHING USER DATA STARTED");
                                        FBSDKGraphRequest* gr = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"id, name, first_name, picture.type(square), last_name, email"} tokenString:result.token.tokenString version:nil HTTPMethod:nil];
                                        [gr startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                                            if(error) {
                                                [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
                                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Localize(@"sorry") message:[error description] delegate:self cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil];
                                                [alert show];
                                                return;
                                            }
                                            RLOG(@"%@", result);
                                            //                     {
                                            //                         email = "petergomes20@gmail.com";
                                            //                         "first_name" = Peter;
                                            //                         id = 1719615974941436;
                                            //                         "last_name" = Gomes;
                                            //                         name = "Peter Gomes";
                                            //                         picture =     {
                                            //                             data =         {
                                            //                                 "is_silhouette" = 0;
                                            //                                 url = "https://scontent.xx.fbcdn.net/v/t1.0-1/s200x200/1374277_1394597837443253_1536501057_n.jpg?oh=87af1b7c37bd69cddf83a7cbcbe3e2a8&oe=59CF8B56";
                                            //                             };
                                            //                         };
                                            //                     }
                                            NSString* firstName = @"";
                                            NSString* lastName = @"";
                                            NSString* userEmailId = @"";
                                            NSString* userImagePath = @"";
                                            NSString* userName = @"";
                                            NSString* uId = @"";
                                            if (result && [result isKindOfClass:[NSDictionary class]]) {
                                                if (IS_NOT_NULL(result, @"name")) {
                                                    userName = GET_VALUE_STR(result, @"name");
                                                }
                                                if (IS_NOT_NULL(result, @"first_name")) {
                                                    firstName = GET_VALUE_STR(result, @"first_name");
                                                }
                                                if (IS_NOT_NULL(result, @"last_name")) {
                                                    lastName = GET_VALUE_STR(result, @"last_name");
                                                }
                                                if (IS_NOT_NULL(result, @"email")) {
                                                    userEmailId = GET_VALUE_STR(result, @"email");
                                                }
                                                if (IS_NOT_NULL(result, @"id")) {
                                                    uId = GET_VALUE_STR(result, @"id");
                                                }
                                                if([userEmailId isEqualToString:@""]){
                                                    userEmailId = [NSString stringWithFormat:@"%@@facebook.com", uId];
                                                }
                                                if (IS_NOT_NULL(result, @"picture")) {
                                                    NSDictionary* picture = GET_VALUE_OBJECT(result, @"picture");
                                                    if (picture && [picture isKindOfClass:[NSDictionary class]]) {
                                                        if (IS_NOT_NULL(picture, @"data")) {
                                                            NSDictionary* picData = GET_VALUE_OBJECT(picture, @"data");
                                                            if (picData && [picData isKindOfClass:[NSDictionary class]]) {
                                                                if (IS_NOT_NULL(picData, @"url")) {
                                                                    userImagePath = GET_VALUE_STR(picData, @"url");
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                            if(![userName isEqualToString:@""] && ![userImagePath isEqualToString:@""] && ![userEmailId isEqualToString:@""]){
                                                LoginFlow* lf = [LoginFlow sharedManager];
                                                NSMutableDictionary* dataDictionary = [[NSMutableDictionary alloc] init];
                                                [dataDictionary setObject:@"" forKey:@"password"];
                                                [dataDictionary setObject:userName forKey:@"name"];
                                                [dataDictionary setObject:firstName forKey:@"first_name"];
                                                [dataDictionary setObject:lastName forKey:@"last_name"];
                                                [dataDictionary setObject:userImagePath forKey:@"image"];
                                                [dataDictionary setObject:userEmailId forKey:@"email"];
                                                [dataDictionary setObject:SA_PROVIDERS_NAME[SA_PROVIDERS_FACEBOOK] forKey:@"provider"];
                                                [[NSNotificationCenter defaultCenter] postNotificationName:@"response_login_clicked" object:dataDictionary];
                                            }else {
                                                [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
                                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Localize(@"login_failed") message:Localize(@"insufficient_data") delegate:self cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil];
                                                [alert show];
                                            }
                                        }];
                                    } else {
                                        RLOG(@"FB TOKEN NOT FOUND");
                                        [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
                                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Localize(@"sorry") message:Localize(@"try_again") delegate:self cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil];
                                        [alert show];
                                    }
                                }
                            }];
#endif
    return;
    
    
    
    
    
    
    
    //    BOOL isInstalled = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fb://"]];
    //    if (isInstalled) {
    //#if ENABLE_SIMPLEAUTH
    //        [[LoginFlow sharedManager] clickOnSimpleAuthItem:SA_PROVIDERS_FACEBOOK];
    //#endif
    //    } else {
    //        [self cancelClicked:nil];
    //#if ENABLE_SIMPLEAUTH
    //        [[LoginFlow sharedManager] clickOnSimpleAuthItem:SA_PROVIDERS_FACEBOOK_WEB];
    //#endif
    //    }
}
- (void)googleClicked:(UIButton*)button {
    if ([[Utility sharedManager] checkForDemoApp:true]) return;
#if NEW_LOGIN_ISSUE
    LoginFlow* lf = [LoginFlow sharedManager];
    [lf responseLogoutClicked:nil];
#endif
    [self cancelClicked:nil];
    [[GIDSignIn sharedInstance] signIn];
    //    [[LoginFlow sharedManager] clickOnSimpleAuthItem:SA_PROVIDERS_GOOGLE_WEB];
}
- (void)twitterClicked:(UIButton*)button {
    if ([[Utility sharedManager] checkForDemoApp:true]) return;
#if NEW_LOGIN_ISSUE
    LoginFlow* lf = [LoginFlow sharedManager];
    [lf responseLogoutClicked:nil];
#endif
    [self cancelClicked:nil];
    [[Twitter sharedInstance] logInWithCompletion:^(TWTRSession *session, NSError *error) {
        [MRProgressOverlayView showOverlayAddedTo:[[UIApplication sharedApplication] keyWindow] title:@"" mode:MRProgressOverlayViewModeIndeterminateSmallDefault animated:YES];
        if (session) {
            RLOG(@"signed in as %@", [session userName]);
            [[[TWTRAPIClient alloc] initWithUserID:[session userID]] loadUserWithID:[session userID] completion:^(TWTRUser * _Nullable user, NSError * _Nullable error) {
                if (error) {
                    [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Localize(@"sorry") message:[error description] delegate:self cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil];
                    [alert show];
                    return;
                } else {
                    __block NSString* uid = user.userID;
                    __block NSString* userImagePath = user.profileImageMiniURL;
                    __block NSString* userName = user.name;
                    __block NSString* firstName = user.screenName;
                    __block NSString* lastName = @"";
                    __block NSString* userEmailId = @"";
                    
                    TWTRAPIClient *client = [TWTRAPIClient clientWithCurrentUser];
                    [client requestEmailForCurrentUser:^(NSString *email, NSError *error) {
                        if (email) {
                            RLOG(@"signed in as %@", email);
                            userEmailId = email;
                        } else {
                            RLOG(@"error: %@", [error localizedDescription]);
                        }
                        if([userEmailId isEqualToString:@""]){
                            userEmailId = [NSString stringWithFormat:@"%@@twitter.com", uid];
                        }
                        
                        if(![userName isEqualToString:@""] && ![userImagePath isEqualToString:@""] && ![userEmailId isEqualToString:@""]) {
                            LoginFlow* lf = [LoginFlow sharedManager];
                            RLOG(@"Sufficient data received.");
                            NSMutableDictionary* dataDictionary = [[NSMutableDictionary alloc] init];
                            [dataDictionary setObject:@"" forKey:@"password"];
                            [dataDictionary setObject:userName forKey:@"name"];
                            [dataDictionary setObject:firstName forKey:@"first_name"];
                            [dataDictionary setObject:lastName forKey:@"last_name"];
                            [dataDictionary setObject:userImagePath forKey:@"image"];
                            [dataDictionary setObject:userEmailId forKey:@"email"];
                            [dataDictionary setObject:SA_PROVIDERS_NAME[SA_PROVIDERS_TWITTER] forKey:@"provider"];
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"response_login_clicked" object:dataDictionary];
                        } else {
                            [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Localize(@"login_failed") message:Localize(@"insufficient_data") delegate:self cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil];
                            [alert show];
                        }
                    }];
                }
            }];
        } else {
            RLOG(@"error: %@", [error localizedDescription]);
            [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Localize(@"sorry") message:[error description] delegate:self cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil];
            [alert show];
            return;
        }
    }];
    
    
    
    //    BOOL isInstalled = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]];
    //    if (isInstalled) {
    //#if ENABLE_SIMPLEAUTH
    //        [[LoginFlow sharedManager] clickOnSimpleAuthItem:SA_PROVIDERS_TWITTER];
    //#endif
    //    } else {
    //        [self cancelClicked:nil];
    //#if ENABLE_SIMPLEAUTH
    //        [[LoginFlow sharedManager] clickOnSimpleAuthItem:SA_PROVIDERS_TWITTER_WEB];
    //#endif
    //    }
}
- (void)cancelClicked:(id)sender {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    if (self.popupController) {
        [self.popupController dismissPopupControllerAnimated:YES];
    }
    if (self.popupControllerRegister) {
        [self.popupControllerRegister dismissPopupControllerAnimated:YES];
    }
    if (self.popupControllerForgotPassword) {
        [self.popupControllerForgotPassword dismissPopupControllerAnimated:YES];
    }
    if (self.popupControllerRegisterAsSeller) {
        [self.popupControllerRegisterAsSeller dismissPopupControllerAnimated:YES];
    }
}
- (void)fillDataInPopup {
    
}
- (UILabel*)createLabel:(UIView*)parentView fontType:(int)fontType fontColorType:(int)fontColorType frame:(CGRect)frame textStr:(NSString*)textStr {
    UILabel* label = [[UILabel alloc] init];
    if (CGRectEqualToRect(frame, CGRectMake(0, 0, 0, 0))) {
        frame = parentView.frame;
    }
    [label setUIFont:fontType isBold:false];
    [label setTextColor:[Utility getUIColor:fontColorType]];
    [label setFrame:frame];
    [label setText:textStr];
    [parentView addSubview:label];
    return label;
}
- (UITextField*)createTextField:(UIView*)parentView fontType:(int)fontType fontColorType:(int)fontColorType frame:(CGRect)frame tag:(int)tag textStrPlaceHolder:(NSString*)textStrPlaceHolder {
    if (CGRectEqualToRect(frame, CGRectMake(0, 0, 0, 0))) {
        frame = parentView.frame;
    }
    if ([[MyDevice sharedManager] isIphone]) {
        fontType--;
    }
    
    UITextField *textField = [[UITextField alloc] initWithFrame:frame];
    textField.placeholder = textStrPlaceHolder;
    textField.backgroundColor = [UIColor whiteColor];
    textField.textColor = [Utility getUIColor:fontColorType];
    textField.layer.borderWidth = 1;
    textField.layer.borderColor =  [[Utility sharedManager] getTextFieldBorderColor].CGColor;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.returnKeyType = UIReturnKeyDone;
    textField.textAlignment = NSTextAlignmentLeft;
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.tag = tag;
    textField.delegate = self;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [textField setUIFont:fontType isBold:false];
    [parentView addSubview:textField];
    
    UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        [textField setRightViewMode:UITextFieldViewModeAlways];
        [textField setRightView:spacerView];
    } else {
        [textField setLeftViewMode:UITextFieldViewModeAlways];
        [textField setLeftView:spacerView];
    }
    return textField;
}
- (UITextView*)createTextView:(UIView*)parentView fontType:(int)fontType fontColorType:(int)fontColorType frame:(CGRect)frame tag:(int)tag textStrPlaceHolder:(NSString*)textStrPlaceHolder textView:(UITextView*)textView {
    if (CGRectEqualToRect(frame, CGRectMake(0, 0, 0, 0))) {
        frame = parentView.frame;
    }
    if (textView == nil) {
        textView = [[UITextView alloc] init];
    }
    textView.frame = frame;
    textView.backgroundColor = [UIColor clearColor];
    textView.textColor = [Utility getUIColor:fontColorType];
    if ([[MyDevice sharedManager] isIphone]) {
        fontType--;
    }
    textView.layer.borderWidth = 1;
    textView.layer.borderColor = [[Utility sharedManager] getTextFieldBorderColor].CGColor;
    textView.textAlignment = NSTextAlignmentLeft;
    textView.tag = tag;
    textView.delegate = self;
    [textView setUIFont:fontType isBold:false];
    [parentView addSubview:textView];
    [textView setTextContainerInset:UIEdgeInsetsMake(5, 5, 5, 5)];
    return textView;
}
- (void)updateViews {
    
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
- (void)showErrorAlert {
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"" message:Localize(@"i_field_compulsary") delegate:nil cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil, nil];
    [errorAlert show];
}
#pragma mark - CNPPopupController Delegate
- (void)popupController:(CNPPopupController *)controller didDismissWithButtonTitle:(NSString *)title {
    RLOG(@"Dismissed with button title: %@", title);
}
- (void)popupControllerDidPresent:(CNPPopupController *)controller {
    RLOG(@"Popup controller presented.");
}

- (void)resetPasswordSentSuccess:(NSNotification *)notification{
    
    [self showLoginPopup:false];
    [self.popupControllerForgotPassword dismissPopupControllerAnimated:YES];
    
    //    if (self.popupController) {
    //        [self.popupController dismissPopupControllerAnimated:YES];
    //    }
    //    if (self.popupControllerRegister) {
    //        [self.popupControllerRegister dismissPopupControllerAnimated:YES];
    //    }
    //    if (self.popupControllerForgotPassword) {
    //        [self.popupControllerForgotPassword dismissPopupControllerAnimated:YES];
    //    }
}
- (void)loggedIn:(NSNotification *)notification{
    AppUser* appuser = [AppUser sharedManager];
    appuser._isUserLoggedIn = true;
    if (self.popupController) {
        [self.popupController dismissPopupControllerAnimated:YES];
    }
    if (self.popupControllerRegister) {
        [self.popupControllerRegister dismissPopupControllerAnimated:YES];
    }
    if (self.popupControllerForgotPassword) {
        [self.popupControllerForgotPassword dismissPopupControllerAnimated:YES];
    }
    if (self.popupControllerRegisterAsSeller) {
        [self.popupControllerRegisterAsSeller dismissPopupControllerAnimated:YES];
    }
    
    [self.dataObjects removeAllObjects];
    [self loadData];
    [self adjustViewsAfterOrientation:0];
    //    [tableView setUserInteractionEnabled:false];
    
    if ([[GuestConfig sharedInstance] hide_price] || [[Addons sharedManager] hide_price]) {
        ViewControllerMain* mainVC = [ViewControllerMain getInstance];
        [mainVC resetPreviousState];
    }
    
    [appuser saveData];
#if ENABLE_FIREBASE_TAG_MANAGER
    [[AnalyticsHelper sharedInstance] registerSignInEvent];
#endif
    
    
    [self removeVC];
}
- (void)loggedOut{
    [LoginFlow sharedManager];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"response_logout_clicked" object:nil];
    AppUser* appuser = [AppUser sharedManager];
    if (_textLoginId)
        _textLoginId.text = @"";
    if (_textLoginPassword)
        _textLoginPassword.text = @"";
    
    if (_textRegisterUsername)
        _textRegisterUsername.text = @"";
    if (_textRegisterPassword)
        _textRegisterPassword.text = @"";
    if (_textRegisterEmailId)
        _textRegisterEmailId.text = @"";
    if (_textRegisterMobileNumber)
        _textRegisterMobileNumber.text = @"";
    if (_textRegisterConfirmPassword)
        _textRegisterConfirmPassword.text = @"";
    
    if (_textRegisterAsSellerUsername)
        _textRegisterAsSellerUsername.text = @"";
    if (_textRegisterAsSellerPassword)
        _textRegisterAsSellerPassword.text = @"";
    if (_textRegisterAsSellerConfirmPassword)
        _textRegisterAsSellerConfirmPassword.text = @"";
    if (_textRegisterAsSellerEmailId)
        _textRegisterAsSellerEmailId.text = @"";
    if (_textRegisterAsSellerMobileNumber)
        _textRegisterAsSellerMobileNumber.text = @"";
    if (_textRegisterAsSellerCompanyName)
        _textRegisterAsSellerCompanyName.text = @"";
    if (_textRegisterAsSellerFirstName)
        _textRegisterAsSellerFirstName.text = @"";
    if (_textRegisterAsSellerLastName)
        _textRegisterAsSellerLastName.text = @"";
    
    if (_textForgotPasswordEmailId)
        _textForgotPasswordEmailId.text = @"";
    
    DataManager* dm = [DataManager sharedManager];
    dm.isShowLoginPopUpHomeScreen = false;
    [appuser clearData];
    [appuser resetUserRole];
    [[ParseHelper sharedManager] proceedSignOut];
    [appuser saveData];
    [self.dataObjects removeAllObjects];
    [self loadData];
    [self adjustViewsAfterOrientation:0];
    
    ViewControllerMain* mainVC = [ViewControllerMain getInstance];
    if (self.isMyAccountScreen) {
        ViewControllerLeft* leftVC = (ViewControllerLeft*)(mainVC.revealController.rearViewController);
        if (leftVC) {
            [leftVC loggedOut];
        }
    } else {
        [mainVC btnClickedHome:nil];
    }
    
#if ENABLE_USER_ROLE
    [ViewControllerMain resetInstance];
    [Utility resetStoryBoardObject];
    [AppUser clearFullAppData:true];
    [appuser saveData];
    UIStoryboard *sb = [Utility getStoryBoardObject];
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"APPDATA_PLATFORM"];
    ViewControllerSplashPrimary *rootViewController = [sb instantiateViewControllerWithIdentifier:VC_SPLASH_PRIMARY];
    [[UIApplication sharedApplication].keyWindow setRootViewController:rootViewController];
#endif
    [SellerInfo setCurrentSeller:nil];
    [self removeVC];
}
- (void)dataFetchCompletion:(ServerData *)serverData{
    [[LoginFlow sharedManager] dataFetchCompletion:serverData];
}
- (void)createRegisterPopupNew {
    if (self.popupControllerRegisterAsSeller == nil) {
        DataManager* dm = [DataManager sharedManager];
        int totalSocialAuthItems = 0;
        float widthView = [[MyDevice sharedManager] screenSize].width - [[MyDevice sharedManager] screenSize].width * 0.1f;
        float heightView = [[MyDevice sharedManager] screenSize].height - [[MyDevice sharedManager] screenSize].width * 0.1f;
        if ([[MyDevice sharedManager] isIpad]) {
            widthView = [[MyDevice sharedManager] screenWidthInPortrait] * 0.65f;
            heightView = [[MyDevice sharedManager] screenHeightInPortrait] * 0.63f;
        } else if ([[MyDevice sharedManager] isIphone]) {
            widthView = [[MyDevice sharedManager] screenSize].width * 0.96f;
            heightView = [[MyDevice sharedManager] screenSize].height * 0.70f;
        }
        UIView* viewMain = [[UIView alloc] initWithFrame:CGRectMake(0, 0, widthView, heightView)];
        viewMain.backgroundColor = [Utility getUIColor:kUIColorBgTheme];
        _mainViewRegisterAsSeller = viewMain;
        UIView* viewTop = [[UIView alloc] initWithFrame:CGRectMake(0, 0, widthView, heightView * 0.05f)];
        viewTop.backgroundColor = [UIColor whiteColor];
        [viewMain addSubview:viewTop];
        self.popupControllerRegisterAsSeller = [[CNPPopupController alloc] initWithContents:@[viewMain]];
        self.popupControllerRegisterAsSeller.theme = [CNPPopupTheme addressTheme];
        self.popupControllerRegisterAsSeller.theme.popupStyle = CNPPopupStyleCentered;
        self.popupControllerRegisterAsSeller.theme.size = CGSizeMake(widthView, heightView);
        self.popupControllerRegisterAsSeller.theme.maxPopupWidth = widthView;
        self.popupControllerRegisterAsSeller.delegate = self;
        [self setShouldDismissOnBackgroundTouch:self.popupControllerRegisterAsSeller];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            self.popupControllerRegisterAsSeller.VIEW_POPUP.transform = CGAffineTransformMakeScale(-1, 1);
        }
        
        UIButton* _buttonCancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, viewTop.frame.size.width, viewTop.frame.size.height)];
        [_buttonCancel setTintColor:[Utility getUIColor:kUIColorThemeFont]];
        [viewTop addSubview:_buttonCancel];
        [_buttonCancel addTarget:self action:@selector(cancelClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_buttonCancel sizeToFit];
        [_buttonCancel setFrame:CGRectMake(viewTop.frame.size.width * 0.04f, 0, _buttonCancel.frame.size.width, viewTop.frame.size.height)];
        
        UILabel* _labelTitle = [self createLabel:viewTop fontType:kUIFontType20 fontColorType:kUIColorFontDark frame:CGRectMake(0, -16, viewTop.frame.size.width, viewTop.frame.size.height + 16) textStr:Localize(@"action_sign_up_title")];
        [_labelTitle setTextAlignment:NSTextAlignmentCenter];
        
        
        float posY = CGRectGetMaxY(viewTop.frame) + viewMain.frame.size.width * 0.05f;
        float width = viewMain.frame.size.width * 0.70f;
        float posX = (viewMain.frame.size.width - width)/2;
        float height = (viewMain.frame.size.height - (posY - viewTop.frame.size.height) - posY)/9;
#if ENABLE_OTP_LOGIN
        if([[Addons sharedManager] show_mobile_number_in_signup] || 1) {
            height = (viewMain.frame.size.height - (posY - viewTop.frame.size.height) - posY)/11.0f;
        }
#endif
        float gap = height/5;
        
        _textRegisterAsSellerUsername = [self createTextField:viewMain fontType:kUIFontType18 fontColorType:kUIColorFontLight frame:CGRectMake(posX, posY, width, height) tag:_kTAGTEXTFIELD_R_USERNAME textStrPlaceHolder:Localize(@" * Enter Username")];
#if REGISTRATION_HIDE_USERNAME
        _textRegisterAsSellerUsername.hidden = true;
#else
        posY += (height+gap);
#endif
        
        _textRegisterAsSellerEmailId = [self createTextField:viewMain fontType:kUIFontType18 fontColorType:kUIColorFontLight frame:CGRectMake(posX, posY, width, height) tag:_kTAGTEXTFIELD_R_EMAIL textStrPlaceHolder:Localize(@"email")];
        posY += (height+gap);
        
        _textRegisterAsSellerPassword = [self createTextField:viewMain fontType:kUIFontType18 fontColorType:kUIColorFontLight frame:CGRectMake(posX, posY, width, height) tag:_kTAGTEXTFIELD_R_PASSWORD textStrPlaceHolder:Localize(@"prompt_password")];
        posY += (height+gap);
        
        _textRegisterAsSellerConfirmPassword = [self createTextField:viewMain fontType:kUIFontType18 fontColorType:kUIColorFontLight frame:CGRectMake(posX, posY, width, height) tag:_kTAGTEXTFIELD_R_CPASSWORD textStrPlaceHolder:Localize(@"prompt_password_confirm")];
        posY += (height+gap);
        
        [_textRegisterAsSellerPassword setSecureTextEntry:YES];
        [_textRegisterAsSellerConfirmPassword setSecureTextEntry:YES];
        
        
        _textRegisterAsSellerFirstName = [self createTextField:viewMain fontType:kUIFontType18 fontColorType:kUIColorFontLight frame:CGRectMake(posX, posY, width, height) tag:_kTAGTEXTFIELD_R_FIRST_NAME textStrPlaceHolder:Localize(@"first_name")];
        posY += (height+gap);
        
        _textRegisterAsSellerLastName = [self createTextField:viewMain fontType:kUIFontType18 fontColorType:kUIColorFontLight frame:CGRectMake(posX, posY, width, height) tag:_kTAGTEXTFIELD_R_LAST_NAME textStrPlaceHolder:Localize(@"last_name")];
        posY += (height+gap);
        
        _textRegisterAsSellerCompanyName = [self createTextField:viewMain fontType:kUIFontType18 fontColorType:kUIColorFontLight frame:CGRectMake(posX, posY, width, height) tag:_kTAGTEXTFIELD_R_COMPANY_NAME textStrPlaceHolder:Localize(@"company_name")];
        posY += (height+gap);
        
        
#if REGISTRATION_HIDE_USERNAME
        if([[Addons sharedManager] show_mobile_number_in_signup] || 1) {
            _textRegisterAsSellerMobileNumber = [self createTextField:viewMain fontType:kUIFontType18 fontColorType:kUIColorFontLight frame:CGRectMake(posX, posY, width, height) tag:_kTAGTEXTFIELD_R_MOBILE_NUMBER textStrPlaceHolder:Localize(@"hint_mobile_number")];
            posY += (height+gap);
        }
#endif
        UIButton* buttonRegister = [[UIButton alloc] initWithFrame:CGRectMake(posX, posY, width, height)];
        [buttonRegister setBackgroundColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
        [[buttonRegister titleLabel] setUIFont:kUIFontType22 isBold:false];
        [buttonRegister setTitle:Localize(@"action_sign_up_short") forState:UIControlStateNormal];
        [buttonRegister setTitleColor:[Utility getUIColor:kUIColorBuyButtonFont] forState:UIControlStateNormal];
        [viewMain addSubview:buttonRegister];
        [buttonRegister addTarget:self action:@selector(registerClickedAsVendor:) forControlEvents:UIControlEventTouchUpInside];
        posY += (height);
        //////////////////////////
        UIButton* _buttonClickHere = [[UIButton alloc] initWithFrame:CGRectMake(posX, posY, width, height)];
        [[_buttonClickHere titleLabel] setUIFont:kUIFontType18 isBold:false];
        [_buttonClickHere setTitleColor:[Utility getUIColor:kUIColorBlue] forState:UIControlStateNormal];
        [viewMain addSubview:_buttonClickHere];
        [_buttonClickHere addTarget:self action:@selector(registerBackClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_buttonClickHere setTitle:Localize(@"sign_in_here") forState:UIControlStateNormal];
        float buttonw1 = LABEL_SIZE([_buttonClickHere titleLabel]).width;
        CGRect br1 = _buttonClickHere.frame;
        br1.origin.x = widthView * 0.10f;
        br1.size.width = buttonw1;
        [_buttonClickHere setFrame:br1];
        UILabel *faltuText = [[UILabel alloc] init];
        [faltuText setUIFont:kUIFontType18 isBold:false];
        faltuText.text = Localize(@"already_have_account");
        faltuText.textColor = [Utility getUIColor:kUIColorFontLight];
        [faltuText sizeToFitUI];
        [viewMain addSubview:faltuText];
        CGRect rectCreateBtn = _buttonClickHere.frame;
        CGRect rectTextDesc = faltuText.frame;
        float totalWidth = rectTextDesc.size.width + rectCreateBtn.size.width;
        float totalViewWidth = viewMain.frame.size.width;
        float startX = (totalViewWidth - totalWidth)/2;
        rectTextDesc.origin.x = startX;
        rectTextDesc.origin.y = rectCreateBtn.origin.y;
        rectTextDesc.size.height =rectCreateBtn.size.height;
        rectCreateBtn.origin.x = CGRectGetMaxX(rectTextDesc);
        _buttonClickHere.frame = rectCreateBtn;
        faltuText.frame = rectTextDesc;
#if (NEW_CHU)
        UIImage * img =  [UIImage imageNamed:@"Icon"];
        [_buttonCancel setUIImage:img forState:UIControlStateDisabled];
        [_buttonCancel.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_buttonCancel setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [_buttonCancel setAdjustsImageWhenDisabled:true];
        [_buttonCancel setEnabled:false];
        float viewH = viewTop.frame.size.height + 16;
        float viewW = (img.size.width/img.size.height) * viewH;
        [_buttonCancel setFrame:CGRectMake(16, -16, viewW, viewH)];
        [_buttonCancel setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
#endif
    }
}


- (void)createRegisterPopup {
    if (self.popupControllerRegister == nil) {
        DataManager* dm = [DataManager sharedManager];
        BOOL isFBExists = ([dm.keyFacebookAppId isEqualToString:@""] || [dm.keyFacebookConsumerSecret isEqualToString:@""]) ? false : true;
        BOOL isGoogleExists = ([dm.keyGoogleClientId isEqualToString:@""] || [dm.keyGoogleClientSecret isEqualToString:@""]) ? false : true;
        BOOL isTwitterExists = ([dm.keyTwitterConsumerKey isEqualToString:@""] || [dm.keyTwitterConsumerSecret isEqualToString:@""]) ? false : true;
        int totalSocialAuthItems = 0;
        if (isFBExists) {
            totalSocialAuthItems++;
        }
        if (isGoogleExists) {
            totalSocialAuthItems++;
        }
        if (isTwitterExists) {
            totalSocialAuthItems++;
        }
        float widthView = [[MyDevice sharedManager] screenSize].width - [[MyDevice sharedManager] screenSize].width * 0.1f;
        float heightView = [[MyDevice sharedManager] screenSize].height - [[MyDevice sharedManager] screenSize].width * 0.1f;
        
        if ([[MyDevice sharedManager] isIpad]) {
            widthView = [[MyDevice sharedManager] screenWidthInPortrait] * 0.65f;
            heightView = [[MyDevice sharedManager] screenHeightInPortrait] * 0.63f;
        } else if ([[MyDevice sharedManager] isIphone]) {
            widthView = [[MyDevice sharedManager] screenSize].width * 0.96f;
            heightView = [[MyDevice sharedManager] screenSize].height * 0.70f;
        }
        UIView* viewMain = [[UIView alloc] initWithFrame:CGRectMake(0, 0, widthView, heightView)];
        viewMain.backgroundColor = [Utility getUIColor:kUIColorBgTheme];
        _mainViewRegister = viewMain;
        
        UIView* viewTop = [[UIView alloc] initWithFrame:CGRectMake(0, 0, widthView, heightView * 0.05f)];
        viewTop.backgroundColor = [UIColor whiteColor];
        [viewMain addSubview:viewTop];
        
        self.popupControllerRegister = [[CNPPopupController alloc] initWithContents:@[viewMain]];
        self.popupControllerRegister.theme = [CNPPopupTheme addressTheme];
        self.popupControllerRegister.theme.popupStyle = CNPPopupStyleCentered;
        self.popupControllerRegister.theme.size = CGSizeMake(widthView, heightView);
        self.popupControllerRegister.theme.maxPopupWidth = widthView;
        self.popupControllerRegister.delegate = self;
        [self setShouldDismissOnBackgroundTouch:self.popupControllerRegister];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            self.popupControllerRegister.VIEW_POPUP.transform = CGAffineTransformMakeScale(-1, 1);
        }
        UIButton* _buttonCancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, viewTop.frame.size.width, viewTop.frame.size.height)];
        [_buttonCancel setTintColor:[Utility getUIColor:kUIColorThemeFont]];
        [viewTop addSubview:_buttonCancel];
        [_buttonCancel addTarget:self action:@selector(cancelClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_buttonCancel sizeToFit];
        [_buttonCancel setFrame:CGRectMake(viewTop.frame.size.width * 0.04f, 0, _buttonCancel.frame.size.width, viewTop.frame.size.height)];
        UILabel* _labelTitle = [self createLabel:viewTop fontType:kUIFontType20 fontColorType:kUIColorFontDark frame:CGRectMake(0, -16, viewTop.frame.size.width, viewTop.frame.size.height + 16) textStr:Localize(@"action_sign_up_title")];
        [_labelTitle setTextAlignment:NSTextAlignmentCenter];
        float posY = CGRectGetMaxY(viewTop.frame) + viewMain.frame.size.width * 0.05f;
        float width = viewMain.frame.size.width * 0.70f;
        float posX = (viewMain.frame.size.width - width)/2;
#if REGISTRATION_HIDE_USERNAME
        float height = (viewMain.frame.size.height - (posY - viewTop.frame.size.height) - posY)/9;
#if ENABLE_OTP_LOGIN
        if([[Addons sharedManager] show_mobile_number_in_signup]) {
            height = (viewMain.frame.size.height - (posY - viewTop.frame.size.height) - posY)/11.0f;
        }
#endif
#else
        float height = (viewMain.frame.size.height - (posY - viewTop.frame.size.height) - posY)/10.0f;
#endif
        float gap = height/4;
        if (totalSocialAuthItems == 0) {
            posY += (heightView * (1.0f - 0.63f) / 4);
        }
        _textRegisterUsername = [self createTextField:viewMain fontType:kUIFontType18 fontColorType:kUIColorFontLight frame:CGRectMake(posX, posY, width, height) tag:_kTAGTEXTFIELD_R_USERNAME textStrPlaceHolder:Localize(@" * Enter Username")];
#if REGISTRATION_HIDE_USERNAME
        _textRegisterUsername.hidden = true;
#else
        posY += (height+gap);
#endif
        
        _textRegisterEmailId = [self createTextField:viewMain fontType:kUIFontType18 fontColorType:kUIColorFontLight frame:CGRectMake(posX, posY, width, height) tag:_kTAGTEXTFIELD_R_EMAIL textStrPlaceHolder:Localize(@"email")];
        posY += (height+gap);
        
        _textRegisterPassword = [self createTextField:viewMain fontType:kUIFontType18 fontColorType:kUIColorFontLight frame:CGRectMake(posX, posY, width, height) tag:_kTAGTEXTFIELD_R_PASSWORD textStrPlaceHolder:Localize(@"prompt_password")];
        posY += (height+gap);
        
        _textRegisterConfirmPassword = [self createTextField:viewMain fontType:kUIFontType18 fontColorType:kUIColorFontLight frame:CGRectMake(posX, posY, width, height) tag:_kTAGTEXTFIELD_R_CPASSWORD textStrPlaceHolder:Localize(@"prompt_password_confirm")];
        posY += (height+gap);
        
        [_textRegisterPassword setSecureTextEntry:YES];
        [_textRegisterConfirmPassword setSecureTextEntry:YES];
        
#if REGISTRATION_HIDE_USERNAME
        if([[Addons sharedManager] show_mobile_number_in_signup]) {
            _textRegisterMobileNumber = [self createTextField:viewMain fontType:kUIFontType18 fontColorType:kUIColorFontLight frame:CGRectMake(posX, posY, width, height) tag:_kTAGTEXTFIELD_R_MOBILE_NUMBER textStrPlaceHolder:Localize(@"hint_mobile_number")];
            posY += (height+gap);
        }
#endif
        UIButton *buttonRegister = [[UIButton alloc] initWithFrame:CGRectMake(posX, posY, width, height)];
        [buttonRegister setBackgroundColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
        [[buttonRegister titleLabel] setUIFont:kUIFontType22 isBold:false];
        [buttonRegister setTitle:Localize(@"action_sign_up_short") forState:UIControlStateNormal];
        [buttonRegister setTitleColor:[Utility getUIColor:kUIColorBuyButtonFont] forState:UIControlStateNormal];
        [viewMain addSubview:buttonRegister];
        [buttonRegister addTarget:self action:@selector(registerClicked:) forControlEvents:UIControlEventTouchUpInside];
        //        posY += (height+gap);
        posY += (height);
        //////////////////////////
        UIButton* _buttonClickHere = [[UIButton alloc] initWithFrame:CGRectMake(posX, posY, width, height)];
        [[_buttonClickHere titleLabel] setUIFont:kUIFontType18 isBold:false];
        [_buttonClickHere setTitleColor:[Utility getUIColor:kUIColorBlue] forState:UIControlStateNormal];
        [viewMain addSubview:_buttonClickHere];
        [_buttonClickHere addTarget:self action:@selector(registerBackClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_buttonClickHere setTitle:Localize(@"sign_in_here") forState:UIControlStateNormal];
        float buttonw1 = LABEL_SIZE([_buttonClickHere titleLabel]).width;
        CGRect br1 = _buttonClickHere.frame;
        br1.origin.x = widthView * 0.10f;
        br1.size.width = buttonw1;
        [_buttonClickHere setFrame:br1];
        UILabel *faltuText = [[UILabel alloc] init];
        [faltuText setUIFont:kUIFontType18 isBold:false];
        faltuText.text = Localize(@"already_have_account");
        faltuText.textColor = [Utility getUIColor:kUIColorFontLight];
        [faltuText sizeToFitUI];
        [viewMain addSubview:faltuText];
        CGRect rectCreateBtn = _buttonClickHere.frame;
        CGRect rectTextDesc = faltuText.frame;
        float totalWidth = rectTextDesc.size.width + rectCreateBtn.size.width;
        float totalViewWidth = viewMain.frame.size.width;
        float startX = (totalViewWidth - totalWidth)/2;
        rectTextDesc.origin.x = startX;
        rectTextDesc.origin.y = rectCreateBtn.origin.y;
        rectTextDesc.size.height = faltuText.frame.size.height + gap;//rectCreateBtn.size.height;
        rectCreateBtn.size.height = faltuText.frame.size.height + gap;
        rectCreateBtn.origin.x = CGRectGetMaxX(rectTextDesc);
        _buttonClickHere.frame = rectCreateBtn;
        faltuText.frame = rectTextDesc;
        ///////////////////
        posY = CGRectGetMaxY(faltuText.frame);
        
        self.buttonRegisterAsVendor = [[UIButton alloc] initWithFrame:CGRectMake(posX, posY, width, height*.75f)];
        [self.buttonRegisterAsVendor.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [self.buttonRegisterAsVendor setImage:[[UIImage imageNamed:@"managing_icon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [self.buttonRegisterAsVendor setTitleColor:[Utility getUIColor:kUIColorBlue] forState:UIControlStateNormal];
        [[self.buttonRegisterAsVendor titleLabel] setUIFont:kUIFontType18 isBold:false];
        if([[Addons sharedManager] multiVendor] && [[[Addons sharedManager] multiVendor] isEnabled] && [[Addons sharedManager] multiVendor_screen_type] == MULTIVENDOR_SCREEN_PRODUCT) {
            [viewMain addSubview:self.buttonRegisterAsVendor];
        }
        [self.buttonRegisterAsVendor addTarget:self action:@selector(registerAsVendor:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttonRegisterAsVendor setTitle:Localize(@"Register as Vendor") forState:UIControlStateNormal];
        
        
        
        
        //////////////////////////
        //        posY = heightView * .63f;
        posY = heightView * .68f;
        gap = height/3;
        UIView *bottomBorder = [[UIView alloc] init];
        bottomBorder.frame = CGRectMake(0, posY, viewMain.frame.size.width, 2);
        bottomBorder.backgroundColor = [Utility getUIColor:kUIColorBorder];
        [viewMain addSubview:bottomBorder];
        
        UILabel* _labelGyan = [self createLabel:viewMain fontType:kUIFontType14 fontColorType:kUIColorFontLight frame:CGRectMake(0, posY, viewMain.frame.size.width, height) textStr:Localize(@"sign_in_1_click")];
        [_labelGyan setTextAlignment:NSTextAlignmentCenter];
        posY += (height * .75f);
        
        _fbLoginButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [_fbLoginButton setUIImage:[UIImage imageNamed:@"facebookLogin.png"] forState:UIControlStateNormal];
        [[_fbLoginButton imageView] setContentMode: UIViewContentModeScaleAspectFit];
        [_fbLoginButton addTarget:self action:@selector(fbClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        _googleLoginButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [_googleLoginButton setUIImage:[UIImage imageNamed:@"googleLogin.png"] forState:UIControlStateNormal];
        [[_googleLoginButton imageView] setContentMode: UIViewContentModeScaleAspectFit];
        [_googleLoginButton addTarget:self action:@selector(googleClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        
        _twitterLoginButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [_twitterLoginButton setUIImage:[UIImage imageNamed:@"twitterLogin.png"] forState:UIControlStateNormal];
        [[_twitterLoginButton imageView] setContentMode: UIViewContentModeScaleAspectFit];
        [_twitterLoginButton addTarget:self action:@selector(twitterClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        
        _fbLoginButton.hidden = !false;
        _googleLoginButton.hidden = !false;
        _twitterLoginButton.hidden = !false;
        if (isFBExists) {
            _fbLoginButton.hidden = !true;
        }
        if (isGoogleExists) {
            _googleLoginButton.hidden = !true;
        }
        if (isTwitterExists) {
            _twitterLoginButton.hidden = !true;
        }
        switch (totalSocialAuthItems) {
            case 0:
                _labelGyan.hidden = true;
                bottomBorder.hidden = true;
                break;
            case 1:
            {
                CGRect rect = CGRectMake((viewMain.frame.size.width - viewMain.frame.size.width * .45f) / 2, posY+gap, viewMain.frame.size.width * .45f, height);
                _registerScreenRectFB = rect;
                _registerScreenRectGoogle = rect;
                _registerScreenRectTwitter = rect;
            } break;
            case 2:
            {
                CGRect rect1 = CGRectMake(viewMain.frame.size.width * .05f, posY+gap, viewMain.frame.size.width * .45f, height);
                CGRect rect2 = CGRectMake(viewMain.frame.size.width * .50f, posY+gap, viewMain.frame.size.width * .45f, height);
                if (isFBExists) {
                    _registerScreenRectFB = rect1;
                    rect1 = rect2;
                }
                if (isGoogleExists) {
                    _registerScreenRectGoogle = rect1;
                    rect1 = rect2;
                }
                if (isTwitterExists) {
                    _registerScreenRectTwitter = rect1;
                    rect1 = rect2;
                }
            } break;
            case 3:
                _registerScreenRectFB = CGRectMake(viewMain.frame.size.width * .05f, posY, viewMain.frame.size.width * .45f, height);
                _registerScreenRectGoogle = CGRectMake(viewMain.frame.size.width * .50f, posY, viewMain.frame.size.width * .45f, height);
                posY += height;
                _registerScreenRectTwitter = CGRectMake((viewMain.frame.size.width - viewMain.frame.size.width * .45f) / 2, posY, viewMain.frame.size.width * .45f, height);
                posY += height;
                break;
                
            default:
                break;
        }
        
#if (NEW_CHU)
        UIImage * img =  [UIImage imageNamed:@"Icon"];
        [_buttonCancel setUIImage:img forState:UIControlStateDisabled];
        [_buttonCancel.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_buttonCancel setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [_buttonCancel setAdjustsImageWhenDisabled:true];
        [_buttonCancel setEnabled:false];
        float viewH = viewTop.frame.size.height + 16;
        float viewW = (img.size.width/img.size.height) * viewH;
        [_buttonCancel setFrame:CGRectMake(16, -16, viewW, viewH)];
        [_buttonCancel setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
#endif
    }
    [_fbLoginButton removeFromSuperview];
    [_fbLoginButton setFrame:_registerScreenRectFB];
    [_mainViewRegister addSubview:_fbLoginButton];
    
    [_googleLoginButton removeFromSuperview];
    [_googleLoginButton setFrame:_registerScreenRectGoogle];
    [_mainViewRegister addSubview:_googleLoginButton];
    
    [_twitterLoginButton removeFromSuperview];
    [_twitterLoginButton setFrame:_registerScreenRectTwitter];
    [_mainViewRegister addSubview:_twitterLoginButton];
    if (self.buttonRegisterAsVendor) {
        [self.buttonRegisterAsVendor setSelected:false];
        [self.buttonRegisterAsVendor setImage:[[UIImage imageNamed:@"managing_icon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [self.buttonRegisterAsVendor setTitleColor:[Utility getUIColor:kUIColorBlue] forState:UIControlStateNormal];
    }
}
- (void)registerAsVendor:(UIButton*)button {
    [button setSelected:![button isSelected]];
    if ([button isSelected]) {
        [self.buttonRegisterAsVendor setImage:[[UIImage imageNamed:@"managing_icon_selected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [self.buttonRegisterAsVendor setTitleColor:[Utility getUIColor:kUIColorBlue] forState:UIControlStateNormal];
        
        if ([Utility isSellerOnlyApp]) {
            [self performSelector:@selector(gotoRegisterAdVendorScreen) withObject:nil afterDelay:0.0f];
        } else {
            [self performSelector:@selector(gotoRegisterAdVendorScreen) withObject:nil afterDelay:0.25f];
        }
        //        [self createRegisterPopupNew];
        //        if(self.popupControllerRegister){
        //            [self.popupControllerRegister dismissPopupControllerAnimated:NO];
        //        }
        //        [self.popupControllerRegisterAsSeller presentPopupControllerAnimated:NO];
    } else {
        [self.buttonRegisterAsVendor setImage:[[UIImage imageNamed:@"managing_icon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [self.buttonRegisterAsVendor setTitleColor:[Utility getUIColor:kUIColorBlue] forState:UIControlStateNormal];
    }
}
- (void)gotoRegisterAdVendorScreen {
    [self createRegisterPopupNew];
    if(self.popupControllerRegister){
        [self.popupControllerRegister dismissPopupControllerAnimated:NO];
    }
    [self.popupControllerRegisterAsSeller presentPopupControllerAnimated:NO];
}
- (void)resetPasswordClicked:(UIButton*)button {
#if NEW_LOGIN_ISSUE
    LoginFlow* lf = [LoginFlow sharedManager];
    [lf responseLogoutClicked:nil];
#endif
    BOOL isEmailValidated = [self isValidEmailId:_textForgotPasswordEmailId.text];
    
    if ([_textForgotPasswordEmailId.text isEqualToString:@""] || isEmailValidated == false) {
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"" message:Localize(@"enter_valid_email") delegate:nil cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil, nil];
        [errorAlert show];
    }
    else {
        NSMutableDictionary* dataDictionary = [[NSMutableDictionary alloc] init];
        [dataDictionary setObject:@"" forKey:@"name"];
        [dataDictionary setObject:@"" forKey:@"password"];
        [dataDictionary setObject:@"" forKey:@"image"];
        [dataDictionary setObject:_textForgotPasswordEmailId.text forKey:@"email"];
        [dataDictionary setObject:SA_PROVIDERS_NAME[SA_PROVIDERS_STORE] forKey:@"provider"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"response_forgot_password_clicked" object:dataDictionary];
    }
}
- (void)registerClickedAsVendor:(UIButton*)button {
    
#if NEW_LOGIN_ISSUE
    LoginFlow* lf = [LoginFlow sharedManager];
    [lf responseLogoutClicked:nil];
#endif
    _isRegisterAsVendor = true;
    _textRegisterAsSellerUsername.text = _textRegisterAsSellerEmailId.text;
    if ([_textRegisterAsSellerUsername.text isEqualToString:@""] || [_textRegisterAsSellerPassword.text isEqualToString:@""] || [_textRegisterAsSellerEmailId.text isEqualToString:@""] || [_textRegisterAsSellerConfirmPassword.text isEqualToString:@""] ||
        [_textRegisterAsSellerFirstName.text isEqualToString:@""] ||
        [_textRegisterAsSellerLastName.text isEqualToString:@""] ||
        [_textRegisterAsSellerCompanyName.text isEqualToString:@""] ||
        [_textRegisterAsSellerMobileNumber.text isEqualToString:@""]) {
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"" message:Localize(@"i_field_compulsary") delegate:nil cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil, nil];
        [errorAlert show];
    }
    else {
        BOOL isUsernameValidated = [self isValidUsername:_textRegisterAsSellerUsername.text];
        BOOL isPasswordValidated = [self isValidPasssword:_textRegisterAsSellerPassword.text pwd2:_textRegisterAsSellerConfirmPassword.text];
        BOOL isEmailValidated = [self isValidEmailId:_textRegisterAsSellerEmailId.text];
        
        if (isUsernameValidated == false) {
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:Localize(@"invalid_username") message:@"" delegate:nil cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil, nil];
            [errorAlert show];
        }else if (isPasswordValidated == false) {
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:Localize(@"invalid_password") message:@"" delegate:nil cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil, nil];
            [errorAlert show];
        }else if (isEmailValidated == false) {
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:Localize(@"invalid_email") message:@"" delegate:nil cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil, nil];
            [errorAlert show];
        }else{
            
            BOOL isMobileNumberValidated = false;
            if (_textRegisterAsSellerMobileNumber) {
                isMobileNumberValidated = [self isValidMobileNumber:_textRegisterAsSellerMobileNumber.text];
            }
            if([[Addons sharedManager] show_mobile_number_in_signup]) {
                if ([[Addons sharedManager] require_mobile_number_in_signup]) {
                    if ([_textRegisterAsSellerMobileNumber.text isEqualToString:@""]) {
                        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"" message:Localize(@"i_field_compulsary") delegate:nil cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil, nil];
                        [errorAlert show];
                    } else if (isMobileNumberValidated == false) {
                        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:Localize(@"invalid_mobile_number") message:@"" delegate:nil cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil, nil];
                        [errorAlert show];
                    }else {
                        _registerMobileNumber = _textRegisterAsSellerMobileNumber.text;
                        [self createOTPVerificationView];
                        [self resendOTP];
                    }
                    return;
                }
            }
            [self goForRegistrationAsVendor];
        }
    }
}
- (void)registerClicked:(UIButton*)button {
#if NEW_LOGIN_ISSUE
    LoginFlow* lf = [LoginFlow sharedManager];
    [lf responseLogoutClicked:nil];
#endif
    _isRegisterAsVendor = false;
    _textRegisterUsername.text = _textRegisterEmailId.text;
    if ([_textRegisterUsername.text isEqualToString:@""] || [_textRegisterPassword.text isEqualToString:@""] || [_textRegisterEmailId.text isEqualToString:@""] || [_textRegisterConfirmPassword.text isEqualToString:@""]) {
        
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"" message:Localize(@"i_field_compulsary") delegate:nil cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil, nil];
        [errorAlert show];
    }
    else {
        
        
        BOOL isUsernameValidated = [self isValidUsername:_textRegisterUsername.text];
        BOOL isPasswordValidated = [self isValidPasssword:_textRegisterPassword.text pwd2:_textRegisterConfirmPassword.text];
        BOOL isEmailValidated = [self isValidEmailId:_textRegisterEmailId.text];
        
        if (isUsernameValidated == false) {
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:Localize(@"invalid_username") message:@"" delegate:nil cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil, nil];
            [errorAlert show];
        }else if (isPasswordValidated == false) {
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:Localize(@"invalid_password") message:@"" delegate:nil cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil, nil];
            [errorAlert show];
        }else if (isEmailValidated == false) {
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:Localize(@"invalid_email") message:@"" delegate:nil cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil, nil];
            [errorAlert show];
        }else{
            
            BOOL isMobileNumberValidated = false;
            if (_textRegisterMobileNumber) {
                isMobileNumberValidated = [self isValidMobileNumber:_textRegisterMobileNumber.text];
            }
            if([[Addons sharedManager] show_mobile_number_in_signup]) {
                if ([[Addons sharedManager] require_mobile_number_in_signup]) {
                    if ([_textRegisterMobileNumber.text isEqualToString:@""]) {
                        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"" message:Localize(@"i_field_compulsary") delegate:nil cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil, nil];
                        [errorAlert show];
                    } else if (isMobileNumberValidated == false) {
                        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:Localize(@"invalid_mobile_number") message:@"" delegate:nil cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil, nil];
                        [errorAlert show];
                    }else {
                        _registerMobileNumber = _textRegisterMobileNumber.text;
                        [self createOTPVerificationView];
                        [self resendOTP];
                    }
                    return;
                }
            }
            
            [self goForRegistration];
        }
    }
}
- (void)goForRegistrationAsVendor {
    _wpWebView = [WebViewWordPress sharedManager];
    [self.view addSubview:_wpWebView];
    _wpWebView.loginFillData_userName = _textRegisterAsSellerUsername.text;
    _wpWebView.loginFillData_userPassword = _textRegisterAsSellerPassword.text;
    _wpWebView.loginFillData_userEmail = _textRegisterAsSellerEmailId.text;
    NSMutableDictionary* dataDictionary = [[NSMutableDictionary alloc] init];
    
    if (_textRegisterAsSellerFirstName)
        [dataDictionary setObject:_textRegisterAsSellerFirstName.text forKey:@"first_name"];
    if (_textRegisterAsSellerLastName)
        [dataDictionary setObject:_textRegisterAsSellerLastName.text forKey:@"last_name"];
    if (_textRegisterAsSellerCompanyName)
        [dataDictionary setObject:_textRegisterAsSellerCompanyName.text forKey:@"shop_name"];
    if (_textRegisterAsSellerUsername)
        [dataDictionary setObject:_textRegisterAsSellerUsername.text forKey:@"name"];
    if (_textRegisterAsSellerPassword)
        [dataDictionary setObject:_textRegisterAsSellerPassword.text forKey:@"password"];
    if (_textRegisterAsSellerEmailId)
        [dataDictionary setObject:_textRegisterAsSellerEmailId.text forKey:@"email"];
    
    [dataDictionary setObject:@"seller" forKey:@"user_role"];
    [dataDictionary setObject:@"" forKey:@"image"];
    
    if (_registerMobileNumber) {
        [dataDictionary setObject:_registerMobileNumber forKey:@"mobile_number"];
        [dataDictionary setObject:_registerMobileNumber forKey:@"phone"];
    } else {
        [dataDictionary setObject:@"" forKey:@"mobile_number"];
        [dataDictionary setObject:@"" forKey:@"phone"];
    }
    [dataDictionary setObject:SA_PROVIDERS_NAME[SA_PROVIDERS_STORE] forKey:@"provider"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"response_register_clicked" object:dataDictionary];
    //    [self authenticateAndLogin];
    //    [self fetchCustomerData];
    
    //here register user call
#if ENABLE_FIREBASE_TAG_MANAGER
    [[AnalyticsHelper sharedInstance] registerSignUpEvent];
#endif
}
- (void)goForRegistration {
    _wpWebView = [WebViewWordPress sharedManager];
    [self.view addSubview:_wpWebView];
    _wpWebView.loginFillData_userName = _textRegisterUsername.text;
    _wpWebView.loginFillData_userPassword = _textRegisterPassword.text;
    _wpWebView.loginFillData_userEmail = _textRegisterEmailId.text;
    NSMutableDictionary* dataDictionary = [[NSMutableDictionary alloc] init];
    [dataDictionary setObject:_textRegisterUsername.text forKey:@"name"];
    [dataDictionary setObject:_textRegisterPassword.text forKey:@"password"];
    [dataDictionary setObject:@"" forKey:@"image"];
    [dataDictionary setObject:_textRegisterEmailId.text forKey:@"email"];
    if (_registerMobileNumber) {
        [dataDictionary setObject:_registerMobileNumber forKey:@"mobile_number"];
    } else {
        [dataDictionary setObject:@"" forKey:@"mobile_number"];
    }
    [dataDictionary setObject:SA_PROVIDERS_NAME[SA_PROVIDERS_STORE] forKey:@"provider"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"response_register_clicked" object:dataDictionary];
    //    [self authenticateAndLogin];
    //    [self fetchCustomerData];
    
    //here register user call
#if ENABLE_FIREBASE_TAG_MANAGER
    [[AnalyticsHelper sharedInstance] registerSignUpEvent];
#endif
}
- (void)registerBackClicked:(UIButton*)button {
    [self showLoginPopup:false];
    [self.popupControllerRegister dismissPopupControllerAnimated:NO];
    if (self.popupControllerRegisterAsSeller) {
        [self.popupControllerRegisterAsSeller dismissPopupControllerAnimated:NO];
    }
}
- (void)forgotPasswordBackClicked:(UIButton*)button {
    [self showLoginPopup:false];
    [self.popupControllerForgotPassword dismissPopupControllerAnimated:NO];
}
- (void)setShouldDismissOnBackgroundTouch:(CNPPopupController*)cnpp {
    cnpp.theme.shouldDismissOnBackgroundTouch = true;
    Addons* addons = [Addons sharedManager];
    AppUser* appUser = [AppUser sharedManager];
    if(appUser._isUserLoggedIn == false && addons.show_login_at_start){
        if (addons.cancellable_login == false) {
            cnpp.theme.shouldDismissOnBackgroundTouch = false;
        }
    }
}
- (void)createForgotPasswordPopup {
    if (self.popupControllerForgotPassword == nil) {
        float widthView = [[MyDevice sharedManager] screenSize].width - [[MyDevice sharedManager] screenSize].width * 0.1f;
        float heightView = [[MyDevice sharedManager] screenSize].height - [[MyDevice sharedManager] screenSize].width * 0.1f;
        
        if ([[MyDevice sharedManager] isIpad]) {
            widthView = [[MyDevice sharedManager] screenWidthInPortrait] * 0.65f;
            heightView = [[MyDevice sharedManager] screenHeightInPortrait] * 0.63f;
            
        }else if ([[MyDevice sharedManager] isIphone]) {
            widthView = [[MyDevice sharedManager] screenSize].width * 0.96f;
            heightView = [[MyDevice sharedManager] screenSize].height * 0.70f;
        }
        
        
        UIView* viewMain = [[UIView alloc] initWithFrame:CGRectMake(0, 0, widthView, heightView)];
        viewMain.backgroundColor = [Utility getUIColor:kUIColorBgTheme];
        _mainViewForgotPassword = viewMain;
        
        UIView* viewTop = [[UIView alloc] initWithFrame:CGRectMake(0, 0, widthView, heightView * 0.05f)];
        viewTop.backgroundColor = [UIColor whiteColor];
        [viewMain addSubview:viewTop];
        
        self.popupControllerForgotPassword = [[CNPPopupController alloc] initWithContents:@[viewMain]];
        self.popupControllerForgotPassword.theme = [CNPPopupTheme addressTheme];
        self.popupControllerForgotPassword.theme.popupStyle = CNPPopupStyleCentered;
        self.popupControllerForgotPassword.theme.size = CGSizeMake(widthView, heightView);
        self.popupControllerForgotPassword.theme.maxPopupWidth = widthView;
        self.popupControllerForgotPassword.delegate = self;
        [self setShouldDismissOnBackgroundTouch:self.popupControllerForgotPassword];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            self.popupControllerForgotPassword.VIEW_POPUP.transform = CGAffineTransformMakeScale(-1, 1);
        }
        
        UIButton* _buttonCancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, viewTop.frame.size.width, viewTop.frame.size.height)];
        [viewTop addSubview:_buttonCancel];
        [_buttonCancel addTarget:self action:@selector(forgotPasswordBackClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_buttonCancel sizeToFit];
        [_buttonCancel setFrame:CGRectMake(viewTop.frame.size.width * 0.04f, 0, _buttonCancel.frame.size.width, viewTop.frame.size.height)];
        
        
        UILabel* _labelTitle = [self createLabel:viewTop fontType:kUIFontType20 fontColorType:kUIColorFontDark frame:CGRectMake(0, -16, viewTop.frame.size.width, viewTop.frame.size.height + 16) textStr:Localize(@"txt_forget")];
        [_labelTitle setTextAlignment:NSTextAlignmentCenter];
        
        float posY = CGRectGetMaxY(viewTop.frame) + viewMain.frame.size.width * 0.05f;
        float width = viewMain.frame.size.width * 0.70f;
        float posX = (viewMain.frame.size.width - width)/2;
        float height = (viewMain.frame.size.height - (posY - viewTop.frame.size.height) - posY)/9;
        float gap = height/2;
        
        _textForgotPasswordEmailId = [self createTextField:viewMain fontType:kUIFontType18 fontColorType:kUIColorFontLight frame:CGRectMake(posX, posY, width, height) tag:_kTAGTEXTFIELD_R_EMAIL textStrPlaceHolder:Localize(@"email")];
        posY += (height+gap);
        
        UIButton *buttonResetPassword = [[UIButton alloc] initWithFrame:CGRectMake(posX, posY, width, height)];
        [buttonResetPassword setBackgroundColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
        [[buttonResetPassword titleLabel] setUIFont:kUIFontType22 isBold:false];
        [buttonResetPassword setTitle:Localize(@"action_reset_password") forState:UIControlStateNormal];
        [buttonResetPassword setTitleColor:[Utility getUIColor:kUIColorBuyButtonFont] forState:UIControlStateNormal];
        [viewMain addSubview:buttonResetPassword];
        [buttonResetPassword addTarget:self action:@selector(resetPasswordClicked:) forControlEvents:UIControlEventTouchUpInside];
        posY += (height+gap);
        
        
        
        UIButton* _buttonGoBack = [[UIButton alloc] initWithFrame:CGRectMake(posX, posY, width, height)];
        [[_buttonGoBack titleLabel] setUIFont:kUIFontType18 isBold:false];
        [_buttonGoBack setTitleColor:[Utility getUIColor:kUIColorBlue] forState:UIControlStateNormal];
        [viewMain addSubview:_buttonGoBack];
        [_buttonGoBack addTarget:self action:@selector(forgotPasswordBackClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_buttonGoBack setTitle:Localize(@"txt_go_back") forState:UIControlStateNormal];
        float buttonw1 = LABEL_SIZE([_buttonGoBack titleLabel]).width;
        CGRect br1 = _buttonGoBack.frame;
        br1.size.width = buttonw1;
        br1.origin.x = widthView * 0.50f - buttonw1/2;
        [_buttonGoBack setFrame:br1];
        posY += (height+gap);
        
        
        UILabel* _labelGyan = [self createLabel:viewMain fontType:kUIFontType14 fontColorType:kUIColorFontLight frame:CGRectMake(0, posY, viewMain.frame.size.width, height) textStr:Localize(@"i_password_reset_desc")];
        [_labelGyan setTextAlignment:NSTextAlignmentCenter];
        posY += (height);
        
#if (NEW_CHU)
        UIImage * img =  [UIImage imageNamed:@"Icon"];
        [_buttonCancel setUIImage:img forState:UIControlStateDisabled];
        [_buttonCancel.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_buttonCancel setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [_buttonCancel setAdjustsImageWhenDisabled:true];
        [_buttonCancel setEnabled:false];
        float viewH = viewTop.frame.size.height + 16;
        float viewW = (img.size.width/img.size.height) * viewH;
        [_buttonCancel setFrame:CGRectMake(16, -16, viewW, viewH)];
        [_buttonCancel setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        //        UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:_buttonCancel.layer.bounds];
        //        _buttonCancel.layer.backgroundColor = [UIColor whiteColor].CGColor;
        //        _buttonCancel.layer.masksToBounds = NO;
        //        _buttonCancel.layer.shadowColor = [UIColor blackColor].CGColor;
        //        if ([[MyDevice sharedManager] isIpad]) {
        //            _buttonCancel.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
        //            _buttonCancel.layer.shadowOpacity = 0.2f;
        //            _buttonCancel.layer.shadowRadius = 0.0f;
        //        }else{
        //            _buttonCancel.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
        //            _buttonCancel.layer.shadowOpacity = 0.2f;
        //            _buttonCancel.layer.shadowRadius = 0.0f;
        //        }
        //        _buttonCancel.layer.shadowPath = shadowPath.CGPath;
#endif
        
    }
}
- (BOOL)isValidUsername:(NSString*)name{
    //    NSString *_username = name;
    //    NSCharacterSet * set = [[NSCharacterSet characterSetWithCharactersInString:@".!#$%&'*+-/=?^_`{|}~@,;"] invertedSet];
    //    if ([_username rangeOfCharacterFromSet:set].location != NSNotFound)
    //        return YES;
    //    else {
    //        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Invalid Username!" message:@"Username doesn't contain any special symbol." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    //        [errorAlert show];
    //        return NO;
    //    }
    
    return [self isValidEmailId:name];;
}
- (BOOL)isValidMobileNumber:(NSString *)mob {
    return true;
}
- (BOOL)isValidPasssword:(NSString *)pwd1 pwd2:(NSString *)pwd2 {
    
    if ([pwd1 compare:pwd2] != NSOrderedSame) {
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:Localize(@"invalid_password") message:Localize(@"both_password_not_same") delegate:nil cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil, nil];
        [errorAlert show];
        return NO;
    }
    
    //    NSString *pwd = pwd1;
    //    NSCharacterSet *upperCaseChars = [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLKMNOPQRSTUVWXYZ"];
    //    NSCharacterSet *lowerCaseChars = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyz"];
    //
    //    //NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    //
    //    if ( [pwd length]<6 || [pwd length]>20 )
    //        return NO;  // too long or too short
    //    NSRange rang;
    //    rang = [pwd rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet]];
    //    if ( !rang.length )
    //        return NO;  // no letter
    //    rang = [pwd rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]];
    //    if ( !rang.length )
    //        return NO;  // no number;
    //    rang = [pwd rangeOfCharacterFromSet:upperCaseChars];
    //    if ( !rang.length )
    //        return NO;  // no uppercase letter;
    //    rang = [pwd rangeOfCharacterFromSet:lowerCaseChars];
    //    if ( !rang.length )
    //        return NO;  // no lowerCase Chars;
    return YES;
}
- (BOOL)isValidEmailId:(NSString*)email {
    return true;
    
    
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

//- (void)popupControllerWillDismiss:(CNPPopupController *)controller {
//    [controller dismissPopupControllerAnimated:true];
//}
- (void)signInWillDispatch:(GIDSignIn *)signIn error:(NSError *)error{
    [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
}
- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    //    [self cancelClicked:nil];
    [MRProgressOverlayView showOverlayAddedTo:[[UIApplication sharedApplication] keyWindow] title:@"" mode:MRProgressOverlayViewModeIndeterminateSmallDefault animated:YES];
    if (error) {
        [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Localize(@"sorry") message:Localize(@"try_again") delegate:self cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil];
        [alert show];
    } else {
        
        LoginFlow* lf = [LoginFlow sharedManager];
        NSMutableDictionary* dataDictionary = [[NSMutableDictionary alloc] init];
        [dataDictionary setObject:@"" forKey:@"password"];
        [dataDictionary setObject:user.profile.name forKey:@"name"];
        [dataDictionary setObject:user.profile.givenName forKey:@"first_name"];
        [dataDictionary setObject:user.profile.familyName forKey:@"last_name"];
        NSString* imgStr = @"";
        if (user.profile.hasImage) {
            NSURL* imgUrl = [user.profile imageURLWithDimension:64];
            imgStr = imgUrl.absoluteString;
        }
        
        [dataDictionary setObject:imgStr forKey:@"image"];
        [dataDictionary setObject:user.profile.email forKey:@"email"];
        [dataDictionary setObject:SA_PROVIDERS_NAME[SA_PROVIDERS_GOOGLE_WEB] forKey:@"provider"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"response_login_clicked" object:dataDictionary];
        
        
        
        // Perform any operations on signed in user here.
        //        NSString *userId = user.userID;                  // For client-side use only!
        //        NSString *idToken = user.authentication.idToken; // Safe to send to the server
        //        NSString *fullName = user.profile.name;
        //        NSString *givenName = user.profile.givenName;
        //        NSString *familyName = user.profile.familyName;
        //        NSString *email = user.profile.email;
    }
}
#pragma mark Localization
- (void)languageSelectedDone:(id)sender {
    if(self.popupControllerSettings != nil) {
        [self.popupControllerSettings dismissPopupControllerAnimated:YES];
    }
    [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
    [MRProgressOverlayView showOverlayAddedTo:[[UIApplication sharedApplication] keyWindow] title:@"" mode:MRProgressOverlayViewModeIndeterminateSmallDefault animated:YES];
    [[NSUserDefaults standardUserDefaults] setValue:_selectedLocale forKey:USER_LOCALE];
    [[TMLanguage sharedManager] refreshLanguage];
    [Utility changeInputLanguage:_selectedLocale];
}
- (void)languageChanged:(NSNotification*)notification {
    [ProductInfo resetAllProductLocalizedStrings];
    [self refreshViewController];
}
- (void)refreshViewController {
    [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
    UIStoryboard *sb = [Utility getStoryBoardObject];
    SWRevealViewController *mainRevealController = [sb instantiateViewControllerWithIdentifier:VC_SWREVEAL];
    UIViewController *mainViewController = [sb instantiateViewControllerWithIdentifier:VC_MAIN];
    UIViewController *rightViewController = [sb instantiateViewControllerWithIdentifier:VC_RIGHT];
    UIViewController *leftViewController = [sb instantiateViewControllerWithIdentifier:VC_LEFT];
    mainRevealController = [[SWRevealViewController alloc] initWithRearViewController:leftViewController frontViewController:mainViewController];
    if ([[Addons sharedManager] multiVendor_enable] &&
        [[Addons sharedManager] multiVendor_screen_type] == MULTIVENDOR_SCREEN_SELLER) {
        [mainRevealController setRightViewController:rightViewController];
    }
    RLOG(@"rightViewController = %@", rightViewController);
    [[UIApplication sharedApplication].keyWindow setRootViewController:mainRevealController];
}
- (void)chkBoxLanguageClicked:(id)sender {
    UIButton* senderButton = (UIButton*)sender;
    [senderButton setSelected:YES];
    for (UIButton* button in _chkBoxLanguage) {
        if(button != senderButton){
            [button setSelected:NO];
        }
    }
    if ([senderButton isSelected]) {
        _selectedLocale = [senderButton.layer valueForKey:@"MY_LOCALE"];
        [[ParseHelper sharedManager] downloadLanguageFileInBg:_selectedLocale];
    }
}
- (void)showLanguageSelectionScreen {
    if(self.popupControllerSettings == nil) {
        float widthView = [[MyDevice sharedManager] screenSize].width - [[MyDevice sharedManager] screenSize].width * 0.1f;
        float heightView = [[MyDevice sharedManager] screenSize].height - [[MyDevice sharedManager] screenSize].width * 0.1f;
        
        if ([[MyDevice sharedManager] isIpad]) {
            widthView = [[MyDevice sharedManager] screenWidthInPortrait] * 0.65f;
            heightView = [[MyDevice sharedManager] screenHeightInPortrait] * 0.63f;
            
        }else if ([[MyDevice sharedManager] isIphone]) {
            widthView = [[MyDevice sharedManager] screenSize].width * 0.96f;
            heightView = [[MyDevice sharedManager] screenSize].height * 0.70f;
        }
        
        UIView* viewMain = [[UIView alloc] initWithFrame:CGRectMake(0, 0, widthView, heightView)];
        viewMain.backgroundColor = [Utility getUIColor:kUIColorBgTheme];
        //    _mainViewRegister = viewMain;
        
        UIView* viewTop = [[UIView alloc] initWithFrame:CGRectMake(0, 0, widthView, heightView * 0.05f)];
        viewTop.backgroundColor = [UIColor whiteColor];
        //    viewMain.backgroundColor = [Utility getUIColor:kUIColorBgTheme];
        [viewMain addSubview:viewTop];
        
        
        
        self.popupControllerSettings = [[CNPPopupController alloc] initWithContents:@[viewMain]];
        self.popupControllerSettings.theme = [CNPPopupTheme addressTheme];
        self.popupControllerSettings.theme.popupStyle = CNPPopupStyleCentered;
        self.popupControllerSettings.theme.size = CGSizeMake(widthView, heightView);
        self.popupControllerSettings.theme.maxPopupWidth = widthView;
        self.popupControllerSettings.delegate = self;
        self.popupControllerSettings.theme.shouldDismissOnBackgroundTouch = true;
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            self.popupControllerSettings.VIEW_POPUP.transform = CGAffineTransformMakeScale(-1, 1);
        }
        
        UILabel* _labelTitle = [self createLabel:viewTop fontType:kUIFontType20 fontColorType:kUIColorFontDark frame:CGRectMake(0, -16, viewTop.frame.size.width, viewTop.frame.size.height + 16) textStr:Localize(@"select_language")];
        [_labelTitle setTextAlignment:NSTextAlignmentCenter];
        
        float leftItemsPosX = viewMain.frame.size.width * 0.10f;
        float itemPosY = viewMain.frame.size.width * 0.04f + viewTop.frame.size.height;
        float itemPosYOriginal = viewMain.frame.size.width * 0.04f + viewTop.frame.size.height;
        UILabel* labelTemp= [[UILabel alloc] init];
        [labelTemp setUIFont:kUIFontType24 isBold:false];
        float fontHeight = [[labelTemp font] lineHeight];
        
        Addons* addons = [Addons sharedManager];
        if(addons.language&& addons.language.titles && [addons.language.titles count] > 0) {
            {
                for (int i = 0; i < (int)[addons.language.titles count]; i++) {
                    CGRect frame = CGRectMake(leftItemsPosX + 10, itemPosY, viewMain.frame.size.width, fontHeight);
                    itemPosY+=(frame.size.height + fontHeight * 0.5f);
                }
            }
        }
        itemPosY += itemPosYOriginal;
        
        self.popupControllerSettings.theme.size = CGSizeMake(widthView, itemPosY);
        CGRect viewMainFrame = viewMain.frame;
        viewMainFrame.size = CGSizeMake(widthView, itemPosY);
        viewMain.frame = viewMainFrame;
        
        
        itemPosY = itemPosYOriginal;
        if(addons.language&& addons.language.titles && [addons.language.titles count] > 0) {
            
            for (int i = 0; i < (int)[addons.language.titles count]; i++) {
                UIButton* button = [[UIButton alloc] init];
                button.frame = CGRectMake(leftItemsPosX + 10, itemPosY, viewMain.frame.size.width, fontHeight);
                [button addTarget:self action:@selector(chkBoxLanguageClicked:) forControlEvents:UIControlEventTouchUpInside];
                [viewMain addSubview:button];
                [button setUIImage:[UIImage imageNamed:@"radiobtn_unselected"] forState:UIControlStateNormal];
                [button setUIImage:[UIImage imageNamed:@"radiobtn_selected"] forState:UIControlStateSelected];
                [button setTitle:[NSString stringWithFormat:@"%@", addons.language.titles[i]] forState:UIControlStateNormal];
                [button setTitleEdgeInsets:UIEdgeInsetsMake(0, viewMain.frame.size.width * 0.04f, 0, 0)];
                [button setTitleColor:[Utility getUIColor:kUIColorFontLight] forState:UIControlStateNormal];
                [button setTitleColor:[Utility getUIColor:kUIColorFontLight] forState:UIControlStateSelected];
                [button.titleLabel setUIFont:kUIFontType20 isBold:false];
                button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                [button.layer setValue:addons.language.locales[i] forKey:@"MY_LOCALE"];
                [_chkBoxLanguage addObject:button];
                
                NSString* selecetedLocale = addons.language.defaultLocale;
                if ([[TMLanguage sharedManager] isUserLanguageSet]) {
                    selecetedLocale = [[NSUserDefaults standardUserDefaults] valueForKey:USER_LOCALE];
                }
                
                if ([selecetedLocale isEqualToString:addons.language.locales[i]]) {
                    [button setSelected:true];
                }
                
                
                itemPosY+=(button.frame.size.height + fontHeight * 0.5f);
            }
            
            for (UIButton* button in _chkBoxLanguage) {
                if (button.isSelected) {
                    [self chkBoxLanguageClicked:button];
                }
            }
            if ((int)[_chkBoxLanguage count] == 1) {
                UIButton* button = (UIButton*)[_chkBoxLanguage objectAtIndex:0];
                [button setSelected:true];
                [self chkBoxLanguageClicked:button];
            }
        }
        
        UIButton* _buttonCancel = [[UIButton alloc] initWithFrame:CGRectMake(0, -16, viewTop.frame.size.width, viewTop.frame.size.height + 16)];
        [viewTop addSubview:_buttonCancel];
        [_buttonCancel addTarget:self action:@selector(languageSelectedDone:) forControlEvents:UIControlEventTouchUpInside];
        [_buttonCancel setTitle:Localize(@"i_cok") forState:UIControlStateNormal];
        [[_buttonCancel titleLabel] setUIFont:kUIFontType18 isBold:false];
        [_buttonCancel setTitleColor:[Utility getUIColor:kUIColorBlue] forState:UIControlStateNormal];
        [_buttonCancel setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 16)];
        _buttonCancel.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [viewMain addSubview:_buttonCancel];
    }
    [self.popupControllerSettings presentPopupControllerAnimated:YES];
}
#pragma mark Reward Points
-(void) getUserRewardPoints{
    if([AppUser isSignedIn] && [[Addons sharedManager] enable_custom_points]) {
        NSString* emailId = base64_str([[AppUser sharedManager] _email]);
        NSString* userId = base64_int([[AppUser sharedManager] _id]);
        NSString* type =  base64_str(@"user_total_points");
        NSDictionary* parameters = @{@"type": type, @"user_id": userId, @"email_id": emailId};
        [[DataManager getDataDoctor] getUserRewardPoints:parameters
                                                 success:^(id data) {
                                                     [_treeView reloadRows];
                                                     RLOG(@"User reward points fetched successfully.");
                                                 }
                                                 failure:^(NSString *error) {
                                                     RLOG(@"Failed to get user reward points.");
                                                 }];
    }
}
#pragma mark Sponser Friend
- (void)createSponserFriendPopup{
    if(self.popupControllerSponserFriend == nil) {
        BOOL isSponsorImgExists = false;
        Addons* addons = [Addons sharedManager];
        if (addons.sponsorFriend.sponsor_img_url && ![addons.sponsorFriend.sponsor_img_url isEqualToString:@""]) {
            isSponsorImgExists = true;
        }
        float widthView = [[MyDevice sharedManager] screenSize].width - [[MyDevice sharedManager] screenSize].width * 0.1f;
        float heightView = [[MyDevice sharedManager] screenSize].height - [[MyDevice sharedManager] screenSize].width * 0.1f;
        if ([[MyDevice sharedManager] isIpad]) {
            widthView = [[MyDevice sharedManager] screenWidthInPortrait] * 0.65f;
            heightView = [[MyDevice sharedManager] screenHeightInPortrait] * 0.63f;
        }else if ([[MyDevice sharedManager] isIphone]) {
            widthView = [[MyDevice sharedManager] screenSize].width * 0.96f;
            heightView = [[MyDevice sharedManager] screenSize].height * 0.70f;
        }
        UIView* viewMain = [[UIView alloc] initWithFrame:CGRectMake(0, 0, widthView, heightView)];
        viewMain.backgroundColor = [Utility getUIColor:kUIColorBgTheme];
        UIView* viewTop = [[UIView alloc] initWithFrame:CGRectMake(0, 0, widthView, heightView * 0.05f)];
        viewTop.backgroundColor = [UIColor whiteColor];
        [viewMain addSubview:viewTop];
        self.popupControllerSponserFriend = [[CNPPopupController alloc] initWithContents:@[viewMain]];
        self.popupControllerSponserFriend.theme = [CNPPopupTheme addressTheme];
        self.popupControllerSponserFriend.theme.popupStyle = CNPPopupStyleCentered;
        self.popupControllerSponserFriend.theme.size = CGSizeMake(widthView, heightView);
        self.popupControllerSponserFriend.theme.maxPopupWidth = widthView;
        self.popupControllerSponserFriend.delegate = self;
        self.popupControllerSponserFriend.theme.shouldDismissOnBackgroundTouch = true;
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            self.popupControllerSponserFriend.VIEW_POPUP.transform = CGAffineTransformMakeScale(-1, 1);
        }
        UILabel* _labelTitle = [self createLabel:viewTop fontType:kUIFontType20 fontColorType:kUIColorFontDark frame:CGRectMake(0, -16, viewTop.frame.size.width, viewTop.frame.size.height + 16) textStr:Localize(@"sponsor_a_friend")];
        [_labelTitle setTextAlignment:NSTextAlignmentCenter];
        
        UIButton* _buttonCancel = [[UIButton alloc] initWithFrame:CGRectMake(16, -16, viewTop.frame.size.width, viewTop.frame.size.height + 16)];
        [viewTop addSubview:_buttonCancel];
        [_buttonCancel addTarget:self action:@selector(sponserCancelBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_buttonCancel setTitle:Localize(@"cancel") forState:UIControlStateNormal];
        [[_buttonCancel titleLabel] setUIFont:kUIFontType18 isBold:false];
        [_buttonCancel setTitleColor:[Utility getUIColor:kUIColorBlue] forState:UIControlStateNormal];
        [_buttonCancel setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 16)];
        _buttonCancel.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [viewMain addSubview:_buttonCancel];
        UILabel* labelTemp= [[UILabel alloc] init];
        [labelTemp setUIFont:kUIFontType24 isBold:false];
        float fontHeight = [[labelTemp font] lineHeight];
        float posY = CGRectGetMaxY(viewTop.frame) + viewMain.frame.size.width * 0.05f;
        float width = viewMain.frame.size.width * 0.70f;
        float posX = (viewMain.frame.size.width - width)/2;
        float height = fontHeight * 2.0f;
        float gap = height/4;
        if (isSponsorImgExists) {
            gap = height/5;
        }
        posY = (heightView - CGRectGetMaxY(viewTop.frame) - height * 7.5 - gap * 6)/2;
        posY += CGRectGetMaxY(viewTop.frame);
        if (isSponsorImgExists) {
            UIImageView* sponsorImgView = [[UIImageView alloc] init];
            [sponsorImgView setFrame:CGRectMake(0, posY - CGRectGetMaxY(viewTop.frame) - 30, viewMain.frame.size.width, height * 3)];
            [viewMain addSubview:sponsorImgView];
            [sponsorImgView setContentMode:UIViewContentModeScaleAspectFit];
            //            [sponsorImgView.layer setBorderWidth:1];
            [Utility setImage:sponsorImgView url:addons.sponsorFriend.sponsor_img_url resizeType:kRESIZE_TYPE_PRODUCT_THUMBNAIL isLocal:false];
            posY = CGRectGetMaxY(sponsorImgView.frame) + gap;
        }
        
        _sponsorFriendFirstName = [self createTextField:viewMain fontType:kUIFontType18 fontColorType:kUIColorFontLight frame:CGRectMake(posX, posY, width, height) tag:_kTAGTEXTFIELD_R_USERNAME textStrPlaceHolder:Localize(@"your_friend_first_name")];
        posY += (height+gap);
        _sponsorFriendLastName = [self createTextField:viewMain fontType:kUIFontType18 fontColorType:kUIColorFontLight frame:CGRectMake(posX, posY, width, height) tag:_kTAGTEXTFIELD_R_USERNAME textStrPlaceHolder:Localize(@"your_friend_last_name")];
        posY += (height+gap);
        _sponsorFriendEmail= [self createTextField:viewMain fontType:kUIFontType18 fontColorType:kUIColorFontLight frame:CGRectMake(posX, posY, width, height) tag:_kTAGTEXTFIELD_R_USERNAME textStrPlaceHolder:Localize(@"your_friend_email")];
        posY += (height+gap/2);
        UILabel* labelOptionalMsg = [self createLabel:viewMain fontType:kUIFontType18 fontColorType:kUIColorFontDark frame:CGRectMake(posX, posY, width, height/2)  textStr:Localize(@"optional_message")];
        posY += (height/2);
        _sponsorOptionalMsg = [self createTextView:viewMain fontType:kUIFontType18 fontColorType:kUIColorFontLight frame:CGRectMake(posX, posY, width, height * 1.5f) tag:_kTAGTEXTFIELD_R_USERNAME textStrPlaceHolder:Localize(@"optional_message") textView:_sponsorOptionalMsg];
        [_sponsorOptionalMsg setKeyboardType:UIKeyboardTypeDefault];
        [_sponsorOptionalMsg setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        if (isSponsorImgExists) {
            posY = CGRectGetMaxY(_sponsorOptionalMsg.frame) + gap;
            posY += (gap * 1.5f);
        } else {
            posY += (height * 1.5f + gap);
            posY += (height * 0.5f + gap);
        }
        UIButton *buttonSponser = [[UIButton alloc] initWithFrame:CGRectMake(posX, posY, width, height)];
        [buttonSponser setBackgroundColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
        [[buttonSponser titleLabel] setUIFont:kUIFontType22 isBold:false];
        [buttonSponser setTitle:Localize(@"sponsor_a_friend") forState:UIControlStateNormal];
        [buttonSponser setTitleColor:[Utility getUIColor:kUIColorBuyButtonFont] forState:UIControlStateNormal];
        [viewMain addSubview:buttonSponser];
        [buttonSponser addTarget:self action:@selector(sponserBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        posY += (height+gap);
        if (isSponsorImgExists) {
            posY += viewMain.frame.size.width * 0.1f;
        } else {
            posY += viewMain.frame.size.width * 0.5f;
        }
        self.popupControllerSponserFriend.theme.size = CGSizeMake(widthView, MAX(heightView, posY));
        CGRect viewMainFrame = viewMain.frame;
        viewMainFrame.size = CGSizeMake(widthView, MAX(heightView, posY));
        viewMain.frame = viewMainFrame;
    }
    [self.popupControllerSponserFriend presentPopupControllerAnimated:YES];
}
- (void)sponserBtnClicked:(UIButton*)button {
    Addons* addons = [Addons sharedManager];
    
    if(addons.sponsorFriend && addons.sponsorFriend.isEnabled) {
        AppUser* appUser = [AppUser sharedManager];
        if(![AppUser isSignedIn]) {
            [Utility showToast:Localize(@"login_required")];
            return;
        }
        NSString* toFirstName = _sponsorFriendFirstName.text;
        NSString* toLastName = _sponsorFriendLastName.text;
        NSString* toMessage = _sponsorOptionalMsg.text;
        NSString* toEmail = _sponsorFriendEmail.text;
        NSString* fromEmail = appUser._email;
        NSString* userId = [NSString stringWithFormat:@"%d", appUser._id];
        RLOG(@"toFirstName=%@, toLastName=%@, toMessage=%@, toEmail=%@, fromEmail=%@, userId=%@",toFirstName, toLastName, toMessage, toEmail, fromEmail, userId);
        toFirstName = base64_str(toFirstName);
        toLastName = base64_str(toLastName);
        toMessage = base64_str(toMessage);
        toEmail = base64_str(toEmail);
        fromEmail = base64_str(fromEmail);
        userId = base64_str(userId);
        RLOG(@"toFirstName=%@, toLastName=%@, toMessage=%@, toEmail=%@, fromEmail=%@, userId=%@",toFirstName, toLastName, toMessage, toEmail, fromEmail, userId);
        NSDictionary* params = @{
                                 @"to_firstname": toFirstName,
                                 @"to_lastname": toLastName,
                                 @"to_message": toMessage,
                                 @"to_email": toEmail,
                                 @"from_email": fromEmail,
                                 @"user_id": userId
                                 };
        RLOG(@"params = %@", params);
        [[DataManager getDataDoctor] sponsorYourFriend:params
                                               success:^(NSString *message) {
                                                   RLOG(@"Request for sponsor friend sent successfully.");
                                                   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:/*Localize(@"Request for sponsor friend sent successfully.")*/ message delegate:self cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil];
                                                   [alert show];
                                                   [self sponserCancelBtnClicked:nil];
                                               }
                                               failure:^(NSString *message) {
                                                   RLOG(@"Failed to sent request for sponsor friend.");
                                                   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:/*Localize(@"Failed to sent request for sponsor friend.")*/message delegate:self cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil];
                                                   [alert show];
                                                   [self sponserCancelBtnClicked:nil];
                                                   
                                               }];
    }
}
- (void)sponserCancelBtnClicked:(UIButton*)button {
    [self.popupControllerSponserFriend dismissPopupControllerAnimated:YES];
}
#pragma mark Barcode Scanner Delegate
//- (void)barcodeFetchedRawValue:(NSString *)rawValue {
////    [Utility showProgressView:@""];
//
//    NSString* sku = rawValue;
//    if (sku && ![sku isEqualToString:@""]) {
//        ProductInfo* pInfo = [ProductInfo getProductWithSku:sku];
//        if (pInfo) {
//            //open product page
//            [self openProductPage:pInfo];
//        } else {
//            //fetch product with sku
//            [self fetchProductWithSku:sku];
//        }
//    }
//}
//
//- (void)fetchProductWithSku:(NSString*)sku {
//    [[[DataManager sharedManager] tmDataDoctor] fetchProductDataFromSku:sku success:^(id data) {
//        ProductInfo* pInfo = (ProductInfo*)data;
//        [self openProductPage:pInfo];
//    } failure:^(NSString *error) {
//        if ([error isEqualToString:@"retry"]) {
//            [self fetchProductWithSku:sku];
//        } else {
////            [Utility hideProgressView];
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Localize(@"i_error") message:Localize(@"try_again") delegate:nil cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil];
//            [alertView show];
//        }
//    }];
//}
//- (void)openProductPage:(ProductInfo*)pInfo {
////    [Utility hideProgressView];
//    if (pInfo) {
//        ViewControllerHome* homeVC = [ViewControllerHome getInstance];
//        [homeVC clickOnProduct:pInfo currentItemData:nil cell:nil];
//    } else {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Localize(@"i_error") message:Localize(@"try_again") delegate:nil cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil];
//        [alertView show];
//    }
//
//}
- (void)barcodeFetchedRawValue:(NSString *)rawValue {
    [Utility showProgressView:@""];
    ViewControllerHome* homeVC = [ViewControllerHome getInstance];
    ViewControllerProduct* prodVC = [homeVC openProductVC];
    self.tempProdVC = prodVC;
    NSString* sku = rawValue;
    if (sku && ![sku isEqualToString:@""]) {
        ProductInfo* pInfo = [ProductInfo getProductWithSku:sku];
        if (pInfo) {
            //open product page
            [Utility hideProgressView];
            [homeVC loadProductVC:self.tempProdVC productClicked:pInfo];
        } else {
            //fetch product with sku
            [self fetchProductWithSku:sku];
        }
    }
}

- (void)fetchProductWithSku:(NSString*)sku {
    [Utility hideProgressView];
    [[[DataManager sharedManager] tmDataDoctor] fetchProductDataFromSku:sku success:^(id data) {
        ProductInfo* pInfo = (ProductInfo*)data;
        ViewControllerHome* homeVC = [ViewControllerHome getInstance];
        [homeVC loadProductVC:self.tempProdVC productClicked:pInfo];
    } failure:^(NSString *error) {
        if ([error isEqualToString:@"retry"]) {
            [self fetchProductWithSku:sku];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Localize(@"i_error") message:Localize(@"try_again") delegate:nil cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil];
            [alertView show];
        }
    }];
}
#pragma mark OTP Verification Methods
- (void)createOTPVerificationView {
    {
        if(self.popupControllerOTP == nil) {
            
            float widthView = [[MyDevice sharedManager] screenSize].width - [[MyDevice sharedManager] screenSize].width * 0.1f;
            float heightView = [[MyDevice sharedManager] screenSize].height - [[MyDevice sharedManager] screenSize].width * 0.1f;
            if ([[MyDevice sharedManager] isIpad]) {
                widthView = [[MyDevice sharedManager] screenWidthInPortrait] * 0.65f;
                heightView = [[MyDevice sharedManager] screenHeightInPortrait] * 0.63f;
            }else if ([[MyDevice sharedManager] isIphone]) {
                widthView = [[MyDevice sharedManager] screenSize].width * 0.96f;
                heightView = [[MyDevice sharedManager] screenSize].height * 0.70f;
            }
            UIView* viewMain = [[UIView alloc] initWithFrame:CGRectMake(0, 0, widthView, heightView)];
            viewMain.backgroundColor = [Utility getUIColor:kUIColorBgTheme];
            UIView* viewTop = [[UIView alloc] initWithFrame:CGRectMake(0, 0, widthView, heightView * 0.05f)];
            viewTop.backgroundColor = [UIColor whiteColor];
            [viewMain addSubview:viewTop];
            self.popupControllerOTP = [[CNPPopupController alloc] initWithContents:@[viewMain]];
            self.popupControllerOTP.theme = [CNPPopupTheme addressTheme];
            self.popupControllerOTP.theme.popupStyle = CNPPopupStyleCentered;
            self.popupControllerOTP.theme.size = CGSizeMake(widthView, heightView);
            self.popupControllerOTP.theme.maxPopupWidth = widthView;
            self.popupControllerOTP.delegate = self;
            self.popupControllerOTP.theme.shouldDismissOnBackgroundTouch = true;
            if ([[TMLanguage sharedManager] isRTLEnabled]) {
                self.popupControllerOTP.VIEW_POPUP.transform = CGAffineTransformMakeScale(-1, 1);
            }
            UILabel* _labelTitle = [self createLabel:viewTop fontType:kUIFontType20 fontColorType:kUIColorFontDark frame:CGRectMake(0, -16, viewTop.frame.size.width, viewTop.frame.size.height + 16) textStr:Localize(@"otp_verification")];
            [_labelTitle setTextAlignment:NSTextAlignmentCenter];
            
            UIButton* _buttonCancel = [[UIButton alloc] initWithFrame:CGRectMake(16, -16, viewTop.frame.size.width, viewTop.frame.size.height + 16)];
            [viewTop addSubview:_buttonCancel];
            [_buttonCancel addTarget:self action:@selector(otpCancelBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [_buttonCancel setTitle:Localize(@"cancel") forState:UIControlStateNormal];
            [[_buttonCancel titleLabel] setUIFont:kUIFontType18 isBold:false];
            [_buttonCancel setTitleColor:[Utility getUIColor:kUIColorBlue] forState:UIControlStateNormal];
            [_buttonCancel setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 16)];
            _buttonCancel.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            [viewMain addSubview:_buttonCancel];
            UILabel* labelTemp= [[UILabel alloc] init];
            [labelTemp setUIFont:kUIFontType24 isBold:false];
            float fontHeight = [[labelTemp font] lineHeight];
            float posY = CGRectGetMaxY(viewTop.frame) + viewMain.frame.size.width * 0.05f;
            float width = viewMain.frame.size.width * 0.70f;
            float posX = (viewMain.frame.size.width - width)/2;
            float height = fontHeight * 2.0f;
            float gap = height/4;
            
            posY = (heightView - CGRectGetMaxY(viewTop.frame) - height * 7.5 - gap * 6)/2;
            posY += CGRectGetMaxY(viewTop.frame);
            
            _otp_button_mobile = [[UIButton alloc] initWithFrame:CGRectMake(posX, posY, width, height)];
            [_otp_button_mobile setBackgroundColor:[UIColor clearColor]];
            [[_otp_button_mobile titleLabel] setUIFont:kUIFontType22 isBold:true];
            [_otp_button_mobile setTitle:_registerMobileNumber forState:UIControlStateNormal];
            [_otp_button_mobile setTitleColor:[Utility getUIColor:kUIColorFontDark] forState:UIControlStateNormal];
            [viewMain addSubview:_otp_button_mobile];
            [_otp_button_mobile addTarget:self action:@selector(otpCancelBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            posY += (height+gap);
            
            
            _otp_textfield_code = [self createTextField:viewMain fontType:kUIFontType18 fontColorType:kUIColorFontDark frame:CGRectMake(posX, posY, width, height) tag:_kTAGTEXTFIELD_R_USERNAME textStrPlaceHolder:Localize(@"enter_otp")];
            _otp_textfield_code.textAlignment = NSTextAlignmentCenter;
            [_otp_textfield_code setUIFont:kUIFontType18 isBold:true];
            posY += (height+gap);
            
            
            _otp_button_timer = [[UIButton alloc] initWithFrame:CGRectMake(posX, posY, width, height)];
            [_otp_button_timer setBackgroundColor:[UIColor clearColor]];
            [[_otp_button_timer titleLabel] setUIFont:kUIFontType22 isBold:false];
            [_otp_button_timer setTitle:@"" forState:UIControlStateNormal];
            [_otp_button_timer setTitleColor:[Utility getUIColor:kUIColorFontDark] forState:UIControlStateNormal];
            [viewMain addSubview:_otp_button_timer];
            [_otp_button_timer addTarget:self action:@selector(resendOTP) forControlEvents:UIControlEventTouchUpInside];
            posY += (height+gap);
            
            posY += (height * 1.5f + gap);
            posY += (height * 0.5f + gap);
            _OTPButtonVerify = [[UIButton alloc] initWithFrame:CGRectMake(posX, posY, width, height)];
            [_OTPButtonVerify setBackgroundColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
            [[_OTPButtonVerify titleLabel] setUIFont:kUIFontType22 isBold:false];
            [_OTPButtonVerify setTitle:Localize(@"verify") forState:UIControlStateNormal];
            [_OTPButtonVerify setTitleColor:[Utility getUIColor:kUIColorBuyButtonFont] forState:UIControlStateNormal];
            [viewMain addSubview:_OTPButtonVerify];
            [_OTPButtonVerify addTarget:self action:@selector(verifyOTP) forControlEvents:UIControlEventTouchUpInside];
            posY += (height+gap);
            posY += viewMain.frame.size.width * 0.5f;
            
            self.popupControllerOTP.theme.size = CGSizeMake(widthView, MIN(heightView, posY));
            CGRect viewMainFrame = viewMain.frame;
            viewMainFrame.size = CGSizeMake(widthView, MIN(heightView, posY));
            viewMain.frame = viewMainFrame;
        }
        [_otp_button_mobile setTitle:_registerMobileNumber forState:UIControlStateNormal];
        [self.popupControllerOTP presentPopupControllerAnimated:YES];
    }
}
- (void)OTPTimerInvalidate {
    if (_otp_timer_foreground) {
        [_otp_timer_foreground invalidate];
        _otp_timer_foreground = nil;
    }
    if (_otp_timer_background) {
        [_otp_timer_background invalidate];
        _otp_timer_background = nil;
    }
    _OTPResendTimerForeground = 1 * 60;
    _OTPResendTimerBackground = 5 * 60;
}
- (void)OTPTimerResetFg {
    if (_otp_timer_foreground) {
        [_otp_timer_foreground invalidate];
        _otp_timer_foreground = nil;
    }
    _otp_timer_foreground = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(OTPTimer:) userInfo:nil repeats:YES];
    _OTPResendTimerForeground = 1 * 60;
}
- (void)OTPTimerResetBg {
    if (_otp_timer_background) {
        [_otp_timer_background invalidate];
        _otp_timer_background = nil;
    }
    _otp_timer_background = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(OTPTimer:) userInfo:nil repeats:YES];
    _OTPResendTimerBackground = 5 * 60;
}
- (void)OTPTimer:(float)tt {
    if (_OTPResendTimerForeground > 0) {
        _OTPResendTimerForeground--;
    }
    if (_OTPResendTimerBackground > 0) {
        _OTPResendTimerBackground--;
    }
    if (_otp_button_timer) {
        if (_OTPResendTimerForeground == 0) {
            [_otp_button_timer setTitle:Localize(@"resend_otp") forState:UIControlStateNormal];
        } else {
            NSString* timeStr =  [Utility formattedTimeString:_OTPResendTimerForeground*1000];
            [_otp_button_timer setTitle:timeStr forState:UIControlStateNormal];
        }
    }
}
- (void)sendOTP {
    _registerMobileNumberOTP = _registerMobileNumber;
    [[[DataManager sharedManager] tmDataDoctor] pluginOTP:_registerMobileNumber
                                                     code:@""
                                                     type:OTP_METHOD_TYPE_SEND
                                                  success:^(NSString *str) {
                                                      RLOG(@"%@",str);
                                                      
                                                      [self OTPTimerResetFg];
                                                      [self OTPTimerResetBg];
                                                  }
                                                  failure:^(NSString *error) {
                                                      RLOG(@"%@",error);
                                                      
                                                      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:error delegate:self cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil];
                                                      [alert show];
                                                  }];
}
- (void)resendOTP {
    if ([_registerMobileNumberOTP isEqualToString:_registerMobileNumber]) {
        if (_OTPResendTimerBackground > 0) {
            if (_OTPResendTimerForeground > 0) {
                
            } else {
                [[[DataManager sharedManager] tmDataDoctor] pluginOTP:_registerMobileNumber
                                                                 code:@""
                                                                 type:OTP_METHOD_TYPE_RESEND
                                                              success:^(NSString *str) {
                                                                  RLOG(@"%@",str);
                                                                  [self OTPTimerResetFg];
                                                              }
                                                              failure:^(NSString *error) {
                                                                  RLOG(@"%@",error);
                                                                  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:error delegate:self cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil];
                                                                  [alert show];
                                                              }];
                
            }
        } else {
            [self sendOTP];
        }
    } else {
        [self sendOTP];
        
    }
}
- (void)verifyOTP {
    [[[DataManager sharedManager] tmDataDoctor] pluginOTP:_registerMobileNumber
                                                     code:_otp_textfield_code.text
                                                     type:OTP_METHOD_TYPE_VERIFY
                                                  success:^(NSString *str) {
                                                      RLOG(@"%@",str);
                                                      [self OTPTimerInvalidate];
                                                      [self.popupControllerOTP dismissPopupControllerAnimated:YES];
                                                      if (_isRegisterAsVendor) {
                                                          [self goForRegistrationAsVendor];
                                                      } else {
                                                          [self goForRegistration];
                                                      }
                                                      
                                                  }
                                                  failure:^(NSString *error) {
                                                      RLOG(@"%@",error);
                                                      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Localize(@"verification_failed") message:error delegate:self cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil];
                                                      [alert show];
                                                  }];
}
- (void)otpCancelBtnClicked:(UIButton*)button {
    [self.popupControllerOTP dismissPopupControllerAnimated:YES];
}
#pragma mark RESET PASSWORD
- (void)createResetPasswordView {
    {
        if(self.popupControllerResetPassword == nil) {
            
            float widthView = [[MyDevice sharedManager] screenSize].width - [[MyDevice sharedManager] screenSize].width * 0.1f;
            float heightView = [[MyDevice sharedManager] screenSize].height - [[MyDevice sharedManager] screenSize].width * 0.1f;
            if ([[MyDevice sharedManager] isIpad]) {
                widthView = [[MyDevice sharedManager] screenWidthInPortrait] * 0.65f;
                heightView = [[MyDevice sharedManager] screenHeightInPortrait] * 0.63f;
            }else if ([[MyDevice sharedManager] isIphone]) {
                widthView = [[MyDevice sharedManager] screenSize].width * 0.96f;
                heightView = [[MyDevice sharedManager] screenSize].height * 0.70f;
            }
            UIView* viewMain = [[UIView alloc] initWithFrame:CGRectMake(0, 0, widthView, heightView)];
            viewMain.backgroundColor = [Utility getUIColor:kUIColorBgTheme];
            UIView* viewTop = [[UIView alloc] initWithFrame:CGRectMake(0, 0, widthView, heightView * 0.05f)];
            viewTop.backgroundColor = [UIColor whiteColor];
            [viewMain addSubview:viewTop];
            self.popupControllerResetPassword = [[CNPPopupController alloc] initWithContents:@[viewMain]];
            self.popupControllerResetPassword.theme = [CNPPopupTheme addressTheme];
            self.popupControllerResetPassword.theme.popupStyle = CNPPopupStyleCentered;
            self.popupControllerResetPassword.theme.size = CGSizeMake(widthView, heightView);
            self.popupControllerResetPassword.theme.maxPopupWidth = widthView;
            self.popupControllerResetPassword.delegate = self;
            self.popupControllerResetPassword.theme.shouldDismissOnBackgroundTouch = true;
            if ([[TMLanguage sharedManager] isRTLEnabled]) {
                self.popupControllerResetPassword.VIEW_POPUP.transform = CGAffineTransformMakeScale(-1, 1);
            }
            UILabel* _labelTitle = [self createLabel:viewTop fontType:kUIFontType20 fontColorType:kUIColorFontDark frame:CGRectMake(0, -16, viewTop.frame.size.width, viewTop.frame.size.height + 16) textStr:Localize(@"title_reset_password")];
            [_labelTitle setTextAlignment:NSTextAlignmentCenter];
            
            UIButton* _buttonCancel = [[UIButton alloc] initWithFrame:CGRectMake(16, -16, viewTop.frame.size.width, viewTop.frame.size.height + 16)];
            [viewTop addSubview:_buttonCancel];
            [_buttonCancel addTarget:self action:@selector(resetPasswordCancelBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [_buttonCancel setTitle:Localize(@"cancel") forState:UIControlStateNormal];
            [[_buttonCancel titleLabel] setUIFont:kUIFontType18 isBold:false];
            [_buttonCancel setTitleColor:[Utility getUIColor:kUIColorBlue] forState:UIControlStateNormal];
            [_buttonCancel setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 16)];
            _buttonCancel.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            [viewMain addSubview:_buttonCancel];
            UILabel* labelTemp= [[UILabel alloc] init];
            [labelTemp setUIFont:kUIFontType24 isBold:false];
            float fontHeight = [[labelTemp font] lineHeight];
            float posY = CGRectGetMaxY(viewTop.frame) + viewMain.frame.size.width * 0.05f;
            float width = viewMain.frame.size.width * 0.70f;
            float posX = (viewMain.frame.size.width - width)/2;
            float height = fontHeight * 2.0f;
            float gap = height/4;
            
            //            posY = (heightView - CGRectGetMaxY(viewTop.frame) - height * 7.5 - gap * 6)/2;
            posY = CGRectGetMaxY(viewTop.frame) + gap * 2;
            
            _rp_textfield_old_pass = [self createTextField:viewMain fontType:kUIFontType18 fontColorType:kUIColorFontDark frame:CGRectMake(posX, posY, width, height) tag:_kTAGTEXTFIELD_RP_OLD_PASS textStrPlaceHolder:Localize(@"prompt_current_password")];
            _rp_textfield_old_pass.textAlignment = NSTextAlignmentLeft;
            [_rp_textfield_old_pass setSecureTextEntry:true];
            [_rp_textfield_old_pass setUIFont:kUIFontType18 isBold:true];
            posY += (height+gap);
            
            _rp_textfield_new_pass = [self createTextField:viewMain fontType:kUIFontType18 fontColorType:kUIColorFontDark frame:CGRectMake(posX, posY, width, height) tag:_kTAGTEXTFIELD_RP_NEW_PASS textStrPlaceHolder:Localize(@"prompt_new_password")];
            _rp_textfield_new_pass.textAlignment = NSTextAlignmentLeft;
            [_rp_textfield_new_pass setSecureTextEntry:true];
            [_rp_textfield_new_pass setUIFont:kUIFontType18 isBold:true];
            posY += (height+gap);
            
            _rp_textfield_new_confirm_pass = [self createTextField:viewMain fontType:kUIFontType18 fontColorType:kUIColorFontDark frame:CGRectMake(posX, posY, width, height) tag:_kTAGTEXTFIELD_RP_NEW_CONFIRM_PASS textStrPlaceHolder:Localize(@"prompt_password_confirm")];
            _rp_textfield_new_confirm_pass.textAlignment = NSTextAlignmentLeft;
            [_rp_textfield_new_confirm_pass setSecureTextEntry:true];
            [_rp_textfield_new_confirm_pass setUIFont:kUIFontType18 isBold:true];
            posY += (height+gap);
            posY += (height+gap);
            
            _rp_button = [[UIButton alloc] initWithFrame:CGRectMake(posX, posY, width, height)];
            [_rp_button setBackgroundColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
            [[_rp_button titleLabel] setUIFont:kUIFontType22 isBold:false];
            [_rp_button setTitle:Localize(@"action_reset_password") forState:UIControlStateNormal];
            [_rp_button setTitleColor:[Utility getUIColor:kUIColorBuyButtonFont] forState:UIControlStateNormal];
            [viewMain addSubview:_rp_button];
            [_rp_button addTarget:self action:@selector(resetPassword) forControlEvents:UIControlEventTouchUpInside];
            
            posY += (height+gap);
            posY += viewMain.frame.size.width * 0.5f;
            
            self.popupControllerResetPassword.theme.size = CGSizeMake(widthView, MIN(heightView, posY));
            CGRect viewMainFrame = viewMain.frame;
            viewMainFrame.size = CGSizeMake(widthView, MIN(heightView, posY));
            viewMain.frame = viewMainFrame;
        }
        [self.popupControllerResetPassword presentPopupControllerAnimated:YES];
        _rp_textfield_old_pass.text = @"";
        _rp_textfield_new_pass.text = @"";
        _rp_textfield_new_confirm_pass.text = @"";
    }
}
- (void)resetPassword {
    AppUser* appUser = [AppUser sharedManager];
    NSString* email = appUser._email;
    NSString* oldPasswordActual = appUser._password;
    NSString* oldPassword = _rp_textfield_old_pass.text;
    NSString* newPassword = _rp_textfield_new_pass.text;
    NSString* newPasswordConfirm = _rp_textfield_new_confirm_pass.text;
    
    if ([oldPassword isEqualToString:@""] ||
        [newPassword isEqualToString:@""] ||
        [newPasswordConfirm isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:Localize(@"all_fields_are_mendatory") delegate:self cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil];
        [alert show];
        return;
    }
    //    if (![oldPasswordActual isEqualToString:oldPassword]) {
    //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:Localize(@"rp_old_password_did_not_matched") delegate:self cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil];
    //        [alert show];
    //        return;
    //    }
    if (![newPassword isEqualToString:newPasswordConfirm]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:Localize(@"passwords_mismatch") delegate:self cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil];
        [alert show];
        return;
    }
    //    if ([oldPassword isEqualToString:newPasswordConfirm]) {
    //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:Localize(@"rp_same_password") delegate:self cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil];
    //        [alert show];
    //        return;
    //    }
    
    [[[DataManager sharedManager] tmDataDoctor] pluginResetPassword:email oldPassword:oldPassword newPassword:newPassword success:^(NSString *str) {
        RLOG(@"%@",str);
        [self.popupControllerResetPassword dismissPopupControllerAnimated:YES];
        appUser._password = newPassword;
        [appUser saveData];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:str delegate:self cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil];
        [alert show];
    } failure:^(NSString *error) {
        RLOG(@"%@",error);
        if (![error isEqualToString:@"failure"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Localize(@"sorry") message:error delegate:self cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil];
            [alert show];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Localize(@"sorry") message:Localize(@"try_again") delegate:self cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil];
            [alert show];
        }
    }];
}
- (void)resetPasswordCancelBtnClicked:(UIButton*)button {
    [self.popupControllerResetPassword dismissPopupControllerAnimated:YES];
}

- (void)backgroundTouchEventRegistered:(CNPPopupController *)controller {
    RLOG(@"backgroundTouchEventRegistered:");
    [self removeVC];
}
- (void)removeVC {
    if ([Utility isSellerOnlyApp]) {
        [self.navigationController popViewControllerAnimated:YES];
        if (self.didDismiss) {
            self.didDismiss(@"some extra data");
        }
    }
}

- (void) onSellerZoneClick {
    [mainVC.revealController revealToggle:self];

    SellerInfo* sellerInfo = [SellerInfo getCurrentSeller];
    if (sellerInfo == nil) {
        return;
    }
    
    if(!sellerInfo.isSellerVerified) {
        Addons* addons = [Addons sharedManager];
        if (addons.multiVendor && addons.multiVendor.multiVendor_shop_settings && addons.multiVendor.multiVendor_shop_settings.enable_subscription) {
            if ([sellerInfo membership_status] && ![[sellerInfo membership_status] isEqualToString:@""] && ![[sellerInfo membership_status] isEqualToString:@"active"]) {
//                [mainVC.revealController revealToggle:self];
                [self showSubscriptionDialog];
                return;
            }
        }
        
        //TODO show message
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:Localize(@"seller_subscription_dialog_title") message:Localize(@"seller_verification_is_pending") delegate:self cancelButtonTitle:Localize(@"btn_yes") otherButtonTitles:Localize(@"btn_no"), nil];
        [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 0) {
                
                    mainVC.containerTop.hidden = YES;
                    mainVC.containerCenter.hidden = YES;
                    mainVC.containerCenterWithTop.hidden = NO;
                    mainVC.vcBottomBar.buttonHome.selected = YES;
                    mainVC.vcBottomBar.buttonCart.selected = NO;
                    mainVC.vcBottomBar.buttonWishlist.selected = NO;
                    mainVC.vcBottomBar.buttonSearch.selected = NO;
                    mainVC.revealController.panGestureEnable = false;
                    [mainVC.vcBottomBar buttonClicked:nil];
                    ViewControllerWebview* vcWebview = (ViewControllerWebview*)[[Utility sharedManager] pushScreenWithoutAnimation:mainVC.vcCenterTop type:PUSH_SCREEN_TYPE_WEBVIEW];
                    [vcWebview loadAllViews:sellerInfo.subscription_url];

            }
        }];
        return;
    }
    
    mainVC.containerTop.hidden = YES;
    mainVC.containerCenter.hidden = YES;
    mainVC.containerCenterWithTop.hidden = NO;
    mainVC.vcBottomBar.buttonHome.selected = YES;
    mainVC.vcBottomBar.buttonCart.selected = NO;
    mainVC.vcBottomBar.buttonWishlist.selected = NO;
    mainVC.vcBottomBar.buttonSearch.selected = NO;
    mainVC.revealController.panGestureEnable = false;
    [mainVC.vcBottomBar buttonClicked:nil];
    
    //[mainVC hideBottomBar];
//    ViewControllerSellerZone* vcSellerZone = (ViewControllerSellerZone*)[[Utility sharedManager] pushScreenWithoutAnimation:mainVC.vcCenterTop type:PUSH_SCREEN_TYPE_SELLER_ZONE];
     ViewControllerSellerZone* vcSellerZone = (ViewControllerSellerZone*)[[Utility sharedManager] pushOverScreenWithoutAnimation:mainVC.vcCenterTop type:PUSH_SCREEN_TYPE_SELLER_ZONE];
        [vcSellerZone setDelegate:self];
//    [mainVC.revealController revealToggle:self];
}

- (void) showSubscriptionDialog {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:Localize(@"seller_subscription_dialog_title") message:Localize(@"seller_subscription_dialog_msg") delegate:self cancelButtonTitle:Localize(@"btn_yes") otherButtonTitles:Localize(@"btn_no"), nil];
    [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 0) {
            mainVC.containerTop.hidden = YES;
            mainVC.containerCenter.hidden = YES;
            mainVC.containerCenterWithTop.hidden = NO;
            mainVC.vcBottomBar.buttonHome.selected = YES;
            mainVC.vcBottomBar.buttonCart.selected = NO;
            mainVC.vcBottomBar.buttonWishlist.selected = NO;
            mainVC.vcBottomBar.buttonSearch.selected = NO;
            mainVC.revealController.panGestureEnable = false;
            [mainVC.vcBottomBar buttonClicked:nil];
            
            SellerInfo*sellerInfo = nil;
            ViewControllerWebview* vcWebview = (ViewControllerWebview*)[[Utility sharedManager] pushScreenWithoutAnimation:mainVC.vcCenterTop type:PUSH_SCREEN_TYPE_WEBVIEW];
            [vcWebview loadAllViews:sellerInfo.subscription_url];

        } else if (buttonIndex == 1) {
          [mainVC.revealController revealToggle:self];
        }
    }];
}
@end
