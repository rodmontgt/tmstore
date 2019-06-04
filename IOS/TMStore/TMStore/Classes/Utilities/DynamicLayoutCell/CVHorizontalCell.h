//
//  CVHorizontalCell.h
//  TMStore
//
//  Created by Raj shekar on 17/11/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CVHorizontalCell : UICollectionViewCell
<UICollectionViewDelegate,UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *labelCategoryName;
@property (weak, nonatomic) IBOutlet UIButton *buttonViewAll;
@property (weak, nonatomic) IBOutlet UICollectionView *cvHorizontalCategory;
@property NSString* strCollectionView3;
@property NSMutableArray* productsArray;
@property NSTimer* t;
@end
