//
//  AnalyticsHelper.h
//  TMStore
//
//  Created by Twist Mobile on 11/02/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Cart.h"
#import "Wishlist.h"
#import "ProductInfo.h"
#import "CategoryInfo.h"
#import "Order.h"
@interface AnalyticsHelper : NSObject
{
    
}
+(id)sharedInstance;
-(void)registerAddToCartProductEventGtm:(Cart*)cart;
-(void)registerRemoveToCartProductEventGtm:(Cart*)cart;
-(void)registerAddToWishlistProductEventGtm:(Wishlist*)wishlist;
-(void)registerRemoveToWishlistProductEventGtm:(Wishlist*)wishlist;
-(void)registerShareProductEventGtm:(ProductInfo*)pInfo;
-(void)registerLogoutEvent;
-(void)registerVisitScreenEvent:(NSString*)screenName;
-(void)registerSignUpEvent;
-(void)registerSignInEvent;
-(void)registerVisitProductEvent:(ProductInfo*)Product;
-(void)registerVisitCategoryEvent:(CategoryInfo*)category;
-(void)registerSearchEvent:(NSString*)searchString isFound:(BOOL)isFound;
-(void)registerOrderEvent:(Order*)order;
//-(void)registerPaymentEvent:(Order*)Order;
-(void)registerApplyCouponeCode:(NSString*)couponeCode;
-(void)registerPaymentMethord:(Order*)order;
-(void)registerClickOnBanner:(NSString*)banner;
@end
