//
//  ViewControllerSellerItems.m
//  TMStore
//
//  Created by Rajshekhar on 19/07/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import "ViewControllerSellerItems.h"
#import "Variables.h"
#import "Utility.h"
#import "AnalyticsHelper.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ProductCollectionViewCell.h"
#import "SellerZoneManager.h"
#import "ProductImage.h"
#import "ProductInfo.h"
#import "ViewControllerUploadProduct.h"
#import "DataManager.h"
#import "AppUser.h"
#import "ProductCollectionViewCellTemp.h"
static int kTagForGlobalSpacing = 0;
static int kTagForNoSpacing = -1;

@interface ViewControllerSellerItems () <UICollectionViewDelegate,UICollectionViewDataSource, UIScrollViewDelegate> {
    NSMutableArray* _viewsAdded;
    UIButton *customBackButton;
    IBOutlet UICollectionView *collectionViewProducts;
}
@end

@implementation ViewControllerSellerItems 

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [_scrollView setBackgroundColor:[UIColor whiteColor]];
    [self.viewbase setBackgroundColor:[UIColor whiteColor]];

    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [Utility getUIColor:kUIColorThemeFont], NSForegroundColorAttributeName, [Utility getUIFont:kUIFontType24 isBold:false], NSFontAttributeName, nil]];
    [self.currentItemHeading setTitle:@"Products"];
    
    _labelViewHeading = [[UILabel alloc] init];
    [_labelViewHeading setFrame:CGRectMake(0, 20, [[MyDevice sharedManager] screenSize].width,  _navigationBar.frame.size.height)];
    [_labelViewHeading setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [_labelViewHeading setUIFont:kUIFontType24 isBold:false];
    [_labelViewHeading setTextColor:[Utility getUIColor:kUIColorThemeFont]];
    [_labelViewHeading setTextAlignment:NSTextAlignmentCenter];
    [_labelViewHeading setText:@"    "];
    [self.view addSubview:_labelViewHeading];
    
    [_navigationBar setClipsToBounds:false];
    [_lineView setBackgroundColor:[Utility getUIColor:kUIColorBorder]];
   // [_scrollView setBackgroundColor:[Utility getUIColor:kUIColorBgTheme]];
    //[self.view setBackgroundColor:[Utility getUIColor:kUIColorBgHeader]];
    [_navigationBar setBarTintColor:[Utility getUIColor:kUIColorBgHeader]];
    customBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [customBackButton setImage:[[UIImage imageNamed:@"img_arrow_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [customBackButton addTarget:self action:@selector(ButtonBackPressed:)forControlEvents:UIControlEventTouchUpInside];
    [customBackButton setTitle:[NSString stringWithFormat:@"  %@  ", Localize(@"i_back")] forState:UIControlStateNormal];
    [customBackButton setTintColor:[Utility getUIColor:kUIColorThemeFont]];
    [customBackButton setTitleColor:[Utility getUIColor:kUIColorThemeFont] forState:UIControlStateNormal];
    [customBackButton.titleLabel setUIFont:kUIFontType18 isBold:false];
    
    [customBackButton sizeToFit];
    [_previousItemHeading setCustomView:customBackButton];
    [_previousItemHeading setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[Utility getUIColor:kUIColorThemeFont], NSForegroundColorAttributeName, [Utility getUIFont:kUIFontType18 isBold:false], NSFontAttributeName, nil] forState:UIControlStateNormal];
    
    //Set Main Cell in Collection View
    [collectionViewProducts registerNib:[UINib nibWithNibName:@"ProductCollectionViewCellTemp" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"ProductCollectionViewCellTemp"];
    
    [_scrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height*1.0)];

//    UICollectionViewFlowLayout *layout= [[UICollectionViewFlowLayout alloc] init];
//    self.propCollectionView = [[LayoutProperties alloc] initWithCollectionViewValues:SCROLL_TYPE_SHOWFULL];
//    self.strCollectionView1 = [[Utility sharedManager] getProductViewString];
//    collectionViewProducts = [[Utility sharedManager] initProductCellCategoryScreen:collectionViewProducts propCollectionView:self.propCollectionView layout:layout nibName:self.strCollectionView1];
//    [collectionViewProducts setScrollEnabled:true];
//    self.propCollectionView._height = self.view.frame.size.height - [[Utility sharedManager] getTopBarHeight];
//    [collectionViewProducts setFrame:[self.propCollectionView getFrameRect]];
    
  
   

}
- (IBAction)ButtonBackPressed:(id)sender {
        [[Utility sharedManager] popScreen:self];
        if ([self.view tag] == PUSH_SCREEN_TYPE_PRODUCT) {
            return;
        }
        ViewControllerMain* mainVC = [ViewControllerMain getInstance];
        [mainVC resetPreviousState];
        [mainVC showBottomBar];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self stopLoadingAnim];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [_scrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height* 1.0)];
   
#if ENABLE_FIREBASE_TAG_MANAGER
    [[AnalyticsHelper sharedInstance] registerVisitScreenEvent:@"Seller Zone"];
#endif
    //get seller products
    [self loadSellerProducts];
    [collectionViewProducts reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)viewWillAppear:(BOOL)animated {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super viewWillAppear:animated];
    [_scrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height* 1.0)];

}
- (void)loadSellerProducts {
    if (self.selectedSellerInfo) {
        [self loadCurrentSellerData];

//        NSString* name = @"";
//        if (self.selectedSellerInfo) {
//            if (self.selectedSellerInfo.shopName && ![self.selectedSellerInfo.shopName isEqualToString:@""]) {
//                name = self.selectedSellerInfo.shopName;
//            } else if (self.selectedSellerInfo.sellerTitle && ![self.selectedSellerInfo.sellerTitle isEqualToString:@""]) {
//                name = self.selectedSellerInfo.sellerTitle;
//            } else {
//                name = @"";
//            }
//        }
//        if (![name isEqualToString:@""]) {
//            [_labelViewHeading setText:name];
//        }
        
        [self startLoadingAnim];
        NSString* sellerId = self.selectedSellerInfo.sellerId;
        int productLimit = 100;
        int offset = self.selectedSellerInfo.productLoadedPageCount * productLimit;
        [[[DataManager sharedManager] tmDataDoctor] getProductsOfSeller:sellerId productLimit:productLimit offset:offset success:^(id data) {
            if (data && [data isKindOfClass:[NSMutableArray class]] && (int)[((NSMutableArray*)data) count] > 0) {
                self.selectedSellerInfo.productLoadedPageCount = self.selectedSellerInfo.productLoadedPageCount + 1;
            }
            NSLog(@"%@", data);
           
            [collectionViewProducts reloadData];
            _pageLoading = false;
            [self stopLoadingAnim];
        } failure:^(NSString *error) {
            NSLog(@"%@", error);
            _pageLoading = false;
            [self stopLoadingAnim];
        }];
    }
}


