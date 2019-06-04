//
//  ProductCollectionViewCell.h
//  TMStore
//
//  Created by Rajshekhar on 19/07/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCProducts.h"

@interface ProductCollectionViewCell : UICollectionViewCell <UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageProduct;
@property (weak, nonatomic) IBOutlet UILabel *labelProductName;
@property (weak, nonatomic) IBOutlet UILabel *labelProductPriceNew;
@property (weak, nonatomic) IBOutlet UILabel *labelProductPriceOld;
@property (weak, nonatomic) IBOutlet UILabel *labelCrossLine;
@property (weak, nonatomic) IBOutlet UIButton *buttonOptions;
@property id parentVC;
@property id productObj;
@end
