//
//  ProductInfo.m
//  eCommerceApp
//
//  Created by Rishabh Jain on 01/10/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import "ProductInfo.h"
#import "ProductImage.h"
#import "Variables.h"
#import "Variation.h"
#import "Utility.h"
#import "Addons.h"
static NSMutableArray *_allProducts = nil;//ARRAY OF ProductInfo Objects

static NSMutableDictionary *_productsWithKey = nil;

static NSMutableArray* _newArrivalItems = nil;
static NSMutableArray* _bestSellingItems = nil;
static NSMutableArray* _trendingItems = nil;
static NSMutableArray* _tempFilteredItems = nil;


@interface ProductInfo ()
#pragma mark SELLER-ZONE
@property NSMutableArray* szCategoryIdsTemp;
@property NSMutableArray* szCategoryNamesTemp;
@property NSMutableArray* szCategoryIds;
@property NSMutableArray* szCategoryNames;

@property NSMutableArray* szAttributesTemp;
@property NSMutableArray* szAttributes;

#pragma mark OTHER
@end

@implementation ProductInfo
- (id)init:(BOOL)isAddToList {
    self = [super init];
    if (self) {
        self._title = @"";
        self._id = -1;
        self._downloadable = NO;
        self._virtual = NO;
        self._permalink = @"";
        self._sku = @"";
        self._price = 0;
        self._regular_price = 0;
        self._sale_price = 0;
        self.price_clone = 0;
        self.sale_price_clone = 0;
        self.regular_price_clone = 0;
        self._price_html = @"";
        self._taxable = NO;
        self._in_stock = NO;
        self._sold_individually = NO;
        self._purchaseable = NO;
        self._featured = NO;
        self._visible = NO;
        self._on_sale = NO;
        self._product_url = @"";
        self._shipping_required = NO;
        self._shipping_taxable = NO;
        self._shipping_class = @"";
        self._description = @"";
        self._short_description = @"";
        self._reviews_allowed = NO;
        self._average_rating = 0;
        self._rating_count = 0;
        self._related_ids = [[NSMutableArray alloc] init];//ARRAY OF int
        self._related_products = [[NSMutableArray alloc] init];//ARRAY OF pinfo
        self._upsell_ids = [[NSMutableArray alloc] init];//ARRAY OF int
        self._cross_sell_ids = [[NSMutableArray alloc] init];//ARRAY OF int
        self._parent_id = 0;
        self._categories = [[NSMutableArray alloc] init];//ARRAY OF CategoryInfo
        self._tags = [[NSMutableArray alloc] init];//ARRAY OF int
        self._images = [[NSMutableArray alloc] init];//ARRAY OF ProductImage
        self._featured_src = @"";
        self._attributes = [[NSMutableArray alloc] init];//ARRAY OF Attribute
        self._extraAttributes = [[NSMutableArray alloc] init];//ARRAY of Extra Attributes
        self._downloads = [[NSMutableArray alloc] init];//ARRAY OF NSString
        self._download_limit = 0;
        self._download_expiry = 0;
        self._download_type = @"";
        self._purchase_note = @"";
        self._total_sales = 0;
        self._variations = [[VariationSet alloc] init];//VariationSet OF Variation
        self._dimensions = [[Dimension alloc] init];
        
        self._type = PRODUCT_TYPE_SIMPLE;
        self._discount = 0;
        self._created_at = NULL;
        self._updated_at = NULL;
        self._isFullRetrieved = false;
        self._isSmallRetrived = false;
        self._isReviewsRetrieved = false;
        self._productReviews = [[NSMutableArray alloc] init];//ARRAY OF ProductReview
        self.pollLikeCount = 0;
        self.pollDislikeCount = 0;
        self.updatedCardSizeL = CGSizeZero;
        self.updatedCardSizeP = CGSizeZero;
        
        self._priceMin = 0.0f;
        self._priceMax = 0.0f;
        self.rewardPoints = -1;
        self._isExtraPriceRetrieved = false;
        self.variation_simple_fields = nil;
        self._weight = 0.0f;
        
        self.brandName = @"";
        self.brandUrl = @"";
        self.priceLabel = @"";
        self.mMixMatch = nil;
        self.mBundles = [[NSMutableArray alloc] init];
        self.descAttribStr = nil;
        self.shortDescAttribStr = nil;
        self._isExtraDataRetrieved = false;
        
        self.prdd = [[TM_PRDD alloc] init];
        self.prddDataFetched = false;
        
        self.sellerInfo = nil;
        self.sellerDataFetched = false;
        
        self.isRestricted = false;
        self.isRestrictionChecked = false;
        
        self.button_text = @"";
    }
    if (_allProducts == nil) {
        _allProducts = [[NSMutableArray alloc] init];
    }
    if (isAddToList) {
        [_allProducts addObject:self];
    }
    return self;
}
- (id)init {
    return [self init:true];
}
- (void)clonePrice{
    self.price_clone = self._price;
    self.regular_price_clone = self._regular_price;
    self.sale_price_clone = self._sale_price;

}
+ (NSMutableArray *)getAll{
    if (_allProducts == nil) {
        _allProducts = [[NSMutableArray alloc] init];
    }
    return _allProducts;
	}
	
