//
//  LoginFlow.h
//
//  Created by Rishabh Jain on 25/01/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerData.h"
#import "AppUser.h"
#import "DataManager.h"
#import "VariousKeys.h"
enum SA_PROVIDERS_TAG{
    SA_PROVIDERS_FACEBOOK,
    SA_PROVIDERS_FACEBOOK_WEB,
    SA_PROVIDERS_TWITTER,
    SA_PROVIDERS_TWITTER_WEB,
    SA_PROVIDERS_GOOGLE_WEB,
    SA_PROVIDERS_STORE,
    SA_PROVIDERS_TOTAL
};
static NSString * SA_PROVIDERS_NAME [SA_PROVIDERS_TOTAL] = {@"facebook", @"facebook-web", @"twitter", @"twitter-web", @"google-web", @"store"};


@interface LoginFlow : NSObject

#if (ENABLE_SIMPLEAUTH)
- (void)configureAuthorizaionProviders:(int)itemType;
- (void)clickOnSimpleAuthItem:(int)itemType;
#endif
+ (id)sharedManager;


@property ServerData* tempServerData;

@property NSString* tempUserName;
@property NSString* tempUserFirstName;
@property NSString* tempUserLastName;
@property NSString* tempUserPassword;
@property NSString* tempUserEmail;
@property NSString* tempUserImage;
@property NSString* tempUserLoginProvider;
@property NSString* tempUserMobileNumber;
@property NSString* tempUserCompanyName;
@property NSString* tempUserRole;


@property BOOL isUserExistOnStore;
@property BOOL isUserAuthenticatedOnStore;
@property BOOL isUserExistOnParse;
@property BOOL isUserLoggedIn;
@property BOOL isSocialLogin;
@property BOOL isRegistration;
@property BOOL isRegistrationAsVendor;
@property AppUser* appUser;

@property NSString* userNickName;
@property NSString* userImage;
- (void)relogIn;
- (void)forgetPassword;
- (void)loginOnStore;
- (void)responseLogoutClicked:(NSNotification *)notification;
@end
