//
//  ViewControllerCartConfirmation.m
//  eMobileApp
//
//  Created by Rishabh Jain on 25/11/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import "ViewControllerCartConfirmation.h"
#import "ViewControllerAddress.h"
#import "AppUser.h"
#import "Attribute.h"
#import "Order.h"
#import "DataManager.h"
#import "CommonInfo.h"
#import "ViewControllerOrderReceipt.h"
#import "ViewControllerCheckout.h"
#import "ViewControllerCartShipping.h"
#import "ViewControllerAddress.h"
#import "TMShippingSDK.h"
#import "DDView.h"
static int kTagForGlobalSpacing = 0;
static int kTagForGlobalSpacingDouble = 0;

static int kTagForNoSpacing = -1;

@interface ViewControllerCartConfirmation () {
    NSMutableArray* _viewsAdded;
    UIButton *customBackButton;
    NSMutableArray* _regionSequences;
}
@end


@implementation ViewControllerCartConfirmation

- (void)viewDidLoad {
    [super viewDidLoad];
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
    
    _alertViewForAddBilling = [[UIAlertView alloc] initWithTitle:@"" message:@"" delegate:self cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil];
    _alertViewForAddShipping = [[UIAlertView alloc] initWithTitle:@"" message:@"" delegate:self cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil];
    _alertViewForEditBilling = [[UIAlertView alloc] initWithTitle:@"" message:@"" delegate:self cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil];
    _alertViewForEditShipping = [[UIAlertView alloc] initWithTitle:@"" message:@"" delegate:self cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil];
    
    [self initVariables];
    //    [[[[DataManager sharedManager] tmDataDoctor] tmMulticastDelegate] addDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)viewWillAppear:(BOOL)animated {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super viewWillAppear:animated];
    
    [self loadAllViews];
    [self fetchWCCheckoutManagerData];
    [self performSelector:@selector(checkToLoadAddress) withObject:nil afterDelay:0.5f] ;
}
- (void)fetchWCCheckoutManagerData {
    if ([[Addons sharedManager] enable_multi_store_checkout] && [[MultiStoreCheckoutConfig getInstance] isDataFetched] == false) {
        [[[DataManager sharedManager] tmDataDoctor] getWCCMData:^(id data) {
            RLOG(@"%@", data);
            UIView* view = [self createWCCMView];
            [Utility showShadow:view];
        } failure:^(NSString *error) {
            RLOG(@"%@", error);
        }];
    }
    
    
//    if ([[Addons sharedManager] enable_multi_store_checkout]) {
//        AppUser* appUser = [AppUser sharedManager];
//        NSMutableArray* orderIDs = [[NSMutableArray alloc] init];
//        for (Order* obj in appUser._ordersArray) {
//            [orderIDs addObject:[NSString stringWithFormat:@"%d", obj._id]];
//        }
//        if ([orderIDs count] > 0) {
//            [[[DataManager sharedManager] tmDataDoctor] getWCCMDataForOrders:orderIDs success:^(id data) {
//                RLOG(@"");
//            } failure:^(NSString *error) {
//                RLOG(@"");
//            }];
//        }
//    }
}
- (void)checkToLoadAddress {
    AppUser* appUser = [AppUser sharedManager];
    NSString* errorDesc = @"";
    int billingAddressesCount = 1;
    int shippingAddressesCount = 1;
    if (shippingAddressesCount == 0) {
        errorDesc = Localize(@"Please Enter Shipping Address");
        //show alert for shipping address
        _alertViewForAddShipping.message = errorDesc;
        //        [_alertViewForAddShipping show];
        [self alertView:_alertViewForAddShipping didDismissWithButtonIndex:0];
        return;
    }
    else if (billingAddressesCount == 0) {
        errorDesc = Localize(@"Please Enter Billing Address");
        //show alert for billing address
        _alertViewForAddBilling.message = errorDesc;
        //        [_alertViewForAddBilling show];
        [self alertView:_alertViewForAddBilling didDismissWithButtonIndex:0];
        return;
    }
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
        if ([tempView tag] == kTagForGlobalSpacingDouble) {
            globalPosY += 20;//[LayoutProperties globalVerticalMargin];
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
    _regionSequences = [[NSMutableArray alloc] initWithArray:[[[DataManager sharedManager] shippingEngine] regionSequences]];
    //    [_scrollView setBackgroundColor:[Utility getUIColor:kUIColorBgTheme]];
    //    [self.view setBackgroundColor:[Utility getUIColor:kUIColorBgHeader]];
    //    [_lineView setBackgroundColor:[Utility getUIColor:kUIColorBorder]];
}
- (void)loadAllViews {
    for (UIView* view in _viewsAdded) {
        [view removeFromSuperview];
    }
    [_viewsAdded removeAllObjects];
    
    _addressViewShipping = nil;
    _addressViewBilling = nil;
    [_labelViewHeading setText:Localize(@"title_mycart")];
    [self createProceedToPay1];
    
    UIView* view;
    
    view = [self createWCCMView];
    [Utility showShadow:view];
    
    if ([[Addons sharedManager] show_shipping_address]) {
        view = [self addHeaderView:Localize(@"shipping_address") isTransparant:false];
        [Utility showShadow:view];
        view = [self createShippingAddress];
        [Utility showShadow:view];
    }
    if ([[Addons sharedManager] show_shipping_address]) {
        view = [self addHeaderView:Localize(@"billing_address") isTransparant:false];
        [Utility showShadow:view];
        view = [self createBillingAddress];
        [Utility showShadow:view];
    }
    view = [self addHeaderView:Localize(@"i_order_summery") isTransparant:false];
    [Utility showShadow:view];
    view = [self createOrderSummery];
    [Utility showShadow:view];
    view = [self addHeaderView:Localize(@"i_amt_details") isTransparant:false];
    [Utility showShadow:view];
    view = [self createAmtDetails];
    [Utility showShadow:view];
    
    
    [self createProceedToPay2];
    [self resetMainScrollView];
}
- (void)createProceedToPay1 {
    UIView* viewDummy1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    [_scrollView addSubview:viewDummy1];
    [_viewsAdded addObject:viewDummy1];
    [viewDummy1 setTag:kTagForGlobalSpacing];
    float imgPosY = self.view.frame.size.width * .01f;
    float imgWidth = self.view.frame.size.width * .5f * 1.5f;
    float imgHeight = [[MyDevice sharedManager] screenHeightInPortrait] * .075f * 1.5f;
    float imgPosX = (self.view.frame.size.width - imgWidth) / 2;
    _topImage = [[UIImageView alloc] initWithFrame:CGRectMake(imgPosX, imgPosY, imgWidth, imgHeight)];
    UIImage* topImg = [[UIImage imageNamed:@"corfirmTopBar"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    if ([[Addons sharedManager] show_pickup_location] && [[TM_PickupLocation getAllPickupLocations] count] > 0) {
        topImg = [[UIImage imageNamed:@"corfirmTopBar_Pickup"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    [_topImage setUIImage:topImg];
    
    [_topImage setTintColor:[Utility getUIColor:kUIColorBlue]];
    [_topImage setContentMode:UIViewContentModeScaleAspectFit];
    [_scrollView addSubview:_topImage];
    [_viewsAdded addObject:_topImage];
    [_topImage setTag:kTagForGlobalSpacingDouble];
}
- (void)createProceedToPay2 {
    UIView* viewDummy2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    [_scrollView addSubview:viewDummy2];
    [_viewsAdded addObject:viewDummy2];
    [viewDummy2 setTag:kTagForGlobalSpacing];
    float buttonPosY = self.view.frame.size.width * .01f;
    float buttonWidth = [[MyDevice sharedManager] screenWidthInPortrait] * 0.6f;
    float buttonHeight = [[MyDevice sharedManager] screenHeightInPortrait] * .075f;
    float buttonPosX = (self.view.frame.size.width - buttonWidth) / 2;
    _btnProceed = [[UIButton alloc] initWithFrame:CGRectMake(buttonPosX, buttonPosY, buttonWidth, buttonHeight)];
    [_btnProceed setBackgroundColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
    [[_btnProceed titleLabel] setUIFont:kUIFontType22 isBold:false];
    [_btnProceed setTitle:Localize(@"select_payment") forState:UIControlStateNormal];
    [_btnProceed setTitleColor:[Utility getUIColor:kUIColorBuyButtonFont] forState:UIControlStateNormal];
    [_btnProceed addTarget:self action:@selector(proceedToPay:) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:_btnProceed];
    [_viewsAdded addObject:_btnProceed];
    [_btnProceed setTag:kTagForGlobalSpacing];
}
- (void)fetchDeliverySlotsCopiaPluginData {
#if ENABLE_DELIVERY_SLOT_COPIA
    Addons* addons = [Addons sharedManager];
    if (addons.deliverySlotsCopiaPlugin.isEnabled) {
        [[[DataManager sharedManager] tmDataDoctor] fetchDeliverySlotsFromPlugin:^(id data) {
            RLOG(@"fetchDeliverySlotsFromPlugin:success");
            [self gotoNextVC1];
        } failure:^(NSString *error) {
            if ([error isEqualToString:@"retry"]) {
                RLOG(@"fetchDeliverySlotsFromPlugin:retry");
                self.retryCount_DeliverySlotsCopia++;
                if (self.retryCount_DeliverySlotsCopia == 3) {
                    [self gotoNextVC1];
                } else {
                    [self fetchDeliverySlotsCopiaPluginData];
                }
            } else {
                RLOG(@"fetchDeliverySlotsFromPlugin:failure");
                [self gotoNextVC1];
            }
        }];
    }
#endif
}
- (void)gotoNextVC {
    Addons* addons = [Addons sharedManager];
    if (addons.deliverySlotsCopiaPlugin.isEnabled) {
        [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
        [Utility createCustomizedLoadingBar:[NSString stringWithFormat:@"%@ ..",Localize(@"calculating_time_slots")] isBottomAlign:false isClearViewEnabled:false isShadowEnabled:true];
        self.retryCount_DeliverySlotsCopia = 0;
        [self fetchDeliverySlotsCopiaPluginData];
    } else {
        [self gotoNextVC1];
    }
}

- (void)gotoNextVC1 {
    [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
    ViewControllerMain* mainVC = [ViewControllerMain getInstance];
    mainVC.containerTop.hidden = YES;
    mainVC.containerCenter.hidden = YES;
    mainVC.containerCenterWithTop.hidden = NO;
    mainVC.vcBottomBar.buttonHome.selected = NO;
    mainVC.vcBottomBar.buttonCart.selected = YES;
    mainVC.vcBottomBar.buttonWishlist.selected = NO;
    mainVC.vcBottomBar.buttonSearch.selected = NO;
    mainVC.revealController.panGestureEnable = false;
    [mainVC.vcBottomBar buttonClicked:nil];
    ViewControllerCartShipping* vcCartShipping = (ViewControllerCartShipping*)[[Utility sharedManager] pushScreenWithoutAnimation:mainVC.vcCenterTop type:PUSH_SCREEN_TYPE_CART_SHIPPING];
}
- (void)cartSyncSuccess:(NSNotification*)notification{
    DataManager* dm = [DataManager sharedManager];
    if (dm.shippingProvider == SHIPPING_PROVIDER_RAJAONGKIR) {
        [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
        [Utility createCustomizedLoadingBar:[NSString stringWithFormat:@"%@..",Localize(@"Fetching Store Location")] isBottomAlign:false isClearViewEnabled:false isShadowEnabled:true];
    }
    [[dm shippingEngine] getStoreLocation:^(id data) {
        if (dm.shippingProvider == SHIPPING_PROVIDER_RAJAONGKIR) {
            AppUser* appUser = [AppUser sharedManager];
            TMRegion* regionDestination = [[TMRegion alloc] initWithoutAppendingInRegionList];
            regionDestination.regionId = appUser._shipping_address._subdistrictId;
            regionDestination.regionTitle = appUser._shipping_address._subdistrict;
            regionDestination.regionType = @"subdistrict";
            
            [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
            [Utility createCustomizedLoadingBar:[NSString stringWithFormat:@"%@..",Localize(@"Fetching Shippings")] isBottomAlign:false isClearViewEnabled:false isShadowEnabled:true];
            [[dm shippingEngine] getAvailableShipping:data regionDestination:regionDestination weight:[Cart getTotalWeight:[[ShippingConfigRajaongkir getInstance] cMinWeight] shippingDefaultWeight:[[ShippingConfigRajaongkir getInstance] cDefaultWeight]] success:^(id data) {
                TMShippingSDK* shippingSDK = [[DataManager sharedManager] tmShippingSDK];
                [shippingSDK resetShippingMethods];
                if (data && [data isKindOfClass:[NSArray class]]) {
                    for (TMShipping* shippingObj in data) {
                        [shippingSDK addShippingMethod:shippingObj];
                    }
                }
                
                [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
                [Utility createCustomizedLoadingBar:[NSString stringWithFormat:@"%@..",Localize(@"Fetching Taxes")] isBottomAlign:false isClearViewEnabled:false isShadowEnabled:true];
                [[dm tmDataDoctor] fetchTaxesData:^(id data) {
                    [self gotoNextVC];
                } failure:^(NSString *error) {
                    [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Localize(@"Failed!") message:Localize(@"Fetching Taxes. Please try again.") delegate:nil cancelButtonTitle:Localize(@"cancel") otherButtonTitles:Localize(@"retry"),nil];
                    [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                        if (buttonIndex == 1) {
                            [self cartSyncSuccess:nil];
                        }
                    }];
                }];
            } failure:^(NSString *error) {
                [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Localize(@"Failed!") message:Localize(@"Fetching Shippings. Please try again.") delegate:nil cancelButtonTitle:Localize(@"cancel") otherButtonTitles:Localize(@"retry"),nil];
                [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    if (buttonIndex == 1) {
                        [self cartSyncSuccess:nil];
                    }
                }];
            }];
        }
        else {
            [self gotoNextVC];
        }
    } failure:^(NSString *error) {
        if (dm.shippingProvider == SHIPPING_PROVIDER_RAJAONGKIR) {
            [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Localize(@"Failed!") message:Localize(@"Fetching Store Location. Please try again.") delegate:nil cancelButtonTitle:Localize(@"cancel") otherButtonTitles:Localize(@"retry"),nil];
            [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (buttonIndex == 1) {
                    [self cartSyncSuccess:nil];
                }
            }];
        }
        else {
            [self gotoNextVC];
        }
    }];
    //here open webview for further progress..
    //    [self orderPurchasedSuccessful];
}
- (void)cartSyncFailed:(NSNotification*)notification{
    
}
- (NSString*)isAddressValidToProceed:(Address*)address {
    
    if(
       (
        [[Addons sharedManager] show_billing_address] == false &&
        address._isBillingAddress
        ) ||
       (
        [[Addons sharedManager] show_shipping_address] == false &&
        address._isShippingAddress
        )
       ) {
        return @"";
    }
    
    
    BOOL isStateNecessary = false;
    BOOL isBillingAddress = address._isBillingAddress;
    BOOL isShippingAddress = address._isShippingAddress;
    NSString* addressType = @"";
    NSString* errorMsg = @"";
    NSString* errorMsgDesc = @"";
    if (isBillingAddress) {
        addressType = Localize(@"billing_address");
    }
    if (isShippingAddress) {
        addressType = Localize(@"shipping_address");
    }
    
    
    BOOL isFirstNameEntered = [address._first_name isEqualToString:@""] ? false : true;
    if (![[[Addons sharedManager] excludedAddress] isVisibleFirstName:isBillingAddress]) {
        isFirstNameEntered = true;
    }
    
    BOOL isLastNameEntered = [address._last_name isEqualToString:@""] ? false : true;
    if (![[[Addons sharedManager] excludedAddress] isVisibleLastName:isBillingAddress]) {
        isLastNameEntered = true;
    }
    
    BOOL isAddress1Entered = [address._address_1 isEqualToString:@""] ? false : true;
    BOOL isAddress2Entered = [address._address_2 isEqualToString:@""] ? false : true;
    BOOL isAddressEntered = (isAddress1Entered||isAddress2Entered);
    if (isAddressEntered == false) {
        if (![[[Addons sharedManager] excludedAddress] isVisibleAddress1:isBillingAddress] && ![[[Addons sharedManager] excludedAddress] isVisibleAddress2:isBillingAddress]) {
            isAddressEntered = true;
        }
    }
    
    
    
    BOOL isCountryEntered = [address._country isEqualToString:@""] ? false : true;
    if (![[[Addons sharedManager] excludedAddress] isVisibleCountry:isBillingAddress]) {
        isCountryEntered = true;
    }
    
    BOOL isStateEntered = [address._state isEqualToString:@""] ? false : true;
    if (![[[Addons sharedManager] excludedAddress] isVisibleState:isBillingAddress]) {
        isStateEntered = true;
    }
    
    BOOL isCityEntered = [address._city isEqualToString:@""] ? false : true;
    if (![[[Addons sharedManager] excludedAddress] isVisibleCity:isBillingAddress]) {
        isCityEntered = true;
    }
    
    BOOL isEmailEntered = [address._email isEqualToString:@""] ? false : true;
    if (![[[Addons sharedManager] excludedAddress] isVisibleEmail:isBillingAddress]) {
        isEmailEntered = true;
    }
    
    BOOL isPostCodeEntered = [address._postcode isEqualToString:@""] ? false : true;
    if (![[[Addons sharedManager] excludedAddress] isVisiblePostCode:isBillingAddress]) {
        isPostCodeEntered = true;
    }
    
    BOOL isPhoneNumberEntered = [address._phone isEqualToString:@""] ? false : true;
    if (![[[Addons sharedManager] excludedAddress] isVisiblePhone:isBillingAddress]) {
        isPhoneNumberEntered = true;
    }
    
    
    if (isCountryEntered) {
        TMCountry* country = [TMCountry getCountryById:address._countryId];
        if ([TMState getStateNames:country]) {
            NSMutableArray* states = [TMState getStateNames:country];
            if (states) {
                int stateCount = (int)[states count];
                if (stateCount > 0) {
                    isStateNecessary = true;
                }
            }
        }
    }
    
    
    if(isBillingAddress) {
        
    }
    if(isShippingAddress) {
        isPhoneNumberEntered = true;
        isEmailEntered = true;
    }
    
    if (isStateNecessary == false) {
        isStateEntered = true;
    }
    
    if (!isFirstNameEntered) {
        errorMsg = Localize(@"first_name");
    }
    else if (!isLastNameEntered) {
        errorMsg = Localize(@"last_name");
    }
    else if (!isAddressEntered) {
        errorMsg = Localize(@"address");
    }
    else if (!isCountryEntered) {
        errorMsg = Localize(@"country");
    }
    else if (!isStateEntered) {
        errorMsg = Localize(@"state");
    }
    else if (!isCityEntered) {
        errorMsg = Localize(@"city");
    }
    else if (!isPostCodeEntered) {
        errorMsg = Localize(@"postcode");
    }
    else if (!isEmailEntered) {
        errorMsg = Localize(@"email");
    }
    else if (!isPhoneNumberEntered) {
        errorMsg = Localize(@"contact_number");
    }
    else {
        errorMsg = @"";
    }
    if (![errorMsg isEqualToString:@""]) {
        errorMsgDesc = [NSString stringWithFormat:Localize(@"please_enter_address"), errorMsg, addressType];
    }
    
    return errorMsgDesc;
}

- (void)proceedToPay:(UIButton*)button{
    AppUser* appUser = [AppUser sharedManager];
    Address* bAdd = appUser._billing_address;
    Address* sAdd = appUser._shipping_address;
    NSString* errorDesc = @"";
    int billingAddressesCount = 1;//(int)[appUser._billingAddressArray count];
    int shippingAddressesCount = 1;//(int)[appUser._shippingAddressArray count];
    if (shippingAddressesCount == 0) {
        errorDesc = Localize(@"Please Enter Shipping Address");
        //show alert for shipping address
        _alertViewForAddShipping.message = errorDesc;
        [_alertViewForAddShipping show];
        return;
    }
    else if (billingAddressesCount == 0) {
        errorDesc = Localize(@"Please Enter Billing Address");
        //show alert for billing address
        _alertViewForAddBilling.message = errorDesc;
        [_alertViewForAddBilling show];
        return;
    }
    else {
        errorDesc = [self isAddressValidToProceed:sAdd];
        if ([errorDesc isEqualToString:@""] == false) {
            //show alert for shipping address
            _alertViewForEditShipping.message = errorDesc;
            [_alertViewForEditShipping show];
            return;
        }else{
            errorDesc = [self isAddressValidToProceed:bAdd];
            if ([errorDesc isEqualToString:@""] == false) {
                //show alert for billing address
                _alertViewForEditBilling.message = errorDesc;
                [_alertViewForEditBilling show];
                return;
            }
        }
    }
    
    
    MultiStoreCheckoutConfig* msConfig = [MultiStoreCheckoutConfig getInstance];
    if ([[Addons sharedManager] enable_multi_store_checkout] && [msConfig isDataFetched] == true) {
        if ([self.wccmDeliveryTimeSlots.buttonSelection.titleLabel.text isEqualToString:Localize(@"i_select")]) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:self.wccmDeliveryTimeSlots.labelSelection.text message:Localize(@"select_time_slot") delegate:self cancelButtonTitle:Localize(@"i_ok") otherButtonTitles:nil, nil];
            [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                [UIView animateWithDuration:0.5f delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                    _scrollView.contentOffset = CGPointZero;
                } completion:^(BOOL finished) {
                    if (finished) {
                        [UIView animateWithDuration:0.0f delay:0.5f options:UIViewAnimationOptionCurveLinear animations:^{
                            
                        } completion:^(BOOL finished) {
                            if (finished) {
                                [self.wccmDeliveryTimeSlots openDropdownView];
                            }
                        }];
                    }
                }];
            }];
            return;
        }
        else {
            //create meta data here.
//            sample
//            {
//                "myfield1": "In Store Collection",
//                "myfield6": " Madzibalori ",
//                "myfield2": "Block 3 Industrial",
//                "myfield3": " Wednesday",
//                "myfield4": "09:00 - 11:00"
//            }

            
            NSMutableDictionary* metaData = [[NSMutableDictionary alloc] init];
            
            NSString *t_wccmOptionDeliveryTypes = [self.wccmOptionDeliveryTypes stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            [metaData setValue:t_wccmOptionDeliveryTypes forKey:self.wccmCowDeliveryTypes];
            
            if (self.wccmClusterDestinations.hidden == false) {
                NSString *t_wccmOptionClusterDestinations = [self.wccmOptionClusterDestinations stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                [metaData setValue:t_wccmOptionClusterDestinations forKey:self.wccmCowClusterDestinations];
            } else {
//                [metaData setValue:@"" forKey:self.wccmCowClusterDestinations];
            }
            NSString *t_wccmOptionHomeDestinations = [self.wccmOptionHomeDestinations stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            [metaData setValue:t_wccmOptionHomeDestinations forKey:self.wccmCowHomeDestinations];
            
            NSString *t_wccmOptionDeliveryDays = [self.wccmOptionDeliveryDays stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            [metaData setValue:t_wccmOptionDeliveryDays forKey:self.wccmCowDeliveryDays];
            
            NSString *t_wccmOptionDeliveryTimeSlots = [self.wccmOptionDeliveryTimeSlots stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            [metaData setValue:t_wccmOptionDeliveryTimeSlots forKey:self.wccmCowDeliveryTimeSlots];
            
            [msConfig setMetaData:metaData];
        }
    }
    
    if (shippingAddressesCount == 0) {
        errorDesc = Localize(@"Please Enter Shipping Address");
        //show alert for shipping address
        _alertViewForAddShipping.message = errorDesc;
        [_alertViewForAddShipping show];
        return;
    }
    
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cartSyncSuccess:) name:@"CART_SYNC_SUCCESS" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cartSyncFailed:) name:@"CART_SYNC_FAILED" object:nil];
    //    [self cartSyncSuccess:nil];
#if ESCAPE_CART_VARIFICATION
    [self gotoNextVC];
    return;
#endif
    [[[DataManager sharedManager] tmDataDoctor] syncCart];
}

- (UIView*)createShippingAddress{
    AppUser* au = [AppUser sharedManager];
    return [self addAddressView:!(au._shipping_address._isAddressSaved) address:au._shipping_address isBillingAddress:false isShippingAddress:true];
}
- (UIView*)createBillingAddress{
    AppUser* au = [AppUser sharedManager];
    return [self addAddressView:!(au._billing_address._isAddressSaved) address:au._billing_address isBillingAddress:true isShippingAddress:false];
}
- (UIView*)addBorder:(UIView*)view{
    UIView* viewBorder = [[UIView alloc] init];
    [viewBorder setFrame:CGRectMake(0, 0, view.frame.size.width, 1)];
    [viewBorder setBackgroundColor:[Utility getUIColor:kUIColorBorder]];
    return viewBorder;
}
- (UIView*)createOrderSummery{
    UIView* view = [[UIView alloc] init];
    [view setFrame:CGRectMake(self.view.frame.size.width * 0.01f, 0, self.view.frame.size.width * 0.98f, 200)];
    [view setBackgroundColor:[UIColor whiteColor]];
    //    [view.layer setBorderColor:[[Utility getUIColor:kUIColorBorder] CGColor]];
    //    [view.layer setBorderWidth:1];
    
    [view addSubview:[self addBorder:view]];
    
    
    float height = 0;
    int itemsCount = (int)[[[AppUser sharedManager] _cartArray] count];
    if (itemsCount > 0) {
        for (int i = 0; i < itemsCount; i++) {
            Cart* c = (Cart*)[[[AppUser sharedManager] _cartArray] objectAtIndex:i];
            
            UIView* subView = [self addView:i pInfo:c.product isCartItem:true isWishlistItem:false quantity:c.count];
            [view addSubview:subView];
            CGRect subViewRect = subView.frame;
            subViewRect.origin.y = height;
            [subView setFrame:subViewRect];
            
            height += subViewRect.size.height;
            
            if (itemsCount > 1 && i < itemsCount - 1) {
                 UIView* horizontalLine = [[UIView alloc] initWithFrame:CGRectMake(subViewRect.size.width *.2f, height - 10, subViewRect.size.width *.7f, 1)];
                [view addSubview:horizontalLine];
                horizontalLine.backgroundColor = [Utility getUIColor:kUIColorBorder];
            }
        }
    }
    
    CGRect viewRect = view.frame;
    viewRect.size.height = height;
    [view setFrame:viewRect];
    [_scrollView addSubview:view];
    [_viewsAdded addObject:view];
    [view setTag:kTagForGlobalSpacing];
    return view;
}
- (UIView*)createAmtDetails{
    
    UILabel* labelTemp= [[UILabel alloc] init];
    [labelTemp setUIFont:kUIFontType24 isBold:false];
    UIView* view = [[UIView alloc] init];
    [view setFrame:CGRectMake(self.view.frame.size.width * 0.01f, 0, self.view.frame.size.width * 0.98f, [[labelTemp font] lineHeight] * 4)];
    
    float posY_item1 = view.frame.size.height * .25f;
    float posX_item1 = self.view.frame.size.width * 0.10f;
    float posX_item2 = self.view.frame.size.width * 0.6f;
    float posY_item2 = view.frame.size.height * .55f;
    float width = view.frame.size.width * .50f;
    float widthN = view.frame.size.width * .30f;
    
    [view setBackgroundColor:[UIColor whiteColor]];
    //    [view.layer setBorderColor:[[Utility getUIColor:kUIColorBorder] CGColor]];
    //    [view.layer setBorderWidth:1];
    [_scrollView addSubview:view];
    [_viewsAdded addObject:view];
    [view setTag:kTagForGlobalSpacing];
    
    [view addSubview:[self addBorder:view]];
    
    float fontHeight = 0;
    
    UILabel* labelQuantityH= [[UILabel alloc] init];
    [labelQuantityH setUIFont:kUIFontType20 isBold:false];
    fontHeight = [[labelQuantityH font] lineHeight];
    [labelQuantityH setFrame:CGRectMake(posX_item1, posY_item1 - fontHeight / 2, widthN, fontHeight)];
    [labelQuantityH setTextColor:[Utility getUIColor:kUIColorFontLight]];
    
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        [labelQuantityH setTextAlignment:NSTextAlignmentLeft];
    } else {
        [labelQuantityH setTextAlignment:NSTextAlignmentRight];
    }
    
    [view addSubview:labelQuantityH];
    NSString* stringQuantitiyH = [NSString stringWithFormat:Localize(@"label_quantity")];
    [labelQuantityH setText:stringQuantitiyH];
    
    //    UILabel* labelAmountH= [[UILabel alloc] init];
    //    [labelAmountH setUIFont:kUIFontType20 isBold:false];
    //    fontHeight = [[labelAmountH font] lineHeight];
    //    [labelAmountH setFrame:CGRectMake(posX_item1, posY_item2 - fontHeight / 2, widthN, fontHeight)];
    //    [labelAmountH setTextColor:[Utility getUIColor:kUIColorFontLight]];
    //    [labelAmountH setTextAlignment:NSTextAlignmentRight];
    //    [view addSubview:labelAmountH];
    //    NSString* stringAmountH = [NSString stringWithFormat:Localize(@"i_cart_totals")];
    //    [labelAmountH setText:stringAmountH];
    
    UILabel* labelAmountH= [[UILabel alloc] init];
    [labelAmountH setFrame:CGRectMake(posX_item1, posY_item2 - fontHeight / 2, widthN, fontHeight)];
    //    [labelAmountH setFrame:CGRectMake(posX_item1, posY_item2 - fontHeight / 2, view.frame.size.width * 0.5f - posX_item1, fontHeight)];
    [labelAmountH setUIFont:kUIFontType20 isBold:false];
    fontHeight = [[labelAmountH font] lineHeight];
    
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        [labelAmountH setTextAlignment:NSTextAlignmentLeft];
    } else {
        [labelAmountH setTextAlignment:NSTextAlignmentRight];
    }
    [view addSubview:labelAmountH];
    NSString* stringAmountH = [NSString stringWithFormat:Localize(@"cart_totals")];
    [labelAmountH setText:stringAmountH];
    labelAmountH.lineBreakMode = NSLineBreakByWordWrapping;
    labelAmountH.numberOfLines = 0;
    [labelAmountH sizeToFitUI];
    [labelAmountH setTextColor:[Utility getUIColor:kUIColorFontLight]];
    if ([[Addons sharedManager] hide_price]) {
        [labelAmountH setFrame:CGRectMake(posX_item1, posY_item2 - fontHeight / 2, widthN, 0)];
    } else {
        [labelAmountH setFrame:CGRectMake(posX_item1, posY_item2 - fontHeight / 2, widthN, labelAmountH.frame.size.height)];
    }
    
    
    UILabel* labelQuantity= [[UILabel alloc] init];
    [labelQuantity setUIFont:kUIFontType20 isBold:false];
    fontHeight = [[labelQuantity font] lineHeight];
    [labelQuantity setFrame:CGRectMake(posX_item2, posY_item1 - fontHeight / 2, width, fontHeight)];
    [labelQuantity setTextColor:[Utility getUIColor:kUIColorFontDark]];
    
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        [labelQuantity setTextAlignment:NSTextAlignmentRight];
    } else {
        [labelQuantity setTextAlignment:NSTextAlignmentLeft];
    }
    [view addSubview:labelQuantity];
    NSString* stringQuantity = [NSString stringWithFormat:@"%d",[Cart getItemCount]];
    
    UILabel* labelAmount= [[UILabel alloc] init];
    [labelAmount setUIFont:kUIFontType20 isBold:false];
    fontHeight = [[labelAmount font] lineHeight];
    if ([[Addons sharedManager] hide_price]) {
        [labelAmount setFrame:CGRectMake(posX_item2, posY_item2 - fontHeight / 2, width, 0)];
    } else {
        [labelAmount setFrame:CGRectMake(posX_item2, posY_item2 - fontHeight / 2, width, fontHeight)];
    }
    [labelAmount setTextColor:[Utility getUIColor:kUIColorFontDark]];
    
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        [labelAmount setTextAlignment:NSTextAlignmentRight];
    } else {
        [labelAmount setTextAlignment:NSTextAlignmentLeft];
    }
    [view addSubview:labelAmount];
    
    float totalPrice = [Cart getTotalPayment];
    NSString* stringGrandTotal = [NSString stringWithFormat:@"%@",[[Utility sharedManager] convertToString:totalPrice isCurrency:true]];
    
    [labelQuantity setText:stringQuantity];
    [labelAmount setText:stringGrandTotal];
    
    UILabel* labelDeliveryCharges= [[UILabel alloc] init];
    [labelDeliveryCharges setUIFont:kUIFontType14 isBold:false];
    fontHeight = [[labelDeliveryCharges font] lineHeight];
    [labelDeliveryCharges setText:Localize(@"i_delivery_charge_info")];

    if ([[MyDevice sharedManager] isIpad]) {
        [labelDeliveryCharges setFrame:CGRectMake(posX_item2, CGRectGetMaxY(labelAmountH.frame), width, fontHeight)];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [labelDeliveryCharges setTextAlignment:NSTextAlignmentRight];
        } else {
            [labelDeliveryCharges setTextAlignment:NSTextAlignmentLeft];
        }
    } else {
        [labelDeliveryCharges setFrame:CGRectMake(0, CGRectGetMaxY(labelAmountH.frame), view.frame.size.width, fontHeight)];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [labelDeliveryCharges setTextAlignment:NSTextAlignmentLeft];
        } else {
            [labelDeliveryCharges setTextAlignment:NSTextAlignmentRight];
        }
    }
    [labelDeliveryCharges setUIFont:kUIFontType14 isBold:false];
    [labelDeliveryCharges setTextColor:[Utility getUIColor:kUIColorFontLight]];
    [view addSubview:labelDeliveryCharges];
    
    
    UILabel* labelQuantityColon= [[UILabel alloc] init];
    [labelQuantityColon setUIFont:kUIFontType20 isBold:false];
    fontHeight = [[labelQuantityColon font] lineHeight];
    [labelQuantityColon setFrame:CGRectMake(width, posY_item1 - fontHeight / 2, width, fontHeight)];
    [labelQuantityColon setTextColor:[Utility getUIColor:kUIColorFontLight]];
    
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        [labelQuantityColon setTextAlignment:NSTextAlignmentRight];
    } else {
        [labelQuantityColon setTextAlignment:NSTextAlignmentLeft];
    }
    [view addSubview:labelQuantityColon];
    [labelQuantityColon setText:@""];
    
    UILabel* labelAmountColon= [[UILabel alloc] init];
    [labelAmountColon setUIFont:kUIFontType20 isBold:false];
    fontHeight = [[labelAmountColon font] lineHeight];
    
    if ([[Addons sharedManager] hide_price]) {
        [labelAmountColon setFrame:CGRectMake(width, posY_item2 - fontHeight / 2, width, 0)];
    } else {
        [labelAmountColon setFrame:CGRectMake(width, posY_item2 - fontHeight / 2, width, fontHeight)];
    }
    
    [labelAmountColon setTextColor:[Utility getUIColor:kUIColorFontLight]];
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        [labelAmountColon setTextAlignment:NSTextAlignmentRight];
    } else {
        [labelAmountColon setTextAlignment:NSTextAlignmentLeft];
    }
    [view addSubview:labelAmountColon];
    [labelAmountColon setText:@""];
    
    
    CGRect viewFrame = view.frame;
    viewFrame.size.height = CGRectGetMaxY(labelDeliveryCharges.frame) + posY_item1 - fontHeight / 2;
    view.frame = viewFrame;
    
    return view;
}

