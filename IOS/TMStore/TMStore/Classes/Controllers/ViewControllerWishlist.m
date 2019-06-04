//
//  ViewControllerWishlist.m

//
//  Created by Rishabh Jain on 24/09/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import "ViewControllerWishlist.h"
#import "Utility.h"
#import "MyDevice.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "AppUser.h"
#import "Cart.h"
#import "Wishlist.h"
#import "DataManager.h"
#import "CWishList.h"
#import "AnalyticsHelper.h"

static int kTagForGlobalSpacing = 0;
static int kTagForNoSpacing = -1;

@implementation PairWishlist
@end

@interface ViewControllerWishlist () {
    NSMutableArray *_viewsAdded;
    NSMutableArray *_horizontalScrollViews;
    NSMutableArray *_tempPairArray;
}
@end

@implementation ViewControllerWishlist

#pragma mark - View Life Cycle

- (void)viewDidLoad {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super viewDidLoad];
    
    [self initVariables];
    [_labelNoItems setUIFont:kUIFontType20 isBold:false];
    _labelNoItems.textColor = [Utility getUIColor:kUIColorFontLight];
    
}
-(void)viewDidAppear:(BOOL)animated{
#if ENABLE_FIREBASE_TAG_MANAGER
    [[AnalyticsHelper sharedInstance] registerVisitScreenEvent:@"Wishlist Screen"];
#endif
}
- (void)viewWillAppear:(BOOL)animated {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super viewWillAppear:animated];
    //rv//[SDWebImageManager.sharedManager.imageDownloader setValue:@"SDWebImage Demo" forHTTPHeaderField:@"AppName"];
