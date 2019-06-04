//
//  Utility.h
//  eCommerceApp
//
//  Created by Rishabh Jain on 06/10/15.
//  Copyright (c) 2015 Twist Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import "Variables.h"
#import "MRProgress.h"
#import "AppDelegate.h"
#import "UserFilter.h"
//#import <MRProgress/MRProgressOverlayView+AFNetworking.h>
#import "ViewControllerCategories.h"
#if CATEGORY_VIEW_NEW_HACK_ENABLE
#import "ViewControllerCategoriesNew.h"
#endif
#import "ViewControllerProduct.h"

#if __IPHONE_OS_VERSION_MAX_ALLOWED > 90000
#import <ReplayKit/ReplayKit.h>
#endif

#if ENABLE_NTP
#import "ios-ntp.h"
#endif

#define PRINT_RECT(rect) RLOG(@"==PRINT_RECT==\tx = %.2f, y = %.2f, w = %.2f, h = %.2f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height)
#define PRINT_SIZE(size) RLOG(@"==PRINT_SIZE==\tw = %.2f, h = %.2f", size.width, size.height);
#define PRINT_POINT(point) RLOG(@"==PRINT_POINT==\tx = %.2f, y = %.2f", point.x, point.y);
#define PRINT_OBJECT(obj) RLOG(@"==PRINT_OBJECT==\tobject = %.@", obj);

#define PRINT_RECT_STR(str,rect) RLOG(@"==PRINT_RECT_%@==\tx = %.2f, y = %.2f, w = %.2f, h = %.2f", str, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height)
#define PRINT_SIZE_STR(str,size) RLOG(@"==PRINT_SIZE_%@==\tw = %.2f, h = %.2f", str, size.width, size.height);
#define PRINT_POINT_STR(str,point) RLOG(@"==PRINT_POINT_%@==\tx = %.2f, y = %.2f", str, point.x, point.y);
#define PRINT_OBJECT_STR(str,obj) RLOG(@"==PRINT_OBJECT_%@==\tobject = %.@", str, obj);

#ifdef __IPHONE_7_0
#define LABEL_SIZE(label) [[label text] sizeWithAttributes:@{NSFontAttributeName:[label font]}]
#else
#define LABEL_SIZE(label) [[label text] sizeWithFont:[label font]]
#endif

#define SAVE_LOCAL_STRING(value, key)   [[NSUserDefaults standardUserDefaults] setValue:value forKey:key]
#define SAVE_LOCAL_INT(value, key)  [[NSUserDefaults standardUserDefaults] setInteger:value forKey:key]
#define SAVE_LOCAL_FLOAT(value, key)    [[NSUserDefaults standardUserDefaults] setFloat:value forKey:key]
#define SAVE_LOCAL_BOOL(value, key) [[NSUserDefaults standardUserDefaults] setBool:value forKey:key]
#define SAVE_LOCAL_OBJ(value, key) [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
#define SAVE_CUSTOM_OBJ(value, key) SAVE_LOCAL_OBJ([NSKeyedArchiver archivedDataWithRootObject:value], key)

#define FETCH_LOCAL_STRING(key) [[NSUserDefaults standardUserDefaults] stringForKey:key]?[[NSUserDefaults standardUserDefaults] stringForKey:key]:@""
#define FETCH_LOCAL_INT(key)    (int)[[NSUserDefaults standardUserDefaults] integerForKey:key]?(int)[[NSUserDefaults standardUserDefaults] integerForKey:key]:0
#define FETCH_LOCAL_FLOAT(key)  [[NSUserDefaults standardUserDefaults] floatForKey:key]?[[NSUserDefaults standardUserDefaults] floatForKey:key]:0.0f
#define FETCH_LOCAL_BOOL(key)   [[NSUserDefaults standardUserDefaults] boolForKey:key]?[[NSUserDefaults standardUserDefaults] boolForKey:key]:false
#define FETCH_LOCAL_OBJ(key)   [[NSUserDefaults standardUserDefaults] objectForKey:key]?[[NSUserDefaults standardUserDefaults] objectForKey:key]:nil
#define FETCH_CUSTOM_OBJ(key) [NSKeyedUnarchiver unarchiveObjectWithData:FETCH_LOCAL_OBJ(key)]?[NSKeyedUnarchiver unarchiveObjectWithData:FETCH_LOCAL_OBJ(key)]:nil

