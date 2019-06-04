//
//  SPViewController.m
//  TMPaymentSDK
//
//  Created by Rishabh Jain on 29/06/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import "SPViewController.h"
#import "CellOldCard.h"
@interface SPViewController () <
STPPaymentCardTextFieldDelegate,
UITextFieldDelegate,
UITableViewDelegate,
UITableViewDataSource
>
{
    NSMutableArray *oldCards;
    NSMutableArray *oldCustomerId;
    NSString* selectedCustomerId;
}
@property (weak, nonatomic) STPPaymentCardTextField *paymentTextField;
@property (weak, nonatomic) UIActivityIndicatorView *activityIndicator;
@property StripeConfig* config;
@property BOOL isTextAdded;

@end
static int cellHeight = 75;
@implementation SPViewController
- (id)initWithDelegate:(id)delegate {
    NSBundle *bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"TMPaymentSDKResources" withExtension:@"bundle"]];
    if ((self = [super initWithNibName:@"SPViewController" bundle:bundle])) {
    }
    _responseDelegate = delegate;
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadCustomerData];
    self.tableOldCard.delegate = self;
    self.tableOldCard.dataSource = self;
    selectedCustomerId = @"";
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textDidChange:)
                                                 name: UITextFieldTextDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    _config = [StripeConfig sharedManager];
    [self initilizeView];
}
- (void)viewWillDisappear:(BOOL)animated {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
}
- (void)initilizeView {
    [self.view setBackgroundColor:[UIColor whiteColor]];
    if ([oldCards count] == 0) {
        [self.viewOldCard setHidden:true];
    } else {
        [self.viewOldCard setHidden:false];
        [self.tableOldCard reloadData];
    }
    [self.lblAddNewCard setText:_config.infoLStrAddCard];
    [self.lblSavedCard setText:_config.infoLStrSavedCard];
    [self.lblSavedCard setFont:[UIFont boldSystemFontOfSize:17]];
    
    [self.lblTotalAmountD setFont:[UIFont boldSystemFontOfSize:20]];
    [self.lblTotalAmountH setFont:[UIFont boldSystemFontOfSize:20]];
    
    [self.lblTotalAmountH setText:_config.infoLStrTotalAmount];
    [self.lblTotalAmountD setText:_config.infoCurrencyString];


    
    if ([oldCards count] > 0) {
        self.constraintTableHeight.constant = [oldCards count] * cellHeight;
        self.constaintTableParentHeight.constant = [oldCards count] * cellHeight + 100;
//        self.cSavedCardViewTopH.constant = 10;
        self.cLblAddNewCardH.constant = 50;
        self.cBtnAddNewCardH.constant = 40;
        [self.btnAddNewCard setHidden:false];
        [self.lblAddNewCard setHidden:false];
        self.cViewNewCardH.constant = 80;
        self.clblNameTop.constant = 40;
        [self.viewLineNewCard setHidden:false];
    } else {
        self.constraintTableHeight.constant = 0;
        self.constaintTableParentHeight.constant = 0;
//        self.cSavedCardViewTopH.constant = 0;
        self.cLblAddNewCardH.constant = 0;
        self.cBtnAddNewCardH.constant = 0;
        [self.btnAddNewCard setHidden:true];
        [self.lblAddNewCard setHidden:true];
        self.cViewNewCardH.constant = 250;
        
        self.clblNameTop.constant = 20;
        [self.viewLineNewCard setHidden:true];
    }
    [self updateViewConstraints];
    [self.tableOldCard reloadData];
    
    
    
    // Setup payment view
    STPPaymentCardTextField *paymentTextField = [[STPPaymentCardTextField alloc] init];
    paymentTextField.delegate = self;
    paymentTextField.cursorColor = [UIColor purpleColor];
    _paymentTextField = paymentTextField;
    [_paymentTextField setHidden:true];
    [_paymentTextField setUserInteractionEnabled:false];
    [self.view addSubview:_paymentTextField];
   
    self.title = _config.cTitle;
    
    _label_name.text = _config.pp_card_holder_name;
    if([_config.pp_card_holder_name_hint isEqualToString:@"default_value"]){
        _textfield_name.placeholder = @"";
    } else {
        _textfield_name.placeholder = _config.pp_card_holder_name_hint;
    }
    _textfield_name.delegate = self;
    
    
    _label_number.text = _config.pp_card_number;
    if([_config.pp_card_number_hint isEqualToString:@"default_value"]){
        _textfield_number.placeholder = _paymentTextField.numberPlaceholder;
    } else {
        _textfield_number.placeholder = _config.pp_card_number_hint;
    }
    _textfield_number.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    _textfield_number.delegate = self;
    _textfield_number.returnKeyType = UIReturnKeyNext;
    
    _label_date.text = _config.pp_card_expiry_date;
    if([_config.pp_card_expiry_date_hint isEqualToString:@"default_value"]){
        _textfield_date.placeholder = _paymentTextField.expirationPlaceholder;
    } else {
        _textfield_date.placeholder = _config.pp_card_expiry_date_hint;
    }
    [_textfield_date setDelegate:self];
//    [_textfield_date setTextContentType:UITextContentTypeTelephoneNumber];
    _textfield_date.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    _textfield_date.delegate = self;
    _textfield_date.returnKeyType = UIReturnKeyNext;
    
    _label_cvv.text = _config.pp_card_cvv;
    if([_config.pp_card_cvv_hint isEqualToString:@"default_value"]){
        _textfield_cvv.placeholder = _paymentTextField.cvcPlaceholder;
    } else {
        _textfield_cvv.placeholder = _config.pp_card_cvv_hint;
    }
    [_textfield_cvv setSecureTextEntry:NO];
    _textfield_cvv.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    _textfield_cvv.delegate = self;
    _textfield_cvv.returnKeyType = UIReturnKeyDone;
    
    
    _label_zip.text = _config.pp_card_zipcode;
    if([_config.pp_card_zipcode_hint isEqualToString:@"default_value"]){
        _textfield_zip.placeholder = @"";
    } else {
        _textfield_zip.placeholder = _config.pp_card_zipcode_hint;
    }
    
    
    NSString *title = [NSString stringWithFormat:@"%@ %@", _config.pp_pay_button_title, _config.infoCurrencyString];
    [_button_pay setTitle:title forState:UIControlStateNormal];
    
    [self setTitle:_config.paymentPageTitle];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:
                                   _config.backButtonTitle style:UIBarButtonItemStylePlain target:
                                   self action:@selector(backButtonClicked:)];
    [self.navigationItem setLeftBarButtonItem:backButton];
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setBackgroundColor:[UIColor whiteColor]];
    
    
    // Setup Activity Indicator
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.hidesWhenStopped = YES;
    _activityIndicator = activityIndicator;
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
    _paymentTextField.frame = CGRectMake(padding, padding, width, 44);
    _paymentTextField.frame = CGRectMake(0, 0, 0, 0);//updated

    _activityIndicator.center = self.view.center;
}

