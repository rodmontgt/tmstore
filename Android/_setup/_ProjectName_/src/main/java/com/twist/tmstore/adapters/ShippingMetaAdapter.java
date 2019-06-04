package com.twist.tmstore.adapters;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.TextView;

import com.twist.dataengine.entities.TM_Coupon;
import com.twist.dataengine.entities.TM_Shipping;
import com.twist.tmstore.Constants;
import com.twist.tmstore.L;
import com.twist.tmstore.R;
import com.twist.tmstore.entities.AppInfo;
import com.twist.tmstore.entities.Cart;
import com.utils.Helper;
import com.utils.HtmlCompat;
import com.utils.Log;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

import static com.twist.tmstore.L.getString;

/**
 * Created by Twist Mobile on 03-04-2017.
 */

public class ShippingMetaAdapter extends RecyclerView.Adapter<ShippingMetaAdapter.DeliveryDateViewHolder> {
    private List<TM_Shipping> shippingList;
    private ShippingMethodListener shippingMethodListener;
    private Context mContext;

    private final int defaultShippingId = 0;

    private static class ShippingMeta {
        int shippingId;
        List<Integer> productIds;
        String deliveryDate;
        String deliveryTime;
    }

    private List<ShippingMeta> shippingMetaList = new ArrayList<>();

    public ShippingMetaAdapter(List<TM_Shipping> shippingList, String cartData) {
        this.shippingList = shippingList;
        List<Integer> pids = new ArrayList<>();
        try {
            JSONArray jsonArray = new JSONArray(cartData);
            for (int i = 0; i < jsonArray.length(); i++) {
                pids.add(jsonArray.getJSONObject(i).getInt("pid"));
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }

        // group shipping methods having same times.
        ArrayList<Integer> groupedProduct = new ArrayList<>();
        for (int i = 0; i < pids.size(); i++) {
            if (groupedProduct.contains(i)) {
                continue;
            }

            ShippingMeta shippingMeta = new ShippingMeta();
            shippingMeta.productIds = new ArrayList<>();
            shippingMeta.productIds.add(pids.get(i));
            Cart cart1 = Cart.findCart(pids.get(i));
            if (cart1 != null) {
                TM_Shipping shipping1 = shippingList.get(defaultShippingId);
                shippingMeta.shippingId = defaultShippingId;
                shippingMeta.deliveryDate = cart1.selectedDeliveryDate;
                shippingMeta.deliveryTime = cart1.selectedDeliveryTime;
                for (int k = i + 1; k < pids.size(); k++) {
                    if (groupedProduct.contains(k)) {
                        continue;
                    }

                    Cart cart2 = Cart.findCart(pids.get(k));
                    TM_Shipping shipping2 = shippingList.get(defaultShippingId);
                    if (cart2 != null
                            && cart1.product_id != cart2.product_id
                            && cart1.selectedDeliveryTime.equalsIgnoreCase(cart2.selectedDeliveryTime)
                            && cart1.selectedDeliveryDate.equalsIgnoreCase(cart2.selectedDeliveryDate)
                            && shipping1.method_id.equalsIgnoreCase(shipping2.method_id)) {
                        shippingMeta.productIds.add(pids.get(i));
                        groupedProduct.add(i + 1);
                    }
                }
            }
            shippingMetaList.add(shippingMeta);
        }
    }

    public interface ShippingMethodListener {
        void onShippingSelected(List<TM_Shipping> shippingList, String shippingString, double shippingTotal);
    }

    public void setOnShippingMethodListener(ShippingMethodListener shippingMethodListener) {
        this.shippingMethodListener = shippingMethodListener;
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    public class DeliveryDateViewHolder extends RecyclerView.ViewHolder {
        TextView deliveryDetails;
        TextView deliveryDate;
        TextView deliveryTime;
        TextView productName;
        RadioGroup shippingRadioGroup;

        public DeliveryDateViewHolder(View itemView) {
            super(itemView);
            deliveryDetails = (TextView) itemView.findViewById(R.id.text_delivery_details);
            deliveryDate = (TextView) itemView.findViewById(R.id.text_delivery_date);
            deliveryTime = (TextView) itemView.findViewById(R.id.text_delivery_time);
            productName = (TextView) itemView.findViewById(R.id.text_product_name);
            shippingRadioGroup = (RadioGroup) itemView.findViewById(R.id.radio_group_shipping);
        }
    }

    @Override
    public DeliveryDateViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        mContext = parent.getContext();
        return new DeliveryDateViewHolder(LayoutInflater.from(mContext).inflate(R.layout.item_delivery_info, parent, false));
    }

    @Override
    public void onBindViewHolder(DeliveryDateViewHolder viewHolder, final int position) {
        final ShippingMeta shippingMeta = shippingMetaList.get(position);
        String productName = "";
        final int size = shippingMeta.productIds.size();
        for (int i = 0; i < size; i++) {
            int productId = shippingMeta.productIds.get(i);
            Cart cart = Cart.findCart(productId);
            if (cart != null) {
                productName += cart.title;
                if (i < size - 1) {
                    productName += ", ";
                }
            }
        }
        viewHolder.productName.setText(productName);
        viewHolder.shippingRadioGroup.removeAllViewsInLayout();

        int index = 0;
        for (TM_Shipping shipping : shippingList) {
            RadioButton radioButton = new RadioButton(mContext);
            Helper.setTextAppearance(mContext, radioButton, android.R.style.TextAppearance_Small);
            radioButton.setId(index++);
            String title = shipping.label.trim();
            float totalWeightCost = (float) shipping.cost;
            if (AppInfo.SHIPPING_PROVIDER.equals(Constants.Key.SHIPPING_EPEKEN_JNE)) {
                totalWeightCost = getShippingTotalFromCartWeight(totalWeightCost, Cart.getTotalWeight());
            }

            if (totalWeightCost > 0) {
                title += " : " + Helper.appendCurrency(totalWeightCost);
            }

            //show shipping tax if available
            for (String str : shipping.taxes) {
                try {
                    float tax = Float.parseFloat(str);
                    if (tax > 0) {
                        title += ",\n" + String.format(Locale.getDefault(), getString(L.string.shipping_tax), Helper.appendCurrency(tax));
                    }
                } catch (NumberFormatException e) {
                    e.printStackTrace();
                }
            }

            if (title.contains("<") || title.contains(">")) {
                radioButton.setText(title);
            } else {
                radioButton.setText(HtmlCompat.fromHtml(title));
            }

            Helper.stylize(radioButton);
            viewHolder.shippingRadioGroup.addView(radioButton);
        }

        shippingMeta.shippingId = defaultShippingId;
        viewHolder.shippingRadioGroup.check(defaultShippingId);
        shippingMethodListener.onShippingSelected(getShippingList(), getShippingJsonString(), getShippingCost());

        viewHolder.shippingRadioGroup.setOnCheckedChangeListener(new RadioGroup.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(RadioGroup group, int checkedId) {
                if (checkedId >= 0) {
                    shippingMeta.shippingId = checkedId;
                    shippingMethodListener.onShippingSelected(getShippingList(), getShippingJsonString(), getShippingCost());
                }
            }
        });

        viewHolder.deliveryDetails.setText(getString(L.string.label_delivery_details));
        viewHolder.deliveryDate.setVisibility(View.VISIBLE);
        viewHolder.deliveryDate.setText(String.format(Locale.getDefault(), getString(L.string.label_date), shippingMeta.deliveryDate));
        viewHolder.deliveryTime.setVisibility(View.VISIBLE);
        viewHolder.deliveryTime.setText(String.format(Locale.getDefault(), getString(L.string.label_time), shippingMeta.deliveryTime));
    }

