//
//  ViewControllerOpinion.h

//
//  Created by Rishabh Jain on 24/09/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Variables.h"
#import "ProductInfo.h"

@interface PairOpinion : NSObject
@property UIButton *buttonLike;
@property UIButton *buttonDislike;
@property UIButton *buttonCart;
@property ProductInfo *product;
@property UIButton *buttonImage;
@end

@interface ViewControllerOpinion: UIViewController

- (void)initVariables;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *labelNoItems;

@property UIView* finalAmountView;
@property UIButton* placeOrderButton;

@property UILabel* labelTotalItems;
@property UILabel* labelGrandTotal;
@end