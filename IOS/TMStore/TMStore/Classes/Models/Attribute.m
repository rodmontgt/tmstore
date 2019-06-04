//
//  Attribute.m
//  eCommerceApp
//
//  Created by Rishabh Jain on 01/10/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import "Attribute.h"
#import "Variables.h"
#import "Utility.h"
@implementation Attribute
//static NSMutableDictionary* additional_values = NULL;

- (id)init {
    self = [super init];
    if (self) {
        // initialize instance variables here
        
        self._name = @"";
        self._slug = @"";
        self._position = 0;
        self._variation = NO;
        self._visible = NO;
        self._options = [[NSMutableArray alloc] init];
        self._taxo = @"";
//        self.additional_price = 0.0f;
        self.additional_values = [[NSMutableDictionary alloc] init];
    }
    return self;
}
- (VariationAttribute*)getVariationAttribute:(int)optionIndex {
    VariationAttribute * variationAttribute = [[VariationAttribute alloc] init];
    variationAttribute.name = self._name;
    variationAttribute.slug = self._slug;
    if (self._options && [self._options count] > 0) {
        variationAttribute.value = [self._options objectAtIndex:optionIndex];
    }
    return variationAttribute;
}
- (BOOL)hasOptionFilterAttribute:(TM_FilterAttributeOption*)optionValue{
    for (NSString* option in self._options) {
        if ([Utility compareAttributeNames:option name2:optionValue.name])
        {
            return true;
        }
    }
    return false;
}
- (BOOL)isSubsetOf:(Attribute*)other {
    if (other == nil)
        return false;
    
    if (![Utility compareAttributeNames:self._name name2:other._name])
    {
        return false;
    }
    
    if ([self._options count] > [other._options count]) {
        return false;
    }
    
    for (NSString* option in self._options) {
        for (NSString* option1 in other._options) {
            if ([option1 isEqualToString:option]) {
                return false;
            }
        }
    }
    return true;
}

- (void)addAdditionalPrice:(NSString*)option value:(float)value {
//    option = Helper.toSlug(option);
    if (_additional_values == nil) {
        _additional_values = [[NSMutableDictionary alloc] init];
    }
    [_additional_values setValue:[NSNumber numberWithFloat:value] forKey:option];
}
- (float)getAdditionalPrice:(NSString*)option {
//    option = Helper.toSlug(option);
    if (_additional_values != nil && IS_NOT_NULL(_additional_values, option))
        return [[_additional_values valueForKey:option] floatValue];
    
    return 0;
}
- (NSMutableArray*)getOptions {
    if ([[Addons sharedManager] load_extra_attrib_data]) {
        NSMutableArray* returnValues = [[NSMutableArray alloc] init];
        for (NSString* optionString in self._options) {
            NSString* returnString = [NSString stringWithFormat:@"%@", optionString];
            float additionalPrice = [self getAdditionalPrice:optionString];
            if (additionalPrice > 0) {
                returnString = [returnString stringByAppendingString:[NSString stringWithFormat:@" (+ %@)", [[Utility sharedManager] convertToString:additionalPrice isCurrency:true]]];
            } else if (additionalPrice < 0) {
                returnString = [returnString stringByAppendingString:[NSString stringWithFormat:@" (- %@)", [[Utility sharedManager] convertToString:additionalPrice isCurrency:true]]];
            }
            [returnValues addObject:returnString];
        }
        return returnValues;
    }
    /*
    NSMutableArray* returnValues = [[NSMutableArray alloc] init];
    for (NSString* optionString in self._options) {
        NSString* returnString = [Utility getStringIfFormatted:[NSString stringWithFormat:@"%@", optionString]];
        [returnValues addObject:returnString];
    }
    return returnValues;
    */
    return self._options;
}


@end
@implementation BasicAttribute

