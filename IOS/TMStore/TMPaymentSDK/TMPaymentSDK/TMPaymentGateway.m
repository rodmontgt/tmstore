//
//  TMPaymentGateway.m
//  TMPaymentSDK
//
//  Created by Rishabh Jain on 04/04/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//
#import "TMPaymentGateway.h"
#import "TMPaymentSDK.h"
#if ENABLE_PAYPAL_PAYFLOW
#import "PayPalPayFlowViewController.h"
#endif
#if ENABLE_VCS_PAY
//#import "VCSPayViewController.h"
#endif
#if ENABLE_TAP_PAYMENT
#import "TapPaymentViewController.h"
#endif
#if ENABLE_PLUGNPAY_PAYMENT
#import "PlugNPayPaymentViewController.h"
#endif
#if ENABLE_SENANGPAY_PAYMENT
#import "SenangPayPaymentViewController.h"
#endif
#if ENABLE_MOLLIE_PAYMENT
#import "MolliePaymentViewController.h"
#endif
#if ENABLE_HESABE_PAYMENT
#import "HesabePaymentViewController.h"
#endif
#if ENABLE_CONEKTA_CARD
#import "ConektaCardPaymentVC.h"
#endif
#if ENABLE_BRAINTREE
#import "BraintreeViewController.h"
#endif
#if ENABLE_MYGATE
#import "MyGateViewController.h"
#endif
#if ENABLE_AUTHORIZENET
#import "AuthorizeNetViewController.h"
#endif
#if ENABLE_GESTPAY
#import "GestpayViewController.h"
#endif
#if ENABLE_DUSUPAY
#import "DusupayViewController.h"
#endif
#if ENABLE_PAYU
#import "PaymentPageViewController.h"
#endif
#if ENABLE_PAYPAL
#import "PayPalMobile.h"
#define TEST_PAYPAL_SANDBOX_CLIENT_ID @"Ab0dO5C0C4pFWd7p3alZEvVFA7AQMTtmu1dYGGeCxo9n2NrQGdswabQGjmCiWmYck3--Swyd8RtXtPuJ"
#define TEST_PAYPAL_PRODUCTION_CLIENT_ID @"AWQ6GygdEFtwcqcYk2LxOVEi35Zm6YeY4XpsKnGeBE5rTAjvfvWHZJHdWGCBYo2ecYJsG3aSRwyPayoj"
#endif

#if ENABLE_STRIPE
#import <Stripe/Stripe.h>
//#import "StripePaymentViewController.h"
#import "SPViewController.h"
#endif

#if ENABLE_PAYSTACK
//#import <Paystack/Paystack.h>
//#import "PaystackViewController.h"
#endif

#if ENABLE_APPLE_PAY_VIA_STRIPE
#import <PassKit/PassKit.h>
#import <Stripe/Stripe.h>
#endif

#if ENABLE_SAGEPAY
#import "SagepayViewController.h"
#endif

#if ENABLE_KENT_PAYMENT
#import "KentPaymentViewController.h"
#endif

#import "CCAvenueController.h"

@implementation ConfigParent
- (id)init {
    self = [super self];
    if (self) {
        self.backButtonTitle = @"< Back";
        self.paymentPageTitle = @"Make a Payment";
        
        self.pp_card_holder_name = @"Name on card";
        self.pp_card_holder_name_hint = @"";
        self.pp_card_number = @"Card number";
        self.pp_card_number_hint = @"";
        self.pp_card_expiry_date = @"Expiry date";
        self.pp_card_expiry_date_hint = @"";
        self.pp_card_cvv = @"Security code";
        self.pp_card_cvv_hint = @"";
        self.pp_card_zipcode = @"ZIP/Postal code";
        self.pp_card_zipcode_hint = @"";
        self.pp_pay_button_title = @"Pay";
        self.pp_invalid_details = @"Invalid details.";
        self.pp_all_fields_are_mendatory = @"All fields are mendatory.";
        
        self.button_ok_title = @"Ok";
    }
    return self;
}
@end

@implementation GatewaySettings
- (id)init {
    self = [super self];
    if (self) {
        self.extraCharges = @"";
        self.extraChargesMessage = @"";
        self.extraChargesType = @"";
    }
    return self;
}
@end

@implementation SagepayConfig
static SagepayConfig *managerSagepay = nil;
+ (id)sharedManager {
    @synchronized(self) {
        if (managerSagepay == nil){
            managerSagepay = [[self alloc] init];
        }
    }
    return managerSagepay;
}
- (id)init {
    self = [super self];
    if (self) {
        //info from addon
        self.cVendorId = @"";
        self.cVendorUrl = @"";
        self.cVendorPassword = @"";
        self.cVendorResponseUrl = @"";
        self.cVendorPaymentUrl = @"";
        self.cIsEnabled = false;
        self.cIsDefaultGateway = false;
        self.cId = [NSString stringWithFormat:@"%@", PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_SAGEPAY]];
        self.cTitle = [NSString stringWithFormat:@""];
        
        //customer info
        self.infoTotalAmount = 0.0f;
        self.infoDescription = @"";
        self.infoCurrency = @"";
        self.infoCountry = @"";
        self.infoAddress = @"";
        self.infoCity = @"";
        self.infoPostCode = @"";
        self.infoPlatform = @"";
        self.infoFirstName = @"";
        self.infoLastName = @"";
        
    }
    return self;
}
@end

@implementation GestpayConfig
static GestpayConfig *managerGestpay = nil;
+ (id)sharedManager {
    @synchronized(self) {
        if (managerGestpay == nil){
            managerGestpay = [[self alloc] init];
        }
    }
    return managerGestpay;
}
- (id)init {
    self = [super self];
    if (self) {
        //info from addon
        self.cPaymentUrl = @"";
        self.cShopLogin = @"";
        self.cShopTransactionId = @"";
        self.cIsEnabled = false;
        self.cIsDefaultGateway = false;
        self.cId = [NSString stringWithFormat:@"%@", PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_GESTPAY]];
        self.cTitle = [NSString stringWithFormat:@""];
        
        //customer info
        self.infoTotalAmount = 0.0f;
        
    }
    return self;
}
@end

@implementation PayPalPayFlowConfig
static PayPalPayFlowConfig *managerPayPalPayFlow = nil;
+ (id)sharedManager {
    @synchronized(self) {
        if (managerPayPalPayFlow == nil){
            managerPayPalPayFlow = [[self alloc] init];
        }
    }
    return managerPayPalPayFlow;
}
- (id)init {
    self = [super self];
    if (self) {
        //info from addon
        self.cBackendUrl = @"";
        self.cIsEnabled = false;
        self.cIsDefaultGateway = false;
        self.cId = [NSString stringWithFormat:@"%@", PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_PAYPAL_PAYFLOW]];
        self.cTitle = [NSString stringWithFormat:@""];
        //customer info
        self.infoTotalAmount = 0.0f;
        self.infoFirstName = @"";
        self.infoLastName = @"";
        self.infoEmail = @"";
        self.infoBillingAdd1 = @"";
        self.infoBillingAdd2 = @"";
        self.infoCity = @"";
        self.infoState = @"";
        self.infoPostCode = @"";
        self.infoCountry = @"";
        self.infoPhone = @"";
        self.infoCurrency = @"";
        self.infoPlatform = @"";
    }
    return self;
}
@end

