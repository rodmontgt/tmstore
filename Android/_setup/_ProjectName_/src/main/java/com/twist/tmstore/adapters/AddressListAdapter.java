package com.twist.tmstore.adapters;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import com.twist.tmstore.L;
import com.twist.tmstore.R;
import com.twist.tmstore.entities.Address;

import java.util.ArrayList;

import static com.twist.tmstore.L.getString;

public class AddressListAdapter extends BaseAdapter {

    private ArrayList<Address> items;

    public AddressListAdapter(ArrayList<Address> items) {
        this.items = items;
    }

    public int getCount() {
        return items.size();
    }

    public Object getItem(int position) {
        return position;
    }

    public long getItemId(int position) {
        return position;
    }

    public static class ViewHolder {
        TextView text_0;
        TextView text_1;
        TextView text_2;
    }

    public View getView(int position, View convertView, ViewGroup parent) {
        View view = convertView;
        ViewHolder holder;
        if (convertView == null) {
            view = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_address, parent, false);
            holder = new ViewHolder();
            holder.text_0 = (TextView) view.findViewById(R.id.text_0);
            holder.text_1 = (TextView) view.findViewById(R.id.text_1);
            holder.text_2 = (TextView) view.findViewById(R.id.text_2);
            view.setTag(holder);
        } else {
            holder = (ViewHolder) view.getTag();
        }

        Address address = items.get(position);
        if (address != null) {
            holder.text_0.setText(address.title);
            holder.text_1.setText(address.first_name + " " + address.last_name);
            holder.text_2.setText(address.getAddressLine());
        } else {
            holder.text_0.setText(getString(L.string.address_not_set));
        }
        return view;
    }
}