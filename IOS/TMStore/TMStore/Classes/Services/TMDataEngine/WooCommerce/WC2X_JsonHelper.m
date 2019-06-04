//
//  WC2X_JsonHelper.m
//  TMDataDoctor
//
//  Created by Rishabh Jain on 18/01/16.
//  Copyright © 2016 Twist Mobile Pvt. Ltd. India. All rights reserved.
//

#import "WC2X_JsonHelper.h"
#import "AppUser.h"
#import "Order.h"
#import "CommonInfo.h"
#import "Utility.h"
#import "LayoutManager.h"
#import "STHTTPRequest.h"
#import "Variables.h"
#import "AppUser.h"
#import "Variation.h"
#import "ServerData.h"
#import "CommonInfo.h"
#import "ProductInfo.h"
#import "ProductImage.h"
#import "Attribute.h"
#import "CategoryInfo.h"
#import "WC2X_Engine.h"
#import "LoginFlow.h"
#import "Country.h"
#import "Coupon.h"
#import "ProductReview.h"
#import <TMPaymentSDK/TMPaymentSDK.h>
#import "Addons.h"
#import "CustomMenu.h"
#import "Vendor.h"
#import <Stripe/Stripe.h>
#import "PermanentAttribute.h"
#import "WaitList.h"
#import "CWishList.h"
#import "TM_Tax.h"
#import "CartMeta.h"
#import "MinOrderData.h"
#import "FeeData.h"
#import "PincodeSetting.h"
#import "TM_MixMatch.h"
#import "TM_Bundle.h"
#import "DateTimeSlot.h"
#import "TimeSlot.h"
#import "TM_ProductFilter.h"
#import "TM_PickupLocation.h"
#import "TM_ProductDeliveryDate.h"
#import "TM_CheckoutAddon.h"
#import "ContactForm3Config.h"
#import "ReservationFormConfig.h"
#import "MultiStoreCheckoutConfig.h"
#import "SellerZoneManager.h"
#import "MapAddress.h"
#import "CurrencyItem.h"
#import "CurrencyHelper.h"