@implementation VCSPayConfig
static VCSPayConfig *managerVCSPayConfig = nil;
+ (id)sharedManager {
    @synchronized(self) {
        if (managerVCSPayConfig == nil){
            managerVCSPayConfig = [[self alloc] init];
        }
    }
    return managerVCSPayConfig;
}
- (id)init {
    self = [super self];
    if (self) {
        //info from addon
        self.cMerchantId = @"";
        self.cIsEnabled = false;
        self.cIsDefaultGateway = false;
        self.cId = [NSString stringWithFormat:@"%@", PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_VCS_PAY]];
        self.cTitle = [NSString stringWithFormat:@""];
        //customer info
        self.infoCurrency = @"";
        self.infoCurrencyString = @"";
        self.infoPlatform = @"";
        self.infoDescription = @"";
        self.infoTotalAmount = 0.0f;
    }
    return self;
}
@end

@implementation TapPaymentConfig
static TapPaymentConfig *managerTapPaymentConfig = nil;
+ (id)sharedManager {
    @synchronized(self) {
        if (managerTapPaymentConfig == nil){
            managerTapPaymentConfig = [[self alloc] init];
        }
    }
    return managerTapPaymentConfig;
}
- (id)init {
    self = [super self];
    if (self) {
        //info from addon
        self.cBackendUrl = @"";
        self.cIsEnabled = false;
        self.cIsDefaultGateway = false;
        self.cId = [NSString stringWithFormat:@"%@", PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_TAP_PAYMENT]];
        self.cTitle = [NSString stringWithFormat:@""];
        //customer info
        self.infoTotalAmount = 0.0f;
        self.infoFirstName = @"";
        self.infoLastName = @"";
        self.infoEmail = @"";
        self.infoPhone = @"";
        self.infoCurrency = @"";
        self.infoPlatform = @"";
    }
    return self;
}
@end
@implementation PlugNPayPaymentConfig
static PlugNPayPaymentConfig *managerPlugNPayPaymentConfig = nil;
+ (id)sharedManager {
    @synchronized(self) {
        if (managerPlugNPayPaymentConfig == nil){
            managerPlugNPayPaymentConfig = [[self alloc] init];
        }
    }
    return managerPlugNPayPaymentConfig;
}
- (id)init {
    self = [super self];
    if (self) {
        //info from addon
        self.cBackendUrl = @"";
        self.cIsEnabled = false;
        self.cIsDefaultGateway = false;
        self.cId = [NSString stringWithFormat:@"%@", PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_PLUGNPAY_PAYMENT]];
        self.cTitle = [NSString stringWithFormat:@""];
        //customer info
        self.infoTotalAmount = 0.0f;
        self.infoName = @"";
        self.infoEmail = @"";
        self.infoPhone = @"";
        self.infoOrderDescription = @"";
        self.infoOrderId = @"";
        self.infoPlatform = @"";
    }
    return self;
}
@end

@implementation KentPaymentConfig
static KentPaymentConfig *managerKentPayment = nil;
+ (id)sharedManager {
    @synchronized(self) {
        if (managerKentPayment == nil){
            managerKentPayment = [[self alloc] init];
        }
    }
    return managerKentPayment;
}
- (id)init {
    self = [super self];
    if (self) {
        //info from addon
        self.cAccessUrl = @"";
        self.cSecretKey = @"";
        self.cIsEnabled = false;
        self.cIsDefaultGateway = false;
        self.cId = [NSString stringWithFormat:@"%@", PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_KENT_PAYMENT]];
        self.cTitle = [NSString stringWithFormat:@""];
        
        //customer info
        self.infoTotalAmount = 0.0f;
        self.infoDescription = @"";
        self.infoCurrency = @"";
        self.infoCountry = @"";
        self.infoAddress = @"";
        self.infoCity = @"";
        self.infoPostCode = @"";
        self.infoPlatform = @"";
        self.infoFirstName = @"";
        self.infoLastName = @"";
        
    }
    return self;
}
@end

@implementation StripeConfig
static StripeConfig *managerStripe = nil;
+ (id)sharedManager {
    @synchronized(self) {
        if (managerStripe == nil){
            managerStripe = [[self alloc] init];
        }
    }
    return managerStripe;
}
- (id)init {
    self = [super self];
    if (self) {
        self.cStripePublishableKey = @"";
        self.cStripeSecretKey = @"";
        self.cBackendChargeURLString = @"";
        self.cBackendChargeURLStringSavedCard = @"";
        self.cIsEnabled = false;
        self.cIsDefaultGateway = false;
        self.cId = [NSString stringWithFormat:@"%@", PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_STRIPE]];
        self.cTitle = [NSString stringWithFormat:@""];
        self.infoTotalAmount = 0.0f;
        self.infoDescription = @"";
        self.infoCurrency = @"";
        self.infoCountry = @"";
        self.infoCurrencyString = @"";
        
        self.infoLStrSavedCard = @"Saved Cards";
        self.infoLStrAddCard = @"Add New Card";
        self.infoLStrTotalAmount = @"Total Amount";
    }
    return self;
}
@end

@implementation PaystackConfig
static PaystackConfig *managerPaystack = nil;
+ (id)sharedManager {
    @synchronized(self) {
        if (managerPaystack == nil){
            managerPaystack = [[self alloc] init];
        }
    }
    return managerPaystack;
}
- (id)init {
    self = [super self];
    if (self) {
        self.cPaystackPublishableKey = @"";
        self.cPaystackSecretKey = @"";
        self.cBackendChargeURLString = @"";
        self.cIsEnabled = false;
        self.cIsDefaultGateway = false;
        self.cId = [NSString stringWithFormat:@"%@", PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_PAYSTACK]];
        self.cTitle = [NSString stringWithFormat:@""];
        self.infoTotalAmount = 0.0f;
        self.infoDescription = @"";
        self.infoCurrency = @"";
        self.infoCountry = @"";
        self.infoCurrencyString = @"";
        self.infoEmail = @"";
    }
    return self;
}
@end


