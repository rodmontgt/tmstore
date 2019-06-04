//
//  ViewControllerOrder.m
//  eMobileApp
//
//  Created by Rishabh Jain on 25/11/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import "ViewControllerOrder.h"
#import "AppUser.h"
#import "Attribute.h"
#import "Order.h"
#import "DataManager.h"
#import "CommonInfo.h"
#import "Cart.h"
#import "AnalyticsHelper.h"
#import "ViewControllerWebview.h"

static int kTagForGlobalSpacing = 0;
static int kTagForNoSpacing = -1;

static int initLoadOrdersCount = 5;
static int moreLoadOrdersCount = 5;

@interface ViewControllerOrder () {
    NSMutableArray* _viewsAdded;
    UIButton *customBackButton;
}
@end


@implementation ViewControllerOrder

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
    [self loadGuestOrders];
    //    [[[DataManager sharedManager] tmMulticastDelegate] addDelegate:self];
}
-(void)viewDidAppear:(BOOL)animated{
#if ENABLE_FIREBASE_TAG_MANAGER
    [[AnalyticsHelper sharedInstance] registerVisitScreenEvent:@"Order Screen"];
#endif
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)fetchOrders {
    [[[DataManager sharedManager] tmDataDoctor] fetchOrdersInBackground:^(id data) {
        _loadedOrdersCount = 0;
        [self loadAllViews];
        [self loadOrderRewardPoints];
    } failure:^(NSString * error) {
        if ([error isEqualToString:@"retry"]) {
            [self fetchOrders];
        }
    }];
}
- (void)viewWillAppear:(BOOL)animated {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    [super viewWillAppear:animated];
    [self fetchOrders];
    [self loadAllViews];
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
            globalPosY += [LayoutProperties globalVerticalMargin];
        }
        i++;
    }
    [_scrollView setContentSize:CGSizeMake(_scrollView.contentSize.width, globalPosY)];
}

- (void)loadGuestOrders {
    if([[AppUser sharedManager] _isUserLoggedIn] == false && [[GuestConfig sharedInstance] guest_checkout]) {
        [[DataManager getDataDoctor] getGuestOrdersInBackground:^(id data) {
            RLOG(@"loadGuestOrders success= %@", data);
            _loadedOrdersCount = 0;
            [self loadAllViews];
            [self resetMainScrollView];
        } failure:^{
            RLOG(@"loadGuestOrders failure");
        }];
    }
}
- (IBAction)barButtonBackPressed:(id)sender {
    //    [[Utility sharedManager] popScreen:self];
    //    ViewControllerMain* mainVC = [ViewControllerMain getInstance];
    //    [mainVC btnClickedHome:nil];
    //        [mainVC resetPreviousState];
    [[Utility sharedManager] popScreen:self];
    ViewControllerMain* mainVC = [ViewControllerMain getInstance];
    [mainVC resetPreviousState];
}
- (void)initVariables {
    _viewsAdded = [[NSMutableArray alloc] init];
    //    [_scrollView setBackgroundColor:[Utility getUIColor:kUIColorBgTheme]];
    //    [self.view setBackgroundColor:[Utility getUIColor:kUIColorBgHeader]];
    //    [_lineView setBackgroundColor:[Utility getUIColor:kUIColorBorder]];
}
- (void)loadAllViews {
    for (UIView* view in _viewsAdded) {
        [view removeFromSuperview];
    }
    [_viewsAdded removeAllObjects];
    [_labelViewHeading setText:Localize(@"title_myorders")];
    
    AppUser* appUser = [AppUser sharedManager];
    
    //    RLOG(@"===========ORDERS============\n%@", appUser._ordersArray);
    //    int orderCount_completed = 0;
    //    int orderCount_cancelled = 0;
    //    int orderCount_refunded = 0;
    //    int orderCount_failed = 0;
    //    int orderCount_processing = 0;
    //    int orderCount_pending = 0;
    //    int orderCount_onhold = 0;
    //
    //    for (Order* order in appUser._ordersArray) {
    //        if([order._status isEqualToString:@"completed"]) {
    //            orderCount_completed++;
    //        }
    //        else if([order._status isEqualToString:@"cancelled"]) {
    //            orderCount_cancelled++;
    //        }
    //        else if([order._status isEqualToString:@"refunded"]) {
    //            orderCount_refunded++;
    //        }
    //        else if([order._status isEqualToString:@"failed"]) {
    //            orderCount_failed++;
    //        }
    //        else if([order._status isEqualToString:@"processing"]) {
    //            orderCount_processing++;
    //        }
    //        else if([order._status isEqualToString:@"pending"]) {
    //            orderCount_pending++;
    //        }
    //        else if([order._status isEqualToString:@"on-hold"]) {
    //            orderCount_onhold++;
    //        }
    //    }
    //    [_scrollView setDelegate:self];
    //    int i = 0;
    //    for (Order* order in appUser._ordersArray) {
    //        [self createOrderSummery:i order:order viewMain:nil];
    //        _loadedOrdersCount = i;
    //        if (i == initLoadOrdersCount-1) {
    //            break;
    //        }
    //        i++;
    //    }
    
    [self loadMoreOrders:initLoadOrdersCount];
    [self resetMainScrollView];
}
- (UIView*)addBorder:(UIView*)view{
    UIView* viewBorder = [[UIView alloc] init];
    [viewBorder setFrame:CGRectMake(0, 0, view.frame.size.width, 1)];
    [viewBorder setBackgroundColor:[Utility getUIColor:kUIColorBorder]];
    return viewBorder;
}
#if LIST_WITH_FOUR_STATUS
#pragma mark- FOUR STATUS
- (UIView*)createOrderSummery:(int)listId order:(Order*)order viewMain:(UIView*)viewMain {
    RLOG(@"===========createOrderSummery============%d", order._id);
    ///header
    BOOL isCurrencySymbolAtLast = true;
    
    float globalPosY = 0;
    float globalPosX = 0;
    float globalWidth = self.view.frame.size.width * 0.96f;
    
    if (viewMain == nil) {
        viewMain = [[UIView alloc] init];
        [viewMain setTag:kTagForGlobalSpacing];
        [_scrollView addSubview:viewMain];
        [_viewsAdded addObject:viewMain];
        viewMain.hidden = true;
    }else{
        for (UIView* view in [viewMain subviews]) {
            [view removeFromSuperview];
        }
    }
    
    [viewMain setFrame:CGRectMake(self.view.frame.size.width * 0.02f, 0, self.view.frame.size.width * 0.96f, globalPosY)];
    [viewMain setBackgroundColor:[UIColor whiteColor]];
    
    
    UIView* viewTop = [[UIView alloc] init];
    [viewTop setFrame:CGRectMake(globalPosX, globalPosY, globalWidth, 50)];
    [viewTop setBackgroundColor:[UIColor whiteColor]];
    [viewMain addSubview:viewTop];
    globalPosY += 50;
    //    [viewTop.layer setBorderColor:[[Utility getUIColor:kUIColorBorder] CGColor]];
    //    [viewTop.layer setBorderWidth:1];
    //    [viewTop setTag:kTagForNoSpacing];
    //    [_scrollView addSubview:viewTop];
    //    [_viewsAdded addObject:viewTop];
    
    //    "pending": "Pending Payment",
    //    "processing": "Processing",
    //    "on-hold": "On Hold",
    //    "completed": "Completed",
    //    "cancelled": "Cancelled",
    //    "refunded": "Refunded",
    //    "failed": "Failed"
    
    
    
    
    
    
    
    UILabel* labelOrderId = [[UILabel alloc] init];
    [labelOrderId setFrame:CGRectMake(self.view.frame.size.width * 0.02f, 0, viewTop.frame.size.width, 50)];
    [labelOrderId setUIFont:kUIFontType16 isBold:true];
    [labelOrderId setTextColor:[Utility getUIColor:kUIColorFontDark]];
    
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        [labelOrderId setText:[NSString stringWithFormat:@"%@ :%@", order._order_number_str, Localize(@"i_orderid")]];
        [labelOrderId setTextAlignment:NSTextAlignmentRight];
    } else {
        [labelOrderId setText:[NSString stringWithFormat:@"%@: %@", Localize(@"i_orderid"),order._order_number_str]];
        [labelOrderId setTextAlignment:NSTextAlignmentLeft];
    }
    
    [viewTop addSubview:labelOrderId];
    
    UILabel* labelOrderDate = [[UILabel alloc] init];
    [labelOrderDate setFrame:CGRectMake(0, 0, viewTop.frame.size.width*.98f, 50)];
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        [labelOrderDate setTextAlignment:NSTextAlignmentLeft];
    } else {
        [labelOrderDate setTextAlignment:NSTextAlignmentRight];
    }
    [labelOrderDate setUIFont:kUIFontType16 isBold:false];
    [labelOrderDate setTextColor:[Utility getUIColor:kUIColorFontDark]];
    NSDate* date = order._created_at;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    NSString* userLocale = [[NSUserDefaults standardUserDefaults] valueForKey:USER_LOCALE];
    NSString* defaultLocale = [[NSUserDefaults standardUserDefaults] valueForKey:DEFAULT_LOCALE];
    NSString* selectedLocale = @"";
    if (userLocale && ![userLocale isEqualToString:@""]) {
        selectedLocale = userLocale;
    } else if (defaultLocale && ![defaultLocale isEqualToString:@""]) {
        selectedLocale = defaultLocale;
    } else {
        selectedLocale = @"en_US";
    }
    [dateFormat setLocale:[NSLocale localeWithLocaleIdentifier:selectedLocale]];
    [dateFormat setDateFormat:[[Addons sharedManager]date_format]];
    NSString* temp = [dateFormat stringFromDate:date];
    [labelOrderDate setText:[NSString stringWithFormat:@"%@", temp]];
    [viewTop addSubview:labelOrderDate];
    
    ///items
    int lineItemsCount = (int)[[order _line_items] count];
    if (lineItemsCount > 0) {
        for (LineItem* lineItem in order._line_items) {
            if (order._id == 828)
            {
                RLOG(@"order._id = %d", order._id);
            }
            UIView* lineItemView = [self addView:lineItem currencyCode:order._currency isCurrencySymbolAtLast:isCurrencySymbolAtLast];
            [viewMain addSubview:lineItemView];
            [lineItemView addSubview:[self addBorder:lineItemView]];
            CGRect rect = lineItemView.frame;
            rect.origin.y = globalPosY;
            rect.origin.x = 0;
            lineItemView.frame = rect;
            globalPosY += lineItemView.frame.size.height;
        }
    }
    
    
    //other views
    UIView* viewOther = [[UIView alloc] init];
    [viewOther setFrame:CGRectMake(0, 0, self.view.frame.size.width * 0.96f, 0)];
    [viewOther setBackgroundColor:[UIColor whiteColor]];
    //    [viewOther.layer setBorderColor:[[Utility getUIColor:kUIColorBorder] CGColor]];
    //    [viewOther.layer setBorderWidth:1];
    [viewOther setTag:kTagForNoSpacing];
    [viewOther addSubview:[self addBorder:viewOther]];
    //    [_scrollView addSubview:viewOther];
    //    [_viewsAdded addObject:viewOther];
    
    float netWidth = viewOther.frame.size.width * 0.96f;
    float startPointX = viewOther.frame.size.width * 0.02f;
    float startPointY = viewOther.frame.size.width * 0.02f;
    float netHeight = 25;
    
    //for tax
    if (order._total_tax != 0.0f)
    {
        UILabel* labelH = [[UILabel alloc] init];
        [labelH setFrame:CGRectMake(startPointX, startPointY, netWidth, netHeight)];
        [labelH setUIFont:kUIFontType16 isBold:false];
        [labelH setTextColor:[Utility getUIColor:kUIColorFontLight]];
        [labelH setText:[NSString stringWithFormat:Localize(@"total_tax")]];
        [viewOther addSubview:labelH];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [labelH setTextAlignment:NSTextAlignmentRight];
        } else {
            [labelH setTextAlignment:NSTextAlignmentLeft];
        }
        
        UILabel* label = [[UILabel alloc] init];
        [label setFrame:CGRectMake(startPointX, startPointY, netWidth, netHeight)];
        [label setUIFont:kUIFontType16 isBold:false];
        [label setTextColor:[Utility getUIColor:kUIColorFontLight]];
        [label setText:[NSString stringWithFormat:@"%@",[[Utility sharedManager] getCurrencyWithSign:order._total_tax currencyCode:order._currency symbolAtLast:isCurrencySymbolAtLast]]];
        [viewOther addSubview:label];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [label setTextAlignment:NSTextAlignmentLeft];
        } else {
            [label setTextAlignment:NSTextAlignmentRight];
        }
        startPointY += netHeight;
    }
    
    //for shipping tax
    if (order._total_shipping != 0.0f)
    {
        UILabel* labelH = [[UILabel alloc] init];
        [labelH setFrame:CGRectMake(startPointX, startPointY, netWidth, netHeight)];
        [labelH setUIFont:kUIFontType16 isBold:false];
        [labelH setTextColor:[Utility getUIColor:kUIColorFontLight]];
        [labelH setText:[NSString stringWithFormat:Localize(@"i_total_shipping_cost")]];
        [viewOther addSubview:labelH];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [labelH setTextAlignment:NSTextAlignmentRight];
        } else {
            [labelH setTextAlignment:NSTextAlignmentLeft];
        }
        
        UILabel* label = [[UILabel alloc] init];
        [label setFrame:CGRectMake(startPointX, startPointY, netWidth, netHeight)];
        [label setUIFont:kUIFontType16 isBold:false];
        [label setTextColor:[Utility getUIColor:kUIColorFontLight]];
        [label setText:[NSString stringWithFormat:@"%@",[[Utility sharedManager] getCurrencyWithSign:order._total_shipping currencyCode:order._currency symbolAtLast:isCurrencySymbolAtLast]]];
        
        [viewOther addSubview:label];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [label setTextAlignment:NSTextAlignmentLeft];
        } else {
            [label setTextAlignment:NSTextAlignmentRight];
        }
        startPointY += netHeight;
    }
    
    
    //for extra charges
    if (order._fee_lines && [order._fee_lines count] > 0)
    {
        float totalExtraCharges = 0.0f;
        for (FeeLine* feeline in order._fee_lines) {
            totalExtraCharges += feeline.total;
        }
        
        UILabel* labelH = [[UILabel alloc] init];
        [labelH setFrame:CGRectMake(startPointX, startPointY, netWidth, netHeight)];
        [labelH setUIFont:kUIFontType16 isBold:false];
        [labelH setTextColor:[Utility getUIColor:kUIColorFontLight]];
        [labelH setText:[NSString stringWithFormat:Localize(@"Total Extra Charges")]];
        [viewOther addSubview:labelH];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [labelH setTextAlignment:NSTextAlignmentRight];
        } else {
            [labelH setTextAlignment:NSTextAlignmentLeft];
        }
        
        UILabel* label = [[UILabel alloc] init];
        [label setFrame:CGRectMake(startPointX, startPointY, netWidth, netHeight)];
        [label setUIFont:kUIFontType16 isBold:false];
        [label setTextColor:[Utility getUIColor:kUIColorFontLight]];
        [label setText:[NSString stringWithFormat:@"%@",[[Utility sharedManager] getCurrencyWithSign:totalExtraCharges currencyCode:order._currency symbolAtLast:isCurrencySymbolAtLast]]];
        
        [viewOther addSubview:label];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [label setTextAlignment:NSTextAlignmentLeft];
        } else {
            [label setTextAlignment:NSTextAlignmentRight];
        }
        startPointY += netHeight;
    }
    
    
    //for discount
    if (order._total_discount != 0.0f)
    {
        UILabel* labelH = [[UILabel alloc] init];
        [labelH setFrame:CGRectMake(startPointX, startPointY, netWidth, netHeight)];
        [labelH setUIFont:kUIFontType16 isBold:false];
        [labelH setTextColor:[Utility getUIColor:kUIColorFontLight]];
        [labelH setText:[NSString stringWithFormat:Localize(@"total_savings")]];
        [viewOther addSubview:labelH];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [labelH setTextAlignment:NSTextAlignmentRight];
        } else {
            [labelH setTextAlignment:NSTextAlignmentLeft];
        }
        UILabel* label = [[UILabel alloc] init];
        [label setFrame:CGRectMake(startPointX, startPointY, netWidth, netHeight)];
        [label setUIFont:kUIFontType16 isBold:false];
        [label setTextColor:[Utility getUIColor:kUIColorFontLight]];
        [label setText:[NSString stringWithFormat:@"- %@",[[Utility sharedManager] getCurrencyWithSign:order._total_discount currencyCode:order._currency symbolAtLast:isCurrencySymbolAtLast]]];
        [viewOther addSubview:label];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [label setTextAlignment:NSTextAlignmentLeft];
        } else {
            [label setTextAlignment:NSTextAlignmentRight];
        }
        startPointY += netHeight;
    }
    //for reward points
    if([[Addons sharedManager] enable_custom_points]) {
        UILabel* labelPointsEarned = [[UILabel alloc] init];
        [labelPointsEarned setFrame:CGRectMake(startPointX, startPointY, netWidth, netHeight)];
        [labelPointsEarned setUIFont:kUIFontType16 isBold:false];
        [labelPointsEarned setTextColor:[Utility getUIColor:kUIColorFontLight]];
        [labelPointsEarned setText:[NSString stringWithFormat:@"%@: %d",Localize(@"i_points_earned"), order.pointsEarned]];
        [viewOther addSubview:labelPointsEarned];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [labelPointsEarned setTextAlignment:NSTextAlignmentRight];
        } else {
            [labelPointsEarned setTextAlignment:NSTextAlignmentLeft];
        }
        UILabel* labelPointsRedeemed = [[UILabel alloc] init];
        [labelPointsRedeemed setFrame:CGRectMake(startPointX, startPointY, netWidth, netHeight)];
        [labelPointsRedeemed setUIFont:kUIFontType16 isBold:false];
        [labelPointsRedeemed setTextColor:[Utility getUIColor:kUIColorFontLight]];
        [labelPointsRedeemed setText:[NSString stringWithFormat:@"%@: %d",Localize(@"i_points_redeemed"), order.pointsRedeemed]];
        [viewOther addSubview:labelPointsRedeemed];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [labelPointsRedeemed setTextAlignment:NSTextAlignmentLeft];
        } else {
            [labelPointsRedeemed setTextAlignment:NSTextAlignmentRight];
        }
        startPointY += netHeight;
    }
    startPointY += viewOther.frame.size.width * 0.02f;
    
    
