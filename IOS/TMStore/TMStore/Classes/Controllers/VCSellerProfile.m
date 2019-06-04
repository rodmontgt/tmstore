//
//  VCSellerProfile.m
//  TMStore
//
//  Created by Twist Mobile on 29/11/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import "VCSellerProfile.h"
#import <GoogleMaps/GoogleMaps.h>
#import <CoreLocation/CoreLocation.h>
#import <GooglePlaces/GooglePlaces.h>
#import "UIScrollView+APParallaxHeader.h"
#import "MXParallaxHeader.h"
#import "PSprofileCell.h"
#import "PSshopeCell.h"
#import "PSDetailCell.h"
#import "Variables.h"
#import "DataManager.h"
#import "ProductImage.h"
#import "Utility.h"
#import "PSMapAddressCell.h"
#import "AppDelegate.h"


static CLLocation *selectedLoc;

@interface VCSellerProfile ()<APParallaxViewDelegate,UITableViewDelegate,UITableViewDataSource,CLLocationManagerDelegate,GMSMapViewDelegate, UIImagePickerControllerDelegate,UIActionSheetDelegate, UITextFieldDelegate,UISearchBarDelegate,GMSAutocompleteViewControllerDelegate,GMSAutocompleteResultsViewControllerDelegate,GMSAutocompleteTableDataSourceDelegate,UISearchDisplayDelegate,UIGestureRecognizerDelegate>
{
    
    CLLocationCoordinate2D destinationCoordinate;
    CLLocationManager *locationManager;
    CGFloat currentZoom;
    NSTimer* myTimer;
    UIButton *customBackButton;
    UIButton *customFilterButton;
    SellerInfo* sellerInfoUpdated;
    
    GMSAutocompleteResultsViewController *resultsViewController;
    UISearchController *searchController;
    GMSAutocompleteTableDataSource *tableDataSource;
    UISearchDisplayController *searchDisplayController;
    UISearchBar *searchBar;
    
}
@property NSString* tempFirstName;
@property NSString* tempLastName;
@property NSString* tempShopName;
@property NSString* tempShopContact;
@property NSString* tempShopAddress;
@property NSString* tempShopIcon;
@property NSString* tempProfileIcon;
@property NSString* tempPlacemarkName;
@property NSString* strMapAddress;

@property CLLocation* sellerLocation;
@property ShopSettings* shopSettings;
@end

