//
//  ViewControllerSearch.m

//
//  Created by Rishabh Jain on 24/09/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import "ViewControllerSearch.h"
#import "DataManager.h"
#import "Wishlist.h"
#import "Cart.h"
#import "AppDelegate.h"
#import "Addons.h"
#import "AppUser.h"
static int kTagForGlobalSpacing = 0;
static int kTagForNoSpacing = -1;

@interface ViewControllerSearch ()
//#if ENABLE_CATEGORY_IN_SEARCH_SCREEN
<RATreeViewDelegate, RATreeViewDataSource>
//#endif
{
    NSMutableArray *_viewsAdded;
    NSMutableArray *_horizontalScrollViews;
    NSMutableArray *_searchedItems;
}
//#if ENABLE_CATEGORY_IN_SEARCH_SCREEN
@property (strong, nonatomic) NSMutableArray *dataObjects;
@property (weak, nonatomic) RATreeView *treeView;
//#endif
@end

@implementation ViewControllerSearch

#pragma mark - View Life Cycle

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    [self.view addGestureRecognizer:_singleTap];
    DataManager* dm = [DataManager sharedManager];
    dm.searchBarTextField = searchBar;
}
// called when text changes (including clear)
//- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
//    if ([searchText isEqualToString:@""] == false) {
//        [[DataManager sharedManager] fetchProductsWithTag:nil tag:searchText offset:0 productCount:100];
//        [self startLoadingAnim];
//        _searchedItems = [ProductInfo searchProducts:searchText];
//    }else{
//        [self stopLoadingAnim];
//        _searchedItems = nil;
//        [labelNoResultFound setText:@""];
//    }
//    [self loadDataInView];
//}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchText isEqualToString:@""] == false) {
        if([[Addons sharedManager] show_categories_in_search]){
            if (_categoryView) {
                [_categoryView setHidden:true];
            }
        }
        else if ([[Addons sharedManager] geoLocation] && [[[Addons sharedManager] geoLocation] isEnabled]) {
                [[DataManager sharedManager] fetchProductsWithTag:nil tag:searchText offset:0 productCount:100];
                [self startLoadingAnim];
                _searchedItems = [ProductInfo searchProducts:searchText];
                [[AppDelegate getInstance] logItemSearched:searchText isFound:true];
        }
    }else{
        [self stopLoadingAnim];
        _searchedItems = nil;
        [labelNoResultFound setText:@""];
        
        if([[Addons sharedManager] show_categories_in_search]){
            if (_categoryView) {
                [_categoryView setHidden:false];
            }
        }
    }
    [self loadDataInView];
}

// called when keyboard search button pressed
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    if ([searchBar.text isEqualToString:@""] == false) {
        if([[Addons sharedManager] show_categories_in_search]){
            if (_categoryView) {
                [_categoryView setHidden:true];
            }
        }
        [[DataManager sharedManager] fetchProductsWithTag:nil tag:searchBar.text offset:0 productCount:100];
        [self startLoadingAnim];
        _searchedItems = [ProductInfo searchProducts:searchBar.text];
        [[AppDelegate getInstance] logItemSearched:searchBar.text isFound:true];
    }else{
        [self stopLoadingAnim];
        _searchedItems = nil;
        [labelNoResultFound setText:@""];
        
        if([[Addons sharedManager] show_categories_in_search]){
            if (_categoryView) {
                [_categoryView setHidden:false];
            }
        }
    }
    [self loadDataInView];
}
// called when bookmark button pressed
- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}
// called when cancel button pressed
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////



