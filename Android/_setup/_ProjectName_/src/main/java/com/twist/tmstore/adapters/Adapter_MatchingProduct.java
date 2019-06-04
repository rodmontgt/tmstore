package com.twist.tmstore.adapters;

import android.content.Context;
import android.support.v7.widget.CardView;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.twist.dataengine.entities.TM_MixMatch;
import com.twist.dataengine.entities.TM_ProductInfo;
import com.twist.tmstore.MainActivity;
import com.twist.tmstore.R;
import com.twist.tmstore.entities.AppInfo;
import com.twist.tmstore.entities.Cart;
import com.twist.tmstore.entities.CartMatchedItem;
import com.twist.tmstore.listeners.QuantityListener;
import com.twist.tmstore.listeners.ValueObserver;
import com.utils.Helper;
import com.utils.HtmlCompat;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class Adapter_MatchingProduct extends RecyclerView.Adapter<Adapter_MatchingProduct.MatchingProductViewHolder> {

    public interface OnQuantityChangeListener {
        void onQuantityChange();
    }

    private Context context;

    private List<TM_ProductInfo> matchingItems;

    private Cart selectedCart;

    private Map<TM_ProductInfo, Integer> selectedItems;

    private TM_MixMatch mMixMatch;

    private OnQuantityChangeListener mOnQuantityChangeListener;

    public Adapter_MatchingProduct(Context context, TM_ProductInfo productInfo) {
        this.context = context;
        this.mMixMatch = productInfo.mMixMatch;
        this.matchingItems = mMixMatch.getMatchingItems();
        this.selectedItems = new HashMap<>();
    }

    public void setOnQuantityChangeListener(OnQuantityChangeListener listener) {
        this.mOnQuantityChangeListener = listener;
    }

    @Override
    public int getItemCount() {
        return matchingItems.size();
    }

    @Override
    public MatchingProductViewHolder onCreateViewHolder(ViewGroup viewGroup, int type) {
        LayoutInflater inflater = LayoutInflater.from(viewGroup.getContext());
        return new MatchingProductViewHolder(inflater.inflate(R.layout.item_mixmatch_product_list, viewGroup, false));
    }

    @Override
    public void onBindViewHolder(MatchingProductViewHolder viewHolder, final int position) {
        viewHolder.bindData(position);
    }

    public Map<TM_ProductInfo, Integer> getSelectedItems() {
        return selectedItems;
    }

    public void setSelectedCart(Cart selectedCart) {
        this.selectedCart = selectedCart;
        // recreate product and quantity map from items in cart.
        if (selectedCart != null && selectedCart.matchedItems != null) {
            for (CartMatchedItem item : selectedCart.matchedItems) {
                for (TM_ProductInfo product : matchingItems) {
                    if (product.id == item.getProductId()) {
                        selectedItems.put(product, item.getQuantity());
                        break;
                    }
                }
            }
        }
    }

    public int getSelectedItemsCount() {
        int selectedItemsCount = 0;
        for (int i : selectedItems.values()) {
            selectedItemsCount += i;
        }
        return selectedItemsCount;
    }

    public float getSelectedItemsPrice() {
        float totalPrice = 0;
        for (Map.Entry<TM_ProductInfo, Integer> entry : selectedItems.entrySet()) {
            TM_ProductInfo productInfo = entry.getKey();
            totalPrice += productInfo.price * entry.getValue();
        }
        return totalPrice;
    }

    public void resetAll() {
        selectedCart = null;
        selectedItems.clear();
        notifyDataSetChanged();
    }

    class MatchingProductViewHolder extends RecyclerView.ViewHolder {
        TextView name;
        ImageView image;

        ImageButton btnQtyPlus;
        ImageButton btnQtyMinus;
        EditText textQuantity;

        MatchingProductViewHolder(View view) {
            super(view);
            name = (TextView) view.findViewById(R.id.name);
            image = (ImageView) view.findViewById(R.id.image);
            CardView cardView = (CardView) view.findViewById(R.id.card_view);
            cardView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    TM_ProductInfo product = matchingItems.get(getLayoutPosition());
                    MainActivity.mActivity.openProductInfo(product);
                }
            });

            textQuantity = (EditText) view.findViewById(R.id.edit_quantity);
            textQuantity.addTextChangedListener(new QuantityListener(textQuantity));
            Helper.stylize(textQuantity, true);

            btnQtyPlus = (ImageButton) view.findViewById(R.id.btn_qty_plus);
            Helper.stylizeVector(btnQtyPlus);
            btnQtyPlus.setOnClickListener(new ValueObserver(textQuantity, ValueObserver.Type.INCREASE, new ValueObserver.OnChangeCallback() {
                @Override
                public void onChange(int value) {
                    if (!isLimitExceeds()) {
                        onQuantityChange(value);
                    } else {
                        textQuantity.setText(String.valueOf(--value));
                    }
                }
            }, 0, 999));

            btnQtyMinus = (ImageButton) view.findViewById(R.id.btn_qty_minus);
            Helper.stylizeVector(btnQtyMinus);
            btnQtyMinus.setOnClickListener(new ValueObserver(textQuantity, ValueObserver.Type.DECREASE, new ValueObserver.OnChangeCallback() {
                @Override
                public void onChange(int value) {
                    onQuantityChange(value);
                }
            }, 0, 999));
            textQuantity.setText(String.valueOf(0));
        }

        void bindData(int position) {
            TM_ProductInfo product = matchingItems.get(position);
            if (product != null) {
                name.setText(HtmlCompat.fromHtml(product.title));
                textQuantity.setText(String.valueOf(getCurrentQuantity(product)));
                Glide.with(context)
                        .load(product.thumb)
                        .placeholder(AppInfo.ID_PLACEHOLDER_PRODUCT)
                        .error(R.drawable.error_product)
                        .into(image);
            }
        }

        void onQuantityChange(int quantity) {
            TM_ProductInfo product = matchingItems.get(getLayoutPosition());
            if (quantity <= 0) {
                selectedItems.remove(product);
            } else {
                selectedItems.put(product, quantity);
            }

            if (selectedCart != null) {
                selectedCart.updateMatchedItems(CartMatchedItem.encodeToString(selectedItems));
            }

            if (mOnQuantityChangeListener != null) {
                mOnQuantityChangeListener.onQuantityChange();
            }
        }

        int getCurrentQuantity(TM_ProductInfo product) {
            if (selectedCart != null && selectedCart.matchedItems != null) {
                for (CartMatchedItem item : selectedCart.matchedItems) {
                    if (item.getProductId() == product.id) {
                        return item.getQuantity();
                    }
                }
            }
            if (!selectedItems.isEmpty() && selectedItems.containsKey(product)) {
                return selectedItems.get(product);
            }
            return 0;
        }

        boolean isLimitExceeds() {
            int size = (int) mMixMatch.getContainerSize();
            return (size != 0 && size == getSelectedItemsCount());
        }
    }
}