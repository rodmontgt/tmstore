//
//  TMPaymentSDK.m
//  TMPaymentSDK
//
//  Created by Rishabh Jain on 04/04/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import "TMPaymentSDK.h"

#if ENABLE_PAYPAL
#import "PayPalMobile.h"
#endif
#if ENABLE_STRIPE
//#import "StripePaymentViewController.h"
#import "SPViewController.h"
#endif
#if ENABLE_PAYSTACK
//#import "PaystackViewController.h"
#endif


static UIActivityIndicatorView* spinnerView = nil;
@implementation PaymentUtility
+ (id)sharedManager {
    static PaymentUtility *shareUtilitydManager = nil;
    @synchronized(self) {
        if (shareUtilitydManager == nil)
            shareUtilitydManager = [[self alloc] init];
    }
    return shareUtilitydManager;
}
- (id)init {
    if (self = [super init]) {
    }
    return self;
}
+ (UIActivityIndicatorView*)startGrayLoadingBar:(BOOL)willRotate {
    if (spinnerView == nil) {
        spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [spinnerView startAnimating];
    }
    [spinnerView removeFromSuperview];
    [[[UIApplication sharedApplication] keyWindow] addSubview:spinnerView];
    [spinnerView setFrame:CGRectMake(
                                     0,
                                     0,
                                     spinnerView.frame.size.width,
                                     spinnerView.frame.size.height)];
    CGRect frame = [[UIApplication sharedApplication] keyWindow].frame;
    spinnerView.center = CGPointMake(frame.size.width/2, frame.size.height/2);
    if (willRotate) {
        spinnerView.center = CGPointMake(frame.size.height/2, frame.size.width/2);
    }
    return spinnerView;
}
+ (void)stopGrayLoadingBar {
    [spinnerView removeFromSuperview];
}
@end


@implementation TMPaymentSDK
- (id)init {
    self = [super init];
    if (self) {
        PLOG(@"TMPaymentSDK INIT");
        _paymentGateways = [[NSMutableArray alloc] init];
//        _shippingMethods = [[NSMutableArray alloc] init];
        _paymentDelegate = [[TMPaymentSDKDelegate alloc] init];
//        _shippingMethodChoosedId = @"";
//        _shippingEnable = false;
    }
    return self;
}
- (void)resetPaymentGateways {
    [_paymentGateways removeAllObjects];
    PLOG(@"PaymentGateways reset.");
}
//- (void)resetShippingMethods {
//    [_shippingMethods removeAllObjects];
//    PLOG(@"ShippingMethods reset.");
//}
- (void)addPaymentGateway:(TMPaymentGateway*)obj {
    [_paymentGateways addObject:obj];
    [obj setSdkObj:self];
    PLOG(@"PaymentGateway added.");
}
//- (void)addShippingMethod:(TMShippingMethod*)obj {
//    [_shippingMethods addObject:obj];
//    PLOG(@"ShippingMethod added.");
//}
@end



@interface TMPaymentSDKDelegate()
< NSCacheDelegate
#if ENABLE_PAYPAL
, PayPalPaymentDelegate
#endif

#if ENABLE_STRIPE
, StripePaymentViewControllerDelegate
#endif

#if ENABLE_PAYSTACK
//, PaystackViewControllerDelegate
#endif

#if ENABLE_APPLE_PAY_VIA_STRIPE
, PKPaymentAuthorizationViewControllerDelegate
#endif


>
{
    NSHashTable* _delegates;
}
@end


@implementation TMPaymentSDKDelegate

- (id)init {
    if (self = [super init]) {
        _delegates = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    }
    return self;
}
- (void)setDelegate:(id)delegate {
    [_delegates removeAllObjects];
    [_delegates addObject:delegate];
}
- (void)addDelegate:(id)delegate {
    [_delegates addObject:delegate];
}
- (void)removeDelegate:(id)delegate {
    [_delegates removeObject:delegate];
}
- (void)removeAllDelegates {
    [_delegates removeAllObjects];
}
- (NSHashTable *)delegates {
    return _delegates;
}
- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([super respondsToSelector:aSelector]) {
        return YES;
    }
    // if any of the delegates respond to this selector, return YES
    for(id delegate in _delegates) {
        if ([delegate respondsToSelector:aSelector]) {
            return YES;
        }
    }
    return NO;
}
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    // can this class create the signature?
    NSMethodSignature* signature = [super methodSignatureForSelector:aSelector];
    // if not, try our delegates
    if (!signature) {
        for(id delegate in _delegates) {
            if ([delegate respondsToSelector:aSelector]) {
                return [delegate methodSignatureForSelector:aSelector];
            }
        }
    }
    return signature;
}
- (void)forwardInvocation:(NSInvocation *)anInvocation {
    // forward the invocation to every delegate
    for(id delegate in _delegates) {
        if ([delegate respondsToSelector:[anInvocation selector]]) {
            [anInvocation invokeWithTarget:delegate];
        }
    }
}
- (BOOL)hasDelegate:(id)newDelegate {
    for(id delegate in _delegates) {
        if (delegate == newDelegate) {
            return true;
        }
    }
    return false;
}
- (void)postCompletionCallbackWithSuccess:(id)obj {
    [PaymentUtility stopGrayLoadingBar];
    for(id delegate in _delegates) {
        NSLog(@"postCompletionCallbackWithSuccess delegate=%@, obj=%@, delegatesCount = %d", delegate, obj, (int)[_delegates count]);
        [delegate paymentCompletionWithSuccess:obj];
    }
}
- (void)postCompletionCallbackWithFailure:(id)obj {
    [PaymentUtility stopGrayLoadingBar];
    for(id delegate in _delegates) {
        NSLog(@"postCompletionCallbackWithFailure delegate=%@, obj=%@, delegatesCount = %d", delegate, obj, (int)[_delegates count]);
        [delegate paymentCompletionWithFailure:obj];
    }
}

