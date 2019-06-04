package com.twist.tmstore.listeners;

/**
 * Created by Twist Mobile on 12/11/2015.
 */
public interface LoginListener {
    void onLoginSuccess(String data);

    void onLoginFailed(String cause);
}
