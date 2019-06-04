package com.twist.tmstore.adapters;

import android.support.v7.widget.PopupMenu;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.RadioButton;
import android.widget.TextView;

import com.twist.tmstore.Constants;
import com.twist.tmstore.MainActivity;
import com.twist.tmstore.R;
import com.twist.tmstore.entities.WishListGroup;
import com.twist.tmstore.fragments.Fragment_Wishlist_Dialog;
import com.utils.Helper;

import java.util.List;

public class Adapter_WishGroup extends RecyclerView.Adapter<Adapter_WishGroup.ViewHolder> {
    public boolean isCheckBoxMode;
    private List<WishListGroup> data;
    private boolean isBind = false;
    private Fragment_Wishlist_Dialog.OnWishGroupSelectListener listener;
    private Fragment_Wishlist_Dialog.OnCheckBoxClickListener checkBoxListener;

    private View.OnClickListener clickListener;

    public Adapter_WishGroup(List<WishListGroup> _data, boolean _isCheckBoxMode, Fragment_Wishlist_Dialog.OnWishGroupSelectListener _listener, Fragment_Wishlist_Dialog.OnCheckBoxClickListener _checkBoxListener, View.OnClickListener _clickListener) {
        data = _data;
        listener = _listener;
        isCheckBoxMode = _isCheckBoxMode;
        checkBoxListener = _checkBoxListener;
        clickListener = _clickListener;
    }

    @Override
    public Adapter_WishGroup.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        return new ViewHolder(LayoutInflater.from(parent.getContext()).inflate(R.layout.item_wishlistgroup, parent, false));
    }

    @Override
    public void onBindViewHolder(final ViewHolder holder, int position) {
        isBind = true;
        final WishListGroup obj = data.get(position);
        holder.radio_wishgroup.setChecked(false);
        if (obj.id == WishListGroup.getdefaultWishGroupID(data)) {
            holder.radio_wishgroup.setChecked(true);
        }
        holder.txtHeader.setText(obj.title);
        holder.txtHeader.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                if (!isCheckBoxMode)
                    listener.onGroupClick(view, obj, false);
                else {
                    holder.checkBox_wishgroup.setChecked(true);
                }
            }
        });

        holder.wishgroup_section_list.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                if (!isCheckBoxMode)
                    listener.onGroupClick(view, obj, false);
                else {
                    holder.checkBox_wishgroup.setChecked(true);
                }
            }
        });

        holder.btn_menu.setVisibility(View.VISIBLE);
        holder.btn_menu.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                PopupMenu popup = new PopupMenu(view.getContext(), view);
                MainActivity.mActivity.setupWishGroupMenu(popup.getMenu());
                popup.setOnMenuItemClickListener(new PopupMenu.OnMenuItemClickListener() {
                    @Override
                    public boolean onMenuItemClick(MenuItem item) {
                        int id = item.getItemId();
                        if (id == Constants.ID_WISH_MENU_RENAME) {
                            holder.editBox.setText(obj.title);
                            holder.txtHeader.setVisibility(View.GONE);
                            holder.editBox.setVisibility(View.VISIBLE);
                            holder.btn_renameOk.setVisibility(View.VISIBLE);
                            holder.btn_menu.setVisibility(View.GONE);
                            return false;
                        }
                        listener.onGroupItemClick(obj, id);
                        return false;
                    }
                });
                popup.getMenuInflater().inflate(R.menu.menu_empty, popup.getMenu());
                popup.show();

            }
        });

        holder.btn_renameOk.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                holder.txtHeader.setVisibility(View.VISIBLE);
                holder.editBox.setVisibility(View.GONE);
                holder.btn_renameOk.setVisibility(View.GONE);
                holder.btn_menu.setVisibility(View.VISIBLE);
                obj.title = holder.editBox.getText().toString();
                listener.onGroupItemClick(obj, Constants.ID_WISH_MENU_RENAME);
            }
        });

        holder.radio_wishgroup.setVisibility(View.VISIBLE);
        holder.radio_wishgroup.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                try {
                    WishListGroup obj = data.get(holder.getLayoutPosition());
                    WishListGroup.setdefaultWishGroupID(obj.id);
                    checkBoxListener.onClick(obj);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        });

        holder.checkBox_wishgroup.setVisibility(View.GONE);

        if (isCheckBoxMode) {
            holder.checkBox_wishgroup.setVisibility(View.VISIBLE);
            holder.radio_wishgroup.setVisibility(View.GONE);
            holder.btn_menu.setVisibility(View.GONE);
        }
        isBind = false;
    }

    @Override
    public int getItemCount() {
        return data.size();
    }

    public class ViewHolder extends RecyclerView.ViewHolder {
        TextView txtHeader;
        EditText editBox;
        LinearLayout wishgroup_section_list;
        CheckBox checkBox_wishgroup;
        ImageButton btn_menu;
        Button btn_renameOk;
        RadioButton radio_wishgroup;

        public ViewHolder(View v) {
            super(v);

            wishgroup_section_list = (LinearLayout) v.findViewById(R.id.wishgroup_section_list);
            txtHeader = (TextView) v.findViewById(R.id.textView_wishgroup);
            editBox = (EditText) v.findViewById(R.id.edittext_wishgroup);
            editBox.setVisibility(View.GONE);

            checkBox_wishgroup = (CheckBox) v.findViewById(R.id.checkBox_wishgroup);
            Helper.stylize(checkBox_wishgroup);
            checkBox_wishgroup.setVisibility(View.GONE);

            checkBox_wishgroup.setOnCheckedChangeListener(null);
            checkBox_wishgroup.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
                @Override
                public void onCheckedChanged(CompoundButton compoundButton, boolean b) {
                    try {
                        WishListGroup obj = data.get(getLayoutPosition());
                        obj.isChecked = b;
                        clickListener.onClick(null);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            });

            btn_renameOk = (Button) v.findViewById(R.id.btn_renameOk);
            Helper.stylize(btn_renameOk);
            btn_renameOk.setVisibility(View.GONE);

            btn_menu = (ImageButton) v.findViewById(R.id.btn_menu);

            radio_wishgroup = (RadioButton) v.findViewById(R.id.radio_wishgroup);
            Helper.stylize(radio_wishgroup);

            radio_wishgroup.setOnCheckedChangeListener(null);
            radio_wishgroup.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
                @Override
                public void onCheckedChanged(CompoundButton compoundButton, boolean b) {
                    if (compoundButton.isChecked()) {
                        try {
                            WishListGroup obj = data.get(getLayoutPosition());
                            WishListGroup.setdefaultWishGroupID(obj.id);
                            if (!isBind)
                                notifyDataSetChanged();
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                }
            });
        }
    }
}