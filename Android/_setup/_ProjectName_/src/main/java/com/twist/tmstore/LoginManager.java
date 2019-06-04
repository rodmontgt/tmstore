package com.twist.tmstore;

import com.twist.dataengine.DataEngine;;
import com.twist.dataengine.TM_LoginListener;
import com.twist.tmstore.entities.AppUser;
import com.twist.tmstore.listeners.LoginListener;
import com.utils.AnalyticsHelper;

/**
 * Created by Twist Mobile on 24-05-2017.
 */

public class LoginManager {

    public static void signInWeb(String email, String password, final LoginListener loginListener) {
        DataEngine.getDataEngine().signInWebUsing(email, password, new TM_LoginListener() {
            @Override
            public void onLoginSuccess(String data) {
                loginListener.onLoginSuccess(data);
            }

            @Override
            public void onLoginFailed(String msg) {
                loginListener.onLoginFailed(msg);
            }
        });
    }

    public static void fetchCustomerData(String email, final LoginListener loginListener) {
        DataEngine.getDataEngine().fetchCustomerDataInBackground(email, new TM_LoginListener() {
            @Override
            public void onLoginSuccess(String data) {
                AppUser.getInstance().setJsonData(data);
                loginListener.onLoginSuccess(data);
                AnalyticsHelper.registerSignInEvent("API Signin");
            }

            @Override
            public void onLoginFailed(String msg) {
                loginListener.onLoginFailed(msg);
            }
        });
    }
}
