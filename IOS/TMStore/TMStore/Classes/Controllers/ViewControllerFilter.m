//
//  ViewControllerFilter.m
//  TMStore
//
//  Created by Twist Mobile on 01/12/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import "ViewControllerFilter.h"
#import "Utility.h"
#import "Attribute.h"
#import "ViewControllerCategories.h"
#import "TM_FilterAttributeOption.h"
#import "Attribute.h"
#import "UIAlertView+NSCookbook.h"
#import "DataManager.h"
#import "Variables.h"
#import "TM_ProductFilter.h"
#import "AnalyticsHelper.h"
#import "TM_Tax.h"
#import "CommonInfo.h"
#import <GooglePlaces/GooglePlaces.h>
#import "FilterLocationView.h"
#define RANGE_SLIDER_NEW_UPDATE 1

static CLLocation *myLoc;
static NSString *myAddressStr;
static CLLocation *selectedLoc;
static NSString *selectedAddressStr;
static BOOL myLocEnable;
static NSString *myRangeUnit;
static NSString *myRangeValue;


@interface ViewControllerFilter ()
{
#pragma mark - GMSAutocompleteViewController
    GMSAutocompleteResultsViewController *resultsViewController;
    UISearchController *searchController;
    GMSAutocompleteTableDataSource *tableDataSource;
    UISearchDisplayController *searchDisplayController;
    UISearchBar *searchBar;
    FilterLocationView*locationView;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
}
@end

@implementation ViewControllerFilter

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [Utility getUIColor:kUIColorThemeFont], NSForegroundColorAttributeName, [Utility getUIFont:kUIFontType24 isBold:false], NSFontAttributeName, nil]];
    [self.currentItemHeading setTitle:@"   "];
    
    _labelViewHeading = [[UILabel alloc] init] ;
    [_labelViewHeading setFrame:CGRectMake(0, 20, [[MyDevice sharedManager] screenSize].width, _navigationBar.frame.size.height)];
    [_labelViewHeading setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [_labelViewHeading setUIFont:kUIFontType24 isBold:false];
    [_labelViewHeading setTextColor:[Utility getUIColor:kUIColorThemeFont]];
    [_labelViewHeading setTextAlignment:NSTextAlignmentCenter];
    [_labelViewHeading setText:[NSString stringWithFormat:@"%@",Localize(@"title_filter")]];
    [self.view addSubview:_labelViewHeading];
    
    [_navigationBar setClipsToBounds:false];
    [_lineView setBackgroundColor:[Utility getUIColor:kUIColorBorder]];
    //[_scrollView setBackgroundColor:[Utility getUIColor:kUIColorBgTheme]];
    [self.view setBackgroundColor:[Utility getUIColor:kUIColorBgHeader]];
    [_navigationBar setBarTintColor:[Utility getUIColor:kUIColorBgHeader]];
    customBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [customBackButton setImage:[[UIImage imageNamed:@"img_arrow_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [customBackButton addTarget:self action:@selector(barButtonBackPressed:)forControlEvents:UIControlEventTouchUpInside];
    [customBackButton setTitle:[NSString stringWithFormat:@"  %@  ", Localize(@"i_back")] forState:UIControlStateNormal];
    [customBackButton setTintColor:[Utility getUIColor:kUIColorThemeFont]];
    [customBackButton setTitleColor:[Utility getUIColor:kUIColorThemeFont] forState:UIControlStateNormal];
    [customBackButton.titleLabel setUIFont:kUIFontType18 isBold:false];
    [customBackButton sizeToFit];
    [_previousItemHeading setCustomView:customBackButton];
    [_previousItemHeading setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[Utility getUIColor:kUIColorThemeFont], NSForegroundColorAttributeName, [Utility getUIFont:kUIFontType18 isBold:false], NSFontAttributeName, nil] forState:UIControlStateNormal];
    
    customApplyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    // [customApplyButton setImage:[[UIImage imageNamed:@"img_arrow_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [customApplyButton addTarget:self action:@selector(barButtonApplyPressed:)forControlEvents:UIControlEventTouchUpInside];
    [customApplyButton setTitle:[NSString stringWithFormat:@"  %@  ", Localize(@"apply")] forState:UIControlStateNormal];
    [customApplyButton setTintColor:[Utility getUIColor:kUIColorThemeFont]];
    [customApplyButton setTitleColor:[Utility getUIColor:kUIColorThemeFont] forState:UIControlStateNormal];
    [customApplyButton.titleLabel setUIFont:kUIFontType18 isBold:false];
    [customApplyButton sizeToFit];
    [_ApplyItemHeading setCustomView:customApplyButton];
    [_ApplyItemHeading setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[Utility getUIColor:kUIColorThemeFont], NSForegroundColorAttributeName, [Utility getUIFont:kUIFontType18 isBold:false], NSFontAttributeName, nil] forState:UIControlStateNormal];
    
    SelectedCellBGColor = [UIColor clearColor];
    NotSelectedCellBGColor = [UIColor colorWithRed:245.00/255.00 green:245.00/255.00 blue:245.00/255.00 alpha:1.0];
    self.automaticallyAdjustsScrollViewInsets = YES;
    
#pragma mark - GMSAutocompleteViewController
    
    GMSAutocompleteViewController *acController = [[GMSAutocompleteViewController alloc] init];
    acController.delegate = self;
    [self presentViewController:acController animated:YES completion:nil];
    
//    resultsViewController = [[GMSAutocompleteResultsViewController alloc] init];
//    resultsViewController.delegate = self;
//    
//    tableDataSource = [[GMSAutocompleteTableDataSource alloc] init];
//    tableDataSource.delegate = self;
//    
//    searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:locationView.locationSearch contentsController:self];
//    searchDisplayController.searchResultsDataSource = tableDataSource;
//    searchDisplayController.searchResultsDelegate = tableDataSource;
//    searchDisplayController.delegate = self;

#pragma Current Location
//    geocoder = [[CLGeocoder alloc] init];
//    if (_locationManager == nil)
//    {
//        _locationManager = [[CLLocationManager alloc] init];
//        _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
//        _locationManager.delegate = self;
//        [_locationManager requestAlwaysAuthorization];
//    }
//    [_locationManager startUpdatingLocation];
    [self enableLocationService];

}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if ENABLE_FIREBASE_TAG_MANAGER
    [[AnalyticsHelper sharedInstance] registerVisitScreenEvent:@"Filter Screen"];
#endif
//#if ENABLE_FILTER_LOCATION
//    if([[Addons sharedManager] enable_location_in_filters]){
//    userFilter.locationFilter_myLoc_lat = myLoc.coordinate.latitude;
//    userFilter.locationFilter_myLoc_lng = myLoc.coordinate.longitude;
//    locationView.locationSearch.text = myAddressStr;
//    }
//#endif
    
    if (locationView) {
        userFilter.locationFilter_myLoc_lat = myLoc.coordinate.latitude;
        userFilter.locationFilter_myLoc_lng = myLoc.coordinate.longitude;
        locationView.locationSearch.text = myAddressStr;
    }
//    userFilter.locationFilter_myLoc_lat = 0;
//    userFilter.locationFilter_myLoc_lng = 0;
//    locationView.locationSearch.text = @"";
}
- (void)setDataInView:(CategoryInfo*)cInfo categoryidwithiteam:(NSMutableArray*)categoryidwithiteam MaxPrice: (float)MaxPrice Minprice :(float)Minprice previousVC:(id)previousVC{
    self.cInfo = cInfo;
    self.previousVC = previousVC;
    userFilter = [UserFilter sharedInstance];
    self.chkBoxSort = [[NSMutableArray alloc]init];
    self.arrayRightViews = [[NSMutableArray alloc] init];
    self.Detailstring = [[NSMutableString alloc]init];
    NSString *strsort_by= [NSString stringWithFormat:@"%@",Localize(@"sort_by")];
    NSString *strprice_range= [NSString stringWithFormat:@"%@",Localize(@"price_range")];
    NSString *strstock_check= [NSString stringWithFormat:@"%@",Localize(@"stock_check")];
    NSString *strdiscount= [NSString stringWithFormat:@"%@",Localize(@"discount")];
    self.arrayleft = [[NSMutableArray alloc] init];
    [self.arrayleft addObject:strsort_by];
    [self.arrayleft addObject:strprice_range];
    [self.arrayleft addObject:strstock_check];
    [self.arrayleft addObject:strdiscount];
    
#if ENABLE_FILTER_LOCATION
    if([[Addons sharedManager] enable_location_in_filters]){
        NSString *strLocationFiler = [NSString stringWithFormat:@"%@",Localize(@"filter_location")];
        [self.arrayleft addObject:strLocationFiler];
    }
#endif
    RLOG(@"Array Left  %@",_arrayleft);
    RLOG(@"array left %lu",(unsigned long)_arrayleft.count);
    
    NSString *strsort_fresh_arrival= [NSString stringWithFormat:@"%@",Localize(@"sort_fresh_arrival")];
    NSString *strsort_featured= [NSString stringWithFormat:@"%@",Localize(@"sort_featured")];
    NSString *strsort_user_rating= [NSString stringWithFormat:@"%@",Localize(@"sort_user_rating")];
    NSString *strsort_price_high_to_low= [NSString stringWithFormat:@"%@",Localize(@"sort_price_high_to_low")];
    NSString *strsort_price_low_to_high= [NSString stringWithFormat:@"%@",Localize(@"sort_price_low_to_high")];
    NSString *strsort_popularity= [NSString stringWithFormat:@"%@",Localize(@"sort_popularity")];
    
    _arraySortTitalList = [[NSMutableArray alloc]initWithObjects:strsort_fresh_arrival,strsort_featured,strsort_user_rating,strsort_price_high_to_low,strsort_price_low_to_high,strsort_popularity,nil];
    _arraySortTag = [[NSMutableArray alloc]initWithObjects:@"0",@"1",@"3",@"4",@"5",@"6",nil];
    
    NSString *strexclude_out_of_stock= [NSString stringWithFormat:@"%@",Localize(@"exclude_out_of_stock")];
    NSString *strshow_discounted_only= [NSString stringWithFormat:@"%@",Localize(@"show_discounted_only")];
    
    _arrayStockList = [[NSMutableArray alloc]initWithObjects:strexclude_out_of_stock, nil];
    _arrayDiscountList = [[NSMutableArray alloc]initWithObjects:strshow_discounted_only, nil];
    
    [_arrayleft addObjectsFromArray:categoryidwithiteam];
    NSLog(@"categoryidwithiteam:%@",categoryidwithiteam);
    
    NSString *strclear_filters= [NSString stringWithFormat:@"%@",Localize(@"clear_filters")];
    [_arrayleft addObject:strclear_filters];
    for (NSString* str in self.arrayleft) {
        UIView* rightView = [[UIView alloc] init];
        [self.RightScrollvieww addSubview:rightView];
        [self.arrayRightViews addObject:rightView];
    }
    [self reloadTable];
    self.automaticallyAdjustsScrollViewInsets = YES;
    MaxPriceWithID = (MaxPrice);
    MinPriceWithID = (Minprice);
//#if RANGE_SLIDER_NEW_UPDATE
//    MaxPriceWithID = ceilf(MaxPrice);
//    MinPriceWithID = floorf(Minprice);
//#endif
    
    //showing filter prices including tax approx.
    taxAmountMin = 0.0f;
    taxAmountMax = 0.0f;
    CommonInfo* commonInfo = [CommonInfo sharedManager];
    BOOL addTaxToProductPrice = commonInfo->_addTaxToProductPrice;
    Addons* addons = [Addons sharedManager];
    BOOL show_filter_price_with_tax = addons.show_filter_price_with_tax;
    if (addTaxToProductPrice && show_filter_price_with_tax) {
        NSArray* children = [ProductInfo getAllForCategory:self.cInfo];
        if(children && [children count] > 0){
            ProductInfo* pInfo = [children objectAtIndex:0];
            taxAmountMin = [TM_TaxApplied calculateTaxProduct:MinPriceWithID productTaxClass:pInfo._tax_class isProductTaxable:pInfo._taxable isShippingNecessary:false];
            taxAmountMax = [TM_TaxApplied calculateTaxProduct:MaxPriceWithID productTaxClass:pInfo._tax_class isProductTaxable:pInfo._taxable isShippingNecessary:false];
        }
    }
    
    NSIndexPath *firstRowPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableData selectRowAtIndexPath:firstRowPath animated:NO scrollPosition: UITableViewScrollPositionNone];
    [self tableView:self.tableData didSelectRowAtIndexPath:firstRowPath];
    self.tableData.contentInset = UIEdgeInsetsMake(-36, 0, 0, 0);
}

