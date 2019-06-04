package com.twist.tmstore.multistore;

import android.content.Intent;
import android.graphics.Color;
import android.graphics.Paint;
import android.os.Build;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.SearchView;
import android.support.v7.widget.Toolbar;
import android.text.InputType;
import android.text.TextUtils;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.google.android.gms.common.api.CommonStatusCodes;
import com.parse.FindCallback;
import com.parse.ParseException;
import com.parse.ParseGeoPoint;
import com.parse.ParseObject;
import com.parse.ParseQuery;
import com.twist.tmstore.BuildConfig;
import com.twist.tmstore.Constants;
import com.twist.tmstore.Extras;
import com.twist.tmstore.L;
import com.twist.tmstore.LauncherActivity;
import com.twist.tmstore.R;
import com.twist.tmstore.adapters.Adapter_MultiStoreList;
import com.twist.tmstore.config.MultiStoreConfig;
import com.twist.tmstore.entities.AppInfo;
import com.twist.tmstore.entities.RecentSearchItem;
import com.twist.tmstore.views.MySearchView;
import com.utils.Helper;
import com.utils.SearchHandler;

import java.util.ArrayList;
import java.util.List;

public class MultiStoreListActivity extends AppCompatActivity {

    private static final int NEAR_BY_STORES_IN_KM = 15;

