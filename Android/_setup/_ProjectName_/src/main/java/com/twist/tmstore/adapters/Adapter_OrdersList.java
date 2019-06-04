package com.twist.tmstore.adapters;

import android.app.Activity;
import android.content.DialogInterface;
import android.graphics.Paint;
import android.support.v7.app.AlertDialog;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.Spinner;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.twist.dataengine.DataQueryHandler;
import com.twist.dataengine.DataEngine;;
import com.twist.dataengine.entities.OrderBookingInfo;
import com.twist.dataengine.entities.TM_Address;
import com.twist.dataengine.entities.TM_Attribute;
import com.twist.dataengine.entities.TM_LineItem;
import com.twist.dataengine.entities.TM_Order;
import com.twist.dataengine.entities.TM_ProductInfo;
import com.twist.dataengine.entities.TM_Variation;
import com.twist.dataengine.entities.TM_VariationAttribute;
import com.twist.tmstore.L;
import com.twist.tmstore.MainActivity;
import com.twist.tmstore.R;
import com.twist.tmstore.BaseActivity;
import com.twist.tmstore.config.TimeSlotConfig;
import com.twist.tmstore.entities.AppInfo;
import com.twist.tmstore.entities.Cart;
import com.utils.CContext;
import com.utils.DataHelper;
import com.utils.Helper;
import com.utils.HtmlCompat;
import com.utils.JsonUtils;
import com.utils.Log;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONTokener;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import static com.twist.tmstore.L.getString;

public class Adapter_OrdersList extends BaseAdapter {

    public interface ImageUploadListener<T1> {

        void onImageUploadSelected(TM_Order order, ProgressBar progressBar);

        void onImageSelected(T1 object);

        void onImageDeleted(T1 object);
    }

    private boolean isMyOrder = false;
    private final boolean isSeller;
    private String status;
    private final ImageUploadListener imageUploadListener;

    public interface CancelRequestListener {
        void onCancelRequested(int orderId);

        void onStatusSelected(String status, TM_Order tm_order);
    }

    private BaseActivity activity;
    private List<TM_Order> data;

    public void setCancelRequestListener(CancelRequestListener cancelRequestListener) {
        this.cancelRequestListener = cancelRequestListener;
    }

    private CancelRequestListener cancelRequestListener = null;
    private Map<String, String> mOrderStatusMap = new HashMap<>();

    public Adapter_OrdersList(BaseActivity a, List<TM_Order> orderList, boolean isSeller, boolean isMyOrder, ImageUploadListener imageUploadListener) {
        activity = a;
        data = orderList;
        this.isSeller = isSeller;
        this.isMyOrder = isMyOrder;
        this.imageUploadListener = imageUploadListener;

        if (isSeller) {
            mOrderStatusMap.put("pending", getString(L.string.pending));
            mOrderStatusMap.put("processing", getString(L.string.processing));
            mOrderStatusMap.put("on-hold", getString(L.string.onhold));
            mOrderStatusMap.put("completed", getString(L.string.completed));
            mOrderStatusMap.put("cancelled", getString(L.string.cancelled));
            mOrderStatusMap.put("refunded", getString(L.string.refunded));
            mOrderStatusMap.put("failed", getString(L.string.failed));
        }
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
        boolean isSpinnerSelected = false;
        LinearLayout products;
        TextView txt_orderdate;
        TextView txt_orderid;
        TextView text_applied_coupons;
        TextView text_payment;
        TextView text_taxes;
        TextView text_fees;
        TextView title_order_note;
        TextView title_order_status;
        TextView text_order_status;

        LinearLayout total_section;
        TextView title_total;
        TextView txt_total;

        LinearLayout totaltax_section;
        TextView title_totaltax;
        TextView txt_totaltax;

        LinearLayout shipping_cost_section;
        TextView title_shipping_cost;
        TextView txt_shipping_cost;

        LinearLayout order_note_section;
        TextView text_order_note;

        LinearLayout cart_note_section;
        TextView text_cart_note;

        Button button_cancel;
        Button button_track_order;
        Button button_order_again;
        Button button_booking_order_pay_again;

        LinearLayout shipment_tracking_layout;
        LinearLayout layout_order_status;
        TextView textShipmentDetails;
        TextView textShipmentId;
        TextView textShipmentProvider;
        TextView textShipmentIdError;

        LinearLayout pointsLayout;
        TextView pointsEarned;
        TextView pointsRedeemed;

        LinearLayout step_three_RL;

        ImageView image_done_1;
        ImageView image_done_2;
        ImageView image_done_3;
        ImageView image_done_4;

        TextView step_onetxt;
        TextView step_twotxt;
        TextView step_threetxt;
        TextView step_fourtxt;
        TextView txt_order_by;
        TextView txt_show_more;
        TextView title_shipping_methods;
        TextView shipping_methods;

        View view_process_one;
        View view_process_two;
        View view_process_three;
        View view_separator;

        View shipping_section;
        View coupon_section;
        View tax_section;
        View fee_section;
        View payment_section;
        FrameLayout order_status_layout;
        Spinner seller_order_status_spinner;
        View section_change_status;
        View section_separator_1;
        Button btn_change_status;
        TextView title_coupon;
        TextView title_payment;
        TextView title_tax;
        TextView title_fee;

        View delivery_address_section;
        TextView title_delivery_address;
        TextView text_delivery_address;

        View delivery_date_section;
        TextView title_delivery_date;
        TextView text_delivery_date;

        View delivery_time_section;
        TextView title_delivery_time;
        TextView text_delivery_time;

        TextView txt_show_billing_address;
        TextView txt_show_shipping_address;

        TextView text_meta_data;

        LinearLayout payment_proof_section;
        TextView txt_upload_image;
        ImageView img_select_image;

        LinearLayout list_track_btn;
        ProgressBar progress_upload_img;
    }

