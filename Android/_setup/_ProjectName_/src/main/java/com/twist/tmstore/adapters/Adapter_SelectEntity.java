package com.twist.tmstore.adapters;

import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.TextView;

import com.twist.dataengine.entities.RawShipping;
import com.twist.tmstore.R;
import com.utils.Helper;
import com.utils.HtmlCompat;

import java.util.List;

/**
 * Created by Twist Mobile on 1/25/2017.
 */

public class Adapter_SelectEntity<T> extends RecyclerView.Adapter<Adapter_SelectEntity.ViewHolder> {

    private List<T> list;
    private EntitySelectionListener mListener;
    private List<T> current_options;

    public Adapter_SelectEntity(List<T> list, EntitySelectionListener<T> mListener) {
        this.list = list;
        this.mListener = mListener;
    }

    public Adapter_SelectEntity(List<T> list, List<T> current_options, EntitySelectionListener<T> mListener) {
        this(list, mListener);
        this.current_options = current_options;
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View itemView = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_select_entity, parent, false);
        return new ViewHolder(itemView);
    }

    @Override
    public void onBindViewHolder(Adapter_SelectEntity.ViewHolder holder, int position) {
        holder.onBind(list.get(position));
    }


    @Override
    public int getItemCount() {
        return list.size();
    }

    public class ViewHolder extends RecyclerView.ViewHolder {
        TextView text_0, text_1;
        CheckBox chk;

        public ViewHolder(View v) {
            super(v);
            text_0 = (TextView) v.findViewById(R.id.text_0);
            text_1 = (TextView) v.findViewById(R.id.text_1);
            chk = (CheckBox) v.findViewById(R.id.chk);
            Helper.stylize(chk);
        }

        void onBind(Object entity) {
            if (entity instanceof RawShipping) {
                final RawShipping rawShipping = (RawShipping) entity;
                text_0.setText(HtmlCompat.fromHtml(rawShipping.getLabel()));
                text_1.setText(HtmlCompat.fromHtml(Helper.appendCurrency(0)));
                text_1.setVisibility(View.GONE);
                chk.setChecked(isOptionSelected(rawShipping));
                chk.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
                    @Override
                    public void onCheckedChanged(CompoundButton compoundButton, boolean b) {
                        if (mListener != null) {
                            mListener.onEntitySelected(rawShipping, b);
                        }
                    }
                });
            }
        }

    }

    private boolean isOptionSelected(Object item) {
        if (item instanceof RawShipping) {
            RawShipping rawShipping = (RawShipping) item;
            for (RawShipping shipping : (List<RawShipping>) current_options) {
                if (rawShipping.getId().equals(shipping.getId()))
                    return true;
            }
            return false;
        }
        return false;
    }

    public interface EntitySelectionListener<T> {
        void onEntitySelected(T options, boolean selected);
    }
}