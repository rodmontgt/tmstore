//
//  MenuOptions.h
//  GoogleMapsDemo
//
//  Created by Raj Shekar on 19/12/17.
//  Copyright © 2017 TwistMobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuOptions : UIView<UITableViewDelegate,UITableViewDataSource>
@property IBOutlet UITableView *tableOptions;

@property MenuOptions *menu;
@property NSMutableArray *arrayStoreTitle;
@property NSMutableArray *arrayStoreUrl;

@property id parentVC;

@end
