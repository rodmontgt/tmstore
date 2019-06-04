//
//  ViewControllerSplashSecondary.m
//  eCommerceApp
//
//  Created by Rishabh Jain on 16/09/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import "ViewControllerSplashSecondary.h"
#import "SWRevealViewController.h"
#import "DataManager.h"
#import "ServerData.h"
#import "CommonInfo.h"
#import "ProductInfo.h"
#import "ProductImage.h"
#import "Attribute.h"
#import "CategoryInfo.h"
#import "Variation.h"
#import "Order.h"
#import "AppUser.h"
#import "ParseHelper.h"
#import "ShippingWooCommerce.h"
#import "Variables.h"
#import "ShippingRajaongkir.h"
#import "AnalyticsHelper.h"
#import "ViewControllerSellerZone.h"
@interface ViewControllerSplashSecondary()

@property ServerData* _tempServerData;
@property UIView* _tempView;

@end


@implementation ViewControllerSplashSecondary

+ (NSDictionary*)dictionaryWithContentsOfJSONString:(NSString*)fileLocation{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[fileLocation stringByDeletingPathExtension] ofType:[fileLocation pathExtension]];
    NSData* data = [NSData dataWithContentsOfFile:filePath];
    __autoreleasing NSError* error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    // Be careful here. You add this as a category to NSDictionary
    // but you get an id back, which means that result
    // might be an NSArray as well!
    if (error != nil) return nil;
    return result;
}
#pragma mark - View Life Cycle

- (void)viewDidLoad {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super viewDidLoad];
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        self.view.transform = CGAffineTransformMakeScale(-1, 1);
    }
    self.view.backgroundColor = [UIColor whiteColor];
    
    [_mainView setBackgroundColor:[UIColor whiteColor]];
    
    [_imageFg setUIImage:[Utility getSplashFgImage]];
    [_imageBg setUIImage:[Utility getSplashBgImage]];
    if ([[DataManager sharedManager] show_tmstore_text]) {
        [_labelPoweredBy setText:Localize(@"powered_by_tm_store")];
    }else{
        [_labelPoweredBy setText:@""];
    }
    [_labelPoweredBy setUIFont:kUIFontType18 isBold:false];
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    NSString *versionStr = [NSString stringWithFormat:Localize(@"i_version_cmpny"), version, build];
    versionStr = @"";
    [_labelVersionInfo setText:versionStr];
    [_labelVersionInfo setUIFont:kUIFontType12 isBold:false];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(homePageDataLoaded:)
                                                 name:@"HOME_PAGE_DATA_LOADED"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(homePageDataFailed:)
                                                 name:@"HOME_PAGE_DATA_FAILED"
                                               object:nil];    
    
    //    [_imageFg setFrame:CGRectMake(0, 0, [[MyDevice sharedManager] screenWidthInPortrait] * .1f, [[MyDevice sharedManager] screenWidthInPortrait] * .1f)];
}
- (void)homePageDataFailed:(NSNotification*)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HOME_PAGE_DATA_LOADED" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HOME_PAGE_DATA_FAILED" object:nil];
    
    if ([[DataManager sharedManager] appType] == APP_TYPE_DEMO) {
        if (FETCH_CUSTOM_OBJ(@"#0002")) {
            _demoCodeObj = (DemoCode*)FETCH_CUSTOM_OBJ(@"#0002");
            //            [_demoCodeObj.demoCodesArray removeAllObjects];
            //            _demoCodeObj.selectedDemoCodeId = -1;
            //            _demoCodeObj.selectedDemoCode = @"";
            //            SAVE_CUSTOM_OBJ(_demoCodeObj, @"#0002");
            DataManager* dm = [DataManager sharedManager];
            dm.merchantObjectId = @"";
        }
        _alertViewHomeDataFailed = [[UIAlertView alloc] initWithTitle:Localize(@"i_error") message:Localize(@"generic_error") delegate:self cancelButtonTitle:Localize(@"retry") otherButtonTitles:nil];
        [_alertViewHomeDataFailed show];
    }else{
        _alertViewHomeDataFailed = [[UIAlertView alloc] initWithTitle:Localize(@"i_error") message:Localize(@"generic_error") delegate:self cancelButtonTitle:Localize(@"retry") otherButtonTitles:nil];
        [_alertViewHomeDataFailed show];
    }
}
- (void)homePageDataLoaded:(NSNotification*)notification{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HOME_PAGE_DATA_LOADED" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HOME_PAGE_DATA_FAILED" object:nil];
    
    CategoryInfo* cTemp = nil;
    for (cTemp in [[CategoryInfo getAllRootCategories] reverseObjectEnumerator]) {
        //RLOG(@"cTemp._name:%@", cTemp._name);
        UIImageView* tempView = [[UIImageView alloc] init];
        [Utility setImage:tempView url:cTemp._image resizeType:kRESIZE_TYPE_CATEGORY_THUMBNAIL isLocal:false highPriority:true];
    }
    
