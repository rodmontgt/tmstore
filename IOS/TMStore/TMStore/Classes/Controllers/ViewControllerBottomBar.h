//
//  ViewControllerBottomBar.h

//
//  Created by Rishabh Jain on 24/09/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Variables.h"




@interface ViewControllerBottomBar : UIViewController

@property UIButton *buttonHome;
@property UIButton *buttonLiveChat;
@property UIButton *buttonWishlist;
@property UIButton *buttonCart;
@property UIButton *buttonSearch;
@property UIButton *buttonMyAccount;
@property UIButton *buttonOpinion;

@property UILabel *labelHome;
@property UILabel *labelLiveChat;
@property UILabel *labelSearch;
@property UILabel *labelCart;
@property UILabel *labelWishlist;
@property UILabel *labelMyAccount;
@property UILabel *labelOpinion;

@property UIImageView* nBgCart;
@property UIImageView* nnBgCart;
@property UIImageView* nBgWishlist;
@property UIImageView* nnBgWishlist;
@property UILabel* nLabelCart;
@property UILabel* nLabelWishlist;

- (void)buttonClicked:(UIButton*)button;
@property NSMutableArray* homeMenuArray;
@property NSMutableArray* buttons;
@property NSMutableArray* labels;
- (void)arrangeUI;
@end