- (id)init {
    self = [super init];
    if (self) {
        _attributeId = -1;
        _attributeName = @"";
        _attributeValue = @"";
        _attributeSlug = @"";
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.attributeName = [decoder decodeObjectForKey:@"#1"];
        self.attributeValue = [decoder decodeObjectForKey:@"#2"];
        self.attributeId = [decoder decodeIntForKey:@"#3"];
        self.attributeSlug = [decoder decodeObjectForKey:@"#4"];
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.attributeName forKey:@"#1"];
    [encoder encodeObject:self.attributeValue forKey:@"#2"];
    [encoder encodeInt:self.attributeId forKey:@"#3"];
    [encoder encodeObject:self.attributeSlug forKey:@"#4"];

}

@end

static NSMutableArray* allSZAttributes = nil;
static NSMutableArray* allSZAttributesOptions = nil;
@implementation SZAttribute
- (id)init {
    self = [super init];
    if (self) {
        self.attributeId = -1;
        self.name = @"";
        self.slug = @"";
        self.type = @"";
        self.order_by = @"";
        self.has_archives = false;
        
        self.product_attribute_term = [[NSMutableArray alloc] init];
        [[SZAttribute getAllSZAttributes] addObject:self];
    }
    return self;
}
+ (NSMutableArray*)getAllSZAttributes {
    if (allSZAttributes == nil) {
        allSZAttributes = [[NSMutableArray alloc] init];
    }
    return allSZAttributes;
}
+ (NSMutableArray*)getAllSZAttributesNames {
    NSMutableArray* tempAttributesNames = [[NSMutableArray alloc] init];
    NSMutableArray* tempAttributes = [SZAttribute getAllSZAttributes];
    for (SZAttribute* szAtt in tempAttributes) {
        [tempAttributesNames addObject:szAtt.name];
    }
    return tempAttributesNames;
}
- (NSMutableArray*)getSZAttributeOptionNames {
    NSMutableArray* tempOptionNames = [[NSMutableArray alloc] init];
    if (self.product_attribute_term) {
        for (SZAttributeOption* szAttOption in self.product_attribute_term) {
            [tempOptionNames addObject:szAttOption.name];
        }
    }
    return tempOptionNames;
}
+ (SZAttribute*)getSZAttributeByName:(NSString*)name {
    NSMutableArray* tempAttributes = [SZAttribute getAllSZAttributes];
    for (SZAttribute* szAtt in tempAttributes) {
        if ([szAtt.name isEqualToString:name]) {
            return szAtt;
        }
    }
    return nil;
}

+ (SZAttribute*)getSZAttributeBySlug:(NSString*)slug {
    NSMutableArray* tempAttributes = [SZAttribute getAllSZAttributes];
    for (SZAttribute* szAtt in tempAttributes) {
        if ([szAtt.slug isEqualToString:slug]) {
            return szAtt;
        }
    }
    return nil;
}

- (SZAttributeOption*)getSZAttributeOptionByName:(NSString*)name {
    if (self.product_attribute_term) {
        for (SZAttributeOption* szAttOption in self.product_attribute_term) {
            if ([szAttOption.name isEqualToString:name]) {
                return szAttOption;
            }
        }
    }
    return nil;
}
+ (SZAttribute*)getSZAttributeById:(int)attributeId {
    NSMutableArray* tempAttributes = [SZAttribute getAllSZAttributes];
    for (SZAttribute* szAtt in tempAttributes) {
        if (szAtt.attributeId == attributeId) {
            return szAtt;
        }
    }
    SZAttribute* szAtt = [[SZAttribute alloc] init];
    return szAtt;
}
+ (SZAttribute*)hasSZAttributeById:(int)attributeId  {
    NSMutableArray* tempAttributes = [SZAttribute getAllSZAttributes];
    for (SZAttribute* szAtt in tempAttributes) {
        if (szAtt.attributeId == attributeId) {
            return szAtt;
        }
    }
    return nil;
}
@end
@implementation SZAttributeOption
- (id)init {
    self = [super init];
    if (self) {
        self.optionId = -1;
        self.name = @"";
        self.slug = @"";
        self.count = 0;
        [[SZAttributeOption getAllSZAttributeOptions] addObject:self];
    }
    return self;
}
+ (NSMutableArray*)getAllSZAttributeOptions {
    if (allSZAttributesOptions == nil) {
        allSZAttributesOptions = [[NSMutableArray alloc] init];
    }
    return allSZAttributesOptions;
}
+ (SZAttributeOption*)getSZAttributeOptionById:(int)optionId {
    NSMutableArray* tempAttributeOptions = [SZAttributeOption getAllSZAttributeOptions];
    for (SZAttributeOption* szAttOption in tempAttributeOptions) {
        if (szAttOption.optionId == optionId) {
            return szAttOption;
        }
    }
    SZAttributeOption* szAttOp = [[SZAttributeOption alloc] init];
    return szAttOp;
}
@end


