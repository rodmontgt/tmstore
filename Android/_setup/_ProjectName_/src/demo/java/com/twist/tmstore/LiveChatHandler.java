package com.twist.tmstore;

import android.content.Context;
import android.content.Intent;

import com.twist.tmstore.entities.AppUser;


public class LiveChatHandler {

    public static void startChatScreen(Context context) {
        Intent intent = new Intent(context, com.livechatinc.inappchat.ChatWindowActivity.class);
        intent.putExtra(com.livechatinc.inappchat.ChatWindowActivity.KEY_LICENCE_NUMBER, context.getString(R.string.live_chat_license_number));
        //intent.putExtra(com.livechatinc.inappchat.ChatWindowActivity.KEY_GROUP_ID, "");
        intent.putExtra(com.livechatinc.inappchat.ChatWindowActivity.KEY_VISITOR_NAME, AppUser.hasSignedIn() ? AppUser.getInstance().first_name : context.getString(R.string.live_chat_user_name));
        intent.putExtra(com.livechatinc.inappchat.ChatWindowActivity.KEY_VISITOR_EMAIL, AppUser.hasSignedIn() ? AppUser.getEmail() : "");
        context.startActivity(intent);
    }
}
