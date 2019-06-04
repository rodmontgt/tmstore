//
//  CategoryInfo.h
//  eCommerceApp
//
//  Created by Rishabh Jain on 02/10/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TM_ProductFilter.h"
@interface CategoryInfo : NSObject
@property int _childRetrievedCount;


@property int _id;
@property NSString* _name;
@property NSString* _slug;
@property NSString* _slugOriginal;
@property int _parentId;
@property CategoryInfo* _parent;
@property NSString* _description;
@property NSString* _display;
@property NSString* _image;
@property int _count;
@property NSMutableArray* _children;//ARRRAY OF CategoryInfo
//@property NSMutableArray* _childrenProducts;//ARRRAY OF CategoryInfo

@property int _childMaximumCount;
@property int pageCount;

@property NSString* _nameForOuterView;

- (id)init;
+ (BOOL)areCategoriesVarified;
+ (void)setCategoriesVarified;
- (BOOL)belongsToCategory:(CategoryInfo*)category;
- (BOOL)hasParent;
- (void)addChild:(CategoryInfo*)child;
- (void)setParent:(CategoryInfo*)parent;
+ (CategoryInfo*)getWithSlug:(NSString*)slug;
+ (CategoryInfo*)getWithName:(NSString*)name;
+ (CategoryInfo*)getWithId:(int) _id;
+ (NSMutableArray*)getAll;//RETURN ARRAY OF CategoryInfo
+ (void)flushAll;
+ (void)saveAll;
- (NSMutableArray*)getSubCategories;//RETURN ARRAY OF CategoryInfo
+ (NSMutableArray*)getAllRootCategories;//RETURN ARRAY OF CategoryInfo
+ (void)printAll;
- (BOOL)hasKeyWord:(NSString*)key;
//+ (CategoryInfo*)getWithKeyWords:(NSArray*)keywords;
+ (NSMutableArray*)getAllSubCategories:(CategoryInfo*)cInfo tempListCategories:(NSMutableArray*)tempListCategories;
+ (void)refineCategories;
+ (void)refineMaxChildCount;
+ (void)stepUpSingleChildrenCategories;
+ (void)autoRefreshCategoryThumbs;
- (BOOL)loadMoreProducts;
- (int)getChildRetrievedCount;
+ (BOOL)isProductBelongsToRestrictedCategories:(id)productObject;

@property TM_ProductFilter* pFilter;
@end
