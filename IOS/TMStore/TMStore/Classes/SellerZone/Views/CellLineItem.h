//
//  CellLineItem.h
//  TMStore
//
//  Created by Rajshekhar on 19/07/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CellLineItem : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *orderImage;
@property (weak, nonatomic) IBOutlet UILabel *labelOrderName;
@property (weak, nonatomic) IBOutlet UILabel *labelOrderPrice;
@property (weak, nonatomic) IBOutlet UILabel *labelQuantity;
@property (weak, nonatomic) IBOutlet UILabel *labelTotal;
@property (weak, nonatomic) IBOutlet UILabel *labelCurrencyTotal;
@property (weak, nonatomic) IBOutlet UILabel *labelCurrencyPrice;
@property (weak, nonatomic) IBOutlet UILabel *labelOrderPriceString;
@property (weak, nonatomic) IBOutlet UILabel *labelQuantityString;
@property (weak, nonatomic) IBOutlet UILabel *labelTotalString;


@end
