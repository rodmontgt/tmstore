//
//  ViewControllerHome.m

//
//  Created by Rishabh Jain on 24/09/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import "ViewControllerHome.h"
#import "Variables.h"
#import "DataManager.h"
#import "CommonInfo.h"
#import "ProductInfo.h"
#import "MRProgress.h"
#import "AppDelegate.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ProductImage.h"
#import "CCollectionViewCell.h"
#import "Utility.h"
#import "ViewControllerMain.h"
#import "RCustomViewSegue.h"
#import "ViewControllerCategories.h"
#import "Wishlist.h"
#import "Variables.h"
#import "Coupon.h"
#import "Banner.h"
#import "LoginFlow.h"
#import "Cart.h"
#import "Vendor.h"
#import "ViewControllerSearch.h"
#import "PincodeSetting.h"
#import "ViewControllerLeft.h"
#import "AnalyticsHelper.h"
#import "TM_PickupLocation.h"
#import "ConsentScreenConfig.h"
#import "MyDevice.h"
#import "ViewControllerMain.h"
#define NEW_WAY 0
#if ENABLE_GOOGLE_ADMOB_SDK
@import GoogleMobileAds;
//#import "GADInterstitial.h"
//#import "GADInterstitialDelegate.h"
#endif

@import FirebaseAnalytics;

static int kTagForGlobalSpacing = 0;
static int kTagForNoSpacing = -1;
static ViewControllerHome *_meHome = nil;
@interface ViewControllerHome ()
< CNPPopupControllerDelegate
#if ENABLE_GOOGLE_ADMOB_SDK
, GADInterstitialDelegate
#endif
>
{
    NSMutableArray *_viewsAdded;
    NSMutableArray *_horizontalScrollViews;
    ViewControllerMain *viewMain;
    
}
@property (nonatomic, strong) CNPPopupController *popupControllerCS;
#if ENABLE_GOOGLE_ADMOB_SDK
@property(nonatomic, strong) GADInterstitial *interstitial;

#endif

@end
@implementation ViewControllerHome

#pragma mark - View Life Cycle
- (void)fetchPickupLocations {
    [[[DataManager sharedManager] tmDataDoctor] getPickupLocations:^(id data) {
    } failure:^(NSString *error) {
    }];
}
+ (ViewControllerHome*)getInstance {
    return _meHome;
}
+ (void)resetInstance {
    if (_meHome.adTimerDelay && [_meHome.adTimerDelay isValid]) {
        [_meHome.adTimerDelay invalidate];
        _meHome.adTimerDelay = nil;
    }
    if (_meHome.adTimerInterval && [_meHome.adTimerInterval isValid]) {
        [_meHome.adTimerInterval invalidate];
        _meHome.adTimerInterval = nil;
    }
    _meHome = nil;
}
- (void)viewDidLoad {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super viewDidLoad];
    [self initiateData];
#if ENABLE_GOOGLE_ADMOB_SDK
    self.isHomeScreenPresented = false;
    self.adTimerDelay = nil;
    self.adTimerInterval = nil;
    Addons* addons = [Addons sharedManager];
    if(addons.googleAdmobPlugin && addons.googleAdmobPlugin.isEnabled) {
        [self createAndLoadInterstitial];
        self.adTimerDelay = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(checkTimerDelay:) userInfo:nil repeats:YES];
    }
#endif
    
    [viewMain btnClickedHome:self];
}
- (void)initiateData {
    DataManager * dm = [DataManager sharedManager];
    dm.isHomeScreenFirstLaunch = true;
    
    _meHome = self;
#if (ENABLE_SIMPLEAUTH)
    for (int i = 0; i < SA_PROVIDERS_TOTAL; i++) {
        [[LoginFlow sharedManager] configureAuthorizaionProviders:i];
    }
#endif
    
    if ([[Addons sharedManager] show_pickup_location] && [[TM_PickupLocation getAllPickupLocations] count] == 0) {
        [self fetchPickupLocations];
    }
    
    if ([Coupon getAllCoupons] == NULL) {
        [[[DataManager sharedManager] tmDataDoctor] fetchCouponsData:nil];
    }
    
    _strCollectionView1 = [[Utility sharedManager] getProductViewString];
    _strCollectionView2 = [[Utility sharedManager] getCategoryViewString];
    _strCollectionView3 = [[Utility sharedManager] getHorizontalViewString];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidFinishLaunchingNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NOTIFY_DL_PRODUCT" object:nil];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillEnteredInForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillEnteredInForeground:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillEnteredInForeground:)
                                                 name:UIApplicationDidFinishLaunchingNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillEnteredInForeground:)
                                                 name:@"NOTIFY_DL_PRODUCT"
                                               object:nil];
    trendingBannerProducts = nil;
    [self initVariables];
}
- (void)appWillEnteredInForeground:(NSNotification *)notification {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    AppDelegate* appD =  (AppDelegate*)[UIApplication sharedApplication].delegate;
    RLOG(@"dlProductId = %d", appD.dlProductId);
    RLOG(@"nType = %d", appD.nType);
    RLOG(@"nJsonData_Id = %d", appD.nJsonData_Id);
    RLOG(@"nJsonData_varId = %d", appD.nJsonData_varId);
    RLOG(@"nJsonData_couponCode = %@", appD.nJsonData_couponCode);
    
    BOOL isInitialPageDataFetched =  [[[DataManager sharedManager] tmDataDoctor] isInitialPageDataFetched];
    RLOG(@"isInitialPageDataFetched = %d", isInitialPageDataFetched);
    BOOL isHomePageDataFetched =  [[[DataManager sharedManager] tmDataDoctor] isHomePageDataFetched];
    RLOG(@"isHomePageDataFetched = %d", isHomePageDataFetched);
    // old code
    //    if ([[[DataManager sharedManager]tmDataDoctor] isInitialPageDataFetched] == false || [[[DataManager sharedManager]tmDataDoctor] isHomePageDataFetched] == false) {
    //        RLOG(@"NO FULL DATA LOADED");
    //        return;
    //    }
    
    if (isHomePageDataFetched == false) {
        RLOG(@"NO FULL DATA LOADED ie isHomePageDataFetched is false.");
        return;
    }
    
    
    
    if (appD.dlProductId != -1) {
        int productId = appD.dlProductId;
        ProductInfo* pInfo = (ProductInfo*)[ProductInfo getProductWithId:productId];
        if (pInfo) {
            [self clickOnProduct:pInfo currentItemData:nil cell:nil];
        } else {
            ProductInfo* pInfo = [[ProductInfo alloc] init];
            pInfo._id = productId;
            [self clickOnProduct:pInfo currentItemData:nil cell:nil];
        }
        appD.dlProductId = -1;
    }
    else if (appD.nType != -1) {
        switch (appD.nType) {
            case nType_DoNothing://do nothing
            {
                
            }break;
            case nType_OpenProduct://open product
            {
                int productId = appD.nJsonData_Id;
                int productVarId = appD.nJsonData_varId;
                ProductInfo* pInfo = (ProductInfo*)[ProductInfo getProductWithId:productId];
                if (pInfo) {
                    [self clickOnProduct:pInfo currentItemData:nil cell:nil];
                } else {
                    ProductInfo* pInfo = [[ProductInfo alloc] init];
                    pInfo._id = productId;
                    [self clickOnProduct:pInfo currentItemData:nil cell:nil];
                }
            }break;
            case nType_OpenCategory://open category
            {
                int categoryId = appD.nJsonData_Id;
                CategoryInfo *cInfo = [CategoryInfo getWithId:categoryId];
                [self clickOnCategory:cInfo currentItemData:nil];
            }break;
            case nType_OpenWishlist://open wishlist
            {
                self.isHomeScreenPresented = false;
                ViewControllerMain* mainVC = [ViewControllerMain getInstance];
                [mainVC btnClickedWishlist:nil];
            }break;
            case nType_OpenCart://open cart
            {
                self.isHomeScreenPresented = false;
                if (![appD.nJsonData_couponCode isEqualToString:@""]) {
                    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                    pasteboard.string = appD.nJsonData_couponCode;
                }
                ViewControllerMain* mainVC = [ViewControllerMain getInstance];
                [mainVC btnClickedCart:nil];
                //                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Coupon code copied to clipboard." delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
                //                [alert dismissWithClickedButtonIndex:0 animated:YES];
            }break;
            default:
                break;
        }
        
        appD.nJsonData_Id = -1;
        appD.nJsonData_varId = -1;
        //        appD.nJsonData_couponCode = @"";
        appD.nType = -1;
    }
}
+ (UIViewController*)topMostController
{
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    return topController;
}
- (void)viewDidAppear:(BOOL)animated {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    self.isHomeScreenPresented = true;
    DataManager * dm = [DataManager sharedManager];
    if(dm.isHomeScreenFirstLaunch){
        dm.isHomeScreenFirstLaunch = false;
        [self loadDataInView];
    } else {
        [self resetMainScrollView];
        for (int i = 0; i < _kTotalViewsHomeScreen; i++) {
            if(_viewUserDefined[i]){
                [_viewUserDefined[i] reloadData];
            }
        }
        if (self.spinnerView){
            [self.spinnerView stopAnimating];
        }
    }
    
    [self appWillEnteredInForeground:nil];
    [[Utility sharedManager] checkShowLoginAtStartCondition];
#if ENABLE_FIREBASE_TAG_MANAGER
    [[AnalyticsHelper sharedInstance] registerVisitScreenEvent:@"Home Screen"];
#endif
    
    //    if (_viewUserDefined[_kCategoryBasic]) {
    //        [_viewUserDefined[_kCategoryBasic] reloadData];
    //        [[_viewUserDefined[_kCategoryBasic] collectionViewLayout] invalidateLayout];
    //    }
    
    [self showConsentScreen];
}
- (void)viewWillAppear:(BOOL)animated {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super viewWillAppear:animated];
#if SUPPORT_PORTRAIT_ORIENTATION_ONLY
    [UIViewController attemptRotationToDeviceOrientation];
