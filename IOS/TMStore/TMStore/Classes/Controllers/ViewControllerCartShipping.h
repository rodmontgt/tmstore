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
    SCREEN_STATE_VERIFY_MOBILE_OTP,
    SCREEN_STATE_ENTER,
    SCREEN_STATE_CREATE_BLANK_ORDER_DONE,
    SCREEN_STATE_UPDATE_BLANK_ORDER_DONE,
    SCREEN_STATE_DELIVERY_SLOT_BOOKED,
    SCREEN_STATE_PRODUCT_DELIVERY_SLOT_BOOKED,
    SCREEN_STATE_MULTISTORE_CHECKOUT_MANAGER,
    SCREEN_STATE_PAYMENT_DONE,
    SCREEN_STATE_UPDATE_ORDER_DONE,
    SCREEN_STATE_EXIT
};

@interface ViewControllerCartShipping : UIViewController <TMPaymentSDKDelegate, UITextViewDelegate, FPPopoverControllerDelegate, NIDropDownDelegate, UITextFieldDelegate>{ //<TMMulticastDelegate>{
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

//@property NSMutableArray* chkBoxShipping;
@property NSMutableArray* chkBoxShippingOuterArray;
@property NSMutableArray* chkBoxPayment;
@property TMPaymentGateway* selectedPaymentGateway;
@property NSMutableArray* selectedShippingMethod;//TMShipping*
@property NSString* selectedShippingMethodId;
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

@property UIView* feeView;
@property UIView* feeViewHeader;
@property float feeViewHeaderHeight;


@property NSMutableDictionary* shippingBunches;
@property NSMutableArray* checkoutAddonCheckboxes;

@property UIView* viewGrandTotal;

#pragma mark OTP
@property NSString* registerMobileNumber;
@property NSString* registerMobileNumberNew;
@property float OTPResendTimerForeground;
@property float OTPResendTimerBackground;
@property UIButton* OTPButtonResend;
@property UIButton* OTPButtonVerify;
//@property UIButton* otp_button_mobile;
@property UITextField* otp_button_mobile;
@property UITextField* otp_textfield_code;
@property UIButton* otp_button_timer;
@property NSTimer* otp_timer_foreground;
@property NSTimer* otp_timer_background;
@property NSString* registerMobileNumberOTP;



@property UITextField* otp_textfield_mobile;
@property UIButton* otp_button_ok;
@property UIButton* otp_button_update;

@end
