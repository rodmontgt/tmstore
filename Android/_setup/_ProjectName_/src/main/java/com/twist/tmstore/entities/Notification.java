package com.twist.tmstore.entities;

import android.os.Parcel;
import android.os.Parcelable;

import com.activeandroid.Model;
import com.activeandroid.annotation.Column;
import com.activeandroid.annotation.Table;
import com.activeandroid.query.Select;
import com.twist.tmstore.L;
import com.utils.JsonHelper;

import org.json.JSONObject;

import java.text.SimpleDateFormat;
import java.util.List;

@Table(name = "Notification")
public class Notification extends Model implements Parcelable {

    public enum Type {
        DEFAULT(0),
        CATEGORY(1),
        PRODUCT(2),
        CART(3),
        WISHLIST(4),
        ORDER(5),
        FIXED_PRODUCT(6),
        SELLER_ORDER(7);

        public static Type from(int type) {
            try {
                return values()[type];
            } catch (Exception ignored) {
            }
            return DEFAULT;
        }

        private final int value;

        Type(int value) {
            this.value = value;
        }

        public int getValue() {
            return value;
        }
    }

    @Column(name = "type")
    public Type type;

    @Column(name = "notification_id")
    public int id;

    @Column(name = "content")
    public String content;

    @Column(name = "alert")
    public String alert;

    @Column(name = "title")
    public String title;

    @Column(name = "arrival_time")
    public long time;

    @Column(name = "notifyId")
    public String notifyId;

    @Column(name = "is_read")
    public int read;

    public Notification() {
        this.type = Type.DEFAULT;
        this.id = -1;
        this.content = "";
        this.alert = "";
        this.title = "";
        this.notifyId = "";
        this.read = 0;
    }

    protected Notification(Parcel in) {
        type = Type.from(in.readInt());
        id = in.readInt();
        content = in.readString();
        alert = in.readString();
        title = in.readString();
        notifyId = in.readString();
        time = in.readLong();
    }

    public static List<Notification> getAllNotification() {
        return new Select()
                .from(Notification.class)
                .orderBy("arrival_time ASC")
                .execute();
    }

    public static Notification save(String jsonData) {
        Notification notification = create(jsonData);
        notification.save();
        return notification;
    }

    public static Notification create(String jsonData) {
        Notification notification = null;
        try {
            notification = new Notification();
            JSONObject mainObject = new JSONObject(jsonData);
            notification.setAlert(JsonHelper.getString(mainObject, "alert", ""));
            notification.setTitle(JsonHelper.getString(mainObject, "title", L.getString(L.string.app_name)));
            if (mainObject.has("data_array")) {
                JSONObject dataJson = new JSONObject(mainObject.getString("data_array"));
                notification.setNotificationId(JsonHelper.getInt(dataJson, "id", 0));
                notification.setType(Type.from(JsonHelper.getInt(dataJson, "type", 0)));
                notification.setContent(JsonHelper.getString(dataJson, "content", ""));
                notification.setNotifyId(JsonHelper.getString(dataJson, "notify_id", ""));
            } else {
                notification.setNotificationId(0);
                notification.setType(Type.from(0));
                notification.setContent("");
                notification.setNotifyId("");
            }
            notification.time = System.currentTimeMillis();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return notification;
    }


    public static final Creator<Notification> CREATOR = new Creator<Notification>() {
        @Override
        public Notification createFromParcel(Parcel in) {
            return new Notification(in);
        }

        @Override
        public Notification[] newArray(int size) {
            return new Notification[size];
        }
    };

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeInt(type.getValue());
        dest.writeInt(id);
        dest.writeString(content);
        dest.writeString(alert);
        dest.writeString(title);
        dest.writeString(notifyId);
        dest.writeLong(time);
    }

    public Type getType() {
        return type;
    }

    public void setType(Type type) {
        this.type = type;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public int getNotificationId() {
        return id;
    }

    public void setNotificationId(int id) {
        this.id = id;
    }

    public String getAlert() {
        return alert;
    }

    public void setAlert(String alert) {
        this.alert = alert;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getNotifyId() {
        return notifyId;
    }

    public boolean isRead() {
        return read == 1;
    }

    public void setRead() {
        if (read == 0) {
            read = 1;
            save();
        }
    }

    public void setNotifyId(String notifyId) {
        this.notifyId = notifyId;
    }


    public String getTime() {
        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy hh:mm");
        return sdf.format(time);
    }

    @Override
    public String toString() {
        return "Notification{" +
                "type=" + type +
                ", id=" + id +
                ", content='" + content + '\'' +
                ", alert='" + alert + '\'' +
                ", title='" + title + '\'' +
                ", time=" + time +
                ", notifyId='" + notifyId + '\'' +
                ", read=" + read +
                '}';
    }
}