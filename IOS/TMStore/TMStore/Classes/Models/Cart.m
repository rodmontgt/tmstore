//
//  Cart.m
//  eCommerceApp
//
//  Created by Rishabh Jain on 02/10/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import "Cart.h"
#import "AppUser.h"
#import "Attribute.h"
#import "ParseHelper.h"
#import "Variables.h"
#import "Coupon.h"
#import "AppDelegate.h"
#import "AnalyticsHelper.h"
#import "TM_PickupLocation.h"
static NSMutableArray* _allCartItems = NULL;//ARRAY OF Cart
static NSMutableArray* _applied_coupons = nil;//ARRAY OF COUPONS
static int _notificationCount = 0;
static NSString* _orderNote = @"";
static NSString* _orderNoteCartItems = @"";
static NSString* _orderNoteCart = @"";
static NSString* _orderNoteOrder = @"";
static float mPointsPriceDiscount = 0.0f;

@implementation Cart
+ (NSMutableArray*)getAppliedCoupons {
    return _applied_coupons;
}
+ (NSString*)addCoupon:(Coupon*) coupon {
    if (_applied_coupons == nil) {
        _applied_coupons = [[NSMutableArray alloc] init];
    }
    
    for (Coupon *c in _applied_coupons) {
        if (c._id == coupon._id) {
            return Localize(@"This coupon is already applied.");
        } else if (c._individual_use) {
            return Localize(@"This Coupon can not be combined with previous coupons.");
        }
    }
    
    
    if (coupon._individual_use && [_applied_coupons count] > 0) {
        [_applied_coupons removeAllObjects];
    }
    
    [_applied_coupons addObject:coupon];
    return @"success";
}
+ (void) removeCoupon:(int) couponId {
    for (Coupon *coupon in _applied_coupons) {
        if (coupon._id == couponId) {
            [_applied_coupons removeObject:coupon];
            break;
        }
    }
}
+ (BOOL) isAnyCouponApplied {
    return !(_applied_coupons == nil || [_applied_coupons count]);
}
+ (float) getTotalCouponBenefits:(float)totalCartPayment {
    for (Cart* cart in _allCartItems) {
        cart.discountTotal = 0.0f;
    }
    
    float totalCardDiscount = 0;
    if (_applied_coupons != nil) {
        for (Coupon* coupon in _applied_coupons) {
            
            
            float thisCouponDiscount = 0;
            if ([coupon._type isEqualToString:@"percent"]) {//basket percent
                for (Cart* cart in _allCartItems) {
                    cart.discountTotal = cart.originalTotal * coupon._amount * 1.0f / 100.0f;
                }
                float discoutAmount = totalCartPayment * coupon._amount * 1.0f / 100.0f;
                totalCardDiscount += discoutAmount;
                thisCouponDiscount += discoutAmount;
            }
            else if ([coupon._type isEqualToString:@"fixed_product"]) {//product price
                //total -= coupon.amount;
                int _limit_usage_to_x_items = coupon._limit_usage_to_x_items;
                for (Cart* cart in _allCartItems) {
                    if (_limit_usage_to_x_items > 0 || coupon._limit_usage_to_x_items == 0) {
                        if ([coupon applicableForId:cart.product_id isProductOnSale:cart.product._on_sale] || [coupon applicableForId:cart.selectedVariationId isProductOnSale:cart.product._on_sale]) {
                            int discountOnItems = 0;
                            if (cart.count >= _limit_usage_to_x_items && coupon._limit_usage_to_x_items > 0) {
                                discountOnItems = _limit_usage_to_x_items;
                            }else{
                                discountOnItems = cart.count;
                            }
                            _limit_usage_to_x_items -= discountOnItems;
                            totalCardDiscount += (coupon._amount * discountOnItems);
                            thisCouponDiscount += (coupon._amount * discountOnItems);
                            cart.discountTotal += (coupon._amount * discountOnItems);
                        }
                        
                    }
                }
            }
            else if ([coupon._type isEqualToString:@"percent_product"]) {//product percent
                //float discoutAmount = total * coupon.amount * 1.0f / 100.0f;
                //total -= discoutAmount;
                int _limit_usage_to_x_items = coupon._limit_usage_to_x_items;
                for (Cart* cart in _allCartItems) {
                    if (_limit_usage_to_x_items > 0 || coupon._limit_usage_to_x_items == 0) {
                        if ([coupon applicableForId:cart.product_id isProductOnSale:cart.product._on_sale] || [coupon applicableForId:cart.selectedVariationId isProductOnSale:cart.product._on_sale]) {
                            int discountOnItems = 0;
                            if (cart.count >= _limit_usage_to_x_items && coupon._limit_usage_to_x_items > 0) {
                                discountOnItems = _limit_usage_to_x_items;
                            }else{
                                discountOnItems = cart.count;
                            }
                            _limit_usage_to_x_items -= discountOnItems;
                            float productPrice =  [cart.product getNewPrice:cart.selectedVariationId] * discountOnItems;
                            float discoutAmount = productPrice * coupon._amount * 1.0f / 100.0f;
                            totalCardDiscount += discoutAmount;
                            thisCouponDiscount += discoutAmount;
                            cart.discountTotal += discoutAmount;
                        }
                    }
                }
            }
            else {//basket price
                totalCardDiscount += coupon._amount;
                thisCouponDiscount += coupon._amount;
                if (totalCartPayment != 0) {
                    for (Cart* cart in _allCartItems) {
                        cart.discountTotal += (coupon._amount * (cart.originalTotal/totalCartPayment));
                    }
                } else {
                    for (Cart* cart in _allCartItems) {
                        cart.discountTotal += 0.0f;
                    }
                }
            }
            coupon._couponDiscountOnApply = thisCouponDiscount;
        }
    }

    if([[Addons sharedManager] enable_custom_points]) {
        float totalPointsDiscountPrice = [self getPointsPriceDiscount];
        totalCardDiscount += totalPointsDiscountPrice;
        for (Cart* cart in _allCartItems) {
            float actualProductPrice = [cart getDiscountedPrice];
            float discountForProduct = actualProductPrice < totalPointsDiscountPrice ? actualProductPrice : totalPointsDiscountPrice;
            cart.discountTotal += discountForProduct;
            totalPointsDiscountPrice -= discountForProduct;
            if (totalPointsDiscountPrice <= 0)
                break;
        }
    }
    return totalCardDiscount;
}
+ (void) clearCoupons {
    if (_applied_coupons != nil) {
        [_applied_coupons removeAllObjects];
        _applied_coupons = nil;
    }
}

