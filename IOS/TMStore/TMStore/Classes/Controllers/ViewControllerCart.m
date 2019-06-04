//
//  ViewControllerCart.m

//
//  Created by Rishabh Jain on 24/09/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import "ViewControllerCart.h"
#import "Utility.h"
#import "MyDevice.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "AppUser.h"
#import "Cart.h"
#import "Wishlist.h"
#import "ViewControllerCartConfirmation.h"
#import "ViewControllerLeft.h"
#import "ParseHelper.h"
#import "Variables.h"
#import "UIAlertView+NSCookbook.h"
#import "AppDelegate.h"
#import "UITextView+LocalizeConstrint.h"
#import "CartMeta.h"
#import "ViewControllerHome.h"
#import "ViewControllerMyCoupon.h"
#import "ViewControllerFilter.h"
#import "VCAddressMap.h"
//#import "ViewControllerHomeDynamic.h"
#import "AnalyticsHelper.h"
static int kTagForGlobalSpacing = 0;
static int kTagForNoSpacing = -1;

@implementation PairCart
@end


@interface ViewControllerCart () {
    NSMutableArray *_viewsAdded;
    NSMutableArray *_horizontalScrollViews;
    NSMutableArray *_tempPairArray;
    NSMutableArray* crossCellIds;
    
    MRProgressOverlayView* mrpoView;
}
@end

@implementation ViewControllerCart

#pragma mark - View Life Cycle

- (void)viewDidLoad {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super viewDidLoad];
    
//    Addons* addons = [Addons sharedManager];
//    addons.show_crosssell_products = false;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(CartLoginToggle:) name:@"CartLogInToggle" object:nil];
    
    RLOG(@"ViewControllerCart = %@", self);
    _strCollectionView2 = [[Utility sharedManager] getHorizontalViewString];
    _strCollectionView3 = [[Utility sharedManager] getHorizontalViewString];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cartPageDataLoaded:)
                                                 name:@"CART_PAGE_DATA_LOADED"
                                               object:nil];
    //    _tapper = [[UITapGestureRecognizer alloc]
    //              initWithTarget:self action:@selector(handleSingleTap:)];
    //    _tapper.cancelsTouchesInView = NO;
    //    [self.view addGestureRecognizer:_tapper];
    [self initVariables];
    [_labelNoItems setUIFont:kUIFontType20 isBold:false];
    _labelNoItems.textColor = [Utility getUIColor:kUIColorFontLight];
#if ESCAPE_CART_VARIFICATION
    return;
#endif
    if ([Cart getItemCount] > 0) {
        mrpoView = [Utility createCustomizedLoadingBar:Localize(@"verifying_cart") isBottomAlign:false isClearViewEnabled:false isShadowEnabled:true];
        [[[DataManager sharedManager] tmDataDoctor] fetchCartProductsDataFromPlugin:^(id data) {
            [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
            if (mrpoView) {
                [mrpoView dismiss:true];
                mrpoView = nil;
            }
            [self loadCartRewardPoints];
        } failure:^(NSString *error) {
            [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
            if (mrpoView) {
                [mrpoView dismiss:true];
                mrpoView = nil;
            }
        }];
    }
}


- (void)CartLoginToggle:(NSNotification*)notification {
    [self updateRewardDiscountView];
}
- (void)cartPageDataLoaded:(NSNotification*)notification {
    RLOG(@"CART REFRESHED");
    _alertViewUpdateCart = [[UIAlertView alloc] initWithTitle:Localize(@"i_refresh") message:Localize(@"i_refresh_cart_permission")
                                                     delegate:nil
                                            cancelButtonTitle:Localize(@"i_ok")
                                            otherButtonTitles:nil];
    [self alertView:_alertViewUpdateCart clickedButtonAtIndex:0];
    
    
    AppDelegate* appD = (AppDelegate*)[UIApplication sharedApplication].delegate;
    if (appD.isPrevScreenCouponCode) {
        appD.isPrevScreenCouponCode = false;
        _textFieldApplyCoupon.text = appD.nJsonData_couponCode;
        
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = @"";
        [self applyCoupon:nil];
        appD.nJsonData_couponCode = @"";
    }else{
        appD.isPrevScreenCouponCode = false;
        if (![appD.nJsonData_couponCode isEqualToString:@""]) {
            _textFieldApplyCoupon.text = appD.nJsonData_couponCode;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:Localize(@"coupon_code"), appD.nJsonData_couponCode] message:Localize(@"apply_coupon") delegate:nil cancelButtonTitle:Localize(@"btn_no") otherButtonTitles:Localize(@"btn_yes"),nil];
            [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if(buttonIndex == 0) {
                    _textFieldApplyCoupon.text = @"";
                }else{
                    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                    pasteboard.string = @"";
                    [self applyCoupon:nil];
                    appD.nJsonData_couponCode = @"";
                }
            }];
        }
    }
}
- (void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LoginCompletedCart" object:nil];
}
- (void)viewDidAppear:(BOOL)animated {
#if ENABLE_FIREBASE_TAG_MANAGER
    [[AnalyticsHelper sharedInstance] registerVisitScreenEvent:@"Cart Screen"];
#endif
}
- (void)viewWillAppear:(BOOL)animated {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super viewWillAppear:animated];
    
    _isKeyboardVisible = false;
    if ([Coupon getAllCoupons] == NULL) {
        [[[DataManager sharedManager] tmDataDoctor] fetchCouponsData:nil];
    }
    
    //rv//[SDWebImageManager.sharedManager.imageDownloader setValue:@"SDWebImage Demo" forHTTPHeaderField:@"AppName"];
//    SDWebImageManager.sharedManager.imageDownloader.executionOrder = SDWebImageDownloaderFIFOExecutionOrder;
    
    
    _couponView = nil;
    _couponViewWithAppliedCoupon = nil;
    _couponViewWithTextField = nil;
    
    _rewardDiscountView = nil;
    _rewardDiscountViewWithTextField = nil;
    
    _autoAppliedCouponView = nil;
    [self loadViewDA];
    [Cart resetNotificationItemCount];
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
- (void)flushCache {
    [SDWebImageManager.sharedManager.imageCache clearMemory];
    
}
- (void)initVariables {
    [_scrollView setBackgroundColor:[Utility getUIColor:kUIColorBgTheme]];
    _viewsAdded = [[NSMutableArray alloc] init];
    _tempPairArray = [[NSMutableArray alloc] init];
    _cartNotesTextViews = [[NSMutableArray alloc] init];
    _rewardPointsApplied = false;
    for (int i = 0; i < _kTotalViewsCartScreen; i++) {
        _viewUserDefined[i] = nil;
        _propCollectionView[i] = [[LayoutProperties alloc] initWithCollectionViewValues:SCROLL_TYPE_SHOWFULL];
        _viewUserDefinedHeaderString[i] = @"";
        _viewUserDefinedHeader[i] = nil;
        _isViewUserDefinedEnable[i] = false;
    }
    _isViewUserDefinedEnable[_kCrossSell] = false;
    _viewUserDefinedHeaderString[_kCrossSell] = Localize(@"header_crosssells_cart");
    _viewKey[_kCrossSell] = @"like_first";
    Addons* addons = [Addons sharedManager];
    if (addons.show_crosssell_products == true) {
        _isViewUserDefinedEnable[_kCrossSell] = true;
    }
}
- (void)loadViewDA {
    [_cartNotesTextViews removeAllObjects];
    [_tempPairArray removeAllObjects];
    for (UIView* view in _viewsAdded) {
        [view removeFromSuperview];
    }
    [_viewsAdded removeAllObjects];
    _couponView = nil;
    [self.view setBackgroundColor:[Utility getUIColor:kUIColorBgTheme]];
    
    int itemsCount = (int)[[[AppUser sharedManager] _cartArray] count];
    if (itemsCount > 0) {
        _scrollView.hidden = false;
        _footerView.hidden = false;
        _labelNoItems.hidden = true;
        for (int i = 0; i < itemsCount; i++) {
            Cart* c = (Cart*)[[[AppUser sharedManager] _cartArray] objectAtIndex:i];
            /*UIView* view = */[self addView:i pInfo:c.product isCartItem:true isWishlistItem:false quantity:c.count];
#if ENABLE_CART_NOTE
            if ([[Addons sharedManager] cartNote]){
                if ([[[Addons sharedManager] cartNote] note_location] == CART_NOTE_LOCATION_AFTER_EACH_ITEM || [[[Addons sharedManager] cartNote] note_location] == CART_NOTE_LOCATION_BOTH) {
                    UITextView* textView = [[UITextView alloc] init];
                    [_cartNotesTextViews addObject:textView];
                    [textView.layer setValue:c forKey:@"MY_OBJECT"];
                    UIView* view = [self createNotesView:textView];
                    [Utility showShadow:view];
                }
            }
#endif
        }
        
        _couponView = [self addCouponView];
        if (_couponView) {
            [_couponView setTag:kTagForGlobalSpacing];
        }
        
        
        Addons* addon = [Addons sharedManager];
        if (addon.enable_auto_coupons) {
            _autoAppliedCouponView = [self createAppliedCouponView];
            if (_autoAppliedCouponView) {
                [_autoAppliedCouponView setTag:kTagForGlobalSpacing];
            }
        }
        
        
        
        _rewardDiscountView = [self addRewardDiscountView];
        if (_rewardDiscountView) {
            [_rewardDiscountView setTag:kTagForGlobalSpacing];
            [self updateRewardDiscountView];
        }
        
        
        if (([[GuestConfig sharedInstance] hide_price] && ![AppUser isSignedIn]) || [[Addons sharedManager] hide_price]) {
        } else {
            _finalAmountView = [self addFinalAmountView];
            if (_finalAmountView) {
                [_finalAmountView setTag:kTagForGlobalSpacing];
            }
        }
        
        
        
        
        
#if ENABLE_CART_NOTE
        if ([[Addons sharedManager] cartNote]){
            if ([[[Addons sharedManager] cartNote] note_location] == CART_NOTE_LOCATION_BEFORE_PLACE_ORDER_BUTTON || [[[Addons sharedManager] cartNote] note_location] == CART_NOTE_LOCATION_BOTH) {
                UITextView* textView = [[UITextView alloc] init];
                [_cartNotesTextViews addObject:textView];
                UIView* view = [self createNotesView:textView];
                [view setTag:kTagForGlobalSpacing];
                [Utility showShadow:view];
            }
        }
#endif
        //_placeOrderButton = [self addPlaceOrderButton];
        //[_placeOrderButton setTag:kTagForGlobalSpacing];
    }else{
        _scrollView.hidden = true;
        _footerView.hidden = true;
        _labelNoItems.hidden = false;
        _labelNoItems.text = Localize(@"no_items_in_cart");
        [_labelNoItems setUIFont:kUIFontType20 isBold:false];
        _labelNoItems.textColor = [Utility getUIColor:kUIColorFontLight];
        _couponView = nil;
        _finalAmountView = nil;
        _placeOrderButton = nil;
    }
    Addons* addons = [Addons sharedManager];
    if (addons.show_crosssell_products == true) {
        crossCellIds = [[NSMutableArray alloc] init];
        for (NSObject* obj in [Cart getAll]) {
            Cart* cInfo = (Cart*)obj;
            if (cInfo.product._cross_sell_ids) {
                for (id csObj in cInfo.product._cross_sell_ids) {
                    [crossCellIds addObject:csObj];
                }
            }
        }
        if (crossCellIds !=nil && [crossCellIds count] > 0) {
            _isViewUserDefinedEnable[_kCrossSell] = true;
            [self createVariousViews];
        }
    }
    [self keepShoppingAndPlaceorderButtonView];
    [self resetMainScrollView:0.0f];
    [self updateViews];
    [self loadCartRewardPoints];
}

