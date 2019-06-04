//
//  VCAddressMap.m
//  GoogleMapsDemo
//
//  Created by Raj Shekar on 30/06/17.
//  Copyright © 2017 TwistMobile. All rights reserved.
//

#import "VCAddressMap.h"
#import <CoreLocation/CoreLocation.h>
#import <GooglePlaces/GooglePlaces.h>
#import "Utility.h"
#import "ViewControllerCartConfirmation.h"
#import "MapAddress.h"
//#import "AddressViewController.h"//TODO
#define CODE_SAME_AS_ANDROID 0
@interface VCAddressMap ()<GMSMapViewDelegate,CLLocationManagerDelegate,UISearchBarDelegate,GMSAutocompleteViewControllerDelegate,GMSAutocompleteResultsViewControllerDelegate,GMSAutocompleteTableDataSourceDelegate,UISearchDisplayDelegate>

@end
@implementation VCAddressMap {
    CLLocationManager *locationManager;
    CLLocation *myLocation;
    GMSCircle *circle;
    GMSMarker *destinationMarker;
    CLLocationCoordinate2D destinationCoordinate;
    CGFloat currentZoom;
    IBOutlet UILabel *shippingLabel;
    IBOutlet UIButton *buttonAddShipping;
    IBOutlet UISearchBar *locationSearch;
    IBOutlet UIButton *buttonProceed;
    IBOutlet UILabel *lblLocationName;
    __weak IBOutlet UIView *viewAddress;
    __weak IBOutlet GMSMapView *googleMaps;
    GMSAutocompleteResultsViewController *resultsViewController;
    UISearchController *searchController;
    GMSAutocompleteTableDataSource *tableDataSource;
    UISearchDisplayController *searchDisplayController;
    UISearchBar *searchBar;
    NSMutableArray *arrayOfAddress;
    NSMutableArray *arrayOfMarker;
    CLLocationDegrees *savedLat;
    CLLocationDegrees *savedLong;
    CLLocationCoordinate2D savedCoord;
    UIButton *customBackButton;
    IBOutlet UIImageView *markerImage;
    IBOutlet UILabel *shippingAddressLabel;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    arrayOfMarker = [[NSMutableArray alloc] init];
    
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [Utility getUIColor:kUIColorThemeFont], NSForegroundColorAttributeName, [Utility getUIFont:kUIFontType24 isBold:false], NSFontAttributeName, nil]];
    [self.currentItemHeading setTitle:@"    "];
    
    _labelViewHeading = [[UILabel alloc] init] ;
    [_labelViewHeading setFrame:CGRectMake(0, 20, [[MyDevice sharedManager] screenSize].width, _navigationBar.frame.size.height)];
    [_labelViewHeading setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [_labelViewHeading setUIFont:kUIFontType24 isBold:false];
    [_labelViewHeading setTextColor:[Utility getUIColor:kUIColorThemeFont]];
    [_labelViewHeading setTextAlignment:NSTextAlignmentCenter];
    [_labelViewHeading setText:Localize(@"Select Shipping Address")];
    [self.view addSubview:_labelViewHeading];
    
    [_navigationBar setClipsToBounds:false];
    [_lineView setBackgroundColor:[Utility getUIColor:kUIColorBorder]];
//    [_scrollView setBackgroundColor:[Utility getUIColor:kUIColorBgTheme]];
    [self.view setBackgroundColor:[Utility getUIColor:kUIColorBgHeader]];
    [_navigationBar setBarTintColor:[Utility getUIColor:kUIColorBgHeader]];
    customBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [customBackButton setImage:[[UIImage imageNamed:@"img_arrow_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [customBackButton addTarget:self action:@selector(barButtonBackPressed:)forControlEvents:UIControlEventTouchUpInside];
    [customBackButton setTitle:[NSString stringWithFormat:@"  %@  ", Localize(@"i_back")] forState:UIControlStateNormal];
    [customBackButton setTintColor:[Utility getUIColor:kUIColorThemeFont]];
    [customBackButton setTitleColor:[Utility getUIColor:kUIColorThemeFont] forState:UIControlStateNormal];
    [customBackButton.titleLabel setUIFont:kUIFontType18 isBold:false];
    
    [customBackButton sizeToFit];
    [_previousItemHeading setCustomView:customBackButton];
    [_previousItemHeading setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[Utility getUIColor:kUIColorThemeFont], NSForegroundColorAttributeName, [Utility getUIFont:kUIFontType18 isBold:false], NSFontAttributeName, nil] forState:UIControlStateNormal];
    
    [buttonAddShipping setBackgroundColor:[UIColor clearColor]];
    [buttonAddShipping.titleLabel setTextColor:[UIColor clearColor]];
    [buttonAddShipping.layer setBorderColor:[UIColor clearColor].CGColor];
    [shippingLabel setBackgroundColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
    [shippingLabel setTextColor:[Utility getUIColor:kUIColorBuyButtonFont]];
    [viewAddress setBackgroundColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
    [lblLocationName setBackgroundColor:[UIColor clearColor]];
    [lblLocationName setTextColor:[Utility getUIColor:kUIColorBuyButtonFont]];
    [buttonProceed setBackgroundColor:[UIColor clearColor]];
    [buttonProceed.layer setBorderColor:[Utility getUIColor:kUIColorBuyButtonFont].CGColor];
    [buttonProceed.titleLabel setTextColor:[Utility getUIColor:kUIColorBuyButtonFont]];
    [buttonProceed setTitle:Localize(@"Proceed") forState:UIControlStateNormal];
    [shippingLabel setText:Localize(@"Add New Address")];
    
    shippingLabel.layer.cornerRadius = 5.0f;
    shippingLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    shippingLabel.layer.borderWidth = 2.0f;
    buttonAddShipping.layer.cornerRadius = 5.0f;
    buttonAddShipping.layer.borderColor = [UIColor whiteColor].CGColor;
    buttonAddShipping.layer.borderWidth = 2.0f;
    
    
    
    [shippingAddressLabel setBackgroundColor:[UIColor darkGrayColor]];
    [shippingAddressLabel setTextColor:[UIColor whiteColor]];
    [shippingAddressLabel setText:Localize(@"Selected Shipping Address")];
    [markerImage setHidden:YES];
    [shippingAddressLabel setHidden:YES];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    currentZoom = 6.0f;
    
   
//    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:myLocation.coordinate.latitude longitude: myLocation.coordinate.longitude zoom:20];
// googleMaps.camera = camera;
    googleMaps.myLocationEnabled = YES;
    googleMaps.delegate = self;
    googleMaps.settings.compassButton = YES;
    googleMaps.settings.myLocationButton = YES;
    googleMaps.settings.zoomGestures = YES;
   //rounded button
//    buttonAddShipping.layer.cornerRadius = buttonAddShipping.frame.size.width/2;
//    buttonAddShipping.clipsToBounds = YES;
    buttonProceed.layer.cornerRadius = 5.0f;
    buttonProceed.layer.borderColor = [UIColor whiteColor].CGColor;
    buttonProceed.layer.borderWidth = 2.0f;
    buttonProceed.clipsToBounds = YES;
    //GMSAutocompleteViewController
    GMSAutocompleteViewController *acController = [[GMSAutocompleteViewController alloc] init];
    acController.delegate = self;
    [self presentViewController:acController animated:YES completion:nil];
    resultsViewController = [[GMSAutocompleteResultsViewController alloc] init];
    resultsViewController.delegate = self;
    tableDataSource = [[GMSAutocompleteTableDataSource alloc] init];
    tableDataSource.delegate = self;
    searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:locationSearch contentsController:self];
    searchDisplayController.searchResultsDataSource = tableDataSource;
    searchDisplayController.searchResultsDelegate = tableDataSource;
    searchDisplayController.delegate = self;
//    arrayOfAddress = @[@{@"location": [[CLLocation alloc]initWithLatitude:17.3850 longitude:78.4867]},
//                      @{@"location": [[CLLocation alloc]initWithLatitude:13.0827 longitude:80.2707]},
//                      @{@"location": [[CLLocation alloc]initWithLatitude:12.9716 longitude:77.5946]},
//            ];
//    for (NSDictionary* dict in arrayOfAddress) {
//        GMSMarker *marker = [[GMSMarker alloc] init];
//        marker.position = [(CLLocation*)dict[@"location"] coordinate];
//        marker.appearAnimation = kGMSMarkerAnimationPop;
//        marker.map = googleMaps;
//    }
//    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"savedLocation"]) {
//        lblLocationName.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"addressOfLoc"];
//        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:26.9124 longitude:75.7873 zoom:20];
//        GMSMarker *mark = [[GMSMarker alloc]init];
//        mark.position = CLLocationCoordinate2DMake(26.9124, 75.7873);
//        mark.map = googleMaps;
//        [googleMaps animateToCameraPosition:camera];
//    }
    
    
    
    
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        locationSearch.transform = CGAffineTransformMakeScale(-1, 1);
        googleMaps.transform = CGAffineTransformMakeScale(-1, 1);
        [shippingLabel setUIFont:kUIFontType14 isBold:true];
        [lblLocationName setUIFont:kUIFontType16 isBold:false];
        [lblLocationName setTextAlignment:NSTextAlignmentRight];
        [buttonProceed.titleLabel setUIFont:kUIFontType14 isBold:true];
        [shippingAddressLabel setUIFont:kUIFontType12 isBold:false];
    } else {
        [lblLocationName setTextAlignment:NSTextAlignmentLeft];
    }
    
    
    shippingLabel.layer.cornerRadius = 0.0f;
    shippingLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    shippingLabel.layer.borderWidth = 2.0f;
    [Utility showShadow:shippingLabel];
    [shippingLabel setBackgroundColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
    [shippingLabel setTextColor:[Utility getUIColor:kUIColorBuyButtonFont]];
    [shippingLabel.layer setBorderColor:[UIColor whiteColor].CGColor];
    
    buttonAddShipping.layer.cornerRadius = 0.0f;
    buttonAddShipping.layer.borderColor = [UIColor clearColor].CGColor;
    buttonAddShipping.layer.borderWidth = 2.0f;
    [buttonAddShipping setBackgroundColor:[UIColor clearColor]];
    [buttonAddShipping.titleLabel setTextColor:[UIColor clearColor]];
    [buttonAddShipping.layer setBorderColor:[UIColor clearColor].CGColor];

}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:googleMaps.myLocation.coordinate.latitude longitude:googleMaps.myLocation.coordinate.longitude zoom:20];
//    googleMaps.camera = camera;
//    [googleMaps animateToCameraPosition:camera];
    
    
    
//    for (UIView *object in googleMaps.subviews) {
//        if([[[object class] description] isEqualToString:@"GMSUISettingsView"] )
//        {
//            for(UIView *view in object.subviews) {
//                if([[[view class] description] isEqualToString:@"UIButton"] ) {
//                    CGRect frame = view.frame;
//                    frame.origin.y -= 60;
//                    view.frame = frame;
//                }
//            }
//            
//        }
//    };
    

}
- (void)setShippingAddresses:(NSArray*)array {
    
    arrayOfAddress = [MapAddress getAllAddressesWithLatLong];
    [arrayOfMarker removeAllObjects];
//    arrayOfAddress = [[NSMutableArray alloc] init];
    if ([arrayOfAddress count] > 0) {
        RLOG(@"arrayOfAddress=%@", arrayOfAddress);
        for (MapAddress* mAdd in arrayOfAddress) {
            GMSMarker *marker = [[GMSMarker alloc] init];
            [arrayOfMarker addObject:marker];
            CLLocation* clLoc = [[CLLocation alloc] initWithLatitude:[mAdd.shipping_lat floatValue] longitude:[mAdd.shipping_lng floatValue]];
            marker.position = [clLoc coordinate];
            marker.appearAnimation = kGMSMarkerAnimationPop;
            marker.map = googleMaps;
            [marker.layer setValue:mAdd forKey:@"MAP_ADDRESS"];
            CLGeocoder *ceo = [[CLGeocoder alloc]init];
            CLLocation *loc = [[CLLocation alloc]initWithLatitude:marker.position.latitude longitude:marker.position.longitude]; //insert your coordinate
            [ceo reverseGeocodeLocation:loc
                      completionHandler:^(NSArray *placemarks, NSError *error) {
                          CLPlacemark *placemark = [placemarks objectAtIndex:0];
                          // Check if any placemarks were found
                          if (error == nil && [placemarks count] > 0) {
                              marker.title = [NSString stringWithFormat:@"%@",[[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "]];
                              self.selectedMarker = marker;
                          }
                          else {
                              NSLog(@"Could not locate");
                          }
                      }
             ];
        }
//        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"savedLocation"])
        
//        if (arrayOfAddress && [arrayOfAddress count] > 0) {
//            NSDictionary* dict = [arrayOfAddress objectAtIndex:0];
//            lblLocationName.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"addressOfLoc"];
//            GMSMarker *mark = [[GMSMarker alloc]init];
//            mark.position = [(CLLocation*)dict[@"location"] coordinate];
//            mark.map = googleMaps;
//            GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:mark.position.latitude longitude:mark.position.longitude zoom:20];
//            [googleMaps animateToCameraPosition:camera];
//        }
    } else {
        RLOG(@"user is either not logged-in or no previous addresses found.");
    }
}
#pragma mark - Custom method
- (void)updateLocationCoordinates:(CLLocationCoordinate2D)coordinates{
    if (destinationMarker==nil) {
        destinationMarker = [[GMSMarker alloc] init];
        destinationMarker.position = coordinates;
        destinationMarker.map = googleMaps;
        googleMaps.selectedMarker = destinationMarker;
        //        destinationMarker.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
        //        destinationMarker.appearAnimation = kGMSMarkerAnimationPop;
    } else{
//        [CATransaction begin];
//        [CATransaction setAnimationDuration:0.1];
//        destinationMarker.position = coordinates;
//        [CATransaction commit];
    }
}
#pragma mark - CLLocationManagerDelegate method
/*
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{

    myLocation = [locations lastObject];

    if (myLocation != nil){
        NSLog(@"The latitude value is  %@",[NSString stringWithFormat:@"%.8f", myLocation.coordinate.latitude]);
        NSLog(@"The logitude value is  %@",[NSString stringWithFormat:@"%.8f", myLocation.coordinate.longitude]);
    }

//
//    //Current
//    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:myLocation.coordinate.latitude longitude: myLocation.coordinate.longitude zoom:18];
//    googleMaps.camera = camera;
//    googleMaps.myLocationEnabled = YES;
//    googleMaps.settings.myLocationButton = YES;
//    googleMaps.delegate = self;

//    GMSMarker *marker = [[GMSMarker alloc] init];
//    marker.position = CLLocationCoordinate2DMake(myLocation.coordinate.latitude, myLocation.coordinate.longitude);
//    marker.map = googleMaps;

}
 */
#pragma mark - Mapview Delegate method
- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position{
    NSLog(@"%f\n%f",position.target.latitude,position.target.longitude);
    //set destination marker
    CLLocation *destinationLoc = [[CLLocation alloc]init];
    destinationLoc = [[CLLocation alloc]initWithLatitude:position.target.latitude longitude:position.target.longitude];
    destinationCoordinate = destinationLoc.coordinate;
    // [self updateLocationCoordinates:destinationCoordinate];
}
- (void)savePersonArrayData:(CLPlacemark *)personObject {
    NSMutableArray* mutableDataArray = [[NSMutableArray alloc] init];
    [mutableDataArray addObject:personObject];
    NSMutableArray *archiveArray = [NSMutableArray arrayWithCapacity:mutableDataArray.count];
    for (CLPlacemark *personObject in mutableDataArray) {
        NSData *personEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:personObject];
        [archiveArray addObject:personEncodedObject];
    }
    
    NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
    [userData setObject:archiveArray forKey:@"personDataArray"];
}
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    if (locations) {
        CLLocation* cLoc = [locations lastObject];
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:cLoc.coordinate.latitude longitude:cLoc.coordinate.longitude zoom:20];
        googleMaps.camera = camera;
        [googleMaps animateToCameraPosition:camera];
    }
    [locationManager stopUpdatingLocation];
    
    
    arrayOfAddress = [MapAddress getAllAddressesWithLatLong];
    if (arrayOfAddress == nil || (arrayOfAddress && [arrayOfAddress count] == 0)) {
        [self selectShippingaddress:nil];
    } else {
        float lat = -1.0f;
        float lng = -1.0f;
        if ([[NSUserDefaults standardUserDefaults] valueForKey:@"LAST_SAVED_LATITUTE"]) {
            lat = [[[NSUserDefaults standardUserDefaults] valueForKey:@"LAST_SAVED_LATITUTE"] floatValue];
        }
        if ([[NSUserDefaults standardUserDefaults] valueForKey:@"LAST_SAVED_LONGITUDE"]) {
            lng = [[[NSUserDefaults standardUserDefaults] valueForKey:@"LAST_SAVED_LONGITUDE"] floatValue];
        }
        if (lat != -1.0f && lng != -1.0f) {
            for (MapAddress* mAdd in arrayOfAddress) {
                if([mAdd.shipping_lat floatValue] == lat && [mAdd.shipping_lng floatValue] == lng) {
                    NSLog(@"Previous Selected Latitude n Longitude = %f, %f", lat, lng);
//                    arrayOfMarker
                    GMSMarker* selectedMarker = nil;
                    if (arrayOfMarker) {
                        for (GMSMarker* marker in arrayOfMarker) {
                            if ([marker.layer valueForKey:@"MAP_ADDRESS"]) {
                                MapAddress* mAddTemp = [marker.layer valueForKey:@"MAP_ADDRESS"];
                                if (mAddTemp == mAdd) {
                                    selectedMarker = marker;
                                    break;
                                }
                            }
                        }
                    }
                    if (selectedMarker) {
                        [googleMaps setSelectedMarker:selectedMarker];
                        [self mapView:googleMaps didTapMarker:selectedMarker];
                    }
                    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:lat longitude:lng zoom:20];
                    googleMaps.camera = camera;
                    [googleMaps animateToCameraPosition:camera];
                }
            }
        }
    }
}
- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position{
    CLGeocoder *ceo = [[CLGeocoder alloc]init];
    CLLocation *loc = [[CLLocation alloc]initWithLatitude:position.target.latitude longitude:position.target.longitude]; //insert your coordinates
    [ceo reverseGeocodeLocation:loc
              completionHandler:^(NSArray *placemarks, NSError *error) {
                  // Check if any placemarks were found
                  if (error == nil && placemarks && [placemarks count] > 0) {
                      CLPlacemark *placemark = [placemarks objectAtIndex:0];
                      NSLog(@"AddressDict:%@",placemark.addressDictionary);
                      lblLocationName.text = [NSString stringWithFormat:@"%@",[[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "]];
                      NSString *valueToSave = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
                      [[NSUserDefaults standardUserDefaults] setObject:valueToSave forKey:@"addressOfLoc"];
                      
                      self.selectedPlacemark = placemark;
                      self.selectedPosition = position;
                      [[NSUserDefaults standardUserDefaults] synchronize];
                      NSNumber *lat = [NSNumber numberWithDouble:position.target.latitude];
                      NSNumber *lon = [NSNumber numberWithDouble:position.target.longitude];
                      NSDictionary *userLocation=@{@"lat":lat,@"long":lon};
                      //NSLog(@"Dict of savedLoc:%@",userLocation);
                      [[NSUserDefaults standardUserDefaults] setObject:userLocation forKey:@"savedLocation"];
                  } else {
                      NSLog(@"Could not locate");
                  }
              }
     ];
}
/*
- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker{
    UIView *infoView = [[UIView alloc] init];
    infoView.frame = CGRectMake(0, 0, 150, 35);
    UILabel *labelInfo = [[UILabel alloc]init];
    labelInfo.frame = CGRectMake(0, 0, 150, 35);
    labelInfo.text = Localize(@"Selected Shipping Address");
    labelInfo.textColor = [UIColor whiteColor];
    labelInfo.textAlignment = NSTextAlignmentCenter;
    labelInfo.numberOfLines = 0;
//    labelInfo.font = [UIFont systemFontOfSize:12.0f];
    [labelInfo setUIFont:kUIFontType12 isBold:false];
    [infoView addSubview:labelInfo];
    infoView.backgroundColor = [UIColor darkGrayColor];
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        infoView.transform = CGAffineTransformMakeScale(-1, 1);
    }
    return infoView;
}
*/
#pragma mark - GMSAutoComplete Delegate method
// Handle the user's selection.
- (void)viewController:(GMSAutocompleteViewController *)viewController
didAutocompleteWithPlace:(GMSPlace *)place {
    [self dismissViewControllerAnimated:YES completion:nil];
    // Do something with the selected place.
    NSLog(@"Place name %@", place.name);
    NSLog(@"Place address %@", place.formattedAddress);
    NSLog(@"Place attributions %@", place.attributions.string);
}
- (void)viewController:(GMSAutocompleteViewController *)viewController
didFailAutocompleteWithError:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
    // TODO: handle the error.
    NSLog(@"Error: %@", [error description]);
}
// User canceled the operation.
- (void)wasCancelled:(GMSAutocompleteViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}
// Turn the network activity indicator on and off again.
- (void)didRequestAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}
- (void)didUpdateAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
// Handle the user's selection.
- (void)resultsController:(GMSAutocompleteResultsViewController *)resultsController
 didAutocompleteWithPlace:(GMSPlace *)place {
    searchController.active = NO;
    // Do something with the selected place.
    NSLog(@"Place name %@", place.name);
    NSLog(@"Place address %@", place.formattedAddress);
    NSLog(@"Place attributions %@", place.attributions.string);
}
- (void)resultsController:(GMSAutocompleteResultsViewController *)resultsController
didFailAutocompleteWithError:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
    // TODO: handle the error.
    NSLog(@"Error: %@", [error description]);
}
// Turn the network activity indicator on and off again.
- (void)didRequestAutocompletePredictionsForResultsController:
(GMSAutocompleteResultsViewController *)resultsController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}
- (void)didUpdateAutocompletePredictionsForResultsController:
(GMSAutocompleteResultsViewController *)resultsController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchString:(NSString *)searchString {
    [tableDataSource sourceTextHasChanged:searchString];
    return NO;
}
// Handle the user's selection.
- (void)tableDataSource:(GMSAutocompleteTableDataSource *)tableDataSource
didAutocompleteWithPlace:(GMSPlace *)place {
    [searchDisplayController setActive:NO animated:YES];
    // Do something with the selected place.
    NSLog(@"Place name %@", place.name);
    NSLog(@"Place address %@", place.formattedAddress);
    NSLog(@"Place attributions %@", place.attributions.string);
    //  search address on MAP
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:place.coordinate.latitude longitude:place.coordinate.longitude zoom:20];
    [googleMaps animateToCameraPosition:camera];
    CLGeocoder *ceo = [[CLGeocoder alloc]init];
    CLLocation *loc = [[CLLocation alloc]initWithLatitude:place.coordinate.latitude longitude:place.coordinate.longitude]; //insert your coordinates
    [ceo reverseGeocodeLocation:loc
              completionHandler:^(NSArray *placemarks, NSError *error) {
                  CLPlacemark* placemark = [placemarks objectAtIndex:0];
                  // Check if any placemarks were found
                  if (error == nil && [placemarks count] > 0) {
                      NSLog(@"addressDictionary:%@",placemark.addressDictionary);
                      lblLocationName.text = [NSString stringWithFormat:@"%@",[[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "]];
                      [shippingAddressLabel setHidden:NO];
                      [markerImage setHidden:NO];
                      //new marker
//                      GMSMarker *marker = [[GMSMarker alloc] init];
//                      marker.position = CLLocationCoordinate2DMake(place.coordinate.latitude, place.coordinate.longitude);
//                      marker.map = googleMaps;
                  } else {
                      NSLog(@"Could not locate");
                  }
              }
     ];
}
- (void)tableDataSource:(GMSAutocompleteTableDataSource *)tableDataSource
didFailAutocompleteWithError:(NSError *)error {
    [searchDisplayController setActive:NO animated:YES];
    // TODO: handle the error.
    NSLog(@"Error: %@", [error description]);
}
- (void)didUpdateAutocompletePredictionsForTableDataSource:
(GMSAutocompleteTableDataSource *)tableDataSource {
    // Turn the network activity indicator off.
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    // Reload table data.
    [searchDisplayController.searchResultsTableView reloadData];
}
- (void)didRequestAutocompletePredictionsForTableDataSource:
(GMSAutocompleteTableDataSource *)tableDataSource {
    // Turn the network activity indicator on.
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    // Reload table data.
    [searchDisplayController.searchResultsTableView reloadData];
}
#pragma mark - button Action method
- (IBAction)zoomInAction:(id)sender {
    currentZoom = currentZoom+1;
    [googleMaps animateToZoom:currentZoom];
}
- (IBAction)zoomOutAction:(id)sender {
    currentZoom = currentZoom -1;
    [googleMaps animateToZoom:currentZoom];
}
- (IBAction)selectShippingaddress:(id)sender {
    [shippingLabel setHidden:YES];
    [buttonAddShipping setHidden:YES];
    [shippingAddressLabel setHidden:NO];
    [markerImage setHidden:NO];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:googleMaps.myLocation.coordinate.latitude longitude:googleMaps.myLocation.coordinate.longitude zoom:20];
    [googleMaps animateToCameraPosition:camera];
}

//public static JSONObject getShippingJSON(Address address) throws JSONException {
//    JSONObject data = new JSONObject();
//    data.put("shipping_first_name", address.first_name);
//    data.put("shipping_last_name", address.last_name);
//    data.put("shipping_company", address.company);
//    data.put("shipping_address_1", address.address_1);
//    data.put("shipping_address_2", address.address_2);
//    data.put("shipping_city", address.city);
//    data.put("shipping_state", address.state);
//    data.put("shipping_postcode", address.postcode);
//    data.put("label", address.first_name);
//    return data;
//}
- (MapAddress*)convertPlacemartToAddress:(CLPlacemark*)placemark {
    if (placemark) {
        NSString* addressLine1 = @"";
        NSString* addressLine2 = @"";
        NSString* city = @"";
        NSString* state = @"";
        NSString* country = @"";
        NSString* postal = @"";
        NSString* countryCode = @"";
        BOOL isCodeSameAsAndroid = false;
#if CODE_SAME_AS_ANDROID
        isCodeSameAsAndroid = true;
#endif
        if (placemark.addressDictionary && isCodeSameAsAndroid) {
            if(IS_NOT_NULL(placemark.addressDictionary, @"FormattedAddressLines")){
                NSArray* formattedAddressLines = GET_VALUE_OBJ(placemark.addressDictionary, @"FormattedAddressLines");
                if (formattedAddressLines && [formattedAddressLines count] > 0) {
                    addressLine1 = [formattedAddressLines objectAtIndex:0];
                }
                if (formattedAddressLines && [formattedAddressLines count] > 1) {
                    addressLine2 = [formattedAddressLines objectAtIndex:1];
                }
            }
            if(IS_NOT_NULL(placemark.addressDictionary, @"City")){
                city = GET_VALUE_OBJ(placemark.addressDictionary, @"City");
            }
            if(IS_NOT_NULL(placemark.addressDictionary, @"State")){
                state = GET_VALUE_OBJ(placemark.addressDictionary, @"State");
            }
            if(IS_NOT_NULL(placemark.addressDictionary, @"Country")){
                country = GET_VALUE_OBJ(placemark.addressDictionary, @"Country");
            }
            if(IS_NOT_NULL(placemark.addressDictionary, @"CountryCode")){
                countryCode = GET_VALUE_OBJ(placemark.addressDictionary, @"CountryCode");
            }
            if(IS_NOT_NULL(placemark.addressDictionary, @"ZIP")){
                postal = GET_VALUE_OBJ(placemark.addressDictionary, @"ZIP");
            }
        }
        else {
            if(placemark.subThoroughfare){
                addressLine1 = [addressLine1 stringByAppendingString:placemark.subThoroughfare];
                if (placemark.thoroughfare) {
                    addressLine1 = [addressLine1 stringByAppendingString:@" , "];
                }
            }
            if(placemark.thoroughfare){
                addressLine1 = [addressLine1 stringByAppendingString:placemark.thoroughfare];
            }
            if(placemark.subLocality){
                addressLine2 = [addressLine2 stringByAppendingString:placemark.subLocality];
                if (placemark.subAdministrativeArea) {
                    addressLine2 = [addressLine2 stringByAppendingString:@" , "];
                }
            }
            if(placemark.subAdministrativeArea){
                addressLine2 = [addressLine2 stringByAppendingString:placemark.subAdministrativeArea];
            }
            
            if(placemark.locality){
                city = placemark.locality;
            }
            if(placemark.administrativeArea){
                state = placemark.administrativeArea;
            }
            if(placemark.country){
                country = placemark.country;
            }
            if(placemark.ISOcountryCode){
                countryCode = placemark.ISOcountryCode;
            }
            if(placemark.postalCode){
                postal = placemark.postalCode;
            }
        }
//        Address* address = [[Address alloc] init];
//        address._address_1 = addressLine1;
//        address._address_2 = addressLine2;
//        address._city = city;
//        address._state = state;
//        address._country = country;
//        address._countryId = countryCode;
//        address._postcode = postal;
        
        
        MapAddress* mAdd = [[MapAddress alloc] init];
        mAdd.shipping_address_1 = addressLine1;
        mAdd.shipping_address_2 = addressLine2;
        mAdd.shipping_city = city;
        mAdd.shipping_state = state;
        mAdd.shipping_country = country;
        mAdd.shipping_countryId = countryCode;
        mAdd.shipping_postcode = postal;
        return mAdd;
    }
    return nil;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)barButtonBackPressed:(id)sender {
    [[Utility sharedManager] popScreen:self];
    ViewControllerMain* mainVC = [ViewControllerMain getInstance];
    [mainVC resetPreviousState];
    [mainVC showBottomBar];
}
//- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D) coordinate {
//    [googleMaps clear];
//    CLGeocoder *ceo = [[CLGeocoder alloc]init];
//    CLLocation *loc = [[CLLocation alloc]initWithLatitude:coordinate.latitude longitude:coordinate.longitude]; //insert your coordinates
//    [ceo reverseGeocodeLocation:loc
//              completionHandler:^(NSArray *placemarks, NSError *error) {
//                  CLPlacemark *placemark = [placemarks objectAtIndex:0];
//                  if (placemark) {
//                      NSLog(@"======placemark0======");
//                      NSLog(@"addressDictionary:%@",placemark.addressDictionary);
//                      NSLog(@"name:%@",placemark.name);
//                      NSLog(@"thoroughfare:%@",placemark.thoroughfare);
//                      NSLog(@"subThoroughfare:%@",placemark.subThoroughfare);
//                      NSLog(@"locality:%@",placemark.locality);
//                      NSLog(@"subLocality:%@",placemark.subLocality);
//                      NSLog(@"administrativeArea:%@",placemark.administrativeArea);
//                      NSLog(@"subAdministrativeArea:%@",placemark.subAdministrativeArea);
//                      NSLog(@"postalCode:%@",placemark.postalCode);
//                      NSLog(@"ISOcountryCode:%@",placemark.ISOcountryCode);
//                      NSLog(@"country:%@",placemark.country);
//                      NSLog(@"inlandWater:%@",placemark.inlandWater);
//                      NSLog(@"ocean:%@",placemark.ocean);
//                      NSLog(@"areasOfInterest:%@",placemark.areasOfInterest);
//                      NSLog(@"======placemark1======");
//                      
//                      GMSMarker *marker = [[GMSMarker alloc] init];
//                      marker.position = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude);
//                      marker.draggable = YES;
//                      marker.map = googleMaps;
//                      marker.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
//                      
//                      lblLocationName.text = [NSString stringWithFormat:@"%@",[[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "]];
//                  }
//                  else {
//                      NSLog(@"Could not locate");
//                  }
//              }
//     ];
//}
- (IBAction)buttonProceedAction:(id)sender {
    NSString* fullAddress = [[NSUserDefaults standardUserDefaults] stringForKey:@"addressOfLoc"];
    MapAddress* mAdd = nil;
    if ([buttonAddShipping isHidden]) {
        //new address
        mAdd = [self convertPlacemartToAddress:self.selectedPlacemark];
        mAdd.shipping_lat = [NSString stringWithFormat:@"%f", self.selectedPosition.target.latitude];
        mAdd.shipping_lng = [NSString stringWithFormat:@"%f", self.selectedPosition.target.longitude];
    } else {
        mAdd = (MapAddress*)[self.selectedMarker.layer valueForKey:@"MAP_ADDRESS"];
    }
    [MapAddress setSelectedMapAddress:mAdd];
    
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithFloat:[mAdd.shipping_lat floatValue]] forKey:@"LAST_SAVED_LATITUTE"];
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithFloat:[mAdd.shipping_lng floatValue]] forKey:@"LAST_SAVED_LONGITUDE"];
    
    
    ViewControllerMain* mainVC = [ViewControllerMain getInstance];
    mainVC.containerTop.hidden = YES;
    mainVC.containerCenter.hidden = YES;
    mainVC.containerCenterWithTop.hidden = NO;
    mainVC.vcBottomBar.buttonHome.selected = NO;
    mainVC.vcBottomBar.buttonCart.selected = YES;
    mainVC.vcBottomBar.buttonWishlist.selected = NO;
    mainVC.vcBottomBar.buttonSearch.selected = NO;
    mainVC.revealController.panGestureEnable = false;
    [mainVC.vcBottomBar buttonClicked:nil];
    ViewControllerCartConfirmation* vcCartConfirmation = (ViewControllerCartConfirmation*)[[Utility sharedManager] pushScreenWithoutAnimation:mainVC.vcCenterTop type:PUSH_SCREEN_TYPE_CART_CONFIRM];
    RLOG(@"vcCartConfirmation = %@", vcCartConfirmation);
    
    
    MapAddress* selectedMapAddress =  [MapAddress getSelectedMapAddress];
    if (selectedMapAddress) {
        Address* address = [[Address alloc] init];
        address._first_name = selectedMapAddress.shipping_first_name;
        address._last_name = selectedMapAddress.shipping_last_name;
        address._company = selectedMapAddress.shipping_company;
        address._city = selectedMapAddress.shipping_city;
        address._address_1 = selectedMapAddress.shipping_address_1;
        address._address_2 = selectedMapAddress.shipping_address_2;
        address._state = selectedMapAddress.shipping_state;
        address._country = selectedMapAddress.shipping_country;
        address._postcode = selectedMapAddress.shipping_postcode;
        [vcCartConfirmation openShippingAddressPopup:address];
    }
}
-(BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker{
    [markerImage setHidden:YES];
    [shippingAddressLabel setHidden:YES];
    [buttonAddShipping setHidden:NO];
    [shippingLabel setHidden:NO];
    self.selectedMarker = marker;
    return false;
    
}

@end
