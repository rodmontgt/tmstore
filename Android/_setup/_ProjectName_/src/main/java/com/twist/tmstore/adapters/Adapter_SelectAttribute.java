package com.twist.tmstore.adapters;

import android.graphics.Paint;
import android.support.v4.app.FragmentManager;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageButton;
import android.widget.TextView;

import com.twist.dataengine.entities.RawAttribute;
import com.twist.dataengine.entities.RawShipping;
import com.twist.dataengine.entities.TM_Attribute;
import com.twist.tmstore.L;
import com.twist.tmstore.R;
import com.twist.tmstore.fragments.sellers.Fragment_SelectAttribute;
import com.twist.tmstore.fragments.sellers.Fragment_SelectAttributeTerms;
import com.twist.tmstore.fragments.sellers.Fragment_SelectShipping;
import com.utils.Helper;
import com.utils.HtmlCompat;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class Adapter_SelectAttribute<T> extends RecyclerView.Adapter<Adapter_SelectAttribute.AppViewHolder> {

    private static final int ITEM_EMPTY = -1;
    private static final int ITEM_DATA = 0;
    private static final int TYPE_HEADER = -2;
    private static final int TYPE_FOOTER = -3;
    private List<T> mValues;
    private List<View> mHeaders = new ArrayList<>();
    private List<View> mFooters = new ArrayList<>();
    private FragmentManager mFragmentManager = null;
    private String mClassType = "";

    public Adapter_SelectAttribute(String classType, List<T> items, FragmentManager fragmentManager) {
        mValues = items;
        mFragmentManager = fragmentManager;
        mClassType = classType;
    }

    public void addFooter(View view) {
        mFooters.add(view);
        notifyItemInserted(mHeaders.size() + mValues.size() + mFooters.size() - 1);
    }

    public void removeFooter() {
        mFooters.clear();
        notifyDataSetChanged();
    }

    public void hideFooters() {
        for (View view : mFooters) {
            view.setVisibility(View.GONE);
        }
    }

    public void showFooters() {
        for (View view : mFooters) {
            view.setVisibility(View.VISIBLE);
        }
    }

    public boolean remove(T item) {
        int index = mValues.indexOf(item);
        if (index >= 0) {
            if (mValues.remove(item)) {
                notifyItemRemoved(index + mHeaders.size());
                return true;
            }
        }
        return false;
    }

    @Override
    public AppViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View view;
        switch (viewType) {
            case TYPE_HEADER:
            case TYPE_FOOTER:
                view = LayoutInflater.from(parent.getContext()).inflate(android.R.layout.simple_list_item_1, parent, false);
                return new RecyclerHeaderViewHolder(view);
            case ITEM_DATA:
                view = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_picked_attribute, parent, false);
                return new DataViewHolder(view);
            case ITEM_EMPTY:
            default:
                view = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_empty, parent, false);
                ViewGroup.LayoutParams layoutParams = new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
                view.setLayoutParams(layoutParams);
                return new EmptyViewHolder(view);
        }
    }

    @Override
    public int getItemViewType(int position) {
        int firstDataIndex = mHeaders.size();
        int firstFooterIndex = mHeaders.size() + mValues.size();
        int totalItemCount = mHeaders.size() + mFooters.size() + mValues.size();

        if (position < firstDataIndex) {
            return TYPE_HEADER;
        } else if (position < firstFooterIndex) {
            return ITEM_DATA;
        } else if (position < totalItemCount) {
            return TYPE_FOOTER;
        } else {
            return ITEM_EMPTY;
        }
    }

    @Override
    public void onBindViewHolder(final AppViewHolder holder, int position) {
        if (mValues.isEmpty() || position < mHeaders.size() || (position >= mValues.size() + mHeaders.size()))
            holder.onBind(null);
        else
            holder.onBind(mValues.get(position - mHeaders.size()));
    }

    @Override
    public int getItemCount() {
        return mValues.size() + mHeaders.size() + mFooters.size();
    }

    public void addItems(List<T> data) {
        if (data != null) {
            int previousSize = mValues.size();
            mValues.addAll(data);
            int newSize = mValues.size();
            notifyItemRangeInserted(previousSize + mHeaders.size(), (newSize - previousSize));
        }
    }

    private void addItem(T item) {
        int indexToAdd = mValues.size();
        if (mValues.add(item)) {
            notifyItemInserted(indexToAdd + mHeaders.size());
        }
    }

    public List<T> getItems() {
        return new ArrayList<>(mValues);
    }

    private void showSelectAttributeDialog() {
        Fragment_SelectAttribute fragment = Fragment_SelectAttribute.newInstance(new Fragment_SelectAttribute.AttributeSelectionListener() {
            @Override
            public void onAttributeSelected(RawAttribute selected_attribute) {
                TM_Attribute attribute = new TM_Attribute(UUID.randomUUID().toString());
                attribute.name = selected_attribute.getName();
                attribute.slug = selected_attribute.getSlug();
                updateAttributeTerms(RawAttribute.getWithSlug(attribute.slug), attribute);
            }
        });
        fragment.show(mFragmentManager, Fragment_SelectAttributeTerms.class.getSimpleName());
    }

    private void showSelectShippingDialog() {
        final List<T> previousCheckedShipping = new ArrayList<>(mValues);
        final Fragment_SelectShipping fragment = Fragment_SelectShipping.newInstance((List<RawShipping>) mValues, new Fragment_SelectShipping.ShippingSelectionListener() {
            @Override
            public void onAttributeSelected(RawShipping selected_shipping) {
                addItem((T) selected_shipping);
            }

            @Override
            public void onAttributeRemoved(RawShipping selected_shipping) {
                remove((T) selected_shipping);
            }

            @Override
            public void onCancelButton() {
                mValues.clear();
                mValues.addAll(previousCheckedShipping);
                notifyDataSetChanged();
            }

        });
        fragment.show(mFragmentManager, Fragment_SelectAttributeTerms.class.getSimpleName());
    }

    private void updateAttributeTerms(RawAttribute referenceAttribute, final TM_Attribute attribute) {
        Fragment_SelectAttributeTerms fragment = Fragment_SelectAttributeTerms.newInstance(referenceAttribute, attribute, new Fragment_SelectAttributeTerms.TermSelectionListener() {
            @Override
            public void onAttributeTermSelected(List<String> options) {
//                if (!ListUtils.isEmpty(attribute.options)) {
//                    attribute.variation = false;
//                }
                //TODO always false, no variable products are being created for the time being.
                attribute.variation = false;
                for (TM_Attribute _attribute : (List<TM_Attribute>) mValues) {
                    if (_attribute.name.equalsIgnoreCase(attribute.name)) {
                        List<String> _options = new ArrayList<>();
                        for(String option : options) {
                            if(!_attribute.getOptions().contains(option)) {
                                _options.add(option);
                            }
                        }

                        if (!_options.isEmpty()) {
                            _attribute.getOptions().addAll(_options);
                        }
                        notifyDataSetChanged();
                        return;
                    }
                }
                addItem((T) attribute);
            }
        });
        fragment.show(mFragmentManager, Fragment_SelectAttributeTerms.class.getSimpleName());
    }

    abstract class AppViewHolder<T> extends RecyclerView.ViewHolder {

        AppViewHolder(View itemView) {
            super(itemView);
        }

        public abstract void onBind(T item);
    }

    private class RecyclerHeaderViewHolder extends AppViewHolder<Object> {

        final TextView textAddNew;

        RecyclerHeaderViewHolder(View view) {
            super(view);
            textAddNew = (TextView) view.findViewById(android.R.id.text1);
            textAddNew.setText(L.getString(L.string.add_new));
        }

        @Override
        public void onBind(final Object item) {
            textAddNew.setPaintFlags(textAddNew.getPaintFlags() | Paint.UNDERLINE_TEXT_FLAG);
            textAddNew.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    if (TM_Attribute.class.getSimpleName().equals(mClassType)) {
                        showSelectAttributeDialog();
                    } else if (RawShipping.class.getSimpleName().equals(mClassType)) {
                        showSelectShippingDialog();
                    }
                }
            });
        }
    }

    private class DataViewHolder extends AppViewHolder<T> {
        TextView attribute_name;
        TextView attribute_values;
        ImageButton btn_remove;
        View attribute_data_section;

        DataViewHolder(View view) {
            super(view);
            attribute_data_section = view.findViewById(R.id.attribute_data_section);
            attribute_name = (TextView) view.findViewById(R.id.attribute_name);
            attribute_values = (TextView) view.findViewById(R.id.attribute_values);
            btn_remove = (ImageButton) view.findViewById(R.id.btn_remove);
        }

        @Override
        public void onBind(final T data) {
            if (data != null) {
                if (data instanceof TM_Attribute) {
                    final TM_Attribute attribute = (TM_Attribute) data;
                    attribute_name.setText(HtmlCompat.fromHtml(attribute.name));
                    String valuesString = "";
                    for (String option : attribute.options) {
                        valuesString += option + ", ";
                    }
                    if (valuesString.length() > 2) {
                        valuesString = valuesString.substring(0, valuesString.length() - 2);
                    }
                    attribute_values.setText(HtmlCompat.fromHtml(valuesString));
                    attribute_data_section.setOnClickListener(new View.OnClickListener() {
                        @Override
                        public void onClick(View view) {
                            updateAttributeTerms(RawAttribute.getWithSlug(attribute.slug), attribute);
                        }
                    });
                } else if (data instanceof RawShipping) {
                    final RawShipping shipping = (RawShipping) data;
                    attribute_name.setText(HtmlCompat.fromHtml(shipping.label));
                    attribute_values.setText(HtmlCompat.fromHtml(Helper.appendCurrency(shipping.cost)));
                    attribute_values.setVisibility(View.GONE);
                }

                btn_remove.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        remove(data);
                    }
                });
            }
        }
    }

    private class EmptyViewHolder extends AppViewHolder {
        TextView empty;

        EmptyViewHolder(View view) {
            super(view);
            empty = (TextView) view.findViewById(R.id.empty);
        }

        @Override
        public void onBind(Object object) {
        }
    }
}
