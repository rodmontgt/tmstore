package com.twist.tmstore.fragments;

import android.content.DialogInterface;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Rect;
import android.graphics.Typeface;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.GradientDrawable;
import android.os.Bundle;
import android.support.v4.content.ContextCompat;
import android.support.v4.graphics.drawable.DrawableCompat;
import android.support.v7.widget.RecyclerView;
import android.text.TextPaint;
import android.text.TextUtils;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestListener;
import com.bumptech.glide.request.target.BitmapImageViewTarget;
import com.bumptech.glide.request.target.Target;
import com.twist.dataengine.entities.SellerInfo;
import com.twist.tmstore.BaseFragment;
import com.twist.tmstore.Constants;
import com.twist.tmstore.L;
import com.twist.tmstore.R;
import com.twist.tmstore.TMStoreApp;
import com.twist.tmstore.adapters.Adapter_MyProfile;
import com.twist.tmstore.config.MultiVendorConfig;
import com.twist.tmstore.entities.AppUser;
import com.twist.tmstore.entities.MyProfileItem;
import com.twist.tmstore.listeners.BackKeyListener;
import com.twist.tmstore.listeners.MyProfileItemClickListener;
import com.utils.CContext;
import com.utils.Helper;
import com.utils.StringUtils;
import com.utils.customviews.RoundedImageView;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;

public class Fragment_SellerProfile extends BaseFragment implements BackKeyListener {

    private TextView nameView;
    private TextView locationView;
    private TextView shopNameView;
    private TextView vendorPhoneView;
    private TextView shopAddressView;
    private Adapter_MyProfile myProfileAdapter;
    private RecyclerView rv_my_profile;
    private SellerInfo seller;

    private MyProfileItemClickListener myProfileItemClickListener = null;
    private LinearLayout vendor_profile_header;

    public Fragment_SellerProfile() {
    }

    public static Fragment_SellerProfile newInstance(SellerInfo seller) {
        Fragment_SellerProfile fragment = new Fragment_SellerProfile();
        fragment.seller = seller;
        return fragment;
    }

    public static Fragment_SellerProfile newInstance(SellerInfo seller, MyProfileItemClickListener myProfileItemClickListener) {
        Fragment_SellerProfile fragment = Fragment_SellerProfile.newInstance(seller);
        fragment.myProfileItemClickListener = myProfileItemClickListener;
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setHasOptionsMenu(true);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.my_profile, container, false);

        List<MyProfileItem> myProfileItems = new ArrayList<>();

        for (int id : MultiVendorConfig.getProfileItems()) {
            MyProfileItem myProfileItem = new MyProfileItem(id);
            myProfileItems.add(myProfileItem);
        }

        if (MultiVendorConfig.isSellerApp()) {
            addBackKeyListenerOnView(view, this);
            myProfileItems.add(new MyProfileItem(Constants.MENU_ID_SIGN_OUT));

            if (MultiVendorConfig.isEnabled() && AppUser.isVendor()) {
                SellerInfo sellerInfo = SellerInfo.getCurrentSeller();
                if (sellerInfo != null && !sellerInfo.isVerified()) {
                    for (MyProfileItem myProfileItem : myProfileItems) {
                        if (myProfileItem.getId() == Constants.MENU_ID_SELLER_ORDERS
                                || myProfileItem.getId() == Constants.MENU_ID_SELLER_PRODUCTS
                                || myProfileItem.getId() == Constants.MENU_ID_SELLER_UPLOAD_PRODUCT) {
                            myProfileItems.remove(myProfileItem);
                        }
                    }
                }
            }
        }

