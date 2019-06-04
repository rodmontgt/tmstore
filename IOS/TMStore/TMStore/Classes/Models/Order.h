//
//  Order.h
//  eCommerceApp
//
//  Created by Rishabh Jain on 01/10/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Address.h"
#import "LineItem.h"
#import "PaymentDetail.h"
#import "FeeData.h"
#import "FeeLine.h"

@interface Order : NSObject

@property int _id;
@property int _order_number;
@property NSString* _order_number_str;
@property int _total_line_items_quantity;
@property int _customer_id;

@property float _total_tax;
@property float _total_shipping;
@property float _cart_tax;
@property float _shipping_tax;
@property float _total_discount;

@property NSDate *_created_at;
@property NSDate *_updated_at;
@property NSDate *_completed_at;
@property NSString *_status;
@property NSString *_currency;
@property NSString *_total;
@property NSString *_subtotal;
@property NSString *_shipping_methods;
@property NSString *_note;
@property NSString* _notePickupLocation;
@property NSString *_view_order_url;

@property PaymentDetail *_payment_details;
@property Address *_billing_address;
@property Address *_shipping_address;
@property NSMutableArray *_line_items;//Array of LineItem

@property NSMutableArray *_shipping_lines;//Array of NSString
@property NSMutableArray *_tax_lines;//Array of NSString
@property NSMutableArray *_fee_lines;//Array of FeeLine
@property NSMutableArray *_coupon_lines;//Array of NSString

@property int pointsEarned;
@property int pointsRedeemed;

@property NSString* shipmentTrackingId;
@property NSString* shipmentProvider;
@property NSString* shipmentUrl;
- (id)init;
//+ (Order*)findWithNumber:(int)orderNumber;
+ (Order*)findWithNumberString:(NSString*)orderNumberStr;
+ (Order*)findWithOrderId:(int)orderId;
@property NSString* deliveryDateString;
@property NSString* deliveryTimeString;

@end
