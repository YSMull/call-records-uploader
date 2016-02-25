package com.example.myapp;

import android.app.Activity;
import android.content.ContentResolver;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.provider.CallLog;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;
import com.android.volley.*;
import com.android.volley.toolbox.JsonObjectRequest;
import com.android.volley.toolbox.StringRequest;
import com.android.volley.toolbox.Volley;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

public class MyActivity extends Activity {
    private String appendParameter(String url,Map<String,String> params){
        Uri uri = Uri.parse(url);
        Uri.Builder builder = uri.buildUpon();
        for(Map.Entry<String,String> entry:params.entrySet()){
            builder.appendQueryParameter(entry.getKey(),entry.getValue());
        }
        return builder.build().getQuery();
    }
    /**
     * Called when the activity is first created.
     */
    private Button inquire_button;
    private Button upload_button;
    private static String URL = "http://www.ysmull.cn:8080/html/show.php";
    private static String insertURL = "http://www.ysmull.cn:8080/html/insert.php";
    private RequestQueue requestQueue;
    private JsonObjectRequest request;
    private TextView result;
    private static long last_time;

    public Cursor getSearchPhone() {
        ContentResolver cr = getContentResolver();
        Cursor c = cr.query(CallLog.Calls.CONTENT_URI,
                new String[]{CallLog.Calls.CACHED_NAME,
                        CallLog.Calls.TYPE,CallLog.Calls.NUMBER,
                        CallLog.Calls.DATE,CallLog.Calls.DURATION}, null, null, null);
        return c;

    }

    public void setLast_time() {

        StringRequest Request_last_date = new StringRequest(Request.Method.POST, URL, new Response.Listener<String>() {
            @Override
            public void onResponse(String response) {
                try{
                    JSONObject jsonObject= new JSONObject(response.toString());
                    JSONArray last_date = jsonObject.getJSONArray("last_date");
                    //get value from jsonRow
                    if(last_date.length() > 0) {
                        last_time = Long.parseLong(last_date.getJSONObject(0).getString("date"));
                        SimpleDateFormat sdf=new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                        String sd = sdf.format(new Date(last_time));
                        result.append("Get last time from server:\n" + sd + "\n");
                    } else {
                        last_time = System.currentTimeMillis();
                        result.append("Can't get last date from server!\n");
                    }
                } catch (JSONException e) {
                    result.append("Date from server error!\n");
                }
            }
        }, new Response.ErrorListener() {
            @Override
            public void onErrorResponse(VolleyError error) {
            }
        }){
            @Override
            protected Map<String, String> getParams() throws AuthFailureError {
                Map<String, String> m = new HashMap<String, String>();
                return m;
            }
        };
        requestQueue.add(Request_last_date);
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
        inquire_button = (Button) findViewById(R.id.inquire_button);
        upload_button = (Button) findViewById(R.id.upload_button);
        result = (TextView) findViewById(R.id.result);

        requestQueue = Volley.newRequestQueue(this);
        setLast_time();


        inquire_button.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                HashMap<String, String> params = new HashMap<String, String>();
                //params.put("token", "AbCdEfGh123456");
                JsonObjectRequest req = new JsonObjectRequest(URL, new JSONObject(params),
                        new Response.Listener<JSONObject>() {
                            @Override
                            public void onResponse(JSONObject response) {
                                try {
                                    JSONObject jsonObject= new JSONObject(response.toString());
                                    JSONArray last_date = jsonObject.getJSONArray("last_date");
                                    //get value from jsonRow
                                    last_time = System.currentTimeMillis();
                                    if(last_date.length() > 0) {
                                        last_time = Long.parseLong(last_date.getJSONObject(0).getString("date"));
                                        SimpleDateFormat sdf=new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                                        String sd = sdf.format(new Date(last_time));
                                        result.append("Get last time form server: " + sd + "\n");
                                    }
                                } catch (JSONException e) {
                                    result.append("err2: " + e.getMessage() + "\n");
                                }
                            }
                        }, new Response.ErrorListener() {
                    @Override
                    public void onErrorResponse(VolleyError error) {
                        VolleyLog.e("Error: ", error.getMessage());
                    }
                });
                requestQueue.add(req);
            }
        });


        upload_button.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {


                Cursor c = getSearchPhone();
                int add_items = 0;
                while(c.moveToNext()) {
                    long date = c.getLong(c.getColumnIndex(CallLog.Calls.DATE));
                    if(date > last_time) {
                        add_items++;
                        String number = c.getString(c.getColumnIndex(CallLog.Calls.NUMBER));
                        long duration = c.getLong(c.getColumnIndex(CallLog.Calls.DURATION));
                        int type = c.getInt(c.getColumnIndex(CallLog.Calls.TYPE));
                        //result.append(Long.toString(date) + "\nnumber:" + number + "\nduration:" + duration + "\n");
                        //CallLog.Calls.INCOMING_TYPE, CallLog.Calls.OUTGOING_TYPE, CallLog.Calls.MISSED_TYPE
                        StringRequest stringRequest = new StringRequest(Request.Method.POST, insertURL, new Response.Listener<String>() {
                            @Override
                            public void onResponse(String response) {
                            }
                        }, new Response.ErrorListener() {
                            @Override
                            public void onErrorResponse(VolleyError error) {
                            }
                        }) {
                            @Override
                            protected Map<String, String> getParams() throws AuthFailureError {

                                Map<String, String> parameters = new HashMap<String, String>();
                                parameters.put("date", Long.toString(date));
                                parameters.put("number", number);
                                parameters.put("duration", Long.toString(duration));
                                parameters.put("type", Integer.toString(type));
                                return parameters;
                            }
                        };
                        requestQueue.add(stringRequest);
                    }
                }
                result.append("update " + Integer.toString(add_items) + " items\n");

            }
        });
    }


}

