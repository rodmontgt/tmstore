//
//  CellOldCard.m
//  SOUQ
//
//  Created by Twist Mobile on 26/09/17.
//  Copyright © 2017 TwistMobile. All rights reserved.
//

#import "CellOldCard.h"
#import <QuartzCore/QuartzCore.h>

@implementation CellOldCard

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        [self.buttonRadio setSelected:true];
        [self.labelCardNumber setFont:[UIFont boldSystemFontOfSize:17]];
    } else {
        [self.buttonRadio setSelected:false];
        [self.labelCardNumber setFont:[UIFont systemFontOfSize:18]];
    }
}

@end
