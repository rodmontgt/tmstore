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

static int kTagForGlobalSpacing = 0;
static int kTagForNoSpacing = -1;
static BOOL isCurrencySymbolAtLast = true;
@interface ViewControllerCartShipping () {
    NSMutableArray* _viewsAdded;
    UIButton *customBackButton;
}
@end


@implementation ViewControllerCartShipping

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
    _chkBoxShipping = [[NSMutableArray alloc] init];
    _selectedPaymentGateway = nil;
    _selectedShippingMethod = nil;
    _screen_current_state = SCREEN_STATE_ENTER;

    _selected_time_slot = nil;
    _selected_date_time_slot = nil;
    _availableTimeSlots = nil;
    _availableDateTimeSlots = nil;
}
- (void)loadAllViews {
    [_chkBoxPayment removeAllObjects];
    [_chkBoxShipping removeAllObjects];
    _selectedPaymentGateway = nil;
    _selectedShippingMethod = nil;
    
    _selected_time_slot = nil;
    _selected_date_time_slot = nil;
    _availableTimeSlots = nil;
    _availableDateTimeSlots = nil;
    
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
    
    if ([[FeeData getAllFeeData] count] > 0 && [self getFeesTotal] > 0) {
        view = [self addHeaderView:Localize(@"Fee Info") isTransparant:false];
        [Utility showShadow:view];
        view = [self createFeeDataView];
        [Utility showShadow:view];
    }
    
    
    if ([[[CartMeta sharedInstance] getAppliedCoupons] count] > 0) {
        view = [self addHeaderView:Localize(@"Applied Coupons") isTransparant:false];
        [Utility showShadow:view];
        view = [self createAppliedCouponView];
        [Utility showShadow:view];
    }
    
    view = [self addHeaderView:Localize(@"i_shipping_info") isTransparant:false];
    [Utility showShadow:view];
    Addons* addons = [Addons sharedManager];
    NSString* shippingErrorMessage = @"";
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
    view = [self createShippingOptionView:shippingErrorMessage];
    [Utility showShadow:view];
    
    view = [self createShippingOptionView:shippingErrorMessage];
    [Utility showShadow:view];
    
    view = [self createShippingOptionView:shippingErrorMessage];
    [Utility showShadow:view];

    if ([[Addons sharedManager] show_pickup_location] && [[TM_PickupLocation getAllPickupLocations] count] > 0) {
        view = [self addHeaderView:Localize(@"title_pickup_location") isTransparant:false];
        [Utility showShadow:view];
        view = [self createPickupSelectionView];
        [Utility showShadow:view];
    }
    
    [self calculateGrandTotal];
    
    view = [self createGrandTotalView];
    [Utility showShadow:view];
    
    
    view = [self addHeaderView:Localize(@"available_payment_options") isTransparant:false];
    [Utility showShadow:view];
    view = [self createPaymentOptionView];
    [Utility showShadow:view];
    
#if ENABLE_DELIVERY_SLOT_COPIA
    if ([[DateTimeSlot getAllDateTimeSlots] count] > 0) {
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
    int shipping_methods_count = (int) [_chkBoxShipping count];
    int payment_methods_count = (int) [_chkBoxPayment count];
    TMShippingSDK* tmShippingSDK = [[DataManager sharedManager] tmShippingSDK];
    if(tmShippingSDK.shippingEnable && tmShippingSDK.shippingMethods) {
        shipping_methods_count = (int)[tmShippingSDK.shippingMethods count];
    }
    if (tmShippingSDK.shippingEnable && shipping_methods_count == 0) {
        return;
    }
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
- (void)refreshBlankOrder {
    
//    [TM_TaxApplied calculateTotalTax];
    
    return;
    if (_blankOrder == nil) {
        return [self createBlankOrder];
    } else {
        if (_selectedShippingMethod) {
            [[[DataManager sharedManager] tmDataDoctor] updateBlankOrderWithOrderId:_blankOrder._id shippingMethod:_selectedShippingMethod success:^(id data) {
                //update tax view here
                _blankOrder = (Order*)data;
            } failure:^(NSString *error) {
                if ([error isEqualToString:@"failure"]) {
                    
                } else if([error isEqualToString:@"retry"]) {
                    
                }
            }];
        }
    }
}
- (void)proceedToPay:(UIButton*)button{
    
    switch (_screen_current_state) {
        case SCREEN_STATE_ENTER:
        {
            _blankOrder = nil;
            int shipping_methods_count = (int) [_chkBoxShipping count];
            int payment_methods_count = (int) [_chkBoxPayment count];
            Addons* addons = [Addons sharedManager];
            TMShippingSDK* tmShippingSDK = [[DataManager sharedManager] tmShippingSDK];
            if(tmShippingSDK.shippingEnable && tmShippingSDK.shippingMethods) {
                shipping_methods_count = (int)[tmShippingSDK.shippingMethods count];
            }
            if (shipping_methods_count > 0 && _selectedShippingMethod == nil) {
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
            if (payment_methods_count > 0 && _selectedPaymentGateway == nil) {
                //alert select shipping methods

                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:Localize(@"select_payment_method") delegate:nil cancelButtonTitle:Localize(@"i_ok") otherButtonTitles:nil];
                [alertView show];
                return;
            }
            
            if (tmShippingSDK.shippingEnable && shipping_methods_count == 0) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Localize(@"sorry") message:Localize(@"no_shipping_method_found") delegate:nil cancelButtonTitle:Localize(@"i_ok") otherButtonTitles:nil];
                [alertView show];
                return;
            }
            
            
            if (payment_methods_count == 0) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Localize(@"sorry") message:Localize(@"no_payments_available") delegate:nil cancelButtonTitle:Localize(@"i_ok") otherButtonTitles:nil];
                [alertView show];
                return;
            }
            
            
            if (addons.deliverySlotsCopiaPlugin.isEnabled && [[DateTimeSlot getAllDateTimeSlots] count] > 0 && (self.selected_date_time_slot == nil || self.selected_time_slot == nil)) {
                if (self.selected_date_time_slot == nil) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Localize(@"sorry") message:Localize(@"title_available_time_slots") delegate:nil cancelButtonTitle:Localize(@"i_ok") otherButtonTitles:nil];
                    [alertView show];
                } else {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Localize(@"sorry") message:Localize(@"title_available_time_slots") delegate:nil cancelButtonTitle:Localize(@"i_ok") otherButtonTitles:nil];
                    [alertView show];
                }
                return;
            }
            
            if (addons.localPickupTimeSelectPlugin.isEnabled && [[TimeSlot getAllTimeSlots] count] > 0 &&  self.selected_time_slot == nil) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Localize(@"sorry") message:Localize(@"title_available_time_slots") delegate:nil cancelButtonTitle:Localize(@"i_ok") otherButtonTitles:nil];
                [alertView show];
                return;
            }
            
            if (_selectedPaymentGateway) {
                RLOG(@"_selectedPaymentGateway = %@", _selectedPaymentGateway);
            }
            if (_selectedShippingMethod) {
                RLOG(@"_selectedShippingMethod = %@", _selectedShippingMethod);
            }
            
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
- (void)bookDeliverySlots {
    if (self.selected_date_time_slot || self.selected_time_slot) {
        if (self.selected_date_time_slot) {
            [[[DataManager sharedManager] tmDataDoctor] postDeliverySlotsThroughPlugin:_blankOrder._id dateTimeSlot:self.selected_date_time_slot timeSlot:self.selected_time_slot success:^{
                
                _blankOrder.deliveryDateString = [self.selected_date_time_slot getDateSlot];
                _blankOrder.deliveryTimeString = self.selected_time_slot.slotTitle;
                //move to next step
                _screen_current_state = SCREEN_STATE_DELIVERY_SLOT_BOOKED;
                [self proceedPayment];
            } failure:^{
                [self bookDeliverySlots];
            }];
        } else {
            [[[DataManager sharedManager] tmDataDoctor] postTimeSlotsThroughPlugin:_blankOrder._id timeSlot:self.selected_time_slot success:^{
                _blankOrder.deliveryTimeString = self.selected_time_slot.slotTitle;
                //move to next step
                _screen_current_state = SCREEN_STATE_DELIVERY_SLOT_BOOKED;
                [self proceedPayment];
            } failure:^{
                [self bookDeliverySlots];
            }];
        }
    } else {
        //move to next step
         _screen_current_state = SCREEN_STATE_DELIVERY_SLOT_BOOKED;
        [self proceedPayment];
    }
}
- (void)proceedPayment {
    float orderTotalAmount = [_blankOrder._total floatValue];
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
        config.infoTotalAmount = orderTotalAmount;
        config.infoPhone = [NSString stringWithFormat:@"%@", user._billing_address._phone];
        config.infoName = [NSString stringWithFormat:@"%@", user._billing_address._first_name];
        config.infoEmail = [NSString stringWithFormat:@"%@", user._email];
    }
    else if ([_selectedPaymentGateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_PAYPAL]]){
        PayPalConfig* config = [PayPalConfig sharedManager];
        AppUser* user = [AppUser sharedManager];
        config.infoCountry = [NSString stringWithFormat:@"%@", user._billing_address._countryId];
        config.infoCurrency = [NSString stringWithFormat:@"%@", [CommonInfo sharedManager]->_currency];
        config.infoDescription = Localize(@"Total Amount");
        config.infoTotalAmount = orderTotalAmount;
    }
    else if ([_selectedPaymentGateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_APPLE_PAY_VIA_STRIPE]]){
        ApplePayViaStripeConfig* config = [ApplePayViaStripeConfig sharedManager];
        AppUser* user = [AppUser sharedManager];
        config.infoCountry = [NSString stringWithFormat:@"%@", user._billing_address._countryId];
        config.infoCurrency = [NSString stringWithFormat:@"%@", [CommonInfo sharedManager]->_currency];
        config.infoDescription = Localize(@"Total Amount");
        config.infoTotalAmount = orderTotalAmount;
    }
    else if ([_selectedPaymentGateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_STRIPE]]){
        StripeConfig* config = [StripeConfig sharedManager];
        AppUser* user = [AppUser sharedManager];
        config.infoCountry = [NSString stringWithFormat:@"%@", user._billing_address._countryId];
        config.infoCurrency = [NSString stringWithFormat:@"%@", [CommonInfo sharedManager]->_currency];
        config.infoDescription = Localize(@"Total Amount");
        config.infoTotalAmount = orderTotalAmount;
        config.infoCurrencyString = [[Utility sharedManager] convertToString:config.infoTotalAmount isCurrency:true];
    }
    else if ([_selectedPaymentGateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_SAGEPAY]]) {
        SagepayConfig* config = [SagepayConfig sharedManager];
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
        config.infoTotalAmount = orderTotalAmount;
    }
    else if ([_selectedPaymentGateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_KENT_PAYMENT]]) {
        KentPaymentConfig* config = [KentPaymentConfig sharedManager];
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
    else if ([_selectedPaymentGateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_TAP_PAYMENT]]) {
        TapPaymentConfig* config = [TapPaymentConfig sharedManager];
        AppUser* user = [AppUser sharedManager];
        config.infoCurrency = [NSString stringWithFormat:@"%@", [CommonInfo sharedManager]->_currency];
        config.infoEmail = [NSString stringWithFormat:@"%@", user._email];
        config.infoFirstName = [NSString stringWithFormat:@"%@", user._billing_address._first_name];
        config.infoLastName = [NSString stringWithFormat:@"%@", user._billing_address._last_name];
        config.infoPhone = [NSString stringWithFormat:@"%@", user._billing_address._phone];
        config.infoPlatform = @"ios";
        config.infoTotalAmount = orderTotalAmount;
    }
    else if ([_selectedPaymentGateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_BRAINTREE]]) {
        BraintreeConfig* config = [BraintreeConfig sharedManager];
        config.infoTotalAmount = orderTotalAmount;
    }
    else if ([_selectedPaymentGateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_MYGATE]]) {
        MyGateConfig* config = [MyGateConfig sharedManager];
        config.infoTotalAmount = orderTotalAmount;
    }
    else if ([_selectedPaymentGateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_AUTHORIZENET]]) {
        AppUser* user = [AppUser sharedManager];
        AuthorizeNetConfig* config = [AuthorizeNetConfig sharedManager];
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
        config.infoTotalAmount = orderTotalAmount;
        config.infoCurrency = [NSString stringWithFormat:@"%@", [CommonInfo sharedManager]->_currency];
    }
    else if ([_selectedPaymentGateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_CCAVENUE]]) {
        CCAvenueConfig* config = [CCAvenueConfig getInstance];
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
    
    
    DateTimeSlot* minDateTimeSlot = [[DateTimeSlot getAllDateTimeSlots] objectAtIndex:0];
    DateTimeSlot* maxDateTimeSlot = [[DateTimeSlot getAllDateTimeSlots] objectAtIndex:[[DateTimeSlot getAllDateTimeSlots] count] - 1];
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
        NSString* picLocStr = @"";
        NSString* seperator = @",";
        BOOL isHeaderRequired = false;
        if (![picLoc.address_1 isEqualToString:@""]) {
            if (isHeaderRequired) {
                picLocStr = [NSString stringWithFormat:@"%@%@ : %@%@", picLocStr, Localize(@"address1"), picLoc.address_1, seperator];
            } else {
                picLocStr = [NSString stringWithFormat:@"%@%@%@", picLocStr, picLoc.address_1, seperator];
            }
        }
        if (![picLoc.address_2 isEqualToString:@""]) {
            if (isHeaderRequired) {
                picLocStr = [NSString stringWithFormat:@"%@%@ : %@%@", picLocStr, Localize(@"address2"), picLoc.address_2, seperator];
            } else {
                picLocStr = [NSString stringWithFormat:@"%@ %@%@", picLocStr, picLoc.address_2, seperator];
            }
        }
        if (![picLoc.company isEqualToString:@""]) {
            if (isHeaderRequired) {
                picLocStr = [NSString stringWithFormat:@"%@%@ : %@%@", picLocStr, Localize(@"company"), picLoc.company, seperator];
            } else {
                picLocStr = [NSString stringWithFormat:@"%@ %@%@", picLocStr, picLoc.company, seperator];
            }
        }
        if (![picLoc.city isEqualToString:@""]) {
            if (isHeaderRequired) {
                picLocStr = [NSString stringWithFormat:@"%@%@ : %@%@", picLocStr, Localize(@"city"), picLoc.city, seperator];
            } else {
                picLocStr = [NSString stringWithFormat:@"%@ %@%@", picLocStr, picLoc.city, seperator];
            }
        }
        if (![picLoc.state isEqualToString:@""]) {
            if (isHeaderRequired) {
                picLocStr = [NSString stringWithFormat:@"%@%@ : %@%@", picLocStr, Localize(@"state"), picLoc.state, seperator];
            } else {
                picLocStr = [NSString stringWithFormat:@"%@ %@%@", picLocStr, picLoc.state, seperator];
            }
        }
        if (![picLoc.country isEqualToString:@""]) {
            if (isHeaderRequired) {
                picLocStr = [NSString stringWithFormat:@"%@%@ : %@%@", picLocStr, Localize(@"country"), picLoc.country, seperator];
            } else {
                picLocStr = [NSString stringWithFormat:@"%@ %@%@", picLocStr, picLoc.country, seperator];
            }
        }
        if (![picLoc.postcode isEqualToString:@""]) {
            if (isHeaderRequired) {
                picLocStr = [NSString stringWithFormat:@"%@%@ : %@%@", picLocStr, Localize(@"postcode"), picLoc.postcode, seperator];
            } else {
                picLocStr = [NSString stringWithFormat:@"%@ %@%@", picLocStr, picLoc.postcode, seperator];
            }
        }
        if (![picLoc.note isEqualToString:@""]) {
            if (isHeaderRequired) {
                picLocStr = [NSString stringWithFormat:@"%@%@ : %@%@", picLocStr, Localize(@"note"), picLoc.note, seperator];
            } else {
                picLocStr = [NSString stringWithFormat:@"%@ %@%@", picLocStr, picLoc.note, seperator];
            }
        }
//        if (![picLoc.cost isEqualToString:@""]) {
//            if (isHeaderRequired) {
//                picLocStr = [NSString stringWithFormat:@"%@%@ : %@", picLocStr, Localize(@"cost"), [[Utility sharedManager] convertToString:[picLoc.cost floatValue] isCurrency:true]];
//            } else {
//                picLocStr = [NSString stringWithFormat:@"%@ %@", picLocStr, [[Utility sharedManager] convertToString:[picLoc.cost floatValue] isCurrency:true]];
//            }
//        }
        
        if (![picLocStr isEqualToString:@""] && [picLocStr containsString:@","]) {
            NSRange lastComma = [picLocStr rangeOfString:@"," options:NSBackwardsSearch];
            if(lastComma.location != NSNotFound) {
                picLocStr = [picLocStr stringByReplacingCharactersInRange:lastComma
                                                   withString:@""];
            }
        }
        
        UILabel* label = [[UILabel alloc] init];
        [label setFrame:CGRectMake(self.view.frame.size.width * 0.1f, varPosY, self.view.frame.size.width * 0.6f, testHeight)];
        [label setAttributedText:[[NSAttributedString alloc] initWithString:picLocStr]];
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
//        [labelCost setFrame:CGRectMake(CGRectGetMaxX(label.frame), varPosY, self.view.frame.size.width - CGRectGetMaxX(label.frame) - self.view.frame.size.width * 0.1f, fontHeight)];
        [labelCost setAttributedText:[[NSAttributedString alloc] initWithString:picLocStrCost]];
        [labelCost setUIFont:kUIFontType17 isBold:true];
        [labelCost setTextColor:[Utility getUIColor:kUIColorFontLight]];
        [view addSubview:labelCost];
        [labelCost setTextAlignment:NSTextAlignmentRight];
        
        viewHeight = gap + CGRectGetMaxY(label.frame);
        [view setFrame:CGRectMake(viewPosX, viewPosY, viewWidth, viewHeight)];
        return view;
    }
    
    
