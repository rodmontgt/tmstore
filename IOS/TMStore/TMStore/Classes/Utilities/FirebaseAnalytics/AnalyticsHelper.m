//
//  AnalyticsHelper.m
//  TMStore
//
//  Created by Twist Mobile on 11/02/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import "AnalyticsHelper.h"
#import "CommonInfo.h"
#import "LineItem.h"
#import "Addons.h"





@import FirebaseAnalytics;

@implementation AnalyticsHelper

+(id)sharedInstance{
    static AnalyticsHelper *sharedInstanceObj=nil;
    @synchronized(self) {
        if (sharedInstanceObj == nil)
        sharedInstanceObj = [[self alloc] init];
    }
    return sharedInstanceObj;
}
- (BOOL)isFireBaseAnalyticsEnable{
    Addons* addons = [Addons sharedManager];
    if (addons.firebaseAnalytics && addons.firebaseAnalytics.isEnabled){
        NSString *pathAndFileName = [[NSBundle mainBundle] pathForResource:@"GoogleService-Info" ofType:@"plist"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:pathAndFileName])
        {
#if ENABLE_FIREBASE_TAG_MANAGER
            return true;
#else
            return false;
#endif
        } else {
            return false;
        }
    }
    return false;
}

-(void)registerAddToCartProductEventGtm:(Cart*)cart{
    if (![self isFireBaseAnalyticsEnable]){
        return;
    }
    [FIRAnalytics logEventWithName:kFIREventAddToCart parameters:@{
                                                                   kFIRParameterQuantity:[NSNumber numberWithInt:cart.count],
                                                                   kFIRParameterItemID:[NSString stringWithFormat:@"%d", cart.product_id],
                                                                   kFIRParameterItemName:cart.productName,
                                                                   kFIRParameterItemCategory:[NSString stringWithFormat:@"%d", cart.product._parent_id],
                                                                   kFIRParameterCurrency:[CommonInfo sharedManager]->_currency,
                                                                   kFIRParameterPrice:[NSNumber numberWithDouble:cart.product._price],
                                                                   @"content_type":@"product"
                                                                   }];
}

-(void)registerRemoveToCartProductEventGtm:(Cart*)cart{
    if (![self isFireBaseAnalyticsEnable]){
        return;
    }
    
    [FIRAnalytics logEventWithName:@"remove_from_cart" parameters:@{
                                                                    kFIRParameterQuantity:[NSNumber numberWithInt:cart.count],
                                                                    kFIRParameterItemID:[NSString stringWithFormat:@"%d", cart.product_id],
                                                                    kFIRParameterItemName:cart.productName,
                                                                    kFIRParameterItemCategory:[NSString stringWithFormat:@"%d", cart.product._parent_id],
                                                                    kFIRParameterCurrency:[CommonInfo sharedManager]->_currency,
                                                                    kFIRParameterPrice:[NSNumber numberWithDouble:cart.product._price],
                                                                    @"content_type":@"product"
                                                                    }];
}
-(void)registerAddToWishlistProductEventGtm:(Wishlist*)wishlist{
    if (![self isFireBaseAnalyticsEnable]){
        return;
    }
    [FIRAnalytics logEventWithName:kFIREventAddToWishlist parameters:@{
                                                                   kFIRParameterQuantity:[NSNumber numberWithInt:wishlist.count],
                                                                   kFIRParameterItemID:[NSString stringWithFormat:@"%d", wishlist.product_id],
                                                                   kFIRParameterItemName:wishlist.productName,
                                                                   kFIRParameterItemCategory:[NSString stringWithFormat:@"%d", wishlist.product._parent_id],
                                                                   kFIRParameterCurrency:[CommonInfo sharedManager]->_currency,
                                                                   kFIRParameterPrice:[NSNumber numberWithDouble:wishlist.product._price],
                                                                   @"content_type":@"product"
                                                                   }];
}

-(void)registerRemoveToWishlistProductEventGtm:(Wishlist*)wishlist{
    if (![self isFireBaseAnalyticsEnable]){
        return;
    }
    
    [FIRAnalytics logEventWithName:@"remove_from_wishlist" parameters:@{
                                                                        kFIRParameterQuantity:[NSNumber numberWithInt:wishlist.count],
                                                                        kFIRParameterItemID:[NSString stringWithFormat:@"%d", wishlist.product_id],
                                                                        kFIRParameterItemName:wishlist.productName,
                                                                        kFIRParameterItemCategory:[NSString stringWithFormat:@"%d", wishlist.product._parent_id],
                                                                        kFIRParameterCurrency:[CommonInfo sharedManager]->_currency,
                                                                        kFIRParameterPrice:[NSNumber numberWithDouble:wishlist.product._price],
                                                                        @"content_type":@"product"
                                                                        }];
}

-(void)registerShareProductEventGtm:(ProductInfo*)pInfo{
    if (![self isFireBaseAnalyticsEnable]){
        return;
    }
    [FIRAnalytics logEventWithName:kFIREventShare parameters:@{
                                                               kFIRParameterContentType:[NSString stringWithFormat:@"%d",pInfo._id],
                                                               kFIRParameterItemID:pInfo._title,
                                                               @"content_type":@"product"
                                                               }];
}
-(void)registerLogoutEvent{
    if (![self isFireBaseAnalyticsEnable]){
        return;
    }
    
    [FIRAnalytics logEventWithName:@"logout" parameters:@{
                                                          @"logout":@"logout"
                                                          }];
}



