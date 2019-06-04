//
//  ViewControllerPlatformSelection.m
//  eCommerceApp
//
//  Created by Rishabh Jain on 16/09/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import "ViewControllerPlatformSelection.h"
#import "Utility.h"
#import "ParseHelper.h"
#import "DataManager.h"
#import "AppDelegate.h"
#import "UIAlertView+NSCookbook.h"
#import "AnalyticsHelper.h"
#import "CNPPopupController.h"
#import "ParseHelper.h"
#import "StoreConfig.h"
#import "Variables.h"
#import "ShowAllStoresViewController.h"

@interface ViewControllerPlatformSelection() {
    NSMutableArray* _viewsAdded;
    BOOL _showFullList;
    NSArray* storeList;
    NSArray* storeListSearch;

    __weak IBOutlet UIButton *showAllStores;
    UIButton *customBackButton;
}
@property (nonatomic, strong) NSArray *tableData;

@end

@implementation ViewControllerPlatformSelection

#pragma mark - View Life Cycle

- (void)viewDidLoad {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super viewDidLoad];

    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [Utility getUIColor:kUIColorThemeFont], NSForegroundColorAttributeName, [Utility getUIFont:kUIFontType24 isBold:false], NSFontAttributeName, nil]];
    [self.currentItemHeading setTitle:@"   "];

    _labelViewHeading = [[UILabel alloc] init] ;
    [_labelViewHeading setFrame:CGRectMake(0, 10, [[MyDevice sharedManager] screenSize].width, _navigationBar.frame.size.height)];
    [_labelViewHeading setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [_labelViewHeading setUIFont:kUIFontType24 isBold:false];
    [_labelViewHeading setTextColor:[Utility getUIColor:kUIColorThemeFont]];
    [_labelViewHeading setTextAlignment:NSTextAlignmentCenter];
    [_labelViewHeading setText:@"    "];
    [self.view addSubview:_labelViewHeading];

    [_navigationBar setClipsToBounds:false];
    [_lineView setBackgroundColor:[Utility getUIColor:kUIColorBorder]];
    [_scrollView setBackgroundColor:[Utility getUIColor:kUIColorBgTheme]];
    [self.view setBackgroundColor:[Utility getUIColor:kUIColorBgHeader]];
    [_navigationBar setBarTintColor:[Utility getUIColor:kUIColorBgHeader]];

    if (_previousItemHeading) {
        [_previousItemHeading setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[Utility getUIColor:kUIColorThemeFont], NSForegroundColorAttributeName, [Utility getUIFont:kUIFontType18 isBold:false], NSFontAttributeName, nil] forState:UIControlStateNormal];
    }

    NSString* stringAppDisplayName = Localize(@"app_display_name");
    if ([stringAppDisplayName isEqualToString:@""] || [stringAppDisplayName isEqualToString:@"app_display_name"]) {
        stringAppDisplayName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    }
    NSString* appName = stringAppDisplayName;
    [_labelViewHeading setText:appName];




    [self.view setBackgroundColor:[UIColor whiteColor]];

    self.tableView.separatorInset = UIEdgeInsetsMake(10, 0, 10, 0);
    [self.tableView setSeparatorColor:[UIColor whiteColor]];
    self.searchDisplayController.searchResultsTableView.separatorInset = UIEdgeInsetsMake(10, 0, 10, 0);
    [self.searchDisplayController.searchResultsTableView setSeparatorColor:[UIColor whiteColor]];

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

//    if ([Utility isNearBySearch]) {
//        showAllStores.hidden = false;
//    }else{
//        showAllStores.hidden = true;
//    }

}
-(void)viewDidAppear:(BOOL)animated{
#if ENABLE_FIREBASE_TAG_MANAGER
    [[AnalyticsHelper sharedInstance] registerVisitScreenEvent:@"Platform Screen"];
#endif
    [self loadAllPlatformData];
}
- (void)viewDidDisappear:(BOOL)animated {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super viewDidDisappear:animated];
}
- (void)viewWillAppear:(BOOL)animated {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super viewWillAppear:animated];
#if SUPPORT_PORTRAIT_ORIENTATION_ONLY
    [UIViewController attemptRotationToDeviceOrientation];
