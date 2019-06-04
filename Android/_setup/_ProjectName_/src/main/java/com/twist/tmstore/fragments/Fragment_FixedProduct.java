package com.twist.tmstore.fragments;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Bundle;
import android.support.design.widget.FloatingActionButton;
import android.support.v7.widget.CardView;
import android.support.v7.widget.GridLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.StaggeredGridLayoutManager;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CompoundButton;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.bumptech.glide.Glide;
import com.twist.dataengine.DataQueryHandler;
import com.twist.dataengine.DataEngine;;
import com.twist.dataengine.entities.TM_ProductInfo;
import com.twist.dataengine.entities.UserFilter;
import com.twist.tmstore.BaseFragment;
import com.twist.tmstore.L;
import com.twist.tmstore.MainActivity;
import com.twist.tmstore.R;
import com.twist.tmstore.BaseActivity;
import com.twist.tmstore.adapters.Adapter_Products;
import com.twist.tmstore.config.GuestUserConfig;
import com.twist.tmstore.config.ImageDownloaderConfig;
import com.twist.tmstore.entities.AppInfo;
import com.twist.tmstore.entities.AppUser;
import com.twist.tmstore.entities.Cart;
import com.twist.tmstore.entities.WishListGroup;
import com.twist.tmstore.entities.Wishlist;
import com.twist.tmstore.listeners.WishListDialogHandler;
import com.utils.Helper;
import com.utils.HtmlCompat;
import com.utils.ImageDownload;
import com.utils.Log;
import com.utils.customviews.progressbar.CircleProgressBar;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by Twist Mobile on 29-12-2016.
 */

public class Fragment_FixedProduct extends BaseFragment {
    View list_footer;
    View coordinatorLayout;
    ViewGroup downloadPanel;

    TextView selected_product_count_text;
    ImageView icon_badge_item_count;

    RecyclerView recyclerView;
    Adapter_Products adapter = null;

    private UserFilter currentFilter = null;
    private int[] productIds = null;
    private List<TM_ProductInfo> products = null;
    private String title;
    private CircleProgressBar progress_bar;

    public UserFilter getUserFilter() {
        return this.currentFilter;
    }

    public static Fragment_FixedProduct newInstance(String title, int[] productId) {
        Fragment_FixedProduct fragment = new Fragment_FixedProduct();
        fragment.title = title;
        fragment.initCategoryByProductId(productId);
        return fragment;
    }

    public static Fragment_FixedProduct newInstance(String title, List<TM_ProductInfo> products) {

        Fragment_FixedProduct fragment = new Fragment_FixedProduct();
        fragment.products = products;
        fragment.title = title;
        return fragment;
    }


    public void initCategoryByProductId(int[] productIds) {
        this.productIds = productIds;
    }


    @Override
    public void onStop() {
        Helper.gc();
        super.onStop();
    }

    @Override
    public void onResume() {
        super.onResume();
        if (adapter != null) {
            adapter.notifyDataSetChanged();
        }
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        Helper.gc();
        View rootView = inflater.inflate(R.layout.fragment_category_child, container, false);
        initComponents(rootView);

        bindData();
        return rootView;
    }

