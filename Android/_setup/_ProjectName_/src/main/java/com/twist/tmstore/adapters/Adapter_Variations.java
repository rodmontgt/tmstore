package com.twist.tmstore.adapters;

import android.content.Context;
import android.content.DialogInterface;
import android.support.annotation.NonNull;
import android.support.v7.app.AlertDialog;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.TextView;

import com.twist.dataengine.entities.TM_Attribute;
import com.twist.tmstore.L;
import com.twist.tmstore.R;
import com.twist.tmstore.entities.AppInfo;
import com.twist.tmstore.listeners.OnAttributeOptionClickListener;
import com.utils.CContext;
import com.utils.HtmlCompat;

import java.util.List;

public class Adapter_Variations extends RecyclerView.Adapter<Adapter_Variations.ViewHolder> {

    private List data;
    private OnAttributeOptionClickListener mOnAttributeOptionClickListener;

    public class ViewHolder extends RecyclerView.ViewHolder {
        TextView title;
        TextView selected_attribute;
        AlertDialog alertDialog;

        private List<String> attributeOptions;

        private int mPosition;

        private int mCheckedItem;

        public ViewHolder(View view) {
            super(view);
            title = (TextView) view.findViewById(R.id.text_title);
            selected_attribute = (TextView) view.findViewById(R.id.text_selected_attribute);
            selected_attribute.setText(L.getString(L.string.select_attribute));
            view.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    AlertDialog.Builder builder = new AlertDialog.Builder(itemView.getContext());
                    builder = builder.setTitle(title.getText());
                    builder = builder.setSingleChoiceItems(
                            new AttributeOptionsAdapter(itemView.getContext(), attributeOptions, android.R.layout.simple_list_item_1, android.R.id.text1),
                            mCheckedItem,
                            new OnAttributeSelectListener(mPosition));
                    alertDialog = builder.create();
                    alertDialog.show();
                }
            });
        }

        void bindView(final int position) {
            this.mPosition = position;
            if (position != data.size() - 1) {
                itemView.setBackground(CContext.getDrawable(itemView.getContext(), R.drawable.bottom_border_layout_white));
            }

            TM_Attribute attribute = (TM_Attribute) data.get(mPosition);
            title.setText(HtmlCompat.fromHtml(attribute.name));

            attributeOptions = attribute.getOptions();

            mCheckedItem = -1;
            if (AppInfo.AUTO_SELECT_VARIATION && !attribute.options.isEmpty()) {
                mCheckedItem = 0;
                selected_attribute.setText(HtmlCompat.fromHtml(attributeOptions.get(mCheckedItem)));
                if (mOnAttributeOptionClickListener != null) {
                    mOnAttributeOptionClickListener.onClick(mPosition, mCheckedItem);
                }
            }
        }

        class OnAttributeSelectListener implements DialogInterface.OnClickListener {
            private int position = -1;

            OnAttributeSelectListener(int position) {
                this.position = position;
            }

            @Override
            public void onClick(DialogInterface dialog, int which) {
                selected_attribute.setText(HtmlCompat.fromHtml(attributeOptions.get(which)));
                if (mOnAttributeOptionClickListener != null) {
                    mOnAttributeOptionClickListener.onClick(position, which);
                }
                dialog.dismiss();
            }
        }
    }

    public Adapter_Variations(List data) {
        this.data = data;
    }

    public void setOptionSelectionListener(OnAttributeOptionClickListener onAttributeOptionClickListener) {
        this.mOnAttributeOptionClickListener = onAttributeOptionClickListener;
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        return new ViewHolder(LayoutInflater.from(parent.getContext()).inflate(R.layout.item_variation, parent, false));
    }

    @Override
    public void onBindViewHolder(ViewHolder holder, int position) {
        holder.bindView(position);
    }

    @Override
    public int getItemCount() {
        return data.size();
    }

    private static class AttributeOptionsAdapter extends ArrayAdapter<String> {
        private final int layoutResId;
        private final int textResId;

        static class ViewHolder {
            public TextView textView;
        }

        AttributeOptionsAdapter(Context context, List<String> data, int layoutResId, int textResId) {
            super(context, layoutResId, textResId, data);
            this.layoutResId = layoutResId;
            this.textResId = textResId;
        }

        @Override
        public long getItemId(int position) {
            return position;
        }

        @NonNull
        @Override
        public View getView(int position, View convertView, @NonNull ViewGroup parent) {
            ViewHolder holder;
            View view = convertView;
            if (view == null) {
                view = LayoutInflater.from(parent.getContext()).inflate(layoutResId, parent, false);
                holder = new ViewHolder();
                holder.textView = (TextView) view.findViewById(textResId);
                view.setTag(holder);
            } else {
                holder = (ViewHolder) view.getTag();
            }
            holder.textView.setText(HtmlCompat.fromHtml(getItem(position)));
            return view;
        }
    }
}