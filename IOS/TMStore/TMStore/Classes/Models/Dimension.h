//
//  Dimension.h
//  eCommerceApp
//
//  Created by Rishabh Jain on 01/10/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Dimension : NSObject

@property float _length;
@property float _width;
@property float _height;
@property NSString *_unit;

- (id)init;
@end