+ (void)setCartArray:(NSMutableArray*)array{
    _allCartItems = array;
    _notificationCount = 0;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATE_NOTIFICATION_COUNT" object:nil];
}
- (id)initWithParameters:(int)product_id product:(ProductInfo *)product variationId:(int)variationId variationIndex:(int)variationIndex {
    self = [super init];
    if (self) {
        self.product_id = product_id;
        self.productName = product._title;
        self.product = product;
        if (product && product._images && [product._images count] > 0) {
            self.productImgUrl = ((ProductImage*)[product._images objectAtIndex:0])._src;
        }
        self.productPrice = [product getNewPrice:variationId];
        self.mMixMatchProducts = [[NSMutableArray alloc] init];
        self.mBundleProducts = [[NSMutableArray alloc] init];
        self.taxOnProduct = 0.0f;
        
        int stepValue = 1;
        int minValue = 1;
        if (product.quantityRule && product.quantityRule.orderrideRule) {
            stepValue = product.quantityRule.stepValue;
            minValue = product.quantityRule.minQuantity;
        }
        if (self.count == 0) {
            self.count = minValue;
        } else {
            self.count += stepValue;
        }
        self.note = @"";
        if (variationId != -1) {
            self.selectedVariationId = variationId;
        }else{
            self.selectedVariationId = -1;
        }
        if (variationIndex != -1) {
            self.selectedVariationIndex = variationIndex;
        }else{
            self.selectedVariationIndex = -1;
        }
        if (_allCartItems == NULL)
        {
            _allCartItems = [[AppUser sharedManager] _cartArray];
        }
        
        [_allCartItems addObject:self];
        
        _prddDay = nil;
        _prddTime = nil;
        _prddDate = @"";
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.product_id = [decoder decodeIntForKey:@"#1"];
        self.count = [decoder decodeIntForKey:@"#2"];
        self.selected_attributes = [decoder decodeObjectForKey:@"#3"];
        self.selectedVariationId = [decoder decodeIntForKey:@"#4"];
        self.productName = [decoder decodeObjectForKey:@"#5"];
        self.productPrice = [decoder decodeFloatForKey:@"#6"];
        self.productImgUrl = [decoder decodeObjectForKey:@"#7"];
        self.selectedVariationIndex = [decoder decodeIntForKey:@"#8"];
        self.note = [decoder decodeObjectForKey:@"#9"];
        self.product = [ProductInfo getProductWithId:self.product_id];
        if (self.product._isSmallRetrived == false) {
            self.product._title = self.productName;
            self.product._titleForOuterView = self.productName;
            self.product._price = self.productPrice;
            ProductImage* img = [[ProductImage alloc] init];
            img._src = self.productImgUrl;
            [self.product._images addObject:img];
        }
        
        self.prddDate = [decoder decodeObjectForKey:@"#10"];
        self.prddDay = [decoder decodeObjectForKey:@"#11"];
        self.prddTime = [decoder decodeObjectForKey:@"#12"];

        
        self.mBundleProducts = [decoder decodeObjectForKey:@"#13"];
        self.mBundles_ProductCopy =  [decoder decodeObjectForKey:@"#14"];
        
        self.productType =  [decoder decodeIntForKey:@"#15"];
        
        if (self.product) {
            self.product._type = self.productType;
            if (self.product.mBundles == nil) {
                self.product.mBundles = self.mBundles_ProductCopy;
            } else {
                if (self.mBundles_ProductCopy && [self.mBundles_ProductCopy count] > 0) {
                    self.product.mBundles = self.mBundles_ProductCopy;
                }
            }
        }
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt:self.product_id forKey:@"#1"];
    [encoder encodeInt:self.count forKey:@"#2"];
    [encoder encodeObject:self.selected_attributes forKey:@"#3"];
    [encoder encodeInt:self.selectedVariationId forKey:@"#4"];
    [encoder encodeObject:self.productName forKey:@"#5"];
    [encoder encodeFloat:self.productPrice forKey:@"#6"];
    [encoder encodeObject:self.productImgUrl forKey:@"#7"];
    [encoder encodeInt:self.selectedVariationIndex forKey:@"#8"];
    [encoder encodeObject:self.note forKey:@"#9"];
    
    [encoder encodeObject:self.prddDate forKey:@"#10"];
    [encoder encodeObject:self.prddDay forKey:@"#11"];
    [encoder encodeObject:self.prddTime forKey:@"#12"];
    
    [encoder encodeObject:self.mBundleProducts forKey:@"#13"];
    [encoder encodeObject:self.mBundles_ProductCopy forKey:@"#14"];
    [encoder encodeInt:self.productType forKey:@"#15"];
}
+ (void)removeAllProduct {
    mPointsPriceDiscount = 0.0f;
    _notificationCount = 0;
    [_allCartItems removeAllObjects];
    [Cart clearCoupons];
    RLOG(@"-- _allCartItems  removeAllObjects--");
}
+ (void)refresh{
    [self prepareCart];
}
+ (int)getNotificationItemCount {
    
    if ([[DataManager sharedManager] layoutIdProductView] == P_LAYOUT_GROCERY) {
        return [Cart getItemCount];
    }
    
    return (int)[[Cart getAll] count];
    if (_notificationCount < 0) {
        _notificationCount = 0;
    }
    return _notificationCount;// (int)[_allCartItems count];
}
+ (void)resetNotificationItemCount {
    _notificationCount = 0;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATE_NOTIFICATION_COUNT" object:nil];
}
+ (float)getTotalPayment {
    float totalCartPayment = [Cart getTotalPaymentExclusiveOfCoupons];
    float totalCouponBenefits = [Cart getTotalCouponBenefits:totalCartPayment];
    float finalTotal = totalCartPayment - totalCouponBenefits;
    if (finalTotal< 0 ) {
        finalTotal = 0.0f;
    }
    return finalTotal;
    //    return total;
}
- (float)getCartTotal {
    ProductInfo* p = self.product;
    Variation* variation = [p._variations getVariation:self.selectedVariationId variationIndex:self.selectedVariationIndex];
    BOOL isDiscounted;
    float newPrice;
    float oldPrice;
    if (variation) {
        isDiscounted = [p isProductDiscounted:variation._id];
        newPrice = [p getNewPrice:variation._id] + [ProductInfo getExtraPrice:self.selected_attributes pInfo:p];
        oldPrice = [p getOldPrice:variation._id];
    } else {
        isDiscounted = [p isProductDiscounted:-1];
        newPrice = [p getNewPrice:-1];
        oldPrice = [p getOldPrice:-1];
    }
    return (newPrice * self.count);
}
+ (float)getTotalPaymentExclusiveOfCoupons {
    float total = 0.0f;
    for (Cart* c in _allCartItems) {
        ProductInfo* p = c.product;
        Variation* variation = [p._variations getVariation:c.selectedVariationId variationIndex:c.selectedVariationIndex];
        BOOL isDiscounted;
        float newPrice;
        float oldPrice;
        float newPriceExcludingTax;
        float oldPriceExcludingTax;
        if (variation) {
            isDiscounted = [p isProductDiscounted:variation._id];
            newPriceExcludingTax = [p getNewPriceOriginal:variation._id] + [ProductInfo getExtraPrice:c.selected_attributes pInfo:p];
            oldPriceExcludingTax = [p getOldPriceOriginal:variation._id];
            newPrice = [p getNewPrice:variation._id] + [ProductInfo getExtraPrice:c.selected_attributes pInfo:p];
            oldPrice = [p getOldPrice:variation._id];
        } else {
            isDiscounted = [p isProductDiscounted:-1];
            newPriceExcludingTax = [p getNewPriceOriginal:-1];
            oldPriceExcludingTax = [p getOldPriceOriginal:-1];
            newPrice = [p getNewPrice:-1];
            oldPrice = [p getOldPrice:-1];
        }
        if ([[Addons sharedManager] enable_mixmatch_products]) {
            if (c.product.mMixMatch) {
                newPrice = 0.0f;
                newPriceExcludingTax = 0.0f;
                for (CartMatchedItem* cmItems in c.mMixMatchProducts) {
                    newPrice +=  (cmItems.quantity * cmItems.price);
                    newPriceExcludingTax +=  (cmItems.quantity * cmItems.price);
                }
            }
        }
        total += (newPrice * c.count);
        c.originalTotal = (newPrice * c.count);
        c.originalTotalExcludingTax = (newPriceExcludingTax * c.count);
    }
    return total;
}
+ (float)getTotalSavings{
    float total = 0.0f;
    for (Cart* c in _allCartItems) {
        ProductInfo* p = c.product;
        Variation* variation = [p._variations getVariation:c.selectedVariationId variationIndex:c.selectedVariationIndex];
        BOOL isDiscounted;
        float newPrice = 0.0f;
        float oldPrice = 0.0f;
        float discountPrice = 0.0f;
        if (variation) {
            isDiscounted = [p isProductDiscounted:variation._id];
            if (isDiscounted) {
                newPrice = [p getNewPrice:variation._id] + [ProductInfo getExtraPrice:c.selected_attributes pInfo:p];
                oldPrice = [p getOldPrice:variation._id];
                discountPrice = oldPrice - newPrice;
            }
        } else {
            isDiscounted = [p isProductDiscounted:-1];
            if (isDiscounted) {
                newPrice = [p getNewPrice:-1];
                oldPrice = [p getOldPrice:-1];
                discountPrice = oldPrice - newPrice;
            }
        }
        
        
        if ([[Addons sharedManager] enable_mixmatch_products]) {
            if (c.product.mMixMatch) {
                newPrice = 0.0f;
                for (CartMatchedItem* cmItems in c.mMixMatchProducts) {
                    newPrice +=  (cmItems.quantity * cmItems.price);
                }
                discountPrice = 0;
            }
        }
        
        
        total += (discountPrice * c.count);
        
        //        ProductInfo* p = c.product;
        //        float realSellingPrice = p._sale_price > 0 ? p._sale_price: p._price;
        //        if (p._regular_price > 0 && p._regular_price > realSellingPrice) {
        //            total += (p._regular_price - realSellingPrice) * c.count;
        //        }
    }
    return total;
}
+ (NSMutableArray*)getAll {//ARRAY OF Cart
    return _allCartItems;
}
+ (int) getItemCount {
    int total = 0;
    for (Cart* c in _allCartItems) {
        total += c.count;
    }
    return total;
    //    if(_allCartItems == nil){
    //        return 0;
    //    }
    //    return (int)[_allCartItems count];
}
+ (void)prepareCart {
    for (Cart* c in _allCartItems) {
        c.product = [ProductInfo getProductWithId:c.product_id];
    }
}