- (void)myEvent:(UIButton*)button {
    if (_isKeyboardVisible) {
        return;
    }
    
    int variationId = -1;
    int variationIndex = -1;
    Cart* cart = nil;
    for (PairCart* p in _tempPairArray) {
        if(button == p.buttonImage){
            variationId = p.cart.selectedVariationId;
            variationIndex = p.cart.selectedVariationIndex;
            cart = p.cart;
            break;
        }
    }
    int productId = (int)button.tag;
    [self clickOnProduct:[ProductInfo getProductWithId:productId] currentItemData:nil variationId:variationId variationIndex:variationIndex cart:cart];
}
- (UIView*)updateCouponView {
    [self addCouponView];
    [self updateRewardDiscountView];
    [self updateViews];
    [self resetMainScrollView:0.1f];
    
    return nil;
}
- (UIView*)addCouponView {
    DataManager* dm = [DataManager sharedManager];
    if (dm.enable_coupons == false) {
       return nil;
    }
    
    float fontHeight = [[Utility getUIFont:kUIFontType18 isBold:false] lineHeight];
    float viewMaxHeight = 0;
    float viewMaxWidth = self.view.frame.size.width * .98f;
    float viewOriginX = self.view.frame.size.width * .01f;
    float viewOriginY = self.view.frame.size.width * .01f;
    
    UIView* view;
    if (_couponView == nil) {
        view = [[UIView alloc] init];
        [view setFrame:CGRectMake(viewOriginX, viewOriginY, viewMaxWidth, viewMaxHeight)];
        //        [view.layer setBorderColor:[[Utility getUIColor:kUIColorBorder] CGColor]];
        //        [view.layer setBorderWidth:1];
        [view setBackgroundColor:[UIColor whiteColor]];
        [_scrollView addSubview:view];
        [_viewsAdded addObject:view];
        [view setTag:kTagForNoSpacing];
    } else {
        view = _couponView;
    }
    
    
    float elementPosYInTopView = self.view.frame.size.width * .02f;
    float diff = self.view.frame.size.width * .025f;
    UIView* viewWithAppliedCoupons;
    if (_couponViewWithAppliedCoupon == nil) {
        viewWithAppliedCoupons = [[UIView alloc] init];
        _couponViewWithAppliedCoupon = viewWithAppliedCoupons;
    }else{
        viewWithAppliedCoupons = _couponViewWithAppliedCoupon;
        for (UIView* v in [viewWithAppliedCoupons subviews]) {
            [v removeFromSuperview];
        }
    }
    [viewWithAppliedCoupons setFrame:CGRectMake(0, 0, view.frame.size.width, 0)];
    [viewWithAppliedCoupons setBackgroundColor:[UIColor whiteColor]];
    [view addSubview:viewWithAppliedCoupons];
    if ([[Cart getAppliedCoupons] count] > 0) {
        UILabel* labelAppliedCoupon = [[UILabel alloc] init];
        [labelAppliedCoupon setFrame:CGRectMake(self.view.frame.size.width * .02f, elementPosYInTopView, view.frame.size.width, view.frame.size.height)];
        [labelAppliedCoupon setUIFont:kUIFontType18 isBold:false];
        [labelAppliedCoupon setText:Localize(@"applied_coupons")];
        [labelAppliedCoupon setTextColor:[Utility getUIColor:kUIColorFontLight]];
        [labelAppliedCoupon sizeToFitUI];
        [viewWithAppliedCoupons addSubview:labelAppliedCoupon];
        elementPosYInTopView += (fontHeight + diff);
        
        int appliedCouponWidth = [[MyDevice sharedManager] screenWidthInPortrait] * .5f;
        int appliedCouponRemoveWidth = 50;
        int appliedCouponHeight = 30;
        int differenceBtnButton = 20;
        int appliedCouponPosX =  (viewMaxWidth  - (appliedCouponWidth + differenceBtnButton + appliedCouponRemoveWidth))/2;
        int appliedCouponRemovePosX = appliedCouponPosX + appliedCouponWidth + differenceBtnButton;
        //    for (Coupon* coupon in [Coupon getAllCoupons]) {
        for (Coupon* coupon in [Cart getAppliedCoupons]) {
            UIButton* buttonCoupon  = [[UIButton alloc] init];
            [viewWithAppliedCoupons addSubview:buttonCoupon];
            [buttonCoupon setFrame:CGRectMake(appliedCouponPosX, elementPosYInTopView, appliedCouponWidth, appliedCouponHeight)];
            [buttonCoupon setBackgroundColor:[UIColor clearColor]];
            [buttonCoupon setTitle:[NSString stringWithFormat:@"%@", coupon._code] forState:UIControlStateNormal];
            [buttonCoupon setUserInteractionEnabled:false];
            [buttonCoupon setTitleColor:[Utility getUIColor:kUIColorFontLight] forState:UIControlStateNormal];
            [buttonCoupon.layer setBorderColor:[[Utility getUIColor:kUIColorBorder] CGColor]];
            [buttonCoupon.layer setBorderWidth:1];
            [buttonCoupon.titleLabel setUIFont:kUIFontType14 isBold:true];
            
            
            
            UIButton* buttonCouponRemove = [[UIButton alloc] init];
            [viewWithAppliedCoupons addSubview:buttonCouponRemove];
            [buttonCouponRemove setFrame:CGRectMake(appliedCouponRemovePosX, elementPosYInTopView, appliedCouponRemoveWidth, appliedCouponHeight)];
            UIImage* normal = [[UIImage imageNamed:@"remove"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            UIImage* selected = [[UIImage imageNamed:@"remove_on"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            UIImage* highlighted = [[UIImage imageNamed:@"remove_on"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [buttonCouponRemove setUIImage:normal forState:UIControlStateNormal];
            [buttonCouponRemove setUIImage:selected forState:UIControlStateSelected];
            [buttonCouponRemove setUIImage:highlighted forState:UIControlStateHighlighted];
            [buttonCouponRemove.imageView setContentMode:UIViewContentModeScaleAspectFit];
            [buttonCouponRemove setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
            [buttonCouponRemove addTarget:self action:@selector(removeCoupon:) forControlEvents:UIControlEventTouchUpInside];
            [buttonCouponRemove.layer setValue:coupon forKey:@"MY_OBJECT"];
            elementPosYInTopView += (appliedCouponHeight + diff);
            
            [buttonCouponRemove setTintColor:[Utility getUIColor:kUIColorThemeButtonSelected]];
        }
    } else {
        elementPosYInTopView = 0;
    }
    
    
    
    
    float elementPosYInBottomView = self.view.frame.size.width * .02f;
    UIView* viewWithTextField;
    if (_couponViewWithTextField == nil) {
        viewWithTextField = [[UIView alloc] init];
        _couponViewWithTextField = viewWithTextField;
        [viewWithTextField setFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)];
        [viewWithTextField setBackgroundColor:[UIColor whiteColor]];
        [view addSubview:viewWithTextField];
        
        elementPosYInBottomView += diff;
        UILabel* labelApplyNewCoupon = [[UILabel alloc] init];
        [viewWithTextField addSubview:labelApplyNewCoupon];
        [labelApplyNewCoupon setFrame:CGRectMake(self.view.frame.size.width * .02f, elementPosYInBottomView, view.frame.size.width * .96f, fontHeight)];
        [labelApplyNewCoupon setUIFont:kUIFontType18 isBold:false];
        [labelApplyNewCoupon setText:Localize(@"apply_new_coupon")];
        [labelApplyNewCoupon setTextColor:[Utility getUIColor:kUIColorFontLight]];
        [labelApplyNewCoupon sizeToFitUI];
        elementPosYInBottomView += (fontHeight + diff);
        
        elementPosYInBottomView += diff;
        _textFieldApplyCoupon = [[UITextField alloc] init];
        [viewWithTextField addSubview:_textFieldApplyCoupon];
        
        float buttonWidth;
        
        if ([[MyDevice sharedManager] isIpad]) {
            buttonWidth = [[MyDevice sharedManager] screenWidthInPortrait] * .30f;
        } else {
            buttonWidth = [[MyDevice sharedManager] screenWidthInPortrait] * .40f;
        }
        
        
        [_textFieldApplyCoupon setFrame:CGRectMake(
                                                   self.view.frame.size.width * .46f -  buttonWidth,
                                                   elementPosYInBottomView,
                                                   buttonWidth,
                                                   fontHeight*2
                                                   )];
        
        [_textFieldApplyCoupon setUIFont:kUIFontType18 isBold:false];
        [_textFieldApplyCoupon setPlaceholder:Localize(@"enter_coupon_code")];
        [_textFieldApplyCoupon setTextColor:[Utility getUIColor:kUIColorFontLight]];
        [_textFieldApplyCoupon.layer setBorderColor:[[Utility getUIColor:kUIColorThemeButtonBorderSelected] CGColor]];
        [_textFieldApplyCoupon.layer setBorderWidth:1];
        [_textFieldApplyCoupon setTextAlignment:NSTextAlignmentCenter];
        [_textFieldApplyCoupon setReturnKeyType:UIReturnKeyDone];
        [_textFieldApplyCoupon setContentVerticalAlignment: UIControlContentVerticalAlignmentCenter];
        [_textFieldApplyCoupon setDelegate:self];
        if (![_userSelectedCouponCode isEqualToString:@""]) {
            [_textFieldApplyCoupon setText:_userSelectedCouponCode];
        }
//        UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
//        if ([[TMLanguage sharedManager] isRTLEnabled]) {
//            [_textFieldApplyCoupon setRightViewMode:UITextFieldViewModeAlways];
//            [_textFieldApplyCoupon setRightView:spacerView];
//        } else {
//            [_textFieldApplyCoupon setLeftViewMode:UITextFieldViewModeAlways];
//            [_textFieldApplyCoupon setLeftView:spacerView];
//        }
        
        
        
        
        
        
        UIButton* buttonApply  = [[UIButton alloc] init];
        [viewWithTextField addSubview:buttonApply];
        
        [buttonApply setFrame:CGRectMake(
                                         self.view.frame.size.width * .52f,
                                         elementPosYInBottomView,
                                         buttonWidth,
                                         fontHeight*2
                                         )];
        
        [buttonApply setBackgroundColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
        [buttonApply setTitleColor:[Utility getUIColor:kUIColorBuyButtonFont] forState:UIControlStateNormal];
        [[buttonApply titleLabel] setUIFont:kUIFontType18 isBold:false];
        [buttonApply setTitle:Localize(@"apply") forState:UIControlStateNormal];
        [buttonApply addTarget:self action:@selector(applyCoupon:) forControlEvents:UIControlEventTouchUpInside];
      
        elementPosYInBottomView += (fontHeight*2 + diff);
        
        if (![[Addons sharedManager] hide_coupon_list]) {
            
            UIButton* buttonMyCoupon  = [[UIButton alloc] init];
            [viewWithTextField addSubview:buttonMyCoupon];
            
            [buttonMyCoupon setFrame:CGRectMake(
                                                self.view.frame.size.width * .50f - (buttonWidth/2),
                                                elementPosYInBottomView,
                                                buttonWidth,
                                                fontHeight*2
                                                )];
            
            [buttonMyCoupon setBackgroundColor:[UIColor clearColor]];
            [buttonMyCoupon setTitleColor:[Utility getUIColor:kUIColorBuyButtonNormalBg] forState:UIControlStateNormal];
            [[buttonMyCoupon titleLabel] setUIFont:kUIFontType18 isBold:false];
            [buttonMyCoupon setTitle:Localize(@"my_coupons") forState:UIControlStateNormal];
            [buttonMyCoupon addTarget:self action:@selector(myCoupone:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        
        elementPosYInBottomView += (fontHeight*2 + diff);
        
        //    UILabel* labelCouponMessage = [[UILabel alloc] init];
        //    [viewWithTextField addSubview:labelCouponMessage];
        //    [labelCouponMessage setFrame:CGRectMake(self.view.frame.size.width * .02f, elementPosYInBottomView, view.frame.size.width * .96f, fontHeight)];
        //    [labelCouponMessage setUIFont:kUIFontType18 isBold:false];
        //    [labelCouponMessage setText:@""];
        //    [labelCouponMessage setTextColor:[Utility getUIColor:kUIColorFontLight]];
        //    [labelCouponMessage setTextAlignment:NSTextAlignmentCenter];
        //    elementPosYInBottomView += (fontHeight + diff);
    }else{
        viewWithTextField = _couponViewWithTextField;
        elementPosYInBottomView = _couponViewWithTextField.frame.size.height;
    }
    
    
    
    
    
    CGRect rect;
    BOOL isApplyCouponIsOnTop = true;
    
    if (isApplyCouponIsOnTop) {
        rect = viewWithAppliedCoupons.frame;
        rect.origin.y = elementPosYInBottomView;
        rect.size.height = elementPosYInTopView;
        [viewWithAppliedCoupons setFrame:rect];
        
        rect = viewWithTextField.frame;
        rect.size.height = elementPosYInBottomView;
        [viewWithTextField setFrame:rect];
    }else{
        rect = viewWithAppliedCoupons.frame;
        rect.size.height = elementPosYInTopView;
        [viewWithAppliedCoupons setFrame:rect];
        
        rect = viewWithTextField.frame;
        rect.origin.y = elementPosYInTopView;
        rect.size.height = elementPosYInBottomView;
        [viewWithTextField setFrame:rect];
    }
    
    rect = view.frame;
    rect.size.height = elementPosYInTopView + elementPosYInBottomView + diff;
    [view setFrame:rect];
    
    [view.layer setShadowOpacity:0.0f];
    [Utility showShadow:view];
    
    
    
    
    return view;
}

- (void)updateRewardDiscountView {
    if (_labelApplyRewardDiscountDesc == nil) {
        [_rewardDiscountView setTag:kTagForNoSpacing];
        [self updateViews];
        [self resetMainScrollView:0.0f];
        return;
    }
    _labelApplyRewardDiscountDesc.transform = CGAffineTransformMakeTranslation(20, 0);
    [UIView animateWithDuration:0.4 delay:0.0 usingSpringWithDamping:0.2 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _labelApplyRewardDiscountDesc.transform = CGAffineTransformIdentity;
    } completion:nil];
    
    int earnPoints = [self getTotalRewardPoints];
    
    AppUser* appUser = [AppUser sharedManager];
    if (_rewardPointsApplied) {
        float useDiscounts = [[AppUser sharedManager] rewardDiscount];
        [Cart setPointsPriceDiscount:useDiscounts];
        float cartPointPriceDiscount = [Cart getPointsPriceDiscount];
        int usePoints = appUser.rewardPoints;//(int)(cartPointPriceDiscount * 100.0f);
        NSString* useDiscountStr = [[Utility sharedManager] convertToString:cartPointPriceDiscount isCurrency:true];
        [_labelApplyRewardDiscountHeading setText:[NSString stringWithFormat:Localize(@"earn_points_desc"), earnPoints]];
        [_labelApplyRewardDiscountHeading sizeToFitUI];
        [_labelApplyRewardDiscountDesc setText:[NSString stringWithFormat:Localize(@"used_points_desc"), usePoints, useDiscountStr]];
        float buttonWidth;
        if ([[MyDevice sharedManager] isIpad]) {
            buttonWidth = [[MyDevice sharedManager] screenWidthInPortrait] * .30f;
        } else {
            buttonWidth = [[MyDevice sharedManager] screenWidthInPortrait] * .40f;
        }
        [_labelApplyRewardDiscountDesc setFrame:CGRectMake(_labelApplyRewardDiscountDesc.frame.origin.x, _labelApplyRewardDiscountDesc.frame.origin.y, buttonWidth, _labelApplyRewardDiscountDesc.frame.size.height)];
        [_labelApplyRewardDiscountDesc sizeToFitUI];
        
        [_buttonApplyRewardDiscount setTitle:Localize(@"remove_discount") forState:UIControlStateNormal];
        _buttonApplyRewardDiscount.center = CGPointMake(_buttonApplyRewardDiscount.center.x, _labelApplyRewardDiscountDesc.center.y);
    } else {
        [Cart setPointsPriceDiscount:0];
        int usePoints = appUser.rewardPoints;
        float useDiscounts = appUser.rewardDiscount;
        NSString* useDiscountStr = [[Utility sharedManager] convertToString:useDiscounts isCurrency:true];
        [_labelApplyRewardDiscountHeading setText:[NSString stringWithFormat:Localize(@"earn_points_desc"), earnPoints]];
        [_labelApplyRewardDiscountHeading sizeToFitUI];
        [_labelApplyRewardDiscountDesc setText:[NSString stringWithFormat:Localize(@"use_points_desc"), usePoints, useDiscountStr]];
        float buttonWidth;
        if ([[MyDevice sharedManager] isIpad]) {
            buttonWidth = [[MyDevice sharedManager] screenWidthInPortrait] * .30f;
        } else {
            buttonWidth = [[MyDevice sharedManager] screenWidthInPortrait] * .40f;
        }
        [_labelApplyRewardDiscountDesc setFrame:CGRectMake(_labelApplyRewardDiscountDesc.frame.origin.x, _labelApplyRewardDiscountDesc.frame.origin.y, buttonWidth, _labelApplyRewardDiscountDesc.frame.size.height)];
        [_labelApplyRewardDiscountDesc sizeToFitUI];
        [_buttonApplyRewardDiscount setTitle:Localize(@"apply_discount") forState:UIControlStateNormal];
        _buttonApplyRewardDiscount.center = CGPointMake(_buttonApplyRewardDiscount.center.x, _labelApplyRewardDiscountDesc.center.y);
    }
    int usePoints = appUser.rewardPoints;
    if (usePoints > 0) {
        _rewardDiscountViewWithTextField.frame = CGRectMake(self.view.frame.size.width* 0.01f, _rewardDiscountViewWithTextField.frame.origin.y, _rewardDiscountViewWithTextField.frame.size.width, CGRectGetMaxY(_labelApplyRewardDiscountDesc.frame) + self.view.frame.size.width* 0.04f);
        _rewardDiscountView.frame = _rewardDiscountViewWithTextField.frame;
        _labelApplyRewardDiscountDesc.hidden = false;
        _buttonApplyRewardDiscount.hidden = false;
    } else {
        _rewardDiscountViewWithTextField.frame = CGRectMake(self.view.frame.size.width* 0.01f, _rewardDiscountViewWithTextField.frame.origin.y, _rewardDiscountViewWithTextField.frame.size.width, CGRectGetMaxY(_labelApplyRewardDiscountHeading.frame) + self.view.frame.size.width* 0.04f);
        _rewardDiscountView.frame = _rewardDiscountViewWithTextField.frame;
        _labelApplyRewardDiscountDesc.hidden = true;
        _buttonApplyRewardDiscount.hidden = true;
    }
    _rewardDiscountView.layer.shadowOpacity = 0.0f;
    [Utility showShadow:_rewardDiscountView];
    
    if (earnPoints == 0) {
        if (_labelApplyRewardDiscountDesc.hidden && _buttonApplyRewardDiscount.hidden) {
            _labelApplyRewardDiscountHeading.hidden = true;
            _rewardDiscountViewWithTextField.frame = CGRectMake(_rewardDiscountViewWithTextField.frame.origin.x, _rewardDiscountViewWithTextField.frame.origin.y, _rewardDiscountViewWithTextField.frame.size.width, 0);
            _rewardDiscountView.frame = _rewardDiscountViewWithTextField.frame;
            _rewardDiscountView.layer.shadowOpacity = 0.0f;
        } else {
            _labelApplyRewardDiscountHeading.hidden = false;
            if ([[TMLanguage sharedManager] isRTLEnabled]) {
                _labelApplyRewardDiscountHeading.text = [NSString stringWithFormat:@":%@", Localize(@"Reward Points")];
            } else {
                _labelApplyRewardDiscountHeading.text = [NSString stringWithFormat:@"%@:", Localize(@"Reward Points")];
            }
        }
    }
    else {
        _labelApplyRewardDiscountHeading.hidden = false;
    }
    
    if (_labelApplyRewardDiscountHeading.hidden &&
        _labelApplyRewardDiscountDesc.hidden &&
        _buttonApplyRewardDiscount.hidden) {
        [_rewardDiscountView setTag:kTagForNoSpacing];
    } else {
        [_rewardDiscountView setTag:kTagForGlobalSpacing];
    }
    
    _rewardDiscountViewWithTextField.backgroundColor = [UIColor clearColor];

    [self updateViews];
    [self resetMainScrollView:0.0f];
}
- (UIView*)addRewardDiscountView {
    float fontHeight = [[Utility getUIFont:kUIFontType18 isBold:false] lineHeight];
    float viewMaxHeight = 0;
    float viewMaxWidth = self.view.frame.size.width * .98f;
    float viewOriginX = self.view.frame.size.width * .01f;
    float viewOriginY = self.view.frame.size.width * .01f;
    AppUser* appUser = [AppUser sharedManager];
    
    int earnPoints = [self getTotalRewardPoints];
    int usePoints = appUser.rewardPoints;
    float useDiscounts = appUser.rewardDiscount;
    NSString* useDiscountStr = [[Utility sharedManager] convertToString:useDiscounts isCurrency:true];
    
    
    
    
    UIView* view;
    if (_rewardDiscountView == nil) {
        view = [[UIView alloc] init];
        [view setFrame:CGRectMake(viewOriginX, viewOriginY, viewMaxWidth, viewMaxHeight)];
        [view setBackgroundColor:[UIColor whiteColor]];
        [_scrollView addSubview:view];
        [_viewsAdded addObject:view];
        [view setTag:kTagForNoSpacing];
        _rewardDiscountView = view;
    }else{
        view = _rewardDiscountView;
    }
    
    
    float elementPosYInTopView = self.view.frame.size.width * .02f;
    float diff = self.view.frame.size.width * .025f;
    
    float elementPosYInBottomView = self.view.frame.size.width * .02f;
    UIView* viewWithTextField;
    if (_rewardDiscountViewWithTextField == nil) {
        viewWithTextField = [[UIView alloc] init];
        _rewardDiscountViewWithTextField = viewWithTextField;
        [viewWithTextField setFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)];
        [viewWithTextField setBackgroundColor:[UIColor whiteColor]];
        [view addSubview:viewWithTextField];
        
        elementPosYInBottomView += diff;
        _labelApplyRewardDiscountHeading = [[UILabel alloc] init];
        [viewWithTextField addSubview:_labelApplyRewardDiscountHeading];
        
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [_labelApplyRewardDiscountHeading setTextAlignment:NSTextAlignmentRight];
        } else {
            [_labelApplyRewardDiscountHeading setTextAlignment:NSTextAlignmentLeft];
        }
        [_labelApplyRewardDiscountHeading setFrame:CGRectMake(self.view.frame.size.width * .01f, elementPosYInBottomView, view.frame.size.width * .98f, fontHeight)];
        [_labelApplyRewardDiscountHeading setUIFont:kUIFontType18 isBold:false];
        [_labelApplyRewardDiscountHeading setText:[NSString stringWithFormat:Localize(@"earn_points_desc"), earnPoints]];
        [_labelApplyRewardDiscountHeading setTextColor:[Utility getUIColor:kUIColorFontLight]];
        [_labelApplyRewardDiscountHeading setNumberOfLines:0];
        [_labelApplyRewardDiscountHeading sizeToFitUI];
        elementPosYInBottomView = (CGRectGetMaxY(_labelApplyRewardDiscountHeading.frame)  + diff);
        
        _labelApplyRewardDiscountDesc = [[UILabel alloc] init];
        [viewWithTextField addSubview:_labelApplyRewardDiscountDesc];
        
        float buttonWidth;
        
        if ([[MyDevice sharedManager] isIpad]) {
            buttonWidth = [[MyDevice sharedManager] screenWidthInPortrait] * .30f;
        } else {
            buttonWidth = [[MyDevice sharedManager] screenWidthInPortrait] * .40f;
        }
        
        
        [_labelApplyRewardDiscountDesc setFrame:CGRectMake(
                                                           self.view.frame.size.width * .46f -  buttonWidth,
                                                           elementPosYInBottomView,
                                                           buttonWidth,
                                                           fontHeight*2
                                                           )];
        
        [_labelApplyRewardDiscountDesc setUIFont:kUIFontType18 isBold:false];
//        RLOG(Localize(@"use_points_desc"));
        [_labelApplyRewardDiscountDesc setText:[NSString stringWithFormat:Localize(@"use_points_desc"), usePoints, useDiscountStr]];
        [_labelApplyRewardDiscountDesc setTextColor:[Utility getUIColor:kUIColorFontLight]];
        [_labelApplyRewardDiscountDesc setTextAlignment:NSTextAlignmentCenter];
        [_labelApplyRewardDiscountDesc setNumberOfLines:0];
        [_labelApplyRewardDiscountDesc sizeToFitUI];
        
        _buttonApplyRewardDiscount  = [[UIButton alloc] init];
        [viewWithTextField addSubview:_buttonApplyRewardDiscount];
        
        [_buttonApplyRewardDiscount setFrame:CGRectMake(
                                                        self.view.frame.size.width * .52f,
                                                        elementPosYInBottomView,
                                                        buttonWidth,
                                                        fontHeight*2
                                                        )];
        
        [_buttonApplyRewardDiscount setBackgroundColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
        [_buttonApplyRewardDiscount setTitleColor:[Utility getUIColor:kUIColorBuyButtonFont] forState:UIControlStateNormal];
        [[_buttonApplyRewardDiscount titleLabel] setUIFont:kUIFontType18 isBold:false];
        [_buttonApplyRewardDiscount setTitle:Localize(@"apply_discount") forState:UIControlStateNormal];
        [_buttonApplyRewardDiscount addTarget:self action:@selector(applyRewardDiscount:) forControlEvents:UIControlEventTouchUpInside];
        
        _buttonApplyRewardDiscount.center = CGPointMake(_buttonApplyRewardDiscount.center.x, _labelApplyRewardDiscountDesc.center.y);
        elementPosYInBottomView += (fontHeight*2 + diff);
    } else{
        viewWithTextField = _rewardDiscountViewWithTextField;
        elementPosYInBottomView = _rewardDiscountViewWithTextField.frame.size.height;
    }
    
    CGRect rect = viewWithTextField.frame;
    rect.size.height = elementPosYInBottomView;
    [viewWithTextField setFrame:rect];
    
    rect = view.frame;
    rect.size.height = elementPosYInTopView + elementPosYInBottomView + diff;
    [view setFrame:rect];
    
    [view.layer setShadowOpacity:0.0f];
    [Utility showShadow:view];
    
    
    [self updateRewardDiscountView];
    return view;
}
- (void)showCouponError:(NSString*)msg {
    _textFieldApplyCoupon.text = @"";
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:Localize(@"i_error") message:msg delegate:self cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil, nil];
    [errorAlert show];
}
- (void)removeCoupon:(UIButton*)button {
    if (_isKeyboardVisible) {
        return;
    }
    Coupon* coupon = (Coupon*) [button.layer valueForKey:@"MY_OBJECT"];
    [Cart removeCoupon:coupon._id];
    [self updateCouponView];
}
- (void)applyCoupon:(UIButton*)button {
    if (_isKeyboardVisible) {
        return;
    }
    
    AppUser* appUser = [AppUser sharedManager];
    if(appUser._isUserLoggedIn == false){
        ViewControllerMain* mainVC = [ViewControllerMain getInstance];
        ViewControllerLeft* leftVC = (ViewControllerLeft*)(mainVC.revealController.rearViewController);
        [leftVC showLoginPopup:true];
    } else {
        NSString *enteredCode = _textFieldApplyCoupon.text;
        if(enteredCode == nil || [enteredCode isEqualToString:@""]) {
            if([[Cart getAll] count] == 0){
                [self showCouponError:Localize(@"no_items_in_cart")];
            }else{
                [self showCouponError:Localize(@"invalid_coupon_code")];
            }
            return;
        }else{
            Coupon* coupon = [Coupon getWithCode:_textFieldApplyCoupon.text];
            if (coupon) {
                NSMutableArray* selectedProductIds = [[NSMutableArray alloc] init];
                NSMutableArray* selectedCategoryIds = [[NSMutableArray alloc] init];
                NSMutableArray* selectedProductVariations = [[NSMutableArray alloc] init];
                for (Cart* cart in [Cart getAll]) {
                    int productId = cart.product._id;
                    [selectedProductIds addObject:[NSNumber numberWithInt:productId]];
                    int productVariationId = cart.selectedVariationId;
                    [selectedProductVariations addObject:[NSNumber numberWithInt:productVariationId]];
                    for (CategoryInfo* cInfo in cart.product._categories) {
                        [selectedCategoryIds addObject:[NSNumber numberWithInt:cInfo._id]];
                    }
                }
                float cartTotal = [Cart getTotalPayment];
                NSString* stringMsg = [coupon verify:selectedProductIds selectedCategoryIds:selectedCategoryIds userEmail:appUser._email total_amount:cartTotal selectedProductVariations:selectedProductVariations];
                if ([stringMsg isEqualToString:@"success"]) {
                    //apply coupon here
                    stringMsg = [Cart addCoupon:coupon];
                    if ([stringMsg isEqualToString:@"success"]) {
                        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:Localize(@"i_success") message:Localize(@"coupon_applied_successfully") delegate:self cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil, nil];
                        [errorAlert show];
                        _textFieldApplyCoupon.text = @"";
                        [self updateCouponView];
                    } else {
                        [self showCouponError:stringMsg];
                    }
                }else {
                    [self showCouponError:stringMsg];
                }
            } else {
                if([[Cart getAll] count] == 0){
                    [self showCouponError:Localize(@"no_items_in_cart")];
                }else{
                    [self showCouponError:Localize(@"invalid_coupon_code")];
                }
            }
#if ENABLE_FIREBASE_TAG_MANAGER
	if(_textFieldApplyCoupon) {
            [[AnalyticsHelper sharedInstance] registerApplyCouponeCode:_textFieldApplyCoupon.text];
	}
#endif
        }
    }
    


}
- (void)myCoupone:(UIButton*)buttonP{
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
    ViewControllerMyCoupon* vcMycopen = (ViewControllerMyCoupon*)[[Utility sharedManager]pushScreenWithoutAnimation:mainVC.vcCenterTop type:PUSH_SCREEN_TYPE_MYCOPON];
}
- (UIView*)addView:(int)listId pInfo:(ProductInfo*)pInfo isCartItem:(BOOL)isCartItem isWishlistItem:(BOOL)isWishlistItem quantity:(int)quantity {
    Cart* c = (Cart*)[[[AppUser sharedManager] _cartArray] objectAtIndex:listId];
    //    BOOL isItemOutofStock = false;
    Variation* variation = [pInfo._variations getVariation:c.selectedVariationId variationIndex:c.selectedVariationIndex];
    UIView* mainView = [[UIView alloc] init];
    [_scrollView addSubview:mainView];
    [_viewsAdded addObject:mainView];
    [mainView setTag:kTagForGlobalSpacing];
    
    
    float viewMaxHeight = 250;
    float viewMaxWidth = self.view.frame.size.width * .98f;
    float viewOriginX = self.view.frame.size.width * .01f;
    float viewOriginY = self.view.frame.size.width * .01f;
    
    float imgRectH = MIN(viewMaxHeight * .75f * .80f, viewMaxWidth * .25f);
    viewMaxHeight = imgRectH * 1.67f;
    
    UIView* viewTop = [[UIView alloc] init];
    [viewTop setFrame:CGRectMake(viewOriginX, viewOriginY, viewMaxWidth, viewMaxHeight * .75f)];
    [viewTop.layer setBorderColor:[[Utility getUIColor:kUIColorBorder] CGColor]];
    [viewTop.layer setBorderWidth:1];
    [viewTop setBackgroundColor:[UIColor whiteColor]];
    
    UIView* viewBottom = [[UIView alloc] init];
    [viewBottom setFrame:CGRectMake(viewOriginX, viewOriginY, viewMaxWidth, viewMaxHeight * .25f)];
    [viewBottom.layer setBorderColor:[[Utility getUIColor:kUIColorBorder] CGColor]];
    [viewBottom.layer setBorderWidth:1];
    [viewBottom setBackgroundColor:[UIColor whiteColor]];
    
    [mainView addSubview:viewTop];
    [mainView addSubview:viewBottom];
    
    
    float viewTopWidth = viewTop.frame.size.width;
    float viewTopHeight = viewTop.frame.size.height;
    CGRect imgRect = CGRectMake(viewTopHeight * .1f,
                                viewTopHeight * .1f,
                                viewTopHeight * .8f,
                                viewTopHeight * .8f);
    
    CGRect nameRect = CGRectMake(imgRect.origin.x * 2 + imgRect.size.width,
                                 viewTopHeight * .15f,
                                 viewTopWidth,
                                 viewTopHeight);
    CGRect descRect = CGRectMake(nameRect.origin.x,
                                 viewTopHeight * .30f,
                                 (viewTopWidth - nameRect.origin.x - viewTopHeight * .1f) * .6f,
                                 viewTopHeight);
    CGRect priceRect = CGRectMake(viewTopHeight * .1f,
                                  viewTopHeight * .6f,
                                  viewTopWidth,
                                  viewTopHeight);
    
    CGRect priceOldRect = CGRectMake(viewTopHeight * .1f,
                                     viewTopHeight * .6f,
                                     viewTopWidth,
                                     viewTopHeight);
    
    CGRect priceNewRect = CGRectMake(viewTopHeight * .1f,
                                     viewTopHeight * .8f,
                                     viewTopWidth,
                                     viewTopHeight);
    
    CGRect priceFinalRect = CGRectMake(viewTopHeight * .1f,
                                       viewTopHeight * .8f,
                                       viewTopWidth,
                                       viewTopHeight);
    
    
    
    UIImageView* imgProduct = [[UIImageView alloc] init];
    imgProduct.frame = imgRect;
    [viewTop addSubview:imgProduct];
    
    if ([variation._images count] > 0) {
        [Utility setImage:imgProduct url:((ProductImage*)[variation._images objectAtIndex:0])._src resizeType:kRESIZE_TYPE_PRODUCT_THUMBNAIL isLocal:false];
    }else{
        if ([pInfo._images count] == 0) {
            [pInfo._images addObject:[[ProductImage alloc] init]];
        }
        [Utility setImage:imgProduct url:((ProductImage*)[pInfo._images objectAtIndex:0])._src resizeType:kRESIZE_TYPE_PRODUCT_THUMBNAIL isLocal:false];
    }
    
    [imgProduct.layer setBorderColor:[[Utility getUIColor:kUIColorBorder] CGColor]];
    [imgProduct.layer setBorderWidth:1];
    [imgProduct setContentMode:UIViewContentModeScaleAspectFill];
    [imgProduct setClipsToBounds:true];
    
    UILabel* labelName = [[UILabel alloc] init];
    [viewTop addSubview:labelName];
    
    UILabel* labelDesc = [[UILabel alloc] init];
    //    [labelDesc setLineBreakMode:NSLineBreakByWordWrapping];
    //    [labelDesc setNumberOfLines:0];
    
    labelDesc.adjustsFontSizeToFitWidth = NO;
    labelDesc.lineBreakMode = NSLineBreakByTruncatingTail;
    
    [viewTop addSubview:labelDesc];
    
    UILabel* labelPrice = [[UILabel alloc] init];
    [viewTop addSubview:labelPrice];
    
    UILabel* labelPriceOld = [[UILabel alloc] init];
    [viewTop addSubview:labelPriceOld];
    
    UILabel* labelPriceNew = [[UILabel alloc] init];
    [viewTop addSubview:labelPriceNew];
    
    UILabel* labelPriceFinal = [[UILabel alloc] init];
    [viewTop addSubview:labelPriceFinal];
    
    
    [labelName setUIFont:kUIFontType18 isBold:true];
    [labelDesc setUIFont:kUIFontType14 isBold:false];
    [labelPrice setUIFont:kUIFontType16 isBold:false];
    [labelPriceOld setUIFont:kUIFontType14 isBold:false];
    [labelPriceNew setUIFont:kUIFontType16 isBold:false];
    [labelPriceFinal setUIFont:kUIFontType16 isBold:false];
    
    labelName.frame = nameRect;
    labelDesc.frame = descRect;
    labelPrice.frame = priceRect;
    
    [labelName setText:pInfo._titleForOuterView];
    [labelDesc setText:Localize(@"title_product_info")];
    [labelDesc setAttributedText:[[NSAttributedString alloc] initWithString:Localize(@"title_product_info")]];
    //    float labelSingleLineDescHeight = LABEL_SIZE(labelDesc).height ;
    
    NSString * htmlString = @"";//pInfo._short_description;
    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    [labelDesc setAttributedText:attrStr];
    
    NSString* priceStr;
    BOOL isDiscounted;
    float price;
    float oldPrice;
    if (variation) {
        isDiscounted = [pInfo isProductDiscounted:variation._id];
        price = [pInfo getNewPrice:variation._id] + [ProductInfo getExtraPrice:c.selected_attributes pInfo:pInfo];
        oldPrice = [pInfo getOldPrice:variation._id];
    }
    else if (c.selectedVariationId != -1) {
        isDiscounted = [pInfo isProductDiscounted:-1];
        price = [pInfo getNewPrice:-1] + [ProductInfo getExtraPrice:c.selected_attributes pInfo:pInfo];
        oldPrice = [pInfo getOldPrice:-1];
    }
    else {
        isDiscounted = [pInfo isProductDiscounted:-1];
        price = [pInfo getNewPrice:-1];
        oldPrice = [pInfo getOldPrice:-1];
    }
    
    
    if ([[Addons sharedManager] enable_mixmatch_products]) {
        if (c.product.mMixMatch) {
            price = 0.0f;
            for (CartMatchedItem* cmItems in c.mMixMatchProducts) {
                price +=  (cmItems.quantity * cmItems.price);
            }
        }
    }
    
    
    priceStr = [[Utility sharedManager] convertToString:price isCurrency:true];
    [labelPriceOld setAttributedText:[[Utility sharedManager] convertToStringStrikethrough:oldPrice isCurrency:true]];
    
//    RLOG(@"Final Rate = %@", [[Utility sharedManager] convertToStringStrikethrough:pInfo._regular_price isCurrency:true]);
    
    
    
    
    
    NSString* newPrice = @"";
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        newPrice = [NSString stringWithFormat:@"   X   %@", priceStr];
    } else {
        newPrice = [NSString stringWithFormat:@"%@   X   ", priceStr];
    }
    
    [labelPriceNew setText:newPrice];
    [labelPrice setText:Localize(@"i_price")];
    [labelPriceFinal setText:[[Utility sharedManager] convertToString:(price * quantity) isCurrency:true]];
    
    
    priceOldRect.origin.x = priceOldRect.origin.x + LABEL_SIZE(labelPrice).width + viewTopHeight * .1f;
    labelPriceOld.frame = priceOldRect;
    
    priceNewRect.origin.x = priceNewRect.origin.x + LABEL_SIZE(labelPrice).width + viewTopHeight * .1f;
    labelPriceNew.frame = priceNewRect;
    
    priceFinalRect.origin.x = viewTopWidth - LABEL_SIZE(labelPriceFinal).width - viewTopHeight * .1f;
    labelPriceFinal.frame = priceFinalRect;
    
    if(isDiscounted == false){
        priceNewRect = priceOldRect;
        labelPriceOld.hidden = true;
        labelPriceNew.frame = priceNewRect;
    }
    [labelPriceOld setTextColor:[Utility getUIColor:kUIColorFontPriceOld]];
    [labelPriceNew setTextColor:[Utility getUIColor:kUIColorFontDark]];
    [labelPriceFinal setTextColor:[Utility getUIColor:kUIColorFontDark]];
    
    [labelDesc setUIFont:kUIFontType14 isBold:false];
    [labelDesc sizeToFitUI];
    [labelPrice sizeToFitUI];
    //    RLOG(@"START==========");
    RLOG(@"====%@====", labelDesc.text);
    //    RLOG(@"END==========");
    float bottomPointDesc = labelDesc.frame.origin.y + labelDesc.frame.size.height;
    float startPointPriceOld = viewTopHeight * .6f;
    float startPointPriceNew = bottomPointDesc ;//+ viewTopHeight * .15f;
    
    float diffHeight = startPointPriceNew - startPointPriceOld;
    float labelPriceOldHeight = LABEL_SIZE(labelPriceOld).height ;
    if (diffHeight < 0 ) {
        diffHeight = 0;
    }
    
    RLOG(@"diffHeight = %.f",diffHeight);
    CGRect topViewUpdatedRect = viewTop.frame;
    if (labelPriceOld.hidden && diffHeight > labelPriceOldHeight) {
        topViewUpdatedRect.size.height += (diffHeight - labelPriceOldHeight);
    }
    viewTop.frame = topViewUpdatedRect;
    
    CGRect tempRect = labelPrice.frame;
    tempRect.origin.y +=  diffHeight;
    labelPrice.frame = tempRect;
    
    tempRect = labelPriceOld.frame;
    tempRect.origin.y +=  diffHeight;
    labelPriceOld.frame = tempRect;
    
    tempRect = labelPriceNew.frame;
    tempRect.origin.y +=  diffHeight;
    labelPriceNew.frame = tempRect;
    
    tempRect = labelPriceFinal.frame;
    tempRect.origin.y = labelPriceNew.frame.origin.y;
    labelPriceFinal.frame = tempRect;
    
    [labelName sizeToFitUI];
    
    CGRect nameRe = labelName.frame;
    nameRe.size.width = (viewTopWidth - nameRect.origin.x - viewTopHeight * .1f);
    labelName.frame = nameRe;
    
    
    //    [labelDesc sizeToFitUI];
    CGRect descRe = labelDesc.frame;
    descRe.size.width = (viewTopWidth - nameRect.origin.x - viewTopHeight * .1f);
    labelDesc.frame = descRe;
    
    [labelPrice sizeToFitUI];
    [labelPriceOld sizeToFitUI];
    [labelPriceNew sizeToFitUI];
    [labelPriceFinal sizeToFitUI];
    
    
    tempRect = labelPriceFinal.frame;
    tempRect.origin.x = viewTopHeight * .1f;
    tempRect.size.width = viewTopWidth - viewTopHeight * .2f;
    labelPriceFinal.frame = tempRect;
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        [labelPriceFinal setTextAlignment:NSTextAlignmentLeft];
    } else {
        [labelPriceFinal setTextAlignment:NSTextAlignmentRight];
    }
    
    
    [labelName setTextColor:[Utility getUIColor:kUIColorFontLight]];
    [labelDesc setTextColor:[Utility getUIColor:kUIColorFontLight]];
    [labelPrice setTextColor:[Utility getUIColor:kUIColorFontDark]];
    [labelPriceOld setTextColor:[Utility getUIColor:kUIColorFontPriceOld]];
    [labelPriceNew setTextColor:[Utility getUIColor:kUIColorFontDark]];
    [labelPriceFinal setTextColor:[Utility getUIColor:kUIColorFontDark]];
    
    
    UIButton* buttonLeft = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonLeft.titleLabel setUIFont:kUIFontType20 isBold:false];
    [buttonLeft setFrame:CGRectMake(0, 0 , (viewBottom.frame.size.width+2)/2+2, viewBottom.frame.size.height)];
    [buttonLeft.layer setBorderColor:[[Utility getUIColor:kUIColorBorder] CGColor]];
    [buttonLeft.layer setBorderWidth:1];
    [buttonLeft setContentMode:UIViewContentModeScaleAspectFit];
    [buttonLeft.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [buttonLeft setImageEdgeInsets:UIEdgeInsetsMake(viewBottom.frame.size.height * .25f, 0, viewBottom.frame.size.height * .25f, 0)];
    //    [buttonLeft setTitleEdgeInsets:UIEdgeInsetsMake(viewBottom.frame.size.height * .25f, 0, viewBottom.frame.size.height * .25f, 0)];
    
    
    UIButton* buttonRight =[UIButton buttonWithType:UIButtonTypeCustom];
    [buttonRight.titleLabel setUIFont:kUIFontType20 isBold:false];
    [buttonRight setFrame:CGRectMake((viewBottom.frame.size.width+2)/2+1, 0, viewBottom.frame.size.width/2, viewBottom.frame.size.height)];
    [buttonRight.layer setBorderColor:[[Utility getUIColor:kUIColorBorder] CGColor]];
    [buttonRight.layer setBorderWidth:1];
    [buttonRight setContentMode:UIViewContentModeScaleAspectFit];
    [buttonRight.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [buttonRight setImageEdgeInsets:UIEdgeInsetsMake(viewBottom.frame.size.height * .25f, 0, viewBottom.frame.size.height * .25f, 0)];
    //    [buttonRight setTitleEdgeInsets:UIEdgeInsetsMake(viewBottom.frame.size.height * .25f, 0, viewBottom.frame.size.height * .25f, 0)];
    
    
    [viewBottom addSubview:buttonLeft];
    [viewBottom addSubview:buttonRight];
    
    NSString *titleLeftButtonPressed;
    NSString *titleRightButtonPressed;
    UIColor *colorLeftButtonPressed;
    UIColor *colorRightButtonPressed;
    UIImage *imageLeftButtonPressed;
    UIImage *imageRightButtonPressed;
    if (isCartItem) {
        titleLeftButtonPressed = Localize(@"i_remove");
        titleRightButtonPressed= Localize(@"menu_title_wishlist");
        imageLeftButtonPressed = [[UIImage imageNamed:@"remove_icon_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        imageRightButtonPressed = [[UIImage imageNamed:@"wishlist_icon_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        colorLeftButtonPressed = [Utility getUIColor:kUIColorThemeButtonNormal];
        colorRightButtonPressed = [Utility getUIColor:kUIColorThemeButtonNormal];
        [buttonRight addTarget:self action:@selector(moveToWishlist:) forControlEvents:UIControlEventTouchUpInside];
    }
    else {
        titleLeftButtonPressed = Localize(@"i_remove");
        titleRightButtonPressed= Localize(@"title_mycart");
        imageLeftButtonPressed = [[UIImage imageNamed:@"remove_icon_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        imageRightButtonPressed = [[UIImage imageNamed:@"cart_icon_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        colorLeftButtonPressed = [Utility getUIColor:kUIColorThemeButtonNormal];
        colorRightButtonPressed = [Utility getUIColor:kUIColorThemeButtonNormal];
        [buttonRight addTarget:self action:@selector(addToCart:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [buttonLeft setUIImage:imageLeftButtonPressed forState:UIControlStateNormal];
    [buttonLeft setUIImage:imageLeftButtonPressed forState:UIControlStateSelected];
    [buttonLeft setTitle:titleLeftButtonPressed forState:UIControlStateNormal];
    [buttonLeft setTitle:titleLeftButtonPressed forState:UIControlStateSelected];
    [buttonLeft setTitleColor:colorLeftButtonPressed forState:UIControlStateNormal];
    [buttonLeft setTitleColor:colorLeftButtonPressed forState:UIControlStateSelected];
    [buttonLeft setTintColor:colorLeftButtonPressed];
    
    [buttonRight setUIImage:imageRightButtonPressed forState:UIControlStateNormal];
    [buttonRight setUIImage:imageRightButtonPressed forState:UIControlStateSelected];
    [buttonRight setTitle:titleRightButtonPressed forState:UIControlStateNormal];
    [buttonRight setTitle:titleRightButtonPressed forState:UIControlStateSelected];
    [buttonRight setTitleColor:colorRightButtonPressed forState:UIControlStateNormal];
    [buttonRight setTitleColor:colorRightButtonPressed forState:UIControlStateSelected];
    [buttonRight setTintColor:colorRightButtonPressed];
    
    [buttonLeft addTarget:self action:@selector(removeFromList:) forControlEvents:UIControlEventTouchUpInside];
    
    [buttonLeft setTag:listId];
    [buttonRight setTag:listId];
    
    PairCart* pair = [[PairCart alloc] init];
    pair.buttonLeft = buttonLeft;
    pair.buttonRight = buttonRight;
    pair.cart = c;
    [_tempPairArray addObject:pair];
    
    CGRect viewT = viewTop.frame;
    CGRect viewB = viewBottom.frame;
    CGRect viewM = mainView.frame;
    
    //    viewM = CGRectMake(0, 0, viewT.size.width, viewT.size.height + viewB.size.height);
    //    viewT = CGRectMake(viewT.origin.x, viewT.origin.y, viewT.size.width, viewT.size.height);
    //    viewB = CGRectMake(viewB.origin.x, viewB.origin.y + viewT.size.height, viewB.size.width, viewB.size.height);
    
    viewM = CGRectMake(self.view.frame.size.width * .01f, self.view.frame.size.width * .01f, self.view.frame.size.width * .98f, viewT.size.height + viewB.size.height);
    viewT = CGRectMake(-1, 0, viewM.size.width + 2, viewT.size.height);
    viewB = CGRectMake(-1, viewB.origin.y + viewT.size.height, viewM.size.width + 2, viewB.size.height);
    
    viewTop.frame = viewT;
    viewBottom.frame = viewB;
    mainView.frame = viewM;
    
    
    UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, viewTop.frame.size.width, viewTop.frame.size.height)];
    [button addTarget:self action:@selector(myEvent:) forControlEvents:UIControlEventTouchUpInside];
    pair.buttonImage = button;
    [viewTop addSubview:button];
    [button setTag:pInfo._id];
    
    ///////////
    UILabel* labelProp = [[UILabel alloc] init];
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
    [labelProp setUIFont:labelDesc.font];
    
    
    [labelProp setText:properties];
    labelProp.textColor = labelPrice.textColor;
    [labelProp setFrame:labelDesc.frame];
    //    labelProp.lineBreakMode = NSLineBreakByWordWrapping;
    labelProp.numberOfLines = 0;
    [labelProp sizeToFitUI];
    CGRect rectProp = labelProp.frame;
    float gap = (labelPrice.frame.origin.y - labelDesc.frame.origin.y + labelDesc.frame.size.height);
    rectProp.origin.y += (gap - rectProp.size.height)/2;
    [labelProp setFrame:rectProp];
    [labelDesc.superview addSubview:labelProp];
    
    CGRect rect_title = labelName.frame;
    CGRect rect_desc = labelDesc.frame;
    CGRect rect_prop = labelProp.frame;
    CGRect rect_priceHeader = labelPrice.frame;
    CGRect rect_priceOld = labelPriceOld.frame;
    CGRect rect_priceNew = labelPriceNew.frame;
    CGRect rect_priceTotal = labelPriceFinal.frame;
    
    
    rect_desc.origin.y = CGRectGetMaxY(rect_title) + 10;
    labelDesc.frame = rect_desc;
    if (labelDesc.frame.size.height == 0) {
        rect_prop.origin.y = CGRectGetMaxY(rect_title) + 10;
        labelProp.frame = rect_prop;
    } else {
        rect_prop.origin.y = CGRectGetMaxY(rect_desc) + 10;
        labelProp.frame = rect_prop;
    }
    
    
    float gapDateTime = 0;
#if ENABLE_PRODUCT_DELIVERY_DATA_PLUGIN
    if ([[Addons sharedManager] productDeliveryDatePlugin] && [[[Addons sharedManager] productDeliveryDatePlugin] isEnabled]) {
        
        float spacingIconX = 30;
        float spacingLabelX = 15;
        float iconW = 16;
        float iconH = 16;
        if ((c.prddDate && ![c.prddDate isEqualToString:@""]) ||
            (c.prddTime && ![c.prddTime.slot_title isEqualToString:@""])) {
            gapDateTime += 5;
            UILabel* deliveryDetailsLabel = [[UILabel alloc] init];
            [deliveryDetailsLabel setUIFont:kUIFontType14 isBold:false];
            deliveryDetailsLabel.frame = CGRectMake(labelProp.frame.origin.x, CGRectGetMaxY(rect_prop) + gapDateTime, (viewTopWidth - nameRect.origin.x - viewTopHeight * .1f), deliveryDetailsLabel.font.lineHeight);
            [deliveryDetailsLabel setText:Localize(@"delivery_details")];
            [labelProp.superview addSubview:deliveryDetailsLabel];
            [deliveryDetailsLabel setTextColor:[Utility getUIColor:kUIColorFontDark]];
            gapDateTime += deliveryDetailsLabel.font.lineHeight;
        }
        if (c.prddDate && ![c.prddDate isEqualToString:@""]) {
            gapDateTime += 5;
            NSString* deliveryDate = [NSString stringWithFormat:@"%@", c.prddDate];
            
            UIImageView* dateSelectionIcon = [[UIImageView alloc] init];
            dateSelectionIcon.frame = CGRectMake(labelProp.frame.origin.x + spacingIconX, CGRectGetMaxY(rect_prop) + gapDateTime, iconW, iconH);
            [dateSelectionIcon setImage:[UIImage imageNamed:@"date_icon.png"]];
            [labelProp.superview addSubview:dateSelectionIcon];
            [dateSelectionIcon setTintColor:[Utility getUIColor:kUIColorFontDark]];
            [dateSelectionIcon setContentMode:UIViewContentModeScaleAspectFit];
            
            UILabel* dateSelectionLabel = [[UILabel alloc] init];
            [dateSelectionLabel setUIFont:kUIFontType14 isBold:false];
            dateSelectionLabel.frame = CGRectMake(CGRectGetMaxX(dateSelectionIcon.frame) + spacingLabelX,CGRectGetMaxY(rect_prop) + gapDateTime,(viewTopWidth - viewTopHeight * .1f - (CGRectGetMaxX(dateSelectionIcon.frame) + spacingLabelX)),MAX(dateSelectionLabel.font.lineHeight, iconH));
            [dateSelectionLabel setText:deliveryDate];
            [labelProp.superview addSubview:dateSelectionLabel];
            [dateSelectionLabel setTextColor:[Utility getUIColor:kUIColorFontDark]];
            gapDateTime += MAX(dateSelectionLabel.font.lineHeight, iconH);
        }
        if (c.prddTime && ![c.prddTime.slot_title isEqualToString:@""]) {
            gapDateTime += 5;
            NSString* deliveryTime = [NSString stringWithFormat:@"%@", c.prddTime.slot_title];
            
            UIImageView* dateSelectionIcon = [[UIImageView alloc] init];
            dateSelectionIcon.frame = CGRectMake(labelProp.frame.origin.x + spacingIconX, CGRectGetMaxY(rect_prop) + gapDateTime, iconW, iconH);
            [dateSelectionIcon setImage:[UIImage imageNamed:@"time_icon.png"]];
            [labelProp.superview addSubview:dateSelectionIcon];
            [dateSelectionIcon setTintColor:[Utility getUIColor:kUIColorFontDark]];
            [dateSelectionIcon setContentMode:UIViewContentModeScaleAspectFit];
            
            UILabel* dateSelectionLabel = [[UILabel alloc] init];
            [dateSelectionLabel setUIFont:kUIFontType14 isBold:false];
            dateSelectionLabel.frame = CGRectMake(
                                                  CGRectGetMaxX(dateSelectionIcon.frame) + spacingLabelX,
                                                  CGRectGetMaxY(rect_prop) + gapDateTime,
                                                  (viewTopWidth - viewTopHeight * .1f - (CGRectGetMaxX(dateSelectionIcon.frame) + spacingLabelX)),
                                                  MAX(dateSelectionLabel.font.lineHeight, iconH));
            [dateSelectionLabel setText:deliveryTime];
            [labelProp.superview addSubview:dateSelectionLabel];
            [dateSelectionLabel setTextColor:[Utility getUIColor:kUIColorFontDark]];
            gapDateTime += MAX(dateSelectionLabel.font.lineHeight, iconH);
        }
    }
#endif
    rect_prop.size.height += gapDateTime;
    
    float newMargin = 0;
    rect_priceHeader.origin.y = CGRectGetMaxY(rect_prop) + newMargin;
    labelPrice.frame = rect_priceHeader;
    
    if (labelPriceOld.frame.size.height == 0) {
        rect_priceOld.origin.y = MAX(CGRectGetMaxY(rect_prop), CGRectGetMaxY(imgProduct.frame)) + newMargin;
        labelPriceOld.frame = rect_priceOld;
        rect_priceNew.origin.y = MAX(CGRectGetMaxY(rect_prop), CGRectGetMaxY(imgProduct.frame)) + newMargin;
        labelPriceNew.frame = rect_priceNew;
        rect_priceTotal.origin.y = MAX(CGRectGetMaxY(rect_priceHeader), CGRectGetMaxY(imgProduct.frame)) + newMargin;
        labelPriceFinal.frame = rect_priceTotal;
    } else {
        newMargin = 10;
        if ([[MyDevice sharedManager] isIphone]) {
            newMargin = 7;
        }
        rect_priceOld.origin.y = MAX(CGRectGetMaxY(rect_prop), CGRectGetMaxY(imgProduct.frame)) + newMargin;
        labelPriceOld.frame = rect_priceOld;
        rect_priceNew.origin.y = MAX(CGRectGetMaxY(rect_priceOld), CGRectGetMaxY(imgProduct.frame)) + newMargin;
        labelPriceNew.frame = rect_priceNew;
        rect_priceTotal.origin.y = MAX(CGRectGetMaxY(rect_priceOld), CGRectGetMaxY(imgProduct.frame)) + newMargin;
        labelPriceFinal.frame = rect_priceTotal;
        
    }
    
    tempRect = labelPriceNew.frame;
    
    
    if (labelPriceOld.hidden == true) {
        labelPrice.frame = CGRectMake(labelPrice.frame.origin.x, labelPriceNew.frame.origin.y, labelPrice.frame.size.width, labelPrice.frame.size.height);
    } else {
        labelPrice.frame = CGRectMake(labelPrice.frame.origin.x, labelPriceOld.frame.origin.y, labelPrice.frame.size.width, labelPrice.frame.size.height);
    }
    
    
    UILabel* tempQuantityLabel = [[UILabel alloc] init];
    [tempQuantityLabel setText:@"0000000000"];
    [tempQuantityLabel setUIFont:kUIFontType16 isBold:false];
    NSString* quantityStr = [NSString stringWithFormat:@"%d", quantity];
    UITextField* textInputQuantity = [self createTextField:viewTop fontType:kUIFontType16 fontColorType:kUIColorFontDark frame:CGRectMake(CGRectGetMaxX(tempRect), tempRect.origin.y - tempRect.size.height / 2,  LABEL_SIZE(tempQuantityLabel).width, tempRect.size.height * 2) tag:0 textStrPlaceHolder:@""];
    [textInputQuantity setText:quantityStr];
    [textInputQuantity setKeyboardType:UIKeyboardTypeNumberPad];
    [textInputQuantity setReturnKeyType:UIReturnKeyDone];
    //    [textInputQuantity setEnablesReturnKeyAutomatically:true];
    
    if ([[MyDevice sharedManager] isIphone]) {
        UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
        //        [numberToolbar.layer setBorderWidth:0.5f];
        //        numberToolbar.barStyle = UIBarStyleDefault;
        //        numberToolbar.translucent = NO;
        numberToolbar.backgroundColor = [UIColor lightGrayColor];
        UIBarButtonItem* cancelBtn = [[UIBarButtonItem alloc]initWithTitle:Localize(@"cancel") style:UIBarButtonItemStyleBordered target:self action:@selector(cancelNumberPad:)];
        UIBarButtonItem* doneBtn = [[UIBarButtonItem alloc]initWithTitle:Localize(@"apply") style:UIBarButtonItemStyleBordered target:self action:@selector(doneWithNumberPad:)];
        pair.cancelBtn = cancelBtn;
        pair.doneBtn = doneBtn;
        
        numberToolbar.items = @[
                                cancelBtn,
                                [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                doneBtn];
        [numberToolbar sizeToFit];
        textInputQuantity.inputAccessoryView = numberToolbar;
    }
    
    UIColor *color = [Utility getUIColor:kUIColorFontDark];
    textInputQuantity.attributedPlaceholder = [[NSAttributedString alloc] initWithString:quantityStr attributes:@{NSForegroundColorAttributeName:color}];
    pair.textFieldQuantity = textInputQuantity;
    pair.labelFinalPrice = labelPriceFinal;
    
    
    
    
    
    
    
    if ([[MyDevice sharedManager] isIphone]) {
        float inputViewMaxY = CGRectGetMaxY(textInputQuantity.frame);
        CGRect finalPriceRect = pair.labelFinalPrice.frame;
        float finalPriceHeight = textInputQuantity.frame.size.height / 3;
        finalPriceRect.origin.y = inputViewMaxY + finalPriceHeight;
        finalPriceRect.origin.x = CGRectGetMaxX(textInputQuantity.frame) - finalPriceRect.size.width;
        pair.labelFinalPrice.frame = finalPriceRect;
        finalPriceRect.origin.x = viewMaxWidth - finalPriceRect.size.width - self.view.frame.size.width * .02f;
        pair.labelFinalPrice.frame = finalPriceRect;
        
        CGRect topViewRect = viewTop.frame;
        topViewRect.size.height = CGRectGetMaxY(pair.labelFinalPrice.frame) + viewTopHeight * .1f;
//        topViewRect.size.height = CGRectGetMaxY(pair.labelFinalPrice.frame)+finalPriceHeight;
        viewTop.frame = topViewRect;
        
        CGRect bottomViewRect = viewBottom.frame;
        bottomViewRect.origin.y = CGRectGetMaxY(topViewRect);
        viewBottom.frame = bottomViewRect;
        
        CGRect mainViewRect = mainView.frame;
        mainViewRect.size.height = CGRectGetMaxY(bottomViewRect);
        mainView.frame = mainViewRect;
    }else {
        CGRect topViewRect = viewTop.frame;
        topViewRect.size.height = CGRectGetMaxY(pair.textFieldQuantity.frame) + viewTopHeight * .1f;
        viewTop.frame = topViewRect;
    }
    
    if (([[GuestConfig sharedInstance] hide_price] && ![AppUser isSignedIn]) || [[Addons sharedManager] hide_price]) {
        [labelPriceOld setText:@""];
        [labelPriceNew setText:@""];
        [labelPriceFinal setText:@""];
        [labelPrice setText:@""];
        [labelPriceOld sizeToFitUI];
        [labelPriceNew sizeToFitUI];
        [labelPriceFinal sizeToFitUI];
        [labelPrice sizeToFitUI];
        [textInputQuantity setHidden:true];
        CGRect topViewRect = viewTop.frame;
        topViewRect.size.height = CGRectGetMaxY(imgProduct.frame) + viewTopHeight * .1f;
        viewTop.frame = topViewRect;
    } else {
        [textInputQuantity setHidden:false];
    }
    
    
    UIView* middleView = [[UIView alloc] init];
    [mainView addSubview:middleView];
    {
        CGRect middleViewRect = viewTop.frame;
        middleViewRect.size.height = 0;
        middleView.frame = middleViewRect;
        CGRect imgViewRect = imgProduct.frame;
        float internalY = 0;
        float internalX = viewTop.frame.origin.x + 1;
        float internalW = viewTop.frame.size.width - 2;
        float internalH = imgViewRect.size.height *= .75f;
        if (c.product._type == PRODUCT_TYPE_MIXNMATCH) {
            for (CartMatchedItem* cmItem in c.mMixMatchProducts) {
                if (cmItem.quantity > 0) {
                    UIView* v = [[UIView alloc] initWithFrame:CGRectMake(internalX, internalY, internalW, internalH)];
                    v.backgroundColor = [UIColor whiteColor];
//                    v.layer.borderWidth = 1;
//                    v.layer.borderColor = [Utility getUIColor:kUIColorBorder].CGColor;
                    [middleView addSubview:v];
                    internalY += internalH;
                    float x = imgViewRect.origin.x  * 2;
                    UIImageView* imgV = [[UIImageView alloc] init];
                    imgV.frame = CGRectMake(x, imgViewRect.origin.y * .75f, imgViewRect.size.height * .75f, imgViewRect.size.height * .75f);
                    [v addSubview:imgV];
                    imgV.layer.borderWidth = 1;
                    imgV.layer.borderColor = [Utility getUIColor:kUIColorBorder].CGColor;
                    [Utility setImage:imgV url:cmItem.imgUrl resizeType:kRESIZE_TYPE_PRODUCT_THUMBNAIL isLocal:false];
                    
                    UILabel* pTitle = [[UILabel alloc] init];
                    pTitle.frame = CGRectMake(
                                            x + CGRectGetMaxX(imgV.frame),
                                            CGRectGetMaxY(imgV.frame),
                                            internalW - x * 2.0f - CGRectGetMaxX(imgV.frame),
                                            0);
                    [pTitle setUIFont:kUIFontType16 isBold:false];
                    [pTitle setText:((ProductInfo*)(cmItem.product))._titleForOuterView];
                    [pTitle setTextColor:[Utility getUIColor:kUIColorFontLight]];
                    [v addSubview:pTitle];
                    CGRect pTitleFrame = pTitle.frame;
                    pTitleFrame.size.width = internalW - x * 2.0f - CGRectGetMaxX(imgV.frame);
                    pTitleFrame.size.height = [pTitle.font lineHeight];
                    pTitle.frame = pTitleFrame;
                    pTitle.center = CGPointMake(pTitle.center.x, internalH * .33f);
                    
                    
                    UILabel* pQty = [[UILabel alloc] init];
                    pQty.frame = CGRectMake(
                                              x + CGRectGetMaxX(imgV.frame),
                                              CGRectGetMaxY(imgV.frame),
                                              internalW - x * 2.0f - CGRectGetMaxX(imgV.frame),
                                              0);
                    [pQty setUIFont:kUIFontType16 isBold:false];
                    [pQty setTextColor:[Utility getUIColor:kUIColorFontLight]];
                    [pQty setText:[NSString stringWithFormat:@"%@:%d", Localize(@"label_quantity"), cmItem.quantity * c.count]];
                    [v addSubview:pQty];
                    CGRect pQtyFrame = pQty.frame;
                    pQtyFrame.origin.y = CGRectGetMaxY(imgV.frame) - pQtyFrame.size.height;
                    pQtyFrame.size.width = internalW - x * 2.0f - CGRectGetMaxX(imgV.frame);
                    pQtyFrame.size.height = [pQty.font lineHeight];
                    pQty.frame = pQtyFrame;
                    pQty.center = CGPointMake(pQty.center.x, internalH * .66f);
                    
                    
                    
                    UILabel* pPrice = [[UILabel alloc] init];
                    pPrice.frame = pQtyFrame;
                    [pPrice setUIFont:kUIFontType16 isBold:false];
                    [pPrice setTextColor:[Utility getUIColor:kUIColorFontLight]];
                    [pPrice setText:[[Utility sharedManager] convertToString:((ProductInfo*)(cmItem.product))._price * cmItem.quantity *c.count isCurrency:true]];
                    [pPrice setTextAlignment:NSTextAlignmentRight];
                    [v addSubview:pPrice];
                    pPrice.frame = pQtyFrame;
                    pPrice.center = CGPointMake(pQty.center.x, internalH * .66f);
                    
                    cmItem.labelQty = pQty;
                    cmItem.labelPrice = pPrice;

                }
            }
            middleViewRect.size.height = internalY;
            middleView.frame = middleViewRect;
        }
        if (c.product._type == PRODUCT_TYPE_BUNDLE) {
            for (CartBundleItem* cmItem in c.mBundleProducts) {
                if (cmItem.quantity > 0) {
                    UIView* v = [[UIView alloc] initWithFrame:CGRectMake(internalX, internalY, internalW, internalH)];
                    v.backgroundColor = [UIColor whiteColor];
                    //                    v.layer.borderWidth = 1;
                    //                    v.layer.borderColor = [Utility getUIColor:kUIColorBorder].CGColor;
                    [middleView addSubview:v];
                    internalY += internalH;
                    float x = imgViewRect.origin.x  * 2;
                    UIImageView* imgV = [[UIImageView alloc] init];
                    imgV.frame = CGRectMake(x, imgViewRect.origin.y * .75f, imgViewRect.size.height * .75f, imgViewRect.size.height * .75f);
                    [v addSubview:imgV];
                    imgV.layer.borderWidth = 1;
                    imgV.layer.borderColor = [Utility getUIColor:kUIColorBorder].CGColor;
                    [Utility setImage:imgV url:cmItem.imgUrl resizeType:kRESIZE_TYPE_PRODUCT_THUMBNAIL isLocal:false];
                    
                    UILabel* pTitle = [[UILabel alloc] init];
                    pTitle.frame = CGRectMake(
                                              x + CGRectGetMaxX(imgV.frame),
                                              CGRectGetMinY(imgV.frame),
                                              internalW - x * 2.0f - CGRectGetMaxX(imgV.frame),
                                              0);
                    [pTitle setUIFont:kUIFontType16 isBold:false];
                    [pTitle setText:cmItem.title];
                    [pTitle setTextColor:[Utility getUIColor:kUIColorFontLight]];
                    [v addSubview:pTitle];
                    CGRect pTitleFrame = pTitle.frame;
                    pTitleFrame.size.width = internalW - x * 2.0f - CGRectGetMaxX(imgV.frame);
                    pTitleFrame.size.height = [pTitle.font lineHeight];
                    pTitle.frame = pTitleFrame;
                    pTitle.center = CGPointMake(pTitle.center.x, internalH * .33f);
                    
                    
                    UILabel* pQty = [[UILabel alloc] init];
                    pQty.frame = CGRectMake(
                                            x + CGRectGetMaxX(imgV.frame),
                                            CGRectGetMaxY(imgV.frame),
                                            internalW - x * 2.0f - CGRectGetMaxX(imgV.frame),
                                            0);
                    [pQty setUIFont:kUIFontType16 isBold:false];
                    [pQty setTextColor:[Utility getUIColor:kUIColorFontLight]];
                    [pQty setText:[NSString stringWithFormat:@"%@:%d", Localize(@"label_quantity"), cmItem.quantity * c.count]];
                    [v addSubview:pQty];
                    CGRect pQtyFrame = pQty.frame;
                    pQtyFrame.origin.y = CGRectGetMaxY(imgV.frame) - pQtyFrame.size.height;
                    pQtyFrame.size.width = internalW - x * 2.0f - CGRectGetMaxX(imgV.frame);
                    pQtyFrame.size.height = [pQty.font lineHeight];
                    pQty.frame = pQtyFrame;
                    pQty.center = CGPointMake(pQty.center.x, internalH * .66f);
                    
                    UILabel* pPrice = [[UILabel alloc] init];
                    pPrice.frame = pQtyFrame;
                    [pPrice setUIFont:kUIFontType16 isBold:false];
                    [pPrice setTextColor:[Utility getUIColor:kUIColorFontLight]];
                    [pPrice setText:[[Utility sharedManager] convertToString:((ProductInfo*)(cmItem.product))._price isCurrency:true]];
                    [pPrice setText:Localize(@"free")];
                    [pPrice setTextAlignment:NSTextAlignmentRight];
                    [v addSubview:pPrice];
                    pPrice.frame = pQtyFrame;
                    pPrice.center = CGPointMake(pQty.center.x, internalH * .66f);
                    
                    
                    cmItem.labelQty = pQty;
                    cmItem.labelPrice = pPrice;
                }
            }
            middleViewRect.size.height = internalY;
            middleView.frame = middleViewRect;
        }
    }
    
    CGRect topViewRect = viewTop.frame;
    CGRect middleViewRect = middleView.frame;
    CGRect bottomViewRect = viewBottom.frame;
    
    middleViewRect.origin.y = CGRectGetMaxY(topViewRect) - 1;
    middleViewRect.origin.x += 1;
    middleView.frame = middleViewRect;
    
    bottomViewRect.origin.y = CGRectGetMaxY(middleViewRect);
    viewBottom.frame = bottomViewRect;
    
    CGRect mainViewRect = mainView.frame;
    mainViewRect.size.height = CGRectGetMaxY(bottomViewRect);
    mainView.frame = mainViewRect;
    
    [Utility showShadow:mainView];
    
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        [labelName setTextAlignment:NSTextAlignmentRight];
        [labelDesc setTextAlignment:NSTextAlignmentRight];
        [labelProp setTextAlignment:NSTextAlignmentRight];
    }
    
    

    
    
    
    
    
    
    
    
    
    
    return mainView;
    
}




- (UITextField*)createTextField:(UIView*)parentView fontType:(int)fontType fontColorType:(int)fontColorType frame:(CGRect)frame tag:(int)tag textStrPlaceHolder:(NSString*)textStrPlaceHolder{
    if (CGRectEqualToRect(frame, CGRectMake(0, 0, 0, 0))) {
        frame = parentView.frame;
    }
    if ([[MyDevice sharedManager] isIphone]) {
        fontType--;
    }
    UITextField *textField = [[UITextField alloc] initWithFrame:frame];
    textField.backgroundColor = [UIColor clearColor];
    textField.textColor = [Utility getUIColor:fontColorType];
    [textField setUIFont:fontType isBold:false];
    textField.borderStyle = UITextBorderStyleLine;
    textField.layer.borderWidth = 1;
    textField.layer.borderColor = [Utility getUIColor:kUIColorThemeButtonBorderSelected].CGColor;
    textField.returnKeyType = UIReturnKeyDone;
    textField.textAlignment = NSTextAlignmentCenter;
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.tag = tag;
    textField.delegate = self;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [parentView addSubview:textField];
    
    //    UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    //
    //    if ([[TMLanguage sharedManager] isRTLEnabled]) {
    //        [textField setRightViewMode:UITextFieldViewModeAlways];
    //        [textField setRightView:spacerView];
    //    } else {
    //        [textField setLeftViewMode:UITextFieldViewModeAlways];
    //        [textField setLeftView:spacerView];
    //    }
    return textField;
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView == _alertViewUpdateCart)
    {
        _couponView = nil;
        _couponViewWithAppliedCoupon = nil;
        _couponViewWithTextField = nil;
        
        _rewardDiscountView= nil;
        _rewardDiscountViewWithTextField = nil;
        _autoAppliedCouponView = nil;
        //        [self loadViewDA];
        //        [Cart resetNotificationItemCount];
        //        [self resetMainScrollView: 0.0f];
        
        _scrollView.alpha = 0.0f;
        [self loadViewDA];
        for(UIView *vieww in _viewsAdded)
        {
            [vieww setAlpha:0.0f];
        }
        _scrollView.alpha = 1.0f;
        [self afterRotation:0.5f];
        [self resetMainScrollView:0.5f];
        
        return;
    }
    
    if([alertView tag] == 23)
    {
        if (_cartNeedToMoveToWishlist) {
            [self moveToWishlist:_cartNeedToMoveToWishlist.buttonRight forcedRemove:true];
        }
        
    }
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    RLOG(@"textFieldDidBeginEditing %@", textField.text);
    _textFieldQuantityEdit = textField;
    _isKeyboardVisible = true;
    PRINT_RECT_STR(@"inputView", _textFieldQuantityEdit.inputView.frame);
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissk)];
    [self.view addGestureRecognizer:tap];
}
- (void)dismissk
{
    RLOG(@"dismissk %@", _textFieldQuantityEdit.text);
    [_textFieldQuantityEdit resignFirstResponder];
}
//- (void)handleSingleTap:(UITapGestureRecognizer *) sender
//{
//    [self.view endEditing:YES];
//}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    RLOG(@"textFieldDidEndEditing %@", textField.text);
    _textFieldQuantityEdit = nil;
    _isKeyboardVisible = false;
    [_scrollView setUserInteractionEnabled:true];
}
- (int)updatedUserDemandForBundleProduct:(Cart*)cart userDemand:(int)userDemand {
    int availState = [cart getProductAvailibleState:userDemand];
    if (availState == PRODUCT_QTY_ZERO) {
        if (userDemand > 1) {
            return [self updatedUserDemandForBundleProduct:cart userDemand:--userDemand];
        }
    }
    return userDemand;
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    RLOG(@"textFieldShouldEndEditing %@", textField.text);
    if (textField == _textFieldApplyCoupon) {
        NSString* str = [NSString stringWithFormat:@"%@", textField.text];
        RLOG(@"_textFieldApplyCoupon = %@", str);
        return YES;
    }
    
    int userDemand = [textField.text intValue];
    PairCart* selectedPairCart = nil;
    for (PairCart* p in _tempPairArray) {
        if(textField == p.textFieldQuantity){
            selectedPairCart = p;
            break;
        }
    }
    ProductInfo* pInfo = selectedPairCart.cart.product;
    Variation* variation = [pInfo._variations getVariation:selectedPairCart.cart.selectedVariationId variationIndex:selectedPairCart.cart.selectedVariationIndex];
    if (pInfo._type == PRODUCT_TYPE_BUNDLE) {
        int userDemandPrevious = userDemand;
        userDemand = [self updatedUserDemandForBundleProduct:selectedPairCart.cart userDemand:userDemand];
        if (userDemand < userDemandPrevious && userDemand != 0) {
            NSString * strQty = [NSString stringWithFormat:Localize(@"items_available"), userDemand];
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:pInfo._titleForOuterView message:strQty delegate:self cancelButtonTitle:Localize(@"i_ok") otherButtonTitles:nil, nil];
            [errorAlert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                textField.text = [NSString stringWithFormat:@"%d", userDemand];
            }];
        }
    }
    
    
    int availState = [selectedPairCart.cart getProductAvailibleState:userDemand];
    int qty = [selectedPairCart.cart getProductAvailibleQuantity:userDemand];
    if (availState == PRODUCT_QTY_ZERO) {
        //out of stock
        userDemand = 0;
        //item out of stock and move to wishlist
        
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:pInfo._titleForOuterView message:Localize(@"out_of_stock") delegate:self cancelButtonTitle:Localize(@"Move To Wishlist") otherButtonTitles:nil, nil];

        [errorAlert setTag:23];
        [errorAlert show];
    }
    else if (availState == PRODUCT_QTY_STOCK) {
        //limited stock
        userDemand = qty;
        NSString * strQty = [NSString stringWithFormat:Localize(@"items_available"), qty];
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:pInfo._titleForOuterView message:strQty delegate:self cancelButtonTitle:Localize(@"i_ok") otherButtonTitles:nil, nil];
        [errorAlert setTag:24];
        [errorAlert show];
    }
    else{
        //available to purchase
        RLOG(@"available to purchase");
    }
    
    
    BOOL isDiscounted;
    float price;
    float oldPrice;
    if (variation) {
        isDiscounted = [pInfo isProductDiscounted:variation._id];
        price = [pInfo getNewPrice:variation._id] + [ProductInfo getExtraPrice:selectedPairCart.cart.selected_attributes pInfo:pInfo];
        oldPrice = [pInfo getOldPrice:variation._id];
    } else {
        isDiscounted = [pInfo isProductDiscounted:-1];
        price = [pInfo getNewPrice:-1];
        oldPrice = [pInfo getOldPrice:-1];
    }
    int oldCartCount = selectedPairCart.cart.count;
    int newCartCount = userDemand;
    int incrementCartCount = newCartCount - oldCartCount;
    
#if ENABLE_PARSE_ANALYTICS
    [[ParseHelper sharedManager] registerParseCartProduct:pInfo._id categoryId:pInfo._parent_id increment:incrementCartCount];
#endif
    
    selectedPairCart.cart.count = userDemand;
    if ([[Addons sharedManager] enable_mixmatch_products]) {
        if (selectedPairCart.cart.product.mMixMatch) {
            price = 0.0f;
            for (CartMatchedItem* cmItems in selectedPairCart.cart.mMixMatchProducts) {
                price +=  (cmItems.quantity * cmItems.price);
                [cmItems.labelPrice setText:[[Utility sharedManager] convertToString:((ProductInfo*)(cmItems.product))._price * cmItems.quantity * selectedPairCart.cart.count isCurrency:true]];
                [cmItems.labelQty setText:[NSString stringWithFormat:@"%@:%d", Localize(@"label_quantity"), cmItems.quantity * selectedPairCart.cart.count]];
            }
        }
    }
    if ([[Addons sharedManager] enable_bundled_products]) {
        if (selectedPairCart.cart.product.mBundles) {
//            price = 0.0f;
            for (CartBundleItem* cmItems in selectedPairCart.cart.mBundleProducts) {
//                price +=  (cmItems.quantity * cmItems.price);
//                [cmItems.labelPrice setText:[[Utility sharedManager] convertToString:((ProductInfo*)(cmItems.product))._price * cmItems.quantity * selectedPairCart.cart.count isCurrency:true]];
                [cmItems.labelQty setText:[NSString stringWithFormat:@"%@:%d", Localize(@"label_quantity"), cmItems.quantity * selectedPairCart.cart.count]];
            }
        }
    }
    [selectedPairCart.labelFinalPrice setText:[[Utility sharedManager] convertToString:(price * userDemand) isCurrency:true]];
    [textField setText:[NSString stringWithFormat:@"%d", userDemand]];
    int itemsCount = [Cart getItemCount];
    float totalPrice = [Cart getTotalPayment];
    NSString* stringItemsCount = [NSString stringWithFormat:@"%d", itemsCount];
    NSString* stringGrandTotal = [[Utility sharedManager] convertToString:totalPrice isCurrency:true];
    [_labelTotalItems setText:stringItemsCount];
    [_labelGrandTotal setText:stringGrandTotal];
    
    _cartNeedToMoveToWishlist = selectedPairCart;
    [self updateViews];
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    RLOG(@"textFieldShouldReturn");
    for (PairCart* p in _tempPairArray) {
        if(textField == p.textFieldQuantity){
            if ([textField.text isEqualToString:@""] || [textField.text isEqualToString:@"0"]) {
                textField.text = @"1";
            }
            break;
        }
    }
    [textField resignFirstResponder];
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    RLOG(@"shouldChangeCharactersInRange");
    for (PairCart* p in _tempPairArray) {
        if(textField == p.textFieldQuantity){
            RLOG(@"textField= %@", textField);
            RLOG(@"p.textFieldQuantity= %@", p.textFieldQuantity);
            [p.textFieldQuantity setPlaceholder:@""];
            
            
            if(string.length > 0) {
                NSCharacterSet *numbersOnly = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
                NSCharacterSet *characterSetFromTextField = [NSCharacterSet characterSetWithCharactersInString:string];
                BOOL stringIsValid = [numbersOnly isSupersetOfSet:characterSetFromTextField];
                return stringIsValid;
            }
            //            else{
            //                if ([p.textFieldQuantity.text length] == 1) {
            //                    p.textFieldQuantity.text = @"1";
            //                    return NO;
            //                }
            //            }
            break;
        }
    }
    return YES;
}
-(void)cancelNumberPad:(UIBarButtonItem*)button {
    UITextField* textInputQuantity;
    for (PairCart* p in _tempPairArray) {
        if(button == p.cancelBtn){
            textInputQuantity = p.textFieldQuantity;
            textInputQuantity.text = [NSString stringWithFormat:@"%d",  p.cart.count];
            break;
        }
    }
    [self textFieldShouldReturn:textInputQuantity];
}
-(void)doneWithNumberPad:(UIBarButtonItem*)button {
    UITextField* textInputQuantity;
    for (PairCart* p in _tempPairArray) {
        if(button == p.doneBtn){
            textInputQuantity = p.textFieldQuantity;
            break;
        }
    }
    [self textFieldShouldReturn:textInputQuantity];
}
- (void)doneWithDeviceKeyPad:(UIBarButtonItem*)button {
    if (_textViewFirstResponder) {
        [_textViewFirstResponder resignFirstResponder];
    }
}

//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
//{
//    if (!string.length)
//        return YES;
//
//    if (textField == _textInputQuantity)
//    {
//        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
//        NSString *expression = @"^([0-9]+)?(\\([0-9]{1,2})?)?$";
//        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression
//                                                                               options:NSRegularExpressionCaseInsensitive
//                                                                                 error:nil];
//        NSUInteger numberOfMatches = [regex numberOfMatchesInString:newString
//                                                            options:0
//                                                              range:NSMakeRange(0, [newString length])];
//        if (numberOfMatches == 0)
//            return NO;
//    }
//    return YES;
//}

- (void)showErrorAlert
{
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"" message:Localize(@"i_field_compulsary") delegate:nil cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil, nil];
    [errorAlert show];
}



- (UIView*)addFinalAmountView {
    float viewMaxHeight = [[MyDevice sharedManager] screenHeightInPortrait] * .4f;
    float viewMaxWidth = self.view.frame.size.width * .98f;
    float viewOriginX = self.view.frame.size.width * .01f;
    float viewOriginY = self.view.frame.size.width * .01f;
    
    _labelTotalItems = [[UILabel alloc] init];
    _labelGrandTotal = [[UILabel alloc] init];
    
    UIView* view = [[UIView alloc] init];
    [view setFrame:CGRectMake(viewOriginX, viewOriginY, viewMaxWidth, viewMaxHeight * .3f)];
    [Utility showShadow:view];
    //    [view.layer setBorderColor:[[Utility getUIColor:kUIColorBorder] CGColor]];
    //    [view.layer setBorderWidth:1];
    [view setBackgroundColor:[UIColor whiteColor]];
    [_scrollView addSubview:view];
    [_viewsAdded addObject:view];
    [view setTag:kTagForGlobalSpacing];
    
    UILabel* labelTotalItemsHeading = [[UILabel alloc] init];
    UILabel* labelTotalItems = _labelTotalItems;
    UILabel* labelGrandTotalHeading = [[UILabel alloc] init];
    UILabel* labelGrandTotal = _labelGrandTotal;
    
    [view addSubview:labelTotalItemsHeading];
    [view addSubview:labelTotalItems];
    [view addSubview:labelGrandTotalHeading];
    [view addSubview:labelGrandTotal];
    
    [labelTotalItemsHeading setText:Localize(@"i_total_items")];
    [labelGrandTotalHeading setText:Localize(@"i_cart_totals")];
    
    int itemsCount = [Cart getItemCount];
    float totalPrice = [Cart getTotalPayment];
    
    NSString* stringItemsCount = [NSString stringWithFormat:@"%d", itemsCount];
    NSString* stringGrandTotal = [[Utility sharedManager] convertToString:totalPrice isCurrency:true];
    
    [labelTotalItems setText:stringItemsCount];
    [labelGrandTotal setText:stringGrandTotal];
    
//    [labelGrandTotalHeading.layer setBorderWidth:1];
    [labelGrandTotalHeading setLineBreakMode:NSLineBreakByCharWrapping];
    [labelGrandTotalHeading setNumberOfLines:0];
    [labelGrandTotalHeading sizeToFitUI];
    
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        [labelTotalItemsHeading setTextAlignment:NSTextAlignmentRight];
        [labelGrandTotalHeading setTextAlignment:NSTextAlignmentRight];
        [labelTotalItems setTextAlignment:NSTextAlignmentLeft];
        [labelGrandTotal setTextAlignment:NSTextAlignmentLeft];
    } else {
        [labelTotalItemsHeading setTextAlignment:NSTextAlignmentLeft];
        [labelGrandTotalHeading setTextAlignment:NSTextAlignmentLeft];
        [labelTotalItems setTextAlignment:NSTextAlignmentRight];
        [labelGrandTotal setTextAlignment:NSTextAlignmentRight];
    }
    
    [labelTotalItemsHeading setUIFont:kUIFontType18 isBold:false];
    [labelTotalItems setUIFont:kUIFontType18 isBold:false];
    [labelGrandTotalHeading setUIFont:kUIFontType20 isBold:false];
    [labelGrandTotal setUIFont:kUIFontType20 isBold:false];
    
    
    labelTotalItemsHeading.textColor = [Utility getUIColor:kUIColorFontLight];
    labelTotalItems.textColor = [Utility getUIColor:kUIColorFontLight];
    labelGrandTotalHeading.textColor = [Utility getUIColor:kUIColorFontDark];
    labelGrandTotal.textColor = [Utility getUIColor:kUIColorFontDark];
    
    float horizontalPadding = view.frame.size.width * .15f;
    float width = view.frame.size.width - horizontalPadding * 2;
    float label1Posy = view.frame.size.height * .33f;
    float label2Posy = view.frame.size.height * .66f;
    
    [labelGrandTotalHeading setFrame:CGRectMake(horizontalPadding,
                                               label2Posy - labelGrandTotalHeading.frame.size.height / 2,
                                               width/2,
                                               labelGrandTotalHeading.frame.size.height
                                               )];
    [labelGrandTotal setFrame:CGRectMake(
                                         CGRectGetMaxX(labelGrandTotalHeading.frame) ,
                                         label2Posy - labelGrandTotal.frame.size.height / 2,
                                         width/2,
                                         labelGrandTotal.frame.size.height
                                         )];
    
    
    [labelTotalItemsHeading sizeToFitUI];
    [labelGrandTotalHeading sizeToFitUI];
    [labelTotalItems sizeToFitUI];
    [labelGrandTotal sizeToFitUI];
    
    
    [labelTotalItemsHeading setFrame:CGRectMake(horizontalPadding, label1Posy - labelTotalItemsHeading.frame.size.height / 2, width, labelTotalItemsHeading.frame.size.height)];
    [labelTotalItems setFrame:CGRectMake(horizontalPadding, label1Posy - labelTotalItems.frame.size.height / 2, width, labelTotalItems.frame.size.height)];
    
    [labelGrandTotalHeading setFrame:CGRectMake(horizontalPadding,
                                                label2Posy - labelGrandTotalHeading.frame.size.height / 2,
                                                width/2,
                                                labelGrandTotalHeading.frame.size.height
                                                )];
    [labelGrandTotal setFrame:CGRectMake(
                                         CGRectGetMaxX(labelGrandTotalHeading.frame) ,
                                         label2Posy - labelGrandTotal.frame.size.height / 2,
                                         width/2,
                                         labelGrandTotal.frame.size.height
                                         )];
    
    return view;
}
//- (UIButton*)addPlaceOrderButton {
//    float buttonPosY = self.view.frame.size.width * .01f;
//    float buttonWidth = [[MyDevice sharedManager] screenWidthInPortrait] * 0.6f;;
//    float buttonHeight = [[MyDevice sharedManager] screenHeightInPortrait] * .075f;
//    //    float buttonHeight = MIN(self.view.frame.size.width * 0.15f, 76);
//    float buttonPosX = (self.view.frame.size.width - buttonWidth) / 2;
//
//    UIButton *buttonBuy = [[UIButton alloc] initWithFrame:CGRectMake(buttonPosX, buttonPosY, buttonWidth, buttonHeight)];
//    [buttonBuy setBackgroundColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
//    [[buttonBuy titleLabel] setUIFont:kUIFontType22 isBold:false];
//#if TMH
//    [buttonBuy setTitle:Localize(@"PLACE AD BOOKING") forState:UIControlStateNormal];
//#else
//    [buttonBuy setTitle:Localize(@"PLACE ORDER") forState:UIControlStateNormal];
//#endif
//    [buttonBuy setTitleColor:[Utility getUIColor:kUIColorBuyButtonFont] forState:UIControlStateNormal];
//    [buttonBuy addTarget:self action:@selector(placeOrder:) forControlEvents:UIControlEventTouchUpInside];
//
//    [_scrollView addSubview:buttonBuy];
//    [_viewsAdded addObject:buttonBuy];
//    [buttonBuy setTag:kTagForGlobalSpacing];
//    return buttonBuy;
//}
- (void)resetScrollViewFrame {
    BOOL showKeepShopping = [[Addons sharedManager] show_keep_shopping_in_cart];
    BOOL showPlaceOrder = true;
    if(showKeepShopping == false && showPlaceOrder == false) {
        return;
    }
    
    float buttonHeight = [[MyDevice sharedManager] screenHeightInPortrait] * .075f;
    float viewHeight = buttonHeight * 1.25f;
    _scrollView.frame = CGRectMake(_scrollView.frame.origin.x, _scrollView.frame.origin.y, _scrollView.frame.size.width, [[MyDevice sharedManager] screenSize].height - [[Utility sharedManager] getBottomBarHeight]  - [[Utility sharedManager] getTopBarHeight] - viewHeight);
}
-(void)keepShoppingAndPlaceorderButtonView {
    BOOL showKeepShopping = [[Addons sharedManager] show_keep_shopping_in_cart];
    BOOL showPlaceOrder = true;
    if(showKeepShopping == false && showPlaceOrder == false) {
        return;
    }
    
    float buttonHeight = [[MyDevice sharedManager] screenHeightInPortrait] * .075f;
    float viewHeight = buttonHeight * 1.25f;
    _scrollView.frame = CGRectMake(_scrollView.frame.origin.x, _scrollView.frame.origin.y, _scrollView.frame.size.width, [[MyDevice sharedManager] screenSize].height - [[Utility sharedManager] getBottomBarHeight]  - [[Utility sharedManager] getTopBarHeight] - viewHeight);
    float viewWidth = [[MyDevice sharedManager] screenSize].width;
    if (_footerView) {
        [_footerView removeFromSuperview];
    }
    _footerView=[[UIView alloc]init];
    _footerView.frame = CGRectMake(0, _scrollView.frame.size.height, viewWidth, viewHeight);
    _footerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_footerView];
    
    
    
    BOOL isSingleButton = false;
    if (showKeepShopping != showPlaceOrder) {
        isSingleButton = true;
    }
    
    
    if (showKeepShopping) {
        [self addKeepshoppingButton:isSingleButton];
    }
    if (showPlaceOrder) {
        [self addPlaceOrderButtons:isSingleButton];
    }
    [self.view bringSubviewToFront:_scrollView];
}
- (UIButton*)addKeepshoppingButton:(BOOL)isSingleButton {
    float buttonWidth = [[MyDevice sharedManager] screenSize].width * 0.46f;
    float buttonHeight = [[MyDevice sharedManager] screenHeightInPortrait] * .075f;
    float buttonPosX = self.view.frame.size.width * .02f;
    UIButton *buttonKeepShoping = [[UIButton alloc] init];
    if (isSingleButton) {
        buttonWidth = [[MyDevice sharedManager] screenWidthInPortrait] * 0.6f;
        buttonKeepShoping.frame = CGRectMake(buttonPosX, 0, buttonWidth, buttonHeight);
        buttonKeepShoping.center = CGPointMake(_footerView.frame.size.width/2, _footerView.frame.size.height/2);
    } else {
        buttonWidth = [[MyDevice sharedManager] screenSize].width * 0.46f;
        buttonKeepShoping.frame = CGRectMake(buttonPosX, 0, buttonWidth, buttonHeight);
        buttonKeepShoping.center = CGPointMake(buttonKeepShoping.center.x, _footerView.frame.size.height/2);
    }
    [buttonKeepShoping setBackgroundColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
    [[buttonKeepShoping titleLabel] setUIFont:kUIFontType22 isBold:false];
    [buttonKeepShoping setTitle:Localize(@"keep_shopping_cart") forState:UIControlStateNormal];
    [buttonKeepShoping setTitleColor:[Utility getUIColor:kUIColorBuyButtonFont] forState:UIControlStateNormal];
    [buttonKeepShoping addTarget:self action:@selector(keepShoingAction:) forControlEvents:UIControlEventTouchUpInside];
    [_footerView addSubview:buttonKeepShoping];
    return buttonKeepShoping;
}
- (UIButton*)addPlaceOrderButtons:(BOOL)isSingleButton {
    float buttonWidth = [[MyDevice sharedManager] screenSize].width * 0.46f;
    float buttonHeight = [[MyDevice sharedManager] screenHeightInPortrait] * .075f;
    float buttonPosX = (_footerView.frame.size.width) / 2 + self.view.frame.size.width * .02f;
    UIButton *buttonBuy = [[UIButton alloc] init];
    if (isSingleButton) {
        buttonWidth = [[MyDevice sharedManager] screenWidthInPortrait] * 0.6f;
        buttonBuy.frame = CGRectMake(buttonPosX, 0, buttonWidth, buttonHeight);
        buttonBuy.center = CGPointMake(_footerView.frame.size.width/2, _footerView.frame.size.height/2);
    } else {
        buttonWidth = [[MyDevice sharedManager] screenSize].width * 0.46f;
        buttonBuy.frame = CGRectMake(buttonPosX, 0, buttonWidth, buttonHeight);
        buttonBuy.center = CGPointMake(buttonBuy.center.x, _footerView.frame.size.height/2);
    }
    [buttonBuy setBackgroundColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
    [[buttonBuy titleLabel] setUIFont:kUIFontType22 isBold:false];
    [buttonBuy setTitle:Localize(@"place_order") forState:UIControlStateNormal];
    [buttonBuy setTitleColor:[Utility getUIColor:kUIColorBuyButtonFont] forState:UIControlStateNormal];
    [buttonBuy addTarget:self action:@selector(placeOrder:) forControlEvents:UIControlEventTouchUpInside];
    [_footerView addSubview:buttonBuy];
    return buttonBuy;
}
-(void)keepShoingAction:(UIButton *)button{
    ViewControllerMain* mainVC = [ViewControllerMain getInstance];
    [mainVC btnClickedHome:nil];
}
- (void)moveToWishlist:(UIButton*)button forcedRemove:(BOOL)forcedRemove {
    {
        if (_isKeyboardVisible) {
            return;
        }
        
        RLOG(@"Button moveToWishlist");
        if ([button isSelected]) {
            [button setSelected:false];
        }else{
            [button setSelected:true];
        }
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            CGRect rect = button.superview.superview.frame;
            rect.origin.x = self.view.frame.size.width * 2;
            [button.superview.superview setFrame:rect];
        } completion:^(BOOL finished){
            [button.superview.superview removeFromSuperview];
            [_viewsAdded removeObject:button.superview.superview];
            [self resetMainScrollView:0.25f];
        }];
        
        for (PairCart* p in _tempPairArray) {
            if(button == p.buttonRight || button == p.buttonLeft){
                ProductInfo* pInfo = p.cart.product;
                if (forcedRemove) {
                    [Cart removeProduct:pInfo variationId:p.cart.selectedVariationId variationIndex:p.cart.selectedVariationIndex];
                } else {
                    if ([[Addons sharedManager] remove_cart_or_wish_items]) {
                        [Cart removeProduct:pInfo variationId:p.cart.selectedVariationId variationIndex:p.cart.selectedVariationIndex];
                    }
                }
                [Wishlist addProduct:pInfo variationId:p.cart.selectedVariationId];
                [self updateRewardDiscountView];
                [self updateViews];
                [_tempPairArray removeObject:p];
                break;
            }
        }
    }
}
- (void)moveToWishlist:(UIButton*)button
{
    [self moveToWishlist:button forcedRemove:false];
}
- (void)removeFromList:(UIButton*)button
{
    if (_isKeyboardVisible) {
        return;
    }
    
    RLOG(@"Button removeFromList");
    if ([button isSelected]) {
        [button setSelected:false];
    }else{
        [button setSelected:true];
    }
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        RLOG(@"Animation needed.");
        CGRect rect = button.superview.superview.frame;
        rect.origin.x = self.view.frame.size.width * 2;
        [button.superview.superview setFrame:rect];
    } completion:^(BOOL finished){
        RLOG(@"Animation completed.");
        [button.superview.superview removeFromSuperview];
        [_viewsAdded removeObject:button.superview.superview];
        [self resetCrosscellData];
        [self resetMainScrollView:0.25f];
    }];
    for (PairCart* p in _tempPairArray) {
        if(button == p.buttonRight || button == p.buttonLeft){
            ProductInfo* pInfo = p.cart.product;
            [Cart removeProduct:pInfo variationId:p.cart.selectedVariationId variationIndex:p.cart.selectedVariationIndex];
            [self updateRewardDiscountView];
            [self updateViews];
            [_tempPairArray removeObject:p];
            break;
        }
    }
}
-(void)LoginCompletedCart:(NSNotification*)notification{
    [self placeOrder:nil];
}
- (void)placeOrder:(UIButton*)button
{
    if (_isKeyboardVisible) {
        return;
    }
    //if ([[Utility sharedManager] checkForDemoApp:true]) return;
    
    _isPlaceOrderClicked = true;
    
#if ESCAPE_CART_VARIFICATION
    [self goToNextStep];
    return;
#endif
    [Utility createCustomizedLoadingBar:Localize(@"verifying_cart") isBottomAlign:false isClearViewEnabled:false isShadowEnabled:true];
    [self fetchCartFullData];
}
- (void)fetchCartFullData {
    [[[DataManager sharedManager] tmDataDoctor] fetchCartProductsDataFromPlugin:^(id data) {
        
        if ([[Addons sharedManager] enable_multi_store_checkout] && [[MultiStoreCheckoutConfig getInstance] isDataFetched] == false) {
            [[[DataManager sharedManager] tmDataDoctor] getWCCMData:^(id data) {
//                RLOG(@"%@", data);
//                UIView* view = [self createWCCMView];
//                [Utility showShadow:view];
                [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
                [self goToNextStep];
            } failure:^(NSString *error) {
//                RLOG(@"%@", error);
                [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
                [self goToNextStep];
            }];
        } else {
            [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
            [self goToNextStep];
        }
        
//        [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
//        [self goToNextStep];
    } failure:^(NSString *error) {
        [self fetchCartFullData];
    }];
}
- (void)goToNextStep {
    PairCart* selectedPairCart = nil;
    RLOG(@"_tempPairArray count = %d", (int)[_tempPairArray count]);
    for (PairCart* p in _tempPairArray) {
        selectedPairCart = p;
        int userDemand = selectedPairCart.cart.count;
        ProductInfo* pInfo = selectedPairCart.cart.product;
        
        
        if(selectedPairCart.cart.prddDate){
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"dd/MM/yyyy"];
            NSDate *todayDate = [NSDate date];
            NSDate *selectedDate = [dateFormat dateFromString:selectedPairCart.cart.prddDate];
            if ([selectedDate compare:todayDate] == NSOrderedDescending) {
                NSLog(@"selectedDate is later than todayDate");
                //its alright
            } else if ([selectedDate compare:todayDate] == NSOrderedAscending) {
                NSLog(@"selectedDate is earlier than todayDate");
                // need to remove item to wishlist
                _cartNeedToMoveToWishlist = selectedPairCart;
                UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:pInfo._titleForOuterView message:Localize(@"slot_out_of_date") delegate:self cancelButtonTitle:Localize(@"Move To Wishlist") otherButtonTitles:nil, nil];
                [errorAlert setTag:23];
                [errorAlert show];
                return;
            } else {
                NSLog(@"dates are the same");
                //need to check delivery time
                if(selectedPairCart.cart.prddTime){
                    int selectedTimeEH = 0;
                    int selectedTimeEM = 0;
                    NSArray* times = [selectedPairCart.cart.prddTime.slot_title componentsSeparatedByString:@"-"];
                    if (times && [times count] == 2) {
                        NSString* endTime = [times objectAtIndex:1];
                        NSArray* endTimes = [endTime componentsSeparatedByString:@":"];
                        if (endTimes && [endTimes count] == 2) {
                            selectedTimeEH = [[endTimes objectAtIndex:0] intValue];
                            selectedTimeEM = [[endTimes objectAtIndex:1] intValue];
                        }
                    }
                    
                    
                    int currentTimeEH = 0;
                    int currentTimeEM = 0;
                    NSDate *now = [NSDate date];
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    dateFormatter.dateFormat = @"hh:mm";
                    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
                    NSString* timeString = [dateFormatter stringFromDate:now];
                    NSArray* timeSeperate = [timeString componentsSeparatedByString:@":"];
                    if (timeSeperate && [timeSeperate count] == 2) {
                        currentTimeEH = [[timeSeperate objectAtIndex:0] intValue];
                        currentTimeEM = [[timeSeperate objectAtIndex:1] intValue];
                    }
                    if (selectedTimeEH < currentTimeEH) {
                        //move to wishlist
                        _cartNeedToMoveToWishlist = selectedPairCart;
                        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:pInfo._titleForOuterView message:Localize(@"slot_out_of_date") delegate:self cancelButtonTitle:Localize(@"Move To Wishlist") otherButtonTitles:nil, nil];
                        [errorAlert setTag:23];
                        [errorAlert show];
                        return;
                    }
                }
            }
        }
        
        if (selectedPairCart.cart.selectedVariationIndex != -1) {
            int userDemand_ByVariation = 0;
            for (PairCart* temp_p in _tempPairArray) {
                if(temp_p.cart.selectedVariationId == selectedPairCart.cart.selectedVariationId) {
                    userDemand_ByVariation += temp_p.cart.count;
                }
            }
            if (userDemand_ByVariation != 0) {
                int availState_ByVariation = [selectedPairCart.cart getProductAvailibleState:userDemand_ByVariation];
                int qty_ByVariation = [selectedPairCart.cart getProductAvailibleQuantity:userDemand_ByVariation];
                if (availState_ByVariation == PRODUCT_QTY_ZERO) {
                    //out of stock
                    userDemand_ByVariation = 0;
                    _cartNeedToMoveToWishlist = selectedPairCart;
                    selectedPairCart.cart.count = userDemand_ByVariation;
                    
                    //item out of stock and move to wishlist
                    
                    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:pInfo._titleForOuterView message:Localize(@"out_of_stock") delegate:self cancelButtonTitle:Localize(@"Move To Wishlist") otherButtonTitles:nil, nil];
                    [errorAlert setTag:23];
                    [errorAlert show];
                    
                    return;
                }
                else if (availState_ByVariation == PRODUCT_QTY_STOCK) {
                    //limited stock
                    //                    userDemand_ByVariation = qty_ByVariation;
                    //                    _cartNeedToMoveToWishlist = selectedPairCart;
                    //                    selectedPairCart.cart.count = userDemand_ByVariation;
                    //                    [selectedPairCart.textFieldQuantity setText:[NSString stringWithFormat:@"%d",userDemand_ByVariation]];
                    
                    NSString * strQty = [NSString stringWithFormat:Localize(@"items_available"), qty_ByVariation];
                    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:pInfo._titleForOuterView message:strQty delegate:self cancelButtonTitle:Localize(@"i_ok") otherButtonTitles:nil, nil];
                    [errorAlert setTag:24];
                    [errorAlert show];
                    return;
                }
                else {
                    //available to purchase
                }
            }
        }
        
        
        
        int availState = [selectedPairCart.cart getProductAvailibleState:userDemand];
        int qty = [selectedPairCart.cart getProductAvailibleQuantity:userDemand];
        if (availState == PRODUCT_QTY_ZERO) {
            //out of stock
            userDemand = 0;
            _cartNeedToMoveToWishlist = selectedPairCart;
            selectedPairCart.cart.count = userDemand;
            
            //item out of stock and move to wishlist

            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:pInfo._titleForOuterView message:Localize(@"out_of_stock") delegate:self cancelButtonTitle:Localize(@"Move To Wishlist") otherButtonTitles:nil, nil];
            [errorAlert setTag:23];
            [errorAlert show];
            
            return;
        }
        else if (availState == PRODUCT_QTY_STOCK) {
            //limited stock
            userDemand = qty;
            _cartNeedToMoveToWishlist = selectedPairCart;
            selectedPairCart.cart.count = userDemand;
            [selectedPairCart.textFieldQuantity setText:[NSString stringWithFormat:@"%d",userDemand]];
            
            NSString * strQty = [NSString stringWithFormat:Localize(@"items_available"), qty];
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:pInfo._titleForOuterView message:strQty delegate:self cancelButtonTitle:Localize(@"i_ok") otherButtonTitles:nil, nil];
            [errorAlert setTag:24];
            [errorAlert show];
            return;
        }
        else {
            //available to purchase
        }
    }
    
    
    
    AppUser* appUser = [AppUser sharedManager];
    if(appUser._isUserLoggedIn || [[GuestConfig sharedInstance] guest_checkout]){
        BOOL gotoDirectConfirmation = true;
#if ENABLE_ADDRESS_WITH_MAP
        gotoDirectConfirmation = ![[Addons sharedManager] use_multiple_shipping_addresses];
#endif
        if (gotoDirectConfirmation) {
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
            ViewControllerCartConfirmation* vcCartConfirmation = (ViewControllerCartConfirmation*)[[Utility sharedManager] pushScreenWithoutAnimation:mainVC.vcCenterTop type:PUSH_SCREEN_TYPE_CART_CONFIRM];
            RLOG(@"vcCartConfirmation = %@", vcCartConfirmation);
        } else {
            [self fetchMultipleShippingAddress];
        }
    } else{
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LoginCompletedCart" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LoginCompletedCart:) name:@"LoginCompletedCart" object:nil];
        
        ViewControllerMain* mainVC = [ViewControllerMain getInstance];
        ViewControllerLeft* leftVC = (ViewControllerLeft*)(mainVC.revealController.rearViewController);
        [leftVC showLoginPopup:true];
    }
}
- (void)fetchMultipleShippingAddress {
    [[[DataManager sharedManager] tmDataDoctor] fetchMultipleShippingAddress:^(id responseObj) {
        [self gotoAddressMapScreen:responseObj];
    } failure:^(NSString *errorString) {
//        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:errorString delegate:self cancelButtonTitle:Localize(@"cancel") otherButtonTitles:Localize(@"retry"), nil];
//        [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
//            if (buttonIndex == 1) {
//                [self fetchMultipleShippingAddress];
//            } else {
                [self gotoAddressMapScreen:nil];
//            }
//        }];
    }];
}
- (void)gotoAddressMapScreen:(NSArray*)responseObj {
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
    VCAddressMap* vcAddressMap = (VCAddressMap*)[[Utility sharedManager] pushScreenWithoutAnimation:mainVC.vcCenterTop type:PUSH_SCREEN_TYPE_ADDRESS_MAP];
    [vcAddressMap setShippingAddresses:responseObj];
}
- (UIView*)createAppliedCouponView {
    UILabel* labelTemp= [[UILabel alloc] init];
    [labelTemp setUIFont:kUIFontType18 isBold:false];
    UIView* view;
    if (_autoAppliedCouponView == nil) {
        view = [[UIView alloc] init];
        [view setFrame:CGRectMake(self.view.frame.size.width * 0.01f, 0, self.view.frame.size.width * 0.98f, [[labelTemp font] lineHeight] * 10)];
        [view setBackgroundColor:[UIColor whiteColor]];
        [_scrollView addSubview:view];
        [_viewsAdded addObject:view];
        [view setTag:kTagForNoSpacing];
        _autoAppliedCouponView = view;
    } else {
        view = _autoAppliedCouponView;
        for (UIView* v in [_autoAppliedCouponView subviews]) {
            [v removeFromSuperview];
        }
    }
    float leftItemsPosX = self.view.frame.size.width * 0.2f;
    float itemPosY = self.view.frame.size.width * 0.04f;
    float width = view.frame.size.width - leftItemsPosX - self.view.frame.size.width * 0.03f;
    float fontHeight = labelTemp.font.lineHeight;
    [view addSubview:[self addBorder:view]];
    ///heading
    UILabel *labelHeading = [[UILabel alloc] init];
    [view addSubview:labelHeading];
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        [labelHeading setTextAlignment:NSTextAlignmentRight];
    } else {
        [labelHeading setTextAlignment:NSTextAlignmentLeft];
    }
    [labelHeading setFrame:CGRectMake(self.view.frame.size.width * .02f, itemPosY, view.frame.size.width * .96f, fontHeight)];
    [labelHeading setUIFont:kUIFontType18 isBold:false];
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        [labelHeading setText:[NSString stringWithFormat:@":%@", Localize(@"applied_coupons")]];
    } else {
        [labelHeading setText:[NSString stringWithFormat:@"%@:", Localize(@"applied_coupons")]];
    }
    
    
    [labelHeading setTextColor:[Utility getUIColor:kUIColorFontLight]];
    [labelHeading setNumberOfLines:0];
    [labelHeading sizeToFitUI];
    itemPosY = CGRectGetMaxY(labelHeading.frame) + fontHeight;
    ///coupons name and amount
    for (AppliedCoupon* appliedCoupon in [[CartMeta sharedInstance] getAppliedCoupons]) {
        UILabel* labelAmountColon= [[UILabel alloc] init];
        [labelAmountColon setUIFont:kUIFontType16 isBold:false];
        fontHeight = [[labelAmountColon font] lineHeight];
        
        float discountAmount = appliedCoupon.discount_amount;
        NSString* couponTitleString = [NSString stringWithFormat:@"%@", appliedCoupon.title];
        NSString* couponCostString = [NSString stringWithFormat:@"- %@",[[Utility sharedManager] convertToString:discountAmount isCurrency:true symbolAtLast:false]];
        
        
        UILabel* labelTitle= [[UILabel alloc] init];
        [labelTitle setUIFont:kUIFontType16 isBold:false];
        [labelTitle setTextColor:[Utility getUIColor:kUIColorFontLight]];
        [view addSubview:labelTitle];
        [labelTitle setText:couponTitleString];
        [labelTitle setFrame:CGRectMake(0, itemPosY, view.frame.size.width * .5f, fontHeight * 1.5f)];
        labelTitle.center = CGPointMake(view.frame.size.width * .5f, labelTitle.center.y);
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [labelTitle setTextAlignment:NSTextAlignmentCenter];
        } else {
            [labelTitle setTextAlignment:NSTextAlignmentCenter];
        }
        labelTitle.layer.borderWidth = 1;
        labelTitle.layer.borderColor = [Utility getUIColor:kUIColorBorder].CGColor;
        
        
        UILabel* labelAmount= [[UILabel alloc] init];
        [labelAmount setUIFont:kUIFontType16 isBold:false];
        fontHeight = [[labelAmount font] lineHeight];
        [labelAmount setTextColor:[Utility getUIColor:kUIColorFontDark]];
        [view addSubview:labelAmount];
        [labelAmount setText:couponCostString];
        [labelAmount setFrame:CGRectMake(leftItemsPosX, itemPosY, width, fontHeight)];
        labelAmount.center = CGPointMake(labelAmount.center.x, labelTitle.center.y);
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [labelAmount setTextAlignment:NSTextAlignmentLeft];
        } else {
            [labelAmount setTextAlignment:NSTextAlignmentRight];
        }
        itemPosY += fontHeight;
    }
    UIActivityIndicatorView* spinnerView = nil;
    if ([[[CartMeta sharedInstance] getAppliedCoupons] count] == 0) {
        if (self.isLoadingAppliedCoupon) {
            spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [spinnerView setFrame:CGRectMake(0, itemPosY, spinnerView.frame.size.width, spinnerView.frame.size.height)];
            [spinnerView startAnimating];
            [view addSubview:spinnerView];
            itemPosY = CGRectGetMaxY(spinnerView.frame);
        }else {
            [view setFrame:CGRectMake(self.view.frame.size.width * 0.01f, 0, self.view.frame.size.width * 0.98f, 0)];
            view.layer.shadowOpacity = 0.0f;
            [Utility showShadow:view];
            [view setTag:kTagForNoSpacing];
            return view;
        }
    }
    itemPosY += self.view.frame.size.width * 0.04f;
    [view setFrame:CGRectMake(self.view.frame.size.width * 0.01f, 0, self.view.frame.size.width * 0.98f, itemPosY)];
    view.layer.shadowOpacity = 0.0f;
    [Utility showShadow:view];
    if (spinnerView) {
        spinnerView.center = CGPointMake(view.frame.size.width/2, view.frame.size.height/2);
    }
    return view;
}
#pragma mark - Deal Views
- (void)createVariousViews {
    for (int i = 0; i < _kTotalViewsCartScreen; i++) {
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
            [_scrollView addSubview:_viewUserDefinedHeader[i]];
            [_viewsAdded addObject:_viewUserDefinedHeader[i]];
            [_viewUserDefinedHeader[i] setTag:kTagForNoSpacing];
        }
        UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
        switch (i) {
            case _kCrossSell:
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
        [self resetMainScrollView:false];
    }
}
#pragma mark - Category View
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    int itemCount = 0;
    int i = 0;
    for (; i < _kTotalViewsCartScreen; i++) {
        if(_viewUserDefined[i] == collectionView){
            break;
        }
    }
    switch (i) {
        case _kRelatedProduct:
        {
            itemCount = (int)[crossCellIds count];
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
    for (; i < _kTotalViewsCartScreen; i++) {
        if(_viewUserDefined[i] == collectionView){
            break;
        }
    }
    if (i < _kTotalViewsCartScreen && _propCollectionView[i]._insetTop != -1) {
        collectionView.contentInset = UIEdgeInsetsMake(_propCollectionView[i]._insetTop, _propCollectionView[i]._insetLeft, _propCollectionView[i]._insetBottom, _propCollectionView[i]._insetRight);
        
    }
    switch (i) {
        case _kCrossSell:
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
                ProductInfo *pInfo = [ProductInfo getProductWithId:[[crossCellIds objectAtIndex:indexPath.row] intValue]];
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
                }else {
                    [cell.layer setValue:nil forKey:@"PRODUCT_INFO"];
                    [cell.layer setValue:nil forKey:@"PINFO_OBJ"];
                }
            }
        }break;
        default:
            break;
    }
    [cell setNeedsLayout];
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    int i = 0;
    for (; i < _kTotalViewsCartScreen; i++) {
        if(_viewUserDefined[i] == collectionView){
            break;
        }
    }
    NSMutableArray *array = nil;
    switch (i) {
        case _kCrossSell:
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
            [self resetMainScrollView:false];
            return CGSizeMake(cardWidth, cardHeight);
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
    for (; i < _kTotalViewsCartScreen; i++) {
        if(_viewUserDefined[i] == collectionView){
            break;
        }
    }
    switch (i) {
        case _kCrossSell:
        {
        }break;
        default:
            break;
    }
}
- (void)removeUserDefinedView:(int)viewId {
    _isViewUserDefinedEnable[viewId] = false;
    RLOG("***************  _isViewUserDefinedEnable  2 ***************");
    [_viewUserDefinedHeader[viewId] removeFromSuperview];
    [_viewsAdded removeObject:_viewUserDefinedHeader[viewId]];
    [_viewUserDefined[viewId] removeFromSuperview];
    [_viewsAdded removeObject:_viewUserDefined[viewId]];
    [self resetMainScrollView:false];
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
- (void)clickOnProduct:(ProductInfo*)productClicked currentItemData:(DataPass*)currentItemData cell:(id)cell{
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
    ViewControllerCategories* vcCategories = [[Utility sharedManager] pushScreen:mainVC.vcCenterTop];
    [vcCategories loadData:clickedItemData previousItem:previousItemData drillingLevel:0];
}
#pragma mark - Adjust Orientation
- (void)beforeRotation {
    [self beforeRotation:0.1f];
}
- (void)afterRotation {
    [self afterRotation:0.1f];
}
- (void)beforeRotation:(float)dt {
    
    [UIView animateWithDuration:dt animations:^{
        [_footerView setAlpha:0.0f];
    }completion:^(BOOL finished){
    }];
    
    
    UIView* lastView = [_viewsAdded lastObject];
    for(UIView *view in _viewsAdded)
    {
        [UIView animateWithDuration:dt animations:^{
            [view setAlpha:0.0f];
        }completion:^(BOOL finished){
            [view removeFromSuperview];
            if (view == lastView) {
                [_scrollView setAlpha:0.0f];
                [_viewsAdded removeAllObjects];
                _couponView = nil;
                _couponViewWithAppliedCoupon = nil;
                _couponViewWithTextField = nil;
                _rewardDiscountView = nil;
                _rewardDiscountViewWithTextField = nil;
                _autoAppliedCouponView = nil;
                [self loadViewDA];
                for(UIView *vieww in _viewsAdded)
                {
                    [vieww setAlpha:0.0f];
                }
                [_scrollView setAlpha:1.0f];
            }
        }];
    }
}
- (void)afterRotation:(float)dt  {
    for(UIView *vieww in _viewsAdded)
    {
        [UIView animateWithDuration:dt animations:^{
            [vieww setAlpha:1.0f];
        }completion:^(BOOL finished){
            
        }];
    }
    
    [UIView animateWithDuration:dt animations:^{
        [_footerView setAlpha:1.0f];
    }completion:^(BOOL finished){
    }];
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
    [self resetMainScrollView: 0.25f];
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if ([[AppDelegate getInstance] isAppEnteredInBackground]) {
        return;
    }
    [self adjustViewsForOrientation:[[UIDevice currentDevice] orientation]];
    [self resetMainScrollView: 0.25f];
}
#pragma mark - Reset Views
- (void)resetMainScrollView:(float) animInterval{
    __block float globalPosY = 0.0f;
    __block UIView* tempView = nil;
    __block int i = 0;
    __block int lastItemIndex = (int)[_viewsAdded count] - 1;
    for (tempView in _viewsAdded) {
        [UIView animateWithDuration:animInterval delay:0.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
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
            if (lastItemIndex == i){
                [_scrollView setContentSize:CGSizeMake(_scrollView.contentSize.width, globalPosY)];
                [self resetScrollViewFrame];

            }
            i++;
        }completion:^(BOOL finished){
            [self resetScrollViewFrame];
        }];
    }
}
- (void)updateViews {
    int itemsCount = [Cart getItemCount];
    float totalPrice = [Cart getTotalPayment];
    if(itemsCount == 0){
        _finalAmountView.hidden = true;
        _placeOrderButton.hidden = true;
        
        _scrollView.hidden = true;
        _footerView.hidden = true;
        _labelNoItems.hidden = false;
        _labelNoItems.text = Localize(@"no_items_in_cart");
        
    }else{
        _finalAmountView.hidden = false;
        _placeOrderButton.hidden = false;
        
        _scrollView.hidden = false;
        _footerView.hidden = false;
        _labelNoItems.hidden = true;
        
    }
    NSString* stringItemsCount = [NSString stringWithFormat:@"%d", itemsCount];
    NSString* stringGrandTotal = [[Utility sharedManager] convertToString:totalPrice isCurrency:true];
    
    [_labelTotalItems setText:stringItemsCount];
    [_labelGrandTotal setText:stringGrandTotal];
    
    [self loadAutoCoupons];
}

