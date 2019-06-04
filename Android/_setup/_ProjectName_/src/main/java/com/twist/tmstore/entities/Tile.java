package com.twist.tmstore.entities;

import android.view.View;

import com.twist.tmstore.MainActivity;

import java.util.Collections;
import java.util.List;

/**
 * Created by Twist Mobile on 6/21/2016.
 */
public class Tile implements View.OnClickListener{

    public enum TileType {
        TILE_SIMPLE(0), TILE_CATEGORY(1), TILE_PRODUCT(2), TILE_CART(3), TILE_WISHLIST(4);
        private final int i;
        TileType(int i){
            this.i=i;
        }
        public int getNumber(){
            return i;
        }
    }

    public int type;
    public int id;
    public int colSpan = 1;
    public String img_url;
    public String title;

    @Override
    public void onClick(View v) {
        switch (TileType.values()[type]) {
            case TILE_CATEGORY: {
                MainActivity.mActivity.expandCategory(id);
                break;
            }
            case TILE_PRODUCT: {
                MainActivity.mActivity.openOrLoadProductInfo(this.id);
                break;
            }
            case TILE_CART: {
                MainActivity.mActivity.openCartFragment();
                break;
            }
            case TILE_WISHLIST: {
                MainActivity.mActivity.openWishlistFragment(false);
                break;
            }
            default:
                //nothing. :)
                break;
        }
    }

    public static Class<List<Tile>> getListClassType() {
        return (Class<List<Tile>>) Collections.<Tile>emptyList().getClass();
    }
}