//
//  ShippingWooCommerce.m
//  TMShippingSDK
//
//  Created by Rishabh Jain on 28/09/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import "ShippingWooCommerce.h"
#import "DataManager.h"

@implementation ShippingWooCommerce

static BOOL countriesLoaded = false;
static NSDictionary* responseDict = nil;
- (id)init:(NSString*)baseUrl {
    self = [super init];
    if (self) {
        self.request_url_countries = [NSString stringWithFormat:@"%@/wp-tm-store-notify/api/countries_list/", baseUrl];
        self.request_url_states = @"";
        self.request_url_districts = @"";
        self.request_url_sub_discricts = @"";
        self.request_url_cities = @"";
        self.request_url_calculate_shipping = @"";
        self.request_url_find_shippings = @"";
        self.request_url_currency = @"";
        self.request_store_destination = @"";
        countrySelection = true;
        stateSelection = true;
        citySelection = false;
        districtSelection = false;
        subDistrictSelection = false;
        
        self.regionSequences = [[NSMutableArray alloc] init];
        [self.regionSequences addObject:[NSNumber numberWithInt:REGION_SEQUENCE_COUNTRY]];
        [self.regionSequences addObject:[NSNumber numberWithInt:REGION_SEQUENCE_STATE]];
        [self.regionSequences addObject:[NSNumber numberWithInt:REGION_SEQUENCE_CITY]];
    }
    return self;
}
- (void)getChildRegions:(TMRegion*)parentRegion
                success:(void(^)(id data))success
                failure:(void(^)(NSString* error))failure {
    
    if (parentRegion != nil) {
        if([parentRegion.regionType isEqualToString:@"country"]) {
            [self getStates:parentRegion success:^(id data) {
                success(data);
            } failure:^(NSString *error) {
                
            }];
        }
        if([parentRegion.regionType isEqualToString:@"state"]) {
            [self getCities:parentRegion success:^(id data) {
                success(data);
            } failure:^(NSString *error) {
                
            }];
        }
    } else {
        [self getCountries:nil success:^(id data) {
            success(data);
        } failure:^(NSString *error) {
            
        }];
    }
}
- (void)getCountries:(TMRegion*)parentRegion
             success:(void(^)(id data))success
             failure:(void(^)(NSString* error))failure {
    
    if (countriesLoaded) {
        if (success != nil) {
            success([TMRegion getRegions:nil]);
        }
        return;
    }
    
    if (![Utility isNetworkAvailable]) {
        if (failure != nil) {
            failure(@"No Network");
        }
        return;
    }
    
    NSString* requestUrl = [NSString stringWithFormat:@"%@", self.request_url_countries];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [manager POST:requestUrl parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = [Utility getJsonObject:responseObject];
		responseDict = dict;
        success([self parseJsonAndCreateCountries:parentRegion response:dict]);
        countriesLoaded = true;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
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
                    failure(@"retry");
                }
            }];
        } else {
            failure(@"retry");
        }
    }];
    
    
    
    //    final List<NameValuePair> postParams = new LinkedList();
    //    PostResponse.ResponseListener postResponseListener = new PostResponse.ResponseListener() {
    //        @Override
    //        public void onResponseReceived(PostResponse postResponse) {
    //            Helper.SOUT("-- getCountries::onResponseReceived:[" + postResponse.msg + "] --");
    //            if (postResponse.succeed) {
    //                String response = postResponse.msg;
    //                if (WooCommerceJSONHelper.hasResponseError(response, dataQueryHandler)) {
    //                    return;
    //                }
    //                if (dataQueryHandler != null) {
    //                    dataQueryHandler.onSuccess(parseJsonAndCreateCountries(response));
    //                    countriesLoaded = true;
    //                }
    //            } else {
    //                if (dataQueryHandler != null) {
    //                    dataQueryHandler.onFailure(postResponse.error);
    //                }
    //            }
    //        }
    //    };
    //    Helper.makeCommonPostRequest(request_url_countries, postParams, postResponseListener);
    
    
}
- (void)getStates:(TMRegion*)parentRegion
          success:(void(^)(id data))success
          failure:(void(^)(NSString* error))failure {
    
    if (parentRegion.regionIsLoaded) {
        if (success != nil) {
            success([TMRegion getRegions:parentRegion]);
        }
        return;
    }
}
- (void)getDistricts:(TMRegion*)parentRegion
             success:(void(^)(id data))success
             failure:(void(^)(NSString* error))failure {
    if (failure != nil) {
        failure(@"NoSuchMethodException");
    }
}
- (void)getSubDistricts:(TMRegion*)parentRegion
                success:(void(^)(id data))success
                failure:(void(^)(NSString* error))failure {
    if (failure != nil) {
        failure(@"NoSuchMethodException");
    }
}
- (void)getCities:(TMRegion*)parentRegion
          success:(void(^)(id data))success
          failure:(void(^)(NSString* error))failure {
    if (failure != nil) {
        failure(@"NoSuchMethodException");
    }
}
- (void)calculateShipping:(TMRegion*)regionOrigin
        regionDestination:(TMRegion*)regionDestination
                  success:(void(^)(id data))success
                  failure:(void(^)(NSString* error))failure {
    if (failure != nil) {
        failure(@"NoSuchMethodException");
    }
}
- (void)getAvailableShipping:(TMStoreInfo*)storeInfo
           regionDestination:(TMRegion*)regionDestination
                      weight:(float)weight
                     success:(void(^)(id data))success
                     failure:(void(^)(NSString* error))failure {
    if (failure != nil) {
        failure(@"NoSuchMethodException");
    }
}
- (void)getCurrencyRate:(void(^)(id data))success
                failure:(void(^)(NSString* error))failure {
    if (failure != nil) {
        failure(@"NoSuchMethodException");
    }
}
- (void)getStoreLocation:(void(^)(id data))success
                 failure:(void(^)(NSString* error))failure {
    if (failure != nil) {
        failure(@"NoSuchMethodException");
    }
}
- (NSMutableArray*)parseJsonAndCreateCountries:(TMRegion*)parentRegion response:(id)response {
    NSMutableArray* countries = [[NSMutableArray alloc] init];
    NSMutableArray* states = [[NSMutableArray alloc] init];
    if (IS_NOT_NULL(response, @"list")) {
        NSArray* listOfCountries = GET_VALUE_OBJECT(response, @"list");
        for (NSDictionary* countryDict in listOfCountries) {
            NSString* countryID = @"";
            NSString* countryName = @"";
            if (IS_NOT_NULL(countryDict, @"id")) {
                countryID = [NSString stringWithFormat:@"%@", GET_VALUE_STRING(countryDict, @"id")];
                //if (countryID && [countryID isEqualToString:@"US"]) {
                //    RLOG(@"countryID = %@", countryID);
                //}
            }
            if (IS_NOT_NULL(countryDict, @"n"))
                countryName = [NSString stringWithFormat:@"%@", GET_VALUE_STRING(countryDict, @"n")];
            TMRegion* country = [TMRegion getRegion:@"country" regionId:countryID regionTitle:countryName regionParent:nil];
            [countries addObject:country];      
            NSArray* countryStates = GET_VALUE_OBJECT(countryDict, @"s");
            for (NSDictionary* stateDict in countryStates) {
                NSString* stateID = @"";
                NSString* stateName = @"";
                if (IS_NOT_NULL(stateDict, @"id"))
                    stateID = [NSString stringWithFormat:@"%@", GET_VALUE_STRING(stateDict, @"id")];
                if (IS_NOT_NULL(stateDict, @"n"))
                    stateName = [NSString stringWithFormat:@"%@", GET_VALUE_STRING(stateDict, @"n")];
                NSString *type = @"state";
                NSString *province_id = stateID;
                NSString *province_name = stateName;
                TMRegion* state = [TMRegion getRegion:type regionId:province_id regionTitle:province_name regionParent:country];
                [states addObject:state];
            }
            country.regionIsLoaded = true;
        }
    }
    return countries;
}







//    NSMutableArray* states = [[NSMutableArray alloc] init];
//    if (response) {
//        if (IS_NOT_NULL(response, @"rajaongkir")) {
//            NSDictionary* rajaongkir = [response objectForKey:@"rajaongkir"];
//            NSArray* results = [rajaongkir objectForKey:@"results"];
//            for (NSDictionary* dict in results) {
//                NSString *type = @"province";
//                NSString *province_id = GET_VALUE_OBJECT(dict, @"province_id");
//                NSString *province_name = GET_VALUE_OBJECT(dict, @"province");
//                TMRegion* state = [TMRegion getRegion:type regionId:province_id regionTitle:province_name regionParent:parentRegion];
//                [states addObject:state];
//            }
//        }
//    }
//    return states;


@end
