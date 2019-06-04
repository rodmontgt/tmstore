//
//  ViewControllerRight.m
//  eCommerceApp
//
//  Created by Rishabh Jain on 16/09/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import "ViewControllerRight.h"
#import "SWRevealViewController.h"
#import "Variables.h"
#import "RATreeView.h"
#import "RADataObject.h"
#import "RATableViewCell.h"
#import "ProductInfo.h"
#import "ProductImage.h"
#import "CategoryInfo.h"
#import "LoginViewOnDrawer.h"
#import "LayoutManager.h"
#import "Utility.h"
#import "ViewControllerMain.h"
#import "ViewControllerAddress.h"
#import "ViewControllerLogin.h"
#import "CNPPopupController.h"
#import "AppUser.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "WebViewWordPress.h"
#import "MRProgress.h"
#import "DataManager.h"
#import "Variables.h"
#import "ViewControllerOrder.h"
#import "ViewControllerWebview.h"
#import "LoginFlow.h"
#import "ParseHelper.h"
#if ENABLE_HOTLINE
#import "Hotline.h"
#elif ENABLE_FRESHCHAT
#import "Freshchat.h"
#endif
#import "CustomMenu.h"
#import "Variables.h"
#import "LoginViewOnDrawer.h"
#import "RADataObject.h"
#import "WebViewWordPress.h"
#import "ServerData.h"
#import "CommonInfo.h"
#import "TMMulticastDelegate.h"
#import "Vendor.h"
#import "UIAlertView+NSCookbook.h"
#import "Cart.h"
#import "Wishlist.h"

@interface ViewControllerRight () <RATreeViewDelegate, RATreeViewDataSource>
@property (strong, nonatomic) NSMutableArray *dataObjects;
@property (weak, nonatomic) RATreeView *treeView;
@property (strong, nonatomic) UIBarButtonItem *editButton;
@end

@implementation ViewControllerRight {
    NSMutableArray *recipes;
    NSArray *searchResults;
}
@synthesize tableView = _tableView;
@synthesize searchBar = _searchBar;
@synthesize searchDisplayController = _searchDisplayController;
#pragma mark - View Life Cycle
- (void)viewDidLoad {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super viewDidLoad];
    _treeView = nil;
    _searchBar.hidden = true;
    _tableView.hidden = true;
    _searchBar.placeholder = Localize(@"vendor_search_placeholder");
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        _searchBar.transform = CGAffineTransformMakeScale(-1, 1);
    }
}
- (void)refreshView {
    if(_treeView != nil){
        return;
    }
    _searchBar.hidden = false;
    _tableView.hidden = true;
    recipes = [[NSMutableArray alloc] init];
    for (Vendor* vendor in [Vendor getAllVendors]) {
        [recipes addObject:vendor.vendorName];
    }
    _tableView.bounces = false;
    if ([[MyDevice sharedManager] isIpad]) {
        _rowH = 65.0f;
        _gap = 10.0f;
    } else {
        _rowH = 65.0f;
        _gap = 7.0f;
    }
    _chkBoxLanguage = [[NSMutableArray alloc] init];
    
    
    [self loadData];
    
    //ADD LOGIN VIEW ON TOP
    float topViewHeight = [[Utility sharedManager] getTopBarHeight];
    CGRect topRect = self.view.bounds;
    topRect.size.height = topViewHeight;
    _headerView = [[UIView alloc] initWithFrame:topRect];
    _headerView.backgroundColor = [UIColor whiteColor];
    [ _headerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self.view addSubview: _headerView];
    
    UILabel* label = [[UILabel alloc] init];
    [label setUIFont:kUIFontType20 isBold:false];
    [label setText:Localize(@"title_change_vendor")];
    
    [label setTextColor:[Utility getUIColor:kUIColorThemeFont]];
    CGRect labelRect = _headerView.frame;
    labelRect.origin.y = 11;
    [label setFrame:labelRect];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [_headerView addSubview:label];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, _headerView.frame.origin.y + _headerView.frame.size.height - 1, self.view.frame.size.width, 1)];
    lineView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    lineView.backgroundColor = [Utility getUIColor:kUIColorBorder];
    [self.view addSubview:lineView];
    
