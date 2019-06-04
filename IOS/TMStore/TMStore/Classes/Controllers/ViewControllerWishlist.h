//
//  ViewControllerWishlist.h

//
//  Created by Rishabh Jain on 24/09/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Variables.h"
#import "Wishlist.h"

@interface PairWishlist : NSObject
@property UIButton *buttonLeft;
@property UIButton *buttonRight;
@property Wishlist *wishlist;
@property UIButton *buttonImage;
@end

@interface ViewControllerWishlist: UIViewController

- (void)initVariables;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *labelNoItems;

@property UIView* finalAmountView;
@property UIButton* placeOrderButton;

@property UILabel* labelTotalItems;
@property UILabel* labelGrandTotal;

@property UIButton *shareWishlistButton;

@property UIView* footerView;
@end
