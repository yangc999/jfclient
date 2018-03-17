package com.zyl.tzgame5.wxapi;

import com.tencent.mm.opensdk.constants.ConstantsAPI;
import com.tencent.mm.opensdk.modelbase.BaseReq;
import com.tencent.mm.opensdk.modelbase.BaseResp;
import com.tencent.mm.opensdk.openapi.IWXAPIEventHandler;
import com.tencent.mm.opensdk.modelmsg.SendAuth;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;

import android.util.Log;
import android.widget.Toast;

import org.cocos2dx.plugin.ShareWeixin;
import org.cocos2dx.plugin.ShareWrapper;
import org.cocos2dx.plugin.UserWeixin;
import org.cocos2dx.plugin.UserWrapper;
import org.cocos2dx.plugin.WeixinWrapper;

public class WXEntryActivity extends Activity implements IWXAPIEventHandler {

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
		Log.d("WX", "WX 返回码:" + String.valueOf(resp.errCode));
        if (resp.getType() == ConstantsAPI.COMMAND_SENDAUTH) {
            switch (resp.errCode) {
            case BaseResp.ErrCode.ERR_OK:
                String code = ((SendAuth.Resp)resp).code;
                WeixinWrapper.code = code;
                UserWeixin.loginResult(UserWrapper.ACTION_RET_LOGIN_SUCCEED, code);
                break;
            case BaseResp.ErrCode.ERR_USER_CANCEL:
                UserWeixin.loginResult(UserWrapper.ACTION_RET_LOGIN_FAILED, "用户取消");
                break;
            case BaseResp.ErrCode.ERR_AUTH_DENIED:
                UserWeixin.loginResult(UserWrapper.ACTION_RET_LOGIN_FAILED, "拒绝授权");
                break;
            default:
                UserWeixin.loginResult(UserWrapper.ACTION_RET_LOGIN_FAILED, resp.errCode+"");
                break;
            }
        }
        if (resp.getType() == ConstantsAPI.COMMAND_SENDMESSAGE_TO_WX) {
			switch (resp.errCode) {
			case BaseResp.ErrCode.ERR_OK:
			    ShareWeixin.shareResult(ShareWrapper.SHARERESULT_SUCCESS, "分享成功");
				break;
			case BaseResp.ErrCode.ERR_USER_CANCEL:
				ShareWeixin.shareResult(ShareWrapper.SHARERESULT_FAIL, resp.errCode+"fffg");
				break;
			case BaseResp.ErrCode.ERR_AUTH_DENIED:
				ShareWeixin.shareResult(ShareWrapper.SHARERESULT_FAIL, resp.errCode+"fffg");
				break;
			default:
				ShareWeixin.shareResult(ShareWrapper.SHARERESULT_FAIL, resp.errCode+"fffg");
				break;
			}
		}
		finish();
	}

}