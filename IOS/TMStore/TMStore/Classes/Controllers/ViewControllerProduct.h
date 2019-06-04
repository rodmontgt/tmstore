//
//  ViewControllerProduct.h
//  eMobileApp
//
//  Created by Rishabh Jain on 16/11/15.
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
#import "ViewControllerCategories.h"
#import "NIDropDown.h"
#import "Attribute.h"
#import "MRProgress.h"
#import "CNPPopupController.h"
#import "PincodeSetting.h"
#import "Wishlist.h"
#import <CZPicker/CZPicker.h>
#import "DateTimeSlot.h"
#import "TimeSlot.h"
#import "FPPopoverController.h"
#import "TM_ProductDeliveryDate.h"
#if ENABLE_SELLER_LOC_PRODUCT_PAGE
#import <GoogleMaps/GoogleMaps.h>
#import <CoreLocation/CoreLocation.h>
#import <GooglePlaces/GooglePlaces.h>
#endif


@interface SelectionView: UIView <NIDropDownDelegate>
@property NIDropDown *dropdownView;
@property NSMutableArray* attributeArray;
@property UILabel* label;
@property UIButton* button;
@property UIView* pView;
@property Attribute* attribute;
@property NSString* attributeSelectedValue;
@property int viewId;
@property ProductInfo* pInfo;
@property NSMutableArray* selectedVariationAttibutes;
@property Variation *selectedVariation;
@property id vcProduct;
@property UIScrollView* scrollViewLinearButton;
- (id)init;
- (void)loadView:(NSMutableArray*)dataArray;
- (void)selectClicked:(id)sender;
- (void)selectClickedTemp:(id)button;
- (void)setParentViewForDropDownView:(UIView*)pView;
- (void)itemClicked:(int)clickedItemId;
@end

enum HORIZONTAL_VIEWS_PRODUCT_SCREEN{
    _kMIXNMATCH,
    _kBUNDLE,
    _kRelatedProduct,
    _kUpSell,
    _kTotalViewsProductScreen
};

@interface ViewControllerProduct: UIViewController <
  UICollectionViewDataSource
, UICollectionViewDelegateFlowLayout
, UIDocumentInteractionControllerDelegate
, UIScrollViewDelegate
, UITextFieldDelegate
, CZPickerViewDataSource
, FPPopoverControllerDelegate
, CZPickerViewDelegate
, NIDropDownDelegate
, UITableViewDataSource
, UITableViewDelegate
#if ENABLE_SELLER_LOC_PRODUCT_PAGE
, GMSMapViewDelegate
, CLLocationManagerDelegate
, UIGestureRecognizerDelegate
#endif
> {
    IBOutlet UIScrollView *_scrollView;
    PagedImageScrollView *_bannerScrollView;
    LayoutProperties *_propBanner;
    LayoutProperties *_propBannerProduct;
#if ENABLE_SELLER_LOC_PRODUCT_PAGE
    CLLocationManager *locationManager;
    CLLocation *myLocation;
    NSString *loc;
#endif
    
    NSString *_viewKey[_kTotalViewsProductScreen];
    NSString *_viewUserDefinedHeaderString[_kTotalViewsProductScreen];
    UILabel *_viewUserDefinedHeader[_kTotalViewsProductScreen];
    LayoutProperties *_propCollectionView[_kTotalViewsProductScreen];
    UICollectionView *_viewUserDefined[_kTotalViewsProductScreen];
    BOOL _isViewUserDefinedEnable[_kTotalViewsProductScreen];
}
- (UICollectionView*)getViewUserDefined:(int)viewId;
- (void)resetMainScrollView;
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UIView *lineView;
@property (weak, nonatomic) IBOutlet UINavigationItem *currentItemHeading;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *previousItemHeading;

- (IBAction)barButtonBackPressed:(id)sender;

@property int drillingLevel;
@property DataPass* currentItem;
@property DataPass* previousItem;
@property Wishlist *Wishlist;
- (void)loadData:(DataPass *)currentItem previousItem:(DataPass *)previousItem drillingLevel:(int)drillingLevel variationId:(int)variationId;
- (void)loadData:(DataPass *)currentItem previousItem:(DataPass *)previousItem drillingLevel:(int)drillingLevel;

