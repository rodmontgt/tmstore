//
//  CCollectionViewCell.m
//  eMobileApp
//
//  Created by Rishabh Jain on 13/10/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import "CCollectionViewCell.h"
#import "Utility.h"
#import "ViewControllerCategories.h"
#import "DataManager.h"
#import "Addons.h"
#import "Cart.h"


@implementation CCollectionViewCell
//@synthesize baseView = _baseView;
//@synthesize productImg = _productImg;
//@synthesize productName = _productName;
//@synthesize productPriceOriginal = _productPriceOriginal;
//@synthesize productPriceFinal = _productPriceFinal;
//@synthesize buttonWishlist = _buttonWishlist;
//@synthesize buttonCart = _buttonCart;
//@synthesize buttonAdd = _buttonAdd;
//@synthesize buttonSubstract = _buttonSubstract;
//@synthesize textFieldAmt = _textFieldAmt;


- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    CGPoint buttonWishlistHit = [_buttonWishlist convertPoint:point fromView:self];
    CGPoint buttonCartHit = [_buttonCart convertPoint:point fromView:self];
    CGPoint productImgHit = [_productImg convertPoint:point fromView:self];
    CGPoint buttonAddHit = [_buttonAdd convertPoint:point fromView:self];
    CGPoint buttonSubstractHit = [_buttonSubstract convertPoint:point fromView:self];
    CGPoint textFieldAmt = [_textFieldAmt convertPoint:point fromView:self];

    if ([_buttonWishlist pointInside:buttonWishlistHit withEvent:event] && _buttonWishlist.isHidden == false) {
        return _buttonWishlist;
    }
    else if ([_productImg pointInside:productImgHit withEvent:event] && _productImg.isHidden == false) {
        return _productImg;
    }
    else if ([_buttonCart pointInside:buttonCartHit withEvent:event] && _buttonCart.isHidden == false) {
        return _buttonCart;
    }
    else if ([_buttonAdd pointInside:buttonAddHit withEvent:event] && _buttonAdd.isHidden == false) {
        return _buttonAdd;
    }
    else if ([_buttonSubstract pointInside:buttonSubstractHit withEvent:event] && _buttonSubstract.isHidden == false) {
        return _buttonSubstract;
    }
