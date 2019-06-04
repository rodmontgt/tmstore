//
//  ViewControllerLeft.h
//  eCommerceApp
//
//  Created by Rishabh Jain on 16/09/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Variables.h"
#import "LoginViewOnDrawer.h"
#import "RADataObject.h"
#import "WebViewWordPress.h"
#import "ServerData.h"
#import "CommonInfo.h"
#import "TMMulticastDelegate.h"
#import <Google/SignIn.h>

#if ENABLE_FB_LOGIN
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#endif

#if ENABLE_TWITTER_LOGIN
#import <TwitterCore/TwitterCore.h>
#import <TwitterKit/TwitterKit.h>
#import <Twitter/Twitter.h>
#endif

@interface ViewControllerLeft : UIViewController <UITextViewDelegate, TMMulticastDelegate, GIDSignInDelegate, GIDSignInUIDelegate

#if (ENABLE_FB_LOGIN)
, FBSDKLoginButtonDelegate
#endif

#if (ENABLE_TWITTER_LOGIN)

#endif
>
{
    UITableView *tableView;
    LoginViewOnDrawer *loginView;
    UIView *headerView;
    UIView *footerView;
    UIButton *buttonDrawer;
    RADataObject *categoryObject;
    RADataObject *settingObject;
//    RADataObject *helpAndSupportObject;
    RADataObject *rateThisAppObject;
    NSMutableArray* menuObjects;//RADataObject
    
}
@property BOOL isUserLoggedIn;
@property UIButton *fbLoginButton;
@property UIButton *twitterLoginButton;
@property UIButton *googleLoginButton;
@property UITextField* textLoginId;
@property UITextField* textLoginPassword;
- (void)adjustViewsForOrientation:(UIDeviceOrientation) orientation;
- (void)adjustViewsAfterOrientation:(UIDeviceOrientation) orientation;
@property WebViewWordPress* wpWebView;

@property ServerData* _tempServerData;
@property float rowH;
@property float gap;

@property BOOL isRegisterAsVendor;
@property UITextField* textRegisterUsername;
@property UITextField* textRegisterEmailId;
@property UITextField* textRegisterPassword;
@property UITextField* textRegisterConfirmPassword;
@property UITextField* textRegisterMobileNumber;

@property UITextField* textForgotPasswordEmailId;

@property UITextField* textRegisterAsSellerUsername;
@property UITextField* textRegisterAsSellerEmailId;
@property UITextField* textRegisterAsSellerPassword;
@property UITextField* textRegisterAsSellerConfirmPassword;
@property UITextField* textRegisterAsSellerMobileNumber;
@property UITextField* textRegisterAsSellerFirstName;
@property UITextField* textRegisterAsSellerLastName;
@property UITextField* textRegisterAsSellerCompanyName;


@property UIView* mainViewRegisterAsSeller;
@property UIView* mainViewRegister;
@property UIView* mainViewLogin;
@property UIView* mainViewForgotPassword;

@property CGRect loginScreenRectFB;
@property CGRect loginScreenRectGoogle;
@property CGRect loginScreenRectTwitter;

@property CGRect registerScreenRectFB;
@property CGRect registerScreenRectGoogle;
@property CGRect registerScreenRectTwitter;

@property CGRect forgotScreenRectFB;
@property CGRect forgotScreenRectGoogle;
@property CGRect forgotScreenRectTwitter;

- (void)showLoginPopup:(BOOL)withAnimation;
- (void)logoutClicked;
@property NSMutableArray* chkBoxLanguage;
@property NSString* selectedLocale;
@property UIButton *buttonRegisterAsVendor;
//@property(weak, nonatomic) IBOutlet GIDSignInButton *signInButton;
//@property GIDSignInButton* signInButton;
@property BOOL isMyAccountScreen;

@property UITextField* sponsorFriendFirstName;
@property UITextField* sponsorFriendLastName;
@property UITextField* sponsorFriendEmail;
@property UITextView* sponsorOptionalMsg;


@property id tempProdVC;
#pragma mark OTP
@property NSString* registerMobileNumber;
@property float OTPResendTimerForeground;
@property float OTPResendTimerBackground;
@property UIButton* OTPButtonResend;
@property UIButton* OTPButtonVerify;
@property UIButton* otp_button_mobile;
@property UITextField* otp_textfield_code;
@property UIButton* otp_button_timer;
@property NSTimer* otp_timer_foreground;
@property NSTimer* otp_timer_background;
@property NSString* registerMobileNumberOTP;


#pragma mark RESET PASSWORD
@property NSString* rp_str_old_pass;
@property NSString* rp_str_new_pass;
@property NSString* rp_str_new_confirm_pass;
@property UIButton* rp_button;
@property UITextField* rp_textfield_old_pass;
@property UITextField* rp_textfield_new_pass;
@property UITextField* rp_textfield_new_confirm_pass;

@property (nonatomic, copy) void (^didDismiss)(NSString *data);
@end
