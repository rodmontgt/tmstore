//
//  ViewControllerLogin.m
//  eMobileApp
//
//  Created by V S Khutal on 25/11/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import "ViewControllerLogin.h"
#import "Utility.h"
#import "Address.h"
#import "AppUser.h"


static int kTagForGlobalSpacing = 0;
static int kTagForNoSpacing = -1;

@interface ViewControllerLogin () <CNPPopupControllerDelegate> {
    
}
@property (nonatomic, strong) CNPPopupController *popupController;

@end


@implementation ViewControllerLogin

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.previousItemHeading setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[Utility getUIColor:kUIColorFontBackButton], NSForegroundColorAttributeName, [UIFont fontWithName:@"AlegreyaSans-Regular" size:18.0f], NSFontAttributeName, nil] forState:UIControlStateNormal];
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [Utility getUIColor:kUIColorFontTitle], NSForegroundColorAttributeName, [UIFont fontWithName:@"AlegreyaSans-Regular" size:24.0], NSFontAttributeName, nil]];
    [self initVariables];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [super viewWillAppear:animated];
    [self loadAllViews];
}
- (void)initVariables {
    self.view.backgroundColor = [UIColor whiteColor];
    _mainView.backgroundColor = [UIColor whiteColor];
    _scrollView.backgroundColor =[UIColor whiteColor];
    _scrollView.hidden = true;
}
- (void)loadAllViews {
    [_previousItemHeading setTitle:@"< Back"];
    [_currentItemHeading setTitle:@"LOGIN"];
    [self showPopup];
}
- (void)showPopup {
    [self createLoginPopup];
    [self fillDataInPopup];

    
    [self.popupController presentPopupControllerAnimated:YES parentView:_mainView];
    [_mainView bringSubviewToFront:_navigationBar] ;
}
- (void)createLoginPopup{
    if (self.popupController != nil) {
        return;
    }
    
    float widthView = [[MyDevice sharedManager] screenSize].width - [[MyDevice sharedManager] screenSize].width * 0.1f;
    float heightView = [[MyDevice sharedManager] screenSize].height - [[MyDevice sharedManager] screenSize].width * 0.1f;
    
    if ([[MyDevice sharedManager] isIpad]) {
        widthView = [[MyDevice sharedManager] screenSize].width * 0.65f;
        heightView = [[MyDevice sharedManager] screenSize].height * 0.63f;
    }else if ([[MyDevice sharedManager] isIphone]) {
        //        widthView = [[MyDevice sharedManager] screenSize].width * 0.65f;
        //        heightView = [[MyDevice sharedManager] screenSize].height *0.63f;
        //here we need full screen
    }
    
    UIView* viewMain = [[UIView alloc] initWithFrame:CGRectMake(0, 0, widthView, heightView)];
    viewMain.backgroundColor = [Utility getUIColor:kUIColorBgTheme];
    
    UIView* viewTop = [[UIView alloc] initWithFrame:CGRectMake(0, 0, widthView, heightView * 0.05f)];
    viewTop.backgroundColor = [Utility getUIColor:kUIColorBgHeader];
    [viewMain addSubview:viewTop];
    
    self.popupController = [[CNPPopupController alloc] initWithContents:@[viewMain]];
    self.popupController.theme = [CNPPopupTheme addressTheme];
    self.popupController.theme.popupStyle = CNPPopupStyleCentered;
    self.popupController.theme.size = CGSizeMake(widthView, heightView);
    self.popupController.theme.maxPopupWidth = widthView;
    self.popupController.delegate = self;
}
- (void)fillDataInPopup{}

- (UILabel*)createLabel:(UIView*)parentView fontName:(NSString*)fontName fontSize:(float)fontSize fontColorType:(int)fontColorType frame:(CGRect)frame textStr:(NSString*)textStr {
    UILabel* label = [[UILabel alloc] init];
    
    if ([fontName compare:@""] == NSOrderedSame) {
        fontName = @"AlegreyaSans-Regular";
    }
    if (CGRectEqualToRect(frame, CGRectMake(0, 0, 0, 0))) {
        frame = parentView.frame;
        
    }
    [label setFont:[UIFont fontWithName:fontName size:fontSize]];
    [label setTextColor:[Utility getUIColor:fontColorType]];
    [label setFrame:frame];
    [label setText:textStr];
    [parentView addSubview:label];
    return label;
}
- (UITextField*)createTextField:(UIView*)parentView fontName:(NSString*)fontName fontSize:(float)fontSize fontColorType:(int)fontColorType frame:(CGRect)frame tag:(int)tag textStrPlaceHolder:(NSString*)textStrPlaceHolder {
    if ([fontName compare:@""] == NSOrderedSame) {
        fontName = @"AlegreyaSans-Regular";
    }
    if (CGRectEqualToRect(frame, CGRectMake(0, 0, 0, 0))) {
        frame = parentView.frame;
    }
    UITextField *textField = [[UITextField alloc] initWithFrame:frame];
    textField.placeholder = textStrPlaceHolder;
    textField.backgroundColor = [UIColor clearColor];
    textField.textColor = [Utility getUIColor:fontColorType];
    textField.font = [UIFont fontWithName:fontName size:fontSize];
    textField.borderStyle = UITextBorderStyleNone;
    textField.layer.borderWidth = 0;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.returnKeyType = UIReturnKeyDone;
    textField.textAlignment = NSTextAlignmentLeft;
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
    textField.tag = tag;
    textField.delegate = self;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [parentView addSubview:textField];
    
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, textField.frame.size.height - 2, textField.frame.size.width - 5.0f, 2.0f);
    bottomBorder.backgroundColor = [Utility getUIColor:kUIColorBorder].CGColor;
    [textField.layer addSublayer:bottomBorder];
    
    return textField;
}
- (void)updateViews {
    
}
- (IBAction)barButtonBackPressed:(id)sender {
    [[Utility sharedManager] popScreen:self];
    ViewControllerMain* mainVC = [ViewControllerMain getInstance];
    [mainVC resetPreviousState];
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
- (void)showErrorAlert {
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"" message:@"Fields marked as ( * ) are mandatory." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [errorAlert show];
}
#pragma mark - CNPPopupController Delegate

- (void)popupController:(CNPPopupController *)controller didDismissWithButtonTitle:(NSString *)title {
    NSLog(@"Dismissed with button title: %@", title);
}

- (void)popupControllerDidPresent:(CNPPopupController *)controller {
    NSLog(@"Popup controller presented.");
}

@end
