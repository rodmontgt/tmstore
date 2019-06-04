package com.twist.tmstore.adapters;

import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.twist.dataengine.entities.AuctionInfo;
import com.twist.tmstore.L;
import com.twist.tmstore.R;
import com.utils.Helper;
import com.utils.HtmlCompat;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

/**
 * Created by Twist Mobile on 11/9/2017.
 */

public class AuctionHistoryAdapter extends RecyclerView.Adapter<AuctionHistoryAdapter.AuctionHistoryViewHolder> {

    private List<AuctionInfo.AuctionHistory> auctionHistoryList;

    public AuctionHistoryAdapter(List<AuctionInfo.AuctionHistory> historyList) {
        this.auctionHistoryList = historyList;
    }

    @Override
    public AuctionHistoryViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View itemView = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_auction_history, parent, false);
        return new AuctionHistoryViewHolder(itemView);
    }

    @Override
    public void onBindViewHolder(AuctionHistoryViewHolder holder, int position) {
        AuctionInfo.AuctionHistory auctionHistory = auctionHistoryList.get(position);
        try {
            DateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
            Date formattedDate = sdf.parse(auctionHistory.date);
            final Calendar calendarDate = Calendar.getInstance();
            calendarDate.setTime(formattedDate);

            Date date1 = calendarDate.getTime();
            SimpleDateFormat simpleDateFormat = new SimpleDateFormat("MMM,dd,yyyy hh:mm aaa");
            String finalDate = simpleDateFormat.format(date1);

            StringBuilder strHistoryDetail = new StringBuilder();
            strHistoryDetail.append("<b>" + L.getString(L.string.title_date) + "</b> " + finalDate);

            strHistoryDetail.append("&nbsp;<strong>|</strong>&nbsp;");
            strHistoryDetail.append("<b>" + L.getString(L.string.title_bid) + "</b> " + Helper.appendCurrency(auctionHistory.bid));

            strHistoryDetail.append("&nbsp;<strong>|</strong>&nbsp;");
            strHistoryDetail.append("<b>" + L.getString(L.string.title_user) + "</b> " + auctionHistory.username);

            holder.title_auction_history_detail.setText(HtmlCompat.fromHtml(strHistoryDetail.toString()));
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public int getItemCount() {
        return auctionHistoryList.size();
    }

    public class AuctionHistoryViewHolder extends RecyclerView.ViewHolder {

        private TextView title_auction_history_detail;

        public AuctionHistoryViewHolder(View itemView) {
            super(itemView);
            title_auction_history_detail = (TextView) itemView.findViewById(R.id.title_auction_history_detail);
        }
    }

    public void addAll(List<AuctionInfo.AuctionHistory> data) {
        auctionHistoryList.addAll(data);
        notifyDataSetChanged();
    }
}
