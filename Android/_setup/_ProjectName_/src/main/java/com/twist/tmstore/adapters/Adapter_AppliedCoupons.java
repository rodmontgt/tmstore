package com.twist.tmstore.adapters;

import android.content.Context;
import android.content.DialogInterface;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.twist.dataengine.entities.TM_Coupon;
import com.twist.tmstore.BaseActivity;
import com.twist.tmstore.L;
import com.twist.tmstore.R;
import com.utils.Helper;
import com.utils.HtmlCompat;

import java.util.ArrayList;
import java.util.List;

import static com.twist.tmstore.L.getString;

public class Adapter_AppliedCoupons extends BaseAdapter {

    private List<TM_Coupon> data;
    private static LayoutInflater inflater = null;

    BaseActivity activity;

    public void resetList(List<TM_Coupon> newData) {
        if (data != null) {
            data.clear();
        }
        data.addAll(newData);
    }

    public interface CouponRemovalRequestListener {
        void onRemovalRequested(int couponId);
    }

    public void setCouponRemovalRequestListener(CouponRemovalRequestListener couponRemovalRequestListener) {
        this.couponRemovalRequestListener = couponRemovalRequestListener;
    }

    private CouponRemovalRequestListener couponRemovalRequestListener = null;

    public Adapter_AppliedCoupons(BaseActivity a, ArrayList d) {
        data = d;
        activity = a;
        inflater = (LayoutInflater) a.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
    }

    public int getCount() {
        return data.size();
    }

    public Object getItem(int position) {
        return position;
    }

    public long getItemId(int position) {
        return position;
    }

    public static class ViewHolder {
        TextView textAppliedCoupon;
        ImageView imageRemoveCoupon;
    }

    public View getView(int position, View convertView, ViewGroup parent) {
        View view = convertView;
        ViewHolder holder;

        if (convertView == null) {
            view = inflater.inflate(R.layout.item_coupon, parent, false);
            holder = new ViewHolder();
            holder.textAppliedCoupon = (TextView) view.findViewById(R.id.text_applied_coupon);
            holder.imageRemoveCoupon = (ImageView) view.findViewById(R.id.image_remove_coupon);
            view.setTag(holder);
        } else
            holder = (ViewHolder) view.getTag();

        TM_Coupon coupon = data.get(position);
        holder.textAppliedCoupon.setText(HtmlCompat.fromHtml(String.format(getString(L.string.coupon_code, true), coupon.code)));
        holder.imageRemoveCoupon.setOnClickListener(new CouponRemoveListener(coupon.id));
        return view;
    }

    private class CouponRemoveListener implements View.OnClickListener {
        final int couponId;

        public CouponRemoveListener(int couponId) {
            this.couponId = couponId;
        }

        @Override
        public void onClick(View v) {
            Helper.getConfirmation(
                    activity,
                    getString(L.string.msg_remove_coupon),
                    true,
                    new DialogInterface.OnClickListener() {
                        public void onClick(DialogInterface dialog, int id) {
                            if (couponRemovalRequestListener != null) {
                                couponRemovalRequestListener.onRemovalRequested(couponId);
                            }
                        }
                    },
                    null);
        }
    }

}