//
//  PSprofileCell.m
//  TMStore
//
//  Created by Twist Mobile on 30/11/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import "PSprofileCell.h"
@implementation PSprofileCell
- (void)awakeFromNib {
    [super awakeFromNib];
    _btnAddProfileIcon.layer.borderWidth = 1.0f;
    _btnAddProfileIcon.layer.borderColor = [[UIColor blackColor] CGColor];
    
    [_btnRemoveProfileIcon setBackgroundColor:[UIColor redColor]];
    [_btnRemoveProfileIcon.layer setCornerRadius:12.5f];
    [_btnRemoveProfileIcon setTitle:@"-" forState:UIControlStateNormal];
    [_btnRemoveProfileIcon setTitle:@"-" forState:UIControlStateHighlighted];
    [_btnRemoveProfileIcon setTitle:@"-" forState:UIControlStateSelected];
    [_btnRemoveProfileIcon setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_btnRemoveProfileIcon setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [_btnRemoveProfileIcon setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    
    UIImage* buttonImg = [[UIImage imageNamed:@"camera _icon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_btnAddProfileIcon setImage:buttonImg forState:UIControlStateNormal];
    [_btnAddProfileIcon setImage:buttonImg forState:UIControlStateSelected];
    [_btnAddProfileIcon setTintColor:self.tintColor];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}
@end
