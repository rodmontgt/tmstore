package com.twist.tmstore.adapters;

import android.app.Activity;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.twist.dataengine.DataQueryHandler;
import com.twist.dataengine.DataEngine;;
import com.twist.dataengine.entities.OrderBookingInfo;
import com.twist.dataengine.entities.TM_LineItem;
import com.twist.dataengine.entities.TM_Order;
import com.twist.dataengine.entities.TM_ProductInfo;
import com.twist.tmstore.L;
import com.twist.tmstore.R;
import com.twist.tmstore.entities.AppInfo;
import com.utils.ArrayUtils;
import com.utils.Helper;
import com.utils.HtmlCompat;

import java.util.ArrayList;
import java.util.List;

import static com.twist.tmstore.L.getString;

public class Adapter_OrdersProduct extends BaseAdapter {
    private Activity activity;
    private TM_Order order;
    private List data;
    private Adapter_OrdersList parentAdapter;

    private OnLayoutChangeListener layoutChangeListener;

    public interface OnLayoutChangeListener {
        void onLayoutChange();
    }

    public void setLayoutChangeListener(OnLayoutChangeListener layoutChangeListener) {
        this.layoutChangeListener = layoutChangeListener;
    }

    public void setParentAdapter(Adapter_OrdersList parentAdapter) {
        this.parentAdapter = parentAdapter;
    }

    public Adapter_OrdersProduct(Activity activity, TM_Order order) {
        this.activity = activity;
        this.order = order;
        this.data = (ArrayList) order.line_items;
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
        ImageView img;
        TextView name;
        TextView subtotal;
        TextView quantity;
        TextView attribute;
        View delivery_info_section;

        TextView deliveryDate;
        TextView deliveryTime;
        TextView text_product_name;

        LinearLayout order_booking_info_section;

        LinearLayout booking_id_section;
        TextView title_booking_id;
        TextView text_booking_id;

        LinearLayout booking_status_section;
        TextView title_booking_status;
        TextView text_booking_status;

        LinearLayout booking_start_date_section;
        TextView title_booking_start_date;
        TextView text_booking_start_date;

        LinearLayout booking_end_date_section;
        TextView title_booking_end_date;
        TextView text_booking_end_date;

        View separator;
    }