- (void)loadAutoCoupons {
    Addons* addons = [Addons sharedManager];
    if (addons.enable_auto_coupons == false)
        return;
    if ([Cart getItemCount] == 0) {
        return;
    }
    if (self.isLoadingAppliedCoupon == true) {
        return;
    }
    
    [[[CartMeta sharedInstance] getAppliedCoupons] removeAllObjects];
    self.isLoadingAppliedCoupon = true;
    [self createAppliedCouponView];
    [self resetMainScrollView:0.0f];
    [[[DataManager sharedManager] tmDataDoctor] syncCartForAppliedCoupon:^{
        self.isLoadingAppliedCoupon = false;
        [self createAppliedCouponView];
        [self resetMainScrollView:0.0f];
    } failure:^{
        self.isLoadingAppliedCoupon = false;
        [self loadAutoCoupons];
    }];
}

- (void)clickOnProduct:(ProductInfo*)productClicked currentItemData:(DataPass*)currentItemData variationId:(int) variationId variationIndex:(int)variationIndex cart:(Cart*)cart {
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
    DataPass* clickedItemData = [[DataPass alloc] init];
    clickedItemData.itemId = productClicked._id;
    clickedItemData.isCategory = false;
    clickedItemData.isProduct = true;
    clickedItemData.hasChildCategory = false;
    clickedItemData.childCount = false;
    clickedItemData.pInfo = productClicked;
    clickedItemData.variationId = variationId;
    clickedItemData.variationIndex = variationIndex;
    
    DataPass* previousItemData = [[DataPass alloc] init];
    previousItemData.itemId = currentItemData.cInfo._id;
    previousItemData.isCategory = currentItemData.isCategory;
    previousItemData.isProduct = currentItemData.isProduct;
    previousItemData.hasChildCategory = currentItemData.hasChildCategory;
    previousItemData.childCount = currentItemData.childCount;
    previousItemData.cInfo = currentItemData.cInfo;
    previousItemData.variationId = currentItemData.variationId;
    previousItemData.variationIndex = currentItemData.variationIndex;
    
    
    ViewControllerProduct* vcProduct = [[Utility sharedManager] pushProductScreen:mainVC.vcCenterTop];
    //    [vcProduct loadData:clickedItemData previousItem:previousItemData drillingLevel:0];
    clickedItemData.cart = cart;
    [vcProduct loadData:clickedItemData previousItem:previousItemData drillingLevel:0 variationId:variationId];
    if ([[Addons sharedManager] enable_mixmatch_products]) {
        if (cart.mMixMatchProducts) {
            vcProduct.matchedItems = [[NSMutableArray alloc] initWithArray:cart.mMixMatchProducts];
            UICollectionView* cV = [vcProduct getViewUserDefined:_kMIXNMATCH];
            if (cV) {
                [cV reloadData];
            }
        }
    }
//    if ([[Addons sharedManager] enable_bundled_products]) {
//        if (cart.mBundleProducts) {
//            vcProduct.bundleItems = [[NSMutableArray alloc] initWithArray:cart.mBundleProducts];
//            UICollectionView* cV = [vcProduct getViewUserDefined:_kBUNDLE];
//            if (cV) {
//                [cV reloadData];
//            }
//        }
//    }
    
    
}
- (UIView*)addBorder:(UIView*)view{
    UIView* viewBorder = [[UIView alloc] init];
    [viewBorder setFrame:CGRectMake(0, 0, view.frame.size.width, 1)];
    [viewBorder setBackgroundColor:[Utility getUIColor:kUIColorBorder]];
    return viewBorder;
}
- (UIView*)createNotesView:(UITextView*)textView{
    CartNote* cartNote = [[Addons sharedManager] cartNote];
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
    
    
    UILabel* cartPlaceHolder = [[UILabel alloc] initWithFrame:CGRectMake(textFieldPosX, textFieldPosY, textFieldWidth, textFieldHeight)];
    [cartPlaceHolder setUIFont:fontType isBold:false];
    [cartPlaceHolder setTextColor:[Utility getUIColor:kUIColorFontLight]];
    if ([Localize(@"cart_note_placeholder") isEqualToString:@"Cart Note Placeholder"]) {
        [cartPlaceHolder setText:@""];
    } else {
        [cartPlaceHolder setText:Localize(@"cart_note_placeholder")];
    }
    [cartPlaceHolder setNumberOfLines:0];
    [cartPlaceHolder setLineBreakMode:NSLineBreakByWordWrapping];
    [cartPlaceHolder sizeToFitUI];
    [view addSubview:cartPlaceHolder];
    
    if (cartPlaceHolder.frame.size.height != 0) {
        itemPosY = self.view.frame.size.width * 0.02f + CGRectGetMaxY(cartPlaceHolder.frame);
    }
    
    
    UILabel* tempLabel = [[UILabel alloc] init];
    [tempLabel setText:@"W"];
    [tempLabel setUIFont:fontType isBold:false];
    [tempLabel sizeToFit];
    int fontW = tempLabel.frame.size.width;
    int fontH = tempLabel.frame.size.height;
    
    CGRect rectTextView;
    int noteLineCount = cartNote.note_line_count;
    BOOL noteSingleLine = cartNote.note_single_line;
    if (noteSingleLine) {
        float maxWidthCartPlaceHolder = textFieldWidth * .25f;
        if ([[MyDevice sharedManager] isIphone]) {
            maxWidthCartPlaceHolder = textFieldWidth * .25f;
        }
        if (maxWidthCartPlaceHolder < cartPlaceHolder.frame.size.width) {
            noteSingleLine = false;
        }else{
            textFieldPosX = CGRectGetMaxX(cartPlaceHolder.frame) + 5;
            itemPosY = CGRectGetMinY(cartPlaceHolder.frame);
            textFieldWidth = textFieldWidth - cartPlaceHolder.frame.size.width - 5;
        }
    }
    textFieldHeight = noteLineCount * fontH + 10;
    rectTextView = CGRectMake(textFieldPosX, itemPosY, textFieldWidth, textFieldHeight);
    switch (cartNote.note_char_type) {
        case CART_NOTE_CHAR_TYPE_ALPHANUMERIC:
            textView = [self createTextView:view fontType:fontType fontColorType:kUIColorFontDark frame:rectTextView tag:0 textStrPlaceHolder:Localize(@"cart_note_placeholder") textView:textView];
            [textView setKeyboardType:UIKeyboardTypeDefault];
            [textView setAutocapitalizationType:UITextAutocapitalizationTypeNone];
            break;
        case CART_NOTE_CHAR_TYPE_NUMERIC:
            textView = [self createTextView:view fontType:fontType fontColorType:kUIColorFontDark frame:rectTextView tag:0 textStrPlaceHolder:Localize(@"cart_note_placeholder") textView:textView];
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
-(void)resetCrosscellData{
    Addons* addons = [Addons sharedManager];
    if (addons.show_crosssell_products == true) {
        
        RLOG(@"**************   crossCell Product View  *************");
        
        crossCellIds = [[NSMutableArray alloc] init];
        for (NSObject* obj in [Cart getAll]) {
            Cart* cInfo = (Cart*)obj;
            if (cInfo.product._cross_sell_ids) {
                for (id csObj in cInfo.product._cross_sell_ids) {
                    RLOG(@"csObj %@",csObj);
                    [crossCellIds addObject:csObj];
                }
            }
        }
        if (crossCellIds !=nil) {
            //[self createVariousViews];
            RLOG(@"crossCellIds  %@",crossCellIds);
        }
                [_viewUserDefined[_kCrossSell] reloadData];
    }
}
#pragma mark TextView
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
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    _textViewFirstResponder = textView;
    return YES;
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    return YES;
}
- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([[Addons sharedManager] cartNote]){
        switch ([[[Addons sharedManager] cartNote] note_location]) {
            case CART_NOTE_LOCATION_AFTER_EACH_ITEM:
            {
                Cart* cartObj = [textView.layer valueForKey:@"MY_OBJECT"];
                if (cartObj) {
                    cartObj.note = textView.text;
                }
            }break;
            case CART_NOTE_LOCATION_BEFORE_PLACE_ORDER_BUTTON:
                [Cart setOrderNoteCart:textView.text];
                break;
            case CART_NOTE_LOCATION_BOTH:
            {
                Cart* cartObj = [textView.layer valueForKey:@"MY_OBJECT"];
                if (cartObj) {
                    cartObj.note = textView.text;
                }else {
                    [Cart setOrderNoteCart:textView.text];
                }
            }break;
                
            default:
                break;
        }
        
    }
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    CartNote* cartNote = [[Addons sharedManager] cartNote];
    if (cartNote.note_char_limit != -1) {
        return textView.text.length + (text.length - range.length) <= cartNote.note_char_limit;
    }
    return YES;
}