- (SelectionView *)createSelectionView:(int)viewId isFullLength:(BOOL)isFullLength origin:(CGPoint)origin viewHeight:(float)viewHeight;

@property NSMutableArray* selectionViews;

@property UIImageView* productImgView;

@property Variation *selectedVariation;
@property NSMutableArray* selectedVariationAttibutes;//VariationAttribute Array

@property UILabel* labelOldPrice;
@property UILabel* labelNewPrice;
@property UIButton *buttonCart;
@property UIButton *buttonWishlist;
@property UIButton *buttonBuy;
@property UIButton *buttonCall;

@property UIButton *buttonOpinion;
@property UIButton *buttonWhatsAppShare;
@property UIButton *buttonLike;
@property UIButton *buttonDislike;

@property UIButton *buttonWaitList;
@property UILabel *labelWaitList;
@property UILabel *labelRewardPoints;

@property NSString* strCollectionView1;
@property NSString* strCollectionView2;
@property NSString* strCollectionView3;

@property NSString* strCollectionMixNMatch;
@property NSString* strCollectionBundle;

@property UIView* sellerView;
@property UIView* productImageAndCostView;
@property UIView* productImageView;
@property UIView* productCostView;
@property UIView* productPropertiesView;
@property UIView* productDetailView;
@property UIView* productAttributesView;
@property UIView* productReviewView;
@property UIView* productLoadingView;
@property UIView *ProductRelatedview;
@property UITableView *productExtraAttributesTable;


@property SelectionView* viewOpened;
@property UILabel* progressViewHeader;
//@property UIProgressView* progressView;
//@property float progressValue;
//@property MRProgressOverlayView* overlayAdded;
@property id parentVC;
@property id parentCell;
@property UILabel* labelViewHeading;
@property UIView* viewMainChildPopoverView;
@property PagedImageScrollView* zoomScrollView;
@property int zoomPageIndex;
@property BOOL zoomPageIsOpened;
@property UITapGestureRecognizer *tapToExit;


@property UIButton* groceryButtonAdd;
@property UIButton* groceryButtonSubstract;
@property UITextField* groceryTextField;

@property NSString* brandName;
@property NSString* brandLink;
@property NSString* stringPerUnit;

@property UIButton* labelBrand;
@property UIButton* labelBrandHeader;

@property UIView* viewForPurchaseGrocery;
@property UIView* viewForMinQuantity;


@property ZipSetting* zipSetting;
@property UIView* zipSettingView;
@property UILabel* zipSettingHeaderLabel;
@property UILabel* zipSettingDescLabel;
@property UIButton* zipSettingCheckButton;
@property UIButton* zipSettingChangeButton;
@property UITextField* zipSettingTextField;
@property int zipSettingState;


@property float keyboardHeight;
@property double duration;
@property UIViewAnimationCurve curve;

@property UITextField* textFieldFirstResponder;
@property BOOL isRelatedProductLoaded;
@property NSMutableArray* bundleItems;
@property NSMutableArray* matchedItems;

@property CZPickerView* callConfirmationView;
@property CZPickerView* callNumberPickerView;


@property UIButton* buttonDateSelection;
@property UIButton* buttonTimeSelection;
@property UIButton* buttonDateSelectionDownArrow;
@property UIButton* buttonDateSelectionIcon;
@property UIButton* buttonTimeSelectionDownArrow;
@property UIButton* buttonTimeSelectionIcon;
@property NIDropDown* ddViewTimeSelection;
@property NSArray* timeSlotDataObjects;
//@property DateTimeSlot* selected_date_time_slot;
//@property TimeSlot* selected_time_slot;
@property TM_PRDD_Day* prdd_sDay;
@property TM_PRDD_Time* prdd_sTime;
@property NSString* prdd_sDateStr;
@property TM_PRDD* prdd;

@property BOOL show_vertical_layout_components;
@property BOOL show_external_product_layout;
#if ENABLE_SELLER_LOC_PRODUCT_PAGE
@property UIView* productMapView;
@property GMSMapView* mapView;
@property CLLocation *myLocation;
//@property UIImageView *pin;
#endif
@end
