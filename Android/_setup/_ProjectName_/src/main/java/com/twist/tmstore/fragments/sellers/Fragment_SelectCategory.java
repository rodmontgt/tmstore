package com.twist.tmstore.fragments.sellers;

import android.app.Dialog;
import android.app.SearchManager;
import android.content.Context;
import android.graphics.Color;
import android.graphics.PorterDuff;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.support.v7.widget.SearchView;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.TextView;

import com.twist.dataengine.entities.RawCategory;
import com.twist.tmstore.BaseDialogFragment;
import com.twist.tmstore.L;
import com.twist.tmstore.R;
import com.twist.tmstore.adapters.RawCategoryAdapter;
import com.twist.tmstore.entities.AppInfo;
import com.twist.tmstore.fragments.Fragment_ListCategoryContainer;
import com.utils.Helper;

import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by Twist Mobile on 13-12-2016.
 */

public class Fragment_SelectCategory extends BaseDialogFragment implements SearchView.OnCloseListener {

    private static OnCompleteListener mOnCompleteListener;
    private ListSelectionListener listSelectionListener;
    private SearchView categoriesSearchView;
    private ListView listViewCategories;
    private FrameLayout containers;
    private List<RawCategory> selected_categories = new ArrayList<>();


    public Fragment_SelectCategory() {
        super();
        listSelectionListener = new ListSelectionListener() {
            @Override
            public void onCategorySelected(int categoryId) {
                Fragment_SelectCategory.this.selectCategory(categoryId);
            }

            @Override
            public void onCategoryUnSelected(int categoryId) {
                Fragment_SelectCategory.this.removeSelectCategory(categoryId);
            }

            @Override
            public boolean isCategorySelected(int categoryId) {
                return Fragment_SelectCategory.this.isCategorySelected(categoryId);
            }

            @Override
            public void onCategoryExpanded(int categoryId) {
                Fragment_SelectCategory.this.expandCategory(categoryId);
            }
        };
    }

    public static Fragment_SelectCategory newInstance(OnCompleteListener onCompleteListener, List<RawCategory> seleted_categories) {
        Fragment_SelectCategory df = new Fragment_SelectCategory();
        mOnCompleteListener = onCompleteListener;
        df.addCategories(seleted_categories);
        return df;
    }

    public void addCategories(List<RawCategory> categories) {
        selected_categories.addAll(categories);
    }

    public boolean isCategorySelected(int categoryId) {
        return selected_categories.contains(RawCategory.getWithId(categoryId));
    }

    public void selectCategory(RawCategory rawCategory) {
        selected_categories.add(rawCategory);
    }

    public void removeSelectCategory(RawCategory rawCategory) {
        selected_categories.remove(rawCategory);
    }

    public void selectCategory(int tempCategoryId) {

        selectCategory(RawCategory.getWithId(tempCategoryId));
    }

