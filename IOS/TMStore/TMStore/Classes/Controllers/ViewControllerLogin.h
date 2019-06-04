//
//  ViewControllerLogin.h
//  eMobileApp
//
//  Created by V S Khutal on 25/11/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CNPPopupController.h"
enum TAGTEXTFIELD_LOGIN{
    _kTAGTEXTFIELD_LOGIN_ID,
    _kTAGTEXTFIELD_LOGIN_PASSWORD,
    _kTAGTEXTFIELD_R_USERNAME,
    _kTAGTEXTFIELD_R_EMAIL,
    _kTAGTEXTFIELD_R_PASSWORD,
    _kTAGTEXTFIELD_R_CPASSWORD,
    _kTAGTEXTFIELD_R_MOBILE_NUMBER,
    _kTAGTEXTFIELD_RP_OLD_PASS,
    _kTAGTEXTFIELD_RP_NEW_PASS,
    _kTAGTEXTFIELD_RP_NEW_CONFIRM_PASS,
    _kTAGTEXTFIELD_R_FIRST_NAME,
    _kTAGTEXTFIELD_R_LAST_NAME,
    _kTAGTEXTFIELD_R_COMPANY_NAME,


};
@interface ViewControllerLogin : UIViewController <UITextFieldDelegate>{
    IBOutlet UIScrollView *_scrollView;
}
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UINavigationItem *currentItemHeading;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *previousItemHeading;
- (IBAction)barButtonBackPressed:(id)sender;

@property UIButton* buttonSignIn;
@property UIButton* buttonFacebook;
@property UIButton* buttonGoogle;
@property UIButton* buttonTwitter;
@property UIButton* buttonSignUp;
@property UILabel* labelTitle;
@property UITextField* textUserId;
@property UITextField* textPassword;

@end