#pragma mark Reward Points
- (void)applyRewardDiscount:(UIButton*)button {
    _rewardPointsApplied = !_rewardPointsApplied;
    [self updateRewardDiscountView];
    
    
    
}
- (BOOL) rewardPointsCheck {
    return [[Addons sharedManager] enable_custom_points]
    && [AppUser isSignedIn]
    && [[[AppUser sharedManager] _cartArray] count] != 0;
}

- (void) loadCartRewardPoints {
    if (![self rewardPointsCheck]) {
        return;
    }
    
    NSMutableString* str = [[NSMutableString alloc] init];
    NSArray* carts = [[AppUser sharedManager] _cartArray];
    int i = 0;
    for(Cart* cart in carts) {
        [str appendString:@"{"];
        [str appendFormat:@"\"prod_id\":%d", cart.product_id];
        if(cart.selectedVariationId != -1) {
            [str appendFormat:@",\"var_ids\":[%d]", cart.selectedVariationId];
        }
        [str appendString:@"}"];
        if (i < carts.count - 1) {
            [str appendString:@","];
        }
        i++;
    }
    
    NSString* prodData = [NSString stringWithFormat:@"[%@]", str];
    
    NSDictionary* params = @{@"type": base64_str(@"poll_reward_data"),
                             @"prod_data": base64_str(prodData),
                             @"email_id": base64_str([[AppUser sharedManager] _email]),
                             @"user_id": base64_int([[AppUser sharedManager] _id])};
    
    [Utility showProgressView:Localize(@"please_wait")];
    [[DataManager getDataDoctor] getCartProductsRewardPoints:params
                                                     success:^(id data) {
                                                         //showCartRewardPoints();
                                                         [Utility hideProgressView];
                                                         [self updateRewardDiscountView];
                                                     }
                                                     failure:^(NSString *error) {
                                                         [Utility hideProgressView];
                                                         //pointsSection.setVisibility(View.GONE);
                                                     }];
}

- (int) getTotalRewardPoints {
    int totalPoints = 0;
    for (Cart* cart in [[AppUser sharedManager] _cartArray]) {
        if (cart.product != nil) {
            int rewardPoints = [cart.product getRewardPoints:cart.selectedVariationId];
            if (rewardPoints > 0.0f) {
                totalPoints += rewardPoints * cart.count;
            }
        }
    }
    return totalPoints;
}

- (void)passCouponCode:(NSString*)couponCodeStr {
    AppDelegate* appD = (AppDelegate*)[UIApplication sharedApplication].delegate;
    appD.nJsonData_couponCode = couponCodeStr;

//    _userSelectedCouponCode = couponCodeStr;
//    _textFieldApplyCoupon.text = couponCodeStr;
//    [self applyCoupon:nil];
    [self cartPageDataLoaded:nil];
}
- (void)addButtonClicked:(UIButton*)button {
    [[Utility sharedManager] addButtonClicked:button];
}
- (void)substractButtonClicked:(UIButton*)button {
    [[Utility sharedManager] substractButtonClicked:button];
}
@end
