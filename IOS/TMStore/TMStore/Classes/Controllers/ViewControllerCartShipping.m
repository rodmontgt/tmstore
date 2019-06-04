//
//  ViewControllerCartShipping.m
//  eMobileApp
//
//  Created by Rishabh Jain on 25/11/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import "ViewControllerCartShipping.h"
#import "ViewControllerAddress.h"
#import "AppUser.h"
#import "Attribute.h"
#import "Order.h"
#import "DataManager.h"
#import "CommonInfo.h"
#import "ViewControllerOrderReceipt.h"
#import "ViewControllerCheckout.h"
#import "LoginFlow.h"
#import "ParseHelper.h"
#import "AppDelegate.h"
#import "UITextView+LocalizeConstrint.h"
#import "TM_Tax.h"
#import "CartMeta.h"
#import "MinOrderData.h"
#import "FeeData.h"
#import "DateTimeSlot.h"
#import "TimeSlot.h"
#import "AnalyticsHelper.h"
#import "TM_CheckoutAddon.h"
#import "MultiStoreCheckoutConfig.h"

#define ENABLE_PAYSTACK_IN_TMSTORE 1
#define ENABLE_VCS_PAY_IN_TMSTORE 1

#define HACK_FEE_DATA 1

#if ENABLE_PAYSTACK_IN_TMSTORE
#import "PaystackViewController.h"
#import <Paystack/Paystack.h>
#endif

#if ENABLE_VCS_PAY_IN_TMSTORE
#import "VCSPayViewController.h"
#endif
#define hack_time_slot_fee @"hack_time_slot_fee"
static int kTagForGlobalSpacing = 0;
static int kTagForNoSpacing = -1;
static BOOL isCurrencySymbolAtLast = true;
@interface ViewControllerCartShipping () {
    NSMutableArray* _viewsAdded;
    UIButton *customBackButton;
}
//@property (nonatomic, strong) CNPPopupController *popupControllerOTP;

@property (nonatomic, strong) CNPPopupController *popupOTPAsk;
@property (nonatomic, strong) CNPPopupController *popupOTPUpdate;
@property (nonatomic, strong) CNPPopupController *popupOTPVerify;
@end


@implementation ViewControllerCartShipping

- (void)viewDidLoad {
    [super viewDidLoad];
    _selectedShippingMethodId = @"";
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
    
    
    
    [self initVariables];
    //    [[[[DataManager sharedManager] tmDataDoctor] tmMulticastDelegate] addDelegate:self];
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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textDidChange:)
                                                 name: UITextFieldTextDidChangeNotification
                                               object:nil];
    [self loadAllViews];
    [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
    [[Utility sharedManager] stopGrayLoadingBar];
    
    

}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextFieldTextDidChangeNotification
                                                  object:nil];
}
-(void)viewDidAppear:(BOOL)animated{
#if ENABLE_FIREBASE_TAG_MANAGER
    [[AnalyticsHelper sharedInstance] registerVisitScreenEvent:@"CartShipping Screen"];
#endif
}
- (void)textDidChange:(NSNotification *)notification {
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
    CGRect rect = self.view.frame;
    [UIView setAnimationDuration:_duration];
    [UIView setAnimationCurve:_curve];
    if (movedUp) {
        if ([[MyDevice sharedManager] isIpad]) {
            rect.origin.y = -_keyboardHeight + MAX(75, [[Utility sharedManager] bottomBarHeight]);
        } else {
            rect.origin.y = -_keyboardHeight + MAX(75, [[Utility sharedManager] bottomBarHeight]);
        }
    }
    else {
        rect.origin.y = 0;
    }
    self.view.frame = rect;
    [UIView commitAnimations];
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
    ViewControllerMain* mainVC = [ViewControllerMain getInstance];
    [mainVC resetPreviousState];
}
- (void)initVariables {
    _viewsAdded = [[NSMutableArray alloc] init];
    _chkBoxPayment = [[NSMutableArray alloc] init];
//    _chkBoxShipping = [[NSMutableArray alloc] init];
    _chkBoxShippingOuterArray = [[NSMutableArray alloc] init];
    _selectedPaymentGateway = nil;
    _selectedShippingMethod = [[NSMutableArray alloc] init];
    Addons* addons = [Addons sharedManager];
    if (addons.enable_otp_in_cod_payment) {
        _screen_current_state = SCREEN_STATE_VERIFY_MOBILE_OTP;
    } else {
        _screen_current_state = SCREEN_STATE_ENTER;
    }
    _selected_time_slot = nil;
    _selected_date_time_slot = nil;
    _availableTimeSlots = nil;
    _availableDateTimeSlots = nil;
    _selectedShippingMethodId = @"";
}
- (void)loadAllViews {
    [_chkBoxPayment removeAllObjects];
//    [_chkBoxShipping removeAllObjects];
    for (NSMutableArray* _chkBoxShipping in _chkBoxShippingOuterArray) {
        [_chkBoxShipping removeAllObjects];
    }
    [_chkBoxShippingOuterArray removeAllObjects];
    _selectedPaymentGateway = nil;
    _selectedShippingMethod = [[NSMutableArray alloc] init];
    
    _selected_time_slot = nil;
    _selected_date_time_slot = nil;
    _availableTimeSlots = nil;
    _availableDateTimeSlots = nil;
    _selectedShippingMethodId = @"";
    _taxView = nil;
    _taxViewHeader = nil;
    _feeView = nil;
    _feeViewHeader = nil;
    _viewGrandTotal = nil;
    for (UIView* view in _viewsAdded) {
        [view removeFromSuperview];
    }
    [_viewsAdded removeAllObjects];
    [_labelViewHeading setText:Localize(@"checkout_title")];
    [self createProceedToPay1];
    
    UIView* view;
    
    if ([[Addons sharedManager] hide_price]) {
    } else {
        view = [self addHeaderView:Localize(@"checkout_info") isTransparant:false];
        [Utility showShadow:view];
        view = [self createCartInfoView];
        [Utility showShadow:view];
    }
    
    
    
    [self addDeliveryCostToFeeLine];
    
    //this hack is only for multi store checkout for safalana multi store, here no free for instore delivery type, this code is based on android code
    if ([[FeeData getAllFeeData] count] > 0) {
        MultiStoreCheckoutConfig* msConfig = [MultiStoreCheckoutConfig getInstance];
        if ([[Addons sharedManager] enable_multi_store_checkout] && [msConfig isDataFetched]) {
            NSString* msDeliveryTypeSelected = [[msConfig getMetaData] valueForKey:msConfig.deliveryTypeField];
            if (msDeliveryTypeSelected && [msConfig.deliveryTypeOptions count] > 2) {
                if ([msDeliveryTypeSelected isEqualToString:[msConfig.deliveryTypeOptions objectAtIndex:2]]) {
                    FeeData* feeDataNeedToRemove = nil;
                    for (FeeData* feeData in [FeeData getAllFeeData]) {
                        if(feeData.plugin_title != nil && [feeData.plugin_title isEqualToString:@"woocommerce-checkout-manager"]) {
                            feeDataNeedToRemove = feeData;
                        }
                    }
                    if (feeDataNeedToRemove) {
                        [[FeeData getAllFeeData] removeObject:feeDataNeedToRemove];
                    }
                }
            }
        }
    }
    
    
    if ([[FeeData getAllFeeData] count] > 0 && [self getFeesTotal] > 0) {
        view = [self addHeaderView:Localize(@"Fee Info") isTransparant:false];
        [Utility showShadow:view];
        _feeViewHeader = view;
        _feeViewHeaderHeight = view.frame.size.height;
        view = [self createFeeDataView];
        [Utility showShadow:view];
    } else if ([[FeeData getAllFeeData] count] == 1) {
        FeeData* feeData = [[FeeData getAllFeeData] objectAtIndex:0];
        if([feeData.plugin_title isEqualToString:hack_time_slot_fee]) {
            view = [self addHeaderView:Localize(@"Fee Info") isTransparant:false];
            [Utility showShadow:view];
            _feeViewHeader = view;
            _feeViewHeaderHeight = view.frame.size.height;
            view = [self createFeeDataView];
            [Utility showShadow:view];
        }
    }
    
    
    if ([[[CartMeta sharedInstance] getAppliedCoupons] count] > 0) {
        view = [self addHeaderView:Localize(@"Applied Coupons") isTransparant:false];
        [Utility showShadow:view];
        view = [self createAppliedCouponView];
        [Utility showShadow:view];
    }
    
    NSString* shippingErrorMessage = @"";
    if ([[Addons sharedManager] hide_shipping_info] == false) {
        view = [self addHeaderView:Localize(@"i_shipping_info") isTransparant:false];
        [Utility showShadow:view];
        Addons* addons = [Addons sharedManager];
        if (addons.check_min_order_data) {
            MinOrderData* minOrder = [MinOrderData sharedInstance];
            float grandTotalWithoutShipping = [self calculateGrandTotalWithoutShipping];
            if (grandTotalWithoutShipping < minOrder.minOrderAmount) {
                NSString *myString = minOrder.minOrderMessage;
                NSString *original = @"%s";
                NSString *replacement1 = [NSString stringWithFormat:@"%@",[[Utility sharedManager] convertToString:minOrder.minOrderAmount isCurrency:true symbolAtLast:false]];
                NSRange rOriginal1 = [myString rangeOfString:original];
                if (NSNotFound != rOriginal1.location) {
                    myString = [myString stringByReplacingCharactersInRange:rOriginal1 withString:replacement1];
                }
                NSString *replacement2 = [NSString stringWithFormat:@"%@",[[Utility sharedManager] convertToString:grandTotalWithoutShipping isCurrency:true symbolAtLast:false]];
                NSRange rOriginal2 = [myString rangeOfString:original];
                if (NSNotFound != rOriginal2.location) {
                    myString = [myString stringByReplacingCharactersInRange:rOriginal2 withString:replacement2];
                }
                minOrder.minOrderMessage = myString;
                shippingErrorMessage = minOrder.minOrderMessage;
            }
        }
        if ([shippingErrorMessage isEqualToString:@""]) {
            TMShippingSDK* tmShippingSDK = [[DataManager sharedManager] tmShippingSDK];
            if(!(tmShippingSDK.shippingEnable && tmShippingSDK.shippingMethods && [tmShippingSDK.shippingMethods count] > 0)) {
                shippingErrorMessage = Localize(@"no_shipping_method_found");
            }
        }
    }
    BOOL is_prddEnable = false;
    for (Cart* c in [Cart getAll]) {
        if(c.prddDay || c.prddTime) {
            is_prddEnable = true;
        }
    }
    
    if (is_prddEnable) {
        _shippingBunches = [Cart createBunches];
        RLOG(@"_shippingBunches = %@", _shippingBunches);
        NSArray* bunchesKeys = [_shippingBunches allKeys];
        for (int i = 0; i < [bunchesKeys count]; i++) {
            NSMutableArray* _chkBoxShipping = [[NSMutableArray alloc] init];
            [_chkBoxShippingOuterArray addObject:_chkBoxShipping];
        }
    }
    
    if (is_prddEnable == false) {
        NSMutableArray* _chkBoxShipping = [[NSMutableArray alloc] init];
        [_chkBoxShippingOuterArray addObject:_chkBoxShipping];
    }
    
    if ([[Addons sharedManager] hide_shipping_info] == false) {
        int bunchId = 0;
        for (NSMutableArray* _chkBoxShipping in _chkBoxShippingOuterArray) {
            view = [self createShippingOptionView:shippingErrorMessage _chkBoxShipping:_chkBoxShipping bunchId:is_prddEnable ? bunchId : -1];
            [Utility showShadow:view];
            bunchId++;
        }
    }
    
    if ([[TM_CheckoutAddon getAllCheckoutAddons] count] > 0) {
        view = [self createCheckoutAddonsView];
        [Utility showShadow:view];
    }
    
    if (_taxView != nil) {
        [_viewsAdded removeObject:_taxViewHeader];
        [_viewsAdded removeObject:_taxView];
        [_viewsAdded addObject:_taxViewHeader];
        [_viewsAdded addObject:_taxView];
    }
    
    
    if ([[Addons sharedManager] show_pickup_location] && [[TM_PickupLocation getAllPickupLocations] count] > 0) {
        view = [self addHeaderView:Localize(@"title_pickup_location") isTransparant:false];
        [Utility showShadow:view];
        view = [self createPickupSelectionView];
        [Utility showShadow:view];
    }
    
    [self calculateGrandTotal];
    
    view = [self createGrandTotalView];
    [Utility showShadow:view];
    _viewGrandTotal = view;
    
    view = [self addHeaderView:Localize(@"available_payment_options") isTransparant:false];
    [Utility showShadow:view];
    view = [self createPaymentOptionView];
    [Utility showShadow:view];
    
    
#if ENABLE_DELIVERY_SLOT_COPIA
    if ([[DateTimeSlot getAllDateTimeSlots:_selectedShippingMethodId] count] > 0) {
        view = [self addHeaderView:Localize(@"title_available_time_slots") isTransparant:false];
        [Utility showShadow:view];
        view = [self createDeliverySlotView];
        [Utility showShadow:view];
    }
#endif
    
#if ENABLE_LOCAL_PICKUP_TIME_SELECT
    if ([[TimeSlot getAllTimeSlots] count] > 0) {
        view = [self addHeaderView:Localize(@"title_available_time_slots") isTransparant:false];
        [Utility showShadow:view];
        view = [self createDeliverySlotView];
        [Utility showShadow:view];
    }
#endif
    

    
#if ENABLE_ORDER_NOTE
    if ([[Addons sharedManager] orderNote] && [[[Addons sharedManager] orderNote] note_enabled]) {
        view = [self addHeaderView:Localize(@"order_note") isTransparant:false];
        [Utility showShadow:view];
        _textView = [[UITextView alloc] init];
        view = [self createNotesView:_textView];
        [Utility showShadow:view];
    }
#endif
    
    
    if ([TM_CheckoutAddon getOrderScreenNote] && ![[TM_CheckoutAddon getOrderScreenNote] isEqualToString:@""]) {
        view = [self createOrderScreenNote];
        [Utility showShadow:view];
    }
    [self createProceedToPay2];
    [self resetMainScrollView];
}
- (NSMutableArray*)calculateAndArrangeApplicableTaxes {
    if(_appliedTaxes == nil) {
        _appliedTaxes = [[NSMutableArray alloc] init];
    }
    [_appliedTaxes removeAllObjects];
    
    
    
    
    
    
    
    return _appliedTaxes;
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
    [_topImage setTag:kTagForGlobalSpacing];
    UIView* viewDummy2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    [_scrollView addSubview:viewDummy2];
    [_viewsAdded addObject:viewDummy2];
    [viewDummy2 setTag:kTagForGlobalSpacing];
}
#pragma mark createOrderScreenNote
- (UIView*)createOrderScreenNote {
    UILabel* labelTemp= [[UILabel alloc] init];
    [labelTemp setUIFont:kUIFontType24 isBold:false];
    UIView* view = [[UIView alloc] init];
    [view setFrame:CGRectMake(self.view.frame.size.width * 0.01f, 0, self.view.frame.size.width * 0.98f, [[labelTemp font] lineHeight] * 10)];
    float leftItemsPosX = self.view.frame.size.width * 0.05f;
    float itemPosY = self.view.frame.size.width * 0.04f;
    float width = view.frame.size.width * .90f;
    [view setBackgroundColor:[UIColor whiteColor]];
    [_scrollView addSubview:view];
    [_viewsAdded addObject:view];
    [view setTag:kTagForGlobalSpacing];
    
    UILabel* labelSelect = [[UILabel alloc] initWithFrame:CGRectMake(leftItemsPosX, itemPosY, width, 0)];
    [labelSelect setUIFont:kUIFontType14 isBold:true];
    [labelSelect setTextColor:[Utility getUIColor:kUIColorFontDark]];
    labelSelect.textAlignment = NSTextAlignmentLeft;
    labelSelect.numberOfLines = 0;
    [labelSelect setLineBreakMode:NSLineBreakByWordWrapping];
    NSString *selectyoursize = [TM_CheckoutAddon getOrderScreenNote];
    [labelSelect setText:[NSString stringWithFormat:@"%@",selectyoursize]];
    [labelSelect sizeToFitUI];
    [view addSubview:labelSelect];
    itemPosY += labelSelect.frame.size.height;
    itemPosY += self.view.frame.size.width * 0.04f;
    [view setFrame:CGRectMake(self.view.frame.size.width * 0.01f, 0, self.view.frame.size.width * 0.98f, itemPosY)];
    return view;
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
    [_btnProceed setTitle:Localize(@"proceed") forState:UIControlStateNormal];
    [_btnProceed setTitleColor:[Utility getUIColor:kUIColorBuyButtonFont] forState:UIControlStateNormal];
    [_btnProceed addTarget:self action:@selector(proceedToPay:) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:_btnProceed];
    [_viewsAdded addObject:_btnProceed];
    [_btnProceed setTag:kTagForGlobalSpacing];
}
- (void)createBlankOrder {
    _blankOrder = nil;
    
    for (NSMutableArray* _chkBoxShipping in _chkBoxShippingOuterArray) {
        int shipping_methods_count = (int) [_chkBoxShipping count];
        TMShippingSDK* tmShippingSDK = [[DataManager sharedManager] tmShippingSDK];
        if(tmShippingSDK.shippingEnable && tmShippingSDK.shippingMethods) {
            shipping_methods_count = (int)[tmShippingSDK.shippingMethods count];
        }
        if (tmShippingSDK.shippingEnable && shipping_methods_count == 0) {
            return;
        }
    }

    
    int payment_methods_count = (int) [_chkBoxPayment count];
    if (payment_methods_count == 0) {
        return;
    }
    if (_textView) {
        [Cart setOrderNoteOrder:_textView.text];
    }
    
    [[[DataManager sharedManager] tmDataDoctor] createBlankOrder:_selectedShippingMethod paymentGateway:_selectedPaymentGateway success:^(id data) {
        //update tax view here
        _blankOrder = (Order*)data;
    } failure:^(NSString *error) {
        if ([error isEqualToString:@"failure"]) {
            
        } else if([error isEqualToString:@"retry"]) {
        
        }
    }];
}
- (void)addDeliveryCostToFeeLine {
    if ([[[Addons sharedManager] deliverySlotsCopiaPlugin] isEnabled]) {
        BOOL isPreviouslyAdded = false;
        for (FeeData* feeData in [FeeData getAllFeeData]) {
            if([feeData.plugin_title isEqualToString:hack_time_slot_fee]){
                feeData.cost = 0.0f;
                isPreviouslyAdded = true;
            }
        }
        if (isPreviouslyAdded == false) {
            FeeData* feeData = [[FeeData alloc] init];
            feeData.plugin_title = hack_time_slot_fee;
            feeData.cost = [_selected_time_slot.slotCost floatValue];
            feeData.label = @"Time Slot Fee";
        }
    }
}
- (void)updateDeliveryCostToFeeLine {
    if ([[[Addons sharedManager] deliverySlotsCopiaPlugin] isEnabled]) {
        for (FeeData* feeData in [FeeData getAllFeeData]) {
            if([feeData.plugin_title isEqualToString:hack_time_slot_fee]){
                feeData.cost = [_selected_time_slot.slotCost floatValue];
                break;
            }
        }
        [self createFeeDataView];
        if (_feeView) {
            [Utility showShadow:_feeView];
        }
        
#if HACK_FEE_DATA
        float totalFee = 0.0f;
        for (FeeData* feeData in [FeeData getAllFeeData]) {
            totalFee += feeData.cost;
        }
        if (totalFee <= 0) {
            if (_feeView) {
                CGRect feeViewRect = _feeView.frame;
                feeViewRect.size.height = 0;
                [_feeView setFrame:feeViewRect];
                _feeView.layer.shadowOpacity = 0.0f;
            }
            if (_feeViewHeader) {
                CGRect feeViewHeaderRect = _feeViewHeader.frame;
                feeViewHeaderRect.size.height = 0;
                [_feeViewHeader setFrame:feeViewHeaderRect];
                _feeViewHeader.layer.shadowOpacity = 0.0f;
            }
            [self resetMainScrollView];
        } else {
            if (_feeViewHeader) {
                CGRect feeViewHeaderRect = _feeViewHeader.frame;
                feeViewHeaderRect.size.height = _feeViewHeaderHeight;
                [_feeViewHeader setFrame:feeViewHeaderRect];
                [Utility showShadow:_feeViewHeader];
            }
        }
#endif
        
        
        NSString* stringGrandAmount = [NSString stringWithFormat:@"%@",[[Utility sharedManager] convertToString:[self calculateGrandTotal] isCurrency:true symbolAtLast:isCurrencySymbolAtLast]];
        [_labelGrandAmount setText:stringGrandAmount];
    }
}
- (void)refreshBlankOrder {
    return;
}
- (void)verifyMobileNumber {
    Addons* addons = [Addons sharedManager];
    
    if (addons.enable_otp_in_cod_payment && _selectedPaymentGateway && [[_selectedPaymentGateway.paymentId lowercaseString] isEqualToString:@"cod"]) {
        
    }
}
- (void)proceedToPay:(UIButton*)button{
    
#if TEST_BYPASS_ORDER_CREATION_DIRECT_PAYMENT
    [self proceedPayment];
    return;
#endif
    
    
    switch (_screen_current_state) {
        case SCREEN_STATE_VERIFY_MOBILE_OTP: {
            if (_selectedPaymentGateway && [[_selectedPaymentGateway.paymentId lowercaseString] isEqualToString:@"cod"]) {
                AppUser* appUser = [AppUser sharedManager];
                _registerMobileNumber = appUser._billing_address._phone;
//                [self createOTPVerificationView];
//                [self resendOTP];
                [self createOTPScreenAsk];
            } else {
                _screen_current_state = SCREEN_STATE_ENTER;
                [self proceedToPay:button];
            }
        } break;
        case SCREEN_STATE_ENTER:
        {
            _blankOrder = nil;
            int payment_methods_count = (int) [_chkBoxPayment count];
            if (payment_methods_count > 0 && _selectedPaymentGateway == nil) {
                //alert select shipping methods
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:Localize(@"select_payment_method") delegate:nil cancelButtonTitle:Localize(@"i_ok") otherButtonTitles:nil];
                [alertView show];
                return;
            }
            if (payment_methods_count == 0) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Localize(@"sorry") message:Localize(@"no_payments_available") delegate:nil cancelButtonTitle:Localize(@"i_ok") otherButtonTitles:nil];
                [alertView show];
                return;
            }
            Addons* addons = [Addons sharedManager];
            
            
            if (addons.check_min_order_data) {
                MinOrderData* minOrder = [MinOrderData sharedInstance];
                float grandTotalWithoutShipping = [self calculateGrandTotalWithoutShipping];
                if (grandTotalWithoutShipping < minOrder.minOrderAmount) {
                    //alert select shipping methods
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:[[MinOrderData sharedInstance] minOrderMessage] delegate:nil cancelButtonTitle:Localize(@"i_ok") otherButtonTitles:nil];
                    [alertView show];
                    if (_labelErrorMsgShippingInfo) {
                        _labelErrorMsgShippingInfo.transform = CGAffineTransformMakeTranslation(20, 0);
                        [UIView animateWithDuration:0.4f delay:0.0 usingSpringWithDamping:0.2f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                            _labelErrorMsgShippingInfo.transform = CGAffineTransformIdentity;
                        } completion:nil];
                    }
                    return;
                }
            }
            
            
            
            int i = 0;
            for (NSMutableArray* _chkBoxShipping in _chkBoxShippingOuterArray) {
                int shipping_methods_count = (int) [_chkBoxShipping count];
                TMShippingSDK* tmShippingSDK = [[DataManager sharedManager] tmShippingSDK];
                if(tmShippingSDK.shippingEnable && tmShippingSDK.shippingMethods) {
                    shipping_methods_count = (int)[tmShippingSDK.shippingMethods count];
                }
                
                if (tmShippingSDK.shippingEnable) {
                    if (shipping_methods_count == 0) {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Localize(@"sorry") message:Localize(@"no_shipping_method_found") delegate:nil cancelButtonTitle:Localize(@"i_ok") otherButtonTitles:nil];
                        [alertView show];
                        return;
                    } else {
                        if ([_selectedShippingMethod count] == 0) {
                            //alert select shipping methods
                            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:Localize(@"select_shipping") delegate:nil cancelButtonTitle:Localize(@"i_ok") otherButtonTitles:nil];
                            [alertView show];
                            return;
                        }
                    }
                }
                
                /*
                //old code
                if (shipping_methods_count > 0 && (_selectedShippingMethod == nil  || [_selectedShippingMethod count] == 0)) {
                    if (addons.check_min_order_data && shipping_methods_count != (int)[_chkBoxShipping count]) {
                        //alert select shipping methods
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:[[MinOrderData sharedInstance] minOrderMessage] delegate:nil cancelButtonTitle:Localize(@"i_ok") otherButtonTitles:nil];
                        [alertView show];
                        if (_labelErrorMsgShippingInfo) {
                            _labelErrorMsgShippingInfo.transform = CGAffineTransformMakeTranslation(20, 0);
                            [UIView animateWithDuration:0.4f delay:0.0 usingSpringWithDamping:0.2f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                                _labelErrorMsgShippingInfo.transform = CGAffineTransformIdentity;
                            } completion:nil];
                        }
                    } else {
                        //alert select shipping methods
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:Localize(@"select_shipping") delegate:nil cancelButtonTitle:Localize(@"i_ok") otherButtonTitles:nil];
                        [alertView show];
                    }
                    return;
                }
                */
                i++;
            }
            if (addons.deliverySlotsCopiaPlugin.isEnabled && [[DateTimeSlot getAllDateTimeSlots:_selectedShippingMethodId] count] > 0 && (self.selected_date_time_slot == nil || self.selected_time_slot == nil)) {
                if (self.selected_date_time_slot == nil) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Localize(@"sorry") message:Localize(@"select_delivery_date") delegate:nil cancelButtonTitle:Localize(@"i_ok") otherButtonTitles:nil];
                    [alertView show];
                } else {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Localize(@"sorry") message:Localize(@"select_delivery_time") delegate:nil cancelButtonTitle:Localize(@"i_ok") otherButtonTitles:nil];
                    [alertView show];
                }
                return;
            }
            if (addons.localPickupTimeSelectPlugin.isEnabled && [[TimeSlot getAllTimeSlots] count] > 0 &&  self.selected_time_slot == nil) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Localize(@"sorry") message:Localize(@"select_time_slot") delegate:nil cancelButtonTitle:Localize(@"i_ok") otherButtonTitles:nil];
                [alertView show];
                return;
            }