@implementation VCSellerProfile

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[Utility getUIColor:kUIColorThemeFont], NSForegroundColorAttributeName, [Utility getUIFont:kUIFontType24 isBold:false], NSFontAttributeName, nil]];
    [self.currentItemHeading setTitle:@"   "];
    
    _labelViewHeading = [[UILabel alloc] init] ;
    [_labelViewHeading setFrame:CGRectMake(0, 20, [[MyDevice sharedManager] screenSize].width, _navigationBar.frame.size.height)];
    [_labelViewHeading setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [_labelViewHeading setUIFont:kUIFontType24 isBold:false];
    [_labelViewHeading setTextColor:[Utility getUIColor:kUIColorThemeFont]];
    [_labelViewHeading setTextAlignment:NSTextAlignmentCenter];
    [_labelViewHeading setText:Localize(@"store_settings")];
    [self.view addSubview:_labelViewHeading];
    int countSubviews = (int)[[_navigationBar subviews] count];
    RLOG(@"countSubviews = %d", countSubviews);
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
    
    
    customFilterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [customFilterButton setImage:[[UIImage imageNamed:@"img_arrow_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [customFilterButton addTarget:self action:@selector(saveButtonPressed:)forControlEvents:UIControlEventTouchUpInside];
    [customFilterButton setTitle:[NSString stringWithFormat:@"  %@  ", Localize(@"i_save")] forState:UIControlStateNormal];
    [customFilterButton setTintColor:[Utility getUIColor:kUIColorThemeFont]];
    [customFilterButton setTitleColor:[Utility getUIColor:kUIColorThemeFont] forState:UIControlStateNormal];
    [customFilterButton.titleLabel setUIFont:kUIFontType18 isBold:false];
    [customFilterButton sizeToFit];
    [_nextItemHeading setCustomView:customFilterButton];
    [_nextItemHeading setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[Utility getUIColor:kUIColorThemeFont], NSForegroundColorAttributeName, [Utility getUIFont:kUIFontType18 isBold:false], NSFontAttributeName, nil] forState:UIControlStateNormal];
    
    
    
    //    customFilterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [customFilterButton setImage:[[UIImage imageNamed:@"filter"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    //    [customFilterButton addTarget:self action:@selector(saveButtonPressed:)forControlEvents:UIControlEventTouchUpInside];
    //    [customFilterButton setTitle:[NSString stringWithFormat:@"%@", Localize(@"")] forState:UIControlStateNormal];
    //    [customFilterButton setTintColor:[Utility getUIColor:kUIColorThemeFont]];
    //    [customFilterButton setTitleColor:[Utility getUIColor:kUIColorThemeFont] forState:UIControlStateNormal];
    //    [customFilterButton.titleLabel setUIFont:kUIFontType18 isBold:false];
    //    [customFilterButton sizeToFit];
    //    [customFilterButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    //    [customFilterButton setContentMode:UIViewContentModeRight];
    //    [customFilterButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    //    [_nextItemHeading setCustomView:customFilterButton];
    //    [_nextItemHeading setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[Utility getUIColor:kUIColorThemeFont], NSForegroundColorAttributeName, [Utility getUIFont:kUIFontType18 isBold:false], NSFontAttributeName, nil] forState:UIControlStateNormal];
    //    [customFilterButton setHidden:true];
    
    
    
    
    CGRect customBtnRect = customBackButton.frame;
    CGRect headingBtnRect = _labelViewHeading.frame;
    customBtnRect.size.height = headingBtnRect.size.height;
    customBackButton.frame = customBtnRect;
    
    CGRect customFilterBtnRect = customFilterButton.frame;
    customFilterBtnRect.size.height = headingBtnRect.size.height;
    customFilterButton.frame = customFilterBtnRect;
    float bckBtnMaxX = CGRectGetMaxX(customBtnRect) + 20;
    headingBtnRect.size.width = self.view.frame.size.width - bckBtnMaxX * 2;
    headingBtnRect.origin.x = bckBtnMaxX;
    _labelViewHeading.frame = headingBtnRect;
    [_labelViewHeading setText:Localize(@"store_settings")];
    
    
    
    
    
    Addons* addons = [Addons sharedManager];
    self.shopSettings = [[addons multiVendor] multiVendor_shop_settings];

    SellerInfo* currentSeller = [SellerInfo getCurrentSeller];
    sellerInfoUpdated = [SellerInfo createCopyFrom:currentSeller];
    if (currentSeller.sellerFirstName && ![currentSeller.sellerFirstName isEqualToString:@""]) {
        self.tempFirstName = currentSeller.sellerFirstName;
    } else {
        self.tempFirstName = @"";
    }
    if (currentSeller.sellerLastName && ![currentSeller.sellerLastName isEqualToString:@""]) {
        self.tempLastName = currentSeller.sellerLastName;
    } else {
        self.tempLastName = @"";
    }
    if (currentSeller.shopName && ![currentSeller.shopName isEqualToString:@""]) {
        self.tempShopName = currentSeller.shopName;
    } else {
        self.tempShopName = @"";
    }
    if (currentSeller.shopAddress && ![currentSeller.shopAddress isEqualToString:@""]) {
        self.strMapAddress = currentSeller.shopAddress;
    } else {
        self.strMapAddress = @"";
    }
    
    if (currentSeller.sellerPhone && ![currentSeller.sellerPhone isEqualToString:@""]) {
        self.tempShopContact = currentSeller.sellerPhone;
    } else {
        self.tempShopContact = @"";
    }
    if (currentSeller.sellerAvatarUrl && ![currentSeller.sellerAvatarUrl isEqualToString:@""]) {
        self.tempProfileIcon = currentSeller.sellerAvatarUrl;
    } else {
        self.tempProfileIcon = @"";
    }
    if (currentSeller.shopIconUrl && ![currentSeller.shopIconUrl isEqualToString:@""]) {
        self.tempShopIcon = currentSeller.shopIconUrl;
    } else {
        self.tempShopIcon = @"";
    }
    if (currentSeller.shopLatitude && currentSeller.shopLongitude) {
        self.tempShopIcon = currentSeller.shopIconUrl;
    } else {
        self.tempShopIcon = @"";
    }
    
    //    [self.navigationItem.rightBarButtonItem setTitle:@"Apply"];
    //    [self.navigationItem.leftBarButtonItem setTitle:@"Back"];
    //    self.title = @"Address";
    
#pragma Header Parallax
    if (_shopSettings && _shopSettings.show_location) {
        [self.tableV addParallaxWithView:_mapView andHeight:400];
        self.tableV.parallaxView.delegate = self;
        [self.tableV setClipsToBounds:true];
    }else{
        [self.tableV addParallaxWithView:_mapView andHeight:0];
        self.tableV.parallaxView.delegate = self;
        [self.tableV setClipsToBounds:false];
        self.tableV.scrollEnabled = NO;
        self.tableV.alwaysBounceVertical = NO;

    }
    //    Addons* addonsloc = [Addons sharedManager];
    //    if (addonsloc.multiVendor && addonsloc.multiVendor.multiVendor_shop_settings) {
    //        SHOP_SETTINGS = addons.multiVendor.multiVendor_shop_settings;
    //    }
    //
    
#pragma GMS MapView
    
    if (_shopSettings && _shopSettings.show_location) {
        
        //        locationManager = [[CLLocationManager alloc] init];
        //        locationManager.delegate = self;
        //        locationManager.distanceFilter = kCLDistanceFilterNone;
        //        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        //        [locationManager startUpdatingLocation];
        //        currentZoom = 6.0f;
        //
        //        _mapView.myLocationEnabled = true;
        //        _mapView.delegate = self;
        //       _mapView.settings.compassButton = false;
        //        _mapView.settings.myLocationButton = YES;
        //        _mapView.settings.zoomGestures = YES;
        //        _mapView.settings.scrollGestures = NO;
        
        
       // locationManager = [[CLLocationManager alloc] init];
       // locationManager.delegate = self;
       // locationManager.distanceFilter = kCLDistanceFilterNone;
      //  locationManager.desiredAccuracy = kCLLocationAccuracyBest;
      //  [locationManager startUpdatingLocation];
        
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate=self;
        locationManager.desiredAccuracy=kCLLocationAccuracyBest;
        locationManager.distanceFilter=kCLDistanceFilterNone;
        [locationManager requestWhenInUseAuthorization];
        [locationManager startMonitoringSignificantLocationChanges];
        [locationManager startUpdatingLocation];

        
        // _mapView.myLocationEnabled = YES;
        _mapView.delegate = self;
        // _mapView.settings.compassButton = YES;
        // _mapView.settings.myLocationButton = YES;
        _mapView.settings.zoomGestures = YES;
        _mapView.settings.scrollGestures = NO;

        
    }
    
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (_shopSettings && _shopSettings.show_location) {
        _mapView.settings.compassButton = false;
        [self.mapView addSubview:_markerImage];
    }
    CGRect customBtnRect = customBackButton.frame;
    CGRect headingBtnRect = _labelViewHeading.frame;
    customBtnRect.size.height = headingBtnRect.size.height;
    customBackButton.frame = customBtnRect;
    
    CGRect customFilterBtnRect = customFilterButton.frame;
    customFilterBtnRect.size.height = headingBtnRect.size.height;
    customFilterButton.frame = customFilterBtnRect;
    float bckBtnMaxX = CGRectGetMaxX(customBtnRect) + 20;
    headingBtnRect.size.width = self.view.frame.size.width - bckBtnMaxX * 2;
    headingBtnRect.origin.x = bckBtnMaxX;
    _labelViewHeading.frame = headingBtnRect;
    [_labelViewHeading setText:Localize(@"store_settings")];
    
    NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:TAG_CELL_SHOP_ADDRESS inSection:0];
    NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
    [self.tableV reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
    
}
- (void)viewWillAppear:(BOOL)animated {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:TAG_CELL_SHOP_ADDRESS inSection:0];
    NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
    [self.tableV reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
    
    
}
- (void)viewWillDisappear:(BOOL)animated {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
}
#pragma mark - APParallaxViewDelegate

- (void)parallaxView:(APParallaxView *)view willChangeFrame:(CGRect)frame {
    // Do whatever you need to do to the parallaxView or your subview before its frame changes
    NSLog(@"parallaxView:willChangeFrame: %@", NSStringFromCGRect(frame));
}

- (void)parallaxView:(APParallaxView *)view didChangeFrame:(CGRect)frame {
    // Do whatever you need to do to the parallaxView or your subview after its frame changed
    NSLog(@"parallaxView:didChangeFrame: %@", NSStringFromCGRect(frame));
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return TAG_CELL_ITEMS_TOTAL;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == TAG_CELL_AVATAR_ICON) {
        if(self.shopSettings.enable_avatar_icon) {
            return 130;
        }
    }
    if (indexPath.row == TAG_CELL_FIRST_NAME) {
        if(self.shopSettings.enable_first_name) {
            return 50;
        }
    }
    if (indexPath.row == TAG_CELL_LAST_NAME) {
        if(self.shopSettings.enable_last_name) {
            return 50;
        }
    }
    if (indexPath.row == TAG_CELL_SHOP_NAME) {
        if(self.shopSettings.enable_shop_name) {
            return 50;
        }
    }
    if (indexPath.row == TAG_CELL_SHOP_ADDRESS) {
        if(self.shopSettings.enable_shop_address) {
            return 50;
        }
    }
    if (indexPath.row == TAG_CELL_SHOP_CONTACT) {
        if(self.shopSettings.enable_shop_contact) {
            return 50;
        }
    }
    if (indexPath.row == TAG_CELL_SHOP_ICON) {
        if(self.shopSettings.enable_shop_icon) {
            return 160;
        }
    }
    return 0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == TAG_CELL_AVATAR_ICON) {
        PSprofileCell *cell = [tableView dequeueReusableCellWithIdentifier:TAG_CELL_STRINGS[TAG_CELL_AVATAR_ICON]];
        if (cell == nil)
        {    cell = [[[NSBundle mainBundle] loadNibNamed:TAG_CELL_STRINGS[TAG_CELL_AVATAR_ICON] owner:self options:nil] objectAtIndex:0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        [cell.btnAddProfileIcon addTarget:self action:@selector(AddProfileIcon:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btnRemoveProfileIcon addTarget:self action:@selector(RemoveProfileIcon:) forControlEvents:UIControlEventTouchUpInside];
        if (self.tempProfileIcon == nil || [self.tempProfileIcon isEqualToString:@""]) {
            cell.btnAddProfileIcon.hidden  = false;
            cell.imageProfileIcon.hidden = true;
            cell.btnRemoveProfileIcon.hidden = true;
        } else {
            cell.btnAddProfileIcon.hidden  = true;
            cell.imageProfileIcon.hidden = false;
            cell.btnRemoveProfileIcon.hidden = false;
            [Utility setImage:cell.imageProfileIcon url:self.tempProfileIcon resizeType:0 isLocal:false highPriority:true];
        }
        [cell.imageProfileIcon.layer setBorderWidth:1];
        [cell.imageProfileIcon.layer setBorderColor:[Utility getUIColor:kUIColorBorder].CGColor];
        [cell.imageProfileIcon setContentMode:UIViewContentModeScaleAspectFit];
        [cell setClipsToBounds:true];
        if (self.shopSettings.enable_avatar_icon == false) {
            [cell setHidden:true];
        } else {
            [cell setHidden:false];
        }
        return cell;
    }
    if (indexPath.row == TAG_CELL_FIRST_NAME) {
        PSDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:TAG_CELL_STRINGS[TAG_CELL_FIRST_NAME]];
        
        if (cell == nil)
        {    cell = [[[NSBundle mainBundle] loadNibNamed:TAG_CELL_STRINGS[TAG_CELL_FIRST_NAME] owner:self options:nil] objectAtIndex:0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
        }
        cell.tfDetail.placeholder = Localize(@"first_name");
        cell.tfDetail.text = self.tempFirstName;
        cell.tfDetail.delegate = self;
        [cell.tfDetail setTag:TAG_CELL_FIRST_NAME];
        [cell setClipsToBounds:true];
        if (self.shopSettings.enable_first_name == false) {
            [cell setHidden:true];
        } else {
            [cell setHidden:false];
        }
        return cell;
    }
    if (indexPath.row == TAG_CELL_LAST_NAME) {
        PSDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:TAG_CELL_STRINGS[TAG_CELL_LAST_NAME]];
        if (cell == nil)
        {    cell = [[[NSBundle mainBundle] loadNibNamed:TAG_CELL_STRINGS[TAG_CELL_LAST_NAME] owner:self options:nil] objectAtIndex:0];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            
        }
        cell.tfDetail.placeholder = Localize(@"last_name");
        cell.tfDetail.text = self.tempLastName;
        cell.tfDetail.delegate = self;
        [cell.tfDetail setTag:TAG_CELL_LAST_NAME];
        [cell setClipsToBounds:true];
        if (self.shopSettings.enable_last_name == false) {
            [cell setHidden:true];
        } else {
            [cell setHidden:false];
        }
        return cell;
    }
    if (indexPath.row == TAG_CELL_SHOP_NAME) {
        PSDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:TAG_CELL_STRINGS[TAG_CELL_SHOP_NAME]];
        
        if (cell == nil)
        {    cell = [[[NSBundle mainBundle] loadNibNamed:TAG_CELL_STRINGS[TAG_CELL_SHOP_NAME] owner:self options:nil] objectAtIndex:0];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            
        }
        cell.tfDetail.placeholder = Localize(@"label_shop_name");
        cell.tfDetail.text = self.tempShopName;
        cell.tfDetail.delegate = self;
        [cell.tfDetail setTag:TAG_CELL_SHOP_NAME];
        [cell setClipsToBounds:true];
        if (self.shopSettings.enable_shop_name == false) {
            [cell setHidden:true];
        } else {
            [cell setHidden:false];
        }
        return cell;
    }
    
    if (indexPath.row == TAG_CELL_SHOP_ADDRESS) {
        PSDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:TAG_CELL_STRINGS[TAG_CELL_SHOP_ADDRESS]];
        
        if (cell == nil)
        {    cell = [[[NSBundle mainBundle] loadNibNamed:TAG_CELL_STRINGS[TAG_CELL_SHOP_ADDRESS] owner:self options:nil] objectAtIndex:0];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            
        }
        //[cell.tfDetail addTarget:self action:@selector(myMethod:) forControlEvents:UIControlEventTouchUpInside];
        // [cell.tfDetail addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventTouchUpInside];
        //            cell.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didRecognizeTapGesture:)];
        //            tapGesture.delegate = self;
        //            tapGesture.numberOfTouchesRequired = 1;
        
        if (_shopSettings && _shopSettings.show_location) {
/*
        cell.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didRecognizeTapGesture:)];
        cell.tapGesture.delegate = self;
        cell.tapGesture.numberOfTouchesRequired = 1;
        cell.tapGesture.numberOfTapsRequired = 1;
*/
       [cell.tfDetail addTarget:self action:@selector(showAddressController) forControlEvents:UIControlEventEditingDidBegin];

        //[cell.tfDetail.superview.superview addGestureRecognizer:cell.tapGesture];
            //[cell.contentView.superview addGestureRecognizer:cell.tapGesture];

            [cell.tfDetail setUserInteractionEnabled:true];
        
        [cell.tfDetail resignFirstResponder];
        cell.tfDetail.placeholder = Localize(@"shop_address");
        cell.tfDetail.text = [NSString stringWithFormat:@"%@",self.strMapAddress];
        cell.tfDetail.delegate = self;
        [cell.tfDetail setTag:TAG_CELL_SHOP_ADDRESS];
        [cell setClipsToBounds:true];
        if (self.shopSettings.enable_shop_address == false) {
            [cell setHidden:true];
        } else {
            [cell setHidden:false];
        }
        }else{
            cell.tfDetail.placeholder = Localize(@"shop_address");
            cell.tfDetail.text = [NSString stringWithFormat:@"%@",self.strMapAddress];
            cell.tfDetail.delegate = self;
            [cell.tfDetail setTag:TAG_CELL_SHOP_ADDRESS];
            
            [cell setClipsToBounds:true];
            if (self.shopSettings.enable_shop_address == false) {
                [cell setHidden:true];
            } else {
                [cell setHidden:false];
            }
        }
        return cell;
    }
    
    
    if (indexPath.row == TAG_CELL_SHOP_CONTACT) {
        PSDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:TAG_CELL_STRINGS[TAG_CELL_SHOP_CONTACT]];
        
        if (cell == nil)
        {    cell = [[[NSBundle mainBundle] loadNibNamed:TAG_CELL_STRINGS[TAG_CELL_SHOP_CONTACT] owner:self options:nil] objectAtIndex:0];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            
        }
        cell.tfDetail.placeholder = Localize(@"contact_number");
        cell.tfDetail.text = self.tempShopContact;
        cell.tfDetail.delegate = self;
        [cell.tfDetail setTag:TAG_CELL_SHOP_CONTACT];
        [cell setClipsToBounds:true];
        [self addDoneButtonTextField:cell.tfDetail];
        if (self.shopSettings.enable_shop_contact == false) {
            [cell setHidden:true];
        } else {
            [cell setHidden:false];
        }
        return cell;
    }
    if (indexPath.row == TAG_CELL_SHOP_ICON) {
        PSshopeCell *cell = [tableView dequeueReusableCellWithIdentifier:TAG_CELL_STRINGS[TAG_CELL_SHOP_ICON]];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:TAG_CELL_STRINGS[TAG_CELL_SHOP_ICON] owner:self options:nil] objectAtIndex:0];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
        [cell.btnAddShopIcon addTarget:self action:@selector(AddShopIcon:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btnRemoveShopIcon addTarget:self action:@selector(RemoveShopIcon:) forControlEvents:UIControlEventTouchUpInside];
        if (self.tempShopIcon == nil || [self.tempShopIcon isEqualToString:@""]) {
            cell.btnAddShopIcon.hidden  = false;
            cell.imageShopIcon.hidden = true;
            cell.btnRemoveShopIcon.hidden = true;
        } else {
            cell.btnAddShopIcon.hidden  = true;
            cell.imageShopIcon.hidden = false;
            cell.btnRemoveShopIcon.hidden = false;
            [Utility setImage:cell.imageShopIcon url:self.tempShopIcon resizeType:0 isLocal:false highPriority:true];
        }
        [cell.imageShopIcon setContentMode:UIViewContentModeScaleAspectFit];
        [cell.imageShopIcon.layer setBorderWidth:1];
        [cell.imageShopIcon.layer setBorderColor:[Utility getUIColor:kUIColorBorder].CGColor];
        [cell setClipsToBounds:true];
        if (self.shopSettings.enable_shop_icon == false) {
            [cell setHidden:true];
        } else {
            [cell setHidden:false];
        }
        return cell;
    }
    else {
        PSshopeCell *cell = [tableView dequeueReusableCellWithIdentifier:TAG_CELL_STRINGS[TAG_CELL_SHOP_ICON]];
        if (cell == nil)
        {    cell = [[[NSBundle mainBundle] loadNibNamed:TAG_CELL_STRINGS[TAG_CELL_SHOP_ICON] owner:self options:nil] objectAtIndex:0];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            
        }
        [cell.btnAddShopIcon addTarget:self action:@selector(AddShopIcon:) forControlEvents:UIControlEventTouchUpInside];
        
        if (self.tempShopIcon == nil || [self.tempShopIcon isEqualToString:@""]) {
            cell.btnAddShopIcon.hidden  = false;
            cell.imageShopIcon.hidden = true;
        } else {
            cell.btnAddShopIcon.hidden  = true;
            cell.imageShopIcon.hidden = false;
            [Utility setImage:cell.imageShopIcon url:self.tempShopIcon resizeType:0 isLocal:false highPriority:true];
        }
        [cell setClipsToBounds:true];
        [cell setHidden:true];
        return cell;
    }
}
- (void)RemoveShopIcon:(UIButton*)sender{
    self.tempShopIcon = @"";
    NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:TAG_CELL_SHOP_ICON inSection:0];
    NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
    [self.tableV reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
}
- (void)RemoveProfileIcon:(UIButton*)sender{
    self.tempProfileIcon = @"";
    NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:TAG_CELL_AVATAR_ICON inSection:0];
    NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
    [self.tableV reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
}
- (void)AddShopIcon:(UIButton*)sender{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"Upload Images from" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Camera" otherButtonTitles:@"Gallery", nil];
    actionSheet.center  = self.view.center;
    self.isShopPick = true;
    self.isProfilePick = false;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // In this case the device is an iPad.
        // [actionSheet showFromRect:[(UIButton *)sender frame] inView:self.view animated:YES];
        [actionSheet showInView:self.view];
    } else {
        // In this case the device is an iPhone/iPod Touch.
        [actionSheet showInView:self.view];
    }
}
- (void)AddProfileIcon:(UIButton*)sender{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"Upload Images from" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Camera" otherButtonTitles:@"Gallery", nil];
    actionSheet.center  = self.view.center;
    self.isShopPick = false;
    self.isProfilePick = true;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // In this case the device is an iPad.
        //  [actionSheet showFromRect:[(UIButton *)sender frame] inView:self.view animated:YES];
        [actionSheet showInView:self.view];
    } else {
        // In this case the device is an iPhone/iPod Touch.
        [actionSheet showInView:self.view];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        NSTimer* myTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(camera:) userInfo:nil repeats:NO];
        
        //          [self camera];
    }else if (buttonIndex == 1){
        // [self photoLibrary];
        NSTimer* myTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(photoLibrary:) userInfo:nil repeats:NO];
        
    }if  (actionSheet.cancelButtonIndex == buttonIndex) {
        return;
    }
    
}

