//
//  ViewControllerMyCoupon.h
//  TMStore
//
//  Created by Twist Mobile on 13/01/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "Coupon.h"

@interface ViewControllerMyCoupon : UIViewController<UITableViewDelegate,UITableViewDataSource,UICollectionViewDataSource, UICollectionViewDelegate>{
    UIButton *customBackButton;
    AppDelegate *application;
    Coupon *coupon;
}
@property UILabel* labelViewHeading;
@property (weak, nonatomic) IBOutlet UINavigationItem *currentItemHeading;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *previousItemHeading;
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UIView *lineView;
@property (weak, nonatomic) IBOutlet UITableView *tableData;
@property NSMutableArray *addindex;
@property (nonatomic, strong) NSArray *colorArray;
@property (nonatomic, strong) NSMutableDictionary *contentOffsetDictionary;
@property (nonatomic, strong) NSMutableArray *colllecationviewArray;
@property (strong, nonatomic) NSArray *sampleData;

@end
