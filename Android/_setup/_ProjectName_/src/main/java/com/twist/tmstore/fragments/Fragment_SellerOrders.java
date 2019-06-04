package com.twist.tmstore.fragments;

import android.graphics.Color;
import android.graphics.PorterDuff;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v7.app.ActionBar;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ListView;
import android.widget.TextView;

import com.twist.dataengine.DataQueryHandler;
import com.twist.dataengine.DataEngine;;
import com.twist.dataengine.entities.SellerInfo;
import com.twist.dataengine.entities.TM_Order;
import com.twist.dataengine.entities.TM_ProductInfo;
import com.twist.tmstore.BaseActivity;
import com.twist.tmstore.BaseFragment;
import com.twist.tmstore.L;
import com.twist.tmstore.MainActivity;
import com.twist.tmstore.R;
import com.twist.tmstore.adapters.Adapter_OrdersList;
import com.twist.tmstore.config.MultiVendorConfig;
import com.twist.tmstore.entities.AppInfo;
import com.twist.tmstore.entities.AppUser;
import com.utils.CContext;
import com.utils.Helper;
import com.utils.JsonUtils;
import com.utils.Log;
import com.utils.customviews.progressbar.CircleProgressBar;

import java.util.ArrayList;
import java.util.List;

public class Fragment_SellerOrders extends BaseFragment {
    private int[] ids;
    private List<TM_Order> mOrderList = new ArrayList<>();
    private Adapter_OrdersList mOrderAdapter = null;
    private ListView listView;
    private CircleProgressBar progressBar;
    private boolean notifyOrder;
    private int[] orderIds;
    String content;
    private ArrayList<TM_ProductInfo> availableProducts;

    public static Fragment_SellerOrders newInstance(SellerInfo seller) {
        Fragment_SellerOrders fragment = new Fragment_SellerOrders();
        return fragment;
    }

    public static Fragment_SellerOrders newInstance(String content, boolean notifyOrder) {
        Fragment_SellerOrders fragment = new Fragment_SellerOrders();
        fragment.notifyOrder = notifyOrder;
        fragment.content = content;
        return fragment;
    }


    private void showSellerOrder() {
        progressBar.setVisibility(View.VISIBLE);
        DataEngine.getDataEngine().getOrderInBackground(Integer.parseInt(""), new DataQueryHandler<TM_Order>() {
                    @Override
                    public void onSuccess(TM_Order order) {
                        try {
                            progressBar.setVisibility(View.GONE);
                            mOrderList.clear();
                            mOrderList.add(order);
                            mOrderAdapter.notifyDataSetChanged();
                            getOrdersMeta(mOrderList);
                        } catch (Exception ex) {
                            ex.printStackTrace();
                        }
                    }

                    @Override
                    public void onFailure(Exception exception) {
                        exception.printStackTrace();
                        progressBar.setVisibility(View.GONE);
                    }
                }
        );
    }

    public Fragment_SellerOrders() {
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (MultiVendorConfig.isSellerApp()) {
            setHasOptionsMenu(true);
            ActionBar actionBar = getSupportActionBar();
            if (actionBar != null) {
                actionBar.setHomeButtonEnabled(true);
                actionBar.setDisplayHomeAsUpEnabled(true);
                Drawable upArrow = CContext.getDrawable(getActivity(), R.drawable.abc_ic_ab_back_material);
                upArrow.setColorFilter(Color.parseColor(AppInfo.color_actionbar_text), PorterDuff.Mode.SRC_ATOP);
                actionBar.setHomeAsUpIndicator(upArrow);
            }
        }
    }

    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
        super.onCreateOptionsMenu(menu, inflater);
        if (MultiVendorConfig.isSellerApp()) {
            menu.clear();
        }
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View rootView = inflater.inflate(R.layout.fragment_orders, container, false);
        listView = (ListView) rootView.findViewById(R.id.list_orders);
        TextView textViewEmpty = (TextView) rootView.findViewById(R.id.text_empty);
        textViewEmpty.setText(getString(L.string.no_orders));
        progressBar = (CircleProgressBar) rootView.findViewById(R.id.progress_bar);
        Helper.stylize(progressBar);
        listView.setEmptyView(textViewEmpty);

        if (mOrderAdapter == null) {
            mOrderAdapter = new Adapter_OrdersList((BaseActivity) getActivity(), mOrderList, true, false, null);
        }

        listView.setAdapter(mOrderAdapter);

        rootView.setFocusableInTouchMode(true);
        rootView.requestFocus();
        rootView.setOnKeyListener(new View.OnKeyListener() {
            @Override
            public boolean onKey(View v, int keyCode, KeyEvent event) {
                if (event.getAction() == KeyEvent.ACTION_DOWN) {
                    if (keyCode == KeyEvent.KEYCODE_BACK) {
                        MainActivity.mActivity.showHomeFragment(true);
                        return true;
                    }
                }
                return false;
            }
        });

        mOrderAdapter.setCancelRequestListener(new Adapter_OrdersList.CancelRequestListener() {
            @Override
            public void onCancelRequested(int orderId) {

            }

            @Override
            public void onStatusSelected(String status, TM_Order tm_order) {
                updateOrderStatusInBackground(tm_order, status);
            }
        });
        registerViewPagerKeyListenerOnView(rootView);
        return rootView;
    }

    private void updateOrderStatusInBackground(TM_Order order, String status) {
        try {
            showProgress(getString(L.string.updating_status), false);
            String str = JsonUtils.createOrderStatusJsonString(status);
            Log.d("-- str: [" + str + "] --");
            DataEngine.getDataEngine().updateOrderStatusInBackground(order.id, str, new DataQueryHandler<TM_Order>() {
                @Override
                public void onSuccess(TM_Order order) {
                    hideProgress();
                    loadSellerOrders();
                }

                @Override
                public void onFailure(Exception reason) {
                    hideProgress();
                    MainActivity.mActivity.generateOrderFailure(reason.getMessage());
                }
            });
        } catch (Exception e) {
            hideProgress();
            MainActivity.mActivity.generateOrderFailure(e.getMessage());
        }
    }

    private void loadSellerOrders() {
        progressBar.setVisibility(View.VISIBLE);
        DataEngine.getDataEngine().getSellerOrdersInBackground(String.valueOf(AppUser.getUserId()), new DataQueryHandler<List<TM_Order>>() {
                    @Override
                    public void onSuccess(List<TM_Order> data) {
                        try {
                            progressBar.setVisibility(View.GONE);
                            mOrderList.clear();
                            mOrderList.addAll(data);
                            mOrderAdapter.notifyDataSetChanged();
                            getOrdersMeta(data);
                        } catch (Exception ex) {
                            ex.printStackTrace();
                        }
                    }

                    @Override
                    public void onFailure(Exception exception) {
                        exception.printStackTrace();
                        progressBar.setVisibility(View.GONE);
                    }
                }
        );
    }

    private void getOrdersMeta(List<TM_Order> orderList) {
        if (AppInfo.USE_LAT_LONG_IN_ORDER) {
            showProgress(getString(L.string.fetching_orders));
            DataEngine.getDataEngine().getOrdersMeta(orderList, new DataQueryHandler() {
                @Override
                public void onSuccess(Object obj) {
                    hideProgress();
                    mOrderAdapter.notifyDataSetChanged();
                }

                @Override
                public void onFailure(Exception error) {
                    error.printStackTrace();
                    hideProgress();
                }
            });
        } else {
            hideProgress();
        }
    }

    @Override
    public void onResume() {
        super.onResume();
        if (notifyOrder) {
            showSellerOrder();
        } else {
            loadSellerOrders();
        }
    }
}