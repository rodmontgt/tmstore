//
//  ViewControllerNotification.m
//  TMStore
//
//  Created by Twist Mobile on 28/02/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import "ViewControllerNotification.h"
#import "Utility.h"
#import "DataManager.h"
#import "Variables.h"

@interface ViewControllerNotification ()

@end

@implementation ViewControllerNotification

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
    [_labelViewHeading setText:[NSString stringWithFormat:@"%@",Localize(@"title_notification")]];
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
    
    
    application =(AppDelegate*)[UIApplication sharedApplication].delegate;
    self.devices =[[NSMutableArray alloc]init];
    
    [_keepShoping setBackgroundColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
    [[_keepShoping titleLabel] setUIFont:kUIFontType22 isBold:false];
    [_keepShoping setTitle:Localize(@"keep_shopping_cart") forState:UIControlStateNormal];
    [_keepShoping setTitleColor:[Utility getUIColor:kUIColorBuyButtonFont] forState:UIControlStateNormal];
    
    [_noNotificationFound setTextColor:[Utility getUIColor:kUIColorFontLight]];
    [_noNotificationFound setNumberOfLines:0];
    [_noNotificationFound setUIFont:kUIFontType16 isBold:false];
    [_noNotificationFound setText:[NSString stringWithFormat:@"%@:", Localize(@"no_notifications_found")]];
}
-(void)viewDidAppear:(BOOL)animated{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"NotificationsList"];
    self.devices = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    NSLog(@"devices  %@",self.devices);
    [self reloadTable];
    if (self.devices.count == 0) {
        self.viewKeepShoping.hidden = false;
        self.tableData.hidden = true;
    }else{
        self.viewKeepShoping.hidden = true;
        self.tableData.hidden = false;
    }
}
- (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

#pragma mark - UITableview Delegate Methord

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.devices.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *simpleTableIdentifier = @"NotificationCell";
    NotificationCell *cell = (NotificationCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"NotificationCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    UIImage* normalC;
    UIImage* selectedC;
    UIImage* highlightedC;
    
    NSManagedObject *device = [self.devices objectAtIndex:indexPath.row];
    NSLog(@"%@",[device valueForKey:@"notificationtitle"]);
    
    if ([device valueForKey:@"descriptions"] != nil) {
        cell.Description.text = [device valueForKey:@"descriptions"];
    }
    if ([device valueForKey:@"timeanddate"] != nil) {
        cell.DateAndTime.text = [device valueForKey:@"timeanddate"];
    }
    if ([device valueForKey:@"notificationtitle"] != nil) {
        cell.Title.text = [device valueForKey:@"notificationtitle"];
        if ([[device valueForKey:@"notificationtitle"] isEqualToString:@"Cart"]) {
            normalC  = [[UIImage imageNamed:@"btn_cart"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            selectedC = [[UIImage imageNamed:@"btn_cart"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            highlightedC = [[UIImage imageNamed:@"btn_cart"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
        else if ([[device valueForKey:@"notificationtitle"] isEqualToString:@"wishlist"]) {
            normalC = [[UIImage imageNamed:@"btn_wishlist"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            selectedC = [[UIImage imageNamed:@"btn_wishlist"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            highlightedC = [[UIImage imageNamed:@"btn_wishlist"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            
        }else if ([[device valueForKey:@"notificationtitle"] isEqualToString:@"Category"]) {
            normalC = [[UIImage imageNamed:@"btn_category"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            selectedC = [[UIImage imageNamed:@"btn_category"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            highlightedC = [[UIImage imageNamed:@"btn_category"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }else {
            normalC = [[UIImage imageNamed:@"notification_icon_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            selectedC = [[UIImage imageNamed:@"notification_icon_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            highlightedC = [[UIImage imageNamed:@"notification_icon_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
    }else{
        NSString* stringAppDisplayName = Localize(@"app_display_name");
        if ([stringAppDisplayName isEqualToString:@""] || [stringAppDisplayName isEqualToString:@"app_display_name"]) {
            stringAppDisplayName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
        }
        normalC = [[UIImage imageNamed:@"notification_icon_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        selectedC = [[UIImage imageNamed:@"notification_icon_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        highlightedC = [[UIImage imageNamed:@"notification_icon_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        NSString* appName = stringAppDisplayName;
        cell.Title.text = appName;
    }
    if ([[device valueForKey:@"backgroundcolor"] isEqualToString:@"yellow"]) {
        cell.viewBackground.backgroundColor = [UIColor yellowColor];
        cell.viewBackground.alpha = 0.2;
    }else{
        cell.viewBackground.backgroundColor = [UIColor whiteColor];
    }
    [[cell Title] setUIFont:kUIFontType16 isBold:false];
    [[cell Title] setTextColor:[Utility getUIColor:kUIColorFontDark]];
    [[cell Description] setUIFont:kUIFontType16 isBold:false];
    [[cell Description] setTextColor:[Utility getUIColor:kUIColorFontDark]];
    [[cell DateAndTime] setUIFont:kUIFontType16 isBold:false];
    [[cell DateAndTime] setTextColor:[Utility getUIColor:kUIColorFontDark]];
    
    [cell.buttonicone setUIImage:normalC forState:UIControlStateNormal];
    [cell.buttonicone setUIImage:selectedC forState:UIControlStateSelected];
    [cell.buttonicone setUIImage:highlightedC forState:UIControlStateHighlighted];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete object from database
        [context deleteObject:[self.devices objectAtIndex:indexPath.row]];
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
            return;
        }
        
        // Remove device from table view
        [self.devices removeObjectAtIndex:indexPath.row];
        [self.tableData deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self reloadTable];
        if (self.devices.count == 0) {
            self.viewKeepShoping.hidden = false;
            self.tableData.hidden = true;
        }else{
            self.viewKeepShoping.hidden = true;
            self.tableData.hidden = false;
        }
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSManagedObject *device = [self.devices objectAtIndex:indexPath.row];
    if (device) {
        [device setValue:@"white" forKey:@"backgroundcolor"];
    }
    int notificationDataType = [[device valueForKey:@"type"] intValue];
    int notificationDataId = [[device valueForKey:@"id"] intValue];
    int notificationDataVarId = -1;
    NSString* notificationDataContent = [device valueForKey:@"content"];
    if (notificationDataType != -1) {
        switch (notificationDataType) {
            case nType_DoNothing://do nothing
            {
                
            }break;
            case nType_OpenProduct://open product
            {
                int productId = notificationDataId;
                int productVarId = notificationDataVarId;
                ProductInfo* pInfo = (ProductInfo*)[ProductInfo getProductWithId:productId];
                if (pInfo) {
                    [self clickOnProduct:pInfo currentItemData:nil cell:nil];
                } else {
                    ProductInfo* pInfo = [[ProductInfo alloc] init];
                    pInfo._id = productId;
                    [self clickOnProduct:pInfo currentItemData:nil cell:nil];
                }
            }break;
            case nType_OpenCategory://open category
            {
                int categoryId = notificationDataId;
                CategoryInfo *cInfo = [CategoryInfo getWithId:categoryId];
                [self clickOnCategory:cInfo currentItemData:nil];
            }break;
            case nType_OpenWishlist://open wishlist
            {
                ViewControllerMain* mainVC = [ViewControllerMain getInstance];
                [mainVC btnClickedWishlist:nil];
            }break;
            case nType_OpenCart://open cart
            {
                if (![notificationDataContent isEqualToString:@""]) {
                    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                    pasteboard.string = notificationDataContent;
                }
                ViewControllerMain* mainVC = [ViewControllerMain getInstance];
                [mainVC btnClickedCart:nil];
            }break;
            default:
                break;
        }
    }
}
-(void)reloadTable{
    if (self.tableData.delegate == nil) {
        self.tableData.delegate = self;
        self.tableData.dataSource = self;
        [self.tableData reloadData];
    }else{
        [self.tableData reloadData];
    }
}

#pragma mark - All Button Actions

- (IBAction)barButtonBackPressed:(id)sender {
    [[Utility sharedManager] popScreen:self];
    if ([self.view tag] == PUSH_SCREEN_TYPE_NOTIFICATION) {
        return;
    }
    ViewControllerMain* mainVC = [ViewControllerMain getInstance];
    [mainVC resetPreviousState];
}

- (IBAction)keepShoingAction:(id)sender {
    ViewControllerMain* mainVC = [ViewControllerMain getInstance];
    [mainVC btnClickedHome:nil];
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
     vcCategories.parentVC = self;
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
@end
