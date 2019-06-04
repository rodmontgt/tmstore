package com.twist.tmstore.listeners;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.support.v7.widget.PopupMenu;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;

import com.twist.dataengine.DataEngine;
import com.twist.dataengine.DataQueryHandler;
import com.twist.dataengine.entities.TM_ProductInfo;
import com.twist.tmstore.L;
import com.twist.tmstore.MainActivity;
import com.utils.Helper;

;

/**
 * Created by Twist Mobile on 10-01-2017.
 */

public class OnOverflowSelectedListener implements View.OnClickListener {
    private final Activity mContext;
    private final TM_ProductInfo product;
    private final DataQueryHandler dataQueryHandler;
    private final ProgressDialog progressDialog;

    public OnOverflowSelectedListener(Activity context, TM_ProductInfo tm_productInfo, DataQueryHandler dataQueryHandler, ProgressDialog progressDialog) {
        mContext = context;
        product = tm_productInfo;
        this.dataQueryHandler = dataQueryHandler;
        this.progressDialog = progressDialog;

    }

    @Override
    public void onClick(View v) {
        final int MENU_ITEM_EDIT = 100;
        final int MENU_ITEM_DELETE = 101;

        PopupMenu popup = new PopupMenu(mContext, v);
        popup.getMenu().add(Menu.FLAG_APPEND_TO_GROUP, MENU_ITEM_EDIT, Menu.NONE, L.getString(L.string.title_seller_zone_edit_product));
        popup.getMenu().add(Menu.FLAG_APPEND_TO_GROUP, MENU_ITEM_DELETE, Menu.NONE, L.getString(L.string.title_seller_zone_delete_product));
        popup.setOnMenuItemClickListener(new PopupMenu.OnMenuItemClickListener() {
            public boolean onMenuItemClick(MenuItem item) {
                switch (item.getItemId()) {
                    case MENU_ITEM_EDIT:
                        MainActivity.mActivity.showEditProduct(product.id);
                        return true;
                    case MENU_ITEM_DELETE:
                        Helper.getConfirmation(mContext, L.getString(L.string.seller_zone_delete_product_confirmation), new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface dialogInterface, int i) {
                                showProgress(L.getString(L.string.please_wait));
                                DataEngine.getDataEngine().deleteProductInBackground(product.id, dataQueryHandler);
                            }
                        });
                        return true;
                    default:
                        return false;
                }
            }
        });
        popup.show();
    }

    public void showProgress(String message) {
        progressDialog.setCancelable(false);
        progressDialog.setMessage(message);
        progressDialog.show();
    }
}
