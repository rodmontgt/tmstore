//
//  ViewControllerReservationForm.h
//  TMStore
//
//  Created by Rishabh Jain on 05/05/17.
//  Copyright (c) 2017 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewControllerReservationForm: UIViewController {
    IBOutlet UIScrollView *_scrollView;
}
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UIView *lineView;
@property (weak, nonatomic) IBOutlet UINavigationItem *currentItemHeading;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *previousItemHeading;
@property UILabel* labelViewHeading;
- (IBAction)barButtonBackPressed:(id)sender;
@end