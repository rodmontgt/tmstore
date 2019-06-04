//
//  FMASViewController.m
//
//  Created by Rishabh Jain on 04/04/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import "FMASViewController.h"
#import "AppUser.h"
@implementation FMASViewController

- (void)backButtonClicked:(id)sender{
    [self operationResult:false];
}
- (void)viewDidDisappear:(BOOL)animated {}
- (void)viewDidLoad {
    [super viewDidLoad];
    appdelegate =(AppDelegate*)[[UIApplication sharedApplication] delegate];

    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:
                                 [NSString stringWithFormat:@"< %@", Localize(@"i_back")] style:UIBarButtonItemStyleBordered target:
                                 self action:@selector(backButtonClicked:)];
    [self.navigationItem setLeftBarButtonItem:backButton];
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    self.view.backgroundColor = [UIColor whiteColor];
#if ENABLE_FMAS
    AppUser* appUser = [AppUser sharedManager];
    WrapperController *wrapperCntrller = [[WrapperController alloc] init];
    wrapperCntrller.FMASDelegate = self;
    appdelegate.FMASDismiss = true;
    [wrapperCntrller initInformationWithEmail:appUser._email withGender:@"Male" withOrganizationId:appUser._last_order_id withAge:24 withJSCallback:YES withNavigationController:self.navigationController];
#endif
}
-(void)viewWillAppear:(BOOL)animated{
    appdelegate =(AppDelegate*)[[UIApplication sharedApplication] delegate];
}
-(void)viewDidAppear:(BOOL)animated{
#if ENABLE_FMAS
    if (appdelegate.FMASDismiss) {
        appdelegate.FMASDismiss = false;
    }else{
        appdelegate.FMASDismiss = true;
        [self dismissViewControllerAnimated:YES completion:nil];
    }
#endif
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithDelegate:(id)delegate {
    self = [super init];
    if (self) {
    }
    return self;
}
-(void)didFailedWithError:(NSError *)error{
    [self operationResult:false];
}
-(void)didFinishWithSuccess:(BOOL)success withFootSize:(NSInteger)footSize{
    [self operationResult:true];
}
-(void)didFinishWithCancel{
    [self operationResult:false];
}
- (void)operationResult:(BOOL)success{
    if (success) {
        [self dismissViewControllerAnimated:YES completion:^{
//            [_responseDelegate postCompletionCallbackWithSuccess:nil];
            _responseDelegate = nil;
            [self dismissViewControllerAnimated:YES completion:^{
                //            [_responseDelegate postCompletionCallbackWithSuccess:nil];
                _responseDelegate = nil;
            }];
        }];
    } else {
        [self dismissViewControllerAnimated:YES completion:^{
//            [_responseDelegate postCompletionCallbackWithFailure:nil];
            _responseDelegate = nil;
            [self dismissViewControllerAnimated:YES completion:^{
                //            [_responseDelegate postCompletionCallbackWithSuccess:nil];
                _responseDelegate = nil;
            }];
        }];
    }
}
@end
