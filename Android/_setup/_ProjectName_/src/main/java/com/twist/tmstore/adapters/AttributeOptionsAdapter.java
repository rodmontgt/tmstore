package com.twist.tmstore.adapters;

import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.Drawable;
import android.support.v7.widget.RecyclerView;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.twist.dataengine.entities.ShortAttribute;
import com.twist.tmstore.R;
import com.twist.tmstore.entities.AppInfo;
import com.twist.tmstore.listeners.OnAttributeOptionClickListener;
import com.utils.CContext;
import com.utils.Helper;
import com.utils.HtmlCompat;


import java.util.List;

/**
 * Created by Twist Mobile on 8/22/2017.
 */

public class AttributeOptionsAdapter extends RecyclerView.Adapter<AttributeOptionsAdapter.ViewHolder> {

    ViewHolder viewHolder;
    int position;
    private List termList;
    private Context context;
    private int selectedPosition = -1;
    private LayoutType layoutType;

    private OnAttributeOptionClickListener mOnAttributeOptionClickListener;
    public AttributeOptionsAdapter(Context context, int position, List termList, LayoutType layoutType) {
        this.context = context;
        this.termList = termList;
        this.layoutType = layoutType;
        this.position = position;
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup viewGroup, int viewType) {
        LayoutInflater inflater = LayoutInflater.from(viewGroup.getContext());
        if (layoutType == LayoutType.IMAGE) {
            viewHolder = new ViewHolder(inflater.inflate(R.layout.item_attribute_term_images, viewGroup, false));
        } else if (layoutType == LayoutType.TEXT) {
            viewHolder = new ViewHolder(inflater.inflate(R.layout.item_attribute_text, viewGroup, false));
        }
        return viewHolder;
    }

    @Override
    public void onBindViewHolder(AttributeOptionsAdapter.ViewHolder holder, int position) {
        holder.bindView(position);
    }

    @Override
    public int getItemCount() {
        return termList.size();
    }

    void setOptionSelectionListener(OnAttributeOptionClickListener onAttributeOptionClickListener) {
        this.mOnAttributeOptionClickListener = onAttributeOptionClickListener;
    }

    public enum LayoutType {
        TEXT,
        IMAGE
    }

    public class ViewHolder extends RecyclerView.ViewHolder {
        ImageView productImageView;
        TextView nameTextView;
        LinearLayout colorLayout;

        public ViewHolder(View itemView) {
            super(itemView);
            if (layoutType == LayoutType.IMAGE) {
                productImageView = (ImageView) itemView.findViewById(R.id.variation_image);
                nameTextView = (TextView) itemView.findViewById(R.id.variation_name);
                colorLayout = (LinearLayout) itemView.findViewById(R.id.variation_background);
            } else if (layoutType == LayoutType.TEXT) {
                nameTextView = (TextView) itemView.findViewById(R.id.variation_name);
            }

            if (AppInfo.AUTO_SELECT_VARIATION) {
                selectedPosition = 0;
            }

            itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    selectedPosition = getLayoutPosition();
                    notifyDataSetChanged();
                    if (mOnAttributeOptionClickListener != null) {
                        mOnAttributeOptionClickListener.onClick(position, getLayoutPosition());
                    }
                }
            });
        }

        void bindView(final int position) {
            final int strokeColor =  position == selectedPosition ? Color.parseColor(AppInfo.normal_button_color) : CContext.getColor(context, R.color.attribute_stroke_normal);
            final int textColor = (position == selectedPosition) ? Color.parseColor(AppInfo.normal_button_color) : CContext.getColor(context, R.color.attribute_text_normal);

            int bgColor = 0;
            Object termObject = termList.get(position);
            if (layoutType == LayoutType.IMAGE) {
                ShortAttribute.Term term = (ShortAttribute.Term) termObject;
                if (term != null) {
                    nameTextView.setText(HtmlCompat.fromHtml(term.key));
                    if (!TextUtils.isEmpty(term.value)) {
                        if(term.value.startsWith("http")) {
                            // show variation image boxes
                            Glide.with(context)
                                    .load(term.value)
                                    .placeholder(R.color.color_bg_theme_2)
                                    .error(R.drawable.error_product)
                                    .into(productImageView);
                            productImageView.setVisibility(View.VISIBLE);
                            nameTextView.setVisibility(View.GONE);
                        } else if(term.value.startsWith("#")) {
                            // show variation color boxes
                            bgColor = Color.parseColor(term.value);
                            productImageView.setVisibility(View.GONE);
                            nameTextView.setVisibility(View.GONE);
                            colorLayout.setBackground(Helper.getInsetBackground(bgColor, strokeColor, 2, 4));
                        }
                    } else {
                        productImageView.setVisibility(View.GONE);
                        nameTextView.setVisibility(View.VISIBLE);
                    }
                }
            } else if (layoutType == LayoutType.TEXT)  {
                String title = (String) termObject;
                Helper.setTextAppearance(context, nameTextView, android.R.style.TextAppearance_Small);
                nameTextView.setBackground(Helper.getSelectedListItemBorder(CContext.getColor(context, R.color.separator)));
                nameTextView.setText(HtmlCompat.fromHtml(title));
                nameTextView.setTextColor(CContext.getColor(context, R.color.separator));
            }

            Drawable backgroundDrawable = Helper.getSelectedListItemBorder(strokeColor, 2, 4);

            if (layoutType == LayoutType.IMAGE) {
                productImageView.setBackground(backgroundDrawable);
                productImageView.setPadding(Helper.DP(8), Helper.DP(8), Helper.DP(8), Helper.DP(8));
            } else if (layoutType == LayoutType.TEXT) {
                nameTextView.setBackground(backgroundDrawable);
                nameTextView.setPaddingRelative(Helper.DP(8), Helper.DP(8), Helper.DP(8), Helper.DP(8));
                nameTextView.setPadding(Helper.DP(8), Helper.DP(8), Helper.DP(8), Helper.DP(8));
                nameTextView.setTextColor(textColor);
            }
        }
    }
}
