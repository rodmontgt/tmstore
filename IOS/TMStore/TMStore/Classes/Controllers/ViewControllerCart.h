//
//  ViewControllerCart.h

//
//  Created by Rishabh Jain on 24/09/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Cart.h"
#import "Variables.h"
#import "LayoutProperties.h"
#import "CategoryInfo.h"
#import "ProductInfo.h"
#import "AppDelegate.h"

@interface PairCart : NSObject
@property UIButton *buttonLeft;
@property UIButton *buttonRight;
@property UIButton *buttonImage;
@property Cart *cart;
@property UITextField *textFieldQuantity;
@property UILabel *labelFinalPrice;
@property UIBarButtonItem* cancelBtn;
@property UIBarButtonItem* doneBtn;
@end



enum HORIZONTAL_VIEWS_CART_SCREEN{
    _kCrossSell,
    _kTotalViewsCartScreen
};
@interface ViewControllerCart: UIViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout ,UITextFieldDelegate, UITextViewDelegate>{
    NSString *_viewKey[_kTotalViewsCartScreen];
    NSString *_viewUserDefinedHeaderString[_kTotalViewsCartScreen];
    UILabel *_viewUserDefinedHeader[_kTotalViewsCartScreen];
    LayoutProperties *_propCollectionView[_kTotalViewsCartScreen];
    UICollectionView *_viewUserDefined[_kTotalViewsCartScreen];
    BOOL _isViewUserDefinedEnable[_kTotalViewsCartScreen];
}

- (void)initVariables;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *labelNoItems;
@property UIView* couponView;
@property UIView* couponViewWithTextField;
@property UIView* couponViewWithAppliedCoupon;
@property UIView *footerView;
@property ProductInfo* pInfo;

@property UIView* finalAmountView;
@property UIButton* placeOrderButton;

@property UILabel* labelTotalItems;
@property UILabel* labelGrandTotal;

//@property UITextField* textInputQuantity;

@property PairCart* cartNeedToMoveToWishlist;

@property UITextField* textFieldApplyCoupon;


@property UITextField *textFieldQuantityEdit;
@property BOOL isKeyboardVisible;
//@property UITapGestureRecognizer* tapper;
@property UIAlertView* alertViewUpdateCart;
@property BOOL isPlaceOrderClicked;
@property NSMutableArray* cartNotesTextViews;

@property UITextView* textViewFirstResponder;


@property UIButton* buttonApplyRewardDiscount;
@property UILabel* labelApplyRewardDiscountHeading;
@property UILabel* labelApplyRewardDiscountDesc;
@property UIView* rewardDiscountView;
@property UIView* rewardDiscountViewWithTextField;
@property BOOL rewardPointsApplied;


@property UIView* autoAppliedCouponView;
@property BOOL isLoadingAppliedCoupon;
@property UIButton* keepShoppingButton;
@property NSString* strCollectionView2;
@property NSString* strCollectionView3;
- (void)passCouponCode:(NSString*)couponCodeStr;
@property NSString* userSelectedCouponCode;
@end
