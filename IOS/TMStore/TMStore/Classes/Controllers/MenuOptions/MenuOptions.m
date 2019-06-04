//
//  MenuOptions.m
//  GoogleMapsDemo
//
//  Created by Raj Shekar on 19/12/17.
//  Copyright © 2017 TwistMobile. All rights reserved.
//

#import "MenuOptions.h"
//#import "AddressViewController.h"
#import "WebViewController.h"
#import "ViewControllerMain.h"
#import "ViewControllerWebview.h"
#import "Utility.h"
#import "StoreConfig.h"
#import "VCMyOrders.h"

#import "MapMenuOptions.h"

@implementation MenuOptions

- (void)awakeFromNib {
    [super awakeFromNib];
    _arrayStoreTitle = [[NSMutableArray alloc]init];
    _arrayStoreUrl = [[NSMutableArray alloc]init];

     [self loadViews];
}

- (void)loadViews{

    for (StoreConfig *sc in  [StoreConfig getAllMapMenuOptions]) {
        NSLog(@"======MenuOptions=======\nTitle:%@\nurl:%@\n", sc.title, sc.url);
        [_arrayStoreTitle addObject:sc.title];
        [_arrayStoreUrl addObject:sc.url];

    }


}
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _arrayStoreTitle.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
      cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: cellIdentifier];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@",[_arrayStoreTitle objectAtIndex:indexPath.row]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    WebViewController *wVC = [[WebViewController alloc]initWithNibName:@"WebViewController" bundle:nil];
    wVC.arrayUrl = _arrayStoreUrl[indexPath.row];
    wVC.arrayTitle = _arrayStoreTitle[indexPath.row];

    UIViewController *yourCurrentViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (yourCurrentViewController.presentedViewController)
    {
        yourCurrentViewController = yourCurrentViewController.presentedViewController;
    }
    [yourCurrentViewController presentViewController:wVC animated:YES completion:nil];

    //[self removeFromSuperview];
    //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:_arrayStoreUrl[indexPath.row]]];


}

@end
