//
//  SampleTestMagento.h
//  TMStore
//
//  Created by V S Khutal on 24/07/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WC2X_Engine.h"
@interface SampleTestMagento : NSObject
+ (id)sharedManager;
- (void)testMagentoPost;
- (void)testWooCommercePost;
@end
