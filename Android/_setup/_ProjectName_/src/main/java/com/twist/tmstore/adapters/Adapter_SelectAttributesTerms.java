package com.twist.tmstore.adapters;

import android.app.FragmentTransaction;
import android.content.Context;
import android.support.v4.app.FragmentActivity;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.twist.dataengine.entities.RawAttribute;
import com.twist.dataengine.entities.RawAttributeTerm;
import com.twist.tmstore.R;
import com.twist.tmstore.fragments.sellers.Fragment_SelectAttribute;
import com.utils.Helper;

import java.util.List;

/**
 * Created by Twist Mobile on 1/25/2017.
 */

public class Adapter_SelectAttributesTerms extends RecyclerView.Adapter<Adapter_SelectAttributesTerms.ViewHolder> {

    private List<RawAttribute> items;
    private Context context;
    private boolean isCategory;

    private Fragment_SelectAttribute.AttributeSelectionListener mListener;
    private List<String> checkedOptions;
    private RawAttribute rawAttribute;

    public Adapter_SelectAttributesTerms(Context context, List<RawAttribute> items, Fragment_SelectAttribute.AttributeSelectionListener mListener, boolean isCategory) {
        this.items = items;
        this.context = context;
        this.isCategory = isCategory;
        this.mListener = mListener;
    }

    public Adapter_SelectAttributesTerms(Context context, RawAttribute rawAttribute, List<String> checkedOptions, boolean isCategory) {
        this.context = context;
        this.rawAttribute = rawAttribute;
        this.checkedOptions = checkedOptions;
        this.isCategory = isCategory;
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View itemView = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_select_attribute_terms, parent, false);
        return new ViewHolder(itemView);
    }


    @Override
    public void onBindViewHolder(ViewHolder holder, int position) {
        if (isCategory) {
            holder.textView.setText(items.get(position).getName());
        } else {
            final RawAttributeTerm attributeTerm = rawAttribute.getAttributeTerms().get(position);
            holder.title_attribute_term.setText(attributeTerm.name);
            holder.title_attribute_term.setOnCheckedChangeListener(null);
            holder.title_attribute_term.setChecked(checkedOptions.contains(attributeTerm.name));
            holder.title_attribute_term.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
                @Override
                public void onCheckedChanged(CompoundButton compoundButton, boolean checked) {
                    if (!checked) {
                        checkedOptions.remove(attributeTerm.name);
                    } else if (!checkedOptions.contains(attributeTerm.name)) {
                        checkedOptions.add(attributeTerm.name);
                    }
                }
            });
        }
    }

    @Override
    public int getItemCount() {
        if (isCategory) {
            return items.size();
        } else {
            return rawAttribute.getAttributeTerms().size();
        }
    }

    public class ViewHolder extends RecyclerView.ViewHolder implements View.OnClickListener {
        TextView textView;
        CheckBox title_attribute_term;
        LinearLayout attribute_section;
        LinearLayout attribute_term_section;

        public ViewHolder(View v) {
            super(v);
            attribute_section = (LinearLayout) v.findViewById(R.id.attribute_section);
            attribute_term_section = (LinearLayout) v.findViewById(R.id.attribute_term_section);
            attribute_section.setVisibility(View.GONE);
            attribute_term_section.setVisibility(View.GONE);
            textView = (TextView) v.findViewById(R.id.title_attribute);
            title_attribute_term = (CheckBox) v.findViewById(R.id.title_attribute_term);
            Helper.stylize(title_attribute_term);
            if (isCategory) {
                attribute_section.setVisibility(View.VISIBLE);
                attribute_section.setOnClickListener(this);
            } else {
                attribute_term_section.setVisibility(View.VISIBLE);
            }
        }

        @Override
        public void onClick(View view) {
            switch (view.getId()) {
                case R.id.attribute_section:
                    if (mListener != null) {
                        mListener.onAttributeSelected(items.get(getLayoutPosition()));
                    }
                    FragmentTransaction ft = ((FragmentActivity) context).getFragmentManager().beginTransaction();
                    ft.addToBackStack("dialog").commit();
                    break;
            }
        }
    }
}