//
//  ViewControllerMyAccount.m
//  eCommerceApp
//
//  Created by Rishabh Jain on 16/09/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import "ViewControllerMyAccount.h"
#import "SWRevealViewController.h"
#import "Variables.h"
#import "RATreeView.h"
#import "RADataObject.h"
#import "RATableViewCell.h"
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
#import "ViewControllerWebview.h"
#import "LoginFlow.h"
#import "ParseHelper.h"
#if ENABLE_HOTLINE
#import "Hotline.h"
#endif
#import "CustomMenu.h"

#define SINGLE_LINE 0
#define REGISTRATION_HIDE_USERNAME 1
#define LOGIN_HIDE_FORGET_PASSWORD 0
#define NEW_CHU 1
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
    
    
    BUTTONS_ID_REWARDS = 50,
    BUTTONS_ID_HELP_AND_SUPPORT = 51,
    BUTTONS_ID_TERMS_AND_CONDITIONS = 52,
    BUTTONS_ID_LANGUAGES = 53,
    BUTTONS_ID_TOTAL
};


@interface ViewControllerMyAccount () <RATreeViewDelegate, RATreeViewDataSource, UITableViewDataSource, UITableViewDelegate, CNPPopupControllerDelegate, UITextFieldDelegate>

@property (strong, nonatomic) NSMutableArray *dataObjects;
@property (weak, nonatomic) RATreeView *treeView;
@property (strong, nonatomic) UIBarButtonItem *editButton;
@property (nonatomic, strong) CNPPopupController *popupController;
@property (nonatomic, strong) CNPPopupController *popupControllerRegister;
@property (nonatomic, strong) CNPPopupController *popupControllerForgotPassword;
@property (nonatomic, strong) CNPPopupController *popupControllerSettings;
@end


@implementation ViewControllerMyAccount
#pragma mark - View Life Cycle
- (void)viewDidLoad {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super viewDidLoad];
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
#if (INTEGRATE_LOGIN_FB_OLD)
    _fbLoginButton = [[FBLoginView alloc] init];
    _fbLoginButton.delegate = self;
    _fbLoginButton.readPermissions = @[@"public_profile", @"email"];
#elif (INTEGRATE_LOGIN_FB_NEW)
    _fbLoginButton = [[FBSDKLoginButton alloc] init];
    _fbLoginButton.delegate = self;
    _fbLoginButton.readPermissions = @[@"public_profile", @"email"];
#endif
    [self loadData];
    
    //ADD LOGIN VIEW ON TOP
    float topViewHeight = [[Utility sharedManager] getTopBarHeight];
    CGRect topRect = self.view.bounds;
    topRect.size.height = topViewHeight;
    headerView = [[UIView alloc] initWithFrame:topRect];
    headerView.backgroundColor = [UIColor whiteColor];
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
    [buttonDrawer addTarget:[[ViewControllerMain getInstance] revealController] action: @selector(revealToggle:) forControlEvents: UIControlEventTouchUpInside];
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
}

