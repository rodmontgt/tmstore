//
//  ViewControllerCategories.m
//  eMobileApp
//
//  Created by Rishabh Jain on 09/11/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import "ViewControllerCategories.h"
#import "Utility.h"
#import "ViewControllerProduct.h"
#import "Wishlist.h"
#import "DataManager.h"
#import "Variables.h"
#import "ParseHelper.h"
#import "ProductInfo.h"
#import "Addons.h"
#import "Cart.h"
#import "ViewControllerFilter.h"
#import "AnalyticsHelper.h"
#import "ViewControllerNotification.h"
#define CATEGORY_IMG_ENABLE 1
#define MAX_PRODUCT_COUNT 12
#define NEW_CPA 1
@interface DataPass ()
@end
@implementation DataPass
- (id)init {
    self = [super init];
    if (self) {
        // initialize instance variables here
        _itemId = 0;
        _isCategory = false;
        _isProduct = false;
        _hasChildCategory = false;
        _childCount = 0;
        _cInfo = nil;
        _pInfo = nil;
        _variationId = -1;
        _cart = nil;
    }
    return self;
}
@end

#define MIN_FILTER_HEIGHT_FACTOR 0.65f
#define MAX_FILTER_HEIGHT_FACTOR 1.0f


static int kTagForGlobalSpacing = 0;
static int kTagForNoSpacing = -1;
static int kTagForLastViewSpacing = 1;
static const CGFloat kNewPageLoadScrollPercentageThreshold = 0.66;
static BOOL ShouldLoadNextPage(UICollectionView *collectionView) {
    CGFloat yOffset = collectionView.contentOffset.y;
    CGFloat height = collectionView.contentSize.height - CGRectGetHeight(collectionView.frame);
    return yOffset / height > kNewPageLoadScrollPercentageThreshold;
}
static BOOL ShouldLoadNextPageScrollView(UIScrollView *scrollView) {
    CGFloat yOffset = scrollView.contentOffset.y;
    CGFloat height = scrollView.contentSize.height - CGRectGetHeight(scrollView.frame);
    return yOffset / height > kNewPageLoadScrollPercentageThreshold;
}
@interface ViewControllerCategories () {
    NSMutableArray *_viewsAdded;
    NSMutableArray *_horizontalScrollViews;
    UIButton *customBackButton;
    UIButton *customFilterButton;
    ShopSettings* SHOP_SETTINGS;

}
@end

@implementation ViewControllerCategories

