//
//  CellProductImage.h
//  TMStore
//
//  Created by Rishabh Jain on 19/08/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CellProductImage : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *view_content;
@property (weak, nonatomic) IBOutlet UIImageView *img_product;
@property (weak, nonatomic) IBOutlet UIButton *btn_remove;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
