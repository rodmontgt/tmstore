//
//  VCAttributeDetails.m
//  TMStore
//
//  Created by Rajshekhar on 25/07/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import "VCAttributeDetails.h"
#import "Variables.h"
#import "Utility.h"
#import "AnalyticsHelper.h"
#import "CellAttributesDetails.h"
#import "Attribute.h"
@interface VCAttributeDetails ()<UITableViewDelegate, UITableViewDataSource> {
    NSMutableArray* _viewsAdded;
    UIButton *customBackButton;
    IBOutlet UITableView *tableViewAttributeDetails;
    //    BOOL checked;
    NSMutableArray* optionArray;
}
@end
@implementation VCAttributeDetails
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [Utility getUIColor:kUIColorThemeFont], NSForegroundColorAttributeName, [Utility getUIFont:kUIFontType24 isBold:false], NSFontAttributeName, nil]];
    [self.currentItemHeading setTitle:_attributeName];
    
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
    [tableViewAttributeDetails registerNib:[UINib nibWithNibName:@"CellAttributesDetails" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"CellAttributesDetails"];
}
- (void)setData:(SZAttribute*)szAttribute {
    self.szAttribute = szAttribute;
    optionArray = [self.szAttribute getSZAttributeOptionNames];
}
- (IBAction)barButtonBackPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)barButtonCheckPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - TableView-Delegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (optionArray) {
        return [optionArray count];
    }
    return 0;
}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return 150;
//}
//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *simpleTableIdentifier = @"CellAttributesDetails";
    CellAttributesDetails *cell = (CellAttributesDetails *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil){
        cell = [[CellAttributesDetails alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    [cell.buttonCheckMark addTarget:self action:@selector(buttonCheckMarkAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.buttonCheckMark.tag = indexPath.row;
    [[cell labelAttributeDetail] setUIFont:kUIFontType16 isBold:false];
    cell.labelAttributeDetail.text = optionArray ? [optionArray objectAtIndex:indexPath.row] : @"";
    
    //cell.labelAttributeDetail.text = [optionArray objectAtIndex:indexPath.row] ;

    [self initCheckMarkButtons:cell.buttonCheckMark];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SZAttributeOption* szAttOption = [self.szAttribute getSZAttributeOptionByName:optionArray[indexPath.row]];
}

- (void)initCheckMarkButtons:(UIButton*)sender {
    int selectedOptionId = (int)sender.tag;
    SZAttributeOption* szAttOption = [self.szAttribute getSZAttributeOptionByName:optionArray[selectedOptionId]];
    if(szAttOption) {
        SelSZAtt* selSZAtt = [SelSZAtt getSelSZAttForSZAttribute:self.szAttribute];
        if ([selSZAtt containsAttributeOption:szAttOption]) {
            [sender setSelected:true];
        } else {
            [sender setSelected:false];
        }
        NSLog(@"selectedOptionId %d",selectedOptionId);
    }
}
- (void)resetCheckMarkButtons:(UIButton*)sender {
    BOOL isSelected = [sender isSelected];
    int selectedOptionId = (int)sender.tag;
    SZAttributeOption* szAttOption = [self.szAttribute getSZAttributeOptionByName:optionArray[selectedOptionId]];
    SelSZAtt* selSZAtt = [SelSZAtt getSelSZAttForSZAttribute:self.szAttribute];
    if (selSZAtt.options) {
        if (isSelected) {
            if (![selSZAtt containsAttributeOption:szAttOption]) {
                [selSZAtt.options addObject:szAttOption];
            }
        } else
            if ([selSZAtt containsAttributeOption:szAttOption]) {
                [selSZAtt removeAttributeOption:szAttOption];
            }
    }
    
//    NSMutableArray* selected = [SelSZAtt getAllSelSZAtt];
//    for (SelSZAtt* sel in selected) {
//        NSString* strOptions = @"";
//        int maxCount = (int)[sel.options count];
//        int i = 0;
//        for (SZAttributeOption* opt in sel.options) {
//            strOptions = [strOptions stringByAppendingString:opt.name];
//            if (i != maxCount - 1) {
//                strOptions = [strOptions stringByAppendingString:@", "];
//            }
//        }
//        RLOG(@"\n\nAttribute:%@\nOptions:%@", sel.attribute.name, strOptions);
//    }
}
- (void)buttonCheckMarkAction:(UIButton*)sender{
    BOOL isSelected = ![sender isSelected];
    [sender setSelected:isSelected];
    [self resetCheckMarkButtons:sender];
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
