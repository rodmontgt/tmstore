//
//  CVHorizontalCell.m
//  TMStore
//
//  Created by Raj shekar on 17/11/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import "CVHorizontalCell.h"
#import "CCollectionViewCell.h"
#import "Utility.h"
#import "AppUser.h"
#import "ViewControllerMain.h"
#import "ViewControllerProduct.h"
#import "ProductInfo.h"
#import "DataManager.h"
#import "ViewControllerCategories.h"
//#import "ViewControllerCategoriesNew.h"

@implementation CVHorizontalCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    _strCollectionView3 = [[Utility sharedManager] getHorizontalViewString];
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [self.cvHorizontalCategory setScrollEnabled:true];
    [self.cvHorizontalCategory registerNib:[UINib nibWithNibName:_strCollectionView3 bundle:nil] forCellWithReuseIdentifier:@"CollectionCell"];

    [ _buttonViewAll setTintColor:[Utility getUIColor:kUIColorThemeButtonSelected]];
    [_buttonViewAll setTitleColor:[Utility getUIColor:kUIColorThemeButtonSelected] forState:UIControlStateNormal];
    [_buttonViewAll.titleLabel setUIFont:kUIFontType18 isBold:true];
    [_labelCategoryName setUIFont:kUIFontType18 isBold:true];
    _labelCategoryName.textAlignment = NSTextAlignmentLeft;
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        _labelCategoryName.textAlignment = NSTextAlignmentRight;
    }
}
#pragma mark - Collection View
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{

    int itemCount = 0;
    //CategoryInfo* cInfo = [self.cvHorizontalCategory.layer valueForKey:@"CATEGORY_OBJ"];
    if (self.productsArray) {
        itemCount = (int)[self.productsArray count];
    }
    return itemCount;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *CellIdentifier = @"CollectionCell";
    CCollectionViewCell *cell=(CCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];

    [cell setNeedsLayout];

//        if(cell == nil) {
//            NSArray *nib = [[ NSBundle mainBundle] loadNibNamed:_strCollectionView3 owner:self options:nil];
//            cell = [nib objectAtIndex:0];
//        }
//
//        [Utility showShadow:cell];
//        [cell setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
//        [[cell productName] setUIFont:kUIFontType16 isBold:false];
//        [[cell productName] setTextColor:[Utility getUIColor:kUIColorFontDark]];
//        [[cell productPriceOriginal] setUIFont:kUIFontType14 isBold:false];
//        [[cell productPriceFinal] setUIFont:kUIFontType14 isBold:false];
//
//        if ([[TMLanguage sharedManager] isRTLEnabled]) {
//            [[cell productName] setTextAlignment:NSTextAlignmentRight];
//            [[cell productPriceOriginal] setTextAlignment:NSTextAlignmentRight];
//            [[cell productPriceFinal] setTextAlignment:NSTextAlignmentRight];
//        }
//            ProductInfo *pInfo = (ProductInfo*) ([self.productsArray objectAtIndex:indexPath.row]);
//            [[cell productName] setText:pInfo._titleForOuterView];
//            [[cell productPriceOriginal] setAttributedText:[pInfo getPriceOldString]];
//            [[cell productPriceFinal] setText:[pInfo getPriceNewString]];
//            if ([pInfo._images count] == 0) {
//                [pInfo._images addObject:[[ProductImage alloc] init]];
//            }
//            if (([[GuestConfig sharedInstance] hide_price] && ![AppUser isSignedIn]) || [[Addons sharedManager] hide_price]) {
//                [[cell productPriceOriginal] setText:@""];
//                [[cell productPriceFinal] setText:@""];
//                [cell.productPriceOriginal sizeToFitUI];
//                [cell.productPriceFinal sizeToFitUI];
//            } else {
//                [cell.productPriceOriginal sizeToFitUI];
//                [cell.productPriceFinal sizeToFitUI];
//            }
//            ProductImage *pImage = [pInfo._images objectAtIndex:0];
//            [Utility setImage:cell.productImg url:pImage._src resizeType:kRESIZE_TYPE_PRODUCT_THUMBNAIL isLocal:false];
//
//            if ([cell buttonWishlist].imageView.image.renderingMode != UIImageRenderingModeAlwaysTemplate) {
//                UIImage* normal = [[UIImage imageNamed:@"wishlist_icon_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//                UIImage* selected = [[UIImage imageNamed:@"wishlist_icon_pressed"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//                [[cell buttonWishlist] setUIImage:normal forState:UIControlStateNormal];
//                [[cell buttonWishlist] setUIImage:selected forState:UIControlStateSelected];
//            }
//
//            [[cell buttonWishlist] addTarget:[Utility sharedManager] action:@selector(wishlistButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//            [[cell buttonWishlist] setTag:pInfo._id];
//            [[Utility sharedManager] initWishlistButton:[cell buttonWishlist]];
//
//
//            if ([cell.productImg.layer valueForKey:@"UITapGestureRecognizer"]) {
//                [cell.productImg removeGestureRecognizer:((UITapGestureRecognizer*)[cell.productImg.layer valueForKey:@"UITapGestureRecognizer"])];
//            }
//            [cell.productImg setTag:pInfo._id];
//            UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bannerTapped:)];
//            singleTap.numberOfTapsRequired = 1;
//            singleTap.numberOfTouchesRequired = 1;
//            [cell.productImg addGestureRecognizer:singleTap];
//            [singleTap.view.layer setValue:cell forKey:@"CELL_OBJ"];
//            [cell.productImg setUserInteractionEnabled:YES];
//            [cell.productImg.layer setValue:singleTap forKey:@"UITapGestureRecognizer"];
//            [cell.productImg.layer setValue:pInfo._titleForOuterView forKey:@"PNAME"];
//            if ([cell buttonAdd].imageView.image.renderingMode != UIImageRenderingModeAlwaysTemplate) {
//                UIImage* normal = [[UIImage imageNamed:@"button_circle"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//                [cell.buttonAdd setBackgroundImage:normal forState:UIControlStateNormal];
//            }
//            if ([cell buttonSubstract].imageView.image.renderingMode != UIImageRenderingModeAlwaysTemplate) {
//                UIImage* normal = [[UIImage imageNamed:@"button_circle"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//                [cell.buttonSubstract setBackgroundImage:normal forState:UIControlStateNormal];
//            }
//            if (pInfo) {
//                [cell.layer setValue:self forKey:@"VC"];
//                [cell.layer setValue:pInfo forKey:@"PRODUCT_INFO"];
//                [cell.layer setValue:pInfo forKey:@"PINFO_OBJ"];
//                [cell.buttonAdd.layer setValue:pInfo forKey:@"PINFO_OBJ"];
//                [cell.buttonAdd.layer setValue:cell forKey:@"CELL_OBJ"];
//                [cell.buttonCart.layer setValue:pInfo forKey:@"PINFO_OBJ"];
//                [cell.buttonCart setTitle:Localize(@"toggle_cart_on") forState:UIControlStateNormal];
//                [cell.buttonCart.layer setValue:cell forKey:@"CELL_OBJ"];
//                [cell.buttonSubstract.layer setValue:pInfo forKey:@"PINFO_OBJ"];
//                [cell.buttonSubstract.layer setValue:cell forKey:@"CELL_OBJ"];
//                [cell.textFieldAmt.layer setValue:pInfo forKey:@"PINFO_OBJ"];
//                [cell.textFieldAmt.layer setValue:cell forKey:@"CELL_OBJ"];
//
//                [cell.buttonCart addTarget:self action:@selector(cartButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//                [cell.buttonAdd addTarget:self action:@selector(addButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//                [cell.buttonSubstract addTarget:self action:@selector(substractButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//
//            }else {
//                [cell.layer setValue:nil forKey:@"PRODUCT_INFO"];
//                [cell.layer setValue:nil forKey:@"PINFO_OBJ"];
//            }
    return cell;
}
//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
//    ProductInfo *pInfo = (ProductInfo*) ([self.productsArray objectAtIndex:indexPath.row]);
//    ProductInfo* pInfoDetail = (ProductInfo*)[ProductInfo getProductWithId:pInfo._id];
//    [self clickOnProduct:pInfoDetail currentItemData:nil cell:nil];
//}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableArray *array = nil;

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

    //    _propCollectionView[i]._insetTop =  insetTop;
    //    _propCollectionView[i]._insetLeft =  insetLeft;
    //    _propCollectionView[i]._insetBottom =  insetBottom;
    //    _propCollectionView[i]._insetRight =  insetRight;
    //
    //    _propCollectionView[i]._height = cardHeight + _propCollectionView[i]._insetTop + _propCollectionView[i]._insetBottom;
    //    [_viewUserDefined[i] setFrame:[_propCollectionView[i] getFrameRect]];
    //    [self resetMainScrollView];
    return CGSizeMake(cardWidth, cardHeight);
}
#pragma mark - Custom Methods

