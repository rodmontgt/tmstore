//
//  DynamicCellCategory.h
//  TMStore
//
//  Created by Raj Shekar on 27/10/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DynamicCellCategory : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIView *categoryView;
@property (weak, nonatomic) IBOutlet UIImageView *imageCategory;
@property (weak, nonatomic) IBOutlet UILabel *labelCategoryName;

@end
