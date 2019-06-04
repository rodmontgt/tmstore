//
//  ProductImage.h
//  eCommerceApp
//
//  Created by Rishabh Jain on 01/10/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProductImage : NSObject

@property int _id;
@property NSString *_src;
@property NSString *_title;
@property NSString *_alt;
@property int _position;

-(id)init;

@end
