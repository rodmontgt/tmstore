package com.twist.tmstore.adapters;

import android.content.Context;
import android.support.v4.app.FragmentActivity;
import android.support.v7.widget.CardView;
import android.support.v7.widget.RecyclerView;
import android.text.InputType;
import android.text.TextUtils;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.view.inputmethod.EditorInfo;
import android.widget.Button;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.bumptech.glide.Glide;
import com.twist.dataengine.DataQueryHandler;
import com.twist.dataengine.entities.TM_ProductInfo;
import com.twist.tmstore.L;
import com.twist.tmstore.MainActivity;
import com.twist.tmstore.R;
import com.twist.tmstore.config.GuestUserConfig;
import com.twist.tmstore.config.ImageDownloaderConfig;
import com.twist.tmstore.entities.AppInfo;
import com.twist.tmstore.entities.Cart;
import com.twist.tmstore.entities.CartBundleItem;
import com.twist.tmstore.entities.CartMatchedItem;
import com.twist.tmstore.entities.WishListGroup;
import com.twist.tmstore.entities.Wishlist;
import com.twist.tmstore.fragments.Fragment_UpdateCartQuantityDialog;
import com.twist.tmstore.fragments.Fragment_Wishlist_Dialog;
import com.twist.tmstore.listeners.ModificationListener;
import com.twist.tmstore.listeners.QuantityListener;
import com.twist.tmstore.listeners.WishListDialogHandler;
import com.utils.Helper;
import com.utils.HtmlCompat;
import com.utils.ImageDownload;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Locale;

import static android.view.ViewGroup.LayoutParams;
import static com.twist.tmstore.L.getString;

public class CartAdapter extends RecyclerView.Adapter<CartAdapter.BaseViewHolder> {

    private static final int TYPE_HEADER = 1;
    private static final int TYPE_FOOTER = 2;
    private static final int TYPE_ITEM = 3;

    private List<View> headers = new ArrayList<>();
    private List<View> footers = new ArrayList<>();

    private Context context;
    private List data;
    private ModificationListener mModificationListener = null;

    abstract class BaseViewHolder extends RecyclerView.ViewHolder {
        BaseViewHolder(View itemView) {
            super(itemView);
        }

        abstract void onBind(Object object);
    }

    private class HeaderFooterViewHolder extends CartAdapter.BaseViewHolder {
        FrameLayout base;

        HeaderFooterViewHolder(View itemView) {
            super(itemView);
            this.base = (FrameLayout) itemView;
        }

        @Override
        void onBind(Object object) {
            View view = (View) object;
            //TODO Don't add view before removing it from parent as well
            base.removeAllViews();
            if (view.getParent() != null) {
                ((ViewGroup) view.getParent()).removeView(view);
            }
            base.addView(view);
        }
    }

    private class SimpleItemViewHolder extends BaseViewHolder {
        ImageView product_img;
        TextView name;
        TextView details;
        EditText quantity;
        TextView qty;
        TextView total;
        ImageButton btn_remove;
        ImageButton btn_wishlist;
        View button_panel;
        CardView cardView;
        View btn_separator2;

        TextView deliveryDate;
        TextView deliveryTime;

        ImageButton btn_download;

        EditText edittext_note_cart;
        Button btn_add_note;
        Button btn_edit_note;
        Button btn_save_note;

        TextView txtBookingDate;

