package com.twist.tmstore.adapters;

import android.app.Activity;
import android.support.v7.widget.CardView;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Filter;
import android.widget.ImageView;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.twist.tmstore.BuildConfig;
import com.twist.tmstore.R;
import com.twist.tmstore.config.MultiStoreConfig;
import com.utils.CContext;

import java.util.ArrayList;
import java.util.List;

public class Adapter_MultiStoreList extends RecyclerView.Adapter<Adapter_MultiStoreList.ViewHolder> {

    private List<MultiStoreConfig> filteredList;
    private List<MultiStoreConfig> originalList;
    private Filter textFilter = null;
    private View.OnClickListener mOnClickListener;
    Activity mContext;

    public Adapter_MultiStoreList(Activity context, List<MultiStoreConfig> list) {
        filteredList = list;
        originalList = list;
        mContext = context;
    }

    public class ViewHolder extends RecyclerView.ViewHolder {
        CardView cv;
        ImageView product_img;
        TextView vName;
        TextView vDesc;

        public ViewHolder(View itemView) {
            super(itemView);
            cv = (CardView) itemView.findViewById(R.id.cv);
            product_img = (ImageView) itemView.findViewById(R.id.product_img);
            vName = (TextView) itemView.findViewById(R.id.name);
            vDesc = (TextView) itemView.findViewById(R.id.details);
        }
    }

    public void setOnClickListener(View.OnClickListener listener) {
        this.mOnClickListener = listener;
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        return new ViewHolder(LayoutInflater.from(parent.getContext()).inflate(R.layout.item_multi_store_list, parent, false));
    }

    @Override
    public void onBindViewHolder(final ViewHolder holder, final int position) {
        final MultiStoreConfig multiStoreConfig = filteredList.get(position);
        holder.itemView.setTag(multiStoreConfig.getPlatform());
        holder.itemView.setOnClickListener(mOnClickListener);
        holder.vName.setText(multiStoreConfig.getTitle());
        holder.vDesc.setText(multiStoreConfig.getDescription());

        if (BuildConfig.SEARCH_NEARBY && !multiStoreConfig.isActive()) {
            holder.itemView.setOnClickListener(null);
            holder.cv.setBackgroundColor(CContext.getColor(mContext, R.color.color_disable_bg));
            holder.vName.setTextColor(CContext.getColor(mContext, R.color.disable_button_color));
            holder.vDesc.setTextColor(CContext.getColor(mContext, R.color.disable_button_color));
        }

        Glide.with(holder.itemView.getContext())
                .load(multiStoreConfig.getIcon_url())
                .asBitmap()
                .centerCrop()
                .placeholder(R.drawable.app_icon)
                .into(holder.product_img);
    }

    @Override
    public int getItemCount() {
        return filteredList.size();
    }

    public Filter getTextFilter() {
        if (textFilter == null) {
            textFilter = new Filter() {
                @Override
                protected FilterResults performFiltering(CharSequence constraint) {
                    final FilterResults filterResults = new FilterResults();
                    final List<MultiStoreConfig> results = new ArrayList<>();
                    if (constraint != null) {
                        if (originalList != null && originalList.size() > 0) {
                            final String[] keyWords = constraint.toString().split(" ");
                            for (final MultiStoreConfig product : originalList) {
                                if (product.hasKeyWords(keyWords)) {
                                    results.add(product);
                                }
                            }
                        }
                        filterResults.values = results;
                    }
                    return filterResults;
                }

                @SuppressWarnings("unchecked")
                @Override
                protected void publishResults(CharSequence constraint, FilterResults results) {
                    filteredList = (List<MultiStoreConfig>) results.values;
                    notifyDataSetChanged();
                }
            };
        }
        return textFilter;
    }

    public void clearFilter() {
        filteredList = originalList;
    }
}