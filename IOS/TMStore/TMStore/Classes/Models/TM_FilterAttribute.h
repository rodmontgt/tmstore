//
//  TM_FilterAttribute.h
//  TMStore
//
//  Created by Rishabh Jain on 16/05/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TM_FilterAttributeOption.h"
#import "Attribute.h"
@interface TM_FilterAttribute : NSObject

@property NSString* attribute;
@property NSString* query_type;
@property NSString* title;
@property NSString* display_type;
//@property int position;
//@property BOOL visible;
//@property BOOL variation;


- (BOOL)isSubsetOf:(TM_FilterAttribute*)other;
- (BOOL)isSubsetOfAttribute:(Attribute*)other;
- (id)init;
- (TM_FilterAttributeOption*)getWithSlug:(NSString*) slug;
- (TM_FilterAttributeOption*)getWithName:(NSString*) name;
- (BOOL)hasOption:(TM_FilterAttributeOption*)otherOption ;
- (BOOL)removeOption:(TM_FilterAttributeOption*)optionToRemove;
- (BOOL)hasOptionStr:(NSString*)optionValue;
- (Attribute*)getProductAttribute;
- (NSMutableArray*)getXYZOptions;
- (void)sortOptions;


@end
