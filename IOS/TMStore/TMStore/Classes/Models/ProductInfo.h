//
//  ProductInfo.h
//  eCommerceApp
//
//  Created by Rishabh Jain on 01/10/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CategoryInfo.h"
#import "Dimension.h"
#import "VariationSet.h"
#import "Attribute.h"
#import "QuantityRule.h"
#import "TM_Bundle.h"
#import "TM_MixMatch.h"
#import "TM_ProductDeliveryDate.h"
#import "SellerInfo.h"
#import "ProductImage.h"

enum ProductType {
    PRODUCT_TYPE_SIMPLE,
    PRODUCT_TYPE_GROUPED,
    PRODUCT_TYPE_CONFIGURABLE,
    PRODUCT_TYPE_VIRTUAL,
    PRODUCT_TYPE_BUNDLE,
    PRODUCT_TYPE_DOWNLOADABLE,
    PRODUCT_TYPE_EXTERNAL_OR_AFFILIATE,
    PRODUCT_TYPE_VARIABLE,
    PRODUCT_TYPE_MIXNMATCH
};
enum HV_TYPES{
    kHV_TYPES_TRENDINGS,
    kHV_TYPES_BESTSELLINGS,
    kHV_TYPES_NEWARRIVALS,
    kHV_TYPES_DISCOUNTS,
    kHV_TYPES_USERDEFINED1,
    kHV_TYPES_USERDEFINED2,
    kHV_TYPES_USERDEFINED3,
    kHV_TYPES_USERDEFINED4,
    kHV_TYPES_USERDEFINED5
};
@interface ProductInfo : NSObject

@property NSString *_title;
@property int _id;
@property BOOL _downloadable;
@property BOOL _virtual;
@property NSString *_permalink;
@property NSString *_sku;

@property float _price;
@property float _regular_price;
@property float _sale_price;

@property float price_clone;
@property float regular_price_clone;
@property float sale_price_clone;

@property float _priceOriginal;
@property float _regular_priceOriginal;
@property float _sale_priceOriginal;

@property float _discount;
@property NSString *_price_html;
@property BOOL _taxable;
@property BOOL _in_stock;
@property BOOL _sold_individually;
@property BOOL _purchaseable;
@property BOOL _featured;
@property BOOL _visible;
@property BOOL _on_sale;
@property NSString *_product_url;
@property BOOL _shipping_required;
@property BOOL _shipping_taxable;
@property NSString *_shipping_class;
@property NSString *_description;
@property NSAttributedString *descAttribStr;
@property NSString *_short_description;
@property NSAttributedString *shortDescAttribStr;
@property BOOL _reviews_allowed;
@property float _average_rating;
@property int _rating_count;
@property NSMutableArray *_related_ids;//ARRAY OF int
@property NSMutableArray *_related_products;//ARRAY OF pinfo
@property NSMutableArray *_upsell_ids;//ARRAY OF int
@property NSMutableArray *_cross_sell_ids;//ARRAY OF int
@property int _parent_id;
@property NSMutableArray *_categories;//ARRAY OF CategoryInfo
@property NSMutableArray *_categoriesNames;
@property NSMutableArray *_tags;//ARRAY OF int
@property NSMutableArray *_images;//ARRAY OF ProductImage
@property NSString *_featured_src;
@property NSMutableArray *_attributes;//ARRAY OF Attribute
@property NSMutableArray *_extraAttributes;//ARRAY of Extra Attributes
@property NSMutableArray *_downloads;//ARRAY OF NSString
@property int _download_limit;
@property int _download_expiry;
@property NSString *_download_type;
@property NSString *_purchase_note;
@property int _total_sales;
@property VariationSet *_variations;//VariationSet OF Variation
@property Dimension *_dimensions;
@property NSDate* _created_at;
@property NSDate* _updated_at;
@property float _weight;
@property enum ProductType _type;
@property BOOL _managing_stock;
@property int _stock_quantity;
@property BOOL _backorders_allowed;
@property BOOL _backordered;//If managing stock, this controls whether or not backorders are allowed. If enabled, stock quantity can go below 0. The options are: false (Do not allow), notify (Allow, but notify customer), and true (Allow)
@property NSString *_tax_status;
@property NSString *_tax_class;
@property int _shipping_class_id;
@property NSString *_status;

@property BOOL _isSmallRetrived;
@property BOOL _isFullRetrieved;
@property BOOL _isExtraPriceRetrieved;
@property BOOL _isReviewsRetrieved;
@property BOOL _isExtraDataRetrieved;
@property BOOL _isDiscountedForOuterView;
@property float _newPriceForOuterView;
@property float _oldPriceForOuterView;
@property NSString* _titleForOuterView;
@property NSString* _priceNewString;
@property NSAttributedString* _priceOldString;
@property NSString *_productThumbnail;
@property NSMutableArray* _productReviews;
@property int pollLikeCount;
@property int pollDislikeCount;

@property float _priceMin;
@property float _priceMax;

