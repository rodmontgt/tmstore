//
//  PaystackViewController.h
//  testapp
//
//  Created by Rishabh Jain on 18/05/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TMPaymentSDK.h"

#if ENABLE_PAYSTACK
#import <Paystack/Paystack.h>
typedef NS_ENUM(NSInteger, PSTCKBackendChargeResult) {
    PSTCKBackendChargeResultSuccess,
    PSTCKBackendChargeResultFailure,
};

typedef void (^PSTCKTokenSubmissionHandler)(PSTCKBackendChargeResult status, NSError *error);

@protocol PSTCKBackendCharging <NSObject>

- (void)createBackendChargeWithToken:(PSTCKToken *)token completion:(PSTCKTokenSubmissionHandler)completion;

@end

@class PaystackViewController;

@protocol PaystackViewControllerDelegate<NSObject>

- (void)paystackPaymentViewController:(PaystackViewController *)controller didFinish:(NSError *)error;

@end

@interface PaystackViewController : UIViewController

@property (nonatomic) NSDecimalNumber *amount;
@property (nonatomic, weak) id<PaystackViewControllerDelegate> delegate;
@property (nonatomic, weak) id responseDelegate;
@end
#else
@interface PaystackViewController : UIViewController
@end
#endif