#define getColor(colorId) [Utility getUIColor:colorId]

enum PUSH_SCREEN_TYPE {
    PUSH_SCREEN_TYPE_PRODUCT,
    PUSH_SCREEN_TYPE_PROD_DESC,
    PUSH_SCREEN_TYPE_CATEGORY,
    PUSH_SCREEN_TYPE_CATEGORY_NEW,
    PUSH_SCREEN_TYPE_ADDRESS,
    PUSH_SCREEN_TYPE_MYORDER,
    PUSH_SCREEN_TYPE_SETTINGS,
    PUSH_SCREEN_TYPE_LOGOUT,
    PUSH_SCREEN_TYPE_LOGIN,
    PUSH_SCREEN_TYPE_CART_CONFIRM,
    PUSH_SCREEN_TYPE_CART_SHIPPING,
    PUSH_SCREEN_TYPE_ORDER,
    PUSH_SCREEN_TYPE_ORDER_RECEIPT,
    PUSH_SCREEN_TYPE_WEBVIEW,
    PUSH_SCREEN_TYPE_CONTACT_US,
    PUSH_SCREEN_TYPE_CONTACT_US_FORM,
    PUSH_SCREEN_TYPE_RESERVATION_FORM,
    PUSH_SCREEN_TYPE_CHECKOUT,
    PUSH_SCREEN_TYPE_GETCODE,
    PUSH_SCREEN_TYPE_SPONSOR_FRIEND,
    PUSH_SCREEN_TYPE_BRAND,
    PUSH_SCREEN_TYPE_FILTER,
    PUSH_SCREEN_TYPE_MYCOPON,
    PUSH_SCREEN_TYPE_SETTING,
    PUSH_SCREEN_TYPE_NOTIFICATION,
    PUSH_SCREEN_TYPE_MYCOPON_PRODUCT,
    PUSH_SCREEN_TYPE_BARCODE_SCAN,
    PUSH_SCREEN_TYPE_LOCATE_STORE,
    PUSH_SCREEN_TYPE_SELLER_ZONE,
    PUSH_SCREEN_TYPE_ADDRESS_MAP,
    PUSH_SCREEN_TYPE_SELLER_ITEM,
    PUSH_SCREEN_TYPE_VC_PRODUCTS,
    PUSH_SCREEN_TYPE_NEARBYSEARCH,
    PUSH_SCREEN_TYPE_CURRENCY,
};


enum UIColorCustom{
    //changable
    kUIColorThemeButtonNormal,
    kUIColorThemeButtonBorderNormal,
    kUIColorThemeButtonSelected,
    kUIColorThemeButtonBorderSelected,
    kUIColorThemeButtonDisable,
    kUIColorThemeButtonBorderDisable,
    kUIColorThemeFont,
    kUIColorBgHeader,
    kUIColorBgFooter,
    kUIColorBuyButtonNormalBg,
    kUIColorBuyButtonFont,
    kUIColorBannerSelectedPageIndicator,
    kUIColorBannerNormalPageIndicator,
    //remains as it is
    kUIColorFontLight,
    kUIColorTextFieldBorder,
    kUIColorFontDark,
    kUIColorFontPriceOld,
    kUIColorBgTheme,
    kUIColorBorder,
    kUIColorFontListViewLevel0,
    kUIColorFontListViewLevel1,
    kUIColorFontListViewLevel2Plus,
    kUIColorBannerBg,
    kUIColorTransparent,
    kUIColorClear,
    kUIColorFontSubTitle,
    kUIColorBgSubTitle,
    kUIColorCartSelected,
    kUIColorWishlistSelected,
    kUIColorBlue,
    kUIColorHViewHeaderBg,
    kUIColorHViewHeaderFont,
//    red heart - #f05259
//    green cart - #09bc00
};

