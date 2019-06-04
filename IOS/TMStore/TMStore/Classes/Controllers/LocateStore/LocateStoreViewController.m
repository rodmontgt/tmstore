//
//  LocateStoreViewController.m

//
//  Created by Rajshekhar on 13/07/17.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import "LocateStoreViewController.h"
#import "Variables.h"
#import "Utility.h"
#import "AnalyticsHelper.h"
#import "StoreConfig.h"
#import <CoreLocation/CoreLocation.h>
@import GoogleMaps;
@import GooglePlaces;
#import <SDWebImage/UIImageView+WebCache.h>
//#import "MBProgressHUD.h"
static int kTagForGlobalSpacing = 0;
static int kTagForNoSpacing = -1;

#define TEST_LOCATION_TEMP 0

@interface LocateStoreViewController () <GMSMapViewDelegate,CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UISearchBarDelegate>{
    NSMutableArray* _viewsAdded;
    UIButton *customBackButton;
    CLLocationManager *locationManager;
    
    __weak IBOutlet GMSMapView *googleMaps;
    IBOutlet UILabel *lblLocationName;
    IBOutlet UIImageView *imgView;
    __weak IBOutlet UIButton *buttonGetDirection;
    __weak IBOutlet UIView *viewDirection;
    
    CLLocation* newDestination;
    
    GMSPolyline* previousPolyline;
    NSArray* arrMarkerData;
    
    NSMutableArray *arrayStoreTitle;
    NSMutableArray *arrayStoreMarker;
    NSMutableArray *searchedArrayStoreTitle;
    NSMutableArray *searchedArrayStoreMarker;
}
@end


@implementation LocateStoreViewController

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
    
    [self initVariables];
    arrayStoreTitle = [[NSMutableArray alloc] init];
    arrayStoreMarker = [[NSMutableArray alloc] init];
    searchedArrayStoreTitle = [[NSMutableArray alloc] init];
    searchedArrayStoreMarker = [[NSMutableArray alloc] init];
    self.storeSearchBar.delegate = self;
    [self loadAllViews];
    newDestination = nil;
    previousPolyline = nil;
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    
    //    //current location on MAP
    //    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:0 longitude:0 zoom:5];
    //    googleMaps.camera = camera;
    googleMaps.delegate=self;
    googleMaps.myLocationEnabled = true;
    googleMaps.settings.compassButton = true;
    //  googleMaps.settings.myLocationButton = true;
    googleMaps.settings.zoomGestures = true;
    //    //[googleMaps setMinZoom:10 maxZoom:15];
    //    [googleMaps animateToCameraPosition:googleMaps.camera];
    //set hide view
    [viewDirection setHidden:YES];
    
    [viewDirection setBackgroundColor:[Utility getUIColor:kUIColorBgHeader]];
    [lblLocationName setUIFont:kUIFontType18 isBold:true];
    [lblLocationName setTextColor:[Utility getUIColor:kUIColorThemeFont]];
    [buttonGetDirection setBackgroundColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
    [buttonGetDirection setTitleColor:[Utility getUIColor:kUIColorBuyButtonFont] forState:UIControlStateNormal];
    [buttonGetDirection.titleLabel setUIFont:kUIFontType14 isBold:false];
    [buttonGetDirection setTitle:Localize(@"show_stores") forState:UIControlStateNormal];
    [self.labelDistance setText:@""];
    [buttonGetDirection setHidden:false];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.tableView setBackgroundColor:[UIColor yellowColor]];
    [self.parentTableview setHidden:true];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
#if ENABLE_FIREBASE_TAG_MANAGER
    [[AnalyticsHelper sharedInstance] registerVisitScreenEvent:@"Locate Store"];
#endif
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)viewWillAppear:(BOOL)animated {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super viewWillAppear:animated];
    
    //hide bottombar
    _vcMain.containerBottom.hidden = true;
    
}
- (void)resetMainScrollView {
    float globalPosY = 0.0f;
    UIView* tempView = nil;
    int i = 0;
    for (tempView in _viewsAdded) {
        CGRect rect = [tempView frame];
        if (i == 0) {
            globalPosY = 10;
        }
        rect.origin.y = globalPosY;
        
        [tempView setFrame:rect];
        globalPosY += rect.size.height;
        
        if ([tempView tag] == kTagForGlobalSpacing) {
            globalPosY += 10;//[LayoutProperties globalVerticalMargin];
        }
        i++;
    }
    [_scrollView setContentSize:CGSizeMake(_scrollView.contentSize.width, globalPosY)];
}
- (IBAction)barButtonBackPressed:(id)sender {
    [[Utility sharedManager] popScreen:self];
    if ([self.view tag] == PUSH_SCREEN_TYPE_BRAND) {
        return;
    }
    ViewControllerMain* mainVC = [ViewControllerMain getInstance];
    [mainVC resetPreviousState];
    [mainVC showBottomBar];
}

