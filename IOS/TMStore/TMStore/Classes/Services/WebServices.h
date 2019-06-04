//
//  WebServices.h
//  eCommerceApp
//
//  Created by V S Khutal on 05/10/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WebServices : NSObject

- (instancetype)init;
+ (instancetype)sharedManager;
- (void)firstPostServiceWithCompletionHandler:(void (^)(NSArray *list, NSError *error))completionHandler;
- (NSArray *)methodUsingJsonFromSuccessBlock:(NSData *)data;
@end

