package com.twist.tmstore.adapters;

import android.support.v4.widget.TextViewCompat;
import android.support.v7.widget.RecyclerView;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.twist.dataengine.entities.TM_CategoryInfo;
import com.twist.tmstore.MainActivity;
import com.twist.tmstore.R;
import com.utils.CContext;


import java.util.List;

/**
 * Created by Twist Mobile on 12/8/2016.
 */

public class Adapter_Tiny_Categories extends RecyclerView.Adapter<Adapter_Tiny_Categories.CouponItemViewHolder> {

    class CouponItemViewHolder extends RecyclerView.ViewHolder implements View.OnClickListener {
        public TextView name;
        public ImageView image;
        LinearLayout quantity_section, tiny_product;

        CouponItemViewHolder(View view) {
            super(view);

            name = (TextView) itemView.findViewById(R.id.name);
            name.setGravity(Gravity.CENTER | Gravity.CENTER_HORIZONTAL);

            image = (ImageView) itemView.findViewById(R.id.image);
            image.setVisibility(View.GONE);

            quantity_section = (LinearLayout) itemView.findViewById(R.id.quantity_section);
            tiny_product = (LinearLayout) itemView.findViewById(R.id.tiny_product);
            quantity_section.setVisibility(View.GONE);
            tiny_product.setOnClickListener(this);
        }

        @Override
        public void onClick(View view) {
            MainActivity.mActivity.expandCategory(categoriesList.get(getLayoutPosition()));
        }
    }

    private List<TM_CategoryInfo> categoriesList;
    private boolean categoryType;

    public Adapter_Tiny_Categories(List<TM_CategoryInfo> categoriesList, boolean categoryType) {
        this.categoriesList = categoriesList;
        this.categoryType = categoryType;
    }

    @Override
    public Adapter_Tiny_Categories.CouponItemViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View itemView = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_mixmatch_product_list, parent, false);
        return new Adapter_Tiny_Categories.CouponItemViewHolder(itemView);
    }

    @Override
    public void onBindViewHolder(Adapter_Tiny_Categories.CouponItemViewHolder holder, int position) {
        TM_CategoryInfo categories = categoriesList.get(position);
        getItemCategory(categoriesList, position);
        holder.name.setText(categories.getName());
        if (categoryType) {
            holder.image.setVisibility(View.VISIBLE);
            holder.name.setBackgroundColor(CContext.getColor(holder.itemView.getContext(), R.color.color_bg_theme));
            Glide.with(holder.itemView.getContext()).load(categories.image)
                    .placeholder(R.drawable.app_icon)
                    .error(R.drawable.app_icon)
                    .into(holder.image);
        } else {
            holder.image.setVisibility(View.GONE);
            TextViewCompat.setTextAppearance(holder.name, android.R.style.TextAppearance_Small);
            holder.name.setGravity(Gravity.START | Gravity.CENTER_HORIZONTAL);
        }
    }

    @Override
    public int getItemCount() {
        return categoriesList.size();
    }

    public void addAll(List<TM_CategoryInfo> data) {
        categoriesList.addAll(data);
        notifyDataSetChanged();
    }

    TM_CategoryInfo getItemCategory(List<TM_CategoryInfo> categoriesInfo, int position) {
        return categoriesInfo.get(position);
    }
}
