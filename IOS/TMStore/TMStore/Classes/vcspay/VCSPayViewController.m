//
//  VCSPayViewController.m
//  TMPaymentSDK
//
//  Created by Rishabh Jain on 29/06/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import "VCSPayViewController.h"
#import <TMPaymentSDK/TMPaymentSDK.h>
#import <AFNetworking/AFNetworking.h>
#import "Utility.h"
@interface VCSPayViewController () <UITextFieldDelegate>
@property (weak, nonatomic) UIActivityIndicatorView *activityIndicator;
@property VCSPayConfig* config;
@property BOOL isTextAdded;
@end

@implementation VCSPayViewController
- (id)initWithDelegate:(id)delegate {
//    NSBundle *bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"TMPaymentSDKResources" withExtension:@"bundle"]];
    NSBundle *bundle = nil;
    if ((self = [super initWithNibName:@"VCSPayViewController" bundle:bundle])) {
    }
    _responseDelegate = delegate;
    _serverUrl = @"https://www.vcs.co.za/vvonline/ccxmlauth.asp";
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textDidChange:)
                                                 name: UITextFieldTextDidChangeNotification
                                               object:nil];
    
    _config = [VCSPayConfig sharedManager];
    [self initilizeView];
}
- (void)viewWillAppear:(BOOL)animated {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super viewWillAppear:animated];
    
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
- (void)initilizeView {
    [self.view setBackgroundColor:[UIColor whiteColor]];
    _label_name_top_constraint.constant = 100;
    [self.view setNeedsUpdateConstraints];
    
    self.title = _config.cTitle;
    
    _label_name.text = _config.pp_card_holder_name;
    if([_config.pp_card_holder_name_hint isEqualToString:@"default_value"]){
        _textfield_name.placeholder = @"";
    } else {
        _textfield_name.placeholder = _config.pp_card_holder_name_hint;
    }
    
    _label_number.text = _config.pp_card_number;
    if([_config.pp_card_number_hint isEqualToString:@"default_value"]){
        _textfield_number.placeholder = @"012345678012345678";
    } else {
        _textfield_number.placeholder = _config.pp_card_number_hint;
    }
    
    _label_date.text = _config.pp_card_expiry_date;
    if([_config.pp_card_expiry_date_hint isEqualToString:@"default_value"]){
        _textfield_date.placeholder = @"MM/YY";
    } else {
        _textfield_date.placeholder = _config.pp_card_expiry_date_hint;
    }
    [_textfield_date setDelegate:self];
//    [_textfield_date setTextContentType:UITextContentTypeTelephoneNumber];
    
    
    _label_cvv.text = _config.pp_card_cvv;
    if([_config.pp_card_cvv_hint isEqualToString:@"default_value"]){
        _textfield_cvv.placeholder = @"CVC";
    } else {
        _textfield_cvv.placeholder = _config.pp_card_cvv_hint;
    }
    [_textfield_cvv setSecureTextEntry:NO];
    [self addDoneButtonTextField:_textfield_cvv];
    
    
    
    _label_zip.text = _config.pp_card_zipcode;
    if([_config.pp_card_zipcode_hint isEqualToString:@"default_value"]){
        _textfield_zip.placeholder = @"";
    } else {
        _textfield_zip.placeholder = _config.pp_card_zipcode_hint;
    }
    
    
    
    
    NSString *title = [NSString stringWithFormat:@"%@ %@", _config.pp_pay_button_title, _config.infoCurrencyString];
    [_button_pay setTitle:title forState:UIControlStateNormal];
    [self setButtonEnable];
    
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
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _activityIndicator.center = self.view.center;
}
- (void)cancel:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
- (void)VCSPayPaymentViewController:(VCSPayViewController *)controller didFinish:(NSError *)error {
    if (error) {
        [self dismissViewControllerAnimated:YES completion:^{
            [_responseDelegate postCompletionCallbackWithFailure:error];
            _responseDelegate = nil;
        }];
    } else {
        [self dismissViewControllerAnimated:YES completion:^{
            [_responseDelegate postCompletionCallbackWithSuccess:nil];
            _responseDelegate = nil;
        }];
    }
}
- (void)setButtonEnable {
    [_button_pay setBackgroundColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
    [_button_pay setTitleColor:[Utility getUIColor:kUIColorBuyButtonFont] forState:UIControlStateNormal];
    [_button_pay setEnabled:true];
}
- (void)setButtonDisable {
    [_button_pay setBackgroundColor:[UIColor lightGrayColor]];
    [_button_pay setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    [_button_pay setEnabled:false];
}
- (IBAction)buttonPayClicked:(id)sender {
    [_activityIndicator startAnimating];
    [self setButtonDisable];
    if (
        ![_textfield_name.text isEqualToString:@""] &&
        ![_textfield_number.text isEqualToString:@""] &&
        ![_textfield_date.text isEqualToString:@""] &&
        ![_textfield_cvv.text isEqualToString:@""] /*&&
                                                    ![_textfield_zip.text isEqualToString:@""]*/
        )
    {
        NSString* requestData = [self getRequestData];
        NSMutableDictionary* paramsMutable = [[NSMutableDictionary alloc] init];
        [paramsMutable setObject:requestData forKey:@"xmlMessage"];
        NSDictionary* params = [[NSDictionary alloc] initWithDictionary:paramsMutable];
        NSString* serverUrl = [NSString stringWithFormat:@"%@", _serverUrl];
        NSLog(@"params:%@", params);
        NSLog(@"serverUrl:%@", serverUrl);
        AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        [manager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
        [manager POST:serverUrl parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSString *responseString = @"";
            if (responseObject) {
                responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            }
            [self parseResponse:responseString];
            [_activityIndicator stopAnimating];
            [self setButtonEnable];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"%@",error);
            NSString *responseString = @"";
            if (error && error.userInfo) {
                id data = [error.userInfo valueForKey:@"com.alamofire.serialization.response.error.data"];
                if (data) {
                    responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                }
            }
            [self parseResponse:responseString];
            [_activityIndicator stopAnimating];
            [self setButtonEnable];
        }];
    } else {
        [_activityIndicator stopAnimating];
        [self setButtonEnable];
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"" message:_config.pp_all_fields_are_mendatory delegate:self cancelButtonTitle:_config.button_ok_title otherButtonTitles:nil, nil];
        [alertView show];
    }
}
- (void)parseResponse:(NSString*)responseString {
    BOOL isPaymentSuccessful = false;
    NSString* resultMessage = @"";
    if (![responseString isEqualToString:@""]) {
        NSString *haystack = responseString;//@"value:hello World:value";
        NSString *haystackPrefix = @"<Response>";
        NSString *haystackSuffix = @"</Response>";
        NSRange prefixRange = [haystack rangeOfString:haystackPrefix];
        NSRange suffixRange = [haystack rangeOfString:haystackSuffix];
        NSRange needleRange = NSMakeRange(prefixRange.location + prefixRange.length, - (prefixRange.location + prefixRange.length) + suffixRange.location);
        NSString *needle = [haystack substringWithRange:needleRange];
        resultMessage = needle;
        RLOG(@"resultMessage: %@", resultMessage); // -> "hello World"
        if ([needle containsString:@"APPROVED"] && [needle length] == 14) {
            isPaymentSuccessful = true;
        }
    }
    if (resultMessage && ![resultMessage isEqualToString:@""]) {
        resultMessage = [resultMessage stringByReplacingOccurrencesOfString:@"~" withString:@""];
    }
    [self operationResult:isPaymentSuccessful obj:resultMessage];
}
- (NSString*)getRequestData {
    VCSPayConfig* config = [VCSPayConfig sharedManager];
    NSString* mMerchantId = config.cMerchantId;
    NSString* mReference = [self randomStringWithLength:25];
    NSString* mDescription = config.infoDescription;
    float mAmount = config.infoTotalAmount;
    NSString* mCurrency = config.infoCurrency;
    
    NSString* mCardHolder = @"";
    NSString* mCardNumber = @"";
    NSString* mExpiryYear = @"";
    NSString* mExpiryMonth = @"";
    NSString* mCardCVC = @"";
    mCardHolder = _textfield_name.text;
    mCardNumber  = _textfield_number.text;
    @try {
        NSString* md =  _textfield_date.text;
        NSArray *items = [md componentsSeparatedByString:@"/"];
        if (items && [items count] == 2) {
            NSString* monthStr = [items objectAtIndex:0];
            NSString* yearStr = [items objectAtIndex:1];
            mExpiryMonth = monthStr;
            mExpiryYear = yearStr;
        }
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    mCardCVC = _textfield_cvv.text;
    /* NSString* customerZip = _textfield_zip.text;*/
    
    
    
    
//    mMerchantId = @"3958";
//    mReference = [self randomStringWithLength:25];
//    mDescription = @"Goods";
//    mAmount = @"10.0";
//    mCurrency = @"bwp";
//    mCardHolder = @"TMStore";
//    mCardNumber = @"4242424242424242";
//    mExpiryYear = @"18";
//    mExpiryMonth = @"21";
//    mCardCVC = @"123";


    NSMutableString *xml = [[NSMutableString alloc] initWithString:@""];
    [xml appendString:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"];
    [xml appendString:@"<AuthorisationRequest>"];
    [xml appendString:[NSString stringWithFormat:@"<UserId>%@</UserId>", mMerchantId]];
    [xml appendString:[NSString stringWithFormat:@"<Reference>%@</Reference>", mReference]];
    [xml appendString:[NSString stringWithFormat:@"<Description>%@</Description>", mDescription]];
    [xml appendString:[NSString stringWithFormat:@"<Amount>%.2f</Amount>", mAmount]];
    [xml appendString:[NSString stringWithFormat:@"<Currency>%@</Currency>", mCurrency]];
    [xml appendString:[NSString stringWithFormat:@"<CardholderName>%@</CardholderName>", mCardHolder]];
    [xml appendString:[NSString stringWithFormat:@"<CardNumber>%@</CardNumber>", mCardNumber]];
    [xml appendString:[NSString stringWithFormat:@"<ExpiryMonth>%@</ExpiryMonth>", mExpiryMonth]];
    [xml appendString:[NSString stringWithFormat:@"<ExpiryYear>%@</ExpiryYear>", mExpiryYear]];
    [xml appendString:[NSString stringWithFormat:@"<CardValidationCode>%@</CardValidationCode>", mCardCVC]];
    [xml appendString:@"</AuthorisationRequest>"];
    NSString* requestData = [NSString stringWithFormat:@"%@", xml];
    NSLog(@"requestData = %@", requestData);
    return requestData;

//    return @"<?xml version=\"1.0\" ?>" +
//    "<AuthorisationRequest>" +
//    "<UserId>" + mMerchantId + "</UserId>" +
//    "<Reference>" + mReference + "</Reference>" +
//    "<Description>" + mDescription + "</Description>" +
//    "<Amount>" + mAmount + "</Amount>" +
//    "<Currency>" + mCurrency + "</Currency>" +
//    "<CardholderName>" + mCardHolder + "</CardholderName>" +
//    "<CardNumber>" + mCardNumber + "</CardNumber>" +
//    "<ExpiryMonth>" + mExpiryMonth + "</ExpiryMonth>" +
//    "<ExpiryYear>" + mExpiryYear + "</ExpiryYear>" +
//    "<CardValidationCode>" + mCardCVC + "</CardValidationCode>" +
//    "</AuthorisationRequest>";
}
- (NSString*)ConvertDictionarytoXML:(NSDictionary*)dictionary  withStartElement:(NSString*)startElement{
    NSMutableString *xml = [[NSMutableString alloc] initWithString:@""];
    [xml appendString:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"];
    [xml appendString:[NSString stringWithFormat:@"<%@>",startElement]];
    [self convertNode:dictionary withString:xml andTag:nil];
    [xml appendString:[NSString stringWithFormat:@"</%@>",startElement]];
    NSString *finalXML=[xml stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
    NSLog(@"%@",xml);
    return finalXML;
}
- (void)convertNode:(id)node withString:(NSMutableString *)xml andTag:(NSString *)tag{
    if ([node isKindOfClass:[NSDictionary class]] && !tag) {
        NSArray *keys = [node allKeys];
        for (NSString *key in keys) {
            [self convertNode:[node objectForKey:key] withString:xml andTag:key];
        }
    }else if ([node isKindOfClass:[NSArray class]]) {
        for (id value in node) {
            [self convertNode:value withString:xml andTag:tag];
        }
    }else {
        [xml appendString:[NSString stringWithFormat:@"<%@>", tag]];
        if ([node isKindOfClass:[NSString class]]) {
            [xml appendString:node];
        }else if ([node isKindOfClass:[NSDictionary class]]) {
            [self convertNode:node withString:xml andTag:nil];
        }
        [xml appendString:[NSString stringWithFormat:@"</%@>", tag]];
    }
}
- (void)backButtonClicked:(id)sender{
    [self operationResult:false];
}
- (void)operationResult:(BOOL)success obj:(id)obj{
    [PaymentUtility stopGrayLoadingBar];
    [_activityIndicator  stopAnimating];
    if (success) {
        [self dismissViewControllerAnimated:YES completion:^{
            [_responseDelegate postCompletionCallbackWithSuccess:nil];
            _responseDelegate = nil;
        }];
    } else {
        [self dismissViewControllerAnimated:YES completion:^{
            [_responseDelegate postCompletionCallbackWithFailure:obj];
            _responseDelegate = nil;
        }];
    }
}
- (void)operationResult:(BOOL)success{
    [PaymentUtility stopGrayLoadingBar];
    [_activityIndicator stopAnimating];
    if (success) {
        [self dismissViewControllerAnimated:YES completion:^{
            [_responseDelegate postCompletionCallbackWithSuccess:nil];
            _responseDelegate = nil;
        }];
    } else {
        [self dismissViewControllerAnimated:YES completion:^{
            [_responseDelegate postCompletionCallbackWithFailure:nil];
            _responseDelegate = nil;
        }];
    }
}
NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
- (NSString *)randomStringWithLength:(int)len {
    NSMutableString *randomString = [NSMutableString stringWithCapacity:len];
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform([letters length])]];
    }
    return randomString;
}
- (NSString*)makeParamtersString:(NSDictionary*)parameters withEncoding:(NSStringEncoding)encoding {
    if (nil == parameters || [parameters count] == 0)
        return nil;
    
    NSMutableString* stringOfParamters = [[NSMutableString alloc] init];
    NSEnumerator *keyEnumerator = [parameters keyEnumerator];
    id key = nil;
    while ((key = [keyEnumerator nextObject]))
    {
        NSString *value = [[parameters valueForKey:key] isKindOfClass:[NSString class]] ?
        [parameters valueForKey:key] : [[parameters valueForKey:key] stringValue];
        [stringOfParamters appendFormat:@"%@=%@&",
         [self URLEscaped:key withEncoding:encoding],
         [self URLEscaped:value withEncoding:encoding]];
    }
    
    // Delete last character of '&'
    NSRange lastCharRange = {[stringOfParamters length] - 1, 1};
    [stringOfParamters deleteCharactersInRange:lastCharRange];
    return stringOfParamters;
}
- (NSString *)URLEscaped:(NSString *)strIn withEncoding:(NSStringEncoding)encoding {
    CFStringRef escaped = CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)strIn, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", CFStringConvertNSStringEncodingToEncoding(encoding));
    NSString *strOut = [NSString stringWithString:(__bridge NSString *)escaped];
    CFRelease(escaped);
    return strOut;
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
    
    
    if (textField == _textfield_cvv)
    {
        if(string.length > 0)
        {
            NSCharacterSet *numbersOnly = [NSCharacterSet characterSetWithCharactersInString:@"+0123456789"];
            NSCharacterSet *characterSetFromTextField = [NSCharacterSet characterSetWithCharactersInString:string];
            BOOL stringIsValid = [numbersOnly isSupersetOfSet:characterSetFromTextField];
            if (stringIsValid) {
                if (_textfield_cvv.text.length < 4) {
                    return stringIsValid;
                } else {
                    return false;
                }
            }
            return stringIsValid;
        }
    }
    return stringIsValid;
}
- (void)addDoneButtonTextField:(UITextField*)view{
    if ([[MyDevice sharedManager] isIphone]) {
        UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
        numberToolbar.backgroundColor = [UIColor lightGrayColor];
        UIBarButtonItem* doneBtn = [[UIBarButtonItem alloc]initWithTitle:Localize(@"done") style:UIBarButtonItemStyleBordered target:self action:@selector(doneWithNumberPad:)];
        numberToolbar.items = @[
                                [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                doneBtn];
        [numberToolbar sizeToFit];
        view.inputAccessoryView = numberToolbar;
    }
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    _textFieldFirstResponder = textField;
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
- (void)cancelNumberPad:(UIBarButtonItem*)button {
    [self textFieldShouldReturn:_textFieldFirstResponder];
}
- (void)doneWithNumberPad:(UIBarButtonItem*)button {
    [self textFieldShouldReturn:_textFieldFirstResponder];
}
- (void)keyboardWillShow:(NSNotification *)notification {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    NSDictionary *info  = notification.userInfo;
    NSValue      *value = info[UIKeyboardFrameEndUserInfoKey];
    CGRect rawFrame      = [value CGRectValue];
    CGRect keyboardFrame = [self.view convertRect:rawFrame fromView:nil];
    RLOG(@"keyboardFrame: %@", NSStringFromCGRect(keyboardFrame));
    _keyboardHeight = keyboardFrame.size.height - 50;
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
        float windowViewHeight = [[MyDevice sharedManager] screenSize].height;
        float keyboardPos = windowViewHeight - _keyboardHeight;
        
        if (textViewPos > keyboardPos) {
            if ([[MyDevice sharedManager] isIphone]) {
                float val = MIN(_keyboardHeight, (textViewPos - keyboardPos));
                val = val * -1;
                rect.origin.y = val;
                self.view.frame = rect;
            }
        }
    }
    else {
        if ([[MyDevice sharedManager] isIphone]) {
            rect.origin.y = 0;
            self.view.frame = rect;
            self.view.center = CGPointMake([[MyDevice sharedManager] screenSize].width/2, [[MyDevice sharedManager] screenSize].height/2);
        }
    }
    [UIView commitAnimations];
}
@end