//            if (_selectedPaymentGateway) {
//                RLOG(@"_selectedPaymentGateway = %@", _selectedPaymentGateway);
//            }
//            if (_selectedShippingMethod) {
//                RLOG(@"_selectedShippingMethod = %@", _selectedShippingMethod);
//            }
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(blankOrderSuccess:) name:@"BLANK_ORDER_SUCCESS" object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(blankOrderFailed:) name:@"BLANK_ORDER_FAILURE" object:nil];
            
            if (_textView) {
                [Cart setOrderNoteOrder:_textView.text];
            }
            
            [[[DataManager sharedManager] tmDataDoctor] createBlankOrder:_selectedShippingMethod paymentGateway:_selectedPaymentGateway];
            
            
        } break;
        case SCREEN_STATE_CREATE_BLANK_ORDER_DONE:
            [self bookDeliverySlots];
            break;
        case SCREEN_STATE_DELIVERY_SLOT_BOOKED:
            [self postOrderShippingDataPRDD];
            break;
        case SCREEN_STATE_PRODUCT_DELIVERY_SLOT_BOOKED:
            [self postMultistoreCheckoutMagagerData];
            break;
        case SCREEN_STATE_MULTISTORE_CHECKOUT_MANAGER:
            [self proceedPayment];
            break;
        case SCREEN_STATE_PAYMENT_DONE:
            [self paymentCompletionWithSuccess:nil];
            break;
        case SCREEN_STATE_UPDATE_ORDER_DONE:
            [self updateOrderSuccess:nil];
            break;
        case SCREEN_STATE_EXIT:
            
            break;
            
        default:
            break;
    }
    
    
    
    return;
    
    
    //here open webview for further progress..
    
    //    [self orderPurchasedSuccessful];
    
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
    ViewControllerCheckout* vcCheckout = (ViewControllerCheckout*)[[Utility sharedManager] pushScreenWithoutAnimation:mainVC.vcCenterTop type:PUSH_SCREEN_TYPE_CHECKOUT];
    [vcCheckout loadLoginView];
}
- (void)postMultistoreCheckoutMagagerData {
    MultiStoreCheckoutConfig* msConfig = [MultiStoreCheckoutConfig getInstance];
    if ([[Addons sharedManager] enable_multi_store_checkout] && [msConfig isDataFetched]) {
        [[[DataManager sharedManager] tmDataDoctor] setWCCMDataForOrderId:_blankOrder._id metaData:[msConfig getMetaData] success:^(id data) {
            //move to next step
            _screen_current_state = SCREEN_STATE_MULTISTORE_CHECKOUT_MANAGER;
            [self proceedPayment];
        } failure:^(NSString *error) {
            [self postMultistoreCheckoutMagagerData];
        }];
    } else {
        //move to next step
        _screen_current_state = SCREEN_STATE_MULTISTORE_CHECKOUT_MANAGER;
        [self proceedPayment];
    }
}
- (void)postOrderShippingDataPRDD {
    if (_shippingBunches) {
        NSArray* bunchesKeys = [_shippingBunches allKeys];
        for (int i = 0; i < [bunchesKeys count]; i++) {
            NSDictionary* dict = [_shippingBunches objectForKey:[NSNumber numberWithInt:i]];
            if (_selectedShippingMethod && [_selectedShippingMethod count] == [bunchesKeys count]) {
                TMShipping* shippingMethod = (TMShipping*)[_selectedShippingMethod objectAtIndex:i];
                [dict setValue:shippingMethod.shippingMethodId forKey:@"method_id"];
                [dict setValue:shippingMethod.shippingLabel forKey:@"method_title"];
//                [_shippingBunches setValue:dict forKey:[NSString stringWithFormat:@"%d", i]];
            }
        }
        [[[DataManager sharedManager] tmDataDoctor] postOrderShippingDataPRDD:_blankOrder._id shippingBunches:_shippingBunches success:^(id data) {
            RLOG(@"data:%@", data);
            _screen_current_state = SCREEN_STATE_PRODUCT_DELIVERY_SLOT_BOOKED;
            [self postMultistoreCheckoutMagagerData];
        } failure:^(NSString *error) {
            [self postOrderShippingDataPRDD];
        }];
    }
    else {
        //move to next step
        _screen_current_state = SCREEN_STATE_PRODUCT_DELIVERY_SLOT_BOOKED;
        [self postMultistoreCheckoutMagagerData];
    }
}
- (void)bookDeliverySlots {
//#if TEST_ORDER_OR_PAYMENT
//    _screen_current_state = SCREEN_STATE_DELIVERY_SLOT_BOOKED;
//    [self postOrderShippingDataPRDD];
//    return;
//#endif
    if (self.selected_date_time_slot || self.selected_time_slot) {
        if (self.selected_date_time_slot) {
            [[[DataManager sharedManager] tmDataDoctor] postDeliverySlotsThroughPlugin:_blankOrder._id dateTimeSlot:self.selected_date_time_slot timeSlot:self.selected_time_slot success:^{
                
                _blankOrder.deliveryDateString = [self.selected_date_time_slot getDateSlot];
                _blankOrder.deliveryTimeString = self.selected_time_slot.slotTitle;
                //move to next step
                _screen_current_state = SCREEN_STATE_DELIVERY_SLOT_BOOKED;
                [self postOrderShippingDataPRDD];
            } failure:^{
                [self bookDeliverySlots];
            }];
        } else {
            [[[DataManager sharedManager] tmDataDoctor] postTimeSlotsThroughPlugin:_blankOrder._id timeSlot:self.selected_time_slot success:^{
                _blankOrder.deliveryTimeString = self.selected_time_slot.slotTitle;
                //move to next step
                _screen_current_state = SCREEN_STATE_DELIVERY_SLOT_BOOKED;
                [self postOrderShippingDataPRDD];
            } failure:^{
                [self bookDeliverySlots];
            }];
        }
    } else {
        //move to next step
         _screen_current_state = SCREEN_STATE_DELIVERY_SLOT_BOOKED;
        [self postOrderShippingDataPRDD];
    }
}
- (void)proceedPayment {
#if TEST_BYPASS_ORDER_CREATION_DIRECT_PAYMENT
    float orderTotalAmount = MINIMUM_PAYMENT_AMOUNT;
#else
    float orderTotalAmount = [_blankOrder._total floatValue];
#endif
    
#if TEST_MINIMUM_PAYMENT
    orderTotalAmount = MINIMUM_PAYMENT_AMOUNT;
#endif
    
    
    BOOL payThroughWebsite = false;
    if (
        [_selectedPaymentGateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_COD]] ||
        [_selectedPaymentGateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_DBT]] ||
        [_selectedPaymentGateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_CHEQUE]] ||
        [_selectedPaymentGateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_JETPACK1]] ||
        [_selectedPaymentGateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_JETPACK2]] ||
        [_selectedPaymentGateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_JETPACK3]]){
    }
    else if(
            [_selectedPaymentGateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_PAYU_IN]] ||
            [_selectedPaymentGateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_PAYU_INDIA]]) {
        
        AppUser* user = [AppUser sharedManager];
        PayuConfig* config = [PayuConfig sharedManager];
        config.paymentPageTitle = Localize(@"make_a_payment");
        config.backButtonTitle = [NSString stringWithFormat:@"< %@", Localize(@"i_back")];
        config.infoTotalAmount = orderTotalAmount;
        config.infoPhone = [NSString stringWithFormat:@"%@", user._billing_address._phone];
        config.infoName = [NSString stringWithFormat:@"%@", user._billing_address._first_name];
        config.infoEmail = [NSString stringWithFormat:@"%@", user._email];
    }
    else if ([_selectedPaymentGateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_PAYPAL]]){
        PayPalConfig* config = [PayPalConfig sharedManager];
        config.paymentPageTitle = Localize(@"make_a_payment");
        config.backButtonTitle = [NSString stringWithFormat:@"< %@", Localize(@"i_back")];
        AppUser* user = [AppUser sharedManager];
        config.infoCountry = [NSString stringWithFormat:@"%@", user._billing_address._countryId];
        config.infoCurrency = [NSString stringWithFormat:@"%@", [CommonInfo sharedManager]->_currency];
        config.infoDescription = Localize(@"Total Amount");
        config.infoTotalAmount = orderTotalAmount;
    }
    else if ([_selectedPaymentGateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_APPLE_PAY_VIA_STRIPE]]){
        ApplePayViaStripeConfig* config = [ApplePayViaStripeConfig sharedManager];
        config.paymentPageTitle = Localize(@"make_a_payment");
        config.backButtonTitle = [NSString stringWithFormat:@"< %@", Localize(@"i_back")];
        AppUser* user = [AppUser sharedManager];
        config.infoCountry = [NSString stringWithFormat:@"%@", user._billing_address._countryId];
        config.infoCurrency = [NSString stringWithFormat:@"%@", [CommonInfo sharedManager]->_currency];
        if ([Localize(@"apple_pay_app_name") isEqualToString:@"default_value"]) {
            NSString* stringAppDisplayName = Localize(@"app_display_name");
            if ([stringAppDisplayName isEqualToString:@""] || [stringAppDisplayName isEqualToString:@"app_display_name"]) {
                stringAppDisplayName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
            }
            NSString* appName = stringAppDisplayName;
            config.infoDescription = appName;
        } else {
            config.infoDescription = Localize(@"apple_pay_app_name");
        }
        config.infoTotalAmount = orderTotalAmount;
    }
    else if ([_selectedPaymentGateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_STRIPE]]){
        StripeConfig* config = [StripeConfig sharedManager];
        config.paymentPageTitle = Localize(@"make_a_payment");
        config.backButtonTitle = [NSString stringWithFormat:@"< %@", Localize(@"i_back")];
        config.pp_card_holder_name_hint = Localize(@"hint_card_holder_name");
        config.pp_card_number_hint = Localize(@"hint_card_number");
        config.pp_card_expiry_date_hint = Localize(@"hint_card_expiry_date");
        config.pp_card_cvv_hint = Localize(@"hint_card_cvv");
        config.pp_card_zipcode_hint = Localize(@"hint_card_zip");
        config.pp_card_holder_name = Localize(@"title_card_holder_name");
        config.pp_card_number = Localize(@"title_card_number");
        config.pp_card_expiry_date = Localize(@"title_card_expiry_date");
        config.pp_card_cvv = Localize(@"title_card_cvv");
        config.pp_card_zipcode = Localize(@"title_card_zip");
        config.pp_pay_button_title = Localize(@"title_pay");
        config.pp_invalid_details = Localize(@"error_check_card_details");
        config.pp_all_fields_are_mendatory = Localize(@"all_fields_are_mendatory");
        config.button_ok_title = Localize(@"i_ok");
        
        config.infoLStrAddCard = Localize(@"add_new_card");
        config.infoLStrSavedCard = Localize(@"saved_cards");
        config.infoLStrTotalAmount = Localize(@"title_total_amount");
        
        AppUser* user = [AppUser sharedManager];
        config.infoCountry = [NSString stringWithFormat:@"%@", user._billing_address._countryId];
        config.infoCurrency = [NSString stringWithFormat:@"%@", [CommonInfo sharedManager]->_currency];
        config.infoDescription = Localize(@"Total Amount");
        config.infoTotalAmount = orderTotalAmount;
        config.infoCurrencyString = [[Utility sharedManager] convertToString:config.infoTotalAmount isCurrency:true];
    }
    else if ([_selectedPaymentGateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_PAYSTACK]]){
        PaystackConfig* config = [PaystackConfig sharedManager];
        config.paymentPageTitle = Localize(@"make_a_payment");
        config.backButtonTitle = [NSString stringWithFormat:@"< %@", Localize(@"i_back")];
        AppUser* user = [AppUser sharedManager];
        config.infoCountry = [NSString stringWithFormat:@"%@", user._billing_address._countryId];
        config.infoCurrency = [NSString stringWithFormat:@"%@", [CommonInfo sharedManager]->_currency];
        config.infoCurrency = @"NGN";//this is static currency as per discussion
        config.infoEmail = [NSString stringWithFormat:@"%@", user._email];
        config.infoDescription = Localize(@"Total Amount");
        config.infoTotalAmount = orderTotalAmount;
        config.infoCurrencyString = [[Utility sharedManager] convertToString:config.infoTotalAmount isCurrency:true];
    }
    else if ([_selectedPaymentGateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_SAGEPAY]]) {
        SagepayConfig* config = [SagepayConfig sharedManager];
        config.paymentPageTitle = Localize(@"make_a_payment");
        config.backButtonTitle = [NSString stringWithFormat:@"< %@", Localize(@"i_back")];
        AppUser* user = [AppUser sharedManager];
        config.infoAddress = [NSString stringWithFormat:@"%@ %@", user._billing_address._address_1, user._billing_address._address_2];
        config.infoCity = [NSString stringWithFormat:@"%@", user._billing_address._city];
        config.infoDescription = Localize(@"Total Amount");
        config.infoPlatform = @"ios";
        config.infoPostCode = [NSString stringWithFormat:@"%@", user._billing_address._postcode];
        config.infoCountry = [NSString stringWithFormat:@"%@", user._billing_address._countryId];
        config.infoFirstName = [NSString stringWithFormat:@"%@", user._billing_address._first_name];
        config.infoLastName = [NSString stringWithFormat:@"%@", user._billing_address._last_name];
        config.infoTotalAmount = orderTotalAmount;
        config.infoCurrency = [NSString stringWithFormat:@"%@", [CommonInfo sharedManager]->_currency];
    }
    else if ([_selectedPaymentGateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_GESTPAY]]) {
        GestpayConfig* config = [GestpayConfig sharedManager];
        config.paymentPageTitle = Localize(@"make_a_payment");
        config.backButtonTitle = [NSString stringWithFormat:@"< %@", Localize(@"i_back")];
        config.infoTotalAmount = orderTotalAmount;
    }
    else if ([_selectedPaymentGateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_KENT_PAYMENT]]) {
        KentPaymentConfig* config = [KentPaymentConfig sharedManager];
        config.paymentPageTitle = Localize(@"make_a_payment");
        config.backButtonTitle = [NSString stringWithFormat:@"< %@", Localize(@"i_back")];
        AppUser* user = [AppUser sharedManager];
        config.infoAddress = [NSString stringWithFormat:@"%@ %@", user._billing_address._address_1, user._billing_address._address_2];
        config.infoCity = [NSString stringWithFormat:@"%@", user._billing_address._city];
        config.infoDescription = Localize(@"Total Amount");
        config.infoPlatform = @"ios";
        config.infoPostCode = [NSString stringWithFormat:@"%@", user._billing_address._postcode];
        config.infoCountry = [NSString stringWithFormat:@"%@", user._billing_address._countryId];
        config.infoFirstName = [NSString stringWithFormat:@"%@", user._billing_address._first_name];
        config.infoLastName = [NSString stringWithFormat:@"%@", user._billing_address._last_name];
        config.infoTotalAmount = orderTotalAmount;
        config.infoCurrency = [NSString stringWithFormat:@"%@", [CommonInfo sharedManager]->_currency];
    }
    else if ([_selectedPaymentGateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_PAYPAL_PAYFLOW]]) {
        PayPalPayFlowConfig* config = [PayPalPayFlowConfig sharedManager];
        config.paymentPageTitle = Localize(@"make_a_payment");
        config.backButtonTitle = [NSString stringWithFormat:@"< %@", Localize(@"i_back")];
        AppUser* user = [AppUser sharedManager];
        config.infoBillingAdd1 = [NSString stringWithFormat:@"%@", user._billing_address._address_1];
        config.infoBillingAdd2 = [NSString stringWithFormat:@"%@", user._billing_address._address_2];
        config.infoCity = [NSString stringWithFormat:@"%@", user._billing_address._city];
        config.infoCountry = [NSString stringWithFormat:@"%@", user._billing_address._countryId];
        config.infoCurrency = [NSString stringWithFormat:@"%@", [CommonInfo sharedManager]->_currency];
        config.infoEmail = [NSString stringWithFormat:@"%@", user._email];
        config.infoFirstName = [NSString stringWithFormat:@"%@", user._billing_address._first_name];
        config.infoLastName = [NSString stringWithFormat:@"%@", user._billing_address._last_name];
        config.infoPhone = [NSString stringWithFormat:@"%@", user._billing_address._phone];
        config.infoPostCode = [NSString stringWithFormat:@"%@", user._billing_address._postcode];
        config.infoPlatform = @"ios";
        config.infoState = [NSString stringWithFormat:@"%@", user._billing_address._stateId];
        config.infoTotalAmount = orderTotalAmount;
    }
    else if ([_selectedPaymentGateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_VCS_PAY]]) {
        VCSPayConfig* config = [VCSPayConfig sharedManager];
        
        config.paymentPageTitle = Localize(@"make_a_payment");
        config.backButtonTitle = [NSString stringWithFormat:@"< %@", Localize(@"i_back")];
        config.pp_card_holder_name_hint = Localize(@"hint_card_holder_name");
        config.pp_card_number_hint = Localize(@"hint_card_number");
        config.pp_card_expiry_date_hint = Localize(@"hint_card_expiry_date");
        config.pp_card_cvv_hint = Localize(@"hint_card_cvv");
        config.pp_card_zipcode_hint = Localize(@"hint_card_zip");
        config.pp_card_holder_name = Localize(@"title_card_holder_name");
        config.pp_card_number = Localize(@"title_card_number");
        config.pp_card_expiry_date = Localize(@"title_card_expiry_date");
        config.pp_card_cvv = Localize(@"title_card_cvv");
        config.pp_card_zipcode = Localize(@"title_card_zip");
        config.pp_pay_button_title = Localize(@"title_pay");
        config.pp_invalid_details = Localize(@"error_check_card_details");
        config.pp_all_fields_are_mendatory = Localize(@"all_fields_are_mendatory");
        config.button_ok_title = Localize(@"i_ok");
    
        config.infoCurrency = [NSString stringWithFormat:@"%@", [CommonInfo sharedManager]->_currency];
        config.infoPlatform = @"ios";
        config.infoTotalAmount = orderTotalAmount;
        config.infoCurrencyString = [[Utility sharedManager] convertToString:config.infoTotalAmount isCurrency:true];
        if ([Localize(@"apple_pay_app_name") isEqualToString:@"default_value"]) {
            NSString* stringAppDisplayName = Localize(@"app_display_name");
            if ([stringAppDisplayName isEqualToString:@""] || [stringAppDisplayName isEqualToString:@"app_display_name"]) {
                stringAppDisplayName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
            }
            NSString* appName = stringAppDisplayName;
            config.infoDescription = appName;
        } else {
            config.infoDescription = Localize(@"apple_pay_app_name");
        }
    }
    else if ([_selectedPaymentGateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_TAP_PAYMENT]]) {
        TapPaymentConfig* config = [TapPaymentConfig sharedManager];
        config.paymentPageTitle = Localize(@"make_a_payment");
        config.backButtonTitle = [NSString stringWithFormat:@"< %@", Localize(@"i_back")];
        AppUser* user = [AppUser sharedManager];
        config.infoCurrency = [NSString stringWithFormat:@"%@", [CommonInfo sharedManager]->_currency];
        config.infoEmail = [NSString stringWithFormat:@"%@", user._email];
        config.infoFirstName = [NSString stringWithFormat:@"%@", user._billing_address._first_name];
        config.infoLastName = [NSString stringWithFormat:@"%@", user._billing_address._last_name];
        config.infoPhone = [NSString stringWithFormat:@"%@", user._billing_address._phone];
        config.infoPlatform = @"ios";
        config.infoTotalAmount = orderTotalAmount;
    }
    else if ([_selectedPaymentGateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_PLUGNPAY_PAYMENT]]) {
        PlugNPayPaymentConfig* config = [PlugNPayPaymentConfig sharedManager];
        config.paymentPageTitle = Localize(@"make_a_payment");
        config.backButtonTitle = [NSString stringWithFormat:@"< %@", Localize(@"i_back")];
        AppUser* user = [AppUser sharedManager];
        config.infoEmail = [NSString stringWithFormat:@"%@", user._email];
        config.infoPhone = [NSString stringWithFormat:@"%@", user._billing_address._phone];
        config.infoPlatform = @"ios";
        config.infoOrderDescription= Localize(@"Total Amount");
        config.infoTotalAmount = orderTotalAmount;
        config.infoName = [NSString stringWithFormat:@"%@ %@", user._billing_address._first_name, user._billing_address._last_name];
        config.infoOrderId = [NSString stringWithFormat:@"%d", _blankOrder._id];
    }
    else if ([_selectedPaymentGateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_SENANGPAY_PAYMENT]]) {
        SenangPayPaymentConfig* config = [SenangPayPaymentConfig sharedManager];
        config.paymentPageTitle = Localize(@"make_a_payment");
        config.backButtonTitle = [NSString stringWithFormat:@"< %@", Localize(@"i_back")];
        AppUser* user = [AppUser sharedManager];
        config.infoEmail = [NSString stringWithFormat:@"%@", user._email];
        config.infoPhone = [NSString stringWithFormat:@"%@", user._billing_address._phone];
        config.infoDescription= Localize(@"Total Amount");
        config.infoTotalAmount = orderTotalAmount;
        config.infoName = [NSString stringWithFormat:@"%@ %@", user._billing_address._first_name, user._billing_address._last_name];
        config.infoOrderId = [NSString stringWithFormat:@"%d", _blankOrder._id];
    }
    else if ([_selectedPaymentGateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_MOLLIE_PAYMENT]]) {
        MolliePaymentConfig* config = [MolliePaymentConfig sharedManager];
        config.paymentPageTitle = Localize(@"make_a_payment");
        config.backButtonTitle = [NSString stringWithFormat:@"< %@", Localize(@"i_back")];
        AppUser* user = [AppUser sharedManager];
        config.infoEmail = [NSString stringWithFormat:@"%@", user._email];
        config.infoPhone = [NSString stringWithFormat:@"%@", user._billing_address._phone];
        config.infoDescription= Localize(@"Total Amount");
        config.infoTotalAmount = orderTotalAmount;
        config.infoName = [NSString stringWithFormat:@"%@ %@", user._billing_address._first_name, user._billing_address._last_name];
        config.infoOrderId = [NSString stringWithFormat:@"%d", _blankOrder._id];
    }
    else if ([_selectedPaymentGateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_HESABE_PAYMENT]]) {
        HesabePaymentConfig* config = [HesabePaymentConfig sharedManager];
        config.paymentPageTitle = Localize(@"make_a_payment");
        config.backButtonTitle = [NSString stringWithFormat:@"< %@", Localize(@"i_back")];
        AppUser* user = [AppUser sharedManager];
        config.infoEmail = [NSString stringWithFormat:@"%@", user._email];
        config.infoPhone = [NSString stringWithFormat:@"%@", user._billing_address._phone];
        config.infoDescription= Localize(@"Total Amount");
        config.infoTotalAmount = orderTotalAmount;
        config.infoName = [NSString stringWithFormat:@"%@ %@", user._billing_address._first_name, user._billing_address._last_name];
        config.infoOrderId = [NSString stringWithFormat:@"%d", _blankOrder._id];
    }
    else if ([_selectedPaymentGateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_CONEKTA_CARD]]) {
        ConektaCardConfig* config = [ConektaCardConfig sharedManager];
        config.paymentPageTitle = Localize(@"make_a_payment");
        config.backButtonTitle = [NSString stringWithFormat:@"< %@", Localize(@"i_back")];
        AppUser* user = [AppUser sharedManager];
        config.infoEmail = [NSString stringWithFormat:@"%@", user._email];
        config.infoPhone = [NSString stringWithFormat:@"%@", user._billing_address._phone];
        config.infoDescription= Localize(@"Total Amount");
        config.infoTotalAmount = orderTotalAmount;
        config.infoName = [NSString stringWithFormat:@"%@ %@", user._billing_address._first_name, user._billing_address._last_name];
        config.infoOrderId = [NSString stringWithFormat:@"%d", _blankOrder._id];
        
        
        AppUser* appUser = [AppUser sharedManager];
        if (appUser._billing_address) {
            Address* address = appUser._billing_address;
            NSMutableArray* array = [[NSMutableArray alloc] init];
            NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
            
            if (address._company && ![address._company isEqualToString:@""]) {
                [dict setValue:address._company forKey:@"company_name"];
            } else {
                [dict setValue:@"default" forKey:@"company_name"];
            }
            
            if (address._address_1 && ![address._address_1 isEqualToString:@""]) {
                [dict setValue:address._address_1 forKey:@"street1"];
            } else {
                [dict setValue:@"default" forKey:@"street1"];
            }
            
            if (address._address_2 && ![address._address_2 isEqualToString:@""]) {
                [dict setValue:address._address_2 forKey:@"street2"];
            } else {
                [dict setValue:@"default" forKey:@"street2"];
            }
            
            if (address._postcode && ![address._postcode isEqualToString:@""]) {
                [dict setValue:address._postcode forKey:@"zip"];
            } else {
                [dict setValue:@"default" forKey:@"zip"];
            }
            
            if (address._city && ![address._city isEqualToString:@""]) {
                [dict setValue:address._city forKey:@"city"];
            } else {
                [dict setValue:@"default" forKey:@"city"];
            }
            
            if (address._phone && ![address._phone isEqualToString:@""]) {
                [dict setValue:address._phone forKey:@"phone"];
            } else {
                [dict setValue:@"default" forKey:@"phone"];
            }
            
            if (address._email && ![address._email isEqualToString:@""]) {
                [dict setValue:address._email forKey:@"email"];
            } else {
                [dict setValue:@"default" forKey:@"email"];
            }
            
            if (address._country && ![address._country isEqualToString:@""]) {
                [dict setValue:address._country forKey:@"country"];
            } else {
                [dict setValue:@"default" forKey:@"country"];
            }
            
            if (address._state && ![address._state isEqualToString:@""]) {
                [dict setValue:address._state forKey:@"state"];
            } else {
                [dict setValue:@"default" forKey:@"state"];
            }
            
            [array addObject:dict];
            NSString* strBillingAddress = [[array valueForKey:@"description"] componentsJoinedByString:@""];
            config.infoBillingAddress = strBillingAddress;
        }
        
        if (appUser._shipping_address) {
            Address* address = appUser._shipping_address;
            NSMutableArray* array = [[NSMutableArray alloc] init];
            NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
            
//            if (address._company && ![address._company isEqualToString:@""]) {
//                [dict setValue:address._company forKey:@"company_name"];
//            } else {
//                [dict setValue:@"default" forKey:@"company_name"];
//            }
            
            if (address._address_1 && ![address._address_1 isEqualToString:@""]) {
                [dict setValue:address._address_1 forKey:@"street1"];
            } else {
                [dict setValue:@"default" forKey:@"street1"];
            }
            
            if (address._address_2 && ![address._address_2 isEqualToString:@""]) {
                [dict setValue:address._address_2 forKey:@"street2"];
            } else {
                [dict setValue:@"default" forKey:@"street2"];
            }
            
            if (address._postcode && ![address._postcode isEqualToString:@""]) {
                [dict setValue:address._postcode forKey:@"zip"];
            } else {
                [dict setValue:@"default" forKey:@"zip"];
            }
            
            if (address._city && ![address._city isEqualToString:@""]) {
                [dict setValue:address._city forKey:@"city"];
            } else {
                [dict setValue:@"default" forKey:@"city"];
            }
            
            if (address._phone && ![address._phone isEqualToString:@""]) {
                [dict setValue:address._phone forKey:@"phone"];
            } else {
                [dict setValue:@"default" forKey:@"phone"];
            }
            
//            if (address._email && ![address._email isEqualToString:@""]) {
//                [dict setValue:address._email forKey:@"email"];
//            } else {
//                [dict setValue:@"default" forKey:@"email"];
//            }
            
            if (address._country && ![address._country isEqualToString:@""]) {
                [dict setValue:address._country forKey:@"country"];
            } else {
                [dict setValue:@"default" forKey:@"country"];
            }
            
            if (address._state && ![address._state isEqualToString:@""]) {
                [dict setValue:address._state forKey:@"state"];
            } else {
                [dict setValue:@"default" forKey:@"state"];
            }
            
            [array addObject:dict];
            NSString* strShippingAddress = [[array valueForKey:@"description"] componentsJoinedByString:@""];
            config.infoShippingAddress = strShippingAddress;
        }
        
        {
            NSMutableArray* array = [[NSMutableArray alloc] init];
            NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
            [dict setValue:@"default" forKey:@"carrier"];
            [dict setValue:@"default" forKey:@"service"];
            [dict setValue:@"0" forKey:@"price"];
            [array addObject:dict];
            NSString* strShipment = [[array valueForKey:@"description"] componentsJoinedByString:@""];
            config.infoShipment = strShipment;
        }
        
        
        {
            NSMutableArray* array = [[NSMutableArray alloc] init];
            for (LineItem* lineItem in _blankOrder._line_items) {
                NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
                [dict setValue:lineItem._name forKey:@"name"];
                [dict setValue:[NSNumber numberWithFloat:lineItem._price] forKey:@"unit_price"];
                [dict setValue:lineItem._name forKey:@"description"];
                [dict setValue:[NSNumber numberWithInt:lineItem._quantity] forKey:@"quantity"];
                [dict setValue:lineItem._sku forKey:@"sku"];
                [dict setValue:@"" forKey:@"type"];
                [array addObject:dict];
            }
            NSString* strOrderItems = [[array valueForKey:@"description"] componentsJoinedByString:@""];
            config.infoOrderItems = strOrderItems;
        }
    }
    else if ([_selectedPaymentGateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_BRAINTREE]]) {
        BraintreeConfig* config = [BraintreeConfig sharedManager];
        config.paymentPageTitle = Localize(@"make_a_payment");
        config.backButtonTitle = [NSString stringWithFormat:@"< %@", Localize(@"i_back")];
        config.infoTotalAmount = orderTotalAmount;
    }
    else if ([_selectedPaymentGateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_MYGATE]]) {
        MyGateConfig* config = [MyGateConfig sharedManager];
        config.paymentPageTitle = Localize(@"make_a_payment");
        config.backButtonTitle = [NSString stringWithFormat:@"< %@", Localize(@"i_back")];
        config.infoTotalAmount = orderTotalAmount;
    }
    else if ([_selectedPaymentGateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_AUTHORIZENET]]) {
        AppUser* user = [AppUser sharedManager];
        AuthorizeNetConfig* config = [AuthorizeNetConfig sharedManager];
        config.paymentPageTitle = Localize(@"make_a_payment");
        config.backButtonTitle = [NSString stringWithFormat:@"< %@", Localize(@"i_back")];
        config.infoTotalAmount = orderTotalAmount;
        config.infoCurrency = [NSString stringWithFormat:@"%@", [CommonInfo sharedManager]->_currency];
        config.infoEmail = [NSString stringWithFormat:@"%@", user._email];
        config.infoFirstName = [NSString stringWithFormat:@"%@", user._billing_address._first_name];
        config.infoLastName = [NSString stringWithFormat:@"%@", user._billing_address._last_name];
        config.infoPhone = [NSString stringWithFormat:@"%@", user._billing_address._phone];
        config.infoPlatform = @"ios";
        config.infoTotalAmount = orderTotalAmount;
        config.infoOrderId = [NSString stringWithFormat:@"%d", _blankOrder._id];
        config.infoPostCode = [NSString stringWithFormat:@"%@", user._billing_address._postcode];
        config.infoCity = [NSString stringWithFormat:@"%@", user._billing_address._city];
        config.infoCountry = [NSString stringWithFormat:@"%@", user._billing_address._countryId];
        config.infoState = [NSString stringWithFormat:@"%@", user._billing_address._stateId];
        config.infoAddress = [NSString stringWithFormat:@"%@ %@", user._billing_address._address_1, user._billing_address._address_2];
    }
    else if ([_selectedPaymentGateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_DUSUPAY]]) {
        DusupayConfig* config = [DusupayConfig sharedManager];
        config.paymentPageTitle = Localize(@"make_a_payment");
        config.backButtonTitle = [NSString stringWithFormat:@"< %@", Localize(@"i_back")];
        config.infoTotalAmount = orderTotalAmount;
        config.infoCurrency = [NSString stringWithFormat:@"%@", [CommonInfo sharedManager]->_currency];
    }
    else if ([_selectedPaymentGateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_CCAVENUE]]) {
        CCAvenueConfig* config = [CCAvenueConfig getInstance];
        config.paymentPageTitle = Localize(@"make_a_payment");
        config.backButtonTitle = [NSString stringWithFormat:@"< %@", Localize(@"i_back")];
        config.currency = [CommonInfo sharedManager]->_currency;
        config.orderId = _blankOrder._id;
        config.amount = orderTotalAmount;
    }
    else {
        payThroughWebsite = true;
    }
    if (payThroughWebsite) {
        //pay through website
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
        ViewControllerCheckout* vcCheckout = (ViewControllerCheckout*)[[Utility sharedManager] pushScreenWithoutAnimation:mainVC.vcCenterTop type:PUSH_SCREEN_TYPE_CHECKOUT];
        [vcCheckout loadLoginViewHidden];
        //        [mainVC.revealController revealToggle:self];
    }
    else {
        [[AppDelegate getInstance] logPaymentInit];
        [_selectedPaymentGateway payAmount:orderTotalAmount currencyCode:[CommonInfo sharedManager]->_currency delegate:self];
    }
}
- (void)blankOrderSuccess:(NSNotification*)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BLANK_ORDER_SUCCESS" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BLANK_ORDER_FAILURE" object:nil];
    RLOG(@"blankOrderSuccess");
    if (_blankOrder == nil) {
        _blankOrder = (Order*) (notification.object);
        AppUser* appUser = [AppUser sharedManager];
        [appUser._ordersArray insertObject:_blankOrder atIndex:0];
        appUser._last_order_id = _blankOrder._id;
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
        NSString *stringFromDate = [df stringFromDate:_blankOrder._updated_at];
        appUser._last_order_date = [NSString stringWithFormat:@"%@", stringFromDate];
    }
    _screen_current_state = SCREEN_STATE_CREATE_BLANK_ORDER_DONE;
    [self bookDeliverySlots];
}
- (void)blankOrderFailed:(NSNotification*)notification {
    RLOG(@"blankOrderFailed");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BLANK_ORDER_SUCCESS" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BLANK_ORDER_FAILURE" object:nil];
}
- (UIView*)createOrderSummery{
    UIView* view = [[UIView alloc] init];
    [view setFrame:CGRectMake(self.view.frame.size.width * 0.01f, 0, self.view.frame.size.width * 0.98f, 200)];
    [view setBackgroundColor:[UIColor whiteColor]];
    [view.layer setBorderColor:[[Utility getUIColor:kUIColorBorder] CGColor]];
    [view.layer setBorderWidth:1];
    
    float height = 0;
    int itemsCount = (int)[[[AppUser sharedManager] _cartArray] count];
    if (itemsCount > 0) {
        for (int i = 0; i < itemsCount; i++) {
            Cart* c = (Cart*)[[[AppUser sharedManager] _cartArray] objectAtIndex:i];
            UIView* subView = [self addView:i pInfo:c.product isCartItem:true isWishlistItem:false quantity:c.count];
            [view addSubview:subView];
            CGRect subViewRect = subView.frame;
            
            subViewRect.origin.y = height;
            height += subViewRect.size.height;
            [subView setFrame:subViewRect];
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
- (UIView*)createCartInfoView {
    NSString* stringQuantityH = [NSString stringWithFormat:Localize(@"label_quantity")];
    NSString* stringQuantity = [NSString stringWithFormat:@"%d",[Cart getItemCount]];
    //    NSString* stringAmountH = [NSString stringWithFormat:Localize(@"i_cart_totals")];
    NSString* stringAmount = [NSString stringWithFormat:@"%@",[[Utility sharedManager] convertToString:[Cart getTotalPayment] isCurrency:true symbolAtLast:isCurrencySymbolAtLast]];
    
    UILabel* labelTemp= [[UILabel alloc] init];
    [labelTemp setUIFont:kUIFontType24 isBold:false];
    UIView* view = [[UIView alloc] init];
    [view setFrame:CGRectMake(self.view.frame.size.width * 0.01f, 0, self.view.frame.size.width * 0.98f, [[labelTemp font] lineHeight] * 10)];
    
    float leftItemsPosX = self.view.frame.size.width * 0.10f;
    float rightItemsPosX = self.view.frame.size.width * 0.50f;
    float itemPosY = self.view.frame.size.width * 0.04f;
    float width = view.frame.size.width * .50f;
    
    [view setBackgroundColor:[UIColor whiteColor]];
    //    [view.layer setBorderColor:[[Utility getUIColor:kUIColorBorder] CGColor]];
    //    [view.layer setBorderWidth:1];
    [_scrollView addSubview:view];
    [_viewsAdded addObject:view];
    [view setTag:kTagForGlobalSpacing];
    float fontHeight = 0;
    
    [view addSubview:[self addBorder:view]];
    //////////////////////////Quantity//////////////////////////
    UILabel* labelQuantityH= [[UILabel alloc] init];
    [labelQuantityH setUIFont:kUIFontType18 isBold:true];
    fontHeight = [[labelQuantityH font] lineHeight];
    [labelQuantityH setFrame:CGRectMake(leftItemsPosX, itemPosY, width, fontHeight)];
    [labelQuantityH setTextColor:[Utility getUIColor:kUIColorFontLight]];
    [labelQuantityH setText:stringQuantityH];
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        [labelQuantityH setTextAlignment:NSTextAlignmentRight];
    } else {
        [labelQuantityH setTextAlignment:NSTextAlignmentLeft];
    }
    [view addSubview:labelQuantityH];
    labelQuantityH.lineBreakMode = NSLineBreakByWordWrapping;
    labelQuantityH.numberOfLines = 0;
    [labelQuantityH sizeToFitUI];
    
    UILabel* labelQuantityColon= [[UILabel alloc] init];
    [labelQuantityColon setUIFont:kUIFontType18 isBold:false];
    fontHeight = [[labelQuantityColon font] lineHeight];
    [labelQuantityColon setFrame:CGRectMake(rightItemsPosX, itemPosY, width, fontHeight)];
    [labelQuantityColon setTextColor:[Utility getUIColor:kUIColorFontLight]];
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        [labelQuantityColon setTextAlignment:NSTextAlignmentRight];
    } else {
        [labelQuantityColon setTextAlignment:NSTextAlignmentLeft];
    }
    [labelQuantityColon setText:@":"];
    [labelQuantityColon sizeToFitUI];
    [view addSubview:labelQuantityColon];
    
    UILabel* labelQuantity= [[UILabel alloc] init];
    [labelQuantity setUIFont:kUIFontType18 isBold:true];
    fontHeight = [[labelQuantity font] lineHeight];
    [labelQuantity setFrame:CGRectMake(rightItemsPosX + 0, itemPosY, width, fontHeight)];
    [labelQuantity setTextColor:[Utility getUIColor:kUIColorFontLight]];
    [labelQuantity setText:stringQuantity];
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        [labelQuantity setTextAlignment:NSTextAlignmentRight];
    } else {
        [labelQuantity setTextAlignment:NSTextAlignmentLeft];
    }
    
    [labelQuantity setFrame:CGRectMake(rightItemsPosX - leftItemsPosX, itemPosY, width, fontHeight)];
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        [labelQuantity setFrame:CGRectMake(rightItemsPosX + leftItemsPosX, itemPosY, width, fontHeight)];
        [labelQuantity setTextAlignment:NSTextAlignmentRight];
    } else {
        [labelQuantity setTextAlignment:NSTextAlignmentRight];
    }
    
    
    
    
    [view addSubview:labelQuantity];
    itemPosY += (fontHeight + labelQuantityH.frame.size.height);
    
    //////////////////////////Amount//////////////////////////
    UILabel* labelAmountH= [[UILabel alloc] init];
    [labelAmountH setUIFont:kUIFontType18 isBold:true];
    fontHeight = [[labelAmountH font] lineHeight];
    [view addSubview:labelAmountH];
    [labelAmountH setFrame:CGRectMake(leftItemsPosX, itemPosY, view.frame.size.width * 0.5f -leftItemsPosX, fontHeight)];
    NSString* stringAmountH = [NSString stringWithFormat:Localize(@"i_cart_totals")];
    [labelAmountH setText:stringAmountH];
    labelAmountH.lineBreakMode = NSLineBreakByWordWrapping;
    labelAmountH.numberOfLines = 0;
    [labelAmountH sizeToFitUI];
    [labelAmountH setTextColor:[Utility getUIColor:kUIColorFontLight]];
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        [labelAmountH setTextAlignment:NSTextAlignmentRight];
    } else {
        [labelAmountH setTextAlignment:NSTextAlignmentLeft];
    }
    if ([[Addons sharedManager] hide_price]) {
        CGRect rect = labelAmountH.frame;
        rect.size.height = 0;
        labelAmountH.frame = rect;
    } else {
        
    }
    
    
    UILabel* labelAmountColon= [[UILabel alloc] init];
    [labelAmountColon setUIFont:kUIFontType18 isBold:false];
    fontHeight = [[labelAmountColon font] lineHeight];
    [labelAmountColon setFrame:CGRectMake(rightItemsPosX, itemPosY, width, fontHeight)];
    [labelAmountColon setTextColor:[Utility getUIColor:kUIColorFontLight]];
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        [labelAmountColon setTextAlignment:NSTextAlignmentRight];
    } else {
        [labelAmountColon setTextAlignment:NSTextAlignmentLeft];
    }
    [labelAmountColon setText:@":"];
    [labelAmountColon sizeToFitUI];
    [view addSubview:labelAmountColon];
    if ([[Addons sharedManager] hide_price]) {
        CGRect rect = labelAmountColon.frame;
        rect.size.height = 0;
        labelAmountColon.frame = rect;
    } else {
        
    }
    
    UILabel* labelAmount= [[UILabel alloc] init];
    [labelAmount setUIFont:kUIFontType18 isBold:true];
    fontHeight = [[labelAmount font] lineHeight];
    [labelAmount setTextColor:[Utility getUIColor:kUIColorFontLight]];
    [labelAmount setText:stringAmount];
    if (isCurrencySymbolAtLast) {
        [labelAmount setFrame:CGRectMake(rightItemsPosX - leftItemsPosX, itemPosY, width, fontHeight)];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [labelAmount setFrame:CGRectMake(rightItemsPosX + leftItemsPosX, itemPosY, width, fontHeight)];
            [labelAmount setTextAlignment:NSTextAlignmentRight];
        } else {
            [labelAmount setTextAlignment:NSTextAlignmentRight];
        }
    } else {
        [labelAmount setFrame:CGRectMake(rightItemsPosX + leftItemsPosX, itemPosY, width, fontHeight)];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [labelAmount setTextAlignment:NSTextAlignmentRight];
        } else {
            [labelAmount setTextAlignment:NSTextAlignmentLeft];
        }
    }
    [view addSubview:labelAmount];
    if ([[Addons sharedManager] hide_price]) {
        CGRect rect = labelAmount.frame;
        rect.size.height = 0;
        labelAmount.frame = rect;
        itemPosY += (0 + labelAmountH.frame.size.height);
    } else {
        itemPosY += (fontHeight + labelAmountH.frame.size.height);
    }
    
    
    
    
