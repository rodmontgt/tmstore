//
//  ViewControllerContactUs.h

//
//  Created by Rishabh Jain on 24/09/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Variables.h"
#import "LayoutProperties.h"
#import <MessageUI/MessageUI.h>


@interface ViewControllerContactUs: UIViewController <MFMailComposeViewControllerDelegate>{
IBOutlet UIScrollView *_scrollView;
    LayoutProperties *_propBanner;

}
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UIView *lineView;
@property (weak, nonatomic) IBOutlet UINavigationItem *currentItemHeading;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *previousItemHeading;
- (IBAction)barButtonBackPressed:(id)sender;

@property UIImageView* topImage;
@property UIButton* btnProceed;

@property float defaultHeight;

- (void)loadAllViews;
@property UILabel* labelViewHeading;
@property NSDictionary *dic;

@end