//    SDWebImageManager.sharedManager.imageDownloader.executionOrder = SDWebImageDownloaderFIFOExecutionOrder;
    
    [self loadViewDA];
    [self syncWishListDetails];
    [Wishlist resetNotificationItemCount];
}
- (void)didReceiveMemoryWarning {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super didReceiveMemoryWarning];
}
- (void)flushCache {
    [SDWebImageManager.sharedManager.imageCache clearMemory];
    
}
- (void)initVariables {
    [_scrollView setBackgroundColor:[Utility getUIColor:kUIColorBgTheme]];
    _viewsAdded = [[NSMutableArray alloc] init];
    _tempPairArray = [[NSMutableArray alloc] init];
}
- (void)loadViewDA {
    [_tempPairArray removeAllObjects];
    for (UIView* view in _viewsAdded) {
        [view removeFromSuperview];
    }
    [_viewsAdded removeAllObjects];
    
    [self.view setBackgroundColor:[Utility getUIColor:kUIColorBgTheme]];
    
    int itemsCount = (int)[[[AppUser sharedManager] _wishlistArray] count];
    if (itemsCount > 0) {
        _scrollView.hidden = false;
        _labelNoItems.hidden = true;
        for (int i = 0; i < itemsCount; i++) {
            Wishlist* c = (Wishlist*)[[[AppUser sharedManager] _wishlistArray] objectAtIndex:i];
            /*UIView* view = */[self addView:i pInfo:c.product isCartItem:false isWishlistItem:true quantity:c.count];
        }
        _finalAmountView = [self addFinalAmountView];
        _placeOrderButton = [self addPlaceOrderButton];
    }else{
        _scrollView.hidden = true;
        _labelNoItems.hidden = false;
        _labelNoItems.text = Localize(@"no_items_in_wishlist");
        [_labelNoItems setUIFont:kUIFontType20 isBold:false];
        _labelNoItems.textColor = [Utility getUIColor:kUIColorFontLight];
        _finalAmountView = nil;
        _placeOrderButton = nil;
    }
    [self resetMainScrollView:0.0f];
    [self updateViews];
}
- (UIView*)addView:(int)listId pInfo:(ProductInfo*)pInfo isCartItem:(BOOL)isCartItem isWishlistItem:(BOOL)isWishlistItem quantity:(int)quantity {
    Wishlist* c = (Wishlist*)[[[AppUser sharedManager] _wishlistArray] objectAtIndex:listId];
    Variation* variation = [pInfo._variations getVariation:c.selectedVariationId variationIndex:c.selectedVariationIndex];
    //    BOOL isItemOutofStock = false;
    
    UIView* mainView = [[UIView alloc] init];
    [_scrollView addSubview:mainView];
    [_viewsAdded addObject:mainView];
    [mainView setTag:kTagForGlobalSpacing];
    
    
    float viewMaxHeight = 250;
    float viewMaxWidth = self.view.frame.size.width * .98f;
    float viewOriginX = self.view.frame.size.width * .01f;
    float viewOriginY = self.view.frame.size.width * .01f;
    
    float imgRectH = MIN(viewMaxHeight * .75f * .80f, viewMaxWidth * .25f);
    viewMaxHeight = imgRectH * 1.67f;
    
    UIView* viewTop = [[UIView alloc] init];
    [viewTop setFrame:CGRectMake(viewOriginX, viewOriginY, viewMaxWidth, viewMaxHeight * .75f)];
    [viewTop.layer setBorderColor:[[Utility getUIColor:kUIColorBorder] CGColor]];
    [viewTop.layer setBorderWidth:1];
    [viewTop setBackgroundColor:[UIColor whiteColor]];
    
    UIView* viewBottom = [[UIView alloc] init];
    [viewBottom setFrame:CGRectMake(viewOriginX, viewOriginY, viewMaxWidth, viewMaxHeight * .25f)];
    [viewBottom.layer setBorderColor:[[Utility getUIColor:kUIColorBorder] CGColor]];
    [viewBottom.layer setBorderWidth:1];
    [viewBottom setBackgroundColor:[UIColor whiteColor]];
    
    [mainView addSubview:viewTop];
    [mainView addSubview:viewBottom];
    
    
    float viewTopWidth = viewTop.frame.size.width;
    float viewTopHeight = viewTop.frame.size.height;
    CGRect imgRect = CGRectMake(viewTopHeight * .1f,
                                viewTopHeight * .1f,
                                viewTopHeight * .8f,
                                viewTopHeight * .8f);
    
    CGRect nameRect = CGRectMake(imgRect.origin.x * 2 + imgRect.size.width,
                                 viewTopHeight * .15f,
                                 viewTopWidth,
                                 viewTopHeight);
    CGRect descRect = CGRectMake(nameRect.origin.x,
                                 viewTopHeight * .35f,
                                 (viewTopWidth - nameRect.origin.x - viewTopHeight * .1f) * .6f,
                                 viewTopHeight);
    CGRect priceRect = CGRectMake(nameRect.origin.x,
                                  viewTopHeight * .6f,
                                  viewTopWidth,
                                  viewTopHeight);
    
    CGRect priceOldRect = CGRectMake(nameRect.origin.x,
                                     viewTopHeight * .6f,
                                     viewTopWidth,
                                     viewTopHeight);
    
    CGRect priceNewRect = CGRectMake(nameRect.origin.x,
                                     viewTopHeight * .8f,
                                     viewTopWidth,
                                     viewTopHeight);
    
    CGRect priceFinalRect = CGRectMake(nameRect.origin.x,
                                       viewTopHeight * .8f,
                                       viewTopWidth,
                                       viewTopHeight);
    
    
    
    UIImageView* imgProduct = [[UIImageView alloc] init];
    imgProduct.frame = imgRect;
    [viewTop addSubview:imgProduct];
    
    if ([variation._images count] > 0) {
        [Utility setImage:imgProduct url:((ProductImage*)[variation._images objectAtIndex:0])._src resizeType:kRESIZE_TYPE_PRODUCT_THUMBNAIL isLocal:false];
    }else{
        if ([pInfo._images count] == 0) {
            [pInfo._images addObject:[[ProductImage alloc] init]];
        }
        [Utility setImage:imgProduct url:((ProductImage*)[pInfo._images objectAtIndex:0])._src resizeType:kRESIZE_TYPE_PRODUCT_THUMBNAIL isLocal:false];
    }
    
    [imgProduct.layer setBorderColor:[[Utility getUIColor:kUIColorBorder] CGColor]];
    [imgProduct.layer setBorderWidth:1];
    [imgProduct setContentMode:UIViewContentModeScaleAspectFill];
    [imgProduct setClipsToBounds:true];
    
    UILabel* labelName = [[UILabel alloc] init];
    [viewTop addSubview:labelName];
    
    UILabel* labelDesc = [[UILabel alloc] init];
    labelDesc.adjustsFontSizeToFitWidth = NO;
    labelDesc.lineBreakMode = NSLineBreakByTruncatingTail;
    
    [viewTop addSubview:labelDesc];
    
    UILabel* labelPrice = [[UILabel alloc] init];
    [viewTop addSubview:labelPrice];
    
    UILabel* labelPriceOld = [[UILabel alloc] init];
    [viewTop addSubview:labelPriceOld];
    
    UILabel* labelPriceNew = [[UILabel alloc] init];
    [viewTop addSubview:labelPriceNew];
    
    UILabel* labelPriceFinal = [[UILabel alloc] init];
    [viewTop addSubview:labelPriceFinal];
    
    
    [labelName setUIFont:kUIFontType18 isBold:true];
    [labelDesc setUIFont:kUIFontType14 isBold:false];
    [labelPrice setUIFont:kUIFontType16 isBold:false];
    [labelPriceOld setUIFont:kUIFontType14 isBold:false];
    [labelPriceNew setUIFont:kUIFontType16 isBold:false];
    [labelPriceFinal setUIFont:kUIFontType16 isBold:false];
    
    labelName.frame = nameRect;
    labelDesc.frame = descRect;
    labelPrice.frame = priceRect;
    
    
    //    [labelName setText:pInfo._title];
    [labelName setText:pInfo._titleForOuterView];
    
    
    
    //    [labelDesc setText:Localize(@"title_product_info")];
    //    [labelDesc setAttributedText:[[NSAttributedString alloc] initWithString:Localize(@"title_product_info")]];
    //    float labelSingleLineDescHeight = LABEL_SIZE(labelDesc).height ;
    
    NSString * htmlString = pInfo._short_description;
    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    [labelDesc setAttributedText:attrStr];
    
    NSString* priceStr;
    BOOL isDiscounted;
    float price;
    float oldPrice;
    if (variation) {
        isDiscounted = [pInfo isProductDiscounted:variation._id];
        price = [pInfo getNewPrice:variation._id];
        oldPrice = [pInfo getOldPrice:variation._id];
    } else {
        isDiscounted = [pInfo isProductDiscounted:-1];
        price = [pInfo getNewPrice:-1];
        oldPrice = [pInfo getOldPrice:-1];
    }
    priceStr = [[Utility sharedManager] convertToString:price isCurrency:true];
    [labelPriceOld setAttributedText:[[Utility sharedManager] convertToStringStrikethrough:oldPrice isCurrency:true]];
    
    RLOG(@"Final Rate = %@", [[Utility sharedManager] convertToStringStrikethrough:pInfo._regular_price isCurrency:true]);
    NSString* newPrice;
    if (quantity > 1) {
        newPrice = [NSString stringWithFormat:@"%@ X %d", priceStr, quantity] ;
    } else {
        newPrice = [NSString stringWithFormat:@"%@", priceStr];
    }
    [labelPriceNew setText:newPrice];
    [labelPrice setText:Localize(@"i_price")];
    [labelPriceFinal setText:[[Utility sharedManager] convertToString:(price * quantity) isCurrency:true]];
    
    
    
    
    
    if(![[Addons sharedManager] show_min_max_price]) {
        
    } else {
        
        if (pInfo._priceMax == pInfo._priceMin) {
            pInfo._priceNewString = [[Utility sharedManager] convertToString:pInfo._newPriceForOuterView isCurrency:true];
        } else {
            NSString* strMin = [[Utility sharedManager] convertToString:pInfo._priceMin isCurrency:true];
            NSString* strMax = [[Utility sharedManager] convertToString:pInfo._priceMax isCurrency:true];
            pInfo._priceNewString = [NSString stringWithFormat:@"%@ - %@", strMin, strMax];
        }
        
        [labelPriceOld setHidden:true];
        [labelPriceNew setText:pInfo._priceNewString];
        [labelPriceFinal setText:@""];
        [labelPriceFinal setHidden:true];
    }
    
    
    priceOldRect.origin.x = priceOldRect.origin.x + LABEL_SIZE(labelPrice).width + viewTopHeight * .1f;
    labelPriceOld.frame = priceOldRect;
    
    priceNewRect.origin.x = priceNewRect.origin.x + LABEL_SIZE(labelPrice).width + viewTopHeight * .1f;
    labelPriceNew.frame = priceNewRect;
    
    priceFinalRect.origin.x = viewTopWidth - LABEL_SIZE(labelPriceFinal).width - viewTopHeight * .1f;
    labelPriceFinal.frame = priceFinalRect;
    
    if(isDiscounted == false){
        priceNewRect = priceOldRect;
        labelPriceOld.hidden = true;
        labelPriceNew.frame = priceNewRect;
    }
    [labelPriceOld setTextColor:[Utility getUIColor:kUIColorFontPriceOld]];
    [labelPriceNew setTextColor:[Utility getUIColor:kUIColorFontDark]];
    [labelPriceFinal setTextColor:[Utility getUIColor:kUIColorFontDark]];
    
    [labelDesc setUIFont:kUIFontType14 isBold:false];
    [labelDesc sizeToFitUI];
    [labelPrice sizeToFitUI];
    //    RLOG(@"START==========");
    RLOG(@"====%@====", labelDesc.text);
    //    RLOG(@"END==========");
    float bottomPointDesc = labelDesc.frame.origin.y + labelDesc.frame.size.height;
    float startPointPriceOld = viewTopHeight * .6f;
    float startPointPriceNew = bottomPointDesc ;//+ viewTopHeight * .15f;
    
    float diffHeight = startPointPriceNew - startPointPriceOld;
    float labelPriceOldHeight = LABEL_SIZE(labelPriceOld).height ;
    if (diffHeight < 0 ) {
        diffHeight = 0;
    }
    
    RLOG(@"diffHeight = %.f",diffHeight);
    CGRect topViewUpdatedRect = viewTop.frame;
    if (labelPriceOld.hidden && diffHeight > labelPriceOldHeight) {
        topViewUpdatedRect.size.height += (diffHeight - labelPriceOldHeight);
    }
    viewTop.frame = topViewUpdatedRect;
    
    CGRect tempRect = labelPrice.frame;
    tempRect.origin.y +=  diffHeight;
    labelPrice.frame = tempRect;
    
    tempRect = labelPriceOld.frame;
    tempRect.origin.y +=  diffHeight;
    labelPriceOld.frame = tempRect;
    
    tempRect = labelPriceNew.frame;
    tempRect.origin.y +=  diffHeight;
    labelPriceNew.frame = tempRect;
    
    tempRect = labelPriceFinal.frame;
    tempRect.origin.y = labelPriceNew.frame.origin.y;
    labelPriceFinal.frame = tempRect;
    
    [labelName sizeToFitUI];
    //    [labelDesc sizeToFitUI];
    
    CGRect nameRe = labelName.frame;
    nameRe.size.width = (viewTopWidth - nameRect.origin.x - viewTopHeight * .1f);
    labelName.frame = nameRe;
    
    CGRect descRe = labelDesc.frame;
    descRe.size.width = (viewTopWidth - nameRect.origin.x - viewTopHeight * .1f),
    labelDesc.frame = descRe;
    
    [labelPrice sizeToFitUI];
    [labelPriceOld sizeToFitUI];
    [labelPriceNew sizeToFitUI];
    [labelPriceFinal sizeToFitUI];
    
    [labelName setTextColor:[Utility getUIColor:kUIColorFontLight]];
    [labelDesc setTextColor:[Utility getUIColor:kUIColorFontLight]];
    [labelPrice setTextColor:[Utility getUIColor:kUIColorFontDark]];
    [labelPriceOld setTextColor:[Utility getUIColor:kUIColorFontPriceOld]];
    [labelPriceNew setTextColor:[Utility getUIColor:kUIColorFontDark]];
    [labelPriceFinal setTextColor:[Utility getUIColor:kUIColorFontDark]];
    
    UIButton* buttonLeft = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonLeft.titleLabel setUIFont:kUIFontType20 isBold:false];
    [buttonLeft setFrame:CGRectMake(0, 0 , (viewBottom.frame.size.width+2)/2+2, viewBottom.frame.size.height)];
    [buttonLeft.layer setBorderColor:[[Utility getUIColor:kUIColorBorder] CGColor]];
    [buttonLeft.layer setBorderWidth:1];
    [buttonLeft setContentMode:UIViewContentModeScaleAspectFit];
    [buttonLeft.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [buttonLeft setImageEdgeInsets:UIEdgeInsetsMake(viewBottom.frame.size.height * .25f, 0, viewBottom.frame.size.height * .25f, 0)];
    [buttonLeft setTitleEdgeInsets:UIEdgeInsetsMake(viewBottom.frame.size.height * .25f, 0, viewBottom.frame.size.height * .25f, 0)];
    
    UIButton* buttonRight =[UIButton buttonWithType:UIButtonTypeCustom];
    [buttonRight.titleLabel setUIFont:kUIFontType20 isBold:false];
    [buttonRight setFrame:CGRectMake((viewBottom.frame.size.width+2)/2+1, 0, viewBottom.frame.size.width/2, viewBottom.frame.size.height)];
    [buttonRight.layer setBorderColor:[[Utility getUIColor:kUIColorBorder] CGColor]];
    [buttonRight.layer setBorderWidth:1];
    [buttonRight setContentMode:UIViewContentModeScaleAspectFit];
    [buttonRight.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [buttonRight setImageEdgeInsets:UIEdgeInsetsMake(viewBottom.frame.size.height * .25f, 0, viewBottom.frame.size.height * .25f, 0)];
    [buttonRight setTitleEdgeInsets:UIEdgeInsetsMake(viewBottom.frame.size.height * .25f, 0, viewBottom.frame.size.height * .25f, 0)];
    
    [viewBottom addSubview:buttonLeft];
    [viewBottom addSubview:buttonRight];
    
    NSString *titleLeftButtonPressed;
    NSString *titleRightButtonPressed;
    UIColor *colorLeftButtonPressed;
    UIColor *colorRightButtonPressed;
    UIImage *imageLeftButtonPressed;
    UIImage *imageRightButtonPressed;
    if (isCartItem) {
        titleLeftButtonPressed = Localize(@"i_remove");
        titleRightButtonPressed= Localize(@"menu_title_wishlist");
        imageLeftButtonPressed = [[UIImage imageNamed:@"remove_icon_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        imageRightButtonPressed = [[UIImage imageNamed:@"wishlist_icon_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        colorLeftButtonPressed = [Utility getUIColor:kUIColorThemeButtonNormal];
        colorRightButtonPressed = [Utility getUIColor:kUIColorThemeButtonNormal];
        [buttonRight addTarget:self action:@selector(moveToWishlist:) forControlEvents:UIControlEventTouchUpInside];
    }
    else {
        titleLeftButtonPressed = Localize(@"i_remove");
        titleRightButtonPressed= Localize(@"title_mycart");
        imageLeftButtonPressed = [[UIImage imageNamed:@"remove_icon_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        imageRightButtonPressed = [[UIImage imageNamed:@"cart_icon_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        colorLeftButtonPressed = [Utility getUIColor:kUIColorThemeButtonNormal];
        colorRightButtonPressed = [Utility getUIColor:kUIColorThemeButtonNormal];
        [buttonRight addTarget:self action:@selector(addToCart:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [buttonLeft setUIImage:imageLeftButtonPressed forState:UIControlStateNormal];
    [buttonLeft setUIImage:imageLeftButtonPressed forState:UIControlStateSelected];
    [buttonLeft setTitle:titleLeftButtonPressed forState:UIControlStateNormal];
    [buttonLeft setTitle:titleLeftButtonPressed forState:UIControlStateSelected];
    [buttonLeft setTitleColor:colorLeftButtonPressed forState:UIControlStateNormal];
    [buttonLeft setTitleColor:colorLeftButtonPressed forState:UIControlStateSelected];
    [buttonLeft setTintColor:colorLeftButtonPressed];
    
    [buttonRight setUIImage:imageRightButtonPressed forState:UIControlStateNormal];
    [buttonRight setUIImage:imageRightButtonPressed forState:UIControlStateSelected];
    [buttonRight setTitle:titleRightButtonPressed forState:UIControlStateNormal];
    [buttonRight setTitle:titleRightButtonPressed forState:UIControlStateSelected];
    [buttonRight setTitleColor:colorRightButtonPressed forState:UIControlStateNormal];
    [buttonRight setTitleColor:colorRightButtonPressed forState:UIControlStateSelected];
    [buttonRight setTintColor:colorRightButtonPressed];
    
    [buttonLeft addTarget:self action:@selector(removeFromList:) forControlEvents:UIControlEventTouchUpInside];
    
    [buttonLeft setTag:listId];
    [buttonRight setTag:listId];
    PairWishlist* pair = [[PairWishlist alloc] init];
    pair.buttonLeft = buttonLeft;
    pair.buttonRight = buttonRight;
    pair.wishlist = c;
    [_tempPairArray addObject:pair];
    
    
    CGRect viewT = viewTop.frame;
    CGRect viewB = viewBottom.frame;
    CGRect viewM = mainView.frame;
    
    //    viewM = CGRectMake(0, 0, viewT.size.width, viewT.size.height + viewB.size.height);
    //    viewT = CGRectMake(viewT.origin.x, viewT.origin.y, viewT.size.width, viewT.size.height);
    //    viewB = CGRectMake(viewB.origin.x, viewB.origin.y + viewT.size.height, viewB.size.width, viewB.size.height);
    
    viewM = CGRectMake(self.view.frame.size.width * .01f, self.view.frame.size.width * .01f, self.view.frame.size.width * .98f, viewT.size.height + viewB.size.height);
    viewT = CGRectMake(-1, 0, viewM.size.width + 2, viewT.size.height);
    viewB = CGRectMake(-1, viewB.origin.y + viewT.size.height, viewM.size.width + 2, viewB.size.height);
    viewTop.frame = viewT;
    viewBottom.frame = viewB;
    mainView.frame = viewM;
    
    
    UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, viewTop.frame.size.width, viewTop.frame.size.height)];
    [button addTarget:self action:@selector(myEvent:) forControlEvents:UIControlEventTouchUpInside];
    pair.buttonImage = button;
    [viewTop addSubview:button];
    [button setTag:pInfo._id];
    
    ///////////
    NSMutableString *properties = [NSMutableString string];
    int i = 0;
    if (variation) {
        for (VariationAttribute* attribute in variation._attributes) {
            if (i > 0) {
                NSString* str = [NSString stringWithFormat:@", "];
                [properties appendString:str];
            }
            NSString* str = [NSString stringWithFormat:@"%@ - %@",
                             [Utility getStringIfFormatted:attribute.name],
                             [Utility getStringIfFormatted:attribute.value]
                             //                             [attribute.name capitalizedString],
                             //                             [attribute.value capitalizedString]
                             ];
            //            NSString* str = [NSString stringWithFormat:@"%@ - %@", [attribute.name capitalizedString], [attribute.value  capitalizedString]];
            [properties appendString:str];
            i++;
        }
    }
    
    //    for (BasicAttribute* basicAttribute in c.selected_attributes) {
    //        if (i > 0) {
    //            NSString* str = [NSString stringWithFormat:@",\n"];
    //            [properties appendString:str];
    //        }
    //        NSString* str = [NSString stringWithFormat:@"%@ - %@", [basicAttribute.attributeName capitalizedString], [basicAttribute.attributeValue capitalizedString]];
    //        [properties appendString:str];
    //        i++;
    //    }
    if ([properties isEqualToString:@""]){
//        [properties appendString:Localize(@"not_available")];
    }
    UILabel* labelProp = [[UILabel alloc] init];
    labelProp.font = labelDesc.font;
    labelProp.textColor = labelPrice.textColor;
    [labelProp setFrame:labelDesc.frame];
    CGRect rectProp = labelProp.frame;
    float gap = (labelPrice.frame.origin.y - labelDesc.frame.origin.y+labelDesc.frame.size.height);
    rectProp.origin.y += (gap - rectProp.size.height)/2;
    [labelProp setFrame:rectProp];
    [labelProp setText:properties];
    [labelProp sizeToFitUI];
    [labelProp setNumberOfLines:0];
    [labelDesc.superview addSubview:labelProp];
    
    
    
    
    
    CGRect topViewRect = viewTop.frame;
    
    CGRect bottomViewRect = viewBottom.frame;
    bottomViewRect.origin.y = CGRectGetMaxY(topViewRect) - 1;
    viewBottom.frame = bottomViewRect;
    
    CGRect mainViewRect = mainView.frame;
    mainViewRect.size.height = CGRectGetMaxY(bottomViewRect);
    mainView.frame = mainViewRect;
    
    [Utility showShadow:mainView];
    
    
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        [labelName setTextAlignment:NSTextAlignmentRight];
        [labelDesc setTextAlignment:NSTextAlignmentRight];
        [labelProp setTextAlignment:NSTextAlignmentRight];
    }
    
    
    if (labelPriceOld.hidden == true) {
        labelPrice.frame = CGRectMake(labelPrice.frame.origin.x, labelPriceNew.frame.origin.y, labelPrice.frame.size.width, labelPrice.frame.size.height);
    }
    Addons* addons = [Addons sharedManager];
    if (addons.enable_cart == false){
        buttonRight.frame = CGRectMake(buttonRight.frame.origin.x, buttonRight.frame.origin.y, buttonRight.frame.size.width, 0);
        buttonRight.hidden = true;
        [buttonLeft setFrame:CGRectMake(0, 0 , (viewBottom.frame.size.width), viewBottom.frame.size.height)];
    }
    
    
    if (([[GuestConfig sharedInstance] hide_price] && ![AppUser isSignedIn]) || [[Addons sharedManager] hide_price]) {
        [labelPriceOld setText:@""];
        [labelPriceNew setText:@""];
        [labelPriceFinal setText:@""];
        [labelPrice setText:@""];
        [labelPriceOld sizeToFitUI];
        [labelPriceNew sizeToFitUI];
        [labelPriceFinal sizeToFitUI];
        [labelPrice sizeToFitUI];
    } else {
        [labelPriceOld sizeToFitUI];
        [labelPriceNew sizeToFitUI];
        [labelPriceFinal sizeToFitUI];
        [labelPrice sizeToFitUI];
    }
    
    return mainView;
}
- (void)myEvent:(UIButton*)button {
    int variationId = -1;
    for (PairWishlist* p in _tempPairArray) {
        if(button == p.buttonImage){
            variationId = p.wishlist.selectedVariationId;
            break;
        }
    }
    int productId = (int)button.tag;
    [self clickOnProduct:[ProductInfo getProductWithId:productId] currentItemData:nil variationId:variationId];
}
- (UIView*)addFinalAmountView {
    UIView* viewDummy1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    [_scrollView addSubview:viewDummy1];
    [_viewsAdded addObject:viewDummy1];
    [viewDummy1 setTag:kTagForGlobalSpacing];
    
    float viewMaxHeight = self.view.frame.size.height * 40.0f / 100.0f;
    float viewMaxWidth = self.view.frame.size.width * .98f;
    float viewOriginX = self.view.frame.size.width * .01f;
    float viewOriginY = self.view.frame.size.width * .01f;
    
    _labelTotalItems = [[UILabel alloc] init];
    _labelGrandTotal = [[UILabel alloc] init];
    
    UIView* view = [[UIView alloc] init];
    [view setFrame:CGRectMake(viewOriginX, viewOriginY, viewMaxWidth, viewMaxHeight * .25f)];
    [view.layer setBorderColor:[[Utility getUIColor:kUIColorBorder] CGColor]];
    [view.layer setBorderWidth:1];
    [view setBackgroundColor:[UIColor whiteColor]];
    [_scrollView addSubview:view];
    [_viewsAdded addObject:view];
    [view setTag:kTagForGlobalSpacing];
    
    UILabel* labelTotalItemsHeading = [[UILabel alloc] init];
    UILabel* labelTotalItems = _labelTotalItems;
    UILabel* labelGrandTotalHeading = [[UILabel alloc] init];
    UILabel* labelGrandTotal = _labelGrandTotal;
    
    [view addSubview:labelTotalItemsHeading];
    [view addSubview:labelTotalItems];
    [view addSubview:labelGrandTotalHeading];
    [view addSubview:labelGrandTotal];
    
    [labelTotalItemsHeading setText:Localize(@"i_total_items")];
    [labelGrandTotalHeading setText:Localize(@"i_grand_total")];
    
    int itemsCount = [Wishlist getItemCount];
    float totalPrice = [Wishlist getTotalPayment];
    
    NSString* stringItemsCount = [NSString stringWithFormat:@"%d", itemsCount];
    NSString* stringGrandTotal = [[Utility sharedManager] convertToString:totalPrice isCurrency:true];
    
    [labelTotalItems setText:stringItemsCount];
    [labelGrandTotal setText:stringGrandTotal];
    
    [labelTotalItemsHeading setTextAlignment:NSTextAlignmentLeft];
    [labelGrandTotalHeading setTextAlignment:NSTextAlignmentLeft];
    [labelTotalItems setTextAlignment:NSTextAlignmentRight];
    [labelGrandTotal setTextAlignment:NSTextAlignmentRight];
    
    [labelTotalItemsHeading setUIFont:kUIFontType18 isBold:false];
    [labelTotalItems setUIFont:kUIFontType18 isBold:false];
    [labelGrandTotalHeading setUIFont:kUIFontType20 isBold:false];
    [labelGrandTotal setUIFont:kUIFontType20 isBold:false];
    
    labelTotalItemsHeading.textColor = [Utility getUIColor:kUIColorFontLight];
    labelTotalItems.textColor = [Utility getUIColor:kUIColorFontLight];
    labelGrandTotalHeading.textColor = [Utility getUIColor:kUIColorFontDark];
    labelGrandTotal.textColor = [Utility getUIColor:kUIColorFontDark];
    
    float horizontalPadding = view.frame.size.width * .15f;
    float width = view.frame.size.width - horizontalPadding * 2;
    float label1Posy = view.frame.size.height * .33f;
    float label2Posy = view.frame.size.height * .66f;
    
    [labelTotalItemsHeading sizeToFitUI];
    [labelGrandTotalHeading sizeToFitUI];
    [labelTotalItems sizeToFitUI];
    [labelGrandTotal sizeToFitUI];
    
    
    [labelTotalItemsHeading setFrame:CGRectMake(horizontalPadding, label1Posy - labelTotalItemsHeading.frame.size.height / 2, width, labelTotalItemsHeading.frame.size.height)];
    [labelGrandTotalHeading setFrame:CGRectMake(horizontalPadding, label2Posy - labelGrandTotalHeading.frame.size.height / 2, width, labelGrandTotalHeading.frame.size.height)];
    [labelTotalItems setFrame:CGRectMake(horizontalPadding, label1Posy - labelTotalItems.frame.size.height / 2, width, labelTotalItems.frame.size.height)];
    [labelGrandTotal setFrame:CGRectMake(horizontalPadding, label2Posy - labelGrandTotal.frame.size.height / 2, width, labelGrandTotal.frame.size.height)];
    
    return view;
}
- (UIButton*)addPlaceOrderButton {
    UIView* viewDummy1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    [_scrollView addSubview:viewDummy1];
    [_viewsAdded addObject:viewDummy1];
    [viewDummy1 setTag:kTagForGlobalSpacing];
    
    float buttonPosY = self.view.frame.size.width * .01f;
    float buttonWidth = self.view.frame.size.width * .6f;
    float buttonHeight = [[MyDevice sharedManager] screenHeightInPortrait] * .075f;
    float buttonPosX = (self.view.frame.size.width - buttonWidth) / 2;
    
    UIButton *buttonBuy = [[UIButton alloc] initWithFrame:CGRectMake(buttonPosX, buttonPosY, buttonWidth, buttonHeight)];
    [buttonBuy setBackgroundColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
    [[buttonBuy titleLabel] setUIFont:kUIFontType22 isBold:false];
    [buttonBuy setTitle:Localize(@"place_order") forState:UIControlStateNormal];
    [buttonBuy setTitleColor:[Utility getUIColor:kUIColorBuyButtonFont] forState:UIControlStateNormal];
    [buttonBuy addTarget:self action:@selector(placeOrder:) forControlEvents:UIControlEventTouchUpInside];
    
    [_scrollView addSubview:buttonBuy];
    [_viewsAdded addObject:buttonBuy];
    [buttonBuy setTag:kTagForGlobalSpacing];
    return buttonBuy;
}

- (void)moveToWishlist:(UIButton*)button
{
}
- (void)addToCart:(UIButton*)button
{
    RLOG(@"Button addToCart");
    
    
    for (PairWishlist* p in _tempPairArray) {
        if(button == p.buttonRight){
            p.wishlist.count = 1;
            int availState = [Cart getProductAvailibleState:p.wishlist.product variationId:p.wishlist.selectedVariationId];
            switch (availState) {
                case PRODUCT_QTY_DEMAND:
                    break;
                case PRODUCT_QTY_ZERO:
                {
                    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:p.wishlist.product._titleForOuterView message:Localize(@"out_of_stock" )delegate:self cancelButtonTitle:Localize(@"i_ok") otherButtonTitles:nil, nil];
                    [errorAlert setTag:25];
                    [errorAlert show];
                    return;
                }break;
                case PRODUCT_QTY_STOCK:
                    break;
                default:
                    break;
            }
            
        }
    }
    
    
    if ([button isSelected]) {
        [button setSelected:false];
        //        button.layer.borderColor = [Utility getUIColor:kUIColorThemeButtonBorderNormal].CGColor;
    }else{
        [button setSelected:true];
        //        button.layer.borderColor = [UIColor greenColor].CGColor;
    }
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        RLOG(@"Animation needed.1");
        CGRect rect = button.superview.superview.frame;
        rect.origin.x = self.view.frame.size.width * 2;
        [button.superview.superview setFrame:rect];
        RLOG(@"Animation needed.2");
    } completion:^(BOOL finished){
        RLOG(@"Animation completed.1");
        [button.superview.superview removeFromSuperview];
        [_viewsAdded removeObject:button.superview.superview];
        [self resetMainScrollView:0.25f];
        RLOG(@"Animation completed.2");
    }];
    for (PairWishlist* p in _tempPairArray) {
        if(button == p.buttonRight || button == p.buttonLeft){
            ProductInfo* pInfo = p.wishlist.product;
            if ([[Addons sharedManager] remove_cart_or_wish_items]) {
                [Wishlist removeProduct:pInfo productId:p.wishlist.product_id variationId:p.wishlist.selectedVariationId];
            }
            [self clickOnProduct:pInfo currentItemData:nil variationId:-1];
            [self updateViews];
            [_tempPairArray removeObject:p];
            
            break;
        }
    }
    
}
- (void)removeFromList:(UIButton*)button
{
    RLOG(@"Button removeFromList");
    if ([button isSelected]) {
        [button setSelected:false];
    }else{
        [button setSelected:true];
    }
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        RLOG(@"Animation needed.");
        CGRect rect = button.superview.superview.frame;
        rect.origin.x = self.view.frame.size.width * 2;
        [button.superview.superview setFrame:rect];
    } completion:^(BOOL finished){
        RLOG(@"Animation completed.");
        [button.superview.superview removeFromSuperview];
        [_viewsAdded removeObject:button.superview.superview];
        [self resetMainScrollView:0.25f];
    }];
    for (PairWishlist* p in _tempPairArray) {
        if(button == p.buttonRight || button == p.buttonLeft){
            ProductInfo* pInfo = p.wishlist.product;
            [Wishlist removeProduct:pInfo productId:p.wishlist.product_id variationId:p.wishlist.selectedVariationId];
            [self updateViews];
            [_tempPairArray removeObject:p];
            break;
        }
    }
}
- (void)placeOrder:(UIButton*)button
{
    
}
#pragma mark - Adjust Orientation
- (void)beforeRotation {
    
    [UIView animateWithDuration:0.1f animations:^{
        [_footerView setAlpha:0.0f];
    }completion:^(BOOL finished){
    }];
    
    
    UIView* lastView = [_viewsAdded lastObject];
    for(UIView *view in _viewsAdded)
    {
        [UIView animateWithDuration:0.1f animations:^{
            [view setAlpha:0.0f];
        }completion:^(BOOL finished){
            [view removeFromSuperview];
            if (view == lastView) {
                [_scrollView setAlpha:0.0f];
                [_viewsAdded removeAllObjects];
                [self loadViewDA];
                for(UIView *vieww in _viewsAdded)
                {
                    [vieww setAlpha:0.0f];
                }
                [_scrollView setAlpha:1.0f];
            }
        }];
    }
}
- (void)afterRotation {
    for(UIView *vieww in _viewsAdded)
    {
        [UIView animateWithDuration:0.1f animations:^{
            [vieww setAlpha:1.0f];
        }completion:^(BOOL finished){
            
        }];
    }
    
    [UIView animateWithDuration:0.1f animations:^{
        [_footerView setAlpha:1.0f];
    }completion:^(BOOL finished){
    }];
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
    [self resetMainScrollView: 0.25f];
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if ([[AppDelegate getInstance] isAppEnteredInBackground]) {
        return;
    }
    [self adjustViewsForOrientation:[[UIDevice currentDevice] orientation]];
    [self resetMainScrollView: 0.25f];
}
#pragma mark - Reset Views
- (void)resetMainScrollView:(float) animInterval{
    __block float globalPosY = 0.0f;
    __block UIView* tempView = nil;
    __block int i = 0;
    __block int lastItemIndex = (int)[_viewsAdded count] - 1;
    for (tempView in _viewsAdded) {
        [UIView animateWithDuration:animInterval delay:0.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            CGRect rect = [tempView frame];
            if (i == 0) {
                globalPosY = 10;
            }
            rect.origin.y = globalPosY;
            [tempView setFrame:rect];
            globalPosY += rect.size.height;
            if ([tempView tag] == kTagForGlobalSpacing) {
                globalPosY += 10;//[LayoutProperties globalVerticalMargin];
            }
            if (lastItemIndex == i){
                [_scrollView setContentSize:CGSizeMake(_scrollView.contentSize.width, globalPosY)];
                [self resetScrollViewFrame];
            }
            i++;
        }completion:^(BOOL finished){
            [self resetScrollViewFrame];
        }];
    }
}
- (void)updateViews {
    int itemsCount = [Wishlist getItemCount];
    float totalPrice = [Wishlist getTotalPayment];
    if(itemsCount == 0){
        _finalAmountView.hidden = true;
        _placeOrderButton.hidden = true;
        
        _scrollView.hidden = true;
        _labelNoItems.hidden = false;
        _labelNoItems.text = Localize(@"no_items_in_wishlist");
    }else{
        _finalAmountView.hidden = true;
        _placeOrderButton.hidden = true;
        
        _scrollView.hidden = false;
        _labelNoItems.hidden = true;
        
    }
    NSString* stringItemsCount = [NSString stringWithFormat:@"%d", itemsCount];
    NSString* stringGrandTotal = [[Utility sharedManager] convertToString:totalPrice isCurrency:true];
    
    [_labelTotalItems setText:stringItemsCount];
    [_labelGrandTotal setText:stringGrandTotal];
    
}
- (void)clickOnProduct:(ProductInfo*)productClicked currentItemData:(DataPass*)currentItemData variationId:(int) variationId {
    
    ViewControllerMain* mainVC = [ViewControllerMain getInstance];
    mainVC.containerTop.hidden = YES;
    mainVC.containerCenter.hidden = YES;
    mainVC.containerCenterWithTop.hidden = NO;
    mainVC.vcBottomBar.buttonHome.selected = NO;
    mainVC.vcBottomBar.buttonCart.selected = NO;
    mainVC.vcBottomBar.buttonWishlist.selected = YES;
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
    clickedItemData.variationId = variationId;
    
    DataPass* previousItemData = [[DataPass alloc] init];
    previousItemData.itemId = currentItemData.cInfo._id;
    previousItemData.isCategory = currentItemData.isCategory;
    previousItemData.isProduct = currentItemData.isProduct;
    previousItemData.hasChildCategory = currentItemData.hasChildCategory;
    previousItemData.childCount = currentItemData.childCount;
    previousItemData.cInfo = currentItemData.cInfo;
    previousItemData.variationId = currentItemData.variationId;
    
    ViewControllerProduct* vcProduct = [[Utility sharedManager] pushProductScreen:mainVC.vcCenterTop];
    [vcProduct loadData:clickedItemData previousItem:previousItemData drillingLevel:0 variationId:variationId];
}

