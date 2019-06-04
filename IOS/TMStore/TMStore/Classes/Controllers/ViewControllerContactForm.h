//
//  ViewControllerContactForm.h
//  TMStore
//
//  Created by Rishabh Jain on 05/05/17.
//  Copyright (c) 2017 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewControllerContactForm: UIViewController<UITextFieldDelegate, UITextViewDelegate> {
    IBOutlet UIScrollView *_scrollView;
    UILabel* labelFormTitle;
    UITextField* textFieldName;
    UITextField* textFieldEmail;
    UITextView* textViewMessage;
    
    
    NSString* tempName;
    NSString* tempEmail;
    NSString* tempMessage;
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