+ (BOOL)isEqualAttributes:(NSMutableArray*)cartAttributes attributes:(NSMutableArray*)attributes{
    
    if (cartAttributes == nil && attributes == nil) {
        return true;
    }
    
    if ((cartAttributes == nil && attributes != nil) || (cartAttributes != nil && attributes == nil)) {
        return false;
    }
    
    if (cartAttributes != nil && attributes != nil) {
        if ([cartAttributes count] != [attributes count]) {
            return false;
        }
        else {
            for (BasicAttribute* pa in attributes) {
                for (BasicAttribute* ca in cartAttributes) {
                    if ([pa.attributeName isEqualToString:ca.attributeName]) {
                        if (![pa.attributeValue isEqualToString:ca.attributeValue]) {
                            return false;
                        }
                    }
                }
            }
        }
    }
    
    return true;
}
+ (BOOL)compareSelectedVariationAttributes:(NSMutableArray*)array1 array2:(NSMutableArray*)array2 {
    
    if (array1 == nil && array2 == nil) {
        return true;
    }
    else if(array1 == nil && [array2 count] == 0) {
        return true;
    }
    else if(array2 == nil && [array1 count] == 0) {
        return true;
    }
    else {
        if (array1 != nil && array2 != nil) {
            for (VariationAttribute* va1 in array1) {
                for (VariationAttribute* va2 in array2) {
                    if ([va1.slug isEqualToString:va2.slug]) {
                        if (![va1.value isEqualToString:va2.value]) {
                            return false;
                        }
                    }
                }
            }
        }else {
            return false;
        }
    }
    return true;
}
+ (Cart*)removeProduct:(ProductInfo*)product variationId:(int)variationId variationIndex:(int)variationIndex selectedVariationAttributes:(NSMutableArray*)selectedVariationAttributes {
#if ENABLE_PARSE_ANALYTICS
    [[ParseHelper sharedManager] registerParseCartProduct:product._id categoryId:product._parent_id increment:-1];
#endif
    if ([Coupon getAllCoupons] == NULL || [[Coupon getAllCoupons] count] == 0) {
        [[[DataManager sharedManager] tmDataDoctor] fetchCouponsData:nil];
    }
    for (Cart* c in _allCartItems) {
        if(c.product_id == product._id && c.selectedVariationId == variationId && c.selectedVariationIndex == variationIndex && ([Cart compareSelectedVariationAttributes:selectedVariationAttributes array2:c.selected_attributes])) {
            BOOL isCartExist = true;
            
            
            
            int stepValue = 1;
            int minValue = 1;
            if (product.quantityRule && product.quantityRule.orderrideRule) {
                stepValue = product.quantityRule.stepValue;
                minValue = product.quantityRule.minQuantity;
            }
            c.count -= stepValue;
            
            if (c.count < minValue) {
                [self removeSafely:c];
                isCartExist = false;
            }
            
            
            
            [Cart clearCoupons];
            _notificationCount--;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATE_NOTIFICATION_COUNT" object:nil];
#if ENABLE_PARSE_ANALYTICS
            [[ParseHelper sharedManager] registerParseCustomerCart];
#endif
            if (isCartExist) {
#if ENABLE_FIREBASE_TAG_MANAGER
                [[AnalyticsHelper sharedInstance] registerRemoveToCartProductEventGtm:c];
#endif
                return c;
            }
            return nil;
        }
    }
    [_allCartItems removeAllObjects];
    _notificationCount = 0;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATE_NOTIFICATION_COUNT" object:nil];
    RLOG(@"-- Can't remove, requested product not found in Cart --");
#if ENABLE_PARSE_ANALYTICS
    [[ParseHelper sharedManager] registerParseCustomerCart];
#endif
    [Cart clearCoupons];
    return nil;
}
+ (Cart*)hasProduct:(ProductInfo*)product variationId:(int)variationId variationIndex:(int)variationIndex selectedVariationAttributes:(NSMutableArray*)selectedVariationAttributes {

    for (Cart* c in _allCartItems) {
        if(c.product_id == product._id && c.selectedVariationId == variationId && c.selectedVariationIndex == variationIndex && ([Cart compareSelectedVariationAttributes:selectedVariationAttributes array2:c.selected_attributes])) {
            return c;
        }
    }
    return nil;
}


