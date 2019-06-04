//
//  ShowAllStoresViewController.h

//
//  Created by Rajshekhar on 13/07/17.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ShowAllStoresViewController: UIViewController

@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UIView *lineView;
@property (weak, nonatomic) IBOutlet UINavigationItem *currentItemHeading;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *previousItemHeading;
- (IBAction)barButtonBackPressed:(id)sender;


@end
