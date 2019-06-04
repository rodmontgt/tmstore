//
//  NearBySearchViewController.m

//
//  Created by Rajshekhar on 13/07/17.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import "NearBySearchViewController.h"
#import "Variables.h"
#import "Utility.h"
#import "AnalyticsHelper.h"
#import "StoreConfig.h"
#import <CoreLocation/CoreLocation.h>
@import GoogleMaps;
@import GooglePlaces;
#import <SDWebImage/UIImageView+WebCache.h>
#import "MenuOptions.h"
#import <GooglePlaces/GooglePlaces.h>
#import <GoogleMaps/GoogleMaps.h>
#import "ViewControllerPlatformSelection.h"
#import "CustomInfoWindow.h"
#import "WebViewController.h"

//#import "MBProgressHUD.h"
static int kTagForGlobalSpacing = 0;
static int kTagForNoSpacing = -1;

#define TEST_LOCATION_TEMP 0

@interface NearBySearchViewController () <GMSMapViewDelegate,CLLocationManagerDelegate, UISearchBarDelegate,GMSAutocompleteViewControllerDelegate,GMSAutocompleteResultsViewControllerDelegate,GMSAutocompleteTableDataSourceDelegate,UISearchDisplayDelegate>{

    CLLocationManager *locationManager;
    
    __weak IBOutlet GMSMapView *googleMaps;

    GMSAutocompleteResultsViewController *resultsViewController;
    UISearchController *searchController;
    GMSAutocompleteTableDataSource *tableDataSource;
    UISearchDisplayController *searchDisplayController;
    UISearchBar *searchBar;
    IBOutlet UIButton *buttonMenu;
    BOOL buttonTag;
    MenuOptions * menu;
    IBOutlet UILabel *labelNearStores;
}
@end


@implementation NearBySearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [Utility getUIColor:kUIColorThemeFont], NSForegroundColorAttributeName, [Utility getUIFont:kUIFontType24 isBold:false], NSFontAttributeName, nil]];
    [self.currentItemHeading setTitle:@"   "];
    
    _labelViewHeading = [[UILabel alloc] init] ;
    [_labelViewHeading setFrame:CGRectMake(0, 20, [[MyDevice sharedManager] screenSize].width, _navigationBar.frame.size.height)];
    [_labelViewHeading setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [_labelViewHeading setUIFont:kUIFontType24 isBold:false];
    [_labelViewHeading setTextColor:[Utility getUIColor:kUIColorThemeFont]];
    [_labelViewHeading setTextAlignment:NSTextAlignmentCenter];
    [_labelViewHeading setText:@"    "];
    [self.view addSubview:_labelViewHeading];
    
    [_navigationBar setClipsToBounds:false];
    [_lineView setBackgroundColor:[Utility getUIColor:kUIColorBorder]];
    [_scrollView setBackgroundColor:[Utility getUIColor:kUIColorBgTheme]];
    [self.view setBackgroundColor:[Utility getUIColor:kUIColorBgHeader]];
    [_navigationBar setBarTintColor:[Utility getUIColor:kUIColorBgHeader]];
    [_previousItemHeading setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[Utility getUIColor:kUIColorThemeFont], NSForegroundColorAttributeName, [Utility getUIFont:kUIFontType18 isBold:false], NSFontAttributeName, nil] forState:UIControlStateNormal];

    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    
    //current location on MAP
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:22.74443890 longitude:75.89219184 zoom:20];
    googleMaps.camera = camera;
    googleMaps.delegate=self;
    googleMaps.myLocationEnabled = NO;
    googleMaps.settings.myLocationButton = true;
    googleMaps.settings.zoomGestures = NO;
    googleMaps.settings.scrollGestures = NO;
    googleMaps.settings.compassButton = true;
    [googleMaps animateToCameraPosition:googleMaps.camera];

    NSLog(@"User's location: %@", googleMaps.myLocation);

    CLLocationCoordinate2D position = CLLocationCoordinate2DMake(22.74443890, 75.89219184);
    GMSMarker *marker = [GMSMarker markerWithPosition:position];
    //marker.title = @"Tap here to search nearby stores";
    marker.map = googleMaps;

    //GMSAutocompleteViewController
    GMSAutocompleteViewController *acController = [[GMSAutocompleteViewController alloc] init];
    acController.delegate = self;
    [self presentViewController:acController animated:YES completion:nil];


    resultsViewController = [[GMSAutocompleteResultsViewController alloc] init];
    resultsViewController.delegate = self;
    tableDataSource = [[GMSAutocompleteTableDataSource alloc] init];
    tableDataSource.delegate = self;
    searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:_storeSearchBar contentsController:self];
    searchDisplayController.searchResultsDataSource = tableDataSource;
    searchDisplayController.searchResultsDelegate = tableDataSource;
    searchDisplayController.delegate = self;
    _storeSearchBar.delegate = self;

    buttonTag = YES;
    menu = [[[NSBundle mainBundle] loadNibNamed:@"MenuOptions" owner:self options:nil] objectAtIndex:0];
    menu.frame = CGRectMake(buttonMenu.frame.origin.x-80, buttonMenu.frame.origin.y, 250, 175);
    [menu.tableOptions reloadData];
    [self.view addSubview:menu];
    [menu setHidden:YES];

    CustomInfoWindow *infoWindow = [[[NSBundle mainBundle] loadNibNamed:@"CustomInfoWindow" owner:self options:nil] objectAtIndex:0];
    infoWindow.frame = CGRectMake(self.view.center.x-115, self.view.center.y-50, 250, 40);
    [self.view addSubview:infoWindow];
    [Utility showShadow:infoWindow];




}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
 }