+ (void)removeProduct:(ProductInfo*)product variationId:(int)variationId variationIndex:(int)variationIndex {
#if ENABLE_PARSE_ANALYTICS
    [[ParseHelper sharedManager] registerParseCartProduct:product._id categoryId:product._parent_id increment:-1];
#endif
    for (Cart* c in _allCartItems) {
        if(c.product_id == product._id && c.selectedVariationId == variationId && c.selectedVariationIndex == variationIndex){
#if ENABLE_FIREBASE_TAG_MANAGER
            [[AnalyticsHelper sharedInstance] registerRemoveToCartProductEventGtm:c];
#endif
            [self removeSafely:c];
            //            [c save];
            _notificationCount--;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATE_NOTIFICATION_COUNT" object:nil];
#if ENABLE_PARSE_ANALYTICS
            [[ParseHelper sharedManager] registerParseCustomerCart];
#endif
            return;
        }
    }
    [_allCartItems removeAllObjects];
    _notificationCount = 0;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATE_NOTIFICATION_COUNT" object:nil];
    RLOG(@"-- Can't remove, requested product not found in Cart --");
#if ENABLE_PARSE_ANALYTICS
    [[ParseHelper sharedManager] registerParseCustomerCart];
#endif
}
+ (BOOL)hasItem:(ProductInfo*)product variationId:(int)variationId variationIndex:(int)variationIndex
{
    for(Cart* c in _allCartItems)
    {
        if(c.product_id == product._id && c.selectedVariationId == variationId && c.selectedVariationIndex == variationIndex)
        {
            return true;
        }
    }
    return false;
}
+ (BOOL)hasItemCheckViaProductIdOnly:(ProductInfo*)product{
    for(Cart* c in _allCartItems)
    {
        if(c.product_id == product._id){
            return true;
        }
    }
    return false;
}
+ (Cart*)getCartFromProduct:(ProductInfo*)product variationId:(int)variationId variationIndex:(int)variationIndex{
    for(Cart* c in _allCartItems)
    {
        if(c.product_id == product._id && c.selectedVariationId == variationId && c.selectedVariationIndex == variationIndex)
        {
            return c;
        }
    }
    return nil;
}