@implementation WC2X_JsonHelper
- (id)initWithEngine:(id)tmEngineObj{
    self = [super init];
    if (self) {
        _engineObj = tmEngineObj;
    }return self;
}
#pragma mark Load Data From Server
- (void)loadCustomerData:(NSDictionary*)dictionary {
    LoginFlow* loginFlow = [LoginFlow sharedManager];

    RLOG(@"CUSTOMER DATA1 = %@", dictionary);
    RLOG(@"Dictionary size = %d", (int)dictionary.count);
    AppUser* au = [AppUser sharedManager];
    NSDictionary* mainDict = nil;
    if (IS_NOT_NULL(dictionary, @"customer")){
        mainDict = [dictionary objectForKey:@"customer"];

        if (IS_NOT_NULL(mainDict, @"id")) {
            au._id = GET_VALUE_INT(mainDict, @"id");
        }
        if (IS_NOT_NULL(mainDict, @"orders_count")) {
            au._orders_count = GET_VALUE_INT(mainDict, @"orders_count");
        }
        if (IS_NOT_NULL(mainDict, @"last_order_id")) {
            au._last_order_id = GET_VALUE_INT(mainDict, @"last_order_id");
        }
        if (IS_NOT_NULL(mainDict, @"total_spent")) {
            au._total_spent = GET_VALUE_FLOAT(mainDict, @"total_spent");
        }
        if (IS_NOT_NULL(mainDict, @"avatar_url")) {
            au._avatar_url = GET_VALUE_STRING(mainDict, @"avatar_url");
            if ([au._avatar_url hasPrefix:@"//"]) {
                au._avatar_url = [au._avatar_url stringByReplacingOccurrencesOfString:@"//"
                                                                                         withString:@"https://"
                                                                                            options:0
                                                                                              range:NSMakeRange(0, 2)];
            }
            RLOG(@"au._avatar_url AvatarUrl : %@", au._avatar_url);

            
            
        }
        if (![loginFlow.userImage isEqualToString:@""]) {
            au._avatar_url = loginFlow.userImage;
            au._avatar_url = [au._avatar_url stringByReplacingOccurrencesOfString:@"//"
                                                                       withString:@"https://"
                                                                          options:0
                                                                            range:NSMakeRange(0, 2)];
        }
          RLOG(@"loginFlow AvatarUrl : %@", au._avatar_url);

        if (IS_NOT_NULL(mainDict, @"email")) {
            au._email = GET_VALUE_STRING(mainDict, @"email");
        }
        if (IS_NOT_NULL(mainDict, @"last_name")) {
            au._last_name = GET_VALUE_STRING(mainDict, @"last_name");
        }

        if (IS_NOT_NULL(mainDict, @"first_name")) {
            au._first_name = GET_VALUE_STRING(mainDict, @"first_name");
        }
        
        if (IS_NOT_NULL(mainDict, @"role")) {
            NSString* role = GET_VALUE_STRING(mainDict, @"role");
            au.ur_type_string = role;
            au.ur_type_title = role;
            au.ur_type = [AppUser getRoleType:role];
        }
        



        if (IS_NOT_NULL(mainDict, @"username")) {
            au._username = GET_VALUE_STRING(mainDict, @"username");
        }
        if (IS_NOT_NULL(mainDict, @"last_order_date")) {
            au._last_order_date = GET_VALUE_STRING(mainDict, @"last_order_date");
        }
        if (IS_NOT_NULL(mainDict, @"created_at")) {
            NSDateFormatter* df = [[NSDateFormatter alloc]init];
            [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
            NSString* str = GET_VALUE_STRING(mainDict, @"created_at");
            au._created_at = [df dateFromString:str];
        }
        if (IS_NOT_NULL(mainDict, @"updated_at")) {
            NSDateFormatter* df = [[NSDateFormatter alloc]init];
            [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
            NSString* str = GET_VALUE_STRING(mainDict, @"updated_at");
            au._updated_at = [df dateFromString:str];
        }
        if (IS_NOT_NULL(mainDict, @"billing_address")) {
            NSDictionary* billDict = (NSDictionary*)GET_VALUE_OBJECT(mainDict, @"billing_address");
            au._billing_address._address_1 = GET_VALUE_STRING(billDict, @"address_1");
            au._billing_address._address_2 = GET_VALUE_STRING(billDict, @"address_2");
            au._billing_address._city = GET_VALUE_STRING(billDict, @"city");
            au._billing_address._company = GET_VALUE_STRING(billDict, @"company");
            au._billing_address._countryId = GET_VALUE_STRING(billDict, @"country");
            au._billing_address._stateId = GET_VALUE_STRING(billDict, @"state");
            au._billing_address._first_name = GET_VALUE_STRING(billDict, @"first_name");
            au._billing_address._last_name = GET_VALUE_STRING(billDict, @"last_name");
            au._billing_address._email = GET_VALUE_STRING(billDict, @"email");
            au._billing_address._phone = GET_VALUE_STRING(billDict, @"phone");
            au._billing_address._postcode = GET_VALUE_STRING(billDict, @"postcode");
            au._billing_address._isBillingAddress = true;
            au._billing_address._isShippingAddress = false;
            au._billing_address._isAddressSaved = true;

            au._billing_addressFetched._address_1 = GET_VALUE_STRING(billDict, @"address_1");
            au._billing_addressFetched._address_2 = GET_VALUE_STRING(billDict, @"address_2");
            au._billing_addressFetched._city = GET_VALUE_STRING(billDict, @"city");
            au._billing_addressFetched._company = GET_VALUE_STRING(billDict, @"company");
            au._billing_addressFetched._countryId = GET_VALUE_STRING(billDict, @"country");
            au._billing_addressFetched._stateId = GET_VALUE_STRING(billDict, @"state");
            au._billing_addressFetched._first_name = GET_VALUE_STRING(billDict, @"first_name");
            au._billing_addressFetched._last_name = GET_VALUE_STRING(billDict, @"last_name");
            au._billing_addressFetched._email = GET_VALUE_STRING(billDict, @"email");
            au._billing_addressFetched._phone = GET_VALUE_STRING(billDict, @"phone");
            au._billing_addressFetched._postcode = GET_VALUE_STRING(billDict, @"postcode");
            au._billing_addressFetched._isBillingAddress = true;
            au._billing_addressFetched._isShippingAddress = false;
            au._billing_addressFetched._isAddressSaved = true;

            TMCountry* country =  [TMCountry getCountryById:au._billing_address._countryId];
            if (country) {
                au._billing_address._country  = [NSString stringWithFormat:@"%@",country.countryName];
                au._billing_addressFetched._country  = [NSString stringWithFormat:@"%@",country.countryName];
                TMState* state =  [TMState getStateById:country stateId:au._billing_address._stateId];
                if (state) {
                    au._billing_address._state  = [NSString stringWithFormat:@"%@",state.stateName];
                    au._billing_addressFetched._state  = [NSString stringWithFormat:@"%@",state.stateName];
                }
            }

        }
        if (IS_NOT_NULL(mainDict, @"shipping_address")) {
            NSDictionary* shipDict = (NSDictionary*)GET_VALUE_OBJECT(mainDict, @"shipping_address");
            au._shipping_address._address_1 = GET_VALUE_STRING(shipDict, @"address_1");
            au._shipping_address._address_2 = GET_VALUE_STRING(shipDict, @"address_2");
            au._shipping_address._city = GET_VALUE_STRING(shipDict, @"city");
            au._shipping_address._company = GET_VALUE_STRING(shipDict, @"company");
            au._shipping_address._countryId = GET_VALUE_STRING(shipDict, @"country");
            au._shipping_address._stateId = GET_VALUE_STRING(shipDict, @"state");
            au._shipping_address._first_name = GET_VALUE_STRING(shipDict, @"first_name");
            au._shipping_address._last_name = GET_VALUE_STRING(shipDict, @"last_name");
            au._shipping_address._email = au._billing_address._email;
            au._shipping_address._phone = au._billing_address._phone;
            au._shipping_address._postcode = GET_VALUE_STRING(shipDict, @"postcode");
            au._shipping_address._isBillingAddress = false;
            au._shipping_address._isShippingAddress = true;
            au._shipping_address._isAddressSaved = true;


            au._shipping_addressFetched._address_1 = GET_VALUE_STRING(shipDict, @"address_1");
            au._shipping_addressFetched._address_2 = GET_VALUE_STRING(shipDict, @"address_2");
            au._shipping_addressFetched._city = GET_VALUE_STRING(shipDict, @"city");
            au._shipping_addressFetched._company = GET_VALUE_STRING(shipDict, @"company");
            au._shipping_addressFetched._countryId = GET_VALUE_STRING(shipDict, @"country");
            au._shipping_addressFetched._stateId = GET_VALUE_STRING(shipDict, @"state");
            au._shipping_addressFetched._first_name = GET_VALUE_STRING(shipDict, @"first_name");
            au._shipping_addressFetched._last_name = GET_VALUE_STRING(shipDict, @"last_name");
            au._shipping_addressFetched._email = au._billing_addressFetched._email;
            au._shipping_addressFetched._phone = au._billing_addressFetched._phone;
            au._shipping_addressFetched._postcode = GET_VALUE_STRING(shipDict, @"postcode");
            au._shipping_addressFetched._isBillingAddress = false;
            au._shipping_addressFetched._isShippingAddress = true;
            au._shipping_addressFetched._isAddressSaved = true;


            TMCountry* country =  [TMCountry getCountryById:au._shipping_address._countryId];
            if (country) {
                au._shipping_address._country  = [NSString stringWithFormat:@"%@",country.countryName];
                au._shipping_addressFetched._country  = [NSString stringWithFormat:@"%@",country.countryName];
                TMState* state =  [TMState getStateById:country stateId:au._shipping_address._stateId];
                if (state) {
                    au._shipping_address._state  = [NSString stringWithFormat:@"%@",state.stateName];
                    au._shipping_addressFetched._state  = [NSString stringWithFormat:@"%@",state.stateName];
                }
            }
        }
    }

    RLOG(@"CUSTOMER DATA2 = %@", dictionary);
    [au saveData];
    [(WC2X_Engine*)_engineObj fetchOrdersData:nil];
}
- (Order*)parseOrderJsonWithOrderObject:(NSDictionary *)mainDict order:(Order*)order {
    if (order == nil) {
        order = [[Order alloc] init];
    }else{
        RLOG(@"");
    }

    if (IS_NOT_NULL(mainDict, @"id")) {
        order._id = GET_VALUE_INT(mainDict, @"id");
    }
    if (IS_NOT_NULL(mainDict, @"order_number")) {
        NSObject* order_number = GET_VALUE_OBJECT(mainDict, @"order_number");

        if ([order_number isKindOfClass:[NSString class]]) {
            order._order_number_str = GET_VALUE_OBJECT(mainDict, @"order_number");
        } else {
            order._order_number = GET_VALUE_INT(mainDict, @"order_number");
            order._order_number_str = [NSString stringWithFormat:@"%d", order._order_number];
        }

    }
    if (IS_NOT_NULL(mainDict, @"created_at")) {
        NSDateFormatter* df = [[NSDateFormatter alloc]init];
        [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
        NSString* str = GET_VALUE_STRING(mainDict, @"created_at");
        order._created_at = [df dateFromString:str];
    }
    if (IS_NOT_NULL(mainDict, @"updated_at")) {
        NSDateFormatter* df = [[NSDateFormatter alloc]init];
        [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
        NSString* str = GET_VALUE_STRING(mainDict, @"updated_at");
        order._updated_at = [df dateFromString:str];
    }
    if (IS_NOT_NULL(mainDict, @"completed_at")) {
        order._completed_at = GET_VALUE_STRING(mainDict, @"completed_at");
    }
    if (IS_NOT_NULL(mainDict, @"status")) {
        order._status = GET_VALUE_STRING(mainDict, @"status");
    }
    if (IS_NOT_NULL(mainDict, @"currency")) {
        order._currency = GET_VALUE_STRING(mainDict, @"currency");
    }
    if (IS_NOT_NULL(mainDict, @"total")) {
        order._total = GET_VALUE_STRING(mainDict, @"total");
    }
    if (IS_NOT_NULL(mainDict, @"subtotal")) {
        order._subtotal = GET_VALUE_STRING(mainDict, @"subtotal");
    }
    if (IS_NOT_NULL(mainDict, @"total_line_items_quantity")) {
        order._total_line_items_quantity = GET_VALUE_INT(mainDict, @"total_line_items_quantity");
    }
    if (IS_NOT_NULL(mainDict, @"total_tax")) {
        order._total_tax = GET_VALUE_FLOAT(mainDict, @"total_tax");
    }
    if (IS_NOT_NULL(mainDict, @"total_shipping")) {
        order._total_shipping = GET_VALUE_FLOAT(mainDict, @"total_shipping");
    }
    if (IS_NOT_NULL(mainDict, @"cart_tax")) {
        order._cart_tax = GET_VALUE_FLOAT(mainDict, @"cart_tax");
    }
    if (IS_NOT_NULL(mainDict, @"shipping_tax")) {
        order._shipping_tax = GET_VALUE_FLOAT(mainDict, @"shipping_tax");
    }
    if (IS_NOT_NULL(mainDict, @"total_discount")) {
        order._total_discount = GET_VALUE_FLOAT(mainDict, @"total_discount");
    }
    if (IS_NOT_NULL(mainDict, @"shipping_methods")) {
        order._shipping_methods = GET_VALUE_STRING(mainDict, @"shipping_methods");
    }
    if (IS_NOT_NULL(mainDict, @"payment_details")) {
        NSDictionary* tempDict = [mainDict objectForKey:@"payment_details"];

        if (IS_NOT_NULL(tempDict, @"method_id")) {
            order._payment_details._method_id = GET_VALUE_STRING(tempDict, @"method_id");
        }
        if (IS_NOT_NULL(tempDict, @"method_title")) {
            order._payment_details._method_title = GET_VALUE_STRING(tempDict, @"method_title");
        }
        if (IS_NOT_NULL(tempDict, @"paid")) {
            order._payment_details._paid = GET_VALUE_BOOL(tempDict, @"paid");
        }
    }
    if (IS_NOT_NULL(mainDict, @"billing_address")) {
        NSDictionary* tempDict = [mainDict objectForKey:@"billing_address"];

        if (IS_NOT_NULL(tempDict, @"first_name")) {
            order._billing_address._first_name = GET_VALUE_STRING(tempDict, @"first_name");
        }
        if (IS_NOT_NULL(tempDict, @"last_name")) {
            order._billing_address._last_name = GET_VALUE_STRING(tempDict, @"last_name");
        }
        if (IS_NOT_NULL(tempDict, @"company")) {
            order._billing_address._company = GET_VALUE_STRING(tempDict, @"company");
        }
        if (IS_NOT_NULL(tempDict, @"address_1")) {
            order._billing_address._address_1 = GET_VALUE_STRING(tempDict, @"address_1");
        }
        if (IS_NOT_NULL(tempDict, @"address_2")) {
            order._billing_address._address_2 = GET_VALUE_STRING(tempDict, @"address_2");
        }
        if (IS_NOT_NULL(tempDict, @"city")) {
            order._billing_address._city = GET_VALUE_STRING(tempDict, @"city");
        }
        if (IS_NOT_NULL(tempDict, @"state")) {
            order._billing_address._state = GET_VALUE_STRING(tempDict, @"state");
        }
        if (IS_NOT_NULL(tempDict, @"postcode")) {
            order._billing_address._postcode = GET_VALUE_STRING(tempDict, @"postcode");
        }
        if (IS_NOT_NULL(tempDict, @"country")) {
            order._billing_address._country = GET_VALUE_STRING(tempDict, @"country");
        }
        if (IS_NOT_NULL(tempDict, @"email")) {
            order._billing_address._email = GET_VALUE_STRING(tempDict, @"email");
        }
        if (IS_NOT_NULL(tempDict, @"phone")) {
            order._billing_address._phone = GET_VALUE_STRING(tempDict, @"phone");
        }
    }
    if (IS_NOT_NULL(mainDict, @"shipping_address")) {
        NSDictionary* tempDict = [mainDict objectForKey:@"shipping_address"];

        if (IS_NOT_NULL(tempDict, @"first_name")) {
            order._shipping_address._first_name = GET_VALUE_STRING(tempDict, @"first_name");
        }
        if (IS_NOT_NULL(tempDict, @"last_name")) {
            order._shipping_address._last_name = GET_VALUE_STRING(tempDict, @"last_name");
        }
        if (IS_NOT_NULL(tempDict, @"company")) {
            order._shipping_address._company = GET_VALUE_STRING(tempDict, @"company");
        }
        if (IS_NOT_NULL(tempDict, @"address_1")) {
            order._shipping_address._address_1 = GET_VALUE_STRING(tempDict, @"address_1");
        }
        if (IS_NOT_NULL(tempDict, @"address_2")) {
            order._shipping_address._address_2 = GET_VALUE_STRING(tempDict, @"address_2");
        }
        if (IS_NOT_NULL(tempDict, @"city")) {
            order._shipping_address._city = GET_VALUE_STRING(tempDict, @"city");
        }
        if (IS_NOT_NULL(tempDict, @"state")) {
            order._shipping_address._state = GET_VALUE_STRING(tempDict, @"state");
        }
        if (IS_NOT_NULL(tempDict, @"postcode")) {
            order._shipping_address._postcode = GET_VALUE_STRING(tempDict, @"postcode");
        }
        if (IS_NOT_NULL(tempDict, @"country")) {
            order._shipping_address._country = GET_VALUE_STRING(tempDict, @"country");
        }
        if (IS_NOT_NULL(tempDict, @"email")) {
            order._shipping_address._email = GET_VALUE_STRING(tempDict, @"email");
        }
        if (IS_NOT_NULL(tempDict, @"phone")) {
            order._shipping_address._phone = GET_VALUE_STRING(tempDict, @"phone");
        }
    }
    if (IS_NOT_NULL(mainDict, @"note")) {
        order._note = GET_VALUE_STRING(mainDict, @"note");
        if (order._note != nil && ![order._note isEqualToString:@""]) {
            NSString* cropString = [NSString stringWithFormat:@"%@", order._note];
            if ((
                 [Utility containsString:cropString substring:@"[[["] &&
                 [Utility containsString:cropString substring:@"]]]"]
                 )) {
                NSRange startCurlyBraket = [cropString rangeOfString:@"[[[" options:0];
                cropString = [cropString substringFromIndex:startCurlyBraket.location];
                NSRange endCurlyBraket = [cropString rangeOfString:@"]]]" options:NSBackwardsSearch];
                cropString = [cropString substringToIndex:endCurlyBraket.location + 3];
                order._note = [order._note stringByReplacingOccurrencesOfString:cropString withString:@""];

                if ([order._note isEqualToString:@"\n"]) {
                    order._note = @"";
                }
                //            order._note = [order._note stringByReplacingOccurrencesOfString:Localize(@"special_order_note") withString:@""];
            }


            if ((
                 [Utility containsString:cropString substring:@"[***"] &&
                 [Utility containsString:cropString substring:@"***]"]
                 )) {
                NSRange startCurlyBraket = [cropString rangeOfString:@"[***" options:0];
                cropString = [cropString substringFromIndex:startCurlyBraket.location];
                NSRange endCurlyBraket = [cropString rangeOfString:@"***]" options:NSBackwardsSearch];
                cropString = [cropString substringToIndex:endCurlyBraket.location + 4];

                order._notePickupLocation = cropString;
                order._notePickupLocation = [order._notePickupLocation stringByReplacingOccurrencesOfString:@"[***" withString:@""];
                order._notePickupLocation = [order._notePickupLocation stringByReplacingOccurrencesOfString:@"***]" withString:@""];


                order._note = [order._note stringByReplacingOccurrencesOfString:@"[***" withString:@""];
                order._note = [order._note stringByReplacingOccurrencesOfString:@"***]" withString:@""];

                if ([order._note isEqualToString:@"\n"]) {
                    order._note = @"";
                }


            }


        }
    }
    if (IS_NOT_NULL(mainDict, @"customer_ip")) {
        //            order._customer_iP = GET_VALUE_STRING(mainDict, @"customer_ip");
    }
    if (IS_NOT_NULL(mainDict, @"customer_user_agent")) {
        //            order._customer_user_agent = GET_VALUE_STRING(mainDict, @"customer_user_agent");
    }
    if (IS_NOT_NULL(mainDict, @"customer_id")) {
        order._customer_id = GET_VALUE_INT(mainDict, @"customer_id");
    }
    if (IS_NOT_NULL(mainDict, @"view_order_url")) {
        order._view_order_url = GET_VALUE_STRING(mainDict, @"view_order_url");
    }
    if (IS_NOT_NULL(mainDict, @"line_items")) {
        [order._line_items removeAllObjects];

        NSArray* tempArray = GET_VALUE_OBJECT(mainDict, @"line_items");
        NSDictionary* tempDict = nil;
        for (tempDict in tempArray) {
            LineItem* lineItem = [[LineItem alloc] init];
            if (IS_NOT_NULL(tempDict, @"id")) {
                lineItem._id = GET_VALUE_INT(tempDict, @"id");
            }
            if (IS_NOT_NULL(tempDict, @"subtotal")) {
                lineItem._subtotal = GET_VALUE_FLOAT(tempDict, @"subtotal");
            }
            if (IS_NOT_NULL(tempDict, @"subtotal_tax")) {
                lineItem._subtotal_tax = GET_VALUE_FLOAT(tempDict, @"subtotal_tax");
            }
            if (IS_NOT_NULL(tempDict, @"total")) {
                lineItem._total = GET_VALUE_FLOAT(tempDict, @"total");
            }
            if (IS_NOT_NULL(tempDict, @"total_tax")) {
                lineItem._total_tax = GET_VALUE_FLOAT(tempDict, @"total_tax");
            }
            if (IS_NOT_NULL(tempDict, @"price")) {
                lineItem._price = GET_VALUE_FLOAT(tempDict, @"price");
            }
            if (IS_NOT_NULL(tempDict, @"quantity")) {
                lineItem._quantity = GET_VALUE_INT(tempDict, @"quantity");
            }
            if (IS_NOT_NULL(tempDict, @"tax_class")) {
                lineItem._tax_class = GET_VALUE_STRING(tempDict, @"tax_class");
            }
            if (IS_NOT_NULL(tempDict, @"name")) {
                lineItem._name = GET_VALUE_STRING(tempDict, @"name");
            }
            if (IS_NOT_NULL(tempDict, @"product_id")) {
                lineItem._product_id = GET_VALUE_INT(tempDict, @"product_id");
            }
            if (IS_NOT_NULL(tempDict, @"sku")) {
                lineItem._sku = GET_VALUE_STRING(tempDict, @"sku");
            }
            if (IS_NOT_NULL(tempDict, @"meta")) {
                if (GET_VALUE_OBJECT(tempDict, @"meta")) {
                    NSArray* tempArrayMeta = GET_VALUE_OBJECT(tempDict, @"meta");
                    NSDictionary* tempDictMeta = nil;
                    for (tempDictMeta in tempArrayMeta) {
                        ProductMetaItemProperties* pmip = [[ProductMetaItemProperties alloc] init];
                        if (IS_NOT_NULL(tempDictMeta, @"key")) {
                            pmip._key = GET_VALUE_STRING(tempDictMeta, @"key");
                        }
                        if (IS_NOT_NULL(tempDictMeta, @"value")) {
                            pmip._value = GET_VALUE_STRING(tempDictMeta, @"value");
                        }
                        if (IS_NOT_NULL(tempDictMeta, @"label")) {
                            pmip._label = GET_VALUE_STRING(tempDictMeta, @"label");
                        }
                        [lineItem._meta addObject:pmip];
                    }
                }
            }

            [order._line_items addObject:lineItem];
        }
    }
    if (IS_NOT_NULL(mainDict, @"shipping_lines")) {
        [order._shipping_lines addObjectsFromArray:[mainDict objectForKey:@"shipping_lines"]] ;
    }
    if (IS_NOT_NULL(mainDict, @"tax_lines")) {
        [order._tax_lines addObjectsFromArray:[mainDict objectForKey:@"tax_lines"]] ;
    }
    if (IS_NOT_NULL(mainDict, @"fee_lines")) {
        [order._fee_lines removeAllObjects];
        NSArray* feeLineArray = [mainDict objectForKey:@"fee_lines"];
        for (NSDictionary* dictFeeLine in feeLineArray) {
            FeeLine* feeLine = [[FeeLine alloc] init];
            if (IS_NOT_NULL(dictFeeLine, @"id")) {
                feeLine.feeline_id = GET_VALUE_INT(dictFeeLine, @"id");
            }
            if (IS_NOT_NULL(dictFeeLine, @"tax_class")) {
                feeLine.tax_class = GET_VALUE_STRING(dictFeeLine, @"tax_class");
            }
            if (IS_NOT_NULL(dictFeeLine, @"title")) {
                feeLine.title = GET_VALUE_STRING(dictFeeLine, @"title");
            }
            if (IS_NOT_NULL(dictFeeLine, @"total")) {
                feeLine.total = [GET_VALUE_STRING(dictFeeLine, @"total") floatValue];
            }
            if (IS_NOT_NULL(dictFeeLine, @"total_tax")) {
                feeLine.total_tax = [GET_VALUE_STRING(dictFeeLine, @"total_tax") floatValue];
            }
            [order._fee_lines addObject:feeLine];
        }
    }
    if (IS_NOT_NULL(mainDict, @"coupon_lines")) {
        [order._coupon_lines addObjectsFromArray:[mainDict objectForKey:@"coupon_lines"]] ;
    }
    if (IS_NOT_NULL(mainDict, @"customer")) {
        NSDictionary* tempDict = [mainDict objectForKey:@"customer"];//TODO
    }

    //TODO ADD THIS OBJECT TO ?

    return order;
}
- (Order*)parseOrderJson:(NSDictionary *)mainDict {
    return [self parseOrderJsonWithOrderObject:mainDict order:nil];
}

- (void)loadOrdersData:(NSDictionary *)dictionary {
    AppUser* appUser = [AppUser sharedManager];
    [appUser._ordersArray removeAllObjects];
    RLOG(@"CategoryInfo Count========>%d", (int)[[CategoryInfo getAll] count]);
    RLOG(@"ProductInfo Count========>%d", (int)[[ProductInfo getAll] count]);
    RLOG(@"Orders Count========>%d", (int)[appUser._ordersArray count]);

    NSArray* orderArray = [dictionary objectForKey:@"orders"];
    NSDictionary* orderDict = nil;

    for (orderDict in orderArray) {
        if ([[GuestConfig sharedInstance] guest_checkout] && appUser._isUserLoggedIn == false) {
            Order* order = [self parseOrderJson:orderDict];
            [appUser._ordersArray addObject:order];
        }
        else {
            if (IS_NOT_NULL(orderDict, @"customer_id")) {
                if(GET_VALUE_INT(orderDict, @"customer_id") == [[AppUser sharedManager] _id] )
                {
                    Order* order = [self parseOrderJson:orderDict];
                    [appUser._ordersArray addObject:order];
                }
            }
        }
    }
    RLOG(@"CategoryInfo Count========>%d", (int)[[CategoryInfo getAll] count]);
    RLOG(@"ProductInfo Count========>%d", (int)[[ProductInfo getAll] count]);
    RLOG(@"Orders Count========>%d", (int)[appUser._ordersArray count]);
    [appUser saveData];

}
- (void)loadCategoriesData:(NSDictionary *)dictionary {
    RLOG(@"<========LoadCategoryData Started");
    RLOG(@"CategoryInfo Count========>%d", (int)[[CategoryInfo getAll] count]);
    RLOG(@"ProductInfo Count========>%d", (int)[[ProductInfo getAll] count]);

    NSDictionary* headerDict = [dictionary objectForKey:@"product_categories"];
    NSDictionary* mainDict = nil;
    for (mainDict in headerDict) {
        CategoryInfo* category = [CategoryInfo getWithId:GET_VALUE_INT(mainDict, @"id")];
        if (IS_NOT_NULL(mainDict, @"id")) {
            category._id = GET_VALUE_INT(mainDict, @"id");
        }
        if (IS_NOT_NULL(mainDict, @"name")) {
            //            NSString * htmlString = GET_VALUE_STRING(mainDict, @"name");
            //            NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
            //            category._name = [[NSString alloc] initWithString: [attrStr string]];
            category._name = GET_VALUE_STRING(mainDict, @"name");
        }
        if (IS_NOT_NULL(mainDict, @"slug")) {
            category._slug = GET_VALUE_STRING(mainDict, @"slug");
            category._slugOriginal = GET_VALUE_STRING(mainDict, @"slug");
        }
        if (IS_NOT_NULL(mainDict, @"parent")) {
            category._parentId = GET_VALUE_INT(mainDict, @"parent");
        }
        if (IS_NOT_NULL(mainDict, @"description")) {
            category._description = GET_VALUE_STRING(mainDict, @"description");
        }
        if (IS_NOT_NULL(mainDict, @"display")) {
            category._display = GET_VALUE_STRING(mainDict, @"display");
        }
        if (IS_NOT_NULL(mainDict, @"image")) {
            category._image = GET_VALUE_STRING(mainDict, @"image");
        }
        if (IS_NOT_NULL(mainDict, @"count")) {
            category._count = GET_VALUE_INT(mainDict, @"count");
        }

        category._parent = [CategoryInfo getWithId:category._parentId];
    }
    RLOG(@"<========LoadCategoryData Completed");
    RLOG(@"CategoryInfo Count========>%d", (int)[[CategoryInfo getAll] count]);
    RLOG(@"ProductInfo Count========>%d", (int)[[ProductInfo getAll] count]);
}
- (ProductInfo*)loadSingleProductData:(NSDictionary *)dictionary {
    CommonInfo* commonInfo = [CommonInfo sharedManager];
    if (dictionary) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&error];
        if (! jsonData) {
            RLOG(@"Got an error: %@", error);
        } else {
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            RLOG(@"jsonString: %@", jsonString);
        }
    }
    NSDictionary* mainDict = nil;
    id dictExtraData = nil;
    if (IS_NOT_NULL(dictionary, @"product")) {
        mainDict = GET_VALUE_OBJECT(dictionary, @"product");
    }
    if (IS_NOT_NULL(dictionary, @"ext_data")) {
        dictExtraData = GET_VALUE_OBJECT(dictionary, @"ext_data");
    }
    int productId = -1;
    if (IS_NOT_NULL(mainDict, @"id")) {
        productId = GET_VALUE_INT(mainDict, @"id");
    }

    ProductInfo* p = [ProductInfo getProductWithId:productId];
    if (p == nil) {
        p = [[ProductInfo alloc] init];
    }
    p._isSmallRetrived = true;

    if (dictExtraData) {
        [self parseProductExtraData:p dict:dictExtraData];
    }

    if (IS_NOT_NULL(mainDict, @"title")) {
        p._title = GET_VALUE_STRING(mainDict, @"title");
    }
    if (IS_NOT_NULL(mainDict, @"id")) {
        p._id = GET_VALUE_INT(mainDict, @"id");
    }
    if (IS_NOT_NULL(mainDict, @"type")) {
        NSString* productType = GET_VALUE_STRING(mainDict, @"type");
        if ([productType isEqualToString:@"simple"]) {
            p._type = PRODUCT_TYPE_SIMPLE;
        }
        if ([productType isEqualToString:@"grouped"]) {
            p._type = PRODUCT_TYPE_GROUPED;
        }
        if ([productType isEqualToString:@"external"]) {
            p._type = PRODUCT_TYPE_EXTERNAL_OR_AFFILIATE;
        }
        if ([productType isEqualToString:@"variable"]) {
            p._type = PRODUCT_TYPE_VARIABLE;
        }
        if ([productType isEqualToString:@"variable-subscription"]) {
            p._type = PRODUCT_TYPE_VARIABLE;
        }
        if ([productType isEqualToString:@"bundle"]) {
            p._type = PRODUCT_TYPE_BUNDLE;
        }
        if ([productType isEqualToString:@"yith_bundle"]) {
            p._type = PRODUCT_TYPE_BUNDLE;
        }
        if ([productType isEqualToString:@"mix-and-match"]) {
            p._type = PRODUCT_TYPE_MIXNMATCH;
        }
        if ([productType isEqualToString:@"downloadable"]) {
            p._type = PRODUCT_TYPE_DOWNLOADABLE;
        }
    }
    if (IS_NOT_NULL(mainDict, @"button_text")) {
        p.button_text = GET_VALUE_STRING(mainDict, @"button_text");
    }
    if (IS_NOT_NULL(mainDict, @"status")) {
        p._status = GET_VALUE_STRING(mainDict, @"status");
    }
    if (IS_NOT_NULL(mainDict, @"downloadable")) {
        p._downloadable = GET_VALUE_BOOL(mainDict, @"downloadable");
    }
    if (IS_NOT_NULL(mainDict, @"virtual")) {
        p._virtual = GET_VALUE_BOOL(mainDict, @"virtual");
    }
    if (IS_NOT_NULL(mainDict, @"permalink")) {
        p._permalink = GET_VALUE_STRING(mainDict, @"permalink");
    }
    if (IS_NOT_NULL(mainDict, @"sku")) {
        p._sku = GET_VALUE_STRING(mainDict, @"sku");
    }
    if (IS_NOT_NULL(mainDict, @"price")) {
        p._price = GET_VALUE_FLOAT(mainDict, @"price");
    }
    if (IS_NOT_NULL(mainDict, @"regular_price")) {
        p._regular_price = GET_VALUE_FLOAT(mainDict, @"regular_price");
    }
    if (IS_NOT_NULL(mainDict, @"sale_price")) {
        p._sale_price = GET_VALUE_FLOAT(mainDict, @"sale_price");
    }

    [CurrencyHelper applyCurrencyRate:p];

    if (IS_NOT_NULL(mainDict, @"taxable")) {
        p._taxable = GET_VALUE_BOOL(mainDict, @"taxable");
    }
    if (IS_NOT_NULL(mainDict, @"tax_status")) {
        p._tax_status = GET_VALUE_STRING(mainDict, @"tax_status");
    }
    if (IS_NOT_NULL(mainDict, @"tax_class")) {
        p._tax_class = GET_VALUE_STRING(mainDict, @"tax_class");
    }
    [self setPriceFromTax:p];
    {
        float priceToUse = p._regular_price != 0 ? p._regular_price : p._price;
        float discountPrice = p._sale_price != 0? (priceToUse - p._sale_price) : 0;
        if (discountPrice > 0) {
            p._discount = discountPrice*100.0f/priceToUse;
        } else {
            p._discount = 0;
        }
    }
    if (IS_NOT_NULL(mainDict, @"price_html")) {
        p._price_html = GET_VALUE_STRING(mainDict, @"price_html");//AttributedString
    }
    if (IS_NOT_NULL(mainDict, @"managing_stock")) {
        p._managing_stock = GET_VALUE_BOOL(mainDict, @"managing_stock");
    }
    if (IS_NOT_NULL(mainDict, @"stock_quantity")) {
        p._stock_quantity = GET_VALUE_INT(mainDict, @"stock_quantity");
    }
    if (IS_NOT_NULL(mainDict, @"in_stock")) {
        p._in_stock = GET_VALUE_BOOL(mainDict, @"in_stock");
    }
    if (IS_NOT_NULL(mainDict, @"backorders_allowed")) {
        p._backorders_allowed = GET_VALUE_BOOL(mainDict, @"backorders_allowed");
    }
    if (IS_NOT_NULL(mainDict, @"backordered")) {
        p._backordered = GET_VALUE_BOOL(mainDict, @"backordered");
    }
    if (IS_NOT_NULL(mainDict, @"sold_individually")) {
        p._sold_individually = GET_VALUE_BOOL(mainDict, @"sold_individually");
    }
    if (IS_NOT_NULL(mainDict, @"purchaseable")) {
        p._purchaseable = GET_VALUE_BOOL(mainDict, @"purchaseable");
    }
    if (IS_NOT_NULL(mainDict, @"featured")) {
        p._featured = GET_VALUE_BOOL(mainDict, @"featured");
    }
    if (IS_NOT_NULL(mainDict, @"visible")) {
        p._visible = GET_VALUE_BOOL(mainDict, @"visible");
    }
    if (IS_NOT_NULL(mainDict, @"catalog_visibility")) {
        //            p._catalog_visibility = GET_VALUE_STRING(mainDict, @"catalog_visibility");
    }
    if (IS_NOT_NULL(mainDict, @"on_sale")) {
        p._on_sale = GET_VALUE_BOOL(mainDict, @"on_sale");
    }
    if (IS_NOT_NULL(mainDict, @"product_url")) {
        p._product_url = GET_VALUE_STRING(mainDict, @"product_url");
    }
    if (IS_NOT_NULL(mainDict, @"button_text")) {
        //            p._button_text = GET_VALUE_STRING(mainDict, @"button_text");
    }
    if (IS_NOT_NULL(mainDict, @"weight")) {
        p._weight = GET_VALUE_FLOAT(mainDict, @"weight");
    }
    if (IS_NOT_NULL(mainDict, @"dimensions")) {
        NSDictionary* tempDict = [mainDict objectForKey:@"dimensions"];
        if (IS_NOT_NULL(tempDict, @"height")) {
            p._dimensions._height = GET_VALUE_FLOAT(tempDict, @"height");
        }
        if (IS_NOT_NULL(tempDict, @"width")) {
            p._dimensions._width = GET_VALUE_FLOAT(tempDict, @"width");
        }
        if (IS_NOT_NULL(tempDict, @"length")) {
            p._dimensions._length = GET_VALUE_FLOAT(tempDict, @"length");
        }
        if (IS_NOT_NULL(tempDict, @"unit")) {
            p._dimensions._unit = GET_VALUE_STRING(tempDict, @"unit");
        }
    }
    if (IS_NOT_NULL(mainDict, @"shipping_required")) {
        p._shipping_required = GET_VALUE_BOOL(mainDict, @"shipping_required");
    }
    if (IS_NOT_NULL(mainDict, @"shipping_taxable")) {
        p._shipping_taxable = GET_VALUE_BOOL(mainDict, @"shipping_taxable");
    }
    if (IS_NOT_NULL(mainDict, @"shipping_class")) {
        p._shipping_class = GET_VALUE_STRING(mainDict, @"shipping_class");
    }
    if (IS_NOT_NULL(mainDict, @"shipping_class_id")) {
        p._shipping_class_id = GET_VALUE_INT(mainDict, @"shipping_class_id");
    }
    if (IS_NOT_NULL(mainDict, @"description")) {
        p._description = GET_VALUE_STRING(mainDict, @"description");//A
        p.descAttribStr = nil;
    }
    if (IS_NOT_NULL(mainDict, @"short_description")) {
        p._short_description = GET_VALUE_STRING(mainDict, @"short_description");//A
        p.shortDescAttribStr = nil;
    }
    if (IS_NOT_NULL(mainDict, @"reviews_allowed")) {
        p._reviews_allowed = GET_VALUE_BOOL(mainDict, @"reviews_allowed");
    }
    if (IS_NOT_NULL(mainDict, @"average_rating")) {
        p._average_rating = GET_VALUE_FLOAT(mainDict, @"average_rating");
    }
    if (IS_NOT_NULL(mainDict, @"rating_count")) {
        p._rating_count = GET_VALUE_INT(mainDict, @"rating_count");
    }
    if (IS_NOT_NULL(mainDict, @"related_ids")) {
        [p._related_ids removeAllObjects];
        [p._related_ids addObjectsFromArray:[mainDict objectForKey:@"related_ids"]] ;
    }
    if (IS_NOT_NULL(mainDict, @"upsell_ids")) {
        [p._upsell_ids removeAllObjects];
        [p._upsell_ids addObjectsFromArray:[mainDict objectForKey:@"upsell_ids"]] ;
    }
    if (IS_NOT_NULL(mainDict, @"cross_sell_ids")) {
        [p._cross_sell_ids removeAllObjects];
        [p._cross_sell_ids addObjectsFromArray:[mainDict objectForKey:@"cross_sell_ids"]] ;
    }
    if (IS_NOT_NULL(mainDict, @"parent_id")) {
        p._parent_id = GET_VALUE_INT(mainDict, @"parent_id");
    }
    if (IS_NOT_NULL(mainDict, @"categories")) {
        [p._categories removeAllObjects];

        BOOL addToCategory = true;
        if (commonInfo->_hideOutOfStock){
            if (p._in_stock) {
                addToCategory = true;
            } else {
                addToCategory = false;
            }
        } else {
            addToCategory = true;
        }
        if (addToCategory) {
            NSArray* mtempArray = [mainDict objectForKey:@"categories"];
            p._categoriesNames = [[NSMutableArray alloc] initWithArray:mtempArray];
            for (NSString* cateogoryName in mtempArray) {
                CategoryInfo* ccinfo = [CategoryInfo getWithName:cateogoryName];
                if (ccinfo) {
                    if ([p._categories containsObject:ccinfo] == false) {
                        [p._categories addObject:ccinfo];
                        [p addInAllParentCategory:ccinfo];
                    }
                }
            }
        }
    }
    if (IS_NOT_NULL(mainDict, @"tags")) {
        [p._tags removeAllObjects];
        [p._tags addObjectsFromArray:[mainDict objectForKey:@"tags"]] ;
    }
    
    if (IS_NOT_NULL(mainDict, @"featured_src")) {
        if(!(p._featured_src && ![p._featured_src isEqualToString:@""])) {
            p._featured_src = GET_VALUE_STRING(mainDict, @"featured_src");
            if (![p._featured_src isKindOfClass:[NSString class]]) {
                p._featured_src = @"";
            }
        }
    }
    
    if (IS_NOT_NULL(mainDict, @"images")) {
        [p._images removeAllObjects];
//        if (p._featured_src && ![p._featured_src isEqualToString:@""]) {
//            ProductImage* pImage = [[ProductImage alloc] init];
//            pImage._src = p._featured_src;
//            [p addImage:pImage];
//        }
        NSArray* imagesArray = [mainDict objectForKey:@"images"];
        id tempDict = nil;
        for (tempDict in imagesArray) {
            RLOG(@"TMStore = %@", imagesArray);
            if ([tempDict isKindOfClass:[NSDictionary class]]) {
                ProductImage* pImage = [[ProductImage alloc] init];
                if (IS_NOT_NULL(tempDict, @"id")) {
                    pImage._id = GET_VALUE_INT(tempDict, @"id");
                }
                if (IS_NOT_NULL(tempDict, @"alt")) {
                    pImage._alt = GET_VALUE_STRING(tempDict, @"alt");
                }
                if (IS_NOT_NULL(tempDict, @"position")) {
                    pImage._position = GET_VALUE_INT(tempDict, @"position");
                }
                if (IS_NOT_NULL(tempDict, @"src")) {
                    pImage._src = GET_VALUE_STRING(tempDict, @"src");
                    //TODO IMAGE_RESIZE
                    pImage._src = [[Utility sharedManager] getScaledImageUrl: pImage._src];
                    [p addImage:pImage];
                }
                if (IS_NOT_NULL(tempDict, @"title")) {
                    pImage._title = GET_VALUE_STRING(tempDict, @"title");
                }
            } else if([tempDict isKindOfClass:[NSString class]]) {
                ProductImage* pImage = [[ProductImage alloc] init];
                pImage._src = tempDict;
                //TODO IMAGE_RESIZE
                pImage._src = [[Utility sharedManager] getScaledImageUrl: pImage._src];
                [p addImage:pImage];
            }
        }
    } else {
        [p._images removeAllObjects];
        ProductImage* pImage = [[ProductImage alloc] init];
        if (p._featured_src && ![p._featured_src isEqualToString:@""]) {
            pImage._src = p._featured_src;
        }
        [p addImage:pImage];
    }
    
    if (IS_NOT_NULL(mainDict, @"attributes")) {
        [p._attributes removeAllObjects];
        NSArray* tempArray = [mainDict objectForKey:@"attributes"];
        NSDictionary* tempDict = nil;
        for (tempDict in tempArray) {
            Attribute* attribute = [[Attribute alloc] init];
            if (IS_NOT_NULL(tempDict, @"name")) {
                attribute._name = GET_VALUE_STRING(tempDict, @"name");
            }
            if (IS_NOT_NULL(tempDict, @"options")) {
                [attribute._options addObjectsFromArray:[tempDict objectForKey:@"options"]] ;
            }
            if (IS_NOT_NULL(tempDict, @"position")) {
                attribute._position = GET_VALUE_INT(tempDict, @"position");
            }
            if (IS_NOT_NULL(tempDict, @"slug")) {
                attribute._slug = GET_VALUE_STRING(tempDict, @"slug");
            }
            if (IS_NOT_NULL(tempDict, @"variation")) {
                attribute._variation = GET_VALUE_BOOL(tempDict, @"variation");
            }
            if (IS_NOT_NULL(tempDict, @"visible")) {
                attribute._visible = GET_VALUE_BOOL(tempDict, @"visible");
            }
//            if (attribute._options && [attribute._options count] > 0 && attribute._variation) {
//                [p._attributes addObject:attribute];
//            }
             [p._attributes addObject:attribute];
        }
    }
    if (IS_NOT_NULL(mainDict, @"downloads")) {
        [p._downloads removeAllObjects];
        [p._downloads addObjectsFromArray:[mainDict objectForKey:@"downloads"]] ;
    }
    if (IS_NOT_NULL(mainDict, @"download_limit")) {
        p._download_limit = GET_VALUE_INT(mainDict, @"download_limit");
    }
    if (IS_NOT_NULL(mainDict, @"download_expiry")) {
        p._download_expiry = GET_VALUE_INT(mainDict, @"download_expiry");
    }
    if (IS_NOT_NULL(mainDict, @"download_type")) {
        p._download_type = GET_VALUE_STRING(mainDict, @"download_type");
    }
    if (IS_NOT_NULL(mainDict, @"purchase_note")) {
        p._purchase_note = GET_VALUE_STRING(mainDict, @"purchase_note");
    }
    if (IS_NOT_NULL(mainDict, @"total_sales")) {
        p._total_sales = GET_VALUE_INT(mainDict, @"total_sales");
    }
    if (IS_NOT_NULL(mainDict, @"created_at")) {
        NSDateFormatter* df = [[NSDateFormatter alloc]init];
        [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
        NSString* str = GET_VALUE_STRING(mainDict, @"created_at");
        p._created_at = [df dateFromString:str];
    }
    if (IS_NOT_NULL(mainDict, @"updated_at")) {
        NSDateFormatter* df = [[NSDateFormatter alloc]init];
        [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
        NSString* str = GET_VALUE_STRING(mainDict, @"updated_at");
        p._updated_at = [df dateFromString:str];
    }

    if (IS_NOT_NULL(mainDict, @"variations")) {
        [p._variations removeAllObjects];
        NSArray* tempArray = [mainDict objectForKey:@"variations"];
        NSDictionary* tempDict = nil;
        for (tempDict in tempArray) {
            Variation* variation = [[Variation alloc] init];//TODO
            if (IS_NOT_NULL(tempDict, @"id")) {
                variation._id = GET_VALUE_INT(tempDict, @"id");
            }
            if (IS_NOT_NULL(tempDict, @"created_at")) {
                NSDateFormatter* df = [[NSDateFormatter alloc]init];
                [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
                NSString* str = GET_VALUE_STRING(tempDict, @"created_at");
                variation._created_at = [df dateFromString:str];
            }
            if (IS_NOT_NULL(tempDict, @"updated_at")) {
                NSDateFormatter* df = [[NSDateFormatter alloc]init];
                [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
                NSString* str = GET_VALUE_STRING(tempDict, @"updated_at");
                variation._updated_at = [df dateFromString:str];
            }
            if (IS_NOT_NULL(tempDict, @"downloadable")) {
                variation._downloadable = GET_VALUE_BOOL(tempDict, @"downloadable");
            }
            if (IS_NOT_NULL(tempDict, @"virtual")) {
                variation._virtual = GET_VALUE_BOOL(tempDict, @"virtual");
            }
            if (IS_NOT_NULL(tempDict, @"permalink")) {
                variation._permalink = GET_VALUE_STRING(tempDict, @"permalink");
            }
            if (IS_NOT_NULL(tempDict, @"sku")) {
                variation._sku = GET_VALUE_STRING(tempDict, @"sku");
            }
            if (IS_NOT_NULL(tempDict, @"price")) {
                variation._price = GET_VALUE_FLOAT(tempDict, @"price");
            }
            if (IS_NOT_NULL(tempDict, @"regular_price")) {
                variation._regular_price = GET_VALUE_FLOAT(tempDict, @"regular_price");
            }
            if (IS_NOT_NULL(tempDict, @"sale_price")) {
                variation._sale_price = GET_VALUE_FLOAT(tempDict, @"sale_price");
            }

            [CurrencyHelper applyCurrencyRateForVariation:variation];

            if (IS_NOT_NULL(tempDict, @"taxable")) {
                variation._taxable = GET_VALUE_BOOL(tempDict, @"taxable");
            }
            if (IS_NOT_NULL(tempDict, @"tax_status")) {
                variation._tax_status = GET_VALUE_STRING(tempDict, @"tax_status");
            }
            if (IS_NOT_NULL(tempDict, @"tax_class")) {
                variation._tax_class = GET_VALUE_STRING(tempDict, @"tax_class");
            }
            [self setPriceFromTax:variation];

            if (IS_NOT_NULL(tempDict, @"managing_stock")) {
                variation._managing_stock = GET_VALUE_BOOL(tempDict, @"managing_stock");
            }
            if (IS_NOT_NULL(tempDict, @"stock_quantity")) {
                variation._stock_quantity = GET_VALUE_INT(tempDict, @"stock_quantity");
            }
            if (IS_NOT_NULL(tempDict, @"in_stock")) {
                variation._in_stock = GET_VALUE_BOOL(tempDict, @"in_stock");
            }
            if (IS_NOT_NULL(tempDict, @"backordered")) {
                variation._backordered = GET_VALUE_BOOL(tempDict, @"backordered");
            }
            if (IS_NOT_NULL(tempDict, @"purchaseable")) {
                variation._purchaseable = GET_VALUE_BOOL(tempDict, @"purchaseable");
            }
            if (IS_NOT_NULL(tempDict, @"visible")) {
                variation._visible = GET_VALUE_BOOL(tempDict, @"visible");
            }
            if (IS_NOT_NULL(tempDict, @"on_sale")) {
                variation._on_sale = GET_VALUE_BOOL(tempDict, @"on_sale");
            }
            if (IS_NOT_NULL(tempDict, @"weight")) {
                variation._weight = GET_VALUE_FLOAT(tempDict, @"weight");
            }
            if (IS_NOT_NULL(tempDict, @"dimensions")) {
                NSDictionary* mtempDict = [tempDict objectForKey:@"dimensions"];
                if (IS_NOT_NULL(mtempDict, @"height")) {
                    variation._dimensions._height = GET_VALUE_FLOAT(mtempDict, @"height");
                }
                if (IS_NOT_NULL(mtempDict, @"width")) {
                    variation._dimensions._width = GET_VALUE_FLOAT(mtempDict, @"width");
                }
                if (IS_NOT_NULL(mtempDict, @"length")) {
                    variation._dimensions._length = GET_VALUE_FLOAT(mtempDict, @"length");
                }
                if (IS_NOT_NULL(mtempDict, @"unit")) {
                    variation._dimensions._unit = GET_VALUE_STRING(mtempDict, @"unit");
                }
            }
            if (IS_NOT_NULL(tempDict, @"shipping_class")) {
                variation._shipping_class = GET_VALUE_STRING(tempDict, @"shipping_class");
            }
            if (IS_NOT_NULL(tempDict, @"shipping_class_id")) {
                variation._shipping_class_id = GET_VALUE_STRING(tempDict, @"shipping_class_id");
            }
            if (IS_NOT_NULL(tempDict, @"image")) {
                [variation._images removeAllObjects];
                NSArray* mtempArray = [tempDict objectForKey:@"image"];
                id mtempDict = nil;
                for (mtempDict in mtempArray) {
                    if ([mtempDict isKindOfClass:[NSDictionary class]]) {
                        ProductImage* pImage = [[ProductImage alloc] init];
                        if (IS_NOT_NULL(mtempDict, @"id")) {
                            pImage._id = GET_VALUE_INT(mtempDict, @"id");
                        }
                        if (IS_NOT_NULL(mtempDict, @"alt")) {
                            pImage._alt = GET_VALUE_STRING(mtempDict, @"alt");
                        }
                        if (IS_NOT_NULL(mtempDict, @"position")) {
                            pImage._position = GET_VALUE_INT(mtempDict, @"position");
                        }
//TODO IMAGE_RESIZE
                        if (IS_NOT_NULL(mtempDict, @"src")) {
                            pImage._src = GET_VALUE_STRING(mtempDict, @"src");
                            pImage._src = [[Utility sharedManager] getScaledImageUrl: pImage._src];
                            [variation._images addObject:pImage];
                        }
//TODO IMAGE_RESIZE
                        if (IS_NOT_NULL(mtempDict, @"title")) {
                            pImage._title = GET_VALUE_STRING(mtempDict, @"title");
                        }

                    } else if ([mtempDict isKindOfClass:[NSString class]]) {
                        ProductImage* pImage = [[ProductImage alloc] init];
                        pImage._src = mtempDict;
//TODO IMAGE_RESIZE
                        pImage._src = [[Utility sharedManager] getScaledImageUrl: pImage._src];
                        [variation._images addObject:pImage];
                    }

                }
            }else {
                ProductImage* pImage = [[ProductImage alloc] init];
                [variation._images addObject:pImage];
            }

            if (IS_NOT_NULL(tempDict, @"attributes")) {
                NSArray* mtempArray = [tempDict objectForKey:@"attributes"];
                NSDictionary* mtempDict = nil;
                for (mtempDict in mtempArray) {
                    VariationAttribute* attribute = [[VariationAttribute alloc] init];
                    if (IS_NOT_NULL(mtempDict, @"name")) {
                        attribute.name = GET_VALUE_STRING(mtempDict, @"name");
                    }
                    if (IS_NOT_NULL(mtempDict, @"slug")) {
                        attribute.slug = GET_VALUE_STRING(mtempDict, @"slug");
                    }
                    if (IS_NOT_NULL(mtempDict, @"option")) {
                        attribute.value = GET_VALUE_STRING(mtempDict, @"option");
                    }
                    attribute.value = [PermanentAttribute resetOption:attribute.slug option:attribute.value];
                    [variation._attributes addObject:attribute];
                }
            }
            if (IS_NOT_NULL(tempDict, @"downloads")) {
                [variation._downloads addObjectsFromArray:[tempDict objectForKey:@"downloads"]] ;
            }
            if (IS_NOT_NULL(tempDict, @"download_limit")) {
                variation._download_limit = GET_VALUE_INT(tempDict, @"download_limit");
            }
            if (IS_NOT_NULL(tempDict, @"download_expiry")) {
                variation._download_expiry = GET_VALUE_INT(tempDict, @"download_expiry");
            }
            [p._variations addObject:variation];
        }
    }
    if (IS_NOT_NULL(mainDict, @"parent")) {
        //            [p._parent addObjectsFromArray:[mainDict objectForKey:@"parent"]] ;
    }

    p._isFullRetrieved = true;
    p._isSmallRetrived = true;

    p._isDiscountedForOuterView = [p isProductDiscounted:-1];
    p._newPriceForOuterView = [p getNewPrice:-1];
    p._oldPriceForOuterView = [p getOldPrice:-1];
    p._titleForOuterView = [Utility getNormalStringFromAttributed:p._title];
    //    p._titleForOuterView = [NSString stringWithFormat:@"%@\n", [Utility getNormalStringFromAttributed:p._title]];
    if (p._isDiscountedForOuterView) {
        p._priceOldString = [[Utility sharedManager] convertToStringStrikethrough:p._oldPriceForOuterView isCurrency:true];
    }else{
        p._priceOldString = [[NSAttributedString alloc]initWithString:@"     "];
    }
    p._priceMin = p._price;
    p._priceMax = p._price;
    if(![[Addons sharedManager] show_min_max_price]) {
        //RLOG(@"show_min_max_price = false");
        p._priceNewString = [[Utility sharedManager] convertToString:p._newPriceForOuterView isCurrency:true];
    } else {
        //RLOG(@"show_min_max_price = true");
        if (p._variations && [p._variations count] > 0) {
            for (Variation* var in p._variations) {
                if (p._priceMax < var._price) {
                    p._priceMax = var._price;
                }
            }
            p._priceMin = p._priceMax;
            for (Variation* var in p._variations) {
                if (p._priceMin > var._price) {
                    p._priceMin = var._price;
                }
            }
        }
        if (p._priceMax == p._priceMin) {
            p._priceNewString = [[Utility sharedManager] convertToString:p._newPriceForOuterView isCurrency:true];
        } else {
            NSString* strMin = [[Utility sharedManager] convertToString:p._priceMin isCurrency:true];
            NSString* strMax = [[Utility sharedManager] convertToString:p._priceMax isCurrency:true];
            p._priceNewString = [NSString stringWithFormat:@"%@ - %@", strMin, strMax];
        }
    }
    
    [p adjustAttributes];
    if([[Addons sharedManager] auto_generate_variations]) {
        [p adjustVariations];
    }
    [p reIndexVariations];

    if([[Addons sharedManager] show_min_max_price]) {
        for (Attribute* att in p._attributes) {
            if ((int)[att._options count] > 1) {
                NSMutableArray* arr = [[NSMutableArray alloc] init];
                [arr addObject:Localize(@"i_select")];
                for (NSString* str in att._options) {
                    [arr addObject:str];
                }
                att._options = arr;
            }
        }
    }
    if (p._isExtraPriceRetrieved) {
        [self parseExtraAttributesForProduct:p variation_simple_fields:p.variation_simple_fields];
    }

    [CategoryInfo isProductBelongsToRestrictedCategories:p];
    [self parseAndSetProductPriceLabels:dictionary product:p];
    if (dictionary != nil || [dictionary objectForKey:@"min_qty_rule"]) {
        [WC2X_JsonHelper parseAndSetProductQuantityRules:dictionary product:p];
    }    return p;
}
- (void)loadSingleProductReviewData:(NSDictionary *)mainDict product:(ProductInfo*)product {
    NSMutableArray* mainArray;
    if (IS_NOT_NULL(mainDict, @"product_reviews")) {
        mainArray = GET_VALUE_OBJECT(mainDict, @"product_reviews");
    } else {
        return;
    }
    [product._productReviews removeAllObjects];
    product._isReviewsRetrieved = true;
    for (NSDictionary* dict in mainArray) {
        ProductReview* pReview = [[ProductReview alloc] init];
        if (IS_NOT_NULL(dict, @"id")) {
            pReview._id = GET_VALUE_INT(dict, @"id");
        }
        if (IS_NOT_NULL(dict, @"rating")) {
            pReview._rating = GET_VALUE_INT(dict, @"rating");
        }
        if (IS_NOT_NULL(dict, @"review")) {
            pReview._review = GET_VALUE_STRING(dict, @"review");
        }
        if (IS_NOT_NULL(dict, @"reviewer_email")) {
            pReview._reviewer_email = GET_VALUE_STRING(dict, @"reviewer_email");
        }
        if (IS_NOT_NULL(dict, @"reviewer_name")) {
            pReview._reviewer_name = GET_VALUE_STRING(dict, @"reviewer_name");
        }
        if (IS_NOT_NULL(dict, @"verified")) {
            pReview._verified = GET_VALUE_BOOL(dict, @"verified");
        }
        if (IS_NOT_NULL(dict, @"created_at")) {
            NSDateFormatter* df = [[NSDateFormatter alloc]init];
            [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
            NSString* str = [NSString stringWithFormat:@"%@", GET_VALUE_STRING(dict, @"created_at")];
            RLOG(@"str = %@", str);
            pReview._created_at = [df dateFromString:str];
        }
        [product._productReviews addObject:pReview];
    }
}
- (NSMutableArray *)loadProductsDataAndReturn:(NSDictionary *)dictionary {

    NSMutableArray *products = [[NSMutableArray alloc] init];

    RLOG(@"<========LoadProductData Started");
    RLOG(@"CategoryInfo Count========>%d", (int)[[CategoryInfo getAll] count]);
    RLOG(@"ProductInfo Count========>%d", (int)[[ProductInfo getAll] count]);

    NSDictionary* headerDict = [dictionary objectForKey:@"products"];
    NSDictionary* mainDict = nil;
    CommonInfo* commonInfo = [CommonInfo sharedManager];
    for (mainDict in headerDict){
        ProductInfo* pInfo = [self loadSingleProductData:mainDict];
        if (pInfo._id == 3932385) {
            NSLog(@"pInfo3932385");
        }

        if (pInfo) {
            if (commonInfo->_hideOutOfStock){
                if (pInfo._in_stock) {
                    [products addObject:pInfo];
                } else {
                    [[ProductInfo getAll] removeObject:pInfo];
                }
            } else {
                [products addObject:pInfo];
            }
        }
    }

    RLOG(@"<========LoadProductData Completed");
    RLOG(@"CategoryInfo Count========>%d", (int)[[CategoryInfo getAll] count]);
    RLOG(@"ProductInfo Count========>%d", (int)[[ProductInfo getAll] count]);

    [CategoryInfo refineMaxChildCount];
    [CategoryInfo refineCategories];
    [CategoryInfo stepUpSingleChildrenCategories];
    [CategoryInfo autoRefreshCategoryThumbs];
    RLOG(@"<========LoadCategoryData Completed");
    RLOG(@"CategoryInfo Count========>%d", (int)[[CategoryInfo getAll] count]);
    RLOG(@"ProductInfo Count========>%d", (int)[[ProductInfo getAll] count]);

    return products;
}

- (NSMutableArray*)loadProductsData:(NSDictionary *)dictionary {
    RLOG(@"<========LoadProductData Started");
    RLOG(@"CategoryInfo Count========>%d", (int)[[CategoryInfo getAll] count]);
    RLOG(@"ProductInfo Count========>%d", (int)[[ProductInfo getAll] count]);
    NSArray* pArray = [dictionary objectForKey:@"products"];
    NSDictionary* pDict = nil;
    NSMutableArray* productArray = [[NSMutableArray alloc] init];
    for (pDict in pArray){
        NSMutableDictionary* mainDict1 = [[NSMutableDictionary alloc] init];
        [mainDict1 setObject:pDict forKey:@"product"];
        ProductInfo* pInfo = [self loadSingleProductData:mainDict1];
        if (pInfo) {
            [productArray addObject:pInfo];
        }
    }
    RLOG(@"<========LoadProductData Completed");
    RLOG(@"CategoryInfo Count========>%d", (int)[[CategoryInfo getAll] count]);
    RLOG(@"ProductInfo Count========>%d", (int)[[ProductInfo getAll] count]);
    [CategoryInfo refineMaxChildCount];
    [CategoryInfo refineCategories];
    [CategoryInfo stepUpSingleChildrenCategories];
    [CategoryInfo autoRefreshCategoryThumbs];
    RLOG(@"<========LoadCategoryData Completed");
    RLOG(@"CategoryInfo Count========>%d", (int)[[CategoryInfo getAll] count]);
    RLOG(@"ProductInfo Count========>%d", (int)[[ProductInfo getAll] count]);
    return productArray;
}
- (void)loadCommonData:(NSDictionary *)dictionary {
    CommonInfo *commonInfo = [CommonInfo sharedManager];

    NSDictionary* mainDict = nil;
    if (IS_NOT_NULL(dictionary, @"store")) {
        mainDict = [dictionary objectForKey:@"store"];
    }else {
        RLOG(@"=====DATA NOT FOUND===== in method loadCommonData");
        return;
    }

    NSDictionary* metaDict = nil;
    if (IS_NOT_NULL(mainDict, @"meta")) {
        metaDict = [mainDict objectForKey:@"meta"];

        if (IS_NOT_NULL(metaDict, @"timezone")) {
            commonInfo->_timezone = GET_VALUE_STRING(metaDict, @"timezone");
        }
        if (IS_NOT_NULL(metaDict, @"currency")) {
            commonInfo->_currency = GET_VALUE_STRING(metaDict, @"currency");
        }
        if (IS_NOT_NULL(metaDict, @"currency_format")) {
            commonInfo->_currency_format = GET_VALUE_STRING(metaDict, @"currency_format");
        }
        if (IS_NOT_NULL(metaDict, @"currency_position")) {
            commonInfo->_currency_position = GET_VALUE_STRING(metaDict, @"currency_position");
        }
        if (IS_NOT_NULL(metaDict, @"thousand_separator")) {
            commonInfo->_thousand_separator = GET_VALUE_STRING(metaDict, @"thousand_separator");
        }
        if (IS_NOT_NULL(metaDict, @"decimal_separator")) {
            commonInfo->_decimal_separator = GET_VALUE_STRING(metaDict, @"decimal_separator");
        }
        if (IS_NOT_NULL(metaDict, @"price_num_decimals")) {
            commonInfo->_price_num_decimals = GET_VALUE_INT(metaDict, @"price_num_decimals");
        }
        if (IS_NOT_NULL(metaDict, @"tax_included")) {
            commonInfo->_tax_included = GET_VALUE_BOOL(metaDict, @"tax_included");
        }
        if (IS_NOT_NULL(metaDict, @"weight_unit")) {
            commonInfo->_weight_unit = GET_VALUE_STRING(metaDict, @"weight_unit");
        }
        if (IS_NOT_NULL(metaDict, @"dimension_unit")) {
            commonInfo->_dimension_unit = GET_VALUE_STRING(metaDict, @"dimension_unit");
        }
    }
    [[Utility sharedManager] initCurrencyPosition];
    [[Utility sharedManager] initCurrencySymbol];

}
#pragma mark Load Data From Server Via Plugin

- (void)parseExtraAttributesForProduct:(ProductInfo*)product variation_simple_fields:(NSArray*)variation_simple_fields {
    if (variation_simple_fields && product) {
        product.variation_simple_fields = variation_simple_fields;
        for (NSDictionary* attributeObject in variation_simple_fields) {
            if (IS_NOT_NULL(attributeObject, @"saved_attribute")) {
                NSDictionary* saved_attribute = GET_VALUE_OBJECT(attributeObject, @"saved_attribute");
                float extraPrice = 0.0f;
                if (IS_NOT_NULL(saved_attribute, @"Additional Price")) {
                    extraPrice = GET_VALUE_FLOAT(saved_attribute, @"Additional Price");
                }

                NSEnumerator *enumerator = [saved_attribute keyEnumerator];
                id keyServer;
                id valueServer;
                //must be like this

                //                while(keyServer = [enumerator nextObject]) {
                //                    valueServer = [saved_attribute objectForKey:keyServer];
                //                    for (Attribute* attribute in product._attributes) {
                //                        NSString* keyAttribute = attribute._name;
                //                        if ([Utility compareAttributeNames:keyAttribute name2:keyServer]) {
                //                            NSString* valueAttribute = @"";
                //                            for (NSString* str in attribute._options) {
                //                                valueAttribute = str;
                //                                if ([Utility compareAttributeNames:valueAttribute name2:valueServer]) {
                //                                    [attribute addAdditionalPrice:valueAttribute value:extraPrice];
                //                                    break;
                //                                }
                //                            }
                //                            break;
                //                        }
                //                    }
                //                }





                //according to yumyum's plugin i.e.(Custom Fields)

                while(keyServer = [enumerator nextObject])
                {
                    valueServer = [saved_attribute objectForKey:keyServer];
                    if ([keyServer isEqualToString:@"Additional Price"] || [valueServer isEqualToString:@"Additional Price"]) {
                        continue;
                    }
                    for (Attribute* attribute in product._attributes) {
                        NSString* valueAttribute = @"";
                        for (NSString* str in attribute._options) {
                            valueAttribute = str;
                            RLOG(@"valueAttribute = %@, valueServer = %@", valueAttribute, valueServer);
                            //                            if ([Utility compareAttributeNames:valueAttribute name2:valueServer]) {
                            if ([valueAttribute isEqualToString:valueServer]) {
                                [attribute addAdditionalPrice:valueAttribute value:extraPrice];
                                break;
                            }

                        }
                    }
                    //                    break;
                }
            }
        }

    }
    if (product) {
        product._isExtraPriceRetrieved = true;
    }
}

//{
//    menu =     {
//        id = 20;
//        name = FooterMeny;
//        slug = footermeny;
//    };
//    options =     (
//                   {
//                       id = 5434;
//                       "menu_order" = 1;
//                       name = "Kj\U00f8psbetingelser";
//                       parent = 0;
//                       "redirect_cid" = "-1";
//                       "redirect_url" = "http://smiabutikken.no/betingelser/";
//                   },
//                   {
//                       id = 5435;
//                       "menu_order" = 2;
//                       name = "Om oss";
//                       parent = 0;
//                       "redirect_cid" = "-1";
//                       "redirect_url" = "http://smiabutikken.no/om-oss/";
//                   }
//                   );
//},
+ (void)loadPluginDataForMenuItems:(NSArray*)array {
    CustomMenu* cMenu = [CustomMenu sharedManager];
    [cMenu.items removeAllObjects];
    if (array) {
        //to remove multiple occurance of similar values
        NSMutableArray* aa = [[NSMutableArray alloc] init];
        for (NSDictionary* mainDict in array) {
            NSError * err;
            NSData * jsonData = [NSJSONSerialization dataWithJSONObject:mainDict options:0 error:&err];
            NSString * jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            [aa addObject:jsonString];
        }
        NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:aa];
        array = [orderedSet array];
        for (NSString* mainDictStr in array) {
            NSData *data = [mainDictStr dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary*  mainDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];


            //previous code
            //        for (NSDictionary* mainDict in array) {

            CustomMenuItem* menuItem = [[CustomMenuItem alloc] init];
            [cMenu.items addObject:menuItem];
            if (IS_NOT_NULL(mainDict, @"menu")) {
                NSMutableDictionary* tempDict = GET_VALUE_OBJECT(mainDict, @"menu");
                if (tempDict) {
                    if (IS_NOT_NULL(tempDict, @"id")) {
                        menuItem.itemId = GET_VALUE_INT(tempDict, @"id");
                    }
                    if (IS_NOT_NULL(tempDict, @"name")) {
                        menuItem.itemName = GET_VALUE_OBJECT(tempDict, @"name");
                        menuItem.itemName = [Utility getNormalStringFromAttributed:menuItem.itemName];
                    }
                    if (IS_NOT_NULL(tempDict, @"slug")) {
                        menuItem.itemSlug = GET_VALUE_OBJECT(tempDict, @"slug");
                    }
                }
            }
            if (IS_NOT_NULL(mainDict, @"options")) {
                NSMutableArray* tempArray = GET_VALUE_OBJECT(mainDict, @"options");
                if (tempArray) {
                    for (NSDictionary* tempDict in tempArray) {
                        CustomMenuChild * menuChild = [[CustomMenuChild alloc] init];
                        [menuItem.itemChildren addObject:menuChild];
                        if (IS_NOT_NULL(tempDict, @"id")) {
                            menuChild.itemId = GET_VALUE_INT(tempDict, @"id");
                        }
                        if (IS_NOT_NULL(tempDict, @"menu_order")) {
                            menuChild.itemMenuOrder = GET_VALUE_INT(tempDict, @"menu_order");
                        }
                        //                        if (IS_NOT_NULL(tempDict, @"parent")) {
                        //                            menuChild.itemParentId = GET_VALUE_INT(tempDict, @"parent");
                        //                        }
                        if (IS_NOT_NULL(tempDict, @"parent")) {
                            NSString* str = GET_VALUE_OBJECT(tempDict, @"parent");
                            menuChild.itemParentId = [str intValue];
                        }
                        if (IS_NOT_NULL(tempDict, @"name")) {
                            menuChild.itemName = GET_VALUE_OBJECT(tempDict, @"name");
                        }
                        if (IS_NOT_NULL(tempDict, @"redirect_cid")) {
                            menuChild.itemCategoryId = GET_VALUE_INT(tempDict, @"redirect_cid");
                        }
                        if (IS_NOT_NULL(tempDict, @"redirect_url")) {
                            menuChild.itemUrl = GET_VALUE_OBJECT(tempDict, @"redirect_url");
                        }
                    }
                }
            }
        }
    }

    [self refineMenuCategories];
}
+ (void)refineMenuCategories {
    CustomMenu* cMenu = [CustomMenu sharedManager];
    for (CustomMenuItem* cMenuItem in cMenu.items) {

        NSMutableArray* childToRemove = [[NSMutableArray alloc] init];
        for (CustomMenuChild* cMenuChild in cMenuItem.itemChildren) {
            if(cMenuChild.itemParentId != 0){
                [childToRemove addObject:cMenuChild];
            }
        }
        for (CustomMenuChild* cMenuChildToAdd in childToRemove) {
            for (CustomMenuChild* cMenuChild in cMenuItem.itemChildren) {
                if(cMenuChild.itemId == cMenuChildToAdd.itemParentId){
                    [cMenuChild.itemChildren addObject:cMenuChildToAdd];
                    break;
                }
            }
        }
        [cMenuItem.itemChildren removeObjectsInArray:childToRemove];
    }
}
- (void)loadPluginDataForHomePage:(NSDictionary*)dict {
    if (dict) {
        [self loadCommonDataViaPlugin:[dict objectForKey:@"meta_data"]];
        [self loadCategoriesDataViaPlugin:[dict objectForKey:@"category"]];
        [self loadTrendingDatasViaPlugin:[dict objectForKey:@"best_selling"] originalDataArray:[ProductInfo getBestSellingItems] resizeEnable:false];
        [self loadTrendingDatasViaPlugin:[dict objectForKey:@"new_sales"] originalDataArray:[ProductInfo getTrendingItems] resizeEnable:true];
        [self loadTrendingDatasViaPlugin:[dict objectForKey:@"new_arrivals"] originalDataArray:[ProductInfo getNewArrivalItems] resizeEnable:false];
        [self loadPaymentGatewayDatasViaPlugin:[dict objectForKey:@"payment"]];
        [self loadPermanentAttributesViaPlugin:[dict objectForKey:@"attributes"]];
    }
}
- (void)loadPluginDataForVendors:(NSArray*)array {
    [[Vendor getAllVendors] removeAllObjects];
    if (array) {
        for (NSDictionary* dict in array) {
            if (dict) {
                Vendor* vendor = [[Vendor alloc] init];
                if (IS_NOT_NULL(dict, @"seller_id")) {
                    vendor.vendorId = GET_VALUE_OBJECT(dict, @"seller_id");
                }
                if (IS_NOT_NULL(dict, @"seller_name")) {
                    vendor.vendorName = GET_VALUE_OBJECT(dict, @"seller_name");
                }
                if (IS_NOT_NULL(dict, @"seller_location")) {
                    vendor.vendorLocations = GET_VALUE_OBJECT(dict, @"seller_location");
                }
#if ENABLE_ARABIC_TEST
                vendor.vendorName = [NSString stringWithFormat:@"%@ : %@", vendor.vendorName,vendor.vendorId];
#endif
            }
        }
    }
}

- (NSString *)randomStringWithLength:(int)len {
    NSString *letters = @"qwerty";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    RLOG(@"STR Random = %@", randomString);
    return randomString;
}
/*
 public void parseJsonAndCreateFrontPageProducts(String jsonStringContent)
 throws  Exception
 {
 Helper.SOUT("-- parseJsonAndCreateFrontPageProducts: ["+jsonStringContent+"] --");
 jsonStringContent = jsonStringContent.substring(jsonStringContent.indexOf("{"), jsonStringContent.lastIndexOf("}") + 1);
 JSONObject jMainObject = new JSONObject(jsonStringContent);
 //List<TM_ProductInfo> list_products = new ArrayList<>();

 //par 1 - Metadata hack // to reduct common data query
 {
 JSONObject meta_data = jMainObject.getJSONObject("meta_data");
 parseCommonInfoFromJsonString(meta_data);
 }

 //par 2 - actual purpose of this query
 {
 JSONArray category = jMainObject.getJSONArray("category");

 for (int i = 0; i < category.length(); i++) {
 //JSONObject productCategoryComboSet = category.getJSONObject(i);
 //JSONObject jsonObjectCategory = productCategoryComboSet.getJSONObject("category");
 JSONObject jsonObjectCategory = category.getJSONObject(i);
 TM_CategoryInfo categoryInfo = WooCommerceJSONHelper.parseRawCategory(jsonObjectCategory);
 Helper.SOUT("-- FrontPageProducts::found Category [" + categoryInfo.id + "][" + categoryInfo.name + "] ---");
 //categoryInfo.isProductRefreshed = false;
 Helper.SOUT("----------------------------------------------------------------------------");
 }
 }

 //par 3 - hack to show smooth home page
 {
 JSONArray best_selling = jMainObject.getJSONArray("best_selling");
 JSONArray new_arrivals = jMainObject.getJSONArray("new_arrivals");
 JSONArray new_sales = jMainObject.getJSONArray("new_sales");

 if (!TM_ProductInfo.bestDealProductsIds.isEmpty())
 TM_ProductInfo.bestDealProductsIds.clear();

 if (!TM_ProductInfo.freshArrivalProductsIds.isEmpty())
 TM_ProductInfo.freshArrivalProductsIds.clear();

 if (!TM_ProductInfo.trendingProductsIds.isEmpty())
 TM_ProductInfo.trendingProductsIds.clear();

 for (int i = 0; i < best_selling.length(); i++) {
 TM_ProductInfo.bestDealProductsIds.add(WooCommerceJSONHelper.parseHomepageProduct(best_selling.getJSONObject(i)));
 }
 for (int i = 0; i < best_selling.length(); i++) {
 TM_ProductInfo.freshArrivalProductsIds.add(WooCommerceJSONHelper.parseHomepageProduct(new_arrivals.getJSONObject(i)));
 }
 for (int i = 0; i < best_selling.length(); i++) {
 TM_ProductInfo.trendingProductsIds.add(WooCommerceJSONHelper.parseHomepageProduct(new_sales.getJSONObject(i)));
 }
 }

 {
 JSONObject payment = jMainObject.getJSONObject("payment");
 JSONArray gateways = payment.getJSONArray("gateways");
 for(int i=0; i<gateways.length(); i++) {
 JSONObject gateway = gateways.getJSONObject(i);
 TM_PaymentGateway paymentGateway = WooCommerceJSONHelper.parseJsonAndCreateGateway(gateway);
 paymentGateway.commit();
 }
 }

 //
 //        Helper.SOUT("-- JSON Parsing Completed --");
 //        Helper.SOUT("-- Found total: ["+TM_CategoryInfo.getAll().size()+"] categories --");
 //        Helper.SOUT("-- Found total: ["+TM_CategoryInfo.getAllRootCategoryNames().size()+"] root categories --");
 //        for(String rootName : TM_CategoryInfo.getAllRootCategoryNames()) {
 //            Helper.SOUT("      -- ["+rootName+"] --");
 //        }
 //        Helper.SOUT("-- Found total: ["+TM_ProductInfo.getAll().size()+"] Products --");

 //          return list_products;
 }

 public static TM_ProductInfo parseRawProduct(JSONObject productInfoJson) throws JSONException
 {
 int id = productInfoJson.getInt("id");
 TM_ProductInfo product = TM_ProductInfo.getOrCreat(id);

 product.title = Helper.safeString(productInfoJson,"title");
 {
 TM_ProductImage tempImg = new TM_ProductImage();
 tempImg.src = Helper.safeString(productInfoJson,"img");
 product.images.add(tempImg);
 }
 product.price = safeFloat(Helper.safeString(productInfoJson,"price"));
 product.regular_price = safeFloat(Helper.safeString(productInfoJson,"regular_price"));
 product.product_url = Helper.safeString(productInfoJson,"url");
 product.sale_price = safeFloat(Helper.safeString(productInfoJson,"sale_price"));

 return product;
 }
 */
//- (void)loadShippingMethodsDatasViaPlugin:(NSArray*)shippingData {
//    if (shippingData) {
//        TMPaymentSDK* paymentSDK = [[DataManager sharedManager] tmPaymentSDK];
//        NSDictionary* shippingDict = (NSDictionary*) [shippingData objectAtIndex:0];
//        paymentSDK.shippingMethodChoosedId = GET_VALUE_STRING(shippingDict, @"chosen");
//        NSArray* listOfShippingMethods  = GET_VALUE_OBJECT(shippingDict, @"methods");
//        if (listOfShippingMethods) {
//            for (NSDictionary* shippingDict in listOfShippingMethods) {
//                TMShipping* shippingItem = [[TMShipping alloc] init];
//
//                if (IS_NOT_NULL(shippingDict, @"id")) {
//                    shippingItem.shippingId = GET_VALUE_STRING(shippingDict, @"id");
//                }
//                if (IS_NOT_NULL(shippingDict, @"cost")) {
//                    shippingItem.shippingCost = GET_VALUE_FLOAT(shippingDict, @"cost");
//                }
//                if (IS_NOT_NULL(shippingDict, @"label")) {
//                    shippingItem.shippingLabel = GET_VALUE_STRING(shippingDict, @"label");
//                }
//                if (IS_NOT_NULL(shippingDict, @"method_id")) {
//                    shippingItemshippingMethod = GET_VALUE_STRING(shippingDict, @"method_id");
//                }
//
//                TMShipping * shipMtd = [[TMShipping alloc] initWithDictionary:shippingDict];
//                [paymentSDK addShippingMethod:shipMtd];
//            }
//        }
//    }
//}
- (void)loadShippingMethodsDatasViaPlugin:(NSArray*)shippingData {
    if (shippingData) {
        TMShippingSDK* shippingSDK = [[DataManager sharedManager] tmShippingSDK];
        NSDictionary* shippingDict = (NSDictionary*) [shippingData objectAtIndex:0];
        shippingSDK.shippingMethodChoosedId = GET_VALUE_STRING(shippingDict, @"chosen");
        NSArray* listOfShippingMethods  = GET_VALUE_OBJECT(shippingDict, @"methods");
        if (listOfShippingMethods) {
            for (NSDictionary* shippingDict in listOfShippingMethods) {
                TMShipping* shippingItem = [[TMShipping alloc] init];
                if (IS_NOT_NULL(shippingDict, @"id")) {
                    shippingItem.shippingId = GET_VALUE_STRING(shippingDict, @"id");
                }
                if (IS_NOT_NULL(shippingDict, @"cost")) {
                    shippingItem.shippingCost = GET_VALUE_FLOAT(shippingDict, @"cost");
                }
                if (IS_NOT_NULL(shippingDict, @"label")) {
                    shippingItem.shippingLabel = GET_VALUE_STRING(shippingDict, @"label");
                }
                if (IS_NOT_NULL(shippingDict, @"method_id")) {
                    shippingItem.shippingMethodId = GET_VALUE_STRING(shippingDict, @"method_id");
                }
                if (IS_NOT_NULL(shippingDict, @"taxable")) {
                    shippingItem.taxable = GET_VALUE_BOOL(shippingDict, @"taxable");
                }
                [shippingSDK addShippingMethod:shippingItem];
            }
        }
    }
}
- (NSArray*)parseJsonAndCreateShipping:(id)response {
    NSMutableArray* shipping = [[NSMutableArray alloc] init];
    if (response) {
        if (IS_NOT_NULL(response, @"rajaongkir")) {
            NSDictionary* rajaongkir = GET_VALUE_OBJECT(response, @"rajaongkir");
            if (IS_NOT_NULL(rajaongkir, @"results")) {
                NSArray* results = GET_VALUE_OBJECT(rajaongkir, @"results");
                for (NSDictionary* resultObject in results) {
                    NSArray* costs = GET_VALUE_OBJECT(resultObject, @"costs");
                    for (NSDictionary* costsJSONObject in costs) {
                        TMShipping* shippingItem = [[TMShipping alloc] init];
                        shippingItem.shippingId = GET_VALUE_OBJECT(resultObject, @"code");
                        shippingItem.shippingMethodId = GET_VALUE_OBJECT(costsJSONObject, @"service");
                        shippingItem.shippingLabel = [NSString stringWithFormat:@"%@ %@", [shippingItem.shippingId uppercaseString], shippingItem.shippingMethodId];
                        shippingItem.shippingDescription = GET_VALUE_OBJECT(costsJSONObject, @"description");
                        {
                            NSArray* cost = GET_VALUE_OBJECT(costsJSONObject, @"cost");
                            NSDictionary* faltuKaObject = [cost objectAtIndex:0];
                            shippingItem.shippingCost = GET_VALUE_FLOAT(faltuKaObject, @"value");
                            shippingItem.shippingEtd = GET_VALUE_OBJECT(faltuKaObject, @"etd");
                        }
                        [shipping addObject:shippingItem];
                    }
                }
            }
        }
    }
    return [NSArray arrayWithArray:shipping];
}
- (void)loadPermanentAttributesViaPlugin:(NSArray*)mainArray {
    if (![mainArray isKindOfClass:[NSArray class]]) {
        return;
    }
    if (mainArray) {
        for (NSDictionary* dict in mainArray) {
            PermanentAttribute* pAttr = [[PermanentAttribute alloc] init];
            if (IS_NOT_NULL(dict, @"slug")) {
                pAttr.slug = GET_VALUE_OBJECT(dict, @"slug");
            }
            if (IS_NOT_NULL(dict, @"terms")) {
                NSArray* termsArray = GET_VALUE_OBJECT(dict, @"terms");
                if (termsArray) {
                    for (NSDictionary* termsDict in termsArray) {
                        NSString* termSlug = @"";
                        NSString* termName = @"";
                        if (IS_NOT_NULL(termsDict, @"slug")) {
                            termSlug = GET_VALUE_OBJECT(termsDict, @"slug");
                        }
                        if (IS_NOT_NULL(termsDict, @"name")) {
                            termName = GET_VALUE_OBJECT(termsDict, @"name");
                        }
                        [pAttr.terms setValue:termName forKey:termSlug];
                    }
                }
            }
        }
    }

    //    NSMutableArray* array = [PermanentAttribute getAllPermanentAttributes];
}
- (void)loadCheckoutAddonsViaPlugin:(NSArray*)checkoutAddons {
    [TM_CheckoutAddon clearAllCheckoutAddons];

    for (id obj in checkoutAddons) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            NSDictionary* dict = (NSDictionary*)obj;
            if (dict) {
                TM_CheckoutAddon* cAddon = [[TM_CheckoutAddon alloc] init];
                if (IS_NOT_NULL(dict, @"cost")) {
                    cAddon.cost = GET_VALUE_FLOAT(dict, @"cost");
                }
                if (IS_NOT_NULL(dict, @"label")) {
                    cAddon.label = GET_VALUE_STRING(dict, @"label");
                }
                if (IS_NOT_NULL(dict, @"name")) {
                    cAddon.name = GET_VALUE_STRING(dict, @"name");
                }
                if (IS_NOT_NULL(dict, @"type")) {
                    NSString* strType = GET_VALUE_STRING(dict, @"type");
                    if ([strType isEqualToString:@"checkbox"]) {
                        cAddon.type = TM_CheckoutAddonType_CHECKBOX;
                    }
                }
            }
        }
    }
}
- (void)loadPaymentGatewayDatasViaPlugin:(NSDictionary*)mainDict {

    TMPaymentSDK* paymentSDK = [[DataManager sharedManager] tmPaymentSDK];
    [paymentSDK resetPaymentGateways];
    Addons* addons = [Addons sharedManager];
    NSMutableArray* listOfGateways = [[NSMutableArray alloc] init];
    for (NSObject* obj in addons.addonPayments) {
        if ([obj isKindOfClass:[ApplePayViaStripeConfig class]]) {
            ApplePayViaStripeConfig* config = (ApplePayViaStripeConfig*)obj;
            if(config.cIsDefaultGateway){
                NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
                [dict setValue:config.cId forKey:@"id"];
                [dict setValue:config.cTitle forKey:@"title"];
                [listOfGateways addObject:dict];
            }
        }
        else if ([obj isKindOfClass:[StripeConfig class]]) {
            StripeConfig* config = (StripeConfig*)obj;
            if(config.cIsDefaultGateway){
                NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
                [dict setValue:config.cId forKey:@"id"];
                [dict setValue:config.cTitle forKey:@"title"];
                [listOfGateways addObject:dict];
            }
        }
        else if ([obj isKindOfClass:[PaystackConfig class]]) {
            PaystackConfig* config = (PaystackConfig*)obj;
            if(config.cIsDefaultGateway){
                NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
                [dict setValue:config.cId forKey:@"id"];
                [dict setValue:config.cTitle forKey:@"title"];
                [listOfGateways addObject:dict];
            }
        }
        else if ([obj isKindOfClass:[SagepayConfig class]]) {
            SagepayConfig* config = (SagepayConfig*)obj;
            if(config.cIsDefaultGateway){
                NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
                [dict setValue:config.cId forKey:@"id"];
                [dict setValue:config.cTitle forKey:@"title"];
                [listOfGateways addObject:dict];
            }
        }
        else if ([obj isKindOfClass:[GestpayConfig class]]) {
            GestpayConfig* config = (GestpayConfig*)obj;
            if(config.cIsDefaultGateway){
                NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
                [dict setValue:config.cId forKey:@"id"];
                [dict setValue:config.cTitle forKey:@"title"];
                [listOfGateways addObject:dict];
            }
        }
        else if ([obj isKindOfClass:[KentPaymentConfig class]]) {
            KentPaymentConfig* config = (KentPaymentConfig*)obj;
            if(config.cIsDefaultGateway){
                NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
                [dict setValue:config.cId forKey:@"id"];
                [dict setValue:config.cTitle forKey:@"title"];
                [listOfGateways addObject:dict];
            }
        }
        else if ([obj isKindOfClass:[PayPalPayFlowConfig class]]) {
            PayPalPayFlowConfig* config = (PayPalPayFlowConfig*)obj;
            if(config.cIsDefaultGateway){
                NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
                [dict setValue:config.cId forKey:@"id"];
                [dict setValue:config.cTitle forKey:@"title"];
                [listOfGateways addObject:dict];
            }
        }
        else if ([obj isKindOfClass:[VCSPayConfig class]]) {
            VCSPayConfig* config = (VCSPayConfig*)obj;
            if(config.cIsDefaultGateway){
                NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
                [dict setValue:config.cId forKey:@"id"];
                [dict setValue:config.cTitle forKey:@"title"];
                [listOfGateways addObject:dict];
            }
        }
        else if ([obj isKindOfClass:[TapPaymentConfig class]]) {
            TapPaymentConfig* config = (TapPaymentConfig*)obj;
            if(config.cIsDefaultGateway){
                NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
                [dict setValue:config.cId forKey:@"id"];
                [dict setValue:config.cTitle forKey:@"title"];
                [listOfGateways addObject:dict];
            }
        }
        else if ([obj isKindOfClass:[PlugNPayPaymentConfig class]]) {
            PlugNPayPaymentConfig* config = (PlugNPayPaymentConfig*)obj;
            if(config.cIsDefaultGateway){
                NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
                [dict setValue:config.cId forKey:@"id"];
                [dict setValue:config.cTitle forKey:@"title"];
                [listOfGateways addObject:dict];
            }
        }
        else if ([obj isKindOfClass:[SenangPayPaymentConfig class]]) {
            SenangPayPaymentConfig* config = (SenangPayPaymentConfig*)obj;
            if(config.cIsDefaultGateway){
                NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
                [dict setValue:config.cId forKey:@"id"];
                [dict setValue:config.cTitle forKey:@"title"];
                [listOfGateways addObject:dict];
            }
        }
        else if ([obj isKindOfClass:[MolliePaymentConfig class]]) {
            MolliePaymentConfig* config = (MolliePaymentConfig*)obj;
            if(config.cIsDefaultGateway){
                NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
                [dict setValue:config.cId forKey:@"id"];
                [dict setValue:config.cTitle forKey:@"title"];
                [listOfGateways addObject:dict];
            }
        }
        else if ([obj isKindOfClass:[HesabePaymentConfig class]]) {
            HesabePaymentConfig* config = (HesabePaymentConfig*)obj;
            if(config.cIsDefaultGateway){
                NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
                [dict setValue:config.cId forKey:@"id"];
                [dict setValue:config.cTitle forKey:@"title"];
                [listOfGateways addObject:dict];
            }
        }
        else if ([obj isKindOfClass:[ConektaCardConfig class]]) {
            ConektaCardConfig* config = (ConektaCardConfig*)obj;
            if(config.cIsDefaultGateway){
                NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
                [dict setValue:config.cId forKey:@"id"];
                [dict setValue:config.cTitle forKey:@"title"];
                [listOfGateways addObject:dict];
            }
        }
        else if ([obj isKindOfClass:[BraintreeConfig class]]) {
            BraintreeConfig* config = (BraintreeConfig*)obj;
            if(config.cIsDefaultGateway){
                NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
                [dict setValue:config.cId forKey:@"id"];
                [dict setValue:config.cTitle forKey:@"title"];
                [listOfGateways addObject:dict];
            }
        }
        else if ([obj isKindOfClass:[MyGateConfig class]]) {
            MyGateConfig* config = (MyGateConfig*)obj;
            if(config.cIsDefaultGateway){
                NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
                [dict setValue:config.cId forKey:@"id"];
                [dict setValue:config.cTitle forKey:@"title"];
                [listOfGateways addObject:dict];
            }
        }
        else if ([obj isKindOfClass:[AuthorizeNetConfig class]]) {
            AuthorizeNetConfig* config = (AuthorizeNetConfig*)obj;
            if(config.cIsDefaultGateway){
                NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
                [dict setValue:config.cId forKey:@"id"];
                [dict setValue:config.cTitle forKey:@"title"];
                [listOfGateways addObject:dict];
            }
        }
        else if ([obj isKindOfClass:[DusupayConfig class]]) {
            DusupayConfig* config = (DusupayConfig*)obj;
            if(config.cIsDefaultGateway){
                NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
                [dict setValue:config.cId forKey:@"id"];
                [dict setValue:config.cTitle forKey:@"title"];
                [listOfGateways addObject:dict];
            }
        }
    }


    if (mainDict && [mainDict isKindOfClass:[NSDictionary class]]) {
        NSArray* tempListOfGateways = nil;
        if (IS_NOT_NULL(mainDict, @"gateways")) {
            tempListOfGateways = GET_VALUE_OBJECT(mainDict, @"gateways");
        }

        if (tempListOfGateways) {
            [listOfGateways addObjectsFromArray:tempListOfGateways];
        }
    }
    if (listOfGateways) {
        BOOL otherGatewayExits = false;
        for (NSDictionary* gaywayDict in listOfGateways) {
            TMPaymentGateway* gateway = [[TMPaymentGateway alloc] initWithDictionary:gaywayDict];
            BOOL thisGatewayExists = false;
            if ([gateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_COD]] ||
                [gateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_CHEQUE]] ||
                [gateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_DBT]] ||
                [gateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_JETPACK1]] ||
                [gateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_JETPACK2]] ||
                [gateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_JETPACK3]]) {
                thisGatewayExists = true;
                //                    gateway.isPrepaid = false;
            }
#if ENABLE_PAYPAL
            else if ([gateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_PAYPAL]]) {
                PayPalConfig* config = [PayPalConfig sharedManager];
                if (config.cIsEnabled) {
                    thisGatewayExists = true;
                }
            }
