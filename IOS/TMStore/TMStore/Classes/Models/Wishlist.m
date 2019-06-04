//
//  Wishlist.m
//  eCommerceApp
//
//  Created by Rishabh Jain on 02/10/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import "Wishlist.h"
#import "AppUser.h"
#import "Attribute.h"
#import "ParseHelper.h"
#import "Variables.h"
#import "AppDelegate.h"
#import "CWishList.h"
#import "AnalyticsHelper.h"

static NSMutableArray* _allWishlistItems = NULL;//ARRAY OF Wishlist
static int _notificationCount = 0;
@implementation Wishlist

+ (void)setWishlistArray:(NSMutableArray*)array{
    _allWishlistItems = array;
    _notificationCount = 0;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATE_NOTIFICATION_COUNT" object:nil];
}
- (id)initWithParameters:(int)product_id product:(ProductInfo *)product variationId:(int)variationId variationIndex:(int)variationIndex {
    self = [super init];
    if (self) {
        self.product_id = product_id;
        self.productName = product._title;
        self.product = product;
        self.productImgUrl = ((ProductImage*)[product._images objectAtIndex:0])._src;
        self.productPrice = [product getNewPrice:variationId];
        self.count = 1;
        if (variationId != -1) {
            self.selectedVariationId = variationId;
        }else{
            self.selectedVariationId = -1;
        }
        if (variationId != -1) {
            self.selectedVariationIndex = variationIndex;
        }else{
            self.selectedVariationIndex = -1;
        }
        if (_allWishlistItems == NULL)
        {
            _allWishlistItems = [[AppUser sharedManager] _wishlistArray];
        }
        
        [_allWishlistItems addObject:self];
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
        
        self.product = [ProductInfo getProductWithId:self.product_id];
        if (self.product._isSmallRetrived == false) {
            self.product._title = self.productName;
            self.product._titleForOuterView = self.productName;
            self.product._price = self.productPrice;
            ProductImage* img = [[ProductImage alloc] init];
            img._src = self.productImgUrl;
            [self.product._images addObject:img];
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
}

+ (void)refresh{
    [self prepareWishlist];
}
+ (float)getTotalPayment{
    float total = 0.0f;
    for (Wishlist* c in _allWishlistItems) {
        ProductInfo* p = c.product;
        float realSellingPrice = p._sale_price > 0 ? p._sale_price: p._price;
        total += realSellingPrice * c.count;
    }
    return total;
}
+ (float)getTotalSavings{
    float total = 0.0f;
    for (Wishlist* c in _allWishlistItems) {
        ProductInfo* p = c.product;
        float realSellingPrice = p._sale_price > 0 ? p._sale_price: p._price;
        if (p._regular_price > 0 && p._regular_price > realSellingPrice) {
            total += (p._regular_price - realSellingPrice) * c.count;
        }
    }
    return total;
}
+ (NSMutableArray*)getAll {//ARRAY OF Wishlist
    return _allWishlistItems;
}
+ (int)getItemCount {
    int total = 0;
    for (Wishlist* c in _allWishlistItems) {
        total += c.count;
    }
    return total;
    //    if(_allWishlistItems == nil){
    //        return 0;
    //    }
    //    return (int)[_allWishlistItems count];
}

+ (void)prepareWishlist {
    for (Wishlist* c in _allWishlistItems) {
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

/*
+ (void)addProduct:(ProductInfo*)product{
#if ENABLE_PARSE_ANALYTICS
    [[ParseHelper sharedManager] registerParseWishlistProduct:product._id categoryId:product._parent_id increment:1];
#endif
    int variationId = -1;
    NSMutableArray* selectedVariationAttibutes = [[NSMutableArray alloc] init];
    for (Attribute* attribute in product._attributes) {
        [selectedVariationAttibutes addObject:[attribute getVariationAttribute:0]];
    }
    if ([selectedVariationAttibutes count] > 0) {
        Variation* selectedVariation = [product._variations getVariationFromAttibutes:selectedVariationAttibutes];
        if (selectedVariation) {
            variationId = selectedVariation._id;
        }
    }
    for (Wishlist* c in _allWishlistItems) {
        if(c.product_id == product._id && c.selectedVariationId == variationId){
//            c.count++;
            //            [c save];
//            _notificationCount++;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATE_NOTIFICATION_COUNT" object:nil];
            return;
        }
    }
    Wishlist* c = [[Wishlist alloc] initWithParameters:product._id product:product variationId:variationId];
    _notificationCount++;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATE_NOTIFICATION_COUNT" object:nil];
    //        [c save];
}
+ (void)removeProduct:(ProductInfo*)product {
#if ENABLE_PARSE_ANALYTICS
    [[ParseHelper sharedManager] registerParseWishlistProduct:product._id categoryId:product._parent_id increment:-1];
#endif
    int variationId = -1;
    NSMutableArray* selectedVariationAttibutes = [[NSMutableArray alloc] init];
    for (Attribute* attribute in product._attributes) {
        [selectedVariationAttibutes addObject:[attribute getVariationAttribute:0]];
    }
    if ([selectedVariationAttibutes count] > 0) {
        Variation* selectedVariation = [product._variations getVariationFromAttibutes:selectedVariationAttibutes];
        if (selectedVariation) {
            variationId = selectedVariation._id;
        }
    }
    
    
    for (Wishlist* c in _allWishlistItems) {
        if(c.product_id == product._id && c.selectedVariationId == variationId){
            [self removeSafely:c];
            //            [c save];
            _notificationCount--;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATE_NOTIFICATION_COUNT" object:nil];
            return;
        }
    }
    _notificationCount = 0;
    [_allWishlistItems removeAllObjects];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATE_NOTIFICATION_COUNT" object:nil];
    RLOG(@"-- Can't remove, requested product not found in Cart --");
}
+ (void)addProduct:(ProductInfo*)product variationId:(int)variationId {
#if ENABLE_PARSE_ANALYTICS
    [[ParseHelper sharedManager] registerParseWishlistProduct:product._id categoryId:product._parent_id increment:1];
#endif
    for (Wishlist* c in _allWishlistItems) {
        if(c.product_id == product._id && c.selectedVariationId == variationId){
//            c.count++;
            //            [c save];
//            _notificationCount++;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATE_NOTIFICATION_COUNT" object:nil];
            return;
        }
    }
    Wishlist* c = [[Wishlist alloc] initWithParameters:product._id product:product variationId:variationId];
    _notificationCount++;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATE_NOTIFICATION_COUNT" object:nil];
    //        [c save];
}
+ (void)removeProduct:(ProductInfo*)product variationId:(int)variationId {
#if ENABLE_PARSE_ANALYTICS
    [[ParseHelper sharedManager] registerParseWishlistProduct:product._id categoryId:product._parent_id increment:-1];
#endif
    for (Wishlist* c in _allWishlistItems) {
        if(c.product_id == product._id && c.selectedVariationId == variationId){
            [self removeSafely:c];
            //            [c save];
            _notificationCount--;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATE_NOTIFICATION_COUNT" object:nil];
            return;
        }
    }
    [_allWishlistItems removeAllObjects];
    _notificationCount = 0;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATE_NOTIFICATION_COUNT" object:nil];
    RLOG(@"-- Can't remove, requested product not found in Cart --");
}
+ (BOOL)hasItem:(ProductInfo*)product variationId:(int)variationId {
    for(Wishlist* c in _allWishlistItems)
    {
        if(c.product_id == product._id && c.selectedVariationId == variationId)
        {
            return true;
        }
    }
    return false;
}
+ (BOOL)hasItem:(ProductInfo*)product{
    for(Wishlist* c in _allWishlistItems)
    {
        if(c.product_id == product._id){
            return true;
        }
    }
    return false;
}
*/

+ (void)addProduct:(ProductInfo*)product {
#if ENABLE_PARSE_ANALYTICS
    [[ParseHelper sharedManager] registerParseWishlistProduct:product._id categoryId:product._parent_id increment:1];
#endif
    int variationId = -1;
    for (Wishlist* c in _allWishlistItems) {
        if(c.product_id == product._id){
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATE_NOTIFICATION_COUNT" object:nil];
#if ENABLE_PARSE_ANALYTICS
            [[ParseHelper sharedManager] registerParseCustomerWishlist];
#endif
            [[AppDelegate getInstance] logWishlistEvent:c];
#if ENABLE_FIREBASE_TAG_MANAGER
            [[AnalyticsHelper sharedInstance] registerAddToWishlistProductEventGtm:c];
#endif
            return;
        }
    }
    Wishlist* c = [[Wishlist alloc] initWithParameters:product._id product:product variationId:variationId variationIndex:-1];
    _notificationCount++;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATE_NOTIFICATION_COUNT" object:nil];
#if ENABLE_PARSE_ANALYTICS
    [[ParseHelper sharedManager] registerParseCustomerWishlist];
#endif
    [[AppDelegate getInstance] logWishlistEvent:c];
#if ENABLE_FIREBASE_TAG_MANAGER
    [[AnalyticsHelper sharedInstance] registerAddToWishlistProductEventGtm:c];
#endif

    // Add Product to custom WishList
    if([[Addons sharedManager] enable_custom_wishlist]) {
        if([AppUser isSignedIn] && IsNaN([CWishList getId])) {
            NSDictionary* params = @{@"type": base64_str(@"add"),
                                     @"user_id": base64_int([[AppUser sharedManager] _id]),
                                     @"email_id": base64_str([[AppUser sharedManager] _email]),
                                     @"prod_id": base64_int(product._id),
                                     @"wishlist_id": base64_str([CWishList getId]),
                                     @"quantity": base64_str(@"1")};

            [[DataManager getDataDoctor] syncWishListProduct:params
                                                     success:^(id data) {
                                                         RLOG(@"Product successfully added custom WishList.");
                                                     }
                                                     failure:^(NSString *error) {
                                                         RLOG(@"Failed to add product into custom WishList.");
                                                     }];

        }
    }

}
+ (void)addProductWithoutSync:(ProductInfo*)product {
#if ENABLE_PARSE_ANALYTICS
    [[ParseHelper sharedManager] registerParseWishlistProduct:product._id categoryId:product._parent_id increment:1];
#endif
    int variationId = -1;
    for (Wishlist* c in _allWishlistItems) {
        if(c.product_id == product._id){
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATE_NOTIFICATION_COUNT" object:nil];
#if ENABLE_PARSE_ANALYTICS
            [[ParseHelper sharedManager] registerParseCustomerWishlist];
#endif
            [[AppDelegate getInstance] logWishlistEvent:c];
#if ENABLE_FIREBASE_TAG_MANAGER
            [[AnalyticsHelper sharedInstance] registerAddToWishlistProductEventGtm:c];
#endif
            return;
        }
    }
    Wishlist* c = [[Wishlist alloc] initWithParameters:product._id product:product variationId:variationId variationIndex:-1];
    _notificationCount++;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATE_NOTIFICATION_COUNT" object:nil];
#if ENABLE_PARSE_ANALYTICS
    [[ParseHelper sharedManager] registerParseCustomerWishlist];
#endif
    [[AppDelegate getInstance] logWishlistEvent:c];
#if ENABLE_FIREBASE_TAG_MANAGER
    [[AnalyticsHelper sharedInstance] registerAddToWishlistProductEventGtm:c];
#endif
    // Add Product to custom WishList
//    if([[Addons sharedManager] enable_custom_wishlist]) {
//        if([AppUser isSignedIn] && IsNaN([CWishList getId])) {
//            NSDictionary* params = @{@"type": base64_str(@"add"),
//                                     @"user_id": base64_int([[AppUser sharedManager] _id]),
//                                     @"email_id": base64_str([[AppUser sharedManager] _email]),
//                                     @"prod_id": base64_int(product._id),
//                                     @"wishlist_id": base64_str([CWishList getId]),
//                                     @"quantity": base64_str(@"1")};
//            
//            [[DataManager getDataDoctor] syncWishListProduct:params
//                                                     success:^(id data) {
//                                                         RLOG(@"Product successfully added custom WishList.");
//                                                     }
//                                                     failure:^(NSString *error) {
//                                                         RLOG(@"Failed to add product into custom WishList.");
//                                                     }];
//            
//        }
//    }
    
}


+ (void)removeProduct:(ProductInfo*)product productId:(int)productId variationId:(int)variationId {
#if ENABLE_PARSE_ANALYTICS
    [[ParseHelper sharedManager] registerParseWishlistProduct:product._id categoryId:product._parent_id increment:-1];
#endif
    for (Wishlist* c in _allWishlistItems) {
        if(c.product_id == productId){
#if ENABLE_FIREBASE_TAG_MANAGER
            [[AnalyticsHelper sharedInstance] registerRemoveToWishlistProductEventGtm:c];
#endif
            [self removeSafely:c];
            _notificationCount--;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATE_NOTIFICATION_COUNT" object:nil];
#if ENABLE_PARSE_ANALYTICS
            [[ParseHelper sharedManager] registerParseCustomerWishlist];
#endif
            return;
        }
    }

    _notificationCount--;
    _notificationCount = 0;
    [_allWishlistItems removeAllObjects];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATE_NOTIFICATION_COUNT" object:nil];
    RLOG(@"-- Can't remove, requested product not found in Cart --");
#if ENABLE_PARSE_ANALYTICS
    [[ParseHelper sharedManager] registerParseCustomerWishlist];
#endif
}
+ (BOOL)hasItem:(ProductInfo*)product{
    for(Wishlist* c in _allWishlistItems)
    {
        if(c.product_id == product._id){
            return true;
        }
    }
    return false;
}
+ (void)addProduct:(ProductInfo*)product variationId:(int)variationId {
    [Wishlist addProduct:product];
}
//+ (void)removeProduct:(ProductInfo*)product variationId:(int)variationId {
//    [Wishlist removeProduct:product];
//}
+ (BOOL)hasItem:(ProductInfo*)product variationId:(int)variationId {
    return [Wishlist hasItem:product];
}

+ (void)removeSafely:(Wishlist*)wishlist {
    // Remove product from custom WishList
    if([[Addons sharedManager] enable_custom_wishlist]) {
        if([AppUser isSignedIn] && IsNaN([CWishList getId])) {
            NSDictionary* params = @{@"type": base64_str(@"delete"),
                                     @"user_id": base64_int([[AppUser sharedManager] _id]),
                                     @"email_id": base64_str([[AppUser sharedManager] _email]),
                                     @"prod_id": base64_int(wishlist.product._id),
                                     @"wishlist_id": base64_str([CWishList getId])};

            [[DataManager getDataDoctor] syncWishListProduct:params
                                                     success:^(id data) {
                                                         RLOG(@"Product successfully removed from custom WishList.");
                                                     }
                                                     failure:^(NSString *error) {
                                                         RLOG(@"Failed to remove product from custom WishList.");
                                                     }];
            
        }
    }

//    if(!validateFirstName()) {
//        return;
//    }
//
//    if(!validateLastName()) {
//        return;
//    }
//
//    if(!validateEmail()) {
//        return;
//    }
//
//    if(!validateMessage()) {
//        return;
//    }
//
//    if(AppUser.getInstance().user_type == AppUser.USER_TYPE.ANONYMOUS_USER) {
//        Helper.toast(L.string.not_signed_in);
//        return;
//    }
    RLOG(@"------- removeSafely: [%@] -------", wishlist.product._title);
    [_allWishlistItems removeObject:wishlist];
}
+ (void)printAll {
    for (Wishlist* c in _allWishlistItems) {
        RLOG(@"------- Wishlist:[Id:%d][Count:%d] --------", c.product_id, c.count);
    }
}
+ (int)getNotificationItemCount {
    return (int)[[Wishlist getAll] count];

    if (_notificationCount < 0) {
        _notificationCount = 0;
    }
    return _notificationCount;//(int)[_allWishlistItems count];
}
+ (void)resetNotificationItemCount {
    _notificationCount = 0;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATE_NOTIFICATION_COUNT" object:nil];
}
- (float)getWishlistTotal {
    ProductInfo* p = self.product;
    Variation* variation = [p._variations getVariation:self.selectedVariationId variationIndex:self.selectedVariationIndex];
    BOOL isDiscounted;
    float newPrice;
    float oldPrice;
    if (variation) {
        isDiscounted = [p isProductDiscounted:variation._id];
        newPrice = [p getNewPrice:variation._id];
        oldPrice = [p getOldPrice:variation._id];
    } else {
        isDiscounted = [p isProductDiscounted:-1];
        newPrice = [p getNewPrice:-1];
        oldPrice = [p getOldPrice:-1];
    }
    return (newPrice * self.count);
}
@end
