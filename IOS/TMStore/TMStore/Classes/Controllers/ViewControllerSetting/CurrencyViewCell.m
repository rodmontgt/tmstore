//
//  CurrencyViewCell.m
//  TMStore
//
//  Created by Vikas Patidar on 15/01/18.
//  Copyright © 2018 Twist Mobile. All rights reserved.
//

#import "CurrencyViewCell.h"

@implementation CurrencyViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _imageCurrency.layer.cornerRadius = 15;
    _imageCurrency.layer.masksToBounds = YES;

    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
