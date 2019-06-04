#import "CommonInfo.h"
#import "Variables.h"
#import "DataManager.h"
@implementation CommonInfo

static CommonInfo *sharedManager = nil;
+ (CommonInfo *)sharedManager {
    if (sharedManager == nil) {
        sharedManager = [[self alloc] init];
    }
    return sharedManager;
}
- (id)init {
    if (self = [super init]) {
        _kIdPageHome        = 0;
        _kIdPageWishlist    = 1;
        _kIdPageMyCart      = 2;
        _kIdPageMyOrders    = 3;
        _kIdPageSettings    = 4;
        _kIdPageSignIn      = 5;
        _kIdPageSignOut     = 6;
        _kIdPageProfile     = 7;
        _timezone                   = @"Asia/Kolkata";
        _currency                   = @"INR";
        _currency_format            = @"Rs.";
        _currency_position          = @"left";
        _thousand_separator         = @",";
        _decimal_separator          = @".";
        _price_num_decimals         = 2;
        _tax_included               = false;
        _addTaxToProductPrice       = false;
        _woocommerce_prices_include_tax = false;
        _weight_unit                = @"kg";
        _dimension_unit             = @"cm";
        _hideOutOfStock             = false;
        _SHOW_NODE_CATEGORY_IN_LISTVIEW     = false;
        _shippingTaxClassName = @"";
        _calculateTaxBasedOn = @"";
        _shopBaseAddressCountryId = @"";
        _shopBaseAddressStateId = @"";
    }
    return self;
}
- (void)dealloc {
    // Should never be called, but just here for clarity really.
}
+ (void)resetManager {
    sharedManager = nil;
}

@end
