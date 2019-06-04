package com.twist.tmstore.fragments.filters;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CheckBox;
import android.widget.CompoundButton;

import com.twist.dataengine.entities.TM_ProductFilter;
import com.twist.dataengine.entities.UserFilter;
import com.twist.tmstore.L;
import com.twist.tmstore.R;
import com.utils.Helper;

public class Filter_Discount extends BaseFilterFragment {

    public static Fragment newInstance(TM_ProductFilter productFilter, UserFilter userFilter, FilterUpdateListener filterUpdateListener) {
        BaseFilterFragment fragment = new Filter_Discount();
        fragment.setFilterUpdateListener(filterUpdateListener);
        fragment.productFilter = productFilter;
        fragment.userFilter = userFilter;
        return fragment;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_filter_discount, container, false);
        CheckBox chkDiscount = (CheckBox) view.findViewById(R.id.chkDiscount);
        chkDiscount.setText(getString(L.string.show_discounted_only));
        chkDiscount.setChecked(userFilter.shouldCheckOnSale());
        chkDiscount.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                userFilter.setCheckSale(isChecked);
            }
        });
        Helper.stylize(chkDiscount);

        //updateFiltersInBackground();

        return view;
    }

}
