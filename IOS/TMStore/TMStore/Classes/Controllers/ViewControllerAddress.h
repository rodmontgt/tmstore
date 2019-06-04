//
//  ViewControllerAddress.h
//  eMobileApp
//
//  Created by Rishabh Jain on 25/11/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "CNPPopupController.h"
#import "Address.h"
#import "NIDropDown.h"
#import "Country.h"
#import <CoreLocation/CoreLocation.h>
#import "AppUser.h"
#import "DataManager.h"
#import "Variables.h"

enum CHKBOX_PROP {
    CHKBOX_PROP_NONE,
    CHKBOX_PROP_COPY_TO_BILLING,
    CHKBOX_PROP_COPY_TO_SHIPPING
};

#import "TMRegion.h"

enum TAGTEXTFIELD {
    _kTAGTEXTFIELD_FIRSTNAME,
    _kTAGTEXTFIELD_LASTNAME,
    _kTAGTEXTFIELD_COMPANY,
    _kTAGTEXTFIELD_ADDRESS1,
    _kTAGTEXTFIELD_ADDRESS2,
    _kTAGTEXTFIELD_CONTACT,
    _kTAGTEXTFIELD_EMAIL,
    _kTAGTEXTFIELD_CITY,
    _kTAGTEXTFIELD_COUNTRY,
    _kTAGTEXTFIELD_STATE,
    _kTAGTEXTFIELD_POSTAL,
    _kTAGTEXTFIELD_DISTRICT,
    _kTAGTEXTFIELD_SUBDISTRICT
};
enum TAGTEXTLABEL {
    _kTAGTEXTLABEL_FIRST_N_LAST_NAME = 101,
    _kTAGTEXTLABEL_FIRST_NAME,
    _kTAGTEXTLABEL_LAST_NAME,
    _kTAGTEXTLABEL_COMPANY,
    _kTAGTEXTLABEL_ADDRESS1,
    _kTAGTEXTLABEL_ADDRESS2,
    _kTAGTEXTLABEL_CONTACT,
    _kTAGTEXTLABEL_EMAIL,
    _kTAGTEXTLABEL_CITY,
    _kTAGTEXTLABEL_POSTAL,
    _kTAGTEXTLABEL_COUNTRY,
    _kTAGTEXTLABEL_STATE,
    _kTAGTEXTLABEL_DISTRICT,
    _kTAGTEXTLABEL_SUBDISTRICT
};
@interface ViewControllerAddress : UIViewController <UITextFieldDelegate, NIDropDownDelegate>{
    IBOutlet UIScrollView *_scrollView;
}
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UIView *lineView;
@property (weak, nonatomic) IBOutlet UINavigationItem *currentItemHeading;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *previousItemHeading;
@property BOOL isAddressOverConfirmationScreen;
@property id vcCartConfirmation;
@property AppUser* appUser;
@property NSMutableArray* billingButtons;
@property NSMutableArray* shippingButtons;
@property NSMutableArray* billingViews;
@property NSMutableArray* shippingViews;
@property UIView* billingHeaderView;
@property UIView* shippingHeaderView;
@property UIButton* buttonEditShipping;
@property UIButton* buttonEditBilling;
@property UIButton* buttonCreateShipping;
@property UIButton* buttonCreateBilling;
@property UIButton* buttonCancel;
@property UIButton* buttonSave;
@property UILabel* labelTitle;
@property UIButton* chkBoxCopyAddress;
@property CGRect addressViewPopupElementRect;
@property UITextField* textFieldFirstResponder;
@property UITextField* textFirstName;
@property UITextField* textLastName;
@property UITextField* textAddress1;
@property UITextField* textAddress2;
@property UITextField* textContactNumber;
@property UITextField* textEmail;
@property UITextField* textPostalCode;
@property UIView* viewMainChildPopoverView;
- (void)editAddressClicked:(id)sender;
- (void)addAddressClicked:(id)sender;
- (IBAction)barButtonBackPressed:(id)sender;

@property Address* editedAddressObj;
@property float keyboardHeight;
@property double duration;
@property UIViewAnimationCurve curve;
@end
