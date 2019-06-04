//
//  CCAvenueController.h
//  TMPaymentSDK
//
//  Created by Rishabh Jain on 04/11/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TMPaymentSDK.h"

@interface CCAvenueController : UIViewController <UIWebViewDelegate>
-(id) initWithDelegate:(TMPaymentSDKDelegate*) delegate;

@property (strong, nonatomic) UIWebView *webView;

@property (strong, nonatomic) NSString *accessCode;
@property (strong, nonatomic) NSString *merchantId;
@property (strong, nonatomic) NSString *orderId;
@property (strong, nonatomic) NSString *amount;
@property (strong, nonatomic) NSString *currency;
@property (strong, nonatomic) NSString *redirectUrl;
@property (strong, nonatomic) NSString *cancelUrl;
@property (strong, nonatomic) NSString *rsaKeyUrl;
@property (strong, nonatomic) TMPaymentSDKDelegate *delegate;
@end
