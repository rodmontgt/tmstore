//
//  ViewControllerSplashPrimary.m
//  eCommerceApp
//
//  Created by Rishabh Jain on 16/09/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import "ViewControllerSplashPrimary.h"
#import "Utility.h"
#import "ParseHelper.h"
#import "DataManager.h"
#import "AppDelegate.h"
#import "UIAlertView+NSCookbook.h"
#import "AnalyticsHelper.h"
#import "Variables.h"

#import "CNPPopupController.h"
@implementation DemoCode
- (id)init {
    self = [super init];
    if (self) {
        _selectedDemoCodeId = -1;
        _selectedDemoCode = @"";
        _demoCodesArray = [[NSMutableArray alloc] init];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        _selectedDemoCodeId = [decoder decodeIntForKey:@"#1"];
        _selectedDemoCode = [decoder decodeObjectForKey:@"#2"];
        _demoCodesArray = [decoder decodeObjectForKey:@"#3"];
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt:_selectedDemoCodeId forKey:@"#1"];
    [encoder encodeObject:_selectedDemoCode forKey:@"#2"];
    [encoder encodeObject:_demoCodesArray forKey:@"#3"];
}
@end

@interface ViewControllerSplashPrimary()<CNPPopupControllerDelegate>{
    NSMutableArray* _viewsAdded;
    
} @property (nonatomic, strong) CNPPopupController *popupController;
@end
@implementation ViewControllerSplashPrimary

#pragma mark - View Life Cycle

- (void)viewDidLoad {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super viewDidLoad];
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        self.view.transform = CGAffineTransformMakeScale(-1, 1);
    }
    _chkBoxLanguage = [[NSMutableArray alloc] init];
    
    _dm = [DataManager sharedManager];
    _launchedBySampleApp = false;
    [self startTimer];
    self.view.backgroundColor = [UIColor whiteColor];
    [_mainView setBackgroundColor:[UIColor whiteColor]];
    [_imageFg setUIImage:[Utility getSplashFgImage]];
    
    [_labelPoweredBy setText:@""];
    [_labelPoweredBy setUIFont:kUIFontType18 isBold:false];
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    NSString *versionStr = [NSString stringWithFormat:Localize(@"i_version_cmpny"), version, build];
    versionStr = @"";
    [_labelVersionInfo setText:versionStr];
    [_labelVersionInfo setUIFont:kUIFontType12 isBold:false];
    RLOG(@"Splash Primary Screen = %@", self);
    [Utility createCustomizedLoadingBar:Localize(@"i_loading_data") isBottomAlign:true isClearViewEnabled:true isShadowEnabled:true];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if ENABLE_FIREBASE_TAG_MANAGER
    [[AnalyticsHelper sharedInstance] registerVisitScreenEvent:@"SplashPrimary Screen"];
#endif
    [[Utility sharedManager] addShowAppInfoGesture:self];
}
//- (BOOL)ischeckNetworkConnection {
//    if (condition) {
//
//    } else {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"No Network" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Retry", nil];
//        [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
//            if ((int)buttonIndex == 0) {
//                //cancel
//            } else {
//                //retry
//            }
//        }];
//    }
//    return true;
//}

