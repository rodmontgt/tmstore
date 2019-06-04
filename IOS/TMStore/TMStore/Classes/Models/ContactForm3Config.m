//
//  ContactForm3Config.m
//  TMStore
//
//  Created by Rishabh Jain on 05/05/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import "ContactForm3Config.h"

@implementation ContactForm3Config
static ContactForm3Config *sharedInstance = nil;
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
        contactForm3Objects = [[NSMutableArray alloc] init];
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
- (void)addContactForm3Object:(ContactForm3*)obj {
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
    [contactForm3Objects addObject:obj];
}
- (void)resetContactForm3Objects{
    [contactForm3Objects removeAllObjects];
}
- (NSMutableArray*)getContactForm3Objects {
    return contactForm3Objects;
}
- (ContactForm3*)getContactForm3_Name {
    return objName;
}
- (ContactForm3*)getContactForm3_Email {
    return objEmail;
}
- (ContactForm3*)getContactForm3_Message {
    return objMessage;
}
- (ContactForm3*)getContactForm3_Date {
    return objDate;
}
- (ContactForm3*)getContactForm3_Person {
    return objPerson;
}
- (ContactForm3*)getContactForm3_Hour {
    return objHour;
}
- (ContactForm3*)getContactForm3_t332 {
    return objt332;
}
- (ContactForm3*)getContactForm3_Contact {
    return objContact;
}
- (ContactForm3*)getContactForm3_BookingName {
    return objBookingName;
}
@end


@implementation ContactForm3
- (id)init {
    self = [super init];
    if (self) {
        self.label = @"";
        self.shortcode = @"";
        self.type = @"";
        self.options = [[NSMutableArray alloc] init];
        [[ContactForm3Config getInstance] addContactForm3Object:self];
    }
    return self;
}
@end