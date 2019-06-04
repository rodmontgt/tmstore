//
//  DLContent.h
//  TMStore
//
//  Created by Rishabh Jain on 18/04/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DLConstants.h"
@interface DLContent : NSObject
@property NSString* imgUrl;
@property NSString* name;
@property NSString* display;

//@property NSString* redirectString;
@property DL_REDIRECT redirect;
@property int redirect_id;
@property NSString* redirect_url;

@property int _id;

@property NSString* bgUrl;
@property UIColor* bgColor;
- (id)init;


@end


