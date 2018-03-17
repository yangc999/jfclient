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

import java.io.IOException;
import java.util.Hashtable;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;

import android.app.Activity;
import android.content.Context;
import android.net.NetworkInfo;
import android.os.Bundle;
import android.util.Log;

public class ShareWeixin implements InterfaceShare {

	private static final String LOG_TAG = "ShareWeixin";
	private static Activity mContext = null;
	private static ShareWeixin mWeixin = null;
	protected static boolean bDebug = false;

	protected static void LogE(String msg, Exception e) {
		Log.e(LOG_TAG, msg, e);
		e.printStackTrace();
	}

	protected static void LogD(String msg) {
		if (bDebug) {
			Log.d(LOG_TAG, msg);
		}
	}

	public ShareWeixin(Context context) {
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
	public void share(Hashtable<String, String> info) {
		LogD("share invoked " + info.toString());
		if (! WeixinWrapper.isInited()) {
			shareResult(ShareWrapper.SHARERESULT_FAIL, "分享失败，未初始化");
			return;
		}

		if (! WeixinWrapper.isInstalled()) {
			shareResult(ShareWrapper.SHARERESULT_FAIL, "分享失败，未安装");
			return;
		}

		if (! WeixinWrapper.networkReachable(mContext)) {
			shareResult(ShareWrapper.SHARERESULT_FAIL, "分享失败，网络问题");
			return;
		}

//		if (! WeixinWrapper.isLogined()) {
//			shareResult(ShareWrapper.SHARERESULT_FAIL, "分享失败，未登录");
//			return;
//		}

		final Hashtable<String, String> curShareInfo = info;

		PluginWrapper.runOnMainThread(new Runnable() {
			@Override
			public void run() {
				try {
					String url = curShareInfo.get("url");
					String title = curShareInfo.get("title");
					String desc = curShareInfo.get("desc");
					String imgPath = curShareInfo.get("imgPath");
					Bitmap img = BitmapFactory.decodeFile(imgPath);
					String scene = curShareInfo.get("scene");
					WeixinWrapper.share(url, title, desc, img, Integer.parseInt(scene));
				} catch (Exception e) {
					shareResult(ShareWrapper.SHARERESULT_FAIL, "分享失败");
				}
			}
		});
	}

	public static void shareResult(int ret, String msg) {
		ShareWrapper.onShareResult(mWeixin, ret, msg);
		LogD("ShareWeixin result : " + ret + " msg : " + msg);
	}
	
}
