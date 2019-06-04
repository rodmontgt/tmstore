//
//  VariationSet.h
//  WooMobil
//
//  Created by Rishabh Jain on 02/02/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Variation.h"


@interface VariationSet : NSMutableArray{
    NSMutableArray *_backendArray;
}
// *** CUSTOM METHODS ***
- (Variation*)getVariationFromAttibutes:(NSMutableArray*)variationAttributes;
- (Variation*)getVariation:(int)variationId variationIndex:(int)variationIndex;
- (Variation*)getVariation:(int)variationId;
@end
