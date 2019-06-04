//
//  CellCategoryDetails.m
//  TMStore
//
//  Created by Rajshekhar on 25/07/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import "CellCategoryDetails.h"
#import "CategoryInfo.h"
#import "SellerZoneManager.h"


@implementation CellCategoryDetails

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _checked = NO;
    if (_checked) {
        [_buttonCheckMark setImage:[[UIImage imageNamed:@"managing_icon_selected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    } else {
        [_buttonCheckMark setImage:[[UIImage imageNamed:@"managing_icon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    }
    _buttonCheckMark.tintColor = [UIColor darkGrayColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)initButtonCheckMark:(UIButton*)button {
    id obj = [button.layer valueForKey:@"CATEGORY_OBJECT"];
    if (obj && [obj isKindOfClass:[CategoryInfo class]]) {
        if ([[[SellerZoneManager getInstance] tempProduct] szHasCategoryId:((CategoryInfo*)obj)._id]) {
            _checked = true;
            [self resetButtonCheckMark:button];
        } else {
            _checked = false;
            [self resetButtonCheckMark:button];
        }
    } else {
        _checked = false;
        [self resetButtonCheckMark:button];
    }
}
- (void)isButtonEnableForCategory:(CategoryInfo*)cInfo button:(UIButton*)button {
    if (cInfo && [cInfo isKindOfClass:[CategoryInfo class]]){
        Addons* addons = [Addons sharedManager];
        if(addons.multiVendor && addons.multiVendor.multiVendor_shop_settings) {
            ShopSettings* sSettings = addons.multiVendor.multiVendor_shop_settings;
            if (sSettings && sSettings.show_parent_categories == false) {
                NSArray* cInfoSubcategories = [cInfo getSubCategories];
                if(cInfoSubcategories && [cInfoSubcategories count] > 0) {
                    if ([button isHidden] != true) {
                        [button setHidden:true];
                        [self.buttonWidthConstraint setConstant:0];
                        [self updateConstraints];
                    }
                } else {
                    if ([button isHidden] != false) {
                        [button setHidden:false];
                        [self.buttonWidthConstraint setConstant:30];
                        [self updateConstraints];
                    }
                }
            }
        }
    } else {
        if ([button isHidden] != false) {
            [button setHidden:false];
            [self.buttonWidthConstraint setConstant:30];
            [self updateConstraints];
        }
    }
    
}
- (void)resetButtonCheckMark:(UIButton*)button {
    id obj = [button.layer valueForKey:@"CATEGORY_OBJECT"];
    
    if (_checked) {
        if (obj && [obj isKindOfClass:[CategoryInfo class]]) {
            [[[SellerZoneManager getInstance] tempProduct] szAddCategoryId:((CategoryInfo*)obj)._id];
        }
        [button setImage:[[UIImage imageNamed:@"managing_icon_selected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    } else {
        if (obj && [obj isKindOfClass:[CategoryInfo class]]) {
            [[[SellerZoneManager getInstance] tempProduct] szRemoveCategoryId:((CategoryInfo*)obj)._id];
        }
        [button setImage:[[UIImage imageNamed:@"managing_icon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    }
    button.tintColor = [UIColor darkGrayColor];
}
- (IBAction)buttonCheckMarkAction:(id)sender{
    _checked = !_checked;
    UIButton* button = (UIButton*)sender;
    [self resetButtonCheckMark:button];
}
@end