//    itemPosY += fontHeight;
    if ([[Addons sharedManager] hide_price]) {
        [view setFrame:CGRectMake(self.view.frame.size.width * 0.01f, 0, self.view.frame.size.width * 0.98f, 0)];
    } else {
        [view setFrame:CGRectMake(self.view.frame.size.width * 0.01f, 0, self.view.frame.size.width * 0.98f, itemPosY)];
    }

    
    
    return view;
}
- (UIView*)createDeliverySlotView {
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
    [view addSubview:[self addBorder:view]];

    if ([[[Addons sharedManager] deliverySlotsCopiaPlugin] isEnabled]) {
        self.buttonDateSelection = [[UIButton alloc] init];
        [self.buttonDateSelection setFrame:CGRectMake(leftMarginInsideView, varPosY, widthInsideView, fontHeight * 2.0f)];
        [self.buttonDateSelection setTitle:Localize(@"select_date") forState:UIControlStateNormal];
        [self.buttonDateSelection setTitleColor:[Utility getUIColor:kUIColorBuyButtonNormalBg] forState:UIControlStateNormal];
        [self.buttonDateSelection.titleLabel setUIFont:kUIFontType18 isBold:false];
        [self.buttonDateSelection addTarget:self action:@selector(dateSelectionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttonDateSelection setTitleEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)];
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
        varPosY = gap + CGRectGetMaxY(self.buttonDateSelection.frame);
    }
    
    self.buttonTimeSelection = [[UIButton alloc] init];
    [self.buttonTimeSelection setFrame:CGRectMake(leftMarginInsideView, varPosY, widthInsideView, fontHeight * 2.0f)];
    [self.buttonTimeSelection setTitle:Localize(@"select_time") forState:UIControlStateNormal];
    [self.buttonTimeSelection setTitleColor:[Utility getUIColor:kUIColorBuyButtonNormalBg] forState:UIControlStateNormal];
    [self.buttonTimeSelection.titleLabel setUIFont:kUIFontType18 isBold:false];
    [self.buttonTimeSelection addTarget:self action:@selector(timeSelectionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonTimeSelection setTitleEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)];
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

//    DateTimeSlot* minDateTimeSlot = [[DateTimeSlot getAllDateTimeSlots:_selectedShippingMethodId] objectAtIndex:0];
//    DateTimeSlot* maxDateTimeSlot = [[DateTimeSlot getAllDateTimeSlots:_selectedShippingMethodId] objectAtIndex:[[DateTimeSlot getAllDateTimeSlots:_selectedShippingMethodId] count] - 1];

    DateTimeSlot* minDateTimeSlot = [DateTimeSlot getStartDateSlot:_selectedShippingMethodId];
    DateTimeSlot* maxDateTimeSlot = [DateTimeSlot getEndDateSlot:_selectedShippingMethodId];
    
    
    NSString *minDateStr = [minDateTimeSlot getDateSlot];
    NSString *maxDateStr = [maxDateTimeSlot getDateSlot];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd/MM/yyyy"];
    NSDate *minDate = [dateFormat dateFromString:minDateStr];
    NSDate *maxDate = [dateFormat dateFromString:maxDateStr];
    datePicker.minimumDate = minDate;
    datePicker.maximumDate = maxDate;
    datePicker.date = minDate;
    if (self.selected_date_time_slot) {
        NSString *selectedDateStr = [self.selected_date_time_slot getDateSlot];
        NSDate *selectedDate = [dateFormat dateFromString:selectedDateStr];
        datePicker.date = selectedDate;
    }
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        viewForDatePicker.transform = CGAffineTransformMakeScale(-1, 1);
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
- (UIView*)createPickupSelectionView {
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
    [view addSubview:[self addBorder:view]];
    
    float testHeight = 0;
    if ([[Addons sharedManager] show_pickup_location] && [[TM_PickupLocation getAllPickupLocations] count] > 0) {
        TM_PickupLocation* picLoc = [[TM_PickupLocation getAllPickupLocations] objectAtIndex:0];
        
        UILabel* label = [[UILabel alloc] init];
        [label setFrame:CGRectMake(self.view.frame.size.width * 0.1f, varPosY, self.view.frame.size.width * 0.6f, testHeight)];
        [label setAttributedText:[picLoc getLocationStringAttributed]];
        
        [label setUIFont:kUIFontType17 isBold:true];
        [label setTextColor:[Utility getUIColor:kUIColorFontLight]];
        [label setNumberOfLines:0];
        [label setLineBreakMode:NSLineBreakByWordWrapping];
        [label sizeToFitUI];
        [view addSubview:label];
        
        NSString* picLocStrCost = @"";
        if (![picLoc.cost isEqualToString:@""]) {
            picLocStrCost = [NSString stringWithFormat:@"%@", [[Utility sharedManager] convertToString:[picLoc.cost floatValue] isCurrency:true]];
        } else {
            picLocStrCost = [NSString stringWithFormat:@"%@", [[Utility sharedManager] convertToString:0.0f isCurrency:true]];
        }
        UILabel* labelCost = [[UILabel alloc] init];
        
        float width = view.frame.size.width * .40f;
        [labelCost setFrame:CGRectMake(view.frame.size.width/2 + 15, varPosY, width - 10, fontHeight)];
        [labelCost setAttributedText:[[NSAttributedString alloc] initWithString:picLocStrCost]];
        [labelCost setUIFont:kUIFontType17 isBold:true];
        [labelCost setTextColor:[Utility getUIColor:kUIColorFontLight]];
        [view addSubview:labelCost];
        [labelCost setTextAlignment:NSTextAlignmentRight];
        
        if ([picLoc.cost floatValue] == 0.0f) {
            labelCost.hidden = true;
        }
        
        
        
        viewHeight = gap + CGRectGetMaxY(label.frame);
        [view setFrame:CGRectMake(viewPosX, viewPosY, viewWidth, viewHeight)];
        return view;
    }
    [view setFrame:CGRectMake(viewPosX, viewPosY, viewWidth, 0)];
    return view;
}
- (void)pickupSelectionButtonClicked:(UIButton *)sender {
    [self.ddViewPickupSelection removeFromSuperview];
    self.ddViewPickupSelection = nil;
    if(self.ddViewPickupSelection == nil)
    {
        NSArray * arrImage = nil;
        self.pickupDataObjects = [TM_PickupLocation getAllPickupLocations];
        
        NSMutableArray* pickupStrings = [[NSMutableArray alloc] init];
        for (TM_PickupLocation* pckloc in self.pickupDataObjects) {
            [pickupStrings addObject:pckloc.address_1];
        }
        
        CGFloat height = [[MyDevice sharedManager] screenHeightInPortrait] * .30f;
        self.ddViewPickupSelection = [[NIDropDown alloc] init:_buttonPickupSelection viewheight:height strArr:pickupStrings imgArr:arrImage direction:NIDropDownDirectionDown pView:self.view];
        self.ddViewPickupSelection.delegate = self;
        self.ddViewPickupSelection.fontColor = [Utility getUIColor:kUIColorBgTheme];
    }
    else {
        [self.ddViewPickupSelection toggle:_buttonPickupSelection];
    }
}
- (void)popoverControllerDidDismissPopover:(FPPopoverController *)popoverController {
    if (self.selected_date_time_slot == nil) {
//        DateTimeSlot* minDateTimeSlot = [[DateTimeSlot getAllDateTimeSlots:_selectedShippingMethodId] objectAtIndex:0];
        DateTimeSlot* minDateTimeSlot = [DateTimeSlot getStartDateSlot:_selectedShippingMethodId];
        self.selected_date_time_slot = minDateTimeSlot;
        NSString *selectedDateStr = [self.selected_date_time_slot getDateSlot];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"dd/MM/yyyy"];
        NSDate *selectedDate = [dateFormat dateFromString:selectedDateStr];
        NSString* dateString = [dateFormat stringFromDate:selectedDate];
        [self.buttonDateSelection setTitle:dateString forState:UIControlStateNormal];
        [self.buttonDateSelection setTitleColor:[Utility getUIColor:kUIColorFontDark] forState:UIControlStateNormal];
        [self.buttonDateSelection.titleLabel setUIFont:kUIFontType18 isBold:true];
        [self.buttonDateSelectionDownArrow setTintColor:[Utility getUIColor:kUIColorFontDark]];
    }
}
- (void)timeSelectionButtonClicked:(UIButton *)sender {
    [self.ddViewTimeSelection removeFromSuperview];
    self.ddViewTimeSelection = nil;
    if(self.ddViewTimeSelection == nil)
    {
        NSArray * arrImage = nil;
        if ([[[Addons sharedManager] deliverySlotsCopiaPlugin] isEnabled]) {
            if (self.selected_date_time_slot) {
                self.timeSlotDataObjects = [self.selected_date_time_slot getTimeSlot];
            }
        }
        if ([[[Addons sharedManager] localPickupTimeSelectPlugin] isEnabled]) {
            self.timeSlotDataObjects = [TimeSlot getAllTimeSlots];
        }
        
        NSMutableArray* timeStrings = [[NSMutableArray alloc] init];
        for (TimeSlot* ts in self.timeSlotDataObjects) {
            if ([ts.slotCost floatValue] > 0) {
                [timeStrings addObject:[NSString stringWithFormat:@"%@ (%@)", ts.slotTitle, [[Utility sharedManager] convertToString:[ts.slotCost floatValue] isCurrency:true symbolAtLast:isCurrencySymbolAtLast]]];
            } else {
                [timeStrings addObject:ts.slotTitle];
            }
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
        TimeSlot* ts =  [self.timeSlotDataObjects objectAtIndex:clickedItemId];
        self.selected_time_slot = ts;
        NSString* timeString = ts.slotTitle;
        if ([ts.slotCost floatValue] > 0) {
            timeString = [NSString stringWithFormat:@"%@ (%@)", ts.slotTitle, [[Utility sharedManager] convertToString:[ts.slotCost floatValue] isCurrency:true symbolAtLast:isCurrencySymbolAtLast]];
        } else {
            timeString = ts.slotTitle;
        }
        
        [self.buttonTimeSelection setTitle:timeString forState:UIControlStateNormal];
        [self.buttonTimeSelection setTitleColor:[Utility getUIColor:kUIColorFontDark] forState:UIControlStateNormal];
        [self.buttonTimeSelection.titleLabel setUIFont:kUIFontType18 isBold:true];
        [self.buttonTimeSelectionDownArrow setTintColor:[Utility getUIColor:kUIColorFontDark]];
    }
    [self updateDeliveryCostToFeeLine];
}
- (void)dateChanged:(UIDatePicker*)uiDatePicker{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd/MM/yyyy"];
    NSDate* selectedDate = uiDatePicker.date;
    NSString* dateString = [dateFormat stringFromDate:selectedDate];
    BOOL isDateTimeSlotExists = false;
    
    NSMutableArray* allDateTimeSlots = [DateTimeSlot getAllDateTimeSlots:_selectedShippingMethodId];
    NSDate* endDate = [DateTimeSlot getEndDate:_selectedShippingMethodId];
    DateTimeSlot* endDateSlot = [DateTimeSlot getEndDateSlot:_selectedShippingMethodId];
    
    
    
CHECK_FOR_NEXT_DATE:
    {
        if ([selectedDate compare:endDate] == NSOrderedDescending)
        {
            selectedDate = endDate;
            self.selected_date_time_slot = endDateSlot;
            isDateTimeSlotExists = true;
            [uiDatePicker setDate:selectedDate animated:true];
            dateString = [dateFormat stringFromDate:selectedDate];
        }
        for (DateTimeSlot* dts in allDateTimeSlots) {
            if ([[dts getDateSlot] isEqualToString:dateString]) {
                self.selected_date_time_slot = dts;
                isDateTimeSlotExists = true;
                break;
            }
        }
    }
    if (isDateTimeSlotExists == false) {
        selectedDate = [cal dateByAddingUnit:NSCalendarUnitDay
                                           value:1
                                          toDate:selectedDate
                                         options:0];
        [uiDatePicker setDate:selectedDate animated:true];
        dateString = [dateFormat stringFromDate:selectedDate];
        goto CHECK_FOR_NEXT_DATE;
    }
    
    
    [self.buttonDateSelection setTitle:dateString forState:UIControlStateNormal];
    [self.buttonDateSelection setTitleColor:[Utility getUIColor:kUIColorFontDark] forState:UIControlStateNormal];
    [self.buttonDateSelection.titleLabel setUIFont:kUIFontType18 isBold:true];
    [self.buttonDateSelectionDownArrow setTintColor:[Utility getUIColor:kUIColorFontDark]];
    
    if (self.buttonTimeSelection) {
        [self.buttonTimeSelection setTitle:Localize(@"select_time") forState:UIControlStateNormal];
        [self.buttonTimeSelection setTitleColor:[Utility getUIColor:kUIColorBuyButtonNormalBg] forState:UIControlStateNormal];
        [self.buttonTimeSelection.titleLabel setUIFont:kUIFontType18 isBold:false];
        [self.buttonTimeSelectionDownArrow setTintColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
        self.selected_time_slot = nil;
    }
    [self updateDeliveryCostToFeeLine];
}
- (void)resetDateSelectionView {
    if (self.buttonDateSelection) {
        [self.buttonDateSelection setTitle:Localize(@"select_date") forState:UIControlStateNormal];
        [self.buttonDateSelection setTitleColor:[Utility getUIColor:kUIColorBuyButtonNormalBg] forState:UIControlStateNormal];
        [self.buttonDateSelection.titleLabel setUIFont:kUIFontType18 isBold:false];
    }
    if (self.buttonDateSelectionDownArrow) {
        [self.buttonDateSelectionDownArrow setTintColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
    }
    self.selected_date_time_slot = nil;
    
    if (self.buttonTimeSelection) {
        [self.buttonTimeSelection setTitle:Localize(@"select_time") forState:UIControlStateNormal];
        [self.buttonTimeSelection setTitleColor:[Utility getUIColor:kUIColorBuyButtonNormalBg] forState:UIControlStateNormal];
        [self.buttonTimeSelection.titleLabel setUIFont:kUIFontType18 isBold:false];
        [self.buttonTimeSelectionDownArrow setTintColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
    }
    self.selected_time_slot = nil;
    [self updateDeliveryCostToFeeLine];
}
- (UIView*)createCheckoutAddonsView {
    _checkoutAddonCheckboxes = [[NSMutableArray alloc] init];
    UILabel* labelTemp= [[UILabel alloc] init];
    [labelTemp setUIFont:kUIFontType24 isBold:false];
    UIView* view = [[UIView alloc] init];
    [view setFrame:CGRectMake(self.view.frame.size.width * 0.01f, 0, self.view.frame.size.width * 0.98f, [[labelTemp font] lineHeight] * 10)];
    
    float leftItemsPosX = self.view.frame.size.width * 0.10f;
    float rightItemsPosX = self.view.frame.size.width * 0.50f;
    float itemPosY = self.view.frame.size.width * 0.04f;
    float width = view.frame.size.width * .40f;
    
    [view setBackgroundColor:[UIColor whiteColor]];
    [_scrollView addSubview:view];
    [_viewsAdded addObject:view];
    [view setTag:kTagForGlobalSpacing];
    float fontHeight = 0;
    [view addSubview:[self addBorder:view]];
    for (TM_CheckoutAddon* tmCheckoutAddon in [TM_CheckoutAddon getAllCheckoutAddons]) {
        UILabel* labelAmountColon= [[UILabel alloc] init];
        [labelAmountColon setUIFont:kUIFontType18 isBold:false];
        fontHeight = [[labelAmountColon font] lineHeight];
        
        float shipCost = tmCheckoutAddon.cost;
        NSString* shipTitle = tmCheckoutAddon.label;
        UIButton* button = [[UIButton alloc] init];
        button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        button.titleLabel.numberOfLines = 0;
        
        button.frame = CGRectMake(view.frame.size.width/2 - width, itemPosY, width, fontHeight);
        if (tmCheckoutAddon.type == TM_CheckoutAddonType_CHECKBOX) {
            [button addTarget:self action:@selector(chkBoxCheckoutAddonClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
        [view addSubview:button];
        [button setUIImage:[UIImage imageNamed:@"chkbox_unselected"] forState:UIControlStateNormal];
        [button setUIImage:[UIImage imageNamed:@"chkbox_selected"] forState:UIControlStateSelected];
        [button.titleLabel setUIFont:kUIFontType18 isBold:false];
        NSString * htmlString = shipTitle;
        NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        [button setTitle:[NSString stringWithFormat:@"%@", attrStr.string] forState:UIControlStateNormal];
        [button setImageEdgeInsets:UIEdgeInsetsMake(5, 0, 0, 0)];
        if ([[MyDevice sharedManager] isIphone]) {
            [button setImageEdgeInsets:UIEdgeInsetsMake(3, 0, 0, 0)];
        }
        button.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
        [button setTitleColor:[Utility getUIColor:kUIColorFontLight] forState:UIControlStateNormal];
        [button setTitleColor:[Utility getUIColor:kUIColorFontLight] forState:UIControlStateSelected];
        
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        button.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
        [button setSelected:NO];
        [button.titleLabel sizeToFitUI];
        
        CGRect btnsize = button.frame;
        btnsize.size.height = button.titleLabel.frame.size.height + fontHeight/4;
        button.frame = btnsize;
        //////////////////////////Amount//////////////////////////
        [labelAmountColon setFrame:CGRectMake(view.frame.size.width/2 + 5, button.frame.origin.y, width, fontHeight)];
        [labelAmountColon setTextColor:[Utility getUIColor:kUIColorFontDark]];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [labelAmountColon setTextAlignment:NSTextAlignmentRight];
        } else {
            [labelAmountColon setTextAlignment:NSTextAlignmentLeft];
        }
        [labelAmountColon setText:@":"];
        [view addSubview:labelAmountColon];
        [labelAmountColon setFrame:CGRectMake(labelAmountColon.frame.origin.x , button.frame.origin.y, labelAmountColon.frame.size.width, fontHeight)];
        
        
        
        UILabel* labelAmount= [[UILabel alloc] init];
        [labelAmount setUIFont:kUIFontType18 isBold:false];
        fontHeight = [[labelAmount font] lineHeight];
        [labelAmount setTextColor:[Utility getUIColor:kUIColorFontLight]];
        [view addSubview:labelAmount];
        [labelAmount setTextAlignment:NSTextAlignmentRight];
        NSString* shippingCost = [NSString stringWithFormat:@"%@",[[Utility sharedManager] convertToString:shipCost isCurrency:true symbolAtLast:isCurrencySymbolAtLast]];
        [labelAmount setText:shippingCost];
        [labelAmount setFrame:CGRectMake(view.frame.size.width/2 + 15, button.frame.origin.y, width - 10, fontHeight)];
        itemPosY += (fontHeight + button.frame.size.height);
        [button.layer setValue:tmCheckoutAddon forKey:@"MY_OBJECT"];
        [button.layer setValue:labelAmount forKey:@"MY_COST_LABEL"];
        [button.layer setValue:labelAmountColon forKey:@"MY_COST_LABEL_COLON"];
        [_checkoutAddonCheckboxes addObject:button];
    }
    [view setFrame:CGRectMake(self.view.frame.size.width * 0.01f, 0, self.view.frame.size.width * 0.98f, itemPosY)];
    return view;
}

- (UIView*)createShippingOptionView:(NSString*)errorMsg _chkBoxShipping:(NSMutableArray*)_chkBoxShipping bunchId:(int)bunchId {
    UILabel* labelTemp= [[UILabel alloc] init];
    [labelTemp setUIFont:kUIFontType24 isBold:false];
    UIView* view = [[UIView alloc] init];
    [view setFrame:CGRectMake(self.view.frame.size.width * 0.01f, 0, self.view.frame.size.width * 0.98f, [[labelTemp font] lineHeight] * 10)];
    
    float leftItemsPosX = self.view.frame.size.width * 0.10f;
    float rightItemsPosX = self.view.frame.size.width * 0.50f;
    float itemPosY = self.view.frame.size.width * 0.04f;
    float width = view.frame.size.width * .40f;
    
    [view setBackgroundColor:[UIColor whiteColor]];
    //    [view.layer setBorderColor:[[Utility getUIColor:kUIColorBorder] CGColor]];
    //    [view.layer setBorderWidth:1];
    [_scrollView addSubview:view];
    [_viewsAdded addObject:view];
    [view setTag:kTagForGlobalSpacing];
    float fontHeight = 0;
    [view addSubview:[self addBorder:view]];
    if ([errorMsg isEqualToString:@""]) {
        TMShippingSDK* tmShippingSDK = [[DataManager sharedManager] tmShippingSDK];
        BOOL isAnyShippingSelected = false;
        if(tmShippingSDK.shippingEnable && tmShippingSDK.shippingMethods) {
            for (TMShipping* shipMthod in tmShippingSDK.shippingMethods) {
                UILabel* labelAmountColon= [[UILabel alloc] init];
                [labelAmountColon setUIFont:kUIFontType18 isBold:false];
                fontHeight = [[labelAmountColon font] lineHeight];
                
                float shipCost = shipMthod.shippingCost;
                NSString* shipTitle = shipMthod.shippingLabel;
                
//                shipTitle = @"Amazon's losses in India more than doubled to Rs 3,572 crore during the twelve months that ended March 2016 as it stepped up its investments to dethrone local rival Flipkart as the top retailer in the country.";
                UIButton* button = [[UIButton alloc] init];
                button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
                button.titleLabel.numberOfLines = 0;
                
                button.frame = CGRectMake(view.frame.size.width/2 - width, itemPosY, width, fontHeight);
                [button addTarget:self action:@selector(chkBoxShippingClicked:) forControlEvents:UIControlEventTouchUpInside];
                [view addSubview:button];
                [button setUIImage:[UIImage imageNamed:@"radiobtn_unselected"] forState:UIControlStateNormal];
                [button setUIImage:[UIImage imageNamed:@"radiobtn_selected"] forState:UIControlStateSelected];
                [button.titleLabel setUIFont:kUIFontType18 isBold:false];
                NSString * htmlString = shipTitle;
                NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
                [button setTitle:[NSString stringWithFormat:@"%@", attrStr.string] forState:UIControlStateNormal];
//                [button setImageEdgeInsets:UIEdgeInsetsMake(5, -20, 0, 0)];
//                button.imageView.contentMode = UIViewContentModeScaleAspectFit;
//                [button setTitleEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
                [button setImageEdgeInsets:UIEdgeInsetsMake(5, 0, 0, 0)];
                if ([[MyDevice sharedManager] isIphone]) {
                    [button setImageEdgeInsets:UIEdgeInsetsMake(3, 0, 0, 0)];
                }
                button.imageView.contentMode = UIViewContentModeScaleAspectFit;
                [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
                [button setTitleColor:[Utility getUIColor:kUIColorFontLight] forState:UIControlStateNormal];
                [button setTitleColor:[Utility getUIColor:kUIColorFontLight] forState:UIControlStateSelected];
                
                button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
                button.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
                
                if (false && [tmShippingSDK.shippingMethodChoosedId isEqualToString:shipMthod.shippingMethodId]) {
                    [button setSelected:YES];
                }else {
                    [button setSelected:NO];
                }
                
                
                if (isAnyShippingSelected == false && shipMthod.shippingCost == 0.0f) {
                    [button setSelected:YES];
                    isAnyShippingSelected = true;
                }
                [button.titleLabel sizeToFitUI];
                
                CGRect btnsize = button.frame;
                btnsize.size.height = button.titleLabel.frame.size.height + fontHeight/4;
//                btnsize.size.width = width;
//                btnsize.size.width += 10;
                button.frame = btnsize;
                //////////////////////////Amount//////////////////////////
                [labelAmountColon setFrame:CGRectMake(view.frame.size.width/2 + 5, button.frame.origin.y, width, fontHeight)];
                [labelAmountColon setTextColor:[Utility getUIColor:kUIColorFontDark]];
                if ([[TMLanguage sharedManager] isRTLEnabled]) {
                    [labelAmountColon setTextAlignment:NSTextAlignmentRight];
                } else {
                    [labelAmountColon setTextAlignment:NSTextAlignmentLeft];
                }
                [labelAmountColon setText:@":"];
                [view addSubview:labelAmountColon];
                [labelAmountColon setFrame:CGRectMake(labelAmountColon.frame.origin.x , button.frame.origin.y, labelAmountColon.frame.size.width, fontHeight)];
                
                
                
                UILabel* labelAmount= [[UILabel alloc] init];
                [labelAmount setUIFont:kUIFontType18 isBold:false];
                fontHeight = [[labelAmount font] lineHeight];
                [labelAmount setTextColor:[Utility getUIColor:kUIColorFontLight]];
                [view addSubview:labelAmount];
                [labelAmount setTextAlignment:NSTextAlignmentRight];
                NSString* shippingCost = [NSString stringWithFormat:@"%@",[[Utility sharedManager] convertToString:shipCost isCurrency:true symbolAtLast:isCurrencySymbolAtLast]];
                [labelAmount setText:shippingCost];
                [labelAmount setFrame:CGRectMake(view.frame.size.width/2 + 15, button.frame.origin.y, width - 10, fontHeight)];
//                [labelAmount setTextAlignment:NSTextAlignmentRight];
                itemPosY += (fontHeight + button.frame.size.height);
                [button.layer setValue:shipMthod forKey:@"MY_OBJECT"];
                [button.layer setValue:[NSNumber numberWithInt:bunchId] forKey:@"MY_INDEX"];

                [button.layer setValue:labelAmount forKey:@"MY_COST_LABEL"];
                [button.layer setValue:labelAmountColon forKey:@"MY_COST_LABEL_COLON"];
                [_chkBoxShipping addObject:button];
                
                [button.layer setValue:_chkBoxShipping forKey:@"CHK_BOX_SHIPPING"];
            }
        }
    }
    else {
        UILabel* labelErrorMsg= [[UILabel alloc] init];
        _labelErrorMsgShippingInfo = labelErrorMsg;
        [labelErrorMsg setUIFont:kUIFontType18 isBold:false];
        fontHeight = [[labelErrorMsg font] lineHeight];
        [labelErrorMsg setTextColor:[Utility getUIColor:kUIColorFontLight]];
        [view addSubview:labelErrorMsg];
        [labelErrorMsg setText:errorMsg];
        [labelErrorMsg setFrame:CGRectMake(self.view.frame.size.width * 0.02f, itemPosY, view.frame.size.width - self.view.frame.size.width * 0.04f, fontHeight)];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [labelErrorMsg setTextAlignment:NSTextAlignmentRight];
        } else {
            [labelErrorMsg setTextAlignment:NSTextAlignmentLeft];
        }
        [labelErrorMsg setNumberOfLines:0];
        [labelErrorMsg setLineBreakMode:NSLineBreakByWordWrapping];
        [labelErrorMsg sizeToFitUI];
        [labelErrorMsg setFrame:CGRectMake(self.view.frame.size.width * 0.02f, itemPosY, view.frame.size.width - self.view.frame.size.width * 0.04f, labelErrorMsg.frame.size.height)];
        if ([errorMsg isEqualToString:Localize(@"no_shipping_method_found")]) {
            [labelErrorMsg setTextAlignment:NSTextAlignmentCenter];
        }
        itemPosY = fontHeight + CGRectGetMaxY(labelErrorMsg.frame);
    }
    
    if (_shippingBunches && bunchId != -1) {
        NSDictionary* dict = [_shippingBunches objectForKey:[NSNumber numberWithInt:bunchId]];
        NSString* deliveryDate = [dict objectForKey:@"date_slot"];
        NSString* deliveryTime = [dict objectForKey:@"time_slot"];
        UILabel* deliveryDetailsLabel = nil;
        UIImageView* dateSelectionIcon = nil;
        UILabel* dateSelectionLabel = nil;
        UIImageView* timeSelectionIcon = nil;
        UILabel* timeSelectionLabel = nil;
        float spacingIconX = 30;
        float spacingLabelX = 15;
        float iconW = 16;
        float iconH = 16;
        if ((deliveryDate && ![deliveryDate isEqualToString:@""]) ||
            (deliveryTime && ![deliveryTime isEqualToString:@""])
            ) {
            itemPosY += 5;
            deliveryDetailsLabel = [[UILabel alloc] init];
            [deliveryDetailsLabel setUIFont:kUIFontType14 isBold:false];
            deliveryDetailsLabel.frame = CGRectMake(leftItemsPosX, itemPosY, view.frame.size.width - leftItemsPosX * 2, deliveryDetailsLabel.font.lineHeight);
            [deliveryDetailsLabel setText:Localize(@"delivery_details")];
            [deliveryDetailsLabel setTextColor:[Utility getUIColor:kUIColorFontLight]];
            [view addSubview:deliveryDetailsLabel];
            itemPosY += deliveryDetailsLabel.font.lineHeight;
        }
        if (deliveryDate && ![deliveryDate isEqualToString:@""]) {
            itemPosY += 5;
            dateSelectionIcon = [[UIImageView alloc] init];
            dateSelectionIcon.frame = CGRectMake(leftItemsPosX + spacingIconX, itemPosY, iconW, iconH);
            [dateSelectionIcon setImage:[UIImage imageNamed:@"date_icon.png"]];
            [view addSubview:dateSelectionIcon];
            [dateSelectionIcon setTintColor:[Utility getUIColor:kUIColorFontLight]];
            [dateSelectionIcon setContentMode:UIViewContentModeScaleAspectFit];
            
            dateSelectionLabel = [[UILabel alloc] init];
            [dateSelectionLabel setUIFont:kUIFontType14 isBold:false];
            dateSelectionLabel.frame = CGRectMake(CGRectGetMaxX(dateSelectionIcon.frame) + spacingLabelX, itemPosY, view.frame.size.width - leftItemsPosX * 2 - (CGRectGetMaxX(dateSelectionIcon.frame) + spacingLabelX), MAX(dateSelectionLabel.font.lineHeight, iconH));
            [dateSelectionLabel setText:deliveryDate];
            [view addSubview:dateSelectionLabel];
            [dateSelectionLabel setTextColor:[Utility getUIColor:kUIColorFontLight]];
            itemPosY += MAX(dateSelectionLabel.font.lineHeight, iconH);
        }
        if (deliveryTime && ![deliveryTime isEqualToString:@""]) {
            itemPosY += 5;
            timeSelectionIcon = [[UIImageView alloc] init];
            timeSelectionIcon.frame = CGRectMake(leftItemsPosX + spacingIconX, itemPosY, iconW, iconH);
            [timeSelectionIcon setImage:[UIImage imageNamed:@"time_icon.png"]];
            [view addSubview:timeSelectionIcon];
            [timeSelectionIcon setTintColor:[Utility getUIColor:kUIColorFontLight]];
            [timeSelectionIcon setContentMode:UIViewContentModeScaleAspectFit];
            
            timeSelectionLabel = [[UILabel alloc] init];
            [timeSelectionLabel setUIFont:kUIFontType14 isBold:false];
            timeSelectionLabel.frame = CGRectMake(CGRectGetMaxX(timeSelectionIcon.frame) + spacingLabelX, itemPosY, view.frame.size.width - leftItemsPosX * 2 - (CGRectGetMaxX(timeSelectionIcon.frame) + spacingLabelX), MAX(timeSelectionLabel.font.lineHeight, iconH));
            [timeSelectionLabel setText:deliveryTime];
            [view addSubview:timeSelectionLabel];
            [timeSelectionLabel setTextColor:[Utility getUIColor:kUIColorFontLight]];
            itemPosY += MAX(timeSelectionLabel.font.lineHeight, iconH);
        }
        if (timeSelectionLabel) {
            float deliveryCost = [[dict objectForKey:@"time_slot_cost"] floatValue];
            UILabel* labelDeliveryCost= [[UILabel alloc] init];
            [labelDeliveryCost setUIFont:kUIFontType17 isBold:true];
            fontHeight = [[labelDeliveryCost font] lineHeight];
            [labelDeliveryCost setTextColor:[Utility getUIColor:kUIColorFontLight]];
            [view addSubview:labelDeliveryCost];
            [labelDeliveryCost setTextAlignment:NSTextAlignmentRight];
            NSString* shippingCost = [NSString stringWithFormat:@"%@",[[Utility sharedManager] convertToString:deliveryCost isCurrency:true symbolAtLast:isCurrencySymbolAtLast]];
            [labelDeliveryCost setText:shippingCost];
            [labelDeliveryCost setFrame:CGRectMake(view.frame.size.width/2 + 15, timeSelectionLabel.frame.origin.y, width - 10, fontHeight)];
        }
        
        
        NSArray* pTitlesArray = [dict objectForKey:@"pTitles"];
        NSString* pTitles = @"";
        int ii = 0;
        for (NSString* pT in pTitlesArray) {
            if (ii == 0) {
                pTitles = [NSString stringWithFormat:@"%@", pT];
            } else {
                pTitles = [NSString stringWithFormat:@"%@, %@", pTitles, pT];
            }
            ii++;
        }
        
        UILabel* labelProductsName= [[UILabel alloc] initWithFrame:CGRectMake(leftItemsPosX + spacingIconX, itemPosY, view.frame.size.width - leftItemsPosX * 2 - spacingIconX * 2, fontHeight)];
        [labelProductsName setUIFont:kUIFontType14 isBold:false];
        fontHeight = [[labelProductsName font] lineHeight];
        [labelProductsName setTextColor:[Utility getUIColor:kUIColorFontLight]];
        [view addSubview:labelProductsName];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [labelProductsName setTextAlignment:NSTextAlignmentRight];
        } else {
            [labelProductsName setTextAlignment:NSTextAlignmentLeft];
        }
        [labelProductsName setText:pTitles];
        [labelProductsName setNumberOfLines:0];
        [labelProductsName setLineBreakMode:NSLineBreakByWordWrapping];
        [labelProductsName sizeToFitUI];
        itemPosY += (fontHeight + labelProductsName.frame.size.height);
//        labelProductsName.layer.borderWidth = 1;
    }
    
    
    
    
    
    [view setFrame:CGRectMake(self.view.frame.size.width * 0.01f, 0, self.view.frame.size.width * 0.98f, itemPosY)];
    
    for (UIButton* button in _chkBoxShipping) {
        if (button.isSelected) {
            [self chkBoxShippingClicked:button];
        }
    }
    if ((int)[_chkBoxShipping count] == 1) {
        UIButton* button = (UIButton*)[_chkBoxShipping objectAtIndex:0];
        [button setSelected:true];
        [self chkBoxShippingClicked:button];
    }
    return view;
}
- (UIView*)createTaxView {
    
    UILabel* labelTemp= [[UILabel alloc] init];
    [labelTemp setUIFont:kUIFontType24 isBold:false];
    UIView* view = [[UIView alloc] init];
    if (_taxView == nil) {
        _taxView = view;
        [_scrollView addSubview:view];
        [_viewsAdded addObject:view];
        [view setTag:kTagForGlobalSpacing];
    } else {
        view =_taxView;
        NSArray* subviewss = [_taxView subviews];
        for (UIView* v in subviewss) {
            [v removeFromSuperview];
        }
    }
    
    [view setFrame:CGRectMake(self.view.frame.size.width * 0.01f, 0, self.view.frame.size.width * 0.98f, [[labelTemp font] lineHeight] * 10)];
    
    float leftItemsPosX = self.view.frame.size.width * 0.10f;
    float rightItemsPosX = self.view.frame.size.width * 0.50f;
    float itemPosY = self.view.frame.size.width * 0.04f;
    float width = view.frame.size.width * .40f;
    
    [view setBackgroundColor:[UIColor whiteColor]];
    //    [view.layer setBorderColor:[[Utility getUIColor:kUIColorBorder] CGColor]];
    //    [view.layer setBorderWidth:1];
    
    float fontHeight = 0;
    
    [view addSubview:[self addBorder:view]];
    
    
    for (TM_TaxApplied* tax in [TM_TaxApplied getAllTaxesApplied]) {
        if (tax.netTax <= 0) {
            continue;
        }
        
        UILabel* labelAmountColon= [[UILabel alloc] init];
        [labelAmountColon setUIFont:kUIFontType17 isBold:false];
        fontHeight = [[labelAmountColon font] lineHeight];
        float taxCost = tax.netTax;//[self calculateChargeFromTax:[self calculateGrandTotalWithoutTax] tax:tax];
        double taxRate = tax.rate;
        NSString* taxTitle = [NSString stringWithFormat:@"%@ (%.2f%%)", tax.name, taxRate];
        
        UIButton* button = [[UIButton alloc] init];
//        button.frame = CGRectMake(leftItemsPosX + 0, itemPosY,rightItemsPosX- leftItemsPosX-10, fontHeight);
        button.frame = CGRectMake(view.frame.size.width/2 - width, itemPosY, width, fontHeight);
        button.userInteractionEnabled = false;
        [view addSubview:button];
        [button setTitle:taxTitle forState:UIControlStateNormal];
        [button setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        button.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [button setTitleColor:[Utility getUIColor:kUIColorFontLight] forState:UIControlStateNormal];
        [button setTitleColor:[Utility getUIColor:kUIColorFontLight] forState:UIControlStateSelected];
        [button.titleLabel setUIFont:kUIFontType17 isBold:true];
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        
        UILabel* tempLabel = [[UILabel alloc] initWithFrame:button.frame];
        [tempLabel setUIFont:kUIFontType18 isBold:true];
        tempLabel.text = taxTitle;
        tempLabel.lineBreakMode = NSLineBreakByWordWrapping;
        tempLabel.numberOfLines = 0;
        [tempLabel sizeToFitUI];
        button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        button.titleLabel.numberOfLines = 0;
        [button.titleLabel sizeToFitUI];
        [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        CGRect btnR = button.frame;
        btnR.size.height = button.titleLabel.frame.size.height;
        button.frame = btnR;
        
        CGRect btnsize = button.frame;
        btnsize.size.height = button.titleLabel.frame.size.height;
        button.frame = btnsize;
        //            button.layer.borderWidth = 1;
        //////////////////////////Amount//////////////////////////
        
        [labelAmountColon setFrame:CGRectMake(rightItemsPosX, button.frame.origin.y, width, fontHeight)];
        [labelAmountColon setTextColor:[Utility getUIColor:kUIColorFontLight]];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [labelAmountColon setTextAlignment:NSTextAlignmentRight];
        } else {
            [labelAmountColon setTextAlignment:NSTextAlignmentLeft];
        }
        [labelAmountColon setText:@":"];
        [labelAmountColon sizeToFitUI];
        [view addSubview:labelAmountColon];
        
        [labelAmountColon setFrame:CGRectMake(labelAmountColon.frame.origin.x, button.frame.origin.y, labelAmountColon.frame.size.width, fontHeight)];
        
        
        
        UILabel* labelAmount= [[UILabel alloc] init];
        [labelAmount setUIFont:kUIFontType17 isBold:true];
        fontHeight = [[labelAmount font] lineHeight];
        [labelAmount setTextColor:[Utility getUIColor:kUIColorFontLight]];
        [view addSubview:labelAmount];
        NSString* shippingCost = [NSString stringWithFormat:@"%@",[[Utility sharedManager] convertToString:taxCost isCurrency:true symbolAtLast:isCurrencySymbolAtLast]];
        [labelAmount setText:shippingCost];
        [labelAmount setFrame:CGRectMake(view.frame.size.width/2 + 15, button.frame.origin.y, width - 10, fontHeight)];
//        if (isCurrencySymbolAtLast) {
//            if ([[TMLanguage sharedManager] isRTLEnabled]) {
//                [labelAmount setFrame:CGRectMake(rightItemsPosX + leftItemsPosX, button.frame.origin.y, width, fontHeight)];
                [labelAmount setTextAlignment:NSTextAlignmentRight];
//            } else {
//                [labelAmount setFrame:CGRectMake(rightItemsPosX - leftItemsPosX, button.frame.origin.y, width, fontHeight)];
//                [labelAmount setTextAlignment:NSTextAlignmentRight];
//            }
//        } else {
//            [labelAmount setFrame:CGRectMake(rightItemsPosX + leftItemsPosX, button.frame.origin.y, width, fontHeight)];
//            if ([[TMLanguage sharedManager] isRTLEnabled]) {
//                [labelAmount setTextAlignment:NSTextAlignmentRight];
//            } else {
//                [labelAmount setTextAlignment:NSTextAlignmentLeft];
//            }
//        }
        itemPosY += (fontHeight + button.frame.size.height);
    }
    
    
//    itemPosY += fontHeight;
    [view setFrame:CGRectMake(self.view.frame.size.width * 0.01f, 0, self.view.frame.size.width * 0.98f, itemPosY)];
    
    return view;
}
- (UIView*)createAppliedCouponView {
    
    UILabel* labelTemp= [[UILabel alloc] init];
    [labelTemp setUIFont:kUIFontType24 isBold:false];
    UIView* view = [[UIView alloc] init];
    [view setFrame:CGRectMake(self.view.frame.size.width * 0.01f, 0, self.view.frame.size.width * 0.98f, [[labelTemp font] lineHeight] * 10)];
    
    float leftItemsPosX = self.view.frame.size.width * 0.10f;
    float rightItemsPosX = self.view.frame.size.width * 0.50f;
    float itemPosY = self.view.frame.size.width * 0.04f;
    float width = view.frame.size.width * .50f;
    
    [view setBackgroundColor:[UIColor whiteColor]];
    //    [view.layer setBorderColor:[[Utility getUIColor:kUIColorBorder] CGColor]];
    //    [view.layer setBorderWidth:1];
    [_scrollView addSubview:view];
    [_viewsAdded addObject:view];
    [view setTag:kTagForGlobalSpacing];
    float fontHeight = 0;
    
    [view addSubview:[self addBorder:view]];
    
    
    for (AppliedCoupon* appliedCoupon in [[CartMeta sharedInstance] getAppliedCoupons]) {
        UILabel* labelAmountColon= [[UILabel alloc] init];
        [labelAmountColon setUIFont:kUIFontType18 isBold:false];
        fontHeight = [[labelAmountColon font] lineHeight];
        float discountAmount = appliedCoupon.discount_amount;
        NSString* couponTitle = [NSString stringWithFormat:@"%@", appliedCoupon.title];
        
        UIButton* button = [[UIButton alloc] init];
        button.frame = CGRectMake(leftItemsPosX + 0, itemPosY,rightItemsPosX- leftItemsPosX-10, fontHeight);
        button.userInteractionEnabled = false;
        [view addSubview:button];
        [button setTitle:couponTitle forState:UIControlStateNormal];
        [button setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        button.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [button setTitleColor:[Utility getUIColor:kUIColorFontLight] forState:UIControlStateNormal];
        [button setTitleColor:[Utility getUIColor:kUIColorFontLight] forState:UIControlStateSelected];
        [button.titleLabel setUIFont:kUIFontType18 isBold:true];
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        
        UILabel* tempLabel = [[UILabel alloc] initWithFrame:button.frame];
        [tempLabel setUIFont:kUIFontType18 isBold:true];
        tempLabel.text = couponTitle;
        tempLabel.lineBreakMode = NSLineBreakByWordWrapping;
        tempLabel.numberOfLines = 0;
        [tempLabel sizeToFitUI];
        button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        button.titleLabel.numberOfLines = 0;
        [button.titleLabel sizeToFitUI];
        [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        CGRect btnR = button.frame;
        btnR.size.height = button.titleLabel.frame.size.height;
        button.frame = btnR;
        
        CGRect btnsize = button.frame;
        btnsize.size.height = button.titleLabel.frame.size.height;
        button.frame = btnsize;
        //            button.layer.borderWidth = 1;
        //////////////////////////Amount//////////////////////////
        
        [labelAmountColon setFrame:CGRectMake(rightItemsPosX, button.frame.origin.y, width, fontHeight)];
        [labelAmountColon setTextColor:[Utility getUIColor:kUIColorFontLight]];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [labelAmountColon setTextAlignment:NSTextAlignmentRight];
        } else {
            [labelAmountColon setTextAlignment:NSTextAlignmentLeft];
        }
        [labelAmountColon setText:@":"];
        [labelAmountColon sizeToFitUI];
        [view addSubview:labelAmountColon];
        
        [labelAmountColon setFrame:CGRectMake(labelAmountColon.frame.origin.x, button.frame.origin.y, labelAmountColon.frame.size.width, fontHeight)];
        
        
        
        UILabel* labelAmount= [[UILabel alloc] init];
        [labelAmount setUIFont:kUIFontType18 isBold:true];
        fontHeight = [[labelAmount font] lineHeight];
        [labelAmount setTextColor:[Utility getUIColor:kUIColorFontLight]];
        [view addSubview:labelAmount];
        NSString* shippingCost = [NSString stringWithFormat:@"- %@",[[Utility sharedManager] convertToString:discountAmount isCurrency:true symbolAtLast:isCurrencySymbolAtLast]];
        [labelAmount setText:shippingCost];
        if (isCurrencySymbolAtLast) {
            if ([[TMLanguage sharedManager] isRTLEnabled]) {
                [labelAmount setFrame:CGRectMake(rightItemsPosX + leftItemsPosX, button.frame.origin.y, width, fontHeight)];
                [labelAmount setTextAlignment:NSTextAlignmentRight];
            } else {
                [labelAmount setFrame:CGRectMake(rightItemsPosX - leftItemsPosX, button.frame.origin.y, width, fontHeight)];
                [labelAmount setTextAlignment:NSTextAlignmentRight];
            }
        } else {
            [labelAmount setFrame:CGRectMake(rightItemsPosX + leftItemsPosX, button.frame.origin.y, width, fontHeight)];
            if ([[TMLanguage sharedManager] isRTLEnabled]) {
                [labelAmount setTextAlignment:NSTextAlignmentRight];
            } else {
                [labelAmount setTextAlignment:NSTextAlignmentLeft];
            }
        }
        
        itemPosY += (fontHeight + button.frame.size.height);
    }
    
    
//    itemPosY += fontHeight;
    [view setFrame:CGRectMake(self.view.frame.size.width * 0.01f, 0, self.view.frame.size.width * 0.98f, itemPosY)];
    
    return view;
}
- (UIView*)createFeeDataView {
    UILabel* labelTemp= [[UILabel alloc] init];
    [labelTemp setUIFont:kUIFontType24 isBold:false];
    UIView* view = [[UIView alloc] init];
    if (_feeView == nil) {
        _feeView = view;
        [_scrollView addSubview:view];
        [_viewsAdded addObject:view];
        [view setTag:kTagForGlobalSpacing];
    } else {
        view =_feeView;
        NSArray* subviewss = [_feeView subviews];
        for (UIView* v in subviewss) {
            [v removeFromSuperview];
        }
    }
    [view setFrame:CGRectMake(self.view.frame.size.width * 0.01f, 0, self.view.frame.size.width * 0.98f, [[labelTemp font] lineHeight] * 10)];
    float leftItemsPosX = self.view.frame.size.width * 0.10f;
    float rightItemsPosX = self.view.frame.size.width * 0.50f;
    float itemPosY = self.view.frame.size.width * 0.04f;
    float width = view.frame.size.width * .50f;
    [view setBackgroundColor:[UIColor whiteColor]];
//    [_scrollView addSubview:view];
//    [_viewsAdded addObject:view];
//    [view setTag:kTagForGlobalSpacing];
    float fontHeight = 0;
    [view addSubview:[self addBorder:view]];
    
    for (FeeData* feeData in [FeeData getAllFeeData]) {
        UILabel* labelAmountColon= [[UILabel alloc] init];
        [labelAmountColon setUIFont:kUIFontType18 isBold:false];
        fontHeight = [[labelAmountColon font] lineHeight];
        float feeAmount = feeData.cost;
        NSString* feeTitle = [NSString stringWithFormat:@"%@", feeData.label];
        
        UIButton* button = [[UIButton alloc] init];
        button.frame = CGRectMake(leftItemsPosX + 0, itemPosY,rightItemsPosX- leftItemsPosX-10, fontHeight);
        button.userInteractionEnabled = false;
        [view addSubview:button];
        [button setTitle:feeTitle forState:UIControlStateNormal];
        [button setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        button.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [button setTitleColor:[Utility getUIColor:kUIColorFontLight] forState:UIControlStateNormal];
        [button setTitleColor:[Utility getUIColor:kUIColorFontLight] forState:UIControlStateSelected];
        [button.titleLabel setUIFont:kUIFontType18 isBold:true];
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        
        UILabel* tempLabel = [[UILabel alloc] initWithFrame:button.frame];
        [tempLabel setUIFont:kUIFontType18 isBold:true];
        tempLabel.text = feeTitle;
        tempLabel.lineBreakMode = NSLineBreakByWordWrapping;
        tempLabel.numberOfLines = 0;
        [tempLabel sizeToFitUI];
        button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        button.titleLabel.numberOfLines = 0;
        [button.titleLabel sizeToFitUI];
        [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        CGRect btnR = button.frame;
        btnR.size.height = button.titleLabel.frame.size.height;
        button.frame = btnR;
        
        CGRect btnsize = button.frame;
        btnsize.size.height = button.titleLabel.frame.size.height;
        button.frame = btnsize;
        //            button.layer.borderWidth = 1;
        //////////////////////////Amount//////////////////////////
        
        [labelAmountColon setFrame:CGRectMake(rightItemsPosX, button.frame.origin.y, width, fontHeight)];
        [labelAmountColon setTextColor:[Utility getUIColor:kUIColorFontLight]];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [labelAmountColon setTextAlignment:NSTextAlignmentRight];
        } else {
            [labelAmountColon setTextAlignment:NSTextAlignmentLeft];
        }
        [labelAmountColon setText:@":"];
        [labelAmountColon sizeToFitUI];
        [view addSubview:labelAmountColon];
        
        [labelAmountColon setFrame:CGRectMake(labelAmountColon.frame.origin.x, button.frame.origin.y, labelAmountColon.frame.size.width, fontHeight)];
        
        
        
        UILabel* labelAmount= [[UILabel alloc] init];
        [labelAmount setUIFont:kUIFontType18 isBold:true];
        fontHeight = [[labelAmount font] lineHeight];
        [labelAmount setTextColor:[Utility getUIColor:kUIColorFontLight]];
        [view addSubview:labelAmount];
        NSString* shippingCost = [NSString stringWithFormat:@"%@",[[Utility sharedManager] convertToString:feeAmount isCurrency:true symbolAtLast:isCurrencySymbolAtLast]];
        [labelAmount setText:shippingCost];
        if (isCurrencySymbolAtLast) {
            if ([[TMLanguage sharedManager] isRTLEnabled]) {
                [labelAmount setFrame:CGRectMake(rightItemsPosX + leftItemsPosX, button.frame.origin.y, width, fontHeight)];
                [labelAmount setTextAlignment:NSTextAlignmentRight];
            } else {
                [labelAmount setFrame:CGRectMake(rightItemsPosX - leftItemsPosX, button.frame.origin.y, width, fontHeight)];
                [labelAmount setTextAlignment:NSTextAlignmentRight];
            }
        } else {
            [labelAmount setFrame:CGRectMake(rightItemsPosX + leftItemsPosX, button.frame.origin.y, width, fontHeight)];
            if ([[TMLanguage sharedManager] isRTLEnabled]) {
                [labelAmount setTextAlignment:NSTextAlignmentRight];
            } else {
                [labelAmount setTextAlignment:NSTextAlignmentLeft];
            }
        }
        
        itemPosY += (fontHeight + button.frame.size.height);
    }
    [view setFrame:CGRectMake(self.view.frame.size.width * 0.01f, 0, self.view.frame.size.width * 0.98f, itemPosY)];
    [self resetMainScrollView];
    return view;
}
- (UIView*)createGrandTotalView {
    NSString* stringGrandAmountH = [NSString stringWithFormat:Localize(@"i_grand_total")];
    NSString* stringGrandAmount = [NSString stringWithFormat:@"%@",[[Utility sharedManager] convertToString:/*[Cart getTotalPayment]//rr*/[self calculateGrandTotal] isCurrency:true symbolAtLast:isCurrencySymbolAtLast]];
    
    UILabel* labelTemp= [[UILabel alloc] init];
    [labelTemp setUIFont:kUIFontType24 isBold:false];
    UIView* view = [[UIView alloc] init];
    [view setFrame:CGRectMake(self.view.frame.size.width * 0.01f, 0, self.view.frame.size.width * 0.98f, [[labelTemp font] lineHeight] * 10)];
    
    float leftItemsPosX = self.view.frame.size.width * 0.10f;
    float rightItemsPosX = self.view.frame.size.width * 0.50f;
    float itemPosY = self.view.frame.size.width * 0.04f;
    float width = view.frame.size.width * .50f;
    
    [view setBackgroundColor:[UIColor whiteColor]];
    //    [view.layer setBorderColor:[[Utility getUIColor:kUIColorBorder] CGColor]];
    //    [view.layer setBorderWidth:1];
    [_scrollView addSubview:view];
    [_viewsAdded addObject:view];
    [view setTag:kTagForGlobalSpacing];
    float fontHeight = 0;
    
    [view addSubview:[self addBorder:view]];
    
    
    UILabel* labelGrandAmountH= [[UILabel alloc] init];
    [labelGrandAmountH setUIFont:kUIFontType18 isBold:true];
    fontHeight = [[labelGrandAmountH font] lineHeight];
    [labelGrandAmountH setFrame:CGRectMake(leftItemsPosX, itemPosY, width, fontHeight)];
    [labelGrandAmountH setTextColor:[Utility getUIColor:kUIColorFontDark]];
    [labelGrandAmountH setText:stringGrandAmountH];
    labelGrandAmountH.lineBreakMode = NSLineBreakByWordWrapping;
    labelGrandAmountH.numberOfLines = 0;
    [labelGrandAmountH sizeToFitUI];
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        [labelGrandAmountH setTextAlignment:NSTextAlignmentRight];
    } else {
        [labelGrandAmountH setTextAlignment:NSTextAlignmentLeft];
    }
    [view addSubview:labelGrandAmountH];
    
    UILabel* labelGrandColon= [[UILabel alloc] init];
    [labelGrandColon setUIFont:kUIFontType18 isBold:false];
    fontHeight = [[labelGrandColon font] lineHeight];
    [labelGrandColon setFrame:CGRectMake(rightItemsPosX, itemPosY, width, fontHeight)];
    [labelGrandColon setTextColor:[Utility getUIColor:kUIColorFontDark]];
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        [labelGrandColon setTextAlignment:NSTextAlignmentRight];
    } else {
        [labelGrandColon setTextAlignment:NSTextAlignmentLeft];
    }
    [labelGrandColon setText:@":"];
    [labelGrandColon sizeToFitUI];
    [view addSubview:labelGrandColon];
    
    
    _labelGrandAmount= [[UILabel alloc] init];
    [_labelGrandAmount setUIFont:kUIFontType18 isBold:true];
    fontHeight = [[_labelGrandAmount font] lineHeight];
    [_labelGrandAmount setTextColor:[Utility getUIColor:kUIColorFontDark]];
    [_labelGrandAmount setText:stringGrandAmount];
    [view addSubview:_labelGrandAmount];
    if (isCurrencySymbolAtLast) {
        [_labelGrandAmount setFrame:CGRectMake(rightItemsPosX - leftItemsPosX, itemPosY, width, fontHeight)];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [_labelGrandAmount setFrame:CGRectMake(rightItemsPosX + leftItemsPosX, itemPosY, width, fontHeight)];
            [_labelGrandAmount setTextAlignment:NSTextAlignmentRight];
        } else {
            [_labelGrandAmount setTextAlignment:NSTextAlignmentRight];
        }
    } else {
        [_labelGrandAmount setFrame:CGRectMake(rightItemsPosX + leftItemsPosX, itemPosY, width, fontHeight)];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [_labelGrandAmount setTextAlignment:NSTextAlignmentRight];
        } else {
            [_labelGrandAmount setTextAlignment:NSTextAlignmentLeft];
        }
    }
    
    
    itemPosY += (fontHeight + labelGrandAmountH.frame.size.height);
//    itemPosY += fontHeight;

    [view setFrame:CGRectMake(self.view.frame.size.width * 0.01f, 0, self.view.frame.size.width * 0.98f, itemPosY)];
    
    if ([[Addons sharedManager] hide_price]) {
        [view setFrame:CGRectMake(self.view.frame.size.width * 0.01f, 0, self.view.frame.size.width * 0.98f, 0)];
    } else {
        
    }
    for (NSMutableArray* _chkBoxShipping in _chkBoxShippingOuterArray) {
        for (UIButton* button in _chkBoxShipping) {
            if (button.isSelected) {
                [self chkBoxShippingClicked:button];
            }
        }
        if ((int)[_chkBoxShipping count] == 1) {
            UIButton* button = (UIButton*)[_chkBoxShipping objectAtIndex:0];
            [button setSelected:true];
            [self chkBoxShippingClicked:button];
        }
    }
    
    
    return view;
}
- (UIView*)createPaymentOptionView {
    UILabel* labelTemp= [[UILabel alloc] init];
    [labelTemp setUIFont:kUIFontType24 isBold:false];
    UIView* view = [[UIView alloc] init];
    [view setFrame:CGRectMake(self.view.frame.size.width * 0.01f, 0, self.view.frame.size.width * 0.98f, [[labelTemp font] lineHeight] * 10)];
    float leftItemsPosX = self.view.frame.size.width * 0.10f;
    float itemPosY = self.view.frame.size.width * 0.04f;
    float width = view.frame.size.width * .80f;
    [view setBackgroundColor:[UIColor whiteColor]];
    [_scrollView addSubview:view];
    [_viewsAdded addObject:view];
    [view setTag:kTagForGlobalSpacing];
    float fontHeight = [[labelTemp font] lineHeight];
    [view addSubview:[self addBorder:view]];
    TMPaymentSDK* tmPaymentSDK = [[DataManager sharedManager] tmPaymentSDK];
    if(tmPaymentSDK.paymentGateways) {
        for (TMPaymentGateway* paymentGateway in tmPaymentSDK.paymentGateways) {
            NSString* paymentTitle = paymentGateway.paymentTitle;
            NSString* localizePaymentTitle = Localize(paymentGateway.paymentId);
            if (![paymentGateway.paymentId isEqualToString:localizePaymentTitle] &&
                ![localizePaymentTitle isEqualToString:@""]) {
                paymentTitle = localizePaymentTitle;
            }
            if (paymentGateway.gatewaySettings) {
                float paymentCharges = [paymentGateway.gatewaySettings.extraCharges floatValue];
                NSString* paymentChargesStr = [NSString stringWithFormat:@"%@",[[Utility sharedManager] convertToString:paymentCharges isCurrency:true symbolAtLast:false]];
                NSString* paymentChargesMsgStr = paymentGateway.gatewaySettings.extraChargesMessage;
                
               paymentTitle = [NSString stringWithFormat:@"%@ (%@ - %@)", paymentTitle, paymentChargesMsgStr, paymentChargesStr];
            }
            if ([paymentTitle isEqualToString:@""]) {
                paymentTitle = @"  ";
            }
            BOOL paymentEnabled = paymentGateway.isPaymentEnabled;
            BOOL paymentGatewayChosed = paymentGateway.isPaymentGatewayChoosen;
            UIButton* button = [[UIButton alloc] init];
            button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
            button.titleLabel.numberOfLines = 0;
            button.frame = CGRectMake(leftItemsPosX, itemPosY, view.frame.size.width *.98 - (leftItemsPosX), fontHeight);
            [button addTarget:self action:@selector(chkBoxPaymentClicked:) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:button];
            [button setUIImage:[UIImage imageNamed:@"radiobtn_unselected"] forState:UIControlStateNormal];
            [button setUIImage:[UIImage imageNamed:@"radiobtn_selected"] forState:UIControlStateSelected];
            NSString * htmlString = paymentTitle;
            NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
            [button setTitle:[NSString stringWithFormat:@"%@", attrStr.string] forState:UIControlStateNormal];
            [button setImageEdgeInsets:UIEdgeInsetsMake(5, 0, 0, 0)];
            if ([[MyDevice sharedManager] isIphone]) {
                [button setImageEdgeInsets:UIEdgeInsetsMake(3, 0, 0, 0)];
            }
            button.imageView.contentMode = UIViewContentModeScaleAspectFit;
            [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
            [button setTitleColor:[Utility getUIColor:kUIColorFontLight] forState:UIControlStateNormal];
            [button setTitleColor:[Utility getUIColor:kUIColorFontLight] forState:UIControlStateSelected];
            [button.titleLabel setUIFont:kUIFontType18 isBold:false];
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            button.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
            [button.layer setValue:paymentGateway forKey:@"MY_OBJECT"];
            [_chkBoxPayment addObject:button];
            if (paymentEnabled == false) {
                [button setEnabled:false];
            }
            if (paymentGatewayChosed) {
                [button setSelected:true];
            }
            [button.titleLabel sizeToFitUI];
            CGRect btnsize = button.frame;
            btnsize.size.height = button.titleLabel.frame.size.height + fontHeight/4;
            button.frame = btnsize;
            itemPosY += (fontHeight * 0.5f + button.frame.size.height);
        }
        if ([tmPaymentSDK.paymentGateways count] == 0) {
            UILabel* labelGrandAmountH = [[UILabel alloc] init];
            [labelGrandAmountH setUIFont:kUIFontType18 isBold:false];
            fontHeight = [[labelGrandAmountH font] lineHeight];
            [labelGrandAmountH setFrame:CGRectMake(self.view.frame.size.width * 0.02f, itemPosY, view.frame.size.width - self.view.frame.size.width * 0.04f, fontHeight)];
            [labelGrandAmountH setTextColor:[Utility getUIColor:kUIColorFontLight]];
            [labelGrandAmountH setTextAlignment:NSTextAlignmentCenter];
            [view addSubview:labelGrandAmountH];
            [labelGrandAmountH setText:Localize(@"no_payments_available")];
            itemPosY+=(fontHeight * 2.0f);
        }
    }
    [view setFrame:CGRectMake(self.view.frame.size.width * 0.01f, 0, self.view.frame.size.width * 0.98f, itemPosY)];
    for (UIButton* button in _chkBoxPayment) {
        if (button.isSelected) {
            [self chkBoxPaymentClicked:button];
        }
    }
    if ((int)[_chkBoxPayment count] == 1) {
        UIButton* button = (UIButton*)[_chkBoxPayment objectAtIndex:0];
        [button setSelected:true];
        [self chkBoxPaymentClicked:button];
    }
    return view;
}
- (UIView*)createNotesView:(UITextView*)textView{
    OrderNote* orderNote = [[Addons sharedManager] orderNote];
    UILabel* labelTemp= [[UILabel alloc] init];
    [labelTemp setUIFont:kUIFontType24 isBold:false];
    UIView* view = [[UIView alloc] init];
    [view setFrame:CGRectMake(self.view.frame.size.width * 0.01f, 0, self.view.frame.size.width * 0.98f, [[labelTemp font] lineHeight] * 10)];
    //    float leftItemsPosX = self.view.frame.size.width * 0.10f;
    float itemPosY = self.view.frame.size.width * 0.02f;
    //    float width = view.frame.size.width * .80f;
    [view setBackgroundColor:[UIColor whiteColor]];
    [_scrollView addSubview:view];
    [_viewsAdded addObject:view];
    [view setTag:kTagForGlobalSpacing];
    float fontHeight = [[labelTemp font] lineHeight];
    [view addSubview:[self addBorder:view]];
    
    
    float textFieldPosX = self.view.frame.size.width * 0.02f;
    float textFieldPosY = self.view.frame.size.width * 0.02f;
    float textFieldWidth = view.frame.size.width - self.view.frame.size.width * 0.04f;
    float textFieldHeight = fontHeight;
    int fontType;
    if ([[MyDevice sharedManager] isIpad]) {
        fontType = kUIFontType18;
    } else {
        fontType = kUIFontType18;
    }
    
    
    UILabel* orderPlaceHolder = [[UILabel alloc] initWithFrame:CGRectMake(textFieldPosX, textFieldPosY, textFieldWidth, textFieldHeight)];
    [orderPlaceHolder setUIFont:fontType isBold:false];
    [orderPlaceHolder setTextColor:[Utility getUIColor:kUIColorFontLight]];
    if ([Localize(@"order_note_placeholder") isEqualToString:@"Order Note Placeholder"]) {
        [orderPlaceHolder setText:@""];
    } else {
        [orderPlaceHolder setText:Localize(@"order_note_placeholder")];
    }
    [orderPlaceHolder setNumberOfLines:0];
    [orderPlaceHolder setLineBreakMode:NSLineBreakByWordWrapping];
    [orderPlaceHolder sizeToFitUI];
    [view addSubview:orderPlaceHolder];
    if (orderPlaceHolder.frame.size.height != 0) {
        itemPosY = self.view.frame.size.width * 0.02f + CGRectGetMaxY(orderPlaceHolder.frame);
    }
    
    UILabel* tempLabel = [[UILabel alloc] init];
    [tempLabel setText:@"W"];
    [tempLabel setUIFont:fontType isBold:false];
    [tempLabel sizeToFit];
    int fontW = tempLabel.frame.size.width;
    int fontH = tempLabel.frame.size.height;
    
    CGRect rectTextView;
    int noteLineCount = orderNote.note_line_count;
    BOOL noteSingleLine = orderNote.note_single_line;
    if (noteSingleLine) {
        float maxWidthOrderPlaceHolder = textFieldWidth * .25f;
        if ([[MyDevice sharedManager] isIphone]) {
            maxWidthOrderPlaceHolder = textFieldWidth * .25f;
        }
        if (maxWidthOrderPlaceHolder < orderPlaceHolder.frame.size.width) {
            noteSingleLine = false;
        }else{
            textFieldPosX = CGRectGetMaxX(orderPlaceHolder.frame) + 5;
            itemPosY = CGRectGetMinY(orderPlaceHolder.frame);
            textFieldWidth = textFieldWidth - orderPlaceHolder.frame.size.width - 5;
        }
    }
    textFieldHeight = noteLineCount * fontH + 10;
    rectTextView = CGRectMake(textFieldPosX, itemPosY, textFieldWidth, textFieldHeight);
    switch (orderNote.note_char_type) {
        case ORDER_NOTE_CHAR_TYPE_ALPHANUMERIC:
            textView = [self createTextView:view fontType:fontType fontColorType:kUIColorFontDark frame:rectTextView tag:0 textStrPlaceHolder:Localize(@"order_note_placeholder") textView:textView];
            [textView setKeyboardType:UIKeyboardTypeDefault];
            [textView setAutocapitalizationType:UITextAutocapitalizationTypeNone];
            break;
        case ORDER_NOTE_CHAR_TYPE_NUMERIC:
            textView = [self createTextView:view fontType:fontType fontColorType:kUIColorFontDark frame:rectTextView tag:0 textStrPlaceHolder:Localize(@"order_note_placeholder") textView:textView];
            [textView setKeyboardType:UIKeyboardTypeDecimalPad];
            break;
            
        default:
            break;
    }
    if ([[MyDevice sharedManager] isIphone]) {
        UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
        numberToolbar.backgroundColor = [UIColor lightGrayColor];
        UIBarButtonItem* doneBtn = [[UIBarButtonItem alloc]initWithTitle:Localize(@"done") style:UIBarButtonItemStyleBordered target:self action:@selector(doneWithDeviceKeyPad:)];
        numberToolbar.items = @[
                                [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                doneBtn];
        [numberToolbar sizeToFit];
        textView.inputAccessoryView = numberToolbar;
    }
    
    itemPosY = self.view.frame.size.width * 0.02f + CGRectGetMaxY(textView.frame);
    
    [view setFrame:CGRectMake(self.view.frame.size.width * 0.01f, 0, self.view.frame.size.width * 0.98f, itemPosY)];
    return view;
}

- (void)doneWithDeviceKeyPad:(UIBarButtonItem*)button {
    if (_textViewFirstResponder) {
        [_textViewFirstResponder resignFirstResponder];
    }
}

//- (UIView*)createNotesView{
//    OrderNote* orderNote = [[Addons sharedManager] orderNote];
//    UILabel* labelTemp= [[UILabel alloc] init];
//    [labelTemp setUIFont:kUIFontType24 isBold:false];
//    UIView* view = [[UIView alloc] init];
//    [view setFrame:CGRectMake(self.view.frame.size.width * 0.01f, 0, self.view.frame.size.width * 0.98f, [[labelTemp font] lineHeight] * 10)];
//    float leftItemsPosX = self.view.frame.size.width * 0.10f;
//    float itemPosY = self.view.frame.size.width * 0.02f;
//    float width = view.frame.size.width * .80f;
//    [view setBackgroundColor:[UIColor whiteColor]];
//    [_scrollView addSubview:view];
//    [_viewsAdded addObject:view];
//    [view setTag:kTagForGlobalSpacing];
//    float fontHeight = [[labelTemp font] lineHeight];
//    [view addSubview:[self addBorder:view]];
//
//
//    float textFieldPosX = self.view.frame.size.width * 0.02f;
//    float textFieldPosY = self.view.frame.size.width * 0.02f;
//    float textFieldWidth = view.frame.size.width - self.view.frame.size.width * 0.04f;
//    float textFieldHeight = fontHeight;
//    int fontType;
//    if ([[MyDevice sharedManager] isIpad]) {
//        fontType = kUIFontType18;
//    } else {
//        fontType = kUIFontType24;
//    }
//
//
//    UILabel* orderPlaceHolder = [[UILabel alloc] initWithFrame:CGRectMake(textFieldPosX, textFieldPosY, textFieldWidth, textFieldHeight)];
//    [orderPlaceHolder setUIFont:fontType isBold:false];
//    [orderPlaceHolder setTextColor:[Utility getUIColor:kUIColorFontLight]];
//    if ([Localize(@"order_note_placeholder") isEqualToString:@"Order Note Placeholder"]) {
//        [orderPlaceHolder setText:@""];
//    } else {
//        [orderPlaceHolder setText:Localize(@"order_note_placeholder")];
//    }
////    [orderPlaceHolder setText:Localize(@"Order Note Place")];//to remove
//    [orderPlaceHolder setNumberOfLines:0];
//    [orderPlaceHolder setLineBreakMode:NSLineBreakByWordWrapping];
//    [orderPlaceHolder sizeToFitUI];
//    [view addSubview:orderPlaceHolder];
//    itemPosY += CGRectGetMaxY(orderPlaceHolder.frame);
//
//
//
//    UILabel* tempLabel = [[UILabel alloc] init];
//    [tempLabel setText:@"W"];
//    [tempLabel setUIFont:fontType isBold:false];
//    [tempLabel sizeToFit];
//    int fontW = tempLabel.frame.size.width;
//    int fontH = tempLabel.frame.size.height;
//
//    CGRect rectTextView;
//    int noteLineCount = orderNote.note_line_count;
//    BOOL noteSingleLine = orderNote.note_single_line;
//    noteSingleLine = true; //to remove
//    if (noteSingleLine) {
//        float maxWidthOrderPlaceHolder = textFieldWidth * .25f;
//        if ([[MyDevice sharedManager] isIphone]) {
//            maxWidthOrderPlaceHolder = textFieldWidth * .25f;
//        }
//        if (maxWidthOrderPlaceHolder < orderPlaceHolder.frame.size.width) {
//            noteSingleLine = false;
//        }else{
//            textFieldPosX = CGRectGetMaxX(orderPlaceHolder.frame) + 5;
//            itemPosY = CGRectGetMinY(orderPlaceHolder.frame);
//            textFieldWidth = textFieldWidth - orderPlaceHolder.frame.size.width - 5;
//            orderPlaceHolder.layer.borderWidth = 1;
//        }
//    }
//    textFieldHeight = noteLineCount * fontH + 10;
//    rectTextView = CGRectMake(textFieldPosX, itemPosY, textFieldWidth, textFieldHeight);
//    switch (orderNote.note_char_type) {
//        case ORDER_NOTE_CHAR_TYPE_ALPHANUMERIC:
//            _textView = [self createTextView:view fontType:fontType fontColorType:kUIColorFontDark frame:rectTextView tag:0 textStrPlaceHolder:Localize(@"order_note_placeholder")];
//            [_textView setKeyboardType:UIKeyboardTypeDefault];
//            [_textView setAutocapitalizationType:UITextAutocapitalizationTypeNone];
//            break;
//        case ORDER_NOTE_CHAR_TYPE_NUMERIC:
//            _textView = [self createTextView:view fontType:fontType fontColorType:kUIColorFontDark frame:rectTextView tag:0 textStrPlaceHolder:Localize(@"order_note_placeholder")];
//            [_textView setKeyboardType:UIKeyboardTypeDecimalPad];
//            break;
//
//        default:
//            break;
//    }
//    itemPosY = self.view.frame.size.width * 0.02f + CGRectGetMaxY(_textView.frame);
//
//    [view setFrame:CGRectMake(self.view.frame.size.width * 0.01f, 0, self.view.frame.size.width * 0.98f, itemPosY)];
//    return view;
//}
#pragma mark TextView
- (UITextView*)createTextView:(UIView*)parentView fontType:(int)fontType fontColorType:(int)fontColorType frame:(CGRect)frame tag:(int)tag textStrPlaceHolder:(NSString*)textStrPlaceHolder textView:(UITextView*)textView{
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
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    _textViewFirstResponder = textView;
    return YES;
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    return YES;
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    OrderNote* orderNote = [[Addons sharedManager] orderNote];
    if (orderNote.note_char_limit != -1) {
        return textView.text.length + (text.length - range.length) <= orderNote.note_char_limit;
    }
    return YES;
}
#pragma mark other methods
- (void)chkBoxCheckoutAddonClicked:(id)sender {
    UIButton* senderButton = (UIButton*)sender;
    if ([senderButton isSelected] == YES) {
        [senderButton setSelected:NO];
        UILabel* label = (UILabel*)[senderButton.layer valueForKey:@"MY_COST_LABEL"];
        [label setTextColor:[Utility getUIColor:kUIColorFontLight]];
        [label setUIFont:kUIFontType18 isBold:false];
        [senderButton.titleLabel setUIFont:kUIFontType18 isBold:false];
    } else {
        [senderButton setSelected:YES];
        UILabel* label = (UILabel*)[senderButton.layer valueForKey:@"MY_COST_LABEL"];
        [label setTextColor:[Utility getUIColor:kUIColorFontLight]];
        [label setUIFont:kUIFontType17 isBold:true];
        [senderButton.titleLabel setUIFont:kUIFontType17 isBold:true];
    }
    NSString* stringGrandAmount = [NSString stringWithFormat:@"%@",[[Utility sharedManager] convertToString:[self calculateGrandTotal] isCurrency:true symbolAtLast:isCurrencySymbolAtLast]];
    [_labelGrandAmount setText:stringGrandAmount];
}
- (void)chkBoxShippingClicked:(id)sender {
    UIButton* senderButton = (UIButton*)sender;
    NSMutableArray* _chkBoxShipping = [senderButton.layer valueForKey:@"CHK_BOX_SHIPPING"];
    if([senderButton isSelected] == YES) {
        
    } else {
        [senderButton setSelected:YES];
        for (UIButton* button in _chkBoxShipping) {
            if(button != senderButton){
                [button setSelected:NO];
                UILabel* label = (UILabel*)[button.layer valueForKey:@"MY_COST_LABEL"];
                UILabel* labelColon = (UILabel*)[button.layer valueForKey:@"MY_COST_LABEL_COLON"];
                [label setTextColor:[Utility getUIColor:kUIColorFontLight]];
                [label setUIFont:kUIFontType18 isBold:false];
                [button.titleLabel setUIFont:kUIFontType18 isBold:false];
            }
        }
    }
    if ([senderButton isSelected]) {
        NSNumber* buttonIndex = (NSNumber*)[senderButton.layer valueForKey:@"MY_INDEX"];
        int myIndex = [buttonIndex intValue];
        TMShipping* shpMthd = (TMShipping*)[senderButton.layer valueForKey:@"MY_OBJECT"];
        if (myIndex == -1) {
            if ([_selectedShippingMethod count] == 0) {
                [_selectedShippingMethod insertObject:shpMthd atIndex:0];
            } else {
                [_selectedShippingMethod replaceObjectAtIndex:0 withObject:shpMthd];
            }
        } else {
            if (myIndex+1 > [_selectedShippingMethod count]) {
                [_selectedShippingMethod insertObject:shpMthd atIndex:myIndex];
            } else {
                [_selectedShippingMethod replaceObjectAtIndex:myIndex withObject:shpMthd];
            }
        }
        
        
//        _selectedShippingMethod = (TMShipping*)[senderButton.layer valueForKey:@"MY_OBJECT"];
        UILabel* label = (UILabel*)[senderButton.layer valueForKey:@"MY_COST_LABEL"];
        UILabel* labelColon = (UILabel*)[senderButton.layer valueForKey:@"MY_COST_LABEL_COLON"];
        [label setTextColor:[Utility getUIColor:kUIColorFontLight]];
        [label setUIFont:kUIFontType17 isBold:true];
        [senderButton.titleLabel setUIFont:kUIFontType17 isBold:true];
        NSString* stringGrandAmount = [NSString stringWithFormat:@"%@",[[Utility sharedManager] convertToString:[self calculateGrandTotal] isCurrency:true symbolAtLast:isCurrencySymbolAtLast]];
        [_labelGrandAmount setText:stringGrandAmount];
        [self refreshBlankOrder];
    }
    
    
    
    //this code is not for single shipping selection and not for multiple shipping selection
    if (_selectedShippingMethod && [_selectedShippingMethod count] > 0 && [DateTimeSlot isShippingDependent]) {
        TMShipping* shpMthd0 = (TMShipping*)[_selectedShippingMethod objectAtIndex:0];
        NSString* previousSelectedShipping = _selectedShippingMethodId;
        _selectedShippingMethodId = shpMthd0.shippingMethodId;
        if (![previousSelectedShipping isEqualToString:_selectedShippingMethodId]) {
            [self resetDateSelectionView];
        }
    }
}
- (void)chkBoxPaymentClicked:(id)sender {
    UIButton* senderButton = (UIButton*)sender;
    if([senderButton isSelected] == YES) {
    } else {
        [senderButton setSelected:YES];
        for (UIButton* button in _chkBoxPayment) {
            if(button != senderButton){
                [button setSelected:NO];
                [button.titleLabel setUIFont:kUIFontType18 isBold:false];
            }
        }
    }
    if ([senderButton isSelected]) {
        _selectedPaymentGateway = (TMPaymentGateway*)[senderButton.layer valueForKey:@"MY_OBJECT"];
        [senderButton.titleLabel setUIFont:kUIFontType17 isBold:true];
        NSString* stringGrandAmount = [NSString stringWithFormat:@"%@",[[Utility sharedManager] convertToString:[self calculateGrandTotal] isCurrency:true symbolAtLast:isCurrencySymbolAtLast]];
        [_labelGrandAmount setText:stringGrandAmount];
    }
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
    ViewControllerAddress* vcAddress = (ViewControllerAddress*)[[Utility sharedManager] pushScreenWithoutAnimation:mainVC.vcCenterTop type:PUSH_SCREEN_TYPE_ADDRESS];
    RLOG(@"vcAddress = %@", vcAddress);
}
- (UIView*)addBorder:(UIView*)view{
    UIView* viewBorder = [[UIView alloc] init];
    [viewBorder setFrame:CGRectMake(0, 0, view.frame.size.width, 1)];
    [viewBorder setBackgroundColor:[Utility getUIColor:kUIColorBorder]];
    return viewBorder;
}
- (UIView*)addView:(int)listId pInfo:(ProductInfo*)pInfo isCartItem:(BOOL)isCartItem isWishlistItem:(BOOL)isWishlistItem quantity:(int)quantity {
    
    Cart* c = (Cart*)[[[AppUser sharedManager] _cartArray] objectAtIndex:listId];
    
    float fontHeight = 20;
    float padding = self.view.frame.size.width * 0.05f;
    float height = 0;
    if (listId == 0) {
        height = fontHeight;
    }
    float viewMaxWidth = self.view.frame.size.width * .98f;
    CGRect rect;
    UILabel* labelName = [[UILabel alloc] init];
    [labelName setFrame:CGRectMake(0, height, viewMaxWidth, labelName.frame.size.height)];
    [labelName setUIFont:kUIFontType18 isBold:false];
    [labelName setTextColor:[Utility getUIColor:kUIColorFontLight]];
    [labelName setText:pInfo._title];
    [labelName sizeToFitUI];
    [labelName setNumberOfLines:0];
    height += labelName.frame.size.height;
    rect = labelName.frame;
    rect.origin.x = padding;
    [labelName setFrame:rect];
    
    /////////////
    
    NSMutableString *properties = [NSMutableString string];
    int i = 0;
    for (BasicAttribute* basicAttribute in c.selected_attributes) {
        if (i > 0) {
            NSString* str = [NSString stringWithFormat:@",\n"];
            [properties appendString:str];
        }
        NSString* str = [NSString stringWithFormat:@"%@ - %@", basicAttribute.attributeName , basicAttribute.attributeValue];
        [properties appendString:str];
        i++;
    }
    if ([properties isEqualToString:@""]){
        [properties appendString:Localize(@"not_available")];
    }
    
    UILabel* labelProp = [[UILabel alloc] init];
    [labelProp setFrame:CGRectMake(0, height, viewMaxWidth, labelProp.frame.size.height)];
    [labelProp setUIFont:kUIFontType14 isBold:false];
    [labelProp setTextColor:[Utility getUIColor:kUIColorFontLight]];
    [labelProp setText:properties];
    [labelProp sizeToFitUI];
    [labelProp setNumberOfLines:0];
    height += labelProp.frame.size.height;
    rect = labelProp.frame;
    rect.origin.x = padding;
    [labelProp setFrame:rect];
    
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
    [labelPriceHeading setFrame:rect];
    
    ///////////
    BOOL isDiscounted = [pInfo isProductDiscounted:-1];
    float price = [pInfo getNewPrice:-1];
    float oldPrice = [pInfo getOldPrice:-1];
    
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
    rect.origin.x = viewMaxWidth - CGRectGetMaxX(labelPriceFinal.frame) - padding;
    [labelPriceFinal setFrame:rect];
    height += labelPriceFinal.frame.size.height;
    
    UIView* mainView = [[UIView alloc] init];
    [mainView setFrame:CGRectMake(0, 0, viewMaxWidth, height + fontHeight)];
    [mainView addSubview:labelName];
    if (labelProp) {
        [mainView addSubview:labelProp];
    }
    [mainView addSubview:labelPriceHeading];
    [mainView addSubview:labelPrice];
    [mainView addSubview:labelPriceFinal];
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

- (void)paymentCompletionWithSuccess:(id)obj {
    RLOG(@"paymentCompletionWithSuccess");
    _screen_current_state = SCREEN_STATE_PAYMENT_DONE;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateOrderSuccess:) name:@"UPDATE_ORDER_SUCCESS" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateOrderFailed:) name:@"UPDATE_ORDER_FAILURE" object:nil];
    if (
        [_selectedPaymentGateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_DBT]] ||
        [_selectedPaymentGateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_CHEQUE]] ||
        [_selectedPaymentGateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_JETPACK1]] ||
        [_selectedPaymentGateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_JETPACK2]] ||
        [_selectedPaymentGateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_JETPACK3]]
        ) {
        [[[DataManager sharedManager] tmDataDoctor] updateOrder:_selectedPaymentGateway orderId:_blankOrder._id orderStatus:@"on-hold" isPaid:false];
    }
    else if([_selectedPaymentGateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_COD]]) {
        [[[DataManager sharedManager] tmDataDoctor] updateOrder:_selectedPaymentGateway orderId:_blankOrder._id orderStatus:@"processing" isPaid:false];
    }
    else {
        [[[DataManager sharedManager] tmDataDoctor] updateOrder:_selectedPaymentGateway orderId:_blankOrder._id orderStatus:@"processing" isPaid:true];
    }
}
- (void)paymentCompletionWithFailure:(id)obj {
    RLOG(@"paymentCompletionWithFailure");
    if (obj!=nil && [obj isKindOfClass:[NSString class]] && [obj isEqualToString:@"not_implemented_here"]) {
        [self paymentGatewaysImplemented];
        //todo
        return;
    }
    Addons* addons = [Addons sharedManager];
    if (addons.enable_otp_in_cod_payment) {
        _screen_current_state = SCREEN_STATE_VERIFY_MOBILE_OTP;
    } else {
        _screen_current_state = SCREEN_STATE_ENTER;
    }
    [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
    [[Utility sharedManager] stopGrayLoadingBar];
    NSString* errorMsg = Localize(@"i_payment_failed_msg");
    if (obj!=nil && [obj isKindOfClass:[NSString class]]){
        errorMsg = obj;
    }
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Localize(@"i_payment_failed_title") message:errorMsg delegate:nil cancelButtonTitle:Localize(@"i_ok") otherButtonTitles:nil];
    [alertView show];
}
- (BOOL)initializeGateway {
    if([_selectedPaymentGateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_PAYSTACK]]){
#if ENABLE_PAYSTACK_IN_TMSTORE
        PaystackConfig* config = [PaystackConfig sharedManager];
//        [Paystack setDefaultPublishableKey:config.cPaystackPublishableKey];
        [Paystack setDefaultPublicKey:config.cPaystackPublishableKey];
        return true;
#endif
    }
    
    if([_selectedPaymentGateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_VCS_PAY]]){
#if ENABLE_VCS_PAY_IN_TMSTORE
        VCSPayConfig* config = [VCSPayConfig sharedManager];
        return true;
#endif
    }
    return false;
}
- (void)paymentGatewaysImplemented {
//    return;
    if ([_selectedPaymentGateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_PAYSTACK]]) {
#if ENABLE_PAYSTACK_IN_TMSTORE
        BOOL initializeGatewaySuccess = [self initializeGateway];
        if(!initializeGatewaySuccess)
            return;
        PaystackViewController *viewController = [[PaystackViewController alloc] initWithNibName:nil bundle:nil];
        PaystackConfig* config = [PaystackConfig sharedManager];
        NSString* amountString = [NSString stringWithFormat:@"%.2f", config.infoTotalAmount];
        viewController.amount = [NSDecimalNumber decimalNumberWithString:amountString];
        
        TMPaymentSDK* tmPaymentSDK = (TMPaymentSDK*)(_selectedPaymentGateway.sdkObj);
//        [tmPaymentSDK.paymentDelegate setDelegate:self];
        viewController.responseDelegate = tmPaymentSDK.paymentDelegate;
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
        [_selectedPaymentGateway.delegate presentViewController:navController animated:YES completion:nil];
#else
        [self paymentCompletionWithFailure:nil];
#endif
    }
    
    
    
    if ([_selectedPaymentGateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_VCS_PAY]]) {
#if ENABLE_VCS_PAY_IN_TMSTORE
        BOOL initializeGatewaySuccess = [self initializeGateway];
        if(!initializeGatewaySuccess)
            return;
        TMPaymentSDK* tmPaymentSDK = (TMPaymentSDK*)(_selectedPaymentGateway.sdkObj);
        VCSPayViewController* viewController = [[VCSPayViewController alloc] initWithDelegate:tmPaymentSDK.paymentDelegate];
        VCSPayConfig* config = [VCSPayConfig sharedManager];
        NSString* amountString = [NSString stringWithFormat:@"%.2f", config.infoTotalAmount];
        viewController.amount = [NSDecimalNumber decimalNumberWithString:amountString];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
        [_selectedPaymentGateway.delegate presentViewController:navController animated:YES completion:nil];
#else
        [self paymentCompletionWithFailure:nil];
#endif
    }
}