- (void)initView{
    RLOG(@"%s", __PRETTY_FUNCTION__);
    if (_dm.appType == APP_TYPE_DEMO) {
        if (FETCH_CUSTOM_OBJ(@"#0002")) {
            _demoCodeObj = (DemoCode*)FETCH_CUSTOM_OBJ(@"#0002");
        } else {
            _demoCodeObj = [[DemoCode alloc] init];
        }
        if (_dm.isAppForExternalUser) {
            if (_demoCodeObj.selectedDemoCodeId != -1) {
                _dm.merchantObjectId = _demoCodeObj.selectedDemoCode;
            }
        }
        
        _imageFgDemo = [[UIImageView alloc] init];
        UIImage* img = [Utility getSplashFgImage];
        [_imageFgDemo setUIImage:img];
        [_imageFgDemo setFrame:CGRectMake(0, 0, [[MyDevice sharedManager] screenWidthInPortrait] * .4f, [[MyDevice sharedManager] screenWidthInPortrait] * .4f)];
        
        
        
        [_mainView addSubview:_imageFgDemo];
        
        if (_dm.appType == APP_TYPE_DEMO) {
            _imageFg.hidden = true;
            [_imageFgDemo setHidden:false];
        } else {
#if (ENABLE_FULL_SPLASH_ON_LAUNCH == 0)
            _imageFg.hidden = false;
#endif
            [_imageFgDemo setHidden:true];
        }
    }
}
- (void)addViews {
    RLOG(@"start %s", __PRETTY_FUNCTION__);
    for (UIView*view in [self.view subviews]) {
        if (view == _mainView || view == _labelPoweredBy || view == _labelVersionInfo ||view == _imageFg || view == _imgSplash) {
        } else {
            [view removeFromSuperview];
        }
    }
    for (UIView*view in [_mainView subviews]) {
        if (view == _mainView || view == _labelPoweredBy || view == _labelVersionInfo ||view == _imageFg || view == _imgSplash || view == _imageFgDemo) {
        } else {
            [view removeFromSuperview];
        }
    }
    
    if (_dm.appType == APP_TYPE_DEMO) {
        int fontType;
        if ([[MyDevice sharedManager] isIpad]) {
            fontType = kUIFontType18;
        } else {
            fontType = kUIFontType18;
        }
        //        PRINT_RECT(self.view.frame);
        //        float height = [[MyDevice sharedManager] screenHeightInPortrait] * .05f;
        float height = [[Utility getUIFont:fontType isBold:false] lineHeight] * 2;
        float width = [[Utility getUIFont:fontType isBold:false] lineHeight] * 10;
        float posX = self.view.frame.size.width / 2 - width / 2;
        float posY = 0;
        _textFieldDemoKey = [[UITextField alloc] initWithFrame:CGRectMake(posX, posY, width, height)];
        _textFieldDemoKey.placeholder = Localize(@"prompt_demo_code");
        _textFieldDemoKey.backgroundColor = [UIColor clearColor];
        _textFieldDemoKey.textColor = [Utility getUIColor:kUIColorFontDark];
        [_textFieldDemoKey setUIFont:fontType isBold:false];
        _textFieldDemoKey.borderStyle = UITextBorderStyleLine;
        _textFieldDemoKey.layer.borderWidth = 1;
        _textFieldDemoKey.clearButtonMode = UITextFieldViewModeAlways;
        _textFieldDemoKey.returnKeyType = UIReturnKeyDone;
        _textFieldDemoKey.textAlignment = NSTextAlignmentLeft;
        _textFieldDemoKey.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _textFieldDemoKey.delegate = self;
        _textFieldDemoKey.autocapitalizationType = UITextAutocapitalizationTypeNone;
        UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        [_textFieldDemoKey setLeftViewMode:UITextFieldViewModeAlways];
        [_textFieldDemoKey setLeftView:spacerView];
        
        _buttonDone = [[UIButton alloc] initWithFrame:_textFieldDemoKey.frame];
        [_buttonDone setBackgroundColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
        [[_buttonDone titleLabel] setUIFont:kUIFontType20 isBold:false];
        [_buttonDone setTitle:Localize(@"enter") forState:UIControlStateNormal];
        [_buttonDone setTitleColor:[Utility getUIColor:kUIColorBuyButtonFont] forState:UIControlStateNormal];
        [_buttonDone addTarget:self action:@selector(checkOnParse:) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel* label = [[UILabel alloc] init];
        [label setUIFont:kUIFontType14 isBold:false];
        [label setText:Localize(@"i_enter_code_desc")];
        [label setTextColor:[Utility getUIColor:kUIColorFontDark]];
        [label setNumberOfLines:0];
        [label sizeToFitUI];
        [label setTextAlignment:NSTextAlignmentCenter];
        
        UILabel* label1 = [[UILabel alloc] init];
        [label1 setUIFont:kUIFontType18 isBold:false];
        [label1 setText:Localize(@"enter_app_code")];
        [label1 setTextColor:[Utility getUIColor:kUIColorFontDark]];
        [label1 sizeToFitUI];
        [label1 setTextAlignment:NSTextAlignmentLeft];
        
        UIButton* _buttonClick = [[UIButton alloc] initWithFrame:_textFieldDemoKey.frame];
        [_buttonClick setBackgroundColor:[UIColor clearColor]];
        [[_buttonClick titleLabel] setUIFont:kUIFontType18 isBold:false];
        UIColor *color = [Utility getUIColor:kUIColorThemeFont]; // select needed color
        NSString *string = Localize(@"demo_code_help_1"); // the string to colorize
        NSDictionary *attrs = @{ NSForegroundColorAttributeName : color , NSUnderlineStyleAttributeName :[NSNumber numberWithInteger:NSUnderlineStyleSingle]};
        NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:string attributes:attrs];
        [_buttonClick setAttributedTitle:attrStr forState:UIControlStateNormal];
        [_buttonClick addTarget:self action:@selector(getCodeBtnCallBack:) forControlEvents:UIControlEventTouchUpInside];
        
        
        
        
        float label1Height  = label1.frame.size.height;
        float labelHeight  = label.frame.size.height;
        float imgDemoHeight = _imageFgDemo.frame.size.height;
        float textFieldHeight = _textFieldDemoKey.frame.size.height;
        float buttonHeight = _buttonDone.frame.size.height;
        float gap = height * .4f;
        float totalViewHeight = self.view.frame.size.height;
        
        float pX = self.view.frame.size.width * 0.5f;
        float viewWidth = [[MyDevice sharedManager] screenWidthInPortrait] * 0.6f;
        
        if ([[MyDevice sharedManager] isIphone]) {
            viewWidth = [[MyDevice sharedManager] screenWidthInPortrait] * 0.96f;
            pX = [[MyDevice sharedManager] screenWidthInPortrait] * 0.51f;
        }
        
        
        
        [_mainView addSubview:label];
        [_mainView addSubview:_buttonClick];
        
        
#if OLD_ART_ENABLE
        float totalH = imgDemoHeight + gap + textFieldHeight + gap + buttonHeight + gap + labelHeight + buttonHeight;
        float newPosY = (totalViewHeight - totalH) / 2;
        [_mainView addSubview:_textFieldDemoKey];
        [_mainView addSubview:_buttonDone];
        
        newPosY += (imgDemoHeight/2);
        [_imageFgDemo setCenter:CGPointMake(self.view.frame.size.width/2, newPosY)];
        
        newPosY += (imgDemoHeight/2) + gap + (textFieldHeight/2);
        [_textFieldDemoKey setCenter:CGPointMake(self.view.frame.size.width/2, newPosY)];
        
        newPosY += (textFieldHeight/2) + gap + (buttonHeight/2);
        [_buttonDone setCenter:CGPointMake(self.view.frame.size.width/2, newPosY)];
        
        newPosY += (buttonHeight/2) + gap + (labelHeight/2);
        [label setCenter:CGPointMake(self.view.frame.size.width/2, newPosY)];
        
        newPosY += (labelHeight/2) + (buttonHeight/2);
        [_buttonClick setCenter:CGPointMake(self.view.frame.size.width/2, newPosY)];
#else
        float totalViewH = gap + label1Height + gap + textFieldHeight + gap;
        float totalH = imgDemoHeight + gap + totalViewH + gap + labelHeight + buttonHeight;
        float newPosY = (totalViewHeight - totalH) / 2;
        
        UIView* viewNew = [[UIView alloc] init];
        viewNew.backgroundColor = [UIColor whiteColor];
        [viewNew addSubview:label1];
        [viewNew addSubview:_textFieldDemoKey];
        [viewNew addSubview:_buttonDone];
        [_mainView addSubview:viewNew];
        viewNew.frame = CGRectMake(0, 0, viewWidth, totalViewH);
        //        [Utility showShadow:viewNew];
        
        UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:viewNew.bounds];
        viewNew.layer.masksToBounds = NO;
        viewNew.layer.shadowColor = [UIColor blackColor].CGColor;
        if ([[MyDevice sharedManager] isIpad]) {
            viewNew.layer.shadowOffset = CGSizeMake(0.0f, 2.4f);
            viewNew.layer.shadowOpacity = 0.4f;
            viewNew.layer.shadowRadius = 1.2f;
        }else{
            viewNew.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
            viewNew.layer.shadowOpacity = 0.4f;
            viewNew.layer.shadowRadius = 1.0f;
        }
        
        viewNew.layer.shadowPath = shadowPath.CGPath;
        
        
        _textFieldDemoKey.backgroundColor = [Utility colorWithHex:0xF1F1F1FF];
        
        UIView *topBorderView = [[UIView alloc] init];
        if ([[MyDevice sharedManager] isIpad]) {
            topBorderView.frame = CGRectMake(0.0f, 2.4f, viewNew.frame.size.width, 1.0f);
        }else{
            topBorderView.frame = CGRectMake(0.0f, 2.0f, viewNew.frame.size.width, 1.0f);
        }
        topBorderView.backgroundColor = [Utility getUIColor:kUIColorBorder];
        [viewNew addSubview:topBorderView];
        
        
        
        label1.frame = CGRectMake(viewWidth*.02f, 0, viewWidth*.98f, label1Height);
        
        _textFieldDemoKey.frame = CGRectMake(viewWidth*.025f, 0, viewWidth*.625f, textFieldHeight);
        _buttonDone.frame = CGRectMake(viewWidth*.675f, 0, viewWidth*.30f, textFieldHeight);
        
        
        _textFieldDemoKey.borderStyle = UITextBorderStyleNone;
        [_textFieldDemoKey.layer setBorderWidth:0];
        
        CALayer *bottomBorder = [CALayer layer];
        bottomBorder.frame = CGRectMake(0.0f, _textFieldDemoKey.frame.size.height - 1.0f, _textFieldDemoKey.frame.size.width, 1.0f);
        bottomBorder.backgroundColor = [Utility getUIColor:kUIColorThemeFont].CGColor;
        [_textFieldDemoKey.layer addSublayer:bottomBorder];
        
        
        [label1 setCenter:CGPointMake(label1.center.x, gap + label1Height/2)];
        [_textFieldDemoKey setCenter:CGPointMake(_textFieldDemoKey.center.x, gap + label1Height/2 + gap + textFieldHeight/2)];
        [_buttonDone setCenter:CGPointMake(_buttonDone.center.x, gap + label1Height/2 + gap + textFieldHeight/2)];
        
        
        
        
        newPosY += (imgDemoHeight/2);
        [_imageFgDemo setCenter:CGPointMake(pX, newPosY)];
        
        newPosY += (imgDemoHeight/2) + gap + (totalViewH/2);
        [viewNew setCenter:CGPointMake(pX, newPosY)];
        
        newPosY += (totalViewH/2) + gap + (labelHeight/2);
        [label setCenter:CGPointMake(pX, newPosY)];
        
        newPosY += (labelHeight/2) + (buttonHeight/2);
        [_buttonClick setCenter:CGPointMake(pX, newPosY)];
#endif
        
        UIButton* _buttonSampleApp = [[UIButton alloc] initWithFrame:_textFieldDemoKey.frame];
        [_buttonSampleApp setBackgroundColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
        [[_buttonSampleApp titleLabel] setUIFont:kUIFontType20 isBold:false];
        [_buttonSampleApp setTitle:Localize(@"launch_sample_app") forState:UIControlStateNormal];
        [_buttonSampleApp setTitleColor:[Utility getUIColor:kUIColorBuyButtonFont] forState:UIControlStateNormal];
        [_mainView addSubview:_buttonSampleApp];
        [_buttonSampleApp addTarget:self action:@selector(launchSampleApp:) forControlEvents:UIControlEventTouchUpInside];
        CGRect btnRect = CGRectMake(self.view.frame.size.width*.01f, self.view.frame.size.height - [[MyDevice sharedManager] screenHeightInPortrait]*.075f - self.view.frame.size.width*.02f , [[MyDevice sharedManager] screenWidthInPortrait]*.6f, [[MyDevice sharedManager] screenHeightInPortrait]* .075f);
        _buttonSampleApp.frame = btnRect;
        _buttonSampleApp.center = CGPointMake(pX, _buttonSampleApp.center.y);
        _labelPoweredBy.hidden = true;
        _labelVersionInfo.hidden = true;
        _dropdownView = nil;
        _tBtnSample = _buttonSampleApp;
        _tBtnGetCode = _buttonClick;
        _tLabelDesc = label;
        _tViewCode = viewNew;
        _tImgLogo = _imageFgDemo;
        if (_dm.isAppForExternalUser == false) {
            [self createDropDownView];
        }else{
            _textFieldDemoKey.secureTextEntry = false;
            _textFieldDemoKey.text = _demoCodeObj.selectedDemoCode;
        }
    }
    else {
        [Utility createCustomizedLoadingBar:Localize(@"i_loading_data") isBottomAlign:true isClearViewEnabled:true isShadowEnabled:true];
        [self performSelector:@selector(callCheckDataLoaded) withObject:nil afterDelay:0.5f];
    }
    RLOG(@"end %s", __PRETTY_FUNCTION__);
}

- (void)callCheckDataLoaded {
    [[ParseHelper sharedManager] checkDataLoaded];
}
- (void)createDropDownView{
    RLOG(@"%s", __PRETTY_FUNCTION__);
    if (_dropdownView) {
        [_dropdownView removeFromSuperview];
    }
    float height = [[MyDevice sharedManager] screenHeightInPortrait] * .30f;
    
    NSArray* reversedArray = [[_demoCodeObj.demoCodesArray reverseObjectEnumerator] allObjects];
    _dropdownView = [[NIDropDown alloc] initTextField:_textFieldDemoKey viewheight:height strArr:reversedArray  imgArr:nil direction:NIDropDownDirectionDown pView:self.view];
    _dropdownView.delegate = self;
    
    if (_demoCodeObj.selectedDemoCodeId != -1) {
        _textFieldDemoKey.text = _demoCodeObj.selectedDemoCode;
    }
}
- (void)reponseDropDownDelegate:(NIDropDown *)sender clickedItemId:(int)clickedItemId{
    RLOG(@"%s", __PRETTY_FUNCTION__);
    RLOG(@"clickedItemId = %d", clickedItemId);
    NSArray* reversedArray = [[_demoCodeObj.demoCodesArray reverseObjectEnumerator] allObjects];
    NSString* strValue = [reversedArray objectAtIndex:clickedItemId];
    _textFieldDemoKey.text = strValue;
    [_dropdownView setDropDownViewVisible:true];
    [_dropdownView toggleTextField:_textFieldDemoKey];
    [_textFieldDemoKey resignFirstResponder];
}
- (void)loadDataInView{
    RLOG(@"%s", __PRETTY_FUNCTION__);
}
- (void)launchSampleApp:(UIButton*)sender {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    _launchedBySampleApp = true;
    _textFieldDemoKey.secureTextEntry = true;
    _textFieldDemoKey.text = SAMPLE_APP_CODE;
    
    [self checkOnParse:nil];
}
- (void)getCodeBtnCallBack:(UIButton*)sender {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [[Utility sharedManager] pushScreenWithNewAnimation:self type:PUSH_SCREEN_TYPE_GETCODE];
    
    
    //    UIStoryboard *sb = [Utility getStoryBoardObject];
    //    UIViewController *rootViewController = [sb instantiateViewControllerWithIdentifier:VC_GETCODE];
    ////    [[UIApplication sharedApplication].keyWindow setRootViewController:rootViewController];
    //    [[Utility sharedManager] pushProductScreen:(UIViewController *)]
    
}
- (void)checkOnParse:(UIButton*)sender {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    if (![_textFieldDemoKey.text isEqualToString:@""]) {
        [Utility createCustomizedLoadingBar:Localize(@"i_loading_data") isBottomAlign:true isClearViewEnabled:true isShadowEnabled:true];
        //        [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
        //        MRProgressOverlayView *overlayView = [MRProgressOverlayView showOverlayAddedTo:[[UIApplication sharedApplication] keyWindow] title:@"" mode:MRProgressOverlayViewModeIndeterminateSmall animated:NO];
        //        overlayView.isMannualPositionEnable = true;
        //        overlayView.mannualBound = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height * 2);
        //        overlayView.mannualPosition = CGPointMake(self.view.frame.size.width * 0.5f, self.view.frame.size.height * 0.85f);
        _dm.merchantObjectId = _textFieldDemoKey.text;
        [self performSelector:@selector(callCheckDataLoaded) withObject:nil afterDelay:1.0f];
    }
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    if (textField == _textFieldDemoKey)
    {
        BOOL isStringExists = false;
        if ([_textFieldDemoKey.text isEqualToString:@""]) {
            isStringExists = true;
        }
        for (NSString* obj in _demoCodeObj.demoCodesArray) {
            if ([obj isEqualToString:_textFieldDemoKey.text]) {
                isStringExists = true;
                break;
            }
        }
        if (isStringExists == false) {
            [_demoCodeObj.demoCodesArray addObject:_textFieldDemoKey.text];
            _demoCodeObj.selectedDemoCode = _textFieldDemoKey.text;
            _demoCodeObj.selectedDemoCodeId = (int)[_demoCodeObj.demoCodesArray count] - 1;
            if (_dropdownView){
                [self createDropDownView];
            }
        }
    }
    if (_dropdownView && [_dropdownView isDropDownViewVisible] ==  true) {
        [_dropdownView toggleTextField:_textFieldDemoKey];
    }
    
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [textField resignFirstResponder];
    return YES;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    if (_dropdownView && [_dropdownView isDropDownViewVisible] ==  false) {
        [_dropdownView toggleTextField:_textFieldDemoKey];
    }
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)sender {
    RLOG(@"%s", __PRETTY_FUNCTION__);
}
- (void)textDidChange:(NSNotification*)notification {
    RLOG(@"%s", __PRETTY_FUNCTION__);
}
- (void)viewDidDisappear:(BOOL)animated {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super viewDidDisappear:animated];
}
- (void)viewWillAppear:(BOOL)animated {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super viewWillAppear:animated];
#if SUPPORT_PORTRAIT_ORIENTATION_ONLY
    [UIViewController attemptRotationToDeviceOrientation];
