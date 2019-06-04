//
//  ProductCollectionViewCellTemp.h
//  TMStore
//
//  Created by Rajshekhar on 19/07/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductCollectionViewCellTemp : UICollectionViewCell <UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageProduct;
@property (weak, nonatomic) IBOutlet UILabel *labelProductName;
@property (weak, nonatomic) IBOutlet UILabel *labelProductPriceNew;
@property (weak, nonatomic) IBOutlet UILabel *labelProductPriceOld;
@property (weak, nonatomic) IBOutlet UILabel *labelCrossLine;

@property (weak, nonatomic) IBOutlet UIButton *buttonWishlist;

@property id parentVC;
@property id productObj;
@end
