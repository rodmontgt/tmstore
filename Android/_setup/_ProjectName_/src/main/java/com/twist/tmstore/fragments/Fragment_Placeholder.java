package com.twist.tmstore.fragments;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.twist.tmstore.BaseFragment;
import com.twist.tmstore.R;

public class Fragment_Placeholder extends BaseFragment {
    private String text;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setHasOptionsMenu(true);
    }

    public static Fragment_Placeholder newInstance(final String text) {
        Fragment_Placeholder fragment = new Fragment_Placeholder();
        fragment.text = text;
        return fragment;
    }

    public Fragment_Placeholder() {
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_placeholder, container, false);
        TextView empty = (TextView) view.findViewById(R.id.text_empty);
        empty.setText(text);
        return view;
    }
}