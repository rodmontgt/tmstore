//
//  ViewControllerMyCouponProduct.m
//  TMStore
//
//  Created by Twist Mobile on 21/01/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import "ViewControllerMyCouponProduct.h"
#import "Utility.h"
#import "DataManager.h"
#import "Variables.h"
#import "CCollectionViewCell.h"
#import "LayoutProperties.h"
#import "ProductInfo.h"
#import "AppUser.h"
#import "RCustomViewSegue.h"
#import "ViewControllerCart.h"

static int kTagForGlobalSpacing = 0;
static int kTagForNoSpacing = 1;

@interface ViewControllerMyCouponProduct ()

@end

@implementation ViewControllerMyCouponProduct

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [Utility getUIColor:kUIColorThemeFont], NSForegroundColorAttributeName, [Utility getUIFont:kUIFontType24 isBold:false], NSFontAttributeName, nil]];
    [self.currentItemHeading setTitle:@"   "];
    
    _labelViewHeading = [[UILabel alloc] init] ;
    [_labelViewHeading setFrame:CGRectMake(0, 20, [[MyDevice sharedManager] screenSize].width, _navigationBar.frame.size.height)];
    [_labelViewHeading setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [_labelViewHeading setUIFont:kUIFontType24 isBold:false];
    [_labelViewHeading setTextColor:[Utility getUIColor:kUIColorThemeFont]];
    [_labelViewHeading setTextAlignment:NSTextAlignmentCenter];
    [_labelViewHeading setText:[NSString stringWithFormat:@"%@",Localize(@"")]];
    [self.view addSubview:_labelViewHeading];
    
    [_navigationBar setClipsToBounds:false];
    [_lineView setBackgroundColor:[Utility getUIColor:kUIColorBorder]];
    [self.view setBackgroundColor:[Utility getUIColor:kUIColorBgHeader]];
    [_navigationBar setBarTintColor:[Utility getUIColor:kUIColorBgHeader]];
    customBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [customBackButton setImage:[[UIImage imageNamed:@"img_arrow_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [customBackButton addTarget:self action:@selector(barButtonBackPressed:)forControlEvents:UIControlEventTouchUpInside];
    [customBackButton setTitle:[NSString stringWithFormat:@"  %@  ", Localize(@"i_back")] forState:UIControlStateNormal];
    [customBackButton setTintColor:[Utility getUIColor:kUIColorThemeFont]];
    [customBackButton setTitleColor:[Utility getUIColor:kUIColorThemeFont] forState:UIControlStateNormal];
    [customBackButton.titleLabel setUIFont:kUIFontType18 isBold:false];
    [customBackButton sizeToFit];
    [_previousItemHeading setCustomView:customBackButton];
    [_previousItemHeading setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[Utility getUIColor:kUIColorThemeFont], NSForegroundColorAttributeName, [Utility getUIFont:kUIFontType18 isBold:false], NSFontAttributeName, nil] forState:UIControlStateNormal];
    
    customApplyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [customApplyButton addTarget:self action:@selector(barButtonApplyPressed:)forControlEvents:UIControlEventTouchUpInside];
    [customApplyButton setTitle:[NSString stringWithFormat:@"  %@  ", Localize(@"apply")] forState:UIControlStateNormal];
    [customApplyButton setTintColor:[Utility getUIColor:kUIColorThemeFont]];
    [customApplyButton setTitleColor:[Utility getUIColor:kUIColorThemeFont] forState:UIControlStateNormal];
    [customApplyButton.titleLabel setUIFont:kUIFontType18 isBold:false];
    [customApplyButton sizeToFit];
    [_ApplyItemHeading setCustomView:customApplyButton];
    [_ApplyItemHeading setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[Utility getUIColor:kUIColorThemeFont], NSForegroundColorAttributeName, [Utility getUIFont:kUIFontType18 isBold:false], NSFontAttributeName, nil] forState:UIControlStateNormal];
    
    UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 20)];
    [statusBarView setBackgroundColor:[Utility getUIColor:kUIColorBgHeader]];
    [self.view addSubview:statusBarView];
    
    _strCollectionView1 = [[Utility sharedManager] getProductViewString];
    _strCollectionView2 = [[Utility sharedManager] getCategoryViewString];
    _strCollectionView3 = [[Utility sharedManager] getHorizontalViewString];
    [self resetMainScrollView];
}
- (void)viewWillAppear:(BOOL)animated {
    
}

-(void)CouponData:(Coupon*)couponData{
    self.coupon = couponData;
    [_labelViewHeading setText:[NSString stringWithFormat:@"%@",couponData._code]];
    [self initVariables];
    [self loadDataInView];
}