- (void)camera:(float)dt {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
}
- (void)photoLibrary:(float)dt{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}
#pragma mark - imagePickerController-Delegates

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:NULL];
    UIImage *chosenImage =  info[UIImagePickerControllerOriginalImage];
    [self uploadImage:chosenImage];
}
-(UIImage*)resizeImage:(UIImage*)image {
    float max = 512.0f;
#if ENABLE_UPLOAD_IMG_LOW_RESOLUTION
    max = 128.0f;
#endif
    CGSize newSize = CGSizeMake(max, max);
    if (image.size.width > max || image.size.height > max) {
        float heightToWidthRatio = image.size.height / image.size.width;
        float scaleFactor = 1;
        if(heightToWidthRatio > 0) {
            scaleFactor = newSize.height / image.size.height;
        } else {
            scaleFactor = newSize.width / image.size.width;
        }
        
        CGSize newSize2 = newSize;
        newSize2.width = image.size.width * scaleFactor;
        newSize2.height = image.size.height * scaleFactor;
        
        UIGraphicsBeginImageContext(newSize2);
        [image drawInRect:CGRectMake(0,0,newSize2.width,newSize2.height)];
        UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
    }
    return image;
}
- (void)uploadImage:(UIImage*)image {
    
    [[[DataManager sharedManager] tmDataDoctor] uploadImageToServer:[self resizeImage:image] success:^(NSString *imgUrl) {
        if (_isProfilePick == true) {
            self.tempProfileIcon = imgUrl;
            NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:TAG_CELL_AVATAR_ICON inSection:0];
            NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
            [self.tableV reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
            
        }else if (_isShopPick == true){
            self.tempShopIcon = imgUrl;
            NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:TAG_CELL_SHOP_ICON inSection:0];
            NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
            [self.tableV reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
        }
    } failure:^(NSString *error) {
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:Localize(@"i_error") message:Localize(@"image_upload_error") delegate:self cancelButtonTitle:Localize(@"cancel") otherButtonTitles:Localize(@"retry"), nil];
        [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [self uploadImage:image];
            }
        }];
    }];
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
#pragma mark - create a marker pin on map

