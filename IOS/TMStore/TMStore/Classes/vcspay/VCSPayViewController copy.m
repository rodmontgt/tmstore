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
//    [self initilizeView];
//    [self buttonPayClicked:nil];
    return;
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
    [_textfield_date setTextContentType:UITextContentTypeTelephoneNumber];
    
    
    _label_cvv.text = _config.pp_card_cvv;
    if([_config.pp_card_cvv_hint isEqualToString:@"default_value"]){
        _textfield_cvv.placeholder = @"CVC";
    } else {
        _textfield_cvv.placeholder = _config.pp_card_cvv_hint;
    }
    [_textfield_cvv setSecureTextEntry:YES];
    
    
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
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _activityIndicator.center = self.view.center;
}
- (void)cancel:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
- (void)VCSPayPaymentViewController:(VCSPayViewController *)controller didFinish:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
    if (error) {
        [_responseDelegate postCompletionCallbackWithFailure:error];
    } else {
        [_responseDelegate postCompletionCallbackWithSuccess:nil];
    }
}
- (IBAction)buttonPayClicked:(id)sender {
//    if (
//        ![_textfield_name.text isEqualToString:@""] &&
//        ![_textfield_number.text isEqualToString:@""] &&
//        ![_textfield_date.text isEqualToString:@""] &&
//        ![_textfield_cvv.text isEqualToString:@""] /*&&
//                                                    ![_textfield_zip.text isEqualToString:@""]*/
//        )
    if(1)
    {

//        NSMutableDictionary* params0 = [[NSMutableDictionary alloc] init];
//        [params0 setValue:requestData0 forKey:@"xmlMessage"];
        
//        NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
//        [params setValue:requestData forKey:@"xmlMessage"];
        
//        NSError* err;
//        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:params0 options:0 error:&err];
//        NSString* myString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//        NSLog(@"%@",myString);
//        NSString* requestData = myString;
        
        
//        NSData *postData = [requestData dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
//        NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
//        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
//        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",_serverUrl]]];
//        [request setHTTPMethod:@"POST"];
//        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
//        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Current-Type"];
//        [request setHTTPBody:postData];
//        [request addValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
//        xmlMessage
        //prepare request
//        NSString *urlString = _serverUrl;
//        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
//        [request setURL:[NSURL URLWithString:urlString]];
//        [request setHTTPMethod:@"POST"];

        //set headers
//        NSString *contentType = [NSString stringWithFormat:@"text/xml"];
//        [request addValue:contentType forHTTPHeaderField: @"Content-Type"];

        //create the body
//        NSMutableData *postBody = [NSMutableData data];
//        [postBody appendData:[requestData dataUsingEncoding:NSUTF8StringEncoding]];
//        [postBody appendData:[[NSString stringWithFormat:@"<xml>"] dataUsingEncoding:NSUTF8StringEncoding]];
//        [postBody appendData:[[NSString stringWithFormat:@"<yourcode/>"] dataUsingEncoding:NSUTF8StringEncoding]];
//        [postBody appendData:[[NSString stringWithFormat:@"</xml>"] dataUsingEncoding:NSUTF8StringEncoding]];

        //post
//        [request setHTTPBody:postBody];
        
        
        
        
        
        //get response
//        NSHTTPURLResponse* urlResponse;
//        NSError* error;
//        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
//        NSString *result = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
//        NSLog(@"Response Code: %ld", (long)[urlResponse statusCode]);
//        if ([urlResponse statusCode] >= 200 && [urlResponse statusCode] < 300) {
//            NSLog(@"Response: %@", result); 
//            //here you get the response 
//        }
        
        
        
        NSString* requestData = [self getRequestData];
        NSMutableDictionary* paramsMutable = [[NSMutableDictionary alloc] init];
        [paramsMutable setObject:requestData forKey:@"xmlMessage"];
        NSDictionary* params = [[NSDictionary alloc] initWithDictionary:paramsMutable];
        NSString* serverUrl = [NSString stringWithFormat:@"%@", _serverUrl];
        NSLog(@"params:%@", params);
        NSLog(@"serverUrl:%@", serverUrl);
        
        
        
//        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
//        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//        manager.securityPolicy.allowInvalidCertificates = YES;
//        manager.securityPolicy.validatesDomainName = NO;
//        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html",@"text/plain", @"text/xml", nil];
        
        
        
        
//        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
//        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//        manager.securityPolicy.allowInvalidCertificates = YES;
//        manager.securityPolicy.validatesDomainName = NO;
//        manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
//        [manager POST:serverUrl parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
//            
//        } progress:^(NSProgress * _Nonnull uploadProgress) {
//            
//        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//            id array = [Utility getJsonArray:responseObject];
//            id json = [Utility getJsonObject:responseObject];
//            
//            NSLog(@"");
//        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//            NSLog(@"");
//        }];
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        manager.securityPolicy.allowInvalidCertificates = YES;
        manager.securityPolicy.validatesDomainName = NO;
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html",@"text/plain", nil];
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [manager.requestSerializer setValue:[[Utility sharedManager] getUserAgent] forHTTPHeaderField:@"User-Agent"];
        [manager POST:serverUrl parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            id array = [Utility getJsonArray:responseObject];
            id json = [Utility getJsonObject:responseObject];
            
            NSLog(@"");
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"");
        }];
        
        
