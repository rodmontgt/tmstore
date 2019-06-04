#import <Foundation/Foundation.h>

@interface CommonInfo : NSObject
{
@public
    int _kIdPageHome;
    int _kIdPageWishlist;
    int _kIdPageMyCart;
    int _kIdPageMyOrders;
    int _kIdPageSettings;
    int _kIdPageSignIn;
    int _kIdPageSignOut;
    int _kIdPageProfile;
    NSString *_timezone;
    NSString *_currency;
    NSString *_currency_format;
    NSString *_currency_position;
    NSString *_thousand_separator;
    NSString *_decimal_separator;
    int _price_num_decimals;
    BOOL _tax_included;
    NSString *_weight_unit;
    NSString *_dimension_unit;
    BOOL _hideOutOfStock;
    BOOL _woocommerce_prices_include_tax;
    BOOL _addTaxToProductPrice;//again in work
    BOOL _SHOW_NODE_CATEGORY_IN_LISTVIEW;
    NSString *_shippingTaxClassName;
    NSString *_calculateTaxBasedOn;
    NSString *_shopBaseAddressCountryId;
    NSString *_shopBaseAddressStateId;
}
+ (CommonInfo *)sharedManager;
+ (void)resetManager;
@end
