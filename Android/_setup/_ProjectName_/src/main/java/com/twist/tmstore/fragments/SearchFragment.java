package com.twist.tmstore.fragments;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Bundle;
import android.support.design.widget.FloatingActionButton;
import android.support.v7.widget.GridLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.SearchView;
import android.support.v7.widget.StaggeredGridLayoutManager;
import android.text.InputType;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;

import com.twist.dataengine.DataQueryHandler;
import com.twist.dataengine.DataEngine;;
import com.twist.dataengine.entities.TM_ProductInfo;
import com.twist.tmstore.BaseActivity;
import com.twist.tmstore.BaseFragment;
import com.twist.tmstore.L;
import com.twist.tmstore.MainActivity;
import com.twist.tmstore.R;
import com.twist.tmstore.adapters.Adapter_Products;
import com.twist.tmstore.config.ImageDownloaderConfig;
import com.twist.tmstore.entities.AppInfo;
import com.twist.tmstore.entities.AppUser;
import com.twist.tmstore.entities.Cart;
import com.twist.tmstore.entities.RecentSearchItem;
import com.twist.tmstore.entities.WishListGroup;
import com.twist.tmstore.entities.Wishlist;
import com.twist.tmstore.listeners.BackKeyListener;
import com.twist.tmstore.listeners.WishGroupCreatedListener;
import com.twist.tmstore.listeners.WishListDialogHandler;
import com.utils.AnalyticsHelper;
import com.utils.Helper;
import com.utils.ImageDownload;
import com.utils.SearchHandler;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class SearchFragment extends BaseFragment {
    private RecyclerView productsRecyclerView;
    private Adapter_Products productsAdapter;
    private ArrayAdapter<String> recentSearchItemAdapter;
    private ListView recentItemsListView;
    private View recent_section;
    private ProgressBar progressBar;
    private SearchView mSearchView;
    private BaseActivity mActivity;
    private SearchHandler mSearchHandler;
    private TextView selected_product_count_text;
    private ImageView icon_badge_item_count;
    private ViewGroup downloadPanel;
    private View rootView;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    public static SearchFragment newInstance() {
        return new SearchFragment();
    }

    public SearchFragment() {
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        mActivity = (BaseActivity) getActivity();
        mSearchHandler = new SearchHandler();

        rootView = inflater.inflate(R.layout.fragment_search, container, false);

        setActionBarHomeAsUpIndicator();
        setTitle(getString(L.string.title_search));

        addBackKeyListenerOnView(rootView, new BackKeyListener() {
            @Override
            public void onBackPressed() {
                closeSearch();
            }
        });

        progressBar = (ProgressBar) rootView.findViewById(R.id.progressBar);
        progressBar.setVisibility(View.GONE);

        recent_section = rootView.findViewById(R.id.recent_section);
        productsRecyclerView = (RecyclerView) rootView.findViewById(R.id.recyclerView);
        recentItemsListView = (ListView) rootView.findViewById(R.id.list_recent_items);
        recentItemsListView.setVisibility(View.VISIBLE);

        TextView textViewRecentSearches = (TextView) rootView.findViewById(R.id.recent_searches);
        textViewRecentSearches.setText(getString(L.string.recent_searches));

        TextView empty_recent_text = (TextView) rootView.findViewById(R.id.empty_recent_text);
        empty_recent_text.setText(getString(L.string.no_recent_item));

        recentSearchItemAdapter = new ArrayAdapter<>(getActivity(), R.layout.item_recentsearch, RecentSearchItem.getAllString());
        recentItemsListView.setAdapter(recentSearchItemAdapter);
        recentItemsListView.setEmptyView(empty_recent_text);

        productsAdapter = new Adapter_Products((BaseActivity) getActivity(), TM_ProductInfo.getAll(), null, new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                setBadgeCount();
            }
        });
        productsRecyclerView = (RecyclerView) rootView.findViewById(R.id.recyclerView);

        final int columnCount = Adapter_Products.getProductLayoutColumnCount();
        RecyclerView.LayoutManager mLayoutManager;
        if (AppInfo.ID_LAYOUT_PRODUCTS == 3) {
            mLayoutManager = new StaggeredGridLayoutManager(columnCount, StaggeredGridLayoutManager.VERTICAL);
            ((StaggeredGridLayoutManager) mLayoutManager).setGapStrategy(StaggeredGridLayoutManager.GAP_HANDLING_MOVE_ITEMS_BETWEEN_SPANS);
            productsRecyclerView.setLayoutManager(mLayoutManager);
        } else {
            mLayoutManager = new GridLayoutManager(getActivity(), columnCount);
            productsRecyclerView.setLayoutManager(mLayoutManager);
        }
        productsRecyclerView.setHasFixedSize(false);
        productsRecyclerView.setAdapter(productsAdapter);
        productsRecyclerView.setVisibility(View.GONE);

        setUpSearch(rootView);

        initDownloadPanel();

        getBaseActivity().restoreActionBar();
        getBaseActivity().invalidateOptionsMenu();

        return rootView;
    }

    void initDownloadPanel() {
        if (AppInfo.ENABLE_MULTIPLE_WISHLIST || AppInfo.ENABLE_SINGLE_CHECK_WISHLIST || ImageDownloaderConfig.isEnabled()) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                downloadPanel = ((ViewGroup) rootView.findViewById(R.id.dynamic_panel));
                FloatingActionButton btn_action = ((FloatingActionButton) rootView.findViewById(R.id.btn_action));
                Helper.stylize(btn_action);
                downloadPanel.setOnClickListener(new View.OnClickListener() {
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
                downloadPanel = (ViewGroup) getDownloadPanel((ViewGroup) rootView.findViewById(R.id.dynamic_panel_v20));
            }

            selected_product_count_text = (TextView) downloadPanel.findViewById(R.id.selected_product_count_text);
            icon_badge_item_count = (ImageView) downloadPanel.findViewById(R.id.icon_badge);
            Helper.stylizeBadgeView(icon_badge_item_count, selected_product_count_text);
            hideDownloadPanelInitially();
        }
    }

    private void closeSearch() {
        if (mSearchView != null) {
            mSearchView.onActionViewCollapsed();
        }

        if (mActivity != null) {
            mActivity.getFM().popBackStack();
        }
    }

    private void setUpSearch(View rootView) {
        mSearchView = (SearchView) rootView.findViewById(R.id.searchView);
        if (mSearchView == null) {
            return;
        }

        mSearchView.setIconifiedByDefault(false);
        mSearchView.setInputType(InputType.TYPE_TEXT_FLAG_NO_SUGGESTIONS);
        mSearchView.setVisibility(View.VISIBLE);
        mSearchView.setOnQueryTextFocusChangeListener(new View.OnFocusChangeListener() {
            @Override
            public void onFocusChange(View view, boolean hasFocus) {
                if (hasFocus) {
                    mSearchHandler.handleSearchViewFocus(view, hasFocus);
                }
            }
        });
        mSearchView.setQueryHint(getString(L.string.txt_search_hint));
        mSearchView.setOnQueryTextListener(new SearchView.OnQueryTextListener() {
            @Override
            public boolean onQueryTextSubmit(String query) {
                query = query.toLowerCase();
                productsAdapter.getTextFilter().filter(query);
                new RecentSearchItem(query);
                progressBar.setVisibility(View.VISIBLE);
                final String finalQuery = query;
                DataEngine.getDataEngine().getProductsWithTag(finalQuery, new DataQueryHandler<List<TM_ProductInfo>>() {
                    @Override
                    public void onSuccess(List<TM_ProductInfo> data) {
                        AnalyticsHelper.registerSearchEvent(finalQuery, !data.isEmpty());
                        productsAdapter.updateResult(data);
                        progressBar.setVisibility(View.GONE);
                    }

                    @Override
                    public void onFailure(Exception reason) {
                        progressBar.setVisibility(View.GONE);
                    }
                });
                return false;
            }

            @Override
            public boolean onQueryTextChange(String newText) {
                progressBar.setVisibility(View.GONE);
                final String searchText = newText.toLowerCase();
                if (TextUtils.isEmpty(searchText)) {
                    recent_section.setVisibility(View.VISIBLE);
                    productsRecyclerView.setVisibility(View.GONE);
                    recentSearchItemAdapter.clear();
                    recentSearchItemAdapter.addAll(RecentSearchItem.getAllString());
                    productsAdapter.updateResult(TM_ProductInfo.getAll());
                    return false;
                } else {
                    productsRecyclerView.setVisibility(View.VISIBLE);
                    recent_section.setVisibility(View.GONE);
                    productsAdapter.getTextFilter().filter(searchText);
                    return true;
                }
            }
        });

        mSearchView.setOnCloseListener(new SearchView.OnCloseListener() {
            @Override
            public boolean onClose() {
                progressBar.setVisibility(View.GONE);
                closeSearch();
                return false;
            }
        });

        recentItemsListView.setOnItemClickListener(new OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                productsRecyclerView.setVisibility(View.VISIBLE);
                recent_section.setVisibility(View.GONE);
                String text = (((TextView) view).getText()).toString();
                mSearchView.setQuery(text, true);
                mSearchView.clearFocus();
                productsAdapter.getTextFilter().filter(text);
                new RecentSearchItem(text);
            }
        });
    }

    @Override
    public void onPause() {
        super.onPause();
        if (mSearchView != null) {
            Helper.hideKeyboard(mSearchView);
        }
    }

    public void onViewCreated(View view, Bundle bundle) {
        super.onViewCreated(view, bundle);
        if (mSearchView != null) {
            mSearchView.requestFocus();
        }
    }

    private int getItemCount() {
        int count = 0;
        for (Map.Entry<Integer, Boolean> entry : productsAdapter.getCheckedItems().entrySet()) {
            Boolean value = entry.getValue();
            if (value) {
                count++;
            }
        }
        return count;
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

    private void showDownloadChkBoxesInAdapter() {
        productsAdapter.setCheckMode(true);
    }

    private void hideDownloadPanel() {
        if (downloadPanel.getVisibility() != View.GONE) {
            downloadPanel.animate()
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

    private View getDownloadPanel(final ViewGroup parent) {
        return Helper.getDownloadPanel(parent, new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                showDownloadChkBoxesInAdapter();
            }
        }, new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Helper.showSelectMultipleMenu(parent, false, new View.OnClickListener() {
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
        refreshAllAdapters();
    }

    private void startDownloadTask() {
        boolean isStarted = false;
        HashMap<Integer, Boolean> map = Adapter_Products.mCheckedItem;
        for (Map.Entry<Integer, Boolean> entry : map.entrySet()) {
            Integer key = entry.getKey();
            TM_ProductInfo product = TM_ProductInfo.getProductWithId(key);
            if (product != null && entry.getValue()) {
                isStarted = true;
                ImageDownload.downloadProductCatalog(getActivity(), product);
            }
        }
        Toast.makeText(getActivity(), isStarted ? getString(L.string.download_initiated) : getString(L.string.no_products), Toast.LENGTH_SHORT).show();
        refreshAllAdapters();
    }

    public void refreshAllAdapters() {
        productsAdapter.resetAdapterForCheckBox();
        setBadgeCount();
    }

    private void initDownloadTask() {
        startDownloadTask();
    }

    private void initAddtoMultipleList() {
        openWishGroupListAndAddProduct();
        if (WishListGroup.selectedProductToAddInWishList.size() == 0) {
            Helper.toast(L.string.no_products);
            refreshAllAdapters();
            return;
        }

        Fragment_Wishlist_Dialog.OpenWishGroupDialogWishCheckbox(WishListGroup.selectedProductToAddInWishList, new WishListDialogHandler() {
            @Override
            public void onSelectGroupSuccess(TM_ProductInfo product, WishListGroup obj) {
                WishListGroup.selectedProductToAddInWishList.clear();
                refreshAllAdapters();
                MainActivity.mActivity.popBackWishFragment();
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
            refreshAllAdapters();
            return;
        }
        openWishGroupListAndAddProduct();

        if (WishListGroup.selectedProductToAddInWishList.size() == 0) {
            Helper.toast(L.string.no_products);
            refreshAllAdapters();
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
                    return false;
                }
            });
        } else {
            for (TM_ProductInfo product : addprodtocart) {
                Cart.addProduct(product);
            }
            WishListGroup.selectedProductToAddInWishList.clear();
            Helper.toast(getString(L.string.item_added_to_cart));
            refreshAllAdapters();
        }
    }

    private void addProductstoWishList(final WishListGroup wishListGroup) {

        List<WishListGroup> mylist = new ArrayList<>();
        wishListGroup.isChecked = true;
        mylist.add(wishListGroup);

        String str = WishListGroup.getPidsArrayString(mylist, WishListGroup.selectedProductToAddInWishList);
        showProgress(getString(L.string.please_wait));
        WishListGroup.addProductsToMultipleWishList(str, new DataQueryHandler() {
            @Override
            public void onSuccess(Object data) {
                hideProgress();
                refreshAllAdapters();
                WishListGroup.selectedProductToAddInWishList.clear();
                Helper.toast(Helper.showItemAddedToWishListToast(wishListGroup));
                MainActivity.mActivity.popBackWishFragment();
            }

            @Override
            public void onFailure(Exception error) {
                hideProgress();
                showProgress(getString(L.string.retry));
            }
        });

    }

    private void initAddtoSingleList() {
        openWishGroupListAndAddProduct();
        if (WishListGroup.selectedProductToAddInWishList.size() == 0) {
            Helper.toast(L.string.no_products);
            refreshAllAdapters();
            return;
        }

        final WishListGroup wishListGroup = WishListGroup.getWishListGroupById(WishListGroup.getdefaultWishGroupID());

        if (AppUser.hasSignedIn() && AppInfo.ENABLE_MULTIPLE_WISHLIST) {

            if (wishListGroup != null) {
                addProductstoWishList(wishListGroup);
            } else {
                MainActivity.mActivity.openWishlistFragment(false);
                Fragment_Wishlist_Dialog.setOnWishGroupCreatedListener(new WishGroupCreatedListener() {
                    @Override
                    public boolean onSuccess(WishListGroup wg) {
                        addProductstoWishList(wg);
                        return false;
                    }
                });
            }
        } else {
            if (AppInfo.ENABLE_SINGLE_CHECK_WISHLIST) {
                if (WishListGroup.allwishListGroup.size() > 0) {
                    for (TM_ProductInfo product : WishListGroup.selectedProductToAddInWishList) {
                        if (!WishListGroup.hasChild(wishListGroup.id, product) && Wishlist.addProduct(product, wishListGroup)) {
                        }
                    }
                    WishListGroup.selectedProductToAddInWishList.clear();
                    Helper.toast(getString(L.string.item_added_to_wishlist));
                    refreshAllAdapters();
                    MainActivity.mActivity.reloadMenu();
                    MainActivity.mActivity.popBackWishFragment();
                } else {
                    MainActivity.mActivity.openWishlistFragment(false);
                    Fragment_Wishlist_Dialog.setOnWishGroupCreatedListener(new WishGroupCreatedListener() {
                        @Override
                        public boolean onSuccess(WishListGroup wishListGroup) {
                            for (TM_ProductInfo product : WishListGroup.selectedProductToAddInWishList) {
                                if (!WishListGroup.hasChild(wishListGroup.id, product) && Wishlist.addProduct(product, wishListGroup)) {
                                }
                            }
                            WishListGroup.selectedProductToAddInWishList.clear();
                            Helper.toast(getString(L.string.item_added_to_wishlist));
                            refreshAllAdapters();
                            MainActivity.mActivity.reloadMenu();
                            MainActivity.mActivity.popBackWishFragment();
                            return false;
                        }
                    });
                }
            } else {
                for (TM_ProductInfo product : WishListGroup.selectedProductToAddInWishList) {
                    Wishlist.addProduct(product, wishListGroup);
                }
                WishListGroup.selectedProductToAddInWishList.clear();
                Helper.toast(getString(L.string.item_added_to_wishlist));
                refreshAllAdapters();
                MainActivity.mActivity.reloadMenu();
            }
        }
    }

    private void initShare() {
        new AsyncTask<Void, Void, ArrayList<Uri>>() {
            @Override
            protected ArrayList<Uri> doInBackground(Void... voids) {
                showProgress(getString(L.string.loading), false);
                return Helper.getImageUriList(getActivity(), Adapter_Products.mCheckedItem);
            }

            @Override
            protected void onPostExecute(ArrayList<Uri> result) {
                super.onPostExecute(result);
                Helper.shareOnWhatsApp("", result);
                hideProgress();
                productsAdapter.checkMode = false;
                refreshAllAdapters();
            }
        }.execute();
    }

}