enum UIFontCustom{
    kUIFontType08,
    kUIFontType09,
    kUIFontType10,
    kUIFontType11,
    kUIFontType12,
    kUIFontType13,
    kUIFontType14,
    kUIFontType15,
    kUIFontType16,
    kUIFontType17,
    kUIFontType18,
    kUIFontType19,
    kUIFontType20,
    kUIFontType21,
    kUIFontType22,
    kUIFontType23,
    kUIFontType24,
    kUIFontType25,
    kUIFontType26,
    kUIFontType27,
    kUIFontType28,
    kUIFontType29,
    kUIFontType30,
    kUIFontType31,
    kUIFontType32,
    kUIFontTypeTotal
};


enum kRECORDING_STATE {
    kRECORDING_ENABLE,
    kRECORDING_DISABLE,
};

enum RESIZE_TYPE {
    kRESIZE_TYPE_NONE,
    kRESIZE_TYPE_BANNER,
    kRESIZE_TYPE_CATEGORY_THUMBNAIL,
    kRESIZE_TYPE_PRODUCT_THUMBNAIL,
    kRESIZE_TYPE_PRODUCT_BANNER
};


@interface Utility : NSObject

#if ENABLE_NTP
@property NetworkClock*  netClock;
@property NetAssociation* netAssociation;
#endif

+ (id)sharedManager;
- (long long)getUnixTimeInMS;
- (NSString *)getUnixTimeString;
//- (NSMutableAttributedString *)getStrikethroughString:(NSString *)str;
//- (NSString *)useNumberFormatter:(float)value;
- (NSString *)convertToString:(float)value isCurrency:(BOOL)isCurrency;
- (NSMutableAttributedString *)convertToStringStrikethrough:(float)value isCurrency:(BOOL)isCurrency;
+ (UIColor *)colorWithHex:(int)color;
//+ (UIImage *)getPlaceholderImage;
+ (UIImage *)getPlaceholderImage:(int)type;

+ (void)setImage:(UIImageView*)uiImageView url:(NSString *)url resizeType:(int)resizeType isLocal:(BOOL)isLocal;
+ (void)setImage:(UIImageView*)uiImageView url:(NSString *)url resizeType:(int)resizeType isLocal:(BOOL)isLocal highPriority:(BOOL)highPriority;


- (ViewControllerCategories *)pushScreen:(UIViewController*)parentViewController;
//- (ViewControllerCategories *)pushScreenWithoutAnimation:(UIViewController*)parentViewController;
- (UIViewController *)pushScreenWithoutAnimation:(UIViewController*)parentViewController type:(int)type;
- (UIViewController *)pushScreenWithNewAnimation:(UIViewController*)parentViewController type:(int)type;
- (void)popScreenWithNewAnimation:(UIViewController*)childViewController;
- (void)popScreen:(UIViewController*)childViewController;
- (void)popScreenWithoutAnimation:(UIViewController*)childViewController;
- (ViewControllerProduct *)pushProductScreen:(UIViewController*)parentViewController;
- (RPPreviewViewController *)pushRecordingScreen:(UIViewController*)parentViewController recordVC:(RPPreviewViewController *)recordVC;
- (UIViewController *)pushOverScreenWithoutAnimation:(UIViewController*)parentViewController type:(int)type;

+ (UIColor*)getUIColor:(int)tag;
+ (UIFont*)getUIFont:(int)type isBold:(BOOL)isBold;
+ (UIColor *)colorWithHexString:(NSString *)hexStr alpha:(CGFloat)alpha;

@property NSMutableArray* pushedViewControllers;

- (NSString *)getCurrencyWithSign:(float)value currencyCode:(NSString*)currencyCode;
- (NSString *)getCurrencyWithSign:(float)value currencyCode:(NSString*)currencyCode symbolAtLast:(BOOL)symbolAtLast;
- (NSString *)convertToString:(float)value isCurrency:(BOOL)isCurrency symbolAtLast:(BOOL)symbolAtLast;
@property float statusBarHeight;
@property float topBarHeight;
@property float bottomBarHeight;
- (float)getStatusBarHeight;
- (float)getTopBarHeight;
- (float)getBottomBarHeight;