@implementation ApplePayViaStripeConfig
static ApplePayViaStripeConfig *managerApplePayViaStripe = nil;
+ (id)sharedManager {
    @synchronized(self) {
        if (managerApplePayViaStripe == nil){
            managerApplePayViaStripe = [[self alloc] init];
        }
    }
    return managerApplePayViaStripe;
}
- (id)init {
    self = [super self];
    if (self) {
        self.cStripePublishableKey = @"";
        self.cStripeSecretKey = @"";
        self.cBackendChargeURLString = @"";
        self.cApplePayMerchantId = @"";
        self.cIsEnabled = false;
        self.cIsDefaultGateway = false;
        self.cId = [NSString stringWithFormat:@"%@", PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_APPLE_PAY_VIA_STRIPE]];
        self.cTitle = [NSString stringWithFormat:@""];
        
        
        self.infoTotalAmount = 0.0f;
        self.infoDescription = @"";
        self.infoCurrency = @"";
        self.infoCountry = @"";
    }
    return self;
}
@end
@implementation PayPalConfig
static PayPalConfig *managerPayPal = nil;
+ (id)sharedManager {
    @synchronized(self) {
        if (managerPayPal == nil){
            managerPayPal = [[self alloc] init];
        }
    }
    return managerPayPal;
}
- (id)init {
    self = [super self];
    if (self) {
        self.cPayPalClientId = @"";
        self.cPayPalSandboxId = @"";
        self.cIsEnabled = false;
        self.cEnableCreditCard = true;
        
        self.infoTotalAmount = 0.0f;
        self.infoDescription = @"";
        self.infoCurrency = @"";
        self.infoCountry = @"";
    }
    return self;
}
@end

@implementation PayuConfig
static PayuConfig *managerPayu = nil;
+ (id)sharedManager {
    @synchronized(self) {
        if (managerPayu == nil){
            managerPayu = [[self alloc] init];
        }
    }
    return managerPayu;
}
- (id)init {
    self = [super self];
    if (self) {
        self.cName = @"";
        self.cPayuMerchantKey = @"";
        self.cPayuSaltKey = @"";
        self.cSuccessUrl = @"";
        self.cFailureUrl = @"";
        self.cServiceProvider = @"";
        self.cIsEnabled = false;
    }
    return self;
}
@end

@implementation BraintreeConfig
static BraintreeConfig *managerBraintree = nil;
+ (id)sharedManager {
    @synchronized(self) {
        if (managerBraintree == nil){
            managerBraintree = [[self alloc] init];
        }
    }
    return managerBraintree;
}
- (id)init {
    self = [super self];
    if (self) {
        self.cId = [NSString stringWithFormat:@"%@", PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_BRAINTREE]];
        self.cFailureUrl = @"";
        self.cSuccessUrl = @"";
        self.cBaseUrl = @"";
        self.cIsEnabled = false;
        self.cIsDefaultGateway = false;
        self.cTitle = [NSString stringWithFormat:@""];
        self.infoTotalAmount = 0.0f;
        self.infoCurrency = @"";
    }
    return self;
}
@end

@implementation MyGateConfig
static MyGateConfig *managerMyGate = nil;
+ (id)sharedManager {
    @synchronized(self) {
        if (managerMyGate == nil){
            managerMyGate = [[self alloc] init];
        }
    }
    return managerMyGate;
}
- (id)init {
    self = [super self];
    if (self) {
        self.cId = [NSString stringWithFormat:@"%@", PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_MYGATE]];
        self.cFailureUrl = @"";
        self.cSuccessUrl = @"";
        self.cBaseUrl = @"";
        self.cIsEnabled = false;
        self.cIsDefaultGateway = false;
        self.cTitle = [NSString stringWithFormat:@""];
        self.infoTotalAmount = 0.0f;
        self.infoCurrency = @"";
    }
    return self;
}
@end


@implementation AuthorizeNetConfig
static AuthorizeNetConfig *managerAuthorizeNet = nil;
+ (id)sharedManager {
    @synchronized(self) {
        if (managerAuthorizeNet == nil){
            managerAuthorizeNet = [[self alloc] init];
        }
    }
    return managerAuthorizeNet;
}
- (id)init {
    self = [super self];
    if (self) {
        self.cId = [NSString stringWithFormat:@"%@", PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_AUTHORIZENET]];
        self.cBaseUrl = @"";
        self.cSuccessUrl = @"";
        self.cFailureUrl = @"";
        self.cIsEnabled = false;
        self.cIsDefaultGateway = false;
        self.cTitle = [NSString stringWithFormat:@""];
        self.infoTotalAmount = 0.0f;
        self.infoDescription = @"";
        self.infoCurrency = @"";
        self.infoPhone = @"";
        self.infoEmail = @"";
        self.infoState = @"";
        self.infoCountry = @"";
        self.infoAddress = @"";
        self.infoCity = @"";
        self.infoPostCode = @"";
        self.infoPlatform = @"";
        self.infoFirstName = @"";
        self.infoLastName = @"";
        self.infoOrderId = @"";
    }
    return self;
}
@end

@implementation SenangPayPaymentConfig
static SenangPayPaymentConfig *managerSenangPay = nil;
+ (id)sharedManager {
    @synchronized(self) {
        if (managerSenangPay == nil){
            managerSenangPay = [[self alloc] init];
        }
    }
    return managerSenangPay;
}
- (id)init {
    self = [super self];
    if (self) {
        self.cId = [NSString stringWithFormat:@"%@", PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_SENANGPAY_PAYMENT]];
        self.cBaseUrl = @"";
        self.cSuccessUrl = @"";
        self.cFailureUrl = @"";
        self.cIsEnabled = false;
        self.cIsDefaultGateway = false;
        self.cTitle = [NSString stringWithFormat:@""];
        self.infoTotalAmount = 0.0f;
        self.infoDescription = @"";
        self.infoPhone = @"";
        self.infoEmail = @"";
        self.infoName = @"";
        self.infoOrderId = @"";
    }
    return self;
}
@end

@implementation MolliePaymentConfig
static MolliePaymentConfig *managerMollie = nil;
+ (id)sharedManager {
    @synchronized(self) {
        if (managerMollie == nil){
            managerMollie = [[self alloc] init];
        }
    }
    return managerMollie;
}
- (id)init {
    self = [super self];
    if (self) {
        self.cId = [NSString stringWithFormat:@"%@", PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_MOLLIE_PAYMENT]];
        self.cBaseUrl = @"";
        self.cSuccessUrl = @"";
        self.cFailureUrl = @"";
        self.cIsEnabled = false;
        self.cIsDefaultGateway = false;
        self.cTitle = [NSString stringWithFormat:@""];
        self.infoTotalAmount = 0.0f;
        self.infoDescription = @"";
        self.infoPhone = @"";
        self.infoEmail = @"";
        self.infoName = @"";
        self.infoOrderId = @"";
    }
    return self;
}
@end

