package com.twist.tmstore.fragments;

import android.os.Bundle;
import android.support.v7.widget.GridLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.twist.tmstore.BaseFragment;
import com.twist.tmstore.R;
import com.twist.tmstore.adapters.CategoryAdapter;
import com.utils.Helper;

import java.util.List;

public class Fragment_ItemList extends BaseFragment {

    RecyclerView recyclerView;

    List items;
    String itemType;
    String title;

    public static Fragment_ItemList newInstance(List items, String itemType, String title) {
        Fragment_ItemList fragment = new Fragment_ItemList();
        fragment.items = items;
        fragment.itemType = itemType;
        fragment.title = title;
        return fragment;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View rootView = inflater.inflate(R.layout.fragment_home, container, false);

        recyclerView = (RecyclerView) rootView.findViewById(R.id.recyclerView);

        switch (itemType.toLowerCase()) {
            case "vendor":
            case "vendors":
            case "seller":
            case "sellers": {
                final int columns = Helper.getCategoryLayoutColumns();
                RecyclerView.LayoutManager layoutManager = new GridLayoutManager(getActivity(), columns);
                ((GridLayoutManager) layoutManager).setSpanSizeLookup(new GridLayoutManager.SpanSizeLookup() {
                    @Override
                    public int getSpanSize(int position) {
                        if (position == 0 || position > items.size()) {
                            return columns;
                        }
                        return 1;
                    }
                });

                CategoryAdapter adapter = new CategoryAdapter<>(items, 4);
                recyclerView.setAdapter(adapter);
                recyclerView.setHasFixedSize(true);
                recyclerView.setLayoutManager(layoutManager);
                break;
            }
            case "cat":
            case "category":
            case "categories":
            default: {
                final int columns = Helper.getCategoryLayoutColumns();
                RecyclerView.LayoutManager layoutManager = new GridLayoutManager(getActivity(), columns);
                ((GridLayoutManager) layoutManager).setSpanSizeLookup(new GridLayoutManager.SpanSizeLookup() {
                    @Override
                    public int getSpanSize(int position) {
                        if (position == 0 || position > items.size()) {
                            return columns;
                        }
                        return 1;
                    }
                });

                CategoryAdapter adapter = new CategoryAdapter<>(items, 4);
                recyclerView.setHasFixedSize(true);
                recyclerView.setLayoutManager(layoutManager);
                recyclerView.setAdapter(adapter);
                break;
            }
        }

        if (Helper.isValidString(title)) {
            setTitle(title);
        }

        return rootView;
    }

}