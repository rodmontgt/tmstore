package com.twist.tmstore.adapters;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.ImageView;
import android.widget.TextView;

import com.twist.dataengine.entities.RawCategory;
import com.twist.tmstore.R;
import com.twist.tmstore.config.MultiVendorConfig;
import com.twist.tmstore.fragments.sellers.Fragment_SelectCategory;
import com.utils.Helper;
import com.utils.HtmlCompat;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Locale;

public class RawCategoryAdapter extends BaseAdapter {

    private List data;
    private List filterData;
    private LayoutInflater inflater;
    private Fragment_SelectCategory.ListSelectionListener listSelectionListener;
    private boolean showCategoryFullPath;
    private boolean showExpandIconVisible;

    public RawCategoryAdapter(Context context, List<RawCategory> data, Fragment_SelectCategory.ListSelectionListener listSelectionListener) {
        this.data = data;
        this.listSelectionListener = listSelectionListener;
        inflater = LayoutInflater.from(context);
        filterData = new ArrayList();
        filterData.addAll(data);
    }

    public void filter(String charText) {
        charText = charText.toLowerCase(Locale.getDefault());
        data.clear();
        if (charText.length() == 0) {
            data.addAll(filterData);
        } else {
            for (int i = 0; i < filterData.size(); i++) {
                if (charText.length() != 0 && ((RawCategory) filterData.get(i)).getName().toLowerCase(Locale.getDefault()).contains(charText)) {
                    data.add(filterData.get(i));
                } else if (charText.length() != 0 && ((RawCategory) filterData.get(i)).getNestedName().toLowerCase(Locale.getDefault()).contains(charText)) {
                    data.add(filterData.get(i));
                }
            }
        }
        notifyDataSetChanged();
    }

    @Override
    public int getCount() {
        return data.size();
    }

    @Override
    public Object getItem(int i) {
        return data.get(i);
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        View vi = convertView;
        ViewHolder holder;
        if (vi == null) {
            vi = inflater.inflate(R.layout.item_select_category, parent, false);
            holder = new ViewHolder();
            holder.text1 = (TextView) vi.findViewById(R.id.name);
            holder.text2 = (TextView) vi.findViewById(R.id.details);
            holder.expand = (ImageView) vi.findViewById(R.id.expand);
            holder.rv = vi.findViewById(R.id.rv);
            holder.checkbox_add = (CheckBox) vi.findViewById(R.id.checkbox_add);
            Helper.stylize(holder.checkbox_add);
            vi.setTag(holder);
        } else {
            holder = (ViewHolder) vi.getTag();
        }

        final RawCategory category = (RawCategory) getItem(position);
        holder.text1.setText(HtmlCompat.fromHtml("<b>" + category.getName() + "</b>"));

        if (showCategoryFullPath) {
            holder.text2.setVisibility(View.VISIBLE);
            holder.text2.setText(HtmlCompat.fromHtml(category.getNestedName()));
        } else {
            holder.text2.setVisibility(View.GONE);
        }

        if (showCategoryFullPath) {
            holder.rv.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    if (listSelectionListener != null)
                        listSelectionListener.onCategorySelected(category.getId());
                }
            });
        }

        holder.expand.setVisibility(category.getChildren().isEmpty() || !showExpandIconVisible ? View.GONE : View.VISIBLE);

        holder.checkbox_add.setVisibility(category.getChildren().isEmpty() ? View.VISIBLE : View.INVISIBLE);
        holder.checkbox_add.setVisibility(MultiVendorConfig.shouldShowParentCategory() ? View.VISIBLE : holder.checkbox_add.getVisibility());

        holder.checkbox_add.setOnCheckedChangeListener(null);

        if (listSelectionListener != null) {
            holder.checkbox_add.setChecked(listSelectionListener.isCategorySelected(category.getId()));
        }
        holder.checkbox_add.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton compoundButton, boolean checked) {
                if (checked) {
                    if (listSelectionListener != null)
                        listSelectionListener.onCategorySelected(category.getId());
                } else {
                    if (listSelectionListener != null)
                        listSelectionListener.onCategoryUnSelected(category.getId());
                }
            }
        });
        if (!showCategoryFullPath) {
            if (category.getChildren().isEmpty()) {
                holder.rv.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {

                    }

                });
            }
        }
        if (!showCategoryFullPath && showExpandIconVisible) {
            if (!category.getChildren().isEmpty()) {
                holder.rv.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        if (listSelectionListener != null)
                            listSelectionListener.onCategoryExpanded(category.getId());
                    }
                });
            }
        }
        return vi;
    }

    public void addAll(Collection newData) {
        data.addAll(newData);
        notifyDataSetChanged();
    }

    public void setShowCategoryFullPath(boolean showCategoryFullPath) {
        this.showCategoryFullPath = showCategoryFullPath;
    }

    public void setShowExpandIconVisible(boolean showExpandIconVisible) {
        this.showExpandIconVisible = showExpandIconVisible;
    }

    public static class ViewHolder {
        public TextView text1;
        public TextView text2;
        public ImageView expand;
        public View rv;
        public CheckBox checkbox_add;
    }
}