#pragma mark - UITableview Delegate Methord

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrayleft.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil){
        //cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    int maxCellIndex = 3;
    if([[Addons sharedManager] enable_location_in_filters]){
        maxCellIndex = 4;
    }
    if (indexPath.row <= maxCellIndex) {
        cell.textLabel.text = [_arrayleft objectAtIndex:indexPath.row];
        if (userFilter.modifiedMaxORminPrice) {
            if (indexPath.row == 0) {
                //                cell.detailTextLabel.text= [_arraySortTitalList objectAtIndex:userFilter.sort_type];
                switch (userFilter.sort_type) {
                    case 0:
                        cell.detailTextLabel.text= [NSString stringWithFormat:@"%@",Localize(@"sort_fresh_arrival")];
                        break;
                    case 1:
                        cell.detailTextLabel.text= [NSString stringWithFormat:@"%@",Localize(@"price_range")];
                        break;
                    case 3:
                        cell.detailTextLabel.text= [NSString stringWithFormat:@"%@",Localize(@"sort_user_rating")];
                        break;
                    case 4:
                        cell.detailTextLabel.text= [NSString stringWithFormat:@"%@",Localize(@"sort_price_high_to_low")];
                        break;
                    case 5:
                        cell.detailTextLabel.text= [NSString stringWithFormat:@"%@",Localize(@"sort_price_low_to_high")];
                        break;
                    case 6:
                        cell.detailTextLabel.text= [NSString stringWithFormat:@"%@",Localize(@"sort_popularity")];
                        break;
                    default:
                        break;
                }
            }
            else if (indexPath.row == 1) {
                cell.detailTextLabel.text =[NSString stringWithFormat:@"%0.2f   %0.2f",userFilter.minPrice + taxAmountMin, userFilter.maxPrice + taxAmountMax];
            }
            else if (indexPath.row == 2 && userFilter.chkStock){
                [self showDetailStringsForStock:cell indexPath:indexPath tableView:_tableData];
            }
            else if (indexPath.row == 3 && userFilter.on_sale){
                [self showDetailStringsForDicount:cell indexPath:indexPath tableView:_tableData];
            }
            else if (indexPath.row == 4){
//                [self showDetailStringsForDicount:cell indexPath:indexPath tableView:_tableData];
            }
            else{
                cell.detailTextLabel.text = @"";
            }
        }else{
            cell.detailTextLabel.text = @"";
        }
    }
       NSInteger totalRow = [tableView numberOfRowsInSection:indexPath.section];//first get total rows in that section by current indexPath.
//    [_arrayleft removeObjectAtIndex:totalRow];
    RLOG(@"totalRow  %ld",(long)totalRow);
    RLOG(@"indepath row  %ld",(long)indexPath.row);
    if(indexPath.row == (long)totalRow-1){
        cell.textLabel.text = [_arrayleft objectAtIndex:indexPath.row];
        cell.detailTextLabel.text =@"";
    }
    if (!(indexPath.row <= maxCellIndex) && !(indexPath.row == (long)totalRow-1)) {
        TM_FilterAttribute *filterAttribute = [_arrayleft objectAtIndex:indexPath.row];
        _arrayAttributOptions = [filterAttribute getXYZOptions];
        cell.textLabel.text = filterAttribute.attribute;
        [cell.layer setValue:filterAttribute forKey:@"FAOBJ"];
        [self showDetailStringsForAttribut:cell indexPath:indexPath tableView:_tableData];
    }
    [cell.textLabel setUIFont:kUIFontType16 isBold:false];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setNeedsLayout];
    [cell.detailTextLabel setTextColor:[Utility getUIColor:999]];
    [cell.detailTextLabel sizeToFitUI];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self reloadTable];
    [[tableView cellForRowAtIndexPath:indexPath] setBackgroundColor:SelectedCellBGColor];
    int i = (int)(indexPath.row);
    if([[Addons sharedManager] enable_location_in_filters]) {
        if (i != 4) {
            if (locationView) {
                [locationView setHidden:true];
            }
        } else {
            if (locationView) {
                [locationView setHidden:false];
            }
        }
    }
    
    UIView* senderView = [_arrayRightViews objectAtIndex:i];
    for (UIView* view in _arrayRightViews) {
        if(view != senderView){
            [view setHidden:YES];
        }else{
            [view setHidden:NO];
        }
    }
    _index =(int)indexPath.row;
    
    NSInteger total =[tableView numberOfRowsInSection:indexPath.section];
    NSInteger lastindex = total - 1;
    if (i == (int)lastindex){
        [self clearFilters];
    }else {
        switch (i) {
            case 0:
                [self createRightview:nil array:_arraySortTitalList type:@"buttonRedio" color:[UIColor clearColor] viewIndex:indexPath.row btnSelectorNOT:nil];
                break;
            case 1:
                [self createRangSlider:MinPriceWithID maxmum:MaxPriceWithID viewIndex:i];
                break;
            case 2:
                [self createRightview:nil array:_arrayStockList type:@"buttonOther" color:[UIColor clearColor] viewIndex:i btnSelectorNOT:[userFilter chkStock]];
                break;
            case 3:
                [self createRightview:nil array:_arrayDiscountList type:@"buttonOther" color:[UIColor clearColor] viewIndex:i btnSelectorNOT:[userFilter on_sale]];
                break;
            case 4:
                if([[Addons sharedManager] enable_location_in_filters]){
                    [self loadFilterLocationView];
                    [self initUserLocationData];
                    break;
                }
            default:{
                NSIndexPath *firstRowPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
                UITableViewCell *cell = [_tableData cellForRowAtIndexPath:firstRowPath];
                BOOL toUpdateNow =[self TableviewDidselectMethorAttributOptionsResponce:indexPath.row];
                //[self showDetailStrings:cell indexPath:indexPath tableView:tableView];
                if (toUpdateNow) {
                    [self createRightview:nil array:nil type:@"buttonOther" color:[UIColor clearColor] viewIndex:i btnSelectorNOT:nil];
                }
            }
                break;
        }
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [[MyDevice sharedManager] screenSize].height * 0.06f;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *currentSelectedIndexPath = [tableView indexPathForSelectedRow];
    if (currentSelectedIndexPath != nil)
    {
        [[tableView cellForRowAtIndexPath:currentSelectedIndexPath] setBackgroundColor:NotSelectedCellBGColor];
    }
    
    return indexPath;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (cell.isSelected == YES)
    {
        [cell setBackgroundColor:SelectedCellBGColor];
    }
    else
    {
        [cell setBackgroundColor:NotSelectedCellBGColor];
    }
}
//-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [[tableView cellForRowAtIndexPath:indexPath] setBackgroundColor:NotSelectedCellBGColor];
//}
-(void)reloadTable{
    if (self.tableData.delegate == nil) {
        self.tableData.delegate = self;
        self.tableData.dataSource = self;
        [self.tableData reloadData];
    }else{
        [self.tableData reloadData];
    }
}

