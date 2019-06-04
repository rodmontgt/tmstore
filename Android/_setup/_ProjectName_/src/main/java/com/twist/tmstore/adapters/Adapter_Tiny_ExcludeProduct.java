package com.twist.tmstore.adapters;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.twist.dataengine.entities.TM_ProductInfo;
import com.twist.tmstore.MainActivity;
import com.twist.tmstore.R;
import com.utils.Helper;

import java.util.List;

/**
 * Created by Twist Mobile on 12/7/2016.
 */

public class Adapter_Tiny_ExcludeProduct extends RecyclerView.Adapter<Adapter_Tiny_ExcludeProduct.CouponsExcludeProductsViewHolder> {

    private List<TM_ProductInfo> excludeProductList;
    Context context;

    Adapter_Tiny_ExcludeProduct(List<TM_ProductInfo> excludeProductList) {
        this.excludeProductList = excludeProductList;
    }

    @Override
    public CouponsExcludeProductsViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View itemView = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_mixmatch_product_list, parent, false);
        return new Adapter_Tiny_ExcludeProduct.CouponsExcludeProductsViewHolder(itemView);
    }

    @Override
    public void onBindViewHolder(CouponsExcludeProductsViewHolder holder, int position) {
        TM_ProductInfo product = excludeProductList.get(position);
        Glide.with(holder.itemView.getContext()).load(product.thumb)
                .placeholder(R.drawable.app_icon)
                .error(R.drawable.app_icon)
                .into(holder.image);

        holder.name.setText(product.title);
    }

    @Override
    public int getItemCount() {
        return excludeProductList.size();
    }

    public void addAll(List<TM_ProductInfo> data) {
        excludeProductList.addAll(data);
        notifyDataSetChanged();
    }

    class CouponsExcludeProductsViewHolder extends RecyclerView.ViewHolder implements View.OnClickListener {
        TextView name;
        ImageView image;
        LinearLayout quantity_section, tiny_product;

        CouponsExcludeProductsViewHolder(View itemView) {
            super(itemView);
            name = (TextView) itemView.findViewById(R.id.name);
            Helper.setTextAppearance(itemView.getContext(), name, android.R.style.TextAppearance_Small);
            image = (ImageView) itemView.findViewById(R.id.image);
            image.setVisibility(View.GONE);
            name.setGravity(Gravity.START | Gravity.CENTER_HORIZONTAL);
            quantity_section = (LinearLayout) itemView.findViewById(R.id.quantity_section);
            tiny_product = (LinearLayout) itemView.findViewById(R.id.tiny_product);
            quantity_section.setVisibility(View.GONE);
            tiny_product.setOnClickListener(this);
        }

        @Override
        public void onClick(View view) {
            MainActivity.mActivity.openProductInfo(excludeProductList.get(getLayoutPosition()));
        }
    }
}
