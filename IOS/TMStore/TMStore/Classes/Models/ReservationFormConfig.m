//
//  ReservationFormConfig.m
//  TMStore
//
//  Created by Rishabh Jain on 05/05/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import "ReservationFormConfig.h"

@implementation ReservationFormConfig
static ReservationFormConfig *sharedInstance = nil;
+ (id)getInstance {
    @synchronized(self) {
        if (sharedInstance == nil)
            sharedInstance = [[self alloc] init];
    }
    return sharedInstance;
}
+ (void)resetInstance {
    sharedInstance = nil;
}


- (id)init {
    self = [super init];
    if (self) {
        reservationFormObjects = [[NSMutableArray alloc] init];
        self.form_title = @"";
        self.submit_button_title = @"";
        self.enabled = false;
        objName = nil;
        objEmail = nil;
        objMessage = nil;
        objDate = nil;
        objPerson = nil;
        objHour = nil;
        objt332 = nil;
        objContact = nil;
        objBookingName = nil;
        self.isDataFetched = false;
    }
    return self;
}
- (void)addReservationFormObject:(ReservationForm*)obj {
    if ([[obj.shortcode lowercaseString] isEqualToString:@"nometprenom"]) {
        objName = obj;
    }
    else if ([[obj.shortcode lowercaseString] isEqualToString:@"adresseemail"]) {
        objEmail = obj;
    }
    else if ([[obj.shortcode lowercaseString] isEqualToString:@"message"]) {
        objMessage = obj;
    }
    else if ([[obj.shortcode lowercaseString] isEqualToString:@"date"]) {
        objDate = obj;
    }
    else if ([[obj.shortcode lowercaseString] isEqualToString:@"pers"]) {
        objPerson = obj;
    }
    else if ([[obj.shortcode lowercaseString] isEqualToString:@"heure"]) {
        objHour = obj;
    }
    else if ([[obj.shortcode lowercaseString] isEqualToString:@"t332"]) {
        objt332 = obj;
    }
    else if ([[obj.shortcode lowercaseString] isEqualToString:@"numerodetel"]) {
        objContact = obj;
    }
    else if ([[obj.shortcode lowercaseString] isEqualToString:@"nomdelareservation"]) {
        objBookingName = obj;
    }
    [reservationFormObjects addObject:obj];
}
- (void)resetReservationFormObjects{
    [reservationFormObjects removeAllObjects];
}
- (NSMutableArray*)getReservationFormObjects {
    return reservationFormObjects;
}
- (ReservationForm*)getReservationForm_Name {
    return objName;
}
- (ReservationForm*)getReservationForm_Email {
    return objEmail;
}
- (ReservationForm*)getReservationForm_Message {
    return objMessage;
}
- (ReservationForm*)getReservationForm_Date {
    return objDate;
}
- (ReservationForm*)getReservationForm_Person {
    return objPerson;
}
- (ReservationForm*)getReservationForm_Hour {
    return objHour;
}
- (ReservationForm*)getReservationForm_t332 {
    return objt332;
}
- (ReservationForm*)getReservationForm_Contact {
    return objContact;
}
- (ReservationForm*)getReservationForm_BookingName {
    return objBookingName;
}
@end


@implementation ReservationForm
- (id)init {
    self = [super init];
    if (self) {
        self.label = @"";
        self.shortcode = @"";
        self.type = @"";
        self.options = [[NSMutableArray alloc] init];
        [[ReservationFormConfig getInstance] addReservationFormObject:self];
    }
    return self;
}
@end