- (void)clickOnProduct:(id)productClicked currentItemData:(id)currentItemData cell:(id)cell {
    // self.isHomeScreenPresented = false;
    ProductInfo* pInfo = productClicked;
    DataPass* dPass = currentItemData;

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
    clickedItemData.itemId = pInfo._id;
    clickedItemData.isCategory = false;
    clickedItemData.isProduct = true;
    clickedItemData.hasChildCategory = false;
    clickedItemData.childCount = false;
    clickedItemData.pInfo = pInfo;

    DataPass* previousItemData = [[DataPass alloc] init];
    previousItemData.itemId = dPass.cInfo._id;
    previousItemData.isCategory = dPass.isCategory;
    previousItemData.isProduct = dPass.isProduct;
    previousItemData.hasChildCategory = dPass.hasChildCategory;
    previousItemData.childCount = dPass.childCount;
    previousItemData.cInfo = dPass.cInfo;

    ViewControllerProduct* vcProduct = [[Utility sharedManager] pushProductScreen:mainVC.vcCenterTop];
    [vcProduct loadData:clickedItemData previousItem:previousItemData drillingLevel:0];
    vcProduct.parentVC = self;
    vcProduct.parentCell = cell;
}
- (void)clickOnCategory:(CategoryInfo*)categoryClicked currentItemData:(DataPass*)currentItemData{
    // self.isHomeScreenPresented = false;
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
                    [self clickOnProduct:pInfo currentItemData:nil cell:cell];
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
        if (pInfo._variations && [pInfo._variations count] > 0) {
            //open new popup to choose variation and add to cart
            [self clickOnProduct:pInfo currentItemData:nil cell:cell];
        }else {
            int availState = [Cart getProductAvailibleState:pInfo variationId:-1];
            if (availState == PRODUCT_QTY_DEMAND || availState == PRODUCT_QTY_STOCK) {
                [Cart addProduct:pInfo variationId:-1 variationIndex:-1 selectedVariationAttributes:nil];
            }
        }
    }
    [cell refreshCell:pInfo];
}
- (void)addButtonClicked:(UIButton*)button {
    ProductInfo* pInfo = (ProductInfo*)[button.layer valueForKey:@"PINFO_OBJ"];
    CCollectionViewCell* cell = (CCollectionViewCell*)[button.layer valueForKey:@"CELL_OBJ"];
    if (pInfo._variations && [pInfo._variations count] > 0) { } else {
        [Cart addProduct:pInfo variationId:-1 variationIndex:-1 selectedVariationAttributes:nil];
    }
    [cell refreshCell:pInfo];
}
- (void)substractButtonClicked:(UIButton*)button {
    ProductInfo* pInfo = (ProductInfo*)[button.layer valueForKey:@"PINFO_OBJ"];
    CCollectionViewCell* cell = (CCollectionViewCell*)[button.layer valueForKey:@"CELL_OBJ"];
    if (pInfo._variations && [pInfo._variations count] > 0) { } else {
        Cart* cInfo = [Cart getCartFromProduct:pInfo variationId:-1 variationIndex:-1];
        if(cInfo.count > 1) {
            cInfo.count -= 1;
        } else {
            [Cart removeProduct:pInfo variationId:-1 variationIndex:-1];
        }
    }
    [cell refreshCell:pInfo];
}

- (IBAction)buttonViewAllAction:(id)sender{
    CategoryInfo* cInfo = [self.cvHorizontalCategory.layer valueForKey:@"CATEGORY_OBJ"];
    [self clickOnCategory:cInfo currentItemData:nil];
}


@end
