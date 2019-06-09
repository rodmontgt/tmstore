//
//  Variables.h
//  eCommerceApp
//
//  Created by Rishabh Jain on 30/09/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#ifndef eCommerceApp_Variables_h
#define eCommerceApp_Variables_h
#import "VariousKeys.h"
#define ENABLE_FULL_SPLASH_ON_LAUNCH_NEW 0
#define ENABLE_FULL_SPLASH_ON_LAUNCH 0
#define ENABLE_GOOGLE_ADMOB_SDK 0
#define PAGE_TERMS_AND_CONDITION @""
#define ENABLE_FMAS 0
#define ENABLE_UPDATE_CHECK 0
#define UPDATE_CHECK_LATER_DAYS 15
#if ENABLE_DEBUGGING
#define ENABLE_FILTER 0
#endif
#define ENABLE_CRASHLYTICS 1
#define ENABLE_LOGIN_AT_HOME 1
#define ENABLE_SPONSOR_FRIEND 1
#define ASK_SET_VENDOR_EVERY_TIME 0
#define ASK_SET_VENDOR_ONLY_IF_CART_WISHLIST_HAVE_ITEM 1
#define ENABLE_ORDER_NOTE 1
#define ENABLE_CART_NOTE 1
#define SHOW_ACCOUNT_DETAILS_ORDER_RECEIPT_SCREEN 1
#define SHOW_ACCOUNT_DETAILS_ORDER_SCREEN 1
#define SHOW_ORDER_NOTE 1
#define SHOW_DATE_TIME_SLOT 1
#define ENABLE_ARABIC_TEST 0
#define ENABLE_KEYBOARD_CHANGE 1
#define MAGENTO_TEST_ENABLE 0
#define SAMPLE_APP_CODE @"sNAGb5J4or"
#define NETWORK_PROBLEM 0
#define CHECK_PRELOADED_DATA 0
#define ENABLE_BRANCH 1
#define ENABLE_FB_LOGIN 1
#define ENABLE_TWITTER_LOGIN 1
#define ENABLE_GOOGLE_ANALYTICS 0
#define ENABLE_ADWORDS_FIREBASE 1
#define ENABLE_FIREBASE_TAG_MANAGER 1
#define INTEGRATE_PARSE 1
#define FORCE_LOGIN_ENABLE 0
#define IS_RECORD_APP_ENABLE 0
#define ENABLE_NTP 1
#define ENABLE_SIMPLEAUTH 0
#define ENABLE_BARCODE_SCANNER 1
#define ENABLE_PARSE_ANALYTICS 1
#define ENABLE_FB_ANALYTICS 1
#define ENABLE_TRENDING_ITEMS_VIA_PLUGIN 1
#define ENABLE_OPINION 1
#define ENABLE_WHATSAPP_SHARING 1
#define PAYUMONEY_TEST_ENABLE 0
#define PAYPAL_TEST_ENABLE 0
#define WORKING_BRANCH_VERSION_0_11_11 1
#define WORKING_BRANCH_VERSION_0_11_6 0
#define ENABLE_AUTOCOMPLETE_GEOLOCATION_SEARCH 1
#define ENABLE_HOTLINE 0
#define ENABLE_FRESHCHAT !ENABLE_HOTLINE
#define ENABLE_VARIABLE_LAYOUT 0
#define ENABLE_DELIVERY_SLOT_COPIA 1
#define ENABLE_LOCAL_PICKUP_TIME_SELECT 1
#define ENABLE_DISCOUNT_LAYOUT_TYPE1 0
#define ENABLE_DISCOUNT_LAYOUT_TYPE2 !ENABLE_DISCOUNT_LAYOUT_TYPE1
#define ENABLE_GUEST_CHECKOUT 1
#define ENABLE_PRODUCT_DELIVERY_DATA_PLUGIN 1
#define ENABLE_OTP_LOGIN 1
#define ENABLE_RESET_PASSWORD 1
#define ENABLE_CHECKOUT_MANAGER 1
#define ENABLE_LOCATE_STORE 1
#define ENABLE_OTP_AT_CHECKOUT 1
#define ENABLE_SELLER_ZONE 1
#define SUPPORT_PORTRAIT_ORIENTATION_ONLY 0
#define ENABLE_ADDRESS_WITH_MAP 1
#define CATEGORY_VIEW_NEW_HACK_ENABLE 1
#define ENABLE_FILTER_LOCATION 1
#define ENABLE_HEADER_FILTER_BUTTON 1
#define ENABLE_SELLER_LOC_PRODUCT_PAGE 1
#define ENABLE_SHOW_ALL_IMAGES 0//SAMPLE FOR NEW FEATURE INTEGRATI0N
#define ENABLE_CURRENCY_SWITCHER 1