- (void)updateOrderSuccess:(NSNotification*)notification {
    AppUser* appUser = [AppUser sharedManager];
    for (Cart* c in appUser._cartArray) {
        if (c.selectedVariationId == -1) {
            if (c.product._images && [c.product._images count] > 0) {
                [LineItem setImgUrlOnProductId:c.product_id imgUrl:((ProductImage*)[c.product._images objectAtIndex:0])._src];
            }
        } else {
            Variation* v = [c.product._variations getVariation:c.selectedVariationId];
            if (v._images && [v._images count] > 0) {
                [LineItem setImgUrlOnProductId:c.selectedVariationId imgUrl:((ProductImage*)[v._images objectAtIndex:0])._src];
            } else if (c.product._images && [c.product._images count] > 0) {
                [LineItem setImgUrlOnProductId:c.selectedVariationId imgUrl:((ProductImage*)[c.product._images objectAtIndex:0])._src];
            }
        }
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UPDATE_ORDER_SUCCESS" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UPDATE_ORDER_FAILURE" object:nil];
    RLOG(@"updateOrderSuccess");
    [self updateOrderRewardPoints:_blankOrder];
    _screen_current_state = SCREEN_STATE_EXIT;
    
    [appUser._cartArray removeAllObjects];
    [Cart resetOrderNotes];
    [appUser saveData];
#if ENABLE_PARSE_ANALYTICS
    [[ParseHelper sharedManager] registerParseCustomerPurchase:_blankOrder];
    [[ParseHelper sharedManager] registerOrder:_blankOrder];

    if ([[GuestConfig sharedInstance] guest_checkout] && appUser._isUserLoggedIn == false) {
        NSArray* guestOrdersArray = [[NSUserDefaults standardUserDefaults] valueForKey:@"GUO"];
        NSMutableArray* guestOrdersArrayMutable = [[NSMutableArray alloc] init];
        if (guestOrdersArray != nil) {
            guestOrdersArrayMutable = [[NSMutableArray alloc] initWithArray:guestOrdersArray];
        }
        [guestOrdersArrayMutable addObject:[NSNumber numberWithInt:_blankOrder._id]];
        guestOrdersArray = [[NSArray alloc] initWithArray:guestOrdersArrayMutable];
        [[NSUserDefaults standardUserDefaults] setValue:guestOrdersArray forKey:@"GUO"];
    }
    
    
    [[CustomerData sharedManager] incrementCurrent_Day_Purchased_Amount:[_blankOrder._total floatValue]];
    [[CustomerData sharedManager] incrementCurrent_Day_Purchased_Item:_blankOrder._total_line_items_quantity];
    [[[CustomerData sharedManager] getPFInstance] saveInBackground];
#endif
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATE_NOTIFICATION_COUNT" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    
    
    RLOG(@"now show order screen here");
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
    ViewControllerOrderReceipt* vcOrderReceipt = (ViewControllerOrderReceipt*)[[Utility sharedManager] getNewViewController:PUSH_SCREEN_TYPE_ORDER_RECEIPT];
    [[Utility sharedManager] pushScreenWithoutAnimation:mainVC.vcCenterTop type:PUSH_SCREEN_TYPE_ORDER_RECEIPT newViewController:vcOrderReceipt];
    
//    ViewControllerOrderReceipt* vcOrderReceipt = (ViewControllerOrderReceipt*)[[Utility sharedManager] pushScreenWithoutAnimation:mainVC.vcCenterTop type:PUSH_SCREEN_TYPE_ORDER_RECEIPT];
    RLOG(@"vcOrderReceipt = %@", vcOrderReceipt);
    
    
    
}
- (void)updateOrderFailed:(NSNotification*)notification {
    //    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UPDATE_ORDER_SUCCESS" object:nil];
    //    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UPDATE_ORDER_FAILURE" object:nil];
    RLOG(@"updateOrderFailed");
//    if (
//        [_selectedPaymentGateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_DBT]] ||
//        [_selectedPaymentGateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_CHEQUE]] ||
//        [_selectedPaymentGateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_JETPACK1]] ||
//        [_selectedPaymentGateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_JETPACK2]] ||
//        [_selectedPaymentGateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_JETPACK3]]) {
//        [[[DataManager sharedManager] tmDataDoctor] updateOrder:_selectedPaymentGateway orderId:_blankOrder._id orderStatus:@"on-hold" isPaid:false];
//    } else {
//        [[[DataManager sharedManager] tmDataDoctor] updateOrder:_selectedPaymentGateway orderId:_blankOrder._id orderStatus:@"processing" isPaid:true];
//    }
    
    
    if (
        [_selectedPaymentGateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_DBT]] ||
        [_selectedPaymentGateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_CHEQUE]] ||
        [_selectedPaymentGateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_JETPACK1]] ||
        [_selectedPaymentGateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_JETPACK2]] ||
        [_selectedPaymentGateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_JETPACK3]]
        ) {
        [[[DataManager sharedManager] tmDataDoctor] updateOrder:_selectedPaymentGateway orderId:_blankOrder._id orderStatus:@"on-hold" isPaid:false];
    }
    else if([_selectedPaymentGateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_COD]]) {
        [[[DataManager sharedManager] tmDataDoctor] updateOrder:_selectedPaymentGateway orderId:_blankOrder._id orderStatus:@"processing" isPaid:false];
    }
    else {
        [[[DataManager sharedManager] tmDataDoctor] updateOrder:_selectedPaymentGateway orderId:_blankOrder._id orderStatus:@"processing" isPaid:true];
    }
}

