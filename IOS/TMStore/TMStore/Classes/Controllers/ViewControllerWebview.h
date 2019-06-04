//
//  ViewControllerWebview.h

//
//  Created by Rishabh Jain on 24/09/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Variables.h"

@interface ViewControllerWebview: UIViewController<UIWebViewDelegate> {
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
@property BOOL enableTouchBg;
- (void)loadAllViews:(NSString*)linkStr;
- (void)loadAllViews:(NSString*)linkStr enableTouchBg:(BOOL)enableTouchBg;
@property UIWebView* webView;
@property UILabel* labelViewHeading;
@end