#if SHOW_DATE_TIME_SLOT
    {
        Addons* addons = [Addons sharedManager];
        BOOL showDateSlot = (addons.deliverySlotsCopiaPlugin && addons.deliverySlotsCopiaPlugin.isEnabled) ? true : false ;
        BOOL showTimeSlot = showDateSlot ? true : (addons.localPickupTimeSelectPlugin && addons.localPickupTimeSelectPlugin.isEnabled) ? true : false ;
        if (showDateSlot) {
            UILabel* label = [[UILabel alloc] init];
            [label setFrame:CGRectMake(startPointX, startPointY, netWidth, netHeight)];
            [label setUIFont:kUIFontType16 isBold:false];
            [label setTextColor:[Utility getUIColor:kUIColorFontLight]];
            [viewOther addSubview:label];
            if ([[TMLanguage sharedManager] isRTLEnabled]) {
                [label setTextAlignment:NSTextAlignmentRight];
            } else {
                [label setTextAlignment:NSTextAlignmentLeft];
            }
            [label setText:[NSString stringWithFormat:@"%@ : %@", Localize(@"delivery_date"), order.deliveryDateString]];
            [label sizeToFitUI];
            
            UIActivityIndicatorView* spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [viewOther addSubview:spinnerView];
            [spinnerView setFrame:CGRectMake(
                                             CGRectGetMaxX(label.frame),
                                             0,
                                             spinnerView.frame.size.width,
                                             spinnerView.frame.size.height)];
            spinnerView.center = CGPointMake(spinnerView.center.x, label.center.y);
            
            if (order.deliveryDateString && ![order.deliveryDateString isEqualToString:@""]) {
                [spinnerView stopAnimating];
            } else {
                [spinnerView startAnimating];
            }
            startPointY += netHeight;
        }
        if (showTimeSlot) {
            UILabel* label = [[UILabel alloc] init];
            [label setFrame:CGRectMake(startPointX, startPointY, netWidth, netHeight)];
            [label setUIFont:kUIFontType16 isBold:false];
            [label setTextColor:[Utility getUIColor:kUIColorFontLight]];
            [viewOther addSubview:label];
            if ([[TMLanguage sharedManager] isRTLEnabled]) {
                [label setTextAlignment:NSTextAlignmentRight];
            } else {
                [label setTextAlignment:NSTextAlignmentLeft];
            }
            [label setText:[NSString stringWithFormat:@"%@ : %@", Localize(@"delivery_time"), order.deliveryTimeString]];
            [label sizeToFitUI];
            UIActivityIndicatorView* spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [viewOther addSubview:spinnerView];
            [spinnerView setFrame:CGRectMake(
                                             CGRectGetMaxX(label.frame),
                                             0,
                                             spinnerView.frame.size.width,
                                             spinnerView.frame.size.height)];
            spinnerView.center = CGPointMake(spinnerView.center.x, label.center.y);
            if (order.deliveryTimeString && ![order.deliveryTimeString isEqualToString:@""]) {
                [spinnerView stopAnimating];
            } else {
                [spinnerView startAnimating];
            }
            startPointY += netHeight;
        }
    }