@property int rewardPoints;

@property NSString* brandName;
@property NSString* brandUrl;
@property NSString* priceLabel;
@property NSString* labelPosition;

@property QuantityRule* quantityRule;
@property TM_MixMatch* mMixMatch;
@property NSMutableArray* mBundles;

@property TM_PRDD* prdd;
@property BOOL prddDataFetched;


@property BOOL sellerDataFetched;
@property SellerInfo* sellerInfo;

- (void)clonePrice;

- (id)init;
- (id)init:(BOOL)isAddToList;
+ (NSMutableArray *)getAll;//RETURN ARRAY OF ProductInfo Objects
+ (ProductInfo*)getProductWithId:(int)_id;
+ (NSMutableArray *)getOnlyForCategory:(CategoryInfo*)category;//RETURN ARRAY OF ProductInfo Objects
+ (NSMutableArray *)getAllForCategory:(CategoryInfo*)category;//RETURN ARRAY OF ProductInfo Objects
+ (NSMutableArray *)getOnlyForCategory:(CategoryInfo*)category showFilterProducts:(BOOL)showFilterProducts;
- (BOOL)belongsToCategory:(CategoryInfo*)category;
+ (void)printAll;
+ (NSString*)getThumbOfProduct:(int)productId;

+ (NSMutableArray *)getDiscounts;
+ (NSMutableArray *)getNewArrivals;
+ (NSMutableArray *)getMaxSolds;
+ (NSMutableArray *)getTrendings;

+ (NSMutableArray *)getProducts:(NSString *)keyString isAscending:(BOOL)isAscending  viewType:(int)viewType;
+ (NSMutableArray *)getProductsForCategory:(CategoryInfo*) cInfo keyString:(NSString *)keyString isAscending:(BOOL)isAscending viewType:(int)viewType;
+ (NSMutableArray *)searchProducts:(NSString *)searchStr;
+ (BOOL)containsTag:(ProductInfo*)product tag:(NSString*)tag;


+ (NSMutableArray *)getNewArrivalItems;
+ (NSMutableArray *)getBestSellingItems;
+ (NSMutableArray *)getTrendingItems;
//PARSE-analytics-stuff
@property int Current_Day_Total_Cart_WhisList;
@property int Current_Day_Revenue;
@property int Current_Day_Sales;
@property int Current_Day_Product_Visited;
@property int Current_Day_cart_added;
@property int Current_Day_wish_added;
@property int Current_Day_Product_Cart_Purchased;
@property int Current_Day_Product_Viewed;

- (BOOL)isProductDiscounted:(int)variationId;
- (float)getNewPrice:(int)variationId;
- (float)getOldPrice:(int)variationId;
- (float)getDiscountPercent:(int)variationId;
- (float)getNewPriceOriginal:(int)variationId;
- (float)getOldPriceOriginal:(int)variationId;
- (float)getDiscountPercentOriginal:(int)variationId;
+ (NSMutableArray *)searchProducts:(NSString *)searchStr searchedArray:(NSMutableArray*)searchedArray;


@property CGSize updatedCardSizeL;
@property CGSize updatedCardSizeP;
@property CGSize originalCardSizeL;
@property CGSize originalCardSizeP;
@property NSArray* variation_simple_fields;
- (void)addAttribute:(Attribute*)attribute;
- (void)reIndexVariations;
- (void)adjustAttributes;
- (void)adjustVariations;
- (void)addInAllParentCategory:(CategoryInfo*)cInfo;
- (BOOL)hasVariations;
- (NSString*)getVariationsIds;
- (Variation*)getVariation:(int)variationId;
- (Attribute*)getAttributeWithName:(NSString*)name;
+ (float)getExtraPrice:(NSMutableArray*)seletedAttributes pInfo:(ProductInfo*)pInfo;
- (float)getWeightWithVariationID:(int)variationId;
- (int)getRewardPoints:(int)variationId;
- (NSAttributedString*)getDescriptionAttributedString;
- (NSAttributedString*)getShortDescriptionAttributedString;
@property id cellObj;
+ (NSMutableArray *)getFilteredItems;
+ (void)setFilteredItems:(NSMutableArray*)array;
- (NSAttributedString*)getPriceOldString;
- (NSString*)getPriceNewString;
+ (void)resetAllProductLocalizedStrings;
+ (ProductInfo*)getProductWithSku:(NSString*)sku;
+ (ProductInfo*)isProductExists:(int)_id;
@property BOOL isRestricted;
@property BOOL isRestrictionChecked;
#pragma mark SELLER-ZONE
- (void)szRemoveCategoryId:(int)cId;
- (void)szAddCategoryId:(int)cId;
- (NSNumber*)szHasCategoryId:(int)cId;
- (NSMutableArray*)szGetCategoryIds;
- (NSMutableArray*)szGetCategoryNames;
- (void)szMoveCategoryIds;
#pragma mark OTHER
-(void)addImage:(ProductImage*)productImage;
@property NSString *button_text;
@end
