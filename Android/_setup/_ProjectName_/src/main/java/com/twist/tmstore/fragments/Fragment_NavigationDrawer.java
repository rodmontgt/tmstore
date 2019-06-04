package com.twist.tmstore.fragments;

import android.content.Context;
import android.content.res.Configuration;
import android.graphics.Color;
import android.os.Bundle;
import android.support.v4.app.FragmentManager;
import android.support.v4.view.GravityCompat;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.app.ColorableActionBarDrawerToggle;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.Toolbar;
import android.text.TextUtils;
import android.text.method.LinkMovementMethod;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.twist.dataengine.entities.MenuInfo;
import com.twist.dataengine.entities.MenuOption;
import com.twist.dataengine.entities.TM_CategoryInfo;
import com.twist.tmstore.BaseFragment;
import com.twist.tmstore.BuildConfig;
import com.twist.tmstore.Constants;
import com.twist.tmstore.L;
import com.twist.tmstore.MainActivity;
import com.twist.tmstore.R;
import com.twist.tmstore.adapters.Adapter_NavigationDrawer;
import com.twist.tmstore.config.ContactForm3Config;
import com.twist.tmstore.config.FreshChatConfig;
import com.twist.tmstore.config.GuestUserConfig;
import com.twist.tmstore.config.MultiVendorConfig;
import com.twist.tmstore.config.NavDrawerConfig;
import com.twist.tmstore.config.ReservationFormConfig;
import com.twist.tmstore.config.SponsorFriendConfig;
import com.twist.tmstore.config.WordPressMenuConfig;
import com.twist.tmstore.entities.AppInfo;
import com.twist.tmstore.entities.AppUser;
import com.twist.tmstore.entities.NavDrawItem;
import com.twist.tmstore.listeners.NavigationDrawerCallbacks;
import com.utils.ArrayUtils;
import com.utils.Helper;
import com.utils.HtmlCompat;
import com.utils.customviews.utility.FlexibleDividerDecoration;
import com.utils.customviews.utility.HorizontalDividerItemDecoration;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;

public class Fragment_NavigationDrawer extends BaseFragment {

    private NavigationDrawerCallbacks mCallbacks;
    private ColorableActionBarDrawerToggle mDrawerToggle;
    private DrawerLayout mDrawerLayout;
    private RecyclerView mDrawerListView;
    private View mFragmentContainerView;
    private ActionBar mActionBar;
    private List<NavDrawItem> drawerItems = new ArrayList<>();
    private Adapter_NavigationDrawer mDrawerListAdapter;
    private boolean isDrawerEnabled = true;
    private TextView mTextNavDrawerFooter;

    public Fragment_NavigationDrawer() {
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        setHasOptionsMenu(true);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View mDrawerView = inflater.inflate(R.layout.fragment_navdrawer, container, false);

        ImageView seasonalGreetingImage = mDrawerView.findViewById(R.id.image_seasonal_greeting);
        seasonalGreetingImage.setVisibility(AppInfo.SHOW_SEASONAL_GREETINGS ? View.VISIBLE : View.GONE);

        mDrawerListView = mDrawerView.findViewById(R.id.drawer_recycler_view);
        mDrawerListView.setNestedScrollingEnabled(false);

        NavDrawerConfig navDrawerConfig = NavDrawerConfig.getInstance();
        if (navDrawerConfig.enabled) {
            mDrawerListView.setBackgroundColor(Color.parseColor(navDrawerConfig.bgColor));
            final NavDrawerConfig.MainMenuConfig mainMenuConfig = navDrawerConfig.getMainMenuConfig();
            if (mainMenuConfig.enabled && mainMenuConfig.dividerHeight > 0) {
                mDrawerListView.addItemDecoration(new HorizontalDividerItemDecoration.Builder(getActivity())
                        .size(Helper.DP(mainMenuConfig.dividerHeight))
                        .color(Color.parseColor(mainMenuConfig.dividerColor))
//                        .visibilityProvider(new FlexibleDividerDecoration.VisibilityProvider() {
//                            @Override
//                            public boolean shouldHideDivider(int position, RecyclerView parent) {
//                                return ArrayUtils.contains(mainMenuConfig.hideDividers, position);
//                            }
//                        })
                        .build());
            }
        } else {
            mDrawerListView.addItemDecoration(new HorizontalDividerItemDecoration.Builder(getActivity()).build());
        }
        mTextNavDrawerFooter = mDrawerView.findViewById(R.id.text_navdrawer_footer);
        mTextNavDrawerFooter.setVisibility(View.GONE);
        return mDrawerView;
    }