    void initComponents(final View rootView) {
        coordinatorLayout = rootView.findViewById(R.id.coordinatorLayout);
        recyclerView = (RecyclerView) rootView.findViewById(R.id.recyclerView);
        progress_bar = (CircleProgressBar) rootView.findViewById(R.id.progress_bar);
        Helper.stylize(progress_bar);

        {
            final int columnCount = Adapter_Products.getProductLayoutColumnCount();
            if (AppInfo.ID_LAYOUT_PRODUCTS == 3) {
                RecyclerView.LayoutManager layoutManager = new StaggeredGridLayoutManager(columnCount, StaggeredGridLayoutManager.VERTICAL);
                ((StaggeredGridLayoutManager) layoutManager).setGapStrategy(StaggeredGridLayoutManager.GAP_HANDLING_MOVE_ITEMS_BETWEEN_SPANS);
                recyclerView.setLayoutManager(layoutManager);
            } else {
                RecyclerView.LayoutManager layoutManager = new GridLayoutManager(getActivity(), columnCount);
                recyclerView.setLayoutManager(layoutManager);
            }
            recyclerView.setHasFixedSize(false);
        }

        adapter = new Adapter_Products((BaseActivity) getActivity(), new ArrayList<TM_ProductInfo>(), new View.OnLongClickListener() {
            @Override
            public boolean onLongClick(View view) {
                if (downloadPanel != null) {
                    showDownloadPanel();
                }
                return false;
            }
        }, new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                setBadgeCount();
            }
        });
        if (products != null) {
            adapter.addProducts(products);
        }

        if (productIds != null) {

            List<TM_ProductInfo> availableProducts = new ArrayList<>();
            List<Integer> missingProducts = new ArrayList<>();
            for (int id : this.productIds) {
                final TM_ProductInfo tm_productInfo = TM_ProductInfo.findProductById(id);
                if (tm_productInfo != null) {
                    availableProducts.add(tm_productInfo);
                } else {
                    missingProducts.add(id);
                }
            }
            if (!missingProducts.isEmpty()) {
                progress_bar.setVisibility(View.VISIBLE);
                DataEngine.getDataEngine().getPollProductsInBackground(missingProducts, new DataQueryHandler<List<TM_ProductInfo>>() {
                    @Override
                    public void onSuccess(List<TM_ProductInfo> data) {
                        progress_bar.setVisibility(View.GONE);
                        adapter.addProducts(data);
                    }

                    @Override
                    public void onFailure(Exception error) {
                        progress_bar.setVisibility(View.GONE);
                        Log.d("***********  no product found ************");
                    }
                });
            }
            adapter.addProducts(availableProducts);
        }

        if (AppInfo.ENABLE_MULTIPLE_WISHLIST || AppInfo.ENABLE_SINGLE_CHECK_WISHLIST || ImageDownloaderConfig.isEnabled()) {

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {

                downloadPanel = ((ViewGroup) rootView.findViewById(R.id.dynamic_panel));
                FloatingActionButton btn_action = ((FloatingActionButton) rootView.findViewById(R.id.btn_action));
                Helper.stylize(btn_action);

                btn_action.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {

                        Helper.showSelectMultipleActionButtons(downloadPanel, false, new View.OnClickListener() {
                            @Override
                            public void onClick(View view) {
                                initDownloadTask();
                            }
                        }, new View.OnClickListener() {
                            @Override
                            public void onClick(View view) {
                                initAddtoMultipleList();
                            }
                        }, new View.OnClickListener() {
                            @Override
                            public void onClick(View view) {

                                initAddtoCart();
                            }
                        }, new View.OnClickListener() {

                            @Override
                            public void onClick(View view) {
                                initAddtoSingleList();

                            }
                        }, new View.OnClickListener() {
                            @Override
                            public void onClick(View view) {

                            }
                        }, new View.OnClickListener() {
                            @Override
                            public void onClick(View view) {
                                initShare();
                            }
                        });
                    }
                });
            } else {
                downloadPanel = (ViewGroup) getDownloadPanel(((ViewGroup) rootView.findViewById(R.id.dynamic_panel_fixed_product_v20)));
            }
            selected_product_count_text = (TextView) downloadPanel.findViewById(R.id.selected_product_count_text);
            icon_badge_item_count = (ImageView) downloadPanel.findViewById(R.id.icon_badge);
            Helper.stylizeBadgeView(icon_badge_item_count, selected_product_count_text);
            setBadgeCount();
        }
        //footer
        if (AppInfo.ENABLE_PROMO_BUTTON) {
            list_footer = View.inflate(getActivity(), Adapter_Products.getProductLayoutId(false), null);
            TextView name = (TextView) list_footer.findViewById(R.id.name);
            TextView regular_price = (TextView) list_footer.findViewById(R.id.regular_price);
            TextView sale_price = (TextView) list_footer.findViewById(R.id.sale_price);
            ImageView img = (ImageView) list_footer.findViewById(R.id.img);
            CompoundButton chk_wishlist = (CompoundButton) list_footer.findViewById(R.id.chk_wishlist);
            CardView cv = (CardView) list_footer.findViewById(R.id.cv);
            cv.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    Helper.openPromotionUrl(v.getContext());
                }
            });
            name.setText(HtmlCompat.fromHtml(AppInfo.PROMO_TITLE));
            regular_price.setText(HtmlCompat.fromHtml(AppInfo.PROMO_DESC));

            sale_price.setVisibility(View.INVISIBLE);
            chk_wishlist.setVisibility(View.GONE);
            Glide.with(getActivity())
                    .load(AppInfo.PROMO_IMG_URL)
                    .placeholder(R.drawable.ic_promotion)
                    .into(img);
            adapter.addFooter(list_footer);
            if (AppInfo.HIDE_PRODUCT_PRICE_TAG || GuestUserConfig.hidePriceTag()) {
                regular_price.setVisibility(View.GONE);
                sale_price.setVisibility(View.GONE);
            }
        }
        recyclerView.setAdapter(adapter);
        rootView.findViewById(R.id.text_empty).setVisibility(View.GONE);
        resetTaskCount();

    }

    void bindData() {
        adapter.setHasSubCategories(false);
        if (Helper.isValidString(title)) {
            setTitle(title);
        }
        if (downloadPanel != null) {
            hideDownloadPanelInitially();
        }
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        resetTitleBar();
    }

    private void resetTitleBar() {
        ((MainActivity) getActivity()).reloadMenu();
    }

    @Override
    public void onStart() {
        super.onStart();
        if (AppInfo.basic_content_loading) {
            addTaskCount();
        }
    }

    void updateProgressStatus() {
    }

    private int numTasks = 0;

    private void resetTaskCount() {
        numTasks = 0;
        updateProgressStatus();
    }

    public void addTaskCount() {
        numTasks++;
        updateProgressStatus();
    }

    public void reduceTaskCount() {
        numTasks--;
        updateProgressStatus();
    }

    private View getDownloadPanel(final ViewGroup parent) {

        return Helper.getDownloadPanel(parent, new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                showDownloadChkBoxesInAdapter();
            }
        }, new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Helper.showSelectMultipleMenu(view, false, new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        initDownloadTask();
                    }
                }, new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        initAddtoMultipleList();
                    }
                }, new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {

                        initAddtoCart();
                    }
                }, new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {

                        initAddtoSingleList();
                    }
                }, new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {
                    }
                }, new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        initShare();
                    }
                });

            }
        });
    }

    private void refreshAdapter() {
        adapter.resetAdapterForCheckBox();
        setBadgeCount();
    }

    private void showDownloadChkBoxesInAdapter() {
        adapter.setCheckMode(true);
    }

    private void startDownloadTask() {
        boolean isStarted = false;
        for (Map.Entry<Integer, Boolean> entry : Adapter_Products.mCheckedItem.entrySet()) {
            TM_ProductInfo product = TM_ProductInfo.getProductWithId(entry.getKey());
            if (product != null && entry.getValue()) {
                isStarted = true;
                ImageDownload.downloadProductCatalog(getActivity(), product);
            }
        }
        Toast.makeText(getActivity(), isStarted ? getString(L.string.download_initiated) : getString(L.string.no_products), Toast.LENGTH_SHORT).show();
        refreshAdapter();
    }

    private void openWishGroupListAndAddProduct() {
        HashMap<Integer, Boolean> map = Adapter_Products.mCheckedItem;
        for (Map.Entry<Integer, Boolean> entry : map.entrySet()) {
            Integer key = entry.getKey();
            Boolean value = entry.getValue();
            TM_ProductInfo product = TM_ProductInfo.getProductWithId(key);
            if (product != null && value) {
                WishListGroup.selectedProductToAddInWishList.add(product);
            }
        }
        refreshAdapter();
    }

    private void setBadgeCount() {
        int count = getItemCount();
        selected_product_count_text.setText(String.valueOf(count));
        selected_product_count_text.setVisibility(count > 0 ? View.VISIBLE : View.GONE);
        icon_badge_item_count.setVisibility(count > 0 ? View.VISIBLE : View.GONE);
        if (count > 0)
            showDownloadPanel();
        else
            hideDownloadPanel();
    }

    private int getItemCount() {
        HashMap<Integer, Boolean> map = Adapter_Products.mCheckedItem;
        int count = 0;
        for (Map.Entry<Integer, Boolean> entry : map.entrySet()) {
            Integer key = entry.getKey();
            Boolean value = entry.getValue();
            if (value) {
                count++;
            }
        }
        return count;
    }

    boolean isDownloadPanelAnimationRunning = false;

    private void hideDownloadPanelInitially() {

        downloadPanel.setVisibility(View.GONE);
        isDownloadPanelAnimationRunning = false;
    }

    private void hideDownloadPanel() {
        if (!adapter.isCheckedMode() && !isDownloadPanelAnimationRunning && downloadPanel.getVisibility() != View.GONE) {
            isDownloadPanelAnimationRunning = true;
            downloadPanel.animate()
                    .translationY(-downloadPanel.getHeight())
                    .alpha(0.0f)
                    .setDuration(300)
                    .setListener(new AnimatorListenerAdapter() {
                        @Override
                        public void onAnimationEnd(Animator animation) {
                            super.onAnimationEnd(animation);
                            downloadPanel.setVisibility(View.GONE);
                            isDownloadPanelAnimationRunning = false;
                        }
                    });
        }

        Helper.hideSelectMultipleActionButtons(downloadPanel);
    }

    private void showDownloadPanel() {

        if (adapter.isCheckedMode() && !isDownloadPanelAnimationRunning && downloadPanel.getVisibility() != View.VISIBLE) {
            isDownloadPanelAnimationRunning = true;
            downloadPanel.setVisibility(View.VISIBLE);
            downloadPanel.animate()
                    .translationY(0)
                    .alpha(1.0f)
                    .setDuration(300)
                    .setListener(new AnimatorListenerAdapter() {
                        @Override
                        public void onAnimationEnd(Animator animation) {
                            super.onAnimationEnd(animation);
                            isDownloadPanelAnimationRunning = false;
                        }
                    });
        }

        Helper.hideSelectMultipleActionButtons(downloadPanel);
    }


    public interface onSingleWishListChangeListner {
        void OnCheckedChange(TM_ProductInfo product, boolean isChecked);
    }

    private void initShare() {

        new AsyncTask<Void, Void, ArrayList<Uri>>() {
            @Override
            protected ArrayList<Uri> doInBackground(Void... voids) {
                MainActivity.mActivity.showProgress(getString(L.string.loading), false);
                return Helper.getImageUriList(getActivity(), Adapter_Products.mCheckedItem);
            }

            @Override
            protected void onPostExecute(ArrayList<Uri> result) {
                super.onPostExecute(result);
                Helper.shareOnWhatsApp("", result);
                MainActivity.mActivity.hideProgress();
                adapter.checkMode = false;
                refreshAdapter();
            }
        }.execute();
    }

    private void initAddtoSingleList() {

        openWishGroupListAndAddProduct();
        if (WishListGroup.selectedProductToAddInWishList.size() == 0) {
            Helper.toast(L.string.no_products);
            refreshAdapter();
            return;
        }
        final WishListGroup wishListGroup = WishListGroup.getWishListGroupById(WishListGroup.getdefaultWishGroupID());
        if (AppUser.hasSignedIn() && AppInfo.ENABLE_MULTIPLE_WISHLIST) {
            List<WishListGroup> mylist = new ArrayList<>();
            if (wishListGroup != null) {
                wishListGroup.isChecked = true;
                mylist.add(wishListGroup);
            }
            String str = WishListGroup.getPidsArrayString(mylist, WishListGroup.selectedProductToAddInWishList);
            MainActivity.mActivity.showProgress(getString(L.string.please_wait));
            WishListGroup.addProductsToMultipleWishList(str, new DataQueryHandler() {
                @Override
                public void onSuccess(Object data) {
                    MainActivity.mActivity.hideProgress();
                    refreshAdapter();
                    WishListGroup.selectedProductToAddInWishList.clear();
                    Helper.toast(Helper.showItemAddedToWishListToast(wishListGroup));
                }

                @Override
                public void onFailure(Exception error) {
                    MainActivity.mActivity.hideProgress();
                    MainActivity.mActivity.showProgress(getString(L.string.retry));
                }
            });
        } else {
            if (AppInfo.ENABLE_SINGLE_CHECK_WISHLIST) {
                if (WishListGroup.allwishListGroup.size() > 0) {
                    for (TM_ProductInfo product : WishListGroup.selectedProductToAddInWishList) {
                        if (!WishListGroup.hasChild(wishListGroup.id, product) && Wishlist.addProduct(product, wishListGroup)) {
                        }
                    }
                    WishListGroup.selectedProductToAddInWishList.clear();
                    Helper.toast(getString(L.string.item_added_to_wishlist));
                    refreshAdapter();
                    MainActivity.mActivity.reloadMenu();
                } else {
                    MainActivity.mActivity.openWishlistFragment(false);
                }
            } else {

                for (TM_ProductInfo product : WishListGroup.selectedProductToAddInWishList) {
                    if (Wishlist.addProduct(product, wishListGroup)) {
                    }
                }
                WishListGroup.selectedProductToAddInWishList.clear();
                Helper.toast(getString(L.string.item_added_to_wishlist));
                refreshAdapter();
                MainActivity.mActivity.reloadMenu();
            }
        }

    }

    private void initAddtoCart() {
        if (AppInfo.mGuestUserConfig != null && AppInfo.mGuestUserConfig.isEnabled() && AppInfo.mGuestUserConfig.isPreventCart() && AppUser.isAnonymous()) {
            Helper.toast(L.string.you_need_to_login_first);
            return;
        }
        openWishGroupListAndAddProduct();

        if (WishListGroup.selectedProductToAddInWishList.size() == 0) {
            Helper.toast(L.string.no_products);
            refreshAdapter();
            return;
        }
        final List<TM_ProductInfo> addprodtocart = new ArrayList<>();
        boolean isAdded = false;
        boolean isoutofstock = false;
        boolean isAttributes = false;
        for (TM_ProductInfo product : WishListGroup.selectedProductToAddInWishList) {
            if (!product.hasAttributes()) {
                if (product.in_stock) {
                    if (Cart.hasItem(product)) {
                        isAdded = true;
                    } else
                        addprodtocart.add(product);
                } else {
                    isoutofstock = true;
                }
            } else {
                isAttributes = true;
            }
        }
        if (isAttributes || isoutofstock || isAdded) {
            String msg = "";
            String title = "";
            if (isAttributes) {
                msg = getString(L.string.adding_attribute_error);
                title = getString(L.string.title_contains_attribute);
            }
            if (isoutofstock) {
                msg = Helper.changeLine(msg) + getString(L.string.adding_outofstock_error);
                title = getString(L.string.title_out_of_stock);
            }
            if (isAdded) {
                msg = Helper.changeLine(msg) + getString(L.string.adding_alredyadded_error);
                title = getString(L.string.title_already_in_cart);
            }
            Helper.showAlertDialog(title, msg, getString(L.string.continue_anyway), true, new View.OnLongClickListener() {
                @Override
                public boolean onLongClick(View view) {
                    boolean isAnyAdded = false;
                    for (TM_ProductInfo product : addprodtocart) {
                        Cart.addProduct(product);
                        isAnyAdded = true;
                    }
                    if (isAnyAdded) Helper.toast(getString(L.string.item_added_to_cart));
                    WishListGroup.selectedProductToAddInWishList.clear();
                    return false;
                }
            });
        } else {
            for (TM_ProductInfo product : addprodtocart) {
                Cart.addProduct(product);
            }
            WishListGroup.selectedProductToAddInWishList.clear();
            Helper.toast(getString(L.string.item_added_to_cart));
        }
    }

    private void initAddtoMultipleList() {
        openWishGroupListAndAddProduct();
        if (WishListGroup.selectedProductToAddInWishList.size() == 0) {
            Helper.toast(L.string.no_products);
            refreshAdapter();
            return;
        }

        Fragment_Wishlist_Dialog.OpenWishGroupDialogWishCheckbox(WishListGroup.selectedProductToAddInWishList, new WishListDialogHandler() {
            @Override
            public void onSelectGroupSuccess(TM_ProductInfo product, WishListGroup obj) {
                WishListGroup.selectedProductToAddInWishList.clear();
            }

            @Override
            public void onSelectGroupFailed(String cause) {

            }

            @Override
            public void onSkipDialog(TM_ProductInfo product, WishListGroup obj) {
            }
        });
    }

    private void initDownloadTask() {
        startDownloadTask();
    }
}
