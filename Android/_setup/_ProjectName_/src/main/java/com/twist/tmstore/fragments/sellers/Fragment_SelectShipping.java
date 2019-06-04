package com.twist.tmstore.fragments.sellers;

import android.app.Dialog;
import android.graphics.Color;
import android.graphics.PorterDuff;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.twist.dataengine.entities.RawShipping;
import com.twist.tmstore.BaseDialogFragment;
import com.twist.tmstore.L;
import com.twist.tmstore.R;
import com.twist.tmstore.adapters.Adapter_SelectEntity;
import com.twist.tmstore.entities.AppInfo;
import com.utils.CContext;
import com.utils.Helper;

import java.util.ArrayList;
import java.util.List;

public class Fragment_SelectShipping extends BaseDialogFragment {

    private ShippingSelectionListener mListener;
    private List<RawShipping> selected_shippings;

    public Fragment_SelectShipping() {
        // Required empty public constructor
    }

    public static Fragment_SelectShipping newInstance(ShippingSelectionListener listener) {
        Fragment_SelectShipping fragment = new Fragment_SelectShipping();
        fragment.mListener = listener;
        return fragment;
    }

    public static Fragment_SelectShipping newInstance(List<RawShipping> selected_shippings, ShippingSelectionListener listener) {
        Fragment_SelectShipping fragment = new Fragment_SelectShipping();
        fragment.mListener = listener;
        fragment.selected_shippings = selected_shippings;
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    public void onStart() {
        super.onStart();
        Dialog dialog = getDialog();
        if (dialog != null && dialog.getWindow() != null) {
            dialog.getWindow().setLayout(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
            dialog.getWindow().setBackgroundDrawable(new ColorDrawable(Color.WHITE));
        }
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {

        Dialog dialog = this.getDialog();
        if (dialog != null) {
            Window window = dialog.getWindow();
            if (window != null) {
                window.requestFeature(Window.FEATURE_NO_TITLE);
            }
        }

        View rootView = inflater.inflate(R.layout.fragment_select_attribute_terms, container, false);

        LinearLayout btn_section = (LinearLayout) rootView.findViewById(R.id.title_attribute_section);
        btn_section.setBackgroundColor(Color.parseColor(AppInfo.color_theme));

        TextView title_attribute = (TextView) rootView.findViewById(R.id.title_attribute);
        Helper.stylizeActionBar(title_attribute);
        title_attribute.setText(getString(L.string.title_select_shipping_types));
        Helper.stylizeActionText(title_attribute);

        ImageView btn_ok = (ImageView) rootView.findViewById(R.id.btn_ok);
        btn_ok.setVisibility(View.VISIBLE);
        btn_ok.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                dismiss();
            }
        });

        ImageView btn_cancel = (ImageView) rootView.findViewById(R.id.btn_cancel);
        Drawable drawableClose = CContext.getDrawable(getContext(), R.drawable.ic_vc_close);
        drawableClose.setColorFilter(Color.parseColor(AppInfo.color_actionbar_text), PorterDuff.Mode.SRC_ATOP);
        btn_cancel.setImageDrawable(drawableClose);
        btn_cancel.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                mListener.onCancelButton();
                dismiss();
            }

        });

        RecyclerView checkBoxRecyclerView = (RecyclerView) rootView.findViewById(R.id.recycler_view_checkbox);
        checkBoxRecyclerView.setLayoutManager(new LinearLayoutManager(getContext(), LinearLayoutManager.VERTICAL, false));

        Adapter_SelectEntity.EntitySelectionListener<RawShipping> entitySelectionListener = new Adapter_SelectEntity.EntitySelectionListener<RawShipping>() {
            @Override
            public void onEntitySelected(RawShipping tempShipping, boolean selected) {
                if (mListener != null) {
                    if (selected) {
                        mListener.onAttributeSelected(tempShipping);
                    } else {
                        mListener.onAttributeRemoved(tempShipping);
                    }
                }
            }
        };

        Adapter_SelectEntity<RawShipping> listAdapter = new Adapter_SelectEntity<>(RawShipping.getAll(), new ArrayList<>(selected_shippings), entitySelectionListener);
        checkBoxRecyclerView.setAdapter(listAdapter);
        return rootView;
    }


    @Override
    public void onDetach() {
        super.onDetach();
        mListener = null;
    }

    public interface ShippingSelectionListener {
        void onAttributeSelected(RawShipping attribute);

        void onAttributeRemoved(RawShipping attribute);

        void onCancelButton();
    }
}
