package com.twist.tmstore.dialogs;

import android.app.Dialog;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.app.DialogFragment;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.Button;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.TextView;

import com.twist.dataengine.entities.TM_Shipping;
import com.twist.dataengine.entities.TM_Shipping_Pickup_Location;
import com.twist.tmstore.L;
import com.twist.tmstore.R;
import com.utils.Helper;
import com.utils.HtmlCompat;

/**
 * Created by Twist Mobile on 09-06-2017.
 */

public class ShippingMethodPickupLocationDialog extends DialogFragment {

    private PickupLocationSelectionListener mPickupLocationSelectionListener;
    private TM_Shipping tm_shipping;
    private int selected_pickup_location_index;
    private Button btn_ok;
    private Button btn_cancel;

    public interface PickupLocationSelectionListener {
        void locationSelected(int selectedPickupLocationIndex);
    }

    public static ShippingMethodPickupLocationDialog newInstance(TM_Shipping tm_shipping, PickupLocationSelectionListener pickupLocationSelectionListener) {
        ShippingMethodPickupLocationDialog pickupLocationDialog = new ShippingMethodPickupLocationDialog();
        pickupLocationDialog.mPickupLocationSelectionListener = pickupLocationSelectionListener;
        pickupLocationDialog.tm_shipping = tm_shipping;
        return pickupLocationDialog;
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.dialog_shipping_pickup_location, container, false);
    }

    @Override
    public void onStart() {
        super.onStart();
        if (getDialog() != null && getDialog().getWindow() != null) {
            int width = ViewGroup.LayoutParams.MATCH_PARENT;
            int height = ViewGroup.LayoutParams.WRAP_CONTENT;
            getDialog().getWindow().setLayout(width, height);
        }
    }

    @NonNull
    @Override
    public Dialog onCreateDialog(@NonNull Bundle savedInstanceState) {
        Dialog dialog = super.onCreateDialog(savedInstanceState);
        dialog.setCancelable(false);
        dialog.getWindow().requestFeature(Window.FEATURE_NO_TITLE);
        return dialog;
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {

        Helper.stylizeView(view.findViewById(R.id.header_box));
        TextView header_msg = (TextView) view.findViewById(R.id.header_msg);
        Helper.stylizeActionBar(header_msg);
        if (tm_shipping != null) {
            header_msg.setText(L.getString(L.string.dialog_header_shipping_pickup));
        }

        btn_ok = (Button) view.findViewById(R.id.btn_ok);
        btn_ok.setText(L.getString(L.string.ok));
        Helper.stylize(btn_ok);
        btn_ok.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mPickupLocationSelectionListener.locationSelected(selected_pickup_location_index);
                dismiss();
            }
        });

        btn_cancel = (Button) view.findViewById(R.id.btn_cancel);
        btn_cancel.setText(L.getString(L.string.cancel));
        Helper.stylize(btn_cancel);
        btn_cancel.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                dismiss();
            }
        });

        RadioGroup radioGroup_shipping_pickup_locations = (RadioGroup) view.findViewById(R.id.radioGroup_shipping_pickup_location);
        radioGroup_shipping_pickup_locations.removeAllViewsInLayout();
        radioGroup_shipping_pickup_locations.setVisibility(View.VISIBLE);
        int index = 0;
        if (tm_shipping != null) {

            for (TM_Shipping_Pickup_Location tm_shipping_pickup_location : tm_shipping.locations) {
                RadioButton radioButton = new RadioButton(getContext());
                Helper.setTextAppearance(getContext(), radioButton, android.R.style.TextAppearance_Small);
                radioButton.setPadding(16, 16, 16, 16);
                radioButton.setId(index++);
                String title = "";
                String s;
                if (!TextUtils.isEmpty(tm_shipping_pickup_location.company))
//                title = "" + '<b>' + HtmlCompat.fromHtml(tm_shipping_pickup_location.company.trim()) + "</b>";
                    title = "<b>" + tm_shipping_pickup_location.company.trim() + "</b>";
                if (!TextUtils.isEmpty(tm_shipping_pickup_location.address_1))

                    title += "<br>" + ", " + tm_shipping_pickup_location.address_1.trim();

                if (!TextUtils.isEmpty(tm_shipping_pickup_location.city))
                    title += ", " + tm_shipping_pickup_location.city.trim();

                if (!TextUtils.isEmpty(tm_shipping_pickup_location.postcode))
                    title += ", " + tm_shipping_pickup_location.postcode;

                if (!TextUtils.isEmpty(tm_shipping_pickup_location.state))
                    title += ", " + tm_shipping_pickup_location.state;

                if (!TextUtils.isEmpty(tm_shipping_pickup_location.phone))
                    title += ", " + tm_shipping_pickup_location.phone;
                //float totalWeightCost = (float) tm_shipping_pickup_location.cost;
//                if (AppInfo.SHIPPING_PROVIDER.equals(Constants.Key.SHIPPING_EPEKEN_JNE)) {
//                    totalWeightCost = getShippingTotalFromCartWeight(totalWeightCost, Cart.getTotalWeight());
//                }

          /*  if (totalWeightCost > 0) {
                title += " : " + Helper.appendCurrency(totalWeightCost);
            }
*/
                //Add shipping tax if available


                if (title.contains("<") || title.contains(">")) {
                    radioButton.setText(HtmlCompat.fromHtml(title));
                } else {
                    radioButton.setText(HtmlCompat.fromHtml(title));
                }

                Helper.stylize(radioButton);
                radioGroup_shipping_pickup_locations.addView(radioButton);
            }
        }

        radioGroup_shipping_pickup_locations.check(0);
        radioGroup_shipping_pickup_locations.setOnCheckedChangeListener(new RadioGroup.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(RadioGroup group, int checkedId) {
                selected_pickup_location_index = checkedId;
            }
        });
    }
}
