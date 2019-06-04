package com.twist.tmstore.fragments.filters;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RadioButton;
import android.widget.RadioGroup;

import com.twist.dataengine.entities.TM_ProductFilter;
import com.twist.dataengine.entities.UserFilter;
import com.twist.tmstore.L;
import com.twist.tmstore.R;
import com.twist.tmstore.entities.FilterSortType;
import com.utils.Helper;
import com.utils.HtmlCompat;

public class Filter_Sort extends BaseFilterFragment {

    public static Fragment newInstance(TM_ProductFilter productFilter, UserFilter userFilter, FilterUpdateListener filterUpdateListener) {
        Filter_Sort fragment = new Filter_Sort();
        fragment.productFilter = productFilter;
        fragment.userFilter = userFilter;
        return fragment;
    }

    public Filter_Sort() {
        super();
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_filter_sort, container, false);
        RadioGroup group_sorts = (RadioGroup) view.findViewById(R.id.group_sorts);

        final FilterSortType[] filterSortTypes = FilterSortType.values();

        String currentSortOrder = filterSortTypes[userFilter.getSortOrder()].toString();
        for (FilterSortType filterSortType : filterSortTypes) {
            final String sortOrder = filterSortType.toString();
            RadioButton radioButton = new RadioButton(getActivity());
            int padding = (int) getResources().getDimension(R.dimen.activity_horizontal_margin);
            radioButton.setPadding(padding, padding, padding, padding);
            radioButton.setId(filterSortType.ordinal());
            radioButton.setText(HtmlCompat.fromHtml(getSortString(sortOrder)));
            Helper.stylize(radioButton);
            group_sorts.addView(radioButton);
            if (currentSortOrder.equals(sortOrder)) {
                radioButton.setChecked(true);
            }
            radioButton.setTag(filterSortType.ordinal());
            radioButton.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    userFilter.setSortOrder((int) view.getTag());
                }
            });
        }
        return view;
    }

    private String getSortString(String key) {
        switch (key) {
            case "sort_fresh_arrival":
                return getString(L.string.sort_fresh_arrival);
            case "sort_featured":
                return getString(L.string.sort_featured);
            case "sort_discount":
                return getString(L.string.sort_discount);
            case "sort_user_rating":
                return getString(L.string.sort_user_rating);
            case "sort_price_high_to_low":
                return getString(L.string.sort_price_high_to_low);
            case "sort_price_low_to_high":
                return getString(L.string.sort_price_low_to_high);
            case "sort_popularity":
                return getString(L.string.sort_popularity);
            default:
                return getString(L.string.sort_fresh_arrival);
        }
    }
}
