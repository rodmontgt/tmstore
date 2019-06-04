package com.twist.tmstore.fragments;

import android.content.Context;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v7.widget.RecyclerView;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import com.twist.dataengine.DataQueryHandler;
import com.twist.dataengine.entities.TM_ProductInfo;
import com.twist.tmstore.BaseFragment;
import com.twist.tmstore.Constants;
import com.twist.tmstore.L;
import com.twist.tmstore.MainActivity;
import com.twist.tmstore.R;
import com.twist.tmstore.adapters.Adapter_WishGroup;
import com.twist.tmstore.entities.AppInfo;
import com.twist.tmstore.entities.AppUser;
import com.twist.tmstore.entities.WishListGroup;
import com.twist.tmstore.entities.Wishlist;
import com.twist.tmstore.listeners.WishGroupCreatedListener;
import com.twist.tmstore.listeners.WishListDialogHandler;
import com.utils.Helper;
import com.utils.ImageDownload;

import java.util.List;

public class Fragment_Wishlist_Dialog extends BaseFragment {

    public static WishGroupCreatedListener onWishGroupCreatedListener;
    public boolean misCheckBoxMode = false;
    public Adapter_WishGroup adapter_wishGroup;
    Button btn_done_wishgroup;
    EditText textfield_name_wishlist;
    Button btn_create_group;
    View rootView;
    private WishListDialogHandler mWishListDialogHandler;
    private TextView mTitleView;
    private TextView text_no_wishgroup;
    private TM_ProductInfo product;
    private List<TM_ProductInfo> allProdList = null;

    public static void setOnWishGroupCreatedListener(WishGroupCreatedListener _onWishGroupCreatedListener) {
        onWishGroupCreatedListener = _onWishGroupCreatedListener;
    }

    public static void OpenWishGroupDialogWishCheckbox(List<TM_ProductInfo> prodList, WishListDialogHandler handler) {
        Fragment_Wishlist_Dialog wishlist_dialog = new Fragment_Wishlist_Dialog();
        wishlist_dialog.setProductList(prodList);
        Bundle bundle = new Bundle();
        bundle.putBoolean("isCheckBoxMode", true);
        wishlist_dialog.setArguments(bundle);
        wishlist_dialog.setWishListDialogHandler(handler);
        MainActivity.mActivity.getFM().beginTransaction()
                .replace(R.id.content, wishlist_dialog)
                .addToBackStack(Fragment_Wishlist_Dialog.class.getSimpleName())
                .commit();
    }

    public static void OpenWishGroupDialog(TM_ProductInfo product, WishListDialogHandler handler) {
        if (AppInfo.mGuestUserConfig != null && AppInfo.mGuestUserConfig.isEnabled() && AppInfo.mGuestUserConfig.isPreventWishlist() && AppUser.isAnonymous()) {
            Helper.toast(L.string.you_need_to_login_first);
            handler.onSelectGroupFailed("");
            return;
        }

        if (!AppInfo.ENABLE_MULTIPLE_WISHLIST) {
            handler.onSkipDialog(product, null);
            return;
        }

        if (WishListGroup.getDefaultItem() != null) {
            if (AppUser.hasSignedIn())
                handler.onSelectGroupSuccess(product, WishListGroup.getDefaultItem());
            else
                handler.onSkipDialog(product, WishListGroup.getDefaultItem());
            return;
        }

        if (handler != null)
            MainActivity.mActivity.showWishListDialog(false, product, handler);
    }

