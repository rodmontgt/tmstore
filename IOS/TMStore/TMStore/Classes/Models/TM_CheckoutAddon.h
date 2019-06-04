//
//  TM_CheckoutAddon.h
//  TMStore
//
//  Created by Rishabh Jain on 12/04/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
enum TM_CheckoutAddonType {
    TM_CheckoutAddonType_CHECKBOX
};
@interface TM_CheckoutAddon : NSObject
- (id)init;
@property float cost;
@property NSString* label;
@property NSString* name;
@property enum TM_CheckoutAddonType type;
@property NSString* taxClass;
@property float netTax;

+ (NSMutableArray*)getAllCheckoutAddons;
+ (void)clearAllCheckoutAddons;


+ (NSMutableArray*)getSelectedCheckoutAddons;
+ (void)clearSelectedCheckoutAddons;
+ (void)addToSelectedCheckoutAddons:(TM_CheckoutAddon*)obj;

+ (NSString*)getOrderScreenNote;
+ (void)setOrderScreenNote:(NSString*)value;
@end
