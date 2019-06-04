//
//  CurrencyViewController.h
//  GoogleMapsDemo
//
//  Created by Vikas Patidar on 20/12/17.
//  Copyright © 2017 TwistMobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CurrencyViewController : UIViewController

@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UIView *lineView;
@property (weak, nonatomic) IBOutlet UINavigationItem *currentItemHeading;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *previousItemHeading;

@property (weak, nonatomic) IBOutlet UITableView *currencyTable;
- (IBAction)barButtonBackPressed:(id)sender;
@property NSMutableArray* chkBoxCurrency;

@property UILabel* labelViewHeading;
@property id parentVC;
@end