#endif
    
    if (0) {
        UIView* viewHorizontalBar = [[UIView alloc] init];
        [viewHorizontalBar setFrame:CGRectMake(0, startPointY, viewOther.frame.size.width, 2)];
        [viewHorizontalBar setBackgroundColor:[Utility getUIColor:kUIColorBorder]];
        [viewOther addSubview:viewHorizontalBar];
        startPointY += 2;
        startPointY += viewOther.frame.size.width * 0.02f;
    }
    //for total
    startPointY += viewOther.frame.size.width * 0.02f;
    {
        UILabel* labelH = [[UILabel alloc] init];
        [labelH setFrame:CGRectMake(startPointX, startPointY, netWidth, netHeight)];
        [labelH setUIFont:kUIFontType16 isBold:true];
        [labelH setTextColor:[Utility getUIColor:kUIColorFontDark]];
        [labelH setText:[NSString stringWithFormat:Localize(@"i_grand_total")]];
        [viewOther addSubview:labelH];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [labelH setTextAlignment:NSTextAlignmentRight];
        } else {
            [labelH setTextAlignment:NSTextAlignmentLeft];
        }
        UILabel* label = [[UILabel alloc] init];
        [label setFrame:CGRectMake(startPointX, startPointY, netWidth, netHeight)];
        [label setUIFont:kUIFontType16 isBold:true];
        [label setTextColor:[Utility getUIColor:kUIColorFontDark]];
        [label setText:[NSString stringWithFormat:@"%@",[[Utility sharedManager] getCurrencyWithSign:[order._total floatValue] currencyCode:order._currency symbolAtLast:isCurrencySymbolAtLast]]];
        [viewOther addSubview:label];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [label setTextAlignment:NSTextAlignmentLeft];
        } else {
            [label setTextAlignment:NSTextAlignmentRight];
        }
        startPointY += netHeight;
    }
    startPointY += viewOther.frame.size.width * 0.02f;
    if (0) {
        UIView* viewHorizontalBar1 = [[UIView alloc] init];
        [viewHorizontalBar1 setFrame:CGRectMake(0, startPointY, viewOther.frame.size.width, 2)];
        [viewHorizontalBar1 setBackgroundColor:[Utility getUIColor:kUIColorBorder]];
        [viewOther addSubview:viewHorizontalBar1];
        startPointY += 2;
        startPointY += viewOther.frame.size.width * 0.02f;
    }
    //for line items count
    if (0)
    {
        UILabel* labelH = [[UILabel alloc] init];
        [labelH setFrame:CGRectMake(startPointX, startPointY, netWidth, netHeight)];
        [labelH setUIFont:kUIFontType16 isBold:false];
        [labelH setTextColor:[Utility getUIColor:kUIColorFontDark]];
        [labelH setText:[NSString stringWithFormat:Localize(@"i_total_items")]];
        [viewOther addSubview:labelH];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [labelH setTextAlignment:NSTextAlignmentRight];
        } else {
            [labelH setTextAlignment:NSTextAlignmentLeft];
        }
        UILabel* label = [[UILabel alloc] init];
        [label setFrame:CGRectMake(startPointX, startPointY, netWidth, netHeight)];
        [label setUIFont:kUIFontType16 isBold:false];
        [label setTextColor:[Utility getUIColor:kUIColorFontDark]];
        [label setText:[NSString stringWithFormat:@"%d",order._total_line_items_quantity]];
        [viewOther addSubview:label];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [label setTextAlignment:NSTextAlignmentLeft];
        } else {
            [label setTextAlignment:NSTextAlignmentRight];
        }
        startPointY += netHeight;
        startPointY += viewOther.frame.size.width * 0.02f;
    }
    [viewOther setFrame:CGRectMake(0, globalPosY, self.view.frame.size.width * 0.96f, startPointY)];
    [viewMain addSubview:viewOther];
    globalPosY += viewOther.frame.size.height;
    
    if ([order._status isEqualToString:@"pending"] ||
        [order._status isEqualToString:@"processing"] ||
        [order._status isEqualToString:@"on-hold"] ||
        [order._status isEqualToString:@"completed"]) {
        
        UIView* viewProgress = [[UIView alloc] init];
        [viewProgress setFrame:CGRectMake(globalPosX, globalPosY, globalWidth, 75)];
        [viewProgress setBackgroundColor:[UIColor whiteColor]];
        
        [viewProgress addSubview:[self addBorder:viewProgress]];
        //        [viewProgress.layer setBorderColor:[[Utility getUIColor:kUIColorBorder] CGColor]];
        //        [viewProgress.layer setBorderWidth:1];
        [viewMain addSubview:viewProgress];
        globalPosY += 75;
        int j = -1;
        if ([order._status isEqualToString:@"pending"]) {
            j = 0;
        }
        if ([order._status isEqualToString:@"processing"]) {
            j = 1;
        }
        if ([order._status isEqualToString:@"on-hold"]) {
            j = 0;
        }
        if ([order._status isEqualToString:@"completed"]) {
            j = 3;
        }
        for (int i = 0; i < 3; i++) {
            UIView* imgView = [[UIView alloc] init];
            [imgView setFrame:CGRectMake(0, 0, viewProgress.frame.size.width * 0.25f, viewProgress.frame.size.height * 0.25f * 0.25f)];
            imgView.center = CGPointMake(viewProgress.frame.size.width * 0.25f + i * viewProgress.frame.size.width * 0.25f, viewProgress.frame.size.height*.33f);
            [viewProgress addSubview:imgView];
            
            if (i < j) {
                imgView.backgroundColor = [Utility getUIColor:kUIColorBlue];//[Utility getUIColor:kUIColorThemeButtonSelected];
            } else {
                imgView.backgroundColor = [Utility getUIColor:kUIColorBorder];//[Utility getUIColor:kUIColorThemeButtonNormal];
            }
        }
        for (int i = 0; i < 4; i++) {
            UIImageView* imgView = [[UIImageView alloc] init];
            [imgView setFrame:CGRectMake(0, 0, viewProgress.frame.size.height * 0.25f, viewProgress.frame.size.height * 0.25f)];
            imgView.contentMode = UIViewContentModeScaleAspectFit;
            imgView.center = CGPointMake(viewProgress.frame.size.width * 0.125f + i * viewProgress.frame.size.width * 0.25f, viewProgress.frame.size.height*.33f);
            [viewProgress addSubview:imgView];
            
            
            UILabel* label = [[UILabel alloc] init];
            [label setFrame:CGRectMake(self.view.frame.size.width * 0.02f, 0, viewTop.frame.size.width, viewProgress.frame.size.height)];
            [label setUIFont:kUIFontType14 isBold:false];
            [label setTextColor:[Utility getUIColor:kUIColorFontLight]];
            switch (i) {
                case 0:
                    [label setText:[NSString stringWithFormat:Localize(@"approval")]];
                    if ([order._status isEqualToString:@"on-hold"]) {
                        [label setText:[NSString stringWithFormat:Localize(@"onhold")]];
                    }
                    break;
                case 1:
                    [label setText:[NSString stringWithFormat:Localize(@"processing")]];
                    break;
                case 2:
                    [label setText:[NSString stringWithFormat:Localize(@"shipping")]];
                    break;
                case 3:
                    [label setText:[NSString stringWithFormat:Localize(@"delivered")]];
                    break;
                    
                default:
                    break;
            }
            [label sizeToFitUI];
            label.center = CGPointMake(viewProgress.frame.size.width * 0.125f + i * viewProgress.frame.size.width * 0.25f, viewProgress.frame.size.height*.66f);
            [viewProgress addSubview:label];
            
            if (i <= j) {
                [imgView setUIImage:[[UIImage imageNamed:@"checked_circle"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
                imgView.tintColor = [Utility getUIColor:kUIColorBlue];//[Utility getUIColor:kUIColorThemeButtonSelected];
            } else {
                [imgView setUIImage:[[UIImage imageNamed:@"checked_circle"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
                imgView.tintColor = [Utility getUIColor:kUIColorBorder];//[Utility getUIColor:kUIColorThemeButtonNormal];
            }
        }
    }
    
    
    
    
    
#if SHOW_ACCOUNT_DETAILS_ORDER_SCREEN
    /////account details///////////
    BOOL showAccountDetails = false;
    TMPaymentSDK* tmPaymentSDK = [[DataManager sharedManager] tmPaymentSDK];
    TMPaymentGateway* paymentGatewaySelected = nil;
    if(tmPaymentSDK.paymentGateways) {
        for (TMPaymentGateway* paymentGateway in tmPaymentSDK.paymentGateways) {
            if ([paymentGateway.paymentId isEqualToString:order._payment_details._method_id]) {
                showAccountDetails = true;
                paymentGatewaySelected = paymentGateway;
                break;
            }
        }
    }
    if (showAccountDetails) {
        NSString* mthdTitle = order._payment_details._method_title;
        UIView* viewPaymentDetails = [[UIView alloc] init];
        [viewPaymentDetails setFrame:CGRectMake(globalPosX, globalPosY, globalWidth, 75)];
        [viewPaymentDetails setBackgroundColor:[UIColor whiteColor]];
        [viewPaymentDetails addSubview:[self addBorder:viewPaymentDetails]];
        [viewMain addSubview:viewPaymentDetails];
        float startX = viewPaymentDetails.frame.size.width * 0.02f;
        float diffY = viewPaymentDetails.frame.size.width * 0.02f;
        float startY = viewPaymentDetails.frame.size.width * 0.02f;
        
        if (![mthdTitle isEqualToString:@""]) {
            UILabel* labelH = [[UILabel alloc] init];
            [labelH setFrame:CGRectMake(startX, startY, netWidth, diffY)];
            [labelH setUIFont:kUIFontType14 isBold:true];
            [labelH setTextColor:[Utility getUIColor:kUIColorFontDark]];
            [labelH setText:[NSString stringWithFormat:@"%@: %@", Localize(@"payment_method"), order._payment_details._method_title]];
            labelH.lineBreakMode = NSLineBreakByWordWrapping;
            labelH.numberOfLines = 0;
            [labelH sizeToFitUI];
            [viewPaymentDetails addSubview:labelH];
            if ([[TMLanguage sharedManager] isRTLEnabled]) {
                [labelH setTextAlignment:NSTextAlignmentRight];
            } else {
                [labelH setTextAlignment:NSTextAlignmentLeft];
            }
            startY += (labelH.frame.size.height + diffY);
        }
        NSString* accountDetails = [paymentGatewaySelected getAccountDetailsString];
        NSString* accountInstruction = paymentGatewaySelected.paymentInstruction;
        if (![order._status isEqualToString:@"on-hold"]) {
            accountDetails = @"";
            accountInstruction = @"";
        }
        if (![accountInstruction isEqualToString:@""]) {
            UILabel* labelInstruction = [[UILabel alloc] init];
            [labelInstruction setFrame:CGRectMake(startX, startY, netWidth, diffY)];
            [labelInstruction setUIFont:kUIFontType14 isBold:false];
            [labelInstruction setTextColor:[Utility getUIColor:kUIColorFontLight]];
            [labelInstruction setText:accountInstruction];
            [viewPaymentDetails addSubview:labelInstruction];
            if ([[TMLanguage sharedManager] isRTLEnabled]) {
                [labelInstruction setTextAlignment:NSTextAlignmentRight];
            } else {
                [labelInstruction setTextAlignment:NSTextAlignmentLeft];
            }
            labelInstruction.lineBreakMode = NSLineBreakByWordWrapping;
            labelInstruction.numberOfLines = 0;
            [labelInstruction sizeToFitUI];
            startY += (labelInstruction.frame.size.height + diffY);
        }
        if (![accountDetails isEqualToString:@""]) {
            UILabel* labelAccountDetails = [[UILabel alloc] init];
            [labelAccountDetails setFrame:CGRectMake(startX, startY, netWidth, diffY)];
            [labelAccountDetails setUIFont:kUIFontType14 isBold:false];
            [labelAccountDetails setTextColor:[Utility getUIColor:kUIColorFontLight]];
            [labelAccountDetails setText:accountDetails];
            [viewPaymentDetails addSubview:labelAccountDetails];
            if ([[TMLanguage sharedManager] isRTLEnabled]) {
                [labelAccountDetails setTextAlignment:NSTextAlignmentRight];
            } else {
                [labelAccountDetails setTextAlignment:NSTextAlignmentLeft];
            }
            labelAccountDetails.lineBreakMode = NSLineBreakByWordWrapping;
            labelAccountDetails.numberOfLines = 0;
            [labelAccountDetails sizeToFitUI];
            startY += (labelAccountDetails.frame.size.height + diffY);
        }
        if (![mthdTitle isEqualToString:@""] || ![accountInstruction isEqualToString:@""] || ![accountDetails isEqualToString:@""]) {
            globalPosY += (startY);
        }else{
            [viewPaymentDetails removeFromSuperview];
        }
    }
    //////////////////////////////
#endif
    
#if SHOW_ORDER_NOTE
    /////account details///////////
    BOOL showOrderNote = true;
    
    if (showOrderNote) {
        
        UIView* viewParent = [[UIView alloc] init];
        [viewParent setFrame:CGRectMake(globalPosX, globalPosY, globalWidth, 75)];
        [viewParent setBackgroundColor:[UIColor whiteColor]];
        [viewParent addSubview:[self addBorder:viewParent]];
        [viewMain addSubview:viewParent];
        float startX = viewParent.frame.size.width * 0.02f;
        float diffY = viewParent.frame.size.width * 0.02f;
        float startY = viewParent.frame.size.width * 0.02f;
        
        if (0) {
            UILabel* labelH = [[UILabel alloc] init];
            [labelH setFrame:CGRectMake(startX, startY, netWidth, diffY)];
            [labelH setUIFont:kUIFontType14 isBold:true];
            [labelH setTextColor:[Utility getUIColor:kUIColorFontDark]];
            [labelH setText:[NSString stringWithFormat:@"%@:", Localize(@"order_note")]];
            labelH.lineBreakMode = NSLineBreakByWordWrapping;
            labelH.numberOfLines = 0;
            [labelH sizeToFitUI];
            [viewParent addSubview:labelH];
            if ([[TMLanguage sharedManager] isRTLEnabled]) {
                [labelH setTextAlignment:NSTextAlignmentRight];
            } else {
                [labelH setTextAlignment:NSTextAlignmentLeft];
            }
            startY += (labelH.frame.size.height + diffY);
        }
        
        NSString* orderNoteDesc = order._note;
        if (![orderNoteDesc isEqualToString:@""]) {
            UILabel* labelOrderNote = [[UILabel alloc] init];
            [labelOrderNote setFrame:CGRectMake(startX, startY, netWidth, diffY)];
            [labelOrderNote setUIFont:kUIFontType14 isBold:false];
            [labelOrderNote setTextColor:[Utility getUIColor:kUIColorFontLight]];
            [labelOrderNote setText:orderNoteDesc];
            [viewParent addSubview:labelOrderNote];
            if ([[TMLanguage sharedManager] isRTLEnabled]) {
                [labelOrderNote setTextAlignment:NSTextAlignmentRight];
            } else {
                [labelOrderNote setTextAlignment:NSTextAlignmentLeft];
            }
            labelOrderNote.lineBreakMode = NSLineBreakByWordWrapping;
            labelOrderNote.numberOfLines = 0;
            [labelOrderNote sizeToFitUI];
            startY += (labelOrderNote.frame.size.height + diffY);
        }
        if (![orderNoteDesc isEqualToString:@""]) {
            globalPosY += (startY);
        }else{
            [viewParent removeFromSuperview];
        }
    }
    //////////////////////////////
#endif
    
    
    
    //track buttons
    
    Addons* addons = [Addons sharedManager];
    AfterShipConfig* config = addons.afterShipConfig;
    BOOL isTrackButtonEnable = false;
    if (config != nil) {
        isTrackButtonEnable = true;
    }
    
    
    int buttonCount = 1;
    if (isTrackButtonEnable) {
        buttonCount = 2;
    }
    
    UIView* viewBottom = [[UIView alloc] init];
    [viewBottom setFrame:CGRectMake(globalPosX, globalPosY, self.view.frame.size.width * 0.96f, 50 * buttonCount)];
    [viewBottom setBackgroundColor:[UIColor whiteColor]];
    [viewBottom addSubview:[self addBorder:viewBottom]];
    netWidth = viewBottom.frame.size.width;
    startPointX = 0;
    netHeight = viewBottom.frame.size.height/buttonCount;//* 0.5f;
    [viewMain addSubview:viewBottom];
    globalPosY += viewBottom.frame.size.height;
    CGRect rectMain = viewMain.frame;
    rectMain.size.height = globalPosY;
    viewMain.frame = rectMain;
    [Utility showShadow:viewMain];
    
    if (/* DISABLES CODE */ (0)) {
        UILabel* labelTotalQuantityH = [[UILabel alloc] init];
        [labelTotalQuantityH setFrame:CGRectMake(startPointX + netWidth * .0f, 0, netWidth * .25f, netHeight)];
        [labelTotalQuantityH setUIFont:kUIFontType18 isBold:false];
        [labelTotalQuantityH setTextColor:[Utility getUIColor:kUIColorFontDark]];
        [labelTotalQuantityH setText:[NSString stringWithFormat:Localize(@"label_quantity")]];
        [viewBottom addSubview:labelTotalQuantityH];
        [labelTotalQuantityH setTextAlignment:NSTextAlignmentCenter];
        [labelTotalQuantityH.layer setBorderColor:[[Utility getUIColor:kUIColorBorder] CGColor]];
        [labelTotalQuantityH.layer setBorderWidth:1];
        UILabel* labelTotalQuantity = [[UILabel alloc] init];
        [labelTotalQuantity setFrame:CGRectMake(startPointX + netWidth * .25f, 0, netWidth * .25f, netHeight)];
        [labelTotalQuantity setUIFont:kUIFontType18 isBold:false];
        [labelTotalQuantity setTextColor:[Utility getUIColor:kUIColorFontDark]];
        [labelTotalQuantity setText:[NSString stringWithFormat:@"%d", order._total_line_items_quantity]];
        [viewBottom addSubview:labelTotalQuantity];
        [labelTotalQuantity setTextAlignment:NSTextAlignmentCenter];
        [labelTotalQuantity.layer setBorderColor:[[Utility getUIColor:kUIColorBorder] CGColor]];
        [labelTotalQuantity.layer setBorderWidth:1];
        UILabel* labelTotalPriceH = [[UILabel alloc] init];
        [labelTotalPriceH setFrame:CGRectMake(startPointX + netWidth * .5f, 0, netWidth * .25f, netHeight)];
        [labelTotalPriceH setUIFont:kUIFontType18 isBold:false];
        [labelTotalPriceH setTextColor:[Utility getUIColor:kUIColorFontDark]];
        [labelTotalPriceH setText:[NSString stringWithFormat:Localize(@"Total")]];
        [viewBottom addSubview:labelTotalPriceH];
        [labelTotalPriceH setTextAlignment:NSTextAlignmentCenter];
        [labelTotalPriceH.layer setBorderColor:[[Utility getUIColor:kUIColorBorder] CGColor]];
        [labelTotalPriceH.layer setBorderWidth:1];
        UILabel* labelTotalPrice = [[UILabel alloc] init];
        [labelTotalPrice setFrame:CGRectMake(startPointX + netWidth * .75f, 0, netWidth * .25f, netHeight)];
        [labelTotalPrice setUIFont:kUIFontType16 isBold:false];
        [labelTotalPrice setTextColor:[Utility getUIColor:kUIColorFontDark]];
        //    [labelTotalPrice setText:[NSString stringWithFormat:@"%@",[[Utility sharedManager] getCurrencyWithSign:[order._total floatValue] currencyCode:order._currency]]];
        [labelTotalPrice setText:[NSString stringWithFormat:@"%@",[[Utility sharedManager] getCurrencyWithSign:[order._total floatValue] currencyCode:order._currency symbolAtLast:isCurrencySymbolAtLast]]];
        [viewBottom addSubview:labelTotalPrice];
        [labelTotalPrice setTextAlignment:NSTextAlignmentCenter];
        [labelTotalPrice.layer setBorderColor:[[Utility getUIColor:kUIColorBorder] CGColor]];
        [labelTotalPrice.layer setBorderWidth:1];
    }
    UIButton *buttonCancelOrder = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, netWidth, netHeight)];
    [[buttonCancelOrder titleLabel] setUIFont:kUIFontType16 isBold:false];
    [buttonCancelOrder setTitle:Localize(@"i_cancel_order") forState:UIControlStateNormal];
    [buttonCancelOrder setTitleColor:[Utility getUIColor:kUIColorThemeFont] forState:UIControlStateNormal];
    [[buttonCancelOrder titleLabel] sizeToFitUI];
    [buttonCancelOrder setTitleColor:[Utility getUIColor:kUIColorFontLight] forState:UIControlStateDisabled];
    [buttonCancelOrder setContentMode:UIViewContentModeLeft];
    [viewBottom addSubview:buttonCancelOrder];
    [buttonCancelOrder addTarget:self action:@selector(cancelOrder:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *buttonTrackOrder = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(buttonCancelOrder.frame), netWidth, netHeight)];
    [[buttonTrackOrder titleLabel] setUIFont:kUIFontType18 isBold:false];
    [buttonTrackOrder setTitle:Localize(@"track_order") forState:UIControlStateNormal];
    [buttonTrackOrder setTitleColor:[Utility getUIColor:kUIColorThemeFont] forState:UIControlStateNormal];
    [buttonTrackOrder setTitleColor:[Utility getUIColor:kUIColorFontLight] forState:UIControlStateDisabled];
    [buttonTrackOrder setUIImage:[UIImage imageNamed:@"track-icon.png"] forState:UIControlStateNormal];
    [buttonTrackOrder setUIImage:[UIImage imageNamed:@"track-icon.png"] forState:UIControlStateSelected];
    [buttonTrackOrder setContentMode:UIViewContentModeScaleAspectFit];
    [[buttonTrackOrder imageView] setContentMode:UIViewContentModeScaleAspectFit];
    [buttonTrackOrder setImageEdgeInsets:UIEdgeInsetsMake(netHeight * .25f, 0, netHeight * .33f, 0)];
    [buttonTrackOrder setBackgroundColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
    [buttonTrackOrder setTitleColor:[Utility getUIColor:kUIColorBuyButtonFont] forState:UIControlStateNormal];
    if(isTrackButtonEnable){
        [viewBottom addSubview:buttonTrackOrder];
    }
    [buttonTrackOrder addTarget:self action:@selector(trackOrder:) forControlEvents:UIControlEventTouchUpInside];
    [buttonTrackOrder.layer setBorderColor:[[Utility getUIColor:kUIColorBorder] CGColor]];
    [buttonTrackOrder.layer setBorderWidth:1];
    buttonTrackOrder.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    buttonTrackOrder.titleLabel.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    buttonTrackOrder.imageView.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    
    [buttonTrackOrder.layer setValue:order forKey:@"MY_OBJECT"];
    //    [buttonTrackOrder.layer setValue:viewMain forKey:@"MY_VIEW"];
    //    [buttonTrackOrder.layer setValue:buttonCancelOrder forKey:@"ORDER_BUTTON_OBJECT"];
    //    [buttonTrackOrder.layer setValue:buttonTrackOrder forKey:@"TRACK_BUTTON_OBJECT"];
    
    [buttonCancelOrder.layer setValue:order forKey:@"MY_OBJECT"];
    [buttonCancelOrder.layer setValue:viewMain forKey:@"MY_VIEW"];
    [buttonCancelOrder.layer setValue:buttonCancelOrder forKey:@"ORDER_BUTTON_OBJECT"];
    [buttonCancelOrder.layer setValue:buttonTrackOrder forKey:@"TRACK_BUTTON_OBJECT"];
    
    
    
    if([order._status isEqualToString:@"failed"] ||
       [order._status isEqualToString:@"pending"]
       ){
        [buttonCancelOrder setEnabled:true];
        [buttonTrackOrder setEnabled:true];
    } else {
        BOOL isOrderAgainButtonEnable = [[Addons sharedManager] order_again];
        NSString* orderStatusStr = @"";
        if([order._status isEqualToString:@"completed"]) {
            orderStatusStr = Localize(@"completed");
        }
        else if([order._status isEqualToString:@"cancelled"]) {
            orderStatusStr = Localize(@"cancelled");
        }
        else if([order._status isEqualToString:@"refunded"]) {
            orderStatusStr = Localize(@"refunded");
        }
        else if([order._status isEqualToString:@"failed"]) {
            orderStatusStr = Localize(@"failed");
        }
        else if([order._status isEqualToString:@"processing"]) {
            orderStatusStr = Localize(@"processing");
        }
        else if([order._status isEqualToString:@"pending"]) {
            orderStatusStr = Localize(@"pending");
        }
        else if([order._status isEqualToString:@"on-hold"]) {
            orderStatusStr = Localize(@"onhold");
        }
        if (([order._status isEqualToString:@"completed"] && isOrderAgainButtonEnable)) {
            NSString* text = [NSString stringWithFormat:Localize(@"i_order_val"), orderStatusStr];
            text = [NSString stringWithFormat:@"%@ %@", text, Localize(@"order_again")];
            [buttonCancelOrder setTitle:text forState:UIControlStateNormal];
            //            CGRect rect = CGRectMake(0, 0, netWidth, netHeight);
            //            buttonCancelOrder.frame = rect;
            [buttonCancelOrder setEnabled:true];
            [buttonCancelOrder setBackgroundColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
            [buttonCancelOrder setTitleColor:[Utility getUIColor:kUIColorBuyButtonFont] forState:UIControlStateNormal];
            [buttonCancelOrder removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
            [buttonCancelOrder addTarget:self action:@selector(reOrder:) forControlEvents:UIControlEventTouchUpInside];
            [buttonCancelOrder.layer setValue:order forKey:@"ORDER_OBJ"];
        } else {
            [buttonCancelOrder setTitle:[NSString stringWithFormat:Localize(@"i_order_val"), orderStatusStr] forState:UIControlStateDisabled];
            //            CGRect rect = CGRectMake(0, 0, netWidth, netHeight);
            //            buttonCancelOrder.frame = rect;
            [buttonCancelOrder setEnabled:false];
            if (isTrackButtonEnable) {
                [buttonTrackOrder setEnabled:true];
                [buttonTrackOrder setHidden:false];
            } else {
                [buttonTrackOrder setHidden:true];
            }
        }
    }
    return viewMain;
}
#else
#pragma mark- THREE STATUS
- (UIView*)createOrderSummery:(int)listId order:(Order*)order viewMain:(UIView*)viewMain {
    RLOG(@"===========createOrderSummery============%d", order._id);
    ///header
    BOOL isCurrencySymbolAtLast = true;
    
    float globalPosY = 0;
    float globalPosX = 0;
    float globalWidth = self.view.frame.size.width * 0.96f;
    
    if (viewMain == nil) {
        viewMain = [[UIView alloc] init];
        [viewMain setTag:kTagForGlobalSpacing];
        [_scrollView addSubview:viewMain];
        [_viewsAdded addObject:viewMain];
        viewMain.hidden = true;
    }else{
        for (UIView* view in [viewMain subviews]) {
            [view removeFromSuperview];
        }
    }
    
    [viewMain setFrame:CGRectMake(self.view.frame.size.width * 0.02f, 0, self.view.frame.size.width * 0.96f, globalPosY)];
    [viewMain setBackgroundColor:[UIColor whiteColor]];
    
    
    UIView* viewTop = [[UIView alloc] init];
    [viewTop setFrame:CGRectMake(globalPosX, globalPosY, globalWidth, 50)];
    [viewTop setBackgroundColor:[UIColor whiteColor]];
    [viewMain addSubview:viewTop];
    globalPosY += 50;
    //    [viewTop.layer setBorderColor:[[Utility getUIColor:kUIColorBorder] CGColor]];
    //    [viewTop.layer setBorderWidth:1];
    //    [viewTop setTag:kTagForNoSpacing];
    //    [_scrollView addSubview:viewTop];
    //    [_viewsAdded addObject:viewTop];
    
    //    "pending": "Pending Payment",
    //    "processing": "Processing",
    //    "on-hold": "On Hold",
    //    "completed": "Completed",
    //    "cancelled": "Cancelled",
    //    "refunded": "Refunded",
    //    "failed": "Failed"
    
    
    
    
    
    
    
    UILabel* labelOrderId = [[UILabel alloc] init];
    [labelOrderId setFrame:CGRectMake(self.view.frame.size.width * 0.02f, 0, viewTop.frame.size.width, 50)];
    [labelOrderId setUIFont:kUIFontType16 isBold:true];
    [labelOrderId setTextColor:[Utility getUIColor:kUIColorFontDark]];
    
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        [labelOrderId setText:[NSString stringWithFormat:@"%@ :%@", order._order_number_str, Localize(@"i_orderid")]];
        [labelOrderId setTextAlignment:NSTextAlignmentRight];
    } else {
        [labelOrderId setText:[NSString stringWithFormat:@"%@: %@", Localize(@"i_orderid"),order._order_number_str]];
        [labelOrderId setTextAlignment:NSTextAlignmentLeft];
    }
    
    [viewTop addSubview:labelOrderId];
    
    UILabel* labelOrderDate = [[UILabel alloc] init];
    [labelOrderDate setFrame:CGRectMake(0, 0, viewTop.frame.size.width*.98f, 50)];
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        [labelOrderDate setTextAlignment:NSTextAlignmentLeft];
    } else {
        [labelOrderDate setTextAlignment:NSTextAlignmentRight];
    }
    [labelOrderDate setUIFont:kUIFontType16 isBold:false];
    [labelOrderDate setTextColor:[Utility getUIColor:kUIColorFontDark]];
    NSDate* date = order._created_at;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    NSString* userLocale = [[NSUserDefaults standardUserDefaults] valueForKey:USER_LOCALE];
    NSString* defaultLocale = [[NSUserDefaults standardUserDefaults] valueForKey:DEFAULT_LOCALE];
    NSString* selectedLocale = @"";
    if (userLocale && ![userLocale isEqualToString:@""]) {
        selectedLocale = userLocale;
    } else if (defaultLocale && ![defaultLocale isEqualToString:@""]) {
        selectedLocale = defaultLocale;
    } else {
        selectedLocale = @"en_US";
    }
    [dateFormat setLocale:[NSLocale localeWithLocaleIdentifier:selectedLocale]];
    [dateFormat setDateFormat:[[Addons sharedManager]date_format]];
    NSString* temp = [dateFormat stringFromDate:date];
    [labelOrderDate setText:[NSString stringWithFormat:@"%@", temp]];
    [viewTop addSubview:labelOrderDate];
    
    ///items
    int lineItemsCount = (int)[[order _line_items] count];
    if (lineItemsCount > 0) {
        for (LineItem* lineItem in order._line_items) {
            if (order._id == 828)
            {
                RLOG(@"order._id = %d", order._id);
            }
            UIView* lineItemView = [self addView:lineItem currencyCode:order._currency isCurrencySymbolAtLast:isCurrencySymbolAtLast];
            [viewMain addSubview:lineItemView];
            [lineItemView addSubview:[self addBorder:lineItemView]];
            CGRect rect = lineItemView.frame;
            rect.origin.y = globalPosY;
            rect.origin.x = 0;
            lineItemView.frame = rect;
            globalPosY += lineItemView.frame.size.height;
        }
    }
    
    
    //other views
    UIView* viewOther = [[UIView alloc] init];
    [viewOther setFrame:CGRectMake(0, 0, self.view.frame.size.width * 0.96f, 0)];
    [viewOther setBackgroundColor:[UIColor whiteColor]];
    //    [viewOther.layer setBorderColor:[[Utility getUIColor:kUIColorBorder] CGColor]];
    //    [viewOther.layer setBorderWidth:1];
    [viewOther setTag:kTagForNoSpacing];
    [viewOther addSubview:[self addBorder:viewOther]];
    //    [_scrollView addSubview:viewOther];
    //    [_viewsAdded addObject:viewOther];
    
    float netWidth = viewOther.frame.size.width * 0.96f;
    float startPointX = viewOther.frame.size.width * 0.02f;
    float startPointY = viewOther.frame.size.width * 0.02f;
    float netHeight = 25;
    
    //for tax
    if (order._total_tax != 0.0f)
    {
        UILabel* labelH = [[UILabel alloc] init];
        [labelH setFrame:CGRectMake(startPointX, startPointY, netWidth, netHeight)];
        [labelH setUIFont:kUIFontType16 isBold:false];
        [labelH setTextColor:[Utility getUIColor:kUIColorFontLight]];
        [labelH setText:[NSString stringWithFormat:Localize(@"total_tax")]];
        [viewOther addSubview:labelH];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [labelH setTextAlignment:NSTextAlignmentRight];
        } else {
            [labelH setTextAlignment:NSTextAlignmentLeft];
        }
        
        UILabel* label = [[UILabel alloc] init];
        [label setFrame:CGRectMake(startPointX, startPointY, netWidth, netHeight)];
        [label setUIFont:kUIFontType16 isBold:false];
        [label setTextColor:[Utility getUIColor:kUIColorFontLight]];
        [label setText:[NSString stringWithFormat:@"%@",[[Utility sharedManager] getCurrencyWithSign:order._total_tax currencyCode:order._currency symbolAtLast:isCurrencySymbolAtLast]]];
        [viewOther addSubview:label];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [label setTextAlignment:NSTextAlignmentLeft];
        } else {
            [label setTextAlignment:NSTextAlignmentRight];
        }
        startPointY += netHeight;
    }
    
    //for shipping tax
    if (order._total_shipping != 0.0f)
    {
        UILabel* labelH = [[UILabel alloc] init];
        [labelH setFrame:CGRectMake(startPointX, startPointY, netWidth, netHeight)];
        [labelH setUIFont:kUIFontType16 isBold:false];
        [labelH setTextColor:[Utility getUIColor:kUIColorFontLight]];
        [labelH setText:[NSString stringWithFormat:Localize(@"i_total_shipping_cost")]];
        [viewOther addSubview:labelH];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [labelH setTextAlignment:NSTextAlignmentRight];
        } else {
            [labelH setTextAlignment:NSTextAlignmentLeft];
        }
        
        UILabel* label = [[UILabel alloc] init];
        [label setFrame:CGRectMake(startPointX, startPointY, netWidth, netHeight)];
        [label setUIFont:kUIFontType16 isBold:false];
        [label setTextColor:[Utility getUIColor:kUIColorFontLight]];
        [label setText:[NSString stringWithFormat:@"%@",[[Utility sharedManager] getCurrencyWithSign:order._total_shipping currencyCode:order._currency symbolAtLast:isCurrencySymbolAtLast]]];
        
        [viewOther addSubview:label];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [label setTextAlignment:NSTextAlignmentLeft];
        } else {
            [label setTextAlignment:NSTextAlignmentRight];
        }
        startPointY += netHeight;
    }
    
    
    //for extra charges
    if (order._fee_lines && [order._fee_lines count] > 0)
    {
        float totalExtraCharges = 0.0f;
        for (FeeLine* feeline in order._fee_lines) {
            totalExtraCharges += feeline.total;
        }
        
        UILabel* labelH = [[UILabel alloc] init];
        [labelH setFrame:CGRectMake(startPointX, startPointY, netWidth, netHeight)];
        [labelH setUIFont:kUIFontType16 isBold:false];
        [labelH setTextColor:[Utility getUIColor:kUIColorFontLight]];
        [labelH setText:[NSString stringWithFormat:Localize(@"Total Extra Charges")]];
        [viewOther addSubview:labelH];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [labelH setTextAlignment:NSTextAlignmentRight];
        } else {
            [labelH setTextAlignment:NSTextAlignmentLeft];
        }
        
        UILabel* label = [[UILabel alloc] init];
        [label setFrame:CGRectMake(startPointX, startPointY, netWidth, netHeight)];
        [label setUIFont:kUIFontType16 isBold:false];
        [label setTextColor:[Utility getUIColor:kUIColorFontLight]];
        [label setText:[NSString stringWithFormat:@"%@",[[Utility sharedManager] getCurrencyWithSign:totalExtraCharges currencyCode:order._currency symbolAtLast:isCurrencySymbolAtLast]]];
        
        [viewOther addSubview:label];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [label setTextAlignment:NSTextAlignmentLeft];
        } else {
            [label setTextAlignment:NSTextAlignmentRight];
        }
        startPointY += netHeight;
    }
    
    
    //for discount
    if (order._total_discount != 0.0f)
    {
        UILabel* labelH = [[UILabel alloc] init];
        [labelH setFrame:CGRectMake(startPointX, startPointY, netWidth, netHeight)];
        [labelH setUIFont:kUIFontType16 isBold:false];
        [labelH setTextColor:[Utility getUIColor:kUIColorFontLight]];
        [labelH setText:[NSString stringWithFormat:Localize(@"total_savings")]];
        [viewOther addSubview:labelH];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [labelH setTextAlignment:NSTextAlignmentRight];
        } else {
            [labelH setTextAlignment:NSTextAlignmentLeft];
        }
        UILabel* label = [[UILabel alloc] init];
        [label setFrame:CGRectMake(startPointX, startPointY, netWidth, netHeight)];
        [label setUIFont:kUIFontType16 isBold:false];
        [label setTextColor:[Utility getUIColor:kUIColorFontLight]];
        [label setText:[NSString stringWithFormat:@"- %@",[[Utility sharedManager] getCurrencyWithSign:order._total_discount currencyCode:order._currency symbolAtLast:isCurrencySymbolAtLast]]];
        [viewOther addSubview:label];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [label setTextAlignment:NSTextAlignmentLeft];
        } else {
            [label setTextAlignment:NSTextAlignmentRight];
        }
        startPointY += netHeight;
    }
    //for reward points
    if([[Addons sharedManager] enable_custom_points]) {
        UILabel* labelPointsEarned = [[UILabel alloc] init];
        [labelPointsEarned setFrame:CGRectMake(startPointX, startPointY, netWidth, netHeight)];
        [labelPointsEarned setUIFont:kUIFontType16 isBold:false];
        [labelPointsEarned setTextColor:[Utility getUIColor:kUIColorFontLight]];
        [labelPointsEarned setText:[NSString stringWithFormat:@"%@: %d",Localize(@"i_points_earned"), order.pointsEarned]];
        [viewOther addSubview:labelPointsEarned];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [labelPointsEarned setTextAlignment:NSTextAlignmentRight];
        } else {
            [labelPointsEarned setTextAlignment:NSTextAlignmentLeft];
        }
        UILabel* labelPointsRedeemed = [[UILabel alloc] init];
        [labelPointsRedeemed setFrame:CGRectMake(startPointX, startPointY, netWidth, netHeight)];
        [labelPointsRedeemed setUIFont:kUIFontType16 isBold:false];
        [labelPointsRedeemed setTextColor:[Utility getUIColor:kUIColorFontLight]];
        [labelPointsRedeemed setText:[NSString stringWithFormat:@"%@: %d",Localize(@"i_points_redeemed"), order.pointsRedeemed]];
        [viewOther addSubview:labelPointsRedeemed];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [labelPointsRedeemed setTextAlignment:NSTextAlignmentLeft];
        } else {
            [labelPointsRedeemed setTextAlignment:NSTextAlignmentRight];
        }
        startPointY += netHeight;
    }
    startPointY += viewOther.frame.size.width * 0.02f;
    
    