//#pragma mark - CLLocationManagerDelegate method
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    if(self.shopSettings.enable_shop_address) {
        
        self.myLocation = [locations lastObject];
        if (self.myLocation != nil){
            NSLog(@"The latitude value is - %@",[NSString stringWithFormat:@"%.8f", self.myLocation.coordinate.latitude]);
            NSLog(@"The logitude value is - %@",[NSString stringWithFormat:@"%.8f", self.myLocation.coordinate.longitude]);
        }
        
        //Current
        GMSCameraPosition *camera = nil;
        CLLocation *loc = nil;
        SellerInfo* currentSeller = [SellerInfo getCurrentSeller];
        if (currentSeller.shopLatitude && currentSeller.shopLatitude != -1.0f && currentSeller.shopLongitude && currentSeller.shopLongitude != -1.0f) {
            camera = [GMSCameraPosition cameraWithLatitude:currentSeller.shopLatitude longitude:currentSeller.shopLongitude zoom:11];
            loc = [[CLLocation alloc]initWithLatitude:currentSeller.shopLatitude longitude:currentSeller.shopLongitude];
            
        } else {
            camera = [GMSCameraPosition cameraWithLatitude:self.myLocation.coordinate.latitude longitude:self.myLocation.coordinate.longitude zoom:11];
            loc = [[CLLocation alloc]initWithLatitude:self.myLocation.coordinate.latitude longitude:self.myLocation.coordinate.longitude];
        }
        GMSMarker *marker=[[GMSMarker alloc]init];
        marker.position= CLLocationCoordinate2DMake(loc.coordinate.latitude,loc.coordinate.longitude);
        marker.map= _mapView;
        
        _mapView.camera = camera;
        _mapView.myLocationEnabled = YES;
        _mapView.settings.compassButton = false;
        _mapView.delegate = self;
        
        CLGeocoder *ceo = [[CLGeocoder alloc]init];
        [ceo reverseGeocodeLocation:loc
                  completionHandler:^(NSArray *placemarks, NSError *error) {
                      CLPlacemark *placemark = [placemarks objectAtIndex:0];
                      if (placemark) {
                          NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
                          NSString *Address = [[NSString alloc]initWithString:locatedAt];
                          
                          self.myLocation = placemark.location;
                          self.tempPlacemarkName = placemark.name;
                          
                          
                          NSLog(@"placemark %@",placemark.country);
                          NSLog(@"placemark %@",placemark.locality);
                          NSLog(@"location %@",placemark.name);
                          NSLog(@"location %@",placemark.postalCode);
                          NSLog(@"location %@",placemark.location);
                          
                          if (self.strMapAddress == nil || [self.strMapAddress isEqualToString:@""]) {
                              self.strMapAddress = Address;
                              NSLog(@"111111didUpdateLocations");
                              NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:TAG_CELL_SHOP_ADDRESS inSection:0];
                              NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
                              [self.tableV reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
                          }
                          
                      }
                      else {
                          NSLog(@"Could not locate");
                      }
                  }
         ];
        
        [locationManager stopUpdatingLocation];
    }
}

