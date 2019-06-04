//
//  NavDrawItem.h
//  eCommerceApp
//
//  Created by Rishabh Jain on 01/10/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NavDrawItem : NSObject

@property NSString *_name;
@property int _itemImageId;
@property int _id;

- (id)init;
- (id)initWithParameters:(int) _id _name:(NSString *)_name _itemImageId:(int)_itemImageId;

@end