- (void)viewDidLoad {
    [super viewDidLoad];

    _pageLoading = false;
    _spinnerView = nil;
    _scrollViewBaseOffsetDefault = -99999.0f;
    _scrollViewChildOffsetDefault = -99999.0f;
    
    _strCollectionView1 = [[Utility sharedManager] getProductViewString];
    _strCollectionView2 = [[Utility sharedManager] getCategoryViewString];
    _strCollectionView3 = [[Utility sharedManager] getHorizontalViewString];
    
    
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[Utility getUIColor:kUIColorThemeFont], NSForegroundColorAttributeName, [Utility getUIFont:kUIFontType24 isBold:false], NSFontAttributeName, nil]];
    [self.currentItemHeading setTitle:@"   "];
    
    _labelViewHeading = [[UILabel alloc] init] ;
    [_labelViewHeading setFrame:CGRectMake(0, 20, [[MyDevice sharedManager] screenSize].width, _navigationBar.frame.size.height)];
    [_labelViewHeading setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [_labelViewHeading setUIFont:kUIFontType24 isBold:false];
    [_labelViewHeading setTextColor:[Utility getUIColor:kUIColorThemeFont]];
    [_labelViewHeading setTextAlignment:NSTextAlignmentCenter];
    [_labelViewHeading setText:@"    "];
    [self.view addSubview:_labelViewHeading];

    int countSubviews = (int)[[_navigationBar subviews] count];
    RLOG(@"countSubviews = %d", countSubviews);
    [_navigationBar setClipsToBounds:false];
    [_lineView setBackgroundColor:[Utility getUIColor:kUIColorBorder]];
    [_scrollView setBackgroundColor:[Utility getUIColor:kUIColorBgTheme]];
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

    customFilterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [customFilterButton setImage:[[UIImage imageNamed:@"ic_filter"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [customFilterButton addTarget:self action:@selector(filterButtonPressed:)forControlEvents:UIControlEventTouchUpInside];
    
    [customFilterButton setTitle:[NSString stringWithFormat:@"%@", Localize(@"")] forState:UIControlStateNormal];
    [customFilterButton setTintColor:[Utility getUIColor:kUIColorThemeFont]];
    [customFilterButton setTitleColor:[Utility getUIColor:kUIColorThemeFont] forState:UIControlStateNormal];
    [customFilterButton.titleLabel setUIFont:kUIFontType18 isBold:false];
    [customFilterButton sizeToFit];
    [customFilterButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [customFilterButton setContentMode:UIViewContentModeRight];
    [customFilterButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [_nextItemHeading setCustomView:customFilterButton];
    [_nextItemHeading setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[Utility getUIColor:kUIColorThemeFont], NSForegroundColorAttributeName, [Utility getUIFont:kUIFontType18 isBold:false], NSFontAttributeName, nil] forState:UIControlStateNormal];
    customFilterButton.hidden = true;
    
    trendingBannerProducts = nil;
    // Do any additional setup after loading the view.
    
    DataManager * dm = [DataManager sharedManager];
    if (dm.isPriceFilterLoaded  && dm.isAtributtFilterLoaded && dm.enable_filters ) {
#if ENABLE_HEADER_FILTER_BUTTON
        customFilterButton.hidden = false;
        [self setFilterVisibility:YES];
#else
        _filterView.hidden = false;
        float filterPOSY = CGRectGetMaxY(_filterView.frame);
        _scrollView.frame = CGRectMake(
                                       _scrollView.frame.origin.x,
                                       filterPOSY - 20,
                                       _scrollView.frame.size.width,
                                       [[MyDevice sharedManager] screenSize].height -  (filterPOSY - 20) - [[Utility sharedManager] getBottomBarHeight] - 20
                                       );
#endif
    }else if (!dm.isPriceFilterLoaded && dm.enable_filters){
        _filterView.hidden = true;
        customFilterButton.hidden = true;
        [self setFilterVisibility:YES];

        [self loadFilterPrices];
    }else if (dm.enable_filters){
        _filterView.hidden = true;
        customFilterButton.hidden = true;
        [self setFilterVisibility:YES];
        [self loadFilterAttributes];
    }
    self.automaticallyAdjustsScrollViewInsets =NO;
    
}
- (void)viewDidAppear:(BOOL)animated{
    DataManager * dm = [DataManager sharedManager];
    if (dm.enable_filters ) {
        [self getAttributeWithID];
        [self getMaximumAndMinimumWithID];
    }
#if ENABLE_FIREBASE_TAG_MANAGER
    [[AnalyticsHelper sharedInstance] registerVisitScreenEvent:@"Categories Screen"];
#endif
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[[[DataManager sharedManager] tmDataDoctor] tmMulticastDelegate] removeDelegate:self];
//    [self flushCache];
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
- (void)viewWillAppear:(BOOL)animated{
    //rv//[SDWebImageManager.sharedManager.imageDownloader setValue:@"SDWebImage Demo" forHTTPHeaderField:@"AppName"];
    //    SDWebImageManager.sharedManager.imageDownloader.executionOrder = SDWebImageDownloaderFIFOExecutionOrder;
    [[Utility sharedManager] startGrayLoadingBar:false];
    //    _setScrollView = 1;
    _permanentScrollSet = false;
    [[[[DataManager sharedManager] tmDataDoctor] tmMulticastDelegate] addDelegate:self];
}
- (void)flushCache {
    [SDWebImageManager.sharedManager.imageCache clearMemory];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)filterButtonPressed:(id)sender {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [self FilterButton:nil];
}
- (IBAction)barButtonBackPressed:(id)sender {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    //    [self dismissViewControllerAnimated:YES completion:nil];
    _pageLoading = false;
    
    for (int i = 0; i < _kTotalViewsHomeScreen; i++) {
        _viewUserDefined[i] = nil;
        _propCollectionView[i] = [[LayoutProperties alloc] initWithCollectionViewValues:SCROLL_TYPE_SHOWFULL];
        _viewUserDefinedHeaderString[i] = @"";
        _viewUserDefinedHeader[i] = nil;
        _isViewUserDefinedEnable[i] = false;
    }
    ViewControllerCategories* vcCategories = nil;
    if([self.parentViewController isKindOfClass:[ViewControllerCategories class]]){
        vcCategories = (ViewControllerCategories*)(self.parentViewController);
    }
    [[Utility sharedManager] popScreen:self];
    [[UserFilter sharedInstance] resetFilterdata];
    
    if (self.parentVC) {
        if ([self.parentVC isKindOfClass:[ViewControllerNotification class]]) {
            [[Utility sharedManager] popScreen:self];
            return;
        }
    }
    if (_drillingLevel == 0) {
        ViewControllerMain* mainVC = [ViewControllerMain getInstance];
        [mainVC resetPreviousState];
    }
    if (vcCategories != nil) {
        [vcCategories refreshView];
    }
}
- (void)refreshView {
#if CATEGORY_VIEW_NEW_HACK_ENABLE
    if (_scrollViewChild) {
        [_scrollViewChild reloadData];
    }
#else
    _scrollViewBase.scrollEnabled = true;
    _scrollViewChild.scrollEnabled  = true;
    _permanentScrollSet = false;
    [self scrollViewDidScroll:_scrollView];
#endif
}
- (void)loadData:(DataPass *)currentItem previousItem:(DataPass *)previousItem drillingLevel:(int)drillingLevel{
    
    _pageNumber = 1;
    
    _currentItem = currentItem;
    _previousItem = previousItem;
    _drillingLevel = drillingLevel;
    
    CategoryInfo * itemCategoryPrevious = nil;
    CategoryInfo * itemCategoryCurrent = nil;
    ProductInfo * itemProductPrevious = nil;
    ProductInfo * itemProductCurrent = nil;
    NSString *str = nil;
    
    
    if (previousItem.isCategory) {
        itemCategoryPrevious = [CategoryInfo getWithId:previousItem.itemId];
    }
    if (previousItem.isProduct) {
        itemProductPrevious = [ProductInfo getProductWithId:previousItem.itemId];
    }
    if (currentItem.isCategory) {
        itemCategoryCurrent = [CategoryInfo getWithId:currentItem.itemId];
    }
    if (currentItem.isProduct) {
        itemProductCurrent = [ProductInfo getProductWithId:currentItem.itemId];
    }
    
    str = [NSString stringWithFormat:@"  %@  ", Localize(@"i_back")];
    [customBackButton setTitle:str forState:UIControlStateNormal];
    [customBackButton sizeToFit];
    
    if (currentItem.isCategory) {
        str = [NSString stringWithFormat:@"%@", itemCategoryCurrent._nameForOuterView];
    }
    if (currentItem.isProduct) {
        str = [NSString stringWithFormat:@"%@", itemProductCurrent._titleForOuterView];
    }
#if NEW_CPA
    int maxSubcategoryCount = (int)[[_currentItem.cInfo getSubCategories] count];
    int maxChildrenCount = _currentItem.cInfo._count;
    if (maxSubcategoryCount == 0 && maxChildrenCount == 0) {
        self.cViewLayoutType = CategoryViewLayoutType_P0_C0;
    } else if (maxSubcategoryCount > 0 && maxChildrenCount == 0) {
        self.cViewLayoutType = CategoryViewLayoutType_P0_C1;
    } else if (maxSubcategoryCount == 0 && maxChildrenCount > 0) {
        self.cViewLayoutType = CategoryViewLayoutType_P1_C0;
    } else if (maxSubcategoryCount > 1 && maxChildrenCount > 1) {
        self.cViewLayoutType = CategoryViewLayoutType_P1_C1;
    }
    self.cViewLayoutType = CategoryViewLayoutType_P0_C1;
#endif
    CGRect customBtnRect = customBackButton.frame;
    CGRect headingBtnRect = _labelViewHeading.frame;
    customBtnRect.size.height = headingBtnRect.size.height;
    customBackButton.frame = customBtnRect;
    //[customFilterButton setImageEdgeInsets:UIEdgeInsetsMake(customBtnRect.size.height *.2f, customBtnRect.size.width, customBtnRect.size.height *.2f, 0)];
    CGRect customFilterBtnRect = customFilterButton.frame;
    customFilterBtnRect.size.height = headingBtnRect.size.height;
    customFilterButton.frame = customFilterBtnRect;
    float bckBtnMaxX = CGRectGetMaxX(customBtnRect) + 20;
    headingBtnRect.size.width = self.view.frame.size.width - bckBtnMaxX * 2;
    headingBtnRect.origin.x = bckBtnMaxX;
    _labelViewHeading.frame = headingBtnRect;
    [_labelViewHeading setText:str];
    [self startTimer];
    
#if ENABLE_PARSE_ANALYTICS
    [[ParseHelper sharedManager] registerParseVisitCategory:currentItem.itemId increment:1];
#endif
    
#if ENABLE_FIREBASE_TAG_MANAGER
    [[AnalyticsHelper sharedInstance] registerVisitCategoryEvent:itemCategoryCurrent];
#endif
    [self checkAndLoadNextPage];
}
- (void)loadUI
{
    [self initVariables];
    [self loadDataInView];
}
- (void)startTimer {
    [self performSelector:@selector(loadUI) withObject:nil afterDelay:0.01f];
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
#pragma mark - Methods
- (int)getChildCount {
    int childC = 0;
    if (self.showFilterdResult) {
        childC = (int)[[ProductInfo getFilteredItems] count];
        return childC;
    }
    childC = _currentItem.childCount;
#if PROMO_ENABLE_IN_SHOW_ALL_VIEWS
    if ([[DataManager sharedManager] promoEnable]) {
        childC = MIN(MAX_PRODUCT_COUNT - 1, childC);
    } else {
        childC = MIN(MAX_PRODUCT_COUNT, childC);
    }
#endif
    return childC;
}
- (void)initVariables {
    
    _viewsAdded = [[NSMutableArray alloc] init];
    _propBanner = [[LayoutProperties alloc] initWithBannerValues];
    _propBannerProduct = [[LayoutProperties alloc] initWithProductBannerValues];
    for (int i = 0; i < _kTotalViewsHomeScreen; i++) {
        _viewUserDefined[i] = nil;
        _propCollectionView[i] = [[LayoutProperties alloc] initWithCollectionViewValues:SCROLL_TYPE_SHOWFULL];
        _viewUserDefinedHeaderString[i] = @"";
        _viewUserDefinedHeader[i] = nil;
        _isViewUserDefinedEnable[i] = false;
    }
    if (_currentItem.isCategory && _currentItem.hasChildCategory) {
        _isViewUserDefinedEnable[_kCategoryBasic] = true;
        _viewUserDefinedHeaderString[_kCategoryBasic] = @"";
        if (self.showFilterdResult) {
            _isViewUserDefinedEnable[_kCategoryBasic] = false;
        }
    }
    
    if (_currentItem.isCategory && [self getChildCount]) {
        _isViewUserDefinedEnable[_kShowAllItems] = true;
        _viewUserDefinedHeaderString[_kShowAllItems] = @"";
    }
    
    if (_currentItem.isCategory)
    {
        _isViewUserDefinedEnable[_kTrending] = false;
        _isViewUserDefinedEnable[_kDiscount] = false;
        _isViewUserDefinedEnable[_kNew] = false;
        _isViewUserDefinedEnable[_kMaxSold] = false;
        
        _viewUserDefinedHeaderString[_kTrending] = Localize(@"header_trending_items");
        _viewUserDefinedHeaderString[_kDiscount] = Localize(@"discount");
        
        _viewUserDefinedHeaderString[_kNew] = Localize(@"header_fresh_arrival");
        
        _viewUserDefinedHeaderString[_kMaxSold] = Localize(@"header_best_deals");
        
        _viewKey[_kTrending] = @"sale_price";
        _viewKey[_kDiscount] = @"on_sale";
        _viewKey[_kNew] = @"id";
        _viewKey[_kMaxSold] = @"total_sales";
    }
    
}
- (void)loadDataInView {
    
    
    
    NSArray* subViews = [_scrollView subviews];
    for (UIView* view in subViews) {
        [view removeFromSuperview];
    }
    for (int i = 0; i < _kTotalViewsHomeScreen; i++) {
        [_propCollectionView[i] setCollectionViewProperties:_propCollectionView[i] scrollType:SCROLL_TYPE_SHOWFULL];
    }
    for (UIView* view in _viewsAdded) {
        [view removeFromSuperview];
    }
    [_viewsAdded removeAllObjects];
    [self createBannerView];
    if (self.showFilterdResult == true) {
        CGRect bannerRect = _bannerScrollView.frame;
        bannerRect.size.height = 0;
        _bannerScrollView.frame = bannerRect;
        _bannerScrollView.hidden = true;
    }
    [self createVariousViews];
    _scrollViewBase = _scrollView;
    _scrollViewChild = _viewUserDefined[_kShowAllItems];
//    _scrollViewChild.bounces = false;
#if CATEGORY_VIEW_NEW_HACK_ENABLE
    [_scrollViewBase setScrollEnabled:true];
    [_scrollViewChild setScrollEnabled:false];
#endif
    _scrollViewBaseOffsetDefault = -99999;
    _scrollViewChildOffsetDefault = -99999;
    
    [self createViewAllButton];
    
    [[Utility sharedManager] stopGrayLoadingBar];
    [self resetMainScrollView];
    
#if ENABLE_FILTER
    [self createFilterButton];
    if (_currentItem.cInfo._childMaximumCount > 0) {
        [self showFilterView];
    }
#endif
    DataManager *dm =[DataManager sharedManager];
    if (dm.enable_filters) {
        [self FilterAndSortingview];
    }
    switch (self.cViewLayoutType) {
        case CategoryViewLayoutType_P0_C0:
        {
//            [_scrollView addSubview:_bannerScrollView];
        }break;
        case CategoryViewLayoutType_P1_C0:
        {
//            [_scrollView addSubview:_bannerScrollView];
        }break;
        case CategoryViewLayoutType_P0_C1:
        {
//            [_scrollView addSubview:_bannerScrollView];
//            CGRect bannerFrame = _bannerScrollView.frame;
//            CGRect scrollFrame = _scrollView.frame;
//            [_bannerScrollView removeFromSuperview];
//            bannerFrame.origin.y = [[Utility sharedManager] getTopBarHeight] * 2;
//            _bannerScrollView.frame = bannerFrame;
//            [_scrollView.superview addSubview:_bannerScrollView];
//            [_scrollView.superview bringSubviewToFront:_scrollView];
//            [_scrollView setBackgroundColor:[UIColor clearColor]];
        }break;
        case CategoryViewLayoutType_P1_C1:
        {
//            [_scrollView addSubview:_bannerScrollView];
        }break;
            
        default:
            break;
    }
}
- (void)createViewAllButton {
#if PROMO_ENABLE_IN_SHOW_ALL_VIEWS
    if ([[DataManager sharedManager] promoEnable]) {
        if(_currentItem.cInfo._count < MAX_PRODUCT_COUNT - 1) {
            return;
        }
    } else {
        if(_currentItem.cInfo._count < MAX_PRODUCT_COUNT) {
            return;
        }
    }
#endif
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 0 , 50)];
    [[button titleLabel] setUIFont:kUIFontType20 isBold:true];
    [button setTitle:Localize(@"view_all") forState:UIControlStateNormal];
    [button setTitleColor:[Utility getUIColor:kUIColorBlue] forState:UIControlStateNormal];
//    [button setTitleColor:[Utility getUIColor:kUIColorBlue] forState:UIControlStateNormal];
    [button setBackgroundColor:[Utility getUIColor:kUIColorBgHeader]];
    [button setTitleColor:[Utility getUIColor:kUIColorThemeFont] forState:UIControlStateNormal];
//    [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
//    if ([[TMLanguage sharedManager] isRTLEnabled]) {
//        [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
//    }
    [_scrollView addSubview:button];
    [_viewsAdded addObject:button];
    [button setTag:kTagForGlobalSpacing];
    [button addTarget:self action:@selector(clickOnViewAll:) forControlEvents:UIControlEventTouchUpInside];
}
- (void)clickOnViewAll:(UIButton*)sender {
    [self clickOnCategoryNew:_currentItem.cInfo currentItemData:_currentItem];
}
//    [self showFilterView:@"rishabh loves india"];
#pragma CreateFilterView
-(void)FilterAndSortingview {
    DataManager* dm = [DataManager sharedManager];
    if ((dm.enable_filters ==false)) {
        return;
    }
    float buttonHeight = [[MyDevice sharedManager] screenHeightInPortrait] * .055f;
    float viewHeight = [[MyDevice sharedManager] screenHeightInPortrait] * .075f;
    float viewPosY = CGRectGetMaxY(_navigationBar.frame) + 20 ;
    
    float viewWidth = [[MyDevice sharedManager] screenSize].width;
    if (_filterView) {
        [_filterView removeFromSuperview];
    }
    _filterView=[[UIView alloc]init];
    _filterView.frame = CGRectMake(0, viewPosY, viewWidth, viewHeight);
    _filterView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_filterView];
    float buttonWidth = [[MyDevice sharedManager] screenSize].width * 0.47f;
    float buttonPosX = self.view.frame.size.width * .02f;
    UIButton *buttonSorting = [[UIButton alloc] init];
    buttonWidth = [[MyDevice sharedManager] screenSize].width * 0.47f;
    buttonSorting.frame = CGRectMake(buttonPosX, 0, buttonWidth, buttonHeight);
    buttonSorting.center = CGPointMake(buttonSorting.center.x, _filterView.frame.size.height/2);
    [buttonSorting setBackgroundColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
    [[buttonSorting titleLabel] setUIFont:kUIFontType22 isBold:false];
    [buttonSorting setTitle:Localize(@"btn_sort") forState:UIControlStateNormal];
    [buttonSorting setTitleColor:[Utility getUIColor:kUIColorBuyButtonFont] forState:UIControlStateNormal];
    [buttonSorting addTarget:self action:@selector(SortingButton:) forControlEvents:UIControlEventTouchUpInside];
    [_filterView addSubview:buttonSorting];
    
    float buttonFilterPosX = buttonPosX + buttonWidth + self.view.frame.size.width * .02f;
    UIButton *buttonFilter = [[UIButton alloc] init];
    buttonFilter.frame = CGRectMake(buttonFilterPosX, 0, buttonWidth, buttonHeight);
    buttonFilter.center = CGPointMake(buttonFilter.center.x, _filterView.frame.size.height/2);
    [buttonFilter setBackgroundColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
    [[buttonFilter titleLabel] setUIFont:kUIFontType22 isBold:false];
    [buttonFilter setTitle:Localize(@"btn_filter") forState:UIControlStateNormal];
    [buttonFilter setTitleColor:[Utility getUIColor:kUIColorBuyButtonFont] forState:UIControlStateNormal];
    [buttonFilter addTarget:self action:@selector(FilterButton:) forControlEvents:UIControlEventTouchUpInside];
    [_filterView addSubview:buttonFilter];
    [self ispriceLoadedandAtributtLoadede];
#if ENABLE_HEADER_FILTER_BUTTON
    _filterView.hidden = true;
#else
#endif
    
}
-(void)ispriceLoadedandAtributtLoadede{
    float filterPOSY = CGRectGetMaxY(_filterView.frame);
    DataManager * dm = [DataManager sharedManager];
    if (dm.isPriceFilterLoaded  && dm.isAtributtFilterLoaded ) {
#if ENABLE_HEADER_FILTER_BUTTON
        customFilterButton.hidden = false;
        [self setFilterVisibility:false];

#else
        _filterView.hidden = false;
        _scrollView.frame = CGRectMake(
                                       _scrollView.frame.origin.x,
                                       filterPOSY - 20,
                                       _scrollView.frame.size.width,
                                       [[MyDevice sharedManager] screenSize].height -  (filterPOSY - 20) - [[Utility sharedManager] getBottomBarHeight] - 20
                                       );
#endif

    }else if (!dm.isPriceFilterLoaded){
        _filterView.hidden = true;
        customFilterButton.hidden = true;
        [self setFilterVisibility:YES];

    }else{
        _filterView.hidden = true;
        customFilterButton.hidden = true;
        [self setFilterVisibility:YES];

    }
}
-(void)SortingButton:(UIButton *)sender {
    ViewControllerMain* mainVC = [ViewControllerMain getInstance];
    ViewControllerFilter* vcFilter = (ViewControllerFilter*)[[Utility sharedManager] pushScreenWithNewAnimation:mainVC.vcCenterTop type:PUSH_SCREEN_TYPE_FILTER];
    [vcFilter.view setTag:PUSH_SCREEN_TYPE_FILTER];
    [vcFilter setDataInView:_currentItem.cInfo categoryidwithiteam:filterAttributes MaxPrice:MaxPriceWithID Minprice:MinPriceWithID previousVC:self];
}

- (void)reloadWithFilter:(NSMutableArray*)array appliedUserFilter:(UserFilter*) userFilter{
    RLOG(@"reloadWithFilter%@",array);
    _userFilter = userFilter;
    [ProductInfo setFilteredItems:array];
    self.showFilterdResult = true;
    BOOL isVisible = (array != nil && array.count == 0);
    [self noProductsFoundthisAppliedFilter:!isVisible];
    [self startTimer];
}
-(void)FilterButton:(UIButton *)sender{
    ViewControllerMain* mainVC = [ViewControllerMain getInstance];
    ViewControllerFilter* vcFilter = (ViewControllerFilter*)[[Utility sharedManager] pushScreenWithNewAnimation:mainVC.vcCenterTop type:PUSH_SCREEN_TYPE_FILTER];
    [vcFilter.view setTag:PUSH_SCREEN_TYPE_FILTER];
    [vcFilter setDataInView:_currentItem.cInfo categoryidwithiteam:filterAttributes MaxPrice:MaxPriceWithID Minprice:MinPriceWithID previousVC:self];
}

#pragma mark - Banner View
- (void)createBannerView {
    if (trendingBannerProducts == nil) {
        refreshBannerCount = -1;
        trendingBannerProducts = [[NSMutableArray alloc] init];
    }
    [_propBanner setBannerProperties:_propBanner showFullSizeBanner:[[DataManager sharedManager] showFullSizeCategoryBanner]];
    CGRect bannerRect = [_propBanner getFrameRect];
    _bannerScrollView = [[PagedImageScrollView alloc] initWithFrame:bannerRect];
    [_bannerScrollView setBackgroundColor:_propBanner._bgColor];
    NSMutableArray *imageArray = [[NSMutableArray alloc] init];
    NSObject* object = nil;
    if([imageArray count] == 0) {
        if (_currentItem.isCategory && _currentItem.cInfo != nil) {
            Banner* banner = nil;
#if CATEGORY_IMG_ENABLE
            if (_currentItem.cInfo._image && ![_currentItem.cInfo._image isEqualToString:@""]) {
                banner = [[Banner alloc] initWithoutAddingToArray];
                banner.bannerType = BANNER_SIMPLE;
                banner.bannerUrl = _currentItem.cInfo._image;
            }
#else
            int subcategoryCount = (int)[[_currentItem.cInfo getSubCategories] count];
            int childrenCount = (int)[self getChildCount];
            if(subcategoryCount > 0) {
                int randChild = rand() % subcategoryCount;
                CategoryInfo* cInfo = (CategoryInfo*)[[_currentItem.cInfo getSubCategories] objectAtIndex:randChild];
                banner = [[Banner alloc] initWithoutAddingToArray];
                banner.bannerType = BANNER_CATEGORY;
                banner.bannerId = cInfo._id;
                banner.bannerUrl = cInfo._image;
            }
            else if (childrenCount > 0) {
                int randChild = rand() % childrenCount;
                ProductInfo *pInfo = (ProductInfo *)[[ProductInfo getOnlyForCategory:_currentItem.cInfo showFilterProducts:false]  objectAtIndex:randChild];
                banner = [[Banner alloc] initWithoutAddingToArray];
                banner.bannerType = BANNER_PRODUCT;
                banner.bannerId = pInfo._id;
                if ([pInfo._images count] == 0) {
                    [pInfo._images addObject:[[ProductImage alloc] init]];
                }
                ProductImage* pImg = [pInfo._images objectAtIndex:0];
                banner.bannerUrl = pImg._src;
            }
#endif
            if (banner) {
                UIImageView * uiImageView = [[UIImageView alloc]init];
                [Utility setImage:uiImageView url:banner.bannerUrl resizeType:kRESIZE_TYPE_BANNER isLocal:false];
                [imageArray addObject:uiImageView];
                [uiImageView.layer setValue:banner forKey:@"BANNER_OBJ"];
                UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bannerTapped:)];
                singleTap.numberOfTapsRequired = 1;
                singleTap.numberOfTouchesRequired = 1;
                [uiImageView addGestureRecognizer:singleTap];
                [uiImageView setUserInteractionEnabled:YES];
            }
        }
    }
    if ([imageArray count] > 0 && [[Addons sharedManager] show_category_banner]) {
        [_bannerScrollView setScrollViewContentsWithImageViews:imageArray contentMode:UIViewContentModeScaleAspectFill];
        [_bannerScrollView reloadView:bannerRect];
        switch (self.cViewLayoutType) {
            case CategoryViewLayoutType_P0_C0:
            {
                [_scrollView addSubview:_bannerScrollView];
            }break;
            case CategoryViewLayoutType_P1_C0:
            {
                [_scrollView addSubview:_bannerScrollView];
            }break;
            case CategoryViewLayoutType_P0_C1:
            {
                [_scrollView addSubview:_bannerScrollView];
//                [self.view addSubview:_bannerScrollView];
//                [self.view bringSubviewToFront:_scrollView];
//                [_scrollView setBackgroundColor:[UIColor clearColor]];
            }break;
            case CategoryViewLayoutType_P1_C1:
            {
                [_scrollView addSubview:_bannerScrollView];
            }break;
                
            default:
                break;
        }
        [_viewsAdded addObject:_bannerScrollView];
        [_bannerScrollView setTag:kTagForNoSpacing];
    }
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
                    [self clickOnProduct:pInfo currentItemData:_currentItem cell:cell];
                } else {
                    ProductInfo* pInfo = [[ProductInfo alloc] init];
                    pInfo._id = productId;
                    [self clickOnProduct:pInfo currentItemData:_currentItem cell:cell];
                }
                
            }break;
            case BANNER_CATEGORY://open category
            {
                int categoryId = bannerId;
                CategoryInfo *cInfo = [CategoryInfo getWithId:categoryId];
                [self clickOnCategory:cInfo currentItemData:_currentItem];
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
        [self clickOnProduct:pInfo currentItemData:_currentItem cell:cell];
    }
}
- (void)promoTapped:(UITapGestureRecognizer*)singleTap{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[DataManager sharedManager] promoUrlString]]];
}
#pragma mark - Deal Views
- (void)createVariousViews {
    for (int i = 0; i < _kTotalViewsHomeScreen; i++) {
        if (_isViewUserDefinedEnable[i] == false) {
            continue;
        }
        
        if (![_viewUserDefinedHeaderString[i] isEqualToString:@""]) {
            float fontSize = 34;
            float alignFactor = .014f * [[MyDevice sharedManager] screenWidthInPortrait];
            
            //            if ([[MyDevice sharedManager] isIpad]) {
            //                fontSize = 25;
            //            } else {
            //                fontSize = 14;
            //            }
            
            _viewUserDefinedHeader[i]=[[UILabel alloc]initWithFrame:CGRectMake(alignFactor, alignFactor, _scrollView.frame.size.width - alignFactor * 2, fontSize + alignFactor * 2)];//Set frame of label in your viewcontroller.
            [_viewUserDefinedHeader[i] setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
            //Set background color of label.
            [_viewUserDefinedHeader[i] setBackgroundColor:[Utility getUIColor:kUIColorBgSubTitle]];
            UIFont *customFont = [Utility getUIFont:kUIFontType24 isBold:false];
            fontSize = [customFont lineHeight];
            [_viewUserDefinedHeader[i] setUIFont:customFont];
            
            [_viewUserDefinedHeader[i] setText:_viewUserDefinedHeaderString[i]];//Set text in label.
            [_viewUserDefinedHeader[i] setTextColor:[Utility getUIColor:kUIColorFontSubTitle]];//Set text color in label.
            if ([[TMLanguage sharedManager] isRTLEnabled]) {
                [_viewUserDefinedHeader[i] setTextAlignment:NSTextAlignmentRight];
            } else {
                [_viewUserDefinedHeader[i] setTextAlignment:NSTextAlignmentLeft];//Set text alignment in label.
            }
            [_viewUserDefinedHeader[i] setBaselineAdjustment:UIBaselineAdjustmentAlignBaselines];//Set line adjustment.
            [_viewUserDefinedHeader[i] setLineBreakMode:NSLineBreakByCharWrapping];//Set linebreaking mode..
            [_viewUserDefinedHeader[i] setNumberOfLines:1];//Set number of lines in label.
                                                           //        [_viewUserDefinedHeader[i].layer setCornerRadius:25.0];//Set corner radius of label to change the shape.
                                                           //        [_viewUserDefinedHeader[i].layer setBorderWidth:2.0f];//Set border width of label.
                                                           //        [_viewUserDefinedHeader[i] setClipsToBounds:YES];//Set its to YES for Corner radius to work.
                                                           //        [_viewUserDefinedHeader[i].layer setBorderColor:[UIColor blackColor].CGColor];//Set Border color.
            [_scrollView addSubview:_viewUserDefinedHeader[i]];
            [_viewsAdded addObject:_viewUserDefinedHeader[i]];
            [_viewUserDefinedHeader[i] setTag:kTagForNoSpacing];
        }
        
        UICollectionViewFlowLayout *layout= [[UICollectionViewFlowLayout alloc] init];
        //        CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
        switch (i) {
            case _kCategoryBasic:
            {
                [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
                _viewUserDefined[i] = [[UICollectionView alloc] initWithFrame:[_propCollectionView[i] getFrameRect] collectionViewLayout:layout];
                [_viewUserDefined[i] setScrollEnabled:false];
                [_viewUserDefined[i] registerNib:[UINib nibWithNibName:_strCollectionView2  bundle:nil] forCellWithReuseIdentifier:@"CollectionCell"];
                [_scrollView addSubview:_viewUserDefined[i]];
                [_viewsAdded addObject:_viewUserDefined[i]];
                [_viewUserDefined[i] setTag:kTagForNoSpacing];
                
                
                UIView* lineView = [self addHorizontalLine:kTagForGlobalSpacing];
                [lineView setHidden:true];
            }break;
            case _kShowAllItems:
                _viewUserDefined[i] = [[Utility sharedManager] initProductCellCategoryScreen:_viewUserDefined[i] propCollectionView:_propCollectionView[i] layout:layout nibName:_strCollectionView1];
                [_scrollView addSubview:_viewUserDefined[i]];
                [_viewsAdded addObject:_viewUserDefined[i]];
                [_viewUserDefined[i] setTag:kTagForNoSpacing];
                [_viewUserDefined[i] setScrollEnabled:true];
                _propCollectionView[i]._height = self.view.frame.size.height - [[Utility sharedManager] getTopBarHeight];
                [_viewUserDefined[i] setFrame:[_propCollectionView[i] getFrameRect]];
                [self resetMainScrollView];
                break;
            case _kTrending:
            case _kMaxSold:
            case _kNew:
            case _kDiscount:
            case _kUserDefined1:
            case _kUserDefined2:
            case _kUserDefined3:
            case _kUserDefined4:
            case _kUserDefined5:
            {
                [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
                _viewUserDefined[i] = [[UICollectionView alloc] initWithFrame:[_propCollectionView[i] getFrameRect] collectionViewLayout:layout];
                [_viewUserDefined[i] setScrollEnabled:true];
                [_viewUserDefined[i] registerNib:[UINib nibWithNibName:_strCollectionView3 bundle:nil] forCellWithReuseIdentifier:@"CollectionCell"];
                
                [_scrollView addSubview:_viewUserDefined[i]];
                [_viewsAdded addObject:_viewUserDefined[i]];
                [_viewUserDefined[i] setTag:kTagForGlobalSpacing];
            }break;
                
            default:
                break;
        }
        
        [_viewUserDefined[i] setBackgroundColor:_propCollectionView[i]._bgColor];
        [_viewUserDefined[i] setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [_viewUserDefined[i] setDataSource:self];
        [_viewUserDefined[i] setDelegate:self];
        
        if ([[DataManager sharedManager] layoutIdProductView] == P_LAYOUT_ZIGZAG ||
            [[DataManager sharedManager] layoutIdProductView] == P_LAYOUT_GROCERY) {
            [UIView animateWithDuration:0 animations:^{
                [_viewUserDefined[i] reloadData];
            } completion:^(BOOL finished) {
                if (finished) {
                    if (i == _kShowAllItems) {
                        [_viewUserDefined[i] reloadData];
                    }
                }
            }];
        } else if ([[DataManager sharedManager] layoutIdProductView] == P_LAYOUT_DISCOUNT) {
            if (ENABLE_DISCOUNT_LAYOUT_TYPE1) {
                if ([[ProductInfo getOnlyForCategory:_currentItem.cInfo showFilterProducts:self.showFilterdResult] count] > 0) {
                    for (ProductInfo* pInfo in [ProductInfo getOnlyForCategory:_currentItem.cInfo showFilterProducts:self.showFilterdResult]) {
                        pInfo.cellObj = nil;
                    }
                }
            }
            [_viewUserDefined[i] reloadData];
        } else {
            [_viewUserDefined[i] reloadData];
        }
        
        
        [self resetMainScrollView];
    }
    [_scrollView setDelegate:self];
}
#pragma mark - Category View
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    int itemCount = 0;
    int i = 0;
    for (; i < _kTotalViewsHomeScreen; i++) {
        if(_viewUserDefined[i] == collectionView){
            break;
        }
    }
    
    if (i == _kCategoryBasic ) {
        if (_currentItem.isCategory && _currentItem.hasChildCategory > 0) {
            itemCount = (int)[[_currentItem.cInfo getSubCategories] count];
            NSLog(@"itemCount_category %d ",itemCount);
        }
    } else {
        switch (i) {
            case _kShowAllItems:
            {
                if (_currentItem.isCategory && [self getChildCount] > 0) {
                    //                    itemCount =   MIN(_pageNumber * 10, _currentItem.childCount);
                    itemCount = [self getChildCount];
#if PROMO_ENABLE_IN_SHOW_ALL_VIEWS
                    if ([[DataManager sharedManager] promoEnable]) {
                        itemCount++;
                    }
#endif
                }
            }break;
            case _kTrending:
            {
                //trendings
                itemCount = (int)[[ProductInfo getProductsForCategory:_currentItem.cInfo keyString:_viewKey[_kTrending] isAscending:YES viewType:kHV_TYPES_TRENDINGS] count];
#if PROMO_ENABLE_IN_HORIZONTAL_VIEWS
                if ([[DataManager sharedManager] promoEnable]) {
                    itemCount++;
                }
#endif
                if (itemCount < MIN_ITEMS_IN_HORIZONTAL_VIEWS) {
                    itemCount = 0;
                }
                if (itemCount > MAX_ITEMS_IN_HORIZONTAL_VIEWS) {
                    itemCount = MAX_ITEMS_IN_HORIZONTAL_VIEWS;
                }
            }break;
            case _kMaxSold:
            {
                //maxsold items
                itemCount = (int)[[ProductInfo getProductsForCategory:_currentItem.cInfo keyString:_viewKey[_kMaxSold] isAscending:NO viewType:kHV_TYPES_BESTSELLINGS] count];
#if PROMO_ENABLE_IN_HORIZONTAL_VIEWS
                if ([[DataManager sharedManager] promoEnable]) {
                    itemCount++;
                }
#endif
                if (itemCount < MIN_ITEMS_IN_HORIZONTAL_VIEWS) {
                    itemCount = 0;
                }
                if (itemCount > MAX_ITEMS_IN_HORIZONTAL_VIEWS) {
                    itemCount = MAX_ITEMS_IN_HORIZONTAL_VIEWS;
                }
            }break;
            case _kNew:
            {
                //new
                itemCount = (int)[[ProductInfo getProductsForCategory:_currentItem.cInfo keyString:_viewKey[_kNew] isAscending:NO viewType:kHV_TYPES_NEWARRIVALS] count];
#if PROMO_ENABLE_IN_HORIZONTAL_VIEWS
                if ([[DataManager sharedManager] promoEnable]) {
                    itemCount++;
                }
#endif
                if (itemCount < MIN_ITEMS_IN_HORIZONTAL_VIEWS) {
                    itemCount = 0;
                }
                if (itemCount > MAX_ITEMS_IN_HORIZONTAL_VIEWS) {
                    itemCount = MAX_ITEMS_IN_HORIZONTAL_VIEWS;
                }
            }break;
            case _kDiscount:
            {
                //discount
                itemCount = (int)[[ProductInfo getProductsForCategory:_currentItem.cInfo keyString:_viewKey[_kDiscount] isAscending:NO viewType:kHV_TYPES_DISCOUNTS] count];
#if PROMO_ENABLE_IN_HORIZONTAL_VIEWS
                if ([[DataManager sharedManager] promoEnable]) {
                    itemCount++;
                }
#endif
                if (itemCount < MIN_ITEMS_IN_HORIZONTAL_VIEWS) {
                    itemCount = 0;
                }
                if (itemCount > MAX_ITEMS_IN_HORIZONTAL_VIEWS) {
                    itemCount = MAX_ITEMS_IN_HORIZONTAL_VIEWS;
                }
            }break;
            default:
                itemCount = 1;
                break;
        }
        NSLog(@"itemCount_product %d ",itemCount);
    }
    
    if (itemCount == 0) {
        [self removeUserDefinedView:i];
    }
    return itemCount;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
//    RLOG(@"collectionView.frame.size.height = %.f", collectionView.frame.size.height);
    static NSString *CellIdentifier = @"CollectionCell";
    CCollectionViewCell *cell=(CCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    int i = 0;
    for (; i < _kTotalViewsHomeScreen; i++) {
        if(_viewUserDefined[i] == collectionView){
            break;
        }
    }
    if (_propCollectionView[i]._insetTop != -1) {
        collectionView.contentInset = UIEdgeInsetsMake(_propCollectionView[i]._insetTop, _propCollectionView[i]._insetLeft, _propCollectionView[i]._insetBottom, _propCollectionView[i]._insetRight);
    }
    switch (i) {
        case _kCategoryBasic:
        {
            if (_currentItem.isCategory) {
                if (_currentItem.hasChildCategory > 0) {
                    if(cell == nil) {
                        NSArray *nib = [[ NSBundle mainBundle] loadNibNamed:_strCollectionView2 owner:self options:nil];
                        cell = [nib objectAtIndex:0];
                    }
                    [Utility showShadow:cell];
                    [cell setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
                    _propCollectionView[i]._height = _viewUserDefined[i].contentSize.height + _viewUserDefined[i].contentInset.top + _viewUserDefined[i].contentInset.bottom;
                    [_viewUserDefined[i] setFrame:[_propCollectionView[i] getFrameRect]];
                    [self resetMainScrollView];
                    CategoryInfo *cInfo = (CategoryInfo*) ([[_currentItem.cInfo getSubCategories] objectAtIndex:indexPath.row]);
                    NSString *cImage = cInfo._image;
                    //                    [[cell productName] setText:cInfo._name];
                    [[cell productName] setText:cInfo._nameForOuterView];
                    [Utility setImage:cell.productImg url:cImage resizeType:kRESIZE_TYPE_CATEGORY_THUMBNAIL isLocal:false];
                    [cell.productImg setContentMode:UIViewContentModeScaleAspectFill];
                    [cell.productImg setClipsToBounds:true];
                    
                    [cell.productName setUIFont:kUIFontType22 isBold:false];
                    switch ([[DataManager sharedManager] layoutIdCategoryView]) {
                        case C_LAYOUT_DEFAULT:
                            
                            break;
                        case C_LAYOUT_RIGHTSIDE:
                        {
                            cell.productImg.translatesAutoresizingMaskIntoConstraints = YES;
                            cell.productImgDummy.translatesAutoresizingMaskIntoConstraints = YES;
                            cell.productName.translatesAutoresizingMaskIntoConstraints = YES;
                            cell.labelExploreNow.translatesAutoresizingMaskIntoConstraints = YES;
                            cell.imgHeaderBg.translatesAutoresizingMaskIntoConstraints = YES;
                            CGRect cellFrame = cell.frame;
                            int diff = cellFrame.size.width/2;
                            int margin = 5;
                            [cell.productName sizeToFitUI];
                            cell.productName.frame = CGRectMake(diff + margin, cell.frame.size.height/2 - 10 - cell.productName.frame.size.height, diff - margin * 2, cell.productName.frame.size.height);
                            [cell.productName setLineBreakMode:NSLineBreakByWordWrapping];
                            [cell.productName setTextAlignment:NSTextAlignmentCenter];
                            [cell.productName setNumberOfLines:2];
                            [cell.productName sizeToFitUI];
                            
                            cell.productImg.frame = CGRectMake(0, 0, diff, cell.frame.size.height);
                            cell.productImgDummy.frame = CGRectMake(0, 0, diff, cell.frame.size.height);
                            cell.imgHeaderBg.frame = CGRectMake(diff, 0, diff, cell.frame.size.height);
                            cell.productName.frame = CGRectMake(diff + margin, cell.frame.size.height/2 - 10-cell.productName.frame.size.height, diff - margin * 2, cell.productName.frame.size.height);
                            cell.labelExploreNow.frame = CGRectMake(diff + cell.frame.size.width * .125f, cell.frame.size.height/2 + 10, cell.frame.size.width * .25f, cell.frame.size.height * .125f);
                            cell.labelExploreNow.backgroundColor = [Utility getUIColor:kUIColorBuyButtonNormalBg];
                            cell.labelExploreNow.textColor = [Utility getUIColor:kUIColorBuyButtonFont];
                            [cell.labelExploreNow setUIFont:kUIFontType14 isBold:true];
                            cell.labelExploreNow.text = Localize(@"explore_now");
                            [cell setNeedsLayout];
                            [cell layoutSubviews];
                        }break;
                        case C_LAYOUT_LEFTRIGHTSIDE:
                            if (((int)indexPath.row) % 2 != 0) {
                                cell.productImg.translatesAutoresizingMaskIntoConstraints = YES;
                                cell.productImgDummy.translatesAutoresizingMaskIntoConstraints = YES;
                                cell.productName.translatesAutoresizingMaskIntoConstraints = YES;
                                cell.labelExploreNow.translatesAutoresizingMaskIntoConstraints = YES;
                                cell.imgHeaderBg.translatesAutoresizingMaskIntoConstraints = YES;
                                CGRect cellFrame = cell.frame;
                                int diff = cellFrame.size.width/2;
                                int margin = 5;
                                [cell.productName sizeToFitUI];
                                cell.productName.frame = CGRectMake(margin, cell.frame.size.height/2 - 10-cell.productName.frame.size.height, diff - margin * 2, cell.productName.frame.size.height);
                                [cell.productName setLineBreakMode:NSLineBreakByWordWrapping];
                                [cell.productName setTextAlignment:NSTextAlignmentCenter];
                                [cell.productName setNumberOfLines:2];
                                [cell.productName sizeToFitUI];
                                
                                cell.productImg.frame = CGRectMake(diff, 0, diff, cell.frame.size.height);
                                cell.productImgDummy.frame = CGRectMake(diff, 0, diff, cell.frame.size.height);
                                cell.imgHeaderBg.frame = CGRectMake(0, 0, diff, cell.frame.size.height);
                                cell.productName.frame = CGRectMake(margin, cell.frame.size.height/2 - 10-cell.productName.frame.size.height, diff - margin * 2, cell.productName.frame.size.height);
                                cell.labelExploreNow.frame = CGRectMake(0 + cell.frame.size.width * .125f, cell.frame.size.height/2 + 10, cell.frame.size.width * .25f, cell.frame.size.height * .125f);
                            } else {
                                cell.productImg.translatesAutoresizingMaskIntoConstraints = YES;
                                cell.productImgDummy.translatesAutoresizingMaskIntoConstraints = YES;
                                cell.productName.translatesAutoresizingMaskIntoConstraints = YES;
                                cell.labelExploreNow.translatesAutoresizingMaskIntoConstraints = YES;
                                cell.imgHeaderBg.translatesAutoresizingMaskIntoConstraints = YES;
                                CGRect cellFrame = cell.frame;
                                int diff = cellFrame.size.width/2;
                                int margin = 5;
                                [cell.productName sizeToFitUI];
                                cell.productName.frame = CGRectMake(diff + margin, cell.frame.size.height/2 - 10 - cell.productName.frame.size.height, diff - margin * 2, cell.productName.frame.size.height);
                                [cell.productName setLineBreakMode:NSLineBreakByWordWrapping];
                                [cell.productName setTextAlignment:NSTextAlignmentCenter];
                                [cell.productName setNumberOfLines:2];
                                [cell.productName sizeToFitUI];
                                
                                cell.productImg.frame = CGRectMake(0, 0, diff, cell.frame.size.height);
                                cell.productImgDummy.frame = CGRectMake(0, 0, diff, cell.frame.size.height);
                                cell.imgHeaderBg.frame = CGRectMake(diff, 0, diff, cell.frame.size.height);
                                cell.productName.frame = CGRectMake(diff + margin, cell.frame.size.height/2 - 10-cell.productName.frame.size.height, diff - margin * 2, cell.productName.frame.size.height);
                                cell.labelExploreNow.frame = CGRectMake(diff + cell.frame.size.width * .125f, cell.frame.size.height/2 + 10, cell.frame.size.width * .25f, cell.frame.size.height * .125f);
                            }
                            cell.labelExploreNow.backgroundColor = [Utility getUIColor:kUIColorBuyButtonNormalBg];
                            cell.labelExploreNow.textColor = [Utility getUIColor:kUIColorBuyButtonFont];
                            [cell.labelExploreNow setUIFont:kUIFontType14 isBold:true];
                            cell.labelExploreNow.text = Localize(@"explore_now");
                            [cell setNeedsLayout];
                            [cell layoutSubviews];
                            break;
                        case C_LAYOUT_FULL:
                            
                            break;
                            
                        default:
                            break;
                    }
                    
                    
                } else {
                    
                }
            }
            
        } break;
        case _kShowAllItems:
        {
            cell = [[Utility sharedManager]setProductCellDataCategoryScreen:collectionView
                                                                       cell:cell
                                                                  indexPath:indexPath
                                                                 isCategory:_currentItem.isCategory
                                                                 childCount:[self getChildCount]
                                                          showFilterdResult:self.showFilterdResult
                                                                      cInfo:_currentItem.cInfo nibName:_strCollectionView1
                                                                     target:self
                                                                 dataSource:[ProductInfo getOnlyForCategory:_currentItem.cInfo
                                                                                         showFilterProducts:self.showFilterdResult]
                                                          appliedUserFilter:_userFilter];

            if (1) {
                float mxH = _propCollectionView[i]._height;
                float height = collectionView.collectionViewLayout.collectionViewContentSize.height;
                _propCollectionView[i]._height = height + 20;//MAX(_propCollectionView[i]._height, collectionView.frame.origin.y + height);
                if (mxH < _propCollectionView[i]._height) {
                    CGRect r = _viewUserDefined[i].frame;
                    r.size.height = _propCollectionView[i]._height;
                    [_viewUserDefined[i] setFrame:r];
                    [self resetMainScrollView];
                }
            }
            if (cell == nil) {
                return nil;
            }
        }
            /*{
             RLOG(@"====***====CELL FOR ITEM AT INDEX PATH = %d", (int)indexPath.row);
             if (_currentItem.isCategory && [self getChildCount] > 0) {
             if(cell == nil) {
             NSArray *nib = [[ NSBundle mainBundle] loadNibNamed:_strCollectionView1 owner:self options:nil];
             cell = [nib objectAtIndex:0];
             }
             if ([[DataManager sharedManager] layoutIdProductView] == P_LAYOUT_ZIGZAG || [[DataManager sharedManager] layoutIdProductView] == P_LAYOUT_GROCERY) {
             cell.layer.shadowOpacity = 0.0f;
             } else {
             [Utility showShadow:cell];
             }
             
             [[cell productName] setUIFont:kUIFontType16 isBold:false];
             [[cell productName] setTextColor:[Utility getUIColor:kUIColorFontDark]];
             [[cell productPriceOriginal] setUIFont:kUIFontType14 isBold:false];
             [[cell productPriceFinal] setUIFont:kUIFontType14 isBold:false];
             if ([[TMLanguage sharedManager] isRTLEnabled]) {
             [[cell productName] setTextAlignment:NSTextAlignmentRight];
             [[cell productPriceOriginal] setTextAlignment:NSTextAlignmentRight];
             [[cell productPriceFinal] setTextAlignment:NSTextAlignmentRight];
             }
             
             ProductInfo *pInfo = nil;
             
             #if PROMO_ENABLE_IN_SHOW_ALL_VIEWS
             if (indexPath.row >= [self getChildCount] && [[DataManager sharedManager] promoEnable]) {
             [[cell productName] setText:@""];
             [[cell productPriceOriginal] setText:@""];
             [[cell buttonWishlist] setHidden:true];
             [[cell buttonCart] setHidden:true];
             [[cell productPriceFinal] setText:@""];
             if ([[DataManager sharedManager] layoutIdProductView] == P_LAYOUT_ZIGZAG) {
             [Utility setImageNew:cell.productImg url:[[DataManager sharedManager] promoUrlImgPath] resizeType:kRESIZE_TYPE_PRODUCT_THUMBNAIL highPriority:true parentCell:cell collectionViewLayout:[collectionView collectionViewLayout] collectionView:collectionView component:indexPath.row indexpath:indexPath vc:self];
             [Utility showShadow:cell];
             }
             else if ([[DataManager sharedManager] layoutIdProductView] == P_LAYOUT_GROCERY) {
             cell.layer.shadowOpacity = 0.0f;
             [Utility showShadow:cell];
             } else {
             [Utility setImage:cell.productImg url:[[DataManager sharedManager] promoUrlImgPath] resizeType:kRESIZE_TYPE_PRODUCT_THUMBNAIL isLocal:false];
             }
             UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(promoTapped:)];
             singleTap.numberOfTapsRequired = 1;
             singleTap.numberOfTouchesRequired = 1;
             [cell.productImg addGestureRecognizer:singleTap];
             [cell.productImg setUserInteractionEnabled:YES];
             } else
             #endif
             {
             if ([[ProductInfo getOnlyForCategory:_currentItem.cInfo showFilterProducts:self.showFilterdResult] count] > indexPath.row) {
             pInfo = (ProductInfo *)[[ProductInfo getOnlyForCategory:_currentItem.cInfo showFilterProducts:self.showFilterdResult] objectAtIndex:indexPath.row];
             if (pInfo == nil) {
             return nil;
             }
             }
             [[cell productName] setText:pInfo._titleForOuterView];
             if ([[DataManager sharedManager] layoutIdProductView] == P_LAYOUT_GROCERY) {
             CGRect pNFrame = cell.productName.frame;
             [[cell productName] setNumberOfLines:0];
             [[cell productName] sizeToFitUI];
             if (cell.productName.frame.size.height < pNFrame.size.height) {
             cell.productName.frame = pNFrame;
             }
             }
             [[cell productPriceOriginal] setAttributedText:[pInfo getPriceOldString]];
             [[cell productPriceFinal] setText:[pInfo getPriceNewString]];
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
             if ([[DataManager sharedManager] layoutIdProductView] == P_LAYOUT_ZIGZAG) {
             [Utility setImageNew:cell.productImg url:pImage._src resizeType:kRESIZE_TYPE_PRODUCT_THUMBNAIL highPriority:true parentCell:cell collectionViewLayout:[collectionView collectionViewLayout] collectionView:collectionView component:indexPath.row indexpath:indexPath vc:self];
             cell.layer.shadowOpacity = 0.0f;
             [Utility showShadow:cell];
             } else if ([[DataManager sharedManager] layoutIdProductView] == P_LAYOUT_GROCERY) {
             cell.layer.shadowOpacity = 0.0f;
             [Utility showShadow:cell];
             } else {
             if ([[DataManager sharedManager] layoutIdProductView] == P_LAYOUT_GROCERY || [[DataManager sharedManager] layoutIdProductView] == P_LAYOUT_DISCOUNT) {
             
             } else {
             [Utility setImage:cell.productImg url:pImage._src resizeType:kRESIZE_TYPE_PRODUCT_THUMBNAIL isLocal:false];
             }
             }
             if ([cell buttonWishlist].imageView.image.renderingMode != UIImageRenderingModeAlwaysTemplate) {
             UIImage* normal = [[UIImage imageNamed:@"wishlist_icon_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
             UIImage* selected = [[UIImage imageNamed:@"wishlist_icon_pressed"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
             [[cell buttonWishlist] setUIImage:normal forState:UIControlStateNormal];
             [[cell buttonWishlist] setUIImage:selected forState:UIControlStateSelected];
             }
             [[cell buttonWishlist] addTarget:[Utility sharedManager] action:@selector(wishlistButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
             [[cell buttonWishlist] setTag:pInfo._id];
             [[Utility sharedManager] initWishlistButton:[cell buttonWishlist]];
             
             if ([[DataManager sharedManager] layoutIdProductView] == P_LAYOUT_GROCERY ||
             [[DataManager sharedManager] layoutIdProductView] == P_LAYOUT_DISCOUNT) {
             if ([cell.layer valueForKey:@"UITapGestureRecognizer"]) {
             [cell removeGestureRecognizer:((UITapGestureRecognizer*)[cell.layer valueForKey:@"UITapGestureRecognizer"])];
             }
             [cell setTag:pInfo._id];
             UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bannerTapped:)];
             singleTap.numberOfTapsRequired = 1;
             singleTap.numberOfTouchesRequired = 1;
             [cell addGestureRecognizer:singleTap];
             [singleTap.view.layer setValue:cell forKey:@"CELL_OBJ"];
             [cell setUserInteractionEnabled:YES];
             [cell.layer setValue:singleTap forKey:@"UITapGestureRecognizer"];
             [cell.layer setValue:pInfo._titleForOuterView forKey:@"PNAME"];
             } else {
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
             }
             
             if ([cell buttonAdd].imageView.image.renderingMode != UIImageRenderingModeAlwaysTemplate) {
             UIImage* normal = [[UIImage imageNamed:@"button_circle"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
             [cell.buttonAdd setBackgroundImage:normal forState:UIControlStateNormal];
             }
             if ([cell buttonSubstract].imageView.image.renderingMode != UIImageRenderingModeAlwaysTemplate) {
             UIImage* normal = [[UIImage imageNamed:@"button_circle"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
             [cell.buttonSubstract setBackgroundImage:normal forState:UIControlStateNormal];
             }
             
             }
             if (pInfo) {
             pInfo.cellObj = cell;
             if ([[DataManager sharedManager] layoutIdProductView] == P_LAYOUT_DISCOUNT){
             if (ENABLE_DISCOUNT_LAYOUT_TYPE1) {
             [cell.labelProductDescription setNumberOfLines:0];
             }
             
             [cell.labelProductDescription setText:[[pInfo getDescriptionAttributedString] string]];
             UIImage* discountBG = [[UIImage imageNamed:@"button_circle"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
             [cell.imgDiscountBg setImage:discountBG];
             [cell.imgDiscountBg setTintColor:[Utility getUIColor:kUIColorBuyButtonFont]];
             [cell.labelDiscount setTextColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
             [cell.imgDiscountBg.layer setBorderColor:[Utility getUIColor:kUIColorBuyButtonNormalBg].CGColor];
             [cell.imgDiscountBg.layer setBorderWidth:1];
             cell.imgDiscountBg.layer.cornerRadius = cell.imgDiscountBg.frame.size.height/2.0;
             if ([[MyDevice sharedManager] isIpad]) {
             cell.imgDiscountBg.layer.cornerRadius = 70/2.0;
             } else {
             cell.imgDiscountBg.layer.cornerRadius = 50/2.0;
             }
             
             [cell.labelDiscount setUIFont:kUIFontType20 isBold:false];
             [cell.productPriceOriginal setUIFont:kUIFontType16 isBold:false];
             [cell.productPriceFinal setUIFont:kUIFontType16 isBold:false];
             [cell.labelDiscount setUIFont:kUIFontType18 isBold:true];
             [cell.productName setUIFont:kUIFontType18 isBold:true];
             [cell.labelProductDescription setUIFont:kUIFontType16 isBold:false];
             [cell.productName setTintColor:[Utility getUIColor:kUIColorBlue]];
             float discountPercent = [pInfo getDiscountPercent:-1];
             if (discountPercent == 0.0f)
             {
             [cell.imgDiscountBg setHidden:true];
             [cell.labelDiscount setHidden:true];
             } else {
             [cell.imgDiscountBg setHidden:false];
             [cell.labelDiscount setHidden:false];
             [cell.labelDiscount setText:[NSString stringWithFormat:@"%d%% %@", (int)discountPercent, Localize(@"off")]];
             }
             if (ENABLE_DISCOUNT_LAYOUT_TYPE1) {
             pInfo.cellObj = cell;
             [cell.labelProductDescription sizeToFitUI];
             if(cell.btnShowMore){
             cell.btnShowMore.hidden = true;
             CGRect btnShowMoreRect = cell.btnShowMore.frame;
             btnShowMoreRect.size.height = 0;
             cell.btnShowMore.frame = btnShowMoreRect;
             }
             }
             if(cell.btnShowMore){
             [cell.btnShowMore removeTarget:self action:@selector(showMoreClicked:) forControlEvents:UIControlEventTouchUpInside];
             [cell.btnShowMore addTarget:self action:@selector(showMoreClicked:) forControlEvents:UIControlEventTouchUpInside];
             [cell.btnShowMore setTag:pInfo._id];
             }
             }
             
             [cell.layer setValue:self forKey:@"VC"];
             [cell.layer setValue:pInfo forKey:@"PRODUCT_INFO"];
             [cell.layer setValue:pInfo forKey:@"PINFO_OBJ"];
             [cell.buttonAdd.layer setValue:pInfo forKey:@"PINFO_OBJ"];
             [cell.buttonAdd.layer setValue:cell forKey:@"CELL_OBJ"];
             [cell.buttonCart.layer setValue:pInfo forKey:@"PINFO_OBJ"];
             [cell.buttonCart setTitle:Localize(@"toggle_cart_on") forState:UIControlStateNormal];
             [cell.buttonCart.layer setValue:cell forKey:@"CELL_OBJ"];
             [cell.buttonSubstract.layer setValue:pInfo forKey:@"PINFO_OBJ"];
             [cell.buttonSubstract.layer setValue:cell forKey:@"CELL_OBJ"];
             [cell.textFieldAmt.layer setValue:pInfo forKey:@"PINFO_OBJ"];
             [cell.textFieldAmt.layer setValue:cell forKey:@"CELL_OBJ"];
             [cell.buttonCart addTarget:self action:@selector(cartButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
             [cell.buttonAdd addTarget:self action:@selector(addButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
             [cell.buttonSubstract addTarget:self action:@selector(substractButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
             }else {
             [cell.layer setValue:nil forKey:@"PRODUCT_INFO"];
             [cell.layer setValue:nil forKey:@"PINFO_OBJ"];
             }
             
             
             switch ([[DataManager sharedManager] layoutIdProductView]) {
             case P_LAYOUT_DEFAULT:
             break;
             case P_LAYOUT_FULL_ICON_BUTTON:
             break;
             case P_LAYOUT_GROCERY:
             {
             if (cell.buttonCart.imageView.image.renderingMode != UIImageRenderingModeAlwaysTemplate) {
             UIImage* normal = [[UIImage imageNamed:@"button_square"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
             [cell.buttonCart setBackgroundImage:normal forState:UIControlStateNormal];
             [cell.buttonCart setShowsTouchWhenHighlighted:true];
             }
             if ([cell buttonAdd].imageView.image.renderingMode != UIImageRenderingModeAlwaysTemplate) {
             UIImage* normal = [[UIImage imageNamed:@"button_square"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
             [cell.buttonAdd setBackgroundImage:normal forState:UIControlStateNormal];
             [cell.buttonAdd setShowsTouchWhenHighlighted:true];
             }
             if ([cell buttonSubstract].imageView.image.renderingMode != UIImageRenderingModeAlwaysTemplate) {
             UIImage* normal = [[UIImage imageNamed:@"button_square"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
             [cell.buttonSubstract setBackgroundImage:normal forState:UIControlStateNormal];
             }
             
             cell.backgroundColor = [UIColor whiteColor];
             cell.productImg.hidden = true;
             cell.productImgDummy.hidden = true;
             cell.productPriceOriginal.hidden = true;
             cell.buttonWishlist.hidden = true;
             cell.buttonWishlist.enabled = false;
             cell.productPriceFinal.hidden = false;
             cell.productName.hidden = false;
             cell.buttonCart.hidden = false;
             cell.buttonCart.enabled = true;
             [cell.buttonCart setTitle:@"+" forState:UIControlStateNormal];
             cell.viewAddToCart.backgroundColor = [UIColor clearColor];
             [cell.buttonCart.imageView setContentMode:UIViewContentModeScaleAspectFit];
             [cell.buttonAdd.imageView setContentMode:UIViewContentModeScaleAspectFit];
             [cell.buttonCart setContentMode:UIViewContentModeScaleAspectFit];
             [cell.buttonAdd setContentMode:UIViewContentModeScaleAspectFit];
             
             
             
             float oldHeight = cell.frame.size.height;
             float newHeight = MAX(75, cell.productName.frame.size.height + 20);
             {
             CGRect cellRect = cell.frame;
             cellRect.size.height = newHeight;
             if ([[MyDevice sharedManager] isLandscape]) {
             pInfo.updatedCardSizeL = cellRect.size;
             } else {
             pInfo.updatedCardSizeP = cellRect.size;
             }
             cell.frame = cellRect;
             cell.layer.shadowOpacity = 0.0f;
             [Utility showShadow:cell];
             }
             [collectionView.collectionViewLayout invalidateLayout];
             [collectionView layoutIfNeeded];
             }break;
             case P_LAYOUT_DISCOUNT:
             {
             if (cell.buttonCart.imageView.image.renderingMode != UIImageRenderingModeAlwaysTemplate) {
             UIImage* normal = [[UIImage imageNamed:@"button_square"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
             [cell.buttonCart setBackgroundImage:normal forState:UIControlStateNormal];
             [cell.buttonCart setShowsTouchWhenHighlighted:true];
             }
             if ([cell buttonAdd].imageView.image.renderingMode != UIImageRenderingModeAlwaysTemplate) {
             UIImage* normal = [[UIImage imageNamed:@"button_square"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
             [cell.buttonAdd setBackgroundImage:normal forState:UIControlStateNormal];
             [cell.buttonAdd setShowsTouchWhenHighlighted:true];
             }
             if ([cell buttonSubstract].imageView.image.renderingMode != UIImageRenderingModeAlwaysTemplate) {
             UIImage* normal = [[UIImage imageNamed:@"button_square"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
             [cell.buttonSubstract setBackgroundImage:normal forState:UIControlStateNormal];
             }
             
             cell.backgroundColor = [UIColor whiteColor];
             cell.productImg.hidden = true;
             cell.productImgDummy.hidden = true;
             cell.productPriceOriginal.hidden = true;
             cell.buttonWishlist.hidden = true;
             cell.buttonWishlist.enabled = false;
             cell.productPriceFinal.hidden = false;
             cell.productName.hidden = false;
             cell.buttonCart.hidden = false;
             cell.buttonCart.enabled = true;
             [cell.buttonCart setTitle:@"+" forState:UIControlStateNormal];
             cell.viewAddToCart.backgroundColor = [UIColor clearColor];
             [cell.buttonCart.imageView setContentMode:UIViewContentModeScaleAspectFit];
             [cell.buttonAdd.imageView setContentMode:UIViewContentModeScaleAspectFit];
             [cell.buttonCart setContentMode:UIViewContentModeScaleAspectFit];
             [cell.buttonAdd setContentMode:UIViewContentModeScaleAspectFit];
             if (ENABLE_DISCOUNT_LAYOUT_TYPE1) {
             float newHeight = 10 + cell.productName.frame.size.height + 10 + cell.labelProductDescription.frame.size.height + 0 + cell.btnShowMore.frame.size.height + 10 + cell.imgDiscountBg.frame.size.height + 10;
             CGRect cellRect = cell.frame;
             cellRect.size.height = newHeight;
             if ([[MyDevice sharedManager] isLandscape]) {
             pInfo.updatedCardSizeL = cellRect.size;
             } else {
             pInfo.updatedCardSizeP = cellRect.size;
             }
             cell.frame = cellRect;
             cell.layer.shadowOpacity = 0.0f;
             [Utility showShadow:cell];
             [collectionView.collectionViewLayout invalidateLayout];
             [collectionView layoutIfNeeded];
             }
             }
             break;
             case P_LAYOUT_FULL_RECT_BUTTON:
             [cell.buttonWishlist setImage:nil forState:UIControlStateNormal];
             [cell.buttonWishlist setImage:nil forState:UIControlStateSelected];
             [cell.buttonWishlist setImage:nil forState:UIControlStateHighlighted];
             
             cell.buttonWishlist.backgroundColor = [Utility getUIColor:kUIColorBuyButtonNormalBg];
             [cell.buttonWishlist.titleLabel setTextColor:[Utility getUIColor:kUIColorBuyButtonFont]];
             if ([[MyDevice sharedManager] isIpad]) {
             [cell.buttonWishlist.titleLabel setUIFont:kUIFontType14 isBold:false];
             }else{
             [cell.buttonWishlist.titleLabel setUIFont:kUIFontType14 isBold:true];
             }
             [cell.buttonWishlist.titleLabel setTextAlignment:NSTextAlignmentCenter];
             [cell.buttonWishlist setAttributedTitle:[[NSAttributedString alloc] initWithString:Localize(@"toggle_wishlist_on")] forState:UIControlStateNormal];
             [cell.buttonWishlist setAttributedTitle:[[NSAttributedString alloc] initWithString:Localize(@"toggle_wishlist_off")] forState:UIControlStateSelected];
             
             break;
             case P_LAYOUT_ZIGZAG:
             break;
             default:
             break;
             }
             }
             }*/
            break;
        case _kTrending:
        case _kMaxSold:
        case _kNew:
        case _kDiscount:
        case _kUserDefined1:
        case _kUserDefined2:
        case _kUserDefined3:
        case _kUserDefined4:
        case _kUserDefined5:
        {
            if(cell == nil) {
                NSArray *nib = [[ NSBundle mainBundle] loadNibNamed:_strCollectionView3 owner:self options:nil];
                cell = [nib objectAtIndex:0];
            }
            [cell setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
            [[cell productName] setUIFont:kUIFontType16 isBold:false];
            [[cell productName] setTextColor:[Utility getUIColor:kUIColorFontDark]];
            [[cell productPriceOriginal] setUIFont:kUIFontType14 isBold:false];
            [[cell productPriceFinal] setUIFont:kUIFontType14 isBold:false];
            if ([[TMLanguage sharedManager] isRTLEnabled]) {
                [[cell productName] setTextAlignment:NSTextAlignmentRight];
                [[cell productPriceOriginal] setTextAlignment:NSTextAlignmentRight];
                [[cell productPriceFinal] setTextAlignment:NSTextAlignmentRight];
            }
            
#if PROMO_ENABLE_IN_HORIZONTAL_VIEWS
            if (indexPath.row >= (int)[[ProductInfo getProductsForCategory:_currentItem.cInfo keyString:_viewKey[i] isAscending:YES viewType:i-_kTrending] count] && [[DataManager sharedManager] promoEnable]) {
                [[cell productName] setText:@""];
                [[cell productPriceOriginal] setText:@""];
                [[cell buttonWishlist]setHidden:true];
                [[cell productPriceFinal] setText:@""];
                [Utility setImage:cell.productImg url:[[DataManager sharedManager] promoUrlImgPath]];
                UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(promoTapped:)];
                singleTap.numberOfTapsRequired = 1;
                singleTap.numberOfTouchesRequired = 1;
                [cell.productImg addGestureRecognizer:singleTap];
                [cell.productImg setUserInteractionEnabled:YES];
            }else
#endif
                
            {
                ProductInfo *pInfo = (ProductInfo*) ([[ProductInfo getProductsForCategory:_currentItem.cInfo keyString:_viewKey[i] isAscending:YES viewType:i-_kTrending] objectAtIndex:indexPath.row]);
                if ([pInfo._images count] == 0) {
                    [pInfo._images addObject:[[ProductImage alloc] init]];
                }
                ProductImage *pImage = [pInfo._images objectAtIndex:0];
                [[cell productName] setText:[NSString stringWithFormat:@"%@",pInfo._titleForOuterView]];
                
                /////////////////
                BOOL isDiscounted = [pInfo isProductDiscounted:-1];
                float newPrice = [pInfo getNewPrice:-1];
                float oldPrice = [pInfo getOldPrice:-1];
                
                if (isDiscounted) {
                    [[cell productPriceOriginal] setAttributedText:[[Utility sharedManager] convertToStringStrikethrough:oldPrice isCurrency:true]];
                }else {
                    [[cell productPriceOriginal] setText:@"   "];
                }
                [[cell productPriceFinal] setText:[[Utility sharedManager] convertToString:newPrice isCurrency:true]];
                /////////////////
                
                [Utility setImage:cell.productImg url:pImage._src resizeType:kRESIZE_TYPE_PRODUCT_THUMBNAIL isLocal:false];
                
                if ([cell buttonWishlist].imageView.image.renderingMode != UIImageRenderingModeAlwaysTemplate) {
                    UIImage* normal = [[UIImage imageNamed:@"wishlist_icon_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                    UIImage* selected = [[UIImage imageNamed:@"wishlist_icon_pressed"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                    [[cell buttonWishlist] setUIImage:normal forState:UIControlStateNormal];
                    [[cell buttonWishlist] setUIImage:selected forState:UIControlStateSelected];
                }
                [[cell buttonWishlist] addTarget:[Utility sharedManager] action:@selector(wishlistButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                [[cell buttonWishlist] setTag:pInfo._id];
                [[Utility sharedManager] initWishlistButton:[cell buttonWishlist]];
                [cell.productImg setTag:pInfo._id];
                UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bannerTapped:)];
                singleTap.numberOfTapsRequired = 1;
                singleTap.numberOfTouchesRequired = 1;
                [cell.productImg addGestureRecognizer:singleTap];
                [singleTap.view.layer setValue:cell forKey:@"CELL_OBJ"];
                [cell.productImg setUserInteractionEnabled:YES];
            }
        }break;
        default:
            break;
    }
    [cell setNeedsLayout];
    return cell;
}
- (void)showMoreClicked:(UIButton*)button {
    int productId = (int)[button tag];
    ProductInfo* pInfo = [ProductInfo getProductWithId:productId];
    if (pInfo) {
        [self clickOnProduct:pInfo currentItemData:nil cell:nil];
    }
    
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    int i = 0;
    for (; i < _kTotalViewsHomeScreen; i++) {
        if(_viewUserDefined[i] == collectionView){
            break;
        }
    }
    NSMutableArray *array = nil;
    switch (i) {
        case _kCategoryBasic:
        {
            array = [LayoutProperties CardPropertiesForCategoryView];
            float cardHorizontalSpacing = [[array objectAtIndex:0] floatValue];
            float cardVerticalSpacing = [[array objectAtIndex:1] floatValue];
            float cardWidth = [[array objectAtIndex:2] floatValue];
            float cardHeight = [[array objectAtIndex:3] floatValue];
            float insetLeft = [[array objectAtIndex:4] floatValue];
            float insetRight = [[array objectAtIndex:5] floatValue];
            float insetTop = [[array objectAtIndex:6] floatValue];
            float insetBottom = [[array objectAtIndex:7] floatValue];
            collectionView.contentInset = UIEdgeInsetsMake(insetTop, insetLeft, insetBottom, insetRight);
            UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)[collectionView collectionViewLayout];
            layout.minimumInteritemSpacing = cardHorizontalSpacing;
            layout.minimumLineSpacing = cardVerticalSpacing;
            
            _propCollectionView[i]._insetTop =  insetTop;
            _propCollectionView[i]._insetLeft =  insetLeft;
            _propCollectionView[i]._insetBottom =  insetBottom;
            _propCollectionView[i]._insetRight =  insetRight;
            //            PRINT_RECT([_propCollectionView[i] getFrameRect]);
            //            PRINT_SIZE( CGSizeMake(cardWidth, cardHeight));
            return CGSizeMake(cardWidth, cardHeight);
        } break;
        case _kShowAllItems:{
            CGSize size = [[Utility sharedManager] getProductCellSizeCategoryScreen:collectionView indexPath:indexPath propCollectionView:_propCollectionView[i] showFilterdResult:self.showFilterdResult cInfo:_currentItem.cInfo dataSource:[ProductInfo getOnlyForCategory:_currentItem.cInfo showFilterProducts:self.showFilterdResult]];
            return size;
            /*{
             RLOG(@"====***====SIZE FOR ITEM AT INDEX PATH = %d", (int)indexPath.row);
             array = [LayoutProperties CardPropertiesForProductView];
             float cardHorizontalSpacing = [[array objectAtIndex:0] floatValue];
             float cardVerticalSpacing = [[array objectAtIndex:1] floatValue];
             float cardWidth = [[array objectAtIndex:2] floatValue];
             float cardHeight = [[array objectAtIndex:3] floatValue];
             float insetLeft = [[array objectAtIndex:4] floatValue];
             float insetRight = [[array objectAtIndex:5] floatValue];
             float insetTop = [[array objectAtIndex:6] floatValue];
             float insetBottom = [[array objectAtIndex:7] floatValue];
             collectionView.contentInset = UIEdgeInsetsMake(insetTop, insetLeft, insetBottom, insetRight);
             
             if ([[DataManager sharedManager] layoutIdProductView] == P_LAYOUT_ZIGZAG ||
             [[DataManager sharedManager] layoutIdProductView] == P_LAYOUT_GROCERY) {
             CHTCollectionViewWaterfallLayout *layout = (CHTCollectionViewWaterfallLayout *)[collectionView collectionViewLayout];
             [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
             [layout setMinimumColumnSpacing:cardHorizontalSpacing];
             [layout setMinimumInteritemSpacing:cardVerticalSpacing];
             _propCollectionView[i]._insetTop = insetTop;
             _propCollectionView[i]._insetLeft = 0;
             _propCollectionView[i]._insetBottom = insetBottom;
             _propCollectionView[i]._insetRight = 0;
             } else {
             UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)[collectionView collectionViewLayout];
             layout.minimumInteritemSpacing = cardHorizontalSpacing;
             layout.minimumLineSpacing = cardVerticalSpacing;
             _propCollectionView[i]._insetTop =  insetTop;
             _propCollectionView[i]._insetLeft =  insetLeft;
             _propCollectionView[i]._insetBottom =  insetBottom;
             _propCollectionView[i]._insetRight =  insetRight;
             }
             
             CGSize cardSize = CGSizeMake(cardWidth, cardHeight);
             
             BOOL isCardSizeUpdated = false;
             if ([[DataManager sharedManager] layoutIdProductView] == P_LAYOUT_ZIGZAG ||
             [[DataManager sharedManager] layoutIdProductView] == P_LAYOUT_GROCERY ) {
             if ((int)[[ProductInfo getOnlyForCategory:_currentItem.cInfo showFilterProducts:self.showFilterdResult] count] >indexPath.row) {
             ProductInfo *pInfo = (ProductInfo *)[[ProductInfo getOnlyForCategory:_currentItem.cInfo showFilterProducts:self.showFilterdResult] objectAtIndex:indexPath.row];
             if (pInfo) {
             if ([[MyDevice sharedManager] isLandscape]) {
             if (pInfo.updatedCardSizeL.width != 0 ) {
             cardSize = pInfo.updatedCardSizeL;
             isCardSizeUpdated = true;
             }
             } else {
             if (pInfo.updatedCardSizeP.width != 0 ) {
             cardSize = pInfo.updatedCardSizeP;
             isCardSizeUpdated = true;
             }
             }
             }
             }
             }
             if ([[DataManager sharedManager] layoutIdProductView] == P_LAYOUT_DISCOUNT) {
             if (ENABLE_DISCOUNT_LAYOUT_TYPE1) {
             if ((int)[[ProductInfo getOnlyForCategory:_currentItem.cInfo showFilterProducts:self.showFilterdResult] count] >indexPath.row) {
             ProductInfo *pInfo = (ProductInfo *)[[ProductInfo getOnlyForCategory:_currentItem.cInfo showFilterProducts:self.showFilterdResult] objectAtIndex:indexPath.row];
             if (pInfo) {
             CCollectionViewCell *cell=(CCollectionViewCell *)(pInfo.cellObj);
             if(cell) {
             float newHeight = 10 + cell.productName.frame.size.height + 10 + cell.labelProductDescription.frame.size.height + 0 + cell.btnShowMore.frame.size.height + 10 + cell.imgDiscountBg.frame.size.height + 10;
             CGRect cellRect = cell.frame;
             cellRect.size.height = newHeight;
             cell.frame = cellRect;
             cell.layer.shadowOpacity = 0.0f;
             [Utility showShadow:cell];
             cardSize = cell.frame.size;
             }
             }
             }
             }
             }
             
             if ([[DataManager sharedManager] layoutIdProductView] == P_LAYOUT_ZIGZAG ||
             [[DataManager sharedManager] layoutIdProductView] == P_LAYOUT_GROCERY) {
             if(isCardSizeUpdated)
             {
             CCollectionViewCell *cell=(CCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
             if (cell) {
             cell.layer.shadowOpacity = 0.0f;
             [Utility showShadow:cell];
             }
             }
             }
             return cardSize;
             }*/
        }break;
        case _kTrending:
        case _kMaxSold:
        case _kNew:
        case _kDiscount:
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
            
            //            collectionView.contentInset = UIEdgeInsetsMake(insetTop, insetLeft, insetBottom, insetRight);
            
            _propCollectionView[i]._insetTop =  insetTop;
            _propCollectionView[i]._insetLeft =  insetLeft;
            _propCollectionView[i]._insetBottom =  insetBottom;
            _propCollectionView[i]._insetRight =  insetRight;
            
            _propCollectionView[i]._height = cardHeight + _viewUserDefined[i].contentInset.top + _viewUserDefined[i].contentInset.bottom;
            [_viewUserDefined[i] setFrame:[_propCollectionView[i] getFrameRect]];
            //            [self resetMainScrollView];
            
            return CGSizeMake(cardWidth, cardHeight);
            
        }break;
        case _kUserDefined1:
        {
            
        }break;
        case _kUserDefined2:
        {
            
        }break;
        case _kUserDefined3:
        {
            
        }break;
        case _kUserDefined4:
        {
            
        }break;
        case _kUserDefined5:
        {
            
        }break;
            
        default:
            break;
    }
    return CGSizeMake(0, 0);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    int i = 0;
    for (; i < _kTotalViewsHomeScreen; i++) {
        if(_viewUserDefined[i] == collectionView){
            break;
        }
    }
    switch (i) {
        case _kCategoryBasic:
        {
            CategoryInfo *cInfo = (CategoryInfo*) ([[_currentItem.cInfo getSubCategories] objectAtIndex:indexPath.row]);
            [self clickOnCategory:cInfo currentItemData:_currentItem];
        } break;
        case _kShowAllItems:
            break;
        case _kTrending:
        case _kMaxSold:
        case _kNew:
        case _kDiscount:
        case _kUserDefined1:
        case _kUserDefined2:
        case _kUserDefined3:
        case _kUserDefined4:
        case _kUserDefined5:
            break;
        default:
            break;
    }
}
- (BOOL)updateStuff{
    if ([[Addons sharedManager] multiVendor] && [[[Addons sharedManager] multiVendor] isEnabled] && [[Addons sharedManager] multiVendor_screen_type] == MULTIVENDOR_SCREEN_PRODUCT) {
        [[[DataManager sharedManager] tmDataDoctor] getProductsOfCategory:_currentItem.cInfo._id offset:_currentItem.cInfo.pageCount * 100  productLimit:100 success:^(id data) {
            _currentItem.cInfo.pageCount = _currentItem.cInfo.pageCount + 1;
            NSLog(@"fetchCategoryProductsFast:success");
            RLOG(@"Load kFetchMoreProduct CATEGORY SCREEN:%@", self);
            if (_pageLoading) {
                int childRC = [_currentItem.cInfo getChildRetrievedCount];
                _pageLoading = false;
                _currentItem.childCount = childRC;
                if ([[DataManager sharedManager] layoutIdProductView] == P_LAYOUT_DISCOUNT) {
                    if (ENABLE_DISCOUNT_LAYOUT_TYPE1) {
                        if ([[ProductInfo getOnlyForCategory:_currentItem.cInfo showFilterProducts:self.showFilterdResult] count] > 0) {
                            for (ProductInfo* pInfo in [ProductInfo getOnlyForCategory:_currentItem.cInfo showFilterProducts:self.showFilterdResult]) {
                                pInfo.cellObj = nil;
                            }
                        }
                    }
                }
                [_viewUserDefined[_kShowAllItems] reloadData];
#if CATEGORY_VIEW_NEW_HACK_ENABLE
#else
                _scrollViewBase.scrollEnabled = true;
                _scrollViewChild.scrollEnabled  = true;
                _permanentScrollSet = false;
                [self scrollViewDidScroll:_scrollView];
#endif
                [self stopLoadingAnim];
            }
        } failure:^(NSString *error) {
            NSLog(@"fetchCategoryProductsFast:failure");
            [self stopLoadingAnim];
        }];
        return true;
    }
    
    return [_currentItem.cInfo loadMoreProducts];
}
-(void)checkAndLoadNextPage {
    BOOL shouldLoadNextPage = ShouldLoadNextPageScrollView(_viewUserDefined[_kShowAllItems]);
    int childRC = [_currentItem.cInfo getChildRetrievedCount];
    if ((shouldLoadNextPage && !_pageLoading) ||( childRC == 0 && !_pageLoading)) {
        _pageLoading = true;
        if ([self updateStuff]) {
            [self startLoadingAnim];
        }
    }
}
-(void)checkAndLoadNextPageForced {
    BOOL shouldLoadNextPage = true;
    int childRC = [_currentItem.cInfo getChildRetrievedCount];
    if ((shouldLoadNextPage && !_pageLoading) ||( childRC == 0 && !_pageLoading))
    {
        _pageLoading = true;
        if ([self updateStuff]) {
            [self startLoadingAnim];
        }
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
#if CATEGORY_VIEW_NEW_HACK_ENABLE
#else
    [self checkAndLoadNextPageForced];
#endif
}
- (void)scrollViewDidScroll:(UIScrollView*)scrollView
{
#if CATEGORY_VIEW_NEW_HACK_ENABLE
        return;
#endif
    
    if (_scrollViewChild == nil) {
        return;
    }
    
    
    //    RLOG(@"======scrollViewDidScroll======");
    //    PRINT_RECT_STR(@"SVBase_frame", _scrollViewBase.frame);
    //    PRINT_SIZE_STR(@"SVBase_contentSize", _scrollViewBase.contentSize);
    //    PRINT_POINT_STR(@"SVBase_contentOffset", _scrollViewBase.contentOffset);
    //    PRINT_RECT_STR(@"SVChild_frame", _scrollViewChild.frame);
    //    PRINT_SIZE_STR(@"SVChild_contentSize", _scrollViewChild.contentSize);
    //    PRINT_POINT_STR(@"SVChild_contentOffset", _scrollViewChild.contentOffset);
    
    
    if (_scrollViewBaseOffsetDefault == -99999) {
        _scrollViewBaseOffsetDefault =  (int)_scrollViewBase.contentOffset.y;
    }
    if (_scrollViewChildOffsetDefault == -99999) {
        _scrollViewChildOffsetDefault =  (int)_scrollViewChild.contentOffset.y;
    }
    if (_permanentScrollSet) {
        return;
    }
    if ((int)_scrollViewChild.contentSize.height != 0 && (int)_scrollViewChild.contentSize.height < (int)_scrollViewChild.frame.size.height) {
        _scrollViewBase.scrollEnabled = true;
        _scrollViewChild.scrollEnabled  = false;
        _permanentScrollSet = true;
    }
    
    int baseContentOffsetHeight = (int)_scrollViewBase.contentSize.height - (int)_scrollViewBase.frame.size.height;
    if ((int)_scrollViewChild.contentOffset.y < _scrollViewChildOffsetDefault) {
        int diff = (int)_scrollViewChild.contentOffset.y - _scrollViewChildOffsetDefault;
        [_scrollViewChild setContentOffset:CGPointMake(
                                                       (int) _scrollViewChild.contentOffset.x,
                                                       _scrollViewChildOffsetDefault)];
        [_scrollViewBase setContentOffset:CGPointMake(
                                                      (int)_scrollViewBase.contentOffset.x,
                                                      (int)_scrollViewBase.contentOffset.y + diff)];
        _scrollViewBase.scrollEnabled = true;
        _scrollViewChild.scrollEnabled = false;
    }
    if ((int)_scrollViewBase.contentOffset.y > baseContentOffsetHeight) {
        int diff = (int)_scrollViewBase.contentOffset.y - baseContentOffsetHeight;
        [_scrollViewBase setContentOffset:CGPointMake(
                                                      (int)_scrollViewBase.contentOffset.x,
                                                      baseContentOffsetHeight)];
        [_scrollViewChild setContentOffset:CGPointMake(
                                                       (int)_scrollViewChild.contentOffset.x,
                                                       (int)_scrollViewChild.contentOffset.y + diff)];
        _scrollViewBase.scrollEnabled = false;
        _scrollViewChild.scrollEnabled = true;
    }
    
    
    
    ScrollDirection scrollDirection = ScrollDirectionNone;
    if (scrollView == _scrollViewBase) {
        if (_scrollViewBaseOffsetLast < (int)scrollView.contentOffset.y)
            scrollDirection = ScrollDirectionUp;
        else if (_scrollViewBaseOffsetLast > (int)scrollView.contentOffset.y)
            scrollDirection = ScrollDirectionDown;
        _scrollViewBaseOffsetLast = (int)scrollView.contentOffset.y;
    } else if (scrollView == _scrollViewChild) {
        if (_scrollViewChildOffsetLast < (int)scrollView.contentOffset.y)
            scrollDirection = ScrollDirectionUp;
        else if (_scrollViewChildOffsetLast > (int)scrollView.contentOffset.y)
            scrollDirection = ScrollDirectionDown;
        _scrollViewChildOffsetLast = (int)scrollView.contentOffset.y;
    }
    
    if (scrollDirection == ScrollDirectionUp) {
        if (scrollView == _scrollViewBase) {
            if ((int)_scrollViewBase.contentOffset.y < baseContentOffsetHeight) {
                _scrollViewBase.scrollEnabled = true;
                _scrollViewChild.scrollEnabled  = false;
            } else {
                _scrollViewBase.scrollEnabled = false;
                _scrollViewChild.scrollEnabled = true;
            }
        }
        if (scrollView == _scrollViewChild) {
            if ((int)_scrollViewBase.contentOffset.y >= 0 && (int)_scrollViewBase.contentOffset.y < baseContentOffsetHeight) {
                _scrollViewBase.scrollEnabled = true;
                _scrollViewChild.scrollEnabled  = false;
            }
        }
    }
    else if(scrollDirection == ScrollDirectionDown) {
        if (scrollView == _scrollViewChild) {
            if ((int)_scrollViewBase.contentOffset.y > _scrollViewBaseOffsetDefault) {
                if ((int)_scrollViewChild.contentOffset.y > _scrollViewChildOffsetDefault) {
                    _scrollViewBase.scrollEnabled = false;
                    _scrollViewChild.scrollEnabled = true;
                } else {
                    _scrollViewBase.scrollEnabled = true;
                    _scrollViewChild.scrollEnabled = false;
                }
            } else {
                _scrollViewBase.scrollEnabled = true;
                _scrollViewChild.scrollEnabled = false;
            }
            [self checkAndLoadNextPage];
        }
    }
}
-(void)noProductsFoundthisAppliedFilter:(BOOL)isVisible {
    if (self.noProducts == nil) {
        self.noProducts = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
        [self.noProducts setText: Localize(@"empty_category_with_filter")];
        [self.noProducts setUIFont:kUIFontType20 isBold:false];
        self.noProducts.textColor = [Utility getUIColor:kUIColorFontLight];
        [self.noProducts setBackgroundColor: [UIColor clearColor]];
        [self.noProducts setNumberOfLines: 0];
        [self.noProducts sizeToFit];
        [self.view addSubview:self.noProducts];
        [self.noProducts setCenter:CGPointMake(self.view.center.x, self.view.center.y)];
    }
    self.noProducts.hidden = isVisible;
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
                [_viewsAdded removeAllObjects];
            }
        }];
    }
}
- (void)afterRotation {
    [self loadDataInView];
    UIView* lastView = [_viewsAdded lastObject];
    for(UIView *vieww in _viewsAdded)
    {
        [vieww setAlpha:0.0f];
        [UIView animateWithDuration:0.1f animations:^{
            [vieww setAlpha:1.0f];
        }completion:^(BOOL finished){
            if (vieww == lastView) {
                [self resetMainScrollView];
                if (_spinnerView) {
                    [_spinnerView setCenter:CGPointMake(self.view.frame.size.width/2, [_scrollView contentSize].height - [LayoutProperties globalVerticalMargin]/2)];
                }
            }
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
    [self resetMainScrollView];
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if ([[AppDelegate getInstance] isAppEnteredInBackground]) {
        return;
    }
    [[Utility sharedManager] startGrayLoadingBar:true];
    [self adjustViewsForOrientation:[[UIDevice currentDevice] orientation]];
    [self resetMainScrollView];
}
#pragma mark - Reset Views
- (void)resetMainScrollView {
    float globalPosY = 0.0f;
    UIView* tempView = nil;
    //    RLOG(@"\n_scrollView child count %d",(int)[[_scrollView subviews] count]);
    
    for (tempView in _viewsAdded) {
        //        RLOG(@"\ntempView = %@, globalPosY = %.f", tempView, globalPosY);
        CGRect rect = [tempView frame];
        rect.origin.y = globalPosY;
        [tempView setFrame:rect];
        globalPosY += rect.size.height;
        
        if ([tempView tag] == kTagForGlobalSpacing) {
            globalPosY += [LayoutProperties globalVerticalMargin];
        }else if ([tempView tag] == kTagForLastViewSpacing){
            globalPosY += [LayoutProperties globalVerticalMargin]/2;
        }
    }
//    globalPosY -= [LayoutProperties globalVerticalMargin]/2;
//    if (_scrollViewChild == nil) {
//        [_scrollView setContentSize:CGSizeMake(_scrollView.contentSize.width, MAX(globalPosY, self.view.frame.size.height))];
//        //        [_scrollView setBounces:true];
//    }else{
//        [_scrollView setContentSize:CGSizeMake(_scrollView.contentSize.width, globalPosY)];
//    }
    
    [_scrollView setContentSize:CGSizeMake(_scrollView.contentSize.width, globalPosY)];
    
}
#pragma mark - HorizontalLine
- (UIView*)addHorizontalLine:(int)tag {
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
    lineView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    lineView.backgroundColor = [Utility getUIColor:kUIColorBorder];
    [_scrollView addSubview:lineView];
    [_viewsAdded addObject:lineView];
    [lineView setTag:tag];
    return lineView;
}
- (void)removeUserDefinedView:(int)viewId {
    _isViewUserDefinedEnable[viewId] = false;
    [_viewUserDefinedHeader[viewId] removeFromSuperview];
    [_viewsAdded removeObject:_viewUserDefinedHeader[viewId]];
    [_viewUserDefined[viewId] removeFromSuperview];
    [_viewsAdded removeObject:_viewUserDefined[viewId]];
    [self resetMainScrollView];
}
- (void)removeBannerView {
    [_bannerScrollView removeFromSuperview];
    [_viewsAdded removeObject:_bannerScrollView];
    [self resetMainScrollView];
}
- (void)clickOnCategoryNew:(CategoryInfo*)categoryClicked currentItemData:(DataPass*)currentItemData{
    ViewControllerMain* mainVC = [ViewControllerMain getInstance];
    mainVC.containerTop.hidden = YES;
    mainVC.containerCenter.hidden = YES;
    mainVC.containerCenterWithTop.hidden = NO;
    mainVC.vcBottomBar.buttonHome.selected = YES;
    mainVC.vcBottomBar.buttonCart.selected = NO;
    mainVC.vcBottomBar.buttonWishlist.selected = NO;
    mainVC.vcBottomBar.buttonSearch.selected = NO;
    [mainVC.vcBottomBar buttonClicked:nil];
    DataPass* clickedItemData = [[DataPass alloc] init];
    clickedItemData.itemId = categoryClicked._id;
    clickedItemData.isCategory = true;
    clickedItemData.isProduct = false;
    clickedItemData.hasChildCategory = [[categoryClicked getSubCategories] count];
    clickedItemData.childCount = (int)[[ProductInfo getOnlyForCategory:categoryClicked showFilterProducts:false] count];
    clickedItemData.cInfo = categoryClicked;
    DataPass* previousItemData = [[DataPass alloc] init];
    previousItemData.itemId = currentItemData.cInfo._id;
    previousItemData.isCategory = currentItemData.isCategory;
    previousItemData.isProduct = currentItemData.isProduct;
    previousItemData.hasChildCategory = currentItemData.hasChildCategory;
    previousItemData.childCount = currentItemData.childCount;
    previousItemData.cInfo = currentItemData.cInfo;
    ViewControllerCategoriesNew* vcCategories = [[Utility sharedManager] pushScreenCategoryNew:mainVC.vcCenterTop];
    [vcCategories loadData:clickedItemData previousItem:previousItemData drillingLevel:_drillingLevel + 1];
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
    [mainVC.vcBottomBar buttonClicked:nil];
    DataPass* clickedItemData = [[DataPass alloc] init];
    clickedItemData.itemId = categoryClicked._id;
    clickedItemData.isCategory = true;
    clickedItemData.isProduct = false;
    clickedItemData.hasChildCategory = [[categoryClicked getSubCategories] count];
    clickedItemData.childCount = (int)[[ProductInfo getOnlyForCategory:categoryClicked showFilterProducts:false] count];
    clickedItemData.cInfo = categoryClicked;
    
    DataPass* previousItemData = [[DataPass alloc] init];
    previousItemData.itemId = currentItemData.cInfo._id;
    previousItemData.isCategory = currentItemData.isCategory;
    previousItemData.isProduct = currentItemData.isProduct;
    previousItemData.hasChildCategory = currentItemData.hasChildCategory;
    previousItemData.childCount = currentItemData.childCount;
    previousItemData.cInfo = currentItemData.cInfo;
    
    ViewControllerCategories* vcCategories = [[Utility sharedManager] pushScreen:mainVC.vcCenterTop];
    [vcCategories loadData:clickedItemData previousItem:previousItemData drillingLevel:_drillingLevel + 1];
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
    [vcProduct loadData:clickedItemData previousItem:previousItemData drillingLevel:_drillingLevel + 1];
    vcProduct.parentVC = self;
    vcProduct.parentCell = cell; 
}

-(void)dataFetchCompletion:(ServerData *)serverData{
    if (serverData._serverRequestStatus == kServerRequestSucceed) {
        RLOG(@"=======DATA_FETCHING:SUCCESS=======");
        RLOG(@"_serverUrl = %@",serverData._serverUrl);
        RLOG(@"_serverDataId = %d",serverData._serverDataId);
        RLOG(@"_serverResultDictionary = %@",serverData._serverResultDictionary);
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:serverData._serverResultDictionary options:NSJSONWritingPrettyPrinted error:&error];
        if (! jsonData) {
            RLOG(@"Got an error: %@", error);
        } else {
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            [[NSUserDefaults standardUserDefaults] setObject:jsonString forKey:serverData._serverUrl];
        }
    } else if (serverData._serverRequestStatus == kServerRequestFailed) {
        RLOG(@"=======DATA_FETCHING:FAILED=======");
        RLOG(@"_serverUrl = %@",serverData._serverUrl);
        RLOG(@"_serverDataId = %d",serverData._serverDataId);
        RLOG(@"_serverResultDictionary = %@",serverData._serverResultDictionary);
        NSString *jsonString = nil;
        if (CHECK_PRELOADED_DATA) {
            jsonString = [[NSUserDefaults standardUserDefaults] objectForKey:serverData._serverUrl];
        }
        if (jsonString) {
            NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            if (data) {
                id jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                if (jsonDict) {
                    serverData._serverResultDictionary = (NSDictionary*) jsonDict;
                    if (serverData._serverResultDictionary) {
                        serverData._serverRequestStatus = kServerRequestSucceed;
                    }
                }
            }
        }
    }
    
    if (serverData._serverRequestStatus == kServerRequestSucceed) {
        switch (serverData._serverDataId) {
            case kFetchMoreProduct:
                RLOG(@"Load kFetchMoreProduct CATEGORY SCREEN:%@", self);
                if (_pageLoading) {
                    int childRC = [_currentItem.cInfo getChildRetrievedCount];
                    _pageLoading = false;
                    _currentItem.childCount = childRC;
                    if ([[DataManager sharedManager] layoutIdProductView] == P_LAYOUT_DISCOUNT) {
                        if (ENABLE_DISCOUNT_LAYOUT_TYPE1) {
                            if ([[ProductInfo getOnlyForCategory:_currentItem.cInfo showFilterProducts:self.showFilterdResult] count] > 0) {
                                for (ProductInfo* pInfo in [ProductInfo getOnlyForCategory:_currentItem.cInfo showFilterProducts:self.showFilterdResult]) {
                                    pInfo.cellObj = nil;
                                }
                            }
                        }
                    }
                    [_viewUserDefined[_kShowAllItems] reloadData];
#if CATEGORY_VIEW_NEW_HACK_ENABLE
#else
                    _scrollViewBase.scrollEnabled = true;
                    _scrollViewChild.scrollEnabled  = true;
                    _permanentScrollSet = false;
                    [self scrollViewDidScroll:_scrollView];
                    //                    [self scrollViewDidScroll:_scrollViewBase];
#endif
                    [self stopLoadingAnim];
                }
                break;
            default:
                break;
        }
    } else if (serverData._serverRequestStatus == kServerRequestFailed){
        
        switch (serverData._serverDataId) {
            case kFetchMoreProduct:
                [self updateStuff];
                break;
            default:
                break;
        }
        
    }
}


- (void)startLoadingAnim {
    RLOG(@"startLoadingAnim");
    if (_spinnerView == nil) {
        _spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [_spinnerView startAnimating];
    }
    [_spinnerView removeFromSuperview];
    [_scrollView addSubview:_spinnerView];
    [_spinnerView setFrame:CGRectMake(
                                      0,
                                      0,
                                      _spinnerView.frame.size.width,
                                      _spinnerView.frame.size.height)];
    [_spinnerView setCenter:CGPointMake(self.view.frame.size.width/2, [_scrollView contentSize].height - _spinnerView.frame.size.height)];
    [_spinnerView startAnimating];
}
- (void)stopLoadingAnim {
    RLOG(@"stopLoadingAnim");
    [_spinnerView removeFromSuperview];
    [self resetMainScrollView];
}

#pragma mark FILTER
- (UIView*)createFilterButton {

    CGRect rectMainView = self.view.frame;
    float viewWidth, viewHeight;
    if ([[MyDevice sharedManager] isIpad]) {
        viewWidth = rectMainView.size.width*.15f;
        viewHeight = rectMainView.size.width*.15f;
    } else {
        viewWidth = rectMainView.size.width*.2f;
        viewHeight = rectMainView.size.width*.2f;
    }
    
    
    
    float viewButtonWidth = viewWidth * .5f;
    float viewButtonHeight = viewHeight * .5f;
    float gap = rectMainView.size.width*.01f;
    
    UIButton* button = [[UIButton alloc] init];
    button.frame = CGRectMake(0, 0, viewButtonWidth, viewButtonHeight);
    [button setUIImage:[[UIImage imageNamed:@"filter"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [button.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [button setTintColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
    [button addTarget:self action:@selector(btnFilterClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    UILabel* label = [[UILabel alloc] init];
    label.frame = CGRectMake(0, 0, viewWidth, viewHeight);
    [label setUIFont:kUIFontType14 isBold:false];
    label.backgroundColor = [Utility getUIColor:kUIColorBuyButtonNormalBg];
    label.textColor = [Utility getUIColor:kUIColorBuyButtonFont];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setNumberOfLines:2];
    label.text = @"";
    [label sizeToFitUI];
    
    UIView* view = [[UIView alloc] init];
    view.frame = CGRectMake(0, 0, viewWidth, viewButtonHeight + gap + label.frame.size.height);
    [view addSubview:button];
    [view addSubview:label];
    [view setHidden:true];
    [self.view addSubview:view];
    
    button.frame = CGRectMake(0, 0, viewButtonWidth, viewButtonHeight);
    label.frame = CGRectMake(0, viewButtonHeight + gap, viewWidth, label.frame.size.height);
    button.center = CGPointMake(label.center.x, button.center.y);
    view.frame = CGRectMake(
                            rectMainView.size.width - view.frame.size.width - gap,
                            rectMainView.size.height - view.frame.size.height - gap,
                            view.frame.size.width,
                            view.frame.size.height);
    
    _viewFilter = view;
    _buttonFilter = button;
    _labelFilter = label;
    return view;
}

- (void)showFilterView:(NSString*)str {
    CGRect rectMainView = self.view.frame;
    float viewWidth, viewHeight;
    if ([[MyDevice sharedManager] isIpad]) {
        viewWidth = [[MyDevice sharedManager] screenWidthInPortrait] * .15f;
        viewHeight = [[MyDevice sharedManager] screenWidthInPortrait] * .15f;
    } else {
        viewWidth = [[MyDevice sharedManager] screenWidthInPortrait] * .20f;
        viewHeight = [[MyDevice sharedManager] screenWidthInPortrait] * .20f;
    }
    float viewButtonWidth = viewWidth * .50f;
    float viewButtonHeight = viewHeight * .50f;
    float gap = [[MyDevice sharedManager] screenWidthInPortrait] * .01f;
    
    
    _labelFilter.text = str;
    [_labelFilter sizeToFitUI];
    _viewFilter.frame = CGRectMake(0, 0, viewWidth, viewButtonHeight + gap + _labelFilter.frame.size.height);
    _buttonFilter.frame = CGRectMake(0, 0, viewButtonWidth, viewButtonHeight);
    _labelFilter.frame = CGRectMake(0, viewButtonHeight + gap, viewWidth, _labelFilter.frame.size.height);
    _buttonFilter.center = CGPointMake(_labelFilter.center.x, _buttonFilter.center.y);
    _viewFilter.frame = CGRectMake(
                                   rectMainView.size.width - _viewFilter.frame.size.width - gap,
                                   rectMainView.size.height - _viewFilter.frame.size.height - gap,
                                   _viewFilter.frame.size.width,
                                   _viewFilter.frame.size.height);
    [_viewFilter setHidden:false];
}
- (void)showFilterView {
    [self showFilterView:@""];
}
- (void)hideFilterView {
    [_viewFilter setHidden:true];
}
- (void)toggleFilterViewSize {
    float timeInterval = 0.3f;
    [UIView animateWithDuration:timeInterval
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         if (_viewFilterMain.frame.size.height == self.view.frame.size.height * MIN_FILTER_HEIGHT_FACTOR) {
                             _viewFilterMain.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height * MAX_FILTER_HEIGHT_FACTOR);
                         } else {
                             _viewFilterMain.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height * MIN_FILTER_HEIGHT_FACTOR);
                         }
                         _viewFilterMain.frame = CGRectMake(0, self.view.frame.size.height - _viewFilterMain.frame.size.height, _viewFilterMain.frame.size.width, _viewFilterMain.frame.size.height);
                         _viewFilterMain.layer.anchorPoint = CGPointMake(0.5f, 1.0f);
                     } completion:^(BOOL complete){
                         if (complete) {
                         }
                     }];
}
- (void)btnFilterClicked:(UIButton*)button {
    if (_viewFilterMain == nil) {
        _viewFilterMain = [[[NSBundle mainBundle] loadNibNamed:@"ViewFilter" owner:self options:nil] objectAtIndex:0];
        [_viewFilterMain setDelegate:self];
        [self.view addSubview:_viewFilterMain];
        
        _viewFilterMain.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height * 0);
        _viewFilterMain.frame = CGRectMake(0, self.view.frame.size.height - _viewFilterMain.frame.size.height/2, _viewFilterMain.frame.size.width, _viewFilterMain.frame.size.height);
        _viewFilterMain.layer.anchorPoint = CGPointMake(0.5f, 1.0f);
    }
    
    float timeInterval = 0.3f;
    [UIView animateWithDuration:timeInterval
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         if (_viewFilterMain.frame.size.height == 0) {
                             _viewFilterMain.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height * MIN_FILTER_HEIGHT_FACTOR);
                         } else {
                             _viewFilterMain.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height * 0);
                         }
                         _viewFilterMain.frame = CGRectMake(0, self.view.frame.size.height - _viewFilterMain.frame.size.height, _viewFilterMain.frame.size.width, _viewFilterMain.frame.size.height);
                         _viewFilterMain.layer.anchorPoint = CGPointMake(0.5f, 1.0f);
                     } completion:^(BOOL complete){
                         if (complete) {
                             if (_viewFilterMain.frame.size.height != 0) {
                                 [_viewFilterMain refreshLeftTable];
                             }
                         }
                     }];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(tableView == _viewFilterMain.leftTable) {
        return [_viewFilterMain.allFilters count];
    }
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == _viewFilterMain.leftTable) {
        static NSString *simpleTableIdentifier = @"SimpleTableItem";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        }
        cell.textLabel.text = [_viewFilterMain.allFilters objectAtIndex:indexPath.row];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        [cell.textLabel setUIFont:kUIFontType18 isBold:false];
        cell.textLabel.textColor = [Utility getUIColor:kUIColorFontLight];
        return cell;
    }
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView == _viewFilterMain.leftTable) {
        return [[MyDevice sharedManager] screenSize].height * 0.06f;
    }
    return [[MyDevice sharedManager] screenSize].height * 0.06f;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(tableView == _viewFilterMain.leftTable) {
        return 1;
    }
    return 1;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(tableView == _viewFilterMain.leftTable) {
        [_viewFilterMain cellSetColor:indexPath isSelected:true];
    }
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView == _viewFilterMain.leftTable) {
        [_viewFilterMain cellSetColor:indexPath isSelected:false];
    }
}
#pragma mark NEW FILLTER
-(void)loadFilterPrices{
    if (_filter_prices_loading) {
        return;
    }
    if (!([TM_ProductFilter getAll]==nil)) {
        [self loadFilterAttributes];
        return;
    }
    _filter_prices_loading = true;
    [[[DataManager sharedManager] tmDataDoctor] getFilterPricesInBackground:nil success:^(id data) {
        RLOG(@"success");
        _filter_prices_loading = false;
        [self getMaximumAndMinimumWithID];
        DataManager *dm = [DataManager sharedManager];
        dm.isPriceFilterLoaded = true;
        if ([TM_ProductFilter attribsLoaded] && dm.isAtributtFilterLoaded) {
        } else {
            [self loadFilterAttributes];
        }
        if (dm.isAtributtFilterLoaded && dm.isPriceFilterLoaded) {
#if ENABLE_HEADER_FILTER_BUTTON
            customFilterButton.hidden = false;
            [self setFilterVisibility:NO];

#else
            _filterView.hidden = false;
            float filterPOSY = CGRectGetMaxY(_filterView.frame);
            _scrollView.frame = CGRectMake(
                                           _scrollView.frame.origin.x,
                                           filterPOSY - 20,
                                           _scrollView.frame.size.width,
                                           [[MyDevice sharedManager] screenSize].height -  (filterPOSY - 20)- [[Utility sharedManager] getBottomBarHeight] - 20
                                           );
#endif

        } else {
            _filterView.hidden = true;
            customFilterButton.hidden = true;
            [self setFilterVisibility:YES];

        }
    } failure:^(NSString *error) {
        RLOG(@"failure");
        [self loadFilterPrices];
    }];
}
-(void)loadFilterAttributes{
    if (_filter_attribs_loading) {
        return;
    }
    if ([TM_ProductFilter attribsLoaded]) {
    }
    _filter_attribs_loading = true;
    [[[DataManager sharedManager] tmDataDoctor] getFilterAttributesInBackground:nil success:^(id data) {
        _filter_attribs_loading = false;
        RLOG(@"Attribut Success");
        [self getAttributeWithID];
        DataManager* dm = [DataManager sharedManager];
        dm.isAtributtFilterLoaded = true;
        if (dm.isAtributtFilterLoaded && dm.isPriceFilterLoaded) {
#if ENABLE_HEADER_FILTER_BUTTON
            customFilterButton.hidden = false;
            [self setFilterVisibility:false];

#else
            _filterView.hidden = false;
            float filterPOSY = CGRectGetMaxY(_filterView.frame);
            _scrollView.frame = CGRectMake(
                                           _scrollView.frame.origin.x,
                                           filterPOSY - 20,
                                           _scrollView.frame.size.width,
                                           [[MyDevice sharedManager] screenSize].height -  (filterPOSY - 20) - [[Utility sharedManager] getBottomBarHeight] - 20
                                           );
#endif
        }else{
            _filterView.hidden = true;
            customFilterButton.hidden = true;
            [self setFilterVisibility:true];
            
        }
    } failure:^(NSString *error) {
        [self loadFilterAttributes];
        _filter_attribs_loading = false;
    }];
}
-(void)getMaximumAndMinimumWithID {
    RLOG(@"_currentItem.cInfo._id  %d",_currentItem.cInfo._id);
    TM_ProductFilter* pfObj =[TM_ProductFilter getWithCategoryId:_currentItem.cInfo._id];
    RLOG(@"MaxPrice  %f",pfObj.maxPrice);
    RLOG(@"minprice  %f",pfObj.minPrice);
    MaxPriceWithID =pfObj.maxPrice;
    MinPriceWithID =pfObj.minPrice;
    [self ispriceLoadedandAtributtLoadede];
}