+ (UIImage *)getSplashBgImage;
+ (UIImage *)getSplashFgImage;
+ (UIImage *)getAppIconImage;
+ (NSString*)getNormalStringFromAttributed:(NSString*)str;
- (void)shareBranchButtonClicked:(ProductInfo*)pInfo button:(UIButton*)button ;
- (void)shareOpinionButtonClicked:(ProductInfo*)pInfo pollId:(NSString*)pollId productUrl:(NSString*)productUrl;
- (void)shareWhatsAppButtonClicked:(ProductInfo*)pInfo pollId:(NSString*)pollId productUrl:(NSString*)productUrl;
- (void)startRecording;
- (void)stopRecording;
+ (void)showShadow:(UIView*)view;
+ (void)showShadow:(UIView*)view enableBorder:(BOOL)enableBorder borderSides:(int)borderSides;
@property int recordingState;

+ (void)setThemeBlueColor;
+ (void)setThemeHeaderBg:(UIColor*)value;
+ (void)setThemeFooterBg:(UIColor*)value;
+ (void)setThemeColor:(UIColor*)value;
+ (void)setThemeButtonNormalColor:(UIColor*)value;
+ (void)setThemeButtonSelectedColor:(UIColor*)value;
+ (void)setThemeButtonDisabledColor:(UIColor*)value;
+ (void)setThemeBigButtonBg:(UIColor*)value;
+ (void)setThemeBigButtonFont:(UIColor*)value;
+ (void)setThemeBannerIndicatorSelectedColor:(UIColor *)value;
+ (void)setThemeBannerIndicatorNormalColor:(UIColor *)value;
+ (void)setThemeColorHorizontalViewBg:(UIColor *)value;
+ (void)setThemeColorHorizontalViewFont:(UIColor *)value;

- (BOOL)checkForDemoApp:(BOOL)showMsg;
- (BOOL)checkForPaidApp;

@property UIAlertView* alertForDemoApp;

- (NSString*)getCategoryViewString;
- (NSString*)getProductViewString;
- (NSString*)getHorizontalViewString;
- (NSString*)getBundleViewString;
- (NSString*)getMixNMatchViewString;

- (UIActivityIndicatorView*)startGrayLoadingBar:(BOOL)willRotate;
- (void)stopGrayLoadingBar;

- (NSString*)getUserAgent;
@property NSString* userAgentForPostMethod;
- (NSString*)resizeImageInPath:(NSString*)path resizeType:(int)resizeType;
- (NSString*)getExtension:(NSString*) fileName;
- (NSString*)getResizedImageUrl:(NSString*) img_url;
- (NSString*)getScaledImageUrl:(NSString*) src_url;
- (NSString*)resizeProductImage:(NSString*) src_url;
- (NSString *)stringByReplacingOccurrencesOfString:(NSString *)target
                                        withString:(NSString *)replacement;
@property UIActivityIndicatorView* spinnerView;

@property NSString* deviceModel;
- (NSString*)getDeviceModel;

- (UIColor*)getTextFieldBorderColor;
+ (MRProgressOverlayView*)createCustomizedLoadingBar:(NSString*)title isBottomAlign:(BOOL)isBottomAlign isClearViewEnabled:(BOOL)isClearViewEnabled isShadowEnabled:(BOOL)isShadowEnabled;
+ (void)showProgressView:(NSString*)message;
+ (void)hideProgressView;
+ (void)showToast:(NSString*)message;

+ (void)setImageNew:(UIImageView*)uiImageView url:(NSString *)url resizeType:(int)resizeType highPriority:(BOOL)highPriority parentCell:(CCollectionViewCell *)parentCell collectionViewLayout:(id)collectionViewLayout collectionView:(UICollectionView*)collectionView component:(NSInteger)component indexpath:(NSIndexPath*)indexpath vc:(ViewControllerCategories*)vc;
+ (CGSize)makeSize:(CGSize)originalSize fitInSize:(CGSize)boxSize;
+ (BOOL)containsString:(NSString *)string substring:(NSString*)substring;
+ (BOOL)compareAttributeNames:(NSString*)name1 name2:(NSString*)name2;
+ (NSString*)getStringIfFormatted:(NSString*)str;
- (NSString*)getCategoryViewString:(int)indexId;
+ (void)getUIFont:(int)type isBold:(BOOL)isBold appliedOnLable:(UILabel*)appliedOnLable;
+ (void)changeInputLanguage:(NSString*)selectedLocale;
+ (void)setImage:(UIImageView*)uiImageView url:(NSString *)url placeholderImage:(UIImage*)placeholderImage;
- (void)openSagepayPaymentGatewayDirectly:(id)delegate;