#endif
    //rv//[SDWebImageManager.sharedManager.imageDownloader setValue:@"SDWebImage Demo" forHTTPHeaderField:@"AppName"];
//    SDWebImageManager.sharedManager.imageDownloader.executionOrder = SDWebImageDownloaderFIFOExecutionOrder;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textDidChange:)
                                                 name: UITextFieldTextDidChangeNotification
                                               object:nil];
    
    [self initView];
    [self addViews];
    
    NSString* strSplashUrlPath = @"";
    if ([[MyDevice sharedManager] isIphone]) {
        strSplashUrlPath = _dm.splashUrlImgPathPortrait;
    }
    else {
        if ([[MyDevice sharedManager] isPortrait]) {
            strSplashUrlPath = _dm.splashUrlImgPathPortrait;
        }
        else {
            strSplashUrlPath = _dm.splashUrlImgPathLandscape;
        }
    }
    
#if ENABLE_FULL_SPLASH_ON_LAUNCH
    strSplashUrlPath = @"";
    [_constraintImgLogoWidth setPriority:999];
    [_constraintImgLogoWidthFull setPriority:1000];
    [_imageFg setContentMode:UIViewContentModeScaleToFill];
    [self.view setNeedsUpdateConstraints];
#endif
    
#if ENABLE_FULL_SPLASH_ON_LAUNCH_NEW
    [_imgSplash setImage:[UIImage imageNamed:strSplashUrlPath]];
    _imageFg.hidden = true;
    [_labelPoweredBy setTextColor:_dm.splashTextColor];
    [_labelVersionInfo setTextColor:_dm.splashTextColor];
