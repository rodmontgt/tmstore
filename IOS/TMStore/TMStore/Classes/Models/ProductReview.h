//
//  ProductReview.h
//  eCommerceApp
//
//  Created by Rishabh Jain on 01/10/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProductReview : NSObject

@property NSDate *_created_at;
@property int _id;
@property float _rating;
@property NSString *_review;
@property NSString *_reviewer_name;
@property NSString *_reviewer_email;
@property BOOL _verified;

-(id)init;

@end