- (UIView*)addAddressView:(BOOL)isEmpty address:(Address*)address isBillingAddress:(BOOL)isBillingAddress isShippingAddress:(BOOL)isShippingAddress {
    UIView* view = nil;
    if (isBillingAddress) {
        if (_addressViewBilling) {
            for (UIView* subView in [_addressViewBilling subviews]) {
                [subView removeFromSuperview];
            }
            view = _addressViewBilling;
        }else{
            view = [[UIView alloc] init];
        }
    }else{
        if (_addressViewShipping) {
            for (UIView* subView in [_addressViewShipping subviews]) {
                [subView removeFromSuperview];
            }
            view = _addressViewShipping;
        }else{
            view = [[UIView alloc] init];
        }
    }
    if (_defaultHeight == 0) {
        _defaultHeight = [[MyDevice sharedManager] screenHeightInPortrait] * .3f;
    }
    [view setFrame: CGRectMake(self.view.frame.size.width * 0.01f, 0, self.view.frame.size.width * 0.98f, _defaultHeight)];
    [view.layer setValue:address forKey:@"ADDRESS_OBJ"];
    [view setBackgroundColor:[UIColor whiteColor]];
    [_scrollView addSubview:view];
    
    if (isShippingAddress) {
        if (_addressViewShipping) {
            int viewIndex = (int)[_viewsAdded indexOfObject:_addressViewShipping];
            [_viewsAdded replaceObjectAtIndex:viewIndex withObject:view];
        }else{
            [_viewsAdded addObject:view];
        }
        _addressViewShipping = view;
    }
    
    if (isBillingAddress) {
        if (_addressViewBilling) {
            int viewIndex = (int)[_viewsAdded indexOfObject:_addressViewBilling];
            [_viewsAdded replaceObjectAtIndex:viewIndex withObject:view];
        }else{
            [_viewsAdded addObject:view];
        }
        _addressViewBilling = view;
    }
    [view setTag:kTagForGlobalSpacing];
    [view addSubview:[self addBorder:view]];
    
    UIButton *buttonAddAddress = [[UIButton alloc] initWithFrame:view.frame];
    [[buttonAddAddress titleLabel] setUIFont:kUIFontType18 isBold:false];
    [buttonAddAddress setTitle:Localize(@"i_add_address") forState:UIControlStateNormal];
    [buttonAddAddress setTitleColor:[Utility getUIColor:kUIColorFontDark] forState:UIControlStateNormal];
    [view addSubview:buttonAddAddress];
    [buttonAddAddress setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    
    if (isEmpty) {
        buttonAddAddress.hidden = false;
        Address* ttempAdd = [[Address alloc] init];
        ttempAdd._isBillingAddress = isBillingAddress;
        ttempAdd._isShippingAddress = isShippingAddress;
        [[buttonAddAddress layer] setValue:ttempAdd forKey:@"ADDRESS_OBJ"];
        [buttonAddAddress addTarget:self action:@selector(addAddressClicked:) forControlEvents:UIControlEventTouchUpInside];
        if (isBillingAddress) {
            _btnAddAddressBilling = buttonAddAddress;
        }else{
            _btnAddAddressShipping = buttonAddAddress;
        }
    } else {
        buttonAddAddress.hidden = true;
        [[buttonAddAddress layer] setValue:address forKey:@"ADDRESS_OBJ"];
        [buttonAddAddress addTarget:self action:@selector(changeAddressClicked:) forControlEvents:UIControlEventTouchUpInside];
        if (isBillingAddress) {
            _btnEditAddressBilling = buttonAddAddress;
        }else{
            _btnEditAddressShipping = buttonAddAddress;
        }
    }
    
    if (isEmpty == false) {
        UILabel* temp = [self createLabel:view fontType:kUIFontType20 fontColorType:kUIColorFontLight frame:CGRectMake(0, 0, 0, 0) textStr:Localize(@"change")];
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
        [button addTarget:self action:@selector(changeAddressClicked:) forControlEvents:UIControlEventTouchUpInside];
        if (isBillingAddress) {
            _btnEditAddressBilling = button;
        }else{
            _btnEditAddressShipping = button;
        }
        
        
        UILabel* name = [self createLabel:view fontType:kUIFontType22 fontColorType:kUIColorFontLight frame:CGRectMake(posX, posY, width, height) textStr:[NSString stringWithFormat:@"%@ %@", address._first_name, address._last_name]];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [name setText:[NSString stringWithFormat:@"%@ %@", address._last_name, address._first_name]];
        } else {
            [name setText:[NSString stringWithFormat:@"%@ %@", address._first_name, address._last_name]];
        }
        name.frame = CGRectMake(name.frame.origin.x, name.frame.origin.y, name.frame.size.width, [name.font lineHeight]);
        
        posY += (LABEL_SIZE(name).height);
        [name setTag:_kTAGTEXTLABEL_FIRST_NAME];
        if (![[[Addons sharedManager] excludedAddress] isVisibleFirstName:isBillingAddress]) {
            name.hidden = true;
            posY -= (LABEL_SIZE(name).height);
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
        if (![[[Addons sharedManager] excludedAddress] isVisibleAddress1:isBillingAddress]) {
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
        if (![[[Addons sharedManager] excludedAddress] isVisibleAddress2:isBillingAddress]) {
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
        if (![[[Addons sharedManager] excludedAddress] isVisiblePostCode:isBillingAddress]) {
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
        if (![[[Addons sharedManager] excludedAddress] isVisibleEmail:isBillingAddress]) {
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
- (UIView*)addHeaderView:(NSString*)str isTransparant:(BOOL)isTransparant{
    UIView* view = [[UIView alloc] init];
    [_scrollView addSubview:view];
    [_viewsAdded addObject:view];
    [view setTag:kTagForNoSpacing];
    
    [view setFrame: CGRectMake(self.view.frame.size.width * 0.01f, 0, self.view.frame.size.width *.98f, 50)];
    
    if(isTransparant){
        [view setBackgroundColor:[Utility getUIColor:kUIColorClear]];
    } else{
        [view setBackgroundColor:[UIColor whiteColor]];
        //        [view.layer setBorderColor:[[Utility getUIColor:kUIColorBorder] CGColor]];
        //        [view.layer setBorderWidth:1];
    }
    
    UILabel* label = [[UILabel alloc] init];
    [label setUIFont:kUIFontType20 isBold:false];
    [label setText:str];
    [label setTextColor:[Utility getUIColor:kUIColorFontLight]];
    CGRect labelRect = view.frame;
    labelRect.origin.x = self.view.frame.size.width * 0.05f;
    [label setFrame:labelRect];
    
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        [label setTextAlignment:NSTextAlignmentRight];
    } else {
        [label setTextAlignment:NSTextAlignmentLeft];
    }
    [label setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [view addSubview:label];
    
    return view;
}
- (void)changeAddressClicked:(UIButton*)button{
    //here open address vc
    ViewControllerMain* mainVC = [ViewControllerMain getInstance];
    mainVC.containerTop.hidden = YES;
    mainVC.containerCenter.hidden = YES;
    mainVC.containerCenterWithTop.hidden = NO;
    mainVC.vcBottomBar.buttonHome.selected = NO;
    mainVC.vcBottomBar.buttonCart.selected = YES;
    mainVC.vcBottomBar.buttonWishlist.selected = NO;
    mainVC.vcBottomBar.buttonSearch.selected = NO;
    mainVC.revealController.panGestureEnable = false;
    [mainVC.vcBottomBar buttonClicked:nil];
    
    ViewControllerAddress* vcAddress = (ViewControllerAddress*)[[Utility sharedManager] pushOverScreenWithoutAnimation:mainVC.vcCenterTop type:PUSH_SCREEN_TYPE_ADDRESS];
    vcAddress.isAddressOverConfirmationScreen = true;
    vcAddress.vcCartConfirmation = self;
    vcAddress.view.opaque = false;
    vcAddress.view.layer.opacity= 0.0f;
    [vcAddress editAddressClicked:button];
}
- (void)addAddressClicked:(UIButton*)button{
    //here open address vc
    ViewControllerMain* mainVC = [ViewControllerMain getInstance];
    mainVC.containerTop.hidden = YES;
    mainVC.containerCenter.hidden = YES;
    mainVC.containerCenterWithTop.hidden = NO;
    mainVC.vcBottomBar.buttonHome.selected = NO;
    mainVC.vcBottomBar.buttonCart.selected = YES;
    mainVC.vcBottomBar.buttonWishlist.selected = NO;
    mainVC.vcBottomBar.buttonSearch.selected = NO;
    mainVC.revealController.panGestureEnable = false;
    [mainVC.vcBottomBar buttonClicked:nil];
    
    ViewControllerAddress* vcAddress = (ViewControllerAddress*)[[Utility sharedManager] pushOverScreenWithoutAnimation:mainVC.vcCenterTop type:PUSH_SCREEN_TYPE_ADDRESS];
    vcAddress.isAddressOverConfirmationScreen = true;
    vcAddress.vcCartConfirmation = self;
    vcAddress.view.opaque = false;
    vcAddress.view.layer.opacity= 0.0f;
    [vcAddress addAddressClicked:button];
}
- (UIView*)addView:(int)listId pInfo:(ProductInfo*)pInfo isCartItem:(BOOL)isCartItem isWishlistItem:(BOOL)isWishlistItem quantity:(int)quantity {
    
    Cart* c = (Cart*)[[[AppUser sharedManager] _cartArray] objectAtIndex:listId];
    Variation* variation = [pInfo._variations getVariation:c.selectedVariationId variationIndex:c.selectedVariationIndex];
    
    float fontHeight = 20;
    float padding = self.view.frame.size.width * 0.05f;
    float height = 0;
    if (listId == 0) {
        height = fontHeight;
    }
    float viewMaxWidth = self.view.frame.size.width * .9f;
    CGRect rect;
    UILabel* labelName = [[UILabel alloc] init];
    [labelName setFrame:CGRectMake(0, height, viewMaxWidth, labelName.frame.size.height)];
    [labelName setUIFont:kUIFontType18 isBold:false];
    [labelName setTextColor:[Utility getUIColor:kUIColorFontLight]];
    [labelName setText:pInfo._title];
    //    [labelName sizeToFitUI];
    //    [labelName setNumberOfLines:0];
    labelName.lineBreakMode = NSLineBreakByWordWrapping;
    labelName.numberOfLines = 0;
    [labelName sizeToFitUI];
    
    height += labelName.frame.size.height;
    rect = labelName.frame;
    rect.origin.x = padding;
    [labelName setFrame:rect];
    
    /////////////
    
    NSMutableString *properties = [NSMutableString string];
    int i = 0;
    
    if (variation) {
        for (VariationAttribute* attribute in variation._attributes) {
            if (i > 0) {
                NSString* str = [NSString stringWithFormat:@", "];
                [properties appendString:str];
            }
            NSString* str = @"";
            if ([attribute.value isEqualToString:@""]) {
                if (c.selected_attributes) {
                    for (VariationAttribute* vAttr in c.selected_attributes) {
                        if([Utility compareAttributeNames:vAttr.slug name2:attribute.slug]) {
//                        if([vAttr.name isEqualToString:attribute.name]) {
                            
                            str = [NSString stringWithFormat:@"%@ - %@",
                                   [Utility getStringIfFormatted:attribute.name],
                                   [Utility getStringIfFormatted:vAttr.value]
                                   ];
                            break;
                        }
                    }
                }
            } else {
                str = [NSString stringWithFormat:@"%@ - %@",
                       [Utility getStringIfFormatted:attribute.name],
                       [Utility getStringIfFormatted:attribute.value]
                       ];
            }
            [properties appendString:str];
            i++;
        }
    }
    else if (c.selectedVariationId != -1) {
        for (VariationAttribute* vAttr in c.selected_attributes) {
            if (i > 0) {
                NSString* str = [NSString stringWithFormat:@", "];
                [properties appendString:str];
            }
            NSString* str = [NSString stringWithFormat:@"%@ - %@",
                             [Utility getStringIfFormatted:vAttr.name],
                             [Utility getStringIfFormatted:vAttr.value]
                             ];
            [properties appendString:str];
            i++;
        }
    }
    
    if (c.product._isFullRetrieved == false) {
        if (c.selectedVariationId != -1 && [properties isEqualToString:@""]) {
            i = 0;
            for (VariationAttribute* vAttr in c.selected_attributes) {
                if (i > 0) {
                    NSString* str = [NSString stringWithFormat:@", "];
                    [properties appendString:str];
                }
                NSString* str = [NSString stringWithFormat:@"%@ - %@",
                                 [Utility getStringIfFormatted:vAttr.name],
                                 [Utility getStringIfFormatted:vAttr.value]
                                 ];
                [properties appendString:str];
                i++;
            }
        }
    }
#if (ENABLE_PRODUCT_DELIVERY_DATA_PLUGIN && 0)
    if ([[Addons sharedManager] productDeliveryDatePlugin] && [[[Addons sharedManager] productDeliveryDatePlugin] isEnabled]) {
        if (c.prddDate && ![c.prddDate isEqualToString:@""]) {
            NSString* deliveryDate = [NSString stringWithFormat:@"%@", c.prddDate];
            if ([[TMLanguage sharedManager] isRTLEnabled]) {
                deliveryDate = [NSString stringWithFormat:@"%@ : %@", deliveryDate, Localize(@"delivery_date")];
            } else {
                deliveryDate = [NSString stringWithFormat:@"%@ : %@", Localize(@"delivery_date"), deliveryDate];
            }
            if (![properties isEqualToString:@""]) {
                [properties appendString:@"\n"];
            }
            [properties appendString:deliveryDate];
        }
        if (c.prddTime && ![c.prddTime.slot_title isEqualToString:@""]) {
            NSString* deliveryTime = [NSString stringWithFormat:@"%@", c.prddTime.slot_title];
            if ([[TMLanguage sharedManager] isRTLEnabled]) {
                deliveryTime = [NSString stringWithFormat:@"%@ : %@", deliveryTime, Localize(@"delivery_time")];
            } else {
                deliveryTime = [NSString stringWithFormat:@"%@ : %@", Localize(@"delivery_time"), deliveryTime];
            }
            if (![properties isEqualToString:@""]) {
                [properties appendString:@"\n"];
            }
            [properties appendString:deliveryTime];
        }
    }
#endif
    if ([properties isEqualToString:@""]){
        [properties appendString:Localize(@"not_available")];
    }
//    [properties appendString:@"\n"];
//    NSString* finalProp = [NSString stringWithFormat:@"\n%@", properties];
    
//    [properties appendString:@"\n"];
    NSString* finalProp = [NSString stringWithFormat:@"%@", properties];

    
    
    
    
//    NSString * htmlString = [NSString stringWithFormat:@"<i>%@</i>", properties];
//    NSMutableAttributedString * finalAttributedProp = [[NSMutableAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil  error:nil];
    UILabel* labelProp = [[UILabel alloc] init];
    [labelProp setFrame:CGRectMake(0, height, viewMaxWidth, labelProp.frame.size.height)];
    [labelProp setUIFont:kUIFontType14 isBold:false];
    [labelProp setTextColor:[Utility getUIColor:kUIColorFontLight]];
    [labelProp setText:finalProp];
//    [labelProp setAttributedText:finalAttributedProp];
    //    [labelProp sizeToFitUI];
    //    [labelProp setNumberOfLines:0];
    labelProp.lineBreakMode = NSLineBreakByWordWrapping;
    labelProp.numberOfLines = 0;
    [labelProp sizeToFitUI];
    
    
    height += labelProp.frame.size.height;
    rect = labelProp.frame;
    rect.origin.x = padding;
    [labelProp setFrame:rect];
//    labelProp.layer.borderWidth = 1;
    
    float gapDateTime = 0;
    UILabel* deliveryDetailsLabel = nil;
    UIImageView* dateSelectionIcon = nil;
    UILabel* dateSelectionLabel = nil;
    UIImageView* timeSelectionIcon = nil;
    UILabel* timeSelectionLabel = nil;
#if ENABLE_PRODUCT_DELIVERY_DATA_PLUGIN
    CGRect rect_prop = labelProp.frame;
    if ([[Addons sharedManager] productDeliveryDatePlugin] && [[[Addons sharedManager] productDeliveryDatePlugin] isEnabled]) {
        
        float spacingIconX = 30;
        float spacingLabelX = 15;
        float iconW = 16;
        float iconH = 16;
        
        if ((c.prddDate && ![c.prddDate isEqualToString:@""]) ||
            (c.prddTime && ![c.prddTime.slot_title isEqualToString:@""])) {
            gapDateTime += 5;
            deliveryDetailsLabel = [[UILabel alloc] init];
            [deliveryDetailsLabel setUIFont:kUIFontType14 isBold:false];
            deliveryDetailsLabel.frame = CGRectMake(labelProp.frame.origin.x, CGRectGetMaxY(rect_prop) + gapDateTime, viewMaxWidth * 1.0f, deliveryDetailsLabel.font.lineHeight);
            [deliveryDetailsLabel setText:Localize(@"delivery_details")];
            [labelProp.superview addSubview:deliveryDetailsLabel];
            [deliveryDetailsLabel setTextColor:[Utility getUIColor:kUIColorFontLight]];
            
            gapDateTime += deliveryDetailsLabel.font.lineHeight;
        }
        
        
        if (c.prddDate && ![c.prddDate isEqualToString:@""]) {
            gapDateTime += 5;
            NSString* deliveryDate = [NSString stringWithFormat:@"%@", c.prddDate];
            dateSelectionIcon = [[UIImageView alloc] init];
            dateSelectionIcon.frame = CGRectMake(labelProp.frame.origin.x + spacingIconX, CGRectGetMaxY(rect_prop) + gapDateTime, iconW, iconH);
            [dateSelectionIcon setImage:[UIImage imageNamed:@"date_icon.png"]];
            [labelProp.superview addSubview:dateSelectionIcon];
            [dateSelectionIcon setTintColor:[Utility getUIColor:kUIColorFontLight]];
            [dateSelectionIcon setContentMode:UIViewContentModeScaleAspectFit];
            
            dateSelectionLabel = [[UILabel alloc] init];
            [dateSelectionLabel setUIFont:kUIFontType14 isBold:false];
            dateSelectionLabel.frame = CGRectMake(CGRectGetMaxX(dateSelectionIcon.frame) + spacingLabelX, CGRectGetMaxY(rect_prop) + gapDateTime, (viewMaxWidth - (CGRectGetMaxX(dateSelectionIcon.frame) + spacingLabelX)), MAX(dateSelectionLabel.font.lineHeight, iconH));
            [dateSelectionLabel setText:deliveryDate];
            [labelProp.superview addSubview:dateSelectionLabel];
            [dateSelectionLabel setTextColor:[Utility getUIColor:kUIColorFontLight]];
            gapDateTime += MAX(dateSelectionLabel.font.lineHeight, iconH);
        }
        if (c.prddTime && ![c.prddTime.slot_title isEqualToString:@""]) {
            gapDateTime += 5;
            NSString* deliveryTime = [NSString stringWithFormat:@"%@", c.prddTime.slot_title];
            
            timeSelectionIcon = [[UIImageView alloc] init];
            timeSelectionIcon.frame = CGRectMake(labelProp.frame.origin.x + spacingIconX, CGRectGetMaxY(rect_prop) + gapDateTime, iconW, iconH);
            [timeSelectionIcon setImage:[UIImage imageNamed:@"time_icon.png"]];
            [labelProp.superview addSubview:timeSelectionIcon];
            [timeSelectionIcon setTintColor:[Utility getUIColor:kUIColorFontLight]];
            [timeSelectionIcon setContentMode:UIViewContentModeScaleAspectFit];
            
            timeSelectionLabel = [[UILabel alloc] init];
            [timeSelectionLabel setUIFont:kUIFontType14 isBold:false];
            timeSelectionLabel.frame = CGRectMake(CGRectGetMaxX(timeSelectionIcon.frame) + spacingLabelX, CGRectGetMaxY(rect_prop) + gapDateTime, (viewMaxWidth - (CGRectGetMaxX(timeSelectionIcon.frame) + spacingLabelX)), MAX(timeSelectionLabel.font.lineHeight, iconH));
            [timeSelectionLabel setText:deliveryTime];
            [labelProp.superview addSubview:timeSelectionLabel];
            [timeSelectionLabel setTextColor:[Utility getUIColor:kUIColorFontLight]];
            gapDateTime += MAX(timeSelectionLabel.font.lineHeight, iconH);
            
        }
    }
#endif
    height += gapDateTime;
    height += padding/2;
    //////////////
    UILabel* labelPriceHeading = [[UILabel alloc] init];
    [labelPriceHeading setFrame:CGRectMake(0, height, viewMaxWidth, fontHeight)];
    [labelPriceHeading setUIFont:kUIFontType16 isBold:false];
    [labelPriceHeading setTextColor:[Utility getUIColor:kUIColorFontLight]];
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        [labelPriceHeading setText:[NSString stringWithFormat:@" %@", Localize(@"i_price")]];
    } else {
        [labelPriceHeading setText:[NSString stringWithFormat:@"%@ ", Localize(@"i_price")]];
    }
    [labelPriceHeading sizeToFitUI];
    [labelPriceHeading setNumberOfLines:0];
    rect = labelPriceHeading.frame;
    rect.origin.x = padding;
    
    if ([[Addons sharedManager] hide_price]) {
        rect.size.height = 0;
    } else {
        
    }
    
    [labelPriceHeading setFrame:rect];
    
    ///////////
    float price = [pInfo getNewPrice:-1];
    if (variation) {
        price = [pInfo getNewPrice:variation._id] + [ProductInfo getExtraPrice:c.selected_attributes pInfo:pInfo];
    } else {
        price = [pInfo getNewPrice:-1];
    }
    if ([[Addons sharedManager] enable_mixmatch_products]) {
        if (c.product.mMixMatch) {
            price = 0.0f;
            for (CartMatchedItem* cmItems in c.mMixMatchProducts) {
                price +=  (cmItems.quantity * cmItems.price);
            }
        }
    }
    NSString *priceStr = [[Utility sharedManager] convertToString:price isCurrency:true];
    if (quantity > 1) {
        priceStr = [NSString stringWithFormat:@"%@ X %d", priceStr, quantity] ;
    } else {
        priceStr = [NSString stringWithFormat:@"%@", priceStr];
    }
    NSString *priceStrFinal = [[Utility sharedManager] convertToString:(price * quantity) isCurrency:true];
    
    
    UILabel* labelPrice = [[UILabel alloc] init];
    [labelPrice setFrame:CGRectMake(0, height, viewMaxWidth, fontHeight)];
    [labelPrice setUIFont:kUIFontType16 isBold:false];
    [labelPrice setTextColor:[Utility getUIColor:kUIColorFontLight]];
    [labelPrice setText:priceStr];
    [labelPrice sizeToFitUI];
    [labelPrice setNumberOfLines:0];
    rect = labelPrice.frame;
    rect.origin.x = CGRectGetMaxX(labelPriceHeading.frame);
    if ([[Addons sharedManager] hide_price]) {
        rect.size.height = 0;
    } else {
        
    }
    [labelPrice setFrame:rect];
    
    ///////////
    UILabel* labelPriceFinal = [[UILabel alloc] init];
    [labelPriceFinal setFrame:CGRectMake(0, height, viewMaxWidth, fontHeight)];
    [labelPriceFinal setUIFont:kUIFontType16 isBold:false];
    [labelPriceFinal setTextColor:[Utility getUIColor:kUIColorFontDark]];
    [labelPriceFinal setText:priceStrFinal];
    [labelPriceFinal sizeToFitUI];
    [labelPriceFinal setNumberOfLines:0];
    rect = labelPriceFinal.frame;
    //    rect.origin.x = viewMaxWidth ;//- CGRectGetMaxX(labelPriceFinal.frame);
    rect.origin.x = viewMaxWidth - CGRectGetMaxX(labelPriceFinal.frame) + padding/2;
    if ([[Addons sharedManager] hide_price]) {
        rect.size.height = 0;
    } else {
        
    }
    [labelPriceFinal setFrame:rect];
    if ([[Addons sharedManager] hide_price]) {
        height += (0 +labelPriceFinal.frame.size.height);
    } else {
        height += (fontHeight +labelPriceFinal.frame.size.height);
    }
        //    labelPriceFinal.layer.borderWidth = 1;
    
    UIView* mainView = [[UIView alloc] init];
    [mainView setFrame:CGRectMake(0, 0, viewMaxWidth, height)];
    [mainView addSubview:labelName];
    if (labelProp) {
        [mainView addSubview:labelProp];
    }
    [mainView addSubview:labelPriceHeading];
    [mainView addSubview:labelPrice];
    [mainView addSubview:labelPriceFinal];
    
    
    if (dateSelectionIcon) {
        [mainView addSubview:dateSelectionIcon];
    }
    if (timeSelectionIcon) {
        [mainView addSubview:timeSelectionIcon];
    }
    if (dateSelectionLabel) {
        [mainView addSubview:dateSelectionLabel];
    }
    if (timeSelectionLabel) {
        [mainView addSubview:timeSelectionLabel];
    }
    if (deliveryDetailsLabel) {
        [mainView addSubview:deliveryDetailsLabel];
    }
    
    
    //    PRINT_RECT(mainView.frame);
    
    return mainView;
    
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
- (void)reloadAddressView{
    UIView* view = nil;
    view = [self createShippingAddress];
    view.layer.shadowOpacity = 0.0f;
    [Utility showShadow:view];
    
    view = [self createBillingAddress];
    view.layer.shadowOpacity = 0.0f;
    [Utility showShadow:view];
    [self resetMainScrollView];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (alertView == _alertViewForAddBilling) {
        [self addAddressClicked:_btnAddAddressBilling];
    }
    else if (alertView == _alertViewForAddShipping) {
        [self addAddressClicked:_btnAddAddressShipping];
    }
    else if (alertView == _alertViewForEditBilling) {
        if (_btnEditAddressBilling) {
            [self changeAddressClicked:_btnEditAddressBilling];
        } else {
            [self addAddressClicked:_btnAddAddressBilling];
        }
    }
    else if (alertView == _alertViewForEditShipping) {
        if (_btnEditAddressShipping) {
             [self changeAddressClicked:_btnEditAddressShipping];
        } else {
             [self addAddressClicked:_btnAddAddressShipping];
        }
    }
}
- (UIView*)createWCCMView {
    MultiStoreCheckoutConfig* msConfig = [MultiStoreCheckoutConfig getInstance];
    if ([msConfig isDataFetched] == false) {
        return nil;
    }
    
    UIView* view = [[UIView alloc] init];
    [view setBackgroundColor:[UIColor whiteColor]];
    [view.layer setBackgroundColor:[UIColor whiteColor].CGColor];
    [view setFrame: CGRectMake(self.view.frame.size.width * 0.01f, 0, self.view.frame.size.width * 0.98f, _defaultHeight)];
    self.wccmView = view;
    
    float posY = 0;
    
    
    //delivery type
    {
        
        DDView* ddView = [[DDView alloc] initWithDelegate:self
                                               parentView:self.view
                                             defaultValue:Localize(@"i_select")
                                              dataObjects:msConfig.deliveryTypeOptions
                                              dataStrings:msConfig.deliveryTypeOptions];
        
        CGRect ddFrame = ddView.frame;
        ddFrame.origin.y = posY;
        ddFrame.origin.x = 0;
        ddView.frame = ddFrame;
        [view addSubview:ddView];
        posY = CGRectGetMaxY(ddFrame);
        self.wccmDeliveryTypes = ddView;
        
        
        [ddView.labelSelection setText:msConfig.deliveryTypeLabel];
        self.wccmCowDeliveryTypes = msConfig.deliveryTypeField;
        self.wccmOptionDeliveryTypes = [ddView selectItemForString:msConfig.selectedDeliveryType];
    }
    
    //cluster destination
    {
        DDView* ddView = [[DDView alloc] initWithDelegate:self
                                               parentView:self.view
                                             defaultValue:Localize(@"i_select")
                                              dataObjects:msConfig.clusterDestinationsOptions
                                              dataStrings:msConfig.clusterDestinationsOptions];
        [ddView.labelSelection setText:msConfig.clusterDestinationsLabel];
        self.wccmCowClusterDestinations = msConfig.clusterDestinationsField;
        self.wccmOptionClusterDestinations = [ddView selectItemForString:msConfig.selectedClusterDestination];
        
        
        CGRect ddFrame = ddView.frame;
        ddFrame.origin.y = posY;
        ddFrame.origin.x = 0;
        ddView.frame = ddFrame;
        [view addSubview:ddView];
        self.wccmClusterDestinations = ddView;
        
        
        self.wccmClusterDestinations.hidden = true;
        if (self.wccmClusterDestinations.hidden == false) {
            posY = CGRectGetMaxY(ddFrame);
        }
        
        
        
    }
    //home destination
    {
        DDView* ddView = [[DDView alloc] initWithDelegate:self
                                               parentView:self.view
                                             defaultValue:Localize(@"i_select")
                                              dataObjects:msConfig.homeDestinationOptions
                                              dataStrings:msConfig.homeDestinationOptions];
        [ddView.labelSelection setText:msConfig.homeDestinationLabel];
        self.wccmCowHomeDestinations = msConfig.homeDestinationField;
        self.wccmOptionHomeDestinations = [ddView selectItemForString:msConfig.selectedHomeDestination];
        CGRect ddFrame = ddView.frame;
        ddFrame.origin.y = posY;
        ddFrame.origin.x = 0;
        ddView.frame = ddFrame;
        [view addSubview:ddView];
        posY = CGRectGetMaxY(ddFrame);
        self.wccmHomeDestinations = ddView;
    }
    //delivery days
    {
        DDView* ddView = [[DDView alloc] initWithDelegate:self
                                               parentView:self.view
                                             defaultValue:Localize(@"i_select")
                                              dataObjects:msConfig.deliveryDaysOptions
                                              dataStrings:msConfig.deliveryDaysOptions];
        self.wccmDeliveryDays = ddView;
        [ddView.labelSelection setText:msConfig.deliveryDaysLabel];
        self.wccmCowDeliveryDays = msConfig.deliveryDaysField;
        self.wccmOptionDeliveryDays = [ddView selectItemForString:msConfig.selectedDeliveryDay];
        
        CGRect ddFrame = ddView.frame;
        ddFrame.origin.y = posY;
        ddFrame.origin.x = 0;
        ddView.frame = ddFrame;
        [view addSubview:ddView];
        posY = CGRectGetMaxY(ddFrame);
        
    }
    //delivery time slot
    
    {
        MSCDeliverSlot* dSlot = [msConfig getDeliverySlotForDay:msConfig.selectedDeliveryDay];
        DDView* ddView = [[DDView alloc] initWithDelegate:self
                                               parentView:self.view
                                             defaultValue:Localize(@"i_select")
                                              dataObjects:dSlot.options
                                              dataStrings:dSlot.options];
        self.wccmDeliveryTimeSlots = ddView;
        [ddView.labelSelection setText:dSlot.label];
        self.wccmCowDeliveryTimeSlots = dSlot.field;
        self.wccmOptionDeliveryTimeSlots = @"";
        if ([dSlot.options count] == 1) {
            [self.wccmDeliveryTimeSlots selectItemForString:[dSlot.options objectAtIndex:0]];
            self.wccmOptionDeliveryTimeSlots = [dSlot.options objectAtIndex:0];
        }
        
        
        
        CGRect ddFrame = ddView.frame;
        ddFrame.origin.y = posY;
        ddFrame.origin.x = 0;
        ddView.frame = ddFrame;
        [view addSubview:ddView];
        posY = CGRectGetMaxY(ddFrame);
        
    }
    posY += self.view.frame.size.width * 0.01f;
    view.frame = CGRectMake(self.view.frame.size.width * 0.01f, 0, self.view.frame.size.width * 0.98f, posY);
    
    
    int index = 0;
    if (_topImage) {
        index = (int)[_viewsAdded indexOfObject:_topImage] + 1;
    }
    
    UIView* viewHeader = [self addHeaderView:Localize(@"delivery_details") isTransparant:false];
    [Utility showShadow:viewHeader];
    [_viewsAdded removeObject:viewHeader];
    [_viewsAdded insertObject:viewHeader atIndex:index];
    
    [_scrollView addSubview:view];
    [_viewsAdded insertObject:view atIndex:index+1];
    [view setTag:kTagForGlobalSpacing];
    
    [view addSubview:[self addBorder:view]];
    
    [self resetMainScrollView];
    return view;
}
- (void)reponseDDViewDelegate:(DDView *)sender
                clickedItemId:(int)clickedItemId
            clickedItemTitle:(NSString*)clickedItemTitle
            clickedItemObject:(id)clickedItemObject {
    RLOG(@"clickedItemTitle = %@", clickedItemTitle);
    MultiStoreCheckoutConfig* msConfig = [MultiStoreCheckoutConfig getInstance];
    if (sender == _wccmDeliveryTypes) {
        self.wccmOptionDeliveryTypes = clickedItemTitle;
        [UIView animateWithDuration:0.2f animations:^{
            if ([clickedItemTitle isEqualToString:msConfig.selectedClusterDestination]) {
                self.wccmClusterDestinations.hidden = false;
            } else {
                self.wccmClusterDestinations.hidden = true;
            }
            self.wccmView.layer.shadowOpacity = 0.0f;
            [self rearrangeWCCMView];
            [self resetMainScrollView];
        } completion:^(BOOL finished) {
            if (finished) {
                [Utility showShadow:self.wccmView];
            }
        }];
    }
    else if (sender == _wccmClusterDestinations) {
        self.wccmOptionClusterDestinations = clickedItemTitle;
    }
    else if (sender == _wccmHomeDestinations) {
        self.wccmOptionHomeDestinations = clickedItemTitle;
    }
    else if (sender == _wccmDeliveryDays) {
        MSCDeliverSlot* dSlot = [msConfig getDeliverySlotForDay:clickedItemTitle];
        [self.wccmDeliveryTimeSlots updateData:Localize(@"i_select") dataObjects:dSlot.options dataStrings:dSlot.options];
        [self.wccmDeliveryTimeSlots.labelSelection setText:dSlot.label];
        self.wccmOptionDeliveryDays = clickedItemTitle;
        self.wccmCowDeliveryTimeSlots = dSlot.field;
        self.wccmOptionDeliveryTimeSlots = @"";
        if ([dSlot.options count] == 1) {
            [self.wccmDeliveryTimeSlots selectItemForString:[dSlot.options objectAtIndex:0]];
            self.wccmOptionDeliveryTimeSlots = [dSlot.options objectAtIndex:0];
        }
    }
    else if (sender == _wccmDeliveryTimeSlots) {
        self.wccmOptionDeliveryTimeSlots = clickedItemTitle;
    }
}
- (void)rearrangeWCCMView {

    float posY = 0;
    CGRect rect;
    
    rect = self.wccmDeliveryTypes.frame;
    rect.origin.y = posY;
    self.wccmDeliveryTypes.frame = rect;
    posY = CGRectGetMaxY(self.wccmDeliveryTypes.frame);
    
    rect = self.wccmClusterDestinations.frame;
    rect.origin.y = posY;
    self.wccmClusterDestinations.frame = rect;
    if (self.wccmClusterDestinations.hidden == false) {
        posY = CGRectGetMaxY(self.wccmClusterDestinations.frame);
    }

    rect = self.wccmHomeDestinations.frame;
    rect.origin.y = posY;
    self.wccmHomeDestinations.frame = rect;
    posY = CGRectGetMaxY(self.wccmHomeDestinations.frame);
    
    rect = self.wccmDeliveryDays.frame;
    rect.origin.y = posY;
    self.wccmDeliveryDays.frame = rect;
    posY = CGRectGetMaxY(self.wccmDeliveryDays.frame);
    
    rect = self.wccmDeliveryTimeSlots.frame;
    rect.origin.y = posY;
    self.wccmDeliveryTimeSlots.frame = rect;
    posY = CGRectGetMaxY(self.wccmDeliveryTimeSlots.frame);
    
    posY += self.view.frame.size.width * 0.01f;
    self.wccmView.frame = CGRectMake(self.view.frame.size.width * 0.01f, 0, self.view.frame.size.width * 0.98f, posY);
}
- (void)openShippingAddressPopup:(Address*)address {
    
    if (_btnAddAddressShipping && _btnAddAddressShipping.hidden == false) {
        Address* addressOld = [[_btnAddAddressShipping layer] valueForKey:@"ADDRESS_OBJ"];
        if ([address._first_name isEqualToString:@""]) {
            address._first_name = addressOld._first_name;
        }
        if ([address._last_name isEqualToString:@""]) {
            address._last_name = addressOld._last_name;
        }
        if ([address._email isEqualToString:@""]) {
            address._email = addressOld._email;
        }
        if ([address._phone isEqualToString:@""]) {
            address._phone = addressOld._phone;
        }
        address._isShippingAddress = addressOld._isShippingAddress;
        address._isBillingAddress = addressOld._isBillingAddress;
        address._isAddressSaved = addressOld._isAddressSaved;
        
        [[_btnAddAddressShipping layer] setValue:address forKey:@"ADDRESS_OBJ"];
        [self addAddressClicked:_btnAddAddressShipping];
    } else if (_btnEditAddressShipping && _btnEditAddressShipping.hidden == false) {
        Address* addressOld = [[_btnEditAddressShipping layer] valueForKey:@"ADDRESS_OBJ"];
        if ([address._first_name isEqualToString:@""]) {
            address._first_name = addressOld._first_name;
        }
        if ([address._last_name isEqualToString:@""]) {
            address._last_name = addressOld._last_name;
        }
        if ([address._email isEqualToString:@""]) {
            address._email = addressOld._email;
        }
        if ([address._phone isEqualToString:@""]) {
            address._phone = addressOld._phone;
        }
        address._isShippingAddress = addressOld._isShippingAddress;
        address._isBillingAddress = addressOld._isBillingAddress;
        address._isAddressSaved = addressOld._isAddressSaved;
        
        [[_btnEditAddressShipping layer] setValue:address forKey:@"ADDRESS_OBJ"];
        [self changeAddressClicked:_btnEditAddressShipping];
    }
}
@end
