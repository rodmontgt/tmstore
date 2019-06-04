package com.twist.tmstore.adapters;

import android.content.Context;
import android.graphics.Color;
import android.graphics.PorterDuff;
import android.support.annotation.NonNull;
import android.support.v7.widget.RecyclerView;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.bignerdranch.expandablerecyclerview.Adapter.ExpandableRecyclerAdapter;
import com.bignerdranch.expandablerecyclerview.Model.ParentListItem;
import com.bignerdranch.expandablerecyclerview.ViewHolder.ChildViewHolder;
import com.bignerdranch.expandablerecyclerview.ViewHolder.ParentViewHolder;
import com.bumptech.glide.Glide;
import com.twist.dataengine.entities.MenuOption;
import com.twist.dataengine.entities.TM_CategoryInfo;
import com.twist.dataengine.entities.TM_ProductInfo;
import com.twist.tmstore.BuildConfig;
import com.twist.tmstore.Constants;
import com.twist.tmstore.L;
import com.twist.tmstore.MainActivity;
import com.twist.tmstore.R;
import com.twist.tmstore.config.NavDrawerConfig;
import com.twist.tmstore.entities.AppInfo;
import com.twist.tmstore.entities.AppUser;
import com.twist.tmstore.entities.NavDrawItem;
import com.twist.tmstore.listeners.NavigationDrawerCallbacks;
import com.twist.tmstore.listeners.TaskListener;
import com.utils.CContext;
import com.utils.Helper;
import com.utils.HtmlCompat;
import com.utils.customviews.RoundedImageView;
import com.utils.customviews.utility.HorizontalDividerItemDecoration;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import static com.twist.tmstore.L.getString;

public class Adapter_NavigationDrawer extends ExpandableRecyclerAdapter<Adapter_NavigationDrawer.MainMenuHolder, Adapter_NavigationDrawer.ChildMenuHolder> {

    private enum ItemType {
        DEFAULT,
        WORDPRESS_MENU,
        CATEGORY_MENU
    }

    class MainMenuHolder extends ParentViewHolder {
        private final TextView title;
        private final ImageView expand;
        private final ImageView image;
        private final FrameLayout layout_nav_drawer_header;
        private final LinearLayout layout_nav_drawer_content;

        MainMenuHolder(View itemView) {
            super(itemView);
            layout_nav_drawer_header = (FrameLayout) itemView.findViewById(R.id.layout_nav_drawer_header);
            layout_nav_drawer_content = itemView.findViewById(R.id.layout_nav_drawer_content);
            title = (TextView) itemView.findViewById(R.id.title);
            expand = (ImageView) itemView.findViewById(R.id.expand);
            image = (ImageView) itemView.findViewById(R.id.image);
            this.stylize();
        }

        private void stylize() {
            NavDrawerConfig navDrawerConfig = NavDrawerConfig.getInstance();
            NavDrawerConfig.MainMenuConfig mainMenuConfig = navDrawerConfig.getMainMenuConfig();
            if (navDrawerConfig.enabled && mainMenuConfig.enabled) {
                itemView.setBackgroundColor(Color.parseColor(mainMenuConfig.bgColor));
                title.setAllCaps(mainMenuConfig.titleCapsAll);
                title.setTextColor(Color.parseColor(mainMenuConfig.titleTextColor));
                if (image.getVisibility() == View.VISIBLE) {
                    image.setVisibility(mainMenuConfig.iconVisible ? View.VISIBLE : View.GONE);
                    image.setColorFilter(Color.parseColor(mainMenuConfig.iconColor), PorterDuff.Mode.SRC_ATOP);
                }

                if (expand.getVisibility() == View.VISIBLE) {
                    expand.setColorFilter(Color.parseColor(mainMenuConfig.indicatorColor), PorterDuff.Mode.SRC_ATOP);
                }
            }

            if (getItemType() == ItemType.CATEGORY_MENU || getItemType() == ItemType.WORDPRESS_MENU) {
                title.setAllCaps(AppInfo.CATEGORY_TITLE_ALL_CAPS);
            }
        }

