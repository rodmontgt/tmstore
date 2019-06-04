//
//  ViewControllerSponsorFriend.h

//
//  Created by Rishabh Jain on 24/09/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Variables.h"

@interface ViewControllerSponsorFriend: UIViewController <UIAlertViewDelegate, UIScrollViewDelegate> {
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
@property UIButton* selectedButtonCancelOrder;
@property UIAlertView *alertViewCancelOrder;
@property int loadedOrdersCount;
@property UIActivityIndicatorView* spinnerView;
@property BOOL isNewOrdersLoading;
@property int cancelledOrderCount;
@property int pendingOrderCount;
@property UILabel* labelViewHeading;
@end