//
//  ReservationFormConfig.h
//  TMStore
//
//  Created by Rishabh Jain on 05/05/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReservationForm : NSObject
@property NSString* label;
@property NSString* shortcode;
@property NSString* type;
@property NSMutableArray* options;//Array of NSString
@end

@interface ReservationFormConfig : NSObject {
    NSMutableArray* reservationFormObjects;//Array of ReservationForm
    ReservationForm* objName;//nometprenom
    ReservationForm* objEmail;//adresseemail
    ReservationForm* objMessage;//message
    ReservationForm* objDate;//date
    ReservationForm* objPerson;//pers
    ReservationForm* objHour;//heure
    ReservationForm* objt332;//t332
    ReservationForm* objContact;//numerodetel
    ReservationForm* objBookingName;//nomdelareservation
}
@property NSString* form_title;
@property NSString* submit_button_title;
@property BOOL enabled;
@property BOOL isDataFetched;
+ (id)getInstance;
+ (void)resetInstance;
- (void)addReservationFormObject:(ReservationForm*)obj;
- (void)resetReservationFormObjects;
- (NSMutableArray*)getReservationFormObjects;
- (ReservationForm*)getReservationForm_Name;
- (ReservationForm*)getReservationForm_Email;
- (ReservationForm*)getReservationForm_Message;
- (ReservationForm*)getReservationForm_Date;
- (ReservationForm*)getReservationForm_Person;
- (ReservationForm*)getReservationForm_Hour;
- (ReservationForm*)getReservationForm_t332;
- (ReservationForm*)getReservationForm_Contact;
- (ReservationForm*)getReservationForm_BookingName;
@end
