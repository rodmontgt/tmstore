//
//  ViewController.h
//  PaymentGateway
//
//  Created by Suraj on 22/07/15.
//  Copyright (c) 2015 Suraj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PaymentPageViewController : UIViewController <UIWebViewDelegate, UIAlertViewDelegate> 
- (id)initWithPayment:(NSDictionary*)dict;

@property NSString* Merchant_Key;
@property NSString* Salt;
@property NSString* Success_URL;
@property NSString* Failure_URL;
@property NSString* Product_Info;
@property NSString* Paid_Amount;
@property NSString* Payee_Name;
@property NSString* Email;
@property NSString* Phone;
@property NSString* Serviceprovider;
@property BOOL isTestMode;
@property id responseDelegate;
@end

