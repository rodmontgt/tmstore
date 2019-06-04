//
//  CurrencyViewController.m
//  GoogleMapsDemo
//
//  Created by Vikas Patidar on 20/12/17.
//  Copyright © 2017 TwistMobile. All rights reserved.
//

#import "CurrencyViewController.h"
#import "Utility.h"
#import "CurrencyViewCell.h"
#import "CurrencyItem.h"
#import "CommonInfo.h"
#import "CurrencyHelper.h"
#import "ProductInfo.h"
#import "Variation.h"

@interface CurrencyViewController ()<UITableViewDelegate,UITableViewDataSource>{

    UIButton *customBackButton;

    __weak IBOutlet UIView *mainView;

    CurrencyItem *selectedCurrencyItem;

    __weak IBOutlet UIButton *buttonChangeCurrency;
}

@end

@implementation CurrencyViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [Utility getUIColor:kUIColorThemeFont], NSForegroundColorAttributeName, [Utility getUIFont:kUIFontType24 isBold:false], NSFontAttributeName, nil]];
    [self.currentItemHeading setTitle:Localize(@"title_currency")];

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

    [buttonChangeCurrency setTitle:[NSString stringWithFormat:@"%@", Localize(@"change_currency")] forState:UIControlStateNormal];
    [buttonChangeCurrency setBackgroundColor:[Utility getUIColor:kUIColorThemeButtonNormal]];
    [buttonChangeCurrency setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //remove empty cells
    _currencyTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    //Set Main Cell in Tableview
    [_currencyTable registerNib:[UINib nibWithNibName:@"CurrencyViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"CurrencyViewCell"];

    _chkBoxCurrency = [[NSMutableArray alloc] init];

    NSMutableArray *currencyItemArray = [CurrencyItem currencyItemList];
    if ([currencyItemArray count] <= 1) {
        return;
    }
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

}
- (IBAction)backAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];

}
- (IBAction)barButtonBackPressed:(id)sender {

    [[Utility sharedManager] popScreen:self];
    if ([self.view tag] == PUSH_SCREEN_TYPE_SETTING) {
        return;
    }

}
#pragma mark - TableView-Delegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return [[CurrencyItem currencyItemList]count];

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *simpleTableIdentifier = @"CurrencyViewCell";

    CurrencyViewCell *cell = (CurrencyViewCell*)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];

    NSMutableArray *currencyItemArray = [CurrencyItem currencyItemList];
    CurrencyItem *currencyItem = [currencyItemArray objectAtIndex:indexPath.row];

    if (cell == nil) {
        cell = [[CurrencyViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    cell.currencyName.text = currencyItem.name;
    cell.currencyDesc.text = currencyItem.desc;

    if (currencyItem.flag == nil || [currencyItem.flag isEqualToString:@""]) {
        [cell.imageCurrency setHidden:YES];
    }
    [Utility setImage:cell.imageCurrency url:currencyItem.flag resizeType:kRESIZE_TYPE_PRODUCT_THUMBNAIL isLocal:false];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    [cell.buttonCheck addTarget:self action:@selector(chkBoxCurrencyClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cell.buttonCheck.layer setValue:currencyItem forKey:@"SELECTED_CURRENCY_ITEM"];
    [_chkBoxCurrency addObject:cell.buttonCheck];

    NSString *lastSelectedCurrencyName = [[NSUserDefaults standardUserDefaults]stringForKey:@"APP_CURRENCY"];
    if ([lastSelectedCurrencyName isEqualToString:currencyItem.name]) {
        [cell.buttonCheck setSelected:true];
    }


    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{


}
- (IBAction)changeCurrencyAction:(id)sender {
    if (selectedCurrencyItem == nil) {
        return;
    }

    NSString *currencyName = [[NSUserDefaults standardUserDefaults] stringForKey:@"APP_CURRENCY"];
    if (![selectedCurrencyItem.name isEqualToString:currencyName]) {
        [CurrencyHelper setSelectedCurrencyItem:selectedCurrencyItem];

        [CommonInfo sharedManager] -> _currency = selectedCurrencyItem.name;

        //format html text and returns plain text.
        selectedCurrencyItem.symbol = [[[NSAttributedString alloc] initWithData:[selectedCurrencyItem.symbol dataUsingEncoding:NSUnicodeStringEncoding]
                                                                        options:@ {NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType}
                                                             documentAttributes:nil
                                                                          error:nil] string];
        [CommonInfo sharedManager] -> _currency_format = selectedCurrencyItem.symbol;


        CurrencyItem *lastCurrencyItem = [CurrencyHelper getCurrencyItemWithName:currencyName];
        if (lastCurrencyItem != nil) {
            float rate =  selectedCurrencyItem.rate /lastCurrencyItem.rate;
            if([Cart getAll] != nil) {
                for (Cart *cart in [Cart getAll]) {
                    [cart setProductPrice:cart.productPrice * rate];
                }
            }

            for (ProductInfo *product in [ProductInfo getAll]) {
                if (product == nil) {
                    continue;
                }

                product._price = product._price * rate;
                product._regular_price = product._regular_price * rate;
                product._sale_price = product._sale_price * rate;
                product._priceMax = product._priceMax * rate;
                product._priceMin = product._priceMin * rate;

                if (product._variations) {
                    for (Variation *variation in product._variations) {
                        if (variation == nil) {
                            continue;
                        }

                        variation._price = variation._price * rate;
                        variation._regular_price = variation._regular_price * rate;
                        variation._sale_price = variation._sale_price * rate;
                    }
                }
            }
        }

        [ProductInfo resetAllProductLocalizedStrings];

        [[NSUserDefaults standardUserDefaults] setValue:selectedCurrencyItem.name forKey:@"APP_CURRENCY"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
        [MRProgressOverlayView showOverlayAddedTo:[[UIApplication sharedApplication] keyWindow] title:@"" mode:MRProgressOverlayViewModeIndeterminateSmallDefault animated:YES];
        
        [self refreshViewController];
    }
}

- (void)chkBoxCurrencyClicked:(id)sender {
    UIButton* senderButton = (UIButton*)sender;
    [senderButton setSelected:YES];
    for (UIButton* button in _chkBoxCurrency) {
        if(button != senderButton){
            [button setSelected:NO];
        }
    }
    if ([senderButton isSelected]) {
        selectedCurrencyItem = [senderButton.layer valueForKey:@"SELECTED_CURRENCY_ITEM"];
    }
}
- (void)refreshViewController {
    [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
    [ViewControllerMain resetInstance];//rpj
    UIStoryboard *sb = [Utility getStoryBoardObject];//rpj
                                                     //    [UIStoryboard storyboardWithName:STORYBOARD_NAME bundle:nil];

    SWRevealViewController *mainRevealController = [sb instantiateViewControllerWithIdentifier:VC_SWREVEAL];
    UIViewController *mainViewController = [sb instantiateViewControllerWithIdentifier:VC_MAIN];
    UIViewController *rightViewController = [sb instantiateViewControllerWithIdentifier:VC_RIGHT];
    UIViewController *leftViewController = [sb instantiateViewControllerWithIdentifier:VC_LEFT];
    mainRevealController = [[SWRevealViewController alloc] initWithRearViewController:leftViewController frontViewController:mainViewController];
    if ([[Addons sharedManager] multiVendor_enable] &&
        [[Addons sharedManager] multiVendor_screen_type] == MULTIVENDOR_SCREEN_SELLER) {
        [mainRevealController setRightViewController:rightViewController];
    }
    RLOG(@"rightViewController = %@", rightViewController);
    [[UIApplication sharedApplication].keyWindow setRootViewController:mainRevealController];
}


/*
#pragma mark - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
     }
 */
    
    @end
