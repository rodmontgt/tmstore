//
//  SellerProfileProductColCell.h
//  TMStore
//
//  Created by Twist Mobile on 02/01/18.
//  Copyright © 2018 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SellerProfileProductColCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgProfile;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelShopName;
@property (weak, nonatomic) IBOutlet UILabel *labelPhoneNo;
@property (weak, nonatomic) IBOutlet UILabel *labelAShopAddress;

@property id parentVC;
@property id productObj;
@end
