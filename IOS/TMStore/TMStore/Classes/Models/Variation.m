//
//  Variation.m
//  eCommerceApp
//
//  Created by Rishabh Jain on 01/10/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import "Variation.h"
#import "VariationAttribute.h"
#import "Attribute.h"
#import "Utility.h"

@implementation Variation

- (id)init{
    self = [super init];
    if (self) {
        self._id = 0;
        self._stock_quantity = 0;
        self._download_limit = 0;
        self._download_expiry = 0;
        
        self._created_at = NULL;
        self._updated_at = NULL;
        self._permalink = @"";
        self._sku = @"";
        self._tax_status = @"";
        self._tax_class = @"";
        self._shipping_class = @"";
        self._shipping_class_id = @"";

        self.price_clone = 0;
        self.sale_price_clone = 0;
        self.regular_price_clone = 0;

        self._price = 0;
        self._regular_price = 0;
        self._sale_price = 0;
        
        self._downloadable = NO;
        self._virtual = NO;
        self._taxable = NO;
        self._managing_stock = NO;
        self._in_stock = NO;
        self._backordered = NO;
        self._purchaseable = NO;
        self._visible = NO;
        self._on_sale = NO;
        
        self._dimensions = [[Dimension alloc] init];
        self._images = [[NSMutableArray alloc] init];
        self._attributes = [[NSMutableArray alloc] init];
        self._downloads = [[NSMutableArray alloc] init];
        self._weight = 0.0f;
        self.rewardPoints = -1;
    }
    return self;
}

- (void)clonePrice{
    self.price_clone = self._price;
    self.regular_price_clone = self._regular_price;
    self.sale_price_clone = self._sale_price;

}
- (BOOL)equals:(Variation*)other {
    if (self._attributes == NULL && other._attributes == NULL) {
        return true;
    }
    if (self._attributes != NULL && other._attributes != NULL) {
        if ([self._attributes count] == [other._attributes count]) {
            for (VariationAttribute* li1Long in self._attributes) {
                BOOL isEqual = false;
                for (VariationAttribute* li2Long in other._attributes) {
                    if ([li1Long isEqual:li2Long]) {
                        isEqual = true;
                        break;
                    }
                }
            }
        }else{
            return true;
        }
    }else{
        return false;
    }
    return true;
}
/*
 - (BOOL)compareAttributes:(NSMutableArray*)other_attibutes {
 if (self._attributes == NULL && other_attibutes == NULL) {
 return true;
 }
 if (self._attributes != NULL && other_attibutes != NULL) {
 if([self._attributes count] == [other_attibutes count]) {
 for(Attribute *li1Long in self._attributes) {
 BOOL isEqual = false;
 for(VariationAttribute *li2Long in other_attibutes) {
 
 NSString* li1Name = [[NSString stringWithFormat:@"%@",li1Long._name] capitalizedString];
 NSString* li1Value = [[NSString stringWithFormat:@"%@",[li1Long._options objectAtIndex:0]] capitalizedString];
 
 NSString* li2Name = [[NSString stringWithFormat:@"%@",li2Long.name] capitalizedString];
 NSString* li2Value = [[NSString stringWithFormat:@"%@",li2Long.value] capitalizedString];
 
 if ([li1Name isEqualToString:li2Name] && ([li1Value isEqualToString:li2Value] || [li1Long._slug isEqualToString:@"abcdefghijklmnopqrstuvwxyz"])) {
 [li1Long._options removeAllObjects];
 [li1Long._options addObject:li2Value];
 isEqual = true;
 break;
 }
 
 }
 if(!isEqual) return false;
 }
 }else{
 //            return false;
 
 if ((int)[self._attributes count] < (int)[other_attibutes count]) {
 int needToMatch = (int)[other_attibutes count] - (int)[self._attributes count];
 int matchCount = 0;
 for(VariationAttribute *userAttribute in other_attibutes) {
 NSString* nameUserAttribute = [[NSString stringWithFormat:@"%@",userAttribute.name] capitalizedString];
 NSString* valUserAttribute = [[NSString stringWithFormat:@"%@",userAttribute.value] capitalizedString];
 for(Attribute *varAttribute in self._attributes) {
 NSString* nameVarAttribute = [[NSString stringWithFormat:@"%@",varAttribute._name] capitalizedString];
 NSString* valVarAttribute = [[NSString stringWithFormat:@"%@",[varAttribute._options objectAtIndex:0]] capitalizedString];
 if ([nameUserAttribute isEqualToString:nameVarAttribute] && [valUserAttribute isEqualToString:valVarAttribute]){
 matchCount++;
 }
 }
 }
 if (needToMatch == matchCount) {
 for(VariationAttribute *userAttribute in other_attibutes) {
 NSString* nameUserAttribute = [[NSString stringWithFormat:@"%@",userAttribute.name] capitalizedString];
 NSString* valUserAttribute = [[NSString stringWithFormat:@"%@",userAttribute.value] capitalizedString];
 BOOL isUserAttributeExists = false;
 for(Attribute *varAttribute in self._attributes) {
 NSString* nameVarAttribute = [[NSString stringWithFormat:@"%@",varAttribute._name] capitalizedString];
 if ([nameUserAttribute isEqualToString:nameVarAttribute]){
 isUserAttributeExists = true;
 break;
 }
 }
 if (isUserAttributeExists == false) {
 Attribute* attribute = [[Attribute alloc] init];
 attribute._name = nameUserAttribute;
 [attribute._options addObject:valUserAttribute] ;
 //                        attribute._position = GET_VALUE_INT(mtempDict, @"position");
 attribute._slug = @"abcdefghijklmnopqrstuvwxyz";
 //                        attribute._variation = GET_VALUE_BOOL(mtempDict, @"variation");
 //                        attribute._visible = GET_VALUE_BOOL(mtempDict, @"visible");
 [self._attributes addObject:attribute];
 }
 }
 return true;
 }
 
 }
 return false;
 
 }
 }else{
 return false;
 }
 return true;
 
 }

 */
