//
//  ViewControllerCheckout.m
//  eMobileApp
//
//  Created by Rishabh Jain on 25/11/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import "ViewControllerCheckout.h"
#import "AppUser.h"
#import "Attribute.h"
#import "Order.h"
#import "DataManager.h"
#import "CommonInfo.h"
#import "Cart.h"
#import "ViewControllerOrderReceipt.h"
#import "LoginFlow.h"
#import "AnalyticsHelper.h"


static int kTagForGlobalSpacing = 0;
static int kTagForNoSpacing = -1;
enum WVC_STATE{
    WVC_STATE_NONE,
    WVC_STATE_EXT,
    WVC_STATE_INIT,
    WVC_STATE_LOGIN,
    WVC_STATE_CART_SYNC,
    WVC_STATE_CHECKOUT_INIT,
    WVC_STATE_CHECKOUT_ADDRESS,
    WVC_STATE_CHECKOUT,
    WVC_STATE_END
};
@implementation NSObject (SEWebviewJSListenerNew)

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSString *requestString = [[[request URL] absoluteString] stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    RLOG(@"requestString = %@", requestString);
    
    NSArray *requestArray = [requestString componentsSeparatedByString:@":##sendToApp##"];
    if ([requestArray count] > 1){
        NSString *requestPrefix = [[requestArray objectAtIndex:0] lowercaseString];
        NSString *requestMssg = ([requestArray count] > 0) ? [requestArray objectAtIndex:1] : @"";
        [self webviewMessageKey:requestPrefix value:requestMssg];
        return NO;
    } else if (navigationType == UIWebViewNavigationTypeLinkClicked && [self shouldOpenLinksExternally]) {
        // open links in safari
        RLOG(@"open links in safari");
        [[UIApplication sharedApplication] openURL:[request URL]];
        return NO;
    }
    return YES;
}

- (void)webviewMessageKey:(NSString *)key value:(NSString *)val {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    RLOG(@"key=%@,val=%@", key, val);
}

- (BOOL)shouldOpenLinksExternally {
    return YES;
}

@end



@interface ViewControllerCheckout (SEWebviewJSListenerNew)

@end


@implementation ViewControllerCheckout
- (BOOL)shouldOpenLinksExternally {
    return NO;
}
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
    _customBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_customBackButton setImage:[[UIImage imageNamed:@"img_arrow_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [_customBackButton addTarget:self action:@selector(barButtonBackPressed:)forControlEvents:UIControlEventTouchUpInside];
    [_customBackButton setTitle:[NSString stringWithFormat:@"  %@  ", Localize(@"i_back")] forState:UIControlStateNormal];
    [_customBackButton setTintColor:[Utility getUIColor:kUIColorThemeFont]];
    [_customBackButton setTitleColor:[Utility getUIColor:kUIColorThemeFont] forState:UIControlStateNormal];
    [_customBackButton.titleLabel setUIFont:kUIFontType18 isBold:false];
    [_customBackButton sizeToFit];
    [_previousItemHeading setCustomView:_customBackButton];
    [_previousItemHeading setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[Utility getUIColor:kUIColorThemeFont], NSForegroundColorAttributeName, [Utility getUIFont:kUIFontType18 isBold:false], NSFontAttributeName, nil] forState:UIControlStateNormal];
    
    
    [self initVariables];
    //    [[[[DataManager sharedManager] tmDataDoctor] tmMulticastDelegate] addDelegate:self];
    //    [[[DataManager sharedManager] tmMulticastDelegate] addDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)viewWillAppear:(BOOL)animated {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super viewWillAppear:animated];
    [[[[DataManager sharedManager] tmDataDoctor] tmMulticastDelegate] addDelegate:self];
}
- (void)viewWillDisappear:(BOOL)animated {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super viewWillAppear:animated];
    [[[[DataManager sharedManager] tmDataDoctor] tmMulticastDelegate] removeDelegate:self];
}
-(void)viewDidAppear:(BOOL)animated{
#if ENABLE_FIREBASE_TAG_MANAGER
    [[AnalyticsHelper sharedInstance] registerVisitScreenEvent:@"Checkout Screen"];
#endif
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
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[Utility sharedManager] popScreen:self];
    ViewControllerMain* mainVC = [ViewControllerMain getInstance];
    [mainVC resetPreviousState];
    [mainVC btnClickedHome:self];
}
- (void)initVariables {
    _viewsAdded = [[NSMutableArray alloc] init];
    //    [_scrollView setBackgroundColor:[Utility getUIColor:kUIColorBgTheme]];
    //    [self.view setBackgroundColor:[Utility getUIColor:kUIColorBgHeader]];
    //    [_lineView setBackgroundColor:[Utility getUIColor:kUIColorBorder]];
    
    [_labelViewHeading setText:@""];
    
    _webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        _webView.transform = CGAffineTransformMakeScale(-1, 1);
    }
    [_webView setDelegate:self];
    [_scrollView addSubview:_webView];
    [_viewsAdded addObject:_webView];
    
    _webViewState = WVC_STATE_NONE;
    
}

