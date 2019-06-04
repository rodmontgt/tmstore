//
//  ViewControllerSellerZone.h

//
//  Created by Rajshekhar on 18/07/17.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Variables.h"

@interface ViewControllerSellerZone: UIViewController {
    IBOutlet UIScrollView *_scrollView;
//        id <BarcodeScannerDelegate> _delegate;
    id _delegate;
}
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UIView *lineView;
@property (weak, nonatomic) IBOutlet UINavigationItem *currentItemHeading;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *previousItemHeading;

- (IBAction)barButtonBackPressed:(id)sender;
@property UIImageView* topImage;
@property UIButton* btnProceed;
@property float defaultHeight;
@property UILabel* labelViewHeading;
- (void)setDelegate:(id)delegate;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintSellerInfoHeight;
@property (weak, nonatomic) IBOutlet UIView *viewNoSeller;
@property (weak, nonatomic) IBOutlet UILabel *labelDesc;
@property (weak, nonatomic) IBOutlet UIButton *buttonLogin;

- (void)loadCurrentSellerData;
@end
