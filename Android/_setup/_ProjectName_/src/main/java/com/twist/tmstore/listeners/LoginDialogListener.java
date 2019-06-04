package com.twist.tmstore.listeners;

public interface LoginDialogListener {
    void onLoginSuccess();

    void onLoginFailed(String cause);
}