- (void)loadAllViews:(NSString*)linkStr {
    _linkStr = linkStr;
    _webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    [_webView setDelegate:self];
    [_scrollView addSubview:_webView];
    [_viewsAdded addObject:_webView];
    [self loadWebView];
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
                [self loadAllViews:_linkStr];
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
    //    [self beforeRotation];
}
- (void)adjustViewsAfterOrientation:(UIDeviceOrientation) orientation {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    RLOG(@"====adjustViewsAfterOrientation====");
    //    [self afterRotation];
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
#pragma mark - Webview
- (void)loadWebView {
//    [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
//    [MRProgressOverlayView showOverlayAddedTo:[[UIApplication sharedApplication] keyWindow] title:@"" mode:MRProgressOverlayViewModeIndeterminateSmallDefault animated:YES];
    UIActivityIndicatorView* act = [[Utility sharedManager] startGrayLoadingBar:true];
    act.center = self.view.center;
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:_linkStr]];
    [_webView setDelegate:self];
    [_webView loadRequest:urlRequest];
}
/*
 public void signInWebViewUsingHidden(final String str_email, final LoginListener loginListener) {
 
 Helper.SOUT("-- signInWebViewUsingHidden: [" + str_email + "] --");
 
 webinterface.setWebResponseListener(new WebAppInterface.WebResponseListener() {
 @Override
 public void onResponseReceived(int resultCode, String response) {
 Helper.SOUT("== MainActivity::onResponseReceived [" + resultCode + "][" + response + "] ==");
 if (response.contains("Login Successful")) {
 //hideProgress(true);
 //mWebView.setVisibility(View.GONE);
 Helper.SOUT("-- MainActivity|signInWebViewUsingHidden|setWebResponseListener::onResponseReceived [Login Successful] --");
 if (loginListener != null) {
 loginListener.onLoginSuccess();
 }
 } else {
 hideProgress(false);
 Helper.SOUT("-- MainActivity|signInWebViewUsingHidden|setWebResponseListener::onResponseReceived [Login Failed] --");
 if (loginListener != null) {
 loginListener.onLoginFailed("Web SignIn Failed!");
 }
 }
 }
 });
 
 File dir = getCacheDir();
 if (!dir.exists()) {
 dir.mkdirs();
 }
 
 showProgress("Updating session..");
 String urlToCall = TMDataDoctor.getDataEngine().external_login_url;
 String postData = "user_platform=Android&user_emailID=" + str_email;
 Helper.SOUT("-- postData: [" + urlToCall + "?" + postData + "] --");
 mWebView.postUrl(urlToCall, EncodingUtils.getBytes(postData, "BASE64"));
 }
 */