        SimpleItemViewHolder(final View view) {
            super(view);
            this.cardView = (CardView) view.findViewById(R.id.cv);
            this.product_img = (ImageView) view.findViewById(R.id.product_img);
            this.name = (TextView) view.findViewById(R.id.name);
            this.details = (TextView) view.findViewById(R.id.details);
            this.quantity = (EditText) view.findViewById(R.id.quantity);
            this.qty = (TextView) view.findViewById(R.id.txt_qty);
            this.total = (TextView) view.findViewById(R.id.total);
            this.btn_remove = (ImageButton) view.findViewById(R.id.btn_remove);
            this.btn_wishlist = (ImageButton) view.findViewById(R.id.btn_wishlist);
            this.button_panel = view.findViewById(R.id.button_panel);
            this.btn_download = (ImageButton) view.findViewById(R.id.btn_download);
            this.btn_separator2 = view.findViewById(R.id.btn_panel_separator_2);
            this.deliveryDate = (TextView) view.findViewById(R.id.text_delivery_date);
            this.deliveryTime = (TextView) view.findViewById(R.id.text_delivery_time);
            this.qty = (TextView) view.findViewById(R.id.txt_qty);

            this.txtBookingDate = (TextView) view.findViewById(R.id.text_booking_date);
            this.txtBookingDate.setVisibility(View.GONE);

            Helper.stylizeVector(btn_remove);
            Helper.stylizeVector(btn_wishlist);

            this.quantity.setFocusable(false);
            this.quantity.setFocusableInTouchMode(false);

            if (btn_download != null) {
                Helper.stylizeVector(btn_download);
            }

            LinearLayout note_layout_wishlist = (LinearLayout) view.findViewById(R.id.note_layout_cart);

            this.btn_add_note = (Button) view.findViewById(R.id.btn_add_note);
            Helper.stylize(this.btn_add_note);
            this.btn_add_note.setText(L.getString(L.string.add_note));


            this.btn_edit_note = (Button) view.findViewById(R.id.btn_edit_note);
            Helper.stylize(this.btn_edit_note);
            this.btn_edit_note.setText(L.getString(L.string.edit_note));


            this.btn_save_note = (Button) view.findViewById(R.id.btn_save_note);
            Helper.stylize(this.btn_save_note);
            this.btn_save_note.setText(L.getString(L.string.ok));

            this.edittext_note_cart = (EditText) view.findViewById(R.id.edittext_note_cart);
            this.edittext_note_cart.setVisibility(View.VISIBLE);
            this.edittext_note_cart.setHint(getString(L.string.cart_note_placeholder));

            this.qty.setText(getString(L.string.qty));
            //btn_add_note.setPaintFlags(Paint.UNDERLINE_TEXT_FLAG);
            btn_edit_note.setText(L.getString(L.string.edit_note));
            //btn_edit_note.setPaintFlags(Paint.UNDERLINE_TEXT_FLAG);
            //btn_save_note.setPaintFlags(Paint.UNDERLINE_TEXT_FLAG);
            btn_save_note.setText(L.getString(L.string.ok));


            if (!AppInfo.ENABLE_WISHLIST) {
                this.btn_wishlist.setVisibility(View.GONE);
                if (AppInfo.ID_LAYOUT_CART == 0) {
                    LinearLayout.LayoutParams lp = (LinearLayout.LayoutParams) this.btn_remove.getLayoutParams();
                    lp.width = LinearLayout.LayoutParams.MATCH_PARENT;
                    lp.weight = 1.0f;
                }
            }

            edittext_note_cart.setEnabled(false);
            btn_add_note.setVisibility(View.VISIBLE);
            btn_edit_note.setVisibility(View.INVISIBLE);
            btn_save_note.setVisibility(View.INVISIBLE);

            if (AppInfo.HIDE_PRODUCT_PRICE_TAG || GuestUserConfig.hidePriceTag()) {
                this.qty.setVisibility(View.GONE);
                this.total.setVisibility(View.GONE);
            }

            if (AppInfo.mCartNoteConfig != null && AppInfo.mCartNoteConfig.isEnabled()) {
                edittext_note_cart.setMaxLines(AppInfo.mCartNoteConfig.getLineCount());
                edittext_note_cart.setSingleLine(AppInfo.mCartNoteConfig.isSingleLine());
                if (Helper.isValidString(AppInfo.mCartNoteConfig.getCharType())) {
                    switch (AppInfo.mCartNoteConfig.getCharType()) {
                        case "numeric":
                            edittext_note_cart.setInputType(InputType.TYPE_CLASS_NUMBER | InputType.TYPE_NUMBER_FLAG_DECIMAL);
                            break;
                        case "alphanumeric":
                            edittext_note_cart.setInputType(InputType.TYPE_TEXT_VARIATION_PERSON_NAME);
                            break;
                        default:
                            edittext_note_cart.setInputType(InputType.TYPE_NULL);
                            break;
                    }
                }
                note_layout_wishlist.setVisibility(View.VISIBLE);
            } else {
                note_layout_wishlist.setVisibility(View.GONE);
            }

            if (ImageDownloaderConfig.isEnabled() && AppInfo.mImageDownloaderConfig.isShowInCart() && btn_download != null) {
                this.btn_download.setVisibility(View.VISIBLE);
                this.btn_separator2.setVisibility(View.VISIBLE);
            } else {
                if (btn_download != null) {
                    this.btn_download.setVisibility(View.GONE);
                }
                this.btn_separator2.setVisibility(View.GONE);
            }

            View extra_section = view.findViewById(R.id.extra_section);
            if (extra_section != null) {
                extra_section.setVisibility(View.GONE);
            }

            if (!AppInfo.ENABLE_PRODUCT_DELIVERY_DATE) {
                deliveryDate.setVisibility(View.GONE);
                deliveryTime.setVisibility(View.GONE);
            }
        }

