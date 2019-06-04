package com.twist.dataengine.entities;

/**
 * Created by Twist Mobile on 8/28/2017.
 */

public class CurrencyItem {
    private String name;
    private float rate;
    private String symbol;
    private String position;
    private int is_etalon;
    private int hide_cents;
    private int decimals;
    private String description;
    private String flag;

    public CurrencyItem() {
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public float getRate() {
        return rate;
    }

    public void setRate(float rate) {
        this.rate = rate;
    }

    public String getSymbol() {
        return symbol;
    }

    public void setSymbol(String symbol) {
        this.symbol = symbol;
    }

    public String getPosition() {
        return position;
    }

    public void setPosition(String position) {
        this.position = position;
    }

    public int getIs_etalon() {
        return is_etalon;
    }

    public void setIs_etalon(int is_etalon) {
        this.is_etalon = is_etalon;
    }

    public int getHide_cents() {
        return hide_cents;
    }

    public void setHide_cents(int hide_cents) {
        this.hide_cents = hide_cents;
    }

    public int getDecimals() {
        return decimals;
    }

    public void setDecimals(int decimals) {
        this.decimals = decimals;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getFlag() {
        return flag;
    }

    public void setFlag(String flag) {
        this.flag = flag;
    }
}