//#pragma mark PayPalPaymentDelegate methods
//- (void)payPalPaymentViewController:(PayPalPaymentViewController *)paymentViewController didCompletePayment:(PayPalPayment *)completedPayment {
//    RLOG(@"PayPal Payment Success!");
//    // self.resultText = [completedPayment description];
//    //  [self showSuccess];
//    RLOG(@"PayPal Payment Sucess");
//    //  [self sendCompletedPaymentToServer:completedPayment]; // Payment was processed successfully; send to server for verification and fulfillment
//    [paymentViewController dismissViewControllerAnimated:YES completion:nil];
//}
//- (void)payPalPaymentDidCancel:(PayPalPaymentViewController *)paymentViewController {
//    RLOG(@"PayPal Payment Canceled");
//    // self.resultText = nil;
//    //  self.successView.hidden = YES;
//    [paymentViewController dismissViewControllerAnimated:YES completion:nil];
//}

- (float)calculateChargeFromTax:(float)totalAmount tax:(TM_Tax *)tax {
    return (float) (totalAmount * tax.rate / 100.00f);
}
- (float)calculateGrandTotalShipping {
    float shippingTotal = 0.0f;
    for (TMShipping* shpMthd in _selectedShippingMethod) {
        if(shpMthd){
            shippingTotal += (float)shpMthd.shippingCost;
        }
    }
    if (_shippingBunches) {
        NSArray* bunchesKeys = [_shippingBunches allKeys];
        for (int i = 0; i < [bunchesKeys count]; i++) {
            NSDictionary* dict = [_shippingBunches objectForKey:[NSNumber numberWithInt:i]];
            float deliveryCost = [[dict objectForKey:@"time_slot_cost"] floatValue];
            shippingTotal += deliveryCost;
        }
    }
    return shippingTotal;
}
- (float)calculateGrandTotalShippingNonTaxable {
    float shippingTotal = 0.0f;
    for (TMShipping* shpMthd in _selectedShippingMethod) {
        if(shpMthd && shpMthd.taxable == false){
            shippingTotal += (float)shpMthd.shippingCost;
        }
    }
    if (_shippingBunches) {
        NSArray* bunchesKeys = [_shippingBunches allKeys];
        for (int i = 0; i < [bunchesKeys count]; i++) {
            NSDictionary* dict = [_shippingBunches objectForKey:[NSNumber numberWithInt:i]];
            float deliveryCost = [[dict objectForKey:@"time_slot_cost"] floatValue];
            shippingTotal += deliveryCost;
        }
    }
    return shippingTotal;
}
- (float)calculateGrandTotalShippingTaxable {
    float shippingTotal = 0.0f;
    for (TMShipping* shpMthd in _selectedShippingMethod) {
        if(shpMthd && shpMthd.taxable){
            shippingTotal += (float)shpMthd.shippingCost;
        }
    }
    return shippingTotal;
}


