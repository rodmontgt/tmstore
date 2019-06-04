//
//  VCSelectCategory.m
//  TMStore
//
//  Created by Rajshekhar on 24/07/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import "VCSelectCategory.h"
#import "Variables.h"
#import "Utility.h"
#import "AnalyticsHelper.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "CellCategoryDetails.h"
#import "SellerZoneManager.h"

@interface VCSelectCategory ()<UISearchDisplayDelegate,UISearchBarDelegate,UISearchResultsUpdating>{
    NSMutableArray* _viewsAdded;
    UIButton *customBackButton;
    IBOutlet UITableView *tableCategory;
    NSMutableArray *arrayCategories;
    NSMutableArray *searchResult;
    IBOutlet UISearchBar *searchBar;
    NSArray* categoryList;
    NSArray* categoryListSearch;
}
@property (nonatomic, strong) NSArray *tableData;

@end

@implementation VCSelectCategory

- (void)viewDidLoad {
    [super viewDidLoad];
    _checked = NO;
    
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [Utility getUIColor:kUIColorThemeFont], NSForegroundColorAttributeName, [Utility getUIFont:kUIFontType24 isBold:false], NSFontAttributeName, nil]];
    [self.currentItemHeading setTitle:_categoryName];
    
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
    [tableCategory registerNib:[UINib nibWithNibName:@"CellCategoryDetails" bundle:[NSBundle mainBundle]]
        forCellReuseIdentifier:@"CellCategoryDetails"];
    
    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"CellCategoryDetails" bundle:[NSBundle mainBundle]]forCellReuseIdentifier:@"CellCategoryDetails"];
    
    [self loadCateoryView];
}
- (void)loadCateoryView{
    
    categoryListSearch = categoryList;
    NSMutableArray* data = [[NSMutableArray alloc] init];
    for (CategoryInfo* ci in categoryListSearch) {
        [data addObject:ci._name];
    }
    self.tableData = data;
    searchResult = [NSMutableArray arrayWithCapacity:[self.tableData count]];
}

- (IBAction)barButtonBackPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
- (IBAction)barButtonDonePressed:(id)sender {
    [[[SellerZoneManager getInstance] tempProduct] szMoveCategoryIds];
    [VCSelectCategory dismissMe:self isAnimated:true];
}
+ (void)dismissMe:(UIViewController*)vc isAnimated:(BOOL)isAnimated {
    [vc dismissViewControllerAnimated:isAnimated completion:^{
        if([[Utility topMostController] isKindOfClass:[VCSelectCategory class]]){
            [VCSelectCategory dismissMe:[Utility topMostController] isAnimated:true];
        }
    }];
}
- (void)setData:(id)categoryInfo {
    self.categoryObject = categoryInfo;
    if (self.categoryObject == nil) {
        categoryList = [CategoryInfo getAllRootCategories];
    } else {
        categoryList = [self.categoryObject getSubCategories];
    }
    if (categoryList == nil) {
        categoryList = [[NSMutableArray alloc] init];
    }if (categoryList.count==0) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Oops!" message:@"No Categories for this Product" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}
#pragma mark - TableView-Delegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.searchDisplayController.searchResultsTableView){
        return [searchResult count];
    }else{
        return [self.tableData count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *simpleTableIdentifier = @"CellCategoryDetails";
    CellCategoryDetails *cell =nil;
    //CategoryInfo* cInfoTemp = [self.tableData objectAtIndex:indexPath.row];
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier forIndexPath:indexPath];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier forIndexPath:indexPath];
    }
    if (cell == nil){
        cell = [[CellCategoryDetails alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    CategoryInfo* ci = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView){
        cell.labelAttributeDetail.text = [searchResult objectAtIndex:indexPath.row];
        ci = [categoryListSearch objectAtIndex:indexPath.row];
    } else {
        cell.labelAttributeDetail.text = self.tableData[indexPath.row];
        ci = [categoryList objectAtIndex:indexPath.row];
    }
    cell.labelAttributeDetail.text = ci._name;
    [[cell labelAttributeDetail] setUIFont:kUIFontType16 isBold:false];
    if (ci) {
        if([[ci getSubCategories] count] > 0) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        [cell.buttonCheckMark.layer setValue:ci forKey:@"CATEGORY_OBJECT"];
        [cell initButtonCheckMark:cell.buttonCheckMark];
        [cell isButtonEnableForCategory:ci button:cell.buttonCheckMark];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    CategoryInfo* ci = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        ci = [categoryListSearch objectAtIndex:indexPath.row];
    } else {
        ci = [categoryList objectAtIndex:indexPath.row];
    }
    
    if([[ci getSubCategories] count] > 0) {
        VCSelectCategory *vcCategory=[[VCSelectCategory alloc] initWithNibName:@"VCSelectCategory" bundle:nil];
        // vcCategory.categoryName = arrayCategories[indexPath.row];
        vcCategory.categoryName = ci._name;
        [vcCategory setData:ci];
        [self presentViewController:vcCategory animated:YES completion:nil];
    }
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope{
    [searchResult removeAllObjects];
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", searchText];
    searchResult = [NSMutableArray arrayWithArray: [self.tableData filteredArrayUsingPredicate:resultPredicate]];
    int i = 0;
    NSMutableIndexSet *mutableIndexSet = [[NSMutableIndexSet alloc] init];
    for (NSString* str in self.tableData) {
        if ([searchResult containsObject:str]) {
            [mutableIndexSet addIndex:i];
        }
        i++;
    }
    categoryListSearch = [categoryList objectsAtIndexes:mutableIndexSet];
}
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString{
    [self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    [tableCategory reloadData];
    return YES;
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
