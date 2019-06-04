//
//  ExampleUIWebViewController.m
//  ExampleApp-iOS
//
//  Created by Marcus Westin on 1/13/14.
//  Copyright (c) 2014 Marcus Westin. All rights reserved.
//

#import "ExampleUIWebViewController.h"
#import "NSObject+SEWebviewJSListener.h"

@interface ExampleUIWebViewController (SEWebviewJSListener)
@end

@implementation ExampleUIWebViewController
- (void)viewWillAppear:(BOOL)animated {
    
    UIWebView* webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:webView];
    
    [self loadLoginExternalPage:webView];
}
- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"webViewDidStartLoad");
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"webViewDidFinishLoad %d", (int)[webView tag]);
    switch ([webView tag]) {
        case 100:
            [self loadLoginPage:webView];
            break;
        case 101:
            [self autofillLoginDetail:webView];
            break;
        case 102:
            break;
        default:
            break;
    }
}
-(void)registerNewUser:(UIWebView*)webView{
    [webView setTag:99];
    NSString* userName = @"ankur";
    NSString* password = @"password";
    NSString* userEmailId = @"myemailId";
    NSString* string = [NSString stringWithFormat:@"http://playcontest.in/ankur_worldpress_test/wordpress/createUser.php?user_name=%@&user_password=%@&user_email=%@", userName, password, userEmailId];
    NSURL *websiteUrl = [NSURL URLWithString:string];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:websiteUrl];
    [webView loadRequest:urlRequest];
}
-(void)loadLoginExternalPage:(UIWebView*)webView {
    NSLog(@"loadLoginExternalPage");
    [webView setTag:100];
    NSString* string = [NSString stringWithFormat:@"http://playcontest.in/ankur_worldpress_test/wordpress/ExternalLogin.php?user_platform=IOS"];
    NSURL *websiteUrl = [NSURL URLWithString:string];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:websiteUrl];
    [webView loadRequest:urlRequest];
}
-(void)loadLoginPage:(UIWebView*)webView {
     NSLog(@"loadLoginPage");
    [webView setTag:101];
    NSString* string = [NSString stringWithFormat:@"http://playcontest.in/ankur_worldpress_test/wordpress/wp-login.php"];
    NSURL *websiteUrl = [NSURL URLWithString:string];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:websiteUrl];
    [webView loadRequest:urlRequest];
}
-(void)autofillLoginDetail:(UIWebView*)webView {
    NSLog(@"autofillLoginDetail");
    [webView setTag:102];
    NSString* userName = @"ankur";
    NSString* password = @"password";
    NSString* string = [NSString stringWithFormat:@"javascript:document.getElementById('user_login').value = '%@';javascript:document.getElementById('user_pass').value = '%@';javascript:document.getElementById('wp-submit').click();", userName, password];
    [webView stringByEvaluatingJavaScriptFromString:string];
}
- (void)webviewMessageKey:(NSString *)key value:(NSString *)val{
    NSLog(@"key = %@, val = %@", key, val);
}
- (BOOL)shouldOpenLinksExternally{
    NSLog(@"shouldOpenLinksExternally");
    return NO;
}
@end
