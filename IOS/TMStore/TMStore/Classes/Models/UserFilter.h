//
//  UserFilter.h
//  TMStore
//
//  Created by Rishabh Jain on 16/05/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TM_FilterAttribute.h"

@interface UserFilter : NSObject
@property BOOL chkStock;
@property float minPrice;
@property float maxPrice;
@property NSMutableArray* attributes;//Array of TM_FilterAttribute
@property NSString* cat_slug;
@property int sort_type; // = "";
@property BOOL filterModified;
@property BOOL priceModified;

@property BOOL on_sale;
@property float locationFilter_myLoc_lat;
@property float locationFilter_myLoc_lng;
@property NSString* locationFilter_myLoc_unit;
@property NSString* locationFilter_myLoc_radius;

- (id)init;
- (id)initWithParameter:(NSString*)cat_slug minPrice:(float)minPrice maxPrice:(float)maxPrice attributes:(NSMutableArray*)attributes chkStock:(BOOL)chkStock;
- (BOOL)isFilterModified;
- (void)setCheckSale:(BOOL)on_sale;
- (void)setMinPrice:(float)price;
- (void)setMaxPrice:(float)price;
-(BOOL)modifiedMaxORminPrice;
- (void)setSortOrder:(int)sort_type;
- (void)addAttribute:(TM_FilterAttribute*)attribute;
- (void)addAttributeOption:(TM_FilterAttribute*)attribute option:(TM_FilterAttributeOption*)option;
- (void)removeAttributeOption:(TM_FilterAttribute*)attribute option:(TM_FilterAttributeOption*)option;
- (BOOL)hasOption:(TM_FilterAttribute*)attribute option:(TM_FilterAttributeOption*)option;
- (void)removeAttributes:(NSMutableArray*)attributesToRemove;
- (NSMutableArray*)getAttributes;
- (float)getMaxPrice;
- (float)getMinPrice;
- (BOOL)isChkStock;
- (BOOL)isChkStockTrue;
- (BOOL)shouldCheckOnSale;
- (BOOL)shouldCheckOnSaleTrue;
- (NSString*)getCatSlug;
- (int)getSortOrder;
- (TM_FilterAttribute*)getOrAddAttributeByNameOf:(TM_FilterAttribute*)other;
//- (TM_FilterAttribute*)getAttributeWithName:(NSString*)name;
- (TM_FilterAttribute*)hasAttribute:(TM_FilterAttribute*)other;
- (NSString*)getFilterString;
+ (id)sharedInstance;
-(void)resetFilterdata;
-(void)maxpriceAndMinpriceReset;
@end
