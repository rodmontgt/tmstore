//
//  WC2X_Engine.m
//  TMDataDoctor
//
//  Created by Rishabh Jain on 18/01/16.
//  Copyright © 2016 Twist Mobile Pvt. Ltd. India. All rights reserved.
//

#import "WC2X_Engine.h"
#import "CommonInfo.h"
#import "Variables.h"
#import "AppUser.h"
#import "Order.h"
#import "Variation.h"
#import "ServerData.h"
#import "ProductInfo.h"
#import "ProductImage.h"
#import "Attribute.h"
#import "CategoryInfo.h"
#import <STHTTPRequest/STHTTPRequest.h>
#import "DataManager.h"
#import "Cart.h"
#import "Variation.h"
#import "Attribute.h"
#import "UIAlertView+NSCookbook.h"
#import "CartMeta.h"
#import "FeeData.h"
#import "MinOrderData.h"
#import "Variables.h"
#import "TM_PickupLocation.h"
#import "TM_CheckoutAddon.h"
#import "ContactForm3Config.h"
#import "ReservationFormConfig.h"
#import "MapAddress.h"
#define WC2XLOG(format, ...) RLOG((@"WC2X: %s [Line %d]\n" format @"\n\n"), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

@interface CustomJSONSerializer: AFJSONResponseSerializer
@end

@implementation CustomJSONSerializer

- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error {
    // Let the superclass do its work.
    // Run the custom code only if there is an error.
    id responseToReturn = [super responseObjectForResponse:response
                                                      data:data
                                                     error:error];
    if (!*error) {
        return responseToReturn;
    }
    
    NSError *parsingError;
    NSDictionary *JSONResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:NSJSONReadingAllowFragments
                                                                   error:&parsingError];
    
    if (parsingError) {
        return responseToReturn;
    }
    
    // Populate the error's userInfo using the parsed JSON
    NSMutableDictionary *userInfo = [(*error).userInfo mutableCopy];
    NSString *errorDescription = JSONResponse[@"error"];
    userInfo[NSLocalizedDescriptionKey] = errorDescription;
    
    NSError *annotatedError = [NSError errorWithDomain:(*error).domain
                                                  code:(*error).code
                                              userInfo:userInfo];
    (*error) = annotatedError;
    
    return responseToReturn;
}

@end


@interface WC2X_Engine()
{
    NSString *oauth_signature;
    NSString *oauth_nonce;
    NSString *time_stamp;
    NSString *requestURL;
    NSMutableData *_responseData;
}
@end

@implementation WC2X_Engine
- (id)initEngineWithBaseUrl:(NSString*)baseUrl storeVersion:(NSString*)storeVersion  consumerKey:(NSString*)consumerKey consumerSecretKey:(NSString*)consumerSecretKey pagelinkContactus:(NSString*)pagelinkContactus pagelinkAboutus:(NSString*)pagelinkAboutus{
    self = [super init];
    if (self) {
        self.tmJsonHelper = [[WC2X_JsonHelper alloc] initWithEngine:self];
        self.tmMulticastDelegate = [TMMulticastDelegate new];
        self.serverDatas = [[NSMutableArray alloc] init];
        
        self.baseUrl = baseUrl;
        self.version_string = storeVersion;
        self.oauth_consumer_key = consumerKey;
        self.oauth_consumer_secret = consumerSecretKey;
        self.pagelinkAboutUs = pagelinkAboutus;
        self.pagelinkContactUs = pagelinkContactus;
        
        self.siteUrl = [NSString stringWithFormat:@"%@/wc-api/%@", self.baseUrl, self.version_string];
        self.oauth_token = @"";
        self.request_url_products = [NSString stringWithFormat:@"%@/wc-api/%@/products", self.baseUrl, self.version_string];
        self.request_url_customer = [NSString stringWithFormat:@"%@/wc-api/%@/customers", self.baseUrl, self.version_string];
        self.request_url_orders = [NSString stringWithFormat:@"%@/wc-api/%@/orders", self.baseUrl, self.version_string];
        self.request_url_all_orders = [NSString stringWithFormat:@"%@/wc-api/%@/customers", self.baseUrl, self.version_string]; //"/wc-api/v3/customers/" + customerId + "/orders
        self.request_url_categories = [NSString stringWithFormat:@"%@/wc-api/%@/products/categories", self.baseUrl, self.version_string];
        self.request_url_common = [NSString stringWithFormat:@"%@/wc-api/%@", self.baseUrl, self.version_string];
        self.createUserPageLink = [NSString stringWithFormat:@"%@", self.baseUrl];
        self.externalLoginPageLink = [NSString stringWithFormat:@"%@", self.baseUrl];
        self.loginPageLink = [NSString stringWithFormat:@"%@/wp-login.php", self.baseUrl];
        self.productPageBaseUrl = [NSString stringWithFormat:@"%@?p=", self.baseUrl];
        self.external_login_url = [NSString stringWithFormat:@"%@/?user_platform=IOS", self.baseUrl];
        self.external_login_url_hidden = [NSString stringWithFormat:@"%@/wp-tm-store-notify/api/login_website", self.baseUrl];
        self.external_signup_url = [NSString stringWithFormat:@"%@/?user_platform=IOS", self.baseUrl];
        self.cart_url = [NSString stringWithFormat:@"%@/cart/", self.baseUrl];
        self.checkout_url = [NSString stringWithFormat:@"%@/checkout?device_type=ios", self.baseUrl];
        self.request_url_singleProduct = [NSString stringWithFormat:@"%@/wc-api/%@/products", self.baseUrl, self.version_string];
        
        // url to load home page contents
        self.request_url_frontpage_content = [NSString stringWithFormat:@"%@/wp-tm-store-notify/api/splash_products", self.baseUrl];
        // url to load 10-10 products for homepage categories
        self.request_url_initial_products = [NSString stringWithFormat:@"%@/wp-tm-store-notify/api/load_products", self.baseUrl];
        self.request_url_more_products = [NSString stringWithFormat:@"%@/wp-tm-store-notify/api/pole_products", self.baseUrl];
        self.request_url_products_full_data = [NSString stringWithFormat:@"%@/wp-tm-store-notify/api/product_full_data", self.baseUrl];
        self.request_url_search_products = [NSString stringWithFormat:@"%@/wp-tm-store-notify/api/search_products",self.baseUrl];
        self.request_url_countries = [NSString stringWithFormat:@"%@/wp-tm-store-notify/api/countries_list/", self.baseUrl];
        self.request_url_update_customer = [NSString stringWithFormat:@"%@/wc-api/%@/customers", self.baseUrl, self.version_string];
        self.request_url_sync_cart_items = [NSString stringWithFormat:@"%@/wp-tm-store-notify/api/cart_items", self.baseUrl];
        self.request_url_coupons = [NSString stringWithFormat:@"%@/wc-api/%@/coupons", self.baseUrl, self.version_string];
        self.request_url_menu_items = [NSString stringWithFormat:@"%@/wp-tm-store-notify/api/menu_data", self.baseUrl];
        self.request_url_extra_attribs = [NSString stringWithFormat:@"%@/wp-tm-ext-store-notify/api/variation_simple_fields/", self.baseUrl];
        self.request_url_taxes = [NSString stringWithFormat:@"%@/wc-api/%@/taxes", self.baseUrl, self.version_string];
        self.request_url_single_product_fast = [NSString stringWithFormat:@"%@/wp-tm-ext-store-notify/api/woocommerce_ext_product_data/", self.baseUrl];
        self.request_url_filterdata_prices = [NSString stringWithFormat:@"%@/wp-tm-store-notify/api/filter_data_price/",self.baseUrl];
        self.request_url_filterdata_attributes =[NSString stringWithFormat:@"%@/wp-tm-store-notify/api/filter_data_attribute/",baseUrl];
        self.request_url_filter_products =[NSString stringWithFormat:@"%@/wp-tm-store-notify/api/filter_products/",baseUrl];
        if (1) {
            NSString* pluginName = @"dokan";
            if ([[Addons sharedManager] multiVendor] && [[[Addons sharedManager] multiVendor] isEnabled] && [[[Addons sharedManager] multiVendor] plugin_name] && ![[[[Addons sharedManager] multiVendor] plugin_name] isEqualToString:@""]) {
                pluginName = [[[Addons sharedManager] multiVendor] plugin_name];
            }
            self.request_url_list_vendor = [NSString stringWithFormat:@"%@/wp-tm-ext-store-notify/api/%@_seller_list", self.baseUrl, pluginName];
            self.request_url_frontpage_content_vendor = [NSString stringWithFormat:@"%@/wp-tm-ext-store-notify/api/%@_splash_products", self.baseUrl, pluginName];
            self.request_url_initial_products_vendor = [NSString stringWithFormat:@"%@/wp-tm-ext-store-notify/api/%@_load_products", self.baseUrl, pluginName];
            self.request_url_products_vendor = [NSString stringWithFormat:@"%@/wp-tm-ext-store-notify/api/%@_load_category_products", self.baseUrl, pluginName];
        }
        
        
        
        self.request_url_products_fast = [NSString stringWithFormat:@"%@/wp-tm-store-notify/api/load_category_products",baseUrl];
        
        _overlayUpdateOrderAfterPurchase = nil;
        _isHomePageDataFetched = false;
        _isInitialPageDataFetched = false;
        _isVendorDataFetched = false;
        
        self.url_shipment_track = [NSString stringWithFormat:@"%@/wp-tm-store-notify/api/exship_data/", self.baseUrl];
        self.url_prdd_plugin_data = [NSString stringWithFormat:@"%@/wp-tm-ext-store-notify/api/product-delivery-info/", self.baseUrl];
        self.url_custom_waitlist = [NSString stringWithFormat:@"%@/wp-tm-ext-store-notify/api/custom_waitlist/", self.baseUrl];
        self.url_custom_wishlist = [NSString stringWithFormat:@"%@/wp-tm-ext-store-notify/api/custom_wishlist/", self.baseUrl];
        self.url_custom_reward_points = [NSString stringWithFormat:@"%@/wp-tm-ext-store-notify/api/custom_reward_points/", self.baseUrl];
        self.url_custom_sponsor_friend = [NSString stringWithFormat:@"%@/wp-tm-ext-store-notify/api/custom_sponsor_a_friend/", self.baseUrl];
        self.url_products_brand_names = [NSString stringWithFormat:@"%@/wp-tm-ext-store-notify/api/woo_brand", self.baseUrl];
        self.url_products_price_labels = [NSString stringWithFormat:@"%@/wp-tm-ext-store-notify/api/woocommerce_price_labeller", self.baseUrl];
        self.url_incremental_product_quantities = [NSString stringWithFormat:@"%@/wp-tm-ext-store-notify/api/woocommerce_incremental_product_quantities", self.baseUrl];
        self.url_product_pin_code = [NSString stringWithFormat:@"%@/wp-tm-ext-store-notify/api/woocommerce_product_pin_code/", self.baseUrl];
        
        self.url_delivery_slots = [NSString stringWithFormat:@"%@/wp-tm-ext-store-notify/api/woocommerce_delivery_slots_copia/", self.baseUrl];
        self.url_local_pickup_time_select = [NSString stringWithFormat:@"%@/wp-tm-ext-store-notify/api/woocommerce_local_pickup_time_select/", self.baseUrl];
        self.url_pick_up_locations = [NSString stringWithFormat:@"%@/wp-tm-ext-store-notify/api/woocommerce-shipping-local-pickup-plus/",baseUrl];
        //"http://demo001.aboutfaces.co.in/wp-tm-ext-store-notify/api/woocommerce-shipping-local-pickup-plus/"
        self.request_url_selected_orders_data = [NSString stringWithFormat:@"%@/wp-tm-store-notify/api/order_data",baseUrl];
        
        
        self.multiVendorPluginName = @"dokan";
        if ([[Addons sharedManager] multiVendor] && [[[Addons sharedManager] multiVendor] isEnabled] && [[[Addons sharedManager] multiVendor] plugin_name] && ![[[[Addons sharedManager] multiVendor] plugin_name] isEqualToString:@""]) {
            self.multiVendorPluginName = [[[Addons sharedManager] multiVendor] plugin_name];
        }
        
        
    }
    return self;
}
#pragma mark Private Methods
- (NSString *)getRFC3986:(NSString *)str {
    NSString *strR = [NSString stringWithString:[str st_stringByAddingRFC3986PercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    RLOG(@"STR RFC3986 = %@", strR);
    return strR;
}
- (NSString *)hmacsha1:(NSString *)plaintext key:(NSString *)key {
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [plaintext cStringUsingEncoding:NSASCIIStringEncoding];
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    NSString *hash = [HMAC base64EncodedString];
    RLOG(@"STR Hash = %@", hash);
    return hash;
}
- (NSString *)randomStringWithLength:(int)len {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    RLOG(@"STR Random = %@", randomString);
    return randomString;
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    RLOG(@"didReceiveResponse");
    //[received_data setLength:0];//Set your data to 0 to clear your buffer
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    RLOG(@"didReceiveData");
    //[received_data appendData:data];//Append the download data..
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    RLOG(@"connection");
    //Use your downloaded data here
}
#pragma mark Fetch Data from Woocommerce
- (NSURL*)getNSURL:(NSString *)requestedUrl isPostMethod:(BOOL)_isPostMethod maxDataLimit:(int)maxDataLimit offset:(int)offset {
    RLOG(@"%@",requestedUrl);
    requestURL = [NSString stringWithString:requestedUrl];
    NSString* params = [NSString stringWithFormat:@"filter%%5Blimit%%5D=%d&oauth_consumer_key=%@&oauth_nonce=%@&oauth_signature_method=%@&oauth_timestamp=%@", maxDataLimit, self.oauth_consumer_key,[self randomStringWithLength:32],@"HMAC-SHA1",[NSString stringWithFormat:@"%lu", (unsigned long)[NSDate.date timeIntervalSince1970]]];
    
    NSString* urlStr = [NSString stringWithFormat:@"%@", requestURL];
    urlStr = [self getRFC3986:urlStr];
    NSString* paramString = [NSString stringWithFormat:@"%@", params];
    paramString = [self getRFC3986:paramString];
    NSString* algoString = [NSString stringWithFormat:@"GET&%@&%@", urlStr, paramString];
    
    NSString* algoKey;
    if([self.version_string isEqualToString:@"v2"]) {
        algoKey = self.oauth_consumer_secret;
    }else if([self.version_string isEqualToString:@"v3"]) {
        algoKey = [NSString stringWithFormat:@"%@&", self.oauth_consumer_secret];
    }
    NSString* _oauth_signature = [self hmacsha1:algoString key:algoKey];
    params = [NSString stringWithFormat:@"%@&oauth_signature=%@", params, _oauth_signature];
    
    if ([Utility containsString:requestURL substring:@"https"]) {
        params = [NSString stringWithFormat:@"filter%%5Blimit%%5D=%d&consumer_key=%@&consumer_secret=%@", maxDataLimit, self.oauth_consumer_key, self.oauth_consumer_secret];
    }
    NSString *finalUrlStr =[NSString stringWithFormat:@"%@?%@",requestURL, params];
    NSURL *url = [NSURL URLWithString:finalUrlStr];
    RLOG(@"url=%@",url);
    return url;
}


- (void)fetchTaxesData:(void(^)(id data))success
               failure:(void(^)(NSString* error))failure {
    RLOG(@"fetchTaxesData");
    NSString* urlString = [NSString stringWithFormat:@"%@", self.request_url_taxes];
    NSURL* nsUrl = [self getNSURL:urlString isPostMethod:false maxDataLimit:200 offset:0];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [manager GET:nsUrl.absoluteString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        if (responseObject != nil) {
            NSDictionary *dict = [Utility getJsonObject:responseObject];
            RLOG(@"\ndict = %@",dict);
            if (dict) {
                if ([dict isKindOfClass:[NSDictionary class]]) {
                    [self.tmJsonHelper loadTaxesData:dict];
                    success(dict);
                    RLOG(@"fetchTaxesData success");
                }
            }else {
                failure(@"failure");
                RLOG(@"fetchTaxesData failure1");
            }
        } else {
            failure(@"failure");
            RLOG(@"fetchTaxesData failure2");
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        
        if (error && error.userInfo) {
            id data = [error.userInfo valueForKey:@"com.alamofire.serialization.response.error.data"];
            if (data) {
                NSDictionary* json_dict = [Utility getJsonObject:data];
                RLOG(@"======fetchTaxesData:failure:%@======",json_dict);
            }
        }
        
        
        
        
        NSInteger statusCode = 0;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
        if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = httpResponse.statusCode;
        }
        
        if(statusCode == 404 || statusCode == 200) {
            failure(@"failure");
            RLOG(@"fetchTaxesData failure3");
        } else {
            failure(@"retry");
            RLOG(@"fetchTaxesData failure4");
//            if ([Utility isMultiStoreApp]) {
//                failure(@"failure");
//            } else {
//                failure(@"retry");
//            }
        }
    }];
    
}

- (void)fetchProductDataFromSku:(NSString*)sku
                        success:(void(^)(id data))success
               failure:(void(^)(NSString* error))failure {
    RLOG(@"fetchProductDataFromSku");
    NSString* requestedUrl = [NSString stringWithFormat:@"%@", self.request_url_singleProduct];
    RLOG(@"%@",requestedUrl);
    requestURL = [NSString stringWithString:requestedUrl];
    NSString* params = [NSString stringWithFormat:@"filter%%5Bsku%%5D=%@&oauth_consumer_key=%@&oauth_nonce=%@&oauth_signature_method=%@&oauth_timestamp=%@", sku, self.oauth_consumer_key,[self randomStringWithLength:32],@"HMAC-SHA1",[NSString stringWithFormat:@"%lu", (unsigned long)[NSDate.date timeIntervalSince1970]]];
    
    NSString* urlStr = [NSString stringWithFormat:@"%@", requestURL];
    urlStr = [self getRFC3986:urlStr];
    NSString* paramString = [NSString stringWithFormat:@"%@", params];
    paramString = [self getRFC3986:paramString];
    NSString* algoString = [NSString stringWithFormat:@"GET&%@&%@", urlStr, paramString];
    
    NSString* algoKey;
    if([self.version_string isEqualToString:@"v2"]) {
        algoKey = self.oauth_consumer_secret;
    }else if([self.version_string isEqualToString:@"v3"]) {
        algoKey = [NSString stringWithFormat:@"%@&", self.oauth_consumer_secret];
    }
    NSString* _oauth_signature = [self hmacsha1:algoString key:algoKey];
    params = [NSString stringWithFormat:@"%@&oauth_signature=%@", params, _oauth_signature];
    
    if ([Utility containsString:requestURL substring:@"https"]) {
        params = [NSString stringWithFormat:@"filter%%5Bsku%%5D=%@&consumer_key=%@&consumer_secret=%@", sku, self.oauth_consumer_key, self.oauth_consumer_secret];
    }
    NSString *finalUrlStr =[NSString stringWithFormat:@"%@?%@",requestURL, params];
    NSURL *url = [NSURL URLWithString:finalUrlStr];
    RLOG(@"url=%@",url);
    
    NSURL* nsUrl = url;
    
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [manager GET:nsUrl.absoluteString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        if (responseObject != nil) {
            NSDictionary *dict = [Utility getJsonObject:responseObject];
            RLOG(@"\ndict = %@",dict);
            if (dict) {
                if ([dict isKindOfClass:[NSDictionary class]]) {
                    if (IS_NOT_NULL(dict, @"products")) {
                        NSArray* products= GET_VALUE_OBJECT(dict, @"products");
                        if (products && [products isKindOfClass:[NSArray class]] && [products count] == 1) {
                            dict = [products objectAtIndex:0];
                            
                            NSMutableDictionary* productDict = [[NSMutableDictionary alloc] init];
                            [productDict setObject:dict forKey:@"product"];
                            ProductInfo* pInfo = [self.tmJsonHelper loadSingleProductData:productDict];
                            success(pInfo);
                            RLOG(@"fetchProductDataFromSku success");
                            return;
                        }
                    }
                }
            }
            
            
            failure(@"failure");
            RLOG(@"fetchProductDataFromSku failure1");
            
        } else {
            failure(@"failure");
            RLOG(@"fetchProductDataFromSku failure2");
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSInteger statusCode = 0;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
        if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = httpResponse.statusCode;
        }
        
        if(statusCode == 404 || statusCode == 200) {
            failure(@"failure");
            RLOG(@"fetchProductDataFromSku failure3");
        } else {
            failure(@"retry");
            RLOG(@"fetchProductDataFromSku failure4");
        }
    }];
    
}

- (ServerData*)fetchCouponsData:(UIView*)view {
    NSString* urlString = [NSString stringWithFormat:@"%@", self.request_url_coupons];
    NSURL* nsUrl = [self getNSURL:urlString isPostMethod:false maxDataLimit:200 offset:0];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    ServerData *sData = [[ServerData alloc] init];
    sData._serverUrl = [NSString stringWithString:urlString];
    sData._serverRequest = manager;
    sData._serverRequestStatus = kServerRequestStart;
    sData._serverDataId = kFetchOrders;
    [self.serverDatas addObject:sData];
    
    [manager GET:nsUrl.absoluteString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        RLOG(@"JSON: %@", responseObject);
        RLOG(@"\noperation = completed");
        RLOG(@"\nresponseObject = %@",responseObject);
        if (responseObject) {
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                [self.tmJsonHelper loadCouponData:responseObject];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"FETCH_COUPON_DATA_SUCCESS" object:nil];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"FETCH_COUPON_DATA_FAILURE" object:nil];
            }
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"FETCH_COUPON_DATA_FAILURE" object:nil];
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        RLOG(@"Error: %@", error);
        RLOG(@"\noperation = failed");
        RLOG(@"\nerror = %@", error);
        RLOG(@"\nlocalizedDescription = %@\nlocalizedFailureReason = %@\n", [error localizedDescription], [error localizedFailureReason]);
        
        NSInteger statusCode = 0;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
        if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = httpResponse.statusCode;
        }
        
        if(statusCode == 404 || statusCode == 200) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"FETCH_COUPON_DATA_FAILURE" object:nil];
        }
        else if(statusCode == 200) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"FETCH_COUPON_DATA_FAILURE" object:nil];
        } else {
            sData._serverRequestStatus = kServerRequestFailed;
            [self fetchCouponsData:view];
        }
    }];
    return sData;
}
- (void)fetchCouponsData:(void(^)(id data))success failure:(void(^)(NSString* error))failure {
    NSString* urlString = [NSString stringWithFormat:@"%@", self.request_url_coupons];
    NSURL* nsUrl = [self getNSURL:urlString isPostMethod:false maxDataLimit:200 offset:0];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:nsUrl.absoluteString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        RLOG(@"JSON: %@", responseObject);
        RLOG(@"\noperation = completed");
        RLOG(@"\nresponseObject = %@",responseObject);
        if (responseObject) {
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                [self.tmJsonHelper loadCouponData:responseObject];
                success(nil);
            } else {
                failure(@"");
            }
        } else {
            failure(@"");
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        RLOG(@"Error: %@", error);
        failure(@"");
    }];
    //    return sData;
}
- (ServerData*)fetchProductsWithTag:(UIView*)view tag:(NSString*)tag offset:(int)offset productCount:(int)productCount {
    if ([[Addons sharedManager]use_plugin_for_pagging]) {
        return [self fetchProductsByTagUsePlugin:view tag:tag offset:offset productCount:productCount];
    }

    tag = [self getRFC3986:tag];
    requestURL = [NSString stringWithFormat:@"%@", self.request_url_products];
    NSString* params = [NSString stringWithFormat:@"filter%%5Blimit%%5D=%d&filter%%5Boffset%%5D=%d&filter%%5Bq%%5D=%@&oauth_consumer_key=%@&oauth_nonce=%@&oauth_signature_method=%@&oauth_timestamp=%@", productCount, offset, tag, self.oauth_consumer_key,[self randomStringWithLength:32],@"HMAC-SHA1",[NSString stringWithFormat:@"%lu", (unsigned long)[NSDate.date timeIntervalSince1970]]];
    
    NSString* urlStr = [NSString stringWithFormat:@"%@", requestURL];
    urlStr = [self getRFC3986:urlStr];
    NSString* paramString = [NSString stringWithFormat:@"%@", params];
    paramString = [self getRFC3986:paramString];
    NSString* algoString = [NSString stringWithFormat:@"GET&%@&%@", urlStr, paramString];
    
    NSString* algoKey;
    if([self.version_string isEqualToString:@"v2"]) {
        algoKey = self.oauth_consumer_secret;
    }else if([self.version_string isEqualToString:@"v3"]) {
        algoKey = [NSString stringWithFormat:@"%@&", self.oauth_consumer_secret];
    }
    NSString* _oauth_signature = [self hmacsha1:algoString key:algoKey];
    params = [NSString stringWithFormat:@"%@&oauth_signature=%@", params, _oauth_signature];
    
    if ([Utility containsString:requestURL substring:@"https"]) {
        params = [NSString stringWithFormat:@"filter%%5Blimit%%5D=%d&filter%%5Boffset%%5D=%d&filter%%5Bq%%5D=%@&consumer_key=%@&consumer_secret=%@", productCount, offset, tag, self.oauth_consumer_key, self.oauth_consumer_secret];
    }
    NSString *finalUrlStr =[NSString stringWithFormat:@"%@?%@",requestURL, params];
    NSURL *nsUrl = [NSURL URLWithString:finalUrlStr];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    ServerData *sData = [[ServerData alloc] init];
    sData._serverUrl = [NSString stringWithFormat:@"%@", self.request_url_products];
    sData._serverRequest = manager;
    sData._serverRequestStatus = kServerRequestStart;
    sData._serverDataId = kFetchMoreProduct;
    [self.serverDatas addObject:sData];
    
    [manager GET:nsUrl.absoluteString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        RLOG(@"\noperation = completed");
        RLOG(@"\nresponseObject = %@",responseObject);
        sData._serverResultDictionary = (NSDictionary *)responseObject;
        sData._serverRequestStatus = kServerRequestSucceed;
        if ([[Addons sharedManager] geoLocation] && [[[Addons sharedManager] geoLocation] isEnabled]) {
            NSMutableArray *products = [[[[DataManager sharedManager] tmDataDoctor] tmJsonHelper] loadProductsDataAndReturn:sData._serverResultDictionary];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NEW_SEARCH_RESULTS" object:products];
        }else{
            [[DataManager sharedManager] loadProductsData:sData._serverResultDictionary];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NEW_SEARCH_RESULTS" object:nil];
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        RLOG(@"\noperation = failed");
        RLOG(@"\nerror = %@", error);
        RLOG(@"\nlocalizedDescription = %@\nlocalizedFailureReason = %@\n", [error localizedDescription], [error localizedFailureReason]);
        NSInteger statusCode = 0;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
        if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = httpResponse.statusCode;
        }
        if(statusCode == 404 || statusCode == 200) {
            sData._serverRequestStatus = kServerRequestFailed;
        } else {
            sData._serverRequestStatus = kServerRequestFailed;
            [self fetchProductsWithTag:nil tag:tag offset:0 productCount:100];
        }
    }];
    return sData;
}
- (ServerData*) fetchProductsByTagUsePlugin:(UIView*)view tag:(NSString*)tag offset:(int)offset productCount:(int)productCount {
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setObject:base64_str(tag) forKey:@"q"];
    [params setObject:base64_int(productCount) forKey:@"limit"];
    [params setObject:base64_int(offset) forKey:@"offset"];
    NSDictionary* parameters = [[NSDictionary alloc] initWithDictionary:params];

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];

    ServerData *sData = [[ServerData alloc] init];
    sData._serverUrl = [NSString stringWithFormat:@"%@", self.request_url_search_products];
    sData._serverRequest = manager;
    sData._serverRequestStatus = kServerRequestStart;
    sData._serverDataId = kFetchMoreProduct;
    [self.serverDatas addObject:sData];

    [manager POST:self.request_url_search_products parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
    } progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        // NSDictionary *dict = [Utility getJsonObject:responseObject];
        sData._serverResultDictionary = [Utility getJsonObject:responseObject];
        sData._serverRequestStatus = kServerRequestSucceed;
        if ([[Addons sharedManager] geoLocation] && [[[Addons sharedManager] geoLocation] isEnabled]) {
            NSMutableArray *products = [[[[DataManager sharedManager] tmDataDoctor] tmJsonHelper] loadProductsDataAndReturn:sData._serverResultDictionary];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NEW_SEARCH_RESULTS" object:products];
        }else{
            NSMutableArray *products  = [[DataManager sharedManager] loadProductsData:sData._serverResultDictionary];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NEW_SEARCH_RESULTS" object:products];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        RLOG(@"\noperation = failed");
        RLOG(@"\nerror = %@", error);
        RLOG(@"\nlocalizedDescription = %@\nlocalizedFailureReason = %@\n", [error localizedDescription], [error localizedFailureReason]);
        NSInteger statusCode = 0;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = httpResponse.statusCode;
        }
        if(statusCode == 404 || statusCode == 200) {
            sData._serverRequestStatus = kServerRequestFailed;
        } else {
            sData._serverRequestStatus = kServerRequestFailed;
            [self fetchProductsWithTag:nil tag:tag offset:0 productCount:100];
        }
    }];
    return sData;
}