#else
    if ([strSplashUrlPath isEqualToString:@""] == false) {
        [_imgSplash sd_setImageWithURL:[NSURL URLWithString:strSplashUrlPath] placeholderImage:nil options:[Utility getImageDownloadOption] progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
#if (ENABLE_FULL_SPLASH_ON_LAUNCH == 0)
            _imageFg.hidden = false;
#endif
            
            [_labelPoweredBy setTextColor:[Utility getUIColor:kUIColorFontDark]];
            [_labelVersionInfo setTextColor:[Utility getUIColor:kUIColorFontDark]];
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            _imageFg.hidden = true;
            [_labelPoweredBy setTextColor:_dm.splashTextColor];
            [_labelVersionInfo setTextColor:_dm.splashTextColor];
            [_imgSplash setUIImage:image];
        }];
    } else {
        [_labelPoweredBy setTextColor:[Utility getUIColor:kUIColorFontDark]];
        [_labelVersionInfo setTextColor:[Utility getUIColor:kUIColorFontDark]];
    }
#endif
}
- (void)didReceiveMemoryWarning {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super didReceiveMemoryWarning];
}


#pragma mark - Methods
- (void)goToNextViewController:(float)dt {
    RLOG(@"%s", __PRETTY_FUNCTION__);
//    PRINT_RECT_STR(@"goToNextViewControllerSSP1", self.view.frame);
//    PRINT_RECT_STR(@"goToNextViewControllerSSP2", self.mainView.frame);
    
    
    if ([[ParseHelper sharedManager] isParseDataLoaded]) {
        
        
        if (_dm.show_tmstore_text) {
            [_labelPoweredBy setText:Localize(@"powered_by_tm_store")];
        } else {
            [_labelPoweredBy setText:@""];
        }
        
        if (_dm.appType == APP_TYPE_DEMO) {
            int i = 0;
            for (NSString* democ in _demoCodeObj.demoCodesArray) {
                if ([democ isEqualToString:_textFieldDemoKey.text]) {
                    _demoCodeObj.selectedDemoCodeId = i;
                    _demoCodeObj.selectedDemoCode = democ;
                    break;
                }
                i++;
            }
            if (_launchedBySampleApp == false) {
                SAVE_CUSTOM_OBJ(_demoCodeObj, @"#0002");
            }
            [self gotonextscreen];
        }else{
            if ([[TMLanguage sharedManager] isUserLanguageSet]) {
                [self gotonextscreen];
            } else {
                [_myTimer invalidate];
                [self showLanguageSelectionScreen];
            }
        }
    }
    else if([[ParseHelper sharedManager] isParseDataLoaded] == false && [[ParseHelper sharedManager] isParseDataLoadedWithError]) {
        if ([[DataManager sharedManager] isUpdateInfoLoaded]) {
            
        } else {
            [self callCheckDataLoaded];
        }
    } else {
        
    }
}
- (void)languageSelectedDone:(id)sender {
    [[NSUserDefaults standardUserDefaults] setValue:_selectedLocale forKey:USER_LOCALE];
    int tempCounter = 0;
    Addons* addons = [Addons sharedManager];
    for (NSString* tempLocale in addons.language.locales) {
        if ([[tempLocale lowercaseString] isEqualToString:[_selectedLocale lowercaseString]]) {
            _selectedLocaleTitle = addons.language.titles[tempCounter];
            break;
        }
        tempCounter++;
    }
    [[NSUserDefaults standardUserDefaults] setValue:_selectedLocaleTitle forKey:USER_LOCAL_TITLE];
    [[TMLanguage sharedManager] refreshLanguage];
    [Utility changeInputLanguage:_selectedLocale];
    
    
    [self.popupController dismissPopupControllerAnimated:YES];
    [self gotonextscreen];
}
- (void)chkBoxLanguageClicked:(id)sender {
    UIButton* senderButton = (UIButton*)sender;
    [senderButton setSelected:YES];
    for (UIButton* button in _chkBoxLanguage) {
        if(button != senderButton){
            [button setSelected:NO];
        }
    }
    if ([senderButton isSelected]) {
        _selectedLocale = [senderButton.layer valueForKey:@"MY_LOCALE"];
        _selectedLocaleTitle = [senderButton.layer valueForKey:@"MY_LOCALE_TITLE"];
        
        [[ParseHelper sharedManager] downloadLanguageFileInBg:_selectedLocale];
    }
    
//    if ([senderButton isSelected]) {
//        _selectedLocale = [senderButton.layer valueForKey:@"MY_LOCALE"];
//        [[ParseHelper sharedManager] downloadLanguageFileInBg:_selectedLocale];
//    }
}
- (void)showLanguageSelectionScreen {
    
    Addons* addons = [Addons sharedManager];
    if(addons.language && addons.language.titles && [addons.language.titles count] > 0) {
        if ([addons.language.titles count] == 1) {
            return;
        }
    } else {
        return;
    }
    
    float widthView = [[MyDevice sharedManager] screenSize].width - [[MyDevice sharedManager] screenSize].width * 0.1f;
    float heightView = [[MyDevice sharedManager] screenSize].height - [[MyDevice sharedManager] screenSize].width * 0.1f;
    
    if ([[MyDevice sharedManager] isIpad]) {
        widthView = [[MyDevice sharedManager] screenWidthInPortrait] * 0.65f;
        heightView = [[MyDevice sharedManager] screenHeightInPortrait] * 0.63f;
        
    }else if ([[MyDevice sharedManager] isIphone]) {
        widthView = [[MyDevice sharedManager] screenSize].width * 0.96f;
        heightView = [[MyDevice sharedManager] screenSize].height * 0.70f;
    }
    
    UIView* viewMain = [[UIView alloc] initWithFrame:CGRectMake(0, 0, widthView, heightView)];
    viewMain.backgroundColor = [Utility getUIColor:kUIColorBgTheme];
    //    _mainViewRegister = viewMain;
    
    UIView* viewTop = [[UIView alloc] initWithFrame:CGRectMake(0, 0, widthView, heightView * 0.05f)];
    viewTop.backgroundColor = [UIColor whiteColor];
    //    viewMain.backgroundColor = [Utility getUIColor:kUIColorBgTheme];
    [viewMain addSubview:viewTop];
    
    
    
    self.popupController = [[CNPPopupController alloc] initWithContents:@[viewMain]];
    self.popupController.theme = [CNPPopupTheme addressTheme];
    self.popupController.theme.popupStyle = CNPPopupStyleCentered;
    self.popupController.theme.size = CGSizeMake(widthView, heightView);
    self.popupController.theme.maxPopupWidth = widthView;
    self.popupController.delegate = self;
    self.popupController.theme.shouldDismissOnBackgroundTouch = false;
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        self.popupController.VIEW_POPUP.transform = CGAffineTransformMakeScale(-1, 1);
    }
    
    UILabel* _labelTitle = [self createLabel:viewTop fontType:kUIFontType20 fontColorType:kUIColorFontDark frame:CGRectMake(0, -16, viewTop.frame.size.width, viewTop.frame.size.height + 16) textStr:Localize(@"select_language")];