#if MAGENTO_TEST_ENABLE
    [[[DataManager sharedManager] tmDataDoctor] testMagentoPost];
    //    [[[DataManager sharedManager] tmDataDoctor] testWooCommercePost];
#else
    if ([[Addons sharedManager] multiVendor_enable] &&
        [[Addons sharedManager] multiVendor_screen_type] == MULTIVENDOR_SCREEN_SELLER) {
        [[[DataManager sharedManager] tmDataDoctor] fetchInitialProductsDataFromPlugin_MultiVendor];
    } else {
        [[[DataManager sharedManager] tmDataDoctor] fetchInitialProductsDataFromPlugin];
    }
    
    id <ShippingEngine> se = nil;
    for (NSObject* obj in [[DataManager sharedManager] shippingEngines]) {
        if ([obj isKindOfClass:[ShippingRajaongkir class]]) {
            se = (ShippingRajaongkir*)obj;
        }
    }
    if (se == nil) {
        for (NSObject* obj in [[DataManager sharedManager] shippingEngines]) {
            if ([obj isKindOfClass:[ShippingWooCommerce class]]) {
                se = (ShippingWooCommerce*)obj;
            }
            if (se) {
                [se getCountries:nil success:^(id data) {
                    //RLOG(@"%@", data);
                } failure:^(NSString *error) {
                    RLOG(@"%@", error);
                    if ([error isEqualToString:@"retry"]) {     
                    }
                }];
            }
        }
    }
    DataManager* dm = [DataManager sharedManager];
    dm.shippingEngine = se;
    if ([se isKindOfClass:[ShippingWooCommerce class]]) {
        dm.shippingProvider = SHIPPING_PROVIDER_WOOCOMMERCE;
    }
    if ([se isKindOfClass:[ShippingRajaongkir class]]) {
        dm.shippingProvider = SHIPPING_PROVIDER_RAJAONGKIR;
    }
	
    [self goToNextViewController];
#endif
    //    [self fetchPrimaryData:self.view];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
#if SUPPORT_PORTRAIT_ORIENTATION_ONLY
    [UIViewController attemptRotationToDeviceOrientation];
#endif
    //rv//[SDWebImageManager.sharedManager.imageDownloader setValue:@"SDWebImage Demo" forHTTPHeaderField:@"AppName"];
//    SDWebImageManager.sharedManager.imageDownloader.executionOrder = SDWebImageDownloaderFIFOExecutionOrder;
    
#if (NETWORK_PROBLEM)
    UIStoryboard *sb = [Utility getStoryBoardObject];
    ViewControllerSplashSecondary *rootViewController = [sb instantiateViewControllerWithIdentifier:VC_SPLASH_SECONDARY];
    [rootViewController startTimer];
#else
    [self fetchTaxData];
#endif
    
    
    
    NSString* strSplashUrlPath = @"";
    if ([[MyDevice sharedManager] isIphone]) {
        strSplashUrlPath = [[DataManager sharedManager] splashUrlImgPathPortrait];
    }
    else {
        if ([[MyDevice sharedManager] isPortrait]) {
            strSplashUrlPath = [[DataManager sharedManager] splashUrlImgPathPortrait];
        }
        else {
            strSplashUrlPath = [[DataManager sharedManager] splashUrlImgPathLandscape];
        }
    }
    
#if ENABLE_FULL_SPLASH_ON_LAUNCH
    strSplashUrlPath = @"";
    [_constraintImgLogoWidth setPriority:999];
    [_constraintImgLogoWidthFull setPriority:1000];
    [_imageFg setContentMode:UIViewContentModeScaleToFill];
    [self.view setNeedsUpdateConstraints];
#endif
    
    
#if ENABLE_FULL_SPLASH_ON_LAUNCH_NEW
    [_imgSplash setImage:[UIImage imageNamed:strSplashUrlPath]];
    _imageFg.hidden = true;
    [_labelPoweredBy setTextColor:[[DataManager sharedManager] splashTextColor]];
    [_labelVersionInfo setTextColor:[[DataManager sharedManager] splashTextColor]];
#else
    if ([strSplashUrlPath isEqualToString:@""] == false) {
        [_imgSplash sd_setImageWithURL:[NSURL URLWithString:strSplashUrlPath] placeholderImage:nil options:[Utility getImageDownloadOption] progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
#if (ENABLE_FULL_SPLASH_ON_LAUNCH == 0)
            _imageFg.hidden = false;
#endif
            [_labelPoweredBy setTextColor:[Utility getUIColor:kUIColorFontDark]];
            [_labelVersionInfo setTextColor:[Utility getUIColor:kUIColorFontDark]];
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            _imageFg.hidden = true;
            [_labelPoweredBy setTextColor:[[DataManager sharedManager] splashTextColor]];
            [_labelVersionInfo setTextColor:[[DataManager sharedManager] splashTextColor]];
            [_imgSplash setUIImage:image];
        }];
    } else {
        [_labelPoweredBy setTextColor:[Utility getUIColor:kUIColorFontDark]];
        [_labelVersionInfo setTextColor:[Utility getUIColor:kUIColorFontDark]];
    }