- (void)viewWillAppear:(BOOL)animated {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super viewWillAppear:animated];
    
    [SDWebImageManager.sharedManager.imageDownloader setValue:@"SDWebImage Demo" forHTTPHeaderField:@"AppName"];
    SDWebImageManager.sharedManager.imageDownloader.executionOrder = SDWebImageDownloaderLIFOExecutionOrder;
    
    int systemVersion = [[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."][0] intValue];
    if (systemVersion >= 7 && systemVersion < 8) {
        CGRect statusBarViewRect = [[UIApplication sharedApplication] statusBarFrame];
        float heightPadding = statusBarViewRect.size.height+self.navigationController.navigationBar.frame.size.height;
        self.treeView.contentInset = UIEdgeInsetsMake(heightPadding, 0.0, 0.0, 0.0);
        self.treeView.contentOffset = CGPointMake(0.0, -heightPadding);
    }
    [tableView setNeedsLayout];
    
    [self adjustViewsAfterOrientation:UIDeviceOrientationUnknown];
    
}
- (void)flushCache {
    [SDWebImageManager.sharedManager.imageCache clearMemory];
    [SDWebImageManager.sharedManager.imageCache clearDisk];
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
    //    [cell.label_name setText:dataObject.title];
    [cell.label_name setText:[[Utility getNormalStringFromAttributed:dataObject.title] capitalizedString]];
    [cell.label_name setUIFont:kUIFontType16 isBold:false];
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        [cell.label_name setTextAlignment:NSTextAlignmentRight];
    } else {
        [cell.label_name setTextAlignment:NSTextAlignmentLeft];
    }
    
    CGRect img_iconFrame = cell.img_icon.frame;
    img_iconFrame.origin.x = _gap + (_gap*2) * level;
    cell.img_icon.frame = img_iconFrame;
    [cell.img_icon setUIImage:[UIImage imageNamed:dataObject.imgPath]];
    
    CGRect label_nameFrame = cell.label_name.frame;
    label_nameFrame.origin.x = img_iconFrame.origin.x + img_iconFrame.size.width + _gap;
    cell.label_name.frame = label_nameFrame;
    
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
    ViewControllerMain* mainVC = [ViewControllerMain getInstance];
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
                case BUTTONS_ID_CONTACT_US:
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
                    [vcWebview loadAllViews:[[[DataManager sharedManager] tmDataDoctor] pagelinkContactUs]];
} else {
                    ViewControllerWebview* vcWebview = (ViewControllerWebview*)[[Utility sharedManager] pushScreenWithoutAnimation:mainVC.vcCenterTop type:PUSH_SCREEN_TYPE_WEBVIEW];
                    [vcWebview loadAllViews:[[[DataManager sharedManager] tmDataDoctor] pagelinkContactUs]];
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
                    
                case BUTTONS_ID_LANGUAGES:
                {
                    //todo
                    [self showLanguageSelectionScreen];
                }break;
                    
#if ENABLE_HOTLINE
                case BUTTONS_ID_LIVE_CHAT:
                {
                    if ([[Addons sharedManager] hotline] && [[[Addons sharedManager] hotline] isEnabled]) {
                        [[Hotline sharedInstance] showConversations:self];
                    }
                }break;
#endif
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
                    break;
                case BUTTONS_ID_CATEGORIES:
                    break;
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
                } break;
                case BUTTONS_ID_HELP_AND_SUPPORT:
                {
                } break;
                case BUTTONS_ID_LOGOUT:
                {
                    switch ([[AppUser sharedManager] _userLoggedInVia]) {
                        case SA_PROVIDERS_FACEBOOK:
                        {
#if (INTEGRATE_LOGIN_FB_OLD)
                            FBSession* session = [FBSession activeSession];
                            RLOG(@"accesstoken=%@", session.accessTokenData.accessToken);
                            [session closeAndClearTokenInformation];
                            [session close];
                            [FBSession setActiveSession:nil];
                            
                            NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
                            NSArray* facebookCookies = [cookies cookiesForURL:[NSURL URLWithString:@"https://facebook.com/"]];
                            
                            for (NSHTTPCookie* cookie in facebookCookies) {
                                [cookies deleteCookie:cookie];
                            }
#endif
                            
#if (INTEGRATE_LOGIN_FB_NEW)
                            [FBSDKAccessToken setCurrentAccessToken:nil];
                            [FBSDKProfile setCurrentProfile:nil];
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
#pragma mark - Helpers
- (void)addItems:(int)itemId item:(RADataObject*)item {
    int i = itemId;
    {
        NSString* itemName = @"default";
        NSString* itemImagePath = @"default";
        NSString* itemImageExpandPath = @"img_arrow_down.png";
        NSString* itemImageCollapsePath = @"img_arrow_up.png";
        BOOL isEnable = true;
        item = [[RADataObject alloc] init];
        item.objId = i;
        if (isEnable) {
            if(![itemName compare:@"default"]){
                switch (i) {
                    case BUTTONS_ID_HOME:
                        itemName = Localize(@"Home");
                        itemImagePath = @"btn_home.png";
                        break;
                    case BUTTONS_ID_WISHLIST:
                        itemName = Localize(@"Wishlist");
                        itemImagePath = @"btn_wishlist.png";
                        break;
                    case BUTTONS_ID_SEARCH:
                        itemName = Localize(@"Search");
                        itemImagePath = @"btn_search.png";
                        if ([[MyDevice sharedManager] isIpad]) {
                            isEnable = NO;
                        }
                        break;
                    case BUTTONS_ID_CART:
                        itemName = Localize(@"Cart");
                        itemImagePath = @"btn_cart.png";
                        break;
                    case BUTTONS_ID_CATEGORIES:
                        itemName = Localize(@"Categories");
                        itemImagePath = @"btn_category.png";
                        categoryObject = item;
                        break;
                    case BUTTONS_ID_ORDERS:
                        if (_isUserLoggedIn) {
                            itemName = Localize(@"My Order");
                            itemImagePath = @"btn_myOrder.png";
                        } else {
                            isEnable = NO;
                        }
                        break;
                    case BUTTONS_ID_REWARDS:
                        if (_isUserLoggedIn) {
                            itemName = Localize(@"My Rewards");
                            itemImagePath = @"btn_myOrder.png";
                        } else {
                            isEnable = NO;
                        }
                        break;
                    case BUTTONS_ID_ADDRESS:
                        if (_isUserLoggedIn) {
                            itemName = Localize(@"My Address");
                            itemImagePath = @"btn_myOrder.png";
                        } else {
                            isEnable = NO;
                        }
                        break;
                    case BUTTONS_ID_HELP_AND_SUPPORT:
                        itemName = Localize(@"Help & Support");
                        itemImagePath = @"btn_chat.png";
                        helpAndSupportObject = item;
                        break;
                    case BUTTONS_ID_RATE_APP:
                        itemName = Localize(@"Rate This App");
                        //                        itemImagePath = @"btn_chat.png";
                        rateThisAppObject = item;
                        break;
                    case BUTTONS_ID_SETTINGS:
                        itemName = Localize(@"Settings");
                        itemImagePath = @"btn_setting.png";
                        settingObject = item;
                        if(![[TMLanguage sharedManager] isLocalizationVisible]) {
                            isEnable = NO;
                        }
                        break;
                        
                    case BUTTONS_ID_LOGIN:
                        if (_isUserLoggedIn) {
                            isEnable = NO;
                        }else{
                            itemName = Localize(@"Login");
                            itemImagePath = @"btn_logout.png";
                        }
                        break;
                    case BUTTONS_ID_LOGOUT:
                        if (_isUserLoggedIn) {
                            itemName = Localize(@"Logout");
                            itemImagePath = @"btn_logout.png";
                        }else{
                            isEnable = NO;
                        }
                        break;
#if ENABLE_HOTLINE
                    case BUTTONS_ID_LIVE_CHAT:
                        if ([[Addons sharedManager] hotline] && [[[Addons sharedManager] hotline] isEnabled]) {
                            itemName = Localize(@"Live Chat");
                            itemImagePath = @"btn_chat.png";
                        }else{
                            isEnable = NO;
                        }
                        break;
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
                [self.dataObjects addObject:item];
            }
        }
    }
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
    
    self.dataObjects = [[NSMutableArray alloc] init];
    RADataObject *item[BUTTONS_ID_TOTAL];
    for (int i = 0; i < BUTTONS_ID_TOTAL; i++) {
        item[i] = [[RADataObject alloc] init];
    }
    categoryObject = nil;
    settingObject = nil;
    helpAndSupportObject = nil;
    rateThisAppObject = nil;
    menuObjects = nil;
    Addons* addons = [Addons sharedManager];
if (_isMyAccountScreen) {
    if (addons.drawer_items) {
        for (DrawerItem* drawerItem in addons.profile_items) {
            [self addItems:drawerItem.itemId item:item[drawerItem.itemId]];
        }
    } else {
        [self addItems:BUTTONS_ID_ADDRESS item:item[BUTTONS_ID_ADDRESS]];
        [self addItems:BUTTONS_ID_ORDERS item:item[BUTTONS_ID_ORDERS]];
        [self addItems:BUTTONS_ID_REWARDS item:item[BUTTONS_ID_REWARDS]];
        [self addItems:BUTTONS_ID_RATE_APP item:item[BUTTONS_ID_RATE_APP]];
        [self addItems:BUTTONS_ID_LIVE_CHAT item:item[BUTTONS_ID_LIVE_CHAT]];
        [self addItems:BUTTONS_ID_HELP_AND_SUPPORT item:item[BUTTONS_ID_HELP_AND_SUPPORT]];
        [self addItems:BUTTONS_ID_LOGOUT item:item[BUTTONS_ID_LOGOUT]];
    }
} else {
    if (addons.drawer_items) {
        for (DrawerItem* drawerItem in addons.drawer_items) {
            [self addItems:drawerItem.itemId item:item[drawerItem.itemId]];
        }
    } else {
        [self addItems:BUTTONS_ID_HOME item:item[BUTTONS_ID_HOME]];
        [self addItems:BUTTONS_ID_CATEGORIES item:item[BUTTONS_ID_CATEGORIES]];
        [self addItems:BUTTONS_ID_MENU_ITEMS item:item[BUTTONS_ID_MENU_ITEMS]];
        [self addItems:BUTTONS_ID_CART item:item[BUTTONS_ID_CART]];
        [self addItems:BUTTONS_ID_WISHLIST item:item[BUTTONS_ID_WISHLIST]];
        [self addItems:BUTTONS_ID_SEARCH item:item[BUTTONS_ID_SEARCH]];
        [self addItems:BUTTONS_ID_ORDERS item:item[BUTTONS_ID_ORDERS]];
        [self addItems:BUTTONS_ID_SETTINGS item:item[BUTTONS_ID_SETTINGS]];
        [self addItems:BUTTONS_ID_HELP_AND_SUPPORT item:item[BUTTONS_ID_HELP_AND_SUPPORT]];
        [self addItems:BUTTONS_ID_LIVE_CHAT item:item[BUTTONS_ID_LIVE_CHAT]];
        [self addItems:BUTTONS_ID_RATE_APP item:item[BUTTONS_ID_RATE_APP]];
        [self addItems:BUTTONS_ID_LOGIN item:item[BUTTONS_ID_LOGIN]];
        [self addItems:BUTTONS_ID_LOGOUT item:item[BUTTONS_ID_LOGOUT]];
    }
}
    RLOG(@"%@",[CategoryInfo getAllRootCategories]);
    
    if([[TMLanguage sharedManager] isLocalizationVisible]) {
        [self addSettingObjects:settingObject];
    }
    [self addHelpAndSupportObjects:helpAndSupportObject];
    [self addCategoriesRecursive:categoryObject categoryArray:[CategoryInfo getAllRootCategories]];
    
    [self.dataObjects addObject:[[RADataObject alloc] init]];
    [self.dataObjects addObject:[[RADataObject alloc] init]];
    [self.dataObjects addObject:[[RADataObject alloc] init]];
    [self.dataObjects addObject:[[RADataObject alloc] init]];
    [self.dataObjects addObject:[[RADataObject alloc] init]];
    
if (_isMyAccountScreen) {
} else {
    int categoryObjIndex = (int)[self.dataObjects indexOfObject:categoryObject];
    [self addCustomMenu:categoryObjIndex + 1];
}
}
- (void)addCustomMenu:(int)objIndex {
    Addons* addons = [Addons sharedManager];
    if (addons.show_wordpress_menu) {
        CustomMenu* cMenu = [CustomMenu sharedManager];
        for (CustomMenuItem* cMenuItem in cMenu.items) {
            BOOL needToShow = false;
            for (NSNumber* n in addons.wordpress_menu_ids) {
                int menuID = [n intValue];
                if (cMenuItem.itemId == menuID) {
                    needToShow = true;
                    break;
                }
            }
            if (needToShow) {
                RADataObject * raObj = [[RADataObject alloc] init];
                raObj.title = cMenuItem.itemName;
                raObj.objId = BUTTONS_ID_MENU_ITEMS;
                [self.dataObjects insertObject:raObj atIndex:objIndex++];
                [self addCustomMenuItems:raObj cMenuChildren:cMenuItem.itemChildren];
            }
        }
    }
}

- (void)addCustomMenuItems:(RADataObject*)raObj cMenuChildren:(NSMutableArray*)cMenuChildren{
    for (CustomMenuChild* cMenuChild in cMenuChildren) {
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
- (void)addHelpAndSupportObjects:(RADataObject*)_raDataObj {
    RADataObject * raObj1 = [[RADataObject alloc] init];
    raObj1.title = Localize(@"Contact Us");
    raObj1.objId = BUTTONS_ID_CONTACT_US;
    
    RADataObject * raObj2 = [[RADataObject alloc] init];
    raObj2.title = Localize(@"Terms And Conditions");
    raObj2.objId = BUTTONS_ID_TERMS_AND_CONDITIONS;
    
    //    RADataObject * raObj3 = [[RADataObject alloc] init];
    //    raObj3.title = Localize(@"Rate This App");
    //    raObj3.objId = BUTTONS_ID_RATE_APP;
    //    [_raDataObj addChild:raObj3];
    if (![[[[DataManager sharedManager] tmDataDoctor] pagelinkAboutUs] isEqualToString:@""]) {
        [_raDataObj addChild:raObj2];
    }
    [_raDataObj addChild:raObj1];
}
- (void)addSettingObjects:(RADataObject*)_raDataObj {
    RADataObject * raObj1 = [[RADataObject alloc] init];
    raObj1.title = Localize(@"Languages");
    raObj1.objId = BUTTONS_ID_LANGUAGES;
    [_raDataObj addChild:raObj1];
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
    [self adjustViewsAfterOrientation:[[UIDevice currentDevice] orientation]];
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
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
        [cell.labelUserId setText:Localize(@"Use your email address")];
    } else {
        [cell.labelUserId setText:[[AppUser sharedManager] _email]];
    }
    if ([[[AppUser sharedManager] _username] isEqualToString:@""]) {
        [cell.labelUserName setText:[NSString stringWithFormat:@"%@ / %@", Localize(@"Login"), Localize(@"Register")]];
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
    }
    if ([[[AppUser sharedManager] _avatar_url] isEqualToString:@""]) {
        [cell.imgUser setUIImage:[UIImage imageNamed:@"profile.png"]];
    } else {
        [Utility setImage:cell.imgUser url:[[AppUser sharedManager] _avatar_url] resizeType:kRESIZE_TYPE_NONE isLocal:false];
    }
    
    cell.imgUserBg.layer.cornerRadius = cell.imgUserBg.frame.size.height / 2;
    cell.imgUserBg.layer.masksToBounds = YES;
    cell.imgUserBg.layer.borderWidth = 0;
    
    cell.imgUser.layer.cornerRadius = cell.imgUser.frame.size.height / 2;
    cell.imgUser.layer.masksToBounds = YES;
    cell.imgUser.layer.borderWidth = 0;
    
    //    cell.imgTopLine.hidden = true;
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
    cell.labelUserName.center = CGPointMake(labelPosX, cell.labelUserName.center.y);
    cell.labelUserId.center = CGPointMake(labelPosX, cell.labelUserId.center.y);

if (_isMyAccountScreen) {
    [cell.labelUserName setUIFont:kUIFontType32 isBold:true];
    [cell.labelUserId setUIFont:kUIFontType20 isBold:true];
} else {
    [cell.labelUserName setUIFont:kUIFontType16 isBold:true];
    [cell.labelUserId setUIFont:kUIFontType10 isBold:true];
}
    [cell setNeedsLayout];
    return cell;
}
#pragma mark - UITableViewDelegate
// when user tap the row, what action you want to perform
- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_isUserLoggedIn == false) {
        [self showLoginPopup:true];
    }else {
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
if (_isMyAccountScreen) {
        ViewControllerAddress* vcAddress = (ViewControllerAddress*)[[Utility sharedManager] pushScreenWithNewAnimation:mainVC.vcCenterTop type:PUSH_SCREEN_TYPE_ADDRESS];
        RLOG(@"vcAddress = %@", vcAddress);
} else {
        ViewControllerAddress* vcAddress = (ViewControllerAddress*)[[Utility sharedManager] pushScreenWithoutAnimation:mainVC.vcCenterTop type:PUSH_SCREEN_TYPE_ADDRESS];
        RLOG(@"vcAddress = %@", vcAddress);

        [mainVC.revealController revealToggle:self];
}
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    RLOG(@"selected %d row", (int)indexPath.row);
}
- (void)clickOnCategory:(CategoryInfo*)categoryClicked currentItemData:(DataPass*)currentItemData{
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
- (void)showLoginPopup:(BOOL)withAnimation {
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
- (void)createLoginPopup{
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
        self.popupController.theme.shouldDismissOnBackgroundTouch = true;
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            self.popupController.VIEW_POPUP.transform = CGAffineTransformMakeScale(-1, 1);
        }
        
        UIButton* _buttonCancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, viewTop.frame.size.width, viewTop.frame.size.height)];
        [viewTop addSubview:_buttonCancel];
        [_buttonCancel addTarget:self action:@selector(cancelClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_buttonCancel sizeToFit];
        [_buttonCancel setFrame:CGRectMake(viewTop.frame.size.width * 0.04f, 0, _buttonCancel.frame.size.width, viewTop.frame.size.height)];
        
        
        
        
        UILabel* _labelTitle = [self createLabel:viewTop fontType:kUIFontType20 fontColorType:kUIColorFontDark frame:CGRectMake(0, 0, viewTop.frame.size.width, viewTop.frame.size.height) textStr:Localize(@"Sign in")];
        [_labelTitle setTextAlignment:NSTextAlignmentCenter];
        
        
        float posY = CGRectGetMaxY(viewTop.frame) + viewMain.frame.size.width * 0.05f;
        float width = viewMain.frame.size.width * 0.70f;
        float posX = (viewMain.frame.size.width - width)/2;
#if REGISTRATION_HIDE_USERNAME
        float height = (viewMain.frame.size.height - (posY - viewTop.frame.size.height) - posY)/9;
#else
        float height = (viewMain.frame.size.height - (posY - viewTop.frame.size.height) - posY)/10;
#endif
        float gap = height/2;
        if (totalSocialAuthItems == 0) {
            posY += (heightView * (1.0f - 0.63f) / 4);
        }
        
        
        
        _textLoginId = [self createTextField:viewMain fontType:kUIFontType20 fontColorType:kUIColorFontLight frame:CGRectMake(posX, posY, width, height) tag:_kTAGTEXTFIELD_LOGIN_ID textStrPlaceHolder:Localize(@" * Enter Email")];
        posY += (height+gap);
        
        _textLoginPassword = [self createTextField:viewMain fontType:kUIFontType20 fontColorType:kUIColorFontLight frame:CGRectMake(posX, posY, width, height) tag:_kTAGTEXTFIELD_LOGIN_PASSWORD textStrPlaceHolder:Localize(@" * Enter Password")];
        posY += (height+gap);
        [_textLoginPassword setSecureTextEntry:YES];
        
        UIButton *buttonLogin = [[UIButton alloc] initWithFrame:CGRectMake(posX, posY, width, height)];
        [buttonLogin setBackgroundColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
        [[buttonLogin titleLabel] setUIFont:kUIFontType22 isBold:false];
        [buttonLogin setTitle:Localize(@"Sign In") forState:UIControlStateNormal];
        [buttonLogin setTitleColor:[Utility getUIColor:kUIColorBuyButtonFont] forState:UIControlStateNormal];
        [viewMain addSubview:buttonLogin];
        [buttonLogin addTarget:self action:@selector(loginClicked:) forControlEvents:UIControlEventTouchUpInside];
        posY += (height+gap);
        
        
        UIButton* _buttonClickHere = [[UIButton alloc] initWithFrame:CGRectMake(posX, posY, width, height)];
        [[_buttonClickHere titleLabel] setUIFont:kUIFontType18 isBold:false];
        [_buttonClickHere setTitleColor:[Utility getUIColor:kUIColorThemeFont] forState:UIControlStateNormal];
        [viewMain addSubview:_buttonClickHere];
        [_buttonClickHere addTarget:self action:@selector(signupClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton* _buttonForgetPass = [[UIButton alloc] initWithFrame:CGRectMake(posX, posY, width, height)];
        [[_buttonForgetPass titleLabel] setUIFont:kUIFontType18 isBold:false];
        [_buttonForgetPass setTitleColor:[Utility getUIColor:kUIColorThemeFont] forState:UIControlStateNormal];
        [viewMain addSubview:_buttonForgetPass];
        [_buttonForgetPass addTarget:self action:@selector(forgotPasswordClicked:) forControlEvents:UIControlEventTouchUpInside];
#if (SINGLE_LINE)
        [_buttonClickHere setTitle:Localize(@"Click here to create new account /") forState:UIControlStateNormal];
        [_buttonForgetPass setTitle:Localize(@"Forgot Password?") forState:UIControlStateNormal];
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
        
        
        [_buttonClickHere setTitle:Localize(@" Sign up here") forState:UIControlStateNormal];
        [_buttonForgetPass setTitle:Localize(@"Forgot password?") forState:UIControlStateNormal];
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
        br2.origin.y = CGRectGetMaxY(br1) + buttonh1/2;
        br2.size.width = buttonw2;
        br2.size.height = buttonh2;
        
        [_buttonClickHere setFrame:br1];
        [_buttonForgetPass setFrame:br2];
        
#if (LOGIN_HIDE_FORGET_PASSWORD == 0)
        UILabel *faltuText = [[UILabel alloc] init];
        [faltuText setUIFont:kUIFontType18 isBold:false];
        faltuText.text = Localize(@"Don't have an account?");
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
        
        
        posY = heightView * .63f;
        gap = height/3;
        UIView *bottomBorder = [[UIView alloc] init];
        bottomBorder.frame = CGRectMake(0, posY, viewMain.frame.size.width, 2);
        bottomBorder.backgroundColor = [Utility getUIColor:kUIColorBorder];
        [viewMain addSubview:bottomBorder];
        
        UILabel* _labelGyan = [self createLabel:viewMain fontType:kUIFontType14 fontColorType:kUIColorFontLight frame:CGRectMake(0, posY, viewMain.frame.size.width, height) textStr:Localize(@"Sign-in with a simple click.")];
        [_labelGyan setTextAlignment:NSTextAlignmentCenter];
        posY += (height);
        
        
#if (INTEGRATE_LOGIN_FB_OLD || INTEGRATE_LOGIN_FB_NEW)
#else
        _fbLoginButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [_fbLoginButton setUIImage:[UIImage imageNamed:@"facebookLogin.png"] forState:UIControlStateNormal];
        [[_fbLoginButton imageView] setContentMode: UIViewContentModeScaleAspectFit];
        [_fbLoginButton addTarget:self action:@selector(fbClicked:) forControlEvents:UIControlEventTouchUpInside];
#endif
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
#if (INTEGRATE_LOGIN_FB_NEW || INTEGRATE_LOGIN_FB_OLD)
    [_fbLoginButton removeFromSuperview];
    [_fbLoginButton setFrame:_loginScreenRectFB];
    [_mainViewLogin addSubview:_fbLoginButton];
#else
    [_fbLoginButton removeFromSuperview];
    [_fbLoginButton setFrame:_loginScreenRectFB];
    [_mainViewLogin addSubview:_fbLoginButton];
#endif
    [_googleLoginButton removeFromSuperview];
    [_googleLoginButton setFrame:_loginScreenRectGoogle];
    [_mainViewLogin addSubview:_googleLoginButton];
    
    [_twitterLoginButton removeFromSuperview];
    [_twitterLoginButton setFrame:_loginScreenRectTwitter];
    [_mainViewLogin addSubview:_twitterLoginButton];
}

- (void)loginClicked:(UIButton*)button {
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
        NSString* description = Localize(@"No user found.");
        if ([notification object]) {
            NSMutableDictionary* dictionary =  [notification object];
            if(dictionary)
                description = [dictionary objectForKey:@"description"];
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Localize(@"Login Failed")
                                                        message:description
                                                       delegate:self
                                              cancelButtonTitle:Localize(@"OK")
                                              otherButtonTitles:nil];
        [alert show];
    }
}
- (void)signupClicked:(UIButton*)button {
    [self createRegisterPopup];
    if (button == nil) {
        [self.popupControllerRegister presentPopupControllerAnimated:YES];
    }else{
        [self.popupControllerRegister presentPopupControllerAnimated:NO];
    }
    [self.popupController dismissPopupControllerAnimated:NO];
    [self.popupControllerForgotPassword dismissPopupControllerAnimated:NO];
    
}
- (void)forgotPasswordClicked:(UIButton*)button {
    [self createForgotPasswordPopup];
    [self.popupControllerForgotPassword presentPopupControllerAnimated:NO];
    [self.popupControllerRegister dismissPopupControllerAnimated:NO];
    [self.popupController dismissPopupControllerAnimated:NO];
}
- (void)tryForFacebookWeb:(NSNotification *)notification{
    [self cancelClicked:nil];
    [[LoginFlow sharedManager] clickOnSimpleAuthItem:SA_PROVIDERS_FACEBOOK_WEB];
}
- (void)tryForTwitterWeb:(NSNotification *)notification{
    [self cancelClicked:nil];
    [[LoginFlow sharedManager] clickOnSimpleAuthItem:SA_PROVIDERS_TWITTER_WEB];
}
- (void)fbClicked:(UIButton*)button {
    if ([[Utility sharedManager] checkForDemoApp:true]) return;
    
    BOOL isInstalled = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fb://"]];
    if (isInstalled) {
        [[LoginFlow sharedManager] clickOnSimpleAuthItem:SA_PROVIDERS_FACEBOOK];
    } else {
        [self cancelClicked:nil];
        [[LoginFlow sharedManager] clickOnSimpleAuthItem:SA_PROVIDERS_FACEBOOK_WEB];
    }
}
- (void)googleClicked:(UIButton*)button {
    if ([[Utility sharedManager] checkForDemoApp:true]) return;
    
    [self cancelClicked:nil];
    [[GIDSignIn sharedInstance] signIn];
    //    [[LoginFlow sharedManager] clickOnSimpleAuthItem:SA_PROVIDERS_GOOGLE_WEB];
}
- (void)twitterClicked:(UIButton*)button {
    if ([[Utility sharedManager] checkForDemoApp:true]) return;
    
    BOOL isInstalled = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]];
    if (isInstalled) {
        [[LoginFlow sharedManager] clickOnSimpleAuthItem:SA_PROVIDERS_TWITTER];
    } else {
        [self cancelClicked:nil];
        [[LoginFlow sharedManager] clickOnSimpleAuthItem:SA_PROVIDERS_TWITTER_WEB];
    }
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
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"" message:Localize(@"Fields marked as ( * ) are mandatory.") delegate:nil cancelButtonTitle:Localize(@"OK") otherButtonTitles:nil, nil];
    [errorAlert show];
}
#pragma mark - CNPPopupController Delegate
- (void)popupController:(CNPPopupController *)controller didDismissWithButtonTitle:(NSString *)title {
    RLOG(@"Dismissed with button title: %@", title);
}
- (void)popupControllerDidPresent:(CNPPopupController *)controller {
    RLOG(@"Popup controller presented.");
}
#pragma mark - FBLoginView Delegate method implementation
#if (INTEGRATE_LOGIN_FB_OLD)
-(void)loginViewShowingLoggedInUser:(FBLoginView *)loginView{
    RLOG(@"You are logged in.");
}
-(void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user{
    RLOG(@"%@", user);
    AppUser* appuser = [AppUser sharedManager];
    appuser._email = [user objectForKey:@"email"];
    if ([[user objectForKey:@"middle_name"] isEqualToString:@""]) {
        appuser._first_name = [NSString stringWithFormat:@"%@", [user objectForKey:@"first_name"]];
    }else{
        appuser._first_name = [NSString stringWithFormat:@"%@ %@", [user objectForKey:@"first_name"],[user objectForKey:@"middle_name"]];
    }
    appuser._last_name = [user objectForKey:@"last_name"];
    NSString *imageUrl = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?redirect=true", [user objectForKey:@"id"]];
    appuser._avatar_url = imageUrl;//[NSString stringWithFormat:@"%@.png",[user objectForKey:@"id"]];
    
    if ([[user objectForKey:@"last_name"] isEqualToString:@""]) {
        appuser._username = [NSString stringWithFormat:@"%@", appuser._first_name];
    }else{
        appuser._username = [NSString stringWithFormat:@"%@ %@", appuser._first_name, appuser._last_name];
    }
    appuser._userLoggedInVia = SA_PROVIDERS_FACEBOOK;
    [self loggedIn:nil];
}
-(void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView{
    RLOG(@"You are logged out.");
    [self loggedOut];
}
-(void)loginView:(FBLoginView *)loginView handleError:(NSError *)error{
    RLOG(@"%@", [error localizedDescription]);
}
#endif
#if (INTEGRATE_LOGIN_FB_NEW)
- (void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error{
    RLOG(@"FB :loginButton:didCompleteWithResult:error");
    if ([FBSDKAccessToken currentAccessToken]) {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{ @"fields" : @"id, name, picture, email, first_name, last_name, middle_name, gender"}]startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                NSString *userEmailId = [result valueForKey:@"email"];
                NSString *userName = [result valueForKey:@"name"];
                NSString *userFName = [result valueForKey:@"first_name"];
                NSString *userMName = [result valueForKey:@"middle_name"];
                NSString *userLName = [result valueForKey:@"last_name"];
                NSString *userGender = [result valueForKey:@"gender"];
                NSString *userBirthday = [result valueForKey:@"birthday"];
                NSString *userImage = [[[result valueForKey:@"picture"] valueForKey:@"data"] valueForKey:@"url"];
                
                RLOG(@"userEmailId = %@", userEmailId);
                RLOG(@"userName = %@", userName);
                RLOG(@"userFName = %@", userFName);
                RLOG(@"userMName = %@", userMName);
                RLOG(@"userLName = %@", userLName);
                RLOG(@"userGender = %@", userGender);
                RLOG(@"userBirthday = %@", userBirthday);
                RLOG(@"userImage = %@", userImage);
                
                AppUser* appuser = [AppUser sharedManager];
                appuser._email = userEmailId;
                appuser._avatar_url = userImage;
                NSMutableString * str = [[NSMutableString alloc] init];
                if (![userFName isEqualToString:@""]) {
                    [str appendString:userFName];
                }
                if (![userMName isEqualToString:@""]) {
                    [str appendFormat:@" %@",userMName];
                }
                appuser._first_name = str;
                appuser._last_name = userLName;
                appuser._username = @"UniqueUserName";
                
                appuser._userLoggedInVia = SA_PROVIDERS_FACEBOOK;
                [self loggedIn:nil];
            }
        }];
    }
}
- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton{
    RLOG(@"FB :loginButtonDidLogOut:loginButton");
    [self loggedOut];
}
#endif
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
    
    [self.dataObjects removeAllObjects];
    [self loadData];
    [self adjustViewsAfterOrientation:0];
    //    [tableView setUserInteractionEnabled:false];
    
    [appuser saveData];
}
- (void)loggedOut{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"response_logout_clicked" object:nil];
    AppUser* appuser = [AppUser sharedManager];
    _textLoginId.text = @"";
    _textLoginPassword.text = @"";
    _textRegisterUsername.text = @"";
    _textRegisterPassword.text = @"";
    _textRegisterEmailId.text = @"";
    _textRegisterConfirmPassword.text = @"";
    _textForgotPasswordEmailId.text = @"";
    [appuser clearData];
    [appuser saveData];
    if (self.popupController) {
        [self.popupController dismissPopupControllerAnimated:YES];
    }
    if (self.popupControllerRegister) {
        [self.popupControllerRegister dismissPopupControllerAnimated:YES];
    }
    if (self.popupControllerForgotPassword) {
        [self.popupControllerForgotPassword dismissPopupControllerAnimated:YES];
    }
    [self.dataObjects removeAllObjects];
    [self loadData];
    [self adjustViewsAfterOrientation:0];
    //    [tableView setUserInteractionEnabled:true];
    
}
- (void)dataFetchCompletion:(ServerData *)serverData{
    
    [[LoginFlow sharedManager] dataFetchCompletion:serverData];
    return;
    if (serverData._serverRequestStatus == kServerRequestSucceed) {
        RLOG(@"=======DATA_FETCHING:SUCCESS=======");
        RLOG(@"_serverUrl = %@",serverData._serverUrl);
        RLOG(@"_serverDataId = %d",serverData._serverDataId);
        //        RLOG(@"_serverRequestName = %@",serverData._serverRequestName);
        RLOG(@"_serverResultDictionary = %@",serverData._serverResultDictionary);
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:serverData._serverResultDictionary options:NSJSONWritingPrettyPrinted error:&error];
        if (! jsonData) {
            RLOG(@"Got an error: %@", error);
        } else {
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            [[NSUserDefaults standardUserDefaults] setObject:jsonString forKey:serverData._serverUrl];
        }
    }
    
    BOOL isUserExists = false;
    if (serverData._serverRequestStatus == kServerRequestSucceed) {
        switch (serverData._serverDataId) {
            case kFetchCustomer:
            {
                NSDictionary* mainDict = nil;
                if (IS_NOT_NULL(serverData._serverResultDictionary, @"customer")) {
                    mainDict = [serverData._serverResultDictionary objectForKey:@"customer"];
                    if (IS_NOT_NULL(mainDict, @"username")) {
                        isUserExists = true;
                        _wpWebView.loginFillData_userName = GET_VALUE_STRING(mainDict, @"username");
                        [_wpWebView loadLoginPage];
                    }
                }
            }break;
            case kFetchOrders:
            {
                [[DataManager sharedManager] loadOrdersData: serverData._serverResultDictionary];
                
            } break;
            default:
                break;
        }
    }
    
    if(isUserExists == false && serverData._serverDataId == kFetchCustomer)
    {
        _wpWebView.isUserAuthenticated = false;
        _wpWebView.isUserLoggedIn = false;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginFailed" object:nil];
    }
}

