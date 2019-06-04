package com.twist.tmstore.adapters;

import android.app.Activity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import com.twist.dataengine.entities.TM_ProductReview;
import com.twist.tmstore.L;
import com.twist.tmstore.R;
import com.utils.HtmlCompat;

import java.text.SimpleDateFormat;
import java.util.List;

import static com.twist.tmstore.L.getString;

public class Adapter_ProductReviewsList extends BaseAdapter {

    private List<TM_ProductReview> productReviews;
    private LayoutInflater layoutInflater;

    public Adapter_ProductReviewsList(Activity activity, List<TM_ProductReview> productReviews) {
        this.productReviews = productReviews;
        this.layoutInflater = LayoutInflater.from(activity);
    }

    public int getCount() {
        int size = productReviews.size();
        return size > 0 ? size : 1;
    }

    public Object getItem(int position) {
        return position;
    }

    public long getItemId(int position) {
        return position;
    }

    public static class ViewHolder {
        public TextView content;
        public TextView name;
        public TextView date;
    }

    public View getView(int position, View convertView, ViewGroup parent) {
        View view = convertView;
        ViewHolder holder;
        if (convertView == null) {
            if (parent == null) {
                view = layoutInflater.inflate(R.layout.item_review, null);
            } else {
                view = layoutInflater.inflate(R.layout.item_review, parent, false);
            }

            holder = new ViewHolder();
            holder.name = (TextView) view.findViewById(R.id.name);
            holder.content = (TextView) view.findViewById(R.id.review_content);
            holder.date = (TextView) view.findViewById(R.id.date);
            view.setTag(holder);
        } else
            holder = (ViewHolder) view.getTag();

        if (productReviews.isEmpty()) {
            holder.content.setText(getString(L.string.msg_no_review));
            holder.name.setVisibility(View.GONE);
            holder.date.setVisibility(View.GONE);
        } else {
            TM_ProductReview productReview = productReviews.get(position);
            holder.name.setText(productReview.reviewer_name);
            holder.content.setText(HtmlCompat.fromHtml(productReview.review));
            SimpleDateFormat ft = new SimpleDateFormat("dd/MM/yyyy");
            holder.date.setText(ft.format(productReview.created_at));
        }
        return view;
    }
}