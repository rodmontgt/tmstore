//
//  CTableViewCellLogin.m
//  eMobileApp
//
//  Created by V S Khutal on 28/10/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import "CTableViewCellLogin.h"

@implementation CTableViewCellLogin

@synthesize baseView = _baseView;
@synthesize imgUserBg = _imgUserBg;
@synthesize imgUser = _imgUser;
@synthesize labelUserName = _labelUserName;
@synthesize labelUserId = _labelUserId;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
