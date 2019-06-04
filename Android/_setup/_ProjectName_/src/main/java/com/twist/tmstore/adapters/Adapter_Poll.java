package com.twist.tmstore.adapters;

import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.twist.dataengine.entities.TM_ProductInfo;
import com.twist.tmstore.L;
import com.twist.tmstore.MainActivity;
import com.twist.tmstore.R;
import com.twist.tmstore.config.GuestUserConfig;
import com.twist.tmstore.entities.AppInfo;
import com.twist.tmstore.entities.Cart;
import com.twist.tmstore.fragments.Fragment_Opinions;
import com.utils.CContext;
import com.utils.Helper;
import com.utils.HtmlCompat;

import java.util.List;

public class Adapter_Poll extends BaseAdapter {
    private List<TM_ProductInfo> data;

    private Fragment_Opinions fragment;

    public Adapter_Poll(Fragment_Opinions fragment) {
        this.fragment = fragment;
    }

    public void setData(List<TM_ProductInfo> data) {
        this.data = data;
        notifyDataSetChanged();
    }

    public int getCount() {
        return data != null ? data.size() : 0;
    }

    public Object getItem(int position) {
        return data.get(position);
    }

    public long getItemId(int position) {
        return position;
    }

    private static class ViewHolder {
        ImageView image;
        ImageView img_likes;
        ImageView img_unlikes;
        TextView name;
        TextView price;
        TextView likes;
        TextView unlikes;
        ImageButton btn_cart;
    }

    public View getView(int position, View convertView, ViewGroup parent) {
        final TM_ProductInfo product = (TM_ProductInfo) getItem(position);

        View view = convertView;
        ViewHolder holder;
        if (convertView == null) {
            view = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_opinion, parent, false);
            holder = new ViewHolder();
            holder.image = (ImageView) view.findViewById(R.id.image);
            holder.img_likes = (ImageView) view.findViewById(R.id.img_likes);
            holder.img_unlikes = (ImageView) view.findViewById(R.id.img_unlikes);
            holder.name = (TextView) view.findViewById(R.id.name);
            holder.price = (TextView) view.findViewById(R.id.price);
            holder.likes = (TextView) view.findViewById(R.id.likes);
            holder.unlikes = (TextView) view.findViewById(R.id.unlikes);
            holder.btn_cart = (ImageButton) view.findViewById(R.id.btn_cart);
            holder.btn_cart.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View view) {
                    Cart.addProduct(product);
                    MainActivity.mActivity.reloadMenu();
                    Helper.toast(fragment.getRootLayout(), L.string.item_added_to_cart);
                }
            });

            Helper.stylizeVector(holder.btn_cart);

            view.setTag(holder);
        } else {
            holder = (ViewHolder) view.getTag();
        }

        holder.name.setText(product.title);
        holder.price.setText(String.format("Price: %s", HtmlCompat.fromHtml(Helper.appendCurrency(product.getActualPrice(), product))));
        holder.likes.setText(String.valueOf(product.likes));
        holder.unlikes.setText(String.valueOf(product.unlikes));

        if (product.likes > 0) {
            holder.likes.setTextColor(CContext.getColor(view.getContext(), R.color.highlight_text_color_2));
        }
        if (product.unlikes > 0) {
            holder.unlikes.setTextColor(CContext.getColor(view.getContext(), R.color.highlight_text_color));
        }

        Glide.with(parent.getContext())
                .load(product.thumb)
                .placeholder(AppInfo.ID_PLACEHOLDER_PRODUCT)
                .error(R.drawable.error_product)
                .into(holder.image);

        view.setOnClickListener(new ItemClickListener(product.id));
        if (AppInfo.HIDE_PRODUCT_PRICE_TAG || GuestUserConfig.hidePriceTag()) {
            holder.price.setVisibility(View.GONE);
        }
        return view;
    }

    class ItemClickListener implements OnClickListener {
        int itemId;

        public ItemClickListener(int itemId) {
            this.itemId = itemId;
        }

        @Override
        public void onClick(View v) {
            MainActivity.mActivity.openOrLoadProductInfo(this.itemId);
        }
    }
}