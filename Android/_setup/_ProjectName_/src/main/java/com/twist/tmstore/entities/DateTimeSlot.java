package com.twist.tmstore.entities;

import java.util.ArrayList;
import java.util.Calendar;

/**
 * Created by Twist Mobile on 12-12-2016.
 */
public class DateTimeSlot {
    private String dateString;

    private ArrayList<TimeSlot> timeSlots;

    public DateTimeSlot(String dateString) {
        this.dateString = dateString;
    }

    public String getDateString() {
        return dateString;
    }

    public void setTimeSlots(ArrayList<TimeSlot> timeSlots) {
        this.timeSlots = timeSlots;
    }

    public ArrayList<TimeSlot> getTimeSlots() {
        return timeSlots;
    }

    public Calendar getCalendarDay() {
        String[] values = getDateString().split("/");
        Calendar day = Calendar.getInstance();
        day.set(Integer.parseInt(values[2]), Integer.parseInt(values[1]) - 1, Integer.parseInt(values[0]));
        return day;
    }

    @Override
    public String toString() {
        return dateString + " - " + timeSlots;
    }
}