    private double getShippingCost() {
        if (!TM_Shipping.SHIPPING_REQUIRED) {
            return 0;
        }

        double totalShippingCost = 0;
        for (ShippingMeta shippingMeta : shippingMetaList) {
            TM_Shipping shipping = shippingList.get(shippingMeta.shippingId);
            if (shipping.isFree() && Cart.isAnyCouponApplied()) {
                for (TM_Coupon coupon : Cart.applied_coupons) {
                    if (!coupon.enable_free_shipping) {
                        Helper.showToast(String.format(getString(L.string.free_shipping_unavailable, true), coupon.code));
                        return 0;
                    }
                }
            }
            totalShippingCost += shipping.cost;
            //Add shipping tax if available
            for (String tax : shipping.taxes) {
                try {
                    totalShippingCost += Float.parseFloat(tax);
                } catch (NumberFormatException e) {
                    e.printStackTrace();
                }
            }
        }
        return totalShippingCost;
    }

    private float getShippingTotalFromCartWeight(float shippingTotal, float cartTotalWeight) {
        return shippingTotal * (cartTotalWeight < 1 ? 1 : (float) Math.floor(cartTotalWeight));
    }

    private List<TM_Shipping> getShippingList() {
        List<TM_Shipping> newShippingList = new ArrayList<>();
        for (ShippingMeta shippingMeta : shippingMetaList) {
            newShippingList.add(shippingList.get(shippingMeta.shippingId));
        }
        return newShippingList;
    }

    private String getShippingJsonString() {
        JSONArray shippingJsonArray = new JSONArray();
        try {
            for (ShippingMeta shippingMeta : shippingMetaList) {
                TM_Shipping shipping = shippingList.get(shippingMeta.shippingId);
                JSONObject jsonObject = new JSONObject();
                JSONArray pidsJsonArray = new JSONArray();
                JSONArray vidsJsonArray = new JSONArray();
                Cart cart = null;
                for (int productId : shippingMeta.productIds) {
                    cart = Cart.findCart(productId);
                    if (cart != null) {
                        pidsJsonArray.put(cart.product_id);
                        vidsJsonArray.put(cart.selected_variation_id);
                    }
                }
                if (cart != null) {
                    jsonObject.put("method_id", shipping.method_id);
                    jsonObject.put("method_title", shipping.label);
                    jsonObject.put("date_slot", cart.selectedDeliveryDate);
                    jsonObject.put("time_slot", cart.selectedDeliveryTime);

                    String slotPrice = cart.selectedDeliverySlotPrice;
                    if (TextUtils.isEmpty(slotPrice)) {
                        jsonObject.put("time_slot_cost", 0);
                    } else {
                        jsonObject.put("time_slot_cost", Double.parseDouble(slotPrice));
                    }
                    jsonObject.put("pids", pidsJsonArray);
                    jsonObject.put("vids", vidsJsonArray);
                }
                shippingJsonArray.put(jsonObject);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        String result = shippingJsonArray.toString();
        Log.d("Shipping String =>" + result);
        return result;
    }

    @Override
    public int getItemCount() {
        return shippingMetaList.size();
    }
}