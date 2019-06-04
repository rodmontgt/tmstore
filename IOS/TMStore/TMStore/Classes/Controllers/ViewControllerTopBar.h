//
//  ViewControllerTopBar.h
//
//  Created by Rishabh Jain on 24/09/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Variables.h"

@interface ViewControllerTopBar : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *buttonBack;
@property (weak, nonatomic) IBOutlet UIButton *buttonLeftView;
@property (weak, nonatomic) IBOutlet UIButton *buttonRightView;
@property (weak, nonatomic) IBOutlet UILabel *labelHeader;
@property (weak, nonatomic) IBOutlet UIImageView *imageLogo;
@property (weak, nonatomic) IBOutlet UIButton *buttonHeader;

- (IBAction)btnClickedBack:(id)sender;
- (IBAction)btnClickedRightDrawer:(id)sender;
- (IBAction)btnClickedLeftDrawer:(id)sender;

@property UIView *lineView;

@property CGSize imgSizeFrameOriginal;
@property CGSize buttonSizeFrameOriginal;
- (void)redrawButtonRightView;
@end
