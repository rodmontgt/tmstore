//
//  VCSellerProfile.h
//  TMStore
//
//  Created by Twist Mobile on 29/11/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "ViewControllerSellerZone.h"
@interface VCSellerProfile : UIViewController
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UIView *lineView;
@property (weak, nonatomic) IBOutlet UITableView *tableV;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnbar;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (strong, nonatomic) IBOutlet GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet UIImageView *markerImage;
@property CLLocation *myLocation;
//@property NSMutableArray *profileImgSources;
@property BOOL isProfilePick,isShopPick;
@property UILabel* labelViewHeading;
@property ViewControllerSellerZone* vcSellerZone;

@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
//@property (strong, nonatomic) IBOutlet UIView *lineView;
@property (weak, nonatomic) IBOutlet UINavigationItem *currentItemHeading;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *previousItemHeading;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextItemHeading;
- (IBAction)saveButtonPressed:(id)sender;
- (IBAction)barButtonBackPressed:(id)sender;
//@property (weak, nonatomic) IBOutlet UIView *mainView;

@property UITextField* textFieldFirstResponder;
@property float keyboardHeight;
@property double duration;
@property UIViewAnimationCurve curve;


@end
