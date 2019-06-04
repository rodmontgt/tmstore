//
//  ViewControllerProduct.m
//  eMobileApp
//
//  Created by Rishabh Jain on 09/11/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import "ViewControllerProduct.h"
#import "Utility.h"
#import "Attribute.h"
#import "Cart.h"
#import "Wishlist.h"
#import "WaitList.h"
#import "AppDelegate.h"
#import "CommonInfo.h"
#import "Variables.h"
#import "DataManager.h"
#import "ParseHelper.h"
#import "ProductReview.h"
#import "ViewControllerHome.h"
//#import "ViewControllerHomeDynamic.h"
#import "ViewControllerSearch.h"
#import "ViewControllerCategories.h"
#import "ViewControllerWebview.h"
#import "PincodeSetting.h"
#import "AnalyticsHelper.h"
#import "ViewControllerMyCouponProduct.h"
#import "ViewControllerNotification.h"
#import "VCProducts.h"
#import "ViewControllerSellerItems.h"
#import "VCProductDesc.h"
#import "ProductAttributCell.h"
static int kTagForGlobalSpacing = 0;
static int kTagForNoSpacing = -1;

@interface SelectionView()
@property (strong, nonatomic) NSMutableArray *dataObjects;
@end
@implementation SelectionView
- (id)init {
    self = [super init];
    if (self) {
        _label = [[UILabel alloc] init];
        [self addSubview:_label];
        [_label setUIFont:kUIFontType18 isBold:false];
        _button = [[UIButton alloc] init];
        [_button.layer setBorderColor:[[Utility getUIColor:kUIColorThemeButtonBorderNormal] CGColor]];
        [_button.layer setBorderWidth:1];
        [_button setBackgroundColor:[UIColor whiteColor]];
        [[_button titleLabel] setUIFont:kUIFontType24 isBold:false];
        [_button setTitle:Localize(@"i_select") forState:UIControlStateNormal];
        [_button setTitleColor:[Utility getUIColor:kUIColorFontDark] forState:UIControlStateNormal];
        [self addSubview:_button];
        [_button addTarget:self action:@selector(selectClicked:) forControlEvents:UIControlEventTouchUpInside];
        _attribute = nil;
        _attributeSelectedValue = @"";
    }
    return self;
}
- (void)loadView:(NSMutableArray*)dataArray {
    _dataObjects = [[NSMutableArray alloc] initWithArray:dataArray];
}
- (void)itemClicked:(int)clickedItemId {
    RLOG(@"clickedItemId = %d", clickedItemId);
    ViewControllerProduct* vcp = ((ViewControllerProduct*)(self.vcProduct));
    vcp.viewOpened = nil;
    
    if (clickedItemId >= (int)[self.attribute._options count]) {
        clickedItemId = (int)[self.attribute._options count] - 1;
    }
    
    NSString* strValue = [self.attribute._options objectAtIndex:clickedItemId];
    NSString* strName = self.attribute._name;
    RLOG(@"strName = %@, strValue = %@", strName, strValue);
    ((VariationAttribute*)[_selectedVariationAttibutes objectAtIndex:_viewId]).value = strValue;
    _selectedVariation = [_pInfo._variations getVariationFromAttibutes:_selectedVariationAttibutes];
    self.attributeSelectedValue = [self.attribute._options objectAtIndex:clickedItemId];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"notifyChangeInAttribute" object:_selectedVariation];
}
- (void)reponseDropDownDelegate:(NIDropDown *)sender clickedItemId:(int)clickedItemId{
    [self itemClicked:clickedItemId];
}
- (void)selectClickedTemp:(id)sender {
    UIButton* btnn =(UIButton*)sender;
    UIButton* btn = (UIButton*)[btnn.layer valueForKey:@"MY_OBJECT"];
    [self selectClicked:btn];
}
- (void)selectClicked:(id)sender {
    ViewControllerProduct* vcp = ((ViewControllerProduct*)(self.vcProduct));
    if (vcp.viewOpened) {
        [vcp.viewOpened.dropdownView toggle:vcp.viewOpened.button];
        vcp.viewOpened = nil;
    }
    vcp.viewOpened = self;
    if(_dropdownView == nil) {
        NSArray * arrImage = nil;
        CGFloat height = [[MyDevice sharedManager] screenHeightInPortrait] * .30f;
        _dropdownView = [[NIDropDown alloc] init:sender viewheight:height strArr:_dataObjects imgArr:arrImage direction:NIDropDownDirectionDown pView:_pView];
        _dropdownView.delegate = self;
        _dropdownView.fontColor = [Utility getUIColor:kUIColorBgTheme];
    }
    else {
        [_dropdownView toggle:sender];
    }
}
- (void)setParentViewForDropDownView:(UIView*)pView{
    _pView = pView;
}

@end

@interface ViewControllerProduct ()<CNPPopupControllerDelegate> {
    NSMutableArray *_viewsAdded;
    NSMutableArray *_horizontalScrollViews;
    UIButton *customBackButton;
    ProductDetailsConfig* PRODUCT_DETAILS_CONFIG;
    NSArray* callNumberPickerArray;
    NSString* callNumberSelected;
    ShopSettings* SHOP_SETTINGS;
}
@property (nonatomic, strong) CNPPopupController *zoomPopupController;
@end
@implementation ViewControllerProduct
- (void)notifyChangeInAttribute:(NSNotification*)notification{
    //here update change images and price
    _selectedVariation = (Variation*)(notification.object);
    if(_selectedVariation != NULL) {
        RLOG(@"-1- found selected variation with following details --");
        RLOG(@"-1- id:%d--", _selectedVariation._id);
        RLOG(@"-1- sku:%@--", _selectedVariation._sku);
        RLOG(@"-1- stock_quantity:%d--", _selectedVariation._stock_quantity);
        RLOG(@"-1- price:%f--", _selectedVariation._price);
        RLOG(@"-1-----------------------------------------------------");
    }
    
    [self updateBannerView];
    [self updatePrice];
    [self updateButtons];
    
}

- (void)loadPRDD_Data {
#if ENABLE_PRODUCT_DELIVERY_DATA_PLUGIN
    if ([[Addons sharedManager] productDeliveryDatePlugin] && [[[Addons sharedManager] productDeliveryDatePlugin] isEnabled]) {
        if (_currentItem.pInfo.prddDataFetched == false) {
            [[[DataManager sharedManager] tmDataDoctor] getProductDeliveryDataPRDD:_currentItem.pInfo._id success:^(id data) {
                RLOG(@"");
                _currentItem.pInfo.prddDataFetched = true;
                [[Utility sharedManager] startGrayLoadingBar:true];
                [self reloadVariations];
                [self afterRotation:0.5f];
            } failure:^(NSString *error) {
                RLOG(@"");
            }];
        }
    }
#endif
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveTestNotification:)
                                                 name:@"TestNotification"
                                               object:nil];
    //    DataManager* dm = [DataManager sharedManager];
    //    dm.layoutIdProductView = P_LAYOUT_GROCERY;
    
    
    
    
    
    Addons* addons = [Addons sharedManager];
    if (addons.multiVendor && addons.multiVendor.multiVendor_shop_settings) {
        SHOP_SETTINGS = addons.multiVendor.multiVendor_shop_settings;
    }
    _tapToExit = nil;
    PRODUCT_DETAILS_CONFIG = [ProductDetailsConfig sharedInstance];
    self.show_vertical_layout_components = PRODUCT_DETAILS_CONFIG.show_vertical_layout_components;
    
    if (PRODUCT_DETAILS_CONFIG.tap_to_exit) {
        _tapToExit = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(barButtonBackPressed:)];
        _tapToExit.numberOfTapsRequired = 1;
        _tapToExit.numberOfTouchesRequired = 1;
        [_scrollView addGestureRecognizer:_tapToExit];
        [_scrollView setUserInteractionEnabled:YES];
    }
    
    _productLoadingView = nil;
    _strCollectionView1 = [[Utility sharedManager] getProductViewString];
    _strCollectionView2 = [[Utility sharedManager] getCategoryViewString];
    _strCollectionView3 = [[Utility sharedManager] getHorizontalViewString];
    _strCollectionMixNMatch = [[Utility sharedManager] getMixNMatchViewString];
    _strCollectionBundle = [[Utility sharedManager] getBundleViewString];
    
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
#if ENABLE_SELLER_LOC_PRODUCT_PAGE
    if (SHOP_SETTINGS && SHOP_SETTINGS.show_location) {
#pragma MapView CLlocation.....
        
        _mapView = [[GMSMapView alloc] init];
        
        //  locationManager = [[CLLocationManager alloc] init];
        //  locationManager.delegate = self;
        //  locationManager.distanceFilter = kCLDistanceFilterNone;
        //  locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        //  [locationManager startUpdatingLocation];
        
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate=self;
        locationManager.desiredAccuracy=kCLLocationAccuracyBest;
        locationManager.distanceFilter=kCLDistanceFilterNone;
        [locationManager requestWhenInUseAuthorization];
        [locationManager startMonitoringSignificantLocationChanges];
        [locationManager startUpdatingLocation];
        
        _mapView.delegate = self;
        // _mapView.settings.compassButton = YES;
        // _mapView.settings.myLocationButton = YES;
    }
