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
static int kTagForGlobalSpacing = 0;
static int kTagForNoSpacing = -1;
static int MAX_ADDRESSES_COUNT = 1;
@interface ViewControllerAddress () <CNPPopupControllerDelegate, CLLocationManagerDelegate> {
    NSMutableArray* _viewsAdded;
    UIButton* customBackButton;
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
}
@property (nonatomic, strong) CNPPopupController *popupController;
@property (strong, nonatomic) NSMutableArray *dataObjectsCountry;
@property (strong, nonatomic) NSMutableArray *dataObjectsState;
@end
@implementation ViewControllerAddress
- (void)viewDidLoad {
    [super viewDidLoad];
    _addressFailedToSubmit = nil;
    _vcCartConfirmation = nil;
    _isAddressOverConfirmationScreen = false;
    _appUser = [AppUser sharedManager];
    _dataManager = [DataManager sharedManager];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addressUpdatedSuccess:) name:@"addressUpdatedSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addressUpdatedFailed:) name:@"addressUpdatedFailed" object:nil];
    
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
    [customBackButton setTitle:[NSString stringWithFormat:@"  %@  ", Localize(@"Back")] forState:UIControlStateNormal];
    [customBackButton setTintColor:[Utility getUIColor:kUIColorThemeFont]];
    [customBackButton setTitleColor:[Utility getUIColor:kUIColorThemeFont] forState:UIControlStateNormal];
    [customBackButton.titleLabel setUIFont:kUIFontType18 isBold:false];
    
    [customBackButton sizeToFit];
    [_previousItemHeading setCustomView:customBackButton];
    [_previousItemHeading setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[Utility getUIColor:kUIColorThemeFont], NSForegroundColorAttributeName, [Utility getUIFont:kUIFontType18 isBold:false], NSFontAttributeName, nil] forState:UIControlStateNormal];
    
    
    [self initVariables];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)viewWillAppear:(BOOL)animated {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super viewWillAppear:animated];
    
    [self loadAllViews];
}
- (void)addressUpdatedSuccess:(NSNotification*)notification {
    //show address updated successfully
    //    RLOG(@"show address updated successfully");
    _addressFailedToSubmit = nil;
    [[AppUser sharedManager] updateFetchedAddress];
    if (_isAddressOverConfirmationScreen) {
        [self barButtonBackPressed:nil];
    }
}
- (void)addressUpdatedFailed:(NSNotification*)notification {
    //show address updated failed and
    //reset view
    //    RLOG(@"show address updated failed and");
    //    RLOG(@"reset view");
    [_appUser resetAddress];
    [self loadAllViews];
    _tempAddress = nil;
    _editAddress = nil;
    [self cancelClicked:nil];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:settingsURL];
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
    //    UIAlertView *errorAlert = [[UIAlertView alloc]
    //                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    //    [errorAlert show];
    //    [locationManager stopUpdatingLocation];
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
                [self fillDataInPopup];
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
- (void)initVariables {
    _dataObjectsCountry = nil;
    _dropdownViewState = nil;
    _defaultHeight = 0;
    _viewsAdded = [[NSMutableArray alloc] init];
    _billingButtons = [[NSMutableArray alloc] init];
    _shippingButtons = [[NSMutableArray alloc] init];
    //    [_scrollView setBackgroundColor:[Utility getUIColor:kUIColorBgTheme]];
    //    [self.view setBackgroundColor:[Utility getUIColor:kUIColorBgHeader]];
    //    [_lineView setBackgroundColor:[Utility getUIColor:kUIColorBorder]];
}
- (void)loadAllViews {
    for (UIView* view in _viewsAdded) {
        [view removeFromSuperview];
    }
    [_viewsAdded removeAllObjects];
    
    [_labelViewHeading setText:Localize(@"ADDRESS")];
    _appUser = [AppUser sharedManager];
    
    
    //shipping address
    [self addShippingHeaderView];
    int shippingAddId = 0;
    if (_shippingButtons) {
        [_shippingButtons removeAllObjects];
    }
    for (Address* address in [[AppUser sharedManager] _shippingAddressArray]) {
        BOOL isSelected = false;
        if(_appUser._selectedShippingAddressId == shippingAddId) {
            isSelected = true;
        }
        [self addAddressView:false address:address isBillingAddress:false isShippingAddress:true isSelected:isSelected addressId:shippingAddId];
        shippingAddId++;
    }
    if ([[[AppUser sharedManager] _shippingAddressArray] count] < MAX_ADDRESSES_COUNT) {
        [self addAddressView:true address:nil isBillingAddress:false isShippingAddress:true isSelected:false addressId:-1];
    }
    
    
    //billing address
    [self addBillingHeaderView];
    int billingAddId = 0;
    if (_billingButtons) {
        [_billingButtons removeAllObjects];
    }
    for (Address* address in [[AppUser sharedManager] _billingAddressArray]) {
        BOOL isSelected = false;
        if(_appUser._selectedBillingAddressId == billingAddId) {
            isSelected = true;
        }
        [self addAddressView:false address:address isBillingAddress:true isShippingAddress:false isSelected:isSelected addressId:billingAddId];
        billingAddId++;
    }
    if ([[[AppUser sharedManager] _billingAddressArray] count] < MAX_ADDRESSES_COUNT) {
        [self addAddressView:true address:nil isBillingAddress:true isShippingAddress:false isSelected:false addressId:-1];
    }
    [self resetMainScrollView];
    [self updateViews];
}
- (void)addBillingHeaderView {
    _billingViews = [[NSMutableArray alloc] init];
    _billingHeaderView = [[UIView alloc] init];
    
    UIView* view = _billingHeaderView;
    [_scrollView addSubview:view];
    [_viewsAdded addObject:view];
    [view setTag:kTagForGlobalSpacing];
    
    [view setFrame: CGRectMake(0, 0, _scrollView.frame.size.width, 50)];
    [view setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [view setBackgroundColor:[Utility getUIColor:kUIColorClear]];
    
    UILabel* label = [[UILabel alloc] init];
    [label setUIFont:kUIFontType20 isBold:false];
    [label setText:Localize(@"Billing Address")];
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
    [view setTag:kTagForGlobalSpacing];
    
    [view setFrame: CGRectMake(0, 0, _scrollView.frame.size.width, 50)];
    [view setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [view setBackgroundColor:[Utility getUIColor:kUIColorClear]];
    
    UILabel* label = [[UILabel alloc] init];
    [label setUIFont:kUIFontType20 isBold:false];
    [label setText:Localize(@"Shipping Address")];
    [label setTextColor:[Utility getUIColor:kUIColorFontDark]];
    [label setFrame:_shippingHeaderView.frame];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [view addSubview:label];
}

- (UIView*)addAddressView:(BOOL)isEmpty address:(Address*)address isBillingAddress:(BOOL)isBillingAddress isShippingAddress:(BOOL)isShippingAddress isSelected:(BOOL)isSelected addressId:(int)addressId {
    UIView* view = [[UIView alloc] init];
    if (_defaultHeight == 0) {
        _defaultHeight = [[MyDevice sharedManager] screenHeightInPortrait] * .3f;
    }
    
    [view setFrame: CGRectMake(self.view.frame.size.width * 0.01f, 0, self.view.frame.size.width * 0.98f, _defaultHeight)];
    //    [view.layer setBorderColor:[[Utility getUIColor:kUIColorBorder] CGColor]];
    //    [view.layer setBorderWidth:1];
    [view.layer setValue:address forKey:@"address"];
    [view setBackgroundColor:[UIColor whiteColor]];
    [_scrollView addSubview:view];
    [_viewsAdded addObject:view];
    [view setTag:kTagForGlobalSpacing];
    
    UIButton *buttonAddAddress = [[UIButton alloc] init];
    [[buttonAddAddress titleLabel] setUIFont:kUIFontType18 isBold:false];
    [buttonAddAddress setTitleColor:[Utility getUIColor:kUIColorFontDark] forState:UIControlStateNormal];
    [view addSubview:buttonAddAddress];
    [buttonAddAddress setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    if (isEmpty) {
        [buttonAddAddress setTitle:Localize(@"+ Add Address") forState:UIControlStateNormal];
        [buttonAddAddress addTarget:self action:@selector(addAddressClicked:) forControlEvents:UIControlEventTouchUpInside];
        
    } else {
        [buttonAddAddress setTitle:@"" forState:UIControlStateNormal];
        [buttonAddAddress setTag:addressId];
        if (isBillingAddress) {
            [buttonAddAddress addTarget:self action:@selector(selectBillingAddressClicked:) forControlEvents:UIControlEventTouchUpInside];
            [_billingButtons addObject:buttonAddAddress];
        }
        if (isShippingAddress) {
            [buttonAddAddress addTarget:self action:@selector(selectShippingAddressClicked:) forControlEvents:UIControlEventTouchUpInside];
            [_shippingButtons addObject:buttonAddAddress];
        }
        [buttonAddAddress.layer setBorderColor:[[Utility getUIColor:kUIColorThemeButtonBorderSelected] CGColor]];
        
        if (isSelected) {
            [buttonAddAddress.layer setBorderWidth:0];
        } else {
            [buttonAddAddress.layer setBorderWidth:0];
        }
    }
    
    
    
    if (isEmpty) {
        Address* ttempAdd = [[Address alloc] init];
        ttempAdd._isBillingAddress = isBillingAddress;
        ttempAdd._isShippingAddress = isShippingAddress;
        [[buttonAddAddress layer] setValue:ttempAdd forKey:@"buttonAddAddress"];
        if (isBillingAddress) {
            _buttonCreateBilling = buttonAddAddress;
        } else {
            _buttonCreateShipping= buttonAddAddress;
        }
    } else {
        [[buttonAddAddress layer] setValue:address forKey:@"buttonAddAddress"];
    }
    
    if (isEmpty == false) {
        UILabel* temp = [self createLabel:view fontType:kUIFontType24 fontColorType:kUIColorFontLight frame:CGRectMake(0, 0, 0, 0) textStr:Localize(@"Edit")];
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
        [button setTitle:Localize(@"Edit") forState:UIControlStateNormal];
        [button setTitleColor:[Utility getUIColor:kUIColorThemeFont] forState:UIControlStateNormal];
        [view addSubview:button];
        [[button layer] setValue:address forKey:@"address"];
        [button addTarget:self action:@selector(editAddressClicked:) forControlEvents:UIControlEventTouchUpInside];
        if (isBillingAddress) {
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
        if (![[[Addons sharedManager] excludedAddress] isVisibleFirstName:isBillingAddress]) {
            name.hidden = true;
            posY -= LABEL_SIZE(name).height;
        }
        
        UILabel* address1 = [self createLabel:view fontType:kUIFontType18 fontColorType:kUIColorFontLight frame:CGRectMake(posX, posY, width, height) textStr:Localize(@"Address1")];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            if ([Localize(@"Address1") isEqualToString:@""]) {
                [address1 setText:[NSString stringWithFormat:@"%@", address._address_1]];
            } else {
                [address1 setText:[NSString stringWithFormat:@"%@ : %@", address._address_1, Localize(@"Address1")]];
            }
        } else {
            if ([Localize(@"Address1") isEqualToString:@""]) {
                [address1 setText:[NSString stringWithFormat:@"%@", address._address_1]];
            } else {
                [address1 setText:[NSString stringWithFormat:@"%@ : %@", Localize(@"Address1"), address._address_1]];
            }
        }
        posY += LABEL_SIZE(address1).height;
        [address1 setTag:_kTAGTEXTLABEL_ADDRESS1];
        if (![[[Addons sharedManager] excludedAddress] isVisibleAddress1:isBillingAddress]) {
            address1.hidden = true;
            posY -= LABEL_SIZE(address1).height;
        }
        
        UILabel* address2 = [self createLabel:view fontType:kUIFontType18 fontColorType:kUIColorFontLight frame:CGRectMake(posX, posY, width, height) textStr:Localize(@"Address2")];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            if ([Localize(@"Address2") isEqualToString:@""]) {
                [address2 setText:[NSString stringWithFormat:@"%@", address._address_2]];
            } else {
                [address2 setText:[NSString stringWithFormat:@"%@ : %@", address._address_2, Localize(@"Address2")]];
            }
        } else {
            if ([Localize(@"Address2") isEqualToString:@""]) {
                [address2 setText:[NSString stringWithFormat:@"%@", address._address_2]];
            } else {
                [address2 setText:[NSString stringWithFormat:@"%@ : %@", Localize(@"Address2"), address._address_2]];
            }
        }
        if ([Localize(@"Address2") isEqualToString:@""]) {
            [address2 setText:[NSString stringWithFormat:@"%@", address._address_2]];
        }
        posY += LABEL_SIZE(address2).height;
        [address2 setTag:_kTAGTEXTLABEL_ADDRESS2];
        if (![[[Addons sharedManager] excludedAddress] isVisibleAddress2:isBillingAddress]) {
            address2.hidden = true;
            posY -= LABEL_SIZE(address2).height;
        }
        
        UILabel* city = [self createLabel:view fontType:kUIFontType18 fontColorType:kUIColorFontLight frame:CGRectMake(posX, posY, width, height) textStr:Localize(@"City")];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [city setText:[NSString stringWithFormat:@"%@ : %@", address._city, Localize(@"City")]];
        } else {
            [city setText:[NSString stringWithFormat:@"%@ : %@", Localize(@"City"), address._city]];
        }
        posY += LABEL_SIZE(city).height;
        [city setTag:_kTAGTEXTLABEL_CITY];
        if (![[[Addons sharedManager] excludedAddress] isVisibleCity:isBillingAddress]) {
            city.hidden = true;
            posY -= LABEL_SIZE(city).height;
        }
        
        UILabel* postalCode = [self createLabel:view fontType:kUIFontType18 fontColorType:kUIColorFontLight frame:CGRectMake(posX, posY, width, height) textStr:Localize(@"Postal Code")];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [postalCode setText:[NSString stringWithFormat:@"%@ : %@", address._postcode, Localize(@"Postal Code")]];
        } else {
            [postalCode setText:[NSString stringWithFormat:@"%@ : %@", Localize(@"Postal Code"), address._postcode]];
        }
        posY += LABEL_SIZE(postalCode).height;
        [postalCode setTag:_kTAGTEXTLABEL_POSTAL];
        if (![[[Addons sharedManager] excludedAddress] isVisiblePostCode:isBillingAddress]) {
            postalCode.hidden = true;
            posY -= LABEL_SIZE(postalCode).height;
        }
        
        UILabel* state = [self createLabel:view fontType:kUIFontType18 fontColorType:kUIColorFontLight frame:CGRectMake(posX, posY, width, height) textStr:Localize(@"State")];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [state setText:[NSString stringWithFormat:@"%@ : %@", address._state, Localize(@"State")]];
        } else {
            [state setText:[NSString stringWithFormat:@"%@ : %@", Localize(@"State"), address._state]];
        }
        posY += LABEL_SIZE(state).height;
        [state setTag:_kTAGTEXTLABEL_STATE];
        if ([address._state isEqualToString:@""] || address._state == nil) {
            state.hidden = true;
            posY -= LABEL_SIZE(state).height;
        }
        if (![[[Addons sharedManager] excludedAddress] isVisibleState:isBillingAddress]) {
            if (state.hidden == false) {
                state.hidden = true;
                posY -= LABEL_SIZE(state).height;
            }
        }
        
        UILabel* country = [self createLabel:view fontType:kUIFontType18 fontColorType:kUIColorFontLight frame:CGRectMake(posX, posY, width, height) textStr:Localize(@"Country")];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [country setText:[NSString stringWithFormat:@"%@ : %@", address._country, Localize(@"Country")]];
        } else {
            [country setText:[NSString stringWithFormat:@"%@ : %@", Localize(@"Country"), address._country]];
        }
        posY += LABEL_SIZE(country).height;
        [country setTag:_kTAGTEXTLABEL_COUNTRY];
        if (![[[Addons sharedManager] excludedAddress] isVisibleCountry:isBillingAddress]) {
            country.hidden = true;
            posY -= LABEL_SIZE(country).height;
        }
        
        UILabel* email = [self createLabel:view fontType:kUIFontType18 fontColorType:kUIColorFontLight frame:CGRectMake(posX, posY, width, height) textStr: Localize(@"E-mail")];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [email setText:[NSString stringWithFormat:@"%@ : %@", address._email, Localize(@"E-mail")]];
        } else {
            [email setText:[NSString stringWithFormat:@"%@ : %@", Localize(@"E-mail"), address._email]];
        }
        posY += LABEL_SIZE(email).height;
        [email setTag:_kTAGTEXTLABEL_EMAIL];
        if (![[[Addons sharedManager] excludedAddress] isVisibleEmail:isBillingAddress]) {
            email.hidden = true;
            posY -= LABEL_SIZE(email).height;
        }
        
        UILabel* phone = [self createLabel:view fontType:kUIFontType18 fontColorType:kUIColorFontLight frame:CGRectMake(posX, posY, width, height) textStr:Localize(@"Phone No.")];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [phone setText:[NSString stringWithFormat:@"%@ : %@", address._phone, Localize(@"Phone No.")]];
        } else {
            [phone setText:[NSString stringWithFormat:@"%@ : %@", Localize(@"Phone No."), address._phone]];
        }
        posY += LABEL_SIZE(phone).height;
        [phone setTag:_kTAGTEXTLABEL_CONTACT];
        if (![[[Addons sharedManager] excludedAddress] isVisiblePhone:isBillingAddress]) {
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
- (void)updateViews {
    
}
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
    RLOG(@"%s", __PRETTY_FUNCTION__);
    UIButton* button = (UIButton*) sender;
    Address* address = (Address*) [[button layer] valueForKey:@"address"];
    _editAddress = address;
    _tempAddress = address;
    [self showPopup];
}
- (void)addAddressClicked:(id)sender {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    _editAddress = nil;
    UIButton* button = (UIButton*)sender;
    _tempAddress = [[button layer] valueForKey:@"buttonAddAddress"];
    [self showPopup];
}
- (void)selectBillingAddressClicked:(id)sender {
    RLOG(@"selectBillingAddressClicked");
    UIButton* buttonSelected = (UIButton*)sender;
    AppUser* appUser = [AppUser sharedManager];
    appUser._selectedBillingAddressId = (int)[buttonSelected tag];
    appUser._selectedShippingAddressId = (int)[buttonSelected tag];
    for (UIButton* button in _billingButtons) {
        if (button == buttonSelected) {
            [button.layer setBorderWidth:0];
        }else{
            [button.layer setBorderWidth:0];
        }
    }
    [appUser saveData];
}
- (void)selectShippingAddressClicked:(id)sender {
    RLOG(@"selectShippingAddressClicked");
    UIButton* buttonSelected = (UIButton*)sender;
    AppUser* appUser = [AppUser sharedManager];
    appUser._selectedShippingAddressId = (int)[buttonSelected tag];
    for (UIButton* button in _shippingButtons) {
        if (button == buttonSelected) {
            [button.layer setBorderWidth:0];
        }else{
            [button.layer setBorderWidth:0];
        }
    }
}
- (void)showPopup {
    [self createAddressPopup];
    [self fillDataInPopup];
    [self.popupController presentPopupControllerAnimated:YES];
}
- (void)createAddressPopup {
    if (self.popupController != nil) {
        int billingAddressCount = (int)[[[AppUser sharedManager] _billingAddressArray] count];
        int shippingAddressCount = (int)[[[AppUser sharedManager] _shippingAddressArray] count];
        
        Address* address = _tempAddress;
        NSString* spacing = @"";
        if ([[MyDevice sharedManager] isIphone]) {
            spacing = Localize(@"  ");
        } else {
            spacing = Localize(@"    ");
        }
        if (address._isShippingAddress){
            if (billingAddressCount > 0) {
                [_chkBoxCopyAddress setTitle:[NSString stringWithFormat:Localize(@"%@Fill data from Billing Address"), spacing] forState:UIControlStateNormal];
                [_chkBoxCopyAddress setSelected:false];
                _chkBoxCopyAddress.tag = 0;
            } else {
                [_chkBoxCopyAddress setTitle:[NSString stringWithFormat:Localize(@"%@Use same address for Billing"), spacing] forState:UIControlStateNormal];
                [_chkBoxCopyAddress setSelected:true];
                _chkBoxCopyAddress.tag = 1;
            }
        } else {
            if (shippingAddressCount > 0) {
                [_chkBoxCopyAddress setTitle:[NSString stringWithFormat:Localize(@"%@Fill data from Shipping Address"), spacing] forState:UIControlStateNormal];
                [_chkBoxCopyAddress setSelected:false];
                _chkBoxCopyAddress.tag = 0;
            } else {
                [_chkBoxCopyAddress setTitle:[NSString stringWithFormat:Localize(@"%@Use same address for Shipping"), spacing] forState:UIControlStateNormal];
                [_chkBoxCopyAddress setSelected:true];
                _chkBoxCopyAddress.tag = 1;
            }
        }
        
        if (address._isShippingAddress){
            _labelTitle.text = Localize(@"Shipping Address");
        } else {
            _labelTitle.text = Localize(@"Billing Address");
        }
        
        float posX = _addressViewPopupElementRect.origin.x;
        float posY = _addressViewPopupElementRect.origin.y;
        float width = _addressViewPopupElementRect.size.width;
        float height = _addressViewPopupElementRect.size.height;
        
        if (![[[Addons sharedManager] excludedAddress] isVisibleFirstName:address._isBillingAddress]) {
            _textFirstName.hidden = true;
        }else{
            _textFirstName.hidden = false;
            _textFirstName.frame = CGRectMake(posX, posY, width/2, height);
        }
        
        if (![[[Addons sharedManager] excludedAddress] isVisibleLastName:address._isBillingAddress]) {
            _textLastName.hidden = true;
        }else{
            _textLastName.hidden = false;
            _textLastName.frame = CGRectMake(posX + width/2, posY, width/2, height);
        }
        
        if (_textFirstName.hidden && _textLastName.hidden) {
            
        } else {
            if (_textFirstName.hidden && _textLastName.hidden == false) {
                _textLastName.frame = CGRectMake(posX, posY, width, height);
                CALayer *bottomBorder = [_textLastName.layer valueForKey:@"BOTTOM_BORDER"];
                bottomBorder.frame = CGRectMake(0.0f, _textLastName.frame.size.height - 1, _textLastName.frame.size.width - 5.0f, 1.0f);
            }
            if (_textFirstName.hidden == false && _textLastName.hidden) {
                _textFirstName.frame = CGRectMake(posX, posY, width, height);
                CALayer *bottomBorder = [_textFirstName.layer valueForKey:@"BOTTOM_BORDER"];
                bottomBorder.frame = CGRectMake(0.0f, _textFirstName.frame.size.height - 1, _textFirstName.frame.size.width - 5.0f, 1.0f);
            }
            posY += height;
        }
        
        
        if (![[[Addons sharedManager] excludedAddress] isVisibleAddress1:address._isBillingAddress]) {
            _textAddress1.hidden = true;
        }else{
            _textAddress1.hidden = false;
            _textAddress1.frame = CGRectMake(posX, posY, width, height);
            posY += height;
        }
        
        if (![[[Addons sharedManager] excludedAddress] isVisibleAddress2:address._isBillingAddress]) {
            _textAddress2.hidden = true;
        }else{
            _textAddress2.hidden = false;
            _textAddress2.frame = CGRectMake(posX, posY, width, height);
            posY += height;
        }
        
        if (![[[Addons sharedManager] excludedAddress] isVisibleCountry:address._isBillingAddress]) {
            _textCountry.hidden = true;
            _countrySelectionButton.hidden = true;
            _countrySelectionButton.enabled = false;
        }else{
            _textCountry.hidden = false;
            _textCountry.frame = CGRectMake(posX, posY, width, height);
            _countrySelectionButton.hidden = false;
            _countrySelectionButton.frame = CGRectMake(posX, posY, width, height);
            posY += height;
        }
        
        if (![[[Addons sharedManager] excludedAddress] isVisibleState:address._isBillingAddress]) {
            _textState.hidden = true;
            _stateSelectionButton.hidden = true;
            _stateSelectionButton.enabled = false;
        }else{
            _textState.hidden = false;
            _textState.frame = CGRectMake(posX, posY, width, height);
            _stateSelectionButton.hidden = false;
            _stateSelectionButton.frame = CGRectMake(posX, posY, width, height);
            posY += height;
        }
        
        if (![[[Addons sharedManager] excludedAddress] isVisibleCity:address._isBillingAddress]) {
            _textCity.hidden = true;
        }else{
            _textCity.hidden = false;
            _textCity.frame = CGRectMake(posX, posY, width/2, height);
        }
        
        if (![[[Addons sharedManager] excludedAddress] isVisiblePostCode:address._isBillingAddress]) {
            _textPostalCode.hidden = true;
        }else{
            _textPostalCode.hidden = false;
            _textPostalCode.frame = CGRectMake(posX +  width/2, posY, width/2, height);
        }
        
        if (_textCity.hidden && _textPostalCode.hidden) {
            
        } else {
            if (_textCity.hidden && _textPostalCode.hidden == false) {
                _textPostalCode.frame = CGRectMake(posX, posY, width, height);
                CALayer *bottomBorder = [_textPostalCode.layer valueForKey:@"BOTTOM_BORDER"];
                bottomBorder.frame = CGRectMake(0.0f, _textPostalCode.frame.size.height - 1, _textPostalCode.frame.size.width - 5.0f, 1.0f);
            }
            if (_textCity.hidden == false && _textPostalCode.hidden) {
                _textCity.frame = CGRectMake(posX, posY, width, height);
                CALayer *bottomBorder = [_textCity.layer valueForKey:@"BOTTOM_BORDER"];
                bottomBorder.frame = CGRectMake(0.0f, _textCity.frame.size.height - 1, _textCity.frame.size.width - 5.0f, 1.0f);
            }
            posY += height;
        }
        
        if (![[[Addons sharedManager] excludedAddress] isVisibleEmail:address._isBillingAddress]) {
            _textEmail.hidden = true;
        }else{
            _textEmail.hidden = false;
            _textEmail.frame = CGRectMake(posX, posY, width, height);
            posY += height;
        }
        
        if (![[[Addons sharedManager] excludedAddress] isVisiblePhone:address._isBillingAddress]) {
            _textContactNumber.hidden = true;
        }else{
            _textContactNumber.hidden = false;
            _textContactNumber.frame = CGRectMake(posX, posY, width, height);
            posY += height;
        }
        
        _chkBoxCopyAddress.frame = CGRectMake(posX + 10, posY, width, height);
        if ([[MyDevice sharedManager] isIphone]) {
            _chkBoxCopyAddress.frame = CGRectMake(posX + 5, posY, width, height);
        }
        posY += height;
        posY += height/2;
        self.popupController.theme.size = CGSizeMake(self.popupController.theme.size.width, posY);
        return;
    }
    
    float widthView, heightView;
    if ([[MyDevice sharedManager] isIpad]) {
        widthView = [[MyDevice sharedManager] screenWidthInPortrait] * 0.65f;
        heightView = [[MyDevice sharedManager] screenHeightInPortrait] * 0.63f;
    }else if ([[MyDevice sharedManager] isIphone]) {
        widthView = [[MyDevice sharedManager] screenSize].width * 0.96f;
        heightView = [[MyDevice sharedManager] screenSize].height * 0.70f;
        //here we need full screen
    }
    
    UIView* viewMain = [[UIView alloc] initWithFrame:CGRectMake(0, 0, widthView, heightView)];
    viewMain.backgroundColor = [Utility getUIColor:kUIColorBgTheme];
    
    UIView* viewTop = [[UIView alloc] initWithFrame:CGRectMake(0, 0, widthView, heightView * 0.05f)];
    viewTop.backgroundColor = [UIColor whiteColor];
    [viewMain addSubview:viewTop];
    
    self.popupController = [[CNPPopupController alloc] initWithContents:@[viewMain]];
    self.popupController.theme = [CNPPopupTheme addressTheme];
    self.popupController.theme.popupStyle = CNPPopupStyleCentered;
    self.popupController.theme.size = CGSizeMake(widthView, heightView);
    self.popupController.theme.maxPopupWidth = widthView;
    self.popupController.delegate = self;
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        self.popupController.VIEW_POPUP.transform = CGAffineTransformMakeScale(-1, 1);
    }
    _buttonCancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, viewTop.frame.size.width, viewTop.frame.size.height)];
    [[_buttonCancel titleLabel] setUIFont:kUIFontType18 isBold:false];
    [_buttonCancel setTitle:Localize(@"Cancel") forState:UIControlStateNormal];
    [_buttonCancel setTitleColor:[Utility getUIColor:kUIColorThemeFont] forState:UIControlStateNormal];
    [viewTop addSubview:_buttonCancel];
    [_buttonCancel addTarget:self action:@selector(cancelClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_buttonCancel sizeToFit];
    [_buttonCancel setFrame:CGRectMake(0, -16, _buttonCancel.frame.size.width * 2 + 16, viewTop.frame.size.height + 16)];
    _buttonCancel.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _buttonCancel.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
    //    _buttonCancel.layer.borderWidth = 1;
    //    [_buttonCancel.layer setBorderWidth:1];
    _buttonCancel.titleEdgeInsets = UIEdgeInsetsMake(0, 16, 0, 16);
    
    
    _buttonSave = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, viewTop.frame.size.width, viewTop.frame.size.height)];
    [[_buttonSave titleLabel] setUIFont:kUIFontType18 isBold:false];
    [_buttonSave setTitle:Localize(@"Save") forState:UIControlStateNormal];
    [_buttonSave setTitleColor:[Utility getUIColor:kUIColorThemeFont] forState:UIControlStateNormal];
    [viewTop addSubview:_buttonSave];
    [_buttonSave addTarget:self action:@selector(saveClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_buttonSave sizeToFit];
    //    [_buttonSave.layer setBorderWidth:1];
    //    [_buttonSave setFrame:CGRectMake(viewTop.frame.size.width - viewTop.frame.size.width * 0.04f - _buttonSave.frame.size.width, 0, _buttonSave.frame.size.width, viewTop.frame.size.height)];
    [_buttonSave setFrame:CGRectMake(viewTop.frame.size.width - viewTop.frame.size.width * 0.04f - _buttonSave.frame.size.width * 2, -16, _buttonSave.frame.size.width * 2 + 16, viewTop.frame.size.height + 16)];
    _buttonSave.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    _buttonSave.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
    _buttonSave.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 16);
    //    _buttonSave.layer.borderWidth = 1;
    
    
    
    
    
    _labelTitle = [self createLabel:viewTop fontType:kUIFontType20 fontColorType:kUIColorFontDark frame:CGRectMake(0, 0, viewTop.frame.size.width, viewTop.frame.size.height) textStr:Localize(@"Address")];
    [_labelTitle setTextAlignment:NSTextAlignmentCenter];
    
    float posX = viewMain.frame.size.width * 0.05f;
    float posY = CGRectGetMaxY(viewTop.frame); // + viewMain.frame.size.width * 0.05f;
    float width = viewMain.frame.size.width * 0.90f;
    float height = (viewMain.frame.size.height - (posY - viewTop.frame.size.height) - posY)/10;
    _addressViewPopupElementRect = CGRectMake(posX, posY, width, height);
    
    int fontType;
    if ([[MyDevice sharedManager] isIpad]) {
        fontType = kUIFontType18;
    } else {
        fontType = kUIFontType24;
    }
    
    
    _textFirstName = [self createTextField:viewMain fontType:fontType fontColorType:kUIColorFontLight frame:CGRectMake(posX, posY, width/2, height) tag:_kTAGTEXTFIELD_FIRSTNAME textStrPlaceHolder:Localize(@"*First Name")];
    
    _textLastName = [self createTextField:viewMain fontType:fontType fontColorType:kUIColorFontLight frame:CGRectMake(posX + width/2, posY, width/2, height) tag:_kTAGTEXTFIELD_LASTNAME textStrPlaceHolder:Localize(@"*Last Name")];
    posY += height;
    
    //    _textCompany = [self createTextField:viewMain fontType:fontType fontColorType:kUIColorFontLight frame:CGRectMake(posX, posY, width, height) tag:_kTAGTEXTFIELD_COMPANY textStrPlaceHolder:@"Company Name"];
    //    posY += height;
    
    _textAddress1 = [self createTextField:viewMain fontType:fontType fontColorType:kUIColorFontLight frame:CGRectMake(posX, posY, width, height) tag:_kTAGTEXTFIELD_ADDRESS1 textStrPlaceHolder:Localize(@"Address1")];
    posY += height;
    
    _textAddress2 = [self createTextField:viewMain fontType:fontType fontColorType:kUIColorFontLight frame:CGRectMake(posX, posY, width, height) tag:_kTAGTEXTFIELD_ADDRESS2 textStrPlaceHolder:Localize(@"Address2")];
    posY += height;
    
    _textCountry = [self createTextField:viewMain fontType:fontType fontColorType:kUIColorFontLight frame:CGRectMake(posX, posY, width, height) tag:_kTAGTEXTFIELD_COUNTRY textStrPlaceHolder:Localize(@"*Country")];
    posY += height;
    
    _textState = [self createTextField:viewMain fontType:fontType fontColorType:kUIColorFontLight frame:CGRectMake(posX, posY, width, height) tag:_kTAGTEXTFIELD_STATE textStrPlaceHolder:Localize(@"*State")];
    posY += height;
    
    _textCity = [self createTextField:viewMain fontType:fontType fontColorType:kUIColorFontLight frame:CGRectMake(posX, posY, width/2, height) tag:_kTAGTEXTFIELD_CITY textStrPlaceHolder:Localize(@"*City")];
    _textPostalCode = [self createTextField:viewMain fontType:fontType fontColorType:kUIColorFontLight frame:CGRectMake(posX + width/2, posY, width/2, height) tag:_kTAGTEXTFIELD_POSTAL textStrPlaceHolder:Localize(@"*Postal Code")];
    posY += height;
    
    _textEmail = [self createTextField:viewMain fontType:fontType fontColorType:kUIColorFontLight frame:CGRectMake(posX, posY, width, height) tag:_kTAGTEXTFIELD_EMAIL textStrPlaceHolder:Localize(@"*Email Address")];
    posY += height;
    
    [_textContactNumber setKeyboardType:UIKeyboardTypeEmailAddress];
    _textContactNumber = [self createTextField:viewMain fontType:fontType fontColorType:kUIColorFontLight frame:CGRectMake(posX, posY, width, height) tag:_kTAGTEXTFIELD_CONTACT textStrPlaceHolder:Localize(@"*Contact Number")];
    posY += height;
    
    [_textContactNumber setKeyboardType:UIKeyboardTypePhonePad];
    if ([[MyDevice sharedManager] isIphone]) {
        UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
        numberToolbar.backgroundColor = [UIColor lightGrayColor];
        UIBarButtonItem* doneBtn = [[UIBarButtonItem alloc]initWithTitle:Localize(@"Done") style:UIBarButtonItemStyleBordered target:self action:@selector(doneWithNumberPad:)];
        numberToolbar.items = @[[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                doneBtn];
        [numberToolbar sizeToFit];
        _textContactNumber.inputAccessoryView = numberToolbar;
    }
    
    
    _chkBoxCopyAddress = [[UIButton alloc] init];
    _chkBoxCopyAddress.frame = CGRectMake(posX + 10, posY, width, height);
    if ([[MyDevice sharedManager] isIphone]) {
        _chkBoxCopyAddress.frame = CGRectMake(posX + 5, posY, width, height);
    }
    [_chkBoxCopyAddress addTarget:self action:@selector(chkBoxButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_textCountry.superview addSubview:_chkBoxCopyAddress];
    [_chkBoxCopyAddress setUIImage:[UIImage imageNamed:@"chkbox_unselected"] forState:UIControlStateNormal];
    [_chkBoxCopyAddress setUIImage:[UIImage imageNamed:@"chkbox_selected"] forState:UIControlStateSelected];
    [_chkBoxCopyAddress setTitle:Localize(@"\tUse same address for Billing") forState:UIControlStateNormal];
    [_chkBoxCopyAddress setTitleColor:[Utility getUIColor:kUIColorFontLight] forState:UIControlStateNormal];
    [_chkBoxCopyAddress setTitleColor:[Utility getUIColor:kUIColorFontLight] forState:UIControlStateSelected];
    if ([[MyDevice sharedManager] isIphone]) {
        [_chkBoxCopyAddress.titleLabel setUIFont:fontType-1 isBold:false];
    }else{
        [_chkBoxCopyAddress.titleLabel setUIFont:fontType isBold:false];
    }
    _chkBoxCopyAddress.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_chkBoxCopyAddress setSelected:YES];
    
    
    
    _countrySelectionButton = [[UIButton alloc] init];
    _countrySelectionButton.frame = _textCountry.frame;
    [_countrySelectionButton addTarget:self action:@selector(countryButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_textCountry.superview addSubview:_countrySelectionButton];
    height = _textCountry.frame.size.height * 5.0f;
    _textCountry.enabled = false;
    _textCountry.userInteractionEnabled = false;
    _textCountry.hidden = false;
    
    NSMutableArray* countryNames = [TMCountry getCountryNames];
    _dataObjectsCountry = [[NSMutableArray alloc] initWithArray:countryNames];
    _dropdownViewCountry = [[NIDropDown alloc] init:_countrySelectionButton viewheight:height strArr:_dataObjectsCountry imgArr:nil direction:NIDropDownDirectionDown pView:_textCountry.superview];
    _dropdownViewCountry.delegate = self;
    [_textCountry.superview addSubview:_dropdownViewCountry];
    _dropdownViewCountry.backgroundColor = [UIColor blueColor];
    [_dropdownViewCountry toggleWithMainFrame:_countrySelectionButton];
    _countrySelectionArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_arrow_down"]];
    [_countrySelectionArrow setImage:[UIImage imageNamed:@"img_arrow_down"]];
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        _countrySelectionArrow.frame = CGRectMake(_countrySelectionArrow.frame.size.width, (_textCountry.frame.size.height - _countrySelectionArrow.frame.size.height) - 10, _countrySelectionArrow.frame.size.width, _countrySelectionArrow.frame.size.height);
    } else {
        _countrySelectionArrow.frame = CGRectMake(_textCountry.frame.size.width - _countrySelectionArrow.frame.size.width * 2, (_textCountry.frame.size.height - _countrySelectionArrow.frame.size.height) - 10, _countrySelectionArrow.frame.size.width, _countrySelectionArrow.frame.size.height);
    }
    [_textCountry addSubview:_countrySelectionArrow];
    
    
    
    _stateSelectionButton = [[UIButton alloc] init];
    _stateSelectionButton.frame = _textState.frame;
    [_stateSelectionButton addTarget:self action:@selector(countryButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_textState.superview addSubview:_stateSelectionButton];
    height = _textState.frame.size.height * 5.0f;
    _textState.enabled = false;
    _textState.userInteractionEnabled = false;
    _textState.hidden = false;
    _stateSelectionArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_arrow_down"]];
    
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        _stateSelectionArrow.frame = CGRectMake(_stateSelectionArrow.frame.size.width, (_textState.frame.size.height - _stateSelectionArrow.frame.size.height) - 10, _stateSelectionArrow.frame.size.width, _stateSelectionArrow.frame.size.height);
    } else {
        _stateSelectionArrow.frame = CGRectMake(_textState.frame.size.width - _stateSelectionArrow.frame.size.width * 2, (_textState.frame.size.height - _stateSelectionArrow.frame.size.height) - 10, _stateSelectionArrow.frame.size.width, _stateSelectionArrow.frame.size.height);
    }
    [_textState addSubview:_stateSelectionArrow];
    
    _stateSelectionButton.userInteractionEnabled = false;
    _stateSelectionArrow.hidden = true;
    
    [self createAddressPopup];
}
-(void)cancelNumberPad:(UIBarButtonItem*)button {
    //    UITextField* textInputView = (UITextField*)[button.customView.layer valueForKey:@"MY_INPUT_VIEW"];
    [self textFieldShouldReturn:_textFieldFirstResponder];
}
-(void)doneWithNumberPad:(UIBarButtonItem*)button {
    //    UITextField* textInputView = (UITextField*)[button.customView.layer valueForKey:@"MY_INPUT_VIEW"];
    [self textFieldShouldReturn:_textFieldFirstResponder];
}