- (ServerData*)fetchProductDataForCategory:(UIView*)view
                              categorySlug:(NSString*)categorySlug
                                    offset:(int)offset productCount:(int)productCount
                                   success:(void(^)(id data))success
                                   failure:(void(^)(NSString* error))failure {
    requestURL = [NSString stringWithFormat:@"%@", self.request_url_products];
    NSString* params = [NSString stringWithFormat:@"filter%%5Blimit%%5D=%d&filter%%5Boffset%%5D=%d&filter%%5Bcategory%%5D=%@&oauth_consumer_key=%@&oauth_nonce=%@&oauth_signature_method=%@&oauth_timestamp=%@", productCount, offset, categorySlug, self.oauth_consumer_key,[self randomStringWithLength:32],@"HMAC-SHA1",[NSString stringWithFormat:@"%lu", (unsigned long)[NSDate.date timeIntervalSince1970]]];
    
    NSString* urlStr = [NSString stringWithFormat:@"%@", requestURL];
    urlStr = [self getRFC3986:urlStr];
    NSString* paramString = [NSString stringWithFormat:@"%@", params];
    paramString = [self getRFC3986:paramString];
    NSString* algoString = [NSString stringWithFormat:@"GET&%@&%@", urlStr, paramString];
    
    NSString* algoKey;
    if([self.version_string isEqualToString:@"v2"]) {
        algoKey = self.oauth_consumer_secret;
    }else if([self.version_string isEqualToString:@"v3"]) {
        algoKey = [NSString stringWithFormat:@"%@&", self.oauth_consumer_secret];
    }
    NSString* _oauth_signature = [self hmacsha1:algoString key:algoKey];
    params = [NSString stringWithFormat:@"%@&oauth_signature=%@", params, _oauth_signature];
    
    if ([Utility containsString:requestURL substring:@"https"]) {
        params = [NSString stringWithFormat:@"filter%%5Blimit%%5D=%d&filter%%5Boffset%%5D=%d&filter%%5Bcategory%%5D=%@&consumer_key=%@&consumer_secret=%@", productCount, offset, categorySlug, self.oauth_consumer_key, self.oauth_consumer_secret];
    }
    NSString *finalUrlStr =[NSString stringWithFormat:@"%@?%@",requestURL, params];
    NSURL *nsUrl = [NSURL URLWithString:finalUrlStr];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    ServerData *sData = [[ServerData alloc] init];
    sData._serverUrl = [NSString stringWithFormat:@"%@", self.request_url_products];
    sData._serverRequest = manager;
    sData._serverRequestStatus = kServerRequestStart;
    sData._serverDataId = kFetchMoreProduct;
    [self.serverDatas addObject:sData];
    if (nsUrl == nil) {
        NSLog(@"finalUrlStr = %@", finalUrlStr);
        sData._serverResultDictionary = [[NSDictionary alloc] init];
        sData._serverRequestStatus = kServerRequestSucceed;
        [self.tmMulticastDelegate respondToDelegates:sData];
        success(nil);
        return nil;
    }
    [manager GET:nsUrl.absoluteString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        //        RLOG(@"\noperation = completed");
        //        RLOG(@"\nresponseObject = %@",responseObject);
        
        
        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:responseObject options:0 error:nil];
        NSString * jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        RLOG(@"jsonString: %@", jsonString);
        
        sData._serverResultDictionary = (NSDictionary *)responseObject;
        sData._serverRequestStatus = kServerRequestSucceed;
        [[DataManager sharedManager] loadProductsData:sData._serverResultDictionary];
        [self.tmMulticastDelegate respondToDelegates:sData];
        success(nil);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        RLOG(@"\noperation = failed");
        RLOG(@"\nerror = %@", error);
        RLOG(@"\nlocalizedDescription = %@\nlocalizedFailureReason = %@\n", [error localizedDescription], [error localizedFailureReason]);
        
        NSInteger statusCode = 0;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
        if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = httpResponse.statusCode;
        }
        if(statusCode == 404 || statusCode == 200) {
            sData._serverRequestStatus = kServerRequestFailed;
            [self.tmMulticastDelegate respondToDelegates:sData];
            failure(@"");
        } else {
            sData._serverRequestStatus = kServerRequestFailed;
            [self fetchProductDataForCategory:view categorySlug:categorySlug offset:offset productCount:productCount success:success failure:failure];
        }
        
    }];
    return sData;
}
- (ServerData *)fetchDataFromServer:(NSString *)_urlString dataId:(int)_dataId view:(UIView *)_view maxDataLimit:(int)maxDataLimit{
    return [self fetchDataFromServer:_urlString dataId:_dataId view:_view maxDataLimit:maxDataLimit offset:0];
}


- (ServerData *)fetchDataFromServer:(NSString *)_urlString dataId:(int)_dataId view:(UIView *)_view maxDataLimit:(int)maxDataLimit offset:(int)offset{
    NSURL* nsUrl = [self getNSURL:_urlString isPostMethod:false maxDataLimit:maxDataLimit offset:offset];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    ServerData *sData = [[ServerData alloc] init];
    sData._serverUrl = [NSString stringWithString:_urlString];
    sData._serverRequest = manager;
    sData._serverRequestStatus = kServerRequestStart;
    sData._serverDataId = _dataId;
    [self.serverDatas addObject:sData];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html",@"text/plain", nil];
    
    [manager GET:nsUrl.absoluteString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        RLOG(@"\noperation = completed");
        
        if (responseObject != nil) {
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                RLOG(@"\nresponseObject = %@",responseObject);
                NSData* responseObjectData = [NSJSONSerialization dataWithJSONObject:responseObject options:0 error:nil];
                NSString * responseJsonString = [[NSString alloc] initWithData:responseObjectData encoding:NSUTF8StringEncoding];
                RLOG(@"%@", responseJsonString);
                sData._serverResultDictionary = (NSDictionary *)responseObject;
            } else {
                NSDictionary *dict = [Utility getJsonObject:responseObject];
                RLOG(@"\nresponseObject = %@",dict);
                if (dict) {
                    sData._serverResultDictionary = dict;
                }
            }
            sData._serverRequestStatus = kServerRequestSucceed;
            if (sData._serverDataId == kFetchSingleProduct) {
                ProductInfo* pInfo = [self.tmJsonHelper loadSingleProductData:sData._serverResultDictionary];
                if ([[Addons sharedManager] load_extra_attrib_data] && pInfo._isExtraPriceRetrieved == false) {
                    [self loadExtraAttribData:pInfo success:^(id data) {
                        //here data is already parsed and added in product object before this success callback.
                        [self.tmMulticastDelegate respondToDelegates:sData];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"NOTIFY_PRODUCT_LOADED" object:pInfo];
                    } failure:^(NSString *error) {
                        
                    }];
                } else {
                    [self.tmMulticastDelegate respondToDelegates:sData];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"NOTIFY_PRODUCT_LOADED" object:pInfo];
                }
            }
            else if (sData._serverDataId == kFetchCustomer) {
                [self.tmMulticastDelegate respondToDelegates:sData];
                [self.tmJsonHelper loadCustomerData:sData._serverResultDictionary];
            }
            else {
                [self.tmMulticastDelegate respondToDelegates:sData];
            }
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        RLOG(@"\noperation = failed");
        RLOG(@"\nerror = %@", error);
        RLOG(@"\nlocalizedDescription = %@\nlocalizedFailureReason = %@\n", [error localizedDescription], [error localizedFailureReason]);
        //            NSDictionary* nsDict = [operation userInfo];
        //            ServerData *sData = (ServerData *)[nsDict objectForKey:@"SERVERDATA"];
        
        if (error && error.userInfo) {
            id data = [error.userInfo valueForKey:@"com.alamofire.serialization.response.error.data"];
            if (data) {
                NSDictionary* json_dict = [Utility getJsonObject:data];
                RLOG(@"======failure:%@======",json_dict);
                if (json_dict) {
                    if (IS_NOT_NULL(json_dict, @"errors")) {
                        NSArray* ers = GET_VALUE_OBJECT(json_dict, @"errors");
                        if (ers) {
                            for (NSDictionary* tDict in ers) {
                                if (tDict) {
                                    if (IS_NOT_NULL(tDict, @"message")) {
                                        NSString* message = GET_VALUE_OBJECT(tDict, @"message");
                                        NSLog(@"message = %@", message);
//                                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Localize(@"i_error") message:message delegate:nil cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil];
//                                        [alertView show];
                                        sData.errorStr = message;
                                    }
                                } break;
                            }
                        }
                    }
                }
                sData._serverRequestStatus = kServerRequestFailed;
                
                [self.tmMulticastDelegate respondToDelegates:sData];
                return;
            }
        }
        
        NSInteger statusCode = 0;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
        if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = httpResponse.statusCode;
        }
        
        if(statusCode == 404 || statusCode == 200) {
            sData._serverRequestStatus = kServerRequestFailed;
            [self.tmMulticastDelegate respondToDelegates:sData];
        } else if (statusCode == -1016){
            sData._serverRequestStatus = kServerRequestFailed;
            //                [self.tmMulticastDelegate respondToDelegates:sData];
        } else {
            sData._serverRequestStatus = kServerRequestFailed;
            [self fetchDataFromServer:_urlString dataId:_dataId view:_view maxDataLimit:maxDataLimit offset:offset];
        }
    }];
    return sData;
}
- (ServerData*)fetchCommonData:(UIView*)view {
    return [self fetchDataFromServer:self.request_url_common dataId:kFetchCommonData view:view maxDataLimit:100];
}
- (ServerData*)fetchCategoriesData:(UIView*)view {
    return [self fetchDataFromServer:self.request_url_categories dataId:kFetchCategories view:view maxDataLimit:[[DataManager sharedManager] maxCategoryLoadCount]];
}
- (ServerData*)fetchProductData:(UIView*)view {
    return [self fetchDataFromServer:self.request_url_products dataId:kFetchProducts view:view maxDataLimit:[[DataManager sharedManager] maxProductLoadCount]];
}
- (ServerData*)fetchCustomerData:(UIView*)view userEmail:(NSString*)userEmail {
    return [self fetchDataFromServer:
            [NSString stringWithFormat:@"%@/email/%@", self.request_url_customer, userEmail] dataId:kFetchCustomer view:view maxDataLimit:100];
}
- (ServerData*)fetchOrdersData:(UIView*)view {
    AppUser* au = [AppUser sharedManager];
    return [self fetchDataFromServer:[NSString stringWithFormat:@"%@/%d/orders", self.request_url_all_orders, au._id] dataId:kFetchOrders view:view maxDataLimit:100];
}
- (ServerData*)fetchSingleProductData:(UIView*)view productId:(int)productId {
    return [self fetchDataFromServer:[NSString stringWithFormat:@"%@/%d", self.request_url_singleProduct, productId] dataId:kFetchSingleProduct view:view maxDataLimit:1];
}
- (ServerData*)fetchSingleProductDataReviews:(UIView*)view productId:(int)productId {
    return nil;
    return [self fetchDataFromServer:[NSString stringWithFormat:@"%@/%d/reviews", self.request_url_singleProduct, productId] dataId:kFetchSingleProductReview view:view maxDataLimit:1];
}
- (void)fetchMultipleShippingAddress:(void(^)(id responseObj))success
                    failure:(void(^)(NSString* errorString))failure {
    AppUser* appUser = [AppUser sharedManager];
    if (appUser._id == -1) {
        success(nil);
        return;
    }
    MRProgressOverlayView* mov = [Utility createCustomizedLoadingBar:[NSString stringWithFormat:@"%@..",Localize(@"Fetching Shipping Address")] isBottomAlign:false isClearViewEnabled:false isShadowEnabled:true];
    NSString* requestUrl = [NSString stringWithFormat:@"%@/wp-tm-ext-store-notify/api/multiple_shipping_address", self.baseUrl];
    NSDictionary *params = @{
                             @"type":base64_str(@"view"),
                             @"user_id":base64_int(appUser._id)
                             };
    RLOG(@"requestUrl: %@", requestUrl);
    RLOG(@"params: %@", params);
    AFHTTPSessionManager *manager =  [self getHttpSessionManagerForPost:@"text/html"];
    [manager POST:requestUrl
       parameters:params
constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {}
         progress:^(NSProgress * _Nonnull uploadProgress) { }
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
              NSDictionary *json = [Utility getJsonObject:responseObject];
              NSArray *array = [Utility getJsonArray:responseObject];
              if (array) {
                  RLOG(@"array: %@", array);
                  [self.tmJsonHelper parseMultipleShippingAddresses:array];
                  success(array);
                  return;
              }
              if (json) {
                  RLOG(@"json: %@", json);
                  NSString* statusStr = [json valueForKey:@"status"];
                  NSString* messageStr = [json valueForKey:@"message"];
                  if ([[statusStr lowercaseString] isEqualToString:@"success"]) {
                      RLOG(@"success");
                      success(messageStr);
                      return;
                  }
                  RLOG(@"failure");
                  failure(messageStr);
              }
              RLOG(@"failure");
              failure(@"failure");
          }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
              RLOG(@"failure");
              failure(@"failure");
          }
     ];
    
}
- (void)updateMultipleShippingAddress:(NSMutableDictionary*)addressJson
                              success:(void(^)(id responseObj))success
                              failure:(void(^)(NSString* errorString))failure {
    AppUser* appUser = [AppUser sharedManager];
    if (appUser._id == -1) {
        success(nil);
        return;
    }
//    MRProgressOverlayView* mov = [Utility createCustomizedLoadingBar:[NSString stringWithFormat:@"%@..",Localize(@"Updating Shipping Address")] isBottomAlign:false isClearViewEnabled:false isShadowEnabled:true];
    NSString* requestUrl = [NSString stringWithFormat:@"%@/wp-tm-ext-store-notify/api/multiple_shipping_address", self.baseUrl];
    NSDictionary *params = @{
                             @"type":base64_str(@"update"),
                             @"user_id":base64_int(appUser._id),
                             @"address":base64_str([MapAddress getFinalJsonString])
                             };
    RLOG(@"requestUrl: %@", requestUrl);
    RLOG(@"params: %@", params);
    AFHTTPSessionManager *manager =  [self getHttpSessionManagerForPost:@"text/html"];
    [manager POST:requestUrl
       parameters:params
constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {}
         progress:^(NSProgress * _Nonnull uploadProgress) { }
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//              [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
              NSDictionary *json = [Utility getJsonObject:responseObject];
              NSArray *array = [Utility getJsonArray:responseObject];
              if (array) {
                  RLOG(@"array: %@", array);
                  success(array);
                  return;
              }
              if (json) {
                  RLOG(@"json: %@", json);
                  NSString* statusStr = [json valueForKey:@"status"];
                  NSString* messageStr = [json valueForKey:@"message"];
                  if ([[statusStr lowercaseString] isEqualToString:@"success"]) {
                      RLOG(@"success");
                      success(messageStr);
                      return;
                  }
                  RLOG(@"failure");
                  failure(messageStr);
              }
              RLOG(@"failure");
              failure(@"failure");
          }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//              [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
              RLOG(@"failure");
              failure(@"failure");
          }
     ];
}

- (void)fetchProductFromServer:(int)productId
                               success:(void(^)(id responseObj))success
                               failure:(void(^)(NSString* errorString))failure {
    NSURL* nsUrl = [self getNSURL:[NSString stringWithFormat:@"%@/%d", self.request_url_singleProduct, productId] isPostMethod:false maxDataLimit:1 offset:0];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html",@"text/plain", nil];
    [manager GET:nsUrl.absoluteString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        RLOG(@"\noperation = completed");
        if (responseObject != nil) {
            NSDictionary* productJson = nil;
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                RLOG(@"\nresponseObject = %@",responseObject);
                NSData* responseObjectData = [NSJSONSerialization dataWithJSONObject:responseObject options:0 error:nil];
                NSString * responseJsonString = [[NSString alloc] initWithData:responseObjectData encoding:NSUTF8StringEncoding];
                RLOG(@"%@", responseJsonString);
                productJson = (NSDictionary *)responseObject;
            }
            else {
                NSDictionary *dict = [Utility getJsonObject:responseObject];
                RLOG(@"\nresponseObject = %@",dict);
                if (dict) {
                    productJson = dict;
                }
            }
            if (productJson) {
                ProductInfo* pInfo = [self.tmJsonHelper loadSingleProductData:productJson];
                if ([[Addons sharedManager] load_extra_attrib_data] && pInfo._isExtraPriceRetrieved == false) {
                    [self loadExtraAttribData:pInfo success:^(id data) {
                        //here data is already parsed and added in product object before this success callback.
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"NOTIFY_PRODUCT_LOADED" object:pInfo];
                        success(pInfo);
                        return;
                    } failure:^(NSString *error) {
                        failure(@"failure");
                    }];
                } else {
                    success(pInfo);
                    return;
                }
            }
            failure(@"failure");
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        failure(@"failure");
    }];
}
#pragma mark Post Data to Woocommerce

- (AFHTTPSessionManager*) getHttpSessionManagerForPost:(NSString*)contentType {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:contentType];
    return manager;
}
- (AFHTTPSessionManager *)initializeRequestManagerForPostMethod {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html",@"text/plain", nil];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:[[Utility sharedManager] getUserAgent] forHTTPHeaderField:@"User-Agent"];
    
    
    //    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    //    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    //    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    //    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    //    [manager.requestSerializer setValue:[[Utility sharedManager] getUserAgent] forHTTPHeaderField:@"User-Agent"];
    //    manager.securityPolicy.allowInvalidCertificates = YES;
    //    manager.securityPolicy.validatesDomainName = NO;
    //    [manager.requestSerializer setTimeoutInterval:30];
    return manager;
}
- (NSString *)initializeRequestStringForDeleteMethod:(NSString*)requestedUrl {
    RLOG(@"%@",requestedUrl);
    requestURL = [NSString stringWithString:requestedUrl];
    NSString* params = [NSString stringWithFormat:@"oauth_consumer_key=%@&oauth_nonce=%@&oauth_signature_method=%@&oauth_timestamp=%@", self.oauth_consumer_key,[self randomStringWithLength:32],@"HMAC-SHA1",[NSString stringWithFormat:@"%lu", (unsigned long)[NSDate.date timeIntervalSince1970]]];
    NSString* urlStr = [NSString stringWithFormat:@"%@", requestURL];
    urlStr = [self getRFC3986:urlStr];
    NSString* paramString = [NSString stringWithFormat:@"%@", params];
    paramString = [self getRFC3986:paramString];
    NSString* algoString = [NSString stringWithFormat:@"DELETE&%@&%@", urlStr, paramString];
    
    NSString* algoKey;
    if([self.version_string isEqualToString:@"v2"]) {
        algoKey = self.oauth_consumer_secret;
    }else if([self.version_string isEqualToString:@"v3"]) {
        algoKey = [NSString stringWithFormat:@"%@&", self.oauth_consumer_secret];
    }
    NSString* _oauth_signature = [self hmacsha1:algoString key:algoKey];
    params = [NSString stringWithFormat:@"%@&oauth_signature=%@", params, _oauth_signature];
    //    if ([Utility containsString:requestURL substring:@"https"]) {
    //        params = [NSString stringWithFormat:@"filter%%5Blimit%%5D=%d&consumer_key=%@&consumer_secret=%@", maxDataLimit, self.oauth_consumer_key, self.oauth_consumer_secret];
    //    }
    if ([Utility containsString:requestURL substring:@"https"]) {
        params = [NSString stringWithFormat:@"filter%%5Blimit%%5D=%d&consumer_key=%@&consumer_secret=%@", 100, self.oauth_consumer_key, self.oauth_consumer_secret];
    }
    NSString *finalUrlStr = [NSString stringWithFormat:@"%@?%@",requestURL, params];
    RLOG(@"finalUrlStr = %@", finalUrlStr);
    return finalUrlStr;
}
- (NSString *)initializeRequestStringForPostMethod:(NSString*)requestedUrl {
    RLOG(@"%@",requestedUrl);
    requestURL = [NSString stringWithString:requestedUrl];
    NSString* params = [NSString stringWithFormat:@"oauth_consumer_key=%@&oauth_nonce=%@&oauth_signature_method=%@&oauth_timestamp=%@", self.oauth_consumer_key,[self randomStringWithLength:32],@"HMAC-SHA1",[NSString stringWithFormat:@"%lu", (unsigned long)[NSDate.date timeIntervalSince1970]]];
    NSString* urlStr = [NSString stringWithFormat:@"%@", requestURL];
    urlStr = [self getRFC3986:urlStr];
    NSString* paramString = [NSString stringWithFormat:@"%@", params];
    paramString = [self getRFC3986:paramString];
    NSString* algoString = [NSString stringWithFormat:@"POST&%@&%@", urlStr, paramString];
    
    NSString* algoKey;
    if([self.version_string isEqualToString:@"v2"]) {
        algoKey = self.oauth_consumer_secret;
    }else if([self.version_string isEqualToString:@"v3"]) {
        algoKey = [NSString stringWithFormat:@"%@&", self.oauth_consumer_secret];
    }
    NSString* _oauth_signature = [self hmacsha1:algoString key:algoKey];
    params = [NSString stringWithFormat:@"%@&oauth_signature=%@", params, _oauth_signature];
    //    if ([Utility containsString:requestURL substring:@"https"]) {
    //        params = [NSString stringWithFormat:@"filter%%5Blimit%%5D=%d&consumer_key=%@&consumer_secret=%@", maxDataLimit, self.oauth_consumer_key, self.oauth_consumer_secret];
    //    }
    if ([Utility containsString:requestURL substring:@"https"]) {
        params = [NSString stringWithFormat:@"filter%%5Blimit%%5D=%d&consumer_key=%@&consumer_secret=%@", 100, self.oauth_consumer_key, self.oauth_consumer_secret];
    }
    NSString *finalUrlStr = [NSString stringWithFormat:@"%@?%@",requestURL, params];
    RLOG(@"finalUrlStr = %@", finalUrlStr);
    return finalUrlStr;
}
- (void)createBlankOrder:(NSMutableArray*)selectedShippingMethods paymentGateway:(TMPaymentGateway*)paymentGateway {
    MRProgressOverlayView* mov = [Utility createCustomizedLoadingBar:Localize(@"i_creating_order") isBottomAlign:false isClearViewEnabled:false isShadowEnabled:true];
    //    TMShipping* shippingMethod = nil;
    //    if (selectedShippingMethods && [selectedShippingMethods count] == 1) {
    //        shippingMethod = (TMShipping*)[selectedShippingMethods objectAtIndex:0];
    //    }
    
    NSDictionary* postParams = [[NSDictionary alloc] initWithDictionary:[self prepareBlankOrder:selectedShippingMethods paymentGateway:paymentGateway]];
    NSString* requestUrl = [NSString stringWithFormat:@"%@", [[[DataManager sharedManager] tmDataDoctor] request_url_orders]];
    NSString* URLString = [self initializeRequestStringForPostMethod:requestUrl];
    AFHTTPSessionManager* manager = [self initializeRequestManagerForPostMethod];
    RLOG(@"createBlankOrder_postParams=\n%@",postParams);
    RLOG(@"createBlankOrder_URLString=\n%@",URLString);
    RLOG(@"createBlankOrder_note=\n%@",[Cart getOrderNote]);
    [manager POST:URLString parameters:postParams progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
        NSDictionary *dict = nil;
        if (responseObject) {
            dict = [Utility getJsonObject:responseObject];
            RLOG(@"\n==ResponseObject = %@\n\n", dict);
        }
        
        if (dict) {
            dict = (NSDictionary*)[dict objectForKey:@"order"];
            Order* order = [self.tmJsonHelper parseOrderJson:dict];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"BLANK_ORDER_SUCCESS" object:order];
        } else {
            RLOG(@"BLANK_ORDER_FAILURE");
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Localize(@"i_error") message:Localize(@"try_again") delegate:nil cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil];
            [alertView show];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"BLANK_ORDER_FAILURE" object:nil];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        RLOG(@"\n==Error = %@\n\n", error);
        
        id data = [error.userInfo valueForKey:@"com.alamofire.serialization.response.error.data"];
        NSDictionary* json_dict = [Utility getJsonObject:data];
        if (json_dict) {
            NSString* errorStr = [json_dict valueForKey:@"error"];
            NSString* messageStr = [json_dict valueForKey:@"message"];
            NSString* statusStr = [json_dict valueForKey:@"status"];
            RLOG(@"messageStr: %@", messageStr);
            if (statusStr && [[statusStr lowercaseString] isEqualToString:@"success"]) {
            
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Localize(@"i_error") message:messageStr delegate:nil cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:Localize(@"retry"), nil];
                [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    if (buttonIndex == 1) {
                        [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
                        [self createBlankOrder:selectedShippingMethods paymentGateway:paymentGateway];
                    } else {
                        [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"BLANK_ORDER_FAILURE" object:nil];
                    }
                }];
                return;
            }
        }
        
        NSInteger statusCode = 0;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = httpResponse.statusCode;
        }
        if(statusCode == 404 || statusCode == 200) {
            [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
            RLOG(@"BLANK_ORDER_FAILURE");
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Localize(@"oops") message:Localize(@"generic_error") delegate:nil cancelButtonTitle:Localize(@"cancel") otherButtonTitles:Localize(@"retry"), nil];;
            [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if ((int)buttonIndex == 0) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"BLANK_ORDER_FAILURE" object:nil];
                } else {
                    [self createBlankOrder:selectedShippingMethods paymentGateway:paymentGateway];
                }
            }];
        } else {
            [self createBlankOrder:selectedShippingMethods paymentGateway:paymentGateway];
        }
    }];
}
- (void)createBlankOrder:(NSMutableArray*)selectedShippingMethods
          paymentGateway:(TMPaymentGateway*)paymentGateway
                 success:(void(^)(id data))success
                 failure:(void(^)(NSString* error))failure {
    MRProgressOverlayView* mov = [Utility createCustomizedLoadingBar:Localize(@"i_creating_order") isBottomAlign:false isClearViewEnabled:false isShadowEnabled:true];
    //    TMShipping* shippingMethod = nil;
    //    if (selectedShippingMethods && [selectedShippingMethods count] == 1) {
    //        shippingMethod = (TMShipping*)[selectedShippingMethods objectAtIndex:0];
    //    }
    NSDictionary* postParams = [[NSDictionary alloc] initWithDictionary:[self prepareBlankOrder:selectedShippingMethods paymentGateway:paymentGateway]];
    NSString* requestUrl = [NSString stringWithFormat:@"%@", [[[DataManager sharedManager] tmDataDoctor] request_url_orders]];
    NSString* URLString = [self initializeRequestStringForPostMethod:requestUrl];
    AFHTTPSessionManager* manager = [self initializeRequestManagerForPostMethod];
    RLOG(@"createBlankOrder_postParams=\n%@",postParams);
    RLOG(@"createBlankOrder_URLString=\n%@",URLString);
    RLOG(@"createBlankOrder_note=\n%@",[Cart getOrderNote]);
    [manager POST:URLString parameters:postParams progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
        NSDictionary *dict = nil;
        if (responseObject) {
            dict = [Utility getJsonObject:responseObject];
            RLOG(@"\n==ResponseObject = %@\n\n", dict);
        }
        if (dict) {
            dict = (NSDictionary*)[dict objectForKey:@"order"];
            Order* order = [self.tmJsonHelper parseOrderJson:dict];
            success(order);
        } else {
            RLOG(@"BLANK_ORDER_FAILURE");
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Localize(@"i_error") message:Localize(@"try_again") delegate:nil cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil];
            [alertView show];
            failure(@"failure");
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:NO];
        RLOG(@"\n==Error = %@\n\n", error);
        NSInteger statusCode = 0;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = httpResponse.statusCode;
        }
        if(statusCode == 404 || statusCode == 200) {
            RLOG(@"BLANK_ORDER_FAILURE");
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Localize(@"oops") message:Localize(@"generic_error") delegate:nil cancelButtonTitle:Localize(@"cancel") otherButtonTitles:Localize(@"retry"), nil];;
            [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if ((int)buttonIndex == 0) {
                    failure(@"failure");
                } else {
                    failure(@"retry");
                }
            }];
        } else {
            failure(@"retry");
        }
    }];
}

