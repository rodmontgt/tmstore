//
//  TM_FilterAttribute.m
//  TMStore
//
//  Created by Rishabh Jain on 16/05/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import "TM_FilterAttribute.h"
#import "Utility.h"
@interface TM_FilterAttribute()
@property NSMutableArray* options;//Array of TM_FilterAttributeOption
@end
@implementation TM_FilterAttribute
- (NSMutableArray*)getXYZOptions {
    return _options;
}
- (void)sortOptions {
    if (_options) {
        NSMutableArray* sortedOptions = [[NSMutableArray alloc] init];
        NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
        NSArray *sortedArray = [_options sortedArrayUsingDescriptors:sortDescriptors];
        sortedOptions = [[NSMutableArray alloc] initWithArray:sortedArray];
        _options = sortedOptions;
    }
}
- (id)init {
    self = [super init];
    if (self) {
        _attribute = @"";
        _query_type =  @"";
        _title =  @"";
        _display_type =  @"";
        _options = [[NSMutableArray alloc] init];
    }
    return self;
}
- (TM_FilterAttributeOption*)getWithSlug:(NSString*)slug {
    for (TM_FilterAttributeOption* option in _options) {
        if ([Utility compareAttributeNames:option.slug name2:slug]) {
            return option;
        }
    }
    return nil;
}
- (TM_FilterAttributeOption*)getWithName:(NSString*)name {
    for (TM_FilterAttributeOption* option in _options) {
        if ([Utility compareAttributeNames:option.name name2:name]) {
            return option;
        }
    }
    return nil;
}
- (BOOL)isSubsetOf:(TM_FilterAttribute*)other {
    if (other == nil)
        return false;
    
    if (![Utility compareAttributeNames:self.attribute name2:other.attribute]) {
        return false;
    }

    if ((int)[self.options count] > (int)[other.options count]) {
        return false;
    }
    
    for (TM_FilterAttributeOption* option in _options) {
        if (![other hasOption:option]) {
            return false;
        }
    }
    return true;
}
- (BOOL)hasOption:(TM_FilterAttributeOption*)otherOption {
    for (TM_FilterAttributeOption* option in _options) {
        if ([option.slug isEqualToString:otherOption.slug]) {
            return true;
        }
    }
    return false;
}
- (BOOL)isSubsetOfAttribute:(Attribute*)other {
    if (other == nil)
        return false;
    if (![Utility compareAttributeNames:self.attribute name2:other._name]) {
        return false;
    }
    
    if ((int)[self.options count] > (int)[other._options count]) {
        return false;
    }
    
    for (TM_FilterAttributeOption* option in _options) {
        if (![other hasOptionFilterAttribute:option]) {
            return false;
        }
    }
    return true;
}
- (BOOL)removeOption:(TM_FilterAttributeOption*)optionToRemove {
    for (TM_FilterAttributeOption* option in _options) {
        if ([option.slug isEqualToString:optionToRemove.slug]) {
            [_options removeObject:option];
            return true;
        }
    }
    return false;
}
- (BOOL)hasOptionStr:(NSString*)optionValue {
    for (TM_FilterAttributeOption* option in _options) {
        if ([Utility compareAttributeNames:option.name name2:optionValue]) {
            return true;
        }
    }
    return false;
}
- (Attribute*)getProductAttribute {
    Attribute* attribute = [[Attribute alloc] init];
    attribute._name = _attribute;
    if ([self.options count] != 0) {
        attribute._slug = ((TM_FilterAttributeOption*)[self.options objectAtIndex:0]).slug;
        attribute._taxo = ((TM_FilterAttributeOption*)[self.options objectAtIndex:0]).taxo;
    }else{
        attribute._slug = self.attribute;
        attribute._taxo = @"";
    }
    
    for (TM_FilterAttributeOption* option in _options) {
        [attribute._options addObject:option.name];
    }
    return attribute;
}
@end
