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
    _kTAGTEXTLABEL_CITY_N_POSTAL,
    _kTAGTEXTLABEL_CITY,
    _kTAGTEXTLABEL_POSTAL,
    _kTAGTEXTLABEL_COUNTRY,
    _kTAGTEXTLABEL_STATE,
};
@interface ViewControllerAddress : UIViewController <UITextFieldDelegate, NIDropDownDelegate>{
    IBOutlet UIScrollView *_scrollView;
}
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UIView *lineView;
@property (weak, nonatomic) IBOutlet UINavigationItem *currentItemHeading;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *previousItemHeading;
- (IBAction)barButtonBackPressed:(id)sender;

@property UIView* billingHeaderView;
@property UIView* shippingHeaderView;
@property NSMutableArray* billingViews;
@property NSMutableArray* shippingViews;
@property float defaultHeight;
@property Address* editAddress;
@property Address* tempAddress;
@property UIButton* buttonCancel;
@property UIButton* buttonSave;
@property UILabel* labelTitle;
@property UITextField* textFirstName;
@property UITextField* textLastName;
@property UITextField* textAddress1;
@property UITextField* textAddress2;
@property UITextField* textContactNumber;
@property UITextField* textEmail;
@property UITextField* textCountry;
@property UITextField* textCity;
@property UITextField* textState;
@property UITextField* textPostalCode;
@property UIButton* chkBoxCopyAddress;
@property NSMutableArray* billingButtons;
@property NSMutableArray* shippingButtons;
@property NIDropDown *dropdownViewCountry;
@property NIDropDown *dropdownViewState;
@property UIButton* countrySelectionButton;
@property UIButton* stateSelectionButton;
@property TMCountry* selectedCountry;
@property TMState* selectedState;
@property UIImageView * countrySelectionArrow;
@property UIImageView * stateSelectionArrow;
@property AppUser *appUser;
@property DataManager* dataManager;

@property BOOL isAddressOverConfirmationScreen;
@property id vcCartConfirmation;
@property UIButton* buttonEditShipping;
@property UIButton* buttonEditBilling;
@property UIButton* buttonCreateShipping;
@property UIButton* buttonCreateBilling;

- (void)editAddressClicked:(id)sender;
- (void)addAddressClicked:(id)sender;
@property UITextField* textFieldFirstResponder;
@property Address* addressFailedToSubmit;
@property NSString* addressFailedToSubmitCountryId;
@property NSString* addressFailedToSubmitStateId;
@property CGRect addressViewPopupElementRect;
@property UILabel* labelViewHeading;
@end
