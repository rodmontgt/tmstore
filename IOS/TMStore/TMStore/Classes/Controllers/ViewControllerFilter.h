//
//  ViewControllerFilter.h
//  TMStore
//
//  Created by Twist Mobile on 01/12/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTRangeSlider.h"
#import "UserFilter.h"
#import "CategoryInfo.h"
#import "MARKRangeSlider.h"
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <GooglePlaces/GooglePlaces.h>


@interface ViewControllerFilter : UIViewController<
TTRangeSliderDelegate,
UITableViewDelegate,
UITableViewDataSource,
CLLocationManagerDelegate,
UISearchBarDelegate,
GMSAutocompleteViewControllerDelegate,
GMSAutocompleteResultsViewControllerDelegate,
GMSAutocompleteTableDataSourceDelegate,
UISearchDisplayDelegate,
UITextFieldDelegate
> {
    UIButton *customBackButton;
    UIButton *customApplyButton;
    UIColor *SelectedCellBGColor;
    UIColor *NotSelectedCellBGColor;
    NSString *buttonType;
    UserFilter *userFilter;
    float MaxPriceWithID;
    float MinPriceWithID;
    
    float taxAmountMin;
    float taxAmountMax;
    UIView *RightviewSlider;
}
@property UILabel* labelViewHeading;
@property (weak, nonatomic) IBOutlet UINavigationItem *currentItemHeading;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *previousItemHeading;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *ApplyItemHeading;

@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UIView *lineView;
@property (strong, nonatomic) IBOutlet UIView *Testview;
@property (nonatomic,retain) UIButton *btnRedio;

@property (nonatomic,retain) UIButton *btnStockCheck;
@property (nonatomic,retain) UIButton *btnDiscount;

@property (nonatomic, strong) MARKRangeSlider *rangeSlider;
@property (nonatomic, strong) UILabel *labelMinPrice;
@property (nonatomic, strong) UILabel *labelMaxPrice;

@property id parentVC;
@property id parentCell;
@property NSMutableArray* chkBoxSort;
@property NSMutableArray *arrayleft;
@property NSMutableArray *arrayRightViews;
@property NSMutableArray *arraySortTitalList;
@property NSMutableArray *arraySortTag;
@property NSMutableArray *arrayStockList;
@property NSMutableArray *arrayDiscountList;
@property NSMutableArray *arrayAttributOptions;
@property NSMutableArray *arrayAttribut;
@property NSMutableArray *StrAttribut;
@property NSMutableString *Detailstring;
@property TM_FilterAttribute* currentFilterAttribute;

@property (weak, nonatomic) IBOutlet UIScrollView *RightScrollvieww;

@property TTRangeSlider *rangeSliderCurrency;
@property CategoryInfo* cInfo;
@property id previousVC;
@property int index;
@property (weak, nonatomic) IBOutlet UITableView *tableData;
- (void)setDataInView:(CategoryInfo*)cInfo categoryidwithiteam:(NSMutableArray*)categoryidwithiteam MaxPrice: (float)MaxPrice Minprice :(float)Minprice previousVC:(id)previousV;

#pragma Google Place API
@property (nonatomic, retain) CLLocationManager *locationManager;
-(void)clearFilters;
@property UIView *fadeView;
@end