    private MultiStoreListActivity thisActivity;
    private ProgressBar progressBar;
    private MySearchView mSearchView;
    private SearchHandler mSearchHandler;
    private RecyclerView recyclerView;
    private Adapter_MultiStoreList mStoreListAdapter;
    private TextView mTextShowAllStores;
    private TextView mTextNoStoreAvailable;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        thisActivity = this;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            Window window = getWindow();
            window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
            window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
            window.setStatusBarColor(Color.parseColor(AppInfo.color_theme_statusbar));
        }
        setContentView(R.layout.activity_multi_store_list);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        toolbar.setBackgroundColor(Color.parseColor(AppInfo.color_theme));
        Helper.stylizeOverflowIcon(toolbar);

        mSearchView = (MySearchView) findViewById(R.id.search_view);
        mSearchView.setVisibility(View.GONE);

        mSearchHandler = new SearchHandler();
        progressBar = (ProgressBar) findViewById(R.id.progressBar);
        progressBar.setVisibility(View.VISIBLE);
        Helper.stylize(progressBar);

        mTextNoStoreAvailable = (TextView) findViewById(R.id.text_no_store_available);
        mTextNoStoreAvailable.setText(L.getString(L.string.no_store_available));
        mTextNoStoreAvailable.setVisibility(View.GONE);

        mTextShowAllStores = (TextView) findViewById(R.id.text_show_all_stores);
        mTextShowAllStores.setText(L.getString(L.string.show_all_stores));
        mTextShowAllStores.setVisibility(View.GONE);
        if (BuildConfig.SEARCH_NEARBY) {
            mTextShowAllStores.setPaintFlags(mTextShowAllStores.getPaintFlags() | Paint.UNDERLINE_TEXT_FLAG);
            mTextShowAllStores.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (BuildConfig.MULTI_STORE) {
                        Intent intent = new Intent(thisActivity, MultiStoreListAllActivity.class);
                        intent.setAction(Constants.ACTION_MULTI_STORE_SEARCH_ALL);
                        startActivityForResult(intent, -1);
                    }
                }
            });
        }
        recyclerView = (RecyclerView) findViewById(R.id.recyclerView);

        final String action = getIntent().getAction();
        if (BuildConfig.SEARCH_NEARBY && action != null && action.equals(Constants.ACTION_MULTI_STORE_SEARCH_NEARBY)) {
            Bundle extras = getIntent().getExtras();
            if (extras != null) {
                Double latitude = extras.getDouble("latitude");
                Double longitude = extras.getDouble("longitude");
                loadNearByStores(latitude, longitude);
            }
        } else {
            mTextNoStoreAvailable.setText(L.getString(L.string.no_store_available));
            loadMultiStoreList((MultiStoreConfig.getMultiStoreConfigList(true)));
        }
    }

    private List<MultiStoreConfig> getActiveStores(List<MultiStoreConfig> list) {
        if (!BuildConfig.SEARCH_NEARBY) {
            return list;
        }

        List<MultiStoreConfig> newList = new ArrayList<>();
        for (MultiStoreConfig config : list) {
            if (config.isActive())
                newList.add(config);
        }
        return newList;
    }

    private void loadMultiStoreList(List<MultiStoreConfig> list) {
        progressBar.setVisibility(View.GONE);
        if (list.size() > 0) {
            recyclerView.setVisibility(View.VISIBLE);
            mTextNoStoreAvailable.setVisibility(View.GONE);
        } else {
            recyclerView.setVisibility(View.GONE);
            mTextNoStoreAvailable.setVisibility(View.VISIBLE);
        }

        mStoreListAdapter = new Adapter_MultiStoreList(this, list);
        mStoreListAdapter.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Bundle bundle = getIntent().getExtras();
                final String action = getIntent().getAction();
                if (action != null && action.equals(Constants.ACTION_MULTI_STORE_SEARCH_NEARBY)) {
                    Intent intent = new Intent(MultiStoreListActivity.this, LauncherActivity.class);
                    intent.putExtra(Extras.MULTI_STORE_PLATFORM, v.getTag().toString());
                    startActivity(intent);
                } else {
                    if (bundle != null && bundle.getBoolean(Extras.SHOW_ALL_PLATFORMS)) {
                        Intent intent = new Intent(MultiStoreListActivity.this, LauncherActivity.class);
                        intent.putExtra(Extras.MULTI_STORE_PLATFORM, v.getTag().toString());
                        startActivity(intent);
                    } else {
                        Intent intent = new Intent();
                        intent.putExtra(Extras.MULTI_STORE_PLATFORM, v.getTag().toString());
                        setResult(RESULT_OK, intent);
                    }
                    finish();
                }
            }
        });
        recyclerView.setAdapter(mStoreListAdapter);
        setUpSearch();
    }

    private void loadNearByStores(double latitude, double longitude) {
        ParseGeoPoint userLocation = new ParseGeoPoint(latitude, longitude);
        ParseQuery<ParseObject> query = ParseQuery.getQuery("AppData");
        query.whereStartsWith("multi_store_platform", "android");
        query.whereWithinKilometers("store_location", userLocation, NEAR_BY_STORES_IN_KM);
        query.findInBackground(new FindCallback<ParseObject>() {
            @Override
            public void done(List<ParseObject> objects, ParseException e) {
                if (e == null) {
                    mTextShowAllStores.setVisibility(View.VISIBLE);
                    List<MultiStoreConfig> multiStoreConfigs = MultiStoreConfig.createConfigs(objects, true);
                    mTextNoStoreAvailable.setText(L.getString(L.string.no_near_by_store_available));
                    loadMultiStoreList(getActiveStores(multiStoreConfigs));
                }
            }
        });
    }

    private void closeSearch() {
        if (mSearchView != null) {
            mSearchView.onActionViewCollapsed();
        }
    }

    private void setUpSearch() {
        mSearchView.setIconifiedByDefault(false);
        mSearchView.setIconified(true);
        mSearchView.setThemeColor(Color.parseColor(AppInfo.color_actionbar_text));
        mSearchView.setInputType(InputType.TYPE_TEXT_FLAG_NO_SUGGESTIONS);
        mSearchView.setVisibility(View.VISIBLE);
        mSearchView.setOnQueryTextFocusChangeListener(new View.OnFocusChangeListener() {
            @Override
            public void onFocusChange(View view, boolean hasFocus) {
                if (hasFocus) {
                    mSearchHandler.handleSearchViewFocus(view, true);
                }
            }
        });
        mSearchView.setOnQueryTextListener(new SearchView.OnQueryTextListener() {
            @Override
            public boolean onQueryTextSubmit(String query) {
                query = query.toLowerCase();
                mStoreListAdapter.getTextFilter().filter(query);
                new RecentSearchItem(query);
                progressBar.setVisibility(View.VISIBLE);
                progressBar.setVisibility(View.GONE);
                return false;
            }

            @Override
            public boolean onQueryTextChange(String newText) {
                progressBar.setVisibility(View.GONE);
                final String searchText = newText.toLowerCase();
                if (TextUtils.isEmpty(searchText)) {
                    mStoreListAdapter.clearFilter();
                    mStoreListAdapter.notifyDataSetChanged();
                    return false;
                } else {
                    mStoreListAdapter.getTextFilter().filter(newText);
                    return true;
                }
            }
        });

        mSearchView.setOnCloseListener(new SearchView.OnCloseListener() {
            @Override
            public boolean onClose() {
                progressBar.setVisibility(View.GONE);
                closeSearch();
                return false;
            }
        });
    }

    @Override
    public void onBackPressed() {
        Intent intent = new Intent();
        setResult(CommonStatusCodes.CANCELED, intent);
        finish();
    }
}