        @Override
        void onBind(Object object) {
            final Cart cart = (Cart) object;
////            this.quantity.setSelection(this.quantity.getText().length());
////            this.quantity.removeTextChangedListener();
//            this.quantity.addTextChangedListener(new QuantityListener(this.quantity, new QuantityListener.OnChangeCallback() {
//                @Override
//                public void onChange(final int value) {
//                    quantity.setOnEditorActionListener(new TextView.OnEditorActionListener() {
//                        @Override
//                        public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
//                            if (actionId == EditorInfo.IME_ACTION_DONE) {
//                                updateCardQuantity(cart, value);
//                            }
//                            return false;
//                        }
//                    });
//                    quantity.requestFocus();
//                    quantity.requestFocusFromTouch();
//                }
//            }));
//


            this.qty.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View view) {
                    showUpdateCartDialog(cart);
                }
            });
            this.quantity.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View view) {
                    showUpdateCartDialog(cart);
                }
            });

            edittext_note_cart.setText(cart.note);
            this.name.setText(HtmlCompat.fromHtml(cart.title));
            this.quantity.setText(String.format(Locale.ENGLISH, "%d", cart.count));
            //holder.txt_price.setText(HtmlCompat.fromHtml(Helper.appendCurrency(cart.getItemPrice())));
            this.total.setText(HtmlCompat.fromHtml(Helper.appendCurrency(cart.getItemTotalPrice())));

            //TM_Variation selectedVariation = cart.product.variations.getVariation(cart.selected_variation_id);
            String selectedVariationStr = cart.getAttributeString();
            if (Helper.isValidString(selectedVariationStr)) {
                this.details.setVisibility(View.VISIBLE);
                this.details.setText(HtmlCompat.fromHtml(selectedVariationStr));
            } else {
                this.details.setVisibility(View.GONE);
            }

            Glide.with(context)
                    .load(cart.img_url)
                    .placeholder(AppInfo.ID_PLACEHOLDER_PRODUCT)
                    .error(R.drawable.error_product)
                    .into(this.product_img);

            if (Helper.isValidString(cart.note)) {
                edittext_note_cart.setVisibility(View.VISIBLE);
                edittext_note_cart.setEnabled(false);
                btn_add_note.setVisibility(View.INVISIBLE);
                btn_edit_note.setVisibility(View.VISIBLE);
                btn_save_note.setVisibility(View.INVISIBLE);

            } else {
                edittext_note_cart.setVisibility(View.VISIBLE);
                edittext_note_cart.setEnabled(false);
                btn_add_note.setVisibility(View.VISIBLE);
                btn_edit_note.setVisibility(View.INVISIBLE);
                btn_save_note.setVisibility(View.INVISIBLE);
            }
