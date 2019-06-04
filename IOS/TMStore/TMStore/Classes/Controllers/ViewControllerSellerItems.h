//
//  ViewControllerSellerItems.h
//  TMStore
//
//  Created by Rajshekhar on 19/07/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Variables.h"
#import "SellerInfo.h"
#import "LayoutProperties.h"
#import "ViewControllerProduct.h"

@interface ViewControllerSellerItems : UIViewController{
    IBOutlet UIScrollView *_scrollView;
    id _delegate;
}
@property (weak, nonatomic) IBOutlet UIView *ViewShowProfile;
@property (weak, nonatomic) IBOutlet UIView *viewbase;

@property (weak, nonatomic) IBOutlet UIImageView *imgProfile;

@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelShopName;
@property (weak, nonatomic) IBOutlet UILabel *labelPhoneNo;

@property (weak, nonatomic) IBOutlet UILabel *labelShopAddress;

@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UIView *lineView;
@property (weak, nonatomic) IBOutlet UINavigationItem *currentItemHeading;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *previousItemHeading;

- (IBAction)barButtonBackPressed:(id)sender;
@property UIImageView* topImage;
@property UIButton* btnProceed;
@property float defaultHeight;
@property UILabel* labelViewHeading;
- (void)setDelegate:(id)delegate;
@property SellerInfo* selectedSellerInfo;
- (void)setData:(SellerInfo*)sellerInfo;
- (void)setProductVC:(id)productVC parentVC:(id)parentVC;
@property UIActivityIndicatorView *spinnerView;
@property BOOL pageLoading;
@property LayoutProperties* propCollectionView;
@property NSString* strCollectionView1;

@property id parentVC;
@property id productVC;
@property id parentCell;


@end