#if SHOW_DATE_TIME_SLOT
    {
        Addons* addons = [Addons sharedManager];
        BOOL showDateSlot = (addons.deliverySlotsCopiaPlugin && addons.deliverySlotsCopiaPlugin.isEnabled) ? true : false ;
        BOOL showTimeSlot = showDateSlot ? true : (addons.localPickupTimeSelectPlugin && addons.localPickupTimeSelectPlugin.isEnabled) ? true : false ;
        if (showDateSlot) {
            UILabel* label = [[UILabel alloc] init];
            [label setFrame:CGRectMake(startPointX, startPointY, netWidth, netHeight)];
            [label setUIFont:kUIFontType16 isBold:false];
            [label setTextColor:[Utility getUIColor:kUIColorFontLight]];
            [viewOther addSubview:label];
            if ([[TMLanguage sharedManager] isRTLEnabled]) {
                [label setTextAlignment:NSTextAlignmentRight];
            } else {
                [label setTextAlignment:NSTextAlignmentLeft];
            }
            [label setText:[NSString stringWithFormat:@"%@ : %@", Localize(@"delivery_date"), order.deliveryDateString]];
            [label sizeToFitUI];
            
            UIActivityIndicatorView* spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [viewOther addSubview:spinnerView];
            [spinnerView setFrame:CGRectMake(
                                             CGRectGetMaxX(label.frame),
                                             0,
                                             spinnerView.frame.size.width,
                                             spinnerView.frame.size.height)];
            spinnerView.center = CGPointMake(spinnerView.center.x, label.center.y);
            
            if (order.deliveryDateString && ![order.deliveryDateString isEqualToString:@""]) {
                [spinnerView stopAnimating];
            } else {
                [spinnerView startAnimating];
            }
            startPointY += netHeight;
        }
        if (showTimeSlot) {
            UILabel* label = [[UILabel alloc] init];
            [label setFrame:CGRectMake(startPointX, startPointY, netWidth, netHeight)];
            [label setUIFont:kUIFontType16 isBold:false];
            [label setTextColor:[Utility getUIColor:kUIColorFontLight]];
            [viewOther addSubview:label];
            if ([[TMLanguage sharedManager] isRTLEnabled]) {
                [label setTextAlignment:NSTextAlignmentRight];
            } else {
                [label setTextAlignment:NSTextAlignmentLeft];
            }
            [label setText:[NSString stringWithFormat:@"%@ : %@", Localize(@"delivery_time"), order.deliveryTimeString]];
            [label sizeToFitUI];
            UIActivityIndicatorView* spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [viewOther addSubview:spinnerView];
            [spinnerView setFrame:CGRectMake(
                                             CGRectGetMaxX(label.frame),
                                             0,
                                             spinnerView.frame.size.width,
                                             spinnerView.frame.size.height)];
            spinnerView.center = CGPointMake(spinnerView.center.x, label.center.y);
            if (order.deliveryTimeString && ![order.deliveryTimeString isEqualToString:@""]) {
                [spinnerView stopAnimating];
            } else {
                [spinnerView startAnimating];
            }
            startPointY += netHeight;
        }
    }