+ (NSMutableArray *)getFilteredItems {
    if (_tempFilteredItems == nil) {
        _tempFilteredItems = [[NSMutableArray alloc] init];
    }
    return _tempFilteredItems;
}

+ (void)setFilteredItems:(NSMutableArray*)array {
        _tempFilteredItems = array;
}
+ (NSMutableArray *)getNewArrivalItems{
    if (_newArrivalItems == nil) {
        _newArrivalItems = [[NSMutableArray alloc] init];
    }
    return _newArrivalItems;
}
+ (NSMutableArray *)getTrendingItems{
    if (_trendingItems == nil) {
        _trendingItems = [[NSMutableArray alloc] init];
    }
    return _trendingItems;
}
+ (NSMutableArray *)getBestSellingItems{
    if (_bestSellingItems == nil) {
        _bestSellingItems = [[NSMutableArray alloc] init];
    }
    return _bestSellingItems;
}

+ (ProductInfo*)getProductWithId:(int)_id{
    ProductInfo* object = nil;
    for (object in _allProducts) {
        if (object._id == _id) {
            return object;
        }
    }
    ProductInfo* obj = [[ProductInfo alloc] init];
    obj._id = _id;
    return obj;
    //    return nil;
}

+ (ProductInfo*)isProductExists:(int)_id{
    ProductInfo* object = nil;
    for (object in _allProducts) {
        if (object._id == _id) {
            return object;
        }
    }
    return nil;
}
+ (NSMutableArray *)getOnlyForCategory:(CategoryInfo*)category showFilterProducts:(BOOL)showFilterProducts {
    if (showFilterProducts) {
        return [ProductInfo getFilteredItems];
    }
    NSMutableArray *productsWithInCategory = [[NSMutableArray alloc] init];
    ProductInfo *temp_product = nil;
    for (temp_product in _allProducts) {
        NSMutableArray *temp_categories = temp_product._categories;
        CategoryInfo *temp_category = nil;
        for (temp_category in temp_categories) {
            if (temp_category == category) {
                [productsWithInCategory addObject:temp_product];
            }
        }
    }
    return productsWithInCategory;
}
+ (NSMutableArray *)getOnlyForCategory:(CategoryInfo*)category{
    NSMutableArray *productsWithInCategory = [[NSMutableArray alloc] init];
    ProductInfo *temp_product = nil;
    for (temp_product in _allProducts) {
        NSMutableArray *temp_categories = temp_product._categories;
        CategoryInfo *temp_category = nil;
        for (temp_category in temp_categories) {
            if (temp_category == category) {
                [productsWithInCategory addObject:temp_product];
            }
        }
    }
    return productsWithInCategory;
}
+ (NSMutableArray *)getAllForCategory:(CategoryInfo*)category{
    NSMutableArray *productsWithInCategory = [[NSMutableArray alloc] init];
    ProductInfo *temp_product = nil;
    for (temp_product in _allProducts) {
        NSMutableArray *temp_categories = temp_product._categories;
        CategoryInfo *temp_category = nil;
        for (temp_category in temp_categories) {
            if (temp_category == category) {
                [productsWithInCategory addObject:temp_product];
                break;
            }
        }
    }
    NSMutableArray *temp_childern_categories = category._children;
    CategoryInfo *tempCategoryInfo = nil;
    for (tempCategoryInfo in temp_childern_categories) {
        [productsWithInCategory addObjectsFromArray:[self getAllForCategory:tempCategoryInfo]];
    }
    return productsWithInCategory;
}
- (BOOL)belongsToCategory:(CategoryInfo*)category{
    CategoryInfo* productsCurrentCategory = nil;
    for (productsCurrentCategory in self._categories) {
        if (productsCurrentCategory == category) {
            return true;
        }
        NSMutableArray* childernCategories = category._children;
        CategoryInfo *tempCategoryInfo = nil;
        for (tempCategoryInfo in childernCategories) {
            if([tempCategoryInfo belongsToCategory:productsCurrentCategory]){
                return true;
            }
        }
    }
    return false;
}
+ (void)printAll{
    ProductInfo *temp_product = nil;
    for (temp_product in _allProducts) {
        RLOG(@"------- ProdductId:[%d]\t --------",temp_product._id);
        RLOG(@"------- ProdductName:[%@]\t --------",temp_product._title);
        RLOG(@"------- ProdductDesc:[%@]\t --------",temp_product._description);
        RLOG(@"--------------------------------------------------------");
    }
}
+ (NSString*)getThumbOfProduct:(int)productId{
    ProductInfo *temp_product = nil;
    for (temp_product in _allProducts) {
        if (temp_product._id == productId) {
            if (temp_product._images.count > 0) {
                ProductImage* productImage = [temp_product._images objectAtIndex:0];
                return productImage._src;
            } else {
                return @"";
            }
        }
    }
    return @"";
}
+ (ProductInfo*) getOrCreat:(int) _id{
    for (ProductInfo *p in _allProducts)
    {
        if (p._id == _id)
        {
            return p;
        }
    }
    ProductInfo *productInfo = [[ProductInfo alloc] init];
    productInfo._id = _id;
    return productInfo;
}
+ (ProductInfo*)getProductWithSku:(NSString*) sku{
    for (ProductInfo *p in _allProducts)
    {
        if ([[p._sku lowercaseString] isEqualToString:[sku lowercaseString]])
        {
            return p;
        }
    }
    return NULL;
}
+ (BOOL)isAvailable:(int) _id {
    for (ProductInfo *p in _allProducts)
    {
        if (p._id == _id)
        {
            return true;
        }
    }
    return false;
}
+ (NSMutableArray *)getDiscounts {
    NSArray *tempArray = [ProductInfo getAll];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"sale_price" ascending:YES];
    NSMutableArray *newArray = [[NSMutableArray alloc] initWithArray:[tempArray sortedArrayUsingDescriptors:@[sortDescriptor]]];
    return newArray;
}
+ (NSMutableArray *)getNewArrivals {
    NSArray *tempArray = [ProductInfo getAll];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"created_at" ascending:YES];
    NSMutableArray *newArray = [[NSMutableArray alloc] initWithArray:[tempArray sortedArrayUsingDescriptors:@[sortDescriptor]]];
    return newArray;
}
+ (NSMutableArray *)getMaxSolds {
    NSArray *tempArray = [ProductInfo getAll];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"sale_price" ascending:YES];
    NSMutableArray *newArray = [[NSMutableArray alloc] initWithArray:[tempArray sortedArrayUsingDescriptors:@[sortDescriptor]]];
    return newArray;
}
+ (NSMutableArray *)getTrendings{
    NSArray *tempArray = [ProductInfo getAll];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"sale_price" ascending:YES];
    NSMutableArray *newArray = [[NSMutableArray alloc] initWithArray:[tempArray sortedArrayUsingDescriptors:@[sortDescriptor]]];
    return newArray;
}

