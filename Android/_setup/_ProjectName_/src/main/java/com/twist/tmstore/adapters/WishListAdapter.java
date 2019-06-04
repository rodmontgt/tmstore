package com.twist.tmstore.adapters;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.graphics.Color;
import android.support.v7.widget.CardView;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.bumptech.glide.Glide;
import com.twist.dataengine.entities.TM_Bundle;
import com.twist.dataengine.entities.TM_ProductInfo;
import com.twist.tmstore.L;
import com.twist.tmstore.MainActivity;
import com.twist.tmstore.R;
import com.twist.tmstore.config.GuestUserConfig;
import com.twist.tmstore.config.ImageDownloaderConfig;
import com.twist.tmstore.entities.AppInfo;
import com.twist.tmstore.entities.Cart;
import com.twist.tmstore.entities.WishListGroup;
import com.twist.tmstore.entities.Wishlist;
import com.twist.tmstore.fragments.Fragment_Wish.OnListFragmentInteractionListener;
import com.utils.CContext;
import com.utils.Helper;
import com.utils.HtmlCompat;
import com.utils.ImageDownload;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import pl.tajchert.nammu.Nammu;
import pl.tajchert.nammu.PermissionCallback;

import static com.twist.tmstore.L.getString;

public class WishListAdapter extends RecyclerView.Adapter<WishListAdapter.WishListItemHolder> {

    private View cordView = null;
    private List<Wishlist> mItems;
    public HashMap<Integer, Boolean> mCheckedItem = new HashMap<>();
    private final OnListFragmentInteractionListener mListener;
    private Context context = null;
    public boolean checkMode = false;
    private View.OnClickListener onclickListener;
    public List<Wishlist> allChecked = new ArrayList<>();

    public WishListAdapter(List<Wishlist> items, OnListFragmentInteractionListener listener, View.OnClickListener click) {
        mItems = items;
        mListener = listener;
        onclickListener = click;
        mCheckedItem.clear();
        allChecked.clear();
    }

