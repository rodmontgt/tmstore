//
//  LoginViewOnDrawer.h
//  eMobileApp
//
//  Created by Rishabh Jain on 30/10/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewOnDrawer : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *baseView;
@property (weak, nonatomic) IBOutlet UIImageView *imgUserBg;
@property (weak, nonatomic) IBOutlet UIImageView *imgUser;
@property (weak, nonatomic) IBOutlet UILabel *labelUserName;
@property (weak, nonatomic) IBOutlet UILabel *labelUserId;
@property (strong, nonatomic) IBOutlet UIImageView *imgTopLine;
@property (strong, nonatomic) IBOutlet UIImageView *imgBottomLine;
@end
