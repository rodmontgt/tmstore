package com.twist.tmstore;

import android.os.Bundle;
import android.view.MenuItem;

import com.twist.tmstore.fragments.WebViewFragment;

public class WebViewActivity extends BaseActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_web_view);
        Bundle bundle = getIntent().getExtras();
        if (bundle != null) {
            getFM().beginTransaction()
                    .replace(R.id.content, WebViewFragment.create(bundle.getString(Extras.ARG_TITLE), bundle.getString(Extras.ARG_URL)))
                    .commit();
        }
    }

    @Override
    protected void onActionBarRestored() {
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {
            case android.R.id.home:
                finish();
                return true;
        }
        return super.onOptionsItemSelected(item);
    }

    @Override
    public void onBackPressed() {
        if (getSupportFragmentManager().getBackStackEntryCount() > 0) {
            getSupportFragmentManager().popBackStack();
        } else {
            super.onBackPressed();
        }
    }
}
