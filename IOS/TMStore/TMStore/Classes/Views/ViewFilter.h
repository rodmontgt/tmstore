//
//  ViewFilter.h
//  TMStore
//
//  Created by Rishabh Jain on 17/05/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTRangeSlider.h"
enum kFilterView {
    kFilterViewSortBy,
    kFilterViewPriceRange,
    kFilterViewStockCheck,
    kFilterViewDiscount,
    kFilterViewClearFilter,
    kFilterViewOther
};
@interface ViewFilter : UIView <TTRangeSliderDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewMain;
@property (weak, nonatomic) IBOutlet UIView *viewTop;
@property (weak, nonatomic) IBOutlet UIView *viewLeft;
@property (weak, nonatomic) IBOutlet UIView *viewRight;
@property (weak, nonatomic) IBOutlet UILabel *labelHeader;
@property (weak, nonatomic) IBOutlet UIButton *buttonSave;
@property (weak, nonatomic) IBOutlet UITableView *leftTable;
-(IBAction)saveFilter:(id)sender;
-(IBAction)toggleFilterViewSize:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *leftViewBorderRight;
-(void)setDelegate:(id)myParent;
@property id myParent;
@property NSMutableArray *allFilters;
@property NSMutableArray *allFiltersView;

@property NSMutableArray *varFilters;
- (void)refreshLeftTable;
- (void)showRightView:(int)tag;
- (void)cellSetColor:(NSIndexPath*)indexPath isSelected:(BOOL)isSelected;

@property NSMutableArray *sortOptionsButton;
@property TTRangeSlider *rangeSliderCurrency;
@property UIButton* btnDiscount;
@property UIButton* btnStock;
@end