#endif
}
- (void)viewDidAppear:(BOOL)animated {
    [Utility createCustomizedLoadingBar:Localize(@"i_loading_data") isBottomAlign:true isClearViewEnabled:true isShadowEnabled:true];
    
    //    [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
    //    MRProgressOverlayView* overlayView = [MRProgressOverlayView showOverlayAddedTo:[[UIApplication sharedApplication] keyWindow] title:@"Loading.." mode:MRProgressOverlayViewModeIndeterminateSmallDefault animated:NO];
    //    UIActivityIndicatorView* smallDefaultActivityIndicatorView = ((UIActivityIndicatorView*) overlayView.modeView);
    //    smallDefaultActivityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    //    [overlayView.titleLabel setUIFont:kUIFontType12 isBold:false];
    //    overlayView.isMannualPositionEnable = true;
    //    overlayView.mannualBound = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height * 2);
    //    overlayView.mannualPosition = CGPointMake(self.view.frame.size.width * 0.5f, self.view.frame.size.height * 0.85f);
    
    
    //    [overlayView manualLayoutSubviews];
    //    UIActivityIndicatorView* smallDefaultActivityIndicatorView = ((UIActivityIndicatorView*) overlayView.modeView);
    //    smallDefaultActivityIndicatorView.color = [Utility getUIColor:kUIColorThemeButtonSelected];
    //    CGAffineTransform transform = CGAffineTransformMakeScale(2.5f, 2.5f);
    //    smallDefaultActivityIndicatorView.transform = transform;
    //    [overlayView modeView].center = CGPointMake(100, 100);
    //    overlayView.center =CGPointMake(100, 100);// CGPointMake(smallDefaultActivityIndicatorView.center.x, overlayView.frame.size.height*.8f);
#if ENABLE_FIREBASE_TAG_MANAGER
    [[AnalyticsHelper sharedInstance] registerVisitScreenEvent:@"SplashSecondary Screen"];
#endif
}
- (void)didReceiveMemoryWarning {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super didReceiveMemoryWarning];
}

#pragma mark - Methods