+ (NSMutableArray *)getProducts:(NSString *)keyString isAscending:(BOOL)isAscending viewType:(int)viewType{
#if ENABLE_TRENDING_ITEMS_VIA_PLUGIN
    switch (viewType) {
        case kHV_TYPES_TRENDINGS:
            return [ProductInfo getTrendingItems];
            break;
        case kHV_TYPES_BESTSELLINGS:
            return [ProductInfo getBestSellingItems];
            break;
        case kHV_TYPES_NEWARRIVALS:
            return [ProductInfo getNewArrivalItems];
            break;
        default:
            return nil;
            break;
    }
#else
    if (_productsWithKey == nil) {
        _productsWithKey = [[NSMutableDictionary alloc] init];
    }
    NSMutableArray * newArray = nil;
    if ([_productsWithKey objectForKey:keyString]) {
        newArray = [_productsWithKey objectForKey:keyString];
    }else{
        NSArray *tempArray = [ProductInfo getAll];
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:keyString ascending:isAscending];
        newArray = [[NSMutableArray alloc] initWithArray:[tempArray sortedArrayUsingDescriptors:@[sortDescriptor]]];
        [_productsWithKey setObject:newArray forKey:keyString];
    }
    return newArray;
#endif
}
+ (NSMutableArray *)getProductsForCategory:(CategoryInfo*)cInfo keyString:(NSString *)keyString isAscending:(BOOL)isAscending viewType:(int)viewType{

#if ENABLE_TRENDING_ITEMS_VIA_PLUGIN
    switch (viewType) {
        case kHV_TYPES_TRENDINGS:
            return [ProductInfo getTrendingItems];
            break;
        case kHV_TYPES_BESTSELLINGS:
            return [ProductInfo getBestSellingItems];
            break;
        case kHV_TYPES_NEWARRIVALS:
            return [ProductInfo getNewArrivalItems];
            break;
        default:
            return nil;
            break;
    }
#else
    if (_productsWithKey == nil) {
        _productsWithKey = [[NSMutableDictionary alloc] init];
    }
    NSMutableArray * newArray = nil;
    if ([_productsWithKey objectForKey:keyString]) {
        newArray = [[NSMutableArray alloc] initWithArray:[_productsWithKey objectForKey:keyString]];
    }else{
        NSArray *tempArray = [ProductInfo getAll];
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:keyString ascending:isAscending];
        newArray = [[NSMutableArray alloc] initWithArray:[tempArray sortedArrayUsingDescriptors:@[sortDescriptor]]];
        [_productsWithKey setObject:newArray forKey:keyString];
    }
    if (cInfo == nil) {
        return newArray;
    }

    NSMutableArray* tArray = [CategoryInfo getAllSubCategories:cInfo tempListCategories:nil];

    NSMutableArray * arrayForCategory = [[NSMutableArray alloc] init];
    NSObject *obj = nil;
    for (obj in newArray) {
        ProductInfo *pInfo = (ProductInfo*) (obj);
        if (pInfo._categories != nil && [pInfo._categories count] > 0) {
            NSObject* obj1 = nil;
            for (obj1 in tArray) {
                CategoryInfo* tcInfo = (CategoryInfo*)obj1;
                if ((CategoryInfo*)([pInfo._categories objectAtIndex:0]) == tcInfo) {
                    [arrayForCategory addObject:pInfo];
                    break;
                }
            }
        }
    }

    if ([arrayForCategory count] > 0) {
        return arrayForCategory;
    }else{
        [newArray removeAllObjects];
        return newArray;
    }
