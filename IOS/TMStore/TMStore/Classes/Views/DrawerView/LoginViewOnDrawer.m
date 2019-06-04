//
//  LoginViewOnDrawer.m
//  eMobileApp
//
//  Created by Rishabh Jain on 30/10/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import "LoginViewOnDrawer.h"
#import "MyDevice.h"
@implementation LoginViewOnDrawer

@synthesize baseView = _baseView;
@synthesize imgUserBg = _imgUserBg;
@synthesize imgUser = _imgUser;
@synthesize labelUserName = _labelUserName;
@synthesize labelUserId = _labelUserId;
@synthesize imgBottomLine = _imgBottomLine;
@synthesize imgTopLine = _imgTopLine;

- (void)awakeFromNib {
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


//- (void) layoutSubviews
//{
//    [super layoutSubviews];
    
//    self.imgUserBg.layer.cornerRadius = self.imgUserBg.frame.size.height / 2;
//    self.imgUserBg.layer.masksToBounds = YES;
//    self.imgUserBg.layer.borderWidth = 0;
//    
//    self.imgUser.layer.cornerRadius = self.imgUser.frame.size.height / 2;
//    self.imgUser.layer.masksToBounds = YES;
//    self.imgUser.layer.borderWidth = 0;
//    
//    float imgCenter = [[MyDevice sharedManager]screenSize].width * .15f;
//    float imgWidth = self.imgUserBg.frame.size.width;
//    float labelCenter1 = imgCenter + imgWidth + self.labelUserName.frame.size.width * .5f;
//    float labelCenter2 = imgCenter + imgWidth + self.labelUserId.frame.size.width * .5f;
//    
//    if(labelCenter1 > labelCenter2)
//        labelCenter2 = labelCenter1;
//    else
//        labelCenter1 = labelCenter2;
//    
//    self.imgUser.center = CGPointMake(imgCenter, self.imgUser.center.y);
//    self.imgUserBg.center = CGPointMake(imgCenter, self.imgUserBg.center.y);
//    self.labelUserName.center = CGPointMake(labelCenter1, self.labelUserName.center.y);
//    self.labelUserId.center = CGPointMake(labelCenter2, self.labelUserId.center.y);
//}
@end