@implementation HesabePaymentConfig
static HesabePaymentConfig *managerHesabe = nil;
+ (id)sharedManager {
    @synchronized(self) {
        if (managerHesabe == nil){
            managerHesabe = [[self alloc] init];
        }
    }
    return managerHesabe;
}
- (id)init {
    self = [super self];
    if (self) {
        self.cId = [NSString stringWithFormat:@"%@", PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_HESABE_PAYMENT]];
        self.cBaseUrl = @"";
        self.cSuccessUrl = @"";
        self.cFailureUrl = @"";
        self.cIsEnabled = false;
        self.cIsDefaultGateway = false;
        self.cTitle = [NSString stringWithFormat:@""];
        self.infoTotalAmount = 0.0f;
        self.infoDescription = @"";
        self.infoPhone = @"";
        self.infoEmail = @"";
        self.infoName = @"";
        self.infoOrderId = @"";
    }
    return self;
}
@end


@implementation ConektaCardConfig
static ConektaCardConfig *managerConekta = nil;
+ (id)sharedManager {
    @synchronized(self) {
        if (managerConekta == nil){
            managerConekta = [[self alloc] init];
        }
    }
    return managerConekta;
}
- (id)init {
    self = [super self];
    if (self) {
        self.cId = [NSString stringWithFormat:@"%@", PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_CONEKTA_CARD]];
        self.cBaseUrl = @"";
        self.cSuccessUrl = @"";
        self.cFailureUrl = @"";
        self.cIsEnabled = false;
        self.cIsDefaultGateway = false;
        self.cTitle = [NSString stringWithFormat:@""];
        self.infoTotalAmount = 0.0f;
        self.infoDescription = @"";
        self.infoPhone = @"";
        self.infoEmail = @"";
        self.infoName = @"";
        self.infoOrderId = @"";
    }
    return self;
}
@end


@implementation DusupayConfig
static DusupayConfig *managerDusupay = nil;
+ (id)sharedManager {
    @synchronized(self) {
        if (managerDusupay == nil){
            managerDusupay = [[self alloc] init];
        }
    }
    return managerDusupay;
}
- (id)init {
    self = [super self];
    if (self) {
        self.cId = [NSString stringWithFormat:@"%@", PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_DUSUPAY]];
        self.cMerchantId = @"";
        self.cSuccessUrl = @"";
        self.cRedirectUrl = @"";
        self.cIsEnabled = false;
        self.cIsDefaultGateway = false;
        self.cIsSandboxMode = false;
        self.cTitle = [NSString stringWithFormat:@""];
        self.infoTotalAmount = 0.0f;
        self.infoCurrency = @"";
    }
    return self;
}
@end


@implementation CCAvenueConfig
static CCAvenueConfig *mCCAvenueConfig = nil;
+ (id)getInstance {
    @synchronized(self) {
        if (mCCAvenueConfig == nil){
            mCCAvenueConfig = [[self alloc] init];
        }
    }
    return mCCAvenueConfig;
}
- (id)init {
    self = [super self];
    if (self) {
        self.gateway = @"";
        self.merchantId = @"";
        self.accessCode = @"";
        self.redirectUrl = @"";
        self.cancelUrl = @"";
        self.rsaKeyUrl = @"";
        self.enabled = false;
        self.cIsEnabled = false;
    }
    return self;
}
@end

@implementation AccountDetails
- (id)init {
    self = [super self];
    if (self) {
        PLOG(@"AccountDetails INIT");
        _account_name = @"";
        _account_number = @"";
        _bank_name = @"";
        _bic = @"";
        _iban = @"";
        _sort_code = @"";
    }
    return self;
}
@end


