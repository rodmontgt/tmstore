//
//  MV1X_JsonHelper.m
//  TMDataDoctor
//
//  Created by Rishabh Jain on 18/01/16.
//  Copyright © 2016 Twist Mobile Pvt. Ltd. India. All rights reserved.
//

#import "MV1X_JsonHelper.h"
#import "AppUser.h"
#import "Order.h"
#import "CommonInfo.h"
#import "Utility.h"
#import "LayoutManager.h"
#import "STHTTPRequest.h"
#import "Variables.h"
#import "AppUser.h"
#import "Variation.h"
#import "ServerData.h"
#import "CommonInfo.h"
#import "ProductInfo.h"
#import "ProductImage.h"
#import "Attribute.h"
#import "CategoryInfo.h"
#import "MV1X_Engine.h"
#import "LoginFlow.h"


@implementation MV1X_JsonHelper
- (id)initWithEngine:(id)tmEngineObj{
    self = [super init];
    if (self) {
        _engineObj = tmEngineObj;
    }return self;
}
#pragma mark Load Data From Server
- (void)loadCustomerData:(NSDictionary*)dictionary {
    LoginFlow* loginFlow = [LoginFlow sharedManager];
    
    RLOG(@"CUSTOMER DATA1 = %@", dictionary);
    RLOG(@"Dictionary size = %d", (int)dictionary.count);
    AppUser* au = [AppUser sharedManager];
    NSDictionary* mainDict = nil;
    if (IS_NOT_NULL(dictionary, @"customer"))
    {
        mainDict = [dictionary objectForKey:@"customer"];
        
        if (IS_NOT_NULL(mainDict, @"id")) {
            au._id = GET_VALUE_INT(mainDict, @"id");
        }
        if (IS_NOT_NULL(mainDict, @"orders_count")) {
            au._orders_count = GET_VALUE_INT(mainDict, @"orders_count");
        }
        if (IS_NOT_NULL(mainDict, @"last_order_id")) {
            au._last_order_id = GET_VALUE_INT(mainDict, @"last_order_id");
        }
        if (IS_NOT_NULL(mainDict, @"total_spent")) {
            au._total_spent = GET_VALUE_FLOAT(mainDict, @"total_spent");
        }
        if (IS_NOT_NULL(mainDict, @"avatar_url")) {
            au._avatar_url = GET_VALUE_STRING(mainDict, @"avatar_url");
        }
        if (![loginFlow.userImage isEqualToString:@""]) {
            au._avatar_url = loginFlow.userImage;
        }
        
        
        if (IS_NOT_NULL(mainDict, @"email")) {
            au._email = GET_VALUE_STRING(mainDict, @"email");
        }
        if (IS_NOT_NULL(mainDict, @"last_name")) {
            au._last_name = GET_VALUE_STRING(mainDict, @"last_name");
        }
        
        if (IS_NOT_NULL(mainDict, @"first_name")) {
            au._first_name = GET_VALUE_STRING(mainDict, @"first_name");
        }
        if (![loginFlow.userNickName isEqualToString:@""]) {
            au._first_name = loginFlow.userNickName;
        }
        if ([au._first_name isEqualToString:@""]) {
            au._first_name = au._username;
        }
        
        
        
        if (IS_NOT_NULL(mainDict, @"username")) {
            au._username = GET_VALUE_STRING(mainDict, @"username");
        }
        if (IS_NOT_NULL(mainDict, @"last_order_date")) {
            au._last_order_date = GET_VALUE_STRING(mainDict, @"last_order_date");
        }
        if (IS_NOT_NULL(mainDict, @"created_at")) {
            NSDateFormatter* df = [[NSDateFormatter alloc]init];
            [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
            NSString* str = GET_VALUE_STRING(mainDict, @"created_at");
            au._created_at = [df dateFromString:str];
        }
        if (IS_NOT_NULL(mainDict, @"updated_at")) {
            NSDateFormatter* df = [[NSDateFormatter alloc]init];
            [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
            NSString* str = GET_VALUE_STRING(mainDict, @"updated_at");
            au._updated_at = [df dateFromString:str];
        }
        if (IS_NOT_NULL(mainDict, @"billing_address")) {
            //            au._billing_address = ?
        }
        if (IS_NOT_NULL(mainDict, @"shipping_address")) {
            //            au._shipping_address = ?
        }
    }
    
    RLOG(@"CUSTOMER DATA2 = %@", dictionary);
    [au saveData];
    [(MV1X_Engine*)_engineObj fetchOrdersData:nil];
}
- (void)loadOrdersData:(NSDictionary *)dictionary {
    AppUser* appUser = [AppUser sharedManager];
    [appUser._ordersArray removeAllObjects];
    RLOG(@"CategoryInfo Count========>%d", (int)[[CategoryInfo getAll] count]);
    RLOG(@"ProductInfo Count========>%d", (int)[[ProductInfo getAll] count]);
    RLOG(@"Orders Count========>%d", (int)[appUser._ordersArray count]);
    
    NSDictionary* headerDict = [dictionary objectForKey:@"orders"];
    NSDictionary* mainDict = nil;
    
    for (mainDict in headerDict) {
        if (IS_NOT_NULL(mainDict, @"customer_id")) {
            if(GET_VALUE_INT(mainDict, @"customer_id") == [[AppUser sharedManager] _id] )
            {
                
                Order* order = [[Order alloc] init];
                if (IS_NOT_NULL(mainDict, @"id")) {
                    order._id = GET_VALUE_INT(mainDict, @"id");
                }
                if (IS_NOT_NULL(mainDict, @"order_number")) {
                    order._order_number = GET_VALUE_INT(mainDict, @"order_number");
                }
                if (IS_NOT_NULL(mainDict, @"created_at")) {
                    NSDateFormatter* df = [[NSDateFormatter alloc]init];
                    [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
                    NSString* str = GET_VALUE_STRING(mainDict, @"created_at");
                    order._created_at = [df dateFromString:str];
                }
                if (IS_NOT_NULL(mainDict, @"updated_at")) {
                    NSDateFormatter* df = [[NSDateFormatter alloc]init];
                    [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
                    NSString* str = GET_VALUE_STRING(mainDict, @"updated_at");
                    order._updated_at = [df dateFromString:str];
                }
                if (IS_NOT_NULL(mainDict, @"completed_at")) {
                    order._completed_at = GET_VALUE_STRING(mainDict, @"completed_at");
                }
                if (IS_NOT_NULL(mainDict, @"status")) {
                    order._status = GET_VALUE_STRING(mainDict, @"status");
                }
                if (IS_NOT_NULL(mainDict, @"currency")) {
                    order._currency = GET_VALUE_STRING(mainDict, @"currency");
                }
                if (IS_NOT_NULL(mainDict, @"total")) {
                    order._total = GET_VALUE_STRING(mainDict, @"total");
                }
                if (IS_NOT_NULL(mainDict, @"subtotal")) {
                    order._subtotal = GET_VALUE_STRING(mainDict, @"subtotal");
                }
                if (IS_NOT_NULL(mainDict, @"total_line_items_quantity")) {
                    order._total_line_items_quantity = GET_VALUE_INT(mainDict, @"total_line_items_quantity");
                }
                if (IS_NOT_NULL(mainDict, @"total_tax")) {
                    order._total_tax = GET_VALUE_FLOAT(mainDict, @"total_tax");
                }
                if (IS_NOT_NULL(mainDict, @"total_shipping")) {
                    order._total_shipping = GET_VALUE_FLOAT(mainDict, @"total_shipping");
                }
                if (IS_NOT_NULL(mainDict, @"cart_tax")) {
                    order._cart_tax = GET_VALUE_FLOAT(mainDict, @"cart_tax");
                }
                if (IS_NOT_NULL(mainDict, @"shipping_tax")) {
                    order._shipping_tax = GET_VALUE_FLOAT(mainDict, @"shipping_tax");
                }
                if (IS_NOT_NULL(mainDict, @"total_discount")) {
                    order._total_discount = GET_VALUE_FLOAT(mainDict, @"total_discount");
                }
                if (IS_NOT_NULL(mainDict, @"shipping_methods")) {
                    order._shipping_methods = GET_VALUE_STRING(mainDict, @"shipping_methods");
                }
                if (IS_NOT_NULL(mainDict, @"payment_details")) {
                    NSDictionary* tempDict = [mainDict objectForKey:@"payment_details"];
                    
                    if (IS_NOT_NULL(tempDict, @"method_id")) {
                        order._payment_details._method_id = GET_VALUE_STRING(tempDict, @"method_id");
                    }
                    if (IS_NOT_NULL(tempDict, @"method_title")) {
                        order._payment_details._method_title = GET_VALUE_STRING(tempDict, @"method_title");
                    }
                    if (IS_NOT_NULL(tempDict, @"paid")) {
                        order._payment_details._paid = GET_VALUE_BOOL(tempDict, @"paid");
                    }
                }
                if (IS_NOT_NULL(mainDict, @"billing_address")) {
                    NSDictionary* tempDict = [mainDict objectForKey:@"billing_address"];
                    
                    if (IS_NOT_NULL(tempDict, @"first_name")) {
                        order._billing_address._first_name = GET_VALUE_STRING(tempDict, @"first_name");
                    }
                    if (IS_NOT_NULL(tempDict, @"last_name")) {
                        order._billing_address._last_name = GET_VALUE_STRING(tempDict, @"last_name");
                    }
                    if (IS_NOT_NULL(tempDict, @"company")) {
                        order._billing_address._company = GET_VALUE_STRING(tempDict, @"company");
                    }
                    if (IS_NOT_NULL(tempDict, @"address_1")) {
                        order._billing_address._address_1 = GET_VALUE_STRING(tempDict, @"address_1");
                    }
                    if (IS_NOT_NULL(tempDict, @"address_2")) {
                        order._billing_address._address_2 = GET_VALUE_STRING(tempDict, @"address_2");
                    }
                    if (IS_NOT_NULL(tempDict, @"city")) {
                        order._billing_address._city = GET_VALUE_STRING(tempDict, @"city");
                    }
                    if (IS_NOT_NULL(tempDict, @"state")) {
                        order._billing_address._state = GET_VALUE_STRING(tempDict, @"state");
                    }
                    if (IS_NOT_NULL(tempDict, @"postcode")) {
                        order._billing_address._postcode = GET_VALUE_STRING(tempDict, @"postcode");
                    }
                    if (IS_NOT_NULL(tempDict, @"country")) {
                        order._billing_address._country = GET_VALUE_STRING(tempDict, @"country");
                    }
                    if (IS_NOT_NULL(tempDict, @"email")) {
                        order._billing_address._email = GET_VALUE_STRING(tempDict, @"email");
                    }
                    if (IS_NOT_NULL(tempDict, @"phone")) {
                        order._billing_address._phone = GET_VALUE_STRING(tempDict, @"phone");
                    }
                }
                if (IS_NOT_NULL(mainDict, @"shipping_address")) {
                    NSDictionary* tempDict = [mainDict objectForKey:@"shipping_address"];
                    
                    if (IS_NOT_NULL(tempDict, @"first_name")) {
                        order._shipping_address._first_name = GET_VALUE_STRING(tempDict, @"first_name");
                    }
                    if (IS_NOT_NULL(tempDict, @"last_name")) {
                        order._shipping_address._last_name = GET_VALUE_STRING(tempDict, @"last_name");
                    }
                    if (IS_NOT_NULL(tempDict, @"company")) {
                        order._shipping_address._company = GET_VALUE_STRING(tempDict, @"company");
                    }
                    if (IS_NOT_NULL(tempDict, @"address_1")) {
                        order._shipping_address._address_1 = GET_VALUE_STRING(tempDict, @"address_1");
                    }
                    if (IS_NOT_NULL(tempDict, @"address_2")) {
                        order._shipping_address._address_2 = GET_VALUE_STRING(tempDict, @"address_2");
                    }
                    if (IS_NOT_NULL(tempDict, @"city")) {
                        order._shipping_address._city = GET_VALUE_STRING(tempDict, @"city");
                    }
                    if (IS_NOT_NULL(tempDict, @"state")) {
                        order._shipping_address._state = GET_VALUE_STRING(tempDict, @"state");
                    }
                    if (IS_NOT_NULL(tempDict, @"postcode")) {
                        order._shipping_address._postcode = GET_VALUE_STRING(tempDict, @"postcode");
                    }
                    if (IS_NOT_NULL(tempDict, @"country")) {
                        order._shipping_address._country = GET_VALUE_STRING(tempDict, @"country");
                    }
                    if (IS_NOT_NULL(tempDict, @"email")) {
                        order._shipping_address._email = GET_VALUE_STRING(tempDict, @"email");
                    }
                    if (IS_NOT_NULL(tempDict, @"phone")) {
                        order._shipping_address._phone = GET_VALUE_STRING(tempDict, @"phone");
                    }
                }
                if (IS_NOT_NULL(mainDict, @"note")) {
                    order._note = GET_VALUE_STRING(mainDict, @"note");
                }
                if (IS_NOT_NULL(mainDict, @"customer_ip")) {
                    //            order._customer_iP = GET_VALUE_STRING(mainDict, @"customer_ip");
                }
                if (IS_NOT_NULL(mainDict, @"customer_user_agent")) {
                    //            order._customer_user_agent = GET_VALUE_STRING(mainDict, @"customer_user_agent");
                }
                if (IS_NOT_NULL(mainDict, @"customer_id")) {
                    order._customer_id = GET_VALUE_INT(mainDict, @"customer_id");
                }
                if (IS_NOT_NULL(mainDict, @"view_order_url")) {
                    order._view_order_url = GET_VALUE_STRING(mainDict, @"view_order_url");
                }
                if (IS_NOT_NULL(mainDict, @"line_items")) {
                    NSArray* tempArray = GET_VALUE_OBJECT(mainDict, @"line_items");
                    NSDictionary* tempDict = nil;
                    for (tempDict in tempArray) {
                        LineItem* lineItem = [[LineItem alloc] init];
                        if (IS_NOT_NULL(tempDict, @"id")) {
                            lineItem._id = GET_VALUE_INT(tempDict, @"id");
                        }
                        if (IS_NOT_NULL(tempDict, @"subtotal")) {
                            lineItem._subtotal = GET_VALUE_FLOAT(tempDict, @"subtotal");
                        }
                        if (IS_NOT_NULL(tempDict, @"subtotal_tax")) {
                            lineItem._subtotal_tax = GET_VALUE_FLOAT(tempDict, @"subtotal_tax");
                        }
                        if (IS_NOT_NULL(tempDict, @"total")) {
                            lineItem._total = GET_VALUE_FLOAT(tempDict, @"total");
                        }
                        if (IS_NOT_NULL(tempDict, @"total_tax")) {
                            lineItem._total_tax = GET_VALUE_FLOAT(tempDict, @"total_tax");
                        }
                        if (IS_NOT_NULL(tempDict, @"price")) {
                            lineItem._price = GET_VALUE_FLOAT(tempDict, @"price");
                        }
                        if (IS_NOT_NULL(tempDict, @"quantity")) {
                            lineItem._quantity = GET_VALUE_INT(tempDict, @"quantity");
                        }
                        if (IS_NOT_NULL(tempDict, @"tax_class")) {
                            lineItem._tax_class = GET_VALUE_STRING(tempDict, @"tax_class");
                        }
                        if (IS_NOT_NULL(tempDict, @"name")) {
                            lineItem._name = GET_VALUE_STRING(tempDict, @"name");
                        }
                        if (IS_NOT_NULL(tempDict, @"product_id")) {
                            lineItem._product_id = GET_VALUE_INT(tempDict, @"product_id");
                        }
                        if (IS_NOT_NULL(tempDict, @"sku")) {
                            lineItem._sku = GET_VALUE_STRING(tempDict, @"sku");
                        }
                        if (IS_NOT_NULL(tempDict, @"meta")) {
                            if (GET_VALUE_OBJECT(tempDict, @"meta")) {
                                NSArray* tempArrayMeta = GET_VALUE_OBJECT(tempDict, @"meta");
                                NSDictionary* tempDictMeta = nil;
                                for (tempDictMeta in tempArrayMeta) {
                                    ProductMetaItemProperties* pmip = [[ProductMetaItemProperties alloc] init];
                                    if (IS_NOT_NULL(tempDictMeta, @"key")) {
                                        pmip._key = GET_VALUE_STRING(tempDictMeta, @"key");
                                    }
                                    if (IS_NOT_NULL(tempDictMeta, @"value")) {
                                        pmip._value = GET_VALUE_STRING(tempDictMeta, @"value");
                                    }
                                    if (IS_NOT_NULL(tempDictMeta, @"label")) {
                                        pmip._label = GET_VALUE_STRING(tempDictMeta, @"label");
                                    }
                                    [lineItem._meta addObject:pmip];
                                }
                            }
                            
                        }
                        
                        [order._line_items addObject:lineItem];
                    }
                }
                if (IS_NOT_NULL(mainDict, @"shipping_lines")) {
                    [order._shipping_lines addObjectsFromArray:[mainDict objectForKey:@"shipping_lines"]] ;
                }
                if (IS_NOT_NULL(mainDict, @"tax_lines")) {
                    [order._tax_lines addObjectsFromArray:[mainDict objectForKey:@"tax_lines"]] ;
                }
                if (IS_NOT_NULL(mainDict, @"fee_lines")) {
                    [order._fee_lines addObjectsFromArray:[mainDict objectForKey:@"fee_lines"]] ;
                }
                if (IS_NOT_NULL(mainDict, @"coupon_lines")) {
                    [order._coupon_lines addObjectsFromArray:[mainDict objectForKey:@"coupon_lines"]] ;
                }
                if (IS_NOT_NULL(mainDict, @"customer")) {
                    NSDictionary* tempDict = [mainDict objectForKey:@"customer"];//TODO
                }
                
                //TODO ADD THIS OBJECT TO ?
                
                [appUser._ordersArray addObject:order];
            }
        }
    }
    RLOG(@"CategoryInfo Count========>%d", (int)[[CategoryInfo getAll] count]);
    RLOG(@"ProductInfo Count========>%d", (int)[[ProductInfo getAll] count]);
    RLOG(@"Orders Count========>%d", (int)[appUser._ordersArray count]);
    [appUser saveData];
}
- (void)loadCategoriesData:(NSDictionary *)dictionary {
    RLOG(@"<========LoadCategoryData Started");
    RLOG(@"CategoryInfo Count========>%d", (int)[[CategoryInfo getAll] count]);
    RLOG(@"ProductInfo Count========>%d", (int)[[ProductInfo getAll] count]);
    
    NSDictionary* headerDict = [dictionary objectForKey:@"product_categories"];
    NSDictionary* mainDict = nil;
    for (mainDict in headerDict) {
        CategoryInfo* category = [CategoryInfo getWithId:GET_VALUE_INT(mainDict, @"id")];
        if (IS_NOT_NULL(mainDict, @"id")) {
            category._id = GET_VALUE_INT(mainDict, @"id");
        }
        if (IS_NOT_NULL(mainDict, @"name")) {
            //            NSString * htmlString = GET_VALUE_STRING(mainDict, @"name");
            //            NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
            //            category._name = [[NSString alloc] initWithString: [attrStr string]];
            category._name = GET_VALUE_STRING(mainDict, @"name");
        }
        if (IS_NOT_NULL(mainDict, @"slug")) {
            category._slug = GET_VALUE_STRING(mainDict, @"slug");
        }
        if (IS_NOT_NULL(mainDict, @"parent")) {
            category._parentId = GET_VALUE_INT(mainDict, @"parent");
        }
        if (IS_NOT_NULL(mainDict, @"description")) {
            category._description = GET_VALUE_STRING(mainDict, @"description");
        }
        if (IS_NOT_NULL(mainDict, @"display")) {
            category._display = GET_VALUE_STRING(mainDict, @"display");
        }
        if (IS_NOT_NULL(mainDict, @"image")) {
            category._image = GET_VALUE_STRING(mainDict, @"image");
        }
        if (IS_NOT_NULL(mainDict, @"count")) {
            category._count = GET_VALUE_INT(mainDict, @"count");
        }
        
        category._parent = [CategoryInfo getWithId:category._parentId];
    }
    RLOG(@"<========LoadCategoryData Completed");
    RLOG(@"CategoryInfo Count========>%d", (int)[[CategoryInfo getAll] count]);
    RLOG(@"ProductInfo Count========>%d", (int)[[ProductInfo getAll] count]);
}
- (NSMutableArray*)loadProductsData:(NSDictionary *)dictionary {
    RLOG(@"<========LoadProductData Started");
    RLOG(@"CategoryInfo Count========>%d", (int)[[CategoryInfo getAll] count]);
    RLOG(@"ProductInfo Count========>%d", (int)[[ProductInfo getAll] count]);
    
    NSDictionary* headerDict = [dictionary objectForKey:@"products"];
    NSDictionary* mainDict = nil;
    for (mainDict in headerDict) {
        ProductInfo* p = [[ProductInfo alloc] init];
        if (IS_NOT_NULL(mainDict, @"title")) {
            p._title = GET_VALUE_STRING(mainDict, @"title");
        }
        if (IS_NOT_NULL(mainDict, @"id")) {
            p._id = GET_VALUE_INT(mainDict, @"id");
        }
        if (IS_NOT_NULL(mainDict, @"type")) {
            NSString* productType = GET_VALUE_STRING(mainDict, @"type");
            if ([productType isEqualToString:@"simple"]) {
                p._type = PRODUCT_TYPE_SIMPLE;
            }
            if ([productType isEqualToString:@"grouped"]) {
                p._type = PRODUCT_TYPE_GROUPED;
            }
            if ([productType isEqualToString:@"external"]) {
                p._type = PRODUCT_TYPE_EXTERNAL_OR_AFFILIATE;
            }
            if ([productType isEqualToString:@"variable"]) {
                p._type = PRODUCT_TYPE_VARIABLE;
            }
        }
        if (IS_NOT_NULL(mainDict, @"status")) {
            p._status = GET_VALUE_STRING(mainDict, @"status");
        }
        if (IS_NOT_NULL(mainDict, @"downloadable")) {
            p._downloadable = GET_VALUE_BOOL(mainDict, @"downloadable");
        }
        if (IS_NOT_NULL(mainDict, @"virtual")) {
            p._virtual = GET_VALUE_BOOL(mainDict, @"virtual");
        }
        if (IS_NOT_NULL(mainDict, @"permalink")) {
            p._permalink = GET_VALUE_STRING(mainDict, @"permalink");
        }
        if (IS_NOT_NULL(mainDict, @"sku")) {
            p._sku = GET_VALUE_STRING(mainDict, @"sku");
        }
        if (IS_NOT_NULL(mainDict, @"price")) {
            p._price = GET_VALUE_FLOAT(mainDict, @"price");
        }
        if (IS_NOT_NULL(mainDict, @"regular_price")) {
            p._regular_price = GET_VALUE_FLOAT(mainDict, @"regular_price");
        }
        if (IS_NOT_NULL(mainDict, @"sale_price")) {
            p._sale_price = GET_VALUE_FLOAT(mainDict, @"sale_price");
        }
        {
            float priceToUse = p._regular_price != 0 ? p._regular_price : p._price;
            float discountPrice = p._sale_price != 0? (priceToUse - p._sale_price) : 0;
            if (discountPrice > 0) {
                p._discount = discountPrice*100.0f/priceToUse;
            } else {
                p._discount = 0;
            }
        }
        if (IS_NOT_NULL(mainDict, @"price_html")) {
            p._price_html = GET_VALUE_STRING(mainDict, @"price_html");//AttributedString
        }
        if (IS_NOT_NULL(mainDict, @"taxable")) {
            p._taxable = GET_VALUE_BOOL(mainDict, @"taxable");
        }
        if (IS_NOT_NULL(mainDict, @"tax_status")) {
            p._tax_status = GET_VALUE_STRING(mainDict, @"tax_status");
        }
        if (IS_NOT_NULL(mainDict, @"tax_class")) {
            p._tax_class = GET_VALUE_STRING(mainDict, @"tax_class");
        }
        if (IS_NOT_NULL(mainDict, @"managing_stock")) {
            p._managing_stock = GET_VALUE_BOOL(mainDict, @"managing_stock");
        }
        if (IS_NOT_NULL(mainDict, @"stock_quantity")) {
            p._stock_quantity = GET_VALUE_INT(mainDict, @"stock_quantity");
        }
        if (IS_NOT_NULL(mainDict, @"in_stock")) {
            p._in_stock = GET_VALUE_BOOL(mainDict, @"in_stock");
        }
        if (IS_NOT_NULL(mainDict, @"backorders_allowed")) {
            p._backorders_allowed = GET_VALUE_BOOL(mainDict, @"backorders_allowed");
        }
        if (IS_NOT_NULL(mainDict, @"backordered")) {
            p._backordered = GET_VALUE_BOOL(mainDict, @"backordered");
        }
        if (IS_NOT_NULL(mainDict, @"sold_individually")) {
            p._sold_individually = GET_VALUE_BOOL(mainDict, @"sold_individually");
        }
        if (IS_NOT_NULL(mainDict, @"purchaseable")) {
            p._purchaseable = GET_VALUE_BOOL(mainDict, @"purchaseable");
        }
        if (IS_NOT_NULL(mainDict, @"featured")) {
            p._featured = GET_VALUE_BOOL(mainDict, @"featured");
        }
        if (IS_NOT_NULL(mainDict, @"visible")) {
            p._visible = GET_VALUE_BOOL(mainDict, @"visible");
        }
        if (IS_NOT_NULL(mainDict, @"catalog_visibility")) {
            //            p._catalog_visibility = GET_VALUE_STRING(mainDict, @"catalog_visibility");
        }
        if (IS_NOT_NULL(mainDict, @"on_sale")) {
            p._on_sale = GET_VALUE_BOOL(mainDict, @"on_sale");
        }
        if (IS_NOT_NULL(mainDict, @"product_url")) {
            p._product_url = GET_VALUE_STRING(mainDict, @"product_url");
        }
        if (IS_NOT_NULL(mainDict, @"button_text")) {
            //            p._button_text = GET_VALUE_STRING(mainDict, @"button_text");
        }
        if (IS_NOT_NULL(mainDict, @"weight")) {
            //            p._weight = GET_VALUE_STRING(mainDict, @"weight");//DOUBT
        }
        if (IS_NOT_NULL(mainDict, @"dimensions")) {
            NSDictionary* tempDict = [mainDict objectForKey:@"dimensions"];
            if (IS_NOT_NULL(tempDict, @"height")) {
                p._dimensions._height = GET_VALUE_FLOAT(tempDict, @"height");
            }
            if (IS_NOT_NULL(tempDict, @"width")) {
                p._dimensions._width = GET_VALUE_FLOAT(tempDict, @"width");
            }
            if (IS_NOT_NULL(tempDict, @"length")) {
                p._dimensions._length = GET_VALUE_FLOAT(tempDict, @"length");
            }
            if (IS_NOT_NULL(tempDict, @"unit")) {
                p._dimensions._unit = GET_VALUE_STRING(tempDict, @"unit");
            }
        }
        if (IS_NOT_NULL(mainDict, @"shipping_required")) {
            p._shipping_required = GET_VALUE_BOOL(mainDict, @"shipping_required");
        }
        if (IS_NOT_NULL(mainDict, @"shipping_taxable")) {
            p._shipping_taxable = GET_VALUE_BOOL(mainDict, @"shipping_taxable");
        }
        if (IS_NOT_NULL(mainDict, @"shipping_class")) {
            p._shipping_class = GET_VALUE_STRING(mainDict, @"shipping_class");
        }
        if (IS_NOT_NULL(mainDict, @"shipping_class_id")) {
            p._shipping_class_id = GET_VALUE_INT(mainDict, @"shipping_class_id");
        }
        if (IS_NOT_NULL(mainDict, @"description")) {
            p._description = GET_VALUE_STRING(mainDict, @"description");//A
        }
        if (IS_NOT_NULL(mainDict, @"short_description")) {
            p._short_description = GET_VALUE_STRING(mainDict, @"short_description");//A
        }
        if (IS_NOT_NULL(mainDict, @"reviews_allowed")) {
            p._reviews_allowed = GET_VALUE_BOOL(mainDict, @"reviews_allowed");
        }
        if (IS_NOT_NULL(mainDict, @"average_rating")) {
            p._average_rating = GET_VALUE_FLOAT(mainDict, @"average_rating");
        }
        if (IS_NOT_NULL(mainDict, @"rating_count")) {
            p._rating_count = GET_VALUE_INT(mainDict, @"rating_count");
        }
        if (IS_NOT_NULL(mainDict, @"related_ids")) {
            [p._related_ids addObjectsFromArray:[mainDict objectForKey:@"related_ids"]] ;
        }
        if (IS_NOT_NULL(mainDict, @"upsell_ids")) {
            [p._upsell_ids addObjectsFromArray:[mainDict objectForKey:@"upsell_ids"]] ;
        }
        if (IS_NOT_NULL(mainDict, @"cross_sell_ids")) {
            [p._cross_sell_ids addObjectsFromArray:[mainDict objectForKey:@"cross_sell_ids"]] ;
        }
        if (IS_NOT_NULL(mainDict, @"parent_id")) {
            p._parent_id = GET_VALUE_INT(mainDict, @"parent_id");
        }
        if (IS_NOT_NULL(mainDict, @"categories")) {
            [p._categories removeAllObjects];
            NSArray* mtempArray = [mainDict objectForKey:@"categories"];
            p._categoriesNames = [[NSMutableArray alloc] initWithArray:mtempArray];
            for (NSString* cateogoryName in mtempArray) {
                CategoryInfo* ccinfo = [CategoryInfo getWithName:cateogoryName];
                if (ccinfo) {
                    if ([p._categories containsObject:ccinfo] == false) {
                        [p._categories addObject:ccinfo];
                        [p addInAllParentCategory:ccinfo];
                    }
                }
            }
        }
        if (IS_NOT_NULL(mainDict, @"tags")) {
            [p._tags addObjectsFromArray:[mainDict objectForKey:@"tags"]] ;
        }
        if (IS_NOT_NULL(mainDict, @"images")) {
            NSArray* tempArray = [mainDict objectForKey:@"images"];
            NSDictionary* tempDict = nil;
            for (tempDict in tempArray) {
                ProductImage* pImage = [[ProductImage alloc] init];
                if (IS_NOT_NULL(tempDict, @"id")) {
                    pImage._id = GET_VALUE_INT(tempDict, @"id");
                }
                if (IS_NOT_NULL(tempDict, @"alt")) {
                    pImage._alt = GET_VALUE_STRING(tempDict, @"alt");
                }
                if (IS_NOT_NULL(tempDict, @"position")) {
                    pImage._position = GET_VALUE_INT(tempDict, @"position");
                }
                if (IS_NOT_NULL(tempDict, @"src")) {
                    pImage._src = GET_VALUE_STRING(tempDict, @"src");
                }
                if (IS_NOT_NULL(tempDict, @"title")) {
                    pImage._title = GET_VALUE_STRING(tempDict, @"title");
                }
                [p._images addObject:pImage];
            }
        }
        if (IS_NOT_NULL(mainDict, @"featured_src")) {
            p._featured_src = GET_VALUE_STRING(mainDict, @"featured_src");
        }
        if (IS_NOT_NULL(mainDict, @"attributes")) {
            NSArray* tempArray = [mainDict objectForKey:@"attributes"];
            NSDictionary* tempDict = nil;
            for (tempDict in tempArray) {
                Attribute* attribute = [[Attribute alloc] init];
                if (IS_NOT_NULL(tempDict, @"name")) {
                    attribute._name = GET_VALUE_STRING(tempDict, @"name");
                }
                if (IS_NOT_NULL(tempDict, @"options")) {
                    [attribute._options addObjectsFromArray:[tempDict objectForKey:@"options"]] ;
                }
                if (IS_NOT_NULL(tempDict, @"position")) {
                    attribute._position = GET_VALUE_INT(tempDict, @"position");
                }
                if (IS_NOT_NULL(tempDict, @"slug")) {
                    attribute._slug = GET_VALUE_STRING(tempDict, @"slug");
                }
                if (IS_NOT_NULL(tempDict, @"variation")) {
                    attribute._variation = GET_VALUE_BOOL(tempDict, @"variation");
                }
                if (IS_NOT_NULL(tempDict, @"visible")) {
                    attribute._visible = GET_VALUE_BOOL(tempDict, @"visible");
                }
                [p._attributes addObject:attribute];
            }
        }
        if (IS_NOT_NULL(mainDict, @"downloads")) {
            [p._downloads addObjectsFromArray:[mainDict objectForKey:@"downloads"]] ;
        }
        if (IS_NOT_NULL(mainDict, @"download_limit")) {
            p._download_limit = GET_VALUE_INT(mainDict, @"download_limit");
        }
        if (IS_NOT_NULL(mainDict, @"download_expiry")) {
            p._download_expiry = GET_VALUE_INT(mainDict, @"download_expiry");
        }
        if (IS_NOT_NULL(mainDict, @"download_type")) {
            p._download_type = GET_VALUE_STRING(mainDict, @"download_type");
        }
        if (IS_NOT_NULL(mainDict, @"purchase_note")) {
            p._purchase_note = GET_VALUE_STRING(mainDict, @"purchase_note");
        }
        if (IS_NOT_NULL(mainDict, @"total_sales")) {
            p._total_sales = GET_VALUE_INT(mainDict, @"total_sales");
        }
        if (IS_NOT_NULL(mainDict, @"created_at")) {
            NSDateFormatter* df = [[NSDateFormatter alloc]init];
            [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
            NSString* str = GET_VALUE_STRING(mainDict, @"created_at");
            p._created_at = [df dateFromString:str];
        }
        if (IS_NOT_NULL(mainDict, @"updated_at")) {
            NSDateFormatter* df = [[NSDateFormatter alloc]init];
            [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
            NSString* str = GET_VALUE_STRING(mainDict, @"updated_at");
            p._updated_at = [df dateFromString:str];
        }
        
        if (IS_NOT_NULL(mainDict, @"variations")) {
            NSArray* tempArray = [mainDict objectForKey:@"variations"];
            NSDictionary* tempDict = nil;
            for (tempDict in tempArray) {
                Variation* variation = [[Variation alloc] init];//TODO
                if (IS_NOT_NULL(tempDict, @"id")) {
                    variation._id = GET_VALUE_INT(tempDict, @"id");
                }
                if (IS_NOT_NULL(tempDict, @"created_at")) {
                    NSDateFormatter* df = [[NSDateFormatter alloc]init];
                    [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
                    NSString* str = GET_VALUE_STRING(tempDict, @"created_at");
                    variation._created_at = [df dateFromString:str];
                }
                if (IS_NOT_NULL(tempDict, @"updated_at")) {
                    NSDateFormatter* df = [[NSDateFormatter alloc]init];
                    [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
                    NSString* str = GET_VALUE_STRING(tempDict, @"updated_at");
                    variation._updated_at = [df dateFromString:str];
                }
                if (IS_NOT_NULL(tempDict, @"downloadable")) {
                    variation._downloadable = GET_VALUE_BOOL(tempDict, @"downloadable");
                }
                if (IS_NOT_NULL(tempDict, @"virtual")) {
                    variation._virtual = GET_VALUE_BOOL(tempDict, @"virtual");
                }
                if (IS_NOT_NULL(tempDict, @"permalink")) {
                    variation._permalink = GET_VALUE_STRING(tempDict, @"permalink");
                }
                if (IS_NOT_NULL(tempDict, @"sku")) {
                    variation._sku = GET_VALUE_STRING(tempDict, @"sku");
                }
                if (IS_NOT_NULL(tempDict, @"price")) {
                    variation._price = GET_VALUE_FLOAT(tempDict, @"price");
                }
                if (IS_NOT_NULL(tempDict, @"regular_price")) {
                    variation._regular_price = GET_VALUE_FLOAT(tempDict, @"regular_price");
                }
                if (IS_NOT_NULL(tempDict, @"sale_price")) {
                    variation._sale_price = GET_VALUE_FLOAT(tempDict, @"sale_price");
                }
                if (IS_NOT_NULL(tempDict, @"taxable")) {
                    variation._taxable = GET_VALUE_BOOL(tempDict, @"taxable");
                }
                if (IS_NOT_NULL(tempDict, @"tax_status")) {
                    variation._tax_status = GET_VALUE_STRING(tempDict, @"tax_status");
                }
                if (IS_NOT_NULL(tempDict, @"tax_class")) {
                    variation._tax_class = GET_VALUE_STRING(tempDict, @"tax_class");
                }
                if (IS_NOT_NULL(tempDict, @"managing_stock")) {
                    variation._managing_stock = GET_VALUE_BOOL(tempDict, @"managing_stock");
                }
                if (IS_NOT_NULL(tempDict, @"stock_quantity")) {
                    variation._stock_quantity = GET_VALUE_INT(tempDict, @"stock_quantity");
                }
                if (IS_NOT_NULL(tempDict, @"in_stock")) {
                    variation._in_stock = GET_VALUE_BOOL(tempDict, @"in_stock");
                }
                if (IS_NOT_NULL(tempDict, @"backordered")) {
                    variation._backordered = GET_VALUE_BOOL(tempDict, @"backordered");
                }
                if (IS_NOT_NULL(tempDict, @"purchaseable")) {
                    variation._purchaseable = GET_VALUE_BOOL(tempDict, @"purchaseable");
                }
                if (IS_NOT_NULL(tempDict, @"visible")) {
                    variation._visible = GET_VALUE_BOOL(tempDict, @"visible");
                }
                if (IS_NOT_NULL(tempDict, @"on_sale")) {
                    variation._on_sale = GET_VALUE_BOOL(tempDict, @"on_sale");
                }
                if (IS_NOT_NULL(tempDict, @"weight")) {
                    variation._weight = GET_VALUE_FLOAT(tempDict, @"weight");
                }
                if (IS_NOT_NULL(tempDict, @"dimensions")) {
                    NSDictionary* mtempDict = [tempDict objectForKey:@"dimensions"];
                    if (IS_NOT_NULL(mtempDict, @"height")) {
                        variation._dimensions._height = GET_VALUE_FLOAT(mtempDict, @"height");
                    }
                    if (IS_NOT_NULL(mtempDict, @"width")) {
                        variation._dimensions._width = GET_VALUE_FLOAT(mtempDict, @"width");
                    }
                    if (IS_NOT_NULL(mtempDict, @"length")) {
                        variation._dimensions._length = GET_VALUE_FLOAT(mtempDict, @"length");
                    }
                    if (IS_NOT_NULL(mtempDict, @"unit")) {
                        variation._dimensions._unit = GET_VALUE_STRING(mtempDict, @"unit");
                    }
                }
                if (IS_NOT_NULL(tempDict, @"shipping_class")) {
                    variation._shipping_class = GET_VALUE_STRING(tempDict, @"shipping_class");
                }
                if (IS_NOT_NULL(tempDict, @"shipping_class_id")) {
                    variation._shipping_class_id = GET_VALUE_STRING(tempDict, @"shipping_class_id");
                }
                if (IS_NOT_NULL(tempDict, @"image")) {
                    NSArray* mtempArray = [tempDict objectForKey:@"image"];
                    NSDictionary* mtempDict = nil;
                    for (mtempDict in mtempArray) {
                        ProductImage* pImage = [[ProductImage alloc] init];
                        if (IS_NOT_NULL(mtempDict, @"id")) {
                            pImage._id = GET_VALUE_INT(mtempDict, @"id");
                        }
                        if (IS_NOT_NULL(mtempDict, @"alt")) {
                            pImage._alt = GET_VALUE_STRING(mtempDict, @"alt");
                        }
                        if (IS_NOT_NULL(mtempDict, @"position")) {
                            pImage._position = GET_VALUE_INT(mtempDict, @"position");
                        }
                        if (IS_NOT_NULL(mtempDict, @"src")) {
                            pImage._src = GET_VALUE_STRING(mtempDict, @"src");
                        }
                        if (IS_NOT_NULL(mtempDict, @"title")) {
                            pImage._title = GET_VALUE_STRING(mtempDict, @"title");
                        }
                        [variation._images addObject:pImage];
                    }
                }
                
                if (IS_NOT_NULL(tempDict, @"attributes")) {
                    NSArray* mtempArray = [tempDict objectForKey:@"attributes"];
                    NSDictionary* mtempDict = nil;
                    for (mtempDict in mtempArray) {
                        Attribute* attribute = [[Attribute alloc] init];
                        if (IS_NOT_NULL(mtempDict, @"name")) {
                            attribute._name = GET_VALUE_STRING(mtempDict, @"name");
                        }
                        if (IS_NOT_NULL(mtempDict, @"option")) {
                            [attribute._options addObject:GET_VALUE_STRING(mtempDict, @"option")] ;
                        }
                        if (IS_NOT_NULL(mtempDict, @"position")) {
                            attribute._position = GET_VALUE_INT(mtempDict, @"position");
                        }
                        if (IS_NOT_NULL(mtempDict, @"slug")) {
                            attribute._slug = GET_VALUE_STRING(mtempDict, @"slug");
                        }
                        if (IS_NOT_NULL(mtempDict, @"variation")) {
                            attribute._variation = GET_VALUE_BOOL(mtempDict, @"variation");
                        }
                        if (IS_NOT_NULL(mtempDict, @"visible")) {
                            attribute._visible = GET_VALUE_BOOL(mtempDict, @"visible");
                        }
                        [variation._attributes addObject:attribute];
                    }
                }
                if (IS_NOT_NULL(tempDict, @"downloads")) {
                    [variation._downloads addObjectsFromArray:[tempDict objectForKey:@"downloads"]] ;
                }
                if (IS_NOT_NULL(tempDict, @"download_limit")) {
                    variation._download_limit = GET_VALUE_INT(tempDict, @"download_limit");
                }
                if (IS_NOT_NULL(tempDict, @"download_expiry")) {
                    variation._download_expiry = GET_VALUE_INT(tempDict, @"download_expiry");
                }
                [p._variations addObject:variation];
            }
        }
        if (IS_NOT_NULL(mainDict, @"parent")) {
            //            [p._parent addObjectsFromArray:[mainDict objectForKey:@"parent"]] ;
        }
    }
    
    RLOG(@"<========LoadProductData Completed");
    RLOG(@"CategoryInfo Count========>%d", (int)[[CategoryInfo getAll] count]);
    RLOG(@"ProductInfo Count========>%d", (int)[[ProductInfo getAll] count]);
    
    [CategoryInfo refineCategories];
    RLOG(@"<========LoadCategoryData Completed");
    RLOG(@"CategoryInfo Count========>%d", (int)[[CategoryInfo getAll] count]);
    RLOG(@"ProductInfo Count========>%d", (int)[[ProductInfo getAll] count]);
    return nil;
}
- (void)loadCommonData:(NSDictionary *)dictionary {
    CommonInfo *commonInfo = [CommonInfo sharedManager];
    
    NSDictionary* mainDict = nil;
    if (IS_NOT_NULL(dictionary, @"store")) {
        mainDict = [dictionary objectForKey:@"store"];
    }else {
        RLOG(@"=====DATA NOT FOUND===== in method loadCommonData");
        return;
    }
    
    NSDictionary* metaDict = nil;
    if (IS_NOT_NULL(mainDict, @"meta")) {
        metaDict = [mainDict objectForKey:@"meta"];
        
        if (IS_NOT_NULL(metaDict, @"timezone")) {
            commonInfo->_timezone = GET_VALUE_STRING(metaDict, @"timezone");
        }
        if (IS_NOT_NULL(metaDict, @"currency")) {
            commonInfo->_currency = GET_VALUE_STRING(metaDict, @"currency");
        }
        if (IS_NOT_NULL(metaDict, @"currency_format")) {
            commonInfo->_currency_format = GET_VALUE_STRING(metaDict, @"currency_format");
        }
        if (IS_NOT_NULL(metaDict, @"currency_position")) {
            commonInfo->_currency_position = GET_VALUE_STRING(metaDict, @"currency_position");
        }
        if (IS_NOT_NULL(metaDict, @"thousand_separator")) {
            commonInfo->_thousand_separator = GET_VALUE_STRING(metaDict, @"thousand_separator");
        }
        if (IS_NOT_NULL(metaDict, @"decimal_separator")) {
            commonInfo->_decimal_separator = GET_VALUE_STRING(metaDict, @"decimal_separator");
        }
        if (IS_NOT_NULL(metaDict, @"price_num_decimals")) {
            commonInfo->_price_num_decimals = GET_VALUE_INT(metaDict, @"price_num_decimals");
        }
        if (IS_NOT_NULL(metaDict, @"tax_included")) {
            commonInfo->_tax_included = GET_VALUE_BOOL(metaDict, @"tax_included");
        }
        if (IS_NOT_NULL(metaDict, @"weight_unit")) {
            commonInfo->_weight_unit = GET_VALUE_STRING(metaDict, @"weight_unit");
        }
        if (IS_NOT_NULL(metaDict, @"dimension_unit")) {
            commonInfo->_dimension_unit = GET_VALUE_STRING(metaDict, @"dimension_unit");
        }
        
    }
}

@end
