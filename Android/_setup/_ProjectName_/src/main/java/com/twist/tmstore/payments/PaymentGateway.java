package com.twist.tmstore.payments;


import android.app.Activity;
import android.content.Intent;
import android.support.annotation.Nullable;
import android.text.TextUtils;

import com.twist.dataengine.entities.TM_AccountDetail;
import com.twist.dataengine.entities.TM_Order;
import com.twist.dataengine.entities.TM_PaymentGateway;
import com.twist.dataengine.entities.TM_PaymentGateway.GatewaySettings;
import com.utils.ListUtils;

import java.util.List;
import java.util.Map;

public abstract class PaymentGateway {

    public static final int REQUEST_PAYMENT = 10254;

    public interface PaymentListener {
        void onPaymentSucceed(int orderId);

        void onPaymentFailed();
    }

    private boolean enabled;

    private Activity mActivity;

    private Intent intent;

    private PaymentListener paymentListener;

    private String title = "";

    private String id = "";

    private String description = "";

    private String instructions = "";

    private GatewaySettings gatewaySettings;

    protected Map<String, String> mData;

    protected TM_Order order;

    private List<TM_AccountDetail> accountDetails;

    public Map<String, String> getData() {
        return mData;
    }

    public PaymentGateway setData(Map<String, String> mData) {
        this.mData = mData;
        return this;
    }

    abstract public boolean open(int orderId, float amount);

    protected PaymentGateway() {
    }

    protected PaymentGateway(PaymentListener listener) {
        this.setPaymentListener(listener);
    }

    public void setPaymentListener(PaymentListener listener) {
        this.checkPaymentListener(listener);
        this.paymentListener = listener;
    }

    public void initialize(Activity activity, Intent intent) {
        this.mActivity = activity;
        this.intent = intent;
    }

    public Intent getIntent() {
        return intent;
    }

    private void checkPaymentListener(PaymentListener listener) {
        if (listener == null) {
            throw new NullPointerException("PaymentListener can not be null");
        }
    }

    public PaymentListener getPaymentListener() {
        return paymentListener;
    }

    public String getTitle() {
        return title;
    }

    public PaymentGateway setTitle(String title) {
        this.title = title;
        // add title to extras so it can be used anywhere in payment activities.
        if (intent != null) {
            intent.putExtra("title", String.valueOf(title));
        }
        return this;
    }

    public String getId() {
        return id;
    }

    public PaymentGateway setId(String id) {
        // set id to lowercase to avoid comparison related bugs
        this.id = id.toLowerCase();
        return this;
    }

    public boolean isEnabled() {
        return enabled;
    }

    public void setEnabled(boolean enabled) {
        this.enabled = enabled;
    }

    public String getInstructions() {
        return instructions;
    }

    public void setInstructions(String instructions) {
        this.instructions = instructions;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public GatewaySettings getGatewaySettings() {
        return gatewaySettings;
    }

    public void setGatewaySettings(GatewaySettings gatewaySettings) {
        this.gatewaySettings = gatewaySettings;
    }

    public void setAccountDetails(List<TM_AccountDetail> accountDetails) {
        this.accountDetails = accountDetails;
    }

    public abstract boolean isPrepaid();

    public PaymentGateway prepare(Activity activity, PaymentListener paymentListener, @Nullable TM_PaymentGateway tm_paymentGateway) {
        this.mActivity = activity;
        this.paymentListener = paymentListener;
        if (tm_paymentGateway != null) {
            setId(tm_paymentGateway.id);
            setTitle(tm_paymentGateway.title);
            setDescription(tm_paymentGateway.description);
            setInstructions(tm_paymentGateway.instructions);
        }
        return this;
    }

    protected void launchIntent() {
        mActivity.startActivityForResult(intent, REQUEST_PAYMENT);
    }

    public TM_Order getOrder() {
        return order;
    }

    public void setOrder(TM_Order order) {
        this.order = order;
    }

    public String getAccountDetailsString() {
        StringBuilder str = new StringBuilder("");
        if (!ListUtils.isEmpty(accountDetails)) {
            for (TM_AccountDetail detail : accountDetails) {
                str.append(checkDetail("Account Name:", detail.account_name));
                str.append(checkDetail("Account Number:", detail.account_number));
                str.append(checkDetail("Bank Name:", detail.bank_name));
                str.append(checkDetail("Sort Code:", detail.sort_code));
                str.append(checkDetail("IBAN:", detail.iban));
                str.append(checkDetail("BIC:", detail.bic));
                str.append("<br>");
            }
        }
        return str.toString();
    }

    private String checkDetail(String label, String detail) {
        return TextUtils.isEmpty(detail) ? "" : label + " <b>" + detail + "</b><br>";
    }
}