    public View getView(int position, View convertView, ViewGroup parent) {
        View view = convertView;
        final ViewHolder holder;
        final TM_Order order = data.get(position);
        if (convertView == null) {
            view = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_order, parent, false);
            holder = new ViewHolder();
            holder.txt_orderid = (TextView) view.findViewById(R.id.txt_order_id);

            holder.total_section = (LinearLayout) view.findViewById(R.id.total_section);
            holder.total_section.setVisibility(View.GONE);
            holder.title_total = (TextView) view.findViewById(R.id.title_total);
            holder.title_total.setText(getString(L.string.total_order));
            holder.txt_total = (TextView) view.findViewById(R.id.txt_total);

            holder.totaltax_section = (LinearLayout) view.findViewById(R.id.totaltax_section);
            holder.totaltax_section.setVisibility(View.GONE);
            holder.title_totaltax = (TextView) view.findViewById(R.id.title_totaltax);
            holder.title_totaltax.setText(getString(L.string.total_tax_order));
            holder.txt_totaltax = (TextView) view.findViewById(R.id.txt_totaltax);

            holder.shipping_cost_section = (LinearLayout) view.findViewById(R.id.shipping_cost_section);
            holder.shipping_cost_section.setVisibility(View.GONE);
            holder.title_shipping_cost = (TextView) view.findViewById(R.id.title_shipping_cost);
            holder.title_shipping_cost.setText(getString(L.string.total_shipping_cost));
            holder.txt_shipping_cost = (TextView) view.findViewById(R.id.txt_shipping_cost);

            holder.products = (LinearLayout) view.findViewById(R.id.products);
            holder.txt_orderdate = (TextView) view.findViewById(R.id.txt_order_date);
            holder.button_track_order = (Button) view.findViewById(R.id.button_track_order);
            holder.button_cancel = (Button) view.findViewById(R.id.button_cancel);
            holder.layout_order_status = (LinearLayout) view.findViewById(R.id.layout_order_status);

            holder.shipment_tracking_layout = (LinearLayout) view.findViewById(R.id.shipment_tracking_layout);
            holder.shipment_tracking_layout.setVisibility(View.GONE);
            holder.textShipmentDetails = (TextView) view.findViewById(R.id.text_shipment_details);
            holder.textShipmentDetails.setText(getString(L.string.label_shipment_details));
            holder.textShipmentId = (TextView) view.findViewById(R.id.text_shipment_id);
            holder.textShipmentProvider = (TextView) view.findViewById(R.id.text_shipment_provider);
            holder.textShipmentIdError = (TextView) view.findViewById(R.id.text_shipment_id_error);
            holder.textShipmentIdError.setVisibility(View.GONE);

            holder.pointsLayout = (LinearLayout) view.findViewById(R.id.points_layout);
            holder.pointsEarned = (TextView) view.findViewById(R.id.text_earned_points);
            holder.pointsRedeemed = (TextView) view.findViewById(R.id.text_redeemed_points);
            holder.txt_order_by = (TextView) view.findViewById(R.id.txt_order_by);
            holder.txt_show_more = (TextView) view.findViewById(R.id.txt_show_more);
            holder.title_shipping_methods = (TextView) view.findViewById(R.id.title_shipping_method);
            holder.shipping_methods = (TextView) view.findViewById(R.id.shipping_methods);
            holder.text_meta_data = (TextView) view.findViewById(R.id.text_meta_data);

            holder.title_shipping_methods.setText(getString(L.string.shipping_methods));
            holder.button_track_order.setText(getString(L.string.track_order));
            holder.button_cancel.setText(getString(L.string.cancel_order));
            holder.button_order_again = (Button) view.findViewById(R.id.btn_order_again);
            holder.button_order_again.setVisibility(View.GONE);
            holder.txt_order_by.setText(getString(L.string.order_by));
            holder.button_booking_order_pay_again = (Button) view.findViewById(R.id.btn_booking_order_pay_again);
            holder.button_booking_order_pay_again.setVisibility(View.GONE);

            holder.step_three_RL = (LinearLayout) view.findViewById(R.id.stepview_three_rl);

            holder.image_done_1 = (ImageView) view.findViewById(R.id.image_done_1);
            holder.image_done_2 = (ImageView) view.findViewById(R.id.image_done_2);
            holder.image_done_3 = (ImageView) view.findViewById(R.id.image_done_3);
            holder.image_done_4 = (ImageView) view.findViewById(R.id.image_done_4);

            holder.step_onetxt = (TextView) view.findViewById(R.id.stepxtxt_one);
            holder.step_twotxt = (TextView) view.findViewById(R.id.stepxtxt_two);
            holder.step_threetxt = (TextView) view.findViewById(R.id.stepxtxt_three);
            holder.step_fourtxt = (TextView) view.findViewById(R.id.stepxtxt_four);

            holder.view_process_one = view.findViewById(R.id.view_process_one);
            holder.view_process_two = view.findViewById(R.id.view_process_two);
            holder.view_process_three = view.findViewById(R.id.view_process_three);
            holder.view_separator = view.findViewById(R.id.view_separator);

            holder.order_note_section = (LinearLayout) view.findViewById(R.id.order_note_section);
            holder.text_order_note = (TextView) view.findViewById(R.id.text_order_note);
            holder.cart_note_section = (LinearLayout) view.findViewById(R.id.cart_note_section);
            holder.text_cart_note = (TextView) view.findViewById(R.id.text_cart_note);
            holder.text_applied_coupons = (TextView) view.findViewById(R.id.text_applied_coupons);
            holder.text_payment = (TextView) view.findViewById(R.id.text_payment);
            holder.text_taxes = (TextView) view.findViewById(R.id.text_taxes);
            holder.text_fees = (TextView) view.findViewById(R.id.text_fees);
            holder.title_order_note = (TextView) view.findViewById(R.id.title_order_note);
            holder.title_order_status = (TextView) view.findViewById(R.id.title_order_status);
            holder.title_order_status.setVisibility(View.VISIBLE);
            holder.text_order_status = (TextView) view.findViewById(R.id.text_order_status);
            holder.text_order_status.setVisibility(View.GONE);
            holder.title_coupon = (TextView) view.findViewById(R.id.title_coupon);
            holder.title_payment = (TextView) view.findViewById(R.id.title_payment);
            holder.title_tax = (TextView) view.findViewById(R.id.title_tax);
            holder.title_fee = (TextView) view.findViewById(R.id.title_fee);

            holder.btn_change_status = (Button) view.findViewById(R.id.btn_change_status);
            holder.btn_change_status.setText(getString(L.string.update_order));
            Helper.stylize(holder.btn_change_status);
            holder.btn_change_status.setEnabled(false);

            holder.shipping_section = view.findViewById(R.id.shipping_section);
            holder.coupon_section = view.findViewById(R.id.coupon_section);
            holder.tax_section = view.findViewById(R.id.tax_section);
            holder.fee_section = view.findViewById(R.id.fee_section);
            holder.payment_section = view.findViewById(R.id.payment_section);
            holder.order_status_layout = (FrameLayout) view.findViewById(R.id.order_status_layout);
            holder.seller_order_status_spinner = (Spinner) view.findViewById(R.id.seller_order_status);
            holder.section_change_status = view.findViewById(R.id.section_change_status);
            holder.section_separator_1 = view.findViewById(R.id.separator_1);

            holder.title_order_note.setText(getString(L.string.order_note));
            holder.title_order_status.setText(getString(L.string.title_order_status));
            holder.title_coupon.setText(getString(L.string.applied_coupons));
            holder.text_applied_coupons.setText(getString(L.string.text_applied_coupons));
            holder.text_payment.setText(getString(L.string.text_payment));
            holder.title_payment.setText(getString(L.string.payment_detail));
            holder.title_fee.setText(getString(L.string.fee_lines));
            holder.title_tax.setText(getString(L.string.title_tax));
            holder.text_taxes.setText(getString(L.string.text_payment));

            holder.delivery_date_section = view.findViewById(R.id.delivery_date_section);
            holder.delivery_time_section = view.findViewById(R.id.delivery_time_section);
            holder.delivery_date_section.setVisibility(View.GONE);
            holder.delivery_time_section.setVisibility(View.GONE);

            holder.title_delivery_date = (TextView) view.findViewById(R.id.title_delivery_date);
            holder.text_delivery_date = (TextView) view.findViewById(R.id.text_delivery_date);
            holder.title_delivery_time = (TextView) view.findViewById(R.id.title_delivery_time);
            holder.text_delivery_time = (TextView) view.findViewById(R.id.text_delivery_time);

            holder.title_delivery_date.setText(getString(L.string.delivery_date));
            holder.title_delivery_time.setText(getString(L.string.delivery_time));

            holder.delivery_address_section = view.findViewById(R.id.delivery_address_section);
            holder.delivery_address_section.setVisibility(View.GONE);
            holder.title_delivery_address = (TextView) view.findViewById(R.id.title_delivery_address);
            holder.text_delivery_address = (TextView) view.findViewById(R.id.text_delivery_address);

            holder.txt_show_billing_address = (TextView) view.findViewById(R.id.txt_show_billing_address);
            holder.txt_show_billing_address.setText(getString(L.string.show_billing_address));
            holder.txt_show_billing_address.setPaintFlags(holder.txt_show_billing_address.getPaintFlags() | Paint.UNDERLINE_TEXT_FLAG);

            holder.txt_show_shipping_address = (TextView) view.findViewById(R.id.txt_show_shipping_address);
            holder.txt_show_shipping_address.setText(getString(L.string.show_shipping_address));
            holder.txt_show_shipping_address.setPaintFlags(holder.txt_show_shipping_address.getPaintFlags() | Paint.UNDERLINE_TEXT_FLAG);

            holder.payment_proof_section = (LinearLayout) view.findViewById(R.id.payment_proof_section);
            holder.payment_proof_section.setVisibility(View.GONE);

            holder.layout_order_status.setVisibility(View.GONE);
            Helper.stylize(holder.button_track_order);
            Helper.styleCancel(holder.button_cancel);
            view.setTag(holder);
        } else {
            holder = (ViewHolder) view.getTag();
        }

