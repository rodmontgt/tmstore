//
//  CategoryInfo.m
//  eCommerceApp
//
//  Created by Rishabh Jain on 02/10/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import "CategoryInfo.h"
#import "ProductInfo.h"
#import "ProductImage.h"
#import "DataManager.h"
#import "AppUser.h"
static NSMutableArray* _allCategories = NULL;//ARRRAY OF CategoryInfo
static NSMutableArray* _rootCategories = NULL;//ARRRAY OF CategoryInfo
static BOOL _categoryVarifiedFromServer = false;

@implementation CategoryInfo

- (id)init {
    self = [super init];
    if (self) {
        self._parentId = -1;
        self._parent = nil;
        self._children = [[NSMutableArray alloc] init];
//        self._childrenProducts = [[NSMutableArray alloc] init];
        if (_allCategories == NULL) {
            _allCategories = [[NSMutableArray alloc] init];
        }
        //        if (_rootCategories == NULL) {
        //            _rootCategories = [[NSMutableArray alloc] init];
        //        }
        self._childRetrievedCount = 0;
        self._childMaximumCount = 0;
    }
    return self;
}
- (int)getChildRetrievedCount {
    self._childRetrievedCount = (int)[[ProductInfo getAllForCategory:self] count];
    return self._childRetrievedCount;
}
+ (void)refineMaxChildCount {
    CategoryInfo * tempCategory = nil;
    for (tempCategory in [CategoryInfo getAll]) {
        [tempCategory computeChildCount];
    }
    
    for (tempCategory in [CategoryInfo getAll]) {
        RLOG(@"Category-%@ count=%d strict=%d", tempCategory._name, tempCategory._count, tempCategory._childMaximumCount);
    }
}
- (void)computeChildCount{
//    CategoryInfo* tempCategory = nil;
//    int grandChildCount = 0;
//    for (tempCategory in [self getSubCategories]) {
//        grandChildCount += tempCategory._count;
//    }
//    self._childMaximumCount = self._count - grandChildCount;
    self._childMaximumCount = self._count;
}


- (BOOL)loadMoreProducts {
    int childRC = [self getChildRetrievedCount];
    if (self._childMaximumCount > childRC)
    {
        RLOG(@"\n=========================\n=========================\n=========================\n=========================\n=========================\n=========================\n=========================updateStuff=========================\n=========================\n=========================\n=========================\n=========================\n=========================\n=========================");
        int offset = self.pageCount * 25;
        if (offset != 0) {
            offset--;
        }
        if ([[Addons sharedManager] multiVendor_enable] &&
            [[Addons sharedManager] multiVendor_screen_type] == MULTIVENDOR_SCREEN_SELLER) {
            [[[DataManager sharedManager] tmDataDoctor] fetchProductDataForCategory_MultiVendor:@"" categoryId:self._id offset:offset productCount:25 success:^(id data) {
                self.pageCount = self.pageCount + 1;
            } failure:^(NSString *error) {
                
            }];
        } else if ([[Addons sharedManager] multiVendor] && [[[Addons sharedManager] multiVendor] isEnabled] && [[Addons sharedManager] multiVendor_screen_type] == MULTIVENDOR_SCREEN_PRODUCT){
            
            [[[DataManager sharedManager] tmDataDoctor] getProductsOfCategory:self._id offset:self.pageCount productLimit:25 success:^(id data) {
                self.pageCount = self.pageCount + 1;
                NSLog(@"fetchCategoryProductsFast:success");
            } failure:^(NSString *error) {
                NSLog(@"fetchCategoryProductsFast:failure");
            }];
            
//            [[[DataManager sharedManager] tmDataDoctor] fetchProductDataForCategory_MultiVendor:@"" categoryId:self._id offset:offset productCount:25 success:^(id data) {
//                self.pageCount = self.pageCount + 1;
//            } failure:^(NSString *error) {
//                
//            }];
            
        } else {
            [[[DataManager sharedManager] tmDataDoctor] fetchProductDataForCategory:nil categorySlug:self._slugOriginal offset:offset productCount:25 success:^(id data) {
                self.pageCount = self.pageCount + 1;
            } failure:^(NSString *error) {
                
            }];
        }
    }
    else
    {
     RLOG(@"No More Products.");
        return false;
    }
    return true;
}

