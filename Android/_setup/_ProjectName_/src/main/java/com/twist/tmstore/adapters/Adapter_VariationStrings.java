package com.twist.tmstore.adapters;

import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.utils.HtmlCompat;

import java.util.List;

public class Adapter_VariationStrings extends RecyclerView.Adapter<Adapter_VariationStrings.ViewHolder> {

    private List<String> items;
    private int layoutResId;
    private int textResId;

    public Adapter_VariationStrings(List<String> items, int layoutResId, int textResId) {
        this.items = items;
        this.layoutResId = layoutResId;
        this.textResId = textResId;
    }

    public class ViewHolder extends RecyclerView.ViewHolder {
        public TextView textView;

        public ViewHolder(View view) {
            super(view);
            textView = (TextView) view.findViewById(textResId);
        }
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        return new ViewHolder(LayoutInflater.from(parent.getContext()).inflate(layoutResId, parent, false));
    }

    @Override
    public void onBindViewHolder(final ViewHolder holder, int position) {
        holder.textView.setText(HtmlCompat.fromHtml(items.get(position)));
    }

    @Override
    public int getItemCount() {
        return items.size();
    }
}