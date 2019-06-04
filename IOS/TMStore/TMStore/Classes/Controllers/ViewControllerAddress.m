//
//  ViewControllerAddress.m
//  eMobileApp
//
//  Created by Rishabh Jain on 25/11/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import "ViewControllerAddress.h"
#import "Utility.h"
#import "Address.h"
#import "AppUser.h"
#import "DataManager.h"
#import "ViewControllerCartConfirmation.h"
#import "ShippingEngine.h"
#import "AnalyticsHelper.h"

static int kTagForGlobalSpacing = 0;
static int kTagForNoSpacing = -1;
static int MAX_ADDRESSES_COUNT = 1;

@interface ViewControllerAddress () <CNPPopupControllerDelegate, CLLocationManagerDelegate, ShippingEngine> {
    NSMutableArray* _viewsAdded;
    UIButton* customBackButton;
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    DataManager* _dataManager;
    UILabel* _labelViewHeading;
    float _defaultHeight;
    
    UITextField* _regionTextFields[REGION_SEQUENCE_TOTAL];
    UIButton* _regionSelectionUIButtons[REGION_SEQUENCE_TOTAL];
    UIImageView* _regionSelectionImgArrows[REGION_SEQUENCE_TOTAL];
    NIDropDown* _regionDropdownViews[REGION_SEQUENCE_TOTAL];
    TMRegion* _regionObjs[REGION_SEQUENCE_TOTAL];
    NSMutableArray* _regionDataObjects[REGION_SEQUENCE_TOTAL];
    NSMutableArray* _regionTMRegionObjects[REGION_SEQUENCE_TOTAL];
    
    NSMutableArray* _regionSequences;
}
@property (nonatomic, strong) CNPPopupController *popupController;
@end
@implementation ViewControllerAddress
#pragma mark - Basic Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    [self enableLocationService];
    [self arrangeTopUIBar];
    [self initVariables];
}
-(void)viewDidAppear:(BOOL)animated{
#if ENABLE_FIREBASE_TAG_MANAGER
    [[AnalyticsHelper sharedInstance] registerVisitScreenEvent:@"Address Screen"];
#endif
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)viewWillAppear:(BOOL)animated {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [self loadAllViews];
}
- (void)viewWillDisappear:(BOOL)animated {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
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
#pragma mark - Fetch Core Location
- (void)enableLocationService {
    if (_dataManager.locationDataFetched == false) {
        locationManager = [[CLLocationManager alloc] init];
        geocoder = [[CLGeocoder alloc] init];
        if ([CLLocationManager locationServicesEnabled]) {
            RLOG(@"locationServicesEnabled");
            [self getCurrentLocation];
        }else{
            RLOG(@"locationServicesDisabled");
        }
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
        if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [locationManager requestWhenInUseAuthorization];
        }
        [locationManager startUpdatingLocation];
    }
}
- (void)getCurrentLocation {
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    RLOG(@"didFailWithError: %@", error);
    RLOG(@"LOCATION FETCHED:FAILED");
}
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    CLLocation *currentLocation = newLocation;
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error == nil && [placemarks count] > 0) {
            placemark = [placemarks lastObject];
            _dataManager.userTempPostalCode = placemark.postalCode;
            _dataManager.userTempCity = placemark.locality;
            _dataManager.userTempState = placemark.administrativeArea;
            _dataManager.userTempCountry = placemark.country;
            _dataManager.locationDataFetched = true;
            RLOG(@"LOCATION FETCHED:SUCCEED");
            [locationManager stopUpdatingLocation];
            if (self.popupController != nil){
                [self updateLocationBasedUI];
            }
        }
    } ];
}
- (void)locationManager:(CLLocationManager*)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusNotDetermined: {
            [locationManager startUpdatingLocation];
        } break;
        case kCLAuthorizationStatusDenied: {
            [locationManager stopUpdatingLocation];
        } break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorizedAlways: {
            [locationManager startUpdatingLocation];
        } break;
        default:
            break;
    }
}
#pragma mark - Update Views
- (void)arrangeTopUIBar {
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
}
- (void)updateLocationBasedUI {
    
}
- (void)updateViews {
    
}
#pragma mark - Initialize Variables & Views
- (void)initVariables {
    _dataManager = [DataManager sharedManager];
    _defaultHeight = 0;
    _viewsAdded = [[NSMutableArray alloc] init];
    _vcCartConfirmation = nil;
    _isAddressOverConfirmationScreen = false;
    _appUser = [AppUser sharedManager];
    _billingButtons = [[NSMutableArray alloc] init];
    _shippingButtons = [[NSMutableArray alloc] init];
    _regionSequences = [[NSMutableArray alloc] initWithArray:[[[DataManager sharedManager] shippingEngine] regionSequences]];
}