        void bind(final NavDrawItem drawerItem) {
            if (drawerItem.getId() == Constants.MENU_ID_PROFILE_FULL) {
                layout_nav_drawer_header.setVisibility(View.VISIBLE);
                layout_nav_drawer_content.setVisibility(View.GONE);
                layout_nav_drawer_header.removeAllViews();
                layout_nav_drawer_header.addView(getNavDrawerHeaderView());
            } else {
                layout_nav_drawer_header.setVisibility(View.GONE);
                layout_nav_drawer_content.setVisibility(View.VISIBLE);
                if(!TextUtils.isEmpty(drawerItem.getName())) {
                    title.setText(HtmlCompat.fromHtml(drawerItem.getName()));
                }

                boolean invisible = true;
                if (drawerItem.getIconId() != -1) {
                    if (drawerItem.getIconUrl() != null) {
                        Glide.with(itemView.getContext())
                                .load(drawerItem.getIconUrl())
                                .asBitmap()
                                .error(R.drawable.ic_vc_categories)
                                .override(56, 56)
                                .into(image);
                    } else {
                        image.setImageResource(drawerItem.getIconId());
                    }

                    image.setVisibility(View.VISIBLE);
                    if (drawerItem.getId() == Constants.MENU_ID_CATEGORIES) {
                        if (!AppInfo.SHOW_NESTED_CATEGORY_MENU && TextUtils.isEmpty(drawerItem.getIconUrl())) {
                            image.setVisibility(View.INVISIBLE);
                        } else {
                            image.setVisibility(View.VISIBLE);
                        }
                    }
                } else {
                    // don't show child category item.
                    //invisible = true;
                    drawerItem.setShowIcon(false);
                }

                image.setVisibility(drawerItem.isShowIcon()
                        ? View.VISIBLE
                        : invisible
                        ? View.INVISIBLE
                        : View.GONE);


                if (drawerItem.getHeader() == null || drawerItem.getHeader().isEmpty()) {
                    final int index = getParentItemList().indexOf(drawerItem);
                    expand.setVisibility(View.GONE);
                    layout_nav_drawer_content.setOnClickListener(v -> {
                        if (drawerItem.getId() == Constants.MENU_ID_WEB_PAGE && !TextUtils.isEmpty(drawerItem.getData())) {
                            MainActivity.mActivity.openWebFragment(drawerItem.getName(), drawerItem.getData());
                        } else if (drawerItem.getId() == Constants.MENU_ID_EXTERNAL_LINK && !TextUtils.isEmpty(drawerItem.getData())) {
                            Helper.openExternalLink(mContext, drawerItem.getData());
                        } else if (drawerItem.getId() == Constants.MENU_ID_FIXED_PRODUCTS && !TextUtils.isEmpty(drawerItem.getData())) {
                            MainActivity.mActivity.openFixedProductFragment(drawerItem);
                        } else if (drawerItem.getId() == Constants.MENU_ID_CATEGORIES) {
                            try {
                                openCategory(TM_CategoryInfo.findCategoryByName(drawerItem.getName()));
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                        } else if (mCallback != null) {
                            String data = drawerItem.getData();
                            if (data != null && data.startsWith("http")) {
                                MainActivity.mActivity.openWebFragment(drawerItem.getName(), drawerItem.getData());
                            } else {
                                mCallback.onNavigationDrawerItemSelected(drawerItem.getId(), index);
                            }
                        }
                    });
                    layout_nav_drawer_content.setClickable(true);
                } else {
                    expand.setVisibility(View.VISIBLE);
                    layout_nav_drawer_content.setClickable(false);
                }
            }
        }
    }

    class ChildMenuHolder extends ChildViewHolder {
        private final LinearLayout layout_nav_drawer_content_child;
        private final TextView title;
        private final RecyclerView childRecyclerView;

        ChildMenuHolder(View itemView) {
            super(itemView);
            layout_nav_drawer_content_child = itemView.findViewById(R.id.layout_nav_drawer_content_child);
            title = (TextView) itemView.findViewById(R.id.title);
            childRecyclerView = itemView.findViewById(R.id.recycler_view_child);
            this.stylize();
        }

        private void stylize() {
            NavDrawerConfig navDrawerConfig = NavDrawerConfig.getInstance();
            NavDrawerConfig.ChildMenuConfig childMenuConfig = navDrawerConfig.getChildMenuConfig();
            if (navDrawerConfig.enabled && childMenuConfig.enabled) {
                itemView.setBackgroundColor(Color.parseColor(childMenuConfig.bgColor));
                childRecyclerView.setBackgroundColor(Color.parseColor(childMenuConfig.bgColor));
                title.setAllCaps(childMenuConfig.titleCapsAll);
                title.setTextColor(Color.parseColor(childMenuConfig.titleTextColor));
                if (childMenuConfig.dividerHeight > 0) {
                    childRecyclerView.addItemDecoration(new HorizontalDividerItemDecoration.Builder(itemView.getContext())
                            .size(Helper.DP(childMenuConfig.dividerHeight))
                            .color(Color.parseColor(childMenuConfig.dividerColor))
                            .build());
                }
            } else {
                childRecyclerView.addItemDecoration(new HorizontalDividerItemDecoration.Builder(itemView.getContext()).build());
            }
        }