-(void)registerVisitScreenEvent:(NSString*)screenName{
    if (![self isFireBaseAnalyticsEnable]){
        return;
    }
    
    [FIRAnalytics logEventWithName:@"visit_screen" parameters:@{
                                                                @"content_type":screenName,
                                                                }];
}
-(void)registerOrderEvent:(Order*)order {
    if (![self isFireBaseAnalyticsEnable]){
        return;
    }
   
    [FIRAnalytics logEventWithName:kFIREventEcommercePurchase parameters:@{
                                                                           kFIRParameterCurrency:[CommonInfo sharedManager]->_currency,
                                                                           kFIRParameterValue: [NSNumber numberWithDouble:[order._total doubleValue]],
                                                                           kFIRParameterTransactionID:[NSString stringWithFormat:@"%d",order._order_number],
                                                                           kFIRParameterItemID:[NSString stringWithFormat:@"%d",order._id],
                                                                           @"content_type":@"order",
                                                                           @"price":order._subtotal,
                                                                           @"payment_method_id":order._payment_details._method_id,
                                                                           @"payment_method_title":order._payment_details._method_title
                                                                           }];
    
//    for (LineItem *line in order._line_items) {
//        [FIRAnalytics setUserPropertyString:[NSString stringWithFormat:@"%d",line._id] forName:@"PRODUCT_ID"];
//        [FIRAnalytics setUserPropertyString:[NSString stringWithFormat:@"%@",line._name] forName:@"PRODUCT_NAME"];
//        [FIRAnalytics setUserPropertyString:@"product" forName:@"CONTENT_TYPE"];
//    }
}
//-(void)registerPaymentEvent:(Order*)order {
//    if (![self isFireBaseAnalyticsEnable]){
//        return;
//    }
//    
//    [FIRAnalytics logEventWithName:@"no_of_orders" parameters:@{
//                                                                kFIRParameterCurrency:[CommonInfo sharedManager]->_currency,
//                                                                kFIRParameterValue: [NSNumber numberWithDouble:[order._total doubleValue]],
//                                                                kFIRParameterTransactionID:[NSString stringWithFormat:@"%d",order._order_number],
//                                                                kFIRParameterItemID:[NSString stringWithFormat:@"%d",order._id],
//                                                                @"content_type":@"order",
//                                                                @"price":order._subtotal,
//                                                                @"payment_method_id":order._payment_details._method_id,
//                                                                @"payment_method_title":order._payment_details._method_title
//                                                                }];
//}
-(void)registerVisitProductEvent:(ProductInfo*)Product{
    if (![self isFireBaseAnalyticsEnable]){
        return;
    }
    [FIRAnalytics logEventWithName:kFIREventViewItem parameters:@{
                                                                  kFIRParameterItemID:[NSString stringWithFormat:@"%d",Product._id],
                                                                  kFIRParameterItemName:Product._title,
                                                                  kFIRParameterItemCategory:[CommonInfo sharedManager]->_currency,
                                                                  @"content_type":@"product"
                                                                  }];
}

-(void)registerVisitCategoryEvent:(CategoryInfo*)category{
    if (![self isFireBaseAnalyticsEnable]){
        return;
    }
    
    [FIRAnalytics logEventWithName:@"view_category" parameters:@{
                                                                 kFIRParameterItemID:[NSString stringWithFormat:@"%d",category._id],
                                                                 kFIRParameterItemCategory:category._name,
                                                                 @"content_type":@"category"
                                                                 }];
}

-(void)registerSearchEvent:(NSString*)searchString isFound:(BOOL)isFound {
    if (![self isFireBaseAnalyticsEnable]){
        return;
    }
    NSString* isFoundString = @"false";
    if (isFound) {
        isFoundString = @"true";
    }
    [FIRAnalytics logEventWithName:kFIREventViewSearchResults parameters:@{
                                                          kFIRParameterSearchTerm:searchString,
                                                          @"value":isFoundString,
                                                          @"content_type":@"product"
                                                          }];
}
-(void)registerSignUpEvent{
    if (![self isFireBaseAnalyticsEnable]){
        return;
    }
    [FIRAnalytics logEventWithName:kFIREventSignUp parameters:@{
                                                          kFIRParameterSignUpMethod:@"Sign up Methord",
                                                           }];
}
-(void)registerSignInEvent{
    if (![self isFireBaseAnalyticsEnable]){
        return;
    }
    [FIRAnalytics logEventWithName:kFIREventLogin parameters:@{
                                                               @"sign_in_methord":@"Sign in Methord",
                                                               }];
}
-(void)registerApplyCouponeCode:(NSString*)couponeCode{
    [FIRAnalytics logEventWithName:@"coupon_apply" parameters:@{
                                                              kFIRParameterCoupon:couponeCode,
                                                              }];
}
-(void)registerPaymentMethord:(Order*)order{
    [FIRAnalytics logEventWithName:kFIREventAddPaymentInfo parameters:@{
                                                                @"payment_method_id":order._payment_details._method_id,
                                                                @"payment_method_title":order._payment_details._method_title
                                                                }];
}
-(void)registerClickOnBanner:(NSString*)banner{
    [FIRAnalytics logEventWithName:@"click_on_banner" parameters:@{
                                                                 kFIRParameterItemID:[NSString stringWithFormat:@"%@",banner],
                                                                 }];
}
@end
