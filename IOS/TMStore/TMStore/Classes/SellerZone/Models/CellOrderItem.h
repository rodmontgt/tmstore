//
//  CellOrderItem.h
//  TMStore
//
//  Created by Rajshekhar on 19/07/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CellOrderItem : UITableViewCell <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIImageView *orderImage;
@property (weak, nonatomic) IBOutlet UILabel *labelOrderName;
@property (weak, nonatomic) IBOutlet UILabel *labelOrderStatus;
@property (weak, nonatomic) IBOutlet UILabel *labelAmount;
@property (weak, nonatomic) IBOutlet UIButton *buttonShowMore;

@property (weak, nonatomic) IBOutlet UILabel *labelOrderId;

@property (weak, nonatomic) IBOutlet UILabel *labelOrderDate;
@property (weak, nonatomic) IBOutlet UILabel *labelCurrency;
@property (weak, nonatomic) IBOutlet UILabel *lblOrder;

@end
