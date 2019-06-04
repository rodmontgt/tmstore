//
//  CardViewController.h
//  TMPaymentSDK
//
//  Created by Rishabh Jain on 28/06/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CardViewController : UIViewController
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
