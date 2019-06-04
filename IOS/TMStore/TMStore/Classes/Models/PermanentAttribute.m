//
//  PermanentAttribute.m
//  TMStore
//
//  Created by Rishabh Jain on 03/10/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import "PermanentAttribute.h"
#import "Utility.h"
static NSMutableArray* pAttributes = nil;
@implementation PermanentAttribute
- (id)init {
    self = [super init];
    if (self) {
        self.slug = @"";
        self.terms = [[NSMutableDictionary alloc] init];
        if (pAttributes == nil) {
            pAttributes = [[NSMutableArray alloc] init];
        }
        [pAttributes addObject:self];
    }
    return self;
}
+ (NSMutableArray*)getAllPermanentAttributes {
    if (pAttributes == nil) {
        pAttributes = [[NSMutableArray alloc] init];
    }
    return pAttributes;
}
+ (NSString*)resetOption:(NSString*)slug option:(NSString*)option {
    NSString* newOption = option;
    if (pAttributes) {
        for (PermanentAttribute* pAttr in pAttributes) {
            if ([Utility compareAttributeNames:slug name2:pAttr.slug]) {
                if (pAttr.terms) {
                    if (IS_NOT_NULL(pAttr.terms, option)) {
                        NSString* tempStr = GET_VALUE_OBJECT(pAttr.terms, option);
                        if ([tempStr isEqualToString:@""]) {
                            newOption = option;
                        } else {
                            newOption = tempStr;
                        }
                        break;
                    }
                }
                
            }
        }
    }
    return newOption;
}
@end
