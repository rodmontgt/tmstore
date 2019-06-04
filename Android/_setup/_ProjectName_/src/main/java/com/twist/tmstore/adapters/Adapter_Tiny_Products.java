package com.twist.tmstore.adapters;

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
import com.utils.HtmlCompat;

import java.util.List;

public class Adapter_Tiny_Products extends RecyclerView.Adapter<Adapter_Tiny_Products.CouponsProductsViewHolder> {

    private List<TM_ProductInfo> productList;

    Adapter_Tiny_Products(List<TM_ProductInfo> productList) {
        this.productList = productList;
    }

    @Override
    public CouponsProductsViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View itemView = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_mixmatch_product_list, parent, false);
        return new CouponsProductsViewHolder(itemView);
    }

    @Override
    public void onBindViewHolder(CouponsProductsViewHolder holder, int position) {
        TM_ProductInfo product = productList.get(position);
        Glide.with(holder.itemView.getContext()).load(product.thumb)
                .placeholder(R.drawable.app_icon)
                .error(R.drawable.app_icon)
                .into(holder.image);

        holder.name.setText(product.title);
        holder.product_price.setText(HtmlCompat.fromHtml(Helper.appendCurrency(product.getActualPrice(), product)));
    }

    @Override
    public int getItemCount() {
        return productList.size();
    }

    public void addAll(List<TM_ProductInfo> data) {
        productList.addAll(data);
        notifyDataSetChanged();
    }

    class CouponsProductsViewHolder extends RecyclerView.ViewHolder implements View.OnClickListener {
        TextView name, product_price;
        ImageView image;
        LinearLayout quantity_section, tiny_product;

        CouponsProductsViewHolder(View view) {
            super(view);
            image = (ImageView) view.findViewById(R.id.image);
            name = (TextView) view.findViewById(R.id.name);
            name.setGravity(Gravity.START | Gravity.CENTER_HORIZONTAL);
            quantity_section = (LinearLayout) view.findViewById(R.id.quantity_section);
            tiny_product = (LinearLayout) view.findViewById(R.id.tiny_product);
            quantity_section.setVisibility(View.GONE);
            product_price = (TextView) view.findViewById(R.id.price);
            product_price.setVisibility(View.VISIBLE);
            tiny_product.setOnClickListener(this);
        }

        @Override
        public void onClick(View view) {
            MainActivity.mActivity.openProductInfo(productList.get(getLayoutPosition()));
        }
    }
}