- (void)viewDidLoad {
    [super viewDidLoad];
    if([[Addons sharedManager] show_categories_in_search]){
        _categoryView = nil;
    }
    //    _searchBar = nil;
    _searchBar.placeholder = Localize(@"txt_search_hint");
    _spinnerView = nil;
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        _searchBar.transform = CGAffineTransformMakeScale(-1, 1);
    }
    
    _strCollectionView1 = [[Utility sharedManager] getProductViewString];
    _strCollectionView2 = [[Utility sharedManager] getCategoryViewString];
    _strCollectionView3 = [[Utility sharedManager] getHorizontalViewString];
    
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [Utility getUIColor:kUIColorThemeFont], NSForegroundColorAttributeName, [Utility getUIFont:kUIFontType24 isBold:false], NSFontAttributeName, nil]];
    
    _singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [labelNoResultFound setText:@""];
    [labelNoResultFound setUIFont:kUIFontType18 isBold:false];
    [self initVariables];
    // Do any additional setup after loading the view.
    
    if ([[Addons sharedManager] geoLocation] && [[[Addons sharedManager] geoLocation] isEnabled]) {
        //Ankur
        _resultsViewController = [[GMSAutocompleteResultsViewController alloc] init];
        _resultsViewController.delegate = self;
        
        _searchController = [[UISearchController alloc]
                             initWithSearchResultsController:_resultsViewController];
        _searchController.searchResultsUpdater = _resultsViewController;
        
        UIView *subView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];

        _searchController.searchBar.placeholder = Localize(@"txt_search_hint");
        [subView addSubview:_searchController.searchBar];
        [_searchController.searchBar sizeToFit];
        [self.view addSubview:subView];
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        self.definesPresentationContext = YES;
        
        [_searchBar setHidden:true];
        //[self searchBar:_searchBar visible:false];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newSearchResults:) name:@"NEW_SEARCH_RESULTS" object:nil];    
}

#if ENABLE_AUTOCOMPLETE_GEOLOCATION_SEARCH

// Handle the user's selection.
- (void)resultsController:(GMSAutocompleteResultsViewController *)resultsController didAutocompleteWithPlace:(GMSPlace *)place {
    [self dismissViewControllerAnimated:YES completion:NULL];
    // Do something with the selected place.
    RLOG(@"Place name %@", place.name);
    RLOG(@"Place address %@", place.formattedAddress);
    RLOG(@"Place attributions %@", place.attributions.string);
    [_searchController.searchBar setText:[NSString stringWithFormat:@"%@", place.name]];
    //    [_searchBar setText:[NSString stringWithFormat:@"%@", place.name]];
    //    NSString *searchText = [[NSString stringWithFormat:@"%@", place.name] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [self searchBar:_searchBar textDidChange:[NSString stringWithFormat:@"%@", place.name]];
}

- (void)resultsController:(GMSAutocompleteResultsViewController *)resultsController didFailAutocompleteWithError:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
    // TODO: handle the error.
    RLOG(@"Error: %@", [error description]);
}

// Turn the network activity indicator on and off again.
- (void)didRequestAutocompletePredictionsForResultsController: (GMSAutocompleteResultsViewController *)resultsController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)didUpdateAutocompletePredictionsForResultsController: (GMSAutocompleteResultsViewController *)resultsController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
#endif //ENABLE_AUTOCOMPLETE_GEOLOCATION_SEARCH