- (void)createRegisterPopup{
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
            
        }else if ([[MyDevice sharedManager] isIphone]) {
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
        self.popupControllerRegister.theme.shouldDismissOnBackgroundTouch = true;
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            self.popupControllerRegister.VIEW_POPUP.transform = CGAffineTransformMakeScale(-1, 1);
        }
        
        UIButton* _buttonCancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, viewTop.frame.size.width, viewTop.frame.size.height)];
        //        [_buttonCancel setImage:[[UIImage imageNamed:@"img_arrow_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        //        [_buttonCancel setTitle:@"Cancel" forState:UIControlStateNormal];
        [_buttonCancel setTintColor:[Utility getUIColor:kUIColorThemeFont]];
        //        [_buttonCancel setTitleColor:[Utility getUIColor:kUIColorThemeFont] forState:UIControlStateNormal];
        //        [_buttonCancel.titleLabel setUIFont:kUIFontType18 isBold:false];
        [viewTop addSubview:_buttonCancel];
        [_buttonCancel addTarget:self action:@selector(cancelClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_buttonCancel sizeToFit];
        [_buttonCancel setFrame:CGRectMake(viewTop.frame.size.width * 0.04f, 0, _buttonCancel.frame.size.width, viewTop.frame.size.height)];
        
        UILabel* _labelTitle = [self createLabel:viewTop fontType:kUIFontType20 fontColorType:kUIColorFontDark frame:CGRectMake(0, 0, viewTop.frame.size.width, viewTop.frame.size.height) textStr:Localize(@"New User")];
        [_labelTitle setTextAlignment:NSTextAlignmentCenter];
        
        
        float posY = CGRectGetMaxY(viewTop.frame) + viewMain.frame.size.width * 0.05f;
        float width = viewMain.frame.size.width * 0.70f;
        float posX = (viewMain.frame.size.width - width)/2;
#if REGISTRATION_HIDE_USERNAME
        float height = (viewMain.frame.size.height - (posY - viewTop.frame.size.height) - posY)/9;
#else
        float height = (viewMain.frame.size.height - (posY - viewTop.frame.size.height) - posY)/10;
#endif
        float gap = height/4;
        if (totalSocialAuthItems == 0) {
            posY += (heightView * (1.0f - 0.63f) / 4);
        }
        
        _textRegisterUsername = [self createTextField:viewMain fontType:kUIFontType20 fontColorType:kUIColorFontLight frame:CGRectMake(posX, posY, width, height) tag:_kTAGTEXTFIELD_R_USERNAME textStrPlaceHolder:Localize(@" * Enter Username")];
#if REGISTRATION_HIDE_USERNAME
        _textRegisterUsername.hidden = true;
#else
        posY += (height+gap);
#endif
        
        _textRegisterEmailId = [self createTextField:viewMain fontType:kUIFontType20 fontColorType:kUIColorFontLight frame:CGRectMake(posX, posY, width, height) tag:_kTAGTEXTFIELD_R_EMAIL textStrPlaceHolder:Localize(@" * Enter Email")];
        posY += (height+gap);
        
        _textRegisterPassword = [self createTextField:viewMain fontType:kUIFontType20 fontColorType:kUIColorFontLight frame:CGRectMake(posX, posY, width, height) tag:_kTAGTEXTFIELD_R_PASSWORD textStrPlaceHolder:Localize(@" * Enter Password")];
        posY += (height+gap);
        
        _textRegisterConfirmPassword = [self createTextField:viewMain fontType:kUIFontType20 fontColorType:kUIColorFontLight frame:CGRectMake(posX, posY, width, height) tag:_kTAGTEXTFIELD_R_CPASSWORD textStrPlaceHolder:Localize(@" * Confirm Password")];
        posY += (height+gap);
        
        [_textRegisterPassword setSecureTextEntry:YES];
        [_textRegisterConfirmPassword setSecureTextEntry:YES];
        
        UIButton *buttonRegister = [[UIButton alloc] initWithFrame:CGRectMake(posX, posY, width, height)];
        [buttonRegister setBackgroundColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
        [[buttonRegister titleLabel] setUIFont:kUIFontType22 isBold:false];
        [buttonRegister setTitle:Localize(@"Register") forState:UIControlStateNormal];
        [buttonRegister setTitleColor:[Utility getUIColor:kUIColorBuyButtonFont] forState:UIControlStateNormal];
        [viewMain addSubview:buttonRegister];
        [buttonRegister addTarget:self action:@selector(registerClicked:) forControlEvents:UIControlEventTouchUpInside];
        //        posY += (height+gap);
        posY += (height);
        //////////////////////////
        
        
        
        
        
        UIButton* _buttonClickHere = [[UIButton alloc] initWithFrame:CGRectMake(posX, posY, width, height)];
        [[_buttonClickHere titleLabel] setUIFont:kUIFontType18 isBold:false];
        [_buttonClickHere setTitleColor:[Utility getUIColor:kUIColorThemeFont] forState:UIControlStateNormal];
        [viewMain addSubview:_buttonClickHere];
        [_buttonClickHere addTarget:self action:@selector(registerBackClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_buttonClickHere setTitle:Localize(@" Sign in here") forState:UIControlStateNormal];
        float buttonw1 = LABEL_SIZE([_buttonClickHere titleLabel]).width;
        CGRect br1 = _buttonClickHere.frame;
        br1.origin.x = widthView * 0.10f;
        br1.size.width = buttonw1;
        [_buttonClickHere setFrame:br1];
        
        
        UILabel *faltuText = [[UILabel alloc] init];
        [faltuText setUIFont:kUIFontType18 isBold:false];
        faltuText.text = Localize(@"Already have an account?");
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
        
        
        
        
        
        
        
        
        
        
        
        
        
        //////////////////////////
        posY = heightView * .63f;
        gap = height/3;
        UIView *bottomBorder = [[UIView alloc] init];
        bottomBorder.frame = CGRectMake(0, posY, viewMain.frame.size.width, 2);
        bottomBorder.backgroundColor = [Utility getUIColor:kUIColorBorder];
        [viewMain addSubview:bottomBorder];
        
        UILabel* _labelGyan = [self createLabel:viewMain fontType:kUIFontType14 fontColorType:kUIColorFontLight frame:CGRectMake(0, posY, viewMain.frame.size.width, height) textStr:Localize(@"Sign-in with a simple click.")];
        [_labelGyan setTextAlignment:NSTextAlignmentCenter];
        posY += (height);
        
        
        
        
#if (INTEGRATE_LOGIN_FB_OLD || INTEGRATE_LOGIN_FB_NEW)
#else
        _fbLoginButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [_fbLoginButton setUIImage:[UIImage imageNamed:@"facebookLogin.png"] forState:UIControlStateNormal];
        [[_fbLoginButton imageView] setContentMode: UIViewContentModeScaleAspectFit];
        [_fbLoginButton addTarget:self action:@selector(fbClicked:) forControlEvents:UIControlEventTouchUpInside];
#endif
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
#if (INTEGRATE_LOGIN_FB_NEW || INTEGRATE_LOGIN_FB_OLD)
    [_fbLoginButton removeFromSuperview];
    [_fbLoginButton setFrame:_registerScreenRectFB];
    [_mainViewRegister addSubview:_fbLoginButton];
#else
    [_fbLoginButton removeFromSuperview];
    [_fbLoginButton setFrame:_registerScreenRectFB];
    [_mainViewRegister addSubview:_fbLoginButton];
#endif
    [_googleLoginButton removeFromSuperview];
    [_googleLoginButton setFrame:_registerScreenRectGoogle];
    [_mainViewRegister addSubview:_googleLoginButton];
    
    [_twitterLoginButton removeFromSuperview];
    [_twitterLoginButton setFrame:_registerScreenRectTwitter];
    [_mainViewRegister addSubview:_twitterLoginButton];
    
    
}
- (void)resetPasswordClicked:(UIButton*)button {
    BOOL isEmailValidated = [self isValidEmailId:_textForgotPasswordEmailId.text];
    
    if ([_textForgotPasswordEmailId.text isEqualToString:@""] || isEmailValidated == false) {
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"" message:Localize(@"Please enter valid email id.") delegate:nil cancelButtonTitle:Localize(@"OK") otherButtonTitles:nil, nil];
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
- (void)registerClicked:(UIButton*)button {
    _textRegisterUsername.text = _textRegisterEmailId.text;
    if ([_textRegisterUsername.text isEqualToString:@""] || [_textRegisterPassword.text isEqualToString:@""] || [_textRegisterEmailId.text isEqualToString:@""] || [_textRegisterConfirmPassword.text isEqualToString:@""]) {
        
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"" message:Localize(@"Fields marked as ( * ) are mandatory.") delegate:nil cancelButtonTitle:Localize(@"OK") otherButtonTitles:nil, nil];
        [errorAlert show];
    }
    else {
        BOOL isUsernameValidated = [self isValidUsername:_textRegisterUsername.text];
        
        BOOL isPasswordValidated = [self isValidPasssword:_textRegisterPassword.text pwd2:_textRegisterConfirmPassword.text];
        
        BOOL isEmailValidated = [self isValidEmailId:_textRegisterEmailId.text];
        
        if (isUsernameValidated == false) {
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:Localize(@"Invalid Username!") message:@"" delegate:nil cancelButtonTitle:Localize(@"OK") otherButtonTitles:nil, nil];
            [errorAlert show];
        }else if (isPasswordValidated == false) {
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:Localize(@"Invalid Password!") message:@"" delegate:nil cancelButtonTitle:Localize(@"OK") otherButtonTitles:nil, nil];
            [errorAlert show];
        }else if (isEmailValidated == false) {
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:Localize(@"Invalid Email!") message:@"" delegate:nil cancelButtonTitle:Localize(@"OK") otherButtonTitles:nil, nil];
            [errorAlert show];
        }else{
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
            [dataDictionary setObject:SA_PROVIDERS_NAME[SA_PROVIDERS_STORE] forKey:@"provider"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"response_register_clicked" object:dataDictionary];
            //    [self authenticateAndLogin];
            //    [self fetchCustomerData];
            
            //here register user call
        }
    }
}
- (void)registerBackClicked:(UIButton*)button {
    [self showLoginPopup:false];
    [self.popupControllerRegister dismissPopupControllerAnimated:NO];
}
- (void)forgotPasswordBackClicked:(UIButton*)button {
    [self showLoginPopup:false];
    [self.popupControllerForgotPassword dismissPopupControllerAnimated:NO];
}
- (void)createForgotPasswordPopup{
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
        self.popupControllerForgotPassword.theme.shouldDismissOnBackgroundTouch = true;
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            self.popupControllerForgotPassword.VIEW_POPUP.transform = CGAffineTransformMakeScale(-1, 1);
        }
        
        UIButton* _buttonCancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, viewTop.frame.size.width, viewTop.frame.size.height)];
        [viewTop addSubview:_buttonCancel];
        [_buttonCancel addTarget:self action:@selector(forgotPasswordBackClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_buttonCancel sizeToFit];
        [_buttonCancel setFrame:CGRectMake(viewTop.frame.size.width * 0.04f, 0, _buttonCancel.frame.size.width, viewTop.frame.size.height)];
        
        
        
        UILabel* _labelTitle = [self createLabel:viewTop fontType:kUIFontType20 fontColorType:kUIColorFontDark frame:CGRectMake(0, 0, viewTop.frame.size.width, viewTop.frame.size.height) textStr:Localize(@"Forgot Password")];
        [_labelTitle setTextAlignment:NSTextAlignmentCenter];
        
        
        float posY = CGRectGetMaxY(viewTop.frame) + viewMain.frame.size.width * 0.05f;
        float width = viewMain.frame.size.width * 0.70f;
        float posX = (viewMain.frame.size.width - width)/2;
        float height = (viewMain.frame.size.height - (posY - viewTop.frame.size.height) - posY)/9;
        float gap = height/2;
        
        _textForgotPasswordEmailId = [self createTextField:viewMain fontType:kUIFontType20 fontColorType:kUIColorFontLight frame:CGRectMake(posX, posY, width, height) tag:_kTAGTEXTFIELD_R_EMAIL textStrPlaceHolder:Localize(@" * Enter Email")];
        posY += (height+gap);
        
        UIButton *buttonResetPassword = [[UIButton alloc] initWithFrame:CGRectMake(posX, posY, width, height)];
        [buttonResetPassword setBackgroundColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
        [[buttonResetPassword titleLabel] setUIFont:kUIFontType22 isBold:false];
        [buttonResetPassword setTitle:Localize(@"Reset Password") forState:UIControlStateNormal];
        [buttonResetPassword setTitleColor:[Utility getUIColor:kUIColorBuyButtonFont] forState:UIControlStateNormal];
        [viewMain addSubview:buttonResetPassword];
        [buttonResetPassword addTarget:self action:@selector(resetPasswordClicked:) forControlEvents:UIControlEventTouchUpInside];
        posY += (height+gap);
        
        
        
        UIButton* _buttonGoBack = [[UIButton alloc] initWithFrame:CGRectMake(posX, posY, width, height)];
        [[_buttonGoBack titleLabel] setUIFont:kUIFontType18 isBold:false];
        [_buttonGoBack setTitleColor:[Utility getUIColor:kUIColorThemeFont] forState:UIControlStateNormal];
        [viewMain addSubview:_buttonGoBack];
        [_buttonGoBack addTarget:self action:@selector(forgotPasswordBackClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_buttonGoBack setTitle:Localize(@"Go Back") forState:UIControlStateNormal];
        float buttonw1 = LABEL_SIZE([_buttonGoBack titleLabel]).width;
        CGRect br1 = _buttonGoBack.frame;
        br1.size.width = buttonw1;
        br1.origin.x = widthView * 0.50f - buttonw1/2;
        [_buttonGoBack setFrame:br1];
        posY += (height+gap);
        
        
        UILabel* _labelGyan = [self createLabel:viewMain fontType:kUIFontType14 fontColorType:kUIColorFontLight frame:CGRectMake(0, posY, viewMain.frame.size.width, height) textStr:Localize(@"Password reset link will be sent on this email id.")];
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
- (BOOL)isValidPasssword:(NSString *)pwd1 pwd2:(NSString *)pwd2 {
    
    if ([pwd1 compare:pwd2] != NSOrderedSame) {
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:Localize(@"Invalid Password!") message:Localize(@"Both passwords are not same.") delegate:nil cancelButtonTitle:Localize(@"OK") otherButtonTitles:nil, nil];
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Localize(@"Sorry!") message:Localize(@"Please try again later.") delegate:self cancelButtonTitle:Localize(@"OK") otherButtonTitles:nil];
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
    [self refreshViewController];
}
- (void)refreshViewController {
    [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
    UIStoryboard *sb = [UIStoryboard storyboardWithName:STORYBOARD_NAME bundle:nil];
    SWRevealViewController *mainRevealController = [sb instantiateViewControllerWithIdentifier:VC_SWREVEAL];
    UIViewController *mainViewController = [sb instantiateViewControllerWithIdentifier:VC_MAIN];
    UIViewController *rightViewController = [sb instantiateViewControllerWithIdentifier:VC_RIGHT];
    UIViewController *leftViewController = [sb instantiateViewControllerWithIdentifier:VC_LEFT];
    mainRevealController = [[SWRevealViewController alloc] initWithRearViewController:leftViewController frontViewController:mainViewController];
    if ([[Addons sharedManager] enable_multi_vendor]) {
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
        
        UILabel* _labelTitle = [self createLabel:viewTop fontType:kUIFontType20 fontColorType:kUIColorFontDark frame:CGRectMake(0, 0, viewTop.frame.size.width, viewTop.frame.size.height) textStr:Localize(@"Select Language")];
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
        
        UIButton* _buttonCancel = [[UIButton alloc] initWithFrame:CGRectMake(leftItemsPosX, 0, viewTop.frame.size.width - leftItemsPosX*2, viewTop.frame.size.height)];
        [viewTop addSubview:_buttonCancel];
        [_buttonCancel addTarget:self action:@selector(languageSelectedDone:) forControlEvents:UIControlEventTouchUpInside];
        [_buttonCancel setTitle:Localize(@"OK") forState:UIControlStateNormal];
        [[_buttonCancel titleLabel] setUIFont:kUIFontType18 isBold:false];
        [_buttonCancel setTitleColor:[Utility getUIColor:kUIColorThemeFont] forState:UIControlStateNormal];
        _buttonCancel.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [viewMain addSubview:_buttonCancel];
    }
    [self.popupControllerSettings presentPopupControllerAnimated:YES];
}
@end
