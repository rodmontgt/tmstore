//
//  TM_ProductFilter.m
//  TMStore
//
//  Created by Rishabh Jain on 16/05/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import "TM_ProductFilter.h"
#import "TM_FilterAttribute.h"
#import "Variables.h"
#import "CategoryInfo.h"
static NSMutableArray* allProductFilters = NULL;

static BOOL attribsLoaded = false;

@interface TM_ProductFilter() {
    NSMutableArray* attributes;//array of filterattributes
}
@end

@implementation TM_ProductFilter
+ (NSMutableArray*)getAll {
    return allProductFilters;
}
+(BOOL)attribsLoaded{
    return attribsLoaded;
}
+(BOOL)attribsLoadedTrue{
    return attribsLoaded = true;
}

- (id)init {
    self = [super init];
    if (self) {
        _categoryId = -1;
       
        attributes = [[NSMutableArray alloc] init];
        self.maxPrice = 100000;
        self.minPrice =  0;
        self.maxDiscount = -1;
        self.minDiscount =  -1;
        [self registered];
    }
    return self;
}
- (void)registered{
    if(allProductFilters == NULL){
        allProductFilters = [[NSMutableArray alloc] init];
    }
    [allProductFilters addObject:self];
}

- (NSMutableArray*)getAttributes {
    return attributes;
}
- (void)addAttribute:(TM_FilterAttribute*)attribute {
    [attributes addObject:attribute];
}
+ (TM_ProductFilter*)getForCategory:(int)categoryId {
    RLOG(@"*************************allProductFilters*************************  %d",(int)[allProductFilters count] );
    for (TM_ProductFilter* filter in allProductFilters) {
//        RLOG(@"getForCategory:filterCategoryId=%d", filter.categoryId);
        if(filter.categoryId == categoryId) {
            RLOG(@"filter.maxPrice  %f",filter.maxPrice);
            return filter;
        }
    }
    TM_ProductFilter *productFilter = [self getWithCategoryId:categoryId];
//    [productFilter registered];
    return productFilter;
}
+ (TM_ProductFilter*)getWithCategoryId:(int)categoryId {
    RLOG(@"*************************allProductFilters*************************  %d",(int)[allProductFilters count] );
    RLOG(@"getWithCategoryId:filterCategoryId=%d", categoryId);
    if(categoryId != -1) {
        CategoryInfo* cInfo = [CategoryInfo getWithId:categoryId];
        if (cInfo && cInfo.pFilter) {
            return cInfo.pFilter;
        }
        //        for (TM_ProductFilter* filter in allProductFilters) {
        //            RLOG(@"getWithCategoryId:filterCategoryId=%d", filter.categoryId);
        //            if(filter.categoryId == categoryId) {
        //                RLOG(@"filter.categoryId   %d ======  categoryId    %d",filter.categoryId,categoryId);
        //                return filter;
        //            }
        //        }
        TM_ProductFilter* filter = [[TM_ProductFilter alloc] init];
        filter.categoryId = categoryId;
        if (cInfo) {
            cInfo.pFilter = filter;
        }
        return filter;
    }
    return nil;
}
/*
+ (TM_ProductFilter*)getWithCategoryId:(int)categoryId {
    RLOG(@"*************************allProductFilters*************************  %d",(int)[allProductFilters count] );
    if(categoryId != -1) {
        for (TM_ProductFilter* filter in allProductFilters) {
            RLOG(@"getWithCategoryId:filterCategoryId=%d", filter.categoryId);
            if(filter.categoryId == categoryId) {
                RLOG(@"filter.categoryId   %d ======  categoryId    %d",filter.categoryId,categoryId);
                return filter;
            }
        }
        TM_ProductFilter* filter = [[TM_ProductFilter alloc] init];
//        filter.maxPrice = 100000;
//        filter.minPrice =  -1;
//        filter.maxDiscount = 100000;
//        filter.minDiscount =  -1;
        filter.categoryId = categoryId;
        return filter;
    }
    return nil;
}
*/
+ (void)resetAttributeLoaded {
    attribsLoaded = false;
}
@end
