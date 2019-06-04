//
//  WebViewWordPress.h
//  ExampleApp-iOS
//
//  Created by Marcus Westin on 1/13/14.
//  Copyright (c) 2014 Marcus Westin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


enum WV_WORDPRESS_STEPS{
    WV_WORDPRESS_STEPS_LOAD_EXT_LOGIN_PAGE,
    WV_WORDPRESS_STEPS_LOAD_LOGIN_PAGE,
    WV_WORDPRESS_STEPS_FILL_LOGIN_DATA,
    WV_WORDPRESS_STEPS_REGISTER,
};



#pragma mark SEWebviewJSListener
@interface NSObject (SEWebviewJSListener)

- (void)webviewMessageKey:(NSString *)key value:(NSString *)val;
- (BOOL)shouldOpenLinksExternally;

@end





#pragma mark WebViewWordPress
@interface WebViewWordPress : UIView <UIWebViewDelegate>

@property UIWebView* webView;
+ (id)sharedManager;
- (void)registerNewUser:(NSString*)userName password:(NSString*)password emailId:(NSString*)emailId;
- (void)loadLoginExternalPage;
- (void)loadLoginPage;
- (void)autofillLoginDetail:(NSString*)userName password:(NSString*)password;

- (void)loadURL:(NSString*)string tag:(int)tag;
- (void)passDataToJS:(NSString*)string tag:(int)tag;

@property NSString* loginFillData_userName;
@property NSString* loginFillData_userPassword;
@property NSString* loginFillData_userEmail;
@property BOOL isUserAuthenticated;
@property BOOL isUserLoggedIn;
- (void)testFaltu;
@end