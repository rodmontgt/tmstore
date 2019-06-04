package com.twist.tmstore.fragments;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.content.Context;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Bundle;
import android.support.design.widget.FloatingActionButton;
import android.support.v7.widget.GridLayoutManager;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.twist.dataengine.DataQueryHandler;
import com.twist.dataengine.DataEngine;;
import com.twist.dataengine.entities.TM_ProductInfo;
import com.twist.dataengine.entities.TM_WishList;
import com.twist.tmstore.BaseFragment;
import com.twist.tmstore.Constants;
import com.twist.tmstore.L;
import com.twist.tmstore.MainActivity;
import com.twist.tmstore.R;
import com.twist.tmstore.adapters.WishListAdapter;
import com.twist.tmstore.config.ImageDownloaderConfig;
import com.twist.tmstore.entities.AppInfo;
import com.twist.tmstore.entities.AppUser;
import com.twist.tmstore.entities.Cart;
import com.twist.tmstore.entities.WishListGroup;
import com.twist.tmstore.entities.Wishlist;
import com.twist.tmstore.listeners.WishListDialogHandler;
import com.utils.DataHelper;
import com.utils.Helper;
import com.utils.Log;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class Fragment_Wish extends BaseFragment {

    private int mColumnCount = 1;
    boolean bIsfromDeeplink = false;
    private OnListFragmentInteractionListener mListener;

    private Button btn_keepshopping;

    private Button mShareWishListButton;

    private TextView mEmptyView;

    private Button ftb_wish;
    private Button btn_cancel_select_wish;
    ViewGroup downloadPanel;

    WishListAdapter adapter;

    TextView selected_product_count_text;
    ImageView icon_badge_item_count;

    public WishListGroup getWishGroup() {
        return wishGroup;
    }

    public void setWishGroup(WishListGroup wishGroup) {
        this.wishGroup = wishGroup;
    }

    public WishListGroup wishGroup;

    public Fragment_Wish() {
    }

    public static Fragment_Wish newInstance() {
        return new Fragment_Wish();
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setHasOptionsMenu(true);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_wish_list, container, false);

        setActionBarHomeAsUpIndicator();
        getBaseActivity().restoreActionBar();

        View coordinatorLayout = view.findViewById(R.id.coordinatorLayout);

        //refreshWishAsync();
        Context context = view.getContext();

        if (getArguments() != null && getArguments().containsKey(Constants.ARG_WISHLIST_DEEPLINK)) {
            bIsfromDeeplink = getArguments().getBoolean(Constants.ARG_WISHLIST_DEEPLINK);
        }

        final View empty = view.findViewById(R.id.text_empty);
        final LinearLayout empty_section = (LinearLayout) view.findViewById(R.id.empty_section);
        btn_keepshopping = (Button) view.findViewById(R.id.btn_keepshopping);
        btn_keepshopping.setText(getString(L.string.keep_shopping));
        btn_keepshopping.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                MainActivity.mActivity.onNavigationDrawerItemSelected(Constants.MENU_ID_HOME, -1);
            }
        });
        Helper.stylize(btn_keepshopping);

        mShareWishListButton = (Button) view.findViewById(R.id.btn_share_wishlist);
        mShareWishListButton.setText(getString(L.string.share_wishlist));
        mShareWishListButton.setVisibility(View.GONE);
        mShareWishListButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                if (!AppUser.hasSignedIn()) {

                    Helper.showAlertDialog("", getString(L.string.login_to_share_wishlist), getString(L.string.ok), true, new View.OnLongClickListener() {
                        @Override
                        public boolean onLongClick(View v) {
                            return false;
                        }
                    });

                    return;
                }
                if (AppInfo.ENABLE_CUSTOM_WISHLIST) {
                    Helper.shareWithFriends(TM_WishList.getSharableUrl());
                } else if (AppInfo.ENABLE_MULTIPLE_WISHLIST) {
                    Helper.shareWithFriends(getWishGroup().url);
                }
            }
        });
        Helper.stylize(mShareWishListButton);

        showShareWishListButton();

        mEmptyView = (TextView) view.findViewById(R.id.text_no_items);
        mEmptyView.setText(getString(L.string.no_items_in_wishlist));

        final RecyclerView recyclerView = (RecyclerView) view.findViewById(R.id.list);

        if (mColumnCount <= 1) {
            recyclerView.setLayoutManager(new LinearLayoutManager(context) {
                @Override
                public void onLayoutChildren(RecyclerView.Recycler recycler, RecyclerView.State state) {
                    super.onLayoutChildren(recycler, state);
                    if (findFirstVisibleItemPosition() == 0 && findLastVisibleItemPosition() == (Wishlist.getItemCount() - 1)) {
                        //hideDownloadPanel();
                        //showDownloadPanel();//fixed Now
                    }
                }
            });
        } else {
            recyclerView.setLayoutManager(new GridLayoutManager(context, mColumnCount));
        }


        final FrameLayout bnt_frame_bottom = (FrameLayout) view.findViewById(R.id.btn_frame_bottom_wishlist);
        bnt_frame_bottom.setVisibility(View.GONE);

        ftb_wish = (Button) view.findViewById(R.id.ftb_wish);
        ftb_wish.setText(getString(L.string.download_selected));
        Helper.stylize(ftb_wish);

        adapter = new WishListAdapter(getWishListFromGroup(Wishlist.getAll()), mListener, new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                setBadgeCount();
            }
        });

        ftb_wish.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                bnt_frame_bottom.setVisibility(View.GONE);
                adapter.downloadAllSelected(getWishGroup());
            }
        });

        if (AppInfo.ENABLE_MULTIPLE_WISHLIST || AppInfo.ENABLE_MULTIPLE_DELETE || (AppInfo.mImageDownloaderConfig != null && AppInfo.mImageDownloaderConfig.isShowInWishList())) {

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {

                downloadPanel = ((ViewGroup) view.findViewById(R.id.dynamic_panel));
                FloatingActionButton btn_action = ((FloatingActionButton) view.findViewById(R.id.btn_action));
                Helper.stylize(btn_action);
                downloadPanel.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {

                        Helper.showSelectMultipleActionButtons(downloadPanel, true, new View.OnClickListener() {
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
                                initDelete();
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
                downloadPanel = (ViewGroup) getDownloadPanel((ViewGroup) view.findViewById(R.id.dynamic_panel_v20));
            }
            selected_product_count_text = (TextView) downloadPanel.findViewById(R.id.selected_product_count_text);
            icon_badge_item_count = (ImageView) downloadPanel.findViewById(R.id.icon_badge);
            Helper.stylizeBadgeView(icon_badge_item_count, selected_product_count_text);
            hideDownloadPanelInitially();
        }

        btn_cancel_select_wish = (Button) view.findViewById(R.id.btn_cancel_select_wish);
        btn_cancel_select_wish.setText(getString(L.string.cancel));
        Helper.stylize(btn_cancel_select_wish);
        btn_cancel_select_wish.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                bnt_frame_bottom.setVisibility(View.GONE);
                adapter.checkMode = false;
                adapter.notifyDataSetChanged();
            }
        });

        final RecyclerView.AdapterDataObserver emptyObserver = new RecyclerView.AdapterDataObserver() {
            @Override
            public void onChanged() {
                if (adapter != null && empty != null) {
                    empty_section.setVisibility(adapter.getItemCount() > 0 ? View.GONE : View.VISIBLE);
                    empty.setVisibility(adapter.getItemCount() > 0 ? View.GONE : View.VISIBLE);
                    if (mShareWishListButton != null) {
                        if (adapter.getItemCount() == 0) {
                            mShareWishListButton.setVisibility(View.GONE);
                        }
                    }
                    if (downloadPanel != null) {
                        if (adapter.getItemCount() == 0) {
                            hideDownloadPanel();
                        }
                    }
                }
            }

            @Override
            public void onItemRangeChanged(int positionStart, int itemCount) {
                onChanged();
            }

            @Override
            public void onItemRangeInserted(int positionStart, int itemCount) {
                onChanged();
            }

            @Override
            public void onItemRangeRemoved(int positionStart, int itemCount) {
                onChanged();
            }
        };
        adapter.registerAdapterDataObserver(emptyObserver);
        recyclerView.setAdapter(adapter);
        emptyObserver.onChanged();

        if (getWishGroup() != null && Helper.isValidString(getWishGroup().title))
            setTitle(getWishGroup().title);
        else
            setTitle(getString(L.string.title_wishlist));

        syncWishListDetails();


        if (bIsfromDeeplink)
            syncWisListGroupDetails();

        return view;
    }

    public List<Wishlist> getWishListFromGroup(List<Wishlist> items) {

        if (!AppInfo.ENABLE_MULTIPLE_WISHLIST) {
            return items;
        }

        List<Wishlist> newlist = new ArrayList<>();
        for (Wishlist list : items) {
            if (getWishGroup() != null && list.parent_id == getWishGroup().id)
                newlist.add(list);
        }
        return newlist;
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        String ids = Wishlist.getUnavailableProductIds();
        Log.d("-- getUnavailableProductIds: [" + ids + "] --");
        if (ids.length() == 0) {
            resetFragment();
        } else {
            fetchWishProducts(ids.substring(0, ids.length() - 1));
        }
    }

    void fetchWishProducts(String productIds) {
        Log.d("-- fetchWishProducts:[" + productIds + "] --");
        showProgress(getString(L.string.retrieving));
        DataEngine.getDataEngine().getPollProductsInBackground(productIds, new DataQueryHandler() {
            @Override
            public void onSuccess(Object data) {
                hideProgress();
                Wishlist.refresh();
                adapter.notifyDataSetChanged();
                try {
                    resetFragment();
                } catch (IllegalStateException ex) {
                    ex.printStackTrace();
                }
            }

            @Override
            public void onFailure(Exception error) {
                hideProgress();
            }
        });
    }

    public void resetFragment() {
//        if (Wishlist.getAll().size() == 0) {
//            empty.setVisibility(View.VISIBLE);
//        } else {
//            empty.setVisibility(View.GONE);
//        }
    }

    void refreshWishAsync() {
        new Thread(new Runnable() {
            @Override
            public void run() {
                Wishlist.refresh();
            }
        }).start();
    }

    @Override
    public void onAttach(Context context) {
        super.onAttach(context);
        if (context instanceof OnListFragmentInteractionListener) {
            mListener = (OnListFragmentInteractionListener) context;
        } else {
            mListener = new OnListFragmentInteractionListener() {
                @Override
                public void onListFragmentInteraction(Wishlist item) {
                    MainActivity.mActivity.showProductInfoQuick(item.product_id, -1, -1, true);
                }
            };
        }
    }

    @Override
    public void onDetach() {
        super.onDetach();
        mListener = null;
    }

    public interface OnListFragmentInteractionListener {
        void onListFragmentInteraction(Wishlist wish);
    }

    private void syncWishListProducts() {
        if (!AppInfo.ENABLE_CUSTOM_WISHLIST) {
            // Custom WishList not enabled
            return;
        }

        showProgress(getString(L.string.syncing_wishlist), false);
        String emailId = AppUser.getEmail();
        int userId = AppUser.getUserId();
        DataEngine.getDataEngine().getWishListProductsAsync(emailId, userId, new DataQueryHandler<Void>() {
            @Override
            public void onSuccess(Void data) {
                List<TM_WishList> items = TM_WishList.getAll();
                for (TM_WishList item : TM_WishList.getAll()) {
                    Wishlist.addProduct(TM_ProductInfo.getProductWithId(item.getProductId()), null, true);
                }
                if (items.size() != 0) {
                    adapter.setItems(Wishlist.getAll());
                    adapter.notifyDataSetChanged();
                }
                hideProgress();
            }

            @Override
            public void onFailure(Exception reason) {
                hideProgress();
                Log.d("Failed to sync WishList!");
            }
        });
    }

    private void syncWisListGroupDetails() {

        if (!AppInfo.ENABLE_MULTIPLE_WISHLIST) {
            return;
        }

        int id = 0;
        if (WishListGroup.allwishListGroup.size() > 0) {

            showShareWishListButton();
            id = getWishGroup().id;
            showProgress(getString(L.string.syncing_wishlist), false);
            WishListGroup.getUserWishList(id, new DataQueryHandler() {
                @Override
                public void onSuccess(Object data) {
                    JSONObject jsonobj = null;
                    try {
                        jsonobj = DataHelper.safeJsonObject(data.toString());
                        String url = jsonobj.getString("url");
                        String items = jsonobj.getString("items");
                        getWishGroup().url = url;
                        getWishGroup().items = items;
                        hideProgress();

                    } catch (JSONException e) {
                        e.printStackTrace();
                        hideProgress();
                    }
                }

                @Override
                public void onFailure(Exception error) {
                    error.printStackTrace();
                    hideProgress();
                }
            });
        }
    }

    private void syncWishListDetails() {
        if (!AppInfo.ENABLE_CUSTOM_WISHLIST) {
            // Custom WishList not enabled
            return;
        }

        if (TM_WishList.getUrl() != null && TM_WishList.getToken() != null) {
            if (adapter.getItemCount() > 0) {
                showShareWishListButton();
            }
            syncWishListProducts();
            return;
        }

        showProgress(getString(L.string.syncing_wishlist), false);
        DataEngine.getDataEngine().getWishListDetailsAsync(AppUser.getEmail(), AppUser.getUserId(), new DataQueryHandler<String>() {
            @Override
            public void onSuccess(String data) {
                try {
                    JSONObject jsonObject = new JSONObject(data);
                    TM_WishList.setUrl(jsonObject.getString("wishlist_url"));
                    TM_WishList.setToken(jsonObject.getString("wishlist_token"));
                } catch (JSONException e) {
                    e.printStackTrace();
                }
                if (adapter.getItemCount() > 0) {
                    showShareWishListButton();
                }
                hideProgress();
                syncWishListProducts();
            }

            @Override
            public void onFailure(Exception reason) {
                hideProgress();
                mShareWishListButton.setVisibility(View.GONE);
                Log.d("Failed to fetch WishList details!");
            }
        });
    }

    private void showShareWishListButton() {
        if (AppUser.hasSignedIn() && AppInfo.ENABLE_MULTIPLE_WISHLIST)
            mShareWishListButton.setVisibility(View.VISIBLE);
        else
            mShareWishListButton.setVisibility(View.GONE);
    }

    private View getDownloadPanel(final ViewGroup parent) {


        return Helper.getDownloadPanel(parent, new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                adapter.setCheckMode(true);
            }
        }, new View.OnClickListener() {
            @Override
            public void onClick(View view) {

                Helper.showSelectMultipleMenu(parent, true, new View.OnClickListener() {
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
                        initDeleteAll();
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

    public void refreshAllAdapters() {
        adapter.resetCheckBox();
        setBadgeCount();
    }

    private void setBadgeCount() {
        if (AppInfo.ENABLE_MULTIPLE_WISHLIST || AppInfo.ENABLE_SINGLE_CHECK_WISHLIST || ImageDownloaderConfig.isEnabled()) {
            int count = getItemCount();
            selected_product_count_text.setText(String.valueOf(count));
            selected_product_count_text.setVisibility(count > 0 ? View.VISIBLE : View.GONE);
            icon_badge_item_count.setVisibility(count > 0 ? View.VISIBLE : View.GONE);
            if (count > 0)
                showDownloadPanel();
            else
                hideDownloadPanel();
        }
    }

    private int getItemCount() {
        HashMap<Integer, Boolean> map = adapter.mCheckedItem;
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

    private void hideDownloadPanel() {
        if (downloadPanel.getVisibility() != View.GONE) {
            downloadPanel.animate()
                    //.translationY(-downloadPanel.getHeight())
                    .translationY(0)
                    .alpha(0.0f)
                    .setDuration(300)
                    .setListener(new AnimatorListenerAdapter() {
                        @Override
                        public void onAnimationEnd(Animator animation) {
                            super.onAnimationEnd(animation);
                            downloadPanel.setVisibility(View.GONE);
                        }
                    });
        }
        Helper.hideSelectMultipleActionButtons(downloadPanel);
    }

    private void hideDownloadPanelInitially() {
        downloadPanel.setVisibility(View.GONE);
    }

    private void showDownloadPanel() {
        if (downloadPanel.getVisibility() != View.VISIBLE) {
            downloadPanel.setVisibility(View.VISIBLE);
            downloadPanel.animate()
                    .translationY(0)
                    .alpha(1.0f)
                    .setDuration(300)
                    .setListener(new AnimatorListenerAdapter() {
                        @Override
                        public void onAnimationEnd(Animator animation) {
                            super.onAnimationEnd(animation);
                        }
                    });
        }
        Helper.hideSelectMultipleActionButtons(downloadPanel);
    }

    private void openWishGroupListAndAddProduct() {
        HashMap<Integer, Boolean> map = adapter.mCheckedItem;
        for (Map.Entry<Integer, Boolean> entry : map.entrySet()) {
            Integer key = entry.getKey();
            Boolean value = entry.getValue();
            TM_ProductInfo product = TM_ProductInfo.getProductWithId(key);
            if (product != null && value) {
                WishListGroup.selectedProductToAddInWishList.add(product);
            }
        }
    }

    private void initDownloadTask() {
        adapter.downloadAllSelected(getWishGroup());
        refreshAllAdapters();
    }

    private void initAddtoMultipleList() {
        openWishGroupListAndAddProduct();
        if (WishListGroup.selectedProductToAddInWishList.size() == 0) {
            Helper.toast(L.string.no_products);
            return;
        }

        Fragment_Wishlist_Dialog.OpenWishGroupDialogWishCheckbox(WishListGroup.selectedProductToAddInWishList, new WishListDialogHandler() {
            @Override
            public void onSelectGroupSuccess(TM_ProductInfo product, WishListGroup obj) {

                WishListGroup.selectedProductToAddInWishList.clear();
                refreshAllAdapters();
            }

            @Override
            public void onSelectGroupFailed(String cause) {

            }

            @Override
            public void onSkipDialog(TM_ProductInfo product, WishListGroup obj) {

            }
        });
    }

    private void initAddtoCart() {
        if (AppInfo.mGuestUserConfig != null && AppInfo.mGuestUserConfig.isEnabled() && AppInfo.mGuestUserConfig.isPreventCart() && AppUser.isAnonymous()) {
            Helper.toast(L.string.you_need_to_login_first);
            return;
        }
        openWishGroupListAndAddProduct();

        if (WishListGroup.selectedProductToAddInWishList.size() == 0) {
            Helper.toast(L.string.no_products);
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
                    refreshAllAdapters();
                    Helper.toast(getString(L.string.item_added_to_cart));
                    return false;
                }
            });
        } else {
            for (TM_ProductInfo product : addprodtocart) {
                Cart.addProduct(product);
            }
            WishListGroup.selectedProductToAddInWishList.clear();
            refreshAllAdapters();
            Helper.toast(getString(L.string.item_added_to_cart));
        }

    }

    private void initDeleteAll() {
        openWishGroupListAndAddProduct();
        if (WishListGroup.selectedProductToAddInWishList.size() == 0) {
            Helper.toast(L.string.no_products);
            return;
        }

        final WishListGroup wishListGroup = getWishGroup();
        if (AppUser.hasSignedIn() && AppInfo.ENABLE_MULTIPLE_WISHLIST) {

            List<WishListGroup> mylist = new ArrayList<>();
            if (wishListGroup != null) {
                wishListGroup.isChecked = true;
                mylist.add(wishListGroup);
            }

            String str = WishListGroup.getProductWishKeyArrayString(mylist, WishListGroup.selectedProductToAddInWishList);
            showProgress(getString(L.string.please_wait));
            WishListGroup.deleteMultipleProductFromWishlist(wishListGroup.id, str, new DataQueryHandler() {
                @Override
                public void onSuccess(Object data) {

                    hideProgress();
                    refreshAllAdapters();
                    WishListGroup.selectedProductToAddInWishList.clear();
                    Helper.toast(Helper.showItemRemovedToWishListToast(wishListGroup.title));
                    MainActivity.mActivity.openWishlistFragment(true);
                }

                @Override
                public void onFailure(Exception error) {
                    WishListGroup.selectedProductToAddInWishList.clear();
                    hideProgress();
                    showProgress(getString(L.string.retry));
                }
            });
        } else {

            if (adapter.allChecked.size() > 0) {
                adapter.removeAllChecked();
            } else
                Helper.toast(getString(L.string.no_products));

            //Helper.toast(getString(L.string.item_removed_from_wishlist));
            refreshAllAdapters();
            WishListGroup.selectedProductToAddInWishList.clear();
            MainActivity.mActivity.reloadMenu();
        }
    }

    private void initDelete() {
        openWishGroupListAndAddProduct();
        if (WishListGroup.selectedProductToAddInWishList.size() == 0) {
            Helper.toast(L.string.no_products);
            return;
        }

        final WishListGroup wishListGroup = getWishGroup();
        if (AppUser.hasSignedIn() && AppInfo.ENABLE_MULTIPLE_WISHLIST) {

            List<WishListGroup> mylist = new ArrayList<>();
            if (wishListGroup != null) {
                wishListGroup.isChecked = true;
                mylist.add(wishListGroup);
            }

            String str = WishListGroup.getProductWishKeyArrayString(mylist, WishListGroup.selectedProductToAddInWishList);
            showProgress(getString(L.string.please_wait));
            WishListGroup.deleteMultipleProductFromWishlist(wishListGroup.id, str, new DataQueryHandler() {
                @Override
                public void onSuccess(Object data) {

                    hideProgress();
                    refreshAllAdapters();
                    WishListGroup.selectedProductToAddInWishList.clear();
                    Helper.toast(Helper.showItemRemovedToWishListToast(wishListGroup.title));
                    MainActivity.mActivity.openWishlistFragment(true);
                }

                @Override
                public void onFailure(Exception error) {
                    WishListGroup.selectedProductToAddInWishList.clear();
                    hideProgress();
                    showProgress(getString(L.string.retry));
                }
            });
        } else {

            if (adapter.allChecked.size() > 0) {
                adapter.removeAllChecked();
            } else
                Helper.toast(getString(L.string.no_products));

            //Helper.toast(getString(L.string.item_removed_from_wishlist));
            refreshAllAdapters();
            WishListGroup.selectedProductToAddInWishList.clear();
            MainActivity.mActivity.reloadMenu();
        }
    }

    private void initAddtoSingleList() {
        openWishGroupListAndAddProduct();
        if (WishListGroup.selectedProductToAddInWishList.size() == 0) {
            Helper.toast(L.string.no_products);
            return;
        }
        final WishListGroup wishListGroup = WishListGroup.getWishListGroupById(WishListGroup.getdefaultWishGroupID());
        if (AppUser.hasSignedIn()) {
            List<WishListGroup> mylist = new ArrayList<>();
            if (wishListGroup != null) {
                wishListGroup.isChecked = true;
                mylist.add(wishListGroup);
            }

            String str = WishListGroup.getPidsArrayString(mylist, WishListGroup.selectedProductToAddInWishList);

            showProgress(getString(L.string.please_wait));
            WishListGroup.addProductsToMultipleWishList(str, new DataQueryHandler() {
                @Override
                public void onSuccess(Object data) {
                    hideProgress();
                    WishListGroup.selectedProductToAddInWishList.clear();
                    refreshAllAdapters();
                    Helper.toast(Helper.showItemAddedToWishListToast(wishListGroup));
                }

                @Override
                public void onFailure(Exception error) {
                    WishListGroup.selectedProductToAddInWishList.clear();
                    hideProgress();
                    showProgress(getString(L.string.retry));
                }
            });
        } else {
            for (TM_ProductInfo product : WishListGroup.selectedProductToAddInWishList) {
                if (!WishListGroup.hasChild(wishListGroup.id, product))
                    Wishlist.addProduct(product, wishListGroup);
            }
            Helper.toast(Helper.showItemAddedToWishListToast(wishListGroup));
            WishListGroup.selectedProductToAddInWishList.clear();
            refreshAllAdapters();
            MainActivity.mActivity.reloadMenu();
        }
    }

    private void initShare() {
        new AsyncTask<Void, Void, ArrayList<Uri>>() {
            @Override
            protected ArrayList<Uri> doInBackground(Void... voids) {
                showProgress(getString(L.string.loading), false);
                return Helper.getImageUriList(getActivity(), adapter.mCheckedItem);
            }

            @Override
            protected void onPostExecute(ArrayList<Uri> result) {
                super.onPostExecute(result);
                Helper.shareOnWhatsApp("", result);
                hideProgress();
                adapter.checkMode = false;
                refreshAllAdapters();
            }
        }.execute();

    }
}