//    UILabel* _labelTitle = [self createLabel:viewTop fontType:kUIFontType20 fontColorType:kUIColorFontDark frame:CGRectMake(0, 0, viewTop.frame.size.width, viewTop.frame.size.height) textStr:Localize(@"select_language")];
    [_labelTitle setTextAlignment:NSTextAlignmentCenter];
    
    float leftItemsPosX = viewMain.frame.size.width * 0.10f;
    float itemPosY = viewMain.frame.size.width * 0.04f + viewTop.frame.size.height;
    float itemPosYOriginal = viewMain.frame.size.width * 0.04f + viewTop.frame.size.height;
    UILabel* labelTemp= [[UILabel alloc] init];
    [labelTemp setUIFont:kUIFontType24 isBold:false];
    float fontHeight = [[labelTemp font] lineHeight];
    
    
    
//    Addons* addons = [Addons sharedManager];
    if(addons.language&& addons.language.titles && [addons.language.titles count] > 0) {
        {
            for (int i = 0; i < (int)[addons.language.titles count]; i++) {
                CGRect frame = CGRectMake(leftItemsPosX + 10, itemPosY, viewMain.frame.size.width, fontHeight);
                itemPosY+=(frame.size.height + fontHeight * 0.5f);
            }
        }
    }
    itemPosY += itemPosYOriginal;
    
    self.popupController.theme.size = CGSizeMake(widthView, itemPosY);
    CGRect viewMainFrame = viewMain.frame;
    viewMainFrame.size = CGSizeMake(widthView, itemPosY);
    viewMain.frame = viewMainFrame;
    
    
    itemPosY = itemPosYOriginal;
    if(addons.language && addons.language.titles && [addons.language.titles count] > 0) {
        
        for (int i = 0; i < (int)[addons.language.titles count]; i++) {
            UIButton* button = [[UIButton alloc] init];
            button.frame = CGRectMake(leftItemsPosX + 10, itemPosY, viewMain.frame.size.width, fontHeight);
            [button addTarget:self action:@selector(chkBoxLanguageClicked:) forControlEvents:UIControlEventTouchUpInside];
            [viewMain addSubview:button];
          
            [button setUIImage:[UIImage imageNamed:@"radiobtn_unselected"] forState:UIControlStateNormal];
            [button setUIImage:[UIImage imageNamed:@"radiobtn_selected"] forState:UIControlStateSelected];
            [button setTitle:[NSString stringWithFormat:@"%@", addons.language.titles[i]] forState:UIControlStateNormal];
            [button setTitleEdgeInsets:UIEdgeInsetsMake(0, viewMain.frame.size.width * 0.04f, 0, 0)];
            [button setTitleColor:[Utility getUIColor:kUIColorFontLight] forState:UIControlStateNormal];
            [button setTitleColor:[Utility getUIColor:kUIColorFontLight] forState:UIControlStateSelected];
            [button.titleLabel setUIFont:kUIFontType20 isBold:false];
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            [button.layer setValue:addons.language.locales[i] forKey:@"MY_LOCALE"];
            [button.layer setValue:addons.language.titles[i] forKey:@"MY_LOCALE_TITLE"];
            [_chkBoxLanguage addObject:button];
            if (i == 0) {
                [button setSelected:true];
            }
            itemPosY+=(button.frame.size.height + fontHeight * 0.5f);
        }
        
        for (UIButton* button in _chkBoxLanguage) {
            if (button.isSelected) {
                [self chkBoxLanguageClicked:button];
            }
        }
        if ((int)[_chkBoxLanguage count] == 1) {
            UIButton* button = (UIButton*)[_chkBoxLanguage objectAtIndex:0];
            [button setSelected:true];
            [self chkBoxLanguageClicked:button];
        }
        
    }
    
    
    UIButton* _buttonOk = [[UIButton alloc] initWithFrame:CGRectMake(0, -16, viewTop.frame.size.width, viewTop.frame.size.height + 16)];
    [viewTop addSubview:_buttonOk];
    //    [_buttonOk addTarget:self action:@selector(languageSelectedDone:) forControlEvents:UIControlEventTouchUpInside];
    [_buttonOk addTarget:self action:@selector(languageSelectedDone:) forControlEvents:UIControlEventTouchDown];
    [_buttonOk setTitle:Localize(@"i_cok") forState:UIControlStateNormal];
    [[_buttonOk titleLabel] setUIFont:kUIFontType18 isBold:false];
    [_buttonOk setTitleColor:[Utility getUIColor:kUIColorThemeFont] forState:UIControlStateNormal];
    [_buttonOk setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 16)];
    _buttonOk.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
