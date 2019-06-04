//
//  TMPaymentGateway.h
//  TMPaymentSDK
//
//  Created by Rishabh Jain on 04/04/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMPaymentVariables.h"
#import <PassKit/PassKit.h>
#import <TargetConditionals.h>


@interface ConfigParent : NSObject
@property NSString* backButtonTitle;
@property NSString* paymentPageTitle;

@property NSString* pp_card_holder_name;
@property NSString* pp_card_holder_name_hint;
@property NSString* pp_card_number;
@property NSString* pp_card_number_hint;
@property NSString* pp_card_expiry_date;
@property NSString* pp_card_expiry_date_hint;
@property NSString* pp_card_cvv;
@property NSString* pp_card_cvv_hint;
@property NSString* pp_card_zipcode;
@property NSString* pp_card_zipcode_hint;
@property NSString* pp_pay_button_title;
@property NSString* pp_invalid_details;
@property NSString* pp_all_fields_are_mendatory;

@property NSString* button_ok_title;
@end


@interface GatewaySettings : NSObject
@property NSString* extraCharges;
@property NSString* extraChargesMessage;
@property NSString* extraChargesType;
@property NSString* cod_pincodes;
@property NSString* in_ex_pincode;
- (id)init;
@end





@interface StripeConfig : ConfigParent
@property NSString* cStripePublishableKey;
@property NSString* cStripeSecretKey;
@property NSString* cBackendChargeURLString;
@property NSString* cBackendChargeURLStringSavedCard;
@property BOOL cIsEnabled;
@property BOOL cIsDefaultGateway;
@property NSString* cId;
@property NSString* cTitle;
+ (id)sharedManager;
@property float infoTotalAmount;
@property NSString* infoDescription;
@property NSString* infoCurrency;
@property NSString* infoCountry;
@property NSString* infoCurrencyString;

@property NSString* infoLStrSavedCard;
@property NSString* infoLStrAddCard;
@property NSString* infoLStrTotalAmount;
@end

@interface PaystackConfig : ConfigParent
@property NSString* cPaystackPublishableKey;
@property NSString* cPaystackSecretKey;
@property NSString* cBackendChargeURLString;
@property BOOL cIsEnabled;
@property BOOL cIsDefaultGateway;
@property NSString* cId;
@property NSString* cTitle;
+ (id)sharedManager;
@property float infoTotalAmount;
@property NSString* infoDescription;
@property NSString* infoCurrency;
@property NSString* infoCountry;
@property NSString* infoCurrencyString;
@property NSString* infoEmail;
@end

@interface ApplePayViaStripeConfig : ConfigParent
@property NSString* cStripePublishableKey;
@property NSString* cStripeSecretKey;
@property NSString* cBackendChargeURLString;
@property NSString* cApplePayMerchantId;
@property BOOL cIsEnabled;
@property BOOL cIsDefaultGateway;
@property NSString* cId;
@property NSString* cTitle;
@property float infoTotalAmount;
@property NSString* infoDescription;
@property NSString* infoCurrency;
@property NSString* infoCountry;
+ (id)sharedManager;
@end

@interface PayPalConfig : ConfigParent
@property NSString* cPayPalClientId;
@property NSString* cPayPalSandboxId;
@property BOOL cIsEnabled;
@property BOOL cEnableCreditCard;

@property float infoTotalAmount;
@property NSString* infoDescription;
@property NSString* infoCurrency;
@property NSString* infoCountry;
+ (id)sharedManager;
@end

@interface PayuConfig : ConfigParent
@property NSString* cName;
@property NSString* cPayuMerchantKey;
@property NSString* cPayuSaltKey;
@property NSString* cSuccessUrl;
@property NSString* cFailureUrl;
@property NSString* cServiceProvider;
@property BOOL cIsEnabled;

@property float infoTotalAmount;
@property NSString* infoName;
@property NSString* infoEmail;
@property NSString* infoPhone;
+ (id)sharedManager;
@end

@interface DusupayConfig : ConfigParent
@property NSString* cMerchantId;
@property NSString* cSuccessUrl;
@property NSString* cRedirectUrl;
@property BOOL cIsEnabled;
@property BOOL cIsDefaultGateway;
@property BOOL cIsSandboxMode;
@property NSString* cId;
@property NSString* cTitle;
@property float infoTotalAmount;
@property NSString* infoCurrency;
+ (id)sharedManager;
@end


@interface BraintreeConfig : ConfigParent
@property NSString* cBaseUrl;
@property NSString* cSuccessUrl;
@property NSString* cFailureUrl;
@property BOOL cIsEnabled;
@property BOOL cIsDefaultGateway;
@property NSString* cId;
@property NSString* cTitle;
@property float infoTotalAmount;
@property NSString* infoCurrency;
+ (id)sharedManager;
@end

