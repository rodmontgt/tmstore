//
//  VCMyOrders.m
//  TMStore
//
//  Created by Rajshekhar on 19/07/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import "VCMyOrders.h"
#import "Variables.h"
#import "Utility.h"
#import "AnalyticsHelper.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "CellOrderItem.h"
#import "Order.h"
#import "AppUser.h"
#import "VCShowMore.h"
#import "ProductImage.h"
#import "ProductInfo.h"
#import "Order.h"
#import "DataManager.h"
#import "SellerZoneManager.h"

@interface VCMyOrders (){
    NSMutableArray* _viewsAdded;
    UIButton *customBackButton;
    NSArray* arrayOrder;
    UIActivityIndicatorView *activityView;
}
@end

@implementation VCMyOrders

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [Utility getUIColor:kUIColorThemeFont], NSForegroundColorAttributeName, [Utility getUIFont:kUIFontType24 isBold:false], NSFontAttributeName, nil]];
    [self.currentItemHeading setTitle:Localize(@"title_seller_orders")];
    
    _labelViewHeading = [[UILabel alloc] init] ;
    [_labelViewHeading setFrame:CGRectMake(0, 20, [[MyDevice sharedManager] screenSize].width, _navigationBar.frame.size.height)];
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
    
    self.pickerArray = @[
                         Localize(@"pending"),
                         Localize(@"processing"),
                         Localize(@"onhold"),
                         Localize(@"completed"),
                         Localize(@"cancelled"),
                         Localize(@"refunded"),
                         Localize(@"failed")
                         ];
    
    self.pickerArrayOriginalStatus = @[
                                       @"pending",
                                       @"processing",
                                       @"on-hold",
                                       @"completed",
                                       @"cancelled",
                                       @"refunded",
                                       @"failed"
                                       ];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //get seller orders
    AppUser* appUser = [AppUser sharedManager];
    [[[DataManager sharedManager] tmDataDoctor] getOrdersOfSeller:appUser._id success:^(id data){
        NSLog(@"%@",data);
        //        [self.tabel_orders reloadData];
        SellerZoneManager *szoManager = [SellerZoneManager getInstance];
        szoManager.myOrders = data;
        [self fetchImages];
    } failure:^(NSString *error) {
        NSLog(@"%@",error);
    }];
}

- (void)fetchImages {
    SellerZoneManager *szoManager = [SellerZoneManager getInstance];
    NSMutableArray* pids = [[NSMutableArray alloc] init];
    for (Order* order in szoManager.myOrders) {
        for (LineItem* lineItem in order._line_items) {
            int pId = lineItem._product_id;
            [pids addObject:[NSString stringWithFormat:@"%d", pId]];
        }
    }
    if ([pids count] > 0) {
        [[[DataManager sharedManager] tmDataDoctor] fetchProductsFullDataFromPlugin:pids success:^(id data) {
            [activityView stopAnimating];
            [self.tabel_orders reloadData];
        } failure:^{
            [activityView stopAnimating];
            [self.tabel_orders reloadData];
        }];
    } else {
        [self.tabel_orders reloadData];
    }
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    // activity indicatorview
    activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityView.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    // activityView.center=self.view.center;
    [activityView startAnimating];
    [self.view addSubview:activityView];
    
}
- (IBAction)barButtonBackPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView-Delegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[[SellerZoneManager getInstance] myOrders]count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 150;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *simpleTableIdentifier = @"CellOrderItem";
    CellOrderItem *cell = (CellOrderItem *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    cell.buttonShowMore.tag = indexPath.row;
    // [cell.buttonShowMore addTarget:self action:@selector(buttonShowMoreAction:) forControlEvents:UIControlEventTouchUpInside];
    
    if (cell == nil)
    {
        cell = [[CellOrderItem alloc] initWithStyle:UITableViewCellStyleDefault
                                    reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    Order *oInfo = (Order*) [[[SellerZoneManager getInstance] myOrders]objectAtIndex:indexPath.row];
    LineItem *lItem = [oInfo._line_items objectAtIndex:0];
    [cell.labelOrderName setText:lItem._name];
    
    //[[cell labelAmount]setText:oInfo._total];
    float productTotalPrice = [oInfo._total floatValue];
    float price = productTotalPrice;
    
    [cell.labelAmount setText:[NSString stringWithFormat:@"%@",[[Utility sharedManager] getCurrencyWithSign:price currencyCode:oInfo._currency symbolAtLast:false]]];
    
    if (oInfo) {
        NSString* finalStatus = @"";
        int i = 0;
        for (NSString* str in self.pickerArrayOriginalStatus) {
            if ([[str lowercaseString] isEqualToString:[oInfo._status lowercaseString]]) {
                finalStatus = [self.pickerArray objectAtIndex:i];
                [[cell labelOrderStatus]setText:finalStatus];
                break;
            }
            i++;
        }
    }
    NSDateFormatter * df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-M-d"];
    [[cell labelOrderDate]setText:[df stringFromDate:oInfo._updated_at]];
    [[cell labelOrderId] setText:[NSString stringWithFormat:@"%d",oInfo._id]];
    
    [cell.orderImage setImage:[Utility getPlaceholderImage:0]];
    ProductInfo* pInfo = [ProductInfo getProductWithId:lItem._product_id];
    if (pInfo && pInfo._images && [pInfo._images count] > 0) {
        ProductImage* pImage = [pInfo._images objectAtIndex:0];
        [Utility setImage:cell.orderImage url:pImage._src resizeType:0 isLocal:false highPriority:false];
    }
    
    [cell.lblOrder setText:Localize(@"i_orderid")];
    // [cell.labelCurrency setText:oInfo._currency];
    return cell;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    VCShowMore *vcShowMore=[[VCShowMore alloc] initWithNibName:@"VCShowMore" bundle:nil];
    Order *order = (Order*) [[[SellerZoneManager getInstance] myOrders]objectAtIndex:indexPath.row];
    [vcShowMore setData:order];
    [self presentViewController:vcShowMore animated:YES completion:nil];
    
}
-(void)buttonShowMoreAction:(UIButton*)sender
{
    VCShowMore *vcShowMore=[[VCShowMore alloc] initWithNibName:@"VCShowMore" bundle:nil];
    [self presentViewController:vcShowMore animated:YES completion:nil];
}

@end
