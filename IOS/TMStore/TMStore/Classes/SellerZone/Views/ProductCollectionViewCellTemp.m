//
//  ProductCollectionViewCellTemp.m
//  TMStore
//
//  Created by Rajshekhar on 19/07/17.
//  Copyright © 2017 Twist Mobile. All rights reserved.
//

#import "ProductCollectionViewCellTemp.h"
#import "ViewControllerUploadProduct.h"
#import "Utility.h"
#import "DataManager.h"
#import "SellerZoneManager.h"
@implementation ProductCollectionViewCellTemp

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.contentView setBackgroundColor:[Utility getUIColor:kUIColorBgTheme]];

}
- (IBAction)buttonWishlistAction:(id)sender {
//    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"What do you want to do with the file?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:@"Edit", nil];
//    
//    if ([[MyDevice sharedManager] isIpad]) {
//        // In this case the device is an iPad.
//        [actionSheet showFromRect:[(UIButton *)sender frame] inView:self animated:YES];
//    }
//    else{
//        // In this case the device is an iPhone/iPod Touch.
//        [actionSheet showInView:self];
//    }
    
}
- (IBAction)buttonOptionAction:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"What do you want to do with the file?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:@"Edit", nil];

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
        NSString* successMsg = @"Product deletion completed.";
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
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error!" message:@"Product deleting failed. Please retry." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Retry", nil];
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
    }else if (buttonIndex == 1){
        ViewControllerUploadProduct *vcUploadProduct=[[ViewControllerUploadProduct alloc] initWithNibName:@"ViewControllerUploadProduct" bundle:nil];
        [vcUploadProduct setData:self.productObj];
        [self.parentVC presentViewController:vcUploadProduct animated:YES completion:nil];
    }
}


@end