#if ENABLE_DEBUGGING
    #define TEST_SHOW_ALL_IMAGES 0
    #define TEST_CURRENCY_SWITCHER 0
    #define TEST_NEW_FEATURE 0
    #define ENABLE_TEST_MULTIVENDOR 0 //must be zero
    #define ENABLE_TEST_FILTER 0
    #define TEST_FILTER_LOCATION 0
    #define TEST_ADDRESS_WITH_MAP 0
    #define ENABLE_UPLOAD_IMG_LOW_RESOLUTION 0
    #define TEST_SELLER_ZONE 0
    #define ENABLE_USER_ROLE 0
    #define TEST_USER_ROLE 0
    #define TEST_OTP_AT_CHECKOUT 0
    #define TEST_CHECKOUT_MANAGER 0
    #define TEST_LOCATE_STORE 0
    #define TEST_CHANGE_STORE 0
    #define TEST_SHOW_NESTED_CATEGORY_MENU_FALSE 0
    #define TEST_SHOW_CART_WITH_PRODUCTS 0
    #define TEST_OTP_LOGIN 0
    #define TEST_BYPASS_ORDER_CREATION_DIRECT_PAYMENT 0
    #if TEST_BYPASS_ORDER_CREATION_DIRECT_PAYMENT
        #define TEST_MINIMUM_PAYMENT 1
    #else
        #define TEST_MINIMUM_PAYMENT 0
    #endif
    #define TEST_BARCODE_SCANNER 0
    #define TEST_PAYSTACK 0
    #define ENABLE_DYNAMIC_LAYOUT_HOME_SCREEN 0
    #define ESCAPE_CART_VARIFICATION 0
    #define TEST_FORCED_DISCOUNT_LAYOUT 0
    #if TEST_MINIMUM_PAYMENT
        #define MINIMUM_PAYMENT_AMOUNT 0.01f
    #endif
    #if ENABLE_APP_PLATFORM_STRING
        #define APPDATA_PLATFORM APP_PLATFORM_STRING
    #else
        #if ENABLE_DYNAMIC_LAYOUT_HOME_SCREEN
            #define APPDATA_PLATFORM @"android"
        #else
            #define APPDATA_PLATFORM @"ios"
        #endif
    #endif
#else
    #define APPDATA_PLATFORM @"ios"
#endif

#define ENABLE_MULTI_VENDOR 1
#define MAX_STR_LENGTH_PREVIOUS_ITEM_IPHONE 5
#define MAX_STR_LENGTH_CURRENT_ITEM_IPHONE 10
#define MAX_STR_LENGTH_PREVIOUS_ITEM_IPAD 12
#define MAX_STR_LENGTH_CURRENT_ITEM_IPAD 25
#define PROMO_ENABLE_IN_SHOW_ALL_VIEWS 1
#define PROMO_ENABLE_IN_HORIZONTAL_VIEWS 0
#define MIN_ITEMS_IN_HORIZONTAL_VIEWS 0
#define MAX_ITEMS_IN_HORIZONTAL_VIEWS 20

#define GMS_SERVICES_API_KEY @"AIzaSyDUdBcUBXEmYtLC2os9OFnGwpZHTwEZPFc"
#define GMS_PLACES_CLIENT_API_KEY @"AIzaSyC7AN8nC5RxCAIrMUmLdu45Xmh4s460Ke0"

#import "Constants.h"
#import "MyDevice.h"
#import "VariousKeys.h"
#import "Addons.h"
#import "TMLanguage.h"
#import <TMPaymentSDK/TMPaymentSDK.h>
#import "UILabel+LocalizeConstrint.h"
#import "UITextField+LocalizeConstrint.h"
#import "UIButton+LocalizeConstrint.h"
#import "UIImageView+LocalizeConstrint.h"