#pragma mark - Collecationview Delegate Methord

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (collectionView == _viewUserDefined[0]) {
        return _coupon._product_ids.count;
    } else if (collectionView == _viewUserDefined[1]) {
        return _coupon._product_category_ids.count;
    } else if (collectionView == _viewUserDefined[2]) {
        return _coupon._exclude_product_ids.count;
    } else if (collectionView == _viewUserDefined[3]) {
        return _coupon._exclude_product_category_ids.count;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"CollectionCell";
    CCollectionViewCell *cell=(CCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    [cell setNeedsLayout];
    int i = 0;
    for (; i < _kTotalViewsCouponScreen; i++) {
        if(_viewUserDefined[i] == collectionView){
            break;
        }
    }
    switch (i) {
        case _kExclude_Categoryid_Cell:
        {
            if(cell == nil) {
                NSArray *nib = [[ NSBundle mainBundle] loadNibNamed:_strCollectionView3 owner:self options:nil];
                cell = [nib objectAtIndex:0];
            }
            [Utility showShadow:cell];
            
            [cell setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
            [[cell productName] setUIFont:kUIFontType16 isBold:false];
            [[cell productName] setTextColor:[Utility getUIColor:kUIColorFontDark]];
            [[cell productPriceOriginal] setUIFont:kUIFontType14 isBold:false];
            [[cell productPriceFinal] setUIFont:kUIFontType14 isBold:false];
            
            ProductInfo *pInfo = [ProductInfo getProductWithId:[[_coupon._exclude_product_category_ids objectAtIndex:indexPath.row] intValue]];
            [[cell productName] setText:pInfo._titleForOuterView];
            [[cell productPriceOriginal] setAttributedText:pInfo._priceOldString];
            [[cell productPriceFinal] setText:pInfo._priceNewString];
            if ([pInfo._images count] == 0) {
                [pInfo._images addObject:[[ProductImage alloc] init]];
            }
            
            if (([[GuestConfig sharedInstance] hide_price] && ![AppUser isSignedIn]) || [[Addons sharedManager] hide_price]) {
                [[cell productPriceOriginal] setText:@""];
                [[cell productPriceFinal] setText:@""];
                [cell.productPriceOriginal sizeToFitUI];
                [cell.productPriceFinal sizeToFitUI];
            } else {
                [cell.productPriceOriginal sizeToFitUI];
                [cell.productPriceFinal sizeToFitUI];
            }
            ProductImage *pImage = [pInfo._images objectAtIndex:0];
            [Utility setImage:cell.productImg url:pImage._src resizeType:kRESIZE_TYPE_PRODUCT_THUMBNAIL isLocal:false];
            if ([cell buttonWishlist].imageView.image.renderingMode != UIImageRenderingModeAlwaysTemplate) {
                UIImage* normal = [[UIImage imageNamed:@"wishlist_icon_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                UIImage* selected = [[UIImage imageNamed:@"wishlist_icon_pressed"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                [[cell buttonWishlist] setUIImage:normal forState:UIControlStateNormal];
                [[cell buttonWishlist] setUIImage:selected forState:UIControlStateSelected];
            }
            [[cell buttonWishlist] addTarget:[Utility sharedManager] action:@selector(wishlistButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [[cell buttonWishlist] setTag:pInfo._id];
            if ([cell.productImg.layer valueForKey:@"UITapGestureRecognizer"]) {
                [cell.productImg removeGestureRecognizer:((UITapGestureRecognizer*)[cell.productImg.layer valueForKey:@"UITapGestureRecognizer"])];
            }
            [cell.productImg setTag:pInfo._id];
            UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bannerTapped:)];
            singleTap.numberOfTapsRequired = 1;
            singleTap.numberOfTouchesRequired = 1;
            [cell.productImg addGestureRecognizer:singleTap];
            [singleTap.view.layer setValue:cell forKey:@"CELL_OBJ"];
            [cell.productImg setUserInteractionEnabled:YES];
            [cell.productImg.layer setValue:singleTap forKey:@"UITapGestureRecognizer"];
            [cell.productImg.layer setValue:pInfo._titleForOuterView forKey:@"PNAME"];
            if ([cell buttonAdd].imageView.image.renderingMode != UIImageRenderingModeAlwaysTemplate) {
                UIImage* normal = [[UIImage imageNamed:@"button_circle"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                [cell.buttonAdd setBackgroundImage:normal forState:UIControlStateNormal];
            }
            if ([cell buttonSubstract].imageView.image.renderingMode != UIImageRenderingModeAlwaysTemplate) {
                UIImage* normal = [[UIImage imageNamed:@"button_circle"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                [cell.buttonSubstract setBackgroundImage:normal forState:UIControlStateNormal];
            }
            if (pInfo) {
                [cell.layer setValue:self forKey:@"VC"];
                [cell.layer setValue:pInfo forKey:@"PRODUCT_INFO"];
                [cell.layer setValue:pInfo forKey:@"PINFO_OBJ"];
                [cell.buttonAdd.layer setValue:pInfo forKey:@"PINFO_OBJ"];
                [cell.buttonAdd.layer setValue:cell forKey:@"CELL_OBJ"];
                [cell.buttonCart.layer setValue:pInfo forKey:@"PINFO_OBJ"];
                [cell.buttonCart setTitle:Localize(@"add_to_cart") forState:UIControlStateNormal];
                [cell.buttonCart.layer setValue:cell forKey:@"CELL_OBJ"];
                [cell.buttonSubstract.layer setValue:pInfo forKey:@"PINFO_OBJ"];
                [cell.buttonSubstract.layer setValue:cell forKey:@"CELL_OBJ"];
                [cell.textFieldAmt.layer setValue:pInfo forKey:@"PINFO_OBJ"];
                [cell.textFieldAmt.layer setValue:cell forKey:@"CELL_OBJ"];
                [cell.buttonCart addTarget:self action:@selector(cartButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//                [cell.buttonAdd addTarget:self action:@selector(addButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//                [cell.buttonSubstract addTarget:self action:@selector(substractButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            }else {
                [cell.layer setValue:nil forKey:@"PRODUCT_INFO"];
                [cell.layer setValue:nil forKey:@"PINFO_OBJ"];
            }
            
        }break;
        case _kExclude_Productid_Cell:
        {
            if(cell == nil) {
                NSArray *nib = [[ NSBundle mainBundle] loadNibNamed:_strCollectionView3 owner:self options:nil];
                cell = [nib objectAtIndex:0];
            }
            [Utility showShadow:cell];
            
            [cell setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
            [[cell productName] setUIFont:kUIFontType16 isBold:false];
            [[cell productName] setTextColor:[Utility getUIColor:kUIColorFontDark]];
            [[cell productPriceOriginal] setUIFont:kUIFontType14 isBold:false];
            [[cell productPriceFinal] setUIFont:kUIFontType14 isBold:false];
            
            ProductInfo *pInfo = [ProductInfo getProductWithId:[[_coupon._exclude_product_ids objectAtIndex:indexPath.row] intValue]];
            [[cell productName] setText:pInfo._titleForOuterView];
            [[cell productPriceOriginal] setAttributedText:pInfo._priceOldString];
            [[cell productPriceFinal] setText:pInfo._priceNewString];
            if ([pInfo._images count] == 0) {
                [pInfo._images addObject:[[ProductImage alloc] init]];
            }
            
            if (([[GuestConfig sharedInstance] hide_price] && ![AppUser isSignedIn]) || [[Addons sharedManager] hide_price]) {
                [[cell productPriceOriginal] setText:@""];
                [[cell productPriceFinal] setText:@""];
                [cell.productPriceOriginal sizeToFitUI];
                [cell.productPriceFinal sizeToFitUI];
            } else {
                [cell.productPriceOriginal sizeToFitUI];
                [cell.productPriceFinal sizeToFitUI];
            }
            ProductImage *pImage = [pInfo._images objectAtIndex:0];
            [Utility setImage:cell.productImg url:pImage._src resizeType:kRESIZE_TYPE_PRODUCT_THUMBNAIL isLocal:false];
            if ([cell buttonWishlist].imageView.image.renderingMode != UIImageRenderingModeAlwaysTemplate) {
                UIImage* normal = [[UIImage imageNamed:@"wishlist_icon_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                UIImage* selected = [[UIImage imageNamed:@"wishlist_icon_pressed"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                [[cell buttonWishlist] setUIImage:normal forState:UIControlStateNormal];
                [[cell buttonWishlist] setUIImage:selected forState:UIControlStateSelected];
            }
            [[cell buttonWishlist] addTarget:[Utility sharedManager] action:@selector(wishlistButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [[cell buttonWishlist] setTag:pInfo._id];
            if ([cell.productImg.layer valueForKey:@"UITapGestureRecognizer"]) {
                [cell.productImg removeGestureRecognizer:((UITapGestureRecognizer*)[cell.productImg.layer valueForKey:@"UITapGestureRecognizer"])];
            }
            [cell.productImg setTag:pInfo._id];
            UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bannerTapped:)];
            singleTap.numberOfTapsRequired = 1;
            singleTap.numberOfTouchesRequired = 1;
            [cell.productImg addGestureRecognizer:singleTap];
            [singleTap.view.layer setValue:cell forKey:@"CELL_OBJ"];
            [cell.productImg setUserInteractionEnabled:YES];
            [cell.productImg.layer setValue:singleTap forKey:@"UITapGestureRecognizer"];
            [cell.productImg.layer setValue:pInfo._titleForOuterView forKey:@"PNAME"];
            if ([cell buttonAdd].imageView.image.renderingMode != UIImageRenderingModeAlwaysTemplate) {
                UIImage* normal = [[UIImage imageNamed:@"button_circle"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                [cell.buttonAdd setBackgroundImage:normal forState:UIControlStateNormal];
            }
            if ([cell buttonSubstract].imageView.image.renderingMode != UIImageRenderingModeAlwaysTemplate) {
                UIImage* normal = [[UIImage imageNamed:@"button_circle"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                [cell.buttonSubstract setBackgroundImage:normal forState:UIControlStateNormal];
            }
            if (pInfo) {
                [cell.layer setValue:self forKey:@"VC"];
                [cell.layer setValue:pInfo forKey:@"PRODUCT_INFO"];
                [cell.layer setValue:pInfo forKey:@"PINFO_OBJ"];
                [cell.buttonAdd.layer setValue:pInfo forKey:@"PINFO_OBJ"];
                [cell.buttonAdd.layer setValue:cell forKey:@"CELL_OBJ"];
                [cell.buttonCart.layer setValue:pInfo forKey:@"PINFO_OBJ"];
                [cell.buttonCart setTitle:Localize(@"add_to_cart") forState:UIControlStateNormal];
                [cell.buttonCart.layer setValue:cell forKey:@"CELL_OBJ"];
                [cell.buttonSubstract.layer setValue:pInfo forKey:@"PINFO_OBJ"];
                [cell.buttonSubstract.layer setValue:cell forKey:@"CELL_OBJ"];
                [cell.textFieldAmt.layer setValue:pInfo forKey:@"PINFO_OBJ"];
                [cell.textFieldAmt.layer setValue:cell forKey:@"CELL_OBJ"];
                [cell.buttonCart addTarget:self action:@selector(cartButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//                [cell.buttonAdd addTarget:self action:@selector(addButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//                [cell.buttonSubstract addTarget:self action:@selector(substractButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            }else {
                [cell.layer setValue:nil forKey:@"PRODUCT_INFO"];
                [cell.layer setValue:nil forKey:@"PINFO_OBJ"];
            }
        }break;
        case _kCategoryid_Cell:
        {
            if(cell == nil) {
                NSArray *nib = [[ NSBundle mainBundle] loadNibNamed:_strCollectionView3 owner:self options:nil];
                cell = [nib objectAtIndex:0];
            }
            [Utility showShadow:cell];
            
            [cell setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
            [[cell productName] setUIFont:kUIFontType16 isBold:false];
            [[cell productName] setTextColor:[Utility getUIColor:kUIColorFontDark]];
            [[cell productPriceOriginal] setUIFont:kUIFontType14 isBold:false];
            [[cell productPriceFinal] setUIFont:kUIFontType14 isBold:false];
            
            ProductInfo *pInfo = [ProductInfo getProductWithId:[[_coupon._product_category_ids objectAtIndex:indexPath.row] intValue]];
            [[cell productName] setText:pInfo._titleForOuterView];
            [[cell productPriceOriginal] setAttributedText:pInfo._priceOldString];
            [[cell productPriceFinal] setText:pInfo._priceNewString];
            if ([pInfo._images count] == 0) {
                [pInfo._images addObject:[[ProductImage alloc] init]];
            }
            
            if (([[GuestConfig sharedInstance] hide_price] && ![AppUser isSignedIn]) || [[Addons sharedManager] hide_price]) {
                [[cell productPriceOriginal] setText:@""];
                [[cell productPriceFinal] setText:@""];
                [cell.productPriceOriginal sizeToFitUI];
                [cell.productPriceFinal sizeToFitUI];
            } else {
                [cell.productPriceOriginal sizeToFitUI];
                [cell.productPriceFinal sizeToFitUI];
            }
            ProductImage *pImage = [pInfo._images objectAtIndex:0];
            [Utility setImage:cell.productImg url:pImage._src resizeType:kRESIZE_TYPE_PRODUCT_THUMBNAIL isLocal:false];
            if ([cell buttonWishlist].imageView.image.renderingMode != UIImageRenderingModeAlwaysTemplate) {
                UIImage* normal = [[UIImage imageNamed:@"wishlist_icon_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                UIImage* selected = [[UIImage imageNamed:@"wishlist_icon_pressed"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                [[cell buttonWishlist] setUIImage:normal forState:UIControlStateNormal];
                [[cell buttonWishlist] setUIImage:selected forState:UIControlStateSelected];
            }
            [[cell buttonWishlist] addTarget:[Utility sharedManager] action:@selector(wishlistButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [[cell buttonWishlist] setTag:pInfo._id];
            if ([cell.productImg.layer valueForKey:@"UITapGestureRecognizer"]) {
                [cell.productImg removeGestureRecognizer:((UITapGestureRecognizer*)[cell.productImg.layer valueForKey:@"UITapGestureRecognizer"])];
            }
            [cell.productImg setTag:pInfo._id];
            UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bannerTapped:)];
            singleTap.numberOfTapsRequired = 1;
            singleTap.numberOfTouchesRequired = 1;
            [cell.productImg addGestureRecognizer:singleTap];
            [singleTap.view.layer setValue:cell forKey:@"CELL_OBJ"];
            [cell.productImg setUserInteractionEnabled:YES];
            [cell.productImg.layer setValue:singleTap forKey:@"UITapGestureRecognizer"];
            [cell.productImg.layer setValue:pInfo._titleForOuterView forKey:@"PNAME"];
            if ([cell buttonAdd].imageView.image.renderingMode != UIImageRenderingModeAlwaysTemplate) {
                UIImage* normal = [[UIImage imageNamed:@"button_circle"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                [cell.buttonAdd setBackgroundImage:normal forState:UIControlStateNormal];
            }
            if ([cell buttonSubstract].imageView.image.renderingMode != UIImageRenderingModeAlwaysTemplate) {
                UIImage* normal = [[UIImage imageNamed:@"button_circle"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                [cell.buttonSubstract setBackgroundImage:normal forState:UIControlStateNormal];
            }
            if (pInfo) {
                [cell.layer setValue:self forKey:@"VC"];
                [cell.layer setValue:pInfo forKey:@"PRODUCT_INFO"];
                [cell.layer setValue:pInfo forKey:@"PINFO_OBJ"];
                [cell.buttonAdd.layer setValue:pInfo forKey:@"PINFO_OBJ"];
                [cell.buttonAdd.layer setValue:cell forKey:@"CELL_OBJ"];
                [cell.buttonCart.layer setValue:pInfo forKey:@"PINFO_OBJ"];
                [cell.buttonCart setTitle:Localize(@"add_to_cart") forState:UIControlStateNormal];
                [cell.buttonCart.layer setValue:cell forKey:@"CELL_OBJ"];
                [cell.buttonSubstract.layer setValue:pInfo forKey:@"PINFO_OBJ"];
                [cell.buttonSubstract.layer setValue:cell forKey:@"CELL_OBJ"];
                [cell.textFieldAmt.layer setValue:pInfo forKey:@"PINFO_OBJ"];
                [cell.textFieldAmt.layer setValue:cell forKey:@"CELL_OBJ"];
                [cell.buttonCart addTarget:self action:@selector(cartButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//                [cell.buttonAdd addTarget:self action:@selector(addButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//                [cell.buttonSubstract addTarget:self action:@selector(substractButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            }else {
                [cell.layer setValue:nil forKey:@"PRODUCT_INFO"];
                [cell.layer setValue:nil forKey:@"PINFO_OBJ"];
            }
        }break;
        case _kProductid_Cell:
        {
            if(cell == nil) {
                NSArray *nib = [[ NSBundle mainBundle] loadNibNamed:_strCollectionView3 owner:self options:nil];
                cell = [nib objectAtIndex:0];
            }
            [Utility showShadow:cell];
            
            [cell setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
            [[cell productName] setUIFont:kUIFontType16 isBold:false];
            [[cell productName] setTextColor:[Utility getUIColor:kUIColorFontDark]];
            [[cell productPriceOriginal] setUIFont:kUIFontType14 isBold:false];
            [[cell productPriceFinal] setUIFont:kUIFontType14 isBold:false];
            
            ProductInfo *pInfo = [ProductInfo getProductWithId:[[_coupon._product_ids objectAtIndex:indexPath.row] intValue]];
            [[cell productName] setText:pInfo._titleForOuterView];
            [[cell productPriceOriginal] setAttributedText:pInfo._priceOldString];
            [[cell productPriceFinal] setText:pInfo._priceNewString];
            if ([pInfo._images count] == 0) {
                [pInfo._images addObject:[[ProductImage alloc] init]];
            }
            
            if (([[GuestConfig sharedInstance] hide_price] && ![AppUser isSignedIn]) || [[Addons sharedManager] hide_price]) {
                [[cell productPriceOriginal] setText:@""];
                [[cell productPriceFinal] setText:@""];
                [cell.productPriceOriginal sizeToFitUI];
                [cell.productPriceFinal sizeToFitUI];
            } else {
                [cell.productPriceOriginal sizeToFitUI];
                [cell.productPriceFinal sizeToFitUI];
            }
            ProductImage *pImage = [pInfo._images objectAtIndex:0];
            [Utility setImage:cell.productImg url:pImage._src resizeType:kRESIZE_TYPE_PRODUCT_THUMBNAIL isLocal:false];
            if ([cell buttonWishlist].imageView.image.renderingMode != UIImageRenderingModeAlwaysTemplate) {
                UIImage* normal = [[UIImage imageNamed:@"wishlist_icon_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                UIImage* selected = [[UIImage imageNamed:@"wishlist_icon_pressed"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                [[cell buttonWishlist] setUIImage:normal forState:UIControlStateNormal];
                [[cell buttonWishlist] setUIImage:selected forState:UIControlStateSelected];
            }
            [[cell buttonWishlist] addTarget:[Utility sharedManager] action:@selector(wishlistButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [[cell buttonWishlist] setTag:pInfo._id];
            if ([cell.productImg.layer valueForKey:@"UITapGestureRecognizer"]) {
                [cell.productImg removeGestureRecognizer:((UITapGestureRecognizer*)[cell.productImg.layer valueForKey:@"UITapGestureRecognizer"])];
            }
            [cell.productImg setTag:pInfo._id];
            UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bannerTapped:)];
            singleTap.numberOfTapsRequired = 1;
            singleTap.numberOfTouchesRequired = 1;
            [cell.productImg addGestureRecognizer:singleTap];
            [singleTap.view.layer setValue:cell forKey:@"CELL_OBJ"];
            [cell.productImg setUserInteractionEnabled:YES];
            [cell.productImg.layer setValue:singleTap forKey:@"UITapGestureRecognizer"];
            [cell.productImg.layer setValue:pInfo._titleForOuterView forKey:@"PNAME"];
            if ([cell buttonAdd].imageView.image.renderingMode != UIImageRenderingModeAlwaysTemplate) {
                UIImage* normal = [[UIImage imageNamed:@"button_circle"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                [cell.buttonAdd setBackgroundImage:normal forState:UIControlStateNormal];
            }
            if ([cell buttonSubstract].imageView.image.renderingMode != UIImageRenderingModeAlwaysTemplate) {
                UIImage* normal = [[UIImage imageNamed:@"button_circle"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                [cell.buttonSubstract setBackgroundImage:normal forState:UIControlStateNormal];
            }
            if (pInfo) {
                [cell.layer setValue:self forKey:@"VC"];
                [cell.layer setValue:pInfo forKey:@"PRODUCT_INFO"];
                [cell.layer setValue:pInfo forKey:@"PINFO_OBJ"];
                [cell.buttonAdd.layer setValue:pInfo forKey:@"PINFO_OBJ"];
                [cell.buttonAdd.layer setValue:cell forKey:@"CELL_OBJ"];
                [cell.buttonCart.layer setValue:pInfo forKey:@"PINFO_OBJ"];
                [cell.buttonCart setTitle:Localize(@"add_to_cart") forState:UIControlStateNormal];
                [cell.buttonCart.layer setValue:cell forKey:@"CELL_OBJ"];
                [cell.buttonSubstract.layer setValue:pInfo forKey:@"PINFO_OBJ"];
                [cell.buttonSubstract.layer setValue:cell forKey:@"CELL_OBJ"];
                [cell.textFieldAmt.layer setValue:pInfo forKey:@"PINFO_OBJ"];
                [cell.textFieldAmt.layer setValue:cell forKey:@"CELL_OBJ"];
                [cell.buttonCart addTarget:self action:@selector(cartButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//                [cell.buttonAdd addTarget:self action:@selector(addButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//                [cell.buttonSubstract addTarget:self action:@selector(substractButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            }else {
                [cell.layer setValue:nil forKey:@"PRODUCT_INFO"];
                [cell.layer setValue:nil forKey:@"PINFO_OBJ"];
            }
            
        }break;
        default:
            break;
    }
    [cell setNeedsLayout];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    int i = 0;
    for (; i < _kTotalViewsCouponScreen; i++) {
        if(_viewUserDefined[i] == collectionView){
            break;
        }
    }
    NSMutableArray *array = nil;
    switch (i) {
        case _kExclude_Categoryid_Cell:
        case _kExclude_Productid_Cell:
        case _kProductid_Cell:
        case _kCategoryid_Cell:
        {
            array = [LayoutProperties CardPropertiesForHorizontalView];
            float cardHorizontalSpacing = [[array objectAtIndex:0] floatValue];
            float cardVerticalSpacing = [[array objectAtIndex:1] floatValue];
            float cardWidth = [[array objectAtIndex:2] floatValue];
            float cardHeight = [[array objectAtIndex:3] floatValue];
            float insetLeft = [[array objectAtIndex:4] floatValue];
            float insetRight = [[array objectAtIndex:5] floatValue];
            float insetTop = [[array objectAtIndex:6] floatValue];
            float insetBottom = [[array objectAtIndex:7] floatValue];
            
            UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)[collectionView collectionViewLayout];
            layout.minimumInteritemSpacing = cardHorizontalSpacing;
            layout.minimumLineSpacing = cardVerticalSpacing;
            
            _propCollectionView[i]._insetTop =  insetTop;
            _propCollectionView[i]._insetLeft =  insetLeft;
            _propCollectionView[i]._insetBottom =  insetBottom;
            _propCollectionView[i]._insetRight =  insetRight;
            
            _propCollectionView[i]._height = cardHeight + _propCollectionView[i]._insetTop + _propCollectionView[i]._insetBottom;
            [_viewUserDefined[i] setFrame:[_propCollectionView[i] getFrameRect]];
            [self resetMainScrollView];
            return CGSizeMake(cardWidth, cardHeight);
        }
            break;
        default:
            break;
    }
    return CGSizeMake(0, 0);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didselect");
}
#pragma mark - All Button Actions

- (IBAction)barButtonBackPressed:(id)sender {
    [[Utility sharedManager] stopGrayLoadingBar];
    [[Utility sharedManager] popScreen:self];
    if ([self.view tag] == PUSH_SCREEN_TYPE_MYCOPON_PRODUCT) {
        return;
    }
    ViewControllerMain* mainVC = [ViewControllerMain getInstance];
    [mainVC resetPreviousState];

}
- (IBAction)barButtonApplyPressed:(id)sender {
    if (_coupon) {
        NSString* couponCodeStr = _coupon._code;
        AppDelegate* appD = (AppDelegate*)[UIApplication sharedApplication].delegate;
        appD.isPrevScreenCouponCode = true;
        ViewControllerMain* vcMain = [ViewControllerMain getInstance];
        ViewControllerCart* cartVC = (ViewControllerCart*)[vcMain getCartViewController:vcMain];
        [cartVC passCouponCode:couponCodeStr];
    }
}
- (void)cartButtonClicked:(UIButton*)button {
    ProductInfo* pInfo = (ProductInfo*)[button.layer valueForKey:@"PINFO_OBJ"];
    CCollectionViewCell* cell = (CCollectionViewCell*)[button.layer valueForKey:@"CELL_OBJ"];
    if (cell.actIndicator.hidden == false) {
        return;
    }
    if (pInfo._isFullRetrieved == false) {
        RLOG(@"NOTIFY_PRODUCT_LOADED1 = CELL = %@", cell);
        [[NSNotificationCenter defaultCenter] addObserver:cell selector:@selector(updateCell:) name:@"NOTIFY_PRODUCT_LOADED" object:nil];
        
        [[DataManager sharedManager] fetchSingleProductData:nil productId:pInfo._id];
        [cell.actIndicator setHidden:false];
        [cell.buttonCart setHidden:true];
    } else {
        //        if (pInfo._variations && [pInfo._variations count] > 0) {
        //            //open new popup to choose variation and add to cart
        //            [self clickOnProduct:pInfo currentItemData:_currentItem cell:cell];
        //        }else {
        //            if ([self checkPurchasable] == false) {
        //                return;
        //            }
        //            [Cart addProduct:pInfo variationId:-1 variationIndex:-1 selectedVariationAttributes:nil bundleItems:self.bundleItems matchedItems:self.matchedItems];
        //        }
    }
    [cell refreshCell:pInfo];
}

- (void)clickOnProduct:(ProductInfo*)productClicked currentItemData:(DataPass*)currentItemData cell:(id)cell{
    ViewControllerMain* mainVC = [ViewControllerMain getInstance];
    mainVC.containerTop.hidden = YES;
    mainVC.containerCenter.hidden = YES;
    mainVC.containerCenterWithTop.hidden = NO;
    mainVC.vcBottomBar.buttonHome.selected = YES;
    mainVC.vcBottomBar.buttonCart.selected = NO;
    mainVC.vcBottomBar.buttonWishlist.selected = NO;
    mainVC.vcBottomBar.buttonSearch.selected = NO;
    mainVC.revealController.panGestureEnable = false;
    [mainVC.vcBottomBar buttonClicked:nil];
    DataPass* clickedItemData = [[DataPass alloc] init];
    clickedItemData.itemId = productClicked._id;
    clickedItemData.isCategory = false;
    clickedItemData.isProduct = true;
    clickedItemData.hasChildCategory = false;
    clickedItemData.childCount = false;
    clickedItemData.pInfo = productClicked;
    DataPass* previousItemData = [[DataPass alloc] init];
    previousItemData.itemId = currentItemData.cInfo._id;
    previousItemData.isCategory = currentItemData.isCategory;
    previousItemData.isProduct = currentItemData.isProduct;
    previousItemData.hasChildCategory = currentItemData.hasChildCategory;
    previousItemData.childCount = currentItemData.childCount;
    previousItemData.cInfo = currentItemData.cInfo;
    ViewControllerProduct* vcProduct = [[Utility sharedManager] pushProductScreen:mainVC.vcCenterTop];
    [vcProduct loadData:clickedItemData previousItem:previousItemData drillingLevel:0];
    vcProduct.parentVC = self;
    vcProduct.parentCell = cell;
}

- (UICollectionView*)getViewUserDefined:(int)viewId {
    return _viewUserDefined[viewId];
}
- (void)bannerTapped:(UITapGestureRecognizer*)singleTap{
    Banner* banner = [singleTap.view.layer valueForKey:@"BANNER_OBJ"];
    id cell = [singleTap.view.layer valueForKey:@"CELL_OBJ"];
    if (banner) {
        int bannerId = banner.bannerId;
        int bannerType = banner.bannerType;
        switch (bannerType) {
            case BANNER_SIMPLE://do nothing
            {
            }break;
            case BANNER_PRODUCT://open product
            {
                int productId = bannerId;
                ProductInfo* pInfo = (ProductInfo*)[ProductInfo getProductWithId:productId];
                if (pInfo) {
                    [self clickOnProduct:pInfo currentItemData:nil cell:cell];
                } else {
                    ProductInfo* pInfo = [[ProductInfo alloc] init];
                    pInfo._id = productId;
                    [self clickOnProduct:pInfo currentItemData:nil  cell:cell];
                }
            }break;
            case BANNER_CATEGORY://open category
            {
                int categoryId = bannerId;
                CategoryInfo *cInfo = [CategoryInfo getWithId:categoryId];
                [self clickOnCategory:cInfo currentItemData:nil];
            }break;
            case BANNER_WISHLIST://open wishlist
            {
                ViewControllerMain* mainVC = [ViewControllerMain getInstance];
                [mainVC btnClickedWishlist:nil];
            }break;
            case BANNER_CART://open cart
            {
                ViewControllerMain* mainVC = [ViewControllerMain getInstance];
                [mainVC btnClickedCart:nil];
            }break;
            default:
                break;
        }
        return;
    }
    int productId = (int)[singleTap.view tag];
    ProductInfo* pInfo = (ProductInfo*)[ProductInfo getProductWithId:productId];
    if (pInfo) {
        [self clickOnProduct:pInfo currentItemData:nil cell:cell];
    }
}
- (void)clickOnCategory:(CategoryInfo*)categoryClicked currentItemData:(DataPass*)currentItemData{
    ViewControllerMain* mainVC = [ViewControllerMain getInstance];
    mainVC.containerTop.hidden = YES;
    mainVC.containerCenter.hidden = YES;
    mainVC.containerCenterWithTop.hidden = NO;
    mainVC.vcBottomBar.buttonHome.selected = YES;
    mainVC.vcBottomBar.buttonCart.selected = NO;
    mainVC.vcBottomBar.buttonWishlist.selected = NO;
    mainVC.vcBottomBar.buttonSearch.selected = NO;
    mainVC.revealController.panGestureEnable = false;
    [mainVC.vcBottomBar buttonClicked:nil];
    DataPass* clickedItemData = [[DataPass alloc] init];
    clickedItemData.itemId = categoryClicked._id;
    clickedItemData.isCategory = true;
    clickedItemData.isProduct = false;
    clickedItemData.hasChildCategory = [[categoryClicked getSubCategories] count];
    clickedItemData.childCount = (int)[[ProductInfo getOnlyForCategory:categoryClicked] count];
    clickedItemData.cInfo = categoryClicked;
    DataPass* previousItemData = [[DataPass alloc] init];
    previousItemData.itemId = currentItemData.cInfo._id;
    previousItemData.isCategory = currentItemData.isCategory;
    previousItemData.isProduct = currentItemData.isProduct;
    previousItemData.hasChildCategory = currentItemData.hasChildCategory;
    previousItemData.childCount = currentItemData.childCount;
    previousItemData.cInfo = currentItemData.cInfo;
    ViewControllerCategories* vcCategories = [[Utility sharedManager] pushScreen:mainVC.vcCenterTop];
    [vcCategories loadData:clickedItemData previousItem:previousItemData drillingLevel:0];
}
#pragma mark - Methods

- (void)initVariables {
    
    self.view.backgroundColor = [Utility getUIColor:kUIColorBgTheme];
    _viewsAdded = [[NSMutableArray alloc] init];
    for (int i = 0; i < _kTotalViewsCouponScreen; i++) {
        _viewUserDefined[i] = nil;
        _propCollectionView[i] = [[LayoutProperties alloc] initWithCollectionViewValues:SCROLL_TYPE_HORIZONTAL];
        _viewUserDefinedHeaderString[i] = @"";
        _viewUserDefinedHeader[i] = nil;
        _isViewUserDefinedEnable[i] = false;
        RLOG(@"i  %d",i);
    }
    
    _isViewUserDefinedEnable[_kExclude_Categoryid_Cell] = false;
    _isViewUserDefinedEnable[_kExclude_Productid_Cell] = false;
    _isViewUserDefinedEnable[_kCategoryid_Cell] = false;
    _isViewUserDefinedEnable[_kProductid_Cell] = false;
    
    _viewUserDefinedHeaderString[_kExclude_Categoryid_Cell] = @"Discount not applied on Categories";
    _viewUserDefinedHeaderString[_kExclude_Productid_Cell] = @"Discount not applied on Products";
    _viewUserDefinedHeaderString[_kCategoryid_Cell] = @"Discount apply on Categories";
    _viewUserDefinedHeaderString[_kProductid_Cell] = @"Discount apply on Products";
    _viewKey[_kExclude_Categoryid_Cell] = @"bhfg";
    _viewKey[_kExclude_Productid_Cell] = @"gfhgf";
    _viewKey[_kCategoryid_Cell] = @"gfhbfg";
    _viewKey[_kProductid_Cell] = @"gbhfg";

    if (self.coupon._exclude_product_ids != nil && self.coupon._exclude_product_ids.count > 0){
        _isViewUserDefinedEnable[_kExclude_Productid_Cell] = true;
    }
    if (self.coupon._exclude_product_category_ids != nil && self.coupon._exclude_product_category_ids.count){
        _isViewUserDefinedEnable[_kExclude_Categoryid_Cell] = true;
    }
    if (self.coupon._product_ids != nil && self.coupon._product_ids.count > 0) {
        _isViewUserDefinedEnable[_kProductid_Cell] = true;
    }
    if (self.coupon._product_category_ids != nil && self.coupon._product_category_ids.count > 0){
        _isViewUserDefinedEnable[_kCategoryid_Cell] = true;
    }
}
#pragma mark - Deal Views

- (void)createVariousViews {
    for (int i = 0; i < _kTotalViewsCouponScreen; i++) {
        if (_isViewUserDefinedEnable[i] == false) {
            continue;
        }
        //        if (![_viewUserDefinedHeaderString[i] isEqualToString:@""]) {
        float fontSize = 34;
        float alignFactor = .014f * [[MyDevice sharedManager] screenWidthInPortrait];
        _viewUserDefinedHeader[i]=[[UILabel alloc]initWithFrame:CGRectMake(alignFactor, alignFactor, _scrollView.frame.size.width - alignFactor * 2, fontSize + alignFactor * 2)];
        [_viewUserDefinedHeader[i] setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [_viewUserDefinedHeader[i] setBackgroundColor:[Utility getUIColor:kUIColorClear]];
        UIFont *customFont = [Utility getUIFont:kUIFontType24 isBold:false];
        fontSize = [customFont lineHeight];
        [_viewUserDefinedHeader[i] setUIFont:customFont];
        [_viewUserDefinedHeader[i] setText:_viewUserDefinedHeaderString[i]];
        [_viewUserDefinedHeader[i] setTextColor:[Utility getUIColor:kUIColorFontSubTitle]];
        [_viewUserDefinedHeader[i] setTextAlignment:NSTextAlignmentLeft];
        [_viewUserDefinedHeader[i] setBaselineAdjustment:UIBaselineAdjustmentAlignBaselines];
        [_viewUserDefinedHeader[i] setLineBreakMode:NSLineBreakByCharWrapping];
        [_viewUserDefinedHeader[i] setNumberOfLines:1];
        [_scrollView addSubview:_viewUserDefinedHeader[i]];
        [_viewsAdded addObject:_viewUserDefinedHeader[i]];
        [_viewUserDefinedHeader[i] setTag:kTagForGlobalSpacing];
        //        }
        UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
        switch (i) {
            case _kExclude_Productid_Cell:
            {
                [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
                _viewUserDefined[i] = [[UICollectionView alloc] initWithFrame:[_propCollectionView[i] getFrameRect] collectionViewLayout:layout];
                [_viewUserDefined[i] setScrollEnabled:true];
                [_viewUserDefined[i] registerNib:[UINib nibWithNibName:_strCollectionView3 bundle:nil] forCellWithReuseIdentifier:@"CollectionCell"];
                [_scrollView addSubview:_viewUserDefined[i]];
                [_viewsAdded addObject:_viewUserDefined[i]];
                [_viewUserDefined[i] setTag:kTagForGlobalSpacing];
                RLOG(@"_kExclude_Productid_Cell");
            }break;
            case _kExclude_Categoryid_Cell:
            {
                [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
                _viewUserDefined[i] = [[UICollectionView alloc] initWithFrame:[_propCollectionView[i] getFrameRect] collectionViewLayout:layout];
                [_viewUserDefined[i] setScrollEnabled:true];
                [_viewUserDefined[i] registerNib:[UINib nibWithNibName:_strCollectionView3 bundle:nil] forCellWithReuseIdentifier:@"CollectionCell"];
                [_scrollView addSubview:_viewUserDefined[i]];
                [_viewsAdded addObject:_viewUserDefined[i]];
                [_viewUserDefined[i] setTag:kTagForGlobalSpacing];
                RLOG(@"_kExclude_Categoryid_Cell");
                
            }break;
            case _kProductid_Cell:
            {
                [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
                _viewUserDefined[i] = [[UICollectionView alloc] initWithFrame:[_propCollectionView[i] getFrameRect] collectionViewLayout:layout];
                [_viewUserDefined[i] setScrollEnabled:true];
                [_viewUserDefined[i] registerNib:[UINib nibWithNibName:_strCollectionView3 bundle:nil] forCellWithReuseIdentifier:@"CollectionCell"];
                [_scrollView addSubview:_viewUserDefined[i]];
                [_viewsAdded addObject:_viewUserDefined[i]];
                [_viewUserDefined[i] setTag:kTagForGlobalSpacing];
                RLOG(@"_kProductid_Cell");
            }break;
            case _kCategoryid_Cell:
            {
                [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
                _viewUserDefined[i] = [[UICollectionView alloc] initWithFrame:[_propCollectionView[i] getFrameRect] collectionViewLayout:layout];
                [_viewUserDefined[i] setScrollEnabled:true];
                [_viewUserDefined[i] registerNib:[UINib nibWithNibName:_strCollectionView3 bundle:nil] forCellWithReuseIdentifier:@"CollectionCell"];
                [_scrollView addSubview:_viewUserDefined[i]];
                [_viewsAdded addObject:_viewUserDefined[i]];
                [_viewUserDefined[i] setTag:kTagForGlobalSpacing];
                RLOG(@"_kCategoryid_Cell");
            }break;
                
            default:
                break;
        }
        [_viewUserDefined[i] setBackgroundColor:_propCollectionView[i]._bgColor];
        [_viewUserDefined[i] setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [_viewUserDefined[i] setDataSource:self];
        [_viewUserDefined[i] setDelegate:self];
        [_viewUserDefined[i] reloadData];
        [self resetMainScrollView];
    }
}

- (void)loadDataInView {
    [_scrollView setAlpha:0];
    for (int i = 0; i < _kTotalViewsCouponScreen; i++) {
        [_propCollectionView[i] setCollectionViewProperties:_propCollectionView[i] scrollType:SCROLL_TYPE_SHOWFULL];
    }
    for (UIView* view in _viewsAdded) {
        [view removeFromSuperview];
    }
    [_viewsAdded removeAllObjects];
    [self createTopview];
    [self createVariousViews];
    [[Utility sharedManager] stopGrayLoadingBar];
    [self resetMainScrollView];
    [_scrollView setAlpha:1];
}

-(void)createTopview{
    float itemPosX = [[MyDevice sharedManager] screenSize].width * 0.00f;
    float itemPosY = [[MyDevice sharedManager] screenSize].width * 0.00f;
    float itemWidth = [[MyDevice sharedManager] screenSize].width ;
    float viewPosX = [[MyDevice sharedManager] screenSize].width * 0.02f;
    float viewPosY = 100;
    
    float viewWidth = [[MyDevice sharedManager] screenSize].width - viewPosX*2 ;
    float gapY = [[MyDevice sharedManager] screenSize].width * 0.02f;;
    
    UIView *view = [[UIView alloc]init];
    view.frame = CGRectMake(viewPosX, viewPosY, viewWidth, 0);
    view.backgroundColor = [UIColor whiteColor];
    [_scrollView addSubview:view];
    [_viewsAdded addObject:view];
    
    UILabel *lblCoupon =[[UILabel alloc] init];
    lblCoupon.frame = CGRectMake(itemPosX, itemPosY, itemWidth, itemPosY);
    lblCoupon.numberOfLines = 0;
    [lblCoupon setUIFont:kUIFontType18 isBold:false];
    [lblCoupon setTextColor:[Utility getUIColor:kUIColorFontDark]];
    [lblCoupon setText:_coupon._code];
    [lblCoupon sizeToFitUI];
    [view addSubview:lblCoupon];
    
    itemPosY = (CGRectGetMaxY(lblCoupon.frame) + gapY);
    
    if (_coupon._expiry_date != nil){
        UILabel *lblExpiry_Date =[[UILabel alloc] init];
        lblExpiry_Date.frame = CGRectMake(itemPosX, itemPosY, itemWidth, itemPosY);
        lblExpiry_Date.numberOfLines = 0;
        [lblExpiry_Date setUIFont:kUIFontType18 isBold:false];
        [lblExpiry_Date setTextColor:[Utility getUIColor:kUIColorFontDark]];
        NSString *expiry_date = [NSString stringWithFormat:@"%@",_coupon._expiry_date];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ssZZZZ"];
        NSDate *date = [dateFormat dateFromString:expiry_date];
        [dateFormat setDateFormat:@"dd-MM-yyyy"];
        lblExpiry_Date.text = [NSString stringWithFormat:@"%@",[dateFormat stringFromDate:date]];
        [lblExpiry_Date sizeToFitUI];
        float ExpiryDatePosX= viewWidth -lblExpiry_Date.frame.size.width;
        lblExpiry_Date.frame = CGRectMake(ExpiryDatePosX, itemPosY, itemWidth, itemPosY);
        [view addSubview:lblExpiry_Date];
    }

    
    itemPosY = (CGRectGetMaxY(lblCoupon.frame) + gapY);
    UILabel *lblDescription =[[UILabel alloc] init];
    lblDescription.frame = CGRectMake(itemPosX, itemPosY, itemWidth, itemPosY);
    lblDescription.numberOfLines = 0;
    [lblDescription setUIFont:kUIFontType18 isBold:false];
    [lblDescription setTextColor:[Utility getUIColor:kUIColorFontDark]];
    [lblDescription setText:_coupon._description];
    [lblDescription sizeToFitUI];
    [view addSubview:lblDescription];
    
    
    itemPosY = (CGRectGetMaxY(lblDescription.frame) + gapY);
    
    if (_coupon._enable_free_shipping) {
        UILabel *lblfree_shipping =[[UILabel alloc] init];
        lblfree_shipping.frame = CGRectMake(itemPosX, itemPosY, itemWidth, itemPosY);
        lblfree_shipping.numberOfLines = 0;
        [lblfree_shipping setUIFont:kUIFontType18 isBold:false];
        [lblfree_shipping setTextColor:[Utility getUIColor:kUIColorFontDark]];
        lblfree_shipping.text = [NSString stringWithFormat:@"%@",Localize(@"free_shipping_available")];
        [lblfree_shipping sizeToFitUI];
        float freeShipingPosX= viewWidth -lblfree_shipping.frame.size.width;
        lblfree_shipping.frame = CGRectMake(freeShipingPosX, itemPosY, itemWidth, itemPosY);
        [view addSubview:lblfree_shipping];
    }
    
    itemPosY = (CGRectGetMaxY(lblDescription.frame) + gapY );
    UILabel *lblAmount =[[UILabel alloc] init];
    lblAmount.frame = CGRectMake(itemPosX, itemPosY, itemWidth, itemPosY);
    lblAmount.numberOfLines = 0;
    [lblAmount setUIFont:kUIFontType18 isBold:false];
    [lblAmount setTextColor:[Utility getUIColor:kUIColorFontDark]];
    if ([_coupon._type isEqualToString:@"fixed_product"]||[_coupon._type isEqualToString:@"fixed_cart"])
    {
        float newPrice = _coupon._amount;
        NSString *Price = [[Utility sharedManager] convertToString:newPrice isCurrency:true];
        [lblAmount setText:[NSString stringWithFormat:@"%@ : %@", Localize(@"i_available_discount"), Price]];
    }
    else if ([_coupon._type isEqualToString:@"percent"]|| [_coupon._type isEqualToString:@"percent_product"])
    {
        lblAmount.text =[NSString stringWithFormat:@"%@ : %d%%",Localize(@"i_available_discount"),(int)_coupon._amount];
    }
    [lblAmount sizeToFitUI];
    [view addSubview:lblAmount];
    

    itemPosY = (CGRectGetMaxY(lblAmount.frame) + gapY + gapY);
    UILabel *lblCanNOT =[[UILabel alloc] init];
    lblCanNOT.frame = CGRectMake(itemPosX, itemPosY, itemWidth, itemPosY);
    lblCanNOT.numberOfLines = 0;
    [lblCanNOT setUIFont:kUIFontType18 isBold:false];
    [lblCanNOT setTextColor:[Utility getUIColor:kUIColorFontDark]];
    [lblCanNOT setText:[NSString stringWithFormat:@"%@",Localize(@"cannot_apply_coupons")]];
    [lblCanNOT sizeToFitUI];
    [view addSubview:lblCanNOT];
    
    itemPosY = (CGRectGetMaxY(lblCanNOT.frame) + gapY);
    
    view.frame = CGRectMake(viewPosX, viewPosY, viewWidth, itemPosY);
    
    [self resetMainScrollView];
}


#pragma mark - Adjust Orientation
- (void)beforeRotation {
    [self beforeRotation:0.1f];
}
- (void)afterRotation {
    [self afterRotation:0.1f];
}
- (void)beforeRotation:(float)dt {
    
//    [UIView animateWithDuration:dt animations:^{
//        [_footerView setAlpha:0.0f];
//    }completion:^(BOOL finished){
//    }];
    
    
    UIView* lastView = [_viewsAdded lastObject];
    for(UIView *view in _viewsAdded)
    {
        [UIView animateWithDuration:dt animations:^{
            [view setAlpha:0.0f];
        }completion:^(BOOL finished){
            [view removeFromSuperview];
            if (view == lastView) {
                [_scrollView setAlpha:0.0f];
                [_viewsAdded removeAllObjects];
//                _couponView = nil;
//                _couponViewWithAppliedCoupon = nil;
//                _couponViewWithTextField = nil;
//                _rewardDiscountView = nil;
//                _rewardDiscountViewWithTextField = nil;
//                _autoAppliedCouponView = nil;
                [self loadDataInView];
                for(UIView *vieww in _viewsAdded)
                {
                    [vieww setAlpha:0.0f];
                }
                [_scrollView setAlpha:1.0f];
            }
        }];
    }
}
- (void)afterRotation:(float)dt  {
    for(UIView *vieww in _viewsAdded)
    {
        [UIView animateWithDuration:dt animations:^{
            [vieww setAlpha:1.0f];
        }completion:^(BOOL finished){
            
        }];
    }
    
//    [UIView animateWithDuration:dt animations:^{
//        [_footerView setAlpha:1.0f];
//    }completion:^(BOOL finished){
//    }];
}
- (void)adjustViewsForOrientation:(UIDeviceOrientation) orientation {
    RLOG(@"====adjustViewsForOrientation====");
    [self beforeRotation];
}
- (void)adjustViewsAfterOrientation:(UIDeviceOrientation) orientation {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    RLOG(@"====adjustViewsAfterOrientation====");
    [self afterRotation];
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    if ([[AppDelegate getInstance] isAppEnteredInBackground]) {
        return;
    }
    [self adjustViewsAfterOrientation:[[UIDevice currentDevice] orientation]];
    [self resetMainScrollView]; 
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if ([[AppDelegate getInstance] isAppEnteredInBackground]) {
        return;
    }
    [self adjustViewsForOrientation:[[UIDevice currentDevice] orientation]];
    [self resetMainScrollView];
}
#pragma mark - Reset Views

- (void)resetMainScrollView {
    float globalPosY = 0.0f;
    
    //    RLOG(@"\n_scrollView child count %d",(int)[[_scrollView subviews] count]);
    UIView* tempView = nil;
    for (tempView in _viewsAdded) {
        //        RLOG(@"\ntempView = %@, globalPosY = %.f", tempView, globalPosY);
        //        if(tempView ==  _viewUserDefined[2]) {
        //            RLOG(@"");
        //        }
        
        CGRect rect = [tempView frame];
        rect.origin.y = globalPosY;
        [tempView setFrame:rect];
        globalPosY += rect.size.height;
        
        //        if ([tempView tag] == kTagForGlobalSpacing) {
        //            globalPosY += [LayoutProperties globalVerticalMargin];
        //        }
    }
    RLOG(@"globalPosY %f",globalPosY);
    [_scrollView setContentSize:CGSizeMake(_scrollView.contentSize.width, globalPosY)];
}
@end