- (float)calculateGrandTotalWithoutTax {
    float grandTotalWithoutShipping = [self calculateGrandTotalWithoutShipping];
    float shippingTotal = 0.0f;
    for (TMShipping* shpMthd in _selectedShippingMethod) {
        if(shpMthd){
            shippingTotal += (float)shpMthd.shippingCost;
            //Add shipping tax if available
            for (NSString* taxString in shpMthd.shippingTaxes) {
                shippingTotal += [taxString floatValue];
            }
        }
    }
    if (_shippingBunches) {
        NSArray* bunchesKeys = [_shippingBunches allKeys];
        for (int i = 0; i < [bunchesKeys count]; i++) {
            NSDictionary* dict = [_shippingBunches objectForKey:[NSNumber numberWithInt:i]];
            float deliveryCost = [[dict objectForKey:@"time_slot_cost"] floatValue];
            shippingTotal += deliveryCost;
        }
    }
    
    float checkoutAddonCost = 0.0f;
    if (_checkoutAddonCheckboxes && [_checkoutAddonCheckboxes count] > 0) {
        [TM_CheckoutAddon clearSelectedCheckoutAddons];
        for (UIButton* tmCheckoutAddonBtn in _checkoutAddonCheckboxes) {
            if([tmCheckoutAddonBtn isSelected]){
                TM_CheckoutAddon* tmCheckoutAddon = [tmCheckoutAddonBtn.layer valueForKey:@"MY_OBJECT"];
                if (tmCheckoutAddon.cost > 0) {
                    checkoutAddonCost += tmCheckoutAddon.cost;
                }
                [TM_CheckoutAddon addToSelectedCheckoutAddons:tmCheckoutAddon];
            }
        }
    }
    
    
    return grandTotalWithoutShipping + shippingTotal + checkoutAddonCost;
}
- (float)getFeesTotal {
    float feesTotal = 0;
    float cartTotal = [Cart getTotalPayment];
    for (FeeData* fee in [FeeData getAllFeeData]) {
        if (fee.minorder == 0 || fee.minorder > cartTotal) {
            feesTotal += fee.cost;
        }
    }
    return feesTotal;
}
- (float)calculateGrandTotalWithoutShipping {
    float cartTotal = [Cart getTotalPayment];
    float feesTotal = [self getFeesTotal];
    float extraPaymentCharges = 0.0f;
    float autoCouponDiscount = 0.0f;
    TMPaymentGateway* paymentGateway = _selectedPaymentGateway;
    if (paymentGateway && paymentGateway.gatewaySettings) {
        extraPaymentCharges = [paymentGateway.gatewaySettings.extraCharges floatValue];
    }
    autoCouponDiscount = [self getAutoCouponDiscount];
    float total = (cartTotal + feesTotal + extraPaymentCharges - autoCouponDiscount);
    return MAX(total, 0.0f);
}

