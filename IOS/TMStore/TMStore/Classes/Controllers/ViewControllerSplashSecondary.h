//
//  ViewControllerSplashSecondary.h
//  eCommerceApp
//
//  Created by Rishabh Jain on 16/09/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Variables.h"
#import "TMMulticastDelegate.h"
#import "ViewControllerSplashPrimary.h"
@interface ViewControllerSplashSecondary : UIViewController<UIAlertViewDelegate, TMMulticastDelegate>

- (void)startTimer;
- (void)fetchPrimaryData:(UIView *)_vview;
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
//@property (strong, nonatomic) IBOutlet UIImageView *imageBg;
//@property (strong, nonatomic) IBOutlet UIImageView *imageFg;
//@property (strong, nonatomic) IBOutlet UIView *view;
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (strong, nonatomic) IBOutlet UIImageView *imageBg;
@property (strong, nonatomic) IBOutlet UIImageView *imageFg;
@property (weak, nonatomic) IBOutlet UILabel *labelVersionInfo;
@property (weak, nonatomic) IBOutlet UILabel *labelPoweredBy;
@property (weak, nonatomic) IBOutlet UIImageView *imgSplash;


@property DemoCode* demoCodeObj;

@property UIAlertView *alertViewHomeDataFailed;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintImgLogoWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintImgLogoWidthFull;


@end