#pragma mark - CLLocationManager Delegates
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {

    
}
#pragma mark - GMSMapView Delegates
- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position{

}
- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate{
    // NSLog(@"%f",coordinate);
    
}

-(BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker{
    NSLog(@"marker Positions:%f %f",marker.position.latitude,marker.position.longitude);

    ViewControllerPlatformSelection *vps = [self.storyboard instantiateViewControllerWithIdentifier:@"VC_SPLASH_PLATFORM"];
    vps.markerInfo = marker;
    NSLog(@"markerInfo:%@",vps.markerInfo);
    
    [self presentViewController:vps animated:YES completion:nil];

    return true;
}
//- (UIView *) mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
//    CustomInfoWindow *infoWindow = [[[NSBundle mainBundle] loadNibNamed:@"CustomInfoWindow" owner:self options:nil] objectAtIndex:0];
//
//    return infoWindow;
//}
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
shouldReloadTableForSearchString:(NSString *)searchString
{
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

                  CLPlacemark*    placemark = [placemarks objectAtIndex:0];
                  // Check if any placemarks were found
                  if (error == nil && [placemarks count] > 0) {

                      GMSMarker *marker = [[GMSMarker alloc] init];
                      marker.position = CLLocationCoordinate2DMake(place.coordinate.latitude, place.coordinate.longitude);
                      GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:place.coordinate.latitude longitude:place.coordinate.longitude zoom:20];
                      [googleMaps animateToCameraPosition:camera];

                      marker.map = googleMaps;

                  }
                  else {
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

#pragma mark - UISearchDisplayControllerDelegate

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    //When the user taps the search bar, this means that the controller will begin searching.
 NSLog(@"searchDisplayControllerWillBeginSearch");
    [menu setHidden:YES];
}


#pragma mark - Button Actions
- (IBAction)buttonOptionAction:(id)sender {
//    buttonTag = YES;

    if (buttonTag) {
        [menu setHidden:NO];
        buttonTag = NO;
    }else{
        [menu setHidden:YES];
        buttonTag = YES;
    }

}
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    NSLog(@"locationManagererror = %@", error);
}

@end