-(void) updateOrderRewardPoints:(Order*)order {
    if(![[Addons sharedManager] enable_custom_points]) {
        return;
    }

    AppUser* appUser = [AppUser sharedManager];
    NSString* orderIds = [NSString stringWithFormat:@"[%d]", order._id];
    int pointsRedeemed = appUser.rewardPoints ;//(int) ([Cart getPointsPriceDiscount] * 100.0f);
    NSDictionary* parameters = @{ @"type": base64_str(@"update_order_points"),
                                  @"user_id": base64_int([appUser _id]),
                                  @"email_id": base64_str([appUser _email]),
                                  @"order_ids" : base64_str(orderIds),
                                  @"points_redeemed": base64_int(pointsRedeemed)};
    [[DataManager getDataDoctor] updateOrderRewardPoints:parameters
                                                 success:^(id data) {
                                                     RLOG(@"Order reward points updated successfully.");
                                                 }
                                                 failure:^(NSString *error) {
                                                     RLOG(@"Failed to update order reward points.");
                                                 }];
}
- (float)getAutoCouponDiscount {
    float autoCouponDiscount = 0.0f;
    CartMeta* cartMeta = [CartMeta sharedInstance];
    for (AppliedCoupon* coupon in [cartMeta getAppliedCoupons]) {
        autoCouponDiscount += coupon.discount_amount;
    }
    return autoCouponDiscount;
}

