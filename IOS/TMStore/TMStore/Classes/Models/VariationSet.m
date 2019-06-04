//
//  VariationSet.m
//  WooMobil
//
//  Created by Rishabh Jain on 02/02/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import "VariationSet.h"
#import "Attribute.h"
#import "Addons.h"
@implementation VariationSet

-(instancetype)init {
    if (self = [super init]) {
        _backendArray = [@[] mutableCopy];
    }
    return self;
}
// *** Super's Required Methods (because you're going to use them) ***

- (void)addObject:(id)anObject {
    [_backendArray addObject:anObject];
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index {
    [_backendArray insertObject:anObject atIndex:index];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    [_backendArray replaceObjectAtIndex:index withObject:anObject];
}

- (id)objectAtIndex:(NSUInteger)index {
    return [_backendArray objectAtIndex:index];
}

- (NSUInteger)count {
    return _backendArray.count;
}

- (void)removeObject:(id)anObject {
    [_backendArray removeObject:anObject];
}

- (void)removeLastObject {
    [_backendArray removeLastObject];
}

- (void)removeAllObjects {
    [_backendArray removeAllObjects];
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    [_backendArray removeObjectAtIndex:index];
}

// *** CUSTOM METHODS ***
- (Variation*)getVariationFromAttibutes:(NSMutableArray*)variationAttributes {
    for (Variation* variation in _backendArray) {
        if ([variation compareAttributes:variationAttributes]) {
            return variation;
        }
    }
    return NULL;
}

- (Variation*)getVariation:(int)variationId variationIndex:(int)variationIndex{
    if(variationId < 0)
        return NULL;
    for(Variation *variation in _backendArray)
    {
        if (variationIndex != -1) {
		
		if(variation._id == variationId && variation._variation_index == variationIndex)
                return variation;
				
			/*	
            if(variation._id == variationId)
            {
                if([[Addons sharedManager] auto_generate_variations] == false)
                {
                    variationIndex = variation._variation_index;
                }
                
                if (variation._variation_index == -1 || variation._variation_index == variationIndex) {
                    return variation;
                }
            }
			*/
        }else{
            if(variation._id == variationId)
                return variation;
        }
        
    }
    return NULL;
}

- (Variation*) getVariation:(int)variationId {
    if(variationId >= 0) {
        for (Variation* variation in _backendArray) {
            if (variation._id == variationId)
                return variation;
        }
    }
    return nil;
}
@end
