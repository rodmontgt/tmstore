//
//  CellProductImage.m
//  TMStore
//
//  Created by Rishabh Jain on 19/08/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import "CellProductImage.h"

@implementation CellProductImage

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.btn_remove.layer setCornerRadius:self.btn_remove.frame.size.width/2];
    [self.btn_remove setBackgroundColor:[UIColor redColor]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
@end