- (void)goToNextViewController
{
    [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
    
    if ([Utility isSellerOnlyApp]) {
        UIStoryboard *sb = [Utility getStoryBoardObject];
        UIViewController *rootViewController = [sb instantiateViewControllerWithIdentifier:VC_SELLER_ZONE];
        [[UIApplication sharedApplication].keyWindow setRootViewController:rootViewController];
        return;
    }
    
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
    [[UIApplication sharedApplication].keyWindow setRootViewController:mainRevealController];
}
- (void)startTimer {
    [self performSelector:@selector(goToNextViewController) withObject:nil afterDelay:1.0] ;
}
- (void)cancelTimer {
    [NSObject cancelPreviousPerformRequestsWithTarget:self] ;
}
- (void)fetchTaxData {
//    DataManager* dm = [DataManager sharedManager];
//    [[dm tmDataDoctor] fetchTaxesData:^(id data) {
    
    [[[DataManager sharedManager] tmDataDoctor] fetchMenuItemsDataFromPlugin];
    
    if ([[Addons sharedManager] multiVendor_enable] &&
        [[Addons sharedManager] multiVendor_screen_type] == MULTIVENDOR_SCREEN_SELLER) {
            [[[DataManager sharedManager] tmDataDoctor] fetchHomePageDataFromPlugin_MultiVendor];
        }
        else{
            [[[DataManager sharedManager] tmDataDoctor] fetchHomePageDataFromPlugin];
        }
//    } failure:^(NSString *error) {
//        if ([error isEqualToString:@"retry"]) {
//            [self fetchTaxData];
//        } else {
//            [[[DataManager sharedManager] tmDataDoctor] fetchMenuItemsDataFromPlugin];
//            if ([[Addons sharedManager] multiVendor_enable] &&
//    [[Addons sharedManager] multiVendor_screen_type] == MULTIVENDOR_SCREEN_SELLER) {
//                [[[DataManager sharedManager] tmDataDoctor] fetchHomePageDataFromPlugin_MultiVendor];
//            }
//            else{
//                [[[DataManager sharedManager] tmDataDoctor] fetchHomePageDataFromPlugin];
//            }
//        }
//    }];
}
- (void)fetchPrimaryData:(UIView *)_vview {
    [[[[DataManager sharedManager] tmDataDoctor] tmMulticastDelegate] addDelegate:self];
    self._tempView = _vview;
    RLOG(@"Request kFetchCommonData");
    self._tempServerData = [[DataManager sharedManager] fetchCommonData:self._tempView];
}
-(void)dataFetchCompletion:(ServerData *)serverData{
    return;
    if (serverData._serverRequestStatus == kServerRequestSucceed) {
        RLOG(@"=======DATA_FETCHING:SUCCESS=======");
        RLOG(@"_serverUrl = %@",serverData._serverUrl);
        RLOG(@"_serverDataId = %d",serverData._serverDataId);
        //        RLOG(@"_serverRequestName = %@",serverData._serverRequestName);
        RLOG(@"_serverResultDictionary = %@",serverData._serverResultDictionary);
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:serverData._serverResultDictionary
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&error];
        if (! jsonData) {
            RLOG(@"Got an error: %@", error);
        } else {
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            [[NSUserDefaults standardUserDefaults] setObject:jsonString forKey:serverData._serverUrl];
        }
    } else if (serverData._serverRequestStatus == kServerRequestFailed) {
        RLOG(@"=======DATA_FETCHING:FAILED=======");
        RLOG(@"_serverUrl = %@",serverData._serverUrl);
        RLOG(@"_serverDataId = %d",serverData._serverDataId);
        //        RLOG(@"_serverRequestName = %@",serverData._serverRequestName);
        RLOG(@"_serverResultDictionary = %@",serverData._serverResultDictionary);
        NSString *jsonString = nil;
        if (CHECK_PRELOADED_DATA) {
            jsonString = [[NSUserDefaults standardUserDefaults] objectForKey:serverData._serverUrl];
        }
        if (jsonString) {
            NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            if (data) {
                id jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                if (jsonDict) {
                    serverData._serverResultDictionary = (NSDictionary*) jsonDict;
                    if (serverData._serverResultDictionary) {
                        serverData._serverRequestStatus = kServerRequestSucceed;
                    }
                }
            }
        }
    }    
    
    if (serverData._serverRequestStatus == kServerRequestSucceed) {
        switch (serverData._serverDataId) {
                
            case kFetchCommonData:
                RLOG(@"Load kFetchCommonData");
                [[DataManager sharedManager] loadCommonData:serverData._serverResultDictionary];
                RLOG(@"Request kFetchCategories");
                self._tempServerData = [[DataManager sharedManager] fetchCategoriesData:self._tempView];
                break;
                
            case kFetchCategories:
                RLOG(@"Load kFetchCategoriesData");
                [[DataManager sharedManager] loadCategoriesData:serverData._serverResultDictionary];
                RLOG(@"Request kFetchProducts");
                self._tempServerData = [[DataManager sharedManager] fetchProductData:self._tempView];
                break;
                
            case kFetchProducts:
                RLOG(@"Load kFetchProductsData");
                [[DataManager sharedManager] loadProductsData:serverData._serverResultDictionary];
                
                RLOG(@"Goto Secondary splash");
            {
                UIStoryboard *sb = [Utility getStoryBoardObject];
                ViewControllerSplashSecondary *rootViewController = [sb instantiateViewControllerWithIdentifier:VC_SPLASH_SECONDARY];
                [rootViewController startTimer];
            }
                break;
            default:
                break;
        }
    }else if (serverData._serverRequestStatus == kServerRequestFailed){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Localize(@"sorry") message:Localize(@"error_loading") delegate:self cancelButtonTitle:Localize(@"skip") otherButtonTitles:Localize(@"retry"), nil];
        [self alertView:alertView clickedButtonAtIndex:1];
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(_alertViewHomeDataFailed != nil && _alertViewHomeDataFailed == alertView) {
        ParseHelper* pH = [ParseHelper sharedManager];
        pH.isParseDataLoaded = false;
        
        NSString * storyboardName = STORYBOARD_NAME;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
        UIViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"VC_SPLASH_PRIMARY"];
        [self presentViewController:vc animated:NO completion:nil];
        return;
    }
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Retry"]) {
        switch (self._tempServerData._serverDataId) {
            case kFetchCommonData:
                RLOG(@"Request kFetchCommonData");
                self._tempServerData = [[DataManager sharedManager] fetchCommonData:self._tempView];
                break;
            case kFetchProducts:
                RLOG(@"Request kFetchProducts");
                self._tempServerData = [[DataManager sharedManager] fetchProductData:self._tempView];
                break;
            case kFetchCategories:
                RLOG(@"Request kFetchCategories");
                self._tempServerData = [[DataManager sharedManager] fetchCategoriesData:self._tempView];
                break;
            default:
                break;
        }
    }
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
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    if([[MyDevice sharedManager] isIphone]){
        return UIInterfaceOrientationMaskPortrait;
    }
    return UIInterfaceOrientationMaskAll;
}
#endif

@end
