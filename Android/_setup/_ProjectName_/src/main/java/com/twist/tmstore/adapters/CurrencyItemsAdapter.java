package com.twist.tmstore.adapters;

import android.content.Context;
import android.graphics.Bitmap;
import android.support.v7.widget.RecyclerView;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.RadioButton;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.animation.GlideAnimation;
import com.bumptech.glide.request.target.SimpleTarget;
import com.twist.dataengine.entities.CurrencyItem;
import com.twist.tmstore.R;
import com.utils.Helper;
import com.utils.customviews.CustomFontTextView;
import com.utils.customviews.RoundedImageView;

import java.util.List;

/**
 * Created by Twist Mobile on 8/28/2017.
 */

public class CurrencyItemsAdapter extends RecyclerView.Adapter<CurrencyItemsAdapter.ViewHolder> {

    private List<CurrencyItem> mCurrencyItems;
    private OnCurrencySelectionListener onCurrencySelectionListener;
    private int mSelectedItemIndex = 0;
    private int mLastSelectedItem;

    public CurrencyItemsAdapter(List<CurrencyItem> currencyItems) {
        this.mCurrencyItems = currencyItems;
    }

    public void setSelectedItemIndex(int selectedItemIndex) {
        this.mSelectedItemIndex = selectedItemIndex;
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        Context mContext = parent.getContext();
        View view = LayoutInflater.from(mContext).inflate(R.layout.currency_item, parent, false);
        ViewHolder viewHolder = new ViewHolder(view);
        return viewHolder;
    }

    @Override
    public void onBindViewHolder(final ViewHolder holder, final int position) {
        final CurrencyItem currencyItem = mCurrencyItems.get(position);
        holder.name.setText(currencyItem.getName());
        holder.description.setText(currencyItem.getDescription());
        holder.currency_radio_button.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mLastSelectedItem = mSelectedItemIndex;
                notifyItemChanged(mLastSelectedItem);
                mSelectedItemIndex = holder.getAdapterPosition();
                onCurrencySelectionListener.onSelectCurrency(currencyItem);
            }
        });

        if (!TextUtils.isEmpty(currencyItem.getFlag())) {
            holder.image_flag_bg.setVisibility(View.INVISIBLE);
            Glide.with(holder.itemView.getContext())
                    .load(currencyItem.getFlag())
                    .asBitmap()
                    .into(new SimpleTarget<Bitmap>() {
                        @Override
                        public void onResourceReady(Bitmap bitmap, GlideAnimation glideAnimation) {
                            holder.image_flag.setImageBitmap(bitmap);
                            holder.image_flag_bg.setVisibility(View.VISIBLE);
                        }
                    });
        } else {
            holder.image_flag_bg.setVisibility(View.GONE);
        }
        holder.currency_radio_button.setChecked(position == mSelectedItemIndex);
    }

    public void setCurrencySelectionListener(OnCurrencySelectionListener listener) {
        this.onCurrencySelectionListener = listener;
    }

    @Override
    public int getItemCount() {
        return mCurrencyItems != null ? mCurrencyItems.size() : 0;
    }

    public interface OnCurrencySelectionListener {
        void onSelectCurrency(CurrencyItem currencyItem);
    }

    public class ViewHolder extends RecyclerView.ViewHolder {
        CustomFontTextView name;
        RadioButton currency_radio_button;
        RoundedImageView image_flag;
        TextView description;
        LinearLayout image_flag_bg;

        public ViewHolder(View itemView) {
            super(itemView);
            name = (CustomFontTextView) itemView.findViewById(R.id.name);
            description = (TextView) itemView.findViewById(R.id.description);
            currency_radio_button = (RadioButton) itemView.findViewById(R.id.currency_radio_button);
            image_flag = (RoundedImageView) itemView.findViewById(R.id.image_flag);
            image_flag_bg = (LinearLayout) itemView.findViewById(R.id.image_flag_bg);
            currency_radio_button.setOnCheckedChangeListener(null);
            Helper.stylize(currency_radio_button);
        }
    }
}
