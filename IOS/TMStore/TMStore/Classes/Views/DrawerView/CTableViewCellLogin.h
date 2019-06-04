//
//  CTableViewCellLogin.h
//  eMobileApp
//
//  Created by V S Khutal on 28/10/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CTableViewCellLogin : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *baseView;
@property (weak, nonatomic) IBOutlet UIImageView *imgUserBg;
@property (weak, nonatomic) IBOutlet UIImageView *imgUser;
@property (weak, nonatomic) IBOutlet UILabel *labelUserName;
@property (weak, nonatomic) IBOutlet UILabel *labelUserId;

@end
