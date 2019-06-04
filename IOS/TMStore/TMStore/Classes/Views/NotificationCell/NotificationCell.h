//
//  NotificationCell.h
//  TMStore
//
//  Created by Twist Mobile on 28/02/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *Title;
@property (weak, nonatomic) IBOutlet UILabel *Description;
@property (weak, nonatomic) IBOutlet UILabel *DateAndTime;
@property (weak, nonatomic) IBOutlet UIButton *buttonicone;
@property (weak, nonatomic) IBOutlet UIView *viewBackground;

@end
