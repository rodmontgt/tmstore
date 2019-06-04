//
//  CurrencyViewCell.h
//  TMStore
//
//  Created by Vikas Patidar on 15/01/18.
//  Copyright © 2018 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CurrencyViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageCurrency;
@property (weak, nonatomic) IBOutlet UILabel *currencyName;
@property (weak, nonatomic) IBOutlet UILabel *currencyDesc;
@property (weak, nonatomic) IBOutlet UIButton *buttonCheck;

@end
