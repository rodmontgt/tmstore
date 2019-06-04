//
//  TM_FilterAttributeOption.h
//  TMStore
//
//  Created by Rishabh Jain on 16/05/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TM_FilterAttributeOption : NSObject
@property NSString* name;
@property NSString* taxo;
@property NSString* slug;
@property NSString* term_id;

@property BOOL isVisible;
- (id)init;
- (id)init:(TM_FilterAttributeOption*)other;
@end
