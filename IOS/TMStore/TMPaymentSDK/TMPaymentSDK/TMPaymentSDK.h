//
//  TMPaymentSDK.h
//  TMPaymentSDK
//
//  Created by Rishabh Jain on 04/04/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMPaymentVariables.h"
#import "TMPaymentGateway.h"
//#import "TMShippingMethod.h"


#if ENABLE_STRIPE
#import <Stripe/Stripe.h>
#endif


#if ENABLE_PAYSTACK
//#import <Paystack/Paystack.h>
#endif


#if ENABLE_APPLE_PAY_VIA_STRIPE
#import <PassKit/PassKit.h>
#import <Stripe/Stripe.h>
#endif

@interface TMPaymentSDKDelegate : NSObject
- (void)setDelegate:(id)delegate;
- (void)addDelegate:(id)delegate;
- (void)removeDelegate:(id)delegate;
- (void)removeAllDelegates;
- (NSHashTable *)delegates;
- (BOOL)hasDelegate:(id)newDelegate;
- (void)postCompletionCallbackWithSuccess:(id)obj;
- (void)postCompletionCallbackWithFailure:(id)obj;
@end

@protocol TMPaymentSDKDelegate <NSObject>
- (void)paymentCompletionWithSuccess:(id)obj;
- (void)paymentCompletionWithFailure:(id)obj;
@end

@interface TMPaymentSDK : NSObject
@property NSMutableArray* paymentGateways;//Array of TMPaymentGateway
//@property NSMutableArray* shippingMethods;//Array of TMShippingMethod
//@property NSString* shippingMethodChoosedId;
//@property BOOL shippingEnable;
@property TMPaymentSDKDelegate* paymentDelegate;
- (id)init;
- (void)addPaymentGateway:(TMPaymentGateway*)obj;
//- (void)addShippingMethod:(TMShippingMethod*)obj;
- (void)resetPaymentGateways;
//- (void)resetShippingMethods;

@end


@interface PaymentUtility : NSObject
+ (UIActivityIndicatorView*)startGrayLoadingBar:(BOOL)willRotate;
+ (void)stopGrayLoadingBar;
+ (id)sharedManager;
@end


