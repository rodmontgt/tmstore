//
//  ViewControllerTopBar.m
//
//  Created by Rishabh Jain on 24/09/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import "ViewControllerTopBar.h"
#import "Utility.h"
#import "ViewControllerMain.h"
#import "LayoutManager.h"
#import "DataManager.h"
#import <SDWebImage/UIButton+WebCache.h>
#import "ViewControllerRight.h"
@interface ViewControllerTopBar ()

@end

@implementation ViewControllerTopBar

#pragma mark - View Life Cycle

- (void)viewDidLoad {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super viewDidLoad];
    [[Utility sharedManager] addShowAppInfoGesture:self];
    
    _imgSizeFrameOriginal = CGSizeMake(0, 0);
    self.view.backgroundColor = [Utility getUIColor:kUIColorBgHeader];
    
    float screenH = [[Utility sharedManager] getTopBarHeight];
    float lineHeight = 1.0f;
    _lineView = [[UIView alloc] initWithFrame:CGRectMake(0,  screenH - lineHeight, self.view.frame.size.width, lineHeight)];
    _lineView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _lineView.backgroundColor = [Utility getUIColor:kUIColorBorder];
    [self.view addSubview:_lineView];

    [_imageLogo setUIImage:[Utility getAppIconImage]];
    
    _imageLogo.hidden = true;
    [_labelHeader setUIFont:kUIFontType24 isBold:false];
    [_labelHeader setTextColor:[Utility getUIColor:kUIColorThemeFont]];
    
    [[_buttonHeader titleLabel] setUIFont:kUIFontType24 isBold:false];
    [_buttonHeader setTitleColor:[Utility getUIColor:kUIColorThemeFont] forState:UIControlStateNormal];
    [_buttonHeader setBackgroundColor:[UIColor clearColor]];
    [_buttonHeader.imageView setContentMode:UIViewContentModeScaleAspectFit];
//    [_buttonHeader setUIImage:[Utility getAppIconImage] forState:UIControlStateNormal];
    
    [_buttonHeader setUIImage:[UIImage imageNamed:@"HeaderIcon.png"] forState:UIControlStateNormal];
    
    if ([[Addons sharedManager] show_actionbar_icon] && [[Addons sharedManager] actionbar_icon_url] && ![[[Addons sharedManager] actionbar_icon_url] isEqualToString:@""]) {
        
        NSString* icon_url =  [[Addons sharedManager] actionbar_icon_url];
        NSURL *url = [NSURL URLWithString:icon_url];
        NSData *data = [NSData dataWithContentsOfURL:url];
   //  [_buttonHeader setUIImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
        NSLog(@"print_url %@",icon_url);
     //  [Utility setImage:_buttonHeader.imageView url:icon_url resizeType:0 isLocal:false highPriority:true];
        
        [_buttonHeader sd_setImageWithURL:[NSURL URLWithString:icon_url] forState:UIControlStateNormal];
    }
     [_buttonHeader setImageEdgeInsets:UIEdgeInsetsMake(5, 0, 5, 0)];
    
#if (IS_RECORD_APP_ENABLE)
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(videoRecordingToggle:)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.numberOfTouchesRequired = 2;
    [_imageLogo.superview addGestureRecognizer:doubleTap];
    [_imageLogo.superview setUserInteractionEnabled:YES];