- (void)initVariables {
    _viewsAdded = [[NSMutableArray alloc] init];
    [_labelViewHeading setText:Localize(@"locate_store")];
}
- (void)loadAllViews {
    float avgLatitude = 0.0f;
    float avgLongitude = 0.0f;
    
    [arrayStoreTitle removeAllObjects];
    [arrayStoreMarker removeAllObjects];
    [searchedArrayStoreTitle removeAllObjects];
    [searchedArrayStoreMarker removeAllObjects];
    
    for (StoreConfig* sc in [StoreConfig getAllStoreConfigsForMark]) {
        NSLog(@"======StoreConfigsForMark=======\nTitle:%@\nDesc:%@\nIconUrl:%@\nLatitude:%f\nLongitude:%f\nPlatform:%@", sc.title, sc.desc, sc.icon_url, sc.latitude, sc.longitude, sc.platform);
        //multiple markers on MAP
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.title = sc.title;
        [marker setPosition:CLLocationCoordinate2DMake(sc.latitude, sc.longitude)];
        marker.appearAnimation = kGMSMarkerAnimationPop;
        marker.map = googleMaps;
        //load image
        [Utility setImage:imgView url:sc.icon_url placeholderImage:[Utility getAppIconImage]];
        
        avgLatitude += sc.latitude;
        avgLongitude += sc.longitude;
        
        [arrayStoreTitle addObject:marker.title];
        [searchedArrayStoreTitle addObject:marker.title];
        [arrayStoreMarker addObject:marker];
        [searchedArrayStoreMarker addObject:marker];
    }
    avgLatitude = avgLatitude/[[StoreConfig getAllStoreConfigsForMark] count];
    avgLongitude = avgLongitude/[[StoreConfig getAllStoreConfigsForMark] count];
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:avgLatitude longitude:avgLongitude zoom:20];
    [googleMaps animateToCameraPosition:camera];
}