@implementation TMPaymentGateway
- (id)init {
    self = [super self];
    if (self) {
        PLOG(@"TMPaymentGateway INIT");
        _paymentId = @"";
        _paymentTitle = @"";
        _paymentDescription = @"";
        _paymentIconPath = @"";
        _paymentOrderButtonText = @"";
        _isPaymentEnabled = YES;
        _isPaymentTestModeEnabled = NO;
        _isPaymentGatewayChoosen = NO;
        _paymentAccountDetails = [[NSMutableArray alloc] init];
        _gatewaySettings = nil;
        _isPrepaid = true;
    }
    return self;
}
- (id)initWithDictionary:(NSDictionary*) dict {
    self = [self init];
    if (IS_NOT_NULL(dict, @"account_details")) {
        NSMutableArray* tempArray = GET_VALUE_OBJECT(dict, @"account_details");
        if (tempArray) {
            for (NSDictionary* tempDict in tempArray) {
                AccountDetails* acd = [[AccountDetails alloc] init];
                [_paymentAccountDetails addObject:acd];
                if (IS_NOT_NULL(tempDict, @"account_name")) {
                    acd.account_name = GET_VALUE_OBJECT(tempDict, @"account_name");
                }
                if (IS_NOT_NULL(tempDict, @"account_number")) {
                    acd.account_number = GET_VALUE_OBJECT(tempDict, @"account_number");
                }
                if (IS_NOT_NULL(tempDict, @"bank_name")) {
                    acd.bank_name = GET_VALUE_OBJECT(tempDict, @"bank_name");
                }
                if (IS_NOT_NULL(tempDict, @"bic")) {
                    acd.bic = GET_VALUE_OBJECT(tempDict, @"bic");
                }
                if (IS_NOT_NULL(tempDict, @"iban")) {
                    acd.iban = GET_VALUE_OBJECT(tempDict, @"iban");
                }
                if (IS_NOT_NULL(tempDict, @"sort_code")) {
                    acd.sort_code = GET_VALUE_OBJECT(tempDict, @"sort_code");
                }
            }
        }
    }
    
    if (IS_NOT_NULL(dict, @"id")) {
        _paymentId = GET_VALUE_STRING(dict, @"id");
    }
    if (IS_NOT_NULL(dict, @"title")) {
        _paymentTitle = GET_VALUE_STRING(dict, @"title");
    }
    if (IS_NOT_NULL(dict, @"description")) {
        _paymentDescription = GET_VALUE_STRING(dict, @"description");
    }
    if (IS_NOT_NULL(dict, @"instructions")) {
        _paymentInstruction = GET_VALUE_STRING(dict, @"instructions");
    }
    if (IS_NOT_NULL(dict, @"icon")) {
        _paymentIconPath = GET_VALUE_STRING(dict, @"icon");
    }
    if (IS_NOT_NULL(dict, @"order_button_text")) {
        _paymentOrderButtonText = GET_VALUE_STRING(dict, @"order_button_text");
    }
    if (IS_NOT_NULL(dict, @"enabled")) {
        _isPaymentEnabled = GET_VALUE_BOOL(dict, @"enabled");
    }
    if (IS_NOT_NULL(dict, @"testmode")) {
        _isPaymentTestModeEnabled = GET_VALUE_BOOL(dict, @"testmode");
    }
    if (IS_NOT_NULL(dict, @"chosen")) {
        _isPaymentGatewayChoosen = GET_VALUE_BOOL(dict, @"chosen");
    }
    if (IS_NOT_NULL(dict, @"settings")) {
        NSDictionary* settingDict = GET_VALUE_OBJECT_DEFAULT(dict, @"settings", nil);
        if (settingDict && [settingDict isKindOfClass:[NSDictionary class]]) {
            _gatewaySettings = [[GatewaySettings alloc] init];
            if (IS_NOT_NULL(settingDict, @"extra_charges")) {
                _gatewaySettings.extraCharges = GET_VALUE_STRING(settingDict, @"extra_charges");
            }
            if (IS_NOT_NULL(settingDict, @"extra_charges_msg")) {
                _gatewaySettings.extraChargesMessage = GET_VALUE_STRING(settingDict, @"extra_charges_msg");
            }
            if (IS_NOT_NULL(settingDict, @"extra_charges_type")) {
                _gatewaySettings.extraChargesType = GET_VALUE_STRING(settingDict, @"extra_charges_type");
            }
            if (IS_NOT_NULL(settingDict, @"cod_pincodes")) {
                _gatewaySettings.cod_pincodes = GET_VALUE_STRING(settingDict, @"cod_pincodes");
            }
            if (IS_NOT_NULL(settingDict, @"in_ex_pincode")) {
                _gatewaySettings.in_ex_pincode = GET_VALUE_STRING(settingDict, @"in_ex_pincode");
            }
        }
    }
    return self;
}
- (NSString*)getAccountDetailsString {
    NSString* str = @"";
    if(_paymentAccountDetails && (int)[_paymentAccountDetails count] > 0){
        int i = 0;
        for (AccountDetails* acd in _paymentAccountDetails) {
            if (i == 0) {
                str = [NSString stringWithFormat:@"%@Account Name: %@\nAccount Number: %@\nBank Name: %@\nSort Code: %@\nIBAN: %@\nBIC: %@", str, acd.account_name, acd.account_number, acd.bank_name, acd.sort_code, acd.iban, acd.bic];
            }else {
                str = [NSString stringWithFormat:@"%@\n\nAccount Name: %@\nAccount Number: %@\nBank Name: %@\nSort Code: %@\nIBAN: %@\nBIC: %@", str, acd.account_name, acd.account_number, acd.bank_name, acd.sort_code, acd.iban, acd.bic];
            }
            i++;
        }
    }
    return str;
}
- (void)payAmount:(float)amount currencyCode:(NSString*)currencyCode delegate:(id)delegate  {
    PLOG("payAmount method called %.2f", amount);
    NSString* amountStr = [NSString stringWithFormat:@"%.2f", amount];
    TMPaymentSDK* tmPaymentSDK = (TMPaymentSDK*)_sdkObj;
    [tmPaymentSDK.paymentDelegate setDelegate:delegate];
    self.delegate = delegate;
    
    if (
        [self.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_COD]] ||
        [self.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_DBT]] ||
        [self.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_CHEQUE]] ||
        [self.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_JETPACK1]] ||
        [self.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_JETPACK2]] ||
        [self.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_JETPACK3]]
        ) {
        [tmPaymentSDK.paymentDelegate postCompletionCallbackWithSuccess:nil];
    }
    else if ([self.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_PAYPAL]]) {
#if ENABLE_PAYPAL
        BOOL initializeGatewaySuccess = [self initializeGateway];
        if(!initializeGatewaySuccess)
            return;
        
        PayPalConfig* paypalConfig = [PayPalConfig sharedManager];
        PayPalPayment *payment = [[PayPalPayment alloc] init];
        [payment setAmount:[[NSDecimalNumber alloc] initWithString:amountStr]];
        payment.currencyCode = paypalConfig.infoCurrency;
        payment.shortDescription = paypalConfig.infoDescription;
        payment.items = NULL;  // if not including multiple items, then leave payment.items as nil
        payment.paymentDetails = NULL; // if not including payment details, then leave payment.paymentDetails as nil
        
        
        if (payment.processable) {
            PayPalConfiguration* payPalConfiguration = [[PayPalConfiguration alloc] init];
            payPalConfiguration.acceptCreditCards = paypalConfig.cEnableCreditCard;
            PayPalPaymentViewController* paymentViewController = [[PayPalPaymentViewController alloc] initWithPayment:payment configuration:payPalConfiguration delegate:tmPaymentSDK.paymentDelegate];
            [self.delegate presentViewController:paymentViewController animated:YES completion:nil];
        } else {
            PLOG(@"payment unable to process for this currency");
            [tmPaymentSDK.paymentDelegate postCompletionCallbackWithFailure:nil];
        }
#else
        [tmPaymentSDK.paymentDelegate postCompletionCallbackWithFailure:nil];
#endif
        
    }
    else if ([self.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_PAYU_IN]] || [self.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_PAYU_INDIA]]) {
#if ENABLE_PAYU
        NSMutableDictionary* payuMoneyDict = [[NSMutableDictionary alloc] init];
        [payuMoneyDict setObject:[NSNumber numberWithBool:false] forKey:@"IsTestModeEnable"];
        [payuMoneyDict setObject:[[PayuConfig sharedManager] cPayuMerchantKey] forKey:@"MerchantKey"];
        [payuMoneyDict setObject:[[PayuConfig sharedManager] cPayuSaltKey] forKey:@"SaltKey"];
        [payuMoneyDict setObject:[[PayuConfig sharedManager] cSuccessUrl] forKey:@"SuccessUrl"];
        [payuMoneyDict setObject:[[PayuConfig sharedManager] cFailureUrl] forKey:@"FailureUrl"];
        [payuMoneyDict setObject:[[PayuConfig sharedManager] cServiceProvider] forKey:@"ServiceProvider"];
        [payuMoneyDict setObject:tmPaymentSDK.paymentDelegate forKey:@"Delegate"];

        float amount =  [[PayuConfig sharedManager] infoTotalAmount];
        [payuMoneyDict setObject:@"ProductInfo" forKey:@"ProductInfo"];
        [payuMoneyDict setObject:[NSString stringWithFormat:@"%.2f", amount] forKey:@"Amount"];
        [payuMoneyDict setObject:[[PayuConfig sharedManager] infoName] forKey:@"Name"];
        [payuMoneyDict setObject:[[PayuConfig sharedManager] infoEmail] forKey:@"Email"];
        [payuMoneyDict setObject:[[PayuConfig sharedManager] infoPhone] forKey:@"Phone"];
        
        PaymentPageViewController* paymentViewController =  [[PaymentPageViewController alloc] initWithPayment:payuMoneyDict];
        UINavigationController *navigation = [[UINavigationController alloc]initWithRootViewController:paymentViewController];
        [self.delegate presentViewController:navigation animated:YES completion:nil];
#else
        TMPaymentSDK* tmPaymentSDK = (TMPaymentSDK*)_sdkObj;
        [tmPaymentSDK.paymentDelegate postCompletionCallbackWithFailure:nil];
#endif
    }
    else if ([self.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_DUSUPAY]]) {
#if ENABLE_DUSUPAY
        NSMutableDictionary* dusupayDict = [[NSMutableDictionary alloc] init];
        [dusupayDict setObject:tmPaymentSDK.paymentDelegate forKey:@"Delegate"];
        DusupayViewController* paymentViewController =  [[DusupayViewController alloc] initWithPayment:dusupayDict];
        UINavigationController *navigation = [[UINavigationController alloc]initWithRootViewController:paymentViewController];
        [self.delegate presentViewController:navigation animated:YES completion:nil];
        
#else
        TMPaymentSDK* tmPaymentSDK = (TMPaymentSDK*)_sdkObj;
        [tmPaymentSDK.paymentDelegate postCompletionCallbackWithFailure:nil];
#endif
    }
    else if ([self.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_STRIPE]]) {
#if ENABLE_STRIPE
        BOOL initializeGatewaySuccess = [self initializeGateway];
        if(!initializeGatewaySuccess)
            return;
//        STPPaymentMethodsViewController* spViewController = [[STPPaymentMethodsViewController alloc] init];
//        STPAddCardViewController* spViewController = [[STPAddCardViewController alloc] init];
        SPViewController* spViewController = [[SPViewController alloc] initWithDelegate:tmPaymentSDK.paymentDelegate];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:spViewController];
        [self.delegate presentViewController:navController animated:YES completion:nil];
