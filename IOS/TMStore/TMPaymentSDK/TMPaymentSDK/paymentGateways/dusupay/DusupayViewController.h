//
//  DusupayViewController.h
//  PaymentGateway
//
//  Created by Rishabh Jain on 25/11/16.
//

#import <UIKit/UIKit.h>

@interface DusupayViewController : UIViewController <UIWebViewDelegate, UIAlertViewDelegate>  {
UIButton *navButton;
}
- (id)initWithPayment:(NSDictionary*)dict;
@property id responseDelegate;
@property NSString* dusupay_hash;                  //not necessary
@property NSString* dusupay_merchantId;
@property NSString* dusupay_amount;
@property NSString* dusupay_currency;
@property NSString* dusupay_itemId;
@property NSString* dusupay_itemName;
@property NSString* dusupay_transactionReference;
@property NSString* dusupay_redirectURL;
@property NSString* dusupay_successURL;
//@property NSString* dusupay_render;                //not necessary
//@property NSString* dusupay_logo;                  //not necessary
@property NSString* dusupay_environment;           //not necessary

@property NSString* dusupay_checkUrl;
@end

