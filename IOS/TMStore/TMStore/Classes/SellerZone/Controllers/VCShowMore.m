//
//  VCShowMore.m
//  TMStore
//
//  Created by Rajshekhar on 21/07/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import "VCShowMore.h"
#import "Variables.h"
#import "Utility.h"
#import "AnalyticsHelper.h"
#import "CellLineItem.h"
#import "Order.h"
#import "AppUser.h"
#import "VCBillingAddress.h"
#import "VCShippingAddress.h"
#import "SellerZoneManager.h"
#import "LineItem.h"
#import "DataManager.h"


@interface VCShowMore ()<UITableViewDelegate, UITableViewDataSource,UIScrollViewDelegate> {
    NSMutableArray* _viewsAdded;
    UIButton *customBackButton;
    NSArray* arrayOrder;
    NSArray* pickerArray;
    NSArray* pickerArrayOriginalStatus;
    NSString *resultString;
    IBOutlet UIButton *buttonUpdateOrder;
    IBOutlet UIButton *buttonShipping;
    IBOutlet UIButton *buttonBilling;

    //IBOutlet UILabel *labelTotalTax;
     IBOutlet UILabel *orderStatusString;
     IBOutlet UILabel *labelTotalTaxString;
     IBOutlet UILabel *labelDiscountString;
     IBOutlet UILabel *labelShippingChargersString;
     IBOutlet UILabel *labelExtraFeeString;
     IBOutlet UILabel *labelGrandTotalString;
     IBOutlet UILabel *labelDeliveryDateString;
     IBOutlet UILabel *labelDeliveryTimeString;
     IBOutlet UILabel *labelPaymentMethodString;
     IBOutlet UILabel *labelShippingMethodNameString;
     IBOutlet UILabel *labelShippingMethodPriceString;
     IBOutlet UILabel *labelCurrencyTotalString;
     IBOutlet UILabel *labelCurrencyString;
     IBOutlet UIBarButtonItem *barCancel;
     IBOutlet UIBarButtonItem *barDone;

}

@end

@implementation VCShowMore

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


    pickerArray = @[
                   Localize(@"pending"),
                   Localize(@"processing"),
                   Localize(@"onhold"),
                   Localize(@"completed"),
                   Localize(@"cancelled"),
                   Localize(@"refunded"),
                   Localize(@"failed")
                   ];

    pickerArrayOriginalStatus = @[
                                @"pending",
                                @"processing",
                                @"on-hold",
                                @"completed",
                                @"cancelled",
                                @"refunded",
                                @"failed"
                                ];

