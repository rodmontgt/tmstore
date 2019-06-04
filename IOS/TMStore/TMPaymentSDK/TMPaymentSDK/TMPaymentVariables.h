//
//  TMPaymentVariables.h
//  TMPaymentSDK
//
//  Created by Rishabh Jain on 04/04/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#ifndef TMPaymentVariables_h
#define TMPaymentVariables_h


#if ENABLE_DEBUGGING
#define PLOG(format, ...)  NSLog((@"==TMPaymentSDK==\t" format), ##__VA_ARGS__);
#define PLOG_DESC(format, ...) NSLog((@"==TMPaymentSDK==\t%s [Line %d]\n" format), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define PLOG(format, ...)  0
#define PLOG_DESC(format, ...) 0
#endif

#define base64_int(value) [[[NSString stringWithFormat:@"%d", value] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0]

#define base64_str(value) [[[NSString stringWithFormat:@"%@", value] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0]
//#define base64_str(value) [NSString stringWithFormat:@"%@", value]

#define IS_NOT_NULL(dict, key) ([dict objectForKey:key] && !([[dict objectForKey:key] isEqual:[NSNull null]]))?true:false

#define GET_VALUE_STRING(dict, key)     [dict objectForKey:key]
#define GET_VALUE_INT(dict, key)        [[dict objectForKey:key] intValue]
#define GET_VALUE_FLOAT(dict, key)      [[dict objectForKey:key] floatValue]
#define GET_VALUE_BOOL(dict, key)       [[dict objectForKey:key] boolValue]
#define GET_VALUE_OBJECT(dict, key)     [dict objectForKey:key]

#define GET_VALUE_STRING_DEFAULT(dict, key, default)     (IS_NOT_NULL(dict, key))? GET_VALUE_STRING(dict, key):default
#define GET_VALUE_INT_DEFAULT(dict, key, default)     (IS_NOT_NULL(dict, key)) ?GET_VALUE_INT(dict, key) : default
#define GET_VALUE_FLOAT_DEFAULT(dict, key, default)     (IS_NOT_NULL(dict, key)) ?GET_VALUE_FLOAT(dict, key) : default
#define GET_VALUE_BOOL_DEFAULT(dict, key, default)     (IS_NOT_NULL(dict, key)) ?GET_VALUE_BOOL(dict, key) : default
#define GET_VALUE_OBJECT_DEFAULT(dict, key, default)     (IS_NOT_NULL(dict, key)) ?GET_VALUE_OBJECT(dict, key) : default

enum PAYMENT_GATEWAY_TYPE {
    PAYMENT_GATEWAY_TYPE_COD,
    PAYMENT_GATEWAY_TYPE_PAYU_INDIA,
    PAYMENT_GATEWAY_TYPE_PAYU_IN,
    PAYMENT_GATEWAY_TYPE_PAYPAL,
    PAYMENT_GATEWAY_TYPE_DBT, //Direct Bank Transfer
    PAYMENT_GATEWAY_TYPE_CHEQUE,
    PAYMENT_GATEWAY_TYPE_JETPACK1,
    PAYMENT_GATEWAY_TYPE_JETPACK2,
    PAYMENT_GATEWAY_TYPE_JETPACK3,
    PAYMENT_GATEWAY_TYPE_STRIPE,
    PAYMENT_GATEWAY_TYPE_PAYSTACK,
    PAYMENT_GATEWAY_TYPE_APPLE_PAY_VIA_STRIPE,
    PAYMENT_GATEWAY_TYPE_SAGEPAY,
    PAYMENT_GATEWAY_TYPE_KENT_PAYMENT,
    PAYMENT_GATEWAY_TYPE_CCAVENUE,
    PAYMENT_GATEWAY_TYPE_DUSUPAY,
    PAYMENT_GATEWAY_TYPE_GESTPAY,
    PAYMENT_GATEWAY_TYPE_PAYPAL_PAYFLOW,
    PAYMENT_GATEWAY_TYPE_VCS_PAY,
    PAYMENT_GATEWAY_TYPE_TAP_PAYMENT,
    PAYMENT_GATEWAY_TYPE_PLUGNPAY_PAYMENT,
    PAYMENT_GATEWAY_TYPE_SENANGPAY_PAYMENT,
    PAYMENT_GATEWAY_TYPE_MOLLIE_PAYMENT,
    PAYMENT_GATEWAY_TYPE_HESABE_PAYMENT,
    PAYMENT_GATEWAY_TYPE_CONEKTA_CARD,
    PAYMENT_GATEWAY_TYPE_BRAINTREE,
    PAYMENT_GATEWAY_TYPE_MYGATE,
    PAYMENT_GATEWAY_TYPE_AUTHORIZENET,
    PAYMENT_GATEWAY_TYPE_WEBVIEW,
};
static NSString * PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_WEBVIEW] = {
    @"cod",
    @"payuindia",
    @"payu_in",
    @"paypal",
    @"bacs",
    @"cheque",
    @"jetpack_custom_gateway",
    @"jetpack_custom_gateway_2",
    @"jetpack_custom_gateway_3",
    @"stripe",
    @"paystack",
    @"apple_pay_via_stripe",
    @"sagepayform",
    @"payle_kent",
    @"ccavenue",
    @"dusupay",
    @"wc_gateway_gestpay_pro",
    @"paypal_pro",
    @"vcs",
    @"tap",
    @"plugnpaydirect",
    @"senangpay",
    @"mollie_wc_gateway_creditcard",
    @"hesabe",
    @"conektacard",
    @"braintree",
    @"mygate",
    @"authorizenet"
    
};

#define ENABLE_COD 1
#define ENABLE_PAYPAL 1
#define ENABLE_PAYU 1
#define ENABLE_DBT 1
#define ENABLE_CHEQUE 1
#define ENABLE_JETPACK1 1
#define ENABLE_JETPACK2 1
#define ENABLE_JETPACK3 1
#define ENABLE_SAGEPAY 1
#define ENABLE_GESTPAY 1
#define ENABLE_KENT_PAYMENT 1
#define ENABLE_DUSUPAY 1
#define ENABLE_BRAINTREE 1
#define ENABLE_MYGATE 1
#define ENABLE_AUTHORIZENET 1
#define ENABLE_PAYPAL_PAYFLOW 1
#define ENABLE_TAP_PAYMENT 1
#define ENABLE_PLUGNPAY_PAYMENT 1
#define ENABLE_SENANGPAY_PAYMENT 1
#define ENABLE_MOLLIE_PAYMENT 1
#define ENABLE_HESABE_PAYMENT 1
#define ENABLE_CONEKTA_CARD 1
#define ENABLE_PAYSTACK 1
#define ENABLE_VCS_PAY 1






#ifdef __IPHONE_8_1
#define ENABLE_STRIPE 1
#define ENABLE_APPLE_PAY_VIA_STRIPE 1
#else
#define ENABLE_STRIPE 0
#define ENABLE_APPLE_PAY_VIA_STRIPE 0
#endif



#endif /* TMPaymentVariables_h */