#pragma mark - Mapview  Marker Delegate method
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (IBAction)barButtonBackPressed:(id)sender {
    NSLog(@"backclick %@",sender);
    [self dismissViewControllerAnimated:YES completion:nil];
    if (self.vcSellerZone) {
        [self.vcSellerZone loadCurrentSellerData];
    }
}
- (IBAction)saveButtonPressed:(id)sender {
    SellerInfo* sellerInfo = sellerInfoUpdated;
    sellerInfo.sellerFirstName = self.tempFirstName;
    sellerInfo.sellerLastName = self.tempLastName;
    sellerInfo.shopName = self.tempShopName;
    sellerInfo.sellerPhone = self.tempShopContact;
    sellerInfo.shopAddress = self.strMapAddress;
    sellerInfo.shopIconUrl = self.tempShopIcon;
    sellerInfo.sellerAvatarUrl = self.tempProfileIcon;
    //sellerInfo.shopLatitude =_sellerLocation.coordinate.latitude;
    //sellerInfo.shopLongitude =_sellerLocation.coordinate.longitude;
    
    NSMutableDictionary *paramsM = [[NSMutableDictionary alloc] init];
    [paramsM setObject:base64_str(@"update") forKey:@"type"];
    [paramsM setObject:base64_str(sellerInfo.sellerId) forKey:@"seller_id"];
    NSString* sellerLatitude = [NSString stringWithFormat:@"%F", _sellerLocation.coordinate.latitude];
    [paramsM setObject:base64_str(sellerLatitude) forKey:@"latitude"];
    NSString* sellerLongitude = [NSString stringWithFormat:@"%F", _sellerLocation.coordinate.longitude];
    [paramsM setObject:base64_str(sellerLongitude) forKey:@"longitude"];
    [paramsM setObject:base64_str(sellerInfo.sellerFirstName) forKey:@"seller_first_name"];
    [paramsM setObject:base64_str(sellerInfo.sellerLastName) forKey:@"seller_last_name"];
    [paramsM setObject:base64_str(sellerInfo.sellerPhone) forKey:@"seller_phone"];
    [paramsM setObject:base64_str(sellerInfo.shopName) forKey:@"shop_name"];
    [paramsM setObject:base64_str(sellerInfo.shopAddress) forKey:@"shop_address"];
    [paramsM setObject:base64_str(sellerInfo.shopUrl) forKey:@"shop_url"];
    [paramsM setObject:base64_str(sellerInfo.sellerInfo) forKey:@"seller_info"];
    [paramsM setObject:base64_str(sellerInfo.shopDescription) forKey:@"shop_description"];
    [paramsM setObject:base64_str(sellerInfo.shopIconUrl) forKey:@"icon_url"];
    [paramsM setObject:base64_str(sellerInfo.shopBannerUrl) forKey:@"banner_url"];
    [paramsM setObject:base64_str(sellerInfo.sellerAvatarUrl) forKey:@"avatar_url"];
    NSDictionary *params = [[NSDictionary alloc] initWithDictionary:paramsM];
    [[[DataManager sharedManager] tmDataDoctor] updateSellerInformation:params success:^(id data) {
        NSLog(@"seller info update: success");
        NSLog( @"data: %@", data);
        
        SellerInfo* currentSeller = [SellerInfo getCurrentSeller];
        currentSeller.sellerFirstName = sellerInfoUpdated.sellerFirstName;
        currentSeller.sellerLastName = sellerInfoUpdated.sellerLastName;
        currentSeller.shopName = sellerInfoUpdated.shopName;
        currentSeller.sellerPhone = sellerInfoUpdated.sellerPhone;
        currentSeller.shopAddress = sellerInfoUpdated.shopAddress;
        currentSeller.shopIconUrl = sellerInfoUpdated.shopIconUrl;
        currentSeller.sellerAvatarUrl = sellerInfoUpdated.sellerAvatarUrl;
        currentSeller.shopLatitude =_sellerLocation.coordinate.latitude;
        currentSeller.shopLongitude =_sellerLocation.coordinate.longitude;
        
        [_tableV reloadData];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Localize(@"i_success") message:Localize(@"i_customer_data_updated") delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
        [alertView show];
        [self performSelector:@selector(dismissAlert:) withObject:alertView afterDelay:1.0f];
    } failure:^(NSString *error) {
        NSLog(@"seller info update: failure");
        NSString* msgStr = @"";
        if (error != nil && ![error isEqualToString:@"failure"] && ![error isEqualToString:@""]) {
            msgStr = error;
        }
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Localize(@"i_payment_failed_msg") message:msgStr delegate:nil cancelButtonTitle:Localize(@"cancel") otherButtonTitles:Localize(@"retry"), nil];;
        [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if ((int)buttonIndex == 0) {
                
            } else {
                [self saveButtonPressed:nil];
            }
        }];
    }];
}
- (void)dismissAlert:(UIAlertView *)alertView{
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
}
- (void)addDoneButtonTextField:(UITextField*)view{
    if ([[MyDevice sharedManager] isIphone]) {
        UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
        numberToolbar.backgroundColor = [UIColor lightGrayColor];
        UIBarButtonItem* doneBtn = [[UIBarButtonItem alloc]initWithTitle:Localize(@"done") style:UIBarButtonItemStyleBordered target:self action:@selector(doneWithNumberPad:)];
        numberToolbar.items = @[
                                [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                doneBtn];
        [numberToolbar sizeToFit];
        view.inputAccessoryView = numberToolbar;
    }
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    _textFieldFirstResponder = textField;
    [self fillTextFieldEditData:textField];
    //    [self ActionTapAddress:self];
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [self setViewMovedUp:NO];
    [self fillTextFieldEditData:textField];
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self fillTextFieldEditData:textField];
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField.tag == TAG_CELL_SHOP_CONTACT)
    {
        if(string.length > 0)
        {
            NSCharacterSet *numbersOnly = [NSCharacterSet characterSetWithCharactersInString:@"+0123456789"];
            NSCharacterSet *characterSetFromTextField = [NSCharacterSet characterSetWithCharactersInString:string];
            
            BOOL stringIsValid = [numbersOnly isSupersetOfSet:characterSetFromTextField];
            return stringIsValid;
        }
    }
    return YES;
}
-(void)cancelNumberPad:(UIBarButtonItem*)button {
    [self textFieldShouldReturn:_textFieldFirstResponder];
}
-(void)doneWithNumberPad:(UIBarButtonItem*)button {
    [self textFieldShouldReturn:_textFieldFirstResponder];
}
- (void)setViewMovedUp:(BOOL)movedUp {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    RLOG(@"setViewMovedUp:%d", movedUp);
    [UIView beginAnimations:nil context:NULL];
    if (movedUp == false) {
        [UIView setAnimationDuration:0.0f];
    } else {
        [UIView setAnimationDuration:_duration];
    }
    
    [UIView setAnimationCurve:_curve];
    CGRect rect = self.view.frame;
    if (movedUp) {
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        CGPoint p = [_textFieldFirstResponder convertPoint:_textFieldFirstResponder.center toView:window];
        float textViewPos = p.y;
        float windowViewHeight = [[MyDevice sharedManager] screenSize].height;
        float keyboardPos = windowViewHeight - _keyboardHeight;
        
        if (textViewPos > keyboardPos) {
            if ([[MyDevice sharedManager] isIphone]) {
                rect.origin.y = - MIN(_keyboardHeight, (textViewPos - keyboardPos));
                self.view.frame = rect;
            }
        }
    }
    else {
        if ([[MyDevice sharedManager] isIphone]) {
            rect.origin.y = 0;
            self.view.frame = rect;
            self.view.center = CGPointMake([[MyDevice sharedManager] screenSize].width/2, [[MyDevice sharedManager] screenSize].height/2);
        }
    }
    
    [UIView commitAnimations];
}
- (void)keyboardWillShow:(NSNotification *)notification {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    NSDictionary *info  = notification.userInfo;
    NSValue      *value = info[UIKeyboardFrameEndUserInfoKey];
    CGRect rawFrame      = [value CGRectValue];
    CGRect keyboardFrame = [self.view convertRect:rawFrame fromView:nil];
    RLOG(@"keyboardFrame: %@", NSStringFromCGRect(keyboardFrame));
    _keyboardHeight = keyboardFrame.size.height;
    _duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    _curve = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    // Animate the current view out of the way
    [self setViewMovedUp:YES];
}
- (void)keyboardWillHide {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [self setViewMovedUp:NO];
}
- (void)fillTextFieldEditData:(UITextField*)textField {
    if (textField) {
        int tfTag = (int)textField.tag;
        switch (tfTag) {
            case TAG_CELL_FIRST_NAME:
            {
                _tempFirstName = textField.text;
            }break;
            case TAG_CELL_LAST_NAME:
            {
                _tempLastName = textField.text;
            }break;
            case TAG_CELL_SHOP_NAME:
            {
                _tempShopName = textField.text;
            }break;
            case TAG_CELL_SHOP_ADDRESS:
            {
                if (_shopSettings && _shopSettings.show_location) {
                    _strMapAddress = textField.text;
                    [textField resignFirstResponder];
                }else{
                    _strMapAddress = textField.text;
                }
            }break;
            case TAG_CELL_SHOP_CONTACT:
            {
                _tempShopContact = textField.text;
            }break;
            default:
                break;
        }
    }
}
- (void) didRecognizeTapGesture:(UITapGestureRecognizer*) gesture {
    if (_shopSettings && _shopSettings.show_location) {
        GMSAutocompleteViewController *acController = [[GMSAutocompleteViewController alloc] init];
        acController.delegate = self;
        [self presentViewController:acController animated:YES completion:nil];
    }
}
- (void) showAddressController{
    if (_shopSettings && _shopSettings.show_location) {
        GMSAutocompleteViewController *acController = [[GMSAutocompleteViewController alloc] init];
        acController.delegate = self;
        [self presentViewController:acController animated:YES completion:nil];
    }
}
#pragma mark GPI............

