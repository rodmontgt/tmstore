//
//  LoginFlow.m
//
//  Created by Rishabh Jain on 25/01/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import "LoginFlow.h"
#import "Variables.h"
#import "ParseHelper.h"
#if (ENABLE_SIMPLEAUTH)
#import <SimpleAuth/SimpleAuth.h>
#endif
#import <Accounts/Accounts.h>
#import "UIAlertView+NSCookbook.h"
#define errorEmailNotFound Localize(@"email_not_found")
#define errorInsufficientData Localize(@"insufficient_data")
#import "AppDelegate.h"
@implementation LoginFlow

+ (id)sharedManager {
    static LoginFlow *shareLoginFlowManager = nil;
    @synchronized(self) {
        if (shareLoginFlowManager == nil)
            shareLoginFlowManager = [[self alloc] init];
    }
    return shareLoginFlowManager;
}
- (id)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(responseLogoutClicked:) name:@"response_logout_clicked" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(responseLoginClicked:) name:@"response_login_clicked" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(responseRegisterClicked:) name:@"response_register_clicked" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(forgetPassword:) name:@"response_forgot_password_clicked" object:nil];
        _tempServerData = nil;
        _appUser = nil;
        _tempUserName = @"";
        _tempUserPassword = @"";
        _tempUserEmail = @"";
        _tempUserImage = @"";
        _tempUserLoginProvider = @"";
        _tempUserMobileNumber = @"";
        _tempUserRole = @"";
        _tempUserFirstName = @"";
        _tempUserLastName = @"";
        _tempUserCompanyName = @"";
        _isUserExistOnStore = false;
        _isUserAuthenticatedOnStore = false;
        _isUserExistOnParse = false;
        _isUserLoggedIn = false;
        _isSocialLogin = false;
        _isRegistration = false;
        _userNickName = @"";
        _userImage = @"";
