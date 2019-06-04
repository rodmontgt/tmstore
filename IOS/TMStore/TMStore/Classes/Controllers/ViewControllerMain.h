//
//  ViewControllerMain.h

//
//  Created by Rishabh Jain on 24/09/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWRevealViewController.h"
#import "ViewControllerBottomBar.h"
#import "ViewControllerTopBar.h"
#import "Variables.h"

@interface ViewControllerMain : UIViewController<UITabBarDelegate>

@property UIStoryboard *sb;
@property NSMutableDictionary* viewControllersByIdentifier;
@property (weak, nonatomic) IBOutlet UIView *containerCenter;
@property (weak, nonatomic) IBOutlet UIView *containerTop;
@property (weak, nonatomic) IBOutlet UIView *containerBottom;
@property (weak, nonatomic) IBOutlet UIView *containerCenterWithTop;

//@property (weak, nonatomic) IBOutlet UITabBar       *bottomTabBar;
//@property (weak, nonatomic) IBOutlet UITabBarItem   *tabBtnHome;
//@property (weak, nonatomic) IBOutlet UITabBarItem   *tabBtnSearch;
//@property (weak, nonatomic) IBOutlet UITabBarItem   *tabBtnCart;
//@property (weak, nonatomic) IBOutlet UITabBarItem   *tabBtnWishlist;

@property (weak, nonatomic) UIViewController *destinationViewController;
@property (strong, nonatomic) UIViewController *oldViewController;

//- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item;




@property (weak, nonatomic) ViewControllerTopBar *vcTopBar;
@property (weak, nonatomic) ViewControllerBottomBar *vcBottomBar;
@property (weak, nonatomic) UIViewController *vcCenterTop;
@property (weak, nonatomic) SWRevealViewController *revealController;


- (IBAction)btnClicked:(id)sender;

- (IBAction)btnClickedRightDrawer:(id)sender;
- (IBAction)btnClickedLeftDrawer:(id)sender;
- (IBAction)btnClickedHome:(id)sender;
- (UIViewController *)btnClickedSearch:(id)sender;
- (IBAction)btnClickedOpinion:(id)sender;
- (IBAction)btnClickedCart:(id)sender;
- (IBAction)btnClickedWishlist:(id)sender;
- (IBAction)btnClickedMyAccount:(id)sender;
- (IBAction)btnClickedLiveChat:(id)sender;
- (UIViewController*)getCartViewController:(id)sender;
+ (ViewControllerMain*)getInstance;
- (void)adjustViewsForOrientation:(UIDeviceOrientation) orientation;
- (void)adjustViewsAfterOrientation:(UIDeviceOrientation) orientation;

@property float leftViewControllerWidth;
@property float rightViewControllerWidth;

@property UIButton* selectedBottomItem;
- (void)resetPreviousState;

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;
+ (void)resetInstance;
- (void)hideBottomBar;
- (void)showBottomBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintBottomBarHeight;
@property BOOL isBottomBarEnable;
@end
