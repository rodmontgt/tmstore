//
//  FrontViewController.m
//  eCommerceApp
//
//  Created by Rishabh Jain on 16/09/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import "FrontViewController.h"

@interface FrontViewController ()

@end


@implementation FrontViewController

#pragma mark - View Life Cycle

- (void)viewDidLoad {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super viewDidLoad];
}
- (void)viewWillAppear:(BOOL)animated {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super viewWillAppear:animated];
}
- (void)didReceiveMemoryWarning {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super didReceiveMemoryWarning];
}
//- (NSUInteger)supportedInterfaceOrientations
//{
//    //Forced Portrait mode
//    return UIInterfaceOrientationMaskPortrait;
//}

@end