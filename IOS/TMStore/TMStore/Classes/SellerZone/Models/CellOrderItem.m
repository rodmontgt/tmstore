//
//  CellOrderItem.m
//  TMStore
//
//  Created by Rajshekhar on 19/07/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import "CellOrderItem.h"
#import "CellLineItem.h"
#import "Order.h"
#import "VCShowMore.h"

@implementation CellOrderItem

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


//#pragma mark - TableView-Delegates
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//
////    Order* order = [self.layer valueForKey:@"ORDER_OBJ"];
////    if (order) {
////        return [order._line_items count];
////    }
////	return 1;
//    return 1;
//
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return 150;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//
//    static NSString *simpleTableIdentifier = @"CellLineItem";
//
//    CellLineItem *cell = (CellLineItem *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
//
//    if (cell == nil)
//    {
//       cell = [[CellLineItem alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
//
//    }
//
//    Order* order = [self.layer valueForKey:@"ORDER_OBJ"];
//    if (order) {
//        LineItem* lItem =  [order._line_items objectAtIndex:indexPath.row];
//        NSLog(@"%@", lItem._name);
//        cell.labelProductName.text = lItem._name;
//
//    }
//
//
//    return cell;
//}
@end
