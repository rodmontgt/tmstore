package com.twist.dataengine.entities;

/**
 * Created by Twist Mobile on 8/21/2017.
 */

public class RewardPoint {

    private static RewardPoint mRewardPoint = null;

    private float mRewardDiscount;
    private int mRewardPoints;

    public static RewardPoint getInstance() {
        if (mRewardPoint == null) {
            mRewardPoint = new RewardPoint();
        }
        return mRewardPoint;
    }

    public int getRewardPoints() {
        return mRewardPoints;
    }

    public void setRewardsPoints(int rewardPoints) {
        mRewardPoints = rewardPoints;
    }

    public void setRewardDiscount(float rewardPoints) {
        mRewardDiscount = rewardPoints;
    }

    public float getRewardDiscount() {
        return mRewardDiscount;
    }


    public double conversionUnitVal = -1;
    public double redeemUnitVal = -1;
    public double reviewOnProductUnitVal = -1;

}
