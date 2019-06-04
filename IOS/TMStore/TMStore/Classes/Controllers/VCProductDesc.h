//
//  VCProductDesc.h
//  eMobileApp
//
//  Created by Rishabh Jain on 16/11/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductInfo.h"
@interface VCProductDesc: UIViewController {
    IBOutlet UIScrollView *_scrollView;
}
- (void)resetMainScrollView;
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UIView *lineView;
@property (weak, nonatomic) IBOutlet UINavigationItem *currentItemHeading;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *previousItemHeading;
- (IBAction)barButtonBackPressed:(id)sender;
@property UILabel* labelViewHeading;
@property ProductInfo* productInfo;
- (void)setProductData:(ProductInfo*)pInfo;
@end
