package com.twist.tmstore.fragments;

import android.os.Bundle;
import android.support.annotation.Nullable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.TextView;

import com.twist.dataengine.entities.RawCategory;
import com.twist.tmstore.BaseFragment;
import com.twist.tmstore.R;
import com.twist.tmstore.adapters.RawCategoryAdapter;
import com.twist.tmstore.fragments.sellers.Fragment_SelectCategory;
import com.utils.Helper;

/**
 * Created by Twist Mobile on 13-12-2016.
 */

public class Fragment_ListCategoryContainer extends BaseFragment {

    RawCategoryAdapter rawCategoryAdapter;
    private RawCategory parentCategory;
    private Fragment_SelectCategory.ListSelectionListener listSelectionListener;

    public static Fragment_ListCategoryContainer newInstance(int parentCategoryId, Fragment_SelectCategory.ListSelectionListener listSelectionListener) {
        Fragment_ListCategoryContainer fragment_listCategoryContainer = new Fragment_ListCategoryContainer();
        if (parentCategoryId > 0)
            fragment_listCategoryContainer.parentCategory = RawCategory.getWithId(parentCategoryId);

        fragment_listCategoryContainer.listSelectionListener = listSelectionListener;
        return fragment_listCategoryContainer;
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_list_category, container, false);
        ImageButton btn_up = (ImageButton) view.findViewById(R.id.btn_up);
        Helper.stylizeVector(btn_up);

        LinearLayout layout_path = (LinearLayout) view.findViewById(R.id.layout_path);

        TextView text_path = (TextView) view.findViewById(R.id.text_path);
        ListView listCategory = (ListView) view.findViewById(R.id.list_category);

        if (parentCategory != null) {
            rawCategoryAdapter = new RawCategoryAdapter(getContext(), parentCategory.getChildren(), listSelectionListener);
            layout_path.setVisibility(View.VISIBLE);
            text_path.setText(parentCategory.getNestedName());
            text_path.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    listSelectionListener.onCategoryExpanded(parentCategory.getParentId());
                }
            });
            btn_up.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    listSelectionListener.onCategoryExpanded(parentCategory.getParentId());
                }
            });
        } else {
            layout_path.setVisibility(View.GONE);
            rawCategoryAdapter = new RawCategoryAdapter(getContext(), RawCategory.getRoots(), listSelectionListener);
        }
        rawCategoryAdapter.setShowCategoryFullPath(false);
        rawCategoryAdapter.setShowExpandIconVisible(true);
        listCategory.setAdapter(rawCategoryAdapter);
        rawCategoryAdapter.notifyDataSetChanged();

        return view;
    }
}