+ (BOOL)areCategoriesVarified {
    return _categoryVarifiedFromServer;
}
+ (void)setCategoriesVarified{
    _categoryVarifiedFromServer = true;
}
- (BOOL)belongsToCategory:(CategoryInfo*)category{
    if (self == category) {
        return true;
    }
    NSMutableArray* childernCategories = category._children;
    CategoryInfo* temp_CategoryInfo = nil;
    for (temp_CategoryInfo in childernCategories) {
        if([temp_CategoryInfo belongsToCategory:category]){//DOUBT here category or self comes..
            return true;
        }
    }
    return false;
}
- (BOOL)hasParent{
    if(self._parent == NULL){
        return false;
    }else{
        return true;
    }
}
- (void)addChild:(CategoryInfo*)child{
    [self._children addObject:child];
//    self._childRetrievedCount = (int)[self._children count];
}
- (void)setParent:(CategoryInfo*)parent{
    if (self._parent != NULL) {
        [self._parent addChild:self];
    }
}

+ (CategoryInfo*)getWithSlug:(NSString*)slug{
    CategoryInfo* tempCategoryInfo = nil;
    for (tempCategoryInfo in _allCategories) {
        if ([tempCategoryInfo._slug isEqualToString:slug]) {
            return tempCategoryInfo;
        }
    }
    CategoryInfo* category = [[CategoryInfo alloc] init];
    category._slug = slug;
    [_allCategories addObject:category];
    return category;
}
+ (CategoryInfo*)getWithName:(NSString*)name{
    CategoryInfo* tempCategoryInfo = nil;
    for (tempCategoryInfo in _allCategories) {
        if ([tempCategoryInfo._name isEqualToString:name]) {
            return tempCategoryInfo;
        }
    }
    CategoryInfo* category = [[CategoryInfo alloc] init];
    category._name = name;
    [_allCategories addObject:category];
    return category;
}
+ (CategoryInfo*)getWithId:(int)_id{
    if (_id == 0) {
        return NULL;
    }
    CategoryInfo* tempCategoryInfo = nil;
    for (tempCategoryInfo in _allCategories) {
        if (tempCategoryInfo._id == _id) {
            return tempCategoryInfo;
        }
    }
    CategoryInfo* category = [[CategoryInfo alloc] init];
    category._id = _id;
    [_allCategories addObject:category];
    return category;
}
+ (NSMutableArray*)getAll{//RETURN ARRAY OF CategoryInfo
    return _allCategories;
}
+ (void)flushAll{
    [_allCategories removeAllObjects];//DOUBT WHERE MEMORY LEAK IS HERE OR NOT..
    [_rootCategories removeAllObjects];
    _allCategories = nil;
    _rootCategories = NULL;
}
+ (void)saveAll{
    //TODO
    //    ActiveAndroid.beginTransaction();
    //    try
    //    {
    //        for(int i=0; i<allCategories.size(); i++)
    //        {
    //            allCategories.get(i).save();
    //        }
    //        ActiveAndroid.setTransactionSuccessful();
    //    }
    //    finally
    //    {
    //        ActiveAndroid.endTransaction();
    //    }
}
- (NSMutableArray*)getSubCategories {//RETURN ARRAY OF CategoryInfo
    NSMutableArray* tempListParentCategories = [[NSMutableArray alloc] init];
    CategoryInfo* tempCategoryInfo = nil;
    for (tempCategoryInfo in _allCategories) {
        if (tempCategoryInfo._parent == self  && ![tempCategoryInfo isRestricted]) {
            [tempListParentCategories addObject:tempCategoryInfo];
        }
    }
    return tempListParentCategories;
}
+ (NSMutableArray*)getAllRootCategories {
    NSMutableArray* newRootCategories = [[NSMutableArray alloc] init];
    NSMutableArray* rc = [self getAllRootCategories0];
//    CategoryInfo* tempCategory = nil;
    for (CategoryInfo* cInfo in rc) {
        if (![cInfo isRestricted]) {
            [newRootCategories addObject:cInfo];
//            tempCategory = cInfo;
        }
    }
//    [newRootCategories addObject:tempCategory];
    return newRootCategories;
}
+ (NSMutableArray*)getAllRootCategories0 {//RETURN ARRAY OF CategoryInfo
    if (_allCategories == NULL) {
        RLOG(@"-- Categories are not initialized --");
        return NULL;
    }
    if (_rootCategories != NULL) {
        return _rootCategories;
    }
    
    _rootCategories = [[NSMutableArray alloc] init];
    CategoryInfo* tempCategoryInfo = nil;
    for (tempCategoryInfo in _allCategories) {
        if(tempCategoryInfo._parent == NULL && tempCategoryInfo._name /*&& ![tempCategoryInfo._name isEqualToString:@""]*/) {
            [_rootCategories addObject:tempCategoryInfo];
            [Utility setImage:[[UIImageView alloc] init] url:tempCategoryInfo._image resizeType:0 isLocal:false highPriority:true];
        }
    }
    return _rootCategories;
}
+ (void)printAll{
    CategoryInfo* tempCategoryInfo = nil;
    for (tempCategoryInfo in _allCategories) {
        RLOG(@"------- Category:[%d] -------",tempCategoryInfo._id);
        RLOG(@"--name\t%@",tempCategoryInfo._name);
        RLOG(@"--slug\t%@",tempCategoryInfo._slug);
        RLOG(@"--parent\t%@",tempCategoryInfo._parent);
        RLOG(@"--description\t%@",tempCategoryInfo._description);
        RLOG(@"--display\t%@",tempCategoryInfo._display);
        RLOG(@"--count\t%d",tempCategoryInfo._count);
        RLOG(@"------------------------------------------------------------");
    }
}
- (BOOL)hasKeyWord:(NSString*)key
{
    if ([self._name isEqualToString:key]) {
        return true;
    }
//    if ([self._name compare:key] == NSOrderedSame) {
//        return true;
//    }
    if([self hasParent])
    {
        return [self._parent hasKeyWord:key];
    }
    return false;
}
//+ (CategoryInfo*)getWithKeyWords:(NSArray*)keywords{
//    
//    if (keywords == nil || [keywords count] == 0) {
//        return NULL;
//    }
//    CategoryInfo* cInfo = nil;
//    for (cInfo in [CategoryInfo getAll]) {
//        BOOL foundMatch = false;
//        NSString *keyword = nil;
//        for (keyword in keywords) {
//            if (![cInfo hasKeyWord:keyword]) {
//                foundMatch = false;
//                break;
//            }
//            foundMatch = true;
//        }
//        if(foundMatch)
//            return cInfo;
//    }
//    return NULL;
//}
+ (NSMutableArray*)getAllSubCategories:(CategoryInfo*)cInfo tempListCategories:(NSMutableArray*)tempListCategories {
    if(tempListCategories == nil){
        tempListCategories = [[NSMutableArray alloc] init];
        [tempListCategories addObject:cInfo];
    }
    CategoryInfo* new_cInfo = nil;
    for (new_cInfo in _allCategories) {
        if (new_cInfo._parent == cInfo && ![new_cInfo isRestricted]) {
            tempListCategories = [CategoryInfo getAllSubCategories:new_cInfo tempListCategories:tempListCategories];
            [tempListCategories addObject:new_cInfo];
        }
    }
    return tempListCategories;
}
+ (void)refineCategories {
    
    if ([[DataManager sharedManager] isRefineCategoriesEnable]) {
        NSMutableArray* categoriesToDelete = [[NSMutableArray alloc] init];
        for (CategoryInfo* cObj in [CategoryInfo getAll]) {
            if (cObj._childMaximumCount <= 0 && (int)[[cObj getSubCategories] count] == 0) {
                [categoriesToDelete addObject:cObj];
            }
        }
        [_allCategories removeObjectsInArray:categoriesToDelete];
        [_rootCategories removeAllObjects];
        _rootCategories = NULL;
        [categoriesToDelete removeAllObjects];
        categoriesToDelete = NULL;
        [CategoryInfo getAllRootCategories];
    }
}
/*
+ (void)refineCategories {
    BOOL isDemoApp = false;
    if ([[DataManager sharedManager] appType] == APP_TYPE_DEMO) {
        isDemoApp = true;
    }
    if ([[DataManager sharedManager] isRefineCategoriesEnable] || isDemoApp) {
        NSMutableArray* categoriesToDelete = [[NSMutableArray alloc] init];
        for (CategoryInfo* cObj in [CategoryInfo getAll]) {
            if (cObj._childMaximumCount <= 0 && (int)[[cObj getSubCategories] count] <= 0) {
                [categoriesToDelete addObject:cObj];
            }
        }
        [_allCategories removeObjectsInArray:categoriesToDelete];
        [CategoryInfo getAllRootCategories];
        NSMutableArray* categoriesToDeleteFromRoot = [[NSMutableArray alloc] init];
        for (CategoryInfo* cObj in _rootCategories) {
            if (cObj._childMaximumCount <= 0 && (int)[[cObj getSubCategories] count] <= 0) {
                [categoriesToDeleteFromRoot addObject:cObj];
            }
        }
        [_rootCategories removeObjectsInArray:categoriesToDeleteFromRoot];
        
        if (0 && ([[DataManager sharedManager] isStepUpSingleChildrenCategoriesEnable] || isDemoApp)) {
            for (CategoryInfo* category in [CategoryInfo getAll]) {
                if (category!=nil && (int)[[category getSubCategories] count] == 1) {
                    CategoryInfo* c = [[category getSubCategories] objectAtIndex:0];
                    if (c != nil) {
                        [category._children removeObject:c];
                        c._parent = category._parent;
                        [self refineCategories];
                        return;
                        
                        //                        if (category._parent != nil) {
                        //                            [category._children removeObject:c];
                        //                            [category._parent._children removeObject:category];
                        //                            [category._parent addChild:c];
                        //                            c._parent = category._parent;
                        //                        }else{
                        //                            RLOG(@"this is root category");
                        //                            [_rootCategories removeObject:category];
                        //                            [_rootCategories addObject:c];
                        //                            c._parent = nil;
                        //                        }
                        //                        [self refineCategories];
                        //                        return;
                    }
                }
            }
        }
        
    }
    if ([[DataManager sharedManager] isAutoRefreshCategoryThumbEnable] || isDemoApp) {
        for (CategoryInfo* cObj in [CategoryInfo getAll]) {
            if (cObj._image == NULL || [cObj._image isEqualToString:@""]) {
                for (ProductInfo* pObj in [ProductInfo getAllForCategory:cObj]) {
                    if (pObj._images || (int)[pObj._images count] > 0) {
                        cObj._image = ((ProductImage*)(pObj._images[0]))._src;
                        break;
                    }
                }
            }
        }
        
        for (CategoryInfo* cObj in [CategoryInfo getAllRootCategories]) {
            [CategoryInfo recurrImgSearch:cObj];
        }
    }
}
*/
+ (void)stepUpSingleChildrenCategories {
    //    BOOL isDemoApp = [[DataManager sharedManager] appType] == APP_TYPE_DEMO ? true : false;

    if ([[DataManager sharedManager] isStepUpSingleChildrenCategoriesEnable]) {
        for (CategoryInfo* category in [CategoryInfo getAll]) {
            if (category != nil && (int)[[category getSubCategories] count] == 1) {
                CategoryInfo* c = [[category getSubCategories] objectAtIndex:0];
                if (c != nil) {
                    [category._children removeObject:c];
                    c._parent = category._parent;
                    [self refineCategories];
                    return;
                }
            }
        }
    }
}
+ (void)autoRefreshCategoryThumbs {
    BOOL isDemoApp = [[DataManager sharedManager] appType] == APP_TYPE_DEMO ? true : false;
    
    if ([[DataManager sharedManager] isAutoRefreshCategoryThumbEnable] || isDemoApp) {
        for (CategoryInfo* cObj in [CategoryInfo getAll]) {
            if (cObj._image == NULL || [cObj._image isEqualToString:@""]) {
                for (ProductInfo* pObj in [ProductInfo getAllForCategory:cObj]) {
                    if (pObj._images && (int)[pObj._images count] > 0) {
                        cObj._image = ((ProductImage*)(pObj._images[0]))._src;
                        break;
                    }
                }
            }
        }
        
        for (CategoryInfo* cObj in [CategoryInfo getAllRootCategories]) {
            [CategoryInfo recurrImgSearch:cObj];
        }
    }

}
+ (void)recurrImgSearch:(CategoryInfo*)cObj{
    NSMutableArray* imgArray = [[NSMutableArray alloc] init];
    if (cObj._image == NULL || [cObj._image isEqualToString:@""]) {
        for (CategoryInfo* ccObj in [cObj getSubCategories]) {
            if (ccObj._image == NULL || [ccObj._image isEqualToString:@""]){
                [CategoryInfo recurrImgSearch:ccObj];
            }else{
                [imgArray addObject:ccObj._image];
            }
        }
        if ([imgArray count] > 0) {
            cObj._image = [imgArray objectAtIndex:arc4random()%(int)[imgArray count]];
        }
    }
}
- (BOOL)isRestricted {
    BOOL isRes = false;
    {
        NSMutableArray* restricted_categories = [[Addons sharedManager] restricted_categories];
        if (restricted_categories && [restricted_categories count] > 0) {
            isRes = [restricted_categories containsObject:[NSString stringWithFormat:@"%d",self._id]];
        }
    }
    
    if (isRes == false && [AppUser isSignedIn] == false){
        NSMutableArray* restricted_categories = [[GuestConfig sharedInstance] restricted_categories];
        if (restricted_categories && [restricted_categories count] > 0) {
            isRes = [restricted_categories containsObject:[NSString stringWithFormat:@"%d",self._id]];
        }
    }
    
    return isRes;
}
+ (BOOL)isProductBelongsToRestrictedCategories:(id)productObject {
    ProductInfo* pInfo = (ProductInfo*)productObject;
    BOOL isRestricted = true;
    if (pInfo.isRestrictionChecked == false) {
        if(pInfo._categories && [pInfo._categories count] > 0){
            for (CategoryInfo* cInfo in pInfo._categories) {
                if([cInfo isRestricted] == false){
                    isRestricted = false;
                    break;
                }
            }
        } else {
            isRestricted = false;
        }
        pInfo.isRestricted = isRestricted;
        pInfo.isRestrictionChecked = true;
    }
    return pInfo.isRestricted;
}
@end
