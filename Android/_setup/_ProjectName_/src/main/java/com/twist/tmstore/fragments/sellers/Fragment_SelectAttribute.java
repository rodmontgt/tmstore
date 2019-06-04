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

import com.twist.dataengine.entities.RawAttribute;
import com.twist.tmstore.BaseDialogFragment;
import com.twist.tmstore.L;
import com.twist.tmstore.R;
import com.twist.tmstore.adapters.Adapter_SelectAttributesTerms;
import com.twist.tmstore.entities.AppInfo;
import com.utils.CContext;
import com.utils.Helper;

public class Fragment_SelectAttribute extends BaseDialogFragment {

    private AttributeSelectionListener mListener;

    public Fragment_SelectAttribute() {
        // Required empty public constructor
    }

    public static Fragment_SelectAttribute newInstance(AttributeSelectionListener listener) {
        Fragment_SelectAttribute fragment = new Fragment_SelectAttribute();
        fragment.mListener = listener;
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
        title_attribute.setText(getString(L.string.select_attribute_dialog_title));
        Helper.stylizeActionText(title_attribute);

        RecyclerView checkBoxRecyclerView = (RecyclerView) rootView.findViewById(R.id.recycler_view_checkbox);
        checkBoxRecyclerView.setLayoutManager(new LinearLayoutManager(getContext(), LinearLayoutManager.VERTICAL, false));
        Adapter_SelectAttributesTerms listAdapter = new Adapter_SelectAttributesTerms(getContext(), RawAttribute.getAll(), mListener, true);
        checkBoxRecyclerView.setAdapter(listAdapter);

        ImageView btn_ok = (ImageView) rootView.findViewById(R.id.btn_ok);
        btn_ok.setEnabled(false);
        btn_ok.setVisibility(View.INVISIBLE);

        ImageView btn_cancel = (ImageView) rootView.findViewById(R.id.btn_cancel);
        Drawable drawableClose = CContext.getDrawable(getContext(), R.drawable.ic_vc_close);
        drawableClose.setColorFilter(Color.parseColor(AppInfo.color_actionbar_text), PorterDuff.Mode.SRC_ATOP);
        btn_cancel.setImageDrawable(drawableClose);
        btn_cancel.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                dismiss();
            }
        });

        return rootView;
    }


    @Override
    public void onDetach() {
        super.onDetach();
        mListener = null;
    }

    public interface AttributeSelectionListener {
        void onAttributeSelected(RawAttribute attribute);
    }
}
