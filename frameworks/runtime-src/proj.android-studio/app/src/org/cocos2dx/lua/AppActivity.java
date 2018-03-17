/****************************************************************************
 Copyright (c) 2008-2010 Ricardo Quesada
 Copyright (c) 2010-2016 cocos2d-x.org
 Copyright (c) 2013-2017 Chukong Technologies Inc.

 http://www.cocos2d-x.org

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/
package org.cocos2dx.lua;

import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.plugin.PluginWrapper;

import android.app.PendingIntent;
import android.content.Intent;
import android.os.Bundle;

import android.net.ConnectivityManager;
import android.telephony.TelephonyManager;
import android.os.BatteryManager;
import android.location.LocationManager;
import android.content.BroadcastReceiver;
import android.telephony.PhoneStateListener;
import android.telephony.SignalStrength;
import android.net.NetworkInfo;
import android.content.Context;
import android.content.IntentFilter;
import android.location.Location;
import android.location.LocationListener;
import android.net.Uri;
import android.util.Log;

public class AppActivity extends Cocos2dxActivity {
    private static float batteryLevel = 0.0f;
    private static int networkStrength = 0;
    private static double longitude = 0.0f;
    private static double latitude = 0.0f;

    @Override
    protected void onCreate(final Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        PluginWrapper.init(this);
        PluginWrapper.setGLSurfaceView(this.getGLSurfaceView());
        Log.d("AppActivity", "onCreate");
        ;
        registerReceiver(new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                int level = intent.getIntExtra(BatteryManager.EXTRA_LEVEL, 100);
                int scale = intent.getIntExtra(BatteryManager.EXTRA_SCALE, 100);
                batteryLevel = level/scale;
            }
        }, new IntentFilter(Intent.ACTION_BATTERY_CHANGED));

        TelephonyManager telMgr = (TelephonyManager)getContext().getSystemService(Context.TELEPHONY_SERVICE);
        telMgr.listen(new PhoneStateListener() {
            @Override
            public void onSignalStrengthsChanged(SignalStrength signalStrength) {
                networkStrength = signalStrength.getGsmSignalStrength();
            }
        }, PhoneStateListener.LISTEN_SIGNAL_STRENGTHS);

        LocationManager locMgr = (LocationManager)getContext().getSystemService(Context.LOCATION_SERVICE);
        locMgr.requestLocationUpdates(LocationManager.GPS_PROVIDER, 0, 0, new LocationListener() {
            @Override
            public void onLocationChanged(Location location) {
                longitude = location.getLongitude();
                latitude = location.getLatitude();
            }

            @Override
            public void onStatusChanged(String s, int i, Bundle bundle) {

            }

            @Override
            public void onProviderEnabled(String s) {

            }

            @Override
            public void onProviderDisabled(String s) {

            }
        });
    }

    @Override
    protected void onResume() {
        super.onResume();
        PluginWrapper.onResume();
    }

    @Override
    protected void onPause() {
        super.onPause();
        PluginWrapper.onPause();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        PluginWrapper.onDestroy();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if(!PluginWrapper.onActivityResult(requestCode, resultCode, data)) {
            super.onActivityResult(requestCode, resultCode, data);
        }
    }

    @Override
    public void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
    }

    public static String getIMEI() {
        TelephonyManager telephonyManager = (TelephonyManager)getContext().getSystemService(Context.TELEPHONY_SERVICE);
        String uniqueId = telephonyManager.getDeviceId();
        return uniqueId;
    }

    public static String getNetworkType() {
        String type = "";
        ConnectivityManager conn = (ConnectivityManager)getContext().getSystemService(Context.CONNECTIVITY_SERVICE);
        NetworkInfo netInfo = conn.getActiveNetworkInfo();
        if (netInfo != null) {
            type = netInfo.getTypeName();
        }
        return type;
    }

    public static int getNetworkStrength() {
        return networkStrength;
    }

    public static float getBatteryLevel() {
        return batteryLevel;
    }

    public static boolean isGpsEnabled() {
        LocationManager locMgr = (LocationManager)getContext().getSystemService(Context.LOCATION_SERVICE);
        return locMgr.isProviderEnabled(LocationManager.GPS_PROVIDER);
    }

    public static void openGps() {
        Intent gpsIntent = new Intent();
        gpsIntent.setClassName("com.android.settings", "com.android.settings.widget.SettingsAppWidgetProvider");
        gpsIntent.addCategory("android.intent.category.ALTERNATIVE");
        gpsIntent.setData(Uri.parse("custom:3"));
        try  {
            PendingIntent.getBroadcast(getContext(), 0, gpsIntent, 0).send();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static double getLongitude() {
        return longitude;
    }

    public static double getLatitude() {
        return latitude;
    }
}
