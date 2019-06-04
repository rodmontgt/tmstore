//
//  FeeLine.h
//  TMStore
//
//  Created by Rishabh Jain on 03/11/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FeeLine : NSObject
@property int feeline_id;
@property NSString* title;
@property BOOL taxable;
@property NSString* tax_class;
@property float total;
@property float total_tax;
- (id)init;
@end