//    ViewControllerMain* vcMain = [ViewControllerMain getInstance];
//    NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:vcMain.vcTopBar.buttonRightView];
//    _buttonDrawer = [NSKeyedUnarchiver unarchiveObjectWithData: archivedData];
//    _buttonDrawer.translatesAutoresizingMaskIntoConstraints = YES;
//    [_buttonDrawer addTarget:[[ViewControllerMain getInstance] revealController] action: @selector(rightRevealToggle:) forControlEvents: UIControlEventTouchUpInside];
//    [_buttonDrawer setNeedsLayout];
//    [_buttonDrawer setHidden:false];
//    [_buttonDrawer setContentMode:UIViewContentModeCenter];
//    [_buttonDrawer setCenter:CGPointMake(_buttonDrawer.frame.origin.x + _buttonDrawer.frame.size.width / 2, topRect.size.height / 2  + [[Utility sharedManager] getStatusBarHeight]/2)];
//    [_headerView addSubview:_buttonDrawer];
    //ADD TABLE VIEW
    RATreeView *treeView = [[RATreeView alloc] init];
    treeView.delegate = self;
    treeView.dataSource = self;
    treeView.separatorStyle = RATreeViewCellSeparatorStyleNone;
    self.treeView = treeView;
    treeView.collapsesChildRowsWhenRowCollapses = true;
    [self.view insertSubview:treeView atIndex:0];
    [self.treeView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self.treeView setScrollEnabled:true];
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController setTitle:NSLocalizedString(@"Things", nil)];
    [self updateNavigationItemButton];
    [self.treeView setBounces:false];
    
    _searchDisplayController.searchResultsTableView.bounces = false;

    
    UILabel* labelNoItemsFound = [[UILabel alloc] initWithFrame:_searchDisplayController.searchContentsController.view.frame];
    [labelNoItemsFound setUIFont:kUIFontType20 isBold:false];
    labelNoItemsFound.textColor = [Utility getUIColor:kUIColorFontLight];
    [labelNoItemsFound setTextAlignment:NSTextAlignmentCenter];
    [labelNoItemsFound setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [labelNoItemsFound setText:Localize(@"no_vendor_found")];
    [_searchDisplayController setValue:labelNoItemsFound forKey: @"noResultsLabel"];
    
    [self setFrames];
    [_treeView reloadData];
}
-(void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller {
    UIButton *cancelButton = nil;
    if (_searchDisplayController && _searchDisplayController.searchBar && _searchDisplayController.searchBar.subviews && _searchDisplayController.searchBar.subviews.count > 0) {
        UIView *topView = _searchDisplayController.searchBar.subviews[0];
        if (topView) {
            for (UIView *subView in topView.subviews) {
                if ([subView isKindOfClass:NSClassFromString(@"UINavigationButton")]) {
                    cancelButton = (UIButton*)subView;
                }
            }
        }
    }
    if (cancelButton) {
        [cancelButton setTitle:Localize(@"cancel") forState:UIControlStateNormal];
    }
}
- (void)viewWillAppear:(BOOL)animated {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super viewWillAppear:animated];
    
    //rv//[SDWebImageManager.sharedManager.imageDownloader setValue:@"SDWebImage Demo" forHTTPHeaderField:@"AppName"];
//    SDWebImageManager.sharedManager.imageDownloader.executionOrder = SDWebImageDownloaderFIFOExecutionOrder;
    
    int systemVersion = [[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."][0] intValue];
    if (systemVersion >= 7 && systemVersion < 8) {
        CGRect statusBarViewRect = [[UIApplication sharedApplication] statusBarFrame];
        float heightPadding = statusBarViewRect.size.height+self.navigationController.navigationBar.frame.size.height;
        self.treeView.contentInset = UIEdgeInsetsMake(heightPadding, 0.0, 0.0, 0.0);
        self.treeView.contentOffset = CGPointMake(0.0, -heightPadding);
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(vendorDataSucceed:)
                                                 name:@"VENDOR_DATA_SUCCESS"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(vendorDataFailed:)
                                                 name:@"VENDOR_DATA_FAILED"
                                               object:nil];
    if ([[Addons sharedManager] multiVendor_enable] &&
        [[Addons sharedManager] multiVendor_screen_type] == MULTIVENDOR_SCREEN_SELLER) {
        if ([[[DataManager sharedManager] tmDataDoctor] isVendorDataFetched]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"VENDOR_DATA_SUCCESS" object:nil];
        } else {
            [[[DataManager sharedManager] tmDataDoctor] fetchVendorDataFromPlugin];
        }
    }
    [self adjustViewsAfterOrientation:UIDeviceOrientationUnknown];
}
- (void)vendorDataSucceed:(NSNotification*)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"VENDOR_DATA_SUCCESS" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"VENDOR_DATA_FAILED" object:nil];
    
    [self refreshView];
    [self adjustViewsAfterOrientation:UIDeviceOrientationUnknown];
}
- (void)vendorDataFailed:(NSNotification*)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"VENDOR_DATA_SUCCESS" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"VENDOR_DATA_FAILED" object:nil];
}
- (void)flushCache {
    [SDWebImageManager.sharedManager.imageCache clearMemory];
    
}
- (void)didReceiveMemoryWarning {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super didReceiveMemoryWarning];
}
#pragma mark - Table View
#pragma mark - Actions
- (void)editButtonTapped:(id)sender{
    [self.treeView setEditing:!self.treeView.isEditing animated:YES];
    [self updateNavigationItemButton];
}
- (void)updateNavigationItemButton{
    UIBarButtonSystemItem systemItem = self.treeView.isEditing ? UIBarButtonSystemItemDone : UIBarButtonSystemItemEdit;
    self.editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:systemItem target:self action:@selector(editButtonTapped:)];
    self.navigationItem.rightBarButtonItem = self.editButton;
}
#pragma mark TreeView Delegate methods
- (CGFloat)treeView:(RATreeView *)treeView heightForRowForItem:(id)item{
    return 50;
    //    return [[LayoutManager sharedManager] leftViewProp]->rowHeight_PWRTH_MAX * [[MyDevice sharedManager] screenHeightInPortrait] / 100.0f;
}
- (BOOL)treeView:(RATreeView *)treeView canEditRowForItem:(id)item{
    return NO;
}
- (void)treeView:(RATreeView *)treeView willExpandRowForItem:(id)item{
    RATableViewCell *cell = (RATableViewCell *)[treeView cellForItem:item];
    RADataObject *data = item;
    if (data != nil) {
        [cell.btn_addition setUIImage:[UIImage imageNamed:data.imgCollapsePath] forState:UIControlStateNormal];
    }
}
- (void)treeView:(RATreeView *)treeView willCollapseRowForItem:(id)item{
    RATableViewCell *cell = (RATableViewCell *)[treeView cellForItem:item];
    RADataObject *data = item;
    if (data != nil) {
        [cell.btn_addition setUIImage:[UIImage imageNamed:data.imgExpandPath] forState:UIControlStateNormal];
    }
}
- (void)treeView:(RATreeView *)treeView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowForItem:(id)item{
    //    if (editingStyle != UITableViewCellEditingStyleDelete) {
    //        return;
    //    }
    //
    //    RADataObject *parent = [self.treeView parentForItem:item];
    //    NSInteger index = 0;
    //
    //    if (parent == nil) {
    //        index = [self.dataObjects indexOfObject:item];
    //        NSMutableArray *children = [self.dataObjects mutableCopy];
    //        [children removeObject:item];
    //        self.dataObjects = [children copy];
    //
    //    } else {
    //        index = [parent.children indexOfObject:item];
    //        [parent removeChild:item];
    //    }
    //
    //    [self.treeView deleteItemsAtIndexes:[NSIndexSet indexSetWithIndex:index] inParent:parent withAnimation:RATreeViewRowAnimationRight];
    //    if (parent) {
    //        [self.treeView reloadRowsForItems:@[parent] withRowAnimation:RATreeViewRowAnimationNone];
    //    }
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
    
    
    [cell.label_name setUIFont:kUIFontType16 isBold:false];
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        [cell.label_name setTextAlignment:NSTextAlignmentRight];
    } else {
        [cell.label_name setTextAlignment:NSTextAlignmentLeft];
    }
    
    CGRect img_iconFrame = cell.img_icon.frame;
    img_iconFrame.origin.x = _gap + (_gap*2) * level;
    img_iconFrame.origin.y = 0;
    img_iconFrame.size.height = 50;
    cell.img_icon.frame = img_iconFrame;
    cell.img_icon.contentMode = UIViewContentModeScaleAspectFit;
    [cell.img_icon setUIImage:[UIImage imageNamed:dataObject.imgPath]];
    [cell.img_icon setClipsToBounds:true];