//        [[[[DataManager sharedManager] tmDataDoctor] tmMulticastDelegate] addDelegate:self];
    }
    return self;
}
- (void)responseForgotPassword:(NSNotification *)notification {
    [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
    [MRProgressOverlayView showOverlayAddedTo:[[UIApplication sharedApplication] keyWindow] title:@"" mode:MRProgressOverlayViewModeIndeterminateSmallDefault animated:YES];
    
    _isRegistration = true;
    NSMutableDictionary* dictionary =  [notification object];
    NSString* userEmailId = [dictionary objectForKey:@"email"];
    NSDictionary *params = nil;
    NSString* storeLink = @"";
    params = @{
               @"user_emailID": [[userEmailId dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0],
               @"user_platform": [[@"IOS" dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0]};
    //    storeLink = @"http://twistmobile.in/wordpress_version_new/wordpress/wp-tm-store-notify/api/forget-password/";
//    storeLink = @"http://playcontest.in/ankur_worldpress_test/wordpress/wp-tm-store-notify/api/forget-password/";
    
    storeLink = [NSString stringWithFormat:@"%@/wp-tm-store-notify/api/forget-password/",  [[[DataManager sharedManager] tmDataDoctor] baseUrl] ];
    RLOG(@"storeLink = %@", storeLink);
    
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    [manager POST:storeLink parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
        
        NSDictionary *json_dict = [Utility getJsonObject:responseObject];
        if (json_dict == nil) {
            RLOG(@"No data received / Invalid Json");
        } else {
            RLOG(@"json_dict: %@", json_dict);
            NSString* errorStr = [json_dict valueForKey:@"error"];
            NSString* messageStr = [json_dict valueForKey:@"message"];
            NSString* statusStr = [json_dict valueForKey:@"status"];
            
            if ([statusStr isEqualToString:@"success"]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ResetPasswordSentSuccess" object:nil];
            }
            
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                            message:Localize(messageStr)
                                                           delegate:self
                                                  cancelButtonTitle:Localize(@"i_cok")
                                                  otherButtonTitles:nil];
            [alert show];
            
            
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        RLOG(@"\n==Error = %@\n\n", error);
        NSInteger statusCode = 0;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = httpResponse.statusCode;
        }        RLOG(@"Error: %@", error);
//        [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
//                                                        message:@"Try again later!"
//                                                       delegate:self
//                                              cancelButtonTitle:@"OK"
//                                              otherButtonTitles:nil];
//        [alert show];
        

        if(statusCode == 404) {
            [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Localize(@"oops") message:Localize(@"generic_error") delegate:nil cancelButtonTitle:Localize(@"cancel") otherButtonTitles:Localize(@"retry"), nil];;
            [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if ((int)buttonIndex == 0) {
                    
                } else {
                    [self responseForgotPassword:notification];
                }
            }];
        } else {
            [self responseForgotPassword:notification];
        }
    }];
    
    
    
}
- (void)responseLogoutClicked:(NSNotification *)notification{
    _tempUserName = @"";
    _tempUserPassword = @"";
    _tempUserEmail = @"";
    _tempUserImage = @"";
    _tempUserLoginProvider = @"";
    _tempUserMobileNumber = @"";
    _tempUserRole = @"";
    _tempUserFirstName = @"";
    _tempUserLastName = @"";
    _tempUserCompanyName = @"";
    _isUserExistOnStore = false;
    _isUserAuthenticatedOnStore = false;
    _isUserExistOnParse = false;
    _isUserLoggedIn = false;
    _isSocialLogin = false;
    _isRegistration = false;
}
- (void)responseRegisterClicked:(NSNotification *)notification {
    _isRegistration = true;
    NSMutableDictionary* dictionary =  [notification object];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"response_login_clicked" object:dictionary];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(RegistrationFailed:) name:@"RegistrationFailed" object:nil];
}
- (void)RegistrationFailed:(NSNotification *)notification {
    _tempServerData = nil;
    _appUser = nil;
    _tempUserName = @"";
    _tempUserPassword = @"";
    _tempUserEmail = @"";
    _tempUserImage = @"";
    _tempUserLoginProvider = @"";
    _tempUserMobileNumber = @"";
    _tempUserRole = @"";
    _tempUserFirstName = @"";
    _tempUserLastName = @"";
    _tempUserCompanyName = @"";
    _isUserExistOnStore = false;
    _isUserAuthenticatedOnStore = false;
    _isUserExistOnParse = false;
    _isUserLoggedIn = false;
    _isSocialLogin = false;
    _isRegistration = false;
    _userNickName = @"";
    _userImage = @"";
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LoginSuccessful" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LoginFailed" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RegistrationFailed" object:nil];
    
    [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
    
    NSMutableDictionary* dictionary =  [notification object];
    NSString* description = [dictionary objectForKey:@"description"];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Localize(@"register_failed")
                                                    message:Localize(description)
                                                   delegate:self
                                          cancelButtonTitle:Localize(@"i_cok")
                                          otherButtonTitles:nil];
    [alert show];
}
- (void)responseLoginClicked:(NSNotification *)notification {
    NSMutableDictionary* dictionary =  [notification object];
    NSString* userName = [dictionary objectForKey:@"name"];
    NSString* firstName = [dictionary objectForKey:@"first_name"];
    NSString* lastName = [dictionary objectForKey:@"last_name"];
    NSString* userImagePath = [dictionary objectForKey:@"image"];
    NSString* userEmailId = [dictionary objectForKey:@"email"];
    NSString* loginProvider = [dictionary objectForKey:@"provider"];
    NSString* userPassword = [dictionary objectForKey:@"password"];
    NSString* mobileNumber = @"";
    if (IS_NOT_NULL(dictionary, @"mobile_number")) {
        mobileNumber = [dictionary objectForKey:@"mobile_number"];
    }
    NSString* shopName = [dictionary objectForKey:@"shop_name"];
    NSString* userRole = @"";
    if (IS_NOT_NULL(dictionary, @"user_role")) {
        userRole = [dictionary objectForKey:@"user_role"];
    }
    

    RLOG(@"userName=%@", userName);
    RLOG(@"firstName=%@", firstName);
    RLOG(@"lastName=%@", lastName);
    RLOG(@"userImagePath=%@", userImagePath);
    RLOG(@"userEmailId=%@", userEmailId);
    RLOG(@"loginProvider=%@", loginProvider);
    RLOG(@"userPassword=%@", userPassword);
    RLOG(@"mobileNumber=%@", mobileNumber);
    RLOG(@"shopName=%@", shopName);
    RLOG(@"userRole=%@", userRole);
    
    
    _appUser = [AppUser sharedManager];
    
    _userNickName = userName;
    _userImage = userImagePath;
    
    _tempUserName = userName;
    _tempUserLastName = lastName;
    _tempUserFirstName = firstName;
    _tempUserPassword = userPassword;
    _tempUserEmail = userEmailId;
    _tempUserImage = userImagePath;
    _tempUserLoginProvider = loginProvider;
    _tempUserMobileNumber = mobileNumber;
    _tempUserCompanyName = shopName;
    _tempUserRole = userRole;
    
    if (_isRegistration) {
        _isSocialLogin = false;
        [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
        [MRProgressOverlayView showOverlayAddedTo:[[UIApplication sharedApplication] keyWindow] title:@"" mode:MRProgressOverlayViewModeIndeterminateSmallDefault animated:YES];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticateUser:) name:@"LoginSuccessful" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticateUser:) name:@"LoginFailed" object:nil];
        ServerData *sData = [[ServerData alloc] init];
        sData._serverDataId = kFetchCustomer;
        sData._serverRequestStatus = kServerRequestFailed;
        [[[[DataManager sharedManager] tmDataDoctor] tmMulticastDelegate] respondToDelegates:sData];
    } else if ([_tempUserLoginProvider isEqualToString:SA_PROVIDERS_NAME[SA_PROVIDERS_STORE]]) {
        _isSocialLogin = false;
        [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
        [MRProgressOverlayView showOverlayAddedTo:[[UIApplication sharedApplication] keyWindow] title:@"" mode:MRProgressOverlayViewModeIndeterminateSmallDefault animated:YES];
        [self authenticatingUser];
    } else {
        _isSocialLogin = true;
        [self authenticatingUser];
    }
}
- (void)authenticateUser:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LoginSuccessful" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LoginFailed" object:nil];
    [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
    if ([[notification name] isEqualToString:@"LoginSuccessful"]){
        RLOG (@"LoginSuccessful");
        NSString *serverUrl = [NSString stringWithFormat:@"%@/email/%@", [[[DataManager sharedManager] tmDataDoctor] request_url_customer], _tempUserEmail];
        NSString* dictionaryString = [[NSUserDefaults standardUserDefaults] valueForKey:serverUrl];
        [[DataManager sharedManager] loadCustomerData:[dictionaryString json_StringToDictionary]];
        
        for (int i = 0; i < SA_PROVIDERS_TOTAL; i++) {
            if ([_tempUserLoginProvider isEqualToString:SA_PROVIDERS_NAME[i]]) {
                _appUser._userLoggedInVia = i;
                if(_tempUserPassword){
                    _appUser._password = _tempUserPassword;
                }
                break;
            }
        }
        if ([_appUser._first_name isEqualToString:@""]) {
            if(_tempUserFirstName){
                _appUser._first_name = [NSString stringWithFormat:@"%@", _tempUserFirstName];
            }
        }
        if ([_appUser._last_name isEqualToString:@""]) {
            if(_tempUserLastName){
            _appUser._last_name = [NSString stringWithFormat:@"%@", _tempUserLastName];
            }
        }
        if ([_appUser._mobile_number isEqualToString:@""]) {
            if(_tempUserMobileNumber){
                _appUser._mobile_number = [NSString stringWithFormat:@"%@", _tempUserMobileNumber];
            }
        }
        _isUserLoggedIn = true;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginCompleted" object:self];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginCompletedCart" object:self];
    }
    if ([[notification name] isEqualToString:@"LoginFailed"]){
        RLOG (@"LoginFailed");
        NSString* description = Localize(@"oops");
        if ([notification object]) {
            NSMutableDictionary* dictionary =  [notification object];
            if(dictionary)
                description = [dictionary objectForKey:@"description"];
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Localize(@"login_failed") message:Localize(description) delegate:self cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil];
        [alert show];
        _userNickName = @"";
        _userImage = @"";
    }
}
- (void)authenticatingUser {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticateUser:) name:@"LoginSuccessful" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticateUser:) name:@"LoginFailed" object:nil];
    _tempServerData = [[DataManager sharedManager] fetchCustomerData:nil userEmail:_tempUserEmail];
}