#endif
    
    if (0) {
        UIView* viewHorizontalBar = [[UIView alloc] init];
        [viewHorizontalBar setFrame:CGRectMake(0, startPointY, viewOther.frame.size.width, 2)];
        [viewHorizontalBar setBackgroundColor:[Utility getUIColor:kUIColorBorder]];
        [viewOther addSubview:viewHorizontalBar];
        startPointY += 2;
        startPointY += viewOther.frame.size.width * 0.02f;
    }
    //for total
    startPointY += viewOther.frame.size.width * 0.02f;
    {
        UILabel* labelH = [[UILabel alloc] init];
        [labelH setFrame:CGRectMake(startPointX, startPointY, netWidth, netHeight)];
        [labelH setUIFont:kUIFontType16 isBold:true];
        [labelH setTextColor:[Utility getUIColor:kUIColorFontDark]];
        [labelH setText:[NSString stringWithFormat:Localize(@"i_grand_total")]];
        [viewOther addSubview:labelH];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [labelH setTextAlignment:NSTextAlignmentRight];
        } else {
            [labelH setTextAlignment:NSTextAlignmentLeft];
        }
        UILabel* label = [[UILabel alloc] init];
        [label setFrame:CGRectMake(startPointX, startPointY, netWidth, netHeight)];
        [label setUIFont:kUIFontType16 isBold:true];
        [label setTextColor:[Utility getUIColor:kUIColorFontDark]];
        [label setText:[NSString stringWithFormat:@"%@",[[Utility sharedManager] getCurrencyWithSign:[order._total floatValue] currencyCode:order._currency symbolAtLast:isCurrencySymbolAtLast]]];
        [viewOther addSubview:label];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [label setTextAlignment:NSTextAlignmentLeft];
        } else {
            [label setTextAlignment:NSTextAlignmentRight];
        }
        startPointY += netHeight;
    }
    startPointY += viewOther.frame.size.width * 0.02f;
    if (0) {
        UIView* viewHorizontalBar1 = [[UIView alloc] init];
        [viewHorizontalBar1 setFrame:CGRectMake(0, startPointY, viewOther.frame.size.width, 2)];
        [viewHorizontalBar1 setBackgroundColor:[Utility getUIColor:kUIColorBorder]];
        [viewOther addSubview:viewHorizontalBar1];
        startPointY += 2;
        startPointY += viewOther.frame.size.width * 0.02f;
    }
    //for line items count
    if (0)
    {
        UILabel* labelH = [[UILabel alloc] init];
        [labelH setFrame:CGRectMake(startPointX, startPointY, netWidth, netHeight)];
        [labelH setUIFont:kUIFontType16 isBold:false];
        [labelH setTextColor:[Utility getUIColor:kUIColorFontDark]];
        [labelH setText:[NSString stringWithFormat:Localize(@"i_total_items")]];
        [viewOther addSubview:labelH];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [labelH setTextAlignment:NSTextAlignmentRight];
        } else {
            [labelH setTextAlignment:NSTextAlignmentLeft];
        }
        UILabel* label = [[UILabel alloc] init];
        [label setFrame:CGRectMake(startPointX, startPointY, netWidth, netHeight)];
        [label setUIFont:kUIFontType16 isBold:false];
        [label setTextColor:[Utility getUIColor:kUIColorFontDark]];
        [label setText:[NSString stringWithFormat:@"%d",order._total_line_items_quantity]];
        [viewOther addSubview:label];
        if ([[TMLanguage sharedManager] isRTLEnabled]) {
            [label setTextAlignment:NSTextAlignmentLeft];
        } else {
            [label setTextAlignment:NSTextAlignmentRight];
        }
        startPointY += netHeight;
        startPointY += viewOther.frame.size.width * 0.02f;
    }
    [viewOther setFrame:CGRectMake(0, globalPosY, self.view.frame.size.width * 0.96f, startPointY)];
    [viewMain addSubview:viewOther];
    globalPosY += viewOther.frame.size.height;
    
    if ([order._status isEqualToString:@"pending"] ||
        [order._status isEqualToString:@"processing"] ||
        [order._status isEqualToString:@"on-hold"] ||
        [order._status isEqualToString:@"completed"]) {
        
        UIView* viewProgress = [[UIView alloc] init];
        [viewProgress setFrame:CGRectMake(globalPosX, globalPosY, globalWidth, 75)];
        [viewProgress setBackgroundColor:[UIColor whiteColor]];
        
        [viewProgress addSubview:[self addBorder:viewProgress]];
        //        [viewProgress.layer setBorderColor:[[Utility getUIColor:kUIColorBorder] CGColor]];
        //        [viewProgress.layer setBorderWidth:1];
        [viewMain addSubview:viewProgress];
        globalPosY += 75;
        int j = -1;
        if ([order._status isEqualToString:@"pending"]) {
            j = 0;
        }
        if ([order._status isEqualToString:@"processing"]) {
            j = 1;
        }
        if ([order._status isEqualToString:@"on-hold"]) {
            j = 0;
        }
        if ([order._status isEqualToString:@"completed"]) {
            j = 3;
        }
        for (int i = 0; i < 3; i++) {
            if(i == 2) {
                continue;
            }
            UIView* imgView = [[UIView alloc] init];
            [imgView setFrame:CGRectMake(0, 0, viewProgress.frame.size.width * 0.375f, viewProgress.frame.size.height * 0.25f * 0.25f)];
            if (i == 0) {
                imgView.center = CGPointMake(viewProgress.frame.size.width * 0.32f, viewProgress.frame.size.height*.33f);
            }
            if (i == 1) {
                imgView.center = CGPointMake(viewProgress.frame.size.width * 0.70f, viewProgress.frame.size.height*.33f);
            }
            [viewProgress addSubview:imgView];
            if (i < j) {
                imgView.backgroundColor = [Utility getUIColor:kUIColorBlue];//[Utility getUIColor:kUIColorThemeButtonSelected];
            } else {
                imgView.backgroundColor = [Utility getUIColor:kUIColorBorder];//[Utility getUIColor:kUIColorThemeButtonNormal];
            }
            
            
//            if (i == 0) {
//                imgView.backgroundColor = [UIColor redColor];
//            }
//            if (i == 1) {
//                imgView.backgroundColor = [UIColor greenColor];
//            }
//            if (i == 2) {
//                imgView.backgroundColor = [UIColor blueColor];
//            }
            
        }
        for (int i = 0; i < 4; i++) {
            if (i == 2) {
                continue;
            }
            UIImageView* imgView = [[UIImageView alloc] init];
            [imgView setFrame:CGRectMake(0, 0, viewProgress.frame.size.height * 0.25f, viewProgress.frame.size.height * 0.25f)];
            imgView.contentMode = UIViewContentModeScaleAspectFit;
            imgView.center = CGPointMake(viewProgress.frame.size.width * 0.125f + i * viewProgress.frame.size.width * 0.25f, viewProgress.frame.size.height*.33f);
            if (i == 1) {
                imgView.center = CGPointMake(viewProgress.frame.size.width * 0.5f, viewProgress.frame.size.height*.33f);
            }
            
            
            [viewProgress addSubview:imgView];
            
            
            UILabel* label = [[UILabel alloc] init];
            [label setFrame:CGRectMake(self.view.frame.size.width * 0.02f, 0, viewTop.frame.size.width, viewProgress.frame.size.height)];
            [label setUIFont:kUIFontType14 isBold:false];
            [label setTextColor:[Utility getUIColor:kUIColorFontLight]];
            switch (i) {
                case 0:
                    [label setText:[NSString stringWithFormat:Localize(@"approval")]];
                    if ([order._status isEqualToString:@"on-hold"]) {
                        [label setText:[NSString stringWithFormat:Localize(@"onhold")]];
                    }
                    break;
                case 1:
                    [label setText:[NSString stringWithFormat:Localize(@"processing")]];
                    break;
                case 2:
                    [label setText:[NSString stringWithFormat:Localize(@"shipping")]];
                    break;
                case 3:
                    [label setText:[NSString stringWithFormat:Localize(@"delivered")]];
                    break;
                    
                default:
                    break;
            }
            [label sizeToFitUI];
            label.center = CGPointMake(viewProgress.frame.size.width * 0.125f + i * viewProgress.frame.size.width * 0.25f, viewProgress.frame.size.height*.66f);
            if (i == 1) {
                label.center = CGPointMake(viewProgress.frame.size.width * 0.5f, viewProgress.frame.size.height*.66f);
            }
            [viewProgress addSubview:label];
            
            if (i <= j) {
                [imgView setUIImage:[[UIImage imageNamed:@"checked_circle"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
                imgView.tintColor = [Utility getUIColor:kUIColorBlue];//[Utility getUIColor:kUIColorThemeButtonSelected];
            } else {
                [imgView setUIImage:[[UIImage imageNamed:@"checked_circle"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
                imgView.tintColor = [Utility getUIColor:kUIColorBorder];//[Utility getUIColor:kUIColorThemeButtonNormal];
            }
        }
    }
    
    
    
    
    
#if SHOW_ACCOUNT_DETAILS_ORDER_SCREEN
    /////account details///////////
    BOOL showAccountDetails = false;
    TMPaymentSDK* tmPaymentSDK = [[DataManager sharedManager] tmPaymentSDK];
    TMPaymentGateway* paymentGatewaySelected = nil;
    if(tmPaymentSDK.paymentGateways) {
        for (TMPaymentGateway* paymentGateway in tmPaymentSDK.paymentGateways) {
            if ([paymentGateway.paymentId isEqualToString:order._payment_details._method_id]) {
                showAccountDetails = true;
                paymentGatewaySelected = paymentGateway;
                break;
            }
        }
    }
    if (showAccountDetails) {
        NSString* mthdTitle = order._payment_details._method_title;
        UIView* viewPaymentDetails = [[UIView alloc] init];
        [viewPaymentDetails setFrame:CGRectMake(globalPosX, globalPosY, globalWidth, 75)];
        [viewPaymentDetails setBackgroundColor:[UIColor whiteColor]];
        [viewPaymentDetails addSubview:[self addBorder:viewPaymentDetails]];
        [viewMain addSubview:viewPaymentDetails];
        float startX = viewPaymentDetails.frame.size.width * 0.02f;
        float diffY = viewPaymentDetails.frame.size.width * 0.02f;
        float startY = viewPaymentDetails.frame.size.width * 0.02f;
        
        if (![mthdTitle isEqualToString:@""]) {
            UILabel* labelH = [[UILabel alloc] init];
            [labelH setFrame:CGRectMake(startX, startY, netWidth, diffY)];
            [labelH setUIFont:kUIFontType14 isBold:true];
            [labelH setTextColor:[Utility getUIColor:kUIColorFontDark]];
            [labelH setText:[NSString stringWithFormat:@"%@: %@", Localize(@"payment_method"), order._payment_details._method_title]];
            labelH.lineBreakMode = NSLineBreakByWordWrapping;
            labelH.numberOfLines = 0;
            [labelH sizeToFitUI];
            [viewPaymentDetails addSubview:labelH];
            if ([[TMLanguage sharedManager] isRTLEnabled]) {
                [labelH setTextAlignment:NSTextAlignmentRight];
            } else {
                [labelH setTextAlignment:NSTextAlignmentLeft];
            }
            startY += (labelH.frame.size.height + diffY);
        }
        NSString* accountDetails = [paymentGatewaySelected getAccountDetailsString];
        NSString* accountInstruction = paymentGatewaySelected.paymentInstruction;
        if (![order._status isEqualToString:@"on-hold"]) {
            accountDetails = @"";
            accountInstruction = @"";
        }
        if (![accountInstruction isEqualToString:@""]) {
            UILabel* labelInstruction = [[UILabel alloc] init];
            [labelInstruction setFrame:CGRectMake(startX, startY, netWidth, diffY)];
            [labelInstruction setUIFont:kUIFontType14 isBold:false];
            [labelInstruction setTextColor:[Utility getUIColor:kUIColorFontLight]];
            [labelInstruction setText:accountInstruction];
            [viewPaymentDetails addSubview:labelInstruction];
            if ([[TMLanguage sharedManager] isRTLEnabled]) {
                [labelInstruction setTextAlignment:NSTextAlignmentRight];
            } else {
                [labelInstruction setTextAlignment:NSTextAlignmentLeft];
            }
            labelInstruction.lineBreakMode = NSLineBreakByWordWrapping;
            labelInstruction.numberOfLines = 0;
            [labelInstruction sizeToFitUI];
            startY += (labelInstruction.frame.size.height + diffY);
        }
        if (![accountDetails isEqualToString:@""]) {
            UILabel* labelAccountDetails = [[UILabel alloc] init];
            [labelAccountDetails setFrame:CGRectMake(startX, startY, netWidth, diffY)];
            [labelAccountDetails setUIFont:kUIFontType14 isBold:false];
            [labelAccountDetails setTextColor:[Utility getUIColor:kUIColorFontLight]];
            [labelAccountDetails setText:accountDetails];
            [viewPaymentDetails addSubview:labelAccountDetails];
            if ([[TMLanguage sharedManager] isRTLEnabled]) {
                [labelAccountDetails setTextAlignment:NSTextAlignmentRight];
            } else {
                [labelAccountDetails setTextAlignment:NSTextAlignmentLeft];
            }
            labelAccountDetails.lineBreakMode = NSLineBreakByWordWrapping;
            labelAccountDetails.numberOfLines = 0;
            [labelAccountDetails sizeToFitUI];
            startY += (labelAccountDetails.frame.size.height + diffY);
        }
        if (![mthdTitle isEqualToString:@""] || ![accountInstruction isEqualToString:@""] || ![accountDetails isEqualToString:@""]) {
            globalPosY += (startY);
        }else{
            [viewPaymentDetails removeFromSuperview];
        }
    }
    //////////////////////////////
#endif
    
#if SHOW_ORDER_NOTE
    /////account details///////////
    BOOL showOrderNote = true;
    
    if (showOrderNote) {
        
        UIView* viewParent = [[UIView alloc] init];
        [viewParent setFrame:CGRectMake(globalPosX, globalPosY, globalWidth, 75)];
        [viewParent setBackgroundColor:[UIColor whiteColor]];
        [viewParent addSubview:[self addBorder:viewParent]];
        [viewMain addSubview:viewParent];
        float startX = viewParent.frame.size.width * 0.02f;
        float diffY = viewParent.frame.size.width * 0.02f;
        float startY = viewParent.frame.size.width * 0.02f;
        
        if (0) {
            UILabel* labelH = [[UILabel alloc] init];
            [labelH setFrame:CGRectMake(startX, startY, netWidth, diffY)];
            [labelH setUIFont:kUIFontType14 isBold:true];
            [labelH setTextColor:[Utility getUIColor:kUIColorFontDark]];
            [labelH setText:[NSString stringWithFormat:@"%@:", Localize(@"order_note")]];
            labelH.lineBreakMode = NSLineBreakByWordWrapping;
            labelH.numberOfLines = 0;
            [labelH sizeToFitUI];
            [viewParent addSubview:labelH];
            if ([[TMLanguage sharedManager] isRTLEnabled]) {
                [labelH setTextAlignment:NSTextAlignmentRight];
            } else {
                [labelH setTextAlignment:NSTextAlignmentLeft];
            }
            startY += (labelH.frame.size.height + diffY);
        }
        
        NSString* orderNoteDesc = order._note;
        if (![orderNoteDesc isEqualToString:@""]) {
            UILabel* labelOrderNote = [[UILabel alloc] init];
            [labelOrderNote setFrame:CGRectMake(startX, startY, netWidth, diffY)];
            [labelOrderNote setUIFont:kUIFontType14 isBold:false];
            [labelOrderNote setTextColor:[Utility getUIColor:kUIColorFontLight]];
            [labelOrderNote setText:orderNoteDesc];
            [viewParent addSubview:labelOrderNote];
            if ([[TMLanguage sharedManager] isRTLEnabled]) {
                [labelOrderNote setTextAlignment:NSTextAlignmentRight];
            } else {
                [labelOrderNote setTextAlignment:NSTextAlignmentLeft];
            }
            labelOrderNote.lineBreakMode = NSLineBreakByWordWrapping;
            labelOrderNote.numberOfLines = 0;
            [labelOrderNote sizeToFitUI];
            startY += (labelOrderNote.frame.size.height + diffY);
        }
        if (![orderNoteDesc isEqualToString:@""]) {
            globalPosY += (startY);
        }else{
            [viewParent removeFromSuperview];
        }
    }
    //////////////////////////////
#endif
    
    
    
    //track buttons
    
    Addons* addons = [Addons sharedManager];
    AfterShipConfig* config = addons.afterShipConfig;
    BOOL isTrackButtonEnable = false;
    if (config != nil) {
        isTrackButtonEnable = true;
    }
    
    
    int buttonCount = 1;
    if (isTrackButtonEnable) {
        buttonCount = 2;
    }
    
    UIView* viewBottom = [[UIView alloc] init];
    [viewBottom setFrame:CGRectMake(globalPosX, globalPosY, self.view.frame.size.width * 0.96f, 50 * buttonCount)];
    [viewBottom setBackgroundColor:[UIColor whiteColor]];
    [viewBottom addSubview:[self addBorder:viewBottom]];
    netWidth = viewBottom.frame.size.width;
    startPointX = 0;
    netHeight = viewBottom.frame.size.height/buttonCount;//* 0.5f;
    [viewMain addSubview:viewBottom];
    globalPosY += viewBottom.frame.size.height;
    CGRect rectMain = viewMain.frame;
    rectMain.size.height = globalPosY;
    viewMain.frame = rectMain;
    [Utility showShadow:viewMain];
    
    if (/* DISABLES CODE */ (0)) {
        UILabel* labelTotalQuantityH = [[UILabel alloc] init];
        [labelTotalQuantityH setFrame:CGRectMake(startPointX + netWidth * .0f, 0, netWidth * .25f, netHeight)];
        [labelTotalQuantityH setUIFont:kUIFontType18 isBold:false];
        [labelTotalQuantityH setTextColor:[Utility getUIColor:kUIColorFontDark]];
        [labelTotalQuantityH setText:[NSString stringWithFormat:Localize(@"label_quantity")]];
        [viewBottom addSubview:labelTotalQuantityH];
        [labelTotalQuantityH setTextAlignment:NSTextAlignmentCenter];
        [labelTotalQuantityH.layer setBorderColor:[[Utility getUIColor:kUIColorBorder] CGColor]];
        [labelTotalQuantityH.layer setBorderWidth:1];
        UILabel* labelTotalQuantity = [[UILabel alloc] init];
        [labelTotalQuantity setFrame:CGRectMake(startPointX + netWidth * .25f, 0, netWidth * .25f, netHeight)];
        [labelTotalQuantity setUIFont:kUIFontType18 isBold:false];
        [labelTotalQuantity setTextColor:[Utility getUIColor:kUIColorFontDark]];
        [labelTotalQuantity setText:[NSString stringWithFormat:@"%d", order._total_line_items_quantity]];
        [viewBottom addSubview:labelTotalQuantity];
        [labelTotalQuantity setTextAlignment:NSTextAlignmentCenter];
        [labelTotalQuantity.layer setBorderColor:[[Utility getUIColor:kUIColorBorder] CGColor]];
        [labelTotalQuantity.layer setBorderWidth:1];
        UILabel* labelTotalPriceH = [[UILabel alloc] init];
        [labelTotalPriceH setFrame:CGRectMake(startPointX + netWidth * .5f, 0, netWidth * .25f, netHeight)];
        [labelTotalPriceH setUIFont:kUIFontType18 isBold:false];
        [labelTotalPriceH setTextColor:[Utility getUIColor:kUIColorFontDark]];
        [labelTotalPriceH setText:[NSString stringWithFormat:Localize(@"Total")]];
        [viewBottom addSubview:labelTotalPriceH];
        [labelTotalPriceH setTextAlignment:NSTextAlignmentCenter];
        [labelTotalPriceH.layer setBorderColor:[[Utility getUIColor:kUIColorBorder] CGColor]];
        [labelTotalPriceH.layer setBorderWidth:1];
        UILabel* labelTotalPrice = [[UILabel alloc] init];
        [labelTotalPrice setFrame:CGRectMake(startPointX + netWidth * .75f, 0, netWidth * .25f, netHeight)];
        [labelTotalPrice setUIFont:kUIFontType16 isBold:false];
        [labelTotalPrice setTextColor:[Utility getUIColor:kUIColorFontDark]];
        //    [labelTotalPrice setText:[NSString stringWithFormat:@"%@",[[Utility sharedManager] getCurrencyWithSign:[order._total floatValue] currencyCode:order._currency]]];
        [labelTotalPrice setText:[NSString stringWithFormat:@"%@",[[Utility sharedManager] getCurrencyWithSign:[order._total floatValue] currencyCode:order._currency symbolAtLast:isCurrencySymbolAtLast]]];
        [viewBottom addSubview:labelTotalPrice];
        [labelTotalPrice setTextAlignment:NSTextAlignmentCenter];
        [labelTotalPrice.layer setBorderColor:[[Utility getUIColor:kUIColorBorder] CGColor]];
        [labelTotalPrice.layer setBorderWidth:1];
    }
    UIButton *buttonCancelOrder = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, netWidth, netHeight)];
    [[buttonCancelOrder titleLabel] setUIFont:kUIFontType16 isBold:false];
    [buttonCancelOrder setTitle:Localize(@"i_cancel_order") forState:UIControlStateNormal];
    [buttonCancelOrder setTitleColor:[Utility getUIColor:kUIColorThemeFont] forState:UIControlStateNormal];
    [[buttonCancelOrder titleLabel] sizeToFitUI];
    [buttonCancelOrder setTitleColor:[Utility getUIColor:kUIColorFontLight] forState:UIControlStateDisabled];
    [buttonCancelOrder setContentMode:UIViewContentModeLeft];
    [viewBottom addSubview:buttonCancelOrder];
    [buttonCancelOrder addTarget:self action:@selector(cancelOrder:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *buttonTrackOrder = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(buttonCancelOrder.frame), netWidth, netHeight)];
    [[buttonTrackOrder titleLabel] setUIFont:kUIFontType18 isBold:false];
    [buttonTrackOrder setTitle:Localize(@"track_order") forState:UIControlStateNormal];
    [buttonTrackOrder setTitleColor:[Utility getUIColor:kUIColorThemeFont] forState:UIControlStateNormal];
    [buttonTrackOrder setTitleColor:[Utility getUIColor:kUIColorFontLight] forState:UIControlStateDisabled];
    [buttonTrackOrder setUIImage:[UIImage imageNamed:@"track-icon.png"] forState:UIControlStateNormal];
    [buttonTrackOrder setUIImage:[UIImage imageNamed:@"track-icon.png"] forState:UIControlStateSelected];
    [buttonTrackOrder setContentMode:UIViewContentModeScaleAspectFit];
    [[buttonTrackOrder imageView] setContentMode:UIViewContentModeScaleAspectFit];
    [buttonTrackOrder setImageEdgeInsets:UIEdgeInsetsMake(netHeight * .25f, 0, netHeight * .33f, 0)];
    [buttonTrackOrder setBackgroundColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
    [buttonTrackOrder setTitleColor:[Utility getUIColor:kUIColorBuyButtonFont] forState:UIControlStateNormal];
    if(isTrackButtonEnable){
        [viewBottom addSubview:buttonTrackOrder];
    }
    [buttonTrackOrder addTarget:self action:@selector(trackOrder:) forControlEvents:UIControlEventTouchUpInside];
    [buttonTrackOrder.layer setBorderColor:[[Utility getUIColor:kUIColorBorder] CGColor]];
    [buttonTrackOrder.layer setBorderWidth:1];
    buttonTrackOrder.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    buttonTrackOrder.titleLabel.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    buttonTrackOrder.imageView.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    
    [buttonTrackOrder.layer setValue:order forKey:@"MY_OBJECT"];
    //    [buttonTrackOrder.layer setValue:viewMain forKey:@"MY_VIEW"];
    //    [buttonTrackOrder.layer setValue:buttonCancelOrder forKey:@"ORDER_BUTTON_OBJECT"];
    //    [buttonTrackOrder.layer setValue:buttonTrackOrder forKey:@"TRACK_BUTTON_OBJECT"];
    
    [buttonCancelOrder.layer setValue:order forKey:@"MY_OBJECT"];
    [buttonCancelOrder.layer setValue:viewMain forKey:@"MY_VIEW"];
    [buttonCancelOrder.layer setValue:buttonCancelOrder forKey:@"ORDER_BUTTON_OBJECT"];
    [buttonCancelOrder.layer setValue:buttonTrackOrder forKey:@"TRACK_BUTTON_OBJECT"];
    
    
    
    if([order._status isEqualToString:@"failed"] ||
       [order._status isEqualToString:@"pending"]
       ){
        [buttonCancelOrder setEnabled:true];
        [buttonTrackOrder setEnabled:true];
    } else {
        BOOL isOrderAgainButtonEnable = [[Addons sharedManager] order_again];
        NSString* orderStatusStr = @"";
        if([order._status isEqualToString:@"completed"]) {
            orderStatusStr = Localize(@"completed");
        }
        else if([order._status isEqualToString:@"cancelled"]) {
            orderStatusStr = Localize(@"cancelled");
        }
        else if([order._status isEqualToString:@"refunded"]) {
            orderStatusStr = Localize(@"refunded");
        }
        else if([order._status isEqualToString:@"failed"]) {
            orderStatusStr = Localize(@"failed");
        }
        else if([order._status isEqualToString:@"processing"]) {
            orderStatusStr = Localize(@"processing");
        }
        else if([order._status isEqualToString:@"pending"]) {
            orderStatusStr = Localize(@"pending");
        }
        else if([order._status isEqualToString:@"on-hold"]) {
            orderStatusStr = Localize(@"onhold");
        }
        if (([order._status isEqualToString:@"completed"] && isOrderAgainButtonEnable)) {
            NSString* text = [NSString stringWithFormat:Localize(@"i_order_val"), orderStatusStr];
            text = [NSString stringWithFormat:@"%@ %@", text, Localize(@"order_again")];
            [buttonCancelOrder setTitle:text forState:UIControlStateNormal];
            //            CGRect rect = CGRectMake(0, 0, netWidth, netHeight);
            //            buttonCancelOrder.frame = rect;
            [buttonCancelOrder setEnabled:true];
            [buttonCancelOrder setBackgroundColor:[Utility getUIColor:kUIColorBuyButtonNormalBg]];
            [buttonCancelOrder setTitleColor:[Utility getUIColor:kUIColorBuyButtonFont] forState:UIControlStateNormal];
            [buttonCancelOrder removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
            [buttonCancelOrder addTarget:self action:@selector(reOrder:) forControlEvents:UIControlEventTouchUpInside];
            [buttonCancelOrder.layer setValue:order forKey:@"ORDER_OBJ"];
        } else {
            [buttonCancelOrder setTitle:[NSString stringWithFormat:Localize(@"i_order_val"), orderStatusStr] forState:UIControlStateDisabled];
            //            CGRect rect = CGRectMake(0, 0, netWidth, netHeight);
            //            buttonCancelOrder.frame = rect;
            [buttonCancelOrder setEnabled:false];
            if (isTrackButtonEnable) {
                [buttonTrackOrder setEnabled:true];
                [buttonTrackOrder setHidden:false];
            } else {
                [buttonTrackOrder setHidden:true];
            }
        }
    }
    return viewMain;
}
#endif
#pragma mark Others
- (void)cancelOrder:(UIButton*)sender {
    RLOG(@"cancel order....");
    _selectedButtonCancelOrder = sender;
    _alertViewCancelOrder = [[UIAlertView alloc] initWithTitle:Localize(@"cancel_order") message:Localize(@"i_order_cancel_permission") delegate:self cancelButtonTitle:Localize(@"btn_yes") otherButtonTitles:Localize(@"btn_no"), nil];
    [_alertViewCancelOrder show];
}
- (void)reOrder:(UIButton*)sender {
    RLOG(@"re order....");
    [Utility showProgressView:Localize(@"please_wait")];
    //    UIActivityIndicatorView* ai = [[Utility sharedManager] startGrayLoadingBar:true];
    //    ai.center = self.view.center;
    Order* order = [sender.layer valueForKey:@"ORDER_OBJ"];
    NSMutableArray* pids = [[NSMutableArray alloc] init];
    for (LineItem* lineItem in order._line_items) {
        int pId = lineItem._product_id;
        [pids addObject:[NSString stringWithFormat:@"%d", pId]];
    }
    if ([pids count] > 0) {
        [[[DataManager sharedManager] tmDataDoctor] fetchProductsFullDataFromPlugin:pids success:^(id data) {
            if (data) {
                for (LineItem* lineItem in order._line_items) {
                    int pId = lineItem._product_id;
                    int qty = lineItem._quantity;
                    ProductInfo* prod = (ProductInfo*)[data objectForKey:[NSString stringWithFormat:@"%d", pId]];
                    if (prod._type == PRODUCT_TYPE_VARIABLE) {
                        NSMutableArray* selectedVariationAttibutes = [[NSMutableArray alloc] init];
                        for (Attribute* attribute in prod._attributes) {
                            [selectedVariationAttibutes addObject:[attribute getVariationAttribute:0]];
                        }
                        
                        for (ProductMetaItemProperties* mp in lineItem._meta) {
                            NSString* vL = mp._value;
                            NSString* vK = mp._key;
                            for (VariationAttribute* va in selectedVariationAttibutes) {
                                if ([Utility compareAttributeNames:va.name name2:vK]) {
                                    va.value = vL;
                                }
                            }
                        }
                        
                        Variation* selectedVariation = [prod._variations getVariationFromAttibutes:selectedVariationAttibutes];
                        
                        if (selectedVariation) {
                            Cart* c = [Cart addProduct:prod variationId:selectedVariation._id variationIndex:-1 selectedVariationAttributes:selectedVariationAttibutes];
                            c.count += (qty-1);
                        } else {
                            Cart* c = [Cart addProduct:prod variationId:-1 variationIndex:-1 selectedVariationAttributes:nil];
                            c.count += (qty-1);
                        }
                    }
                    else {
                        Cart* c = [Cart addProduct:prod variationId:-1 variationIndex:-1 selectedVariationAttributes:nil];
                        c.count += (qty-1);
                    }
                }
            }
            [Utility hideProgressView];
            ViewControllerMain* mainVC = [ViewControllerMain getInstance];
            [mainVC btnClickedCart:self];
        } failure:^{
            [Utility hideProgressView];
        }];
    }
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    //Checks For Approval
    if (alertView == _alertViewCancelOrder) {
        if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:Localize(@"btn_yes")]) {
            Order* order = [_selectedButtonCancelOrder.layer valueForKey:@"MY_OBJECT"];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateOrderSuccess:) name:@"UPDATE_ORDER_SUCCESS" object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateOrderFailed:) name:@"UPDATE_ORDER_FAILURE" object:nil];
            [[[DataManager sharedManager] tmDataDoctor] updateOrder:nil orderId:order._id orderStatus:@"cancelled" isPaid:false];
        } else {
            _selectedButtonCancelOrder = nil;
        }
    }
}
- (void)updateOrderSuccess:(NSNotification*)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UPDATE_ORDER_SUCCESS" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UPDATE_ORDER_FAILURE" object:nil];
    RLOG(@"updateOrderSuccess");
    
    
    Order* order = [_selectedButtonCancelOrder.layer valueForKey:@"MY_OBJECT"];
    UIView* mainView = [_selectedButtonCancelOrder.layer valueForKey:@"MY_VIEW"];
    UIView* view = [self createOrderSummery:0 order:order viewMain:mainView];
    mainView.layer.shadowOpacity = 0.0f;
    [Utility showShadow:mainView];
    [self resetMainScrollView];
    
    //    order._status = @"cancelled";
    
    //    UIButton* buttonCancelOrder = [_selectedButtonCancelOrder.layer valueForKey:@"ORDER_BUTTON_OBJECT"];
    //    UIButton* buttonTrackOrder = [_selectedButtonCancelOrder.layer valueForKey:@"TRACK_BUTTON_OBJECT"];
    //
    //    if([order._status isEqualToString:@"processing"] ||
    //       [order._status isEqualToString:@"on-hold"] ||
    //       [order._status isEqualToString:@"pending"]
    //       ){
    //        [buttonCancelOrder setEnabled:true];
    //        [buttonTrackOrder setEnabled:true];
    //    } else {
    //        [buttonCancelOrder setTitle:[NSString stringWithFormat:@"Order %@",[order._status capitalizedString]] forState:UIControlStateDisabled];
    //
    //        CGRect rect = CGRectMake(0, 0, self.view.frame.size.width * .96f, 50);
    //        buttonCancelOrder.frame = rect;
    //        [buttonCancelOrder setEnabled:false];
    //        [buttonTrackOrder setHidden:true];
    //    }
    
    AppUser* appUser = [AppUser sharedManager];
    [appUser saveData];
    
    _selectedButtonCancelOrder = nil;
}
- (void)updateOrderFailed:(NSNotification*)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UPDATE_ORDER_SUCCESS"   object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UPDATE_ORDER_FAILURE"   object:nil];
    RLOG(@"updateOrderFailed");
    _selectedButtonCancelOrder = nil;
}
- (UIView*)addView:(LineItem*)lineItem currencyCode:(NSString*)currencyCode isCurrencySymbolAtLast:(BOOL)isCurrencySymbolAtLast {
    NSString *productImgUrl = [LineItem getImgUrlOnProductId:lineItem._product_id];
    int productQuantity = lineItem._quantity;
    float productTotalPrice = lineItem._subtotal;
    NSString *productName = lineItem._name;
    NSMutableArray* productProperties = lineItem._meta;
    
    float fontHeight = 20;
    float padding = self.view.frame.size.width * 0.05f;
    float height = 0;
    float viewMaxWidth = self.view.frame.size.width * 0.96f;
    CGRect rect;
    
    UILabel* labelName = [[UILabel alloc] init];
    [labelName setFrame:CGRectMake(0, height, viewMaxWidth, labelName.frame.size.height)];
    [labelName setUIFont:kUIFontType18 isBold:false];
    [labelName setTextColor:[Utility getUIColor:kUIColorFontLight]];
    //    [labelName setText:productName];
    [labelName setText:[Utility getNormalStringFromAttributed:productName]];
    [labelName sizeToFitUI];
    [labelName setNumberOfLines:0];
    height += labelName.frame.size.height;
    rect = labelName.frame;
    rect.origin.x = padding;
    [labelName setFrame:rect];
    
    /////////////
    
    NSMutableString *properties = [NSMutableString string];
    int i = 0;
    for (ProductMetaItemProperties* pmip in productProperties) {
        if (i > 0) {
            NSString* str = [NSString stringWithFormat:@",\n"];
            [properties appendString:str];
        }
        NSString* str = [NSString stringWithFormat:@"%@ - %@", pmip._label , pmip._value ];
        [properties appendString:str];
        i++;
    }
    if ([properties isEqualToString:@""]){
        [properties appendString:Localize(@"not_available")];
    }
    
    UILabel* labelProp = [[UILabel alloc] init];
    [labelProp setFrame:CGRectMake(0, height, viewMaxWidth, labelProp.frame.size.height)];
    [labelProp setUIFont:kUIFontType14 isBold:false];
    [labelProp setTextColor:[Utility getUIColor:kUIColorFontLight]];
    [labelProp setText:properties];
    [labelProp sizeToFitUI];
    [labelProp setNumberOfLines:0];
    height += labelProp.frame.size.height;
    rect = labelProp.frame;
    rect.origin.x = padding;
    [labelProp setFrame:rect];
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        [labelProp setTextAlignment:NSTextAlignmentRight];
    } else {
        [labelProp setTextAlignment:NSTextAlignmentLeft];
    }
    
    //////////////
    UILabel* labelQuantity = [[UILabel alloc] init];
    [labelQuantity setFrame:CGRectMake(0, height, viewMaxWidth, fontHeight)];
    [labelQuantity setUIFont:kUIFontType16 isBold:false];
    [labelQuantity setTextColor:[Utility getUIColor:kUIColorFontLight]];
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        [labelQuantity setText:[NSString stringWithFormat:@"%d :%@", productQuantity, Localize(@"label_quantity")]];
    } else {
        [labelQuantity setText:[NSString stringWithFormat:@"%@: %d", Localize(@"label_quantity"),productQuantity]];
    }
    [labelQuantity sizeToFitUI];
    [labelQuantity setNumberOfLines:0];
    rect = labelQuantity.frame;
    rect.origin.x = padding;
    [labelQuantity setFrame:rect];
    
    ///////////
    
    ///////////
    UILabel* labelPrice = [[UILabel alloc] init];
    [labelPrice setFrame:CGRectMake(0, height, viewMaxWidth, fontHeight)];
    [labelPrice setUIFont:kUIFontType16 isBold:false];
    [labelPrice setTextColor:[Utility getUIColor:kUIColorFontLight]];
    float price = productTotalPrice;
    //    NSString *priceStr = [[Utility sharedManager] convertToString:price isCurrency:true symbolAtLast:true];
    [labelPrice setText:[NSString stringWithFormat:@"%@",[[Utility sharedManager] getCurrencyWithSign:price currencyCode:currencyCode symbolAtLast:isCurrencySymbolAtLast]]];
    
    //    [labelPrice setText:[NSString stringWithFormat:@"%@", priceStr]];
    [labelPrice sizeToFitUI];
    [labelPrice setNumberOfLines:0];
    if ([[TMLanguage sharedManager] isRTLEnabled]) {
        [labelPrice setTextAlignment:NSTextAlignmentLeft];
    } else {
        [labelPrice setTextAlignment:NSTextAlignmentRight];
    }
    rect = labelPrice.frame;
    rect.origin.x = viewMaxWidth - CGRectGetMaxX(labelPrice.frame) - padding;
    [labelPrice setFrame:rect];
    height += labelPrice.frame.size.height;
    
    
    UIView* mainView = [[UIView alloc] init];
    [mainView setBackgroundColor:[UIColor whiteColor]];
    [mainView setFrame:CGRectMake(self.view.frame.size.width * 0.02f, 0, viewMaxWidth, height + fontHeight)];
    [mainView addSubview:labelName];
    if (labelProp) {
        [mainView addSubview:labelProp];
    }
    [mainView addSubview:labelQuantity];
    [mainView addSubview:labelPrice];
    //    [mainView addSubview:labelPriceHeading];
    [mainView setTag:kTagForNoSpacing];
    CGRect temp = mainView.frame;
    temp.size.height = mainView.frame.size.height * 2;
    mainView.frame = temp;
    UIImageView* imgProduct = [[UIImageView alloc] init];
    imgProduct.frame = CGRectMake(self.view.frame.size.width * 0.02f, self.view.frame.size.width * 0.02f, mainView.frame.size.height - self.view.frame.size.width * 0.04f, mainView.frame.size.height - self.view.frame.size.width * 0.04f);
    [mainView addSubview:imgProduct];
    if (productImgUrl) {
        [Utility setImage:imgProduct url:productImgUrl resizeType:kRESIZE_TYPE_PRODUCT_THUMBNAIL isLocal:false];
    } else {
        
    }
    
    
    [imgProduct.layer setBorderColor:[[Utility getUIColor:kUIColorBorder] CGColor]];
    [imgProduct.layer setBorderWidth:1];
    [imgProduct setContentMode:UIViewContentModeScaleAspectFill];
    [imgProduct setClipsToBounds:true];
    
    temp = labelName.frame;
    temp.origin.x = CGRectGetMaxX(imgProduct.frame) + self.view.frame.size.width * 0.02f;
    temp.origin.y = self.view.frame.size.width * 0.02f + self.view.frame.size.width * 0.02f;
    temp.size.width = viewMaxWidth - temp.origin.x - self.view.frame.size.width * 0.02f;
    labelName.frame = temp;
    
    temp = labelProp.frame;
    temp.origin.x = CGRectGetMaxX(imgProduct.frame) + self.view.frame.size.width * 0.02f;
    temp.origin.y = CGRectGetMaxY(labelName.frame) + self.view.frame.size.width * 0.02f;
    temp.size.width = viewMaxWidth - temp.origin.x - self.view.frame.size.width * 0.02f;
    
    //    self.view.frame.size.width * 0.96f - temp.origin.x;
    labelProp.frame = temp;
    [labelProp setNumberOfLines:0];
    labelProp.lineBreakMode = NSLineBreakByWordWrapping;
    [labelProp sizeToFitUI];
    //    labelProp.frame = temp;
    
    temp = labelQuantity.frame;
    temp.origin.x = CGRectGetMaxX(imgProduct.frame) + self.view.frame.size.width * 0.02f;
    temp.origin.y = CGRectGetMaxY(labelProp.frame) + self.view.frame.size.width * 0.02f;
    labelQuantity.frame = temp;
    
    temp = labelPrice.frame;
    temp.origin.x = mainView.frame.size.width - self.view.frame.size.width * 0.02f - labelPrice.frame.size.width;
    temp.origin.y = CGRectGetMaxY(labelProp.frame) + self.view.frame.size.width * 0.02f;
    labelPrice.frame = temp;
    
    //    temp = labelPrice.frame;
    //    temp.origin.x = mainView.frame.size.width - self.view.frame.size.width * 0.02f - labelPrice.frame.size.width;
    //    temp.origin.y = mainView.frame.size.height * 0.5f - temp.size.height * 0.5f;
    //    labelPriceHeading.frame = temp;
    
    CGRect newRect = mainView.frame;
    newRect.size.height = MAX(CGRectGetMaxY(imgProduct.frame) + self.view.frame.size.width * 0.02f, CGRectGetMaxY(labelPrice.frame) + self.view.frame.size.width * 0.02f);
    mainView.frame = newRect;
    
    
    
    return mainView;
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
    [self beforeRotation];
}
- (void)adjustViewsAfterOrientation:(UIDeviceOrientation) orientation {
    RLOG(@"%s", __PRETTY_FUNCTION__);
    RLOG(@"====adjustViewsAfterOrientation====");
    [self afterRotation];
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    if ([[AppDelegate getInstance] isAppEnteredInBackground]) {
        return;
    }
    [self adjustViewsAfterOrientation:[[UIDevice currentDevice] orientation]];
    [self resetMainScrollView];
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if ([[AppDelegate getInstance] isAppEnteredInBackground]) {
        return;
    }
    [self adjustViewsForOrientation:[[UIDevice currentDevice] orientation]];
    [self resetMainScrollView];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (_isNewOrdersLoading == false) {
        _isNewOrdersLoading = true;
        RLOG(@"scrollViewDidEndDecelerating");
        [self startLoadingAnim];
        [self loadMoreOrders:moreLoadOrdersCount];
    }
}
- (void)loadMoreOrders:(int)moreCount {
    _isNewOrdersLoading = true;
    AppUser* appUser = [AppUser sharedManager];
    int i = _loadedOrdersCount;
    int iMax = _loadedOrdersCount+moreCount;
    //    float globalPosY = _scrollView.contentSize.height;
    //    float globalPosYOriginal = _scrollView.contentSize.height;
    for (; i < iMax; i++) {
        if ([appUser._ordersArray count] > i) {
            _loadedOrdersCount++;
            Order* order = (Order*)[appUser._ordersArray objectAtIndex:i];
            BOOL isOrderNeedToDisplay = true;
            if ([order._status isEqualToString:@"cancelled"]) {
                _cancelledOrderCount++;
                if (_cancelledOrderCount >= 5) {
                    //                    isOrderNeedToDisplay = false;//todo ask
                }
            }
            else if ([order._status isEqualToString:@"pending"]) {
//                isOrderNeedToDisplay = false;//todo ask
            }
            
            if (isOrderNeedToDisplay) {
                float globalPosY = _scrollView.contentSize.height;
                UIView* tempView = [self createOrderSummery:0 order:order viewMain:nil];
                CGRect rect = tempView.frame;
                rect.origin.y = globalPosY;
                [tempView setFrame:rect];
                globalPosY += rect.size.height;
                if ([tempView tag] == kTagForGlobalSpacing) {
                    globalPosY += [LayoutProperties globalVerticalMargin];
                }
                tempView.hidden = false;
                [_scrollView setContentSize:CGSizeMake(_scrollView.contentSize.width, globalPosY)];
            }
        }else{
            break;
        }
    }
    //    if (globalPosYOriginal != globalPosY) {
    //        [_scrollView setContentSize:CGSizeMake(_scrollView.contentSize.width, globalPosY)];
    //    }
    
    [self performSelector:@selector(doSomething) withObject:nil afterDelay:0.0f];
}
- (void)doSomething {
    [self stopLoadingAnim];
    _isNewOrdersLoading = false;
    
    AppUser* appUser = [AppUser sharedManager];
    if (_loadedOrdersCount < [appUser._ordersArray count]) {
        [self scrollViewDidEndDecelerating:nil];
    }
}
- (void)startLoadingAnim {
    return;
    if (_spinnerView == nil) {
        _spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [_spinnerView setFrame:CGRectMake(0, 0, _spinnerView.frame.size.width, _spinnerView.frame.size.height)];
        [_scrollView addSubview:_spinnerView];
    }
    [_spinnerView setCenter:CGPointMake(self.view.frame.size.width/2, [_scrollView contentSize].height - _spinnerView.frame.size.height)];
    [_spinnerView startAnimating];
}
- (void)stopLoadingAnim {
    return;
    if (_spinnerView) {
        [_spinnerView stopAnimating];
    }
}