//

            this.cardView.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    MainActivity.mActivity.showProductInfoQuick(cart.product_id, cart.selected_variation_id, cart.selected_variation_index, false);
                }
            });

            this.btn_remove.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    Cart.moveCartToBin(cart);
                    removeItem(cart);
                }
            });

            if (AppInfo.ENABLE_WISHLIST) {
                this.btn_wishlist.setVisibility(View.VISIBLE);
                this.btn_wishlist.setOnClickListener(new OnClickListener() {
                    @Override
                    public void onClick(View v) {

                        Wishlist wish = Wishlist.findCart(cart.product.id);
                        if (wish != null) {
                            if (Helper.isValidString(cart.note)) {
                                wish.note = cart.note;
                                wish.save();
                            }

                            if (!AppInfo.ENABLE_MULTIPLE_WISHLIST) {
                                if (AppInfo.REMOVE_CART_OR_WISH_ITEMS) {
                                    Cart.removeSafely(cart);
                                    removeItem(cart);
                                }
                                return;
                            }
                        }

                        Fragment_Wishlist_Dialog.OpenWishGroupDialog(cart.product, new WishListDialogHandler() {
                            @Override
                            public void onSelectGroupSuccess(final TM_ProductInfo product, final WishListGroup obj) {
                                MainActivity.mActivity.showProgress(getString(L.string.please_wait), false);
                                WishListGroup.addProductToWishList(obj.id, product.id, new DataQueryHandler() {
                                    @Override
                                    public void onSuccess(Object data) {

                                        MainActivity.mActivity.hideProgress();
                                        if (Wishlist.addProduct(product, obj)) {
                                            if (!AppInfo.ENABLE_MULTIPLE_WISHLIST && AppInfo.REMOVE_CART_OR_WISH_ITEMS) {
                                                Cart.removeSafely(cart);
                                                removeItem(cart);
                                            }
                                            Helper.toast(L.string.item_moved_to_wishlist);
                                        }
                                    }

                                    @Override
                                    public void onFailure(Exception error) {
                                        Helper.toast(getString(L.string.generic_server_timeout));
                                    }
                                });
                            }

                            @Override
                            public void onSelectGroupFailed(String cause) {

                            }

                            @Override
                            public void onSkipDialog(TM_ProductInfo product, final WishListGroup obj) {
                                if (Wishlist.addProduct(product, obj)) {
                                    if (AppInfo.REMOVE_CART_OR_WISH_ITEMS) {
                                        Cart.removeSafely(cart);
                                        removeItem(cart);
                                    }
                                    Helper.toast(L.string.item_moved_to_wishlist);
                                }
                            }
                        });
                        MainActivity.mActivity.restoreActionBar();
                    }
                });
            }


            btn_add_note.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    edittext_note_cart.setVisibility(View.VISIBLE);
                    edittext_note_cart.setEnabled(true);
                    btn_add_note.setVisibility(View.INVISIBLE);
                    btn_edit_note.setVisibility(View.INVISIBLE);
                    btn_save_note.setVisibility(View.VISIBLE);
                }
            });

            btn_edit_note.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    edittext_note_cart.setVisibility(View.VISIBLE);
                    edittext_note_cart.setEnabled(true);
                    btn_add_note.setVisibility(View.INVISIBLE);
                    btn_edit_note.setVisibility(View.INVISIBLE);
                    btn_save_note.setVisibility(View.VISIBLE);
                }
            });

            btn_save_note.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    edittext_note_cart.setVisibility(View.VISIBLE);
                    edittext_note_cart.setEnabled(false);
                    btn_add_note.setVisibility(View.INVISIBLE);
                    btn_edit_note.setVisibility(View.VISIBLE);
                    btn_save_note.setVisibility(View.INVISIBLE);
                    cart.note = edittext_note_cart.getText().toString();
                    try {
                        cart.save();
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            });

            if (ImageDownloaderConfig.isEnabled() && AppInfo.mImageDownloaderConfig.isShowInCart() && btn_download != null) {
                this.btn_download.setOnClickListener(new OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        Toast.makeText(context, getString(L.string.download_initiated), Toast.LENGTH_SHORT).show();
                        ImageDownload.downloadProductCatalog(context, cart.product);
                    }
                });
            }

            if (AppInfo.ENABLE_PRODUCT_DELIVERY_DATE) {
                deliveryDate.setVisibility(View.VISIBLE);
                deliveryDate.setText(String.format(Locale.getDefault(), getString(L.string.label_date), cart.selectedDeliveryDate));

                deliveryTime.setVisibility(View.VISIBLE);
                deliveryTime.setText(String.format(Locale.getDefault(), getString(L.string.label_time), cart.selectedDeliveryTime));
            }

            if (AppInfo.SHOW_PRODUCTS_BOOKING_INFO && !TextUtils.isEmpty(cart.booking_date)) {
                try {
                    txtBookingDate.setVisibility(View.VISIBLE);
                    txtBookingDate.setText(String.format(Locale.getDefault(), getString(L.string.label_booking_date), getBookingDate(cart.booking_date)));
                } catch (Exception e) {
                    e.printStackTrace();
                    txtBookingDate.setVisibility(View.GONE);
                }
            }
        }
    }

    private class GroupedItemViewHolder extends BaseViewHolder {
        ImageView product_img;
        TextView name;
        TextView details;
        EditText quantity;
        TextView qty;
        TextView total;
        ImageButton btn_remove;
        ImageButton btn_wishlist;
        View button_panel;
        CardView card_view;
        RecyclerView childItemsView;
        TextView txtBookingDate;

        GroupedItemViewHolder(final View view) {
            super(view);
            card_view = (CardView) view.findViewById(R.id.card_view);
            product_img = (ImageView) view.findViewById(R.id.product_img);
            name = (TextView) view.findViewById(R.id.name);
            details = (TextView) view.findViewById(R.id.details);
            quantity = (EditText) view.findViewById(R.id.quantity);
            qty = (TextView) view.findViewById(R.id.txt_qty);
            total = (TextView) view.findViewById(R.id.total);
            btn_remove = (ImageButton) view.findViewById(R.id.btn_remove);
            btn_wishlist = (ImageButton) view.findViewById(R.id.btn_wishlist);
            button_panel = view.findViewById(R.id.button_panel);
            childItemsView = (RecyclerView) view.findViewById(R.id.child_items_recycler_view);
            childItemsView.setVisibility(View.GONE);
            this.txtBookingDate = (TextView) view.findViewById(R.id.text_booking_date);
            this.txtBookingDate.setVisibility(View.GONE);

            Helper.stylizeVector(btn_remove);
            Helper.stylizeVector(btn_wishlist);

            quantity.addTextChangedListener(new QuantityListener(this.quantity, new QuantityListener.OnChangeCallback() {
                @Override
                public void onChange(final int value) {

                    quantity.setOnEditorActionListener(new TextView.OnEditorActionListener() {
                        @Override
                        public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
                            if (actionId == EditorInfo.IME_ACTION_DONE) {
                                updateCardQuantity(getAdapterPosition(), value);
                            }
                            return false;
                        }
                    });
//                    updateCardQuantity(getAdapterPosition(), value);
                    quantity.requestFocus();
                    quantity.requestFocusFromTouch();
                }
            }));

            card_view.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    Cart cart = ((Cart) data.get(getAdapterPosition()));
                    MainActivity.mActivity.showProductInfoQuick(cart.product_id, cart.selected_variation_id, cart.selected_variation_index, false);
                }
            });

            btn_remove.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (getAdapterPosition() < data.size()) {
//                        Cart.moveCartToBin((Cart) data.get(getAdapterPosition()));
//                        notifyItemRemoved(headers.size() + getAdapterPosition());
//                        if (mModificationListener != null) {
//                            mModificationListener.onModificationDone();
//                        }
                        Cart.moveCartToBin((Cart) data.get(getAdapterPosition()));
                        removeItem((Cart) data.get(getAdapterPosition()));
                    }
                }
            });

            if (AppInfo.ENABLE_WISHLIST) {
                btn_wishlist.setVisibility(View.VISIBLE);
                btn_wishlist.setOnClickListener(new OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        final int position = getAdapterPosition();
                        if (position < data.size()) {
                            Cart cart = (Cart) data.get(position);
                            final TM_ProductInfo product = cart.product;
                            Cart.removeSafely(cart);
                            Fragment_Wishlist_Dialog.OpenWishGroupDialog(product, new WishListDialogHandler() {
                                @Override
                                public void onSelectGroupSuccess(final TM_ProductInfo product, final WishListGroup obj) {
                                    MainActivity.mActivity.showProgress(getString(L.string.please_wait), false);
                                    WishListGroup.addProductToWishList(obj.id, product.id, new DataQueryHandler() {
                                        @Override
                                        public void onSuccess(Object data) {

                                            MainActivity.mActivity.hideProgress();
                                            if (Wishlist.addProduct(product, obj)) {
                                                notifyItemRemoved(headers.size() + position);
                                                if (mModificationListener != null) {
                                                    mModificationListener.onModificationDone();
                                                }
                                                Helper.toast(L.string.item_moved_to_wishlist);
                                            }
                                        }

                                        @Override
                                        public void onFailure(Exception error) {
                                            Helper.toast(getString(L.string.generic_server_timeout));
                                        }
                                    });
                                }

                                @Override
                                public void onSelectGroupFailed(String cause) {

                                }

                                @Override
                                public void onSkipDialog(TM_ProductInfo product, final WishListGroup obj) {
                                    MainActivity.mActivity.hideProgress();
                                    if (Wishlist.addProduct(product, obj)) {
                                        notifyItemRemoved(position);
                                        if (mModificationListener != null) {
                                            mModificationListener.onModificationDone();
                                        }
                                        Helper.toast(L.string.item_moved_to_wishlist);
                                    }
                                }
                            });
                        }
                    }
                });
            } else {
                btn_wishlist.setVisibility(View.GONE);
                if (AppInfo.ID_LAYOUT_CART == 0) {
                    LinearLayout.LayoutParams lp = (LinearLayout.LayoutParams) this.btn_remove.getLayoutParams();
                    lp.width = LinearLayout.LayoutParams.MATCH_PARENT;
                    lp.weight = 1.0f;
                }
            }
        }

        @Override
        void onBind(Object object) {
            final Cart cart = (Cart) object;
            this.qty.setText(getString(L.string.qty));
            this.name.setText(HtmlCompat.fromHtml(cart.title));
            this.quantity.setText(String.format(Locale.ENGLISH, "%d", cart.count));
            this.total.setText(HtmlCompat.fromHtml(Helper.appendCurrency(cart.getItemTotalPrice())));

            String attributeString = cart.getAttributeString();
            if (Helper.isValidString(attributeString)) {
                this.details.setVisibility(View.VISIBLE);
                this.details.setText(HtmlCompat.fromHtml(attributeString));
            } else {
                this.details.setVisibility(View.GONE);
            }

            Glide.with(context)
                    .load(cart.img_url)
                    .placeholder(AppInfo.ID_PLACEHOLDER_PRODUCT)
                    .error(R.drawable.error_product)
                    .into(this.product_img);

            if (cart.bundledItems != null && !cart.bundledItems.isEmpty()) {
                childItemsView.setVisibility(View.VISIBLE);
                BundledItemsAdapter adapter = new BundledItemsAdapter(cart);
                childItemsView.setAdapter(adapter);
            }

            if (cart.matchedItems != null && !cart.matchedItems.isEmpty()) {
                childItemsView.setVisibility(View.VISIBLE);
                MatchingItemsAdapter adapter = new MatchingItemsAdapter(cart);
                childItemsView.setAdapter(adapter);
            }

            if (AppInfo.SHOW_PRODUCTS_BOOKING_INFO && !TextUtils.isEmpty(cart.booking_date)) {
                try {
                    txtBookingDate.setVisibility(View.VISIBLE);
                    txtBookingDate.setText(String.format(Locale.getDefault(), getString(L.string.label_booking_date), getBookingDate(cart.booking_date)));
                } catch (Exception e) {
                    e.printStackTrace();
                    txtBookingDate.setVisibility(View.GONE);
                }
            }
        }
    }

    private class BundledItemsAdapter extends RecyclerView.Adapter<BundledItemsAdapter.BundledItemViewHolder> {

        private Cart cart;

        BundledItemsAdapter(Cart cart) {
            this.cart = cart;
        }

        @Override
        public BundledItemViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
            LayoutInflater layoutInflater = LayoutInflater.from(parent.getContext());
            return new BundledItemViewHolder(layoutInflater.inflate(R.layout.item_cart_grouped_items, parent, false));
        }

        @Override
        public void onBindViewHolder(BundledItemViewHolder holder, int position) {
            holder.bindViewData(cart.bundledItems.get(position));
        }

        @Override
        public int getItemCount() {
            return cart.bundledItems.size();
        }

        class BundledItemViewHolder extends RecyclerView.ViewHolder {
            ImageView productImage;
            TextView productName;
            TextView productPrice;
            TextView productQuantity;

            BundledItemViewHolder(final View view) {
                super(view);
                this.productImage = (ImageView) view.findViewById(R.id.image_product);
                this.productName = (TextView) view.findViewById(R.id.text_name);
                this.productPrice = (TextView) view.findViewById(R.id.text_price);
                Helper.stylizeSalePriceText(productPrice);
                this.productQuantity = (TextView) view.findViewById(R.id.text_quantity);
            }

            void bindViewData(Object object) {
                CartBundleItem item = (CartBundleItem) object;
                productName.setText(HtmlCompat.fromHtml(item.getTitle()));
                productPrice.setText(getString(L.string.free));
                productQuantity.setText(String.format(getString(L.string.label_quantity) + " %s", item.getQuantity() * cart.count));
                Glide.with(context)
                        .load(item.getImageUrl())
                        .placeholder(AppInfo.ID_PLACEHOLDER_PRODUCT)
                        .error(R.drawable.error_product)
                        .into(this.productImage);
            }
        }
    }

    private class MatchingItemsAdapter extends RecyclerView.Adapter<MatchingItemsAdapter.MatchingItemViewHolder> {

        private Cart cart;

        MatchingItemsAdapter(Cart cart) {
            this.cart = cart;
        }

        @Override
        public MatchingItemViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
            LayoutInflater layoutInflater = LayoutInflater.from(parent.getContext());
            return new MatchingItemViewHolder(layoutInflater.inflate(R.layout.item_cart_grouped_items, parent, false));
        }

        @Override
        public void onBindViewHolder(MatchingItemViewHolder holder, int position) {
            holder.bindViewData(cart.matchedItems.get(position));
        }

        @Override
        public int getItemCount() {
            return cart.matchedItems.size();
        }

        class MatchingItemViewHolder extends RecyclerView.ViewHolder {
            ImageView productImage;
            TextView productName;
            TextView productPrice;
            TextView productQuantity;

            MatchingItemViewHolder(final View view) {
                super(view);
                this.productImage = (ImageView) view.findViewById(R.id.image_product);
                this.productName = (TextView) view.findViewById(R.id.text_name);
                this.productPrice = (TextView) view.findViewById(R.id.text_price);
                Helper.stylizeSalePriceText(productPrice);
                this.productQuantity = (TextView) view.findViewById(R.id.text_quantity);
            }

            void bindViewData(Object object) {
                CartMatchedItem item = (CartMatchedItem) object;
                productName.setText(HtmlCompat.fromHtml(item.getTitle()));

                float subTotalPrice = (float) (item.getBasePrice() * item.getQuantity() * cart.count);
                productPrice.setText(HtmlCompat.fromHtml(Helper.appendCurrency(subTotalPrice)));

                int subTotalQuantity = item.getQuantity() * cart.count;
                productQuantity.setText(String.format(getString(L.string.label_quantity) + " %s", subTotalQuantity));

                Glide.with(context)
                        .load(item.getImageUrl())
                        .placeholder(AppInfo.ID_PLACEHOLDER_PRODUCT)
                        .error(R.drawable.error_product)
                        .into(this.productImage);
            }
        }
    }

    public void setModificationListener(ModificationListener obj) {
        mModificationListener = obj;
    }

    public CartAdapter(Context context, List<Cart> data) {
        this.context = context;
        this.data = data;
    }

    private void setData(List<Cart> data) {
        this.data = data;
        if (data.size() == 0 && mModificationListener != null) {
            mModificationListener.onModificationDone();
        }
        this.notifyDataSetChanged();
    }

    public void updateData(List<Cart> newData) {
        this.data.clear();
        if (newData != null) {
            this.data.addAll(newData);
        }
        this.notifyDataSetChanged();
        if (mModificationListener != null) {
            mModificationListener.onModificationDone();
        }
    }

    @Override
    public int getItemCount() {
        return data.size() + headers.size() + footers.size();
    }

    public Object getItem(int position) {
        return position;
    }

    @Override
    public BaseViewHolder onCreateViewHolder(ViewGroup viewGroup, int type) {
        switch (type) {
            case TYPE_HEADER:
            case TYPE_FOOTER: {
                FrameLayout frameLayout = new FrameLayout(viewGroup.getContext());
                frameLayout.setLayoutParams(new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT));
                return new HeaderFooterViewHolder(frameLayout);
            }
            default: {
                LayoutInflater layoutInflater = LayoutInflater.from(viewGroup.getContext());
                if (AppInfo.ENABLE_BUNDLED_PRODUCTS || AppInfo.ENABLE_MIXMATCH_PRODUCTS) {
                    return new GroupedItemViewHolder(layoutInflater.inflate(R.layout.item_cart_bundled_list, viewGroup, false));
                } else {
                    int layoutId = AppInfo.ID_LAYOUT_CART == 0 ? R.layout.item_cart_0 : R.layout.item_cart_1;
                    return new SimpleItemViewHolder(layoutInflater.inflate(layoutId, viewGroup, false));
                }
            }
        }
    }

    @Override
    public void onBindViewHolder(BaseViewHolder holder, int position) {
        if (position < headers.size()) {
            holder.onBind(headers.get(position));
        } else if (position >= (headers.size() + data.size())) {
            holder.onBind(footers.get(position - data.size() - headers.size()));
        } else {
            holder.onBind(data.get(position - headers.size()));
        }
    }

    @Override
    public int getItemViewType(int position) {
        //check what type our position is, based on the assumption that the order is headers > items > footers
        if (position < headers.size()) {
            return TYPE_HEADER;
        } else if (position >= headers.size() + data.size()) {
            return TYPE_FOOTER;
        }
        return TYPE_ITEM;
    }

    @Override
    public void onAttachedToRecyclerView(RecyclerView recyclerView) {
        super.onAttachedToRecyclerView(recyclerView);
    }

    private void showUpdateCartDialog(final Cart cart) {
        Fragment_UpdateCartQuantityDialog.getInstance(cart, new Fragment_UpdateCartQuantityDialog.OnCompleteListener() {
            @Override
            public void onCompletion() {
                notifyItemChanged(headers.size() + data.indexOf(cart));
                if (mModificationListener != null) {
                    mModificationListener.onModificationDone();
                }
            }
        }).show(((FragmentActivity) context).getSupportFragmentManager(), Fragment_UpdateCartQuantityDialog.TAG);
    }

    private void updateCardQuantity(int position, int value) {
        Cart cart = (Cart) data.get(position);
        updateCardQuantity(cart, value);
    }

    private void updateCardQuantity(Cart cart, int value) {
        cart.setCount(value);
        notifyItemChanged(headers.size() + data.indexOf(cart));
        if (mModificationListener != null) {
            mModificationListener.onModificationDone();
        }
    }

    //add a header to the adapter
    public void addHeader(View header) {
        if (!headers.contains(header)) {
            headers.add(header);
            //animate
            notifyItemInserted(headers.size() - 1);
        }
    }

    //remove a header from the adapter
    public void removeHeader(View header) {
        if (headers.contains(header)) {
            //animate
            notifyItemRemoved(headers.indexOf(header));
            headers.remove(header);
            if (header.getParent() != null) {
                ((ViewGroup) header.getParent()).removeView(header);
            }
        }
    }

    //add a footer to the adapter
    public void addFooter(View footer) {
        if (!footers.contains(footer)) {
            footers.add(footer);
            //animate
            notifyItemInserted(headers.size() + data.size() + footers.size() - 1);
        }
    }

    //remove a footer from the adapter
    public void removeFooter(View footer) {
        if (footers.contains(footer)) {
            //animate
            notifyItemRemoved(headers.size() + data.size() + footers.indexOf(footer));
            footers.remove(footer);
            if (footer.getParent() != null) {
                ((ViewGroup) footer.getParent()).removeView(footer);
            }
        }
    }

    private void removeItem(Cart cart) {
        int position = data.indexOf(cart);
        if (position >= 0 && data.remove(cart)) {
            notifyItemRemoved(headers.size() + position);
            if (mModificationListener != null) {
                mModificationListener.onModificationDone();
            }
        }
    }

    public String getBookingDate(String dateBooking) throws Exception {
        Calendar calendar = Calendar.getInstance();
        DateFormat sdf = new SimpleDateFormat("MM/dd/yyyy");
        Date date = sdf.parse(dateBooking);
        calendar.setTime(date);
        SimpleDateFormat month_date = new SimpleDateFormat("MMM");
        String month_name = month_date.format(calendar.getTime());
        int dayName = calendar.get(Calendar.DAY_OF_MONTH);
        int year = calendar.get(Calendar.YEAR);
        return month_name + " " + dayName + ", " + year;
    }
}