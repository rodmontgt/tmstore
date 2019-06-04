//
//  TMShipping.h
//  TMShippingSDK
//
//  Created by Rishabh Jain on 28/09/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

//public class TM_Shipping {
//    public String id = ""; //"free_shipping",
//    public String label; //":"Free Shipping",
//    public double cost; //":"0.00",
//    public List<String> taxes = new ArrayList<>(); //":[],
//    public String method_id; //":"free_shipping"
//    public String description = "";
//    public String etd = "";
//    
//    public static boolean SHIPPING_REQUIRED = true;
//    
//    @Override
//    public String toString() {
//        return this.label;
//    }
//}


@interface TMShipping : NSObject
@property NSString* shippingId;
@property NSString* shippingLabel;
@property float shippingCost;
@property NSString* shippingMethodId;
@property NSString* shippingDescription;
@property NSString* shippingEtd;
@property NSMutableArray* shippingTaxes;
@property BOOL taxable;
- (id)init;
+ (BOOL)SHIPPING_REQUIRED;
- (void)setSHIPPING_REQUIRED:(BOOL)value;
@end