- (BOOL)compareAttributes:(NSMutableArray*)other_attibutes {
    if (self._attributes == nil && other_attibutes == nil)
        return true;
    if (self._attributes != nil && other_attibutes != nil) {
        for (VariationAttribute* attribute2 in other_attibutes) {
            VariationAttribute* attribute1 = [self getWithName:attribute2.name];
            if (attribute1 == nil) {
                continue;
            }
            if([[Addons sharedManager] auto_generate_variations]) {
                
            }else {
                if (attribute1.value == nil || [attribute1.value isEqualToString:@""]) {
                    continue;
                }
            }
            if (![Utility compareAttributeNames:attribute1.value name2:attribute2.value]) {
                RLOG(@"attribute1.value = %@", attribute1.value);
                RLOG(@"attribute2.value = %@", attribute2.value);
                return false;
            }
        }
    } else {
        return false;
    }
    return true;
}


/*
- (BOOL)compareAttributes:(NSMutableArray*)other_attibutes {
    if (self._attributes == NULL && other_attibutes == NULL) {
        return true;
    }
    if (self._attributes != NULL && other_attibutes != NULL) {
        if([self._attributes count] == [other_attibutes count]) {
            for(VariationAttribute *li1Long in self._attributes) {
                BOOL isEqual = false;
                for(VariationAttribute *li2Long in other_attibutes) {
                    
//                    NSString* li1Name = [[NSString stringWithFormat:@"%@",li1Long.name] capitalizedString];
//                    NSString* li1Value = [[NSString s/tringWithFormat:@"%@",[li1Long.value objectAtIndex:0]] capitalizedString];
                    NSString* li1Name = [[NSString stringWithFormat:@"%@",li1Long.name] capitalizedString];
                    NSString* li1Value = [[NSString stringWithFormat:@"%@",li1Long.value] capitalizedString];
                    
                    
                    NSString* li2Name = [[NSString stringWithFormat:@"%@",li2Long.name] capitalizedString];
                    NSString* li2Value = [[NSString stringWithFormat:@"%@",li2Long.value] capitalizedString];
                    
                    if ([li1Name isEqualToString:li2Name] && ([li1Value isEqualToString:li2Value] || [li1Long.slug isEqualToString:@"abcdefghijklmnopqrstuvwxyz"])) {
                        [li1Long._options removeAllObjects];
                        [li1Long._options addObject:li2Value];
                        isEqual = true;
                        break;
                    }
                    
                }
                if(!isEqual) return false;
            }
        }else{
//            return false;
            
            if ((int)[self._attributes count] < (int)[other_attibutes count]) {
                int needToMatch = (int)[other_attibutes count] - (int)[self._attributes count];
                int matchCount = 0;
                for(VariationAttribute *userAttribute in other_attibutes) {
                    NSString* nameUserAttribute = [[NSString stringWithFormat:@"%@",userAttribute.name] capitalizedString];
                    NSString* valUserAttribute = [[NSString stringWithFormat:@"%@",userAttribute.value] capitalizedString];
                    for(Attribute *varAttribute in self._attributes) {
                        NSString* nameVarAttribute = [[NSString stringWithFormat:@"%@",varAttribute._name] capitalizedString];
                        NSString* valVarAttribute = [[NSString stringWithFormat:@"%@",[varAttribute._options objectAtIndex:0]] capitalizedString];
                        if ([nameUserAttribute isEqualToString:nameVarAttribute] && [valUserAttribute isEqualToString:valVarAttribute]){
                            matchCount++;
                        }
                    }
                }
                if (needToMatch == matchCount) {
                    for(VariationAttribute *userAttribute in other_attibutes) {
                        NSString* nameUserAttribute = [[NSString stringWithFormat:@"%@",userAttribute.name] capitalizedString];
                        NSString* valUserAttribute = [[NSString stringWithFormat:@"%@",userAttribute.value] capitalizedString];
                        BOOL isUserAttributeExists = false;
                        for(Attribute *varAttribute in self._attributes) {
                            NSString* nameVarAttribute = [[NSString stringWithFormat:@"%@",varAttribute._name] capitalizedString];
                            if ([nameUserAttribute isEqualToString:nameVarAttribute]){
                                isUserAttributeExists = true;
                                break;
                            }
                        }
                        if (isUserAttributeExists == false) {
                            Attribute* attribute = [[Attribute alloc] init];
                            attribute._name = nameUserAttribute;
                            [attribute._options addObject:valUserAttribute] ;
                            //                        attribute._position = GET_VALUE_INT(mtempDict, @"position");
                            attribute._slug = @"abcdefghijklmnopqrstuvwxyz";
                            //                        attribute._variation = GET_VALUE_BOOL(mtempDict, @"variation");
                            //                        attribute._visible = GET_VALUE_BOOL(mtempDict, @"visible");
                            [self._attributes addObject:attribute];
                        }
                    }
                    return true;
                }
                
            }
            return false;
            
        }
    }else{
        return false;
    }
    return true;

}
*/
- (NSString*)getAttributeString {
    NSString *str = @"";
    for (VariationAttribute *attribute in self._attributes) {
        str = [NSString stringWithFormat:@"%@%@:<strong>%@</strong> |", str, attribute.name, attribute.value];
    }
    str = [str substringToIndex: [str length] - 3];
    return str;
}
- (id)cloneMe {
    Variation* v = [[Variation alloc] init];
    v._id = self._id;
    v._stock_quantity = self._stock_quantity;
    v._download_limit = self._download_limit;
    v._download_expiry = self._download_expiry;
    v._created_at = self._created_at;
    v._updated_at = self._updated_at;
    v._permalink = self._permalink;
    v._sku = self._sku;
    v._tax_status = self._tax_status;
    v._tax_class = self._tax_class;
    v._shipping_class = self._shipping_class;
    v._shipping_class_id = self._shipping_class_id;
    v._price = self._price;
    v._regular_price = self._regular_price;
    v._sale_price = self._sale_price;
    v._downloadable = self._downloadable;
    v._virtual = self._virtual;
    v._taxable = self._taxable;
    v._managing_stock = self._managing_stock;
    v._in_stock = self._in_stock;
    v._backordered = self._backordered;
    v._purchaseable = self._purchaseable;
    v._visible = self._visible;
    v._on_sale = self._on_sale;
    v._dimensions = self._dimensions;
    v._images = self._images;
    //    v._attributes = self._attributes;
    v._downloads = self._downloads;
    v._variation_index = -1;
    if (self._attributes) {
        for (VariationAttribute* _attribute in self._attributes) {
            VariationAttribute* attribute = [[VariationAttribute alloc] init];
            attribute.name = _attribute.name;
            attribute.slug = _attribute.slug;
            attribute.value = _attribute.value;
            [v._attributes addObject:attribute];
        }
    }
    v._weight = self._weight;
    return v;
}
- (BOOL)hasOptionForAttribute:(NSString*)attribName option:(NSString*)option {
    VariationAttribute* attribute = [self getWithName:attribName];
    if (attribute != nil) {
        if (attribute.value == nil || [attribute.value isEqualToString:@""] || [Utility compareAttributeNames:attribute.value name2:option]) {
            return true;
        }
    }
    return false;
}
- (VariationAttribute*)getWithName:(NSString*)name {
    for (VariationAttribute* attribute in self._attributes) {
        //if (attribute.name.equalsIgnoreCase(name)) {
        if ([Utility compareAttributeNames:attribute.name name2:name]) {
            return attribute;
        }
    }
    return nil;
}
- (NSMutableArray*)getImageUrls{
    NSMutableArray* array = [[NSMutableArray alloc] init];
    for (ProductImage* productImg in self._images) {
        [array addObject:productImg._src];
    }
    return array;
}
@end