- (void)loadCurrentSellerData {
    
//    AppUser* appUser = [AppUser sharedManager];
//    if (appUser._id != -1) {
//        _labelTitle.text = [NSString stringWithFormat:@"%@ %@", appUser._first_name, appUser._last_name];
//        if ([[SellerInfo getCurrentSeller] sellerAvatarUrl] && ![[[SellerInfo getCurrentSeller] sellerAvatarUrl] isEqualToString:@""]) {
//            [Utility setImage:_imgProfile url:[[SellerInfo getCurrentSeller] sellerAvatarUrl] resizeType:0 isLocal:false highPriority:true];
//        } else {
//            //            [Utility setImage:imageUser url:appUser._avatar_url resizeType:0 isLocal:false highPriority:true];
//        }
//        _labelShopName.hidden = true;
//        
//        [[[DataManager sharedManager] tmDataDoctor] getSellerInformation:appUser._id success:^(id data) {
//            if (data && [data isKindOfClass:[SellerInfo class]]) {
//                [SellerInfo setCurrentSeller:data];
//                _labelTitle.text = [NSString stringWithFormat:@"%@", [[SellerInfo getCurrentSeller] sellerTitle]];
//                _labelShopName.text = [[SellerInfo getCurrentSeller] shopName];
//                _labelPhoneNo.text = [[SellerInfo getCurrentSeller] sellerPhone];
//                _labelShopAddress.text = [[SellerInfo getCurrentSeller] shopAddress];
//                
//                _labelShopName.hidden = false;
//                if ([[SellerInfo getCurrentSeller] sellerAvatarUrl] && ![[[SellerInfo getCurrentSeller] sellerAvatarUrl] isEqualToString:@""]) {
//                    [Utility setImage:_imgProfile url:[[SellerInfo getCurrentSeller] sellerAvatarUrl] resizeType:0 isLocal:false highPriority:true];
//                } else {
//                    [Utility setImage:_imgProfile url:appUser._avatar_url resizeType:0 isLocal:false highPriority:true];
//                }
//            }
//        } failure:^(NSString *error) {
//            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error!" message:@"Fetching seller data failed. Please retry." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Retry", nil];
//            [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
//                if (buttonIndex == 1) {
//                    [self loadCurrentSellerData];
//                }
//            }];
//        }];
//    } else {
//        [self resetView];
//    }
    
    
  //  NSString* sellerId = self.selectedSellerInfo.sellerId;
    
    _imgProfile.layer.masksToBounds = false;
    _imgProfile.layer.cornerRadius = _imgProfile.frame.size.height/2;
    _imgProfile.clipsToBounds = true;

    _labelTitle.text = [NSString stringWithFormat:@"%@", self.selectedSellerInfo.sellerTitle];
    NSLog(@"SellerTitle %@",self.selectedSellerInfo.sellerTitle);
    
    _labelShopName.text = [NSString stringWithFormat:@"%@", self.selectedSellerInfo.shopName];
    NSLog(@"SellerName %@",self.selectedSellerInfo.shopName);
    
    NSString* strphone = self.selectedSellerInfo.sellerPhone;
    _labelPhoneNo.text = [NSString stringWithFormat:@"%@", self.selectedSellerInfo.sellerPhone];
    NSLog(@"SellerNumber %@",strphone);
    
    _labelShopAddress.text = [NSString stringWithFormat:@"%@", self.selectedSellerInfo.shopAddress];
    NSLog(@"SellerAddress %@",self.selectedSellerInfo.shopAddress);
    
    NSString *strImage = self.selectedSellerInfo.sellerAvatarUrl;
    [Utility setImage:_imgProfile url:strImage resizeType:0 isLocal:false highPriority:true];
    NSLog(@"AvtarURl %@",strImage);

    }