#endif
}
+ (NSMutableArray *)searchProducts:(NSString *)searchStr searchedArray:(NSMutableArray*)searchedArray {
    NSMutableArray* array = [[NSMutableArray alloc] init];

    NSMutableArray* arrayStr = [[NSMutableArray alloc] init];
    NSString* searchedStr = [searchStr lowercaseString];

    for (ProductInfo* product in searchedArray) {
        BOOL isSearchedItem = false;
        BOOL isRestrictedProduct = product.isRestricted;
        NSString* matchedStr = @"";
        if (!isRestrictedProduct && !isSearchedItem && product._title && [Utility containsString:[product._title lowercaseString] substring:searchedStr]) {
            isSearchedItem = true;
            matchedStr =[product._title lowercaseString];
            RLOG(@"matched string = %@", matchedStr);
        }
        //        if (!isSearchedItem && product._sku && [[product._sku lowercaseString] containsString:searchedStr]) {
        //            isSearchedItem = true;
        //            matchedStr =[product._sku lowercaseString];
        //        }
        //        if (!isSearchedItem && product._description && [[product._description lowercaseString] containsString:searchedStr]) {
        //            isSearchedItem = true;
        //            matchedStr =[product._description lowercaseString];
        //        }
        //        if (!isSearchedItem && product._short_description && [[product._short_description lowercaseString] containsString:searchedStr]) {
        //            isSearchedItem = true;
        //            matchedStr =[product._short_description lowercaseString];
        //        }
        //        if (!isSearchedItem) {
        //            for (CategoryInfo* category in [product _categories]) {
        //                if (category._name && [[category._name lowercaseString] containsString:searchedStr]) {
        //                    isSearchedItem = true;
        //                    matchedStr = [category._name lowercaseString];
        //                }
        //            }
        //        }
        if (isSearchedItem) {
            [array addObject:product];
            [arrayStr addObject:matchedStr];
        }
    }

    RLOG(@"======RESULT FOUND : %d======", (int)[array count]);
    for (int i = 0; i < (int)[array count]; i++) {
        RLOG(@"PNAME:\n%@", ((ProductInfo*)[array objectAtIndex:i])._title);
        //        RLOG(@"MATCH:\n%@", [arrayStr objectAtIndex:i]);
    }
    if ([array count] == 0) {
        RLOG(@"NO RESULT FOUND!");
        return nil;
    }

    return array;
}

