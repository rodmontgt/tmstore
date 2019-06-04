//
//  ContactForm3Config.h
//  TMStore
//
//  Created by Rishabh Jain on 05/05/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContactForm3 : NSObject
@property NSString* label;
@property NSString* shortcode;
@property NSString* type;
@property NSMutableArray* options;//Array of NSString
@end

@interface ContactForm3Config : NSObject {
    NSMutableArray* contactForm3Objects;//Array of ContactForm3
    ContactForm3* objName;//nometprenom
    ContactForm3* objEmail;//adresseemail
    ContactForm3* objMessage;//message
    ContactForm3* objDate;//date
    ContactForm3* objPerson;//pers
    ContactForm3* objHour;//heure
    ContactForm3* objt332;//t332
    ContactForm3* objContact;//numerodetel
    ContactForm3* objBookingName;//nomdelareservation
}
@property NSString* form_title;
@property NSString* submit_button_title;
@property BOOL enabled;
@property BOOL isDataFetched;
+ (id)getInstance;
+ (void)resetInstance;

- (void)addContactForm3Object:(ContactForm3*)obj;
- (void)resetContactForm3Objects;
- (NSMutableArray*)getContactForm3Objects;
- (ContactForm3*)getContactForm3_Name;
- (ContactForm3*)getContactForm3_Email;
- (ContactForm3*)getContactForm3_Message;
- (ContactForm3*)getContactForm3_Date;
- (ContactForm3*)getContactForm3_Person;
- (ContactForm3*)getContactForm3_Hour;
- (ContactForm3*)getContactForm3_t332;
- (ContactForm3*)getContactForm3_Contact;
- (ContactForm3*)getContactForm3_BookingName;
@end
