/****************************************************************************
Copyright (c) 2012-2013 cocos2d-x.org

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
package org.cocos2dx.plugin;

import android.content.Context;
import android.graphics.Bitmap;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;

import java.io.IOException;
import java.util.Hashtable;

import com.tencent.mm.opensdk.modelmsg.SendMessageToWX;
import com.tencent.mm.opensdk.modelmsg.WXImageObject;
import com.tencent.mm.opensdk.modelmsg.WXMediaMessage;
import com.tencent.mm.opensdk.modelmsg.WXWebpageObject;
import com.tencent.mm.opensdk.modelmsg.SendAuth;
import com.tencent.mm.opensdk.modelpay.PayReq;
import com.tencent.mm.opensdk.openapi.IWXAPI;
import com.tencent.mm.opensdk.openapi.WXAPIFactory;

import android.util.Log;

public class WeixinWrapper {

    public static String wxAppId = "";
    private static boolean isInited = false;
    public static IWXAPI api;
    public static String code = "";

    public static void initSDK(Context ctx, String appId) {
        if (isInited) {
            return;
        }
        wxAppId = appId;
        api = WXAPIFactory.createWXAPI(ctx, appId, true);
        api.registerApp(appId);
        isInited = true;
        Log.d("WeixinWrapper", "init succeed!");
    }

    public static boolean isLogined() {
        return code.length() > 0;
    }

    public static void login() {
        SendAuth.Req req = new SendAuth.Req();
        req.scope = "snsapi_userinfo";
        req.state = "com.zyl.tzgame5";
        boolean success = api.sendReq(req);
        Log.d("WeixinWrapper", "send login" + success);
    }

    public static void share(String url, String title, String desc, Bitmap img, int scene) {
        WXMediaMessage msg = new WXMediaMessage();
        WXWebpageObject page = new WXWebpageObject();
        page.webpageUrl = url;
        msg.mediaObject = page;
        msg.title = title;
        msg.description = desc;
        msg.setThumbImage(img);
        SendMessageToWX.Req req = new SendMessageToWX.Req();
        req.transaction = String.valueOf(System.currentTimeMillis());
        req.message = msg;
        req.scene = scene;
        boolean success = api.sendReq(req);
        Log.d("WeixinWrapper", "send share" + success);
    }

    public static void pay(String partner, String prepay, String nonce, String time, String sign) {
        PayReq request = new PayReq();
        request.appId = wxAppId;
        request.partnerId = partner;
        request.packageValue = "Sign=WXPay";
        request.prepayId = prepay;
        request.nonceStr = nonce;
        request.timeStamp = time;
        request.sign = sign;
        boolean success = api.sendReq(request);
        Log.d("WeixinWrapper", "send pay" + success);
    }

    public static String getSDKVersion() {
        return "20130607_3.2.5.1";
    }

    public static String getPluginVersion() {
        return "0.2.0";
    }

    public static boolean isInited() {
        return isInited;
    }

    public static boolean isInstalled() {
        return api.isWXAppInstalled();
    }

    public static boolean networkReachable(Context ctx) {
        boolean bRet = false;
        try {
            ConnectivityManager conn = (ConnectivityManager)ctx.getSystemService(Context.CONNECTIVITY_SERVICE);
            NetworkInfo netInfo = conn.getActiveNetworkInfo();
            bRet = (null == netInfo) ? false : netInfo.isAvailable();
        } catch (Exception e) {
            e.printStackTrace();
        }

        return bRet;
    }
}