//    "pending": "Pending Payment",
//    "processing": "Processing",
//    "on-hold": "On Hold",
//    "completed": "Completed",
//    "cancelled": "Cancelled",
//    "refunded": "Refunded",
//    "failed": "Failed"


    [_viewTaxes.layer setCornerRadius:10.0f];
    _viewTaxes.layer.borderColor = [UIColor redColor].CGColor;

    [_pickerViewOptions setHidden:YES];
    [_doneToolBar setHidden:YES];

    //Set Main Cell in Tableview

    [_table_lineItemes registerNib:[UINib nibWithNibName:@"CellLineItem"
                                                    bundle:[NSBundle mainBundle]]
              forCellReuseIdentifier:@"CellLineItem"];

    //_scrollView.contentSize=CGSizeMake(self.view.frame.size.width,3000);

    [buttonUpdateOrder setTitle:Localize(@"update_order") forState:UIControlStateNormal];

    [buttonBilling setTitle:Localize(@"billing_address") forState:UIControlStateNormal];
    [buttonShipping setTitle:Localize(@"shipping_address") forState:UIControlStateNormal];

    labelTotalTaxString.text = Localize(@"total_tax");
    labelDiscountString.text = Localize(@"discount");
    labelShippingChargersString.text = Localize(@"i_total_shipping_cost");
    labelExtraFeeString.text = Localize(@"total_extra_fee");
    labelGrandTotalString.text = Localize(@"grand_total");
    labelDeliveryDateString.text = Localize(@"delivery_date");
    labelDeliveryTimeString.text = Localize(@"delivery_time");
    labelPaymentMethodString.text = Localize(@"payment_method");
    labelShippingMethodNameString.text = Localize(@"shipping_methods");
    [barCancel setTitle:Localize(@"cancel")];
    [barDone setTitle:Localize(@"done")];
    orderStatusString.text = Localize(@"title_order_status");


}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
//    _scrollView.contentSize = CGSizeMake(self.view.frame.size.width, CGRectGetMaxY(_pickerViewOptions.frame));

    if (self.selectedOrder) {
        NSString* finalStatus = @"";
        int i = 0;
        for (NSString* str in pickerArrayOriginalStatus) {
            if ([[str lowercaseString] isEqualToString:[self.selectedOrder._status lowercaseString]]) {
                finalStatus = [pickerArray objectAtIndex:i];
                resultString = finalStatus;
                _orderStatus.text = resultString;
                _orderStatus.textColor = [UIColor redColor];
                break;
            }
            i++;
        }
    }

}
- (IBAction)barButtonBackPressed:(id)sender {

    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)updateOrderAction:(id)sender {
    
    [_pickerViewOptions setHidden:NO];
    [_doneToolBar setHidden:NO];


}
- (IBAction)buttonShippingAddressAction:(id)sender {

    VCShippingAddress *vcShipping=[[VCShippingAddress alloc] initWithNibName:@"VCShippingAddress" bundle:nil];
    [vcShipping setData:self.selectedOrder];
    [self presentViewController:vcShipping animated:YES completion:nil];

}
- (IBAction)buttonBillingAddressAction:(id)sender {

    VCBillingAddress *vcBilling=[[VCBillingAddress alloc] initWithNibName:@"VCBillingAddress" bundle:nil];
    [vcBilling setData:self.selectedOrder];
    [self presentViewController:vcBilling animated:YES completion:nil];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - TableView-Delegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

//    Order* order = [self.layer valueForKey:@"ORDER_OBJ"];
//    if (order) {
//        return [order._line_items count];
//    }
//	return 1;
    if (self.selectedOrder && self.selectedOrder._line_items) {
        return [self.selectedOrder._line_items count];
    }



    return 0;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 150;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *simpleTableIdentifier = @"CellLineItem";

    CellLineItem *cell = (CellLineItem *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];

    if (cell == nil)
    {
       cell = [[CellLineItem alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];

    }

    if(self.selectedOrder){
        LineItem *lItem = [self.selectedOrder._line_items objectAtIndex:indexPath.row];
        [cell.labelOrderName setText:lItem._name];
        [cell.labelQuantity setText:[NSString stringWithFormat:@"%d",lItem._quantity]];
        [cell.orderImage setImage:[Utility getPlaceholderImage:0]];
        float orderPrice = lItem._price;
        float price = orderPrice;
        [cell.labelOrderPrice setText:[NSString stringWithFormat:@"%@",[[Utility sharedManager] getCurrencyWithSign:price currencyCode:self.selectedOrder._currency symbolAtLast:false]]];

        float orderPriceTotal = lItem._total;
        float priceTotal = orderPriceTotal;
        [cell.labelTotal setText:[NSString stringWithFormat:@"%@",[[Utility sharedManager] getCurrencyWithSign:priceTotal currencyCode:self.selectedOrder._currency symbolAtLast:false]]];
        [_labelTotalTax setText:[NSString stringWithFormat:@"%.2f",self.selectedOrder._total_tax]];
        [_labelDiscount setText:[NSString stringWithFormat:@"%.2f",self.selectedOrder._total_discount]];
        // [_labelShippingChargers setText:[NSString stringWithFormat:@"%.2f",self.selectedOrder._shipping_tax]];
        float grandTotal = self.selectedOrder._total.floatValue;
        float priceGrandTotal = grandTotal;
        [_labelGrandTotal setText:[NSString stringWithFormat:@"%@",[[Utility sharedManager] getCurrencyWithSign:priceGrandTotal currencyCode:self.selectedOrder._currency symbolAtLast:false]]];

        float orderShippingCurrency = 0.0f;
        if (self.selectedOrder._shipping_lines && [self.selectedOrder._shipping_lines count] > 0) {
            orderShippingCurrency = [[[self.selectedOrder._shipping_lines objectAtIndex:0] objectForKey:@"total"] floatValue];
        }

        float shippingPrice = orderShippingCurrency;
        [_labelShippingMethodPrice setText:[NSString stringWithFormat:@"%@",[[Utility sharedManager] getCurrencyWithSign:shippingPrice currencyCode:self.selectedOrder._currency symbolAtLast:false]]];
        [_labelShippingChargers setText:[NSString stringWithFormat:@"%@",[[Utility sharedManager] getCurrencyWithSign:shippingPrice currencyCode:self.selectedOrder._currency symbolAtLast:false]]];

        [_labelPaymentMethod setText:[NSString stringWithFormat:@"%@",self.selectedOrder._payment_details._method_title]];



        [_labelShippingMethodName setText:@""];
        if (self.selectedOrder._shipping_lines && [self.selectedOrder._shipping_lines count] > 0) {
        [_labelShippingMethodName setText:[[self.selectedOrder._shipping_lines objectAtIndex:0] objectForKey:@"method_title"]];
        }

        [[cell labelOrderName] setUIFont:kUIFontType16 isBold:false];
        [[cell labelQuantity] setUIFont:kUIFontType16 isBold:false];
        [[cell labelOrderPrice] setUIFont:kUIFontType16 isBold:false];
        [[cell labelTotal] setUIFont:kUIFontType16 isBold:false];
        [_labelTotalTax setUIFont:kUIFontType16 isBold:false];
        [_labelDiscount setUIFont:kUIFontType16 isBold:false];
        [_labelShippingChargers setUIFont:kUIFontType16 isBold:false];
        [_labelGrandTotal setUIFont:kUIFontType16 isBold:true];
        [_labelShippingMethodName setUIFont:kUIFontType16 isBold:false];
        [_labelShippingMethodPrice setUIFont:kUIFontType16 isBold:false];
        [_labelDeliveryDate setUIFont:kUIFontType16 isBold:false];
        [_labelDeliveryTime setUIFont:kUIFontType16 isBold:false];
        [[cell labelOrderPriceString]setText:Localize(@"i_price")];
        [[cell labelQuantityString]setText:Localize(@"label_quantity")];
        [[cell labelTotalString]setText:Localize(@"total_order")];


        [cell.orderImage setImage:[Utility getPlaceholderImage:0]];
        ProductInfo* pInfo = [ProductInfo getProductWithId:lItem._product_id];
        if (pInfo && pInfo._images && [pInfo._images count] > 0) {
            ProductImage* pImage = [pInfo._images objectAtIndex:0];
            [Utility setImage:cell.orderImage url:pImage._src resizeType:0 isLocal:false highPriority:false];
        }

    }

    return cell;
}
#pragma mark -
#pragma mark PickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:
(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    return pickerArray.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    return pickerArray[row];
}
#pragma mark -
#pragma mark PickerView Delegate
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row
      inComponent:(NSInteger)component
{
    resultString = [[NSString alloc] initWithFormat:
                             @"%@",
                              pickerArray[row]];
    }

- (IBAction)DoneAction:(id)sender {
    [_pickerViewOptions setHidden:YES];
    [_doneToolBar setHidden:YES];

    NSString* finalStatus = @"";
    int i = 0;
    for (NSString* str in pickerArray) {
        if ([str isEqualToString:resultString]) {
            finalStatus = [pickerArrayOriginalStatus objectAtIndex:i];
            break;
        }
        i++;
    }
    [self updateOrderStatus:finalStatus];
}
- (void)updateOrderStatus:(NSString*)status {
    if (self.selectedOrder) {
        [[[DataManager sharedManager] tmDataDoctor] updateSellerOrder:self.selectedOrder orderStatus:status success:^(id data) {
            self.selectedOrder = data;
            
            
            if (self.selectedOrder) {
                NSString* finalStatus = @"";
                int i = 0;
                for (NSString* str in pickerArrayOriginalStatus) {
                    if ([[str lowercaseString] isEqualToString:[self.selectedOrder._status lowercaseString]]) {
                        finalStatus = [pickerArray objectAtIndex:i];
                        resultString = finalStatus;
                        _orderStatus.text = resultString;
                        _orderStatus.textColor = [UIColor redColor];
                        break;
                    }
                    i++;
                }
            }
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:Localize(@"i_success") message:Localize(@"status_updated_successfully") delegate:self cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil, nil];
            [alert show];
        } failure:^(NSString *error) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:Localize(@"failed") message:Localize(@"try_again") delegate:self cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:Localize(@"retry"), nil];
            [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (buttonIndex == 1) {
                    [self updateOrderStatus:status];
                }
            }];
        }];
    }

}
- (IBAction)CancelAction:(id)sender{
    [_pickerViewOptions setHidden:YES];
    [_doneToolBar setHidden:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)setData:(Order*)order {
    self.selectedOrder = order;
}
@end