#endif
    
    UIImage* normal = [[UIImage imageNamed:@"drawer"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage* selected = [[UIImage imageNamed:@"drawer"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage* highlighted = [[UIImage imageNamed:@"drawer"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_buttonLeftView setUIImage:normal forState:UIControlStateNormal];
    [_buttonLeftView setUIImage:selected forState:UIControlStateSelected];
    [_buttonLeftView setUIImage:highlighted forState:UIControlStateHighlighted];
    [_buttonLeftView setTintColor:[Utility getUIColor:kUIColorThemeFont]];
    [_buttonLeftView setEnabled:true];

    [_buttonRightView.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [_buttonLeftView.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self redrawButtonRightView];
}
- (void)redrawButtonRightView{
    if ([[[Addons sharedManager] multiVendor] isEnabled]) {
        UIImage* normalR;
        normalR = [[UIImage imageNamed:@"shopNew"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        NSString* vendorIcon = [[[Addons sharedManager] multiVendor] multiVendor_icon_url];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            _buttonRightView.imageView.transform = CGAffineTransformMakeScale(-1, 1);
        }
        
//        _buttonRightView.imageView.layer.borderWidth = 1;
//        _buttonRightView.layer.borderWidth = 1;
//        _buttonLeftView.imageView.layer.borderWidth = 1;
//        _buttonLeftView.layer.borderWidth = 1;
        
        NSURL* nsurl = [NSURL URLWithString:[vendorIcon stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
        [_buttonRightView setTintColor:[Utility getUIColor:kUIColorThemeButtonSelected]];
        
        [_buttonRightView sd_setImageWithURL:nsurl forState:UIControlStateNormal placeholderImage:normalR completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [_buttonRightView setTintColor:[Utility getUIColor:kUIColorClear]];
        }];
        
        [_buttonRightView sd_setImageWithURL:nsurl forState:UIControlStateSelected placeholderImage:normalR completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [_buttonRightView setTintColor:[Utility getUIColor:kUIColorClear]];
        }];
        
        [_buttonRightView sd_setImageWithURL:nsurl forState:UIControlStateHighlighted placeholderImage:normalR completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [_buttonRightView setTintColor:[Utility getUIColor:kUIColorClear]];
//            float s1 = _buttonRightView.imageView.frame.size.width;
//            float s2 = _buttonRightView.imageView.frame.size.height;
//            [_buttonRightView setImageEdgeInsets:UIEdgeInsetsMake(0, s1 - s2, 0, 0)];
//            [_buttonRightView.imageView setContentMode:UIViewContentModeScaleAspectFit];
//            [_buttonLeftView.imageView setContentMode:UIViewContentModeScaleAspectFit];
        }];
    }
    else {
        [_buttonRightView setEnabled:false];
    }
}
- (void)videoRecordingToggle:(UITapGestureRecognizer*)doubleTap{
    RLOG(@"videoRecordingToggle called.");
    Utility* utility = [Utility sharedManager];
    if (utility.recordingState == kRECORDING_ENABLE)
    {
        utility.recordingState = kRECORDING_DISABLE;
        [utility stopRecording];
    } else {
        utility.recordingState = kRECORDING_ENABLE;
        [utility startRecording];
    }
}
//- (void)viewWillAppear:(BOOL)animated {
//    RLOG(@"%s", __PRETTY_FUNCTION__);
//    [super viewWillAppear:animated];
//
//    float screenH = [[Utility sharedManager] getTopBarHeight];
//    float lineHeight = 1.0f;
//    [_lineView setFrame:CGRectMake(0,  screenH - lineHeight, self.view.frame.size.width, lineHeight)];
//}
//- (void)viewDidAppear:(BOOL)animated {
//    RLOG(@"%s", __PRETTY_FUNCTION__);
//    [super viewDidAppear:animated];
//
//    float screenH = [[Utility sharedManager] getTopBarHeight];
//    float lineHeight = 1.0f;
//    [_lineView setFrame:CGRectMake(0,  screenH - lineHeight, self.view.frame.size.width, lineHeight)];
//}
- (void)didReceiveMemoryWarning {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super didReceiveMemoryWarning];
}
//- (NSUInteger)supportedInterfaceOrientations
//{
//    //Forced Portrait mode
//    return UIInterfaceOrientationMaskPortrait;
//}
 #pragma mark - Navigation
//  In a storyboard-based application, you will often want to do a little preparation before navigation
// - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//  Get the new view controller using [segue destinationViewController].
//  Pass the selected object to the new view controller.
// }
#pragma mark - Actions

- (IBAction)btnClickedBack:(id)sender {

}
- (IBAction)btnClickedRightDrawer:(id)sender {
    
}
- (IBAction)btnClickedLeftDrawer:(id)sender {
    
}

@end