    private void setupDrawerComponents() {
        mDrawerListAdapter = new Adapter_NavigationDrawer(getActivity(), drawerItems, new NavigationDrawerCallbacks() {
            @Override
            public void onNavigationDrawerItemSelected(int itemId, int position) {
                selectItem(itemId, position);
            }
        });
        mDrawerListView.setAdapter(mDrawerListAdapter);

        drawerItems.add(new NavDrawItem(Constants.MENU_ID_PROFILE_FULL));

        if (AppInfo.drawerItems != null) {
            for (NavDrawItem item : AppInfo.drawerItems) {
                if (item.getId() == Constants.MENU_ID_ORDERS && AppUser.isAnonymous() && (AppInfo.mGuestUserConfig == null || !GuestUserConfig.isGuestCheckout() || GuestUserConfig.isPreventMyOrders()))
                    continue;
                if (item.getId() == Constants.MENU_ID_SIGN_OUT && AppUser.isAnonymous())
                    continue;
                if (item.getId() == Constants.MENU_ID_SIGN_IN && !AppUser.isAnonymous())
                    continue;
                if (item.getId() == Constants.MENU_ID_SELLER_INFO && !AppUser.isAnonymous())
                    continue;
                if (item.getId() == Constants.MENU_ID_FRESH_CHAT && !FreshChatConfig.shouldShowInDrawer())
                    continue;
                if (item.getId() == Constants.MENU_ID_SETTINGS && (!AppInfo.ENABLE_LOCALIZATION && !AppInfo.ENABLE_CURRENCY_SWITCHER))
                    continue;
                if (item.getId() == Constants.MENU_ID_CHANGE_MERCHANT)
                    continue;
                if (item.getId() == Constants.MENU_ID_CHANGE_SELLER && !(MultiVendorConfig.isEnabled() && MultiVendorConfig.getScreenType() == MultiVendorConfig.ScreenType.VENDORS))
                    continue;
                if (item.getId() == Constants.MENU_ID_SELLER_HOME && !(MultiVendorConfig.isEnabled() && (AppUser.isVendor() || AppUser.isPendingVendor())))
                    continue;
                if (item.getId() == Constants.MENU_ID_REFER_FRIEND && !SponsorFriendConfig.getInstance().isEnabled())
                    continue;
                if (item.getId() == Constants.MENU_ID_RATE_APP && !AppInfo.ENABLE_APP_RATING)
                    continue;
                if (item.getId() == Constants.MENU_ID_CART && (!AppInfo.ENABLE_CART || !GuestUserConfig.isEnableCart()))
                    continue;
                if (item.getId() == Constants.MENU_ID_MY_COUPONS && (!AppInfo.ENABLE_COUPONS || AppInfo.HIDE_COUPON_LIST))
                    continue;
                if (item.getId() == Constants.MENU_ID_NOTIFICATIONS && AppInfo.HIDE_NOTIFICATIONS_LIST)
                    continue;
                if (item.getId() == Constants.MENU_ID_SCAN_PRODUCT && !BuildConfig.MULTI_STORE)
                    continue;
                if (item.getId() == Constants.MENU_ID_RESERVATION_FORM && !ReservationFormConfig.isEnabled())
                    continue;
                if (item.getId() == Constants.MENU_ID_CONTACT_FORM3 && !ContactForm3Config.isEnabled())
                    continue;
                if (item.getId() == Constants.MENU_ID_WISH && !AppInfo.ENABLE_WISHLIST)
                    continue;

                if (item.getId() != Constants.MENU_ID_GROUPS)
                    item.updateName();

                switch (item.getId()) {
                    case Constants.MENU_ID_CATEGORIES:
                        addCategories(item);
                        break;
                    case Constants.MENU_ID_GROUPS:
                        addGroupItems(item);
                        break;
                    case Constants.MENU_ID_WP_MENU:
                        addMenuItems();
                        break;
                    case Constants.MENU_ID_FOOTER_ITEM:
                        addFooterMenu(item);
                        break;
                    default: {
                        if (!TextUtils.isEmpty(item.getRole())) {
                            if (AppUser.hasSignedIn() && item.getRole().equals(AppUser.getRoleType().getValue())) {
                                drawerItems.add(item);
                            }
                        } else {
                            drawerItems.add(item);
                        }

                    }
                }
            }
        }

        mDrawerListAdapter = new Adapter_NavigationDrawer(getActivity(), drawerItems, new NavigationDrawerCallbacks() {
            @Override
            public void onNavigationDrawerItemSelected(int itemId, int position) {
                selectItem(itemId, position);
            }
        });
        mDrawerListView.setAdapter(mDrawerListAdapter);
    }

