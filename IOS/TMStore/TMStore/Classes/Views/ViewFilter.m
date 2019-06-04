//
//  ViewFilter.m
//  TMStore
//
//  Created by Rishabh Jain on 17/05/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import "ViewFilter.h"
#import "Utility.h"
#import "ViewControllerCategories.h"

#define kStrSortBy @"SORT BY"
#define kStrPriceRange @"PRICE RANGE"
#define kStrStockChk @"STOCK CHECK"
#define kStrDiscount @"DISCOUNT"
#define kStrClearFilter @"CLEAR FILTER"
//#define kStrSortBy @"Sort By"
//#define kStrPriceRange @"Price Range"
//#define kStrStockChk @"Stock Check"
//#define kStrDiscount @"Discount"
//#define kStrClearFilter @"Clear Filter"
enum kSortOptions {
    kSortOptionsFreshArrivals,
    kSortOptionsFeatured,
    kSortOptionsUserRating,
    kSortOptionsPriceHighToLow,
    kSortOptionsPriceLowToHigh,
    kSortOptionsPopularity,
    kSortOptionsTotal
};
NSString *const kStrSortOptions[] = {
    @"Fresh Arrivals",
    @"Featured",
    @"User Rating",
    @"Price - High to Low",
    @"Price - Low to High",
    @"Popularity"
};