#pragma mark - Adjust Orientation
- (void)beforeRotation {
    UIView* lastView = [_viewsAdded lastObject];
    for(UIView *view in _viewsAdded)
    {
        [UIView animateWithDuration:0.1f animations:^{
            [view setAlpha:0.0f];
        }completion:^(BOOL finished){
            [view removeFromSuperview];
            if (view == lastView) {
                [_scrollView setAlpha:0.0f];
                [_viewsAdded removeAllObjects];
                [self loadAllViews];
                for(UIView *vieww in _viewsAdded)
                {
                    [vieww setAlpha:0.0f];
                }
                [_scrollView setAlpha:1.0f];
            }
        }];
    }
}
- (void)afterRotation {
    for(UIView *vieww in _viewsAdded)
    {
        [UIView animateWithDuration:0.1f animations:^{
            [vieww setAlpha:1.0f];
        }completion:^(BOOL finished){
            
        }];
    }
}
- (void)adjustViewsForOrientation:(UIDeviceOrientation) orientation {
    RLOG(@"====adjustViewsForOrientation====");
    //    [self beforeRotation];
}
- (void)adjustViewsAfterOrientation:(UIDeviceOrientation) orientation {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    RLOG(@"====adjustViewsAfterOrientation====");
    //    [self afterRotation];
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self adjustViewsAfterOrientation:[[UIDevice currentDevice] orientation]];
    [self resetMainScrollView];
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self adjustViewsForOrientation:[[UIDevice currentDevice] orientation]];
    [self resetMainScrollView];
}
- (void)setDelegate:(id)delegate {
    _delegate = delegate;
}
#pragma mark - CLLocationManager Delegates
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
}
#pragma mark - GMSMapView Delegates
- (void)mapView:(GMSMapView *)mapView willMove:(BOOL)gesture{
    googleMaps.myLocationEnabled = true;
    if (gesture) {
        mapView.selectedMarker = nil;
    }
}
- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position{
    googleMaps.myLocationEnabled = true;
    
}
- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate{
    // NSLog(@"%f",coordinate);
    
}
- (BOOL)didTapMyLocationButtonForMapView:(GMSMapView *)mapView{
    googleMaps.myLocationEnabled = true;
    googleMaps.selectedMarker = nil;
    return false;
}
- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker{
    [viewDirection setHidden:NO];
    [buttonGetDirection setHidden:false];
    [lblLocationName setText:[NSString stringWithFormat:@"%@",marker.title]];
    [buttonGetDirection setTitle:Localize(@"get_direction") forState:UIControlStateNormal];
    
    CLGeocoder *ceo = [[CLGeocoder alloc]init];
    CLLocation *loc = [[CLLocation alloc]initWithLatitude:marker.position.latitude longitude:marker.position.longitude]; //insert your coordinates
    
    //set new destination
    newDestination = loc;
    
    [ceo reverseGeocodeLocation:loc
              completionHandler:^(NSArray *placemarks, NSError *error) {
                  CLPlacemark *placemark = [placemarks objectAtIndex:0];
                  if (placemark) {
                      
                      NSLog(@"placemark %@",placemark);
                      //String to hold address
                      NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
                      NSLog(@"addressDictionary %@", placemark.addressDictionary);
                      NSLog(@"placemark %@",placemark.country);
                      NSLog(@"placemark %@",placemark.locality);
                      NSLog(@"location %@",placemark.name);
                      NSLog(@"location %@",placemark.postalCode);
                      NSLog(@"location %@",placemark.location);
                      //Print the location to console
                      
                  }
                  else {
                      NSLog(@"Could not locate");
                  }
              }
     ];
    return true;
    
}
#pragma mark -Draw Route
- (void)drawRoute {
    [self drawRoute:nil destination:nil];
}
- (void)drawRoute:(CLLocation*)source destination:(CLLocation*)destination
{
    //CLLocation *myOrigin = [[CLLocation alloc] initWithLatitude:-23.104882 longitude:26.832568];
    CLLocation *myOrigin = googleMaps.myLocation;
#if TEST_LOCATION_TEMP
    myOrigin = [[CLLocation alloc] initWithLatitude:12.1348 longitude:15.0557];
#endif
    //CLLocation *myDestination = [[CLLocation alloc] initWithLatitude:-24.61427 longitude:25.917715];
    CLLocation *myDestination = destination;
    
    
    if (source) {
        myOrigin = source;
    }
    if (destination) {
        myDestination = destination;
    }
    
    if (previousPolyline) {
        previousPolyline.map = nil;
        previousPolyline = nil;
    }
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:myOrigin.coordinate.latitude longitude:myOrigin.coordinate.longitude zoom:20];
    [googleMaps animateToCameraPosition:camera];
    
    
    //clear all markers on MAP
    [googleMaps clear];
    
    GMSMarker *markerSource = [[GMSMarker alloc] init];
    markerSource.title = @"My Location";
    [markerSource setPosition:CLLocationCoordinate2DMake(myOrigin.coordinate.latitude, myOrigin.coordinate.longitude)];
    markerSource.appearAnimation = kGMSMarkerAnimationPop;
    markerSource.map = googleMaps;
    
    GMSMarker *markerDestination = [[GMSMarker alloc] init];
    markerDestination.title = @"Store Location";
    [markerDestination setPosition:CLLocationCoordinate2DMake(myDestination.coordinate.latitude, myDestination.coordinate.longitude)];
    markerDestination.appearAnimation = kGMSMarkerAnimationPop;
    markerDestination.map = googleMaps;

    [self fetchPolylineWithOrigin:myOrigin destination:myDestination completionHandler:^(GMSPolyline *polyline)
     {
         
         if(polyline) {
             polyline.map = googleMaps;
             previousPolyline = polyline;
             
         }
         else {
             UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"oops!" message:@"Can't find a way there" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
             [alert show];
         }
         
         //  [MBProgressHUD hideHUDForView:self.view animated:YES];
         
     }];
    
    
}