//+ (BOOL)hasItem:(ProductInfo*)product attributes:(NSMutableArray*)attributes
//{
//    for(Cart* c in _allCartItems)
//    {
//        c.selected_attributes = (NSMutableArray*)[c.selected_attributes sortedArrayUsingSelector:@selector(compare:)];
//        attributes = (NSMutableArray*)[attributes sortedArrayUsingSelector:@selector(compare:)];
//        if(c.product_id == product._id && [c.selected_attributes isEqualToArray:attributes])
//        {
//            return true;
//        }
//    }
//    return false;
//}
+ (void)removeSafely:(Cart*)cart{
    RLOG(@"------- removeSafely: [%@] -------", cart.product._title);
    [_allCartItems removeObject:cart];
}
+ (void)printAll{
    for (Cart* c in _allCartItems) {
        RLOG(@"------- Cart:[Id:%d][Count:%d] --------", c.product_id, c.count);
    }
}
- (int)getProductAvailibleQuantity:(int)userDemand {
    ProductInfo* pInfo = self.product;
    Variation* variation = [pInfo._variations getVariation:self.selectedVariationId variationIndex:self.selectedVariationIndex];
    BOOL inStock = pInfo._in_stock;
    BOOL isManagingStock = pInfo._managing_stock;
    int stockAvailable = pInfo._stock_quantity;
    BOOL allowBackorder = pInfo._backorders_allowed;
    
    if (variation) {
        inStock = variation._in_stock;
        stockAvailable = variation._stock_quantity;
        isManagingStock = variation._managing_stock;
        allowBackorder = variation._backordered;//new
    }else {
        if (pInfo._variations && [pInfo._variations count] > 0) {
            if ([[[Addons sharedManager] productDetailsConfig] show_quick_cart_section]) {
                return PRODUCT_QTY_INVALID;
            }
        }
//        if (isManagingStock && inStock && !allowBackorder) {
//            inStock = false;
//        }
    }
    if (isManagingStock) {
        if (allowBackorder) {
            //confirm
            return userDemand;
        }else {
            if (inStock) {
                if (stockAvailable >= userDemand) {
                    //confirm
                    return userDemand;
                } else {
                    //demand not completed show remaining stock
                    return stockAvailable;
                }
            } else {
                //out of stock
                return 0;
            }
        }
    }
    else {
        if (inStock == false) {
            return 0;
        }
        return userDemand;
    }
    
    if (variation) {
        if (inStock) {
            //confirm
            return userDemand;
        }else{
            //out of stock
            return 0;
        }
    }
    else {
        if (inStock) {
            return userDemand;
        }else{
            return 0;
        }
    }
}
+ (BOOL)isProductAvailableAsDemand:(int)demand mBundles:(NSMutableArray*)mBundles bundleProduct:(ProductInfo*)bundleProduct {
    int userDemand = demand;
    int previouslyAdded = 0;
    for (Cart* cInfo in [Cart getAll]) {
        if (cInfo.product._id == bundleProduct._id) {
            previouslyAdded += cInfo.count;
        }
        else if(cInfo.product._type == PRODUCT_TYPE_BUNDLE) {
            if (cInfo.product.mBundles != mBundles) {
                for (TM_Bundle* bundleProd in cInfo.product.mBundles) {
                    ProductInfo* bpInfo = bundleProd.product;
                    if (bpInfo && bpInfo._id == bundleProduct._id) {
                        previouslyAdded += (bundleProd.bundle_quantity * cInfo.count);
                    }
                }
            }
        }
    }
    userDemand += previouslyAdded;
    
    
    BOOL inStock = bundleProduct._in_stock;
    BOOL isManagingStock = bundleProduct._managing_stock;
    int stockAvailable = bundleProduct._stock_quantity;
    BOOL allowBackorder = bundleProduct._backorders_allowed;
    if (isManagingStock) {
        if (allowBackorder) {
            //confirm
            return true;
        } else {
            if (inStock) {
                if (stockAvailable >= userDemand) {
                    //confirm
                    return true;
                } else {
                    //demand not completed show remaining stock
                    return false;
                }
            } else {
                //out of stock
                return false;
            }
        }
    }
    else {
        if (inStock == false) {
            return false;
        }
        return true;
    }
    {
        if (inStock) {
            return true;
        }else{
            return false;
        }
    }
}
+ (BOOL)isBundleProductAvailable:(ProductInfo*)pInfo {
    if (pInfo._type == PRODUCT_TYPE_BUNDLE) {
        if (pInfo.mBundles) {
            for (TM_Bundle* bundle in pInfo.mBundles) {
                ProductInfo *bundleProduct = ((ProductInfo*)(bundle.product));
                if (bundleProduct) {
                    if (bundleProduct._in_stock == false) {
                        return false;
                    } else {
                        if ([Cart isProductAvailableAsDemand:bundle.bundle_quantity mBundles:pInfo.mBundles bundleProduct:bundleProduct] == false) {
                            return false;
                        }
                    }
                }
            }
        }
    }
    return true;
}
+ (int)getProductAvailibleStateBasic:(ProductInfo*)pInfo variationId:(int)variationId {
    Cart* cartItem = nil;
    int userDemand = 1;
    for (Cart* c in _allCartItems) {
        if(c.product_id == pInfo._id && c.selectedVariationId == variationId){
            cartItem = c;
        }
    }
    if (cartItem) {
        int userDemand = cartItem.count + 1;
        return [cartItem getProductAvailibleState:userDemand];
    } else {
        Variation* variation = [pInfo._variations getVariation:variationId variationIndex:-1];
        BOOL inStock = pInfo._in_stock;
        BOOL isManagingStock = pInfo._managing_stock;
        int stockAvailable = pInfo._stock_quantity;
        BOOL allowBackorder = pInfo._backorders_allowed;
        
        if (variation) {
            inStock = variation._in_stock;
            stockAvailable = variation._stock_quantity;
            isManagingStock = variation._managing_stock;
            allowBackorder = variation._backordered;//new
        }else {
            if (pInfo._variations && [pInfo._variations count] > 0) {
                if ([[[Addons sharedManager] productDetailsConfig] show_quick_cart_section]) {
                    return PRODUCT_QTY_INVALID;
                }
            }
            //            if (isManagingStock && inStock && !allowBackorder) {
            //                inStock = false;
            //            }
        }
        if (isManagingStock) {
            if (allowBackorder) {
                return PRODUCT_QTY_DEMAND;
            }else {
                if (inStock) {
                    if (stockAvailable >= userDemand) {
                        return PRODUCT_QTY_DEMAND;
                    } else {
                        return PRODUCT_QTY_STOCK;
                    }
                } else {
                    return PRODUCT_QTY_ZERO;
                }
            }
        }
        else {
            if (inStock == false) {
                return PRODUCT_QTY_ZERO;
            }
            return PRODUCT_QTY_DEMAND;
        }
        
        
        if (variation) {
            if (inStock) {
                return PRODUCT_QTY_DEMAND;
            }else{
                return PRODUCT_QTY_ZERO;
            }
        } else {
            if (inStock) {
                return PRODUCT_QTY_DEMAND;
            }else{
                return PRODUCT_QTY_ZERO;
            }
        }
    }
}
+ (int)getProductAvailibleState:(ProductInfo*)pInfo variationId:(int)variationId {
    int availState = [Cart getProductAvailibleStateBasic:pInfo variationId:variationId];
    if (availState != PRODUCT_QTY_ZERO) {
        BOOL isAllBundleItemsAvailable = [Cart isBundleProductAvailable:pInfo];
        if (isAllBundleItemsAvailable == false) {
            availState = PRODUCT_QTY_ZERO;
        }
    }
    return availState;
}
- (int)getProductAvailibleStateBasic:(int)userDemand {
    ProductInfo* pInfo = self.product;
    Variation* variation = [pInfo._variations getVariation:self.selectedVariationId variationIndex:-1];
    BOOL inStock = pInfo._in_stock;
    BOOL isManagingStock = pInfo._managing_stock;
    int stockAvailable = pInfo._stock_quantity;
    BOOL allowBackorder = pInfo._backorders_allowed;
    if (variation) {
        inStock = variation._in_stock;
        stockAvailable = variation._stock_quantity;
        isManagingStock = variation._managing_stock;
        allowBackorder = variation._backordered;//new
    }else {
        if (pInfo._variations && [pInfo._variations count] > 0) {
            if ([[[Addons sharedManager] productDetailsConfig] show_quick_cart_section]) {
                return PRODUCT_QTY_INVALID;
            }
        }
        //        if (isManagingStock && inStock && !allowBackorder) {
        //            inStock = false;
        //        }
    }
    
    if (isManagingStock) {
        if (allowBackorder) {
            //confirm
            return PRODUCT_QTY_DEMAND;
        }else {
            if (inStock) {
                if (stockAvailable >= userDemand) {
                    //confirm
                    return PRODUCT_QTY_DEMAND;
                } else {
                    //demand not completed show remaining stock
                    return PRODUCT_QTY_STOCK;
                }
            } else {
                //out of stock
                return PRODUCT_QTY_ZERO;
            }
        }
    }
    else {
        if (inStock == false) {
            return PRODUCT_QTY_ZERO;
        }
        return PRODUCT_QTY_DEMAND;
    }
    
    
    
    
    
    if (variation) {
        if (inStock) {
            //confirm
            return PRODUCT_QTY_DEMAND;
        }else{
            //out of stock
            return PRODUCT_QTY_ZERO;
        }
    } else {
        if (inStock) {
            //            if (stockAvailable > userDemand) {
            //confirm
            return PRODUCT_QTY_DEMAND;
            //            } else {
            //                //demand not completed show remaining stock
            //                return PRODUCT_QTY_STOCK;
            //            }
        }else{
            //out of stock
            return PRODUCT_QTY_ZERO;
        }
    }
}
- (BOOL)isBundleProductAvailableForDemand:(int)userDemand {
    if (self.product._type == PRODUCT_TYPE_BUNDLE) {
        if (self.product.mBundles) {
            for (TM_Bundle* bundle in self.product.mBundles) {
                ProductInfo *bundleProduct = ((ProductInfo*)(bundle.product));
                if (bundleProduct) {
                    if (bundleProduct._in_stock == false) {
                        return false;
                    } else {
//                        if (bundleProduct._id == 3745) {
//                            bundleProduct._stock_quantity = 40;
//                            NSLog(@"bundle product found");
//                        }
                        if ([Cart isProductAvailableAsDemand:bundle.bundle_quantity * userDemand mBundles:self.product.mBundles  bundleProduct:bundleProduct] == false) {
                            return false;
                        }
                    }
                }
            }
        }
    }
    return true;
}


