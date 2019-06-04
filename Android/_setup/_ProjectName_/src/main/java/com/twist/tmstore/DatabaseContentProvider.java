package com.twist.tmstore;

import com.activeandroid.Configuration;
import com.activeandroid.content.ContentProvider;
import com.twist.tmstore.entities.Address;
import com.twist.tmstore.entities.AppUser;
import com.twist.tmstore.entities.Cart;
import com.twist.tmstore.entities.GhostCart;
import com.twist.tmstore.entities.Notification;
import com.twist.tmstore.entities.RecentMerchant;
import com.twist.tmstore.entities.RecentSearchItem;
import com.twist.tmstore.entities.RecentlyViewedItem;
import com.twist.tmstore.entities.WishListGroup;
import com.twist.tmstore.entities.Wishlist;

public class DatabaseContentProvider extends ContentProvider {

    @Override
    protected Configuration getConfiguration() {
        // Register all Active Android model classes here
        //noinspection unchecked
        Configuration.Builder builder = new Configuration.Builder(getContext())
                .addModelClasses(
                        Address.class,
                        AppUser.class,
                        GhostCart.class,
                        Cart.class,
                        RecentSearchItem.class,
                        Wishlist.class,
                        WishListGroup.class,
                        Notification.class,
                        RecentlyViewedItem.class,
                        RecentMerchant.class);
        return builder.create();
    }
}
