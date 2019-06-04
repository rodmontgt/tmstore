//
//  ProductCollectionViewCell.m
//  TMStore
//
//  Created by Rajshekhar on 19/07/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import "ProductCollectionViewCell.h"
#import "ViewControllerUploadProduct.h"
#import "Utility.h"
#import "DataManager.h"
#import "SellerZoneManager.h"
#import "VCProducts.h"
@implementation ProductCollectionViewCell
{
    MRProgressOverlayView* mov;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    [self.contentView setBackgroundColor:[Utility getUIColor:kUIColorBgTheme]];

}
- (IBAction)buttonOptionAction:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:Localize(@"title_seller_zone_delete_product") otherButtonTitles:Localize(@"title_seller_zone_edit_product"), nil];

    if ([[MyDevice sharedManager] isIpad]) {
        // In this case the device is an iPad.
        [actionSheet showFromRect:[(UIButton *)sender frame] inView:self animated:YES];
    }
    else{
        // In this case the device is an iPhone/iPod Touch.
        [actionSheet showInView:self];
    }

}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
}
- (void)deleteProduct {
    [[[DataManager sharedManager] tmDataDoctor] deleteProduct:((ProductInfo*)(self.productObj))._id success:^(NSString *msg) {
        NSString* successMsg = Localize(@"product_deleted");
        if (msg && ![msg isEqualToString:@""]) {
            successMsg = msg;
        }
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:successMsg delegate:self cancelButtonTitle:Localize(@"i_ok") otherButtonTitles:nil, nil];
        [alert show];
        
        UICollectionView* collectionView = (UICollectionView*)(self.superview);
        NSIndexPath *indexPath = [collectionView indexPathForCell:self];
        [collectionView performBatchUpdates:^{
            SellerInfo* sInfo = ((ProductInfo*)(self.productObj)).sellerInfo;
            [sInfo.sellerProducts removeObject:self.productObj];
            [[ProductInfo getAll] removeObject:self.productObj];
            [collectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
        } completion:^(BOOL finished) {
            
        }];
    } failure:^(NSString *msg) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error!" message:Localize(@"product_delete_error") delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Retry", nil];
        [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [self deleteProduct];
            }
        }];
    }];
}
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self deleteProduct];
    } else if (buttonIndex == 1){
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NOTIFY_PRODUCT_LOADED" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OnProductDataFetched:) name:@"NOTIFY_PRODUCT_LOADED" object:nil];
        
         mov = [Utility createCustomizedLoadingBar:Localize(@"i_loading_data") isBottomAlign:false isClearViewEnabled:false isShadowEnabled:true];
        [mov.titleLabel setUIFont:kUIFontType18 isBold:false];

        [[DataManager sharedManager] fetchSingleProductData:nil productId:((ProductInfo*)self.productObj)._id];
        NSLog(@"product_id %d",((ProductInfo*)self.productObj)._id);
      }
}
-(void)OnProductDataFetched:(NSNotification*)notification{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NOTIFY_PRODUCT_LOADED" object:nil];
    [mov dismiss:true];
    ViewControllerUploadProduct *vcUploadProduct=[[ViewControllerUploadProduct alloc] initWithNibName:@"ViewControllerUploadProduct" bundle:nil];
    [vcUploadProduct setData:self.productObj];
     NSLog(@"product_id %d",((ProductInfo*)self.productObj)._id);
    [self.parentVC presentViewController:vcUploadProduct animated:YES completion:nil];
}
@end
