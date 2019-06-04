//
//  PaymentDetail.h
//  eCommerceApp
//
//  Created by Rishabh Jain on 01/10/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PaymentDetail : NSObject

@property NSString *_method_id;
@property NSString *_method_title;
@property BOOL _paid;

-(id)init;
@end
