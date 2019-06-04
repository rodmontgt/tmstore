package com.twist.tmstore.listeners;

import com.twist.tmstore.entities.Cart;

/**
 * Created by Twist Mobile on 25-04-2017.
 */

public interface CartEventListener {
    void onItemAdded(Cart cartItem);

    void onItemUpdated(Cart cartItem);

    void onItemRemoved();
}