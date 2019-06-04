package com.twist.tmstore.fragments.sellers;

import android.app.Dialog;
import android.app.FragmentManager;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
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

import com.twist.dataengine.entities.TM_Attribute;
import com.twist.dataengine.entities.RawAttribute;
import com.twist.tmstore.BaseDialogFragment;
import com.twist.tmstore.R;
import com.twist.tmstore.adapters.Adapter_SelectAttributesTerms;
import com.utils.Helper;
import com.utils.HtmlCompat;

import java.util.ArrayList;
import java.util.List;

public class Fragment_SelectAttributeTerms extends BaseDialogFragment {

    private TermSelectionListener mListener;
    private RawAttribute rawAttribute;
    private TM_Attribute actualAttribute;
    private List<String> currentOptions;

    public Fragment_SelectAttributeTerms() {
        // Required empty public constructor
    }

    public static Fragment_SelectAttributeTerms newInstance(RawAttribute rawAttribute, TM_Attribute actualAttribute, TermSelectionListener listener) {
        Fragment_SelectAttributeTerms fragment = new Fragment_SelectAttributeTerms();
        fragment.mListener = listener;
        fragment.rawAttribute = rawAttribute;
        fragment.actualAttribute = actualAttribute;
        fragment.currentOptions = new ArrayList<>(actualAttribute.options);
        return fragment;
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
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        Dialog dialog = this.getDialog();
        if (dialog != null && dialog.getWindow() != null) {
            dialog.getWindow().requestFeature(Window.FEATURE_NO_TITLE);
        }

        View rootView = inflater.inflate(R.layout.fragment_select_attribute_terms, container, false);

        LinearLayout btn_section = (LinearLayout) rootView.findViewById(R.id.title_attribute_section);
        Helper.stylize(btn_section);

        TextView title_attribute = (TextView) rootView.findViewById(R.id.title_attribute);
        title_attribute.setText(HtmlCompat.fromHtml(rawAttribute.getName()));
        Helper.stylizeActionText(title_attribute);

        ImageView btn_ok = (ImageView) rootView.findViewById(R.id.btn_ok);
        btn_ok.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (mListener != null && currentOptions.size() > 0) {
                    actualAttribute.options = currentOptions;
                    mListener.onAttributeTermSelected(currentOptions);
                }
                dismiss();
            }
        });
        Helper.stylizeActionBar(btn_ok);

        ImageView btn_cancel = (ImageView) rootView.findViewById(R.id.btn_cancel);
        btn_cancel.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                getActivity().getFragmentManager().popBackStack("dialog", FragmentManager.POP_BACK_STACK_INCLUSIVE);
                dismiss();
            }
        });
        Helper.stylizeActionBar(btn_cancel);

        RecyclerView checkBoxRecyclerView = (RecyclerView) rootView.findViewById(R.id.recycler_view_checkbox);
        checkBoxRecyclerView.setLayoutManager(new LinearLayoutManager(getContext(), LinearLayoutManager.VERTICAL, false));
        Adapter_SelectAttributesTerms listAdapter = new Adapter_SelectAttributesTerms(getContext(), rawAttribute, currentOptions, false);
        checkBoxRecyclerView.setAdapter(listAdapter);

        return rootView;
    }

    @Override
    public void onDetach() {
        super.onDetach();
        mListener = null;
    }

    public interface TermSelectionListener {
        void onAttributeTermSelected(List<String> options);
    }
}