@interface MyGateConfig : ConfigParent
@property NSString* cBaseUrl;
@property NSString* cSuccessUrl;
@property NSString* cFailureUrl;
@property BOOL cIsEnabled;
@property BOOL cIsDefaultGateway;
@property NSString* cId;
@property NSString* cTitle;
@property float infoTotalAmount;
@property NSString* infoCurrency;
+ (id)sharedManager;
@end

@interface AuthorizeNetConfig : ConfigParent
@property NSString* cBaseUrl;
@property NSString* cSuccessUrl;
@property NSString* cFailureUrl;
@property BOOL cIsEnabled;
@property BOOL cIsDefaultGateway;
@property NSString* cId;
@property NSString* cTitle;

@property float infoTotalAmount;
@property NSString* infoDescription;
@property NSString* infoCurrency;
@property NSString* infoPhone;
@property NSString* infoEmail;
@property NSString* infoState;
@property NSString* infoCountry;
@property NSString* infoAddress;
@property NSString* infoCity;
@property NSString* infoPostCode;
@property NSString* infoPlatform;
@property NSString* infoFirstName;
@property NSString* infoLastName;
@property NSString* infoOrderId;
//'fname'         => base64_encode('John'),
//'lname'          => base64_encode('Smith'),
//'address'   => base64_encode('123 Main Street'),
//'city'      => base64_encode('Townsville'),
//'state'            => base64_encode('NJ'),
//'zipcode'   => base64_encode('12345'),
//'phone'         => base64_encode('8005551234'),
//'amount'         => base64_encode('10.01'),
//'email'           => base64_encode('johnny@example.com'),
//'description' => base64_encode('A test transaction'),
//'orderid'         => base64_encode('121')

+ (id)sharedManager;
@end


@interface SagepayConfig : ConfigParent
@property NSString* cVendorUrl;
@property NSString* cVendorId;
@property NSString* cVendorPassword;
@property NSString* cVendorResponseUrl;
@property NSString* cVendorPaymentUrl;
@property BOOL cIsEnabled;

@property BOOL cIsDefaultGateway;
@property NSString* cId;
@property NSString* cTitle;

+ (id)sharedManager;

@property float infoTotalAmount;
@property NSString* infoDescription;
@property NSString* infoCurrency;
@property NSString* infoCountry;
@property NSString* infoAddress;
@property NSString* infoCity;
@property NSString* infoPostCode;
@property NSString* infoPlatform;
@property NSString* infoFirstName;
@property NSString* infoLastName;
@end



@interface GestpayConfig : ConfigParent
@property NSString* cPaymentUrl;
@property NSString* cShopLogin;
@property NSString* cShopTransactionId;
@property BOOL cIsEnabled;
@property BOOL cIsDefaultGateway;
@property NSString* cId;
@property NSString* cTitle;
+ (id)sharedManager;
@property float infoTotalAmount;
@end

@interface KentPaymentConfig : ConfigParent
@property NSString* cAccessUrl;
@property NSString* cSecretKey;
@property BOOL cIsEnabled;
@property BOOL cIsDefaultGateway;
@property NSString* cId;
@property NSString* cTitle;
+ (id)sharedManager;
@property float infoTotalAmount;
@property NSString* infoDescription;
@property NSString* infoCurrency;
@property NSString* infoCountry;
@property NSString* infoAddress;
@property NSString* infoCity;
@property NSString* infoPostCode;
@property NSString* infoPlatform;
@property NSString* infoFirstName;
@property NSString* infoLastName;
@end

@interface PayPalPayFlowConfig : ConfigParent
@property NSString* cBackendUrl;
@property BOOL cIsEnabled;
@property BOOL cIsDefaultGateway;
@property NSString* cId;
@property NSString* cTitle;
+ (id)sharedManager;
@property float infoTotalAmount;
@property NSString* infoFirstName;
@property NSString* infoLastName;
@property NSString* infoEmail;
@property NSString* infoBillingAdd1;
@property NSString* infoBillingAdd2;
@property NSString* infoCity;
@property NSString* infoState;
@property NSString* infoPostCode;
@property NSString* infoCountry;
@property NSString* infoPhone;
@property NSString* infoCurrency;
@property NSString* infoPlatform;
@end


@interface VCSPayConfig : ConfigParent
@property NSString* cMerchantId;
@property BOOL cIsEnabled;
@property BOOL cIsDefaultGateway;
@property NSString* cId;
@property NSString* cTitle;
+ (id)sharedManager;
@property NSString* infoCurrency;
@property float infoTotalAmount;
@property NSString* infoPlatform;
@property NSString* infoDescription;
@property NSString* infoCurrencyString;
@end

