package com.twist.tmstore.fragments.filters;

import android.app.Dialog;
import android.content.DialogInterface;
import android.graphics.drawable.ColorDrawable;
import android.os.Build;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v4.content.res.ResourcesCompat;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.twist.dataengine.entities.TM_CategoryInfo;
import com.twist.dataengine.entities.TM_ComparableFilter;
import com.twist.dataengine.entities.TM_FilterAttribute;
import com.twist.dataengine.entities.TM_ProductFilter;
import com.twist.dataengine.entities.UserFilter;
import com.twist.tmstore.BaseDialogFragment;
import com.twist.tmstore.L;
import com.twist.tmstore.R;
import com.twist.tmstore.entities.AppInfo;
import com.utils.Helper;
import com.utils.HtmlCompat;

import java.util.ArrayList;
import java.util.List;

public class Fragment_FilterGroup extends BaseDialogFragment {

    private FilterCallback filterCallback = null;
    private LinearLayout layoutFiltersList;
    private List<TextView> filterTexts = new ArrayList<>();
    private int defaultSortIndex = 0;
    private boolean mEnableClick = true;

    public interface FilterCallback {
        void onFilterApplied(UserFilter filter);
    }

    public void setFilterCallback(FilterCallback filterCallback) {
        this.filterCallback = filterCallback;
    }

    private TM_ProductFilter productFilter;
    private UserFilter userFilter;
    private BaseFilterFragment.FilterUpdateListener filterUpdateListener;

    private void setUserFilter(UserFilter userFilter) {
        this.userFilter = userFilter;
        final String slug = TM_CategoryInfo.getWithId(productFilter.categoryId).slug;
        if (userFilter == null) {
            List<TM_FilterAttribute> userAttributes = new ArrayList<>();
            for (TM_FilterAttribute productAttribute : productFilter.getAttributes()) {
                TM_FilterAttribute userAttribute = new TM_FilterAttribute();
                userAttribute.attribute = productAttribute.attribute;
                userAttributes.add(userAttribute);
            }
            this.userFilter = new UserFilter(slug, productFilter.minPrice, productFilter.maxPrice, userAttributes, false);
        }

        if (defaultSortIndex > 0) {
            this.userFilter.setSortOrder(defaultSortIndex);
        }
    }

    public Fragment_FilterGroup() {
    }

    public static Fragment_FilterGroup newInstance() {
        return new Fragment_FilterGroup();
    }

    @Override
    public void onStart() {
        super.onStart();
        if (getDialog() != null) {
            Dialog dialog = getDialog();
            int width = ViewGroup.LayoutParams.MATCH_PARENT;
            int height = ViewGroup.LayoutParams.MATCH_PARENT;
            if (dialog.getWindow() != null) {
                dialog.getWindow().setLayout(width, height);
                dialog.getWindow().setBackgroundDrawable(new ColorDrawable(ResourcesCompat.getColor(getResources(), R.color.card_header_bg, null)));
            }
        }
    }