#endif
    //rv//[SDWebImageManager.sharedManager.imageDownloader setValue:@"SDWebImage Demo" forHTTPHeaderField:@"AppName"];
    //    SDWebImageManager.sharedManager.imageDownloader.executionOrder = SDWebImageDownloaderFIFOExecutionOrder;
    NSString* strSplashUrlPath = @"";
    if ([[MyDevice sharedManager] isIphone]) {
        strSplashUrlPath = [[DataManager sharedManager] splashUrlImgPathPortrait];
    } else if ([[MyDevice sharedManager] isPortrait]) {
        strSplashUrlPath = [[DataManager sharedManager] splashUrlImgPathPortrait];
    } else {
        strSplashUrlPath = [[DataManager sharedManager] splashUrlImgPathLandscape];
    }

    if (_markerInfo == nil) {
#if ENABLE_FULL_SPLASH_ON_LAUNCH
        strSplashUrlPath = @"";
        [_constraintImgLogoWidth setPriority:999];
        [_constraintImgLogoWidthFull setPriority:1000];
        [_imageFg setContentMode:UIViewContentModeScaleToFill];
        [self.view setNeedsUpdateConstraints];
        [self.view bringSubviewToFront:_mainView];
#endif


#if ENABLE_FULL_SPLASH_ON_LAUNCH_NEW
        [_imgSplash setImage:[UIImage imageNamed:strSplashUrlPath]];
        _imageFg.hidden = true;
        [_labelPoweredBy setTextColor:[[DataManager sharedManager] splashTextColor]];
        [_labelVersionInfo setTextColor:[[DataManager sharedManager] splashTextColor]];
#else
        if ([strSplashUrlPath isEqualToString:@""] == false) {
            [_imgSplash sd_setImageWithURL:[NSURL URLWithString:strSplashUrlPath] placeholderImage:nil options:[Utility getImageDownloadOption] progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
#if (ENABLE_FULL_SPLASH_ON_LAUNCH == 0)
                _imageFg.hidden = false;
#endif
                [_labelPoweredBy setTextColor:[Utility getUIColor:kUIColorFontDark]];
                [_labelVersionInfo setTextColor:[Utility getUIColor:kUIColorFontDark]];
            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                _imageFg.hidden = true;
                [_labelPoweredBy setTextColor:[[DataManager sharedManager] splashTextColor]];
                [_labelVersionInfo setTextColor:[[DataManager sharedManager] splashTextColor]];
                [_imgSplash setUIImage:image];
            }];
        } else {
            [_labelPoweredBy setTextColor:[Utility getUIColor:kUIColorFontDark]];
            [_labelVersionInfo setTextColor:[Utility getUIColor:kUIColorFontDark]];
        }
#endif
    }else{
        [_imgSplash setHidden:YES];
        [_imageFg setHidden:YES];

    }

    _labelPoweredBy.hidden = true;
    _labelVersionInfo.hidden = true;
}
- (void)didReceiveMemoryWarning {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super didReceiveMemoryWarning];
}
- (void)viewWillDisappear:(BOOL)animated {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super viewWillDisappear:animated];
}