@interface TapPaymentConfig : ConfigParent
@property NSString* cBackendUrl;
@property BOOL cIsEnabled;
@property BOOL cIsDefaultGateway;
@property NSString* cId;
@property NSString* cTitle;
+ (id)sharedManager;
@property float infoTotalAmount;
@property NSString* infoFirstName;
@property NSString* infoLastName;
@property NSString* infoEmail;
@property NSString* infoPhone;
@property NSString* infoCurrency;
@property NSString* infoPlatform;
@end

@interface PlugNPayPaymentConfig : ConfigParent
@property NSString* cBackendUrl;
@property BOOL cIsEnabled;
@property BOOL cIsDefaultGateway;
@property NSString* cId;
@property NSString* cTitle;
+ (id)sharedManager;
@property float infoTotalAmount;
@property NSString* infoPlatform;
@property NSString* infoName;
@property NSString* infoEmail;
@property NSString* infoPhone;
@property NSString* infoOrderId;
@property NSString* infoOrderDescription;
@end


@interface SenangPayPaymentConfig : ConfigParent
@property NSString* cBaseUrl;
@property NSString* cSuccessUrl;
@property NSString* cFailureUrl;
@property BOOL cIsEnabled;
@property BOOL cIsDefaultGateway;
@property NSString* cId;
@property NSString* cTitle;
+ (id)sharedManager;
@property float infoTotalAmount;
@property NSString* infoDescription;
@property NSString* infoPhone;
@property NSString* infoEmail;
@property NSString* infoName;
@property NSString* infoOrderId;
@end


@interface MolliePaymentConfig : ConfigParent
@property NSString* cBaseUrl;
@property NSString* cSuccessUrl;
@property NSString* cFailureUrl;
@property BOOL cIsEnabled;
@property BOOL cIsDefaultGateway;
@property NSString* cId;
@property NSString* cTitle;
+ (id)sharedManager;
@property float infoTotalAmount;
@property NSString* infoDescription;
@property NSString* infoPhone;
@property NSString* infoEmail;
@property NSString* infoName;
@property NSString* infoOrderId;
@end

@interface HesabePaymentConfig : ConfigParent
@property NSString* cBaseUrl;
@property NSString* cSuccessUrl;
@property NSString* cFailureUrl;
@property BOOL cIsEnabled;
@property BOOL cIsDefaultGateway;
@property NSString* cId;
@property NSString* cTitle;
+ (id)sharedManager;
@property float infoTotalAmount;
@property NSString* infoDescription;
@property NSString* infoPhone;
@property NSString* infoEmail;
@property NSString* infoName;
@property NSString* infoOrderId;
@end

@interface ConektaCardConfig : ConfigParent
@property NSString* cBaseUrl;
@property NSString* cSuccessUrl;
@property NSString* cFailureUrl;
@property BOOL cIsEnabled;
@property BOOL cIsDefaultGateway;
@property NSString* cId;
@property NSString* cTitle;
+ (id)sharedManager;
@property float infoTotalAmount;
@property NSString* infoDescription;
@property NSString* infoPhone;
@property NSString* infoEmail;
@property NSString* infoName;
@property NSString* infoOrderId;
@property NSString* infoOrderItems;
@property NSString* infoBillingAddress;
@property NSString* infoShippingAddress;
@property NSString* infoShipment;
@end



@interface CCAvenueConfig : ConfigParent
@property BOOL cIsEnabled;
+ (id)getInstance;

@property NSString* gateway;
@property NSString* merchantId;
@property NSString* accessCode;
@property NSString* redirectUrl;
@property NSString* cancelUrl;
@property NSString* rsaKeyUrl;
@property int orderId;
@property NSString* currency;
@property double amount;
@property BOOL enabled;

@end

@interface AccountDetails : NSObject
- (id)init;
@property NSString* account_name;
@property NSString* account_number;
@property NSString* bank_name;
@property NSString* bic;
@property NSString* iban;
@property NSString* sort_code;
@end

@interface TMPaymentGateway : NSObject
@property NSString* paymentId;
@property NSString* paymentTitle;
@property NSString* paymentDescription;//description
@property NSString* paymentInstruction;//instructions
@property NSString* paymentIconPath;
@property NSString* paymentOrderButtonText;
@property BOOL isPaymentEnabled;
@property BOOL isPaymentTestModeEnabled;
@property BOOL isPaymentGatewayChoosen;
@property NSMutableArray* paymentAccountDetails;
@property GatewaySettings* gatewaySettings;
@property id sdkObj;
@property id delegate;
@property BOOL isPrepaid;
- (id)init;
- (id)initWithDictionary:(NSDictionary*) dict;
- (BOOL)initializeGateway;
- (void)payAmount:(float)amount currencyCode:(NSString*)currencyCode delegate:(id)delegate;
- (NSString*)getAccountDetailsString;
@end