- (int)getProductAvailibleState:(int)userDemand {
    int availState = [self getProductAvailibleStateBasic:userDemand];
    if (availState != PRODUCT_QTY_ZERO) {
        BOOL isAllBundleItemsAvailable = [self isBundleProductAvailableForDemand:userDemand];
        if (isAllBundleItemsAvailable == false) {
            availState = PRODUCT_QTY_ZERO;
        }
    }
    return availState;
}
+ (NSString*)getOrderNote {
    NSString* str = @"";
    if (![[Cart getOrderNoteCartItems] isEqualToString:@""]) {
        str = [NSString stringWithFormat:@"%@", [Cart getOrderNoteCartItems]];
    }
    if (![[Cart getOrderNoteCart] isEqualToString:@""]) {
        str = [NSString stringWithFormat:@"%@\n%@:\n%@", str, Localize(@"cart_note"), [Cart getOrderNoteCart]];
    }
    if (![[Cart notesStrForMixAndBundleProducts] isEqualToString:@""]) {
        str = [NSString stringWithFormat:@"%@\n%@:\n%@", str, Localize(@"cart_note"), [Cart notesStrForMixAndBundleProducts]];
    }
    if (![[Cart getOrderNoteOrder] isEqualToString:@""]) {
        str = [NSString stringWithFormat:@"%@\n%@:\n%@", str, Localize(@"order_note"), [Cart getOrderNoteOrder]];
    }
    
    if ([[Addons sharedManager] enable_special_order_note]) {
        str = [NSString stringWithFormat:@"%@\n[[[ %@ ]]]", str, Localize(@"special_order_note")];
    }

    if ([[Addons sharedManager] show_pickup_location] && [[TM_PickupLocation getAllPickupLocations] count] > 0) {
        TM_PickupLocation* pickupLoc = [[TM_PickupLocation getAllPickupLocations] objectAtIndex:0];
        str = [NSString stringWithFormat:@"%@\n[*** %@ %@ ***]", str, Localize(@"pickup_order_text"), [[pickupLoc getLocationStringAttributed] string]];
    }
    _orderNote = str;
    return _orderNote;
}
+ (NSString*)notesStrForMixAndBundleProducts {
    NSString* str = @"";
    for (Cart* c in [Cart getAll]) {
        if (c.mBundleProducts != nil && [c.mBundleProducts count] > 0 && 0/* this code is removed*/) {
            NSString* productString = [NSString stringWithFormat:@"\n[%d] %@", c.product_id, c.productName];
            productString = [productString stringByAppendingString:@"\nBundled Items:"];
            for (CartBundleItem* bItem in c.mBundleProducts) {
                if(bItem.quantity > 0){
                    NSString* bundleItemString = [NSString stringWithFormat:@"\n\t[%d] %@ x %d", bItem.productId, bItem.title, bItem.quantity];
                    productString = [productString stringByAppendingString:bundleItemString];
                }
            }
            productString = [productString stringByAppendingString:@"\n----------------------------"];
            str = [str stringByAppendingString:productString];
        }
        
        if (c.mMixMatchProducts != nil && [c.mMixMatchProducts count] > 0) {
            NSString* productString = [NSString stringWithFormat:@"\n[%d] %@", c.product_id, c.productName];
            productString = [productString stringByAppendingString:@"\nMatched Items:"];
            for (CartMatchedItem* mItem in c.mMixMatchProducts) {
                if(mItem.quantity > 0){
                    NSString* matchedItemString = [NSString stringWithFormat:@"\n\t[%d] %@ x %d", mItem.productId, mItem.title, mItem.quantity];
                    productString = [productString stringByAppendingString:matchedItemString];
                }
            }
            productString = [productString stringByAppendingString:@"\n----------------------------"];
            str = [str stringByAppendingString:productString];
        }
    }
    if (![str isEqualToString:@""]) {
        str = [NSString stringWithFormat:@"----------------------------%@", str];
    }
    return str;
}
+ (NSString*)getOrderNoteCartItems{
    NSString* str = @"";
    int i = 0;
    int countItems = (int)[[Cart getAll] count];
    for (Cart* cartObj in [Cart getAll]) {
        
        if (![cartObj.note isEqualToString:@""]) {
            NSString* propStr = @"";
            if(cartObj.selectedVariationIndex != -1) {
                Variation* variation = [cartObj.product._variations getVariation:cartObj.selectedVariationId variationIndex:cartObj.selectedVariationIndex];
                NSMutableString *properties = [NSMutableString string];
                int i = 0;
                if (variation) {
                    for (VariationAttribute* attribute in variation._attributes) {
                        if (i > 0) {
                            NSString* str = [NSString stringWithFormat:@",\n"];
                            [properties appendString:str];
                        }
                        NSString* str = [NSString stringWithFormat:@"%@ - %@",
                                         [Utility getStringIfFormatted:attribute.name],
                                         [Utility getStringIfFormatted:attribute.value]
                                         ];
                        [properties appendString:str];
                        i++;
                    }
                }
                if (![properties isEqualToString:@""]){
                    propStr = [NSString stringWithFormat:@"%@", properties];
                }
            }
            
            
            if (![propStr isEqualToString:@""]) {
                str = [NSString stringWithFormat:@"%@%@\n%@\n%@:%@\n", str, cartObj.productName, propStr, Localize(@"note"), cartObj.note];
            } else {
                str = [NSString stringWithFormat:@"%@%@\n%@:%@\n", str, cartObj.productName, Localize(@"note"), cartObj.note];
            }
            if (i != countItems-1) {
                str = [str stringByAppendingString:@"\n"];
            }
            
        }
        i++;
    }
    _orderNoteCartItems = str;
    return _orderNoteCartItems;
}
+ (void)setOrderNoteCart:(NSString*)noteStr {
    _orderNoteCart = noteStr;
}
+ (NSString*)getOrderNoteCart {
    return _orderNoteCart;
}
+ (void)setOrderNoteOrder:(NSString*)noteStr {
    _orderNoteOrder = noteStr;
}
+ (NSString*)getOrderNoteOrder{
    return _orderNoteOrder;
}
+ (void)resetOrderNotes{
    _orderNoteOrder = @"";
    _orderNoteCart = @"";
    _orderNote = @"";
    _orderNoteCartItems = @"";
}
+ (float)getTotalWeight:(float)shippingMinWeight shippingDefaultWeight:(float)shippingDefaultWeight {
    float totalWeight = shippingMinWeight; // 0.0f;
    for (Cart* cart in [Cart getAll]) {
        if(cart.product){
            float cartWeight = [cart.product getWeightWithVariationID:cart.selectedVariationId];
            float weight = cartWeight > 0 ? cartWeight : shippingDefaultWeight;
            totalWeight += weight;
        }
    }
    return totalWeight;
}

-(float) getDiscountedPrice {
    return [self getItemTotalPrice] - _discountTotal;
}

