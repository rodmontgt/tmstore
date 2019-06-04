//
//  CustomerData.h
//  TMStore
//
//  Created by Rishabh Jain on 05/05/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
@interface CustomerData : NSObject

+ (CustomerData *)sharedManager;
- (PFObject*)getPFInstance;
- (void)setPFInstance:(PFObject*)customerObj;
- (void)setFirstName:(NSString*)string;
- (NSString*)getUsername;
- (void)setUsername:(NSString*)string;
- (NSString*)getPassword;
- (void)setPassword:(NSString*)string;
- (void)setEmailID:(NSString*)string;
- (void)setLastName:(NSString*)string;
- (NSString*)getAddress;
- (void)setAddress:(NSString*)string;
- (NSString*)getState;
- (void)setState:(NSString*)string;
- (void)setApp_Name:(NSString*)string;
- (NSString*)getDeviceModel;
- (void)setDeviceModel:(NSString*)string;
- (NSMutableArray*)getCurrent_Day_Cart_Items;
- (void)setCurrent_Day_Cart_Items:(NSMutableArray*)obj;
- (NSMutableArray*)getCurrent_Day_Whishlist_Items;
- (void)setCurrent_Day_Whishlist_Items:(NSMutableArray*)obj;
- (NSMutableArray*)getCurrent_Day_WhishList_Items;
- (void)setCurrent_Day_WhishList_Items:(NSMutableArray*)obj;
- (int)getCurrent_Day_App_Visit;
- (void)setCurrent_Day_App_Visit:(int) current_Day_App_Visit;
- (void)incrementCurrent_Day_App_Visit;
- (void)setCurrent_Day_Purchased_Amount:(int)current_Day_Purchased_Amount;
- (void)incrementCurrent_Day_Purchased_Amount:(float)amount;
- (void)incrementCurrent_Day_Purchased_Item:(int)amount;
- (void)setParseUser:(PFUser*)parseUser;
- (void)copyData:(CustomerData*)another;
- (NSString*)getDisplayName;
- (void)setDisplayName:(NSString*) displayName;
- (void)appendData:(PFObject*)from to:(PFObject*)to;







@end