//    _buttonOk.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
    [viewMain addSubview:_buttonOk];
    
    
    [self.popupController presentPopupControllerAnimated:YES];
}
- (UILabel*)createLabel:(UIView*)parentView fontType:(int)fontType fontColorType:(int)fontColorType frame:(CGRect)frame textStr:(NSString*)textStr {
    UILabel* label = [[UILabel alloc] init];
    if (CGRectEqualToRect(frame, CGRectMake(0, 0, 0, 0))) {
        frame = parentView.frame;
    }
    [label setUIFont:fontType isBold:false];
    [label setTextColor:[Utility getUIColor:fontColorType]];
    [label setFrame:frame];
    [label setText:textStr];
    [parentView addSubview:label];
    return label;
}
- (void)gotonextscreen{
    if ([[Addons sharedManager] multiVendor_enable] &&
        [[Addons sharedManager] multiVendor_screen_type] == MULTIVENDOR_SCREEN_SELLER && [[[DataManager sharedManager] tmDataDoctor] isVendorDataFetched] == false) {
        [[[DataManager sharedManager] tmDataDoctor] fetchVendorDataFromPlugin];
    }
    NSString* vendorId = [[NSUserDefaults standardUserDefaults] valueForKey:VENDOR_ID];
    if ([[Addons sharedManager] multiVendor_enable] &&
        [[Addons sharedManager] multiVendor_screen_type] == MULTIVENDOR_SCREEN_SELLER && vendorId == nil) {
        [self hhh];
        [_myTimer invalidate];
    }else{
        UIStoryboard *sb = [Utility getStoryBoardObject];
        UIViewController *rootViewController = [sb instantiateViewControllerWithIdentifier:VC_SPLASH_SECONDARY];
        [[UIApplication sharedApplication].keyWindow setRootViewController:rootViewController];
        [_myTimer invalidate];
    }
}
- (void)startTimer {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    _myTimer =  [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(goToNextViewController:) userInfo:nil repeats:YES];
}
- (void)cancelTimer {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [ NSObject cancelPreviousPerformRequestsWithTarget:self];
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
- (void)setViewMovedUp:(BOOL)movedUp {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    RLOG(@"setViewMovedUp:%d", movedUp);
    [UIView beginAnimations:nil context:NULL];
    CGRect rect = self.view.frame;
    [UIView setAnimationDuration:_duration];
    [UIView setAnimationCurve:_curve];
    if (movedUp) {
        rect.origin.y = -_keyboardHeight;
    }
    else {
        rect.origin.y = 0;
    }
    self.view.frame = rect;
    [UIView commitAnimations];
}

//- (void)setViewMovedUp:(BOOL)movedUp {
//    RLOG(@"%s", __PRETTY_FUNCTION__);
//    RLOG(@"setViewMovedUp:%d", movedUp);
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:_duration];
//    [UIView setAnimationCurve:_curve];
//    CGRect rect = _popupController.VIEW_POPUP.frame;
//    if (movedUp) {
//        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
//        CGPoint p = [_textFieldFirstResponder convertPoint:_textFieldFirstResponder.center toView:window];
//        float textViewPos = p.y;
//        float windowViewHeight = [[MyDevice sharedManager] screenSize].height;
//        float keyboardPos = windowViewHeight - _keyboardHeight;
//        if (textViewPos > keyboardPos) {
//            rect.origin.y = -_keyboardHeight;
//        }
//    }
//    else {
//        rect.origin.y = 0;
//    }
//    _popupController.VIEW_POPUP.frame = rect;
//    [UIView commitAnimations];
//}

