//
//  ViewControllerSplashVendor.m
//  eCommerceApp
//
//  Created by Rishabh Jain on 16/09/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import "ViewControllerSplashVendor.h"
#import "SWRevealViewController.h"
#import "DataManager.h"
#import "ServerData.h"
#import "CommonInfo.h"
#import "ProductInfo.h"
#import "ProductImage.h"
#import "Attribute.h"
#import "CategoryInfo.h"
#import "Variation.h"
#import "Order.h"
#import "AppUser.h"
#import "ParseHelper.h"
#import "Vendor.h"
@interface ViewControllerSplashVendor()
@property ServerData* _tempServerData;
@property UIView* _tempView;
@end


@implementation ViewControllerSplashVendor

#pragma mark - View Life Cycle

- (void)viewDidLoad {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super viewDidLoad];
}
- (void)viewWillDisappear:(BOOL)animated {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super viewWillDisappear:animated];
}
- (void)viewDidDisappear:(BOOL)animated {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super viewDidDisappear:animated];
}
- (void)viewWillAppear:(BOOL)animated {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super viewWillAppear:animated];
    [SDWebImageManager.sharedManager.imageDownloader setValue:@"SDWebImage Demo" forHTTPHeaderField:@"AppName"];
    SDWebImageManager.sharedManager.imageDownloader.executionOrder = SDWebImageDownloaderLIFOExecutionOrder;
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(vendorDataSucceed:)
//                                                 name:@"VENDOR_DATA_SUCCESS"
//                                               object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(vendorDataFailed:)
//                                                 name:@"VENDOR_DATA_FAILED"
//                                               object:nil];
//    if ([[Addons sharedManager] enable_multi_vendor]) {
//        [[[DataManager sharedManager] tmDataDoctor] fetchVendorDataFromPlugin];
//    }
}
- (void)vendorDataSucceed:(NSNotification*)notification{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"VENDOR_DATA_SUCCESS" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"VENDOR_DATA_FAILED" object:nil];
    [self loadAllViews];
}
- (void)vendorDataFailed:(NSNotification*)notification{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"VENDOR_DATA_SUCCESS" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"VENDOR_DATA_FAILED" object:nil];
    [self goToNextViewController];
}
- (void)viewDidAppear:(BOOL)animated {
    
}
- (void)didReceiveMemoryWarning {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super didReceiveMemoryWarning];
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if([[MyDevice sharedManager] isIphone]){
        return UIInterfaceOrientationMaskPortrait;
    }
    return UIInterfaceOrientationMaskAll;
}

#pragma mark - Methods

- (void)goToNextViewController
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:STORYBOARD_NAME bundle:nil];
    UIViewController *rootViewController = [sb instantiateViewControllerWithIdentifier:VC_SPLASH_SECONDARY];
    [[UIApplication sharedApplication].keyWindow setRootViewController:rootViewController];
//    [_myTimer invalidate];
}
- (void)loadAllViews {
    UIView* view = [[UIView alloc] init];
    view.backgroundColor = [UIColor yellowColor];
    view.frame = self.view.frame;
    [self.view addSubview:view];
    NSMutableArray* arrayVendors = [Vendor getAllVendors];
    NSMutableArray* arrayLocations = [Vendor getVendorLocations];
    for (NSString* loc in arrayLocations) {
        NSMutableArray* arrayVendors = [Vendor getVendorsByLocation:loc];
    }
    [self goToNextViewController];
}
@end