- (void)relogIn {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticateUser:) name:@"LoginSuccessful" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticateUser:) name:@"LoginFailed" object:nil];
    _appUser = [AppUser sharedManager];
    _userNickName = _appUser._username;
    _userImage = _appUser._avatar_url;
    _tempUserName = _appUser._username;
    _tempUserPassword = _appUser._password;
    _tempUserEmail = _appUser._email;
    _tempUserImage = _appUser._avatar_url;
    _tempUserLoginProvider = SA_PROVIDERS_NAME[_appUser._userLoggedInVia];
    _isRegistration = false;
    _isSocialLogin = false;
    if (![_tempUserLoginProvider isEqualToString:SA_PROVIDERS_NAME[SA_PROVIDERS_STORE]]) {
        _isSocialLogin = true;
    }
    
    _tempServerData = [[DataManager sharedManager] fetchCustomerData:nil userEmail:_appUser._email];
}

#if (ENABLE_SIMPLEAUTH)
- (void)configureAuthorizaionProviders:(int)itemType {
    DataManager* dm = [DataManager sharedManager];
    switch (itemType) {
        case SA_PROVIDERS_FACEBOOK:
        {
            // app_id is required
            SimpleAuth.configuration[SA_PROVIDERS_NAME[SA_PROVIDERS_FACEBOOK]] = @{@"app_id":dm.keyFacebookAppId, @"consumer_secret":dm.keyFacebookConsumerSecret};
        }
            break;
        case SA_PROVIDERS_FACEBOOK_WEB:
        {
            // app_id is required
            SimpleAuth.configuration[SA_PROVIDERS_NAME[SA_PROVIDERS_FACEBOOK_WEB]] = @{@"app_id":dm.keyFacebookAppId, @"app_secret":dm.keyFacebookConsumerSecret};
        }
            break;
        case SA_PROVIDERS_TWITTER:
        {
            // consumer_key and consumer_secret are required
            SimpleAuth.configuration[SA_PROVIDERS_NAME[SA_PROVIDERS_TWITTER]] = @{@"consumer_key":dm.keyTwitterConsumerKey, @"consumer_secret":dm.keyTwitterConsumerSecret};
        }
            break;
        case SA_PROVIDERS_TWITTER_WEB:
        {
            SimpleAuth.configuration[SA_PROVIDERS_NAME[SA_PROVIDERS_TWITTER_WEB]] = @{@"consumer_key":dm.keyTwitterConsumerKey, @"consumer_secret":dm.keyTwitterConsumerSecret};
        }
            break;
        case SA_PROVIDERS_GOOGLE_WEB:
        {
// client_id and client_secret are required
            SimpleAuth.configuration[SA_PROVIDERS_NAME[SA_PROVIDERS_GOOGLE_WEB]] = @{ @"client_id":dm.keyGoogleClientId, @"client_secret":dm.keyGoogleClientSecret};
//            SimpleAuth.configuration[SA_PROVIDERS_NAME[SA_PROVIDERS_GOOGLE_WEB]] = @{ @"client_id":@"785717206448-9dap52jiijecpgqeei2vq4firfmplvf1.apps.googleusercontent.com", @"client_secret":@"jL-5lmJxQgdD2dCR3nZ51fqv"};
//            SimpleAuth.configuration[SA_PROVIDERS_NAME[SA_PROVIDERS_GOOGLE_WEB]] = @{ @"client_id":@"848168438665-mma2mun5fb9ru668hq7v88muaontfqs0.apps.googleusercontent.com", @"client_secret":@"_-UasjRKYL_w0pTOS9L4cuxB"};
        }
            break;
            
        default:
            break;
    }
}
- (void)clickOnSimpleAuthItem:(int)itemType {
    [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
    
    NSString* errorMessage = @"";
    NSString* errorTitle = @"";
    
    switch (itemType) {
        case SA_PROVIDERS_FACEBOOK:
        {
            [MRProgressOverlayView showOverlayAddedTo:[[UIApplication sharedApplication] keyWindow] title:@"" mode:MRProgressOverlayViewModeIndeterminateSmallDefault animated:YES];
            [SimpleAuth authorize:SA_PROVIDERS_NAME[SA_PROVIDERS_FACEBOOK] completion:^(id responseObject, NSError *error) {
                if (error == nil) {
                    NSDictionary* infoDictionary = (NSDictionary*)[responseObject objectForKey:@"info"];
                    if (infoDictionary) {
                        NSString* uid = [responseObject objectForKey:@"uid"];
                        NSString* userImagePath = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=square", uid];
                        NSString* userName = [infoDictionary objectForKey:@"name"];
                        NSString* firstName = @"";
                        NSString* lastName = @"";
                        NSString* userEmailId = [self createEmailId:@"facebook" uid:uid emailID:[infoDictionary objectForKey:@"email"]];
                        if ([infoDictionary objectForKey:@"first_name"] && ![[infoDictionary objectForKey:@"first_name"] isEqualToString:@""]) {
                            firstName = [infoDictionary objectForKey:@"first_name"];
                        }
                        if ([infoDictionary objectForKey:@"last_name"] && ![[infoDictionary objectForKey:@"last_name"] isEqualToString:@""]) {
                            lastName = [infoDictionary objectForKey:@"last_name"];
                        }
                        if(userName && userImagePath && userEmailId){
                            RLOG(@"Sufficient data received.");
                            NSMutableDictionary* dataDictionary = [[NSMutableDictionary alloc] init];
                            [dataDictionary setObject:@"" forKey:@"password"];
                            [dataDictionary setObject:userName forKey:@"name"];
                            [dataDictionary setObject:firstName forKey:@"first_name"];
                            [dataDictionary setObject:lastName forKey:@"last_name"];
                            [dataDictionary setObject:userImagePath forKey:@"image"];
                            [dataDictionary setObject:userEmailId forKey:@"email"];
                            [dataDictionary setObject:SA_PROVIDERS_NAME[SA_PROVIDERS_FACEBOOK] forKey:@"provider"];
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"response_login_clicked" object:dataDictionary];
                        }
                        else {
                            [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Localize(@"login_failed") message:errorEmailNotFound delegate:self cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil];
                            [alert show];
                        }
                    }
                    else{
                        [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Localize(@"login_failed") message:errorInsufficientData delegate:self cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil];
                        [alert show];
                    }
                } else {
                    RLOG(@"Error in fetching data: %@", error);
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"TRY_FOR_FACEBOOK_WEB" object:nil];
                }
            }];
        }break;
        case SA_PROVIDERS_FACEBOOK_WEB:
        {
            [SimpleAuth authorize:SA_PROVIDERS_NAME[SA_PROVIDERS_FACEBOOK_WEB] completion:^(id responseObject, NSError *error) {
                [MRProgressOverlayView showOverlayAddedTo:[[UIApplication sharedApplication] keyWindow] title:@"" mode:MRProgressOverlayViewModeIndeterminateSmallDefault animated:YES];
                
                RLOG(@"\n SA_PROVIDERS_FACEBOOK_WEB Response: %@\nError:%@", responseObject, error);
                RLOG(@"SA_PROVIDERS_FACEBOOK_WEB RESPONSE");
                if (error == nil) {
                    NSDictionary* infoDictionary = (NSDictionary*)[responseObject objectForKey:@"info"];
                    if (infoDictionary) {
                        NSString* uid = [responseObject objectForKey:@"uid"];
                        NSString* userImagePath = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=square", uid];
                        NSString* userName = [infoDictionary objectForKey:@"name"];
                        NSString* firstName = @"";
                        NSString* lastName = @"";
                        NSString* userEmailId = [self createEmailId:@"facebook" uid:uid emailID:[infoDictionary objectForKey:@"email"]];
                        if ([infoDictionary objectForKey:@"first_name"] && ![[infoDictionary objectForKey:@"first_name"] isEqualToString:@""]) {
                            firstName = [infoDictionary objectForKey:@"first_name"];
                        }
                        if ([infoDictionary objectForKey:@"last_name"] && ![[infoDictionary objectForKey:@"last_name"] isEqualToString:@""]) {
                            lastName = [infoDictionary objectForKey:@"last_name"];
                        }
                        
                        
                        if(userName && userImagePath && userEmailId){
                            RLOG(@"Sufficient data received.");
                            NSMutableDictionary* dataDictionary = [[NSMutableDictionary alloc] init];
                            [dataDictionary setObject:@"" forKey:@"password"];
                            [dataDictionary setObject:userName forKey:@"name"];
                            [dataDictionary setObject:firstName forKey:@"first_name"];
                            [dataDictionary setObject:lastName forKey:@"last_name"];
                            [dataDictionary setObject:userImagePath forKey:@"image"];
                            [dataDictionary setObject:userEmailId forKey:@"email"];
                            [dataDictionary setObject:SA_PROVIDERS_NAME[SA_PROVIDERS_FACEBOOK_WEB] forKey:@"provider"];
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"response_login_clicked" object:dataDictionary];
                        }
                        else {
                            [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Localize(@"login_failed") message:errorEmailNotFound delegate:self cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil];
                            [alert show];
                        }
                    }
                    else {
                        [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Localize(@"login_failed") message:errorInsufficientData delegate:self cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil];
                        [alert show];
                    }
                } else {
                    RLOG(@"Error in fetching data: %@", error);
                    [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
                    if([error code] == ACErrorAccountNotFound) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Localize(@"account_not_found") message:Localize(@"setup_account") delegate:self cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil];
                        [alert show];
                    } else {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:Localize(@"try_again") delegate:self cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil];
                        [alert show];
                    }
                }
            }];
        }break;
        case SA_PROVIDERS_TWITTER:
        {
            [MRProgressOverlayView showOverlayAddedTo:[[UIApplication sharedApplication] keyWindow] title:@"" mode:MRProgressOverlayViewModeIndeterminateSmallDefault animated:YES];
            [SimpleAuth authorize:SA_PROVIDERS_NAME[SA_PROVIDERS_TWITTER] completion:^(id responseObject, NSError *error) {
                RLOG(@"\n SA_PROVIDERS_TWITTER Response: %@\nError:%@", responseObject, error);
                RLOG(@"SA_PROVIDERS_TWITTER RESPONSE");
                if (error == nil) {
                    NSDictionary* infoDictionary = (NSDictionary*)[responseObject objectForKey:@"info"];
                    if (infoDictionary) {
                        NSString* uid = [responseObject objectForKey:@"uid"];
                        NSString* userImagePath = [infoDictionary objectForKey:@"image"];
                        NSString* userName = [infoDictionary objectForKey:@"name"];
                        NSString* firstName = @"";
                        NSString* lastName = @"";
                        NSString* userEmailId = [self createEmailId:@"twitter" uid:uid emailID:[infoDictionary objectForKey:@"email"]];
                        if ([infoDictionary objectForKey:@"first_name"] && ![[infoDictionary objectForKey:@"first_name"] isEqualToString:@""]) {
                            firstName = [infoDictionary objectForKey:@"first_name"];
                        }
                        if ([infoDictionary objectForKey:@"last_name"] && ![[infoDictionary objectForKey:@"last_name"] isEqualToString:@""]) {
                            lastName = [infoDictionary objectForKey:@"last_name"];
                        }
                        if(userName && userImagePath && userEmailId){
                            RLOG(@"Sufficient data received.");
                            NSMutableDictionary* dataDictionary = [[NSMutableDictionary alloc] init];
                            [dataDictionary setObject:@"" forKey:@"password"];
                            [dataDictionary setObject:userName forKey:@"name"];
                            [dataDictionary setObject:firstName forKey:@"first_name"];
                            [dataDictionary setObject:lastName forKey:@"last_name"];
                            
                            [dataDictionary setObject:userImagePath forKey:@"image"];
                            [dataDictionary setObject:userEmailId forKey:@"email"];
                            [dataDictionary setObject:SA_PROVIDERS_NAME[SA_PROVIDERS_TWITTER] forKey:@"provider"];
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"response_login_clicked" object:dataDictionary];
                        }
                        else {
                            [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Localize(@"login_failed") message:errorEmailNotFound delegate:self cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil];
                            [alert show];
                        }
                    }
                    else {
                        [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Localize(@"login_failed") message:errorInsufficientData delegate:self cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil];
                        [alert show];
                    }
                } else {
                    RLOG(@"Error in fetching data: %@", error);
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"TRY_FOR_TWITTER_WEB" object:nil];
                }
            }];
        }break;
        case SA_PROVIDERS_TWITTER_WEB:
        {
            [SimpleAuth authorize:SA_PROVIDERS_NAME[SA_PROVIDERS_TWITTER_WEB] completion:^(id responseObject, NSError *error) {
                if (error == nil) {
                    [MRProgressOverlayView showOverlayAddedTo:[[UIApplication sharedApplication] keyWindow] title:@"" mode:MRProgressOverlayViewModeIndeterminateSmallDefault animated:YES];
                    NSDictionary* infoDictionary = (NSDictionary*)[responseObject objectForKey:@"info"];
                    if (infoDictionary) {
                        NSString* uid = [responseObject objectForKey:@"uid"];
                        NSString* userImagePath = [infoDictionary objectForKey:@"image"];
                        NSString* userName = [infoDictionary objectForKey:@"name"];
                        NSString* firstName = @"";
                        NSString* lastName = @"";
                        NSString* userEmailId = [self createEmailId:@"twitter" uid:uid emailID:[infoDictionary objectForKey:@"email"]];
                        if ([infoDictionary objectForKey:@"first_name"] && ![[infoDictionary objectForKey:@"first_name"] isEqualToString:@""]) {
                            firstName = [infoDictionary objectForKey:@"first_name"];
                        }
                        if ([infoDictionary objectForKey:@"last_name"] && ![[infoDictionary objectForKey:@"last_name"] isEqualToString:@""]) {
                            lastName = [infoDictionary objectForKey:@"last_name"];
                        }
                        if(userName && userImagePath && userEmailId){
                            RLOG(@"Sufficient data received.");
                            NSMutableDictionary* dataDictionary = [[NSMutableDictionary alloc] init];
                            [dataDictionary setObject:@"" forKey:@"password"];
                            [dataDictionary setObject:userName forKey:@"name"];
                            [dataDictionary setObject:firstName forKey:@"first_name"];
                            [dataDictionary setObject:lastName forKey:@"last_name"];
                            [dataDictionary setObject:userImagePath forKey:@"image"];
                            [dataDictionary setObject:userEmailId forKey:@"email"];
                            [dataDictionary setObject:SA_PROVIDERS_NAME[SA_PROVIDERS_TWITTER_WEB] forKey:@"provider"];
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"response_login_clicked" object:dataDictionary];
                        }
                        else {
                            [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Localize(@"login_failed") message:errorEmailNotFound delegate:self cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil];
                            [alert show];
                        }
                    }
                    else {
                        [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Localize(@"login_failed") message:errorInsufficientData delegate:self cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil];
                        [alert show];
                    }
                }
                else {
                    RLOG(@"Error in fetching data: %@", error);
                    [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
                    if([error code] == ACErrorAccountNotFound) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Localize(@"account_not_found") message:Localize(@"setup_account") delegate:self cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil];
                        [alert show];
                    } else {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:Localize(@"try_again") delegate:self cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil];
                        [alert show];
                    }
                }
            }];
        }break;
        case SA_PROVIDERS_GOOGLE_WEB:
        {
            [SimpleAuth authorize:SA_PROVIDERS_NAME[SA_PROVIDERS_GOOGLE_WEB] completion:^(id responseObject, NSError *error) {
                RLOG(@"\n SA_PROVIDERS_GOOGLE_WEB Response: %@\nError:%@", responseObject, error);
                if (error == nil) {
                    [MRProgressOverlayView showOverlayAddedTo:[[UIApplication sharedApplication] keyWindow] title:@"" mode:MRProgressOverlayViewModeIndeterminateSmallDefault animated:YES];
                    NSDictionary* infoDictionary = (NSDictionary*)[responseObject objectForKey:@"info"];
                    if (infoDictionary) {
                        NSString* userImagePath = @"";
                        NSString* userName = @"";
                        NSString* firstName = @"";
                        NSString* lastName = @"";
                        NSString* userEmailId = @"";
                        
                        if ([infoDictionary objectForKey:@"name"] && ![[infoDictionary objectForKey:@"name"] isEqualToString:@""]) {
                            userImagePath = [infoDictionary objectForKey:@"name"];
                        }
                        if ([infoDictionary objectForKey:@"image"] && ![[infoDictionary objectForKey:@"image"] isEqualToString:@""]) {
                            userImagePath = [infoDictionary objectForKey:@"image"];
                        }
                        if ([infoDictionary objectForKey:@"first_name"] && ![[infoDictionary objectForKey:@"first_name"] isEqualToString:@""]) {
                            firstName = [infoDictionary objectForKey:@"first_name"];
                        }
                        if ([infoDictionary objectForKey:@"last_name"] && ![[infoDictionary objectForKey:@"last_name"] isEqualToString:@""]) {
                            lastName = [infoDictionary objectForKey:@"last_name"];
                        }
                        if ([infoDictionary objectForKey:@"email"] && ![[infoDictionary objectForKey:@"email"] isEqualToString:@""]) {
                            userEmailId = [infoDictionary objectForKey:@"email"];
                        }
                        
                        
                        if(userName && userImagePath && userEmailId){
                            RLOG(@"Sufficient data received.");
                            NSMutableDictionary* dataDictionary = [[NSMutableDictionary alloc] init];
                            [dataDictionary setObject:@"" forKey:@"password"];
                            [dataDictionary setObject:userName forKey:@"name"];
                            [dataDictionary setObject:firstName forKey:@"first_name"];
                            [dataDictionary setObject:lastName forKey:@"last_name"];
                            [dataDictionary setObject:userImagePath forKey:@"image"];
                            [dataDictionary setObject:userEmailId forKey:@"email"];
                            [dataDictionary setObject:SA_PROVIDERS_NAME[SA_PROVIDERS_GOOGLE_WEB] forKey:@"provider"];
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"response_login_clicked" object:dataDictionary];
                        }
                        else {
                            [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Localize(@"login_failed") message:errorEmailNotFound delegate:self cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil];
                            [alert show];
                        }
                    }
                    else {
                        [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Localize(@"login_failed") message:errorInsufficientData delegate:self cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil];
                        [alert show];
                    }
                }
                else {
                    RLOG(@"Error in fetching data: %@", error);
                    [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
//                    if([error code] == ACErrorAccountNotFound) {
//                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Account not found." message:@"Please setup your account in settings app." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                        [alert show];
//                    } else {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:Localize(@"try_again") delegate:self cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil];
                        [alert show];
//                    }
                }
            }];
        }break;
            
        default:
            break;
    }
    
    if ([errorMessage isEqualToString:@""] == false) {
        [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Localize(@"sorry") message:errorMessage delegate:self cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil];
        [alert show];
    }

}
#endif

