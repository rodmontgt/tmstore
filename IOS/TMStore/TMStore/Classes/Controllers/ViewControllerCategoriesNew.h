//
//  ViewControllerCategoriesNew.h
//  eMobileApp
//
//  Created by Rishabh Jain on 09/11/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LayoutProperties.h"
#import "PagedImageScrollView.h"
#import "ViewControllerHome.h"
//#import "ViewControllerHomeDynamic.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "CategoryInfo.h"
#import "ProductInfo.h"
#import "ProductImage.h"
#import "ViewControllerMain.h"
#import "CCollectionViewCell.h"
#import "ViewFilter.h"
#import "CHTCollectionViewWaterfallLayout.h"
#import "Cart.h"
#import "TM_ProductFilter.h"
#import "UserFilter.h"
#import "CNPPopupController.h"
#import "ViewControllerCategories.h"
//@interface DataPass: NSObject
//
//@property int itemId;
//@property BOOL isCategory;
//@property BOOL isProduct;
//@property BOOL hasChildCategory;
//@property int childCount;
//@property CategoryInfo* cInfo;
//@property ProductInfo* pInfo;
//@property int variationId;
//@property int variationIndex;
//@property Cart* cart;
//- (id)init;
//
//@end


@interface ViewControllerCategoriesNew : UIViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout , UIScrollViewDelegate, CHTCollectionViewDelegateWaterfallLayout,UITabBarDelegate> {
    UserFilter *_userFilter;
    IBOutlet UIScrollView *_scrollView;
    PagedImageScrollView *_bannerScrollView;
    LayoutProperties *_propBanner;
    LayoutProperties *_propBannerProduct;
    
    NSString *_viewKey[_kTotalViewsHomeScreen];
    NSString *_viewUserDefinedHeaderString[_kTotalViewsHomeScreen];
    UILabel *_viewUserDefinedHeader[_kTotalViewsHomeScreen];
    LayoutProperties *_propCollectionView[_kTotalViewsHomeScreen];
    
    BOOL _isViewUserDefinedEnable[_kTotalViewsHomeScreen];
    BOOL isAllFilterLoaded;
    NSMutableArray* trendingBannerProducts;
    NSMutableArray *filterAttributes;
    float MaxPriceWithID;
    float MinPriceWithID;
    int refreshBannerCount;
    
@public
    UICollectionView *_viewUserDefined[_kTotalViewsHomeScreen];
}

- (void)resetMainScrollView;

@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UIView *lineView;
@property (weak, nonatomic) IBOutlet UINavigationItem *currentItemHeading;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *previousItemHeading;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextItemHeading;
- (IBAction)filterButtonPressed:(id)sender;
- (IBAction)barButtonBackPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *mainView;

@property int drillingLevel;
@property DataPass* currentItem;
@property DataPass* previousItem;
- (void)loadData:(DataPass *)currentItem previousItem:(DataPass *)previousItem drillingLevel:(int)drillingLevel;
@property NSString* strCollectionView1;
@property NSString* strCollectionView2;
@property NSString* strCollectionView3;
@property BOOL pageLoading;
@property UIView *filterView;
@property int pageNumber;
//@property UIImageView* spinnerView;
@property UIActivityIndicatorView* spinnerView;
@property UILabel* labelViewHeading;

@property int scrollViewBaseOffsetLast;
@property int scrollViewChildOffsetLast;
@property int scrollViewBaseOffsetDefault;
@property int scrollViewChildOffsetDefault;
@property UIScrollView* scrollViewBase;
@property UICollectionView* scrollViewChild;
@property int setScrollView;
@property BOOL permanentScrollSet;
@property BOOL filter_prices_loading;
@property BOOL filter_attribs_loading;

@property UIButton* buttonFilter;
@property UILabel* labelFilter;
@property UIView* viewFilter;
@property BOOL showFilterdResult;
@property ViewFilter* viewFilterMain;
@property UILabel *noProducts;
- (void)btnFilterClicked:(UIButton*)button;
- (void)toggleFilterViewSize;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)backFromProductScreen:(id)cell;
- (void)reloadWithFilter:(NSMutableArray*)array appliedUserFilter:(UserFilter*) userFilterUser;


@property CNPPopupController* popupShowMore;
@property id parentVC;

- (void)setFilterVisibilityNew:(BOOL)value;
@end
