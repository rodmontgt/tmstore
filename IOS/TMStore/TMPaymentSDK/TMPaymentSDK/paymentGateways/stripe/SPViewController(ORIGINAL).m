//
//  SPViewController.m
//  TMPaymentSDK
//
//  Created by Rishabh Jain on 29/06/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import "SPViewController.h"

@interface SPViewController () <STPPaymentCardTextFieldDelegate>
@property (weak, nonatomic) STPPaymentCardTextField *paymentTextField;
@property (weak, nonatomic) UIActivityIndicatorView *activityIndicator;
@property StripeConfig* config;
@end

@implementation SPViewController
- (id)init {
    NSBundle *bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"TMPaymentSDKResources" withExtension:@"bundle"]];
    if ((self = [super initWithNibName:@"SPViewController" bundle:bundle])) {
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _config = [StripeConfig sharedManager];
    [self initilizeView];
    return;
    /*
    
    // Do any additional setup after loading the view from its nib.
    self.config = [StripeConfig sharedManager];
    self.title = self.config.cTitle;
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    // Setup save button
    NSString *title = [NSString stringWithFormat:@"Pay %@", stripeConfig.infoCurrencyString];
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleDone target:self action:@selector(save:)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    saveButton.enabled = NO;
    self.navigationItem.leftBarButtonItem = cancelButton;
    self.navigationItem.rightBarButtonItem = saveButton;
    
    // Setup payment view
    STPPaymentCardTextField *paymentTextField = [[STPPaymentCardTextField alloc] init];
    paymentTextField.delegate = self;
    paymentTextField.cursorColor = [UIColor purpleColor];
    self.paymentTextField = paymentTextField;
    [self.view addSubview:paymentTextField];
    
    // Setup Activity Indicator
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.hidesWhenStopped = YES;
    self.activityIndicator = activityIndicator;
    [self.view addSubview:activityIndicator];
    
    */
}
- (void)initilizeView {
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.label_name_top_constraint.constant = 100;
    [self.view setNeedsUpdateConstraints];
    
    
    
    
    // Setup payment view
    STPPaymentCardTextField *paymentTextField = [[STPPaymentCardTextField alloc] init];
    paymentTextField.delegate = self;
    paymentTextField.cursorColor = [UIColor purpleColor];
    self.paymentTextField = paymentTextField;
    
    
   
    self.title = _config.cTitle;
    self.label_name.text = _config.pp_card_holder_name;
    self.label_number.text = _config.pp_card_number;
    self.label_date.text = _config.pp_card_expiry_date;
    self.label_cvv.text = _config.pp_card_cvv;
    self.label_zip.text = _config.pp_card_zipcode;
    self.textfield_number.placeholder = self.paymentTextField.numberPlaceholder;
    self.textfield_date.placeholder = self.paymentTextField.expirationPlaceholder;
    self.textfield_cvv.placeholder = self.paymentTextField.cvcPlaceholder;
    
    NSString *title = [NSString stringWithFormat:@"%@ %@", _config.pp_pay_button_title, _config.infoCurrencyString];
    [self.button_pay setTitle:title forState:UIControlStateNormal];
    
    [self setTitle:_config.paymentPageTitle];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:
                                   _config.backButtonTitle style:UIBarButtonItemStylePlain target:
                                   self action:@selector(backButtonClicked:)];
    [self.navigationItem setLeftBarButtonItem:backButton];
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setBackgroundColor:[UIColor whiteColor]];
    
//    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleDone target:self action:@selector(save:)];
//    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
//    saveButton.enabled = NO;
//    self.navigationItem.leftBarButtonItem = cancelButton;
//    self.navigationItem.rightBarButtonItem = saveButton;
    
    
    
    
    // Setup Activity Indicator
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.hidesWhenStopped = YES;
    self.activityIndicator = activityIndicator;
    [self.view addSubview:activityIndicator];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat padding = 15;
    CGFloat width = CGRectGetWidth(self.view.frame) - (padding * 2);
    self.paymentTextField.frame = CGRectMake(padding, padding, width, 44);
    
    self.activityIndicator.center = self.view.center;
}

- (void)paymentCardTextFieldDidChange:(nonnull STPPaymentCardTextField *)textField {
    self.navigationItem.rightBarButtonItem.enabled = textField.isValid;
}

