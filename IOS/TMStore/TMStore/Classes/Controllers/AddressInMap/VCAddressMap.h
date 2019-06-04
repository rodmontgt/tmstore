//
//  VCAddressMap.h
//  GoogleMapsDemo
//
//  Created by Raj Shekar on 30/06/17.
//  Copyright © 2017 TwistMobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "ViewControllerMain.h"
#import "MapAddress.h"
@interface VCAddressMap : UIViewController
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) IBOutlet UIView *lineView;
@property (weak, nonatomic) IBOutlet UINavigationItem *currentItemHeading;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *previousItemHeading;
//@property (weak, nonatomic) ViewControllerMain *vcMain;
- (IBAction)barButtonBackPressed:(id)sender;
@property UILabel* labelViewHeading;

@property CLPlacemark* selectedPlacemark;
@property GMSCameraPosition* selectedPosition;

@property GMSMarker* selectedMarker;

- (void)setShippingAddresses:(NSArray*)array;
@end

