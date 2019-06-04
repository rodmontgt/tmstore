//
//  PSshopeCell.h
//  TMStore
//
//  Created by Twist Mobile on 30/11/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PSshopeCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *btnAddShopIcon;
@property (weak, nonatomic) IBOutlet UIButton *btnRemoveShopIcon;
@property (weak, nonatomic) IBOutlet UIImageView *imageShopIcon;
@property (weak, nonatomic) IBOutlet UILabel *label_shop_icon;

@end