-(void)dataFetchCompletion:(ServerData *)serverData{
    if (serverData._serverRequestStatus == kServerRequestSucceed) {
        RLOG(@"=======DATA_FETCHING:SUCCESS=======");
        RLOG(@"_serverUrl = %@",serverData._serverUrl);
        RLOG(@"_serverDataId = %d",serverData._serverDataId);
        //        RLOG(@"_serverRequestName = %@",serverData._serverRequestName);
        RLOG(@"_serverResultDictionary = %@",serverData._serverResultDictionary);
        NSError *error;
        if (serverData._serverResultDictionary == nil) {
            serverData._serverResultDictionary = [[NSMutableDictionary alloc] init];
        }
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:serverData._serverResultDictionary options:NSJSONWritingPrettyPrinted error:&error];
        if (!jsonData) {
            RLOG(@"Got an error: %@", error);
        } else {
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            RLOG(@"jsonString:%@", jsonString);
            [[NSUserDefaults standardUserDefaults] setObject:jsonString forKey:serverData._serverUrl];
        }
    }
    else if (serverData._serverRequestStatus == kServerRequestFailed) {
        switch (serverData._serverDataId) {
            case kFetchOrders:
            {
                RLOG(@"=======DATA_FETCHING:FAILED=======");
                RLOG(@"_serverUrl = %@",serverData._serverUrl);
                RLOG(@"_serverDataId = %d",serverData._serverDataId);
                //        RLOG(@"_serverRequestName = %@",serverData._serverRequestName);
                RLOG(@"_serverResultDictionary = %@",serverData._serverResultDictionary);
                NSString *jsonString = nil;
                if (CHECK_PRELOADED_DATA) {
                    jsonString = [[NSUserDefaults standardUserDefaults] objectForKey:serverData._serverUrl];
                }
                if (jsonString) {
                    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
                    if (data) {
                        id jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                        if (jsonDict) {
                            serverData._serverResultDictionary = (NSDictionary*) jsonDict;
                            if (serverData._serverResultDictionary) {
                                serverData._serverRequestStatus = kServerRequestSucceed;
                            }
                        }
                    }
                }
            }break;
            case kFetchCustomer:
            {
                if(_isUserAuthenticatedOnStore){
                    _tempServerData = [[DataManager sharedManager] fetchCustomerData:nil userEmail:_tempUserEmail];
                    return;
                }
            }break;
                
        }
    }
    if (serverData._serverRequestStatus == kServerRequestSucceed) {
        switch (serverData._serverDataId) {
            case kFetchCustomer:
            {
                NSDictionary* mainDict = nil;
                if (IS_NOT_NULL(serverData._serverResultDictionary, @"customer")) {
                    mainDict = [serverData._serverResultDictionary objectForKey:@"customer"];
                    if (IS_NOT_NULL(mainDict, @"username")) {
                        _tempUserName = GET_VALUE_STRING(mainDict, @"username");
                        _isUserExistOnStore = true;
                        [self loginOnStore];
                    }
                }
            }break;
            case kFetchOrders:
            {
                [[DataManager sharedManager] loadOrdersData: serverData._serverResultDictionary];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ProceedToOrderScreen" object:self];
            } break;
            default:
                break;
        }
    }
    else if(_isUserExistOnStore == false && serverData._serverDataId == kFetchCustomer) {
        if (_isSocialLogin || _isRegistration) {
            [self loginOnStore];
        }else {
            if (serverData.errorStr && ![serverData.errorStr isEqualToString:@""]) {
                NSMutableDictionary* dataDictionary = [[NSMutableDictionary alloc] init];
                [dataDictionary setObject:serverData.errorStr forKey:@"description"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginFailed" object:dataDictionary];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginFailed" object:nil];
            }
        }
    }
    else if (serverData._serverRequestStatus == kServerRequestFailed){
        if(serverData._serverDataId == kFetchOrders){
            _tempServerData =[[DataManager sharedManager] fetchOrdersData:nil];
        }
    }
}