- (void)trackOrder:(UIButton*)button {
    Order* order = (Order*)[button.layer valueForKey:@"MY_OBJECT"];
    if([[Addons sharedManager] enable_shipment_tracking]) {
        Addons* addons = [Addons sharedManager];
        AfterShipConfig* config = addons.afterShipConfig;
        if(config != nil) {
            if (order.shipmentTrackingId && ![order.shipmentTrackingId isEqualToString:@""]) {
                [self showTrackAlert:order];
            } else {
                [Utility showProgressView:Localize(@"please_wait")];
                [[DataManager getDataDoctor] getShipmentTrackingId:@"aftership" orderId:[order _id] success:^(id data) {
                    [Utility hideProgressView];
                    @try {
                        if (data) {
                            if (IS_NOT_NULL(data, @"tracking_id")) {
                                NSString* tracking_id = [data valueForKey:@"tracking_id"];
                                order.shipmentTrackingId = tracking_id;
                            }
                            
                            if (IS_NOT_NULL(data, @"provider")) {
                                NSString* provider = [data valueForKey:@"provider"];
                                order.shipmentProvider = provider;
                            }
                            
                            if (IS_NOT_NULL(data, @"tracking_url")) {
                                NSString* tracking_url = [data valueForKey:@"tracking_url"];
                                order.shipmentUrl = tracking_url;
                            }
                            [self showTrackAlert:order];
                        } else {
                            [Utility showToast:Localize(@"shipment_tracking_id_unavailable")];
                        }
                    } @catch (NSException *exception) {
                        [Utility showToast:Localize(@"shipment_tracking_id_error")];
                    }
                } failure:^(NSString *error) {
                    [Utility hideProgressView];
                    [Utility showToast:Localize(@"shipment_tracking_id_error")];
                }];
            }
        }
    }
}
- (void)showTrackAlert:(Order*)order {
    if(order.shipmentTrackingId != nil && ![order.shipmentTrackingId isEqualToString:@""]) {
        if (order.shipmentUrl && ![order.shipmentUrl isEqualToString:@""]) {
            UITextView *alertTextView = [[UITextView alloc] init];
            NSString* strTrackId = [NSString stringWithFormat:Localize(@"tracking_id"), order.shipmentTrackingId];

            NSString* strTrackProvider = [NSString stringWithFormat:Localize(@"tracking_provider"), order.shipmentProvider];
            NSString* strTrackURL = order.shipmentUrl;
            alertTextView.text = [NSString stringWithFormat:@"%@\n%@\n\n%@\n", strTrackId, strTrackProvider, strTrackURL];
            alertTextView.textAlignment = NSTextAlignmentCenter;
            alertTextView.font = [Utility getUIFont:kUIFontType14 isBold:false];
            alertTextView.delegate = self;
            // enable links data inside textview and customize textview
            alertTextView.dataDetectorTypes = UIDataDetectorTypeAll;
            alertTextView.scrollEnabled = true;
            //alertTextView.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0];
            alertTextView.editable = false;
            [alertTextView sizeToFit];
            // create UIAlertView
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:Localize(@"track_order") message:@"" delegate:self cancelButtonTitle:Localize(@"i_cok") otherButtonTitles:nil];
            [alert setValue:alertTextView forKey:@"accessoryView"];
            alertTextView.frame = CGRectMake(0, 0, alertTextView.contentSize.width, alertTextView.contentSize.height);
            [alert show];
            
            _trackAlertView = alert;
            _trackAlertTextView = alertTextView;
            [_trackAlertTextView.layer setValue:order.shipmentTrackingId forKey:@"TRACK_ID"];
        }
        else {
            NSString* strTrackId = [NSString stringWithFormat:Localize(@"tracking_id"), order.shipmentTrackingId];
            NSString* strTrackProvider = [NSString stringWithFormat:Localize(@"tracking_provider"), order.shipmentProvider];
            UIAlertView* alertView = [[UIAlertView alloc]
                                      initWithTitle:Localize(@"track_order") message:[NSString stringWithFormat:@"%@\n%@", strTrackId, strTrackProvider] delegate:self cancelButtonTitle:Localize(@"i_ok") otherButtonTitles: nil];
            [alertView show];
        }
    }
    else {
        [Utility showToast:Localize(@"shipment_tracking_id_unavailable")];
    }
}
- (void) trackOrderWithUrl:(NSString*) url {
    [Utility showToast:@"Open WebView for tracking shipment order"];
}

