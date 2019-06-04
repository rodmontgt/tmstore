//
//  TM_ProductFilter.m
//  TMStore
//
//  Created by Rishabh Jain on 16/05/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import "TM_Tax.h"
#import "Cart.h"
#import "DataManager.h"
#import "CommonInfo.h"
#import "AppUser.h"
#import "TM_CheckoutAddon.h"
static NSMutableArray* _allTaxes = NULL;//ARRAY OF TM_Tax
static NSMutableArray* _allTaxesApplied = NULL;//ARRAY OF TM_TaxApplied
@implementation TM_Tax
+ (NSMutableArray*)getAllTaxes {
    if (_allTaxes == NULL) {
        _allTaxes = [[NSMutableArray alloc] init];
    }
    return _allTaxes;
}
- (id)init {
    self = [super init];
    if (self) {
        if (_allTaxes == NULL) {
            _allTaxes = [[NSMutableArray alloc] init];
        }
        [_allTaxes addObject:self];
        
        _taxId = -1;
        _country = @"";
        _state = @"";
        _postcode = @"";
        _city = @"";
        _rate = 0.0f;
        _name = @"";
        _priority = 0;
        _compound = false;
        _shipping = false;
        _order = 0;
        _taxClass = @"";
        _additionalProperties = [[NSMutableDictionary alloc] init];
        _cities = nil;
        _postalCodes = nil;
    }
    return self;
}
@end

