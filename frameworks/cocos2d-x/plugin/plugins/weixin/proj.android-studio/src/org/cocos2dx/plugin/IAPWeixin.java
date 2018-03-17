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

import java.util.Hashtable;
import java.util.UUID;

import android.app.Activity;
import android.content.Context;
import android.util.Log;

public class IAPWeixin implements InterfaceIAP {

	private static final String LOG_TAG = "IAPWeixin";
	private static Activity mContext = null;
	private static IAPWeixin mWeixin = null;
	private static boolean bDebug = false;

	protected static void LogE(String msg, Exception e) {
		Log.e(LOG_TAG, msg, e);
		e.printStackTrace();
	}

	protected static void LogD(String msg) {
		if (bDebug) {
			Log.d(LOG_TAG, msg);
		}
	}

	public IAPWeixin(Context context) {
		mContext = (Activity) context;
		mWeixin = this;
	}

	@Override
	public void configDeveloperInfo(Hashtable<String, String> cpInfo) {
		LogD("initDeveloperInfo invoked " + cpInfo.toString());
		final Hashtable<String, String> curCPInfo = cpInfo;
		PluginWrapper.runOnMainThread(new Runnable() {
			@Override
			public void run() {
				try {
				    String appId = curCPInfo.get("AppId");
                    WeixinWrapper.initSDK(mContext, appId);
				} catch (Exception e) {
					LogE("Developer info is wrong!", e);
				}
			}
		});
	}

	@Override
	public void setDebugMode(boolean debug) {
		bDebug = debug;
	}

	@Override
	public String getSDKVersion() {
		return WeixinWrapper.getSDKVersion();
	}

	@Override
	public String getPluginVersion() {
		return WeixinWrapper.getPluginVersion();
	}	

	@Override
	public void payForProduct(Hashtable<String, String> info) {
		LogD("payForProduct invoked " + info.toString());
		if (! WeixinWrapper.isInited()) {
			payResult(IAPWrapper.PAYRESULT_FAIL, "支付失败");
			return;
		}

		if (! WeixinWrapper.isInstalled()) {
			payResult(IAPWrapper.PAYRESULT_FAIL, "支付失败");
			return;
		}

		if (! WeixinWrapper.networkReachable(mContext)) {
			payResult(IAPWrapper.PAYRESULT_FAIL, "支付失败");
			return;
		}

		if (! WeixinWrapper.isLogined()) {
			payResult(IAPWrapper.PAYRESULT_FAIL, "支付失败");
			return;
		}

		final Hashtable<String, String> curProductInfo = info;

		PluginWrapper.runOnMainThread(new Runnable() {
			@Override
			public void run() {
				try {
					String partner = curProductInfo.get("PartnerId");
                    String prepay = curProductInfo.get("PrepayId");
					String nonce = curProductInfo.get("NonceStr");
					String time = curProductInfo.get("TimeStamp");
					String sign = curProductInfo.get("Sign");
					WeixinWrapper.pay(partner, prepay, nonce, time, sign);
				} catch (Exception e) {
					payResult(IAPWrapper.PAYRESULT_FAIL, "支付失败");
				}
			}
		});
	}

	public static void payResult(int ret, String msg) {
		IAPWrapper.onPayResult(mWeixin, ret, msg);
		LogD("IAPWeixin result : " + ret + " msg : " + msg);
	}

}
