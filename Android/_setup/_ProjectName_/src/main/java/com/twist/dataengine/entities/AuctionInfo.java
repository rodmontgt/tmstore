package com.twist.dataengine.entities;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Twist Mobile on 11/9/2017.
 */

public class AuctionInfo {

    public String auction_bid_count;
    public String auction_regular_price;
    public String auction_sale_price;
    public String auction_price;

    public String auction_start_price;
    public String auction_bid_increment;

    public String auction_manage_stock;
    public String auction_stock;
    public String auction_stock_status;

    public String auction_dates_from;
    public String auction_dates_to;

    public String auction_item_condition;
    public String auction_type;

    public String auction_current_bid;
    public String auction_start;
    public String timezone;

    public List<AuctionHistory> auctionHistoryList = new ArrayList<>();

    public AuctionHistory getAuctionHistory(String id) {
        for (AuctionHistory auctionHistory : auctionHistoryList) {
            if (auctionHistory.id.equalsIgnoreCase(id)) {
                return auctionHistory;
            }
        }
        return null;
    }

    public static class AuctionHistory {
        public String id;
        public String userid;
        public String username;
        public String auction_id;
        public String bid;
        public String date;
        public String proxy;

    }
}
