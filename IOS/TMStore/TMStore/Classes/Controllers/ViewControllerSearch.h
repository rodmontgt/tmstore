//
//  ViewControllerSearch.h

//
//  Created by Rishabh Jain on 24/09/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Variables.h"
#import "ProductInfo.h"
#import "ViewControllerCategories.h"
#import "Utility.h"
#import "ViewControllerProduct.h"
#import "LayoutProperties.h"
#import "PagedImageScrollView.h"
#import "ViewControllerHome.h"
//#import "ViewControllerHomeDynamic.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "CategoryInfo.h"
#import "ProductImage.h"
#import "ViewControllerMain.h"
#import "CCollectionViewCell.h"
#if ENABLE_AUTOCOMPLETE_GEOLOCATION_SEARCH
#import <GoogleMaps/GoogleMaps.h>
@import GooglePlaces;
#endif


//#if ENABLE_CATEGORY_IN_SEARCH_SCREEN
#import "RATreeView.h"
#import "RADataObject.h"
#import "RATableViewCell.h"
//#endif
@interface ViewControllerSearch: UIViewController <
                                                    UISearchBarDelegate
                                                    ,UICollectionViewDataSource
                                                    ,UICollectionViewDelegateFlowLayout
#if ENABLE_AUTOCOMPLETE_GEOLOCATION_SEARCH
                                                    ,GMSAutocompleteViewControllerDelegate
#endif
                                                >
{
    IBOutlet UIScrollView *_scrollView;
    IBOutlet UILabel *labelNoResultFound;
    NSString *_viewKey[_kTotalViewsHomeScreen];
    NSString *_viewUserDefinedHeaderString[_kTotalViewsHomeScreen];
    UILabel *_viewUserDefinedHeader[_kTotalViewsHomeScreen];
    LayoutProperties *_propCollectionView[_kTotalViewsHomeScreen];
    UICollectionView *_viewUserDefined[_kTotalViewsHomeScreen];
    BOOL _isViewUserDefinedEnable[_kTotalViewsHomeScreen];
#if ENABLE_AUTOCOMPLETE_GEOLOCATION_SEARCH
    GMSAutocompleteResultsViewController *_resultsViewController;
    UISearchController *_searchController;
#endif
}
- (void)resetMainScrollView;

@property int drillingLevel;
@property DataPass* currentItem;
@property DataPass* previousItem;
@property UITapGestureRecognizer *singleTap;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property NSString* strCollectionView1;
@property NSString* strCollectionView2;
@property NSString* strCollectionView3;

- (void)newSearchResults:(NSNotification*)notification;
@property UIActivityIndicatorView* spinnerView;
@property NSMutableArray* previousArray;
- (void)backFromProductScreen:(id)cell;

//#if ENABLE_CATEGORY_IN_SEARCH_SCREEN
@property UIView* categoryView;
@property float gap;
@property float rowH;
//#endif
@end