        holder.products.removeAllViewsInLayout();
        holder.products.removeAllViews();

        if (AppInfo.HIDE_PRODUCT_PRICE_TAG) {
            holder.total_section.setVisibility(View.GONE);
            holder.totaltax_section.setVisibility(View.GONE);
            holder.shipping_cost_section.setVisibility(View.GONE);
        } else {
            holder.total_section.setVisibility(View.VISIBLE);
            holder.txt_total.setText(HtmlCompat.fromHtml(Helper.appendCurrency(order.total)));

            if (order.total_tax > 0 && !TextUtils.isEmpty(String.valueOf(order.total_tax))) {
                holder.totaltax_section.setVisibility(View.VISIBLE);
                holder.txt_totaltax.setText(HtmlCompat.fromHtml(Helper.appendCurrency(order.total_tax)));
            }
        }
        holder.txt_orderid.setText(HtmlCompat.fromHtml(String.format(getString(L.string.order_id, true), order.order_number)));

        if (TimeSlotConfig.isEnabled() && TimeSlotConfig.getPluginType() == TimeSlotConfig.PluginType.DELIVERY_SLOTS) {
            holder.delivery_date_section.setVisibility(View.VISIBLE);
            holder.delivery_time_section.setVisibility(View.VISIBLE);
            holder.text_delivery_date.setText(order.deliveryDate);
            holder.text_delivery_time.setText(order.deliveryTime);
            if (TextUtils.isEmpty(order.deliveryDate)) {
                holder.delivery_date_section.setVisibility(View.GONE);
                Log.d("Order Delivery Date is empty");
            }
            if (TextUtils.isEmpty(order.deliveryTime)) {
                holder.delivery_time_section.setVisibility(View.GONE);
                Log.d("Order Delivery Time is empty");
            }
        } else {
            holder.delivery_date_section.setVisibility(View.GONE);
            holder.delivery_time_section.setVisibility(View.GONE);
        }