    public View getView(int position, View convertView, ViewGroup parent) {
        View view = convertView;
        ViewHolder holder;
        if (convertView == null) {
            if (parent == null) {
                view = LayoutInflater.from(activity).inflate(R.layout.item_order_product, null);
            } else {
                view = LayoutInflater.from(activity).inflate(R.layout.item_order_product, parent, false);
            }
            holder = new ViewHolder();
            holder.img = (ImageView) view.findViewById(R.id.img);
            holder.name = (TextView) view.findViewById(R.id.name);
            holder.subtotal = (TextView) view.findViewById(R.id.subtotal);
            holder.quantity = (TextView) view.findViewById(R.id.quantity);
            holder.attribute = (TextView) view.findViewById(R.id.attribute);
            holder.separator = view.findViewById(R.id.separator);


            holder.delivery_info_section = view.findViewById(R.id.delivery_info_section);
            holder.deliveryDate = (TextView) view.findViewById(R.id.text_delivery_date);
            holder.deliveryTime = (TextView) view.findViewById(R.id.text_delivery_time);
            holder.text_product_name = (TextView) view.findViewById(R.id.text_product_name);

            initBookingInfo(view, holder);

            view.setTag(holder);
        } else
            holder = (ViewHolder) view.getTag();

        holder.separator.setVisibility(position == 0 ? View.GONE : View.VISIBLE);

        TM_LineItem lineItem = (TM_LineItem) data.get(position);

        holder.name.setText(HtmlCompat.fromHtml(lineItem.name));
        if (AppInfo.HIDE_PRODUCT_PRICE_TAG) {
            holder.subtotal.setVisibility(View.GONE);
        } else {
            holder.subtotal.setVisibility(View.VISIBLE);
            holder.subtotal.setText(HtmlCompat.fromHtml(Helper.appendCurrency(lineItem.total)));
        }
        holder.quantity.setText(HtmlCompat.fromHtml(String.format(L.getString(L.string.order_quantity), lineItem.quantity)));
        if (TextUtils.isEmpty(lineItem.meta)) {
            holder.attribute.setVisibility(View.GONE);
        } else {
            holder.attribute.setVisibility(View.VISIBLE);
            holder.attribute.setText(HtmlCompat.fromHtml(lineItem.meta));
        }

        holder.delivery_info_section.setVisibility(View.GONE);
        if (AppInfo.ENABLE_PRODUCT_DELIVERY_DATE) {
            holder.delivery_info_section.setVisibility(View.VISIBLE);
            holder.deliveryDate.setVisibility(View.VISIBLE);
            holder.deliveryTime.setVisibility(View.VISIBLE);

            boolean error = true;
            try {
                String[] metaArray = lineItem.meta.split("\\|");
                int length = ArrayUtils.length(metaArray);
                if (length >= 2) {
                    holder.deliveryDate.setText(metaArray[length - 2]);
                    holder.deliveryTime.setText(metaArray[length - 1]);
                    error = false;
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            if (error) {
                holder.delivery_info_section.setVisibility(View.GONE);
            }
        }


        if (AppInfo.SHOW_PRODUCTS_BOOKING_INFO && order.orderBookingInfo != null) {
            holder.order_booking_info_section.setVisibility(View.VISIBLE);
            for (int i = 0; i < order.orderBookingInfo.bookingStatusList.size(); i++) {
                OrderBookingInfo.BookingInfoStatus bookingInfoStatus = order.orderBookingInfo.bookingStatusList.get(i);
                if (bookingInfoStatus != null) {
                    holder.booking_id_section.setVisibility(View.VISIBLE);
                    holder.text_booking_id.setText(String.valueOf(bookingInfoStatus.booking_id));
                    holder.booking_status_section.setVisibility(View.VISIBLE);
                    holder.text_booking_status.setText(HtmlCompat.fromHtml(bookingInfoStatus.status));
                    holder.booking_start_date_section.setVisibility(View.VISIBLE);
                    holder.text_booking_start_date.setText(HtmlCompat.fromHtml(bookingInfoStatus.booking_start));
                    holder.booking_end_date_section.setVisibility(View.VISIBLE);
                    holder.text_booking_end_date.setText(HtmlCompat.fromHtml(bookingInfoStatus.booking_end));
                }
            }
        }
        if (parentAdapter != null) {
            parentAdapter.notifyDataSetChanged();
        }
        notifyDataSetChanged();

        String thumbUrl = TM_ProductInfo.getThumbOfProduct(lineItem.product_id);
        if (TextUtils.isEmpty(thumbUrl)) {
            Glide.with(activity)
                    .load(R.drawable.placeholder_product)
                    .centerCrop()
                    .into(holder.img);

            getProductInfoInBackground(lineItem.product_id);

        } else {
            Glide.with(activity)
                    .load(thumbUrl)
                    .placeholder(Helper.getPlaceholderColor())
                    .error(R.drawable.placeholder_product)
                    .fitCenter()
                    .into(holder.img);
        }
        return view;
    }

    private void getProductInfoInBackground(int productId) {

        DataEngine.getDataEngine().getProductInfoInBackground(productId, new DataQueryHandler<TM_ProductInfo>() {
            @Override
            public void onSuccess(TM_ProductInfo data) {
                if (data != null) {
//                    //TODO : Change order status according booking type order status
//                    if (AppInfo.SHOW_PRODUCTS_BOOKING_INFO && order.status.equalsIgnoreCase("pending") && data.type == TM_ProductInfo.ProductType.BOOKING) {
//                        parentAdapter.enablePendingBookingPayBtn(true);
//                    }

                    if (parentAdapter != null) {
                        parentAdapter.notifyDataSetChanged();
                    } else {
                        notifyDataSetChanged();
                    }

                    if (layoutChangeListener != null) {
                        layoutChangeListener.onLayoutChange();
                    }
                }
            }

            @Override
            public void onFailure(Exception error) {
                error.printStackTrace();
            }
        });
    }

    private void initBookingInfo(View mRootView, ViewHolder holder) {
        holder.order_booking_info_section = (LinearLayout) mRootView.findViewById(R.id.order_booking_info_section);

        if (!AppInfo.SHOW_PRODUCTS_BOOKING_INFO) {
            holder.order_booking_info_section.setVisibility(View.GONE);
            return;
        }
        holder.order_booking_info_section.setVisibility(View.GONE);

        View view = LayoutInflater.from(activity).inflate(R.layout.order_product_booking_info_layout, holder.order_booking_info_section, true);

        holder.booking_id_section = (LinearLayout) view.findViewById(R.id.booking_id_section);
        holder.booking_id_section.setVisibility(View.GONE);
        holder.title_booking_id = (TextView) view.findViewById(R.id.title_booking_id);
        holder.title_booking_id.setText(getString(L.string.title_order_booking_id));
        holder.text_booking_id = (TextView) view.findViewById(R.id.text_booking_id);

        holder.booking_status_section = (LinearLayout) view.findViewById(R.id.booking_status_section);
        holder.booking_status_section.setVisibility(View.GONE);
        holder.title_booking_status = (TextView) view.findViewById(R.id.title_booking_status);
        holder.title_booking_status.setText(getString(L.string.title_order_booking_status));
        holder.text_booking_status = (TextView) view.findViewById(R.id.text_booking_status);

        holder.booking_start_date_section = (LinearLayout) view.findViewById(R.id.booking_start_date_section);
        holder.booking_start_date_section.setVisibility(View.GONE);
        holder.title_booking_start_date = (TextView) view.findViewById(R.id.title_booking_start_date);
        holder.title_booking_start_date.setText(getString(L.string.title_order_booking_start_date));
        holder.text_booking_start_date = (TextView) view.findViewById(R.id.text_booking_start_date);

        holder.booking_end_date_section = (LinearLayout) view.findViewById(R.id.booking_end_date_section);
        holder.booking_end_date_section.setVisibility(View.GONE);
        holder.title_booking_end_date = (TextView) view.findViewById(R.id.title_booking_end_date);
        holder.title_booking_end_date.setText(getString(L.string.title_order_booking_end_date));
        holder.text_booking_end_date = (TextView) view.findViewById(R.id.text_booking_end_date);
    }
}