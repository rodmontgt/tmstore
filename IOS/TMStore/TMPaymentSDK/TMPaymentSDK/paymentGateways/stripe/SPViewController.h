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


@interface SPViewController : UIViewController <UITextFieldDelegate>
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
@property (weak, nonatomic) IBOutlet UIView *viewPay;
@property (weak, nonatomic) IBOutlet UIView *viewNewCard;
@property (weak, nonatomic) IBOutlet UIView *viewOldCard;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *viewMain;
@property (weak, nonatomic) IBOutlet UITableView *tableOldCard;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constaintTableParentHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTableHeight;

@property (weak, nonatomic) IBOutlet UIButton *btnAddNewCard;
@property (weak, nonatomic) IBOutlet UILabel *lblAddNewCard;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cLblAddNewCardH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cBtnAddNewCardH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cViewNewCardH;
@property (weak, nonatomic) IBOutlet UILabel *lblSavedCard;
@property (weak, nonatomic) IBOutlet UILabel *lblTotalAmountH;
@property (weak, nonatomic) IBOutlet UILabel *lblTotalAmountD;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *clblNameTop;

@property (weak, nonatomic) IBOutlet UIView *viewLineNewCard;


@property UITextField* textFieldFirstResponder;
@property float keyboardHeight;
@property double duration;
@property UIViewAnimationCurve curve;
@end