+ (NSMutableArray *)searchProducts:(NSString *)searchStr {
    NSMutableArray* array = [[NSMutableArray alloc] init];

    NSMutableArray* arrayStr = [[NSMutableArray alloc] init];
    searchStr = [searchStr lowercaseString];

    for (ProductInfo* product in [ProductInfo getAll]) {
        NSString* matchedStr = @"";
        RLOG(@"Product Title:%@",product._title);
        if (!product.isRestricted
            && product._title
            && ([Utility containsString:[product._title lowercaseString] substring:searchStr] || [ProductInfo containsTag:product tag:searchStr])) {
            matchedStr =[product._title lowercaseString];
            [array addObject:product];
            [arrayStr addObject:matchedStr];
        }
    }
    if ([array count] == 0) {
        RLOG(@"NO RESULT FOUND!");
        return nil;
    }
    return array;
}

+ (BOOL)containsTag:(ProductInfo*)product tag:(NSString*)tag{
    if(product._tags != nil && [product._tags count] > 0){
        for (NSString* _tag in product._tags){
            if([Utility containsString:[_tag lowercaseString] substring:tag])
                return true;
        }
    }
    return false;
}

+ (NSMutableArray *)searchProductsOld:(NSString *)searchStr{
    NSMutableArray* array = [[NSMutableArray alloc] init];

    NSMutableArray* arrayStr = [[NSMutableArray alloc] init];
    NSString* searchedStr = [searchStr lowercaseString];
    for (ProductInfo* product in [ProductInfo getAll]) {
        BOOL isSearchedItem = false;
        NSString* matchedStr = @"";
        if (!isSearchedItem && product._title && [Utility containsString:[product._title lowercaseString] substring:searchedStr]) {
            isSearchedItem = true;
            matchedStr =[product._title lowercaseString];
        }

        if (!isSearchedItem && product._sku && [Utility containsString:[product._sku lowercaseString] substring:searchedStr]) {
            isSearchedItem = true;
            matchedStr =[product._sku lowercaseString];
        }
        if (!isSearchedItem && product._description && [Utility containsString:[product._description lowercaseString] substring:searchedStr]) {
            isSearchedItem = true;
            matchedStr =[product._description lowercaseString];
        }
        if (!isSearchedItem && product._short_description && [Utility containsString:[product._short_description lowercaseString] substring:searchedStr]) {
            isSearchedItem = true;
            matchedStr =[product._short_description lowercaseString];
        }
        if (!isSearchedItem) {
            for (CategoryInfo* category in [product _categories]) {
                if (category._name && [Utility containsString:[category._name lowercaseString] substring:searchedStr]) {
                    isSearchedItem = true;
                    matchedStr = [category._name lowercaseString];
                }
            }
        }
        if (isSearchedItem) {
            [array addObject:product];
            [arrayStr addObject:matchedStr];
        }
    }

    RLOG(@"======RESULT FOUND : %d======", (int)[array count]);
    for (int i = 0; i < (int)[array count]; i++) {
        RLOG(@"PNAME:\n%@", ((ProductInfo*)[array objectAtIndex:i])._title);
        //        RLOG(@"MATCH:\n%@", [arrayStr objectAtIndex:i]);
    }
    if ([array count] == 0) {
        RLOG(@"NO RESULT FOUND!");
        return nil;
    }

    return array;
}


