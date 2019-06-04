//
//  ViewControllerOpinion.m
//
//  Created by Rishabh Jain on 24/09/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import "ViewControllerOpinion.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Utility.h"
#import "MyDevice.h"
#import "AppUser.h"
#import "Cart.h"
#import "Wishlist.h"
#import "Opinion.h"
#import "AnalyticsHelper.h"
static int kTagForGlobalSpacing = 0;
static int kTagForNoSpacing = -1;

@implementation PairOpinion
@end

@interface ViewControllerOpinion () {
    NSMutableArray *_viewsAdded;
    NSMutableArray *_horizontalScrollViews;
    NSMutableArray *_tempPairArray;
}
@end

@implementation ViewControllerOpinion

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
    [[AnalyticsHelper sharedInstance] registerVisitScreenEvent:@"Opinion Screen"];
#endif
}
- (void)viewWillAppear:(BOOL)animated {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super viewWillAppear:animated];
    //rv//[SDWebImageManager.sharedManager.imageDownloader setValue:@"SDWebImage Demo" forHTTPHeaderField:@"AppName"];
//    SDWebImageManager.sharedManager.imageDownloader.executionOrder = SDWebImageDownloaderFIFOExecutionOrder;
    [self loadViewDA];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchAllOpinionSuccess:) name:@"FETCH_ALL_OPINION" object:nil];
    [[ParseHelper sharedManager] fetchAllOpinionPoll];
}
- (void)fetchAllOpinionSuccess:(NSNotification*)notification{
    int count = (int)[_tempPairArray count];
    int itemsCount = (int)[[[AppUser sharedManager] _opinionArray] count];
    if (count != itemsCount) {
        [self loadViewDA];
    }else{
        for (PairOpinion* pairOp in _tempPairArray) {
            [self updateOpinionView: pairOp];
        }
    }

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FETCH_ALL_OPINION" object:nil];
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
    int itemsCount = (int)[[[AppUser sharedManager] _opinionArray] count];
    if (itemsCount > 0) {
        _scrollView.hidden = false;
        _labelNoItems.hidden = true;
        for (int i = 0; i < itemsCount; i++) {
            Opinion* c = (Opinion*)[[[AppUser sharedManager] _opinionArray] objectAtIndex:i];
            ProductInfo* product = [ProductInfo getProductWithId:c.product_id];
            if (product) {
                [self addView:i pInfo:product isCartItem:false isWishlistItem:true quantity:1];
            }
        }
    }else{
        _scrollView.hidden = true;
        _labelNoItems.hidden = false;
        _labelNoItems.text = Localize(@"i_opinion_empty");
        [_labelNoItems setUIFont:kUIFontType20 isBold:false];
        _labelNoItems.textColor = [Utility getUIColor:kUIColorFontLight];
        _finalAmountView = nil;
        _placeOrderButton = nil;
    }
    [self resetMainScrollView:0.0f];
    [self updateViews];
}
- (void)addToCart:(UIButton*)button
{
    if ([button isSelected]) {
        [button setSelected:false];
    }else{
        [button setSelected:true];
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
    for (PairOpinion* p in _tempPairArray) {
        if(button == p.buttonCart){
            ProductInfo* pInfo = p.product;
            [self clickOnProduct:[ProductInfo getProductWithId:pInfo._id] currentItemData:nil variationId:-1];
            break;
        }
    }
}
- (void)updateOpinionView:(PairOpinion*)pair {
    int likeCount       = pair.product.pollLikeCount;
    int dislikeCount    = pair.product.pollDislikeCount;
    float _buttonHeight = [[MyDevice sharedManager] screenWidthInPortrait] * 0.1f;
    {
        float viewMaxHeight = 250;
        float viewMaxWidth = self.view.frame.size.width * .98f;
        float imgRectH = MIN(viewMaxHeight * .75f * .80f, viewMaxWidth * .25f);
        viewMaxHeight = imgRectH * 1.67f;
        _buttonHeight = viewMaxHeight * .25f;
    }

    float buttonHeight = _buttonHeight;
    float edgeSize = buttonHeight * .20f;
    
    
    [pair.buttonDislike setTitle:[NSString stringWithFormat:@"%d", dislikeCount] forState:UIControlStateNormal];
    if (1/* [[MyDevice sharedManager] isIphone] && likeCount > 99999*/) {
        
        int digitCount = (int) log10(dislikeCount) + 1;
        RLOG(@"digitCount = %d", digitCount);
        if (digitCount > 5) {
            int moreDigit = digitCount - 5;
            CGSize titleSize = LABEL_SIZE(pair.buttonDislike.titleLabel);
            int widthLetter = titleSize.width/digitCount;
            float diff = widthLetter * moreDigit/2;
            [pair.buttonDislike setImageEdgeInsets:UIEdgeInsetsMake(edgeSize, edgeSize/4, edgeSize,  - diff)];
            [pair.buttonDislike setTitleEdgeInsets:UIEdgeInsetsMake(edgeSize, -diff, edgeSize, edgeSize/4)];
        }
    }
    
    
    [pair.buttonLike setTitle:[NSString stringWithFormat:@"%d", likeCount] forState:UIControlStateNormal];
    if (1/* [[MyDevice sharedManager] isIphone] && likeCount > 99999*/) {
        int digitCount = (int) log10(likeCount) + 1;
        RLOG(@"digitCount = %d", digitCount);
        if (digitCount > 5) {
            int moreDigit = digitCount - 5;
            CGSize titleSize = LABEL_SIZE(pair.buttonLike.titleLabel);
            int widthLetter = titleSize.width/digitCount;
            float diff = widthLetter * moreDigit/2;
            [pair.buttonLike setImageEdgeInsets:UIEdgeInsetsMake(edgeSize, edgeSize/4, edgeSize,  - diff)];
            [pair.buttonLike setTitleEdgeInsets:UIEdgeInsetsMake(edgeSize, -diff, edgeSize, edgeSize/4)];
        }
    }
}
- (UIView*)createOpinionView:(PairOpinion*)pair {
    float _heightRectBottomView, _buttonWishlistWidth,_buttonCartWidth ,_buttonHeight, _viewWidth, _buttonBuyWidth;
    _viewWidth = self.view.frame.size.width * (1.0f - 0.02f);
    
    float width = _viewWidth;
//    if ([[MyDevice sharedManager] isIpad]) {
        _buttonBuyWidth = width * 0.50f+1;
        _buttonWishlistWidth = width * 0.25f;
        _buttonCartWidth = width * 0.25f;
        {
            float viewMaxHeight = 250;
            float viewMaxWidth = self.view.frame.size.width * .98f;
            float imgRectH = MIN(viewMaxHeight * .75f * .80f, viewMaxWidth * .25f);
            viewMaxHeight = imgRectH * 1.67f;
            _buttonHeight = viewMaxHeight * .25f;
        }
        _heightRectBottomView = _buttonHeight;
//    } else {
//        _buttonBuyWidth = width * 0.50f;
//        _buttonWishlistWidth = width * 0.25f;
//        _buttonCartWidth = width * 0.25f;
//        {
//            float viewMaxHeight = 250;
//            float viewMaxWidth = self.view.frame.size.width * .98f;
//            float imgRectH = MIN(viewMaxHeight * .75f * .80f, viewMaxWidth * .25f);
//            viewMaxHeight = imgRectH * 1.67f;
//            _buttonHeight = viewMaxHeight * .25f;
//        }
//        _heightRectBottomView = _buttonHeight;
//    }
    CGRect rectBottomView = CGRectMake(self.view.frame.size.width * .01f, self.view.frame.size.width * .01f, _viewWidth, _heightRectBottomView);
    UIView* viewBottom = [[UIView alloc] initWithFrame:rectBottomView];
    viewBottom.backgroundColor = [UIColor whiteColor];
    //elements in bottomView
    {
        float buttonBuyWidth = _buttonBuyWidth;
        float buttonWishlistWidth = _buttonWishlistWidth;
        float buttonCartWidth = _buttonCartWidth;
        float buttonWishlistPosX = 0;
        float buttonCartPosX = buttonWishlistPosX + buttonWishlistWidth + 1;
        float buttonBuyPosX = buttonCartPosX + buttonCartWidth;
        float buttonHeight = _buttonHeight;
        float buttonPosY = 0;
        float edgeSize = buttonHeight * .20f;
        
        UIButton * _buttonOpinion = [[UIButton alloc] initWithFrame:CGRectMake(buttonBuyPosX, buttonPosY, buttonBuyWidth, buttonHeight)];
        [[_buttonOpinion titleLabel] setUIFont:kUIFontType20 isBold:false];
        [_buttonOpinion setTitle:Localize(@"menu_title_opinion") forState:UIControlStateNormal];
        [_buttonOpinion setTitleColor:[Utility getUIColor:kUIColorBuyButtonFont] forState:UIControlStateNormal];
        [viewBottom addSubview:_buttonOpinion];
        [_buttonOpinion addTarget:self action:@selector(addToCart:) forControlEvents:UIControlEventTouchUpInside];
        _buttonOpinion.layer.borderColor = [Utility getUIColor:kUIColorBorder].CGColor;
        _buttonOpinion.layer.borderWidth = 1;
        UIImage* whatsappLogo = [UIImage imageNamed:@"whatsappLogo"];
        [_buttonOpinion setUIImage:whatsappLogo forState:UIControlStateNormal];
        [_buttonOpinion.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_buttonOpinion setImageEdgeInsets:UIEdgeInsetsMake(edgeSize, 0, edgeSize, 0)];
//        [_buttonOpinion setTitleEdgeInsets:UIEdgeInsetsMake(edgeSize, edgeSize, edgeSize, 0)];
        
        
        
        UIView* viewForLikeAndDislike = [[UIView alloc] initWithFrame:CGRectMake(buttonWishlistPosX, buttonPosY, buttonWishlistWidth+ buttonCartWidth+2, buttonHeight)];
        viewForLikeAndDislike.backgroundColor = [UIColor whiteColor];
        [viewBottom addSubview:viewForLikeAndDislike];
        [viewForLikeAndDislike.layer setBorderColor:[[Utility getUIColor:kUIColorBorder] CGColor]];
        [viewForLikeAndDislike.layer setBorderWidth:1];
        
        
        
        UIButton* _buttonLike = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonWishlistWidth, buttonHeight)];
        [viewForLikeAndDislike addSubview:_buttonLike];
        //        _buttonLike = [[UIButton alloc] initWithFrame:CGRectMake(buttonWishlistPosX, buttonPosY, buttonWishlistWidth, buttonHeight)];
        //        [viewBottom addSubview:_buttonLike];
        UIImage* imgLike = [UIImage imageNamed:@"icon_like"];
        UIImage* disableWL = [imgLike imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_buttonLike setUIImage:disableWL forState:UIControlStateNormal];
        [_buttonLike setImageEdgeInsets:UIEdgeInsetsMake(edgeSize, 0, edgeSize, edgeSize/4)];
        [_buttonLike setTitleEdgeInsets:UIEdgeInsetsMake(edgeSize, edgeSize/4, edgeSize, 0)];
        [_buttonLike.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [[_buttonLike titleLabel] setUIFont:kUIFontType16 isBold:false];
        [_buttonLike setEnabled:false];
        
        
        UIButton* _buttonDislike = [[UIButton alloc] initWithFrame:CGRectMake(buttonWishlistWidth, 0, buttonCartWidth, buttonHeight)];
        [viewForLikeAndDislike addSubview:_buttonDislike];
        UIImage* imgDislike = [UIImage imageNamed:@"icon_dislike"];
        UIImage* disableC = [imgDislike imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_buttonDislike setUIImage:disableC forState:UIControlStateNormal];
        [_buttonDislike setImageEdgeInsets:UIEdgeInsetsMake(edgeSize, 0, edgeSize, edgeSize/4)];
        [_buttonDislike setTitleEdgeInsets:UIEdgeInsetsMake(edgeSize, edgeSize/4, edgeSize, 0)];
        [_buttonDislike.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [[_buttonDislike titleLabel] setUIFont:kUIFontType16 isBold:false];
        [_buttonDislike setEnabled:false];
        
        
        [_buttonDislike setTintColor:[Utility getUIColor:kUIColorWishlistSelected]];
        [_buttonLike setTintColor:[Utility getUIColor:kUIColorCartSelected]];
        [_buttonLike setTitleColor:[Utility getUIColor:kUIColorFontLight] forState:UIControlStateNormal];
        [_buttonDislike setTitleColor:[Utility getUIColor:kUIColorFontLight] forState:UIControlStateNormal];
        
        _buttonDislike.layer.borderColor = [Utility getUIColor:kUIColorThemeButtonBorderDisable].CGColor;
        _buttonLike.layer.borderColor = [Utility getUIColor:kUIColorThemeButtonBorderDisable].CGColor;
        
        
        
        
       
        [_buttonOpinion setUIImage:[[UIImage imageNamed:@"cart_icon_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [_buttonOpinion setTitle:Localize(@"title_mycart") forState:UIControlStateNormal];
        [_buttonOpinion setTitleColor:[Utility getUIColor:kUIColorThemeFont] forState:UIControlStateNormal];
        [_buttonOpinion setTintColor:[Utility getUIColor:kUIColorThemeButtonSelected]];
        [_buttonOpinion setTag:0];
        
        
        
        
        
        pair.buttonLike = _buttonLike;
        pair.buttonDislike = _buttonDislike;
        pair.buttonCart = _buttonOpinion;
        [self updateOpinionView:pair];
    }
    
    
//    [Utility showShadow:viewBottom];
    return viewBottom;
}
- (UIView*)addView:(int)listId pInfo:(ProductInfo*)pInfo isCartItem:(BOOL)isCartItem isWishlistItem:(BOOL)isWishlistItem quantity:(int)quantity {
    
    Opinion* c = (Opinion*)[[[AppUser sharedManager] _opinionArray] objectAtIndex:listId];
    
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

    [mainView addSubview:viewTop];
   
    
    
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
    if ([pInfo._images count] == 0) {
        [pInfo._images addObject:[[ProductImage alloc] init]];
    }
    [Utility setImage:imgProduct url:((ProductImage*)[pInfo._images objectAtIndex:0])._src resizeType:kRESIZE_TYPE_PRODUCT_THUMBNAIL isLocal:false];
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
    
    
    [labelName setUIFont:kUIFontType18 isBold:false];
    [labelDesc setUIFont:kUIFontType14 isBold:false];
    [labelPrice setUIFont:kUIFontType16 isBold:false];
    [labelPriceOld setUIFont:kUIFontType14 isBold:false];
    [labelPriceNew setUIFont:kUIFontType16 isBold:false];
    [labelPriceFinal setUIFont:kUIFontType16 isBold:false];
    
    labelName.frame = nameRect;
    labelDesc.frame = descRect;
    labelPrice.frame = priceRect;
    
    [labelName setText:pInfo._titleForOuterView];
    [labelDesc setText:Localize(@"title_product_info")];
    [labelDesc setAttributedText:[[NSAttributedString alloc] initWithString:Localize(@"title_product_info")]];

    NSString * htmlString = pInfo._short_description;
    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    [labelDesc setAttributedText:attrStr];
    
    NSString* priceStr;
    BOOL isDiscounted;
    float price;
    float oldPrice;
    
    
    isDiscounted = [pInfo isProductDiscounted:-1];
    price = [pInfo getNewPrice:-1];
    oldPrice = [pInfo getOldPrice:-1];
    
    priceStr = [[Utility sharedManager] convertToString:price isCurrency:true];
    [labelPriceOld setAttributedText:[[Utility sharedManager] convertToStringStrikethrough:oldPrice isCurrency:true]];
    
    NSString* newPrice;
    if (quantity > 1) {
        newPrice = [NSString stringWithFormat:@"%@ X %d", priceStr, quantity] ;
    } else {
        newPrice = [NSString stringWithFormat:@"%@", priceStr];
    }
    [labelPriceNew setText:newPrice];
    [labelPrice setText:Localize(@"i_price")];
    [labelPriceFinal setText:[[Utility sharedManager] convertToString:(price * quantity) isCurrency:true]];
    
    
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
    [labelDesc sizeToFitUI];
    [labelPrice sizeToFitUI];
    float bottomPointDesc = labelDesc.frame.origin.y + labelDesc.frame.size.height;
    float startPointPriceOld = viewTopHeight * .6f;
    float startPointPriceNew = bottomPointDesc;
    
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
    
   
    
    PairOpinion* pair = [[PairOpinion alloc] init];
    pair.product = [ProductInfo getProductWithId:c.product_id];
    UIView* viewBottom = [self createOpinionView:pair];
    [viewBottom.layer setBorderColor:[[Utility getUIColor:kUIColorBorder] CGColor]];
    [viewBottom.layer setBorderWidth:1];
    [viewBottom setBackgroundColor:[UIColor whiteColor]];
    [mainView addSubview:viewBottom];
    
    
    [_tempPairArray addObject:pair];

    
    CGRect viewT = viewTop.frame;
    CGRect viewB = viewBottom.frame;
    CGRect viewM = mainView.frame;
    
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
    if ([properties isEqualToString:@""]){
        [properties appendString:@" "];
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
    return mainView;
    
}
- (void)myEvent:(UIButton*)button {
    int variationId = -1;
//    for (PairOpinion* p in _tempPairArray) {
//        if(button == p.buttonImage){
//            variationId = p.product.selectedVariationId;
//            break;
//        }
//    }
    int productId = (int)button.tag;
    [self clickOnProduct:[ProductInfo getProductWithId:productId] currentItemData:nil variationId:variationId];
}


#pragma mark - Adjust Orientation
- (void)beforeRotation {
    UIView* lastView = [_viewsAdded lastObject];
    for(UIView *view in _viewsAdded)
    {
        [UIView animateWithDuration:0.0f animations:^{
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
        [UIView animateWithDuration:0.0f animations:^{
            [vieww setAlpha:1.0f];
        }completion:^(BOOL finished){
            
        }];
    }
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
    [self resetMainScrollView: 0.0f];
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if ([[AppDelegate getInstance] isAppEnteredInBackground]) {
        return;
    }
    [self adjustViewsForOrientation:[[UIDevice currentDevice] orientation]];
    [self resetMainScrollView: 0.0f];
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
            }
            i++;
        }completion:^(BOOL finished){}];
    }
}
- (void)updateViews {
    int itemsCount = [Opinion getItemCount];
    if(itemsCount == 0){
        _finalAmountView.hidden = true;
        _placeOrderButton.hidden = true;
        
        _scrollView.hidden = true;
        _labelNoItems.hidden = false;
        _labelNoItems.text = Localize(@"i_opinion_empty");
        
    }else{
        _finalAmountView.hidden = true;
        _placeOrderButton.hidden = true;
        
        _scrollView.hidden = false;
        _labelNoItems.hidden = true;
        
    }
    NSString* stringItemsCount = [NSString stringWithFormat:@"%d", itemsCount];
    [_labelTotalItems setText:stringItemsCount];
    
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
@end
