//
//  SPViewController.h
//  TMPaymentSDK
//
//  Created by Rishabh Jain on 29/06/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Stripe/Stripe.h>
#import "TMPaymentSDK.h"

typedef NS_ENUM(NSInteger, STPBackendChargeResult) {
    STPBackendChargeResultSuccess,
    STPBackendChargeResultFailure,
};

typedef void (^STPTokenSubmissionHandler)(STPBackendChargeResult status, NSError *error);

@protocol STPBackendCharging <NSObject>
- (void)createBackendChargeWithToken:(STPToken *)token completion:(STPTokenSubmissionHandler)completion;
@end

@class SPViewController;

@protocol StripePaymentViewControllerDelegate<NSObject>
- (void)stripePaymentViewController:(SPViewController *)controller didFinish:(NSError *)error;
@end


@interface SPViewController : UIViewController
@property (nonatomic) NSDecimalNumber *amount;
@property (nonatomic, weak) id<StripePaymentViewControllerDelegate> delegate;
@property (nonatomic, weak) id responseDelegate;
@property (weak, nonatomic) IBOutlet UILabel *label_name;
@property (weak, nonatomic) IBOutlet UILabel *label_number;
@property (weak, nonatomic) IBOutlet UILabel *label_date;
@property (weak, nonatomic) IBOutlet UILabel *label_cvv;
@property (weak, nonatomic) IBOutlet UILabel *label_zip;
@property (weak, nonatomic) IBOutlet UITextField *textfield_name;
@property (weak, nonatomic) IBOutlet UITextField *textfield_number;
@property (weak, nonatomic) IBOutlet UITextField *textfield_date;
@property (weak, nonatomic) IBOutlet UITextField *textfield_cvv;
@property (weak, nonatomic) IBOutlet UITextField *textfield_zip;
@property (weak, nonatomic) IBOutlet UIButton *button_pay;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *label_name_top_constraint;
- (IBAction)buttonPayClicked:(id)sender;
- (id)initWithDelegate:(id)delegate;
@end