- (float)calculateGrandTotal {
    float grandTotalWithoutTax = [self calculateGrandTotalWithoutTax];
    float grandTotalShipping = [self calculateGrandTotalShipping];
//    float grandTotalShippingNonTaxable = [self calculateGrandTotalShippingNonTaxable];
//    float grandTotalShippingTaxable = [self calculateGrandTotalShippingTaxable];
    float taxAmount = [TM_TaxApplied calculateTotalTax:grandTotalShipping];
    taxAmount = [TM_TaxApplied calculateTotalTaxOnCheckoutAddons];
    if (taxAmount > 0)
    {
        if (_taxViewHeader == nil) {
            _taxViewHeader = [self addHeaderView:Localize(@"Tax Info") isTransparant:false];
            [Utility showShadow:_taxViewHeader];
        }
        UIView* view = [self createTaxView];
        view.layer.shadowOpacity = 0.0f;
        [Utility showShadow:view];
        
        if (_viewGrandTotal) {
            [_viewsAdded removeObject:_taxViewHeader];
            [_viewsAdded removeObject:_taxView];
            int viewGrandTotalIndex = (int)[_viewsAdded indexOfObject:_viewGrandTotal];
            [_viewsAdded insertObject:_taxView atIndex:viewGrandTotalIndex];
            [_viewsAdded insertObject:_taxViewHeader atIndex:viewGrandTotalIndex];
            [self resetMainScrollView];
        }
    } else {
        [_viewsAdded removeObject:_taxViewHeader];
        [_viewsAdded removeObject:_taxView];
        [_taxViewHeader removeFromSuperview];
        [_taxView removeFromSuperview];
        _taxViewHeader = nil;
        _taxView = nil;
        [self resetMainScrollView];
    }
    
    float pickupCost = 0.0f;
    if ([[Addons sharedManager] show_pickup_location] && [[TM_PickupLocation getAllPickupLocations] count] > 0) {
        TM_PickupLocation* pckloc = [[TM_PickupLocation getAllPickupLocations] objectAtIndex:0];
        pickupCost = [pckloc.cost floatValue];
    }
    return grandTotalWithoutTax + taxAmount + pickupCost;
}


#pragma mark OTP Verification Methods
- (void)createOTPScreenAsk {
//    if(self.popupOTPAsk == nil) {
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
        self.popupOTPAsk = [[CNPPopupController alloc] initWithContents:@[viewMain]];
        self.popupOTPAsk.theme = [CNPPopupTheme addressTheme];
        self.popupOTPAsk.theme.popupStyle = CNPPopupStyleCentered;
        self.popupOTPAsk.theme.size = CGSizeMake(widthView, heightView);
        self.popupOTPAsk.theme.maxPopupWidth = widthView;
        self.popupOTPAsk.delegate = self;
        self.popupOTPAsk.theme.shouldDismissOnBackgroundTouch = false;
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            self.popupOTPAsk.VIEW_POPUP.transform = CGAffineTransformMakeScale(-1, 1);
        }
        UILabel* _labelTitle = [self createLabel:viewTop fontType:kUIFontType20 fontColorType:kUIColorFontDark frame:CGRectMake(0, -16, viewTop.frame.size.width, viewTop.frame.size.height + 16) textStr:Localize(@"otp_verification")];
        [_labelTitle setTextAlignment:NSTextAlignmentCenter];
        
        UIButton* _buttonCancel = [[UIButton alloc] initWithFrame:CGRectMake(16, -16, viewTop.frame.size.width, viewTop.frame.size.height + 16)];
        [viewTop addSubview:_buttonCancel];
        [_buttonCancel addTarget:self action:@selector(clickedCancelAsk:) forControlEvents:UIControlEventTouchUpInside];
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
        
        posY = CGRectGetMaxY(viewTop.frame) + gap * 2;
        
        UILabel* labelMessage = [self createLabel:viewMain fontType:kUIFontType18 fontColorType:kUIColorFontDark frame:CGRectMake(posX, posY, width, height) textStr:Localize(@"cod_otp_dialog_msg")];
        [labelMessage setNumberOfLines:0];
        [labelMessage setLineBreakMode:NSLineBreakByWordWrapping];
        [labelMessage sizeToFitUI];
        posY = CGRectGetMaxY(labelMessage.frame) + gap;
        
        _otp_textfield_mobile = [self createTextField:viewMain fontType:kUIFontType18 fontColorType:kUIColorFontDark frame:CGRectMake(posX, posY, width, height) tag:0 textStrPlaceHolder:Localize(@"hint_mobile_number")];
        [_otp_textfield_mobile setText:_registerMobileNumber];
        [_otp_textfield_mobile setUIFont:kUIFontType18 isBold:true];
        UIImageView *spacerView = [[UIImageView alloc] initWithFrame:CGRectMake(height * .20f, height * .20f, height, height * .60f)];
        [spacerView setContentMode:UIViewContentModeScaleAspectFit];
        UIImage* img = [[UIImage imageNamed:@"ic_mode_edit_white"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [spacerView setImage:img];
        [spacerView setTintColor:[Utility getUIColor:kUIColorFontLight]];
        if (![[TMLanguage sharedManager] isRTLEnabled]) {
            [_otp_textfield_mobile setRightViewMode:UITextFieldViewModeAlways];
            [_otp_textfield_mobile setRightView:spacerView];
        } else {
            [_otp_textfield_mobile setLeftViewMode:UITextFieldViewModeAlways];
            [_otp_textfield_mobile setLeftView:spacerView];
        }
        [viewMain addSubview:_otp_textfield_mobile];
        posY = CGRectGetMaxY(_otp_textfield_mobile.frame) + gap*2;
        
        _otp_button_ok = [[UIButton alloc] initWithFrame:CGRectMake(posX, posY, width, height)];
        [_otp_button_ok setBackgroundColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
        [[_otp_button_ok titleLabel] setUIFont:kUIFontType22 isBold:false];
        [_otp_button_ok setTitle:Localize(@"i_ok") forState:UIControlStateNormal];
        [_otp_button_ok setTitleColor:[Utility getUIColor:kUIColorBuyButtonFont] forState:UIControlStateNormal];
        [viewMain addSubview:_otp_button_ok];
        [_otp_button_ok addTarget:self action:@selector(clickedOtpOk) forControlEvents:UIControlEventTouchUpInside];
        posY = CGRectGetMaxY(_otp_button_ok.frame) + gap * 2;
        posY += CGRectGetMaxY(viewTop.frame) + gap * 2;
        self.popupOTPAsk.theme.size = CGSizeMake(widthView, posY);
        CGRect viewMainFrame = viewMain.frame;
        viewMainFrame.size = CGSizeMake(widthView, posY);
        viewMain.frame = viewMainFrame;
//    }
    [_otp_button_mobile setText:_registerMobileNumber];
    [self.popupOTPAsk presentPopupControllerAnimated:YES];
}
- (void)clickedOtpOk {
    if ([_registerMobileNumber isEqualToString:_otp_textfield_mobile.text]) {
        [self resendOTP];
        [self.popupOTPAsk dismissPopupControllerAnimated:true];
        [self createOTPScreenVerify];
    } else {
        _registerMobileNumberNew = _otp_textfield_mobile.text;
        [self.popupOTPAsk dismissPopupControllerAnimated:true];
        [self createOTPScreenUpdate];
    }
}
- (void)createOTPScreenUpdate {
//    if(self.popupOTPUpdate == nil) {
    
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
        self.popupOTPUpdate = [[CNPPopupController alloc] initWithContents:@[viewMain]];
        self.popupOTPUpdate.theme = [CNPPopupTheme addressTheme];
        self.popupOTPUpdate.theme.popupStyle = CNPPopupStyleCentered;
        self.popupOTPUpdate.theme.size = CGSizeMake(widthView, heightView);
        self.popupOTPUpdate.theme.maxPopupWidth = widthView;
        self.popupOTPUpdate.delegate = self;
        self.popupOTPUpdate.theme.shouldDismissOnBackgroundTouch = false;
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            self.popupOTPUpdate.VIEW_POPUP.transform = CGAffineTransformMakeScale(-1, 1);
        }
        UILabel* _labelTitle = [self createLabel:viewTop fontType:kUIFontType20 fontColorType:kUIColorFontDark frame:CGRectMake(0, -16, viewTop.frame.size.width, viewTop.frame.size.height + 16) textStr:Localize(@"update_billing_mobile_no_dialog_header")];
        [_labelTitle setTextAlignment:NSTextAlignmentCenter];
        
        UIButton* _buttonCancel = [[UIButton alloc] initWithFrame:CGRectMake(16, -16, viewTop.frame.size.width, viewTop.frame.size.height + 16)];
        [viewTop addSubview:_buttonCancel];
        [_buttonCancel addTarget:self action:@selector(clickedCancelUpdate:) forControlEvents:UIControlEventTouchUpInside];
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
        
        posY = CGRectGetMaxY(viewTop.frame) + gap * 2;
        
        UILabel* labelMessage = [self createLabel:viewMain fontType:kUIFontType18 fontColorType:kUIColorFontDark frame:CGRectMake(posX, posY, width, height) textStr:[NSString stringWithFormat:@"%@ %@", Localize(@"update_billing_mobile_no_dialog_msg"),_registerMobileNumberNew]];
        [labelMessage setNumberOfLines:0];
        [labelMessage setLineBreakMode:NSLineBreakByWordWrapping];
        [labelMessage sizeToFitUI];
        posY = CGRectGetMaxY(labelMessage.frame) + gap * 2;
        
        _otp_button_update = [[UIButton alloc] initWithFrame:CGRectMake(posX, posY, width, height)];
        [_otp_button_update setBackgroundColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
        [[_otp_button_update titleLabel] setUIFont:kUIFontType22 isBold:false];
        [_otp_button_update setTitle:Localize(@"update") forState:UIControlStateNormal];
        [_otp_button_update setTitleColor:[Utility getUIColor:kUIColorBuyButtonFont] forState:UIControlStateNormal];
        [viewMain addSubview:_otp_button_update];
        [_otp_button_update addTarget:self action:@selector(clickedUpdateMobileNumber) forControlEvents:UIControlEventTouchUpInside];
        posY = CGRectGetMaxY(_otp_button_update.frame) + gap * 2;
        posY += CGRectGetMaxY(viewTop.frame) + gap * 2;
        self.popupOTPUpdate.theme.size = CGSizeMake(widthView, posY);
        CGRect viewMainFrame = viewMain.frame;
        viewMainFrame.size = CGSizeMake(widthView, posY);
        viewMain.frame = viewMainFrame;
//    }
//    [_otp_button_mobile setText:_registerMobileNumber];
    [self.popupOTPUpdate presentPopupControllerAnimated:YES];
}
- (void)clickedUpdateMobileNumber {
    [Utility showProgressView:@""];
    AppUser* appUser = [AppUser sharedManager];
    appUser._billing_address._phone = _registerMobileNumberNew;
    [[[DataManager sharedManager] tmDataDoctor] updateCustomerData:^(id data) {
        [Utility hideProgressView];
        _registerMobileNumber = _registerMobileNumberNew;
        [self.popupOTPUpdate dismissPopupControllerAnimated:YES];
        [self createOTPScreenVerify];
        [self resendOTP];
    } failure:^(NSString *error) {
        [Utility hideProgressView];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Localize(@"oops") message:Localize(@"generic_error") delegate:nil cancelButtonTitle:Localize(@"cancel") otherButtonTitles:Localize(@"retry"), nil];;
        [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if ((int)buttonIndex == 0) {
                
            } else {
                [self clickedUpdateMobileNumber];
            }
        }];
    }];
}
- (void)createOTPScreenVerify {
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
    self.popupOTPVerify = [[CNPPopupController alloc] initWithContents:@[viewMain]];
    self.popupOTPVerify.theme = [CNPPopupTheme addressTheme];
    self.popupOTPVerify.theme.popupStyle = CNPPopupStyleCentered;
    self.popupOTPVerify.theme.size = CGSizeMake(widthView, heightView);
    self.popupOTPVerify.theme.maxPopupWidth = widthView;
    self.popupOTPVerify.delegate = self;
    self.popupOTPVerify.theme.shouldDismissOnBackgroundTouch = false;
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        self.popupOTPVerify.VIEW_POPUP.transform = CGAffineTransformMakeScale(-1, 1);
    }
    UILabel* _labelTitle = [self createLabel:viewTop fontType:kUIFontType20 fontColorType:kUIColorFontDark frame:CGRectMake(0, -16, viewTop.frame.size.width, viewTop.frame.size.height + 16) textStr:Localize(@"otp_verification")];
    [_labelTitle setTextAlignment:NSTextAlignmentCenter];
    
    UIButton* _buttonCancel = [[UIButton alloc] initWithFrame:CGRectMake(16, -16, viewTop.frame.size.width, viewTop.frame.size.height + 16)];
    [viewTop addSubview:_buttonCancel];
    [_buttonCancel addTarget:self action:@selector(clickedCancelVerify:) forControlEvents:UIControlEventTouchUpInside];
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
    posY = CGRectGetMaxY(viewTop.frame) + gap * 2;
    
//    _otp_button_mobile = [self createTextField:viewMain fontType:kUIFontType18 fontColorType:kUIColorFontDark frame:CGRectMake(posX, posY, width, height) tag:0 textStrPlaceHolder:_registerMobileNumber];
//    [_otp_button_mobile setText:_registerMobileNumber];
//    [_otp_button_mobile setUIFont:kUIFontType18 isBold:true];
//    UIImageView *spacerView = [[UIImageView alloc] initWithFrame:CGRectMake(height * .20f, height * .20f, height, height * .60f)];
//    [spacerView setContentMode:UIViewContentModeScaleAspectFit];
//    UIImage* img = [[UIImage imageNamed:@"ic_mode_edit_white"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//    [spacerView setImage:img];
//    [spacerView setTintColor:[Utility getUIColor:kUIColorFontLight]];
//    if (![[TMLanguage sharedManager] isRTLEnabled]) {
//        [_otp_button_mobile setRightViewMode:UITextFieldViewModeAlways];
//        [_otp_button_mobile setRightView:spacerView];
//    } else {
//        [_otp_button_mobile setLeftViewMode:UITextFieldViewModeAlways];
//        [_otp_button_mobile setLeftView:spacerView];
//    }
//    [viewMain addSubview:_otp_button_mobile];
//    posY += (height+gap);
    
    
    _otp_textfield_code = [self createTextField:viewMain fontType:kUIFontType18 fontColorType:kUIColorFontDark frame:CGRectMake(posX, posY, width, height) tag:0 textStrPlaceHolder:Localize(@"enter_otp")];
    _otp_textfield_code.textAlignment = NSTextAlignmentLeft;
    [_otp_textfield_code setUIFont:kUIFontType18 isBold:true];
    posY = CGRectGetMaxY(_otp_textfield_code.frame) + gap * 2;
    
    
    _otp_button_timer = [[UIButton alloc] initWithFrame:CGRectMake(posX, posY, width, height)];
    [_otp_button_timer setBackgroundColor:[UIColor clearColor]];
    [[_otp_button_timer titleLabel] setUIFont:kUIFontType22 isBold:false];
    [_otp_button_timer setTitle:@"" forState:UIControlStateNormal];
    [_otp_button_timer setTitleColor:[Utility getUIColor:kUIColorFontDark] forState:UIControlStateNormal];
    [viewMain addSubview:_otp_button_timer];
    [_otp_button_timer addTarget:self action:@selector(resendOTP) forControlEvents:UIControlEventTouchUpInside];
    posY = CGRectGetMaxY(_otp_button_timer.frame) + gap * 2;
    
    
    _OTPButtonVerify = [[UIButton alloc] initWithFrame:CGRectMake(posX, posY, width, height)];
    [_OTPButtonVerify setBackgroundColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
    [[_OTPButtonVerify titleLabel] setUIFont:kUIFontType22 isBold:false];
    [_OTPButtonVerify setTitle:Localize(@"verify") forState:UIControlStateNormal];
    [_OTPButtonVerify setTitleColor:[Utility getUIColor:kUIColorBuyButtonFont] forState:UIControlStateNormal];
    [viewMain addSubview:_OTPButtonVerify];
    [_OTPButtonVerify addTarget:self action:@selector(verifyOTP) forControlEvents:UIControlEventTouchUpInside];
    posY = CGRectGetMaxY(_OTPButtonVerify.frame) + gap * 2;
    posY += CGRectGetMaxY(viewTop.frame) + gap * 2;
    self.popupOTPVerify.theme.size = CGSizeMake(widthView, posY);
    CGRect viewMainFrame = viewMain.frame;
    viewMainFrame.size = CGSizeMake(widthView, posY);
    viewMain.frame = viewMainFrame;
    [self.popupOTPVerify presentPopupControllerAnimated:YES];
}
- (void)createOTPVerificationView {
    /*
     
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
        self.popupControllerOTP.theme.shouldDismissOnBackgroundTouch = false;
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
        
        
        _otp_button_mobile = [self createTextField:viewMain fontType:kUIFontType18 fontColorType:kUIColorFontDark frame:CGRectMake(posX, posY, width, height) tag:0 textStrPlaceHolder:_registerMobileNumber];
        [_otp_button_mobile setText:_registerMobileNumber];
        [_otp_button_mobile setUIFont:kUIFontType18 isBold:true];
        UIImageView *spacerView = [[UIImageView alloc] initWithFrame:CGRectMake(height * .20f, height * .20f, height, height * .60f)];
        [spacerView setContentMode:UIViewContentModeScaleAspectFit];
        UIImage* img = [[UIImage imageNamed:@"ic_mode_edit_white"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [spacerView setImage:img];
        [spacerView setTintColor:[Utility getUIColor:kUIColorFontLight]];
        if (![[TMLanguage sharedManager] isRTLEnabled]) {
            [_otp_button_mobile setRightViewMode:UITextFieldViewModeAlways];
            [_otp_button_mobile setRightView:spacerView];
        } else {
            [_otp_button_mobile setLeftViewMode:UITextFieldViewModeAlways];
            [_otp_button_mobile setLeftView:spacerView];
        }
        [viewMain addSubview:_otp_button_mobile];
        posY += (height+gap);
        
        
        _otp_textfield_code = [self createTextField:viewMain fontType:kUIFontType18 fontColorType:kUIColorFontDark frame:CGRectMake(posX, posY, width, height) tag:0 textStrPlaceHolder:Localize(@"enter_otp")];
        _otp_textfield_code.textAlignment = NSTextAlignmentLeft;
        [_otp_textfield_code setUIFont:kUIFontType18 isBold:true];
        [_otp_textfield_code setHidden:true];
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
        [_OTPButtonVerify setTitle:Localize(@"send") forState:UIControlStateNormal];
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
    [_otp_button_mobile setText:_registerMobileNumber];
    [self.popupControllerOTP presentPopupControllerAnimated:YES];
    
    */
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
    [Utility showProgressView:@""];
    _registerMobileNumberOTP = _registerMobileNumber;
    [[[DataManager sharedManager] tmDataDoctor] pluginOTP:_registerMobileNumber
                                                     code:@""
                                                     type:OTP_METHOD_TYPE_CHECKOUT_SEND
                                                  success:^(NSString *str) {
                                                      RLOG(@"%@",str);
                                                      [Utility hideProgressView];
                                                      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:str delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
                                                      [alert show];
                                                      [self dismissAlertViewAfterTime:1.0f alertView:alert];
                                                      [self OTPTimerResetFg];
                                                      [self OTPTimerResetBg];
                                                  }
                                                  failure:^(NSString *error) {
                                                      RLOG(@"%@",error);
                                                      [Utility hideProgressView];
                                                      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:error delegate:self cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil];
                                                      [alert show];
                                                  }];
}
- (void)resendOTP {
    if ([_registerMobileNumberOTP isEqualToString:_registerMobileNumber]) {
        if (_OTPResendTimerBackground > 0) {
            if (_OTPResendTimerForeground > 0) {
                
            } else {
                [Utility showProgressView:@""];
                [[[DataManager sharedManager] tmDataDoctor] pluginOTP:_registerMobileNumber
                                                                 code:@""
                                                                 type:OTP_METHOD_TYPE_CHECKOUT_RESEND
                                                              success:^(NSString *str) {
                                                                  RLOG(@"%@",str);
                                                                  [Utility hideProgressView];
                                                                  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:str delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
                                                                  [alert show];
                                                                  [self dismissAlertViewAfterTime:1.0f alertView:alert];
                                                                  
                                                                  [self OTPTimerResetFg];
                                                              }
                                                              failure:^(NSString *error) {
                                                                  RLOG(@"%@",error);
                                                                  [Utility hideProgressView];
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
    if (_OTPButtonVerify && [_OTPButtonVerify.titleLabel.text isEqualToString:Localize(@"send")]) {
        [self resendOTP];
        return;
    }
    if (_otp_textfield_code && [_otp_textfield_code.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:Localize(@"enter_otp") delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
        [alert show];
        [self dismissAlertViewAfterTime:1.0f alertView:alert];
        return;
    }
    [Utility showProgressView:@""];
    [[[DataManager sharedManager] tmDataDoctor] pluginOTP:_registerMobileNumber
                                                     code:_otp_textfield_code.text
                                                     type:OTP_METHOD_TYPE_CHECKOUT_VERIFY
                                                  success:^(NSString *str) {
                                                      [Utility hideProgressView];
                                                      RLOG(@"%@",str);
//                                                      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:str delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
//                                                      [alert show];
//                                                      [self dismissAlertViewAfterTime:1.0f alertView:alert];
                                                      
                                                      [self OTPTimerInvalidate];
//                                                      [self.popupControllerOTP dismissPopupControllerAnimated:YES];
                                                      [self.popupOTPVerify dismissPopupControllerAnimated:YES];
                                                    _screen_current_state = SCREEN_STATE_ENTER;
                                                      [self proceedToPay:nil];
                                                  }
                                                  failure:^(NSString *error) {
                                                      [Utility hideProgressView];
                                                      RLOG(@"%@",error);
                                                      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Localize(@"verification_failed") message:error delegate:self cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil];
                                                      [alert show];
                                                  }];
}
- (void)clickedCancelAsk:(UIButton*)button {
    if (self.popupOTPAsk) {
        [self.popupOTPAsk dismissPopupControllerAnimated:YES];
    }
}
- (void)clickedCancelUpdate:(UIButton*)button {
    if (self.popupOTPUpdate) {
        [self.popupOTPUpdate dismissPopupControllerAnimated:YES];
        [self createOTPScreenAsk];
    }
}
- (void)clickedCancelVerify:(UIButton*)button {
    if (self.popupOTPVerify) {
        [self.popupOTPVerify dismissPopupControllerAnimated:YES];
    }
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
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
- (void)dismissAlertViewAfterTime:(float)dt alertView:(UIAlertView*)alertView {
    [self performSelector:@selector(dismissAlertView:) withObject:alertView afterDelay:dt];
}
- (void)dismissAlertView:(UIAlertView *)alertView{
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
}
@end
