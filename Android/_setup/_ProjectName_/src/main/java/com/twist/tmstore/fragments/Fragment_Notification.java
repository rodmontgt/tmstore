package com.twist.tmstore.fragments;

import android.graphics.Paint;
import android.os.Bundle;
import android.support.v7.widget.CardView;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.helper.ItemTouchHelper;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.TextView;

import com.twist.tmstore.BaseFragment;
import com.twist.tmstore.Constants;
import com.twist.tmstore.L;
import com.twist.tmstore.MainActivity;
import com.twist.tmstore.R;
import com.twist.tmstore.adapters.Adapter_NotificationList;
import com.twist.tmstore.entities.Notification;
import com.twist.tmstore.listeners.ModificationListener;
import com.utils.Helper;
import com.utils.customviews.progressbar.CircleProgressBar;

/**
 * Created by Twist Mobile on 03-01-2017.
 */

public class Fragment_Notification extends BaseFragment {

    private RecyclerView recyclerView;
    public Adapter_NotificationList adapter_Notification_list;
    private CircleProgressBar progress_fullnotificationdata;
    private Paint p = new Paint();
    private CardView text_empty;
    private Button btn_back;
    private TextView txt_NoNotification;

    public static Fragment_Notification newInstance() {
        return new Fragment_Notification();
    }

    public Fragment_Notification() {
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        final View view = inflater.inflate(R.layout.fragment_notifications, container, false);

        setActionBarHomeAsUpIndicator();
        getBaseActivity().restoreActionBar();
        setTitle(getString(L.string.title_notification));

        initView(view);
        return view;
    }

    private void initView(View view) {
        recyclerView = (RecyclerView) view.findViewById(R.id.notifications_recyclerview);
        recyclerView.setLayoutManager(new LinearLayoutManager(getContext(), LinearLayoutManager.VERTICAL, false));

        adapter_Notification_list = new Adapter_NotificationList(getActivity());
        recyclerView.setAdapter(adapter_Notification_list);

        ItemTouchHelper.Callback callback = new MovieTouchHelper(adapter_Notification_list);
        ItemTouchHelper helper = new ItemTouchHelper(callback);
        helper.attachToRecyclerView(recyclerView);

        text_empty = (CardView) view.findViewById(R.id.text_empty);
        txt_NoNotification = (TextView) view.findViewById(R.id.text_no_notifications_found);
        txt_NoNotification.setText(getString(L.string.no_notifications_found));

        btn_back = (Button) view.findViewById(R.id.btn_back);
        btn_back.setText(getString(L.string.keep_shopping));
        Helper.stylize(btn_back);
        btn_back.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                MainActivity.mActivity.onNavigationDrawerItemSelected(Constants.MENU_ID_HOME, -1);
            }
        });
        adapter_Notification_list.setModificationListener(new ModificationListener() {
            @Override
            public void onModificationDone() {
                if (Notification.getAllNotification().size() == 0) {
                    text_empty.setVisibility(View.VISIBLE);
                } else {
                    text_empty.setVisibility(View.GONE);
                }
                MainActivity.mActivity.reloadMenu();
            }
        });
    }

    @Override
    public void onResume() {
        super.onResume();
        adapter_Notification_list.addNotifications(Notification.getAllNotification());
        if (Notification.getAllNotification().size() == 0) {
            text_empty.setVisibility(View.VISIBLE);
        } else {
            text_empty.setVisibility(View.GONE);
        }
    }

    class MovieTouchHelper extends ItemTouchHelper.SimpleCallback {
        private Adapter_NotificationList adapter_notificationList;

        MovieTouchHelper(Adapter_NotificationList adapter_notificationList) {
            super(ItemTouchHelper.UP | ItemTouchHelper.DOWN, ItemTouchHelper.LEFT | ItemTouchHelper.RIGHT);
            this.adapter_notificationList = adapter_notificationList;
        }

        @Override
        public boolean onMove(RecyclerView recyclerView, RecyclerView.ViewHolder viewHolder, RecyclerView.ViewHolder target) {
            adapter_notificationList.swap(viewHolder.getAdapterPosition(), target.getAdapterPosition());
            return true;
        }

        @Override
        public void onSwiped(RecyclerView.ViewHolder viewHolder, int direction) {
            adapter_notificationList.remove(viewHolder.getAdapterPosition());
        }

    }

}
