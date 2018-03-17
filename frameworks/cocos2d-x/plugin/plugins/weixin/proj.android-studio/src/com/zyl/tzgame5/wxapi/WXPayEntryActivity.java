package com.zyl.tzgame5.wxapi;

import com.tencent.mm.opensdk.constants.ConstantsAPI;
import com.tencent.mm.opensdk.modelbase.BaseReq;
import com.tencent.mm.opensdk.modelbase.BaseResp;
import com.tencent.mm.opensdk.openapi.IWXAPIEventHandler;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;

import org.cocos2dx.plugin.IAPWeixin;
import org.cocos2dx.plugin.IAPWrapper;
import org.cocos2dx.plugin.WeixinWrapper;

import android.util.Log;

public class WXPayEntryActivity extends Activity implements IWXAPIEventHandler {

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		WeixinWrapper.api.handleIntent(getIntent(), this);
	}

	@Override
	protected void onNewIntent(Intent intent) {
		super.onNewIntent(intent);
		setIntent(intent);
		WeixinWrapper.api.handleIntent(intent, this);
	}

	@Override
	public void onReq(BaseReq req) {

	}

	@Override
	public void onResp(BaseResp resp) {
		Log.d("PayEntry", "onResp");
		if (resp.getType() == ConstantsAPI.COMMAND_PAY_BY_WX) {
			Log.d("PayEntry", "errCode:" + resp.errCode);
			Log.d("PayEntry", "errStr:" + resp.errStr);
			switch (resp.errCode) {
			case BaseResp.ErrCode.ERR_OK:
				IAPWeixin.payResult(IAPWrapper.PAYRESULT_SUCCESS, "支付成功");
				break;
			case BaseResp.ErrCode.ERR_USER_CANCEL:
				IAPWeixin.payResult(IAPWrapper.PAYRESULT_FAIL, "支付失败");
				break;
			case BaseResp.ErrCode.ERR_AUTH_DENIED:
				IAPWeixin.payResult(IAPWrapper.PAYRESULT_FAIL, "支付失败");
				break;
			default:
				IAPWeixin.payResult(IAPWrapper.PAYRESULT_FAIL, "支付失败");
				break;
			}
		}
		finish();
	}
	
}