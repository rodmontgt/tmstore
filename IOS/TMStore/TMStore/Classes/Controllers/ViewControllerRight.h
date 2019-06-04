//
//  ViewControllerRight.h
//  eCommerceApp
//
//  Created by Rishabh Jain on 16/09/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "RADataObject.h"

@interface ViewControllerRight : UIViewController <UITableViewDelegate, UITableViewDataSource>//<TMMulticastDelegate>

@property UIView *headerView;
@property UIView *footerView;
//@property UIButton *buttonDrawer;
@property NSMutableArray* menuObjects;//RADataObject

@property float rowH;
@property float gap;
@property NSMutableArray* chkBoxLanguage;
@property NSString* selectedLocale;

- (void)adjustViewsForOrientation:(UIDeviceOrientation) orientation;
- (void)adjustViewsAfterOrientation:(UIDeviceOrientation) orientation;

@property (strong, nonatomic) IBOutlet UIView *viewMain;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchBarTopSpaceConstraint;
@property (strong, nonatomic) IBOutlet UISearchDisplayController *searchDisplayController;



@end
