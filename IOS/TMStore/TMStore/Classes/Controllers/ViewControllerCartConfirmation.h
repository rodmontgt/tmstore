//
//  ViewControllerCartConfirmation.h
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
#import "MultiStoreCheckoutConfig.h"
#import "DDView.h"
//#import "TMMulticastDelegate.h"

@interface ViewControllerCartConfirmation : UIViewController<UIAlertViewDelegate, DDViewDelegate> { //<TMMulticastDelegate>{
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
@property UIView* addressViewBilling;
@property UIView* addressViewShipping;
- (void)reloadAddressView;
@property UIAlertView *alertViewForAddBilling;
@property UIAlertView *alertViewForAddShipping;
@property UIAlertView *alertViewForEditBilling;
@property UIAlertView *alertViewForEditShipping;

@property UIButton* btnAddAddressBilling;
@property UIButton* btnAddAddressShipping;
@property UIButton* btnEditAddressBilling;
@property UIButton* btnEditAddressShipping;
@property UILabel* labelViewHeading;

@property int retryCount_DeliverySlotsCopia;


@property UIView* wccmView;
@property DDView* wccmDeliveryTypes;
@property DDView* wccmClusterDestinations;
@property DDView* wccmHomeDestinations;
@property DDView* wccmDeliveryDays;
@property DDView* wccmDeliveryTimeSlots;

@property NSString* wccmCowDeliveryTypes;
@property NSString* wccmCowClusterDestinations;
@property NSString* wccmCowHomeDestinations;
@property NSString* wccmCowDeliveryDays;
@property NSString* wccmCowDeliveryTimeSlots;


@property NSString* wccmOptionDeliveryTypes;
@property NSString* wccmOptionClusterDestinations;
@property NSString* wccmOptionHomeDestinations;
@property NSString* wccmOptionDeliveryDays;
@property NSString* wccmOptionDeliveryTimeSlots;

- (void)openShippingAddressPopup:(Address*)address;
@end
