package com.twist.tmstore.adapters;

import android.support.v7.widget.RecyclerView;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CompoundButton;
import android.widget.RadioButton;
import android.widget.TextView;

import com.twist.tmstore.L;
import com.twist.tmstore.R;
import com.twist.tmstore.entities.AppInfo;
import com.twist.tmstore.payments.PaymentGateway;
import com.utils.CContext;
import com.utils.Helper;
import com.utils.HtmlCompat;

import java.util.List;

/**
 * Created by Twist Mobile on 6/7/2017.
 */

public class Adapter_PaymentGateway extends RecyclerView.Adapter<Adapter_PaymentGateway.PaymentGatewayViewHolder> {

    private List<PaymentGateway> paymentGateways;

    private CompoundButton.OnCheckedChangeListener onCheckedChangeListener;

    public Adapter_PaymentGateway(List<PaymentGateway> paymentGateways) {
        this.paymentGateways = paymentGateways;
    }

    @Override
    public PaymentGatewayViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {

        View itemView = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_payment_gateway, parent, false);
        return new PaymentGatewayViewHolder(itemView);
    }

    @Override
    public void onBindViewHolder(PaymentGatewayViewHolder holder, int position) {
        holder.bindView(holder, position);
    }

    @Override
    public int getItemCount() {
        return paymentGateways != null ? paymentGateways.size() : 0;
    }

    public void setOnCheckedChangeListener(CompoundButton.OnCheckedChangeListener onCheckedChangeListener) {
        this.onCheckedChangeListener = onCheckedChangeListener;
    }

    private void showNoPaymentMethodError(RadioButton nameRadioButton, TextView textView1, TextView textView2) {
        try {
            nameRadioButton.setVisibility(View.GONE);
            textView2.setVisibility(View.GONE);
            textView1.setText(L.getString(L.string.error_no_payment_methods));
            textView1.setTextColor(CContext.getColor(textView1.getContext(), R.color.highlight_text_color));
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public class PaymentGatewayViewHolder extends RecyclerView.ViewHolder {
        RadioButton nameRadioButton;
        TextView descriptionTextView;
        TextView instructionsTextView;

        PaymentGatewayViewHolder(View view) {
            super(view);
            nameRadioButton = (RadioButton) view.findViewById(R.id.btn_payment_gateway_name);
            descriptionTextView = (TextView) view.findViewById(R.id.text_payment_gateway_description);
            instructionsTextView = (TextView) view.findViewById(R.id.text_payment_gateway_instructions);
            Helper.stylize(nameRadioButton);
        }

        private void bindView(PaymentGatewayViewHolder holder, int position) {
            PaymentGateway paymentGateway = paymentGateways.get(position);
            int size = paymentGateways.size();
            if (size == 0) {
                showNoPaymentMethodError(holder.nameRadioButton, holder.descriptionTextView, holder.instructionsTextView);
            } else if (size == 1) {
                holder.nameRadioButton.setChecked(false);
            }

            if (AppInfo.SHOW_PAYMENT_GATEWAY_DESCRIPTION && !TextUtils.isEmpty(paymentGateway.getDescription())) {
                holder.descriptionTextView.setText(HtmlCompat.fromHtml(paymentGateway.getDescription()).toString());
            } else {
                holder.descriptionTextView.setVisibility(View.GONE);
            }

            if (AppInfo.SHOW_PAYMENT_GATEWAY_INSTRUCTIONS && !TextUtils.isEmpty(paymentGateway.getInstructions())) {
                holder.instructionsTextView.setText(HtmlCompat.fromHtml(paymentGateway.getInstructions()).toString());
            } else {
                holder.instructionsTextView.setVisibility(View.GONE);
            }

            String title = paymentGateway.getTitle();
            if (paymentGateway.getGatewaySettings() != null && !TextUtils.isEmpty(paymentGateway.getGatewaySettings().extra_charges)) {
                title += " (" + paymentGateway.getGatewaySettings().extra_charges_msg + " <b>" + Helper.appendCurrency(paymentGateway.getGatewaySettings().extra_charges) + "</b>)";
            }
            holder.nameRadioButton.setEnabled(paymentGateway.isEnabled());
            holder.nameRadioButton.setText(HtmlCompat.fromHtml(title));
            holder.nameRadioButton.setTag(paymentGateway.getId());
            holder.nameRadioButton.setOnCheckedChangeListener(onCheckedChangeListener);
        }
    }
}