//    self.buttonPickupSelection = [[UIButton alloc] init];
//    [self.buttonPickupSelection setFrame:CGRectMake(leftMarginInsideView, varPosY, widthInsideView, fontHeight * 10.0f)];
//    [self.buttonPickupSelection setTitle:Localize(@"select_pickup_location") forState:UIControlStateNormal];
//    [self.buttonPickupSelection setTitleColor:[Utility getUIColor:kUIColorBuyButtonNormalBg] forState:UIControlStateNormal];
//    [self.buttonPickupSelection.titleLabel setUIFont:kUIFontType18 isBold:false];
//    [self.buttonPickupSelection addTarget:self action:@selector(pickupSelectionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [self.buttonPickupSelection setTitleEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)];
//    [self.buttonPickupSelection setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
//    [self.buttonPickupSelection.layer setBorderWidth:1];
//    [view addSubview:self.buttonPickupSelection];
//    
//    
//    self.buttonPickupSelectionDownArrow = [[UIButton alloc] init];
//    [self.buttonPickupSelectionDownArrow setFrame:CGRectMake(leftMarginInsideView + widthInsideView - 50, varPosY, 50, fontHeight * 10.0f)];
//    [self.buttonPickupSelectionDownArrow addTarget:self action:@selector(timeSelectionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [self.buttonPickupSelectionDownArrow.imageView setContentMode:UIViewContentModeScaleAspectFit];
//    [self.buttonPickupSelectionDownArrow setImage:[[UIImage imageNamed:@"img_arrow_down_white"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
//    [self.buttonPickupSelectionDownArrow setTintColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
//    [self.buttonPickupSelectionDownArrow setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
//    [view addSubview:self.buttonPickupSelectionDownArrow];
//    varPosY = gap + CGRectGetMaxY(self.buttonPickupSelection.frame);
//    viewHeight = gap + varPosY;
//    [view setFrame:CGRectMake(viewPosX, viewPosY, viewWidth, viewHeight)];
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
        DateTimeSlot* minDateTimeSlot = [[DateTimeSlot getAllDateTimeSlots] objectAtIndex:0];
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
            [timeStrings addObject:ts.slotTitle];
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
        TimeSlot* timeSlot =  [self.timeSlotDataObjects objectAtIndex:clickedItemId];
        self.selected_time_slot = timeSlot;
        NSString* timeString = timeSlot.slotTitle;
        [self.buttonTimeSelection setTitle:timeString forState:UIControlStateNormal];
        [self.buttonTimeSelection setTitleColor:[Utility getUIColor:kUIColorFontDark] forState:UIControlStateNormal];
        [self.buttonTimeSelection.titleLabel setUIFont:kUIFontType18 isBold:true];
        [self.buttonTimeSelectionDownArrow setTintColor:[Utility getUIColor:kUIColorFontDark]];
    }
}
- (void)dateChanged:(UIDatePicker*)uiDatePicker{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd/MM/yyyy"];
    NSString* dateString = [dateFormat stringFromDate:uiDatePicker.date];
    for (DateTimeSlot* dts in [DateTimeSlot getAllDateTimeSlots]) {
        if ([[dts getDateSlot] isEqualToString:dateString]) {
            self.selected_date_time_slot = dts;
            break;
        }
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
    
}

- (UIView*)createShippingOptionView:(NSString*)errorMsg {
    
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
                [button.layer setValue:labelAmount forKey:@"MY_COST_LABEL"];
                [button.layer setValue:labelAmountColon forKey:@"MY_COST_LABEL_COLON"];
                [_chkBoxShipping addObject:button];
                
                
            
                
//                [button.layer setBorderWidth:1];
//                [button.titleLabel.layer setBorderWidth:1];
//                [button.imageView.layer setBorderWidth:1];
//                [labelAmount.layer setBorderWidth:1];
//                [labelAmountColon.layer setBorderWidth:1];
                
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
//    itemPosY += fontHeight;
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
    float width = view.frame.size.width * .50f;
    
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
        button.frame = CGRectMake(leftItemsPosX + 0, itemPosY,rightItemsPosX- leftItemsPosX-10, fontHeight);
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
    [view setFrame:CGRectMake(self.view.frame.size.width * 0.01f, 0, self.view.frame.size.width * 0.98f, [[labelTemp font] lineHeight] * 10)];
    
    float leftItemsPosX = self.view.frame.size.width * 0.10f;
    float rightItemsPosX = self.view.frame.size.width * 0.50f;
    float itemPosY = self.view.frame.size.width * 0.04f;
    float width = view.frame.size.width * .50f;
    
    [view setBackgroundColor:[UIColor whiteColor]];
    [_scrollView addSubview:view];
    [_viewsAdded addObject:view];
    [view setTag:kTagForGlobalSpacing];
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
    
    
    //    itemPosY += fontHeight;
    [view setFrame:CGRectMake(self.view.frame.size.width * 0.01f, 0, self.view.frame.size.width * 0.98f, itemPosY)];
    
    return view;
}
/*
 - (UIView*)createGrandTotalView {
 NSString* stringQuantityH = [NSString stringWithFormat:Localize(@"label_quantity")];
 NSString* stringQuantity = [NSString stringWithFormat:@"%d",[Cart getItemCount]];
 //    NSString* stringAmountH = [NSString stringWithFormat:Localize(@"i_cart_totals")];
 NSString* stringAmount = [NSString stringWithFormat:@"%@",[[Utility sharedManager] convertToString:[Cart getTotalPayment] isCurrency:true symbolAtLast:isCurrencySymbolAtLast]];
 NSString* stringGrandAmountH = [NSString stringWithFormat:Localize(@"i_grand_total")];
 NSString* stringGrandAmount = [NSString stringWithFormat:@"%@",[[Utility sharedManager] convertToString:[Cart getTotalPayment] isCurrency:true symbolAtLast:isCurrencySymbolAtLast]];
 
 
 
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
 [labelQuantityH setUIFont:kUIFontType18 isBold:false];
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
 [labelQuantityColon setTextColor:[Utility getUIColor:kUIColorFontDark]];
 if ([[TMLanguage sharedManager] isRTLEnabled]) {
 [labelQuantityColon setTextAlignment:NSTextAlignmentRight];
 } else {
 [labelQuantityColon setTextAlignment:NSTextAlignmentLeft];
 }
 [labelQuantityColon setText:@":"];
 [labelQuantityColon sizeToFitUI];
 [view addSubview:labelQuantityColon];
 
 UILabel* labelQuantity= [[UILabel alloc] init];
 [labelQuantity setUIFont:kUIFontType18 isBold:false];
 fontHeight = [[labelQuantity font] lineHeight];
 [labelQuantity setFrame:CGRectMake(rightItemsPosX + leftItemsPosX, itemPosY, width, fontHeight)];
 [labelQuantity setTextColor:[Utility getUIColor:kUIColorFontDark]];
 [labelQuantity setText:stringQuantity];
 if ([[TMLanguage sharedManager] isRTLEnabled]) {
 [labelQuantity setTextAlignment:NSTextAlignmentRight];
 } else {
 [labelQuantity setTextAlignment:NSTextAlignmentLeft];
 }
 [view addSubview:labelQuantity];
 itemPosY += (fontHeight + labelQuantityH.frame.size.height);
 
 //////////////////////////Amount//////////////////////////
 UILabel* labelAmountH= [[UILabel alloc] init];
 [labelAmountH setUIFont:kUIFontType18 isBold:false];
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
 
 UILabel* labelAmountColon= [[UILabel alloc] init];
 [labelAmountColon setUIFont:kUIFontType18 isBold:false];
 fontHeight = [[labelAmountColon font] lineHeight];
 [labelAmountColon setFrame:CGRectMake(rightItemsPosX, itemPosY, width, fontHeight)];
 [labelAmountColon setTextColor:[Utility getUIColor:kUIColorFontDark]];
 if ([[TMLanguage sharedManager] isRTLEnabled]) {
 [labelAmountColon setTextAlignment:NSTextAlignmentRight];
 } else {
 [labelAmountColon setTextAlignment:NSTextAlignmentLeft];
 }
 [labelAmountColon setText:@":"];
 [labelAmountColon sizeToFitUI];
 [view addSubview:labelAmountColon];
 
 UILabel* labelAmount= [[UILabel alloc] init];
 [labelAmount setUIFont:kUIFontType18 isBold:false];
 fontHeight = [[labelAmount font] lineHeight];
 [labelAmount setTextColor:[Utility getUIColor:kUIColorFontDark]];
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
 itemPosY += (fontHeight + labelAmountH.frame.size.height);
 
 TMPaymentSDK* tmPaymentSDK = [[DataManager sharedManager] tmPaymentSDK];
 TMShippingSDK* tmShippingSDK = [[DataManager sharedManager] tmShippingSDK];
 
 
 if(tmShippingSDK.shippingEnable && tmShippingSDK.shippingMethods) {
 for (TMShipping* shipMthod in tmShippingSDK.shippingMethods) {
 float shipCost = shipMthod.shippingCost;
 NSString* shipTitle = shipMthod.shippingLabel;
 
 UIButton* button = [[UIButton alloc] init];
 button.frame = CGRectMake(leftItemsPosX + 10, itemPosY,rightItemsPosX- leftItemsPosX-10, fontHeight);
 [button addTarget:self action:@selector(chkBoxShippingClicked:) forControlEvents:UIControlEventTouchUpInside];
 [view addSubview:button];
 [button setUIImage:[UIImage imageNamed:@"radiobtn_unselected"] forState:UIControlStateNormal];
 [button setUIImage:[UIImage imageNamed:@"radiobtn_selected"] forState:UIControlStateSelected];
 //            [button setTitle:[NSString stringWithFormat:@"\t%@  :  %@", shipTitle, [[Utility sharedManager] convertToString:shipCost isCurrency:true]] forState:UIControlStateNormal];
 [button setTitle:[NSString stringWithFormat:@"%@", shipTitle] forState:UIControlStateNormal];
 [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
 [button setTitleColor:[Utility getUIColor:kUIColorFontLight] forState:UIControlStateNormal];
 [button setTitleColor:[Utility getUIColor:kUIColorFontLight] forState:UIControlStateSelected];
 [button.titleLabel setUIFont:kUIFontType18 isBold:false];
 button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
 button.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
 
 if ([tmShippingSDK.shippingMethodChoosedId isEqualToString:shipMthod.shippingId]) {
 [button setSelected:YES];
 }else {
 [button setSelected:NO];
 }
 UILabel* tempLabel = [[UILabel alloc] initWithFrame:button.frame];
 tempLabel.text = [NSString stringWithFormat:@"%@", shipTitle];
 tempLabel.lineBreakMode = NSLineBreakByWordWrapping;
 tempLabel.numberOfLines = 0;
 [tempLabel sizeToFitUI];
 button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
 button.titleLabel.numberOfLines = 0;
 [button.titleLabel sizeToFitUI];
 [button setTitleEdgeInsets:UIEdgeInsetsMake(-5, 10, 0, 0)];
 CGRect btnR = button.frame;
 btnR.size.height = MAX(tempLabel.frame.size.height, btnR.size.height);
 btnR.size.height += fontHeight/2;
 button.frame = btnR;
 button.layer.frame = btnR;
 //            button.layer.borderWidth = 1;
 //////////////////////////Amount//////////////////////////
 UILabel* labelAmountColon= [[UILabel alloc] init];
 [labelAmountColon setUIFont:kUIFontType18 isBold:false];
 fontHeight = [[labelAmountColon font] lineHeight];
 [labelAmountColon setFrame:CGRectMake(rightItemsPosX, itemPosY, width, fontHeight)];
 [labelAmountColon setTextColor:[Utility getUIColor:kUIColorFontDark]];
 if ([[TMLanguage sharedManager] isRTLEnabled]) {
 [labelAmountColon setTextAlignment:NSTextAlignmentRight];
 } else {
 [labelAmountColon setTextAlignment:NSTextAlignmentLeft];
 }
 [labelAmountColon setText:@":"];
 [labelAmountColon sizeToFitUI];
 [view addSubview:labelAmountColon];
 
 
 
 UILabel* labelAmount= [[UILabel alloc] init];
 [labelAmount setUIFont:kUIFontType18 isBold:false];
 fontHeight = [[labelAmount font] lineHeight];
 [labelAmount setTextColor:[Utility getUIColor:kUIColorFontLight]];
 [view addSubview:labelAmount];
 NSString* shippingCost = [NSString stringWithFormat:@"%@",[[Utility sharedManager] convertToString:shipCost isCurrency:true symbolAtLast:isCurrencySymbolAtLast]];
 [labelAmount setText:shippingCost];
 if (isCurrencySymbolAtLast) {
 if ([[TMLanguage sharedManager] isRTLEnabled]) {
 [labelAmount setFrame:CGRectMake(rightItemsPosX + leftItemsPosX, itemPosY, width, fontHeight)];
 [labelAmount setTextAlignment:NSTextAlignmentRight];
 } else {
 [labelAmount setFrame:CGRectMake(rightItemsPosX - leftItemsPosX, itemPosY, width, fontHeight)];
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
 itemPosY += (fontHeight * 0.5f + btnR.size.height);
 
 [button.layer setValue:shipMthod forKey:@"MY_OBJECT"];
 [button.layer setValue:labelAmount forKey:@"MY_COST_LABEL"];
 [button.layer setValue:labelAmountColon forKey:@"MY_COST_LABEL_COLON"];
 [_chkBoxShipping addObject:button];
 
 }
 
 }
 
 itemPosY += (fontHeight * 1.5f);
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
 */
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
        UIBarButtonItem* doneBtn = [[UIBarButtonItem alloc]initWithTitle:Localize(@"Done") style:UIBarButtonItemStyleBordered target:self action:@selector(doneWithDeviceKeyPad:)];
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

- (void)chkBoxShippingClicked:(id)sender {
    UIButton* senderButton = (UIButton*)sender;
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
        _selectedShippingMethod = (TMShipping*)[senderButton.layer valueForKey:@"MY_OBJECT"];
        UILabel* label = (UILabel*)[senderButton.layer valueForKey:@"MY_COST_LABEL"];
        UILabel* labelColon = (UILabel*)[senderButton.layer valueForKey:@"MY_COST_LABEL_COLON"];
        [label setTextColor:[Utility getUIColor:kUIColorFontLight]];
        [label setUIFont:kUIFontType17 isBold:true];
        [senderButton.titleLabel setUIFont:kUIFontType17 isBold:true];
        NSString* stringGrandAmount = [NSString stringWithFormat:@"%@",[[Utility sharedManager] convertToString:[self calculateGrandTotal] isCurrency:true symbolAtLast:isCurrencySymbolAtLast]];
        [_labelGrandAmount setText:stringGrandAmount];
        [self refreshBlankOrder];
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
    [self adjustViewsAfterOrientation:[[UIDevice currentDevice] orientation]];
    [self resetMainScrollView];
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self adjustViewsForOrientation:[[UIDevice currentDevice] orientation]];
    [self resetMainScrollView];
}

