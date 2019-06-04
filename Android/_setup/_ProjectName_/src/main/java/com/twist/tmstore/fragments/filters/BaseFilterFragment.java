package com.twist.tmstore.fragments.filters;

import com.twist.dataengine.entities.TM_ComparableFilter;
import com.twist.dataengine.entities.TM_ProductFilter;
import com.twist.dataengine.entities.UserFilter;
import com.twist.tmstore.BaseFragment;

public class BaseFilterFragment extends BaseFragment {

    public void setFilterUpdateListener(FilterUpdateListener filterUpdateListener) {
        this.filterUpdateListener = filterUpdateListener;
    }

    public interface FilterUpdateListener {
        void onFilterUpdated(TM_ComparableFilter filter);
        void onFilterClick(boolean enableClick);
    }

    public TM_ProductFilter productFilter;
    public UserFilter userFilter;

    protected FilterUpdateListener filterUpdateListener = null;

    public BaseFilterFragment() {
        // Required empty public constructor
    }

    public boolean skipInitialChk = false;
}
