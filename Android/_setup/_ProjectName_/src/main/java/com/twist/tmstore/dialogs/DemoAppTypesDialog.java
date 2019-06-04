package com.twist.tmstore.dialogs;

import android.app.Dialog;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v4.content.res.ResourcesCompat;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageButton;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.twist.tmstore.BaseDialogFragment;
import com.twist.tmstore.L;
import com.twist.tmstore.R;
import com.twist.tmstore.adapters.AppTypesAdapter;
import com.twist.tmstore.entities.AppType;
import com.utils.Helper;

import java.util.ArrayList;

/**
 * Created by Twist Mobile on 11/27/2017.
 */

public class DemoAppTypesDialog extends BaseDialogFragment {
    private SelectAppTypeListener listener;

    public static DemoAppTypesDialog newInstance() {
        DemoAppTypesDialog fragment = new DemoAppTypesDialog();
        return fragment;
    }

    public interface SelectAppTypeListener {
        void onSelectAppType(String appType);
    }

    public void onStart() {
        super.onStart();
        Dialog dialog = this.getDialog();
        if (dialog != null && dialog.getWindow() != null) {
            dialog.getWindow().setLayout(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
            dialog.getWindow().setBackgroundDrawable(new ColorDrawable(ResourcesCompat.getColor(getResources(), R.color.color_bg_theme, null)));
        }
    }

    public void setAppTypeDialogListener(SelectAppTypeListener listener) {
        this.listener = listener;
    }

    public DemoAppTypesDialog() {
        // Empty constructor is required for DialogFragment
        // Make sure not to add arguments to the constructor
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
        return inflater.inflate(R.layout.dialog_get_app_type, container);
    }

    @Override
    public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        RecyclerView rvAppType = (RecyclerView) view.findViewById(R.id.rv_app_type);
        Helper.stylizeView(view.findViewById(R.id.header_box));

        TextView header_msg = (TextView) view.findViewById(R.id.header_msg);
        header_msg.setText(getString(L.string.title_dialog_get_app_type));
        Helper.stylizeActionBar(header_msg);
        ImageButton btn_close = (ImageButton) view.findViewById(R.id.btn_close);
        btn_close.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                dismiss();
            }
        });
        rvAppType.setLayoutManager(new LinearLayoutManager(getActivity()));
        final ArrayList<AppType> appTypes = createAppTypesList();
        AppTypesAdapter adapter = new AppTypesAdapter(appTypes);
        adapter.setOnItemClickListener(new AppTypesAdapter.OnItemClickListener() {
            @Override
            public void onItemClick(int position) {
                for (int i = 0; i < appTypes.size(); i++) {
                    if (i == position) {
                        AppType appType = appTypes.get(position);
                        if (appType != null) {
                            listener.onSelectAppType(appType.getType());
                            dismiss();
                        }
                    }
                }
            }
        });
        rvAppType.setAdapter(adapter);
    }

    private ArrayList<AppType> createAppTypesList() {
        ArrayList<AppType> appTypes = new ArrayList<>();
        appTypes.add(new AppType(getString(R.string.woocommerce_mobile_app), R.drawable.ic_app_normal, "config", getString(R.string.woocommerce_mobile_app_description)));
        appTypes.add(new AppType(getString(R.string.marketplace_app), R.drawable.ic_app_marketplace, "config_marketplace", getString(R.string.marketplace_app_description)));
        appTypes.add(new AppType(getString(R.string.buyer_app), R.drawable.ic_app_buyer, "config_buyer", getString(R.string.buyer_app_description)));
        appTypes.add(new AppType(getString(R.string.seller_app), R.drawable.ic_app_seller, "config_seller", getString(R.string.seller_app_description)));
        //appTypes.add(new AppType(getString(R.string.multistore_app), R.drawable.ic_app_multistore, "config_multistore", getString(R.string.multistore_app_description)));
        return appTypes;
    }
}
