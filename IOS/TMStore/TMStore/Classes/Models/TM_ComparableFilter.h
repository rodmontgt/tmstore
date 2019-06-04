//
//  TM_ComparableFilter.h
//  TMStore
//
//  Created by Rishabh Jain on 16/05/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface TM_ComparableFilterAttribute : NSObject
@property NSString* taxo;
@property NSMutableArray* names;//array of strings

- (id)init;
@end

@interface TM_ComparableFilter : NSObject
@property float min_limit;
@property float max_limit;
@property NSMutableArray* attribute;//array ofTM_ComparableFilterAttribute

- (id)init;
- (TM_ComparableFilterAttribute*)getMatchingAttribute:(NSString*)text;
- (BOOL)hasAnyOptionInAttribute:(NSString*)attributeName;
@end