    private void addFooterMenu(NavDrawItem item) {
        NavDrawerConfig navDrawerConfig = NavDrawerConfig.getInstance();
        NavDrawerConfig.MainMenuConfig mainMenuConfig = navDrawerConfig.getMainMenuConfig();
        if (navDrawerConfig.enabled && mainMenuConfig.enabled) {
            mTextNavDrawerFooter.setBackgroundColor(Color.parseColor(navDrawerConfig.bgColor));
            mTextNavDrawerFooter.setAllCaps(mainMenuConfig.titleCapsAll);
            mTextNavDrawerFooter.setTextColor(Color.parseColor(mainMenuConfig.titleTextColor));
        }
        mTextNavDrawerFooter.setVisibility(View.VISIBLE);
        mTextNavDrawerFooter.setGravity(Gravity.CENTER);
        mTextNavDrawerFooter.setText(HtmlCompat.fromHtml(item.getName()));
        mTextNavDrawerFooter.setMovementMethod(LinkMovementMethod.getInstance());
    }

    public void addGroupItems(NavDrawItem navDrawItem) {
        List<Object> header = new ArrayList<>();
        HashMap<NavDrawItem, List<Object>> child = new HashMap<>();
        header.addAll(navDrawItem.getHeader());
        child.put(navDrawItem, new ArrayList<>());

        NavDrawItem _navDrawItem = new NavDrawItem(
                Constants.MENU_ID_GROUPS,
                navDrawItem.getName(),
                R.drawable.ic_vc_link,
                header,
                child);
        _navDrawItem.setShowIcon(_navDrawItem.isShowIcon());
        drawerItems.add(_navDrawItem);
    }

    public void addCategories(NavDrawItem categoryItem) {
        if (!AppInfo.SHOW_NESTED_CATEGORY_MENU) {
            addAllCategories(categoryItem);
            return;
        }
        if (drawerItems == null) {
            return;
        }

        final List<TM_CategoryInfo> header = new ArrayList<>();
        final HashMap<TM_CategoryInfo, List<TM_CategoryInfo>> child = new HashMap<>();
        List<TM_CategoryInfo> rootCategories = TM_CategoryInfo.getAllRootCategories();

        List<TM_CategoryInfo> sortedCategories = new ArrayList<>();
        if (rootCategories != null) {
            int[] sortOrder = categoryItem.getSortOrder();
            if (sortOrder != null && sortOrder.length != 0) {
                for (int sortedCategoryId : sortOrder) {
                    for (TM_CategoryInfo category : rootCategories) {
                        if (category.id == sortedCategoryId) {
                            sortedCategories.add(category);
                            break;
                        }
                    }
                }
            }
        }

        if (sortedCategories.isEmpty()) {
            sortedCategories = rootCategories;
        }

        if (sortedCategories != null) {
            header.addAll(sortedCategories);
            for (TM_CategoryInfo rootCategory : sortedCategories) {
                child.put(rootCategory, rootCategory.getSubCategories());
            }
        }

        NavDrawItem navDrawItem = new NavDrawItem(
                Constants.MENU_ID_CATEGORIES,
                categoryItem.getName(),
                categoryItem.getIconId(),
                header,
                child);
        navDrawItem.setShowIcon(categoryItem.isShowIcon());
        drawerItems.add(navDrawItem);
    }

