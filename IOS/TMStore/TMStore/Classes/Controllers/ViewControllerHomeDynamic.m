//
//  ViewControllerHomeDynamic.m
//
//  Created by Rishabh Jain on 18/04/17.
//  Copyright (c) 2017 Twist Mobile. All rights reserved.
//


#import "ViewControllerHomeDynamic.h"
#import "DLVariable.h"
#import "DLContent.h"
#import "DLFiller.h"
#import "DataManager.h"

@interface ViewControllerHomeDynamic () {
    IBOutlet UITableView *tableDynamic;
    BOOL isViewLoaded;
}
@end

@implementation ViewControllerHomeDynamic
#pragma mark - View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    isViewLoaded = false;
    

}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
//    for (UIView* vObj in [self.view subviews]) {
//        [vObj removeFromSuperview];
//    }

}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (isViewLoaded == false) {
        [self initView];
        isViewLoaded = true;
    }
    [self fetchContentProducts];

}
- (void)initView {
    DLManager* dlManager = [DLManager sharedManager];
    DLFiller* dlFiller = [DLFiller getInstance];
    [dlFiller fillWithData:dlManager.homeDLObjects scrollView:_scrollView delegate:self];
}

- (void)fetchContentProducts {
    DLFiller* dlFiller = [DLFiller getInstance];
    NSMutableArray* pids = [[NSMutableArray alloc] init];
    if (dlFiller.allVCorrousals) {
        for (UICollectionView* cvVertical in dlFiller.allVCorrousals) {
            if (cvVertical) {
                DLVariable* variable = [cvVertical.layer valueForKey:@"CV_DLVariable"];
                if (variable) {
                    NSMutableArray* products = [variable getContentProducts];
                    for (ProductInfo* pInfo in products) {
                        //if (pInfo._isFullRetrieved == false) {
                            [pids addObject:[NSNumber numberWithInt:pInfo._id]];
                        //}
                    }
                }
            }
        }
    }
    if ([pids count] > 0) {
        [[[DataManager sharedManager] tmDataDoctor] fetchMoreProductsDataFromPlugin:pids success:^{
            NSLog(@"fetchContentProducts: succeed");
            if (dlFiller.allVCorrousals) {
                for (UICollectionView* cvVertical in dlFiller.allVCorrousals) {
                    [cvVertical reloadData];
                }
            }
        } failure:^{
            NSLog(@"fetchContentProducts: failed");
        }];
    }
}

@end
