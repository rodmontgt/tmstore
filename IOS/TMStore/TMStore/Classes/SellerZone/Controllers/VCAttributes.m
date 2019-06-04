//
//  VCAttributes.m
//  TMStore
//
//  Created by Rajshekhar on 24/07/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import "VCAttributes.h"
#import "Variables.h"
#import "Utility.h"
#import "AnalyticsHelper.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "CellAttributes.h"
#import "VCAttributeDetails.h"
#import "DataManager.h"
@interface VCAttributes ()<UITableViewDelegate, UITableViewDataSource> {
    NSMutableArray* _viewsAdded;
    UIButton *customBackButton;
    NSMutableArray *arrayAttributes;
    IBOutlet UITableView *tableViewAttributes;
}
@end

@implementation VCAttributes
- (void)viewDidLoad {
    [super viewDidLoad];
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [Utility getUIColor:kUIColorThemeFont], NSForegroundColorAttributeName, [Utility getUIFont:kUIFontType24 isBold:false], NSFontAttributeName, nil]];
    [self.currentItemHeading setTitle:@"Attributes"];
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
    //Set Main Cell in Tableview
    [tableViewAttributes registerNib:[UINib nibWithNibName:@"CellAttributes" bundle:[NSBundle mainBundle]]forCellReuseIdentifier:@"CellAttributes"];
    arrayAttributes = [[NSMutableArray alloc] init];
    //    [self loadAllAttributes];
}
- (void)loadAllAttributes {
    if ([[SZAttribute getAllSZAttributesNames] count] == 0) {
        [[[DataManager sharedManager] tmDataDoctor] getAllAttributes:^{
            arrayAttributes = [SZAttribute getAllSZAttributesNames];
            [tableViewAttributes reloadData];
        } failure:^(NSString *error) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error!" message:@"Fetching attributes failed. Please retry." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Retry", nil];
            [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (buttonIndex == 1) {
                    [self loadAllAttributes];
                }
            }];
        }];
    } else {
        arrayAttributes = [SZAttribute getAllSZAttributesNames];
        [tableViewAttributes reloadData];
    }
}
- (void)loadAllAttributesForCategories:(NSArray*)cIds {
    if (true){ //[[SZAttribute getAllSZAttributesNames] count] == 0
        [_spinner startAnimating];
        [[[DataManager sharedManager] tmDataDoctor] getAllAttributesForCategories:cIds success:^{
            arrayAttributes = [SZAttribute getAllSZAttributesNames];
            [tableViewAttributes reloadData];
            [_spinner stopAnimating];
            [_spinner removeFromSuperview];
        } failure:^(NSString *error) {
            [_spinner stopAnimating];
            [_spinner removeFromSuperview];
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error!" message:@"Fetching attributes failed. Please retry." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Retry", nil];
            [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (buttonIndex == 1) {
                    [self loadAllAttributes];
                }
            }];
        }];
    } else {
        arrayAttributes = [SZAttribute getAllSZAttributesNames];
        [tableViewAttributes reloadData];
    }
}
- (IBAction)barButtonBackPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - TableView-Delegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return arrayAttributes.count;
}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return 150;
//}
//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *simpleTableIdentifier = @"CellAttributes";
    CellAttributes *cell = (CellAttributes *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        cell = [[CellAttributes alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    cell.labelAttributeName.text = arrayAttributes[indexPath.row];
    [[cell labelAttributeName] setUIFont:kUIFontType16 isBold:false];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    VCAttributeDetails *vcAttributeDetails = [[VCAttributeDetails alloc] initWithNibName:@"VCAttributeDetails" bundle:nil];
    vcAttributeDetails.attributeName = arrayAttributes[indexPath.row];
    SZAttribute* szAtt = [SZAttribute getSZAttributeByName:arrayAttributes[indexPath.row]];
    [vcAttributeDetails setData:szAtt];
    [self presentViewController:vcAttributeDetails animated:YES completion:nil];
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

@end