- (void)newSearchResults:(NSNotification*)notification {

    if(notification.object){
        _searchedItems = notification.object;
    }
    
    [self stopLoadingAnim];
    
    if ([[Addons sharedManager] geoLocation] && [[[Addons sharedManager] geoLocation] isEnabled]) {
        if(_searchedItems != nil) {
            [self loadDataInView];
        }
    }
    else {
        if (_searchBar != nil) {
            if ([_searchBar.text isEqualToString:@""] == false) {
                _searchedItems = [ProductInfo searchProducts:_searchBar.text];
                if (_searchedItems == nil) {
                    [labelNoResultFound setText:Localize(@"i_no_result_found")];
                    [[AppDelegate getInstance] logItemSearched:_searchBar.text isFound:false];
                }
                else {
                    [labelNoResultFound setText:@""];
                    [[AppDelegate getInstance] logItemSearched:_searchBar.text isFound:true];
                }
                [self loadDataInView];
            } else {
                _searchedItems = nil;
                [labelNoResultFound setText:@""];
                [self loadDataInView];
            }
        }else{
            _searchedItems = nil;
            [labelNoResultFound setText:Localize(@"i_no_result_found")];
            [self loadDataInView];
        }
    }
    
}
-(void)handleSingleTap:(UITapGestureRecognizer *)sender{
    [self.view endEditing:YES];
    [self.view removeGestureRecognizer:_singleTap];
}
- (void)viewWillAppear:(BOOL)animated{
    //rv//[SDWebImageManager.sharedManager.imageDownloader setValue:@"SDWebImage Demo" forHTTPHeaderField:@"AppName"];
//    SDWebImageManager.sharedManager.imageDownloader.executionOrder = SDWebImageDownloaderFIFOExecutionOrder;
    [self adjustViewsAfterOrientation:nil];
    
    if ([[Addons sharedManager] geoLocation] && [[[Addons sharedManager] geoLocation] isEnabled]) {
//        [_searchController.searchBar becomeFirstResponder];
    }else{
        [_searchBar becomeFirstResponder];
    }
}
- (void)viewWillDisappear:(BOOL)animated {
    if ([[Addons sharedManager] geoLocation] && [[[Addons sharedManager] geoLocation] isEnabled]) {
//        [_searchController.searchBar resignFirstResponder];
    }else{
        [_searchBar resignFirstResponder];
    }
}
- (void)flushCache {
    [SDWebImageManager.sharedManager.imageCache clearMemory];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Methods
- (void)initVariables {
    _searchedItems = [[NSMutableArray alloc] init];
    [_scrollView setBackgroundColor:[Utility getUIColor:kUIColorBgTheme]];
    self.view.backgroundColor = [Utility getUIColor:kUIColorBgTheme];
    _viewsAdded = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < _kTotalViewsHomeScreen; i++)
    {
        _viewUserDefined[i] = nil;
        _propCollectionView[i] = [[LayoutProperties alloc] initWithCollectionViewValues:SCROLL_TYPE_SHOWFULL];
        _viewUserDefinedHeaderString[i] = @"";
        _viewUserDefinedHeader[i] = nil;
        _isViewUserDefinedEnable[i] = false;
    }
    _isViewUserDefinedEnable[_kShowAllItems] = true;
    
}
- (void)loadDataInView {
    for (int i = 0; i < _kTotalViewsHomeScreen; i++) {
        [_propCollectionView[i] setCollectionViewProperties:_propCollectionView[i] scrollType:SCROLL_TYPE_SHOWFULL];
    }
    
    _isViewUserDefinedEnable[_kShowAllItems] = true;
    for (UIView* view in _viewsAdded) {
        [view removeFromSuperview];
    }
    [_viewsAdded removeAllObjects];
    [self createVariousViews];
    
    if([[Addons sharedManager] show_categories_in_search]){
        [self loadCategoryView];
    }
    [self resetMainScrollView];
}