//    else if ([_textFieldAmt pointInside:textFieldAmt withEvent:event] && _textFieldAmt.isHidden == false) {
//        return _textFieldAmt;
//    }
    return [super hitTest:point withEvent:event];
}
// Lazy loading of the imageView
//- (UIImageView *)_productImg
//{
//    if (!_productImg) {
//        _productImg = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
//        [self.contentView addSubview:_productImg];
//    }
//    return self._productImg;
//}
//
////// Here we remove all the custom stuff that we added to our subclassed cell
//-(void)prepareForReuse
//{
//    [super prepareForReuse];
//    
//    [_productImg removeFromSuperview];
//    _productImg = nil;
//}
//- (id)initWithCoder:(NSCoder *)aDecoder {
//    self = [super initWithCoder:aDecoder];
//    if(self) {
//        
//        // 1. Load .xib file
//        NSString *className = NSStringFromClass([self class]);
//        _customView = [[[NSBundle mainBundle] loadNibNamed:className owner:self options:nil] firstObject];
//        
//        // 2. Add as a subview
//        [self addSubview:_customView];
//        
//    }
//    return self;
//}
//- (void)awakeFromNib
//{
//    [super awakeFromNib];
//    self.contentView.frame = self.bounds;
//    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//}
//- (void)layoutSubviews
//{
//    BOOL contentViewIsAutoresized = CGSizeEqualToSize(self.frame.size, self.contentView.frame.size);
//    
//    if( !contentViewIsAutoresized) {
//        CGRect contentViewFrame = self.contentView.frame;
//        contentViewFrame.size = self.frame.size;
//        self.contentView.frame = contentViewFrame;
//    }
//}
- (void)layoutSubviews
{
    [super layoutSubviews];
    ProductInfo* pInfo = (ProductInfo*)([self.layer valueForKey:@"PINFO_OBJ"]);
    if (pInfo) {
        [self refreshCell:pInfo];
    }else {
        [self refreshCell:nil];
    }
}
- (void)updateCell:(NSNotification*)notification{
    RLOG(@"updateCell = CELL = %@", self);
    if(notification.object){
        ProductInfo* pInfo = (ProductInfo*)(notification.object);
        ProductInfo* pInfoC = (ProductInfo*)([self.layer valueForKey:@"PINFO_OBJ"]);
        if (pInfo != pInfoC || pInfo == nil || pInfoC == nil) {
            return;
        }
        RLOG(@"pInfo title = %@", pInfo._titleForOuterView);
        if (pInfo._variations && [pInfo._variations count] > 0) {
            
        } else {
            int availState = [Cart getProductAvailibleState:pInfo variationId:-1];
            if (availState == PRODUCT_QTY_DEMAND || availState == PRODUCT_QTY_STOCK)
            {
                [Cart addProduct:pInfo variationId:-1 variationIndex:-1 selectedVariationAttributes:nil];
            }
        }
        [self refreshCell:pInfo];
    }else {
        [self refreshCell:nil];
    }
}
- (void)refreshCell:(ProductInfo*)pInfo {
    Addons* addons = [Addons sharedManager];
    CCollectionViewCell* cell = self;
    BOOL ismixnmatch = false;
    NSString* ismixnmatchStr = [cell.layer valueForKey:@"ismixnmatch"];
    if (ismixnmatchStr && [ismixnmatchStr isEqualToString:@"true"]) {
        ismixnmatch = true;
        [self refreshCellMixNMatch:pInfo qty:-1];
        return;
    }
    if (addons.show_cart_with_product) {
        UIButton* button = nil;
        
        button = cell.buttonCart;
        button.backgroundColor = [Utility getUIColor:kUIColorBuyButtonNormalBg];
        [button.titleLabel setTextColor:[Utility getUIColor:kUIColorBuyButtonFont]];
        if ([[MyDevice sharedManager] isIpad]) {
            [button.titleLabel setUIFont:kUIFontType14 isBold:true];
        }else{
            [button.titleLabel setUIFont:kUIFontType14 isBold:true];
        }
        [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [button setAttributedTitle:[[NSAttributedString alloc] initWithString:Localize(@"toggle_cart_on")] forState:UIControlStateNormal];
        
        button = cell.buttonAdd;
        button.tintColor = [Utility getUIColor:kUIColorBuyButtonNormalBg];
        [button setTintColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
        [button setTitleColor:[Utility getUIColor:kUIColorBuyButtonFont] forState:UIControlStateNormal];
        if ([[MyDevice sharedManager] isIpad]) {
            [button.titleLabel setUIFont:kUIFontType14 isBold:true];
        }else{
            [button.titleLabel setUIFont:kUIFontType14 isBold:true];
        }
        [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [button setTitle:@"+" forState:UIControlStateNormal];
        
        
        button = cell.buttonSubstract;
        button.tintColor = [Utility getUIColor:kUIColorBuyButtonNormalBg];
        [button setTintColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
        [button setTitleColor:[Utility getUIColor:kUIColorBuyButtonFont] forState:UIControlStateNormal];
        if ([[MyDevice sharedManager] isIpad]) {
            [button.titleLabel setUIFont:kUIFontType14 isBold:true];
        }else{
            [button.titleLabel setUIFont:kUIFontType14 isBold:true];
        }
        [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [button setTitle:@"-" forState:UIControlStateNormal];
        
        
        UITextField* textfield = cell.textFieldAmt;
        [textfield setTextColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
        if ([[MyDevice sharedManager] isIpad]) {
            [textfield setUIFont:kUIFontType14 isBold:true];
        }else{
            [textfield setUIFont:kUIFontType14 isBold:true];
        }
        [textfield setTextAlignment:NSTextAlignmentCenter];
        [textfield setText:@"20"];
        
        
        
        if ([[DataManager sharedManager] layoutIdProductView] == P_LAYOUT_GROCERY) {
            cell.buttonCart.backgroundColor = [UIColor clearColor];
            [cell.buttonCart setAttributedTitle:[[NSAttributedString alloc] initWithString:@"+"] forState:UIControlStateNormal];
            [cell.buttonCart.titleLabel setUIFont:kUIFontType18 isBold:true];
            [cell.buttonAdd.titleLabel setUIFont:kUIFontType18 isBold:true];
            if (cell.buttonCart.imageView.image.renderingMode != UIImageRenderingModeAlwaysTemplate) {
                UIImage* normal = [[UIImage imageNamed:@"button_square"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                [cell.buttonCart setBackgroundImage:normal forState:UIControlStateNormal];
                [cell.buttonCart setTintColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
                [cell.buttonCart.imageView setContentMode:UIViewContentModeScaleAspectFit];
            }
        }
        else if ([[DataManager sharedManager] layoutIdProductView] == P_LAYOUT_DISCOUNT) {
            cell.buttonCart.backgroundColor = [UIColor clearColor];
//            [cell.buttonCart setAttributedTitle:[[NSAttributedString alloc] initWithString:@"+"] forState:UIControlStateNormal];
            [cell.buttonCart.titleLabel setUIFont:kUIFontType18 isBold:true];
            [cell.buttonAdd.titleLabel setUIFont:kUIFontType18 isBold:true];
            if (cell.buttonCart.imageView.image.renderingMode != UIImageRenderingModeAlwaysTemplate) {
                UIImage* normal = [[UIImage imageNamed:@"button_square"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                [cell.buttonCart setBackgroundImage:normal forState:UIControlStateNormal];
                [cell.buttonCart setTintColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
                [cell.buttonCart.imageView setContentMode:UIViewContentModeScaleAspectFit];
            }
        }
    }
    if (addons.show_cart_with_product) {
        if (pInfo) {
            [cell.buttonWishlist setHidden:true];
            [cell.viewAddToCart setHidden:false];
            BOOL showButtonCart;
            BOOL showQuantity;
            if ([Cart hasItemCheckViaProductIdOnly:pInfo]) {
                if (pInfo._isFullRetrieved) {
                    if (pInfo._variations && [pInfo._variations count] > 0) {
                        showButtonCart = true;
                        showQuantity = false;
                    } else {
                        int availState = [Cart getProductAvailibleState:pInfo variationId:-1];
                        if (availState == PRODUCT_QTY_ZERO || availState == PRODUCT_QTY_INVALID) {
                            showButtonCart = true;
                            showQuantity = false;
                            [cell.buttonCart setAttributedTitle:[[NSAttributedString alloc] initWithString:Localize(@"out_of_stock")] forState:UIControlStateNormal];
                        } else {
                            showButtonCart = false;
                            showQuantity = true;
                            Cart* cInfo = [Cart getCartFromProduct:pInfo variationId:-1 variationIndex:-1];
                            if (cInfo) {
                                self.textFieldAmt.text = [NSString stringWithFormat:@"%d", (int)cInfo.count];
                            }
                        }
                    }
                    [cell.actIndicator setHidden:true];
                }
                else {
                    if ([cell.actIndicator isHidden] == false) {
                        showButtonCart = false;
                    }else{
                        showButtonCart = true;
                    }
                    showQuantity = false;
                }
                [cell.buttonCart setHidden:!showButtonCart];
                [cell.buttonAdd setHidden:!showQuantity];
                [cell.buttonSubstract setHidden:!showQuantity];
                [cell.textFieldAmt setHidden:!showQuantity];
            }
            else {
                if ([cell.actIndicator isHidden] == false) {
                    showButtonCart = false;
                }else{
                    if (pInfo._variations && [pInfo._variations count] > 0) {
                    } else {
                        int availState = [Cart getProductAvailibleState:pInfo variationId:-1];
                        if (availState == PRODUCT_QTY_ZERO || availState == PRODUCT_QTY_INVALID) {
                            [cell.buttonCart setAttributedTitle:[[NSAttributedString alloc] initWithString:Localize(@"out_of_stock")] forState:UIControlStateNormal];
                        }
                    }
                    showButtonCart = true;
                }
                showQuantity = false;
                [cell.buttonCart setHidden:!showButtonCart];
                [cell.buttonAdd setHidden:!showQuantity];
                [cell.buttonSubstract setHidden:!showQuantity];
                [cell.textFieldAmt setHidden:!showQuantity];
                if (pInfo._isFullRetrieved) {
                    [cell.actIndicator setHidden:true];
                }
            }
        }
        else {
            [cell.buttonWishlist setHidden:true];
            [cell.viewAddToCart setHidden:true];
        }
    }
    else {
        [cell.buttonWishlist setHidden:false];
        [cell.viewAddToCart setHidden:true];
    }
}
- (void)refreshCellMixNMatch:(ProductInfo*)pInfo qty:(int)qty {
    Addons* addons = [Addons sharedManager];
    CCollectionViewCell* cell = self;
    if (1) {
        UIButton* button = nil;
        
        button = cell.buttonCart;
        button.backgroundColor = [Utility getUIColor:kUIColorBuyButtonNormalBg];
        [button.titleLabel setTextColor:[Utility getUIColor:kUIColorBuyButtonFont]];
        if ([[MyDevice sharedManager] isIpad]) {
            [button.titleLabel setUIFont:kUIFontType14 isBold:true];
        }else{
            [button.titleLabel setUIFont:kUIFontType14 isBold:true];
        }
        [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [button setAttributedTitle:[[NSAttributedString alloc] initWithString:Localize(@"toggle_cart_on")] forState:UIControlStateNormal];
        
        button = cell.buttonAdd;
        button.tintColor = [Utility getUIColor:kUIColorBuyButtonNormalBg];
        [button setTintColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
        [button setTitleColor:[Utility getUIColor:kUIColorBuyButtonFont] forState:UIControlStateNormal];
        if ([[MyDevice sharedManager] isIpad]) {
            [button.titleLabel setUIFont:kUIFontType14 isBold:true];
        }else{
            [button.titleLabel setUIFont:kUIFontType14 isBold:true];
        }
        [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [button setTitle:@"+" forState:UIControlStateNormal];
        
        
        button = cell.buttonSubstract;
        button.tintColor = [Utility getUIColor:kUIColorBuyButtonNormalBg];
        [button setTintColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
        [button setTitleColor:[Utility getUIColor:kUIColorBuyButtonFont] forState:UIControlStateNormal];
        if ([[MyDevice sharedManager] isIpad]) {
            [button.titleLabel setUIFont:kUIFontType14 isBold:true];
        }else{
            [button.titleLabel setUIFont:kUIFontType14 isBold:true];
        }
        [button.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [button setTitle:@"-" forState:UIControlStateNormal];
        
        
        UITextField* textfield = cell.textFieldAmt;
        [textfield setTextColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
        if ([[MyDevice sharedManager] isIpad]) {
            [textfield setUIFont:kUIFontType14 isBold:true];
        }else{
            [textfield setUIFont:kUIFontType14 isBold:true];
        }
        [textfield setTextAlignment:NSTextAlignmentCenter];
//        [textfield setText:@"20"];
        
        
        
        if ([[DataManager sharedManager] layoutIdProductView] == P_LAYOUT_GROCERY) {
            cell.buttonCart.backgroundColor = [UIColor clearColor];
            [cell.buttonCart setAttributedTitle:[[NSAttributedString alloc] initWithString:@"+"] forState:UIControlStateNormal];
            [cell.buttonCart.titleLabel setUIFont:kUIFontType18 isBold:true];
            [cell.buttonAdd.titleLabel setUIFont:kUIFontType18 isBold:true];
            if (cell.buttonCart.imageView.image.renderingMode != UIImageRenderingModeAlwaysTemplate) {
                UIImage* normal = [[UIImage imageNamed:@"button_square"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                [cell.buttonCart setBackgroundImage:normal forState:UIControlStateNormal];
                [cell.buttonCart setTintColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
                [cell.buttonCart.imageView setContentMode:UIViewContentModeScaleAspectFit];
            }
        }
        else if ([[DataManager sharedManager] layoutIdProductView] == P_LAYOUT_DISCOUNT) {
            cell.buttonCart.backgroundColor = [UIColor clearColor];
//            [cell.buttonCart setAttributedTitle:[[NSAttributedString alloc] initWithString:@"+"] forState:UIControlStateNormal];
            [cell.buttonCart.titleLabel setUIFont:kUIFontType18 isBold:true];
            [cell.buttonAdd.titleLabel setUIFont:kUIFontType18 isBold:true];
            if (cell.buttonCart.imageView.image.renderingMode != UIImageRenderingModeAlwaysTemplate) {
                UIImage* normal = [[UIImage imageNamed:@"button_square"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                [cell.buttonCart setBackgroundImage:normal forState:UIControlStateNormal];
                [cell.buttonCart setTintColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
                [cell.buttonCart.imageView setContentMode:UIViewContentModeScaleAspectFit];
            }
        }
    }
    
    if (pInfo) {
        [cell.buttonWishlist setHidden:true];
        [cell.viewAddToCart setHidden:false];
        BOOL showButtonCart;
        BOOL showQuantity;
        showButtonCart = false;
        showQuantity = true;
//        Cart* cInfo = [Cart getCartFromProduct:pInfo variationId:-1 variationIndex:-1];
//        if (cInfo) {
        if (qty != -1) {
            self.textFieldAmt.text = [NSString stringWithFormat:@"%d", qty];
        }
        
//        } else {
//            self.textFieldAmt.text = [NSString stringWithFormat:@"0"];
//        }
//        self.textFieldAmt.text = @"rj";
        [cell.actIndicator setHidden:true];
        [cell.buttonCart setHidden:!showButtonCart];
        [cell.buttonAdd setHidden:!showQuantity];
        [cell.buttonSubstract setHidden:!showQuantity];
        [cell.textFieldAmt setHidden:!showQuantity];
    }
}
@end
