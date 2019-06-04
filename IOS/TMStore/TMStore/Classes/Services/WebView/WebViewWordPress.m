//
//  WebViewWordPress.m
//  ExampleApp-iOS
//
//  Created by Marcus Westin on 1/13/14.
//  Copyright (c) 2014 Marcus Westin. All rights reserved.
//

#import "WebViewWordPress.h"
#import "CommonInfo.h"
#import "DataManager.h"
#import "ViewControllerMain.h"
#import "Utility.h"
//#import "NSObject+SEWebviewJSListener.h"

#pragma mark SEWebviewJSListener

@implementation NSObject (SEWebviewJSListener)

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSString *requestString = [[[request URL] absoluteString] stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    RLOG(@"requestString = %@", requestString);
    
    NSArray *requestArray = [requestString componentsSeparatedByString:@":##sendToApp##"];
    if ([requestArray count] > 1){
        NSString *requestPrefix = [[requestArray objectAtIndex:0] lowercaseString];
        NSString *requestMssg = ([requestArray count] > 0) ? [requestArray objectAtIndex:1] : @"";
        [self webviewMessageKey:requestPrefix value:requestMssg];
        return NO;
    } else if (navigationType == UIWebViewNavigationTypeLinkClicked && [self shouldOpenLinksExternally]) {
        // open links in safari
        RLOG(@"open links in safari");
        [[UIApplication sharedApplication] openURL:[request URL]];
        return NO;
    }
    return YES;
}

- (void)webviewMessageKey:(NSString *)key value:(NSString *)val {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    RLOG(@"key=%@,val=%@", key, val);
}

- (BOOL)shouldOpenLinksExternally {
    return YES;
}

@end



#pragma mark WebViewWordPress

@interface WebViewWordPress (SEWebviewJSListener)

@end

@implementation WebViewWordPress

#pragma mark INIT

+ (id)sharedManager {
    static WebViewWordPress *sharedManager = nil;
    @synchronized(self) {
        if (sharedManager == nil)
            sharedManager = [[self alloc] init];
    }
    return sharedManager;
}

- (id)init {
    if (self = [super init]) {
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [_webView setDelegate:self];
        [self addSubview:_webView];
//        [[ViewControllerMain getInstance].view addSubview:_webView];
        
    }
    return self;
}

#pragma mark PUBLIC-METHODS

- (void)registerNewUser:(NSString*)userName password:(NSString*)password emailId:(NSString*)emailId {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    NSString* string = [NSString stringWithFormat:@"%@?user_platform=IOS&user_name=%@&user_password=%@&user_email=%@&create_new_user",[[[DataManager sharedManager] tmDataDoctor] createUserPageLink], userName, password, emailId];
    [self loadURL:string tag:WV_WORDPRESS_STEPS_REGISTER];
}

- (void)loadLoginExternalPage {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    NSString* string = [NSString stringWithFormat:@"%@?user_platform=IOS", [[[DataManager sharedManager] tmDataDoctor] externalLoginPageLink]];
    [self loadURL:string tag:WV_WORDPRESS_STEPS_LOAD_EXT_LOGIN_PAGE];
}

- (void)loadLoginPage {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    NSString* string = [NSString stringWithFormat:@"%@", [[[DataManager sharedManager] tmDataDoctor] loginPageLink]];
    [self loadURL:string tag:WV_WORDPRESS_STEPS_LOAD_LOGIN_PAGE];
}

- (void)autofillLoginDetail:(NSString*)userName password:(NSString*)password {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    NSString* string = [NSString stringWithFormat:@"\
                                       javascript:document.getElementById('user_login').value = '%@';\
                                       javascript:document.getElementById('user_pass').value = '%@';\
                                       javascript:document.getElementById('wp-submit').click();\
                        ", userName, password];
    [self passDataToJS:string tag:WV_WORDPRESS_STEPS_FILL_LOGIN_DATA];
}

#pragma mark CALL-BACKS

- (void)webViewDidStartLoad:(UIWebView *)webView {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    RLOG(@"webViewDidStartLoad");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    RLOG(@"webViewDidFinishLoad %d", (int)[webView tag]);
    switch ([webView tag]) {
        case WV_WORDPRESS_STEPS_REGISTER:
            break;
        case WV_WORDPRESS_STEPS_LOAD_EXT_LOGIN_PAGE:
            [self loadLoginPage];
            break;
        case WV_WORDPRESS_STEPS_LOAD_LOGIN_PAGE:
            [self autofillLoginDetail:_loginFillData_userName password:_loginFillData_userPassword];
            break;
        case WV_WORDPRESS_STEPS_FILL_LOGIN_DATA:
#if (FORCE_LOGIN_ENABLE)
            [self webviewMessageKey:@"Login" value:@"Success"];
#endif
            break;
        default:
            break;
    }
}

- (void)webviewMessageKey:(NSString *)key value:(NSString *)val{
    RLOG(@"%s", __PRETTY_FUNCTION__);
    RLOG(@"key=%@,val=%@,", key, val);
    
    if ([key isEqualToString:@"Login"]) {
        if ([Utility containsString:val substring:@"Successful"]){
            _isUserAuthenticated = true;
            _isUserLoggedIn = true;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginSuccessful" object:self];
        }else {
            _isUserAuthenticated = false;
            _isUserLoggedIn = false;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginFailed" object:self];
        }
    }
}

- (BOOL)shouldOpenLinksExternally{
    RLOG(@"%s", __PRETTY_FUNCTION__);
    return NO;
}

#pragma mark REQUESTS

- (void)loadURL:(NSString*)string tag:(int)tag{
    RLOG(@"%s", __PRETTY_FUNCTION__);
    RLOG(@"%@", string);
    [_webView setTag:tag];
    NSURL *websiteUrl = [NSURL URLWithString:string];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:websiteUrl];
    [_webView loadRequest:urlRequest];
}

- (void)passDataToJS:(NSString*)string tag:(int)tag{
    RLOG(@"%s", __PRETTY_FUNCTION__);
    RLOG(@"%@", string);
    
    [_webView setTag:tag];
    [_webView stringByEvaluatingJavaScriptFromString:string];
}
- (void)testFaltu{
    RLOG(@"%s", __PRETTY_FUNCTION__);
    NSString* string = @"http://thetmstore.com/test/pluginFunctions_ios.php";
    RLOG(@"%@", string);
    [_webView setTag:88];
    NSURL *websiteUrl = [NSURL URLWithString:string];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:websiteUrl];
    [_webView loadRequest:urlRequest];
}

@end
