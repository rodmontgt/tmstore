
package com.twist.tmstore.payments;

import android.os.Bundle;

import com.twist.tmstore.BaseActivity;
import com.utils.Helper;

public class PaymentActivity extends BaseActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Helper.showToast("Payment Method Not Supported In This Build Variant.");
        finish();
    }

    @Override
    protected void onActionBarRestored() {
    }
}