- (BOOL)isProductDiscounted:(int)variationId{
    float newPrice = [self getNewPrice:variationId];
    float oldPrice = [self getOldPrice:variationId];
    if (oldPrice == 0.0f) {
        return false;
    }else{
        if (oldPrice > newPrice) {
            return true;
        } else {
            return false;
        }
    }
    return false;
}
- (float)getOldPrice:(int)variationId{
    float oldPrice = 0.0f;
    if (variationId == -1) {
        //no variation available
        if (self._price == self._sale_price) {
            //may be sale or not
            if (self._price != self._regular_price) {
                //sale
                oldPrice = self._regular_price;
            }
        } else {
            //100% no sale
            oldPrice = self._regular_price;
        }
    }else{
        Variation* variation = [self._variations getVariation:variationId variationIndex:-1];
        //no variation available
        if (variation._price == variation._sale_price) {
            //may be sale or not
            if (variation._price != variation._regular_price) {
                //sale
                oldPrice = variation._regular_price;
            }
        } else {
            //100% no sale
            oldPrice = variation._regular_price;
        }
    }
    return oldPrice;
}
- (float)getOldPriceOriginal:(int)variationId{
    float oldPrice = 0.0f;
    if (variationId == -1) {
        //no variation available
        if (self._priceOriginal == self._sale_priceOriginal) {
            //may be sale or not
            if (self._priceOriginal != self._regular_priceOriginal) {
                //sale
                oldPrice = self._regular_priceOriginal;
            }
        } else {
            //100% no sale
            oldPrice = self._regular_priceOriginal;
        }
    }else{
        Variation* variation = [self._variations getVariation:variationId variationIndex:-1];
        //no variation available
        if (variation._priceOriginal == variation._sale_priceOriginal) {
            //may be sale or not
            if (variation._priceOriginal != variation._regular_priceOriginal) {
                //sale
                oldPrice = variation._regular_priceOriginal;
            }
        } else {
            //100% no sale
            oldPrice = variation._regular_priceOriginal;
        }
    }
    return oldPrice;
}
- (float)getNewPrice:(int)variationId{
    float newPrice = 0.0f;

    if (variationId == -1) {
        //no variation available
        newPrice = self._price;
    }else{
        Variation* variation = [self._variations getVariation:variationId variationIndex:-1];
        newPrice = variation._price;
    }
    return newPrice;
}
- (float)getNewPriceOriginal:(int)variationId{
    float newPrice = 0.0f;
    
    if (variationId == -1) {
        //no variation available
        newPrice = self._priceOriginal;
    }else{
        Variation* variation = [self._variations getVariation:variationId variationIndex:-1];
        newPrice = variation._priceOriginal;
    }
    return newPrice;
}

- (float)getDiscountPercent:(int)variationId {
    float oldPrice = [self getOldPrice:variationId];
    float newPrice = [self getNewPrice:variationId];
    float discountPercent = 0.0f;
    if (newPrice != oldPrice && oldPrice != 0) {
        discountPercent = 100 * (newPrice / oldPrice);
    }
    return discountPercent;
}
- (float)getDiscountPercentOriginal:(int)variationId {
    float oldPrice = [self getOldPriceOriginal:variationId];
    float newPrice = [self getNewPriceOriginal:variationId];
    float discountPercent = 0.0f;
    if (newPrice != oldPrice && oldPrice != 0) {
        discountPercent = 100 * (newPrice / oldPrice);
    }
    return discountPercent;
}
+ (float)getExtraPrice:(NSMutableArray*)seletedAttributes pInfo:(ProductInfo*)pInfo
{
    float extraPrice = 0.0f;
    if (seletedAttributes) {
        for (VariationAttribute* vAttr in seletedAttributes) {
            Attribute* tempAttribute = [pInfo getAttributeWithName:vAttr.name];
            if (tempAttribute) {
                float additionalPrice = 0.0f;
                if (tempAttribute.additional_values != nil && (int)[tempAttribute.additional_values count] > 0) {
                    additionalPrice = [tempAttribute getAdditionalPrice:vAttr.value];
                    vAttr.extraPrice = additionalPrice;
                } else {
                    additionalPrice = vAttr.extraPrice;
                }
                extraPrice += additionalPrice;
            } else if(pInfo._isFullRetrieved == false) {
                float additionalPrice = vAttr.extraPrice;
                extraPrice += additionalPrice;
            }
        }
    }
    return extraPrice;
}
- (void)adjustVariations{
    if (self._variations == nil || (int)[self._variations count] == 0) {
        return;
    }
    NSMutableArray* newVariationsToAdd = [[NSMutableArray alloc] init];
    NSMutableArray* variationsToDelete = [[NSMutableArray alloc] init];
    for (Variation* variation in self._variations) {
        for (int attributeIndex = 0; attributeIndex < [variation._attributes count]; attributeIndex++) {
            VariationAttribute* attribute = [variation._attributes objectAtIndex:attributeIndex];
            if (attribute.value == nil || [attribute.value isEqualToString:@""]) {
                Attribute* productAttribute = [self getAttributeWithName:attribute.name];
                if (productAttribute != nil) {
                    //TODO - some magic here
                    for (NSString* option in productAttribute._options) {
                        Variation* newVariation = [variation cloneMe];
                        ((VariationAttribute*)([newVariation._attributes objectAtIndex:attributeIndex])).value = option;
                        [newVariationsToAdd addObject:newVariation];
                    }
                    if (![variationsToDelete containsObject:variation]) {
                        [variationsToDelete addObject:variation];
                    }
                }
            }
        }
    }


    RLOG(@"VARIATION COUNT BEFORE = %d", (int)[self._variations count]);
    [self._variations addObjectsFromArray:newVariationsToAdd];
    [self._variations removeObjectsInArray:variationsToDelete];
    RLOG(@"VARIATION COUNT AFTER = %d", (int)[self._variations count]);

    if ([variationsToDelete count] > 0) {
        [self adjustVariations];
    }

}