- (void)loadAllViews {
    for (UIView* view in _viewsAdded) {
        [view removeFromSuperview];
    }
    [_viewsAdded removeAllObjects];
    
    [_labelViewHeading setText:Localize(@"address")];
    
    
    //shipping address
    [self addShippingHeaderView];
    
    if (_shippingButtons) {
        [_shippingButtons removeAllObjects];
    }
    [self addAddressView:_appUser._shipping_address];
    
    
    //billing address
    [self addBillingHeaderView];
    
    if (_billingButtons) {
        [_billingButtons removeAllObjects];
    }
    [self addAddressView:_appUser._billing_address];
    [self resetMainScrollView];
    [self updateViews];
}
- (void)addBillingHeaderView {
    _billingViews = [[NSMutableArray alloc] init];
    _billingHeaderView = [[UIView alloc] init];
    
    UIView* view = _billingHeaderView;
    [_scrollView addSubview:view];
    [_viewsAdded addObject:view];
    [view setTag:kTagForNoSpacing];
    
    [view setFrame: CGRectMake(0, 0, _scrollView.frame.size.width, 50)];
    [view setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [view setBackgroundColor:[Utility getUIColor:kUIColorClear]];
    
    UILabel* label = [[UILabel alloc] init];
    [label setUIFont:kUIFontType20 isBold:false];
    [label setText:Localize(@"billing_address")];
    [label setTextColor:[Utility getUIColor:kUIColorFontDark]];
    [label setFrame:_billingHeaderView.frame];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [view addSubview:label];
}
- (void)addShippingHeaderView {
    _shippingViews = [[NSMutableArray alloc] init];
    _shippingHeaderView = [[UIView alloc] init];
    
    UIView* view = _shippingHeaderView;
    [_scrollView addSubview:view];
    [_viewsAdded addObject:view];
    [view setTag:kTagForNoSpacing];
    
    [view setFrame: CGRectMake(0, 0, _scrollView.frame.size.width, 50)];
    [view setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [view setBackgroundColor:[Utility getUIColor:kUIColorClear]];
    
    UILabel* label = [[UILabel alloc] init];
    [label setUIFont:kUIFontType20 isBold:false];
    [label setText:Localize(@"shipping_address")];
    [label setTextColor:[Utility getUIColor:kUIColorFontDark]];
    [label setFrame:_shippingHeaderView.frame];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [view addSubview:label];
}
- (UIView*)addAddressView:(Address*)address {
    UIView* view = [[UIView alloc] init];
    if (_defaultHeight == 0) {
        _defaultHeight = [[MyDevice sharedManager] screenHeightInPortrait] * .3f;
    }
    
    [view setFrame: CGRectMake(self.view.frame.size.width * 0.01f, 0, self.view.frame.size.width * 0.98f, _defaultHeight)];
    [view.layer setValue:address forKey:@"setValue:"];
    [view setBackgroundColor:[UIColor whiteColor]];
    [_scrollView addSubview:view];
    [_viewsAdded addObject:view];
    [view setTag:kTagForGlobalSpacing];
    
    UIButton *buttonAddAddress = [[UIButton alloc] init];
    [[buttonAddAddress titleLabel] setUIFont:kUIFontType18 isBold:false];
    [buttonAddAddress setTitleColor:[Utility getUIColor:kUIColorFontDark] forState:UIControlStateNormal];
    [view addSubview:buttonAddAddress];
    [buttonAddAddress setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [buttonAddAddress setTitle:@"" forState:UIControlStateNormal];
    if (address._isBillingAddress) {
        [buttonAddAddress addTarget:self action:@selector(selectBillingAddressClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_billingButtons addObject:buttonAddAddress];
    }
    if (address._isShippingAddress) {
        [buttonAddAddress addTarget:self action:@selector(selectShippingAddressClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_shippingButtons addObject:buttonAddAddress];
    }
    [buttonAddAddress.layer setBorderColor:[[Utility getUIColor:kUIColorThemeButtonBorderSelected] CGColor]];
    [[buttonAddAddress layer] setValue:address forKey:@"ADDRESS_OBJ"];
    
    if (address._isAddressSaved == false) {
        [buttonAddAddress setTitle:Localize(@"i_add_address") forState:UIControlStateNormal];
        [buttonAddAddress addTarget:self action:@selector(addAddressClicked:) forControlEvents:UIControlEventTouchUpInside];
        
    } else {
        [buttonAddAddress setTitle:@"" forState:UIControlStateNormal];
        if (address._isBillingAddress) {
            [buttonAddAddress addTarget:self action:@selector(selectBillingAddressClicked:) forControlEvents:UIControlEventTouchUpInside];
            [_billingButtons addObject:buttonAddAddress];
        }
        if (address._isShippingAddress) {
            [buttonAddAddress addTarget:self action:@selector(selectShippingAddressClicked:) forControlEvents:UIControlEventTouchUpInside];
            [_shippingButtons addObject:buttonAddAddress];
        }
        [buttonAddAddress.layer setBorderColor:[[Utility getUIColor:kUIColorThemeButtonBorderSelected] CGColor]];
    }
    
    
    
    if (address._isAddressSaved == false) {
        [[buttonAddAddress layer] setValue:address forKey:@"ADDRESS_OBJ"];
        if (address._isBillingAddress) {
            _buttonCreateBilling = buttonAddAddress;
        } else {
            _buttonCreateShipping= buttonAddAddress;
        }
    } else {
        [[buttonAddAddress layer] setValue:address forKey:@"ADDRESS_OBJ"];
    }
    
    
    
    
    
    
    
    
    
    
    if (address._isAddressSaved) {
        UILabel* temp = [self createLabel:view fontType:kUIFontType24 fontColorType:kUIColorFontLight frame:CGRectMake(0, 0, 0, 0) textStr:Localize(@"change")];
        [temp sizeToFitUI];
        CGSize btnSize = LABEL_SIZE(temp);
        float height = btnSize.height;
        [temp removeFromSuperview];
        float posX = view.frame.size.width * 0.05f;
        float posY = view.frame.size.width * 0.05f;
        float width = view.frame.size.width * 0.90f;
        float btnW = btnSize.width * 1.5f;
        float btnH = btnSize.height * 1.5f;
        float btnX = view.frame.size.width - btnW;
        float btnY = 0;
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(btnX, btnY, btnW, btnH)];
        [[button titleLabel] setUIFont:kUIFontType18 isBold:false];
        [button setTitle:Localize(@"change") forState:UIControlStateNormal];
        [button setTitleColor:[Utility getUIColor:kUIColorBlue] forState:UIControlStateNormal];
        [view addSubview:button];
        [[button layer] setValue:address forKey:@"ADDRESS_OBJ"];
        [button addTarget:self action:@selector(editAddressClicked:) forControlEvents:UIControlEventTouchUpInside];
        if (address._isBillingAddress) {
            _buttonEditBilling = button;
        } else {
            _buttonEditShipping = button;
        }
        
        UILabel* name = [self createLabel:view fontType:kUIFontType22 fontColorType:kUIColorFontLight frame:CGRectMake(posX, posY, width, height) textStr:[NSString stringWithFormat:@"%@ %@", address._first_name, address._last_name]];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [name setText:[NSString stringWithFormat:@"%@ %@", address._last_name, address._first_name]];
        }else{
            [name setText:[NSString stringWithFormat:@"%@ %@", address._first_name, address._last_name]];
        }
        posY += LABEL_SIZE(name).height;
        [name setTag:_kTAGTEXTLABEL_FIRST_NAME];
        if (![[[Addons sharedManager] excludedAddress] isVisibleFirstName:address._isBillingAddress]) {
            name.hidden = true;
            posY -= LABEL_SIZE(name).height;
        }
        
        UILabel* address1 = [self createLabel:view fontType:kUIFontType18 fontColorType:kUIColorFontLight frame:CGRectMake(posX, posY, width, height) textStr:Localize(@"address1")];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            if ([Localize(@"address1") isEqualToString:@""]) {
                [address1 setText:[NSString stringWithFormat:@"%@", address._address_1]];
            } else {
                [address1 setText:[NSString stringWithFormat:@"%@ : %@", address._address_1, Localize(@"address1")]];
            }
        } else {
            if ([Localize(@"address1") isEqualToString:@""]) {
                [address1 setText:[NSString stringWithFormat:@"%@", address._address_1]];
            } else {
                [address1 setText:[NSString stringWithFormat:@"%@ : %@", Localize(@"address1"), address._address_1]];
            }
        }
        posY += LABEL_SIZE(address1).height;
        [address1 setTag:_kTAGTEXTLABEL_ADDRESS1];
        if (![[[Addons sharedManager] excludedAddress] isVisibleAddress1:address._isBillingAddress]) {
            address1.hidden = true;
            posY -= LABEL_SIZE(address1).height;
        }
        
        UILabel* address2 = [self createLabel:view fontType:kUIFontType18 fontColorType:kUIColorFontLight frame:CGRectMake(posX, posY, width, height) textStr:Localize(@"address2")];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            if ([Localize(@"address2") isEqualToString:@""]) {
                [address2 setText:[NSString stringWithFormat:@"%@", address._address_2]];
            } else {
                [address2 setText:[NSString stringWithFormat:@"%@ : %@", address._address_2, Localize(@"address2")]];
            }
        } else {
            if ([Localize(@"address2") isEqualToString:@""]) {
                [address2 setText:[NSString stringWithFormat:@"%@", address._address_2]];
            } else {
                [address2 setText:[NSString stringWithFormat:@"%@ : %@", Localize(@"address2"), address._address_2]];
            }
        }
        if ([Localize(@"address2") isEqualToString:@""]) {
            [address2 setText:[NSString stringWithFormat:@"%@", address._address_2]];
        }
        posY += LABEL_SIZE(address2).height;
        [address2 setTag:_kTAGTEXTLABEL_ADDRESS2];
        if (![[[Addons sharedManager] excludedAddress] isVisibleAddress2:address._isBillingAddress]) {
            address2.hidden = true;
            posY -= LABEL_SIZE(address2).height;
        }
        NSArray* reversedObjects = [[_regionSequences reverseObjectEnumerator] allObjects];
        for (NSNumber* num in reversedObjects) {
            int i = [num intValue];
            UILabel* labelRegion = [self createLabel:view fontType:kUIFontType18 fontColorType:kUIColorFontLight frame:CGRectMake(posX, posY, width, height) textStr:[NSString stringWithFormat:@"%@", Localize(REGION_SEQUENCE_STRINGS[i])]];
            int labelTag = -1;
            NSString* regionTitle = @"";
            NSString* regionId = @"";

            BOOL isVisible = true;
            switch (i) {
                case REGION_SEQUENCE_COUNTRY:
                    labelTag = _kTAGTEXTLABEL_COUNTRY;
                    regionTitle = address._country;
                    regionId = address._countryId;
                    isVisible = [[[Addons sharedManager] excludedAddress] isVisibleCountry:address._isBillingAddress];
                    break;
                case REGION_SEQUENCE_STATE:
                    labelTag = _kTAGTEXTLABEL_STATE;
                    regionTitle = address._state;
                    regionId = address._stateId;
                    isVisible = [[[Addons sharedManager] excludedAddress] isVisibleState:address._isBillingAddress];
                    break;
                case REGION_SEQUENCE_CITY:
                    labelTag = _kTAGTEXTLABEL_CITY;
                    regionTitle = address._city;
                    regionId = address._cityId;
                    isVisible = [[[Addons sharedManager] excludedAddress] isVisibleCity:address._isBillingAddress];
                    break;
                case REGION_SEQUENCE_DISTRICT:
                    labelTag = _kTAGTEXTLABEL_DISTRICT;
                    regionTitle = address._district;
                    regionId = address._districtId;
                    isVisible = [[[Addons sharedManager] excludedAddress] isVisibleDistrict:address._isBillingAddress];
                    break;
                    
                case REGION_SEQUENCE_SUBDISTRICT:
                    labelTag = _kTAGTEXTLABEL_SUBDISTRICT;
                    regionTitle = address._subdistrict;
                    regionId = address._subdistrictId;
                    isVisible = [[[Addons sharedManager] excludedAddress] isVisibleSubdistrict:address._isBillingAddress];
                    break;
                default:
                    break;
            }
            
            if (regionTitle == nil || [regionTitle isEqualToString:@""]) {
                if (regionId != nil && ![regionId isEqualToString:@""]) {
                    //todo find region title here and set
                    NSString* regionType = @"";
                    DataManager* dm = [DataManager sharedManager];
                    if (dm.shippingProvider == SHIPPING_PROVIDER_RAJAONGKIR) {
                        switch (i) {
                            case REGION_SEQUENCE_COUNTRY:
                            {
                                regionType = @"country";
                                TMRegion* tmregion = [TMRegion findRegionFromId:regionId regionType:regionType regionParent:nil];
                                if (tmregion) {
                                    regionTitle = tmregion.regionTitle;
                                    address._country = regionTitle;
                                }
                            }break;
                            default:
                                break;
                        }
                    } else if (dm.shippingProvider == SHIPPING_PROVIDER_WOOCOMMERCE) {
                        switch (i) {
                            case REGION_SEQUENCE_COUNTRY:
                            {
                                regionType = @"country";
                                TMRegion* tmregion = [TMRegion findRegionFromId:regionId regionType:regionType regionParent:nil];
                                if (tmregion) {
                                    regionTitle = tmregion.regionTitle;
                                    address._country = regionTitle;
                                }
                            }break;
                            case REGION_SEQUENCE_STATE:
                            {
                                regionType = @"country";
                                TMRegion* tmregionParent = [TMRegion findRegionFromId:address._countryId regionType:regionType regionParent:nil];
                                
                                regionType = @"state";
                                TMRegion* tmregion = [TMRegion findRegionFromId:regionId regionType:regionType regionParent:tmregionParent];
                                if (tmregion) {
                                    regionTitle = tmregion.regionTitle;
                                    address._state = regionTitle;
                                }
                                
//                                regionType = @"state";
//                                TMRegion* tmregion = [TMRegion findRegionFromId:regionId regionType:regionType];
//                                if (tmregion) {
//                                    regionTitle = tmregion.regionTitle;
//                                    address._state = regionTitle;
//                                }
                            }break;
                            default:
                                break;
                        }
                    }
                }
            }
            if ([[TMLanguage sharedManager] isRTLEnabled]) {
                [labelRegion setText:[NSString stringWithFormat:@"%@ : %@", regionTitle, Localize(REGION_SEQUENCE_STRINGS[i])]];
            } else {
                [labelRegion setText:[NSString stringWithFormat:@"%@ : %@", Localize(REGION_SEQUENCE_STRINGS[i]), regionTitle]];
            }
            posY += LABEL_SIZE(labelRegion).height;
            [labelRegion setTag:labelTag];
            if (regionTitle == nil || [regionTitle isEqualToString:@""]) {
                labelRegion.hidden = true;
                posY -= LABEL_SIZE(labelRegion).height;
            }
            if (!isVisible) {
                if (labelRegion.hidden == false) {
                    labelRegion.hidden = true;
                    posY -= LABEL_SIZE(labelRegion).height;
                }
            }
        }
        
        UILabel* postalCode = [self createLabel:view fontType:kUIFontType18 fontColorType:kUIColorFontLight frame:CGRectMake(posX, posY, width, height) textStr:Localize(@"postcode")];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [postalCode setText:[NSString stringWithFormat:@"%@ : %@", address._postcode, Localize(@"postcode")]];
        } else {
            [postalCode setText:[NSString stringWithFormat:@"%@ : %@", Localize(@"postcode"), address._postcode]];
        }
        posY += LABEL_SIZE(postalCode).height;
        [postalCode setTag:_kTAGTEXTLABEL_POSTAL];
        if (![[[Addons sharedManager] excludedAddress] isVisiblePostCode:address._isBillingAddress]) {
            postalCode.hidden = true;
            posY -= LABEL_SIZE(postalCode).height;
        }
        
        
        UILabel* email = [self createLabel:view fontType:kUIFontType18 fontColorType:kUIColorFontLight frame:CGRectMake(posX, posY, width, height) textStr: Localize(@"email")];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [email setText:[NSString stringWithFormat:@"%@ : %@", address._email, Localize(@"email")]];
        } else {
            [email setText:[NSString stringWithFormat:@"%@ : %@", Localize(@"email"), address._email]];
        }
        posY += LABEL_SIZE(email).height;
        [email setTag:_kTAGTEXTLABEL_EMAIL];
        if (![[[Addons sharedManager] excludedAddress] isVisibleEmail:address._isBillingAddress]) {
            email.hidden = true;
            posY -= LABEL_SIZE(email).height;
        }
        
        UILabel* phone = [self createLabel:view fontType:kUIFontType18 fontColorType:kUIColorFontLight frame:CGRectMake(posX, posY, width, height) textStr:Localize(@"contact_number")];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [phone setText:[NSString stringWithFormat:@"%@ : %@", address._phone, Localize(@"contact_number")]];
        } else {
            [phone setText:[NSString stringWithFormat:@"%@ : %@", Localize(@"contact_number"), address._phone]];
        }
        posY += LABEL_SIZE(phone).height;
        [phone setTag:_kTAGTEXTLABEL_CONTACT];
        if (![[[Addons sharedManager] excludedAddress] isVisiblePhone:address._isBillingAddress]) {
            phone.hidden = true;
            posY -= LABEL_SIZE(phone).height;
        }
        
        
        posY += view.frame.size.width * 0.025f;
        
        CGRect viewRect = view.frame;
        viewRect.size.height = posY;
        view.frame = viewRect;
        _defaultHeight = posY;
    }
    
    buttonAddAddress.frame = CGRectMake(5, 5, view.frame.size.width - 10, view.frame.size.height - 10);
    
    [Utility showShadow:view];
    return view;
}
- (void)unloadPopupView {
    
    for (int i = 0; i < REGION_SEQUENCE_TOTAL; i++) {
        if (_regionTextFields[i]) {
            [_regionTextFields[i] removeFromSuperview];
            _regionTextFields[i] = nil;
        }
        if (_regionSelectionUIButtons[i]) {
            [_regionSelectionUIButtons[i] removeFromSuperview];
            _regionSelectionUIButtons[i] = nil;
        }
        if (_regionSelectionImgArrows[i]) {
            [_regionSelectionImgArrows[i] removeFromSuperview];
            _regionSelectionImgArrows[i] = nil;
        }
        if (_regionDropdownViews[i]) {
            [_regionDropdownViews[i] removeFromSuperview];
            _regionDropdownViews[i] = nil;
        }
        if (_regionObjs[i]) {
            _regionObjs[i] = nil;
        }
//        if (_regionDataObjects[i]) {
//            [_regionDataObjects[i] removeAllObjects];
//            _regionDataObjects[i] = nil;
//        }
//        if (_regionTMRegionObjects[i]) {
//            [_regionTMRegionObjects[i] removeAllObjects];
//            _regionTMRegionObjects[i] = nil;
//        }
    }
    
    
    [self.popupController dismissPopupControllerAnimated:YES];
    for (UIView* v in [_viewMainChildPopoverView subviews]) {
        [v removeFromSuperview];
    }
}
- (void)loadPopupView:(Address*)address {
    float widthView, heightView;
    if ([[MyDevice sharedManager] isIpad]) {
        widthView = [[MyDevice sharedManager] screenWidthInPortrait] * 0.65f;
        heightView = [[MyDevice sharedManager] screenHeightInPortrait] * 0.63f;
    }else if ([[MyDevice sharedManager] isIphone]) {
        widthView = [[MyDevice sharedManager] screenSize].width * 1.0f;
        heightView = [[MyDevice sharedManager] screenSize].height *1.0f;
    }
    
    UIView* viewMain = nil;
    if (self.popupController == nil) {
        viewMain = [[UIView alloc] initWithFrame:CGRectMake(0, 0, widthView, heightView)];
        viewMain.backgroundColor = [Utility getUIColor:kUIColorBgTheme];
        viewMain.center = CGPointMake(widthView/2, heightView/2);
        
        _viewMainChildPopoverView = viewMain;
        self.popupController = [[CNPPopupController alloc] initWithContents:@[_viewMainChildPopoverView]];
        self.popupController.theme = [CNPPopupTheme addressTheme];
        
        if ([[MyDevice sharedManager] isIphone]) {
            self.popupController.theme.cornerRadius = 0.0f;
            self.popupController.theme.popupContentInsets = UIEdgeInsetsMake(16.0f+11.0f, 16.0f, 16.0f, 16.0f);
        }
        
        
    }
    viewMain = _viewMainChildPopoverView;
    UIView* viewTop = [[UIView alloc] initWithFrame:CGRectMake(0, 0, widthView, heightView * 0.05f)];
    viewTop.backgroundColor = [UIColor whiteColor];
    [viewMain addSubview:viewTop];
    self.popupController.theme.popupStyle = CNPPopupStyleCentered;
    self.popupController.theme.size = CGSizeMake(widthView, heightView);
    self.popupController.theme.maxPopupWidth = widthView;
    self.popupController.delegate = self;
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        self.popupController.VIEW_POPUP.transform = CGAffineTransformMakeScale(-1, 1);
    }
    _buttonCancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, viewTop.frame.size.width, viewTop.frame.size.height)];
    [[_buttonCancel titleLabel] setUIFont:kUIFontType18 isBold:false];
    [_buttonCancel setTitle:Localize(@"cancel") forState:UIControlStateNormal];
    [_buttonCancel setTitleColor:[Utility getUIColor:kUIColorBlue] forState:UIControlStateNormal];
    [viewTop addSubview:_buttonCancel];
    [_buttonCancel addTarget:self action:@selector(cancelClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_buttonCancel sizeToFit];
    [_buttonCancel setFrame:CGRectMake(0, -16, _buttonCancel.frame.size.width * 2 + 16, viewTop.frame.size.height + 16)];
    _buttonCancel.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _buttonCancel.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
    _buttonCancel.titleEdgeInsets = UIEdgeInsetsMake(0, 16, 0, 16);
    
    
    _buttonSave = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, viewTop.frame.size.width, viewTop.frame.size.height)];
    [[_buttonSave titleLabel] setUIFont:kUIFontType18 isBold:false];
    [_buttonSave setTitle:Localize(@"i_save") forState:UIControlStateNormal];
    [_buttonSave setTitleColor:[Utility getUIColor:kUIColorBlue] forState:UIControlStateNormal];
    [viewTop addSubview:_buttonSave];
    [_buttonSave addTarget:self action:@selector(saveClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_buttonSave sizeToFit];
    [_buttonSave setFrame:CGRectMake(viewTop.frame.size.width - viewTop.frame.size.width * 0.04f - _buttonSave.frame.size.width * 2, -16, _buttonSave.frame.size.width * 2 + 16, viewTop.frame.size.height + 16)];
    _buttonSave.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    _buttonSave.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
    _buttonSave.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 16);
    [_buttonSave.layer setValue:address forKey:@"ADDRESS_OBJ"];
    
    _labelTitle = [self createLabel:viewTop fontType:kUIFontType20 fontColorType:kUIColorFontDark frame:CGRectMake(0, 0, viewTop.frame.size.width, viewTop.frame.size.height) textStr:Localize(@"address")];
    [_labelTitle setTextAlignment:NSTextAlignmentCenter];
    float posX = viewMain.frame.size.width * 0.05f;
    float posY = CGRectGetMaxY(viewTop.frame); // + viewMain.frame.size.width * 0.05f;
    float width = viewMain.frame.size.width * 0.90f;
    float height = (viewMain.frame.size.height - (posY - viewTop.frame.size.height) - posY)/12;
    height = 50;
    _addressViewPopupElementRect = CGRectMake(posX, posY, width, height);
    int fontType;
    if ([[MyDevice sharedManager] isIpad]) {
        fontType = kUIFontType18;
    } else {
        fontType = kUIFontType24;
    }
    NSString* mandatorySymbol = @"*";
    
    BOOL isVisibleFirstName = [[[Addons sharedManager] excludedAddress] isVisibleFirstName:address._isBillingAddress];
    BOOL isVisibleLastName = [[[Addons sharedManager] excludedAddress] isVisibleLastName:address._isBillingAddress];
    BOOL isVisibleAddress1 = [[[Addons sharedManager] excludedAddress] isVisibleAddress1:address._isBillingAddress];
    BOOL isVisibleAddress2 = [[[Addons sharedManager] excludedAddress] isVisibleAddress2:address._isBillingAddress];
    BOOL isVisibleCity = [[[Addons sharedManager] excludedAddress] isVisibleCity:address._isBillingAddress];
    BOOL isVisibleCountry = [[[Addons sharedManager] excludedAddress] isVisibleCountry:address._isBillingAddress];
    BOOL isVisibleEmail = [[[Addons sharedManager] excludedAddress] isVisibleEmail:address._isBillingAddress];
    BOOL isVisiblePhone = [[[Addons sharedManager] excludedAddress] isVisiblePhone:address._isBillingAddress];
    BOOL isVisiblePostCode = [[[Addons sharedManager] excludedAddress] isVisiblePostCode:address._isBillingAddress];
    BOOL isVisibleState = [[[Addons sharedManager] excludedAddress] isVisibleState:address._isBillingAddress];
    BOOL isVisibleDistrict = [[[Addons sharedManager] excludedAddress] isVisibleDistrict:address._isBillingAddress];
    BOOL isVisibleSubdistrict = [[[Addons sharedManager] excludedAddress] isVisibleSubdistrict:address._isBillingAddress];
    
    if (isVisibleFirstName && isVisibleLastName) {
        _textFirstName = [self createTextField:viewMain fontType:fontType fontColorType:kUIColorFontLight frame:CGRectMake(posX, posY, width/2, height) tag:_kTAGTEXTFIELD_FIRSTNAME textStrPlaceHolder:[NSString stringWithFormat:@"%@%@", mandatorySymbol, Localize(@"first_name")]];
        
        _textLastName = [self createTextField:viewMain fontType:fontType fontColorType:kUIColorFontLight frame:CGRectMake(posX + width/2, posY, width/2, height) tag:_kTAGTEXTFIELD_LASTNAME textStrPlaceHolder:[NSString stringWithFormat:@"%@%@", mandatorySymbol, Localize(@"last_name")]];
        posY += height;
    } else if (isVisibleFirstName) {
        _textFirstName = [self createTextField:viewMain fontType:fontType fontColorType:kUIColorFontLight frame:CGRectMake(posX, posY, width, height) tag:_kTAGTEXTFIELD_FIRSTNAME textStrPlaceHolder:[NSString stringWithFormat:@"%@%@", mandatorySymbol, Localize(@"first_name")]];
        posY += height;
        
    } else if (isVisibleLastName) {
        _textLastName = [self createTextField:viewMain fontType:fontType fontColorType:kUIColorFontLight frame:CGRectMake(posX, posY, width, height) tag:_kTAGTEXTFIELD_LASTNAME textStrPlaceHolder:[NSString stringWithFormat:@"%@%@", mandatorySymbol, Localize(@"last_name")]];
        posY += height;
        
    }
    
    
    if (isVisibleAddress1) {
        _textAddress1 = [self createTextField:viewMain fontType:fontType fontColorType:kUIColorFontLight frame:CGRectMake(posX, posY, width, height) tag:_kTAGTEXTFIELD_ADDRESS1 textStrPlaceHolder:[NSString stringWithFormat:@"%@%@", mandatorySymbol, Localize(@"address1")]];
        posY += height;
    }
    
    if (isVisibleAddress2) {
        _textAddress2 = [self createTextField:viewMain fontType:fontType fontColorType:kUIColorFontLight frame:CGRectMake(posX, posY, width, height) tag:_kTAGTEXTFIELD_ADDRESS2 textStrPlaceHolder:[NSString stringWithFormat:@"%@%@", mandatorySymbol, Localize(@"address2")]];
        posY += height;
    }
    
    for (NSNumber* num in _regionSequences) {
        int i = [num intValue];
        int textFieldTag = -1;
        NSString* placeholderString = @"";
        BOOL isVisible = true;
        switch (i) {
            case REGION_SEQUENCE_COUNTRY:
                textFieldTag = _kTAGTEXTLABEL_COUNTRY;
                isVisible = isVisibleCountry;
                break;
            case REGION_SEQUENCE_STATE:
                textFieldTag = _kTAGTEXTLABEL_STATE;
                isVisible = isVisibleState;
                break;
            case REGION_SEQUENCE_CITY:
                textFieldTag = _kTAGTEXTLABEL_CITY;
                isVisible = isVisibleCity;
                break;
            case REGION_SEQUENCE_DISTRICT:
                textFieldTag = _kTAGTEXTLABEL_DISTRICT;
                isVisible = isVisibleDistrict;
                break;
            case REGION_SEQUENCE_SUBDISTRICT:
                textFieldTag = _kTAGTEXTLABEL_SUBDISTRICT;
                isVisible = isVisibleSubdistrict;
                break;
            default:
                break;
        }
        if (isVisible) {
            placeholderString = Localize(REGION_SEQUENCE_STRINGS[i]);
            _regionTextFields[i] = [self createTextField:viewMain fontType:fontType fontColorType:kUIColorFontLight frame:CGRectMake(posX, posY, width, height) tag:textFieldTag textStrPlaceHolder:[NSString stringWithFormat:@"%@%@", mandatorySymbol, placeholderString]];
            posY += height;
        }else {
            _regionTextFields[i] = nil;
            
        }
    }
    
    if (isVisiblePostCode) {
        _textPostalCode = [self createTextField:viewMain fontType:fontType fontColorType:kUIColorFontLight frame:CGRectMake(posX, posY, width, height) tag:_kTAGTEXTFIELD_POSTAL textStrPlaceHolder:[NSString stringWithFormat:@"%@%@", mandatorySymbol, Localize(@"postcode")]];
        posY += height;
    }
    
    if (isVisibleEmail) {
        _textEmail = [self createTextField:viewMain fontType:fontType fontColorType:kUIColorFontLight frame:CGRectMake(posX, posY, width, height) tag:_kTAGTEXTFIELD_EMAIL textStrPlaceHolder:[NSString stringWithFormat:@"%@%@", mandatorySymbol, Localize(@"email")]];
        
        posY += height;
    }
    
    if (isVisiblePhone) {
        _textContactNumber = [self createTextField:viewMain fontType:fontType fontColorType:kUIColorFontLight frame:CGRectMake(posX, posY, width, height) tag:_kTAGTEXTFIELD_CONTACT textStrPlaceHolder:[NSString stringWithFormat:@"%@%@", mandatorySymbol, Localize(@"contact_number")]];
        [_textContactNumber setKeyboardType:UIKeyboardTypePhonePad];
        if ([[MyDevice sharedManager] isIphone]) {
            UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
            numberToolbar.backgroundColor = [UIColor lightGrayColor];
            UIBarButtonItem* doneBtn = [[UIBarButtonItem alloc]initWithTitle:Localize(@"done") style:UIBarButtonItemStyleBordered target:self action:@selector(doneWithNumberPad:)];
            numberToolbar.items = @[[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                    doneBtn];
            [numberToolbar sizeToFit];
            _textContactNumber.inputAccessoryView = numberToolbar;
        }
        posY += height;
    }
    
    
    _chkBoxCopyAddress = [[UIButton alloc] init];
    _chkBoxCopyAddress.frame = CGRectMake(posX + 10, posY + height / 4, width, height);
    if ([[MyDevice sharedManager] isIphone]) {
        _chkBoxCopyAddress.frame = CGRectMake(posX + 5, posY + height / 4, width, height);
    }
    [_chkBoxCopyAddress addTarget:self action:@selector(chkBoxButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [viewMain addSubview:_chkBoxCopyAddress];
    [_chkBoxCopyAddress setUIImage:[UIImage imageNamed:@"chkbox_unselected"] forState:UIControlStateNormal];
    [_chkBoxCopyAddress setUIImage:[UIImage imageNamed:@"chkbox_selected"] forState:UIControlStateSelected];
    [_chkBoxCopyAddress setTitleColor:[Utility getUIColor:kUIColorFontLight] forState:UIControlStateNormal];
    [_chkBoxCopyAddress setTitleColor:[Utility getUIColor:kUIColorFontLight] forState:UIControlStateSelected];
    if ([[MyDevice sharedManager] isIphone]) {
        [_chkBoxCopyAddress.titleLabel setUIFont:fontType-1 isBold:false];
    }else{
        [_chkBoxCopyAddress.titleLabel setUIFont:fontType isBold:false];
    }
    _chkBoxCopyAddress.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_chkBoxCopyAddress setSelected:YES];
    [_chkBoxCopyAddress.layer setValue:address forKey:@"ADDRESS_OBJ"];
    posY += height;
    
    
    if (address._isBillingAddress) {
        [_chkBoxCopyAddress setTitle:[NSString stringWithFormat:Localize(@"i_use_same_for_shipping"), @""] forState:UIControlStateNormal];
        [_chkBoxCopyAddress setTag:CHKBOX_PROP_COPY_TO_SHIPPING];
    }
    if (address._isShippingAddress) {
        [_chkBoxCopyAddress setTitle:[NSString stringWithFormat:Localize(@"i_use_same_for_billing"), @""] forState:UIControlStateNormal];
        [_chkBoxCopyAddress setTag:CHKBOX_PROP_COPY_TO_BILLING];
    }
    
    
    
    
    
    
    posY += height;
    CGRect viewMainRect = viewMain.frame;
    if ([[MyDevice sharedManager] isIpad]) {
        viewMainRect.size = CGSizeMake(self.popupController.theme.size.width, posY);
        viewMain.frame = viewMainRect;
        self.popupController.theme.size = CGSizeMake(self.popupController.theme.size.width, posY);
    } else {
//        viewMainRect.size = CGSizeMake(self.popupController.theme.size.width, posY);
//        viewMain.frame = viewMainRect;
//        self.popupController.theme.size = CGSizeMake(self.popupController.theme.size.width, posY);
    }
    
    for (NSNumber* num in _regionSequences) {
        int i = [num intValue];
        BOOL isSelectionEnabled = false;
        switch (i) {
            case REGION_SEQUENCE_COUNTRY:
                isSelectionEnabled = [_dataManager.shippingEngine hasCountrySelection];
                break;
            case REGION_SEQUENCE_STATE:
                isSelectionEnabled = [_dataManager.shippingEngine hasStateSelection];
                break;
            case REGION_SEQUENCE_CITY:
                isSelectionEnabled = [_dataManager.shippingEngine hasCitySelection];
                break;
            case REGION_SEQUENCE_DISTRICT:
                isSelectionEnabled = [_dataManager.shippingEngine hasDistrictSelection];
                break;
            case REGION_SEQUENCE_SUBDISTRICT:
                isSelectionEnabled = [_dataManager.shippingEngine hasSubDistrictSelection];
                break;
                
            default:
                break;
        }
        if(_regionTextFields[i] && isSelectionEnabled) {
            _regionSelectionUIButtons[i] = [[UIButton alloc] init];
            _regionSelectionUIButtons[i].frame = _regionTextFields[i].frame;
            [_regionSelectionUIButtons[i] addTarget:self action:@selector(regionSelectionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [_regionSelectionUIButtons[i] setTitleColor:[Utility getUIColor:kUIColorFontLight] forState:UIControlStateNormal];
            [_regionSelectionUIButtons[i] setTitleColor:[Utility getUIColor:kUIColorFontLight] forState:UIControlStateSelected];
            [viewMain addSubview:_regionSelectionUIButtons[i]];
            [_regionSelectionUIButtons[i].titleLabel setUIFont:fontType isBold:false];
            if ([[MyDevice sharedManager] isIphone]) {
                [_regionSelectionUIButtons[i].titleLabel setUIFont:fontType - 1 isBold:false];
            }
            [_regionSelectionUIButtons[i] setContentVerticalAlignment:UIControlContentVerticalAlignmentBottom];
        }
        else {
            _regionSelectionUIButtons[i] = nil;
        }
    }
    
    for (NSNumber* num in _regionSequences) {
        int i = [num intValue];
        if(_regionSelectionUIButtons[i]) {
            float dropdownHeight = _regionTextFields[i].frame.size.height * 5.0f;
            _regionTextFields[i].enabled = false;
            _regionTextFields[i].userInteractionEnabled = false;
            _regionTextFields[i].hidden = false;
            _regionDataObjects[i] = [[NSMutableArray alloc] init];
            _regionDropdownViews[i] = [[NIDropDown alloc] init:_regionSelectionUIButtons[i] viewheight:dropdownHeight strArr:_regionDataObjects[i] imgArr:nil direction:NIDropDownDirectionDown pView:viewMain];
            
            [_regionSelectionUIButtons[i].layer setValue:_regionDropdownViews[i] forKey:@"DROPDOWNVIEW"];
            _regionDropdownViews[i].delegate = self;
            [viewMain addSubview:_regionDropdownViews[i]];
            _regionDropdownViews[i].backgroundColor = [UIColor blueColor];
            [_regionDropdownViews[i] toggleWithMainFrame:_regionSelectionUIButtons[i]];
            _regionSelectionImgArrows[i] = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"img_arrow_down_white"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
            [_regionSelectionImgArrows[i] setTintColor:[Utility getUIColor:kUIColorFontLight]];
            [_regionSelectionImgArrows[i] setHidden:true];//rj todo
            if ([[TMLanguage sharedManager] isRTLEnabled]) {
                _regionSelectionImgArrows[i].frame = CGRectMake(_regionSelectionImgArrows[i].frame.size.width, (_regionTextFields[i].frame.size.height - _regionSelectionImgArrows[i].frame.size.height) - 10, _regionSelectionImgArrows[i].frame.size.width, _regionSelectionImgArrows[i].frame.size.height);
            } else {
                _regionSelectionImgArrows[i].frame = CGRectMake(_regionTextFields[i].frame.size.width - _regionSelectionImgArrows[i].frame.size.width * 2, (_regionTextFields[i].frame.size.height - _regionSelectionImgArrows[i].frame.size.height) - 10, _regionSelectionImgArrows[i].frame.size.width, _regionSelectionImgArrows[i].frame.size.height);
            }
            [_regionTextFields[i] addSubview:_regionSelectionImgArrows[i]];
        }
    }
    
    [self.popupController presentPopupControllerAnimated:YES];
    
    for (NSNumber* num in _regionSequences)
    {
        int i = [num intValue];
        [self fetchLocale:i];
        [self recursiveFetchLocale:i address:(Address*)address];
        break;//rishabh
    }
    
    if (address._first_name == nil || (address._first_name && [address._first_name isEqualToString:@""])) {
        AppUser* appUser = [AppUser sharedManager];
        if(appUser._first_name && ![appUser._first_name isEqualToString:@""])
            address._first_name = appUser._first_name;
    }
    _textFirstName.text = address._first_name;
    
    
    
    
    if (address._last_name == nil || (address._last_name && [address._last_name isEqualToString:@""])) {
        AppUser* appUser = [AppUser sharedManager];
        if(appUser._last_name && ![appUser._last_name isEqualToString:@""])
            address._last_name = appUser._last_name;
    }
    _textLastName.text = address._last_name;
    
    
    _textAddress1.text = address._address_1;
    _textAddress2.text = address._address_2;
    
    
    if (address._email == nil || (address._email && [address._email isEqualToString:@""])) {
        AppUser* appUser = [AppUser sharedManager];
        if(appUser._email && ![appUser._email isEqualToString:@""])
            address._email = appUser._email;
    }
    _textEmail.text = address._email;
    
    
    if (address._phone == nil || (address._phone && [address._phone isEqualToString:@""])) {
        AppUser* appUser = [AppUser sharedManager];
        if(appUser._mobile_number && ![appUser._mobile_number isEqualToString:@""])
            address._phone = appUser._mobile_number;
    }
    _textContactNumber.text = address._phone;
    
    
    _textPostalCode.text = address._postcode;
    _textContactNumber.text = address._phone;
    
    for (NSNumber* num in _regionSequences) {
        int i = [num intValue];
        BOOL isVisible = true;
        NSString* title = @"";
        switch (i) {
            case REGION_SEQUENCE_COUNTRY:
                title = address._country;
                isVisible = isVisibleCountry;
                break;
            case REGION_SEQUENCE_STATE:
                title = address._state;
                isVisible = isVisibleState;
                break;
            case REGION_SEQUENCE_CITY:
                title = address._city;
                isVisible = isVisibleCity;
                break;
            case REGION_SEQUENCE_DISTRICT:
                title = address._district;
                isVisible = isVisibleDistrict;
                break;
            case REGION_SEQUENCE_SUBDISTRICT:
                title = address._subdistrict;
                isVisible = isVisibleSubdistrict;
                break;
            default:
                break;
        }
        if (isVisible) {
            _regionTextFields[i].text = title;
        }
    }
    
    
    
}
- (void)fetchLocale:(int)ii
       parentRegion:(TMRegion*)parentRegion
            success1:(void(^)(NSString* str))success1
            failure1:(void(^)(NSString* str))failure1 {
    
    __block int i = ii;
    if(_regionSelectionUIButtons[i])
    {
        {
            int j = i;
            if (_regionObjs[i] != nil && i < REGION_SEQUENCE_TOTAL - 1) {
                for (int k = i+1; k < REGION_SEQUENCE_TOTAL; k++) {
                    j = k;
                    if (_regionTextFields[j]) {
                        //start anim
                        break;
                    }
                }
            }
            [_regionSelectionImgArrows[j] setHidden:true];
        }
        [_dataManager.shippingEngine getChildRegions:parentRegion success:^(id data) {
            int j = i;
            if (_regionObjs[i] != nil && i < REGION_SEQUENCE_TOTAL - 1) {
                for (int k = i+1; k < REGION_SEQUENCE_TOTAL; k++) {
                    j = k;
                    if (_regionTextFields[j]) {
                        //stop anim
                        break;
                    }
                }
            }
            [_regionSelectionImgArrows[j] setHidden:false];
            
            if (data == nil) {
                return;
            }
            
            if ((int)[((NSArray*)data) count] == 0) {
                [_regionSelectionImgArrows[j] setHidden:true];
                [_regionTextFields[j] setText:Localize(@"i_state_data_not_available")];
            }
            
            NSMutableArray* mArray = [[NSMutableArray alloc] init];
            _regionTMRegionObjects[j] = data;
            for (TMRegion* regionObj in data) {
                [mArray addObject:regionObj.regionTitle];
            }
            _regionDataObjects[j] = [[NSMutableArray alloc] initWithArray:mArray];
            float dropdownHeight = _regionTextFields[j].frame.size.height * 5.0f;
            [_regionDropdownViews[j] updateDataObjects:_regionSelectionUIButtons[j] viewheight:dropdownHeight strArr:_regionDataObjects[j] imgArr:nil];
            success1(@"");
        } failure:^(NSString *error) {
            failure1(@"");
        }];
    }
}
- (void)recursiveFetchLocale:(int)regionSeq address:(Address*)address{
    __block int regionSeqCurrent = regionSeq;
    TMRegion* parentRegion = nil;
    if (regionSeqCurrent > 0) {
        parentRegion = _regionObjs[regionSeqCurrent-1];
    }
    [self fetchLocale:regionSeqCurrent
         parentRegion:parentRegion
             success1:^(NSString *str) {
        int clickedItemId = 0;
        int itemFoundAtId = 0;
        for (TMRegion* region in _regionTMRegionObjects[regionSeqCurrent]) {
            switch (regionSeqCurrent) {
                case REGION_SEQUENCE_COUNTRY:
                    if ([region.regionId isEqualToString:address._countryId] && [region.regionType isEqualToString:@"country"]) {
                        itemFoundAtId = clickedItemId;
                        _regionObjs[regionSeqCurrent] = region;
                        break;
                    }
                    break;
                case REGION_SEQUENCE_STATE:
                    if ([region.regionId isEqualToString:address._stateId] && [region.regionType isEqualToString:@"state"]) {
                        itemFoundAtId = clickedItemId;
                        _regionObjs[regionSeqCurrent] = region;
                        break;
                    }
                    break;
                default:
                    break;
            }
            clickedItemId++;
        }
                 
                 if (_regionTMRegionObjects[regionSeqCurrent] && [_regionTMRegionObjects[regionSeqCurrent] count] > itemFoundAtId) {
                     [self reponseDropDownDelegate:_regionDropdownViews[regionSeqCurrent] clickedItemId:itemFoundAtId];
                 }
                 
        
        
        BOOL isNextOneFound = false;
        for (NSNumber* num in _regionSequences) {
            int i = [num intValue];
            if (isNextOneFound) {
                [self recursiveFetchLocale:i address:address];
            }
            if (i == regionSeqCurrent) {
                isNextOneFound = true;
            }
        }
    } failure1:^(NSString *str) {
        
    }];
}
- (void)fetchLocale:(int)i {
    if(_regionSelectionUIButtons[i])
    {
        {
            int j = i;
            if (_regionObjs[i] != nil && i < REGION_SEQUENCE_TOTAL - 1) {
                for (int k = i+1; k < REGION_SEQUENCE_TOTAL; k++) {
                    j = k;
                    if (_regionTextFields[j]) {
                        //start anim
                        break;
                    }
                }
            }
            [_regionSelectionImgArrows[j] setHidden:true];
        }
        [_dataManager.shippingEngine getChildRegions:_regionObjs[i] success:^(id data) {
            int j = i;
            if (_regionObjs[i] != nil && i < REGION_SEQUENCE_TOTAL - 1) {
                for (int k = i+1; k < REGION_SEQUENCE_TOTAL; k++) {
                    j = k;
                    if (_regionTextFields[j]) {
                        //stop anim
                        break;
                    }
                }
            }
            [_regionSelectionImgArrows[j] setHidden:false];
            
            if (data == nil) {
                return;
            }
            
            if ((int)[((NSArray*)data) count] == 0) {
                [_regionSelectionImgArrows[j] setHidden:true];
                [_regionTextFields[j] setText:Localize(@"i_state_data_not_available")];
            }
            
            NSMutableArray* mArray = [[NSMutableArray alloc] init];
            _regionTMRegionObjects[j] = data;
            for (TMRegion* regionObj in data) {
                [mArray addObject:regionObj.regionTitle];
            }
            _regionDataObjects[j] = [[NSMutableArray alloc] initWithArray:mArray];
            float dropdownHeight = _regionTextFields[j].frame.size.height * 5.0f;
            [_regionDropdownViews[j] updateDataObjects:_regionSelectionUIButtons[j] viewheight:dropdownHeight strArr:_regionDataObjects[j] imgArr:nil];
        } failure:^(NSString *error) {
            
        }];
    }
}
#pragma mark - Events
- (IBAction)barButtonBackPressed:(id)sender {
    if (_isAddressOverConfirmationScreen) {
        [[Utility sharedManager] popScreenWithoutAnimation:self];
        if (_vcCartConfirmation) {
            ViewControllerCartConfirmation* vcCartC = (ViewControllerCartConfirmation*)_vcCartConfirmation;
            [vcCartC reloadAddressView];
        }
    } else {
        [[Utility sharedManager] popScreen:self];
        ViewControllerMain* mainVC = [ViewControllerMain getInstance];
        [mainVC resetPreviousState];
    }
}
- (void)editAddressClicked:(id)sender {
    UIButton* button = (UIButton*) sender;
    Address* address = (Address*)[[button layer] valueForKey:@"ADDRESS_OBJ"];
    _editedAddressObj = address;
    [self loadPopupView:address];
}
- (void)addAddressClicked:(id)sender {
    UIButton* button = (UIButton*)sender;
    Address* address = (Address*)[[button layer] valueForKey:@"ADDRESS_OBJ"];
    _editedAddressObj = address;
    [self loadPopupView:address];
}
- (void)cancelClicked:(id)sender {
    [self unloadPopupView];
    if (_isAddressOverConfirmationScreen) {
        [self barButtonBackPressed:nil];
    }
}
- (void)saveClicked:(id)sender {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    UIButton* saveButton = (UIButton*)(sender);
    Address* address = [saveButton.layer valueForKey:@"ADDRESS_OBJ"];
    if (_textFirstName)
        address._first_name = _textFirstName.text;
    if (_textLastName)
        address._last_name = _textLastName.text;
    if (_textContactNumber)
        address._phone = _textContactNumber.text;
    if (_textAddress1)
        address._address_1 = _textAddress1.text;
    if (_textAddress2)
        address._address_2 = _textAddress2.text;
    if (_textEmail)
        address._email = _textEmail.text;
    if (_textPostalCode)
        address._postcode= _textPostalCode.text;
    address._isBillingAddress = address._isBillingAddress;
    address._isShippingAddress = address._isShippingAddress;
    TMRegion* country = _regionObjs[REGION_SEQUENCE_COUNTRY];
    TMRegion* state = _regionObjs[REGION_SEQUENCE_STATE];
    TMRegion* city = _regionObjs[REGION_SEQUENCE_CITY];
    TMRegion* district = _regionObjs[REGION_SEQUENCE_DISTRICT];
    TMRegion* subdistrict = _regionObjs[REGION_SEQUENCE_SUBDISTRICT];
    if (country) {
        address._country = country.regionTitle;
        address._countryId = country.regionId;
    } else {
        if (_regionTextFields[REGION_SEQUENCE_COUNTRY]) {
            address._country = _regionTextFields[REGION_SEQUENCE_COUNTRY].text;
        }
    }
    if (state) {
        address._state = state.regionTitle;
        address._stateId = state.regionId;
    } else {
        if (_regionTextFields[REGION_SEQUENCE_STATE]) {
            address._state = _regionTextFields[REGION_SEQUENCE_STATE].text;
        }
    }
    if (city) {
        address._city = city.regionTitle;
        address._cityId = city.regionId;
    } else {
        if(_regionTextFields[REGION_SEQUENCE_CITY]) {
            address._city = _regionTextFields[REGION_SEQUENCE_CITY].text;
        }
    }
    if (district) {
        address._district = district.regionTitle;
        address._districtId = district.regionId;
    } else {
        if (_regionTextFields[REGION_SEQUENCE_DISTRICT]) {
            address._district = _regionTextFields[REGION_SEQUENCE_DISTRICT].text;
        }
    }
    if (subdistrict) {
        address._subdistrict = subdistrict.regionTitle;
        address._subdistrictId = subdistrict.regionId;
    } else {
        if (_regionTextFields[REGION_SEQUENCE_SUBDISTRICT]) {
            address._subdistrict = _regionTextFields[REGION_SEQUENCE_SUBDISTRICT].text;
        }
    }
    address._isAddressSaved = true;
    switch (_chkBoxCopyAddress.tag) {
        case CHKBOX_PROP_COPY_TO_SHIPPING:
            if ([[AppUser sharedManager] _isUserLoggedIn] == false && [[GuestConfig sharedInstance] guest_checkout]) {
                [_appUser._billing_address copyAddress:address];
                _appUser._billing_address._isShippingAddress = false;
                _appUser._billing_address._isBillingAddress = true;
            }
            [_appUser._shipping_address copyAddress:address];
            _appUser._shipping_address._isShippingAddress = true;
            _appUser._shipping_address._isBillingAddress = false;
            break;
        case CHKBOX_PROP_COPY_TO_BILLING:
            if ([[AppUser sharedManager] _isUserLoggedIn] == false && [[GuestConfig sharedInstance] guest_checkout]) {
                [_appUser._shipping_address copyAddress:address];
                _appUser._shipping_address._isShippingAddress = true;
                _appUser._shipping_address._isBillingAddress = false;
            }
            [_appUser._billing_address copyAddress:address];
            _appUser._billing_address._isShippingAddress = false;
            _appUser._billing_address._isBillingAddress = true;
            break;
        default:
            if (address._isBillingAddress) {
                [_appUser._billing_address copyAddress:address];
                _appUser._billing_address._isShippingAddress = false;
                _appUser._billing_address._isBillingAddress = true;
            } else {
                [_appUser._shipping_address copyAddress:address];
                _appUser._shipping_address._isShippingAddress = true;
                _appUser._shipping_address._isBillingAddress = false;
            }
            break;
    }
    BOOL isObjectExists = false;
    UIView* viewObject = nil;
    {
        for (UIView* view in _viewsAdded) {
            if([view.layer valueForKey:@"ADDRESS_OBJ"] == address) {
                //object is already in list //so update its view
                isObjectExists = true;
                viewObject = view;
                break;
            }
        }
    }
//    [self storeDataTemp:address];
    [[[DataManager sharedManager] tmDataDoctor] updateCustomerData];
    [self saveMapAddress];
    [self storeDataTemp:address];
    [self loadAllViews];
    [self cancelClicked:nil];
}
- (void)saveMapAddress {
#if ENABLE_ADDRESS_WITH_MAP
    if([[Addons sharedManager] use_multiple_shipping_addresses]){
        [[[DataManager sharedManager] tmDataDoctor] updateMultipleShippingAddress:nil success:^(id responseObj) {
            
        } failure:^(NSString *errorString) {
            
        }];
    }
#endif
}
- (void)chkBoxButtonClicked:(id)sender {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    if([_chkBoxCopyAddress isSelected])
    {
        [_chkBoxCopyAddress setSelected:NO];
        [_chkBoxCopyAddress setTag:CHKBOX_PROP_NONE];
    } else {
        [_chkBoxCopyAddress setSelected:YES];
        Address* address = [_chkBoxCopyAddress.layer valueForKey:@"ADDRESS_OBJ"];
        if (address._isBillingAddress) {
            [_chkBoxCopyAddress setTitle:[NSString stringWithFormat:Localize(@"i_use_same_for_shipping"), @""] forState:UIControlStateNormal];
            [_chkBoxCopyAddress setTag:CHKBOX_PROP_COPY_TO_SHIPPING];
        }
        if (address._isShippingAddress) {
            [_chkBoxCopyAddress setTitle:[NSString stringWithFormat:Localize(@"i_use_same_for_billing"), @""] forState:UIControlStateNormal];
            [_chkBoxCopyAddress setTag:CHKBOX_PROP_COPY_TO_BILLING];
        }
    }
}
- (void)regionSelectionButtonClicked:(id)sender {
    if (_textFieldFirstResponder) {
        [_textFieldFirstResponder resignFirstResponder];
    }
    
    NIDropDown* ddview = [((UIButton*)sender).layer valueForKey:@"DROPDOWNVIEW"];
    [ddview toggleWithMainFrame:sender];
}
- (void)selectBillingAddressClicked:(id)sender {
    
}
- (void)selectShippingAddressClicked:(id)sender {
    
}
- (void)reponseDropDownDelegate:(NIDropDown *)sender clickedItemId:(int)clickedItemId{
    for (NSNumber* num in _regionSequences) {
        int i = [num intValue];
        if(_regionDropdownViews[i] == sender) {
            [_regionSelectionUIButtons[i] setTitle:@"" forState:UIControlStateNormal];
            TMRegion* previousTMRegion = _regionObjs[i];
            _regionObjs[i] = [_regionTMRegionObjects[i] objectAtIndex:clickedItemId];
            if (_regionObjs[i] != nil && i < REGION_SEQUENCE_TOTAL) {
                if (previousTMRegion != _regionObjs[i]) {
                    [_regionTextFields[i] setText:_regionObjs[i].regionTitle];
                    for (int j = i+1; j < REGION_SEQUENCE_TOTAL; j++) {
                        if (_regionTextFields[j]) {
                            _regionDataObjects[j] = [[NSMutableArray alloc] init];
                            float dropdownHeight = _regionTextFields[j].frame.size.height * 5.0f;
                            [_regionDropdownViews[j] updateDataObjects:_regionSelectionUIButtons[j] viewheight:dropdownHeight strArr:_regionDataObjects[j] imgArr:nil];
                            [_regionTextFields[j] setText:@""];
                            [_regionSelectionImgArrows[j] setHidden:true];
                        }
                    }
                    [self fetchLocale:i];
                }
                [_regionTextFields[i] setText:_regionObjs[i].regionTitle];
            }
            
        }
    }
}

#pragma mark - UITextField Methods & Delegate Responses
- (UITextField*)createTextField:(UIView*)parentView fontType:(int)fontType fontColorType:(int)fontColorType frame:(CGRect)frame tag:(int)tag textStrPlaceHolder:(NSString*)textStrPlaceHolder {
    if (CGRectEqualToRect(frame, CGRectMake(0, 0, 0, 0))) {
        frame = parentView.frame;
    }
    UITextField *textField = [[UITextField alloc] initWithFrame:frame];
    textField.placeholder = textStrPlaceHolder;
    textField.backgroundColor = [UIColor clearColor];
    textField.textColor = [Utility getUIColor:fontColorType];
    if ([[MyDevice sharedManager] isIphone]) {
        fontType--;
    }
    textField.borderStyle = UITextBorderStyleNone;
    textField.layer.borderWidth = 0;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.returnKeyType = UIReturnKeyDone;
    textField.textAlignment = NSTextAlignmentLeft;
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
    textField.tag = tag;
    textField.delegate = self;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [textField setUIFont:fontType isBold:false];
    [parentView addSubview:textField];
    UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, textField.frame.size.height - 1, textField.frame.size.width - 5.0f, 1.0f);
    bottomBorder.backgroundColor = [[Utility sharedManager] getTextFieldBorderColor].CGColor;
    [textField.layer setValue:bottomBorder forKey:@"BOTTOM_BORDER"];
    [textField.layer addSublayer:bottomBorder];
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        [textField setRightViewMode:UITextFieldViewModeAlways];
        [textField setRightView:spacerView];
    } else {
        [textField setLeftViewMode:UITextFieldViewModeAlways];
        [textField setLeftView:spacerView];
    }
    return textField;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    _textFieldFirstResponder = textField;
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [self setViewMovedUp:NO];
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField.tag == _kTAGTEXTLABEL_CONTACT)
    {
        if(string.length > 0)
        {
            NSCharacterSet *numbersOnly = [NSCharacterSet characterSetWithCharactersInString:@"+0123456789"];
            NSCharacterSet *characterSetFromTextField = [NSCharacterSet characterSetWithCharactersInString:string];
            
            BOOL stringIsValid = [numbersOnly isSupersetOfSet:characterSetFromTextField];
            return stringIsValid;
        }
    }
    return YES;
}
-(void)cancelNumberPad:(UIBarButtonItem*)button {
    //    UITextField* textInputView = (UITextField*)[button.customView.layer valueForKey:@"MY_INPUT_VIEW"];
    [self textFieldShouldReturn:_textFieldFirstResponder];
}
-(void)doneWithNumberPad:(UIBarButtonItem*)button {
    //    UITextField* textInputView = (UITextField*)[button.customView.layer valueForKey:@"MY_INPUT_VIEW"];
    [self textFieldShouldReturn:_textFieldFirstResponder];
}
#pragma mark - UILabel Methods
- (UILabel*)createLabel:(UIView*)parentView fontType:(float)fontType fontColorType:(int)fontColorType frame:(CGRect)frame textStr:(NSString*)textStr {
    UILabel* label = [[UILabel alloc] init];
    if (CGRectEqualToRect(frame, CGRectMake(0, 0, 0, 0))) {
        frame = parentView.frame;
        
    }
    [label setUIFont:fontType isBold:false];
    [label setTextColor:[Utility getUIColor:fontColorType]];
    [label setFrame:frame];
    [label setText:textStr];
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        [label setTextAlignment:NSTextAlignmentRight];
    } else {
        [label setTextAlignment:NSTextAlignmentLeft];
    }
    [parentView addSubview:label];
    return label;
}