#endif
#if ENABLE_PAYU
            else if ([gateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_PAYU_IN]] || [gateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_PAYU_INDIA]]) {
                PayuConfig* config = [PayuConfig sharedManager];
                if (config.cIsEnabled) {
                    thisGatewayExists = true;
                }
            }
#endif
#if ENABLE_DUSUPAY
            else if ([gateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_DUSUPAY]]) {
                DusupayConfig* config = [DusupayConfig sharedManager];
                if (config.cIsEnabled) {
                    thisGatewayExists = true;
                }
            }
#endif

#if ENABLE_STRIPE
            else if ([gateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_STRIPE]]) {
                StripeConfig* config = [StripeConfig sharedManager];
                if (config.cIsEnabled) {
                    thisGatewayExists = true;
                }
            }
#endif
#if ENABLE_PAYSTACK
            else if ([gateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_PAYSTACK]]) {
                PaystackConfig* config = [PaystackConfig sharedManager];
                if (config.cIsEnabled) {
                    thisGatewayExists = true;
                }
            }
#endif
#if ENABLE_APPLE_PAY_VIA_STRIPE
            else if ([gateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_APPLE_PAY_VIA_STRIPE]]) {
                ApplePayViaStripeConfig* config = [ApplePayViaStripeConfig sharedManager];
                if (config.cIsEnabled) {
                    if ([PKPaymentAuthorizationViewController canMakePayments] && /*[Stripe deviceSupportsApplePay] &&*/ [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.1) {
                        thisGatewayExists = true;
                    }
                }
            }
#endif
#if ENABLE_SAGEPAY
            else if ([gateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_SAGEPAY]]) {
                SagepayConfig* config = [SagepayConfig sharedManager];
                if (config.cIsEnabled) {
                    thisGatewayExists = true;
                }
            }
