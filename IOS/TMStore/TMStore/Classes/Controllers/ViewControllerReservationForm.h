//
//  ViewControllerReservationForm.h
//  TMStore
//
//  Created by Rishabh Jain on 08/05/17.
//  Copyright (c) 2017 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FPPopoverController.h"
#import "NIDropDown.h"
@interface ViewControllerReservationForm: UIViewController<UITextFieldDelegate, UITextViewDelegate, FPPopoverControllerDelegate, NIDropDownDelegate> {
    IBOutlet UIScrollView *_scrollView;
    UILabel* labelFormTitle;
    UITextField* textFieldBookingName;
    UITextField* textFieldEmail;
    UITextField* textFieldPers;

    UIButton* buttonDate;
    UIButton* buttonDateDD;
//    UIButton* buttonPers;
//    UIButton* buttonPersDD;
    UIButton* buttonHour;
    UIButton* buttonHourDD;
    UIButton* buttonT332;
    UIButton* buttonT332DD;
    UITextField* textFieldContact;
    UITextView* textViewMessage;
    
    
    NSString* tempBookingName;
    NSString* tempEmail;
    NSString* tempPers;
    NSString* tempMessage;
    NSString* tempContact;
    NSString* tempDate;
    NSString* tempHour;
    NSString* tempT332;
}
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UIView *lineView;
@property (weak, nonatomic) IBOutlet UINavigationItem *currentItemHeading;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *previousItemHeading;
@property UILabel* labelViewHeading;
- (IBAction)barButtonBackPressed:(id)sender;


@property UITextField* textFieldFirstResponder;
@property float keyboardHeight;
@property double duration;
@property UIViewAnimationCurve curve;


@property UITextView* textViewFirstResponder;
@end