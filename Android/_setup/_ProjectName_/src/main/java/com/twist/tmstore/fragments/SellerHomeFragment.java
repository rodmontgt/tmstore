package com.twist.tmstore.fragments;

import android.content.DialogInterface;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v7.app.ActionBar;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.twist.tmstore.BaseFragment;
import com.twist.tmstore.BuildConfig;
import com.twist.tmstore.L;
import com.twist.tmstore.MainActivity;
import com.twist.tmstore.R;
import com.twist.tmstore.TMStoreApp;
import com.twist.tmstore.dialogs.ConsentDialog;
import com.twist.tmstore.listeners.BackKeyListener;
import com.utils.Helper;

/**
 * Created by Twist Mobile on 10/5/2017.
 */

public class SellerHomeFragment extends BaseFragment implements BackKeyListener {
    public SellerHomeFragment() {
    }

    public static SellerHomeFragment newInstance() {
        return new SellerHomeFragment();
    }

    @Override
    public void onStart() {
        super.onStart();
        setupActionBar();
        ConsentDialog.show(this);
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setHasOptionsMenu(true);
        setupActionBar();
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View rootView = inflater.inflate(R.layout.fragment_seller_home, container, false);
        setupActionBar();
        initCoreFragment(rootView);
        return rootView;
    }

    private void initCoreFragment(View rootView) {
        addBackKeyListenerOnView(rootView, this);

        ImageView img_app_logo;
        TextView text_msg;
        Button btn_register;

        img_app_logo = (ImageView) rootView.findViewById(R.id.img_app_logo);

        Glide.with(getContext())
                .load(R.drawable.app_icon)
                .asBitmap()
                .into(img_app_logo);

        text_msg = (TextView) rootView.findViewById(R.id.text_msg);
        text_msg.setText(String.format(getString(L.string.txt_msg_seller_intro), Helper.getApplicationName()));

        btn_register = (Button) rootView.findViewById(R.id.btn_register);
        btn_register.setText(getString(L.string.btn_seller_register_login));
        Helper.stylize(btn_register);

        btn_register.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                ((MainActivity) getActivity()).showSellerLoginFragment();
            }
        });
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        resetTitleBar();
    }

    private void resetTitleBar() {
        ((MainActivity) getActivity()).resetTitleBar();
        ((MainActivity) getActivity()).restoreActionBar();
        ((MainActivity) getActivity()).reloadMenu();
        setupActionBar();
    }

    @Override
    public void onBackPressed() {
        Helper.getConfirmation(
                getActivity(),
                getString(L.string.exit_message),
                false,
                new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int id) {
                        TMStoreApp.exit(getActivity());
                    }
                },
                null);
    }

    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
        super.onCreateOptionsMenu(menu, inflater);
        menu.clear();
        setupActionBar();
    }

    private void setupActionBar() {
        ((MainActivity) getActivity()).resetDrawer();
        ((MainActivity) getActivity()).closeDrawer();
        ((MainActivity) getActivity()).lockDrawer();
        ActionBar actionBar = getSupportActionBar();
        if (actionBar != null) {
            actionBar.setHomeButtonEnabled(false);
            actionBar.setDisplayShowHomeEnabled(false);
            actionBar.setHomeAsUpIndicator(null);
            actionBar.show();
        }
    }
}