#else
        [tmPaymentSDK.paymentDelegate postCompletionCallbackWithFailure:nil];
#endif
    }
    else if ([self.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_PAYSTACK]]) {
#if ENABLE_PAYSTACK
//        BOOL initializeGatewaySuccess = [self initializeGateway];
//        if(!initializeGatewaySuccess)
//            return;
//        PaystackViewController *paystackViewController = [[PaystackViewController alloc] initWithNibName:nil bundle:nil];
//        PaystackConfig* paystackConfig = [PaystackConfig sharedManager];
//        NSString* amountString = [NSString stringWithFormat:@"%.2f", paystackConfig.infoTotalAmount];
//        paystackViewController.amount = [NSDecimalNumber decimalNumberWithString:amountString];
//        paystackViewController.responseDelegate = tmPaymentSDK.paymentDelegate;
//        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:paystackViewController];
//        [self.delegate presentViewController:navController animated:YES completion:nil];
        
        [tmPaymentSDK.paymentDelegate postCompletionCallbackWithFailure:@"not_implemented_here"];
#else
        [tmPaymentSDK.paymentDelegate postCompletionCallbackWithFailure:nil];
#endif
    }
    else if ([self.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_APPLE_PAY_VIA_STRIPE]]) {
#if ENABLE_APPLE_PAY_VIA_STRIPE
        BOOL initializeGatewaySuccess = [self initializeGateway];
        if(!initializeGatewaySuccess)
            return;
        
        
        ApplePayViaStripeConfig* configApplePayViaStripe = [ApplePayViaStripeConfig sharedManager];
        PKPaymentRequest *paymentRequest = [Stripe paymentRequestWithMerchantIdentifier:configApplePayViaStripe.cApplePayMerchantId];
        paymentRequest.paymentSummaryItems = @[
//                                                                                          [PKPaymentSummaryItem summaryItemWithLabel:@"Fancy Hat" amount:[NSDecimalNumber decimalNumberWithString:@"50.00"]],
//                                                                                          [PKPaymentSummaryItem summaryItemWithLabel:@"Fancy Cat" amount:[NSDecimalNumber decimalNumberWithString:@"150.00"]],
//                                                the final line should represent your company; it'll be prepended with the word "Pay" (i.e. "Pay iHats, Inc $50")
                                               [PKPaymentSummaryItem summaryItemWithLabel:configApplePayViaStripe.infoDescription amount:[NSDecimalNumber decimalNumberWithString:amountStr]],
                                               ];
        
        
        
        paymentRequest.merchantIdentifier = configApplePayViaStripe.cApplePayMerchantId;
        paymentRequest.supportedNetworks = @[PKPaymentNetworkAmex, PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkDiscover];
        paymentRequest.merchantCapabilities = PKMerchantCapability3DS;//|PKMerchantCapabilityEMV;
        paymentRequest.countryCode = configApplePayViaStripe.infoCountry;
        paymentRequest.currencyCode = configApplePayViaStripe.infoCurrency;

        
        if ([Stripe canSubmitPaymentRequest:paymentRequest]) {
            PKPaymentAuthorizationViewController *paymentAuthorizationVC = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:paymentRequest];
            paymentAuthorizationVC.delegate = tmPaymentSDK.paymentDelegate;
            [self.delegate presentViewController:paymentAuthorizationVC animated:YES completion:nil];
        } else {
            // there is a problem with your Apple Pay configuration.
            [tmPaymentSDK.paymentDelegate postCompletionCallbackWithFailure:nil];
        }
#else
        [tmPaymentSDK.paymentDelegate postCompletionCallbackWithFailure:nil];
