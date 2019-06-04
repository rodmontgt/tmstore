package com.twist.tmstore.adapters;

import android.content.Context;
import android.support.v7.widget.CardView;
import android.support.v7.widget.RecyclerView;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.bumptech.glide.Glide;
import com.twist.dataengine.entities.TM_Bundle;
import com.twist.dataengine.entities.TM_ProductInfo;
import com.twist.tmstore.L;
import com.twist.tmstore.MainActivity;
import com.twist.tmstore.R;
import com.twist.tmstore.entities.AppInfo;
import com.utils.HtmlCompat;

import java.util.List;

public class Adapter_BundledProduct extends RecyclerView.Adapter<Adapter_BundledProduct.BundledProductViewHolder> {

    private List<TM_Bundle> bundles;

    private Context context;

    class BundledProductViewHolder extends RecyclerView.ViewHolder {
        ImageView productImageView;
        TextView nameTextView;
        TextView freeTextView;

        BundledProductViewHolder(View view) {
            super(view);
            productImageView = (ImageView) view.findViewById(R.id.image_product);
            nameTextView = (TextView) view.findViewById(R.id.text_name);
            freeTextView = (TextView) view.findViewById(R.id.text_free);
            CardView cardView = (CardView) view.findViewById(R.id.card_view);
            cardView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    TM_ProductInfo product = bundles.get(getLayoutPosition()).getProduct();
                    MainActivity.mActivity.openProductInfo(product);
                }
            });
            cardView.setOnLongClickListener(new View.OnLongClickListener() {
                @Override
                public boolean onLongClick(View view) {
                    showDetails();
                    return true;
                }
            });
        }

        void bindData(int position) {
            TM_Bundle bundle = bundles.get(position);
            TM_ProductInfo product = bundle.getProduct();
            if (product != null) {
                Glide.with(context)
                        .load(product.thumb)
                        .placeholder(AppInfo.ID_PLACEHOLDER_PRODUCT)
                        .error(R.drawable.error_product)
                        .into(productImageView);
                nameTextView.setText(HtmlCompat.fromHtml(product.title));
                freeTextView.setText(String.format(L.getString(L.string.bundle_free_quantity), bundle.getBundleQuantity()));
            }
        }

        void showDetails() {
            TM_Bundle bundle = bundles.get(getLayoutPosition());
            TM_ProductInfo product = bundle.getProduct();
            if (!TextUtils.isEmpty(product.getShortDescription())) {
                Toast.makeText(context, HtmlCompat.fromHtml(product.getShortDescription()).toString().trim(), Toast.LENGTH_SHORT).show();
            }
        }
    }

    public Adapter_BundledProduct(Context context, List<TM_Bundle> bundles) {
        this.context = context;
        this.bundles = bundles;
    }

    @Override
    public int getItemCount() {
        return bundles.size();
    }

    @Override
    public BundledProductViewHolder onCreateViewHolder(ViewGroup viewGroup, int type) {
        LayoutInflater inflater = LayoutInflater.from(viewGroup.getContext());
        return new BundledProductViewHolder(inflater.inflate(R.layout.item_bundled_product_list, viewGroup, false));
    }

    @Override
    public void onBindViewHolder(BundledProductViewHolder viewHolder, final int position) {
        viewHolder.bindData(position);
    }
}