    @Override
    public WishListItemHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        context = parent.getContext();
        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_wishlist, parent, false);
        return new WishListItemHolder(view);
    }

    @Override
    public void onBindViewHolder(final WishListItemHolder holder, int position) {
        holder.onBind(position);
    }

    @Override
    public int getItemCount() {
        return mItems == null ? 0 : mItems.size();
    }

    private void removeAt(int position) {

        Wishlist.removeSafely(mItems.get(position));

        if (AppInfo.ENABLE_MULTIPLE_WISHLIST)
            mItems.remove(position); //Need to check

        notifyItemRemoved(position);
        notifyItemRangeChanged(position, mItems == null ? 0 : mItems.size());
    }

    public void removeAllChecked() {
        for (Wishlist wishlist : allChecked) {
            Wishlist.removeChecked(wishlist);
            if (AppInfo.ENABLE_MULTIPLE_WISHLIST)
                mItems.remove(wishlist); //Need to check
        }

        allChecked.clear();
        notifyItemRangeChanged(0, mItems == null ? 0 : mItems.size());
        notifyDataSetChanged();
    }

    public void resetCheckBox() {
        for (Wishlist wishlist : Wishlist.allWishlistItems) {
            wishlist.isChecked = false;
        }
        checkMode = true;
        mCheckedItem.clear();
        notifyDataSetChanged();
    }

    private void downloadAt(int position) {
        Wishlist wish = mItems.get(position);
        Toast.makeText(context, getString(L.string.download_initiated), Toast.LENGTH_SHORT).show();
        ImageDownload.downloadWishListGroupProductCatalog(context, wish.product, wish.parent_title);
    }

    @Override
    public void onAttachedToRecyclerView(RecyclerView recyclerView) {
        super.onAttachedToRecyclerView(recyclerView);
        cordView = recyclerView;
    }

    public void setItems(List<Wishlist> items) {
        mItems = items;
    }

    public class WishListItemHolder extends RecyclerView.ViewHolder {
        ImageView product_img;
        TextView name;
        TextView details;
        TextView price;
        EditText textfield_note_wishlist;
        ImageButton btn_remove;
        ImageButton btn_download;
        ImageButton btn_move_to_cart;
        CardView cv;
        CheckBox checkbox;

        LinearLayout out_of_stock_section;
        TextView text_out_of_stock;
        TextView text_saletag;
        TextView text_newtag;

        Button btn_add_note;
        Button btn_edit_note;
        Button btn_save_note;

        public WishListItemHolder(View view) {
            super(view);

            checkMode = AppInfo.ENABLE_SINGLE_CHECK_WISHLIST || checkMode;

            this.product_img = (ImageView) view.findViewById(R.id.product_img);
            this.name = (TextView) view.findViewById(R.id.name);
            this.details = (TextView) view.findViewById(R.id.details);
            this.price = (TextView) view.findViewById(R.id.txt_price);
            Helper.stylizeSalePriceText(price);
            this.btn_remove = (ImageButton) view.findViewById(R.id.btn_remove);
            this.btn_move_to_cart = (ImageButton) view.findViewById(R.id.btn_move_to_cart);

            this.btn_download = (ImageButton) view.findViewById(R.id.btn_download);
            this.textfield_note_wishlist = (EditText) view.findViewById(R.id.textfield_note_wishlist);
            this.textfield_note_wishlist.setVisibility(View.INVISIBLE);

            Helper.stylizeVector(btn_remove);
            Helper.stylizeVector(btn_move_to_cart);
            Helper.stylizeVector(btn_download);

            this.out_of_stock_section = (LinearLayout) itemView.findViewById(R.id.out_of_stock_section);
            this.text_out_of_stock = (TextView) itemView.findViewById(R.id.text_out_of_stock);
            this.text_saletag = (TextView) itemView.findViewById(R.id.text_saletag);
            this.text_newtag = (TextView) itemView.findViewById(R.id.text_newtag);

            this.out_of_stock_section.setBackground(CContext.getDrawable(context, R.drawable.border_layout_transperent));
            this.text_out_of_stock.setBackground(CContext.getDrawable(context, R.drawable.border_layout_white));
            this.text_out_of_stock.setText(getString(L.string.out_of_stock_tag));
            this.text_out_of_stock.setTextColor(Color.parseColor(AppInfo.color_actionbar_text));
            this.out_of_stock_section.setVisibility(View.GONE);

            Helper.stylizeActionText(this.text_saletag);
            this.text_saletag.setText(getString(L.string.sale_tag));
            this.text_saletag.setVisibility(View.GONE);

            Helper.stylizeActionText(this.text_newtag);
            this.text_newtag.setText(getString(L.string.new_tag));
            this.text_newtag.setVisibility(View.GONE);

            LinearLayout note_layout_wishlist = (LinearLayout) view.findViewById(R.id.note_layout_wishlist);
            if (AppInfo.ENABLE_WISHLIST_NOTE) {
                note_layout_wishlist.setVisibility(View.VISIBLE);
            } else {
                note_layout_wishlist.setVisibility(View.GONE);
            }

            if (AppInfo.ENABLE_SINGLE_CHECK_WISHLIST) {
                btn_remove.setVisibility(View.GONE);
            } else {
                btn_remove.setVisibility(View.VISIBLE);
            }

            this.btn_add_note = (Button) view.findViewById(R.id.btn_add_note);
            Helper.stylize(this.btn_add_note);
            this.btn_add_note.setText(L.getString(L.string.add_note));

            this.btn_edit_note = (Button) view.findViewById(R.id.btn_edit_note);
            Helper.stylize(this.btn_edit_note);
            this.btn_edit_note.setText(L.getString(L.string.edit_note));

            this.btn_save_note = (Button) view.findViewById(R.id.btn_save_note);
            Helper.stylize(this.btn_save_note);
            this.btn_save_note.setText(L.getString(L.string.ok));

            textfield_note_wishlist.setEnabled(false);
            btn_add_note.setVisibility(View.VISIBLE);
            btn_edit_note.setVisibility(View.INVISIBLE);
            btn_save_note.setVisibility(View.INVISIBLE);

            this.checkbox = (CheckBox) view.findViewById(R.id.checkbox_wishlist);
            this.checkbox.setVisibility(View.INVISIBLE);
            this.checkbox.setChecked(false);
            Helper.stylize(checkbox);

            this.cv = (CardView) view.findViewById(R.id.cv);
            this.cv.setLongClickable(true);

            this.btn_add_note.setText(L.getString(L.string.add_note));
            this.btn_edit_note.setText(L.getString(L.string.edit_note));
            this.btn_save_note.setText(L.getString(L.string.ok));

            this.btn_add_note.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    textfield_note_wishlist.setVisibility(View.VISIBLE);
                    textfield_note_wishlist.setEnabled(true);
                    btn_add_note.setVisibility(View.INVISIBLE);
                    btn_edit_note.setVisibility(View.INVISIBLE);
                    btn_save_note.setVisibility(View.VISIBLE);
                }
            });

            this.btn_edit_note.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    textfield_note_wishlist.setVisibility(View.VISIBLE);
                    textfield_note_wishlist.setEnabled(true);
                    btn_add_note.setVisibility(View.INVISIBLE);
                    btn_edit_note.setVisibility(View.INVISIBLE);
                    btn_save_note.setVisibility(View.VISIBLE);
                }
            });
        }

        public void onBind(final int position) {
            this.cv.setOnLongClickListener(new View.OnLongClickListener() {
                @Override
                public boolean onLongClick(View view) {
                    return true;
                }
            });
            this.btn_remove.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    String title = mItems.get(position).parent_title;
                    removeAt(position);
                    Helper.toast(cordView, Helper.showItemRemovedToWishListToast(title));
                }
            });

            if (ImageDownloaderConfig.isEnabled() && AppInfo.mImageDownloaderConfig.isShowInWishList()) {
                this.btn_download.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        if (!Nammu.checkPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE)) {
                            Nammu.askForPermission((Activity) context, Manifest.permission.WRITE_EXTERNAL_STORAGE, new PermissionCallback() {
                                @Override
                                public void permissionGranted() {
                                    downloadAt(position);
                                }

                                @Override
                                public void permissionRefused() {
                                }
                            });
                        } else {
                            downloadAt(position);
                        }
                    }
                });
            } else {
                this.checkbox.setVisibility(View.INVISIBLE);
                this.btn_download.setVisibility(View.GONE);
                this.cv.setLongClickable(false);
            }

            final Wishlist wish = mItems.get(position);
            this.cv.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (null != mListener) {
                        mListener.onListFragmentInteraction(wish);
                    }
                }
            });

            if (AppInfo.ENABLE_CART && GuestUserConfig.isEnableCart()) {
                this.btn_move_to_cart.setOnClickListener(new OnItemCartListener(position));
                this.btn_move_to_cart.setVisibility(View.VISIBLE);
            } else {
                this.btn_move_to_cart.setVisibility(View.GONE);
            }

            if (AppInfo.SHOW_PRODUCTS_BOOKING_INFO && wish.product != null && wish.product.type == TM_ProductInfo.ProductType.BOOKING && wish.product.bookingInfo == null/*|| Cart.containsBookingProduct()*/) {
                this.btn_move_to_cart.setVisibility(View.GONE);
            }

            if (wish.product == null) {
                this.name.setText(getString(L.string.outdated_product));
                this.details.setVisibility(View.VISIBLE);
                this.details.setText(getString(L.string.remove_from_cart));

                this.textfield_note_wishlist.setText(wish.note);
                this.checkbox.setOnCheckedChangeListener(null);
                this.checkbox.setChecked(wish.isChecked);
                this.checkbox.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
                    @Override
                    public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                        wish.isChecked = isChecked;
                        if (isChecked)
                            allChecked.add(wish);
                        else
                            allChecked.remove(wish);
                        onclickListener.onClick(buttonView);
                    }
                });

                if (checkMode) {
                    this.checkbox.setVisibility(View.VISIBLE);
                    this.btn_download.setVisibility(View.GONE);
                } else {
                    this.checkbox.setVisibility(View.INVISIBLE);
                }
                Glide.with(this.product_img.getContext()).load(R.drawable.error_product).into(this.product_img);
            } else {
                this.name.setText(HtmlCompat.fromHtml(wish.title));
                this.details.setText(HtmlCompat.fromHtml(wish.short_description));
                this.textfield_note_wishlist.setText(wish.note);
                if (AppInfo.SHOW_MIN_MAX_PRICE && wish.hasPriceRange()) {
                    this.price.setText(HtmlCompat.fromHtml(Helper.appendCurrency(wish.price_min) + " - " + Helper.appendCurrency(wish.price_max)));
                } else {
                    this.price.setText(HtmlCompat.fromHtml(Helper.appendCurrency(wish.price, wish.product)));
                }
                this.checkbox.setOnCheckedChangeListener(null);
                this.checkbox.setChecked(wish.isChecked);
                this.checkbox.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
                    @Override
                    public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                        wish.isChecked = isChecked;
                        if (isChecked)
                            allChecked.add(wish);
                        else
                            allChecked.remove(wish);
                        mCheckedItem.put(wish.product_id, wish.isChecked);
                        onclickListener.onClick(buttonView);
                    }
                });

                if (wish.note != null) {
                    this.textfield_note_wishlist.setVisibility(View.VISIBLE);
                    this.textfield_note_wishlist.setEnabled(false);
                    this.btn_add_note.setVisibility(View.INVISIBLE);
                    this.btn_edit_note.setVisibility(View.VISIBLE);
                    this.btn_save_note.setVisibility(View.INVISIBLE);
                } else {
                    this.textfield_note_wishlist.setVisibility(View.INVISIBLE);
                    this.textfield_note_wishlist.setEnabled(false);
                    this.btn_add_note.setVisibility(View.VISIBLE);
                    this.btn_edit_note.setVisibility(View.INVISIBLE);
                    this.btn_save_note.setVisibility(View.INVISIBLE);
                }

                if (checkMode) {
                    this.checkbox.setVisibility(View.VISIBLE);
                    this.btn_download.setVisibility(View.GONE);

                } else {
                    this.checkbox.setVisibility(View.INVISIBLE);
                }

                if (wish.img_url.length() > 0) {
                    Glide.with(this.product_img.getContext())
                            .load(wish.img_url)
                            .placeholder(Helper.getPlaceholderColor())
                            .error(R.drawable.error_product)
                            .into(this.product_img);
                } else {
                    Glide.with(this.product_img.getContext())
                            .load(R.drawable.error_product)
                            .into(this.product_img);
                }
            }

            if (AppInfo.HIDE_PRODUCT_PRICE_TAG || GuestUserConfig.hidePriceTag()) {
                this.price.setVisibility(View.GONE);
            }

            this.btn_save_note.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    textfield_note_wishlist.setVisibility(View.VISIBLE);
                    textfield_note_wishlist.setEnabled(false);
                    btn_add_note.setVisibility(View.INVISIBLE);
                    btn_edit_note.setVisibility(View.VISIBLE);
                    btn_save_note.setVisibility(View.INVISIBLE);

                    wish.note = textfield_note_wishlist.getText().toString();
                    wish.save();
                }
            });

            TM_ProductInfo product = mItems.get(position).product;
            if (product == null) {
                // TODO: 05-Jan-17 This condition might be true when we change configuration platform and select another one.
                this.out_of_stock_section.setVisibility(View.VISIBLE);
                this.text_saletag.setVisibility(View.GONE);
                this.text_newtag.setVisibility(View.GONE);
            } else {
                float realSellingPrice = wish.getItemPrice();
                if (realSellingPrice > 0) {
                    if (AppInfo.SHOW_SALE_PRODUCT_TAG && wish.product.regular_price > realSellingPrice) {
                        this.text_saletag.setVisibility(View.VISIBLE);
                    } else {
                        this.text_saletag.setVisibility(View.GONE);
                    }
                } else {
                    this.text_saletag.setVisibility(View.GONE);
                }

                if (AppInfo.SHOW_NEW_PRODUCT_TAG && Helper.getDaysDifference(product.created_at) < AppInfo.NEW_PRODUCT_DAYS_LIMIT) {
                    text_saletag.setVisibility(View.GONE);
                    text_newtag.setVisibility(View.VISIBLE);
                } else {
                    text_newtag.setVisibility(View.GONE);
                }

                if (AppInfo.SHOW_OUTOFSTOCK_PRODUCT_TAG && !product.in_stock) {
                    this.out_of_stock_section.setVisibility(View.VISIBLE);
                    this.text_saletag.setVisibility(View.GONE);
                    this.text_newtag.setVisibility(View.GONE);
                } else {
                    this.out_of_stock_section.setVisibility(View.GONE);
                }
            }
        }
    }

    public void setCheckMode(boolean checkMode) {
        this.checkMode = checkMode;
    }

    public void downloadAllSelected(WishListGroup wishListGroup) {
        boolean isStarted = false;
        for (Map.Entry<Integer, Boolean> entry : mCheckedItem.entrySet()) {
            TM_ProductInfo product = TM_ProductInfo.getProductWithId(entry.getKey());
            if (product != null && entry.getValue()) {
                isStarted = true;
                String title = wishListGroup != null ? wishListGroup.title : "";
                ImageDownload.downloadWishListGroupProductCatalog(context, product, title);
            }
        }
        Toast.makeText(context, isStarted ? getString(L.string.download_initiated) : getString(L.string.no_products), Toast.LENGTH_SHORT).show();
    }

    private class OnItemCartListener implements View.OnClickListener {
        private int mPosition;

        OnItemCartListener(int position) {
            mPosition = position;
        }

        @Override
        public void onClick(View view) {
            if (mPosition < mItems.size()) {
                TM_ProductInfo product = mItems.get(mPosition).product;
                if (product != null) {
                    if (!product.full_data_loaded || product.variations.size() > 0) {
                        MainActivity.mActivity.openProductInfo(product);
                    } else {
                        String note = mItems.get(mPosition).note;
                        if (addProductToCart(product, note)) {
                            if (!AppInfo.ENABLE_MULTIPLE_WISHLIST && AppInfo.REMOVE_CART_OR_WISH_ITEMS) {
                                removeAt(mPosition);
                            }
                            MainActivity.mActivity.restoreActionBar();
                            Helper.toast(cordView, L.string.item_added_to_cart);
                        } else {
                            Helper.toast(cordView, L.string.product_out_of_stock);
                        }
                    }
                }
            }
        }
    }

    private boolean addProductToCart(TM_ProductInfo product, String note) {
        if (product.managing_stock) {
            if (!product.backorders_allowed && !product.in_stock) {
                Helper.toast(cordView, L.string.product_out_of_stock);
                return false;
            }
        } else if (!product.in_stock) {
            Helper.toast(cordView, L.string.product_out_of_stock);
            return false;
        }

        if (AppInfo.ENABLE_BUNDLED_PRODUCTS) {
            if (product.type == TM_ProductInfo.ProductType.BUNDLE || product.type == TM_ProductInfo.ProductType.BUNDLE_YITH) {
                for (TM_Bundle tm_bundle : product.mBundles) {
                    TM_ProductInfo tmProduct = tm_bundle.getProduct();
                    if (tmProduct.managing_stock) {
                        if (!tmProduct.in_stock) {
                            Helper.toast(cordView, L.string.bundle_product_out_of_stock);
                            return false;
                        }
                    } else if (!tmProduct.in_stock) {
                        //if (!product.in_stock && !product.back_order_allowed) {
                        Helper.toast(cordView, L.string.bundle_product_out_of_stock);
                        return false;
                    }
                }
            }
        }

        if (!AppInfo.ENABLE_ZERO_PRICE_ORDER) {
            if (product.getActualPrice() <= 0) {
                Helper.toast(cordView, L.string.product_not_for_sale);
                return false;
            }
        }
        if (Cart.addProduct(product)) {
            Cart cart = Cart.findCart(product.id);
            if (cart != null && Helper.isValidString(note)) {
                cart.note = note;
                try {
                    cart.save();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
            return true;
        }
        return false;
    }
}