#endif
    //rv//[SDWebImageManager.sharedManager.imageDownloader setValue:@"SDWebImage Demo" forHTTPHeaderField:@"AppName"];
    if (self.spinnerView == nil) {
        self.spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.view addSubview:self.spinnerView];
        [self.spinnerView hidesWhenStopped];
    }
    self.spinnerView.center = self.view.center;
    [self.spinnerView startAnimating];
    [self.view bringSubviewToFront:self.spinnerView];
}
- (void)viewDidDisappear:(BOOL)animated {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super viewDidDisappear:animated];
}
- (void)viewWillDisappear:(BOOL)animated {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super viewWillDisappear:animated];
    self.isHomeScreenPresented = false;
}
- (void)flushCache {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [SDWebImageManager.sharedManager.imageCache clearMemory];
    
}
- (void)didReceiveMemoryWarning {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super didReceiveMemoryWarning];
    [[[SDWebImageManager sharedManager] imageCache] clearMemory];
}
//- (NSUInteger)supportedInterfaceOrientations

////    Forced Portrait mode
//    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
//    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
//    return [super supportedInterfaceOrientations];
//}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    return interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight;
}

#if SUPPORT_PORTRAIT_ORIENTATION_ONLY
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}
- (BOOL)shouldAutorotate {
    return YES;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
- (NSUInteger)navigationControllerSupportedInterfaceOrientations:(UINavigationController *)navigationController {
    return UIInterfaceOrientationMaskPortrait;
}
#else
#endif

#pragma mark - Methods
- (void)initVariables {
    self.view.backgroundColor = [Utility getUIColor:kUIColorBgTheme];
    _viewsAdded = [[NSMutableArray alloc] init];
    _propBanner = [[LayoutProperties alloc] initWithBannerValues];
    for (int i = 0; i < _kTotalViewsHomeScreen; i++) {
        _viewUserDefined[i] = nil;
        _propCollectionView[i] = [[LayoutProperties alloc] initWithCollectionViewValues:SCROLL_TYPE_SHOWFULL];
        _viewUserDefinedHeaderString[i] = @"";
        _viewUserDefinedHeader[i] = nil;
        _isViewUserDefinedEnable[i] = false;
    }
    _isViewUserDefinedEnable[_kTrending] = true;
    _isViewUserDefinedEnable[_kCategoryBasic] = true;
    _isViewUserDefinedEnable[_kDiscount] = false;
    _isViewUserDefinedEnable[_kNew] = true;
    _isViewUserDefinedEnable[_kMaxSold] = true;
    
    _viewUserDefinedHeaderString[_kTrending] = Localize(@"header_trending_items");
    _viewUserDefinedHeaderString[_kCategoryBasic] = @"";
    _viewUserDefinedHeaderString[_kDiscount] = Localize(@"discount");
    _viewUserDefinedHeaderString[_kNew] = Localize(@"header_fresh_arrival");
    _viewUserDefinedHeaderString[_kMaxSold] = Localize(@"header_best_deals");
    _viewKey[_kTrending] = @"sale_price";
    _viewKey[_kMaxSold] = @"total_sales";
    _viewKey[_kNew] = @"id";
    _viewKey[_kDiscount] = @"on_sale";
    
    
    Addons* addons = [Addons sharedManager];
    // this condition is put in numberOfItemsInSection method
    //    if (addons.show_home_categories == false) {
    //    }
    if (addons.show_section_best_deals == false) {
        _isViewUserDefinedEnable[_kMaxSold] = false;
    }
    if (addons.show_section_fresh_arrivals == false) {
        _isViewUserDefinedEnable[_kNew] = false;
    }
    if (addons.show_section_trending == false) {
        _isViewUserDefinedEnable[_kTrending] = false;
    }
    
#if NEW_WAY
    _isViewUserDefinedEnable[_kMaxSold] = false;
    _isViewUserDefinedEnable[_kNew] = false;
#endif
    //    [self fetchDeliverySlotsCopiaPluginData];
    [self fetchLocalPickupTimeSelectPlugin];
}
- (void)fetchLocalPickupTimeSelectPlugin {
#if ENABLE_LOCAL_PICKUP_TIME_SELECT
    Addons* addons = [Addons sharedManager];
    if (addons.localPickupTimeSelectPlugin.isEnabled) {
        [[[DataManager sharedManager] tmDataDoctor] fetchLocalPickupTimeSelectFromPlugin:^(id data) {
            RLOG(@"fetchLocalPickupTimeSelectPlugin:success");
        } failure:^{
            RLOG(@"fetchLocalPickupTimeSelectPlugin:failure");
            //            [self fetchLocalPickupTimeSelectPlugin];
        }];
    }
#endif
}
- (void)loadDataInView {
    [_scrollView setAlpha:0];
    for (int i = 0; i < _kTotalViewsHomeScreen; i++) {
        [_propCollectionView[i] setCollectionViewProperties:_propCollectionView[i] scrollType:SCROLL_TYPE_SHOWFULL];
    }
    for (UIView* view in _viewsAdded) {
        [view removeFromSuperview];
    }
    [_viewsAdded removeAllObjects];
    [self createTopView];
    [self createBannerView];
    [self createVariousViews];
    if (self.spinnerView ) {
        [self.spinnerView stopAnimating];
    }
    [[Utility sharedManager] stopGrayLoadingBar];
    [self resetMainScrollView];
    [_scrollView setAlpha:1];
    if (_viewTopExtraItems) {
        [self.view bringSubviewToFront:_viewTopExtraItems];
    }
    [self loadWaitListProductIds];
    [self loadProductsPincodeSettings];
}
/*
#pragma mark - Table View
- (void)createTableView {
    float spacing = 0;
    _tableView=[[UITableView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x + spacing, self.view.frame.origin.y + spacing, self.view.frame.size.width - spacing * 2, 250 - spacing * 2)];
    _tableView.dataSource=self;
    _tableView.delegate=self;
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [_tableView reloadData];
    [_scrollView addSubview:_tableView];
    RLOG(@"\n_tableView = %@", _tableView);
    [_viewsAdded addObject:_tableView];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[ProductInfo getAll] count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    
    ProductInfo *pInfo = (ProductInfo*) ([[ProductInfo getAll] objectAtIndex:indexPath.row]);
    if ([pInfo._images count] == 0) {
        [pInfo._images addObject:[[ProductImage alloc] init]];
    }
    ProductImage *pImage = [pInfo._images objectAtIndex:0];
    
    //    [cell.imageView setShowActivityIndicatorView:YES];
    //    [cell.imageView setIndicatorStyle:UIActivityIndicatorViewStyleGray];
    cell.textLabel.text = [NSString stringWithFormat:@"Image #%ld", (long)indexPath.row];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:pImage._src] placeholderImage:[UIImage imageNamed:@"blue32x32.png"] options:[Utility getImageDownloadOption]];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //    if (!self.detailViewController)
    //    {
    //        self.detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
    //    }
    //    NSString *largeImageURL = [[_objects objectAtIndex:indexPath.row] stringByReplacingOccurrencesOfString:@"small" withString:@"source"];
    //    self.detailViewController.imageURL = [NSURL URLWithString:largeImageURL];
    //    [self.navigationController pushViewController:self.detailViewController animated:YES];
}
//-- Table header height if needed
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}
*/
- (void)createTopView {
    Addons* addons = [Addons sharedManager];
    if (_viewTopExtraItems == nil) {
        _viewTopExtraItems = [[UIView alloc] init];
        _viewTopExtraItems.backgroundColor = [Utility getUIColor:kUIColorBgTheme];
        [_viewTopExtraItems setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [self.view addSubview:_viewTopExtraItems];
        [self.view bringSubviewToFront:_viewTopExtraItems];
        if (addons.add_search_in_home) {
            _viewTopExtraItemsSearchBar = [[UISearchBar alloc] init];
            _viewTopExtraItemsSearchBar.delegate = self;
            [_viewTopExtraItems addSubview:_viewTopExtraItemsSearchBar];
            
            _viewTopExtraItemsSearchBar.placeholder = Localize(@"txt_search_hint_home");
            if ([[TMLanguage sharedManager] isRTLEnabled]) {
                _viewTopExtraItemsSearchBar.transform = CGAffineTransformMakeScale(-1, 1);
            }
        }
    }
    if (_viewTopExtraItems){
        float viewWidth = self.view.frame.size.width;
        CGRect topViewRect = CGRectMake(0, 0, viewWidth, 0);
        float viewHeight = 44;
        if (addons.add_search_in_home) {
            topViewRect.size.height += viewHeight;
            _viewTopExtraItemsSearchBar.frame = CGRectMake(0, 0, viewWidth, viewHeight);
        }
        _viewTopExtraItems.frame = topViewRect;
    }
    
    UIView* view = [[UIView alloc] initWithFrame:_viewTopExtraItems.frame];
#if NEW_WAY
    [_scrollView.contentView addSubview:view];
#else
    [_scrollView addSubview:view];
#endif
    [_viewsAdded addObject:view];
    [view setTag:kTagForNoSpacing];
}
#pragma mark - Banner View
- (void)createBannerView {
    if(trendingBannerProducts == nil){
        refreshBannerCount = -1;
        trendingBannerProducts = [[NSMutableArray alloc] init];
    }
    [_propBanner setBannerProperties:_propBanner showFullSizeBanner:false];
    CGRect bannerRect = [_propBanner getFrameRect];
    _bannerScrollView = [[PagedImageScrollView alloc] initWithFrame:bannerRect];
    [_bannerScrollView setBackgroundColor:_propBanner._bgColor];
    NSMutableArray *imageArray = [[NSMutableArray alloc] init];
    NSObject* object = nil;
    for (Banner* banner in [Banner getAllBanners]) {
        UIImageView * uiImageView = [[UIImageView alloc]init];
        [Utility setImage:uiImageView url:banner.bannerUrl resizeType:kRESIZE_TYPE_BANNER isLocal:false];
        [imageArray addObject:uiImageView];
        [uiImageView.layer setValue:banner forKey:@"BANNER_OBJ"];
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bannerTapped:)];
        singleTap.numberOfTapsRequired = 1;
        singleTap.numberOfTouchesRequired = 1;
        [uiImageView addGestureRecognizer:singleTap];
        [uiImageView setUserInteractionEnabled:YES];
    }
    if([imageArray count] == 0) {
        int viewTypeForBanner = kHV_TYPES_TRENDINGS;
        int total = 0;
        for (viewTypeForBanner = kHV_TYPES_TRENDINGS; viewTypeForBanner <=kHV_TYPES_NEWARRIVALS; viewTypeForBanner++) {
            total = (int)[[ProductInfo getProducts:_viewKey[_kTrending] isAscending:YES viewType:viewTypeForBanner] count];
            if (total !=0) {
                break;
            }
        }
        if (refreshBannerCount == 3 || (int)[trendingBannerProducts count] > total) {
            [trendingBannerProducts removeAllObjects];
            refreshBannerCount = -1;
        }
        if (refreshBannerCount == -1) {
            for (int i = 0; i < total; i++) {
                [trendingBannerProducts addObject:[NSNumber numberWithInt:i]];
            }
            if (total > 5) {
                int extraItems = total - 5;
                for (int i = 0; i < extraItems; i++) {
                    [trendingBannerProducts removeObjectAtIndex:arc4random()%[trendingBannerProducts count]];
                }
            }
        }
        refreshBannerCount++;
        NSMutableArray* trendingProducts = [ProductInfo getProducts:_viewKey[_kTrending] isAscending:YES viewType:viewTypeForBanner];
        for (int i = 0 ; i < (int)[trendingBannerProducts count]; i++) {
            ProductInfo *pinfo = (ProductInfo *)[trendingProducts objectAtIndex:[[trendingBannerProducts objectAtIndex:i] intValue]];
            UIImageView * uiImageView = [[UIImageView alloc]init];
            if ([pinfo._images count] == 0) {
                [pinfo._images addObject:[[ProductImage alloc] init]];
            }
            ProductImage* pImg = [pinfo._images objectAtIndex:0];
            [Utility setImage:uiImageView url:pImg._src resizeType:kRESIZE_TYPE_BANNER isLocal:false];
            [imageArray addObject:uiImageView];
            [uiImageView setTag:pinfo._id];
            UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bannerTapped:)];
            singleTap.numberOfTapsRequired = 1;
            singleTap.numberOfTouchesRequired = 1;
            [uiImageView addGestureRecognizer:singleTap];
            [uiImageView setUserInteractionEnabled:YES];
        }
    }
    if ([imageArray count] > 0 && [[Addons sharedManager] show_home_page_banner]) {
        [_bannerScrollView setScrollViewContentsWithImageViews:imageArray contentMode:UIViewContentModeScaleAspectFill];
        [_bannerScrollView reloadView:bannerRect];
#if NEW_WAY
                [_scrollView.contentView addSubview:_bannerScrollView];
#else
                [_scrollView addSubview:_bannerScrollView];
#endif

        [_viewsAdded addObject:_bannerScrollView];
        [_bannerScrollView setTag:kTagForNoSpacing];
        [_bannerScrollView enableBannerChangeAutomatically];
    }
}
- (void)bannerTapped:(UITapGestureRecognizer*)singleTap {
    Banner* banner = [singleTap.view.layer valueForKey:@"BANNER_OBJ"];
    id cell = [singleTap.view.layer valueForKey:@"CELL_OBJ"];
    if (banner) {
        int bannerId = banner.bannerId;
        int bannerType = banner.bannerType;
        switch (bannerType) {
            case BANNER_SIMPLE://do nothing
            {
                
            }break;
            case BANNER_PRODUCT://open product
            {
                int productId = bannerId;
                ProductInfo* pInfo = (ProductInfo*)[ProductInfo getProductWithId:productId];
                if (pInfo) {
                    [self clickOnProduct:pInfo currentItemData:nil cell:cell];
                } else {
                    ProductInfo* pInfo = [[ProductInfo alloc] init];
                    pInfo._id = productId;
                    [self clickOnProduct:pInfo currentItemData:nil  cell:cell];
#if ENABLE_FIREBASE_TAG_MANAGER
                    [[AnalyticsHelper sharedInstance] registerClickOnBanner:[NSString stringWithFormat:@"%d",pInfo._id]];
#endif
                }
                
            }break;
            case BANNER_CATEGORY://open category
            {
                int categoryId = bannerId;
                CategoryInfo *cInfo = [CategoryInfo getWithId:categoryId];
                [self clickOnCategory:cInfo currentItemData:nil];
#if ENABLE_FIREBASE_TAG_MANAGER
                [[AnalyticsHelper sharedInstance] registerClickOnBanner:[NSString stringWithFormat:@"%d",categoryId]];
#endif
            }break;
            case BANNER_WISHLIST://open wishlist
            {
                self.isHomeScreenPresented = false;
                ViewControllerMain* mainVC = [ViewControllerMain getInstance];
                [mainVC btnClickedWishlist:nil];
            }break;
            case BANNER_CART://open cart
            {
                self.isHomeScreenPresented = false;
                ViewControllerMain* mainVC = [ViewControllerMain getInstance];
                [mainVC btnClickedCart:nil];
            }break;
            default:
                break;
        }
        return;
    }
    
    
    
    int productId = (int)[singleTap.view tag];
    ProductInfo* pInfo = (ProductInfo*)[ProductInfo getProductWithId:productId];
    if (pInfo) {
        [self clickOnProduct:pInfo currentItemData:nil cell:cell];
    }
}
- (void)promoTapped:(UITapGestureRecognizer*)singleTap {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[DataManager sharedManager] promoUrlString]]];
}
#pragma mark - Deal Views
- (void)createVariousViews {
    for (int i = 0; i < _kTotalViewsHomeScreen; i++) {
        if (_isViewUserDefinedEnable[i] == false) {
            continue;
        }
        
        if (![_viewUserDefinedHeaderString[i] isEqualToString:@""]) {
            UIFont *customFont = [Utility getUIFont:kUIFontType18 isBold:true];
            float fontSize = [customFont lineHeight];
            float alignFactor = .014f * [[MyDevice sharedManager] screenWidthInPortrait];
            _viewUserDefinedHeader[i] = [[UILabel alloc] initWithFrame:CGRectMake(0, alignFactor, _scrollView.frame.size.width, fontSize + alignFactor * 1)];
            [_viewUserDefinedHeader[i] setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
            [_viewUserDefinedHeader[i] setBackgroundColor:[Utility getUIColor:kUIColorBgSubTitle]];
            [_viewUserDefinedHeader[i] setUIFont:customFont];
            [_viewUserDefinedHeader[i] setText:_viewUserDefinedHeaderString[i]];
            if (![_viewUserDefinedHeaderString[i] isEqualToString:@""]) {
                [_viewUserDefinedHeader[i] setText:[NSString stringWithFormat:@"  %@",_viewUserDefinedHeaderString[i]]];
            }
            [_viewUserDefinedHeader[i] setTextColor:[Utility getUIColor:kUIColorFontSubTitle]];
            if ([[TMLanguage sharedManager] isRTLEnabled]) {
                [_viewUserDefinedHeader[i] setTextAlignment:NSTextAlignmentRight];
            } else {
                [_viewUserDefinedHeader[i] setTextAlignment:NSTextAlignmentLeft];
            }
            [_viewUserDefinedHeader[i] setBaselineAdjustment:UIBaselineAdjustmentAlignBaselines];
            [_viewUserDefinedHeader[i] setLineBreakMode:NSLineBreakByCharWrapping];
            [_viewUserDefinedHeader[i] setNumberOfLines:1];
#if NEW_WAY
            [_scrollView.contentView addSubview:_viewUserDefinedHeader[i]];
#else
            [_scrollView addSubview:_viewUserDefinedHeader[i]];
#endif
            [_viewsAdded addObject:_viewUserDefinedHeader[i]];
            [_viewUserDefinedHeader[i] setTag:kTagForNoSpacing];
            [_viewUserDefinedHeader[i] setTextColor:[Utility getUIColor:kUIColorHViewHeaderFont]];
            [_viewUserDefinedHeader[i] setBackgroundColor:[Utility getUIColor:kUIColorHViewHeaderBg]];
        }
        UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
        switch (i) {
            case _kCategoryBasic:
            {
                [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
                _viewUserDefined[i] = [[UICollectionView alloc] initWithFrame:[_propCollectionView[i] getFrameRect] collectionViewLayout:layout];
                [_viewUserDefined[i] setScrollEnabled:false];
                [_viewUserDefined[i] registerNib:[UINib nibWithNibName:_strCollectionView2 bundle:nil] forCellWithReuseIdentifier:@"CollectionCell"];
#if NEW_WAY
                [_scrollView.contentView addSubview:_viewUserDefined[i]];
#else
                [_scrollView addSubview:_viewUserDefined[i]];
#endif
                [_viewsAdded addObject:_viewUserDefined[i]];
                [_viewUserDefined[i] setTag:kTagForGlobalSpacing];
            }break;
            case _kTrending:
            case _kMaxSold:
            case _kNew:
            case _kDiscount:
            case _kUserDefined1:
            case _kUserDefined2:
            case _kUserDefined3:
            case _kUserDefined4:
            case _kUserDefined5:
            {
                [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
                _viewUserDefined[i] = [[UICollectionView alloc] initWithFrame:[_propCollectionView[i] getFrameRect] collectionViewLayout:layout];
                [_viewUserDefined[i] setScrollEnabled:true];
                [_viewUserDefined[i] registerNib:[UINib nibWithNibName:_strCollectionView3 bundle:nil] forCellWithReuseIdentifier:@"CollectionCell"];
#if NEW_WAY
                [_scrollView.contentView addSubview:_viewUserDefined[i]];
#else
                [_scrollView addSubview:_viewUserDefined[i]];
#endif
                [_viewsAdded addObject:_viewUserDefined[i]];
                [_viewUserDefined[i] setTag:kTagForGlobalSpacing];
            }break;
            default:
                break;
        }
        [_viewUserDefined[i] setBackgroundColor:_propCollectionView[i]._bgColor];
        [_viewUserDefined[i] setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [_viewUserDefined[i] setDataSource:self];
        [_viewUserDefined[i] setDelegate:self];
        [_viewUserDefined[i] reloadData];
        [self resetMainScrollView];
    }
}
#pragma mark - Category View
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    int itemCount = 0;
    int i = 0;
    for (; i < _kTotalViewsHomeScreen; i++) {
        if(_viewUserDefined[i] == collectionView){
            break;
        }
    }
    switch (i) {
        case _kCategoryBasic:
        {
            itemCount = (int)[[CategoryInfo getAllRootCategories] count];
            Addons* addons = [Addons sharedManager];
            if (addons.show_home_categories == false) {
                itemCount = 0;
            }
            if (itemCount == 0) {
                [_bannerScrollView setTag:kTagForGlobalSpacing];
            }
        }break;
        case _kTrending:
        {
            //trendings
            itemCount = (int)[[ProductInfo getProducts:_viewKey[_kTrending] isAscending:YES viewType:kHV_TYPES_TRENDINGS] count];
#if PROMO_ENABLE_IN_HORIZONTAL_VIEWS
            if ([[DataManager sharedManager] promoEnable]) {
                itemCount++;
            }
#endif
            if (itemCount < MIN_ITEMS_IN_HORIZONTAL_VIEWS) {
                itemCount = 0;
            }
            if (itemCount > MAX_ITEMS_IN_HORIZONTAL_VIEWS) {
                itemCount = MAX_ITEMS_IN_HORIZONTAL_VIEWS;
            }
        }break;
        case _kMaxSold:
        {
            //maxsold items
            itemCount = (int)[[ProductInfo getProducts:_viewKey[_kMaxSold] isAscending:NO viewType:kHV_TYPES_BESTSELLINGS] count];
#if PROMO_ENABLE_IN_HORIZONTAL_VIEWS
            if ([[DataManager sharedManager] promoEnable]) {
                itemCount++;
            }
#endif
            if (itemCount < MIN_ITEMS_IN_HORIZONTAL_VIEWS) {
                itemCount = 0;
            }
            if (itemCount > MAX_ITEMS_IN_HORIZONTAL_VIEWS) {
                itemCount = MAX_ITEMS_IN_HORIZONTAL_VIEWS;
            }
        }break;
        case _kNew:
        {
            //new
            itemCount = (int)[[ProductInfo getProducts:_viewKey[_kNew] isAscending:NO viewType:kHV_TYPES_NEWARRIVALS] count];
#if PROMO_ENABLE_IN_HORIZONTAL_VIEWS
            if ([[DataManager sharedManager] promoEnable]) {
                itemCount++;
            }
#endif
            if (itemCount < MIN_ITEMS_IN_HORIZONTAL_VIEWS) {
                itemCount = 0;
            }
            if (itemCount > MAX_ITEMS_IN_HORIZONTAL_VIEWS) {
                itemCount = MAX_ITEMS_IN_HORIZONTAL_VIEWS;
            }
        }break;
        case _kDiscount:
        {
            //discount
            itemCount = (int)[[ProductInfo getProducts:_viewKey[_kDiscount] isAscending:NO viewType:kHV_TYPES_DISCOUNTS] count];
#if PROMO_ENABLE_IN_HORIZONTAL_VIEWS
            if ([[DataManager sharedManager] promoEnable]) {
                itemCount++;
            }
#endif
            if (itemCount < MIN_ITEMS_IN_HORIZONTAL_VIEWS) {
                itemCount = 0;
            }
            if (itemCount > MAX_ITEMS_IN_HORIZONTAL_VIEWS) {
                itemCount = MAX_ITEMS_IN_HORIZONTAL_VIEWS;
            }
        }break;
        case _kUserDefined1:
        case _kUserDefined2:
        case _kUserDefined3:
        case _kUserDefined4:
        case _kUserDefined5:
        {
            itemCount = 0;
        }break;
        default:
            itemCount = 1;
            break;
    }
    if (itemCount == 0) {
        [self removeUserDefinedView:i];
    }
    return itemCount;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CollectionCell";
    CCollectionViewCell *cell=(CCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    [cell setNeedsLayout];
    int i = 0;
    for (; i < _kTotalViewsHomeScreen; i++) {
        if(_viewUserDefined[i] == collectionView){
            break;
        }
    }
    if (i < _kTotalViewsHomeScreen && _propCollectionView[i]._insetTop != -1) {
        collectionView.contentInset = UIEdgeInsetsMake(_propCollectionView[i]._insetTop, _propCollectionView[i]._insetLeft, _propCollectionView[i]._insetBottom, _propCollectionView[i]._insetRight);
        
    }
    switch (i) {
        case _kCategoryBasic:
        {
            if(cell == nil) {
                NSArray *nib = [[ NSBundle mainBundle] loadNibNamed:_strCollectionView2 owner:self options:nil];
                cell = [nib objectAtIndex:0];
            }
            [Utility showShadow:cell];
            [cell setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
            //no scroll show full collection
            _propCollectionView[i]._height = _viewUserDefined[i].contentSize.height + _viewUserDefined[i].contentInset.top + _viewUserDefined[i].contentInset.bottom;
            [_viewUserDefined[i] setFrame:[_propCollectionView[i] getFrameRect]];
            [self resetMainScrollView];
            if ([[CategoryInfo getAllRootCategories] count] <= indexPath.row) {
                cell.hidden = true;
                return cell;
            }
            CategoryInfo *cInfo = (CategoryInfo*) ([[CategoryInfo getAllRootCategories] objectAtIndex:indexPath.row]);
            NSString *cImage = cInfo._image;
            [[cell productName] setText:cInfo._nameForOuterView];
            [Utility setImage:cell.productImg url:cImage resizeType:kRESIZE_TYPE_CATEGORY_THUMBNAIL isLocal:false];
            [cell.productImg setContentMode:UIViewContentModeScaleAspectFill];
            [cell.productImg setClipsToBounds:true];
            [cell.productName setUIFont:kUIFontType22 isBold:false];
            switch ([[DataManager sharedManager] layoutIdCategoryView]) {
                case C_LAYOUT_DEFAULT:
                    [cell setNeedsLayout];
                    [cell layoutSubviews];
                    break;
                case C_LAYOUT_RIGHTSIDE:
                {
                    cell.productImg.translatesAutoresizingMaskIntoConstraints = YES;
                    cell.productImgDummy.translatesAutoresizingMaskIntoConstraints = YES;
                    cell.productName.translatesAutoresizingMaskIntoConstraints = YES;
                    cell.labelExploreNow.translatesAutoresizingMaskIntoConstraints = YES;
                    cell.imgHeaderBg.translatesAutoresizingMaskIntoConstraints = YES;
                    CGRect cellFrame = cell.frame;
                    int diff = cellFrame.size.width/2;
                    int margin = 5;
                    [cell.productName sizeToFitUI];
                    cell.productName.frame = CGRectMake(diff + margin, cell.frame.size.height/2 - 10 - cell.productName.frame.size.height, diff - margin * 2, cell.productName.frame.size.height);
                    [cell.productName setLineBreakMode:NSLineBreakByWordWrapping];
                    [cell.productName setTextAlignment:NSTextAlignmentCenter];
                    [cell.productName setNumberOfLines:2];
                    [cell.productName sizeToFitUI];
                    cell.productImg.frame = CGRectMake(0, 0, diff, cell.frame.size.height);
                    cell.productImgDummy.frame = CGRectMake(0, 0, diff, cell.frame.size.height);
                    cell.imgHeaderBg.frame = CGRectMake(diff, 0, diff, cell.frame.size.height);
                    cell.productName.frame = CGRectMake(diff + margin, cell.frame.size.height/2 - 10-cell.productName.frame.size.height, diff - margin * 2, cell.productName.frame.size.height);
                    cell.labelExploreNow.frame = CGRectMake(diff + cell.frame.size.width * .125f, cell.frame.size.height/2 + 10, cell.frame.size.width * .25f, cell.frame.size.height * .125f);
                    cell.labelExploreNow.backgroundColor = [Utility getUIColor:kUIColorBuyButtonNormalBg];
                    cell.labelExploreNow.textColor = [Utility getUIColor:kUIColorBuyButtonFont];
                    [cell.labelExploreNow setUIFont:kUIFontType14 isBold:true];
                    cell.labelExploreNow.text = Localize(@"explore_now");
                    [cell setNeedsLayout];
                    [cell layoutSubviews];
                }break;
                case C_LAYOUT_LEFTRIGHTSIDE:
                    if (((int)indexPath.row) % 2 != 0) {
                        cell.productImg.translatesAutoresizingMaskIntoConstraints = YES;
                        cell.productImgDummy.translatesAutoresizingMaskIntoConstraints = YES;
                        cell.productName.translatesAutoresizingMaskIntoConstraints = YES;
                        cell.labelExploreNow.translatesAutoresizingMaskIntoConstraints = YES;
                        cell.imgHeaderBg.translatesAutoresizingMaskIntoConstraints = YES;
                        CGRect cellFrame = cell.frame;
                        int diff = cellFrame.size.width/2;
                        int margin = 5;
                        [cell.productName sizeToFitUI];
                        cell.productName.frame = CGRectMake(margin, cell.frame.size.height/2 - 10-cell.productName.frame.size.height, diff - margin * 2, cell.productName.frame.size.height);
                        [cell.productName setLineBreakMode:NSLineBreakByWordWrapping];
                        [cell.productName setTextAlignment:NSTextAlignmentCenter];
                        [cell.productName setNumberOfLines:2];
                        [cell.productName sizeToFitUI];
                        cell.productImg.frame = CGRectMake(diff, 0, diff, cell.frame.size.height);
                        cell.productImgDummy.frame = CGRectMake(diff, 0, diff, cell.frame.size.height);
                        cell.imgHeaderBg.frame = CGRectMake(0, 0, diff, cell.frame.size.height);
                        cell.productName.frame = CGRectMake(margin, cell.frame.size.height/2 - 10-cell.productName.frame.size.height, diff - margin * 2, cell.productName.frame.size.height);
                        cell.labelExploreNow.frame = CGRectMake(0 + cell.frame.size.width * .125f, cell.frame.size.height/2 + 10, cell.frame.size.width * .25f, cell.frame.size.height * .125f);
                    } else {
                        cell.productImg.translatesAutoresizingMaskIntoConstraints = YES;
                        cell.productImgDummy.translatesAutoresizingMaskIntoConstraints = YES;
                        cell.productName.translatesAutoresizingMaskIntoConstraints = YES;
                        cell.labelExploreNow.translatesAutoresizingMaskIntoConstraints = YES;
                        cell.imgHeaderBg.translatesAutoresizingMaskIntoConstraints = YES;
                        CGRect cellFrame = cell.frame;
                        int diff = cellFrame.size.width/2;
                        int margin = 5;
                        [cell.productName sizeToFitUI];
                        cell.productName.frame = CGRectMake(diff + margin, cell.frame.size.height/2 - 10 - cell.productName.frame.size.height, diff - margin * 2, cell.productName.frame.size.height);
                        [cell.productName setLineBreakMode:NSLineBreakByWordWrapping];
                        [cell.productName setTextAlignment:NSTextAlignmentCenter];
                        [cell.productName setNumberOfLines:2];
                        [cell.productName sizeToFitUI];
                        cell.productImg.frame = CGRectMake(0, 0, diff, cell.frame.size.height);
                        cell.productImgDummy.frame = CGRectMake(0, 0, diff, cell.frame.size.height);
                        cell.imgHeaderBg.frame = CGRectMake(diff, 0, diff, cell.frame.size.height);
                        cell.productName.frame = CGRectMake(diff + margin, cell.frame.size.height/2 - 10-cell.productName.frame.size.height, diff - margin * 2, cell.productName.frame.size.height);
                        cell.labelExploreNow.frame = CGRectMake(diff + cell.frame.size.width * .125f, cell.frame.size.height/2 + 10, cell.frame.size.width * .25f, cell.frame.size.height * .125f);
                    }
                    cell.labelExploreNow.backgroundColor = [Utility getUIColor:kUIColorBuyButtonNormalBg];
                    cell.labelExploreNow.textColor = [Utility getUIColor:kUIColorBuyButtonFont];
                    [cell.labelExploreNow setUIFont:kUIFontType14 isBold:true];
                    cell.labelExploreNow.text = Localize(@"explore_now");
                    [cell setNeedsLayout];
                    [cell layoutSubviews];
                    break;
                case C_LAYOUT_FULL:
                    break;
                default:
                    break;
            }
        }break;
        case _kTrending:
        case _kMaxSold:
        case _kNew:
        case _kDiscount:
        case _kUserDefined1:
        case _kUserDefined2:
        case _kUserDefined3:
        case _kUserDefined4:
        case _kUserDefined5:
        {
            if(cell == nil) {
                NSArray *nib = [[ NSBundle mainBundle] loadNibNamed:_strCollectionView3 owner:self options:nil];
                cell = [nib objectAtIndex:0];
            }
            [Utility showShadow:cell];
            [cell setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
            [[cell productName] setUIFont:kUIFontType16 isBold:false];
            [[cell productName] setTextColor:[Utility getUIColor:kUIColorFontDark]];
            [[cell productPriceOriginal] setUIFont:kUIFontType14 isBold:false];
            [[cell productPriceFinal] setUIFont:kUIFontType14 isBold:false];
            if ([[TMLanguage sharedManager] isRTLEnabled]) {
                [[cell productName] setTextAlignment:NSTextAlignmentRight];
                [[cell productPriceOriginal] setTextAlignment:NSTextAlignmentRight];
                [[cell productPriceFinal] setTextAlignment:NSTextAlignmentRight];
            }
#if PROMO_ENABLE_IN_HORIZONTAL_VIEWS
            if (indexPath.row >= (int)[[ProductInfo getProducts:_viewKey[i] isAscending:YES viewType:i-_kTrending] count] && [[DataManager sharedManager] promoEnable]) {
                [[cell productName] setText:@""];
                [[cell productPriceOriginal] setText:@""];
                [[cell buttonWishlist]setHidden:true];
                [[cell productPriceFinal] setText:@""];
                [Utility setImage:cell.productImg url:[[DataManager sharedManager] promoUrlImgPath]];
                UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(promoTapped:)];
                singleTap.numberOfTapsRequired = 1;
                singleTap.numberOfTouchesRequired = 1;
                [cell.productImg addGestureRecognizer:singleTap];
                [cell.productImg setUserInteractionEnabled:YES];
            }else
#endif
            {
                ProductInfo *pInfo = (ProductInfo*) ([[ProductInfo getProducts:_viewKey[i] isAscending:YES viewType:i-_kTrending] objectAtIndex:indexPath.row]);
                [[cell productName] setText:pInfo._titleForOuterView];
                [[cell productPriceOriginal] setAttributedText:[pInfo getPriceOldString]];
                [[cell productPriceFinal] setText:[pInfo getPriceNewString]];
                if ([pInfo._images count] == 0) {
                    [pInfo._images addObject:[[ProductImage alloc] init]];
                }
                if (([[GuestConfig sharedInstance] hide_price] && ![AppUser isSignedIn]) || [[Addons sharedManager] hide_price]) {
                    [[cell productPriceOriginal] setText:@""];
                    [[cell productPriceFinal] setText:@""];
                    [cell.productPriceOriginal sizeToFitUI];
                    [cell.productPriceFinal sizeToFitUI];
                } else {
                    [cell.productPriceOriginal sizeToFitUI];
                    [cell.productPriceFinal sizeToFitUI];
                }
                ProductImage *pImage = [pInfo._images objectAtIndex:0];
                [Utility setImage:cell.productImg url:pImage._src resizeType:kRESIZE_TYPE_PRODUCT_THUMBNAIL isLocal:false];
                if ([cell buttonWishlist].imageView.image.renderingMode != UIImageRenderingModeAlwaysTemplate) {
                    UIImage* normal = [[UIImage imageNamed:@"wishlist_icon_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                    UIImage* selected = [[UIImage imageNamed:@"wishlist_icon_pressed"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                    [[cell buttonWishlist] setUIImage:normal forState:UIControlStateNormal];
                    [[cell buttonWishlist] setUIImage:selected forState:UIControlStateSelected];
                }
                [[cell buttonWishlist] addTarget:[Utility sharedManager] action:@selector(wishlistButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                [[cell buttonWishlist] setTag:pInfo._id];
                [[Utility sharedManager] initWishlistButton:[cell buttonWishlist]];
                if ([cell.productImg.layer valueForKey:@"UITapGestureRecognizer"]) {
                    [cell.productImg removeGestureRecognizer:((UITapGestureRecognizer*)[cell.productImg.layer valueForKey:@"UITapGestureRecognizer"])];
                }
                [cell.productImg setTag:pInfo._id];
                UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bannerTapped:)];
                singleTap.numberOfTapsRequired = 1;
                singleTap.numberOfTouchesRequired = 1;
                [cell.productImg addGestureRecognizer:singleTap];
                [singleTap.view.layer setValue:cell forKey:@"CELL_OBJ"];
                [cell.productImg setUserInteractionEnabled:YES];
                [cell.productImg.layer setValue:singleTap forKey:@"UITapGestureRecognizer"];
                [cell.productImg.layer setValue:pInfo._titleForOuterView forKey:@"PNAME"];
                if ([cell buttonAdd].imageView.image.renderingMode != UIImageRenderingModeAlwaysTemplate) {
                    UIImage* normal = [[UIImage imageNamed:@"button_circle"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                    [cell.buttonAdd setBackgroundImage:normal forState:UIControlStateNormal];
                }
                if ([cell buttonSubstract].imageView.image.renderingMode != UIImageRenderingModeAlwaysTemplate) {
                    UIImage* normal = [[UIImage imageNamed:@"button_circle"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                    [cell.buttonSubstract setBackgroundImage:normal forState:UIControlStateNormal];
                }
                if (pInfo) {
                    [cell.layer setValue:self forKey:@"VC"];
                    [cell.layer setValue:pInfo forKey:@"PRODUCT_INFO"];
                    [cell.layer setValue:pInfo forKey:@"PINFO_OBJ"];
                    [cell.buttonAdd.layer setValue:pInfo forKey:@"PINFO_OBJ"];
                    [cell.buttonAdd.layer setValue:cell forKey:@"CELL_OBJ"];
                    [cell.buttonCart.layer setValue:pInfo forKey:@"PINFO_OBJ"];
                    [cell.buttonCart setTitle:Localize(@"toggle_cart_on") forState:UIControlStateNormal];
                    [cell.buttonCart.layer setValue:cell forKey:@"CELL_OBJ"];
                    [cell.buttonSubstract.layer setValue:pInfo forKey:@"PINFO_OBJ"];
                    [cell.buttonSubstract.layer setValue:cell forKey:@"CELL_OBJ"];
                    [cell.textFieldAmt.layer setValue:pInfo forKey:@"PINFO_OBJ"];
                    [cell.textFieldAmt.layer setValue:cell forKey:@"CELL_OBJ"];
                    
                    [cell.buttonCart addTarget:self action:@selector(cartButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.buttonAdd addTarget:self action:@selector(addButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.buttonSubstract addTarget:self action:@selector(substractButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                } else {
                    [cell.layer setValue:nil forKey:@"PRODUCT_INFO"];
                    [cell.layer setValue:nil forKey:@"PINFO_OBJ"];
                }
            }
        } break;
        default:
            break;
    }
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    int i = 0;
    for (; i < _kTotalViewsHomeScreen; i++) {
        if(_viewUserDefined[i] == collectionView){
            break;
        }
    }
    NSMutableArray *array = nil;
    switch (i) {
        case _kCategoryBasic:
        {
            array = [LayoutProperties CardPropertiesForCategoryView];
            float cardHorizontalSpacing = [[array objectAtIndex:0] floatValue];
            float cardVerticalSpacing = [[array objectAtIndex:1] floatValue];
            float cardWidth = [[array objectAtIndex:2] floatValue];
            float cardHeight = [[array objectAtIndex:3] floatValue];
            float insetLeft = [[array objectAtIndex:4] floatValue];
            float insetRight = [[array objectAtIndex:5] floatValue];
            float insetTop = [[array objectAtIndex:6] floatValue];
            float insetBottom = [[array objectAtIndex:7] floatValue];
            collectionView.contentInset = UIEdgeInsetsMake(insetTop, insetLeft, insetBottom, insetRight);
            UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)[collectionView collectionViewLayout];
            layout.minimumInteritemSpacing = cardHorizontalSpacing;
            layout.minimumLineSpacing = cardVerticalSpacing;
            _propCollectionView[i]._insetTop =  insetTop;
            _propCollectionView[i]._insetLeft =  insetLeft;
            _propCollectionView[i]._insetBottom =  insetBottom;
            _propCollectionView[i]._insetRight =  insetRight;
            return CGSizeMake(cardWidth, cardHeight);
        }break;
        case _kTrending:
        case _kMaxSold:
        case _kNew:
        case _kDiscount:
        {
            array = [LayoutProperties CardPropertiesForHorizontalView];
            float cardHorizontalSpacing = [[array objectAtIndex:0] floatValue];
            float cardVerticalSpacing = [[array objectAtIndex:1] floatValue];
            float cardWidth = [[array objectAtIndex:2] floatValue];
            float cardHeight = [[array objectAtIndex:3] floatValue];
            float insetLeft = [[array objectAtIndex:4] floatValue];
            float insetRight = [[array objectAtIndex:5] floatValue];
            float insetTop = [[array objectAtIndex:6] floatValue];
            float insetBottom = [[array objectAtIndex:7] floatValue];
            UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)[collectionView collectionViewLayout];
            layout.minimumInteritemSpacing = cardHorizontalSpacing;
            layout.minimumLineSpacing = cardVerticalSpacing;
            _propCollectionView[i]._insetTop =  insetTop;
            _propCollectionView[i]._insetLeft =  insetLeft;
            _propCollectionView[i]._insetBottom =  insetBottom;
            _propCollectionView[i]._insetRight =  insetRight;
            _propCollectionView[i]._height = cardHeight + _propCollectionView[i]._insetTop + _propCollectionView[i]._insetBottom;
            [_viewUserDefined[i] setFrame:[_propCollectionView[i] getFrameRect]];
            [self resetMainScrollView];
            return CGSizeMake(cardWidth, cardHeight);
        }break;
        case _kUserDefined1:
        case _kUserDefined2:
        case _kUserDefined3:
        case _kUserDefined4:
        case _kUserDefined5:
            break;
        default:
            break;
    }
    return CGSizeMake(0, 0);
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    int i = 0;
    for (; i < _kTotalViewsHomeScreen; i++) {
        if(_viewUserDefined[i] == collectionView){
            break;
        }
    }
    switch (i) {
        case _kCategoryBasic:
        {
            if ([[CategoryInfo getAllRootCategories] count] <= indexPath.row) {
                return;
            }
            CategoryInfo *cInfo = (CategoryInfo*) ([[CategoryInfo getAllRootCategories] objectAtIndex:indexPath.row]);
            [self clickOnCategory:cInfo currentItemData:nil];
            
        } break;
        case _kTrending:
        case _kMaxSold:
        case _kNew:
        case _kDiscount:
        case _kUserDefined1:
        case _kUserDefined2:
        case _kUserDefined3:
        case _kUserDefined4:
        case _kUserDefined5:
            break;
        default:
            break;
    }
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
        [UIView animateWithDuration:0.1f animations:^{
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
#if NEW_WAY
//    [_scrollView setFrame:CGRectMake(200, 200, 500, 100)];
#else
    float globalPosY = 0.0f;
    UIView* tempView = nil;
    for (tempView in _viewsAdded) {
        CGRect rect = [tempView frame];
        rect.origin.y = globalPosY;
        [tempView setFrame:rect];
        globalPosY += rect.size.height;
        
        if ([tempView tag] == kTagForGlobalSpacing) {
            globalPosY += [LayoutProperties globalVerticalMargin];
        }
    }
    [_scrollView setContentSize:CGSizeMake(_scrollView.contentSize.width, globalPosY)];
#endif
}
#pragma mark - HorizontalLine
- (void)addHorizontalLine:(int)tag {
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
    lineView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    lineView.backgroundColor = [Utility getUIColor:kUIColorBorder];
#if NEW_WAY
    [_scrollView.contentView addSubview:lineView];
#else
    [_scrollView addSubview:lineView];
#endif
    [_viewsAdded addObject:lineView];
    [lineView setTag:tag];
}
- (void)clickOnCategory:(CategoryInfo*)categoryClicked currentItemData:(DataPass*)currentItemData{
    self.isHomeScreenPresented = false;
    
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
    
    ViewControllerCategories* vcCategories = [[Utility sharedManager] pushScreen:mainVC.vcCenterTop];
    [vcCategories loadData:clickedItemData previousItem:previousItemData drillingLevel:0];
}
- (void)clickOnProduct:(id)productClicked currentItemData:(id)currentItemData cell:(id)cell {
    self.isHomeScreenPresented = false;
    ProductInfo* pInfo = productClicked;
    DataPass* dPass = currentItemData;
    
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
    clickedItemData.itemId = pInfo._id;
    clickedItemData.isCategory = false;
    clickedItemData.isProduct = true;
    clickedItemData.hasChildCategory = false;
    clickedItemData.childCount = false;
    clickedItemData.pInfo = pInfo;
    
    DataPass* previousItemData = [[DataPass alloc] init];
    previousItemData.itemId = dPass.cInfo._id;
    previousItemData.isCategory = dPass.isCategory;
    previousItemData.isProduct = dPass.isProduct;
    previousItemData.hasChildCategory = dPass.hasChildCategory;
    previousItemData.childCount = dPass.childCount;
    previousItemData.cInfo = dPass.cInfo;
    
    ViewControllerProduct* vcProduct = [[Utility sharedManager] pushProductScreen:mainVC.vcCenterTop];
    [vcProduct loadData:clickedItemData previousItem:previousItemData drillingLevel:0];
    vcProduct.parentVC = self;
    vcProduct.parentCell = cell;
}
- (id)openProductVC {
    self.isHomeScreenPresented = false;
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
    ViewControllerProduct* vcProduct = [[Utility sharedManager] pushProductScreen:mainVC.vcCenterTop];
    return vcProduct;
}
- (void)loadProductVC:(id)vcProduct productClicked:(id)productClicked {
    ProductInfo* pInfo = productClicked;
    DataPass* dPass = nil;
    DataPass* clickedItemData = [[DataPass alloc] init];
    clickedItemData.itemId = pInfo._id;
    clickedItemData.isCategory = false;
    clickedItemData.isProduct = true;
    clickedItemData.hasChildCategory = false;
    clickedItemData.childCount = false;
    clickedItemData.pInfo = pInfo;
    DataPass* previousItemData = [[DataPass alloc] init];
    previousItemData.itemId = dPass.cInfo._id;
    previousItemData.isCategory = dPass.isCategory;
    previousItemData.isProduct = dPass.isProduct;
    previousItemData.hasChildCategory = dPass.hasChildCategory;
    previousItemData.childCount = dPass.childCount;
    previousItemData.cInfo = dPass.cInfo;
    ViewControllerProduct* productVC = vcProduct;
    [productVC loadData:clickedItemData previousItem:previousItemData drillingLevel:0];
    productVC.parentVC = self;
    productVC.parentCell = nil;
}
#if __IPHONE_OS_VERSION_MAX_ALLOWED > 90000
- (void)previewControllerDidFinish:(RPPreviewViewController *)previewController{
    RLOG(@"%@", previewController);
}
- (void)previewController:(RPPreviewViewController *)previewController didFinishWithActivityTypes:(NSSet <NSString *> *)activityTypes{
    RLOG(@"%@", previewController);
    RLOG(@"%@", activityTypes);
    [[Utility sharedManager] popScreen:previewController];
}
#endif
- (void)removeUserDefinedView:(int)viewId {
    //    _isViewUserDefinedEnable[viewId] = false;
    [_viewUserDefinedHeader[viewId] removeFromSuperview];
    [_viewsAdded removeObject:_viewUserDefinedHeader[viewId]];
    [_viewUserDefined[viewId] removeFromSuperview];
    [_viewsAdded removeObject:_viewUserDefined[viewId]];
    //    _viewUserDefined[viewId] = nil;
    [self resetMainScrollView];
}
- (void)removeBannerView {
    [_bannerScrollView removeFromSuperview];
    [_viewsAdded removeObject:_bannerScrollView];
    [self resetMainScrollView];
}
#pragma mark Grocery mode
- (void)addButtonClicked:(UIButton*)button {
    [[Utility sharedManager] addButtonClicked:button];
}
- (void)substractButtonClicked:(UIButton*)button {
    [[Utility sharedManager] substractButtonClicked:button];
}
- (void)groceryAddButtonClicked:(UIButton*)button {
    [[Utility sharedManager] addButtonClicked:button];
}
- (void)grocerySubstractButtonClicked:(UIButton*)button {
    [[Utility sharedManager] substractButtonClicked:button];
}
- (void)cartButtonClicked:(UIButton*)button {
    ProductInfo* pInfo = (ProductInfo*)[button.layer valueForKey:@"PINFO_OBJ"];
    CCollectionViewCell* cell = (CCollectionViewCell*)[button.layer valueForKey:@"CELL_OBJ"];
    if (cell.actIndicator.hidden == false) {
        return;
    }
    if (pInfo._isFullRetrieved == false) {
        if (pInfo._type == PRODUCT_TYPE_SIMPLE) {
            RLOG(@"NOTIFY_PRODUCT_LOADED1 = CELL = %@", cell);
            [[NSNotificationCenter defaultCenter] addObserver:cell selector:@selector(updateCell:) name:@"NOTIFY_PRODUCT_LOADED" object:nil];
            [[DataManager sharedManager] fetchSingleProductData:nil productId:pInfo._id];
            [cell.actIndicator setHidden:false];
            [cell.buttonCart setHidden:true];
        } else {
            [self clickOnProduct:pInfo currentItemData:nil cell:cell];
        }
    } else {
        if (pInfo._variations && [pInfo._variations count] > 0) {
            //open new popup to choose variation and add to cart
            [self clickOnProduct:pInfo currentItemData:nil cell:cell];
        } else {
            int availState = [Cart getProductAvailibleState:pInfo variationId:-1];
            if (availState == PRODUCT_QTY_DEMAND || availState == PRODUCT_QTY_STOCK) {
                [Cart addProduct:pInfo variationId:-1 variationIndex:-1 selectedVariationAttributes:nil];
            }
        }
    }
    [cell refreshCell:pInfo];
}
- (void)backFromProductScreen:(id)cell{
    if (cell) {
        CCollectionViewCell* pCell = (CCollectionViewCell*)cell;
        ProductInfo* pInfo = (ProductInfo*)[pCell.layer valueForKey:@"PINFO_OBJ"];
        if (pInfo) {
            [pCell refreshCell:pInfo];
        }
    }
}
- (void) loadWaitListProductIds {
    if([[Addons sharedManager] enable_custom_waitlist]) {
        if ([AppUser isSignedIn]) {
            [[DataManager getDataDoctor] getWaitListProductIds:[[AppUser sharedManager] _id] emailId:[[AppUser sharedManager] _email] success:^(id data) {
                RLOG(@"WaitList Product Ids loading success.");
            } failure:^(NSString *error) {
                RLOG(@"WaitList Product Ids loading failed.");
            }];
        }
    }
}
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    self.isHomeScreenPresented = false;
    ViewControllerMain* mainVC = [ViewControllerMain getInstance];
    [mainVC btnClickedSearch:nil];
    return NO;
}
- (void) loadProductsPincodeSettings {
    if([[Addons sharedManager] enable_pincode_settings]) {
        if(![[PincodeSetting getInstance] isFetched]) {
            [[DataManager getDataDoctor] getProductsPincodeSettings:^(id data) {
                PincodeSetting* picodeSetting = [PincodeSetting getInstance];
                picodeSetting.fetched = YES;
            } failure:^(NSString *error) {
                PincodeSetting* picodeSetting = [PincodeSetting getInstance];
                picodeSetting.fetched = NO;
            }];
        }
    }
}
#pragma mark -
#pragma mark - GOOGLE ADMOB
#if ENABLE_GOOGLE_ADMOB_SDK
- (void)checkTimerDelay:(float)dt {
    RLOG(@"adTime = %d", self.adTime);
    RLOG(@"adTime:isHomeScreenPresented = %d", self.isHomeScreenPresented);
    Addons* addons = [Addons sharedManager];
    if (addons.googleAdmobPlugin.ad_delay == self.adTime) {
        [self showAd:nil];
    } else if(addons.googleAdmobPlugin.ad_delay > self.adTime) {
        self.adTime++;
    } else {
        //ad is present at this time
    }
}
- (void)checkTimerInterval:(float)dt {
    RLOG(@"adTime = %d", self.adTime);
    RLOG(@"adTime:isHomeScreenPresented = %d", self.isHomeScreenPresented);
    Addons* addons = [Addons sharedManager];
    if (addons.googleAdmobPlugin.ad_interval == self.adTime) {
        [self showAd:nil];
    } else if(addons.googleAdmobPlugin.ad_interval > self.adTime) {
        self.adTime++;
    } else {
        //ad is present at this time
    }
}
- (IBAction)showAd:(id)sender {
    RLOG(@"showAd");
    RLOG(@"showAd:isHomeScreenPresented = %d", self.isHomeScreenPresented);
    BOOL isSideDrawerVisible = NO;
    ViewControllerMain* mainVC = [ViewControllerMain getInstance];
    if (mainVC.revealController) {
        isSideDrawerVisible = [mainVC.revealViewController isAnySideViewVisible];
    }
    if (self.interstitial.isReady) {
        if (self.isHomeScreenPresented && isSideDrawerVisible == NO) {
            self.adTime = -1;
            if (self.adTimerDelay) {
                [self.adTimerDelay invalidate];
                self.adTimerDelay = nil;
            }
            if (self.adTimerInterval == nil) {
                self.adTimerInterval = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(checkTimerInterval:) userInfo:nil repeats:YES];
            }
            [self.interstitial presentFromRootViewController:self];
        }
    } else {
        RLOG(@"Ad wasn't ready");
        if (self.interstitial == nil) {
            [self createAndLoadInterstitial];
        }
    }
}
- (GADInterstitial *)createAndLoadInterstitial {
    RLOG(@"createAndLoadInterstitial");
    Addons* addons = [Addons sharedManager];
    self.interstitial = [[GADInterstitial alloc] initWithAdUnitID:addons.googleAdmobPlugin.ad_unit_id];
    self.interstitial.delegate = self;
    [self.interstitial loadRequest:[GADRequest request]];
    return self.interstitial;
}
#pragma mark GADInterstitialDelegate Methods
- (void)interstitialDidDismissScreen:(GADInterstitial *)interstitial {
    RLOG(@"interstitialDidDismissScreen");
    [self createAndLoadInterstitial];
    self.adTime = 0;
}
/// Tells the delegate an ad request succeeded.
- (void)interstitialDidReceiveAd:(GADInterstitial *)ad {
    RLOG(@"interstitialDidReceiveAd");
}
/// Tells the delegate an ad request failed.
- (void)interstitial:(GADInterstitial *)ad
didFailToReceiveAdWithError:(GADRequestError *)error {
    RLOG(@"interstitial:didFailToReceiveAdWithError: %@", [error localizedDescription]);
}
/// Tells the delegate that an interstitial will be presented.
- (void)interstitialWillPresentScreen:(GADInterstitial *)ad {
    RLOG(@"interstitialWillPresentScreen");
}
/// Tells the delegate the interstitial is to be animated off the screen.
- (void)interstitialWillDismissScreen:(GADInterstitial *)ad {
    RLOG(@"interstitialWillDismissScreen");
}
/// Tells the delegate the interstitial had been animated off the screen.
//- (void)interstitialDidDismissScreen:(GADInterstitial *)ad {
//    NSLog(@"interstitialDidDismissScreen");
//}
/// Tells the delegate that a user click will open another app
/// (such as the App Store), backgrounding the current app.
- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad {
    RLOG(@"interstitialWillLeaveApplication");
}
#endif
#pragma mark -
#pragma mark - CONSENT SCREEN
- (void)showConsentScreen {
    Addons* addons = [Addons sharedManager];
    ConsentScreenConfig* csConfig = addons.csConfig;
    if (csConfig.enabled) {
        if(csConfig.show_always) {
            [self createConsentScreen];
        } else {
            BOOL isCSShown = false;
            if ([[NSUserDefaults standardUserDefaults] valueForKey:@"IS_CS_SHOWN"]) {
                isCSShown = [[[NSUserDefaults standardUserDefaults] valueForKey:@"IS_CS_SHOWN"] boolValue];
            }
            if (isCSShown == false) {
                [self createConsentScreen];
            }
        }
    }
}
- (void)createConsentScreen {
    if(self.popupControllerCS == nil) {
        float widthView = [[MyDevice sharedManager] screenSize].width - [[MyDevice sharedManager] screenSize].width * 0.1f;
        float heightView = [[MyDevice sharedManager] screenSize].height - [[MyDevice sharedManager] screenSize].width * 0.1f;
        if ([[MyDevice sharedManager] isIpad]) {
//            widthView = [[MyDevice sharedManager] screenWidthInPortrait] * 0.65f;
//            heightView = [[MyDevice sharedManager] screenHeightInPortrait] * 0.63f;
            widthView = [[MyDevice sharedManager] screenHeightInPortrait] * 0.60f;
            heightView = [[MyDevice sharedManager] screenWidthInPortrait];
        } else if ([[MyDevice sharedManager] isIphone]) {
            widthView = [[MyDevice sharedManager] screenSize].width * 0.96f;
            heightView = [[MyDevice sharedManager] screenSize].height * 0.90f;
        }
        self.csView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, widthView, heightView)];
        self.csViewScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, widthView, heightView - 80)];
        [self.csView addSubview:self.csViewScroll];
        self.csView.backgroundColor = [Utility getUIColor:kUIColorBgTheme];
        self.csViewScroll.backgroundColor = [Utility getUIColor:kUIColorBgTheme];
        self.popupControllerCS = [[CNPPopupController alloc] initWithContents:@[self.csView]];
        self.popupControllerCS.theme = [CNPPopupTheme consentScreenTheme];
        self.popupControllerCS.theme.popupStyle = CNPPopupStyleCentered;
        self.popupControllerCS.theme.size = CGSizeMake(widthView, heightView);
        self.popupControllerCS.theme.maxPopupWidth = widthView;
        self.popupControllerCS.delegate = self;
        self.popupControllerCS.theme.shouldDismissOnBackgroundTouch = false;
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            self.popupControllerCS.VIEW_POPUP.transform = CGAffineTransformMakeScale(-1, 1);
        }
        float gap = 10;
        float posX = 10;
        float posY = 20;
        float labelW = widthView - 20;
        float imgW = widthView - 20;
        float buttonW = 250;
        float buttonH = 50;
        float labelH = 50;
        Addons* addons = [Addons sharedManager];
        self.csLayouts = [[NSMutableArray alloc] init];
        for (ConsentScreenLayout* layout in addons.csConfig.layout) {
            switch (layout.viewType) {
                case CS_VIEW_TYPE_TEXT:
                {
                    UILabel* label = [[UILabel alloc] init];
                    [label setFrame:CGRectMake(posX, posY, labelW, labelH)];
                    [label setText:layout.contentString];
                    [label setTextColor:[Utility getUIColor:kUIColorFontDark]];
                    switch (layout.viewSubType) {
                        case CS_VIEW_SUB_TYPE_NORMAL:
                            [label setUIFont:kUIFontType18 isBold:false];
                            break;
                        case CS_VIEW_SUB_TYPE_HEADER:
                            [label setUIFont:kUIFontType28 isBold:true];
                            break;
                        default:
                            [label setUIFont:kUIFontType18 isBold:false];
                            break;
                    }
                    [label setTextAlignment:NSTextAlignmentCenter];
                    [label setLineBreakMode:NSLineBreakByWordWrapping];
                    [label setNumberOfLines:0];
                    [label sizeToFitUI];
                    if (layout.viewSubType != CS_VIEW_SUB_TYPE_HEADER &&
                        label.frame.size.height > label.font.lineHeight) {
                        [label setTextAlignment:NSTextAlignmentLeft];
                    }
                    [label setCenter:CGPointMake(self.csViewScroll.center.x, label.center.y)];
                    [self.csViewScroll addSubview:label];
                    [self.csLayouts addObject:label];
//                    [label.layer setBorderWidth:1];
                    posY = CGRectGetMaxY(label.frame) + gap;
                } break;
                case CS_VIEW_TYPE_IMAGE:
                {
                    UIImageView* imgView = [[UIImageView alloc] initWithFrame:CGRectMake(posX, posY, imgW, 0)];
                    [imgView setContentMode:UIViewContentModeScaleAspectFit];
                    NSURL* nsurl = [NSURL URLWithString:[layout.contentString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//                    NSURL* nsurl = [NSURL URLWithString:[@"https://cdn0.iconfinder.com/data/icons/black-icon-social-media/256/099280-blinklist-logo.png" stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                    [imgView sd_setImageWithURL:nsurl placeholderImage:nil options:[Utility getImageDownloadOption] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                        CGSize imgSizeOriginal = image.size;
                        float ratio = imgView.frame.size.width / imgSizeOriginal.width;
                        float scaledWidth = imgView.frame.size.width;
                        float scaledHeight = imgSizeOriginal.height * ratio;
                        if (scaledWidth > imgSizeOriginal.width) {
                            scaledHeight = imgSizeOriginal.height;
                        }
                        imgView.frame = CGRectMake(
                                                   imgView.frame.origin.x,
                                                   imgView.frame.origin.y,
                                                   scaledWidth,
                                                   scaledHeight
                                                   );
                        [self updateConsentScreen];
                    }];
                    [imgView setCenter:CGPointMake(self.csViewScroll.center.x, imgView.center.y)];
                    [self.csViewScroll addSubview:imgView];
                    [self.csLayouts addObject:imgView];
//                    [imgView.layer setBorderWidth:1];
                    posY = CGRectGetMaxY(imgView.frame) + gap;
                } break;
                case CS_VIEW_TYPE_BUTTON:
                {
                    UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(posX, self.csView.frame.size.height - 65, buttonW, buttonH)];
                    [button setTitle:layout.contentString forState:UIControlStateNormal];
                    [button setTitleColor:[Utility getUIColor:kUIColorBuyButtonFont] forState:UIControlStateNormal];
                    [button.titleLabel setUIFont:kUIFontType16 isBold:true];
                    [button setBackgroundColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
                    [button addTarget:self action:@selector(eventContinueConsentScreen) forControlEvents:UIControlEventTouchUpInside];
                    [button setCenter:CGPointMake(self.csView.center.x, button.center.y)];
                    [self.csView addSubview:button];
//                    [self.csLayouts addObject:button];
//                    [button.layer setBorderWidth:1];
//                    posY = CGRectGetMaxY(button.frame) + endGap;
                }break;
                default:
                    break;
            }
        }
        [self.csViewScroll setContentSize:CGSizeMake(widthView, posY)];
    }
    [self.popupControllerCS presentPopupControllerAnimated:YES];
}
- (void)updateConsentScreen {
    float gap = 10;
    float posY = 20;
    for (UIView* view in self.csLayouts) {
        CGRect frame = view.frame;
        frame.origin.y = posY;
        view.frame = frame;
        posY = CGRectGetMaxY(view.frame) + gap;
    }
    [self.csViewScroll setContentSize:CGSizeMake(self.csViewScroll.contentSize.width, posY)];
}
- (void)eventContinueConsentScreen {
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:true] forKey:@"IS_CS_SHOWN"];
    [self.popupControllerCS dismissPopupControllerAnimated:YES];
}
@end