- (void)loginOnStore{
    NSDictionary *params = nil;
    NSString* storeLink = @"";
    if (_isSocialLogin) {
        params = @{
                   @"user_emailID": [[_tempUserEmail dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0],
                   @"user_platform": [[@"IOS" dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0]};
//        storeLink = @"http://playcontest.in/ankur_worldpress_test/wordpress/wp-tm-store-notify/api/social-login/";
        storeLink = [NSString stringWithFormat:@"%@/wp-tm-store-notify/api/social-login/",  [[[DataManager sharedManager] tmDataDoctor] baseUrl] ];
        RLOG(@"storeLink = %@", storeLink);

    }
    else if(_isRegistration){
        if ([_tempUserRole isEqualToString:@""]) {
            params = @{@"user_name": [[_tempUserName dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0],
                       @"user_pass": [[_tempUserPassword dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0],
                       @"user_emailID": [[_tempUserEmail dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0],
                       @"user_platform": [[@"IOS" dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0]};
        } else {
            params = @{@"user_name": [[_tempUserName dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0],
                       @"user_pass": [[_tempUserPassword dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0],
                       @"user_emailID": [[_tempUserEmail dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0],
                       @"user_platform": [[@"IOS" dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0],
                       @"first_name": [[_tempUserFirstName dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0],
                       @"last_name": [[_tempUserLastName dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0],
                       @"shop_name": [[_tempUserCompanyName dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0],
                       @"phone": [[_tempUserMobileNumber dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0],
                       @"role": [[_tempUserRole dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0]};
        }
        
        
        
        
//        storeLink = @"http://playcontest.in/ankur_worldpress_test/wordpress/wp-tm-store-notify/api/register/";
        storeLink = [NSString stringWithFormat:@"%@/wp-tm-store-notify/api/register/",  [[[DataManager sharedManager] tmDataDoctor] baseUrl] ];
        RLOG(@"storeLink = %@", storeLink);
    }
    else {
        params = @{@"user_name": [[_tempUserName dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0],
                   @"user_pass": [[_tempUserPassword dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0],
                   @"user_emailID": [[_tempUserEmail dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0],
                   @"user_platform": [[@"IOS" dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0]};
//        storeLink = @"http://playcontest.in/ankur_worldpress_test/wordpress/wp-tm-store-notify/api/login/";
        storeLink = [NSString stringWithFormat:@"%@/wp-tm-store-notify/api/login/",  [[[DataManager sharedManager] tmDataDoctor] baseUrl] ];
        RLOG(@"storeLink = %@", storeLink);
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [manager POST:storeLink parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *json_dict = [Utility getJsonObject:responseObject];
        if (json_dict == nil) {
            RLOG(@"No data received / Invalid Json");
        } else {
            RLOG(@"json_dict: %@", json_dict);
            NSString* errorStr = [json_dict valueForKey:@"error"];
            NSString* messageStr = [json_dict valueForKey:@"message"];
            NSString* statusStr = [json_dict valueForKey:@"status"];
            
            RLOG(@"messageStr: %@", messageStr);
            if ([statusStr isEqualToString:@"success"]) {
                
                [[AppUser sharedManager] parseUserRole:json_dict];
                //loggedin successful
                _isUserAuthenticatedOnStore = true;
                if (_isUserExistOnStore == false || _isRegistration) {
                    //it means its a new user..created by social login or new registration
                    _isRegistration = false;
                    _tempServerData = [[DataManager sharedManager] fetchCustomerData:nil userEmail:_tempUserEmail];
                } else {
                    [self loginOnParse];
                }
            } else {
                //loggedin failed
                if (_isRegistration){
                    NSMutableDictionary* dataDictionary = [[NSMutableDictionary alloc] init];
                    [dataDictionary setObject:messageStr forKey:@"description"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"RegistrationFailed" object:dataDictionary];
                } else {
                    NSMutableDictionary* dataDictionary = [[NSMutableDictionary alloc] init];
                    [dataDictionary setObject:messageStr forKey:@"description"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginFailed" object:dataDictionary];
                }
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        RLOG(@"\n==Error = %@\n\n", error);
        id data = [error.userInfo valueForKey:@"com.alamofire.serialization.response.error.data"];
        NSDictionary* json_dict = [Utility getJsonObject:data];
        
        if (json_dict){
            NSString* errorStr = [json_dict valueForKey:@"error"];
            NSString* messageStr = [json_dict valueForKey:@"message"];
            NSString* statusStr = [json_dict valueForKey:@"status"];
            if (statusStr && messageStr && [statusStr isEqualToString:@"failed"] && ![messageStr isEqualToString:@""]) {
                if (_isRegistration){
                    NSMutableDictionary* dataDictionary = [[NSMutableDictionary alloc] init];
                    [dataDictionary setObject:messageStr forKey:@"description"];
//                    [[NSNotificationCenter defaultCenter] postNotificationName:@"RegistrationFailed" object:dataDictionary];
                    
                    [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginFailed" object:dataDictionary];
                } else {
                    NSMutableDictionary* dataDictionary = [[NSMutableDictionary alloc] init];
                    [dataDictionary setObject:messageStr forKey:@"description"];
//                    [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginFailed" object:dataDictionary];
                    
                    [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginFailed" object:dataDictionary];
                }
            }

        }
        
        if (json_dict && 0) {
            RLOG(@"json_dict: %@", json_dict);
            NSString* errorStr = [json_dict valueForKey:@"error"];
            NSString* messageStr = [json_dict valueForKey:@"message"];
            NSString* statusStr = [json_dict valueForKey:@"status"];
            
            RLOG(@"messageStr: %@", messageStr);
            if (statusStr && [statusStr isEqualToString:@"success"]) {
                
                [[AppUser sharedManager] parseUserRole:json_dict];
                //loggedin successful
                _isUserAuthenticatedOnStore = true;
                if (_isUserExistOnStore == false || _isRegistration) {
                    //it means its a new user..created by social login or new registration
                    _isRegistration = false;
                    _tempServerData = [[DataManager sharedManager] fetchCustomerData:nil userEmail:_tempUserEmail];
                } else {
                    [self loginOnParse];
                }
            } else {
                //loggedin failed
                if (_isRegistration){
                    NSMutableDictionary* dataDictionary = [[NSMutableDictionary alloc] init];
                    [dataDictionary setObject:messageStr forKey:@"description"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"RegistrationFailed" object:dataDictionary];
                } else {
                    NSMutableDictionary* dataDictionary = [[NSMutableDictionary alloc] init];
                    [dataDictionary setObject:messageStr forKey:@"description"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginFailed" object:dataDictionary];
                }
            }
            return;
        }
        
        
        
        
        NSInteger statusCode = 0;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = httpResponse.statusCode;
        }

        if(statusCode == 404) {
            [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginFailed" object:nil];
        } else {
//            [self loginOnStore];
            [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginFailed" object:nil];
        }
    }];
}
- (void)loginOnParse{
    _isUserExistOnParse = true;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginSuccessful" object:self];
    AppUser* au = [AppUser sharedManager];
//    [au saveAll];
    [[ParseHelper sharedManager] signInParse:au._email];
    [[AppDelegate getInstance] logRegistration];
    //do stuff here
    // if user exists then merge data with user's row.
    // else create new row and send data to that row.
    // after this process user is logged in successfully.
    
    

    if ([[Addons sharedManager] enable_role_price]) {
        [au relaunchApp];
    } else {
        
    }
}
- (NSString*)createEmailId:(NSString*)serviceProvider uid:(NSString*)uid emailID:(NSString*)emailID {
    NSString* userEmailId = @"";
    
    if (emailID && ![emailID isEqualToString:@""]) {
        userEmailId = emailID;
    } else {
//        NSString* strCmpnyUrl =[NSString stringWithFormat:@"%@", [[[DataManager sharedManager] tmDataDoctor] baseUrl]];
//        strCmpnyUrl = [strCmpnyUrl stringByReplacingOccurrencesOfString:@"http://" withString:@""];
//        strCmpnyUrl = [strCmpnyUrl stringByReplacingOccurrencesOfString:@"https://" withString:@""];
//        NSArray *chunks = [strCmpnyUrl componentsSeparatedByString: @"/"];
//        if (chunks!=nil && (int)[chunks count] > 0) {
//            strCmpnyUrl = chunks[0];
//            RLOG(@"CompanyUrl = %@", strCmpnyUrl);
//            userEmailId = [NSString stringWithFormat:@"%@%@@%@",serviceProvider, uid, strCmpnyUrl];
//        }
        userEmailId = nil;
    }
    return userEmailId;
}
- (void)forgetPassword:(NSNotification*)notification {
    [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
    [MRProgressOverlayView showOverlayAddedTo:[[UIApplication sharedApplication] keyWindow] title:@"" mode:MRProgressOverlayViewModeIndeterminateSmallDefault animated:YES];
    NSMutableDictionary* dictionary = [notification object];
    NSString* userEmailId = [dictionary objectForKey:@"email"];
    
    NSDictionary *params = nil;
    NSString* storeLink = @"";
    params = @{@"user_emailID": [[userEmailId dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0]};
    storeLink = [NSString stringWithFormat:@"%@/wp-tm-store-notify/api/forget-password/",  [[[DataManager sharedManager] tmDataDoctor] baseUrl] ];
    RLOG(@"storeLink = %@", storeLink);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    [manager POST:storeLink parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

       [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
        NSDictionary *json_dict = [Utility getJsonObject:responseObject];
        if (json_dict == nil) {
            RLOG(@"No data received / Invalid Json");
        } else {
            RLOG(@"json_dict: %@", json_dict);
            NSString* errorStr = [json_dict valueForKey:@"error"];
            NSString* messageStr = [json_dict valueForKey:@"message"];
            NSString* statusStr = [json_dict valueForKey:@"status"];
            RLOG(@"messageStr: %@", messageStr);
            if ([statusStr isEqualToString:@"success"]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ResetPasswordSentSuccess" object:nil];
            }
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:messageStr delegate:self cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil];
            [alert show];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        RLOG(@"\n==Error = %@\n\n", error);
        NSInteger statusCode = 0;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = httpResponse.statusCode;
        }
        if(statusCode == 404) {
            [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginFailed" object:nil];
        } else {
            [self forgetPassword];
        }
    }];
}

@end