- (void)paymentCardTextFieldDidChange:(nonnull STPPaymentCardTextField *)textField {
    self.navigationItem.rightBarButtonItem.enabled = textField.isValid;
}

- (void)cancel:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)save:(id)sender {
    if ([selectedCustomerId isEqualToString:@""] && ![_paymentTextField isValid]) {
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
    [_activityIndicator startAnimating];
    
    if (![selectedCustomerId isEqualToString:@""]) {
        [self createBackendChargeWithToken:nil completion:^(STPBackendChargeResult result, NSError *error) {
            if (error) {
                [self stripePaymentViewController:self didFinish:error];
                return;
            }
            [self stripePaymentViewController:self didFinish:nil];
        }];
    } else {
        [[STPAPIClient sharedClient] createTokenWithCard:_paymentTextField.cardParams
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
}
- (void)createBackendChargeWithToken:(STPToken *)token completion:(STPTokenSubmissionHandler)completion {
    [_activityIndicator startAnimating];
    NSString* BackendChargeURLString = _config.cBackendChargeURLString;
    if (![_config.cBackendChargeURLStringSavedCard isEqualToString:@""]) {
        BackendChargeURLString = _config.cBackendChargeURLStringSavedCard;
    }
    
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
    NSString *postBody = @"";
    
    if (token == nil && ![selectedCustomerId isEqualToString:@""]) {
        postBody = [NSString stringWithFormat:@"stripeToken=%@&amount=%@&apikey=%@&currency=%@&description=%@&customer_id=%@", @" ", [NSNumber numberWithFloat:_config.infoTotalAmount/* * 100.0f */], _config.cStripeSecretKey, _config.infoCurrency, _config.infoDescription, selectedCustomerId];
    } else {
        postBody = [NSString stringWithFormat:@"stripeToken=%@&amount=%@&apikey=%@&currency=%@&description=%@", token.tokenId, [NSNumber numberWithFloat:_config.infoTotalAmount/* * 100.0f */], _config.cStripeSecretKey, _config.infoCurrency, _config.infoDescription];
    }
    
    
    NSData *data = [postBody dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request fromData:data completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [self.activityIndicator stopAnimating];
        
        NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"Response String = %@" ,jsonString);
        
        NSDictionary *dict = nil;
        if (![_config.cBackendChargeURLStringSavedCard isEqualToString:@""]) {
            NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            dict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
        }
        
        if (error == nil) {
            NSString *statusStr = jsonString;
            if (dict) {
                if ([dict objectForKey:@"status"] && ![[dict objectForKey:@"status"] isEqual:[NSNull null]]) {
                    statusStr = [dict valueForKey:@"status"];
                }
                if ([[statusStr lowercaseString] isEqualToString:@"success"]) {
                    NSArray *customer_data = [dict valueForKey:@"customer_data"];
                    if (customer_data && [customer_data isKindOfClass:[NSArray class]] && [customer_data count] > 0) {
                        [self saveCustomerData:customer_data];
                    }
                    completion(STPBackendChargeResultSuccess, nil);
                } else {
                    NSError *errorViaResponseData = [NSError errorWithDomain:StripeDomain code:STPInvalidRequestError userInfo:@{NSLocalizedDescriptionKey: statusStr}];
                    completion(STPBackendChargeResultFailure, errorViaResponseData);
                }
            } else if ([[statusStr lowercaseString] isEqualToString:@"success"]) {
                completion(STPBackendChargeResultSuccess, nil);
            } else {
                NSError *errorViaResponseData = [NSError errorWithDomain:StripeDomain code:STPInvalidRequestError userInfo:@{NSLocalizedDescriptionKey: statusStr}];
                completion(STPBackendChargeResultFailure, errorViaResponseData);
            }
        } else {
            completion(STPBackendChargeResultFailure, error);
        }
    }];
    [uploadTask resume];
}
- (void)saveCustomerData:(NSArray*)customer_data {
    if (customer_data && [customer_data isKindOfClass:[NSArray class]]) {
        NSLog(@"customer_data = %@",customer_data);
        
        NSError *err = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:customer_data options:0 error:&err];
        
        NSString *cDataDesc = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSString *cDataDescBase64 = [[[NSString stringWithFormat:@"%@", cDataDesc] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
        NSLog(@"cDataDesc = %@",cDataDesc);
        NSLog(@"cDataDescBase64 = %@",cDataDescBase64);
        
        NSString *cDataTitle = @"cData";
        NSString *cDataTitleBase64 = [[[NSString stringWithFormat:@"%@", cDataTitle] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
        NSLog(@"cData = %@",cDataTitle);
        NSLog(@"cDataBase64 = %@",cDataTitleBase64);
        
        [[NSUserDefaults standardUserDefaults] setObject:cDataDescBase64 forKey:cDataTitleBase64];
    }
}
- (void)loadCustomerData {
    NSString *cDataTitle = @"cData";
    NSString *cDataTitleBase64 = [[[NSString stringWithFormat:@"%@", cDataTitle] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
    NSLog(@"cData = %@",cDataTitle);
    NSLog(@"cDataBase64 = %@",cDataTitleBase64);
    NSString *cDataDescBase64 = [[NSUserDefaults standardUserDefaults] valueForKey:cDataTitleBase64];
    NSArray *customer_data = nil;
    if (cDataDescBase64 && ![cDataDescBase64 isEqualToString:@""]) {
        NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:cDataDescBase64 options:0];
        NSString *cDataDesc = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
        NSLog(@"cDataDesc = %@",cDataDesc);
        NSLog(@"cDataDescBase64 = %@",cDataDescBase64);
        NSData *data = [cDataDesc dataUsingEncoding:NSUTF8StringEncoding];
        customer_data = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSLog(@"customer_data = %@",customer_data);
    }
    if (oldCards == nil) {
        oldCards = [[NSMutableArray alloc] init];
    }
    if (oldCustomerId == nil) {
        oldCustomerId = [[NSMutableArray alloc] init];
    }
    [oldCards removeAllObjects];
    [oldCustomerId removeAllObjects];
    if (customer_data) {
        for (NSDictionary* dict in customer_data) {
            NSString* customerId = @"";
            NSString* last4 = @"";
            if ([dict valueForKey:@"customer_id"]) {
                customerId = [dict valueForKey:@"customer_id"];
            }
            if ([dict valueForKey:@"last4"]) {
                last4 = [dict valueForKey:@"last4"];
            }
            if (![customerId isEqualToString:@""] && ![last4 isEqualToString:@""]) {
                [oldCards addObject:last4];
                [oldCustomerId addObject:customerId];
            }
        }
    }
    
//    {
//        [oldCards addObject:@"3456"];
//        [oldCustomerId addObject:@"fgdfghjdfhdfgh"];
//        [oldCards addObject:@"5567"];
//        [oldCustomerId addObject:@"fgdfdgsdfhdfgh"];
//        [oldCards addObject:@"3886"];
//        [oldCustomerId addObject:@"fgdfghhggsdfgh"];
//        [oldCards addObject:@"9967"];
//        [oldCustomerId addObject:@"fgfghghjkghjgh"];
//    }
}
- (void)stripePaymentViewController:(SPViewController *)controller didFinish:(NSError *)error {
    if (error == nil) {
        [self dismissViewControllerAnimated:YES completion:^ {
            [_responseDelegate postCompletionCallbackWithSuccess:nil];
            _responseDelegate = nil;
        }];
    } else {
        [self dismissViewControllerAnimated:YES completion:^ {
            [_responseDelegate postCompletionCallbackWithFailure:nil];
            _responseDelegate = nil;
        }];
    }
}
- (IBAction)buttonPayClicked:(id)sender {
    if ([oldCards count] > 0 && [self.tableOldCard indexPathForSelectedRow] != nil) {
        [self payWithOldCard];
    } else {
        selectedCustomerId = @"";
        [self payWithCardDetails];
    }
}
- (void)payWithOldCard {
    int selectedRow = (int)[self.tableOldCard indexPathForSelectedRow].row;
    selectedCustomerId = [oldCustomerId objectAtIndex:selectedRow];
    [self save:nil];
}
- (void)payWithCardDetails {
    if (
        /*![_textfield_name.text isEqualToString:@""] &&*/
        ![_textfield_number.text isEqualToString:@""] &&
        ![_textfield_date.text isEqualToString:@""] &&
        ![_textfield_cvv.text isEqualToString:@""] /*&&
                                                    ![_textfield_zip.text isEqualToString:@""]*/
        ) {
        
        STPCardParams* cParam = [[STPCardParams alloc] init];
        /*cParam.name = _textfield_name.text;*/
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
        /*cParam.addressZip = _textfield_zip.text;*/
        [_paymentTextField setCardParams:cParam];
        [self save:nil];
    }
    else {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"" message:_config.pp_all_fields_are_mendatory delegate:self cancelButtonTitle:_config.button_ok_title otherButtonTitles:nil, nil];
        [alertView show];
    }
}
- (void)backButtonClicked:(id)sender {
    [self operationResult:false];
}
- (void)operationResult:(BOOL)success {
    [PaymentUtility stopGrayLoadingBar];
    [_activityIndicator stopAnimating];
    if (success) {
        [self dismissViewControllerAnimated:YES completion:^ {
            [_responseDelegate postCompletionCallbackWithSuccess:nil];
            _responseDelegate = nil;
        }];
    } else {
        [self dismissViewControllerAnimated:YES completion:^ {
            [_responseDelegate postCompletionCallbackWithFailure:nil];
            _responseDelegate = nil;
        }];
    }
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (self.tableOldCard) {
        [self.tableOldCard deselectRowAtIndexPath:[self.tableOldCard indexPathForSelectedRow] animated:YES];
    }
    return YES;
}
- (void)textDidChange:(NSNotification*)notification {
    UITextField *textField = (UITextField *)[notification object];
    if(textField == _textfield_date && textField.text.length == 2 && _isTextAdded){
        textField.text = [textField.text stringByAppendingString:@"/"];
    }
    _isTextAdded = false;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    BOOL stringIsValid = true;
    if(textField == _textfield_date) {
        if (string.length > 0) {
            _isTextAdded = true;
            NSCharacterSet *numbersOnly = [NSCharacterSet characterSetWithCharactersInString:@"/0123456789"];
            NSCharacterSet *characterSetFromTextField = [NSCharacterSet characterSetWithCharactersInString:string];
            stringIsValid = [numbersOnly isSupersetOfSet:characterSetFromTextField];
            if (stringIsValid) {
                if(textField == _textfield_date && textField.text.length == 2 && _isTextAdded){
                    textField.text = [textField.text stringByAppendingString:@"/"];
                }
                stringIsValid = !([textField.text length] > 4 && [string length] > range.length);
            }
        }
    }
    return stringIsValid;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [oldCards count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellOldCard";
    CellOldCard *cell = (CellOldCard *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSBundle *bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"TMPaymentSDKResources" withExtension:@"bundle"]];
        cell = [[bundle loadNibNamed:CellIdentifier owner:self options:nil] objectAtIndex:0];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    if (oldCards && [oldCards count] >= indexPath.row) {
        [cell.labelCardNumber setText:[NSString stringWithFormat:@"xxxx xxxx xxxx %@", [oldCards objectAtIndex:indexPath.row]]];
    }
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return cellHeight;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self setAddNewCardEnable:false];
}
- (IBAction)eventAddNewCardClicked:(id)sender {
    [self setAddNewCardEnable:true];
}
- (void)setAddNewCardEnable:(BOOL)isEnable {
    if (isEnable) {
        self.cViewNewCardH.constant = 290;
        [self updateViewConstraints];
        
        [self.btnAddNewCard setSelected:true];
        [self.lblAddNewCard setFont:[UIFont boldSystemFontOfSize:17]];
        if (self.tableOldCard) {
            [self.tableOldCard deselectRowAtIndexPath:[self.tableOldCard indexPathForSelectedRow] animated:YES];
        }
    } else {
        self.cViewNewCardH.constant = 80;
        [self updateViewConstraints];
        
        [self.btnAddNewCard setSelected:false];
        [self.lblAddNewCard setFont:[UIFont systemFontOfSize:18]];
        [_textfield_number setText:@""];
        [_textfield_date setText:@""];
        [_textfield_cvv setText:@""];
    }
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    _textFieldFirstResponder = textField;
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _textfield_number && textField.returnKeyType == UIReturnKeyNext) {
        [_textfield_date becomeFirstResponder];
    } else if (textField == _textfield_date && textField.returnKeyType == UIReturnKeyNext) {
        [_textfield_cvv becomeFirstResponder];
    } else if (textField == _textfield_cvv && textField.returnKeyType == UIReturnKeyDone) {
        [textField resignFirstResponder];
    }
    return YES;
}
- (void)cancelNumberPad:(UIBarButtonItem*)button {
    [self textFieldShouldReturn:_textFieldFirstResponder];
}
- (void)doneWithNumberPad:(UIBarButtonItem*)button {
    [self textFieldShouldReturn:_textFieldFirstResponder];
}
- (void)keyboardWillShow:(NSNotification *)notification {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSDictionary *info  = notification.userInfo;
    NSValue      *value = info[UIKeyboardFrameEndUserInfoKey];
    CGRect rawFrame      = [value CGRectValue];
    CGRect keyboardFrame = [self.view convertRect:rawFrame fromView:nil];
    NSLog(@"keyboardFrame: %@", NSStringFromCGRect(keyboardFrame));
    _keyboardHeight = keyboardFrame.size.height - 50;
    _duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    _curve = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    // Animate the current view out of the way
    [self setViewMovedUp:YES];
}
- (void)keyboardWillHide {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self setViewMovedUp:NO];
}
- (void)setViewMovedUp:(BOOL)movedUp {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"setViewMovedUp:%d", movedUp);
    [UIView beginAnimations:nil context:NULL];
    if (movedUp == false) {
        [UIView setAnimationDuration:0.0f];
    } else {
        [UIView setAnimationDuration:_duration];
    }
    
    
    [UIView setAnimationCurve:_curve];
    CGRect rect = self.view.frame;
    if (movedUp) {
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        CGPoint p = [_textFieldFirstResponder convertPoint:_textFieldFirstResponder.center toView:window];
        float textViewPos = p.y;
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        float windowViewHeight = screenSize.height;
        float keyboardPos = windowViewHeight - _keyboardHeight;
        
        if (textViewPos > keyboardPos) {
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                float val = MIN(_keyboardHeight, (textViewPos - keyboardPos));
                val = val * -1;
                rect.origin.y = val;
                self.view.frame = rect;
            }
        }
    }
    else {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            rect.origin.y = 0;
            self.view.frame = rect;
            CGSize screenSize = [UIScreen mainScreen].bounds.size;
            self.view.center = CGPointMake(screenSize.width/2, screenSize.height/2);
        }
    }
    
    [UIView commitAnimations];
}
@end
