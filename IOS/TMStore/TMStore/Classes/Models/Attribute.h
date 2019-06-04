//
//  Attribute.h
//  eCommerceApp
//
//  Created by Rishabh Jain on 01/10/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VariationAttribute.h"
#import "TM_FilterAttributeOption.h"
@interface Attribute : NSObject

@property NSString *_name;
@property NSString *_slug;
@property int _position;
@property BOOL _visible;
@property BOOL _variation;
@property NSMutableArray *_options;//Array of NSString
@property NSString* _taxo;
//@property float additional_price;
@property NSDictionary* additional_values;
- (id)init;
- (VariationAttribute*)getVariationAttribute:(int)optionIndex;
- (BOOL)hasOptionFilterAttribute:(TM_FilterAttributeOption*)optionValue;
- (BOOL)isSubsetOf:(Attribute*)other;
- (void)addAdditionalPrice:(NSString*)option value:(float)value;
- (float)getAdditionalPrice:(NSString*)option;
- (NSMutableArray*)getOptions;
@end

@interface BasicAttribute : NSObject <NSCoding>

@property int attributeId;
@property NSString* attributeValue;
@property NSString* attributeName;
@property NSString* attributeSlug;
@end



@interface SZAttributeOption : NSObject
@property int optionId;
@property NSString* name;
@property NSString* slug;
@property int count;
+ (SZAttributeOption*)getSZAttributeOptionById:(int)optionId;
+ (NSMutableArray*)getAllSZAttributeOptions;
@end

@interface SZAttribute : NSObject
@property int attributeId;
@property NSString* name;
@property NSString* slug;
@property NSString* type;
@property NSString* order_by;
@property BOOL has_archives;
@property NSMutableArray* product_attribute_term;


+ (NSMutableArray*)getAllSZAttributes;
+ (NSMutableArray*)getAllSZAttributesNames;
- (NSMutableArray*)getSZAttributeOptionNames;
+ (SZAttribute*)getSZAttributeByName:(NSString*)name;
+ (SZAttribute*)getSZAttributeBySlug:(NSString*)slug;
- (SZAttributeOption*)getSZAttributeOptionByName:(NSString*)name;
+ (SZAttribute*)getSZAttributeById:(int)attributeId;
+ (SZAttribute*)hasSZAttributeById:(int)attributeId;
@end


@interface SelSZAtt : NSObject
@property NSMutableArray* options;//Array of SZAttributeOption
@property SZAttribute* attribute;
+ (NSMutableArray*)getAllSelSZAtt;
+ (void)resetAllSelSZAtt;
+ (SelSZAtt*)getSelSZAttForSZAttribute:(SZAttribute*)szAttribute;
+ (void)remanageAllSelSZAtt;
-(BOOL)containsAttributeOption:(SZAttributeOption*)szAttributeOption;
- (BOOL)removeAttributeOption:(SZAttributeOption*)szAttributeOption;

@end