- (void)paymentCompletionWithSuccess:(id)obj {
    RLOG(@"paymentCompletionWithSuccess");
    _screen_current_state = SCREEN_STATE_PAYMENT_DONE;
    
    //    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Success!" message:@"Payment done with success." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    //    [alertView show];
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
    _screen_current_state = SCREEN_STATE_ENTER;
    [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
    [[Utility sharedManager] stopGrayLoadingBar];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Localize(@"i_payment_failed_title") message:Localize(@"i_payment_failed_msg") delegate:nil cancelButtonTitle:Localize(@"ok") otherButtonTitles:nil];
    [alertView show];
}
- (void)updateOrderSuccess:(NSNotification*)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UPDATE_ORDER_SUCCESS" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UPDATE_ORDER_FAILURE" object:nil];
    RLOG(@"updateOrderSuccess");
    [self updateOrderRewardPoints:_blankOrder];
    _screen_current_state = SCREEN_STATE_EXIT;
    AppUser* appUser = [AppUser sharedManager];
    [appUser._cartArray removeAllObjects];
    [Cart resetOrderNotes];
    [appUser saveData];
#if PARSE_ANALYTICS_ENABLE
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
    ViewControllerOrderReceipt* vcOrderReceipt = (ViewControllerOrderReceipt*)[[Utility sharedManager] pushScreenWithoutAnimation:mainVC.vcCenterTop type:PUSH_SCREEN_TYPE_ORDER_RECEIPT];
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
//    float grandTotalWithoutShipping = [self calculateGrandTotalWithoutShipping];
    float shippingTotal = 0.0f;
    TMShipping* shipping = _selectedShippingMethod;
    if(shipping){
        shippingTotal = (float)_selectedShippingMethod.shippingCost;
        //Add shipping tax if available
//        for (NSString* taxString in shipping.shippingTaxes) {
//            shippingTotal += [taxString floatValue];
//        }
    }
    return shippingTotal;
}
- (float)calculateGrandTotalWithoutTax {
    float grandTotalWithoutShipping = [self calculateGrandTotalWithoutShipping];
    float shippingTotal = 0.0f;
    TMShipping* shipping = _selectedShippingMethod;
    if(shipping){
        shippingTotal = (float)_selectedShippingMethod.shippingCost;
        //Add shipping tax if available
        for (NSString* taxString in shipping.shippingTaxes) {
            shippingTotal += [taxString floatValue];
        }
    }
    return grandTotalWithoutShipping + shippingTotal;
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
    int pointsRedeemed = (int) ([Cart getPointsPriceDiscount] * 100.0f);
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
//    float grandTotalWithoutShipping = [self calculateGrandTotalWithoutShipping];
    float grandTotalShipping = [self calculateGrandTotalShipping];
    float taxAmount = [TM_TaxApplied calculateTotalTax:grandTotalShipping];
    
    if (taxAmount > 0) {
        if (_taxViewHeader == nil) {
            _taxViewHeader = [self addHeaderView:Localize(@"Tax Info") isTransparant:false];
            [Utility showShadow:_taxViewHeader];
        }
        UIView* view = [self createTaxView];
        view.layer.shadowOpacity = 0.0f;
        [Utility showShadow:view];
        [self resetMainScrollView];
    }
//   for (TM_Tax* tax in [TM_Tax getAllTaxes]) {
//        if ([tax shipping]) {
////            taxAmount += [self calculateChargeFromTax:grandTotalShipping tax:tax];
//        } else {
//            taxAmount += [self calculateChargeFromTax:grandTotalWithoutShipping tax:tax];
//        }
//    }
    float pickupCost = 0.0f;
    if ([[Addons sharedManager] show_pickup_location] && [[TM_PickupLocation getAllPickupLocations] count] > 0) {
        TM_PickupLocation* pckloc = [[TM_PickupLocation getAllPickupLocations] objectAtIndex:0];
        pickupCost = [pckloc.cost floatValue];
    }
    return grandTotalWithoutTax + taxAmount + pickupCost;
}
@end