#define IS_NOT_NULL(dict, key) [dict objectForKey:key] && ![[dict objectForKey:key] isEqual:[NSNull null]]
// Is Not a Null
#define IsNaN(value) (value != nil) && ![value isEqual:[NSNull null]]
#define IS_EMPTY_STR(value) (value == nil) || [value isEqualToString:@""]
#define GET_VALUE_STRING_DEFAULT(dict, key, default)     (IS_NOT_NULL(dict, key))? GET_VALUE_STRING(dict, key):default
#define GET_VALUE_INT_DEFAULT(dict, key, default)     (IS_NOT_NULL(dict, key)) ?GET_VALUE_INT(dict, key) : default
#define GET_VALUE_FLOAT_DEFAULT(dict, key, default)     (IS_NOT_NULL(dict, key)) ?GET_VALUE_FLOAT(dict, key) : default
#define GET_VALUE_BOOL_DEFAULT(dict, key, default)     (IS_NOT_NULL(dict, key)) ?GET_VALUE_BOOL(dict, key) : default
#define GET_VALUE_OBJECT_DEFAULT(dict, key, default)     (IS_NOT_NULL(dict, key)) ?GET_VALUE_OBJECT(dict, key) : default
#define GET_VALUE_STR(dict, key)     [dict objectForKey:key]
#define GET_VALUE_STRING(dict, key)     [dict objectForKey:key]
#define GET_VALUE_INT(dict, key)        [[dict objectForKey:key] intValue]
#define GET_VALUE_FLOAT(dict, key)      [[dict objectForKey:key] floatValue]
#define GET_VALUE_DOUBLE(dict, key)      [[dict objectForKey:key] doubleValue]
#define GET_VALUE_BOOL(dict, key)       [[dict objectForKey:key] boolValue]
#define GET_VALUE_OBJECT(dict, key)     [dict objectForKey:key]
#define GET_VALUE_OBJ(dict, key)     [dict objectForKey:key]
#define base64_int(value) [[[NSString stringWithFormat:@"%d", value] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0]
#define base64_str(value) [[[NSString stringWithFormat:@"%@", value] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0]
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#if ENABLE_DEBUGGING
//#define RLOG(format, ...)  NSLog((@"==TMStore==\t" format), ##__VA_ARGS__);
#define RLOG_DESC(format, ...) NSLog((@"==TMStore==\t%s [Line %d]\n" format), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#define RLOG(format, ...) NSLog((@"==TMStore==\t%s [Line %d]\n" format), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define RLOG(format, ...)  0
#define RLOG_DESC(format, ...) 0
#endif

