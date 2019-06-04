//
//  VCBillingAddress.m
//  TMStore
//
//  Created by Rajshekhar on 27/07/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import "VCBillingAddress.h"
#import "Variables.h"
#import "Utility.h"
#import "AnalyticsHelper.h"
#import "SellerZoneManager.h"

@interface VCBillingAddress (){
    NSMutableArray* _viewsAdded;
    UIButton *customBackButton;
}
@end

@implementation VCBillingAddress

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [Utility getUIColor:kUIColorThemeFont], NSForegroundColorAttributeName, [Utility getUIFont:kUIFontType24 isBold:false], NSFontAttributeName, nil]];
    [self.currentItemHeading setTitle:@"Billing Address"];
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
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    Order *oInfo = self.selectedOrder;
    [_labelFirstName setText:[NSString stringWithFormat:@"%@",oInfo._billing_address._first_name]];
    [_labelLastName setText:[NSString stringWithFormat:@"%@",oInfo._billing_address._last_name]];
    [_labelCompanyName setText:[NSString stringWithFormat:@"%@",oInfo._billing_address._company]];
    [_labelAddress1 setText:[NSString stringWithFormat:@"%@",oInfo._billing_address._address_1]];
    [_labelAddress2 setText:[NSString stringWithFormat:@"%@",oInfo._billing_address._address_2]];
    [_labelCity setText:[NSString stringWithFormat:@"%@",oInfo._billing_address._city]];
    [_labelState setText:[NSString stringWithFormat:@"%@",oInfo._billing_address._state]];
    [_labelPostCode setText:[NSString stringWithFormat:@"%@",oInfo._billing_address._postcode]];
    [_labelCountry setText:[NSString stringWithFormat:@"%@",oInfo._billing_address._country]];
    [_labelEmail setText:[NSString stringWithFormat:@"%@",oInfo._billing_address._email]];
    [_labelPhone setText:[NSString stringWithFormat:@"%@",oInfo._billing_address._phone]];
    
    [_labelFirstName setUIFont:kUIFontType16 isBold:false];
    [_labelLastName setUIFont:kUIFontType16 isBold:false];
    [_labelCompanyName setUIFont:kUIFontType16 isBold:false];
    [_labelAddress1 setUIFont:kUIFontType16 isBold:false];
    [_labelAddress2 setUIFont:kUIFontType16 isBold:false];
    [_labelCity setUIFont:kUIFontType16 isBold:false];
    [_labelState setUIFont:kUIFontType16 isBold:false];
    [_labelPostCode setUIFont:kUIFontType16 isBold:false];
    [_labelCountry setUIFont:kUIFontType16 isBold:false];
    [_labelEmail setUIFont:kUIFontType16 isBold:false];
    [_labelPhone setUIFont:kUIFontType16 isBold:false];
    
}
- (IBAction)barButtonBackPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
