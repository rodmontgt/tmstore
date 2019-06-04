//
//  ShippingWooCommerce.h
//  TMShippingSDK
//
//  Created by Rishabh Jain on 28/09/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShippingEngine.h"
#import "TMShippingSDK.h"

@interface ShippingRajaongkir : ShippingEngine <ShippingEngine>
- (id)init:(NSString*)baseUrl keyRajaongkir:(NSString*)keyRajaongkir;
@end