- (void)viewController:(GMSAutocompleteViewController *)viewController
didAutocompleteWithPlace:(GMSPlace *)place {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [_mapView clear];
    NSLog(@"Place name %@", place.name);
    NSLog(@"Place address %@", place.formattedAddress);
    NSLog(@"Place attributions %@", place.attributions.string);
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:place.coordinate.latitude longitude:place.coordinate.longitude zoom:11];
    [_mapView animateToCameraPosition:camera];
    
    CLGeocoder *ceo = [[CLGeocoder alloc]init];
    CLLocation *loc = [[CLLocation alloc]initWithLatitude:place.coordinate.latitude longitude:place.coordinate.longitude]; //insert your coordinates
    
    self.sellerLocation = loc;
    
    
   // NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:TAG_CELL_SHOP_ADDRESS inSection:0];
   // NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
   // [self.tableV reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
    
    [ceo reverseGeocodeLocation:loc
              completionHandler:^(NSArray *placemarks, NSError *error) {
                  
                  CLPlacemark*    placemark = [placemarks objectAtIndex:0];
                  // Check if any placemarks were found
                  if (error == nil && [placemarks count] > 0) {
                      
                      GMSMarker *marker=[[GMSMarker alloc]init];
                      marker.position=CLLocationCoordinate2DMake(place.coordinate.latitude, place.coordinate.longitude);
                      
                      self.strMapAddress = [NSString stringWithFormat:@"%@, %@",place.name, place.formattedAddress];
                      self.sellerLocation = loc;
                    marker.map= _mapView;
                      NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:TAG_CELL_SHOP_ADDRESS inSection:0];
                      NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
                      [self.tableV reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];

                      [_markerImage setHidden:NO];
                  }
                  else {
                      NSLog(@"Could not locate");
                  }
              }
     ];
}

