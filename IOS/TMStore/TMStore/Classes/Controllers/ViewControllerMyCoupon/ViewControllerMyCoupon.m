//
//  ViewControllerMyCoupon.m
//  TMStore
//
//  Created by Twist Mobile on 13/01/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import "ViewControllerMyCoupon.h"
#import "Utility.h"
#import "DataManager.h"
#import "Variables.h"
#import "MyCouponCell.h"
#import "ViewControllerCart.h"
#import "ViewControllerMyCouponProduct.h"
#
@interface ViewControllerMyCoupon ()



@end

@implementation ViewControllerMyCoupon

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
    [_labelViewHeading setText:[NSString stringWithFormat:@"%@",Localize(@"my_coupons")]];
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
    
    self.addindex =[[NSMutableArray alloc]init];
    if ([Coupon getAllCoupons] == NULL || [[Coupon getAllCoupons] count] == 0) {
        [self fetchCouponData];
        MRProgressOverlayView* mov = [Utility createCustomizedLoadingBar:Localize(@"") isBottomAlign:false isClearViewEnabled:false isShadowEnabled:true];
    }
    [self reloadTable];
    application =(AppDelegate*)[UIApplication sharedApplication].delegate;
}

- (void)fetchCouponData {
    [[[DataManager sharedManager] tmDataDoctor] fetchCouponsData:^(id data) {
        RLOG(@"data  %@",data);
        [self reloadTable];
        [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
    } failure:^(NSString *error) {
        [self fetchCouponData];
    }];
}

-(void)viewDidAppear:(BOOL)animated{
    [self reloadTable];
}
#pragma mark - UITableview Delegate Methord
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[Coupon sharedInstance] getcouponList].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"MyCouponCell";
    MyCouponCell *cell = (MyCouponCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MyCouponCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    Coupon *coupons = [[[Coupon sharedInstance] getcouponList] objectAtIndex:indexPath.row];
    [[cell.btnCoupone titleLabel] setUIFont:kUIFontType18 isBold:false];
    [cell.btnCoupone setTitle:coupons._code forState:UIControlStateNormal];
    [cell.btnCoupone setTitleColor:[Utility getUIColor:kUIColorFontDark] forState:UIControlStateNormal];
    [cell.btnCoupone sizeToFit];

    CAShapeLayer * dotborder = [CAShapeLayer layer];
    dotborder.strokeColor = [Utility getUIColor:kUIColorThemeFont].CGColor;//your own color
    dotborder.fillColor = nil;
    dotborder.lineDashPattern = @[@4, @4];//your own patten
    [cell.btnCoupone.layer addSublayer:dotborder];
    dotborder.frame = cell.btnCoupone.bounds;
    dotborder.path = [UIBezierPath bezierPathWithRect:cell.btnCoupone.bounds].CGPath;
 
    
    if (coupons._description != nil)
    {
        cell.lblDescription.text = coupons._description;
//        cell.lblDescription.text = @"bla1 bla2 bla3 bla4 bla5 bla6 bla7 bla8 bla9 bla10 bla11 bla12 bla13 bla14 bla15 bla16 bla17 bla18 bla19 bla20";
        [cell.lblDescription setUIFont:kUIFontType18 isBold:false];
        [cell.lblDescription setTextColor:[Utility getUIColor:kUIColorFontDark]];
        [cell.lblDescription sizeToFit];
    }
    
    if (coupons._expiry_date != nil)
    {
        NSString *expiry_date = [NSString stringWithFormat:@"%@",coupons._expiry_date];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ssZZZZ"];
        NSDate *date = [dateFormat dateFromString:expiry_date];
        [dateFormat setDateFormat:@"dd-MM-yyyy"];
        cell.lblExpiry_Date.text = [NSString stringWithFormat:@"%@",[dateFormat stringFromDate:date]];
        [cell.lblExpiry_Date setUIFont:kUIFontType18 isBold:false];
        [cell.lblExpiry_Date setTextColor:[Utility getUIColor:kUIColorFontDark]];
        [cell.lblExpiry_Date sizeToFit];
    }
    cell.apply.tag = indexPath.row;
    [cell.apply addTarget:self action:@selector(applyCoupon:) forControlEvents:UIControlEventTouchUpInside];
    [cell.apply setTitle:Localize(@"apply") forState:UIControlStateNormal];
    [[cell.apply titleLabel] setUIFont:kUIFontType18 isBold:false];
    [cell.apply setTitleColor:[Utility getUIColor:kUIColorThemeFont] forState:UIControlStateNormal];
    
    if ([coupons._type isEqualToString:@"fixed_product"]||[coupons._type isEqualToString:@"fixed_cart"]) {
        float newPrice = coupons._amount;
        NSString *Price = [[Utility sharedManager] convertToString:newPrice isCurrency:true];
        [cell.lblAmount setText:[NSString stringWithFormat:@"%@ : %@", Localize(@"i_available_discount"), Price]];
    }
    else if ([coupons._type isEqualToString:@"percent"]|| [coupons._type isEqualToString:@"percent_product"]) {
        cell.lblAmount.text =[NSString stringWithFormat:@"%@ : %d%%",Localize(@"i_available_discount"), (int)coupons._amount];
    }
    
    if (coupons._enable_free_shipping) {
        [cell.lblShiping setUIFont:kUIFontType18 isBold:false];
        [cell.lblShiping setTextColor:[Utility getUIColor:kUIColorFontDark]];
        cell.lblShiping.text =[NSString stringWithFormat:@"%@",Localize(@"free_shipping_available")];
        [cell.lblShiping sizeToFit];
    }else{
        cell.lblShiping.text =[NSString stringWithFormat:@""];
    }
    [cell.lblAmount setUIFont:kUIFontType18 isBold:false];
    [cell.lblAmount setTextColor:[Utility getUIColor:kUIColorFontDark]];
    [cell.lblAmount sizeToFit];
    
    [cell.lblCanNOT setUIFont:kUIFontType18 isBold:false];
    [cell.lblCanNOT setTextColor:[Utility getUIColor:kUIColorFontDark]];
    cell.lblCanNOT.text =[NSString stringWithFormat: @"%@",Localize(@"cannot_apply_coupons")];
    [cell.lblCanNOT sizeToFit];
    
    
    NSNumber *index = [NSNumber numberWithInt:indexPath.row];
    if([self.addindex containsObject:index])
    {
        [cell.apply setBackgroundColor:[UIColor redColor]];
        [cell.showMore setTitle:Localize(@"show_less") forState:UIControlStateNormal];
    }
    else
    {
        cell.showMore.tag  = indexPath.row;
        [cell.showMore addTarget:self action:@selector(showMoreAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.apply setBackgroundColor:[UIColor clearColor]];
        [cell.showMore setTitle:Localize(@"show_more") forState:UIControlStateNormal];
        [[cell.showMore titleLabel] setUIFont:kUIFontType18 isBold:false];
        [cell.showMore setTitleColor:[Utility getUIColor:kUIColorThemeFont] forState:UIControlStateNormal];
    }
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
        return 160.0f;
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
    if ([self.view tag] == PUSH_SCREEN_TYPE_MYCOPON) {
        return;
    }
    ViewControllerMain* mainVC = [ViewControllerMain getInstance];
    [mainVC resetPreviousState];
}

- (IBAction)applyCoupon:(id)sender {
    int index = (int)[sender tag];
    Coupon *coupons = [[[Coupon sharedInstance] getcouponList] objectAtIndex:index];
    if (coupons) {
        NSString* couponCodeStr = coupons._code;
        
        ViewControllerMain* vcMain = [ViewControllerMain getInstance];
        ViewControllerCart* cartVC = (ViewControllerCart*)[vcMain getCartViewController:vcMain];
        application.isPrevScreenCouponCode = true;
        [cartVC passCouponCode:couponCodeStr];
    }
}
- (IBAction)showMoreAction:(id)sender{
    
   int index = (int)[sender tag];
    
    ViewControllerMain* mainVC = [ViewControllerMain getInstance];
    ViewControllerMyCouponProduct* vcMyCouponProduct = (ViewControllerMyCouponProduct*)[[Utility sharedManager] pushScreenWithNewAnimation:mainVC.vcCenterTop type:PUSH_SCREEN_TYPE_MYCOPON_PRODUCT];
    [vcMyCouponProduct.view setTag:PUSH_SCREEN_TYPE_MYCOPON_PRODUCT];
    Coupon* c = [[[Coupon sharedInstance] getcouponList] objectAtIndex:index];
    [vcMyCouponProduct CouponData:c];
}
@end
