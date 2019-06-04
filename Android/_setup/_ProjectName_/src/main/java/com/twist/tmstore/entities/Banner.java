package com.twist.tmstore.entities;

import android.view.View;

import com.twist.dataengine.DataQueryHandler;
import com.twist.dataengine.entities.TM_ProductInfo;
import com.twist.tmstore.MainActivity;
import com.utils.AnalyticsHelper;
import com.utils.Helper;

/**
 * Created by Twist Mobile on 4/18/2016.
 */
public class Banner implements View.OnClickListener {
    private enum BannerType {
        BANNER_SIMPLE(0),
        BANNER_CATEGORY(1),
        BANNER_PRODUCT(2),
        BANNER_CART(3),
        BANNER_WISHLIST(4);

        private final int i;

        BannerType(int i) {
            this.i = i;
        }

        public int getNumber() {
            return i;
        }
    }

    public int type;
    public int id;
    public String img_url;

    @Override
    public void onClick(final View v) {
        switch (BannerType.values()[type]) {
            case BANNER_CATEGORY: {
                MainActivity.mActivity.expandCategory(id);
                AnalyticsHelper.registerClickBannerEvent(BannerType.BANNER_CATEGORY.name(), id);
                break;
            }
            case BANNER_PRODUCT: {
                AnalyticsHelper.registerClickBannerEvent(BannerType.BANNER_PRODUCT.name(), id);
                TM_ProductInfo product = TM_ProductInfo.findProductById(id);
                if (product != null) {
                    if (product.type == TM_ProductInfo.ProductType.EXTERNAL) {
                        Helper.openExternalLink(v.getContext(), product.product_url);
                    } else {
                        MainActivity.mActivity.openProductInfo(product);
                    }

                } else {
                    MainActivity.mActivity.loadProductInfo(this.id, new DataQueryHandler<TM_ProductInfo>() {
                        @Override
                        public void onSuccess(TM_ProductInfo product) {
                            if (product.type == TM_ProductInfo.ProductType.EXTERNAL) {
                                Helper.openExternalLink(v.getContext(), product.product_url);
                            } else {
                                MainActivity.mActivity.openProductInfo(product);
                            }
                        }

                        @Override
                        public void onFailure(Exception error) {
                        }
                    });
                }
                break;
            }
            case BANNER_CART: {
                AnalyticsHelper.registerClickBannerEvent(BannerType.BANNER_CART.name(), 0);
                MainActivity.mActivity.openCartFragment();
                break;
            }
            case BANNER_WISHLIST: {
                AnalyticsHelper.registerClickBannerEvent(BannerType.BANNER_WISHLIST.name(), 0);
                MainActivity.mActivity.openWishlistFragment(false);
                break;
            }
        }
    }
}