//    cell.img_icon.layer.borderWidth = 1;
    
    
    
    if([[Addons sharedManager] multiVendor]) {
        if ([dataObject.imgPath isEqualToString:@"sellerN.png"]){
            if (![[[[Addons sharedManager] multiVendor] multiVendor_icon_url] isEqualToString:@""] && [[[Addons sharedManager] multiVendor] multiVendor_icon_reuse]) {
                [Utility setImage:cell.img_icon url:[[[Addons sharedManager] multiVendor] multiVendor_icon_url] resizeType:0 isLocal:false highPriority:true];
            }
            else if (![dataObject.vendorInfo.vendorIconUrl isEqualToString:@""]) {
                [Utility setImage:cell.img_icon url:dataObject.vendorInfo.vendorIconUrl resizeType:0 isLocal:false highPriority:true];
            }
        }
    }
    
    CGRect label_nameFrame = cell.label_name.frame;
    label_nameFrame.origin.x = img_iconFrame.origin.x + img_iconFrame.size.width + _gap;
    cell.label_name.frame = label_nameFrame;
    
    CGRect img_childrenFrame = cell.img_children.frame;
    img_childrenFrame.origin.x = 0;//_gap + cell.img_icon.frame.size.width;
    cell.img_children.frame = img_childrenFrame;
    
    //    RLOG(@"POSX=%.f", cell.frame.size.width - cell.btn_addition.frame.size.width - _gap);
    
    cell.btn_addition.center = CGPointMake(self.view.frame.size.width - cell.btn_addition.frame.size.width - _gap, cell.btn_addition.center.y);
    [cell.btn_addition setUIImage:[UIImage imageNamed:dataObject.imgExpandPath] forState:UIControlStateNormal];
    
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
    if (data && data.vendorInfo) {
        [self vendorSelected:data.vendorInfo];
    }
}
- (void)vendorSelected:(Vendor*)vendorInfo {
    if (vendorInfo) {
#if ASK_SET_VENDOR_EVERY_TIME
        NSString* alertViewTitle = Localize(@"title_change_vendor");
        NSString* alertViewDesc = Localize(@"vendor_change_confirmation");
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:alertViewTitle message:alertViewDesc delegate:self cancelButtonTitle:Localize(@"cancel") otherButtonTitles:Localize(@"i_ok"), nil];
        [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [self changeVendor:vendorInfo];
            }
        }];
