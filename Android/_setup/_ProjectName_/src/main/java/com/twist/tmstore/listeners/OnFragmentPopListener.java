package com.twist.tmstore.listeners;

public interface OnFragmentPopListener {
    int CODE_EMPTY = 0;
    int CODE_BUY = 1;
    int CODE_SHOW = 2;
    int CODE_HOME = 3;
    int CODE_CART = 4;
    int CODE_WISHLIST = 5;
    int CODE_OPINIONS = 6;
    int CODE_SEARCH = 7;

    void onFragmentPoped(int code);
}
