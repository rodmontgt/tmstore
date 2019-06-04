package com.utils;

/**
 * Created by Twist Mobile on 3/29/2016.
 */
public class TimeDebugger {
    static Long currentTime;
    static Long previousTime;

    public static void printDiff(){
        currentTime = System.currentTimeMillis();
        Log.d("--## time diff: ["+(currentTime-previousTime)+"] ##--");
        previousTime = currentTime;
    }

    public static void printDiff(String chkPoint){
        currentTime = System.currentTimeMillis();
        Log.d("--## time diff at ["+chkPoint+"] : ["+(currentTime-previousTime)+"] ##--");
        previousTime = currentTime;
    }

    public static void reset(){
        previousTime = System.currentTimeMillis();
    }
}
