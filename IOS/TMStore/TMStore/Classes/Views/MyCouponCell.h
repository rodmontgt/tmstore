//
//  MyCouponCell.h
//  TMStore
//
//  Created by Twist Mobile on 16/01/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyCouponCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *btnCoupone;
@property (weak, nonatomic) IBOutlet UIButton *apply;
@property (weak, nonatomic) IBOutlet UILabel *lblDescription;
@property (weak, nonatomic) IBOutlet UILabel *lblAmount;
@property (weak, nonatomic) IBOutlet UILabel *lblExpiry_Date;
@property (weak, nonatomic) IBOutlet UIButton *showMore;
@property (weak, nonatomic) IBOutlet UILabel *lblDiscountApplyon;
@property (weak, nonatomic) IBOutlet UILabel *lblCanNOT;
@property (weak, nonatomic) IBOutlet UILabel *lblShiping;

@end