- (void)webViewDidStartLoad:(UIWebView *)webView {
    UIActivityIndicatorView* act = [[Utility sharedManager] startGrayLoadingBar:true];
    act.center = self.view.center;
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
    [[Utility sharedManager] stopGrayLoadingBar];
    if(webView.request){
        RLOG(@"webView.request = %@", webView.request);
    }
    switch ([webView tag]) {
        case WVC_STATE_EXT:
        {
            
        } break;
        default:
        {
            
        } break;
    }
}
- (void)webViewDidFinishLoadOld:(UIWebView *)webView {
    [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
    [[Utility sharedManager] stopGrayLoadingBar];
    if(webView.request){
        RLOG(@"webView.request = %@", webView.request);
    }
    
    switch ([webView tag]) {
        case WVC_STATE_EXT:
        {
            _webViewState = WVC_STATE_INIT;
            [_webView setTag:WVC_STATE_INIT];
            _linkStr = [[[DataManager sharedManager] tmDataDoctor] loginPageLink];
            [self loadWebView];
            
            
            
            
        } break;
        case WVC_STATE_CART_SYNC:
            [self loadCartData];
            break;
        case WVC_STATE_CHECKOUT_INIT:
            [self fillAddressCheckoutPage];
            break;
        case WVC_STATE_CHECKOUT_ADDRESS:
            _webViewState = WVC_STATE_CHECKOUT;
            [_webView setTag:WVC_STATE_CHECKOUT];
            break;
        default:
            break;
    }
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
    [[Utility sharedManager] stopGrayLoadingBar];
}
//- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
//    return YES;
//}


- (void)externalLoginView {
    
    
}
- (void)loadLoginView {
    _webViewState = WVC_STATE_EXT;
    [_webView setTag:WVC_STATE_EXT];
    _linkStr = [[[DataManager sharedManager] tmDataDoctor] external_login_url];
    [self loadWebView];
}
- (void)loadLoginViewHidden {
    _webViewState = WVC_STATE_EXT;
    [_webView setTag:WVC_STATE_EXT];
    _linkStr = [[[DataManager sharedManager] tmDataDoctor] external_login_url_hidden];
    AppUser* au = [AppUser sharedManager];
//    [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
//    [MRProgressOverlayView showOverlayAddedTo:[[UIApplication sharedApplication] keyWindow] title:@"" mode:MRProgressOverlayViewModeIndeterminateSmallDefault animated:YES];
    UIActivityIndicatorView* act = [[Utility sharedManager] startGrayLoadingBar:true];
    act.center = self.view.center;
    NSURL *url = [NSURL URLWithString: _linkStr];
    NSString *body = [NSString stringWithFormat:@"user_platform=IOS&user_emailID=%@", au._email];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    [_webView loadRequest:request];
}
- (void)startTimer {
    [self performSelector:@selector(initCartDataUploading) withObject:nil afterDelay:120.0f];
}
- (void)initCartDataUploading {
    return;
    _webViewState = WVC_STATE_CART_SYNC;
    [_webView setTag:WVC_STATE_CART_SYNC];
    _cartItems = [[NSMutableArray alloc] initWithArray:[Cart getAll]];
    [self loadCartData];
}
- (void)loadCartData {
    if ([_cartItems count] > 0) {
        Cart* cartItem = [_cartItems objectAtIndex:0];
        NSString* cartUrl = [NSString stringWithFormat:@"%@?add-to-cart=%d&quantity=%d",[[[DataManager sharedManager] tmDataDoctor] cart_url], cartItem.product_id, cartItem.count];
        if(cartItem.selectedVariationId != -1) {
            cartUrl = [NSString stringWithFormat:@"%@&variation_id=%d", cartUrl, cartItem.selectedVariationId];
            Variation* variation = [cartItem.product._variations getVariation:cartItem.selectedVariationId variationIndex:cartItem.selectedVariationIndex];
            for (VariationAttribute* attribute in variation._attributes) {
                cartUrl = [NSString stringWithFormat:@"%@&attribute_pa_%@=%@&attribute_%@=%@", cartUrl, attribute.name, attribute.value , attribute.name, attribute.value];
            }
        }
        RLOG(@"CART_URL=\n%@", cartUrl);
        _linkStr = cartUrl;
        [_cartItems removeObject:cartItem];
        [self loadWebView];
        //        [self startCartDataTimer];
    }else{
        [self goForCheckoutPage];
    }
}
- (void)startCartDataTimer {
    [self performSelector:@selector(loadCartData) withObject:nil afterDelay:60.0f];
}
- (void)goForCheckoutPage {
    //    [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
    //    [MRProgressOverlayView showOverlayAddedTo:[[UIApplication sharedApplication] keyWindow] title:@"" mode:MRProgressOverlayViewModeIndeterminateSmallDefault animated:YES];
    _webViewState = WVC_STATE_CHECKOUT_INIT;
    [_webView setTag:WVC_STATE_CHECKOUT_INIT];
    
    if ([[[DataManager sharedManager] checkoutUrlLinkFromPlugin] isEqualToString:@""]) {
        _linkStr = [[[DataManager sharedManager] tmDataDoctor] checkout_url];
    } else {
        _linkStr = [[DataManager sharedManager] checkoutUrlLinkFromPlugin];
    }
    
    [self loadWebView];
}
- (void)fillAddressCheckoutPage{
    _webViewState = WVC_STATE_CHECKOUT_ADDRESS;
    [_webView setTag:WVC_STATE_CHECKOUT_ADDRESS];
    
    RLOG(@"%s", __PRETTY_FUNCTION__);
    AppUser* au = [AppUser sharedManager];
    Address* address = au._billing_address;
    NSString* string =  [NSString stringWithFormat:@"\
                         javascript:document.getElementById('billing_first_name').value = '%@';\
                         javascript:document.getElementById('billing_last_name').value = '%@';\
                         javascript:document.getElementById('billing_company').value = '%@';\
                         javascript:document.getElementById('billing_email').value = '%@';\
                         javascript:document.getElementById('billing_phone').value = '%@';\
                         javascript:document.getElementById('billing_country').value = '%@';\
                         javascript:document.getElementById('billing_address_1').value = '%@';\
                         javascript:document.getElementById('billing_address_2').value = '%@';\
                         javascript:document.getElementById('billing_city').value = '%@';\
                         javascript:document.getElementById('billing_state').value = '%@';\
                         javascript:document.getElementById('billing_postcode').value = '%@';\
                         javascript:document.getElementById('wp-save_address')[0].click();\
                         ",
                         address._first_name,
                         address._last_name,
                         address._company,
                         address._email,
                         address._phone,
                         address._country,
                         address._address_1,
                         address._address_2,
                         address._city,
                         address._state,
                         address._postcode
                         ];
    _linkStr = string;
    //    [self loadWebView];
    [_webView stringByEvaluatingJavaScriptFromString:_linkStr];
}
- (void)webviewMessageKey:(NSString *)key value:(NSString *)val{
    RLOG(@"%s", __PRETTY_FUNCTION__);
    RLOG(@"key=%@,val=%@", key, val);
    if ([key isEqualToString:@"login"]) {
        if ([Utility containsString:val substring:@"Successful"]){
            //            [self initCartDataUploading];
            [self goForCheckoutPage];
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Localize(@"login_failed")
                                                            message:Localize(@"password_incorrect")
                                                           delegate:self
                                                  cancelButtonTitle:Localize(@"i_cok")
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
    
    if ([key isEqualToString:@"purchase"]) {
        
        NSString *valMain = [NSString stringWithFormat:@"%@", val];
        NSArray *componentsMain = [valMain componentsSeparatedByString: @","];
        
        NSString *orderId = @"";
        NSString *orderStatus = @"";
        for (NSString *valSub in componentsMain) {
            NSArray *componentsSub = [valSub componentsSeparatedByString: @":"];
            if ([(NSString*)[componentsSub objectAtIndex:0] isEqualToString:@"orderid"]) {
                if ((int)[componentsSub count] > 0) {
                    orderId = (NSString*) [componentsSub objectAtIndex:1];
                }
            }
            if ([(NSString*)[componentsSub objectAtIndex:0] isEqualToString:@"orderstatus"]) {
                if ((int)[componentsSub count] > 0) {
                    orderStatus = (NSString*) [componentsSub objectAtIndex:1];
                }
            }
        }
        NSString* msg = @"";
        if ([orderId isEqualToString:@""]) {
            msg = [NSString stringWithFormat:@"%@", orderStatus];
        }else{
            msg = [NSString stringWithFormat:@"%@ \n Order Id is %@", orderStatus, orderId];
            [Cart removeAllProduct];
            [self orderPurchasedSuccessful];
            //            AppUser* appUser = [AppUser sharedManager];
            //            [[DataManager sharedManager] fetchCustomerData:nil userEmail:appUser._email];
        }
        
        //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Order Status"
        //                                                        message:msg
        //                                                       delegate:self
        //                                              cancelButtonTitle:@"OK"
        //                                              otherButtonTitles:nil];
        //        [alert show];
    }
}
//-(void)dataFetchCompletion:(ServerData *)serverData{
//    if (serverData._serverRequestStatus == kServerRequestSucceed) {
//        RLOG(@"=======DATA_FETCHING:SUCCESS=======");
//        RLOG(@"_serverUrl = %@",serverData._serverUrl);
//        RLOG(@"_serverDataId = %d",serverData._serverDataId);
//        //        RLOG(@"_serverRequestName = %@",serverData._serverRequestName);
//        RLOG(@"_serverResultDictionary = %@",serverData._serverResultDictionary);
//        NSError *error;
//        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:serverData._serverResultDictionary
//                                                           options:NSJSONWritingPrettyPrinted
//                                                             error:&error];
//        if (! jsonData) {
//            RLOG(@"Got an error: %@", error);
//        } else {
//            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//            [[NSUserDefaults standardUserDefaults] setObject:jsonString forKey:serverData._serverUrl];
//        }
//
//        switch (serverData._serverDataId) {
//            case kFetchCustomer:
//            {
//                [[DataManager sharedManager] loadCustomerData:serverData._serverResultDictionary];
//            }break;
//            case kFetchOrders:
//            {
//                [[DataManager sharedManager] loadOrdersData:serverData._serverResultDictionary];
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"ProceedToOrderScreen" object:self];
//            } break;
//            default:
//                break;
//        }
//    }
//}
- (void)orderPurchasedSuccessful {
    [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
    [MRProgressOverlayView showOverlayAddedTo:[[UIApplication sharedApplication] keyWindow] title:@"" mode:MRProgressOverlayViewModeIndeterminateSmallDefault animated:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:@"ProceedToOrderScreen" object:nil];
    
    //    [[LoginFlow sharedManager] relogIn];
    AppUser* appUser = [AppUser sharedManager];
    [[DataManager sharedManager] fetchCustomerData:nil userEmail:appUser._email];
}
- (void)receiveNotification:(NSNotification *)notification
{
    AppUser* appUser = [AppUser sharedManager];
    [appUser._cartArray removeAllObjects];
    [appUser saveData];
    [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
    [[Utility sharedManager] stopGrayLoadingBar];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ProceedToOrderScreen" object:nil];
    if ([[notification name] isEqualToString:@"ProceedToOrderScreen"]){
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
}
-(void)dataFetchCompletion:(ServerData *)serverData{
    if (serverData._serverRequestStatus == kServerRequestSucceed) {
        RLOG(@"=======DATA_FETCHING:SUCCESS=======");
        RLOG(@"_serverUrl = %@",serverData._serverUrl);
        RLOG(@"_serverDataId = %d",serverData._serverDataId);
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
    else if (serverData._serverRequestStatus == kServerRequestFailed) {
        switch (serverData._serverDataId) {
            case kFetchCustomer:
            {
                AppUser* au = [AppUser sharedManager];
                [[DataManager sharedManager] fetchCustomerData:nil userEmail:au._email];
            }break;
                
            case kFetchOrders:
            {
                [[DataManager sharedManager] fetchOrdersData:nil];
            }break;
                
            default:
            { }break;
        }
    }
    
    
    if (serverData._serverRequestStatus == kServerRequestSucceed) {
        switch (serverData._serverDataId) {
            case kFetchCustomer:
            {
                [[DataManager sharedManager] loadCustomerData:serverData._serverResultDictionary];
            }break;
            case kFetchOrders:
            {
                [[DataManager sharedManager] loadOrdersData:serverData._serverResultDictionary];
                [[[[DataManager sharedManager] tmDataDoctor] tmMulticastDelegate] removeDelegate:self];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ProceedToOrderScreen" object:self];
            }break;
            default:
            {
                
            }break;
        }
    }
    
}
@end