- (void)resetView {
    [collectionViewProducts reloadData];
    [_imgProfile setImage:[Utility getAppIconImage]];
    [_labelTitle setText:@""];
    [_labelShopName setText:@""];
    [_labelPhoneNo setText:@""];
    [_labelShopAddress setText:@""];
}
- (void)resetMainScrollView {
    float globalPosY = 0.0f;
    UIView* tempView = nil;
    int i = 0;
    for (tempView in _viewsAdded) {
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
        i++;
    }
    [_scrollView setContentSize:CGSizeMake(_scrollView.contentSize.width, globalPosY)];
}

- (void)initVariables {
    _viewsAdded = [[NSMutableArray alloc] init];
    [_labelViewHeading setText:Localize(@"title_products")];
}
- (void)loadAllViews {
    
}

#pragma mark - Adjust Orientation
- (void)beforeRotation {
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
                [self loadAllViews];
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
}
- (void)adjustViewsForOrientation:(UIDeviceOrientation) orientation {
    RLOG(@"====adjustViewsForOrientation====");
    //    [self beforeRotation];
}
- (void)adjustViewsAfterOrientation:(UIDeviceOrientation) orientation {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    RLOG(@"====adjustViewsAfterOrientation====");
    //    [self afterRotation];
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
- (void)setDelegate:(id)delegate {
    _delegate = delegate;
}
#pragma mark : Collection View Datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (self.selectedSellerInfo) {
        return [self.selectedSellerInfo.sellerProducts count];
    }
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([[MyDevice sharedManager] isIpad]) {
        return CGSizeMake((self.view.frame.size.width/3) - 30, (self.view.frame.size.height/3) - 45);
    } else {
        return CGSizeMake(((self.view.frame.size.width - 30)/2), (self.view.frame.size.height/2) - 45);
    }
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"ProductCollectionViewCellTemp";
    ProductCollectionViewCellTemp *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    [cell setNeedsLayout];
    cell.parentVC = self;
    ProductInfo *pInfo = (ProductInfo*) [self.selectedSellerInfo.sellerProducts objectAtIndex:indexPath.row];
    cell.productObj = pInfo;
    [[cell labelProductName]setText:pInfo._title];
    [[cell labelProductPriceOld] setAttributedText:[pInfo getPriceOldString]];
    if (pInfo._priceOldString.length == 0 || 1) {
        [cell.labelCrossLine setHidden:YES];
    }
    [[cell labelProductPriceNew] setText:[pInfo getPriceNewString]];
    [[cell labelProductName] setUIFont:kUIFontType16 isBold:false];
    //    [[cell labelProductPriceOld] setUIFont:kUIFontType14 isBold:false];
    [[cell labelProductPriceNew] setUIFont:kUIFontType14 isBold:false];
    
    
    
    if ([pInfo._images count] == 0) {
        [pInfo._images addObject:[[ProductImage alloc] init]];
    }
    ProductImage *pImage = [pInfo._images objectAtIndex:0];
    [cell.imageProduct sd_setImageWithURL:[NSURL URLWithString:pImage._src] placeholderImage:[Utility getPlaceholderImage:0] options:[Utility getImageDownloadOption]];
    if ([cell buttonWishlist].imageView.image.renderingMode != UIImageRenderingModeAlwaysTemplate) {
        UIImage* normal = [[UIImage imageNamed:@"wishlist_icon_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImage* selected = [[UIImage imageNamed:@"wishlist_icon_pressed"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [[cell buttonWishlist] setUIImage:normal forState:UIControlStateNormal];
        [[cell buttonWishlist] setUIImage:selected forState:UIControlStateSelected];
        [[cell buttonWishlist].imageView setContentMode:UIViewContentModeScaleAspectFit];
    }
    [[cell buttonWishlist] addTarget:[Utility sharedManager] action:@selector(wishlistButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cell.buttonWishlist setTag:pInfo._id];
    [[Utility sharedManager] initWishlistButton:cell.buttonWishlist];
    
    [Utility showShadow:cell];
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    id productVC = self.productVC;
    id parentVC = self.parentVC;
//    [self dismissViewControllerAnimated:YES completion:^{
       // [productVC dismissViewControllerAnimated:YES completion:^{
            ProductInfo *pInfo = (ProductInfo*) [self.selectedSellerInfo.sellerProducts objectAtIndex:indexPath.row];
            [self clickOnProduct:pInfo currentItemData:nil cell:nil parentVC:parentVC];
       // }];
//    }];
}
- (void)clickOnProduct:(id)productClicked currentItemData:(id)currentItemData cell:(id)cell parentVC:(id)parentVC {
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
    vcProduct.parentVC = parentVC;
    vcProduct.parentCell = cell;
}

/*
{
    ProductInfo* pInfo = productClicked;
    DataPass* dPass = currentItemData;
    
    //    ViewControllerMain* mainVC = [ViewControllerMain getInstance];
    //    mainVC.containerTop.hidden = YES;
    //    mainVC.containerCenter.hidden = YES;
    //    mainVC.containerCenterWithTop.hidden = NO;
    //    mainVC.vcBottomBar.buttonHome.selected = YES;
    //    mainVC.vcBottomBar.buttonCart.selected = NO;
    //    mainVC.vcBottomBar.buttonWishlist.selected = NO;
    //    mainVC.vcBottomBar.buttonSearch.selected = NO;
    //    mainVC.revealController.panGestureEnable = false;
    //    [mainVC.vcBottomBar buttonClicked:nil];
    
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
    
    ViewControllerProduct* vcProduct = [[Utility sharedManager] pushProductScreen:self.parentVC];
    [vcProduct loadData:clickedItemData previousItem:previousItemData drillingLevel:0];
    
    vcProduct.parentVC = parentVC;
    vcProduct.parentCell = cell;
}
 */
- (void)setData:(SellerInfo*)sellerInfo {
    self.selectedSellerInfo = sellerInfo;
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self checkAndLoadNextPageForced];
}
- (void)startLoadingAnim {
    RLOG(@"startLoadingAnim");
    if (_spinnerView == nil) {
        _spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    [_spinnerView removeFromSuperview];
    [collectionViewProducts addSubview:_spinnerView];
    [_spinnerView setFrame:CGRectMake(
                                      0,
                                      0,
                                      _spinnerView.frame.size.width,
                                      _spinnerView.frame.size.height)];
    [_spinnerView setCenter:CGPointMake(self.view.frame.size.width/2, MAX([collectionViewProducts contentSize].height, [collectionViewProducts frame].size.height) - _spinnerView.frame.size.height)];
    [_spinnerView startAnimating];
}
- (void)stopLoadingAnim {
    RLOG(@"stopLoadingAnim");
    [_spinnerView removeFromSuperview];
    //    [self resetMainScrollView];
}
-(void)checkAndLoadNextPageForced {
    BOOL shouldLoadNextPage = true;
    int childRC = self.selectedSellerInfo.productLoadedPageCount * 100;
    if ((shouldLoadNextPage && !_pageLoading) ||( childRC == 0 && !_pageLoading)) {
        _pageLoading = true;
        [self loadSellerProducts];
    }
}
- (void)setProductVC:(id)productVC parentVC:(id)parentVC {
    self.productVC = productVC;
    self.parentVC = ((ViewControllerProduct*)productVC).parentVC;

}
@end
