//
//  VCSPayViewController.h
//  TMPaymentSDK
//
//  Created by Rishabh Jain on 29/06/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TMShippingSDK.h"
@interface VCSPayViewController : UIViewController
@property (nonatomic) NSDecimalNumber *amount;
//@property (nonatomic, weak) id<StripePaymentViewControllerDelegate> delegate;
@property (nonatomic, weak) id responseDelegate;
@property NSString* serverUrl;
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
@property UITextField* textFieldFirstResponder;
@property float keyboardHeight;
@property double duration;
@property UIViewAnimationCurve curve;
@end
