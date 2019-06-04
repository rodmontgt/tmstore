package com.twist.tmstore.adapters;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.twist.tmstore.R;

import java.util.List;

/**
 * Created by Twist Mobile on 03-02-2017.
 */

public class PhoneNumberAdapter extends BaseAdapter {
    private List<String> items;

    public PhoneNumberAdapter(List<String> items) {
        this.items = items;
    }

    private static class ViewHolder {
        TextView titleText;
        ImageView iconImage;
    }

    public View getView(int position, View convertView, ViewGroup parent) {
        ViewHolder holder;
        if (convertView == null) {
            convertView = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_phone_number, parent, false);
            holder = new ViewHolder();
            holder.titleText = (TextView) convertView.findViewById(R.id.title);
            holder.iconImage = (ImageView) convertView.findViewById(R.id.icon);
            convertView.setTag(holder);
        } else {
            holder = (ViewHolder) convertView.getTag();
        }

        holder.titleText.setText(getItem(position).toString());
        holder.iconImage.setImageResource(R.drawable.ic_vc_call);

        return convertView;
    }

    @Override
    public int getCount() {
        return items.size();
    }

    @Override
    public Object getItem(int position) {
        return items.get(position);
    }

    @Override
    public long getItemId(int position) {
        return position;
    }
}