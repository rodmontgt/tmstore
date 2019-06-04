package com.twist.tmstore.fragments;

import android.os.Bundle;
import android.support.v7.widget.CardView;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.TextView;

import com.twist.dataengine.DataQueryHandler;
import com.twist.dataengine.DataEngine;;
import com.twist.dataengine.entities.TM_Coupon;
import com.twist.tmstore.BaseFragment;
import com.twist.tmstore.Constants;
import com.twist.tmstore.L;
import com.twist.tmstore.MainActivity;
import com.twist.tmstore.R;
import com.twist.tmstore.adapters.Adapter_CouponList;
import com.twist.tmstore.entities.AppUser;
import com.utils.Helper;
import com.utils.customviews.progressbar.CircleProgressBar;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;

/**
 * Created by Twist Mobile on 11/29/2016.
 */

public class Fragment_Coupons extends BaseFragment {

    private RecyclerView recyclerView;
    FrameLayout coordLayout;
    TextView no_couponsTextView;
    private Adapter_CouponList couponListAdapter;

    public static Fragment_Coupons newInstance() {
        return new Fragment_Coupons();
    }

    public Fragment_Coupons() {
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        final View view = inflater.inflate(R.layout.fragment_coupons, container, false);

        setActionBarHomeAsUpIndicator();

        getBaseActivity().restoreActionBar();

        setTitle(getString(L.string.title_coupons));

        coordLayout = (FrameLayout) view.findViewById(R.id.coupons_layout);

        recyclerView = (RecyclerView) view.findViewById(R.id.coupons_recyclerview);
        recyclerView.setLayoutManager(new LinearLayoutManager(getContext(), LinearLayoutManager.VERTICAL, false));

        couponListAdapter = new Adapter_CouponList(new ArrayList<TM_Coupon>(), coordLayout);
        recyclerView.setAdapter(couponListAdapter);

        if (!TM_Coupon.allCouponsLoaded || TM_Coupon.getAll().isEmpty()) {
            final CircleProgressBar progressBar = (CircleProgressBar) view.findViewById(R.id.progress_bar);
            Helper.stylize(progressBar);
            progressBar.setVisibility(View.VISIBLE);
            DataEngine.getDataEngine().getCouponsInBackground(new DataQueryHandler<List<TM_Coupon>>() {
                @Override
                public void onSuccess(List<TM_Coupon> data) {
                    setCouponsListView(view, data);
                    TM_Coupon.allCouponsLoaded = true;
                    progressBar.setVisibility(View.GONE);
                }

                @Override
                public void onFailure(Exception reason) {
                    Helper.showToast(coordLayout, reason.getMessage());
                    progressBar.setVisibility(View.GONE);
                    if (!TM_Coupon.getAll().isEmpty()) {
                        setCouponsListView(view, TM_Coupon.getAll());
                    }
                }
            });
        } else {
            setCouponsListView(view, TM_Coupon.getAll());
        }
        return view;
    }

    private void setCouponsListView(View view, List<TM_Coupon> data) {
        prepareEmptySection(view, data);
        loadCouponsInAdapter(view, data);
    }

    private void loadCouponsInAdapter(View rootView, List<TM_Coupon> couponsList) {
        List<TM_Coupon> couponsListToAdd = new ArrayList<>();
        for (int i = 0; i < couponsList.size(); i++) {
            TM_Coupon coupon = couponsList.get(i);
            boolean shouldAddThisCoupon = true;
            if (coupon.customer_emails != null && coupon.customer_emails.size() > 0) {
                if (!AppUser.hasSignedIn()) {
                    shouldAddThisCoupon = false;
                } else if (AppUser.hasSignedIn()) {
                    if (!coupon.customer_emails.contains(AppUser.getEmail())) {
                        shouldAddThisCoupon = false;
                    }
                }
            }

            if (coupon.expiry_date != null && !coupon.expiry_date.toString().isEmpty()) {
                try {
                    Calendar expiryCalendar = Calendar.getInstance();
                    expiryCalendar.setTime(coupon.expiry_date);
                    Calendar presentCalendar = Calendar.getInstance();
                    presentCalendar.add(Calendar.DATE, -1);
                    if (presentCalendar.after(expiryCalendar)) {
                        shouldAddThisCoupon = false;
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
            if (shouldAddThisCoupon) {
                couponsListToAdd.add(coupon);
            }
        }
        if (couponsListToAdd.isEmpty() && couponsListToAdd.size() <= 0) {
            prepareEmptySection(rootView, couponsListToAdd);
        } else {
            couponListAdapter.addItems(couponsListToAdd);
        }
    }

    private void prepareEmptySection(View rootView, List<TM_Coupon> data) {
        CardView emptyView = (CardView) rootView.findViewById(R.id.text_empty);
        no_couponsTextView = (TextView) rootView.findViewById(R.id.no_coupons);
        Button btn_back = (Button) rootView.findViewById(R.id.btn_back);
        if (data.isEmpty() && data.size() == 0) {
            recyclerView.setVisibility(View.GONE);
            emptyView.setVisibility(View.VISIBLE);
            this.setTextOnView(rootView, R.id.no_coupons, L.string.no_coupons_found);
            btn_back.setText(getString(L.string.btn_go_back));
            Helper.stylize(btn_back);
            btn_back.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (getFragmentManager().getBackStackEntryCount() > 0) {
                        getFragmentManager().popBackStack();
                    } else {
                        MainActivity.mActivity.onNavigationDrawerItemSelected(Constants.MENU_ID_HOME, -1);
                    }
                }
            });
        } else {
            recyclerView.setVisibility(View.VISIBLE);
            emptyView.setVisibility(View.GONE);
        }
    }
}