//
//  ViewControllerSetting.h
//  TMStore
//
//  Created by Twist Mobile on 07/03/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "CNPPopupController.h"

@interface ViewControllerSetting : UIViewController<CNPPopupControllerDelegate,UITableViewDelegate,UITableViewDataSource>{
    UIButton *customBackButton;
    AppDelegate *application;
    NSMutableArray* viewsAdded;
}
@property UILabel* labelViewHeading;
@property (weak, nonatomic) IBOutlet UINavigationItem *currentItemHeading;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *previousItemHeading;
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UIView *lineView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property NSMutableArray* chkBoxLanguage;
@property NSMutableArray* chkBoxCurrency;

@property NSString* selectedLocale;
@property NSString* selectedLocaleTitle;
@property NSString* selectedCurrency;
@property (nonatomic,retain) UILabel* labelNotification;
@property (nonatomic, strong) CNPPopupController *popupControllerLanguage;
@property (nonatomic, strong) CNPPopupController *popupControllerCurrency;

@end