- (Attribute*)getAttributeWithName:(NSString*)name {
    for (Attribute* attribute in self._attributes) {
        if ([Utility compareAttributeNames:attribute._name name2:name]) {
            return attribute;
        }
    }
    return nil;
}
- (void)addAttribute:(Attribute*)attribute {
    Attribute* attribute1 = [self getAttributeWithName:attribute._name];
    if (attribute1 == nil) {
        [self._attributes addObject:attribute];
    } else {
        for (NSString* option in attribute._options) {
            if (![attribute1._options containsObject:option]) {
                [attribute1._options addObject:option];
            }
        }
    }
}
- (void)reIndexVariations {
    for (int i = 0; i < (int)[self._variations count]; i++) {
        ((Variation*)([self._variations objectAtIndex:i]))._variation_index = i;
    }
}


- (void)adjustAttributes {
    NSMutableArray* extraAttributes = [[NSMutableArray alloc] init];
    for (Attribute* attribute in self._attributes) {
        if (attribute._variation) {//if this attribute is used for variation or not
            NSMutableArray* extraOptions = [[NSMutableArray alloc] init];
            for (NSString* option in attribute._options) {
                BOOL isAttributeUsedEver = false;
                for (Variation* variation in self._variations) {
                    if ([variation hasOptionForAttribute:attribute._name option:option]) {
                        isAttributeUsedEver = true;
                        break;
                    }
                }
                // excludes attributes having visibility and no variations
                if (!attribute._visible && !isAttributeUsedEver) {
                    [extraOptions addObject:option];
                }
            }
            [attribute._options removeObjectsInArray:extraOptions];
        }
        
        if ([attribute._options count] == 0 || (IS_EMPTY_STR(attribute._name) && IS_EMPTY_STR(attribute._slug))) {
            [extraAttributes addObject:attribute];
        } else if (![[Addons sharedManager] show_non_variation_attribute] && !attribute._variation) {
            [extraAttributes addObject:attribute];
        } else if ((!attribute._visible && !attribute._variation) || !attribute._variation) {
            [extraAttributes addObject:attribute];
        }
    }
    // Add extra attribute for additional information
    [self._extraAttributes removeAllObjects];
    [self._extraAttributes addObjectsFromArray:extraAttributes];
    
    // Remove extra attribute for normal attribute selection
    if (self._attributes) {
        [self._attributes removeObjectsInArray:extraAttributes];
    }
}
- (void)addInAllParentCategory:(CategoryInfo*)cInfo {

    if ([[Addons sharedManager] show_child_cat_products_in_parent_cat]) {
        if(cInfo._parent){
            if ([self._categories containsObject:cInfo._parent] == false) {
                [self._categories addObject:cInfo._parent];
                [self addInAllParentCategory:cInfo._parent];
            }
        }
    }
}

- (BOOL) hasVariations {
    return self._variations != nil && [self._variations count] > 0;
}
- (float)getWeightWithVariationID:(int)variationId {
    if (variationId != -1) {
        Variation* variation = [self._variations getVariation:variationId variationIndex:-1];
        return variation._weight;
    }
    return self._weight;
}

- (NSString*) getVariationsIds {
    NSMutableString* str = [[NSMutableString alloc] init];
    if ([self hasVariations]) {
        unsigned long size = self._variations.count;
        for (int i = 0; i < size; i++) {
            Variation* variation = self._variations[i];
            [str appendFormat:@"%d", variation._id];
            if (i < size - 1) {
                [str appendString:@","];
            }
        }
    }
    return [NSString stringWithFormat:@"[%@]", str];
}