#elif ASK_SET_VENDOR_ONLY_IF_CART_WISHLIST_HAVE_ITEM
        int cartItems = (int)[[Cart getAll] count];
        int wishlistItems = (int)[[Wishlist getAll] count];
        if (cartItems || wishlistItems) {
            NSString* alertViewTitle = Localize(@"title_change_vendor");
            NSString* alertViewDesc = Localize(@"vendor_change_confirmation");
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:alertViewTitle message:alertViewDesc delegate:self cancelButtonTitle:Localize(@"cancel") otherButtonTitles:Localize(@"i_ok"), nil];
            [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (buttonIndex == 1) {
                    [self changeVendor:vendorInfo];
                }
            }];
        } else {
            [self changeVendor:vendorInfo];
        }
#else
        [self changeVendor:vendorInfo];
#endif
    }
}
- (void)changeVendor:(Vendor*)vendorInfo {
    NSString* vendorId = [[NSUserDefaults standardUserDefaults] valueForKey:VENDOR_ID];
    if (![vendorId isEqualToString:vendorInfo.vendorId]) {
        [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%@", vendorInfo.vendorId] forKey:VENDOR_ID];
        [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%@", vendorInfo.vendorName] forKey:VENDOR_NAME];
        [self startTimer];
    }
}
- (void)startTimer {
    [self performSelector:@selector(refreshViewController:) withObject:nil afterDelay:1.0f] ;
}
- (void)treeView:(RATreeView *)treeView didDeselectRowForItem:(id)item {
}

#pragma mark - Helpers
- (void)loadData {

    self.dataObjects = [[NSMutableArray alloc] init];
    RADataObject *item[15];
    _menuObjects = nil;
    
    
    [self.dataObjects addObject:[[RADataObject alloc] init]];
    [self.dataObjects addObject:[[RADataObject alloc] init]];
    [self.dataObjects addObject:[[RADataObject alloc] init]];
    [self.dataObjects addObject:[[RADataObject alloc] init]];
    [self.dataObjects addObject:[[RADataObject alloc] init]];
    
    
//    int categoryObjIndex = (int)[self.dataObjects indexOfObject:_categoryObject];
    [self addCustomMenu:0];
    
}
- (void)addCustomMenu:(int)objIndex {
    if ([[Addons sharedManager] multiVendor_enable] &&
        [[Addons sharedManager] multiVendor_screen_type] == MULTIVENDOR_SCREEN_SELLER) {
        NSMutableArray* arrayLocations = [Vendor getVendorLocations];
        for (NSString* loc in arrayLocations) {
            if (![loc isEqualToString:@""]) {
                RADataObject * raObj = [[RADataObject alloc] init];
                raObj.title = loc;
                raObj.imgPath = @"btn_trackN.png";
                [self.dataObjects insertObject:raObj atIndex:objIndex++];
                NSMutableArray* arrayVendors = [Vendor getVendorsByLocation:loc];
                [self addCustomMenuItems:raObj cMenuChildren:arrayVendors];
            }
        }
    }
}

- (void)addCustomMenuItems:(RADataObject*)raObj cMenuChildren:(NSMutableArray*)cMenuChildren{
    for (Vendor* vendor in cMenuChildren) {
        RADataObject * raObjChild = [[RADataObject alloc] init];
        raObjChild.title = vendor.vendorName;
        raObjChild.imgPath = @"sellerN.png";
        raObjChild.vendorInfo = vendor;
        [raObj addChild:raObjChild];
    }
}
#pragma mark - Adjust Orientation
- (void)adjustViewsForOrientation:(UIDeviceOrientation) orientation {
    RLOG(@"adjustViewsAfterOrientation");
    [self setFrames];
}
- (void)adjustViewsAfterOrientation:(UIDeviceOrientation) orientation {
    RLOG(@"adjustViewsAfterOrientation");
    [self setFrames];
    if (_treeView) {
        [_treeView reloadData];
    }
}
- (void)setFrames{
    float topViewHeight = [[Utility sharedManager] getTopBarHeight];
    if (_headerView) {
        CGRect rect = self.view.frame;
        rect.size.height = topViewHeight;
        _headerView.frame = rect;
//        [_buttonDrawer setCenter:CGPointMake(_buttonDrawer.frame.origin.x + _buttonDrawer.frame.size.width / 2, rect.size.height / 2  + [[Utility sharedManager] getStatusBarHeight]/2)];
    }
    if (_searchBar) {
        _searchBarTopSpaceConstraint.constant = CGRectGetMaxY(_headerView.frame);
        _searchBar.clipsToBounds = true;
    }
    if (_tableView) {
//        _searchDisplayController.searchResultsTableView.frame = _tableView.frame;
    }
    if (_treeView) {
        CGRect rect = CGRectMake(0, CGRectGetMaxY(_headerView.frame) + 44, self.view.frame.size.width, self.view.frame.size.height - (CGRectGetMaxY(_headerView.frame) + 44));
        _treeView.frame =  rect;
    }
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    if ([[AppDelegate getInstance] isAppEnteredInBackground]) {
        return;
    }
    [self adjustViewsAfterOrientation:[[UIDevice currentDevice] orientation]];
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if ([[AppDelegate getInstance] isAppEnteredInBackground]) {
        return;
    }
    [self adjustViewsForOrientation:[[UIDevice currentDevice] orientation]];
}

///////////////////////////////
#pragma mark - LOGIN
- (void)refreshViewController:(float)dt {
    AppUser* appUser = [AppUser sharedManager];
    [appUser clearSelectedData];
    
    [ViewControllerMain resetInstance];
    UIStoryboard *sb = [Utility getStoryBoardObject];
    UIViewController *rootViewController = [sb instantiateViewControllerWithIdentifier:VC_SPLASH_SECONDARY];
    [[UIApplication sharedApplication].keyWindow setRootViewController:rootViewController];
}

#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _searchDisplayController.searchResultsTableView) {
        return [searchResults count];
    }
    return [recipes count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"RecipeCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    if (tableView == _searchDisplayController.searchResultsTableView) {
        cell.textLabel.text = [searchResults objectAtIndex:indexPath.row];
    } else {
        cell.textLabel.text = [recipes objectAtIndex:indexPath.row];
    }
    [cell.textLabel setTextColor:[Utility getUIColor:kUIColorFontListViewLevel0]];
    [cell.textLabel setUIFont:kUIFontType16 isBold:false];
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        [cell.textLabel setTextAlignment:NSTextAlignmentRight];
    } else {
        [cell.textLabel setTextAlignment:NSTextAlignmentLeft];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _searchDisplayController.searchResultsTableView) {
        NSString* str = [searchResults objectAtIndex:indexPath.row];
        Vendor* vendorInfo = [Vendor getVendorByName:str];
        if (vendorInfo) {
            [self vendorSelected:vendorInfo];
        }
    }
}
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", searchText];
    searchResults = [recipes filteredArrayUsingPredicate:resultPredicate];
}
#pragma mark - UISearchDisplayController delegate methods
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterContentForSearchText:searchString scope:[[_searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[_searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    return YES;
}
- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView{
    _tableView.hidden = false;
}
- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView{
    _tableView.hidden = true;
}
@end
