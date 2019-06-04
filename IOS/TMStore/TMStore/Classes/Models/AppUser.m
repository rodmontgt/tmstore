//
//  AppUser.m
//  eCommerceApp
//
//  Created by Rishabh Jain on 01/10/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import "AppUser.h"
#import "Cart.h"
#import "Wishlist.h"
#import "Opinion.h"
#import "Variables.h"
#import "CustomerData.h"
#import "LoginFlow.h"
#import "CartMeta.h"
#import "CommonInfo.h"
#import "Country.h"
#import "CustomMenu.h"
#import "CWishList.h"
#import "FeeData.h"
#import "TimeSlot.h"
#import "TM_CheckoutAddon.h"
#import "TM_Tax.h"
#import "Vendor.h"
#import "WaitList.h"
#import "ContactForm3Config.h"
#import "ReservationFormConfig.h"
#import "TM_ProductFilter.h"
#import "ViewControllerSplashPrimary.h"

@implementation AppUser
static AppUser * _mAppUser = nil;
BOOL _SAVE_OFFLINE_DATA = false;
BOOL _USE_OFFLINE_MODE = false;
static AppUser *sharedAppManager = nil;
+ (void)clearFullAppData {
    AppUser* appUserObj = [AppUser sharedManager];
    [appUserObj clearData];
    [appUserObj clearSelectedData];

    
    //remove all banners
    [[Banner getAllBanners] removeAllObjects];
    
    //remove applied coupons
    [[[CartMeta sharedInstance] getAppliedCoupons] removeAllObjects];
    
    //remove tmcountry and tmstate
    if ([[TMCountry getAllCountries] count] > 0) {
        for (TMCountry* country in [TMCountry getAllCountries]) {
            if(country && country.countryStates && [country.countryStates count] > 0) {
                [country.countryStates removeAllObjects];
            }
        }
    }
    [[TMCountry getAllCountries] removeAllObjects];
    
    //remove custom menu items
    CustomMenu* cm = [CustomMenu sharedManager];
    if (cm.items) {
        [cm.items removeAllObjects];
    }
    
    //remove cwishlist items
    [CWishList clearAll];
    
    //remove date time slots
    NSMutableArray* allDateTimeSlots = [DateTimeSlot getAllDateTimeSlots];
    if ([allDateTimeSlots count] > 0) {
        for (DateTimeSlot* dtSlot in allDateTimeSlots) {
            if(dtSlot && [dtSlot getTimeSlot] && [[dtSlot getTimeSlot] count] > 0) {
                [[dtSlot getTimeSlot] removeAllObjects];
            }
        }
    }
    [allDateTimeSlots removeAllObjects];
    
    //remove all feedata
    [[FeeData getAllFeeData] removeAllObjects];
    
    //remove all timeslots
    [[TimeSlot getAllTimeSlots] removeAllObjects];
    
    //remove TM_CheckoutAddon
    [[TM_CheckoutAddon getAllCheckoutAddons] removeAllObjects];
    [[TM_CheckoutAddon getSelectedCheckoutAddons] removeAllObjects];
    [TM_CheckoutAddon setOrderScreenNote:@""];
    
    
    //remove all taxes
    [[TM_Tax getAllTaxes] removeAllObjects];
    [[TM_TaxApplied getAllTaxesApplied] removeAllObjects];
    
    //remove all addons
    [Addons resetManager];
    [Language resetInstance];
    [GuestConfig resetInstance];
    [ExcludedAddress resetInstance];
    [ProductDetailsConfig resetInstance];
    
    
    //reset language preference
    [[TMLanguage sharedManager] resetAllData];
    
    //remove all vendors
    [[Vendor getAllVendors] removeAllObjects];
    
    //remove contactform3 config
    [ContactForm3Config resetInstance];
    
    //remove reservationform config
    [ReservationFormConfig resetInstance];
    
    //remove all filters
    [[TM_ProductFilter getAll] removeAllObjects];
    [TM_ProductFilter resetAttributeLoaded];
    
    
    //reset custominfo manager
    [CommonInfo resetManager];
    
    //reset datamanager
    [DataManager resetManager];
    
    //reset parsehelper
    [ParseHelper resetManager];
    //remove appuser
    [AppUser deleteInstance];
    
    
}
+ (void)clearFullAppData:(BOOL)deleteAppUserData {
    AppUser* appUserObj = [AppUser sharedManager];
    if (deleteAppUserData) {
        [appUserObj clearData];
//        [appUserObj clearSelectedData];
    }
    [appUserObj clearSelectedData];
    
    //remove all banners
    [[Banner getAllBanners] removeAllObjects];
    
    //remove applied coupons
    [[[CartMeta sharedInstance] getAppliedCoupons] removeAllObjects];
    
    //remove tmcountry and tmstate
    if ([[TMCountry getAllCountries] count] > 0) {
        for (TMCountry* country in [TMCountry getAllCountries]) {
            if(country && country.countryStates && [country.countryStates count] > 0) {
                [country.countryStates removeAllObjects];
            }
        }
    }
    [[TMCountry getAllCountries] removeAllObjects];
    
    //remove custom menu items
    CustomMenu* cm = [CustomMenu sharedManager];
    if (cm.items) {
        [cm.items removeAllObjects];
    }
    
    //remove cwishlist items
    [CWishList clearAll];
    
    //remove date time slots
    NSMutableArray* allDateTimeSlots = [DateTimeSlot getAllDateTimeSlots];
    if ([allDateTimeSlots count] > 0) {
        for (DateTimeSlot* dtSlot in allDateTimeSlots) {
            if(dtSlot && [dtSlot getTimeSlot] && [[dtSlot getTimeSlot] count] > 0) {
                [[dtSlot getTimeSlot] removeAllObjects];
            }
        }
    }
    [allDateTimeSlots removeAllObjects];
    
    //remove all feedata
    [[FeeData getAllFeeData] removeAllObjects];
    
    //remove all timeslots
    [[TimeSlot getAllTimeSlots] removeAllObjects];
    
    //remove TM_CheckoutAddon
    [[TM_CheckoutAddon getAllCheckoutAddons] removeAllObjects];
    [[TM_CheckoutAddon getSelectedCheckoutAddons] removeAllObjects];
    [TM_CheckoutAddon setOrderScreenNote:@""];
    
    
    //remove all taxes
    [[TM_Tax getAllTaxes] removeAllObjects];
    [[TM_TaxApplied getAllTaxesApplied] removeAllObjects];
    
    //remove all addons
    [Addons resetManager];
    [Language resetInstance];
    [GuestConfig resetInstance];
    [ExcludedAddress resetInstance];
    [ProductDetailsConfig resetInstance];
    
    
    //reset language preference
//    [[TMLanguage sharedManager] resetAllData];
    
    //remove all vendors
    [[Vendor getAllVendors] removeAllObjects];
    
    //remove contactform3 config
    [ContactForm3Config resetInstance];
    
    //remove reservationform config
    [ReservationFormConfig resetInstance];
    
    //remove all filters
    [[TM_ProductFilter getAll] removeAllObjects];
    [TM_ProductFilter resetAttributeLoaded];
    
    
    //reset custominfo manager
    [CommonInfo resetManager];
    
    //reset datamanager
    [DataManager resetManager];
    
    //reset parsehelper
    [ParseHelper resetManager];
    //remove appuser
    if (deleteAppUserData) {
        [AppUser deleteInstance];
    }
    
    
}
+ (id)sharedManager {
    @synchronized(self) {
        if (sharedAppManager == nil){
            if (FETCH_CUSTOM_OBJ(@"#0001")) {
                sharedAppManager = (AppUser*)FETCH_CUSTOM_OBJ(@"#0001");
                [Cart setCartArray:sharedAppManager._cartArray];
                [Wishlist setWishlistArray:sharedAppManager._wishlistArray];
                [Opinion setOpinionArray:sharedAppManager._opinionArray];
                [LineItem setLineItemProductImgUrls:sharedAppManager._lineItemProductImgUrls];
                if (sharedAppManager._isUserLoggedIn) {
                    [[LoginFlow sharedManager] relogIn];
//                    [[[DataManager sharedManager] tmDataDoctor] fetchCustomerData:nil userEmail:sharedAppManager._email];
                } else {
                    [sharedAppManager removeUnusedData];
                }
            }else{
                sharedAppManager = [[self alloc] init];
            }
        }
    }
    if (sharedAppManager._opinionArray == nil) {
        sharedAppManager._opinionArray = [[NSMutableArray alloc] init];
    }
    if (sharedAppManager._needProductsArrayForOpinion == nil) {
        sharedAppManager._needProductsArrayForOpinion = [[NSMutableArray alloc] init];
    }
    if (sharedAppManager._lineItemProductImgUrls == nil) {
        sharedAppManager._lineItemProductImgUrls = [[NSMutableDictionary alloc] init];
        [LineItem setLineItemProductImgUrls:sharedAppManager._lineItemProductImgUrls];
    }

    return sharedAppManager;
}

