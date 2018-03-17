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
import java.util.Map;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.text.TextUtils;
import android.os.Handler;
import android.os.Message;
import android.util.Log;

import com.alipay.sdk.app.PayTask;

public class IAPAlipay implements InterfaceIAP {

	private static final String LOG_TAG = "IAPAlipay";
	private static Activity mContext = null;
	@SuppressLint("HandlerLeak")
	private static Handler mHandler = null;
	private static IAPAlipay mAli = null;
	private static boolean bDebug = false;
	private static final int SDK_PAY_FLAG = 1;

	protected static void LogE(String msg, Exception e) {
		Log.e(LOG_TAG, msg, e);
		e.printStackTrace();
	}

	protected static void LogD(String msg) {
		if (bDebug) {
			Log.d(LOG_TAG, msg);
		}
	}

	public IAPAlipay(Context context) {
		mContext = (Activity) context;
		mAli = this;
		PluginWrapper.runOnMainThread(new Runnable() {
			@Override
			public void run() {
				initUIHandle();
			}
		});
	}

	@Override
	public void configDeveloperInfo(Hashtable<String, String> cpInfo) {
		LogD("initDeveloperInfo invoked " + cpInfo.toString());
	}

	@Override
	public void setDebugMode(boolean debug) {
		bDebug = debug;
	}

	@Override
	public String getSDKVersion() {
		return "20170922";
	}

	@Override
	public String getPluginVersion() {
		return "0.2.0";
	}	

	@Override
	public void payForProduct(Hashtable<String, String> info) {
		LogD("payForProduct invoked " + info.toString());
		final Hashtable<String, String> curProductInfo = info;
		try {
			final String orderInfo = curProductInfo.get("OrderInfo");
			Runnable payRunnable = new Runnable() {
				@Override
				public void run() {
					PayTask alipay = new PayTask(mContext);
					Map<String, String> result = alipay.payV2(orderInfo, true);
					Log.i("msp", result.toString());				
					Message msg = new Message();
					msg.what = SDK_PAY_FLAG;
					msg.obj = result;
					mHandler.sendMessage(msg);
				}
			};
			Thread payThread = new Thread(payRunnable);
			payThread.start();
		} catch (Exception e) {
			payResult(IAPWrapper.PAYRESULT_FAIL, "支付失败");
		}
	}

	public static void payResult(int ret, String msg) {
		IAPWrapper.onPayResult(mAli, ret, msg);
		LogD("IAPAlipay result : " + ret + " msg : " + msg);
	}

	private static void initUIHandle() {
		mHandler = new Handler() {
			@SuppressWarnings("unused")
			public void handleMessage(Message msg) {
				switch (msg.what) {
				case SDK_PAY_FLAG: {
					@SuppressWarnings("unchecked")
					PayResult payResult = new PayResult((Map<String, String>) msg.obj);
					String resultInfo = payResult.getResult();// 同步返回需要验证的信息
					String resultStatus = payResult.getResultStatus();
					if (TextUtils.equals(resultStatus, "9000")) {
						Log.d("Alipay", "pay success");
						payResult(IAPWrapper.PAYRESULT_SUCCESS, "支付成功");
					} else {
						Log.d("Alipay", "pay fail");
						payResult(IAPWrapper.PAYRESULT_FAIL, "支付失败");		
					}
					break;
				}
				default:
					break;
				}
			}
		};
	}	

}
