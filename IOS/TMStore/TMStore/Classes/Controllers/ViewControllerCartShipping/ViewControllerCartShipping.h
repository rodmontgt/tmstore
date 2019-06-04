//
//  ViewControllerCartShipping.h
//  eMobileApp
//
//  Created by Rishabh Jain on 25/11/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Address.h"
#import "Cart.h"
#import "Utility.h"
#import "AppUser.h"
#import "Order.h"
#import <TMPaymentSDK/TMPaymentSDK.h>
#import "TMShipping.h"
#import "DateTimeSlot.h"
#import "TimeSlot.h"
#import "TM_PickupLocation.h"
//#import "TMMulticastDelegate.h"

#import "FPPopoverController.h"

enum SCREEN_STATE {
    SCREEN_STATE_ENTER,
    SCREEN_STATE_CREATE_BLANK_ORDER_DONE,
    SCREEN_STATE_UPDATE_BLANK_ORDER_DONE,
    SCREEN_STATE_DELIVERY_SLOT_BOOKED,
    SCREEN_STATE_PAYMENT_DONE,
    SCREEN_STATE_UPDATE_ORDER_DONE,
    SCREEN_STATE_EXIT
};

@interface ViewControllerCartShipping : UIViewController <TMPaymentSDKDelegate, UITextViewDelegate, FPPopoverControllerDelegate, NIDropDownDelegate>{ //<TMMulticastDelegate>{
    IBOutlet UIScrollView *_scrollView;
}
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UIView *lineView;
@property (weak, nonatomic) IBOutlet UINavigationItem *currentItemHeading;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *previousItemHeading;
- (IBAction)barButtonBackPressed:(id)sender;

@property UIImageView* topImage;
@property UIButton* btnProceed;

@property float defaultHeight;

@property NSMutableArray* chkBoxShipping;
@property NSMutableArray* chkBoxPayment;
@property TMPaymentGateway* selectedPaymentGateway;
@property TMShipping* selectedShippingMethod;
@property UILabel* labelGrandAmount;

@property Order *blankOrder;
@property int screen_current_state;
@property UILabel* labelViewHeading;

@property float keyboardHeight;
@property double duration;
@property UIViewAnimationCurve curve;
@property UITextView* textView;

@property UITextView* textViewFirstResponder;
@property UILabel* labelErrorMsgShippingInfo;


@property TimeSlot* selected_time_slot;
@property DateTimeSlot* selected_date_time_slot;
@property TM_PickupLocation* selected_pickup_location;

@property NSMutableArray* availableTimeSlots;
@property NSMutableArray* availableDateTimeSlots;
@property NSMutableArray* availablePickupLocations;

//@property UITextField* textFieldDatePicker;
@property UIButton* buttonDateSelection;
@property UIButton* buttonTimeSelection;
@property UIButton* buttonPickupSelection;

@property UIButton* buttonDateSelectionDownArrow;
@property UIButton* buttonTimeSelectionDownArrow;
@property UIButton* buttonPickupSelectionDownArrow;

@property NIDropDown* ddViewTimeSelection;
@property NIDropDown* ddViewPickupSelection;

@property NSArray* timeSlotDataObjects;
@property NSArray* pickupDataObjects;
@property NSMutableArray* appliedTaxes;
@property UIView* taxView;
@property UIView* taxViewHeader;
@end