- (void)cancel:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)save:(id)sender {
    if (![self.paymentTextField isValid]) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"" message:_config.pp_invalid_details delegate:self cancelButtonTitle:_config.button_ok_title otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    if (![Stripe defaultPublishableKey]) {
        NSError *error = [NSError errorWithDomain:StripeDomain
                                             code:STPInvalidRequestError
                                         userInfo:@{
                                                    NSLocalizedDescriptionKey: @"Please specify a Stripe Publishable Key in Constants.m"
                                                    }];
        [self stripePaymentViewController:self didFinish:error];
        return;
    }
    [self.activityIndicator startAnimating];
    [[STPAPIClient sharedClient] createTokenWithCard:self.paymentTextField.cardParams
                                          completion:^(STPToken *token, NSError *error) {
                                              [self.activityIndicator stopAnimating];
                                              if (error) {
                                                  [self stripePaymentViewController:self didFinish:error];
                                                  return;
                                              }
                                              [self createBackendChargeWithToken:token completion:^(STPBackendChargeResult result, NSError *error) {
                                                  if (error) {
                                                      [self stripePaymentViewController:self didFinish:error];
                                                      return;
                                                  }
                                                  [self stripePaymentViewController:self didFinish:nil];
                                              }];
                                          }];
}
- (void)createBackendChargeWithToken:(STPToken *)token completion:(STPTokenSubmissionHandler)completion {
    NSString* BackendChargeURLString = _config.cBackendChargeURLString;
    if (!BackendChargeURLString) {
        NSError *error = [NSError
                          errorWithDomain:StripeDomain
                          code:STPInvalidRequestError
                          userInfo:@{
                                     NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Good news! Stripe turned your credit card into a token: %@ \nYou can follow the "
                                                                 @"instructions in the README to set up an example backend, or use this "
                                                                 @"token to manually create charges at dashboard.stripe.com .",
                                                                 token.tokenId]
                                     }];
        completion(STPBackendChargeResultFailure, error);
        return;
    }
    
    // This passes the token off to our payment backend, which will then actually complete charging the card using your Stripe account's secret key
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    NSURL *url = [NSURL URLWithString:BackendChargeURLString];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    NSString *postBody = [NSString stringWithFormat:@"stripeToken=%@&amount=%@&apikey=%@&currency=%@&description=%@", token.tokenId, [NSNumber numberWithFloat:_config.infoTotalAmount/* * 100.0f */], _config.cStripeSecretKey, _config.infoCurrency, _config.infoDescription];
    NSData *data = [postBody dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request fromData:data completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString* newStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"Response String = %@" ,newStr);
        if (error == nil) {
            if ([newStr isEqualToString:@"SUCCESS"]) {
                completion(STPBackendChargeResultSuccess, nil);
            } else {
                NSError *errorViaResponseData = [NSError errorWithDomain:StripeDomain
                                                                    code:STPInvalidRequestError
                                                                userInfo:@{
                                                                           NSLocalizedDescriptionKey: newStr
                                                                           }];
                completion(STPBackendChargeResultFailure, errorViaResponseData);
            }
        } else {
            completion(STPBackendChargeResultFailure, error);
        }
    }];
    [uploadTask resume];
}
- (void)stripePaymentViewController:(SPViewController *)controller didFinish:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
    if (error) {
        [_responseDelegate postCompletionCallbackWithFailure:error];
    } else {
        [_responseDelegate postCompletionCallbackWithSuccess:nil];
    }
}
- (IBAction)buttonPayClicked:(id)sender {
    if (![_textfield_name.text isEqualToString:@""] &&
        ![_textfield_number.text isEqualToString:@""] &&
        ![_textfield_date.text isEqualToString:@""] &&
        ![_textfield_cvv.text isEqualToString:@""] &&
        ![_textfield_zip.text isEqualToString:@""]) {
        
        STPCardParams* cParam = [[STPCardParams alloc] init];
        cParam.name = _textfield_name.text;
        cParam.number = _textfield_number.text;
        
        @try {
            NSString* md =  _textfield_date.text;
            NSArray *items = [md componentsSeparatedByString:@"/"];
            if (items && [items count] == 2) {
                NSString* monthStr = [items objectAtIndex:0];
                NSString* yearStr = [items objectAtIndex:1];
                cParam.expMonth = [monthStr intValue];
                cParam.expYear = [yearStr intValue];
            }
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
        
        

        cParam.cvc = _textfield_cvv.text;
        cParam.addressZip = _textfield_zip.text;
        [self.paymentTextField setCardParams:cParam];
        [self save:nil];
        
    } else {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"" message:_config.pp_all_fields_are_mendatory delegate:self cancelButtonTitle:_config.button_ok_title otherButtonTitles:nil, nil];
        [alertView show];
    }
    
}
- (void)backButtonClicked:(id)sender{
    [self operationResult:false];
}
- (void)operationResult:(BOOL)success{
    [PaymentUtility stopGrayLoadingBar];
    [self.activityIndicator  stopAnimating];
    [self dismissViewControllerAnimated:YES completion:nil];
    if (success) {
        [_responseDelegate postCompletionCallbackWithSuccess:nil];
    } else {
        [_responseDelegate postCompletionCallbackWithFailure:nil];
    }
}
@end