#endif
#if ENABLE_GESTPAY
            else if ([gateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_GESTPAY]]) {
                GestpayConfig* config = [GestpayConfig sharedManager];
                if (config.cIsEnabled) {
                    thisGatewayExists = true;
                }
            }
#endif
#if ENABLE_KENT_PAYMENT
            else if ([gateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_KENT_PAYMENT]]) {
                KentPaymentConfig* config = [KentPaymentConfig sharedManager];
                if (config.cIsEnabled) {
                    thisGatewayExists = true;
                }
            }
#endif
#if ENABLE_PAYPAL_PAYFLOW
            else if ([gateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_PAYPAL_PAYFLOW]]) {
                PayPalPayFlowConfig* config = [PayPalPayFlowConfig sharedManager];
                if (config.cIsEnabled) {
                    thisGatewayExists = true;
                }
            }
#endif
#if ENABLE_VCS_PAY
            else if ([gateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_VCS_PAY]]) {
                VCSPayConfig* config = [VCSPayConfig sharedManager];
                if (config.cIsEnabled) {
                    thisGatewayExists = true;
                }
            }
#endif
#if ENABLE_TAP_PAYMENT
            else if ([gateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_TAP_PAYMENT]]) {
                TapPaymentConfig* config = [TapPaymentConfig sharedManager];
                if (config.cIsEnabled) {
                    thisGatewayExists = true;
                }
            }
#endif
#if ENABLE_PLUGNPAY_PAYMENT
            else if ([gateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_PLUGNPAY_PAYMENT]]) {
                PlugNPayPaymentConfig* config = [PlugNPayPaymentConfig sharedManager];
                if (config.cIsEnabled) {
                    thisGatewayExists = true;
                }
            }
#endif
#if ENABLE_SENANGPAY_PAYMENT
            else if ([gateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_SENANGPAY_PAYMENT]]) {
                SenangPayPaymentConfig* config = [SenangPayPaymentConfig sharedManager];
                if (config.cIsEnabled) {
                    thisGatewayExists = true;
                }
            }
#endif
#if ENABLE_MOLLIE_PAYMENT
            else if ([gateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_MOLLIE_PAYMENT]]) {
                MolliePaymentConfig* config = [MolliePaymentConfig sharedManager];
                if (config.cIsEnabled) {
                    thisGatewayExists = true;
                }
            }
#endif
#if ENABLE_HESABE_PAYMENT
            else if ([gateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_HESABE_PAYMENT]]) {
                HesabePaymentConfig* config = [HesabePaymentConfig sharedManager];
                if (config.cIsEnabled) {
                    thisGatewayExists = true;
                }
            }
#endif
#if ENABLE_CONEKTA_CARD
            else if ([gateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_CONEKTA_CARD]]) {
                ConektaCardConfig* config = [ConektaCardConfig sharedManager];
                if (config.cIsEnabled) {
                    thisGatewayExists = true;
                }
            }
#endif
#if ENABLE_BRAINTREE
            else if ([gateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_BRAINTREE]]) {
                BraintreeConfig* config = [BraintreeConfig sharedManager];
                if (config.cIsEnabled) {
                    thisGatewayExists = true;
                }
            }
#endif
#if ENABLE_MYGATE
            else if ([gateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_MYGATE]]) {
                MyGateConfig* config = [MyGateConfig sharedManager];
                if (config.cIsEnabled) {
                    thisGatewayExists = true;
                }
            }
#endif
#if ENABLE_AUTHORIZENET
            else if ([gateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_AUTHORIZENET]]) {
                AuthorizeNetConfig* config = [AuthorizeNetConfig sharedManager];
                if (config.cIsEnabled) {
                    thisGatewayExists = true;
                }
            }
