//
//  VCMyOrders.h
//  TMStore
//
//  Created by Rajshekhar on 19/07/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Variables.h"

@interface VCMyOrders : UIViewController <UITableViewDelegate, UITableViewDataSource> {
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
@property (weak, nonatomic) IBOutlet UITableView *tabel_orders;

@property NSArray* pickerArray;
@property NSArray* pickerArrayOriginalStatus;
@end
