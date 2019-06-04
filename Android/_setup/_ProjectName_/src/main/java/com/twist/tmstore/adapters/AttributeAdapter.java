package com.twist.tmstore.adapters;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.twist.dataengine.entities.ShortAttribute;
import com.twist.dataengine.entities.TM_Attribute;
import com.twist.tmstore.R;
import com.twist.tmstore.entities.AppInfo;
import com.twist.tmstore.listeners.OnAttributeOptionClickListener;
import com.utils.HtmlCompat;

import java.util.ArrayList;
import java.util.List;

public class AttributeAdapter extends RecyclerView.Adapter<AttributeAdapter.AttributeViewHolder> {

    private List<TM_Attribute> attributeData;
    private Context context;

    private int mCheckedItem;
    private OnAttributeOptionClickListener mOnAttributeOptionClickListener;

    public AttributeAdapter(Context context, List<TM_Attribute> attributeData) {
        this.context = context;
        this.attributeData = attributeData;
    }

    @Override
    public AttributeViewHolder onCreateViewHolder(ViewGroup viewGroup, int type) {
        View itemView = LayoutInflater.from(viewGroup.getContext()).inflate(R.layout.item_variations_images, viewGroup, false);
        return new AttributeViewHolder(itemView);
    }

    @Override
    public long getItemId(int position) {
        return position;
    }


    @Override
    public void onBindViewHolder(AttributeAdapter.AttributeViewHolder holder, int position) {
        holder.bindView(position);
    }

    @Override
    public int getItemCount() {
        return attributeData.size();
    }

    public class AttributeViewHolder extends RecyclerView.ViewHolder {

        private RecyclerView attributeImageRecyclerView;
        private TextView attributeName;
        private int mPosition;

        public AttributeViewHolder(View view) {
            super(view);
            attributeImageRecyclerView = (RecyclerView) view.findViewById(R.id.variation_image_list);
            attributeName = (TextView) view.findViewById(R.id.variation_title);
        }

        void bindView(final int position) {
            this.mPosition = position;

            TM_Attribute attribute = attributeData.get(position);

            mCheckedItem = -1;
            if (AppInfo.AUTO_SELECT_VARIATION && !attribute.options.isEmpty()) {
                mCheckedItem = 0;
                if (mOnAttributeOptionClickListener != null) {
                    mOnAttributeOptionClickListener.onClick(mPosition, mCheckedItem);
                }
            }

            ShortAttribute shortAttribute = ShortAttribute.getShortAttributeWithSlug(attribute.slug);
            if (shortAttribute != null) {
                attributeName.setText(HtmlCompat.fromHtml(shortAttribute.getName()));
                if (shortAttribute.getTerms() != null && shortAttribute.getTerms().size() > 0) {
                    if (shortAttribute.getTerms().size() != attribute.options.size()) {
                        adjustAttributesTerms(shortAttribute.getTerms(), attribute.options);
                    }

                    List<ShortAttribute.Term> termList = shortAttribute.getTerms();
                    AttributeOptionsAdapter adapter = new AttributeOptionsAdapter(context, mPosition, termList, AttributeOptionsAdapter.LayoutType.IMAGE);
                    attributeImageRecyclerView.setAdapter(adapter);
                    adapter.setOptionSelectionListener(new OnAttributeOptionClickListener() {
                        @Override
                        public void onClick(int id, int index) {
                            if (mOnAttributeOptionClickListener != null) {
                                mOnAttributeOptionClickListener.onClick(id, index);
                            }
                        }
                    });
                }
            } else {
                attributeName.setText(HtmlCompat.fromHtml(attribute.name));
                AttributeOptionsAdapter adapter = new AttributeOptionsAdapter(context, mPosition, attribute.getOptions(), AttributeOptionsAdapter.LayoutType.TEXT);
                attributeImageRecyclerView.setAdapter(adapter);
                adapter.setOptionSelectionListener(new OnAttributeOptionClickListener() {
                    @Override
                    public void onClick(int id, int index) {
                        if (mOnAttributeOptionClickListener != null) {
                            mOnAttributeOptionClickListener.onClick(id, index);
                        }
                    }
                });
            }
        }
    }

    public void setOptionSelectionListener(OnAttributeOptionClickListener onAttributeOptionClickListener) {
        this.mOnAttributeOptionClickListener = onAttributeOptionClickListener;
    }

    public void adjustAttributesTerms(List<ShortAttribute.Term> termList, List<String> options) {
        List<String> option = new ArrayList<>();

        for (String s : options) {
            option.add(s.toLowerCase());
        }

        List<ShortAttribute.Term> extraAttributes = new ArrayList<>();
        for (ShortAttribute.Term term : termList) {
            if (!option.contains(term.key)) {
                extraAttributes.add(term);
            }
        }
        termList.removeAll(extraAttributes);
    }
}