    @NonNull
    @Override
    public Dialog onCreateDialog(@NonNull Bundle savedInstanceState) {
        Dialog dialog = super.onCreateDialog(savedInstanceState);
        if (dialog.getWindow() != null) {
            dialog.getWindow().requestFeature(Window.FEATURE_NO_TITLE);
        }
        return dialog;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        if (getDialog() != null && getDialog().getWindow() != null) {
            getDialog().getWindow().requestFeature(Window.FEATURE_NO_TITLE);
        }
        updateFilter(productFilter, userFilter);
        View view = inflater.inflate(R.layout.fragment_filter_group, container, false);
        View header_box = view.findViewById(R.id.header_box);
        final View scroll_view = view.findViewById(R.id.scroll_view);
        Helper.stylize(header_box);

        final Button btn_apply_filter = (Button) view.findViewById(R.id.btn_apply_filter);
        Helper.stylize(btn_apply_filter);
        btn_apply_filter.setText(getString(L.string.apply));

        final TextView text_clear_filters = (TextView) view.findViewById(R.id.text_clear_filters);
        text_clear_filters.setText(getString(L.string.clear_filters));
        Helper.stylizeActionBar(text_clear_filters);

        TextView filterTitleTextView = (TextView) view.findViewById(R.id.filter_title);
        filterTitleTextView.setText(getString(L.string.title_filter));
        Helper.stylizeActionBar(filterTitleTextView);

        TextView selectFilterTextView = (TextView) view.findViewById(R.id.select_filter_to_apply);
        selectFilterTextView.setText(getString(L.string.select_filter_to_apply));

        layoutFiltersList = (LinearLayout) view.findViewById(R.id.filters_list);

        TextView txtSort = addNormalText(layoutFiltersList, getString(L.string.sort_by), true);
        txtSort.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mEnableClick) {
                    showSortFilter(productFilter, userFilter);
                    updateTitleSelection((TextView) v);
                }
            }
        });
        filterTexts.add(txtSort);

        if (productFilter.minPrice > 0 || productFilter.maxPrice < Integer.MAX_VALUE) {
            final TextView txtPriceRange = addNormalText(layoutFiltersList, getString(L.string.price_range), true);
            txtPriceRange.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (mEnableClick) {
                        showPriceRangeFilter(productFilter, userFilter);
                        updateTitleSelection(txtPriceRange);
                    }
                }
            });
            filterTexts.add(txtPriceRange);
        }

        TextView txtStock = addNormalText(layoutFiltersList, getString(L.string.stock_check), true);
        txtStock.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mEnableClick) {
                    showOutOfStockFilter(productFilter, userFilter);
                    updateTitleSelection((TextView) v);
                }
            }
        });
        filterTexts.add(txtStock);
        if (AppInfo.ENABLE_LOCATION_IN_FILTERS) {
            final TextView txtGeoLocation = addNormalText(layoutFiltersList, getString(L.string.filter_location), true);
            txtGeoLocation.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    showGeoLocationFilter(productFilter, userFilter);
                    updateTitleSelection(txtGeoLocation);
                }
            });
            filterTexts.add(txtGeoLocation);
        }

        TextView txtDiscount = addNormalText(layoutFiltersList, getString(L.string.discount), true);
        txtDiscount.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mEnableClick) {
                    showDiscountFilter(productFilter, userFilter);
                    updateTitleSelection((TextView) v);
                }
            }
        });
        filterTexts.add(txtDiscount);

        for (final TM_FilterAttribute productAttribute : productFilter.getAttributes()) {
            final TM_FilterAttribute userAttribute = userFilter.getOrAddAttributeByNameOf(productAttribute);
            TextView filterText = addNormalText(layoutFiltersList, productAttribute.attribute, true);
            filterTexts.add(filterText);
            filterText.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (mEnableClick) {
                        showAttributeFilter(productFilter, userFilter, productAttribute, userAttribute);
                        updateTitleSelection((TextView) v);
                    }
                }
            });
        }

        final ImageButton btn_close = (ImageButton) view.findViewById(R.id.btn_close);
        Helper.stylizeActionBar(btn_close);
        btn_close.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                dismiss();
            }
        });

        btn_apply_filter.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (filterCallback != null) {
                    List<TM_FilterAttribute> attributesToRemove = new ArrayList<>();
                    for (TM_FilterAttribute attribute : userFilter.getAttributes()) {
                        if (attribute.options.isEmpty()) {
                            attributesToRemove.add(attribute);
                        }
                    }
                    if (!attributesToRemove.isEmpty()) {
                        userFilter.removeAttributes(attributesToRemove);
                    }
                    filterCallback.onFilterApplied(userFilter);
                }
                dismiss();
            }
        });

        text_clear_filters.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Helper.getConfirmation(
                        getActivity(),
                        getString(L.string.reset_all_filters),
                        true,
                        new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface dialog, int which) {
                                userFilter = null;
                                if (filterCallback != null) {
                                    filterCallback.onFilterApplied(null);
                                }
                                dismiss();
                            }
                        },
                        null
                );
            }
        });

        filterUpdateListener = new BaseFilterFragment.FilterUpdateListener() {
            @Override
            public void onFilterUpdated(TM_ComparableFilter filter) {
                updateFilterTexts(filter);
            }

            @Override
            public void onFilterClick(boolean enableClick) {
                mEnableClick = enableClick;
                btn_close.setClickable(enableClick);
                btn_apply_filter.setClickable(enableClick);
                text_clear_filters.setClickable(enableClick);
                scroll_view.setClickable(enableClick);
                layoutFiltersList.setClickable(enableClick);
            }
        };

        showSortFilter(productFilter, userFilter);
        updateTitleSelection(txtSort);
        return view;
    }

    private TextView addNormalText(ViewGroup parentView, String text, boolean isTitle) {
        // Don't use android:id attribute for text view because we are inflating it into linear layout.
        // And using same id will set text on only first text view.
        LinearLayout view = (LinearLayout) LayoutInflater.from(getActivity()).inflate(R.layout.filter_attribute, parentView, true);
        TextView textView = (TextView) view.getChildAt(view.getChildCount() - 1);
        textView.setText(HtmlCompat.fromHtml(text));
        textView.setAllCaps(isTitle);
        return textView;
    }

    private void updateTitleSelection(TextView selectedText) {
        for (TextView textView : filterTexts) {
            // Fix a potential padding issue in Android 4.2
            int bottom = textView.getPaddingBottom();
            int top = textView.getPaddingTop();
            int right = textView.getPaddingRight();
            int left = textView.getPaddingLeft();

            if (textView.equals(selectedText)) {
                textView.setBackgroundResource(R.drawable.bottom_border_layout_white);
            } else {
                textView.setBackgroundResource(R.drawable.bottom_border_layout);
            }

            if (Build.VERSION.SDK_INT < Build.VERSION_CODES.KITKAT) {
                textView.setPadding(left, top, right, bottom);
            }
        }
    }

    private void updateFilterTexts(TM_ComparableFilter filter) {
//        try {
//            for (TextView filterText : filterTexts) {
//                if (filter.hasAnyOptionInAttribute(filterText.getText().toString())) {
//                    filterText.setVisibility(View.VISIBLE);
//                } else {
//                    filterText.setVisibility(View.GONE);
//                }
//            }
//        } catch (Exception e) {
//            e.printStackTrace();
//        }
    }

    public void setFilterData(TM_ProductFilter productFilter, UserFilter userFilter, int defaultSortIndex) {
        this.productFilter = productFilter;
        this.defaultSortIndex = defaultSortIndex;
        this.userFilter = userFilter;
    }

    private void updateFilter(TM_ProductFilter productFilter, UserFilter userFilter) {
        this.productFilter = productFilter;
        setUserFilter(userFilter);
    }

    private void showSortFilter(TM_ProductFilter productFilter, UserFilter userFilter) {
        getChildFragmentManager().beginTransaction()
                .replace(R.id.fragments_section, Filter_Sort.newInstance(productFilter, userFilter, filterUpdateListener))
                .commit();
    }

    private void showPriceRangeFilter(TM_ProductFilter productFilter, UserFilter userFilter) {
        getChildFragmentManager().beginTransaction()
                .replace(R.id.fragments_section, Filter_PriceRange.newInstance(productFilter, userFilter, filterUpdateListener))
                .commit();
    }

    private void showOutOfStockFilter(TM_ProductFilter productFilter, UserFilter userFilter) {
        getChildFragmentManager().beginTransaction()
                .replace(R.id.fragments_section, Filter_OutOfStock.newInstance(productFilter, userFilter, filterUpdateListener))
                .commit();
    }

    private void showGeoLocationFilter(TM_ProductFilter productFilter, UserFilter userFilter) {
        getChildFragmentManager().beginTransaction()
                .replace(R.id.fragments_section, Fragment_FilterByLocation.newInstance(productFilter, userFilter, filterUpdateListener))
                .commit();
    }

    private void showDiscountFilter(TM_ProductFilter productFilter, UserFilter userFilter) {
        getChildFragmentManager().beginTransaction()
                .replace(R.id.fragments_section, Filter_Discount.newInstance(productFilter, userFilter, filterUpdateListener))
                .commit();
    }

    private void showAttributeFilter(TM_ProductFilter productFilter, UserFilter userFilter, TM_FilterAttribute filterAttribute, TM_FilterAttribute userAttribute) {
        getChildFragmentManager().beginTransaction()
                .replace(R.id.fragments_section, Filter_Attribute.newInstance(productFilter, userFilter, filterAttribute, userAttribute, filterUpdateListener))
                .commit();
    }
}