- (void)viewWillDisappear:(BOOL)animated {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super viewWillDisappear:animated];
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextFieldTextDidChangeNotification
                                                  object:nil];
}
#pragma mark - Adjust Orientation
- (void)resetMainScrollView {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    int fontType;
    if ([[MyDevice sharedManager] isIpad]) {
        fontType = kUIFontType18;
    } else {
        fontType = kUIFontType18;
    }
    float height = [[Utility getUIFont:fontType isBold:false] lineHeight] * 2;
    float imgDemoHeight = _imageFgDemo.frame.size.height;
    float textFieldHeight = _textFieldDemoKey.frame.size.height;
    float buttonHeight = _buttonDone.frame.size.height;
    float gap = height;
    float totalH = imgDemoHeight + gap + textFieldHeight + gap + buttonHeight;
    float totalViewHeight = self.view.frame.size.height;
    float newPosY = (totalViewHeight - totalH) / 2;
    newPosY += (imgDemoHeight/2);
    [_imageFgDemo setCenter:CGPointMake(self.view.frame.size.width/2, newPosY)];
    newPosY += (imgDemoHeight/2) + gap + (textFieldHeight/2);
    [_textFieldDemoKey setCenter:CGPointMake(self.view.frame.size.width/2, newPosY)];
    newPosY += (textFieldHeight/2) + gap + (buttonHeight/2);
    [_buttonDone setCenter:CGPointMake(self.view.frame.size.width/2, newPosY)];
}