#endif
    }
    else if ([self.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_SAGEPAY]]) {
#if ENABLE_SAGEPAY
        BOOL initializeGatewaySuccess = [self initializeGateway];
        if(!initializeGatewaySuccess)
            return;
        SagepayViewController* paymentViewController = [[SagepayViewController alloc] initWithDelegate:tmPaymentSDK.paymentDelegate];
        UINavigationController *navigation = [[UINavigationController alloc]initWithRootViewController:paymentViewController];
        [self.delegate presentViewController:navigation animated:YES completion:nil];
#else
        [tmPaymentSDK.paymentDelegate postCompletionCallbackWithFailure:nil];
#endif
    }
    else if ([self.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_GESTPAY]]) {
#if ENABLE_GESTPAY
        BOOL initializeGatewaySuccess = [self initializeGateway];
        if(!initializeGatewaySuccess)
            return;
        GestpayViewController* paymentViewController = [[GestpayViewController alloc] initWithDelegate:tmPaymentSDK.paymentDelegate];
        UINavigationController *navigation = [[UINavigationController alloc]initWithRootViewController:paymentViewController];
        [self.delegate presentViewController:navigation animated:YES completion:nil];
#else
        [tmPaymentSDK.paymentDelegate postCompletionCallbackWithFailure:nil];
#endif
    }
    else if ([self.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_KENT_PAYMENT]]) {
#if ENABLE_KENT_PAYMENT
        BOOL initializeGatewaySuccess = [self initializeGateway];
        if(!initializeGatewaySuccess)
            return;
        KentPaymentViewController* paymentViewController = [[KentPaymentViewController alloc] initWithDelegate:tmPaymentSDK.paymentDelegate];
        UINavigationController *navigation = [[UINavigationController alloc]initWithRootViewController:paymentViewController];
        [self.delegate presentViewController:navigation animated:YES completion:nil];
#else
        [tmPaymentSDK.paymentDelegate postCompletionCallbackWithFailure:nil];
#endif
    }
    else if ([self.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_PAYPAL_PAYFLOW]]) {
#if ENABLE_PAYPAL_PAYFLOW
        BOOL initializeGatewaySuccess = [self initializeGateway];
        if(!initializeGatewaySuccess)
            return;
        PayPalPayFlowViewController* paymentViewController = [[PayPalPayFlowViewController alloc] initWithDelegate:tmPaymentSDK.paymentDelegate];
        UINavigationController *navigation = [[UINavigationController alloc]initWithRootViewController:paymentViewController];
        [self.delegate presentViewController:navigation animated:YES completion:nil];
#else
        [tmPaymentSDK.paymentDelegate postCompletionCallbackWithFailure:nil];
#endif
    }
    else if ([self.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_VCS_PAY]]) {
#if ENABLE_VCS_PAY
//        BOOL initializeGatewaySuccess = [self initializeGateway];
//        if(!initializeGatewaySuccess)
//            return;
//        VCSPayViewController* paymentViewController = [[VCSPayViewController alloc] initWithDelegate:tmPaymentSDK.paymentDelegate];
//        UINavigationController *navigation = [[UINavigationController alloc]initWithRootViewController:paymentViewController];
//        [self.delegate presentViewController:navigation animated:YES completion:nil];
        [tmPaymentSDK.paymentDelegate postCompletionCallbackWithFailure:@"not_implemented_here"];
#else
        [tmPaymentSDK.paymentDelegate postCompletionCallbackWithFailure:nil];
#endif
    }
    else if ([self.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_TAP_PAYMENT]]) {
#if ENABLE_TAP_PAYMENT
        BOOL initializeGatewaySuccess = [self initializeGateway];
        if(!initializeGatewaySuccess)
            return;
        TapPaymentViewController* paymentViewController = [[TapPaymentViewController alloc] initWithDelegate:tmPaymentSDK.paymentDelegate];
        UINavigationController *navigation = [[UINavigationController alloc]initWithRootViewController:paymentViewController];
        [self.delegate presentViewController:navigation animated:YES completion:nil];
#else
        [tmPaymentSDK.paymentDelegate postCompletionCallbackWithFailure:nil];
#endif
    }
    else if ([self.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_PLUGNPAY_PAYMENT]]) {
#if ENABLE_PLUGNPAY_PAYMENT
        BOOL initializeGatewaySuccess = [self initializeGateway];
        if(!initializeGatewaySuccess)
            return;
        PlugNPayPaymentViewController* paymentViewController = [[PlugNPayPaymentViewController alloc] initWithDelegate:tmPaymentSDK.paymentDelegate];
        UINavigationController *navigation = [[UINavigationController alloc]initWithRootViewController:paymentViewController];
        [self.delegate presentViewController:navigation animated:YES completion:nil];
#else
        [tmPaymentSDK.paymentDelegate postCompletionCallbackWithFailure:nil];
#endif
    }
    else if ([self.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_SENANGPAY_PAYMENT]]) {
#if ENABLE_SENANGPAY_PAYMENT
        BOOL initializeGatewaySuccess = [self initializeGateway];
        if(!initializeGatewaySuccess)
            return;
        SenangPayPaymentViewController* paymentViewController = [[SenangPayPaymentViewController alloc] initWithDelegate:tmPaymentSDK.paymentDelegate];
        UINavigationController *navigation = [[UINavigationController alloc]initWithRootViewController:paymentViewController];
        [self.delegate presentViewController:navigation animated:YES completion:nil];
#else
        [tmPaymentSDK.paymentDelegate postCompletionCallbackWithFailure:nil];
#endif
    }
    else if ([self.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_MOLLIE_PAYMENT]]) {
#if ENABLE_MOLLIE_PAYMENT
        BOOL initializeGatewaySuccess = [self initializeGateway];
        if(!initializeGatewaySuccess)
            return;
        MolliePaymentViewController* paymentViewController = [[MolliePaymentViewController alloc] initWithDelegate:tmPaymentSDK.paymentDelegate];
        UINavigationController *navigation = [[UINavigationController alloc]initWithRootViewController:paymentViewController];
        [self.delegate presentViewController:navigation animated:YES completion:nil];
#else
        [tmPaymentSDK.paymentDelegate postCompletionCallbackWithFailure:nil];
#endif
    }
    else if ([self.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_HESABE_PAYMENT]]) {
#if ENABLE_HESABE_PAYMENT
        BOOL initializeGatewaySuccess = [self initializeGateway];
        if(!initializeGatewaySuccess)
            return;
        HesabePaymentViewController* paymentViewController = [[HesabePaymentViewController alloc] initWithDelegate:tmPaymentSDK.paymentDelegate];
        UINavigationController *navigation = [[UINavigationController alloc]initWithRootViewController:paymentViewController];
        [self.delegate presentViewController:navigation animated:YES completion:nil];
#else
        [tmPaymentSDK.paymentDelegate postCompletionCallbackWithFailure:nil];
#endif
    }
    else if ([self.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_CONEKTA_CARD]]) {
#if ENABLE_CONEKTA_CARD
        BOOL initializeGatewaySuccess = [self initializeGateway];
        if(!initializeGatewaySuccess)
            return;
        ConektaCardPaymentVC* paymentViewController = [[ConektaCardPaymentVC alloc] initWithDelegate:tmPaymentSDK.paymentDelegate];
        UINavigationController *navigation = [[UINavigationController alloc]initWithRootViewController:paymentViewController];
        [self.delegate presentViewController:navigation animated:YES completion:nil];
#else
        [tmPaymentSDK.paymentDelegate postCompletionCallbackWithFailure:nil];
#endif
    }
    else if ([self.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_BRAINTREE]]) {
#if ENABLE_BRAINTREE
        BOOL initializeGatewaySuccess = [self initializeGateway];
        if(!initializeGatewaySuccess)
            return;
        BraintreeViewController* paymentViewController = [[BraintreeViewController alloc] initWithDelegate:tmPaymentSDK.paymentDelegate];
        UINavigationController *navigation = [[UINavigationController alloc]initWithRootViewController:paymentViewController];
        [self.delegate presentViewController:navigation animated:YES completion:nil];
#else
        [tmPaymentSDK.paymentDelegate postCompletionCallbackWithFailure:nil];
#endif
    }
    else if ([self.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_MYGATE]]) {
#if ENABLE_MYGATE
        BOOL initializeGatewaySuccess = [self initializeGateway];
        if(!initializeGatewaySuccess)
            return;
        MyGateViewController* paymentViewController = [[MyGateViewController alloc] initWithDelegate:tmPaymentSDK.paymentDelegate];
        UINavigationController *navigation = [[UINavigationController alloc]initWithRootViewController:paymentViewController];
        [self.delegate presentViewController:navigation animated:YES completion:nil];
#else
        [tmPaymentSDK.paymentDelegate postCompletionCallbackWithFailure:nil];
#endif
    }
    else if ([self.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_AUTHORIZENET]]) {
#if ENABLE_AUTHORIZENET
        BOOL initializeGatewaySuccess = [self initializeGateway];
        if(!initializeGatewaySuccess)
            return;
        AuthorizeNetViewController* paymentViewController = [[AuthorizeNetViewController alloc] initWithDelegate:tmPaymentSDK.paymentDelegate];
        UINavigationController *navigation = [[UINavigationController alloc]initWithRootViewController:paymentViewController];
        [self.delegate presentViewController:navigation animated:YES completion:nil];
#else
        [tmPaymentSDK.paymentDelegate postCompletionCallbackWithFailure:nil];
#endif
    }
    else if ([self.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_CCAVENUE]]){
        CCAvenueController* paymentViewController = [[CCAvenueController alloc] initWithDelegate:tmPaymentSDK.paymentDelegate];
        UINavigationController *navigation = [[UINavigationController alloc]initWithRootViewController:paymentViewController];
        [self.delegate presentViewController:navigation animated:YES completion:nil];
    }
}
- (BOOL)initializeGateway {
    if ([self.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_COD]] ||
        [self.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_DBT]] ||
        [self.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_CHEQUE]] ||
        [self.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_JETPACK1]] ||
        [self.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_JETPACK2]] ||
        [self.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_JETPACK3]] ||
        [self.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_AUTHORIZENET]] ||
        [self.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_MYGATE]] ||
        [self.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_BRAINTREE]] ||
        [self.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_TAP_PAYMENT]] ||
        [self.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_PAYPAL_PAYFLOW]] ||
        [self.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_VCS_PAY]] ||
        [self.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_KENT_PAYMENT]] ||
        [self.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_GESTPAY]] ||
        [self.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_SAGEPAY]] ||
        [self.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_DUSUPAY]] ||
        [self.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_PAYU_IN]] ||
        [self.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_PAYU_INDIA]]
        ) {
    }
    else if ([self.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_PAYPAL]]) {
#if ENABLE_PAYPAL
        PayPalConfig* config = [PayPalConfig sharedManager];
        [PayPalMobile initializeWithClientIdsForEnvironments: @{PayPalEnvironmentProduction:config.cPayPalClientId, PayPalEnvironmentSandbox:config.cPayPalSandboxId}];
        // Set up payPalConfig
//        PayPalConfiguration* _payPalConfig = [[PayPalConfiguration alloc] init];
//        _payPalConfig.acceptCreditCards = YES;
//        _payPalConfig.merchantName = @"Awesome Shirts, Inc.";
//        _payPalConfig.merchantPrivacyPolicyURL = [NSURL URLWithString:@"https://www.paypal.com/webapps/mpp/ua/privacy-full"];
//        _payPalConfig.merchantUserAgreementURL = [NSURL URLWithString:@"https://www.paypal.com/webapps/mpp/ua/useragreement-full"];
        // Do any additional setup after loading the view, typically from a nib.
//        self.successView.hidden = YES;
        // use default environment, should be Production in real life
//        _payPalConfig.environment = PayPalEnvironmentProduction;
        @try {
            [PayPalMobile preconnectWithEnvironment:PayPalEnvironmentProduction];
        }
        @catch (NSException *exception) {
            PLOG(@"invalid client id");
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Invalid merchant" message:@"Payments to this merchant are not allowed (invalid clientId)" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [errorAlert show];
            return false;
        }
        @finally {
//            PLOG(@"invalid client key");
//            return false;
        }
#endif
    }
    else if([self.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_STRIPE]]){
#if ENABLE_STRIPE
        StripeConfig* config = [StripeConfig sharedManager];
        [Stripe setDefaultPublishableKey:config.cStripePublishableKey];
#endif
    }
    else if([self.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_PAYSTACK]]){
#if ENABLE_PAYSTACK
//        PaystackConfig* config = [PaystackConfig sharedManager];
//        [Paystack setDefaultPublicKey:config.cPaystackPublishableKey];
#endif
    }
    else if([self.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_APPLE_PAY_VIA_STRIPE]]){
#if ENABLE_APPLE_PAY_VIA_STRIPE
        ApplePayViaStripeConfig* config = [ApplePayViaStripeConfig sharedManager];
        [Stripe setDefaultPublishableKey:config.cStripePublishableKey];
        [[STPPaymentConfiguration sharedConfiguration] setAppleMerchantIdentifier:config.cApplePayMerchantId];
        BOOL result = [Stripe deviceSupportsApplePay];
        if (result == NO) {
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"" message:@"Either Apple Pay is not supported in your device or card is not added in your wallet app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [errorAlert show];
        }else{
            result = [self applePayEnabled];
            if (result == NO) {
                UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"" message:@"Either Apple Pay is not supported in your device or card is not added in your wallet app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [errorAlert show];
            }
        }
        return result;
#endif
    }
    return true;
}

- (BOOL)applePayEnabled {
    return YES;
#if TARGET_IPHONE_SIMULATOR
    return YES;
#else
    if ([PKPaymentRequest class]) {
        ApplePayViaStripeConfig* configApplePayViaStripe = [ApplePayViaStripeConfig sharedManager];
        PKPaymentRequest *paymentRequest = [Stripe paymentRequestWithMerchantIdentifier:configApplePayViaStripe.cApplePayMerchantId];
        paymentRequest.merchantIdentifier = configApplePayViaStripe.cApplePayMerchantId;
        paymentRequest.supportedNetworks = @[PKPaymentNetworkAmex, PKPaymentNetworkVisa, PKPaymentNetworkMasterCard];
        paymentRequest.merchantCapabilities = PKMerchantCapability3DS|PKMerchantCapabilityEMV;
        paymentRequest.countryCode = configApplePayViaStripe.infoCountry;
        paymentRequest.currencyCode = configApplePayViaStripe.infoCurrency;
        BOOL res = [Stripe canSubmitPaymentRequest:paymentRequest];
//        BOOL res = [PKPaymentAuthorizationViewController canMakePayments];
        return res;
    }
    return NO;
#endif
}
@end