- (void)updateBlankOrderWithOrderId:(int)orderId
                     shippingMethod:(TMShipping*)shippingMethod
                            success:(void(^)(id data))success
                            failure:(void(^)(NSString* error))failure {
    [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:NO];
    MRProgressOverlayView* mov = [Utility createCustomizedLoadingBar:Localize(@"Refresh order") isBottomAlign:false isClearViewEnabled:false isShadowEnabled:true];
    [mov.titleLabel setUIFont:kUIFontType18 isBold:false];
    
    NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
    {
        NSMutableDictionary* order = [[NSMutableDictionary alloc] init];
        {
            {
                NSMutableArray *shippingLine = [[NSMutableArray alloc] init];
                if (shippingMethod != nil) {
                    [order setObject:shippingLine forKey:@"shipping_lines"];
                    NSMutableDictionary *shippingMthd = [[NSMutableDictionary alloc] init];
                    [shippingLine addObject:shippingMthd];
                    
                    [shippingMthd setObject:shippingMethod.shippingMethodId forKey:@"method_id"];
                    [shippingMthd setObject:shippingMethod.shippingLabel forKey:@"method_title"];
                    [shippingMthd setObject:[NSNumber numberWithFloat:shippingMethod.shippingCost] forKey:@"total"];
                }
            }
        }
        [data setObject:order forKey:@"order"];
    }
    NSData * updateOrderJsonData = [NSJSONSerialization dataWithJSONObject:data options:0 error:nil];
    NSString * updateOrderJsonString = [[NSString alloc] initWithData:updateOrderJsonData encoding:NSUTF8StringEncoding];
    RLOG(@"====updateOrderJsonString:\n%@\n====", updateOrderJsonString);
    NSDictionary* postParams = [[NSDictionary alloc]initWithDictionary:data];
    NSString* requestUrl = [NSString stringWithFormat:@"%@/%d", [[[DataManager sharedManager] tmDataDoctor] request_url_orders], orderId];
    NSString* URLString = [self initializeRequestStringForPostMethod:requestUrl];
    AFHTTPSessionManager* manager = [self initializeRequestManagerForPostMethod];
    RLOG(@"====URLString:\n%@\n====", URLString);
    [manager POST:URLString parameters:postParams progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
        NSDictionary *dict = nil;
        if (responseObject) {
            dict = [Utility getJsonObject:responseObject];
            RLOG(@"\n==ResponseObject = %@\n\n", dict);
        }
        if (dict) {
            dict = (NSDictionary*)[dict objectForKey:@"order"];
            Order* updatedOrder = [self.tmJsonHelper parseOrderJson:dict];
            success(updatedOrder);
        } else {
            RLOG(@"UPDATE_BLANK_ORDER_FAILURE");
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Localize(@"i_error") message:Localize(@"try_again") delegate:nil cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil];
            [alertView show];
            failure(@"failure");
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:NO];
        NSInteger statusCode = 0;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = httpResponse.statusCode;
        }
        if(statusCode == 404 || statusCode == 200) {
            RLOG(@"UPDATE_BLANK_ORDER_FAILURE");
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Localize(@"oops") message:Localize(@"generic_error") delegate:nil cancelButtonTitle:Localize(@"cancel") otherButtonTitles:Localize(@"retry"), nil];;
            [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if ((int)buttonIndex == 0) {
                    failure(@"failure");
                } else {
                    failure(@"retry");
                }
            }];
        } else {
            failure(@"retry");
        }
    }];
}
- (void)updateOrderWithOrderId:(int)orderId
                paymentGateway:(TMPaymentGateway*)paymentGateway
                        isPaid:(BOOL)isPaid
                   orderStatus:(NSString*)orderStatus
                       success:(void(^)(id data))success
                       failure:(void(^)(NSString* error))failure {
    if (_overlayUpdateOrderAfterPurchase == nil) {
        [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:NO];
    }
    MRProgressOverlayView* mov;
    if([orderStatus isEqualToString:@"cancelled"]) {
        [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:NO];
        mov = [Utility createCustomizedLoadingBar:Localize(@"i_cancelling_order") isBottomAlign:false isClearViewEnabled:false isShadowEnabled:true];
    } else {
        if (_overlayUpdateOrderAfterPurchase == nil) {
            [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:NO];
            mov = [Utility createCustomizedLoadingBar:Localize(@"updating_order") isBottomAlign:false isClearViewEnabled:false isShadowEnabled:true];
            _overlayUpdateOrderAfterPurchase = mov;
        }else{
            mov = _overlayUpdateOrderAfterPurchase;
        }
    }
    [mov.titleLabel setUIFont:kUIFontType18 isBold:false];
    
    NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
    {
        NSMutableDictionary* order = [[NSMutableDictionary alloc] init];
        {
            [order setObject:orderStatus forKey:@"status"];
            if (paymentGateway) {
                NSMutableDictionary* payment_details = [[NSMutableDictionary alloc] init];
                {
                    [payment_details setObject:paymentGateway.paymentId forKey:@"method_id"];
                    [payment_details setObject:paymentGateway.paymentTitle forKey:@"method_title"];
                    [payment_details setObject:[NSNumber numberWithBool:paymentGateway.isPrepaid] forKey:@"paid"];
                }
                [order setObject:payment_details forKey:@"payment_details"];
                [order setObject:[NSNumber numberWithBool:paymentGateway.isPrepaid] forKey:@"set_paid"];
            }
        }
        [data setObject:order forKey:@"order"];
    }
    NSData * updateOrderJsonData = [NSJSONSerialization dataWithJSONObject:data options:0 error:nil];
    NSString * updateOrderJsonString = [[NSString alloc] initWithData:updateOrderJsonData encoding:NSUTF8StringEncoding];
    RLOG(@"====updateOrderJsonString:\n%@\n====", updateOrderJsonString);
    NSDictionary* postParams = [[NSDictionary alloc]initWithDictionary:data];
    NSString* requestUrl = [NSString stringWithFormat:@"%@/%d", [[[DataManager sharedManager] tmDataDoctor] request_url_orders], orderId];
    NSString* URLString = [self initializeRequestStringForPostMethod:requestUrl];
    AFHTTPSessionManager* manager = [self initializeRequestManagerForPostMethod];
    RLOG(@"====URLString:\n%@\n====", URLString);
    [manager POST:URLString parameters:postParams progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
        
        NSDictionary *dict = nil;
        if (responseObject) {
            dict = [Utility getJsonObject:responseObject];
            RLOG(@"\n==ResponseObject = %@\n\n", dict);
        }
        if (dict) {
            dict = (NSDictionary*)[dict objectForKey:@"order"];
            Order* updatedOrder = [self.tmJsonHelper parseOrderJson:dict];
            AppUser* au = [AppUser sharedManager];
            for (Order* order in au._ordersArray) {
                if(order._id == updatedOrder._id){
                    [self.tmJsonHelper parseOrderJsonWithOrderObject:dict order:order];
                    break;
                }
            }
            success(updatedOrder);
            _overlayUpdateOrderAfterPurchase = nil;
        }
        else {
            RLOG(@"\n==ResponseObject is null");
            RLOG(@"UPDATE_ORDER_FAILURE");
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Localize(@"i_error") message:Localize(@"try_again") delegate:nil cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil];
            [alertView show];
            failure(@"failure");
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSInteger statusCode = 0;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = httpResponse.statusCode;
        }
        if(statusCode == 404 || statusCode == 200) {
            [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:NO];
            RLOG(@"UPDATE_ORDER_FAILURE");
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Localize(@"oops") message:Localize(@"generic_error") delegate:nil cancelButtonTitle:Localize(@"cancel") otherButtonTitles:Localize(@"retry"), nil];;
            [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if ((int)buttonIndex == 0) {
                    failure(@"failure");
                } else {
                    failure(@"retry");
                }
            }];
        } else {
            failure(@"retry");
        }
    }];
}
- (void)updateOrder:(TMPaymentGateway*)paymentGateway orderId:(int)orderId orderStatus:(NSString*)orderStatus isPaid:(BOOL)isPaid {
    MRProgressOverlayView* mov;
    mov = [Utility createCustomizedLoadingBar:Localize(@"updating_order") isBottomAlign:false isClearViewEnabled:false isShadowEnabled:true];
    mov = _overlayUpdateOrderAfterPurchase;
    
    [mov.titleLabel setUIFont:kUIFontType18 isBold:false];
    
    NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
    {
        NSMutableDictionary* order = [[NSMutableDictionary alloc] init];
        {
            [order setObject:orderStatus forKey:@"status"];
            if (paymentGateway) {
                NSMutableDictionary* payment_details = [[NSMutableDictionary alloc] init];
                {
                    [payment_details setObject:paymentGateway.paymentId forKey:@"method_id"];
                    [payment_details setObject:paymentGateway.paymentTitle forKey:@"method_title"];
                    [payment_details setObject:[NSNumber numberWithBool:paymentGateway.isPrepaid] forKey:@"paid"];
                }
                [order setObject:payment_details forKey:@"payment_details"];
                [order setObject:[NSNumber numberWithBool:paymentGateway.isPrepaid] forKey:@"set_paid"];
            }
        }
        [data setObject:order forKey:@"order"];
    }
    NSData * updateOrderJsonData = [NSJSONSerialization dataWithJSONObject:data options:0 error:nil];
    NSString * updateOrderJsonString = [[NSString alloc] initWithData:updateOrderJsonData encoding:NSUTF8StringEncoding];
    RLOG(@"====updateOrderJsonString:\n%@\n====", updateOrderJsonString);
    NSDictionary* postParams = [[NSDictionary alloc]initWithDictionary:data];
    NSString* requestUrl = [NSString stringWithFormat:@"%@/%d", [[[DataManager sharedManager] tmDataDoctor] request_url_orders], orderId];
    NSString* URLString = [self initializeRequestStringForPostMethod:requestUrl];
    AFHTTPSessionManager* manager = [self initializeRequestManagerForPostMethod];
    RLOG(@"====URLString:\n%@\n====", URLString);
    [manager POST:URLString parameters:postParams progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
        
        NSDictionary *dict = nil;
        if (responseObject) {
            dict = [Utility getJsonObject:responseObject];
            RLOG(@"\n==ResponseObject = %@\n\n", dict);
        }
        if (dict) {
            dict = (NSDictionary*)[dict objectForKey:@"order"];
            Order* updatedOrder = [self.tmJsonHelper parseOrderJson:dict];
            AppUser* au = [AppUser sharedManager];
            for (Order* order in au._ordersArray) {
                if(order._id == updatedOrder._id){
                    [self.tmJsonHelper parseOrderJsonWithOrderObject:dict order:order];
                    break;
                }
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATE_ORDER_SUCCESS" object:nil];
            _overlayUpdateOrderAfterPurchase = nil;
        }
        else {
            RLOG(@"\n==ResponseObject is null");
            RLOG(@"UPDATE_ORDER_FAILURE");
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Localize(@"i_error") message:Localize(@"try_again") delegate:nil cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil];
            [alertView show];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATE_ORDER_FAILURE" object:nil];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSInteger statusCode = 0;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = httpResponse.statusCode;
        }
        if(statusCode == 404 || statusCode == 200) {
            [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:NO];
            RLOG(@"UPDATE_ORDER_FAILURE");
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Localize(@"oops") message:Localize(@"generic_error") delegate:nil cancelButtonTitle:Localize(@"cancel") otherButtonTitles:Localize(@"retry"), nil];;
            [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if ((int)buttonIndex == 0) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATE_ORDER_FAILURE" object:nil];
                } else {
                    [self updateOrder:paymentGateway orderId:orderId orderStatus:orderStatus isPaid:isPaid];
                }
            }];
        } else {
            [self updateOrder:paymentGateway orderId:orderId orderStatus:orderStatus isPaid:isPaid];
        }
    }];
}
- (void)updateCustomerData:(void(^)(id data))success
                          failure:(void(^)(NSString* error))failure  {
    if ([[AppUser sharedManager] _isUserLoggedIn] == false && [[GuestConfig sharedInstance] guest_checkout]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Localize(@"i_success") message:Localize(@"i_customer_data_updated") delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
        [alertView show];
        [self performSelector:@selector(dismissAlert:) withObject:alertView afterDelay:1.0f];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"addressUpdatedSuccess" object:nil];
        return;
    }
    AppUser* appUser = [AppUser sharedManager];
    Address* billingAddress = appUser._billing_address;
    Address* shippingAddress = appUser._shipping_address;
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    NSMutableDictionary *subParams = [[NSMutableDictionary alloc]init];
    [params setObject:subParams forKey:@"customer"];
    //    [subParams setObject:appUser._email forKey:@"email"];
    [subParams setObject:appUser._first_name forKey:@"first_name"];
    [subParams setObject:appUser._last_name forKey:@"last_name"];
    //    [subParams setObject:appUser._username forKey:@"username"];
    if (billingAddress) {
        NSMutableDictionary *billingParams = [[NSMutableDictionary alloc]init];
        [subParams setObject:billingParams forKey:@"billing_address"];
        [billingParams setObject:billingAddress._first_name forKey:@"first_name"];
        [billingParams setObject:billingAddress._last_name forKey:@"last_name"];
        //        [billingParams setObject:billingAddress._company forKey:@"company"];
        [billingParams setObject:billingAddress._address_1 forKey:@"address_1"];
        [billingParams setObject:billingAddress._address_2 forKey:@"address_2"];
        [billingParams setObject:billingAddress._city forKey:@"city"];
        [billingParams setObject:billingAddress._postcode forKey:@"postcode"];
        [billingParams setObject:billingAddress._email forKey:@"email"];
        [billingParams setObject:billingAddress._phone forKey:@"phone"];
        [billingParams setObject:billingAddress._stateId forKey:@"state"];
        [billingParams setObject:billingAddress._countryId forKey:@"country"];
    }
    if (shippingAddress) {
        NSMutableDictionary *shippingParams = [[NSMutableDictionary alloc]init];
        [subParams setObject:shippingParams forKey:@"shipping_address"];
        [shippingParams setObject:shippingAddress._first_name forKey:@"first_name"];
        [shippingParams setObject:shippingAddress._last_name forKey:@"last_name"];
        //        [shippingParams setObject:billingAddress._company forKey:@"company"];
        [shippingParams setObject:shippingAddress._address_1 forKey:@"address_1"];
        [shippingParams setObject:shippingAddress._address_2 forKey:@"address_2"];
        [shippingParams setObject:shippingAddress._city forKey:@"city"];
        [shippingParams setObject:shippingAddress._postcode forKey:@"postcode"];
        [shippingParams setObject:shippingAddress._stateId forKey:@"state"];
        [shippingParams setObject:shippingAddress._countryId forKey:@"country"];
    }
    NSString* requestUrl = [NSString stringWithFormat:@"%@/%d", [[[DataManager sharedManager] tmDataDoctor] request_url_update_customer], appUser._id];
    NSString* URLString = [self initializeRequestStringForPostMethod:requestUrl];
    NSDictionary *postParams = [[NSDictionary alloc]initWithDictionary:params];
    AFHTTPSessionManager* manager = [self initializeRequestManagerForPostMethod];
    [manager POST:URLString parameters:postParams progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        RLOG(@"success!");
        NSDictionary *dict = nil;
        if (responseObject) {
            dict = [Utility getJsonObject:responseObject];
            RLOG(@"\n==ResponseObject = %@\n\n", dict);
        }
        if (dict) {
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Localize(@"i_success") message:Localize(@"i_customer_data_updated") delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
//            [alertView show];
//            [self performSelector:@selector(dismissAlert:) withObject:alertView afterDelay:1.0f];
            success(dict);
            return;
        }
        failure(@"failure");
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        RLOG(@"error: %@", error);
        RLOG(@"\n==Error = %@\n\n", error);
        failure(@"failure");
    }];
}
- (void)updateCustomerData {
    [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
    if ([[AppUser sharedManager] _isUserLoggedIn] == false && [[GuestConfig sharedInstance] guest_checkout]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Localize(@"i_success") message:Localize(@"i_customer_data_updated") delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
        [alertView show];
        [self performSelector:@selector(dismissAlert:) withObject:alertView afterDelay:1.0f];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"addressUpdatedSuccess" object:nil];
        return;
    }
    
    [MRProgressOverlayView showOverlayAddedTo:[[UIApplication sharedApplication] keyWindow] title:@"" mode:MRProgressOverlayViewModeIndeterminateSmallDefault animated:YES];
    
    AppUser* appUser = [AppUser sharedManager];
    Address* billingAddress = appUser._billing_address;
    Address* shippingAddress = appUser._shipping_address;
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    NSMutableDictionary *subParams = [[NSMutableDictionary alloc]init];
    [params setObject:subParams forKey:@"customer"];
    //    [subParams setObject:appUser._email forKey:@"email"];
    [subParams setObject:appUser._first_name forKey:@"first_name"];
    [subParams setObject:appUser._last_name forKey:@"last_name"];
    //    [subParams setObject:appUser._username forKey:@"username"];
    if (billingAddress) {
        NSMutableDictionary *billingParams = [[NSMutableDictionary alloc]init];
        [subParams setObject:billingParams forKey:@"billing_address"];
        [billingParams setObject:billingAddress._first_name forKey:@"first_name"];
        [billingParams setObject:billingAddress._last_name forKey:@"last_name"];
        //        [billingParams setObject:billingAddress._company forKey:@"company"];
        [billingParams setObject:billingAddress._address_1 forKey:@"address_1"];
        [billingParams setObject:billingAddress._address_2 forKey:@"address_2"];
        [billingParams setObject:billingAddress._city forKey:@"city"];
        [billingParams setObject:billingAddress._postcode forKey:@"postcode"];
        [billingParams setObject:billingAddress._email forKey:@"email"];
        [billingParams setObject:billingAddress._phone forKey:@"phone"];
        [billingParams setObject:billingAddress._stateId forKey:@"state"];
        [billingParams setObject:billingAddress._countryId forKey:@"country"];
    }
    
    if (shippingAddress) {
        NSMutableDictionary *shippingParams = [[NSMutableDictionary alloc]init];
        [subParams setObject:shippingParams forKey:@"shipping_address"];
        [shippingParams setObject:shippingAddress._first_name forKey:@"first_name"];
        [shippingParams setObject:shippingAddress._last_name forKey:@"last_name"];
        //        [shippingParams setObject:billingAddress._company forKey:@"company"];
        [shippingParams setObject:shippingAddress._address_1 forKey:@"address_1"];
        [shippingParams setObject:shippingAddress._address_2 forKey:@"address_2"];
        [shippingParams setObject:shippingAddress._city forKey:@"city"];
        [shippingParams setObject:shippingAddress._postcode forKey:@"postcode"];
        [shippingParams setObject:shippingAddress._stateId forKey:@"state"];
        [shippingParams setObject:shippingAddress._countryId forKey:@"country"];
    }
    
    
    NSString* requestUrl = [NSString stringWithFormat:@"%@/%d", [[[DataManager sharedManager] tmDataDoctor] request_url_update_customer], appUser._id];
    NSString* URLString = [self initializeRequestStringForPostMethod:requestUrl];
    NSDictionary *postParams = [[NSDictionary alloc]initWithDictionary:params];
    AFHTTPSessionManager* manager = [self initializeRequestManagerForPostMethod];
    [manager POST:URLString parameters:postParams progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        RLOG(@"success!");
        [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
        NSDictionary *dict = nil;
        if (responseObject) {
            dict = [Utility getJsonObject:responseObject];
            RLOG(@"\n==ResponseObject = %@\n\n", dict);
        }
        if (dict) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Localize(@"i_success") message:Localize(@"i_customer_data_updated") delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
            [alertView show];
            [self performSelector:@selector(dismissAlert:) withObject:alertView afterDelay:1.0f];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"addressUpdatedSuccess" object:nil];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        RLOG(@"error: %@", error);
        RLOG(@"\n==Error = %@\n\n", error);
        
        if (error && error.userInfo) {
            id data = [error.userInfo valueForKey:@"com.alamofire.serialization.response.error.data"];
            if (data) {
                NSDictionary* json = [Utility getJsonObject:data];
                RLOG(@"======failure:%@======",json);
            }
        }
        
        NSInteger statusCode = 0;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = httpResponse.statusCode;
        }
        if(statusCode == 404 || statusCode == 200) {
            [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Localize(@"oops") message:Localize(@"generic_error") delegate:nil cancelButtonTitle:Localize(@"cancel") otherButtonTitles:Localize(@"retry"), nil];;
            [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if ((int)buttonIndex == 0) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"addressUpdatedFailed" object:nil];
                } else {
                    [self updateCustomerData];
                }
            }];
        } else {
            [self updateCustomerData];
        }
    }];
    
    
    
    /*
     [manager POST:URLString parameters:postParams constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
     
     } progress:^(NSProgress * _Nonnull uploadProgress) {
     
     } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
     [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
     RLOG(@"\n==ResponseObject = %@\n\n", responseObject);
     
     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Localize(@"i_success") message:Localize(@"i_customer_data_updated") delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
     [alertView show];
     [self performSelector:@selector(dismissAlert:) withObject:alertView afterDelay:1.0f];
     
     [[NSNotificationCenter defaultCenter] postNotificationName:@"addressUpdatedSuccess" object:nil];
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
     RLOG(@"\n==Error = %@\n\n", error);
     NSInteger statusCode = 0;
     NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
     if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
     statusCode = httpResponse.statusCode;
     }
     if(statusCode == 404 || statusCode == 200) {
     [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Localize(@"oops") message:Localize(@"generic_error") delegate:nil cancelButtonTitle:Localize(@"cancel") otherButtonTitles:Localize(@"retry"), nil];;
     [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
     if ((int)buttonIndex == 0) {
     [[NSNotificationCenter defaultCenter] postNotificationName:@"addressUpdatedFailed" object:nil];
     } else {
     [self updateCustomerData];
     }
     }];
     } else {
     [self updateCustomerData];
     }
     }];
     */
}
#pragma mark Fetch Data from Plugin
- (void)fetchCategoryProductsFast:(int)categoryId
                    product_limit:(int)product_limit
                           offset:(int)offset
                  success:(void (^)(id data))success
                  failure:(void (^)(void))failure {
    NSString* requestUrl = [NSString stringWithFormat:@"%@", [[[DataManager sharedManager] tmDataDoctor] request_url_products_fast]];
    NSMutableArray* paramArray = [self getCartStringForVerification];
    NSError * err;
    NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:paramArray options:0 error:&err];
    NSString * myString = [[NSString alloc] initWithData:jsonData   encoding:NSUTF8StringEncoding];
    RLOG(@"%@",myString);
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setObject:base64_int(categoryId) forKey:@"category_id"];
    [params setObject:base64_int(product_limit) forKey:@"product_limit"];
    [params setObject:base64_int(offset) forKey:@"offset"];
    NSDictionary* parameters = [[NSDictionary alloc] initWithDictionary:params];
    RLOG(@"\n==requestUrl = %@\n\n", requestUrl);
    RLOG(@"\n==parameters = %@\n\n", parameters);
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [manager POST:requestUrl parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
    } progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *array = [Utility getJsonArray:responseObject];
        NSArray *json = [Utility getJsonObject:responseObject];
        RLOG(@"\n==array = %@\n\n", array);
        RLOG(@"\n==json = %@\n\n", json);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        RLOG(@"\n==Error = %@\n\n", error);
    }];
}
- (void)fetchCartProductsDataFromPlugin {
    AppUser* appUser = [AppUser sharedManager];
    int maxCount = (int)[appUser._cartArray count];
    if (maxCount == 0) {
        return;
    }
    NSString* requestUrl = [NSString stringWithFormat:@"%@", [[[DataManager sharedManager] tmDataDoctor] request_url_more_products]];
    NSMutableArray* paramArray = [self getCartStringForVerification];
    NSError * err;
    NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:paramArray options:0 error:&err];
    NSString * myString = [[NSString alloc] initWithData:jsonData   encoding:NSUTF8StringEncoding];
    RLOG(@"%@",myString);
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setObject:myString forKey:@"cart_param"];
    NSDictionary* parameters = [[NSDictionary alloc] initWithDictionary:params];
    
    RLOG(@"\n==requestUrl = %@\n\n", requestUrl);
    RLOG(@"\n==parameters = %@\n\n", parameters);
    
    
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    [manager POST:requestUrl parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *array = [Utility getJsonArray:responseObject];
        [self.tmJsonHelper loadPluginDataForCartProducts:array];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CART_PAGE_DATA_LOADED" object:nil];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        RLOG(@"\n==Error = %@\n\n", error);
        NSInteger statusCode = 0;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = httpResponse.statusCode;
        }
        if(statusCode == 404 || statusCode == 200) {
            [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Localize(@"oops") message:Localize(@"generic_error") delegate:nil cancelButtonTitle:Localize(@"cancel") otherButtonTitles:Localize(@"retry"), nil];;
            [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if ((int)buttonIndex == 0) {
                } else {
                    [self fetchCartProductsDataFromPlugin];
                }
            }];
        } else {
            [self fetchCartProductsDataFromPlugin];
        }
    }];
}
- (void)fetchHomePageDataFromPlugin {
    NSString* requestUrl = [NSString stringWithFormat:@"%@", [[[DataManager sharedManager] tmDataDoctor] request_url_frontpage_content]];
    RLOG(@"\n==requestUrl = %@\n\n", requestUrl);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    
    [manager POST:requestUrl parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [Utility getJsonObject:responseObject];
        [self.tmJsonHelper loadPluginDataForHomePage:dict];
        self.isHomePageDataFetched = true;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HOME_PAGE_DATA_LOADED" object:nil];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        RLOG(@"\n==Error = %@\n\n", error);
        NSInteger statusCode = 0;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = httpResponse.statusCode;
        }
        if(statusCode == 404 || statusCode == 200) {
            [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"HOME_PAGE_DATA_FAILED" object:nil];
        } else {
            [self fetchHomePageDataFromPlugin];
        }
    }];
}
- (void)fetchInitialProductsDataFromPlugin{
    NSString* requestUrl = [NSString stringWithFormat:@"%@", [[[DataManager sharedManager] tmDataDoctor] request_url_initial_products]];
    RLOG(@"\n==requestUrl = %@\n\n", requestUrl);
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    NSMutableDictionary *paramsM = [[NSMutableDictionary alloc] init];
    [paramsM setValue:[NSNumber numberWithInteger:10] forKey:@"product_limit"];
    NSDictionary *params = [[NSDictionary alloc] initWithDictionary:paramsM];
    
    NSLog(@"logged0");
    [manager POST:requestUrl parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSLog(@"logged1");
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"logged2");
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"logged3");
        NSArray *array = [Utility getJsonArray:responseObject];
        if (array) {
            [self.tmJsonHelper loadPluginDataForInitialProducts:array];
            self.isInitialPageDataFetched = true;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NOTIFY_DL_PRODUCT" object:self];
        } else {
            NSLog(@"fetchInitialProductsDataFromPlugin failed. response is not array");
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Localize(@"oops") message:Localize(@"generic_error") delegate:nil cancelButtonTitle:Localize(@"cancel") otherButtonTitles:Localize(@"retry"), nil];;
            [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if ((int)buttonIndex == 0) {
                } else {
                    [self fetchInitialProductsDataFromPlugin];
                }
            }];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"logged4");
        RLOG(@"\n==Error = %@\n\n", error);
        NSInteger statusCode = 0;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = httpResponse.statusCode;
        }
        if(statusCode == 404 || statusCode == 200) {
            [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Localize(@"oops") message:Localize(@"generic_error") delegate:nil cancelButtonTitle:Localize(@"cancel") otherButtonTitles:Localize(@"retry"), nil];;
            [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if ((int)buttonIndex == 0) {
                } else {
                    [self fetchInitialProductsDataFromPlugin];
                }
            }];
        } else {
            [self fetchInitialProductsDataFromPlugin];
        }
        
        //        NSString* ErrorResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
        //        NSData *jsonData = [ErrorResponse dataUsingEncoding:NSUTF8StringEncoding];
        //        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
        //        NSArray* errors = [jsonDict objectForKey:@"errors"];
        //        NSDictionary* errorDict = [errors objectAtIndex:0];
        //        NSString* errorMessage = [errorDict objectForKey:@"message"];
        //        RLOG(@"\n==ErrorMsg = %@\n\n", errorMessage);
        //        if (errorMessage == NULL) {
        //            [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
        //            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Something went wrong." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        //            [alertView show];
        //            [self fetchInitialProductsDataFromPlugin];
        //        }
    }];
}

- (void)fetchCountryDataFromPlugin{
    NSString* requestUrl = [NSString stringWithFormat:@"%@", [[[DataManager sharedManager] tmDataDoctor] request_url_countries]];
    RLOG(@"\n==requestUrl = %@\n\n", requestUrl);
    
    
    
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    [manager POST:requestUrl parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [Utility getJsonObject:responseObject];
        [self.tmJsonHelper loadPluginDataForCountries:dict];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        RLOG(@"\n==Error = %@\n\n", error);
        NSInteger statusCode = 0;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = httpResponse.statusCode;
        }
        if(statusCode == 404 || statusCode == 200) {
            [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Localize(@"oops") message:Localize(@"generic_error") delegate:nil cancelButtonTitle:Localize(@"cancel") otherButtonTitles:Localize(@"retry"), nil];;
            [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if ((int)buttonIndex == 0) {
                } else {
                    [self fetchCountryDataFromPlugin];
                }
            }];
        } else {
            [self fetchCountryDataFromPlugin];
        }
        //        NSString* ErrorResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
        //        NSData *jsonData = [ErrorResponse dataUsingEncoding:NSUTF8StringEncoding];
        //        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
        //        NSArray* errors = [jsonDict objectForKey:@"errors"];
        //        NSDictionary* errorDict = [errors objectAtIndex:0];
        //        NSString* errorMessage = [errorDict objectForKey:@"message"];
        //        RLOG(@"\n==ErrorMsg = %@\n\n", errorMessage);
        //        if (errorMessage == NULL) {
        //            [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
        //            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Something went wrong." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        //            [alertView show];
        //            [self fetchCountryDataFromPlugin];
        //        }
    }];
}
- (void)fetchMoreProductsDataFromPlugin:(NSArray*)productIds success:(void (^)(void))success failure:(void (^)(void))failure {
    if (productIds == nil) {
        failure();
    }
    NSString * strProducts = @"";
    int i = 0;
    int maxCount = (int)[productIds count];
    if (maxCount == 0) {
        return;
    }
    for (NSNumber* objNumber in productIds) {
        if (i == maxCount-1) {
            strProducts = [strProducts stringByAppendingString:[NSString stringWithFormat:@"%d",[objNumber intValue]]];
        } else {
            strProducts = [strProducts stringByAppendingString:[NSString stringWithFormat:@"%d;",[objNumber intValue]]];
        }
        i++;
    }
    RLOG(@"strProducts = %@", strProducts);
    NSString* requestUrl = [NSString stringWithFormat:@"%@", [[[DataManager sharedManager] tmDataDoctor] request_url_more_products]];
    RLOG(@"\n==requestUrl = %@\n\n", requestUrl);
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setObject:strProducts forKey:@"pole_param"];
    NSDictionary* parameters = [[NSDictionary alloc] initWithDictionary:params];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [manager POST:requestUrl parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
    } progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *array = [Utility getJsonArray:responseObject];
        [self.tmJsonHelper loadPluginDataForMoreProducts:array];
        success();
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        RLOG(@"\n==Error = %@\n\n", error);
        failure();
    }];
}
- (void)fetchMoreProductsDataFromPlugin {
    AppUser* appUser = [AppUser sharedManager];
    NSString * strProducts = @"";
    int i = 0;
    int maxCount = (int)[appUser._needProductsArrayForOpinion count];
    if (maxCount == 0) {
        return;
    }
    for (NSNumber* objNumber in appUser._needProductsArrayForOpinion) {
        if (i == maxCount-1) {
            strProducts = [strProducts stringByAppendingString:[NSString stringWithFormat:@"%d",[objNumber intValue]]];
        } else {
            strProducts = [strProducts stringByAppendingString:[NSString stringWithFormat:@"%d;",[objNumber intValue]]];
        }
        i++;
    }
    RLOG(@"strProducts = %@", strProducts);
    NSString* requestUrl = [NSString stringWithFormat:@"%@", [[[DataManager sharedManager] tmDataDoctor] request_url_more_products]];
    
    RLOG(@"\n==requestUrl = %@\n\n", requestUrl);
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setObject:strProducts forKey:@"pole_param"];
    NSDictionary* parameters = [[NSDictionary alloc] initWithDictionary:params];
    
    
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    [manager POST:requestUrl parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *array = [Utility getJsonArray:responseObject];
        [self.tmJsonHelper loadPluginDataForMoreProducts:array];
        [appUser._needProductsArrayForOpinion removeAllObjects];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        RLOG(@"\n==Error = %@\n\n", error);
        NSInteger statusCode = 0;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = httpResponse.statusCode;
        }
        if(statusCode == 404 || statusCode == 200) {
            [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Localize(@"oops") message:Localize(@"generic_error") delegate:nil cancelButtonTitle:Localize(@"cancel") otherButtonTitles:Localize(@"retry"), nil];;
            [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if ((int)buttonIndex == 0) {
                } else {
                    [self fetchMoreProductsDataFromPlugin];
                }
            }];
        } else {
            [self fetchMoreProductsDataFromPlugin];
        }
    }];
}
- (void)fetchMenuItemsDataFromPlugin {
    NSString* requestUrl = [self request_url_menu_items];
    RLOG(@"\n==requestUrl = %@\n\n", requestUrl);
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [manager POST:requestUrl parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *array = [Utility getJsonArray:responseObject];
        [WC2X_JsonHelper loadPluginDataForMenuItems:array];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        RLOG(@"\n==Error = %@\n\n", error);
        NSInteger statusCode = 0;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = httpResponse.statusCode;
        }
        if(statusCode == 404 || statusCode == 200) {
            [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
        } else {
            [self fetchMenuItemsDataFromPlugin];
        }
    }];
}

