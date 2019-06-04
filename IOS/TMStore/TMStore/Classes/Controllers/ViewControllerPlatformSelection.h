//
//  ViewControllerPlatformSelection.h
//  eCommerceApp
//
//  Created by Rishabh Jain on 16/09/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Variables.h"
#import "DataManager.h"


@interface ViewControllerPlatformSelection : UIViewController<UISearchDisplayDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *searchResult;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (weak, nonatomic) IBOutlet UINavigationItem *currentItemHeading;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *previousItemHeading;
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UIView *lineView;
@property UILabel* labelViewHeading;

@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (strong, nonatomic) IBOutlet UIImageView *imageFg;
@property (strong, nonatomic) IBOutlet UILabel *labelPoweredBy;
@property (weak, nonatomic) IBOutlet UILabel *labelVersionInfo;
@property (weak, nonatomic) IBOutlet UIImageView *imgSplash;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintImgLogoWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintImgLogoWidthFull;
@property (weak, nonatomic) IBOutlet UILabel *noNearStoreLabel;

@property (nonatomic, strong) GMSMarker *markerInfo;

@end


@interface StoreViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgIcon;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelDesc;
@property (weak, nonatomic) IBOutlet UIView *viewContent;
@property (weak, nonatomic) IBOutlet UIView *viewMain;





@end