    public void removeSelectCategory(int tempCategoryId) {
        removeSelectCategory(RawCategory.getWithId(tempCategoryId));
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
        if (dialog != null && dialog.getWindow() != null) {
            dialog.getWindow().requestFeature(Window.FEATURE_NO_TITLE);
        }

        View rootView = inflater.inflate(R.layout.fragment_temp_category, container, false);

        LinearLayout title = (LinearLayout) rootView.findViewById(R.id.title_section);
        Helper.stylize(title);

        ImageView btn_ok = (ImageView) rootView.findViewById(R.id.btn_ok);
        btn_ok.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Helper.hideKeyboard(categoriesSearchView);
                mOnCompleteListener.onCompletion(selected_categories);
                dismiss();
            }
        });
        Helper.stylizeActionBar(btn_ok);

        ImageView btn_back = (ImageView) rootView.findViewById(R.id.btn_back);
        btn_back.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Helper.hideKeyboard(categoriesSearchView);
                dismiss();
            }
        });
        Helper.stylizeActionBar(btn_back);
        btn_back.setVisibility(View.VISIBLE);

        SearchManager searchManager = (SearchManager) getActivity().getSystemService(Context.SEARCH_SERVICE);
        categoriesSearchView = (SearchView) rootView.findViewById(R.id.search_view_categories);
        categoriesSearchView.setSearchableInfo(searchManager.getSearchableInfo(getActivity().getComponentName()));
        categoriesSearchView.setIconifiedByDefault(false);
        categoriesSearchView.setOnCloseListener(this);
        categoriesSearchView.clearFocus();
        categoriesSearchView.setQueryHint(getString(L.string.title_search));
        this.stylizeSearchView();

        listViewCategories = (ListView) rootView.findViewById(R.id.list_view_categories);
        containers = (FrameLayout) rootView.findViewById(R.id.container);

        RawCategoryAdapter listAdapter = new RawCategoryAdapter(getContext(), RawCategory.getAll(), listSelectionListener);
        listAdapter.setShowCategoryFullPath(true);
        listAdapter.setShowExpandIconVisible(false);
        listViewCategories.setAdapter(listAdapter);
        listViewCategories.setTextFilterEnabled(true);

        categoriesSearchView.setOnQueryTextListener(new SearchView.OnQueryTextListener() {
            @Override
            public boolean onQueryTextSubmit(String s) {
                categoriesSearchView.clearFocus();
                return true;
            }

            @Override
            public boolean onQueryTextChange(String s) {
                if (TextUtils.isEmpty(s)) {
                    //ImageView searchButton = (ImageView) categoriesSearchView.findViewById(android.support.v7.appcompat.R.id.search_mag_icon);
                    //searchButton.setImageResource(R.drawable.ic_vc_search);
                    listViewCategories.setVisibility(View.GONE);
                    containers.setVisibility(View.VISIBLE);
                } else {
                    ImageView searchButton = (ImageView) categoriesSearchView.findViewById(android.support.v7.appcompat.R.id.search_mag_icon);
                    //searchButton.setImageResource(R.drawable.ic_vc_arrow_back);
                    //Helper.stylize(searchButton);
                    searchButton.setOnClickListener(new View.OnClickListener() {
                        @Override
                        public void onClick(View view) {
                            listViewCategories.setVisibility(View.GONE);
                            containers.setVisibility(View.VISIBLE);
                        }
                    });
                    // listSelectionListener.onCategoryExpanded(parentCategory.getParentId());
                    listViewCategories.setVisibility(View.VISIBLE);
                    containers.setVisibility(View.GONE);
                    ((RawCategoryAdapter) listViewCategories.getAdapter()).filter(s);
                }
                return true;
            }
        });
        expandCategory(-1);
        Helper.hideKeyboard(categoriesSearchView);
        return rootView;
    }

    private void expandCategory(int categoryId) {
        getChildFragmentManager()
                .beginTransaction()
                .replace(R.id.container, Fragment_ListCategoryContainer.newInstance(categoryId, listSelectionListener), Fragment_ListCategoryContainer.class.getSimpleName())
                .setCustomAnimations(R.anim.slide_in, R.anim.slide_in_reverse)
                .commit();
    }

    @Override
    public boolean onClose() {
        return false;
    }

    private void stylizeSearchView() {
        Helper.stylize(categoriesSearchView);

        try {
            SearchView.SearchAutoComplete search_src_text = (SearchView.SearchAutoComplete) categoriesSearchView.findViewById(android.support.v7.appcompat.R.id.search_src_text);
            search_src_text.setHintTextColor(Color.parseColor(AppInfo.color_actionbar_text));
            search_src_text.setBackgroundColor(Color.parseColor(AppInfo.color_theme));

            Field mCursorDrawableRes = TextView.class.getDeclaredField("mCursorDrawableRes");
            mCursorDrawableRes.setAccessible(true);
            mCursorDrawableRes.set(search_src_text, R.drawable.search_view_cursor);

        } catch (Exception e) {
        }

        try {
            ImageView search_close_btn = (ImageView) categoriesSearchView.findViewById(android.support.v7.appcompat.R.id.search_close_btn);
            search_close_btn.setColorFilter(Color.parseColor(AppInfo.color_actionbar_text), PorterDuff.Mode.SRC_IN);
        } catch (Exception e) {
            e.printStackTrace();
        }

        try {
            View search_plate = categoriesSearchView.findViewById(android.support.v7.appcompat.R.id.search_plate);
            search_plate.setBackgroundColor(Color.parseColor(AppInfo.color_theme));
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public interface OnCompleteListener {
        void onCompletion(List<RawCategory> selected_categories);
    }

    public interface ListSelectionListener {
        void onCategorySelected(int categoryId);

        void onCategoryUnSelected(int categoryId);

        void onCategoryExpanded(int categoryId);

        boolean isCategorySelected(int categoryId);
    }
}