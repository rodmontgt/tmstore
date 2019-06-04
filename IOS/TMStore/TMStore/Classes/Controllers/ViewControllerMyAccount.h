//
//  ViewControllerMyAccount.h
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
#if (INTEGRATE_LOGIN_FB_OLD)
#import <FacebookSDK/FacebookSDK.h>
#endif
#if (INTEGRATE_LOGIN_FB_NEW)
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#endif
#import "ViewControllerLeft.h"

//enum BUTTONS_ID {
//    BUTTONS_ID_HOME,
//    BUTTONS_ID_CATEGORIES,
//    BUTTONS_ID_MENU_ITEMS,
//    BUTTONS_ID_CART,
//    BUTTONS_ID_WISHLIST,
//    BUTTONS_ID_SEARCH,
//    BUTTONS_ID_ORDERS,
//    BUTTONS_ID_SETTINGS,
//    BUTTONS_ID_HELP_AND_SUPPORT,
//    BUTTONS_ID_LIVE_CHAT,
//    BUTTONS_ID_RATE_APP,
//    BUTTONS_ID_LOGIN,
//    BUTTONS_ID_LOGOUT,
//    BUTTONS_ID_ADDRESS,
//    BUTTONS_ID_CONTACT_US,
//    BUTTONS_ID_TERMS_AND_CONDITIONS,
//    BUTTONS_ID_LANGUAGES,
//    BUTTONS_ID_TOTAL
//};




@interface ViewControllerMyAccount : UIViewController <TMMulticastDelegate, GIDSignInDelegate, GIDSignInUIDelegate

#if (INTEGRATE_LOGIN_FB_OLD)
, FBLoginViewDelegate
#endif
#if (INTEGRATE_LOGIN_FB_NEW)
, FBSDKLoginButtonDelegate
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
    RADataObject *helpAndSupportObject;
    RADataObject *rateThisAppObject;
    NSMutableArray* menuObjects;//RADataObject
    
}
@property BOOL isUserLoggedIn;

#if (INTEGRATE_LOGIN_FB_OLD)
@property FBLoginView *fbLoginButton;
#elif (INTEGRATE_LOGIN_FB_NEW)
@property FBSDKLoginButton *fbLoginButton;
#else
@property UIButton *fbLoginButton;
#endif
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


@property UITextField* textRegisterUsername;
@property UITextField* textRegisterEmailId;
@property UITextField* textRegisterPassword;
@property UITextField* textRegisterConfirmPassword;
@property UITextField* textForgotPasswordEmailId;

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
@property NSMutableArray* chkBoxLanguage;
@property NSString* selectedLocale;
//@property(weak, nonatomic) IBOutlet GIDSignInButton *signInButton;
//@property GIDSignInButton* signInButton;
@property BOOL isMyAccountScreen;
@end