- (void)loadOrderRewardPoints {
    if(![[Addons sharedManager] enable_custom_points]) {
        [self loadOrderDateTimeSlot];
        return;
    }
    
    AppUser* appUser = [AppUser sharedManager];
    NSMutableString* str = [[NSMutableString alloc] init];
    NSArray* orders = appUser._ordersArray;
    int i = 0;
    for (Order* order in orders) {
        [str appendFormat:@"%d", order._id];
        if (i < orders.count - 1) {
            [str appendString:@","];
        }
        i++;
    }
    
    NSString* orderIds = [NSString stringWithFormat:@"[%@]", str];
    
    if ([orderIds isEqualToString:@"[]"]) {
        return;
    }
    NSDictionary* parameters = @{ @"type": base64_str(@"order_reward_points"),
                                  @"user_id": base64_int([[AppUser sharedManager] _id]),
                                  @"email_id": base64_str([[AppUser sharedManager] _email]),
                                  @"order_ids" : base64_str(orderIds)};
    [Utility showProgressView:Localize(@"please_wait")];
    [[DataManager getDataDoctor] getOrderRewardPoints:parameters
                                              success:^(id data) {
                                                  //TODO In youur orders list add text for earned and redeemed points and refresh
                                                  RLOG(@"Order reward points fetched successfully.");
                                                  [Utility hideProgressView];
                                                  _loadedOrdersCount = 0;
                                                  [self loadAllViews];
                                                  [self loadOrderDateTimeSlot];
                                              }
                                              failure:^(NSString *error) {
                                                  RLOG(@"Failed to get order reward points.");
                                                  [Utility hideProgressView];
                                                  [self loadOrderDateTimeSlot];
                                              }];
}
- (void)loadOrderDateTimeSlot {
    Addons* addons = [Addons sharedManager];
    BOOL showDateSlot = (addons.deliverySlotsCopiaPlugin && addons.deliverySlotsCopiaPlugin.isEnabled) ? true : false ;
    BOOL showTimeSlot = showDateSlot ? true : (addons.localPickupTimeSelectPlugin && addons.localPickupTimeSelectPlugin.isEnabled) ? true : false ;
    if (showTimeSlot == false && showDateSlot == false) {
        [self loadOrderWCCMData];
        return;
    }
    
    AppUser* appUser = [AppUser sharedManager];
    NSMutableString* str = [[NSMutableString alloc] init];
    NSArray* orders = appUser._ordersArray;
    int i = 0;
    for (Order* order in orders) {
        [str appendFormat:@"%d", order._id];
        if (i < orders.count - 1) {
            [str appendString:@","];
        }
        i++;
    }
    
    NSString* orderIds = [NSString stringWithFormat:@"[%@]", str];
    NSDictionary* parameters = @{ @"type": base64_str(@"ordered_slot"),
                                  @"order_ids" : base64_str(orderIds)
                                  };
//    [Utility showProgressView:Localize(@"please_wait")];
    
    if (showDateSlot) {
        [[DataManager getDataDoctor] getOrderDeliverySlots:parameters
                                                   success:^(id data) {
                                                       RLOG(@"Order delivery slots fetched successfully.");
                                                       [Utility hideProgressView];
                                                       _loadedOrdersCount = 0;
                                                       [self loadAllViews];
                                                       [self loadOrderWCCMData];
                                                   }
                                                   failure:^(NSString *error) {
                                                       RLOG(@"Failed to get order delivery slots.");
//                                                       [Utility hideProgressView];
                                                       if ([error isEqualToString:@"retry"]) {
                                                           [self loadOrderDateTimeSlot];
                                                       } else {
                                                           [self loadOrderWCCMData];
                                                       }
                                                   }];
    }
    else if (showTimeSlot) {
        [[DataManager getDataDoctor] getOrderTimeSlots:parameters
                                                   success:^(id data) {
                                                       RLOG(@"Order time slots fetched successfully.");
                                                       [Utility hideProgressView];
                                                       _loadedOrdersCount = 0;
                                                       [self loadAllViews];
                                                       [self loadOrderWCCMData];
                                                   }
                                                   failure:^(NSString *error) {
                                                       RLOG(@"Failed to get order time slots.");
//                                                       [Utility hideProgressView];
                                                       if ([error isEqualToString:@"retry"]) {
                                                           [self loadOrderDateTimeSlot];
                                                       } else {
                                                           [self loadOrderWCCMData];
                                                       }
                                                   }];
    }
    else {
        [self loadOrderWCCMData];
    }
}
-(void) updateOrderRewardPoints:(Order*)order {
    if(![[Addons sharedManager] enable_custom_points]) {
        return;
    }
    
    AppUser* appUser = [AppUser sharedManager];
    
    NSString* orderIds = [NSString stringWithFormat:@"[%d]", order._id];
    
    //TODO calculate order reward points discount here
    
    //int pointsRedeemed = (int) (Cart.getPointsPriceDiscount() / AppUser.getRewardDiscount());
    int pointsRedeemed =  0; //(int) (Cart.getPointsPriceDiscount());
    
    NSDictionary* parameters = @{ @"type": base64_str(@"update_order_points"),
                                  @"user_id": base64_int([appUser _id]),
                                  @"email_id": base64_str([appUser _email]),
                                  @"order_ids" : base64_str(orderIds),
                                  @"points_redeemed": base64_int(pointsRedeemed)};
    
    [[DataManager getDataDoctor] updateOrderRewardPoints:parameters
                                                 success:^(id data) {
                                                     RLOG(@"Order reward points updated successfully.");
                                                     
                                                 }
                                                 failure:^(NSString *error) {
                                                     RLOG(@"Failed to update order reward points.");
                                                 }];
}
-(BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange{
    if (_trackAlertTextView == textView) {
        //Do something with the URL
        NSString* trackId = [_trackAlertTextView.layer valueForKey:@"TRACK_ID"];
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = trackId;
        NSLog(@"%@", URL);
        if (_trackAlertView) {
            [_trackAlertView dismissWithClickedButtonIndex:0 animated:YES];
            _trackAlertView = nil;
        }
        _trackAlertTextView = nil;
        ViewControllerMain* mainVC = [ViewControllerMain getInstance];
        ViewControllerWebview* vcWebview = (ViewControllerWebview*)[[Utility sharedManager] pushScreenWithNewAnimation:mainVC.vcCenterTop type:PUSH_SCREEN_TYPE_WEBVIEW];
        [vcWebview loadAllViews:URL.absoluteString];
        [vcWebview.view setTag:PUSH_SCREEN_TYPE_BRAND];
        return NO;
    }
    return YES;
}
- (void)loadOrderWCCMData {
    if ([[Addons sharedManager] enable_multi_store_checkout]) {
        AppUser* appUser = [AppUser sharedManager];
        NSMutableArray* orderIDs = [[NSMutableArray alloc] init];
        for (Order* obj in appUser._ordersArray) {
            [orderIDs addObject:[NSString stringWithFormat:@"%d", obj._id]];
        }
        if ([orderIDs count] > 0) {
            [[[DataManager sharedManager] tmDataDoctor] getWCCMDataForOrders:orderIDs success:^(id data) {
                RLOG(@"");
                [Utility hideProgressView];
                _loadedOrdersCount = 0;
                [self loadAllViews];
            } failure:^(NSString *error) {
                RLOG(@"");
                if ([error isEqualToString:@"retry"]) {
                    [self loadOrderWCCMData];
                } else {
                }
            }];
        }
    }
}
@end
