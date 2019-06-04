package com.twist.tmstore.fragments.filters;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.twist.dataengine.DataQueryHandler;
import com.twist.dataengine.DataEngine;;
import com.twist.dataengine.entities.TM_ComparableFilter;
import com.twist.dataengine.entities.TM_ProductFilter;
import com.twist.dataengine.entities.UserFilter;
import com.utils.TaxHelper;
import com.twist.tmstore.L;
import com.twist.tmstore.R;
import com.utils.Helper;
import com.utils.customviews.rangeseekbar.RangeSeekBar;

public class Filter_PriceRange extends BaseFilterFragment {

    private RangeSeekBar priceRange;
    private ProgressBar progressbar;
    private TextView headerTextView;

    public static Fragment newInstance(TM_ProductFilter productFilter, UserFilter userFilter, FilterUpdateListener filterUpdateListener) {
        return newInstance(productFilter, userFilter, filterUpdateListener, false);
    }

    public static Fragment newInstance(TM_ProductFilter productFilter, UserFilter userFilter, FilterUpdateListener filterUpdateListener, boolean skipInitialChk) {
        Filter_PriceRange fragment = new Filter_PriceRange();
        fragment.setFilterUpdateListener(filterUpdateListener);
        fragment.productFilter = productFilter;
        fragment.userFilter = userFilter;
        fragment.skipInitialChk = skipInitialChk;
        return fragment;
    }

    public Filter_PriceRange() {
        super();
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_filter_price_range, container, false);
        priceRange = (RangeSeekBar) view.findViewById(R.id.priceRange);
        progressbar = (ProgressBar) view.findViewById(R.id.progressbar);
        Helper.stylize(progressbar);
        userFilter.taxApplied = TaxHelper.applyTaxOnPrice(userFilter.getMinPrice());
        float minVal = userFilter.getMinPrice() + TaxHelper.applyTaxOnPrice(userFilter.getMinPrice());
        float maxVal = userFilter.getMaxPrice() + TaxHelper.applyTaxOnPrice(userFilter.getMaxPrice());

        priceRange.setRangeValues(minVal, maxVal);
        priceRange.setSelected(true);
        priceRange.setSelectedMinValue(minVal);
        priceRange.setSelectedMaxValue(maxVal);
        priceRange.setOnRangeSeekBarChangeListener(new RangeSeekBar.OnRangeSeekBarChangeListener<Float>() {
            @Override
            public void onRangeSeekBarValuesChanged(RangeSeekBar bar, Float minValue, Float maxValue) {
                userFilter.setMinPrice(minValue - userFilter.taxApplied);
                userFilter.setMaxPrice(maxValue - userFilter.taxApplied);
            }
        });
        Helper.stylize(priceRange);

        headerTextView = (TextView) view.findViewById(R.id.txt_price_range_header);
        headerTextView.setText(getString(L.string.price_range_header));

        if (!skipInitialChk) {
            updateFiltersInBackground();
            skipInitialChk = false;
        }
        return view;
    }

    private void showProgressBar() {
        progressbar.setVisibility(View.VISIBLE);
        headerTextView.setVisibility(View.GONE);
        priceRange.setVisibility(View.GONE);
        filterUpdateListener.onFilterClick(false);
    }

    private void hideProgressBar() {
        progressbar.setVisibility(View.GONE);
        headerTextView.setVisibility(View.VISIBLE);
        priceRange.setVisibility(View.VISIBLE);
        filterUpdateListener.onFilterClick(true);
    }

    void updateFiltersInBackground() {
        showProgressBar();
        DataEngine.getDataEngine().getFilterByFilter(userFilter, new DataQueryHandler<TM_ComparableFilter>() {
            @Override
            public void onSuccess(TM_ComparableFilter comparableFilter) {
                hideProgressBar();
                if (filterUpdateListener != null) {
                    filterUpdateListener.onFilterUpdated(comparableFilter);
                }
            }

            @Override
            public void onFailure(Exception reason) {
                reason.printStackTrace();
                hideProgressBar();
            }
        });
    }
}
