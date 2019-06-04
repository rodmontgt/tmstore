package com.twist.dataengine;

/**
 * Created by Twist Mobile on 12/11/2015.
 */
public interface TM_LoginListener {
    void onLoginSuccess(String data);

    void onLoginFailed(String msg);
}
