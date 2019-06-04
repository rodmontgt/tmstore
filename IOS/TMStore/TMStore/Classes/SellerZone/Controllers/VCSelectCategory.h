//
//  VCSelectCategory.h
//  TMStore
//
//  Created by Rajshekhar on 24/07/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CategoryInfo.h"

@interface VCSelectCategory : UIViewController{
IBOutlet UIScrollView *_scrollView;
//        id <BarcodeScannerDelegate> _delegate;
id _delegate;
}
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UIView *lineView;
@property (weak, nonatomic) IBOutlet UINavigationItem *currentItemHeading;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *previousItemHeading;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonDone;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, readonly) NSArray *searchResults;

- (IBAction)barButtonBackPressed:(id)sender;
@property UIImageView* topImage;
@property UIButton* btnProceed;
@property float defaultHeight;
@property NSString *categoryName;

@property UILabel* labelViewHeading;
- (void)setDelegate:(id)delegate;
@property BOOL checked;

- (void)setData:(id)categoryInfo;
@property CategoryInfo *categoryObject;

+ (void)dismissMe:(UIViewController*)vc isAnimated:(BOOL)isAnimated;
@end
