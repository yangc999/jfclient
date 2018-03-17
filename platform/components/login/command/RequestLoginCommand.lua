
local SimpleCommand = cc.load("puremvc").SimpleCommand
local RequestLoginCommand = class("RequestLoginCommand", SimpleCommand)

function RequestLoginCommand:execute(notification)
	print("exec Guest Login")
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

	local load = platformFacade:retrieveProxy("LoadProxy")
	local login = platformFacade:retrieveProxy("LoginProxy")

	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
	xhr:open("POST", load:getData().serviceUrl.."login")
	local function onReadyStateChange()
		if xhr.readyState == 4 and xhr.status >= 200 and xhr.status < 207 then
			local tarslib = cc.load("jfutils").Tars
			local str = xhr.response
			local _, res1 = tarslib.decode(str, "JFGame::THttpPackage")
			local _, res2 = tarslib.decode(res1.vecData, "JFGame::TLoginMsg")
			local _, res3 = tarslib.decode(res2.vecData, "JFGame::TRspGuestLogin")
			if res3.iRetCode == 0 then
				login:getData().uid = res3.lUid
				login:getData().token = res3.sToken
				local scene = platformFacade:retrieveMediator("LoginMediator").scene
				platformFacade:sendNotification(PlatformConstants.START_HALL, scene)
			end
		else
			print("网络异常，请重新检查网络后尝试重新连接（如有问题请联系客服）")
			platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "网络异常，请重新检查网络后尝试重新连接（如有问题请联系客服）")
		end
		xhr:unregisterScriptHandler()
	end
	xhr:registerScriptHandler(onReadyStateChange)

	local tarslib = cc.load("jfutils").Tars
	local pak1 = {
		sDeviceNo = load:getData().deviceCode, 
	}
	local req1 = tarslib.encode(pak1, "JFGame::TReqGuestLogin")
	local pak2 = {
		eAct = 3,
		vecData = req1, 
	}
	local req2 = tarslib.encode(pak2, "JFGame::TLoginMsg")
	local pak3 = {
		iVer = load:getData().version, 
		iSeq = load:getData().sequence, 
		stUid = {
			lUid = login:getData().uid, 
			sToken = login:getData().token, 
		}, 
		vecData = req2,
	}
	local req3 = tarslib.encode(pak3, "JFGame::THttpPackage")
	xhr:send(req3)
    self:showLoading(notification)
end

--显示loading进度条
function RequestLoginCommand:showLoading(notification)
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
    --重新请求游戏列表
    local function retryReqShopList()
         local strMsg = "登录超时,是否重试?"
         local function okCall()  --确定按钮回调
            self:execute(notification)
         end
         local tMsg = {mType = 2, msg = strMsg, okCallback = okCall} --类型为2，code无用，msg为显示的描述，okCallback为按确定按钮的回调函数
         platformFacade:sendNotification(PlatformConstants.UPDATE_MSGBOX_EX, tMsg)  --弹出MsgBox，等用户确定。真正的购买请求在MSGBOX_OK消息处理里
    end
    print("login loading...")
    --显示转圈条
    cc.exports.showLoadingAnim("登录中...","登录超时", retryReqShopList, 5)
end

return RequestLoginCommand