@implementation TM_TaxApplied
+ (NSMutableArray*)getAllTaxesApplied {
    if (_allTaxesApplied == NULL) {
        _allTaxesApplied = [[NSMutableArray alloc] init];
    }
    return _allTaxesApplied;
}
- (id)init {
    self = [super init];
    if (self) {
        if (_allTaxesApplied == NULL) {
            _allTaxesApplied = [[NSMutableArray alloc] init];
        }
        [_allTaxesApplied addObject:self];
        
        _taxId = -1;
        _country = @"";
        _state = @"";
        _postcode = @"";
        _city = @"";
        _rate = 0.0f;
        _name = @"";
        _priority = 0;
        _compound = false;
        _shipping = false;
        _order = 0;
        _taxClass = @"";
        _additionalProperties = [[NSMutableDictionary alloc] init];
        _netTax = 0.0f;
        _cities = nil;
        _postalCodes = nil;
    }
    return self;
}
+ (TM_TaxApplied*)copyTax:(TM_Tax*)taxObj {
    TM_TaxApplied* taxApplied = [[TM_TaxApplied alloc] init];
    taxApplied.city = [NSString stringWithFormat:@"%@", taxObj.city];
    taxApplied.state = [NSString stringWithFormat:@"%@", taxObj.state];
    taxApplied.country = [NSString stringWithFormat:@"%@", taxObj.country];
    taxApplied.postcode = [NSString stringWithFormat:@"%@", taxObj.postcode];
    taxApplied.name = [NSString stringWithFormat:@"%@", taxObj.name];
    taxApplied.taxClass = [NSString stringWithFormat:@"%@", taxObj.taxClass];
    
    taxApplied.taxId = taxObj.taxId;
    taxApplied.priority = taxObj.priority;
    taxApplied.order = taxObj.order;
    
    taxApplied.rate = taxObj.rate;
    taxApplied.compound = taxObj.compound;
    taxApplied.shipping = taxObj.shipping;
    
    taxApplied.additionalProperties = taxObj.additionalProperties;
    
    if (taxObj.cities && [taxObj.cities count] > 0) {
        taxApplied.cities = [[NSArray alloc] initWithArray:taxObj.cities];
    }
    if (taxObj.postalCodes && [taxObj.postalCodes count] > 0) {
        taxApplied.postalCodes = [[NSArray alloc] initWithArray:taxObj.postalCodes];
    }
    
    return taxApplied;
}
+ (void)loadTaxes:(float)shippingCost {
    CommonInfo* commonInfo = [CommonInfo sharedManager];
    if([commonInfo->_calculateTaxBasedOn isEqualToString:@""]){
        return;
    }
    
    NSArray* allTaxes = [TM_Tax getAllTaxes];
    if ([allTaxes count] == 0) {
        [[[DataManager sharedManager] tmDataDoctor] fetchTaxesData:^(id data) {
            [self calculateTotalTax:shippingCost];
        } failure:^(NSString *error) {
            RLOG(@"unable to fetch taxes");
        }];
    }
}
+ (BOOL)isTaxApplicable:(TM_TaxApplied*)tax {
    CommonInfo* commonInfo = [CommonInfo sharedManager];
    
//    if (tax.shipping == false) {
//        return true;
//    }
    
//#if ENABLE_DEBUGGING
//    if ([commonInfo->_calculateTaxBasedOn isEqualToString:@""]) {
//        commonInfo->_calculateTaxBasedOn = @"shipping";
//    }
//#endif
    
    
    if ([commonInfo->_calculateTaxBasedOn isEqualToString:@""]) {
        //no tax is applied
        return false;
    }
    
    AppUser* appUser = [AppUser sharedManager];
    NSString* userCountryCode = @"";
    NSString* userStateCode = @"";
    NSString* userCityNameStr = @"";
    NSString* userPincodeStr = @"";
    
    if ([[commonInfo->_calculateTaxBasedOn lowercaseString] isEqualToString:@"shipping"]) {
        //tax is applied on customer shipping address
        userCountryCode = appUser._shipping_address._countryId?[[NSString stringWithFormat:@"%@", appUser._shipping_address._countryId] uppercaseString]:@"";
        userStateCode = appUser._shipping_address._stateId?[[NSString stringWithFormat:@"%@", appUser._shipping_address._stateId] uppercaseString]:@"";
        userCityNameStr = appUser._shipping_address._city?[[NSString stringWithFormat:@"%@", appUser._shipping_address._city] uppercaseString]:@"";
        userPincodeStr = appUser._shipping_address._postcode?[[NSString stringWithFormat:@"%@", appUser._shipping_address._postcode] uppercaseString]:@"";
    }
    else if ([[commonInfo->_calculateTaxBasedOn lowercaseString] isEqualToString:@"billing"]) {
        //tax is applied on customer billing address
        userCountryCode = appUser._billing_address._countryId?[[NSString stringWithFormat:@"%@", appUser._billing_address._countryId] uppercaseString]:@"";
        userStateCode = appUser._billing_address._stateId?[[NSString stringWithFormat:@"%@", appUser._billing_address._stateId] uppercaseString]:@"";
        userCityNameStr = appUser._billing_address._city?[[NSString stringWithFormat:@"%@", appUser._billing_address._city] uppercaseString]:@"";
        userPincodeStr = appUser._billing_address._postcode?[[NSString stringWithFormat:@"%@", appUser._billing_address._postcode] uppercaseString]:@"";
    }
    else if ([[commonInfo->_calculateTaxBasedOn lowercaseString] isEqualToString:@"base"]) {
        //tax is applied on merchant shop base address
        userCountryCode = commonInfo->_shopBaseAddressCountryId?[[NSString stringWithFormat:@"%@", commonInfo->_shopBaseAddressCountryId] uppercaseString]:@"";
        userStateCode = commonInfo->_shopBaseAddressStateId?[[NSString stringWithFormat:@"%@", commonInfo->_shopBaseAddressStateId] uppercaseString]:@"";
    }
    
    
    
    
    if (![tax.country isEqualToString:@""]) {
        if (![tax.country isEqualToString:userCountryCode]) {
            return false;
        }
    }
//    if (([tax.country isEqualToString:@""]) && (![tax.state isEqualToString:@""])) {
//        return false;
//    }
    if (![tax.state isEqualToString:@""]) {
        if (![tax.state isEqualToString:userStateCode]) {
            return false;
        }
    }
//    if (([tax.state isEqualToString:@""]) && (![tax.city isEqualToString:@""])) {
//        return false;
//    }
    if (![tax.city isEqualToString:@""]) {
        if (![tax.city isEqualToString:userCityNameStr]) {
            return false;
        }
    }
//    if (([tax.city isEqualToString:@""]) && (![tax.postcode isEqualToString:@""])) {
//        return false;
//    }
    if (![tax.postcode isEqualToString:@""]) {
        if (![tax.postcode isEqualToString:userPincodeStr]) {
            return false;
        }
    }
    return true;
}
+ (float)calculateTax:(float)cost productTaxClass:(NSString*)productTaxClass isProductTaxable:(BOOL)isProductTaxable isShippingNecessary:(BOOL)isShippingNecessary {
    CommonInfo* commonInfo = [CommonInfo sharedManager];
    if (isShippingNecessary == false && commonInfo->_woocommerce_prices_include_tax) {
        return 0.0f;
    }
    
    if (isShippingNecessary == false && commonInfo->_addTaxToProductPrice) {
        return 0.0f;
    }
    
    
    float productPriceWithoutTax = cost;
    float productPriceWithTax = cost;
    float taxOnProduct = 0.0f;
    
    if (cost == 0.0f) {
        return taxOnProduct;
    }
    if(isProductTaxable) {
        if(productTaxClass == nil || [productTaxClass isEqualToString:@""]) {
            productTaxClass = @"standard";
        }
        NSMutableArray* taxesForThisProd = [[NSMutableArray alloc] init];
        NSMutableDictionary* sortingTaxes = [[NSMutableDictionary alloc] init];
//        NSMutableArray* samePriorityTaxes = [[NSMutableArray alloc] init];
        for (TM_TaxApplied* taxObj in _allTaxesApplied) {
            if ([taxObj.taxClass isEqualToString:productTaxClass]) {
                if ([sortingTaxes objectForKey:[NSString stringWithFormat:@"%d", taxObj.priority]]) {
                    
//                    [samePriorityTaxes addObject:[sortingTaxes objectForKey:[NSString stringWithFormat:@"%d", taxObj.priority]]];
                } else {
                
                [sortingTaxes setObject:taxObj forKey:[NSString stringWithFormat:@"%d", taxObj.priority]];
                }
            }
        }
        NSArray *priorityKeys = [sortingTaxes allKeys];
        NSArray *sortedKeys = [priorityKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
        
        NSMutableArray* taxObjSamePriorityToBeRemove = [[NSMutableArray alloc] init];
        for(id key in sortedKeys) {
            id object = [sortingTaxes objectForKey:key];
            [taxesForThisProd addObject:object];
//            TM_TaxApplied* refTaxObj = object;
//            for (TM_TaxApplied* taxObjSamePriority  in samePriorityTaxes) {
//                if (refTaxObj.priority == taxObjSamePriority.priority) {
//                    [taxesForThisProd addObject:taxObjSamePriority];
//                    [taxObjSamePriorityToBeRemove addObject:taxObjSamePriority];
//                }
//            }
//            [samePriorityTaxes removeObjectsInArray:taxObjSamePriorityToBeRemove];
        }
        
        RLOG(@"%@", taxesForThisProd);
        
        float productPrice = cost;
        if (productPrice < 0) {
            productPrice = 0.0f;
        }
        productPriceWithTax = productPrice;
        productPriceWithoutTax = productPrice;
        for (TM_TaxApplied* taxObj in taxesForThisProd) {
            if ([TM_TaxApplied isTaxApplicable:taxObj] && taxObj.compound == false) {
                if ((isShippingNecessary && taxObj.shipping) || isShippingNecessary == false) {
                    float taxOnThisProduct = productPrice * taxObj.rate / 100.0f;
                    taxObj.netTax += taxOnThisProduct;
                    productPriceWithTax += taxOnThisProduct;
                }
            }
        }
        float productPriceWithTaxForCompound = productPriceWithTax;
        for (TM_TaxApplied* taxObj in taxesForThisProd) {
            if ([TM_TaxApplied isTaxApplicable:taxObj] && taxObj.compound == true) {
                if ((isShippingNecessary && taxObj.shipping) || isShippingNecessary == false) {
                    float taxOnThisProduct = productPriceWithTaxForCompound * taxObj.rate / 100.0f;
                    taxObj.netTax += taxOnThisProduct;
                    productPriceWithTax += taxOnThisProduct;
                }
            }
        }
        
    }
    
    taxOnProduct = productPriceWithTax - productPriceWithoutTax;
    return taxOnProduct;
}
+ (float)calculateTaxProductOriginal:(float)cost productTaxClass:(NSString*)productTaxClass isProductTaxable:(BOOL)isProductTaxable isShippingNecessary:(BOOL)isShippingNecessary {
    float productPriceWithoutTax = cost;
    float productPriceWithTax = cost;
    float taxOnProduct = 0.0f;
    
    if (cost == 0.0f) {
        return taxOnProduct;
    }
    if(isProductTaxable) {
        if(productTaxClass == nil || [productTaxClass isEqualToString:@""]) {
            productTaxClass = @"standard";
        }
        NSMutableArray* taxesForThisProd = [[NSMutableArray alloc] init];
        NSMutableDictionary* sortingTaxes = [[NSMutableDictionary alloc] init];
        for (TM_Tax* taxObj in [TM_Tax getAllTaxes]) {
            if ([taxObj.taxClass isEqualToString:productTaxClass]) {
                if ([sortingTaxes objectForKey:[NSString stringWithFormat:@"%d", taxObj.priority]]) {
                } else {
                    [sortingTaxes setObject:taxObj forKey:[NSString stringWithFormat:@"%d", taxObj.priority]];
                }
            }
        }
        NSArray *priorityKeys = [sortingTaxes allKeys];
        NSArray *sortedKeys = [priorityKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
        for(id key in sortedKeys) {
            id object = [sortingTaxes objectForKey:key];
            [taxesForThisProd addObject:object];
        }
        
        RLOG(@"%@", taxesForThisProd);
        
        float productPrice = cost;
        if (productPrice < 0) {
            productPrice = 0.0f;
        }
        productPriceWithTax = productPrice;
        productPriceWithoutTax = productPrice;
        
        float taxRatesTotal = 0.0f;
        for (TM_TaxApplied* taxObj in taxesForThisProd) {
            if ([TM_TaxApplied isTaxApplicable:taxObj] && taxObj.compound == false) {
                if ((isShippingNecessary && taxObj.shipping) || isShippingNecessary == false) {
                    taxRatesTotal += taxObj.rate;
                }
            }
        }
        if (taxRatesTotal > 0) {
            float taxOnThisProduct = productPrice - (productPrice * 100.0f)/(100.0f +taxRatesTotal);
            productPriceWithTax -= taxOnThisProduct;
        }
        
        
        
        float productPriceWithTaxForCompound = productPriceWithTax;
        for (TM_TaxApplied* taxObj in taxesForThisProd) {
            if ([TM_TaxApplied isTaxApplicable:taxObj] && taxObj.compound == true) {
                if ((isShippingNecessary && taxObj.shipping) || isShippingNecessary == false) {
                    float taxOnThisProduct = productPriceWithTaxForCompound - (productPriceWithTaxForCompound * 100.0f)/(100.0f + taxObj.rate);
                    productPriceWithTax -= taxOnThisProduct;
                }
            }
        }
        
    }
    
    taxOnProduct = productPriceWithTax - productPriceWithoutTax;
    return taxOnProduct;
}
+ (float)calculateTaxProduct:(float)cost productTaxClass:(NSString*)productTaxClass isProductTaxable:(BOOL)isProductTaxable isShippingNecessary:(BOOL)isShippingNecessary {
    float productPriceWithoutTax = cost;
    float productPriceWithTax = cost;
    float taxOnProduct = 0.0f;
    
    if (cost == 0.0f) {
        return taxOnProduct;
    }
    if(isProductTaxable) {
        if(productTaxClass == nil || [productTaxClass isEqualToString:@""]) {
            productTaxClass = @"standard";
        }
        NSMutableArray* taxesForThisProd = [[NSMutableArray alloc] init];
        NSMutableDictionary* sortingTaxes = [[NSMutableDictionary alloc] init];
        for (TM_Tax* taxObj in [TM_Tax getAllTaxes]) {
            if ([taxObj.taxClass isEqualToString:productTaxClass]) {
                if ([sortingTaxes objectForKey:[NSString stringWithFormat:@"%d", taxObj.priority]]) {
                } else {
                    [sortingTaxes setObject:taxObj forKey:[NSString stringWithFormat:@"%d", taxObj.priority]];
                }
            }
        }
        NSArray *priorityKeys = [sortingTaxes allKeys];
        NSArray *sortedKeys = [priorityKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
        for(id key in sortedKeys) {
            id object = [sortingTaxes objectForKey:key];
            [taxesForThisProd addObject:object];
        }
        
        RLOG(@"%@", taxesForThisProd);
        
        float productPrice = cost;
        if (productPrice < 0) {
            productPrice = 0.0f;
        }
        productPriceWithTax = productPrice;
        productPriceWithoutTax = productPrice;
        for (TM_TaxApplied* taxObj in taxesForThisProd) {
            if ([TM_TaxApplied isTaxApplicable:taxObj] && taxObj.compound == false) {
                if ((isShippingNecessary && taxObj.shipping) || isShippingNecessary == false) {
                    float taxOnThisProduct = productPrice * taxObj.rate / 100.0f;
//                    taxObj.netTax += taxOnThisProduct;
                    productPriceWithTax += taxOnThisProduct;
                }
            }
        }
        float productPriceWithTaxForCompound = productPriceWithTax;
        for (TM_TaxApplied* taxObj in taxesForThisProd) {
            if ([TM_TaxApplied isTaxApplicable:taxObj] && taxObj.compound == true) {
                if ((isShippingNecessary && taxObj.shipping) || isShippingNecessary == false) {
                    float taxOnThisProduct = productPriceWithTaxForCompound * taxObj.rate / 100.0f;
//                    taxObj.netTax += taxOnThisProduct;
                    productPriceWithTax += taxOnThisProduct;
                }
            }
        }
        
    }
    
    taxOnProduct = productPriceWithTax - productPriceWithoutTax;
    return taxOnProduct;
}
+ (float)calculateTotalTax:(float)shippingCost {
    if (_allTaxesApplied == NULL) {
        _allTaxesApplied = [[NSMutableArray alloc] init];
    }
    [_allTaxesApplied removeAllObjects];
    
    NSArray* allTaxes = [TM_Tax getAllTaxes];
    if ([allTaxes count] == 0) {
        [TM_TaxApplied loadTaxes:shippingCost];
        return 0.0f;
    }
    for (TM_Tax* taxObj in allTaxes) {
        [TM_TaxApplied copyTax:taxObj];
    }
    
    //calculate tax for cart items.
    NSArray* cartItems = [Cart getAll];
    for (Cart* cartObj in cartItems) {
        BOOL isProductTaxable = cartObj.product._taxable;
        NSString* productTaxClass = cartObj.product._tax_class;
        float cost = cartObj.originalTotal - cartObj.discountTotal;
        if (cost < 0) {
            cost = 0.0f;
        }
        float totalTaxOnProduct = [TM_TaxApplied calculateTax:cost productTaxClass:productTaxClass isProductTaxable:isProductTaxable isShippingNecessary:false];
        
        
        RLOG(@"totalTaxOnProduct = %.2f", totalTaxOnProduct);
        cartObj.taxOnProduct = totalTaxOnProduct;
    }
    
    //calculate tax for shipping.
    CommonInfo* commonInfo = [CommonInfo sharedManager];
    [TM_TaxApplied calculateTax:shippingCost productTaxClass:commonInfo->_shippingTaxClassName isProductTaxable:true isShippingNecessary:true];
    
    //total tax
    float totalTax = 0.0f;
    for (TM_TaxApplied* taxObj in _allTaxesApplied) {
        if (taxObj.netTax > 0) {
            RLOG(@"name=%@:rate=%.2f:shipping=%d:compound=%d:tax=%.2f", taxObj.name, taxObj.rate, taxObj.shipping, taxObj.compound, taxObj.netTax);
            totalTax += taxObj.netTax;
        }
    }
    return totalTax;
}
+ (float)calculateTotalTaxOnCheckoutAddons {
    //calculate tax for checkout addons
    for (TM_CheckoutAddon* tmCheckoutAddon in [TM_CheckoutAddon getSelectedCheckoutAddons]) {
        if(tmCheckoutAddon.cost > 0.0f){
            float taxTotal = [TM_TaxApplied calculateTax:tmCheckoutAddon.cost productTaxClass:@"" isProductTaxable:true isShippingNecessary:false];
            taxTotal = ceilf(taxTotal * 100) / 100;
            RLOG(@"taxTotal = %.2f", taxTotal);
            tmCheckoutAddon.netTax = taxTotal;
        }
    }

    //total tax
    float totalTax = 0.0f;
    for (TM_TaxApplied* taxObj in _allTaxesApplied) {
        if (taxObj.netTax > 0) {
            RLOG(@"name=%@:rate=%.2f:shipping=%d:compound=%d:tax=%.2f", taxObj.name, taxObj.rate, taxObj.shipping, taxObj.compound, taxObj.netTax);
            totalTax += taxObj.netTax;
        }
    }
    return totalTax;
}

@end