//        [manager POST:_serverUrl parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
//        } progress:^(NSProgress * _Nonnull uploadProgress) {
//        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//            id array = [Utility getJsonArray:responseObject];
//            id json = [Utility getJsonObject:responseObject];
//
//            NSLog(@"");
//        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//            NSLog(@"");
//        }];
        
//        AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] init];
//        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//        manager.responseSerializer.acceptableContentTypes =  [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/xml"];
//        NSURLSessionDataTask *task = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
//            NSString *fetchedXML = [[NSString alloc] initWithData:(NSData *)responseObject encoding:NSUTF8StringEncoding];
//            NSLog(@"Response string: %@",fetchedXML);
//        }];
//        [task resume];
    } else {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"" message:_config.pp_all_fields_are_mendatory delegate:self cancelButtonTitle:_config.button_ok_title otherButtonTitles:nil, nil];
        [alertView show];
    }
    
}
- (NSString*)getRequestData {
    VCSPayConfig* config = [VCSPayConfig sharedManager];
    NSString* mMerchantId = config.cMerchantId;
    NSString* mReference = [self randomStringWithLength:25];
    NSString* mDescription = config.infoDescription;
    NSString* mAmount = config.infoCurrencyString;
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
    
    
    
    
    mMerchantId = @"3958";
    mReference = [self randomStringWithLength:25];
    mDescription = @"Goods";
    mAmount = @"10.0";
    mCurrency = @"bwp";
    mCardHolder = @"TMStore";
    mCardNumber = @"4242424242424242";
    mExpiryYear = @"18";
    mExpiryMonth = @"01";
    mCardCVC = @"123";


    NSMutableString *xml = [[NSMutableString alloc] initWithString:@""];
    [xml appendString:@"<?xml version='1.0' encoding='utf-8'?>"];
    [xml appendString:@"<AuthorisationRequest>"];
    [xml appendString:[NSString stringWithFormat:@"<UserId>%@</UserId>", mMerchantId]];
    [xml appendString:[NSString stringWithFormat:@"<Reference>%@</Reference>", mReference]];
    [xml appendString:[NSString stringWithFormat:@"<Description>%@</Description>", mDescription]];
    [xml appendString:[NSString stringWithFormat:@"<Amount>%@</Amount>", mAmount]];
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
- (void)operationResult:(BOOL)success{
    [PaymentUtility stopGrayLoadingBar];
    [_activityIndicator  stopAnimating];
    [self dismissViewControllerAnimated:YES completion:nil];
    if (success) {
        [_responseDelegate postCompletionCallbackWithSuccess:nil];
    } else {
        [_responseDelegate postCompletionCallbackWithFailure:nil];
    }
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
NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

- (NSString *)randomStringWithLength:(int)len {
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity:len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform([letters length])]];
    }
    
    return randomString;
}


- (NSString*)makeParamtersString:(NSDictionary*)parameters withEncoding:(NSStringEncoding)encoding
{
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

- (NSString *)URLEscaped:(NSString *)strIn withEncoding:(NSStringEncoding)encoding
{
    CFStringRef escaped = CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)strIn, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", CFStringConvertNSStringEncodingToEncoding(encoding));
    NSString *strOut = [NSString stringWithString:(__bridge NSString *)escaped];
    CFRelease(escaped);
    return strOut;
}
@end