    public void addAllCategories(NavDrawItem categoryItem) {
        if (drawerItems == null) {
            return;
        }
        List<TM_CategoryInfo> categories = TM_CategoryInfo.getAllRootCategories();

        List<TM_CategoryInfo> sortedCategories = new ArrayList<>();
        if (categories != null) {
            int[] sortOrder = categoryItem.getSortOrder();
            if (sortOrder != null && sortOrder.length != 0) {
                for (int sortedCategoryId : sortOrder) {
                    for (TM_CategoryInfo category : categories) {
                        if (category.id == sortedCategoryId) {
                            sortedCategories.add(category);
                            break;
                        }
                    }
                }
            }
        }

        if (sortedCategories.isEmpty()) {
            sortedCategories = categories;
        }

        if (sortedCategories != null) {
            for (TM_CategoryInfo category : sortedCategories) {
                List<TM_CategoryInfo> header = new ArrayList<>();
                List<TM_CategoryInfo> rootCategories = category.getSubCategories();
                header.addAll(rootCategories);
                HashMap<TM_CategoryInfo, List<TM_CategoryInfo>> child = new HashMap<>();
                for (TM_CategoryInfo childCategory : rootCategories) {
                    child.put(childCategory, childCategory.getSubCategories());
                }
                NavDrawItem navDrawItem = new NavDrawItem(
                        Constants.MENU_ID_CATEGORIES,
                        category.getName(),
                        categoryItem.getIconId(),
                        header, child);
                navDrawItem.setShowIcon(categoryItem.isShowIcon());
                drawerItems.add(navDrawItem);
            }
        }
    }

    public void addCategories(int index) {
        if (drawerItems == null || drawerItems.size() == 0 || index >= drawerItems.size()) {
            return;
        }

        if (drawerItems.get(index).getId() == Constants.MENU_ID_CATEGORIES) {
            drawerItems.remove(index);
        }

        final List<TM_CategoryInfo> header = new ArrayList<>();
        final HashMap<TM_CategoryInfo, List<TM_CategoryInfo>> child = new HashMap<>();
        List<TM_CategoryInfo> rootCategories = TM_CategoryInfo.getAllRootCategories();
        if (rootCategories != null) {
            header.addAll(rootCategories);
            for (TM_CategoryInfo c : rootCategories) {
                child.put(c, c.getSubCategories());
            }
        }
        drawerItems.add(index, new NavDrawItem(
                Constants.MENU_ID_CATEGORIES,
                getString(L.string.title_categories),
                R.drawable.ic_vc_categories,
                header,
                child));
    }

