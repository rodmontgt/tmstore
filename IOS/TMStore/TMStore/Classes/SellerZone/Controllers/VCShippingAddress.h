//
//  VCShippingAddress.h
//  TMStore
//
//  Created by Rajshekhar on 27/07/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Order.h"

@interface VCShippingAddress : UIViewController{
IBOutlet UIScrollView *_scrollView;
//        id <BarcodeScannerDelegate> _delegate;
id _delegate;
}
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UIView *lineView;
@property (weak, nonatomic) IBOutlet UINavigationItem *currentItemHeading;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *previousItemHeading;

- (IBAction)barButtonBackPressed:(id)sender;
@property UIImageView* topImage;
@property UIButton* btnProceed;
@property float defaultHeight;
@property UILabel* labelViewHeading;
@property (weak, nonatomic) IBOutlet UILabel *labelFirstName;
@property (weak, nonatomic) IBOutlet UILabel *labelLastName;
@property (weak, nonatomic) IBOutlet UILabel *labelCompanyName;
@property (weak, nonatomic) IBOutlet UILabel *labelCity;
@property (weak, nonatomic) IBOutlet UILabel *labelAddress1;
@property (weak, nonatomic) IBOutlet UILabel *labelAddress2;
@property (weak, nonatomic) IBOutlet UILabel *labelState;
@property (weak, nonatomic) IBOutlet UILabel *labelPostCode;
@property (weak, nonatomic) IBOutlet UILabel *labelCountry;

@property Order* selectedOrder;
- (void)setData:(Order*)order;
@end