- (void)viewController:(GMSAutocompleteViewController *)viewController
didFailAutocompleteWithError:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
    // TODO: handle the error.
    NSLog(@"Error: %@", [error description]);
}

// User canceled the operation.
- (void)wasCancelled:(GMSAutocompleteViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Turn the network activity indicator on and off again.
- (void)didRequestAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)didUpdateAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

// Handle the user's selection.
- (void)resultsController:(GMSAutocompleteResultsViewController *)resultsController
 didAutocompleteWithPlace:(GMSPlace *)place {
    searchController.active = NO;
    // Do something with the selected place.
    NSLog(@"Place name %@", place.name);
    NSLog(@"Place address %@", place.formattedAddress);
    NSLog(@"Place attributions %@", place.attributions.string);
}

- (void)resultsController:(GMSAutocompleteResultsViewController *)resultsController
didFailAutocompleteWithError:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
    // TODO: handle the error.
    NSLog(@"Error: %@", [error description]);
}

// Turn the network activity indicator on and off again.
- (void)didRequestAutocompletePredictionsForResultsController:
(GMSAutocompleteResultsViewController *)resultsController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)didUpdateAutocompletePredictionsForResultsController:
(GMSAutocompleteResultsViewController *)resultsController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchString:(NSString *)searchString
{
    [tableDataSource sourceTextHasChanged:searchString];
    return NO;
}
- (void)tableDataSource:(GMSAutocompleteTableDataSource *)tableDataSource
didAutocompleteWithPlace:(GMSPlace *)place {
    [searchDisplayController setActive:NO animated:YES];
    
    [_mapView clear];
    // Do something with the selected place.
    NSLog(@"Place name %@", place.name);
    NSLog(@"Place address %@", place.formattedAddress);
    NSLog(@"Place attributions %@", place.attributions.string);
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:place.coordinate.latitude longitude:place.coordinate.longitude zoom:11];
    [_mapView animateToCameraPosition:camera];
    
    CLGeocoder *ceo = [[CLGeocoder alloc]init];
    CLLocation *loc = [[CLLocation alloc]initWithLatitude:place.coordinate.latitude longitude:place.coordinate.longitude]; //insert your coordinates
    
    self.sellerLocation = loc;
    
    NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:TAG_CELL_SHOP_ADDRESS inSection:0];
    NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
    [self.tableV reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
    
    [ceo reverseGeocodeLocation:loc
              completionHandler:^(NSArray *placemarks, NSError *error) {
                  
                  CLPlacemark*    placemark = [placemarks objectAtIndex:0];
                  // Check if any placemarks were found
                  if (error == nil && [placemarks count] > 0) {
                      
                      GMSMarker *marker=[[GMSMarker alloc]init];
                      marker.position=CLLocationCoordinate2DMake(place.coordinate.latitude, place.coordinate.longitude);
                    
                      self.strMapAddress = [NSString stringWithFormat:@"%@, %@",place.name, place.formattedAddress];
                      
                      self.sellerLocation = loc;
                      marker.map= _mapView;
                      _mapView.settings.compassButton = false;

                      [_markerImage setHidden:NO];
                  }
                  else {
                      NSLog(@"Could not locate");
                  }
              }
     ];
}

- (void)tableDataSource:(GMSAutocompleteTableDataSource *)tableDataSource
didFailAutocompleteWithError:(NSError *)error {
    [searchDisplayController setActive:NO animated:YES];
    // TODO: handle the error.
    NSLog(@"Error: %@", [error description]);
}

- (void)didUpdateAutocompletePredictionsForTableDataSource:
(GMSAutocompleteTableDataSource *)tableDataSource {
    // Turn the network activity indicator off.
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    // Reload table data.
    [searchDisplayController.searchResultsTableView reloadData];
}

- (void)didRequestAutocompletePredictionsForTableDataSource:
(GMSAutocompleteTableDataSource *)tableDataSource {
    // Turn the network activity indicator on.
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    // Reload table data.
    [searchDisplayController.searchResultsTableView reloadData];
}

@end
