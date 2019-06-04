//
//  ConektaCardPaymentVC.h
//  PaymentGateway
//
//  Created by Rishabh Jain on 12/05/17.
//

#import <UIKit/UIKit.h>

@interface ConektaCardPaymentVC : UIViewController <UIWebViewDelegate, UIAlertViewDelegate>
{
    UIButton *navButton;
}
@property NSString* baseURL;
@property NSString* successURL;
@property NSString* failureURL;
@property NSString* amountStr;
@property float amount;

@property id responseDelegate;
- (id)initWithDelegate:(id)delegate;
@end