- (void)loadExtraAttribData:(ProductInfo*)pInfo
                    success:(void(^)(id data))success
                    failure:(void(^)(NSString* error))failure {
    
    if (![Utility isNetworkAvailable]) {
        if (failure != nil) {
            failure(@"No Network");
        }
        return;
    }
    
    
    NSString* requestUrl = [NSString stringWithFormat:@"%@", self.request_url_extra_attribs];
    NSMutableArray* arrayPidsM = [[NSMutableArray alloc] init];
    [arrayPidsM addObject:[NSNumber numberWithInt:pInfo._id]];
    NSArray *arrayPids = [[NSArray alloc] initWithArray:arrayPidsM];
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:arrayPids options:kNilOptions error:&error];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSData *data1 = [[str dataUsingEncoding:NSUTF8StringEncoding] base64EncodedDataWithOptions:0];
    NSString *str1 = [[NSString alloc] initWithData:data1 encoding:NSUTF8StringEncoding];
    
    NSMutableDictionary *paramsM = [[NSMutableDictionary alloc] init];
    [paramsM setValue:str1 forKey:@"pids"];
    NSDictionary *params = [[NSDictionary alloc] initWithDictionary:paramsM];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [manager POST:requestUrl parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *jsonString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        RLOG(@"jsonString3 = %@", jsonString);
        NSArray *array = [Utility getJsonArray:responseObject];
        RLOG(@"ExtraAttributeData = %@", array);
        [self.tmJsonHelper parseExtraAttributesForProduct:pInfo variation_simple_fields:array];
        success(array);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(@"retry");
    }];
    
}
- (void)fetchCartProductsDataFromPlugin:(void(^)(id data))success failure:(void(^)(NSString* error))failure {
    AppUser* appUser = [AppUser sharedManager];
    int maxCount = (int)[appUser._cartArray count];
    if (maxCount == 0) {
        return;
    }
    NSString* requestUrl = [NSString stringWithFormat:@"%@", [[[DataManager sharedManager] tmDataDoctor] request_url_more_products]];
    NSMutableArray* paramArray = [self getCartStringForVerification];
    NSError * err;
    NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:paramArray options:0 error:&err];
    NSString * myString = [[NSString alloc] initWithData:jsonData   encoding:NSUTF8StringEncoding];
    RLOG(@"%@",myString);
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setObject:myString forKey:@"cart_param"];
    NSDictionary* parameters = [[NSDictionary alloc] initWithDictionary:params];
    
    RLOG(@"\n==requestUrl = %@\n\n", requestUrl);
    RLOG(@"\n==parameters = %@\n\n", parameters);
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    [manager POST:requestUrl parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *array = [Utility getJsonArray:responseObject];
        [self.tmJsonHelper loadPluginDataForCartProducts:array];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CART_PAGE_DATA_LOADED" object:nil];
        success(array);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        RLOG(@"\n==Error = %@\n\n", error);
        failure(error?[NSString stringWithFormat:@"%@", error]:@"error in fetchingCartProductsDataFromPlugin");
    }];
}
- (void)fetchProductsFullDataFromPlugin:(NSArray*)productIds success:(void (^)(id data))success failure:(void (^)(void))failure {
    int maxCount = (int)[productIds count];
    if (maxCount == 0) {
        return;
    }
    NSString* requestUrl = [NSString stringWithFormat:@"%@", [[[DataManager sharedManager] tmDataDoctor] request_url_products_full_data]];
    NSArray *arrayPids = [[NSArray alloc] initWithArray:productIds];
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:arrayPids options:kNilOptions error:&error];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSData *data1 = [[str dataUsingEncoding:NSUTF8StringEncoding] base64EncodedDataWithOptions:0];
    NSString *str1 = [[NSString alloc] initWithData:data1 encoding:NSUTF8StringEncoding];
    
    NSMutableDictionary *paramsM = [[NSMutableDictionary alloc] init];
    [paramsM setValue:str1 forKey:@"pids"];
    NSDictionary *params = [[NSDictionary alloc] initWithDictionary:paramsM];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [manager POST:requestUrl parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *array = [Utility getJsonArray:responseObject];
        if (array && [array count] > 0) {
            NSMutableDictionary* responseDict = [[NSMutableDictionary alloc] init];
            for (NSDictionary* dict in array) {
                for (id key in [dict allKeys]) {
                    RLOG(@"%@ - %@", key, [dict objectForKey:key]);
                    int productId = [key intValue];
                    NSDictionary* productObjData = [dict objectForKey:key];
                    NSMutableDictionary* mainDict = [[NSMutableDictionary alloc] init];
                    [mainDict setObject:productObjData forKey:@"product"];
                    ProductInfo* pInfo = [self.tmJsonHelper loadSingleProductData:mainDict];
                    pInfo._isFullRetrieved = false;
                    [responseDict setObject:pInfo forKey:[NSString stringWithFormat:@"%d", productId]];
                }
            }
            success(responseDict);
            return;
        }
        success(nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure();
    }];
}
- (void)fetchDeliverySlotsFromPlugin:(void (^)(id data))success failure:(void(^)(NSString* error))failure {
    NSMutableArray* arrayListDateTimeSlot = [DateTimeSlot getAllDateTimeSlots];
    [arrayListDateTimeSlot removeAllObjects];
    
    
    //    dispatch_async(dispatch_get_global_queue(0, 0), ^{
    NSString* requestUrl = [NSString stringWithFormat:@"%@", [[[DataManager sharedManager] tmDataDoctor] url_delivery_slots]];
    //    requestUrl = @"http://www.sexappealstore.it/wp-tm-ext-store-notify/api/woocommerce_delivery_slots_copia/";
    NSMutableDictionary *paramsM = [[NSMutableDictionary alloc] init];
    [paramsM setValue:base64_str(@"slot_list") forKey:@"type"];
    NSDictionary *params = [[NSDictionary alloc] initWithDictionary:paramsM];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [manager POST:requestUrl parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *jsonString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        RLOG(@"jsonString5 = %@", jsonString);
        NSArray* respObjArray = [Utility getJsonArray:responseObject];
        NSDictionary* respObjDict = [Utility getJsonObject:responseObject];
        
        if (respObjArray && [respObjArray isKindOfClass:[NSArray class]]) {
            NSMutableArray* arrayResponse = [WC2X_JsonHelper parseDeliverySlotDataType1:respObjArray];
            success(arrayResponse);
        } else if(respObjDict && [respObjDict isKindOfClass:[NSDictionary class]]) {
            NSMutableArray* arrayResponse = [WC2X_JsonHelper parseDeliverySlotDataType2:respObjDict];
            success(arrayResponse);
        } else {
            failure(@"failure");
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(@"retry");
    }];
    
    //    });
}
- (void)fetchLocalPickupTimeSelectFromPlugin:(void (^)(id data))success failure:(void (^)(void))failure {
    NSString* requestUrl = [NSString stringWithFormat:@"%@", [[[DataManager sharedManager] tmDataDoctor] url_local_pickup_time_select]];
    NSMutableDictionary *paramsM = [[NSMutableDictionary alloc] init];
    [paramsM setValue:base64_str(@"slot_list") forKey:@"type"];
    NSDictionary *params = [[NSDictionary alloc] initWithDictionary:paramsM];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [manager POST:requestUrl parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
    } progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *jsonString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        RLOG(@"jsonString6 = %@", jsonString);
        NSDictionary *dict = [Utility getJsonObject:responseObject];
        if (dict) {
            jsonString = [jsonString stringByReplacingOccurrencesOfString:@"{" withString:@""];
            jsonString = [jsonString stringByReplacingOccurrencesOfString:@"}" withString:@""];
            NSArray *arrayOfKeyValues = [jsonString componentsSeparatedByString:@","];
            NSMutableArray* arrayOfKeys = [[NSMutableArray alloc] init];
            NSMutableArray* arrayOfValues = [[NSMutableArray alloc] init];
            for (NSString* keyValStr in arrayOfKeyValues) {
                NSArray *myArray = [keyValStr componentsSeparatedByString:@":"];
                NSString* key = myArray[0];
                NSString* val = myArray[1];
                key = [key stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                val = [val stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                [arrayOfKeys addObject:key];
                [arrayOfValues addObject:val];
                RLOG(@"=%@=", key);
            }
            NSMutableArray* arrayResponse = [WC2X_JsonHelper parsePickUpTimeSlotData:dict keysArray:arrayOfKeys valuesArray:arrayOfValues];
            success(arrayResponse);
        } else {
            failure();
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure();
    }];
}
- (void)postTimeSlotsThroughPlugin:(int)orderId timeSlot:(TimeSlot*)timeSlot success:(void (^)(void))success failure:(void (^)(void))failure {
    [Utility createCustomizedLoadingBar:Localize(@"updating_order") isBottomAlign:false isClearViewEnabled:false isShadowEnabled:true];
    NSString* requestUrl = [NSString stringWithFormat:@"%@", [[[DataManager sharedManager] tmDataDoctor] url_local_pickup_time_select]];
    NSMutableDictionary *paramsM = [[NSMutableDictionary alloc] init];
    [paramsM setValue:base64_str(@"order_slot") forKey:@"type"];
    [paramsM setValue:base64_int(orderId) forKey:@"order_id"];
    [paramsM setValue:base64_str(timeSlot.slotId) forKey:@"pickup_time"];
    
    NSDictionary *params = [[NSDictionary alloc] initWithDictionary:paramsM];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [manager POST:requestUrl parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
    } progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
        NSDictionary *json = [self responseToDictionary:responseObject];
        if(json != nil && ![self hasResponseError:json]) {
            success();
            return;
        }
        if (json == nil) {
            RLOG(@"No data received / Invalid Json");
        } else {
            RLOG(@"json_dict: %@", json);
            //                NSString* errorStr = [json valueForKey:@"error"];
            //                NSString* messageStr = [json valueForKey:@"message"];
            NSString* statusStr = [json valueForKey:@"status"];
            //                RLOG(@"messageStr: %@", messageStr);
            if ([statusStr isEqualToString:@"success"]) {
                success();
                return;
            }
        }
        failure();
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
        failure();
    }];
    
}
- (void)postDeliverySlotsThroughPlugin:(int)orderId dateTimeSlot:(DateTimeSlot*)dateTimeSlot timeSlot:(TimeSlot*)timeSlot success:(void (^)(void))success failure:(void (^)(void))failure {
    [Utility createCustomizedLoadingBar:Localize(@"updating_order") isBottomAlign:false isClearViewEnabled:false isShadowEnabled:true];
    
    NSString* requestUrl = [NSString stringWithFormat:@"%@", [[[DataManager sharedManager] tmDataDoctor] url_delivery_slots]];
    NSMutableDictionary *paramsM = [[NSMutableDictionary alloc] init];
    [paramsM setValue:base64_str(@"order_slot") forKey:@"type"];
    [paramsM setValue:base64_int(orderId) forKey:@"order_id"];
    [paramsM setValue:base64_str([dateTimeSlot getDateSlot]) forKey:@"delivery_date"];
    [paramsM setValue:base64_str(timeSlot.slotId) forKey:@"id"];
    [paramsM setValue:base64_str(timeSlot.slotCost) forKey:@"cost"];
    NSDictionary *params = [[NSDictionary alloc] initWithDictionary:paramsM];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [manager POST:requestUrl parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
        NSDictionary *json = [self responseToDictionary:responseObject];
        if(json != nil && ![self hasResponseError:json]) {
            success();
            return;
        }
        if (json == nil) {
            RLOG(@"No data received / Invalid Json");
        } else {
            RLOG(@"json_dict: %@", json);
            //                NSString* errorStr = [json valueForKey:@"error"];
            //                NSString* messageStr = [json valueForKey:@"message"];
            NSString* statusStr = [json valueForKey:@"status"];
            //                RLOG(@"messageStr: %@", messageStr);
            if ([statusStr isEqualToString:@"success"]) {
                success();
                return;
            }
        }
        failure();
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
        failure();
    }];
    
}
- (void)getProductInfoFastInBackground:(ProductInfo*)product success:(void (^)(id data))success failure:(void (^)(void))failure {
    NSString* requestUrl = [NSString stringWithFormat:@"%@", [[[DataManager sharedManager] tmDataDoctor] request_url_single_product_fast]];
    NSMutableArray* productIds = [[NSMutableArray alloc] init];
    [productIds addObject:[NSString stringWithFormat:@"%d", product._id]];
    
    NSArray *arrayPids = [[NSArray alloc] initWithArray:productIds];
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:arrayPids options:kNilOptions error:&error];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSData *data1 = [[str dataUsingEncoding:NSUTF8StringEncoding] base64EncodedDataWithOptions:0];
    NSString *str1 = [[NSString alloc] initWithData:data1 encoding:NSUTF8StringEncoding];
    
    NSMutableDictionary *paramsM = [[NSMutableDictionary alloc] init];
    [paramsM setValue:str1 forKey:@"pids"];
    NSDictionary *params = [[NSDictionary alloc] initWithDictionary:paramsM];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [manager POST:requestUrl parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *array = [Utility getJsonArray:responseObject];
        for (NSDictionary* dict in array) {
            NSDictionary* productObjData = nil;
            id extraObjData = nil;
            productObjData = [dict objectForKey:@"product_info"];
            extraObjData = [dict objectForKey:@"ext_data"];
            NSMutableDictionary* mainDict = [[NSMutableDictionary alloc] init];
            [mainDict setObject:productObjData forKey:@"product"];
            [mainDict setObject:extraObjData forKey:@"ext_data"];
            BOOL isFullRetrieved = product._isFullRetrieved;
            ProductInfo* pInfo = [self.tmJsonHelper loadSingleProductData:mainDict];
            pInfo._isFullRetrieved = isFullRetrieved;
            pInfo._isExtraDataRetrieved = true;
            success(pInfo);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure();
    }];
}
- (void)getFilterPricesInBackground :(NSDictionary*)params success:(void(^)(id data))success failure:(void(^)(NSString* error))failure {
    NSString* requestUrl = [self request_url_filterdata_prices];
    RLOG(@"\n==requestUrl = %@\n\n", requestUrl);
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    [manager GET:requestUrl parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        RLOG(@"responseObject*********************  %@",responseObject);
        if (responseObject) {
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                NSMutableArray* array = [self parseJsonAndCreateFilterPrices:responseObject];
                success(array);
            }
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            RLOG(@" ***************** Price failure********************* ");
            RLOG(@"***************** Pricefailure******************  %@",error.description);
            return ;
        }
    }];
}
- (NSMutableArray *)parseJsonAndCreateFilterPrices:(NSDictionary*) json{
    if (IS_NOT_NULL(json, @"cat_price_range")) {
        NSMutableArray *cat_price_range = nil;
        cat_price_range = GET_VALUE_STR(json, @"cat_price_range");
        for (NSDictionary *Dics in cat_price_range) {
            [self.tmJsonHelper parseFilterPrices:Dics];
        }
    }
    return [TM_ProductFilter getAll];
}

- (void)getFilterAttributesInBackground:(NSDictionary*)params success:(void(^)(id data))success failure:(void(^)(NSString* error))failure{
    NSString* requestUrl = [self request_url_filterdata_attributes];
    RLOG(@"\n==requestUrl = %@\n\n", requestUrl);
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    [manager GET:requestUrl parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //        RLOG(@"responseObject*********************  %@",responseObject);
        NSError * err;
        NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:responseObject options:0 error:&err];
        NSString * myString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        RLOG(@"%@",myString);
        
        if (responseObject) {
            if ([responseObject isKindOfClass:[NSArray class]]) {
                NSMutableArray* array = [self parseJsonAndCreateFilterAttributes:responseObject];
                success(array);
            }
            [TM_ProductFilter attribsLoadedTrue];
            
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        RLOG(@" *****************Attribuut failure********************* ");
        RLOG(@"***************** Attribuut failure******************  %@",error.description);
        failure(@"AT failure");
    }];
}

- (void)getProductsByFilter:(NSDictionary *)userFilter success:(void(^)(id data))success failure:(void(^)(NSString* error))failure{
    
    NSString* requestUrl = [NSString stringWithFormat:@"%@",self.request_url_filter_products];
    RLOG(@"\n==requestUrl = %@\n\n", requestUrl);
    int products_required = 1;
    NSError * err;
    NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:userFilter options:0 error:&err];
    NSString* filterString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    RLOG(@"filterString = %@",filterString);
    
    NSDictionary *Postperameter = @{
                                    @"filter_data" : filterString,
                                    @"products_required" :[NSNumber numberWithInteger:products_required],
                                    };
    
    RLOG(@"Postperameter  %@",Postperameter);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [manager POST:requestUrl parameters:Postperameter constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        
        RLOG(@"responseObject  %@",responseObject);
        NSString *jsonString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        RLOG(@"jsonString7 = %@", jsonString);
        
        NSArray *array = [Utility getJsonArray:responseObject];
        NSMutableArray* arrayResponse = [[NSMutableArray alloc] init];
        [self.tmJsonHelper loadTrendingDatasViaPlugin:array originalDataArray:arrayResponse resizeEnable:false];
        success(arrayResponse);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        RLOG(@"\n==Error = %@\n\n", error);
        failure(@"");
    }];
}

- (void)getAttributByAttributSelectedAttribute:(NSDictionary *)userFilter success:(void(^)(id data))success failure:(void(^)(NSString* error))failure{
    
    NSString* requestUrl = [NSString stringWithFormat:@"%@",self.request_url_filter_products];
    //    RLOG(@"\n==requestUrl = %@\n\n", requestUrl);
    int products_required = 0;
    NSError * err;
    NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:userFilter options:0 error:&err];
    NSString* filterString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    RLOG(@"filterString = %@",filterString);
    
    NSDictionary *Postperameter = @{
                                    @"filter_data" : filterString,
                                    @"products_required" :[NSNumber numberWithInteger:products_required],
                                    };
    
    //    RLOG(@"Postperameter  %@",Postperameter);
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [manager POST:requestUrl parameters:Postperameter constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //        RLOG(@"responseObject  %@",responseObject);
        NSString *jsonString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        RLOG(@"jsonString8 = %@", jsonString);
        
        NSDictionary* responseDict = [Utility getJsonObject:responseObject];
        success(responseDict);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        RLOG(@"\n==Error = %@\n\n", error);
        failure(@"");
    }];
}

