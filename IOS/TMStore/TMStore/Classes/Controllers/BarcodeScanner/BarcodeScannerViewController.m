/*
 Copyright 2017 Google Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

@import AVFoundation;
#import "Variables.h"
#import "BarcodeScannerViewController.h"
#import "Utility.h"

#define MTB_BARCODE_SCANNER 1
#if !(TARGET_OS_SIMULATOR) && ENABLE_BARCODE_SCANNER && MTB_BARCODE_SCANNER
#import "MTBBarcodeScanner.h"
#import "DrawingUtility.h"
@interface BarcodeScannerViewController () {
    UIButton *customBackButton;
}
@property (nonatomic, weak) IBOutlet UIView *previewView;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *toggleTorchButton;
@property (nonatomic, strong) MTBBarcodeScanner *scanner;
@property (nonatomic, strong) NSMutableArray *uniqueCodes;
@property (nonatomic, assign) BOOL captureIsFrozen;
@property (nonatomic, assign) BOOL didShowCaptureWarning;

@property UIView *placeHolderView;
@property UIView *overlayView;
@end
@implementation BarcodeScannerViewController

- (IBAction)barButtonBackPressed:(id)sender {
    [[Utility sharedManager] popScreen:self];
    if ([self.view tag] == PUSH_SCREEN_TYPE_BRAND) {
        return;
    }
    ViewControllerMain* mainVC = [ViewControllerMain getInstance];
    [mainVC resetPreviousState];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [Utility getUIColor:kUIColorThemeFont], NSForegroundColorAttributeName, [Utility getUIFont:kUIFontType24 isBold:false], NSFontAttributeName, nil]];
    [self.currentItemHeading setTitle:@"   "];
    
    _labelViewHeading = [[UILabel alloc] init] ;
    [_labelViewHeading setFrame:CGRectMake(0, 20, [[MyDevice sharedManager] screenSize].width, _navigationBar.frame.size.height)];
    [_labelViewHeading setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [_labelViewHeading setUIFont:kUIFontType24 isBold:false];
    [_labelViewHeading setTextColor:[Utility getUIColor:kUIColorThemeFont]];
    [_labelViewHeading setTextAlignment:NSTextAlignmentCenter];
    [_labelViewHeading setText:@"    "];
    [self.view addSubview:_labelViewHeading];
    
    [_navigationBar setClipsToBounds:false];
    [_lineView setBackgroundColor:[Utility getUIColor:kUIColorBorder]];
    //    [_scrollView setBackgroundColor:[Utility getUIColor:kUIColorBgTheme]];
    [self.view setBackgroundColor:[Utility getUIColor:kUIColorBgHeader]];
    [_navigationBar setBarTintColor:[Utility getUIColor:kUIColorBgHeader]];
    customBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [customBackButton setImage:[[UIImage imageNamed:@"img_arrow_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [customBackButton addTarget:self action:@selector(barButtonBackPressed:)forControlEvents:UIControlEventTouchUpInside];
    [customBackButton setTitle:[NSString stringWithFormat:@"  %@  ", Localize(@"i_back")] forState:UIControlStateNormal];
    [customBackButton setTintColor:[Utility getUIColor:kUIColorThemeFont]];
    [customBackButton setTitleColor:[Utility getUIColor:kUIColorThemeFont] forState:UIControlStateNormal];
    [customBackButton.titleLabel setUIFont:kUIFontType18 isBold:false];
    
    [customBackButton sizeToFit];
    [_previousItemHeading setCustomView:customBackButton];
    [_previousItemHeading setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[Utility getUIColor:kUIColorThemeFont], NSForegroundColorAttributeName, [Utility getUIFont:kUIFontType18 isBold:false], NSFontAttributeName, nil] forState:UIControlStateNormal];
    
    CGRect rect = self.view.frame;
    rect.origin.y = [[Utility sharedManager] getTopBarHeight];
    rect.size.height -= rect.origin.y;
    _overlayView = [[UIView alloc] initWithFrame:rect];
    [self.view addSubview:_overlayView];
    
    [self.labelViewHeading setText:Localize(@"title_barcode_scan")];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self startScanning];
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.scanner stopScanning];
}
#pragma mark - Scanner
- (MTBBarcodeScanner *)scanner {
    if (!_scanner) {
        _scanner = [[MTBBarcodeScanner alloc] initWithPreviewView:_overlayView];
    }
    return _scanner;
}
#pragma mark - Scanning

- (void)startScanning {
    self.uniqueCodes = [[NSMutableArray alloc] init];
    NSError *error = nil;
    [self.scanner startScanningWithResultBlock:^(NSArray *codes) {
        for (AVMetadataMachineReadableCodeObject *code in codes) {
            if (code.stringValue && [self.uniqueCodes indexOfObject:code.stringValue] == NSNotFound) {
                [self.uniqueCodes addObject:code.stringValue];
                
                NSLog(@"Found unique code: %@", code.stringValue);
                [self barcodeRawValue:code.stringValue];
            }
        }
    } error:&error];
    if (error) {
        NSLog(@"An error occurred: %@", error.localizedDescription);
    }
}
- (void)stopScanning {
    [self.scanner stopScanning];
    self.captureIsFrozen = NO;
}
#pragma mark - Actions
- (IBAction)toggleScanningTapped:(id)sender {
    if ([self.scanner isScanning] || self.captureIsFrozen) {
        [self stopScanning];
        self.toggleTorchButton.title = @"Enable Torch";
    } else {
        [MTBBarcodeScanner requestCameraPermissionWithSuccess:^(BOOL success) {
            if (success) {
                [self startScanning];
            } else {
                [self displayPermissionMissingAlert];
            }
        }];
    }
}
- (IBAction)switchCameraTapped:(id)sender {
    [self.scanner flipCamera];
}
- (IBAction)toggleTorchTapped:(id)sender {
    if (self.scanner.torchMode == MTBTorchModeOff) {
        self.scanner.torchMode = MTBTorchModeOn;
        self.toggleTorchButton.title = @"Disable Torch";
    } else {
        self.scanner.torchMode = MTBTorchModeOff;
        self.toggleTorchButton.title = @"Enable Torch";
    }
}
- (void)backTapped {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - Helper Methods
- (void)displayPermissionMissingAlert {
    NSString *message = nil;
    if ([MTBBarcodeScanner scanningIsProhibited]) {
        message = @"This app does not have permission to use the camera.";
    } else if (![MTBBarcodeScanner cameraIsPresent]) {
        message = @"This device does not have a camera.";
    } else {
        message = @"An unknown error occurred.";
    }
    
    [[[UIAlertView alloc] initWithTitle:@"Scanning Unavailable"
                                message:message
                               delegate:nil
                      cancelButtonTitle:@"Ok"
                      otherButtonTitles:nil] show];
}
#pragma mark - Gesture Handlers
- (void)previewTapped {
    if (![self.scanner isScanning] && !self.captureIsFrozen) {
        return;
    }
    if (!self.didShowCaptureWarning) {
        [[[UIAlertView alloc] initWithTitle:@"Capture Frozen"
                                    message:@"The capture is now frozen. Tap the preview again to unfreeze."
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil] show];
        
        self.didShowCaptureWarning = YES;
    }
    if (self.captureIsFrozen) {
        [self.scanner unfreezeCapture];
    } else {
        [self.scanner freezeCapture];
    }
    self.captureIsFrozen = !self.captureIsFrozen;
}
#pragma mark - Setters
- (void)setUniqueCodes:(NSMutableArray *)uniqueCodes {
    _uniqueCodes = uniqueCodes;
}



#pragma mark - AVCaptureVideoPreviewLayer Helper method

- (CGRect)scaleRect:(CGRect)rect
             xScale:(CGFloat)xscale
             yScale:(CGFloat)yscale
             offset:(CGPoint)offset {
    CGRect resultRect = CGRectMake(rect.origin.x * xscale,
                                   rect.origin.y * yscale,
                                   rect.size.width * xscale,
                                   rect.size.height * yscale);
    resultRect = CGRectOffset(resultRect, offset.x, offset.y);
    return resultRect;
}

- (CGPoint)scalePoint:(CGPoint)point
               xScale:(CGFloat)xscale
               yScale:(CGFloat)yscale
               offset:(CGPoint)offset {
    CGPoint resultPoint = CGPointMake(point.x * xscale + offset.x, point.y * yscale + offset.y);
    return resultPoint;
}
- (void)setDelegate:(id)delegate {
    _delegate = delegate;
}
- (void)barcodeRawValue:(NSString*)rawValue {
    NSLog(@"RawValue: %@", rawValue);
    [[Utility sharedManager] popScreen:self];
    if (_delegate) {
        [_delegate barcodeFetchedRawValue:rawValue];
    }
    _delegate = nil;
}
@end
#else
@interface BarcodeScannerViewController (){}
@property(nonatomic, weak) IBOutlet UIView *placeHolderView;
@property(nonatomic, weak) IBOutlet UIView *overlayView;
@end
@implementation BarcodeScannerViewController
- (void)setDelegate:(id)delegate {
    _delegate = delegate;
}
- (IBAction)barButtonBackPressed:(id)sender {
    [[Utility sharedManager] popScreen:self];
    if ([self.view tag] == PUSH_SCREEN_TYPE_BRAND) {
        return;
    }
    ViewControllerMain* mainVC = [ViewControllerMain getInstance];
    [mainVC resetPreviousState];
}
@end
#endif
