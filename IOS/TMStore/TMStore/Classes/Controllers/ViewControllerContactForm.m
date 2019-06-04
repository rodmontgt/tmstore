//
//  ViewControllerContactForm.m
//  TMStore
//
//  Created by Rishabh Jain on 05/05/17.
//  Copyright (c) 2017 Twist Mobile. All rights reserved.
//

#import "ViewControllerContactForm.h"
#import "Utility.h"
#import "Variables.h"
#import "AnalyticsHelper.h"
#import "DataManager.h"
#import "ContactForm3Config.h"
#import "UITextView+LocalizeConstrint.h"
static int kTagForGlobalDoubleSpacing = 2;
static int kTagForGlobalSpacing = 1;
static int kTagForNoSpacing = -1;

enum TAGS_CONTACT_FORM {
    TAGS_CONTACT_FORM_TITLE,
    TAGS_CONTACT_FORM_NAME,
    TAGS_CONTACT_FORM_ADDRESS,
    TAGS_CONTACT_FORM_CONTACT,
    TAGS_CONTACT_FORM_EMAIL,
    TAGS_CONTACT_FORM_MESSAGE_TITLE,
    TAGS_CONTACT_FORM_MESSAGE
};


@interface ViewControllerContactForm () {
    NSMutableArray* _viewsAdded;
    UIButton *customBackButton;
    
    
    ContactForm3* objName;
    ContactForm3* objEmail;
    ContactForm3* objMessage;
}
@end
@implementation ViewControllerContactForm
#pragma mark Default Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [Utility getUIColor:kUIColorThemeFont], NSForegroundColorAttributeName, [Utility getUIFont:kUIFontType24 isBold:false], NSFontAttributeName, nil]];
    [self.currentItemHeading setTitle:@"   "];
    
    self.labelViewHeading = [[UILabel alloc] init] ;
    [self.labelViewHeading setFrame:CGRectMake(0, 20, [[MyDevice sharedManager] screenSize].width, self.navigationBar.frame.size.height)];
    [self.labelViewHeading setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self.labelViewHeading setUIFont:kUIFontType24 isBold:false];
    [self.labelViewHeading setTextColor:[Utility getUIColor:kUIColorThemeFont]];
    [self.labelViewHeading setTextAlignment:NSTextAlignmentCenter];
    [self.labelViewHeading setText:@"    "];
    [self.view addSubview:self.labelViewHeading];
    
    [self.navigationBar setClipsToBounds:false];
    [self.lineView setBackgroundColor:[Utility getUIColor:kUIColorBorder]];
    [_scrollView setBackgroundColor:[Utility getUIColor:kUIColorBgTheme]];
    [self.view setBackgroundColor:[Utility getUIColor:kUIColorBgHeader]];
    [self.navigationBar setBarTintColor:[Utility getUIColor:kUIColorBgHeader]];
    customBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [customBackButton setImage:[[UIImage imageNamed:@"img_arrow_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [customBackButton addTarget:self action:@selector(barButtonBackPressed:)forControlEvents:UIControlEventTouchUpInside];
    [customBackButton setTitle:[NSString stringWithFormat:@"  %@  ", Localize(@"i_back")] forState:UIControlStateNormal];
    [customBackButton setTintColor:[Utility getUIColor:kUIColorThemeFont]];
    [customBackButton setTitleColor:[Utility getUIColor:kUIColorThemeFont] forState:UIControlStateNormal];
    [customBackButton.titleLabel setUIFont:kUIFontType18 isBold:false];
    
    [customBackButton sizeToFit];
    [self.previousItemHeading setCustomView:customBackButton];
    [self.previousItemHeading setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[Utility getUIColor:kUIColorThemeFont], NSForegroundColorAttributeName, [Utility getUIFont:kUIFontType18 isBold:false], NSFontAttributeName, nil] forState:UIControlStateNormal];
    
    [self initVariables];
    [self loadAllViews];
}
- (void)viewWillAppear:(BOOL)animated {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super viewWillAppear:animated];
#if ENABLE_FIREBASE_TAG_MANAGER
    [[AnalyticsHelper sharedInstance] registerVisitScreenEvent:@"Contact Us Form"];
#endif
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}
- (void)viewWillDisappear:(BOOL)animated {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark - Adjust Orientation
- (void)saveTempVariables {
    tempEmail = textFieldEmail.text;
    tempMessage = textViewMessage.text;
    tempName = textFieldName.text;
}
- (void)beforeRotation {
    [self saveTempVariables];
    UIView* lastView = [_viewsAdded lastObject];
    for(UIView *view in _viewsAdded)
    {
        [UIView animateWithDuration:0.1f animations:^{
            [view setAlpha:0.0f];
        }completion:^(BOOL finished){
            [view removeFromSuperview];
            if (view == lastView) {
                [_scrollView setAlpha:0.0f];
                [_viewsAdded removeAllObjects];
                [self loadAllViews];
                for(UIView *vieww in _viewsAdded)
                {
                    [vieww setAlpha:0.0f];
                }
                [_scrollView setAlpha:1.0f];
            }
        }];
    }
}
- (void)afterRotation {
    for(UIView *vieww in _viewsAdded)
    {
        [UIView animateWithDuration:0.1f animations:^{
            [vieww setAlpha:1.0f];
        }completion:^(BOOL finished){
            
        }];
    }
}
- (void)adjustViewsForOrientation:(UIDeviceOrientation) orientation {
    RLOG(@"====adjustViewsForOrientation====");
    [self beforeRotation];
}
- (void)adjustViewsAfterOrientation:(UIDeviceOrientation) orientation {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    RLOG(@"====adjustViewsAfterOrientation====");
    [self afterRotation];
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    if ([[AppDelegate getInstance] isAppEnteredInBackground]) {
        return;
    }
    [self adjustViewsAfterOrientation:[[UIDevice currentDevice] orientation]];
    [self resetMainScrollView];
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if ([[AppDelegate getInstance] isAppEnteredInBackground]) {
        return;
    }
    [self adjustViewsForOrientation:[[UIDevice currentDevice] orientation]];
    [self resetMainScrollView];
}
- (void)resetMainScrollView {
    float globalPosY = 0.0f;
    UIView* tempView = nil;
    int i = 0;
    for (tempView in _viewsAdded) {
        CGRect rect = [tempView frame];
        if (i == 0) {
            globalPosY = 20;
        }
        rect.origin.y = globalPosY;
        
        [tempView setFrame:rect];
        globalPosY += rect.size.height;
        
        if ([tempView tag] == kTagForGlobalSpacing) {
            globalPosY += 20;//[LayoutProperties globalVerticalMargin];
        }
        if ([tempView tag] == kTagForGlobalDoubleSpacing) {
            globalPosY += 40;//[LayoutProperties globalVerticalMargin];
        }
        i++;
    }
    [_scrollView setContentSize:CGSizeMake(_scrollView.contentSize.width, globalPosY)];
}
#pragma mark - Create & Manage View
- (void)initVariables {
    objEmail = nil;
    objName = nil;
    objMessage = nil;
    
    tempEmail = @"";
    tempMessage = @"";
    tempName = @"";
    
    _viewsAdded = [[NSMutableArray alloc] init];
    [self.labelViewHeading setText:Localize(@"title_contact_us")];
}
- (void)loadAllViews {
    for (UIView* view in _viewsAdded) {
        [view removeFromSuperview];
    }
    [_viewsAdded removeAllObjects];
    
    if ([[ContactForm3Config getInstance] isDataFetched]) {
        [self createView];
        [self loadDataInView];
    } else {
        [self fetchData];
    }
    [self resetMainScrollView];
}
- (void)createView {
    ContactForm3Config* config = [ContactForm3Config getInstance];
    objEmail = [config getContactForm3_Email];
    objName = [config getContactForm3_Name];
    objMessage = [config getContactForm3_Message];
    
    NSString* placeholderName = objName.label;
    placeholderName = [NSString stringWithFormat:@"*%@", placeholderName];
    NSString* placeholderEmail = objEmail.label;
    placeholderEmail = [NSString stringWithFormat:@"*%@", placeholderEmail];
    NSString* placeholderMessage = objMessage.label;
    placeholderMessage = [NSString stringWithFormat:@"*%@", placeholderMessage];
    NSString* submitButtonTitle = [config submit_button_title];
    
    float posX = self.view.frame.size.width * .02f;
    float posY = self.view.frame.size.width * .04f;
    float width = self.view.frame.size.width * .96f;
    float height = 50;
    int fontType;
    fontType = kUIFontType18;
    
    NSString* mandatorySymbol = @"";
    textFieldName = [self createTextField:_scrollView fontType:fontType fontColorType:kUIColorFontLight frame:CGRectMake(posX, posY, width, height) tag:TAGS_CONTACT_FORM_NAME textStrPlaceHolder:[NSString stringWithFormat:@"%@%@", mandatorySymbol, placeholderName]];
    [_viewsAdded addObject:textFieldName];
    [textFieldName setTag:kTagForGlobalSpacing];
    posY = CGRectGetMaxY(textFieldName.frame) + height;
    
    textFieldEmail = [self createTextField:_scrollView fontType:fontType fontColorType:kUIColorFontLight frame:CGRectMake(posX, posY, width, height) tag:TAGS_CONTACT_FORM_EMAIL textStrPlaceHolder:[NSString stringWithFormat:@"%@%@", mandatorySymbol, placeholderEmail]];
    [_viewsAdded addObject:textFieldEmail];
    [textFieldEmail setTag:kTagForGlobalDoubleSpacing];
    posY = CGRectGetMaxY(textFieldEmail.frame) + height;
    
    UILabel* labelTextViewTitle = [[UILabel alloc] initWithFrame:CGRectMake(posX + 10, posY, width - 10, height)];
    [labelTextViewTitle setUIFont:fontType isBold:false];
    [labelTextViewTitle setTextColor:[Utility getUIColor:kUIColorFontLight]];
    [labelTextViewTitle setText:placeholderMessage];
    [labelTextViewTitle setNumberOfLines:0];
    [labelTextViewTitle setLineBreakMode:NSLineBreakByWordWrapping];
    [labelTextViewTitle sizeToFitUI];
//    float stringH = labelTextViewTitle.frame.size.height;
//    [labelTextViewTitle setFrame:CGRectMake(posX + 10, posY, width - 10, MAX(height, labelTextViewTitle.frame.size.height))];
//    float difference = labelTextViewTitle.frame.size.height - stringH;

    [_scrollView addSubview:labelTextViewTitle];
    [_viewsAdded addObject:labelTextViewTitle];
    [labelTextViewTitle setTag:kTagForNoSpacing];
    posY = CGRectGetMaxY(labelTextViewTitle.frame) + height;
//    labelTextViewTitle.layer.borderWidth = 1;
    textViewMessage = nil;
    textViewMessage = [self createTextView:_scrollView fontType:fontType fontColorType:kUIColorFontDark frame:CGRectMake(posX, posY, width, height * 5) tag:TAGS_CONTACT_FORM_MESSAGE textStrPlaceHolder:placeholderMessage textView:textViewMessage];
    [textViewMessage setKeyboardType:UIKeyboardTypeDefault];
    [textViewMessage setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [_viewsAdded addObject:textViewMessage];
    [textViewMessage setTag:kTagForGlobalSpacing];
    posY = CGRectGetMaxY(textViewMessage.frame) + height;
    
    float buttonWidth = [[MyDevice sharedManager] screenWidthInPortrait] * 0.6f;
    float buttonHeight = [[MyDevice sharedManager] screenHeightInPortrait] * .075f;
    float buttonPosX = (self.view.frame.size.width - buttonWidth) / 2;
    UIButton* btnProceed = [[UIButton alloc] initWithFrame:CGRectMake(buttonPosX, posY, buttonWidth, buttonHeight)];
    [btnProceed setBackgroundColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
    [[btnProceed titleLabel] setUIFont:kUIFontType22 isBold:false];
    [btnProceed setTitle:submitButtonTitle forState:UIControlStateNormal];
    [btnProceed setTitleColor:[Utility getUIColor:kUIColorBuyButtonFont] forState:UIControlStateNormal];
    [btnProceed addTarget:self action:@selector(submit:) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:btnProceed];
    [_viewsAdded addObject:btnProceed];
    [btnProceed setTag:kTagForGlobalSpacing];
}
- (void)loadDataInView {
    if (![tempName isEqualToString:@""]) {
        textFieldName.text = tempName;
    }
    if (![tempEmail isEqualToString:@""]) {
        textFieldEmail.text = tempEmail;
    }
    if (![tempMessage isEqualToString:@""]) {
        textViewMessage.text = tempMessage;
    }
}
#pragma mark - UITextField Methods & Delegate Responses
- (UITextField*)createTextField:(UIView*)parentView fontType:(int)fontType fontColorType:(int)fontColorType frame:(CGRect)frame tag:(int)tag textStrPlaceHolder:(NSString*)textStrPlaceHolder {
    if (CGRectEqualToRect(frame, CGRectMake(0, 0, 0, 0))) {
        frame = parentView.frame;
    }
    UITextField *textField = [[UITextField alloc] initWithFrame:frame];
    textField.placeholder = textStrPlaceHolder;
    textField.backgroundColor = [UIColor clearColor];
    textField.textColor = [Utility getUIColor:fontColorType];
    if ([[MyDevice sharedManager] isIphone]) {
        fontType--;
    }
    textField.borderStyle = UITextBorderStyleNone;
    textField.layer.borderWidth = 0;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.returnKeyType = UIReturnKeyDone;
    textField.textAlignment = NSTextAlignmentLeft;
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
    textField.tag = tag;
    textField.delegate = self;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [textField setUIFont:fontType isBold:false];
    [parentView addSubview:textField];
    UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, textField.frame.size.height - 1, textField.frame.size.width - 5.0f, 1.0f);
    bottomBorder.backgroundColor = [[Utility sharedManager] getTextFieldBorderColor].CGColor;
    [textField.layer setValue:bottomBorder forKey:@"BOTTOM_BORDER"];
    [textField.layer addSublayer:bottomBorder];
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        [textField setRightViewMode:UITextFieldViewModeAlways];
        [textField setRightView:spacerView];
    } else {
        [textField setLeftViewMode:UITextFieldViewModeAlways];
        [textField setLeftView:spacerView];
    }
    return textField;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    _textFieldFirstResponder = textField;
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [self setViewMovedUp:NO];
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
//    if (textField.tag == TAGS_CONTACT_FORM_CONTACT)
//    {
//        if(string.length > 0)
//        {
//            NSCharacterSet *numbersOnly = [NSCharacterSet characterSetWithCharactersInString:@"+0123456789"];
//            NSCharacterSet *characterSetFromTextField = [NSCharacterSet characterSetWithCharactersInString:string];
//            
//            BOOL stringIsValid = [numbersOnly isSupersetOfSet:characterSetFromTextField];
//            return stringIsValid;
//        }
//    }
    return YES;
}
-(void)cancelNumberPad:(UIBarButtonItem*)button {
    [self textFieldShouldReturn:_textFieldFirstResponder];
}
-(void)doneWithNumberPad:(UIBarButtonItem*)button {
    [self textFieldShouldReturn:_textFieldFirstResponder];
}
- (void)setViewMovedUp:(BOOL)movedUp {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    RLOG(@"setViewMovedUp:%d", movedUp);
    [UIView beginAnimations:nil context:NULL];
    if (movedUp == false) {
        [UIView setAnimationDuration:0.0f];
    } else {
        [UIView setAnimationDuration:_duration];
    }
    
    
    [UIView setAnimationCurve:_curve];
    CGRect rect = _scrollView.frame;
    if (movedUp) {
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        CGPoint p = [_textFieldFirstResponder convertPoint:_textFieldFirstResponder.center toView:window];
        float textViewPos = p.y;
        float windowViewHeight = [[MyDevice sharedManager] screenSize].height;
        float keyboardPos = windowViewHeight - _keyboardHeight;
        
        if (textViewPos > keyboardPos) {
            if ([[MyDevice sharedManager] isIphone]) {
                rect.origin.y = - MIN(_keyboardHeight, (textViewPos - keyboardPos));
                _scrollView.frame = rect;
            }
        }
    }
    else {
        if ([[MyDevice sharedManager] isIphone]) {
            rect.origin.y = 0;
            _scrollView.frame = rect;
            _scrollView.center = CGPointMake([[MyDevice sharedManager] screenSize].width/2, [[MyDevice sharedManager] screenSize].height/2);
        }
    }
    
    [UIView commitAnimations];
}
- (void)keyboardWillShow:(NSNotification *)notification {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    NSDictionary *info  = notification.userInfo;
    NSValue      *value = info[UIKeyboardFrameEndUserInfoKey];
    CGRect rawFrame      = [value CGRectValue];
    CGRect keyboardFrame = [self.view convertRect:rawFrame fromView:nil];
    RLOG(@"keyboardFrame: %@", NSStringFromCGRect(keyboardFrame));
    _keyboardHeight = keyboardFrame.size.height;
    _duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    _curve = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    // Animate the current view out of the way
    [self setViewMovedUp:YES];
}
- (void)keyboardWillHide {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [self setViewMovedUp:NO];
}
#pragma mark TextView
- (UITextView*)createTextView:(UIView*)parentView fontType:(int)fontType fontColorType:(int)fontColorType frame:(CGRect)frame tag:(int)tag textStrPlaceHolder:(NSString*)textStrPlaceHolder textView:(UITextView*)textView {
    if (CGRectEqualToRect(frame, CGRectMake(0, 0, 0, 0))) {
        frame = parentView.frame;
    }
    if (textView == nil) {
        textView = [[UITextView alloc] init];
    }
    textView.frame = frame;
    textView.backgroundColor = [UIColor clearColor];
    textView.textColor = [Utility getUIColor:fontColorType];
    if ([[MyDevice sharedManager] isIphone]) {
        fontType--;
    }
    textView.layer.borderWidth = 1;
    textView.layer.borderColor = [[Utility sharedManager] getTextFieldBorderColor].CGColor;
    textView.textAlignment = NSTextAlignmentLeft;
    textView.tag = tag;
    textView.delegate = self;
    [textView setUIFont:fontType isBold:false];
    [parentView addSubview:textView];
    [textView setTextContainerInset:UIEdgeInsetsMake(5, 5, 5, 5)];
    
    if ([[MyDevice sharedManager] isIphone]) {
        UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
        numberToolbar.backgroundColor = [UIColor lightGrayColor];
        UIBarButtonItem* doneBtn = [[UIBarButtonItem alloc]initWithTitle:Localize(@"done") style:UIBarButtonItemStyleBordered target:self action:@selector(doneWithNumberPadTextView:)];
        numberToolbar.items = @[
                                [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                doneBtn];
        [numberToolbar sizeToFit];
        textView.inputAccessoryView = numberToolbar;
    }
    return textView;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    _textViewFirstResponder = textView;
    return YES;
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    [self setViewMovedUp:NO];
    return YES;
}
- (void)textViewDidEndEditing:(UITextView *)textView {
    
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    return YES;
}
- (void)doneWithNumberPadTextView:(UIBarButtonItem*)button {
    [self textViewShouldEndEditing:_textViewFirstResponder];
    [_textViewFirstResponder resignFirstResponder];
}
#pragma mark - Fetch Data
- (void)fetchData {
    [Utility showProgressView:@""];
    if ([[ContactForm3Config getInstance] isDataFetched] == false) {
        [[[DataManager sharedManager] tmDataDoctor] getContactForm3InBackground:0 success:^(id data) {
            RLOG_DESC(@"data: %@", data);
            [Utility hideProgressView];
            [self createView];
            [self resetMainScrollView];
        } failure:^(NSString *error) {
            RLOG_DESC(@"error: %@", error);
            [Utility hideProgressView];
        }];
    } else {
        [Utility hideProgressView];
        [self createView];
        [self resetMainScrollView];
    }
}
#pragma mark - Events
- (IBAction)barButtonBackPressed:(id)sender {
    [[Utility sharedManager] popScreen:self];
    ViewControllerMain* mainVC = [ViewControllerMain getInstance];
    [mainVC resetPreviousState];
}
- (void)submit:(id)sender {
    if ([textFieldName.text isEqualToString:@""] ||
        [textFieldEmail.text isEqualToString:@""] ||
        [textViewMessage.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:Localize(@"i_field_compulsary") delegate:self cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if (![[Utility sharedManager] isValidEmailId:textFieldEmail.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:Localize(@"enter_valid_email") delegate:self cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    
    
    [Utility showProgressView:@""];
    [[[DataManager sharedManager] tmDataDoctor] postContactForm3InBackground:0 name:textFieldName.text email:textFieldEmail.text message:textViewMessage.text success:^(id data) {
        [Utility hideProgressView];
        RLOG_DESC(@"success:%@", data);
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Localize(@"i_success") message:data delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
        [alertView show];
        [self performSelector:@selector(dismissAlert:) withObject:alertView afterDelay:1.0f];
    } failure:^(NSString *error) {
        [Utility hideProgressView];
        RLOG_DESC(@"failure:%@", error);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Localize(@"sorry") message:error delegate:self cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil];
        [alert show];
    }];
}
-(void)dismissAlert:(UIAlertView *) alertView{
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
    [self barButtonBackPressed:nil];
}
@end
