package com.twist.tmstore.adapters;

import android.content.Context;
import android.support.v4.content.res.ResourcesCompat;
import android.support.v7.widget.CardView;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.twist.tmstore.MainActivity;
import com.twist.tmstore.R;
import com.twist.tmstore.entities.Notification;
import com.twist.tmstore.listeners.ModificationListener;
import com.utils.CContext;
import com.utils.Helper;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * Created by Twist Mobile on 03-01-2017.
 */
public class Adapter_NotificationList extends RecyclerView.Adapter<Adapter_NotificationList.NotificationsViewHolder> {
    private Context context;
    private List<Notification> notifications = new ArrayList<>();
    private ModificationListener mModificationListener;

    public Adapter_NotificationList(Context context) {
        this.context = context;
    }

    @Override
    public NotificationsViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View itemView = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_notification_listrow, parent, false);
        return new NotificationsViewHolder(itemView);
    }

    public void setModificationListener(ModificationListener obj) {
        mModificationListener = obj;
    }

    @Override
    public void onBindViewHolder(final NotificationsViewHolder holder, int position) {

        final Notification notification = notifications.get(position);
        holder.tv_notification_description.setText(notification.getAlert());
        holder.tv_notification_title.setText(notification.getTitle());


        switch (notification.getType()) {
            case CATEGORY:
                Helper.stylize(holder.iv_notification);
                holder.iv_notification.setImageDrawable(ResourcesCompat.getDrawable(context.getResources(), R.drawable.ic_vc_categories, null));
                holder.iv_expand.setVisibility(View.VISIBLE);
                break;
            case PRODUCT:
                Helper.stylize(holder.iv_notification);
                holder.iv_notification.setImageDrawable(ResourcesCompat.getDrawable(context.getResources(), R.drawable.ic_vc_notification, null));
                holder.iv_expand.setVisibility(View.VISIBLE);
                break;
            case CART:
                if (Helper.isValidString(notification.getContent())) {
                    holder.iv_notification.setImageDrawable(ResourcesCompat.getDrawable(context.getResources(), R.drawable.ic_vc_coupon, null));
                } else {
                    holder.iv_notification.setImageDrawable(ResourcesCompat.getDrawable(context.getResources(), R.drawable.ic_vc_cart, null));
                }
                Helper.stylize(holder.iv_notification);
                holder.iv_expand.setVisibility(View.VISIBLE);
                break;
            case WISHLIST:
                Helper.stylize(holder.iv_notification);
                holder.iv_notification.setImageDrawable(ResourcesCompat.getDrawable(context.getResources(), R.drawable.ic_vc_wish_flat, null));
                holder.iv_expand.setVisibility(View.VISIBLE);
                break;
            case ORDER:
            case SELLER_ORDER:
                Helper.stylize(holder.iv_notification);
                holder.iv_notification.setImageDrawable(ResourcesCompat.getDrawable(context.getResources(), R.drawable.ic_vc_orders, null));
                holder.iv_expand.setVisibility(View.VISIBLE);
                break;
            case DEFAULT:
                Helper.stylize(holder.iv_notification);
                holder.iv_expand.setVisibility(View.GONE);
                break;
        }
        holder.item_bg.setBackgroundColor(CContext.getColor(context, notification.isRead() ? R.color.white : R.color.new_notification_bg_color));
        holder.cv.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                notification.setRead();
                notifyDataSetChanged();
                MainActivity.mActivity.handleNotification(notification);
            }
        });

        holder.tv_notification_time.setText(notification.getTime());
//        NotificationManager notifManager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
//        notifManager.cancel(notification.id);
    }

    @Override
    public int getItemCount() {
        return notifications.size();
    }

    public void remove(int position) {
        notifications.get(position).delete();
        notifications.remove(position);
        if (mModificationListener != null) {
            mModificationListener.onModificationDone();
        }
        notifyItemRemoved(position);
    }

    public void addNotifications(List<Notification> notificationList) {
        notifications.clear();
        notifications.addAll(notificationList);
        notifyDataSetChanged();
    }

    public void swap(int firstPosition, int secondPosition) {
        Collections.swap(notifications, firstPosition, secondPosition);
        notifyItemMoved(firstPosition, secondPosition);
    }

    public class NotificationsViewHolder extends RecyclerView.ViewHolder {
        TextView tv_notification_title;
        TextView tv_notification_description;
        TextView tv_notification_time;
        ImageView iv_notification, iv_expand;
        CardView cv;
        RelativeLayout item_bg;

        public NotificationsViewHolder(View itemView) {
            super(itemView);
            tv_notification_title = (TextView) itemView.findViewById(R.id.tv_notification_title);
            tv_notification_description = (TextView) itemView.findViewById(R.id.tv_notification_description);
            tv_notification_time = (TextView) itemView.findViewById(R.id.tv_notification_time);
            iv_notification = (ImageView) itemView.findViewById(R.id.iv_notification_icon);
            cv = (CardView) itemView.findViewById(R.id.cv);
            item_bg = (RelativeLayout) itemView.findViewById(R.id.item_bg);
            iv_expand = (ImageView) itemView.findViewById(R.id.iv_expand);
        }
    }
}
