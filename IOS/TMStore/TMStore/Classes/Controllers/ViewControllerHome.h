//
//  ViewControllerHome.h

//
//  Created by Rishabh Jain on 24/09/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Variables.h"
#import "PagedImageScrollView.h"
#import "LayoutProperties.h"
#import "OLEContainerScrollView.h"
#if __IPHONE_OS_VERSION_MAX_ALLOWED > 90000
#import <ReplayKit/ReplayKit.h>
#endif
enum VIEWS{
    _kTopView,
    _kCategoryBasic,
    _kShowAllItems,
    _kTrending,
    _kMaxSold,
    _kNew,
    _kDiscount,
    _kUserDefined1,
    _kUserDefined2,
    _kUserDefined3,
    _kUserDefined4,
    _kUserDefined5,
    _kTotalViewsHomeScreen
};
@interface ViewControllerHome: UIViewController <
UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
#if __IPHONE_OS_VERSION_MAX_ALLOWED > 90000
, RPPreviewViewControllerDelegate
#endif
>
{
    IBOutlet UIScrollView *_scrollView;
    UITableView *_tableView;
    PagedImageScrollView *_bannerScrollView;
    LayoutProperties *_propBanner;
    NSString *_viewKey[_kTotalViewsHomeScreen];
    NSString *_viewUserDefinedHeaderString[_kTotalViewsHomeScreen];
    UILabel *_viewUserDefinedHeader[_kTotalViewsHomeScreen];
    LayoutProperties *_propCollectionView[_kTotalViewsHomeScreen];
    UICollectionView *_viewUserDefined[_kTotalViewsHomeScreen];
    BOOL _isViewUserDefinedEnable[_kTotalViewsHomeScreen];
    NSMutableArray* trendingBannerProducts;
    int refreshBannerCount;
}
- (void)resetMainScrollView;
@property NSString* strCollectionView1;
@property NSString* strCollectionView2;
@property NSString* strCollectionView3;
- (void)backFromProductScreen:(id)cell;
@property UIView* viewTopExtraItems;
@property UISearchBar *viewTopExtraItemsSearchBar;
+ (ViewControllerHome*)getInstance;
+ (void)resetInstance;
- (void)clickOnProduct:(id)productClicked currentItemData:(id)currentItemData cell:(id)cell;
- (id)openProductVC;
- (void)loadProductVC:(id)vcProduct productClicked:(id)productClicked;
@property UIActivityIndicatorView* spinnerView;
@property BOOL isHomeScreenPresented;
@property BOOL isAdTimeCompleted;
@property int adTime;
@property NSTimer* adTimerDelay;
@property NSTimer* adTimerInterval;
#pragma mark - 
#pragma mark - CONSENT SCREEN
@property UIView *csView;
@property UIScrollView *csViewScroll;
@property NSMutableArray* csLayouts;
#pragma mark -
@end