        void bind(Object object) {
            if (object instanceof TM_CategoryInfo) {
                final TM_CategoryInfo category = (TM_CategoryInfo) object;
                if (category.childrens.isEmpty() && category.parent!=null) {
                    layout_nav_drawer_content_child.setVisibility(View.VISIBLE);
                    title.setVisibility(View.VISIBLE);
                    title.setText(HtmlCompat.fromHtml(category.getName()));
                    childRecyclerView.setVisibility(View.GONE);
                    title.setOnClickListener(new OnClickListener() {
                        @Override
                        public void onClick(View v) {
                            openCategory(category);
                        }
                    });
                    title.setAllCaps(AppInfo.CATEGORY_TITLE_ALL_CAPS);
                    title.setClickable(true);
                } else {
                    layout_nav_drawer_content_child.setVisibility(View.GONE);
                    title.setVisibility(View.GONE);
                    childRecyclerView.setVisibility(View.VISIBLE);
                    List<NavDrawItem> drawerItems = new ArrayList<>();
                    final List<TM_CategoryInfo> header = new ArrayList<>();
                    header.addAll(category.childrens);
                    HashMap<TM_CategoryInfo, List<TM_CategoryInfo>> child = new HashMap<>();
                    NavDrawItem drawerItem = new NavDrawItem(Constants.MENU_ID_CATEGORIES, category.getName(), -1, header, child);
                    drawerItems.add(drawerItem);
                    Adapter_NavigationDrawer adapter = new Adapter_NavigationDrawer(mContext, drawerItems, mCallback);
                    adapter.setItemType(ItemType.CATEGORY_MENU);
                    childRecyclerView.setAdapter(adapter);
                    title.setClickable(false);
                }
            } else if (object instanceof MenuOption) {
                final MenuOption menuOption = (MenuOption) object;
                if (menuOption.getAllChild().size() > 0) {
                    List<NavDrawItem> drawerItems = new ArrayList<>();
                    final List<MenuOption> header = new ArrayList<>();
                    header.addAll(menuOption.getAllChild());
                    HashMap<TM_CategoryInfo, List<TM_CategoryInfo>> child = new HashMap<>();
                    NavDrawItem drawerItem = new NavDrawItem(Constants.MENU_ID_CATEGORIES, menuOption.getName(), -1, header, child);
                    drawerItems.add(drawerItem);
                    Adapter_NavigationDrawer adapter = new Adapter_NavigationDrawer(mContext, drawerItems, mCallback);
                    adapter.setItemType(ItemType.WORDPRESS_MENU);
                    childRecyclerView.setVisibility(View.VISIBLE);
                    childRecyclerView.setAdapter(adapter);
                    layout_nav_drawer_content_child.setVisibility(View.GONE);
                    title.setVisibility(View.GONE);
                    title.setClickable(false);
                } else {
                    childRecyclerView.setVisibility(View.GONE);
                    title.setAllCaps(AppInfo.CATEGORY_TITLE_ALL_CAPS);
                    title.setText(HtmlCompat.fromHtml(menuOption.getName()));
                    title.setOnClickListener(v -> {
                        if (!menuOption.getUrl().equals("")) {
                            MainActivity.mActivity.openWebFragment(menuOption.getName(), menuOption.getUrl());
                        } else {
                            try {
                                openCategory(TM_CategoryInfo.getWithId(menuOption.getCategoryId()));
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                        }
                    });
                    title.setClickable(true);
                }
            } else if (object instanceof NavDrawItem) {
                final NavDrawItem menuItem = (NavDrawItem) object;
                final int index = getParentItemList().indexOf(menuItem);
                title.setText(HtmlCompat.fromHtml(menuItem.getName()));
                title.setOnClickListener(new OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        if (menuItem.getId() == Constants.MENU_ID_WEB_PAGE) {
                            MainActivity.mActivity.openWebFragment(menuItem.getName(), menuItem.getData());
                        } else if (menuItem.getId() == Constants.MENU_ID_EXTERNAL_LINK) {
                            Helper.openExternalLink(mContext, menuItem.getData());
                        } else {
                            mCallback.onNavigationDrawerItemSelected(menuItem.getId(), index);
                        }
                    }
                });
                title.setClickable(true);
                childRecyclerView.setVisibility(View.GONE);
            } else {
                layout_nav_drawer_content_child.setVisibility(View.GONE);
                title.setVisibility(View.GONE);
                title.setClickable(false);
                childRecyclerView.setVisibility(View.GONE);
            }
        }
    }