- (Variation*) getVariation:(int)variationId {
    if(self._variations != nil) {
        return [self._variations getVariation:variationId];
    }
    return nil;
}

-(int) getRewardPoints:(int)variationId {
    if (variationId < 0) {
        return _rewardPoints;
    }

    Variation* variation = [self getVariation:variationId];
    if (variation != nil) {
        return variation.rewardPoints;
    }
    return 0;
}
- (NSAttributedString*)getDescriptionAttributedString {
//    if (self.descAttribStr == nil)
    {
        NSString * htmlString = self._description;
        NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        self.descAttribStr = attrStr;
    }
    return self.descAttribStr;
}
- (NSAttributedString*)getShortDescriptionAttributedString {
    NSString * htmlString = self._short_description;
    if (self.shortDescAttribStr == nil) {
        NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        self.shortDescAttribStr = attrStr;
    }
    return self.shortDescAttribStr;
}
- (NSAttributedString*)getPriceOldString {
    return self._priceOldString;
}
- (NSString*)getPriceNewString {
    return self._priceNewString;
}
+ (void)resetAllProductLocalizedStrings {
    for (ProductInfo* p in [ProductInfo getAll]) {
        if (p._isDiscountedForOuterView) {
            p._priceOldString = [[Utility sharedManager] convertToStringStrikethrough:p._oldPriceForOuterView isCurrency:true];
        }else{
            p._priceOldString = [[NSAttributedString alloc]initWithString:@"     "];
        }
        
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
    }
}
#pragma mark SELLER-ZONE
- (NSMutableArray*)szGetCategoryNames {
    [self szGetCategoryIds];
    return self.szCategoryNames;
}
- (NSMutableArray*)szGetCategoryIds {
    if (self.szCategoryIdsTemp == nil) {
        self.szCategoryIdsTemp = [[NSMutableArray alloc] init];
        self.szCategoryNamesTemp = [[NSMutableArray alloc] init];
        self.szCategoryIds = [[NSMutableArray alloc] init];
        self.szCategoryNames = [[NSMutableArray alloc] init];
        if (self._attributes) {
            for (CategoryInfo* cInfo in self._categories) {
                NSNumber* cIdObj = [NSNumber numberWithInteger:cInfo._id];
                [self.szCategoryIdsTemp addObject:cIdObj];
                [self.szCategoryNamesTemp addObject:cInfo._name];
                
                [self.szCategoryIds addObject:cIdObj];
                [self.szCategoryNames addObject:cInfo._name];
            }
        }
    }
    return self.szCategoryIds;
}
- (NSNumber*)szHasCategoryId:(int)cId {
    [self szGetCategoryIds];
    NSMutableArray* categoryIds = self.szCategoryIdsTemp;
    for (NSNumber* categoryId in categoryIds) {
        if ([categoryId intValue] == cId) {
            return categoryId;
        }
    }
    return nil;
}
- (void)szAddCategoryId:(int)cId {
    [self szGetCategoryIds];
    if ([self szHasCategoryId:cId] == nil) {
        CategoryInfo* cInfo = [CategoryInfo getWithId:cId];
        [self.szCategoryIdsTemp addObject:[NSNumber numberWithInteger:cId]];
        [self.szCategoryNamesTemp addObject:cInfo._name];
    }
}
- (void)szRemoveCategoryId:(int)cId {
    [self szGetCategoryIds];
    NSNumber* obj = [self szHasCategoryId:cId];
    if (obj != nil) {
        NSMutableArray* categoryIds = self.szCategoryIdsTemp;
        int objIndex = (int)[categoryIds indexOfObject:obj];
        [self.szCategoryIdsTemp removeObjectAtIndex:objIndex];
        [self.szCategoryNamesTemp removeObjectAtIndex:objIndex];
    }
}
- (void)szMoveCategoryIds {
    self.szCategoryIds = [NSMutableArray arrayWithArray:self.szCategoryIdsTemp];
    self.szCategoryNames = [NSMutableArray arrayWithArray:self.szCategoryNamesTemp];
}
#pragma mark OTHER

-(void)addImage:(ProductImage*)productImage {
    if (self._images == nil) {
        return;
    }
    
    BOOL contains = false;
    for (ProductImage *_productImage in self._images) {
        if ([_productImage._src isEqualToString:productImage._src]) {
            contains = true;
            break;
        }
    }
    
    if(!contains){
        [self._images addObject:productImage];
    }
}

@end