    public void addMenuItems() {
        WordPressMenuConfig wordPressMenuConfig = WordPressMenuConfig.getInstance();
        if (!wordPressMenuConfig.isEnabled() || MenuInfo.getAll().isEmpty()) {
            return;
        }

        boolean isAnyItemChanged = false;
        for (Iterator<NavDrawItem> it = drawerItems.iterator(); it.hasNext(); ) {
            if (it.next().getId() == Constants.MENU_ID_WP_MENU) {
                it.remove();
                isAnyItemChanged = true;
            }
        }

        int menuIndex = AppInfo.DRAWER_INDEX_WP_MENU;
        if (AppInfo.drawerItems != null) {
            final int size = AppInfo.drawerItems.size();
            int neighbourId = -1;
            for (int i = 0; i < size; i++) {
                if (AppInfo.drawerItems.get(i).getId() == Constants.MENU_ID_WP_MENU) {
                    if (i > 0 && i <= size - 1) {
                        neighbourId = AppInfo.drawerItems.get(i - 1).getId();
                    }
                    break;
                }
            }

            if (neighbourId == Constants.MENU_ID_SIGN_IN) {
                if (AppUser.hasSignedIn()) {
                    neighbourId = Constants.MENU_ID_SIGN_OUT;
                }
            } else if (neighbourId == Constants.MENU_ID_SIGN_OUT) {
                if (!AppUser.hasSignedIn()) {
                    neighbourId = Constants.MENU_ID_SIGN_IN;
                }
            }

            menuIndex = -1;
            for (int k = 0; k < drawerItems.size(); k++) {
                if (neighbourId == drawerItems.get(k).getId()) {
                    menuIndex = k + 1;
                }
            }

            int currentSize = drawerItems.size();

            if (menuIndex == -1) {
                menuIndex = AppInfo.DRAWER_INDEX_WP_MENU;
            } else if (currentSize >= size && menuIndex >= size) {
                menuIndex = drawerItems.size() - 1;
            }
        }

        for (MenuInfo menuInfo : MenuInfo.getAll()) {
            // Show only menus which are in server config.
            boolean showMenu = false;
            if (!ArrayUtils.isEmpty(wordPressMenuConfig.getMenuIds())) {
                for (int id : wordPressMenuConfig.getMenuIds()) {
                    if (id == menuInfo.getId()) {
                        showMenu = true;
                        break;
                    }
                }
            } else {
                showMenu = true;
            }

            if (showMenu) {
                final List<MenuOption> header = new ArrayList<>();
                final HashMap<MenuOption, List<MenuOption>> child = new HashMap<>();
                List<MenuOption> menuOptions = menuInfo.getMenuOptions(true);
                if (menuOptions != null) {
                    header.addAll(menuOptions);
                    for (MenuOption menuOption : menuOptions) {
                        child.put(menuOption, menuOption.getAllChild());
                    }
                }
                drawerItems.add(menuIndex++, new NavDrawItem(
                        Constants.MENU_ID_WP_MENU,
                        menuInfo.getName(),
                        R.drawable.ic_vc_menu,
                        header,
                        child));
                isAnyItemChanged = true;
            }
        }

        if (isAnyItemChanged) {
            mDrawerListAdapter = new Adapter_NavigationDrawer(getActivity(), drawerItems, new NavigationDrawerCallbacks() {
                @Override
                public void onNavigationDrawerItemSelected(int itemId, int position) {
                    selectItem(itemId, position);
                }
            });
            mDrawerListView.setAdapter(mDrawerListAdapter);
        }
    }

    public boolean isDrawerOpen() {
        return mDrawerLayout != null && mDrawerLayout.isDrawerOpen(mFragmentContainerView);
    }

    public void setUp(int fragmentId, DrawerLayout drawerLayout, Toolbar toolbar) {
        mActionBar = ((AppCompatActivity) getActivity()).getSupportActionBar();
        if (mActionBar != null) {
            mActionBar.setDisplayHomeAsUpEnabled(true);
            mActionBar.setHomeButtonEnabled(true);
        }

        mFragmentContainerView = getActivity().findViewById(fragmentId);
        mDrawerLayout = drawerLayout;
        mDrawerToggle = new ColorableActionBarDrawerToggle(getActivity(), mDrawerLayout, toolbar, R.string.nav_drawer_open, R.string.nav_drawer_close) {
            @Override
            public void onDrawerClosed(View drawerView) {
                super.onDrawerClosed(drawerView);
                if (!isAdded()) {
                    return;
                }
                getActivity().supportInvalidateOptionsMenu();
            }

            @Override
            public void onDrawerOpened(View drawerView) {
                super.onDrawerOpened(drawerView);
                if (!isAdded()) {
                    return;
                }
                Helper.hideKeyboard(getActivity().getCurrentFocus());
            }
        };

        mDrawerToggle.setColor(Color.parseColor(AppInfo.color_actionbar_text));
        mDrawerLayout.post(new Runnable() {
            @Override
            public void run() {
                mDrawerToggle.syncState();
            }
        });
        mDrawerLayout.addDrawerListener(mDrawerToggle);

        setupDrawerComponents();
        setupBackKeyNavigation();
    }