- (void)beforeRotation {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [UIView animateWithDuration:0.1f animations:^{
        [_mainView setAlpha:0.0f];
    }completion:^(BOOL finished){
    }];
}
- (void)afterRotation {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [self addViews];
    [UIView animateWithDuration:0.1f animations:^{
        [_mainView setAlpha:1.0f];
    }completion:^(BOOL finished){
        
    }];
}
/*
 - (void)beforeRotation {
 [UIView animateWithDuration:0.1f animations:^{
 [_imageFgDemo setAlpha:0.0f];
 }completion:^(BOOL finished){
 }];
 
 [UIView animateWithDuration:0.1f animations:^{
 [_textFieldDemoKey setAlpha:0.0f];
 }completion:^(BOOL finished){
 }];
 
 [UIView animateWithDuration:0.1f animations:^{
 [_buttonDone setAlpha:0.0f];
 }completion:^(BOOL finished){
 }];
 }
 - (void)afterRotation {
 [self resetMainScrollView];
 [_imageFgDemo setAlpha:0.0f];
 [UIView animateWithDuration:0.1f animations:^{
 [_imageFgDemo setAlpha:1.0f];
 }completion:^(BOOL finished){
 }];
 [_textFieldDemoKey setAlpha:0.0f];
 [UIView animateWithDuration:0.1f animations:^{
 [_textFieldDemoKey setAlpha:1.0f];
 }completion:^(BOOL finished){
 }];
 [_buttonDone setAlpha:0.0f];
 [UIView animateWithDuration:0.1f animations:^{
 [_buttonDone setAlpha:1.0f];
 }completion:^(BOOL finished){
 }];
 }
 */
- (void)adjustViewsForOrientation:(UIDeviceOrientation) orientation {
    RLOG(@"%s", __PRETTY_FUNCTION__);
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
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [self adjustViewsAfterOrientation:[[UIDevice currentDevice] orientation]];
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if ([[AppDelegate getInstance] isAppEnteredInBackground]) {
        return;
    }
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [self adjustViewsForOrientation:[[UIDevice currentDevice] orientation]];
}
- (void)hhh
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(vendorDataSucceed:)
                                                 name:@"VENDOR_DATA_SUCCESS"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(vendorDataFailed:)
                                                 name:@"VENDOR_DATA_FAILED"
                                               object:nil];
    if ([[Addons sharedManager] multiVendor_enable] &&
        [[Addons sharedManager] multiVendor_screen_type] == MULTIVENDOR_SCREEN_SELLER) {
        if ([[[DataManager sharedManager] tmDataDoctor] isVendorDataFetched]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"VENDOR_DATA_SUCCESS" object:nil];
        } else {
            [[[DataManager sharedManager] tmDataDoctor] fetchVendorDataFromPlugin];
        }
    }
}
- (void)vendorDataSucceed:(NSNotification*)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"VENDOR_DATA_SUCCESS" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"VENDOR_DATA_FAILED" object:nil];
    UIStoryboard *sb = [Utility getStoryBoardObject];
    UIViewController *rootViewController = [sb instantiateViewControllerWithIdentifier:VC_RIGHT];
    [[UIApplication sharedApplication].keyWindow setRootViewController:rootViewController];
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        rootViewController.view.transform = CGAffineTransformMakeScale(-1, 1);
    }
}
- (void)vendorDataFailed:(NSNotification*)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"VENDOR_DATA_SUCCESS" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"VENDOR_DATA_FAILED" object:nil];
}
#if SUPPORT_PORTRAIT_ORIENTATION_ONLY
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}
- (BOOL)shouldAutorotate {
    return YES;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
- (NSUInteger)navigationControllerSupportedInterfaceOrientations:(UINavigationController *)navigationController {
    return UIInterfaceOrientationMaskPortrait;
}
#else
- (BOOL)shouldAutorotate {
    return YES;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    if([[MyDevice sharedManager] isIphone]){
        return UIInterfaceOrientationMaskPortrait;
    }
    return UIInterfaceOrientationMaskAll;
}
#endif

- (void)backgroundTouchEventRegistered:(CNPPopupController *)controller {
    RLOG(@"backgroundTouchEventRegistered:");
}
@end