- (void)chkBoxButtonClicked:(id)sender {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    if([_chkBoxCopyAddress isSelected] == YES) {
        [_chkBoxCopyAddress setSelected:NO];
    } else {
        [_chkBoxCopyAddress setSelected:YES];
    }
    
    int billingAddressCount = (int)[[[AppUser sharedManager] _billingAddressArray] count];
    int shippingAddressCount = (int)[[[AppUser sharedManager] _shippingAddressArray] count];
    
    Address* address = _tempAddress;
    if (address._isShippingAddress) {
        if (_chkBoxCopyAddress.selected) {
            if (billingAddressCount > 0) {
                //use address same as shipping address if any
                Address* savedAddress = (Address*)[[[AppUser sharedManager] _billingAddressArray] objectAtIndex:0];
                _textFirstName.text = [NSString stringWithFormat:@"%@", savedAddress._first_name];
                _textLastName.text = [NSString stringWithFormat:@"%@", savedAddress._last_name];
                _textAddress1.text = [NSString stringWithFormat:@"%@", savedAddress._address_1];
                _textAddress2.text = [NSString stringWithFormat:@"%@", savedAddress._address_2];
                _textCity.text = [NSString stringWithFormat:@"%@", savedAddress._city];
                _textPostalCode.text = [NSString stringWithFormat:@"%@", savedAddress._postcode];
                _textEmail.text = [NSString stringWithFormat:@"%@", savedAddress._email];
                _textContactNumber.text = [NSString stringWithFormat:@"%@", savedAddress._phone];
                //if (![savedAddress._country isEqualToString:@""])
                {
                    
                    TMCountry* country =  [TMCountry getCountryByName:savedAddress._country];
                    if (country) {
                        [self countryButtonClicked:_countrySelectionButton];
                        [self reponseDropDownDelegate:_dropdownViewCountry clickedItemId:[TMCountry getCountryIndex:country]];
                        [self countryButtonClicked:_countrySelectionButton];
                    }
                }
                //if (![savedAddress._state isEqualToString:@""])
                {
                    if (_selectedCountry) {
                        TMState* state = [TMState getStateByName:_selectedCountry stateName:savedAddress._state];
                        if (state) {
                            [self reponseDropDownDelegate:_dropdownViewState clickedItemId:[TMState getStateIndex:_selectedCountry state:state]];
                        }
                    }
                }
                _chkBoxCopyAddress.tag = 0;
            } else {
                //copy address for shipping.. this case is used at saving time
                _chkBoxCopyAddress.tag = 1;
            }
        }else{
            //do nothing just save this data
            _chkBoxCopyAddress.tag = 0;
        }
    }
    else if (address._isBillingAddress) {
        if (_chkBoxCopyAddress.selected) {
            if (shippingAddressCount > 0) {
                //use address same as shipping address if any
                Address* savedAddress = (Address*)[[[AppUser sharedManager] _shippingAddressArray] objectAtIndex:0];
                _textFirstName.text = [NSString stringWithFormat:@"%@", savedAddress._first_name];
                _textLastName.text = [NSString stringWithFormat:@"%@", savedAddress._last_name];
                _textAddress1.text = [NSString stringWithFormat:@"%@", savedAddress._address_1];
                _textAddress2.text = [NSString stringWithFormat:@"%@", savedAddress._address_2];
                _textCity.text = [NSString stringWithFormat:@"%@", savedAddress._city];
                _textPostalCode.text = [NSString stringWithFormat:@"%@", savedAddress._postcode];
                _textEmail.text = [NSString stringWithFormat:@"%@", savedAddress._email];
                _textContactNumber.text = [NSString stringWithFormat:@"%@", savedAddress._phone];
                //                if (![savedAddress._country isEqualToString:@""])
                {
                    TMCountry* country =  [TMCountry getCountryByName:savedAddress._country];
                    if (country) {
                        [self countryButtonClicked:_countrySelectionButton];
                        [self reponseDropDownDelegate:_dropdownViewCountry clickedItemId:[TMCountry getCountryIndex:country]];
                        [self countryButtonClicked:_countrySelectionButton];
                    }
                }
                //                if (![savedAddress._state isEqualToString:@""])
                {
                    if (_selectedCountry) {
                        TMState* state = [TMState getStateByName:_selectedCountry stateName:savedAddress._state];
                        if (state) {
                            [self reponseDropDownDelegate:_dropdownViewState clickedItemId:[TMState getStateIndex:_selectedCountry state:state]];
                        }
                    }
                }
                _chkBoxCopyAddress.tag = 0;
            } else {
                //copy address for shipping.. this case is used at saving time
                _chkBoxCopyAddress.tag = 1;
            }
        }else{
            //do nothing just save this data
            _chkBoxCopyAddress.tag = 0;
        }
    }
    
    
    if (_tempAddress._isBillingAddress) {
        _textEmail.hidden = false;
        _textContactNumber.hidden = false;
    }else{
        if (_chkBoxCopyAddress.tag == 1) {
            _textEmail.hidden = false;
            _textContactNumber.hidden = false;
        } else {
            //            _textEmail.hidden = true;
            //            _textContactNumber.hidden = true;
        }
    }
}
- (void)countryButtonClicked:(id)sender {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    if (sender == _countrySelectionButton) {
        if([_dropdownViewState isDropDownViewVisible] == false){
            if ([_dropdownViewCountry isDropDownViewVisible]) {
                _stateSelectionButton.userInteractionEnabled = true;
            }else{
                _stateSelectionButton.userInteractionEnabled = false;
            }
            [_dropdownViewCountry toggleWithMainFrame:sender];
        }
    } else if (sender == _stateSelectionButton) {
        if([_dropdownViewCountry isDropDownViewVisible] == false){
            [_dropdownViewState toggleWithMainFrame:sender];
        }
    }
}
- (void)reponseDropDownDelegate:(NIDropDown *)sender clickedItemId:(int)clickedItemId{
    
    if (sender == _dropdownViewCountry) {
        _textCountry.text = [_dataObjectsCountry objectAtIndex:clickedItemId];
        _textState.text = @"";
        [_countrySelectionButton setTitle:@"" forState:UIControlStateNormal];
        
        _selectedCountry = [TMCountry getCountryByIndex:clickedItemId];
        if (_dropdownViewState != nil) {
            [_dropdownViewState removeFromSuperview];
            _dropdownViewState = nil;
        }
        float height = _textState.frame.size.height * 5.0f;
        NSMutableArray* stateNames = [TMState getStateNames:_selectedCountry];
        if ((int)[stateNames count] > 0) {
            _dataObjectsState = [[NSMutableArray alloc] initWithArray:stateNames];
            _dropdownViewState = [[NIDropDown alloc] init:_stateSelectionButton viewheight:height strArr:_dataObjectsState imgArr:nil direction:NIDropDownDirectionDown pView:_textState.superview];
            _dropdownViewState.delegate = self;
            [_textState.superview addSubview:_dropdownViewState];
            _dropdownViewState.backgroundColor = [UIColor blueColor];
            [_dropdownViewState toggleWithMainFrame:_stateSelectionButton];
            _stateSelectionButton.userInteractionEnabled = true;
            _textState.placeholder = Localize(@"*State");
            
            [_stateSelectionArrow setHidden:false];
        }else{
            _textState.placeholder = Localize(@"State Data Not Fetched. Sorry!");
            
            [_stateSelectionArrow setHidden:true];
        }
    } else if (sender == _dropdownViewState) {
        _textState.text = [_dataObjectsState objectAtIndex:clickedItemId];
        [_stateSelectionButton setTitle:@"" forState:UIControlStateNormal];
        _selectedState = [TMState getStateByIndex:_selectedCountry index:clickedItemId];
    }
}
- (void)fillDataInPopup {
    if (_addressFailedToSubmit) {
        _textFirstName.text = _addressFailedToSubmit._first_name;
        _textLastName.text = _addressFailedToSubmit._last_name;
        //        _textCompany.text = _addressFailedToSubmit._company;
        _textContactNumber.text = _addressFailedToSubmit._phone;
        _textAddress1.text = _addressFailedToSubmit._address_1;
        _textAddress2.text = _addressFailedToSubmit._address_2;
        _textCity.text = _addressFailedToSubmit._city;
        _textPostalCode.text = _addressFailedToSubmit._postcode;
        //        _textState.text = _addressFailedToSubmit._state;
        //        _textCountry.text = _addressFailedToSubmit._country;
        _textEmail.text = _addressFailedToSubmit._email;
        
        if (![_addressFailedToSubmit._country isEqualToString:@""]) {
            TMCountry* country =  [TMCountry getCountryByName:_addressFailedToSubmit._country];
            if (country) {
                [self countryButtonClicked:_countrySelectionButton];
                [self reponseDropDownDelegate:_dropdownViewCountry clickedItemId:[TMCountry getCountryIndex:country]];
                [self countryButtonClicked:_countrySelectionButton];
            }
        }else{
            _textCountry.text = @"";
        }
        
        
        if (![_addressFailedToSubmit._state isEqualToString:@""]) {
            if (_selectedCountry) {
                TMState* state = [TMState getStateByName:_selectedCountry stateName:_addressFailedToSubmit._state];
                if (state) {
                    [self reponseDropDownDelegate:_dropdownViewState clickedItemId:[TMState getStateIndex:_selectedCountry state:state]];
                }
            }
        }else{
            _textState.text = @"";
        }
        return;
    }
    if (_editAddress) {
        _textFirstName.text = _editAddress._first_name;
        _textLastName.text = _editAddress._last_name;
        //        _textCompany.text = _editAddress._company;
        _textContactNumber.text = _editAddress._phone;
        _textAddress1.text = _editAddress._address_1;
        _textAddress2.text = _editAddress._address_2;
        _textCity.text = _editAddress._city;
        _textPostalCode.text = _editAddress._postcode;
        //        _textState.text = _editAddress._state;
        //        _textCountry.text = _editAddress._country;
        _textEmail.text = _editAddress._email;
        
        if (![_editAddress._country isEqualToString:@""]) {
            TMCountry* country =  [TMCountry getCountryByName:_editAddress._country];
            if (country) {
                [self countryButtonClicked:_countrySelectionButton];
                [self reponseDropDownDelegate:_dropdownViewCountry clickedItemId:[TMCountry getCountryIndex:country]];
                [self countryButtonClicked:_countrySelectionButton];
            }
        }else{
            _textCountry.text = @"";
        }
        
        
        if (![_editAddress._state isEqualToString:@""]) {
            if (_selectedCountry) {
                TMState* state = [TMState getStateByName:_selectedCountry stateName:_editAddress._state];
                if (state) {
                    [self reponseDropDownDelegate:_dropdownViewState clickedItemId:[TMState getStateIndex:_selectedCountry state:state]];
                }
            }
        }else{
            _textState.text = @"";
        }
    }
    else {
        AppUser* appUser = [AppUser sharedManager];
        if (![appUser._first_name isEqualToString:@""]) {
            _textFirstName.text = appUser._first_name;
        }else{
            _textFirstName.text = @"";
        }
        if (![appUser._last_name isEqualToString:@""]) {
            _textLastName.text = appUser._last_name;
        }else{
            _textLastName.text = @"";
        }
        //        _textCompany.text = @"";
        _textContactNumber.text = @"";
        _textAddress1.text = @"";
        _textAddress2.text = @"";
        
        if (![appUser._email isEqualToString:@""]) {
            _textEmail.text = appUser._email;
        }else{
            _textEmail.text = @"";
        }
        
        if (![_dataManager.userTempCity isEqualToString:@""]) {
            _textCity.text = _dataManager.userTempCity;
        }else{
            _textCity.text = @"";
        }
        if (![_dataManager.userTempPostalCode isEqualToString:@""]) {
            _textPostalCode.text = _dataManager.userTempPostalCode;
        }else{
            _textPostalCode.text = @"";
        }
        
        if (![_dataManager.userTempCountry isEqualToString:@""]) {
            TMCountry* country =  [TMCountry getCountryByName:_dataManager.userTempCountry];
            if (country) {
                [self countryButtonClicked:_countrySelectionButton];
                [self reponseDropDownDelegate:_dropdownViewCountry clickedItemId:[TMCountry getCountryIndex:country]];
                [self countryButtonClicked:_countrySelectionButton];
            }
        }else{
            _textCountry.text = @"";
        }
        if (![_dataManager.userTempState isEqualToString:@""]) {
            if (_selectedCountry) {
                TMState* state = [TMState getStateByName:_selectedCountry stateName:_dataManager.userTempState];
                if (state) {
                    [self reponseDropDownDelegate:_dropdownViewState clickedItemId:[TMState getStateIndex:_selectedCountry state:state]];
                }
            }
        }else{
            _textState.text = @"";
        }
    }
    if (_tempAddress._isBillingAddress) {
        _textEmail.hidden = false;
        _textContactNumber.hidden = false;
    }
    else{
        if (_chkBoxCopyAddress.tag == 1) {
            _textEmail.hidden = false;
            _textContactNumber.hidden = false;
        } else {
            //            _textEmail.hidden = true;
            //            _textContactNumber.hidden = true;
        }
    }
    
}
#pragma mark - CNPPopupController Delegate
- (void)popupController:(CNPPopupController *)controller didDismissWithButtonTitle:(NSString *)title {
    RLOG(@"Dismissed with button title: %@", title);
}
- (void)popupControllerDidPresent:(CNPPopupController *)controller {
    RLOG(@"Popup controller presented.");
}
#pragma mark - event response
- (void)saveClicked:(id)sender {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    BOOL isStateNecessary = true;
    BOOL isEmailNecessary = true;
    BOOL isPhoneNecessary = true;
    if ((int)[_selectedCountry.countryStates count] == 0) {
        isStateNecessary = false;
    }
    if (_textEmail.hidden == true) {
        isEmailNecessary = false;
    }
    if (_textContactNumber.hidden == true) {
        isPhoneNecessary = false;
    }
    
    
    //    if( [_textFirstName.text isEqualToString:@""] ||
    //       [_textLastName.text isEqualToString:@""] ||
    //       (isPhoneNecessary && [_textContactNumber.text isEqualToString:@""]) ||
    //       [_textAddress1.text isEqualToString:@""] ||
    //       [_textCity.text isEqualToString:@""] ||
    //       [_textPostalCode.text isEqualToString:@""] ||
    //       (isStateNecessary && [_textState.text isEqualToString:@""]) ||
    //       [_textCountry.text isEqualToString:@""] ||
    //       (isEmailNecessary && [_textEmail.text isEqualToString:@""])
    //       ) {
    //        [self showErrorAlert];
    //        return;
    //    }
    
    
    if (_tempAddress) {
        _tempAddress._first_name = _textFirstName.text;
        _tempAddress._last_name = _textLastName.text;
        //        _tempAddress._company =  _textCompany.text;
        _tempAddress._phone = _textContactNumber.text;
        _tempAddress._address_1 = _textAddress1.text;
        _tempAddress._address_2 = _textAddress2.text;
        _tempAddress._city = _textCity.text;
        _tempAddress._postcode= _textPostalCode.text;
        _tempAddress._state = _textState.text;
        _tempAddress._country = _textCountry.text;
        _tempAddress._email = _textEmail.text;
    }
    Address* address = _tempAddress;
    
    BOOL isObjectExists = false;
    UIView* viewObject = nil;
    
    if (_tempAddress) {
        for (UIView* view in _viewsAdded) {
            if([view.layer valueForKey:@"address"] == _tempAddress) {
                //object is already in list //so update its view
                isObjectExists = true;
                viewObject = view;
                break;
            }
        }
    }
    if (viewObject) {
        for (UIView* v in [viewObject subviews]) {
            
            switch (v.tag) {
                case _kTAGTEXTLABEL_FIRST_N_LAST_NAME:
                {
                    UILabel* textLabel = (UILabel*)v;
                    [textLabel setText:[NSString stringWithFormat:@"%@ %@", address._first_name, address._last_name]];
                }break;
                case _kTAGTEXTLABEL_COMPANY:
                {
                    UILabel* textLabel = (UILabel*)v;
                    //                    [textLabel setText:[NSString stringWithFormat:@"Company: %@", address._company]];
                    [textLabel setText:@""];
                }break;
                case _kTAGTEXTLABEL_ADDRESS1:
                {
                    UILabel* textLabel = (UILabel*)v;
                    [textLabel setText:[NSString stringWithFormat:Localize(@"Address: %@"), address._address_1]];
                }break;
                case _kTAGTEXTLABEL_ADDRESS2:
                {
                    UILabel* textLabel = (UILabel*)v;
                    [textLabel setText:[NSString stringWithFormat:@"%@", address._address_2]];
                }break;
                case _kTAGTEXTLABEL_CITY_N_POSTAL:
                {
                    UILabel* textLabel = (UILabel*)v;
                    [textLabel setText:[NSString stringWithFormat:Localize(@"City: %@\tPostal Code: %@"), address._city, address._postcode]];
                }break;
                case _kTAGTEXTLABEL_STATE:
                {
                    UILabel* textLabel = (UILabel*)v;
                    [textLabel setText:[NSString stringWithFormat:Localize(@"State: %@"), address._state]];
                    if ([address._state isEqualToString:@""] || address._state == nil) {
                        textLabel.hidden = true;
                    }
                }break;
                case _kTAGTEXTLABEL_COUNTRY:
                {
                    UILabel* textLabel = (UILabel*)v;
                    [textLabel setText:[NSString stringWithFormat:Localize(@"Country: %@"), address._country]];
                }break;
                case _kTAGTEXTLABEL_EMAIL:
                {
                    UILabel* textLabel = (UILabel*)v;
                    [textLabel setText:[NSString stringWithFormat:Localize(@"E-mail: %@"), address._email]];
                }break;
                case _kTAGTEXTLABEL_CONTACT:
                {
                    UILabel* textLabel = (UILabel*)v;
                    [textLabel setText:[NSString stringWithFormat:Localize(@"Phone No.:%@"), address._phone]];
                }break;
                    
                default:
                    break;
            }
        }
    }
    {
        //reload full view
        Address* address = _tempAddress;
        address._first_name = _textFirstName.text;
        address._last_name = _textLastName.text;
        //        address._company =  _textCompany.text;
        address._phone = _textContactNumber.text;
        address._address_1 = _textAddress1.text;
        address._address_2 = _textAddress2.text;
        address._city = _textCity.text;
        address._postcode= _textPostalCode.text;
        address._state = _textState.text;
        address._country = _textCountry.text;
        if (_selectedState.stateId) {
            address._stateId = _selectedState.stateId;
        }
        if (_selectedCountry.countryId) {
            address._countryId = _selectedCountry.countryId;
        }
        address._email = _textEmail.text;
        
        
        if (address._isBillingAddress) {
            [[[AppUser sharedManager] _billingAddressArray] removeAllObjects];
            [[[AppUser sharedManager] _billingAddressArray] addObject:address];
            if (_chkBoxCopyAddress.selected) {
                if (_chkBoxCopyAddress.tag == 1) {
                    [[[AppUser sharedManager] _shippingAddressArray] removeAllObjects];
                    
                    Address* newAddress = [[Address alloc] init];
                    newAddress._address_1 = [NSString stringWithFormat:@"%@", address._address_1];
                    newAddress._address_2 = [NSString stringWithFormat:@"%@", address._address_2];
                    newAddress._city = [NSString stringWithFormat:@"%@", address._city];
                    newAddress._company = [NSString stringWithFormat:@"%@", address._company];
                    newAddress._country = [NSString stringWithFormat:@"%@", address._country];
                    newAddress._email = [NSString stringWithFormat:@"%@", address._email];
                    newAddress._first_name = [NSString stringWithFormat:@"%@", address._first_name];
                    newAddress._isBillingAddress = false;
                    newAddress._isShippingAddress = true;
                    newAddress._last_name = [NSString stringWithFormat:@"%@", address._last_name];
                    newAddress._phone = [NSString stringWithFormat:@"%@", address._phone];
                    newAddress._postcode = [NSString stringWithFormat:@"%@", address._postcode];
                    newAddress._state = [NSString stringWithFormat:@"%@", address._state];
                    newAddress._stateId = [NSString stringWithFormat:@"%@", address._stateId];
                    newAddress._countryId = [NSString stringWithFormat:@"%@", address._countryId];
                    
                    [[[AppUser sharedManager] _shippingAddressArray] addObject:newAddress];
                }
            }
        }
        else if (address._isShippingAddress) {
            [[[AppUser sharedManager] _shippingAddressArray] removeAllObjects];
            [[[AppUser sharedManager] _shippingAddressArray] addObject:address];
            if (_chkBoxCopyAddress.selected) {
                if (_chkBoxCopyAddress.tag == 1) {
                    [[[AppUser sharedManager] _billingAddressArray] removeAllObjects];
                    
                    Address* newAddress = [[Address alloc] init];
                    newAddress._address_1 = [NSString stringWithFormat:@"%@", address._address_1];
                    newAddress._address_2 = [NSString stringWithFormat:@"%@", address._address_2];
                    newAddress._city = [NSString stringWithFormat:@"%@", address._city];
                    newAddress._company = [NSString stringWithFormat:@"%@", address._company];
                    newAddress._country = [NSString stringWithFormat:@"%@", address._country];
                    newAddress._email = [NSString stringWithFormat:@"%@", address._email];
                    newAddress._first_name = [NSString stringWithFormat:@"%@", address._first_name];
                    newAddress._isBillingAddress = true;
                    newAddress._isShippingAddress = false;
                    newAddress._last_name = [NSString stringWithFormat:@"%@", address._last_name];
                    newAddress._phone = [NSString stringWithFormat:@"%@", address._phone];
                    newAddress._postcode = [NSString stringWithFormat:@"%@", address._postcode];
                    newAddress._state = [NSString stringWithFormat:@"%@", address._state];
                    newAddress._stateId = [NSString stringWithFormat:@"%@", address._stateId];
                    newAddress._countryId = [NSString stringWithFormat:@"%@", address._countryId];
                    [[[AppUser sharedManager] _billingAddressArray] addObject:newAddress];
                }
            }
        }
    }
    AppUser* appUser = [AppUser sharedManager];
    if ([appUser._billingAddressArray count] > 0){
        appUser._billing_address = (Address*)[appUser._billingAddressArray objectAtIndex:0];
    }
    if ([appUser._shippingAddressArray count] > 0){
        appUser._shipping_address = (Address*)[appUser._shippingAddressArray objectAtIndex:0];
    }
    
    
    if ([appUser._billingAddressArray count] > 0 && [appUser._shippingAddressArray count] > 0) {
        Address* shippAddress =  [appUser._shippingAddressArray objectAtIndex:0];
        Address* billAddress =  [appUser._billingAddressArray objectAtIndex:0];
        if (![_tempAddress._phone isEqualToString:@""]) {
            billAddress._phone = [NSString stringWithFormat:@"%@", _tempAddress._phone];
            shippAddress._phone = [NSString stringWithFormat:@"%@", _tempAddress._phone];
        }
        if (![_tempAddress._email isEqualToString:@""]) {
            billAddress._email = [NSString stringWithFormat:@"%@", _tempAddress._email];
            shippAddress._email = [NSString stringWithFormat:@"%@", _tempAddress._email];
        }
    }
    
    
    
    
    
    //    [[AppUser sharedManager] saveData];
    [[[DataManager sharedManager] tmDataDoctor] updateCustomerData];
    [self storeDataTemp];
    [self loadAllViews];
    _tempAddress = nil;
    _editAddress = nil;
    [self cancelClicked:nil];
}
- (void)storeDataTemp {
    _addressFailedToSubmit = [[Address alloc] init];
    _addressFailedToSubmit._first_name = _textFirstName.text;
    _addressFailedToSubmit._last_name = _textLastName.text;
    _addressFailedToSubmit._phone = _textContactNumber.text;
    _addressFailedToSubmit._address_1 = _textAddress1.text;
    _addressFailedToSubmit._address_2 = _textAddress2.text;
    _addressFailedToSubmit._city = _textCity.text;
    _addressFailedToSubmit._postcode= _textPostalCode.text;
    _addressFailedToSubmit._state = _textState.text;
    _addressFailedToSubmit._country = _textCountry.text;
    _addressFailedToSubmit._email = _textEmail.text;
    if (_selectedState.stateId) {
        _addressFailedToSubmit._stateId = _selectedState.stateId;
    }
    if (_selectedCountry.countryId) {
        _addressFailedToSubmit._countryId = _selectedCountry.countryId;
    }
}
- (void)cancelClicked:(id)sender {
    if (sender) {
        //        [self storeDataTemp];
    }
    
    _textState.placeholder = Localize(@"*State");
    _stateSelectionButton.userInteractionEnabled = false;
    _stateSelectionArrow.hidden = true;
    [self.popupController dismissPopupControllerAnimated:YES];
    if (_isAddressOverConfirmationScreen) {
        [self barButtonBackPressed:nil];
    }
    
}
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
- (void)showErrorAlert {
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"" message:Localize(@"Fields marked as ( * ) are mandatory.") delegate:nil cancelButtonTitle:Localize(@"OK") otherButtonTitles:nil, nil];
    [errorAlert show];
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
    [self adjustViewsAfterOrientation:[[UIDevice currentDevice] orientation]];
    [self resetMainScrollView];
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self adjustViewsForOrientation:[[UIDevice currentDevice] orientation]];
    [self resetMainScrollView];
}
@end