//+ (id)sharedManager {
//    @synchronized(self) {
//        if (_mAppUser == nil)
//            _mAppUser = [[self alloc] init];
//    }
//    return _mAppUser;
//}
- (void)removeUnusedData {
    self._email = @"";
    self._mobile_number = @"";
    self._username = @"";
    self._password = @"";
    self._first_name = @"";
    self._last_name = @"";
    self._avatar_url = @"";
    self._userLoggedInVia = -1;
}
- (id)init {
    if (self = [super init]) {
        self._id = -1;
        self._email = @"";
        self._mobile_number = @"";
        self._isUserLoggedIn = false;
        self._userLoggedInVia = -1;
        self._username = @"";
        self._password = @"";
        self._created_at = NULL;
        self._updated_at = NULL;
        self._first_name = @"";
        self._last_name = @"";
        self._last_order_date = @"";
        self._avatar_url = @"";


        self._wishlistArray = [[NSMutableArray alloc] init];
        self._cartArray = [[NSMutableArray alloc] init];
        self._ordersArray = [[NSMutableArray alloc] init];
        self._opinionArray = [[NSMutableArray alloc] init];
        self._lineItemProductImgUrls = [[NSMutableDictionary alloc] init];
        self._needProductsArrayForOpinion = [[NSMutableArray alloc] init];
        self.rewardPoints = -1;
        self.rewardDiscount = 0.0f;
        self._billing_address = [[Address alloc] init];
        self._shipping_address = [[Address alloc] init];
        self._billing_addressTemp = [[Address alloc] init];
        self._shipping_addressTemp = [[Address alloc] init];
        self._billing_addressFetched = [[Address alloc] init];
        self._shipping_addressFetched = [[Address alloc] init];
        self.guestOrderIds = [[NSMutableArray alloc] init];
        
        self.ur_type_string = @"";
        
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self._id = [decoder decodeIntForKey:@"#1"];
        self._email = [decoder decodeObjectForKey:@"#2"];
        self._username = [decoder decodeObjectForKey:@"#3"];
        self._password = [decoder decodeObjectForKey:@"#4"];
        self._created_at = [decoder decodeObjectForKey:@"#5"];
        self._first_name = [decoder decodeObjectForKey:@"#6"];
        self._last_name = [decoder decodeObjectForKey:@"#7"];
        self._last_order_date = [decoder decodeObjectForKey:@"#8"];
        self._avatar_url = [decoder decodeObjectForKey:@"#9"];
        self._billing_address = [decoder decodeObjectForKey:@"#10"];
        self._shipping_address = [decoder decodeObjectForKey:@"#11"];
//        self._shippingAddressArray = [decoder decodeObjectForKey:@"#12"];
//        self._billingAddressArray = [decoder decodeObjectForKey:@"#13"];
        self._isUserLoggedIn = [decoder decodeBoolForKey:@"#14"];
        self._userLoggedInVia = [decoder decodeIntForKey:@"#15"];
//        self._selectedBillingAddressId = [decoder decodeIntForKey:@"#16"];
//        self._selectedShippingAddressId = [decoder decodeIntForKey:@"#17"];
        self._wishlistArray = (NSMutableArray*)[decoder decodeObjectForKey:@"#18"];
        self._cartArray = (NSMutableArray*)[decoder decodeObjectForKey:@"#19"];
        self._ordersArray = (NSMutableArray*)[decoder decodeObjectForKey:@"#20"];
        self._updated_at = [decoder decodeObjectForKey:@"#21"];
        self._billing_addressFetched = [decoder decodeObjectForKey:@"#22"];
        self._shipping_addressFetched = [decoder decodeObjectForKey:@"#23"];
        self._opinionArray = [decoder decodeObjectForKey:@"#24"];
        self.guestOrderIds = [decoder decodeObjectForKey:@"#25"];
        self._mobile_number = [decoder decodeObjectForKey:@"#26"];
        self._lineItemProductImgUrls = [decoder decodeObjectForKey:@"#27"];
        self.ur_type_string = [decoder decodeObjectForKey:@"#28"];
        self.ur_type = [decoder decodeIntForKey:@"#29"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt:self._id forKey:@"#1"];
    [encoder encodeObject:self._email forKey:@"#2"];
    [encoder encodeObject:self._username forKey:@"#3"];
    [encoder encodeObject:self._password forKey:@"#4"];
    [encoder encodeObject:self._created_at forKey:@"#5"];
    [encoder encodeObject:self._first_name forKey:@"#6"];
    [encoder encodeObject:self._last_name forKey:@"#7"];
    [encoder encodeObject:self._last_order_date forKey:@"#8"];
    [encoder encodeObject:self._avatar_url forKey:@"#9"];
    [encoder encodeObject:self._billing_address forKey:@"#10"];
    [encoder encodeObject:self._shipping_address forKey:@"#11"];
//    [encoder encodeObject:self._shippingAddressArray forKey:@"#12"];
//    [encoder encodeObject:self._billingAddressArray forKey:@"#13"];
    [encoder encodeBool:self._isUserLoggedIn forKey:@"#14"];
    [encoder encodeInt:self._userLoggedInVia forKey:@"#15"];
//    [encoder encodeInt:self._selectedBillingAddressId forKey:@"#16"];
//    [encoder encodeInt:self._selectedShippingAddressId forKey:@"#17"];
    [encoder encodeObject:self._wishlistArray forKey:@"#18"];
    [encoder encodeObject:self._cartArray forKey:@"#19"];
    [encoder encodeObject:self._ordersArray forKey:@"#20"];
    [encoder encodeObject:self._updated_at forKey:@"#21"];
    [encoder encodeObject:self._billing_addressFetched forKey:@"#22"];
    [encoder encodeObject:self._shipping_addressFetched forKey:@"#23"];
    [encoder encodeObject:self._opinionArray forKey:@"#24"];
    [encoder encodeObject:self.guestOrderIds forKey:@"#25"];
    [encoder encodeObject:self._mobile_number forKey:@"#26"];
    [encoder encodeObject:self._lineItemProductImgUrls forKey:@"#27"];
    [encoder encodeObject:self.ur_type_string forKey:@"#28"];
    [encoder encodeInt:self.ur_type forKey:@"#29"];
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}
- (void)saveData{
    SAVE_CUSTOM_OBJ(sharedAppManager, @"#0001");
}
- (void)loadData{
    //    if (FETCH_CUSTOM_OBJ(@"#0001")) {
    //        sharedAppManager = (AppUser*)FETCH_CUSTOM_OBJ(@"#0001");
    //    }
}
- (void)clearData{
    self._id = -1;
    self._email = @"";
    self._mobile_number = @"";
    self._username = @"";
    self._password = @"";
    self._created_at = NULL;
    self._updated_at = NULL;
    self._first_name = @"";
    self._last_name = @"";
    self._last_order_date = @"";
    self._avatar_url = @"";
    self._billing_address = [[Address alloc] init];
    self._shipping_address = [[Address alloc] init];
    self._billing_addressFetched = [[Address alloc] init];
    self._shipping_addressFetched = [[Address alloc] init];
    //    [self._wishlistArray removeAllObjects];
    //    [self._cartArray removeAllObjects];
    self._billing_addressTemp= [[Address alloc] init];
    self._shipping_addressTemp = [[Address alloc] init];
//    [self._wishlistArray removeAllObjects];
//    [self._cartArray removeAllObjects];
    [self._ordersArray removeAllObjects];
    self._isUserLoggedIn = false;
    self._userLoggedInVia = -1;
    [self._opinionArray removeAllObjects];
    [self._lineItemProductImgUrls removeAllObjects];
    [self._needProductsArrayForOpinion removeAllObjects];
    self.rewardPoints = 0;
    self.rewardDiscount = 0;
    [self resetUserRole];
    [self saveData];
}
- (void)clearSelectedData {
    [[Cart getAll] removeAllObjects];
    [[Wishlist getAll] removeAllObjects];
    [[ProductInfo getAll] removeAllObjects];
    [CategoryInfo flushAll];
    [[ProductInfo getTrendingItems] removeAllObjects];
    [[ProductInfo getBestSellingItems] removeAllObjects];
    [[ProductInfo getNewArrivalItems] removeAllObjects];
    [[Coupon getAllCoupons] removeAllObjects];
    [WaitList clearAllProductIds];
    [self saveData];
}


+ (void)reload{
    //    TODO here data(ie user instance) is derived from db and check whether it is empty or not..
    //    AppUser temp = (AppUser) new Select().from(AppUser.class).executeSingle();
    //    if(temp != null)
    //    {
    //        mAppUser.id			= temp.id;
    //        mAppUser.email 		= temp.email;
    //        mAppUser.username 	= temp.username;
    //    }
    //    else
    //    {
    //        mAppUser.id			= -1;
    //        mAppUser.email 		= "";
    //        mAppUser.username 	= "";
    //    }

    _mAppUser._id			= -1;
    _mAppUser._email 		= @"";
    _mAppUser._username      = @"";
    _mAppUser._mobile_number      = @"";

}
+ (void)deleteInstance{
    //TODO here we delete the user singleton instance from memory and db..
    //    if(mAppUser != null)
    //    {
    //        mAppUser.delete();
    //        new Delete().from(AppUser.class).execute();
    //        mAppUser = null;
    //        System.gc();
    //    }
    _mAppUser  = nil;
}
- (void)resetAddress {
    AppUser *au = [AppUser sharedManager];
    [au._billing_address copyAddress:au._billing_addressFetched];
    [au._shipping_address copyAddress:au._shipping_addressFetched];
}
- (void)updateFetchedAddress {
    AppUser *au = [AppUser sharedManager];
    [au._billing_addressFetched copyAddress:au._billing_address];
    [au._shipping_addressFetched copyAddress:au._shipping_address];
    [au saveData];
}

- (void)synq
{
    AppUser *au = [AppUser sharedManager];
    [[CustomerData sharedManager] setFirstName:au._first_name];
    [[CustomerData sharedManager] setLastName:au._last_name];
    [[CustomerData sharedManager] setUsername:au._username];
    [[CustomerData sharedManager] setEmailID:au._email];
    [[CustomerData sharedManager] setPassword:au._password];
}
- (void)saveAll{
    AppUser *au = [AppUser sharedManager];
    [au saveData];
    [[[CustomerData sharedManager] getPFInstance] saveInBackground];
    [[ParseHelper sharedManager] registerParseCustomerUpdate];
}

+ (BOOL)isSignedIn
{
    return [[AppUser sharedManager] _isUserLoggedIn];
    //return ([[AppUser sharedManager] _id] != -1 && ![[[AppUser sharedManager] _email] isEqualToString:@""]);
}
- (void)parseUserRole:(NSDictionary*)dict {
    if (!((IS_NOT_NULL(dict, @"role")) || (IS_NOT_NULL(dict, @"role_price")))) {
        return;
    }
    [self resetUserRole];
    
    AppUser* appUser = [AppUser sharedManager];
    NSString* role = @"";
    NSString* role_title = @"";
    NSString* urp_formula_type = @"";
    NSString* urp_type = @"";
    float urp = 0.0f;
    
    if (IS_NOT_NULL(dict, @"role")) {
        role = GET_VALUE_STRING(dict, @"role");
        role_title = GET_VALUE_STRING(dict, @"role");
    }
    
    if (IS_NOT_NULL(dict, @"role_price")) {
        NSDictionary* role_price = GET_VALUE_OBJ(dict, @"role_price");
        if (IS_NOT_NULL(role_price, @"role")) {
            role = GET_VALUE_STRING(role_price, @"role");
            role_title = role;
        }
        if (IS_NOT_NULL(role_price, @"role_title")) {
            role_title = GET_VALUE_STRING(role_price, @"role_title");
        }
        if (IS_NOT_NULL(role_price, @"type")) {
            urp_type = GET_VALUE_STRING(role_price, @"type");
        }
        if (IS_NOT_NULL(role_price, @"filter")) {
            urp_formula_type = GET_VALUE_STRING(role_price, @"filter");
        }
        if (IS_NOT_NULL(role_price, @"price")) {
            urp = GET_VALUE_FLOAT(role_price, @"price");
        }
    }
    
    //    [administrator] => Administrator
    //    [editor] => Editor
    //    [author] => Author
    //    [contributor] => Contributor
    //    [subscriber] => Subscriber
    //    [customer] => Customer
    //    [shop_manager] => Shop Manager
    //    [dc_vendor] => Vendor
    //    [dc_pending_vendor] => Pending Vendor
    //    [dc_rejected_vendor] => Rejected Vendor
    
    
    appUser.ur_type = [AppUser getRoleType:role];
    
    //    type: discount / markup
    if ([urp_type isEqualToString:@"discount"]) {
        appUser.urp_type = URP_TYPE_DISCOUNT;
    } else if ([urp_type isEqualToString:@"markup"]) {
        appUser.urp_type = URP_TYPE_MARKUP;
    }
    
    //    filter: percentage / amount
    if ([urp_formula_type isEqualToString:@"percentage"]) {
        appUser.urp_formula_type = URP_FORMULA_TYPE_PERCENTAGE;
    } else if ([urp_type isEqualToString:@"amount"]) {
        appUser.urp_formula_type = URP_FORMULA_TYPE_AMOUNT;
    }
    appUser.ur_type_string = role;
    appUser.ur_type_title = role_title;
    appUser.urp = urp;
    [appUser saveData];
}

+ (int)getRoleType:(NSString*)role {
    role = [role lowercaseString];
    int roleType = UR_TYPE_CUSTOMER;
    if ([role isEqualToString:@"administrator"]) {
        roleType = UR_TYPE_ADMINISTRATOR;
    } else if ([role isEqualToString:@"editor"]) {
        roleType = UR_TYPE_EDITOR;
    } else if ([role isEqualToString:@"author"]) {
        roleType = UR_TYPE_AUTHOR;
    } else if ([role isEqualToString:@"contributor"]) {
        roleType = UR_TYPE_CONTRIBUTOR;
    } else if ([role isEqualToString:@"subscriber"]) {
        roleType = UR_TYPE_SUBSCRIBER;
    } else if ([role isEqualToString:@"customer"]) {
        roleType = UR_TYPE_CUSTOMER;
    } else if ([role isEqualToString:@"shop_manager"]) {
        roleType = UR_TYPE_SHOP_MANAGER;
    } else if ([role isEqualToString:@"seller"] || [role isEqualToString:@"vendor"] || [role isEqualToString:@"dc_vendor"]) {
        roleType = UR_TYPE_SELLER;
    } else if ([role isEqualToString:@"pending_vendor"] || [role isEqualToString:@"dc_pending_vendor"]) {
        roleType = UR_TYPE_PENDING_VENDOR;
    } else if ([role isEqualToString:@"dc_rejected_vendor"]) {
        roleType = UR_TYPE_REJECTED_VENDOR;
    }
    return roleType;
}

- (void)relaunchApp {
    [ViewControllerMain resetInstance];
    [Utility resetStoryBoardObject];
    [AppUser clearFullAppData:false];
    UIStoryboard *sb = [Utility getStoryBoardObject];
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"APPDATA_PLATFORM"];
    ViewControllerSplashPrimary *rootViewController = [sb instantiateViewControllerWithIdentifier:VC_SPLASH_PRIMARY];
    [[UIApplication sharedApplication].keyWindow setRootViewController:rootViewController];

}
- (void)resetUserRole {
    AppUser* appUser = [AppUser sharedManager];
    appUser.ur_type_string = @"";
    appUser.ur_type = -1;
    appUser.ur_type_title = @"";
    appUser.urp_formula_type = -1;
    appUser.urp_type = -1;
    appUser.urp = 0.0f;
}
@end