    private void setupBackKeyNavigation() {
        final View.OnClickListener navigationListener = mDrawerToggle.getToolbarNavigationClickListener();
        final FragmentManager fragmentManager = getActivity().getSupportFragmentManager();
        fragmentManager.addOnBackStackChangedListener(new FragmentManager.OnBackStackChangedListener() {
            @Override
            public void onBackStackChanged() {
                if (fragmentManager.getBackStackEntryCount() > 0) {
                    getBaseActivity().setShowActionBarSearch(false);
                    mActionBar.setDisplayHomeAsUpEnabled(true);
                    mActionBar.setHomeButtonEnabled(true);
                    mDrawerToggle.setDrawerIndicatorEnabled(false);
                    mDrawerToggle.setToolbarNavigationClickListener(new View.OnClickListener() {
                        @Override
                        public void onClick(View v) {
                            Helper.hideKeyboard(v);
                            fragmentManager.popBackStack();
                            ((MainActivity) getActivity()).setBottomNavMenuItemChecked();
                            FreshChatConfig.onResume(getBaseActivity());
                        }
                    });
                } else {
                    if (AppInfo.SHOW_BOTTOM_NAV_MENU) {
                        getBaseActivity().setShowActionBarSearch(true);
                        mDrawerToggle.setDrawerIndicatorEnabled(false);
                        mActionBar.setDisplayHomeAsUpEnabled(false);
                        mActionBar.setHomeButtonEnabled(false);
                    } else {
                        mDrawerToggle.setDrawerIndicatorEnabled(true);
                        mDrawerToggle.setToolbarNavigationClickListener(navigationListener);
                    }
                }
            }
        });
    }

    public void lockDrawer() {
        getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                isDrawerEnabled = false;
                mDrawerLayout.setDrawerLockMode(DrawerLayout.LOCK_MODE_LOCKED_CLOSED, GravityCompat.START);
                mDrawerToggle.setDrawerIndicatorEnabled(false);
                mActionBar.setDisplayHomeAsUpEnabled(false);
            }
        });
    }

    public void hideDrawer() {
        getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                mActionBar.setDisplayHomeAsUpEnabled(false);
                mActionBar.setHomeButtonEnabled(false);
                mDrawerToggle.setDrawerIndicatorEnabled(false);
            }
        });
    }

    public void unlockDrawer() {
        getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                mDrawerLayout.setDrawerLockMode(DrawerLayout.LOCK_MODE_UNLOCKED, GravityCompat.START);
                mDrawerToggle.setDrawerIndicatorEnabled(true);
                mActionBar.setDisplayHomeAsUpEnabled(true);
                isDrawerEnabled = true;
            }
        });
    }

    public void resetDrawer() {
        getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                drawerItems.clear();
                setupDrawerComponents();
            }
        });
    }

    private void selectItem(int id, int position) {
        if (mCallbacks != null) {
            if (id == Constants.MENU_ID_CHANGE_SELLER) {
                position = -1;
            }
            mCallbacks.onNavigationDrawerItemSelected(id, position);
        }
        closeDrawer();
    }

    public void closeDrawer() {
        if (mDrawerLayout != null) {
            getActivity().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    mDrawerLayout.closeDrawer(mFragmentContainerView);
                }
            });
        }
    }

    @Override
    public void onAttach(Context context) {
        super.onAttach(context);
        try {
            mCallbacks = (NavigationDrawerCallbacks) context;
        } catch (ClassCastException e) {
            throw new ClassCastException("Activity must implement NavigationDrawerCallbacks.");
        }
    }

    @Override
    public void onDetach() {
        super.onDetach();
        mCallbacks = null;
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        mDrawerToggle.onConfigurationChanged(newConfig);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        if (isDrawerEnabled && mDrawerToggle.onOptionsItemSelected(item)) {
            return true;
        }
        switch (item.getItemId()) {
            case Constants.ID_ACTION_MENU_HOME:
                selectItem(Constants.MENU_ID_HOME, -1);
                return true;
            case Constants.ID_ACTION_MENU_CART:
                selectItem(Constants.MENU_ID_CART, -1);
                return true;
            case Constants.ID_ACTION_MENU_WISH:
                selectItem(Constants.MENU_ID_WISH, -1);
                return true;
            case Constants.ID_ACTION_MENU_OPINION:
                selectItem(Constants.MENU_ID_OPINION, -1);
                return true;
            case Constants.ID_ACTION_MENU_SEARCH:
                selectItem(Constants.MENU_ID_SEARCH, -1);
                return true;
        }
        return super.onOptionsItemSelected(item);
    }
}
