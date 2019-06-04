//
//  ViewControllerCheckout.h

//
//  Created by Rishabh Jain on 24/09/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Variables.h"
#import "AppUser.h"
//#import "TMMulticastDelegate.h"

#pragma mark SEWebviewJSListenerNew
@interface NSObject (SEWebviewJSListenerNew)
- (void)webviewMessageKey:(NSString *)key value:(NSString *)val;
- (BOOL)shouldOpenLinksExternally;
@end


@interface ViewControllerCheckout: UIViewController<UIWebViewDelegate> {
IBOutlet UIScrollView *_scrollView;
}
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UIView *lineView;
@property (weak, nonatomic) IBOutlet UINavigationItem *currentItemHeading;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *previousItemHeading;
- (IBAction)barButtonBackPressed:(id)sender;

@property UIImageView* topImage;
@property UIButton* btnProceed;

@property float defaultHeight;
@property NSString* linkStr;
@property UIWebView* webView;


- (void)loadLoginView;
- (void)loadLoginViewHidden;

@property NSMutableArray* cartItems;
@property int webViewState;

@property NSMutableArray* viewsAdded;
@property UIButton *customBackButton;
@property UILabel* labelViewHeading;
@end