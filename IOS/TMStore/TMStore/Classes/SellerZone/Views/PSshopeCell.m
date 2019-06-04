//
//  PSshopeCell.m
//  TMStore
//
//  Created by Twist Mobile on 30/11/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import "PSshopeCell.h"
#import "TMLanguage.h"
@implementation PSshopeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _btnAddShopIcon.layer.borderWidth = 1.0f;
    _btnAddShopIcon.layer.borderColor = [[UIColor blackColor] CGColor];
    
    [_btnRemoveShopIcon setBackgroundColor:[UIColor redColor]];
    [_btnRemoveShopIcon.layer setCornerRadius:12.5f];
    [_btnRemoveShopIcon setTitle:@"-" forState:UIControlStateNormal];
    [_btnRemoveShopIcon setTitle:@"-" forState:UIControlStateHighlighted];
    [_btnRemoveShopIcon setTitle:@"-" forState:UIControlStateSelected];
    [_btnRemoveShopIcon setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_btnRemoveShopIcon setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [_btnRemoveShopIcon setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    
    [_label_shop_icon setText:Localize(@"title_seller_icon")];
    
    
    UIImage* buttonImg = [[UIImage imageNamed:@"camera _icon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_btnAddShopIcon setImage:buttonImg forState:UIControlStateNormal];
    [_btnAddShopIcon setImage:buttonImg forState:UIControlStateSelected];
    [_btnAddShopIcon setTintColor:self.tintColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
