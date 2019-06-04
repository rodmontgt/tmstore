//
//  CustomerData.m
//  TMStore
//
//  Created by Rishabh Jain on 05/05/16.
//  Copyright © 2016 Twist Mobile. All rights reserved.
//
#import "CustomerData.h"
#import "ParseVariables.h"
#import "Variables.h"
@implementation CustomerData

static NSArray* numericColumns = nil;
static NSArray* arrayColumns = nil;
static NSArray* stringColumns = nil;
static PFObject* customerDataObj = nil;
static CustomerData *sharedManager = nil;

+ (CustomerData *)sharedManager {
    if (sharedManager == nil) {
        sharedManager = [[self alloc] init];
    }
    return sharedManager;
}
- (id)init {
    self = [super init];
    if (self) {
        customerDataObj = [PFObject objectWithClassName:PClassCustomerData];
        numericColumns = @[
                           @"Current_Day_App_Visit",
                           @"Current_Day_Purchased_Amount",
                           @"Current_Day_Purchased_Item",
                           @"Today_App_Visit"
                           ];
        arrayColumns = @[
                         @"Current_Day_Purchased_Items",
                         @"Current_Day_Whishlist_Items",
                         @"Current_Month_Cart_Items",
                         @"Current_Month_Purchased_Amount",
                         @"Current_Month_App_Visit",
                         @"Current_Month_WhishList_Items",
                         @"Today_Cart_Items",
                         @"Today_Purchased_Amount",
                         @"Today_WhishList_Items",
                         @"Today_Purchased_Items",
                         @"Current_Day_Cart_Items",
                         @"Current_Day_WhishList_Items"
                         ];
        stringColumns = @[
                          @"FirstName",
                          @"LastName",
                          @"Password",
                          @"Username"
                          ];
    }
    return self;
}
- (PFObject*)getPFInstance {
    return customerDataObj;
}
- (void)setPFInstance:(PFObject*)customerObj {
    customerDataObj = customerObj;
}
- (void)setFirstName:(NSString*)string {
    customerDataObj[@"FirstName"] = string;
}
- (NSString*)getUsername {
    return customerDataObj[@"Username"];
}
- (void)setUsername:(NSString*)string {
    customerDataObj[@"Username"] = string;
}
- (NSString*)getPassword {
    return customerDataObj[@"Password"];
}
- (void)setPassword:(NSString*)string {
    customerDataObj[@"Password"] = string;
}
- (void)setEmailID:(NSString*)string {
    customerDataObj[@"EmailID"] = string;
}
- (void)setLastName:(NSString*)string {
    customerDataObj[@"LastName"] = string;
}
- (NSString*)getAddress {
    return customerDataObj[@"Address"];
}
- (void)setAddress:(NSString*)string {
    customerDataObj[@"Address"] = string;
}
- (NSString*)getState {
    return customerDataObj[@"State"];
}
- (void)setState:(NSString*)string {
    customerDataObj[@"State"] = string;
}
- (void)setApp_Name:(NSString*)string {
    customerDataObj[@"App_Name"] = string;
}
- (NSString*)getDeviceModel {
    return customerDataObj[@"DeviceModel"];
}
- (void)setDeviceModel:(NSString*)string {
    customerDataObj[@"DeviceModel"] = string;
}
- (NSMutableArray*)getCurrent_Day_Cart_Items {
    return [[NSMutableArray alloc] initWithArray:customerDataObj[@"Current_Day_Cart_Items"]];
}
- (void)setCurrent_Day_Cart_Items:(NSMutableArray*)obj {
    if (obj != nil) {
        NSString *string = [obj componentsJoinedByString:@","];
        RLOG(@"setCurrent_Day_Cart_Items = %@", string);
        customerDataObj[@"Current_Day_Cart_Items"] = string;
    } else {
        customerDataObj[@"Current_Day_Cart_Items"] = @"[]";
    }
}
- (NSMutableArray*)getCurrent_Day_Whishlist_Items {
    return [[NSMutableArray alloc] initWithArray:customerDataObj[@"Current_Day_Whishlist_Items"]];
}
- (void)setCurrent_Day_Whishlist_Items:(NSMutableArray*)obj {
    if (obj != nil) {
        NSString *string = [obj componentsJoinedByString:@","];
        RLOG(@"setCurrent_Day_Whishlist_Items = %@", string);
        customerDataObj[@"Current_Day_Whishlist_Items"] = string;
    } else {
        customerDataObj[@"Current_Day_Whishlist_Items"] = @"[]";
    }
}
- (NSMutableArray*)getCurrent_Day_WhishList_Items {
    return [[NSMutableArray alloc] initWithArray:customerDataObj[@"Current_Day_WhishList_Items"]];
}
- (void)setCurrent_Day_WhishList_Items:(NSMutableArray*)obj {
    if (obj != nil) {
        NSString *string = [obj componentsJoinedByString:@","];
        RLOG(@"setCurrent_Day_WhishList_Items = %@", string);
        customerDataObj[@"Current_Day_WhishList_Items"] = string;
    } else {
        customerDataObj[@"Current_Day_WhishList_Items"] = @"[]";
    }
}
- (int)getCurrent_Day_App_Visit {
    return [customerDataObj[@"Current_Day_App_Visit"] intValue];
}
- (void)setCurrent_Day_App_Visit:(int) current_Day_App_Visit {
    customerDataObj[@"Current_Day_App_Visit"] = [NSNumber numberWithInt:current_Day_App_Visit];
}
- (void)incrementCurrent_Day_App_Visit {
    [customerDataObj incrementKey:@"Current_Day_App_Visit"];
}
- (void)setCurrent_Day_Purchased_Amount:(int)current_Day_Purchased_Amount {
    customerDataObj[@"Current_Day_Purchased_Amount"] = [NSNumber numberWithInt:current_Day_Purchased_Amount];
}
- (void)incrementCurrent_Day_Purchased_Amount:(float)amount {
    RLOG(@"incrementCurrent_Day_Purchased_Amount = %f", amount);
    [customerDataObj incrementKey:@"Current_Day_Purchased_Amount" byAmount:[NSNumber numberWithFloat:amount]];
}
- (void)incrementCurrent_Day_Purchased_Item:(int)amount {
    RLOG(@"incrementCurrent_Day_Purchased_Item = %d", amount);
    [customerDataObj incrementKey:@"Current_Day_Purchased_Item" byAmount:[NSNumber numberWithInt:amount]];
}
- (void)setParseUser:(PFUser*)parseUser {
    customerDataObj[@"ParseUser"] = parseUser;
}
- (void)copyData:(CustomerData*)another {
    [self setCurrent_Day_App_Visit:[another getCurrent_Day_App_Visit]];
    [self setCurrent_Day_Cart_Items:[another getCurrent_Day_Cart_Items]];
    [self setCurrent_Day_WhishList_Items:[another getCurrent_Day_WhishList_Items]];
    [self setCurrent_Day_Whishlist_Items:[another getCurrent_Day_Whishlist_Items]];
}
- (NSString*)getDisplayName {
    return customerDataObj[@"displayName"];
}
- (void)setDisplayName:(NSString*) displayName {
    customerDataObj[@"displayName"] = displayName;
}
- (void)appendData:(PFObject*)from to:(PFObject*)to {
    RLOG(@"customerdata_appendData\n from:%@\n to:%@", from, to);
    
    RLOG(@"numericColumns1");
    for (NSString* key in numericColumns) {
        RLOG(@"key = %@", key);
        if (from[key] != NULL) {
            RLOG(@"from[%@] is incremented", key);
            int val = [from[key] intValue];
            [to incrementKey:key byAmount:[NSNumber numberWithInt:val]];
        }else{
            RLOG(@"from[%@] is null", key);
        }
    }
    RLOG(@"numericColumns2");
    
    
    RLOG(@"arrayColumns1");
    for (NSString* key in arrayColumns) {
        RLOG(@"key = %@", key);
        if (from[key] != NULL) {
            //            to.addAll(key, from.getList(key));
            NSMutableArray* array = [[NSMutableArray alloc] initWithArray:to[key]];
            [array addObjectsFromArray:from[key]];
            to[key] = array;
        }else{
            RLOG(@"from[%@] is null", key);
        }
    }
    RLOG(@"arrayColumns2");
    
    RLOG(@"stringColumns1");
    for (NSString* key in stringColumns) {
        RLOG(@"key = %@", key);
        if (from[key] != NULL) {
            to[key] = from[key];
        }else{
            RLOG(@"from[%@] is null", key);
        }
    }
    RLOG(@"stringColumns2");
}

@end