- (float) getItemTotalPrice {
    return [self getItemPrice] * _count;
}

- (float) getItemPrice {
    return [self getItemPriceWithoutExtra] + [self getPriceExtra];
}

- (float)getPriceExtra {
    float extra = 0.0f;
    for (VariationAttribute* attribute in _selected_attributes) {
        extra += attribute.extraPrice;
    }
    return extra;
}

- (float) getItemPriceWithoutExtra {
    //    if(this.matchedItems != null && this.matchedItems.size() != 0) {
    //        float subTotalPrice = 0;
    //        for(CartMatchedItem matchedItem : matchedItems) {
    //            subTotalPrice += matchedItem.getBasePrice() * matchedItem.getQuantity();
    //        }
    //        return subTotalPrice;
    //    }
    if (_product != nil && _product._isFullRetrieved) {
        return [_product getNewPrice:_selectedVariationId];
    } else {
        return _productPrice;
    }
}

+ (void) setPointsPriceDiscount:(float) pointsPriceDiscount {
    if ([[Addons sharedManager] enable_custom_points]) {
        mPointsPriceDiscount = [Cart getTotalPayment] > pointsPriceDiscount
        ? pointsPriceDiscount
        : [Cart getTotalPayment];
    }
}

+ (float) getPointsPriceDiscount {
    return mPointsPriceDiscount;
}

+ (void) removePointsPriceDiscount {
    mPointsPriceDiscount = 0.0f;
}
+ (NSMutableDictionary*)createBunches {
    NSMutableDictionary* bunches = [[NSMutableDictionary alloc] init];
    NSMutableArray* cartAllItems = [Cart getAll];
    NSMutableArray* tempDateTimeCartPairs = [[NSMutableArray alloc] init];
    for (Cart* c in cartAllItems) {
        NSMutableDictionary* tempDict = [[NSMutableDictionary alloc] init];
        [tempDict setObject:c forKey:@"cartObj"];
        [tempDict setObject:[NSString stringWithFormat:@"%@, %@", c.prddDate, c.prddTime.slot_title] forKey:@"datetime"];
        [tempDateTimeCartPairs addObject:tempDict];
    }
    NSArray* array = [[NSArray alloc] initWithArray:tempDateTimeCartPairs];
    NSMutableArray *resultArray = [NSMutableArray new];
    NSArray *groups = [array valueForKeyPath:@"@distinctUnionOfObjects.datetime"];
    for (NSString *datetime in groups)
    {
        NSMutableDictionary *entry = [NSMutableDictionary new];
        [entry setObject:datetime forKey:@"datetime"];
        NSArray *groupNames = [array filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"datetime = %@", datetime]];
        for (int i = 0; i < groupNames.count; i++) {
            Cart* c = (Cart*)([[groupNames objectAtIndex:i] objectForKey:@"cartObj"]);
            
            [entry setObject:c.prddTime.slot_title forKey:@"time_slot"];
            [entry setObject:[NSNumber numberWithFloat:c.prddTime.slot_price] forKey:@"time_slot_cost"];
            [entry setObject:c.prddDate forKey:@"date_slot"];
            [entry setObject:c.prddDay forKey:@"prdd_day_obj"];
            [entry setObject:c.prddTime forKey:@"prdd_time_obj"];
            
            NSMutableArray* pids;
            if ([entry objectForKey:@"pids"]) {
                pids = [[NSMutableArray alloc] initWithArray:[entry objectForKey:@"pids"]];
            } else {
                pids = [[NSMutableArray alloc] init];
            }
            [pids addObject:[NSNumber numberWithInt:c.product_id]];
            [entry setObject:pids forKey:@"pids"];
            
            NSMutableArray* vids;
            if ([entry objectForKey:@"vids"]) {
                vids = [[NSMutableArray alloc] initWithArray:[entry objectForKey:@"vids"]];
            } else {
                vids = [[NSMutableArray alloc] init];
            }
            [vids addObject:[NSNumber numberWithInt:c.selectedVariationId]];
            [entry setObject:vids forKey:@"vids"];
            
            
            NSMutableArray* pTitles;
            if ([entry objectForKey:@"pTitles"]) {
                pTitles = [[NSMutableArray alloc] initWithArray:[entry objectForKey:@"pTitles"]];
            } else {
                pTitles = [[NSMutableArray alloc] init];
            }
            NSString* productTitle = [NSString stringWithFormat:@"%@", c.product._titleForOuterView];
            [pTitles addObject:productTitle];
            [entry setObject:pTitles forKey:@"pTitles"];
            
        }
        [resultArray addObject:entry];
    }
    
    int i = 0;
    for (NSMutableDictionary *entry in resultArray) {
        [bunches setObject:entry forKey:[NSNumber numberWithInt:i]];
        i++;
    }
    
    return bunches;
}

+ (Cart*)addProduct:(ProductInfo*)product
        variationId:(int)variationId
     variationIndex:(int)variationIndex
