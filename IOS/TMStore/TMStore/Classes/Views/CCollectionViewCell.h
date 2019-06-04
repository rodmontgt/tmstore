//
//  CCollectionViewCell.h
//  eMobileApp
//
//  Created by Rishabh Jain on 13/10/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ProductInfo.h"

@interface CCollectionViewCell: UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIView *baseView;
@property (weak, nonatomic) IBOutlet UIImageView *productImg;
@property (weak, nonatomic) IBOutlet UIImageView *productImgDummy;
@property (weak, nonatomic) IBOutlet UILabel *productName;
@property (weak, nonatomic) IBOutlet UILabel *productPriceOriginal;
@property (weak, nonatomic) IBOutlet UILabel *productPriceFinal;
//TODO DISTANCE.....
@property (weak, nonatomic) IBOutlet UILabel *productDistance;
@property (strong, nonatomic) IBOutlet UIButton *buttonWishlist;
@property (weak, nonatomic) IBOutlet UIImageView *imgHeaderBg;
@property (weak, nonatomic) IBOutlet UILabel *labelExploreNow;
@property (weak, nonatomic) IBOutlet UIView *viewAddToCart;
@property (strong, nonatomic) IBOutlet UIButton *buttonCart;
@property (weak, nonatomic) IBOutlet UIButton *buttonSubstract;
@property (weak, nonatomic) IBOutlet UIButton *buttonAdd;
@property (weak, nonatomic) IBOutlet UITextField *textFieldAmt;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *actIndicator;
- (void)refreshCell:(ProductInfo*)pInfo;
- (void)refreshCellMixNMatch:(ProductInfo*)pInfo qty:(int)qty;
- (void)updateCell:(NSNotification*)notification;
#pragma mark Only for Discount Layout ie ProductCellType5_Cart
@property (weak, nonatomic) IBOutlet UIImageView *imgDiscountBg;
@property (weak, nonatomic) IBOutlet UILabel *labelDiscount;
@property (weak, nonatomic) IBOutlet UILabel *labelProductDescription;
@property (weak, nonatomic) IBOutlet UIButton *btnShowMore;
@property (weak, nonatomic) IBOutlet UIImageView *imageHeader;
@property (weak, nonatomic) IBOutlet UIView *viewBG;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;

@end
