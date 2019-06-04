package com.twist.dataengine.entities;

/**
 * Created by Twist Mobile on 4/28/2016.
 */
public class TM_SimpleCart {
    public int pid;
    public int vid;
    public int index = -1;
    //public boolean stock;
    public String url = "";
    public String title = "";
    public String img = "";
    public String type = "";

    public boolean taxable;
    public String manage_stock = "no";
    public String stock_status = "instock";
    public String backorders = "no";

    public int total_stock = 1;

    public double price = 0;
    public double regular_price = 0;
    public double sale_price = 0;
    public double price_clone = 0;
    public double regular_price_clone = 0;
    public double sale_price_clone = 0;
    public double weight = 0;

    public TM_SimpleCart() {
    }

    public TM_SimpleCart(int pid, int vid, int index) {
        this.pid = pid;
        this.vid = vid;
        this.index = index;
    }

    public float getActualPrice() {
        return (float) ((sale_price > 0) ? sale_price : price);
    }

    public void clonePrice() {
        this.price_clone = this.price;
        this.regular_price_clone = this.regular_price;
        this.sale_price_clone = this.sale_price;
    }
}