        if (!TextUtils.isEmpty(order.note)) {
            holder.order_note_section.setVisibility(View.VISIBLE);
            holder.title_order_note.setVisibility(View.VISIBLE);
            holder.text_order_note.setVisibility(View.VISIBLE);

            String orderNote = "";
            JSONArray cartNote = null;
            try {
                Object object = new JSONTokener(order.note).nextValue();
                if (object instanceof JSONObject) {
                    JSONObject noteJsonObject = (JSONObject) object;
                    if (noteJsonObject.has("ordernote")) {
                        orderNote = noteJsonObject.getString("ordernote");
                    }

                    if (noteJsonObject.has("cartnotes")) {
                        cartNote = noteJsonObject.getJSONArray("cartnotes");
                    }
                } else {
                    orderNote = order.note;
                    holder.cart_note_section.setVisibility(View.GONE);
                    holder.text_cart_note.setVisibility(View.GONE);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }

            if (AppInfo.ENABLE_SPECIAL_ORDER_NOTE) {
                try {
                    int s = orderNote.indexOf("***");
                    int e = orderNote.lastIndexOf("***");
                    if (s >= 0 && e >= 0 && s != e) {
                        orderNote = orderNote.substring(0, s);
                        if (TextUtils.isEmpty(orderNote)) {
                            // Don't show order notes in case of masked notes.
                            holder.order_note_section.setVisibility(View.GONE);
                            holder.title_order_note.setVisibility(View.GONE);
                            holder.text_order_note.setVisibility(View.GONE);
                        }
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }

            holder.text_order_note.setText(HtmlCompat.fromHtml(orderNote));

            String finalStr = "";
            if (cartNote != null) {
                for (int i = 0; i < cartNote.length(); i++) {
                    String Name = "";
                    String noteStr = "";
                    String padding = "<br><br>";

                    if (i == cartNote.length() - 1)
                        padding = "";

                    try {
                        JSONObject obj = (JSONObject) cartNote.get(i);
                        Name = obj.getString("prod_name");
                        noteStr = obj.getString("note");
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                    finalStr += "<b>" + Name + "</b>" + " - " + "<br>" + "<b>" + getString(L.string.note) + " :   " + "</b>" + noteStr + padding;
                }
            }
            holder.text_cart_note.setSingleLine(false);
            holder.text_cart_note.setText(HtmlCompat.fromHtml(finalStr));

        } else {
            holder.order_note_section.setVisibility(View.GONE);
            holder.text_order_note.setVisibility(View.GONE);
            holder.title_order_note.setVisibility(View.GONE);
            holder.cart_note_section.setVisibility(View.GONE);
            holder.text_cart_note.setVisibility(View.GONE);
        }

        holder.txt_show_more.setText(getString(L.string.show_more));
        Helper.setDrawableRight(holder.txt_show_more, R.drawable.ic_vc_arrow_down);
        Helper.stylizeThemedText(holder.txt_show_more);
        holder.txt_order_by.setVisibility(View.GONE); //until address issue resolves
        holder.txt_show_more.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                if (holder.layout_order_status.getVisibility() == View.GONE) {
                    holder.layout_order_status.setVisibility(View.VISIBLE);
                    Helper.setDrawableRight(holder.txt_show_more, R.drawable.ic_vc_arrow_up);
                    holder.txt_show_more.setText(getString(L.string.show_less));
                } else {
                    holder.layout_order_status.setVisibility(View.GONE);
                    Helper.setDrawableRight(holder.txt_show_more, R.drawable.ic_vc_arrow_down);
                    holder.txt_show_more.setText(getString(L.string.show_more));
                }
            }
        });

        if (!TextUtils.isEmpty(order.shipping_methods)) {
            holder.shipping_section.setVisibility(View.VISIBLE);
            holder.shipping_methods.setText(order.shipping_methods);
        } else {
            holder.shipping_section.setVisibility(View.GONE);
        }

        if (order.total_shipping > 0 && !TextUtils.isEmpty(String.valueOf(order.total_shipping))) {
            holder.shipping_cost_section.setVisibility(View.VISIBLE);
            holder.txt_shipping_cost.setText(HtmlCompat.fromHtml(Helper.appendCurrency(order.total_shipping)));
        } else {
            holder.shipping_cost_section.setVisibility(View.GONE);
        }

        if (order.coupon_lines != null && !order.coupon_lines.isEmpty()) {
            holder.coupon_section.setVisibility(View.VISIBLE);
            holder.text_applied_coupons.setText(Helper.stringFromList(order.coupon_lines));
        } else {
            holder.coupon_section.setVisibility(View.GONE);
        }

        if (order.payment_details != null && Helper.isValidString(order.payment_details.method_title)) {
            holder.payment_section.setVisibility(View.VISIBLE);
            holder.text_payment.setText(order.payment_details.method_title);
        } else {
            holder.payment_section.setVisibility(View.GONE);
        }

        if (order.tax_lines != null && !order.tax_lines.isEmpty()) {
            holder.tax_section.setVisibility(View.VISIBLE);
            holder.text_taxes.setText(Helper.stringFromList(order.tax_lines));
        } else {
            holder.tax_section.setVisibility(View.GONE);
        }

        if (order.fee_lines != null && !order.fee_lines.isEmpty()) {
            holder.fee_section.setVisibility(View.VISIBLE);
            holder.text_fees.setText(Helper.stringFromList(order.fee_lines));
        } else {
            holder.fee_section.setVisibility(View.GONE);
        }

        if (isSeller) {
            holder.section_change_status.setVisibility(View.VISIBLE);
            holder.section_separator_1.setVisibility(View.VISIBLE);
            ArrayList<String> data = new ArrayList<>(mOrderStatusMap.values());
            Adapter_HtmlString adapterOrderStatus = new Adapter_HtmlString(activity, data);
            holder.seller_order_status_spinner.setAdapter(adapterOrderStatus);
            if (!TextUtils.isEmpty(order.status)) {
                holder.seller_order_status_spinner.setSelection(adapterOrderStatus.getPosition(getOrderStatusTitle(order.status)));
                holder.text_order_status.setVisibility(View.VISIBLE);
                switch (order.status.toLowerCase()) {
                    case "processing":
                        holder.text_order_status.setText(getString(L.string.processing));
                        break;
                    case "on-hold":
                        holder.text_order_status.setText(getString(L.string.onhold));
                        break;
                    case "pending":
                        holder.text_order_status.setText(getString(L.string.pending));
                        break;
                    case "completed":
                        holder.text_order_status.setText(getString(L.string.completed));
                        break;
                    case "cancelled":
                        holder.text_order_status.setText(getString(L.string.cancelled));
                        break;
                    case "refunded":
                        holder.text_order_status.setText(getString(L.string.refunded));
                        break;
                    case "failed":
                        holder.text_order_status.setText(getString(L.string.failed));
                        break;
                }
            }
            holder.seller_order_status_spinner.setOnItemSelectedListener(null);
            holder.seller_order_status_spinner.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
                @Override
                public void onItemSelected(AdapterView<?> adapterView, View view, int position, long l) {
                    if (!holder.isSpinnerSelected) {
                        holder.isSpinnerSelected = true;
                        holder.btn_change_status.setEnabled(false);
                        return;
                    }
                    status = getOrderStatusString(adapterView.getSelectedItem().toString());
                    holder.btn_change_status.setEnabled(true);
                    holder.isSpinnerSelected = false;
                }

                @Override
                public void onNothingSelected(AdapterView<?> adapterView) {
                }
            });
            holder.btn_change_status.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View view) {
                    holder.btn_change_status.setEnabled(false);
                    cancelRequestListener.onStatusSelected(status, order);
                }
            });
        } else {
            holder.section_change_status.setVisibility(View.GONE);
            holder.section_separator_1.setVisibility(View.GONE);
        }

        if (isSeller) {
            holder.txt_show_billing_address.setVisibility(View.VISIBLE);
            holder.txt_show_billing_address.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    String billing_title = L.getString(L.string.billing_address);
                    showOrderAddressDialog(activity, billing_title, order.billing_address);
                }
            });

        } else {
            holder.txt_show_billing_address.setVisibility(View.GONE);
        }

        if (isSeller) {
            holder.txt_show_shipping_address.setVisibility(View.VISIBLE);
            holder.txt_show_shipping_address.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    String shipping_title = L.getString(L.string.shipping_address);
                    showOrderAddressDialog(activity, shipping_title, order.shipping_address);
                }
            });

        } else {
            holder.txt_show_shipping_address.setVisibility(View.GONE);
        }


        if (!isSeller) {
            switch (order.status.toLowerCase()) {
                case "pending":
                case "failed":
                    holder.button_cancel.setVisibility(View.VISIBLE);
                    break;
                case "processing":
                case "on-hold":
                case "completed":
                case "refunded":
                case "cancelled":
                default:
                    holder.button_cancel.setVisibility(View.GONE);
                    break;
            }

            holder.button_cancel.setTag(order.id);
            holder.button_cancel.setOnClickListener(v -> {
                final int orderId = (int) v.getTag();
                Helper.getConfirmation(activity,
                        getString(L.string.msg_cancel_order),
                        true,
                        (dialog, id) -> performCancelOrder(orderId),
                        null);
            });
        }
        if (AppInfo.ENABLE_SHIPMENT_TRACKING) {
            if (order.status.equalsIgnoreCase("failed")
                    || order.status.equalsIgnoreCase("on-hold")
                    || order.status.equalsIgnoreCase("pending")
                    || order.status.equalsIgnoreCase("cancelled")
                    || order.status.equalsIgnoreCase("refunded")) {

                holder.shipment_tracking_layout.setVisibility(View.GONE);
                holder.button_track_order.setVisibility(View.GONE);
            } else {
                // Show for only processing || shipped
                holder.shipment_tracking_layout.setVisibility(View.GONE);
                holder.step_three_RL.setVisibility(View.VISIBLE);
                holder.view_process_two.setVisibility(View.VISIBLE);
                holder.view_separator.setVisibility(View.VISIBLE);
                holder.textShipmentIdError.setVisibility(View.GONE);
                if (!TextUtils.isEmpty(order.provider) && !TextUtils.isEmpty(order.trackingId)) {
                    holder.textShipmentIdError.setVisibility(View.GONE);
                    holder.shipment_tracking_layout.setVisibility(View.VISIBLE);
                    holder.textShipmentId.setVisibility(View.VISIBLE);
                    holder.textShipmentProvider.setVisibility(View.VISIBLE);
                    holder.textShipmentId.setText(String.format(Locale.getDefault(), getString(L.string.label_shipment_id), order.trackingId));
                    holder.textShipmentProvider.setText(String.format(Locale.getDefault(), getString(L.string.label_shipment_provider), order.provider));

                    if (!TextUtils.isEmpty(order.trackingURL)) {
                        Helper.stylize(holder.button_track_order);
                        holder.button_track_order.setVisibility(View.VISIBLE);
                        holder.button_track_order.setOnClickListener(new OnClickListener() {
                            @Override
                            public void onClick(final View view) {
                                MainActivity.mActivity.openWebFragment(getString(L.string.track_order), order.trackingURL + order.trackingId);
                            }
                        });
                    } else {
                        holder.button_track_order.setVisibility(View.GONE);
                    }
                } else {
                    holder.textShipmentId.setVisibility(View.GONE);
                    holder.textShipmentProvider.setVisibility(View.GONE);
                    holder.button_track_order.setVisibility(View.GONE);
                    holder.shipment_tracking_layout.setVisibility(View.VISIBLE);
                    holder.textShipmentIdError.setVisibility(View.VISIBLE);
                    holder.textShipmentIdError.setText(getString(L.string.shipment_tracking_id_unavailable));
                }
            }
        } else {
            holder.shipment_tracking_layout.setVisibility(View.GONE);
            holder.button_track_order.setVisibility(View.GONE);
            holder.step_three_RL.setVisibility(View.GONE);
            holder.view_process_two.setVisibility(View.GONE);
            holder.view_separator.setVisibility(View.GONE);
        }

        if (AppInfo.ENABLE_CUSTOM_POINTS) {
            holder.pointsLayout.setVisibility(View.VISIBLE);
            holder.pointsEarned.setText(HtmlCompat.fromHtml(String.format(getString(L.string.points_earned), order.getPointsEarned())));
            holder.pointsRedeemed.setText(HtmlCompat.fromHtml(String.format(getString(L.string.points_redeemed), order.getPointsRedeemed())));
        } else {
            holder.pointsLayout.setVisibility(View.GONE);
        }

        if (!isSeller || AppInfo.ENABLE_SHIPMENT_TRACKING) {
            holder.order_status_layout.setVisibility(View.VISIBLE);
            switch (order.status) {
                case "pending":
                    setOrderStatusStepEnabled(holder.image_done_1, holder.step_onetxt, L.string.pending);
                    setOrderStatusStepDisabled(holder.image_done_2, holder.step_twotxt, L.string.processing);
                    setOrderStatusStepDisabled(holder.image_done_3, holder.step_threetxt, L.string.shipping);
                    setOrderStatusStepDisabled(holder.image_done_4, holder.step_fourtxt, L.string.delivered);

                    holder.view_process_one.setBackground(CContext.getDrawable(activity, R.color.order_status_progress_bg_disable));
                    holder.view_process_two.setBackground(CContext.getDrawable(activity, R.color.order_status_progress_bg_disable));
                    holder.view_process_three.setBackground(CContext.getDrawable(activity, R.color.order_status_progress_bg_disable));

                    break;
                case "processing":
                    setOrderStatusStepEnabled(holder.image_done_1, holder.step_onetxt, L.string.approval);
                    setOrderStatusStepEnabled(holder.image_done_2, holder.step_twotxt, L.string.processing);
                    setOrderStatusStepDisabled(holder.image_done_3, holder.step_threetxt, L.string.shipping);
                    setOrderStatusStepDisabled(holder.image_done_4, holder.step_fourtxt, L.string.delivered);

                    holder.view_process_one.setBackground(CContext.getDrawable(activity, R.color.order_status_progress_bg_enable));
                    holder.view_process_two.setBackground(CContext.getDrawable(activity, R.color.order_status_progress_bg_disable));
                    holder.view_process_three.setBackground(CContext.getDrawable(activity, R.color.order_status_progress_bg_disable));

                    break;
                case "on-hold":
                    setOrderStatusStepEnabled(holder.image_done_1, holder.step_onetxt, L.string.onhold);
                    setOrderStatusStepDisabled(holder.image_done_2, holder.step_twotxt, L.string.processing);
                    setOrderStatusStepDisabled(holder.image_done_3, holder.step_threetxt, L.string.shipping);
                    setOrderStatusStepDisabled(holder.image_done_4, holder.step_fourtxt, L.string.delivered);

                    holder.view_process_one.setBackground(CContext.getDrawable(activity, R.color.order_status_progress_bg_disable));
                    holder.view_process_two.setBackground(CContext.getDrawable(activity, R.color.order_status_progress_bg_disable));
                    holder.view_process_three.setBackground(CContext.getDrawable(activity, R.color.order_status_progress_bg_disable));

                    break;
                case "completed":
                    setOrderStatusStepEnabled(holder.image_done_1, holder.step_onetxt, L.string.approval);
                    setOrderStatusStepEnabled(holder.image_done_2, holder.step_twotxt, L.string.processing);
                    setOrderStatusStepEnabled(holder.image_done_3, holder.step_threetxt, L.string.shipping);
                    setOrderStatusStepEnabled(holder.image_done_4, holder.step_fourtxt, L.string.delivered);

                    holder.view_process_one.setBackground(CContext.getDrawable(activity, R.color.order_status_progress_bg_enable));
                    holder.view_process_two.setBackground(CContext.getDrawable(activity, R.color.order_status_progress_bg_enable));
                    holder.view_process_three.setBackground(CContext.getDrawable(activity, R.color.order_status_progress_bg_enable));

                    break;
                case "cancelled":
                    setOrderStatusStepEnabled(holder.image_done_1, holder.step_onetxt, L.string.approval);
                    setOrderStatusStepEnabled(holder.image_done_2, holder.step_twotxt, L.string.cancelled);
                    setOrderStatusStepDisabled(holder.image_done_3, holder.step_threetxt, L.string.shipping);
                    setOrderStatusStepDisabled(holder.image_done_4, holder.step_fourtxt, L.string.delivered);

                    holder.view_process_one.setBackground(CContext.getDrawable(activity, R.color.order_status_progress_bg_enable));
                    holder.view_process_two.setBackground(CContext.getDrawable(activity, R.color.order_status_progress_bg_disable));
                    holder.view_process_three.setBackground(CContext.getDrawable(activity, R.color.order_status_progress_bg_disable));

                    break;
                case "refunded":
                    setOrderStatusStepEnabled(holder.image_done_1, holder.step_onetxt, L.string.approval);
                    setOrderStatusStepEnabled(holder.image_done_2, holder.step_twotxt, L.string.processing);
                    setOrderStatusStepEnabled(holder.image_done_3, holder.step_threetxt, L.string.shipping);
                    setOrderStatusStepEnabled(holder.image_done_4, holder.step_fourtxt, L.string.refunded);

                    holder.view_process_one.setBackground(CContext.getDrawable(activity, R.color.order_status_progress_bg_enable));
                    holder.view_process_two.setBackground(CContext.getDrawable(activity, R.color.order_status_progress_bg_enable));
                    holder.view_process_three.setBackground(CContext.getDrawable(activity, R.color.order_status_progress_bg_enable));

                    break;
                case "failed":
                    setOrderStatusStepEnabled(holder.image_done_1, holder.step_onetxt, L.string.failed);
                    setOrderStatusStepDisabled(holder.image_done_2, holder.step_twotxt, L.string.processing);
                    setOrderStatusStepDisabled(holder.image_done_3, holder.step_threetxt, L.string.shipping);
                    setOrderStatusStepDisabled(holder.image_done_4, holder.step_fourtxt, L.string.delivered);

                    holder.view_process_one.setBackground(CContext.getDrawable(activity, R.color.order_status_progress_bg_disable));
                    holder.view_process_two.setBackground(CContext.getDrawable(activity, R.color.order_status_progress_bg_disable));
                    holder.view_process_three.setBackground(CContext.getDrawable(activity, R.color.order_status_progress_bg_disable));

                    break;

                case "shipping":
                    setOrderStatusStepEnabled(holder.image_done_1, holder.step_onetxt, L.string.approval);
                    setOrderStatusStepEnabled(holder.image_done_2, holder.step_twotxt, L.string.processing);
                    setOrderStatusStepEnabled(holder.image_done_3, holder.step_threetxt, L.string.shipping);
                    setOrderStatusStepDisabled(holder.image_done_4, holder.step_fourtxt, L.string.delivered);

                    holder.view_process_one.setBackground(CContext.getDrawable(activity, R.color.order_status_progress_bg_enable));
                    holder.view_process_two.setBackground(CContext.getDrawable(activity, R.color.order_status_progress_bg_enable));
                    holder.view_process_three.setBackground(CContext.getDrawable(activity, R.color.order_status_progress_bg_enable));

                    break;

                default:
                    setOrderStatusStepEnabled(holder.image_done_1, holder.step_onetxt, L.string.approval);
                    setOrderStatusStepEnabled(holder.image_done_2, holder.step_twotxt, L.string.processing);
                    setOrderStatusStepEnabled(holder.image_done_3, holder.step_threetxt, L.string.shipping);
                    setOrderStatusStepEnabled(holder.image_done_4, holder.step_fourtxt, L.string.delivered);

                    holder.view_process_one.setBackground(CContext.getDrawable(activity, R.color.order_status_progress_bg_enable));
                    holder.view_process_two.setBackground(CContext.getDrawable(activity, R.color.order_status_progress_bg_enable));
                    holder.view_process_three.setBackground(CContext.getDrawable(activity, R.color.order_status_progress_bg_enable));
                    break;
            }
        } else {
            holder.order_status_layout.setVisibility(View.GONE);
        }

        String createdDate = Helper.getDateByPattern(order.created_at);
        if (!TextUtils.isEmpty(createdDate)) {
            holder.txt_orderdate.setVisibility(View.VISIBLE);
            String finalDate = String.format(getString(L.string.order_created_date, true), createdDate);
            holder.txt_orderdate.setText(HtmlCompat.fromHtml(finalDate));
        } else {
            holder.txt_orderdate.setVisibility(View.GONE);
        }

        Adapter_OrdersProduct adapter = new Adapter_OrdersProduct(activity, order);

        if (AppInfo.SHOW_ORDER_AGAIN) {
            holder.button_order_again.setVisibility(View.VISIBLE);
            Helper.stylize(holder.button_order_again);
            holder.button_order_again.setText(getString(L.string.order_again));

            holder.button_order_again.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View view) {
                    loadLineItemProducts(holder, order);
                }

            });
        } else {
            holder.button_order_again.setVisibility(View.GONE);
        }

        if (AppInfo.REQUIRE_ORDER_PAYMENT_PROOF) {
            holder.txt_upload_image = (TextView) view.findViewById(R.id.txt_upload_image);
            holder.img_select_image = (ImageView) view.findViewById(R.id.img_select_image);
            holder.progress_upload_img = (ProgressBar) view.findViewById(R.id.progress_upload_img);
            Helper.stylize(holder.progress_upload_img);
            holder.progress_upload_img.setVisibility(View.GONE);
            holder.img_select_image.setOnClickListener(null);

            if (isMyOrder &&
                    !TextUtils.isEmpty(order.status) &&
                    order.status.equals("on-hold") &&
                    order.payment_details != null &&
                    order.payment_details.method_id.equals("bacs")) {
                holder.payment_proof_section.setVisibility(View.VISIBLE);
            } else {
                holder.payment_proof_section.setVisibility(View.GONE);
            }

            if (TextUtils.isEmpty(order.imgUploadUrl)) {
                holder.txt_upload_image.setText(getString(L.string.upload_payment_proof));
                holder.img_select_image.setOnClickListener(new OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        if (imageUploadListener != null) {
                            imageUploadListener.onImageUploadSelected(order, holder.progress_upload_img);
                        }
                    }
                });
            } else {
                holder.txt_upload_image.setText(getString(L.string.payment_proof_uploaded));
                holder.img_select_image.setOnClickListener(null);
            }
            Glide.with(activity)
                    .load(order.imgUploadUrl)
                    .placeholder(R.drawable.img_select_image)
                    .override(activity.getResources().getDimensionPixelSize(R.dimen.image_thumb_size_list), activity.getResources().getDimensionPixelSize(R.dimen.image_thumb_size_list))
                    .fitCenter()
                    .into(holder.img_select_image);
        }

        holder.list_track_btn = (LinearLayout) view.findViewById(R.id.list_track_btn);
        holder.list_track_btn.setVisibility(View.GONE);
        holder.list_track_btn.removeAllViews();

        for (final String trackingId : order.trackingIds) {
            Button btn_track = new Button(activity);
            btn_track.setText(getString(getString(L.string.track)));
            Helper.styleFlat(btn_track);
            int padding = Helper.DP(16);
            btn_track.setPadding(padding, padding, padding, padding);
            btn_track.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    ((MainActivity) activity).showShipmentStatusFragment(false, trackingId);
                }
            });
            LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT);
            params.setMargins(0, 0, 0, Helper.DP(8));
            holder.list_track_btn.addView(btn_track, params);
            holder.textShipmentIdError.setVisibility(View.GONE);
        }

        if (AppInfo.ENABLE_SHIPMENT_TRACKING) {
            if (isMyOrder &&
                    !TextUtils.isEmpty(order.status) &&
                    order.status.equals("on-hold") &&
                    order.payment_details != null &&
                    order.payment_details.method_id.equals("bacs")) {
                holder.list_track_btn.setVisibility(View.GONE);
            } else {
                holder.list_track_btn.setVisibility(View.VISIBLE);
            }
        }

        if (AppInfo.ENABLE_MULTI_STORE_CHECKOUT && !TextUtils.isEmpty(order.metaData)) {
            holder.text_meta_data.setText(order.metaData);
            holder.text_meta_data.setVisibility(View.VISIBLE);
        } else {
            holder.text_meta_data.setVisibility(View.GONE);
        }

        adapter.setParentAdapter(this);
        for (int i = 0; i < adapter.getCount(); i++) {
            View v = adapter.getView(i, null, null);
            holder.products.addView(v, new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT));
        }
        adapter.notifyDataSetChanged();

        //TODO : change order status according booking type order status
        if (AppInfo.SHOW_PRODUCTS_BOOKING_INFO && order.status.equalsIgnoreCase("pending") && order.orderBookingInfo != null && order.orderBookingInfo.order_id == order.id && order.orderBookingInfo.enable_payment && !order.orderBookingInfo.bookingStatusList.isEmpty() /*&& bookingPayBtnVisibility*/) {
            holder.button_booking_order_pay_again.setVisibility(View.VISIBLE);
            Helper.stylize(holder.button_booking_order_pay_again);
            holder.button_booking_order_pay_again.setText(getString(L.string.btn_order_booking_pay));

            holder.button_booking_order_pay_again.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View view) {
                    loadLineItemProducts(holder, order);
                }

            });
        } else {
            holder.button_booking_order_pay_again.setVisibility(View.GONE);
        }
        return view;
    }

    public void refresh() {
        notifyDataSetChanged();
    }

    private String getOrderStatusTitle(String c) {
        if (mOrderStatusMap != null) {
            for (Map.Entry<String, String> entry : mOrderStatusMap.entrySet()) {
                if (entry.getKey().equalsIgnoreCase(c)) {
                    return entry.getValue();
                }
            }
        }
        return "";
    }

    private String getOrderStatusString(String c) {
        if (mOrderStatusMap != null) {
            for (Map.Entry<String, String> entry : mOrderStatusMap.entrySet()) {
                if (entry.getValue().equals(c)) {
                    return entry.getKey();
                }
            }
        }
        return "";
    }

    private void loadLineItemProducts(final ViewHolder holder, final TM_Order order) {
        final List<TM_LineItem> lineItems = order.line_items;
        List<Integer> productIds = new ArrayList<>();

        for (TM_LineItem lineItem : lineItems) {
            productIds.add(lineItem.product_id);
        }

        boolean isAnyProductMissing = false;

        final List<TM_ProductInfo> allProducts = new ArrayList<>();

        for (int i = 0; i < productIds.size(); i++) {
            int id = productIds.get(i);
            TM_ProductInfo productInfo = TM_ProductInfo.findProductById(id);

            if (productInfo == null) {
                isAnyProductMissing = true;
                break;
            }

            if (productInfo.managing_stock) {
                if (!productInfo.backorders_allowed && !productInfo.in_stock) {
                    Helper.toast(L.string.product_out_of_stock);
                    break;
                }
            } else if (!productInfo.in_stock) {
                Helper.toast(L.string.product_out_of_stock);
                break;
            }

            if (AppInfo.SHOW_PRODUCTS_BOOKING_INFO && order.orderBookingInfo != null) {
                for (int j = 0; j < order.orderBookingInfo.bookingStatusList.size(); j++) {
                    OrderBookingInfo.BookingInfoStatus bookingInfoStatus = order.orderBookingInfo.bookingStatusList.get(j);
                    productInfo.orderAgainBookingId = String.valueOf(bookingInfoStatus.booking_id);
                    productInfo.orderAgainBookingDate = bookingInfoStatus.booking_start;
                }
            }

            if (productInfo.type == TM_ProductInfo.ProductType.VARIABLE) {
                isAnyProductMissing = true;
                allProducts.clear();
                break;
            }
            allProducts.add(productInfo);
        }

        if (isAnyProductMissing) {
            DataEngine.getDataEngine().getFullProductsInBackground(productIds, new DataQueryHandler<List<TM_ProductInfo>>() {
                @Override
                public void onSuccess(List<TM_ProductInfo> products) {
                    for (TM_LineItem lineItem : lineItems) {
                        TM_ProductInfo product = getProductByID(lineItem.product_id, products);

                        if (product == null)
                            continue;

                        int quantity = lineItem.quantity;
                        List<TM_VariationAttribute> selected_variationAttributes = new ArrayList<>();
                        if (product.managing_stock) {
                            if (!product.backorders_allowed && !product.in_stock) {
                                Helper.toast(L.string.product_out_of_stock);
                                break;
                            }
                        } else if (!product.in_stock) {
                            Helper.toast(L.string.product_out_of_stock);
                            break;
                        }

                        if (product.attributes.size() > 0) {
                            for (int i = 0; i < product.attributes.size(); i++) {
                                TM_Attribute attribute = product.attributes.get(i);
                                if (attribute.variation && !attribute.options.isEmpty()) {
                                    TM_VariationAttribute variationAttribute = attribute.getVariationAttribute(0);
                                    selected_variationAttributes.add(variationAttribute);
                                }
                            }
                        }
                        String[] metaArray = lineItem.meta.split("\\|");
                        for (String mp : metaArray) {
                            String name = mp.split(":")[0];
                            String value = mp.split(":")[1];

                            for (TM_VariationAttribute va : selected_variationAttributes) {
                                if (DataHelper.compareAttributeStrings(va.name, name)) {
                                    va.value = value;
                                    break;
                                }
                            }
                        }
                        TM_Variation selectedVariation = product.variations.findVariationWithAttributes(selected_variationAttributes);
                        if (selectedVariation != null) {
                            Cart.addProduct(product, selectedVariation.id, selectedVariation.index, quantity, selected_variationAttributes, order);
                            MainActivity.mActivity.openCartFragment();
                        } else {
                            Cart.addProduct(product, -1, -1, quantity, new ArrayList<TM_VariationAttribute>(), order);
                            Helper.toast(L.string.item_added_to_cart);
                            MainActivity.mActivity.openCartFragment();
                        }
                    }
                }

                @Override
                public void onFailure(Exception exception) {
                    exception.printStackTrace();
                }
            });
        } else {
            for (TM_LineItem lineItem : lineItems) {
                TM_ProductInfo product = getProductByID(lineItem.product_id, allProducts);
                if (product != null) {
                    // TODO Put qty count here
                    Cart.addProduct(product, -1, -1, lineItem.quantity, new ArrayList<TM_VariationAttribute>(), order);
                    MainActivity.mActivity.openCartFragment();
                }
            }
        }
    }

    private TM_ProductInfo getProductByID(int id, List<TM_ProductInfo> products) {
        for (int i = 0; i < products.size(); i++) {
            TM_ProductInfo product = products.get(i);
            if (product.id == id) {
                return product;
            }
            for (TM_Variation variation : product.variations) {
                if (variation.id == id) {
                    return product;
                }
            }
        }
        return null;
    }

    private void performCancelOrder(int orderId) {
        if (cancelRequestListener != null) {
            cancelRequestListener.onCancelRequested(orderId);
        }
    }

    private void setOrderStatusStepEnabled(ImageView imageView, TextView textView, String textKey) {
        imageView.setBackground(Helper.getShapeRoundBG_Green());
        imageView.setImageResource(R.drawable.ic_check_circle);
        textView.setText(getString(textKey));
    }

    private void setOrderStatusStepDisabled(ImageView imageView, TextView textView, String textKey) {
        imageView.setBackground(Helper.getShapeRoundBG_Gray());
        imageView.setImageResource(R.drawable.ic_vc_more_horiz);
        textView.setText(getString(textKey));
    }

    private void updateOrderStatusInBackground(TM_Order order, String status) {
        try {
            MainActivity.mActivity.showProgress(getString(L.string.updating_status), false);
            String str = JsonUtils.createOrderStatusJsonString(status);
            Log.d("-- str: [" + str + "] --");
            DataEngine.getDataEngine().updateOrderStatusInBackground(order.id, str, new DataQueryHandler<TM_Order>() {
                @Override
                public void onSuccess(TM_Order order) {
                    Log.d("aaa", "order" + order.status);
                }

                @Override
                public void onFailure(Exception reason) {
                    MainActivity.mActivity.hideProgress();
                    MainActivity.mActivity.generateOrderFailure(reason.getMessage());
                }
            });
        } catch (Exception e) {
            MainActivity.mActivity.hideProgress();
            MainActivity.mActivity.generateOrderFailure(e.getMessage());
        }
    }


    public void showOrderAddressDialog(final Activity activity, String titlemsg, final TM_Address address) {
        AlertDialog.Builder builder = new AlertDialog.Builder(activity);
        View view = LayoutInflater.from(activity).inflate(R.layout.dialog_show_order_address, null);

        LinearLayout header = (LinearLayout) view.findViewById(R.id.header_box);
        Helper.stylize(header);
        TextView header_msg = (TextView) view.findViewById(R.id.header_msg);
        header_msg.setText(titlemsg);
        Helper.stylizeActionBar(header_msg);

        final LinearLayout name_section = (LinearLayout) view.findViewById(R.id.name_section);
        final LinearLayout company_section = (LinearLayout) view.findViewById(R.id.company_section);
        final LinearLayout address1_section = (LinearLayout) view.findViewById(R.id.address1_section);
        final LinearLayout address2_section = (LinearLayout) view.findViewById(R.id.address2_section);
        final LinearLayout city_section = (LinearLayout) view.findViewById(R.id.city_section);
        final LinearLayout state_section = (LinearLayout) view.findViewById(R.id.state_section);
        final LinearLayout postcode_section = (LinearLayout) view.findViewById(R.id.postcode_section);
        final LinearLayout country_section = (LinearLayout) view.findViewById(R.id.country_section);
        final LinearLayout email_section = (LinearLayout) view.findViewById(R.id.email_section);
        final LinearLayout phone_section = (LinearLayout) view.findViewById(R.id.phone_section);

        Helper.setTextOnView(view, R.id.title_name, getString(L.string.name));
        Helper.setTextOnView(view, R.id.title_company, getString(L.string.company));
        Helper.setTextOnView(view, R.id.title_address1, getString(L.string.title_address1));
        Helper.setTextOnView(view, R.id.title_address2, getString(L.string.title_address2));
        Helper.setTextOnView(view, R.id.title_city, getString(L.string.city));
        Helper.setTextOnView(view, R.id.title_state, getString(L.string.state));
        Helper.setTextOnView(view, R.id.title_postcode, getString(L.string.postcode));
        Helper.setTextOnView(view, R.id.title_country, getString(L.string.country));
        Helper.setTextOnView(view, R.id.title_email, getString(L.string.email));
        Helper.setTextOnView(view, R.id.title_phone, getString(L.string.phone));

        final TextView txt_name = (TextView) view.findViewById(R.id.txt_name);
        final TextView txt_company = (TextView) view.findViewById(R.id.txt_company);
        final TextView txt_address1 = (TextView) view.findViewById(R.id.txt_address1);
        final TextView txt_address2 = (TextView) view.findViewById(R.id.txt_address2);
        final TextView txt_city = (TextView) view.findViewById(R.id.txt_city);
        final TextView txt_state = (TextView) view.findViewById(R.id.txt_state);
        final TextView txt_postcode = (TextView) view.findViewById(R.id.txt_postcode);
        final TextView txt_country = (TextView) view.findViewById(R.id.txt_country);
        final TextView txt_email = (TextView) view.findViewById(R.id.txt_email);
        final TextView txt_phone = (TextView) view.findViewById(R.id.txt_phone);

        if (!TextUtils.isEmpty(address.first_name) && !TextUtils.isEmpty(address.last_name)) {
            name_section.setVisibility(View.VISIBLE);
            txt_name.setVisibility(View.VISIBLE);
            txt_name.setText(address.first_name + " " + address.last_name);
        } else {
            name_section.setVisibility(View.GONE);
        }

        if (!TextUtils.isEmpty(address.company)) {
            company_section.setVisibility(View.VISIBLE);
            txt_company.setVisibility(View.VISIBLE);
            txt_company.setText(address.company);
        } else {
            company_section.setVisibility(View.GONE);
        }

        if (!TextUtils.isEmpty(address.address_1)) {
            address1_section.setVisibility(View.VISIBLE);
            txt_address1.setVisibility(View.VISIBLE);
            txt_address1.setText(address.address_1);
        } else {
            address2_section.setVisibility(View.GONE);
        }

        if (!TextUtils.isEmpty(address.address_2)) {
            address2_section.setVisibility(View.VISIBLE);
            txt_address2.setVisibility(View.VISIBLE);
            txt_address2.setText(address.address_2);
        } else {
            address2_section.setVisibility(View.GONE);
        }

        if (!TextUtils.isEmpty(address.city)) {
            city_section.setVisibility(View.VISIBLE);
            txt_city.setVisibility(View.VISIBLE);
            txt_city.setText(address.city);
        } else {
            city_section.setVisibility(View.GONE);
            txt_city.setVisibility(View.GONE);
        }

        if (!TextUtils.isEmpty(address.state)) {
            state_section.setVisibility(View.VISIBLE);
            txt_state.setVisibility(View.VISIBLE);
            txt_state.setText(address.state);
        } else {
            state_section.setVisibility(View.GONE);
        }

        if (!TextUtils.isEmpty(address.postcode)) {
            postcode_section.setVisibility(View.VISIBLE);
            txt_postcode.setVisibility(View.VISIBLE);
            txt_postcode.setText(address.postcode);
        } else {
            postcode_section.setVisibility(View.GONE);
        }

        if (!TextUtils.isEmpty(address.country)) {
            country_section.setVisibility(View.VISIBLE);
            txt_country.setVisibility(View.VISIBLE);
            txt_country.setText(address.country);
        } else {
            country_section.setVisibility(View.GONE);
        }

        if (!TextUtils.isEmpty(address.email)) {
            email_section.setVisibility(View.VISIBLE);
            txt_email.setVisibility(View.VISIBLE);
            txt_email.setText(address.email);
        } else {
            email_section.setVisibility(View.GONE);
        }

        if (!TextUtils.isEmpty(address.phone)) {
            phone_section.setVisibility(View.VISIBLE);
            txt_phone.setVisibility(View.VISIBLE);
            txt_phone.setText(address.phone);
        } else {
            phone_section.setVisibility(View.GONE);
        }

        Log.d("Address Billing", address.getAddressLine());
        ImageView iv_close = (ImageView) view.findViewById(R.id.iv_close);
        Helper.stylizeActionBar(iv_close);
        builder.setView(view).setCancelable(true);
        final AlertDialog alertDialog = builder.create();

        Button btn_map_locate = (Button) view.findViewById(R.id.btn_map_locate);
        Helper.stylize(btn_map_locate);
        Helper.setDrawableLeftOnButton(activity, btn_map_locate, R.drawable.ic_vc_location);
        if (AppInfo.USE_LAT_LONG_IN_ORDER) {
            btn_map_locate.setVisibility(View.VISIBLE);
            btn_map_locate.setText(getString(L.string.locate));
            btn_map_locate.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    alertDialog.dismiss();
                    if (Helper.isGoogleMapsInstalled(activity)) {
                        Helper.openNavigationLocation(activity, address.latitude, address.longitude, address.address_2);
                    } else {
                        AlertDialog.Builder builder = new AlertDialog.Builder(activity);
                        builder.setMessage(getString(L.string.msg_install_map_dialog));
                        builder.setCancelable(false);
                        builder.setPositiveButton(getString(L.string.install), new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface dialog, int which) {
                                final String packageName = "com.google.android.apps.maps";
                                Helper.openPlayStoreURI(activity, packageName);
                            }
                        });
                        builder.setNegativeButton(getString(L.string.cancel), new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface dialog, int which) {
                                dialog.dismiss();
                            }
                        });
                        AlertDialog dialog = builder.create();
                        dialog.show();
                    }
                }
            });
        } else {
            btn_map_locate.setVisibility(View.GONE);
        }

        iv_close.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                alertDialog.dismiss();
            }
        });
        alertDialog.show();
    }
}