- (void)fetchOrdersInBackground:(void (^)(id data))success failure:(void (^)(NSString* error))failure {
    AppUser* au = [AppUser sharedManager];
    NSString* _urlString = [NSString stringWithFormat:@"%@/%d/orders", self.request_url_all_orders, au._id];
    NSURL* nsUrl = [self getNSURL:_urlString isPostMethod:false maxDataLimit:200 offset:0];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html",@"text/plain", nil];
    [manager GET:nsUrl.absoluteString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        if (responseObject != nil) {
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                RLOG(@"\nresponseObject = %@",responseObject);
                NSData* responseObjectData = [NSJSONSerialization dataWithJSONObject:responseObject options:0 error:nil];
                NSString * responseJsonString = [[NSString alloc] initWithData:responseObjectData encoding:NSUTF8StringEncoding];
                RLOG(@"%@", responseJsonString);
                [[DataManager sharedManager] loadOrdersData:responseObject];
                AppUser* appUser = [AppUser sharedManager];
                [self fetchOrderImgData:appUser._ordersArray success:^{
                    success(responseObject);
                } failure:^{
                    success(responseObject);
                }];
            } else {
                NSDictionary *dict = [Utility getJsonObject:responseObject];
                RLOG(@"\nresponseObject = %@",dict);
                if (dict) {
                    [[DataManager sharedManager] loadOrdersData:dict];
                    AppUser* appUser = [AppUser sharedManager];
                    [self fetchOrderImgData:appUser._ordersArray success:^{
                        success(dict);
                    } failure:^{
                        success(dict);
                    }];
                }
            }
        } else {
            failure(@"failure");
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        RLOG(@"\noperation = failed");
        RLOG(@"\nerror = %@", error);
        RLOG(@"\nlocalizedDescription = %@\nlocalizedFailureReason = %@\n", [error localizedDescription], [error localizedFailureReason]);
        NSInteger statusCode = 0;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)operation.response;
        if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = httpResponse.statusCode;
        }
        if(statusCode == 404 || statusCode == 200) {
            failure(@"failure");
        } else if (statusCode == -1016){
            failure(@"failure");
        } else {
            failure(@"retry");
        }
    }];
}
- (void)fetchOrderImgData:(NSArray*)orders
                  success:(void (^)(void))success
                  failure:(void (^)(void))failure {
    NSMutableArray* pids = [[NSMutableArray alloc] init];
    for (Order* order in orders) {
        for (LineItem* lineItem in order._line_items) {
            int pId = lineItem._product_id;
            ProductInfo* prodObj = [ProductInfo isProductExists:pId];
            BOOL isExists = prodObj ? true : false;
            if (isExists) {
                if (prodObj._images && [prodObj._images count] > 0) {
                    ProductImage* pImg = [prodObj._images objectAtIndex:0];
                    [LineItem setImgUrlOnProductId:lineItem._product_id imgUrl:pImg._src];
                    continue;
                }
            }
            BOOL isImgExists = [LineItem getImgUrlOnProductId:pId]?true:false;
            if (isImgExists == false) {
                [pids addObject:[NSString stringWithFormat:@"%d", pId]];
            }
        }
    }
    if ([pids count] > 0) {
        [[[DataManager sharedManager] tmDataDoctor] fetchProductsFullDataFromPlugin:pids success:^(id data) {
            if (data) {
                for (Order* order in orders) {
                    for (LineItem* lineItem in order._line_items) {
                        int pId = lineItem._product_id;
                        ProductInfo* prod = (ProductInfo*)[data objectForKey:[NSString stringWithFormat:@"%d", pId]];
                        if (prod._type == PRODUCT_TYPE_VARIABLE) {
                            NSMutableArray* selectedVariationAttibutes = [[NSMutableArray alloc] init];
                            for (Attribute* attribute in prod._attributes) {
                                [selectedVariationAttibutes addObject:[attribute getVariationAttribute:0]];
                            }
                            for (ProductMetaItemProperties* mp in lineItem._meta) {
                                NSString* vL = mp._value;
                                NSString* vK = mp._key;
                                for (VariationAttribute* va in selectedVariationAttibutes) {
                                    if ([Utility compareAttributeNames:va.name name2:vK]) {
                                        va.value = vL;
                                    }
                                }
                            }
                            Variation* selectedVariation = [prod._variations getVariationFromAttibutes:selectedVariationAttibutes];
                            
                            if (selectedVariation) {
                                if (selectedVariation._images && [selectedVariation._images count] > 0) {
                                    ProductImage* pImg = [selectedVariation._images objectAtIndex:0];
                                    [LineItem setImgUrlOnProductId:lineItem._product_id imgUrl:pImg._src];
                                } else if (prod._images && [prod._images count] > 0) {
                                    ProductImage* pImg = [prod._images objectAtIndex:0];
                                    [LineItem setImgUrlOnProductId:lineItem._product_id imgUrl:pImg._src];
                                }
                            } else {
                                if (prod._images && [prod._images count] > 0) {
                                    ProductImage* pImg = [prod._images objectAtIndex:0];
                                    [LineItem setImgUrlOnProductId:lineItem._product_id imgUrl:pImg._src];
                                }
                            }
                        }
                        else {
                            if (prod._images && [prod._images count] > 0) {
                                ProductImage* pImg = [prod._images objectAtIndex:0];
                                [LineItem setImgUrlOnProductId:lineItem._product_id imgUrl:pImg._src];
                            }
                        }
                    }
                }
            }
            success();
        } failure:^{
            failure();
        }];
    }
}
- (void)getGuestOrdersInBackground:(void (^)(id data))success failure:(void (^)(void))failure {
    NSString* requestUrl = [NSString stringWithFormat:@"%@", [[[DataManager sharedManager] tmDataDoctor] request_url_selected_orders_data]];
    NSMutableArray* orderIdsM = [[NSMutableArray alloc] init];
    AppUser* appUser = [AppUser sharedManager];
    if(appUser._ordersArray && [appUser._ordersArray count] > 0){
        for (Order* order in appUser._ordersArray) {
            [orderIdsM addObject:[NSString stringWithFormat:@"%d", order._id]];
        }
        NSArray *orderIds = [[NSArray alloc] initWithArray:orderIdsM];
        NSString* oids = [NSString stringWithFormat:@"[%@]", [NSArray join:orderIds]];
        NSDictionary* params = @{@"oids": base64_str(oids)};
        
        AFHTTPSessionManager *manager =  [self getHttpSessionManagerForPost:@"text/html"];
        [manager POST:requestUrl parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {}
             progress:^(NSProgress * _Nonnull uploadProgress) {
             } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                 NSDictionary *json = [self responseToDictionary:responseObject];
                 if(json != nil && ![self hasResponseError:json]) {
                     @try {
                         [self.tmJsonHelper loadOrdersData:json];
                         success(json);
                         return;
                     } @catch(NSException* e) {
                         RLOG(@"getGuestOrdersInBackground: %@", e);
                     }
                 }
                 failure();
             } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                 failure();
             }];
        
        
        
        //        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        //        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        //        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        //        manager.securityPolicy.allowInvalidCertificates = YES;
        //        manager.securityPolicy.validatesDomainName = NO;
        //        manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
        //        [manager POST:requestUrl parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        //
        //        } progress:^(NSProgress * _Nonnull uploadProgress) {
        //
        //        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //            NSArray *array = [Utility getJsonArray:responseObject];
        ////            for (NSDictionary* dict in array) {
        ////                NSDictionary* productObjData = nil;
        ////                id extraObjData = nil;
        ////                productObjData = [dict objectForKey:@"product_info"];
        ////                extraObjData = [dict objectForKey:@"ext_data"];
        ////                NSMutableDictionary* mainDict = [[NSMutableDictionary alloc] init];
        ////                [mainDict setObject:productObjData forKey:@"product"];
        ////                [mainDict setObject:extraObjData forKey:@"ext_data"];
        ////                BOOL isFullRetrieved = product._isFullRetrieved;
        ////                ProductInfo* pInfo = [self.tmJsonHelper loadSingleProductData:mainDict];
        ////                pInfo._isFullRetrieved = isFullRetrieved;
        ////                pInfo._isExtraDataRetrieved = true;
        ////                success(pInfo);
        //
        ////            }
        //            success(array);
        //        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //            failure();
        //        }];
    }
    else {
        failure();
    }
    
}
- (NSMutableArray*)parseJsonAndCreateFilterAttributes:(NSMutableArray*) json{
    NSMutableArray * tt = [TM_ProductFilter getAll];
    if (tt.count != 0) {
        [tt removeAllObjects];
        [self getFilterPricesInBackground:nil success:^(id data) {
            RLOG(@"getFilterPricesInBackground  Sucess");
        } failure:^(NSString *error) {
            RLOG(@"getFilterPricesInBackground  Failure");
            
        }];
    }
    NSMutableArray *jMainObject = [[NSMutableArray alloc]initWithArray:json];
    for (int i = 0; i<jMainObject.count; i++) {
        NSDictionary *dic= [jMainObject objectAtIndex:i];
        [self.tmJsonHelper parseFilterAttributes:dic];
    }
    return [TM_ProductFilter getAll];
}
#pragma mark Fetch Data from Plugin Vendor
- (void)fetchVendorDataFromPlugin {
    NSString* requestUrl = [NSString stringWithFormat:@"%@", [[[DataManager sharedManager] tmDataDoctor] request_url_list_vendor]];
    RLOG(@"\n==requestUrl = %@\n\n", requestUrl);
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [manager POST:requestUrl parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *array = [Utility getJsonArray:responseObject];
        [self.tmJsonHelper loadPluginDataForVendors:array];
        //        self.isHomePageDataFetched = true;
        self.isVendorDataFetched = true;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"VENDOR_DATA_SUCCESS" object:nil];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        RLOG(@"\n==Error = %@\n\n", error);
        NSInteger statusCode = 0;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = httpResponse.statusCode;
        }
        if(statusCode == 404 || statusCode == 200) {
            [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"VENDOR_DATA_FAILED" object:nil];
        } else {
            [self fetchVendorDataFromPlugin];
        }
    }];
}
- (void)fetchHomePageDataFromPlugin_MultiVendor {
    NSString* requestUrl = [NSString stringWithFormat:@"%@", [[[DataManager sharedManager] tmDataDoctor] request_url_frontpage_content_vendor]];
    RLOG(@"\n==requestUrl = %@\n\n", requestUrl);
    NSString* vendorId = [[NSUserDefaults standardUserDefaults] valueForKey:VENDOR_ID];
    NSDictionary *params = @{
                             @"seller_id": [[vendorId dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0]};
    
    
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [manager POST:requestUrl parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [Utility getJsonObject:responseObject];
        [self.tmJsonHelper loadPluginDataForHomePage:dict];
        self.isHomePageDataFetched = true;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"HOME_PAGE_DATA_LOADED" object:nil];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        RLOG(@"\n==Error = %@\n\n", error);
        NSInteger statusCode = 0;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = httpResponse.statusCode;
        }
        if(statusCode == 404 || statusCode == 200) {
            [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"HOME_PAGE_DATA_FAILED" object:nil];
        } else {
            [self fetchHomePageDataFromPlugin_MultiVendor];
        }
    }];
}
- (void)fetchInitialProductsDataFromPlugin_MultiVendor {
    NSString* requestUrl = [NSString stringWithFormat:@"%@", [[[DataManager sharedManager] tmDataDoctor] request_url_initial_products_vendor]];
    RLOG(@"\n==requestUrl = %@\n\n", requestUrl);
    NSString* vendorId = [[NSUserDefaults standardUserDefaults] valueForKey:VENDOR_ID];
    NSDictionary *params = @{
                             @"seller_id": [[vendorId dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0]};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [manager POST:requestUrl parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *array = [Utility getJsonArray:responseObject];
        if (array) {
            [self.tmJsonHelper loadPluginDataForInitialProducts:array];
            self.isInitialPageDataFetched = true;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NOTIFY_DL_PRODUCT" object:self];
        } else {
            
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        RLOG(@"\n==Error = %@\n\n", error);
        NSInteger statusCode = 0;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = httpResponse.statusCode;
        }
        if(statusCode == 404 || statusCode == 200) {
            [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Localize(@"oops") message:Localize(@"generic_error") delegate:nil cancelButtonTitle:Localize(@"cancel") otherButtonTitles:Localize(@"retry"), nil];;
            [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if ((int)buttonIndex == 0) {
                } else {
                    [self fetchInitialProductsDataFromPlugin_MultiVendor];
                }
            }];
        } else {
            [self fetchInitialProductsDataFromPlugin_MultiVendor];
        }
    }];
}
- (void)fetchProductDataForCategory_MultiVendor:(NSString*)vendorId
                                     categoryId:(int)categoryId
                                         offset:(int)offset
                                   productCount:(int)productCount
                                        success:(void(^)(id data))success
                                        failure:(void(^)(NSString* error))failure {
    vendorId = [[NSUserDefaults standardUserDefaults] valueForKey:VENDOR_ID];
    
    NSString* requestUrl = [NSString stringWithFormat:@"%@", [[[DataManager sharedManager] tmDataDoctor] request_url_products_vendor]];
    RLOG(@"\n==requestUrl = %@\n\n", requestUrl);
    NSDictionary *params = @{
                             @"seller_id": [[vendorId dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0],
                             @"category_id": [[[NSString stringWithFormat:@"%d", categoryId] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0],
                             @"product_limit": [[[NSString stringWithFormat:@"%d", productCount] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0],
                             @"offset": [[[NSString stringWithFormat:@"%d", offset] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0]
                             };
    
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [manager POST:requestUrl parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *array = [Utility getJsonArray:responseObject];
        if (array) {
            NSArray *dict = [[NSArray alloc] initWithArray:array];
            RLOG(@"\n==ResponseObject = %@\n\n", dict);
            [self.tmJsonHelper loadPluginDataForInitialProducts:dict];
            ServerData *sData = [[ServerData alloc] init];
            sData._serverUrl = [NSString stringWithFormat:@"%@", self.request_url_products];
            sData._serverRequest = nil;
            sData._serverRequestStatus = kServerRequestStart;
            sData._serverDataId = kFetchMoreProduct;
            [self.serverDatas addObject:sData];
            
            NSMutableDictionary* mutDict = [[NSMutableDictionary alloc] init];
            [mutDict setValue:dict forKey:@"MoreProducts"];
            sData._serverResultDictionary = [[NSDictionary alloc] initWithDictionary:mutDict];
            sData._serverRequestStatus = kServerRequestSucceed;
            [self.tmMulticastDelegate respondToDelegates:sData];
            success(nil);
        } else {
            failure(@"");
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        RLOG(@"\n==Error = %@\n\n", error);
        RLOG(@"\noperation = failed");
        RLOG(@"\nerror = %@", error);
        RLOG(@"\nlocalizedDescription = %@\nlocalizedFailureReason = %@\n", [error localizedDescription], [error localizedFailureReason]);
        ServerData *sData = [[ServerData alloc] init];
        sData._serverUrl = [NSString stringWithFormat:@"%@", self.request_url_products];
        sData._serverRequest = nil;
        sData._serverRequestStatus = kServerRequestStart;
        sData._serverDataId = kFetchMoreProduct;
        [self.serverDatas addObject:sData];
        sData._serverRequestStatus = kServerRequestFailed;
        NSInteger statusCode = 0;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = httpResponse.statusCode;
        }
        if(statusCode == 404 || statusCode == 200) {
            sData._serverRequestStatus = kServerRequestFailed;
            [self.tmMulticastDelegate respondToDelegates:sData];
            failure(@"");
        } else {
            sData._serverRequestStatus = kServerRequestFailed;
            [self fetchProductDataForCategory_MultiVendor:@"" categoryId:categoryId offset:offset productCount:productCount success:success failure:failure];
        }
    }];
}
#pragma mark Post Data to Plugin
- (void)syncCartForAppliedCoupon:(void (^)(void))success failure:(void (^)(void))failure {
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    NSData * cartJsonData = [NSJSONSerialization dataWithJSONObject:[self prepareCartJson] options:0 error:nil];
    NSString * cartJsonString = [[NSString alloc] initWithData:cartJsonData encoding:NSUTF8StringEncoding];
    NSData * shipJsonData = [NSJSONSerialization dataWithJSONObject:[self prepareShipmentJson] options:0 error:nil];
    NSString * shipJsonString = [[NSString alloc] initWithData:shipJsonData encoding:NSUTF8StringEncoding];
    NSData * billJsonData = [NSJSONSerialization dataWithJSONObject:[self prepareBillingJson] options:0 error:nil];
    NSString * billJsonString = [[NSString alloc] initWithData:billJsonData encoding:NSUTF8StringEncoding];
    NSData * couponJsonData = [NSJSONSerialization dataWithJSONObject:[self prepareCouponJson] options:0 error:nil];
    NSString * couponJsonString = [[NSString alloc] initWithData:couponJsonData encoding:NSUTF8StringEncoding];
    [params setObject:cartJsonString forKey:@"cart_data"];
    [params setObject:shipJsonString forKey:@"ship_data"];
    [params setObject:billJsonString forKey:@"bill_data"];
    [params setObject:couponJsonString forKey:@"coupon_data"];
    NSDictionary *postParams = [[NSDictionary alloc]initWithDictionary:params];
    NSString* requestUrl = [NSString stringWithFormat:@"%@", [[[DataManager sharedManager] tmDataDoctor] request_url_sync_cart_items]];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [manager POST:requestUrl parameters:postParams constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [Utility getJsonObject:responseObject];
        if (dict != nil){
            if([dict objectForKey:@"payment"]) {
                //if ([[dict objectForKey:@"payment"] isKindOfClass:[NSDictionary class]]) {
                [self.tmJsonHelper loadPaymentGatewayDatasViaPlugin:[dict objectForKey:@"payment"]];
                //}
            }
            if([dict objectForKey:@"shipping_data"]) {
                if ([[dict objectForKey:@"shipping_data"] isKindOfClass:[NSDictionary class]]) {
                    NSString* status = @"";
                    NSString* status_message = @"";
                    if (IS_NOT_NULL([dict objectForKey:@"shipping_data"], @"status")) {
                        status = GET_VALUE_STRING([dict objectForKey:@"shipping_data"], @"status");
                    }
                    if (IS_NOT_NULL([dict objectForKey:@"shipping_data"], @"message")) {
                        status_message = GET_VALUE_STRING([dict objectForKey:@"shipping_data"], @"message");
                    }
                    if ([status isEqualToString:@"failed"]) {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Localize(@"cart_sync_failed") message:status_message delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
                        [alertView show];
                        [self performSelector:@selector(dismissAlert:) withObject:alertView afterDelay:1.0f];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"CART_SYNC_FAILED" object:nil];
                        return;
                    }
                    TMShippingSDK* shippingSDK = [[DataManager sharedManager] tmShippingSDK];
                    [shippingSDK resetShippingMethods];
                    NSDictionary* mainDict = [dict objectForKey:@"shipping_data"];
                    if (mainDict) {
                        shippingSDK.shippingEnable = GET_VALUE_BOOL(mainDict, @"show_shipping");
                        if (shippingSDK.shippingEnable)
                        {
                            NSArray* shippingData = GET_VALUE_OBJECT(mainDict, @"shipping");
                            [self.tmJsonHelper loadShippingMethodsDatasViaPlugin:shippingData];
                        }
                    }
                }
            }
            if([dict objectForKey:@"cart_meta"]) {
                NSDictionary* cartMetaDict = [dict objectForKey:@"cart_meta"];
                if (cartMetaDict) {
                    [self.tmJsonHelper parseJsonAndCreateCartMeta:cartMetaDict];
                }
            }
            success();
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure();
    }];
}
- (void)syncCart {
    MRProgressOverlayView* mov = [Utility createCustomizedLoadingBar:[NSString stringWithFormat:@"%@..",Localize(@"syncing_cart")] isBottomAlign:false isClearViewEnabled:false isShadowEnabled:true];
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    NSData * cartJsonData = [NSJSONSerialization dataWithJSONObject:[self prepareCartJson] options:0 error:nil];
    NSString * cartJsonString = [[NSString alloc] initWithData:cartJsonData encoding:NSUTF8StringEncoding];
    NSData * shipJsonData = [NSJSONSerialization dataWithJSONObject:[self prepareShipmentJson] options:0 error:nil];
    NSString * shipJsonString = [[NSString alloc] initWithData:shipJsonData encoding:NSUTF8StringEncoding];
    NSData * billJsonData = [NSJSONSerialization dataWithJSONObject:[self prepareBillingJson] options:0 error:nil];
    NSString * billJsonString = [[NSString alloc] initWithData:billJsonData encoding:NSUTF8StringEncoding];
    NSData * couponJsonData = [NSJSONSerialization dataWithJSONObject:[self prepareCouponJson] options:0 error:nil];
    NSString * couponJsonString = [[NSString alloc] initWithData:couponJsonData encoding:NSUTF8StringEncoding];
    [params setObject:cartJsonString forKey:@"cart_data"];
    [params setObject:shipJsonString forKey:@"ship_data"];
    [params setObject:billJsonString forKey:@"bill_data"];
    [params setObject:couponJsonString forKey:@"coupon_data"];
    NSDictionary *postParams = [[NSDictionary alloc]initWithDictionary:params];
    NSString* requestUrl = [NSString stringWithFormat:@"%@", [[[DataManager sharedManager] tmDataDoctor] request_url_sync_cart_items]];
    RLOG(@"==requestUrl:%@==", requestUrl);
    NSData * jsonData1 = [NSJSONSerialization dataWithJSONObject:postParams options:0 error:nil];
    NSString * myString1 = [[NSString alloc] initWithData:jsonData1 encoding:NSUTF8StringEncoding];
    RLOG(@"==PARAMETERS:%@==", myString1);
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    [manager POST:requestUrl parameters:postParams constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
        NSDictionary *dict = [Utility getJsonObject:responseObject];
        RLOG(@"==RESPONSEOBJECT:%@==", dict);
        if (dict != nil){
            if([dict objectForKey:@"payment"]) {
                //if ([[dict objectForKey:@"payment"] isKindOfClass:[NSDictionary class]]) {
                [self.tmJsonHelper loadPaymentGatewayDatasViaPlugin:[dict objectForKey:@"payment"]];
                //}
            }
            if([dict objectForKey:@"shipping_data"]) {
                if ([[dict objectForKey:@"shipping_data"] isKindOfClass:[NSDictionary class]]) {
                    NSString* status = @"";
                    NSString* status_message = @"";
                    if (IS_NOT_NULL([dict objectForKey:@"shipping_data"], @"status")) {
                        status = GET_VALUE_STRING([dict objectForKey:@"shipping_data"], @"status");
                    }
                    if (IS_NOT_NULL([dict objectForKey:@"shipping_data"], @"message")) {
                        status_message = GET_VALUE_STRING([dict objectForKey:@"shipping_data"], @"message");
                    }
                    if ([status isEqualToString:@"failed"]) {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Localize(@"cart_sync_failed") message:status_message delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
                        [alertView show];
                        [self performSelector:@selector(dismissAlert:) withObject:alertView afterDelay:1.0f];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"CART_SYNC_FAILED" object:nil];
                        return;
                    }
                    
                    
                    TMPaymentSDK* paymentSDK = [[DataManager sharedManager] tmPaymentSDK];
                    TMShippingSDK* shippingSDK = [[DataManager sharedManager] tmShippingSDK];
                    
                    [shippingSDK resetShippingMethods];
                    NSDictionary* mainDict = [dict objectForKey:@"shipping_data"];
                    if (mainDict) {
                        shippingSDK.shippingEnable = GET_VALUE_BOOL(mainDict, @"show_shipping");
                        if (shippingSDK.shippingEnable)
                        {
                            NSArray* shippingData = GET_VALUE_OBJECT(mainDict, @"shipping");
                            [self.tmJsonHelper loadShippingMethodsDatasViaPlugin:shippingData];
                        }
                    }
                    
                    /////////////////
                    [[CartMeta sharedInstance] resetCartMeta];
                    NSDictionary* cartMetaDict = [dict objectForKey:@"cart_meta"];
                    if (cartMetaDict) {
                        [self.tmJsonHelper parseJsonAndCreateCartMeta:cartMetaDict];
                    }
                    
                    [[MinOrderData sharedInstance] resetMinOrderData];
                    [self.tmJsonHelper parseJsonAndCreateMinOrderData:dict];
                    
                    
                    [FeeData resetFeeData];
                    [self.tmJsonHelper parseJsonAndCreateFees:dict];
                }
            }
            if([dict objectForKey:@"checkout_addon"]) {
                [self.tmJsonHelper loadCheckoutAddonsViaPlugin:[dict objectForKey:@"checkout_addon"]];
            }
            if ([dict objectForKey:@"cart_note"]) {
                [TM_CheckoutAddon setOrderScreenNote:GET_VALUE_STRING(dict, @"cart_note")];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CART_SYNC_SUCCESS" object:nil];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Localize(@"i_error") message:Localize(@"try_again") delegate:nil cancelButtonTitle:Localize(@"i_ok") otherButtonTitles:nil];
            [alertView show];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CART_SYNC_FAILED" object:nil];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        RLOG(@"\n==Error = %@\n\n", error);
        NSInteger statusCode = 0;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = httpResponse.statusCode;
        }
        if(statusCode == 404 || statusCode == 200) {
            [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Localize(@"oops") message:Localize(@"generic_error") delegate:nil cancelButtonTitle:Localize(@"cancel") otherButtonTitles:Localize(@"retry"), nil];;
            [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if ((int)buttonIndex == 0) {
                } else {
                    [self syncCart];
                }
            }];
        } else {
            [self syncCart];
        }
    }];
}
#pragma mark Create Data
- (NSMutableArray*)prepareCouponJson {
    //    coupon_data
    NSMutableArray* couponDataArray = [[NSMutableArray alloc] init];
    Coupon* coupon = nil;
    for (coupon in [Cart getAppliedCoupons]) {
        NSMutableDictionary *couponLine = [[NSMutableDictionary alloc] init];
        [couponDataArray addObject:couponLine];
        [couponLine setObject:[NSNumber numberWithInt:coupon._id] forKey:@"id"];
        [couponLine setObject:coupon._code forKey:@"code"];
    }
    return couponDataArray;
}
- (NSMutableArray*)prepareCartJson {
    NSMutableArray* cartDataArray = [[NSMutableArray alloc] init];
    NSObject* obj = nil;
    for (obj in [Cart getAll]) {
        Cart *cInfo = (Cart*) obj;
        NSMutableDictionary* cartItemDict = [[NSMutableDictionary alloc] init];
        [cartItemDict setObject:[NSNumber numberWithInt:cInfo.product_id] forKey:@"pid"];
        [cartItemDict setObject:[NSNumber numberWithInt:cInfo.selectedVariationId] forKey:@"variation_id"];
        [cartItemDict setObject:[NSNumber numberWithInt:cInfo.count] forKey:@"quantity"];
        NSMutableArray *jsonAttributes = [[NSMutableArray alloc] init];
        
        
        
        if (cInfo.selectedVariationId != -1) {
            if (cInfo.product._isFullRetrieved == false) {
                //                [lineItem setObject:variations forKey:@"variations"];
                for (VariationAttribute* vAttr in cInfo.selected_attributes) {
                    //                    [variations setObject:vAttr.value forKey:vAttr.name];
                    NSMutableDictionary *jAttribute = [[NSMutableDictionary alloc] init];
                    [jAttribute setObject:vAttr.name forKey:@"name"];
                    [jAttribute setObject:vAttr.value forKey:@"value"];
                    [jsonAttributes addObject:jAttribute];
                }
                [cartItemDict setObject:jsonAttributes forKey:@"attributes"];
            } else {
                //                [lineItem setObject:variations forKey:@"variations"];
                Variation* variation = [cInfo.product._variations getVariation:cInfo.selectedVariationId variationIndex:cInfo.selectedVariationIndex];
                if (variation != nil) {
                    NSObject* obj1 = nil;
                    for (obj1 in variation._attributes) {
                        VariationAttribute* v_attribute = (VariationAttribute*)obj1;
                        NSString* v_attributeName = [NSString stringWithFormat:@"%@", v_attribute.name];
                        NSString* v_attributeValue = [NSString stringWithFormat:@"%@", v_attribute.value];
                        
                        if ([v_attributeValue isEqualToString:@""]) {
                            if (cInfo.selected_attributes) {
                                for (VariationAttribute* vAttr in cInfo.selected_attributes) {
                                    if([vAttr.name isEqualToString:v_attributeName]) {
                                        v_attributeValue = vAttr.value;
                                        break;
                                    }
                                }
                            }
                        }
                        //super special case
                        if (v_attributeValue == nil || [v_attributeValue isEqualToString:@""]) {
                            NSObject* objn = nil;
                            for (objn in cInfo.product._attributes) {
                                Attribute* attribute = (Attribute*)objn;
                                if ([attribute._slug isEqualToString:v_attribute.slug]) {
                                    v_attributeValue = [attribute._options objectAtIndex:0];
                                }
                            }
                        }
                        NSMutableDictionary *jAttribute = [[NSMutableDictionary alloc] init];
                        [jAttribute setObject:v_attributeName forKey:@"name"];
                        [jAttribute setObject:v_attributeValue forKey:@"value"];
                        [jsonAttributes addObject:jAttribute];
                        //                        [variations setObject:v_attributeValue forKey:v_attributeName];
                    }
                    [cartItemDict setObject:jsonAttributes forKey:@"attributes"];
                }
                else{
                    [cartItemDict setObject:jsonAttributes forKey:@"attributes"];
                }
            }
        }
        else {
            [cartItemDict setObject:jsonAttributes forKey:@"attributes"];
        }
        [cartDataArray addObject:cartItemDict];
    }
    return cartDataArray;
}
- (NSMutableDictionary*)prepareBlankOrder:(NSMutableArray*)shippingMethods paymentGateway:(TMPaymentGateway*)paymentGateway {
    AppUser* appUser = [AppUser sharedManager];
    Address* billingAddress = appUser._billing_address;
    Address* shippingAddress = appUser._shipping_address;
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *orderDict = [[NSMutableDictionary alloc] init];
    [params setObject:orderDict forKey:@"order"];
    
    if ([[Addons sharedManager] show_billing_address]) {
        NSMutableDictionary *billingParams = [[NSMutableDictionary alloc] init];
        [orderDict setObject:billingParams forKey:@"billing_address"];
        [billingParams setObject:billingAddress._first_name forKey:@"first_name"];
        [billingParams setObject:billingAddress._last_name forKey:@"last_name"];
        [billingParams setObject:billingAddress._address_1 forKey:@"address_1"];
        [billingParams setObject:billingAddress._address_2 forKey:@"address_2"];
        [billingParams setObject:billingAddress._city forKey:@"city"];
        [billingParams setObject:billingAddress._postcode forKey:@"postcode"];
        [billingParams setObject:billingAddress._email forKey:@"email"];
        [billingParams setObject:billingAddress._phone forKey:@"phone"];
        [billingParams setObject:billingAddress._stateId forKey:@"state"];
        [billingParams setObject:billingAddress._countryId forKey:@"country"];
    }
    if ([[Addons sharedManager] show_shipping_address]) {
        NSMutableDictionary *shippingParams = [[NSMutableDictionary alloc] init];
        [orderDict setObject:shippingParams forKey:@"shipping_address"];
        [shippingParams setObject:shippingAddress._first_name forKey:@"first_name"];
        [shippingParams setObject:shippingAddress._last_name forKey:@"last_name"];
        [shippingParams setObject:shippingAddress._address_1 forKey:@"address_1"];
        [shippingParams setObject:shippingAddress._address_2 forKey:@"address_2"];
        [shippingParams setObject:shippingAddress._city forKey:@"city"];
        [shippingParams setObject:shippingAddress._postcode forKey:@"postcode"];
        [shippingParams setObject:shippingAddress._stateId forKey:@"state"];
        [shippingParams setObject:shippingAddress._countryId forKey:@"country"];
    }
    
    
    if([[GuestConfig sharedInstance] guest_checkout] && appUser._isUserLoggedIn == false) {
        
    } else {
        [orderDict setObject:[NSNumber numberWithInt:appUser._id] forKey:@"customer_id"];
    }
    
    
    
    {
        [orderDict setObject:[Cart getOrderNote] forKey:@"note"];
    }
    {
        NSMutableArray *shippingLine = [[NSMutableArray alloc] init];
        if (shippingMethods != nil && [shippingMethods count] > 0) {
            [orderDict setObject:shippingLine forKey:@"shipping_lines"];
            for (TMShipping* shippingMethod in shippingMethods) {
                NSMutableDictionary *shippingMthd = [[NSMutableDictionary alloc] init];
                [shippingLine addObject:shippingMthd];
                [shippingMthd setObject:shippingMethod.shippingMethodId forKey:@"method_id"];
                [shippingMthd setObject:shippingMethod.shippingLabel forKey:@"method_title"];
                [shippingMthd setObject:[NSNumber numberWithFloat:shippingMethod.shippingCost] forKey:@"total"];
            }
        }
    }
    {
        NSMutableArray *lineItems = [[NSMutableArray alloc] init];
        [orderDict setObject:lineItems forKey:@"line_items"];
        
        CommonInfo* commonInfo = [CommonInfo sharedManager];
        BOOL woocommerce_prices_include_tax = commonInfo->_woocommerce_prices_include_tax;
        //        BOOL addTaxToProductPrice = commonInfo->_addTaxToProductPrice;
        if (woocommerce_prices_include_tax/*|| addTaxToProductPrice*/)
        {
            [orderDict setObject:[NSNumber numberWithBool:true] forKey:@"is_vat_exempt"];
        }
        
        for (Cart* cInfo in appUser._cartArray) {
            NSMutableDictionary *lineItem = [[NSMutableDictionary alloc] init];
            [lineItems addObject:lineItem];
            
            [lineItem setObject:[NSNumber numberWithInt:cInfo.product_id] forKey:@"product_id"];
            [lineItem setObject:[NSNumber numberWithInt:cInfo.count] forKey:@"quantity"];
            
            
            
            float taxIncludedInProductPrice = cInfo.originalTotal - cInfo.originalTotalExcludingTax;
            float priceToReduce = 0.0f;
            if (taxIncludedInProductPrice != 0.0f && cInfo.originalTotal != 0.0f) {
                float discountPercent = cInfo.discountTotal / cInfo.originalTotal * 100.0f;
                if (discountPercent > 0.0f) {
                    float taxAfterDiscountInProductPrice = taxIncludedInProductPrice * discountPercent / 100.0f;
                    priceToReduce = taxAfterDiscountInProductPrice;
                } else {
                    priceToReduce = taxIncludedInProductPrice;
                }
            }
            float substractPrice = (cInfo.discountTotal - priceToReduce);
            if (substractPrice < 0) {
                substractPrice *= -1;
            }
            float newTotal = 0;
            
            if (cInfo.discountTotal == 0) {
                newTotal = cInfo.originalTotal - substractPrice;
            } else {
                newTotal = cInfo.originalTotalExcludingTax - substractPrice;
            }
            
            //            float newTotal = cInfo.originalTotal - cInfo.discountTotal - priceToReduce;
            if (newTotal < 0) {
                newTotal = 0.0f;
            }
            if ([[Addons sharedManager] hide_price]) {
                [lineItem setObject:[NSNumber numberWithFloat:0] forKey:@"subtotal"];//before discount
                [lineItem setObject:[NSNumber numberWithFloat:0] forKey:@"total"];//after discount
            } else {
                [lineItem setObject:[NSNumber numberWithFloat:cInfo.originalTotal - taxIncludedInProductPrice] forKey:@"subtotal"];//before discount
                [lineItem setObject:[NSNumber numberWithFloat:newTotal] forKey:@"total"];//after discount
            }
            NSMutableDictionary *variations = [[NSMutableDictionary alloc] init];
            if (cInfo.selectedVariationId != -1) {
                [lineItem setObject:[NSNumber numberWithInt:cInfo.selectedVariationId] forKey:@"product_id"];
                if (cInfo.product._isFullRetrieved == false) {
                    [lineItem setObject:variations forKey:@"variations"];
                    for (VariationAttribute* vAttr in cInfo.selected_attributes) {
                        if (vAttr.value != nil &&
                            vAttr.name != nil &&
                            ![vAttr.value isEqualToString:@""] &&
                            ![vAttr.name isEqualToString:@""]
                            ) {
                            [variations setObject:vAttr.value forKey:vAttr.name];
                        }
                    }
                } else {
                    [lineItem setObject:variations forKey:@"variations"];
                    Variation* variation = [cInfo.product._variations getVariation:cInfo.selectedVariationId variationIndex:cInfo.selectedVariationIndex];
                    if (variation != nil) {
                        NSObject* obj1 = nil;
                        for (obj1 in variation._attributes) {
                            VariationAttribute* v_attribute = (VariationAttribute*)obj1;
                            NSString* v_attributeName = [NSString stringWithFormat:@"%@", v_attribute.name];
                            NSString* v_attributeValue = [NSString stringWithFormat:@"%@", v_attribute.value];
                            
                            if ([v_attributeValue isEqualToString:@""]) {
                                if (cInfo.selected_attributes) {
                                    for (VariationAttribute* vAttr in cInfo.selected_attributes) {
                                        if([vAttr.name isEqualToString:v_attributeName]) {
                                            //                                        v_attributeValue = [[Utility getStringIfFormatted:vAttr.value]capitalizedString];
                                            v_attributeValue = vAttr.value;
                                            break;
                                        }
                                    }
                                }
                            }
                            //super special case
                            if (v_attributeValue == nil || [v_attributeValue isEqualToString:@""]) {
                                NSObject* objn = nil;
                                for (objn in cInfo.product._attributes) {
                                    Attribute* attribute = (Attribute*)objn;
                                    if ([attribute._slug isEqualToString:v_attribute.slug]) {
                                        v_attributeValue = [attribute._options objectAtIndex:0];
                                    }
                                }
                            }
                            
                            if (v_attributeValue != nil &&
                                v_attributeName != nil &&
                                ![v_attributeValue isEqualToString:@""] &&
                                ![v_attributeName isEqualToString:@""]
                                ) {
                                [variations setObject:v_attributeValue forKey:v_attributeName];
                            }
                        }
                    }
                }
            }
        }
        for (Cart* cInfo in appUser._cartArray) {
            if (cInfo.product._type == PRODUCT_TYPE_BUNDLE && cInfo.mBundleProducts) {
                for (CartBundleItem *cartBundle in cInfo.mBundleProducts) {
                    NSMutableDictionary *lineItem = [[NSMutableDictionary alloc] init];
                    [lineItems addObject:lineItem];
                    [lineItem setObject:[NSNumber numberWithInt:cartBundle.productId] forKey:@"product_id"];
                    [lineItem setObject:[NSNumber numberWithInt:cartBundle.quantity * cInfo.count] forKey:@"quantity"];
                    [lineItem setObject:[NSNumber numberWithFloat:0] forKey:@"subtotal"];//before discount
                    [lineItem setObject:[NSNumber numberWithFloat:0] forKey:@"total"];//after discount
                }
            }
        }
    }
    {
        float totalDiscount = 0.0f;
        NSMutableArray *couponLines = [[NSMutableArray alloc] init];
        if (([Cart getAppliedCoupons] && [[Cart getAppliedCoupons] count] > 0) || ([[[CartMeta sharedInstance] getAppliedCoupons] count] > 0)) {
            [orderDict setObject:couponLines forKey:@"coupon_lines"];
        }
        for (Coupon* coupon in [Cart getAppliedCoupons]) {
            NSMutableDictionary *couponLine = [[NSMutableDictionary alloc] init];
            [couponLines addObject:couponLine];
            [couponLine setObject:[NSNumber numberWithInt:coupon._id] forKey:@"id"];
            [couponLine setObject:coupon._code forKey:@"code"];
            [couponLine setObject:[NSNumber numberWithFloat:coupon._couponDiscountOnApply] forKey:@"amount"];
            totalDiscount += coupon._couponDiscountOnApply;
        }
        
        for (AppliedCoupon* appliedCoupon in [[CartMeta sharedInstance] getAppliedCoupons]) {
            NSMutableDictionary *couponLine = [[NSMutableDictionary alloc] init];
            [couponLines addObject:couponLine];
            [couponLine setObject:appliedCoupon.title forKey:@"id"];
            [couponLine setObject:appliedCoupon.title forKey:@"code"];
            [couponLine setObject:[NSNumber numberWithFloat:appliedCoupon.discount_amount] forKey:@"amount"];
            totalDiscount += appliedCoupon.discount_amount;
        }
        
        [orderDict setObject:[NSNumber numberWithFloat:totalDiscount] forKey:@"total_discount"];
    }
    {
        NSMutableArray* fee_lines = [[NSMutableArray alloc] init];
        //shipping fees
        for (FeeData* feeData in [FeeData getAllFeeData]) {
            NSMutableDictionary* fee_line = [[NSMutableDictionary alloc] init];
            [fee_line setObject:feeData.label forKey:@"title"];
            [fee_line setObject:[NSString stringWithFormat:@"%.2f", feeData.cost] forKey:@"total"];
            [fee_lines addObject:fee_line];
        }
        //extra fees
        if (paymentGateway && paymentGateway.gatewaySettings) {
            NSMutableDictionary* fee_line = [[NSMutableDictionary alloc] init];
            [fee_line setObject:paymentGateway.gatewaySettings.extraChargesMessage forKey:@"title"];
            [fee_line setObject:[NSString stringWithFormat:@"%.2f", [paymentGateway.gatewaySettings.extraCharges floatValue]] forKey:@"total"];
            [fee_lines addObject:fee_line];
        }
        //extra checkout addons
        if ([TM_CheckoutAddon getSelectedCheckoutAddons] && [[TM_CheckoutAddon getSelectedCheckoutAddons] count] > 0) {
            for (TM_CheckoutAddon* tmCheckoutAddon in [TM_CheckoutAddon getSelectedCheckoutAddons]) {
                NSMutableDictionary* fee_line = [[NSMutableDictionary alloc] init];
                [fee_line setObject:tmCheckoutAddon.name forKey:@"title"];
                //                [fee_line setObject:[NSString stringWithFormat:@"%.2f", tmCheckoutAddon.cost] forKey:@"total"];
                [fee_line setObject:[NSString stringWithFormat:@"%.2f", tmCheckoutAddon.cost + tmCheckoutAddon.netTax] forKey:@"total"];
                [fee_line setObject:[NSString stringWithFormat:@"%.2f", tmCheckoutAddon.netTax] forKey:@"total_tax"];
                [fee_line setObject:tmCheckoutAddon.taxClass forKey:@"tax_class"];
                [fee_line setObject:[NSNumber numberWithBool:true] forKey:@"taxable"];
                [fee_lines addObject:fee_line];
            }
        }
        //pickup charges
        if ([[Addons sharedManager] show_pickup_location] && [[TM_PickupLocation getAllPickupLocations] count] > 0) {
            
            TM_PickupLocation* pckloc = [[TM_PickupLocation getAllPickupLocations] objectAtIndex:0];
            float pckCost = [pckloc.cost floatValue];
            if (pckCost > 0) {
                NSMutableDictionary* fee_line = [[NSMutableDictionary alloc] init];
                [fee_line setObject:@"Pickup Cost" forKey:@"title"];
                [fee_line setObject:[NSString stringWithFormat:@"%.2f", pckCost] forKey:@"total"];
                [fee_lines addObject:fee_line];
            }
            
        }
        if ([fee_lines count] > 0) {
            [orderDict setValue:[[NSArray alloc] initWithArray:fee_lines] forKey:@"fee_lines"];
        }
    }
    NSData * orderJsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    NSString * orderJsonString = [[NSString alloc] initWithData:orderJsonData encoding:NSUTF8StringEncoding];
    RLOG(@"====orderJsonString:\n%@\n====", orderJsonString);
    return params;
}
- (NSDictionary*)prepareShipmentJson {
    AppUser* appUser = [AppUser sharedManager];
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setObject:appUser._shipping_address._countryId forKey:@"cal_shipping_country"];
    [dict setObject:appUser._shipping_address._stateId forKey:@"cal_shipping_state"];
    [dict setObject:appUser._shipping_address._postcode forKey:@"cal_shipping_postcode"];
    [dict setObject:appUser._shipping_address._city forKey:@"cal_shipping_city"];
    return dict;
}
- (NSDictionary*)prepareBillingJson {
    AppUser* appUser = [AppUser sharedManager];
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setObject:appUser._billing_address._countryId forKey:@"cal_billing_country"];
    [dict setObject:appUser._billing_address._stateId forKey:@"cal_billing_state"];
    [dict setObject:appUser._billing_address._postcode forKey:@"cal_billing_postcode"];
    [dict setObject:appUser._billing_address._city forKey:@"cal_billing_city"];
    return dict;
}

