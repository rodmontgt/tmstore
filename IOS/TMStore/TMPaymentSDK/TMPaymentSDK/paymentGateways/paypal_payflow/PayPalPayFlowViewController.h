//
//  PayPalPayFlowViewController.h
//  
//
//  Created by Rishabh Jain on 12/12/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#pragma mark SEWebviewJSListenerNew
@interface NSObject (SEWebviewJSListenerNew)
- (void)webviewMessageKey:(NSString *)key value:(NSString *)val;
- (BOOL)shouldOpenLinksExternally;
@end

@interface PayPalPayFlowViewController : UIViewController<UIWebViewDelegate, UIAlertViewDelegate>
{
    UIButton *navButton;
}
@property id responseDelegate;
- (id)initWithDelegate:(id)delegate;

@end