-(void)addShareWishlistButtonView {
    float buttonHeight = [[MyDevice sharedManager] screenHeightInPortrait] * .075f;
    float viewHeight = buttonHeight * 1.25f;
    _scrollView.frame = CGRectMake(_scrollView.frame.origin.x, _scrollView.frame.origin.y, _scrollView.frame.size.width, [[MyDevice sharedManager] screenSize].height - [[Utility sharedManager] getBottomBarHeight]  - [[Utility sharedManager] getTopBarHeight] - viewHeight);
    float viewWidth = [[MyDevice sharedManager] screenSize].width;
    if (_footerView) {
        [_footerView removeFromSuperview];
    }
    _footerView=[[UIView alloc]init];
    _footerView.frame = CGRectMake(0, _scrollView.frame.size.height, viewWidth, viewHeight);
    _footerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_footerView];
    [self addShareWishlistButton];
    
    [self.view bringSubviewToFront:_scrollView];
}
- (UIButton*)addShareWishlistButton {
    float buttonWidth = [[MyDevice sharedManager] screenSize].width * 0.46f;
    float buttonHeight = [[MyDevice sharedManager] screenHeightInPortrait] * .075f;
    float buttonPosX = self.view.frame.size.width * .02f;
    _shareWishlistButton = [[UIButton alloc] init];
    buttonWidth = [[MyDevice sharedManager] screenWidthInPortrait] * 0.6f;
    _shareWishlistButton.frame = CGRectMake(buttonPosX, 0, buttonWidth, buttonHeight);
    _shareWishlistButton.center = CGPointMake(_footerView.frame.size.width/2, _footerView.frame.size.height/2);
    [_shareWishlistButton setBackgroundColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
    [[_shareWishlistButton titleLabel] setUIFont:kUIFontType22 isBold:false];
    [_shareWishlistButton setTitle:Localize(@"share_wishlist") forState:UIControlStateNormal];
    [_shareWishlistButton setTitleColor:[Utility getUIColor:kUIColorBuyButtonFont] forState:UIControlStateNormal];
    [_shareWishlistButton addTarget:self action:@selector(onShareWishListClick:) forControlEvents:UIControlEventTouchUpInside];
    [_footerView addSubview:_shareWishlistButton];
    return _shareWishlistButton;
}


- (void) syncWishListDetails {
    if([[Addons sharedManager] enable_custom_wishlist]) {
        [self addShareWishlistButtonView];
//        if(_shareWishlistButton == nil) {
//            float x = 8.0f, y = 0.0f;
//            _shareWishlistButton = [[UIButton alloc] init];
//            _shareWishlistButton.frame = CGRectMake(x, y, self.view.frame.size.width - 2*x, self.view.frame.size.width *.1f);
//            [_shareWishlistButton setTag:kTagForGlobalSpacing];
//            [_shareWishlistButton setBackgroundColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
//            [[_shareWishlistButton titleLabel] setUIFont:kUIFontType22 isBold:true];
//            [_shareWishlistButton setTitle:Localize(@"share_wishlist") forState:UIControlStateNormal];
//            [_shareWishlistButton setTitleColor:getColor(kUIColorBuyButtonFont) forState:UIControlStateNormal];
//            [_shareWishlistButton addTarget:self action:@selector(onShareWishListClick:) forControlEvents:UIControlEventTouchUpInside];
//            [self.view addSubview:_shareWishlistButton];
//        }

        if (IsNaN([CWishList getUrl]) && IsNaN([CWishList getToken])) {
            [self syncWishListProducts];
            return;
        }

        __block BOOL hidden = [[[AppUser sharedManager] _wishlistArray] count] <= 0;
        [Utility showProgressView:Localize(@"syncing_wishlist")];
        [[DataManager getDataDoctor] getWishListDetails:[[AppUser sharedManager] _id]
                                                emailId:[[AppUser sharedManager] _email]
                                                success:^(id data) {
                                                    RLOG(@"WishList details fetched successfully.");
                                                    [Utility hideProgressView];
                                                    _footerView.hidden = hidden;
                                                    [self resetScrollViewFrame];
                                                    [self syncWishListProducts];
                                                }
                                                failure:^(NSString *error) {
                                                    RLOG(@"Failed to fetch WishList details.");
                                                    [Utility hideProgressView];
                                                    [self resetScrollViewFrame];
                                                    _footerView.hidden = hidden;
                                                }];
    }
}

-(void) syncWishListProducts {
    if([[Addons sharedManager] enable_custom_wishlist]) {
        __block BOOL hidden = [[[AppUser sharedManager] _wishlistArray] count] < 1;
        [Utility showProgressView:Localize(@"syncing_wishlist")];
        
        [[DataManager getDataDoctor] getWishListProducts:[[AppUser sharedManager] _id]
                                                 emailId:[[AppUser sharedManager] _email]
                                                 success:^(id data) {
                                                     [Utility hideProgressView];
                                                     _footerView.hidden = hidden;
                                                     [self resetScrollViewFrame];
                                                     NSArray* items = [CWishList getAll];
                                                     //if (items != nil && [items count] > 0) {
                                                     //}
                                                     for(CWishList* item in items) {
                                                         ProductInfo* pInfo = [ProductInfo getProductWithId:item.productId];
                                                         [Wishlist addProductWithoutSync:pInfo];
                                                     }
                                                     [self loadViewDA];
                                                     // reload wish list data source
                                                 }
                                                 failure:^(NSString *error) {
                                                     RLOG(@"Failed to get WishList products.");
                                                     [Utility hideProgressView];
                                                     _footerView.hidden = hidden;
                                                     [self resetScrollViewFrame];
                                                 }];
        
    }
}

-(void) onShareWishListClick:(UIButton*) button {
    NSArray * shareItems = @[[CWishList getSharableUrl]];
    [self presentViewController:[[UIActivityViewController alloc] initWithActivityItems:shareItems applicationActivities:nil]
                       animated:YES
                     completion:nil];
}
- (void)resetScrollViewFrame {
    if([[Addons sharedManager] enable_custom_wishlist]) {
        if (_footerView) {
            if (_footerView.hidden == true) {
                _scrollView.frame = CGRectMake(_scrollView.frame.origin.x, _scrollView.frame.origin.y, _scrollView.frame.size.width, [[MyDevice sharedManager] screenSize].height);
            } else {
                float buttonHeight = [[MyDevice sharedManager] screenHeightInPortrait] * .075f;
                float viewHeight = buttonHeight * 1.25f;
                _scrollView.frame = CGRectMake(_scrollView.frame.origin.x, _scrollView.frame.origin.y, _scrollView.frame.size.width, [[MyDevice sharedManager] screenSize].height - [[Utility sharedManager] getBottomBarHeight]  - [[Utility sharedManager] getTopBarHeight] - viewHeight);
            }
        }
        
    }
}
@end
