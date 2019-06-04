//
//  ViewControllerSplashPrimary.h
//  eCommerceApp
//
//  Created by Rishabh Jain on 16/09/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Variables.h"
#import "NIDropDown.h"
#import "DataManager.h"

@interface DemoCode: NSObject <NSCoding>
@property int selectedDemoCodeId;
@property NSString* selectedDemoCode;
@property NSMutableArray* demoCodesArray;
@end

@interface ViewControllerSplashPrimary : UIViewController <UITextFieldDelegate,  NIDropDownDelegate>
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (strong, nonatomic) IBOutlet UIImageView *imageFg;
@property (strong, nonatomic) IBOutlet UILabel *labelPoweredBy;
@property (weak, nonatomic) IBOutlet UILabel *labelVersionInfo;
@property (weak, nonatomic) IBOutlet UIImageView *imgSplash;
@property NSMutableArray* chkBoxLanguage;
@property NSString* selectedLocale;
@property NSString* selectedLocaleTitle;


@property UIImageView *imageFgDemo;
-(void)startTimer;
@property NSTimer* myTimer;
@property UITextField *textFieldDemoKey;
@property UIButton* buttonDone;
@property float keyboardHeight;
@property double duration;
@property UIViewAnimationCurve curve;
@property NIDropDown* dropdownView;
@property NSMutableArray* dataObjects;

@property DemoCode* demoCodeObj;
@property BOOL launchedBySampleApp;



@property UIImageView* tImgLogo;
@property UIView* tViewCode;
@property UILabel* tLabelDesc;
@property UIButton* tBtnGetCode;
@property UIButton* tBtnSample;
@property DataManager* dm;



@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintImgLogoWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintImgLogoWidthFull;


@end