@implementation ViewFilter {
    NSArray* sortOptions;
}
- (void)drawRect:(CGRect)rect {
    _allFilters = [[NSMutableArray alloc] init];
    _varFilters = [[NSMutableArray alloc] init];
    _sortOptionsButton = [[NSMutableArray alloc] init];
    _allFiltersView = [[NSMutableArray alloc] init];
    _viewMain.backgroundColor = [UIColor whiteColor];
    _viewTop.backgroundColor = [Utility getUIColor:kUIColorThemeFont];
    _viewLeft.backgroundColor = [UIColor whiteColor];
    _viewRight.backgroundColor = [UIColor whiteColor];
    //    [_viewTop.layer setBorderWidth:1];
    //    [_viewTop.layer setBorderColor:[Utility getUIColor:kUIColorBorder].CGColor];
    [_labelHeader setTextColor:[UIColor whiteColor]];
    [_buttonSave setUIImage:[[UIImage imageNamed:@"drawer"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [_buttonSave setTintColor:[UIColor whiteColor]];
    
    _leftViewBorderRight.backgroundColor = [Utility getUIColor:kUIColorBorder];
}
- (void)setDelegate:(id)myParent{
    _myParent = myParent;
}
- (void)refreshLeftTable {
    /////////////////////////////////
    [_allFilters removeAllObjects];
    for (UIView*view in _allFiltersView) {
        [view removeFromSuperview];
    }
    [_allFiltersView removeAllObjects];
    
    /////////////////////////////////
    [_allFilters addObject:kStrSortBy];
    [_allFilters addObject:kStrPriceRange];
    [_allFilters addObject:kStrStockChk];
    [_allFilters addObject:kStrDiscount];
    for (NSString* str in _varFilters) {
        [_allFilters addObject:str];
    }
    [_allFilters addObject:kStrClearFilter];
    
    /////////////////////////////////
    [self createRightViews];
    [_leftTable reloadData];
    
    [_leftTable setSeparatorColor:[Utility getUIColor:kUIColorBorder]];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [_leftTable selectRowAtIndexPath:indexPath animated:YES  scrollPosition:UITableViewScrollPositionBottom];
    [self cellSetColor:indexPath isSelected:true];
}
- (void)showRightView:(int)tag {
    int i = 0;
    for (UIView*view in _allFiltersView) {
        [view setHidden:true];
        if (tag == i) {
            [view setHidden:false];
        }
        i++;
    }
}
- (void)createRightViews {
    for (NSString* str in _allFilters) {
        UIView* view;
        if ([str isEqualToString:kStrSortBy]) {
            view = [self createSortByView];
        }
        else if ([str isEqualToString:kStrStockChk]) {
            view = [self createStockChkView];
        }
        else if ([str isEqualToString:kStrDiscount]) {
            view = [self createDiscountView];
        }
        else if ([str isEqualToString:kStrClearFilter]) {
            view = [self createClearFilterView];
        }
        else if ([str isEqualToString:kStrPriceRange]) {
            view = [self createPriceRangeView];
        }
        else {
            view = [self createAttributeView];
        }
        
        [_allFiltersView addObject:view];
        [_viewRight addSubview:view];
        [view setHidden:true];
        
        //        if ([str isEqualToString:kStrSortBy]) {
        //            [view setHidden:false];
        //        }
    }
}
- (UIView*)createSortByView {
    float buttonHeight = [[MyDevice sharedManager] screenSize].height * 0.05f;
    UIView* view = [[UIView alloc] init];
    [view setFrame:CGRectMake(0, 0, _viewRight.frame.size.width, _viewRight.frame.size.height)];
    float posX = [[MyDevice sharedManager] screenSize].height * 0.05f;
    //    float posY = [[MyDevice sharedManager] screenSize].height * 0.05f;
    for (int i = 0; i < kSortOptionsTotal; i++) {
        BOOL buttonEnabled = true;
        BOOL buttonChoosed = false;
        UIButton* button = [[UIButton alloc] init];
        [_sortOptionsButton addObject:button];
        [button setTitle:[NSString stringWithFormat:@"\t%@", kStrSortOptions[i]] forState:UIControlStateNormal];
        [button setTitleColor:[Utility getUIColor:kUIColorThemeFont] forState:UIControlStateNormal];
        [button setFrame:CGRectMake(posX, (i + 0.5f) * buttonHeight, view.frame.size.width, buttonHeight)];
        [view addSubview:button];
        [button addTarget:self action:@selector(btnSortSelected:) forControlEvents:UIControlEventTouchUpInside];
        [button setUIImage:[UIImage imageNamed:@"radiobtn_unselected"] forState:UIControlStateNormal];
        [button setUIImage:[UIImage imageNamed:@"radiobtn_selected"] forState:UIControlStateSelected];
        [button setTitleColor:[Utility getUIColor:kUIColorFontLight] forState:UIControlStateNormal];
        [button setTitleColor:[Utility getUIColor:kUIColorFontLight] forState:UIControlStateSelected];
        [button.titleLabel setUIFont:kUIFontType18 isBold:false];
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        if (buttonEnabled == false) {
            [button setEnabled:false];
        }
        if (buttonChoosed) {
            [button setSelected:true];
        }
    }
    return view;
}
- (UIView*)createPriceRangeView {
    UIView* view = [[UIView alloc] init];
    [view setFrame:CGRectMake(0, 0, _viewRight.frame.size.width, _viewRight.frame.size.height)];
    float gap = [[MyDevice sharedManager] screenSize].height * 0.05f;
    float posY = gap;
    float posX = gap;
    float labelHeight = gap;
    UILabel* label = [[UILabel alloc] init];
    label.frame = CGRectMake(posX, posY, view.frame.size.width - posX * 2, labelHeight);
    [label setUIFont:kUIFontType18 isBold:false];
    label.textColor = [Utility getUIColor:kUIColorFontLight];
    [view addSubview:label];
    [label setText:@"Select the price range for the products."];
    [label setNumberOfLines:0];
    [label sizeToFitUI];
    labelHeight = label.frame.size.height;
    posY += labelHeight;
    posY += gap*2;
    
    _rangeSliderCurrency = [[TTRangeSlider alloc] initWithFrame:CGRectMake(posX, posY, view.frame.size.width - posX * 2, gap)];
    [view addSubview:_rangeSliderCurrency];
    _rangeSliderCurrency.delegate = self;
    _rangeSliderCurrency.minValue = 0;
    _rangeSliderCurrency.maxValue = 5000;
    _rangeSliderCurrency.selectedMinimum = 0;
    _rangeSliderCurrency.selectedMaximum = 5000;
    _rangeSliderCurrency.handleDiameter = labelHeight;
    _rangeSliderCurrency.selectedHandleDiameterMultiplier = 1.0f;
    _rangeSliderCurrency.step = _rangeSliderCurrency.maxValue/100.0f;
    _rangeSliderCurrency.enableStep = false;
    [_rangeSliderCurrency setTintColor:[Utility getUIColor:kUIColorThemeFont]];
    
    return view;
}
- (UIView*)createAttributeView {
    UIView* view = [[UIView alloc] init];
    [view setFrame:CGRectMake(0, 0, _viewRight.frame.size.width, _viewRight.frame.size.height)];
    return view;
}
- (UIView*)createClearFilterView {
    UIView* view = [[UIView alloc] init];
    [view setFrame:CGRectMake(0, 0, _viewRight.frame.size.width, _viewRight.frame.size.height)];
    return view;
}
- (UIView*)createDiscountView {
    UIButton* button = [[UIButton alloc] init];
    BOOL buttonEnabled = true;
    BOOL buttonChoosed = false;
    _btnDiscount = button;
    NSString* buttonText = @"Show discount items only.";
    
    
    UIView* view = [[UIView alloc] init];
    [view setFrame:CGRectMake(0, 0, _viewRight.frame.size.width, _viewRight.frame.size.height)];
    float buttonHeight = [[MyDevice sharedManager] screenSize].height * 0.05f;
    float posX = [[MyDevice sharedManager] screenSize].height * 0.05f;
    float posY = buttonHeight;
    [view addSubview:button];
    [button setTitle:[NSString stringWithFormat:@""] forState:UIControlStateNormal];
    [button setTitleColor:[Utility getUIColor:kUIColorThemeFont] forState:UIControlStateNormal];
    [button setFrame:CGRectMake(posX, posY, view.frame.size.width, buttonHeight)];
    [button addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [button setUIImage:[UIImage imageNamed:@"chkbox_unselected"] forState:UIControlStateNormal];
    [button setUIImage:[UIImage imageNamed:@"chkbox_selected"] forState:UIControlStateSelected];
    [button setUIImage:[UIImage imageNamed:@"chkbox_selected"] forState:UIControlStateHighlighted];
    [button setTitleColor:[Utility getUIColor:kUIColorFontLight] forState:UIControlStateNormal];
    [button setTitleColor:[Utility getUIColor:kUIColorFontLight] forState:UIControlStateSelected];
    [button setShowsTouchWhenHighlighted:false];
    [button.titleLabel setUIFont:kUIFontType18 isBold:false];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    if (buttonEnabled == false) {
        [button setEnabled:false];
    }
    if (buttonChoosed) {
        [button setSelected:true];
    }
    UILabel* label = [[UILabel alloc] init];
    [view addSubview:label];
    label.frame = CGRectMake(posX * 2, posY, view.frame.size.width - posX * 2, 0);
    [label setUIFont:kUIFontType18 isBold:false];
    label.textColor = [Utility getUIColor:kUIColorFontLight];
    [label setText:buttonText];
    [label setNumberOfLines:0];
    [label sizeToFitUI];
    CGRect labelRect = label.frame;
    labelRect.size.height = MAX(labelRect.size.height, button.frame.size.height);
    label.frame = labelRect;
    return view;
}
- (UIView*)createStockChkView {
    UIButton* button = [[UIButton alloc] init];
    BOOL buttonEnabled = true;
    BOOL buttonChoosed = false;
    _btnStock = button;
    NSString* buttonText = @"Exclude out of stock items.";
    
    
    UIView* view = [[UIView alloc] init];
    [view setFrame:CGRectMake(0, 0, _viewRight.frame.size.width, _viewRight.frame.size.height)];
    float buttonHeight = [[MyDevice sharedManager] screenSize].height * 0.05f;
    float posX = [[MyDevice sharedManager] screenSize].height * 0.05f;
    float posY = buttonHeight;
    [view addSubview:button];
    [button setTitle:[NSString stringWithFormat:@""] forState:UIControlStateNormal];
    [button setTitleColor:[Utility getUIColor:kUIColorThemeFont] forState:UIControlStateNormal];
    [button setFrame:CGRectMake(posX, posY, view.frame.size.width, buttonHeight)];
    [button addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [button setUIImage:[UIImage imageNamed:@"chkbox_unselected"] forState:UIControlStateNormal];
    [button setUIImage:[UIImage imageNamed:@"chkbox_selected"] forState:UIControlStateSelected];
    [button setUIImage:[UIImage imageNamed:@"chkbox_selected"] forState:UIControlStateHighlighted];
    [button setTitleColor:[Utility getUIColor:kUIColorFontLight] forState:UIControlStateNormal];
    [button setTitleColor:[Utility getUIColor:kUIColorFontLight] forState:UIControlStateSelected];
    [button.titleLabel setUIFont:kUIFontType18 isBold:false];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    if (buttonEnabled == false) {
        [button setEnabled:false];
    }
    if (buttonChoosed) {
        [button setSelected:true];
    }
    UILabel* label = [[UILabel alloc] init];
    [view addSubview:label];
    label.frame = CGRectMake(posX * 2, posY, view.frame.size.width - posX * 2, 0);
    [label setUIFont:kUIFontType18 isBold:false];
    label.textColor = [Utility getUIColor:kUIColorFontLight];
    [label setText:buttonText];
    [label setNumberOfLines:0];
    [label sizeToFitUI];
    CGRect labelRect = label.frame;
    labelRect.size.height = MAX(labelRect.size.height, button.frame.size.height);
    label.frame = labelRect;
    return view;
}

#pragma mark Events
- (void)btnClicked:(UIButton*)sender {
    [sender setSelected:![sender isSelected]];
}
- (void)btnSortSelected:(UIButton*)sender {
    for (UIButton*button in _sortOptionsButton) {
        if (sender == button) {
            [button setSelected:true];
        }else{
            [button setSelected:false];
        }
    }
}
- (IBAction)saveFilter:(id)sender {
    if (_myParent) {
        ViewControllerCategories* vcCategories = _myParent;
        [vcCategories btnFilterClicked:sender];
    }
}
- (IBAction)toggleFilterViewSize:(id)sender {
    if (_myParent) {
        ViewControllerCategories* vcCategories = _myParent;
        [vcCategories toggleFilterViewSize];
    }
}
- (void)cellSetColor:(NSIndexPath*)indexPath isSelected:(BOOL)isSelected {
    UITableViewCell *cell = [_leftTable cellForRowAtIndexPath:indexPath];
    if (isSelected) {
        //        cell.selectedBackgroundView.backgroundColor = [Utility getUIColor:kUIColorThemeFont];
        //        cell.backgroundColor = [Utility getUIColor:kUIColorThemeFont];
        //        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.textColor = [Utility getUIColor:kUIColorFontDark];
        [self showRightView:(int)indexPath.row];
    }else{
        //        cell.selectedBackgroundView.backgroundColor = [UIColor whiteColor];
        //        cell.backgroundColor = [UIColor whiteColor];
        //        cell.textLabel.textColor = [Utility getUIColor:kUIColorThemeFont];
        cell.textLabel.textColor = [Utility getUIColor:kUIColorFontLight];
    }
}
#pragma mark TTRangeSliderViewDelegate
- (void)rangeSlider:(TTRangeSlider *)sender didChangeSelectedMinimumValue:(float)selectedMinimum andMaximumValue:(float)selectedMaximum {
    if (sender == _rangeSliderCurrency) {
        RLOG(@"Currency slider updated. Min Value: %.0f Max Value: %.0f", selectedMinimum, selectedMaximum);
    }
}
@end
