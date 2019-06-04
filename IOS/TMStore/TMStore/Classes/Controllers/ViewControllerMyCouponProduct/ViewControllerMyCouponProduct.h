//
//  ViewControllerMyCouponProduct.h
//  TMStore
//
//  Created by Twist Mobile on 21/01/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Coupon.h"
#import "Variables.h"
#import "LayoutProperties.h"
#import "SWRevealViewController.h"
#import "ViewControllerBottomBar.h"
#import "ViewControllerTopBar.h"



enum HORIZONTAL_VIEWS_MYCOUPON_SCREEN {
    _kProductid_Cell,
    _kCategoryid_Cell,
    _kExclude_Productid_Cell,
    _kExclude_Categoryid_Cell,

    _kTotalViewsCouponScreen
};

@interface ViewControllerMyCouponProduct : UIViewController<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UISearchBarDelegate,UICollectionViewDelegate> {
    UIButton *customBackButton;
    UIButton *customApplyButton;
    IBOutlet UIScrollView *_scrollView;
    
    NSString *_viewKey[_kTotalViewsCouponScreen];
    NSString *_viewUserDefinedHeaderString[_kTotalViewsCouponScreen];
    UILabel *_viewUserDefinedHeader[_kTotalViewsCouponScreen];
    LayoutProperties *_propCollectionView[_kTotalViewsCouponScreen];
    UICollectionView *_viewUserDefined[_kTotalViewsCouponScreen];
    BOOL _isViewUserDefinedEnable[_kTotalViewsCouponScreen];
    NSMutableArray *_viewsAdded;
}
@property UILabel* labelViewHeading;
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UIView *lineView;
@property (weak, nonatomic) IBOutlet UINavigationItem *currentItemHeading;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *previousItemHeading;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *ApplyItemHeading;
@property (weak, nonatomic) ViewControllerTopBar *vcTopBar;
@property (weak, nonatomic) ViewControllerBottomBar *vcBottomBar;
@property (weak, nonatomic) UIViewController *vcCenterTop;
@property (weak, nonatomic) SWRevealViewController *revealController;
-(void)CouponData:(Coupon*)couponData;

@property NSString* strCollectionView1;
@property NSString* strCollectionView2;
@property NSString* strCollectionView3;

@property Coupon* coupon;

@end
