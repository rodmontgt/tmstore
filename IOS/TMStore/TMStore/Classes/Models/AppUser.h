//
//  AppUser.h
//  eCommerceApp
//
//  Created by Rishabh Jain on 01/10/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Address.h"
#import "Utility.h"
#import "Variables.h"
@interface AppUser : NSObject <NSCoding>

@property int _id;

@property NSString *_email;
@property NSString *_username;
@property NSString *_password;//local
@property NSDate *_created_at;
@property NSDate *_updated_at;
@property NSString *_first_name;
@property NSString *_last_name;
@property NSString *_mobile_number;
@property int _last_order_id;
@property NSString *_last_order_date;
@property int _orders_count;
@property double _total_spent;
@property NSString *_avatar_url;
@property NSString *_offline_index;
@property NSString *_offline_categories;
@property NSString *_offline_product;
@property NSString *_offline_comments;
@property NSString *_offline_orders;
@property NSString *_offline_customers;

@property NSMutableArray* _ordersArray;
@property NSMutableArray* _cartArray;
@property NSMutableArray* _wishlistArray;
@property NSMutableArray* _opinionArray;
@property NSMutableArray* _needProductsArrayForOpinion;
@property NSMutableDictionary* _lineItemProductImgUrls;
@property Address *_billing_address;
@property Address *_shipping_address;
@property Address *_billing_addressTemp;
@property Address *_shipping_addressTemp;
@property Address *_billing_addressFetched;
@property Address *_shipping_addressFetched;

extern BOOL _SAVE_OFFLINE_DATA;
extern BOOL _USE_OFFLINE_MODE;

@property BOOL _isUserLoggedIn;
@property int _userLoggedInVia;

@property int rewardPoints;
@property float rewardDiscount;
@property NSMutableArray* guestOrderIds;
+ (id)sharedManager;
+ (void)reload;
+ (void)deleteInstance;
- (void)saveData;
- (void)clearData;
- (void)loadData;
- (void)resetAddress;
- (void)clearSelectedData;
- (void)synq;
- (void)saveAll;
- (void)updateFetchedAddress;
+ (BOOL)isSignedIn;
+ (void)clearFullAppData;
+ (void)clearFullAppData:(BOOL)deleteAppUserData;
//{
//    "error": "",
//    "message": "Login Successful.",
//    "role": "customer",
//    "role_price": {
//        "filter": "percentage",
//        "price": "25",
//        "role": "Customer",
//        "type": "discount"
//    },
//    "role_shipping": [
//                      {
//                          "price": "50",
//                          "role": "Customer",
//                          "shipping": "flat"
//                      },
//                      {
//                          "price": "70",
//                          "role": "Customer",
//                          "shipping": "weight"
//                      }
//                      ], 
//    "status": "success"
//}


@property int ur_type;
@property NSString* ur_type_string;
@property NSString* ur_type_title;
@property float urp;
@property int urp_formula_type;
@property int urp_type;
- (void)parseUserRole:(NSDictionary*)dict;
- (void)resetUserRole;
- (void)relaunchApp;
+ (int)getRoleType:(NSString*)role;
@end