@interface NSString(Extensions)
- (NSDictionary *) json_StringToDictionary;
@end
@implementation NSString (Extensions)
- (NSDictionary *) json_StringToDictionary {
    NSError *error;
    NSData *objectData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData options:NSJSONReadingMutableContainers error:&error];
    return (error ? nil : json);
}
@end
@interface NSArray(Extensions)
+ (NSString*) join:(NSArray*) array;
+ (NSString*) join:(NSArray*) array seperator:(NSString*) seperator;
@end
@implementation NSArray (Extensions)
+ (NSString*) join:(NSArray*) array {
    return [NSArray join:array seperator:@","];
}
+ (NSString*) join:(NSArray*) array seperator:(NSString*) seperator {
    NSMutableString *str = [[NSMutableString alloc] init];
    NSInteger count = [array count];
    for(int i = 0; i < count; i++) {
        [str appendString:[array objectAtIndex:i]];
        if(i < count - 1)
            [str appendString:seperator];
    }
    return [NSString stringWithString:str];
}
@end
#define _DATAID                     @"DFID"
#define CategoryCellType1           @"CategoryCellType1"
#define CategoryCellType2           @"CategoryCellType2"
#define ProductCellType1            @"ProductCellType1"
#define ProductCellType2            @"ProductCellType2"
#define ProductCellType3            @"ProductCellType3"
#define ProductCellType4            @"ProductCellType4"
#define ProductCellType1_Cart       @"ProductCellType1_Cart"
#define ProductCellType2_Cart       @"ProductCellType2_Cart"
#define ProductCellType3_Cart       @"ProductCellType3_Cart"
#define ProductCellType4_Cart       @"ProductCellType4_Cart"
#define ProductCellTypeBundle       @"ProductCellTypeBundle"
#define ProductCellTypeMixMatch     @"ProductCellTypeMixMatch"
#define ProductCellType5_Cart       @"ProductCellType5_Cart"
#define ProductCellType5_Cart_FLEXIBLE @"ProductCellType5_Cart_FLEXIBLE"
enum APP_TYPE{
    APP_TYPE_INACTIVE,
    APP_TYPE_DEMO,
    APP_TYPE_FREE,
    APP_TYPE_PAID
};
typedef enum ScrollDirection {
    ScrollDirectionNone,
    ScrollDirectionRight,
    ScrollDirectionLeft,
    ScrollDirectionUp,
    ScrollDirectionDown,
    ScrollDirectionCrazy,
} ScrollDirection;
typedef enum : NSUInteger {
    C_LAYOUT_DEFAULT = 0,//default
    C_LAYOUT_FULL = 1,//fullScreen
    C_LAYOUT_RIGHTSIDE = 2,//rightside explore button
    C_LAYOUT_LEFTRIGHTSIDE = 3,//left right side explore button
    
} C_LAYOUT;
typedef enum : NSUInteger {
    P_LAYOUT_DEFAULT = 0,//default
    P_LAYOUT_FULL_ICON_BUTTON = 1,//fullscreen
    P_LAYOUT_FULL_RECT_BUTTON = 2,//fullscreen with button
    P_LAYOUT_ZIGZAG = 3,//default with zigzag
    P_LAYOUT_GROCERY = 4,
    P_LAYOUT_DISCOUNT = 5
} P_LAYOUT;
#define DEFAULT_LOCALE @"DEFAULT_LOCALE"
#define USER_LOCALE @"USER_LOCALE"
#define USER_LOCAL_TITLE @"USER_LOCAL_TITLE"
#define SET_RTL_VALUE @"SET_RTL_VALUE"
#define SET_KEYBOARD_VALUE @"SET_KEYBOARD_VALUE"
#define VENDOR_ID @"VENDOR_ID"
#define VENDOR_NAME @"VENDOR_NAME"
enum REGION_SEQUENCE {
    REGION_SEQUENCE_COUNTRY = 0,
    REGION_SEQUENCE_STATE = 1,
    REGION_SEQUENCE_CITY = 2,
    REGION_SEQUENCE_DISTRICT = 3,
    REGION_SEQUENCE_SUBDISTRICT = 4,
    REGION_SEQUENCE_TOTAL
};
static NSString* REGION_SEQUENCE_STRINGS[REGION_SEQUENCE_TOTAL] = {@"country", @"state", @"city", @"district", @"subdistrict"};
enum OTP_METHOD_TYPE {
    OTP_METHOD_TYPE_SEND,
    OTP_METHOD_TYPE_VERIFY,
    OTP_METHOD_TYPE_RESEND,
    OTP_METHOD_TYPE_CHECKOUT_SEND,
    OTP_METHOD_TYPE_CHECKOUT_RESEND,
    OTP_METHOD_TYPE_CHECKOUT_VERIFY
};

typedef enum : NSUInteger {
    UR_TYPE_CUSTOMER,
    UR_TYPE_ADMINISTRATOR,
    UR_TYPE_EDITOR,
    UR_TYPE_AUTHOR,
    UR_TYPE_CONTRIBUTOR,
    UR_TYPE_SUBSCRIBER,
    UR_TYPE_SHOP_MANAGER,
    UR_TYPE_PENDING_VENDOR,
    UR_TYPE_REJECTED_VENDOR,
    UR_TYPE_SELLER,
    UR_TYPE_TOTAL,
} UR_TYPE;

typedef enum : NSUInteger {
    URP_FORMULA_TYPE_PERCENTAGE,
    URP_FORMULA_TYPE_AMOUNT,
    URP_FORMULA_TYPE_TOTAL,
} URP_FORMULA_TYPE;

typedef enum : NSUInteger {
    URP_TYPE_DISCOUNT,
    URP_TYPE_MARKUP,
    URP_TYPE_TOTAL,
} URP_TYPE;
//"avatar_icon",
//"first_name",
//"last_name",
//"shop_name",
//"shop_contact",
//"shop_address",
//"shop_icon"
typedef enum : NSUInteger {
    TAG_CELL_AVATAR_ICON,
    TAG_CELL_FIRST_NAME,
    TAG_CELL_LAST_NAME,
    TAG_CELL_SHOP_NAME,
    TAG_CELL_SHOP_ADDRESS,
    TAG_CELL_SHOP_CONTACT,
    TAG_CELL_SHOP_ICON,
    TAG_CELL_ITEMS_TOTAL
} TAG_CELL_ITEMS;
static NSString* TAG_CELL_STRINGS[TAG_CELL_ITEMS_TOTAL] = {
    @"PSprofileCell",
    @"PSDetailCell",
    @"PSDetailCell",
    @"PSDetailCell",
    @"PSDetailCell",
    @"PSDetailCell",
    @"PSshopeCell"
};
/// @"PSMapAddressCell",
#endif
