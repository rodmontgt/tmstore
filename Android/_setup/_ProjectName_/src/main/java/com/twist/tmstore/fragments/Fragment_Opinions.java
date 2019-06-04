package com.twist.tmstore.fragments;

import android.os.Bundle;
import android.support.design.widget.CoordinatorLayout;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ListView;
import android.widget.TextView;

import com.parse.FindCallback;
import com.parse.ParseException;
import com.parse.ParseObject;
import com.parse.ParseQuery;
import com.parse.ParseUser;
import com.twist.dataengine.DataEngine;
import com.twist.dataengine.DataQueryHandler;
import com.twist.dataengine.entities.TM_ProductInfo;
import com.twist.tmstore.BaseFragment;
import com.twist.tmstore.Constants;
import com.twist.tmstore.L;
import com.twist.tmstore.MainActivity;
import com.twist.tmstore.R;
import com.twist.tmstore.adapters.Adapter_Poll;
import com.twist.tmstore.entities.AppInfo;
import com.utils.AnalyticsHelper;
import com.utils.Helper;

import java.util.ArrayList;
import java.util.List;

public class Fragment_Opinions extends BaseFragment {

    private List<PollInfo> mPollInfoList = new ArrayList<>();
    private Adapter_Poll mPollAdapter;
    private CoordinatorLayout mRootLayout;
    private View mEmptyView;

    public Fragment_Opinions() {
    }

    public static Fragment_Opinions newInstance() {
        return new Fragment_Opinions();
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setHasOptionsMenu(true);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_opinions, container, false);

        setActionBarHomeAsUpIndicator();
        getBaseActivity().restoreActionBar();

        mRootLayout = (CoordinatorLayout) view.findViewById(R.id.coordinatorLayout);
        ListView mListView = (ListView) view.findViewById(R.id.list_polls);
        mEmptyView = view.findViewById(R.id.text_empty);

        mListView.setEmptyView(mEmptyView);
        if (mPollAdapter == null) {
            mPollAdapter = new Adapter_Poll(this);
        }
        mListView.setAdapter(mPollAdapter);
        if (mPollAdapter.getCount() == 0) {
            this.fetchPollData();
        }
        setTitle(getString(L.string.title_polls));

        Button btn_keepshopping = (Button) view.findViewById(R.id.btn_keepshopping);
        btn_keepshopping.setText(getString(L.string.keep_shopping));
        Helper.stylize(btn_keepshopping);
        btn_keepshopping.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                MainActivity.mActivity.onNavigationDrawerItemSelected(Constants.MENU_ID_HOME, -1);
            }
        });

        ((TextView) view.findViewById(R.id.opinion_message)).setText(getString(L.string.opinion_message));
        AnalyticsHelper.registerVisitScreenEvent(Constants.OPINION);
        return view;
    }

    public void fetchPollData() {
        mEmptyView.setVisibility(View.GONE);
        showProgress(getString(L.string.retrieving));
        List<ParseQuery<ParseObject>> queries = new ArrayList<>();
        queries.add(ParseQuery.getQuery("PollData").whereGreaterThan("likes", 0));
        queries.add(ParseQuery.getQuery("PollData").whereGreaterThan("unlikes", 0));

        ParseQuery<ParseObject> query = ParseQuery.or(queries);
        query.whereEqualTo("user_id", ParseUser.getCurrentUser());
        query.whereEqualTo("is_active", true);
        query.findInBackground(new FindCallback<ParseObject>() {
            @Override
            public void done(List<ParseObject> objects, ParseException e) {
                if (e == null) {
                    String ids = "";
                    AppInfo.PENDING_NOTIFICATIONS = 0;
                    for (ParseObject obj : objects) {
                        PollInfo pollInfo = new PollInfo();
                        pollInfo.pollId = obj.getObjectId();
                        pollInfo.productId = Integer.parseInt(obj.getString("product_id"));
                        pollInfo.likes = (obj.getNumber("likes").intValue());
                        pollInfo.unlikes = (obj.getNumber("unlikes").intValue());
                        mPollInfoList.add(pollInfo);
                        ids += pollInfo.productId + ";";
                    }
                    if (mPollInfoList.size() != 0) {
                        fetchPollProducts(ids.substring(0, ids.length() - 1));
                    } else {
                        hideProgressView();
                    }
                } else {
                    hideProgressView();
                }
            }
        });
    }

    private void fetchPollProducts(final String productIds) {
        DataEngine.getDataEngine().getPollProductsInBackground(productIds, new DataQueryHandler() {
            @Override
            public void onSuccess(Object data) {
                mPollAdapter.setData(gePollProductList());
                hideProgress();
            }

            @Override
            public void onFailure(Exception error) {
                hideProgressView();
            }
        });
    }

    private List<TM_ProductInfo> gePollProductList() {
        List<TM_ProductInfo> list = TM_ProductInfo.getAllProductWithPoll();
        for (TM_ProductInfo product : list) {
            PollInfo pollInfo = findPollByProduct(product.id);
            if (pollInfo != null) {
                product.likes = pollInfo.likes;
                product.unlikes = pollInfo.unlikes;
                product.poll_id = pollInfo.pollId;
            }
        }
        return list;
    }

    private PollInfo findPollByProduct(int id) {
        for (PollInfo pollInfo : mPollInfoList) {
            if (pollInfo.productId == id)
                return pollInfo;
        }
        return null;
    }

    public CoordinatorLayout getRootLayout() {
        return mRootLayout;
    }

    private void hideProgressView() {
        mEmptyView.setVisibility(View.VISIBLE);
        hideProgress();
    }

    private class PollInfo {
        String pollId;
        int productId;
        int likes;
        int unlikes;
    }
}