#pragma mark - Deal Views
- (void)bannerTapped:(UITapGestureRecognizer*)singleTap{
    Banner* banner = [singleTap.view.layer valueForKey:@"BANNER_OBJ"];
    id cell = [singleTap.view.layer valueForKey:@"CELL_OBJ"];
    
    int productId = (int)[singleTap.view tag];
    ProductInfo* pInfo = (ProductInfo*)[ProductInfo getProductWithId:productId];
    if (pInfo) {
        [self clickOnProduct:pInfo currentItemData:_currentItem cell:cell];
    }
}
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
            [_viewUserDefinedHeader[i] setTextAlignment:NSTextAlignmentLeft];//Set text alignment in label.
            [_viewUserDefinedHeader[i] setBaselineAdjustment:UIBaselineAdjustmentAlignBaselines];//Set line adjustment.
            [_viewUserDefinedHeader[i] setLineBreakMode:NSLineBreakByCharWrapping];//Set linebreaking mode..
            [_viewUserDefinedHeader[i] setNumberOfLines:1];//Set number of lines in label.
            [_scrollView addSubview:_viewUserDefinedHeader[i]];
            [_viewsAdded addObject:_viewUserDefinedHeader[i]];
            [_viewUserDefinedHeader[i] setTag:kTagForNoSpacing];
        }
        
        UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
        switch (i) {
            case _kShowAllItems:
            {
                [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
                _viewUserDefined[i] = [[UICollectionView alloc] initWithFrame:[_propCollectionView[i] getFrameRect] collectionViewLayout:layout];
                CGRect rect = _viewUserDefined[i].frame;
                rect.size.height = self.view.frame.size.height - 44.0f;
                _viewUserDefined[i].frame = rect;
                [_viewUserDefined[i] setScrollEnabled:true];
                [_viewUserDefined[i] registerNib:[UINib nibWithNibName:_strCollectionView1 bundle:nil] forCellWithReuseIdentifier:@"CollectionCell"];
                [_scrollView addSubview:_viewUserDefined[i]];
                [_viewsAdded addObject:_viewUserDefined[i]];
                [_viewUserDefined[i] setTag:kTagForNoSpacing];
            }break;
            default:
                break;
        }
        [_viewUserDefined[i] setBackgroundColor:_propCollectionView[i]._bgColor];
        [_viewUserDefined[i] setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [_viewUserDefined[i] setDataSource:self];
        [_viewUserDefined[i] setDelegate:self];
        [_viewUserDefined[i] reloadData];
        //        RLOG(@"\n_viewUserDefined[%d] = %@", i, _viewUserDefined[i]);
        [self resetMainScrollView];
    }
}
#pragma mark - Category View
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    int itemCount = 0;
    int i = 0;
    for (; i < _kTotalViewsHomeScreen; i++) {
        if(_viewUserDefined[i] == collectionView){
            break;
        }
    }
    
    switch (i) {
        case _kShowAllItems:
        {
            itemCount = (int)[_searchedItems count];
        }break;
        default:
            itemCount = 1;
            break;
    }
    
    if (itemCount == 0) {
        [self removeUserDefinedView:i];
    }
    return itemCount;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CollectionCell";
    CCollectionViewCell *cell=(CCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    [cell setNeedsLayout];
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
            
        case _kShowAllItems:
        {
            
            if(cell == nil) {
                NSArray *nib = [[ NSBundle mainBundle] loadNibNamed:_strCollectionView1 owner:self options:nil];
                cell = [nib objectAtIndex:0];
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
            [Utility showShadow:cell];
            [cell setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
//            _propCollectionView[i]._height = _viewUserDefined[i].contentSize.height + _viewUserDefined[i].contentInset.top + _viewUserDefined[i].contentInset.bottom;
//            [_viewUserDefined[i] setFrame:[_propCollectionView[i] getFrameRect]];
//            [self resetMainScrollView];
            ProductInfo *pInfo = (ProductInfo *)[_searchedItems objectAtIndex:indexPath.row];
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
            
            ProductImage *pImage = [pInfo._images objectAtIndex:0];;
            [[cell productName] setText:pInfo._titleForOuterView];
            [[cell productPriceOriginal] setAttributedText:[pInfo getPriceOldString]];
            [[cell productPriceFinal] setText:[pInfo getPriceNewString]];
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
            UIImage* discountBG = [[UIImage imageNamed:@"button_circle"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [cell.imgDiscountBg setImage:discountBG];
            [cell.imgDiscountBg setTintColor:[Utility getUIColor:kUIColorBuyButtonFont]];
            [cell.labelDiscount setTextColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
            [cell.imgDiscountBg.layer setBorderColor:[Utility getUIColor:kUIColorBuyButtonNormalBg].CGColor];
            [cell.imgDiscountBg.layer setBorderWidth:1];
            //                cell.imgDiscountBg.layer.cornerRadius = cell.imgDiscountBg.frame.size.height/2.0;
            if ([[MyDevice sharedManager] isIpad]) {
                //                    cell.imgDiscountBg.layer.cornerRadius = 70/2.0;
                cell.imgDiscountBg.layer.cornerRadius = cell.imgDiscountBg.frame.size.height/2.0;
                //                    [cell.labelDiscount setFont:[UIFont systemFontOfSize:16]];
                [cell.labelDiscount setUIFont:kUIFontType16 isBold:false];
                [cell.labelDiscount setUIFont:kUIFontType16 isBold:true];
                
                
            } else {
                //                    cell.imgDiscountBg.layer.cornerRadius = 50/2.0;
                cell.imgDiscountBg.layer.cornerRadius = cell.imgDiscountBg.frame.size.height/2.0;
                //                    [cell.labelDiscount setFont:[UIFont systemFontOfSize:10]];
                [cell.labelDiscount setUIFont:kUIFontType10 isBold:false];
                [cell.labelDiscount setUIFont:kUIFontType10 isBold:true];
                
            }


            
            
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
                //                    if ([cell.layer valueForKey:@"PINFO_OBJ"] == nil)
                {
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
                }
                
                
                
                [cell.buttonCart addTarget:self action:@selector(cartButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                [cell.buttonAdd addTarget:self action:@selector(addButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                [cell.buttonSubstract addTarget:self action:@selector(substractButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                //                    [cell.textFieldAmt addTarget:self action:@selector(cartButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            }
            

            /////////////////
            [Utility setImage:cell.productImg url:pImage._src resizeType:kRESIZE_TYPE_PRODUCT_THUMBNAIL isLocal:false highPriority:false];
            //            [Utility setImage:cell.productImg url:pImage._src resizeType:kRESIZE_TYPE_PRODUCT_THUMBNAIL isLocal:false];
            
            switch ([[DataManager sharedManager] layoutIdProductView]) {
                case P_LAYOUT_DEFAULT:
                    break;
                case P_LAYOUT_FULL_ICON_BUTTON:
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
            break;
        default:
            break;
    }
    [cell setNeedsLayout];
    return cell;
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
            
        case _kShowAllItems:
        {
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
            UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)[collectionView collectionViewLayout];
            layout.minimumInteritemSpacing = cardHorizontalSpacing;
            layout.minimumLineSpacing = cardVerticalSpacing;
            
            _propCollectionView[i]._insetTop =  insetTop;
            _propCollectionView[i]._insetLeft =  insetLeft;
            _propCollectionView[i]._insetBottom =  insetBottom;
            _propCollectionView[i]._insetRight =  insetRight;
            
            return CGSizeMake(cardWidth, cardHeight);
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
            
        case _kShowAllItems:
        {
//                        ProductInfo *pInfo = (ProductInfo *) ([_searchedItems objectAtIndex:indexPath.row]);
//                        [self clickOnProduct:pInfo currentItemData:nil];
        } break;
        default:
            break;
    }
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
                    [_spinnerView setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)];
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
    
    if([[Addons sharedManager] show_categories_in_search]){
        if (_categoryView) {
            CGRect rect = self.view.frame;
            rect.origin.y = CGRectGetMaxY(_searchBar.frame);
            rect.size.height = self.view.frame.size.height - rect.origin.y;
            _categoryView.frame = rect;
            _treeView.frame = CGRectMake(0, 0, _categoryView.frame.size.width, _categoryView.frame.size.height);
            [_treeView reloadData];
        }
    }
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
        }
    }
    
    [_scrollView setContentSize:CGSizeMake(_scrollView.contentSize.width, globalPosY)];
}
#pragma mark - HorizontalLine
- (void)addHorizontalLine:(int)tag {
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
    lineView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    lineView.backgroundColor = [Utility getUIColor:kUIColorBorder];
    [_scrollView addSubview:lineView];
    [_viewsAdded addObject:lineView];
    [lineView setTag:tag];
}
- (void)removeUserDefinedView:(int)viewId {
    _isViewUserDefinedEnable[viewId] = false;
    [_viewUserDefinedHeader[viewId] removeFromSuperview];
    [_viewsAdded removeObject:_viewUserDefinedHeader[viewId]];
    [_viewUserDefined[viewId] removeFromSuperview];
    [_viewsAdded removeObject:_viewUserDefined[viewId]];
    [self resetMainScrollView];
}

- (void)clickOnProduct:(ProductInfo*)productClicked currentItemData:(DataPass*)currentItemData cell:(id)cell{
    if ([[Addons sharedManager] geoLocation] && [[[Addons sharedManager] geoLocation] isEnabled]) {
        //        [_searchController.searchBar resignFirstResponder];
    }else{
        [_searchBar resignFirstResponder];
    }

    
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
    [vcProduct loadData:clickedItemData previousItem:previousItemData drillingLevel:0];
    vcProduct.parentVC = self;
    vcProduct.parentCell = cell;
}

- (void)startLoadingAnim {
    RLOG(@"startLoadingAnim");
    [self stopLoadingAnim];
    _spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [_scrollView addSubview:_spinnerView];
    [_spinnerView setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)];
    [_spinnerView startAnimating];
}
- (void)stopLoadingAnim {
    RLOG(@"stopLoadingAnim");
    [_spinnerView removeFromSuperview];
    _spinnerView = nil;
}
#pragma mark Grocery mode
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
//#if ENABLE_CATEGORY_IN_SEARCH_SCREEN
#pragma mark TreeView Delegate methods
- (CGFloat)treeView:(RATreeView *)treeView heightForRowForItem:(id)item{
    return 50;
}
- (BOOL)treeView:(RATreeView *)treeView canEditRowForItem:(id)item{
    return NO;
}
- (void)treeView:(RATreeView *)treeView willExpandRowForItem:(id)item{
    RATableViewCell *cell = (RATableViewCell *)[treeView cellForItem:item];
    RADataObject *data = item;
    if (data != nil) {
        [cell.btn_addition setUIImage:[UIImage imageNamed:data.imgCollapsePath] forState:UIControlStateNormal];
        data.isExpanded = true;
    }
}
- (void)treeView:(RATreeView *)treeView willCollapseRowForItem:(id)item{
    RATableViewCell *cell = (RATableViewCell *)[treeView cellForItem:item];
    RADataObject *data = item;
    if (data != nil) {
        [cell.btn_addition setUIImage:[UIImage imageNamed:data.imgExpandPath] forState:UIControlStateNormal];
        //        data.isExpanded = false;
    }
}
- (void)treeView:(RATreeView *)treeView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowForItem:(id)item{
}
#pragma mark TreeView Data Source
- (UITableViewCell *)treeView:(RATreeView *)treeView cellForItem:(id)item{
    RADataObject *dataObject = item;
    
    RATableViewCell *cell = [treeView dequeueReusableCellWithIdentifier:@"RATableViewCell"];
    if (! cell) {
        NSArray *parts = [[NSBundle mainBundle] loadNibNamed:@"RATableViewCell" owner:nil options:nil];
        cell = [parts objectAtIndex:0];
    }
    
    //    cell.translatesAutoresizingMaskIntoConstraints = YES;
    cell.label_name.translatesAutoresizingMaskIntoConstraints = YES;
    cell.img_icon.translatesAutoresizingMaskIntoConstraints = YES;
    cell.img_children.translatesAutoresizingMaskIntoConstraints = YES;
    cell.btn_addition.translatesAutoresizingMaskIntoConstraints = YES;
    
    if (dataObject == [self.dataObjects lastObject]) {
        //        [cell.img_children setHidden:true];
    }
    
    NSInteger level = [self.treeView levelForCellForItem:item];
    NSInteger numberOfChildren = [dataObject.children count];
    
    if (numberOfChildren > 0) {
        [cell setAdditionButtonHidden:NO];
    }else{
        [cell setAdditionButtonHidden:YES];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    if (level == 0) {
        [cell.label_name setTextColor:[Utility getUIColor:kUIColorFontListViewLevel0]];
    } else if (level == 1) {
        [cell.label_name setTextColor:[Utility getUIColor:kUIColorFontListViewLevel1]];
    } else if (level >= 2) {
        [cell.label_name setTextColor:[Utility getUIColor:kUIColorFontListViewLevel2Plus]];
    }
    //    [cell.label_name setText:dataObject.title];
    [cell.label_name setText:[Utility getNormalStringFromAttributed:dataObject.title]];
    [cell.label_name setUIFont:kUIFontType16 isBold:true];
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        [cell.label_name setTextAlignment:NSTextAlignmentRight];
    } else {
        [cell.label_name setTextAlignment:NSTextAlignmentLeft];
    }
    
    CGRect img_iconFrame = cell.img_icon.frame;
    
    
    if ([[MyDevice sharedManager] isIpad]) {
        img_iconFrame.origin.x = _gap + (_gap*5) * level;
    } else {
        img_iconFrame.origin.x = _gap + (_gap*2) * level;
    }
    cell.img_icon.frame = img_iconFrame;
    //    [cell.img_icon setUIImage:[UIImage imageNamed:dataObject.imgPath]];
    
    [Utility setImage:cell.img_icon url:dataObject.imgPath resizeType:0 isLocal:false highPriority:false];
    
    
    
    CGRect label_nameFrame = cell.label_name.frame;
    label_nameFrame.origin.x = img_iconFrame.origin.x + img_iconFrame.size.width + _gap;
    cell.label_name.frame = label_nameFrame;
    
    CGRect img_childrenFrame = cell.img_children.frame;
    img_childrenFrame.origin.x = _gap + cell.img_icon.frame.size.width;
    cell.img_children.frame = img_childrenFrame;
    
    //    RLOG(@"POSX=%.f", cell.frame.size.width - cell.btn_addition.frame.size.width - _gap);
    
    cell.btn_addition.center = CGPointMake(self.view.frame.size.width - cell.btn_addition.frame.size.width - _gap, cell.btn_addition.center.y);
    
    //    if (dataObject.isExpanded == false) {
    [cell.btn_addition setUIImage:[UIImage imageNamed:dataObject.imgExpandPath] forState:UIControlStateNormal];
    //    }
    //    else {
    //        [cell.btn_addition setUIImage:[UIImage imageNamed:dataObject.imgCollapsePath] forState:UIControlStateNormal];
    //    }
    
    //
    
    if([dataObject.title isEqualToString:@""]) {
        cell.img_children.hidden = true;
    }else{
        cell.img_children.hidden = false;
    }
    
    float maxLabelX = CGRectGetMaxX(cell.label_name.frame);
    float minButtonX = CGRectGetMinX(cell.btn_addition.frame);
    float diff = maxLabelX - minButtonX;
    label_nameFrame.size.width = label_nameFrame.size.width - diff;
    cell.label_name.frame = label_nameFrame;
    
    RLOG(@"dataObject.name = %@, %.f", dataObject.title, cell.img_icon.frame.origin.x);
    [cell setNeedsLayout];
    return cell;
}
- (NSInteger)treeView:(RATreeView *)treeView numberOfChildrenOfItem:(id)item{
    RADataObject *data = item;
    if (item == nil) {
        return [self.dataObjects count];
    }
    return [data.children count];
}
- (id)treeView:(RATreeView *)treeView child:(NSInteger)index ofItem:(id)item{
    RADataObject *data = item;
    if (item == nil) {
        return [self.dataObjects objectAtIndex:index];
    }
    return data.children[index];
}
- (void)treeView:(RATreeView *)treeView didSelectRowForItem:(id)item {
    RADataObject *data = item;
    //    ViewControllerMain* mainVC = [ViewControllerMain getInstance];
    if (data) {
        if (data.cInfo) {
            //object is category
            if ([data.children count] == 0) {
                DataPass* dp = nil;
                [self clickOnCategory:data.cInfo currentItemData:dp];
                //                [mainVC.revealController revealToggle:self];
            }
        }
        
    }
    
    
}
- (void)treeView:(RATreeView *)treeView didDeselectRowForItem:(id)item {
}
#pragma mark category methods
- (void)loadCategoryView {
    if (_categoryView != nil) {
        return;
    }
    if ([[MyDevice sharedManager] isIpad]) {
        _rowH = 65.0f;
        _gap = 10.0f;
    } else {
        _rowH = 65.0f;
        _gap = 7.0f;
    }
    
    self.dataObjects = [[NSMutableArray alloc] init];
    
    CGRect treeViewRect = self.view.bounds;
    
    
    _categoryView = [[UIView alloc] initWithFrame:treeViewRect];
    [_categoryView setBackgroundColor:[UIColor whiteColor]];
    [self.view insertSubview:_categoryView atIndex:999];
    
    
    
    RATreeView *treeView = [[RATreeView alloc] initWithFrame:treeViewRect];
    treeView.delegate = self;
    treeView.dataSource = self;
    treeView.separatorStyle = RATreeViewCellSeparatorStyleNone;
    self.treeView = treeView;
    treeView.collapsesChildRowsWhenRowCollapses = true;
    
    [self.treeView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self.treeView setScrollEnabled:true];
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController setTitle:NSLocalizedString(@"Things", nil)];
    //    [self updateNavigationItemButton];
    [_categoryView addSubview:treeView];
    
    //    CGRect rect = self.view.frame;
    //    rect.origin.y = CGRectGetMaxY(_searchBar.frame);
    //    rect.size.height = self.view.frame.size.height - rect.origin.y;
    //    _categoryView.frame =  rect;
    //    [_treeView reloadData];
    
    
    int systemVersion = [[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."][0] intValue];
    if (systemVersion >= 7 && systemVersion < 8) {
        CGRect statusBarViewRect = [[UIApplication sharedApplication] statusBarFrame];
        float heightPadding = statusBarViewRect.size.height + self.navigationController.navigationBar.frame.size.height;
        self.treeView.contentInset = UIEdgeInsetsMake(heightPadding, 0.0, 0.0, 0.0);
        self.treeView.contentOffset = CGPointMake(0.0, -heightPadding);
    }
    
    
    if (_categoryView) {
        CGRect rect = self.view.frame;
        rect.origin.y = CGRectGetMaxY(_searchBar.frame);
        rect.size.height = self.view.frame.size.height - rect.origin.y;
        _categoryView.frame = rect;
        _treeView.frame = CGRectMake(0, 0, _categoryView.frame.size.width, _categoryView.frame.size.height);
        [_treeView reloadData];
    }
    
    
    //    RADataObject* categoryObject = [[RADataObject alloc] init];
    //    NSString* itemName = @"default";
    //    NSString* itemImagePath = @"default";
    //    NSString* itemImageExpandPath = @"img_plus.png";
    //    NSString* itemImageCollapsePath = @"img_minus.png";
    //    itemName = Localize(@"title_categories");
    //    itemImagePath = @"btn_category.png";
    //    categoryObject.title = itemName;
    //    categoryObject.imgPath = itemImagePath;
    //    categoryObject.imgCollapsePath = itemImageCollapsePath;
    //    categoryObject.imgExpandPath = itemImageExpandPath;
    //    [self.dataObjects removeAllObjects];
    //    [self.dataObjects addObject:categoryObject];
    
    for (CategoryInfo* cInfo in [CategoryInfo getAllRootCategories]) {
        //        RADataObject* categoryObject = [[RADataObject alloc] init];
        
        CategoryInfo *category = cInfo;
        //        for (category in [_categoryArray reverseObjectEnumerator]) {
        NSString* itemImageExpandPath = @"img_plus.png";
        NSString* itemImageCollapsePath = @"img_minus.png";
        RADataObject * raObj = [[RADataObject alloc] init];
        raObj.title = category._name;
        raObj.imgPath = category._image;
        raObj.cInfo = category;
        raObj.imgCollapsePath = itemImageCollapsePath;
        raObj.imgExpandPath = itemImageExpandPath;
        [self.dataObjects addObject:raObj];
        RLOG(@"%@",[category getSubCategories]);
        [self addCategoriesRecursive:raObj categoryArray:[category getSubCategories]];
        //        }
    }
    //    [self addCategoriesRecursive:categoryObject categoryArray:[CategoryInfo getAllRootCategories]];
    
    [self.dataObjects addObject:[[RADataObject alloc] init]];
    [self.dataObjects addObject:[[RADataObject alloc] init]];
    [self.dataObjects addObject:[[RADataObject alloc] init]];
    [self.dataObjects addObject:[[RADataObject alloc] init]];
    [self.dataObjects addObject:[[RADataObject alloc] init]];
    
    
}
- (void)addCategoriesRecursive:(RADataObject*)_raDataObj categoryArray:(NSMutableArray*)_categoryArray {
    CategoryInfo *category = nil;
    for (category in [_categoryArray reverseObjectEnumerator]) {
        NSString* itemImageExpandPath = @"img_plus.png";
        NSString* itemImageCollapsePath = @"img_minus.png";
        RADataObject * raObj = [[RADataObject alloc] init];
        raObj.title = category._name;
        raObj.imgPath = category._image;
        raObj.cInfo = category;
        raObj.imgCollapsePath = itemImageCollapsePath;
        raObj.imgExpandPath = itemImageExpandPath;
        [_raDataObj addChild:raObj];
        RLOG(@"%@",[category getSubCategories]);
        [self addCategoriesRecursive:raObj categoryArray:[category getSubCategories]];
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
    
    ViewControllerCategories* vcCategories = (ViewControllerCategories*)[[Utility sharedManager] pushScreenWithoutAnimation:mainVC.vcCenterTop type:PUSH_SCREEN_TYPE_CATEGORY];
    [vcCategories loadData:clickedItemData previousItem:previousItemData drillingLevel:0];
}
- (void)clickOnProduct:(ProductInfo*)productClicked currentItemData:(DataPass*)currentItemData{
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
}

//#pragma mark - Table View
//#pragma mark - Actions
//- (void)editButtonTapped:(id)sender{
//    [self.treeView setEditing:!self.treeView.isEditing animated:YES];
//    [self updateNavigationItemButton];
//}
//- (void)updateNavigationItemButton{
//    UIBarButtonSystemItem systemItem = self.treeView.isEditing ? UIBarButtonSystemItemDone : UIBarButtonSystemItemEdit;
//    self.editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:systemItem target:self action:@selector(editButtonTapped:)];
//    self.navigationItem.rightBarButtonItem = self.editButton;
//}
//#endif
@end