-(void)getAttributeWithID {
    filterAttributes = [[NSMutableArray alloc]init];
    TM_ProductFilter* productFilter =[TM_ProductFilter getForCategory:_currentItem.cInfo._id];
    NSLog(@"productFilter1 %lu",(unsigned long)[productFilter.getAttributes count]);
    for (TM_FilterAttribute* filterAttribute in productFilter.getAttributes) {
        if (![self containsFilterAttribute:filterAttribute]) {
            [filterAttributes addObject:filterAttribute];
        }
        NSLog(@"SHOW_TITLE %@",filterAttribute.title);
    }
    [self ispriceLoadedandAtributtLoadede];
    NSLog(@"productFilter2 %lu",(unsigned long)[filterAttributes count]);
}

-(BOOL)containsFilterAttribute :(TM_FilterAttribute*)filterAttribute1{
    if (filterAttributes == nil) {
        return false;
    }
    for (TM_FilterAttribute* filterAttribute2 in filterAttributes) {
        if ([filterAttribute1.attribute isEqualToString:filterAttribute2.attribute]) {
            return true;
        }
    }
    return false;
}

#pragma mark Grocery mode
-(void)dismissAlertViewAuto:(UIAlertView *)alertView{
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
}
- (void)addButtonClicked:(UIButton*)button {
    [[Utility sharedManager] addButtonClicked:button];
}
- (void)substractButtonClicked:(UIButton*)button {
    [[Utility sharedManager] substractButtonClicked:button];
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
            [self clickOnProduct:pInfo currentItemData:_currentItem cell:cell];
        }else {
            int availState = [Cart getProductAvailibleState:pInfo variationId:-1];
            if (availState == PRODUCT_QTY_DEMAND || availState == PRODUCT_QTY_STOCK) {
                [Cart addProduct:pInfo variationId:-1 variationIndex:-1 selectedVariationAttributes:nil];
            }
        }
    }
    [cell refreshCell:pInfo];
}
- (void)backFromProductScreen:(id)cell{
    if (cell) {
        CCollectionViewCell* pCell = (CCollectionViewCell*)cell;
        ProductInfo* pInfo = (ProductInfo*)[pCell.layer valueForKey:@"PINFO_OBJ"];
        if (pInfo) {
            [pCell refreshCell:pInfo];
        }
    }
}

- (void)setFilterVisibility:(BOOL)value{
    if ([self getChildCount] == 0) {
        customFilterButton.hidden = YES;
    }else{
        customFilterButton.hidden = value;
    }
}

@end
