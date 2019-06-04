package com.twist.tmstore.fragments;

import android.graphics.Paint;
import android.os.Bundle;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.twist.tmstore.BaseFragment;
import com.twist.tmstore.Constants;
import com.twist.tmstore.L;
import com.twist.tmstore.R;
import com.twist.tmstore.entities.AppInfo;
import com.twist.tmstore.entities.ContactDetail;
import com.utils.Helper;
import com.utils.HtmlCompat;
import com.utils.Log;
import com.utils.customviews.BannerImage;

public class Fragment_AboutCool extends BaseFragment {
    private String lng;
    private String lat;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setHasOptionsMenu(true);
    }

    public static Fragment_AboutCool newInstance() {
        return new Fragment_AboutCool();
    }

    public Fragment_AboutCool() {
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View rootView = inflater.inflate(R.layout.fragment_about_cool, container, false);

        setActionBarHomeAsUpIndicator();
        getBaseActivity().restoreActionBar();

        LinearLayout content = (LinearLayout) rootView.findViewById(R.id.content);

        for (ContactDetail contactDetail : AppInfo.contactDetails) {
            switch (contactDetail.type.toLowerCase()) {
                case Constants.Key.CONTACT_TYPE_IMAGE:
                    addImage(content, contactDetail.label, contactDetail.intro);
                    break;
                case Constants.Key.CONTACT_TYPE_ADDRESS:
                    addAddressView(content, contactDetail.label, contactDetail.intro);
                    break;
                case Constants.Key.CONTACT_TYPE_MOBILE:
                case Constants.Key.CONTACT_TYPE_PHONE:
                    addPhoneNumberView(content, contactDetail.label, contactDetail.intro);
                    break;
                case Constants.Key.CONTACT_TYPE_EMAIL:
                    addEmailView(content, contactDetail.label, contactDetail.intro);
                    break;
                case Constants.Key.CONTACT_TYPE_WEBSITE:
                    addWebsite(content, contactDetail.label, contactDetail.intro);
                    break;
                case Constants.Key.CONTACT_TYPE_GEOLOCATION:
                    addMap(content, contactDetail.label, contactDetail.intro);
                    break;
                default:
                    addCommonDetail(content, contactDetail.label, contactDetail.intro);
                    break;
            }
        }

        setTitle(getString(L.string.title_about));

        Log.commitBuffer();

        return rootView;
    }

    private void addImage(LinearLayout parentView, String title, String url) {
        LinearLayout linearLayout = new LinearLayout(parentView.getContext());
        linearLayout.setGravity(Gravity.CENTER);
        linearLayout.setPadding(DP(5), DP(5), DP(5), DP(5));
        linearLayout.setOrientation(LinearLayout.VERTICAL);
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);

        ImageView imageView = new ImageView(parentView.getContext());
        imageView.setPadding(DP(5), DP(5), DP(5), DP(5));
        imageView.setScaleType(ImageView.ScaleType.CENTER_INSIDE);
        if (Helper.isValidString(url)) {
            Glide.with(getContext())
                    .load(url)
                    .error(R.drawable.app_icon)
                    .into(imageView);
        } else {
            Glide.with(getContext())
                    .load(R.drawable.app_icon)
                    .error(R.drawable.app_splash)
                    .into(imageView);
        }
        linearLayout.addView(imageView, new ViewGroup.LayoutParams(DP(200), DP(200)));


        if (Helper.isValidString(title)) {
            TextView textTitle = new TextView(parentView.getContext());
            textTitle.setText(HtmlCompat.fromHtml(title));
            textTitle.setPadding(DP(0), DP(5), DP(0), DP(5));
            Helper.setTextAppearance(getContext(), textTitle, android.R.style.TextAppearance_Medium);
            linearLayout.addView(textTitle, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT));
        }

        parentView.addView(linearLayout, lp);
    }

    private void addCommonDetail(LinearLayout parentView, String title, String data) {
        LinearLayout linearLayout = new LinearLayout(parentView.getContext());
        linearLayout.setGravity(Gravity.LEFT | Gravity.CENTER_VERTICAL);
        linearLayout.setPadding(DP(5), DP(5), DP(5), DP(5));
        linearLayout.setOrientation(LinearLayout.VERTICAL);
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);

        TextView textTitle = new TextView(parentView.getContext());
        textTitle.setPadding(DP(0), DP(5), DP(0), DP(5));
        Helper.setTextAppearance(getContext(), textTitle, android.R.style.TextAppearance_Medium);
        if (Helper.isValidString(title)) {
            textTitle.setText(HtmlCompat.fromHtml(title));
        } else {
            textTitle.setText(getString(L.string.introduction));
        }
        linearLayout.addView(textTitle, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT));

        if (Helper.isValidString(data)) {
            TextView textContent = new TextView(parentView.getContext());
            textContent.setText(HtmlCompat.fromHtml(data));
            linearLayout.addView(textContent, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT));
        }

        parentView.addView(linearLayout, lp);
    }

    private void addPhoneNumberView(LinearLayout parentView, String title, String phoneNumbers) {
        LinearLayout linearLayout = new LinearLayout(parentView.getContext());
        linearLayout.setGravity(Gravity.LEFT);
        linearLayout.setPadding(DP(5), DP(5), DP(5), DP(5));
        linearLayout.setOrientation(LinearLayout.VERTICAL);
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);

        TextView textTitle = new TextView(parentView.getContext());
        textTitle.setPadding(DP(0), DP(5), DP(0), DP(5));
        Helper.setTextAppearance(getContext(), textTitle, android.R.style.TextAppearance_Medium);
        if (Helper.isValidString(title)) {
            textTitle.setText(HtmlCompat.fromHtml(title));
        } else {
            textTitle.setText(getString(L.string.call_or_whatsapp));
        }
        linearLayout.addView(textTitle, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT));

        String phoneNumberTokens[] = phoneNumbers.split(",");
        for (int i = 0; i < phoneNumberTokens.length; i++) {
            LinearLayout linearLayoutLine = new LinearLayout(parentView.getContext());
            linearLayoutLine.setGravity(Gravity.CENTER_VERTICAL);
            linearLayoutLine.setPadding(DP(5), DP(5), DP(5), DP(5));
            linearLayoutLine.setOrientation(LinearLayout.HORIZONTAL);
            LinearLayout.LayoutParams lp2 = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);

            ImageView imageView = new ImageView(parentView.getContext());
            imageView.setImageResource(R.drawable.ic_vc_call);
            imageView.setPadding(DP(5), DP(5), DP(5), DP(5));
            imageView.setScaleType(ImageView.ScaleType.CENTER_INSIDE);
            linearLayoutLine.addView(imageView, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT));

            TextView textView = new TextView(parentView.getContext());
            textView.setText(phoneNumberTokens[i]);
            Helper.setTextAppearance(getContext(), textView, android.R.style.TextAppearance_Small);
            textView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    String phoneNumber = ((TextView) v).getText().toString();
                    Helper.callTo(getActivity(), phoneNumber);
                }
            });
            linearLayoutLine.addView(textView, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT));

            linearLayout.addView(linearLayoutLine, lp2);
        }

        parentView.addView(linearLayout, lp);
    }

    private void addEmailView(LinearLayout parentView, String title, String emailIds) {

        LinearLayout linearLayout = new LinearLayout(parentView.getContext());
        linearLayout.setGravity(Gravity.LEFT);
        linearLayout.setPadding(DP(5), DP(5), DP(5), DP(5));
        linearLayout.setOrientation(LinearLayout.VERTICAL);
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);

        TextView textTitle = new TextView(parentView.getContext());
        textTitle.setPadding(DP(0), DP(5), DP(0), DP(5));
        Helper.setTextAppearance(getContext(), textTitle, android.R.style.TextAppearance_Medium);
        if (Helper.isValidString(title)) {
            textTitle.setText(HtmlCompat.fromHtml(title));
        } else {
            textTitle.setText(getString(L.string.email));
        }
        linearLayout.addView(textTitle, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT));

        String emailIdsTokens[] = emailIds.split(",");
        for (int i = 0; i < emailIdsTokens.length; i++) {
            LinearLayout linearLayoutLine = new LinearLayout(parentView.getContext());
            linearLayoutLine.setGravity(Gravity.CENTER_VERTICAL);
            linearLayoutLine.setPadding(DP(5), DP(5), DP(5), DP(5));
            linearLayoutLine.setOrientation(LinearLayout.HORIZONTAL);
            LinearLayout.LayoutParams lp2 = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);

            ImageView imageView = new ImageView(parentView.getContext());
            imageView.setPadding(DP(5), DP(5), DP(5), DP(5));
            imageView.setImageResource(R.drawable.ic_vc_contact);
            imageView.setScaleType(ImageView.ScaleType.CENTER_INSIDE);
            linearLayoutLine.addView(imageView, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT));

            TextView textView = new TextView(parentView.getContext());
            textView.setText(emailIdsTokens[i]);
            Helper.setTextAppearance(getContext(), textView, android.R.style.TextAppearance_Small);
            textView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    String emailId = ((TextView) v).getText().toString();
                    Helper.emailTo(getActivity(), emailId);
                }
            });
            linearLayoutLine.addView(textView, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT));
            linearLayout.addView(linearLayoutLine, lp2);
        }

        parentView.addView(linearLayout, lp);
    }


    private void addAddressView(LinearLayout parentView, String title, String data) {
        LinearLayout linearLayout = new LinearLayout(parentView.getContext());
        linearLayout.setGravity(Gravity.LEFT);
        linearLayout.setPadding(DP(10), DP(10), DP(10), DP(10));
        linearLayout.setOrientation(LinearLayout.VERTICAL);
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);

        TextView textTitle = new TextView(parentView.getContext());
        textTitle.setPadding(DP(0), DP(5), DP(0), DP(5));
        Helper.setTextAppearance(getContext(), textTitle, android.R.style.TextAppearance_Medium);
        if (Helper.isValidString(title)) {
            textTitle.setText(HtmlCompat.fromHtml(title));
        } else {
            textTitle.setText(getString(L.string.address));
        }
        linearLayout.addView(textTitle, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT));

        if (Helper.isValidString(data)) {
            TextView textContent = new TextView(parentView.getContext());
            textContent.setText(HtmlCompat.fromHtml(data));
            linearLayout.addView(textContent, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT));
        }
        parentView.addView(linearLayout, lp);
    }

    private void addMap(LinearLayout parentView, String title, String data) {
        LinearLayout linearLayout = new LinearLayout(parentView.getContext());
        linearLayout.setGravity(Gravity.LEFT);
        linearLayout.setPadding(DP(10), DP(10), DP(10), DP(10));
        linearLayout.setOrientation(LinearLayout.VERTICAL);
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);

        TextView textTitle = new TextView(parentView.getContext());
        textTitle.setPadding(DP(0), DP(5), DP(0), DP(5));
        Helper.setTextAppearance(getContext(), textTitle, android.R.style.TextAppearance_Medium);
        if (Helper.isValidString(title)) {
            textTitle.setText(HtmlCompat.fromHtml(title));
        } else {
            textTitle.setText(getString(L.string.location));
        }
        linearLayout.addView(textTitle, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT));

        String mapLatLng = data;
        mapLatLng = mapLatLng.substring(1, mapLatLng.length() - 1);
        String[] mapTokens = mapLatLng.split(",");
        lat = mapTokens[0];
        lng = mapTokens[1];


        BannerImage imageView = new BannerImage(parentView.getContext());
        imageView.setAdjustViewBounds(true);
        imageView.setScaleType(ImageView.ScaleType.FIT_CENTER);
        int width = 640;
        int height = 480;

        String urlMap = "https://maps.googleapis.com/maps/api/staticmap?center=" + lat + "," + lng + "&zoom=14&size=" + width + "x" + height + "&markers=color:red%7C" + lat + "," + lng;
        Glide.with(getContext()).load(urlMap).into(imageView);
        imageView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Helper.openLocation(getActivity(), Float.parseFloat(lat), Float.parseFloat(lng));
            }
        });
        linearLayout.addView(imageView, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT));
        parentView.addView(linearLayout, lp);

    }

    private void addWebsite(LinearLayout parentView, String title, String webUrls) {

        LinearLayout linearLayout = new LinearLayout(parentView.getContext());
        linearLayout.setGravity(Gravity.CENTER);
        linearLayout.setPadding(DP(5), DP(5), DP(5), DP(5));
        linearLayout.setOrientation(LinearLayout.VERTICAL);
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);

        TextView textTitle = new TextView(parentView.getContext());
        textTitle.setPadding(DP(0), DP(5), DP(0), DP(5));
        Helper.setTextAppearance(getContext(), textTitle, android.R.style.TextAppearance_Medium);
        if (Helper.isValidString(title)) {
            textTitle.setText(HtmlCompat.fromHtml(title));
        } else {
            textTitle.setText(getString(L.string.website));
        }
        linearLayout.addView(textTitle, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT));

        String webUrlTokens[] = webUrls.split(",");
        for (int i = 0; i < webUrlTokens.length; i++) {
            LinearLayout linearLayoutLine = new LinearLayout(parentView.getContext());
            linearLayoutLine.setGravity(Gravity.CENTER_VERTICAL);
            linearLayoutLine.setPadding(DP(5), DP(5), DP(5), DP(5));
            linearLayoutLine.setOrientation(LinearLayout.HORIZONTAL);
            LinearLayout.LayoutParams lp2 = new LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);

            TextView textView = new TextView(parentView.getContext());
            textView.setText(webUrlTokens[i]);
            textView.setPaintFlags(textView.getPaintFlags() | Paint.UNDERLINE_TEXT_FLAG);
            Helper.setTextAppearance(getContext(), textView, android.R.style.TextAppearance_Small);
            textView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    String webUrl = ((TextView) v).getText().toString();
                    Helper.confirmAndVisitSite(getActivity(), webUrl);
                }
            });
            linearLayoutLine.addView(textView, new ViewGroup.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT));
            linearLayout.addView(linearLayoutLine, lp2);
        }

        parentView.addView(linearLayout, lp);
    }

    int DP(int measure) {
        return Helper.DP(measure, getResources());
    }


}