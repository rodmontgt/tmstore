package oauthtester;

import java.io.IOException;
import java.io.InputStream;
import java.io.UnsupportedEncodingException;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URLEncoder;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedList;
import java.util.List;

import org.apache.commons.codec.binary.Base64;
import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.client.utils.URLEncodedUtils;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.params.HttpParams;

import javax.crypto.Mac;
import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;

/**
 * Created by Ankur on 1/5/2016.
 */
public class OAuthRequest
{
    public interface RequestListener<T>
    {
        void onRequestCompleted(T object);
        void onRequestFailed(Exception error);
    }

    public static Comparator<NameValuePair> nameValuePairComparator= new Comparator() {
        @Override
        public int compare(Object param1, Object param2) {
            return ((NameValuePair)param1).getName().compareTo(((NameValuePair)param2).getName());
        }
    };

    private static String oauth_consumer_key = "";
    private static String oauth_consumer_secret = "";
    private static final String HMAC_SHA1 = "HmacSHA1";
    private static final String ENC = "UTF-8";
    private static Base64 base64 = new Base64();

    public static boolean isDebugLog() {
        return debugLog;
    }

    public static void setDebugLog(boolean debugLog) {
        OAuthRequest.debugLog = debugLog;
    }

    private static boolean debugLog = false;



    public static void setParams(String key, String secret)
    {
        oauth_consumer_key = key;
        oauth_consumer_secret = secret;
    }


    private static String getSignature(String methodType, String url, String params)
            throws UnsupportedEncodingException, NoSuchAlgorithmException,
            InvalidKeyException
    {

        StringBuilder base = new StringBuilder();
        base.append(methodType+"&");
        base.append(url);
        base.append("&");
        base.append(params);
        //System.out.println("Stirng for oauth_signature generation:" + base);
        // yea, don't ask me why, it is needed to append a "&" to the end of
        // secret key.
        byte[] keyBytes = (oauth_consumer_secret + "&").getBytes(ENC);

        SecretKey key = new SecretKeySpec(keyBytes, HMAC_SHA1);

        Mac mac = Mac.getInstance(HMAC_SHA1);
        mac.init(key);

        // encode it, base64 it, change it to string and return.
        return new String(base64.encode(mac.doFinal(base.toString().getBytes(ENC))), ENC).trim();
    }

    public static String getSignature(String email, String password)
            throws UnsupportedEncodingException, NoSuchAlgorithmException,
            InvalidKeyException
    {

        StringBuilder base = new StringBuilder();
        base.append(email);
        //System.out.println("Stirng for oauth_signature generation:" + base);
        byte[] keyBytes = (password + "&").getBytes(ENC);
        SecretKey key = new SecretKeySpec(keyBytes, HMAC_SHA1);
        Mac mac = Mac.getInstance(HMAC_SHA1);
        mac.init(key);
        return new String(base64.encode(mac.doFinal(base.toString().getBytes(ENC))), ENC).trim();
    }

    public static String getFinalURL(final String url, final List<NameValuePair> extraParams)
    {
        try
        {
            final List<NameValuePair> params = new LinkedList<NameValuePair>();

            if(extraParams != null)
            {
                params.addAll(extraParams);
            }

            params.add(new BasicNameValuePair("filter[limit]"		, "100"));
            params.add(new BasicNameValuePair("oauth_consumer_key"	, oauth_consumer_key));
            params.add(new BasicNameValuePair("oauth_nonce"		, ((int) (Math.random() * 100000000))+"")); //"aaaaaddddd"));
            params.add(new BasicNameValuePair("oauth_signature_method"	, "HMAC-SHA1"));
            params.add(new BasicNameValuePair("oauth_timestamp"		, ((int)(System.currentTimeMillis()/1000)+"")));
            params.add(new BasicNameValuePair("oauth_version", "1.0")); //is not required and must be omitted.

            java.util.Collections.sort(params, nameValuePairComparator);

            String paramString = URLEncodedUtils.format(params, ENC);

            final String oauth_signature =  getSignature(
                    "GET",
                    URLEncoder.encode(url, ENC),
                    URLEncoder.encode(paramString, ENC)
            );

            //System.out.println("-- oauth_signature: 	[" + oauth_signature + "] 		--");
            params.add(new BasicNameValuePair("oauth_signature", oauth_signature));

            if(debugLog) {
                System.out.println("-- request_url: 	[" + url + "] 		--");
                for (NameValuePair param : params) {
                    System.out.println("-- oauth_signature: 	[" + param.getName() + "],[" + param.getValue() + "] 		--");
                }
            }

            java.util.Collections.sort(params, nameValuePairComparator);

            paramString = URLEncodedUtils.format(params, ENC);

            return url + "?" + paramString;
        }
        catch (IOException e)
        {
            e.printStackTrace();
            return "";
        }
        catch (InvalidKeyException e)
        {
            e.printStackTrace();
            return "";
        }
        catch (NoSuchAlgorithmException e)
        {
            e.printStackTrace();
            return "";
        }
        catch (Exception e)
        {
            e.printStackTrace();
            return "";
        }
    }