- (void)loadAllPlatformData {
    if(!_markerInfo) {
        [Utility createCustomizedLoadingBar:Localize(@"i_loading_data") isBottomAlign:true isClearViewEnabled:true isShadowEnabled:true];
    }
    _searchBar.hidden = false;
    _tableView.hidden = true;
    _navigationBar.hidden = true;
    _lineView.hidden = true;
    _labelViewHeading.hidden = true;

    if ([[ParseHelper sharedManager] appDataRows] == nil) {
        [[ParseHelper sharedManager] loadAllPlatformData:^{
            _showFullList = false;
            [self loadPlatformView];
        } failure:^(NSString *error) {
             [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
             [self loadAllPlatformData];
         } markerInfo:nil];
    } else {
        _showFullList = true;
        _searchBar.hidden = false;
        _tableView.hidden = false;
        _navigationBar.hidden = false;
        _lineView.hidden = false;
        _labelViewHeading.hidden = false;

        if (_markerInfo) {
            [[ParseHelper sharedManager] loadAllPlatformData:^{
                _showFullList = true;
                [self loadPlatformView];
            } failure:^(NSString *error)
             {
                 [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
                 //                 [self loadAllPlatformData];
                 //empty view handle
             } markerInfo:_markerInfo];

        }else{
            [self loadPlatformView];
            [showAllStores setHidden:YES];
        }

    }
}
- (void)loadPlatformView {
    BOOL isFirstLaunch = ![[[NSUserDefaults standardUserDefaults] valueForKey:@"MULTISTORE_APP_LAUNCHED"] boolValue];
    NSMutableArray* allStoreConfigs = _markerInfo ? [StoreConfig getAllStoreConfigNearBy] :[StoreConfig getAllStoreConfigs];
    storeList = allStoreConfigs;
    if (!_showFullList) {
        NSMutableArray* allDefaultStoreConfigs = [StoreConfig getAllDefaultStoreConfigs];
        if (isFirstLaunch) {
            if ([Utility isNearBySearch]) {
                UIStoryboard *sb = [Utility getStoryBoardObject];
                UIViewController *rootViewController = [sb instantiateViewControllerWithIdentifier:VC_NEARBYSEARCH];
                [[UIApplication sharedApplication].keyWindow setRootViewController:rootViewController];
                return;
            }
            if (allDefaultStoreConfigs && [allDefaultStoreConfigs count] > 0) {
                storeList = allDefaultStoreConfigs;
                if ([storeList count] ==  1) {
                    //go direct inside app
                    StoreConfig* sc = [storeList objectAtIndex:0];
                    [self proceed:sc];
                    return;
                }
            } else {
                storeList = allStoreConfigs;
            }
        } else {
            if ([Utility isNearBySearch]) {
                UIStoryboard *sb = [Utility getStoryBoardObject];
                UIViewController *rootViewController = [sb instantiateViewControllerWithIdentifier:VC_NEARBYSEARCH];
                [[UIApplication sharedApplication].keyWindow setRootViewController:rootViewController];
                return;
            }

            NSString* selectedPlatform = [[NSUserDefaults standardUserDefaults] valueForKey:@"APPDATA_PLATFORM"];
            if (selectedPlatform && ![selectedPlatform isEqualToString:@""]) {
                StoreConfig* sc = [StoreConfig isStoreConfigExists:selectedPlatform];
                if (sc == nil) {
                    storeList = allStoreConfigs;
                } else {
                    [self proceed:sc];
                    return;
                }
            } else {
                storeList = allStoreConfigs;
            }
        }
    }

    [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];

    _searchBar.hidden = false;
    _tableView.hidden = false;
    _navigationBar.hidden = false;
    _lineView.hidden = false;
    _labelViewHeading.hidden = false;
    _mainView.hidden = true;

    if (storeList.count == 1) {
        _noNearStoreLabel.hidden = true;
        [showAllStores setHidden:NO];
    }
    if (storeList.count == 2) {
        _noNearStoreLabel.hidden = true;
        [showAllStores setHidden:YES];
        customBackButton.hidden = YES;
    }

    storeListSearch = storeList;

    NSMutableArray* data = [[NSMutableArray alloc] init];
    for (StoreConfig* sc in storeList) {
        [data addObject:sc.title];
    }
    self.tableData = data;
    self.searchResult = [NSMutableArray arrayWithCapacity:[self.tableData count]];

    [self.tableView setNeedsLayout];
    [self.tableView layoutIfNeeded];
    [self.tableView reloadData];
    [self.tableView setNeedsLayout];
    [self.tableView layoutIfNeeded];
    [self.tableView reloadData];


    //    if ([storeList count] > 1) {
    //show list
    //        float buttonPosX = 0;
    //        float buttonPosY = 0;
    //        for (StoreConfig* sc in storeList) {
    //            UIButton* button = [[UIButton alloc] init];
    //            [button setTitle:sc.title forState:UIControlStateNormal];
    //            [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    //            button.frame = CGRectMake(buttonPosX, buttonPosY, self.view.frame.size.width, 50);
    //            buttonPosY += 50;
    //            [self.scrollView addSubview:button];
    //            [self.scrollView setContentSize:CGSizeMake(self.scrollView.contentSize.width, MAX(self.scrollView.contentSize.height, buttonPosY))];
    //            [button addTarget:self action:@selector(onPlatformSelectionEvent:) forControlEvents:UIControlEventTouchUpInside];
    //            if ([Utility isMultiStoreAppTMStore]) {
    //                [button.layer setValue:sc.platform forKey:@"PLATFORM_NAME"];
    //            } else {
    //                [button.layer setValue:sc.multi_store_platform forKey:@"PLATFORM_NAME"];
    //            }
    //        }
    //    }
    //    else if ([storeList count] > 0) {
    //        //go direct inside app
    //        StoreConfig* sc = [storeList objectAtIndex:0];
    //        [self proceed:sc];
    //    }
    //    else {
    //don't know
    //    }
}
//- (void)onPlatformSelectionEvent:(UIButton*)sender {
//    NSString* str = [sender.layer valueForKey:@"PLATFORM_NAME"];
//    DataManager* dm = [DataManager sharedManager];
//    dm.appDataPlatformString = str;
//    [[NSUserDefaults standardUserDefaults] setValue:str forKey:@"APPDATA_PLATFORM"];
//    UIStoryboard *sb = [Utility getStoryBoardObject];
//    UIViewController *rootViewController = [sb instantiateViewControllerWithIdentifier:VC_SPLASH_PRIMARY];
//    [[UIApplication sharedApplication].keyWindow setRootViewController:rootViewController];
//}



- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    [self.searchResult removeAllObjects];
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", searchText];
    self.searchResult = [NSMutableArray arrayWithArray: [self.tableData filteredArrayUsingPredicate:resultPredicate]];
    int i = 0;
    NSMutableIndexSet *mutableIndexSet = [[NSMutableIndexSet alloc] init];
    for (NSString* str in self.tableData) {
        if ([self.searchResult containsObject:str]) {
            [mutableIndexSet addIndex:i];
        }
        i++;
    }
    storeListSearch = [storeList objectsAtIndexes:mutableIndexSet];
}
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];

    [self.tableView setNeedsLayout];
    [self.tableView layoutIfNeeded];
    [self.tableView reloadData];
    [self.tableView setNeedsLayout];
    [self.tableView layoutIfNeeded];
    [self.tableView reloadData];

    return YES;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        return [self.searchResult count];
    }
    else
    {
        return [self.tableData count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"StoreViewCell";
    StoreViewCell *cell = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    } else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    }
    if (cell == nil)
    {
        cell = [[StoreViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    StoreConfig* sc = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        cell.textLabel.text = [self.searchResult objectAtIndex:indexPath.row];
        sc = [storeListSearch objectAtIndex:indexPath.row];
    } else {
        cell.textLabel.text = self.tableData[indexPath.row];
        sc = [storeList objectAtIndex:indexPath.row];
    }

    [cell.textLabel setHidden:true];
    cell.labelTitle.text = sc.title;
    cell.labelDesc.text = sc.desc;
    [Utility setImage:cell.imgIcon url:sc.icon_url placeholderImage:[Utility getAppIconImage]];
    cell.viewMain.layer.shadowOpacity = 0.0f;
    [Utility showShadow:cell.viewMain];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 150;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    StoreConfig* sc = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        sc = [storeListSearch objectAtIndex:indexPath.row];
    } else {
        sc = [storeList objectAtIndex:indexPath.row];
    }
    [self proceed:sc];
}
- (void)proceed:(StoreConfig*)storeConfig {
    NSString* str = @"";
    if ([Utility isMultiStoreAppTMStore]) {
        str = storeConfig.platform;
    } else {
        str = storeConfig.multi_store_platform;
    }
    //        NSString* str = [sender.layer valueForKey:@"PLATFORM_NAME"];
    DataManager* dm = [DataManager sharedManager];
    dm.appDataPlatformString = str;
    [[NSUserDefaults standardUserDefaults] setValue:str forKey:@"APPDATA_PLATFORM"];
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:true] forKey:@"MULTISTORE_APP_LAUNCHED"];
    UIStoryboard *sb = [Utility getStoryBoardObject];
    UIViewController *rootViewController = [sb instantiateViewControllerWithIdentifier:VC_SPLASH_PRIMARY];
    [[UIApplication sharedApplication].keyWindow setRootViewController:rootViewController];
}

- (IBAction)buttonShowAllStoresAction:(id)sender{
    ShowAllStoresViewController *svc = [self.storyboard instantiateViewControllerWithIdentifier:@"ShowAllStoresViewController"];
    [self presentViewController:svc animated:YES completion:nil];
    
}

- (IBAction)barButtonBackPressed:(id)sender {

    [self dismissViewControllerAnimated:YES completion:nil];

}

@end

@implementation StoreViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}
#if SUPPORT_PORTRAIT_ORIENTATION_ONLY
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}
- (BOOL)shouldAutorotate {
    return YES;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
- (NSUInteger)navigationControllerSupportedInterfaceOrientations:(UINavigationController *)navigationController {
    return UIInterfaceOrientationMaskPortrait;
}
#else
- (BOOL)shouldAutorotate {
    return YES;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    if([[MyDevice sharedManager] isIphone]){
        return UIInterfaceOrientationMaskPortrait;
    }
    return UIInterfaceOrientationMaskAll;
}
#endif
@end