    private Context mContext;
    private NavigationDrawerCallbacks mCallback;
    private ItemType mItemType;

    public Adapter_NavigationDrawer(Context context, @NonNull List<? extends ParentListItem> parentItemList, NavigationDrawerCallbacks callback) {
        super(parentItemList);
        this.mContext = context;
        this.mCallback = callback;
    }

    @Override
    public MainMenuHolder onCreateParentViewHolder(ViewGroup parentViewGroup) {
        View view = LayoutInflater.from(mContext).inflate(R.layout.item_navigation_drawer_recycler_parent, parentViewGroup, false);
        return new MainMenuHolder(view);
    }

    @Override
    public ChildMenuHolder onCreateChildViewHolder(ViewGroup childViewGroup) {
        View view = LayoutInflater.from(mContext).inflate(R.layout.item_navigation_drawer_recycler_child, childViewGroup, false);
        return new ChildMenuHolder(view);
    }

    @Override
    public void onBindParentViewHolder(MainMenuHolder viewHolder, int position, ParentListItem parentListItem) {
        viewHolder.bind((NavDrawItem) parentListItem);
    }

    @Override
    public void onBindChildViewHolder(ChildMenuHolder viewHolder, int position, Object childListItem) {
        viewHolder.bind(childListItem);
    }

    public ItemType getItemType() {
        return mItemType;
    }

    public void setItemType(ItemType itemType) {
        this.mItemType = itemType;
    }

    private void openCategory(final TM_CategoryInfo category) {
        final MainActivity activity = MainActivity.mActivity;
        if (category.isProductRefreshed) {
            activity.expandCategory(category);
        } else {
            activity.showProgress(getString(L.string.loading));
            TM_ProductInfo.getAll().clear();
            for (TM_CategoryInfo c : TM_CategoryInfo.getAll()) {
                c.isProductRefreshed = false;
            }
            activity.getProductsOfCategory(category, new TaskListener() {
                @Override
                public void onTaskDone() {
                    activity.hideProgress();
                    activity.expandCategory(category);
                }

                @Override
                public void onTaskFailed(String reason) {
                    activity.hideProgress();
                    Helper.showErrorToast(reason);
                }
            });
        }
        activity.closeDrawer();
    }

    private View getNavDrawerHeaderView() {
        View view = View.inflate(mContext, R.layout.fragment_navdrawer_header, null);

        ImageView imageHeaderBackground = (ImageView) view.findViewById(R.id.img_header_bg);
        if (!TextUtils.isEmpty(AppInfo.drawer_header_bg)) {
            imageHeaderBackground.setVisibility(View.VISIBLE);
            Glide.with(mContext).load(AppInfo.drawer_header_bg).into(imageHeaderBackground);
        } else {
            imageHeaderBackground.setVisibility(View.GONE);
        }

        View userProfileView = view.findViewById(R.id.user_profile);

        TextView textUsername = (TextView) view.findViewById(R.id.txt_username);
        TextView textEmail = (TextView) view.findViewById(R.id.txt_email);

        Helper.stylizeDynamically(userProfileView);
        if (!AppUser.getEmail().equals("")) {
            textUsername.setVisibility(View.VISIBLE);
            textEmail.setText(AppUser.getEmail());
            textUsername.setText(AppUser.getInstance().getDisplayName());
            userProfileView.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    mCallback.onNavigationDrawerItemSelected(Constants.MENU_ID_PROFILE, -1);
                }
            });
        } else {
            textUsername.setVisibility(View.GONE);
            textEmail.setText(getString(L.string.not_signed_in));
            userProfileView.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    mCallback.onNavigationDrawerItemSelected(Constants.MENU_ID_SIGN_IN, -1);
                }
            });
        }

        if (BuildConfig.DEBUG) {
            userProfileView.setOnLongClickListener(new View.OnLongClickListener() {
                @Override
                public boolean onLongClick(View v) {
                    mCallback.onNavigationDrawerItemSelected(Constants.MENU_ID_CHANGE_PLATFORM, -1);
                    return true;
                }
            });
        }

        RoundedImageView imageUserIcon = (RoundedImageView) view.findViewById(R.id.img_user_icon);
        if (!TextUtils.isEmpty(AppUser.getInstance().avatar_url)) {
            Glide.with(mContext)
                    .load(AppUser.getInstance().avatar_url)
                    .asBitmap()
                    .into(imageUserIcon);
        } else {
            imageUserIcon.setImageDrawable(CContext.getDrawable(mContext, R.drawable.user_img));
        }
        return view;
    }
}