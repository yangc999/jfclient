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

import android.app.Activity;
import android.content.Context;
import android.util.Log;

public class UserWeixin implements InterfaceUser {

	private static final String LOG_TAG = "UserWeixin";
	private static Activity mContext = null;
	private static UserWeixin mWeixin = null;
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

	public UserWeixin(Context context) {
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
    public void login() {
        LogD("start login");
        if (! WeixinWrapper.isInited()) {
            LogD("not inited");
            loginResult(UserWrapper.ACTION_RET_LOGIN_FAILED, "登录失败");
            return;
        }

        if (! WeixinWrapper.isInstalled()) {
            LogD("not installed");
            loginResult(UserWrapper.ACTION_RET_LOGIN_FAILED_NOTINSTALL, "登录失败,未安装微信");
            return;
        }

        if (! WeixinWrapper.networkReachable(mContext)) {
            LogD("not connected");
            loginResult(UserWrapper.ACTION_RET_LOGIN_FAILED, "登录失败");
            return;
        }

        PluginWrapper.runOnMainThread(new Runnable() {
            @Override
            public void run() {
                WeixinWrapper.login();
            }
        });
    }

    @Override
    public void logout() {
        PluginWrapper.runOnMainThread(new Runnable() {
            @Override
            public void run() {
                loginResult(UserWrapper.ACTION_RET_LOGOUT_SUCCEED, "登出成功");
            }
        });
    }

    @Override
    public boolean isLogined() {
        return WeixinWrapper.isLogined();
    }

    @Override
    public String getSessionID() {
        String strRet = "";
        if (isLogined()) {
            strRet = WeixinWrapper.code;
        }
        return strRet;
    }

    public static void loginResult(int ret, String msg) {
        UserWrapper.onActionResult(mWeixin, ret, msg);
        LogD("UserWeixin result : " + ret + " msg : " + msg);
    }

}