#endif
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleUpdatedData:)
                                                 name:@"PushDataController"
                                               object:nil];
}
- (void) receiveTestNotification:(NSNotification *) notification
{
    [self loadDataInView];
    //[self dismissViewControllerAnimated:YES completion:nil];
    [[Utility sharedManager] popScreen:self];
    //    ViewControllerMain* mainVC = [ViewControllerMain getInstance];
    //    [mainVC resetPreviousState];
}
-(void)handleUpdatedData:(NSNotification *)notification {
    NSLog(@"recieved");
    [self loadDataInView];
}
#if ENABLE_SELLER_LOC_PRODUCT_PAGE
- (void)handleMapTap:(id)sender {
    if (SHOP_SETTINGS && SHOP_SETTINGS.show_location) {
        //NSLog(@"handleMapTap: %@", sender);
        //CLLocation* currentLocation = [locationManager location];
        //loc = [NSString stringWithFormat:@"%f,%f",currentLocation.coordinate.latitude, currentLocation.coordinate.longitude];
        //NSLog(@"location:%@", loc);
        
        
        //        ProductInfo* pInfo = self.currentItem.pInfo;
        //        SellerInfo* sInfo = pInfo.sellerInfo;
        //        NSString* addr = nil;
        //        //addr = [NSString stringWithFormat:@"http://maps.google.com/maps?daddr=%1.6f,%1.6f&saddr=Posizione attuale", sInfo.shopLatitude, sInfo.shopLongitude];
        //        addr = [NSString stringWithFormat:@"http://maps.apple.com/maps?q=%F,%F", sInfo.shopLatitude, sInfo.shopLongitude];
        //        NSURL* url = [[NSURL alloc] initWithString:[addr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        //        [[UIApplication sharedApplication] openURL:url];
        
        // &dirflg=d&t=h
        //  http://maps.apple.com/maps?q=22.7442096,75.8940591&dirflg=d&t=h
        
        // http://maps.apple.com/?saddr=%f,%f&daddr=%f,%f
        
        ProductInfo* pInfo = self.currentItem.pInfo;
        SellerInfo* sInfo = pInfo.sellerInfo;
        
        CLLocation* currentLocation = [locationManager location];
        NSString *queryString = [NSString stringWithFormat:@"http://maps.apple.com/?saddr=%f,%f&daddr=%f,%f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude, sInfo.shopLatitude, sInfo.shopLongitude];
        NSLog(@"my string %@",queryString);
        NSURL *url = [NSURL URLWithString:queryString];
        [[UIApplication sharedApplication] openURL:url];
        
    }
}
#endif
//- (void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
//    [[Utility sharedManager] startGrayLoadingBar:true];
//    [self reloadVariations];
//    [self afterRotation:0.5f];
//}

- (void)viewWillAppear:(BOOL)animated{
    //rv//[SDWebImageManager.sharedManager.imageDownloader setValue:@"SDWebImage Demo" forHTTPHeaderField:@"AppName"];
    //    SDWebImageManager.sharedManager.imageDownloader.executionOrder = SDWebImageDownloaderFIFOExecutionOrder;
    
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveTestNotification:)
                                                 name:@"TestNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyChangeInAttribute:) name:@"notifyChangeInAttribute" object:nil];
    [[[[DataManager sharedManager] tmDataDoctor] tmMulticastDelegate] addDelegate:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    //    _mapView = [[GMSMapView alloc] init];
    //    _pin = [[UIImageView alloc]initWithFrame:CGRectMake(0,0, 30, 30)];
    //    _pin.center = self.mapView.center;
    //    _pin.image = [UIImage imageNamed:@"marker.png"];
    //    [_mapView addSubview:_pin];
    //    [_mapView bringSubviewToFront:_pin ];
    
}
- (void)viewWillDisappear:(BOOL)animated {
    [self removeME];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}
- (void)removeME {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"notifyChangeInAttribute" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FETCH_OPINION" object:nil];
    [[[[DataManager sharedManager] tmDataDoctor] tmMulticastDelegate] removeDelegate:self];
    NSArray* subviews = [self.view subviews];
    for (UIView* v in subviews) {
        NSArray* subviews1 = [self.view subviews];
        for (UIView* v1 in subviews1) {
            [v1 removeFromSuperview];
        }
        [v removeFromSuperview];
    }
}

- (void)flushCache {
    [SDWebImageManager.sharedManager.imageCache clearMemory];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)barButtonBackPressed:(id)sender {
    
    //    [self dismissViewControllerAnimated:YES completion:nil];
    if (self.parentVC) {
        if ([self.parentVC isKindOfClass:[ViewControllerCategories class]]) {
            [self.parentVC backFromProductScreen:self.parentCell];
        }
        else if ([self.parentVC isKindOfClass:[ViewControllerHome class]]) {
            [self.parentVC backFromProductScreen:self.parentCell];
        }
        //        else if ([self.parentVC isKindOfClass:[ViewControllerHomeDynamic class]]) {
        //            [self.parentVC backFromProductScreen:self.parentCell];
        //        }
        else if ([self.parentVC isKindOfClass:[ViewControllerSearch class]]) {
            [self.parentVC backFromProductScreen:self.parentCell];
        }
        else if ([self.parentVC isKindOfClass:[ViewControllerMyCouponProduct class]]) {
            [[Utility sharedManager] popScreen:self];
            return;
        }
        else if ([self.parentVC isKindOfClass:[ViewControllerNotification class]]) {
            [[Utility sharedManager] popScreen:self];
            return;
        }
        else if ([self.parentVC isKindOfClass:[VCProducts class]]) {
            [[Utility sharedManager] popScreen:self];
            return;
        }
        
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FETCH_OPINION" object:nil];
    [[Utility sharedManager] popScreen:self];
    if (_drillingLevel == 0) {
        ViewControllerMain* mainVC = [ViewControllerMain getInstance];
        [mainVC resetPreviousState];
    }
}
- (void)updateOpinionPoll:(NSNotification*)nofitication {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FETCH_OPINION" object:nil];
    [self updateOpinionView];
}
- (void)loadData:(DataPass *)currentItem previousItem:(DataPass *)previousItem drillingLevel:(int)drillingLevel variationId:(int)variationId {
    [_scrollView setBackgroundColor:[Utility getUIColor:kUIColorBgTheme]];
    
    _currentItem = currentItem;
    [self loadPRDD_Data];
    //    [self loadSellerData];
    _previousItem = previousItem;
    _drillingLevel = drillingLevel;
    
    CategoryInfo * itemCategoryPrevious = nil;
    CategoryInfo * itemCategoryCurrent = nil;
    ProductInfo * itemProductPrevious = nil;
    ProductInfo * itemProductCurrent = nil;
    NSString *str = nil;
    
    if (previousItem.isCategory) {
        itemCategoryPrevious = [CategoryInfo getWithId:previousItem.itemId];
    }
    if (previousItem.isProduct) {
        itemProductPrevious = [ProductInfo getProductWithId:previousItem.itemId];
    }
    if (currentItem.isCategory) {
        itemCategoryCurrent = [CategoryInfo getWithId:currentItem.itemId];
    }
    if (currentItem.isProduct) {
        itemProductCurrent = [ProductInfo getProductWithId:currentItem.itemId];
    }
    str = [NSString stringWithFormat:@"  %@  ", Localize(@"i_back")];
    [customBackButton setTitle:str forState:UIControlStateNormal];
    [customBackButton sizeToFit];
    
    if (currentItem.isCategory) {
        str = [NSString stringWithFormat:@"%@", itemCategoryCurrent._nameForOuterView];
    }
    if (currentItem.isProduct) {
        str = [NSString stringWithFormat:@"%@", itemProductCurrent._titleForOuterView];
    }
    
    CGRect customBtnRect = customBackButton.frame;
    CGRect headingBtnRect = _labelViewHeading.frame;
    customBtnRect.size.height = headingBtnRect.size.height;
    customBackButton.frame = customBtnRect;
    float bckBtnMaxX = CGRectGetMaxX(customBtnRect) + 20;
    headingBtnRect.size.width = self.view.frame.size.width - bckBtnMaxX * 2;
    headingBtnRect.origin.x = bckBtnMaxX;
    _labelViewHeading.frame = headingBtnRect;
    [_labelViewHeading setText:str];
    
    if (_currentItem.pInfo._type == PRODUCT_TYPE_EXTERNAL_OR_AFFILIATE) {
        self.show_external_product_layout = true;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateOpinionPoll:) name:@"FETCH_OPINION" object:nil];
    [[ParseHelper sharedManager] fetchOpinionPoll:_currentItem.pInfo];
    if (_currentItem.pInfo._isFullRetrieved == false) {
        [[DataManager sharedManager] fetchSingleProductData:nil productId:_currentItem.itemId];
    }
    else if ([[Addons sharedManager] load_extra_attrib_data] && _currentItem.pInfo._isExtraPriceRetrieved == false) {
        _currentItem.pInfo._isFullRetrieved = false;
        [[[DataManager sharedManager] tmDataDoctor] loadExtraAttribData:_currentItem.pInfo success:^(id data) {
            _currentItem.pInfo._isFullRetrieved = true;
            //here data is already parsed and added in product object before this success callback.
            [[Utility sharedManager] startGrayLoadingBar:true];
            [self reloadVariations];
            [self afterRotation:0.5f];
            [[DataManager sharedManager] fetchSingleProductDataReviews:nil productId:_currentItem.itemId];
        } failure:^(NSString *error) {
            
        }];
    }
    else {
        if (_currentItem.pInfo._isReviewsRetrieved == false) {
            [[DataManager sharedManager] fetchSingleProductDataReviews:nil productId:_currentItem.itemId];
        }
        
    }
    
    [self initVariables];
    
    if (_currentItem.pInfo._isSmallRetrived == true) {
        CGRect customBtnRect = customBackButton.frame;
        CGRect headingBtnRect = _labelViewHeading.frame;
        customBtnRect.size.height = headingBtnRect.size.height;
        customBackButton.frame = customBtnRect;
        float bckBtnMaxX = CGRectGetMaxX(customBtnRect) + 20;
        headingBtnRect.size.width = self.view.frame.size.width - bckBtnMaxX * 2;
        headingBtnRect.origin.x = bckBtnMaxX;
        _labelViewHeading.frame = headingBtnRect;
        [_labelViewHeading setText:str];
        [self loadDataInView];
    } else {
        [_labelViewHeading setText:@""];
    }
    
    
#if ENABLE_PARSE_ANALYTICS
    [[ParseHelper sharedManager] registerParseVisitProduct:currentItem.itemId increment:1];
#endif
    [[AppDelegate getInstance] logProductViewEvent:currentItem.pInfo];
#if ENABLE_FIREBASE_TAG_MANAGER
    [[AnalyticsHelper sharedInstance] registerVisitProductEvent:currentItem.pInfo];
#endif
}
- (void)loadData:(DataPass *)currentItem previousItem:(DataPass *)previousItem drillingLevel:(int)drillingLevel{
    
    [self loadData:currentItem previousItem:previousItem drillingLevel:drillingLevel variationId:-1];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
#pragma mark - Methods
- (void)initVariables {
    //    [_scrollView setBackgroundColor:[Utility getUIColor:kUIColorBgTheme]];
    //    [self.view setBackgroundColor:[Utility getUIColor:kUIColorBgHeader]];
    //    [_lineView setBackgroundColor:[Utility getUIColor:kUIColorBorder]];
    self.matchedItems = nil;
    self.bundleItems = nil;
    _isRelatedProductLoaded = false;
    _zipSettingView = nil;
    _viewsAdded = [[NSMutableArray alloc] init];
    _propBanner = [[LayoutProperties alloc] initWithBannerValues];
    _propBannerProduct = [[LayoutProperties alloc] initWithProductBannerValues];
    for (int i = 0; i < _kTotalViewsProductScreen; i++) {
        _viewUserDefined[i] = nil;
        _propCollectionView[i] = [[LayoutProperties alloc] initWithCollectionViewValues:SCROLL_TYPE_SHOWFULL];
        _viewUserDefinedHeaderString[i] = @"";
        _viewUserDefinedHeader[i] = nil;
        _isViewUserDefinedEnable[i] = false;
    }
    if (PRODUCT_DETAILS_CONFIG.show_related_section == true) {
        _isViewUserDefinedEnable[_kRelatedProduct] = true;
        _viewUserDefinedHeaderString[_kRelatedProduct] = Localize(@"header_related_products");
        _viewKey[_kRelatedProduct] = @"related_products";
    }
    
    Addons* addons = [Addons sharedManager];
    if (PRODUCT_DETAILS_CONFIG.show_upsell_section == true) {
        _isViewUserDefinedEnable[_kUpSell] = true;
        _viewUserDefinedHeaderString[_kUpSell] = Localize(@"header_upsells_products");
        _viewKey[_kUpSell] = @"You_may_also_like";
    }
    
    if (addons.enable_mixmatch_products) {
        _isViewUserDefinedEnable[_kMIXNMATCH] = true;
        _viewUserDefinedHeaderString[_kMIXNMATCH] = Localize(@"_kMIXNMATCH");
        _viewKey[_kMIXNMATCH] = @"_kMIXNMATCH";
    }
    if (addons.enable_bundled_products) {
        _isViewUserDefinedEnable[_kBUNDLE] = true;
        _viewUserDefinedHeaderString[_kBUNDLE] = Localize(@"_kBUNDLE");
        _viewKey[_kBUNDLE] = @"_kBUNDLE";
    }
    
    _selectedVariationAttibutes = [[NSMutableArray alloc] init];
    [self reloadVariations];
}
- (void)reloadVariations{
    _selectedVariation = nil;
    [_selectedVariationAttibutes removeAllObjects];
    
    if (_currentItem.variationId != -1) {
        _selectedVariation = [_currentItem.pInfo._variations getVariation:_currentItem.variationId variationIndex:_currentItem.variationIndex];
        for (Attribute* attribute in _currentItem.pInfo._attributes) {
            [_selectedVariationAttibutes addObject:[attribute getVariationAttribute:0]];
        }
        if(_currentItem.cart && _currentItem.cart.selected_attributes) {
            for (VariationAttribute* vAttr in _selectedVariationAttibutes) {
                //                if ([vAttr.value isEqualToString:@""])
                //                {
                for (VariationAttribute* vAttr1 in _currentItem.cart.selected_attributes) {
                    
                    
                    if ([Utility compareAttributeNames:vAttr.slug name2:vAttr1.slug]) {
                        vAttr.value = [NSString stringWithFormat:@"%@", vAttr1.value];
                        break;
                    }
                }
                //                }
            }
        }
        
        
        //        for (VariationAttribute* attribute in _selectedVariation._attributes) {
        //
        //            NSString* variationName = [[NSString stringWithFormat:@"%@", attribute.name] capitalizedString];
        //            for (VariationAttribute* varAttribute in _selectedVariationAttibutes) {
        //                NSString* varAttributeName = [[NSString stringWithFormat:@"%@", varAttribute.name] capitalizedString];
        //                if ([variationName isEqualToString:varAttributeName]) {
        //                    varAttribute.value = [NSString stringWithFormat:@"%@",attribute.value];
        //                }
        //            }
        
        
        //            NSString* variationName = [[NSString stringWithFormat:@"%@", attribute.name] capitalizedString];
        //            for (VariationAttribute* varAttribute in _selectedVariationAttibutes) {
        //                NSString* varAttributeName = [[NSString stringWithFormat:@"%@", varAttribute.name] capitalizedString];
        //                if ([Utility compareAttributeNames:variationName name2:varAttributeName]) {
        //                    varAttribute.value = [NSString stringWithFormat:@"%@",varAttribute.value];
        //                }
        //            }
        //        }
    } else {
        for (Attribute* attribute in _currentItem.pInfo._attributes) {
            [_selectedVariationAttibutes addObject:[attribute getVariationAttribute:0]];
        }
        _selectedVariation = [_currentItem.pInfo._variations getVariationFromAttibutes:_selectedVariationAttibutes];
        //        if(![[Addons sharedManager] show_min_max_price]) {
        //            _selectedVariation = [_currentItem.pInfo._variations getVariationFromAttibutes:_selectedVariationAttibutes];
        //        }
    }
    
    
    
    if(_selectedVariation != NULL) {
        RLOG(@"-- found selected variation with following details --");
        RLOG(@"-- id:%d--", _selectedVariation._id);
        RLOG(@"-- sku:%@--", _selectedVariation._sku);
        RLOG(@"-- stock_quantity:%d--", _selectedVariation._stock_quantity);
        RLOG(@"-- price:%f--", _selectedVariation._price);
        RLOG(@"------------------------------------------------------");
    } else {
        RLOG(@"-- No such varition found with given attribut set --");
        for(VariationAttribute *attribute in _selectedVariationAttibutes) {
            RLOG(@"-- attribute:\n[attribute.name=%@:attribute.value=%@]", attribute.name, attribute.value);
        }
        RLOG(@"------------------------------------------------------");
    }
    
    
    
    if (PRODUCT_DETAILS_CONFIG.select_variation_with_button) {
        
        
    }
    
}
- (void)loadDataInView {
    [_scrollView setDelegate:self];
    [[Utility sharedManager] startGrayLoadingBar:false];
    [_scrollView setAlpha:0];
    //    for (int i = 0; i < _kTotalViewsProductScreen; i++) {
    //        [_propCollectionView[i] setCollectionViewProperties:_propCollectionView[i] scrollType:SCROLL_TYPE_SHOWFULL];
    //    }
    for (UIView* view in _viewsAdded) {
        [view removeFromSuperview];
    }
    [_viewsAdded removeAllObjects];
    _productReviewView = nil;
    _zipSettingView = nil;
    
    for (int i = 0; i < _kTotalViewsProductScreen; i++) {
        _viewUserDefined[i] = nil;
        _propCollectionView[i] = [[LayoutProperties alloc] initWithCollectionViewValues:SCROLL_TYPE_SHOWFULL];
        _viewUserDefinedHeaderString[i] = @"";
        _viewUserDefinedHeader[i] = nil;
        _isViewUserDefinedEnable[i] = false;
    }
    //#if SHOW_RELATED_PRODUCEDS
    if (PRODUCT_DETAILS_CONFIG.show_related_section == true) {
        _isViewUserDefinedEnable[_kRelatedProduct] = true;
        _viewUserDefinedHeaderString[_kRelatedProduct] = Localize(@"header_related_products");
        _viewKey[_kRelatedProduct] = @"related_products";
    }
    //#endif
    Addons* addons = [Addons sharedManager];
    if (PRODUCT_DETAILS_CONFIG.show_upsell_section == true) {
        _isViewUserDefinedEnable[_kUpSell] = true;
        _viewUserDefinedHeaderString[_kUpSell] = Localize(@"header_upsells_products");
        _viewKey[_kUpSell] = @"You_may_also_like";
    }
    if (addons.enable_mixmatch_products) {
        _isViewUserDefinedEnable[_kMIXNMATCH] = true;
        _viewUserDefinedHeaderString[_kMIXNMATCH] = Localize(@"_kMIXNMATCH");
        _viewKey[_kMIXNMATCH] = @"_kMIXNMATCH";
    }
    if (addons.enable_bundled_products) {
        _isViewUserDefinedEnable[_kBUNDLE] = true;
        _viewUserDefinedHeaderString[_kBUNDLE] = Localize(@"_kBUNDLE");
        _viewKey[_kBUNDLE] = @"_kBUNDLE";
    }
    
#if ENABLE_SELLER_ZONE
    if([[Addons sharedManager] multiVendor] && [[[Addons sharedManager] multiVendor] isEnabled] && [[Addons sharedManager] multiVendor_screen_type] == MULTIVENDOR_SCREEN_PRODUCT && self.currentItem.pInfo.sellerInfo != nil) {
        UIView * view = [self createSellerInfoView];
        [Utility showShadow:view];
    }
#endif
    
    [self createBannerView];
    if(_currentItem.pInfo._isFullRetrieved == false) {
        [self createLoadingView];
    } else {
        if (_productLoadingView) {
            [_productLoadingView removeFromSuperview];
            _productLoadingView = nil;
        }
    }
    if ([addons enable_mixmatch_products]) {
        [self createMixAndMatchView];
    }
    if ([addons enable_bundled_products]) {
        [self createBundleView];
    }
    
    [self createVariationView];
    
    
#if ENABLE_PRODUCT_DELIVERY_DATA_PLUGIN
    if ([[Addons sharedManager] productDeliveryDatePlugin] && [[[Addons sharedManager] productDeliveryDatePlugin] isEnabled]) {
        self.prdd = self.currentItem.pInfo.prdd;
        if (self.prdd.prdd_recurring_chk && [self.prdd.prdd_days count] > 0) {
            UIView * view = [self createPRDDView];
            [Utility showShadow:view];
        }
    }
#endif
    [self createCostView];
    [self createCallView];
#if ENABLE_OPINION
    if ([[MyDevice sharedManager] isIphone]) {
        if (PRODUCT_DETAILS_CONFIG.show_opinion_section) {
            [self createOpinionView];
            [self updateOpinionView];
        }
    }
#endif
# if ENABLE_WHATSAPP_SHARING
    if ([[MyDevice sharedManager] isIphone]) {
        if (PRODUCT_DETAILS_CONFIG.show_full_share_section) {
            [self createWhatsappSharingView];
        }
    }
#endif
    [self createWaitListView];
    [self loadRewardPoints];
    
    if (PRODUCT_DETAILS_CONFIG.show_brand_names) {
        [self loadBrandNames];
    }
    if (PRODUCT_DETAILS_CONFIG.show_price_labels) {
        [self loadPriceLabels];
    }
    if (PRODUCT_DETAILS_CONFIG.show_quantity_rules){
        [self loadQuantityRules];
    }
    
    [self createPincodeSettingsView];
    
#if ENABLE_SELLER_LOC_PRODUCT_PAGE
    if (SHOP_SETTINGS && SHOP_SETTINGS.show_location) {
        [self createMapView];
    }
#endif
    if (PRODUCT_DETAILS_CONFIG.show_additional_info) {
        [self createAttributesView];
    }
    
    if (PRODUCT_DETAILS_CONFIG.show_full_description) {
        [self createDetailView];
    }
    
    [self createReviewView];
    if (PRODUCT_DETAILS_CONFIG.show_related_section || PRODUCT_DETAILS_CONFIG.show_upsell_section) {
        [self createRelatedView];
    }
    if (PRODUCT_DETAILS_CONFIG.show_related_section ) {
        if ([_currentItem.pInfo._related_products count] == 0) {
            [[[DataManager sharedManager] tmDataDoctor] fetchMoreProductsDataFromPlugin:_currentItem.pInfo._related_ids success:^{
                
                for (id obj in _currentItem.pInfo._related_ids) {
                    int pid = [obj intValue];
                    ProductInfo *pInfo = [ProductInfo getProductWithId:pid];
                    [_currentItem.pInfo._related_products addObject:pInfo];
                }
                
                //                [[Utility sharedManager] stopGrayLoadingBar];
                [_viewUserDefined[_kRelatedProduct] reloadData];
                [self resetMainScrollView];
                //[_viewUserDefined[_kRelatedProduct] setHidden:false];
                return ;
            } failure:^{
            }];
        }
    }
    
    if (PRODUCT_DETAILS_CONFIG.show_upsell_section) {
        if ([_currentItem.pInfo._upsell_ids count] == 0) {
            [[[DataManager sharedManager] tmDataDoctor] fetchMoreProductsDataFromPlugin:_currentItem.pInfo._upsell_ids success:^{
                
                for (id obj in _currentItem.pInfo._upsell_ids) {
                    int pid = [obj intValue];
                    ProductInfo *pInfo = [ProductInfo getProductWithId:pid];
                    [_currentItem.pInfo._upsell_ids addObject:pInfo];
                }
                
                //                [[Utility sharedManager] stopGrayLoadingBar];
                [_viewUserDefined[_kUpSell] reloadData];
                [self resetMainScrollView];
                //[_viewUserDefined[_kRelatedProduct] setHidden:false];
                return ;
            } failure:^{
            }];
        }
    }
    
    if ([addons enable_mixmatch_products] || [addons enable_bundled_products]) {
        if (_currentItem.pInfo._isExtraDataRetrieved == false) {
            [[[DataManager sharedManager] tmDataDoctor] getProductInfoFastInBackground:_currentItem.pInfo success:^(id data) {
                RLOG(@"succeed");
                if ([addons enable_mixmatch_products]) {
                    int count = (int)[_currentItem.pInfo.mMixMatch.matchingItems count];
                    if (count > 0) {
                        [self collectionView:_viewUserDefined[_kMIXNMATCH] layout:_viewUserDefined[_kMIXNMATCH].collectionViewLayout sizeForItemAtIndexPath:nil];
                        [_viewUserDefined[_kMIXNMATCH] reloadData];
                        [self resetMainScrollView];
                        _viewUserDefined[_kMIXNMATCH].hidden = false;
                        _viewUserDefinedHeader[_kMIXNMATCH].hidden = false;
                        int leastSelected = (int) _currentItem.pInfo.mMixMatch.container_size;
                        if (leastSelected == 0) {
                            leastSelected = 1;
                        }
                        [_viewUserDefinedHeader[_kMIXNMATCH] setText:[NSString stringWithFormat:@"Please select %d items to continue", leastSelected]];
                        
                        [_viewUserDefinedHeader[_kMIXNMATCH] sizeToFitUI];
                        
                        if (self.matchedItems == nil) {
                            if (_currentItem.pInfo.mMixMatch) {
                                self.matchedItems = [[NSMutableArray alloc] init];
                                for (ProductInfo* pObj in _currentItem.pInfo.mMixMatch.matchingItems) {
                                    CartMatchedItem* cmItem = [[CartMatchedItem alloc] init];
                                    cmItem.product = pObj;
                                    cmItem.productId = pObj._id;
                                    cmItem.price = pObj._price;
                                    cmItem.title = pObj._title;
                                    cmItem.quantity = 0;
                                    if(pObj._images && [pObj._images count] > 0) {
                                        cmItem.imgUrl = ((ProductImage*)[pObj._images objectAtIndex:0])._src;
                                    }
                                    [self.matchedItems addObject:cmItem];
                                }
                            }
                        }
                    }
                    else {
                        [self removeUserDefinedView:_kMIXNMATCH];
                    }
                }
                if ([addons enable_bundled_products]) {
                    int count = (int)[_currentItem.pInfo.mBundles count];
                    if (count > 0) {
                        [self collectionView:_viewUserDefined[_kBUNDLE] layout:_viewUserDefined[_kBUNDLE].collectionViewLayout sizeForItemAtIndexPath:nil];
                        [_viewUserDefined[_kBUNDLE] reloadData];
                        [self updateButtons];
                        [self resetMainScrollView];
                        _viewUserDefined[_kBUNDLE].hidden = false;
                        _viewUserDefinedHeader[_kBUNDLE].hidden = false;
                        if (self.bundleItems == nil) {
                            if (_currentItem.pInfo.mBundles) {
                                self.bundleItems = [[NSMutableArray alloc] init];
                                for (TM_Bundle* bundle in _currentItem.pInfo.mBundles) {
                                    CartBundleItem *cartBundle = [[CartBundleItem alloc] init];
                                    ProductInfo *bundleProduct = ((ProductInfo*)(bundle.product));
                                    cartBundle.productId = bundleProduct._id;
                                    cartBundle.title = bundleProduct._title;
                                    cartBundle.price = 0;
                                    for (ProductImage* pimg in bundleProduct._images) {
                                        cartBundle.imgUrl = pimg._src;
                                        break;
                                    }
                                    cartBundle.quantity = bundle.bundle_quantity;
                                    cartBundle.product = bundleProduct;
                                    [self.bundleItems addObject:cartBundle];
                                }
                            }
                        }
                    }
                    else {
                        [self removeUserDefinedView:_kBUNDLE];
                    }
                }
                
            } failure:^{
                RLOG(@"failure");
                [self removeUserDefinedView:_kMIXNMATCH];
                [self removeUserDefinedView:_kBUNDLE];
            }];
        }
    }
    // [self updateHeader];
    [self updateBannerView];
    [self updatePrice];
    [self updateRewardPoints];
    [self updateButtons];
    for (SelectionView* sv in _selectionViews) {
        int clickedItemId = 0;
        if (_currentItem.variationId != -1) {
            Attribute* attribute = sv.attribute;
            NSString* attributeName = [NSString stringWithFormat:@"%@", attribute._name];
            NSString* attributeSlug = [NSString stringWithFormat:@"%@", attribute._slug];
            for (VariationAttribute* varAttribute in _selectedVariation._attributes) {
                NSString* varAttributeName = [NSString stringWithFormat:@"%@", varAttribute.name];
                NSString* varAttributeSlug = [NSString stringWithFormat:@"%@", varAttribute.slug];
                if ([Utility compareAttributeNames:attributeSlug name2:varAttributeSlug]) {
                    for (NSString* option in attribute._options) {
                        NSString* attributeOptionValue = [NSString stringWithFormat:@"%@", option];
                        NSString* varAttributeValue = [NSString stringWithFormat:@"%@", varAttribute.value];
                        
                        
                        if ([varAttributeValue isEqualToString:@""]) {
                            for (VariationAttribute* vAttr in _selectedVariationAttibutes) {
                                NSString* varAttributeNameSelected = [NSString stringWithFormat:@"%@", vAttr.name];
                                NSString* varAttributeSlugSelected = [NSString stringWithFormat:@"%@", vAttr.slug];
                                if ([Utility compareAttributeNames:varAttributeSlugSelected name2:varAttributeSlug]) {
                                    varAttributeValue = [NSString stringWithFormat:@"%@", vAttr.value];
                                }
                            }
                        }
                        
                        if ([Utility compareAttributeNames:attributeOptionValue name2:varAttributeValue]) {
                            sv.attributeSelectedValue = option;
                            break;
                        }
                        clickedItemId++;
                    }
                    break;
                }
            }
            [sv selectClicked:sv.button];
            [sv.dropdownView selectItemManually:clickedItemId textStr:sv.attributeSelectedValue];
        }
    }
    [self resetMainScrollView];
    [_scrollView setAlpha:1];
    [[Utility sharedManager] stopGrayLoadingBar];
    
    
    if (PRODUCT_DETAILS_CONFIG.tap_to_exit) {
        if (_tapToExit && [self isVariationKindProduct]) {
            _tapToExit.numberOfTapsRequired = 2;
        }
    }
    
}

#pragma mark - Banner View
- (void)updateHeader {
    NSString *str = @"";
    ProductInfo* itemProductCurrent = [ProductInfo getProductWithId:_currentItem.itemId];
    if (_currentItem.isProduct) {
        str = [NSString stringWithFormat:@"%@", itemProductCurrent._titleForOuterView];
    }
    if ([[MyDevice sharedManager] isIpad]) {
        if (str.length > MAX_STR_LENGTH_CURRENT_ITEM_IPAD) {
            str = [str substringToIndex:MAX_STR_LENGTH_CURRENT_ITEM_IPAD];
            str = [str stringByAppendingString:@"..."];
        }
    } else {
        if (str.length > MAX_STR_LENGTH_CURRENT_ITEM_IPHONE) {
            str = [str substringToIndex:MAX_STR_LENGTH_CURRENT_ITEM_IPHONE];
            str = [str stringByAppendingString:@".."];
        }
    }
    
    [_labelViewHeading setText:str];
}
- (void)updateBannerView {
    RLOG(@"=====BANNER_VIEW=====updateBannerView_START");
    if (_bannerScrollView) {
        if ((int)[_selectedVariation._images count] > 0) {
            NSMutableArray *imageArray = [[NSMutableArray alloc] init];
            NSObject* object = nil;
            for (object in _selectedVariation._images) {
                ProductImage *pImage = (ProductImage *)object;
                UIImageView * uiImageView = [[UIImageView alloc]init];
                [Utility setImage:uiImageView url:pImage._src resizeType:kRESIZE_TYPE_PRODUCT_BANNER isLocal:false];
                [imageArray addObject:uiImageView];
                
                
                RLOG(@"=====BANNER_VIEW=====%@", pImage._src);
            }
            if ([imageArray count] > 0) {
                [_bannerScrollView setScrollViewContentsWithImageViews:imageArray contentMode:UIViewContentModeScaleAspectFit];
            }
        }
    }
    RLOG(@"=====BANNER_VIEW=====updateBannerView_END");
    
}
- (void)updatePrice {
    if(_selectedVariation){
        /////////////////
        BOOL isDiscounted = [_currentItem.pInfo isProductDiscounted:_selectedVariation._id];
        float newPrice = [_currentItem.pInfo getNewPrice:_selectedVariation._id] + [ProductInfo getExtraPrice:_selectedVariationAttibutes pInfo:_currentItem.pInfo];
        float oldPrice = [_currentItem.pInfo getOldPrice:_selectedVariation._id];
        
        if (isDiscounted) {
            [_labelOldPrice setAttributedText:[[Utility sharedManager] convertToStringStrikethrough:oldPrice isCurrency:true]];
        }else {
            [_labelOldPrice setText:@""];
        }
        
        if(![[Addons sharedManager] show_min_max_price]) {
            [_labelNewPrice setText:[[Utility sharedManager] convertToString:newPrice isCurrency:true]];
            [self setProductLabelInView];
        }
        else{
            if (_selectedVariation._id == -1) {
                [_labelNewPrice setText:[_currentItem.pInfo getPriceNewString]];
                [self setProductLabelInView];
            } else {
                [_labelNewPrice setText:[[Utility sharedManager] convertToString:newPrice isCurrency:true]];
                [self setProductLabelInView];
            }
        }
        [self costShift];
        /////////////////
    }
    else {
        if([[Addons sharedManager] show_min_max_price]) {
            
        } else {
            [_labelNewPrice setText:[_currentItem.pInfo getPriceNewString]];
            [self setProductLabelInView];
            [self costShift];
        }
    }
    if ([[Addons sharedManager] enable_mixmatch_products]) {
        if (_currentItem.pInfo.mMixMatch) {
            float price = 0.0f;
            for (CartMatchedItem* cmItems in self.matchedItems) {
                price +=  (cmItems.quantity * cmItems.price);
            }
            [_labelNewPrice setText:[[Utility sharedManager] convertToString:price isCurrency:true]];
            [self setProductLabelInView];
            [self costShift];
        }
    }
    
    
    if (([[GuestConfig sharedInstance] hide_price] && ![AppUser isSignedIn]) || [[Addons sharedManager] hide_price]) {
        _labelNewPrice.text = @"";
        _labelOldPrice.text = @"";
        CGRect lRect = _labelNewPrice.frame;
        lRect.size.height = 0;
        _labelNewPrice.frame = lRect;
        _labelOldPrice.frame = lRect;
    } else {
        
    }
    if (PRODUCT_DETAILS_CONFIG.show_price == false && ![self isVariationKindProduct]) {
        CGRect lRect = _labelNewPrice.frame;
        lRect.size.height = 0;
        _labelNewPrice.frame = lRect;
        _labelOldPrice.frame = lRect;
    }
    if ((PRODUCT_DETAILS_CONFIG.show_price == false && ![self isVariationKindProduct]) &&
        PRODUCT_DETAILS_CONFIG.show_product_title == false &&
        PRODUCT_DETAILS_CONFIG.show_short_desc == false &&
        PRODUCT_DETAILS_CONFIG.show_image_slider == false) {
        CGRect lRect = _productImageAndCostView.frame;
        lRect.size.height = 0;
        _productImageAndCostView.frame = lRect;
        [_productImageAndCostView setTag:kTagForNoSpacing];
        [_productImageAndCostView removeFromSuperview];
    }
}

- (void)updateRewardPoints {
    [_labelRewardPoints sizeToFitUI];
    _productCostView.frame = CGRectMake(_productCostView.frame.origin.x, _productCostView.frame.origin.y, _productCostView.frame.size.width, MAX(CGRectGetMaxY(_labelNewPrice.frame), CGRectGetMaxY(_labelRewardPoints.frame)) + self.view.frame.size.width * .01f);
    _productImageAndCostView.frame = CGRectMake(self.view.frame.size.width * .01f, _productImageView.frame.origin.y, self.view.frame.size.width * .98f, _productImageView.frame.size.height + _productCostView.frame.size.height);
    [_productImageAndCostView addSubview:_productImageView];
    [_productImageAndCostView addSubview:_productCostView];
    _productImageAndCostView.layer.shadowOpacity = 0.0f;
    [Utility showShadow:_productImageAndCostView];
    [self resetMainScrollView];
    
}
- (void)updateButtons {
    if ([[[Addons sharedManager] productDetailsConfig] show_quick_cart_section]) {
        [self updateButtonsGrocery];
        return;
    }
    if (self.show_vertical_layout_components) {
        [self updateButtonsThreeLiner];
        return;
    }
    if (self.show_external_product_layout) {
        [self updateButtonsExtProduct];
        return;
    }
    
    int variationId = -1;
    if(_selectedVariation) {
        variationId = _selectedVariation._id;
    }
    
    if ([Wishlist hasItem:_currentItem.pInfo variationId:variationId]) {
        [_buttonWishlist setSelected:true];
        [_buttonWishlist setTintColor:[Utility getUIColor:kUIColorWishlistSelected]];
    } else {
        [_buttonWishlist setSelected:false];
        [_buttonWishlist setTintColor:[Utility getUIColor:kUIColorThemeButtonNormal]];
    }
    int availState = [Cart getProductAvailibleState:_currentItem.pInfo variationId:variationId];
    if (_selectedVariation == nil && _currentItem.pInfo && _currentItem.pInfo._variations && [_currentItem.pInfo._variations count] > 0) {
        BOOL noSuchVariationFound = true;
        for (VariationAttribute* vAttr in _selectedVariationAttibutes) {
            if([vAttr.value isEqualToString:Localize(@"i_select")]) {
                noSuchVariationFound = false;
                break;
            }
        }
        if (noSuchVariationFound) {
            availState = PRODUCT_QTY_ZERO;
        }
    }
    switch (availState) {
        case PRODUCT_QTY_DEMAND:
            [_buttonBuy setEnabled:true];
            [_buttonBuy setTitle:Localize(@"buy") forState:UIControlStateNormal];
            [_buttonBuy setTitleColor:[Utility getUIColor:kUIColorBuyButtonFont] forState:UIControlStateNormal];
            [_buttonBuy setBackgroundColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
            _buttonBuy.layer.borderColor = [Utility getUIColor:kUIColorBuyButtonNormalBg].CGColor;
            
            [_buttonCart setSelected:false];
            [_buttonCart setEnabled:true];
            [_buttonCart setTintColor:[Utility getUIColor:kUIColorThemeButtonNormal]];
            
            _buttonCart.layer.borderColor = [Utility getUIColor:kUIColorBuyButtonNormalBg].CGColor;
            break;
        case PRODUCT_QTY_ZERO:
            [_buttonBuy setEnabled:false];
            [_buttonBuy setTitle:Localize(@"out_of_stock") forState:UIControlStateNormal];
            [_buttonBuy setTitleColor:[Utility getUIColor:kUIColorThemeButtonNormal] forState:UIControlStateNormal];
            [_buttonBuy setBackgroundColor:[UIColor whiteColor]];
            _buttonBuy.layer.borderColor = [Utility getUIColor:kUIColorBuyButtonNormalBg].CGColor;
            
            [_buttonCart setSelected:false];
            [_buttonCart setEnabled:false];
            [_buttonCart setTintColor:[Utility getUIColor:kUIColorThemeButtonNormal]];
            _buttonCart.layer.borderColor = [Utility getUIColor:kUIColorBuyButtonNormalBg].CGColor;
            break;
        case PRODUCT_QTY_STOCK:
            [_buttonBuy setEnabled:true];
            [_buttonBuy setTitle:Localize(@"buy") forState:UIControlStateNormal];
            [_buttonBuy setTitleColor:[Utility getUIColor:kUIColorBuyButtonFont] forState:UIControlStateNormal];
            [_buttonBuy setBackgroundColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
            _buttonBuy.layer.borderColor = [Utility getUIColor:kUIColorBuyButtonNormalBg].CGColor;
            
            [_buttonCart setSelected:false];
            [_buttonCart setEnabled:true];
            [_buttonCart setTintColor:[Utility getUIColor:kUIColorThemeButtonNormal]];
            _buttonCart.layer.borderColor = [Utility getUIColor:kUIColorBuyButtonNormalBg].CGColor;
            break;
        default:
            break;
    }
}
- (void)updateButtonsExtProduct {
    int variationId = -1;
    if(_selectedVariation) {
        variationId = _selectedVariation._id;
    }
    if ([Wishlist hasItem:_currentItem.pInfo variationId:variationId]) {
        [_buttonWishlist setSelected:true];
        [_buttonWishlist setTintColor:[Utility getUIColor:kUIColorWishlistSelected]];
    } else {
        [_buttonWishlist setSelected:false];
        [_buttonWishlist setTintColor:[Utility getUIColor:kUIColorThemeButtonNormal]];
        if (self.show_vertical_layout_components) {
            [_buttonWishlist setTintColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
            [_buttonWishlist setTitleColor:[Utility getUIColor:kUIColorBuyButtonNormalBg] forState:UIControlStateNormal];
        }
        if (self.show_external_product_layout) {
            [_buttonWishlist setTintColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
            [_buttonWishlist setTitleColor:[Utility getUIColor:kUIColorBuyButtonNormalBg] forState:UIControlStateNormal];
        }
    }
    
    NSString* strVisitButtonText = Localize(@"visit_product");
    if (_currentItem.pInfo.button_text && ![_currentItem.pInfo.button_text isEqualToString:@""]) {
        strVisitButtonText = _currentItem.pInfo.button_text;
    }
    [_buttonBuy setTitle:strVisitButtonText forState:UIControlStateNormal];
}
- (void)updateButtonsThreeLiner {
    int variationId = -1;
    if(_selectedVariation) {
        variationId = _selectedVariation._id;
    }
    
    if ([Wishlist hasItem:_currentItem.pInfo variationId:variationId]) {
        [_buttonWishlist setSelected:true];
        [_buttonWishlist setTintColor:[Utility getUIColor:kUIColorWishlistSelected]];
        //        _buttonWishlist.layer.borderColor = [Utility getUIColor:kUIColorThemeButtonBorderSelected].CGColor;
    }else{
        [_buttonWishlist setSelected:false];
        [_buttonWishlist setTintColor:[Utility getUIColor:kUIColorThemeButtonNormal]];
        if (self.show_vertical_layout_components) {
            [_buttonWishlist setTintColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
            [_buttonWishlist setTitleColor:[Utility getUIColor:kUIColorBuyButtonNormalBg] forState:UIControlStateNormal];
        }
        if (self.show_external_product_layout) {
            [_buttonWishlist setTintColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
            [_buttonWishlist setTitleColor:[Utility getUIColor:kUIColorBuyButtonNormalBg] forState:UIControlStateNormal];
        }
    }
    
    int availState = [Cart getProductAvailibleState:_currentItem.pInfo variationId:variationId];
    if (_selectedVariation == nil && _currentItem.pInfo && _currentItem.pInfo._variations && [_currentItem.pInfo._variations count] > 0) {
        BOOL noSuchVariationFound = true;
        for (VariationAttribute* vAttr in _selectedVariationAttibutes) {
            if([vAttr.value isEqualToString:Localize(@"i_select")]) {
                noSuchVariationFound = false;
                break;
            }
        }
        if (noSuchVariationFound) {
            availState = PRODUCT_QTY_ZERO;
        }
    }
    switch (availState) {
        case PRODUCT_QTY_DEMAND:
            [_buttonBuy setEnabled:true];
            [_buttonBuy setTitle:Localize(@"buy") forState:UIControlStateNormal];
            [_buttonBuy setTitleColor:[Utility getUIColor:kUIColorBuyButtonFont] forState:UIControlStateNormal];
            [_buttonBuy setBackgroundColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
            _buttonBuy.layer.borderColor = [Utility getUIColor:kUIColorBuyButtonNormalBg].CGColor;
            
            [_buttonCart setSelected:false];
            [_buttonCart setEnabled:true];
            [_buttonCart setTintColor:[Utility getUIColor:kUIColorThemeButtonNormal]];
            if (self.show_vertical_layout_components) {
                [_buttonCart setTintColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
                [_buttonCart setTitleColor:[Utility getUIColor:kUIColorBuyButtonNormalBg] forState:UIControlStateNormal];
            }
            if (self.show_external_product_layout) {
                [_buttonCart setHidden:true];
            }
            _buttonCart.layer.borderColor = [Utility getUIColor:kUIColorBuyButtonNormalBg].CGColor;
            break;
        case PRODUCT_QTY_ZERO:
            [_buttonBuy setEnabled:false];
            [_buttonBuy setTitle:Localize(@"out_of_stock") forState:UIControlStateNormal];
            [_buttonBuy setTitleColor:[Utility getUIColor:kUIColorThemeButtonNormal] forState:UIControlStateNormal];
            [_buttonBuy setBackgroundColor:[UIColor whiteColor]];
            _buttonBuy.layer.borderColor = [Utility getUIColor:kUIColorBuyButtonNormalBg].CGColor;
            
            [_buttonCart setSelected:false];
            [_buttonCart setEnabled:false];
            [_buttonCart setTintColor:[Utility getUIColor:kUIColorThemeButtonNormal]];
            if (self.show_vertical_layout_components) {
                [_buttonCart setTintColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
                [_buttonCart setTitleColor:[Utility getUIColor:kUIColorBuyButtonNormalBg] forState:UIControlStateNormal];
            }
            if (self.show_external_product_layout) {
                [_buttonCart setHidden:true];
            }
            _buttonCart.layer.borderColor = [Utility getUIColor:kUIColorBuyButtonNormalBg].CGColor;
            break;
        case PRODUCT_QTY_STOCK:
            [_buttonBuy setEnabled:true];
            [_buttonBuy setTitle:Localize(@"buy") forState:UIControlStateNormal];
            [_buttonBuy setTitleColor:[Utility getUIColor:kUIColorBuyButtonFont] forState:UIControlStateNormal];
            [_buttonBuy setBackgroundColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
            _buttonBuy.layer.borderColor = [Utility getUIColor:kUIColorBuyButtonNormalBg].CGColor;
            
            [_buttonCart setSelected:false];
            [_buttonCart setEnabled:true];
            [_buttonCart setTintColor:[Utility getUIColor:kUIColorThemeButtonNormal]];
            if (self.show_vertical_layout_components) {
                [_buttonCart setTintColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
                [_buttonCart setTitleColor:[Utility getUIColor:kUIColorBuyButtonNormalBg] forState:UIControlStateNormal];
            }
            if (self.show_external_product_layout) {
                [_buttonCart setHidden:true];
            }
            _buttonCart.layer.borderColor = [Utility getUIColor:kUIColorBuyButtonNormalBg].CGColor;
            break;
        default:
            break;
    }
}
- (void)updateButtonsGrocery {
    
    int variationId = -1;
    if(_selectedVariation) {
        variationId = _selectedVariation._id;
    }
    if ([Wishlist hasItem:_currentItem.pInfo variationId:variationId]) {
        [_buttonWishlist setSelected:true];
        [_buttonWishlist setTintColor:[Utility getUIColor:kUIColorWishlistSelected]];
    }else{
        [_buttonWishlist setSelected:false];
        [_buttonWishlist setTintColor:[Utility getUIColor:kUIColorThemeButtonNormal]];
    }
    int availState = [Cart getProductAvailibleState:_currentItem.pInfo variationId:variationId];
    if (_selectedVariation == nil && _currentItem.pInfo && _currentItem.pInfo._variations && [_currentItem.pInfo._variations count] > 0) {
        BOOL noSuchVariationFound = true;
        for (VariationAttribute* vAttr in _selectedVariationAttibutes) {
            if([vAttr.value isEqualToString:Localize(@"i_select")]) {
                noSuchVariationFound = false;
                break;
            }
        }
        if (noSuchVariationFound) {
            availState = PRODUCT_QTY_INVALID;
        }
    }
    
    
    Cart* c = [Cart hasProduct:_currentItem.pInfo variationId:_selectedVariation?_selectedVariation._id:-1 variationIndex:-1 selectedVariationAttributes:_selectedVariationAttibutes];
    
    
    switch (availState) {
        case PRODUCT_QTY_INVALID:
            _groceryButtonAdd.enabled = false;
            _groceryButtonSubstract.enabled = false;
            _groceryTextField.enabled = false;
            _groceryTextField.text = [NSString stringWithFormat:@"0"];
            [_buttonCart setTitle:Localize(@"view_cart") forState:UIControlStateNormal];
            [_buttonCart setEnabled:true];
            [_buttonCart setTitleColor:[Utility getUIColor:kUIColorBuyButtonFont] forState:UIControlStateNormal];
            [_buttonCart setBackgroundColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
            _buttonCart.layer.borderColor = [Utility getUIColor:kUIColorBuyButtonNormalBg].CGColor;
            [_buttonCart removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
            [_buttonCart addTarget:self action:@selector(viewCart:) forControlEvents:UIControlEventTouchUpInside];
            break;
        case PRODUCT_QTY_DEMAND:
        case PRODUCT_QTY_STOCK:
            _groceryButtonAdd.enabled = true;
            _groceryButtonSubstract.enabled = true;
            _groceryTextField.enabled = true;
            
            if (c) {
                _groceryTextField.text = [NSString stringWithFormat:@"%d", c.count];
                [_buttonCart setTitle:Localize(@"view_cart") forState:UIControlStateNormal];
                [_buttonCart removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
                [_buttonCart addTarget:self action:@selector(viewCart:) forControlEvents:UIControlEventTouchUpInside];
            } else {
                _groceryTextField.text = [NSString stringWithFormat:@"0"];
                [_buttonCart setTitle:Localize(@"toggle_cart_on") forState:UIControlStateNormal];
                [_buttonCart removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
                [_buttonCart addTarget:self action:@selector(groceryAddButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            }
            [_buttonCart setEnabled:true];
            [_buttonCart setTitleColor:[Utility getUIColor:kUIColorBuyButtonFont] forState:UIControlStateNormal];
            [_buttonCart setBackgroundColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
            _buttonCart.layer.borderColor = [Utility getUIColor:kUIColorBuyButtonNormalBg].CGColor;break;
        case PRODUCT_QTY_ZERO:
            _groceryButtonAdd.enabled = false;
            _groceryButtonSubstract.enabled = false;
            _groceryTextField.enabled = false;
            _groceryTextField.text = [NSString stringWithFormat:@"0"];
            
            [_buttonCart setEnabled:false];
            [_buttonCart setTitle:Localize(@"out_of_stock") forState:UIControlStateNormal];
            [_buttonCart setTitleColor:[Utility getUIColor:kUIColorThemeButtonNormal] forState:UIControlStateNormal];
            [_buttonCart setBackgroundColor:[UIColor whiteColor]];
            _buttonCart.layer.borderColor = [Utility getUIColor:kUIColorBuyButtonNormalBg].CGColor;
            break;
        default:
            break;
    }
}
- (void)updateOpinionView {
    int likeCount       = _currentItem.pInfo.pollLikeCount;
    int dislikeCount    = _currentItem.pInfo.pollDislikeCount;
    float buttonHeight = [[MyDevice sharedManager] screenWidthInPortrait] * 0.1f;
    float edgeSize = buttonHeight * .20f;
    
    
    [_buttonDislike setTitle:[NSString stringWithFormat:@"%d", dislikeCount] forState:UIControlStateNormal];
    if (1/* [[MyDevice sharedManager] isIphone] && likeCount > 99999*/) {
        
        int digitCount = (int) log10(dislikeCount) + 1;
        RLOG(@"digitCount = %d", digitCount);
        if (digitCount > 5) {
            int moreDigit = digitCount - 5;
            CGSize titleSize = LABEL_SIZE(_buttonDislike.titleLabel);
            int widthLetter = titleSize.width/digitCount;
            float diff = widthLetter * moreDigit/2;
            [_buttonDislike setImageEdgeInsets:UIEdgeInsetsMake(edgeSize, edgeSize/4, edgeSize,  - diff)];
            [_buttonDislike setTitleEdgeInsets:UIEdgeInsetsMake(edgeSize, -diff, edgeSize, edgeSize/4)];
        }
    }
    
    
    [_buttonLike setTitle:[NSString stringWithFormat:@"%d", likeCount] forState:UIControlStateNormal];
    if (1/* [[MyDevice sharedManager] isIphone] && likeCount > 99999*/) {
        int digitCount = (int) log10(likeCount) + 1;
        RLOG(@"digitCount = %d", digitCount);
        if (digitCount > 5) {
            int moreDigit = digitCount - 5;
            CGSize titleSize = LABEL_SIZE(_buttonLike.titleLabel);
            int widthLetter = titleSize.width/digitCount;
            float diff = widthLetter * moreDigit/2;
            [_buttonLike setImageEdgeInsets:UIEdgeInsetsMake(edgeSize, edgeSize/4, edgeSize,  - diff)];
            [_buttonLike setTitleEdgeInsets:UIEdgeInsetsMake(edgeSize, -diff, edgeSize, edgeSize/4)];
        }
    }
}
- (UIView*)createSellerInfoView {
    ProductInfo* pInfo = self.currentItem.pInfo;
    SellerInfo* sInfo = pInfo.sellerInfo;
    _sellerView = [[UIView alloc] init];
    _sellerView.frame = CGRectMake(self.view.frame.size.width * .01f, self.view.frame.size.width * .01f, self.view.frame.size.width * .98f, 100);
    
    BOOL sellerLocationExists = false;
    if ([sInfo getSellerFirstLocation] && ![[sInfo getSellerFirstLocation] isEqualToString:@""]) {
        sellerLocationExists = true;
    }
    BOOL sellerTitleExists = false;
    NSString* name = @"";
    if (sInfo) {
        if (sInfo.shopName && ![sInfo.shopName isEqualToString:@""]) {
            name = sInfo.shopName;
            sellerTitleExists = true;
        } else if (sInfo.sellerTitle && ![sInfo.sellerTitle isEqualToString:@""]) {
            name = sInfo.sellerTitle;
            sellerTitleExists = true;
        } else {
            name = @"";
            sellerTitleExists = false;
        }
    }
    
    UIButton* buttonSeller = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 80, 80)];
    [_sellerView addSubview:buttonSeller];
    [buttonSeller setBackgroundColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
    [buttonSeller setUserInteractionEnabled:false];
    [buttonSeller setTitleColor:[Utility getUIColor:kUIColorBuyButtonFont] forState:UIControlStateNormal];
    [buttonSeller.titleLabel setUIFont:kUIFontType32 isBold:true];
    [buttonSeller.layer setBorderWidth:3];
    [buttonSeller.layer setCornerRadius:10];
    [buttonSeller.layer setBorderColor:[Utility getUIColor:kUIColorBorder].CGColor];
    
    UIImageView * imageSeller = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 80, 80)];
    if (sInfo.sellerAvatarUrl && ![sInfo.sellerAvatarUrl isEqualToString:@""]) {
        
        buttonSeller.hidden = YES;
        imageSeller.hidden = NO;
        SDWebImageOptions dwldOption = [Utility getImageDownloadOption];
        NSURL* nsurl = [NSURL URLWithString:[sInfo.sellerAvatarUrl stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
        [_sellerView addSubview:imageSeller];
        [imageSeller sd_setImageWithURL:nsurl
                       placeholderImage:nil
                                options:dwldOption
                               progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                                   
                               } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                   if (error) {
                                       NSString* sellerInitials = [Utility getInitials:name limit:2];
                                       [buttonSeller setTitle:sellerInitials forState:UIControlStateNormal];
                                   }
                               }];
    } else {
        buttonSeller.hidden = NO;
        imageSeller.hidden = YES;
        NSString* sellerInitials = [Utility getInitials:name limit:2];
        [buttonSeller setTitle:sellerInitials forState:UIControlStateNormal];
    }
    float posX = 100;
    float posY = 10;
    float sizeW = _sellerView.frame.size.width - posX - 10;
    float sizeH = 100;
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(posX, posY, sizeW, sizeH)];
    [_sellerView addSubview:labelTitle];
    labelTitle.backgroundColor = [UIColor clearColor];
    labelTitle.textColor = [Utility getUIColor:kUIColorFontLight];
    [labelTitle setUIFont:kUIFontType24 isBold:false];
    [labelTitle setText:name];
    [labelTitle setNumberOfLines:0];
    [labelTitle setLineBreakMode:NSLineBreakByWordWrapping];
    [labelTitle sizeToFitUI];
    [labelTitle setFrame:CGRectMake(posX, posY, sizeW, labelTitle.frame.size.height)];
    if (labelTitle.frame.size.height > 0) {
        posY = CGRectGetMaxY(labelTitle.frame) + 10;
    }
    
    
    UILabel *labelLocation = [[UILabel alloc] initWithFrame:CGRectMake(posX, posY, sizeW, sizeH)];
    [_sellerView addSubview:labelLocation];
    labelLocation.backgroundColor = [UIColor clearColor];
    labelLocation.textColor = [Utility getUIColor:kUIColorFontLight];
    [labelLocation setUIFont:kUIFontType16 isBold:false];
    [labelLocation setText:[sInfo getSellerFirstLocation]];
    [labelLocation setNumberOfLines:0];
    [labelLocation setLineBreakMode:NSLineBreakByWordWrapping];
    [labelLocation sizeToFitUI];
    [labelLocation setFrame:CGRectMake(posX, posY, sizeW, labelLocation.frame.size.height)];
    if (labelLocation.frame.size.height > 0) {
        posY = CGRectGetMaxY(labelLocation.frame) + 10;
    }
    
    _sellerView.backgroundColor = [UIColor whiteColor];
    [_scrollView addSubview:_sellerView];
    [_viewsAdded addObject:_sellerView];
    [_sellerView setTag:kTagForNoSpacing];
    
    CGRect sellerViewRect = _sellerView.frame;
    sellerViewRect.size.height = MAX(sellerViewRect.size.height, posY);
    _sellerView.frame = sellerViewRect;
    
    if (sellerTitleExists && sellerLocationExists) {
        if (_sellerView.frame.size.height == 100) {
            [labelTitle setCenter:CGPointMake(labelTitle.center.x, _sellerView.frame.size.height/2 - labelTitle.frame.size.height/2)];
            [labelLocation setCenter:CGPointMake(labelLocation.center.x, _sellerView.frame.size.height/2 + labelLocation.frame.size.height/2)];
        }
    } else if (sellerTitleExists) {
        [labelTitle setCenter:CGPointMake(labelTitle.center.x, _sellerView.frame.size.height/2)];
    } else if (sellerLocationExists) {
        [labelLocation setCenter:CGPointMake(labelLocation.center.x, _sellerView.frame.size.height/2)];
    }
    
    UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, _sellerView.frame.size.width, _sellerView.frame.size.height)];
    [button setBackgroundColor:[UIColor clearColor]];
    [button addTarget:self action:@selector(eventOpenSellerInfo:) forControlEvents:UIControlEventTouchUpInside];
    [_sellerView addSubview:button];
    return _sellerView;
}
- (void)eventOpenSellerInfo:(UIButton*)button {
    NSLog(@"open seller info");
    //    VCProducts *vcProducts=[[VCProducts alloc] initWithNibName:@"VCProducts" bundle:nil];
    //    [vcProducts setData:_currentItem.pInfo.sellerInfo];
    //    [self presentViewController:vcProducts animated:YES completion:nil];
    
    
    ViewControllerMain* mainVC = [ViewControllerMain getInstance];
    mainVC.containerTop.hidden = YES;
    mainVC.containerCenter.hidden = YES;
    mainVC.containerCenterWithTop.hidden = NO;
    mainVC.vcBottomBar.buttonHome.selected = YES;
    mainVC.vcBottomBar.buttonCart.selected = NO;
    mainVC.vcBottomBar.buttonWishlist.selected = NO;
    mainVC.vcBottomBar.buttonSearch.selected = NO;
    [mainVC.vcBottomBar buttonClicked:nil];
    
    
    //    ViewControllerSellerItems *vcSellerItems=[[ViewControllerSellerItems alloc] initWithNibName:@"ViewControllerSellerItems" bundle:nil];
    //    [vcSellerItems setData:_currentItem.pInfo.sellerInfo];
    //    [vcSellerItems setProductVC:self parentVC:self.parentViewController];
    //    [self presentViewController:vcSellerItems animated:YES completion:nil];
    
    
    
    ViewControllerSellerItems* vcSellerItems = (ViewControllerSellerItems*)[[Utility sharedManager] pushScreenWithNewAnimation:mainVC.vcCenterTop type:PUSH_SCREEN_TYPE_SELLER_ITEM];
    [vcSellerItems setData:_currentItem.pInfo.sellerInfo];
    [vcSellerItems setProductVC:self parentVC:self.parentViewController];
    
    
    
}
- (void)createBannerView {
    RLOG(@"=====BANNER_VIEW=====createBannerView_START");
    
    
    _productImageAndCostView = [[UIView alloc] init];
    _productImageAndCostView.backgroundColor = [UIColor whiteColor];
    [_scrollView addSubview:_productImageAndCostView];
    [_viewsAdded addObject:_productImageAndCostView];
    [_productImageAndCostView setTag:kTagForGlobalSpacing];
    
    
    
    CGRect bannerRect = [_propBannerProduct getFrameRect];
    bannerRect.size.width = self.view.frame.size.width * 0.98f;
    bannerRect.origin.x = 0;
    bannerRect.size.height = bannerRect.size.height * PRODUCT_DETAILS_CONFIG.img_slider_height_ratio;
    _bannerScrollView = [[PagedImageScrollView alloc] initWithFrame:bannerRect];
    [_bannerScrollView setBackgroundColor:_propBannerProduct._bgColor];
    NSMutableArray *imageArray = [[NSMutableArray alloc] init];
    NSObject* object = nil;
    
    for (object in _currentItem.pInfo._images) {
        ProductImage *pImage = (ProductImage *)object;
        UIImageView * uiImageView = [[UIImageView alloc]init];
        if (![pImage._src isKindOfClass:[NSString class]]) {
            pImage._src = @"";
        }
        [Utility setImage:uiImageView url:pImage._src resizeType:kRESIZE_TYPE_PRODUCT_BANNER isLocal:false];
        [imageArray addObject:uiImageView];
        RLOG(@"=====BANNER_VIEW=====%@", pImage._src);
    }
    if ([imageArray count] > 0) {
        [_bannerScrollView setScrollViewContentsWithImageViews:imageArray contentMode:UIViewContentModeScaleAspectFit];
        
        //        [_scrollView addSubview:_bannerScrollView];
        //        [_viewsAdded addObject:_bannerScrollView];
        //        [_bannerScrollView setTag:kTagForNoSpacing];
        
        if (PRODUCT_DETAILS_CONFIG.show_image_slider) {
            [_bannerScrollView reloadView:bannerRect];
        }else {
            CGRect bRect = _bannerScrollView.frame;
            bRect.size.height = 0;
            _bannerScrollView.frame = bRect;
            [_bannerScrollView reloadView:bRect];
        }
        
        _productImageView = _bannerScrollView;
    }
    RLOG(@"=====BANNER_VIEW=====createBannerView_END");
}
- (void)createZoomView:(NSMutableArray*)mArray {
    float widthView, heightView;
    widthView = [[MyDevice sharedManager] screenSize].width;
    heightView = [[MyDevice sharedManager] screenSize].height;
    //    if (_viewMainChildPopoverView) {
    //        for (UIView* v in [_viewMainChildPopoverView subviews]) {
    //            [v removeFromSuperview];
    //        }
    //    }
    
    UIView* viewMain = nil;
    if (self.zoomPopupController == nil)
    {
        viewMain = [[UIView alloc] initWithFrame:CGRectMake(0, 0, widthView, heightView)];
        viewMain.backgroundColor = [UIColor clearColor];
        [viewMain setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        _viewMainChildPopoverView = viewMain;
        self.zoomPopupController = [[CNPPopupController alloc] initWithContents:@[viewMain]];
        self.zoomPopupController.theme = [CNPPopupTheme zoomTheme];
        self.zoomPopupController.theme.popupStyle = CNPPopupStyleCentered;
        self.zoomPopupController.theme.size = CGSizeMake(widthView, heightView);
        self.zoomPopupController.theme.maxPopupWidth = widthView;
        self.zoomPopupController.theme.shouldDismissOnBackgroundTouch = true;
    }
    viewMain = _viewMainChildPopoverView;
    viewMain.frame = CGRectMake(0, 0, widthView, heightView);
    
    self.zoomPopupController.delegate = self;
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        self.zoomPopupController.VIEW_POPUP.transform = CGAffineTransformMakeScale(-1, 1);
    }
    NSMutableArray *imageArray = [[NSMutableArray alloc] init];
    for (NSString* imgUrl in mArray) {
        UIImageView * uiImageView = [[UIImageView alloc]init];
        [uiImageView setBackgroundColor:[UIColor clearColor]];
        [Utility setImage:uiImageView url:imgUrl resizeType:kRESIZE_TYPE_PRODUCT_BANNER isLocal:false];
        [imageArray addObject:uiImageView];
    }
    
    if (_zoomScrollView != nil) {
        [_zoomScrollView removeFromSuperview];
    }
    
    _zoomScrollView = [[PagedImageScrollView alloc] initWithFrame:viewMain.frame];
    [_zoomScrollView setBackgroundColor:[UIColor clearColor]];
    [_zoomScrollView setScrollViewContentsWithImageViews:imageArray contentMode:UIViewContentModeScaleAspectFit];
    [_zoomScrollView reloadView:viewMain.frame];
    [viewMain addSubview:_zoomScrollView];
    [_zoomScrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    
    float buttonHeight = [[MyDevice sharedManager] screenHeightInPortrait] * .075f;
    float buttonWidth = buttonHeight;
    float buttonEdge = buttonHeight * .05f;
    float buttonEdgeZoom = buttonHeight * .25f;
    
    
    UIButton *buttonZoomBg = [[UIButton alloc] initWithFrame:CGRectMake(_zoomScrollView.frame.size.width - buttonWidth - _zoomScrollView.frame.size.width * 0.02f, _zoomScrollView.frame.size.width * 0.02f, buttonWidth, buttonHeight)];
    buttonZoomBg.contentEdgeInsets = UIEdgeInsetsMake(buttonEdgeZoom, buttonEdgeZoom, buttonEdgeZoom, buttonEdgeZoom);
    UIImage* normalZBg = [[UIImage imageNamed:@"cross_btn_bg"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage* selectedZBg = [[UIImage imageNamed:@"cross_btn_bg"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage* highlightedZBg = [[UIImage imageNamed:@"cross_btn_bg"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [buttonZoomBg setUIImage:normalZBg forState:UIControlStateNormal];
    [buttonZoomBg setUIImage:selectedZBg forState:UIControlStateSelected];
    [buttonZoomBg setUIImage:highlightedZBg forState:UIControlStateHighlighted];
    [buttonZoomBg setTintColor:[Utility getUIColor:kUIColorBgHeader]];
    [buttonZoomBg setContentMode:UIViewContentModeScaleAspectFit];
    [buttonZoomBg.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [_zoomScrollView addSubview:buttonZoomBg];
    [buttonZoomBg addTarget:self action:@selector(zoomOut:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *buttonZoom = [[UIButton alloc] initWithFrame:CGRectMake(_zoomScrollView.frame.size.width - buttonWidth - _zoomScrollView.frame.size.width * 0.02f, _zoomScrollView.frame.size.width * 0.02f, buttonWidth, buttonHeight)];
    buttonZoom.contentEdgeInsets = UIEdgeInsetsMake(buttonEdgeZoom, buttonEdgeZoom, buttonEdgeZoom, buttonEdgeZoom);
    UIImage* normalZ = [[UIImage imageNamed:@"cross_btn"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage* selectedZ = [[UIImage imageNamed:@"cross_btn"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage* highlightedZ = [[UIImage imageNamed:@"cross_btn"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [buttonZoom setUIImage:normalZ forState:UIControlStateNormal];
    [buttonZoom setUIImage:selectedZ forState:UIControlStateSelected];
    [buttonZoom setUIImage:highlightedZ forState:UIControlStateHighlighted];
    [buttonZoom setTintColor:[Utility getUIColor:kUIColorThemeButtonSelected]];
    [buttonZoom setContentMode:UIViewContentModeScaleAspectFit];
    [buttonZoom.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [_zoomScrollView addSubview:buttonZoom];
    [buttonZoom addTarget:self action:@selector(zoomOut:) forControlEvents:UIControlEventTouchUpInside];
    
}
- (void)zoomOut:(UIButton*)button {
    _zoomPageIsOpened = false;
    if (self.zoomPopupController) {
        [_bannerScrollView setCurrentPage:(int)(_zoomScrollView.pageControl.currentPage)];
        [self.zoomPopupController dismissPopupControllerAnimated:YES];
    }
}
- (void)showProductFullShortDesc:(UIButton*)button {
    ViewControllerMain* mainVC = [ViewControllerMain getInstance];
    mainVC.containerTop.hidden = YES;
    mainVC.containerCenter.hidden = YES;
    mainVC.containerCenterWithTop.hidden = NO;
    mainVC.vcBottomBar.buttonHome.selected = YES;
    mainVC.vcBottomBar.buttonCart.selected = NO;
    mainVC.vcBottomBar.buttonWishlist.selected = NO;
    mainVC.vcBottomBar.buttonSearch.selected = NO;
    [mainVC.vcBottomBar buttonClicked:nil];
    VCProductDesc* vcProductDesc = (VCProductDesc*)[[Utility sharedManager] pushScreenWithNewAnimation:mainVC.vcCenterTop type:PUSH_SCREEN_TYPE_PROD_DESC];
    //    VCProductDesc* vcProductDesc = (VCProductDesc*)[[Utility sharedManager] pushScreenWithAnimation:mainVC.vcCenterTop type:PUSH_SCREEN_TYPE_PROD_DESC];
    [vcProductDesc setProductData:_currentItem.pInfo];
}
- (void)zoomIn:(UIButton*)button {
    NSMutableArray* mArray = [[NSMutableArray alloc] init];
    if(_currentItem.pInfo){
        if (_currentItem.pInfo._images) {
            for (ProductImage* pImg in _currentItem.pInfo._images) {
                [mArray addObject:pImg._src];
            }
        }
    }
    
    [self createZoomView:mArray];
    _zoomPageIsOpened = true;
    [_zoomScrollView setCurrentPage:(int)(_bannerScrollView.pageControl.currentPage)];
    [self.zoomPopupController presentPopupControllerAnimated:YES];
    [_viewMainChildPopoverView setFrame:CGRectMake(0, 0, [[MyDevice sharedManager] screenSize].width , [[MyDevice sharedManager] screenSize].height)];
    
}
- (void)shareIt:(UIButton*)button {
    
    ProductInfo* pInfo = _currentItem.pInfo;
    [[Utility sharedManager] shareBranchButtonClicked:pInfo button:button];
#if ENABLE_FIREBASE_TAG_MANAGER
    [[AnalyticsHelper sharedInstance] registerShareProductEventGtm:pInfo];
#endif
}
- (void)costShift {
    [_labelOldPrice sizeToFitUI];
    [_labelNewPrice sizeToFitUI];
    CGRect rectOldPrice = _labelOldPrice.frame;
    CGRect rectNewPrice = _labelNewPrice.frame;
    if (rectOldPrice.size.width == 0) {
        rectNewPrice.origin.x = rectOldPrice.origin.x;
    } else {
        rectNewPrice.origin.x = CGRectGetMaxX(rectOldPrice) + self.view.frame.size.width * 0.02f;
    }
    _labelNewPrice.frame = rectNewPrice;
}
- (void)createLoadingView {
    //    _overlayAdded = [Utility createCustomizedLoadingBar:@"Loading Product Data.." isBottomAlign:true isClearViewEnabled:true isShadowEnabled:true];
    //    [_overlayAdded removeFromSuperview];
    //    [self.view addSubview:_overlayAdded];
    //    return;
    //    _progressValue = 0.0f;
    
    float _buttonHeight;
    if ([[MyDevice sharedManager] isIpad]) {
        _buttonHeight = [[MyDevice sharedManager] screenWidthInPortrait] * 0.1f;
    }else{
        _buttonHeight = [[MyDevice sharedManager] screenWidthInPortrait] * 0.125f;
    }
    _buttonHeight *= 0.75f;
    
    float viewWidth = [[MyDevice sharedManager] screenWidthInPortrait] * 0.4f;
    if ([[MyDevice sharedManager] isIphone]) {
        viewWidth = self.view.frame.size.width * 0.7f;
    }
    if (_productLoadingView != nil) {
        [_productLoadingView removeFromSuperview];
        _productLoadingView = nil;
    }
    _productLoadingView = [[UIView alloc] init];
    _productLoadingView.backgroundColor = [UIColor whiteColor];
    _productLoadingView.layer.backgroundColor = [UIColor whiteColor].CGColor;
    _productLoadingView.frame = CGRectMake((self.view.frame.size.width - viewWidth)/2, self.view.frame.size.height - _buttonHeight * 1.25f, viewWidth, _buttonHeight);
    
    //    _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    //    _progressView.frame = CGRectMake(0, 0, _productLoadingView.frame.size.width, _productLoadingView.frame.size.height);
    //    [_progressView setTrackTintColor:[Utility getUIColor:kUIColorThemeButtonDisable]];
    //    [_progressView setProgressTintColor:[Utility getUIColor:kUIColorThemeButtonSelected]];
    //    [_progressView setProgress:0.0f animated:false];
    
    _progressViewHeader = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _productLoadingView.frame.size.width, _productLoadingView.frame.size.height)];
    [_productLoadingView addSubview:_progressViewHeader];
    [_progressViewHeader setUIFont:kUIFontType20 isBold:false];
    _progressViewHeader.text = Localize(@"i_loading_product_data");
    _progressViewHeader.textColor = [Utility getUIColor:kUIColorFontDark];
    _progressViewHeader.textAlignment = NSTextAlignmentCenter;
    
    //    [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(changeValuePBar) userInfo:nil repeats:YES];
    UIActivityIndicatorView* spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinnerView startAnimating];
    spinnerView.center = CGPointMake(_productLoadingView.frame.size.width * 0.10f, _productLoadingView.frame.size.height/2);
    [_productLoadingView addSubview:spinnerView];
    
    _productLoadingView.layer.opacity = 0.9f;
    [_productLoadingView.layer setBorderColor:[[Utility getUIColor:kUIColorBorder] CGColor]];
    [_productLoadingView.layer setBorderWidth:1];
    [Utility showShadow:_productLoadingView];
    [self.view addSubview:_productLoadingView];
    _productLoadingView.layer.shadowOpacity = 0.6f;
}
/*
 - (void)createLoadingView {
 float _buttonHeight;
 if ([[MyDevice sharedManager] isIpad]) {
 _buttonHeight = [[MyDevice sharedManager] screenWidthInPortrait] * 0.1f;
 }else{
 _buttonHeight = [[MyDevice sharedManager] screenWidthInPortrait] * 0.125f;
 }
 
 _productLoadingView = [[UIView alloc] init];
 _productLoadingView.backgroundColor = [UIColor whiteColor];
 _productLoadingView.frame = CGRectMake(self.view.frame.size.width * 0.01f, self.view.frame.size.width * 0.01f, self.view.frame.size.width * 0.98f, _buttonHeight);
 
 UIProgressView* p = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
 [_productLoadingView addSubview:p];
 p.frame = CGRectMake(0, 0, _productLoadingView.frame.size.width, _productLoadingView.frame.size.height);
 [p setTrackTintColor:[Utility getUIColor:kUIColorThemeButtonDisable]];
 [p setProgressTintColor:[Utility getUIColor:kUIColorThemeButtonSelected]];
 [p setProgress:0.0f animated:false];
 CGRect pV = p.frame;
 CGRect lV = _productLoadingView.frame;
 lV.size.height = pV.size.height;
 _productLoadingView.frame = lV;
 
 
 
 
 //    UILabel* labelHeaderTopView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _productLoadingView.frame.size.width, _productLoadingView.frame.size.height)];
 //    [_productLoadingView addSubview:labelHeaderTopView];
 //    [labelHeaderTopView setUIFont:kUIFontType20 isBold:false];
 //    labelHeaderTopView.text = @"Loading Variations..";
 //    labelHeaderTopView.textColor = [Utility getUIColor:kUIColorFontDark];
 //    labelHeaderTopView.textAlignment = NSTextAlignmentCenter;
 //    _progressViewHeader = labelHeaderTopView;
 
 _progressView = p;
 _progressValue = 0.0f;
 [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(changeValuePBar) userInfo:nil repeats:YES];
 
 [_scrollView addSubview:_productLoadingView];
 [_viewsAdded addObject:_productLoadingView];
 [_productLoadingView setTag:kTagForGlobalSpacing];
 //    [Utility showShadow:_productLoadingView];
 }
 */
//- (void)changeValuePBar {
//    if (_progressValue >= 1.0f) {
//        _progressValue = 0.0f;
//        [_progressView setProgress:_progressValue animated:false];
//    } else {
//        _progressValue += 0.1f;
//        [_progressView setProgress:_progressValue animated:true];
//    }
//}
- (BOOL)isVariationKindProduct {
    if (((_currentItem.pInfo._variations && (int)[_currentItem.pInfo._variations count] > 0) || (_currentItem.pInfo._attributes && (int)[_currentItem.pInfo._attributes count] > 0))) {
        return true;
    }
    return false;
}
- (void)setProductLabelInView {
    if (![_currentItem.pInfo.priceLabel isEqualToString:@""]) {
        [_labelNewPrice setText:[NSString stringWithFormat:@"%@%@", _labelNewPrice.text, _currentItem.pInfo.priceLabel]];
    }
}
- (void)setBrandNameInView {
    if(![_currentItem.pInfo.brandName isEqualToString:@""]){
        int fontSize = 3;
        if ([[MyDevice sharedManager] isIpad]) {
            fontSize = 5;
        }
        NSString* fontFace = @"HelveticaNeue-Light";
        //asquared && premihair && groce wheels
        if ([MY_APPID isEqualToString:@"1151746673"] ||
            [MY_APPID isEqualToString:@"1148317682"] ||
            [MY_APPID isEqualToString:@"1172871780"])
        {
            fontFace = @"Futura T OT";
        }
        NSString * htmlString2 = [NSString stringWithFormat:@"<font size=\"%d\" face=\"%@\" color=\"#424242\"> %@ : <a href=\"change-underline-color.php\" style=\"text-decoration: none; border-bottom: 1px solid #FF0000;\">%@</a>", fontSize, fontFace, Localize(@"Brand"), _currentItem.pInfo.brandName];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            htmlString2 = [NSString stringWithFormat:@"<font size=\"%d\" face=\"%@\" color=\"#424242\"> <a href=\"change-underline-color.php\" style=\"text-decoration: none; border-bottom: 1px solid #FF0000;\">%@</a> : %@", fontSize, fontFace, _currentItem.pInfo.brandName, Localize(@"Brand")];
        }
        NSAttributedString * attrStr2 = [[NSAttributedString alloc] initWithData:[htmlString2 dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        [_labelBrand setAttributedTitle:attrStr2 forState:UIControlStateNormal];
    }
}
- (void)createCallView {
    float _heightRectBottomView ,_buttonHeight , _gapBetweenButton, _viewWidth, _buttonCallWidth;
    //    _viewWidth = self.view.frame.size.width * (1.0f - 0.02f);
    if ([[MyDevice sharedManager] isIpad]) {
        _viewWidth = self.view.frame.size.width * (1.0f - 0.02f);
    }else{
        _viewWidth = self.view.frame.size.width * (1.0f - 0.00f);
    }
    
    float width = _viewWidth;
    float dummyWidth = _viewWidth;
    
    
    if ([[MyDevice sharedManager] isIpad]) {
        if ([[MyDevice sharedManager] isLandscape]) {
            dummyWidth *= .8f;
        }
        _buttonCallWidth = dummyWidth * 0.94f;
        
        _buttonHeight = [[MyDevice sharedManager] screenWidthInPortrait] * 0.1f;
        _gapBetweenButton = width * 0.01f;
    } else {
        _buttonCallWidth = dummyWidth;
        _buttonHeight = [[MyDevice sharedManager] screenWidthInPortrait] * 0.125f;
        _gapBetweenButton = width * 0.00f;
    }
    
    _heightRectBottomView = _buttonHeight * 1.0f + _gapBetweenButton * 2.0f;
    CGRect rectBottomView;
    if ([[MyDevice sharedManager] isIpad]) {
        rectBottomView = CGRectMake(self.view.frame.size.width * .01f, self.view.frame.size.width * .01f, width, _heightRectBottomView);
    } else {
        rectBottomView = CGRectMake(0, self.view.frame.size.width * .01f, width, _heightRectBottomView);
    }
    UIView* viewBottom = [[UIView alloc] initWithFrame:rectBottomView];
    viewBottom.backgroundColor = [UIColor whiteColor];
    if (PRODUCT_DETAILS_CONFIG.contact_numbers && [PRODUCT_DETAILS_CONFIG.contact_numbers count] > 0 && [[Utility sharedManager] canDevicePlaceAPhoneCall]) {
        [_scrollView addSubview:viewBottom];
        [_viewsAdded addObject:viewBottom];
        [viewBottom setTag:kTagForGlobalSpacing];
        callNumberPickerArray = [NSArray arrayWithArray:PRODUCT_DETAILS_CONFIG.contact_numbers];
    }
    if ([[MyDevice sharedManager] isIpad]) {
        [Utility showShadow:viewBottom];
    } else {
        
    }
    
    {
        float buttonBuyWidth = _buttonCallWidth;
        float gapBetweenButton = _gapBetweenButton;
        float buttonBuyPosX = gapBetweenButton;
        float buttonHeight = _buttonHeight;
        float buttonBuyPosY = gapBetweenButton;
        _buttonCall = [[UIButton alloc] initWithFrame:CGRectMake(buttonBuyPosX, buttonBuyPosY, buttonBuyWidth, buttonHeight)];
        _buttonCall.center = CGPointMake(width/2, _buttonCall.center.y);
        [_buttonCall setBackgroundColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
        [[_buttonCall titleLabel] setUIFont:kUIFontType22 isBold:false];
        [_buttonCall setTitle:Localize(@"call") forState:UIControlStateNormal];
        [_buttonCall setTitleColor:[Utility getUIColor:kUIColorBuyButtonFont] forState:UIControlStateNormal];
        [viewBottom addSubview:_buttonCall];
        [_buttonCall addTarget:self action:@selector(callButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        _buttonCall.layer.borderColor = [Utility getUIColor:kUIColorBuyButtonNormalBg].CGColor;
        _buttonCall.layer.borderWidth = 1;
    }
}
- (void)callButtonClicked:(UIButton*)button {
    if ([callNumberPickerArray count] > 1) {
        _callNumberPickerView = [[CZPickerView alloc] initWithHeaderTitle:Localize(@"pick_number") cancelButtonTitle:Localize(@"cancel") confirmButtonTitle:Localize(@"call")];
        _callNumberPickerView.delegate = self;
        _callNumberPickerView.dataSource = self;
        _callNumberPickerView.headerBackgroundColor = [Utility getUIColor:kUIColorBuyButtonNormalBg];
        _callNumberPickerView.headerTitleColor = [Utility getUIColor:kUIColorBuyButtonFont];
        //    pickerView.needFooterView = YES;
        [_callNumberPickerView show];
    } else {
        callNumberSelected = callNumberPickerArray[0];
        [self createCallPopup];
    }
}
- (void)createCallPopup {
    [self openPhoneCall:callNumberSelected];
    return;
    _callConfirmationView = [[CZPickerView alloc] initWithHeaderTitle:Localize(@"call") cancelButtonTitle:Localize(@"btn_no") confirmButtonTitle:Localize(@"btn_yes")];
    _callConfirmationView.delegate = self;
    _callConfirmationView.dataSource = self;
    _callConfirmationView.needFooterView = YES;
    _callConfirmationView.headerBackgroundColor = [UIColor whiteColor];
    _callConfirmationView.headerBackgroundColor = [Utility getUIColor:kUIColorBuyButtonNormalBg];
    _callConfirmationView.headerTitleColor = [Utility getUIColor:kUIColorBuyButtonFont];
    _callConfirmationView.confirmButtonBackgroundColor = [Utility getUIColor:kUIColorBuyButtonNormalBg];
    _callConfirmationView.confirmButtonNormalColor = [Utility getUIColor:kUIColorBuyButtonFont];
    _callConfirmationView.cancelButtonBackgroundColor = [Utility getUIColor:kUIColorBuyButtonFont];
    _callConfirmationView.cancelButtonNormalColor = [Utility getUIColor:kUIColorBuyButtonNormalBg];
    [_callConfirmationView show];
}
- (NSString *)czpickerView:(CZPickerView *)pickerView
               titleForRow:(NSInteger)row{
    if (pickerView == _callNumberPickerView) {
        return callNumberPickerArray[row];
    }
    else if(pickerView == _callConfirmationView){
        return [NSString stringWithFormat:@"%@ %@ ?", Localize(@"call"), callNumberSelected];
    }
    return @"";
}
- (NSInteger)numberOfRowsInPickerView:(CZPickerView *)pickerView {
    if (pickerView == _callNumberPickerView) {
        return callNumberPickerArray.count;
    }
    else if(pickerView == _callConfirmationView){
        return 1;
    }
    
    return 1;
}
- (void)czpickerView:(CZPickerView *)pickerView didConfirmWithItemAtRow:(NSInteger)row {
    if (pickerView == _callNumberPickerView) {
        RLOG(@"%@ is chosen!", callNumberPickerArray[row]);
        callNumberSelected = callNumberPickerArray[row];
        [self createCallPopup];
    }
    else if(pickerView == _callConfirmationView){
        [self openPhoneCall:callNumberSelected];
    }
    //    [self.navigationController setNavigationBarHidden:YES];
}
- (void)czpickerViewDidClickCancelButton:(CZPickerView *)pickerView {
    //    [self.navigationController setNavigationBarHidden:YES];
    RLOG(@"Canceled.");
}
- (void)czpickerViewWillDisplay:(CZPickerView *)pickerView {
    RLOG(@"Picker will display.");
}

- (void)czpickerViewDidDisplay:(CZPickerView *)pickerView {
    RLOG(@"Picker did display.");
}

- (void)czpickerViewWillDismiss:(CZPickerView *)pickerView {
    RLOG(@"Picker will dismiss.");
}

- (void)czpickerViewDidDismiss:(CZPickerView *)pickerView {
    RLOG(@"Picker did dismiss.");
}
//- (void)openPhoneCall:(NSString *)phoneNumberString{
//    phoneNumberString = [NSString stringWithFormat:@"tel:%@", phoneNumberString];
//    NSURL *phoneNumberURL = [NSURL URLWithString:phoneNumberString];
//    [[UIApplication sharedApplication] openURL:phoneNumberURL];
//}
- (void)openPhoneCall:(NSString *)phoneNumberStr {
    UIAlertView *alert= [[UIAlertView alloc]initWithTitle:@"" message:[NSString stringWithFormat:Localize(@"call_to_number"),phoneNumberStr] delegate:self cancelButtonTitle:Localize(@"btn_no") otherButtonTitles:Localize(@"btn_yes"), nil];
    [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            NSString *phoneNumberString = phoneNumberStr;
            phoneNumberString = [phoneNumberString stringByReplacingOccurrencesOfString:@" " withString:@""];
            phoneNumberString = [NSString stringWithFormat:@"tel:%@", phoneNumberString];
            NSURL *phoneNumberURL = [NSURL URLWithString:phoneNumberString];
            [[UIApplication sharedApplication] openURL:phoneNumberURL];
        }
    }];
}
- (void)createBuyButtonDescription {
    
    NSString* str = Localize(@"buy_button_description");
    BOOL show_buy_button_description = PRODUCT_DETAILS_CONFIG.show_buy_button_description;
    if (str == nil || [str isEqualToString:@"buy_button_description"] || [str isEqualToString:@""]) {
        show_buy_button_description = false;
    }
    
    
    if (show_buy_button_description == false) {
        return;
    }
    
    
    
    UILabel* label = [[UILabel alloc] init];
    [label setText:str];
    [label setTextColor:[Utility getUIColor:kUIColorFontDark]];
    [label setUIFont:kUIFontType18 isBold:true];
    [label sizeToFitUI];
    [_scrollView addSubview:label];
    [_viewsAdded addObject:label];
    [label setTag:kTagForGlobalSpacing];
    
    CGRect rect = label.frame;
    rect.origin.x = self.view.frame.size.width * .03f;
    rect.size.width = self.view.frame.size.width * .97f;
    label.frame = rect;
    
    
    
    //    float _heightRectBottomView ,_buttonHeight , _gapBetweenButton, _viewWidth, _buttonCallWidth;
    //    if ([[MyDevice sharedManager] isIpad]) {
    //        _viewWidth = self.view.frame.size.width * (1.0f - 0.02f);
    //    }else{
    //        _viewWidth = self.view.frame.size.width * (1.0f - 0.00f);
    //    }
    //
    //    float width = _viewWidth;
    //    float dummyWidth = _viewWidth;
    //
    //
    //    if ([[MyDevice sharedManager] isIpad]) {
    //        if ([[MyDevice sharedManager] isLandscape]) {
    //            dummyWidth *= .8f;
    //        }
    //        _buttonCallWidth = dummyWidth * 0.94f;
    //
    //        _buttonHeight = [[MyDevice sharedManager] screenWidthInPortrait] * 0.1f;
    //        _gapBetweenButton = width * 0.00f;
    //    } else {
    //        _buttonCallWidth = dummyWidth;
    //        _buttonHeight = [[MyDevice sharedManager] screenWidthInPortrait] * 0.125f;
    //        _gapBetweenButton = width * 0.00f;
    //    }
    //
    //    _heightRectBottomView = _buttonHeight * 1.0f + _gapBetweenButton * 2.0f;
    //    CGRect rectBottomView;
    //    if ([[MyDevice sharedManager] isIpad]) {
    //        rectBottomView = CGRectMake(self.view.frame.size.width * .01f, self.view.frame.size.width * .01f, width, _heightRectBottomView);
    //    } else {
    //        rectBottomView = CGRectMake(0, self.view.frame.size.width * .01f, width, _heightRectBottomView);
    //    }
    //    UIView* viewBottom = [[UIView alloc] initWithFrame:rectBottomView];
    //    viewBottom.backgroundColor = [UIColor whiteColor];
    //
    //
    //    NSString* str = Localize(@"buy_button_description");
    //    BOOL show_buy_button_description = PRODUCT_DETAILS_CONFIG.show_buy_button_description;
    //
    //
    //    if (str == nil || [str isEqualToString:@"buy_button_description"] || [str isEqualToString:@""]) {
    //        show_buy_button_description = false;
    //    }
    //
    //    if (show_buy_button_description) {
    //        [_scrollView addSubview:viewBottom];
    //        [_viewsAdded addObject:viewBottom];
    //        [viewBottom setTag:kTagForNoSpacing];
    //    }
    //    if ([[MyDevice sharedManager] isIpad]) {
    //        [Utility showShadow:viewBottom];
    //    } else {
    //
    //    }
    //    float buttonBuyWidth = _buttonCallWidth;
    //    float gapBetweenButton = _gapBetweenButton;
    //    float buttonBuyPosX = gapBetweenButton;
    //    float buttonHeight = _buttonHeight;
    //    float buttonBuyPosY = gapBetweenButton;
    //    UIButton* buttonBuyDesc = [[UIButton alloc] initWithFrame:CGRectMake(buttonBuyPosX, buttonBuyPosY, buttonBuyWidth, buttonHeight)];
    //    buttonBuyDesc.center = CGPointMake(width/2, buttonBuyDesc.center.y);
    //    [[buttonBuyDesc titleLabel] setUIFont: isBold:false];
    //    [buttonBuyDesc setTitle:Localize(@"buy_button_description") forState:UIControlStateNormal];
    //    [buttonBuyDesc setTitleColor:[Utility getUIColor:kUIColorFontDark] forState:UIControlStateNormal];
    //    [viewBottom addSubview:buttonBuyDesc];
}
- (void)createVariationView {
    float _heightRectTopView, _heightRectMiddleView, _heightRectBottomView, _buttonWishlistWidth,_buttonCartWidth ,_buttonHeight , _gapBetweenButton, _viewWidth, _buttonBuyWidth;
    if ([[MyDevice sharedManager] isIpad]) {
        _viewWidth = self.view.frame.size.width * (1.0f - 0.02f);
    }else{
        _viewWidth = self.view.frame.size.width * (1.0f - 0.00f);
    }
    float width = _viewWidth;
    if ([[MyDevice sharedManager] isIpad]) {
        _buttonBuyWidth = width * 0.6f;
        _buttonWishlistWidth = width * 0.15f;
        _buttonCartWidth = width * 0.15f;
        _buttonHeight = [[MyDevice sharedManager] screenWidthInPortrait] * 0.1f;
        _gapBetweenButton = _viewWidth * 0.02f;
        _heightRectBottomView = _buttonHeight * 1.25f;
        _heightRectMiddleView = _buttonHeight * 0.75f;
        
        if (PRODUCT_DETAILS_CONFIG.select_variation_with_button) {
            _heightRectMiddleView = _buttonHeight * 1.125f;
        }
    }else{
        _buttonBuyWidth = width * 0.6f+2;
        _buttonWishlistWidth = width * 0.2f;
        _buttonCartWidth = width * 0.2f;
        _buttonHeight = [[MyDevice sharedManager] screenWidthInPortrait] * 0.125f;
        _gapBetweenButton = width * 0.00f;
        _heightRectBottomView = _buttonHeight * 1.0f;
        _heightRectMiddleView = _buttonHeight * 1.25f;//TODO FOR IPHONE
        
        if (PRODUCT_DETAILS_CONFIG.select_variation_with_button) {
            _heightRectMiddleView = _buttonHeight * 1.0f;
        }
    }
    _heightRectTopView = _buttonHeight * 1.0f;
    int selectionViewCount = (int)[_currentItem.pInfo._attributes count];
    CGRect rectTopView = CGRectMake(0, _productImageView.frame.size.height, self.view.frame.size.width * .98f, _heightRectTopView);
    UIView* viewTop = [[UIView alloc] initWithFrame:rectTopView];
    viewTop.backgroundColor = [UIColor whiteColor];
    _productCostView = viewTop;
    CGRect rectMiddleView = CGRectMake(
                                       self.view.frame.size.width * .01f,
                                       self.view.frame.size.width * .01f,
                                       self.view.frame.size.width * .98f,
                                       selectionViewCount * _heightRectMiddleView * 1.0f);
    UIView* viewMiddle = [[UIView alloc] initWithFrame:rectMiddleView];
    viewMiddle.backgroundColor = [UIColor whiteColor];
    if(selectionViewCount){
        [_scrollView addSubview:viewMiddle];
        [_viewsAdded addObject:viewMiddle];
        [viewMiddle setTag:kTagForGlobalSpacing];
        [Utility showShadow:viewMiddle];
    }
    UIButton *buttonShare = [[UIButton alloc] init];
    //elements in topView
    {
        //        float buttonHeight = [[MyDevice sharedManager] screenHeightInPortrait] * .075f;
        float buttonHeight = [[MyDevice sharedManager] screenHeightInPortrait] * .065f;
        
        float buttonWidth = buttonHeight;
        float buttonEdge = buttonHeight * .05f;
        float buttonEdgeZoom = buttonHeight * .25f;
        
        if (PRODUCT_DETAILS_CONFIG.show_share_button) {
            buttonShare.frame = CGRectMake(_bannerScrollView.frame.size.width - buttonWidth - _bannerScrollView.frame.size.width * 0.02f, _bannerScrollView.frame.size.width * 0.02f, buttonWidth, buttonHeight);
            buttonShare.contentEdgeInsets = UIEdgeInsetsMake(buttonEdge, buttonEdge, buttonEdge, buttonEdge);
            UIImage* normalS = [[UIImage imageNamed:@"share_icon_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            UIImage* selectedS = [[UIImage imageNamed:@"share_icon_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            UIImage* highlightedS = [[UIImage imageNamed:@"share_icon_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [buttonShare setUIImage:normalS forState:UIControlStateNormal];
            [buttonShare setUIImage:selectedS forState:UIControlStateSelected];
            [buttonShare setUIImage:highlightedS forState:UIControlStateHighlighted];
            [buttonShare setTintColor:[Utility getUIColor:kUIColorThemeButtonSelected]];
            [buttonShare setContentMode:UIViewContentModeScaleAspectFit];
            [buttonShare.imageView setContentMode:UIViewContentModeScaleAspectFit];
            [viewTop addSubview:buttonShare];
            [buttonShare addTarget:self action:@selector(shareIt:) forControlEvents:UIControlEventTouchUpInside];
        }
        if (PRODUCT_DETAILS_CONFIG.show_zoom_button) {
            UIButton *buttonZoom = [[UIButton alloc] initWithFrame:CGRectMake(_bannerScrollView.frame.size.width - buttonWidth - _bannerScrollView.frame.size.width * 0.02f, _bannerScrollView.frame.size.width * 0.02f, buttonWidth, buttonHeight)];
            buttonZoom.contentEdgeInsets = UIEdgeInsetsMake(buttonEdgeZoom, buttonEdgeZoom, buttonEdgeZoom, buttonEdgeZoom);
            UIImage* normalZ = [[UIImage imageNamed:@"zoom-in"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            UIImage* selectedZ = [[UIImage imageNamed:@"zoom-in"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            UIImage* highlightedZ = [[UIImage imageNamed:@"zoom-in"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [buttonZoom setUIImage:normalZ forState:UIControlStateNormal];
            [buttonZoom setUIImage:selectedZ forState:UIControlStateSelected];
            [buttonZoom setUIImage:highlightedZ forState:UIControlStateHighlighted];
            [buttonZoom setTintColor:[Utility getUIColor:kUIColorThemeButtonSelected]];
            [buttonZoom setContentMode:UIViewContentModeScaleAspectFit];
            [buttonZoom.imageView setContentMode:UIViewContentModeScaleAspectFit];
            [_bannerScrollView addSubview:buttonZoom];
            [buttonZoom addTarget:self action:@selector(zoomIn:) forControlEvents:UIControlEventTouchUpInside];
            [buttonZoom setHidden:true];
        }
        _labelOldPrice = [[UILabel alloc] initWithFrame:
                          CGRectMake(0,
                                     0,
                                     viewTop.frame.size.width * (1.0f - 0.04f),
                                     viewTop.frame.size.height * .5f)];
        [_labelOldPrice setUIFont:kUIFontType18 isBold:true];
        [_labelOldPrice setTextAlignment:NSTextAlignmentLeft];
        [viewTop addSubview:_labelOldPrice];
        _labelNewPrice = [[UILabel alloc] initWithFrame:
                          CGRectMake(0,
                                     0,
                                     viewTop.frame.size.width * (1.0f - 0.04f),
                                     viewTop.frame.size.height * .5f)];
        [_labelNewPrice setUIFont:kUIFontType18 isBold:true];
        [_labelNewPrice setTextAlignment:NSTextAlignmentLeft];
        [viewTop addSubview:_labelNewPrice];
        
        
        UILabel* labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(viewTop.frame.size.width * 0.02f, viewTop.frame.size.width * (0.02f), viewTop.frame.size.width * 0.7f, viewTop.frame.size.height - viewTop.frame.size.width * (0.04f))];
        [viewTop addSubview:labelTitle];
        labelTitle.lineBreakMode = NSLineBreakByWordWrapping;
        labelTitle.numberOfLines = 0;
        NSString * htmlString1 = _currentItem.pInfo._title;
        NSAttributedString * attrStr1 = [[NSAttributedString alloc] initWithData:[htmlString1 dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        labelTitle.text = [attrStr1 string];
        [labelTitle setUIFont:kUIFontType20 isBold:false];
        labelTitle.textColor = [Utility getUIColor:kUIColorFontDark];
        [labelTitle sizeToFitUI];
        if (PRODUCT_DETAILS_CONFIG.show_product_title == false) {
            CGRect lRect = labelTitle.frame;
            lRect.size.height = 0.0;
            labelTitle.frame = lRect;
        }
        
        
        _labelBrand = [[UIButton alloc] initWithFrame:CGRectMake(viewTop.frame.size.width * 0.02f, CGRectGetMaxY(labelTitle.frame), viewTop.frame.size.width * 0.7f, viewTop.frame.size.height - viewTop.frame.size.width * (0.04f))];
        [viewTop addSubview:_labelBrand];
        [_labelBrand setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [_labelBrand setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        }
        if (PRODUCT_DETAILS_CONFIG.show_brand_names == false) {
            CGRect lRect = _labelBrand.frame;
            lRect.size.height = 0.0;
            _labelBrand.frame = lRect;
        }
        [_labelBrand addTarget:self action:@selector(openBrandPageLink) forControlEvents:UIControlEventTouchUpInside];
        [self setBrandNameInView];
        
        
        
        UILabel* labelDetails = [[UILabel alloc] initWithFrame:CGRectMake(viewTop.frame.size.width * 0.02f, CGRectGetMaxY(_labelBrand.frame), viewTop.frame.size.width * 0.7f, viewTop.frame.size.height - viewTop.frame.size.width * (0.04f))];
        [viewTop addSubview:labelDetails];
        labelDetails.lineBreakMode = NSLineBreakByWordWrapping;
        labelDetails.numberOfLines = 0;
        if (PRODUCT_DETAILS_CONFIG.product_short_desc_max_line != -1) {
            labelDetails.numberOfLines = PRODUCT_DETAILS_CONFIG.product_short_desc_max_line;
        }
        
        NSString * htmlString = _currentItem.pInfo._short_description;
        if (htmlString == nil || [htmlString isEqualToString:@""]) {
            //            labelDetails.text=_currentItem.pInfo._title;
            [labelDetails setUIFont:kUIFontType16 isBold:false];
        } else {
            labelDetails.attributedText = [_currentItem.pInfo getShortDescriptionAttributedString];
            [labelDetails setUIFont:kUIFontType16 isBold:false];
        }
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [labelDetails setTextAlignment:NSTextAlignmentRight];
        }
        labelDetails.textColor = [Utility getUIColor:kUIColorFontDark];
        [labelDetails sizeToFitUI];
        if (PRODUCT_DETAILS_CONFIG.show_short_desc == false) {
            CGRect lRect = labelDetails.frame;
            lRect.size.height = 0.0;
            labelDetails.frame = lRect;
        }
        
        if (PRODUCT_DETAILS_CONFIG.product_short_desc_max_line != -1) {
            UIButton* btnShowMore = [[UIButton alloc] initWithFrame:CGRectMake( CGRectGetMinX(labelDetails.frame), CGRectGetMaxY(labelDetails.frame), labelDetails.superview.frame.size.width - CGRectGetMinX(labelDetails.frame) * 2, 50)];
            btnShowMore.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
            btnShowMore.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
            [btnShowMore.titleLabel setUIFont:kUIFontType16 isBold:false];
            [btnShowMore setTitle:[NSString stringWithFormat:@"..%@", Localize(@"show_more")] forState:UIControlStateNormal];
            [btnShowMore setTitleColor:[Utility getUIColor:kUIColorThemeButtonSelected] forState:UIControlStateNormal];
            [labelDetails.superview addSubview:btnShowMore];
            [btnShowMore addTarget:self action:@selector(showProductFullShortDesc:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        
        /////////////////
        BOOL isDiscounted = [_currentItem.pInfo isProductDiscounted:-1];
        float newPrice = [_currentItem.pInfo getNewPrice:-1];
        float oldPrice = [_currentItem.pInfo getOldPrice:-1];
        if (isDiscounted) {
            [_labelOldPrice setAttributedText:[[Utility sharedManager] convertToStringStrikethrough:oldPrice isCurrency:true]];
        } else {
            [_labelOldPrice setText:@""];
        }
        if(![[Addons sharedManager] show_min_max_price]) {
            [_labelNewPrice setText:[[Utility sharedManager] convertToString:newPrice isCurrency:true]];
            [self setProductLabelInView];
        } else {
            if (_currentItem.variationId == -1) {
                [_labelNewPrice setText:[_currentItem.pInfo getPriceNewString]];
                [self setProductLabelInView];
            } else {
                [_labelNewPrice setText:[[Utility sharedManager] convertToString:newPrice isCurrency:true]];
                [self setProductLabelInView];
            }
        }
        /////////////////
        _labelOldPrice.textColor = [Utility getUIColor:kUIColorFontPriceOld];
        _labelNewPrice.textColor = [Utility getUIColor:kUIColorFontDark];
        
        [_labelOldPrice sizeToFitUI];
        [_labelNewPrice sizeToFitUI];
        
        CGRect rectOldPrice = _labelOldPrice.frame;
        CGRect rectNewPrice = _labelNewPrice.frame;
        rectOldPrice.origin.x = viewTop.frame.size.width * 0.02f;
        rectOldPrice.origin.y = CGRectGetMaxY(labelDetails.frame)+viewTop.frame.size.width * 0.02f;
        _labelOldPrice.frame = rectOldPrice;
        if (rectOldPrice.size.width == 0) {
            rectNewPrice.origin.x = viewTop.frame.size.width * 0.02f;
        } else {
            rectNewPrice.origin.x = rectOldPrice.origin.x + rectOldPrice.size.width + viewTop.frame.size.width * 0.02f;
        }
        rectNewPrice.origin.y = rectOldPrice.origin.y;
        _labelNewPrice.frame = rectNewPrice;
        
        if (([[GuestConfig sharedInstance] hide_price] && ![AppUser isSignedIn]) || [[Addons sharedManager] hide_price]) {
            if (_currentItem.pInfo._isFullRetrieved) {
                _labelNewPrice.text = @"";
                _labelOldPrice.text = @"";
            }
            CGRect lRect = _labelNewPrice.frame;
            lRect.size.height = 0;
            _labelNewPrice.frame = lRect;
            _labelOldPrice.frame = lRect;
        } else {
            
        }
        
        [self costShift];
        CGRect topViewRect =  viewTop.frame;
        topViewRect.size.height = MAX(topViewRect.size.height, CGRectGetMaxY(_labelNewPrice.frame) + viewTop.frame.size.width * 0.02f);
        topViewRect.size.height = MAX(topViewRect.size.height, CGRectGetMaxY(buttonShare.frame) + viewTop.frame.size.width * 0.02f);
        viewTop.frame = topViewRect;
        if([[Addons sharedManager] enable_custom_points]) {
            float x = 8.0f, y = 0.0f;
            _labelRewardPoints = [[UILabel alloc] initWithFrame:CGRectMake(x, CGRectGetMaxY(_labelNewPrice.frame), self.view.frame.size.width - 2*x, self.view.frame.size.width *.1f)];
            _labelRewardPoints.textColor = getColor(kUIColorFontDark);
            _labelRewardPoints.lineBreakMode = NSLineBreakByWordWrapping;
            _labelRewardPoints.hidden = YES;
            [_labelRewardPoints setTag:kTagForGlobalSpacing];
            [_labelRewardPoints setUIFont:kUIFontType16 isBold:false];
            [_labelRewardPoints sizeToFitUI];
            [_labelNewPrice.superview addSubview:_labelRewardPoints];
        }
    }
    //elements in middleView
    if(1){
        if (selectionViewCount > 0) {
            _selectionViews = [[NSMutableArray alloc] init];
        }else{
            _selectionViews = nil;
        }
        
        
        for (int i = 0; i < selectionViewCount; i++) {
            BOOL isFullLength = true;
            CGPoint origin = CGPointMake(0, i * _heightRectMiddleView);
            if (selectionViewCount == 1) {
                isFullLength = true;
            }
            SelectionView* selectionView = nil;
            if (PRODUCT_DETAILS_CONFIG.select_variation_with_button) {
                float middleViewMaxH = 0;
                for (SelectionView* sv in self.selectionViews) {
                    middleViewMaxH += sv.frame.size.height;
                }
                origin = CGPointMake(0, middleViewMaxH);
                selectionView = [self createSelectionViewLinearButton:i isFullLength:isFullLength origin:origin viewHeight:_heightRectMiddleView];
            } else {
                selectionView = [self createSelectionView:i isFullLength:isFullLength origin:origin viewHeight:_heightRectMiddleView];
            }
            [viewMiddle addSubview:selectionView];
            [_selectionViews addObject:selectionView];
        }
        
        
        
        
        float middleViewMaxH = 0;
        for (SelectionView* sv in self.selectionViews) {
            middleViewMaxH += sv.frame.size.height;
        }
        viewMiddle.frame = CGRectMake(viewMiddle.frame.origin.x, viewMiddle.frame.origin.y, viewMiddle.frame.size.width, middleViewMaxH);
        viewMiddle.layer.shadowOpacity = 0.0f;
        [Utility showShadow:viewMiddle];
        
    }
    _productImageAndCostView.frame = CGRectMake(self.view.frame.size.width * .01f,
                                                _productImageView.frame.origin.y,
                                                self.view.frame.size.width * .98f,
                                                _productImageView.frame.size.height  +_productCostView.frame.size.height);
    [_productImageAndCostView addSubview:_productImageView];
    [_productImageAndCostView addSubview:_productCostView];
    [Utility showShadow:_productImageAndCostView];
    
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(zoomIn:)];
    [_productImageAndCostView addGestureRecognizer:singleFingerTap];
    
}


- (SelectionView *)createSelectionViewLinearButton:(int)viewId isFullLength:(BOOL)isFullLength origin:(CGPoint)origin viewHeight:(float)viewHeight{
    float buttonHeight = 50;
    float viewWidth = self.view.frame.size.width * .98f;
    float originX = origin.x;
    float originY = origin.y;
    float posY = originY;
    SelectionView* selectionView = [[SelectionView alloc] init];
    selectionView.vcProduct = self;
    [selectionView setFrame:CGRectMake(origin.x, origin.y, viewWidth, viewHeight)];
    Attribute* attribute = (Attribute*)[_currentItem.pInfo._attributes objectAtIndex:viewId];
    selectionView.attribute = attribute;
    selectionView.attributeSelectedValue = [attribute._options objectAtIndex:0];
    selectionView.selectedVariation = _selectedVariation;
    selectionView.selectedVariationAttibutes = _selectedVariationAttibutes;
    selectionView.viewId = viewId;
    selectionView.pInfo = _currentItem.pInfo;
    int clickedItemId = 0;
    if (_currentItem.variationId != -1) {
        NSString* attributeName = [NSString stringWithFormat:@"%@", attribute._name];
        NSString* attributeSlug = [NSString stringWithFormat:@"%@", attribute._slug];
        for (VariationAttribute* varAttribute in _selectedVariation._attributes) {
            NSString* varAttributeName = [NSString stringWithFormat:@"%@", varAttribute.name];
            NSString* varAttributeSlug = [NSString stringWithFormat:@"%@", varAttribute.slug];
            if ([Utility compareAttributeNames:attributeSlug name2:varAttributeSlug]) {
                NSString* varAttributeValue = [NSString stringWithFormat:@"%@", varAttribute.value];
                if ([varAttributeValue isEqualToString:@""]) {
                    for (VariationAttribute* varAttributeSelected in _selectedVariationAttibutes) {
                        NSString* varAttributeNameSelected = [NSString stringWithFormat:@"%@", varAttributeSelected.name];
                        NSString* varAttributeSlugSelected = [NSString stringWithFormat:@"%@", varAttributeSelected.slug];
                        if ([Utility compareAttributeNames:attributeSlug name2:varAttributeSlugSelected]) {
                            varAttributeValue = varAttributeSelected.value;
                            NSLog(@"changed");
                            break;
                        }
                    }
                }
                for (NSString* option in attribute._options) {
                    NSString* attributeOptionValue = [NSString stringWithFormat:@"%@", option];
                    if ([Utility compareAttributeNames:attributeOptionValue name2:varAttributeValue]) {
                        selectionView.attributeSelectedValue = option;
                        break;
                    }
                    clickedItemId++;
                }
                break;
            }
        }
    }
    NSString* stringTitle = [NSString stringWithString:attribute._name];
    [selectionView loadView:[[NSMutableArray alloc] initWithArray:[attribute getOptions]]];
    [selectionView.label setText:[Utility getNormalStringFromAttributed:stringTitle]];
    [selectionView setParentViewForDropDownView:_scrollView];
    [selectionView.label setTextColor:[Utility getUIColor:kUIColorFontDark]];
    [selectionView.label setUIFont:kUIFontType18 isBold:true];
    [selectionView.label setFrame:CGRectMake(0 + 10, 0, viewWidth - 20, viewHeight/2)];
    [selectionView.button setFrame:CGRectMake(0, 0, viewWidth, viewHeight)];
    [selectionView.label setTextColor:[Utility getUIColor:kUIColorFontDark]];
    [selectionView.layer setBorderWidth:0.5f];
    [selectionView.layer setBorderColor:[Utility getUIColor:kUIColorBorder].CGColor];
    [selectionView.button.layer setBorderWidth:0.5f];
    [selectionView.button setUserInteractionEnabled:false];
    [selectionView.button setHidden:true];
    [selectionView.label setHidden:false];
    [selectionView bringSubviewToFront:selectionView.label];
    [selectionView.button setTitle:@"" forState:UIControlStateNormal];
    [selectionView.label sizeToFitUI];
    float labelH = selectionView.label.frame.size.height;
    float buttonH = viewHeight/2;
    float marginH = 10;
    float marginW = 10;
    if ([[MyDevice sharedManager] isIphone]) {
        marginH = 5;
    }
    float labelY = marginH;
    float buttonY = labelY+labelH+marginH;
    float selectionViewH = buttonY+buttonH+marginH;
    selectionView.label.frame = CGRectMake(selectionView.label.frame.origin.x, labelY, selectionView.label.frame.size.width, labelH);
    selectionView.frame = CGRectMake(selectionView.frame.origin.x, selectionView.frame.origin.y, selectionView.frame.size.width, selectionViewH);
    [selectionView setUserInteractionEnabled:true];
    int x = 10;
    int y = 0;
    int w = viewWidth;
    int h = viewHeight/2;
    UIScrollView* scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, w, selectionViewH)];
    [selectionView addSubview:scrollView];
    selectionView.scrollViewLinearButton = scrollView;
    [scrollView setClipsToBounds:true];
    [scrollView setUserInteractionEnabled:true];
    int itemId = 0;
    UIButton* btnClicked = nil;
    for (NSString* str in [attribute getOptions]) {
        UIButton* button = [[UIButton alloc] init];
        button.frame = CGRectMake(x, buttonY, w, buttonH);
        [button setTitle:str forState:UIControlStateNormal];
        [button.layer setBorderWidth:0.5f];
        [button.titleLabel setUIFont:kUIFontType18 isBold:false];
        [button setTitleColor:[Utility getUIColor:kUIColorBuyButtonNormalBg] forState:UIControlStateNormal];
        [button.layer setBorderColor:[Utility getUIColor:kUIColorBuyButtonNormalBg].CGColor];
        [button setBackgroundColor:[Utility getUIColor:kUIColorBuyButtonFont]];
        [button.titleLabel sizeToFitUI];
        //        [button setShowsTouchWhenHighlighted:true];
        [button setFrame:CGRectMake(x, buttonY, button.titleLabel.frame.size.width + marginW * 2, buttonH)];
        [button addTarget:self action:@selector(hButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:button];
        [button setUserInteractionEnabled:true];
        
        [button.layer setValue:selectionView forKey:@"SELECTION_VIEW_OBJ"];
        x += (button.frame.size.width + marginW);
        if (itemId == clickedItemId) {
            btnClicked = button;
        }
        itemId++;
    }
    if (btnClicked) {
        [self hButtonClicked:btnClicked];
    }
    [scrollView setBackgroundColor:[UIColor clearColor]];
    [scrollView setScrollEnabled:true];
    [scrollView setDelegate:self];
    CGSize contentSize = CGSizeMake(MAX(scrollView.contentSize.width, x), viewHeight/2);
    [scrollView setContentSize:contentSize];
    [scrollView setUserInteractionEnabled:true];
    [scrollView setBounces:true];
    [scrollView setShowsHorizontalScrollIndicator:true];
    selectionView.layer.borderWidth = 0.5f;
    return selectionView;
}

- (void)hButtonClicked:(UIButton*)sender {
    NSLog(@"VCPRODUCT:hButtonClicked");
    UIButton* button = sender;
    SelectionView* sView = (SelectionView*)[button.layer valueForKey:@"SELECTION_VIEW_OBJ"];
    UIScrollView* scrollView = (UIScrollView*)(button.superview);
    NSArray* buttons = scrollView.subviews;
    int clickedItemId = 0;
    int itemId = 0;
    for (id obj in buttons) {
        if ([obj isKindOfClass:[UIButton class]]) {
            UIButton* btn = obj;
            if (btn != button) {
                [btn setTitleColor:[Utility getUIColor:kUIColorBuyButtonNormalBg] forState:UIControlStateNormal];
                [btn.layer setBorderColor:[Utility getUIColor:kUIColorBuyButtonNormalBg].CGColor];
                [btn setBackgroundColor:[Utility getUIColor:kUIColorBuyButtonFont]];
                [btn setSelected:false];
            } else {
                [btn setTitleColor:[Utility getUIColor:kUIColorBuyButtonFont] forState:UIControlStateNormal];
                [btn.layer setBorderColor:[Utility getUIColor:kUIColorBuyButtonFont].CGColor];
                [btn setBackgroundColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
                clickedItemId = itemId;
                [btn setSelected:true];
            }
            itemId++;
        }
    }
    
    [sView itemClicked:clickedItemId];
}
- (void)handlePanGestureRecognizer:(UIPanGestureRecognizer *)gesture {
    NSLog(@"VCPRODUCT:handlePanGestureRecognizer");
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    NSLog(@"VCPRODUCT:gestureRecognizerShouldBegin");
    return YES;
}
- (void)createCostView {
    Addons* addons = [Addons sharedManager];
    if (addons.enable_cart == false){
        if (self.show_external_product_layout) {
            [self createButtonViewForExtProduct];
        }else {
            [self createButtonViewForPurchaseThreeLiner];
        }
    } else {
        if ([[[Addons sharedManager] productDetailsConfig] show_quick_cart_section]) {
            _viewForMinQuantity = [self createViewForMinQuantity];
            _viewForPurchaseGrocery = [self createButtonViewForPurchaseGrocery];
        }
        else if (self.show_vertical_layout_components) {
            [self createButtonViewForPurchaseThreeLiner];
        }
        else if (self.show_external_product_layout) {
            [self createButtonViewForExtProduct];
        }
        else {
            [self createButtonViewForPurchase];
        }
    }
    BOOL showBuyButtonDescription = true;
    if (showBuyButtonDescription) {
        [self createBuyButtonDescription];
    }
}
- (void)createButtonViewForPurchase {
    float _heightRectTopView, _heightRectMiddleView, _heightRectBottomView, _buttonWishlistWidth,_buttonCartWidth ,_buttonHeight , _gapBetweenButton, _viewWidth, _buttonBuyWidth;
    if ([[MyDevice sharedManager] isIpad]) {
        _viewWidth = self.view.frame.size.width * (1.0f - 0.02f);
    }else{
        _viewWidth = self.view.frame.size.width * (1.0f - 0.00f);
    }
    float width = _viewWidth;
    if ([[MyDevice sharedManager] isIpad]) {
        _buttonBuyWidth = width * 0.6f;
        _buttonWishlistWidth = width * 0.15f;
        _buttonCartWidth = width * 0.15f;
        _buttonHeight = [[MyDevice sharedManager] screenWidthInPortrait] * 0.1f;
        _gapBetweenButton = _viewWidth * 0.02f;
        _heightRectBottomView = _buttonHeight * 1.25f;
        _heightRectMiddleView = _buttonHeight * 1.0f;
    } else {
        _buttonBuyWidth = width * 0.6f+2;
        _buttonWishlistWidth = width * 0.2f;
        _buttonCartWidth = width * 0.2f;
        _buttonHeight = [[MyDevice sharedManager] screenWidthInPortrait] * 0.125f;
        _gapBetweenButton = width * 0.00f;
        _heightRectBottomView = _buttonHeight * 1.0f;
        _heightRectMiddleView = _buttonHeight * 1.25f;
    }
    _heightRectTopView = _buttonHeight * 1.0f;
    CGRect rectBottomView;
    if ([[MyDevice sharedManager] isIpad]) {
        rectBottomView = CGRectMake(self.view.frame.size.width * .01f, self.view.frame.size.width * .01f, _viewWidth, _heightRectBottomView);
    } else {
        rectBottomView = CGRectMake(0, self.view.frame.size.width * .01f, _viewWidth, _heightRectBottomView);
    }
    UIView* viewBottom = [[UIView alloc] initWithFrame:rectBottomView];
    viewBottom.backgroundColor = [UIColor whiteColor];
    if (PRODUCT_DETAILS_CONFIG.show_button_section || [self isVariationKindProduct]) {
        [_scrollView addSubview:viewBottom];
        [_viewsAdded addObject:viewBottom];
        [viewBottom setTag:kTagForGlobalSpacing];
    }
    if ([[MyDevice sharedManager] isIpad]) {
        [Utility showShadow:viewBottom];
    } else {
        
    }
    
    
    {
        float buttonBuyWidth = _buttonBuyWidth;
        float buttonWishlistWidth = _buttonWishlistWidth;
        float buttonCartWidth = _buttonCartWidth;
        float gapBetweenButton = _gapBetweenButton;
        float totalWidth = buttonBuyWidth + gapBetweenButton + buttonWishlistWidth + gapBetweenButton + buttonCartWidth;
        float buttonBuyPosX = (viewBottom.frame.size.width - totalWidth) / 2.0f;
        float buttonWishlistPosX = buttonBuyPosX + buttonBuyWidth + gapBetweenButton;
        float buttonCartPosX = buttonWishlistPosX + buttonWishlistWidth + gapBetweenButton;
        if ([[MyDevice sharedManager] isIphone]) {
            buttonBuyPosX = (viewBottom.frame.size.width - totalWidth) / 2.0f + 1;
            buttonWishlistPosX = buttonBuyPosX + buttonBuyWidth + gapBetweenButton-1;
            buttonCartPosX = buttonWishlistPosX + buttonWishlistWidth + gapBetweenButton-1;
        }
        float buttonHeight = _buttonHeight;
        float buttonPosY = viewBottom.frame.size.height * 0.5f - buttonHeight / 2;
        float buttonEdge = buttonHeight * .20f;
        _buttonBuy = [[UIButton alloc] initWithFrame:CGRectMake(buttonBuyPosX, buttonPosY, buttonBuyWidth, buttonHeight)];
        [_buttonBuy setBackgroundColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
        [[_buttonBuy titleLabel] setUIFont:kUIFontType22 isBold:false];
        [_buttonBuy setTitle:Localize(@"buy") forState:UIControlStateNormal];
        [_buttonBuy setTitleColor:[Utility getUIColor:kUIColorBuyButtonFont] forState:UIControlStateNormal];
        [viewBottom addSubview:_buttonBuy];
        [_buttonBuy addTarget:self action:@selector(buyProduct:) forControlEvents:UIControlEventTouchUpInside];
        _buttonBuy.layer.borderColor = [Utility getUIColor:kUIColorBuyButtonNormalBg].CGColor;
        _buttonBuy.layer.borderWidth = 1;
        
        
        _buttonWishlist = [[UIButton alloc] initWithFrame:CGRectMake(buttonWishlistPosX, buttonPosY, buttonWishlistWidth, buttonHeight)];
        float edgeSize = buttonHeight * .25f;
        [_buttonWishlist setImageEdgeInsets:UIEdgeInsetsMake(edgeSize, 0, edgeSize, 0)];
        [_buttonWishlist.imageView setContentMode:UIViewContentModeScaleAspectFit];
        UIImage* normalWL = [[UIImage imageNamed:@"btn_wishlist_bottom"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImage* selectedWL = [[UIImage imageNamed:@"btn_wishlist_bottom_on"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImage* highlightedWL = [[UIImage imageNamed:@"btn_wishlist_bottom_on"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_buttonWishlist setUIImage:normalWL forState:UIControlStateNormal];
        [_buttonWishlist setUIImage:selectedWL forState:UIControlStateSelected];
        [_buttonWishlist setUIImage:highlightedWL forState:UIControlStateHighlighted];
        [viewBottom addSubview:_buttonWishlist];
        [_buttonWishlist addTarget:self action:@selector(addToWishlist:) forControlEvents:UIControlEventTouchUpInside];
        _buttonWishlist.layer.borderWidth = 1.0f;
        _buttonWishlist.layer.borderColor = [Utility getUIColor:kUIColorBuyButtonNormalBg].CGColor;
        [self initWishlistButtonProductScreen:_buttonWishlist];
        _buttonCart = [[UIButton alloc] initWithFrame:CGRectMake(buttonCartPosX, buttonPosY, buttonCartWidth, buttonHeight)];
        [_buttonCart setImageEdgeInsets:UIEdgeInsetsMake(edgeSize, 0, edgeSize, 0)];
        [_buttonCart.imageView setContentMode:UIViewContentModeScaleAspectFit];
        UIImage* normalC = [[UIImage imageNamed:@"btn_cart_bottom"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImage* selectedC = [[UIImage imageNamed:@"btn_cart_bottom_on"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImage* highlightedC = [[UIImage imageNamed:@"btn_cart_bottom_on"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_buttonCart setUIImage:normalC forState:UIControlStateNormal];
        [_buttonCart setUIImage:selectedC forState:UIControlStateSelected];
        [_buttonCart setUIImage:highlightedC forState:UIControlStateHighlighted];
        [viewBottom addSubview:_buttonCart];
        [_buttonCart removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
        [_buttonCart addTarget:self action:@selector(addToCart:) forControlEvents:UIControlEventTouchUpInside];
        [_buttonCart setShowsTouchWhenHighlighted:YES];
        _buttonCart.layer.borderWidth = 1.0f;
        _buttonCart.layer.borderColor = [Utility getUIColor:kUIColorBuyButtonNormalBg].CGColor;
    }
}
- (UIView*)createButtonViewForPurchaseGrocery {
    float _heightRectTopView, _heightRectBottomView, _buttonWishlistWidth,_buttonCartWidth ,_buttonHeight , _gapBetweenButton, _viewWidth, _buttonBuyWidth;
    if ([[MyDevice sharedManager] isIpad]) {
        _viewWidth = self.view.frame.size.width * (1.0f - 0.02f);
    }else{
        _viewWidth = self.view.frame.size.width * (1.0f - 0.00f);
    }
    float width = _viewWidth;
    
    if ([[MyDevice sharedManager] isIpad]) {
        width = [[MyDevice sharedManager] screenWidthInPortrait] * (1.0f - 0.02f);
    }
    if ([[MyDevice sharedManager] isIpad]) {
        _buttonBuyWidth = width * 0.4f;
        _buttonWishlistWidth = width * 0.15f;
        _buttonCartWidth = width * 0.4f;
        _buttonHeight = [[MyDevice sharedManager] screenWidthInPortrait] * 0.1f;
        _gapBetweenButton = _viewWidth * 0.0f;
        _heightRectBottomView = _buttonHeight * 1.25f;
    } else {
        _buttonBuyWidth = width * 0.425f;
        _buttonWishlistWidth = width * 0.15f;
        _buttonCartWidth = width * 0.425f;
        _buttonHeight = [[MyDevice sharedManager] screenWidthInPortrait] * 0.125f;
        _gapBetweenButton = width * 0.00f;
        _heightRectBottomView = _buttonHeight * 1.0f;
    }
    _heightRectTopView = _buttonHeight * 1.0f;
    CGRect rectBottomView;
    if ([[MyDevice sharedManager] isIpad]) {
        rectBottomView = CGRectMake(self.view.frame.size.width * .01f, self.view.frame.size.width * .01f, _viewWidth, _heightRectBottomView);
    } else {
        rectBottomView = CGRectMake(0, self.view.frame.size.width * .01f, _viewWidth, _heightRectBottomView);
    }
    UIView* viewBottom = [[UIView alloc] initWithFrame:rectBottomView];
    viewBottom.backgroundColor = [UIColor whiteColor];
    if (PRODUCT_DETAILS_CONFIG.show_button_section || [self isVariationKindProduct]) {
        [_scrollView addSubview:viewBottom];
        [_viewsAdded addObject:viewBottom];
        [viewBottom setTag:kTagForGlobalSpacing];
    }
    if ([[MyDevice sharedManager] isIpad]) {
        [Utility showShadow:viewBottom];
    } else {
        
    }
    
    
    {
        float buttonBuyWidth = _buttonBuyWidth;
        float buttonWishlistWidth = _buttonWishlistWidth;
        float buttonCartWidth = _buttonCartWidth;
        float gapBetweenButton = _gapBetweenButton;
        float totalWidth = buttonBuyWidth + gapBetweenButton + buttonWishlistWidth + gapBetweenButton + buttonCartWidth;
        float buttonBuyPosX = (viewBottom.frame.size.width - totalWidth) / 2.0f;
        float buttonCartPosX = buttonBuyPosX + buttonBuyWidth + gapBetweenButton;
        float buttonWishlistPosX = buttonCartPosX + buttonCartWidth + gapBetweenButton;
        if ([[MyDevice sharedManager] isIphone]) {
            buttonBuyPosX = (viewBottom.frame.size.width - totalWidth) / 2.0f;
            buttonCartPosX = buttonBuyPosX + buttonBuyWidth + gapBetweenButton;
            buttonWishlistPosX = buttonCartPosX + buttonCartWidth + gapBetweenButton;
        }
        float buttonHeight = _buttonHeight;
        float buttonPosY = viewBottom.frame.size.height * 0.5f - buttonHeight / 2;
        
        _buttonBuy = [[UIButton alloc] initWithFrame:CGRectMake(buttonBuyPosX, buttonPosY, buttonBuyWidth, buttonHeight)];
        
        
        float buttonAddWidth = _buttonBuy.frame.size.height * .7f;
        if ([[MyDevice sharedManager] isIpad]) {
            buttonAddWidth = _buttonBuy.frame.size.height * .6f;
        }
        float buttonAddGap = _buttonBuy.frame.size.height * .4f / 2;
        UIView* _groceryView = [[UIView alloc] init];
        _groceryView.backgroundColor = [UIColor clearColor];
        _groceryView.frame = _buttonBuy.frame;
        _groceryView.layer.borderWidth = 1;
        _groceryView.layer.borderColor = [Utility getUIColor:kUIColorBuyButtonNormalBg].CGColor;
        [viewBottom addSubview:_groceryView];
        _groceryButtonAdd = [[UIButton alloc] init];
        _groceryButtonSubstract = [[UIButton alloc] init];
        _groceryTextField = [[UITextField alloc] init];
        [_groceryView addSubview:_groceryButtonAdd];
        [_groceryView addSubview:_groceryButtonSubstract];
        [_groceryView addSubview:_groceryTextField];
        UIImage* imgAddButtonCircle = [[UIImage imageNamed:@"button_circle"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImage* imgSubstractButtonCircle = [[UIImage imageNamed:@"button_circle"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _groceryButtonSubstract.frame = CGRectMake(buttonAddGap, buttonAddGap, buttonAddWidth, buttonAddWidth);
        _groceryButtonAdd.frame = CGRectMake(_buttonBuy.frame.size.width - buttonAddWidth - buttonAddGap, buttonAddGap, buttonAddWidth, buttonAddWidth);
        _groceryTextField.frame = CGRectMake(CGRectGetMaxX(_groceryButtonSubstract.frame) + buttonAddGap, buttonAddGap, (CGRectGetMinX(_groceryButtonAdd.frame) - buttonAddGap) - (CGRectGetMaxX(_groceryButtonSubstract.frame) + buttonAddGap), buttonAddWidth);
        
        [_groceryButtonAdd setBackgroundImage:imgAddButtonCircle forState:UIControlStateNormal];
        [_groceryButtonAdd addTarget:self action:@selector(groceryAddButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_groceryButtonAdd setTintColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
        [_groceryButtonAdd setTitleColor:[Utility getUIColor:kUIColorBuyButtonFont] forState:UIControlStateNormal];
        [_groceryButtonAdd.titleLabel setUIFont:kUIFontType20 isBold:true];
        //        if ([[MyDevice sharedManager] isIpad]) {
        //            [_groceryButtonAdd.titleLabel setUIFont:kUIFontType22 isBold:true];
        //        }
        [_groceryButtonAdd.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_groceryButtonAdd setTitle:@"+" forState:UIControlStateNormal];
        
        
        
        
        
        [_groceryButtonSubstract setBackgroundImage:imgSubstractButtonCircle forState:UIControlStateNormal];
        [_groceryButtonSubstract addTarget:self action:@selector(grocerySubstractButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_groceryButtonSubstract setTintColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
        [_groceryButtonSubstract setTitleColor:[Utility getUIColor:kUIColorBuyButtonFont] forState:UIControlStateNormal];
        [_groceryButtonSubstract.titleLabel setUIFont:kUIFontType20 isBold:true];
        //        if ([[MyDevice sharedManager] isIpad]) {
        //            [_groceryButtonSubstract.titleLabel setUIFont:kUIFontType22 isBold:true];
        //        }
        [_groceryButtonSubstract.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_groceryButtonSubstract setTitle:@"-" forState:UIControlStateNormal];
        
        
        _groceryTextField.backgroundColor = [UIColor clearColor];
        _groceryTextField.textColor = [Utility getUIColor:kUIColorBuyButtonNormalBg];
        [_groceryTextField setUIFont:kUIFontType18 isBold:false];
        _groceryTextField.layer.borderWidth = 1.0f;
        _groceryTextField.layer.borderColor = [Utility getUIColor:kUIColorBuyButtonNormalBg].CGColor;
        //        _groceryTextField.borderStyle = UITextBorderStyleRoundedRect;
        //        [_groceryTextField.layer setCornerRadius:10.0f];
        _groceryTextField.borderStyle = UITextBorderStyleLine;
        _groceryTextField.returnKeyType = UIReturnKeyDone;
        _groceryTextField.textAlignment = NSTextAlignmentCenter;
        _groceryTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _groceryTextField.delegate = self;
        _groceryTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _groceryTextField.userInteractionEnabled = false;
        
        _buttonWishlist = [[UIButton alloc] initWithFrame:CGRectMake(buttonWishlistPosX, buttonPosY, buttonWishlistWidth, buttonHeight)];
        float edgeSize = buttonHeight * .25f;
        [_buttonWishlist setImageEdgeInsets:UIEdgeInsetsMake(edgeSize, 0, edgeSize, 0)];
        [_buttonWishlist.imageView setContentMode:UIViewContentModeScaleAspectFit];
        UIImage* normalWL = [[UIImage imageNamed:@"btn_wishlist_bottom"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImage* selectedWL = [[UIImage imageNamed:@"btn_wishlist_bottom_on"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImage* highlightedWL = [[UIImage imageNamed:@"btn_wishlist_bottom_on"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_buttonWishlist setUIImage:normalWL forState:UIControlStateNormal];
        [_buttonWishlist setUIImage:selectedWL forState:UIControlStateSelected];
        [_buttonWishlist setUIImage:highlightedWL forState:UIControlStateHighlighted];
        [viewBottom addSubview:_buttonWishlist];
        [_buttonWishlist addTarget:self action:@selector(addToWishlist:) forControlEvents:UIControlEventTouchUpInside];
        _buttonWishlist.layer.borderWidth = 1.0f;
        _buttonWishlist.layer.borderColor = [Utility getUIColor:kUIColorBuyButtonNormalBg].CGColor;
        [self initWishlistButtonProductScreen:_buttonWishlist];
        
        
        _buttonCart = [[UIButton alloc] initWithFrame:CGRectMake(buttonCartPosX, buttonPosY, buttonCartWidth, buttonHeight)];
        [_buttonCart setBackgroundColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
        [[_buttonCart titleLabel] setUIFont:kUIFontType22 isBold:false];
        [_buttonCart setTitle:Localize(@"toggle_cart_on") forState:UIControlStateNormal];
        [_buttonCart setTitleColor:[Utility getUIColor:kUIColorBuyButtonFont] forState:UIControlStateNormal];
        [viewBottom addSubview:_buttonCart];
        [_buttonCart removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
        [_buttonCart addTarget:self action:@selector(buyProduct:) forControlEvents:UIControlEventTouchUpInside];
        _buttonCart.layer.borderColor = [Utility getUIColor:kUIColorBuyButtonNormalBg].CGColor;
        _buttonCart.layer.borderWidth = 1;
        
    }
    
    return viewBottom;
}
- (void)createButtonViewForExtProduct {
    float _heightRectBottomView, _buttonWishlistWidth, _buttonCartWidth ,_buttonHeight , _gapBetweenButton, _viewWidth, _buttonBuyWidth;
    _viewWidth = self.view.frame.size.width * (1.0f - 0.02f);
    float width = _viewWidth;
    float dummyWidth = _viewWidth;
    if ([[MyDevice sharedManager] isLandscape]) {
        dummyWidth *= .8f;
    }
    _buttonBuyWidth = dummyWidth * 0.96f;
    _buttonWishlistWidth = dummyWidth * 0.96f;
    _buttonCartWidth = dummyWidth * 0.96f;
    if ([[MyDevice sharedManager] isIpad]) {
        _buttonHeight = [[MyDevice sharedManager] screenWidthInPortrait] * 0.1f;
    } else {
        _buttonHeight = [[MyDevice sharedManager] screenWidthInPortrait] * 0.125f;
    }
    _gapBetweenButton = width * 0.02f;
    _heightRectBottomView = _buttonHeight * 3.0f + _gapBetweenButton * 4.0f;
    CGRect rectBottomView;
    if ([[MyDevice sharedManager] isIpad]) {
        rectBottomView = CGRectMake(self.view.frame.size.width * .01f, self.view.frame.size.width * .01f, width, _heightRectBottomView);
    } else {
        rectBottomView = CGRectMake(0, self.view.frame.size.width * .01f, width, _heightRectBottomView);
    }
    UIView* viewBottom = [[UIView alloc] initWithFrame:rectBottomView];
    viewBottom.backgroundColor = [UIColor whiteColor];
    if (PRODUCT_DETAILS_CONFIG.show_button_section || [self isVariationKindProduct]) {
        [_scrollView addSubview:viewBottom];
        [_viewsAdded addObject:viewBottom];
        [viewBottom setTag:kTagForGlobalSpacing];
    }
    if ([[MyDevice sharedManager] isIpad]) {
        [Utility showShadow:viewBottom];
    }
    
    {
        float buttonBuyWidth = _buttonBuyWidth;
        float buttonWishlistWidth = _buttonWishlistWidth;
        float buttonCartWidth = _buttonCartWidth;
        float gapBetweenButton = _gapBetweenButton;
        float buttonBuyPosX = gapBetweenButton;
        float buttonWishlistPosX = gapBetweenButton;
        float buttonCartPosX = gapBetweenButton;
        float buttonHeight = _buttonHeight;
        float buttonBuyPosY = gapBetweenButton;
        float buttonCartPosY = buttonBuyPosY + buttonHeight + gapBetweenButton;
        float buttonWishlistPosY = buttonCartPosY + buttonHeight + gapBetweenButton;
        Addons* addons = [Addons sharedManager];
        //        if (addons.enable_cart == false){
        buttonWishlistPosY = buttonCartPosY;
        viewBottom.frame = CGRectMake(viewBottom.frame.origin.x, viewBottom.frame.origin.y, viewBottom.frame.size.width,  _buttonHeight * 2.0f + _gapBetweenButton * 3.0f);
        if ([[MyDevice sharedManager] isIpad]) {
            viewBottom.layer.shadowOpacity = 0.0f;
            [Utility showShadow:viewBottom];
        }
        //        }
        float buttonEdge = buttonHeight * .20f;
        _buttonBuy = [[UIButton alloc] initWithFrame:CGRectMake(buttonBuyPosX, buttonBuyPosY, buttonBuyWidth, buttonHeight)];
        _buttonBuy.center = CGPointMake(width/2, _buttonBuy.center.y);
        [_buttonBuy setBackgroundColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
        [[_buttonBuy titleLabel] setUIFont:kUIFontType22 isBold:false];
        
        NSString* strVisitButtonText = Localize(@"visit_product");
        if (_currentItem.pInfo.button_text && ![_currentItem.pInfo.button_text isEqualToString:@""]) {
            strVisitButtonText = _currentItem.pInfo.button_text;
        }
        [_buttonBuy setTitle:strVisitButtonText forState:UIControlStateNormal];
        [_buttonBuy setTitleColor:[Utility getUIColor:kUIColorBuyButtonFont] forState:UIControlStateNormal];
        [viewBottom addSubview:_buttonBuy];
        [_buttonBuy addTarget:self action:@selector(visitProduct:) forControlEvents:UIControlEventTouchUpInside];
        _buttonBuy.layer.borderColor = [Utility getUIColor:kUIColorBuyButtonNormalBg].CGColor;
        _buttonBuy.layer.borderWidth = 1;
        
        
        _buttonWishlist = [[UIButton alloc] initWithFrame:CGRectMake(buttonWishlistPosX, buttonWishlistPosY, buttonWishlistWidth, buttonHeight)];
        _buttonWishlist.center = CGPointMake(width/2, _buttonWishlist.center.y);
        float edgeSize = buttonHeight * .25f;
        [[_buttonWishlist titleLabel] setUIFont:kUIFontType22 isBold:false];
        [_buttonWishlist setTitle:Localize(@"toggle_wishlist_on") forState:UIControlStateNormal];
        [_buttonWishlist setTitleColor:[Utility getUIColor:kUIColorBuyButtonNormalBg] forState:UIControlStateNormal];
        [_buttonWishlist setImageEdgeInsets:UIEdgeInsetsMake(edgeSize, 0, edgeSize, 0)];
        [_buttonWishlist.imageView setContentMode:UIViewContentModeScaleAspectFit];
        UIImage* normalWL = [[UIImage imageNamed:@"btn_wishlist_trimmed"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImage* selectedWL = [[UIImage imageNamed:@"btn_wishlist_trimmed_on"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImage* highlightedWL = [[UIImage imageNamed:@"btn_wishlist_trimmed_on"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_buttonWishlist setUIImage:normalWL forState:UIControlStateNormal];
        [_buttonWishlist setUIImage:selectedWL forState:UIControlStateSelected];
        [_buttonWishlist setUIImage:highlightedWL forState:UIControlStateHighlighted];
        [viewBottom addSubview:_buttonWishlist];
        [_buttonWishlist addTarget:self action:@selector(addToWishlist:) forControlEvents:UIControlEventTouchUpInside];
        _buttonWishlist.layer.borderWidth = 1.0f;
        _buttonWishlist.layer.borderColor = [Utility getUIColor:kUIColorBuyButtonNormalBg].CGColor;
        [self initWishlistButtonProductScreen:_buttonWishlist];
        
        
        
        _buttonCart = [[UIButton alloc] initWithFrame:CGRectMake(buttonCartPosX, buttonCartPosY, buttonCartWidth, buttonHeight)];
        _buttonCart.center = CGPointMake(width/2, _buttonCart.center.y);
        [[_buttonCart titleLabel] setUIFont:kUIFontType22 isBold:false];
        [_buttonCart setTitle:Localize(@"toggle_cart_on") forState:UIControlStateNormal];
        [_buttonCart setTitleColor:[Utility getUIColor:kUIColorBuyButtonNormalBg] forState:UIControlStateNormal];
        [_buttonCart setImageEdgeInsets:UIEdgeInsetsMake(edgeSize, 0, edgeSize, 0)];
        [_buttonCart.imageView setContentMode:UIViewContentModeScaleAspectFit];
        UIImage* normalC = [[UIImage imageNamed:@"btn_cart_trimmed"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImage* selectedC = [[UIImage imageNamed:@"btn_cart_trimmed_on"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImage* highlightedC = [[UIImage imageNamed:@"btn_cart_trimmed_on"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_buttonCart setUIImage:normalC forState:UIControlStateNormal];
        [_buttonCart setUIImage:selectedC forState:UIControlStateSelected];
        [_buttonCart setUIImage:highlightedC forState:UIControlStateHighlighted];
        [viewBottom addSubview:_buttonCart];
        [_buttonCart removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
        [_buttonCart addTarget:self action:@selector(addToCart:) forControlEvents:UIControlEventTouchUpInside];
        [_buttonCart setShowsTouchWhenHighlighted:YES];
        _buttonCart.layer.borderWidth = 1.0f;
        _buttonCart.layer.borderColor = [Utility getUIColor:kUIColorBuyButtonNormalBg].CGColor;
        //        if (addons.enable_cart == false){
        //            _buttonBuy.enabled = false;
        //            _buttonBuy.hidden = true;
        //            _buttonBuy.frame = CGRectMake(_buttonBuy.frame.origin.x, _buttonBuy.frame.origin.y, _buttonBuy.frame.size.width, _buttonBuy.frame.size.height * 0);
        _buttonCart.enabled = false;
        _buttonCart.frame = CGRectMake(_buttonCart.frame.origin.x, _buttonCart.frame.origin.y, _buttonCart.frame.size.width, _buttonCart.frame.size.height * 0);
        _buttonCart.hidden = true;
        //        }
        
        _buttonCart.enabled = false;
        _buttonCart.frame = CGRectMake(_buttonCart.frame.origin.x, _buttonCart.frame.origin.y, _buttonCart.frame.size.width, _buttonCart.frame.size.height * 0);
        _buttonCart.hidden = true;
        
    }
}
- (void)createButtonViewForPurchaseThreeLiner {
    float _heightRectBottomView, _buttonWishlistWidth,_buttonCartWidth ,_buttonHeight , _gapBetweenButton, _viewWidth, _buttonBuyWidth;
    _viewWidth = self.view.frame.size.width * (1.0f - 0.02f);
    
    float width = _viewWidth;
    float dummyWidth = _viewWidth;
    if ([[MyDevice sharedManager] isLandscape]) {
        dummyWidth *= .8f;
    }
    
    
    
    _buttonBuyWidth = dummyWidth * 0.96f;
    _buttonWishlistWidth = dummyWidth * 0.96f;
    _buttonCartWidth = dummyWidth * 0.96f;
    
    if ([[MyDevice sharedManager] isIpad]) {
        _buttonHeight = [[MyDevice sharedManager] screenWidthInPortrait] * 0.1f;
    } else {
        _buttonHeight = [[MyDevice sharedManager] screenWidthInPortrait] * 0.125f;
    }
    _gapBetweenButton = width * 0.02f;
    _heightRectBottomView = _buttonHeight * 3.0f + _gapBetweenButton * 4.0f;
    CGRect rectBottomView;
    if ([[MyDevice sharedManager] isIpad]) {
        rectBottomView = CGRectMake(self.view.frame.size.width * .01f, self.view.frame.size.width * .01f, width, _heightRectBottomView);
    } else {
        rectBottomView = CGRectMake(0, self.view.frame.size.width * .01f, width, _heightRectBottomView);
    }
    UIView* viewBottom = [[UIView alloc] initWithFrame:rectBottomView];
    viewBottom.backgroundColor = [UIColor whiteColor];
    if (PRODUCT_DETAILS_CONFIG.show_button_section || [self isVariationKindProduct]) {
        [_scrollView addSubview:viewBottom];
        [_viewsAdded addObject:viewBottom];
        [viewBottom setTag:kTagForGlobalSpacing];
    }
    if ([[MyDevice sharedManager] isIpad]) {
        [Utility showShadow:viewBottom];
    } else {
        
    }
    
    
    {
        float buttonBuyWidth = _buttonBuyWidth;
        float buttonWishlistWidth = _buttonWishlistWidth;
        float buttonCartWidth = _buttonCartWidth;
        float gapBetweenButton = _gapBetweenButton;
        //        float totalWidth = buttonBuyWidth + gapBetweenButton + buttonWishlistWidth + gapBetweenButton + buttonCartWidth;
        float buttonBuyPosX = gapBetweenButton;
        float buttonWishlistPosX = gapBetweenButton;
        float buttonCartPosX = gapBetweenButton;
        float buttonHeight = _buttonHeight;
        
        float buttonBuyPosY = gapBetweenButton;
        float buttonCartPosY = buttonBuyPosY + buttonHeight + gapBetweenButton;
        float buttonWishlistPosY = buttonCartPosY + buttonHeight + gapBetweenButton;
        Addons* addons = [Addons sharedManager];
        if (addons.enable_cart == false){
            buttonWishlistPosY = buttonBuyPosY;
            viewBottom.frame = CGRectMake(viewBottom.frame.origin.x, viewBottom.frame.origin.y, viewBottom.frame.size.width,  _buttonHeight * 1.0f + _gapBetweenButton * 2.0f);
            if ([[MyDevice sharedManager] isIpad]) {
                viewBottom.layer.shadowOpacity = 0.0f;
                [Utility showShadow:viewBottom];
            }
        }
        
        float buttonEdge = buttonHeight * .20f;
        _buttonBuy = [[UIButton alloc] initWithFrame:CGRectMake(buttonBuyPosX, buttonBuyPosY, buttonBuyWidth, buttonHeight)];
        _buttonBuy.center = CGPointMake(width/2, _buttonBuy.center.y);
        [_buttonBuy setBackgroundColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
        [[_buttonBuy titleLabel] setUIFont:kUIFontType22 isBold:false];
        [_buttonBuy setTitle:Localize(@"buy") forState:UIControlStateNormal];
        [_buttonBuy setTitleColor:[Utility getUIColor:kUIColorBuyButtonFont] forState:UIControlStateNormal];
        [viewBottom addSubview:_buttonBuy];
        [_buttonBuy addTarget:self action:@selector(buyProduct:) forControlEvents:UIControlEventTouchUpInside];
        _buttonBuy.layer.borderColor = [Utility getUIColor:kUIColorBuyButtonNormalBg].CGColor;
        _buttonBuy.layer.borderWidth = 1;
        
        _buttonWishlist = [[UIButton alloc] initWithFrame:CGRectMake(buttonWishlistPosX, buttonWishlistPosY, buttonWishlistWidth, buttonHeight)];
        _buttonWishlist.center = CGPointMake(width/2, _buttonWishlist.center.y);
        float edgeSize = buttonHeight * .25f;
        [[_buttonWishlist titleLabel] setUIFont:kUIFontType22 isBold:false];
        [_buttonWishlist setTitle:Localize(@"toggle_wishlist_on") forState:UIControlStateNormal];
        [_buttonWishlist setTitleColor:[Utility getUIColor:kUIColorBuyButtonNormalBg] forState:UIControlStateNormal];
        [_buttonWishlist setImageEdgeInsets:UIEdgeInsetsMake(edgeSize, 0, edgeSize, 0)];
        [_buttonWishlist.imageView setContentMode:UIViewContentModeScaleAspectFit];
        UIImage* normalWL = [[UIImage imageNamed:@"btn_wishlist_trimmed"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImage* selectedWL = [[UIImage imageNamed:@"btn_wishlist_trimmed_on"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImage* highlightedWL = [[UIImage imageNamed:@"btn_wishlist_trimmed_on"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_buttonWishlist setUIImage:normalWL forState:UIControlStateNormal];
        [_buttonWishlist setUIImage:selectedWL forState:UIControlStateSelected];
        [_buttonWishlist setUIImage:highlightedWL forState:UIControlStateHighlighted];
        [viewBottom addSubview:_buttonWishlist];
        [_buttonWishlist addTarget:self action:@selector(addToWishlist:) forControlEvents:UIControlEventTouchUpInside];
        _buttonWishlist.layer.borderWidth = 1.0f;
        _buttonWishlist.layer.borderColor = [Utility getUIColor:kUIColorBuyButtonNormalBg].CGColor;
        [self initWishlistButtonProductScreen:_buttonWishlist];
        
        _buttonCart = [[UIButton alloc] initWithFrame:CGRectMake(buttonCartPosX, buttonCartPosY, buttonCartWidth, buttonHeight)];
        _buttonCart.center = CGPointMake(width/2, _buttonCart.center.y);
        [[_buttonCart titleLabel] setUIFont:kUIFontType22 isBold:false];
        [_buttonCart setTitle:Localize(@"toggle_cart_on") forState:UIControlStateNormal];
        [_buttonCart setTitleColor:[Utility getUIColor:kUIColorBuyButtonNormalBg] forState:UIControlStateNormal];
        [_buttonCart setImageEdgeInsets:UIEdgeInsetsMake(edgeSize, 0, edgeSize, 0)];
        [_buttonCart.imageView setContentMode:UIViewContentModeScaleAspectFit];
        UIImage* normalC = [[UIImage imageNamed:@"btn_cart_trimmed"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImage* selectedC = [[UIImage imageNamed:@"btn_cart_trimmed_on"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImage* highlightedC = [[UIImage imageNamed:@"btn_cart_trimmed_on"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_buttonCart setUIImage:normalC forState:UIControlStateNormal];
        [_buttonCart setUIImage:selectedC forState:UIControlStateSelected];
        [_buttonCart setUIImage:highlightedC forState:UIControlStateHighlighted];
        [viewBottom addSubview:_buttonCart];
        [_buttonCart removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
        [_buttonCart addTarget:self action:@selector(addToCart:) forControlEvents:UIControlEventTouchUpInside];
        [_buttonCart setShowsTouchWhenHighlighted:YES];
        _buttonCart.layer.borderWidth = 1.0f;
        _buttonCart.layer.borderColor = [Utility getUIColor:kUIColorBuyButtonNormalBg].CGColor;
        if (addons.enable_cart == false){
            _buttonBuy.enabled = false;
            _buttonBuy.hidden = true;
            _buttonBuy.frame = CGRectMake(_buttonBuy.frame.origin.x, _buttonBuy.frame.origin.y, _buttonBuy.frame.size.width, _buttonBuy.frame.size.height * 0);
            _buttonCart.enabled = false;
            _buttonCart.frame = CGRectMake(_buttonCart.frame.origin.x, _buttonCart.frame.origin.y, _buttonCart.frame.size.width, _buttonCart.frame.size.height * 0);
            _buttonCart.hidden = true;
        }
        
    }
}
- (UIView*)createViewForMinQuantity {
    float _heightRectBottomView ,_buttonHeight , _viewWidth;
    if ([[MyDevice sharedManager] isIpad]) {
        _viewWidth = self.view.frame.size.width * (1.0f - 0.02f);
    }else{
        _viewWidth = self.view.frame.size.width * (1.0f - 0.00f);
    }
    if ([[MyDevice sharedManager] isIpad]) {
        _buttonHeight = [[MyDevice sharedManager] screenWidthInPortrait] * 0.1f;
        _heightRectBottomView = _buttonHeight * 0;
    } else {
        _buttonHeight = [[MyDevice sharedManager] screenWidthInPortrait] * 0.125f;
        _heightRectBottomView = _buttonHeight * 0;
    }
    CGRect rectBottomView;
    if ([[MyDevice sharedManager] isIpad]) {
        rectBottomView = CGRectMake(self.view.frame.size.width * .01f, self.view.frame.size.width * .01f, _viewWidth, _heightRectBottomView);
    } else {
        rectBottomView = CGRectMake(0, self.view.frame.size.width * .01f, _viewWidth, _heightRectBottomView);
    }
    UIView* viewBottom = [[UIView alloc] initWithFrame:rectBottomView];
    viewBottom.backgroundColor = [UIColor whiteColor];
    if (PRODUCT_DETAILS_CONFIG.show_button_section || [self isVariationKindProduct]) {
        [_scrollView addSubview:viewBottom];
        [_viewsAdded addObject:viewBottom];
        [viewBottom setTag:kTagForNoSpacing];
    }
    
    
    return viewBottom;
}
- (void)updateViewForMinQuantity {
    
    if (_currentItem.pInfo.quantityRule.orderrideRule == false) {
        return;
    }
    int stepValue = _currentItem.pInfo.quantityRule.stepValue;
    int minValue = _currentItem.pInfo.quantityRule.minQuantity;
    
    
    float _heightRectBottomView ,_buttonHeight , _viewWidth;
    if ([[MyDevice sharedManager] isIpad]) {
        _viewWidth = self.view.frame.size.width * (1.0f - 0.02f);
    }else{
        _viewWidth = self.view.frame.size.width * (1.0f - 0.00f);
    }
    if ([[MyDevice sharedManager] isIpad]) {
        _buttonHeight = [[MyDevice sharedManager] screenWidthInPortrait] * 0.1f;
        _heightRectBottomView = _buttonHeight * 1.25f;
    } else {
        _buttonHeight = [[MyDevice sharedManager] screenWidthInPortrait] * 0.125f;
        _heightRectBottomView = _buttonHeight * 1.0f;
    }
    _heightRectBottomView = _heightRectBottomView * 0.5f;
    
    CGRect rect = _viewForMinQuantity.frame;
    rect.size.height = _heightRectBottomView;
    _viewForMinQuantity.frame = rect;
    
    for (UIView* v in [_viewForMinQuantity subviews]) {
        [v removeFromSuperview];
    }
    UILabel* labelHeaderBottomView = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width * 0.02f, 0, _viewForMinQuantity.frame.size.width, _viewForMinQuantity.frame.size.height)];
    [_viewForMinQuantity addSubview:labelHeaderBottomView];
    labelHeaderBottomView.textColor = [Utility getUIColor:kUIColorFontDark];
    [labelHeaderBottomView setUIFont:kUIFontType16 isBold:false];
    [labelHeaderBottomView setText:[NSString stringWithFormat:@"%@ : %d", Localize(@"Minimum Quantity"), minValue]];
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        [labelHeaderBottomView setText:[NSString stringWithFormat:@"%d : %@", minValue, Localize(@"Minimum Quantity")]];
    }
    [Utility showShadow:_viewForMinQuantity];
}
- (void)createOpinionView {
    float _heightRectBottomView, _buttonWishlistWidth,_buttonCartWidth ,_buttonHeight , _gapBetweenButton, _viewWidth, _buttonBuyWidth;
    
    if ([[MyDevice sharedManager] isIpad]) {
        _viewWidth = self.view.frame.size.width * (1.0f - 0.02f);
    }else{
        _viewWidth = self.view.frame.size.width * (1.0f - 0.0f);
    }
    float width = _viewWidth;//[[MyDevice sharedManager] screenWidthInPortrait];
    
    if ([[MyDevice sharedManager] isIpad]) {
        _gapBetweenButton = width * 0.02f;
        _buttonBuyWidth = width * 0.6f - _gapBetweenButton - self.view.frame.size.width * .01f;
        _buttonWishlistWidth = width * 0.2f - _gapBetweenButton/2 - self.view.frame.size.width * .005f;
        _buttonCartWidth = width * 0.2f - _gapBetweenButton/2 - self.view.frame.size.width * .005f;
        _buttonHeight = [[MyDevice sharedManager] screenWidthInPortrait] * 0.1f;
        _gapBetweenButton = width * 0.0f;
        _heightRectBottomView = _buttonHeight * 1.25f;
    } else {
        //        _gapBetweenButton = width * 0.02f;
        //        _buttonBuyWidth = width * 0.5f - _gapBetweenButton - self.view.frame.size.width * .01f;
        //        _buttonWishlistWidth = width * 0.25f - _gapBetweenButton/2 - self.view.frame.size.width * .005f;
        //        _buttonCartWidth = width * 0.25f - _gapBetweenButton/2 - self.view.frame.size.width * .005f;
        //        _buttonHeight = [[MyDevice sharedManager] screenWidthInPortrait] * 0.125f;
        //        _gapBetweenButton = width * 0.0f;
        //        _heightRectBottomView = _buttonHeight * 1.25f;
        
        _buttonBuyWidth = width * 0.5f;
        _buttonWishlistWidth = width * 0.25f;
        _buttonCartWidth = width * 0.25f;
        _buttonHeight = [[MyDevice sharedManager] screenWidthInPortrait] * 0.125f;
        _gapBetweenButton = width * 0.00f;
        _heightRectBottomView = _buttonHeight * 1.0f;
    }
    CGRect rectBottomView;
    
    if ([[MyDevice sharedManager] isIpad]) {
        rectBottomView = CGRectMake(self.view.frame.size.width * .01f, self.view.frame.size.width * .01f, _viewWidth, _heightRectBottomView);
    }else{
        rectBottomView = CGRectMake(0, self.view.frame.size.width * .01f, _viewWidth, _heightRectBottomView);
    }
    UIView* viewBottom = [[UIView alloc] initWithFrame:rectBottomView];
    viewBottom.backgroundColor = [UIColor whiteColor];
    [_scrollView addSubview:viewBottom];
    [_viewsAdded addObject:viewBottom];
    [viewBottom setTag:kTagForGlobalSpacing];
    if ([[MyDevice sharedManager] isIphone]) {
        [viewBottom.layer setBorderColor:[[Utility getUIColor:kUIColorBuyButtonNormalBg] CGColor]];
        [viewBottom.layer setBorderWidth:1];
    }
    
    
    //elements in bottomView
    {
        float buttonBuyWidth = _buttonBuyWidth;
        float buttonWishlistWidth = _buttonWishlistWidth;
        float buttonCartWidth = _buttonCartWidth;
        float gapBetweenButton = _gapBetweenButton;
        float totalWidth = buttonBuyWidth + gapBetweenButton + buttonWishlistWidth + gapBetweenButton + buttonCartWidth;
        float buttonWishlistPosX = (viewBottom.frame.size.width - totalWidth) / 2.0f;
        float buttonCartPosX = buttonWishlistPosX + buttonWishlistWidth + gapBetweenButton;
        float buttonBuyPosX = buttonCartPosX + buttonCartWidth + gapBetweenButton;
        float buttonHeight = _buttonHeight;
        float buttonPosY = viewBottom.frame.size.height * 0.5f - buttonHeight / 2;
        float edgeSize = buttonHeight * .20f;
        
        _buttonOpinion = [[UIButton alloc] initWithFrame:CGRectMake(buttonBuyPosX, buttonPosY, buttonBuyWidth, buttonHeight)];
        [_buttonOpinion setBackgroundColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
        [[_buttonOpinion titleLabel] setUIFont:kUIFontType22 isBold:false];
        [_buttonOpinion setTitle:Localize(@"menu_title_opinion") forState:UIControlStateNormal];
        [_buttonOpinion setTitleColor:[Utility getUIColor:kUIColorBuyButtonFont] forState:UIControlStateNormal];
        [viewBottom addSubview:_buttonOpinion];
        [_buttonOpinion addTarget:self action:@selector(opinionProduct:) forControlEvents:UIControlEventTouchUpInside];
        _buttonOpinion.layer.borderColor = [Utility getUIColor:kUIColorBuyButtonNormalBg].CGColor;
        _buttonOpinion.layer.borderWidth = 1;
        UIImage* whatsappLogo = [UIImage imageNamed:@"whatsappLogo"];
        [_buttonOpinion setUIImage:whatsappLogo forState:UIControlStateNormal];
        [_buttonOpinion.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_buttonOpinion setImageEdgeInsets:UIEdgeInsetsMake(edgeSize, 0, edgeSize, 0)];
        [_buttonOpinion setTitleEdgeInsets:UIEdgeInsetsMake(edgeSize, edgeSize, edgeSize, 0)];
        
        
        
        UIView* viewForLikeAndDislike = [[UIView alloc] initWithFrame:CGRectMake(buttonWishlistPosX, buttonPosY, buttonWishlistWidth+ buttonCartWidth, buttonHeight)];
        viewForLikeAndDislike.backgroundColor = [UIColor whiteColor];
        [viewBottom addSubview:viewForLikeAndDislike];
        [viewForLikeAndDislike.layer setBorderColor:[[Utility getUIColor:kUIColorBorder] CGColor]];
        //        [viewForLikeAndDislike.layer setBorderWidth:1];
        
        
        
        _buttonLike = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonWishlistWidth, buttonHeight)];
        [viewForLikeAndDislike addSubview:_buttonLike];
        //        _buttonLike = [[UIButton alloc] initWithFrame:CGRectMake(buttonWishlistPosX, buttonPosY, buttonWishlistWidth, buttonHeight)];
        //        [viewBottom addSubview:_buttonLike];
        UIImage* imgLike = [UIImage imageNamed:@"icon_like"];
        UIImage* disableWL = [imgLike imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_buttonLike setUIImage:disableWL forState:UIControlStateNormal];
        [_buttonLike setImageEdgeInsets:UIEdgeInsetsMake(edgeSize, 0, edgeSize, edgeSize/4)];
        [_buttonLike setTitleEdgeInsets:UIEdgeInsetsMake(edgeSize, edgeSize/4, edgeSize, 0)];
        [_buttonLike.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [[_buttonLike titleLabel] setUIFont:kUIFontType16 isBold:false];
        [_buttonLike setEnabled:false];
        
        
        _buttonDislike = [[UIButton alloc] initWithFrame:CGRectMake(buttonWishlistWidth, 0, buttonCartWidth, buttonHeight)];
        [viewForLikeAndDislike addSubview:_buttonDislike];
        UIImage* imgDislike = [UIImage imageNamed:@"icon_dislike"];
        UIImage* disableC = [imgDislike imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_buttonDislike setUIImage:disableC forState:UIControlStateNormal];
        [_buttonDislike setImageEdgeInsets:UIEdgeInsetsMake(edgeSize, 0, edgeSize, edgeSize/4)];
        [_buttonDislike setTitleEdgeInsets:UIEdgeInsetsMake(edgeSize, edgeSize/4, edgeSize, 0)];
        [_buttonDislike.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [[_buttonDislike titleLabel] setUIFont:kUIFontType16 isBold:false];
        [_buttonDislike setEnabled:false];
        
        
        [_buttonDislike setTintColor:[Utility getUIColor:kUIColorWishlistSelected]];
        [_buttonLike setTintColor:[Utility getUIColor:kUIColorCartSelected]];
        [_buttonLike setTitleColor:[Utility getUIColor:kUIColorFontLight] forState:UIControlStateNormal];
        [_buttonDislike setTitleColor:[Utility getUIColor:kUIColorFontLight] forState:UIControlStateNormal];
        
        _buttonDislike.layer.borderColor = [Utility getUIColor:kUIColorBuyButtonNormalBg].CGColor;
        _buttonLike.layer.borderColor = [Utility getUIColor:kUIColorBuyButtonNormalBg].CGColor;
    }
    if ([[MyDevice sharedManager] isIpad]) {
        [Utility showShadow:viewBottom];
    }
}
- (void)createWhatsappSharingView {
    float _heightRectBottomView, _buttonWishlistWidth,_buttonCartWidth ,_buttonHeight , _gapBetweenButton, _viewWidth, _buttonBuyWidth;
    
    if ([[MyDevice sharedManager] isIpad]) {
        _viewWidth = self.view.frame.size.width * (1.0f - 0.02f);
    }else{
        _viewWidth = self.view.frame.size.width * (1.0f - 0.0f);
    }
    float width = _viewWidth;//[[MyDevice sharedManager] screenWidthInPortrait];
    
    if ([[MyDevice sharedManager] isIpad]) {
        _gapBetweenButton = width * 0.02f;
        _buttonBuyWidth = width * 0.6f - _gapBetweenButton - self.view.frame.size.width * .01f;
        _buttonWishlistWidth = width * 0.2f - _gapBetweenButton/2 - self.view.frame.size.width * .005f;
        _buttonCartWidth = width * 0.2f - _gapBetweenButton/2 - self.view.frame.size.width * .005f;
        _buttonHeight = [[MyDevice sharedManager] screenWidthInPortrait] * 0.1f;
        _gapBetweenButton = width * 0.0f;
        _heightRectBottomView = _buttonHeight * 1.25f;
    } else {
        
        _buttonBuyWidth = width * 0.5f;
        _buttonWishlistWidth = width * 0.25f;
        _buttonCartWidth = width * 0.25f;
        _buttonHeight = [[MyDevice sharedManager] screenWidthInPortrait] * 0.125f;
        _gapBetweenButton = width * 0.00f;
        _heightRectBottomView = _buttonHeight * 1.0f;
    }
    CGRect rectBottomView;
    
    if ([[MyDevice sharedManager] isIpad]) {
        rectBottomView = CGRectMake(self.view.frame.size.width * .01f, self.view.frame.size.width * .01f, _viewWidth, _heightRectBottomView);
    }else{
        rectBottomView = CGRectMake(0, self.view.frame.size.width * .01f, _viewWidth, _heightRectBottomView);
    }
    UIView* viewBottom = [[UIView alloc] initWithFrame:rectBottomView];
    viewBottom.backgroundColor = [UIColor whiteColor];
    [_scrollView addSubview:viewBottom];
    [_viewsAdded addObject:viewBottom];
    [viewBottom setTag:kTagForGlobalSpacing];
    if ([[MyDevice sharedManager] isIphone]) {
        [viewBottom.layer setBorderColor:[[Utility getUIColor:kUIColorBuyButtonNormalBg] CGColor]];
        [viewBottom.layer setBorderWidth:1];
    }
    
    
    //elements in bottomView
    {
        float buttonBuyWidth = _buttonBuyWidth;
        float buttonWishlistWidth = _buttonWishlistWidth;
        float buttonCartWidth = _buttonCartWidth;
        float gapBetweenButton = _gapBetweenButton;
        float totalWidth = buttonBuyWidth + gapBetweenButton + buttonWishlistWidth + gapBetweenButton + buttonCartWidth;
        float buttonWishlistPosX = (viewBottom.frame.size.width - totalWidth) / 2.0f;
        float buttonCartPosX = buttonWishlistPosX + buttonWishlistWidth + gapBetweenButton;
        float buttonBuyPosX = buttonCartPosX + buttonCartWidth + gapBetweenButton;
        float buttonHeight = _buttonHeight;
        float buttonPosY = viewBottom.frame.size.height * 0.5f - buttonHeight / 2;
        float edgeSize = buttonHeight * .20f;
        
        _buttonWhatsAppShare = [[UIButton alloc] initWithFrame:CGRectMake(buttonBuyPosX, buttonPosY, buttonBuyWidth, buttonHeight)];
        [_buttonWhatsAppShare setBackgroundColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
        [[_buttonWhatsAppShare titleLabel] setUIFont:kUIFontType22 isBold:false];
        [_buttonWhatsAppShare setTitle:Localize(@"share") forState:UIControlStateNormal];
        [_buttonWhatsAppShare setTitleColor:[Utility getUIColor:kUIColorBuyButtonFont] forState:UIControlStateNormal];
        [viewBottom addSubview:_buttonWhatsAppShare];
        [_buttonWhatsAppShare addTarget:self action:@selector(whatsAppSharing:) forControlEvents:UIControlEventTouchUpInside];
        _buttonWhatsAppShare.layer.borderColor = [Utility getUIColor:kUIColorBuyButtonNormalBg].CGColor;
        _buttonWhatsAppShare.layer.borderWidth = 1;
        UIImage* whatsappLogo = [UIImage imageNamed:@"whatsappLogo"];
        [_buttonWhatsAppShare setUIImage:whatsappLogo forState:UIControlStateNormal];
        [_buttonWhatsAppShare.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_buttonWhatsAppShare setImageEdgeInsets:UIEdgeInsetsMake(edgeSize, 0, edgeSize, 0)];
        [_buttonWhatsAppShare setTitleEdgeInsets:UIEdgeInsetsMake(edgeSize, edgeSize, edgeSize, 0)];
        
        UIView* viewForLikeAndDislike = [[UIView alloc] initWithFrame:CGRectMake(buttonWishlistPosX, buttonPosY, buttonWishlistWidth+ buttonCartWidth, buttonHeight)];
        viewForLikeAndDislike.backgroundColor = [UIColor whiteColor];
        [viewBottom addSubview:viewForLikeAndDislike];
        [viewForLikeAndDislike.layer setBorderColor:[[Utility getUIColor:kUIColorBorder] CGColor]];
        UILabel*shareInWhatsApp= [[UILabel alloc] init];
        [shareInWhatsApp setUIFont:kUIFontType22 isBold:false];
        shareInWhatsApp.textAlignment = UITextAlignmentCenter;
        
        [shareInWhatsApp setTextColor:[Utility getUIColor:kUIColorFontLight]];
        [shareInWhatsApp setText:[NSString stringWithFormat:@"%@",Localize(@"share_via_whatsapp")]];
        [viewForLikeAndDislike addSubview:shareInWhatsApp];
        shareInWhatsApp.backgroundColor =[UIColor whiteColor];
        shareInWhatsApp.frame = CGRectMake(0, 0, viewForLikeAndDislike.frame.size.width, buttonHeight);
        _buttonLike = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonWishlistWidth, buttonHeight)];
        [viewForLikeAndDislike addSubview:_buttonLike];
        [_buttonDislike setTintColor:[Utility getUIColor:kUIColorWishlistSelected]];
        [_buttonLike setTintColor:[Utility getUIColor:kUIColorCartSelected]];
        [_buttonLike setTitleColor:[Utility getUIColor:kUIColorFontLight] forState:UIControlStateNormal];
        [_buttonDislike setTitleColor:[Utility getUIColor:kUIColorFontLight] forState:UIControlStateNormal];
        
        _buttonDislike.layer.borderColor = [Utility getUIColor:kUIColorBuyButtonNormalBg].CGColor;
        _buttonLike.layer.borderColor = [Utility getUIColor:kUIColorBuyButtonNormalBg].CGColor;
    }
    if ([[MyDevice sharedManager] isIpad]) {
        [Utility showShadow:viewBottom];
    }
}

#if ENABLE_SELLER_LOC_PRODUCT_PAGE
- (void)createMapView {
    if (SHOP_SETTINGS && SHOP_SETTINGS.show_location) {
        ProductInfo* pInfo = self.currentItem.pInfo;
        SellerInfo* sInfo = pInfo.sellerInfo;
        if (sInfo == nil || (sInfo.shopLatitude <= 0 && sInfo.shopLongitude <= 0)) {
            return;
        }
        _productMapView = [[UIView alloc] init];
        _productMapView.backgroundColor = [UIColor whiteColor];
        _productMapView.frame = CGRectMake(self.view.frame.size.width * 0.01f, self.view.frame.size.width * 0.01f, self.view.frame.size.width * 0.98f, 300);
        [_scrollView addSubview:_productMapView];
        [_viewsAdded addObject:_productMapView];
        [_productMapView setTag:kTagForGlobalSpacing];
        UILabel* labelHeaderTopView = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width * 0.02f, self.view.frame.size.width * 0.02f, self.view.frame.size.width * 0.96f, 250)];
        [_productMapView addSubview:labelHeaderTopView];
        [labelHeaderTopView setUIFont:kUIFontType20 isBold:false];
        labelHeaderTopView.text = Localize(@"location");
        labelHeaderTopView.textColor = [Utility getUIColor:kUIColorFontDark];
        [labelHeaderTopView sizeToFitUI];
        _mapView.backgroundColor = [UIColor grayColor];
        
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
        _mapView.frame = CGRectMake(self.view.frame.size.width * 0.01f, self.view.frame.size.width * 0.06f, self.view.frame.size.width * 0.96f, 250);
        }else{
        _mapView.frame = CGRectMake(self.view.frame.size.width * 0.01f, self.view.frame.size.width * 0.08f, self.view.frame.size.width * 0.96f, 250);
        }
        
        
        [_productMapView addSubview:_mapView];
        [_mapView setTag:kTagForGlobalSpacing];
        _mapView.settings.scrollGestures = NO;
        _mapView.settings.zoomGestures = NO;
        UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width * 0.01f, self.view.frame.size.width * 0.06f, self.view.frame.size.width * 0.96f, 250)];
        [button setBackgroundColor:[UIColor clearColor]];
        [_productMapView addSubview:button];
        [button addTarget:self action:@selector(handleMapTap:) forControlEvents:UIControlEventTouchUpInside];
        _productMapView.frame = CGRectMake(self.view.frame.size.width * 0.01f, self.view.frame.size.width * 0.02f, self.view.frame.size.width * 0.98f, 300);
        [Utility showShadow:_productMapView];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
        }
    }
}
#endif

- (void)createAttributesView {
    
    if (PRODUCT_DETAILS_CONFIG.show_additional_info) {
        if ([_currentItem.pInfo._extraAttributes count]) {
            _productAttributesView = [[UIView alloc] init];
            _productAttributesView.backgroundColor = [UIColor whiteColor];
            _productAttributesView.frame = CGRectMake(self.view.frame.size.width * 0.01f, self.view.frame.size.width * 0.01f, self.view.frame.size.width * 0.98f, 300);
            [_scrollView addSubview:_productAttributesView];
            [_viewsAdded addObject:_productAttributesView];
            [_productAttributesView setTag:kTagForGlobalSpacing];
            
            UILabel* labelHeaderTopView = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width * 0.02f, self.view.frame.size.width * 0.01f, self.view.frame.size.width * 0.96f, 250)];
            [_productAttributesView addSubview:labelHeaderTopView];
            [labelHeaderTopView setUIFont:kUIFontType20 isBold:false];
            labelHeaderTopView.text = Localize(@"title_additional_information");
            labelHeaderTopView.textColor = [Utility getUIColor:kUIColorFontDark];
            [labelHeaderTopView sizeToFitUI];
            
            _productExtraAttributesTable = [[UITableView alloc] initWithFrame:CGRectMake( self.view.frame.size.width * 0.02f, self.view.frame.size.width * 0.06f, self.view.frame.size.width * 0.96f,40.0f*([_currentItem.pInfo._extraAttributes count])) style:UITableViewStylePlain];
            _productExtraAttributesTable.separatorStyle = UITableViewCellSeparatorStyleNone;
            [_productExtraAttributesTable registerNib:[UINib nibWithNibName:@"ProductAttributCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ProductAttributCell"];
            _productExtraAttributesTable.delegate = self;
            _productExtraAttributesTable.dataSource = self;
            [_productAttributesView addSubview:_productExtraAttributesTable];
            [_productExtraAttributesTable setNeedsDisplay];
            _productAttributesView.frame = CGRectMake(self.view.frame.size.width * 0.01f, self.view.frame.size.width * 0.02f, self.view.frame.size.width * 0.98f, CGRectGetMaxY(_productExtraAttributesTable.frame) + self.view.frame.size.width * 0.02f);
            [Utility showShadow:_productAttributesView];
            [_productExtraAttributesTable reloadData];
        }
    }
}

- (void)createDetailView {
    _productDetailView = [[UIView alloc] init];
    _productDetailView.backgroundColor = [UIColor whiteColor];
    _productDetailView.frame = CGRectMake(self.view.frame.size.width * 0.01f, self.view.frame.size.width * 0.01f, self.view.frame.size.width * 0.98f, 250);
    [_scrollView addSubview:_productDetailView];
    [_viewsAdded addObject:_productDetailView];
    [_productDetailView setTag:kTagForGlobalSpacing];
    
    UILabel* labelHeaderTopView = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width * 0.02f, self.view.frame.size.width * 0.02f, self.view.frame.size.width * 0.96f, 250)];
    [_productDetailView addSubview:labelHeaderTopView];
    [labelHeaderTopView setUIFont:kUIFontType20 isBold:false];
    labelHeaderTopView.text = Localize(@"title_product_info");
    labelHeaderTopView.textColor = [Utility getUIColor:kUIColorFontDark];
    [labelHeaderTopView sizeToFitUI];
    
    UILabel* labelHeaderBottomView = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width * 0.02f, CGRectGetMaxY(labelHeaderTopView.frame) + self.view.frame.size.width * 0.01f, self.view.frame.size.width * 0.96f, 250)];
    [_productDetailView addSubview:labelHeaderBottomView];
    labelHeaderBottomView.textColor = [Utility getUIColor:kUIColorFontDark];
    labelHeaderBottomView.lineBreakMode = NSLineBreakByWordWrapping;
    labelHeaderBottomView.numberOfLines = 0;
    labelHeaderBottomView.attributedText = [_currentItem.pInfo getDescriptionAttributedString];
    [labelHeaderBottomView setUIFont:kUIFontType16 isBold:false];
    [labelHeaderBottomView sizeToFitUI];
    
    _productDetailView.frame = CGRectMake(self.view.frame.size.width * 0.01f, self.view.frame.size.width * 0.02f, self.view.frame.size.width * 0.98f, CGRectGetMaxY(labelHeaderBottomView.frame) + self.view.frame.size.width * 0.02f);
    [Utility showShadow:_productDetailView];
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        [labelHeaderBottomView setTextAlignment:NSTextAlignmentRight];
    }
}
- (void)createReviewView {
    
    if (PRODUCT_DETAILS_CONFIG.show_ratings_section == false && PRODUCT_DETAILS_CONFIG.show_reviews_section == false) {
        return;
    }
    
    if(_currentItem.pInfo._isFullRetrieved == false)
        return;
    
    if (_productReviewView) {
        for (UIView* view in _productReviewView.subviews) {
            [view removeFromSuperview];
        }
    }
    else{
        _productReviewView = [[UIView alloc] init];
        [_scrollView addSubview:_productReviewView];
        [_viewsAdded addObject:_productReviewView];
        [_productReviewView setTag:kTagForGlobalSpacing];
        _productReviewView.backgroundColor = [UIColor whiteColor];
        _productReviewView.frame = CGRectMake(self.view.frame.size.width * 0.01f, self.view.frame.size.width * 0.01f, self.view.frame.size.width * 0.98f, 250);
    }
    
    UILabel* labelHeaderTopView = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width * 0.02f, self.view.frame.size.width * 0.02f, self.view.frame.size.width * 0.96f, 250)];
    [_productReviewView addSubview:labelHeaderTopView];
    [labelHeaderTopView setUIFont:kUIFontType20 isBold:false];
    labelHeaderTopView.text = Localize(@"average_user_ratings");
    labelHeaderTopView.textColor = [Utility getUIColor:kUIColorFontDark];
    [labelHeaderTopView sizeToFitUI];
    float currentY = CGRectGetMaxY(labelHeaderTopView.frame);
    
    
    int ratingCount = _currentItem.pInfo._rating_count;
    if (ratingCount == 0 && _currentItem.pInfo._isReviewsRetrieved == true && (int)[_currentItem.pInfo._productReviews count] == 0) {
        if (PRODUCT_DETAILS_CONFIG.show_ratings_section && PRODUCT_DETAILS_CONFIG.show_reviews_section) {
            labelHeaderTopView.text = Localize(@"i_average_user_rating_review");
            [labelHeaderTopView sizeToFitUI];
            UILabel* labelNoUserRated = [[UILabel alloc] initWithFrame:CGRectMake(
                                                                                  self.view.frame.size.width * 0.04f,
                                                                                  currentY + self.view.frame.size.width * 0.02f,
                                                                                  self.view.frame.size.width * 0.96f,
                                                                                  250)];
            [_productReviewView addSubview:labelNoUserRated];
            [labelNoUserRated setUIFont:kUIFontType16 isBold:false];
            labelNoUserRated.text = Localize(@"i_no_user_review_rated");
            labelNoUserRated.textColor = [Utility getUIColor:kUIColorFontDark];
            [labelNoUserRated sizeToFitUI];
            currentY = CGRectGetMaxY(labelNoUserRated.frame);
        }
        else if (PRODUCT_DETAILS_CONFIG.show_ratings_section) {
            labelHeaderTopView.text = Localize(@"average_user_ratings");
            [labelHeaderTopView sizeToFitUI];
            UILabel* labelNoUserRated = [[UILabel alloc] initWithFrame:CGRectMake(
                                                                                  self.view.frame.size.width * 0.04f,
                                                                                  currentY + self.view.frame.size.width * 0.02f,
                                                                                  self.view.frame.size.width * 0.96f,
                                                                                  250)];
            [_productReviewView addSubview:labelNoUserRated];
            [labelNoUserRated setUIFont:kUIFontType16 isBold:false];
            labelNoUserRated.text = Localize(@"i_no_user_rated_yet");
            labelNoUserRated.textColor = [Utility getUIColor:kUIColorFontDark];
            [labelNoUserRated sizeToFitUI];
            currentY = CGRectGetMaxY(labelNoUserRated.frame);
        }
        else if (PRODUCT_DETAILS_CONFIG.show_reviews_section) {
            labelHeaderTopView.text = Localize(@"reviews");
            [labelHeaderTopView sizeToFitUI];
            UILabel* labelNoUserRated = [[UILabel alloc] initWithFrame:CGRectMake(
                                                                                  self.view.frame.size.width * 0.04f,
                                                                                  currentY + self.view.frame.size.width * 0.02f,
                                                                                  self.view.frame.size.width * 0.96f,
                                                                                  250)];
            [_productReviewView addSubview:labelNoUserRated];
            [labelNoUserRated setUIFont:kUIFontType16 isBold:false];
            labelNoUserRated.text = Localize(@"No user reviews yet.");
            labelNoUserRated.textColor = [Utility getUIColor:kUIColorFontDark];
            [labelNoUserRated sizeToFitUI];
            currentY = CGRectGetMaxY(labelNoUserRated.frame);
        }
    }
    else {
        
        if (PRODUCT_DETAILS_CONFIG.show_ratings_section == false) {
            labelHeaderTopView.text = Localize(@"");
            currentY = 0;
        }
        
        
        if (PRODUCT_DETAILS_CONFIG.show_ratings_section) {
            if (ratingCount) {
                float ratingStars = _currentItem.pInfo._average_rating;
                float tempRatingStars = _currentItem.pInfo._average_rating;
                UIImageView* bgImg[5];
                UIImageView* fgImg[5];
                for (int i = 0; i < 5; i++) {
                    UIImage *progressImage = [UIImage imageNamed:@"starOn"];
                    UIImage *trackImage = [UIImage imageNamed:@"starOff"];
                    
                    bgImg[i] = [[UIImageView alloc] initWithImage:trackImage];
                    [bgImg[i] setFrame:CGRectMake(self.view.frame.size.width * 0.02f +  progressImage.size.width * i, CGRectGetMaxY(labelHeaderTopView.frame) + self.view.frame.size.width * 0.01f, progressImage.size.width, progressImage.size.height)];
                    [_productReviewView addSubview:bgImg[i]];
                    
                    CGRect cropRect;
                    if (tempRatingStars > 1) {
                        cropRect = CGRectMake(0, 0, progressImage.size.width * 1.0f, progressImage.size.height);
                        tempRatingStars--;
                    } else if(tempRatingStars > 0) {
                        cropRect = CGRectMake(0, 0, progressImage.size.width * tempRatingStars, progressImage.size.height);
                        tempRatingStars = 0;
                    } else {
                        cropRect = CGRectMake(0, 0, progressImage.size.width * 0.0f, progressImage.size.height);
                    }
                    
                    CGImageRef imageRef = CGImageCreateWithImageInRect([progressImage CGImage], cropRect);
                    UIImage* image = [UIImage imageWithCGImage:imageRef];
                    CGImageRelease(imageRef);
                    fgImg[i] = [[UIImageView alloc] initWithImage:image];
                    [fgImg[i] setFrame:CGRectMake(self.view.frame.size.width * 0.02f +  progressImage.size.width * i, CGRectGetMaxY(labelHeaderTopView.frame) + self.view.frame.size.width * 0.01f, image.size.width, progressImage.size.height)];
                    [fgImg[i] setContentMode:UIViewContentModeScaleAspectFit];
                    [_productReviewView addSubview:fgImg[i]];
                }
                UILabel* labelRatingStars = [[UILabel alloc] initWithFrame:CGRectMake(
                                                                                      CGRectGetMaxX(bgImg[4].frame) + self.view.frame.size.width * 0.02f,
                                                                                      CGRectGetMaxY(bgImg[4].frame) - bgImg[4].frame.size.height * 0.5f,
                                                                                      self.view.frame.size.width * 0.96f,
                                                                                      250)];
                [_productReviewView addSubview:labelRatingStars];
                [labelRatingStars setUIFont:kUIFontType20 isBold:false];
                labelRatingStars.text = [NSString stringWithFormat:@"%.1f/5.0", ratingStars];
                labelRatingStars.textColor = [Utility getUIColor:kUIColorFontDark];
                [labelRatingStars sizeToFitUI];
                
                currentY = CGRectGetMaxY(bgImg[4].frame);
            }
            else {
                UILabel* labelNoUserRated = [[UILabel alloc] initWithFrame:CGRectMake(
                                                                                      self.view.frame.size.width * 0.04f,
                                                                                      currentY + self.view.frame.size.width * 0.02f,
                                                                                      self.view.frame.size.width * 0.96f,
                                                                                      250)];
                [_productReviewView addSubview:labelNoUserRated];
                [labelNoUserRated setUIFont:kUIFontType16 isBold:false];
                labelNoUserRated.text = Localize(@"i_no_user_rated_yet");
                labelNoUserRated.textColor = [Utility getUIColor:kUIColorFontDark];
                [labelNoUserRated sizeToFitUI];
                currentY = CGRectGetMaxY(labelNoUserRated.frame);
            }
        }
        if (PRODUCT_DETAILS_CONFIG.show_reviews_section) {
            UILabel* labelHeaderBottomView = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width * 0.02f, currentY + self.view.frame.size.width * 0.04f, self.view.frame.size.width * 0.96f, 250)];
            [_productReviewView addSubview:labelHeaderBottomView];
            [labelHeaderBottomView setUIFont:kUIFontType20 isBold:false];
            labelHeaderBottomView.text = Localize(@"reviews");
            labelHeaderBottomView.textColor = [Utility getUIColor:kUIColorFontDark];
            [labelHeaderBottomView sizeToFitUI];
            currentY = CGRectGetMaxY(labelHeaderBottomView.frame);
            
            if (_currentItem.pInfo._isReviewsRetrieved /* && _currentItem.pInfo._reviews_allowed */) {
                if ((int)[_currentItem.pInfo._productReviews count] > 0) {
                    float initX = self.view.frame.size.width * 0.02f;
                    float initY = self.view.frame.size.width * 0.01f + CGRectGetMaxY(labelHeaderBottomView.frame);
                    float initW = self.view.frame.size.width * 0.96f;
                    float initH = self.view.frame.size.width * 0.02f;
                    float initD = self.view.frame.size.width * 0.02f;
                    currentY = initY;
                    //    int rViewCount = 0;
                    for (ProductReview* pReview in _currentItem.pInfo._productReviews) {
                        UILabel* lName = [[UILabel alloc] initWithFrame:CGRectMake(initX, currentY, initW, initH)];
                        [_productReviewView addSubview:lName];
                        [lName setUIFont:kUIFontType18 isBold:true];
                        lName.text = pReview._reviewer_name;
                        lName.textColor = [Utility getUIColor:kUIColorFontDark];
                        [lName sizeToFitUI];
                        
                        UILabel* lDate = [[UILabel alloc] initWithFrame:CGRectMake(initX, CGRectGetMaxY( lName.frame), initW, initH)];
                        [_productReviewView addSubview:lDate];
                        [lDate setUIFont:kUIFontType14 isBold:false];
                        NSDate* date = pReview._created_at;
                        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                        [dateFormat setDateFormat:@"MMMM dd, YYYY"];
                        NSString* temp = [dateFormat stringFromDate:date];
                        
                        lDate.text = temp;
                        lDate.textColor = [Utility getUIColor:kUIColorFontDark];
                        [lDate sizeToFitUI];
                        
                        UILabel* lReview = [[UILabel alloc] initWithFrame:CGRectMake(initX, CGRectGetMaxY( lDate.frame), initW, initH)];
                        [_productReviewView addSubview:lReview];
                        [lReview setUIFont:kUIFontType16 isBold:false];
                        lReview.text = pReview._review;
                        lReview.textColor = [Utility getUIColor:kUIColorFontDark];
                        lReview.lineBreakMode = NSLineBreakByWordWrapping;
                        lReview.numberOfLines = 0;
                        [lReview sizeToFitUI];
                        currentY = CGRectGetMaxY(lReview.frame) + initD;
                    }
                }
                else {
                    UILabel* labelNoUserRated = [[UILabel alloc] initWithFrame:CGRectMake(
                                                                                          self.view.frame.size.width * 0.04f,
                                                                                          currentY + self.view.frame.size.width * 0.02f,
                                                                                          self.view.frame.size.width * 0.96f,
                                                                                          250)];
                    [_productReviewView addSubview:labelNoUserRated];
                    [labelNoUserRated setUIFont:kUIFontType16 isBold:false];
                    labelNoUserRated.text = Localize(@"i_no_user_review_yet");
                    labelNoUserRated.textColor = [Utility getUIColor:kUIColorFontDark];
                    [labelNoUserRated sizeToFitUI];
                    currentY = CGRectGetMaxY(labelNoUserRated.frame);
                }
            }
            else {
                UILabel* labelNoUserRated = [[UILabel alloc] initWithFrame:CGRectMake(
                                                                                      self.view.frame.size.width * 0.04f,
                                                                                      currentY + self.view.frame.size.width * 0.02f,
                                                                                      self.view.frame.size.width * 0.96f,
                                                                                      250)];
                [_productReviewView addSubview:labelNoUserRated];
                [labelNoUserRated setUIFont:kUIFontType16 isBold:false];
                labelNoUserRated.text = Localize(@"i_fetching_reviews");
                labelNoUserRated.textColor = [Utility getUIColor:kUIColorFontDark];
                [labelNoUserRated sizeToFitUI];
                currentY = CGRectGetMaxY(labelNoUserRated.frame);
            }
        }
    }
    
    
    
    
    _productReviewView.frame = CGRectMake(self.view.frame.size.width * 0.01f, self.view.frame.size.width * 0.02f, self.view.frame.size.width * 0.98f, currentY + self.view.frame.size.width * 0.02f);
    [_productReviewView.layer setShadowOpacity:0.0f];
    
    [Utility showShadow:_productReviewView];
    PRINT_RECT_STR(@"labelHeaderTopView", labelHeaderTopView.frame);
}
- (SelectionView *)createSelectionView:(int)viewId isFullLength:(BOOL)isFullLength origin:(CGPoint)origin viewHeight:(float)viewHeight {
    float _selectionViewHeight, _gapping, _buttonHeight, _buttonExtraWidth, _viewWidth;
    _viewWidth = self.view.frame.size.width * (1.0f - 0.02f);
    _selectionViewHeight = viewHeight;
    _gapping = _viewWidth * 0.02f;
    float varW;
    varW = 5.0f;
    _buttonExtraWidth = _gapping + varW*2;
    _buttonHeight = viewHeight / 1.5f;
    
    SelectionView* selectionView = [[SelectionView alloc] init];
    selectionView.vcProduct = self;
    selectionView.backgroundColor = [UIColor whiteColor];
    
    Attribute* attribute = (Attribute*)[_currentItem.pInfo._attributes objectAtIndex:viewId];
    selectionView.attribute = attribute;
    selectionView.attributeSelectedValue = [attribute._options objectAtIndex:0];
    selectionView.selectedVariation = _selectedVariation;
    selectionView.selectedVariationAttibutes = _selectedVariationAttibutes;
    selectionView.viewId = viewId;
    selectionView.pInfo = _currentItem.pInfo;
    
    int clickedItemId = 0;
    if (_currentItem.variationId != -1) {
        NSString* attributeName = [NSString stringWithFormat:@"%@", attribute._name];
        NSString* attributeSlug = [NSString stringWithFormat:@"%@", attribute._slug];
        for (VariationAttribute* varAttribute in _selectedVariation._attributes) {
            NSString* varAttributeName = [NSString stringWithFormat:@"%@", varAttribute.name];
            NSString* varAttributeSlug = [NSString stringWithFormat:@"%@", varAttribute.slug];
            
            if ([Utility compareAttributeNames:attributeSlug name2:varAttributeSlug]) {
                
                NSString* varAttributeValue = [NSString stringWithFormat:@"%@", varAttribute.value];
                if ([varAttributeValue isEqualToString:@""]) {
                    for (VariationAttribute* varAttributeSelected in _selectedVariationAttibutes) {
                        NSString* varAttributeNameSelected = [NSString stringWithFormat:@"%@", varAttributeSelected.name];
                        NSString* varAttributeSlugSelected = [NSString stringWithFormat:@"%@", varAttributeSelected.slug];
                        if ([Utility compareAttributeNames:attributeSlug name2:varAttributeSlugSelected]) {
                            varAttributeValue = varAttributeSelected.value;
                            NSLog(@"changed");
                            break;
                        }
                    }
                }
                
                
                
                for (NSString* option in attribute._options) {
                    NSString* attributeOptionValue = [NSString stringWithFormat:@"%@", option];
                    if ([Utility compareAttributeNames:attributeOptionValue name2:varAttributeValue]) {
                        selectionView.attributeSelectedValue = option;
                        break;
                    }
                    clickedItemId++;
                }
                break;
            }
        }
    }
    
    NSString* stringTitle = [NSString stringWithString:attribute._name];
    [selectionView loadView:[[NSMutableArray alloc] initWithArray:[attribute getOptions]]];
    [selectionView setFrame:CGRectMake(origin.x, origin.y, _viewWidth, _selectionViewHeight)];
    [selectionView.label setText:[Utility getNormalStringFromAttributed:stringTitle]];
    [selectionView setParentViewForDropDownView:_scrollView];
    [selectionView.label setTextColor:[Utility getUIColor:kUIColorFontDark]];
    [selectionView.label setUIFont:kUIFontType18 isBold:true];
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        [selectionView.label setTextAlignment:NSTextAlignmentRight];
    }
    CGSize labelSize = LABEL_SIZE(selectionView.label);
    float labelWidth = labelSize.width;
    UILabel* tempLabel = [[UILabel alloc] init];
    [tempLabel setUIFont:kUIFontType18 isBold:false];
    [tempLabel setText:Localize(@"i_select")];
    float buttonDefaultWidth = LABEL_SIZE(tempLabel).width;
    float buttonWidth = 0;
    for (NSString* nsStr in [attribute getOptions]) {
        [tempLabel setText:nsStr];
        buttonWidth = MAX(buttonWidth, LABEL_SIZE(tempLabel).width);
    }
    buttonWidth = MAX(buttonWidth, buttonDefaultWidth);
    buttonWidth += _buttonExtraWidth;
    buttonWidth = MAX(buttonWidth, _buttonHeight);
    buttonWidth = MIN(buttonWidth, self.view.frame.size.width * .8f);
    float selectionButtonWidthMax = _viewWidth * 0.15f;
    if (buttonWidth < selectionButtonWidthMax) {
        buttonWidth = selectionButtonWidthMax;
    }
    _buttonHeight = [[MyDevice sharedManager] screenWidthInPortrait] * 0.075f;
    [selectionView.button setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [selectionView.button setTitle:[Utility getNormalStringFromAttributed:[[attribute getOptions] objectAtIndex:0]] forState:UIControlStateNormal];
    [selectionView.button.titleLabel setUIFont:kUIFontType14 isBold:false];
    [Utility showShadow:selectionView.button];
    float gapping = _gapping;
    float viewWidth = selectionView.frame.size.width;
    float totalWidth = labelWidth + gapping + buttonWidth;
    float labelPosX = (viewWidth - totalWidth)/2;
    float buttonPosX = labelPosX + labelWidth + gapping;
    float height = _buttonHeight;
    float posY = selectionView.frame.size.height * 0.5f - height / 2;
    gapping = self.view.frame.size.width * 0.02f;
    viewWidth = selectionView.frame.size.width;
    labelWidth = viewWidth - gapping * 2;
    buttonWidth = viewWidth - gapping * 2;
    totalWidth = labelWidth + gapping + buttonWidth;
    labelPosX = gapping;
    buttonPosX = labelPosX + labelWidth + gapping;
    height = selectionView.frame.size.height;//*.75f;//_buttonHeight;
    posY = 0;//selectionView.frame.size.height * 0.5f - height / 2;
    selectionView.button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    selectionView.button.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
    selectionView.button.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [selectionView.button.layer setBorderWidth:0];
    [selectionView.layer setBorderWidth:0.5f];
    [selectionView.layer setBorderColor:[Utility getUIColor:kUIColorBorder].CGColor];
    [selectionView.label setFrame:CGRectMake(labelPosX, posY, labelWidth, [selectionView.label.font lineHeight])];
    [selectionView.button setFrame:CGRectMake(labelPosX, posY, buttonWidth, [selectionView.label.font lineHeight]+ [selectionView.button.titleLabel.font lineHeight])];
    
    
    posY = height / 2  - selectionView.button.frame.size.height * 0.5f;
    [selectionView.label setFrame:CGRectMake(labelPosX, posY, labelWidth, [selectionView.label.font lineHeight])];
    [selectionView.button setFrame:CGRectMake(labelPosX, posY, buttonWidth, [selectionView.label.font lineHeight]+ [selectionView.button.titleLabel.font lineHeight])];
    [selectionView.label setTextColor:[Utility getUIColor:kUIColorFontDark]];
    [selectionView.label.superview bringSubviewToFront:selectionView.label];
    
    UIImage *img = [UIImage imageNamed:@"img_attribute_arrow_down"];
    UIButton *dropdownImg = [[UIButton alloc] init];
    [dropdownImg setUIImage:img forState:UIControlStateNormal];
    [dropdownImg setContentMode:UIViewContentModeCenter];
    [selectionView.button.superview addSubview:dropdownImg];
    [dropdownImg setBackgroundColor:[UIColor whiteColor]];
    [dropdownImg setFrame:CGRectMake(
                                     selectionView.button.frame.origin.x + selectionView.button.frame.size.width - (img.size.width + varW) - varW/2,
                                     selectionView.button.frame.origin.y,
                                     img.size.width + varW,
                                     selectionView.button.frame.size.height)];
    [dropdownImg addTarget:selectionView action:@selector(selectClickedTemp:) forControlEvents:UIControlEventTouchUpInside];
    [dropdownImg.layer setValue:selectionView.button forKey:@"MY_OBJECT"];
    return selectionView;
}
- (void)opinionProduct:(UIButton*)button {
    RLOG(@"opinionProduct:%@", _currentItem.pInfo._title);
    ProductInfo* product = _currentItem.pInfo;
    if (product._isFullRetrieved) {
        [[ParseHelper sharedManager] registerOpinionPoll:product];
    }
    return;
}
-(void)whatsAppSharing:(UIButton*)sender{
    ProductInfo* pInfo = _currentItem.pInfo;
    NSString *productUrl = [NSString stringWithFormat:@"%@/?p=%d",[[[DataManager sharedManager] tmDataDoctor] baseUrl], pInfo._id];
    
    NSLog(@"productUrl  %@",productUrl);
    
    //    [[Utility sharedManager]shareWhatsAppButtonClicked:pInfo pollId:nil productUrl:productUrl];
    
    NSString* productLinkUrl = [NSString stringWithFormat:@"%@", pInfo._permalink];
    
    NSString* textToShare =[NSString stringWithFormat:@"\n%@\n%@",
                            pInfo._title,
                            productLinkUrl
                            ];
    NSString * urlWhats = [NSString stringWithFormat:@"whatsapp://send?text=%@",textToShare];
    NSURL * whatsappURL = [NSURL URLWithString:[urlWhats stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) {
        RLOG(@"whatsappURL = %@", whatsappURL);
        [[UIApplication sharedApplication] openURL: whatsappURL];
    } else {
        
    }
}
- (void)previewDocumentWithURL:(NSURL*)url {
    UIDocumentInteractionController* preview = [UIDocumentInteractionController interactionControllerWithURL:url];
    preview.delegate = self;
    [preview presentPreviewAnimated:YES];
    
}
- (void)documentInteractionControllerDidEndPreview:(UIDocumentInteractionController *)controller {
    
}
- (void)xx:(UIAlertView *)alertView  {
    [self performSelector:@selector(dismissAlertViewAuto:) withObject:alertView afterDelay:1];
}
- (void)dismissAlertViewAuto:(UIAlertView *)alertView{
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
}
- (BOOL)checkPurchasable {
    BOOL isPurchasable = true;
    if ([[Addons sharedManager] enable_mixmatch_products]) {
        int qty = 0;
        if (_currentItem.pInfo.mMixMatch) {
            for (CartMatchedItem* cmItems in self.matchedItems) {
                qty += cmItems.quantity;
            }
            if (qty < (int)(_currentItem.pInfo.mMixMatch.container_size)) {
                //unable to purchase.
                isPurchasable = false;
                int leastSelected = (int)(_currentItem.pInfo.mMixMatch.container_size);
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"Please select %d items to continue", leastSelected] delegate:nil cancelButtonTitle:Localize(@"i_ok") otherButtonTitles:nil];
                [alertView show];
                //                [self xx:alertView];
            }
        }
    }
    return isPurchasable;
}
- (BOOL)isPrddSlotsSelected {
#if ENABLE_PRODUCT_DELIVERY_DATA_PLUGIN
    if ([[Addons sharedManager] productDeliveryDatePlugin] && [[[Addons sharedManager] productDeliveryDatePlugin] isEnabled]) {
        self.prdd = self.currentItem.pInfo.prdd;
        if (self.prdd.prdd_recurring_chk && [self.prdd.prdd_days count] > 0) {
            if (self.prdd_sDay == nil) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:Localize(@"select_delivery_date") delegate:nil cancelButtonTitle:Localize(@"i_ok") otherButtonTitles:nil];
                [alertView show];
                return false;
            }
            if (self.prdd_sDay && self.prdd_sDay.prdd_times && [self.prdd_sDay.prdd_times count] > 0){
                if(self.prdd_sTime == nil) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:Localize(@"select_delivery_time") delegate:nil cancelButtonTitle:Localize(@"i_ok") otherButtonTitles:nil];
                    [alertView show];
                    return false;
                }
            }
        }
    }
#endif
    return true;
}
- (void)visitProduct:(UIButton*)button {
    NSString* openLink = @"";
    ProductInfo* pInfo = _currentItem.pInfo;
    if (pInfo._product_url && ![pInfo._product_url isEqualToString:@""]){
        openLink = pInfo._product_url;
    }
    if (openLink && [openLink isKindOfClass:[NSString class]] && ![openLink isEqualToString:@""]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:openLink]];
    }
}
- (void)buyProduct:(UIButton*)button {
    ProductInfo* pInfo = _currentItem.pInfo;
    if (pInfo._isFullRetrieved == false) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:Localize(@"i_loading_product_data") delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
        [alertView show];
        [self xx:alertView];
        return;
    }
    
#if ENABLE_PRODUCT_DELIVERY_DATA_PLUGIN
    if ([[Addons sharedManager] productDeliveryDatePlugin] && [[[Addons sharedManager] productDeliveryDatePlugin] isEnabled]) {
        if (pInfo.prddDataFetched && (self.prdd_sDateStr == nil || [self.prdd_sDateStr isEqualToString:@""])) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:Localize(@"select_delivery_date") delegate:nil cancelButtonTitle:Localize(@"i_ok") otherButtonTitles:nil];
            [alertView show];
            return;
        }
        if (pInfo.prddDataFetched && self.prdd_sTime == nil) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:Localize(@"select_delivery_time") delegate:nil cancelButtonTitle:Localize(@"i_ok") otherButtonTitles:nil];
            [alertView show];
            return;
        }
    }
#endif
    
    
    BOOL isPrddSlotSelected = [self isPrddSlotsSelected];
    if (isPrddSlotSelected == false) {
        return;
    }
    
    RLOG(@"Button Clicked:buyProduct ie addToCart");
    [button setSelected:true];
    NSMutableArray* basicAttributes = nil;
    if (_selectionViews) {
        basicAttributes = [[NSMutableArray alloc] init];
        for (SelectionView* sv in _selectionViews) {
            BasicAttribute* ba = [[BasicAttribute alloc] init];
            ba.attributeName = sv.attribute._name;
            ba.attributeSlug = sv.attribute._slug;
            ba.attributeValue = sv.attributeSelectedValue;
            [basicAttributes addObject:ba];
        }
    }
    
    BOOL isPurchasable = false;
    if (_selectedVariation) {
        isPurchasable = _selectedVariation._purchaseable;
    }else{
        isPurchasable = pInfo._purchaseable;
    }
    if (isPurchasable == false) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Localize(@"sorry") message:Localize(@"unable_to_purchase") delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
        [alertView show];
        [self xx:alertView];
        return;
    }
    
    if ([[Addons sharedManager] show_min_max_price]) {
        for (VariationAttribute* vAttr in _selectedVariationAttibutes) {
            if([vAttr.value isEqualToString:Localize(@"i_select")]) {
                _selectedVariation = nil;
                break;
            }
        }
    }
    
    if (PRODUCT_DETAILS_CONFIG.select_variation_with_button) {
        if (_selectionViews) {
            for (SelectionView* sv in _selectionViews) {
                BOOL isButtonSelected = false;
                NSArray* buttons = sv.scrollViewLinearButton.subviews;
                for (id obj in buttons) {
                    if ([obj isKindOfClass:[UIButton class]]) {
                        UIButton* btn = obj;
                        if(btn.isSelected){
                            isButtonSelected = true;
                        }
                    }
                }
                if (isButtonSelected == false) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:Localize(@"select_all_variations") delegate:nil cancelButtonTitle:Localize(@"i_ok") otherButtonTitles:nil];
                    [alertView show];
                    return;
                }
            }
        }
    }
    
    
    
    
    if (_selectedVariation) {
        if ([self checkPurchasable] == false) {
            return;
        }
        Cart* c = [Cart addProduct:pInfo
                       variationId:_selectedVariation._id
                    variationIndex:_selectedVariation._variation_index
       selectedVariationAttributes:_selectedVariationAttibutes
                       bundleItems:self.bundleItems
                      matchedItems:self.matchedItems
                           prddDay:self.prdd_sDay
                          prddTime:self.prdd_sTime
                          prddDate:self.prdd_sDateStr
                   ];
    }
    else {
        if ([pInfo._variations count] > 0) {
            //            BOOL noSuchVariationFound = false;
            //            for (VariationAttribute* vAttr in _selectedVariationAttibutes) {
            //                if(![vAttr.value isEqualToString:Localize(@"i_select")]) {
            //                    noSuchVariationFound = true;
            //                    break;
            //                }
            //            }
            //            if (noSuchVariationFound) {
            //                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:Localize(@"Out of stock.") delegate:nil cancelButtonTitle:Localize(@"i_ok") otherButtonTitles:nil];
            //                [alertView show];
            //            }else
            //            {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:Localize(@"select_all_variations") delegate:nil cancelButtonTitle:Localize(@"i_ok") otherButtonTitles:nil];
            [alertView show];
            //            }
            return;
        }
        else {
            if ([self checkPurchasable] == false) {
                return;
            }
            Cart* c = [Cart addProduct:pInfo
                           variationId:-1
                        variationIndex:-1
           selectedVariationAttributes:nil
                           bundleItems:self.bundleItems
                          matchedItems:self.matchedItems
                               prddDay:self.prdd_sDay
                              prddTime:self.prdd_sTime
                              prddDate:self.prdd_sDateStr
                       ];
        }
    }
    
    ViewControllerMain* vcMain = [ViewControllerMain getInstance];
    if ([Utility isSellerOnlyApp] == false) {
        [vcMain btnClickedCart:vcMain];
    }
    
}
- (void)viewCart:(UIButton*)button {
    ViewControllerMain* vcMain = [ViewControllerMain getInstance];
    if ([Utility isSellerOnlyApp] == false) {
        [vcMain btnClickedCart:vcMain];
    }
}
- (void)addToCart:(UIButton*)button {
    ProductInfo* pInfo = _currentItem.pInfo;
    if (pInfo._isFullRetrieved == false) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:Localize(@"i_loading_product_data") delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
        [alertView show];
        [self xx:alertView];
        return;
    }
    
    BOOL isPrddSlotSelected = [self isPrddSlotsSelected];
    if (isPrddSlotSelected == false) {
        return;
    }
    
    
    if ([button isSelected]) {
        RLOG(@"Button Clicked:removeFormCart");
        [button setSelected:false];
        
        [button setTintColor:[Utility getUIColor:kUIColorThemeButtonNormal]];
        button.layer.borderColor = [Utility getUIColor:kUIColorBuyButtonNormalBg].CGColor;
        if (self.show_vertical_layout_components) {
            [button setTintColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
            [button setTitleColor:[Utility getUIColor:kUIColorBuyButtonNormalBg] forState:UIControlStateNormal];
            [button setTitle:Localize(@"toggle_cart_on") forState:UIControlStateNormal];
        }
        if (self.show_external_product_layout) {
            [_buttonCart setHidden:true];
        }
        
        NSMutableArray* basicAttributes = nil;
        if (_selectionViews) {
            basicAttributes = [[NSMutableArray alloc] init];
            for (SelectionView* sv in _selectionViews) {
                BasicAttribute* ba = [[BasicAttribute alloc] init];
                ba.attributeName = sv.attribute._name;
                ba.attributeSlug = sv.attribute._slug;
                ba.attributeValue = sv.attributeSelectedValue;
                [basicAttributes addObject:ba];
            }
        }
        if (_selectedVariation) {
            [Cart removeProduct:pInfo variationId:_selectedVariation._id variationIndex:_selectedVariation._variation_index];
        }else{
            
            [Cart removeProduct:pInfo variationId:-1 variationIndex:-1];
        }
        
        //        [Cart removeProduct:pInfo variationId:_selectedVariation._id];
        //        [Cart removeProduct:pInfo attributes:basicAttributes];
    }
    else{
        RLOG(@"Button Clicked:addToCart");
        //        button.layer.borderColor = [UIColor greenColor].CGColor;
        NSMutableArray* basicAttributes = nil;
        if (_selectionViews) {
            basicAttributes = [[NSMutableArray alloc] init];
            for (SelectionView* sv in _selectionViews) {
                BasicAttribute* ba = [[BasicAttribute alloc] init];
                ba.attributeName = sv.attribute._name;
                ba.attributeSlug = sv.attribute._slug;
                ba.attributeValue = sv.attributeSelectedValue;
                [basicAttributes addObject:ba];
            }
        }
        
        BOOL isPurchasable = false;
        if (_selectedVariation) {
            isPurchasable = _selectedVariation._purchaseable;
        }else{
            isPurchasable = pInfo._purchaseable;
        }
        if (isPurchasable == false) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Localize(@"sorry") message:Localize(@"unable_to_add_cart") delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
            [alertView show];
            [self xx:alertView];
            return;
        }
        
        
        
        [button setSelected:true];
        [button setTintColor:[Utility getUIColor:kUIColorCartSelected]];
        if (self.show_vertical_layout_components) {
            [button setTitleColor:[Utility getUIColor:kUIColorCartSelected] forState:UIControlStateNormal];
            [button setTitle:Localize(@"toggle_cart_off") forState:UIControlStateNormal];
        }
        if (self.show_external_product_layout) {
            [_buttonCart setHidden:true];
        }
        
        
        if ([[Addons sharedManager] show_min_max_price]) {
            for (VariationAttribute* vAttr in _selectedVariationAttibutes) {
                if([vAttr.value isEqualToString:Localize(@"i_select")]) {
                    _selectedVariation = nil;
                    break;
                }
            }
        }
        
        if (PRODUCT_DETAILS_CONFIG.select_variation_with_button) {
            if (_selectionViews) {
                for (SelectionView* sv in _selectionViews) {
                    BOOL isButtonSelected = false;
                    NSArray* buttons = sv.scrollViewLinearButton.subviews;
                    for (id obj in buttons) {
                        if ([obj isKindOfClass:[UIButton class]]) {
                            UIButton* btn = obj;
                            if(btn.isSelected){
                                isButtonSelected = true;
                            }
                        }
                    }
                    if (isButtonSelected == false) {
                        [button setSelected:false];
                        [button setTintColor:[Utility getUIColor:kUIColorThemeButtonNormal]];
                        if (self.show_vertical_layout_components) {
                            [button setTintColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
                            [button setTitleColor:[Utility getUIColor:kUIColorBuyButtonNormalBg] forState:UIControlStateNormal];
                            [button setTitle:Localize(@"toggle_cart_on") forState:UIControlStateNormal];
                        }
                        if (self.show_external_product_layout) {
                            [_buttonCart setHidden:true];
                        }
                        button.layer.borderColor = [Utility getUIColor:kUIColorBuyButtonNormalBg].CGColor;
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:Localize(@"select_all_variations") delegate:nil cancelButtonTitle:Localize(@"i_ok") otherButtonTitles:nil];
                        [alertView show];
                        return;
                    }
                }
            }
        }
        
        if (_selectedVariation) {
            if ([self checkPurchasable] == false) {
                [button setSelected:false];
                [button setTintColor:[Utility getUIColor:kUIColorThemeButtonNormal]];
                if (self.show_vertical_layout_components) {
                    [button setTintColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
                    [button setTitleColor:[Utility getUIColor:kUIColorBuyButtonNormalBg] forState:UIControlStateNormal];
                    [button setTitle:Localize(@"toggle_cart_on") forState:UIControlStateNormal];
                }
                if (self.show_external_product_layout) {
                    [_buttonCart setHidden:true];
                }
                button.layer.borderColor = [Utility getUIColor:kUIColorBuyButtonNormalBg].CGColor;
                return;
            }
            Cart* c = [Cart addProduct:pInfo
                           variationId:_selectedVariation._id
                        variationIndex:_selectedVariation._variation_index
           selectedVariationAttributes:_selectedVariationAttibutes
                           bundleItems:self.bundleItems
                          matchedItems:self.matchedItems
                               prddDay:self.prdd_sDay
                              prddTime:self.prdd_sTime
                              prddDate:self.prdd_sDateStr
                       ];
        }
        else {
            if ([pInfo._variations count] > 0) {
                [button setSelected:false];
                [button setTintColor:[Utility getUIColor:kUIColorThemeButtonNormal]];
                if (self.show_vertical_layout_components) {
                    [button setTintColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
                    [button setTitleColor:[Utility getUIColor:kUIColorBuyButtonNormalBg] forState:UIControlStateNormal];
                    [button setTitle:Localize(@"toggle_cart_on") forState:UIControlStateNormal];
                }
                if (self.show_external_product_layout) {
                    [_buttonCart setHidden:true];
                }
                button.layer.borderColor = [Utility getUIColor:kUIColorBuyButtonNormalBg].CGColor;
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:Localize(@"select_all_variations") delegate:nil cancelButtonTitle:Localize(@"i_ok") otherButtonTitles:nil];
                [alertView show];
                return;
            }
            else {
                if ([self checkPurchasable] == false) {
                    [button setSelected:false];
                    [button setTintColor:[Utility getUIColor:kUIColorThemeButtonNormal]];
                    if (self.show_vertical_layout_components) {
                        [button setTintColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
                        [button setTitleColor:[Utility getUIColor:kUIColorBuyButtonNormalBg] forState:UIControlStateNormal];
                        [button setTitle:Localize(@"toggle_cart_on") forState:UIControlStateNormal];
                    }
                    if (self.show_external_product_layout) {
                        [_buttonCart setHidden:true];
                    }
                    
                    button.layer.borderColor = [Utility getUIColor:kUIColorBuyButtonNormalBg].CGColor;
                    return;
                }
                Cart* c = [Cart addProduct:pInfo
                               variationId:-1
                            variationIndex:-1
               selectedVariationAttributes:nil
                               bundleItems:self.bundleItems
                              matchedItems:self.matchedItems
                                   prddDay:self.prdd_sDay
                                  prddTime:self.prdd_sTime
                                  prddDate:self.prdd_sDateStr
                           ];
            }
        }
    }
}
- (void)addToWishlist:(UIButton*)button {
    ProductInfo* pInfo = _currentItem.pInfo;
    if ([button isSelected]) {
        RLOG(@"Button Clicked:removeFormWishlist");
        [button setSelected:false];
        [_buttonWishlist setTintColor:[Utility getUIColor:kUIColorThemeButtonNormal]];
        button.layer.borderColor = [Utility getUIColor:kUIColorBuyButtonNormalBg].CGColor;
        if (self.show_vertical_layout_components) {
            [button setTintColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
            [button setTitleColor:[Utility getUIColor:kUIColorBuyButtonNormalBg] forState:UIControlStateNormal];
            [button setTitle:Localize(@"toggle_wishlist_on") forState:UIControlStateNormal];
        }
        if (self.show_external_product_layout) {
            [button setTintColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
            [button setTitleColor:[Utility getUIColor:kUIColorBuyButtonNormalBg] forState:UIControlStateNormal];
            [button setTitle:Localize(@"toggle_wishlist_on") forState:UIControlStateNormal];
        }
        NSMutableArray* basicAttributes = nil;
        if (_selectionViews) {
            basicAttributes = [[NSMutableArray alloc] init];
            for (SelectionView* sv in _selectionViews) {
                BasicAttribute* ba = [[BasicAttribute alloc] init];
                ba.attributeName = sv.attribute._name;
                ba.attributeSlug = sv.attribute._slug;
                ba.attributeValue = sv.attributeSelectedValue;
                [basicAttributes addObject:ba];
            }
        }
        if (_selectedVariation) {
            [Wishlist removeProduct:pInfo productId:pInfo._id variationId:_selectedVariation._id];
        }else{
            [Wishlist removeProduct:pInfo productId:pInfo._id variationId:-1];
        }
    }else{
        RLOG(@"Button Clicked:addToWishlist");
        [button setSelected:true];
        [_buttonWishlist setTintColor:[Utility getUIColor:kUIColorWishlistSelected]];
        //        button.layer.borderColor = [UIColor redColor].CGColor;
        if (self.show_vertical_layout_components) {
            [button setTitleColor:[Utility getUIColor:kUIColorWishlistSelected] forState:UIControlStateNormal];
            [button setTitle:Localize(@"toggle_wishlist_off") forState:UIControlStateNormal];
        }
        if (self.show_external_product_layout) {
            [button setTitleColor:[Utility getUIColor:kUIColorWishlistSelected] forState:UIControlStateNormal];
            [button setTitle:Localize(@"toggle_wishlist_off") forState:UIControlStateNormal];
        }
        NSMutableArray* basicAttributes = nil;
        if (_selectionViews) {
            basicAttributes = [[NSMutableArray alloc] init];
            for (SelectionView* sv in _selectionViews) {
                BasicAttribute* ba = [[BasicAttribute alloc] init];
                ba.attributeName = sv.attribute._name;
                ba.attributeSlug = sv.attribute._slug;
                ba.attributeValue = sv.attributeSelectedValue;
                [basicAttributes addObject:ba];
            }
        }
        if (_selectedVariation) {
            [Wishlist addProduct:pInfo variationId:_selectedVariation._id];
        }else{
            [Wishlist addProduct:pInfo variationId:-1];
        }
        //        [Wishlist addProduct:pInfo attributes:basicAttributes];
    }
}
- (void)initWishlistButtonProductScreen:(UIButton*)button {
    ProductInfo* pInfo = _currentItem.pInfo;
    BOOL itemIsInWishlist = [Wishlist hasItem:pInfo];
    if (itemIsInWishlist) {
        [button setSelected:true];
        [button setTintColor:[Utility getUIColor:kUIColorWishlistSelected]];
        if (self.show_vertical_layout_components) {
            [button setTitleColor:[Utility getUIColor:kUIColorWishlistSelected] forState:UIControlStateNormal];
            [button setTitle:Localize(@"toggle_wishlist_off") forState:UIControlStateNormal];
        }
        if (self.show_external_product_layout) {
            [button setTitleColor:[Utility getUIColor:kUIColorWishlistSelected] forState:UIControlStateNormal];
            [button setTitle:Localize(@"toggle_wishlist_off") forState:UIControlStateNormal];
        }
    } else {
        [button setSelected:false];
        [button setTintColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
        if (self.show_vertical_layout_components) {
            [button setTitleColor:[Utility getUIColor:kUIColorBuyButtonNormalBg] forState:UIControlStateNormal];
            [button setTitle:Localize(@"toggle_wishlist_on") forState:UIControlStateNormal];
        }
        if (self.show_external_product_layout) {
            [button setTitleColor:[Utility getUIColor:kUIColorBuyButtonNormalBg] forState:UIControlStateNormal];
            [button setTitle:Localize(@"toggle_wishlist_on") forState:UIControlStateNormal];
        }
    }
}
- (void)createWaitListView {
    if([[Addons sharedManager] enable_custom_waitlist]) {
        ProductInfo* product = _currentItem.pInfo;
        if(!product._in_stock) {
            float x = 8.0f, y = 0.0f;
            BOOL subscribed = [WaitList hasProductId:product._id];
            _labelWaitList = [[UILabel alloc] initWithFrame:CGRectMake(x, y, self.view.frame.size.width - 2*x, self.view.frame.size.width *.1f)];
            _labelWaitList.textColor = getColor(kUIColorFontDark);
            _labelWaitList.lineBreakMode = NSLineBreakByWordWrapping;
            [_labelWaitList setTag:kTagForGlobalSpacing];
            [_labelWaitList setUIFont:kUIFontType16 isBold:false];
            [_labelWaitList setText:Localize(subscribed?@"unsubscribe_waitlist_desc":@"subscribe_waitlist_desc")];
            [_labelWaitList sizeToFitUI];
            [_scrollView addSubview:_labelWaitList];
            [_viewsAdded addObject:_labelWaitList];
            
            _buttonWaitList = [[UIButton alloc] init];
            _buttonWaitList.frame = CGRectMake(x, y, self.view.frame.size.width - 2*x, self.view.frame.size.width *.125f);
            [_buttonWaitList setTag:kTagForGlobalSpacing];
            [_buttonWaitList setBackgroundColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
            [[_buttonWaitList titleLabel] setUIFont:kUIFontType22 isBold:true];
            [_buttonWaitList setTitle:Localize(subscribed ? @"unsubscribe_waitlist" : @"subscribe_waitlist") forState:UIControlStateNormal];
            [_buttonWaitList setTitleColor:getColor(kUIColorBuyButtonFont) forState:UIControlStateNormal];
            [_buttonWaitList addTarget:self action:@selector(onWaitListClick:) forControlEvents:UIControlEventTouchUpInside];
            
            [_scrollView addSubview:_buttonWaitList];
            [_viewsAdded addObject:_buttonWaitList];
        }
    }
}
- (void)showWaitListUI {
    if([[Addons sharedManager] enable_custom_waitlist]) {
        ProductInfo* product = _currentItem.pInfo;
        if(!product._in_stock) {
            _labelWaitList.hidden = NO;
            _buttonWaitList.hidden = NO;
            
            BOOL subscribed = [WaitList hasProductId:product._id];
            
            [_labelWaitList setText:Localize(subscribed?@"unsubscribe_waitlist_desc":@"subscribe_waitlist_desc")];
            [_buttonWaitList setTitle:Localize(subscribed ? @"unsubscribe_waitlist" : @"subscribe_waitlist") forState:UIControlStateNormal];
        } else {
            _labelWaitList.hidden = YES;
            _buttonWaitList.hidden = YES;
        }
    }
}
- (void)onWaitListClick:(UIButton*) button {
    if([[Addons sharedManager] enable_custom_waitlist]) {
        if(_currentItem.pInfo._in_stock) {
            _labelWaitList.hidden = YES;
            _buttonWaitList.hidden = YES;
            return;
        }
        
        if (![AppUser isSignedIn]) {
            [Utility showToast:Localize(@"Login required.")];
            return;
        }
        
        int userId = [[AppUser sharedManager] _id];
        NSString* emailId = [[AppUser sharedManager] _email];
        __block int productId = _currentItem.pInfo._id;
        
        [Utility showProgressView:Localize(@"Please wait...")];
        
        NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{@"user_id": base64_int(userId),
                                                                                          @"email_id": base64_str(emailId),
                                                                                          @"prod_id": base64_int(productId)}];
        if([WaitList hasProductId:productId]) {
            parameters[@"type"] = base64_str(@"unsubscribe");
            [[DataManager getDataDoctor] updateWaitListProduct:parameters
                                                       success:^(id data) {
                                                           [Utility hideProgressView];
                                                           [WaitList removeProductId:productId];
                                                           [self showWaitListUI];
                                                       }
                                                       failure:^(NSString *error) {
                                                           [Utility hideProgressView];
                                                       }];
        } else {
            parameters[@"type"] = base64_str(@"subscribe");
            [[DataManager getDataDoctor] updateWaitListProduct:parameters
                                                       success:^(id data) {
                                                           [Utility hideProgressView];
                                                           [WaitList addProductId:productId];
                                                           [self showWaitListUI];
                                                       }
                                                       failure:^(NSString *error) {
                                                           [Utility hideProgressView];
                                                       }];
        }
    }
}
- (void)loadRewardPoints {
    if([[Addons sharedManager] enable_custom_points]) {
        ProductInfo* product = _currentItem.pInfo;
        if(product.rewardPoints > 0) {
            _labelRewardPoints.hidden = NO;
            [_labelRewardPoints setText:[NSString stringWithFormat:Localize(@"product_points"), product.rewardPoints]];
            [_labelRewardPoints sizeToFitUI];
            return;
        }
        
        NSMutableDictionary* parameters = [[NSMutableDictionary alloc] init];
        [parameters setObject:base64_str(@"product_reward_points") forKey:@"type"];
        [parameters setObject:base64_int([[AppUser sharedManager] _id]) forKey:@"user_id"];
        [parameters setObject:base64_str([[AppUser sharedManager] _email]) forKey:@"email_id"];
        [parameters setObject:base64_int([product _id]) forKey:@"prod_id"];
        
        if([product hasVariations]) {
            NSString* varIds = [product getVariationsIds];
            if(varIds != nil && ![varIds isEqualToString:@""]) {
                [parameters setObject:base64_str(varIds) forKey:@"var_ids"];
            }
        }
        [[DataManager getDataDoctor] getProductRewardPoints:parameters
                                                    success:^(id data) {
                                                        if(product.rewardPoints > 0) {
                                                            _labelRewardPoints.hidden = NO;
                                                            [_labelRewardPoints setText:[NSString stringWithFormat:Localize(@"product_points"), product.rewardPoints]];
                                                            [self updateRewardPoints];
                                                        }
                                                        RLOG(@"This product has %d reward points.", product.rewardPoints);
                                                    }
                                                    failure:^(NSString *error) {
                                                        RLOG(@"Failed to get product reward points.");
                                                        _labelRewardPoints.hidden = YES;
                                                    }];
    }
}
- (void)loadBrandNames {
    ProductDetailsConfig* config = [[Addons sharedManager] productDetailsConfig];
    if(config.show_brand_names) {
        ProductInfo* product = _currentItem.pInfo;
        if(IS_EMPTY_STR(product.brandName))
        {
            NSArray* ids = @[[NSString stringWithFormat:@"%d", product._id]];
            
            [[DataManager getDataDoctor] getProductsBrandNames:ids
                                                       success:^(id data) {
                                                           // Show product brand name.
                                                           RLOG(@"brandName:1:%@", data);
                                                           [self setBrandNameInView];
                                                       }
                                                       failure:^(NSString *error) {
                                                           // Hide product brand name.
                                                           RLOG(@"brandName:2:%@", error);
                                                           [self setBrandNameInView];
                                                       }];
        } else {
            // Show product brand name.
            RLOG(@"brandName:3:%@", product.brandName);
            [self setBrandNameInView];
        }
    }
}
- (void)loadPriceLabels {
    ProductDetailsConfig* config = [[Addons sharedManager] productDetailsConfig];
    if(config.show_price_labels) {
        ProductInfo* product = _currentItem.pInfo;
        if(IS_EMPTY_STR(product.priceLabel)) {
            NSArray* ids = @[[NSString stringWithFormat:@"%d", product._id]];
            [[DataManager getDataDoctor] getProductsPriceLabels:ids
                                                        success:^(id data) {
                                                            // Show product price label.
                                                            [self updatePrice];
                                                            
                                                        }
                                                        failure:^(NSString *error) {
                                                            // Hide product price label.
                                                        }];
        } else {
            // Show product price label.
            [self updatePrice];
        }
    }
}
- (void)loadQuantityRules {
    ProductDetailsConfig* config = [[Addons sharedManager] productDetailsConfig];
    if(config.show_quantity_rules) {
        ProductInfo* product = _currentItem.pInfo;
        if(product.quantityRule == nil) {
            NSArray* ids = @[[NSString stringWithFormat:@"%d", product._id]];
            [[DataManager getDataDoctor] getProductsQuantityRules:ids
                                                          success:^(id data) {
                                                              // Show product qualtity rules in quick cart.
                                                              [self updateViewForMinQuantity];
                                                              [self resetMainScrollView];
                                                          }
                                                          failure:^(NSString *error) {
                                                              // Hide product qualtity rules in quick cart.
                                                          }];
        } else {
            // Show product qualtity rules in quick cart.
            [self updateViewForMinQuantity];
            [self resetMainScrollView];
        }
    }
}
- (void)openBrandPageLink {
    if (![_currentItem.pInfo.brandUrl isEqualToString:@""]) {
        ViewControllerMain* mainVC = [ViewControllerMain getInstance];
        ViewControllerWebview* vcWebview = (ViewControllerWebview*)[[Utility sharedManager] pushScreenWithNewAnimation:mainVC.vcCenterTop type:PUSH_SCREEN_TYPE_WEBVIEW];
        [vcWebview loadAllViews:_currentItem.pInfo.brandUrl];
        [vcWebview.view setTag:PUSH_SCREEN_TYPE_BRAND];
    }
}
#pragma mark - Deal Views
- (void)createMixAndMatchView {
    for (int i = 0; i < _kTotalViewsProductScreen; i++) {
        if (i != _kMIXNMATCH) {
            continue;
        }
        if (_isViewUserDefinedEnable[i] == false) {
            continue;
        }
        if (![_viewUserDefinedHeaderString[i] isEqualToString:@""]) {
            float fontSize = 34;
            float alignFactor = .014f * [[MyDevice sharedManager] screenWidthInPortrait];
            _viewUserDefinedHeader[i]=[[UILabel alloc]initWithFrame:CGRectMake(alignFactor, alignFactor, _scrollView.frame.size.width - alignFactor * 2, fontSize + alignFactor * 2)];
            [_viewUserDefinedHeader[i] setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
            [_viewUserDefinedHeader[i] setBackgroundColor:[Utility getUIColor:kUIColorClear]];
            UIFont *customFont = [Utility getUIFont:kUIFontType18 isBold:false];
            fontSize = [customFont lineHeight];
            [_viewUserDefinedHeader[i] setUIFont:customFont];
            [_viewUserDefinedHeader[i] setText:_viewUserDefinedHeaderString[i]];
            
            int leastSelected = (int) _currentItem.pInfo.mMixMatch.container_size;
            if (leastSelected == 0) {
                leastSelected = 1;
            }
            [_viewUserDefinedHeader[i] setText:[NSString stringWithFormat:@"Please select %d items to continue", leastSelected]];
            [_viewUserDefinedHeader[i] setTextColor:[Utility getUIColor:kUIColorFontSubTitle]];
            [_viewUserDefinedHeader[i] setTextAlignment:NSTextAlignmentLeft];
            [_viewUserDefinedHeader[i] setBaselineAdjustment:UIBaselineAdjustmentAlignBaselines];
            [_viewUserDefinedHeader[i] setLineBreakMode:NSLineBreakByCharWrapping];
            [_viewUserDefinedHeader[i] setNumberOfLines:1];
            
            [_scrollView addSubview:_viewUserDefinedHeader[i]];
            [_viewsAdded addObject:_viewUserDefinedHeader[i]];
            [_viewUserDefinedHeader[i] setTag:kTagForNoSpacing];
            
            if (self.matchedItems == nil) {
                if (_currentItem.pInfo.mMixMatch) {
                    self.matchedItems = [[NSMutableArray alloc] init];
                    for (ProductInfo* pObj in _currentItem.pInfo.mMixMatch.matchingItems) {
                        CartMatchedItem* cmItem = [[CartMatchedItem alloc] init];
                        cmItem.product = pObj;
                        cmItem.productId = pObj._id;
                        cmItem.price = pObj._price;
                        cmItem.title = pObj._title;
                        cmItem.quantity = 0;
                        if(pObj._images && [pObj._images count] > 0) {
                            cmItem.imgUrl = ((ProductImage*)[pObj._images objectAtIndex:0])._src;
                        }
                        [self.matchedItems addObject:cmItem];
                    }
                }
            }
        }
        
        UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
        switch (i) {
            case _kMIXNMATCH:
            {
                [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
                _viewUserDefined[i] = [[UICollectionView alloc] initWithFrame:[_propCollectionView[i] getFrameRect] collectionViewLayout:layout];
                [_viewUserDefined[i] setScrollEnabled:true];
                [_viewUserDefined[i] registerNib:[UINib nibWithNibName:_strCollectionMixNMatch bundle:nil] forCellWithReuseIdentifier:@"CollectionCell"];
                [_scrollView addSubview:_viewUserDefined[i]];
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
        //        [_viewUserDefined[i] setHidden:true];
    }
}
- (void)createBundleView {
    for (int i = 0; i < _kTotalViewsProductScreen; i++) {
        if (i != _kBUNDLE) {
            continue;
        }
        if (_isViewUserDefinedEnable[i] == false) {
            continue;
        }
        if (![_viewUserDefinedHeaderString[i] isEqualToString:@""]) {
            float fontSize = 34;
            float alignFactor = .014f * [[MyDevice sharedManager] screenWidthInPortrait];
            _viewUserDefinedHeader[i]=[[UILabel alloc]initWithFrame:CGRectMake(alignFactor, alignFactor, _scrollView.frame.size.width - alignFactor * 2, fontSize + alignFactor * 2)];
            [_viewUserDefinedHeader[i] setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
            [_viewUserDefinedHeader[i] setBackgroundColor:[Utility getUIColor:kUIColorClear]];
            UIFont *customFont = [Utility getUIFont:kUIFontType24 isBold:false];
            fontSize = [customFont lineHeight];
            [_viewUserDefinedHeader[i] setUIFont:customFont];
            [_viewUserDefinedHeader[i] setText:_viewUserDefinedHeaderString[i]];
            [_viewUserDefinedHeader[i] setTextColor:[Utility getUIColor:kUIColorFontSubTitle]];
            [_viewUserDefinedHeader[i] setTextAlignment:NSTextAlignmentLeft];
            [_viewUserDefinedHeader[i] setBaselineAdjustment:UIBaselineAdjustmentAlignBaselines];
            [_viewUserDefinedHeader[i] setLineBreakMode:NSLineBreakByCharWrapping];
            [_viewUserDefinedHeader[i] setNumberOfLines:1];
            if (self.bundleItems == nil) {
                if (_currentItem.pInfo.mBundles) {
                    self.bundleItems = [[NSMutableArray alloc] init];
                    for (TM_Bundle* bundle in _currentItem.pInfo.mBundles) {
                        CartBundleItem *cartBundle = [[CartBundleItem alloc] init];
                        ProductInfo *bundleProduct = ((ProductInfo*)(bundle.product));
                        cartBundle.productId = bundleProduct._id;
                        cartBundle.title = bundleProduct._title;
                        cartBundle.price = 0;
                        for (ProductImage* pimg in bundleProduct._images) {
                            cartBundle.imgUrl = pimg._src;
                            break;
                        }
                        cartBundle.quantity = bundle.bundle_quantity;
                        cartBundle.product = bundleProduct;
                        [self.bundleItems addObject:cartBundle];
                    }
                }
            }
        }
        
        UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
        switch (i) {
            case _kBUNDLE:
            {
                [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
                _viewUserDefined[i] = [[UICollectionView alloc] initWithFrame:[_propCollectionView[i] getFrameRect] collectionViewLayout:layout];
                [_viewUserDefined[i] setScrollEnabled:true];
                [_viewUserDefined[i] registerNib:[UINib nibWithNibName:_strCollectionBundle bundle:nil] forCellWithReuseIdentifier:@"CollectionCell"];
                [_scrollView addSubview:_viewUserDefined[i]];
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
        //        [_viewUserDefined[i] setHidden:true];
    }
}
- (void)createRelatedView {
    for (int i = 0; i < _kTotalViewsProductScreen; i++) {
        if (_isViewUserDefinedEnable[i] == false) {
            continue;
        }
        if (i == _kBUNDLE || i == _kMIXNMATCH) {
            continue;
        }
        if (![_viewUserDefinedHeaderString[i] isEqualToString:@""]) {
            float fontSize = 34;
            float alignFactor = .014f * [[MyDevice sharedManager] screenWidthInPortrait];
            _viewUserDefinedHeader[i]=[[UILabel alloc]initWithFrame:CGRectMake(alignFactor, alignFactor, _scrollView.frame.size.width - alignFactor * 2, fontSize + alignFactor * 2)];
            [_viewUserDefinedHeader[i] setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
            [_viewUserDefinedHeader[i] setBackgroundColor:[Utility getUIColor:kUIColorClear]];
            UIFont *customFont = [Utility getUIFont:kUIFontType24 isBold:false];
            fontSize = [customFont lineHeight];
            [_viewUserDefinedHeader[i] setUIFont:customFont];
            [_viewUserDefinedHeader[i] setText:_viewUserDefinedHeaderString[i]];
            [_viewUserDefinedHeader[i] setTextColor:[Utility getUIColor:kUIColorFontSubTitle]];
            [_viewUserDefinedHeader[i] setTextAlignment:NSTextAlignmentLeft];
            [_viewUserDefinedHeader[i] setBaselineAdjustment:UIBaselineAdjustmentAlignBaselines];
            [_viewUserDefinedHeader[i] setLineBreakMode:NSLineBreakByCharWrapping];
            [_viewUserDefinedHeader[i] setNumberOfLines:1];
            
            [_scrollView addSubview:_viewUserDefinedHeader[i]];
            [_viewsAdded addObject:_viewUserDefinedHeader[i]];
            [_viewUserDefinedHeader[i] setTag:kTagForNoSpacing];
        }
        
        UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
        switch (i) {
            case _kRelatedProduct:
            {
                [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
                _viewUserDefined[i] = [[UICollectionView alloc] initWithFrame:[_propCollectionView[i] getFrameRect] collectionViewLayout:layout];
                [_viewUserDefined[i] setScrollEnabled:true];
                [_viewUserDefined[i] registerNib:[UINib nibWithNibName:_strCollectionView3 bundle:nil] forCellWithReuseIdentifier:@"CollectionCell"];
                [_scrollView addSubview:_viewUserDefined[i]];
                [_viewsAdded addObject:_viewUserDefined[i]];
                [_viewUserDefined[i] setTag:kTagForGlobalSpacing];
            }break;
            case _kUpSell:
            {
                [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
                _viewUserDefined[i] = [[UICollectionView alloc] initWithFrame:[_propCollectionView[i] getFrameRect] collectionViewLayout:layout];
                [_viewUserDefined[i] setScrollEnabled:true];
                [_viewUserDefined[i] registerNib:[UINib nibWithNibName:_strCollectionView3 bundle:nil] forCellWithReuseIdentifier:@"CollectionCell"];
                [_scrollView addSubview:_viewUserDefined[i]];
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
        //        [_viewUserDefined[i] setHidden:true];
    }
}
#pragma mark - Category View
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    int itemCount = 0;
    int i = 0;
    for (; i < _kTotalViewsProductScreen; i++) {
        if(_viewUserDefined[i] == collectionView){
            break;
        }
    }
    
    switch (i) {
        case _kRelatedProduct:
        {
            itemCount = (int)[_currentItem.pInfo._related_ids count];
        }break;
        case _kUpSell:
        {
            itemCount = (int)[_currentItem.pInfo._upsell_ids count];
        }break;
        case _kMIXNMATCH:
        {
            itemCount = (int)[_currentItem.pInfo.mMixMatch.matchingItems count];
            if (itemCount == 0) {
                itemCount = -1;
            }
        }break;
        case _kBUNDLE:
        {
            itemCount = (int)[_currentItem.pInfo.mBundles count];
            if (itemCount == 0) {
                itemCount = -1;
            }
        }break;
            
        default:
            itemCount = 1;
            break;
    }
    
    if (itemCount == 0) {
        [self removeUserDefinedView:i];
    }
    if (itemCount == -1) {
        [self hideTillDataLoaded:i];
    }
    return itemCount;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CollectionCell";
    CCollectionViewCell *cell=(CCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    [cell setNeedsLayout];
    int i = 0;
    for (; i < _kTotalViewsProductScreen; i++) {
        if(_viewUserDefined[i] == collectionView){
            break;
        }
    }
    if (i < _kTotalViewsProductScreen && _propCollectionView[i]._insetTop != -1) {
        collectionView.contentInset = UIEdgeInsetsMake(_propCollectionView[i]._insetTop, _propCollectionView[i]._insetLeft, _propCollectionView[i]._insetBottom, _propCollectionView[i]._insetRight);
        
    }
    switch (i) {
        case _kRelatedProduct:
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
            if (indexPath.row >= (int)[_currentItem.pInfo._related_ids count] && [[DataManager sharedManager] promoEnable]) {
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
                ProductInfo *pInfo = [ProductInfo getProductWithId:[[_currentItem.pInfo._related_ids objectAtIndex:indexPath.row] intValue]];
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
                
                BOOL itemIsInWishlist = [Wishlist hasItem:pInfo variationId:pInfo._id];
                if (itemIsInWishlist) {
                    [cell.buttonWishlist setSelected:true];
                    [cell.buttonWishlist setTintColor:[Utility getUIColor:kUIColorWishlistSelected]];
                    if (self.show_vertical_layout_components) {
                        [cell.buttonWishlist setTitleColor:[Utility getUIColor:kUIColorWishlistSelected] forState:UIControlStateNormal];
                        [cell.buttonWishlist setTitle:Localize(@"toggle_wishlist_off") forState:UIControlStateNormal];
                    }
                    if (self.show_external_product_layout) {
                        [cell.buttonWishlist setTitleColor:[Utility getUIColor:kUIColorWishlistSelected] forState:UIControlStateNormal];
                        [cell.buttonWishlist setTitle:Localize(@"toggle_wishlist_off") forState:UIControlStateNormal];
                    }
                }else{
                    [cell.buttonWishlist setSelected:false];
                    [cell.buttonWishlist setTintColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
                    if (self.show_vertical_layout_components) {
                        [cell.buttonWishlist setTitleColor:[Utility getUIColor:kUIColorBuyButtonNormalBg] forState:UIControlStateNormal];
                        [cell.buttonWishlist setTitle:Localize(@"toggle_wishlist_on") forState:UIControlStateNormal];
                    }
                    if (self.show_external_product_layout) {
                        [cell.buttonWishlist setTitleColor:[Utility getUIColor:kUIColorBuyButtonNormalBg] forState:UIControlStateNormal];
                        [cell.buttonWishlist setTitle:Localize(@"toggle_wishlist_on") forState:UIControlStateNormal];
                    }
                }
                
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
                [cell.productImg setContentMode:UIViewContentModeScaleAspectFill];
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
                    [cell.buttonCart setTitle:Localize(@"add_to_cart") forState:UIControlStateNormal];
                    [cell.buttonCart.layer setValue:cell forKey:@"CELL_OBJ"];
                    [cell.buttonSubstract.layer setValue:pInfo forKey:@"PINFO_OBJ"];
                    [cell.buttonSubstract.layer setValue:cell forKey:@"CELL_OBJ"];
                    [cell.textFieldAmt.layer setValue:pInfo forKey:@"PINFO_OBJ"];
                    [cell.textFieldAmt.layer setValue:cell forKey:@"CELL_OBJ"];
                    
                    [cell.buttonCart addTarget:self action:@selector(cartButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.buttonAdd addTarget:self action:@selector(addButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.buttonSubstract addTarget:self action:@selector(grocerySubstractButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                    //                    [cell.textFieldAmt addTarget:self action:@selector(cartButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                }else {
                    [cell.layer setValue:nil forKey:@"PRODUCT_INFO"];
                    [cell.layer setValue:nil forKey:@"PINFO_OBJ"];
                }
            }
        } break;
        case _kUpSell:
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
            if (indexPath.row >= (int)[_currentItem.pInfo._upsell_ids count] && [[DataManager sharedManager] promoEnable]) {
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
                ProductInfo *pInfo = [ProductInfo getProductWithId:[[_currentItem.pInfo._upsell_ids objectAtIndex:indexPath.row] intValue]];
                [[cell productName] setText:pInfo._titleForOuterView];
                
                [[cell productPriceOriginal] setAttributedText:[pInfo getPriceOldString]];
                [[cell productPriceFinal] setText:[pInfo getPriceNewString]];
                if ([pInfo._images count] == 0) {
                    [pInfo._images addObject:[[ProductImage alloc] init]];
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
                BOOL itemIsInWishlist = [Wishlist hasItem:pInfo variationId:pInfo._id];
                if (itemIsInWishlist) {
                    [cell.buttonWishlist setSelected:true];
                    [cell.buttonWishlist setTintColor:[Utility getUIColor:kUIColorWishlistSelected]];
                    if (self.show_vertical_layout_components) {
                        [cell.buttonWishlist setTitleColor:[Utility getUIColor:kUIColorWishlistSelected] forState:UIControlStateNormal];
                        [cell.buttonWishlist setTitle:Localize(@"toggle_wishlist_off") forState:UIControlStateNormal];
                    }
                    if (self.show_external_product_layout) {
                        [cell.buttonWishlist setTitleColor:[Utility getUIColor:kUIColorWishlistSelected] forState:UIControlStateNormal];
                        [cell.buttonWishlist setTitle:Localize(@"toggle_wishlist_off") forState:UIControlStateNormal];
                    }
                }else{
                    [cell.buttonWishlist setSelected:false];
                    [cell.buttonWishlist setTintColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
                    if (self.show_vertical_layout_components) {
                        [cell.buttonWishlist setTitleColor:[Utility getUIColor:kUIColorBuyButtonNormalBg] forState:UIControlStateNormal];
                        [cell.buttonWishlist setTitle:Localize(@"toggle_wishlist_on") forState:UIControlStateNormal];
                    }
                    if (self.show_external_product_layout) {
                        [cell.buttonWishlist setTitleColor:[Utility getUIColor:kUIColorBuyButtonNormalBg] forState:UIControlStateNormal];
                        [cell.buttonWishlist setTitle:Localize(@"toggle_wishlist_on") forState:UIControlStateNormal];
                    }
                }
                
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
                    [cell.buttonCart setTitle:Localize(@"add_to_cart") forState:UIControlStateNormal];
                    [cell.buttonCart.layer setValue:cell forKey:@"CELL_OBJ"];
                    [cell.buttonSubstract.layer setValue:pInfo forKey:@"PINFO_OBJ"];
                    [cell.buttonSubstract.layer setValue:cell forKey:@"CELL_OBJ"];
                    [cell.textFieldAmt.layer setValue:pInfo forKey:@"PINFO_OBJ"];
                    [cell.textFieldAmt.layer setValue:cell forKey:@"CELL_OBJ"];
                    
                    [cell.buttonCart addTarget:self action:@selector(cartButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.buttonAdd addTarget:self action:@selector(addButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.buttonSubstract addTarget:self action:@selector(substractButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                    //                    [cell.textFieldAmt addTarget:self action:@selector(cartButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                }else {
                    [cell.layer setValue:nil forKey:@"PRODUCT_INFO"];
                    [cell.layer setValue:nil forKey:@"PINFO_OBJ"];
                }
            }
        } break;
        case _kMIXNMATCH:
        {
            if(cell == nil) {
                NSArray *nib = [[ NSBundle mainBundle] loadNibNamed:_strCollectionMixNMatch owner:self options:nil];
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
            if (indexPath.row >= (int)[_currentItem.pInfo.mMixMatch.matchingItems count] && [[DataManager sharedManager] promoEnable]) {
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
                
                ProductInfo *pInfo = (ProductInfo *)[_currentItem.pInfo.mMixMatch.matchingItems objectAtIndex:indexPath.row];
                [[cell productName] setText:pInfo._titleForOuterView];
                
                [[cell productPriceOriginal] setAttributedText:[pInfo getPriceOldString]];
                [[cell productPriceFinal] setText:[pInfo getPriceNewString]];
                if ([pInfo._images count] == 0) {
                    [pInfo._images addObject:[[ProductImage alloc] init]];
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
                BOOL itemIsInWishlist = [Wishlist hasItem:pInfo variationId:pInfo._id];
                if (itemIsInWishlist) {
                    [cell.buttonWishlist setSelected:true];
                    [cell.buttonWishlist setTintColor:[Utility getUIColor:kUIColorWishlistSelected]];
                    if (self.show_vertical_layout_components) {
                        [cell.buttonWishlist setTitleColor:[Utility getUIColor:kUIColorWishlistSelected] forState:UIControlStateNormal];
                        [cell.buttonWishlist setTitle:Localize(@"toggle_wishlist_off") forState:UIControlStateNormal];
                    }
                    if (self.show_external_product_layout) {
                        [cell.buttonWishlist setTitleColor:[Utility getUIColor:kUIColorWishlistSelected] forState:UIControlStateNormal];
                        [cell.buttonWishlist setTitle:Localize(@"toggle_wishlist_off") forState:UIControlStateNormal];
                    }
                }else{
                    [cell.buttonWishlist setSelected:false];
                    [cell.buttonWishlist setTintColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
                    if (self.show_vertical_layout_components) {
                        [cell.buttonWishlist setTitleColor:[Utility getUIColor:kUIColorBuyButtonNormalBg] forState:UIControlStateNormal];
                        [cell.buttonWishlist setTitle:Localize(@"toggle_wishlist_on") forState:UIControlStateNormal];
                    }
                    if (self.show_external_product_layout) {
                        [cell.buttonWishlist setTitleColor:[Utility getUIColor:kUIColorBuyButtonNormalBg] forState:UIControlStateNormal];
                        [cell.buttonWishlist setTitle:Localize(@"toggle_wishlist_on") forState:UIControlStateNormal];
                    }
                }
                
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
                    [cell.layer setValue:@"true" forKey:@"ismixnmatch"];
                    [cell.layer setValue:self forKey:@"VC"];
                    [cell.layer setValue:pInfo forKey:@"PRODUCT_INFO"];
                    [cell.layer setValue:pInfo forKey:@"PINFO_OBJ"];
                    [cell.buttonAdd.layer setValue:pInfo forKey:@"PINFO_OBJ"];
                    [cell.buttonAdd.layer setValue:cell forKey:@"CELL_OBJ"];
                    [cell.buttonCart.layer setValue:pInfo forKey:@"PINFO_OBJ"];
                    [cell.buttonCart setTitle:Localize(@"add_to_cart") forState:UIControlStateNormal];
                    [cell.buttonCart.layer setValue:cell forKey:@"CELL_OBJ"];
                    [cell.buttonSubstract.layer setValue:pInfo forKey:@"PINFO_OBJ"];
                    [cell.buttonSubstract.layer setValue:cell forKey:@"CELL_OBJ"];
                    [cell.textFieldAmt.layer setValue:pInfo forKey:@"PINFO_OBJ"];
                    [cell.textFieldAmt.layer setValue:cell forKey:@"CELL_OBJ"];
                    
                    //                    [cell.buttonCart addTarget:self action:@selector(cartButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.buttonAdd addTarget:self action:@selector(addButtonClickedMixMatch:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.buttonSubstract addTarget:self action:@selector(substractButtonClickedMixMatch:) forControlEvents:UIControlEventTouchUpInside];
                    
                    
                    int qty = 0;
                    if (_currentItem.pInfo.mMixMatch) {
                        for (CartMatchedItem* cmItems in self.matchedItems) {
                            if(cmItems.product == pInfo) {
                                //                                cmItems.quantity += 1;
                                qty = cmItems.quantity;
                                break;
                            }
                        }
                        [self updatePrice];
                        [cell refreshCellMixNMatch:pInfo qty:qty];
                    }
                    //                    [cell.textFieldAmt addTarget:self action:@selector(cartButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                }else {
                    [cell.layer setValue:nil forKey:@"PRODUCT_INFO"];
                    [cell.layer setValue:nil forKey:@"PINFO_OBJ"];
                }
            }
        }
            break;
        case _kBUNDLE:
        {
            if(cell == nil) {
                NSArray *nib = [[ NSBundle mainBundle] loadNibNamed:_strCollectionBundle owner:self options:nil];
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
            if (indexPath.row >= (int)[_currentItem.pInfo.mBundles count] && [[DataManager sharedManager] promoEnable]) {
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
                TM_Bundle* bundle = [_currentItem.pInfo.mBundles objectAtIndex:indexPath.row];
                ProductInfo *pInfo = bundle.product;
                [[cell productName] setText:pInfo._titleForOuterView];
                
                [[cell productPriceOriginal] setAttributedText:[pInfo getPriceOldString]];
                [[cell productPriceFinal] setText:[pInfo getPriceNewString]];
                if ([pInfo._images count] == 0) {
                    [pInfo._images addObject:[[ProductImage alloc] init]];
                }
                [[cell productPriceFinal] setText:[NSString stringWithFormat:@"%d %@", bundle.bundle_quantity, Localize(@"FREE")]];
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
                BOOL itemIsInWishlist = [Wishlist hasItem:pInfo variationId:pInfo._id];
                if (itemIsInWishlist) {
                    [cell.buttonWishlist setSelected:true];
                    [cell.buttonWishlist setTintColor:[Utility getUIColor:kUIColorWishlistSelected]];
                    if (self.show_vertical_layout_components) {
                        [cell.buttonWishlist setTitleColor:[Utility getUIColor:kUIColorWishlistSelected] forState:UIControlStateNormal];
                        [cell.buttonWishlist setTitle:Localize(@"toggle_wishlist_off") forState:UIControlStateNormal];
                    }
                    if (self.show_external_product_layout) {
                        [cell.buttonWishlist setTitleColor:[Utility getUIColor:kUIColorWishlistSelected] forState:UIControlStateNormal];
                        [cell.buttonWishlist setTitle:Localize(@"toggle_wishlist_off") forState:UIControlStateNormal];
                    }
                }else{
                    [cell.buttonWishlist setSelected:false];
                    [cell.buttonWishlist setTintColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
                    if (self.show_vertical_layout_components) {
                        [cell.buttonWishlist setTitleColor:[Utility getUIColor:kUIColorBuyButtonNormalBg] forState:UIControlStateNormal];
                        [cell.buttonWishlist setTitle:Localize(@"toggle_wishlist_on") forState:UIControlStateNormal];
                    }
                    if (self.show_external_product_layout) {
                        [cell.buttonWishlist setTitleColor:[Utility getUIColor:kUIColorBuyButtonNormalBg] forState:UIControlStateNormal];
                        [cell.buttonWishlist setTitle:Localize(@"toggle_wishlist_on") forState:UIControlStateNormal];
                    }
                }
                
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
                    [cell.buttonCart setTitle:Localize(@"add_to_cart") forState:UIControlStateNormal];
                    [cell.buttonCart.layer setValue:cell forKey:@"CELL_OBJ"];
                    [cell.buttonSubstract.layer setValue:pInfo forKey:@"PINFO_OBJ"];
                    [cell.buttonSubstract.layer setValue:cell forKey:@"CELL_OBJ"];
                    [cell.textFieldAmt.layer setValue:pInfo forKey:@"PINFO_OBJ"];
                    [cell.textFieldAmt.layer setValue:cell forKey:@"CELL_OBJ"];
                    
                    [cell.buttonCart addTarget:self action:@selector(cartButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.buttonAdd addTarget:self action:@selector(addButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.buttonSubstract addTarget:self action:@selector(substractButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                    //                    [cell.textFieldAmt addTarget:self action:@selector(cartButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                }else {
                    [cell.layer setValue:nil forKey:@"PRODUCT_INFO"];
                    [cell.layer setValue:nil forKey:@"PINFO_OBJ"];
                }
            }
        }
            break;
        default:
            break;
    }
    [cell setNeedsLayout];
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    int i = 0;
    for (; i < _kTotalViewsProductScreen; i++) {
        if(_viewUserDefined[i] == collectionView){
            break;
        }
    }
    NSMutableArray *array = nil;
    switch (i) {
        case _kRelatedProduct:
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
        case _kUpSell:
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
        case _kMIXNMATCH:
        case _kBUNDLE:
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
            
            
            
            float ratioScale = 1.0f;
            if ([[MyDevice sharedManager] isIpad]) {
                ratioScale = 0.75f;
            }
            
            _propCollectionView[i]._height = cardHeight + _propCollectionView[i]._insetTop + _propCollectionView[i]._insetBottom;
            _propCollectionView[i]._height *= ratioScale;
            [_viewUserDefined[i] setFrame:[_propCollectionView[i] getFrameRect]];
            [self resetMainScrollView];
            return CGSizeMake(cardWidth * ratioScale, cardHeight * ratioScale);
        }break;
            
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
    for (; i < _kTotalViewsProductScreen; i++) {
        if(_viewUserDefined[i] == collectionView){
            break;
        }
    }
    switch (i) {
        case _kRelatedProduct:
        {
            
        }break;
        case _kUpSell:
        {
            
        }break;
        case _kMIXNMATCH:
        {
            
        }break;
        case _kBUNDLE:
        {
            
        }break;
            
        default:
            break;
    }
}
#pragma mark - Adjust Orientation
- (void)beforeRotation {
    if ([[AppDelegate getInstance] isAppEnteredInBackground]) {
        return;
    }
    
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
    if ([[AppDelegate getInstance] isAppEnteredInBackground]) {
        return;
    }
    
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
    if ([[AppDelegate getInstance] isAppEnteredInBackground]) {
        return;
    }
    
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
    if ([[AppDelegate getInstance] isAppEnteredInBackground]) {
        return;
    }
    
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
    if (_zoomScrollView && _zoomPopupController && _viewMainChildPopoverView && _zoomPageIsOpened) {
        [self zoomOut:nil];
    }
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
    //    RLOG(@"\n_scrollView child count %d",(int)[[_scrollView subviews] count]);
    int i = 0;
    for (tempView in _viewsAdded) {
        //        RLOG(@"\ntempView = %@, globalPosY = %.f", tempView, globalPosY);
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
#pragma mark - HorizontalLine
- (void)addHorizontalLine:(int)tag {
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
    lineView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    lineView.backgroundColor = [Utility getUIColor:kUIColorBorder];
    [_scrollView addSubview:lineView];
    [_viewsAdded addObject:lineView];
    [lineView setTag:tag];
}
- (void)hideTillDataLoaded:(int)viewId {
    _viewUserDefined[viewId].hidden = true;
    _viewUserDefinedHeader[viewId].hidden = true;
    
    CGRect tempRect = _viewUserDefined[viewId].frame;
    tempRect.size.height = 0;
    _viewUserDefined[viewId].frame = tempRect;
    _viewUserDefined[viewId].tag = kTagForNoSpacing;
    
    CGRect tempRectH = _viewUserDefinedHeader[viewId].frame;
    tempRectH.size.height = 0;
    _viewUserDefinedHeader[viewId].frame = tempRectH;
    _viewUserDefinedHeader[viewId].tag = kTagForNoSpacing;
    
    [self resetMainScrollView];
}
- (void)removeUserDefinedView:(int)viewId {
    _isViewUserDefinedEnable[viewId] = false;
    [_viewUserDefinedHeader[viewId] removeFromSuperview];
    [_viewsAdded removeObject:_viewUserDefinedHeader[viewId]];
    [_viewUserDefined[viewId] removeFromSuperview];
    [_viewsAdded removeObject:_viewUserDefined[viewId]];
    [self resetMainScrollView];
}
- (void)removeBannerView {
    [_bannerScrollView removeFromSuperview];
    [_viewsAdded removeObject:_bannerScrollView];
    [self resetMainScrollView];
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
    [vcCategories loadData:clickedItemData previousItem:previousItemData drillingLevel:_drillingLevel + 1];
}
- (void)clickOnProduct:(ProductInfo*)productClicked currentItemData:(DataPass*)currentItemData{
    ViewControllerMain* mainVC = [ViewControllerMain getInstance];
    mainVC.containerTop.hidden = YES;
    mainVC.containerCenter.hidden = YES;
    mainVC.containerCenterWithTop.hidden = NO;
    mainVC.vcBottomBar.buttonHome.selected = YES;
    mainVC.vcBottomBar.buttonCart.selected = NO;
    mainVC.vcBottomBar.buttonWishlist.selected = NO;
    mainVC.vcBottomBar.buttonSearch.selected = NO;
    [mainVC.vcBottomBar buttonClicked:nil];
    DataPass* clickedItemData = [[DataPass alloc] init];
    clickedItemData.itemId = productClicked._id;
    clickedItemData.isCategory = false;
    clickedItemData.isProduct = true;
    clickedItemData.hasChildCategory = false;
    clickedItemData.childCount = false;
    clickedItemData.pInfo = productClicked;
    
    DataPass* previousItemData = [[DataPass alloc] init];
    previousItemData.itemId = currentItemData.cInfo._id;
    previousItemData.isCategory = currentItemData.isCategory;
    previousItemData.isProduct = currentItemData.isProduct;
    previousItemData.hasChildCategory = currentItemData.hasChildCategory;
    previousItemData.childCount = currentItemData.childCount;
    previousItemData.cInfo = currentItemData.cInfo;
    
    ViewControllerProduct* vcProduct = [[Utility sharedManager] pushProductScreen:mainVC.vcCenterTop];
    [vcProduct loadData:clickedItemData previousItem:previousItemData drillingLevel:_drillingLevel + 1];
}

- (void)clickOnProduct:(ProductInfo*)productClicked currentItemData:(DataPass*)currentItemData cell:(id)cell{
    if ([Utility isSellerOnlyApp]) {
        ProductInfo* pInfo = productClicked;
        DataPass* dPass = currentItemData;
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
        ViewControllerProduct* vcProduct = [[Utility sharedManager] pushProductScreen:self];
        [vcProduct loadData:clickedItemData previousItem:previousItemData drillingLevel:0];
        vcProduct.parentVC = self;
        vcProduct.parentCell = cell;
        return;
    }
    
    
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
    clickedItemData.itemId = productClicked._id;
    clickedItemData.isCategory = false;
    clickedItemData.isProduct = true;
    clickedItemData.hasChildCategory = false;
    clickedItemData.childCount = false;
    clickedItemData.pInfo = productClicked;
    DataPass* previousItemData = [[DataPass alloc] init];
    previousItemData.itemId = currentItemData.cInfo._id;
    previousItemData.isCategory = currentItemData.isCategory;
    previousItemData.isProduct = currentItemData.isProduct;
    previousItemData.hasChildCategory = currentItemData.hasChildCategory;
    previousItemData.childCount = currentItemData.childCount;
    previousItemData.cInfo = currentItemData.cInfo;
    ViewControllerProduct* vcProduct = [[Utility sharedManager] pushProductScreen:mainVC.vcCenterTop];
    [vcProduct loadData:clickedItemData previousItem:previousItemData drillingLevel:0];
    vcProduct.parentVC = self;
    vcProduct.parentCell = cell;
}
-(void)dataFetchCompletion:(ServerData *)serverData{
    if (serverData._serverRequestStatus == kServerRequestSucceed) {
        RLOG(@"=======DATA_FETCHING:SUCCESS=======");
        RLOG(@"_serverUrl = %@",serverData._serverUrl);
        RLOG(@"_serverDataId = %d",serverData._serverDataId);
        RLOG(@"_serverResultDictionary = %@",serverData._serverResultDictionary);
        if (serverData._serverResultDictionary != NULL) {
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:serverData._serverResultDictionary options:NSJSONWritingPrettyPrinted error:&error];
            if (! jsonData) {
                RLOG(@"Got an error: %@", error);
            } else {
                NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                [[NSUserDefaults standardUserDefaults] setObject:jsonString forKey:serverData._serverUrl];
            }
        }
    } else if (serverData._serverRequestStatus == kServerRequestFailed) {
        RLOG(@"=======DATA_FETCHING:FAILED=======");
        RLOG(@"_serverUrl = %@",serverData._serverUrl);
        RLOG(@"_serverDataId = %d",serverData._serverDataId);
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
            case kFetchSingleProduct:
                RLOG(@"Load kFetchSingleProduct");
                [[DataManager sharedManager] loadSingleProductData:serverData._serverResultDictionary];
                [[Utility sharedManager] startGrayLoadingBar:true];
                [self reloadVariations];
                [self afterRotation:0.5f];
                [[DataManager sharedManager] fetchSingleProductDataReviews:nil productId:_currentItem.itemId];
                break;
            case kFetchSingleProductReview:
                RLOG(@"Load kFetchSingleProductReview PRODUCT SCREEN:%@", self);
                _currentItem.pInfo._isReviewsRetrieved = true;
                [[DataManager sharedManager] loadSingleProductReviewData:serverData._serverResultDictionary product:_currentItem.pInfo];
                //                [[Utility sharedManager] startGrayLoadingBar:true];
                [self createReviewView];
                [self resetMainScrollView];
                break;
            default:
                break;
        }
    }else if (serverData._serverRequestStatus == kServerRequestFailed){
        switch (serverData._serverDataId) {
            case kFetchSingleProduct:
                if (_currentItem.pInfo._isFullRetrieved == false) {
                    if (_productLoadingView) {
                        [_productLoadingView removeFromSuperview];
                        _productLoadingView = nil;
                    }
                }
                break;
            case kFetchSingleProductReview:
                if (_currentItem.pInfo._isReviewsRetrieved == false) {
                }
                break;
        }
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    RLOG(@"scrollViewDidEndDecelerating");
    [self fetchReviews];
}
- (void)fetchReviews {
    if (_currentItem.pInfo._isFullRetrieved && _currentItem.pInfo._isReviewsRetrieved == false) {
        [[DataManager sharedManager] fetchSingleProductDataReviews:nil productId:_currentItem.itemId];
    }
}
#pragma mark - CNPPopupController Delegate
- (void)popupControllerDidDismiss:(CNPPopupController *)controller {
    //    RLOG(@"Dismissed with button title: %@", title);
    for (UIView* v in [_viewMainChildPopoverView subviews]) {
        [v removeFromSuperview];
    }
}
- (void)popupControllerDidPresent:(CNPPopupController *)controller {
    RLOG(@"Popup controller presented.");
}
- (void)addButtonClickedMixMatch:(UIButton*)button {
    ProductInfo* pInfo = (ProductInfo*)[button.layer valueForKey:@"PINFO_OBJ"];
    CCollectionViewCell* cell = (CCollectionViewCell*)[button.layer valueForKey:@"CELL_OBJ"];
    int qty = 0;
    if (_currentItem.pInfo.mMixMatch) {
        for (CartMatchedItem* cmItems in self.matchedItems) {
            if(cmItems.product == pInfo) {
                cmItems.quantity += 1;
                qty = cmItems.quantity;
                break;
            }
        }
    }
    [self updatePrice];
    [cell refreshCellMixNMatch:pInfo qty:qty];
}
- (void)substractButtonClickedMixMatch:(UIButton*)button {
    ProductInfo* pInfo = (ProductInfo*)[button.layer valueForKey:@"PINFO_OBJ"];
    CCollectionViewCell* cell = (CCollectionViewCell*)[button.layer valueForKey:@"CELL_OBJ"];
    int qty = 0;
    if (_currentItem.pInfo.mMixMatch) {
        for (CartMatchedItem* cmItems in self.matchedItems) {
            if(cmItems.product == pInfo) {
                if (cmItems.quantity > 0) {
                    cmItems.quantity -= 1;
                }
                qty = cmItems.quantity;
                break;
            }
        }
    }
    [self updatePrice];
    [cell refreshCellMixNMatch:pInfo qty:qty];
}
- (void)addButtonClicked:(UIButton*)button {
    ProductInfo* pInfo = (ProductInfo*)[button.layer valueForKey:@"PINFO_OBJ"];
    CCollectionViewCell* cell = (CCollectionViewCell*)[button.layer valueForKey:@"CELL_OBJ"];
    if (pInfo._variations && [pInfo._variations count] > 0) { } else {
        Cart* c = [Cart addProduct:pInfo
                       variationId:-1
                    variationIndex:-1
       selectedVariationAttributes:nil
                       bundleItems:self.bundleItems
                      matchedItems:self.matchedItems
                           prddDay:self.prdd_sDay
                          prddTime:self.prdd_sTime
                          prddDate:self.prdd_sDateStr
                   ];
    }
    [cell refreshCell:pInfo];
}
- (void)substractButtonClicked:(UIButton*)button {
    [[Utility sharedManager] substractButtonClicked:button];
}
- (void)groceryAddButtonClicked:(UIButton*)button {
    ProductInfo* pInfo = _currentItem.pInfo;
    if (pInfo._isFullRetrieved == false) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:Localize(@"i_loading_product_data") delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
        [alertView show];
        [self xx:alertView];
        return;
    }
    
    
    int variationId = -1;
    if (_selectedVariation) {
        variationId = _selectedVariation._id;
    }
    if ([self checkPurchasable] == false) {
        return;
    }
    Cart* c = [Cart addProduct:pInfo
                   variationId:variationId
                variationIndex:-1
   selectedVariationAttributes:_selectedVariationAttibutes
                   bundleItems:self.bundleItems
                  matchedItems:self.matchedItems
                       prddDay:self.prdd_sDay
                      prddTime:self.prdd_sTime
                      prddDate:self.prdd_sDateStr
               ];
    int count = 0;
    if (c) {
        count = c.count;
    }
    _groceryTextField.text = [NSString stringWithFormat:@"%d", count];
    [self updateButtons];
}
- (void)grocerySubstractButtonClicked:(UIButton*)button {
    ProductInfo* pInfo = _currentItem.pInfo;
    if (pInfo._isFullRetrieved == false) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:Localize(@"i_loading_product_data") delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
        [alertView show];
        [self xx:alertView];
        return;
    }
    
    int variationId = -1;
    if (_selectedVariation) {
        variationId = _selectedVariation._id;
    }
    
    
    
    Cart* c = [Cart removeProduct:pInfo variationId:variationId variationIndex:-1 selectedVariationAttributes:_selectedVariationAttibutes];
    int count = 0;
    if (c) {
        count = c.count;
    }
    _groceryTextField.text = [NSString stringWithFormat:@"%d", count];
    [self updateButtons];
}

- (void)createPincodeSettingsView {
    if([[Addons sharedManager] enable_pincode_settings]) {
        if([[PincodeSetting getInstance] isFetched]) {
            float posX = self.view.frame.size.width * 0.01f;
            float posY = self.view.frame.size.width * 0.01f;
            float viewWidth = self.view.frame.size.width * 0.98f;
            
            float itemPosX = self.view.frame.size.width * 0.02f;
            float itemPosY = self.view.frame.size.width * 0.02f;
            float itemWidth = viewWidth - itemPosX * 2;
            float gapY = itemPosY;
            
            if (_zipSettingView == nil) {
                _zipSetting = nil;
                _zipSettingView = nil;
                _zipSettingHeaderLabel = nil;
                _zipSettingDescLabel = nil;
                _zipSettingCheckButton = nil;
                _zipSettingChangeButton = nil;
                _zipSettingTextField = nil;
                _zipSettingState = ZIP_SETTING_VIEW_STATE_INITIATE;
                
                
                _zipSettingView = [[UIView alloc] init];
                _zipSettingView.backgroundColor = [UIColor whiteColor];
                _zipSettingView.frame = CGRectMake(posX, posY, viewWidth, 250);
                [_scrollView addSubview:_zipSettingView];
                [_viewsAdded addObject:_zipSettingView];
                [_zipSettingView setTag:kTagForGlobalSpacing];
            } else {
                for (UIView* v in [_zipSettingView subviews]) {
                    [v removeFromSuperview];
                }
            }
            
            
            
            _zipSettingHeaderLabel = [[UILabel alloc] initWithFrame:CGRectMake(itemPosX, itemPosY, itemWidth, 0)];
            [_zipSettingView addSubview:_zipSettingHeaderLabel];
            [_zipSettingHeaderLabel setUIFont:kUIFontType20 isBold:false];
            _zipSettingHeaderLabel.text = [[PincodeSetting getInstance] zipTitle];
            _zipSettingHeaderLabel.textColor = [Utility getUIColor:kUIColorFontDark];
            _zipSettingHeaderLabel.numberOfLines = 0;
            [_zipSettingHeaderLabel setLineBreakMode:NSLineBreakByWordWrapping];
            [_zipSettingHeaderLabel sizeToFitUI];
            itemPosY = CGRectGetMaxY(_zipSettingHeaderLabel.frame) + gapY;
            
            if (_zipSettingState == ZIP_SETTING_VIEW_STATE_FOUND || _zipSettingState == ZIP_SETTING_VIEW_STATE_NOT_FOUND) {
                _zipSettingDescLabel = [[UILabel alloc] initWithFrame:CGRectMake(itemPosX, itemPosY, itemWidth, 0)];
                [_zipSettingView addSubview:_zipSettingDescLabel];
                [_zipSettingDescLabel setUIFont:kUIFontType20 isBold:false];
                
                if (_zipSettingState == ZIP_SETTING_VIEW_STATE_FOUND && _zipSetting) {
                    _zipSettingDescLabel.text = _zipSetting.message;
                    _zipSettingDescLabel.textColor = [Utility getUIColor:kUIColorCartSelected];
                } else {
                    _zipSettingDescLabel.text = [[PincodeSetting getInstance] zipNotFoundMessage];
                    _zipSettingDescLabel.textColor = [Utility getUIColor:kUIColorWishlistSelected];
                }
                
                
                
                _zipSettingDescLabel.numberOfLines = 0;
                [_zipSettingDescLabel setLineBreakMode:NSLineBreakByWordWrapping];
                [_zipSettingDescLabel sizeToFitUI];
                itemPosY = CGRectGetMaxY(_zipSettingDescLabel.frame) + gapY;
                
                _zipSettingChangeButton = [[UIButton alloc] initWithFrame:CGRectMake(itemPosX, itemPosY, itemWidth, 0)];
                [_zipSettingView addSubview:_zipSettingChangeButton];
                [_zipSettingChangeButton.titleLabel setUIFont:kUIFontType20 isBold:false];
                [_zipSettingChangeButton setAttributedTitle:[Utility createUnderlineAttributedString:Localize(@"Change Pincode")] forState:UIControlStateNormal];
                [_zipSettingChangeButton setTitleColor:[Utility getUIColor:kUIColorFontDark] forState:UIControlStateNormal];
                _zipSettingChangeButton.titleLabel.numberOfLines = 0;
                [_zipSettingChangeButton.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
                [_zipSettingChangeButton.titleLabel sizeToFitUI];
                [_zipSettingChangeButton sizeToFit];
                [_zipSettingChangeButton addTarget:self action:@selector(eventZipChange:) forControlEvents:UIControlEventTouchUpInside];
                itemPosY = CGRectGetMaxY(_zipSettingChangeButton.frame) + gapY;
            } else {
                float buttonHeight;
                if ([[MyDevice sharedManager] isIpad]) {
                    buttonHeight = [[MyDevice sharedManager] screenWidthInPortrait] * 0.1f;
                } else {
                    buttonHeight = [[MyDevice sharedManager] screenWidthInPortrait] * 0.125f;
                }
                
                float buttonWidth;
                if ([[MyDevice sharedManager] isIpad]) {
                    buttonWidth = [[MyDevice sharedManager] screenWidthInPortrait] * .30f;
                } else {
                    buttonWidth = [[MyDevice sharedManager] screenWidthInPortrait] * .40f;
                }
                
                _zipSettingTextField = [[UITextField alloc] initWithFrame:CGRectMake(viewWidth * .49f -  buttonWidth, itemPosY, buttonWidth, buttonHeight)];
                [_zipSettingView addSubview:_zipSettingTextField];
                [_zipSettingTextField setUIFont:kUIFontType20 isBold:false];
                if (_zipSetting) {
                    _zipSettingTextField.text = _zipSetting.pincode;
                } else {
                    _zipSettingTextField.text = @"";
                }
                _zipSettingTextField.placeholder = Localize(@"Enter Pincode");
                _zipSettingTextField.textColor = [Utility getUIColor:kUIColorFontDark];
                _zipSettingTextField.borderStyle = UITextBorderStyleLine;
                _zipSettingTextField.layer.borderWidth = 1;
                _zipSettingTextField.layer.borderColor = [Utility getUIColor:kUIColorThemeButtonBorderSelected].CGColor;
                _zipSettingTextField.returnKeyType = UIReturnKeyDone;
                _zipSettingTextField.textAlignment = NSTextAlignmentCenter;
                _zipSettingTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                _zipSettingTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
                _zipSettingTextField.delegate = self;
                //                _zipSettingTextField.keyboardType = UIKeyboardTypePhonePad;
                //                if ([[MyDevice sharedManager] isIphone]) {
                //                    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
                //                    numberToolbar.backgroundColor = [UIColor lightGrayColor];
                //                    UIBarButtonItem* cancelBtn = [[UIBarButtonItem alloc]initWithTitle:Localize(@"cancel") style:UIBarButtonItemStyleBordered target:self action:@selector(cancelNumberPad:)];
                //                    UIBarButtonItem* doneBtn = [[UIBarButtonItem alloc]initWithTitle:[[PincodeSetting getInstance] zipButtonText] style:UIBarButtonItemStyleBordered target:self action:@selector(doneWithNumberPad:)];
                //                    numberToolbar.items = @[
                //                                            cancelBtn,
                //                                            [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                //                                            doneBtn];
                //                    [numberToolbar sizeToFit];
                //                    _zipSettingTextField.inputAccessoryView = numberToolbar;
                //                }
                
                
                _zipSettingCheckButton = [[UIButton alloc] initWithFrame:CGRectMake(viewWidth * .51f, itemPosY, buttonWidth, buttonHeight)];
                [_zipSettingView addSubview:_zipSettingCheckButton];
                [_zipSettingCheckButton.titleLabel setUIFont:kUIFontType20 isBold:false];
                [_zipSettingCheckButton setTitle:[[PincodeSetting getInstance] zipButtonText] forState:UIControlStateNormal];
                [_zipSettingCheckButton setTitleColor:[Utility getUIColor:kUIColorBuyButtonFont] forState:UIControlStateNormal];
                [_zipSettingCheckButton setBackgroundColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
                [_zipSettingCheckButton addTarget:self action:@selector(eventZipCheck:) forControlEvents:UIControlEventTouchUpInside];
                itemPosY = CGRectGetMaxY(_zipSettingCheckButton.frame) + gapY;
            }
            
            
            _zipSettingView.frame = CGRectMake(posX, posY, viewWidth, itemPosY);
            _zipSettingView.layer.shadowOpacity = 0.0f;
            [Utility showShadow:_zipSettingView];
        }
    }
}

- (void)eventZipCheck:(UIButton*)button {
    
    _zipSetting = [[PincodeSetting getInstance] getZipSetting:_zipSettingTextField.text];
    if (_zipSetting) {
        _zipSettingState = ZIP_SETTING_VIEW_STATE_FOUND;
    } else {
        _zipSettingState = ZIP_SETTING_VIEW_STATE_NOT_FOUND;
    }
    [self createPincodeSettingsView];
    [self resetMainScrollView];
}
- (void)eventZipChange:(UIButton*)button {
    _zipSettingState = ZIP_SETTING_VIEW_STATE_INITIATE;
    [self createPincodeSettingsView];
    [self resetMainScrollView];
}
- (void)cancelNumberPad:(UIBarButtonItem*)button {
    if (_zipSettingTextField) {
        [_zipSettingTextField resignFirstResponder];
    }
}
- (void)doneWithNumberPad:(UIBarButtonItem*)button {
    if (_zipSettingTextField) {
        [_zipSettingTextField resignFirstResponder];
        [self eventZipCheck:nil];
    }
}
- (void)doneWithDeviceKeyPad:(UIBarButtonItem*)button {
    if (_zipSettingTextField) {
        [_zipSettingTextField resignFirstResponder];
    }
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    _textFieldFirstResponder = textField;
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    //    if (textField == _zipSettingTextField) {
    //        [self eventZipCheck:nil];
    //    }
    return YES;
}
- (void)keyboardWillShow:(NSNotification *)notification {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    NSDictionary *info  = notification.userInfo;
    NSValue      *value = info[UIKeyboardFrameEndUserInfoKey];
    CGRect rawFrame      = [value CGRectValue];
    CGRect keyboardFrame = [self.view convertRect:rawFrame fromView:nil];
    RLOG(@"keyboardFrame: %@", NSStringFromCGRect(keyboardFrame));
    _keyboardHeight = keyboardFrame.size.height;
    _duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    _curve = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    // Animate the current view out of the way
    [self setViewMovedUp:YES];
}
- (void)keyboardWillHide {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [self setViewMovedUp:NO];
}
- (void)setViewMovedUp:(BOOL)movedUp {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    RLOG(@"setViewMovedUp:%d", movedUp);
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:_duration];
    [UIView setAnimationCurve:_curve];
    CGRect rect = self.view.frame;
    if (movedUp) {
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        CGPoint p = [_textFieldFirstResponder convertPoint:_textFieldFirstResponder.center toView:window];
        float textViewPos = p.y;
        float windowViewHeight = [[MyDevice sharedManager] screenSize].height;
        float keyboardPos = windowViewHeight - _keyboardHeight;
        if (textViewPos > keyboardPos) {
            if ([[MyDevice sharedManager] isIphone]) {
                rect.origin.y = - (textViewPos - keyboardPos);
                self.view.frame = rect;
            } else {
            }
        }
    }
    else {
        if ([[MyDevice sharedManager] isIphone]) {
            rect.origin.y = 0;
            self.view.frame = rect;
            //            self.view.center = CGPointMake([[MyDevice sharedManager] screenSize].width/2, [[MyDevice sharedManager] screenSize].height/2);
        } else {
        }
        
    }
    
    [UIView commitAnimations];
}
- (void)cartButtonClicked:(UIButton*)button {
    ProductInfo* pInfo = (ProductInfo*)[button.layer valueForKey:@"PINFO_OBJ"];
    CCollectionViewCell* cell = (CCollectionViewCell*)[button.layer valueForKey:@"CELL_OBJ"];
    if (cell.actIndicator.hidden == false) {
        return;
    }
    if (pInfo._isFullRetrieved == false) {
        [[NSNotificationCenter defaultCenter] addObserver:cell selector:@selector(updateCell:) name:@"NOTIFY_PRODUCT_LOADED" object:nil];
        
        [[DataManager sharedManager] fetchSingleProductData:nil productId:pInfo._id];
        [cell.actIndicator setHidden:false];
        [cell.buttonCart setHidden:true];
    } else {
        if (pInfo._variations && [pInfo._variations count] > 0) {
            //open new popup to choose variation and add to cart
            [self clickOnProduct:pInfo currentItemData:_currentItem cell:cell];
        }else {
            if ([self checkPurchasable] == false) {
                return;
            }
            
            int availState = [Cart getProductAvailibleState:pInfo variationId:-1];
            if (availState == PRODUCT_QTY_DEMAND || availState == PRODUCT_QTY_STOCK) {
                Cart* c = [Cart addProduct:pInfo
                               variationId:-1
                            variationIndex:-1
               selectedVariationAttributes:nil
                               bundleItems:self.bundleItems
                              matchedItems:self.matchedItems
                                   prddDay:self.prdd_sDay
                                  prddTime:self.prdd_sTime
                                  prddDate:self.prdd_sDateStr
                           ];
            }
            
        }
    }
    [cell refreshCell:pInfo];
}
- (void)bannerTapped:(UITapGestureRecognizer*)singleTap{
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
                }
                
            }break;
            case BANNER_CATEGORY://open category
            {
                int categoryId = bannerId;
                CategoryInfo *cInfo = [CategoryInfo getWithId:categoryId];
                [self clickOnCategory:cInfo currentItemData:nil];
            }break;
            case BANNER_WISHLIST://open wishlist
            {
                ViewControllerMain* mainVC = [ViewControllerMain getInstance];
                [mainVC btnClickedWishlist:nil];
            }break;
            case BANNER_CART://open cart
            {
                ViewControllerMain* mainVC = [ViewControllerMain getInstance];
                if ([Utility isSellerOnlyApp] == false) {
                    [mainVC btnClickedCart:nil];
                }
                
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
- (UICollectionView*)getViewUserDefined:(int)viewId {
    return _viewUserDefined[viewId];
}



- (UIView*)createPRDDView {
    float topMargin = self.view.frame.size.width * 0.01f;
    float leftMargin = self.view.frame.size.width * 0.01f;
    float rightMargin = self.view.frame.size.width * 0.01f;
    float bottomMargin = self.view.frame.size.width * 0.01f;
    float viewWidth = self.view.frame.size.width - leftMargin - rightMargin;
    float viewHeight = 0;
    float viewPosX = leftMargin;
    float viewPosY = topMargin;
    float leftMarginInsideView = self.view.frame.size.width * 0.10f;
    float rightMarginInsideView = self.view.frame.size.width * 0.10f;
    float widthInsideView = viewWidth - leftMarginInsideView - rightMarginInsideView;
    float gap = topMargin;
    float varPosY = topMargin + gap;
    UIFont* font = [Utility getUIFont:kUIFontType18 isBold:true];
    float fontHeight = [font lineHeight];
    
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(viewPosX, viewPosY, viewWidth, viewHeight)];
    [view setBackgroundColor:[UIColor whiteColor]];
    [_scrollView addSubview:view];
    [_viewsAdded addObject:view];
    [view setTag:kTagForGlobalSpacing];
    //    [view addSubview:[self addBorder:view]];
    
    if ([[Addons sharedManager] productDeliveryDatePlugin] && [[[Addons sharedManager] productDeliveryDatePlugin] isEnabled]) {
        self.buttonDateSelection = [[UIButton alloc] init];
        [self.buttonDateSelection setFrame:CGRectMake(leftMarginInsideView, varPosY, widthInsideView, fontHeight * 2.0f)];
        [self.buttonDateSelection setTitle:Localize(@"select_date") forState:UIControlStateNormal];
        [self.buttonDateSelection setTitleColor:[Utility getUIColor:kUIColorBuyButtonNormalBg] forState:UIControlStateNormal];
        [self.buttonDateSelection.titleLabel setUIFont:kUIFontType18 isBold:false];
        [self.buttonDateSelection addTarget:self action:@selector(dateSelectionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttonDateSelection setTitleEdgeInsets:UIEdgeInsetsMake(0, 50, 0, 0)];
        [self.buttonDateSelection setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [self.buttonDateSelection.layer setBorderWidth:1];
        [view addSubview:self.buttonDateSelection];
        
        
        self.buttonDateSelectionDownArrow = [[UIButton alloc] init];
        [self.buttonDateSelectionDownArrow setFrame:CGRectMake(leftMarginInsideView + widthInsideView - 50, varPosY, 50, fontHeight * 2.0f)];
        [self.buttonDateSelectionDownArrow addTarget:self action:@selector(dateSelectionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttonDateSelectionDownArrow.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [self.buttonDateSelectionDownArrow setImage:[[UIImage imageNamed:@"img_arrow_down_white"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [self.buttonDateSelectionDownArrow setTintColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
        [self.buttonDateSelectionDownArrow setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        [view addSubview:self.buttonDateSelectionDownArrow];
        
        
        self.buttonDateSelectionIcon = [[UIButton alloc] init];
        [self.buttonDateSelectionIcon setFrame:CGRectMake(leftMarginInsideView, varPosY, 50, fontHeight * 2.0f)];
        [self.buttonDateSelectionIcon addTarget:self action:@selector(dateSelectionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttonDateSelectionIcon.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [self.buttonDateSelectionIcon setImage:[[UIImage imageNamed:@"date_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [self.buttonDateSelectionIcon setTintColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
        [self.buttonDateSelectionIcon setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        [self.buttonDateSelectionIcon setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
        [view addSubview:self.buttonDateSelectionIcon];
        //        self.buttonDateSelectionIcon.layer.borderWidth = 1;
        
        varPosY = gap + CGRectGetMaxY(self.buttonDateSelection.frame);
    }
    
    self.buttonTimeSelection = [[UIButton alloc] init];
    [self.buttonTimeSelection setFrame:CGRectMake(leftMarginInsideView, varPosY, widthInsideView, fontHeight * 2.0f)];
    [self.buttonTimeSelection setTitle:Localize(@"select_time") forState:UIControlStateNormal];
    [self.buttonTimeSelection setTitleColor:[Utility getUIColor:kUIColorBuyButtonNormalBg] forState:UIControlStateNormal];
    [self.buttonTimeSelection.titleLabel setUIFont:kUIFontType18 isBold:false];
    [self.buttonTimeSelection addTarget:self action:@selector(timeSelectionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonTimeSelection setTitleEdgeInsets:UIEdgeInsetsMake(0, 50, 0, 0)];
    [self.buttonTimeSelection setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self.buttonTimeSelection.layer setBorderWidth:1];
    [view addSubview:self.buttonTimeSelection];
    
    
    self.buttonTimeSelectionDownArrow = [[UIButton alloc] init];
    [self.buttonTimeSelectionDownArrow setFrame:CGRectMake(leftMarginInsideView + widthInsideView - 50, varPosY, 50, fontHeight * 2.0f)];
    [self.buttonTimeSelectionDownArrow addTarget:self action:@selector(timeSelectionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonTimeSelectionDownArrow.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.buttonTimeSelectionDownArrow setImage:[[UIImage imageNamed:@"img_arrow_down_white"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.buttonTimeSelectionDownArrow setTintColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
    [self.buttonTimeSelectionDownArrow setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [view addSubview:self.buttonTimeSelectionDownArrow];
    
    
    self.buttonTimeSelectionIcon = [[UIButton alloc] init];
    [self.buttonTimeSelectionIcon setFrame:CGRectMake(leftMarginInsideView, varPosY, 50, fontHeight * 2.0f)];
    [self.buttonTimeSelectionIcon addTarget:self action:@selector(timeSelectionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonTimeSelectionIcon.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.buttonTimeSelectionIcon setImage:[[UIImage imageNamed:@"time_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.buttonTimeSelectionIcon setTintColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
    [self.buttonTimeSelectionIcon setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [self.buttonTimeSelectionIcon setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    [view addSubview:self.buttonTimeSelectionIcon];
    //    self.buttonTimeSelectionIcon.layer.borderWidth = 1;
    
    varPosY = gap + CGRectGetMaxY(self.buttonTimeSelection.frame);
    
    
    viewHeight = gap + varPosY;
    [view setFrame:CGRectMake(viewPosX, viewPosY, viewWidth, viewHeight)];
    return view;
}
- (void)dateSelectionButtonClicked:(UIButton *)sender {
    CGSize datePickerSize = CGSizeMake(320, 216);
    
    UIViewController *viewController = [[UIViewController alloc]init];
    UIView *viewForDatePicker = [[UIView alloc]initWithFrame:CGRectMake(0, 0, datePickerSize.width, datePickerSize.height)];
    UIDatePicker* datePicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, 0, datePickerSize.width, datePickerSize.height)];
    NSString* userLocale = [[NSUserDefaults standardUserDefaults] valueForKey:USER_LOCALE];
    NSString* defaultLocale = [[NSUserDefaults standardUserDefaults] valueForKey:DEFAULT_LOCALE];
    NSString* selectedLocale = @"";
    if (userLocale && ![userLocale isEqualToString:@""]) {
        selectedLocale = userLocale;
    } else if (defaultLocale && ![defaultLocale isEqualToString:@""]) {
        selectedLocale = defaultLocale;
    } else {
        selectedLocale = @"en_US";
    }
    [datePicker setLocale: [NSLocale localeWithLocaleIdentifier:selectedLocale]];
    datePicker.datePickerMode = UIDatePickerModeDate;
    datePicker.hidden = NO;
    [datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    [datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventAllTouchEvents];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd/MM/yyyy"];
    datePicker.date = [NSDate date];
    if (self.prdd_sDay && self.prdd_sDateStr && ![self.prdd_sDateStr isEqualToString:@""]) {
        NSDate *selectedDate = [dateFormat dateFromString:self.prdd_sDateStr];
        datePicker.date = selectedDate;
    }
    [viewForDatePicker addSubview:datePicker];
    [viewController.view addSubview:viewForDatePicker];
    
    FPPopoverController *popOverForDatePicker = [[FPPopoverController alloc] initWithViewController:viewController];
    popOverForDatePicker.contentSize = CGSizeMake(datePickerSize.width,datePickerSize.height);
    popOverForDatePicker.arrowDirection = FPPopoverArrowDirectionUp | FPPopoverArrowDirectionDown | FPPopoverArrowDirectionLeft | FPPopoverArrowDirectionRight;
    popOverForDatePicker.delegate = self;
    [popOverForDatePicker presentPopoverFromView:self.buttonDateSelection];
    popOverForDatePicker.border = NO;
    popOverForDatePicker.tint = FPPopoverWhiteTint;
}
- (void)popoverControllerDidDismissPopover:(FPPopoverController *)popoverController {
    if (self.prdd_sDay == nil) {
        [self nextValidDefaultDate:nil];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"dd/MM/yyyy"];
        NSDate *selectedDate = [self nextValidDefaultDate:nil];
        NSString* dateString = [dateFormat stringFromDate:selectedDate];
        self.prdd_sDateStr = dateString;
        [self.buttonDateSelection setTitle:dateString forState:UIControlStateNormal];
        [self.buttonDateSelection setTitleColor:[Utility getUIColor:kUIColorFontDark] forState:UIControlStateNormal];
        [self.buttonDateSelection.titleLabel setUIFont:kUIFontType18 isBold:true];
        [self.buttonDateSelectionDownArrow setTintColor:[Utility getUIColor:kUIColorFontDark]];
        [self.buttonDateSelectionIcon setTintColor:[Utility getUIColor:kUIColorFontDark]];
    }
}
- (void)timeSelectionButtonClicked:(UIButton *)sender {
    [self.ddViewTimeSelection removeFromSuperview];
    self.ddViewTimeSelection = nil;
    if(self.ddViewTimeSelection == nil)
    {
        NSArray * arrImage = nil;
        if (self.prdd_sDay && [[self.prdd_sDay prdd_times] count] > 0) {
            self.timeSlotDataObjects = self.prdd_sDay.prdd_times;
        }
        NSMutableArray* timeStrings = [[NSMutableArray alloc] init];
        for (TM_PRDD_Time* ts in self.timeSlotDataObjects) {
            NSString* timeStr = [NSString stringWithFormat:@"%@", ts.slot_title];
            NSString* costStr = [[Utility sharedManager] convertToString:ts.slot_price isCurrency:true];
            if (ts.slot_price != 0) {
                timeStr = [NSString stringWithFormat:@"%@ (%@)", timeStr, costStr];
            }
            [timeStrings addObject:timeStr];
        }
        
        CGFloat height = [[MyDevice sharedManager] screenHeightInPortrait] * .30f;
        self.ddViewTimeSelection = [[NIDropDown alloc] init:_buttonTimeSelection viewheight:height strArr:timeStrings imgArr:arrImage direction:NIDropDownDirectionDown pView:self.view];
        self.ddViewTimeSelection.delegate = self;
        self.ddViewTimeSelection.fontColor = [Utility getUIColor:kUIColorBgTheme];
    }
    else {
        [self.ddViewTimeSelection toggle:_buttonTimeSelection];
    }
}
- (void)reponseDropDownDelegate:(NIDropDown *)sender clickedItemId:(int)clickedItemId {
    if (self.timeSlotDataObjects) {
        TM_PRDD_Time* ts =  [self.timeSlotDataObjects objectAtIndex:clickedItemId];
        self.prdd_sTime = ts;
        NSString* timeStr = [NSString stringWithFormat:@"%@", ts.slot_title];
        NSString* costStr = [[Utility sharedManager] convertToString:ts.slot_price isCurrency:true];
        if (ts.slot_price != 0) {
            timeStr = [NSString stringWithFormat:@"%@ (%@)", timeStr, costStr];
        }
        [self.buttonTimeSelection setTitle:timeStr forState:UIControlStateNormal];
        [self.buttonTimeSelection setTitleColor:[Utility getUIColor:kUIColorFontDark] forState:UIControlStateNormal];
        [self.buttonTimeSelection.titleLabel setUIFont:kUIFontType18 isBold:true];
        [self.buttonTimeSelectionDownArrow setTintColor:[Utility getUIColor:kUIColorFontDark]];
        [self.buttonTimeSelectionIcon setTintColor:[Utility getUIColor:kUIColorFontDark]];
    }
}
- (NSDate*)nextValidDefaultDate:(NSDate*)nextDate {
    NSDate* todayDate = [NSDate date];
    if (nextDate == nil) {
        nextDate = todayDate;
    }
    else if (nextDate.timeIntervalSince1970 < todayDate.timeIntervalSince1970) {
        nextDate = todayDate;
    }
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit fromDate:nextDate];
    int weekday = (int)[comps weekday] - 1;
    TM_PRDD_Day* prddDay = [self.prdd.prdd_days objectAtIndex:weekday];
    self.prdd_sDay = prddDay;
    if (prddDay.prdd_day_enable == false) {
        nextDate = [NSDate dateWithTimeInterval:60*60*24*1 sinceDate:nextDate];
        [self nextValidDefaultDate:nextDate];
    }
    return nextDate;
}
- (NSDate*)nextValidDate:(UIDatePicker*)uiDatePicker {
    NSDate* todayDate = [NSDate date];
    if (uiDatePicker.date.timeIntervalSince1970 < todayDate.timeIntervalSince1970) {
        [uiDatePicker setDate:todayDate animated:true];
    }
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit fromDate:uiDatePicker.date];
    int weekday = (int)[comps weekday] - 1;
    TM_PRDD_Day* prddDay = [self.prdd.prdd_days objectAtIndex:weekday];
    self.prdd_sDay = prddDay;
    if (prddDay.prdd_day_enable == false) {
        [uiDatePicker setDate:[NSDate dateWithTimeInterval:60*60*24*1 sinceDate:uiDatePicker.date] animated:true];
        [self nextValidDate:uiDatePicker];
    }
    return uiDatePicker.date;
}
- (void)dateChanged:(UIDatePicker*)uiDatePicker{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd/MM/yyyy"];
    NSDate* date = [self nextValidDate:uiDatePicker];
    NSString* dateString = [dateFormat stringFromDate:date];
    [self.buttonDateSelection setTitle:dateString forState:UIControlStateNormal];
    [self.buttonDateSelection setTitleColor:[Utility getUIColor:kUIColorFontDark] forState:UIControlStateNormal];
    [self.buttonDateSelection.titleLabel setUIFont:kUIFontType18 isBold:true];
    [self.buttonDateSelectionDownArrow setTintColor:[Utility getUIColor:kUIColorFontDark]];
    [self.buttonDateSelectionIcon setTintColor:[Utility getUIColor:kUIColorFontDark]];
    self.prdd_sDateStr = dateString;
    if (self.buttonTimeSelection) {
        [self.buttonTimeSelection setTitle:Localize(@"select_time") forState:UIControlStateNormal];
        [self.buttonTimeSelection setTitleColor:[Utility getUIColor:kUIColorBuyButtonNormalBg] forState:UIControlStateNormal];
        [self.buttonTimeSelection.titleLabel setUIFont:kUIFontType18 isBold:false];
        [self.buttonTimeSelectionDownArrow setTintColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
        [self.buttonTimeSelectionIcon setTintColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
        self.prdd_sTime = nil;
    }
}
- (void)backgroundTouchEventRegistered:(CNPPopupController *)controller {
    RLOG(@"backgroundTouchEventRegistered:");
}
#if ENABLE_SELLER_LOC_PRODUCT_PAGE
#pragma mark - create a marker pin on map
/*
 - (void)createMarker:(NSString*)titleMarker lattitude:(CLLocationDegrees)lattitude longitude:(CLLocationDegrees)longitude{
 if (SHOP_SETTINGS && SHOP_SETTINGS.show_location) {
 ProductInfo* pInfo = self.currentItem.pInfo;
 SellerInfo* sInfo = pInfo.sellerInfo;
 //        [_mapView clear];
 GMSMarker *marker = [[GMSMarker alloc]init];
 if (sInfo == nil || sInfo.shopLatitude == -1 || sInfo.shopLongitude == -1) {
 marker.position = CLLocationCoordinate2DMake(sInfo.shopLatitude, sInfo.shopLongitude);
 } else {
 marker.position = CLLocationCoordinate2DMake(lattitude, longitude);
 }
 marker.title = titleMarker;
 marker.map =_mapView;
 }
 }
 */
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    if(SHOP_SETTINGS && SHOP_SETTINGS.show_location) {
        self.myLocation = [locations lastObject];
        if (self.myLocation != nil){
            NSLog(@"The latitude value is - %@",[NSString stringWithFormat:@"%.8f", self.myLocation.coordinate.latitude]);
            NSLog(@"The logitude value is - %@",[NSString stringWithFormat:@"%.8f", self.myLocation.coordinate.longitude]);
        }
        
        GMSCameraPosition *camera = nil;
        CLLocation *location = nil;
        ProductInfo* pInfo = self.currentItem.pInfo;
        SellerInfo* sInfo = pInfo.sellerInfo;
        camera = [GMSCameraPosition cameraWithLatitude:sInfo.shopLatitude longitude:sInfo.shopLongitude zoom:11];
        location = [[CLLocation alloc]initWithLatitude:sInfo.shopLatitude longitude:sInfo.shopLongitude];
        
        GMSMarker *marker=[[GMSMarker alloc]init];
        marker.position= CLLocationCoordinate2DMake(location.coordinate.latitude,location.coordinate.longitude);
        marker.map= _mapView;
        
        _mapView.camera = camera;
        _mapView.myLocationEnabled = YES;
        _mapView.settings.compassButton = false;
        _mapView.delegate = self;
        
        [locationManager stopUpdatingLocation];
    }
}

#endif


- (void)backFromProductScreen:(id)cell{
    if (cell) {
        CCollectionViewCell* pCell = (CCollectionViewCell*)cell;
        ProductInfo* pInfo = (ProductInfo*)[pCell.layer valueForKey:@"PINFO_OBJ"];
        if (pInfo) {
            [pCell refreshCell:pInfo];
        }
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_currentItem.pInfo._extraAttributes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ProductAttributCell *cell = (ProductAttributCell*)[tableView dequeueReusableCellWithIdentifier:@"ProductAttributCell"];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    Attribute *attribute = [_currentItem.pInfo._extraAttributes  objectAtIndex:indexPath.row];
    
    if (cell == nil)
    {
        cell = [[ProductAttributCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ProductAttributCell"];
    }
    
    NSMutableString *optionsString = [[NSMutableString alloc]init];
    for (int i = 0; i < [attribute._options count]; i++){
        [optionsString appendFormat:@"%@",attribute._options[i]];
        if(i < [attribute._options count] - 1)
            [optionsString appendString:@"&nbsp;|&nbsp;"];
    }
    
    cell.labelKey.textColor = [Utility getUIColor:kUIColorFontDark];
    [cell.labelKey setUIFont:kUIFontType16 isBold:true];
    cell.labelKey.text = attribute._name;
    // cell.labelValue.text = optionsString;
    
    NSMutableAttributedString * optionsHtmlString = [[NSMutableAttributedString alloc] initWithData:[optionsString dataUsingEncoding:NSUnicodeStringEncoding]options:@{ NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType } documentAttributes:nil  error:nil];
    cell.labelValue.attributedText = optionsHtmlString;
    
    cell.labelValue.textColor = [Utility getUIColor:kUIColorFontDark];
    [cell.labelValue setUIFont:kUIFontType16 isBold:false];
    
    
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Calculate a height based on a cell
    return 40;
}


@end
