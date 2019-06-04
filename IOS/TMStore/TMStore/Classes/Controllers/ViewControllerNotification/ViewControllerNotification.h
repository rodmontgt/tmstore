//
//  ViewControllerNotification.h
//  TMStore
//
//  Created by Twist Mobile on 28/02/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <CoreData/CoreData.h>
#import "NotificationCell.h"

@interface ViewControllerNotification : UIViewController<UITableViewDelegate,UITableViewDataSource>{
    UIButton *customBackButton;
    AppDelegate *application;
    int cellHeight;
}
@property UILabel* labelViewHeading;
@property (weak, nonatomic) IBOutlet UINavigationItem *currentItemHeading;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *previousItemHeading;
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UIView *lineView;
@property (weak, nonatomic) IBOutlet UITableView *tableData;
@property (weak, nonatomic) IBOutlet UILabel *noNotificationFound;
@property (weak, nonatomic) IBOutlet UIView *viewKeepShoping;
@property (weak, nonatomic) IBOutlet UIButton *keepShoping;
@property (strong) NSMutableArray *devices;
//@property (strong,nonatomic)  NotificationCell *notificationCell;
@end
