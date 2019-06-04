//
//  LocateStoreViewController.h

//
//  Created by Rajshekhar on 13/07/17.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Variables.h"
#import "ViewControllerMain.h"

@interface LocateStoreViewController: UIViewController {
    IBOutlet UIScrollView *_scrollView;
//        id <BarcodeScannerDelegate> _delegate;
    id _delegate;
}
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UIView *lineView;
@property (weak, nonatomic) IBOutlet UINavigationItem *currentItemHeading;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *previousItemHeading;
@property (weak, nonatomic) ViewControllerMain *vcMain;
@property (weak, nonatomic) IBOutlet UISearchBar *storeSearchBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintSearchBarHeight;
- (IBAction)barButtonBackPressed:(id)sender;
@property UIImageView* topImage;
@property UIButton* btnProceed;
@property float defaultHeight;
@property UILabel* labelViewHeading;
- (void)setDelegate:(id)delegate;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *parentTableview;
@property (weak, nonatomic) IBOutlet UILabel *labelDistance;
@end
