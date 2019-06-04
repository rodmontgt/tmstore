package com.twist.tmstore.adapters;

import android.content.Context;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;

import com.twist.tmstore.R;
import com.utils.HtmlCompat;

import java.util.Collection;
import java.util.List;

public class Adapter_HtmlString extends ArrayAdapter<Object> {

    final private int layoutResId;
    final private int textViewResId;
    private LayoutInflater inflater;

    public static class ViewHolder {
        public TextView text;
    }

    public Adapter_HtmlString(Context context, List data, int layoutResId, int textViewResId) {
        super(context, layoutResId, textViewResId, data);
        this.layoutResId = layoutResId;
        this.textViewResId = textViewResId;
        inflater = LayoutInflater.from(context);
    }

    public Adapter_HtmlString(Context context, List data) {
        this(context, data, R.layout.item_spinner, R.id.text1);
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @NonNull
    @Override
    public View getView(int position, View convertView, @NonNull ViewGroup parent) {
        ViewHolder holder;
        if (convertView == null) {
            convertView = inflater.inflate(layoutResId, parent, false);
            holder = new ViewHolder();
            holder.text = (TextView) convertView.findViewById(textViewResId);
            convertView.setTag(holder);
        } else {
            holder = (ViewHolder) convertView.getTag();
        }
        holder.text.setText(HtmlCompat.fromHtml(getItem(position).toString()));
        return convertView;
    }

    @Override
    public View getDropDownView(int position, @Nullable View convertView, @NonNull ViewGroup parent) {
        return getView(position, convertView, parent);
    }

    public int findItem(String keyword) {
        for (int i = 0; i < getCount(); i++) {
            String item = getItem(i).toString();
            if (item != null && item.equals(keyword)) {
                return i;
            }
        }
        return -1;
    }

    public void updateItems(Collection newData) {
        clear();
        addAll(newData);
    }
}