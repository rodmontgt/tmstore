//
//  UserFilter.m
//  TMStore
//
//  Created by Rishabh Jain on 16/05/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import "UserFilter.h"
#import "Utility.h"

@interface UserFilter() {

}
@end
@implementation UserFilter
- (id)init {
    self = [super init];
    if (self) {
        self.chkStock = false;
        self.attributes = [[NSMutableArray alloc] init];
        self.cat_slug = @"";
        self.filterModified = false;
        self.on_sale = false;
        self.priceModified = false;
    }
    return self;
}
- (id)initWithParameter:(NSString*)cat_slug minPrice:(float)minPrice maxPrice:(float)maxPrice attributes:(NSMutableArray*)attributes chkStock:(BOOL)chkStock {
    self = [super init];
    if (self) {
        self.cat_slug = cat_slug;
        self.minPrice = minPrice;
        self.maxPrice = maxPrice;
        self.chkStock = chkStock;
        self.attributes = attributes;
    }
    return self;
}
+(id)sharedInstance{
    static UserFilter *sharedInstanceObj=nil;
    @synchronized(self) {
        if (sharedInstanceObj == nil)
            sharedInstanceObj = [[self alloc] init];
    }
    return sharedInstanceObj;
 }
- (BOOL)isFilterModified {
    return _filterModified;
}
-(void)resetFilterdata{
    self.chkStock = false;
    self.attributes = [[NSMutableArray alloc] init];
    self.cat_slug = @"";
    self.filterModified = false;
    self.on_sale = false;
    self.priceModified = false;
    self.sort_type = 0;
    
}

- (void)setCheckSale:(BOOL)on_sale {
    _on_sale = on_sale;
}
- (void)setMinPrice:(float)price {
    
    _minPrice = price;
    _priceModified = true;
    //this.filterModified = true;
}
- (void)setMaxPrice:(float)price {
    
    _maxPrice = price;
    _priceModified=true;
    //this.filterModified = true;
}
- (void)setSortOrder:(int)sort_type {
    _sort_type = sort_type;
    //this.filterModified = true;
}
- (void)addAttribute:(TM_FilterAttribute*)attribute {
    [_attributes addObject:attribute];
}
- (void)addAttributeOption:(TM_FilterAttribute*)attribute option:(TM_FilterAttributeOption*) option {
    if (![attribute hasOption:option]) {
        [[attribute getXYZOptions] addObject:option];
    }
    _filterModified = true;
}
- (void)removeAttributeOption:(TM_FilterAttribute*)attribute option:(TM_FilterAttributeOption*)option {
    [attribute removeOption:option];
    if ([[attribute getXYZOptions] count] == 0) {
        [_attributes removeObject:attribute];
    }
    _filterModified = true;
}
- (void)removeAttributes:(NSMutableArray*)attributesToRemove {
    [_attributes removeObjectsInArray:attributesToRemove];
}
//Getters
- (NSMutableArray*)getAttributes {
    return _attributes;
}
- (float)getMaxPrice {
    return _maxPrice;
}
- (float)getMinPrice {
    return _minPrice;
}
- (BOOL)isChkStock {
    return _chkStock = false;
}
- (BOOL)isChkStockTrue {
    return _chkStock = true;
}
- (BOOL)shouldCheckOnSale {
    return _on_sale = false;
}
- (BOOL)shouldCheckOnSaleTrue {
    return _on_sale = true;
}
-(BOOL)modifiedMaxORminPrice{
    return _priceModified;
}
- (NSString*)getCatSlug {
    return _cat_slug;
}
- (int)getSortOrder {
    RLOG(@"  _sort_type  %d",_sort_type);
    return _sort_type;
}
- (TM_FilterAttribute*)getOrAddAttributeByNameOf:(TM_FilterAttribute*)other {
    if (_attributes == nil) {
        _attributes = [[NSMutableArray alloc] init];
    }
    
    for (TM_FilterAttribute* attribute in _attributes) {
        if ([Utility compareAttributeNames:attribute.attribute name2:other.attribute]) {
            return attribute;
        }
    }
    
    TM_FilterAttribute* attribute =  [[TM_FilterAttribute alloc] init];
    attribute.attribute = other.attribute;
    attribute.query_type = other.query_type;
    [_attributes addObject:attribute];
    
    return attribute;
}
//- (TM_FilterAttribute*)getAttributeWithName:(NSString*) name {
//    for (TM_FilterAttribute* attribute in _attributes) {
//        if ([Utility compareAttributeNames:attribute.attribute name2:name]) {
//            return attribute;
//        }
//    }
//    return nil;
//}
- (TM_FilterAttribute*)hasAttribute:(TM_FilterAttribute*)other {
    for (TM_FilterAttribute* attribute in _attributes) {
        if ([Utility compareAttributeNames:attribute.attribute name2:other.attribute]) {
            return attribute;
        }
    }
    return nil;
}
- (BOOL)hasOption:(TM_FilterAttribute*)attribute option:(TM_FilterAttributeOption*)option {
    return [attribute hasOption:option];
}
- (NSString*)getFilterString {
    NSString* filterString = @"";
    for (TM_FilterAttribute* attribute in _attributes) {
        NSMutableArray* attributeOptions = [attribute getXYZOptions];
        for (TM_FilterAttributeOption* option in attributeOptions) {
            filterString = [filterString stringByAppendingString:[NSString stringWithFormat:@"%@ | ", option.name]];
        }
    }
    
    //        if (sortOrder.length() > 0) {
    //            filterString += "Sort by: " + sortOrder + " | ";
    //        }
    
    //        filterString += "Max Price: " + maxPrice + " | ";
    //        filterString += "Min Price: " + minPrice + " | ";
    
    if ([filterString length] > 3) {
        filterString = [filterString substringWithRange:NSMakeRange(0, [filterString length] - 3)];
    }
    
    return filterString;
}

//    @Override
//    public String toString() {
//        return "ReadWriteObject [minPrice=" + minPrice + ", maxPrice=" + maxPrice + ", chkStock=" + chkStock + "]";
//    }
@end
