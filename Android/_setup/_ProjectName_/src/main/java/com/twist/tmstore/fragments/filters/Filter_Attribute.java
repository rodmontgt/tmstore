package com.twist.tmstore.fragments.filters;

import android.os.Bundle;
import android.support.annotation.NonNull;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.ListView;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.twist.dataengine.DataQueryHandler;
import com.twist.dataengine.DataEngine;;
import com.twist.dataengine.entities.TM_ComparableFilter;
import com.twist.dataengine.entities.TM_ComparableFilterAttribute;
import com.twist.dataengine.entities.TM_FilterAttribute;
import com.twist.dataengine.entities.TM_FilterAttributeOption;
import com.twist.dataengine.entities.TM_ProductFilter;
import com.twist.dataengine.entities.UserFilter;
import com.twist.tmstore.L;
import com.twist.tmstore.R;
import com.utils.Helper;
import com.utils.HtmlCompat;

import java.util.ArrayList;
import java.util.List;

public class Filter_Attribute extends BaseFilterFragment {

    private ProgressBar progressbar;

    public Filter_Attribute() {
        // Required empty public constructor
    }

    private TM_FilterAttribute filterAttribute;
    private TM_FilterAttribute userAttribute;
    private ListView filterAttributeOptionsListView;
    private TextView emptyTextView;
    private List<TM_FilterAttributeOption> filterAttributeOptions;

    public static Filter_Attribute newInstance(TM_ProductFilter productFilter, UserFilter userFilter, TM_FilterAttribute filterAttribute, TM_FilterAttribute userAttribute, FilterUpdateListener filterUpdateListener) {
        Filter_Attribute fragment = new Filter_Attribute();
        fragment.setFilterUpdateListener(filterUpdateListener);
        fragment.productFilter = productFilter;
        fragment.userFilter = userFilter;
        fragment.filterAttribute = filterAttribute;
        fragment.userAttribute = userAttribute;
        return fragment;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_filter_attribute, container, false);

        filterAttributeOptionsListView = (ListView) view.findViewById(R.id.listview_filter_attribute_options);
        emptyTextView = (TextView) view.findViewById(R.id.text_empty);
        progressbar = (ProgressBar) view.findViewById(R.id.progressbar);
        Helper.stylize(progressbar);

        emptyTextView.setText(getString(L.string.attribute_name_unavailable).replace("ATTRIBUTE_NAME", filterAttribute.attribute));

        filterAttributeOptions = new ArrayList<>();
        if (userFilter.isFilterModified()) {
            updateFiltersInBackground();
        } else {
            setDefaultOptions();
        }
        return view;
    }

    void showLoading() {
        progressbar.setVisibility(View.VISIBLE);
        filterUpdateListener.onFilterClick(false);
    }

    void dismissLoading() {
        progressbar.setVisibility(View.INVISIBLE);
        filterUpdateListener.onFilterClick(true);
    }
    //Warning: Dimag ka istemaaal na kare..

    private void updateFiltersInBackground() {
        showLoading();
        DataEngine.getDataEngine().getFilterByFilter(userFilter, new DataQueryHandler<TM_ComparableFilter>() {
            @Override
            public void onSuccess(TM_ComparableFilter comparableFilter) {
                filterAttributeOptions.clear();
                dismissLoading();
                if (!filterAttribute.options.isEmpty()) {
                    String firstTaxo = filterAttribute.options.get(0).taxo;
                    TM_ComparableFilterAttribute matchingAttribute = comparableFilter.getMatchingAttribute(firstTaxo);
                    if (matchingAttribute != null) {
                        for (String name : matchingAttribute.names) {
                            TM_FilterAttributeOption option = filterAttribute.getWithName(name, false);
                            if (option != null) {
                                filterAttributeOptions.add(option);
                            }
                        }

                        if (!filterAttributeOptions.isEmpty()) {
                            FilterAttributeOptionsAdapter adapter = new FilterAttributeOptionsAdapter(filterAttributeOptions);
                            filterAttributeOptionsListView.setAdapter(adapter);
                        }
                    }
                }
                filterAttributeOptionsListView.setVisibility(filterAttributeOptions.isEmpty() ? View.GONE : View.VISIBLE);
                emptyTextView.setVisibility(filterAttributeOptions.isEmpty() ? View.VISIBLE : View.GONE);
            }

            @Override
            public void onFailure(Exception reason) {
                reason.printStackTrace();
                dismissLoading();
                emptyTextView.setVisibility(filterAttributeOptions.isEmpty() ? View.VISIBLE : View.GONE);
            }
        });
    }

    void setDefaultOptions() {
        filterAttributeOptions.clear();
        for (TM_FilterAttributeOption option : filterAttribute.options) {
            if (option != null && !TextUtils.isEmpty(option.name) && !TextUtils.isEmpty(option.slug) && !TextUtils.isEmpty(option.taxo)) {
                filterAttributeOptions.add(option);
            }
        }

        if (!filterAttributeOptions.isEmpty()) {
            FilterAttributeOptionsAdapter adapter = new FilterAttributeOptionsAdapter(filterAttributeOptions);
            filterAttributeOptionsListView.setAdapter(adapter);
            filterAttributeOptionsListView.setVisibility(View.VISIBLE);
            emptyTextView.setVisibility(View.GONE);
        } else {
            filterAttributeOptionsListView.setVisibility(View.GONE);
            emptyTextView.setVisibility(View.VISIBLE);
        }
    }

    private class FilterAttributeOptionsAdapter extends BaseAdapter {
        private List<TM_FilterAttributeOption> filterAttributeOptions;

        class ViewHolder {
            CheckBox checkBox;
        }

        FilterAttributeOptionsAdapter(List<TM_FilterAttributeOption> filterAttributeOptions) {
            this.filterAttributeOptions = filterAttributeOptions;
        }

        @Override
        public int getCount() {
            return filterAttributeOptions.size();
        }

        @Override
        public TM_FilterAttributeOption getItem(int position) {
            return filterAttributeOptions.get(position);
        }

        @Override
        public long getItemId(int position) {
            return position;
        }

        @NonNull
        @Override
        public View getView(final int position, View convertView, @NonNull ViewGroup parent) {
            TM_FilterAttributeOption filterAttributeOption = getItem(position);
            ViewHolder holder;
            View view = convertView;
            if (view == null) {
                view = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_filter_attribute_options, parent, false);
                holder = new ViewHolder();
                holder.checkBox = (CheckBox) view.findViewById(R.id.checkbox_filter_attribute_option);
                holder.checkBox.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
                    @Override
                    public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                        TM_FilterAttributeOption filterAttributeOption = (TM_FilterAttributeOption) buttonView.getTag();
                        if (isChecked) {
                            userFilter.addAttributeOption(userAttribute, filterAttributeOption);
                        } else {
                            userFilter.removeAttributeOption(userAttribute, filterAttributeOption);
                        }
                    }
                });
                Helper.stylize(holder.checkBox);
                view.setTag(holder);
            } else {
                holder = (ViewHolder) view.getTag();
            }
            holder.checkBox.setTag(filterAttributeOption);
            holder.checkBox.setText(HtmlCompat.fromHtml(filterAttributeOption.name));
            holder.checkBox.setChecked(userAttribute.options.contains(filterAttributeOption));
            return view;
        }
    }
}
