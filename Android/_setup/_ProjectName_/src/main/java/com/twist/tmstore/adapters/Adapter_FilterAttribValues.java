package com.twist.tmstore.adapters;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.CheckBox;

import com.utils.HtmlCompat;

import java.util.ArrayList;

public class Adapter_FilterAttribValues extends BaseAdapter {

    private ArrayList data;
    private static LayoutInflater inflater = null;
    String tempValues = null;
    int layoutResId;
    int chkBoxResId;

    public Adapter_FilterAttribValues(Context context, ArrayList data, int layoutResId, int chkBoxResId) {
        //activity = a;
        this.data = data;
        this.layoutResId = layoutResId;
        this.chkBoxResId = chkBoxResId;
        inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
    }

    public static class ViewHolder {
        public CheckBox checkBox;
    }

    @Override
    public int getCount() {
        return data.size();
    }

    @Override
    public Object getItem(int position) {
        return data.get(position);
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    public View getView(int position, View convertView, ViewGroup parent) {
        View vi = convertView;
        ViewHolder holder;
        if (convertView == null) {
            vi = inflater.inflate(layoutResId, null);
            holder = new ViewHolder();
            holder.checkBox = (CheckBox) vi.findViewById(chkBoxResId);
            vi.setTag(holder);
        } else
            holder = (ViewHolder) vi.getTag();
        tempValues = (String) data.get(position);
        holder.checkBox.setText(HtmlCompat.fromHtml(tempValues));
        return vi;
    }
}