#endif
            else if ([gateway.paymentId isEqualToString:PAYMENT_GATEWAYS[PAYMENT_GATEWAY_TYPE_CCAVENUE]]) {
                CCAvenueConfig* config = [CCAvenueConfig getInstance];
                if (config.cIsEnabled) {
                    thisGatewayExists = true;
                }
            }
            if (thisGatewayExists) {
                TMPaymentSDK* paymentSDK = [[DataManager sharedManager] tmPaymentSDK];
                [paymentSDK addPaymentGateway:gateway];
            } else {
                otherGatewayExits = true;
            }
        }

        if (otherGatewayExits) {
            if ([[Addons sharedManager] enable_webview_payment]) {
                TMPaymentGateway* gateway = [[TMPaymentGateway alloc] init];
                TMPaymentSDK* paymentSDK = [[DataManager sharedManager] tmPaymentSDK];
                [paymentSDK addPaymentGateway:gateway];
                gateway.paymentId = @"pay_from_merchant_site";
                NSString* stringAppDisplayName = Localize(@"app_display_name");
                if ([stringAppDisplayName isEqualToString:@""] || [stringAppDisplayName isEqualToString:@"app_display_name"]) {                    stringAppDisplayName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
                }
                gateway.paymentTitle = [NSString stringWithFormat:@"%@ %@", Localize(@"i_select_payment_from"), stringAppDisplayName];
                gateway.paymentDescription = @"";
                gateway.paymentIconPath = @"";
                gateway.paymentOrderButtonText = @"";
                gateway.isPaymentEnabled = YES;
                gateway.isPaymentTestModeEnabled = NO;
                gateway.isPaymentGatewayChoosen = NO;
            }
        }
    }

}
- (void)loadPluginDataForCountries:(NSDictionary*)mainDict {
    if (IS_NOT_NULL(mainDict, @"list")) {
        NSArray* listOfCountries = GET_VALUE_OBJECT(mainDict, @"list");
        for (NSDictionary* countryDict in listOfCountries) {
            NSString* countryID = @"";
            NSString* countryName = @"";
            if (IS_NOT_NULL(countryDict, @"id"))
                countryID = GET_VALUE_STRING(countryDict, @"id");
            if (IS_NOT_NULL(countryDict, @"n"))
                countryName = GET_VALUE_STRING(countryDict, @"n");
            TMCountry* country = [[TMCountry alloc] init];
            country.countryId = countryID;
            country.countryName = countryName;

            NSArray* countryStates = GET_VALUE_OBJECT(countryDict, @"s");
            for (NSDictionary* stateDict in countryStates) {
                NSString* stateID = GET_VALUE_STRING(stateDict, @"id");
                NSString* stateName = GET_VALUE_STRING(stateDict, @"n");
                TMState* state = [[TMState alloc] init];
                state.stateId = stateID;
                state.stateName = stateName;
                [country.countryStates addObject:state];
            }
        }
    }

    NSMutableArray* allCountryList = [TMCountry getAllCountries];
    RLOG(@"country count = %d", (int)allCountryList.count);


    AppUser* appUser = [AppUser sharedManager];
    if(![appUser._billing_address._countryId isEqualToString:@""]){
        TMCountry* country = [TMCountry getCountryById:appUser._billing_address._countryId];
        appUser._billing_address._country = country.countryName;
    }
    if(![appUser._billing_address._stateId isEqualToString:@""]){
        TMState* state = [TMState getStateById:[TMCountry getCountryById:appUser._billing_address._countryId] stateId:appUser._billing_address._stateId];
        appUser._billing_address._state = state.stateName;
    }

    if(![appUser._shipping_address._countryId isEqualToString:@""]){
        TMCountry* country = [TMCountry getCountryById:appUser._shipping_address._countryId];
        appUser._shipping_address._country = country.countryName;
    }
    if(![appUser._shipping_address._stateId isEqualToString:@""]){
        TMState* state = [TMState getStateById:[TMCountry getCountryById:appUser._shipping_address._countryId] stateId:appUser._shipping_address._stateId];
        appUser._shipping_address._state = state.stateName;
    }



}
- (void)loadPluginDataForInitialProducts:(NSArray*)dict {
    [self loadProductsDataViaPlugin:dict];
}
- (void)loadPluginDataForCartProducts:(NSArray *)productArray {
    if (productArray) {
        for (NSDictionary* dict in productArray) {
            int productId = 0;
            int varId = -1;
            int varIndex = -1;
            if (IS_NOT_NULL(dict, @"id")) {
                productId = GET_VALUE_INT(dict, @"id");
            }
            if (IS_NOT_NULL(dict, @"vid")) {
                varId = GET_VALUE_INT(dict, @"vid");
            }
            if (IS_NOT_NULL(dict, @"index")) {
                varIndex = GET_VALUE_INT(dict, @"index");
            }

            ProductInfo* pInfo = [ProductInfo getProductWithId:productId];

            if (IS_NOT_NULL(dict, @"category_ids")) {
                NSArray* categoriesIds = GET_VALUE_STRING(dict, @"category_ids");
                if (categoriesIds) {
                    for (NSNumber* obj in categoriesIds) {
                        int categoryId = [obj intValue];
                        CategoryInfo* ccinfo = [CategoryInfo getWithId:categoryId];
                        if ([pInfo._categories containsObject:ccinfo] == false) {
                            [pInfo._categories addObject:ccinfo];
                        }
                    }
                }
            }


            if (IS_NOT_NULL(dict, @"average_rating")) {
                pInfo._average_rating = GET_VALUE_FLOAT(dict, @"average_rating");
            }
            if (IS_NOT_NULL(dict, @"featured")) {
                pInfo._featured = GET_VALUE_BOOL(dict, @"featured");
            }
            if (IS_NOT_NULL(dict, @"title")) {
                pInfo._title = GET_VALUE_OBJECT(dict, @"title");
            }
            if (IS_NOT_NULL(dict, @"total_sales")) {
                pInfo._total_sales = GET_VALUE_INT(dict, @"total_sales");
            }
            if (IS_NOT_NULL(dict, @"type")) {
                NSString* productType = GET_VALUE_STRING(dict, @"type");
                if ([productType isEqualToString:@"simple"]) {
                    pInfo._type = PRODUCT_TYPE_SIMPLE;
                }
                if ([productType isEqualToString:@"grouped"]) {
                    pInfo._type = PRODUCT_TYPE_GROUPED;
                }
                if ([productType isEqualToString:@"external"]) {
                    pInfo._type = PRODUCT_TYPE_EXTERNAL_OR_AFFILIATE;
                }
                if ([productType isEqualToString:@"variable"]) {
                    pInfo._type = PRODUCT_TYPE_VARIABLE;
                }
                if ([productType isEqualToString:@"variable-subscription"]) {
                    pInfo._type = PRODUCT_TYPE_VARIABLE;
                }
                if ([productType isEqualToString:@"bundle"]) {
                    pInfo._type = PRODUCT_TYPE_BUNDLE;
                }
                if ([productType isEqualToString:@"yith_bundle"]) {
                    pInfo._type = PRODUCT_TYPE_BUNDLE;
                }
                if ([productType isEqualToString:@"mix-and-match"]) {
                    pInfo._type = PRODUCT_TYPE_MIXNMATCH;
                }
                if ([productType isEqualToString:@"downloadable"]) {
                    pInfo._type = PRODUCT_TYPE_DOWNLOADABLE;
                }
            }
            if (IS_NOT_NULL(dict, @"button_text")) {
                pInfo.button_text = GET_VALUE_STRING(dict, @"button_text");
            }
            if (IS_NOT_NULL(dict, @"url")) {
                pInfo._product_url = GET_VALUE_OBJECT(dict, @"url");
            }

            if (varId != -1) {
                Variation* pVar = [pInfo._variations getVariation:varId variationIndex:varIndex];
                if(pVar == nil){
                    pVar = [[Variation alloc] init];
                    [pInfo._variations addObject:pVar];
                }
                pVar._id = varId;
                if (IS_NOT_NULL(dict, @"backorders")) {
                    pVar._backordered = GET_VALUE_BOOL(dict, @"backorders");
                }
                if (IS_NOT_NULL(dict, @"manage_stock")) {
                    pVar._managing_stock = GET_VALUE_BOOL(dict, @"manage_stock");
                }
                if (IS_NOT_NULL(dict, @"price")) {
                    pVar._price = GET_VALUE_FLOAT(dict, @"price");
                }
                if (IS_NOT_NULL(dict, @"regular_price")) {
                    pVar._regular_price = GET_VALUE_FLOAT(dict, @"regular_price");
                }
                if (IS_NOT_NULL(dict, @"sale_price")) {
                    pVar._sale_price = GET_VALUE_FLOAT(dict, @"sale_price");
                }

                [CurrencyHelper applyCurrencyRateForVariation:pVar];

                if (IS_NOT_NULL(dict, @"taxable")) {
                    pVar._taxable = GET_VALUE_BOOL(dict, @"taxable");
                }
                if (IS_NOT_NULL(dict, @"tax_status")) {
                    pVar._tax_status = GET_VALUE_STRING(dict, @"tax_status");
                }
                if (IS_NOT_NULL(dict, @"tax_class")) {
                    pVar._tax_class = GET_VALUE_STRING(dict, @"tax_class");
                }
                [self setPriceFromTax:pVar];

                if (IS_NOT_NULL(dict, @"stock")) {
                    pVar._stock_quantity = GET_VALUE_INT(dict, @"stock");
                }
                if (IS_NOT_NULL(dict, @"weight")) {
                    pVar._weight = GET_VALUE_FLOAT(dict, @"weight");
                }
                if (IS_NOT_NULL(dict, @"stock_status")) {
                    NSString* stockStr = GET_VALUE_OBJECT(dict, @"stock_status");
                    if ([stockStr isEqualToString:@"instock"]) {
                        pVar._in_stock = true;
                    } else {
                        pVar._in_stock = false;
                    }
                }
                ProductImage* pImg = [[ProductImage alloc] init];
                if (IS_NOT_NULL(dict, @"img")) {
                    pImg._src = GET_VALUE_OBJECT(dict, @"img");
                }
                [pVar._images addObject:pImg];
            } else {
                if (IS_NOT_NULL(dict, @"backorders")) {
                    pInfo._backordered = GET_VALUE_BOOL(dict, @"backorders");
                }
                if (IS_NOT_NULL(dict, @"manage_stock")) {
                    pInfo._managing_stock = GET_VALUE_BOOL(dict, @"manage_stock");
                }
                if (IS_NOT_NULL(dict, @"price")) {
                    pInfo._price = GET_VALUE_FLOAT(dict, @"price");
                }
                if (IS_NOT_NULL(dict, @"regular_price")) {
                    pInfo._regular_price = GET_VALUE_FLOAT(dict, @"regular_price");
                }
                if (IS_NOT_NULL(dict, @"sale_price")) {
                    pInfo._sale_price = GET_VALUE_FLOAT(dict, @"sale_price");
                }

                [CurrencyHelper applyCurrencyRate:pInfo];

                if (IS_NOT_NULL(dict, @"stock")) {
                    pInfo._stock_quantity = GET_VALUE_INT(dict, @"stock");
                }
                if (IS_NOT_NULL(dict, @"taxable")) {
                    pInfo._taxable = GET_VALUE_BOOL(dict, @"taxable");
                }
                if (IS_NOT_NULL(dict, @"tax_status")) {
                    pInfo._tax_status = GET_VALUE_STRING(dict, @"tax_status");
                }
                if (IS_NOT_NULL(dict, @"tax_class")) {
                    pInfo._tax_class = GET_VALUE_STRING(dict, @"tax_class");
                }
                [self setPriceFromTax:pInfo];

                if (IS_NOT_NULL(dict, @"weight")) {
                    pInfo._weight = GET_VALUE_FLOAT(dict, @"weight");
                }
                if (IS_NOT_NULL(dict, @"stock_status")) {
                    NSString* stockStr = GET_VALUE_OBJECT(dict, @"stock_status");
                    if ([stockStr isEqualToString:@"instock"]) {
                        pInfo._in_stock = true;
                    } else {
                        pInfo._in_stock = false;
                    }
                }
                if (pInfo._isFullRetrieved == false) {
                    ProductImage* pImg = [[ProductImage alloc] init];
                    if (IS_NOT_NULL(dict, @"index")) {
                        pImg._src = GET_VALUE_OBJECT(dict, @"img");
                    }
                    [pInfo._images addObject:pImg];
                }
            }
            [self parseAndSetProductPriceLabels:dict product:pInfo];
            if (dict != nil || [dict objectForKey:@"min_qty_rule"]) {
                [WC2X_JsonHelper parseAndSetProductQuantityRules:dict product:pInfo];
            }
        }

    }

}
- (void)loadPluginDataForMoreProducts:(NSArray *)productArray {
    if (productArray) {
        [self loadTrendingDatasViaPlugin:productArray originalDataArray:nil resizeEnable:true];
    }
}
- (void)loadProductsDataViaPlugin:(NSArray *)dictionary {
    if(dictionary == nil){
        RLOG(@"loadProductsDataViaPlugin: No data found");
        return;
    }
    NSDictionary* mainDict = nil;
    for (mainDict in dictionary) {
        NSDictionary* categoryDict;
        NSArray* productArray;
        int categoryId = 0;
        if (IS_NOT_NULL(mainDict, @"category")) {
            categoryDict = GET_VALUE_OBJECT(mainDict, @"category");
            if (IS_NOT_NULL(categoryDict, @"id")) {
                categoryId = GET_VALUE_INT(categoryDict, @"id");
            }
        }

        
        if (IS_NOT_NULL(mainDict, @"products")) {
            productArray = GET_VALUE_OBJECT(mainDict, @"products");
        }
        
        NSDictionary* pDict = nil;
        CommonInfo *commonInfo = [CommonInfo sharedManager];
        for (pDict in productArray) {

            int productId = -1;
            if (IS_NOT_NULL(pDict, @"id")) {
                productId = GET_VALUE_INT(pDict, @"id");
            }

            if (commonInfo->_hideOutOfStock) {
                if (IS_NOT_NULL(pDict, @"stock")) {
                    BOOL isProductInStock = GET_VALUE_BOOL(pDict, @"stock");
                    if (isProductInStock == false) {
                        continue;
                    }
                }
            }
            ProductInfo* p = [ProductInfo getProductWithId:productId];
            if (p == nil) {
                p = [[ProductInfo alloc] init];
            }
            p._isSmallRetrived = true;

            if (IS_NOT_NULL(pDict, @"title")) {
                p._title = GET_VALUE_STRING(pDict, @"title");
            }
            if (IS_NOT_NULL(pDict, @"id")) {
                p._id = GET_VALUE_INT(pDict, @"id");
            }
            if (IS_NOT_NULL(pDict, @"price")) {
                p._price = GET_VALUE_FLOAT(pDict, @"price");
            }
            if (IS_NOT_NULL(pDict, @"regular_price")) {
                p._regular_price = GET_VALUE_FLOAT(pDict, @"regular_price");
            }
            if (IS_NOT_NULL(pDict, @"sale_price")) {
                p._sale_price = GET_VALUE_FLOAT(pDict, @"sale_price");
            }

            [CurrencyHelper applyCurrencyRate:p];

            if (IS_NOT_NULL(pDict, @"taxable")) {
                p._taxable = GET_VALUE_BOOL(pDict, @"taxable");
            }
            if (IS_NOT_NULL(pDict, @"tax_status")) {
                p._tax_status = GET_VALUE_STRING(pDict, @"tax_status");
            }
            if (IS_NOT_NULL(pDict, @"tax_class")) {
                p._tax_class = GET_VALUE_STRING(pDict, @"tax_class");
            }
            [self setPriceFromTax:p];


            {
                float priceToUse = p._regular_price != 0 ? p._regular_price : p._price;
                float discountPrice = p._sale_price != 0? (priceToUse - p._sale_price) : 0;
                if (discountPrice > 0) {
                    p._discount = discountPrice*100.0f/priceToUse;
                } else {
                    p._discount = 0;
                }
            }
            if (IS_NOT_NULL(pDict, @"stock")) {
                p._in_stock = GET_VALUE_BOOL(pDict, @"stock");
            }
            if (IS_NOT_NULL(pDict, @"type")) {
                NSString* productType = GET_VALUE_STRING(pDict, @"type");
                if ([productType isEqualToString:@"simple"]) {
                    p._type = PRODUCT_TYPE_SIMPLE;
                }
                if ([productType isEqualToString:@"grouped"]) {
                    p._type = PRODUCT_TYPE_GROUPED;
                }
                if ([productType isEqualToString:@"external"]) {
                    p._type = PRODUCT_TYPE_EXTERNAL_OR_AFFILIATE;
                }
                if ([productType isEqualToString:@"variable"]) {
                    p._type = PRODUCT_TYPE_VARIABLE;
                }
                if ([productType isEqualToString:@"variable-subscription"]) {
                    p._type = PRODUCT_TYPE_VARIABLE;
                }
                if ([productType isEqualToString:@"bundle"]) {
                    p._type = PRODUCT_TYPE_BUNDLE;
                }
                if ([productType isEqualToString:@"yith_bundle"]) {
                    p._type = PRODUCT_TYPE_BUNDLE;
                }
                if ([productType isEqualToString:@"mix-and-match"]) {
                    p._type = PRODUCT_TYPE_MIXNMATCH;
                }
                if ([productType isEqualToString:@"downloadable"]) {
                    p._type = PRODUCT_TYPE_DOWNLOADABLE;
                }
            }
            if (IS_NOT_NULL(pDict, @"button_text")) {
                p.button_text = GET_VALUE_STRING(pDict, @"button_text");
            }
            if (IS_NOT_NULL(pDict, @"desc") && p._isFullRetrieved == false) {
                p._short_description = GET_VALUE_STRING(pDict, @"desc");//A
                p.shortDescAttribStr = nil;
            }
            if (IS_NOT_NULL(pDict, @"tags")) {
                [p._tags addObjectsFromArray:[pDict objectForKey:@"tags"]] ;
            }
            if (IS_NOT_NULL(pDict, @"img")) {
                [p._images removeAllObjects];
                ProductImage* pImage = [[ProductImage alloc] init];
                pImage._src = GET_VALUE_STRING(pDict, @"img");
 //TODO IMAGE_RESIZE
                pImage._src = [[Utility sharedManager] getResizedImageUrl:pImage._src];
                if (p._featured_src == nil || [p._featured_src isEqualToString:@""]) {
                    p._featured_src = pImage._src;
                }
                [p addImage:pImage];
            } else {
                [p._images removeAllObjects];
                ProductImage* pImage = [[ProductImage alloc] init];
                [p._images addObject:pImage];
            }
            if (IS_NOT_NULL(pDict, @"url")) {
                if ([GET_VALUE_STRING(pDict, @"url") isKindOfClass:[NSNumber class]]) {
                    p._product_url = @"";
                }else{
                    p._product_url = GET_VALUE_STRING(pDict, @"url");
                }
            }

            CategoryInfo* ccinfo = [CategoryInfo getWithId:categoryId];
            if ([p._categories containsObject:ccinfo] == false) {
                [p._categories addObject:ccinfo];
                [p addInAllParentCategory:ccinfo];
            }

            p._isDiscountedForOuterView = [p isProductDiscounted:-1];
            p._newPriceForOuterView = [p getNewPrice:-1];
            p._oldPriceForOuterView = [p getOldPrice:-1];
            p._titleForOuterView = [Utility getNormalStringFromAttributed:p._title] ;
            //            p._titleForOuterView = [NSString stringWithFormat:@"%@\n", [Utility getNormalStringFromAttributed:p._title]];
            if (p._isDiscountedForOuterView) {
                p._priceOldString = [[Utility sharedManager] convertToStringStrikethrough:p._oldPriceForOuterView isCurrency:true];
            }else{
                p._priceOldString = [[NSAttributedString alloc]initWithString:@"     "];
            }
            //            p._priceNewString = [[Utility sharedManager] convertToString:p._newPriceForOuterView isCurrency:true];


            p._priceMax = p._price;
            p._priceMin = p._price;
            if (IS_NOT_NULL(pDict, @"max_var_price")) {
                p._priceMax = GET_VALUE_FLOAT(pDict, @"max_var_price");
                p._priceMax = [CurrencyHelper applyRate:p._priceMax];
            }
            if (IS_NOT_NULL(pDict, @"min_var_price")) {
                p._priceMin = GET_VALUE_FLOAT(pDict, @"min_var_price");
                p._priceMin = [CurrencyHelper applyRate:p._priceMin];
            }
            //            if (p._priceMax == p._priceMin && p._price > p._priceMin) {
            //                p._price = p._priceMin;//new hack
            //                p._isDiscountedForOuterView = [p isProductDiscounted:-1];
            //                p._newPriceForOuterView = [p getNewPrice:-1];
            //                p._oldPriceForOuterView = [p getOldPrice:-1];
            //                p._titleForOuterView = [Utility getNormalStringFromAttributed:p._title];
            //                if (p._isDiscountedForOuterView) {
            //                    p._priceOldString = [[Utility sharedManager] convertToStringStrikethrough:p._oldPriceForOuterView isCurrency:true];
            //                }else{
            //                    p._priceOldString = [[NSAttributedString alloc]initWithString:@"     "];
            //                }
            //            }

            if(![[Addons sharedManager] show_min_max_price]) {
                //RLOG(@"show_min_max_price = false");
                p._priceNewString = [[Utility sharedManager] convertToString:p._newPriceForOuterView isCurrency:true];
            }
            else {
                //RLOG(@"show_min_max_price = true");
                if (p._variations && [p._variations count] > 0) {
                    for (Variation* var in p._variations) {
                        if (p._priceMax < var._price) {
                            p._priceMax = var._price;
                        }
                    }
                    p._priceMin = p._priceMax;
                    for (Variation* var in p._variations) {
                        if (p._priceMin > var._price) {
                            p._priceMin = var._price;
                        }
                    }
                }

                if (p._priceMax == p._priceMin) {
                    p._priceNewString = [[Utility sharedManager] convertToString:p._newPriceForOuterView isCurrency:true];
                } else {
                    NSString* strMin = [[Utility sharedManager] convertToString:p._priceMin isCurrency:true];
                    NSString* strMax = [[Utility sharedManager] convertToString:p._priceMax isCurrency:true];
                    p._priceNewString = [NSString stringWithFormat:@"%@ - %@", strMin, strMax];
                }
            }

            [self parseSellerInfoForProduct:p pDict:pDict];
            [self parseAndSetProductPriceLabels:pDict product:p];
            if (pDict != nil || [pDict objectForKey:@"min_qty_rule"]) {
                [WC2X_JsonHelper parseAndSetProductQuantityRules:pDict product:p];
            }
        }
    }
    RLOG(@"<========LoadInitialData Completed");
    RLOG(@"CategoryInfo Count========>%d", (int)[[CategoryInfo getAll] count]);
    RLOG(@"ProductInfo Count========>%d", (int)[[ProductInfo getAll] count]);
}
- (void)loadCategoriesDataViaPlugin:(NSArray *)arrayObj {
    if(arrayObj == nil){
        RLOG(@"loadCategoriesDataViaPlugin: No data found");
        return;
    }
    NSDictionary* mainDict = nil;
    for (mainDict in arrayObj) {
        CategoryInfo* category = [CategoryInfo getWithId:GET_VALUE_INT(mainDict, @"id")];
        if (IS_NOT_NULL(mainDict, @"id")) {
            category._id = GET_VALUE_INT(mainDict, @"id");
        }
        if (IS_NOT_NULL(mainDict, @"name")) {
            NSString* ssss = GET_VALUE_OBJECT(mainDict, @"name");
            NSString* newStr = [ssss stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            if (newStr == nil) {
                newStr = ssss;
            }
            newStr = [Utility getStringIfFormatted:newStr];
            category._name = newStr;
            category._nameForOuterView = [Utility getNormalStringFromAttributed:category._name];
        }
        if (IS_NOT_NULL(mainDict, @"slug")) {
            category._slugOriginal = GET_VALUE_OBJECT(mainDict, @"slug");
            NSString* newStr = [GET_VALUE_OBJECT(mainDict, @"slug") stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            newStr = [Utility getStringIfFormatted:newStr];
            category._slug = newStr;
        }
        if (IS_NOT_NULL(mainDict, @"parent")) {
            category._parentId = GET_VALUE_INT(mainDict, @"parent");
        }
        if (IS_NOT_NULL(mainDict, @"description")) {
            category._description = GET_VALUE_STRING(mainDict, @"description");
        }
        if (IS_NOT_NULL(mainDict, @"display")) {
            category._display = GET_VALUE_STRING(mainDict, @"display");
        }
        if (IS_NOT_NULL(mainDict, @"img_url")) {
            if ([GET_VALUE_STRING(mainDict, @"img_url") isKindOfClass:[NSNumber class]]) {
                category._image = @"";
            }else{
                category._image = GET_VALUE_OBJECT(mainDict, @"img_url");
                //TODO IMAGE_RESIZE
                category._image = [[Utility sharedManager] getResizedImageUrl:category._image];
            }
        }

        if (IS_NOT_NULL(mainDict, @"count")) {
            category._count = GET_VALUE_INT(mainDict, @"count");
        }

        category._parent = [CategoryInfo getWithId:category._parentId];

        RLOG(@"category = %@", category);
        RLOG(@"categoryName = %@", category._name);
        RLOG(@"categoryImage = %@", category._image);
        RLOG(@"categoryId = %d", category._id);
        RLOG(@"categoryParentId = %d", category._parentId);
    }

    [CategoryInfo refineMaxChildCount];
    [CategoryInfo refineCategories];
    [CategoryInfo stepUpSingleChildrenCategories];
    [CategoryInfo autoRefreshCategoryThumbs];
    RLOG(@"<========LoadCategoryData Completed");
    RLOG(@"CategoryInfo Count========>%d", (int)[[CategoryInfo getAll] count]);
    RLOG(@"ProductInfo Count========>%d", (int)[[ProductInfo getAll] count]);
}
- (void)loadCommonDataViaPlugin:(NSDictionary *)dictionary {
    NSDictionary* metaDict = dictionary;
    CommonInfo *commonInfo = [CommonInfo sharedManager];
    {
        if (IS_NOT_NULL(metaDict, @"tz")) {
            commonInfo->_timezone = GET_VALUE_STRING(metaDict, @"tz");
        }
        if (IS_NOT_NULL(metaDict, @"c")) {
            commonInfo->_currency = GET_VALUE_STRING(metaDict, @"c");
        }
        if (IS_NOT_NULL(metaDict, @"c_f")) {
            commonInfo->_currency_format = GET_VALUE_STRING(metaDict, @"c_f");
        }
        if (IS_NOT_NULL(metaDict, @"c_p")) {
            commonInfo->_currency_position = GET_VALUE_STRING(metaDict, @"c_p");
        }
        if (IS_NOT_NULL(metaDict, @"t_s")) {
            commonInfo->_thousand_separator = GET_VALUE_STRING(metaDict, @"t_s");
        }
        if (IS_NOT_NULL(metaDict, @"d_s")) {
            commonInfo->_decimal_separator = GET_VALUE_STRING(metaDict, @"d_s");
        }
        if (IS_NOT_NULL(metaDict, @"p_d")) {
            commonInfo->_price_num_decimals = GET_VALUE_INT(metaDict, @"p_d");
        }
        //        commonInfo->_price_num_decimals = 1;
        if (IS_NOT_NULL(metaDict, @"t_i")) {
            commonInfo->_tax_included = GET_VALUE_BOOL(metaDict, @"t_i");
        }
        if (IS_NOT_NULL(metaDict, @"w_u")) {
            commonInfo->_weight_unit = GET_VALUE_STRING(metaDict, @"w_u");
        }
        if (IS_NOT_NULL(metaDict, @"d_u")) {
            commonInfo->_dimension_unit = GET_VALUE_STRING(metaDict, @"d_u");
        }
        if (IS_NOT_NULL(metaDict, @"checkout_url")) {
            DataManager* dm = [DataManager sharedManager];
            dm.checkoutUrlLinkFromPlugin = GET_VALUE_STRING(metaDict, @"checkout_url");
            dm.checkoutUrlLinkFromPlugin =[NSString stringWithFormat:@"%@?device_type=ios", dm.checkoutUrlLinkFromPlugin];
        }
        if (IS_NOT_NULL(metaDict, @"hide_out_of_stock")) {
            NSString* str = GET_VALUE_STRING(metaDict, @"hide_out_of_stock");
            if ([str isEqualToString:@"no"]) {
                commonInfo->_hideOutOfStock = false;
            }else{
                commonInfo->_hideOutOfStock = true;
            }
        }
        if (IS_NOT_NULL(metaDict, @"add_price_to_product")) {
            commonInfo->_addTaxToProductPrice = GET_VALUE_BOOL(metaDict, @"add_price_to_product");
            //                    commonInfo->_addTaxToProductPrice = false;
        }
        /*

         "tax_settings" = {
         "shipping_tax_class" = "";
         "tax_based_on" = shipping;
         "store_base_location" = {
         "country" ="FR";
         "state" = "";
         }
         };
         //here
         //        "shipping_tax_class" =

         //        "standard"    //default
         //        "atc-a"       //user created
         //        "atc-b"       //user created
         //        ""            //this empty is for shipping tax class based on cart items
         //and
         //        "tax_based_on" =
         //        "shipping"    //customer shipping address//this condition is not handled on product page. tax applied only on checkout page
         //        "billing"     //customer billing address//this condition is not handled on product page. tax applied only on checkout page
         //        "base"        //shop base address//this condition not handled on product page. tax again not applied on checkout page
         */
        if (IS_NOT_NULL(metaDict, @"tax_settings")) {
            NSDictionary* taxSettingsDict = GET_VALUE_OBJECT(metaDict, @"tax_settings");
            if ([taxSettingsDict isKindOfClass:[NSDictionary class]]) {
                if (IS_NOT_NULL(taxSettingsDict, @"add_price_to_product")) {
                    commonInfo->_addTaxToProductPrice = GET_VALUE_BOOL(taxSettingsDict, @"add_price_to_product");
                    //                    commonInfo->_addTaxToProductPrice = false;
                }
                if (IS_NOT_NULL(taxSettingsDict, @"woocommerce_prices_include_tax")) {
                    commonInfo->_woocommerce_prices_include_tax = GET_VALUE_BOOL(taxSettingsDict, @"woocommerce_prices_include_tax");
                }
                if (IS_NOT_NULL(taxSettingsDict, @"shipping_tax_class")) {
                    commonInfo->_shippingTaxClassName = GET_VALUE_STRING(taxSettingsDict, @"shipping_tax_class");
                }
                if (IS_NOT_NULL(taxSettingsDict, @"tax_based_on")) {
                    commonInfo->_calculateTaxBasedOn = GET_VALUE_STRING(taxSettingsDict, @"tax_based_on");
                    if (![commonInfo->_calculateTaxBasedOn isEqualToString:@"base"]) {
                        commonInfo->_addTaxToProductPrice = false;
                    }
                }
                if (IS_NOT_NULL(taxSettingsDict, @"store_base_location")) {
                    NSDictionary* storeBaseLocation = GET_VALUE_OBJECT(taxSettingsDict, @"store_base_location");
                    if (storeBaseLocation && [storeBaseLocation isKindOfClass:[NSDictionary class]]) {
                        if (IS_NOT_NULL(storeBaseLocation, @"country")) {
                            commonInfo->_shopBaseAddressCountryId = GET_VALUE_STRING(storeBaseLocation, @"country");
                        }
                        if (IS_NOT_NULL(storeBaseLocation, @"state")) {
                            commonInfo->_shopBaseAddressStateId = GET_VALUE_STRING(storeBaseLocation, @"state");
                        }
                    }
                }
                if (IS_NOT_NULL(taxSettingsDict, @"taxes")) {
                    NSArray* taxes = GET_VALUE_OBJECT(taxSettingsDict, @"taxes");
                    [self loadTaxesDataFromPlugin:taxes];
                }
            }
        }

        if (IS_NOT_NULL(metaDict, @"currency_meta")) {
            [[CurrencyItem currencyItemList]removeAllObjects];
            NSDictionary *currency_meta_dict = [metaDict objectForKey:@"currency_meta"];
            for (NSString* key in [currency_meta_dict allKeys]) {
                NSDictionary *currency_dict = [currency_meta_dict objectForKey:key];
                CurrencyItem *currencyItem = [[CurrencyItem alloc]init];
                if (IS_NOT_NULL(currency_dict, @"name")) {
                    currencyItem.name = GET_VALUE_STRING(currency_dict, @"name");
                }
                if (IS_NOT_NULL(currency_dict, @"symbol")) {
                    currencyItem.symbol = GET_VALUE_STRING(currency_dict, @"symbol");
                }
                if (IS_NOT_NULL(currency_dict, @"position")) {
                    currencyItem.position = GET_VALUE_STRING(currency_dict, @"position");
                }
                if (IS_NOT_NULL(currency_dict, @"flag")) {
                    currencyItem.flag = GET_VALUE_STRING(currency_dict, @"flag");
                }
                if (IS_NOT_NULL(currency_dict, @"description")) {
                    currencyItem.desc = GET_VALUE_STRING(currency_dict, @"description");
                }
                if (IS_NOT_NULL(currency_dict, @"is_etalon")) {
                    currencyItem.is_etalon = GET_VALUE_INT(currency_dict, @"is_etalon");
                }
                if (IS_NOT_NULL(currency_dict, @"hide_cents")) {
                    currencyItem.hide_cents = GET_VALUE_INT(currency_dict, @"hide_cents");
                }
                if (IS_NOT_NULL(currency_dict, @"decimals")) {
                    currencyItem.decimals = GET_VALUE_INT(currency_dict, @"decimals");
                }
                if (IS_NOT_NULL(currency_dict, @"rate")) {
                    currencyItem.rate = [CurrencyHelper parseSafeFloatPrice:GET_VALUE_STRING(currency_dict, @"rate")];
                }
                [[CurrencyItem currencyItemList]addObject:currencyItem];
            }
            [[NSUserDefaults standardUserDefaults]setObject:commonInfo->_currency forKey:@"APP_CURRENCY"];
            [[NSUserDefaults standardUserDefaults]synchronize];
        }
    }
    [[Utility sharedManager] initCurrencyPosition];
    [[Utility sharedManager] initCurrencySymbol];
}
- (void)loadTrendingDatasViaPlugin:(NSArray*)pluginDataArray originalDataArray:(NSMutableArray*)originalDataArray resizeEnable:(BOOL)resizeEnable {
    //RLOG(@"pluginDataArray = %@", pluginDataArray);
    if(pluginDataArray == nil){
        RLOG(@"loadTrendingDatasViaPlugin: No data found");
        return;
    }
    NSDictionary* pDict = nil;
    int i = -1;
    for (pDict in pluginDataArray) {
        i++;
        if (i > 100) {
            break;
        }
        ProductInfo* p = [self parseRawProductData:pDict];
        if (originalDataArray && p) {
            [originalDataArray addObject:p];
        }
    }
    if (originalDataArray) {
        RLOG(@"originalDataArray Count = %d", (int)[originalDataArray count]);
    }
}
- (ProductInfo*)parseRawProductData:(NSDictionary*)pDict {
    int productId = -1;
    if (IS_NOT_NULL(pDict, @"id")) {
        productId = GET_VALUE_INT(pDict, @"id");
    }
    CommonInfo* commonInfo = [CommonInfo sharedManager];
    if (commonInfo->_hideOutOfStock) {
        if (IS_NOT_NULL(pDict, @"stock")) {
            BOOL isProductInStock = GET_VALUE_BOOL(pDict, @"stock");
            if (isProductInStock == false) {
                return nil;
            }
        }
    }
    ProductInfo* p = [ProductInfo getProductWithId:productId];
    if (p == nil) {
        p = [[ProductInfo alloc] init];
    }
    p._isSmallRetrived = true;

    if (IS_NOT_NULL(pDict, @"title")) {
        p._title = GET_VALUE_STRING(pDict, @"title");
    }
    if (IS_NOT_NULL(pDict, @"id")) {
        p._id = GET_VALUE_INT(pDict, @"id");
    }
    if (IS_NOT_NULL(pDict, @"price")) {
        p._price = GET_VALUE_FLOAT(pDict, @"price");
    }
    if (IS_NOT_NULL(pDict, @"regular_price")) {
        p._regular_price = GET_VALUE_FLOAT(pDict, @"regular_price");
    }
    if (IS_NOT_NULL(pDict, @"sale_price")) {
        p._sale_price = GET_VALUE_FLOAT(pDict, @"sale_price");
    }

    [CurrencyHelper applyCurrencyRate:p];

    if (IS_NOT_NULL(pDict, @"taxable")) {
        p._taxable = GET_VALUE_BOOL(pDict, @"taxable");
    }
    if (IS_NOT_NULL(pDict, @"tax_status")) {
        p._tax_status = GET_VALUE_STRING(pDict, @"tax_status");
    }
    if (IS_NOT_NULL(pDict, @"tax_class")) {
        p._tax_class = GET_VALUE_STRING(pDict, @"tax_class");
    }

    [self setPriceFromTax:p];

    {
        float priceToUse = p._regular_price != 0 ? p._regular_price : p._price;
        float discountPrice = p._sale_price != 0? (priceToUse - p._sale_price) : 0;
        if (discountPrice > 0) {
            p._discount = discountPrice*100.0f/priceToUse;
        } else {
            p._discount = 0;
        }
    }
    if (IS_NOT_NULL(pDict, @"stock")) {
        p._in_stock = GET_VALUE_BOOL(pDict, @"stock");
    }
    if (IS_NOT_NULL(pDict, @"managing_stock")) {
        p._managing_stock = GET_VALUE_BOOL(pDict, @"managing_stock");
    }
    if (IS_NOT_NULL(pDict, @"stock_quantity")) {
        p._stock_quantity = GET_VALUE_INT(pDict, @"stock_quantity");
    }
    if (IS_NOT_NULL(pDict, @"type")) {
        NSString* productType = GET_VALUE_STRING(pDict, @"type");
        if ([productType isEqualToString:@"simple"]) {
            p._type = PRODUCT_TYPE_SIMPLE;
        }
        if ([productType isEqualToString:@"grouped"]) {
            p._type = PRODUCT_TYPE_GROUPED;
        }
        if ([productType isEqualToString:@"external"]) {
            p._type = PRODUCT_TYPE_EXTERNAL_OR_AFFILIATE;
        }
        if ([productType isEqualToString:@"variable"]) {
            p._type = PRODUCT_TYPE_VARIABLE;
        }
        if ([productType isEqualToString:@"variable-subscription"]) {
            p._type = PRODUCT_TYPE_VARIABLE;
        }
        if ([productType isEqualToString:@"bundle"]) {
            p._type = PRODUCT_TYPE_BUNDLE;
        }
        if ([productType isEqualToString:@"yith_bundle"]) {
            p._type = PRODUCT_TYPE_BUNDLE;
        }
        if ([productType isEqualToString:@"mix-and-match"]) {
            p._type = PRODUCT_TYPE_MIXNMATCH;
        }
        if ([productType isEqualToString:@"downloadable"]) {
            p._type = PRODUCT_TYPE_DOWNLOADABLE;
        }
    }
    if (IS_NOT_NULL(pDict, @"button_text")) {
        p.button_text = GET_VALUE_STRING(pDict, @"button_text");
    }
    if (IS_NOT_NULL(pDict, @"desc") && p._isFullRetrieved == false) {
        p._short_description = GET_VALUE_STRING(pDict, @"desc");
        p.shortDescAttribStr = nil;
    }
    if (IS_NOT_NULL(pDict, @"img")) {
        ProductImage* pImage = [[ProductImage alloc] init];
        pImage._src = GET_VALUE_STRING(pDict, @"img");
        pImage._src = [[Utility sharedManager] resizeProductImage:pImage._src];
        NSLog(@"resizeProductImage:%@", pImage._src);
        if(p._images && p._images.count == 0){
            [p._images addObject:pImage];
        }
    }    
    
    if (IS_NOT_NULL(pDict, @"url")) {
        if ([GET_VALUE_STRING(pDict, @"url") isKindOfClass:[NSNumber class]]) {
            p._product_url = @"";
        }else{
            p._product_url = GET_VALUE_STRING(pDict, @"url");
        }
    }

    if (IS_NOT_NULL(pDict, @"category_ids")) {
        NSArray* categoriesIds = GET_VALUE_STRING(pDict, @"category_ids");
        if (categoriesIds) {
            for (NSNumber* obj in categoriesIds) {
                int categoryId = [obj intValue];
                CategoryInfo* ccinfo = [CategoryInfo getWithId:categoryId];
                if ([p._categories containsObject:ccinfo] == false) {
                    [p._categories addObject:ccinfo];
                    [p addInAllParentCategory:ccinfo];
                }
            }
        }
    }

    p._isDiscountedForOuterView = [p isProductDiscounted:-1];
    p._newPriceForOuterView = [p getNewPrice:-1];
    p._oldPriceForOuterView = [p getOldPrice:-1];
    p._titleForOuterView = [Utility getNormalStringFromAttributed:p._title];
    if (p._isDiscountedForOuterView) {
        p._priceOldString = [[Utility sharedManager] convertToStringStrikethrough:p._oldPriceForOuterView isCurrency:true];
    } else {
        p._priceOldString = [[NSAttributedString alloc]initWithString:@"     "];
    }
    p._priceMax = p._price;
    p._priceMin = p._price;

    if (IS_NOT_NULL(pDict, @"max_var_price")) {
        p._priceMax = GET_VALUE_FLOAT(pDict, @"max_var_price");
        p._priceMax = [CurrencyHelper applyRate:p._priceMax];
    }
    if (IS_NOT_NULL(pDict, @"min_var_price")) {
        p._priceMin = GET_VALUE_FLOAT(pDict, @"min_var_price");
        p._priceMin = [CurrencyHelper applyRate:p._priceMin];
    }

    if(![[Addons sharedManager] show_min_max_price]) {
        p._priceNewString = [[Utility sharedManager] convertToString:p._newPriceForOuterView isCurrency:true];
    } else {
        if (p._variations && [p._variations count] > 0) {
            for (Variation* var in p._variations) {
                if (p._priceMax < var._price) {
                    p._priceMax = var._price;
                }
            }
            p._priceMin = p._priceMax;
            for (Variation* var in p._variations) {
                if (p._priceMin > var._price) {
                    p._priceMin = var._price;
                }
            }
        }


        if (p._priceMax == p._priceMin) {
            p._priceNewString = [[Utility sharedManager] convertToString:p._newPriceForOuterView isCurrency:true];
        } else {
            NSString* strMin = [[Utility sharedManager] convertToString:p._priceMin isCurrency:true];
            NSString* strMax = [[Utility sharedManager] convertToString:p._priceMax isCurrency:true];
            p._priceNewString = [NSString stringWithFormat:@"%@ - %@", strMin, strMax];
        }
    }

    [self parseSellerInfoForProduct:p pDict:pDict];

    [self parseAndSetProductPriceLabels:pDict product:p];
    if (pDict != nil || [pDict objectForKey:@"min_qty_rule"]) {
        [WC2X_JsonHelper parseAndSetProductQuantityRules:pDict product:p];
    }
    return p;
}
- (void)parseSellerInfoForProduct:(ProductInfo*)p pDict:(NSDictionary*)pDict {
    //sample
    //    "seller_info" =         {
    //        seller =             {
    //            "first_name" = "BJ Interiors";
    //            id = 127;
    //            "last_name" = "";
    //            location =                 (
    //            );
    //            "profile_url" = "";
    //        };
    //        shop =             {
    //            name = "";
    //        };
    //    };
    if (IS_NOT_NULL(pDict, @"seller_info")) {
        NSDictionary* seller_info_dict = GET_VALUE_OBJ(pDict, @"seller_info");
        if (seller_info_dict && [seller_info_dict isKindOfClass:[NSDictionary class]]) {
            if (IS_NOT_NULL(seller_info_dict, @"seller")) {
                NSDictionary* seller_dict = GET_VALUE_OBJ(seller_info_dict, @"seller");
                if (seller_dict && [seller_dict isKindOfClass:[NSDictionary class]]) {
                    NSString* sellerId = @"";
                    if (IS_NOT_NULL(seller_dict, @"id")) {
                        sellerId = GET_VALUE_STR(seller_dict, @"id");
                    }
                    SellerInfo* sInfo = [SellerInfo getSellerInfoWithId:sellerId];
                    if (sInfo == nil) {
                        sInfo = [[SellerInfo alloc] init];
                    }
                    p.sellerInfo = sInfo;
                    if ([p.sellerInfo.sellerProducts containsObject:p] == false) {
                        [p.sellerInfo.sellerProducts addObject:p];
                    }
                    if (IS_NOT_NULL(seller_dict, @"id")) {
                        sInfo.sellerId = GET_VALUE_STR(seller_dict, @"id");
                    }
                    if (IS_NOT_NULL(seller_dict, @"first_name")) {
                        sInfo.sellerFirstName = GET_VALUE_STR(seller_dict, @"first_name");
                    }
                    if (IS_NOT_NULL(seller_dict, @"last_name")) {
                        sInfo.sellerLastName = GET_VALUE_STR(seller_dict, @"last_name");
                    }
                    sInfo.sellerTitle = [NSString stringWithFormat:@"%@ %@", sInfo.sellerFirstName, sInfo.sellerLastName];
                    if (IS_NOT_NULL(seller_dict, @"location")) {
                        NSMutableArray* locationArray = GET_VALUE_OBJ(seller_dict, @"location");
                        if ([locationArray isKindOfClass:[NSArray class]]) {
                            sInfo.locations = locationArray;
                        } else {
                            RLOG(@"locationArray is not an array");
                        }
                    }
                    if (IS_NOT_NULL(seller_dict, @"profile_url")) {
                        sInfo.sellerProfileUrl = GET_VALUE_STR(seller_dict, @"profile_url");
                    }
                    if (IS_NOT_NULL(seller_dict, @"avatar")) {
                        sInfo.sellerAvatarUrl = GET_VALUE_STR(seller_dict, @"avatar");
                        if ([sInfo.sellerAvatarUrl hasPrefix:@"//"]) {
                            sInfo.sellerAvatarUrl = [sInfo.sellerAvatarUrl stringByReplacingOccurrencesOfString:@"//"
                                                                                             withString:@"https://"
                                                                                                options:0
                                                                                                  range:NSMakeRange(0, 2)];
                                               }
                       RLOG(@"sellerAvatarUrl : %@", sInfo.sellerAvatarUrl);
                    }
                }
            }
            if (IS_NOT_NULL(seller_info_dict, @"shop") && p.sellerInfo != nil) {
                NSDictionary* shop_dict = GET_VALUE_OBJ(seller_info_dict, @"shop");
                if (shop_dict && [shop_dict isKindOfClass:[NSDictionary class]]) {
                    if (IS_NOT_NULL(shop_dict, @"name")) {
                        p.sellerInfo.shopName = GET_VALUE_STR(shop_dict, @"name");
                    }
                    if (IS_NOT_NULL(shop_dict, @"shop_url")) {
                        p.sellerInfo.shopUrl = GET_VALUE_STR(shop_dict, @"shop_url");
                    }
                    if (IS_NOT_NULL(shop_dict, @"icon_url")) {
                        p.sellerInfo.shopIconUrl = GET_VALUE_STR(shop_dict, @"icon_url");
                    }
                    if (IS_NOT_NULL(shop_dict, @"banner_url")) {
                        p.sellerInfo.shopBannerUrl = GET_VALUE_STR(shop_dict, @"banner_url");
                    }
                    if (IS_NOT_NULL(shop_dict, @"address")) {
                        p.sellerInfo.shopAddress = GET_VALUE_STR(shop_dict, @"address");
                    }
                    if (IS_NOT_NULL(shop_dict, @"description")) {
                        p.sellerInfo.shopDescription = GET_VALUE_STR(shop_dict, @"description");
                    }

                }
            }
            if (IS_NOT_NULL(seller_info_dict, @"geo_location") && p.sellerInfo != nil) {
                NSDictionary* geolocation_dict = GET_VALUE_OBJ(seller_info_dict, @"geo_location");
                if (geolocation_dict && [geolocation_dict isKindOfClass:[NSDictionary class]]) {
                    if (IS_NOT_NULL(geolocation_dict, @"latitude")) {
                        NSString* latStr = GET_VALUE_STR(geolocation_dict, @"latitude");
                        if (latStr) {
                            if (![latStr isEqualToString:@""]) {
                                p.sellerInfo.shopLatitude = [latStr floatValue];
                            }
                        }
                    }
                    if (IS_NOT_NULL(geolocation_dict, @"longitude")) {
                        NSString* lngStr = GET_VALUE_STR(geolocation_dict, @"longitude");
                        if (lngStr) {
                            if (![lngStr isEqualToString:@""]) {
                                p.sellerInfo.shopLongitude = [lngStr floatValue];
                            }
                        }
                    }
                }
            }
        }
    }
}
- (void)loadCouponData:(NSDictionary *)dictionary {
    if(dictionary == nil){
        RLOG(@"loadCouponData: No data found");
        return;
    }
    if (IS_NOT_NULL(dictionary, @"coupons")) {
        [[Coupon getAllCoupons] removeAllObjects];
        NSDictionary* headerDict = [dictionary objectForKey:@"coupons"];
        NSDictionary* mainDict = nil;
        for (mainDict in headerDict) {
            Coupon* c = [[Coupon alloc] init];

            if (IS_NOT_NULL(mainDict, @"id")) {
                c._id = GET_VALUE_INT(mainDict, @"id");
            }
            if (IS_NOT_NULL(mainDict, @"usage_limit")) {
                c._usage_limit = GET_VALUE_INT(mainDict, @"usage_limit");
            }
            if (IS_NOT_NULL(mainDict, @"usage_limit_per_user")) {
                c._usage_limit_per_user = GET_VALUE_INT(mainDict, @"usage_limit_per_user");
            }
            if (IS_NOT_NULL(mainDict, @"limit_usage_to_x_items")) {
                c._limit_usage_to_x_items = GET_VALUE_INT(mainDict, @"limit_usage_to_x_items");
            }
            if (IS_NOT_NULL(mainDict, @"usage_count")) {
                c._usage_count = GET_VALUE_INT(mainDict, @"usage_count");
            }
            if (IS_NOT_NULL(mainDict, @"amount")) {
                c._amount = GET_VALUE_FLOAT(mainDict, @"amount");
            }
            if (IS_NOT_NULL(mainDict, @"minimum_amount")) {
                c._minimum_amount = GET_VALUE_FLOAT(mainDict, @"minimum_amount");
            }
            if (IS_NOT_NULL(mainDict, @"maximum_amount")) {
                c._maximum_amount = GET_VALUE_FLOAT(mainDict, @"maximum_amount");
            }
            if (IS_NOT_NULL(mainDict, @"individual_use")) {
                c._individual_use = GET_VALUE_BOOL(mainDict, @"individual_use");
            }
            if (IS_NOT_NULL(mainDict, @"exclude_sale_items")) {
                c._exclude_sale_items = GET_VALUE_BOOL(mainDict, @"exclude_sale_items");
            }
            if (IS_NOT_NULL(mainDict, @"enable_free_shipping")) {
                c._enable_free_shipping = GET_VALUE_BOOL(mainDict, @"enable_free_shipping");
            }
            if (IS_NOT_NULL(mainDict, @"description")) {
                c._description = GET_VALUE_STRING(mainDict, @"description");
            }
            if (IS_NOT_NULL(mainDict, @"code")) {
                c._code = GET_VALUE_STRING(mainDict, @"code");
            }
            if (IS_NOT_NULL(mainDict, @"type")) {
                c._type = GET_VALUE_STRING(mainDict, @"type");
            }
            if (IS_NOT_NULL(mainDict, @"created_at")) {
                c._created_at = GET_VALUE_STRING(mainDict, @"created_at");
            }
            if (IS_NOT_NULL(mainDict, @"updated_at")) {
                c._updated_at = GET_VALUE_STRING(mainDict, @"updated_at");
            }
            if (IS_NOT_NULL(mainDict, @"expiry_date")) {
                c._expiry_dateStr = GET_VALUE_STRING(mainDict, @"expiry_date");
            }
            if (IS_NOT_NULL(mainDict, @"expiry_date")) {
                NSDateFormatter* df = [[NSDateFormatter alloc]init];
                [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
                NSString* str = GET_VALUE_STRING(mainDict, @"expiry_date");
                c._expiry_date = [df dateFromString:str];
            }
            if (IS_NOT_NULL(mainDict, @"product_category_ids")) {
                c._product_category_ids = GET_VALUE_OBJECT(mainDict, @"product_category_ids");
            }
            if (IS_NOT_NULL(mainDict, @"exclude_product_category_ids")) {
                c._exclude_product_category_ids = GET_VALUE_OBJECT(mainDict, @"exclude_product_category_ids");
            }
            if (IS_NOT_NULL(mainDict, @"customer_emails")) {
                c._customer_emails = GET_VALUE_OBJECT(mainDict, @"customer_emails");
            }
            if (IS_NOT_NULL(mainDict, @"product_ids")) {
                c._product_ids = GET_VALUE_OBJECT(mainDict, @"product_ids");
            }
            if (IS_NOT_NULL(mainDict, @"exclude_product_ids")) {
                c._exclude_product_ids = GET_VALUE_OBJECT(mainDict, @"exclude_product_ids");
            }

            RLOG(@"coupon = %@", c);
        }
        int couponCount = [[Coupon getAllCoupons] count];
        RLOG(@"couponCount = %d", couponCount);
    }
}
+ (void) createWaitList:(NSDictionary*) json {
    if(json == nil){
        RLOG(@"createWaitList: No data found");
        return;
    }

    [WaitList clearAllProductIds];

    NSArray* productIds = [json objectForKey:@"pids"];
    for (NSNumber* productId in productIds) {
        [WaitList addProductId:[productId intValue]];
    }
}

+ (void) createWishList:(NSDictionary*) json {
    if(json == nil){
        RLOG(@"createWishList: No data found");
        return;
    }

    [CWishList clearAll];

    [CWishList setId:[json valueForKey:@"wishlist_id"]];

    NSArray* productsData = [json objectForKey:@"products"];
    for (NSDictionary* productData in productsData) {
        int productId = GET_VALUE_INT(productData, @"pid");
        int quantity = GET_VALUE_INT(productData, @"qty");
        [CWishList create:productId quantity:quantity];
    }
}

+ (void) parseWishListDetails:(NSDictionary*) json {
    if(json == nil){
        RLOG(@"parseWishListDetails: No data found");
        return;
    }

    [CWishList setUrl:[json valueForKey:@"wishlist_url"]];
    [CWishList setToken:[json valueForKey:@"wishlist_token"]];
}

+ (void)parseUserRewardPoints:(NSDictionary*) json {
    if(json == nil){
        RLOG(@"parseUserRewardPoints: No data found");
        return;
    }

    AppUser* appUser=[AppUser sharedManager];
    if ([AppUser isSignedIn]) {
        appUser.rewardPoints = GET_VALUE_INT(json, @"total_reward_points");
        appUser.rewardDiscount = GET_VALUE_FLOAT(json, @"total_reward_points_value");
    } else {
        appUser.rewardPoints = 0;
        appUser.rewardDiscount = 0;

    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CartLogInToggle" object:nil];
}

+ (void)parseProductRewardPoints:(NSDictionary*) json {
    if(json == nil){
        RLOG(@"parseProductRewardPoints: No data found");
        return;
    }

    NSDictionary* productData = [json valueForKey:@"prod_data"];
    int productId = GET_VALUE_INT(productData, @"prod_id");
    ProductInfo* productInfo = [ProductInfo getProductWithId:productId];
    if([productInfo hasVariations]) {
        NSArray* variationsData = [json valueForKey:@"var_data"];
        for(NSDictionary* variationData in variationsData) {
            int variationId = GET_VALUE_INT(variationData, @"var_id");
            Variation* variation = [productInfo getVariation:variationId];
            if(variation != nil) {
                variation.rewardPoints = GET_VALUE_INT(variationData, @"var_points");
            }
        }
    } else {
        productInfo.rewardPoints = GET_VALUE_INT(productData, @"prod_points");
    }
}
+ (void)parseOrderDeliveySlots:(NSDictionary*)json {
    if(json == nil){
        RLOG(@"parseOrderDeliveySlots: No data found");
        return;
    }
    NSArray* ordersData = [json valueForKey:@"data"];
    for(NSDictionary* orderData in ordersData) {
        if (IS_NOT_NULL(orderData, @"order_id")) {
            int orderId = GET_VALUE_INT(orderData, @"order_id");
            Order* order = [Order findWithOrderId:orderId];
            if(order != nil) {
                if (IS_NOT_NULL(orderData, @"date")){
                    order.deliveryDateString = GET_VALUE_STRING(orderData, @"date");
                    if (order.deliveryDateString && [order.deliveryDateString isEqualToString:@""]) {
                        order.deliveryDateString = @"N/A";
                    }
                } else {
                    order.deliveryDateString = @"N/A";
                }


                if (IS_NOT_NULL(orderData, @"time")){
                    order.deliveryTimeString = GET_VALUE_STRING(orderData, @"time");
                    if (order.deliveryTimeString && [order.deliveryTimeString isEqualToString:@""]) {
                        order.deliveryTimeString = @"N/A";
                    }
                } else {
                    order.deliveryTimeString = @"N/A";
                }
            }
        }

    }
}
+ (void)parseOrderRewardPoints:(NSDictionary*)json {
    if(json == nil){
        RLOG(@"parseOrderRewardPoints: No data found");
        return;
    }

    NSArray* ordersData = [json valueForKey:@"order_data"];
    for(NSDictionary* orderData in ordersData) {
        NSString* orderNumberStr = @"";
        NSObject* oo = GET_VALUE_OBJECT(orderData, @"order_no");
        if ([oo isKindOfClass:[NSString class]]) {
            orderNumberStr = GET_VALUE_OBJECT(orderData, @"order_no");
        } else {
            int orderNumber = GET_VALUE_INT(orderData, @"order_no");
            orderNumberStr = [NSString stringWithFormat:@"%d", orderNumber];
        }

        Order* order = [Order findWithNumberString:orderNumberStr];
        if(order != nil) {
            order.pointsEarned = GET_VALUE_INT(orderData, @"points_earned");
            order.pointsRedeemed = GET_VALUE_INT(orderData, @"points_redeemed");
        }
    }
}

+ (void)parseCartProductsRewardPoints:(NSDictionary*) json {
    if(json == nil){
        RLOG(@"parseCartProductsRewardPoints: No data found");
        return;
    }

    NSArray* productsData = [json valueForKey:@"product_data"];
    for(NSDictionary* productDataParent in productsData) {
        NSDictionary* productData = [productDataParent valueForKey:@"prod_data"];
        int productId = GET_VALUE_INT(productData, @"prod_id");;
        ProductInfo* productInfo = [ProductInfo getProductWithId:productId];
        if([productInfo hasVariations]) {
            NSArray* variationsData = [productDataParent valueForKey:@"var_data"];
            NSDictionary* variationData = [variationsData firstObject];
            int variationId = GET_VALUE_INT(variationData, @"var_id");
            Variation* variation = [productInfo getVariation:variationId];
            if(variation != nil) {
                variation.rewardPoints = GET_VALUE_INT(variationData, @"var_points");
            }
        } else {
            productInfo.rewardPoints = GET_VALUE_INT(productData, @"prod_points");
        }
    }

    NSDictionary* userData = [json valueForKey:@"user_data"];

    AppUser* appUser=[AppUser sharedManager];
    if ([AppUser isSignedIn]) {
        appUser.rewardPoints = GET_VALUE_INT(userData, @"total_reward_points");
        appUser.rewardDiscount = GET_VALUE_FLOAT(userData, @"total_reward_points_value");
    } else {
        appUser.rewardPoints = 0;
        appUser.rewardDiscount = 0;

    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CartLogInToggle" object:nil];
}

- (void)loadTaxesData:(NSDictionary *)dictionary {
    [[TM_Tax getAllTaxes] removeAllObjects];
    if(dictionary == nil){
        RLOG(@"loadTaxesData: No data found");
        return;
    }
    if (IS_NOT_NULL(dictionary, @"taxes")) {
        NSDictionary* headerDict = [dictionary objectForKey:@"taxes"];
        NSDictionary* mainDict = nil;
        for (mainDict in headerDict) {
            TM_Tax* tax = [[TM_Tax alloc] init];
            if (IS_NOT_NULL(mainDict, @"id")) {
                tax.taxId = GET_VALUE_INT(mainDict, @"id");
            }
            if (IS_NOT_NULL(mainDict, @"country")) {
                tax.country = GET_VALUE_STRING(mainDict, @"country");
            }
            if (IS_NOT_NULL(mainDict, @"state")) {
                tax.state = GET_VALUE_STRING(mainDict, @"state");
            }
            if (IS_NOT_NULL(mainDict, @"postcode")) {
                tax.postcode = GET_VALUE_STRING(mainDict, @"postcode");
                if (![tax.postcode isEqualToString:@""]) {
                    tax.postalCodes = [tax.postcode componentsSeparatedByString:@";"];
                }
            }
            if (IS_NOT_NULL(mainDict, @"city")) {
                tax.city = GET_VALUE_STRING(mainDict, @"city");
                if (![tax.city isEqualToString:@""]) {
                    tax.cities = [tax.city componentsSeparatedByString:@";"];
                }
            }
            if (IS_NOT_NULL(mainDict, @"rate")) {
                tax.rate = [GET_VALUE_STRING(mainDict, @"rate") doubleValue];
            }
            if (IS_NOT_NULL(mainDict, @"name")) {
                tax.name = GET_VALUE_STRING(mainDict, @"name");
            }
            if (IS_NOT_NULL(mainDict, @"priority")) {
                tax.priority = GET_VALUE_INT(mainDict, @"priority");
            }
            if (IS_NOT_NULL(mainDict, @"compound")) {
                tax.compound = GET_VALUE_BOOL(mainDict, @"compound");
            }
            if (IS_NOT_NULL(mainDict, @"shipping")) {
                tax.shipping = GET_VALUE_BOOL(mainDict, @"shipping");
            }
            if (IS_NOT_NULL(mainDict, @"order")) {
                tax.order = GET_VALUE_INT(mainDict, @"order");
            }
            if (IS_NOT_NULL(mainDict, @"class")) {
                tax.taxClass = GET_VALUE_STRING(mainDict, @"class");
            }
        }
        int taxesCount = (int)[[TM_Tax getAllTaxes] count];
        RLOG(@"taxesCount = %d", taxesCount);
    }
}
- (void)loadTaxesDataFromPlugin:(NSArray *)taxes {
    [[TM_Tax getAllTaxes] removeAllObjects];
    if(taxes == nil){
        RLOG(@"loadTaxesDataFromPlugin: No data found");
        return;
    }
    if (1) {
        NSArray* headerDict = taxes;
        NSDictionary* mainDict = nil;
        for (mainDict in headerDict) {
            TM_Tax* tax = [[TM_Tax alloc] init];
            if (IS_NOT_NULL(mainDict, @"id")) {
                tax.taxId = GET_VALUE_INT(mainDict, @"id");
            }
            if (IS_NOT_NULL(mainDict, @"country")) {
                tax.country = GET_VALUE_STRING(mainDict, @"country");
            }
            if (IS_NOT_NULL(mainDict, @"state")) {
                tax.state = GET_VALUE_STRING(mainDict, @"state");
            }
            if (IS_NOT_NULL(mainDict, @"postcode")) {
                tax.postcode = GET_VALUE_STRING(mainDict, @"postcode");
                if (![tax.postcode isEqualToString:@""]) {
                    tax.postalCodes = [tax.postcode componentsSeparatedByString:@";"];
                }
            }
            if (IS_NOT_NULL(mainDict, @"city")) {
                tax.city = GET_VALUE_STRING(mainDict, @"city");
                if (![tax.city isEqualToString:@""]) {
                    tax.cities = [tax.city componentsSeparatedByString:@";"];
                }
            }
            if (IS_NOT_NULL(mainDict, @"rate")) {
                tax.rate = [GET_VALUE_STRING(mainDict, @"rate") doubleValue];
            }
            if (IS_NOT_NULL(mainDict, @"name")) {
                tax.name = GET_VALUE_STRING(mainDict, @"name");
            }
            if (IS_NOT_NULL(mainDict, @"priority")) {
                tax.priority = GET_VALUE_INT(mainDict, @"priority");
            }
            if (IS_NOT_NULL(mainDict, @"compound")) {
                tax.compound = GET_VALUE_BOOL(mainDict, @"compound");
            }
            if (IS_NOT_NULL(mainDict, @"shipping")) {
                tax.shipping = GET_VALUE_BOOL(mainDict, @"shipping");
            }
            if (IS_NOT_NULL(mainDict, @"order")) {
                tax.order = GET_VALUE_INT(mainDict, @"order");
            }
            if (IS_NOT_NULL(mainDict, @"class")) {
                tax.taxClass = GET_VALUE_STRING(mainDict, @"class");
            }
        }
        int taxesCount = (int)[[TM_Tax getAllTaxes] count];
        RLOG(@"taxesCount = %d", taxesCount);
    }
}
- (void)parseJsonAndCreateCartMeta:(NSDictionary*)mainDict {
    CartMeta* cartMeta = [CartMeta sharedInstance];
    [cartMeta.getAppliedCoupons removeAllObjects];
    NSArray* coupon_discounted = GET_VALUE_OBJECT_DEFAULT(mainDict, @"coupon_discounted", [[NSMutableArray alloc] init]);
    for (NSDictionary* objDict in coupon_discounted) {
        NSString* couponTitle = GET_VALUE_STRING_DEFAULT(objDict, @"coupon", @"");
        float couponDiscount = GET_VALUE_FLOAT_DEFAULT(objDict, @"discount", 0.0f);
        AppliedCoupon* appliedCoupon = [[AppliedCoupon alloc] initWithTitle:couponTitle];
        appliedCoupon.discount_amount = couponDiscount;
        [cartMeta.getAppliedCoupons addObject:appliedCoupon];
    }
}
- (void)parseJsonAndCreateMinOrderData:(NSDictionary*)mainDict {
    MinOrderData* minOrder = [MinOrderData sharedInstance];
    Addons* addons = [Addons sharedManager];
    if (addons.check_min_order_data) {
        if (IS_NOT_NULL(mainDict, @"min_order_data")) {
            NSDictionary* dict = GET_VALUE_OBJ(mainDict, @"min_order_data");
            if (dict) {
                minOrder.minOrderAmount = GET_VALUE_FLOAT_DEFAULT(dict, @"wcj_order_minimum_amount", 0.0f);
                minOrder.minOrderMessage = GET_VALUE_STRING_DEFAULT(dict, @"wcj_order_minimum_amount_error_message", @"");
            }
        }
    }
}
- (void)parseJsonAndCreateFees:(NSDictionary*)mainDict {
    if (IS_NOT_NULL(mainDict, @"fee_data")) {
        NSArray* array = GET_VALUE_OBJ(mainDict, @"fee_data");
        if (array) {
            for (NSDictionary* dict in array) {
                FeeData* feeData = [[FeeData alloc] init];
                feeData.plugin_title = GET_VALUE_STRING_DEFAULT(dict, @"plugin_title", @"");
                feeData.label = GET_VALUE_STRING_DEFAULT(dict, @"label", @"");
                feeData.taxable = GET_VALUE_BOOL_DEFAULT(dict, @"taxable", false);
                feeData.minorder = GET_VALUE_FLOAT_DEFAULT(dict, @"minorder", 0.0f);
                feeData.cost = GET_VALUE_FLOAT_DEFAULT(dict, @"cost", 0.0f);
            }
        }
    }
}

+ (void) parseProductsBrandNames:(NSDictionary *)json {
    if(json == nil){
        RLOG(@"parseProductsBrandNames: No data found");
        return;
    }

    NSArray* brandsData = [json valueForKey:@"woo_brand"];
    for(NSDictionary* brandData in brandsData) {
        NSObject* obj = GET_VALUE_OBJ(brandData, @"data");
        if([obj isKindOfClass:[NSString class]]) {
            int productId = GET_VALUE_INT(brandData, @"pid");
            ProductInfo* product = [ProductInfo getProductWithId:productId];
            if(product != nil) {
                NSString* parseStr = (NSString*)obj;
                //working to parse brand name
                {
                    NSError *regexError = nil;
                    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<a href=.*?>(.*?)</a>" options:NSRegularExpressionCaseInsensitive error:&regexError];
                    NSString *modifiedString = [regex stringByReplacingMatchesInString:parseStr options:0 range:NSMakeRange(0, [parseStr length]) withTemplate:@"$1"];
                    RLOG(@"product.brandName: %@", modifiedString);
                    product.brandName = modifiedString;
                }
                //working to parse url
                {
                    NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
                    NSArray *matches = [linkDetector matchesInString:parseStr options:0 range:NSMakeRange(0, [parseStr length])];
                    for (NSTextCheckingResult *result in matches) {
                        NSString *url = [parseStr substringWithRange:result.range];
                        RLOG(@"product.brandUrl: %@", url);
                        product.brandUrl = url;
                    }
                }
            }
        }
    }
}

- (void)parseAndSetProductPriceLabels:(NSDictionary *)json product:(ProductInfo*) product{
    if (IS_NOT_NULL(json, @"price_labeller")) {
        @try {
            NSObject *object = [json objectForKey:@"price_labeller"];
            if ([object isKindOfClass:[NSDictionary class]]){
                json = (NSDictionary*) object;
                if ([json objectForKey:@"price_label"]) {
                    NSString* priceLabel = GET_VALUE_STRING(json, @"price_label");
                    product.priceLabel = [NSString stringWithFormat:@" %@", priceLabel];
                }
                if ([json objectForKey:@"label_position"]) {
                    NSString* labelPosition = GET_VALUE_STRING(json, @"label_position");
                    product.labelPosition = [NSString stringWithFormat:@" %@", labelPosition];
                }
            }
        } @catch (NSException *e1) {
        }
    }
}

+ (void)parseProductsPriceLabels:(NSDictionary *)json {
    if(json == nil){
        RLOG(@"parseProductsPriceLabels: No data found");
        return;
    }

    NSArray* labelsData = [json valueForKey:@"woocommerce_price_labeller"];
    for(NSDictionary* labelData in labelsData) {
        int productId = GET_VALUE_INT(labelData, @"pid");
        ProductInfo* product = [ProductInfo getProductWithId:productId];
        if(product != nil) {
            NSDictionary* data = [labelData valueForKey:@"data"];
            NSString* priceLabel = GET_VALUE_STR(data, @"price_label");
            product.priceLabel = [NSString stringWithFormat:@" %@", priceLabel];

        }

    }
}

+ (void)parseAndSetProductQuantityRules:(NSDictionary *)json product:(ProductInfo*) product{
    QuantityRule* quantityRule = [[QuantityRule alloc] init];
    NSCharacterSet * set = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
    if (IS_NOT_NULL(json, @"override_rule")) {
        quantityRule.orderrideRule = [GET_VALUE_STRING(json, @"override_rule") isEqualToString:@"on"] ? true : false;
    }

    if (IS_NOT_NULL(json, @"step")) {
        if ([[json objectForKey:@"step"] rangeOfCharacterFromSet:set].location != NSNotFound) {
            quantityRule.stepValue = GET_VALUE_INT(json, @"step");
            //            RLOG(@"quantity rule step before %@",json)
            //            quantityRule.stepValue =  [self safeIntWithCeil:data stringKey:@"step" value:1];
            //            RLOG(@"quantity rule step before %@",json)

        }
    }
    if (IS_NOT_NULL(json, @"min_value")) {
        if ([[json objectForKey:@"min_value"] rangeOfCharacterFromSet:set].location != NSNotFound) {
            quantityRule.minQuantity = GET_VALUE_INT(json, @"min_value");
        }
    }
    if (IS_NOT_NULL(json, @"max_value")) {
        if ([[json objectForKey:@"max_value"] rangeOfCharacterFromSet:set].location != NSNotFound) {
            quantityRule.maxQuantity = GET_VALUE_INT(json, @"max_value");

        }
    }
    if (IS_NOT_NULL(json, @"min_oss")) {
        if ([[json objectForKey:@"min_oss"] rangeOfCharacterFromSet:set].location != NSNotFound) {
            quantityRule.minOutOfStock = GET_VALUE_INT(json, @"min_oss");
        }
    }
    if (IS_NOT_NULL(json, @"max_oss")) {
        if ([[json objectForKey:@"max_oss"] rangeOfCharacterFromSet:set].location != NSNotFound) {
            quantityRule.maxOutOfStock = GET_VALUE_INT(json, @"max_oss");
        }
    }
    product.quantityRule = quantityRule;
}

+ (void)parseProductsQuantityRules:(NSDictionary*) json {
    if(json == nil){
        RLOG(@"parseProductsQuantityRules: No data found");
        return;
    }
    NSMutableArray *quantityRuleArray = [json valueForKey:@"woocommerce_incremental_product_quantities"];
    if (quantityRuleArray != nil) {
        for(NSDictionary* quantityRuleJson in quantityRuleArray) {
            int productId = GET_VALUE_INT(quantityRuleJson, @"pid");
            ProductInfo* product = [ProductInfo getProductWithId:productId];
            if(product != nil) {
                NSDictionary* data = [quantityRuleJson valueForKey:@"data"];
                [self parseAndSetProductQuantityRules:data product:product];
            }
        }
    }
}

+ (int)safeIntWithCeil:(NSDictionary*)json stringKey:(NSString*)key value:(int)defaultValue{
    if(![json objectForKey:key]){
        return defaultValue;
    }
    @try {
        NSObject *object = [json objectForKey:key];
        if ([object isKindOfClass:[NSNumber class]]) {
            return (int) ceil([(NSNumber*) object doubleValue]);
        } else if ([object isKindOfClass:[NSString class]]) {
            return (int)ceil([(NSString*) object doubleValue]);
        }
    } @catch (NSException *e) {

    }
    return defaultValue;
}

+ (void)parsePickupLocations:(NSArray*)pickupLocations {
    if(pickupLocations == nil){
        RLOG(@"parsePickupLocations: No data found");
        return;
    }
    //[{"country":"US","cost":"10","id":"0","note":"","company":"test","address_1":"teyghdgsjd1","address_2":"test","city":"tampa","state":"FL","postcode":"33613","phone":""},{"country":"US","cost":"","id":"1","note":"","company":"","address_1":"","address_2":"","city":"","state":"AR","postcode":"","phone":""}]
    [TM_PickupLocation clearAllPickupLocations];
    for (NSDictionary* pickupLoc in pickupLocations) {
        if (pickupLoc && [pickupLoc isKindOfClass:[NSDictionary class]]) {
            TM_PickupLocation * pckLoc = [[TM_PickupLocation alloc] init];
            if (IS_NOT_NULL(pickupLoc, @"country")) {
                pckLoc.country = [NSString stringWithFormat:@"%@", GET_VALUE_STR(pickupLoc, @"country")];
            }
            if (IS_NOT_NULL(pickupLoc, @"cost")) {
                pckLoc.cost = [NSString stringWithFormat:@"%@", GET_VALUE_STR(pickupLoc, @"cost")];
            }
            if (IS_NOT_NULL(pickupLoc, @"id")) {
                pckLoc.pickupId = [NSString stringWithFormat:@"%@", GET_VALUE_STR(pickupLoc, @"id")];
            }
            if (IS_NOT_NULL(pickupLoc, @"note")) {
                pckLoc.note = [NSString stringWithFormat:@"%@", GET_VALUE_STR(pickupLoc, @"note")];
            }
            if (IS_NOT_NULL(pickupLoc, @"company")) {
                pckLoc.company = [NSString stringWithFormat:@"%@", GET_VALUE_STR(pickupLoc, @"company")];
            }
            if (IS_NOT_NULL(pickupLoc, @"address_1")) {
                pckLoc.address_1 = [NSString stringWithFormat:@"%@", GET_VALUE_STR(pickupLoc, @"address_1")];
            }
            if (IS_NOT_NULL(pickupLoc, @"address_2")) {
                pckLoc.address_2 = [NSString stringWithFormat:@"%@", GET_VALUE_STR(pickupLoc, @"address_2")];
            }
            if (IS_NOT_NULL(pickupLoc, @"city")) {
                pckLoc.city = [NSString stringWithFormat:@"%@", GET_VALUE_STR(pickupLoc, @"city")];
            }
            if (IS_NOT_NULL(pickupLoc, @"state")) {
                pckLoc.state = [NSString stringWithFormat:@"%@", GET_VALUE_STR(pickupLoc, @"state")];
            }
            if (IS_NOT_NULL(pickupLoc, @"postcode")) {
                pckLoc.postcode = [NSString stringWithFormat:@"%@", GET_VALUE_STR(pickupLoc, @"postcode")];
            }
            if (IS_NOT_NULL(pickupLoc, @"phone")) {
                pckLoc.phone = [NSString stringWithFormat:@"%@", GET_VALUE_STR(pickupLoc, @"phone")];
            }
        }
    }

}
+ (void)parseProductsPincodeSettings:(NSDictionary*) json {
    if(json == nil){
        RLOG(@"parseProductsPincodeSettings: No data found");
        return;
    }

    NSDictionary* pincodeSettingJson = [json valueForKey:@"pincode_settings"];

    PincodeSetting* pincodeSetting = [PincodeSetting getInstance];
    pincodeSetting.enableOnProductPage = GET_VALUE_BOOL(pincodeSettingJson, @"enable_on_productpage");
    pincodeSetting.zipTitle = GET_VALUE_STR(pincodeSettingJson, @"zip_title");
    pincodeSetting.zipButtonText = GET_VALUE_STR(pincodeSettingJson, @"zip_buttontext");
    pincodeSetting.zipNotFoundMessage = GET_VALUE_STR(pincodeSettingJson, @"zip_notfound_msg");

    [pincodeSetting clearZipSettings];

    for(NSDictionary* zipSettingJson in [pincodeSettingJson valueForKey:@"zip_settings"]) {
        ZipSetting* zipSetting = [[ZipSetting alloc] init];
        zipSetting.pincode = GET_VALUE_STR(zipSettingJson, @"pincode");
        zipSetting.message = GET_VALUE_STR(zipSettingJson, @"available_msg");
        [pincodeSetting addZipSetting:zipSetting];
    }
    pincodeSetting.fetched = YES;
}

- (void)parseProductExtraData:(ProductInfo*)product dict:(id)dict {
    if (dict) {
        if (product._type == PRODUCT_TYPE_MIXNMATCH) {
            TM_MixMatch* mixMatch = [[TM_MixMatch alloc] init];
            if (IS_NOT_NULL(dict, @"per_product_pricing")) {
                mixMatch.per_product_pricing = GET_VALUE_BOOL(dict, @"per_product_pricing");
            }
            if (IS_NOT_NULL(dict, @"per_product_shipping")) {
                mixMatch.per_product_shipping = GET_VALUE_BOOL(dict, @"per_product_shipping");
            }
            if (IS_NOT_NULL(dict, @"is_synced")) {
                mixMatch.is_synced = GET_VALUE_BOOL(dict, @"is_synced");
            }
            if (IS_NOT_NULL(dict, @"min_price")) {
                mixMatch.min_price = GET_VALUE_FLOAT(dict, @"min_price");
            }
            if (IS_NOT_NULL(dict, @"max_price")) {
                mixMatch.max_price = GET_VALUE_FLOAT(dict, @"max_price");
            }
            if (IS_NOT_NULL(dict, @"base_price")) {
                mixMatch.base_price = GET_VALUE_FLOAT(dict, @"base_price");
            }
            if (IS_NOT_NULL(dict, @"base_regular_price")) {
                mixMatch.base_regular_price = GET_VALUE_FLOAT(dict, @"base_regular_price");
            }
            if (IS_NOT_NULL(dict, @"base_sale_price")) {
                mixMatch.base_sale_price = GET_VALUE_FLOAT(dict, @"base_sale_price");
            }
            if (IS_NOT_NULL(dict, @"container_size")) {
                mixMatch.container_size = GET_VALUE_FLOAT(dict, @"container_size");
            }
            if (IS_NOT_NULL(dict, @"product_info")) {
                NSArray* productArray = GET_VALUE_OBJECT(dict, @"product_info");
                NSMutableArray* array = [[NSMutableArray alloc] init];
                [self loadTrendingDatasViaPlugin:productArray originalDataArray:array resizeEnable:false];
                for (ProductInfo* p in array) {
                    [mixMatch addMatchingItems:p];
                }
            }
            product.mMixMatch = mixMatch;
        }
        else if (product._type == PRODUCT_TYPE_BUNDLE) {
            NSArray* ext_data = dict;
            product.mBundles = [[NSMutableArray alloc] init];
            for (NSDictionary* bundleJson in ext_data) {
                TM_Bundle* bundle = [[TM_Bundle alloc] init];
                if (IS_NOT_NULL(bundleJson, @"hide_thumbnail")) {
                    bundle.hide_thumbnail = GET_VALUE_BOOL(bundleJson, @"hide_thumbnail");
                }
                if (IS_NOT_NULL(bundleJson, @"override_title")) {
                    bundle.override_title = GET_VALUE_BOOL(bundleJson, @"override_title");
                }
                if (IS_NOT_NULL(bundleJson, @"override_description")) {
                    bundle.override_description = GET_VALUE_BOOL(bundleJson, @"override_description");
                }
                if (IS_NOT_NULL(bundleJson, @"optional")) {
                    bundle.optional = GET_VALUE_BOOL(bundleJson, @"optional");
                }
                if (IS_NOT_NULL(bundleJson, @"visibility")) {
                    bundle.visibility = GET_VALUE_BOOL(bundleJson, @"visibility");
                }
                if (IS_NOT_NULL(bundleJson, @"bundle_quantity")) {
                    bundle.bundle_quantity = GET_VALUE_INT(bundleJson, @"bundle_quantity");
                }
                if (IS_NOT_NULL(bundleJson, @"bundle_discount")) {
                    bundle.bundle_discount = GET_VALUE_FLOAT(bundleJson, @"bundle_discount");
                }
                if (IS_NOT_NULL(bundleJson, @"product_info")) {
                    NSDictionary* pDict = GET_VALUE_OBJECT(bundleJson, @"product_info");
                    ProductInfo* p = [self parseRawProductData:pDict];
                    bundle.product = p;
                    bundle.productId = p._id;
                }
                [product.mBundles addObject:bundle];
            }
        }
    }
}
- (float)getRolePriceDifference:(float)price {
    float difference = 0.0f;
    AppUser* appUser = [AppUser sharedManager];
    if ([AppUser isSignedIn] && appUser.urp > 0) {
        switch (appUser.urp_formula_type) {
            case URP_FORMULA_TYPE_PERCENTAGE:
            {
                difference = price * appUser.urp / 100.0f;

            }break;
            case URP_FORMULA_TYPE_AMOUNT:
            {
                difference = appUser.urp;
            }break;
            default:
                break;
        }

        switch (appUser.urp_type) {
            case URP_TYPE_DISCOUNT:
                difference *= -1;
                break;
            case URP_TYPE_MARKUP:
                difference *= +1;
                break;
            default:
                break;
        }
    }
    return difference;
}
- (void)setRolePrice:(id)obj {
    ProductInfo* pInfo = nil;
    Variation* vInfo = nil;
    if ([obj isKindOfClass:[ProductInfo class]]) {
        pInfo = (ProductInfo*)obj;
        pInfo._price += [self getRolePriceDifference:pInfo._price];
        pInfo._regular_price += [self getRolePriceDifference:pInfo._regular_price];
        pInfo._sale_price += [self getRolePriceDifference:pInfo._sale_price];
    }
    if ([obj isKindOfClass:[Variation class]]) {
        vInfo = (Variation*)obj;
        vInfo._price += [self getRolePriceDifference:vInfo._price];
        vInfo._regular_price += [self getRolePriceDifference:vInfo._regular_price];
        vInfo._sale_price += [self getRolePriceDifference:vInfo._sale_price];
    }
}
- (void)setPriceFromTax:(id)obj {
#if ENABLE_USER_ROLE
    [self setRolePrice:obj];
#endif
    ProductInfo* pInfo = nil;
    Variation* vInfo = nil;
    if ([obj isKindOfClass:[ProductInfo class]]) {
        pInfo = (ProductInfo*)obj;
        pInfo._priceOriginal = pInfo._price;
        pInfo._regular_priceOriginal = pInfo._regular_price;
        pInfo._sale_priceOriginal = pInfo._sale_price;
    }
    if ([obj isKindOfClass:[Variation class]]) {
        vInfo = (Variation*)obj;
        vInfo._priceOriginal = vInfo._price;
        vInfo._regular_priceOriginal = vInfo._regular_price;
        vInfo._sale_priceOriginal = vInfo._sale_price;
    }
    CommonInfo* commonInfo = [CommonInfo sharedManager];
    BOOL pricesIncludeTax = false;
    //    pricesIncludeTax = commonInfo->_woocommerce_prices_include_tax;
    //    if (pricesIncludeTax) {
    //        commonInfo->_addTaxToProductPrice = true;
    //    }
    BOOL addTaxToProductPrice = commonInfo->_addTaxToProductPrice;



    if (addTaxToProductPrice == true && pricesIncludeTax == false) {
        if (pInfo && pInfo._taxable) {
            pInfo._price += [TM_TaxApplied calculateTaxProduct:pInfo._price productTaxClass:pInfo._tax_class isProductTaxable:pInfo._taxable isShippingNecessary:false];
            pInfo._regular_price += [TM_TaxApplied calculateTaxProduct:pInfo._regular_price productTaxClass:pInfo._tax_class isProductTaxable:pInfo._taxable isShippingNecessary:false];
            pInfo._sale_price += [TM_TaxApplied calculateTaxProduct:pInfo._sale_price productTaxClass:pInfo._tax_class isProductTaxable:pInfo._taxable isShippingNecessary:false];
        }
        if (vInfo && vInfo._taxable) {
            vInfo._price += [TM_TaxApplied calculateTaxProduct:vInfo._price productTaxClass:vInfo._tax_class isProductTaxable:vInfo._taxable isShippingNecessary:false];
            vInfo._regular_price += [TM_TaxApplied calculateTaxProduct:vInfo._regular_price productTaxClass:vInfo._tax_class isProductTaxable:vInfo._taxable isShippingNecessary:false];
            vInfo._sale_price += [TM_TaxApplied calculateTaxProduct:vInfo._sale_price productTaxClass:vInfo._tax_class isProductTaxable:vInfo._taxable isShippingNecessary:false];
        }
    }
    //    else if(addTaxToProductPrice == true && pricesIncludeTax == true) {
    //        if (pInfo && pInfo._taxable) {
    //            pInfo._priceOriginal += [TM_TaxApplied calculateTaxProductOriginal:pInfo._price productTaxClass:pInfo._tax_class isProductTaxable:pInfo._taxable isShippingNecessary:false];
    //            pInfo._regular_priceOriginal += [TM_TaxApplied calculateTaxProductOriginal:pInfo._regular_price productTaxClass:pInfo._tax_class isProductTaxable:pInfo._taxable isShippingNecessary:false];
    //            pInfo._sale_priceOriginal += [TM_TaxApplied calculateTaxProductOriginal:pInfo._sale_price productTaxClass:pInfo._tax_class isProductTaxable:pInfo._taxable isShippingNecessary:false];
    //        }
    //        if (vInfo && vInfo._taxable) {
    //            vInfo._priceOriginal += [TM_TaxApplied calculateTaxProductOriginal:vInfo._price productTaxClass:vInfo._tax_class isProductTaxable:vInfo._taxable isShippingNecessary:false];
    //            vInfo._regular_priceOriginal += [TM_TaxApplied calculateTaxProductOriginal:vInfo._regular_price productTaxClass:vInfo._tax_class isProductTaxable:vInfo._taxable isShippingNecessary:false];
    //            vInfo._sale_priceOriginal += [TM_TaxApplied calculateTaxProductOriginal:vInfo._sale_price productTaxClass:vInfo._tax_class isProductTaxable:vInfo._taxable isShippingNecessary:false];
    //        }
    //    }
}

+ (NSMutableArray*)parseDeliverySlotDataType2:(NSDictionary*)jsonDict {
    NSMutableArray* arrayListDateTimeSlot = [DateTimeSlot getAllDateTimeSlots];
    [arrayListDateTimeSlot removeAllObjects];
    [DateTimeSlot setShippingDenpendent:true];
    if (jsonDict && [jsonDict isKindOfClass:[NSDictionary class]]) {
        for (NSString* shippingMethodId in jsonDict.allKeys) {
            NSDictionary* jsonObject = GET_VALUE_OBJECT(jsonDict, shippingMethodId);
            if (jsonObject && [jsonObject isKindOfClass:[NSDictionary class]]) {
                for (NSString* key in jsonObject.allKeys) {
                    NSString* dateSlot = key;
                    NSArray* timeJsonArray = GET_VALUE_OBJECT(jsonObject, dateSlot);
                    NSMutableArray* arrayListTimeSlot = [[NSMutableArray alloc] init];
                    if (timeJsonArray) {
                        for (int j = 0; j < [timeJsonArray count]; j++) {
                            NSDictionary* jsonTimeObject = [timeJsonArray objectAtIndex:j];
                            TimeSlot* timeSlot = [[TimeSlot alloc] init];
                            if (IS_NOT_NULL(jsonTimeObject, @"id")) {
                                timeSlot.slotId = GET_VALUE_STRING(jsonTimeObject, @"id");
                            }
                            if (IS_NOT_NULL(jsonTimeObject, @"cost")) {
                                timeSlot.slotCost = GET_VALUE_STRING(jsonTimeObject, @"cost");
                            }
                            if (IS_NOT_NULL(jsonTimeObject, @"title")) {
                                timeSlot.slotTitle = GET_VALUE_STRING(jsonTimeObject, @"title");
                            }
                            [arrayListTimeSlot addObject:timeSlot];
                        }
                    }
                    DateTimeSlot* dateTimeSlot = [[DateTimeSlot alloc] init];
                    [dateTimeSlot setDateSlot:dateSlot];
                    [dateTimeSlot setTimeSlot:arrayListTimeSlot];
                    [dateTimeSlot setShippingMethodId:shippingMethodId];
                    [arrayListDateTimeSlot addObject:dateTimeSlot];
                }
            }
        }
    }
    return arrayListDateTimeSlot;
}
+ (NSMutableArray*)parseDeliverySlotDataType1:(NSArray*)jsonArray {
    NSMutableArray* arrayListDateTimeSlot = [DateTimeSlot getAllDateTimeSlots];
    [arrayListDateTimeSlot removeAllObjects];
    [DateTimeSlot setShippingDenpendent:false];
    for (int i = 0; i < [jsonArray count]; i++) {
        NSMutableArray* arrayListTimeSlot = [[NSMutableArray alloc] init];//Array of TimeSlot
        NSDictionary* jsonObject = [jsonArray objectAtIndex:i];
        NSString* dateSlot = @"";
        if (IS_NOT_NULL(jsonObject, @"dateSlot")) {
            dateSlot = GET_VALUE_STRING(jsonObject, @"dateSlot");
        }
        NSArray* timeJsonArray = nil;
        if (IS_NOT_NULL(jsonObject, @"timeSlot")) {
            timeJsonArray = GET_VALUE_OBJECT(jsonObject, @"timeSlot");
        }
        if (timeJsonArray) {
            for (int j = 0; j < [timeJsonArray count]; j++) {
                NSDictionary* jsonTimeObject = [timeJsonArray objectAtIndex:j];
                TimeSlot* timeSlot = [[TimeSlot alloc] init];
                if (IS_NOT_NULL(jsonTimeObject, @"id")) {
                    timeSlot.slotId = GET_VALUE_STRING(jsonTimeObject, @"id");
                }
                if (IS_NOT_NULL(jsonTimeObject, @"cost")) {
                    timeSlot.slotCost = GET_VALUE_STRING(jsonTimeObject, @"cost");
                }
                if (IS_NOT_NULL(jsonTimeObject, @"title")) {
                    timeSlot.slotTitle = GET_VALUE_STRING(jsonTimeObject, @"title");
                }
                [arrayListTimeSlot addObject:timeSlot];
            }
        }
        DateTimeSlot* dateTimeSlot = [[DateTimeSlot alloc] init];
        [dateTimeSlot setDateSlot:dateSlot];
        [dateTimeSlot setTimeSlot:arrayListTimeSlot];
        [arrayListDateTimeSlot addObject:dateTimeSlot];
    }
    return arrayListDateTimeSlot;
}
+ (NSMutableArray*)parsePickUpTimeSlotData:(NSDictionary*)jsonObject keysArray:(NSMutableArray*)keysArray valuesArray:(NSMutableArray*)valuesArray{
    NSMutableArray* timeSlots = [TimeSlot getAllTimeSlots];
    [timeSlots removeAllObjects];
    int i = 0;
    for (NSString* key in keysArray) {
        NSString* value = [valuesArray objectAtIndex:i];// GET_VALUE_OBJECT(jsonObject, key);
        TimeSlot* timeSlot = [[TimeSlot alloc] init];
        timeSlot.slotId = key;
        timeSlot.slotTitle = value;
        [timeSlots addObject:timeSlot];
        i++;
    }
    return timeSlots;
}
- (TM_ProductFilter*)parseFilterPrices:(NSDictionary*) json{
    if(json == nil) {
        RLOG(@"parseFilterPrices: No data found");
        return nil;
    }
    int c_id = -1;
    if (IS_NOT_NULL(json, @"c_id")) {
        c_id = GET_VALUE_INT(json, @"c_id");
    }
    TM_ProductFilter *filter = [TM_ProductFilter getWithCategoryId:c_id];
    if (json) {
        if (IS_NOT_NULL(json, @"max_limit")) {
            filter.maxPrice = GET_VALUE_FLOAT(json, @"max_limit");
        }
        if (IS_NOT_NULL(json, @"min_limit")) {
            filter.minPrice = GET_VALUE_FLOAT(json, @"min_limit");
        }
    }

    return filter;
}

- (void)parseJsonAndCreateFilterPrices:(NSDictionary *)json{
    if(json == nil){
        RLOG(@"parseJsonAndCreateFilterPrices: No data found");
        return;
    }
    for (NSDictionary *priceRang in [json valueForKey:@"cat_price_range"]) {
        RLOG(@"price Rang =%@",priceRang);

        TM_ProductFilter *filter = [TM_ProductFilter getWithCategoryId:[[priceRang valueForKey:@"c_id"] floatValue]];
        filter.maxPrice = [[priceRang valueForKey:@"max_limit"] floatValue];
        filter.minPrice = [[priceRang valueForKey:@"min_limit"] floatValue];
    }
}
- (TM_ProductFilter*)parseFilterAttributes:(NSDictionary *)json{
    if(json == nil) {
        RLOG(@"parseProductsPincodeSettings: No data found");
        return nil;
    }
    RLOG(@"parseJsonAndCreateFilterAttributes  %@",json);
    int c_id = -1;
    if (IS_NOT_NULL(json, @"c_id")) {
        c_id = GET_VALUE_INT(json, @"c_id");
    }
    TM_ProductFilter *filter = [TM_ProductFilter getWithCategoryId:c_id];
    NSMutableArray *attribute = nil;
    if (IS_NOT_NULL(json, @"attribute")) {
        attribute = GET_VALUE_OBJECT(json, @"attribute");
    }
    if (attribute) {
        for (NSDictionary* tempDict in attribute) {
            NSArray* attribute_var_data = nil;
            NSDictionary* attribute_data = nil;
            if (IS_NOT_NULL(tempDict, @"attribute_var_data")) {
                attribute_var_data = GET_VALUE_OBJECT(tempDict, @"attribute_var_data");
            }
            if (IS_NOT_NULL(tempDict, @"attribute_data")) {
                attribute_data = GET_VALUE_OBJECT(tempDict, @"attribute_data");
            }
            TM_FilterAttribute* categoryAttribute = [[TM_FilterAttribute alloc] init];
            if (attribute_data) {
                if (IS_NOT_NULL(attribute_data, @"title")) {
                    categoryAttribute.title = GET_VALUE_OBJECT(attribute_data, @"title");
                }
                if (IS_NOT_NULL(attribute_data, @"attribute")) {
                    categoryAttribute.attribute = GET_VALUE_OBJECT(attribute_data, @"attribute");
                }
                if (IS_NOT_NULL(attribute_data, @"display_type")) {
                    categoryAttribute.display_type = GET_VALUE_OBJECT(attribute_data, @"display_type");
                }
                if (IS_NOT_NULL(attribute_data, @"query_type")) {
                    categoryAttribute.query_type = GET_VALUE_OBJECT(attribute_data, @"query_type");
                }
            }
            if (attribute_var_data) {
                for (NSDictionary* dict2 in attribute_var_data) {
                    if (dict2) {
                        TM_FilterAttributeOption* option = [[TM_FilterAttributeOption alloc] init];
                        if (IS_NOT_NULL(dict2, @"name")) {
                            option.name = GET_VALUE_OBJECT(dict2, @"name");
                        }
                        if (IS_NOT_NULL(dict2, @"taxonomy")) {
                            option.taxo = GET_VALUE_OBJECT(dict2, @"taxonomy");
                        }
                        if (IS_NOT_NULL(dict2, @"slug")) {
                            option.slug = GET_VALUE_OBJECT(dict2, @"slug");
                        }
                        if (IS_NOT_NULL(dict2, @"term_id")) {
                            option.term_id = GET_VALUE_OBJECT(dict2, @"term_id");
                        }
                        [[categoryAttribute getXYZOptions] addObject:option];
                    }

                }
            }
            [categoryAttribute sortOptions];
            [filter addAttribute:categoryAttribute];
        }
    }
    return filter;
}
- (void)parse_pddData:(NSDictionary*)json productId:(int)productId {
    ProductInfo* product = [ProductInfo getProductWithId:productId];
    TM_PRDD* prdd = product.prdd;
    if (prdd == nil) {
        prdd = [[TM_PRDD alloc] init];
        product.prdd = prdd;
    }
    if (IS_NOT_NULL(json, @"prdd_enable_date")) {
        prdd.prdd_enable_date = [GET_VALUE_OBJECT(json, @"prdd_enable_date") isEqualToString:@"on"] ? true : false;
    }
    if (IS_NOT_NULL(json, @"prdd_enable_time")) {
        prdd.prdd_enable_time = [GET_VALUE_OBJECT(json, @"prdd_enable_time") isEqualToString:@"on"] ? true : false;
    }
    if (IS_NOT_NULL(json, @"prdd_recurring_chk")) {
        prdd.prdd_recurring_chk = [GET_VALUE_OBJECT(json, @"prdd_recurring_chk") isEqualToString:@"on"] ? true : false;
    }
    if (prdd.prdd_recurring_chk) {
        NSDictionary* prdd_time_settings_dict = nil;
        if (IS_NOT_NULL(json, @"prdd_time_settings")) {
            prdd_time_settings_dict = GET_VALUE_OBJECT(json, @"prdd_time_settings");
        }
        int const weekDayCount = 7;
        if (IS_NOT_NULL(json, @"prdd_recurring")) {
            NSDictionary* prdd_recurring_dict = GET_VALUE_OBJECT(json, @"prdd_recurring");
            for (int i = 0; i < weekDayCount; i++) {
                TM_PRDD_Day* prddDay = [[TM_PRDD_Day alloc] init];
                prddDay.prdd_day = i;
                [prdd.prdd_days addObject:prddDay];
                NSString* weekDayString = [NSString stringWithFormat:@"prdd_weekday_%d", i];
                if (IS_NOT_NULL(prdd_recurring_dict, weekDayString)) {
                    prddDay.prdd_day_enable = [GET_VALUE_OBJECT(prdd_recurring_dict, weekDayString) isEqualToString:@"on"] ? true : false;
                }
                if (prddDay.prdd_day_enable && prdd_time_settings_dict) {
                    if (IS_NOT_NULL(prdd_time_settings_dict, weekDayString)) {
                        NSDictionary* prdd_weekday_dict = GET_VALUE_OBJECT(prdd_time_settings_dict, weekDayString);
                        NSArray* prdd_weekday_dict_keys = [prdd_weekday_dict allKeys];
                        for (NSString* key in prdd_weekday_dict_keys) {

                            NSDictionary* prdd_time_dict = GET_VALUE_OBJECT(prdd_weekday_dict, key);
                            TM_PRDD_Time * prddTime = [[TM_PRDD_Time alloc] init];
                            [prddDay.prdd_times addObject:prddTime];
                            if (IS_NOT_NULL(prdd_time_dict, @"slot_price")) {
                                prddTime.slot_price = [GET_VALUE_OBJECT(prdd_time_dict, @"slot_price") floatValue];
                            }
                            if (IS_NOT_NULL(prdd_time_dict, @"lockout_slot")) {
                                prddTime.slot_lockout = [GET_VALUE_OBJECT(prdd_time_dict, @"lockout_slot") intValue];
                            }
                            NSString* startTimeH = @"";
                            NSString* startTimeM = @"";
                            NSString* endTimeH = @"";
                            NSString* endTimeM = @"";
                            if (IS_NOT_NULL(prdd_time_dict, @"from_slot_hrs")) {
                                startTimeH = GET_VALUE_OBJECT(prdd_time_dict, @"from_slot_hrs");
                            }
                            if (IS_NOT_NULL(prdd_time_dict, @"from_slot_min")) {
                                startTimeM = GET_VALUE_OBJECT(prdd_time_dict, @"from_slot_min");
                            }
                            if (IS_NOT_NULL(prdd_time_dict, @"to_slot_hrs")) {
                                endTimeH = GET_VALUE_OBJECT(prdd_time_dict, @"to_slot_hrs");
                            }
                            if (IS_NOT_NULL(prdd_time_dict, @"to_slot_min")) {
                                endTimeM = GET_VALUE_OBJECT(prdd_time_dict, @"to_slot_min");
                            }
                            prddTime.slot_title = [NSString stringWithFormat:@"%@:%@-%@:%@", startTimeH, startTimeM, endTimeH, endTimeM];
                        }
                    }
                }
            }
        }
    }
}
- (void)parse_ContactForm3Config:(NSDictionary*)json {
    if (json != nil &&  [json isKindOfClass:[NSDictionary class]]) {
        ContactForm3Config* config = [ContactForm3Config getInstance];
        [config resetContactForm3Objects];
        config.isDataFetched = true;
        if (IS_NOT_NULL(json, @"form_name")) {
            config.form_title = GET_VALUE_OBJ(json, @"form_name");
        }
        if (IS_NOT_NULL(json, @"submit_mess")) {
            config.submit_button_title = GET_VALUE_OBJ(json, @"submit_mess");
        }
        if (IS_NOT_NULL(json, @"input")) {
            NSArray* array = GET_VALUE_OBJ(json, @"input");
            for (NSDictionary* dict in array) {
                ContactForm3* cObj = [[ContactForm3 alloc] init];
                if (IS_NOT_NULL(dict, @"type")) {
                    cObj.type = GET_VALUE_OBJ(dict, @"type");
                }
                if (IS_NOT_NULL(dict, @"shortcode")) {
                    cObj.shortcode = GET_VALUE_OBJ(dict, @"shortcode");
                }
                if (IS_NOT_NULL(dict, @"label")) {
                    cObj.label = GET_VALUE_OBJ(dict, @"label");
                }
                if (IS_NOT_NULL(dict, @"options")) {
                    NSArray* array_options = GET_VALUE_OBJ(dict, @"options");
                    for (NSString* str in array_options) {
                        [cObj.options addObject:str];
                    }
                }
                [config addContactForm3Object:cObj];
            }
        }
    }
}
- (void)parse_ReservationFormConfig:(NSDictionary*)json {
    if (json != nil &&  [json isKindOfClass:[NSDictionary class]]) {
        ReservationFormConfig* config = [ReservationFormConfig getInstance];
        [config resetReservationFormObjects];
        config.isDataFetched = true;
        if (IS_NOT_NULL(json, @"form_name")) {
            config.form_title = GET_VALUE_OBJ(json, @"form_name");
        }
        if (IS_NOT_NULL(json, @"submit_mess")) {
            config.submit_button_title = GET_VALUE_OBJ(json, @"submit_mess");
        }
        if (IS_NOT_NULL(json, @"input")) {
            NSArray* array = GET_VALUE_OBJ(json, @"input");
            for (NSDictionary* dict in array) {
                ReservationForm* cObj = [[ReservationForm alloc] init];
                if (IS_NOT_NULL(dict, @"type")) {
                    cObj.type = GET_VALUE_OBJ(dict, @"type");
                }
                if (IS_NOT_NULL(dict, @"shortcode")) {
                    cObj.shortcode = GET_VALUE_OBJ(dict, @"shortcode");
                }
                if (IS_NOT_NULL(dict, @"label")) {
                    cObj.label = GET_VALUE_OBJ(dict, @"label");
                }
                if (IS_NOT_NULL(dict, @"options")) {
                    NSArray* array_options = GET_VALUE_OBJ(dict, @"options");
                    for (NSString* str in array_options) {
                        [cObj.options addObject:str];
                    }
                }
                [config addReservationFormObject:cObj];
            }
        }
    }
}
- (void)parseWCCheckoutManagerDataAllOrders:(NSArray*)array {
    if (!(array && [array isKindOfClass:[NSArray class]])) {
        RLOG(@"Unable to parse: Either array is empty or invalid array");
        return;
    }
    for (NSDictionary* dict in array) {
        Order* order = nil;
        if (IS_NOT_NULL(dict, @"order_id")) {
            int order_id = GET_VALUE_INT(dict, @"order_id");
            order = [Order findWithOrderId:order_id];
            if (IS_NOT_NULL(dict, @"meta_data")) {
                NSDictionary* metaData = GET_VALUE_OBJ(dict, @"meta_data");
                if (metaData && [metaData isKindOfClass:[NSDictionary class]]) {
                    NSArray* metaDataKeys = [metaData allKeys];
                    if ([metaDataKeys count] > 0) {
                        NSString* strMetaData = @"";
                        for (NSString* keyStr in metaDataKeys) {
                            NSString* valStr = [metaData valueForKey:keyStr];
                            strMetaData = [strMetaData stringByAppendingFormat:@"%@ : %@\n", keyStr, valStr];
                        }
                        if (![strMetaData isEqualToString:@""] && [order._note containsString:strMetaData] == false) {
                            NSString* orderNote = [NSString stringWithFormat:@"%@", order._note];
                            if ([orderNote isEqualToString:@""]) {
                                order._note = [NSString stringWithFormat:@"%@", strMetaData];
                            } else {
                                order._note = [NSString stringWithFormat:@"%@\n%@", strMetaData, orderNote];
                            }
                        }
                    }
                }
            }
        }
    }
}
- (void)parseWCCheckoutManagerData:(NSArray*)array {
    if (!(array && [array isKindOfClass:[NSArray class]])) {
        RLOG(@"Unable to parse: Either array is empty or invalid array");
        return;
    }
    MultiStoreCheckoutConfig* msConfig = [MultiStoreCheckoutConfig getInstance];
    msConfig.isDataFetched = false;
    [msConfig.deliverSlots removeAllObjects];
    for (NSDictionary* dict in array) {
        NSString* label = @"";
        NSString* cow = @"";
        NSString* cow_temp = @"";
        NSString* chosen_valt = @"";
        NSString* conditional_tie = @"";
        NSString* force_title2 = @"";
        NSArray* option_array = nil;
        if (IS_NOT_NULL(dict, @"label")) {
            label = GET_VALUE_OBJECT(dict, @"label");
        }
        if (IS_NOT_NULL(dict, @"cow")) {
            cow = GET_VALUE_OBJECT(dict, @"cow");
            cow_temp = [cow lowercaseString];
        }
        if (IS_NOT_NULL(dict, @"chosen_valt")) {
            chosen_valt = GET_VALUE_OBJECT(dict, @"chosen_valt");
        }
        if (IS_NOT_NULL(dict, @"conditional_tie")) {
            conditional_tie = GET_VALUE_OBJECT(dict, @"conditional_tie");
        }
        if (IS_NOT_NULL(dict, @"force_title2")) {
            force_title2 = GET_VALUE_OBJECT(dict, @"force_title2");
        }
        if (IS_NOT_NULL(dict, @"option_array")) {
            @try {
                NSString* strOptionArray = GET_VALUE_OBJECT(dict, @"option_array");
                option_array = [strOptionArray componentsSeparatedByString:@"||"];
            } @catch (NSException *exception) {

            } @finally {

            }
        }
        if ([cow_temp isEqualToString:@"myfield1"]) {
            msConfig.deliveryTypeLabel = label;
            msConfig.deliveryTypeOptions = option_array;
            msConfig.selectedDeliveryType = chosen_valt;
            msConfig.deliveryTypeField = @"myfield1";
            if (IS_NOT_NULL(dict, @"add_amount")) {
                BOOL add_amount = GET_VALUE_BOOL(dict, @"add_amount");
                if (add_amount) {
                    if (IS_NOT_NULL(dict, @"add_amount_field")) {
                        msConfig.deliveryFee = GET_VALUE_OBJECT(dict, @"add_amount_field");
                    }
                }
            }
        } else if ([cow_temp isEqualToString:@"myfield2"]) {
            msConfig.clusterDestinationsLabel = label;
            msConfig.clusterDestinationsOptions = option_array;
            msConfig.selectedClusterDestination = chosen_valt;
            msConfig.clusterDestinationsField = @"myfield2";
        } else if ([cow_temp isEqualToString:@"myfield3"]) {
            msConfig.deliveryDaysLabel = label;
            msConfig.deliveryDaysOptions = option_array;
            msConfig.selectedDeliveryDay = chosen_valt;
            msConfig.deliveryDaysField = @"myfield3";
        } else if ([cow_temp isEqualToString:@"myfield6"]) {
            msConfig.homeDestinationLabel = label;
            msConfig.homeDestinationOptions = option_array;
            msConfig.selectedHomeDestination = chosen_valt;
            msConfig.homeDestinationField = @"myfield6";
        } else if ([cow_temp isEqualToString:@"myfield4"]
                   || [cow_temp isEqualToString:@"myfield5"]
                   || [cow_temp isEqualToString:@"myfield7"]
                   || [cow_temp isEqualToString:@"myfield8"]
                   || [cow_temp isEqualToString:@"myfield9"]
                   || [cow_temp isEqualToString:@"myfield10"]
                   || [cow_temp isEqualToString:@"myfield11"]) {
            MSCDeliverSlot* msdSlot = [[MSCDeliverSlot alloc] init];
            msdSlot.label = label;
            msdSlot.options = option_array;
            msdSlot.chosen_valt = chosen_valt;
            msdSlot.field = cow;
            [msConfig.deliverSlots addObject:msdSlot];
        }

    }
    msConfig.isDataFetched = true;
}

#pragma mark SELLER_ZONE
- (NSMutableArray*)sellerZoneParseOrderJson:(NSDictionary*)dict {
    SellerZoneManager* szManager = [SellerZoneManager getInstance];
    [szManager.myOrders removeAllObjects];
    if (dict) {
        NSArray* headerDict = [dict objectForKey:@"orders"];
        for (NSDictionary* orderJson in headerDict) {
            Order* order = [self parseOrderJson:orderJson];
            [szManager.myOrders addObject:order];
        }
    }
    return szManager.myOrders;
}

- (SellerInfo*)szParseSellerInfo:(NSDictionary*)dict {
    //    {
    //        "geo_location": {
    //            "latitude": "22.718664",
    //            "longitude": "75.855377"
    //        },
    //        "membership_level": {
    //            "allow_signups": "",
    //            "billing_amount": "",
    //            "enddate": "",
    //            "expiration_number": "",
    //            "expiration_period": "",
    //            "initial_payment": "",
    //            "level_id": "",
    //            "membership_status": "",
    //            "startdate": "",
    //            "subscription_id": "",
    //            "subscription_name": "",
    //            "trial_amount": "",
    //            "trial_limit": ""
    //        },
    //        "seller": {
    //            "avatar": "https://fashoover.com/wp-content/uploads/avatars/113/5a1fd5413dcdf-bpfull.png",
    //            "first_name": "TMStore",
    //            "id": "113",
    //            "info": "",
    //            "last_name": "",
    //            "phone": "12345680",
    //            "profile_url": "",
    //            "verified": true
    //        },
    //        "shop": {
    //            "address": "Rajwada Chowk, Rajwada, Indore, Madhya Pradesh 452002, India",
    //            "banner_url": "https://fashoover.com/wp-content/uploads/2017/10/11.jpg",
    //            "description": "",
    //            "icon_url": "https://fashoover.com/wp-content/uploads/2017/11/1512035607-1.png",
    //            "name": "tms shop",
    //            "shop_url": "https://fashoover.com/vendors/rock/"
    //        }
    //    }
    NSDictionary* sellerDict = nil;
    NSDictionary* shopDict = nil;
    NSDictionary* geoLocDict = nil;
    NSDictionary* membership_level_dict = nil;
    NSString* sellerId = @"";
    if (IS_NOT_NULL(dict, @"seller")) {
        sellerDict = GET_VALUE_OBJ(dict, @"seller");
        if (IS_NOT_NULL(sellerDict, @"id")) {
            sellerId = GET_VALUE_STR(sellerDict, @"id");
        }
    }
    if (IS_NOT_NULL(dict, @"shop")) {
        shopDict = GET_VALUE_OBJ(dict, @"shop");
    }
    if (IS_NOT_NULL(dict, @"geo_location")) {
        geoLocDict = GET_VALUE_OBJ(dict, @"geo_location");
    }
    if (IS_NOT_NULL(dict, @"membership_level")) {
        membership_level_dict = GET_VALUE_OBJ(dict, @"membership_level");
    }

    SellerInfo* sInfo = nil;
    if (sellerDict && sellerId && ![sellerId isEqualToString:@""]) {
        sInfo = [SellerInfo getSellerInfoWithId:sellerId];
        if (sInfo == nil) {
            sInfo = [[SellerInfo alloc] init];
        }
        if (IS_NOT_NULL(sellerDict, @"id")) {
            sInfo.sellerId = GET_VALUE_STR(sellerDict, @"id");
        }
        if (IS_NOT_NULL(sellerDict, @"first_name")) {
            sInfo.sellerFirstName = GET_VALUE_STR(sellerDict, @"first_name");
        }
        if (IS_NOT_NULL(sellerDict, @"last_name")) {
            sInfo.sellerLastName = GET_VALUE_STR(sellerDict, @"last_name");
        }
        AppUser* appUSer = [AppUser sharedManager];
        if ([sInfo.sellerId isEqualToString:[NSString stringWithFormat:@"%d",appUSer._id]]) {
            appUSer._first_name = sInfo.sellerFirstName;
            appUSer._last_name = sInfo.sellerLastName;
        }

        sInfo.sellerTitle = [NSString stringWithFormat:@"%@ %@", sInfo.sellerFirstName, sInfo.sellerLastName];
        if (IS_NOT_NULL(sellerDict, @"location")) {
            NSMutableArray* locationArray = GET_VALUE_OBJ(sellerDict, @"location");
            if ([locationArray isKindOfClass:[NSArray class]]) {
                sInfo.locations = locationArray;
            } else {
                RLOG(@"locationArray is not an array");
            }
        }
        if (IS_NOT_NULL(sellerDict, @"profile_url")) {
            sInfo.sellerProfileUrl = GET_VALUE_STR(sellerDict, @"profile_url");
        }
        if (IS_NOT_NULL(sellerDict, @"avatar")) {
            sInfo.sellerAvatarUrl = GET_VALUE_STR(sellerDict, @"avatar");
        }
        if (IS_NOT_NULL(sellerDict, @"verified")) {
            sInfo.isSellerVerified = GET_VALUE_BOOL(sellerDict, @"verified");
        }
        if (IS_NOT_NULL(sellerDict, @"phone")) {
            sInfo.sellerPhone = GET_VALUE_STR(sellerDict, @"phone");
        }
        if (IS_NOT_NULL(sellerDict, @"info")) {
            sInfo.sellerInfo = GET_VALUE_STR(sellerDict, @"info");
        }
    }
    if (shopDict && sInfo) {
        if (IS_NOT_NULL(shopDict, @"name")) {
            sInfo.shopName = GET_VALUE_STR(shopDict, @"name");
        }
        if (IS_NOT_NULL(shopDict, @"shop_url")) {
            sInfo.shopUrl = GET_VALUE_STR(shopDict, @"shop_url");
        }
        if (IS_NOT_NULL(shopDict, @"icon_url")) {
            sInfo.shopIconUrl = GET_VALUE_STR(shopDict, @"icon_url");
        }
        if (IS_NOT_NULL(shopDict, @"banner_url")) {
            sInfo.shopBannerUrl = GET_VALUE_STR(shopDict, @"banner_url");
        }
        if (IS_NOT_NULL(shopDict, @"address")) {
            sInfo.shopAddress = GET_VALUE_STR(shopDict, @"address");
        }
        if (IS_NOT_NULL(shopDict, @"description")) {
            sInfo.shopDescription = GET_VALUE_STR(shopDict, @"description");
        }
    }
    
    if (geoLocDict && sInfo) {
        if (geoLocDict && [geoLocDict isKindOfClass:[NSDictionary class]]) {
            if (IS_NOT_NULL(geoLocDict, @"latitude")) {
                sInfo.shopLatitude = GET_VALUE_DOUBLE(geoLocDict, @"latitude");
            }
            if (IS_NOT_NULL(geoLocDict, @"longitude")) {
                sInfo.shopLongitude = GET_VALUE_DOUBLE(geoLocDict, @"longitude");
            }
        }
    }

    if (membership_level_dict && sInfo) {
        if ([membership_level_dict isKindOfClass:[NSDictionary class]]) {
            if (IS_NOT_NULL(membership_level_dict, @"membership_status")) {
                sInfo.membership_status = GET_VALUE_STR(membership_level_dict, @"membership_status");
            }           
            if (IS_NOT_NULL(membership_level_dict, @"subscription_url")) {
                sInfo.subscription_url = GET_VALUE_STR(membership_level_dict, @"subscription_url");
            }
        }
    }

    return sInfo;
}
- (void)szParseAttributesData:(NSDictionary*)dict {
    [[SZAttribute getAllSZAttributes] removeAllObjects];
    [[SZAttributeOption getAllSZAttributeOptions] removeAllObjects];
    NSArray* attributeArray = nil;
    if (IS_NOT_NULL(dict, @"attribute_data")) {
        attributeArray = GET_VALUE_OBJ(dict, @"attribute_data");
    }
    if (attributeArray) {
        for (NSDictionary* attDict in attributeArray) {
            int attId = -1;
            if (IS_NOT_NULL(attDict, @"id")) {
                attId = GET_VALUE_INT(attDict, @"id");
            }
            SZAttribute* szAtt = [SZAttribute getSZAttributeById:attId];
            if (IS_NOT_NULL(attDict, @"id")) {
                szAtt.attributeId = GET_VALUE_INT(attDict, @"id");
            }
            if (IS_NOT_NULL(attDict, @"name")) {
                szAtt.name = GET_VALUE_STRING(attDict, @"name");
            }
            if (IS_NOT_NULL(attDict, @"slug")) {
                szAtt.slug = GET_VALUE_STRING(attDict, @"slug");
            }
            if (IS_NOT_NULL(attDict, @"type")) {
                szAtt.type = GET_VALUE_STRING(attDict, @"type");
            }
            if (IS_NOT_NULL(attDict, @"order_by")) {
                szAtt.order_by = GET_VALUE_STRING(attDict, @"order_by");
            }
            if (IS_NOT_NULL(attDict, @"has_archives")) {
                szAtt.has_archives = GET_VALUE_BOOL(attDict, @"has_archives");
            }
            if (IS_NOT_NULL(attDict, @"product_attribute_term")) {
                NSArray* product_attribute_term = GET_VALUE_OBJ(attDict, @"product_attribute_term");
                if (product_attribute_term && [product_attribute_term isKindOfClass:[NSArray class]]) {
                    for (NSDictionary* optionDict in product_attribute_term) {

                        int attOptionId = -1;
                        if (IS_NOT_NULL(optionDict, @"id")) {
                            attOptionId = GET_VALUE_INT(optionDict, @"id");
                        }
                        SZAttributeOption* szAttOp = [SZAttributeOption getSZAttributeOptionById:attOptionId];
                        [szAtt.product_attribute_term addObject:szAttOp];
                        if (IS_NOT_NULL(optionDict, @"id")) {
                            szAttOp.optionId = GET_VALUE_INT(optionDict, @"id");
                        }
                        if (IS_NOT_NULL(optionDict, @"slug")) {
                            szAttOp.slug = GET_VALUE_STRING(optionDict, @"slug");
                        }
                        if (IS_NOT_NULL(optionDict, @"name")) {
                            szAttOp.name = GET_VALUE_STRING(optionDict, @"slug");
                        }
                        if (IS_NOT_NULL(optionDict, @"count")) {
                            szAttOp.count = GET_VALUE_INT(optionDict, @"count");
                        }
                    }
                }
            }
        }
    }
    [SelSZAtt remanageAllSelSZAtt];
}

- (void)parseMultipleShippingAddresses:(NSArray*)array {
    [[MapAddress getAllAddresses] removeAllObjects];
    [[MapAddress getAllAddressesWithLatLong] removeAllObjects];
    [MapAddress setSelectedMapAddress:nil];


    if (array && [array isKindOfClass:[NSArray class]]) {
        for (NSDictionary* dict in array) {
            if (dict && [dict isKindOfClass:[NSDictionary class]]) {
                MapAddress* mAdd = [[MapAddress alloc] init];
                if (IS_NOT_NULL(dict, @"shipping_first_name")) {
                    mAdd.shipping_first_name = GET_VALUE_OBJ(dict, @"shipping_first_name");
                }
                if (IS_NOT_NULL(dict, @"shipping_last_name")) {
                    mAdd.shipping_last_name = GET_VALUE_OBJ(dict, @"shipping_last_name");
                }
                if (IS_NOT_NULL(dict, @"shipping_company")) {
                    mAdd.shipping_company = GET_VALUE_OBJ(dict, @"shipping_company");
                }
                if (IS_NOT_NULL(dict, @"shipping_country")) {
                    mAdd.shipping_country = GET_VALUE_OBJ(dict, @"shipping_country");
                }
                if (IS_NOT_NULL(dict, @"shipping_address_1")) {
                    mAdd.shipping_address_1 = GET_VALUE_OBJ(dict, @"shipping_address_1");
                }
                if (IS_NOT_NULL(dict, @"shipping_address_2")) {
                    mAdd.shipping_address_2 = GET_VALUE_OBJ(dict, @"shipping_address_2");
                }
                if (IS_NOT_NULL(dict, @"shipping_city")) {
                    mAdd.shipping_city = GET_VALUE_OBJ(dict, @"shipping_city");
                }
                if (IS_NOT_NULL(dict, @"shipping_state")) {
                    mAdd.shipping_state = GET_VALUE_OBJ(dict, @"shipping_state");
                }
                if (IS_NOT_NULL(dict, @"shipping_postcode")) {
                    mAdd.shipping_postcode = GET_VALUE_OBJ(dict, @"shipping_postcode");
                }
                if (IS_NOT_NULL(dict, @"shipping_lat")) {
                    mAdd.shipping_lat = GET_VALUE_OBJ(dict, @"shipping_lat");
                }
                if (IS_NOT_NULL(dict, @"shipping_lng")) {
                    mAdd.shipping_lng = GET_VALUE_OBJ(dict, @"shipping_lng");
                }
                if (IS_NOT_NULL(dict, @"shipping_address_is_default")) {
                    mAdd.shipping_address_is_default = GET_VALUE_BOOL(dict, @"shipping_address_is_default");
                }
            }
        }
    }
}
@end
