//
//  Coupon.m
//  TMStore
//
//  Created by Rishabh Jain on 08/04/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import "Coupon.h"
#import "Variables.h"
#import "ProductInfo.h"
#import "Cart.h"
#import "Utility.h"
#import "AppUser.h"

static NSMutableArray* _allCoupons = NULL;//ARRAY OF Coupon
static NSMutableArray *couponsListToAdd;
@implementation Coupon
+ (NSMutableArray*)getAllCoupons {
    if (_allCoupons == NULL) {
        _allCoupons = [[NSMutableArray alloc] init];
    }
    return _allCoupons;
}
- (id)init {
    self = [super init];
    if (self) {
        if (_allCoupons == NULL) {
            _allCoupons = [[NSMutableArray alloc] init];
        }
        [_allCoupons addObject:self];
        self._product_ids = [[NSMutableArray alloc] init];
        self._exclude_product_ids = [[NSMutableArray alloc] init];
        self._product_category_ids = [[NSMutableArray alloc] init];
        self._exclude_product_category_ids = [[NSMutableArray alloc] init];
        self._customer_emails = [[NSMutableArray alloc] init];
        self._usage_limit = 99999;
        self._usage_limit_per_user = 99999;
        self._expiry_date = nil;
        self._couponDiscountOnApply = 0;
        couponsListToAdd = [[NSMutableArray alloc] init];
    }
    return self;
}
+ (id)sharedInstance {
    static Coupon *sharedInstanceObj=nil;
    @synchronized(self) {
        if (sharedInstanceObj == nil)
            sharedInstanceObj = [[self alloc] init];
    }
    return sharedInstanceObj;
}
- (BOOL)applicableForId:(int)productId isProductOnSale:(BOOL)isProductOnSale {
    if (self._exclude_sale_items && isProductOnSale) {
        return false;
    }
    if(![self._product_ids count] == 0) {
        if ([self._product_ids containsObject:[NSNumber numberWithInt:productId]]) {
            return true;
        } else {
            return false;
        }
    } else if(![self._exclude_product_ids count] == 0) {
        if ([self._exclude_product_ids containsObject:[NSNumber numberWithInt:productId]]) {
            return false;
        }else {
            return true;
        }
    }
    return true;
}
+ (Coupon*)getWithCode:(NSString*)couponCode {
    for (Coupon* obj in _allCoupons) {
        if ([[obj._code lowercaseString] isEqualToString:[couponCode lowercaseString]]) {
            return obj;
        }
    }
    return nil;
}
- (NSString*)verify:(NSMutableArray*)selectedProductIds selectedCategoryIds:(NSMutableArray*)selectedCategoryIds userEmail:(NSString*)userEmail total_amount:(float)total_amount selectedProductVariations:(NSMutableArray*)selectedProductVariations {
    
    if ([self._product_ids count] > 0) {
        if ([self._type isEqualToString:@"fixed_product"] || [self._type isEqualToString:@"percent_product"]) {
            BOOL applicableProductFound = false;
            
            for (NSNumber* obj  in selectedProductIds) {
                if ([self._product_ids containsObject:obj]) {
                    applicableProductFound = true;
                    break;
                }
            }
            if (applicableProductFound == false) {
                for (NSNumber* obj  in selectedProductVariations) {
                    if ([self._product_ids containsObject:obj]) {
                        applicableProductFound = true;
                        break;
                    }
                }
            }
            
            if (!applicableProductFound) {
                return Localize(@"coupon_not_applicable_for_products");
            }
        } else {
            
        }
    }
    
    if([self._exclude_product_ids count] > 0) {
        if([self._type isEqualToString:@"fixed_product"] || [self._type isEqualToString: @"percent_product"]) {
            BOOL applicableProductFound = true;
            for (NSNumber* obj in selectedProductIds) {
                if ([self._exclude_product_ids containsObject:obj]) {
                    applicableProductFound = false;
                    break;
                }
            }
            if (applicableProductFound == true) {
                for (NSNumber* obj in selectedProductVariations) {
                    if ([self._exclude_product_ids containsObject:obj]) {
                        applicableProductFound = false;
                        break;
                    }
                }
            }
            
            
            if (!applicableProductFound) {
                return Localize(@"coupon_not_applicable_for_products");
            }
        } else {
            for (NSNumber* obj in selectedProductIds) {
                if (![self._exclude_product_ids containsObject:obj]) {
                    return [NSString stringWithFormat:Localize(@"coupon_invalid_for_product"), [ProductInfo getProductWithId:[obj intValue]]._title];
                    break;
                }
            }
        }
    }
    
    if (self._usage_limit <= 0 || self._usage_count > self._usage_limit) {
        return Localize(@"coupon_surpasses_total_usage_limit");
    }
    
    if(self._usage_limit_per_user <= 0){
        return Localize(@"coupon_exceeds_usage_limit");
    }
    
    if(self._limit_usage_to_x_items > 0 && [selectedProductIds count] > self._limit_usage_to_x_items){
        return [NSString stringWithFormat:Localize(@"coupon_not_applicable_for_items"), self._limit_usage_to_x_items];
    }
    
    if(self._expiry_date != nil) {
        NSComparisonResult result;
        result = [[self today] compare:self._expiry_date];
        if(result==NSOrderedAscending) {
            RLOG(@"today is less");
        }
        else if(result == NSOrderedDescending){
            RLOG(@"expiry is less");
            return Localize(@"coupon_expired");
        }
        else {
            RLOG(@"Both dates are same");
        }
    }
    
    if([self._product_category_ids count] > 0) {
        for (NSNumber *obj in selectedCategoryIds) {
            if (![self._product_category_ids containsObject:obj]) {
                return Localize(@"coupon_not_applicable_for_category");
            }
        }
    }
    
    if([self._exclude_product_category_ids count] > 0) {
        for (NSNumber *obj in selectedCategoryIds) {
            if ([self._exclude_product_category_ids containsObject:obj]) {
                return Localize(@"coupon_not_applicable_for_category");
            }
        }
    }
    
    if(self._exclude_sale_items) {
        int i = 0;
        for (NSNumber* obj in selectedProductIds) {
            ProductInfo *productInfo = [ProductInfo getProductWithId:[obj intValue]];
            int variationId = [[selectedProductVariations objectAtIndex:i] intValue];
            if([productInfo isProductDiscounted:variationId]){
                return Localize(@"coupon_invalid_for_already_sale_items");
            }
            i++;
        }
    }
    
    
    if(self._minimum_amount > 0 && total_amount < self._minimum_amount){
        return [NSString stringWithFormat:Localize(@"coupon_valid_for_min_purchase"), [[Utility sharedManager] convertToString:self._minimum_amount isCurrency:true]];
    }
    if(self._maximum_amount > 0 && total_amount > self._maximum_amount){
        return [NSString stringWithFormat:Localize(@"coupon_valid_for_max_purchase"), [[Utility sharedManager] convertToString:self._maximum_amount isCurrency:true]];
    }
    
    if([self._customer_emails count] > 0){
        if(![self._customer_emails containsObject:userEmail]){
            return Localize(@"coupon_not_applicable_for_email");
        }
    }
    return @"success";
}

- (NSDate*) today {
    return [NSDate date];
}

- (void)register {
    [_allCoupons addObject:self];
}

-(NSMutableArray*)getcouponList{
    [couponsListToAdd removeAllObjects];
    RLOG(@"_allCoupons  %lu",(unsigned long)_allCoupons.count);
    for (Coupon *obj in _allCoupons) {
        AppUser* appUser = [AppUser sharedManager];
        
//        RLOG(@"self._customer_emails count %lu",(unsigned long)self._customer_emails.count);
        self.shouldAddThisCoupon = true;
        RLOG(@"[self._customer_emails count]%@",self._customer_emails);
        if(obj._customer_emails.count>0){
            if(appUser._email != nil && appUser._email.length != 0){
                if(![obj._customer_emails containsObject:appUser._email]){
                    self.shouldAddThisCoupon = false;
                }
            }
        }
        if(self.shouldAddThisCoupon && obj._code != nil){
            [couponsListToAdd addObject:obj];
            RLOG(@"self.couponsListToAdd  %@",couponsListToAdd);
        }
    }
    return couponsListToAdd;
}
@end
