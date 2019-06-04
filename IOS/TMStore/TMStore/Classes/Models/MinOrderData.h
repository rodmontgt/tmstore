//
//  MinOrderData.h
//  TMStore
//
//  Created by Rishabh Jain on 03/11/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MinOrderData : NSObject
@property float minOrderAmount;
@property NSString* minOrderMessage;
+ (id)sharedInstance;
- (void)resetMinOrderData;
@end