@implementation SelSZAtt
static NSMutableArray* allSelSZAtt = nil;
- (id)init {
    self = [super init];
    if (self) {
        self.options = [[NSMutableArray alloc] init];
        self.attribute = nil;
        [[SelSZAtt getAllSelSZAtt] addObject:self];
    }
    return self;
}
+ (NSMutableArray*)getAllSelSZAtt {
    if (allSelSZAtt == nil) {
        allSelSZAtt = [[NSMutableArray alloc] init];
    }
    return allSelSZAtt;
}
+ (void)resetAllSelSZAtt {
    [[SelSZAtt getAllSelSZAtt] removeAllObjects];
}
+ (SelSZAtt*)getSelSZAttForSZAttribute:(SZAttribute*)szAttribute {
    NSMutableArray* allItems = [SelSZAtt getAllSelSZAtt];
    for (SelSZAtt* obj in allItems) {
        if (obj.attribute.attributeId == szAttribute.attributeId) {
            return obj;
        }
    }
    
    SelSZAtt* newObj = [[SelSZAtt alloc] init];
    newObj.attribute = szAttribute;
    return newObj;
}

+ (void)remanageAllSelSZAtt {
    NSMutableArray* allItems = [SelSZAtt getAllSelSZAtt];
    NSMutableArray* itemsToRemove = [[NSMutableArray alloc] init];
    for (SelSZAtt* obj in allItems) {
        obj.attribute = [SZAttribute hasSZAttributeById:obj.attribute.attributeId];
        if (obj.attribute) {
            NSMutableArray* newOpts = [[NSMutableArray alloc] init];
            for (SZAttributeOption* opt in obj.options) {
                SZAttributeOption* newOpt = [SZAttributeOption getSZAttributeOptionById:opt.optionId];
                [newOpts addObject:newOpt];
            }
            obj.options = newOpts;
        } else {
            [itemsToRemove addObject:obj];
        }
    }
    [allItems removeObjectsInArray:itemsToRemove];
}

- (BOOL)containsAttributeOption:(SZAttributeOption*)szAttributeOption {
    if (self.options) {
        for (SZAttributeOption* szAttOption in self.options) {
            if ((szAttOption.name && [szAttOption.name caseInsensitiveCompare:szAttributeOption.name] == NSOrderedSame)
                && (szAttOption.slug && [szAttOption.slug caseInsensitiveCompare:szAttributeOption.slug] == NSOrderedSame)) {
                return true;
            }
        }
    }
    return false;}

- (BOOL)removeAttributeOption:(SZAttributeOption*)szAttributeOption {
    if (self.options) {
        for (SZAttributeOption* szAttOption in self.options) {
            if ((szAttOption.name && [szAttOption.name caseInsensitiveCompare:szAttributeOption.name] == NSOrderedSame)
                && (szAttOption.slug && [szAttOption.slug caseInsensitiveCompare:szAttributeOption.slug] == NSOrderedSame)) {
                [self.options removeObject:szAttOption];
                return true;
            }
        }
    }
    return false;
}

@end