- (void)storeDataTemp:(Address*)address {
    //    Address* addressFailedToSubmit = [[Address alloc] init];
    //    addressFailedToSubmit._first_name = address._first_name;
    //    addressFailedToSubmit._last_name = address._last_name;
    //    addressFailedToSubmit._phone = address._phone;
    //    addressFailedToSubmit._address_1 = address._address_1;
    //    addressFailedToSubmit._address_2 = address._address_2;
    //    addressFailedToSubmit._email = address._email;
    //    addressFailedToSubmit._postcode= address._postcode;
    //    addressFailedToSubmit._isBillingAddress = address._isBillingAddress;
    //    addressFailedToSubmit._isShippingAddress = address._isShippingAddress;
    //    addressFailedToSubmit._country       =   address._country;
    //    addressFailedToSubmit._state         =   address._state;
    //    addressFailedToSubmit._city          =   address._city;
    //    addressFailedToSubmit._subdistrict   =   address._subdistrict;
    //    addressFailedToSubmit._countryId     =   address._countryId;
    //    addressFailedToSubmit._stateId       =   address._stateId;
    //    addressFailedToSubmit._cityId        =   address._cityId;
    //    addressFailedToSubmit._subdistrictId =   address._subdistrictId;
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
    if (movedUp == false) {
        [UIView setAnimationDuration:0.0f];
    } else {
        [UIView setAnimationDuration:_duration];
    }
    
    
    [UIView setAnimationCurve:_curve];
    CGRect rect = _popupController.VIEW_POPUP.frame;
    if (movedUp) {
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        CGPoint p = [_textFieldFirstResponder convertPoint:_textFieldFirstResponder.center toView:window];
        float textViewPos = p.y;
        float windowViewHeight = [[MyDevice sharedManager] screenSize].height;
        float keyboardPos = windowViewHeight - _keyboardHeight;
 
        if (textViewPos > keyboardPos) {
            if ([[MyDevice sharedManager] isIphone]) {
                rect.origin.y = - MIN(_keyboardHeight, (textViewPos - keyboardPos)) ;
//                rect.origin.y = -(textViewPos - keyboardPos) ;
                _popupController.VIEW_POPUP.frame = rect;
            }
        }
    }
    else {
        if ([[MyDevice sharedManager] isIphone]) {
            rect.origin.y = 0;
            _popupController.VIEW_POPUP.frame = rect;
            _popupController.VIEW_POPUP.center = CGPointMake([[MyDevice sharedManager] screenSize].width/2, [[MyDevice sharedManager] screenSize].height/2);
        }
    }
    
    [UIView commitAnimations];
}





- (void)backgroundTouchEventRegistered:(CNPPopupController *)controller {
    RLOG(@"backgroundTouchEventRegistered:");
}





@end