- (NSMutableArray*)getCartStringForVerification {
    NSMutableArray* jsonArray = [[NSMutableArray alloc] init];
    for (Cart* cInfo in [Cart getAll]) {
        NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
        [dict setObject:[NSNumber numberWithInt:cInfo.product_id] forKey:@"pid"];
        [dict setObject:[NSNumber numberWithInt:cInfo.selectedVariationId] forKey:@"vid"];
        [dict setObject:[NSNumber numberWithInt:cInfo.selectedVariationIndex] forKey:@"index"];
        [jsonArray addObject:dict];
        if (cInfo.product._type == PRODUCT_TYPE_BUNDLE && cInfo.mBundleProducts) {
            for (CartBundleItem *cartBundle in cInfo.mBundleProducts) {
                NSMutableDictionary* dictBundle = [[NSMutableDictionary alloc] init];
                [dictBundle setObject:[NSNumber numberWithInt:cartBundle.productId] forKey:@"pid"];
                [dictBundle setObject:[NSNumber numberWithInt:-1] forKey:@"vid"];
                [dictBundle setObject:[NSNumber numberWithInt:-1] forKey:@"index"];
                [jsonArray addObject:dictBundle];
            }
        }
    }
    return jsonArray;
}
#pragma mark Helpers
-(void)dismissAlert:(UIAlertView *) alertView{
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
}


#pragma mark MAGENTO
- (void)sortDict:(NSMutableDictionary*)dict{
    NSMutableDictionary* tempDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
    NSMutableArray *sortedArray = [NSMutableArray arrayWithArray:[tempDict allKeys]];
    [sortedArray sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    [dict removeAllObjects];
    for (NSString *key in sortedArray) {
        RLOG(@"%@",[tempDict objectForKey:key]);
        [dict setValue:[tempDict objectForKey:key] forKey:key];
    }
}
/*
 - (void)testMagentoPost {
 NSString* oauth_nonce = [self randomStringWithLength:32];
 NSString* oauth_signature_method = @"HMAC-SHA1";
 NSString* oauth_callback = @"http://localhost";
 NSString* oauth_timestamp = [NSString stringWithFormat:@"%lu", (unsigned long)[NSDate.date timeIntervalSince1970]];
 NSString* oauth_consumer_key = @"77a25d495babcab5df31854cc6fadc97";
 NSString* oauth_consumer_secret = @"4972db1a08e3bc13252a5036ed7e93df";
 NSString* requestUrlString = @"http://192.168.21.241/magento192/oauth/initiate";
 
 NSMutableDictionary* urlParameters = [[NSMutableDictionary alloc] init];
 [urlParameters setValue:oauth_consumer_key forKey:@"oauth_consumer_key"];
 [urlParameters setValue:oauth_nonce forKey:@"oauth_nonce"];
 [urlParameters setValue:oauth_signature_method forKey:@"oauth_signature_method"];
 [urlParameters setValue:oauth_timestamp forKey:@"oauth_timestamp"];
 [urlParameters setValue:oauth_callback forKey:@"oauth_callback"];
 
 NSString* params = [NSString stringWithFormat:@"oauth_consumer_key=%@&oauth_nonce=%@&oauth_signature_method=%@&oauth_timestamp=%@&oauth_callback=%@", oauth_consumer_key, oauth_nonce, oauth_signature_method, oauth_timestamp, oauth_callback];
 NSString* urlStr = [NSString stringWithFormat:@"%@", requestUrlString];
 urlStr = [self getRFC3986:urlStr];
 NSString* paramString = [NSString stringWithFormat:@"%@", params];
 paramString = [self getRFC3986:paramString];
 
 NSString* algoString = [NSString stringWithFormat:@"POST&%@&%@", urlStr, paramString];
 NSString* algoKey = self.oauth_consumer_secret;
 NSString* _oauth_signature = [self hmacsha1:algoString key:algoKey];
 [urlParameters setValue:_oauth_signature forKey:@"oauth_signature"];
 
 
 params = [NSString stringWithFormat:@"%@&oauth_signature=%@", params, _oauth_signature];
 NSString *finalUrlStr = [NSString stringWithFormat:@"%@?%@",requestUrlString, params];
 
 
 NSDictionary* postParams = [[NSDictionary alloc] initWithDictionary:urlParameters];//[self initializeRequestStringForPostMethod:finalUrlStr];//[[NSDictionary alloc] initWithDictionary:[self prepareBlankOrder:shippingMethod]];
 
 
 
 
 
 
 
 //    NSString* URLString = [self initializeRequestStringForPostMethod:finalUrlStr];
 
 AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
 manager.responseSerializer = [AFJSONResponseSerializer serializer];
 manager.requestSerializer = [AFJSONRequestSerializer serializer];
 [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
 [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
 UIWebView* webV= [[UIWebView alloc] init];
 NSString* userAgent = [NSString stringWithFormat:@"%@", [webV stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"]];
 [manager.requestSerializer setValue:userAgent forHTTPHeaderField:@"User-Agent"];
 manager.securityPolicy.allowInvalidCertificates = YES;
 manager.securityPolicy.validatesDomainName = NO;
 [manager POST:finalUrlStr parameters:postParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
 RLOG(@"\n==ResponseObject = %@\n\n", responseObject);
 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
 RLOG(@"\n==Error = %@\n\n", error);
 NSInteger statusCode = operation.response.statusCode;
 if(statusCode == 404 || statusCode == 200) {
 
 } else {
 
 }
 }];
 }
 */
- (void)testMagentoPost {
    //initialize variables
    NSString* m_oauth_callback = @"http://localhost";
    NSString* m_oauth_nonce = [self randomStringWithLength:32];
    NSString* m_oauth_signature_method = @"HMAC-SHA1";
    NSString* m_oauth_timestamp = [NSString stringWithFormat:@"%lu", (unsigned long)[NSDate.date timeIntervalSince1970]];
    NSString* m_oauth_consumer_key = @"77a25d495babcab5df31854cc6fadc97";
    NSString* m_oauth_consumer_secret = @"4972db1a08e3bc13252a5036ed7e93df";
    NSString* strRequest = @"http://192.168.21.241/magento192/oauth/initiate";
    //initialize parameters
    NSMutableDictionary* urlParameters = [[NSMutableDictionary alloc] init];
    [urlParameters setValue:m_oauth_consumer_key forKey:@"oauth_consumer_key"];
    [urlParameters setValue:m_oauth_nonce forKey:@"oauth_nonce"];
    [urlParameters setValue:m_oauth_signature_method forKey:@"oauth_signature_method"];
    [urlParameters setValue:m_oauth_timestamp forKey:@"oauth_timestamp"];
    [urlParameters setValue:m_oauth_callback forKey:@"oauth_callback"];
    //initialize param string
    NSString* strParams = [NSString stringWithFormat:@"oauth_callback=%@&oauth_consumer_key=%@&oauth_nonce=%@&oauth_signature_method=%@&oauth_timestamp=%@",m_oauth_callback, m_oauth_consumer_key, m_oauth_nonce, m_oauth_signature_method, m_oauth_timestamp];
    NSString* temp_strRequest = [NSString stringWithFormat:@"%@", strRequest];
    NSString* temp_strParams = [NSString stringWithFormat:@"%@", strParams];
    temp_strRequest = [self getRFC3986:temp_strRequest];
    temp_strParams = [self getRFC3986:temp_strParams];
    
    NSString* algoString = [NSString stringWithFormat:@"POST&%@&%@", temp_strRequest, temp_strParams];
    NSString* algoKey = m_oauth_consumer_secret;
    NSString* m_oauth_signature = [self hmacsha1:algoString key:algoKey];
    [urlParameters setValue:m_oauth_signature forKey:@"oauth_signature"];
    
    strParams = [NSString stringWithFormat:@"%@&oauth_signature=%@", strParams, m_oauth_signature];
    NSString *URLString = [NSString stringWithFormat:@"%@?%@",strRequest, strParams];
    
    AFHTTPSessionManager* manager = [self initializeRequestManagerForPostMethod];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    
    UIWebView* webV= [[UIWebView alloc] init];
    NSString* userAgent = [NSString stringWithFormat:@"%@", [webV stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"]];
    [manager.requestSerializer setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    
    
    
    //    NSMutableDictionary *paramsToPost = [[NSMutableDictionary alloc]init];
    //    [paramsToPost setObject:@"fure@gmail.com" forKey:@"user_emailID"];
    //    [paramsToPost setObject:@"1" forKey:@"user_pass"];
    
    //    NSMutableDictionary *paramsToPost = @{ @"user_emailID": [[@"fure@gmail.com" dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0],
    //      @"user_pass": [[@"1" dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0]};
    //    NSDictionary *paramsToPost = @{
    //                                   @"user_emailID": [[@"fure@gmail.com" dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0],
    //                                   @"user_pass": [[@"1" dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0]};
    
    
    
    //
    //    urlParameters.add(new BasicNameValuePair("user_emailID", new String(Base64.encodeBase64("fure@gmail.com".getBytes())))) ;
    //    urlParameters.add(new BasicNameValuePair("user_pass", new String(Base64.encodeBase64("1".getBytes()))));
    
    
    
    [manager POST:URLString parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        RLOG(@"\n==ResponseObject = %@\n\n", responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        RLOG(@"\n==Error = %@\n\n", error);
        RLOG(@"\nlocalizedDescription = %@\nlocalizedFailureReason = %@\nerrorCode = %d", [error localizedDescription], [error localizedFailureReason], (int)[error code]);
        NSInteger statusCode = 0;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = httpResponse.statusCode;
        }
        if(statusCode == 404 || statusCode == 200) {
            
        } else {
            
        }
    }];
    
    
    //    NSMutableDictionary *paramsToPost = [[NSMutableDictionary alloc] initWithDictionary:urlParameters];
    //    NSMutableDictionary *subParams = [[NSMutableDictionary alloc]init];
    //    [paramsToPost setObject:subParams forKey:@"customer"];
    //    [subParams setObject:@"rishabh" forKey:@"first_name"];
    
    //    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    //    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Accept"];
    
    //    [manager.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    //    [manager.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Accept"];
    //    NSError *error;
    //    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:urlParameters options:0 error:&error];
    //    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    //        [manager setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    
    
    
}
- (void)testWooCommercePost {
    NSString* oauth_nonce = [self randomStringWithLength:32];
    NSString* oauth_signature_method = @"HMAC-SHA1";
    NSString* oauth_timestamp = [NSString stringWithFormat:@"%lu", (unsigned long)[NSDate.date timeIntervalSince1970]];
    NSString* oauth_consumer_key = @"ck_63829de745135b919f6518776e4940ad1e7ca487";
    NSString* oauth_consumer_secret = @"cs_6c72af7acb9c912f8d384e4714d352601ce6e7b5";
    NSString* requestUrlString = @"http://playcontest.in/demo/wordpress/wc-api/v2/customers/2";
    NSMutableDictionary* urlParameters = [[NSMutableDictionary alloc] init];
    [urlParameters setValue:oauth_consumer_key forKey:@"oauth_consumer_key"];
    [urlParameters setValue:oauth_nonce forKey:@"oauth_nonce"];
    [urlParameters setValue:oauth_signature_method forKey:@"oauth_signature_method"];
    [urlParameters setValue:oauth_timestamp forKey:@"oauth_timestamp"];
    
    NSString* params = [NSString stringWithFormat:@"oauth_consumer_key=%@&oauth_nonce=%@&oauth_signature_method=%@&oauth_timestamp=%@", oauth_consumer_key, oauth_nonce, oauth_signature_method, oauth_timestamp];
    NSString* urlStr = [NSString stringWithFormat:@"%@", requestUrlString];
    urlStr = [self getRFC3986:urlStr];
    NSString* paramString = [NSString stringWithFormat:@"%@", params];
    paramString = [self getRFC3986:paramString];
    NSString* algoString = [NSString stringWithFormat:@"POST&%@&%@", urlStr, paramString];
    NSString* algoKey = self.oauth_consumer_secret;
    NSString* _oauth_signature = [self hmacsha1:algoString key:algoKey];
    [urlParameters setValue:_oauth_signature forKey:@"oauth_signature"];
    params = [NSString stringWithFormat:@"%@&oauth_signature=%@", params, _oauth_signature];
    NSString *finalUrlStr = [NSString stringWithFormat:@"%@?%@",requestUrlString, params];
    NSDictionary* postParams = [[NSDictionary alloc] initWithDictionary:urlParameters];
    AFHTTPSessionManager* manager = [self initializeRequestManagerForPostMethod];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    UIWebView* webV= [[UIWebView alloc] init];
    NSString* userAgent = [NSString stringWithFormat:@"%@", [webV stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"]];
    [manager.requestSerializer setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    NSMutableDictionary *paramsToPost = [[NSMutableDictionary alloc]init];
    NSMutableDictionary *subParams = [[NSMutableDictionary alloc]init];
    [paramsToPost setObject:subParams forKey:@"customer"];
    [subParams setObject:@"rishabh" forKey:@"first_name"];
    [manager POST:finalUrlStr parameters:paramsToPost constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        RLOG(@"\n==ResponseObject = %@\n\n", responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        RLOG(@"\n==Error = %@\n\n", error);
        NSInteger statusCode = 0;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = httpResponse.statusCode;
        }
        if(statusCode == 404 || statusCode == 200) {
            
        } else {
            
        }
    }];
}

#pragma mark WaitList members
-(void)getWaitListProductIds:(int)userId
                     emailId:(NSString*)emailId
                     success:(void(^)(id data))success
                     failure:(void(^)(NSString* error))failure {
    NSDictionary *params = @{@"type": base64_str(@"view"),
                             @"user_id": base64_int(userId),
                             @"email_id": base64_str(emailId)};
    RLOG(@"params = %@", params);
    AFHTTPSessionManager *manager =  [self getHttpSessionManagerForPost:@"text/html"];
    [manager POST:self.url_custom_waitlist parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {}
         progress:^(NSProgress * _Nonnull uploadProgress) {
         } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             NSDictionary *json = [self responseToDictionary:responseObject];
             NSArray *jsonArray = [self responseToArray:responseObject];
             if(json != nil && ![self hasResponseError:json]) {
                 @try {
                     [WC2X_JsonHelper createWaitList:json];
                     success(json);
                     return;
                 } @catch(NSException* e) {
                     RLOG(@"updateWaitListProduct: %@", e);
                 }
             }
             failure(@"Error while subscribing/unsubscribing WaitList for product.");
         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             [self handleResponseError:task error:error failure:failure];
         }];
}

-(void)updateWaitListProduct:(NSDictionary*)params
                     success:(void(^)(id data))success
                     failure:(void(^)(NSString* error))failure {
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [manager POST:self.url_custom_waitlist parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(nil);
        return;
        NSDictionary *json = [Utility getJsonObject:responseObject];
        if (json == nil) {
            RLOG(@"No data received / Invalid Json");
            failure(@"Error invalid Response.");
        } else {
            RLOG(@"json: %@", json);
            NSString* errorStr = [json valueForKey:@"error"];
            NSString* messageStr = [json valueForKey:@"message"];
            NSString* statusStr = [json valueForKey:@"status"];
            RLOG(@"messageStr: %@", messageStr);
            if ([statusStr isEqualToString:@"success"]) {
                success(nil);
            } else {
                failure(messageStr);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        RLOG(@"\n==Error = %@\n\n", error);
        [self handleResponseError:task error:error failure:failure];
    }];
    
    
    
    
    //    RLOG(@"params = %@", params);
    //    AFHTTPSessionManager *manager =  [self getHttpSessionManagerForPost:@"text/html"];
    //    [manager POST:self.url_custom_waitlist parameters:params progress:nil success:^(NSURLSessionDataTask* _Nonnull task, id _Nonnull responseObject) {
    //        success(nil);//HACK BECAUSE SERVER RESPONSE IS IN FORM OF true/false NOT IN JSON.
    //        return;
    //    } failure:^(NSURLSessionDataTask* _Nonnull task, NSError* _Nonnull error) {
    //        [self handleResponseError:task error:error failure:failure];
    //    }];
}

#pragma mark WishList members
- (void) getWishListProducts:(int)userId
                     emailId:(NSString*)emailId
                     success:(void(^)(id data))success
                     failure:(void(^)(NSString* error))failure {
    NSDictionary *params = @{@"type": base64_str(@"products"),
                             @"user_id": base64_int(userId),
                             @"email_id": base64_str(emailId)};
    AFHTTPSessionManager *manager =  [self getHttpSessionManagerForPost:@"text/html"];
    [manager POST:self.url_custom_wishlist parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {}
         progress:^(NSProgress * _Nonnull uploadProgress) {
         } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             NSDictionary *json = [self responseToDictionary:responseObject];
             if(json != nil && ![self hasResponseError:json]) {
                 @try {
                     [WC2X_JsonHelper createWishList:json];
                     success(json);
                     return;
                 } @catch(NSException* e) {
                     RLOG(@"updateWaitListProduct: %@", e);
                 }
             }
             failure(@"Error while subscribing/unsubscribing WaitList for product.");
         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             [self handleResponseError:task error:error failure:failure];
         }];
}

- (void) getWishListDetails:(int)userId
                    emailId:(NSString*)emailId
                    success:(void(^)(id data))success
                    failure:(void(^)(NSString* error))failure {
    NSDictionary *params = @{@"type": base64_str(@"details"),
                             @"user_id": base64_int(userId),
                             @"email_id": base64_str(emailId)};
    AFHTTPSessionManager* manager = [self initializeRequestManagerForPostMethod];
    [manager POST:self.url_custom_wishlist parameters:params progress:nil success:^(NSURLSessionDataTask* _Nonnull task, id _Nonnull responseObject) {
        if (responseObject) {
            id responseObj = [Utility getJsonObject:responseObject];
            RLOG(@"responseObj = %@",responseObj);
            if(responseObj != nil && [responseObj isKindOfClass:[NSDictionary class]]) {
                NSDictionary *json = responseObj;
                if (![self hasResponseError:json]) {
                    @try {
                        [WC2X_JsonHelper parseWishListDetails:json];
                        success(json);
                        return;
                    } @catch(NSException* e) {
                        RLOG(@"getWishListDetails: %@", e);
                    }
                }
            }
            failure(@"Error while getting custom WishList details.");
        } else {
            failure(@"Error while getting custom WishList details.");
        }
    } failure:^(NSURLSessionDataTask* _Nonnull task, NSError* _Nonnull error) {
        [self handleResponseError:task error:error failure:failure];
    }];
}

- (void) syncWishListProduct:(NSDictionary*)params
                     success:(void(^)(id data))success
                     failure:(void(^)(NSString* error))failure {
    AFHTTPSessionManager *manager =  [self getHttpSessionManagerForPost:@"text/html"];
    [manager POST:self.url_custom_wishlist parameters:params progress:nil success:^(NSURLSessionDataTask* _Nonnull task, id _Nonnull responseObject) {
        RLOG(@"responseObject = %@", responseObject);
        
        id response = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        if(response != nil && [response isKindOfClass:[NSDictionary class]]) {
            NSDictionary *json = response;
            if (![self hasResponseError:json]) {
                success(json);
                return;
            }
        }
        failure(@"Error while syncing custom WishList product.");
    } failure:^(NSURLSessionDataTask* _Nonnull task, NSError* _Nonnull error) {
        [self handleResponseError:task error:error failure:failure];
    }];
}
#pragma mark Product Delivery Data Plugin
- (void)postOrderShippingDataPRDD:(int)orderId
                  shippingBunches:(NSDictionary*)shippingBunches
                          success:(void(^)(id data))success
                          failure:(void(^)(NSString* error))failure {
    [Utility createCustomizedLoadingBar:Localize(@"updating_order") isBottomAlign:false isClearViewEnabled:false isShadowEnabled:true];
    NSString* requestUrl = [NSString stringWithFormat:@"%@", [[[DataManager sharedManager] tmDataDoctor] url_prdd_plugin_data]];
    NSMutableDictionary *paramsM = [[NSMutableDictionary alloc] init];
    
    [paramsM setObject:base64_str(@"order-meta") forKey:@"type"];
    [paramsM setObject:base64_int(orderId) forKey:@"orderid"];
    if (shippingBunches) {
        NSMutableArray* newShippingBunches = [[NSMutableArray alloc] init];
        NSArray* bunchesKeys = [shippingBunches allKeys];
        for (int i = 0; i < [bunchesKeys count]; i++) {
            NSDictionary* dict = [shippingBunches objectForKey:[NSNumber numberWithInt:i]];
            [dict setValue:@"" forKey:@"datetime"];
            [dict setValue:@"" forKey:@"prdd_day_obj"];
            [dict setValue:@"" forKey:@"prdd_time_obj"];
            [newShippingBunches addObject:dict];
        }
        NSData* shippingBunchJsonData = [NSJSONSerialization dataWithJSONObject:newShippingBunches options:0 error:nil];
        NSString * shippingBunchJsonString = [[NSString alloc] initWithData:shippingBunchJsonData encoding:NSUTF8StringEncoding];
        [paramsM setObject:shippingBunchJsonString forKey:@"shipping"];
    }
    
    NSDictionary *params = [[NSDictionary alloc] initWithDictionary:paramsM];
    
    @try {
        NSData* orderShippingData = [NSJSONSerialization dataWithJSONObject:paramsM options:0 error:nil];
        NSString* orderShippingDataPRDD = [[NSString alloc] initWithData:orderShippingData encoding:NSUTF8StringEncoding];
        RLOG(@"====orderShippingDataPRDD:\n%@\n====", orderShippingDataPRDD);
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [manager POST:requestUrl parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
    } progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
        id responseObj = [Utility getJsonObject:responseObject];
        NSDictionary *json = [self responseToDictionary:responseObject];
        if(json != nil && ![self hasResponseError:json]) {
            success(json);
            return;
        }
        if (json == nil) {
            RLOG(@"No data received / Invalid Json");
            failure(@"postOrderShippingDataPRDD: No data received / Invalid Json");
        } else {
            RLOG(@"json_dict: %@", json);
            NSString* statusStr = [json valueForKey:@"status"];
            if ([statusStr isEqualToString:@"success"]) {
                success(json);
                return;
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
        failure(@"postOrderShippingDataPRDD");
    }];
}
- (void)getProductDeliveryDataPRDD:(int)productId
                           success:(void(^)(id data))success
                           failure:(void(^)(NSString* error))failure {
    NSDictionary *params = @{@"type": base64_str(@"product"),
                             @"pid": base64_int(productId)};
    RLOG(@"params = %@", params);
    AFHTTPSessionManager *manager =  [self getHttpSessionManagerForPost:@"text/html"];
    [manager POST:self.url_prdd_plugin_data parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {}
         progress:^(NSProgress * _Nonnull uploadProgress) {
         } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             NSDictionary *json = [self responseToDictionary:responseObject];
             NSArray *jsonArray = [self responseToArray:responseObject];
             if(json != nil && ![self hasResponseError:json]) {
                 @try {
                     [self.tmJsonHelper parse_pddData:json productId:productId];
                     //                     [WC2X_JsonHelper createWaitList:json];
                     success(json);
                     return;
                 } @catch(NSException* e) {
                     RLOG(@"updateWaitListProduct: %@", e);
                 }
             }
             failure(@"Error while subscribing/unsubscribing WaitList for product.");
         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             [self handleResponseError:task error:error failure:failure];
         }];
}
#pragma mark Sponsor Your Friend members
- (void)sponsorYourFriend:(NSDictionary*)params
                  success:(void(^)(NSString* msg))success
                  failure:(void(^)(NSString* msg))failure {
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [manager POST:self.url_custom_sponsor_friend parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *json = [Utility getJsonObject:responseObject];
        if (json == nil) {
            RLOG(@"No data received / Invalid Json");
            failure(@"Error while sending sponsor your friend request..");
        } else {
            RLOG(@"json: %@", json);
            //            NSString* errorStr = [json valueForKey:@"error"];
            //            NSString* messageStr = [json valueForKey:@"message"];
            NSString* statusStr = [json valueForKey:@"status"];
            //            RLOG(@"messageStr: %@", messageStr);
            if ([statusStr isEqualToString:@"success"]) {
                success(@"Request for sponsor friend sent successfully.");
            } else {
                failure(@"Error while sending sponsor your friend request.");
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        RLOG(@"\n==Error = %@\n\n", error);
        failure(@"Error while sending sponsor your friend request.");
    }];
}




#pragma mark Reward Points members


- (void) getUserRewardPoints:(NSDictionary*)params
                     success:(void(^)(id data))success
                     failure:(void(^)(NSString* error))failure {
    AFHTTPSessionManager *manager =  [self getHttpSessionManagerForPost:@"text/html"];
    [manager POST:self.url_custom_reward_points parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {}
         progress:^(NSProgress * _Nonnull uploadProgress) {
         } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             NSDictionary *json = [self responseToDictionary:responseObject];
             if(json != nil && ![self hasResponseError:json]) {
                 @try {
                     [WC2X_JsonHelper parseUserRewardPoints:json];
                     success(json);
                     return;
                 } @catch(NSException* e) {
                     RLOG(@"getUserRewardPoints: %@", e);
                 }
             }
             failure(@"Error while retrieving user reward & discount points.");
         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             [self handleResponseError:task error:error failure:failure];
         }];
}

- (void) getProductRewardPoints:(NSDictionary*)params
                        success:(void(^)(id data))success
                        failure:(void(^)(NSString* error))failure {
    AFHTTPSessionManager *manager =  [self getHttpSessionManagerForPost:@"text/html"];
    [manager POST:self.url_custom_reward_points parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {}
         progress:^(NSProgress * _Nonnull uploadProgress) {
         } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             NSDictionary *json = [self responseToDictionary:responseObject];
             if(json != nil && ![self hasResponseError:json]) {
                 @try {
                     [WC2X_JsonHelper parseProductRewardPoints:json];
                     success(json);
                     return;
                 } @catch(NSException* e) {
                     RLOG(@"getProductRewardPoints: %@", e);
                 }
             }
             failure(@"Error while retrieving product reward & discount points.");
         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             [self handleResponseError:task error:error failure:failure];
         }];
}

- (void) getOrderRewardPoints:(NSDictionary*)params
                      success:(void(^)(id data))success
                      failure:(void(^)(NSString* error))failure {
    AFHTTPSessionManager *manager =  [self getHttpSessionManagerForPost:@"text/html"];
    [manager POST:self.url_custom_reward_points parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {}
         progress:^(NSProgress * _Nonnull uploadProgress) {
         } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             NSDictionary *json = [Utility getJsonObject:responseObject];
             if(json != nil && ![self hasResponseError:json]) {
                 @try {
                     [WC2X_JsonHelper parseOrderRewardPoints:json];
                     success(json);
                     return;
                 } @catch(NSException* e) {
                     RLOG(@"getOrderRewardPoints: %@", e);
                 }
             }
             failure(@"Error while retrieving order reward points.");
         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             [self handleResponseError:task error:error failure:failure];
         }];
}
- (void)getOrderDeliverySlots:(NSDictionary*)params
                      success:(void(^)(id data))success
                      failure:(void(^)(NSString* error))failure {
    AFHTTPSessionManager *manager =  [self getHttpSessionManagerForPost:@"text/html"];
    [manager POST:self.url_delivery_slots parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {}
         progress:^(NSProgress * _Nonnull uploadProgress) {
         } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             NSDictionary *json = [self responseToDictionary:responseObject];
             if(json != nil && ![self hasResponseError:json]) {
                 @try {
                     [WC2X_JsonHelper parseOrderDeliveySlots:json];
                     success(json);
                     return;
                 } @catch(NSException* e) {
                     RLOG(@"getOrderDateAndTimeSlots: %@", e);
                 }
             }
             failure(@"error");
         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             //             [self handleResponseError:task error:error failure:failure];
             NSInteger statusCode = error.code;
             if(statusCode == 404 || statusCode == 200) {
                 failure(@"failure");
             } else if (statusCode == -1016){
                 failure(@"failure");
             } else {
                 failure(@"retry");
             }
         }];
}
- (void)getOrderTimeSlots:(NSDictionary*)params
                  success:(void(^)(id data))success
                  failure:(void(^)(NSString* error))failure {
    return failure(@"code not implemented.");
    
    AFHTTPSessionManager *manager =  [self getHttpSessionManagerForPost:@"text/html"];
    [manager POST:self.url_local_pickup_time_select parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {}
         progress:^(NSProgress * _Nonnull uploadProgress) {
         } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             NSDictionary *json = [self responseToDictionary:responseObject];
             if(json != nil && ![self hasResponseError:json]) {
                 @try {
                     //                     [WC2X_JsonHelper parseOrderRewardPoints:json];
                     success(json);
                     return;
                 } @catch(NSException* e) {
                     RLOG(@"getOrderDateAndTimeSlots: %@", e);
                 }
             }
             failure(@"Error while retrieving order time slots.");
         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             //             [self handleResponseError:task error:error failure:failure];
             NSInteger statusCode = error.code;
             if(statusCode == 404 || statusCode == 200) {
                 failure(@"failure");
             } else if (statusCode == -1016){
                 failure(@"failure");
             } else {
                 failure(@"retry");
             }
         }];
}
- (void) updateOrderRewardPoints:(NSDictionary*)params
                         success:(void(^)(id data))success
                         failure:(void(^)(NSString* error))failure {
    AFHTTPSessionManager *manager =  [self getHttpSessionManagerForPost:@"text/html"];
    [manager POST:self.url_custom_reward_points parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {}
         progress:^(NSProgress * _Nonnull uploadProgress) {
         } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             NSDictionary *json = [self responseToDictionary:responseObject];
             if(json != nil && ![self hasResponseError:json]) {
                 success(json);
                 return;
             }
             
             if (json == nil) {
                 RLOG(@"No data received / Invalid Json");
             } else {
                 RLOG(@"json_dict: %@", json);
                 NSString* errorStr = [json valueForKey:@"error"];
                 NSString* messageStr = [json valueForKey:@"message"];
                 NSString* statusStr = [json valueForKey:@"status"];
                 RLOG(@"messageStr: %@", messageStr);
                 if ([statusStr isEqualToString:@"success"]) {
                     success(json);
                     return;
                 }
             }
             
             failure(@"Error while updating order reward & discount points.");
         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             [self handleResponseError:task error:error failure:failure];
         }];
}