selectedVariationAttributes:(NSMutableArray*)selectedVariationAttributes
        bundleItems:(NSMutableArray*)bundleItems
       matchedItems:(NSMutableArray*)matchedItems
            prddDay:(TM_PRDD_Day*)prddDay
           prddTime:(TM_PRDD_Time*)prddTime
           prddDate:(NSString*)prddDate
{
    NSString* product_prddDate = prddDate;
    if (product_prddDate == nil) {
        product_prddDate = @"";
    }
    NSString* product_prddTime = @"";
    if (prddTime) {
        product_prddTime = prddTime.slot_title;
    }
#if ENABLE_PARSE_ANALYTICS
    [[ParseHelper sharedManager] registerParseCartProduct:product._id categoryId:product._parent_id increment:1];
#endif
    if ([Coupon getAllCoupons] == NULL || [[Coupon getAllCoupons] count] == 0) {
        [[[DataManager sharedManager] tmDataDoctor] fetchCouponsData:nil];
    }
    for (Cart* c in _allCartItems) {
        NSString* cart_prddDate = c.prddDate;
        if (cart_prddDate == nil) {
            cart_prddDate = @"";
        }
        NSString* cart_prddTime = @"";
        if (c.prddTime) {
            cart_prddTime = c.prddTime.slot_title;
        }
        if(
           c.product_id == product._id &&
           c.selectedVariationId == variationId &&
           c.selectedVariationIndex == variationIndex &&
           [Cart compareSelectedVariationAttributes:selectedVariationAttributes array2:c.selected_attributes] &&
           [cart_prddDate isEqualToString:product_prddDate] &&
           [cart_prddTime isEqualToString:product_prddTime]
           ) {
            
            if (c.product._type == PRODUCT_TYPE_BUNDLE) {
                c.mBundleProducts = bundleItems;
                if (c.mBundleProducts == nil || [c.mBundleProducts count] == 0) {
                    for (TM_Bundle* bundle in product.mBundles) {
                        CartBundleItem *cartBundle = [[CartBundleItem alloc] init];
                        ProductInfo *bundleProduct = ((ProductInfo*)(bundle.product));
                        cartBundle.productId = bundleProduct._id;
                        cartBundle.title = bundleProduct._title;
                        cartBundle.price = 0;
                        for (ProductImage* pimg in bundleProduct._images) {
                            cartBundle.imgUrl = pimg._src;
                            break;
                        }
                        cartBundle.quantity = bundle.bundle_quantity;
                        cartBundle.product = bundleProduct;
                        [c.mBundleProducts addObject:cartBundle];
                    }
                }
            }
            
            if (c.product._type == PRODUCT_TYPE_MIXNMATCH) {
                c.mMixMatchProducts = matchedItems;
            }
            
            int stepValue = 1;
            int minValue = 1;
            if (product.quantityRule && product.quantityRule.orderrideRule) {
                stepValue = product.quantityRule.stepValue;
                minValue = product.quantityRule.minQuantity;
            }
            if (c.count == 0) {
                c.count = minValue;
            } else {
                c.count += stepValue;
            }
            
            [Cart clearCoupons];
            _notificationCount++;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATE_NOTIFICATION_COUNT" object:nil];
#if ENABLE_PARSE_ANALYTICS
            [[ParseHelper sharedManager] registerParseCustomerCart];
#endif
            [[AppDelegate getInstance] logCartEvent:c];
#if ENABLE_FIREBASE_TAG_MANAGER
            [[AnalyticsHelper sharedInstance] registerAddToCartProductEventGtm:c];
#endif
            c.mBundles_ProductCopy = c.product.mBundles;
            c.productType = c.product._type;
            return c;
        }
    }
    Cart* c = [[Cart alloc] initWithParameters:product._id product:product variationId:variationId variationIndex:variationIndex];
    c.prddDate = prddDate;
    c.prddDay = prddDay;
    c.prddTime = prddTime;
    if (c.product._type == PRODUCT_TYPE_BUNDLE) {
        c.mBundleProducts = bundleItems;
        if (c.mBundleProducts == nil || [c.mBundleProducts count] == 0) {
            for (TM_Bundle* bundle in product.mBundles) {
                CartBundleItem *cartBundle = [[CartBundleItem alloc] init];
                ProductInfo *bundleProduct = ((ProductInfo*)(bundle.product));
                cartBundle.productId = bundleProduct._id;
                cartBundle.title = bundleProduct._title;
                cartBundle.price = 0;
                for (ProductImage* pimg in bundleProduct._images) {
                    cartBundle.imgUrl = pimg._src;
                    break;
                }
                cartBundle.quantity = bundle.bundle_quantity;
                cartBundle.product = bundleProduct;
                [c.mBundleProducts addObject:cartBundle];
            }
        }
    }
    
    if (c.product._type == PRODUCT_TYPE_MIXNMATCH) {
        c.mMixMatchProducts = matchedItems;
    }
    c.selected_attributes = [[NSMutableArray alloc] init];
    for (VariationAttribute* vAttr in selectedVariationAttributes) {
        VariationAttribute* vAttrNew = [[VariationAttribute alloc] init];
        vAttrNew.name = vAttr.name;
        vAttrNew.slug = vAttr.slug;
        vAttrNew.value = vAttr.value;
        [c.selected_attributes addObject:vAttrNew];
    }
    if (![c.selected_attributes count] > 0) {
        c.selected_attributes = nil;
    }
    
    
    [Cart clearCoupons];
    _notificationCount++;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATE_NOTIFICATION_COUNT" object:nil];
#if ENABLE_PARSE_ANALYTICS
    [[ParseHelper sharedManager] registerParseCustomerCart];
#endif
    [[AppDelegate getInstance] logCartEvent:c];
#if ENABLE_FIREBASE_TAG_MANAGER
    [[AnalyticsHelper sharedInstance] registerAddToCartProductEventGtm:c];
#endif
    c.productType = c.product._type;
    c.mBundles_ProductCopy = c.product.mBundles;
    return c;
}
+ (Cart*)addProduct:(ProductInfo*)product
        variationId:(int)variationId
     variationIndex:(int)variationIndex
selectedVariationAttributes:(NSMutableArray*)selectedVariationAttributes {
#if ENABLE_PARSE_ANALYTICS
    [[ParseHelper sharedManager] registerParseCartProduct:product._id categoryId:product._parent_id increment:1];
#endif
    if ([Coupon getAllCoupons] == NULL || [[Coupon getAllCoupons] count] == 0) {
        [[[DataManager sharedManager] tmDataDoctor] fetchCouponsData:nil];
    }
    for (Cart* c in _allCartItems) {
        if(c.product_id == product._id && c.selectedVariationId == variationId && c.selectedVariationIndex == variationIndex && [Cart compareSelectedVariationAttributes:selectedVariationAttributes array2:c.selected_attributes]) {
            int stepValue = 1;
            int minValue = 1;
            if (product.quantityRule && product.quantityRule.orderrideRule) {
                stepValue = product.quantityRule.stepValue;
                minValue = product.quantityRule.minQuantity;
            }
            if (c.count == 0) {
                c.count = minValue;
            } else {
                c.count += stepValue;
            }
            
            [Cart clearCoupons];
            _notificationCount++;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATE_NOTIFICATION_COUNT" object:nil];
#if ENABLE_PARSE_ANALYTICS
            [[ParseHelper sharedManager] registerParseCustomerCart];
#endif
            [[AppDelegate getInstance] logCartEvent:c];
#if ENABLE_FIREBASE_TAG_MANAGER
            [[AnalyticsHelper sharedInstance] registerAddToCartProductEventGtm:c];
#endif
            return c;
        }
    }
    Cart* c = [[Cart alloc] initWithParameters:product._id product:product variationId:variationId variationIndex:variationIndex];
    c.selected_attributes = [[NSMutableArray alloc] init];
    for (VariationAttribute* vAttr in selectedVariationAttributes) {
        VariationAttribute* vAttrNew = [[VariationAttribute alloc] init];
        vAttrNew.name = vAttr.name;
        vAttrNew.slug = vAttr.slug;
        vAttrNew.value = vAttr.value;
        [c.selected_attributes addObject:vAttrNew];
    }
    if (![c.selected_attributes count] > 0) {
        c.selected_attributes = nil;
    }
    
    
    [Cart clearCoupons];
    _notificationCount++;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATE_NOTIFICATION_COUNT" object:nil];
#if ENABLE_PARSE_ANALYTICS
    [[ParseHelper sharedManager] registerParseCustomerCart];
#endif
    [[AppDelegate getInstance] logCartEvent:c];
#if ENABLE_FIREBASE_TAG_MANAGER
    [[AnalyticsHelper sharedInstance] registerAddToCartProductEventGtm:c];
#endif
    return c;
}
@end