//@property NSDictionary* slugify_strings;
@property NSMutableArray* slugify_keys;
@property NSMutableArray* slugify_values;
+ (BOOL)isNetworkAvailable;
+ (id)getJsonObject:(id)responseObject;
+ (id)getJsonArray:(id)responseObject;
+ (CATransition*)pushAnimation;
+ (NSAttributedString*)createLinkAttributedString:(NSString*)string;
+ (NSAttributedString*)createUnderlineAttributedString:(NSString*)string;
- (void)initCurrencySymbol;
- (void)initCurrencyPosition;
- (void)checkShowLoginAtStartCondition;
- (BOOL)canDevicePlaceAPhoneCall;
+ (id)getStoryBoardObject;
+ (id)getViewControllersByIdentifier;
- (BOOL)isValidEmailId:(NSString*)email;
+ (id)resetStoryBoardObject;
+ (BOOL)isMultiStoreApp;
+ (BOOL)isMultiStoreAppTMStore;
+ (BOOL)isNearBySearch;
+ (BOOL)isSellerOnlyApp;
+ (void)resetViewControllersByIdentifier;
+ (NSString *)formattedTimeString:(float)totalMilliSeconds ;
- (UIViewController*)pushScreenWithoutAnimation:(UIViewController*)parentViewController type:(int)type newViewController:(UIViewController *)newViewController;
- (UIViewController*)getNewViewController:(int)type;

- (void)substractButtonClicked:(UIButton*)button;
- (void)addButtonClicked:(UIButton*)button;
- (void)addShowAppInfoGesture:(id)delegate;
+ (UIViewController*)topMostController;
- (NSString*)getCurrencySymbol ;
+ (NSString*)getInitials:(NSString*)fullName limit:(int)limit;

- (CCollectionViewCell*)setProductCellDataCategoryScreen:(UICollectionView *)collectionView cell:(CCollectionViewCell *)cell indexPath:(NSIndexPath *)indexPath isCategory:(BOOL)isCategory childCount:(int)childCount showFilterdResult:(BOOL)showFilterdResult cInfo:(CategoryInfo*)cInfo nibName:(NSString*)nibName target:(id)target dataSource:(NSMutableArray*)dataSource;

- (CCollectionViewCell*)setProductCellDataCategoryScreen:(UICollectionView *)collectionView cell:(CCollectionViewCell *)cell indexPath:(NSIndexPath *)indexPath isCategory:(BOOL)isCategory childCount:(int)childCount showFilterdResult:(BOOL)showFilterdResult cInfo:(CategoryInfo*)cInfo nibName:(NSString*)nibName target:(id)target dataSource:(NSMutableArray*)dataSource appliedUserFilter:(UserFilter*)userFilter;

- (CGSize)getProductCellSizeCategoryScreen:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath propCollectionView:(LayoutProperties*)propCollectionView showFilterdResult:(BOOL)showFilterdResult cInfo:(CategoryInfo*)cInfo dataSource:(NSMutableArray*)dataSource;

- (id)initProductCellCategoryScreen:(UICollectionView*)viewUserDefined propCollectionView:(LayoutProperties*)propCollectionView layout:(UICollectionViewFlowLayout *)layout nibName:(NSString*)nibName;

- (void)initWishlistButton:(UIButton*)button;
- (void)wishlistButtonClicked:(UIButton*)button;
+ (NSString*)getAppName;
#if CATEGORY_VIEW_NEW_HACK_ENABLE
- (ViewControllerCategoriesNew *)pushScreenCategoryNew:(UIViewController*)parentViewController;
#endif

+ (SDWebImageOptions)getImageDownloadOption;
+ (long) getCurrentMilliseconds;
@end