    public void setWishListDialogHandler(WishListDialogHandler handler) {
        this.mWishListDialogHandler = handler;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        rootView = inflater.inflate(R.layout.activity_wishlist_dialog, container, false);

        if (getArguments() != null)
            misCheckBoxMode = getArguments().getBoolean("isCheckBoxMode");

        setTitle(getString(R.string.title_wishlist));

        mTitleView = (TextView) rootView.findViewById(R.id.txt_wishlist_title);
        mTitleView.setText(getString(L.string.title_wishlist));
        if (misCheckBoxMode)
            mTitleView.setText(getString(L.string.select_wishlist));

        text_no_wishgroup = (TextView) rootView.findViewById(R.id.text_no_wishgroup);
        text_no_wishgroup.setVisibility(View.VISIBLE);

        rootView.findViewById(R.id.layout_textfield_wishlist).setVisibility(View.GONE);

        textfield_name_wishlist = (EditText) rootView.findViewById(R.id.textfield_name_wishlist);
        textfield_name_wishlist.setText(getString(L.string.mylist));
        final TextView txt_create_wish = (TextView) rootView.findViewById(R.id.txt_create_wish);
        txt_create_wish.setVisibility(View.GONE);
        txt_create_wish.setText(getString(L.string.create_wishlist_message));


        final Button btn_create_wishlist = (Button) rootView.findViewById(R.id.btn_ok_create_wishlist);
        Helper.stylize(btn_create_wishlist);
        btn_create_wishlist.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (textfield_name_wishlist != null && !TextUtils.isEmpty(textfield_name_wishlist.getText())) {
                    MainActivity.mActivity.showProgress(getString(L.string.please_wait), false);
                    txt_create_wish.setVisibility(View.GONE);
                    rootView.findViewById(R.id.layout_textfield_wishlist).setVisibility(View.VISIBLE);
                    if (AppUser.hasSignedIn()) {
                        WishListGroup.addWishlist(textfield_name_wishlist.getText().toString(), new DataQueryHandler() {
                            @Override
                            public void onSuccess(Object data) {
                                MainActivity.mActivity.hideProgress();
                                rootView.findViewById(R.id.layout_textfield_wishlist).setVisibility(View.GONE);
                                rootView.findViewById(R.id.btn_create_group).setVisibility(View.VISIBLE);
                                text_no_wishgroup.setVisibility(View.GONE);
                                updateList();

                                View view = getActivity().getCurrentFocus();
                                if (view != null) {
                                    InputMethodManager imm = (InputMethodManager) getActivity().getSystemService(Context.INPUT_METHOD_SERVICE);
                                    imm.hideSoftInputFromWindow(view.getWindowToken(), 0);
                                }

                                if (allProdList != null) {
                                    Fragment_Wishlist_Dialog.OpenWishGroupDialogWishCheckbox(allProdList, mWishListDialogHandler);
                                }

                                if (onWishGroupCreatedListener != null) {
                                    onWishGroupCreatedListener.onSuccess((WishListGroup) data);
                                    onWishGroupCreatedListener = null; // Recreate every time
                                }
                            }

                            @Override
                            public void onFailure(Exception error) {
                                Helper.toast(getString(L.string.generic_server_timeout));
                                MainActivity.mActivity.hideProgress();
                            }
                        });
                    } else {
                        int id = Helper.randInt(1000, 5000);
                        WishListGroup wg = WishListGroup.createAndAddNewGroupOffline(textfield_name_wishlist.getText().toString(), id);
                        MainActivity.mActivity.hideProgress();

                        rootView.findViewById(R.id.layout_textfield_wishlist).setVisibility(View.GONE);
                        if (misCheckBoxMode)
                            rootView.findViewById(R.id.btn_done_wishgroup).setVisibility(View.VISIBLE);
                        else
                            rootView.findViewById(R.id.btn_create_group).setVisibility(View.VISIBLE);

                        text_no_wishgroup.setVisibility(View.GONE);

                        updateList();

                        View viewcurrent = getActivity().getCurrentFocus();
                        if (viewcurrent != null) {
                            InputMethodManager imm = (InputMethodManager) getActivity().getSystemService(Context.INPUT_METHOD_SERVICE);
                            imm.hideSoftInputFromWindow(viewcurrent.getWindowToken(), 0);
                        }

                        if (onWishGroupCreatedListener != null) {
                            onWishGroupCreatedListener.onSuccess(wg);
                            onWishGroupCreatedListener = null; // Recreate every time
                        }
                    }
                }
            }
        });

        final Button btn_get_user_info = (Button) rootView.findViewById(R.id.btn_get_user_info);
        Helper.stylize(btn_get_user_info);
        btn_get_user_info.setVisibility(View.GONE);
        btn_get_user_info.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                WishListGroup wishgroup = null;
                if (WishListGroup.allwishListGroup.size() > 0)
                    wishgroup = WishListGroup.allwishListGroup.get(0);

                WishListGroup.getUserWishList(wishgroup.id, new DataQueryHandler() {
                    @Override
                    public void onSuccess(Object data) {
                    }

                    @Override
                    public void onFailure(Exception error) {
                    }
                });
            }
        });

        btn_create_group = (Button) rootView.findViewById(R.id.btn_create_group);
        Helper.stylize(btn_create_group);
        btn_create_group.setVisibility(View.VISIBLE);
        btn_create_group.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                rootView.findViewById(R.id.layout_textfield_wishlist).setVisibility(View.VISIBLE);
                txt_create_wish.setVisibility(View.VISIBLE);
                btn_create_group.setVisibility(View.GONE);
            }
        });

        adapter_wishGroup = new Adapter_WishGroup(WishListGroup.allwishListGroup, misCheckBoxMode, new OnWishGroupSelectListener() {
            @Override
            public void onGroupClick(View view, WishListGroup wishgroup, boolean dismiss) {
                if (AppUser.hasSignedIn())
                    mWishListDialogHandler.onSelectGroupSuccess(getProduct(), wishgroup);
                else
                    mWishListDialogHandler.onSkipDialog(getProduct(), wishgroup);
            }

            @Override
            public void onGroupItemClick(final WishListGroup wishgroup, int id) {
                if (id == Constants.ID_WISH_MENU_RENAME) {
                    if (AppUser.hasSignedIn()) {
                        MainActivity.mActivity.showProgress(getString(L.string.please_wait));
                        WishListGroup.updateWishList(wishgroup.id, wishgroup.title, new DataQueryHandler() {
                            @Override
                            public void onSuccess(Object data) {
                                MainActivity.mActivity.hideProgress();
                                Helper.toast(wishgroup.title + " " + getString(L.string.updated_successfully));
                                adapter_wishGroup.notifyDataSetChanged();
                            }

                            @Override
                            public void onFailure(Exception error) {
                                MainActivity.mActivity.hideProgress();
                            }
                        });
                    } else {
                        wishgroup.save();
                        Helper.toast(wishgroup.title + " " + getString(L.string.updated_successfully));
                        adapter_wishGroup.notifyDataSetChanged();
                    }
                }

                if (id == Constants.ID_WISH_MENU_DELETE) {

                    if (AppUser.hasSignedIn()) {
                        MainActivity.mActivity.showProgress(getString(L.string.please_wait));
                        WishListGroup.deleteWishList(wishgroup.id, new DataQueryHandler() {
                            @Override
                            public void onSuccess(Object data) {
                                Helper.toast(wishgroup.title + " " + getString(L.string.deleted_successfully));
                                WishListGroup.allwishListGroup.remove(wishgroup);
                                adapter_wishGroup.notifyDataSetChanged();
                                MainActivity.mActivity.hideProgress();
                            }

                            @Override
                            public void onFailure(Exception error) {
                                MainActivity.mActivity.hideProgress();
                            }
                        });
                    } else {
                        Helper.toast(wishgroup.title + " " + getString(L.string.deleted_successfully));
                        WishListGroup.remove(getActivity(), wishgroup);
                        adapter_wishGroup.notifyDataSetChanged();
                        MainActivity.mActivity.hideProgress();
                    }
                }
                if (id == Constants.ID_WISH_MENU_DOWNLOAD_LIST) {
                    startDownloadTask(wishgroup);
                }
                if (id == Constants.ID_WISH_MENU_SHARE) {

                    if (!AppUser.hasSignedIn()) {

                        Helper.showAlertDialog("", getString(L.string.login_to_share_wishlist), getString(L.string.ok), true, new View.OnLongClickListener() {
                            @Override
                            public boolean onLongClick(View v) {
                                return false;
                            }
                        });

                        return;
                    }
                    Helper.shareWithFriends(wishgroup.url);
                }
            }
        }, new OnCheckBoxClickListener() {
            @Override
            public void onClick(WishListGroup obj) {
                Helper.showAlertDialog("", obj.title + " " + getString(L.string.set_as_default_WishList), getString(L.string.ok), true, new View.OnLongClickListener() {
                    @Override
                    public boolean onLongClick(View view) {
                        return false;
                    }
                });
            }
        }, new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                btn_done_wishgroup.setEnabled(false);
                for (WishListGroup wishGroup : WishListGroup.allwishListGroup) {

                    if (wishGroup.isChecked) {
                        btn_done_wishgroup.setEnabled(true);
                    }
                }
            }
        });

        btn_done_wishgroup = (Button) rootView.findViewById(R.id.btn_done_wishgroup);
        btn_done_wishgroup.setText(getString(L.string.done));
        Helper.stylize(btn_done_wishgroup);
        btn_done_wishgroup.setVisibility(View.GONE);

        if (misCheckBoxMode) {
            btn_done_wishgroup.setVisibility(View.VISIBLE);
            btn_done_wishgroup.setEnabled(false);
            btn_create_group.setVisibility(View.GONE);
        }
        btn_done_wishgroup.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {

                if (!AppUser.hasSignedIn()) {

                    for (WishListGroup wishGroup : WishListGroup.allwishListGroup) {

                        if (wishGroup.isChecked) {
                            for (TM_ProductInfo product : allProdList) {
                                if (!WishListGroup.hasChild(wishGroup.id, product))
                                    Wishlist.addProduct(product, wishGroup);
                            }
                            wishGroup.isChecked = false;
                        }
                    }
                    mWishListDialogHandler.onSelectGroupSuccess(null, null);
                    Helper.toast(getString(L.string.item_added_to_wishlist));
                    MainActivity.mActivity.popBackWishFragment();
                } else {
                    MainActivity.mActivity.showProgress(getString(L.string.please_wait), false);
                    String str = WishListGroup.getPidsArrayString(WishListGroup.allwishListGroup, allProdList);
                    WishListGroup.addProductsToMultipleWishList(str, new DataQueryHandler() {
                        @Override
                        public void onSuccess(Object data) {
                            MainActivity.mActivity.hideProgress();
                            Helper.toast(getString(L.string.item_added_to_wishlist));
                            mWishListDialogHandler.onSelectGroupSuccess(null, null);
                            MainActivity.mActivity.popBackWishFragment();
                        }

                        @Override
                        public void onFailure(Exception error) {
                            MainActivity.mActivity.hideProgress();
                            MainActivity.mActivity.showProgress(getString(L.string.retry));
                        }
                    });
                }
            }
        });

        RecyclerView recycler_wishgroup = (RecyclerView) rootView.findViewById(R.id.recycler_wishgroup);
        recycler_wishgroup.setAdapter(adapter_wishGroup);
        return rootView;
    }

    @Override
    public void onViewCreated(View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        if (adapter_wishGroup.getItemCount() > 0) {
            text_no_wishgroup.setVisibility(View.GONE);
        } else {
            btn_done_wishgroup.setVisibility(View.GONE);
            text_no_wishgroup.setVisibility(View.VISIBLE);
            btn_create_group.callOnClick();
            textfield_name_wishlist.setFocusableInTouchMode(true);

            textfield_name_wishlist.requestFocus();
            InputMethodManager imm = (InputMethodManager) getActivity().getSystemService(Context.INPUT_METHOD_SERVICE);
            imm.showSoftInput(textfield_name_wishlist, InputMethodManager.SHOW_IMPLICIT);
        }
    }

    private void startDownloadTask(WishListGroup wishlistGroup) {
        for (Wishlist wishlist : Wishlist.allWishlistItems) {
            if (wishlistGroup != null && wishlistGroup.id == wishlist.parent_id) {
                TM_ProductInfo product = wishlist.product;
                if (product != null) {
                    Toast.makeText(getActivity(), getString(L.string.download_initiated), Toast.LENGTH_SHORT).show();
                    ImageDownload.downloadWishListGroupProductCatalog(getActivity(), product, wishlistGroup.title);
                }
            }
        }
    }

    public void updateList() {
        adapter_wishGroup.notifyDataSetChanged();
    }

    public TM_ProductInfo getProduct() {
        return product;
    }

    public void setProduct(TM_ProductInfo product) {
        this.product = product;
    }

    public void setProductList(List<TM_ProductInfo> allProdList) {
        this.allProdList = allProdList;
    }

    public void refresh(WishListDialogHandler loginDialogHandler) {
        rootView.findViewById(R.id.btn_create_group).setVisibility(View.VISIBLE);
        rootView.findViewById(R.id.btn_done_wishgroup).setVisibility(View.GONE);
        adapter_wishGroup.isCheckBoxMode = false;
        setWishListDialogHandler(loginDialogHandler);
        adapter_wishGroup.notifyDataSetChanged();
    }


    public interface OnWishGroupSelectListener {
        void onGroupClick(View view, WishListGroup wishgroup, boolean dismiss);
        void onGroupItemClick(WishListGroup wishgroup, int id);
    }

    public interface OnCheckBoxClickListener {
        void onClick(WishListGroup obj);
    }
}