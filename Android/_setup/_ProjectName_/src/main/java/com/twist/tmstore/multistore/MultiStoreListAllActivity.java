package com.twist.tmstore.multistore;

import android.content.Intent;
import android.graphics.Color;
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
import com.parse.ParseObject;
import com.parse.ParseQuery;
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

public class MultiStoreListAllActivity extends AppCompatActivity {
    private ProgressBar progressBar;
    private MySearchView mSearchView;
    private SearchHandler mSearchHandler;
    private RecyclerView recyclerView;
    private Adapter_MultiStoreList mStoreListAdapter;
    private TextView mTextNoStoreAvailable;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            Window window = getWindow();
            window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
            window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
            window.setStatusBarColor(Color.parseColor(AppInfo.color_theme_statusbar));
        }
        setContentView(R.layout.activity_multi_store_list_all);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        toolbar.setBackgroundColor(Color.parseColor(AppInfo.color_theme));
        Helper.stylizeOverflowIcon(toolbar);

        mSearchHandler = new SearchHandler();
        progressBar = (ProgressBar) findViewById(R.id.progressBar);
        Helper.stylize(progressBar);
        progressBar.setVisibility(View.VISIBLE);

        mTextNoStoreAvailable = (TextView) findViewById(R.id.text_no_store_available);
        mTextNoStoreAvailable.setText(L.getString(L.string.no_store_available));
        mTextNoStoreAvailable.setVisibility(View.GONE);

        recyclerView = (RecyclerView) findViewById(R.id.recyclerView);

        String action = getIntent().getAction();
        if (action != null && action.equals(Constants.ACTION_MULTI_STORE_SEARCH_ALL)) {
            showAllStores();
        } else {
            loadMultiStoreList(MultiStoreConfig.getMultiStoreConfigList(true));
        }
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
                    Intent intent = new Intent(MultiStoreListAllActivity.this, LauncherActivity.class);
                    intent.putExtra(Extras.MULTI_STORE_PLATFORM, v.getTag().toString());
                    startActivity(intent);
                } else {
                    if (bundle != null && bundle.getBoolean(Extras.SHOW_ALL_PLATFORMS)) {
                        Intent intent = new Intent(MultiStoreListAllActivity.this, LauncherActivity.class);
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

    private void showAllStores() {
        ParseQuery<ParseObject> query = ParseQuery.getQuery("AppData");
        query.findInBackground(new FindCallback<ParseObject>() {
            @Override
            public void done(List<ParseObject> objects, ParseException e) {
                if (e == null) {
                    List<MultiStoreConfig> multiStoreConfigs = MultiStoreConfig.createConfigs(objects, true);
                    loadMultiStoreList(getInactiveStores(multiStoreConfigs));
                }
            }
        });
    }

    private List<MultiStoreConfig> getInactiveStores(List<MultiStoreConfig> list) {
        List<MultiStoreConfig> newList = new ArrayList<>();
        for (MultiStoreConfig config : list) {
            if (!config.isActive())
                newList.add(config);
        }
        return newList;
    }

    private void closeSearch() {
        if (mSearchView != null) {
            mSearchView.onActionViewCollapsed();
        }
    }

    private void setUpSearch() {
        mSearchView = (MySearchView) findViewById(R.id.search_view);
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
