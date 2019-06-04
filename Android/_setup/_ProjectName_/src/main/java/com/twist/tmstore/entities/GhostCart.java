package com.twist.tmstore.entities;

import com.activeandroid.Model;
import com.activeandroid.annotation.Column;
import com.activeandroid.annotation.Table;
import com.activeandroid.query.Select;
import com.utils.Log;

import java.util.ArrayList;
import java.util.List;

@Table(name = "GhostCart")
public class GhostCart extends Model {
    @Column(name = "cart_product_id")
    public int product_id;

    @Column(name = "selected_variation_id")
    public int selected_variation_id = -1;

    private static List<GhostCart> allCartItems = null;

    public GhostCart() {
        super();
    }

    public GhostCart(int product_id, int variation_id) {
        this.product_id = product_id;
        this.selected_variation_id = variation_id;
        allCartItems.add(this);
    }

    public static void add(int product_id, int variation_id) {
        GhostCart gc = new GhostCart(product_id, variation_id);
        gc.save();
    }

    public static void init() {
        allCartItems = new Select().from(GhostCart.class).execute();
        if (allCartItems == null) {
            allCartItems = new ArrayList<>();
        }
    }

    public static boolean hasItem(int product_id, int variation_id) {
        if (allCartItems == null) {
            allCartItems = new Select().from(GhostCart.class).execute();
            return false;
        }

        if (allCartItems.size() <= 0)
            return false;

        for (GhostCart c : allCartItems) {
            if (c.product_id == product_id && c.selected_variation_id == variation_id) {
                return true;
            }
        }
        return false;
    }

    public static void printAll() {
        for (GhostCart c : allCartItems) {
            Log.d("------- GhostCart:[" + c.product_id + "][" + c.selected_variation_id + "] --------");
        }
    }

    public static void clearCart() {
        if (allCartItems == null)
            return;

        if (allCartItems.size() <= 0)
            return;

        for (GhostCart c : allCartItems) {
            c.delete();
        }
        allCartItems.clear();
    }


    public static void removeSafely(GhostCart cart) {
        //Log.d("-- removeSafely: ["+cart.product_id+"] ----");
        try {
            cart.delete();
            allCartItems.remove(cart);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