- (void)fetchPolylineWithOrigin:(CLLocation *)origin destination:(CLLocation *)destination completionHandler:(void (^)(GMSPolyline *))completionHandler
{
    NSString *originString = [NSString stringWithFormat:@"%f,%f", origin.coordinate.latitude, origin.coordinate.longitude];
    NSString *destinationString = [NSString stringWithFormat:@"%f,%f", destination.coordinate.latitude, destination.coordinate.longitude];
    NSString *directionsAPI = @"https://maps.googleapis.com/maps/api/directions/json?";
    NSString *directionsUrlString = [NSString stringWithFormat:@"%@&origin=%@&destination=%@&mode=driving", directionsAPI, originString, destinationString];
    NSURL *directionsUrl = [NSURL URLWithString:directionsUrlString];

    //  [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    NSURLSessionDataTask *fetchDirectionsTask = [[NSURLSession sharedSession] dataTaskWithURL:directionsUrl completionHandler:
                                                 ^(NSData *data, NSURLResponse *response, NSError *error)
                                                 {
                                                     NSDictionary* tempJson = [Utility getJsonObject:data];
                                                     [self.labelDistance setText:@""];
                                                     NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                                     if(error)
                                                     {
                                                         if(completionHandler)
                                                             completionHandler(nil);
                                                         return;
                                                     }

                                                     NSArray *routesArray = [json objectForKey:@"routes"];
                                                     GMSPolyline *polyline = nil;
                                                     if (routesArray && [routesArray count] > 0)
                                                     {
                                                         NSDictionary *routeDict = [routesArray objectAtIndex:0];
                                                         NSDictionary *routeOverviewPolyline = [routeDict objectForKey:@"overview_polyline"];
                                                         [self calculateDistance:routeDict];
                                                         NSString *points = [routeOverviewPolyline objectForKey:@"points"];
                                                         GMSPath *path = [GMSPath pathFromEncodedPath:points];
                                                         polyline = [GMSPolyline polylineWithPath:path];
                                                         polyline.strokeWidth = 5.f;
                                                     }

                                                     // run completionHandler on main thread
                                                     dispatch_sync(dispatch_get_main_queue(), ^{
                                                         if(completionHandler)
                                                             completionHandler(polyline);
                                                     });
                                                 }];
    [fetchDirectionsTask resume];
    
}
- (void)calculateDistance:(NSDictionary*)routeDict {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (IS_NOT_NULL(routeDict, @"legs")) {
            NSArray *legs = GET_VALUE_OBJ(routeDict, @"legs");
            if (legs && [legs count] > 0) {
                NSDictionary* legDict = [legs objectAtIndex:0];
                if (legDict && [legDict isKindOfClass:[NSDictionary class]]) {
                    if (IS_NOT_NULL(legDict, @"distance")) {
                        NSDictionary *distanceDict = GET_VALUE_OBJ(legDict, @"distance");
                        if (distanceDict && [distanceDict isKindOfClass:[NSDictionary class]]) {
                            if (IS_NOT_NULL(distanceDict, @"text")) {
                                NSString* distanceStr = GET_VALUE_OBJ(distanceDict, @"text");
                                distanceStr = [distanceStr uppercaseString];
                                //                            if (![lblLocationName.text isEqualToString:@""])
                                {
//                                    [lblLocationName setText:[NSString stringWithFormat:@"%@",distanceStr]];
                                    [lblLocationName setText:[NSString stringWithFormat:@"%@\n(%@)",lblLocationName.text, distanceStr]];
                                }
                            }
                        }
                    }
                }
            }
        }
    });
}
#pragma mark - Button Actions
- (IBAction)getDirectionAction:(id)sender {
    UIButton *button = (UIButton *)sender;
    if ([button.currentTitle isEqualToString:Localize(@"get_direction")]) {
        [buttonGetDirection setTitle:Localize(@"show_stores") forState:UIControlStateNormal];
        [self.labelDistance setText:@""];
        //draw route between two locations
        CLLocation* source = nil;
        CLLocation* destination = newDestination;
        [self drawRoute:source destination:destination];
    }else if ([button.currentTitle isEqualToString:Localize(@"show_stores")]){
        //show all markers on MAP
        [googleMaps clear];
        [self loadAllViews];
        [lblLocationName setText:@""];
    }
    
}
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    NSLog(@"error = %@", error);
}

#pragma mark - Search Actions
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.parentTableview setHidden:true];
}
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [buttonGetDirection setTitle:Localize(@"show_stores") forState:UIControlStateNormal];
    [self.labelDistance setText:@""];
    [googleMaps clear];
    [self loadAllViews];
    [lblLocationName setText:@""];
    [self.searchDisplayController setActive:true];
    [self.parentTableview setHidden:false];
    return true;
}
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    [searchedArrayStoreTitle removeAllObjects];
    
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", searchText];
    searchedArrayStoreTitle = [NSMutableArray arrayWithArray: [arrayStoreTitle filteredArrayUsingPredicate:resultPredicate]];
    int i = 0;
    NSMutableIndexSet *mutableIndexSet = [[NSMutableIndexSet alloc] init];
    for (NSString* str in arrayStoreTitle) {
        if ([searchedArrayStoreTitle containsObject:str]) {
            [mutableIndexSet addIndex:i];
        }
        i++;
    }
    searchedArrayStoreMarker = [arrayStoreMarker objectsAtIndexes:mutableIndexSet];
}
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    return YES;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        return [searchedArrayStoreTitle count];
    } else {
        return [arrayStoreTitle count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    } else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    }
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cell.textLabel.text = [searchedArrayStoreTitle objectAtIndex:indexPath.row];
    } else {
        cell.textLabel.text = arrayStoreTitle[indexPath.row];
    }
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GMSMarker* marker = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        marker = [searchedArrayStoreMarker objectAtIndex:indexPath.row];
    } else {
        marker = [arrayStoreMarker objectAtIndex:indexPath.row];
    }
    [self mapView:googleMaps didTapMarker:marker];
    [self.storeSearchBar resignFirstResponder];
    [self.parentTableview setHidden:true];
    [self.searchDisplayController setActive:false];
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:marker.position.latitude longitude:marker.position.longitude zoom:20];
    [googleMaps animateToCameraPosition:camera];
}
@end