- (void) getCartProductsRewardPoints:(NSDictionary*)parameters
                             success:(void(^)(id data))success
                             failure:(void(^)(NSString* error))failure {
    AFHTTPSessionManager *manager =  [self getHttpSessionManagerForPost:@"text/html"];
    [manager POST:self.url_custom_reward_points parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {}
         progress:^(NSProgress * _Nonnull uploadProgress) {
         } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             NSDictionary *json = [self responseToDictionary:responseObject];
             if(json != nil && ![self hasResponseError:json]) {
                 @try {
                     [WC2X_JsonHelper parseCartProductsRewardPoints:json];
                     success(json);
                     return;
                 } @catch(NSException* e) {
                     RLOG(@"getCartProductsRewardPoints: %@", e);
                 }
             }
             failure(@"Error while retrieving cart products reward points.");
         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             [self handleResponseError:task error:error failure:failure];
         }];
}

- (void)getCustomMenuItems:(NSArray*) menuIds
                   success:(void(^)(id data))success
                   failure:(void(^)(NSString* error))failure {
    NSMutableString *ids = [[NSMutableString alloc]init];
    if(menuIds != nil) {
        NSInteger count = [menuIds count];
        for(int i = 0; i < count; i++) {
            [ids appendString:[[menuIds objectAtIndex:i] stringValue]];
            if(i < count - 1)
                [ids appendString:@","];
        }
        ids = [NSMutableString stringWithFormat:@"[%@]", ids];
    }
    
    NSDictionary* parameters = @{@"menu_ids": base64_str(menuIds)};
    [self sendHttpGetRequest:self.request_url_menu_items parameters:parameters failure:failure response:^(id data) {
        NSArray *array = [Utility getJsonArray:data];
        if(array != nil) {
            @try {
                [WC2X_JsonHelper loadPluginDataForMenuItems:array];
                success(array);
                return;
            } @catch(NSException* e) {
                RLOG(@"getCustomMenuItems: %@", e);
            }
        }
        failure(@"Error while retrieving custom menu items.");
    }];
}

- (void) getShipmentTrackingId:(NSString*)shipmentType
                       orderId:(int)orderId
                       success:(void(^)(id data))success
                       failure:(void(^)(NSString* error))failure {
    
    NSString* orderIds = [NSString stringWithFormat:@"[%d]", orderId];
    NSDictionary* params = @{@"ship_type": base64_str(shipmentType), @"order_ids": base64_str(orderIds)};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [manager POST:self.url_shipment_track parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *array = [Utility getJsonArray:responseObject];
        if (array == nil) {
            RLOG(@"No data received / Invalid array");
            failure(@"Error while getting shipment tracking.");
        } else {
            RLOG(@"array: %@", array);
            NSDictionary* json = nil;
            if (array && [array count] > 0) {
                json = [array objectAtIndex:0];
            }
            success(json);
            //            NSString* errorStr = [json valueForKey:@"error"];
            //            NSString* messageStr = [json valueForKey:@"message"];
            //            NSString* statusStr = [json valueForKey:@"status"];
            //            RLOG(@"messageStr: %@", messageStr);
            //            if ([statusStr isEqualToString:@"success"]) {
            //                success(@"Request for sponsor friend sent successfully.");
            //            } else {
            //                failure(@"Error while sending sponsor your friend request.");
            //            }
            //            failure(@"FAILURE");
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        RLOG(@"\n==Error = %@\n\n", error);
        failure(@"FAILURE");
    }];
    
    
    //    [self sendHttpPostRequest:self.url_shipment_track parameters:parameters failure:failure response:^(id data) {
    //        id response = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    //        if(response != nil && [response isKindOfClass:[NSDictionary class]]) {
    //            NSDictionary *json = response;
    //            if (![self hasResponseError:json]) {
    //                @try {
    //                    [WC2X_JsonHelper parseCartProductsRewardPoints:json];
    //                    success(json);
    //                    return;
    //                } @catch(NSException* e) {
    //                    RLOG(@"getShipmentTrackingId: %@", e);
    //                }
    //            }
    //        }
    //        failure(@"Error while retrieving product reward & discount points.");
    //    }];
}

- (void) getProductsBrandNames:(NSArray*)productIds
                       success:(void(^)(id data))success
                       failure:(void(^)(NSString* error))failure {
    
    NSString* pids = [NSString stringWithFormat:@"[%@]", [NSArray join:productIds]];
    
    NSDictionary* params = @{@"pids": base64_str(pids)};
    
    AFHTTPSessionManager *manager =  [self getHttpSessionManagerForPost:@"text/html"];
    [manager POST:self.url_products_brand_names parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {}
         progress:^(NSProgress * _Nonnull uploadProgress) {
         } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             NSDictionary *json = [self responseToDictionary:responseObject];
             if(json != nil && ![self hasResponseError:json]) {
                 @try {
                     [WC2X_JsonHelper parseProductsBrandNames:json];
                     success(json);
                     return;
                 } @catch(NSException* e) {
                     RLOG(@"getProductsBrandNames: %@", e);
                 }
             }
             failure(@"Error while retrieving product brand names.");
         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             [self handleResponseError:task error:error failure:failure];
         }];
}

- (void) getProductsPriceLabels:(NSArray*)productIds
                        success:(void(^)(id data))success
                        failure:(void(^)(NSString* error))failure {
    NSString* pids = [NSString stringWithFormat:@"[%@]", [NSArray join:productIds]];
    
    NSDictionary* params = @{@"pids": base64_str(pids)};
    
    AFHTTPSessionManager *manager =  [self getHttpSessionManagerForPost:@"text/html"];
    [manager POST:self.url_products_price_labels parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {}
         progress:^(NSProgress * _Nonnull uploadProgress) {
         } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             NSDictionary *json = [self responseToDictionary:responseObject];
             if(json != nil && ![self hasResponseError:json]) {
                 @try {
                     [WC2X_JsonHelper parseProductsPriceLabels:json];
                     success(json);
                     return;
                 } @catch(NSException* e) {
                     RLOG(@"getProductsPriceLabels: %@", e);
                 }
             }
             failure(@"Error while retrieving product price labels.");
         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             [self handleResponseError:task error:error failure:failure];
         }];
}

- (void) getProductsQuantityRules:(NSArray*)productIds
                          success:(void(^)(id data))success
                          failure:(void(^)(NSString* error))failure {
    NSString* pids = [NSString stringWithFormat:@"[%@]", [NSArray join:productIds]];
    
    NSDictionary* params = @{@"pids": base64_str(pids)};
    
    AFHTTPSessionManager *manager =  [self getHttpSessionManagerForPost:@"text/html"];
    [manager POST:self.url_incremental_product_quantities parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {}
         progress:^(NSProgress * _Nonnull uploadProgress) {
         } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             NSDictionary *json = [self responseToDictionary:responseObject];
             if(json != nil && ![self hasResponseError:json]) {
                 @try {
                     [WC2X_JsonHelper parseProductsQuantityRules:json];
                     success(json);
                     return;
                 } @catch(NSException* e) {
                     RLOG(@"getProductsQuantityRules: %@", e);
                 }
             }
             failure(@"Error while retrieving product quantity rules.");
         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             [self handleResponseError:task error:error failure:failure];
         }];
}

- (void) getProductsPincodeSettings:(void(^)(id data))success
                            failure:(void(^)(NSString* error))failure {
    [self sendHttpGetRequest:self.url_product_pin_code parameters:nil failure:failure response:^(id data) {
        NSDictionary *json = [self responseToDictionary:data];
        if(json != nil && ![self hasResponseError:json]) {
            @try {
                [WC2X_JsonHelper parseProductsPincodeSettings:json];
                success(json);
                return;
            } @catch(NSException* e) {
                RLOG(@"getProductsPincodeSettings: %@", e);
            }
        }
        failure(@"Error while retrieving products pincode settings.");
    }];
}
- (void)getPickupLocations:(void(^)(id data))success
                   failure:(void(^)(NSString* error))failure {
    //    self.url_pick_up_locations = @"http://demo001.aboutfaces.co.in/wp-tm-ext-store-notify/api/woocommerce-shipping-local-pickup-plus/";
    [self sendHttpGetRequest:self.url_pick_up_locations parameters:nil failure:failure response:^(id data) {
        NSArray *array = [self responseToArray:data];
        if(array != nil && [array isKindOfClass:[NSArray class]]) {
            @try {
                [WC2X_JsonHelper parsePickupLocations:array];
                success(array);
                return;
            } @catch(NSException* e) {
                RLOG(@"getPickupLocations: %@", e);
            }
        }
        failure(@"Error while retrieving pickup locations.");
    }];
}
#pragma mark HTTP GET & POST request and error handlers

- (void) sendHttpGetRequest:(NSString*) url
                 parameters:(id)parameters
                    failure:(void(^)(NSString* error))failure
                   response:(void(^)(id data))response {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [manager POST:url parameters:parameters
         progress:nil
          success:^(NSURLSessionDataTask* _Nonnull task, id _Nonnull responseObject) {
            		response(responseObject);
          } failure:^(NSURLSessionDataTask* _Nonnull task, NSError* _Nonnull error) {
              [self handleResponseError:task error:error failure:failure];
          }];
}
- (void)blockCode:(id)aviObj successCallBack:(void(^)(NSString* str1, NSString* str2))success failureCallBack:(void(^)(NSString* str1, NSString* str2))failure {
    if (aviObj) {
        success(@"ss", @"pp");
    } else {
        failure(@"ff", @"tt");
    }
}
- (void)testBlockCode {
    id aviObject = nil;
    [self blockCode:aviObject successCallBack:^(NSString *str1, NSString *str2) {
        RLOG(@"str1=%@, str2=%@", str1, str2);
    } failureCallBack:^(NSString *str1, NSString *str2) {
        RLOG(@"str1=%@, str2=%@", str1, str2);
    }];
}
- (void)sendHttpPostRequest:(NSString*) url
                 parameters:(id)parameters
                    failure:(void(^)(NSString* error))failure
                   response:(void(^)(id data))response {
    AFHTTPSessionManager* manager = [self initializeRequestManagerForPostMethod];
    
    //    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [manager POST:url
       parameters:parameters
         progress:nil
          success:^(NSURLSessionDataTask* _Nonnull task, id _Nonnull responseObject) {
              if (responseObject) {
                  id responseObj = [Utility getJsonObject:responseObject];
                  RLOG(@"responseObj = %@",responseObj);
                  response(responseObj);
              } else {
                  [self handleResponseError:task error:nil failure:failure];
              }
          } failure:^(NSURLSessionDataTask* _Nonnull task, NSError* _Nonnull error) {
              [self handleResponseError:task error:error failure:failure];
          }];
}

- (NSDictionary*) responseToDictionary:(id _Nonnull) response {
    NSDictionary* dictionary = nil;
    if(response != nil) {
        if(![response isKindOfClass:[NSDictionary class]]) {
            @try {
                dictionary = [NSJSONSerialization JSONObjectWithData:response options:0 error:nil];
            } @catch (NSException *exception) {
            }
        } else {
            dictionary = response;
        }
        
        
        if (dictionary == nil) {
            dictionary = [Utility getJsonObject:response];
        }
    }
    
    
    return dictionary;
}
- (NSArray*) responseToArray:(id _Nonnull) response {
    NSArray* array = nil;
    if(response != nil) {
        if(![response isKindOfClass:[NSArray class]]) {
            @try {
                array = [NSJSONSerialization JSONObjectWithData:response options:0 error:nil];
            } @catch (NSException *exception) {
            }
        } else {
            if (array == nil) {
                array = [Utility getJsonArray:response];
            }
            if (array == nil) {
                array = response;
            }
        }
    }
    return array;
}
- (BOOL)hasResponseError:(NSDictionary*)dictionary {
    RLOG(@"\n==ResponseObject = %@\n\n", dictionary);
    if ([dictionary isKindOfClass:[NSDictionary class]] == false) {
        return false;
    }
    
    if (dictionary[@"status"] && [dictionary[@"status"] isEqualToString:@"failed"]) {
        return true;
    }
    return false;
    
    //    return dictionary[@"error"] || dictionary[@"errors"];
}

- (void) handleResponseError:(NSURLSessionDataTask*)task
                       error:(NSError*)error
                     failure:(void(^)(NSString* error))failure {
    RLOG(@"\n==Error = %@\n\n", error);
    RLOG(@"\nlocalizedDescription = %@\nlocalizedFailureReason = %@\n", [error localizedDescription], [error localizedFailureReason]);
    failure([error localizedFailureReason]);
}

#pragma mark Reservation&ContactForm Data
- (void)getContactForm3InBackground:(int)formId
                            success:(void(^)(id data))success
                            failure:(void(^)(NSString* error))failure {
    NSString* requestUrl = [NSString stringWithFormat:@"%@/wp-tm-ext-store-notify/api/contact_form/", self.baseUrl];
    NSDictionary *params = @{@"type": base64_str(@"contact_form"),
                             @"form_id": base64_int(0)};
    RLOG(@"getContactForm3InBackground: requestUrl: %@", requestUrl);
    RLOG(@"getContactForm3InBackground: params: %@", params);
    AFHTTPSessionManager *manager =  [self getHttpSessionManagerForPost:@"text/html"];
    [manager POST:requestUrl
       parameters:params
constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {}
         progress:^(NSProgress * _Nonnull uploadProgress) { }
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSDictionary *json = [Utility getJsonObject:responseObject];
              if (json) {
                  [self.tmJsonHelper parse_ContactForm3Config:json];
                  success(json);
                  RLOG(@"getContactForm3InBackground: success: %@", json);
                  return;
              }
              failure(@"failure");
              RLOG(@"getContactForm3InBackground: failure");
          }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              failure(@"failure");
              RLOG(@"getContactForm3InBackground: failure");
          }
     ];
}
- (void)getReservationFormInBackground:(int)formId
                               success:(void(^)(id data))success
                               failure:(void(^)(NSString* error))failure {
    NSString* requestUrl = [NSString stringWithFormat:@"%@/wp-tm-ext-store-notify/api/reservation_form/", self.baseUrl];
    NSDictionary *params = @{@"type": base64_str(@"reservation_form"),
                             @"form_id": base64_int(25)};
    RLOG(@"getReservationFormInBackground: requestUrl: %@", requestUrl);
    RLOG(@"getReservationFormInBackground: params: %@", params);
    AFHTTPSessionManager *manager =  [self getHttpSessionManagerForPost:@"text/html"];
    [manager POST:requestUrl
       parameters:params
constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {}
         progress:^(NSProgress * _Nonnull uploadProgress) { }
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSDictionary *json = [Utility getJsonObject:responseObject];
              if (json) {
                  [self.tmJsonHelper parse_ReservationFormConfig:json];
                  success(json);
                  RLOG(@"getReservationFormInBackground: success: %@", json);
                  return;
              }
              failure(@"failure");
              RLOG(@"getReservationFormInBackground: failure");
          }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              failure(@"failure");
              RLOG(@"getReservationFormInBackground: failure");
          }
     ];
}
- (void)postContactForm3InBackground:(int)formId
                                name:(NSString*)name
                               email:(NSString*)email
                             message:(NSString*)message
                             success:(void(^)(id data))success
                             failure:(void(^)(NSString* error))failure {
    NSString* requestUrl = [NSString stringWithFormat:@"%@/wp-tm-ext-store-notify/api/contact_form/", self.baseUrl];
    NSMutableDictionary *paramsM = [[NSMutableDictionary alloc] init];
    [paramsM setObject:base64_str(@"submit_contact_form") forKey:@"type"];
    [paramsM setObject:base64_int(0) forKey:@"form_id"];
    NSString* nameShortCode = [[[ContactForm3Config getInstance] getContactForm3_Name] shortcode];
    [paramsM setObject:base64_str(name) forKey:nameShortCode];
    NSString* emailShortCode = [[[ContactForm3Config getInstance] getContactForm3_Email] shortcode];
    [paramsM setObject:base64_str(email) forKey:emailShortCode];
    NSString* messageShortCode = [[[ContactForm3Config getInstance] getContactForm3_Message] shortcode];
    [paramsM setObject:base64_str(message) forKey:messageShortCode];
    NSDictionary *params = [[NSDictionary alloc] initWithDictionary:paramsM];
    @try {
        NSData* requestData = [NSJSONSerialization dataWithJSONObject:paramsM options:0 error:nil];
        NSString* requestDataString = [[NSString alloc] initWithData:requestData encoding:NSUTF8StringEncoding];
        RLOG(@"postContactForm3InBackground: requestDataString: %@", requestDataString);
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [manager POST:requestUrl parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
    } progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *json = [Utility getJsonObject:responseObject];
        if (json == nil) {
            failure(@"No data received / Invalid Json");
            RLOG(@"postContactForm3InBackground: failure:%@", @"No data received / Invalid Json");
        } else {
            RLOG(@"json: %@", json);
            NSString* messageStr = [json valueForKey:@"message"];
            NSString* statusStr = [json valueForKey:@"status"];
            if ([statusStr isEqualToString:@"success"]) {
                RLOG(@"postContactForm3InBackground: success:%@", messageStr);
                success(messageStr);
            } else {
                RLOG(@"postContactForm3InBackground: failure:%@", messageStr);
                failure(messageStr);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        RLOG(@"postContactForm3InBackground: failure");
        NSString* str = [NSString stringWithFormat:@"%@", [error localizedDescription]];
        failure(str);
    }];
}
- (void)postReservationFormInBackground:(int)formId
                                   name:(NSString*)name
                                  email:(NSString*)email
                                dateStr:(NSString*)dateStr
                              date_pers:(NSString*)date_pers
                                timeStr:(NSString*)timeStr
                             timePeriod:(NSString*)timePeriod
                                  phone:(NSString*)phone
                                message:(NSString*)message
                                success:(void(^)(id data))success
                                failure:(void(^)(NSString* error))failure {
    NSString* requestUrl = [NSString stringWithFormat:@"%@/wp-tm-ext-store-notify/api/reservation_form/", self.baseUrl];
    NSMutableDictionary *paramsM = [[NSMutableDictionary alloc] init];
    [paramsM setObject:base64_str(@"submit_reservation_form") forKey:@"type"];
    [paramsM setObject:base64_int(25) forKey:@"form_id"];
    [paramsM setObject:base64_str(name) forKey:@"nomdelareservation"];
    [paramsM setObject:base64_str(email) forKey:@"adresseemail"];
    [paramsM setObject:base64_str(dateStr) forKey:@"date"];//date
    [paramsM setObject:base64_str(date_pers) forKey:@"pers"];//date_pers
    [paramsM setObject:base64_str(timeStr) forKey:@"heure"];
    [paramsM setObject:base64_str(timePeriod) forKey:@"t332"];
    [paramsM setObject:base64_str(phone) forKey:@"numerodetel"];
    [paramsM setObject:base64_str(message) forKey:@"message"];
    NSDictionary *params = [[NSDictionary alloc] initWithDictionary:paramsM];
    @try {
        NSData* requestData = [NSJSONSerialization dataWithJSONObject:paramsM options:0 error:nil];
        NSString* requestDataString = [[NSString alloc] initWithData:requestData encoding:NSUTF8StringEncoding];
        RLOG(@"postReservationFormInBackground: requestDataString: %@", requestDataString);
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [manager POST:requestUrl parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
    } progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *json = [Utility getJsonObject:responseObject];
        if (json == nil) {
            failure(@"No data received / Invalid Json");
            RLOG(@"postReservationFormInBackground: failure:%@", @"No data received / Invalid Json");
        } else {
            RLOG(@"json: %@", json);
            NSString* messageStr = [json valueForKey:@"message"];
            NSString* statusStr = [json valueForKey:@"status"];
            if ([statusStr isEqualToString:@"success"]) {
                RLOG(@"postReservationFormInBackground: success:%@", messageStr);
                success(messageStr);
            } else {
                RLOG(@"postReservationFormInBackground: failure:%@", messageStr);
                failure(messageStr);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        RLOG(@"postReservationFormInBackground: failure");
        NSString* str = [NSString stringWithFormat:@"%@", [error localizedDescription]];
        failure(str);
    }];
}
#pragma mark OTP
- (void)pluginOTP:(NSString*)mobileNumber
             code:(NSString*)code
             type:(int)type
          success:(void(^)(NSString* str))success
          failure:(void(^)(NSString* error))failure {
    NSString* requestUrl = [NSString stringWithFormat:@"%@/wp-tm-ext-store-notify/api/otp/", self.baseUrl];
    NSString* methodType = @"";
    if (type == OTP_METHOD_TYPE_SEND) {
        methodType = @"send";
    } else if (type == OTP_METHOD_TYPE_VERIFY) {
        methodType = @"verify";
    } else if (type == OTP_METHOD_TYPE_RESEND) {
        methodType = @"resend";
    } else if (type == OTP_METHOD_TYPE_CHECKOUT_SEND) {
        methodType = @"checkout_otp";
    } else if (type == OTP_METHOD_TYPE_CHECKOUT_VERIFY) {
        methodType = @"verify";
    } else if (type == OTP_METHOD_TYPE_CHECKOUT_RESEND) {
        methodType = @"resend";
    } else {
        methodType = @"send";
    }
    
    NSDictionary *params;
    if (type == OTP_METHOD_TYPE_VERIFY || type == OTP_METHOD_TYPE_CHECKOUT_VERIFY){
        params = @{@"type": base64_str(methodType),
                   @"mobile": base64_str(mobileNumber),
                   @"otp_code": base64_str(code)
                   };
    } else {
        params = @{@"type": base64_str(methodType),
                   @"mobile": base64_str(mobileNumber)
                   };
    
    }
    
    
    
     //'otp_code' => base64_encode('4292')
    RLOG(@"generateOTP: requestUrl: %@", requestUrl);
    RLOG(@"generateOTP: params: %@", params);
    AFHTTPSessionManager *manager =  [self getHttpSessionManagerForPost:@"text/html"];
    [manager POST:requestUrl
       parameters:params
constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {}
         progress:^(NSProgress * _Nonnull uploadProgress) { }
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSDictionary *json = [Utility getJsonObject:responseObject];
              if (json) {
                  NSString* statusStr = [json valueForKey:@"status"];
                  NSString* messageStr = [json valueForKey:@"message"];
                  RLOG(@"messageStr: %@", messageStr);
                  if ([[statusStr lowercaseString] isEqualToString:@"success"]) {
                      success(messageStr);
                      RLOG(@"generateOTP: success: %@", json);
                      return;
                  }
                  failure(messageStr);
              }
              failure(@"failure");
              RLOG(@"generateOTP: failure");
          }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              failure(@"failure");
              RLOG(@"generateOTP: failure");
          }
     ];
}


#pragma mark Reset Password

- (void)pluginResetPassword:(NSString*)userEmail
                oldPassword:(NSString*)oldPassword
                newPassword:(NSString*)newPassword
                    success:(void(^)(NSString* str))success
                    failure:(void(^)(NSString* error))failure {
    [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
    [MRProgressOverlayView showOverlayAddedTo:[[UIApplication sharedApplication] keyWindow] title:@"" mode:MRProgressOverlayViewModeIndeterminateSmallDefault animated:YES];
    NSString* requestUrl = [NSString stringWithFormat:@"%@/wp-tm-store-notify/api/reset_password/", self.baseUrl];
    NSDictionary *params = @{
               @"user_emailID":     base64_str(userEmail),
               @"user_pass":        base64_str(oldPassword),
               @"user_pass_new":    base64_str(newPassword),
               @"user_platform":    base64_str(@"IOS")
               };
    
    RLOG(@"pluginResetPassword: requestUrl: %@", requestUrl);
    RLOG(@"pluginResetPassword: params: %@", params);
    AFHTTPSessionManager *manager =  [self getHttpSessionManagerForPost:@"text/html"];
    [manager POST:requestUrl
       parameters:params
constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {}
         progress:^(NSProgress * _Nonnull uploadProgress) { }
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
              NSDictionary *json = [Utility getJsonObject:responseObject];
              if (json) {
                  NSString* statusStr = [json valueForKey:@"status"];
                  NSString* messageStr = [json valueForKey:@"message"];
                  RLOG(@"messageStr: %@", messageStr);
                  if ([[statusStr lowercaseString] isEqualToString:@"success"]) {
                      success(messageStr);
                      RLOG(@"pluginResetPassword: success: %@", json);
                      return;
                  }
                  failure(messageStr);
              }
              failure(@"failure");
              RLOG(@"pluginResetPassword: failure");
          }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
              failure(@"failure");
              RLOG(@"pluginResetPassword: failure");
          }
     ];
    
}
#pragma mark WOOCOMMERCE CHECKOUT MANAGER (WCCM)
- (void)getWCCMData:(void(^)(id data))success
            failure:(void(^)(NSString* error))failure {
    NSString* requestUrl = [NSString stringWithFormat:@"%@/wp-tm-ext-store-notify/api/woocommerce-checkout-manager/", self.baseUrl];
    NSDictionary *params = @{@"type": base64_str(@"view")};
    RLOG(@"requestUrl: %@", requestUrl);
    RLOG(@"params: %@", params);
    AFHTTPSessionManager *manager =  [self getHttpSessionManagerForPost:@"text/html"];
    [manager POST:requestUrl
       parameters:params
constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {}
         progress:^(NSProgress * _Nonnull uploadProgress) { }
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSArray *array = [Utility getJsonArray:responseObject];
              if (array) {
                  [self.tmJsonHelper parseWCCheckoutManagerData:array];
                  success(array);
                  RLOG(@"success: %@", array);
                  return;
              }
              failure(@"failure");
              RLOG(@"failure");
          }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              failure(@"failure");
              RLOG(@"failure");
          }
     ];
}
- (void)getWCCMDataForOrders:(NSArray*)orderIds
            success:(void(^)(id data))success
            failure:(void(^)(NSString* error))failure {
    NSString* requestUrl = [NSString stringWithFormat:@"%@/wp-tm-ext-store-notify/api/woocommerce-checkout-manager/", self.baseUrl];
    NSMutableDictionary *paramsM = [[NSMutableDictionary alloc] init];
    [paramsM setObject:base64_str(@"view_order") forKey:@"type"];
    NSString* oids = [NSString stringWithFormat:@"[%@]", [NSArray join:orderIds]];
    [paramsM setObject:base64_str(oids) forKey:@"order_ids"];
    NSDictionary *params = [[NSDictionary alloc] initWithDictionary:paramsM];
    RLOG(@"requestUrl: %@", requestUrl);
    RLOG(@"params: %@", params);
    AFHTTPSessionManager *manager =  [self getHttpSessionManagerForPost:@"text/html"];
    [manager POST:requestUrl
       parameters:params
constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {}
         progress:^(NSProgress * _Nonnull uploadProgress) { }
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSArray *array = [Utility getJsonArray:responseObject];
              if (array) {
                  [self.tmJsonHelper parseWCCheckoutManagerDataAllOrders:array];
                  success(array);
                  RLOG(@"success: %@", array);
                  return;
              }
              failure(@"failure");
              RLOG(@"failure");
          }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              failure(@"failure");
              RLOG(@"failure");
          }
     ];
    
}
- (void)setWCCMDataForOrderId:(int)orderId
                     metaData:(NSDictionary*)metaData
                      success:(void(^)(id data))success
                      failure:(void(^)(NSString* error))failure {
    NSString* requestUrl = [NSString stringWithFormat:@"%@/wp-tm-ext-store-notify/api/woocommerce-checkout-manager/", self.baseUrl];
    NSMutableDictionary *paramsM = [[NSMutableDictionary alloc] init];
    [paramsM setObject:base64_str(@"update") forKey:@"type"];
    [paramsM setObject:base64_int(orderId) forKey:@"orderid"];
    NSString* metaDataStr = @"";
    @try {
        NSError* err;
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:metaData options:0 error:&err];
        metaDataStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"%@",metaDataStr);
    } @catch (NSException *exception) {
        metaDataStr = @"";
    } @finally {
        
    }
    
