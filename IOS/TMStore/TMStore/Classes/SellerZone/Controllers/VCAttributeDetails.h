//
//  VCAttributeDetails.h
//  TMStore
//
//  Created by Rajshekhar on 25/07/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Attribute.h"

@interface VCAttributeDetails : UIViewController{
IBOutlet UIScrollView *_scrollView;
//        id <BarcodeScannerDelegate> _delegate;
id _delegate;
}
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UIView *lineView;
@property (weak, nonatomic) IBOutlet UINavigationItem *currentItemHeading;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *previousItemHeading;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barButtonRightHeading;

- (IBAction)barButtonBackPressed:(id)sender;
- (IBAction)barButtonCheckPressed:(id)sender;

@property UIImageView* topImage;
@property UIButton* btnProceed;
@property float defaultHeight;
@property NSString *attributeName;
@property UILabel* labelViewHeading;
- (void)setDelegate:(id)delegate;
@property SZAttribute* szAttribute;
- (void)setData:(SZAttribute*)szAttribute;
@end