#pragma mark - CreateViews

- (void)createRightview:(NSMutableDictionary *)arr array:(NSMutableArray*)array type:(NSString*)type color:(UIColor*)color viewIndex:(int)viewIndex btnSelectorNOT:(BOOL)btnSelectorNOT{
    float viewPosX = self.RightScrollvieww.frame.size.width * 0.00f;
    float viewPosY = self.RightScrollvieww.frame.size.width  * 0.03f;
    float viewWidth = [[MyDevice sharedManager] screenSize].width * 0.60f;
    float viewHeight = [[MyDevice sharedManager] screenSize].height - viewPosY;
    
    UIView *Rightview = [_arrayRightViews objectAtIndex:viewIndex];
    Rightview.frame = CGRectMake(viewPosX, viewPosY, viewWidth, viewHeight);
    Rightview.backgroundColor = [UIColor clearColor];
    
    for (UIView* v in [Rightview subviews]) {
        [v removeFromSuperview];
    }
    float itemPosX = Rightview.frame.size.width * 0.03f;
    float itemPosY = Rightview.frame.size.width * 0.01f;
    float gap = Rightview.frame.size.width * 0.01f;
    float itemWidth = viewWidth - itemPosX * 2;
    float buttonHeight = [[MyDevice sharedManager] screenHeightInPortrait] * .075f;
    int j = 0;
    
    if (viewIndex <=3) {
        for (NSString *strtitale in array) {
            _btnRedio = [[UIButton alloc]init];
            [[_btnRedio titleLabel] setUIFont:kUIFontType16 isBold:false];
            buttonHeight = MAX([[_btnRedio.titleLabel font] lineHeight] * 2, 50);
            float edgeSize = buttonHeight * .25f;
            _btnRedio.frame = CGRectMake(itemPosX * 2, itemPosY, itemWidth, buttonHeight);
            [_btnRedio setTitle:strtitale forState:UIControlStateNormal];
            [_btnRedio setTitleColor:[Utility getUIColor:kUIColorFontLight] forState:UIControlStateNormal];
            [_btnRedio setImageEdgeInsets:UIEdgeInsetsMake(edgeSize, 0, edgeSize, 0)];
            [_btnRedio setTitleEdgeInsets:UIEdgeInsetsMake(0, edgeSize, 0, 0)];
            [_btnRedio.imageView setContentMode:UIViewContentModeScaleAspectFit];
            UIImage* normalWL = [[UIImage imageNamed:@"chkBoxNormal.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            UIImage* selectedWL = [[UIImage imageNamed:@"chkBoxSelected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            UIImage* disabledWL = [[UIImage imageNamed:@"chkBoxNormal.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [_btnRedio setUIImage:normalWL forState:UIControlStateNormal];
            [_btnRedio setUIImage:selectedWL forState:UIControlStateSelected];
            [_btnRedio setUIImage:disabledWL forState:UIControlStateDisabled];
            _btnRedio.backgroundColor = [UIColor clearColor];
            
            [_btnRedio setTintColor:[Utility getUIColor:kUIColorFontLight]];
            _btnRedio.tag = [[_arraySortTag objectAtIndex:j] integerValue];
            
            if (viewIndex == 0) {
                if ([userFilter getSortOrder]==j) {
                    [_btnRedio setSelected:YES];
                }else{
                    [_btnRedio setSelected:NO];
                }
            }else{
                [_btnRedio setSelected:btnSelectorNOT];
            }
            j++;
            [_btnRedio setEnabled:true];
            [_btnRedio setUserInteractionEnabled:true];
            [_btnRedio setTintColor:[Utility getUIColor:999]];
            
            [Rightview addSubview:_btnRedio];
            [self.chkBoxSort addObject:_btnRedio];
            [_btnRedio setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
            [_btnRedio.layer setValue:[NSNumber numberWithInt:viewIndex] forKey:@"VIEW_INDEX"];
            
            if ([type isEqualToString:@"buttonRedio"]) {
                [_btnRedio addTarget:self action:@selector(radiobuttonSelected:) forControlEvents:UIControlEventTouchUpInside];
            }
            else if ([type isEqualToString:@"buttonOther"]){
                [_btnRedio addTarget:self action:@selector(otherbuttonSelected:) forControlEvents:UIControlEventTouchUpInside];
            }
            [_btnRedio.titleLabel setNumberOfLines:0];
            [_btnRedio.titleLabel sizeToFitUI];
            
            CGRect btnRect = _btnRedio.frame;
            btnRect.size.height = MAX(_btnRedio.titleLabel.frame.size.height, btnRect.size.height);
            _btnRedio.frame = btnRect;
            itemPosY = (CGRectGetMaxY(_btnRedio.frame));
        }
        Rightview.frame = CGRectMake(viewPosX, viewPosY, viewWidth, itemPosY);
        [_RightScrollvieww setContentSize:CGSizeMake(Rightview.frame.size.width, itemPosY)];
        
    }else{
        TM_FilterAttribute *filterAttribute = [_arrayleft objectAtIndex:viewIndex];
        NSMutableArray* filterAttributeOptions = [filterAttribute getXYZOptions];
        for (TM_FilterAttributeOption *arrayoption in filterAttributeOptions) {
            _btnRedio = [[UIButton alloc]init];
            [[_btnRedio titleLabel] setUIFont:kUIFontType16 isBold:false];
            buttonHeight = MAX([[_btnRedio.titleLabel font] lineHeight] * 2, 50);
            _btnRedio.frame = CGRectMake(itemPosX * 2, itemPosY, itemWidth, buttonHeight);
            float edgeSize = buttonHeight * .25f;
            NSMutableString* title = [NSMutableString stringWithFormat:@"%@", arrayoption.name];
            [_btnRedio setTitleColor:[Utility getUIColor:kUIColorFontDark] forState:UIControlStateNormal];
            [_btnRedio setTitleColor:[Utility getUIColor:kUIColorFontDark] forState:UIControlStateSelected];
            [_btnRedio setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
            [_btnRedio setImageEdgeInsets:UIEdgeInsetsMake(edgeSize, 0, edgeSize, 0)];
            [_btnRedio setTitleEdgeInsets:UIEdgeInsetsMake(0, edgeSize, 0, 0)];
            [_btnRedio.imageView setContentMode:UIViewContentModeScaleAspectFit];
            UIImage* normalWL = [[UIImage imageNamed:@"chkBoxNormal.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            UIImage* selectedWL = [[UIImage imageNamed:@"chkBoxSelected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            UIImage* disabledWL = [[UIImage imageNamed:@"chkBoxNormal.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [_btnRedio setUIImage:normalWL forState:UIControlStateNormal];
            [_btnRedio setUIImage:selectedWL forState:UIControlStateSelected];
            [_btnRedio setUIImage:disabledWL forState:UIControlStateDisabled];
            _btnRedio.backgroundColor = [UIColor clearColor];
            
            //            [_btnRedio setTintColor:[Utility getUIColor:kUIColorFontLight]];
            _btnRedio.tag = j;
            [Rightview addSubview:_btnRedio];
            
            [self.chkBoxSort addObject:_btnRedio];
            [_btnRedio setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
            [_btnRedio.layer setValue:[NSNumber numberWithInt:viewIndex] forKey:@"VIEW_INDEX"];
            if ([type isEqualToString:@"buttonRedio"]) {
                [_btnRedio addTarget:self action:@selector(radiobuttonSelected:) forControlEvents:UIControlEventTouchUpInside];
            }
            else if ([type isEqualToString:@"buttonOther"]){
                [_btnRedio addTarget:self action:@selector(otherbuttonSelected:) forControlEvents:UIControlEventTouchUpInside];
            }            [_btnRedio.titleLabel sizeToFitUI];
            //        [_btnRedio sizeToFit];
            itemPosY = (CGRectGetMaxY(_btnRedio.frame)) + gap;
            j++;
            
            TM_FilterAttributeOption *option = arrayoption;
            TM_FilterAttribute* userAttribute = [userFilter hasAttribute:filterAttribute];
            BOOL hasOption = false;
            if (userAttribute) {
                hasOption = [userFilter hasOption:userAttribute option:option];
                [_btnRedio setSelected:hasOption];
            }
            if(arrayoption.isVisible == false){
                [_btnRedio setEnabled:false];
                [_btnRedio setUserInteractionEnabled:false];
                [_btnRedio setTintColor:[UIColor lightGrayColor]];
                if (hasOption) {
                    [_btnRedio setEnabled:true];
                    [_btnRedio setUserInteractionEnabled:true];
                    [_btnRedio setTintColor:[Utility getUIColor:999]];
                }
                [title appendFormat:@" (0)"];
            } else {
                [_btnRedio setEnabled:true];
                [_btnRedio setUserInteractionEnabled:true];
                [_btnRedio setTintColor:[Utility getUIColor:999]];
            }
            
            [_btnRedio setTitle:title forState:UIControlStateNormal];
            [_btnRedio.titleLabel setNumberOfLines:0];
            [_btnRedio.titleLabel sizeToFitUI];
            
            CGRect btnRect = _btnRedio.frame;
            btnRect.size.height = MAX(_btnRedio.titleLabel.frame.size.height, btnRect.size.height);
            _btnRedio.frame = btnRect;
            itemPosY = (CGRectGetMaxY(_btnRedio.frame));
            
        }
        Rightview.frame = CGRectMake(viewPosX, viewPosY, viewWidth, itemPosY);
        [_RightScrollvieww setContentSize:CGSizeMake(Rightview.frame.size.width, itemPosY)];
    }
}

-(void)createRangSlider:(float)minimum maxmum:(float)maxmum viewIndex:(int)viewIndex{
    float viewPosX = [[MyDevice sharedManager] screenSize].width * 0.00f;
    float viewPosY = [[MyDevice sharedManager] screenSize].width * 0.00f;
    float viewWidth = [[MyDevice sharedManager] screenSize].width * 0.60f;
    float viewHeight = [[MyDevice sharedManager] screenSize].height - viewPosY;
    RightviewSlider = [_arrayRightViews objectAtIndex:viewIndex];
    
    RightviewSlider.frame = CGRectMake(viewPosX, viewPosY, viewWidth, viewHeight);
    
    for (UIView* v in [RightviewSlider subviews]) {
        [v removeFromSuperview];
    }
    float itemPosX = RightviewSlider.frame.size.width * 0.03f;
    float itemPosY = RightviewSlider.frame.size.width * 0.10f;
    float itemWidth = viewWidth - itemPosX * 2;
    float itemHeight = [[MyDevice sharedManager] screenHeightInPortrait] * .075f;
    
    float pricePosX = RightviewSlider.frame.size.width * 0.03f;
    float pricePosY = RightviewSlider.frame.size.width * 0.03f;
    float priceWidth = viewWidth * 0.15;
    float priceHeight = 25;
    
    
    float price1Width = viewWidth * 0.15;
    float price1PosX = RightviewSlider.frame.size.width - RightviewSlider.frame.size.width * 0.03f - price1Width;
    float price1PosY = RightviewSlider.frame.size.width * 0.03f;
    float price1Height = 25;
    
    self.labelMinPrice = [[UILabel alloc] initWithFrame:CGRectMake(pricePosX, pricePosY, priceWidth, priceHeight)];
    self.labelMinPrice.backgroundColor = [UIColor clearColor];
    self.labelMinPrice.numberOfLines = 1;
    self.labelMinPrice.textColor = [UIColor blackColor];
    
    
    self.labelMaxPrice = [[UILabel alloc] initWithFrame:CGRectMake(price1PosX, price1PosY, price1Width, price1Height)];
    self.labelMaxPrice.backgroundColor = [UIColor clearColor];
    self.labelMaxPrice.numberOfLines = 1;
    self.labelMaxPrice.textColor = [UIColor blackColor];
    
    // Init slider
    self.rangeSlider = [[MARKRangeSlider alloc] initWithFrame:CGRectMake(itemPosX, itemPosY, itemWidth, itemHeight)];
    self.rangeSlider.backgroundColor = [UIColor clearColor];
    [self.rangeSlider addTarget:self action:@selector(rangeSliderValueDidChange:) forControlEvents:UIControlEventValueChanged];
    
    [self.rangeSlider setMinValue:minimum maxValue:maxmum];
    
    if (userFilter.priceModified) {
        [self.rangeSlider setLeftValue:userFilter.minPrice rightValue:userFilter.maxPrice];
    }else{
        userFilter.minPrice = minimum;
        userFilter.maxPrice = maxmum;
        [self.rangeSlider setLeftValue:minimum rightValue:maxmum];
    }
    
//    self.rangeSlider.minimumDistance = 0.2;
//#if RANGE_SLIDER_NEW_UPDATE
//    self.rangeSlider.minimumDistance = 1.0;
//#endif
    [self updateRangeText];
    [RightviewSlider addSubview:self.labelMinPrice];
    [RightviewSlider addSubview:self.labelMaxPrice];
    [RightviewSlider addSubview:self.rangeSlider];
}
- (void)updateRangeText{
    //    RLOG(@"%0.2f - %0.2f", self.rangeSlider.leftValue, self.rangeSlider.rightValue);
    if (userFilter.priceModified) {
        self.labelMinPrice.text = [NSString stringWithFormat:@"%0.2f",userFilter.minPrice +taxAmountMin];
        self.labelMaxPrice.text = [NSString stringWithFormat:@"%0.2f",userFilter.maxPrice +taxAmountMax];
    }else{
        self.labelMinPrice.text = [NSString stringWithFormat:@"%0.2f",self.rangeSlider.leftValue +taxAmountMin];
        self.labelMaxPrice.text = [NSString stringWithFormat:@"%0.2f",self.rangeSlider.rightValue +taxAmountMax];
    }
    [self.labelMinPrice sizeToFitUI];
    [self.labelMaxPrice sizeToFitUI];
    
    CGRect maxLabelRect = self.labelMaxPrice.frame;
    maxLabelRect.origin.x = RightviewSlider.frame.size.width - RightviewSlider.frame.size.width * 0.03f - maxLabelRect.size.width;
    [self.labelMaxPrice setFrame:maxLabelRect];
    
}
- (void)rangeSliderValueDidChange:(MARKRangeSlider *)slider{
    [userFilter setMinPrice:self.rangeSlider.leftValue];
    [userFilter setMaxPrice:self.rangeSlider.rightValue];
    [self updateRangeText];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_index inSection:0];
    RLOG(@"ROW = %d", (int)indexPath.row);
    UITableViewCell *cell = [_tableData cellForRowAtIndexPath:indexPath];
    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%0.2f  %0.2f", userFilter.minPrice+taxAmountMin, userFilter.maxPrice+taxAmountMax]];
    [cell.detailTextLabel setTextColor:[Utility getUIColor:999]];
    [cell.detailTextLabel sizeToFitUI];
    [self.tableData reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [[_tableData cellForRowAtIndexPath:indexPath] setBackgroundColor:SelectedCellBGColor];
}
#pragma mark - All Button Actions

- (IBAction)barButtonBackPressed:(id)sender {
    [[Utility sharedManager] popScreen:self];
    if ([self.view tag] == PUSH_SCREEN_TYPE_FILTER) {
        return;
    }
    ViewControllerMain* mainVC = [ViewControllerMain getInstance];
    [mainVC resetPreviousState];
}
- (IBAction)barButtonApplyPressed:(id)sender {
    [locationView.tfRange resignFirstResponder];
    [Utility createCustomizedLoadingBar:Localize(@"") isBottomAlign:false isClearViewEnabled:false isShadowEnabled:true];
    NSMutableArray* attributes= [[NSMutableArray alloc] init];
    for (TM_FilterAttribute* fa in userFilter.attributes) {
        NSMutableDictionary* dict = [[NSMutableDictionary alloc]  init];
        NSMutableArray* options = [[NSMutableArray alloc] init];
        
        [dict setObject:fa.attribute forKey:@"attribute"];
        NSMutableArray* filterAttributeOptions = [fa getXYZOptions];
        for (TM_FilterAttributeOption *op in filterAttributeOptions) {
            NSMutableDictionary* dict1 = [[NSMutableDictionary alloc]  init];
            [dict1 setObject:op.name forKey:@"name"];
            [dict1 setObject:op.slug forKey:@"slug"];
            [dict1 setObject:op.taxo forKey:@"taxo"];
            [options addObject:dict1];
            [dict setObject:options forKey:@"options"];
        }
        [attributes addObject:dict];
    }
    float MaxPrice;
    if (userFilter.maxPrice == 0.0f) {
        MaxPrice = MaxPriceWithID;
    }else{
        MaxPrice = userFilter.maxPrice;
    }
    if (locationView) {
        userFilter.locationFilter_myLoc_radius = locationView.tfRange.text;
    }
    NSMutableDictionary* geoLocationDict = [[NSMutableDictionary alloc] init];
    [geoLocationDict setValue:[NSNumber numberWithFloat:userFilter.locationFilter_myLoc_lat] forKey:@"latitude"];
    [geoLocationDict setValue:[NSNumber numberWithFloat:userFilter.locationFilter_myLoc_lng] forKey:@"longitude"];
    [geoLocationDict setValue:userFilter.locationFilter_myLoc_radius forKey:@"radius"];
    [geoLocationDict setValue:userFilter.locationFilter_myLoc_unit forKey:@"unit"];

    NSMutableDictionary *JSONdic = [[NSMutableDictionary alloc] init];
    [JSONdic setValue:attributes forKey:@"attributes"];
    [JSONdic setValue:_cInfo._slug forKey:@"cat_slug"];
    [JSONdic setValue:[NSNumber numberWithBool:userFilter.chkStock] forKey:@"chkStock"];
    [JSONdic setValue:[NSNumber numberWithBool: userFilter.filterModified] forKey:@"filterModified"];
    [JSONdic setValue:[NSNumber numberWithFloat:userFilter.minPrice] forKey:@"minPrice"];
    [JSONdic setValue:[NSNumber numberWithFloat:MaxPrice] forKey:@"maxPrice"];
    [JSONdic setValue:[NSNumber numberWithBool:userFilter.on_sale] forKey:@"on_sale"];
    [JSONdic setValue:[NSNumber numberWithInt:[userFilter getSortOrder]] forKey:@"sort_type"];
    if([[Addons sharedManager] enable_location_in_filters] && userFilter.locationFilter_myLoc_lat != 0) {
        [JSONdic setValue:geoLocationDict forKey:@"geoLocation"];
    }
    [[[DataManager sharedManager] tmDataDoctor] getProductsByFilter:JSONdic success:^(id data) {
        RLOG(@"success %@",data);
        [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
        [((ViewControllerCategories*)(self.previousVC)) reloadWithFilter:data appliedUserFilter: userFilter];
        [[Utility sharedManager] popScreen:self];
    } failure:^(NSString *error) {
        RLOG(@"Failure");
        [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
    }];
}

- (BOOL)TableviewDidselectMethorAttributOptionsResponce:(int)rowIndex {
    
    if (userFilter.filterModified == false) {
        return true;
    }
    MRProgressOverlayView* mov = [Utility createCustomizedLoadingBar:Localize(@"") isBottomAlign:false isClearViewEnabled:false isShadowEnabled:true];
    
    for (TM_ProductFilter* productFilter in [TM_ProductFilter getAll]) {
        for (TM_FilterAttribute* filterAttribute in [productFilter getAttributes]) {
            NSMutableArray* filterAttributeOptions = [filterAttribute getXYZOptions];
            for (TM_FilterAttributeOption *attributeOption in filterAttributeOptions) {
                attributeOption.isVisible = true;
            }
        }
    }
    NSMutableArray* attributes= [[NSMutableArray alloc] init];
    for (TM_FilterAttribute* fa in userFilter.attributes) {
        NSMutableDictionary* dict = [[NSMutableDictionary alloc]  init];
        NSMutableArray* options = [[NSMutableArray alloc] init];
        
        [dict setObject:fa.attribute forKey:@"attribute"];
        NSMutableArray* filterAttributeOptions = [fa getXYZOptions];
        for (TM_FilterAttributeOption *op in filterAttributeOptions) {
            //            op.isVisible = true;
            NSMutableDictionary* dict1 = [[NSMutableDictionary alloc]  init];
            [dict1 setObject:op.name forKey:@"name"];
            [dict1 setObject:op.slug forKey:@"slug"];
            [dict1 setObject:op.taxo forKey:@"taxo"];
            [options addObject:dict1];
            [dict setObject:options forKey:@"options"];
        }
        [attributes addObject:dict];
    }
    NSDictionary *JSONdic = nil;
    float MaxPrice;
    if (userFilter.maxPrice == 0) {
        MaxPrice = MaxPriceWithID;
    }else{
        MaxPrice = userFilter.maxPrice;
    }
    JSONdic = @{
                @"attributes" : attributes,
                @"cat_slug" : _cInfo._slug,
                @"chkStock" : [NSNumber numberWithBool:userFilter.chkStock],
                @"filterModified" :[NSNumber numberWithBool: userFilter.filterModified],
                @"minPrice" : [NSNumber numberWithFloat:userFilter.minPrice],
                @"maxPrice" : [NSNumber numberWithFloat:MaxPrice],
                @"on_sale" : [NSNumber numberWithBool:userFilter.on_sale],
                @"sort_type" : [NSNumber numberWithInt:[userFilter getSortOrder]]
                };
    
    if (attributes == nil || [attributes count]==0) {
        [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
        return true;
    }
    
    [[[DataManager sharedManager] tmDataDoctor] getAttributByAttributSelectedAttribute:JSONdic success:^(id data) {
        //        RLOG(@"RESPONSE:\n%@\n",data);
        NSString *taxo;
        NSArray *names;
        
        for (NSDictionary* dict2 in [data valueForKey:@"attribute"]) {
            if (dict2) {
                if (IS_NOT_NULL(dict2, @"taxo")) {
                    taxo = GET_VALUE_OBJECT(dict2, @"taxo");
                }
                if (IS_NOT_NULL(dict2, @"names")) {
                    names = GET_VALUE_OBJECT(dict2, @"names");
                    NSMutableArray* formattedStr = [[NSMutableArray alloc] init];
                    for (NSString* stri in names) {
                        [formattedStr addObject:[Utility getStringIfFormatted:stri]];
                    }
                    names = formattedStr;
                    
                    int categoryId = self.cInfo._id;
                    TM_ProductFilter* productFilter = [TM_ProductFilter getForCategory:categoryId];
                    {
                        for (TM_FilterAttribute* filterAttribute in [productFilter getAttributes]) {
                            NSMutableArray* filterAttributeOptions = [filterAttribute getXYZOptions];
                            for (TM_FilterAttributeOption *attributeOption in filterAttributeOptions) {
                                if ([Utility compareAttributeNames:taxo name2:attributeOption.taxo]) {
                                    attributeOption.isVisible = false;
                                    RLOG(@"set false attributeOption = %@", attributeOption.name);
                                    if ([names containsObject:attributeOption.name]) {
                                        attributeOption.isVisible = true;
                                        RLOG(@"set true attributeOption = %@", attributeOption.name);
                                    }
                                }
                            }
                        }
                    }
                }
                
            }
        }
        
        //        for (NSDictionary* dict2 in [data valueForKey:@"attribute"]) {
        //            if (dict2) {
        //                if (IS_NOT_NULL(dict2, @"taxo")) {
        //                    taxo = GET_VALUE_OBJECT(dict2, @"taxo");
        //                }
        //                if (IS_NOT_NULL(dict2, @"names")) {
        //                    names = GET_VALUE_OBJECT(dict2, @"names");
        //                    TM_FilterAttribute *filterAttribute = [_arrayleft objectAtIndex:rowIndex];
        //                    for (TM_FilterAttributeOption *arrayoption in filterAttribute.options) {
        //                        if ([names containsObject:arrayoption.name]) {
        //                            arrayoption.isVisible = true;
        //                            RLOG(@"set true attributeOption = %@", arrayoption.name);
        //                        }else{
        //                            arrayoption.isVisible = false;
        //                        }
        //                    }
        //            }
        //        }
        //    }
        [self createRightview:data array:nil type:@"buttonOther" color:[UIColor clearColor] viewIndex:rowIndex btnSelectorNOT:nil] ;
        
        [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
    } failure:^(NSString *error) {
        RLOG(@"Failure");
    }];
    return false;
}

-(void)radiobuttonSelected:(UIButton*)sender {
    UIButton* senderButton = (UIButton*)sender;
    [userFilter setSort_type:(int)[senderButton tag]];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[[sender.layer valueForKey:@"VIEW_INDEX"] intValue] inSection:0];
    UITableViewCell *cell = [_tableData cellForRowAtIndexPath:indexPath];
    cell.detailTextLabel.text = sender.titleLabel.text;
    [_tableData reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [[_tableData cellForRowAtIndexPath:indexPath] setBackgroundColor:SelectedCellBGColor];
    if([senderButton isSelected] == YES) {
        RLOG(@" Button Selected");
        
    } else {
        [senderButton setSelected:YES];
        for (UIButton* button in _chkBoxSort) {
            if(button != senderButton){
                [button setSelected:NO];
                RLOG(@" Button NOT Selected");
            }
        }
    }
    if ([senderButton isSelected]) {
        return;
    }
}
-(void)otherbuttonSelected:(UIButton*)sender {
    UIButton* senderButton = (UIButton*)sender;
    TM_FilterAttribute *filterAttribute = [_arrayleft objectAtIndex:_index];
    RLOG(@"VIEW_INDEX = %d",[[sender.layer valueForKey:@"VIEW_INDEX"] intValue]);
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[[sender.layer valueForKey:@"VIEW_INDEX"] intValue] inSection:0];
    RLOG(@"ROW = %d", (int)indexPath.row);
    UITableViewCell *cell = [_tableData cellForRowAtIndexPath:indexPath];
    
    if([senderButton isSelected] == YES) {
        [senderButton setSelected:NO];
        if (_index == 2) {
            [userFilter isChkStock];
            [self showDetailStringsForStock:cell indexPath:indexPath tableView:_tableData];
            [_tableData reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [[_tableData cellForRowAtIndexPath:indexPath] setBackgroundColor:SelectedCellBGColor];
        }
        else if (_index == 3){
            [userFilter shouldCheckOnSale];
            [self showDetailStringsForDicount:cell indexPath:indexPath tableView:_tableData];
            [_tableData reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [[_tableData cellForRowAtIndexPath:indexPath] setBackgroundColor:SelectedCellBGColor];
        }
        else{
            NSMutableArray *temp = [filterAttribute getXYZOptions];
            RLOG(@"sender.tag  %ld",(long)sender.tag);
            TM_FilterAttributeOption *options = [temp objectAtIndex:sender.tag];
            TM_FilterAttribute* userAttribute = [userFilter getOrAddAttributeByNameOf:filterAttribute];
            [userFilter removeAttributeOption:userAttribute option:options];
            [self TableviewDidselectMethorAttributOptionsResponce:_index];
            [self showDetailStringsForAttribut:cell indexPath:indexPath tableView:_tableData];
            [_tableData reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [[_tableData cellForRowAtIndexPath:indexPath] setBackgroundColor:SelectedCellBGColor];
        }
    } else {
        if (_index == 2) {
            [userFilter isChkStockTrue];
            [cell.detailTextLabel setText:[NSString stringWithFormat:@""]];
            [cell.detailTextLabel setTextColor:[Utility getUIColor:999]];
            [cell.detailTextLabel sizeToFitUI];
            [_tableData reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [[_tableData cellForRowAtIndexPath:indexPath] setBackgroundColor:SelectedCellBGColor];
        }
        else if (_index == 3){
            [userFilter shouldCheckOnSaleTrue];
            [cell.detailTextLabel setText:[NSString stringWithFormat:@""]];
            [cell.detailTextLabel setTextColor:[Utility getUIColor:999]];
            [cell.detailTextLabel sizeToFitUI];
            [_tableData reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [[_tableData cellForRowAtIndexPath:indexPath] setBackgroundColor:SelectedCellBGColor];
        } else {
            NSMutableArray *temp = [filterAttribute getXYZOptions];
            RLOG(@"sender.tag  %ld",(long)sender.tag);
            TM_FilterAttributeOption *options = [temp objectAtIndex:sender.tag];
            TM_FilterAttribute* userAttribute = [userFilter getOrAddAttributeByNameOf:filterAttribute];
            [userFilter addAttributeOption:userAttribute option:options];
            [self showDetailStringsForAttribut:cell indexPath:indexPath tableView:_tableData];
            [_tableData reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [[_tableData cellForRowAtIndexPath:indexPath] setBackgroundColor:SelectedCellBGColor];
        }
        [senderButton setSelected:YES];
    }
    return;
}
- (void)showDetailStringsForAttribut:(UITableViewCell*)cell indexPath:(NSIndexPath*)indexPath tableView:(UITableView*)tableView {
    TM_FilterAttribute* cellFA = [cell.layer valueForKey:@"FAOBJ"];
    NSMutableString* dstr = [[NSMutableString alloc] init];
    for (TM_FilterAttribute* fa in userFilter.attributes) {
        if([fa.attribute isEqualToString:cellFA.attribute]){
            int i = 0;
            NSMutableArray* filterAttributeOptions = [fa getXYZOptions];
            for (TM_FilterAttributeOption* opt in filterAttributeOptions) {
                [dstr appendString:opt.name];
                i++;
                if (i < (int)[filterAttributeOptions count]) {
                    [dstr appendString:@", "];
                }
            }
        }
    }
    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@", dstr]];
    [cell.detailTextLabel setTextColor:[Utility getUIColor:999]];
    [cell.detailTextLabel sizeToFitUI];
}
- (void)showDetailStringsForDicount:(UITableViewCell*)cell indexPath:(NSIndexPath*)indexPath tableView:(UITableView*)tableView {
    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@",Localize(@"discount")]];
    [cell.detailTextLabel setTextColor:[Utility getUIColor:999]];
    [cell.detailTextLabel sizeToFitUI];
}
- (void)showDetailStringsForStock:(UITableViewCell*)cell indexPath:(NSIndexPath*)indexPath tableView:(UITableView*)tableView {
    [cell.detailTextLabel setText:[NSString stringWithFormat:@"%@",Localize(@"in_Stock")]];
    [cell.detailTextLabel setTextColor:[Utility getUIColor:999]];
    [cell.detailTextLabel sizeToFitUI];
}
-(void)StockCheck:(UIButton*)sender {
    UIButton *senderbutton = (UIButton *)sender;
    if ([senderbutton isSelected] == YES) {
        [senderbutton setSelected:NO];
    }else{
        [senderbutton setSelected:YES];
    }
}
-(void)ShowDiscountiem:(UIButton*)sender{
    UIButton *senderbutton = (UIButton *)sender;
    if ([senderbutton isSelected] == YES) {
        [senderbutton setSelected:NO];
    }else{
        [senderbutton setSelected:YES];
    }
}

-(void)clearFilters{
//    myLoc = nil;
//    myAddressStr = @"";
//    selectedLoc = nil;
    selectedAddressStr = nil;
//     locationView.locationSearch.text = selectedAddressStr;
    userFilter.locationFilter_myLoc_lat = 0;
    userFilter.locationFilter_myLoc_lng = 0;
    userFilter.locationFilter_myLoc_unit = @"metric";
    userFilter.locationFilter_myLoc_radius = @"0";
    
    UIAlertView *alert= [[UIAlertView alloc]initWithTitle:Localize(@"reset_all_filters") message:@"" delegate:self cancelButtonTitle:Localize(@"btn_no") otherButtonTitles:Localize(@"btn_yes"), nil];
    [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1){
            userFilter.minPrice = MinPriceWithID;
            userFilter.maxPrice = MaxPriceWithID;
            [[UserFilter sharedInstance]resetFilterdata];
            for (TM_ProductFilter* productFilter in [TM_ProductFilter getAll]) {
                for (TM_FilterAttribute* filterAttribute in [productFilter getAttributes]) {
                    NSMutableArray* filterAttributeOptions = [filterAttribute getXYZOptions];
                    for (TM_FilterAttributeOption *attributeOption in filterAttributeOptions) {
                        attributeOption.isVisible = true;
                    }
                }
            }
            [_tableData reloadData];
            NSIndexPath *firstRowPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.tableData selectRowAtIndexPath:firstRowPath animated:NO scrollPosition: UITableViewScrollPositionNone];
            [self tableView:self.tableData didSelectRowAtIndexPath:firstRowPath];
        }else if (buttonIndex == 0){
            [_tableData reloadData];
            NSIndexPath *firstRowPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.tableData selectRowAtIndexPath:firstRowPath animated:NO scrollPosition: UITableViewScrollPositionNone];
            [self tableView:self.tableData didSelectRowAtIndexPath:firstRowPath];
        }
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Adjust Orientation

- (void)beforeRotation {
    //    UIView* lastView = [_arrayRightViews lastObject];
    //    for(UIView *view in _arrayRightViews)
    //    {
    //        [UIView animateWithDuration:0.1f animations:^{
    //            [view setAlpha:0.0f];
    //        }completion:^(BOOL finished){
    //            [view removeFromSuperview];
    //            if (view == lastView) {
    //                [_arrayRightViews removeAllObjects];
    //            }
    //        }];
    //    }
}
- (void)afterRotation {
    //    [self loadDataInView];
    //    UIView* lastView = [_viewsAdded lastObject];
    //    for(UIView *vieww in _viewsAdded)
    //    {
    //        [vieww setAlpha:0.0f];
    //        [UIView animateWithDuration:0.1f animations:^{
    //            [vieww setAlpha:1.0f];
    //        }completion:^(BOOL finished){
    //            if (vieww == lastView) {
    //                [self resetMainScrollView];
    //                if (_spinnerView) {
    //                    [_spinnerView setCenter:CGPointMake(self.view.frame.size.width/2, [_scrollView contentSize].height - [LayoutProperties globalVerticalMargin]/2)];
    //                }
    //            }
    //        }];
    //    }
}
- (void)adjustViewsForOrientation:(UIDeviceOrientation) orientation {
    RLOG(@"====adjustViewsForOrientation====");
    [self beforeRotation];
}
- (void)adjustViewsAfterOrientation:(UIDeviceOrientation) orientation {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    RLOG(@"====adjustViewsAfterOrientation====");
    [self afterRotation];
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    if ([[AppDelegate getInstance] isAppEnteredInBackground]) {
        return;
    }
    [self adjustViewsAfterOrientation:[[UIDevice currentDevice] orientation]];
    [self resetMainScrollView];
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if ([[AppDelegate getInstance] isAppEnteredInBackground]) {
        return;
    }
    [[Utility sharedManager] startGrayLoadingBar:true];
    [self adjustViewsForOrientation:[[UIDevice currentDevice] orientation]];
    [self resetMainScrollView];
}
#pragma mark - Reset Views
- (void)resetMainScrollView {
    //    float globalPosY = 0.0f;
    //    UIView* tempView = nil;
    //    //    RLOG(@"\n_scrollView child count %d",(int)[[_scrollView subviews] count]);
    //
    //    for (tempView in _viewsAdded) {
    //        //        RLOG(@"\ntempView = %@, globalPosY = %.f", tempView, globalPosY);
    //        CGRect rect = [tempView frame];
    //        rect.origin.y = globalPosY;
    //        [tempView setFrame:rect];
    //        globalPosY += rect.size.height;
    //
    //        if ([tempView tag] == kTagForGlobalSpacing) {
    //            globalPosY += [LayoutProperties globalVerticalMargin];
    //        }else if ([tempView tag] == kTagForLastViewSpacing){
    //            globalPosY += [LayoutProperties globalVerticalMargin]/2;
    //        }
    //    }
    //    globalPosY -= [LayoutProperties globalVerticalMargin]/2;
    //    //    [_scrollView setContentSize:CGSizeMake(_scrollView.contentSize.width, MAX(globalPosY, self.view.frame.size.height))];
    //    //    [_scrollView setBounces:true];
    
    float viewPosX = [[MyDevice sharedManager] screenSize].width * 0.00f;
    float viewPosY = [[MyDevice sharedManager] screenSize].width * 0.00f;
    float viewWidth = [[MyDevice sharedManager] screenSize].width * 0.60f;
    float viewHeight = [[MyDevice sharedManager] screenSize].height - viewPosY;
    
    RightviewSlider.frame = CGRectMake(viewPosX, viewPosY, viewWidth, viewHeight);
    float itemPosX = RightviewSlider.frame.size.width * 0.03f;
    float itemPosY = RightviewSlider.frame.size.width * 0.08f;
    float itemWidth = viewWidth - itemPosX * 2;
    float itemHeight = [[MyDevice sharedManager] screenHeightInPortrait] * .075f;
    self.rangeSlider.frame = CGRectMake(itemPosX, itemPosY, itemWidth, itemHeight);
    
    //    if (_RightScrollvieww == nil) {
    //        [_RightScrollvieww setContentSize:CGSizeMake(_scrollView.contentSize.width, MAX(globalPosY, self.view.frame.size.height))];
    //        //        [_scrollView setBounces:true];
    //    }else{
    //        [_RightScrollvieww setContentSize:CGSizeMake(_scrollView.contentSize.width, globalPosY)];
    //    }
}

#pragma mark GPI............

- (void)viewController:(GMSAutocompleteViewController *)viewController
didAutocompleteWithPlace:(GMSPlace *)place {
    [self dismissViewControllerAnimated:YES completion:nil];
    // Do something with the selected place.
    NSLog(@"Place name %@", place.name);
    NSLog(@"Place address %@", place.formattedAddress);
    NSLog(@"Place attributions %@", place.attributions.string);
}

- (void)viewController:(GMSAutocompleteViewController *)viewController
didFailAutocompleteWithError:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
    // TODO: handle the error.
    NSLog(@"Error: %@", [error description]);
}

// User canceled the operation.
- (void)wasCancelled:(GMSAutocompleteViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Turn the network activity indicator on and off again.
- (void)didRequestAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)didUpdateAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

// Handle the user's selection.
- (void)resultsController:(GMSAutocompleteResultsViewController *)resultsController
 didAutocompleteWithPlace:(GMSPlace *)place {
    searchController.active = NO;
    // Do something with the selected place.
    NSLog(@"Place name %@", place.name);
    NSLog(@"Place address %@", place.formattedAddress);
    NSLog(@"Place attributions %@", place.attributions.string);
}

- (void)resultsController:(GMSAutocompleteResultsViewController *)resultsController
didFailAutocompleteWithError:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
    // TODO: handle the error.
    NSLog(@"Error: %@", [error description]);
}

// Turn the network activity indicator on and off again.
- (void)didRequestAutocompletePredictionsForResultsController:
(GMSAutocompleteResultsViewController *)resultsController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)didUpdateAutocompletePredictionsForResultsController:
(GMSAutocompleteResultsViewController *)resultsController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchString:(NSString *)searchString
{
    [tableDataSource sourceTextHasChanged:searchString];
    return NO;
}
// Handle the user's selection.
- (void)tableDataSource:(GMSAutocompleteTableDataSource *)tableDataSource
didAutocompleteWithPlace:(GMSPlace *)place {
    [searchDisplayController setActive:NO animated:YES];
    // Do something with the selected place.
    NSLog(@"Place name %@", place.name);
    NSLog(@"Place address %@", place.formattedAddress);
    NSLog(@"Place attributions %@", place.attributions.string);
    // search address on MAP
    //    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:place.coordinate.latitude longitude:place.coordinate.longitude zoom:15];
    //    [googleMaps animateToCameraPosition:camera];
    
    CLLocation *loc = [[CLLocation alloc]initWithLatitude:place.coordinate.latitude longitude:place.coordinate.longitude]; //insert your coordinates
    selectedLoc = loc;
    selectedAddressStr = [NSString stringWithFormat:@"%@, %@",place.name, place.formattedAddress];
    myLocEnable = false;
    [self refreshUserLocationData];
    return;
//    CLGeocoder *ceo = [[CLGeocoder alloc]init];
//    [ceo reverseGeocodeLocation:loc
//              completionHandler:^(NSArray *placemarks, NSError *error) {
//                  
//                  CLPlacemark *placemark = [placemarks objectAtIndex:0];
//                  // Check if any placemarks were found
//                  if (error == nil && [placemarks count] > 0) {
//                      
//                      NSLog(@"AddressDict:%@",placemark.addressDictionary);
//                      locationView.locationSearch.text = [NSString stringWithFormat:@"%@",[[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "]];
//                      // [markerImage setHidden:NO];
//                      //[shippingAddressLabel setHidden:NO];
//                  }
//                  else {
//                      NSLog(@"Could not locate");
//                  }
//              }
//     ];
    
    
}

- (void)tableDataSource:(GMSAutocompleteTableDataSource *)tableDataSource
didFailAutocompleteWithError:(NSError *)error {
    [searchDisplayController setActive:NO animated:YES];
    // TODO: handle the error.
    NSLog(@"Error: %@", [error description]);
}

- (void)didUpdateAutocompletePredictionsForTableDataSource:
(GMSAutocompleteTableDataSource *)tableDataSource {
    // Turn the network activity indicator off.
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    // Reload table data.
    [searchDisplayController.searchResultsTableView reloadData];
}

- (void)didRequestAutocompletePredictionsForTableDataSource:
(GMSAutocompleteTableDataSource *)tableDataSource {
    // Turn the network activity indicator on.
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    // Reload table data.
    [searchDisplayController.searchResultsTableView reloadData];
}

#pragma Current Location

- (void)didTouchUp:(UIButton *)sender {
    NSLog(@"Button Pressed!");
     //  locationView.tfRange.text = self.mySelectedAddressStr;
    myLocEnable = true;
    [self refreshUserLocationData];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Turn off the location manager to save power.
     [self.locationManager stopUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation *newLocation = [locations lastObject];
    NSLog(@"FINAL1 LOC FETCHED");
    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        
        if (error == nil && [placemarks count] > 0) {
            NSLog(@"FINAL2 LOC FETCHED");
            placemark = [placemarks lastObject];
            // txtLatitude.text = [NSString stringWithFormat:@"%f",newLocation.coordinate.latitude];
            // txtLongitude.text = [NSString stringWithFormat:@"%f",newLocation.coordinate.longitude];
            // txtState.text = placemark.administrativeArea;
            // txtCountry.text = placemark.country;
            NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
            NSString *Address = [[NSString alloc]initWithString:locatedAt];
//            locationView.tfRange.text = Address;
            myLoc = placemark.location;
            myAddressStr = Address;
            [self refreshUserLocationData];
            [manager stopUpdatingLocation];
        } else {
            NSLog(@"%@", error.debugDescription);
        }
    } ];
    
    // Turn off the location manager to save power.
//    [manager stopUpdatingLocation];
}

//- (void)locationManager:(CLLocationManager *)manager
//       didFailWithError:(NSError *)error
//{
//    NSLog(@"Cannot find the location.");
//}
- (void)loadFilterLocationView {
    
    if (locationView != nil) {
        
        if([[Addons sharedManager] enable_location_in_filters] && userFilter.locationFilter_myLoc_lat != 0) {
            locationView.tfRange.text = userFilter.locationFilter_myLoc_radius;
            if ([userFilter.locationFilter_myLoc_unit isEqualToString:@"metric"]) {
                locationView.lblRangeUnit.text = Localize(@"kilometer");
            } else if ([userFilter.locationFilter_myLoc_unit isEqualToString:Localize(@"imperial")]) {
                locationView.lblRangeUnit.text = Localize(@"mile");
            } else {
                locationView.lblRangeUnit.text = Localize(@"kilometer");
            }
            [self refreshUserLocationData];
        } else {
            locationView.lblRangeUnit.text = Localize(@"kilometer");
            locationView.tfRange.text = @"";
            locationView.locationSearch.text = @"";
        }
        return;
    }
    
    float viewPosX = self.RightScrollvieww.frame.size.width * 0.00f;
    float viewPosY = self.RightScrollvieww.frame.size.width  * 0.03f;
    float viewWidth = [[MyDevice sharedManager] screenSize].width * 0.60f;
    float viewHeight = [[MyDevice sharedManager] screenSize].height - viewPosY;
    UIView *Rightview = [_arrayRightViews objectAtIndex:4];
    Rightview.frame = CGRectMake(viewPosX, viewPosY, viewWidth, viewHeight);
    Rightview.backgroundColor = [UIColor clearColor];
    for (UIView* v in [Rightview subviews]) {
        [v removeFromSuperview];
    }
    FilterLocationView *containerView =
    [[FilterLocationView alloc] init];
    locationView = containerView;
    //    [[[NSBundle mainBundle] loadNibNamed:@"FilterLocationView" owner:self options:nil] lastObject];
    containerView.locationSearch.delegate = self;
//    searchDisplayController = containerView.
//    containerView.searchDisplayController.delegate = self;
//    containerView.searchDisplayController.searchResultsDelegate = self;
//    containerView.searchDisplayController.searchResultsDataSource = self;
//        containerView.searchDisplayController.searchContentsController = self;
    
    [containerView.btnCurrentLocation addTarget:self action:@selector(didTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    locationView.tfRange.delegate = self;
    [locationView.locationSearch setPlaceholder:Localize(@"search_location")];
    [locationView.lblRangeTitle setText:Localize(@"title_range_in")];
    [locationView.tfRange setPlaceholder:Localize(@"title_range")];
    [locationView.btnCurrentLocation setTitle:Localize(@"text_autofill") forState:UIControlStateNormal];
    resultsViewController = [[GMSAutocompleteResultsViewController alloc] init];
    resultsViewController.delegate = self;
    tableDataSource = [[GMSAutocompleteTableDataSource alloc] init];
    tableDataSource.delegate = self;
    tableDataSource.tableCellSeparatorColor = [UIColor whiteColor];
    

    searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:locationView.locationSearch contentsController:self];
    [searchDisplayController setSearchResultsTitle:@"jahdkjahdklj"];
//    [searchDisplayController setDisplaysSearchBarInNavigationBar:true];
    PRINT_RECT_STR(@"searchDisplayController", searchDisplayController.accessibilityFrame);
    
   // [searchDisplayController setAccessibilityFrame:CGRectMake(0, 0, [[MyDevice sharedManager] screenSize].width, searchDisplayController.accessibilityFrame.size.height)];
    [searchBar setFrame:CGRectMake(0, 0,[[MyDevice sharedManager] screenSize].width, searchDisplayController.accessibilityFrame.size.height)];
    searchDisplayController.searchResultsDataSource = tableDataSource;
    searchDisplayController.searchResultsDelegate = tableDataSource;
    searchDisplayController.delegate = self;
    searchBar.backgroundColor = [UIColor redColor];

    [self.view addSubview:containerView];
//    [Rightview addSubview:containerView];
    {
        float viewPosX = [[MyDevice sharedManager] screenSize].width * 0.40f;
        float viewPosY = [[MyDevice sharedManager] screenSize].width * 0.00f + [[Utility sharedManager] getTopBarHeight];
        float viewWidth = [[MyDevice sharedManager] screenSize].width * 0.60f;
        float viewHeight = [[MyDevice sharedManager] screenSize].height - viewPosY;
        containerView.frame = CGRectMake(viewPosX, viewPosY, viewWidth, viewHeight);
    }
//    containerView.frame = CGRectMake(0, 0, Rightview.frame.size.width, Rightview.frame.size.height);
}
- (IBAction)search:(id)sender
{
//    containerView.btnCurrentLocationsearchBar.hidden = NO;
    [locationView.locationSearch becomeFirstResponder];
    [searchDisplayController setActive:YES animated:YES];
}
#pragma mark - Fetch Core Location
- (void)enableLocationService {
    if (1) {
        _locationManager = [[CLLocationManager alloc] init];
        geocoder = [[CLGeocoder alloc] init];
        if ([CLLocationManager locationServicesEnabled]) {
            RLOG(@"locationServicesEnabled");
            [self getCurrentLocation];
        }else{
            RLOG(@"locationServicesDisabled");
        }
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
        if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [_locationManager requestWhenInUseAuthorization];
        }
        [_locationManager startUpdatingLocation];
    }
}
- (void)getCurrentLocation {
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [_locationManager startUpdatingLocation];
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    RLOG(@"didFailWithError: %@", error);
    RLOG(@"LOCATION FETCHED:FAILED");
}
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    CLLocation *currentLocation = newLocation;
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error == nil && [placemarks count] > 0) {
            placemark = [placemarks lastObject];
//            _dataManager.userTempPostalCode = placemark.postalCode;
//            _dataManager.userTempCity = placemark.locality;
//            _dataManager.userTempState = placemark.administrativeArea;
//            _dataManager.userTempCountry = placemark.country;
//            _dataManager.locationDataFetched = true;
            RLOG(@"LOCATION FETCHED:SUCCEED");
//            [_locationManager stopUpdatingLocation];
//            if (self.popupController != nil){
//                [self updateLocationBasedUI];
//            }
        }
    } ];
}
- (void)locationManager:(CLLocationManager*)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusNotDetermined: {
            [_locationManager startUpdatingLocation];
        } break;
        case kCLAuthorizationStatusDenied: {
            [_locationManager stopUpdatingLocation];
        } break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorizedAlways: {
            [_locationManager startUpdatingLocation];
        } break;
        default:
            break;
    }
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (locationView != nil && textField == locationView.tfRange) {
        NSCharacterSet *myCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
        for (int i = 0; i < [string length]; i++)
        {
            unichar c = [string characterAtIndex:i];
            if (![myCharSet characterIsMember:c])
            {
                return NO;
            }
        }
        return YES;
    }[self refreshUserLocationData];
    return true;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (locationView != nil && textField == locationView.tfRange) {
        [self refreshUserLocationData];
    }
}
- (void)refreshUserLocationData {
    if (locationView) {
        if (myLocEnable) {
            if(myLoc){
                userFilter.locationFilter_myLoc_lat = myLoc.coordinate.latitude;
                userFilter.locationFilter_myLoc_lng = myLoc.coordinate.longitude;
                locationView.locationSearch.text = myAddressStr;
            } else {
                userFilter.locationFilter_myLoc_lat = 0;
                userFilter.locationFilter_myLoc_lng = 0;
                locationView.locationSearch.text = @"";
            }
        } else {
            if(selectedLoc) {
                userFilter.locationFilter_myLoc_lat = selectedLoc.coordinate.latitude;
                userFilter.locationFilter_myLoc_lng = selectedLoc.coordinate.longitude;
                locationView.locationSearch.text = selectedAddressStr;
            } else {
                userFilter.locationFilter_myLoc_lat = 0;
                userFilter.locationFilter_myLoc_lng = 0;
                locationView.locationSearch.text = @"";
            }
        }
        
//        if (userFilter.locationFilter_myLoc_unit && ![userFilter.locationFilter_myLoc_unit isEqualToString:@""]) {
            if ([userFilter.locationFilter_myLoc_unit isEqualToString:@"metric"]) {
                locationView.lblRangeUnit.text = Localize(@"kilometer");
            } else if ([userFilter.locationFilter_myLoc_unit isEqualToString:@"imperial"]) {
                locationView.lblRangeUnit.text = Localize(@"mile");
            } else {
                locationView.lblRangeUnit.text = Localize(@"kilometer");
            }
//        } else {
//            if ([locationView.lblRangeUnit.text isEqualToString:Localize(@"kilometer")]) {
//                userFilter.locationFilter_myLoc_unit = @"metric";
//            } else if ([locationView.lblRangeUnit.text isEqualToString:Localize(@"mile")]) {
//                userFilter.locationFilter_myLoc_unit = @"imperial";
//            } else {
//                userFilter.locationFilter_myLoc_unit = @"metric";
//            }
//        }
        
        
//        if (userFilter.locationFilter_myLoc_radius && ![userFilter.locationFilter_myLoc_radius isEqualToString:@""]) {
//            locationView.tfRange.text = userFilter.locationFilter_myLoc_radius;
//        } else {
            userFilter.locationFilter_myLoc_radius = locationView.tfRange.text;
//        }
    }
}
- (void)initUserLocationData {
    if (locationView) {
        if (myLocEnable) {
            if(myLoc){
                userFilter.locationFilter_myLoc_lat = myLoc.coordinate.latitude;
                userFilter.locationFilter_myLoc_lng = myLoc.coordinate.longitude;
                locationView.locationSearch.text = myAddressStr;
            } else {
                userFilter.locationFilter_myLoc_lat = 0;
                userFilter.locationFilter_myLoc_lng = 0;
                locationView.locationSearch.text = @"";
            }
        } else {
            if(selectedLoc) {
                userFilter.locationFilter_myLoc_lat = selectedLoc.coordinate.latitude;
                userFilter.locationFilter_myLoc_lng = selectedLoc.coordinate.longitude;
                locationView.locationSearch.text = selectedAddressStr;
            } else {
                userFilter.locationFilter_myLoc_lat = 0;
                userFilter.locationFilter_myLoc_lng = 0;
                locationView.locationSearch.text = @"";
            }
        }
        
        if (userFilter.locationFilter_myLoc_unit && ![userFilter.locationFilter_myLoc_unit isEqualToString:@""]) {
            if ([userFilter.locationFilter_myLoc_unit isEqualToString:@"metric"]) {
                locationView.lblRangeUnit.text = Localize(@"kilometer");
            } else if ([userFilter.locationFilter_myLoc_unit isEqualToString:@"imperial"]) {
                locationView.lblRangeUnit.text = Localize(@"mile");
            } else {
                locationView.lblRangeUnit.text = Localize(@"kilometer");
            }
        } else {
            if ([locationView.lblRangeUnit.text isEqualToString:Localize(@"kilometer")]) {
                userFilter.locationFilter_myLoc_unit = @"metric";
            } else if ([locationView.lblRangeUnit.text isEqualToString:Localize(@"mile")]) {
                userFilter.locationFilter_myLoc_unit = @"imperial";
            } else {
                userFilter.locationFilter_myLoc_unit = @"metric";
            }
        }
        
        
        if (userFilter.locationFilter_myLoc_radius && ![userFilter.locationFilter_myLoc_radius isEqualToString:@""]) {
            locationView.tfRange.text = userFilter.locationFilter_myLoc_radius;
        } else {
            userFilter.locationFilter_myLoc_radius = locationView.tfRange.text;
        }
    }
}
- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    NSLog(@"animate will begins");
    if(locationView){
        self.fadeView = [[UIView alloc] initWithFrame:CGRectMake(0, [[Utility sharedManager] getTopBarHeight] - 10, self.view.frame.size.width, self. view.frame.size.height)];
        [self.fadeView setAlpha:0.0f];
        [self.fadeView setBackgroundColor:[UIColor whiteColor]];
        [self.view addSubview:self.fadeView];
        [self.view bringSubviewToFront:locationView];
        [UIView animateWithDuration:0.3f animations:^{
            [locationView.cLeadingLocationSearch setConstant: -locationView.frame.origin.x + 20];
            [locationView updateConstraints];
            [self.fadeView setAlpha:1.0f];
            [locationView.imagepin setHidden:YES];
        }];
    }
}
- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    NSLog(@"animate will ends");
    if (self.fadeView) {
        [UIView animateWithDuration:0.3f animations:^{
            [locationView.cLeadingLocationSearch setConstant:60];
            [locationView updateConstraints];
            [self.fadeView setAlpha:0.0f];
            [locationView.imagepin setHidden:NO];
        } completion:^(BOOL finished) {
            [self.fadeView removeFromSuperview];
            self.fadeView = nil;
        }];
    }
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBara {
    if (locationView != nil && locationView.locationSearch == searchBara && [searchBara.text isEqualToString:@""]) {
        selectedLoc = nil;
        selectedAddressStr = @"";
        myLocEnable = false;
        [self refreshUserLocationData];
    }
}
@end
