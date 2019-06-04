//
//  StripePaymentViewController.h
//  Stripe
//
//  Created by Alex MacCaw on 3/4/13.
//
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

@class StripePaymentViewController;

@protocol StripePaymentViewControllerDelegate<NSObject>

- (void)stripePaymentViewController:(StripePaymentViewController *)controller didFinish:(NSError *)error;

@end

@interface StripePaymentViewController : UIViewController

@property (nonatomic) NSDecimalNumber *amount;
@property (nonatomic, weak) id<StripePaymentViewControllerDelegate> delegate;
@property (nonatomic, weak) id responseDelegate;




@property (unsafe_unretained, nonatomic) IBOutlet UILabel *label_name;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *textfield_name;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *label_number;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *textfield_number;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *label_date;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *textfield_date;
@property (unsafe_unretained, nonatomic) IBOutlet UIDatePicker *datepicker;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *label_cvv;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *textfield_cvv;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *label_zip;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *textfield_zip;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *button_pay;
@property (unsafe_unretained, nonatomic) IBOutlet UIStackView *sview_name;
@property (unsafe_unretained, nonatomic) IBOutlet UIStackView *sview_number;
@property (unsafe_unretained, nonatomic) IBOutlet UIStackView *sview_date;
@property (unsafe_unretained, nonatomic) IBOutlet UIStackView *sview_cvv;
@property (unsafe_unretained, nonatomic) IBOutlet UIStackView *sview_zip;
@end