#pragma mark PAYPAL
#if ENABLE_PAYPAL
- (void)payPalPaymentViewController:(PayPalPaymentViewController *)paymentViewController didCompletePayment:(PayPalPayment *)completedPayment {
    PLOG(@"PayPal Payment Success!");
    [paymentViewController dismissViewControllerAnimated:YES completion:^{
        [self postCompletionCallbackWithSuccess:nil];
    }];
}
- (void)payPalPaymentDidCancel:(PayPalPaymentViewController *)paymentViewController {
    PLOG(@"PayPal Payment Canceled");
    [paymentViewController dismissViewControllerAnimated:YES completion:^{
        [self postCompletionCallbackWithFailure:nil];
    }];
}
#endif



#pragma mark APPLE PAY Via Stripe
#if ENABLE_APPLE_PAY_VIA_STRIPE
- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller{
    [controller dismissViewControllerAnimated:YES completion:^{
        //        if (self.paymentSucceeded) {
        //            [self showReceiptPage];
        //        }
        [self postCompletionCallbackWithFailure:nil];
    }];
}

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller didAuthorizePayment:(PKPayment *)payment completion:(void (^)(PKPaymentAuthorizationStatus))completion {
    [[STPAPIClient sharedClient] createTokenWithPayment:payment completion:^(STPToken * _Nullable token, NSError * _Nullable error) {
        //NSLog(@"Token %@", token);
        if (token == nil) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"%@", [error localizedDescription]] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            [controller dismissViewControllerAnimated:YES completion:^{
                [self postCompletionCallbackWithFailure:nil];
            }];
            return;
        }
        ApplePayViaStripeConfig* configApplePayViaStripe = [ApplePayViaStripeConfig sharedManager];
        float currencyAmount = configApplePayViaStripe.infoTotalAmount;
        NSString* infoCurrencyCode = [NSString stringWithFormat:@"%@", configApplePayViaStripe.infoCurrency];
        NSString* infoDescription = [NSString stringWithFormat:@"%@", configApplePayViaStripe.infoDescription];
        NSString* infoCountryCode = [NSString stringWithFormat:@"%@", configApplePayViaStripe.infoCountry];
        
        // This passes the token off to our payment backend, which will then actually complete charging the card using your Stripe account's secret key
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        config.requestCachePolicy =NSURLRequestReloadIgnoringLocalCacheData;
        NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
        NSURL *url = [NSURL URLWithString:configApplePayViaStripe.cBackendChargeURLString];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        request.HTTPMethod = @"POST";
        NSString *postBody = [NSString stringWithFormat:@"stripeToken=%@&amount=%@&apikey=%@&currency=%@&description=%@", token.tokenId, [NSNumber numberWithFloat:currencyAmount/* * 100.0f */], configApplePayViaStripe.cStripeSecretKey, infoCurrencyCode, infoDescription];
        NSData *data = [postBody dataUsingEncoding:NSUTF8StringEncoding];
        
        NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request fromData:data completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            NSString* newStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            //NSLog(@"newStr= %@" ,newStr);
            if (error == nil) {
                if ([newStr isEqualToString:@"SUCCESS"]) {
                    //NSLog(@"SUCCESS");
                    [controller dismissViewControllerAnimated:YES completion:^{
                        [self postCompletionCallbackWithSuccess:nil];
                    }];
                } else {
                    //NSLog(@"FAILED");
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"%@", newStr] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alert show];
                    [controller dismissViewControllerAnimated:YES completion:^{
                        [self postCompletionCallbackWithFailure:nil];
                    }];
                }
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"%@", [error localizedDescription]] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                [controller dismissViewControllerAnimated:YES completion:^{
                    [self postCompletionCallbackWithFailure:nil];
                }];
            }
        }];
        [uploadTask resume];
        
    }];
}
#endif

@end