        rv_my_profile = (RecyclerView) view.findViewById(R.id.rv_my_profile);
        myProfileAdapter = new Adapter_MyProfile(myProfileItems);
        myProfileAdapter.setMyProfileItemClickListener(myProfileItemClickListener);
        rv_my_profile.setAdapter(myProfileAdapter);
        updateSellerInfo();
        return view;
    }

    private void setVendorProfile(View parentView) {
        View view = parentView.findViewById(R.id.vendor_profile_header);
        if (view == null) {
            return;
        }

        vendor_profile_header = (LinearLayout) view.findViewById(R.id.vendor_profile_header);
        if (seller == null) {
            view.setVisibility(View.GONE);
            return;
        }

        final String sellerName = seller.getTitle();
        if (TextUtils.isEmpty(sellerName)) {
            view.setVisibility(View.GONE);
            return;
        }

        vendor_profile_header.setVisibility(View.VISIBLE);

        setTitle(sellerName);

        LinearLayout seller_detail = (LinearLayout) view.findViewById(R.id.seller_detail_section);
        seller_detail.setVisibility(View.VISIBLE);
        String[] layoutOrder = MultiVendorConfig.getLayoutOrder();
        if (layoutOrder != null && layoutOrder.length > 0) {
            for (String str : layoutOrder) {
                switch (str) {
                    case MultiVendorConfig.ID_NAME: {
                        nameView = addNewTextView(seller_detail);
                        nameView.setText(sellerName);
                        nameView.setTextSize(TypedValue.COMPLEX_UNIT_SP, 18);
                        nameView.setTypeface(Typeface.DEFAULT_BOLD);
                        nameView.setTextColor(CContext.getColor(getContext(), R.color.normal_text_color));
                        break;
                    }
                    case MultiVendorConfig.ID_LOCATION: {
                        locationView = addNewTextView(seller_detail);
                        locationView.setTextSize(TypedValue.COMPLEX_UNIT_SP, 16);
                        locationView.setTextColor(CContext.getColor(getContext(), R.color.normal_text_color_lite));
                        String strLocation = seller.getSellerFirstLocation();
                        if (TextUtils.isEmpty(strLocation)) {
                            locationView.setVisibility(View.GONE);
                        } else {
                            locationView.setVisibility(View.VISIBLE);
                            locationView.setText(strLocation);
                        }
                        break;
                    }
                    case MultiVendorConfig.ID_SHOP_NAME: {
                        shopNameView = addNewTextView(seller_detail);
                        shopNameView.setTextSize(TypedValue.COMPLEX_UNIT_SP, 16);
                        shopNameView.setTextColor(CContext.getColor(getContext(), R.color.normal_text_color_lite));
                        String strShopName = seller.getShopName();
                        if (TextUtils.isEmpty(strShopName)) {
                            shopNameView.setVisibility(View.GONE);
                        } else {
                            shopNameView.setVisibility(View.VISIBLE);
                            shopNameView.setText(strShopName);
                        }
                        break;
                    }
                    case MultiVendorConfig.ID_PHONE_NUMBER: {
                        vendorPhoneView = addNewTextView(seller_detail);
                        vendorPhoneView.setTextSize(TypedValue.COMPLEX_UNIT_SP, 16);
                        vendorPhoneView.setTextColor(CContext.getColor(getContext(), R.color.normal_text_color_lite));
                        String strPhoneNumber = seller.getPhoneNumber();
                        if (TextUtils.isEmpty(strPhoneNumber)) {
                            vendorPhoneView.setVisibility(View.GONE);
                        } else {
                            vendorPhoneView.setVisibility(View.VISIBLE);
                            vendorPhoneView.setText(strPhoneNumber);
                        }
                        break;
                    }
                    case MultiVendorConfig.ID_SHOP_ADDRESS: {
                        shopAddressView = addNewTextView(seller_detail);
                        shopAddressView.setTextSize(TypedValue.COMPLEX_UNIT_SP, 12);
                        shopAddressView.setTextColor(CContext.getColor(getContext(), R.color.normal_text_color_lite));
                        String strShopAddress = seller.getShopAddress();
                        if (TextUtils.isEmpty(strShopAddress)) {
                            shopAddressView.setVisibility(View.GONE);
                        } else {
                            shopAddressView.setVisibility(View.VISIBLE);
                            shopAddressView.setText(strShopAddress);
                        }
                        break;
                    }
                }
            }
        }

        ImageButton image_vendor_edit_shop_info = (ImageButton) view.findViewById(R.id.image_vendor_edit_shop_info);
        Helper.stylizeVector(image_vendor_edit_shop_info);
        image_vendor_edit_shop_info.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                String tag = Fragment_SellerStoreSettings.class.getSimpleName();
                getActivity().getSupportFragmentManager().beginTransaction()
                        .replace(R.id.content, Fragment_SellerStoreSettings.newInstance(seller, true), tag)
                        .addToBackStack(tag)
                        .commit();
            }
        });
        final RoundedImageView imageView = (RoundedImageView) view.findViewById(R.id.image_vendor_icon);
        if (TextUtils.isEmpty(seller.getAvatarUrl())) {
            this.createSellerIconFromName(seller, imageView, locationView);
        } else {
            Glide.with(getActivity()).load(seller.getAvatarUrl()).asBitmap().centerCrop().listener(new RequestListener<String, Bitmap>() {
                @Override
                public boolean onException(Exception e, String model, Target<Bitmap> target, boolean isFirstResource) {
                    return false;
                }

                @Override
                public boolean onResourceReady(Bitmap resource, String model, Target<Bitmap> target, boolean isFromMemoryCache, boolean isFirstResource) {
                    return false;
                }
            }).into(new BitmapImageViewTarget(imageView) {
                @Override
                protected void setResource(Bitmap resource) {
                    imageView.setImageBitmap(resource);
                }
            });
        }
    }

    public TextView addNewTextView(LinearLayout layout) {
        TextView labelText = new TextView(getActivity());
        labelText.setPadding(Helper.DP(12), Helper.DP(0), Helper.DP(12), Helper.DP(0));
        labelText.setGravity(Gravity.CENTER | Gravity.CENTER_HORIZONTAL);
        layout.addView(labelText, new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));
        return labelText;
    }

    public void updateSellerInfo() {
        if (seller != null) {
            View headerView = View.inflate(getActivity(), R.layout.vendor_profile_header, null);
            myProfileAdapter.addHeader(headerView);
            setVendorProfile(headerView);
        }
    }

    public void refreshSellerInfo(SellerInfo sellerInfo) {
        if (seller != null) {
            vendor_profile_header.setVisibility(View.GONE);
        }
        this.seller = sellerInfo;
        if (seller != null) {
            View headerView = View.inflate(getActivity(), R.layout.vendor_profile_header, null);
            myProfileAdapter.addHeader(headerView);
            setVendorProfile(headerView);
        }
    }

    private void createSellerIconFromName(SellerInfo sellerInfo, RoundedImageView imageView, TextView locationView) {
        String sellerID = sellerInfo.getId();
        if (TextUtils.isEmpty(sellerID)) {
            sellerID = "0";
        }

        Resources resources = getActivity().getResources();
        int[] colors = resources.getIntArray(R.array.material_colors);
        Random random = new Random();
        try {
            random.setSeed(Long.parseLong(sellerID));
        } catch (NumberFormatException e) {
            e.printStackTrace();
        }

        int backgroundColor = colors[random.nextInt(colors.length - 1)];
        String strokeColor = String.format("#66%06X", 0xFFFFFF & backgroundColor);

        GradientDrawable drawable = new GradientDrawable();
        drawable.setShape(GradientDrawable.RECTANGLE);
        drawable.setCornerRadius(Helper.DP(4));
        drawable.setColor(backgroundColor);
        drawable.setStroke(Helper.DP(4), Color.parseColor(strokeColor));
        imageView.setBackground(drawable);

        int iconWidth = resources.getDimensionPixelSize(R.dimen.vendor_icon_large_width);
        int iconHeight = resources.getDimensionPixelSize(R.dimen.vendor_icon_large_height);

        Bitmap bitmap = Bitmap.createBitmap(iconWidth, iconHeight, Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(bitmap);

        final int textSize = resources.getDimensionPixelSize(R.dimen.vendor_icon_large_text_size);
        TextPaint paint = new TextPaint();
        paint.setTypeface(Typeface.create(Typeface.SANS_SERIF, Typeface.BOLD));
        paint.setColor(Color.WHITE);
        paint.setTextAlign(Paint.Align.CENTER);
        paint.setTextSize(textSize);
        paint.setAntiAlias(true);

        String initials = StringUtils.getInitials(sellerInfo.getTitle(), 2);

        Rect textBounds = new Rect();
        paint.getTextBounds(initials, 0, initials.length() - 1, textBounds);
        canvas.drawText(initials, iconWidth / 2, (iconHeight + textBounds.height()) / 2, paint);
        imageView.setImageBitmap(bitmap);

        if (locationView != null) {
            if (TextUtils.isEmpty(sellerInfo.getSellerFirstLocation())) {
                locationView.setVisibility(View.GONE);
            } else {
                Drawable locationDrawable = ContextCompat.getDrawable(getContext(), R.drawable.ic_vc_location);
                DrawableCompat.setTint(locationDrawable, backgroundColor);
                locationView.setCompoundDrawablesWithIntrinsicBounds(locationDrawable, null, null, null);
                locationView.setText(sellerInfo.getSellerFirstLocation());
            }
        }
    }

    @Override
    public void onBackPressed() {
        if (MultiVendorConfig.isSellerApp()) {
            Helper.getConfirmation(
                    getActivity(),
                    getString(L.string.exit_message),
                    false,
                    new DialogInterface.OnClickListener() {
                        public void onClick(DialogInterface dialog, int id) {
                            TMStoreApp.exit(getActivity());
                        }
                    },
                    null);
        }
    }
}