    public static void makeGetRequest (
                            final String url,
                            final List<NameValuePair> extraParams,
                            final RequestListener requestListener
                        )
    {
        new Thread()
        {
            @Override
            public void run()
            {
                try
                {
                    final List<NameValuePair> params = new LinkedList<NameValuePair>();

                    if(extraParams != null)
                    {
                        params.addAll(extraParams);
                    }

                    params.add(new BasicNameValuePair("filter[limit]"		, "100"));
                    params.add(new BasicNameValuePair("oauth_consumer_key"	, oauth_consumer_key));
                    params.add(new BasicNameValuePair("oauth_nonce"		, ((int) (Math.random() * 100000000))+"")); //"aaaaaddddd"));
                    params.add(new BasicNameValuePair("oauth_signature_method"	, "HMAC-SHA1"));
                    params.add(new BasicNameValuePair("oauth_timestamp"		, ((int)(System.currentTimeMillis()/1000)+"")));
                    params.add(new BasicNameValuePair("oauth_version", "1.0")); //is not required and must be omitted.

                    java.util.Collections.sort(params, nameValuePairComparator);

                    String paramString = URLEncodedUtils.format(params, ENC);

                    final String oauth_signature =  getSignature(
                            "GET",
                            URLEncoder.encode(url, ENC),
                            URLEncoder.encode(paramString, ENC)
                    );

                    //System.out.println("-- oauth_signature: 	[" + oauth_signature + "] 		--");
                    params.add(new BasicNameValuePair("oauth_signature", oauth_signature));

                    if(debugLog) {
                        System.out.println("-- request_url: 	[" + url + "] 		--");
                        for (NameValuePair param : params) {
                            System.out.println("-- oauth_signature: 	[" + param.getName() + "],[" + param.getValue() + "] 		--");
                        }
                    }

                    java.util.Collections.sort(params, nameValuePairComparator);

                    paramString = URLEncodedUtils.format(params, ENC);

                    doInBackground(url + "?" + paramString, requestListener);
                }
                catch (IOException e)
                {
                    requestListener.onRequestFailed(e);
                    e.printStackTrace();
                }
                catch (InvalidKeyException e)
                {
                    requestListener.onRequestFailed(e);
                    e.printStackTrace();
                }
                catch (NoSuchAlgorithmException e)
                {
                    requestListener.onRequestFailed(e);
                    e.printStackTrace();
                }
                catch (Exception e)
                {
                    requestListener.onRequestFailed(e);
                    e.printStackTrace();
                }/*
                catch (ClientProtocolException e)
                {
                    requestListener.onRequestFailed(e);
                    e.printStackTrace();
                }
                catch (URISyntaxException e)
                {
                    requestListener.onRequestFailed(e);
                    e.printStackTrace();
                }*/
            }
        }.start();
    }

    private static void doInBackground(String url, RequestListener requestListener)
    {
        String output = "";
        try
        {
            URI uri = new URI( url );
            ////System.out.println("Get Token and Token Secrect from:" + uri.toString());
            HttpGet httpget = new HttpGet(uri);
            // output the response content.
            ////System.out.println("oken and Token Secrect:");

            HttpClient httpclient = new DefaultHttpClient();
            HttpResponse response = httpclient.execute(httpget);
            HttpEntity entity = response.getEntity();
            if (entity != null) {
                ////System.out.println("-----------------------------------------");
                InputStream instream = entity.getContent();
                int len;
                byte[] tmp = new byte[2048];
                while ((len = instream.read(tmp)) != -1) {
                    output += new String(tmp, 0, len, ENC);
                }
                ////System.out.println("-----------------------------------------");
            }

            if(requestListener != null)
            {
                requestListener.onRequestCompleted(output);
            }
        }
        catch (Exception e)
        {
            if(requestListener != null)
            {
                requestListener.onRequestFailed(e);
            }
        }
    }
    
    
}
