//
//  WebViewController.h
//  GoogleMapsDemo
//
//  Created by Vikas Patidar on 20/12/17.
//  Copyright © 2017 TwistMobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, strong) NSMutableArray *arrayTitle;

@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UIView *lineView;
@property (weak, nonatomic) IBOutlet UINavigationItem *currentItemHeading;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *previousItemHeading;

@property (strong,nonatomic)NSMutableArray *arrayUrl;
- (IBAction)barButtonBackPressed:(id)sender;

@property UILabel* labelViewHeading;
@property id parentVC;
@end
