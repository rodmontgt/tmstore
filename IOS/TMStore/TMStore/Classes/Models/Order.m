//
//  Order.m
//  eCommerceApp
//
//  Created by Rishabh Jain on 01/10/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import "Order.h"
#import "AppUser.h"

@implementation Order

- (id)init {
    self = [super init];
    if (self) {
        // initialize instance variables here
        self._id = 0;
        self._order_number = 0;
        self._order_number_str = @"0";
        self._created_at  = NULL;
        self._updated_at  = NULL;
        self._completed_at  = NULL;
        self._status  = @"";
        self._currency  = @"";
        self._total  = @"";
        self._subtotal  = @"";
        self._total_line_items_quantity = 0;
        self._total_tax = 0;
        self._total_shipping = 0;
        self._cart_tax = 0;
        self._shipping_tax = 0;
        self._total_discount = 0;
        self._shipping_methods = @"";
        self._payment_details = [[PaymentDetail alloc] init];
        self._billing_address = [[Address alloc] init];
        self._shipping_address = [[Address alloc] init];
        self._note = @"";
        self._notePickupLocation = @"";
        self._customer_id = 0;
        self._view_order_url = @"";
        self._line_items = [[NSMutableArray alloc] init];
        self._shipping_lines = [[NSMutableArray alloc] init];
        self._tax_lines = [[NSMutableArray alloc] init];
        self._fee_lines = [[NSMutableArray alloc] init];
        self._coupon_lines = [[NSMutableArray alloc] init];
        self.pointsEarned = 0;
        self.pointsRedeemed = 0;
        self.shipmentTrackingId = nil;
        self.shipmentProvider = nil;
        
        self.deliveryDateString = @"";
        self.deliveryTimeString = @"";
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self._id = [decoder decodeIntForKey:@"#1"];
        self._order_number = [decoder decodeIntForKey:@"#2"];
        self._total_line_items_quantity = [decoder decodeIntForKey:@"#3"];
        self._customer_id = [decoder decodeIntForKey:@"#4"];

        self._total_tax = [decoder decodeFloatForKey:@"#5"];
        self._total_shipping = [decoder decodeFloatForKey:@"#6"];
        self._cart_tax = [decoder decodeFloatForKey:@"#7"];
        self._shipping_tax = [decoder decodeFloatForKey:@"#8"];
        self._total_discount = [decoder decodeFloatForKey:@"#9"];

        self._created_at = [decoder decodeObjectForKey:@"#10"];
        self._updated_at = [decoder decodeObjectForKey:@"#11"];
        self._completed_at = [decoder decodeObjectForKey:@"#12"];
        self._status = [decoder decodeObjectForKey:@"#13"];
        self._currency = [decoder decodeObjectForKey:@"#14"];
        self._total = [decoder decodeObjectForKey:@"#15"];
        self._subtotal = [decoder decodeObjectForKey:@"#16"];
        self._shipping_methods = [decoder decodeObjectForKey:@"#17"];
        self._note = [decoder decodeObjectForKey:@"#18"];
        self._view_order_url = [decoder decodeObjectForKey:@"#19"];

        self._payment_details = (PaymentDetail*)[decoder decodeObjectForKey:@"#20"];
        self._billing_address = (Address*)[decoder decodeObjectForKey:@"#21"];
        self._shipping_address = (Address*)[decoder decodeObjectForKey:@"#22"];
        self._line_items = (NSMutableArray*)[decoder decodeObjectForKey:@"#23"];
        self._shipping_lines = (NSMutableArray*)[decoder decodeObjectForKey:@"#24"];
        self._tax_lines = (NSMutableArray*)[decoder decodeObjectForKey:@"#25"];
//        self._fee_lines = (NSMutableArray*)[decoder decodeObjectForKey:@"#26"];
        self._coupon_lines = (NSMutableArray*)[decoder decodeObjectForKey:@"#27"];
        self.pointsEarned = [decoder decodeIntForKey:@"#28"];
        self.pointsRedeemed = [decoder decodeIntForKey:@"#29"];
        self._order_number_str = [decoder decodeObjectForKey:@"#30"];
        
        self.deliveryDateString = @"";
        self.deliveryTimeString = @"";
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt:self._id forKey:@"#1"];
    [encoder encodeInt:self._order_number forKey:@"#2"];
    [encoder encodeInt:self._total_line_items_quantity forKey:@"#3"];
    [encoder encodeInt:self._customer_id forKey:@"#4"];

    [encoder encodeFloat:self._total_tax forKey:@"#5"];
    [encoder encodeFloat:self._total_shipping forKey:@"#6"];
    [encoder encodeFloat:self._cart_tax forKey:@"#7"];
    [encoder encodeFloat:self._shipping_tax forKey:@"#8"];
    [encoder encodeFloat:self._total_discount forKey:@"#9"];

    [encoder encodeObject:self._created_at forKey:@"#10"];
    [encoder encodeObject:self._updated_at forKey:@"#11"];
    [encoder encodeObject:self._completed_at forKey:@"#12"];
    [encoder encodeObject:self._status forKey:@"#13"];
    [encoder encodeObject:self._currency forKey:@"#14"];
    [encoder encodeObject:self._total forKey:@"#15"];
    [encoder encodeObject:self._subtotal forKey:@"#16"];
    [encoder encodeObject:self._shipping_methods forKey:@"#17"];
    [encoder encodeObject:self._note forKey:@"#18"];
    [encoder encodeObject:self._view_order_url forKey:@"#19"];

    [encoder encodeObject:self._payment_details forKey:@"#20"];
    [encoder encodeObject:self._billing_address forKey:@"#21"];
    [encoder encodeObject:self._shipping_address forKey:@"#22"];
    [encoder encodeObject:self._line_items forKey:@"#23"];
    [encoder encodeObject:self._shipping_lines forKey:@"#24"];
    [encoder encodeObject:self._tax_lines forKey:@"#25"];
//    [encoder encodeObject:self._fee_lines forKey:@"#26"];
    [encoder encodeObject:self._coupon_lines forKey:@"#27"];
    [encoder encodeInt:self.pointsEarned forKey:@"#28"];
    [encoder encodeInt:self.pointsRedeemed forKey:@"#29"];
    [encoder encodeObject:self._order_number_str forKey:@"#30"];
}

//+ (Order*)findWithNumber:(int)orderNumber {
//    AppUser* appUser = [AppUser sharedManager];
//    for(Order* order in appUser._ordersArray) {
//		if(order._order_number == orderNumber)
//            return order;
//    }
//    return nil;
//}
+ (Order*)findWithNumberString:(NSString*)orderNumberStr {
    AppUser* appUser = [AppUser sharedManager];
    for(Order* order in appUser._ordersArray) {
        if([order._order_number_str isEqualToString:orderNumberStr])
            return order;
    }
    return nil;
}
+ (Order*)findWithOrderId:(int)orderId {
    AppUser* appUser = [AppUser sharedManager];
    for(Order* order in appUser._ordersArray) {
        if(order._id == orderId)
            return order;
    }
    return nil;
}
@end


//for (int i = 0; i < 20; i++)
//{
//    LineItem *lineItem = [[LineItem alloc] init];
//    lineItem._id = 2;
//    lineItem._subtotal = 223;
//    [self._line_items addObject:lineItem];
//    [lineItem release];
//}