//    [paramsM setObject:base64_str(metaDataStr) forKey:@"meta_data"];
    [paramsM setObject:(metaDataStr) forKey:@"meta_data"];
    NSDictionary *params = [[NSDictionary alloc] initWithDictionary:paramsM];
    @try {
        NSData* requestData = [NSJSONSerialization dataWithJSONObject:paramsM options:0 error:nil];
        NSString* requestDataString = [[NSString alloc] initWithData:requestData encoding:NSUTF8StringEncoding];
        RLOG(@"requestDataString: %@", requestDataString);
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [manager POST:requestUrl parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
    } progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *json = [Utility getJsonObject:responseObject];
        if (json == nil) {
            failure(@"No data received / Invalid Json");
            RLOG(@"failure:%@", @"No data received / Invalid Json");
        } else {
            RLOG(@"json: %@", json);
            NSString* messageStr = [json valueForKey:@"message"];
            NSString* statusStr = [json valueForKey:@"status"];
            if ([statusStr isEqualToString:@"success"]) {
                RLOG(@"success:%@", messageStr);
                success(messageStr);
            } else {
                RLOG(@"failure:%@", messageStr);
                failure(messageStr);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        RLOG(@"failure");
        NSString* str = [NSString stringWithFormat:@"%@", [error localizedDescription]];
        failure(str);
    }];
}

#pragma mark SELLER_ZONE
- (void)getProductsOfCategory:(int)categoryId
                       offset:(int)offset
                 productLimit:(int)productLimit
                    success:(void(^)(id data))success
                    failure:(void(^)(NSString* error))failure {
    NSString* requestUrl = [NSString stringWithFormat:@"%@/wp-tm-ext-store-notify/api/%@_load_category_products/", self.baseUrl, self.multiVendorPluginName];
    NSMutableDictionary *paramsM = [[NSMutableDictionary alloc] init];
    [paramsM setObject:base64_int(-1) forKey:@"seller_id"];
    [paramsM setObject:base64_int(productLimit) forKey:@"product_limit"];
    [paramsM setObject:base64_int(categoryId) forKey:@"category_id"];
    [paramsM setObject:base64_int(offset) forKey:@"offset"];
    [paramsM setObject:base64_str(@"publish") forKey:@"post_status"];
    NSDictionary *params = [[NSDictionary alloc] initWithDictionary:paramsM];
    RLOG(@"requestUrl: %@", requestUrl);
    RLOG(@"params: %@", params);
    AFHTTPSessionManager *manager =  [self getHttpSessionManagerForPost:@"text/html"];
    [manager POST:requestUrl
       parameters:params
constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {}
         progress:^(NSProgress * _Nonnull uploadProgress) { }
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSArray *array = [Utility getJsonArray:responseObject];
              if (array) {
                  NSMutableArray* parsedArray = [[NSMutableArray alloc] init];
                  [self.tmJsonHelper loadTrendingDatasViaPlugin:array originalDataArray:parsedArray resizeEnable:false];
                  success(parsedArray);
                  return;
              }
              failure(@"failure");
          }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              failure(@"failure");
          }
     ];
    
}
- (void)getProductsOfSeller:(NSString*)sellerId
              productLimit:(int)productLimit
                     offset:(int)offset
                    success:(void(^)(id data))success
                    failure:(void(^)(NSString* error))failure {
    NSString* requestUrl = [NSString stringWithFormat:@"%@/wp-tm-ext-store-notify/api/%@_load_category_products/", self.baseUrl, self.multiVendorPluginName];
    NSMutableDictionary *paramsM = [[NSMutableDictionary alloc] init];
    [paramsM setObject:base64_str(sellerId) forKey:@"seller_id"];
    [paramsM setObject:base64_int(productLimit) forKey:@"product_limit"];
    [paramsM setObject:base64_int(-1) forKey:@"category_id"];
    [paramsM setObject:base64_int(offset) forKey:@"offset"];
    [paramsM setObject:base64_str(@"publish") forKey:@"post_status"];


    NSDictionary *params = [[NSDictionary alloc] initWithDictionary:paramsM];
    RLOG(@"requestUrl: %@", requestUrl);
    RLOG(@"params: %@", params);
    AFHTTPSessionManager *manager =  [self getHttpSessionManagerForPost:@"text/html"];
    [manager POST:requestUrl
       parameters:params
constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {}
         progress:^(NSProgress * _Nonnull uploadProgress) { }
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSArray *array = [Utility getJsonArray:responseObject];
              if (array) {
                  RLOG(@"need to parse data here");
                  NSMutableArray* parsedArray = [[NSMutableArray alloc] init];
                  [self.tmJsonHelper loadTrendingDatasViaPlugin:array originalDataArray:parsedArray resizeEnable:false];
                  success(parsedArray);
                  RLOG(@"success: %@", parsedArray);
                  return;
              }
              failure(@"failure");
              RLOG(@"failure");
          }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              failure(@"failure");
              RLOG(@"failure");
          }
     ];

}
- (void)getOrdersOfSeller:(int)sellerId
                    success:(void(^)(id data))success
                    failure:(void(^)(NSString* error))failure {
    NSString* requestUrl = [NSString stringWithFormat:@"%@/wp-tm-ext-store-notify/api/%@_seller_orders/", self.baseUrl, self.multiVendorPluginName];
    NSMutableDictionary *paramsM = [[NSMutableDictionary alloc] init];
    [paramsM setObject:base64_int(sellerId) forKey:@"seller_id"];
    [paramsM setObject:base64_int(100) forKey:@"product_limit"];
    [paramsM setObject:base64_int(-1) forKey:@"category_id"];
    [paramsM setObject:base64_int(0) forKey:@"offset"];
    [paramsM setObject:base64_str(@"publish") forKey:@"post_status"];
    NSDictionary *params = [[NSDictionary alloc] initWithDictionary:paramsM];
    RLOG(@"requestUrl: %@", requestUrl);
    RLOG(@"params: %@", params);
    AFHTTPSessionManager *manager =  [self getHttpSessionManagerForPost:@"text/html"];
    [manager POST:requestUrl
       parameters:params
constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {}
         progress:^(NSProgress * _Nonnull uploadProgress) { }
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              NSDictionary *dict = nil;
              if (responseObject) {
                  dict = [Utility getJsonObject:responseObject];
                  RLOG(@"\n==ResponseObject = %@\n\n", dict);
                  NSMutableArray* orderArray = [self.tmJsonHelper sellerZoneParseOrderJson:dict];
                  success(orderArray);
                  RLOG(@"success");
                  return;
              }
              failure(@"failure");
              RLOG(@"failure");
          }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              failure(@"failure");
              RLOG(@"failure");
          }
     ];
}
- (NSString *)encodeImageToBase64String:(UIImage *)image {
    return [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}
- (UIImage *)decodeBase64ToImage:(NSString *)strEncodeData {
    NSData *data = [[NSData alloc]initWithBase64EncodedString:strEncodeData options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [UIImage imageWithData:data];
}
- (void)uploadImageToServer:(UIImage*)img
                    success:(void(^)(NSString* imgUrl))success
                    failure:(void(^)(NSString* error))failure {
    MRProgressOverlayView* mov = [Utility createCustomizedLoadingBar:Localize(@"uploading") isBottomAlign:false isClearViewEnabled:false isShadowEnabled:true];
    NSString* requestUrl = [NSString stringWithFormat:@"%@/wp-tm-store-notify/api/upload_image/", self.baseUrl];
    
    NSMutableDictionary *paramsM = [[NSMutableDictionary alloc] init];
    [paramsM setObject:([self encodeImageToBase64String:img]) forKey:@"image"];
    NSString* imgName = [NSString stringWithFormat:@"%@.png", [self randomStringWithLength:24]];
    [paramsM setObject:(imgName) forKey:@"name"];
    
    NSDictionary *params = [[NSDictionary alloc] initWithDictionary:paramsM];
    RLOG(@"requestUrl: %@", requestUrl);
    RLOG(@"params: %@", params);
    AFHTTPSessionManager *manager =  [self getHttpSessionManagerForPost:@"text/html"];
    [manager POST:requestUrl
       parameters:params
constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {}
         progress:^(NSProgress * _Nonnull uploadProgress) { }
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
              if (responseObject) {
                  NSDictionary *dict = [Utility getJsonObject:responseObject];
                  NSString* messageStr = [dict valueForKey:@"message"];
                  NSString* statusStr = [dict valueForKey:@"status"];
                  NSString* urlStr = [dict valueForKey:@"url"];
                  if ([statusStr isEqualToString:@"success"]) {
                      RLOG(@"success:%@:%@", messageStr, urlStr);
                      success(urlStr);
                      return;
                  }
              }
              RLOG(@"failure");
              failure(@"failure");
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
//              if (error && error.userInfo) {
//                  id data = [error.userInfo valueForKey:@"com.alamofire.serialization.response.error.data"];
//                  if (data) {
//                      NSDictionary* json = [Utility getJsonObject:data];
//                      RLOG(@"======failure:%@======",json);
//                      NSString* messageStr = [json valueForKey:@"message"];
//                      NSString* statusStr = [json valueForKey:@"status"];
//                      NSString* urlStr = [json valueForKey:@"url"];
//                      if ([statusStr isEqualToString:@"success"]) {
//                          RLOG(@"success:%@:%@", messageStr, urlStr);
//                          success(urlStr);
//                          return;
//                      }
//                  }
//              }
              
              failure(@"failure");
              RLOG(@"failure");
          }
     ];
}
- (void)uploadProduct:(int)productId
                 uploadDict:(NSMutableDictionary*)uploadDict
                    success:(void(^)(id data))success
              failure:(void(^)(NSString* error))failure {
    MRProgressOverlayView* mov = [Utility createCustomizedLoadingBar:Localize(@"uploading_product_data") isBottomAlign:false isClearViewEnabled:false isShadowEnabled:true];
    NSDictionary* postParams = uploadDict;
    NSString* requestUrl = [NSString stringWithFormat:@"%@", [[[DataManager sharedManager] tmDataDoctor] request_url_products]];
    
    if (productId != -1) {
        requestUrl = [NSString stringWithFormat:@"%@/%d", [[[DataManager sharedManager] tmDataDoctor] request_url_products], productId];
    }
    NSString* urlString = [self initializeRequestStringForPostMethod:requestUrl];
    AFHTTPSessionManager* manager = [self initializeRequestManagerForPostMethod];
    RLOG(@"postParams=\n%@",postParams);
    RLOG(@"urlString=\n%@",urlString);
    [manager POST:urlString parameters:postParams progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
        NSDictionary *dict = nil;
        if (responseObject) {
            dict = [Utility getJsonObject:responseObject];
            RLOG(@"\n==ResponseObject = %@\n\n", dict);
        }
        if (dict) {
//            dict = (NSDictionary*)[dict objectForKey:@"product"];
            ProductInfo* pInfo = [self.tmJsonHelper loadSingleProductData:dict];
//            Order* order = [self.tmJsonHelper parseOrderJson:dict];
//            success(order);
            success(pInfo);
        } else {
            RLOG(@"UPLOAD_PRODUCT_FAILURE");
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Localize(@"i_error") message:Localize(@"try_again") delegate:nil cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil];
            [alertView show];
            failure(@"failure");
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:NO];
        RLOG(@"\n==Error = %@\n\n", error);
        
        if (error && error.userInfo) {
            id data = [error.userInfo valueForKey:@"com.alamofire.serialization.response.error.data"];
            if (data) {
                NSDictionary* json_dict = [Utility getJsonObject:data];
                RLOG(@"======failure:%@======",json_dict);
            }
        }
        
        
        NSInteger statusCode = 0;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
        if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = httpResponse.statusCode;
        }
        if(statusCode == 404 || statusCode == 200) {
            RLOG(@"UPLOAD_PRODUCT_FAILURE");
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Localize(@"oops") message:Localize(@"generic_error") delegate:nil cancelButtonTitle:Localize(@"cancel") otherButtonTitles:Localize(@"retry"), nil];;
            [alertView showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if ((int)buttonIndex == 0) {
                    failure(@"failure");
                } else {
                    failure(@"retry");
                }
            }];
        } else {
            failure(@"retry");
        }
    }];
}
- (void)deleteProduct:(int)productId
              success:(void(^)(NSString* msg))success
              failure:(void(^)(NSString* msg))failure {
    MRProgressOverlayView* mov = [Utility createCustomizedLoadingBar:Localize(@"Deleting product data..") isBottomAlign:false isClearViewEnabled:false isShadowEnabled:true];
    NSMutableDictionary* postParams =  [[NSMutableDictionary alloc] init];
    [postParams setValue:@"true" forKey:@"force"];
    postParams = nil;
    NSString* requestUrl = [NSString stringWithFormat:@"%@", [[[DataManager sharedManager] tmDataDoctor] request_url_products]];
    if (productId != -1) {
        requestUrl = [NSString stringWithFormat:@"%@/%d", [[[DataManager sharedManager] tmDataDoctor] request_url_products], productId];
    }
    NSString* urlString = [self initializeRequestStringForDeleteMethod:requestUrl];
    AFHTTPSessionManager* manager = [self initializeRequestManagerForPostMethod];
    RLOG(@"postParams=\n%@",postParams);
    RLOG(@"urlString=\n%@",urlString);
    [manager DELETE:urlString parameters:postParams success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
        NSDictionary* json = [Utility getJsonObject:responseObject];
        if (json && [json isKindOfClass:[NSDictionary class]]) {
            if (IS_NOT_NULL(json, @"message")) {
                NSString* str = GET_VALUE_STR(json, @"message");
                success(str);
                return;
            }
        }
        failure(@"failure");
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:NO];
        RLOG(@"\n==Error = %@\n\n", error);
        if (error && error.userInfo) {
            id data = [error.userInfo valueForKey:@"com.alamofire.serialization.response.error.data"];
            if (data) {
                NSDictionary* json_dict = [Utility getJsonObject:data];
                RLOG(@"======failure:%@======",json_dict);
            }
        }
        failure(@"failure");
    }];
}
- (void)linkProductWithSeller:(int)productId
                     sellerId:(int)sellerId
                    success:(void(^)(void))success
                      failure:(void(^)(NSString* error))failure {
    MRProgressOverlayView* mov = [Utility createCustomizedLoadingBar:Localize(@"uploading_product_data") isBottomAlign:false isClearViewEnabled:false isShadowEnabled:true];
    NSString* requestUrl = [NSString stringWithFormat:@"%@/wp-tm-ext-store-notify/api/%@_product_to_seller/", self.baseUrl, self.multiVendorPluginName];
    NSMutableDictionary *paramsM = [[NSMutableDictionary alloc] init];
    [paramsM setObject:base64_int(sellerId) forKey:@"seller_id"];
    [paramsM setObject:base64_int(productId) forKey:@"product_id"];
    NSDictionary *params = [[NSDictionary alloc] initWithDictionary:paramsM];
    RLOG(@"requestUrl: %@", requestUrl);
    RLOG(@"params: %@", params);
    AFHTTPSessionManager *manager =  [self getHttpSessionManagerForPost:@"text/html"];
    [manager POST:requestUrl
       parameters:params
constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {}
         progress:^(NSProgress * _Nonnull uploadProgress) { }
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
              if (responseObject) {
                  NSDictionary *dict = [Utility getJsonObject:responseObject];
                  NSString* messageStr = [dict valueForKey:@"message"];
                  NSString* statusStr = [dict valueForKey:@"status"];
                  if ([statusStr isEqualToString:@"success"]) {
                      RLOG(@"success:%@", messageStr);
                      success();
                      return;
                  }
              }
              RLOG(@"failure");
              failure(@"failure");
          }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
              failure(@"failure");
              RLOG(@"failure");
          }
     ];
}
- (void)getSellerInformation:(int)sellerId
                    success:(void(^)(id data))success
                    failure:(void(^)(NSString* error))failure {
    MRProgressOverlayView* mov = [Utility createCustomizedLoadingBar:Localize(@"loading_seller_info") isBottomAlign:false isClearViewEnabled:false isShadowEnabled:true];
    
    NSString* requestUrl = [NSString stringWithFormat:@"%@/wp-tm-ext-store-notify/api/%@_seller_info/", self.baseUrl, self.multiVendorPluginName];
    NSMutableDictionary *paramsM = [[NSMutableDictionary alloc] init];
    [paramsM setObject:base64_int(sellerId) forKey:@"seller_id"];
    [paramsM setObject:base64_str(@"view") forKey:@"type"];
    NSDictionary *params = [[NSDictionary alloc] initWithDictionary:paramsM];
    RLOG(@"requestUrl: %@", requestUrl);
    RLOG(@"params: %@", params);
    AFHTTPSessionManager *manager =  [self getHttpSessionManagerForPost:@"text/html"];
    [manager POST:requestUrl
       parameters:params
constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {}
         progress:^(NSProgress * _Nonnull uploadProgress) { }
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
              NSDictionary *json = [Utility getJsonObject:responseObject];
              if (json) {
                  RLOG(@"success: %@", json);
                  SellerInfo* sInfo = [self.tmJsonHelper szParseSellerInfo:json];
                  success(sInfo);
                  return;
              }
              failure(@"failure");
              RLOG(@"failure");
          }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
              failure(@"failure");
              RLOG(@"failure");
          }
     ];
    
}
- (void)updateSellerInformation:(NSDictionary*)params
                     success:(void(^)(id data))success
                     failure:(void(^)(NSString* error))failure {
    if (params) {
        MRProgressOverlayView* mov = [Utility createCustomizedLoadingBar:Localize(@"updating_seller_info") isBottomAlign:false isClearViewEnabled:false isShadowEnabled:true];
        NSString* requestUrl = [NSString stringWithFormat:@"%@/wp-tm-ext-store-notify/api/%@_seller_info/", self.baseUrl, self.multiVendorPluginName];
        RLOG(@"requestUrl: %@", requestUrl);
        RLOG(@"params: %@", params);
        AFHTTPSessionManager *manager =  [self getHttpSessionManagerForPost:@"text/html"];
        [manager POST:requestUrl
           parameters:params
constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {}
             progress:^(NSProgress * _Nonnull uploadProgress) { }
              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                  [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
                  if (responseObject) {
                      NSDictionary *dict = [Utility getJsonObject:responseObject];
                      NSString* messageStr = [dict valueForKey:@"message"];
                      NSString* statusStr = [dict valueForKey:@"status"];
                      if ([statusStr isEqualToString:@"success"]) {
                          RLOG(@"success:%@", messageStr);
                          success(messageStr);
                          return;
                      } else {
                          RLOG(@"failure:%@", messageStr);
                          failure(messageStr);
                          return;
                      }
                  }
                  RLOG(@"failure");
                  failure(@"failure");
              }
              failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                  [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
                  failure(@"failure");
                  RLOG(@"failure");
              }
         ];
    } else {
        failure(@"failure");
    }
}

- (void)getAllAttributes:(void(^)(void))success
                     failure:(void(^)(NSString* error))failure {
    MRProgressOverlayView* mov = [Utility createCustomizedLoadingBar:Localize(@"Fetching attributes..") isBottomAlign:false isClearViewEnabled:false isShadowEnabled:true];
    NSString* requestUrl = [NSString stringWithFormat:@"%@/wp-tm-store-notify/api/attribute_data/", self.baseUrl];
    NSDictionary *params = nil;
    RLOG(@"requestUrl: %@", requestUrl);
    RLOG(@"params: %@", params);
    AFHTTPSessionManager *manager =  [self getHttpSessionManagerForPost:@"text/html"];
    [manager POST:requestUrl
       parameters:params
constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {}
         progress:^(NSProgress * _Nonnull uploadProgress) { }
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
              NSDictionary *json = [Utility getJsonObject:responseObject];
              if (json) {
                  RLOG(@"success: %@", json);
                  [self.tmJsonHelper szParseAttributesData:json];
                  success();
                  return;
              }
              failure(@"failure");
              RLOG(@"failure");
          }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
              failure(@"failure");
              RLOG(@"failure");
          }
     ];
    
}
- (void)getAllAttributesForCategories:(NSArray*)categoryIds
                              success:(void(^)(void))success
                              failure:(void(^)(NSString* error))failure {
    MRProgressOverlayView* mov = [Utility createCustomizedLoadingBar:Localize(@"Fetching attributes..") isBottomAlign:false isClearViewEnabled:false isShadowEnabled:true];
    NSString* requestUrl = [NSString stringWithFormat:@"%@/wp-tm-store-notify/api/attribute_data/", self.baseUrl];
    
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:categoryIds options:kNilOptions error:&error];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSData *data1 = [[str dataUsingEncoding:NSUTF8StringEncoding] base64EncodedDataWithOptions:0];
    NSString *str1 = [[NSString alloc] initWithData:data1 encoding:NSUTF8StringEncoding];
    NSMutableDictionary *paramsM = [[NSMutableDictionary alloc] init];
    [paramsM setObject:str1 forKey:@"c_ids"];
    [paramsM setObject:base64_str(@"en_US") forKey:@"lang"];
    NSDictionary *params = [[NSDictionary alloc] initWithDictionary:paramsM];
    RLOG(@"requestUrl: %@", requestUrl);
    RLOG(@"params: %@", params);
    AFHTTPSessionManager *manager =  [self getHttpSessionManagerForPost:@"text/html"];
    [manager POST:requestUrl
       parameters:params
constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {}
         progress:^(NSProgress * _Nonnull uploadProgress) { }
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
              NSDictionary *json = [Utility getJsonObject:responseObject];
              if (json) {
                  RLOG(@"success: %@", json);
                  [self.tmJsonHelper szParseAttributesData:json];
                  success();
                  return;
              }
              failure(@"failure");
              RLOG(@"failure");
          }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
              failure(@"failure");
              RLOG(@"failure");
          }
     ];
    
}
- (void)updateSellerOrder:(Order*)order
              orderStatus:(NSString*)orderStatus
                  success:(void(^)(id data))success
                  failure:(void(^)(NSString* error))failure {
    MRProgressOverlayView* mov = [Utility createCustomizedLoadingBar:Localize(@"updating_status") isBottomAlign:false isClearViewEnabled:false isShadowEnabled:true];
    [mov.titleLabel setUIFont:kUIFontType18 isBold:false];
    NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
    {
        NSMutableDictionary* order = [[NSMutableDictionary alloc] init];
        {
            [order setObject:orderStatus forKey:@"status"];
        }
        [data setObject:order forKey:@"order"];
    }
    NSData * updateOrderJsonData = [NSJSONSerialization dataWithJSONObject:data options:0 error:nil];
    NSString * updateOrderJsonString = [[NSString alloc] initWithData:updateOrderJsonData encoding:NSUTF8StringEncoding];
    RLOG(@"====updateOrderJsonString:\n%@\n====", updateOrderJsonString);
    NSDictionary* postParams = [[NSDictionary alloc]initWithDictionary:data];
    NSString* requestUrl = [NSString stringWithFormat:@"%@/%d", [[[DataManager sharedManager] tmDataDoctor] request_url_orders], order._id];
    NSString* URLString = [self initializeRequestStringForPostMethod:requestUrl];
    AFHTTPSessionManager* manager = [self initializeRequestManagerForPostMethod];
    RLOG(@"====URLString:\n%@\n====", URLString);
    [manager POST:URLString parameters:postParams progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
        NSDictionary *dict = nil;
        if (responseObject) {
            dict = [Utility getJsonObject:responseObject];
        }
        if (dict) {
            dict = (NSDictionary*)[dict objectForKey:@"order"];
            Order* updatedOrder = [self.tmJsonHelper parseOrderJsonWithOrderObject:dict order:order];
            success(updatedOrder);
            return;
        }
        failure(@"failure");
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
        failure(@"failure");
    }];
}
- (void)updateSellerInfo:(NSMutableDictionary*)sellerInfoDict
                 success:(void(^)(NSString* successStr))success
                 failure:(void(^)(NSString* failureStr))failure {
    MRProgressOverlayView* mov = [Utility createCustomizedLoadingBar:Localize(@"updating_seller_info") isBottomAlign:false isClearViewEnabled:false isShadowEnabled:true];
    NSString* requestUrl = [NSString stringWithFormat:@"%@/wp-tm-ext-store-notify/api/%@_seller_info/", self.baseUrl, self.multiVendorPluginName];
    NSMutableDictionary *paramsM = [[NSMutableDictionary alloc] init];
    [paramsM setObject:base64_str(@"update") forKey:@"type"];
    [paramsM setObject:base64_int([[sellerInfoDict objectForKey:@"seller_id"] intValue]) forKey:@"seller_id"];
    [paramsM setObject:base64_str([sellerInfoDict objectForKey:@"seller_first_name"]) forKey:@"seller_first_name"];
    [paramsM setObject:base64_str([sellerInfoDict objectForKey:@"seller_last_name"]) forKey:@"seller_last_name"];
    [paramsM setObject:base64_str([sellerInfoDict objectForKey:@"seller_phone"]) forKey:@"seller_phone"];
    [paramsM setObject:base64_str([sellerInfoDict objectForKey:@"shop_name"]) forKey:@"shop_name"];
    [paramsM setObject:base64_str([sellerInfoDict objectForKey:@"shop_address"]) forKey:@"shop_address"];
    [paramsM setObject:base64_str([sellerInfoDict objectForKey:@"seller_info"]) forKey:@"seller_info"];
    [paramsM setObject:base64_str([sellerInfoDict objectForKey:@"store_description"]) forKey:@"store_description"];
    [paramsM setObject:base64_str([sellerInfoDict objectForKey:@"banner_url"]) forKey:@"banner_url"];
    [paramsM setObject:base64_str([sellerInfoDict objectForKey:@"latitude"]) forKey:@"latitude"];
    [paramsM setObject:base64_str([sellerInfoDict objectForKey:@"longitude"]) forKey:@"longitude"];
    [paramsM setObject:base64_str([sellerInfoDict objectForKey:@"icon_url"]) forKey:@"icon_url"];
    [paramsM setObject:base64_str([sellerInfoDict objectForKey:@"avatar_url"]) forKey:@"avatar_url"];
    
//    params.put("type", "view");
//    params.put("seller_id", String.valueOf(sellerId));
//    params.put("seller_first_name", _first_name);
//    params.put("seller_last_name", _last_name);
//    params.put("seller_phone", _phone);
//    params.put("shop_name", _shop_name);
//    params.put("shop_address", _shop_address);
//    params.put("seller_info", "");
//    params.put("store_description", "");
//    params.put("type", "update");
//    params.put("banner_url", "");
//    params.put("latitude", String.valueOf(currentSeller.getLatitude()));
//    params.put("longitude", String.valueOf(currentSeller.getLongitude()));
//    params.put("icon_url", iconUrl);
//    params.put("avatar_url", avatarUrl);
    
    NSDictionary *params = [[NSDictionary alloc] initWithDictionary:paramsM];
    RLOG(@"requestUrl: %@", requestUrl);
    RLOG(@"params: %@", params);
    AFHTTPSessionManager *manager =  [self getHttpSessionManagerForPost:@"text/html"];
    [manager POST:requestUrl
       parameters:params
constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {}
         progress:^(NSProgress * _Nonnull uploadProgress) { }
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
              if (responseObject) {
                  NSDictionary *dict = [Utility getJsonObject:responseObject];
                  NSString* messageStr = [dict valueForKey:@"message"];
                  NSString* statusStr = [dict valueForKey:@"status"];
                  if ([statusStr isEqualToString:@"success"]) {
                      RLOG(@"success:%@", messageStr);
                      success(messageStr);
                      return;
                  } else {
                      RLOG(@"failure:%@", messageStr);
                      failure(messageStr);
                      return;
                  }
              }
              RLOG(@"failure");
              failure(@"failure");
          }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              [MRProgressOverlayView dismissOverlayForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
              failure(@"failure");
              RLOG(@"failure");
          }
     ];
}

#pragma mark - new methods

- (void)fetchCategoriesDataNew:(int)categoryId
                         count:(int)count
                       success:(void(^)(id data))success
                       failure:(void(^)(NSString* error))failure {
    requestURL = [NSString stringWithFormat:@"%@", self.request_url_products];
    int offset = 0;
    CategoryInfo* cInfo = [CategoryInfo getWithId:categoryId];
    NSString* categorySlug = cInfo._slug;
    int productCount = count;
    NSString* params = [NSString stringWithFormat:@"filter%%5Blimit%%5D=%d&filter%%5Boffset%%5D=%d&filter%%5Bcategory%%5D=%@&oauth_consumer_key=%@&oauth_nonce=%@&oauth_signature_method=%@&oauth_timestamp=%@", productCount, offset, categorySlug, self.oauth_consumer_key,[self randomStringWithLength:32],@"HMAC-SHA1",[NSString stringWithFormat:@"%lu", (unsigned long)[NSDate.date timeIntervalSince1970]]];
    NSString* urlStr = [NSString stringWithFormat:@"%@", requestURL];
    urlStr = [self getRFC3986:urlStr];
    NSString* paramString = [NSString stringWithFormat:@"%@", params];
    paramString = [self getRFC3986:paramString];
    NSString* algoString = [NSString stringWithFormat:@"GET&%@&%@", urlStr, paramString];
    NSString* algoKey;
    if([self.version_string isEqualToString:@"v2"]) {
        algoKey = self.oauth_consumer_secret;
    }else if([self.version_string isEqualToString:@"v3"]) {
        algoKey = [NSString stringWithFormat:@"%@&", self.oauth_consumer_secret];
    }
    NSString* _oauth_signature = [self hmacsha1:algoString key:algoKey];
    params = [NSString stringWithFormat:@"%@&oauth_signature=%@", params, _oauth_signature];
    if ([Utility containsString:requestURL substring:@"https"]) {
        params = [NSString stringWithFormat:@"filter%%5Blimit%%5D=%d&filter%%5Boffset%%5D=%d&filter%%5Bcategory%%5D=%@&consumer_key=%@&consumer_secret=%@", productCount, offset, categorySlug, self.oauth_consumer_key, self.oauth_consumer_secret];
    }
    NSString *finalUrlStr =[NSString stringWithFormat:@"%@?%@",requestURL, params];
    NSURL *nsUrl = [NSURL URLWithString:finalUrlStr];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager GET:nsUrl.absoluteString parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        RLOG(@"fetchCategoriesDataNew = success");
        NSDictionary* respDict = responseObject;//[Utility getJsonObject:responseObject];
        NSMutableArray* productArray = [[DataManager sharedManager] loadProductsData:respDict];
        success(productArray);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        RLOG(@"fetchCategoriesDataNew = failed");
        failure(@"failure");
    }];
}

@end
